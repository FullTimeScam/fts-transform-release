---
description: "현재 프로젝트에 맞춤형 fts 워크플로우 파일을 설치·재생성한다"
---

# /fts-transform

모든 출력은 한국어로 작성해라.

## 목표

현재 프로젝트 디렉토리(`$CWD`)에 맞는 fts 워크플로우 파일 일체를 설치하거나 재생성한다.
Q&A 를 통해 프로젝트 타입·스택·제약에 맞는 파일을 생성하며, 재실행 시 이전 설정을 기본값으로 불러온다.

---

## 프로세스

### Step 0: 전제 조건 확인

1. `~/.claude/fts-templates/manifest.yml` 이 존재하는지 Read 툴로 확인해라.
   - 없으면: 아래 메시지를 출력하고 **즉시 종료**해라.
     ```
     오류: ~/.claude/fts-templates/manifest.yml 을 찾을 수 없습니다.
     먼저 설치 스크립트를 실행해라: bash <fts-transform 저장소>/scripts/install.sh
     ```
2. `~/.claude/fts-templates/manifest.yml` 을 읽어 `version` 값을 TEMPLATE_VERSION 으로 기억해라.
3. `TODAY` 를 오늘 날짜(YYYY-MM-DD)로 기억해라.
4. `git_enabled` 를 판정해라. Bash 로 `git -C "$CWD" rev-parse --is-inside-work-tree` 를 실행하여 성공하면 `true`, 실패하면 `false`. 템플릿 조건 블록 `{{#if git_enabled}}` 이 이 값을 참조한다.

---

### Step 1: 모드 판별

`$CWD/.claude/fts.config.yml` 이 존재하는지 확인해라.

**존재하지 않으면** → **install 모드**. Step 2 로 바로 이동.
(`install` 은 사용자가 M1 에서 선택하는 옵션이 아니라 config 부재 시 자동 진입하는 모드다.)

**존재하면** → fts.config.yml 을 읽어 현재 설정 요약을 출력한 뒤, AskUserQuestion 으로 M1 질문을 한다:

```
현재 설정(fts.config.yml)이 발견됐습니다.

프로젝트 타입: {types}
언어: {language}
에이전트 모델: {agent_model}
옵션 명령어: {optional_cmds}

어떻게 처리할까요?
```

옵션:
- `modify` — 항목별 선택 수정 (M2 에서 고른 질문만 재질의, 나머지 config 유지)
- `regenerate` — 모든 Q&A 다시 진행 (현재 config 값이 기본값으로 제시됨). 전체 파일 재렌더.
- `sync` — Q&A 없이 현재 config 로 재렌더. 템플릿 버전 업데이트·수기 편집 복구 목적.
- `cancel` — 중단

`cancel` 이면 즉시 종료.
`sync` 이면 Step 2 를 건너뛰고 Step 3 으로 이동.

**모드 간 차이 요약**:

| 항목 | install | modify | regenerate | sync |
|------|---------|--------|------------|------|
| Q&A 범위 | 전 항목 | M2 선택 항목만 | 전 항목(기존값이 default) | 생략 |
| 설치 대상 파일 | 전체 | 전체 | 전체 | 전체 |
| Step 6 판정 | 공통 적용 | 공통 적용 | 공통 적용 | 공통 적용 |
| 스캐폴드(Step 9) | 생성 | 건너뜀 | 건너뜀 | 건너뜀 |

Step 6 판정 로직(체크섬 일치+본문 동일 → skip / 나머지 → C7 정책)은 **모드와 무관하게 동일**하다. `sync` 의 특이성은 **Q&A 를 건너뛴다**는 점이며, 파일 단위 덮어쓰기 규칙은 다른 모드와 같다.

`modify` 이면 추가 질문(M2):
```
어떤 항목을 바꿀까요? (다중 선택)
```
옵션: `프로젝트 타입`, `언어`, `빌드 gate`, `옵션 명령어`, `에이전트 모델`, `보안 설정`, `기타`

선택된 항목만 Step 2 에서 재질의한다. 나머지는 config 값을 유지.

---

### Step 2: Q&A 루프

아래 질문 목록을 순서대로 진행한다. 각 질문은 `when` 조건을 평가하여 해당하지 않으면 건너뛴다.
`modify` 모드에서는 M2 에서 선택된 항목과 관련된 질문만 진행한다.
기존 config 값이 있으면 AskUserQuestion 의 선택지에 **(현재값: ...)** 를 표시하고 그것을 기본값으로 한다.

