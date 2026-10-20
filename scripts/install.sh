#!/usr/bin/env bash
# Turn on toolkit plugins for a project or for this whole machine.
#
#   install.sh [--project DIR | --global] [GROUP|PLUGIN ...]
#
# GROUP is a marketplace category (core, platform) or "all". Defaults to "core".
#
# Examples:
#   ./scripts/install.sh --project ~/code/my-app core vercel neon
#   curl -fsSL https://raw.githubusercontent.com/nguyeehub/claude-toolkit/main/scripts/install.sh \
#     | bash -s -- --global all
set -euo pipefail

REPO="${TOOLKIT_REPO:-nguyeehub/claude-toolkit}"
REF="${TOOLKIT_REF:-main}"
MARKETPLACE="claude-toolkit"

scope=global
project_dir=""
selectors=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    --global) scope=global ;;
    --project) scope=project; project_dir="${2:?--project needs a directory}"; shift ;;
    -h|--help) sed -n '2,12p' "$0"; exit 0 ;;
    *) selectors+=("$1") ;;
  esac
  shift
done
[[ ${#selectors[@]} -eq 0 ]] && selectors=(core)

# Read marketplace.json from this checkout, or from GitHub when piped through curl.
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd || true)"
local_manifest="$script_dir/../.claude-plugin/marketplace.json"
if [[ -f "$local_manifest" ]]; then
  manifest="$(cat "$local_manifest")"
else
  manifest="$(curl -fsSL "https://raw.githubusercontent.com/$REPO/$REF/.claude-plugin/marketplace.json")"
fi

if [[ $scope == project ]]; then
  settings="$project_dir/.claude/settings.json"
else
  settings="${CLAUDE_CONFIG_DIR:-$HOME/.claude}/settings.json"
fi
mkdir -p "$(dirname "$settings")"

plugins="$(MANIFEST="$manifest" SETTINGS="$settings" REPO="$REPO" MARKETPLACE="$MARKETPLACE" \
  python3 - "${selectors[@]}" <<'PY'
import json, os, sys

manifest = json.loads(os.environ["MANIFEST"])
by_name = {p["name"]: p for p in manifest["plugins"]}

chosen = []
for sel in sys.argv[1:]:
    if sel == "all":
        names = list(by_name)
    elif sel in by_name:
        names = [sel]
    else:
        names = [n for n, p in by_name.items() if p.get("category") == sel]
        if not names:
            sys.exit(f"unknown plugin or group: {sel} (have: {', '.join(by_name)})")
    chosen += [n for n in names if n not in chosen]

path = os.environ["SETTINGS"]
try:
    with open(path) as f:
        settings = json.load(f)
except FileNotFoundError:
    settings = {}

mp = os.environ["MARKETPLACE"]
settings.setdefault("extraKnownMarketplaces", {})[mp] = {
    "source": {"source": "github", "repo": os.environ["REPO"]}
}
enabled = settings.setdefault("enabledPlugins", {})
for name in chosen:
    enabled[f"{name}@{mp}"] = True

with open(path, "w") as f:
    json.dump(settings, f, indent=2)
    f.write("\n")

print(" ".join(chosen))
PY
)"

echo "Enabled in $settings: $plugins"

# For a machine-wide install, also install now so the first session doesn't wait.
# A project only needs its settings file: Claude Code installs from it when the project opens.
if [[ $scope == global ]] && command -v claude >/dev/null 2>&1; then
  claude plugin marketplace add "$REPO" >/dev/null 2>&1 || claude plugin marketplace update "$MARKETPLACE" >/dev/null 2>&1 || true
  for p in $plugins; do
    claude plugin install "$p@$MARKETPLACE" --scope user >/dev/null 2>&1 \
      && echo "installed $p" || echo "could not install $p now; Claude Code will retry at startup"
  done
fi
