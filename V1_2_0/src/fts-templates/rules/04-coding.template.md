---
description: "coding 타입 프로젝트 규칙 (빌드·테스트·린트)"
---

<!-- AUTO-GENERATED v{{TEMPLATE_VERSION}} {{TODAY}} sha1:{{CHECKSUM}} — /fts-transform to regenerate -->

# 코딩 규칙

이 파일은 프로젝트 타입에 `coding` 이 포함된 경우에만 설치된다.

## 주 언어·런타임

- **{{PRIMARY_LANG}}**

## 빌드·타입체크

다음 명령은 플랜의 verify·done 단계에서 반드시 통과해야 한다:

{{BUILD_CMDS}}

- 에러 메시지를 먼저 정확히 읽어라. 같은 수정을 2 번 이상 반복하지 말고 다른 접근으로.
- 수정 후 반드시 위 명령을 다시 실행하여 검증해라.

## 테스트

{{#if TEST_CMDS}}
{{TEST_CMDS}}
{{else}}
테스트 명령이 등록되지 않았다. 테스트를 추가할 때는 `/fts-transform` 을 재실행하여 등록해라.
{{/if}}

## 린트·포맷

{{#if LINT_CMDS}}
{{LINT_CMDS}}
{{else}}
린트·포맷 명령이 등록되지 않았다. 추가할 때는 `/fts-transform` 을 재실행해라.
{{/if}}

## 조사 원칙

- 복잡한 조사는 서브에이전트(별도 컨텍스트). 간단한 Grep·Glob·Read 는 직접.
- 열지 않은 코드에 추측 금지. 언급된 파일은 먼저 읽어라.

## 산출물 배치

| 종류 | 폴더 |
|------|------|
| 코드 | `{{SRC_PATH}}` |
| 테스트 | `{{TESTS_PATH}}` |
| 일회성·운영 스크립트 | `{{SCRIPTS_PATH}}` |
| 문서 | `{{DOCS_PATH}}` |

`{{PLANNING_DIR}}/current/{task-id}/` 에는 메타 4종(research/context/plan/summary) 외의 코드 파일을 두지 마라. plan.md 의 각 step 은 위 매핑 폴더 중 하나를 `출력 경로` 로 지정해야 한다.

## 최소 변경 원칙

- 직접 요청·명확 필요인 변경만. 주변 정리·미추가 코드 docstring·타입 추가 금지.
- 발생할 수 없는 시나리오의 에러 핸들링·일회성 작업의 헬퍼·추상화 금지.
- 요청받지 않은 리팩토링·"개선" 금지.
