#!/usr/bin/env bash
#
# validate.sh — fts-transform 무결성 검증 (릴리즈 직전 사용)
#
# 4단계 검사:
#   1. 하드코딩 누출 (Solana/Telegram/XRPL/한국어/npx tsc 등이 변수·예시 밖에 박혀 있는지)
#   2. 변수↔manifest 정합성 (모든 {{VAR}} 가 manifest.yml variables: 에 정의됐는지)
#   3. install.sh --dry-run 카운트 (명령어 1 + 템플릿 26 = 27)
#   4. 조건 블록 짝 ({{#if}} ↔ {{/if}} 카운트 일치)
#
# 모든 검사 통과 시 exit 0. 첫 실패에서 즉시 exit 1.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

TEMPLATES_DIR="${REPO_ROOT}/src/fts-templates"
MANIFEST="${TEMPLATES_DIR}/manifest.yml"
INSTALL_SH="${SCRIPT_DIR}/install.sh"

EXPECTED_DRY_RUN_COUNT=27

# ──────────────────────────────────────────────
# 출력 헬퍼
# ──────────────────────────────────────────────

step()    { echo ""; echo "▶ [$1] $2"; }
ok()      { echo "  ✓ $*"; }
fail()    { echo "  ✗ $*" >&2; exit 1; }

# ──────────────────────────────────────────────
# 사전 점검
# ──────────────────────────────────────────────

[[ -d "${TEMPLATES_DIR}" ]] || fail "src/fts-templates/ 가 없다: ${TEMPLATES_DIR}"
[[ -f "${MANIFEST}" ]]      || fail "manifest.yml 이 없다: ${MANIFEST}"
[[ -x "${INSTALL_SH}" || -f "${INSTALL_SH}" ]] || fail "install.sh 가 없다: ${INSTALL_SH}"

echo "=== fts-transform 무결성 검증 ==="
echo "repo: ${REPO_ROOT}"

# ──────────────────────────────────────────────
# 1. 하드코딩 누출
#    제외: manifest.yml (Q&A 옵션 정의 소스 — value:/label:/question: 의 예시 문자열은 의도된 것)
#    제외: 01-language.template.md (LANG=="혼용" 조건블록 내 "한국어" 참조는 의도된 것)
# ──────────────────────────────────────────────

step 1 "하드코딩 누출 점검 (템플릿 본문)"

HARDCODED_HITS="$(grep -rn 'npx tsc\|Solana\|Telegram\|XRPL\|한국어' "${TEMPLATES_DIR}/" 2>/dev/null \
  | grep -vE '\{\{|# 예시|<!-- 예시|의 예시' \
  | grep -vE '/manifest\.yml:|/rules/01-language\.template\.md:' \
  || true)"

if [[ -n "${HARDCODED_HITS}" ]]; then
  echo "${HARDCODED_HITS}" >&2
  fail "하드코딩 누출 발견 (위 라인 검토 필요)"
fi
ok "템플릿 본문 하드코딩 0건 (manifest.yml·01-language 정상 예외)"

# ──────────────────────────────────────────────
# 2. 변수↔manifest 정합성
# ──────────────────────────────────────────────

step 2 "변수↔manifest 정합성"

# 템플릿에서 사용된 모든 {{VAR}} 추출 (조건 블록 마커 제외)
USED_VARS="$(grep -rhoE '\{\{[A-Z_]+\}\}' "${TEMPLATES_DIR}/" 2>/dev/null \
  | sed -E 's/^\{\{//; s/\}\}$//' \
  | sort -u || true)"

if [[ -z "${USED_VARS}" ]]; then
  fail "템플릿에서 {{VAR}} 가 하나도 발견되지 않음 (스캔 실패?)"
fi

MISSING=""
while IFS= read -r var; do
  [[ -z "${var}" ]] && continue
  # manifest.yml 에 "  VAR_NAME:" 패턴으로 정의됐는지 검사
  if ! grep -qE "^[[:space:]]+${var}:" "${MANIFEST}"; then
    MISSING="${MISSING}${var} "
  fi
done <<< "${USED_VARS}"

if [[ -n "${MISSING}" ]]; then
  fail "manifest.yml 에 미정의 변수: ${MISSING}"
fi

VAR_COUNT="$(echo "${USED_VARS}" | wc -l | tr -d ' ')"
ok "사용 변수 ${VAR_COUNT}개 모두 manifest.yml 에 정의됨"

# ──────────────────────────────────────────────
# 3. install.sh --dry-run 카운트
# ──────────────────────────────────────────────

step 3 "install.sh --dry-run 카운트"

DRY_RUN_COUNT="$(bash "${INSTALL_SH}" --dry-run 2>&1 | grep -c '^  src/' || true)"

if [[ "${DRY_RUN_COUNT}" != "${EXPECTED_DRY_RUN_COUNT}" ]]; then
  fail "dry-run 카운트 ${DRY_RUN_COUNT} ≠ 기대값 ${EXPECTED_DRY_RUN_COUNT}"
fi
ok "복사 대상 ${DRY_RUN_COUNT}개 (명령어 1 + 템플릿 26)"

# ──────────────────────────────────────────────
# 4. 조건 블록 짝
# ──────────────────────────────────────────────

step 4 "조건 블록 {{#if}} ↔ {{/if}} 짝"

OPEN_COUNT="$(grep -roE '\{\{#if' "${TEMPLATES_DIR}/" 2>/dev/null | wc -l | tr -d ' ')"
CLOSE_COUNT="$(grep -roE '\{\{/if\}\}' "${TEMPLATES_DIR}/" 2>/dev/null | wc -l | tr -d ' ')"

if [[ "${OPEN_COUNT}" != "${CLOSE_COUNT}" ]]; then
  fail "조건 블록 짝 불일치: 열림 ${OPEN_COUNT} ≠ 닫힘 ${CLOSE_COUNT}"
fi
ok "조건 블록 ${OPEN_COUNT}/${CLOSE_COUNT} 짝 일치"

# ──────────────────────────────────────────────
# 결과
# ──────────────────────────────────────────────

echo ""
echo "✅ 모든 검증 통과 (4/4)"
