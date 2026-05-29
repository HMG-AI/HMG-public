/**
 * HMG Agent Memory SDK — Community Edition.
 *
 * Wire-safe client types for the HMG agent memory protocol.
 * This module contains only the public DTO types needed to interact
 * with HMG Community Edition via HTTP or MCP.
 *
 * For the full SDK including observation, vault, and advanced features,
 * see the Developer/Enterprise Edition.
 */

// ---------------------------------------------------------------------------
// Context types
// ---------------------------------------------------------------------------

export type ActorKind = "User" | "Agent" | "Service";
export type AccessLevel = "Public" | "Internal" | "Restricted";
export type CorrectAction = "negate" | "confirm_actual" | "confirm_necessary" | "demote" | "replace";
export type GovernanceAction = "quarantine" | "seal" | "tombstone" | "derive_lesson";
export type RecallViewMode = "normal" | "governance" | "audit";
export type Modality = "text" | "code" | "dialogue" | "observation";
export type OutputFormat = "compact_yaml" | "json" | "markdown" | "summary";

export interface ScopeSegment {
  kind: string;
  id: string;
}

export interface ScopeRef {
  tenant_id: string;
  path: ScopeSegment[];
}

export function codingAgentScope(
  tenantId: string,
  workspace: string,
  repository: string,
  branch: string,
): ScopeRef {
  return {
    tenant_id: tenantId,
    path: [
      { kind: "workspace", id: workspace },
      { kind: "repository", id: repository },
      { kind: "branch", id: branch },
    ],
  };
}

export interface ActorPrincipal {
  kind: ActorKind;
  id: string;
}

export interface AuditContext {
  actor: ActorPrincipal;
  operation: string;
  trace_id?: string;
  reason?: string;
}

export interface ObjectRef {
  object_type: string;
  object_id: string;
}

export interface MemoryReferences {
  subjects?: ObjectRef[];
  artifacts?: ObjectRef[];
  work_items?: ObjectRef[];
  decisions?: ObjectRef[];
  commitments?: ObjectRef[];
  evidence?: ObjectRef[];
}

export interface MemoryGovernance {
  sensitivity?: string[];
  legal_basis?: string;
  break_glass_role?: string;
}

export interface MemoryContext {
  scope?: ScopeRef;
  access_level?: AccessLevel;
  policy_tags?: string[];
  audit?: AuditContext;
  references?: MemoryReferences;
  governance?: MemoryGovernance;
}

// ---------------------------------------------------------------------------
// Request types
// ---------------------------------------------------------------------------

export interface MemorizeRequest {
  content: string;
  source?: string;
  modality?: Modality;
  domain_pack_id?: string;
  context?: MemoryContext;
}

export interface RecallRequest {
  query: string;
  max_results?: number;
  include_negated?: boolean;
  domain_pack_id?: string;
  context?: MemoryContext;
}

export interface RecallViewRequest extends RecallRequest {
  mode?: RecallViewMode;
}

export interface CorrectRequest {
  target_atom: string;
  action: CorrectAction;
  reason: string;
  new_content?: string;
  domain_pack_id?: string;
  context?: MemoryContext;
}

export interface GovernanceRequest {
  target_atom: string;
  action: GovernanceAction;
  reason: string;
  actor?: string;
  lesson_content?: string;
  destroy_payload?: boolean;
}

export interface HandoffRequest {
  summary: string;
  source?: string;
  context?: MemoryContext;
}

export interface AgentBriefRequest {
  query?: string;
  max_results?: number;
  output_format?: OutputFormat;
  context?: MemoryContext;
}

// ---------------------------------------------------------------------------
// Response types
// ---------------------------------------------------------------------------

export interface ApiError {
  code: string;
  message: string;
  details?: unknown;
}

export interface ApiEnvelope<T> {
  ok: boolean;
  data: T | null;
  error: ApiError | null;
}

export interface MemorizeResponse {
  added_atoms: string[];
  snapshot_version?: number;
  error?: string;
}

export interface RecalledAtom {
  id: string;
  text?: string;
  score?: number;
  epistemic_rank?: number;
  is_conditional?: boolean;
  exposure_state?: string;
}

export interface RecallResponse {
  narrative?: string;
  atoms: RecalledAtom[];
  knowledge_gaps: string[];
  candidates_considered?: number;
  error?: string;
}

export interface CorrectResponse {
  success: boolean;
  message: string;
  replacement_atom?: string;
}