모든 질문은 AskUserQuestion 툴을 사용해 순차적으로 (한 번에 하나씩) 물어봐라.

#### 공통 질문

**C1 — 프로젝트 타입** (다중 선택 허용)
```
이 프로젝트는 어떤 성격인가요? (여러 개 선택 가능)
1. coding — 타입체크·빌드·테스트 중심
2. research — 문헌 조사·자료 정리·인용
3. design — UI/UX·에셋 제작
4. writing — 기획서·문서·블로그 등 글쓰기
5. 기타 (직접 입력) — 공통 템플릿만 설치
```
결과를 `types` 배열로 기억 (예: `["coding", "writing"]`).

**C2 — 언어**
```
대화·커밋에 쓸 언어를 선택하세요.
1. 한국어
2. 영어
3. 혼용 (한국어 기본, 코드 식별자는 영어 허용)
4. 기타 (직접 입력)
```
결과를 `LANG` 으로 기억.

**C3 — 프로젝트명** (install 모드 또는 regenerate 모드에서만)
```
프로젝트 이름(slug)을 입력하세요. 예: my-project
```
결과를 `PROJECT_NAME` 으로 기억.

**C4 — Planning 경로** (install 모드 또는 regenerate 모드에서만)
```
planning 파일 저장 디렉토리를 선택하세요.
1. .planning (기본값)
2. 직접 입력
```
결과를 `PLANNING_DIR` 로 기억. 기본값: `.planning`

**C5 — 에이전트 모델**
```
서브에이전트 기본 모델을 선택하세요.
1. inherit — 부모 대화와 동일 (권장)
2. claude-opus-4-7 — Opus
3. claude-sonnet-4-6 — Sonnet
4. claude-haiku-4-5-20251001 — Haiku
5. 기타 (직접 입력 — 모델 ID)
```
결과를 `AGENT_MODEL` 로 기억. 기본값: `inherit`

**C6 — 옵션 명령어** (다중 선택 허용)
```
설치할 옵션 명령어를 선택하세요. (없으면 건너뛰기)
1. fts-verify — plan 품질 10차원 검증
2. fts-security-gate — 보안 게이트 (coding 선택 시에만 표시)
3. 없음
```
결과를 `opts` 배열로 기억.
`coding` 이 types 에 없으면 `fts-security-gate` 선택지를 표시하지 마라.

**C7 — 덮어쓰기 정책** (sync 모드 제외)
```
기존 파일 충돌 시 처리 방식을 선택하세요.
1. 백업(.bak-{타임스탬프}) 후 덮어쓰기 (기본값, 권장)
2. 그냥 덮어쓰기
3. 건너뛰기
4. 기타 (직접 입력)
```
결과를 `overwrite_policy` 로 기억. 기본값: `backup_overwrite`

#### coding 전용 질문 (types 에 coding 포함 시에만)

**D1 — 주 언어**
```
주 언어/런타임을 선택하세요.
1. TypeScript / Node.js
2. Python
3. Rust
4. Go
5. 기타 (직접 입력)
```
결과를 `PRIMARY_LANG` 으로 기억.

**D2 — 빌드 gate** (다중 선택 허용)
```
완료(done) 전 강제 실행할 빌드·타입체크 명령어를 선택하세요.
1. npx tsc --noEmit
2. cargo check
3. go build ./...
4. pytest
5. 기타 (직접 입력)
```
결과를 `BUILD_CMDS` 목록으로 기억 (개행 구분).

**D3 — 린트·포맷**
```
린트·포맷 명령어를 선택하세요. (없으면 '없음')
1. 없음
2. eslint
3. biome
4. ruff
5. rustfmt
6. 기타 (직접 입력)
```
결과를 `LINT_CMDS` 로 기억. `없음` 이면 빈 문자열.

**D4 — 테스트**
```
테스트 명령어를 선택하세요. (없으면 '없음')
1. 없음
2. npm test
3. pytest
4. cargo test
5. 기타 (직접 입력)
```
결과를 `TEST_CMDS` 로 기억.

**D5 — 시크릿 종류** (opts 에 fts-security-gate 포함 시에만, 다중 선택)
```
관리할 시크릿 종류를 선택하세요. (다중 선택)
1. API 키
2. 지갑·seed·keypair
3. RPC URL
4. DB 크리덴셜
5. 기타 (직접 입력)
```
결과를 `SECURITY_ITEMS` 목록으로 기억.

