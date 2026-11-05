#!/usr/bin/env bash
# Definition of Done, step 1: class-cache scan, parse check, test suite, tree hygiene.
# Passes only on the runner's pass marker (Godot exit codes are not reliable).
#   tools/verify.sh [runner args]      e.g. --only test_inventory,test_save
# Ends with VERIFY_OK or VERIFY_FAILED (exit 1).
# Settings (environment):
#   GODOT_BIN       path to the Godot 4 binary (default: `godot` on PATH)
#   VERIFY_PROJECT  project folder (default: the folder above tools/)
#   TEST_CMD        a custom test command instead of tools/run_tests.gd (e.g. for GUT or gdUnit4)
#   TEST_PASS       the line that marks a passing run for TEST_CMD (default: TESTS_OK)
set -u
PROJECT="${VERIFY_PROJECT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
GODOT="${GODOT_BIN:-$(command -v godot || true)}"
PASS="${TEST_PASS:-TESTS_OK}"
OUT="$(mktemp -d "${TMPDIR:-/tmp}/verify.XXXXXX")" || { echo "VERIFY_FAILED: no temp dir"; exit 1; }
trap 'rm -rf "$OUT"' EXIT
fails=0
fail() { echo "FAIL  $*"; fails=$((fails + 1)); }
ok() { echo "ok    $*"; }
godot() { "$GODOT" --headless --path "$PROJECT" "$@" 2>&1; }

[ -n "$GODOT" ] && [ -x "$GODOT" ] || { echo "VERIFY_FAILED: no Godot binary (set GODOT_BIN)"; exit 1; }
cd "$PROJECT" || exit 1

# 1. Class cache: rescan when any script is newer than it (a branch switch leaves it stale, and a
#    stale cache makes new class_names look undefined).
cache=".godot/global_script_class_cache.cfg"
if [ ! -f "$cache" ] || [ -n "$(find . -name '*.gd' -newer "$cache" -not -path './.godot/*' -print -quit 2>/dev/null)" ]; then
	godot --editor --quit > "$OUT/scan.txt"
	ok "class cache rescanned"
else
	ok "class cache is current"
fi

# 2. Parse check: load every script once (works without a main scene).
godot --script res://tools/run_tests.gd -- --parse-only > "$OUT/parse.txt"
if grep -q "^PARSE_OK" "$OUT/parse.txt" && ! grep -qE "SCRIPT ERROR|Parse Error" "$OUT/parse.txt"; then
	ok "parse check: $(grep '^PARSE_OK' "$OUT/parse.txt")"
else
	fail "parse check"; grep -E "^  - |SCRIPT ERROR|Parse Error|PARSE_FAILED" "$OUT/parse.txt" | head -10
fi

# 3. Tests: the pass marker decides.
if [ -n "${TEST_CMD:-}" ]; then
	bash -c "$TEST_CMD $*" > "$OUT/tests.txt" 2>&1
else
	godot --script res://tools/run_tests.gd -- --quiet "$@" > "$OUT/tests.txt"
fi
if grep -q "^$PASS" "$OUT/tests.txt"; then
	ok "$(grep "^$PASS" "$OUT/tests.txt" | head -1)"
else
	fail "tests: no $PASS line"
	grep -E '^\[FAIL\]|^  - |SCRIPT ERROR|_FAILED' "$OUT/tests.txt" | cut -c1-220 | head -20
fi

# 4. Tree hygiene: orphan .uid files (script deleted or renamed without its .uid), scratch files.
orphans=""
while IFS= read -r u; do [ -f "${u%.uid}" ] || orphans="$orphans $u"; done \
	< <(find . -name '*.gd.uid' -not -path './.godot/*' 2>/dev/null)
[ -n "$orphans" ] && fail "orphan .uid files:$orphans"
scratch="$(git status --porcelain 2>/dev/null | grep -Ei '(probe|scratch|\.orig|\.rej)' | cut -c4-)"
[ -n "$scratch" ] && fail "scratch-looking files in git status: $(echo $scratch)"
n="$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')"
ok "git status: $n path(s) uncommitted on $(git branch --show-current 2>/dev/null) (check they are all yours)"

if [ "$fails" -eq 0 ]; then echo "VERIFY_OK"; else echo "VERIFY_FAILED ($fails)"; exit 1; fi
