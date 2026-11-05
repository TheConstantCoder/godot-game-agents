---
name: status
description: Refresh docs/PLAN.md's "▶ Resume here" block and its open-box counts from git, GitHub and the checklist itself. Use when the user says /status, asks "where are we", or after a PR merges.
---

# /status: bring "Resume here" up to date

The "▶ Resume here" block in `docs/PLAN.md` goes stale every time a PR merges. This skill rewrites it from facts, not memory. (If `AGENTS.md` → "Project settings" names a different plan file, use that.)

1. Run `tools/status.sh`. It needs `gh` for the PR lists and works without it. It prints:
   - the main branch's head and last tag;
   - open and recently merged PRs;
   - every worktree;
   - each plan heading's `· N open` claim next to the boxes actually counted (`!!` means the heading count is wrong);
   - any extra facts the project added in `tools/status.local.sh`, such as a save-format version.
2. Read the current block (from `## ▶ Resume here` to the next `---`) and the `· N open` headings it summarises.
3. Draft the new block, keeping its existing bullets and order. Change only what the facts contradict:
   - **Phase, main, tag** and any project facts come from step 1.
   - **Open PRs** lists the open PRs. A PR that the block calls open but that has merged moves out.
   - **Open boxes** uses the counted numbers. Fix every `!!` heading count to match.
   - **Next** and **In flight** stay as written unless a fact makes them wrong (say, a merged PR closed the "next" item). If so, say what changed and ask the user what is next, rather than inventing it.
   - Add a worktree line only when a worktree holds unmerged work.
   - Update the "*(checked YYYY-MM-DD)*" line.
4. Show the user the diff (the block plus any heading counts) before writing. Never touch box wording or tick boxes here; that is the docs-clerk's job, and it needs a named commit.
5. On the user's OK, edit the plan and commit only that file, in the docs commit style from "Project settings" (for example `docs: refresh Resume here`).

Related: `tools/prune_worktrees.sh` lists worktrees whose PR has merged (it is a dry run; `--yes` removes them). Suggest it when status.sh shows one.
