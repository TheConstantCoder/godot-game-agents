# Godot Game Agents

A team of [Claude Code](https://claude.com/claude-code) subagents for making games in **Godot 4** with **GDScript**: a team lead, a game architect, an art director, a technical artist, a UI developer, a visiting creative director, and three cheap helpers for searching, bookkeeping and test triage. They come with two skills, a few small tools, and a docs layout they all share.

They grew out of a real Godot project, and they are written to be game-agnostic. Everything project-specific comes from your own docs.

## The team

| Agent | Model | What it does | Edits code? |
| --- | --- | --- | --- |
| `team-lead` | opus | Project reviews, phase planning, settling open decisions, mapping assets to phases, keeping the roadmap, plan and decision log in sync. | No |
| `game-architect` | opus | Structure reviews at phase boundaries: layering, object archetypes, repeated decisions, spaghetti signals, the cost of the next one. Writes standards into `docs/ARCHITECTURE.md`. | No |
| `art-director` | opus | Owns look, UI and sound: pillars, palette, readability at every camera distance, setting accuracy, music licensing. Reviews captures and assets. | No |
| `look-dev` | opus | Technical artist: shaders, lighting, post-processing, colour grade, captures. Turns the art direction into presentation code. | Presentation only |
| `ui-dev` | opus | Builds `Control` screens from a brief: Theme, Containers, `tr()`, focus and input, a test and a capture for each screen. | Presentation only |
| `creative-director` | opus | Visits now and then to pitch 3–5 bold ideas that push what the game can do. Pitches only; the team decides. | No |
| `scout` | haiku | Finds things: "where is X", "what calls Y". Returns `file:line` pointers. | No (read-only) |
| `docs-clerk` | sonnet | Ticks plan boxes for merged work, fixes open-box counts, appends decision entries. | Docs only |
| `test-triage` | haiku | Runs the tests or reads a CI log and reports the first real error per failing test. | No |

### Skills
- **`status`** rewrites the "▶ Resume here" block of `docs/PLAN.md` from git, GitHub and the checklist itself. Try `/status` or "where are we?".
- **`handoff-ticket`** writes a small, complete ticket that hands one plan box to a cheaper coding agent (a local model, a smaller model or a fresh subagent) in its own worktree.

### Tools (optional)
| File | What it does |
| --- | --- |
| `tools/run_tests.gd` | A headless test runner with no addon needed. It finds `test_*.gd`, calls `run(tree)`, and prints `TESTS_OK`. On Godot 4.5+ it also fails a test that logs an engine error. |
| `tools/verify.sh` | Rebuilds the class cache, runs a parse check, the tests and a tree-hygiene check, then prints `VERIFY_OK` or `VERIFY_FAILED`. Works with GUT or gdUnit4 through `TEST_CMD`. |
| `tools/status.sh` | The facts behind `/status`: main, tags, PRs, worktrees, and the plan's open-box counts. |
| `tools/box.py` | Prints one plan box and the decisions it cites, so a small model never reads the whole plan. `--lint` checks a hand-off ticket. |
| `tools/new_worktree.sh`, `tools/prune_worktrees.sh` | Give each chat its own worktree, and clean up the ones whose PR has merged. |
| `hooks/check_gd.sh` | A PostToolUse hook that parse-checks every `.gd` file Claude writes and makes it fix errors at once. |
| `hooks/stop_check.sh` | A Stop hook that reminds you about uncommitted files. |

## Install

Copy just the agents:

```bash
git clone https://github.com/<you>/godot-game-agents.git
mkdir -p my-game/.claude/agents && cp godot-game-agents/agents/*.md my-game/.claude/agents/
```

Or copy everything (agents, skills, tools, hooks, and the docs templates if you don't have them yet):

```bash
godot-game-agents/install.sh path/to/my-game
```

The installer never overwrites a file you already have unless you pass `--force`. It never overwrites your docs at all. To make the agents available in every project, copy `agents/*.md` to `~/.claude/agents/` instead.

Then:
1. Fill in **"Project settings"** in `AGENTS.md`: the game's one line, Godot version, renderer, test command, folders, and branch and commit style. Add a `CLAUDE.md` containing `@AGENTS.md` so Claude Code loads it.
2. Set `GODOT_BIN` to your Godot 4 binary, and run `tools/verify.sh`.
3. Optional: merge `hooks/settings.example.json` into `.claude/settings.json` to turn on the hooks. They need `jq`.

Use an agent by asking for it ("ask the game-architect to review the save system"), or let Claude Code pick one from its description.

## The docs layout

The agents share one convention, so they can hand work to each other:

```
AGENTS.md              hard rules + "Project settings" (every agent reads this first)
CLAUDE.md              @AGENTS.md
docs/
  ROADMAP.md           phases, milestones, standing direction       (team-lead)
  PLAN.md              next work as checkboxes, "▶ Resume here"     (team-lead, docs-clerk, status)
  DECISIONS.md         append-only decision log, D1, D2, … "Next id" (everyone appends)
  ARCHITECTURE.md      layers, archetypes, standards, refactors      (game-architect)
  ART_DIRECTION.md     look, UI, sound, setting, music               (art-director)
  ASSETS.md            asset contract and inventory                  (art-director, team-lead)
  PITCHES.md           dated pitch sections                          (creative-director)
tickets/               hand-off tickets, one per branch              (handoff-ticket)
```

Starter versions of each are in [`templates/`](templates/). Three ideas hold it together:
- **Docs lead, code follows.** The roadmap and plan decide mechanics, the art direction decides look, the architecture doc decides structure. Agents check the docs before deciding and log what they decide.
- **Decisions get ids.** Any agent can cite `D12`, and `grep D12` finds the reason.
- **One box, one testable piece.** Each plan box names its test, which is what lets cheap agents tick boxes and hand off work safely.

## Adapting it
- **Different doc names?** Point "Project settings" at your files. Every agent reads that table before using its default paths.
- **Different test framework?** Set the test command and pass marker in "Project settings", or run `TEST_CMD=... TEST_PASS=... tools/verify.sh`.
- **Not a simulation game?** The game-architect's layer advice covers both a pure-logic layer under the scene tree and node-first games. Delete what doesn't apply.
- **Other models?** Change `model:` in an agent's frontmatter. The cheap helpers are deliberately on small models.
- **Your own rules?** Add them to the `AGENTS.md` code rules, numbered, so agents can cite them. Keep the agent files generic, which makes upgrades a plain copy.

## Requirements
- Claude Code
- Godot 4.x. The runner's error capture needs 4.5+; the rest works on any 4.x.
- bash, git and python3. `gh` and `jq` are optional.

## Contributing
See [CONTRIBUTING.md](CONTRIBUTING.md).

## License
[MIT](LICENSE).
