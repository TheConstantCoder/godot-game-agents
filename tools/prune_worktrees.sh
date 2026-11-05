#!/bin/bash
# Removes worktrees under .claude/worktrees whose work has landed: the branch has a merged PR,
# its tip is in the main branch and the folder has no uncommitted changes. Dry run unless --yes.
# Worktrees elsewhere and the main folder are only listed, never touched. Needs gh.
# Settings (environment): MAIN_BRANCH (default main).
here=$(cd "$(dirname "$0")" && pwd)
main=$(dirname "$(git -C "$here" rev-parse --path-format=absolute --git-common-dir)")
yes=0; [ "$1" = "--yes" ] && yes=1
git -C "$main" fetch -q origin 2>/dev/null || echo "fetch failed; using local refs" >&2
target="origin/${MAIN_BRANCH:-main}"
while IFS=$'\t' read -r path branch; do
	[ "$path" = "$main" ] && continue
	case "$path" in
		"$main/.claude/worktrees/"*) ;;
		*) echo "skip   $path [$branch]: outside .claude/worktrees"; continue ;;
	esac
	if [ "$path" = "$(git rev-parse --show-toplevel 2>/dev/null)" ]; then
		echo "keep   $branch: this session is working in it"; continue
	fi
	if [ -n "$(git -C "$path" status --porcelain 2>/dev/null)" ]; then
		echo "keep   $branch: uncommitted changes"; continue
	fi
	if ! git -C "$main" merge-base --is-ancestor "refs/heads/$branch" "$target" 2>/dev/null; then
		echo "keep   $branch: has commits not in $target"; continue
	fi
	pr=$(gh pr list --repo "$(git -C "$main" remote get-url origin)" --state merged --head "$branch" --json number -q '.[0].number' 2>/dev/null)
	if [ -z "$pr" ]; then
		echo "keep   $branch: no merged PR"; continue
	fi
	if [ $yes -eq 1 ]; then
		git -C "$main" worktree remove "$path" && git -C "$main" branch -d "$branch" >/dev/null 2>&1
		echo "pruned $branch (PR #$pr)"
	else
		echo "prune  $branch (PR #$pr merged) - run with --yes to remove"
	fi
done < <(git -C "$main" worktree list --porcelain | awk '/^worktree /{p=substr($0,10)} /^branch /{sub("refs/heads/","",$2); print p"\t"$2} /^detached/{print p"\t(detached)"}')
[ $yes -eq 1 ] && git -C "$main" worktree prune
exit 0
