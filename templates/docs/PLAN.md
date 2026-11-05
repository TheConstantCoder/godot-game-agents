# Plan

Next work as checkboxes. One box = one testable, committable piece, with its test named. Headings carry a `· N open` count that `tools/status.sh` checks. A 🛠 at the start of a box marks it as fit for a hand-off agent (see the `handoff-ticket` skill).

## ▶ Resume here
- **Phase:** M0 — `<name>`
- **Main:** `<short sha> <subject>` · last tag `<tag>`
- **Open PRs:** none
- **Open boxes:** M0 3
- **Next:** `<the box to pick up next>`
- **In flight:** nothing
*(checked YYYY-MM-DD)*

---

## M0 — `<name>` · 3 open

### Core loop · 2 open
- [ ] **Player movement** — `CharacterBody3D` with walk and jump, from InputMap actions. Test: `test_player_movement.gd`.
- [ ] 🛠 **Inventory data** — `Inventory` (RefCounted) with add, remove and `to_dict`/`from_dict`. Test: `test_inventory.gd` (D2).
- [x] **Project skeleton** — folders, AGENTS.md, test runner. — PR #1

### Look · 1 open
- [ ] **First look capture** — greybox scene lit for day and night, captured at every camera distance. Test: `test_look_palette.gd`.
