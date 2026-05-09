<!-- 이 partial 은 /fts-transform 이 fts-security-gate.template.md 와 03-security.template.md 의
     `{{SECURITY_CHECKLIST}}` 자리에 삽입한다. D5(시크릿 종류) + D6(외부 서비스) 응답에서 행이 파생된다. -->

### 공통 항목

- [ ] 시크릿·키·토큰이 코드·커밋·산출물에 하드코딩되지 않음
- [ ] `.env` 및 키 파일(`*.keypair`, `*.wallet`, `secrets/*`) 이 공유·커밋 대상에 포함되지 않음
- [ ] 로깅·에러 메시지에 시크릿이 출력되지 않음
- [ ] 외부 서비스 자격증명은 모두 환경변수로 관리

### 시크릿 종류 (D5 에서 선택된 항목별 1 행)

{{#if includes(secrets,"api-key")}}
- [ ] API 키: 환경변수 관리 + 로테이션 정책 명시
{{/if}}
{{#if includes(secrets,"wallet-seed")}}
- [ ] 지갑·seed·keypair: 저장소 외부에 보관, 접근 로그 확인
{{/if}}
{{#if includes(secrets,"rpc-url")}}
- [ ] RPC URL: 환경변수 관리, 레이트 리밋·인증 헤더 포함 여부 확인
{{/if}}
{{#if includes(secrets,"db-credentials")}}
- [ ] DB 자격증명: 환경변수 관리, 최소권한 계정 사용
{{/if}}
{{#if includes(secrets,"other")}}
- [ ] 기타 시크릿({{SECRETS_OTHER}}): 저장 방식·접근 범위 문서화
{{/if}}

### 외부 서비스 (D6 응답 각 항목별 1 행)

{{EXTERNAL_SERVICES_SECURITY_ROWS}}
