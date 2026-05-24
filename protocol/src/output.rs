//! Agent Tool Output Contract v2 — the output format for agent-facing recall results.
//!
//! HMG returns memory to agents in a structured compact format with progressive
//! disclosure: essential fields first, diagnostics and metadata on demand.

/// A single recalled memory atom in agent output format.
#[derive(Clone, Debug, serde::Serialize, serde::Deserialize)]
pub struct RecallAtom {
    /// The memory content (compact text).
    pub content: String,
    /// The atom ID (for correction/governance references).
    pub id: String,
    /// Relevance score (normalized 0.0-1.0). Higher = more relevant.
    pub relevance: f64,
    /// The scope this memory belongs to.
    pub scope: Option<String>,
    /// When this memory was created (ISO 8601).
    pub created_at: Option<String>,
}

/// The response from a recall operation (agent output contract v2).
#[derive(Clone, Debug, serde::Serialize, serde::Deserialize)]
pub struct RecallResponse {
    /// The recalled atoms, ranked by relevance.
    pub atoms: Vec<RecallAtom>,
    /// Total number of atoms considered.
    pub total_candidates: usize,
    /// Query that was executed.
    pub query: String,
    /// Output format used.
    pub format: OutputFormat,
    /// Optional diagnostics (only when requested or in Community edition).
    pub diagnostics: Option<RecallDiagnostics>,
}

/// Output format variants.
#[derive(Clone, Debug, serde::Serialize, serde::Deserialize, PartialEq)]
#[serde(rename_all = "snake_case")]
pub enum OutputFormat {
    /// Compact YAML (default for agents).
    CompactYaml,
    /// Full JSON.
    Json,
    /// Markdown (for human consumption).
    Markdown,
    /// Summary (narrated).
    Summary,
}

/// Diagnostics attached to recall responses.
#[derive(Clone, Debug, serde::Serialize, serde::Deserialize)]
pub struct RecallDiagnostics {
    /// Which recall engine was used.
    pub recall_engine: String,
    /// Number of seed candidates.
    pub seed_count: usize,
    /// Number of atoms after projection.
    pub projected_count: usize,
    /// Token budget used (if applicable).
    pub tokens_used: Option<usize>,
    /// Optional upgrade hint (Community edition only).
    pub hint: Option<String>,
}

/// Memorize acknowledgment — minimal response for write operations.
#[derive(Clone, Debug, serde::Serialize, serde::Deserialize)]
pub struct MemorizeAck {
    /// IDs of created atoms.
    pub atom_ids: Vec<String>,
    /// Whether the operation succeeded.
    pub success: bool,
    /// Optional message.
    pub message: Option<String>,
}

/// Handoff summary — for cross-session context continuity.
#[derive(Clone, Debug, serde::Serialize, serde::Deserialize)]
pub struct HandoffSummary {
    /// Summary text.
    pub summary: String,
    /// Number of atoms stored.
    pub atoms_stored: usize,
    /// Scope of the handoff.
    pub scope: Option<String>,
}

/// Agent brief — compact context for starting a new session.
#[derive(Clone, Debug, serde::Serialize, serde::Deserialize)]
pub struct AgentBrief {
    /// Brief content (compact YAML or text).
    pub content: String,
    /// Number of memories in the scope.
    pub memory_count: usize,
    /// Key decisions recalled.
    pub decisions: Vec<String>,
    /// Active risks or open items.
    pub risks: Vec<String>,
    /// Suggested next steps.
    pub next_steps: Vec<String>,
}
