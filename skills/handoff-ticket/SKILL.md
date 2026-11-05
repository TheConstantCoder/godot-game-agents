---
name: handoff-ticket
description: Write a short, focused ticket (the prompt) that hands one plan box to a cheaper coding agent — a local model, a smaller Claude model or a fresh subagent — to run in its own branch and worktree. Use when the user asks for a ticket, a prompt or a task for a local agent or a cheaper model, or to hand off the next coding job.
---

# Hand-off ticket

A cheaper agent is slow to read and quick to wander, so the ticket is its whole brief. It must be small and complete. **One ticket = one plan box (or half of one) = one branch and worktree = one commit.** You do the thinking; the agent types.

## 1. Pick the box
- Only boxes the project marks as hand-off-able. By default that is a 🛠 at the start of the box in `docs/PLAN.md`; `AGENTS.md` → "Project settings" may say otherwise, and may list the folders a hand-off agent may touch.
- Good hand-off boxes are self-contained: pure logic, data, tools, tests. Scene layout, shaders, UI look and anything that needs a judgement call stay with the main agent. If the box isn't a fit, say so and stop.

## 2. Settle the design first
- Run `grep -n -i "<topic>" docs/*.md`, and copy only the lines that decide the box: names, numbers, stand-ins.
- Decide any rule the docs leave open **before** the ticket goes out. Ask the user; or, for a trivial choice, decide it, name it in the hand-over, and log it in `docs/DECISIONS.md` at review. Never leave a design choice to the agent.

## 3. Read the code yourself
- Find the exact files, functions and line areas (`grep -n "^func \|^class_name\|^@export\|^signal" <file>`), the resources and data to touch, and an existing test to copy.
- Point the agent at functions, never at whole big files.

## 4. Write `tickets/<branch>.md`
Use the template in `tickets/README.md` (this pack ships it in `templates/tickets/README.md`). Its parts are Branch, Box, Goal, Settled rules, Files, Steps and Done when.
- **Branch:** follow the project's branch naming; the commit prefix follows its commit style.
- **Steps:** numbered and imperative, with one change each. Every step ends with a check run (a parse check or one test). Use the project's commands from "Project settings", for example `tools/verify.sh --only <test>`.
- **Exact names:** fields, consts, paths and test-case messages. Give a code skeleton when the API is unusual (`ConfigFile`, signals, `RandomNumberGenerator` seeding, `Resource` saving), and for each new function when the agent is a small model. Small models copy exact code well and lose time working it out.
- **Read first:** under Files, name the exact line ranges to read (helpers, the case to copy). Tell the agent to read only those, then edit. Anything it must not re-check goes in the ticket.
- **Built at runtime:** mark any name that grep cannot find (for example a key built from an id and a suffix) as "built at runtime". Otherwise the agent searches for it in a loop.
- **Setup facts:** state the starting values a test relies on (starting money, stock, seed quirks), so the agent does not go looking for them.
- **Say what not to touch:** files, save formats, UI, docs.
- **No history.** Give no rationale beyond one line. Don't paste AGENTS.md rules; the agent reads AGENTS.md itself.
- **Budget:** `wc -c tickets/<branch>.md` divided by 4 stays under about 1,500 tokens.
- **Never** ask the agent to change an allow-list, a ratchet or an expected count in a test. The reviewer does that.

## 5. Check and hand over
- If the project has `tools/box.py`, run `python3 -I tools/box.py --lint <branch>`; it must print `TICKET_OK`.
- Make the worktree (`tools/new_worktree.sh <branch>`), then give the user one command in a `bash` block that starts the agent there with the ticket as its prompt. Add a one-line note of any choice you made for them.
- Commit the ticket with the project's docs commit style.

## 6. Review after the run (the main agent's job)
- Read `git -C <worktree> log -1 --stat` and the diff against AGENTS.md's hard rules. Run the full verify command yourself.
- Fix it, or send it back. Then tick the plan box, append any decision entry, delete the ticket in the same docs commit, push the branch and open the PR.
