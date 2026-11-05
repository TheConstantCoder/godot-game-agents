#!/bin/bash
# Claude Code Stop hook: reminds the user (never blocks) when tracked files are left uncommitted
# at the end of a turn. Needs jq.
root="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/../.." && pwd)}"
cd "$root" || exit 0
changed=$(git diff --name-only HEAD 2>/dev/null | head -8)
[ -z "$changed" ] && exit 0
jq -n --arg m "Uncommitted work: $(echo $changed | tr ' ' ',')." '{systemMessage: $m}'