**D6 — 외부 서비스** (opts 에 fts-security-gate 포함 시에만)
```
의존하는 외부 서비스를 쉼표로 나열해 주세요.
예: Solana RPC, Telegram Bot, OpenAI API
(없으면 그냥 엔터)
```
결과를 `EXTERNAL_SERVICES` 로 기억.

#### research 전용 질문 (types 에 research 포함 시에만)

**R2 — 인용 포맷**
```
인용 스타일을 선택하세요.
1. Markdown 각주 ([^1])
2. APA
3. Chicago
4. 기타 (직접 입력)
```
결과를 `CITATION_FORMAT` 으로 기억.

**R3 — 민감 정보**
```
개인정보·내부기밀이 포함되나요?
1. 없음
2. 있음 — 보안 게이트 설치
3. 기타 (부분 민감, 직접 입력)
```
`있음` 이면 opts 에 `fts-security-gate` 추가 (아직 없으면).

#### design 전용 질문 (types 에 design 포함 시에만)

**S1 — 디자인 툴** (다중 선택)
```
주 디자인 툴을 선택하세요.
1. Figma
2. Sketch
3. Adobe Creative Cloud
4. 기타 (직접 입력)
```
결과를 `DESIGN_TOOL` 로 기억 (첫 번째 선택값).

**S2 — 에셋 경로**
```
산출물 저장 경로를 선택하세요.
1. assets/ (기본값)
2. design/
3. 직접 입력
```
결과를 `ASSET_PATH` 로 기억.

**S3 — 접근성 기준**
```
WCAG 준수 레벨을 선택하세요.
1. A
2. AA (권장)
3. AAA
4. 해당없음
5. 기타 (다른 표준)
```
결과를 `WCAG_LEVEL` 로 기억.

#### writing 전용 질문 (types 에 writing 포함 시에만)

**W1 — 문서 종류** (다중 선택)
```
주 산출물 종류를 선택하세요.
1. 블로그/기사
2. 기획서
3. 제안서
4. 기술 문서
5. 기타 (직접 입력)
```
결과를 `DOC_TYPE` 로 기억 (쉼표 구분).

**W2 — 포맷**
```
주 포맷을 선택하세요.
1. Markdown
2. Google Docs / Word
3. Notion
4. 기타
```
결과를 `DOC_FORMAT` 로 기억.

**W3 — 맞춤법 도구**
```
사용할 linting 도구를 선택하세요. (없으면 '없음')
1. 없음
2. textlint
3. vale
4. 기타
```
결과를 `WRITING_LINT_TOOL` 로 기억.

---

### Step 3: 파생 변수 계산

Q&A 응답을 바탕으로 다음 변수를 계산해라:

| 변수 | 계산 규칙 |
|------|-----------|
| `EXECUTION_PHASE_LABEL` | types 에 coding 포함 → `구현` / 아니면 → `실행` |
| `IMPLEMENTER_ROLE_LABEL` | types 에 coding 포함 → `구현자` / 아니면 → `실행자` |
| `RULES_SECURITY_PATH` | (types 에 coding 포함) 또는 (R3 == 있음) → `.claude/rules/03-security.md` / 아니면 → 빈 문자열 |
| `RULES_WORKFLOW_PATH` | 항상 `.claude/rules/02-workflow.md` |
| `PROJECT_TYPES` | types 배열을 쉼표로 연결 (예: `coding, writing`) |
| `RESEARCH_IMPACT_SECTION` | types 기반으로 아래 규칙 적용 |
| `DONE_GATE_BLOCK` | Step 4 에서 조립 |
| `BUILD_TARGETS_TABLE` | types 기반으로 아래 규칙 적용 |
| `STATUS_BUILD_BLOCK` | types 기반으로 아래 규칙 적용 |
| `STATE_BUILD_SECTION` | types 기반으로 아래 규칙 적용 |
| `SYNC_DOC_TARGETS` | 설치될 rules 파일 목록에서 행 생성 |
| `SECURITY_CHECKLIST` | D5·D6 응답 기반 (Step 4 에서 조립) |
| `VERIFY_CRITERIA_HINTS` | Step 4 에서 types 기반 조립 |
| `WAVE_PATTERN_EXAMPLES` | types[0] 기반으로 예시 선택 |
| `EXTERNAL_SERVICES_SECURITY_ROWS` | D6 각 서비스 → `- [ ] {서비스} 자격증명 환경변수 관리` |
| `CHECKSUM` | 렌더 후 sha1 short (파일별로 계산) |
| `git_enabled` | `$CWD` 가 git 워크트리인가. `git rev-parse --is-inside-work-tree` 으로 판정 (true/false). 템플릿 조건 블록 `{{#if git_enabled}}` 에서 사용. |
| `secrets` | D5 응답 배열의 별칭. `security-checklist.md` 의 `{{#if includes(secrets, "...")}}` 조건 처리 전용. Step 4 SECURITY_CHECKLIST 조립 로직이 해석한다. |

