# 업그레이드 가이드

이 문서는 HMG 업그레이드 및 에디션 전환 방법을 설명합니다.

## HMG 업그레이드

### v0.9.x에서 업그레이드

```bash
# 최신 버전 다운로드
curl -fsSL https://github.com/HMG-AI/HMG-public/releases/latest/download/install.sh | sh

# 데몬 재시작
hmg daemon restart

# 버전 확인
hmg --version
```

### 수동 업그레이드

```bash
# Linux x86_64
curl -L https://github.com/HMG-AI/HMG-public/releases/latest/download/hmg-x86_64-unknown-linux-gnu.tar.gz | tar -xzf - -C ~/.local/bin/

# macOS Apple Silicon
curl -L https://github.com/HMG-AI/HMG-public/releases/latest/download/hmg-aarch64-apple-darwin.tar.gz | tar -xzf - -C ~/.local/bin/
```

### v0.8.x에서 업그레이드

v0.9.x에는 스토리지 형식 변경이 포함되어 있습니다. HMG가 자동으로 마이그레이션합니다：

```bash
hmg daemon start
# 첫 실행 시 v0.8 스토리지 형식 자동 마이그레이션
```

마이그레이션은 자동적이며 되돌릴 수 없습니다. 사전 백업을 권장합니다：

```bash
cp -r ~/.local/share/hmg ~/.local/share/hmg.bak-v0.8
```

## 에디션 전환

HMG는 단일 바이너리를 사용합니다. 에디션은 라이선스 키로 결정됩니다：

### Community → Developer

```bash
hmg license apply hmg-dev-xxxxx
hmg daemon restart
```

즉시 잠금 해제：무제한 원자, 시맨틱 검색, One-Shot Recall, 도메인 팩.

### Developer → Enterprise

```bash
hmg license apply hmg-ent-xxxxx
hmg daemon restart
```

즉시 잠금 해제：SSO, RBAC, 멀티테넌트, 감사 내보내기.

### Enterprise → Community

```bash
hmg license remove
hmg daemon restart
```

Community 버전 제한으로 돌아갑니다. 데이터는 유지되지만 제한을 초과하는 원자는 읽기 전용이 됩니다.

## 데이터 호환성

| From → To | 마이그레이션 액션 |
|---|---|
| Community → Developer | 마이그레이션 불필요 |
| Community → Enterprise | 마이그레이션 불필요 |
| Developer → Enterprise | 마이그레이션 불필요 |
| v0.8 → v0.9 | 자동 마이그레이션（첫 실행 시） |

## 변경 이력

전체 변경 이력은 [CHANGELOG.md](https://github.com/HMG-AI/HMG-public/blob/main/CHANGELOG.md)를 참조하세요.