export interface GovernanceResponse {
  success: boolean;
  message: string;
  target_atom: string;
  lesson_atom?: string;
  exposure?: string;
}

export interface AtomHistory {
  atom: Record<string, unknown>;
  current: Record<string, unknown>;
  polarity_history: unknown[];
  epistemic_history: unknown[];
  exposure_history: unknown[];
}

export interface StatsResponse {
  atom_count: number;
  edge_count: number;
  snapshot_version: number;
}

export interface HandoffResponse {
  summary: string;
  atoms_stored: number;
  scope?: string;
}

export interface AgentBriefResponse {
  content: string;
  memory_count: number;
  decisions: string[];
  risks: string[];
  next_steps: string[];
}

// ---------------------------------------------------------------------------
// Client
// ---------------------------------------------------------------------------

/**
 * HTTP client for the HMG memory service.
 *
 * @example
 * ```typescript
 * import { HMGClient } from "@hmg_ai/sdk-ts";
 *
 * const client = new HMGClient({ baseUrl: "http://localhost:8080" });
 *
 * await client.memorize({
 *   content: "We chose PostgreSQL for the main database",
 *   context: { repository: "my-app", branch: "main" },
 * });
 *
 * const result = await client.recall({ query: "database choice" });
 * for (const atom of result.atoms) {
 *   console.log(atom.text);
 * }
 * ```
 */
export class HMGClient {
  private baseUrl: string;
  private apiKey: string | undefined;

  constructor(options: { baseUrl?: string; apiKey?: string } = {}) {
    this.baseUrl = (options.baseUrl ?? "http://localhost:8080").replace(/\/+$/, "");
    this.apiKey = options.apiKey;
  }

  private async request<T>(method: string, path: string, body?: unknown): Promise<ApiEnvelope<T>> {
    const url = `${this.baseUrl}${path}`;
    const headers: Record<string, string> = { "Content-Type": "application/json" };
    if (this.apiKey) {
      headers["x-api-key"] = this.apiKey;
    }

    const response = await fetch(url, {
      method,
      headers,
      body: body ? JSON.stringify(body) : undefined,
    });

    return response.json();
  }

  async memorize(req: MemorizeRequest): Promise<MemorizeResponse> {
    const envelope = await this.request<MemorizeResponse>("POST", "/api/memorize", req);
    if (envelope.data) return envelope.data;
    throw new Error(apiErrorMessage(envelope));
  }

  async recall(req: RecallRequest): Promise<RecallResponse> {
    const envelope = await this.request<RecallResponse>("POST", "/api/recall", req);
    if (envelope.data) return envelope.data;
    throw new Error(apiErrorMessage(envelope));
  }

  async recallView(req: RecallViewRequest): Promise<RecallResponse> {
    const envelope = await this.request<RecallResponse>("POST", "/api/recall_view", req);
    if (envelope.data) return envelope.data;
    throw new Error(apiErrorMessage(envelope));
  }

  async correct(req: CorrectRequest): Promise<CorrectResponse> {
    const envelope = await this.request<CorrectResponse>("POST", "/api/correct", req);
    if (envelope.data) return envelope.data;
    throw new Error(apiErrorMessage(envelope));
  }

  async govern(req: GovernanceRequest): Promise<GovernanceResponse> {
    const envelope = await this.request<GovernanceResponse>(
      "POST",
      `/api/governance/${req.action}`,
      req,
    );
    if (envelope.data) return envelope.data;
    throw new Error(apiErrorMessage(envelope));
  }

  async history(atomId: string): Promise<AtomHistory> {
    const envelope = await this.request<AtomHistory>("GET", `/api/atom/${atomId}/history`);
    if (envelope.data) return envelope.data;
    throw new Error(apiErrorMessage(envelope));
  }

  async stats(): Promise<StatsResponse> {
    const envelope = await this.request<StatsResponse>("GET", "/api/stats");
    if (envelope.data) return envelope.data;
    throw new Error(apiErrorMessage(envelope));
  }

  async graphExport(): Promise<Record<string, unknown>> {
    const envelope = await this.request<Record<string, unknown>>("GET", "/api/graph/export");
    return envelope.data ?? {};
  }
}

function apiErrorMessage(envelope: ApiEnvelope<unknown>): string {
  const e = envelope.error;
  return `HMG API error: ${e?.code ?? "unknown"} — ${e?.message ?? "no details"}`;
}