**RESEARCH_IMPACT_SECTION 계산:**
- coding → `빌드 타겟 영향 분석 (어떤 모듈·파일이 변경되는가)`
- research → `자료 범위·섹션 영향 분석 (어떤 출처·챕터가 추가·수정되는가)`
- design → `화면·디자인 시스템 영향 분석 (어떤 컴포넌트·화면이 바뀌는가)`
- writing → `챕터·스타일 가이드 영향 분석 (어떤 섹션·표현 기준이 바뀌는가)`
- 복수 타입 → 선택된 타입 순서대로 항목 union (개행 구분)

**BUILD_TARGETS_TABLE 계산:**
- coding → BUILD_CMDS 각 명령어별 `| {cmd} | pass |` 행
- research → `| 인용 검증 | pass |`
- design → `| 접근성 (WCAG_LEVEL) | pass |`
- writing → `| 맞춤법 | pass |`
- 복수 타입 → 모든 행 union

**STATUS_BUILD_BLOCK 계산:**
- coding 포함 → `BUILD_CMDS 각 명령어 실행 → {cmd}: pass/fail 출력`
- coding 미포함 → `진행률: N/M done 기준 충족 · 최근 검증: {criteria}`

**STATE_BUILD_SECTION 계산:**
- coding 포함 → `- Target: {BUILD_CMDS 개행 목록}`
- coding 미포함 → `- 검증 대상: {types}-별 완료 기준 (done-gate 참조)`

**SYNC_DOC_TARGETS 계산:**
설치될 .claude/rules/ 파일 각각에 대해 `| {파일명} | {설명} |` 행 생성.

**WAVE_PATTERN_EXAMPLES 계산:**
- coding → `Wave 1 데이터 모델 → Wave 2 비즈니스 로직 → Wave 3 통합`
- research → `Wave 1 자료 수집 → Wave 2 분석·분류 → Wave 3 합성·보고서`
- design → `Wave 1 와이어프레임 → Wave 2 컴포넌트 → Wave 3 화면 완성`
- writing → `Wave 1 아웃라인 → Wave 2 초안 → Wave 3 편집·교정`
- 복수 타입 → types[0] 기준으로 첫 예시 선택. 나머지 타입은 병행 note 추가.

---

### Step 4: 블록 조립

#### DONE_GATE_BLOCK 조립

선택된 각 타입에 해당하는 partial 파일을 `~/.claude/fts-templates/planning/templates/partials/` 에서 읽어 합친다:
- `done-gate.coding.md` (types 에 coding 포함 시)
- `done-gate.research.md` (types 에 research 포함 시)
- `done-gate.design.md` (types 에 design 포함 시)
- `done-gate.writing.md` (types 에 writing 포함 시)

각 partial 내부의 `{{VAR}}` 도 이미 계산한 변수로 치환.
파일들을 `\n\n` 으로 연결하여 `DONE_GATE_BLOCK` 에 저장.

#### SECURITY_CHECKLIST 조립 (fts-security-gate 설치 시에만)

`~/.claude/fts-templates/partials/security-checklist.md` 를 읽고 다음을 수행:
1. D5 선택 항목별로 체크리스트 행 활성화 (미선택 항목 행은 제거)
2. D6 각 서비스에 대해 `- [ ] {서비스} 자격증명 환경변수 관리` 행 추가
3. 치환 결과를 `SECURITY_CHECKLIST` 에 저장

> **단일 출처 원칙**: 보안 체크리스트는 `rules/03-security.md` 에 있는 `SECURITY_CHECKLIST` 하나만 둔다. fts-security-gate·implementer 등은 `{{RULES_SECURITY_PATH}}` 를 통해 참조만 한다 (결과 테이블·규칙 블록을 별도로 생성하지 않는다).

#### VERIFY_CRITERIA_HINTS 조립

