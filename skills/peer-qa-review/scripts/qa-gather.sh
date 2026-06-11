#!/usr/bin/env bash
# Stage 0 single-call discovery for peer-qa-review.
#
# Delegates to the jira-communication skill's qa-gather.py if available
# (locates it via CLAUDE_PLUGIN_ROOT, $HOME/.claude/plugins, or PATH).
#
# Falls back to a multi-call sequence using core jira-communication scripts
# if qa-gather.py is not yet installed (older skill version).
#
# Usage:
#   qa-gather.sh <ISSUE-KEY> [--json]
#
# Exits with the underlying script's status. Prints a friendly hint to
# stderr if neither qa-gather.py nor the fallback scripts can be found.

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
    # legacy one, deterministically: one find per name, first match wins.
    # `-print -quit` stops at the first hit — no `| head` pipeline, so no
    # SIGPIPE risk under `set -o pipefail`.
    local p name found
    for p in "${search_paths[@]}"; do
        [[ -z "$p" ]] && continue
        for name in jira-qa-gather.py qa-gather.py; do
            found=$(find "$p" -maxdepth 6 -type f \
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
    local p
    for p in "${search_paths[@]}"; do
        [[ -z "$p" ]] && continue
        local found
        found=$(find "$p" -maxdepth 6 -path '*/skills/jira-communication/scripts/core/jira-issue.py' 2>/dev/null | head -n1)
        if [[ -n "$found" ]]; then
            dirname "$(dirname "$found")"
            return 0
        fi
    done
    return 1
}

if QA_GATHER_PATH=$(find_qa_gather); then
    exec uv run "$QA_GATHER_PATH" "$ISSUE_KEY" "${EXTRA_ARGS[@]}"
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
