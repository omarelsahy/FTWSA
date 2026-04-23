# Project docs

Use this folder so **plans and AI session context travel with the repo** (different PCs, fresh chats, collaborators).

## Files and folders

- **`HANDOFF.md`** — Living notes: current goal, recent changes, next steps. Edit this when you switch devices or start a new chat.
- **`plans/`** — Design and implementation plans (including anything you export from Cursor Plan mode). Use clear filenames, e.g. `2026-04-22-combat-parry.md`.
- **`agent-chats/`** — Summaries or exports of important agent conversations so you are not dependent on local Cursor history.

## Cursor chat location (Windows)

Full transcripts live **outside** the repo under your user profile, typically:

`%USERPROFILE%\.cursor\projects\<workspace-folder>\agent-transcripts\`

The `<workspace-folder>` name is derived from the project path (this repo often appears as `f-Projects-FTWSA`). Open that folder on each machine to copy text or files into `docs/agent-chats/`. Redact secrets before committing; raw logs can grow large.