`~/.claude/fts-templates/partials/verify-criteria-hints.md` 를 읽고,
선택된 타입 섹션만 남기고 나머지를 제거. 내부 `{{VAR}}` 치환 후 `VERIFY_CRITERIA_HINTS` 에 저장.

---

### Step 5: 대상 파일 목록 결정

`~/.claude/fts-templates/manifest.yml` 의 `files` 섹션을 읽어, 아래 조건으로 설치 대상을 결정:

| 조건 | 결과 |
|------|------|
| `required: true` | 항상 포함 |
| `requires_types: [X]` | types 에 X 포함 시에만 |
| `requires_options: [X]` | opts 에 X 포함 시에만 |
| `condition: "..."` | 조건식 평가 결과 true 시에만 |

결정된 파일 목록을 내부 배열로 보관.

---

### Step 6: 수기 편집 감지 및 충돌 처리

설치 대상 각 파일에 대해, 먼저 **새로 렌더된 본문** 과 **기존 파일 본문** 을 비교해 처리 분기를 정한다.

1. `$CWD/{dest}` 가 존재하지 않으면 → 신규 생성. Step 7 로.
2. 존재하면 파일 상단 2줄을 읽어 `AUTO-GENERATED` 주석이 있는지 확인.
   - 없으면 → 사용자에게 경고: "이 파일은 fts-transform 이 생성하지 않은 파일입니다. 덮어쓰시겠어요?" 응답에 따라 처리. 진행 시 C7 정책 적용.
3. 있으면 헤더의 `sha1:` 값을 현재 파일 본문(헤더 주석 제외)의 sha1 와 비교.
   - **체크섬 일치** → 파일이 수기 편집되지 않은 정상 상태. 새 렌더 결과와 기존 본문을 비교:
     - 동일 → **skip** (백업 생성하지 않음. 결과 요약에 "변경 없음" 으로 집계).
     - 다름 → 템플릿·변수 변경으로 인한 업데이트. C7 정책 적용.
   - **체크섬 불일치** → 수기 편집됨. 사용자에게 경고 후 C7 정책 적용.

C7 정책 적용:
- `backup_overwrite`: `$CWD/{dest}.bak-{YYYYMMDDHHMMSS}` 로 복사 후 덮어쓰기
- `overwrite`: 바로 덮어쓰기
- `skip`: 해당 파일 건너뛰기 (재생성 목록에서 제외)

> **중요**: Step 6 의 모든 단계는 `fts.config.yml` 에 적용하지 마라. config 파일은 Step 8 이 단독으로 관리한다 (설치 대상 목록 및 수기 편집 감지 대상에서 제외).

---

### Step 7: 파일 생성

설치 대상 파일 각각에 대해:

1. `~/.claude/fts-templates/{src}` 를 Read 툴로 읽어라.
2. **변수 치환**: 파일 내 모든 `{{VAR_NAME}}` 을 계산된 변수값으로 치환.
3. **조건 블록 해석**: 아래 규칙으로 처리.

#### 조건 블록 처리 규칙

```
{{#if <조건>}}
  ... (조건 true 시 유지)
{{else}}
  ... (조건 false 시 유지)
{{/if}}
```

지원하는 조건 형태:
- `includes(types, "coding")` — types 배열에 "coding" 포함 여부
- `includes(opts, "fts-security-gate")` — opts 에 해당 옵션 포함 여부
- `not includes(...)` — 위 조건의 부정
- `VAR == "value"` — 변수 값 비교 (`LANG == "혼용"` 등)
- `VAR` (단독) — **truthy check**. 변수가 정의돼 있고 빈 문자열이 아니면 true. `{{#if LINT_CMDS}}`, `{{#if EXTERNAL_SERVICES}}` 등. `git_enabled` 같은 불리언 런타임 변수도 이 형태로 사용.

> `{{#if includes(secrets, ...)}}` 조건은 `security-checklist.md` partial 전용. Step 4 SECURITY_CHECKLIST 조립 로직이 D5 응답 배열을 보고 해석하므로 Step 7 일반 처리기를 거치지 않도록 Step 4 에서 **이 partial 의 조건 블록을 먼저 해결** 한 뒤 최종 문자열을 `SECURITY_CHECKLIST` 변수에 저장한다.

처리 방법:
1. `{{#if ...}}` ~ `{{/if}}` 블록을 찾는다 (중첩 없음, 1단계만).
2. `{{else}}` 가 있으면 then 블록과 else 블록으로 분리.
3. 조건이 true 이면 then 블록만 남기고 `{{#if...}}`, `{{else}}`, `{{/if}}` 마커를 제거.
4. 조건이 false 이면 else 블록(있으면)만 남기고, 없으면 블록 전체 제거.

