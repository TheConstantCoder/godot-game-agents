#!/usr/bin/env bash
# Installs Godot Game Agents into a Godot project.
#   ./install.sh <project folder> [--agents-only] [--force]
# Copies:
#   agents/*.md          -> <project>/.claude/agents/
#   skills/*             -> <project>/.claude/skills/
#   (unless --agents-only)
#   tools/*              -> <project>/tools/
#   hooks/*.sh           -> <project>/.claude/hooks/
#   templates/AGENTS.md  -> <project>/AGENTS.md          (only if missing)
#   templates/docs/*     -> <project>/docs/              (only if missing)
#   templates/tickets/*  -> <project>/tickets/           (only if missing)
# Existing files are never overwritten unless --force is given (templates never are).
# Hooks are copied but not switched on: merge hooks/settings.example.json into
# <project>/.claude/settings.json yourself.
set -euo pipefail
src="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
dest="${1:-}"
[ -n "$dest" ] && [ -d "$dest" ] || { echo "usage: $0 <project folder> [--agents-only] [--force]" >&2; exit 1; }
dest="$(cd "$dest" && pwd)"
shift
agents_only=0; force=0
for a in "$@"; do
	case "$a" in
		--agents-only) agents_only=1 ;;
		--force) force=1 ;;
		*) echo "unknown option $a" >&2; exit 1 ;;
	esac
done
[ -f "$dest/project.godot" ] || echo "note: no project.godot in $dest (installing anyway)"

copied=0; skipped=0
put() { # $1 source file, $2 destination file, $3 = "template" to never overwrite
	mkdir -p "$(dirname "$2")"
	if [ -e "$2" ] && { [ "${3:-}" = template ] || [ "$force" -eq 0 ]; }; then
		echo "skip  ${2#"$dest"/} (exists)"; skipped=$((skipped + 1)); return
	fi
	cp "$1" "$2"; echo "add   ${2#"$dest"/}"; copied=$((copied + 1))
}

for f in "$src"/agents/*.md; do put "$f" "$dest/.claude/agents/$(basename "$f")"; done
for d in "$src"/skills/*/; do
	name="$(basename "$d")"
	for f in "$d"*; do put "$f" "$dest/.claude/skills/$name/$(basename "$f")"; done
done

if [ "$agents_only" -eq 0 ]; then
	for f in "$src"/tools/*; do put "$f" "$dest/tools/$(basename "$f")"; done
	for f in "$src"/hooks/*.sh; do put "$f" "$dest/.claude/hooks/$(basename "$f")"; done
	chmod +x "$dest"/tools/*.sh "$dest"/tools/*.py "$dest"/.claude/hooks/*.sh 2>/dev/null || true
	put "$src/templates/AGENTS.md" "$dest/AGENTS.md" template
	for f in "$src"/templates/docs/*.md; do put "$f" "$dest/docs/$(basename "$f")" template; done
	put "$src/templates/tickets/README.md" "$dest/tickets/README.md" template
fi

echo
echo "done: $copied added, $skipped skipped."
echo "next:"
echo "  1. Fill in 'Project settings' in AGENTS.md, and add '@AGENTS.md' to CLAUDE.md."
echo "  2. export GODOT_BIN=/path/to/Godot   (then: tools/verify.sh)"
echo "  3. Optional hooks: merge hooks/settings.example.json into .claude/settings.json."
echo "  4. Add .claude/worktrees/ to .gitignore."
