# Changelog

이 프로젝트의 모든 주목할 변경은 이 파일에 기록된다.

형식은 [Keep a Changelog](https://keepachangelog.com/ko/1.1.0/) 를 따르고, [Semantic Versioning](https://semver.org/lang/ko/) 을 준수한다.

`version` 의 출처는 [src/fts-templates/manifest.yml](src/fts-templates/manifest.yml) 의 `version` 필드. 이 값은 모든 템플릿의 `AUTO-GENERATED` 헤더에 `{{TEMPLATE_VERSION}}` 으로 자동 주입된다.

---

## [1.1.0] - 2026-05-10

릴리즈 직전 전수 점검에서 발견한 문서·검증 인프라 갭을 메우고, 누적된 토큰 압축·설계 결함 수정 결과를 정식 버전으로 묶었다.

### Added
- `CHANGELOG.md` — Keep-a-Changelog 형식 변경 이력. 사용자가 버전 간 차이를 한 곳에서 추적 가능.
- `scripts/validate.sh` — 4단계 무결성 자동 검증 스크립트. 하드코딩 누출, 변수↔manifest 정합성, dry-run 카운트(=27), 조건 블록 짝을 한 줄로 점검.
- `README.md` 상단 현재 버전 배지 (CHANGELOG 링크 포함).
- `CLAUDE.md` 검증 명령 섹션에 통합 검증 (`bash scripts/validate.sh`) 진입점.

### Changed
- 토큰·컨텍스트 압축 (-127줄 / 약 -3.8K 토큰) — 2026-05-09 작업 반영. 자동 로드 rules 7개, commands 6개, agents·partials 정리. 사용자 가시 동작 변화 없음, 컨텍스트 사용량만 감소.

### Fixed
- 설계 결함 8건 (E1·E2·E3·E5·E6·E7·E4 follow-up + 부수 2건) — 2026-04-19 Wave 5·6 작업 반영. 주요 수정 위치:
  - `src/commands/fts-transform.md` — install vs sync 모드 차이표 명확화, 변경 요약 라인 추가, install 자동 진입 분기 주석 보강
  - `src/fts-templates/manifest.yml` — 변수 정합성 보정
  - `src/fts-templates/rules/01-language.template.md` — LANG 조건부 처리 정정

### Verified
- 하드코딩 누출 0건 (`src/fts-templates/**`).
- 변수↔manifest 정합성: 사용된 모든 `{{VAR}}` 가 `manifest.yml` 의 `variables:` 에 정의됨. dead variable 없음.
- 조건 블록 `{{#if}}/{{/if}}` 짝 일치, 1단계 중첩 이내, `{{#each}}`/`{{#unless}}` 미사용.
- `bash scripts/install.sh --dry-run` → 27개 (명령어 1 + 템플릿 26) 유지.
- 에이전트 4종(verifier 포함)·partials 3종 모두 실제 참조됨.

---

## [1.0.0] - 2026-04-19

`/fts-transform` 글로벌 명령어와 `fts-templates/` 뱅크의 첫 정식 릴리즈.

### Added
- 글로벌 명령어 `/fts-transform` (소스: `src/commands/fts-transform.md`)
  - 4분류 타입 지원 (코딩 / 리서치 / 디자인 / 플래닝·글쓰기, 다중 선택 가능)
  - Q&A 기반 맞춤 생성 — 타입·스택·제약을 순수 질문으로 받아 프로젝트별 fts 파일 일체 생성
  - 4모드 (install / modify / regenerate / sync) — 한 명령어로 초기 설치·부분 수정·전면 재생성·템플릿 동기화 모두 처리
- 변수화된 템플릿 뱅크 (`src/fts-templates/`)
  - `manifest.yml` — 질문 24개·변수 42개·파일 19개·조건블록 정의
  - `{{VAR}}` 치환 + `{{#if includes(types, "...")}} ... {{/if}}` 조건 블록 (1단계 중첩, `each`/`unless` 미지원)
  - 템플릿 파일 26개: commands 6 + rules 7 + agents 4 + planning 1 + partials 2 + planning/templates 6
- 안전 배포 스크립트 `scripts/install.sh`
  - `~/.claude/` 외부 쓰기 차단, `.bak-{TIMESTAMP}` 백업 정책, `set -euo pipefail`, `--dry-run` 지원
- 문서: `README.md`, `CLAUDE.md`, `사용 설명서.md`, `examples/` (coding · research · writing · mixed-coding-writing 4 시나리오)
- 모든 템플릿에 `<!-- AUTO-GENERATED v{{TEMPLATE_VERSION}} {{TODAY}} sha1:{{CHECKSUM}} -->` 헤더로 사용자 수정 감지

### Verified
- E2E 9 시나리오 렌더 검증 통과
- 설계 결함 6건 + 부수 2건 발견·수정 (Wave 5·6)
- 4타입 조합 시뮬: 잔존 `{{...}}` 마커 0, if/endif 64/64

[1.1.0]: https://github.com/FullTimeScam/fts-transform/releases/tag/v1.1.0
[1.0.0]: https://github.com/FullTimeScam/fts-transform/releases/tag/v1.0.0
