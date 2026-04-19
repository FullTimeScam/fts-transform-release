### 코딩 gate (필수)

다음 명령을 순차 실행한다. **하나라도 fail 이면 done 중단.**

{{BUILD_CMDS}}

{{#if TEST_CMDS}}
추가 테스트:

{{TEST_CMDS}}
{{/if}}

{{#if LINT_CMDS}}
린트·포맷:

{{LINT_CMDS}}
{{/if}}

- [ ] 위 명령 전부 exit code 0
- [ ] 경고(warning) 중 차단 기준에 해당하는 것 0 건
- [ ] 환경변수 의존 명령이 CI 에서도 통과
