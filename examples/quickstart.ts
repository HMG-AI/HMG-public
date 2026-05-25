/**
 * Quickstart example: HMG TypeScript SDK.
 *
 * Demonstrates basic memorize, recall, correct, and govern operations.
 * Run against a local HMG daemon:
 *     hmg daemon start
 *     npx ts-node quickstart.ts
 */

import {
  HMGClient,
  codingAgentScope,
  type CorrectAction,
  type GovernanceAction,
} from "../sdk-ts/src/index";

const client = new HMGClient({ baseUrl: "http://localhost:8080" });

async function main(): Promise<void> {
  // Define scope for a coding agent session
  const scope = codingAgentScope("my-tenant", "platform", "my-repo", "main");

  // --- Memorize ---
  const memResp = await client.memorize({
    content: "We chose PostgreSQL for the main database because of JSON support",
    source: "agent",
    domain_pack_id: "software-engineering",
  });
  console.log(`Memorized ${memResp.added_atoms.length} atom(s): ${memResp.added_atoms}`);
  const atomId = memResp.added_atoms[0];

  // --- Recall ---
  const result = await client.recall({
    query: "database choice",
    domain_pack_id: "software-engineering",
  });
  console.log(`\nRecall: ${result.atoms.length} atom(s)`);
  for (const atom of result.atoms) {
    console.log(`  [${atom.score?.toFixed(2)}] ${atom.text}`);
  }

  // --- Correct ---
  const correction = await client.correct({
    target_atom: atomId,
    action: "confirm_actual",
    reason: "Verified in architecture review meeting 2026-05-24",
  });
  console.log(`\nCorrected: success=${correction.success}`);

  // --- Govern (derive lesson) ---
  const lesson = await client.govern({
    target_atom: atomId,
    action: "derive_lesson",
    reason: "Contains infrastructure decision worth preserving",
    lesson_content: "PostgreSQL chosen for JSON support in main database",
  });
  console.log(`Governed: success=${lesson.success}, lesson_atom=${lesson.lesson_atom}`);

  // --- Stats ---
  const stats = await client.stats();
  console.log(`\nStats: ${stats.atom_count} atoms, ${stats.edge_count} edges`);
}

main().catch(console.error);
