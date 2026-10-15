#!/usr/bin/env bash
# Check the agent-agnostic topology. Shape only, never whether the content is true.
# Calls scripts/skills.sh so a green run is enough for CI and for the commit gate.

set -euo pipefail

repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
cd "$repo_root"

fail=0
note() { printf '  %s\n' "$1"; fail=1; }

[ -f AGENTS.md ] || note "AGENTS.md missing"
lines=$(wc -l < AGENTS.md)
[ "$lines" -le 200 ] || note "AGENTS.md is $lines lines (target <= 200), split it"

claude_files=$(find . \( -name node_modules -o -name .git -o -name dist -o -name coverage \) -prune -o \
  \( -name CLAUDE.md -o -name CLAUDE.local.md \) -print)
[ -z "$claude_files" ] || note "CLAUDE file found, Claude Code would ignore AGENTS.md: $(echo $claude_files)"

if [ -e .claude/skills ]; then
  [ -L .claude/skills ] || note ".claude/skills exists and is not a symlink, duplicated content"
  mode=$(git ls-files -s .claude/skills | awk '{print $1}')
  if [ -n "$mode" ]; then
    [ "$mode" = "120000" ] || note ".claude/skills is tracked outside mode 120000, broken on clone"
  fi
else
  note "no .claude/skills symlink, Claude Code will not auto-load skills"
fi

[ -d .agents/skills ] || note ".agents/skills missing"

if [ "$fail" -ne 0 ]; then
  echo "agent topology: FAIL"
  exit 1
fi

echo "agent topology: OK"
exec "$repo_root/scripts/skills.sh"
