"""Quickstart example: HMG Python SDK.

Demonstrates basic memorize, recall, correct, and govern operations.
Run against a local HMG daemon:
    hmg daemon start
    python quickstart.py
"""

from hmg import (
    HMGClient,
    coding_agent_scope,
    GovernanceAction,
)

client = HMGClient(base_url="http://localhost:3000")


def main() -> None:
    # Define scope for a coding agent session
    scope = coding_agent_scope("my-tenant", "platform", "my-repo", "main")

    # --- Memorize ---
    resp = client.memorize(
        content="We chose PostgreSQL for the main database because of JSON support",
        source="agent",
        domain_pack_id="software-engineering",
    )
    print(f"Memorized {len(resp.added_atoms)} atom(s): {resp.added_atoms}")
    atom_id = resp.added_atoms[0]

    # --- Recall ---
    result = client.recall(
        query="database choice",
        domain_pack_id="software-engineering",
    )
    print(f"\nRecall: {len(result.atoms)} atom(s)")
    for atom in result.atoms:
        print(f"  [{atom.score:.2f}] {atom.text}")

    # --- Correct ---
    correction = client.correct(
        target_atom=atom_id,
        action="confirm_actual",
        reason="Verified in architecture review meeting 2026-05-24",
    )
    print(f"\nCorrected: success={correction.success}")

    # --- Govern (derive lesson) ---
    lesson = client.govern(
        target_atom=atom_id,
        action="derive_lesson",
        reason="Contains infrastructure decision worth preserving",
        lesson_content="PostgreSQL chosen for JSON support in main database",
    )
    print(f"Governed: success={lesson.success}, lesson_atom={lesson.lesson_atom}")

    # --- Stats ---
    stats = client.stats()
    print(f"\nStats: {stats.atom_count} atoms, {stats.edge_count} edges")


if __name__ == "__main__":
    main()
