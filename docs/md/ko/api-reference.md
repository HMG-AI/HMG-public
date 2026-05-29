# HMG API 참조 — Community Edition

HTTP 기본 URL：`http://localhost:3000`（기본값）.

## MCP 도구

HMG는 Community Edition에서 8개의 MCP 도구를 노출합니다. 모든 도구는 브랜치 인식 기억을 위한 스코프 필드가 포함된 선택적 `context` 객체를 허용합니다.

### `memory_memorize`

지속적인 정보를 저장합니다.

```json
{
  "content": "기억할 텍스트",
  "source": "선택적 소스 레이블",
  "modality": "text",
  "context": {
    "tenant_id": "tenant-acme",
    "workspace": "platform",
    "repository": "my-repo",
    "branch": "main"
  }
}
```

응답：

```json
{
  "success": true,
  "added_atom_count": 1,
  "added_atoms": ["01KSEFSC29QX8RQ78N3110ATC9"],
  "snapshot_version": 8
}
```


### `memory_recall`

관련 기억을 검색합니다.

```json
{
  "query": "어떤 데이터베이스를 선택했습니까？",
  "max_results": 10,
  "response_profile": "compact",
  "output_format": "yaml"
}
```

응답 프로필：`compact`（기본값）、`summary`、`full`、`debug`.

출력 형식：`yaml`（기본값）、`markdown`、`json`.


### `memory_correct`

원자를 수정, 부정, 확인, 강등 또는 대체합니다.

```json
{
  "target_atom": "01KSEFSC29QX8RQ78N3110ATC9",
  "action": "replace",
  "reason": "단순화를 위해 SQLite로 변경",
  "new_content": "결정：사용자 데이터에 SQLite 사용."
}
```

액션：`negate`、`confirm_actual`、`confirm_necessary`、`demote`、`replace`.


### `memory_govern`

거버넌스 적용：격리, 봉인, 툼스톤 또는 교훈 파생.

```json
{
  "target_atom": "01KSEFSC29QX8RQ78N3110ATC9",
  "action": "tombstone",
  "reason": "민감한 API 키 참조 포함"
}
```

액션：`quarantine`、`seal`、`tombstone`、`derive_lesson`.


### `memory_history`

원자의 수정 및 거버넌스 기록을 검사합니다.

```json
{
  "atom_id": "01KSEFSC29QX8RQ78N3110ATC9"
}
```

### `memory_handoff`

크로스 세션 핸드오프 요약을 작성합니다.

```json
{
  "summary": "X를 구현, Y 테스트로 검증, 남은 리스크：Z.",
  "source": "session-end"
}
```

### `memory_agent_brief`

태스크 시작 시 컴팩트한 브랜치 인식 브리프를 가져옵니다.

```json
{
  "query": "현재 코딩 태스크의 컨텍스트",
  "brief_format": "compact_yaml"
}
```


### `memory_stats`

그래프와 인덱스 통계를 가져옵니다.

```json
{}
```


## HTTP API

### `POST /api/memorize`

`memory_memorize`와 동일한 매개변수, JSON 바디로.

### `POST /api/recall`

`memory_recall`과 동일한 매개변수, JSON 바디로.

### `POST /api/correct`

`memory_correct`와 동일한 매개변수, JSON 바디로.

### `POST /api/governance/{action}`

액션：`quarantine`、`seal`、`tombstone`、`derive_lesson`.

### `GET /api/stats`

원자 수, 엣지 수, 인덱스 통계를 반환합니다.

### `GET /api/graph/export`

전체 기억 그래프를 JSON으로 내보냅니다.

### `GET /api/snapshot/{atom_id}`

특정 원자의 스냅샷 기록을 반환합니다.

### `GET /api/audit/{atom_id}`

전체 감사 추적（수정 + 거버넌스 기록）을 반환합니다.

## 스코프（브랜치 인식 기억）

HMG는 코딩 에이전트를 위한 계층적 스코프를 지원합니다：

```text
tenant_id → workspace → repository → branch
                                        ↳ task_id
                                        ↳ decision_id
```

스코프 필드가 제공되면, 리콜은 자동으로 브랜치별 기억을 우선하여 더 넓은 워크스페이스나 테넌트 기억보다 상위에 랭킹합니다.

## 응답 형식

모든 응답은 일관된 구조를 따릅니다：

```json
{
  "success": true,
  "snapshot_version": 905,
  "..."
}
```

오류 응답：

```json
{
  "success": false,
  "error": "오류 설명"
}
```
