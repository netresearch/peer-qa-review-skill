#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: Netresearch DTT GmbH
#
# Stage 0 single-call discovery for peer-qa-review.
#
# Delegates to the jira-communication skill's jira-qa-gather.py (named
# qa-gather.py before jira-integration 3.13) if available. It searches
# below $CLAUDE_PLUGIN_ROOT, then
# $HOME/.claude/plugins/cache/netresearch-claude-code-marketplace/jira-integration,
# then $HOME/.claude/plugins/cache; PATH is not searched.
#
# Falls back to a multi-call sequence using core jira-communication scripts
# (jira-issue.py, jira-comment.py, jira-worklog.py) if neither is installed;
# the fallback ignores extra arguments such as --json.
#
# Usage:
#   qa-gather.sh <ISSUE-KEY> [--json|--no-siblings|--max-siblings N|...]
#
# Exits with the underlying script's status. Prints a friendly hint to
# stderr and exits 1 if neither script nor the fallback scripts are found.

set -euo pipefail

if [[ $# -lt 1 ]]; then
    echo "usage: qa-gather.sh <ISSUE-KEY> [--json|--no-siblings|--max-siblings N|...]" >&2
    exit 64
fi

ISSUE_KEY="$1"
shift
EXTRA_ARGS=("$@")

# Preferred: qa-gather.py from jira-communication skill.
find_qa_gather() {
    local search_paths=(
        "${CLAUDE_PLUGIN_ROOT:-}"
        "${HOME}/.claude/plugins/cache/netresearch-claude-code-marketplace/jira-integration"
        "${HOME}/.claude/plugins/cache"
    )
    # Prefer the current script name (jira-integration >= 3.13) over the
    # legacy one: one find per name in explicit preference order, stopping
    # at the first hit (`-print -quit`). Which copy wins *within* one search
    # root still follows find's traversal order; the guarantee here is the
    # name preference plus the early stop — and no `| head` pipeline, so no
    # SIGPIPE risk under `set -o pipefail`.
    # -maxdepth 8 reaches <marketplace>/<plugin>/<version>/skills/
    # jira-communication/scripts/utility/<name> below a plugin cache root.
    local p name found
    for p in "${search_paths[@]}"; do
        [[ -z "$p" ]] && continue
        for name in jira-qa-gather.py qa-gather.py; do
            found=$(find "$p" -maxdepth 8 -type f \
                -path "*/skills/jira-communication/scripts/utility/${name}" \
                -print -quit 2>/dev/null) || true
            if [[ -n "$found" ]]; then
                echo "$found"
                return 0
            fi
        done
    done
    return 1
}

# Fallback: best-effort using core scripts. Same skill base, older version.
find_jira_scripts_dir() {
    local search_paths=(
        "${CLAUDE_PLUGIN_ROOT:-}"
        "${HOME}/.claude/plugins/cache/netresearch-claude-code-marketplace/jira-integration"
        "${HOME}/.claude/plugins/cache"
    )
    local p found
    for p in "${search_paths[@]}"; do
        [[ -z "$p" ]] && continue
        found=$(find "$p" -maxdepth 8 -type f \
            -path '*/skills/jira-communication/scripts/core/jira-issue.py' \
            -print -quit 2>/dev/null) || true
        if [[ -n "$found" ]]; then
            dirname "$(dirname "$found")"
            return 0
        fi
    done
    return 1
}

if QA_GATHER_PATH=$(find_qa_gather); then
    # ${EXTRA_ARGS[@]+...}: bash < 4.4 (macOS /bin/bash is 3.2) treats an
    # empty array as unbound under `set -u`.
    exec uv run "$QA_GATHER_PATH" "$ISSUE_KEY" ${EXTRA_ARGS[@]+"${EXTRA_ARGS[@]}"}
fi

# Fallback path
if SCRIPTS_DIR=$(find_jira_scripts_dir); then
    echo "[qa-gather] qa-gather.py not found; falling back to multi-call discovery" >&2
    echo "=== ISSUE ===" && uv run "${SCRIPTS_DIR}/core/jira-issue.py" get "$ISSUE_KEY"
    echo "=== COMMENTS ===" && uv run "${SCRIPTS_DIR}/workflow/jira-comment.py" list "$ISSUE_KEY"
    echo "=== WORKLOG ===" && uv run "${SCRIPTS_DIR}/core/jira-worklog.py" list "$ISSUE_KEY" 2>/dev/null || true
    exit 0
fi

cat >&2 <<'EOF'
[qa-gather] Could not find the jira-communication skill.

Install it from:
  https://github.com/netresearch/jira-skill

Or if it's installed in a non-standard location, set:
  export CLAUDE_PLUGIN_ROOT=/path/to/your/claude/plugins/cache
EOF
exit 1