4. **CHECKSUM 계산**: 치환·조건처리 완료된 본문(헤더 주석 제외)의 sha1 7자리.
5. 헤더 주석 내 `{{CHECKSUM}}` 을 실제 체크섬으로 교체.
6. `$CWD/{dest}` 경로에 Write 툴로 저장. 부모 디렉토리가 없으면 먼저 생성.

**검증**: 파일 저장 후 해당 파일을 Read 로 읽어 `{{` 가 남아 있지 않은지 확인.
남아 있으면 오류 목록에 추가.

---

### Step 8: fts.config.yml 저장

`$CWD/.claude/fts.config.yml` 에 현재 Q&A 응답을 저장한다. Step 6 수기 편집 감지 로직을 적용하지 않고 **항상 직접 덮어쓴다** (config 는 AUTO-GENERATED 헤더·체크섬을 갖지 않는다). 기존 파일 백업도 만들지 않는다 — 변경 이력이 필요하면 git 을 사용하라.

```yaml
# fts-transform config — 재실행 시 이 파일을 default 로 사용.
# /fts-transform 을 재실행하면 수동 수정 없이 설정을 변경할 수 있다.
generated_at: "{TODAY}"
template_version: "{TEMPLATE_VERSION}"

types: [{types 배열}]
language: "{LANG}"
project_name: "{PROJECT_NAME}"
planning_dir: "{PLANNING_DIR}"
agent_model: "{AGENT_MODEL}"
optional_cmds: [{opts 배열}]
overwrite_policy: "{overwrite_policy}"

# coding 전용 (해당 시)
primary_lang: "{PRIMARY_LANG}"
build_cmds:
{BUILD_CMDS 각 줄을 "  - {cmd}" 형식}
lint_cmds: "{LINT_CMDS}"
test_cmds: "{TEST_CMDS}"

# security 전용 (해당 시)
security_items: [{SECURITY_ITEMS}]
external_services: "{EXTERNAL_SERVICES}"

# research 전용 (해당 시)
citation_format: "{CITATION_FORMAT}"

# design 전용 (해당 시)
design_tool: "{DESIGN_TOOL}"
asset_path: "{ASSET_PATH}"
wcag_level: "{WCAG_LEVEL}"

# writing 전용 (해당 시)
doc_type: [{DOC_TYPE}]
doc_format: "{DOC_FORMAT}"
writing_lint_tool: "{WRITING_LINT_TOOL}"
```

해당하지 않는 섹션은 파일에서 제외.

---

### Step 9: 디렉토리 스캐폴드 (install 모드에서만)

아래 디렉토리를 생성해라 (이미 존재하면 건너뜀):
- `$CWD/.planning/current/`
- `$CWD/.planning/archive/`
- `$CWD/.claude/commands/`
- `$CWD/.claude/rules/`
- `$CWD/.claude/agents/`

---

### Step 10: 요약 출력

다음 형식으로 결과를 출력해라:

```
✅ fts-transform 완료

모드: {install | modify | regenerate | sync}
타입: {types}

변경 요약: 신규 {N_new} · 갱신 {N_updated} · 변경 없음 {N_unchanged} · 건너뜀 {N_skipped} · 백업 {N_backed_up}

생성·갱신된 파일:
- .claude/commands/fts-start.md
- ... (신규 + 갱신 파일 목록)

건너뛴 파일: (있으면)
- ...

백업된 파일: (있으면)
- ...

오류: (있으면 목록 표시)

---
다음 단계:
```

**install 모드이면:**
```
초기 설치 완료. /fts-start "첫 번째 태스크 이름" 으로 첫 태스크를 시작하세요.
```

**modify 모드이면:**
```
선택한 항목을 반영해 파일 {N_updated}개가 갱신되었습니다.
```

**regenerate 모드이면:**
```
Q&A 를 다시 진행해 파일 {N_updated}개가 재생성되었습니다.
```

**sync 모드이면:**
```
Q&A 를 건너뛰고 템플릿 v{TEMPLATE_VERSION} 변경분을 반영했습니다 (갱신 {N_updated} · 변경 없음 {N_unchanged}).
```

오류가 하나라도 있으면 마지막에 경고를 표시하고, 오류 파일은 수동 확인을 안내해라.
