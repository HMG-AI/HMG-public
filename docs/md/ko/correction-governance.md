# 수정과 거버넌스

HMG는 **추가 전용 수정 및 거버넌스 모델**을 사용합니다. 원자는 절대 조용히 덮어쓰이지 않습니다. 대신, 수정은 명시적 관계를 가진 새로운 원자를 생성하고, 거버넌스 전환은 전체 기록을 보존합니다.

## 원자 수명 주기 상태

### 극성（Polarity）

모든 원자에는 진위 상태를 나타내는 극성이 있습니다：

| 극성 | 의미 |
|---|---|
| `positive` | 원자가 참으로 주장됨 |
| `negative` | 원자가 부정되거나 대체됨 |
| `neutral` | 정보성 — 진위 주장 없음 |

### 인식 상태（Epistemic Status）

| 상태 | 의미 |
|---|---|
| `claimed` | 미확인 주장 |
| `confirmed` | 증거 또는 권위로 검증됨 |
| `deprecated` | 더 이상 관련 없지만 거짓이 아님 |
| `unknown` | 분류하기에 정보 부족 |

### 거버넌스 노출 상태（Exposure State）

| 상태 | 리콜 가능 | 의미 |
|---|---|---|
| `normal` | ✅ 정상 리콜 | 기본 상태 |
| `quarantined` | ❌ 리콜에서 숨김 | 민감성 검토 중 |
| `sealed` | ❌ 숨김, 불변 | 법적 또는 정책 제한 |
| `tombstoned` | ❌ 숨김, 페이로드 선택적 | 삭제 대상으로 표시 |
| `lesson` | ✅ 교훈만 | 민감 페이로드를 안전한 교훈으로 교체 |

## 수정 흐름

수정은 원자 간에 명시적인 `Supersedes`（대체）엣지를 생성합니다：

```text
원본 원자 (positive)
    │
    ├── negate ──→ 새 원자 (negative) + Supersedes 엣지
    ├── confirm_actual ──→ 원본 극성 확인 + Supersedes 엣지
    ├── confirm_necessary ──→ 원본 필요성 확인
    ├── demote ──→ 원본 인식 상태 강등
    └── replace ──→ 새 원자 (positive) + Supersedes 엣지 + 새 내용
```

### 수정 액션

| 액션 | 효과 |
|---|---|
| `negate` | 부정 극성의 원자를 생성하여 대상 대체 |
| `confirm_actual` | 원자의 사실적 정확성 확인 |
| `confirm_necessary` | 원자가 계속 관련 있음을 확인 |
| `demote` | 인식 상태 강등（예：confirmed → deprecated） |
| `replace` | 업데이트된 내용의 새 원자를 생성하여 이전 것 대체 |


## 거버넌스 흐름

거버넌스 전환은 민감하거나 오래된 기억을 보호합니다：

```text
normal → quarantined（검토 중）
quarantined → sealed（잠금, 불변）
quarantined → tombstoned（리콜에서 제거）
quarantined → normal（해제, 복원）
임의 → derive_lesson（안전한 요약으로 페이로드 교체）
```

### 거버넌스 액션

| 액션 | From → To | 사용 사례 |
|---|---|---|
| `quarantine` | normal → quarantined | 민감 콘텐츠로 의심됨 |
| `seal` | quarantined → sealed | 법적 보류, 컴플라이언스 |
| `tombstone` | quarantined → tombstoned | 리콜에서 삭제 |
| `derive_lesson` | 임의 → lesson | 안전한 교훈 추출, 민감 페이로드 제거 |


## 스냅샷 기록

모든 수정 및 거버넌스 액션은 불변 스냅샷을 생성합니다.
스냅샷은 전환 시점의 원자 상태를 보존합니다.

`memory_history` 도구는 전체 체인을 반환합니다：

```text
원자 생성 (v1)
  → 수정：negate (v2, Supersedes v1)
    → 거버넌스：tombstone (v2 정상 리콜에서 숨김)
      → 교훈 파생 (v3, 안전한 요약이 리콜에서 표시 가능)
```

## 리콜 뷰

HMG는 서로 다른 가시성 규칙을 가진 3가지 리콜 뷰를 지원합니다：

| 뷰 | 표시 내용 | 사용 사례 |
|---|---|---|
| `normal` | 활성 원자만（양극성, normal 노출 상태） | 일상 에이전트 사용 |
| `governance` | + 격리/봉인된 원자 | 컴플라이언스 검토 |
| `audit` | + 툼스톤된 것을 포함한 모든 원자, 전체 수정 체인 | 포렌식 조사 |

정상 리콜은 의도적으로 거버넌스된 페이로드를 제외합니다. 감사 리콜은 책임 추적을 위해 모든 것을 표시합니다.
