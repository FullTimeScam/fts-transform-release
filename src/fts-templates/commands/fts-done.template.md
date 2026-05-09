---
description: "현재 태스크를 완료하고 아카이브한다"
---

<!-- AUTO-GENERATED v{{TEMPLATE_VERSION}} {{TODAY}} sha1:{{CHECKSUM}} — /fts-transform to regenerate -->

# /fts:done

## 목표

현재 태스크를 완료 처리하고, 결과를 기록하고, 아카이브한다.

## 프로세스

### 1. 완료 게이트 확인

{{DONE_GATE_BLOCK}}

**하나라도 미충족이면 완료 처리를 중단하고 내용을 보고해라.**

{{#if includes(opts,"fts-security-gate")}}
### 2. 보안 체크리스트

`{{PLANNING_DIR}}/STATE.md` 의 보안 점검 상태 확인. 미체크 항목은 `{{RULES_SECURITY_PATH}}` 로 점검 — 문제 없으면 체크, 있으면 완료 중단·보고.
{{/if}}

### 3. Summary 생성

`{{PLANNING_DIR}}/current/{task-id}/summary.md` 작성:

```
# Task Summary: {task-id}

> 완료일: {date}

## 작업 내용
{무엇을 했는지 {{LANG}}로 요약}

## 수정·생성·검토한 산출물
{STATE.md 에서 가져온 목록}

## 완료 게이트 결과
{{BUILD_TARGETS_TABLE}}

{{#if includes(opts,"fts-security-gate")}}
## 보안 점검
- [x] 모든 항목 통과
{{/if}}

## 비고
{특이사항, 향후 작업 제안 등}
```

### 4. 아카이브

- `{{PLANNING_DIR}}/current/{task-id}/` → `{{PLANNING_DIR}}/archive/` 이동
- STATE.md 세션 히스토리에 완료 기록 추가, 현재 작업(Task ID, Phase) `---` 로 초기화

### 5. 문서 전반 동기화 (필수)

서브에이전트로 모든 프로젝트 문서가 현재 상태와 일치하는지 점검·수정.

#### 5a. 현재 상태 수집

{{#if git_enabled}}
1. `git diff --name-only HEAD~{태스크 커밋 수}..HEAD` 로 변경 파일 목록 파악
{{else}}
1. `{{PLANNING_DIR}}/current/{task-id}/summary.md` 의 "수정·생성·검토한 산출물" 참조
{{/if}}
2. 현재 디렉토리 구조 파악
{{#if includes(types,"coding")}}
3. 현재 빌드 명령어·환경변수·외부 서비스 목록 파악
{{/if}}

#### 5b. 문서별 동기화 점검·수정

각 문서를 읽고 현재 상태와 불일치 부분을 직접 수정:

{{SYNC_DOC_TARGETS}}

#### 5c. 동기화 결과 보고

수정한 내용을 사용자에게 요약 보고:

```
## 문서 동기화 결과
| 문서 | 상태 | 변경 내용 |
|------|------|----------|
| CLAUDE.md | 수정됨 | {변경 요약} |
...
```

{{#if git_enabled}}
**수정이 있으면 별도 커밋**해라: `문서 동기화: {task-id} 완료 반영`
{{/if}}
