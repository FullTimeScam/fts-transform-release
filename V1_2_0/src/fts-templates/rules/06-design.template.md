---
description: "design 타입 프로젝트 규칙 (툴·에셋·접근성)"
---

<!-- AUTO-GENERATED v{{TEMPLATE_VERSION}} {{TODAY}} sha1:{{CHECKSUM}} — /fts-transform to regenerate -->

# 디자인 규칙

이 파일은 프로젝트 타입에 `design` 이 포함된 경우에만 설치된다.

## 주 디자인 툴

- **{{DESIGN_TOOL}}**

동일 산출물을 서로 다른 툴에 중복 유지하지 마라. 원본 1 개 + 내보내기 에셋 구조를 따라라.

## 산출물 배치

| 종류 | 폴더 | 비고 |
|------|------|------|
| 디자인 원본 (`.fig`·`.sketch` 등) | `{{ASSET_PATH}}/source/` | 1 개 툴만 유지 |
| 내보내기 (PNG·SVG) | `{{ASSET_PATH}}/export/` | 화면별 하위 폴더 |
| 작업 중 파일 | `{{ASSET_PATH}}/_wip/` | 격리 보관, 완료 후 정리 |

경로 패턴 예: `{{ASSET_PATH}}/source/{screen-name}/v1.fig` · `{{ASSET_PATH}}/export/{screen-name}/v1.png`
`{{PLANNING_DIR}}/current/{task-id}/` 에는 메타 4종(research/context/plan/summary) 외 에셋·디자인 파일을 두지 마라. plan.md 의 각 step 은 위 매핑 폴더 중 하나를 `출력 경로` 로 지정해야 한다.

## 네이밍 규칙

- 화면·컴포넌트: kebab-case. 버전은 `v{n}` 접미사만 (날짜·사용자명 금지).
- 작업 중 파일은 `_wip` 접미사 또는 별도 디렉토리에 격리.

## 접근성

- 목표 준수 레벨: **WCAG {{WCAG_LEVEL}}**
- 모든 화면에 대해 다음을 검토해라:
  - [ ] 대비비 (텍스트·아이콘)
  - [ ] 키보드 포커스 순서·인디케이터
  - [ ] 아이콘·이미지의 대체 텍스트
  - [ ] 터치 타겟 최소 크기

## 완료 기준

각 태스크 완료 전에 다음을 확인해라:

- [ ] 모든 화면·컴포넌트에 외부 링크(`{{DESIGN_TOOL}}`) 가 연결됨
- [ ] 에셋 경로(`{{ASSET_PATH}}`) 가 유효하고 누락된 파일이 없음
- [ ] WCAG {{WCAG_LEVEL}} 기준 접근성 체크 완료
- [ ] 디자인 시스템 토큰(색·타이포·간격) 과 불일치 없음
- [ ] 다크 모드 또는 반응형 변형이 요구되면 함께 제공됨

## 최소 변경 원칙

- 요청된 화면·컴포넌트 외 임의 수정 금지. 디자인 시스템 토큰 변경은 별도 태스크.
- 요청받지 않은 "스타일 개선·정리" 금지.
