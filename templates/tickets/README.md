# Tickets

One file per hand-off: `tickets/<branch>.md`. The `handoff-ticket` skill writes them; the main agent deletes each one when its work is reviewed and merged. Keep each under about 1,500 tokens (characters / 4).

Copy this template:

```markdown
# <short title>

**Branch:** <branch-name>
**Box:** <the plan box, word for word>

## Goal
One or two sentences: what exists when this is done.

## Settled rules
- The decided names, numbers and stand-ins this box needs (cite D<N> ids).

## Files
- Read first: `path/to/file.gd` lines 40–80 (the helper to reuse), `path/to/test_thing.gd` lines 1–30 (the case to copy).
- Edit: `path/to/file.gd`, `path/to/test_new.gd` (new).
- Do not touch: save format, UI, docs, any other file.

## Steps
1. <one change>. Check: `tools/verify.sh --only test_new`.
2. <one change>. Check: `tools/verify.sh --only test_new`.

## Done when
- `tools/verify.sh` ends with `VERIFY_OK`.
- One commit on the branch: `<prefix>: <what>`.
```
