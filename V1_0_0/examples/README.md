# examples

`/fts-transform` 을 4가지 대표 시나리오로 실행했을 때의 산출물 스냅샷.

각 디렉토리는 두 파일로 구성:

- `fts.config.yml` — Q&A 응답이 저장되는 형태 (재실행 시 default 로 사용됨)
- `rendered-fts-done.md` — 가장 구별되는 렌더 결과. `fts-done.template.md` 를 해당 config 로 렌더한 결과

## 비교표

| 시나리오 | 타입 | fts-done gate | security-gate | 빌드 명령 |
|----------|------|---------------|---------------|-----------|
| [coding](./coding/) | `[coding]` | TypeScript 빌드 | 설치 | `npx tsc --noEmit`, `npm test` |
| [writing](./writing/) | `[writing]` | 맞춤법·헤딩·링크 체크리스트 | 미설치 | 없음 |
| [mixed-coding-writing](./mixed-coding-writing/) | `[coding, writing]` | Python 빌드 **+** 맞춤법 | 설치 | `pytest` |
| [research](./research/) | `[research]` | 인용·출처·요약 체크리스트 | 미설치 | 없음 |

## 읽는 법

- 이 예시는 **실제 `/fts-transform` 실행 결과와 바이트 단위 동일** 하지 않을 수 있다. `{{TEMPLATE_VERSION}}`, `{{CHECKSUM}}`, `{{TODAY}}` 같은 런타임 변수가 실행 시점에 결정되기 때문.
- 구조·섹션 구성·조건 블록 적용 결과를 비교하는 용도로 사용.
- 템플릿을 수정할 때 이 스냅샷과 실제 렌더 결과를 diff 해 회귀를 검증할 수 있다.
