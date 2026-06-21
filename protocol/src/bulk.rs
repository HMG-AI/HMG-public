//! Bulk onboarding protocol types.
//!
//! Wire-safe DTOs for the bulk memorize endpoint (`POST /api/memorize/bulk`),
//! which streams Server-Sent-Events progress. These types are the public
//! contract shared by the server, the TypeScript SDK, and any external
//! integrator. They contain no ranking or algorithm types — only data shapes.
//!
//! Design (ADR `2026-06-19-adr-perf-scaling-recall-first-and-bulk-onboarding.md`,
//! roadmap item P2): the bulk channel is **pure UX** — it turns blind waiting
//! into visible waiting via streamed progress. Each item ingests through the
//! exact same admission / extraction / dedup / governance / DLP path as a
//! single `memorize`. The embedding-batching speedup (P3) is a separate,
//! deferred change and does not alter these shapes.

use serde::{Deserialize, Serialize};

use crate::MemoryContextView;

/// A single atom to ingest as part of a bulk request.
///
/// `content` is the only required field; `source` / `modality` may be set per
/// item or inherited from the request-level defaults.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct BulkMemorizeItem {
    /// Raw text content to ingest (one atom).
    pub content: String,
    /// Optional per-item source attribution; falls back to request `default_source`.
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub source: Option<String>,
    /// Optional per-item modality: `"text"` | `"code"` | `"dialogue"` | `"observation"`.
    /// Falls back to request `default_modality`, then `"text"`.
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub modality: Option<String>,
}

/// Request body for `POST /api/memorize/bulk`.
///
/// The response is an SSE stream of [`BulkProgressEvent`].
///
/// Note: does not derive `PartialEq`/`Eq` because the embedded
/// [`MemoryContextView`] is intentionally not equality-comparable.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct BulkMemorizeRequest {
    /// Non-empty list of items to ingest, in order.
    pub items: Vec<BulkMemorizeItem>,
    /// Default source applied when an item omits `source`.
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub default_source: Option<String>,
    /// Default modality applied when an item omits `modality`.
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub default_modality: Option<String>,
    /// Optional domain-pack runtime applied to every item.
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub domain_pack_id: Option<String>,
    /// Shared memory context (scope / access level / audit / references)
    /// applied to every item after per-item operator-profile preparation.
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub context: Option<MemoryContextView>,
    /// When true, stop at the first per-item error (terminal `failed` event).
    /// When false (default), every item is attempted and errors are reported
    /// per-item in `item_done.error` without aborting the batch.
    #[serde(default)]
    pub stop_on_error: bool,
}

/// One streamed progress event for a bulk memorize request.
///
/// Wire shape: `{"event": "<variant>", ...fields}` (internally tagged).
/// Variants are emitted in this order for a normal run:
/// `started` → (`item_done`, `progress`)* → `completed`. With `stop_on_error`,
/// the stream terminates with `failed` (followed by `completed`).
#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
#[serde(tag = "event", rename_all = "snake_case")]
pub enum BulkProgressEvent {
    /// Emitted once at the start, before any item is processed.
    Started { total: usize },
    /// Emitted after each item. `error` is set if this item failed but the
    /// batch continues (`stop_on_error == false`).
    ItemDone {
        index: usize,
        total: usize,
        added_atoms: Vec<String>,
        error: Option<String>,
    },
    /// Running aggregate progress after each item, for progress-bar / ETA UI.
    Progress {
        done: usize,
        total: usize,
        elapsed_ms: u64,
        eta_ms: Option<u64>,
    },
    /// Terminal success (or end-of-batch) summary.
    Completed {
        total: usize,
        written_atoms: usize,
        failed: usize,
        elapsed_ms: u64,
    },
    /// Terminal failure of item `index` when `stop_on_error == true`.
    Failed { index: usize, error: String },
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn bulk_request_round_trips_with_defaults() {
        let json_str = r#"{
            "items": [
                {"content": "We chose PostgreSQL"},
                {"content": "Switched to CockroachDB", "source": "followup", "modality": "dialogue"}
            ],
            "default_source": "architecture-review",
            "stop_on_error": true
        }"#;
        let req: BulkMemorizeRequest = serde_json::from_str(json_str).unwrap();
        assert_eq!(req.items.len(), 2);
        assert_eq!(req.items[0].content, "We chose PostgreSQL");
        assert!(req.items[0].source.is_none());
        assert_eq!(req.items[1].source.as_deref(), Some("followup"));
        assert_eq!(req.default_source.as_deref(), Some("architecture-review"));
        assert!(req.stop_on_error);
        assert!(req.default_modality.is_none());
        assert!(req.domain_pack_id.is_none());

        // Re-serialize and parse again — wire shape is stable. Compared via
        // JSON because `BulkMemorizeRequest` does not derive `PartialEq`.
        let reserialized = serde_json::to_string(&req).unwrap();
        let again: BulkMemorizeRequest = serde_json::from_str(&reserialized).unwrap();
        assert_eq!(serde_json::to_string(&again).unwrap(), reserialized);
    }

    #[test]
    fn progress_event_is_internally_tagged_snake_case() {
        let evt = BulkProgressEvent::Progress {
            done: 7,
            total: 10,
            elapsed_ms: 14000,
            eta_ms: Some(6000),
        };
        let v: serde_json::Value = serde_json::to_value(&evt).unwrap();
        assert_eq!(v["event"], "progress");
        assert_eq!(v["done"], 7);
        assert_eq!(v["eta_ms"], 6000);

        let started = BulkProgressEvent::Started { total: 10 };
        let sv: serde_json::Value = serde_json::to_value(&started).unwrap();
        assert_eq!(sv["event"], "started");
        assert_eq!(sv["total"], 10);

        // Round-trip through the tagged union.
        let parsed: BulkProgressEvent = serde_json::from_value(sv).unwrap();
        assert_eq!(parsed, started);
    }

    #[test]
    fn item_done_with_error_round_trips() {
        let evt = BulkProgressEvent::ItemDone {
            index: 3,
            total: 5,
            added_atoms: vec![],
            error: Some("admission rejected".into()),
        };
        let s = serde_json::to_string(&evt).unwrap();
        assert!(s.contains("\"event\":\"item_done\""));
        assert!(s.contains("\"admission rejected\""));
        let back: BulkProgressEvent = serde_json::from_str(&s).unwrap();
        assert_eq!(evt, back);
    }
}
