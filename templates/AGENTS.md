# AGENTS.md

Hard rules for every agent (and human) working on this project. Agents read this file first. Keep it short: rules here are enforced, and anything longer belongs in `docs/`.

Claude Code reads `CLAUDE.md`, not `AGENTS.md`. Put one line, `@AGENTS.md`, in `CLAUDE.md` so both names work.

## Project settings
The agents in this pack look here for anything project-specific. Fill in every `<…>`.

| Setting | Value |
| --- | --- |
| Game | `<one line: genre, setting, what the player does>` |
| Godot version | `<4.x.y>` |
| Renderer | `<Forward+ / Mobile / Compatibility>` |
| Godot binary | `$GODOT_BIN` (each developer sets it) |
| Test command | `tools/verify.sh` — passes on `VERIFY_OK` |
| One test | `tools/verify.sh --only <test_name>` |
| Docs folder | `docs/` (ROADMAP, PLAN, DECISIONS, ARCHITECTURE, ART_DIRECTION, ASSETS, PITCHES) |
| Decision ids | `D<N>` in `docs/DECISIONS.md` |
| Main branch | `main` |
| Branch names | `<area>-<topic>` |
| Commit style | `<area>: <what>` (docs: `docs: …`, art: `art: …`, architecture: `arch: …`) |
| Code folders | `<src/ (game code), scenes/, common/ (shared resources)>` |
| Look resources | `<common/look/>` |
| Shared UI theme | `<common/theme/theme.tres>` |
| Translations | `<common/i18n/strings.csv>` |
| Hand-off boxes | boxes starting with 🛠 in `docs/PLAN.md`; hand-off agents may edit `<src/logic/, tools/>` |
| No-touch files | `<save format, migrations, fixtures: ask first>` |

## Code rules
- Static typing everywhere: typed variables, parameters, returns, and `Array[T]`.
- Godot 4 syntax only (`@export`, `@onready`, `signal x(a: int)`, `Callable`, `await`).
- Signal up, call down: children emit signals, parents call methods. No long `get_node("../../x")` paths.
- `<If you keep game rules in a pure logic layer: that folder never uses Node, get_tree(), autoloads or await.>`
- UI reads read-only views of game state and sends commands; it never computes game rules.
- All player-facing text goes through `tr()`.
- `<add your own "never" rules here, numbered, so agents can cite them>`

## Testing
- Tests are `test_*.gd` files beside the code they test (see `tools/run_tests.gd` for the contract).
- A change is done only when the test command prints its pass marker.

## Definition of Done
1. The test command passes.
2. New behaviour has a test.
3. Docs that the change makes wrong are updated (or a decision is logged).
4. Nothing is left uncommitted.

## Git
- One worktree per chat or agent (`tools/new_worktree.sh <branch>`). Never switch branches in a folder another agent is using.
- Never commit to the main branch directly; open a PR.
