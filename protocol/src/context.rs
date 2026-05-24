//! Memory context — unified metadata attached to every memory operation.
//!
//! MemoryContext carries scope, access level, policy tags, timing, audit,
//! and governance metadata. This is the public wire-visible subset.

use crate::scope::ScopeRef;

/// Access level for a memory atom.
#[derive(Clone, Debug, serde::Serialize, serde::Deserialize, PartialEq)]
#[serde(rename_all = "snake_case")]
pub enum AccessLevel {
    /// Internal use within the scope.
    Internal,
    /// Shared across scopes within the same tenant.
    Shared,
    /// Restricted to specific authorized users.
    Restricted,
}

/// Unified context attached to memory operations (memorize, recall, correct, govern).
#[derive(Clone, Debug, serde::Serialize, serde::Deserialize)]
pub struct MemoryContextView {
    /// The scope this operation belongs to.
    pub scope: Option<ScopeRef>,
    /// Access level.
    pub access_level: AccessLevel,
    /// Policy tags applied to this operation.
    pub policy_tags: Vec<String>,
    /// The actor performing this operation.
    pub actor_id: Option<String>,
    /// Domain pack that should interpret this operation.
    pub domain_pack_id: Option<String>,
}
