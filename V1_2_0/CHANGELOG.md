# Changelog

이 프로젝트의 모든 주목할 변경은 이 파일에 기록된다.

형식은 [Keep a Changelog](https://keepachangelog.com/ko/1.1.0/) 를 따르고, [Semantic Versioning](https://semver.org/lang/ko/) 을 준수한다.

`version` 의 출처는 [src/fts-templates/manifest.yml](src/fts-templates/manifest.yml) 의 `version` 필드. 이 값은 모든 템플릿의 `AUTO-GENERATED` 헤더에 `{{TEMPLATE_VERSION}}` 으로 자동 주입된다.

---

## [1.2.0] - 2026-05-10

작업 산출물(코드·문서·스크립트·에셋·리서치 결과물)이 작업 메타 폴더(`.planning/current/{task-id}/`)에 머무르거나 임의 위치에 흩어지지 않도록, 프로젝트 타입별 표준 폴더 매핑을 룰·템플릿 차원에서 명시했다.

### Added
- `manifest.yml` 변수 6종:
  - `{{SRC_PATH}}` (default `src/`) · `{{TESTS_PATH}}` (`tests/`) · `{{SCRIPTS_PATH}}` (`scripts/`) · `{{DOCS_PATH}}` (`docs/`) · `{{RESEARCH_OUTPUT_PATH}}` (`research/`) — 타입별 산출물 경로
  - `{{ARTIFACT_FOLDERS_TABLE}}` (derived) — 선택된 타입의 폴더 매핑 표를 task-plan에 union으로 렌더
- 도메인 룰 4개에 "## 산출물 배치" 섹션 추가:
  - `04-coding.template.md` — 코드/테스트/스크립트/문서 매핑
  - `05-research.template.md` — 리서치 결과물 (raw/processed 분리) + writing 동시 선택 시 docs 행
  - `06-design.template.md` — 기존 "에셋 경로" 섹션을 source/export/_wip 매핑으로 확장
  - `07-writing.template.md` — 본 문서 + research 동시 선택 시 리서치 메모 행
- `task-plan.template.md`: "산출물 폴더 매핑" 섹션 + step 양식의 `**출력 경로**` 필수 필드. 4개 예시 step 갱신.
- `planner.template.md`: 입력에 도메인 룰 "산출물 배치" 참조 추가, 필수 포함 규칙에 "step의 출력 경로 검증" 항목 추가.
- 본 저장소 신규: `.claude/rules/07-artifacts.md` — 메타 프로젝트 폴더 매핑 가이드 (배포 템플릿 미포함).

### Changed
- `02-workflow.template.md` (배포) + `.claude/rules/05-workflow.md` (본 저장소) Phase 3에 "산출물은 도메인 룰의 '산출물 배치' 섹션에 정의된 폴더로만 생성한다" 한 줄 추가.

### Verified
- `bash scripts/validate.sh` 4/4 통과 (변수 41/41, 조건블록 66/66, dry-run 27, 하드코딩 0)
- 기존 `{{ASSET_PATH}}` 의미·기본값·참조 위치 유지

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

[1.2.0]: https://github.com/FullTimeScam/fts-transform/releases/tag/v1.2.0
[1.1.0]: https://github.com/FullTimeScam/fts-transform/releases/tag/v1.1.0
[1.0.0]: https://github.com/FullTimeScam/fts-transform/releases/tag/v1.0.0
