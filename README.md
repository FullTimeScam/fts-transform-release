# fts-transform
## **find, track, ship**

`/fts-transform` 은 Claude Code 환경에서 프로젝트 워크플로우를 자동 설정하는 글로벌 슬래시 명령어다. 아래 3단계로 설치·사용이 완료된다.

## **문제와 해법**
— Claude Code 로 작업할 때마다 조사·계획·승인·검증을 매번 프롬프트로 강제하는 건 비효율적이다. `fts-transform` 은 프로젝트에 맞춘 슬래시 명령어 세트를 한 번 설치해, 이후 `/fts-start` 하나로 "조사 → 계획 → 승인 → 구현 → 검증" 루프가 자동으로 돌게 만든다.

## **배경**
— 코딩 전용 워크플로우였던 `gsd` 를 참고해 만들었다. 여기서는 이를 코딩을 넘어 research·design·writing 까지 확장해, 타입별로 템플릿·게이트·에이전트가 다르게 조립된다.

---

## 1. 설치 (1회)

```bash
git clone https://github.com/FullTimeScam/fts-transform-release.git
cd fts-transform-release
bash scripts/install.sh
```

Claude Code 를 재시작하면 `/fts-transform` 이 슬래시 명령어로 등록된다.

> 사전 요건: Claude Code 1회 이상 실행(`~/.claude/` 존재), `git`·`bash`.

---

## 2. 초기화 및 설정

대상 프로젝트 루트에서 Claude Code 를 열고:

```
/fts-transform
```

Q&A 가 진행된다. 핵심 응답 항목만 기재한다.

- **프로젝트 타입** — `coding` / `research` / `design` / `writing` 중 **다중 선택**
- **언어** — 한국어 / 영어 / 혼용
- **옵션 명령어** — `fts-verify` (plan 검증), `fts-security-gate` (코딩 전용)
- 타입별 추가 질문(빌드 명령, 인용 포맷, 디자인 툴, 문서 포맷 등)은 선택된 타입에 해당하는 것만 노출된다

완료 시 `.claude/` 와 `.planning/` 이 해당 타입에 맞춰 생성된다.

---

## 3. 운영

| 목적 | 명령어 |
|------|--------|
| 새 태스크 개시 (research → plan → 승인 → 구현) | `/fts-start "<title>"` |
| 현재 상태 조회 | `/fts-status` |
| 세션 중단 후 복귀 | `/fts-resume` |
| 태스크 종결 (gate 검증·summary·archive) | `/fts-done` |
| plan 품질 검증 (옵션) | `/fts-verify` |

---

## 재실행

설정을 바꾸거나 템플릿을 최신화할 때 같은 프로젝트에서 `/fts-transform` 을 다시 호출한다.

| 모드 | 용도 |
|------|------|
| `modify` | 일부 응답만 수정 (예: 타입 추가) |
| `regenerate` | 전 항목 Q&A 재진행 |
| `sync` | Q&A 생략, 템플릿 업데이트만 반영 |

수기 편집 파일은 `.bak-{타임스탬프}` 로 자동 백업된다.

---

## 제거

```bash
rm ~/.claude/commands/fts-transform.md
rm -rf ~/.claude/fts-templates
```
