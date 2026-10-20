#!/usr/bin/env bash
# Install toolkit skills into any coding agent with `npx skills`.
#
#   install-skills.sh [--global] [--agent "cursor codex ..."] [GROUP|REPO ...]
#
# GROUP is a group from skills.txt (core, platform) or "all". Defaults to "core".
# --agent defaults to every agent `npx skills` supports.
#
# Examples:
#   ./scripts/install-skills.sh --agent "cursor codex" core
#   curl -fsSL https://raw.githubusercontent.com/nguyeehub/claude-toolkit/main/scripts/install-skills.sh \
#     | bash -s -- --global all
set -euo pipefail

REPO="${TOOLKIT_REPO:-nguyeehub/claude-toolkit}"
REF="${TOOLKIT_REF:-main}"

global=()
agents=('*')
selectors=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    -g|--global) global=(-g) ;;
    -a|--agent) read -r -a agents <<<"${2:?--agent needs a value}"; shift ;;
    -h|--help) sed -n '2,13p' "$0"; exit 0 ;;
    *) selectors+=("$1") ;;
  esac
  shift
done
[[ ${#selectors[@]} -eq 0 ]] && selectors=(core)

# Read skills.txt from this checkout, or from GitHub when piped through curl.
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd || true)"
if [[ -f "$script_dir/../skills.txt" ]]; then
  list="$(cat "$script_dir/../skills.txt")"
else
  list="$(curl -fsSL "https://raw.githubusercontent.com/$REPO/$REF/skills.txt")"
fi

repos=()
for sel in "${selectors[@]}"; do
  matched=0
  while read -r repo group _; do
    [[ -z "$repo" || "$repo" == \#* ]] && continue
    if [[ $sel == all || $sel == "$group" || $sel == "$repo" ]]; then
      matched=1
      [[ " ${repos[*]-} " == *" $repo "* ]] || repos+=("$repo")
    fi
  done <<<"$list"
  if [[ $matched == 0 ]]; then
    echo "unknown group or repo: $sel (see skills.txt)" >&2
    exit 1
  fi
done

failed=()
for repo in "${repos[@]}"; do
  source="$repo"
  # Use this checkout for the toolkit's own skills, and skip it while it has none.
  if [[ $repo == "$REPO" && -d "$script_dir/../skills" ]]; then
    if ! find "$script_dir/../skills" -name SKILL.md | grep -q .; then
      echo "==> $repo: no skills in skills/ yet, skipping"
      continue
    fi
    source="$(cd "$script_dir/.." && pwd)"
  fi
  echo "==> $repo"
  npx -y skills add "$source" --skill '*' --agent "${agents[@]}" ${global[@]+"${global[@]}"} --yes \
    || failed+=("$repo")
done

if [[ ${#failed[@]} -gt 0 ]]; then
  echo "Could not install: ${failed[*]}" >&2
  exit 1
fi
