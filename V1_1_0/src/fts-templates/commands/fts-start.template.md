---
description: "새 태스크를 시작하고 research/plan을 생성한다"
---

<!-- AUTO-GENERATED v{{TEMPLATE_VERSION}} {{TODAY}} sha1:{{CHECKSUM}} — /fts-transform to regenerate -->

# /fts:start $ARGUMENTS

## 목표

새로운 태스크를 시작하고, 연구 → 계획 → 검증까지 완료한다.

## 프로세스

### 1. 태스크 초기화

- Task ID 생성: `YYYYMMDD-{짧은-kebab-이름}` (오늘 날짜 + 작업 요약)
- `{{PLANNING_DIR}}/current/{task-id}/` 디렉토리 생성
- `{{PLANNING_DIR}}/STATE.md` 업데이트: 현재 브랜치, Task ID, Phase 를 `research` 로 설정

### 2. 연구 (Research)

서브에이전트 `researcher` 스폰. 절차는 `.claude/rules/02-workflow.md` Phase 2 참조.

출력 파일: `{{PLANNING_DIR}}/current/{task-id}/research.md`
- 관련 문서 목록 (경로 + 한 줄 요약)
- 영향 받는 파일·산출물 목록 (경로 + 수정·검토 이유)
- 발견된 제약 조건
- {{RESEARCH_IMPACT_SECTION}}

### 3. 컨텍스트 수집 (Context)

서브에이전트 스폰. 출력 파일: `{{PLANNING_DIR}}/current/{task-id}/context.md`
- 핵심 스니펫·인용
- 기존 패턴
- 의존성·참조 맵

### 4. 계획 수립 (Plan)

research.md + context.md 기반으로 `{{PLANNING_DIR}}/templates/task-plan.md` 를 참고하여 plan.md 생성.

핵심 규칙:
- step 자체 완결성, wave 내 병렬·wave 간 의존성
{{#if includes(opts,"fts-security-gate")}}
- 보안 관련 변경 step 은 보안 검토 포함
{{/if}}
{{#if includes(types,"coding")}}
- verify 는 실제 빌드 명령어 (상세 `.claude/rules/04-coding.md`)
{{else}}
- verify 는 명령어 또는 측정 가능 체크리스트 (예: 출처 링크 존재, Figma 링크, 맞춤법 통과)
{{/if}}

출력 파일: `{{PLANNING_DIR}}/current/{task-id}/plan.md`

### 5. 계획 검증

plan.md 를 다시 읽고 검증 — 자체 완결성, verify 기준 명확성, {{#if includes(opts,"fts-security-gate")}}보안 검토 포함, {{/if}}wave 의존성. 문제 있으면 수정 후 재검증.

### 6. STATE.md 업데이트

Phase 를 `planning` 에서 `{{EXECUTION_PHASE_LABEL}}` 으로 변경.
사용자에게 plan.md 요약을 보여주고 승인을 받아라.

{{#if includes(opts,"fts-security-gate")}}
### 7. 보안 게이트

`{{RULES_SECURITY_PATH}}` 기준으로 plan 을 점검.
STATE.md 의 보안 점검 상태를 업데이트.
{{/if}}
