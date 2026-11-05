#!/bin/bash
# Facts for the plan's "▶ Resume here" block (the status skill): the main branch, tags, open PRs,
# worktrees, and each plan heading's real open-box count against the count it claims. Read-only.
# Settings (environment): PLAN_FILE (default docs/PLAN.md), MAIN_BRANCH (default main).
# Project-specific facts (a save version, a build number): put them in tools/status.local.sh;
# it is run with the main folder as its first argument.
here=$(cd "$(dirname "$0")" && pwd)
main=$(dirname "$(git -C "$here" rev-parse --path-format=absolute --git-common-dir)")
branch="${MAIN_BRANCH:-main}"
plan="$main/${PLAN_FILE:-docs/PLAN.md}"
g() { git -C "$main" "$@"; }
ref="$branch"
if g remote get-url origin >/dev/null 2>&1; then
	g fetch -q origin --tags 2>/dev/null || echo "(fetch failed; local refs)"
	g show-ref -q --verify "refs/remotes/origin/$branch" && ref="origin/$branch"
fi
echo "== $ref"
g log -1 --format='%h %ad %s' --date=short "$ref"
echo "last tag: $(g describe --tags --abbrev=0 "$ref" 2>/dev/null || echo none)"
if command -v gh >/dev/null && g remote get-url origin >/dev/null 2>&1; then
	repo=$(g remote get-url origin)
	echo "== open PRs"
	gh pr list --repo "$repo" --json number,title,headRefName -q '.[] | "#\(.number) [\(.headRefName)] \(.title)"' 2>/dev/null || echo "(gh failed)"
	echo "== recently merged PRs"
	gh pr list --repo "$repo" --state merged --limit 5 --json number,title -q '.[] | "#\(.number) \(.title)"' 2>/dev/null
fi
echo "== worktrees"
g worktree list | sed "s#$main#.#"
[ -x "$here/status.local.sh" ] && { echo "== project"; "$here/status.local.sh" "$main"; }
[ -f "$plan" ] || { echo "(no plan file at $plan)"; exit 0; }
echo "== plan open boxes (heading claims vs counted)"
python3 -I - "$plan" <<'PY'
import re, sys
lines = open(sys.argv[1], encoding="utf-8").read().splitlines()
heads = [(i, len(m.group(1)), l) for i, l in enumerate(lines) if (m := re.match(r"(#{2,6}) ", l))]
for k, (i, lvl, text) in enumerate(heads):
    m = re.search(r"· (\d+) open", text)
    if not m:
        continue
    end = next((j for j, l2, _ in heads[k + 1:] if l2 <= lvl), len(lines))
    n = sum(1 for l in lines[i:end] if l.lstrip().startswith("- [ ]"))
    claim = int(m.group(1))
    name = re.sub(r"\s*·\s*\d+ open.*", "", text)
    print(f"{claim:>3} {n:>3} {'  ' if claim == n else '!!'} {name[:90]}")
PY
echo "(claim count heading; !! = heading count is wrong)"
