#!/usr/bin/env bash
# Report the state of the skill library, and fail loudly when its shape is wrong.
#
# This is the only deterministic part of the skill lifecycle in this repository
# (see .agents/skills/skill-lifecycle/SKILL.md). Capture, promotion and amendment
# are enforced by instructions a model can talk itself out of; this script is
# what a machine can check without believing anyone.
#
# What it does NOT check: whether a skill is true, whether it was actually
# followed on the date it claims, or whether it earns the context it costs.
# This checks shape only.
#
# Usage: scripts/skills.sh [--stale-days N]   (default 90)

set -euo pipefail

repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
skills_dir="$repo_root/.agents/skills"
stale_days=90

while [[ $# -gt 0 ]]; do
  case "$1" in
    --stale-days) stale_days="${2:?--stale-days needs a number}"; shift 2 ;;
    *) echo "unknown argument: $1" >&2; exit 2 ;;
  esac
done

[[ -d $skills_dir ]] || { echo "no skill library at $skills_dir" >&2; exit 1; }

today_epoch=$(date +%s)
failures=0
drafts=0
proven=0

# The front matter only — the body of a skill quotes these keys in its
# templates, and a naive grep over the whole file reads the template as the
# declaration. That false positive cost a promotion its status line.
front_matter() {
  awk 'NR == 1 && $0 == "---" { inside = 1; next }
       inside && $0 == "---" { exit }
       inside' "$1"
}

hidden_from_model() {
  front_matter "$1" | grep -q '^disable-model-invocation: true'
}

# Age in days of a YYYY-MM-DD date, or -1 when the field carries no date
# ("never" is the legitimate value of last-followed on a fresh draft).
age_days() {
  local value=$1
  [[ $value =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]] || { echo -1; return; }
  local then_epoch
  then_epoch=$(date -d "$value" +%s 2>/dev/null) \
    || then_epoch=$(date -j -f '%Y-%m-%d' "$value" +%s 2>/dev/null) \
    || { echo -1; return; }
  echo $(( (today_epoch - then_epoch) / 86400 ))
}

printf '%-20s %-8s %5s  %-12s %-12s %s\n' NAME STATUS REV CAPTURED FOLLOWED NOTE

for dir in "$skills_dir"/*/; do
  name=$(basename "$dir")
  file="$dir/SKILL.md"

  if [[ ! -f $file ]]; then
    printf '%-20s %-8s %5s  %-12s %-12s %s\n' "$name" - - - - 'no SKILL.md'
    failures=$((failures + 1))
    continue
  fi

  line=$(grep -m1 '^> status:' "$file" || true)
  if [[ -z $line ]]; then
    printf '%-20s %-8s %5s  %-12s %-12s %s\n' "$name" - - - - 'no lifecycle line'
    failures=$((failures + 1))
    continue
  fi

  field() {
    awk -v k="$1" '{
      sub(/^> /, "")
      n = split($0, a, " · ")
      for (i = 1; i <= n; i++) {
        sep = index(a[i], ": ")
        if (sep == 0) continue
        if (substr(a[i], 1, sep - 1) == k) { print substr(a[i], sep + 2); exit }
      }
    }' <<<"$line"
  }
  status=$(field status)
  revision=$(field revision)
  captured=$(field captured)
  followed=$(field last-followed)

  note=""
  case "$status" in
    draft)
      drafts=$((drafts + 1))
      if ! hidden_from_model "$file"; then
        note="draft without disable-model-invocation"
        failures=$((failures + 1))
      fi
      ;;
    proven)
      proven=$((proven + 1))
      if hidden_from_model "$file"; then
        note="proven but still hidden from the model (deliberate for command-only skills)"
      fi
      ;;
    *)
      note="unknown status '$status'"
      failures=$((failures + 1))
      ;;
  esac

  clock=$followed
  [[ $(age_days "$followed") -lt 0 ]] && clock=$captured
  age=$(age_days "$clock")
  if [[ $age -ge $stale_days ]]; then
    note="${note:+$note; }stale: $age days — delete it, do not archive it"
    failures=$((failures + 1))
  fi

  printf '%-20s %-8s %5s  %-12s %-12s %s\n' \
    "$name" "$status" "${revision:--}" "${captured:--}" "${followed:--}" "$note"
done

echo
echo "$drafts draft(s), $proven proven, stale threshold ${stale_days}d"

if [[ $failures -gt 0 ]]; then
  echo "$failures problem(s) — the library is not in a shape anyone should trust" >&2
  exit 1
fi
