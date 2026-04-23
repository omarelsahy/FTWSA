# Agent context (committed)

This repo keeps **plans**, **session notes**, and **handoff state** in Git so work stays coherent across machines and chats.

## Read first

1. `docs/HANDOFF.md` — current focus, decisions, blockers, and “what changed last”.
2. `README.md` — how to run the Godot project and input defaults.

## Where to put artifacts

| Kind | Location |
|------|----------|
| Plans (from Plan mode or design docs) | `docs/plans/` |
| Agent chat exports or summaries | `docs/agent-chats/` |

Prefer **short summaries** in `docs/agent-chats/` for important threads; paste or copy full transcripts only when you need verbatim history (files can get large).

## When you finish a meaningful chunk of work

Update `docs/HANDOFF.md`: what was done, what is next, any open questions or risks.
