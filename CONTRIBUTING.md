# Contributing

Thanks for helping. Agents here are used across many different games, so the bar is: **useful to any Godot 4 project, specific to none.**

## What makes a good change
- **Generic.** No game names, settings, characters or file paths from one project. If an agent needs a project fact, it reads it from `AGENTS.md` → "Project settings" or the `docs/` layout. Add a row to the settings table (and to `templates/AGENTS.md`) rather than hard-coding a value.
- **Godot 4 accurate.** GDScript 2.0 syntax, with static typing in examples. If advice depends on a version or renderer, say which ("4.5+", "Forward+ only").
- **Role-pure.** Reviewers don't write code; presentation agents don't change game rules; cheap helpers stay read-only or mechanical. Keep each agent's "does not" line true.
- **Plain words.** Agents are read by people too. Short sentences, no invented jargon.
- **No real people.** Don't name an agent after a real person, or write it to imitate one.

## Adding an agent
1. Add `agents/<name>.md` with `name`, `description` (when to use it and what it won't do), `model`, and `tools` if it should be limited.
2. Follow the shape of the others: **Read first**, **What you own / look for**, **How you work**, **How you report**.
3. Add it to the table in `README.md`.

## Changing tools
- Keep scripts dependency-light: bash, git and python3, plus optional `gh` and `jq`.
- Run `bash -n` on shell scripts and `python3 -m py_compile` on Python.
- For `tools/run_tests.gd`, check it against a small Godot project, headless, on the oldest and newest Godot 4 versions you can.

## Pull requests
- One concern per PR, with a clear title.
- Say which Godot version you tested with, if the change touches tools.
- Before opening, check for leftovers from your own project: `git grep -n -i "<your game name>"`.

By contributing you agree that your contribution is licensed under the MIT License.
