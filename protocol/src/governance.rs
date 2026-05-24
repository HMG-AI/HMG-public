//! Governance actions for memory atoms.

/// Actions that can be applied to govern a memory atom's lifecycle.
///
/// Governance transitions are append-only — the original atom is never
/// deleted, only its exposure state changes.
#[derive(Clone, Debug, serde::Serialize, serde::Deserialize, PartialEq)]
#[serde(rename_all = "snake_case")]
pub enum GovernanceAction {
    /// Restrict access to the atom; it will not appear in normal recall
    /// but remains accessible in governance and audit views.
    Quarantine,
    /// Permanently seal the atom; it cannot be modified further.
    /// Content remains accessible to authorized governance users.
    Seal,
    /// Mark the atom as tombstoned. The content is replaced with a
    /// tombstone marker (unless `destroy_payload` is false).
    Tombstone,
    /// Derive a safe lesson from the atom's content. The original atom
    /// may be sealed or tombstoned, and a new lesson atom is created.
    DeriveLesson,
}
