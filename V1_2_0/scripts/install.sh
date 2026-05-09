#!/usr/bin/env bash
#
# install.sh — fts-transform 글로벌 설치 스크립트
#
# 소스(레포): src/commands/fts-transform.md, src/fts-templates/**
# 대상(글로벌): ~/.claude/commands/fts-transform.md, ~/.claude/fts-templates/**
#
# 기본: 기존 파일이 있으면 `.bak-{TIMESTAMP}` 로 백업 후 덮어쓰기.
# 옵션: --dry-run (복사 없이 계획만 출력), --no-backup (백업 생략), -h/--help

set -euo pipefail

# ──────────────────────────────────────────────
# 설정
# ──────────────────────────────────────────────

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

SRC_COMMAND="${REPO_ROOT}/src/commands/fts-transform.md"
SRC_TEMPLATES="${REPO_ROOT}/src/fts-templates"

DEST_CLAUDE="${HOME}/.claude"
DEST_COMMAND="${DEST_CLAUDE}/commands/fts-transform.md"
DEST_TEMPLATES="${DEST_CLAUDE}/fts-templates"

TIMESTAMP="$(date +%Y%m%d-%H%M%S)"

DRY_RUN=0
NO_BACKUP=0

# ──────────────────────────────────────────────
# 인자 파싱
# ──────────────────────────────────────────────

usage() {
  cat <<'EOF'
usage: bash scripts/install.sh [--dry-run] [--no-backup] [-h|--help]

옵션:
  --dry-run     복사·생성 없이 대상 경로 목록만 출력
  --no-backup   기존 파일 백업 없이 덮어쓰기 (기본은 .bak-{TS} 백업 후 덮어쓰기)
  -h, --help    이 도움말 출력

동작:
  - 이 저장소의 src/commands/fts-transform.md 와 src/fts-templates/ 를
    ~/.claude/commands/ 와 ~/.claude/fts-templates/ 로 설치한다.
  - ~/.claude/ 외부에는 쓰지 않는다.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) DRY_RUN=1 ;;
    --no-backup) NO_BACKUP=1 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "알 수 없는 옵션: $1" >&2; usage; exit 2 ;;
  esac
  shift
done

# ──────────────────────────────────────────────
# 사전 체크
# ──────────────────────────────────────────────

if [[ ! -f "${SRC_COMMAND}" ]]; then
  echo "오류: ${SRC_COMMAND} 가 없음. 저장소 루트에서 실행했는지 확인." >&2
  exit 1
fi
if [[ ! -d "${SRC_TEMPLATES}" ]]; then
  echo "오류: ${SRC_TEMPLATES} 디렉토리가 없음." >&2
  exit 1
fi
if [[ ! -f "${SRC_TEMPLATES}/manifest.yml" ]]; then
  echo "오류: ${SRC_TEMPLATES}/manifest.yml 이 없음. 템플릿 빌드가 완료되지 않음." >&2
  exit 1
fi

# ~/.claude 쓰기 가능 여부
if [[ "${DRY_RUN}" -eq 0 ]]; then
  if [[ ! -d "${DEST_CLAUDE}" ]]; then
    mkdir -p "${DEST_CLAUDE}"
  fi
  if [[ ! -w "${DEST_CLAUDE}" ]]; then
    echo "오류: ${DEST_CLAUDE} 에 쓸 권한이 없음." >&2
    exit 1
  fi
fi

# ──────────────────────────────────────────────
# 복사 플랜 수집
# ──────────────────────────────────────────────

# 각 항목: "SRC|DEST"
plan=()

plan+=("${SRC_COMMAND}|${DEST_COMMAND}")

# src/fts-templates/ 내 모든 정규 파일
while IFS= read -r -d '' src_file; do
  rel_path="${src_file#${SRC_TEMPLATES}/}"
  dest_file="${DEST_TEMPLATES}/${rel_path}"
  plan+=("${src_file}|${dest_file}")
done < <(find "${SRC_TEMPLATES}" -type f -print0 | sort -z)

total="${#plan[@]}"

# ──────────────────────────────────────────────
# 출력/실행
# ──────────────────────────────────────────────

echo "fts-transform 설치"
echo "  소스: ${REPO_ROOT}"
echo "  대상: ${DEST_CLAUDE}"
if [[ "${DRY_RUN}" -eq 1 ]]; then
  echo "  모드: dry-run (실제 복사 없음)"
else
  echo "  모드: install"
  echo "  백업: $([[ "${NO_BACKUP}" -eq 1 ]] && echo "비활성" || echo "활성 (.bak-${TIMESTAMP})")"
fi
echo "  파일: ${total}개"
echo ""

copied=0
backed_up=0

for entry in "${plan[@]}"; do
  src="${entry%%|*}"
  dest="${entry##*|}"

  # 안전: dest 가 $HOME 로 시작하지 않으면 거부
  case "${dest}" in
    "${HOME}"/*) : ;;
    *)
      echo "거부: ${dest} 는 홈 디렉토리 외부." >&2
      exit 1
      ;;
  esac

  if [[ "${DRY_RUN}" -eq 1 ]]; then
    printf "  %s\n    → %s\n" "${src#${REPO_ROOT}/}" "${dest}"
    continue
  fi

  # 대상 디렉토리 보장
  dest_dir="$(dirname "${dest}")"
  mkdir -p "${dest_dir}"

  # 기존 파일 백업
  if [[ -e "${dest}" && "${NO_BACKUP}" -eq 0 ]]; then
    backup="${dest}.bak-${TIMESTAMP}"
    cp "${dest}" "${backup}"
    backed_up=$((backed_up + 1))
  fi

  cp "${src}" "${dest}"
  copied=$((copied + 1))
done

echo ""
if [[ "${DRY_RUN}" -eq 1 ]]; then
  echo "dry-run 완료. 실제 설치는 --dry-run 없이 재실행."
else
  echo "복사 완료: ${copied}개 파일"
  if [[ "${backed_up}" -gt 0 ]]; then
    echo "백업: ${backed_up}개 (.bak-${TIMESTAMP})"
  fi
  echo ""
  echo "다음 단계:"
  echo "  1. Claude Code 를 재시작해 /fts-transform 명령어 등록."
  echo "  2. 아무 프로젝트 디렉토리에서 /fts-transform 실행."
fi
