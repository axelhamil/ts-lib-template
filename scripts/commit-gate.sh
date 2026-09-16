#!/usr/bin/env bash
# PreToolUse helper: refuse git commit while scripts/skills.sh is red.
# Reads the Claude tool-call JSON on stdin. Exit 0 allows, 2 denies.
#
# Fail closed: missing jq still denies. A matcher of adjacent "git commit" lets
# `git -C . commit` and `bash -c 'git commit'` through — parse argv, then fall
# back to "git appears and commit is a word".
set -uo pipefail

repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)

emit_deny() {
  local reason=$1
  if command -v jq >/dev/null 2>&1; then
    printf '%s' "$reason" | jq -Rs '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"deny",permissionDecisionReason:.}}'
  else
    local escaped
    escaped=$(printf '%s' "$reason" | awk 'BEGIN{ORS=""} {
      gsub(/\\/,"\\\\"); gsub(/"/,"\\\""); gsub(/\t/,"\\t")
      if (NR > 1) printf "\\n"
      printf "%s", $0
    }')
    printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"%s"}}\n' "$escaped"
  fi
  exit 2
}

if ! command -v jq >/dev/null 2>&1; then
  emit_deny "jq is required for the commit gate (AGENTS.md § The skill loop)."
fi

payload=$(cat)
cmd=$(jq -r '.tool_input.command // empty' <<<"$payload")
[[ -z $cmd ]] && exit 0

# Returns 0 if any list/pipeline segment is `git [global-opts] commit`.
is_git_commit_argv() {
  local line bin
  while IFS= read -r line; do
    line=${line#"${line%%[![:space:]]*}"}
    line=${line%"${line##*[![:space:]]}"}
    [[ -z $line ]] && continue

    # Word-split. Quoted paths are not the cases the gate exists for.
    # shellcheck disable=SC2086
    set -- $line
    while [[ $# -gt 0 ]]; do
      case $1 in
        *=*) shift ;;
        command | exec | env) shift ;;
        *) break ;;
      esac
    done
    [[ $# -eq 0 ]] && continue
    bin=${1##*/}
    [[ $bin == git ]] || continue
    shift
    while [[ $# -gt 0 ]]; do
      case $1 in
        commit) return 0 ;;
        -C | -c | --git-dir | --work-tree | --namespace | --config-env | --exec-path)
          shift 2 || return 1
          ;;
        --*=*) shift ;;
        --*) shift ;;
        -*) shift ;;
        *) break ;;
      esac
    done
    [[ ${1-} == commit ]] && return 0
  done < <(printf '%s\n' "$1" | sed 's/&&/\n/g; s/||/\n/g; s/;/\n/g; s/|/\n/g')
  return 1
}

# Catches `bash -c 'git commit'` which argv-parsing of the outer command misses.
# `git log --grep=commit` does not match: commit is not a word.
is_git_commit_words() {
  grep -Eq '(^|[;&|[:space:]])([^[:space:]]*/)?git([[:space:]]|$)' <<<"$1" \
    && grep -Eq "(^|[[:space:]'\"])commit([[:space:]'\"]|$)" <<<"$1"
}

if ! is_git_commit_argv "$cmd" && ! is_git_commit_words "$cmd"; then
  exit 0
fi

if out=$("$repo_root/scripts/skills.sh" 2>&1); then
  exit 0
fi

emit_deny "$out"
