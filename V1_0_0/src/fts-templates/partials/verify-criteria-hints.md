<!-- 이 partial 은 planner.template.md 의 `{{VERIFY_CRITERIA_HINTS}}` 자리에 삽입된다.
     선택된 타입별 힌트만 최종 렌더에 포함된다. -->

각 step 의 verify 는 아래 타입별 힌트를 참고하여 **측정 가능한** 형태로 기술한다.

{{#if includes(types,"coding")}}
### coding

- 명령어(cmd): `{{BUILD_CMDS}}`
{{#if TEST_CMDS}}
- 테스트: `{{TEST_CMDS}}`
{{/if}}
{{#if LINT_CMDS}}
- 린트: `{{LINT_CMDS}}`
{{/if}}
- 체크리스트 예: 에러 0, 경고 차단 기준 0, 신규 API 에 타입 정의 존재
{{/if}}

{{#if includes(types,"research")}}
### research

- 체크리스트 예:
  - 모든 주장에 출처 링크 존재
  - 인용 포맷 `{{CITATION_FORMAT}}` 일관
  - 1 차 자료 N 개 이상
  - 반대 입장 검토 여부
  - 접근일·검색 엔진 기록 존재
{{/if}}

{{#if includes(types,"design")}}
### design

- 체크리스트 예:
  - 각 화면·컴포넌트에 `{{DESIGN_TOOL}}` 링크 연결
  - 에셋 경로 `{{ASSET_PATH}}` 유효
  - WCAG {{WCAG_LEVEL}} 대비비·포커스·대체 텍스트 통과
  - 디자인 토큰 불일치 0
{{/if}}

{{#if includes(types,"writing")}}
### writing

- 체크리스트 예:
{{#if WRITING_LINT_TOOL}}
  - `{{WRITING_LINT_TOOL}}` 검사 통과
{{/if}}
  - 헤딩 계층 순차성
  - 인용·각주·링크 유효성
  - 용어·외래어·약어 표기 일관
  - 섹션별 요지 1 문장 요약 존재
{{/if}}
