#!/bin/bash
# Gives a chat or agent its own folder and branch, so agents never share uncommitted work.
# Usage: tools/new_worktree.sh <branch> [base, default origin/main or main]
# Creates .claude/worktrees/<branch>; an existing branch is checked out there instead.
# Add .claude/worktrees/ to .gitignore.
set -e
name="$1"
[ -n "$name" ] || { echo "usage: $0 <branch> [base]" >&2; exit 1; }
here=$(cd "$(dirname "$0")" && pwd)
main=$(dirname "$(git -C "$here" rev-parse --path-format=absolute --git-common-dir)")
path="$main/.claude/worktrees/$name"
git -C "$main" fetch -q origin 2>/dev/null || true
base="${2:-$(git -C "$main" show-ref -q --verify refs/remotes/origin/main && echo origin/main || echo main)}"
if git -C "$main" show-ref -q --verify "refs/heads/$name"; then
	git -C "$main" worktree add "$path" "$name"
else
	git -C "$main" worktree add --no-track -b "$name" "$path" "$base"
fi
# Agents and local settings are often untracked: link them in so the worktree sees them.
for p in .claude/agents .claude/skills .claude/settings.local.json; do
	[ -e "$main/$p" ] && [ ! -e "$path/$p" ] && { mkdir -p "$(dirname "$path/$p")"; ln -s "$main/$p" "$path/$p"; }
done
echo "ready: $path"
