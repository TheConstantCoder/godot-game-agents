#!/bin/bash
# Claude Code PostToolUse hook (matcher Edit|Write): parse-checks the .gd file just written and
# feeds any errors back to Claude, which must fix them before moving on. Silent when the file is
# clean, is not GDScript, or is outside the project. Needs jq and GODOT_BIN (or godot on PATH).
root="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/../.." && pwd)}"
f=$(jq -r '.tool_input.file_path // .tool_response.filePath // empty')
case "$f" in *.gd) ;; *) exit 0 ;; esac
case "$f" in "$root"/*) rel="${f#"$root"/}" ;; *) exit 0 ;; esac
[ -f "$f" ] || exit 0
godot="${GODOT_BIN:-$(command -v godot)}"
[ -x "$godot" ] || exit 0
out=$("$godot" --headless --path "$root" --check-only --script "res://$rel" 2>&1 | grep -E "SCRIPT ERROR|Parse Error|at: GDScript" | head -20)
[ -z "$out" ] && exit 0
hint=""
if echo "$out" | grep -q "Could not find type\|not declared in the current scope"; then
	hint=" If the missing name is a new class_name, rebuild the class cache (godot --headless --editor --quit) and re-check."
fi
jq -n --arg r "Godot parse check failed for $rel:
$out
Fix it before moving on.$hint" '{decision: "block", reason: $r}'
