# HMG 개념

이 문서는 HMG의 핵심 개념을 설명합니다：기억 원자, 스코프, 수정, 거버넌스, 리콜.

## 기억 원자

기억 원자는 HMG의 기본 데이터 단위입니다. 각 원자는 구조화된 메타데이터를 가진 지속적인 정보 조각입니다.

### 원자 구조

```
Atom {
  id:          ULID          // 고유 식별자
  text:        String        // 실제 기억 내용
  modality:    text|code|dialogue|observation
  source:      String        // 소스 레이블
  polarity:    positive|negative|neutral
  epistemic:   claimed|confirmed|deprecated|unknown
  exposure:    normal|quarantined|sealed|tombstoned|lesson
  scope: {
    tenant_id, workspace, repository, branch, task_id, decision_id
  }
  timestamps:  created_at, updated_at
}
```

### 모달리티

| 모달리티 | 용도 |
|---|---|
| `text` | 일반 텍스트 기억（결정, 메모, 관찰） |
| `code` | 코드 스니펫 또는 아키텍처 결정 |
| `dialogue` | 대화 기록 또는 상호작용 |
| `observation` | 수동적으로 관찰된 행동 패턴 |

## 스코프

스코프는 기억의 컨텍스트 경계를 정의합니다. HMG는 계층적 스코프 모델을 사용합니다：

```
tenant_id         // 조직 또는 계정
  └── workspace   // 프로젝트 그룹 또는 팀
       └── repository  // 코드베이스
            └── branch  // 브랜치
                 ├── task_id     // 태스크
                 └── decision_id // 결정
```

### 스코프 동작

- **정확한 매치 우선**：리콜 시 `branch`가 제공되면 해당 브랜치의 기억을 우선 반환
- **폴백**：브랜치 레벨에 결과가 없으면 repository, workspace, tenant 레벨로 폴백
- **빈 스코프**：스코프 없는 기억은 전역으로 간주

## 수정 수명 주기

HMG는 기억을 덮어쓰지 않습니다. 대신 수정은 새 원자를 생성하고 엣지로 연결합니다：

### 수정 액션

| 액션 | 효과 |
|---|---|
| `negate` | 부정 극성 원자 생성, 대상 대체 |
| `confirm_actual` | 사실적 정확성 확인 |
| `confirm_necessary` | 지속적 관련성 확인 |
| `demote` | 인식 상태 강등 |
| `replace` | 이전 원자를 새 내용으로 대체 |

모든 수정은 불변 스냅샷 기록을 생성합니다.

자세한 내용은 [수정과 거버넌스](correction-governance.md)를 참조하세요.

## 거버넌스 수명 주기

거버넌스는 민감하거나 오래된 기억을 보호합니다：

```
normal → quarantined → sealed     （잠금）
                    → tombstoned  （삭제）
                    → normal      （복원）
임의   → lesson                   （교훈 추출）
```

거버넌스된 원자는 정상 리콜에서 숨겨지지만 감사 추적에는 보존됩니다.

자세한 내용은 [수정과 거버넌스](correction-governance.md)를 참조하세요.

## 리콜（Recall）

리콜은 기억 저장소에서 관련 기억을 검색합니다.

### 리콜 흐름

```
쿼리 → 의도 파싱 → 인덱스 검색 → 랭킹 → 스코프 필터 → 그래프 순회 투영 → 포맷 출력
```

### 응답 형식

| 형식 | 용도 |
|---|---|
| `compact` | 에이전트 일상 사용（기본값） |
| `summary` | 사람이 읽을 수 있는 요약 |
| `full` | 전체 세부 정보 |
| `debug` | 진단 정보 포함 |

### 시맨틱 검색

Community Edition은 One-Shot Recall (P1-P9)을 포함한 모든 에디션이 완전한 리콜 기능을 사용할 수 있습니다. Developer Edition은 수량 제한을 해제하고 자동 통합을 추가합니다.

## 그래프 모델

원자는 타입화된 엣지로 서로 연결됩니다：

| 엣지 유형 | 의미 |
|---|---|
| `Supersedes` | 수정/대체 관계 |
| `DerivesFrom` | 파생/학습 관계 |
| `RelatesTo` | 일반적 연관 |
| `ScopedBy` | 스코프 귀속 |

그래프 순회를 통해 리콜 작업은 직접 일치한 결과뿐만 아니라 관련 기억도 투영할 수 있습니다.

## 도메인 팩

도메인 팩은 사전 정의된 기억 템플릿과 스코프 전략입니다：

- **Software Engineering**：코드베이스, 브랜치, 태스크의 스코프 모델
- 커스텀 도메인 팩（Developer/Enterprise）

`domain_pack_id` 매개변수로 활성화합니다.

## 다음 단계

- [아키텍처](architecture.md) — HMG의 고수준 동작 원리
- [API 참조](api-reference.md) — 모든 MCP 도구와 HTTP 엔드포인트
- [수정과 거버넌스](correction-governance.md) — 자세한 수정 및 거버넌스 흐름
