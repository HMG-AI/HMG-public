# 자주 묻는 질문

## 일반

### HMG란 무엇인가요？

HMG（Holographic Memory Graph）는 AI 에이전트를 위한 영구 기억 시스템입니다. 구조화된 기억 저장, 지능형 리콜, 수정 추적, 거버넌스 기능을 제공합니다 — 로컬 서비스로 실행되며 MCP 프로토콜을 통해 에이전트와 통합됩니다.

### AI 에이전트에 영구 기억이 필요한 이유는？

기억이 없는 에이전트는 매 세션마다 모든 것을 잊습니다. 같은 실수를 반복하고, 이전 아키텍처 결정을 잊으며, 프로젝트 간 일관성을 유지할 수 없습니다. HMG는 에이전트에게 시간이 지남에 따라 개선되는 영구적인 "작업 기억"을 제공합니다.

### HMG는 안전한가요？

네. Community Edition은：
- **아웃바운드 네트워크 연결 제로** — 데이터가 머신을 떠나지 않음
- `localhost`에 바인딩 — 네트워크에 노출되지 않음
- 사용자 전용 권한의 파일 스토리지 사용
- 원격 측정이나 분석 없음

자세한 내용은 [보안](security.md)을 참조하세요.

### 어떤 플랫폼을 지원하나요？

- Linux（x86_64, ARM64）
- macOS（Intel, Apple Silicon）
- Windows（WSL 또는 GNU 툴체인 통해）

## 설치 및 설정

### 설치 방법은？

```bash
curl -fsSL https://github.com/HMG-AI/HMG-public/releases/latest/download/install.sh | sh
```

자세한 내용은 [빠른 시작](getting-started.md)을 참조하세요.

### 에이전트를 연결하려면？

```bash
hmg init --agent cursor    # Cursor
hmg init --agent codex     # Claude Code / Codex
hmg init --agent pi        # Pi
hmg init --agent windsurf  # Windsurf
hmg init --agent aider     # Aider
```

### 스토리지 위치를 커스터마이즈할 수 있나요？

네. `HMG_STORE_PATH` 환경 변수를 설정하세요：

```bash
export HMG_STORE_PATH=/custom/path/hmg-store
hmg daemon start
```

## 사용법

### 기억은 어떻게 구성되나요？

기억은 **원자**로 저장됩니다 — 타입, 스코프, 메타데이터를 가진 구조화된 정보 단위. 원자는 그래프의 엣지로 서로 연결됩니다（대체, 파생, 연관）.

자세한 내용은 [개념](concepts.md)을 참조하세요.

### 수정은 어떻게 작동하나요？

HMG는 기억을 덮어쓰지 않습니다. 수정은 새 원자를 생성하고 `Supersedes` 엣지로 원본에 연결합니다. 부정, 확인, 강등, 대체를 지원합니다.

자세한 내용은 [수정과 거버넌스](correction-governance.md)를 참조하세요.

### 거버넌스란 무엇인가요？

거버넌스는 민감한 기억을 보호합니다. 액션에는以下가 포함됩니다：격리（검토 중）, 봉인（잠금）, 툼스톤（삭제）, 교훈 파생（안전한 요약 추출）.

자세한 내용은 [수정과 거버넌스](correction-governance.md)를 참조하세요.

### 기억을 검색할 수 있나요？

네. Community Edition은 One-Shot Recall (P1-P9)을 지원합니다. Developer Edition은 수량 제한을 해제하고 자동 통합을 추가합니다.

## 에디션

### Community, Developer, Enterprise의 차이는？

| 기능 | Community | Developer | Enterprise |
|---|---|---|---|
| 기억과 리콜 | ✅ | ✅ | ✅ |
| 수정과 거버넌스 | ✅ | ✅ | ✅ |
| MCP 프로토콜 | ✅ | ✅ | ✅ |
| 원자 수 | 50,000 | 무제한 | 무제한 |
| 시맨틱 검색 | ❌ | ✅ | ✅ |
| One-Shot Recall | ✅ | ✅ | ✅ |
| 도메인 팩 | ❌ | ✅ | 전체 |
| SSO / RBAC | ❌ | ❌ | ✅ |
| 가격 | 무료 | 구독제 | 문의 |

### Developer로 업그레이드하려면？

```bash
hmg license apply <your-key>
hmg daemon restart
```

재설치 불필요 — 동일한 바이너리입니다.

자세한 내용은 [업그레이드 가이드](upgrade.md)를 참조하세요.

## 문제 해결

### 에이전트가 HMG 도구를 찾을 수 없음

1. 데몬이 실행 중인지 확인：`hmg daemon status`
2. 에이전트 설정 확인：`hmg doctor`
3. 에이전트/IDE 재시작

### `hmg daemon start` 실패

1. 포트 사용 여부 확인：`lsof -i :7654`
2. 스토리지 경로 권한 확인
3. `hmg doctor` 실행하여 진단

### 리콜이 잘못된 결과를 반환

1. 스코프 필드가 올바른지 확인（repository, branch）
2. `response_profile: "debug"`로 진단 정보 확인
3. 오래된 기억에 수정이 필요한지 확인
