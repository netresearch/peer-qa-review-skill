#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: Netresearch DTT GmbH
#
# Behavioural tests for skills/peer-qa-review/scripts/qa-gather.sh.
#
# A stub `uv` first on PATH records every call instead of running Python, and
# fake plugin trees under a temporary HOME / CLAUDE_PLUGIN_ROOT stand in for
# the jira-communication skill. Offline; needs bash, find and coreutils.
# The script under test runs with the same bash as this file ("$BASH"), so
# running this file with another bash tests the script with that bash too.
#
# Each check prints `ok` or `FAIL`; the file exits 1 when any check failed.

set -uo pipefail

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
SCRIPT="$ROOT/skills/peer-qa-review/scripts/qa-gather.sh"
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
FAILS=0
CASE=0

mkdir -p "$TMP/bin"
cat >"$TMP/bin/uv" <<'EOF'
#!/usr/bin/env bash
# Test stub: append one line per call, arguments joined by '|'.
line="uv"
for a in "$@"; do line="$line|$a"; done
echo "$line" >>"$UV_LOG"
# UV_FAIL: exit 1 when any argument contains this text.
if [[ -n "${UV_FAIL:-}" ]]; then
    for a in "$@"; do
        [[ "$a" == *"$UV_FAIL"* ]] && exit 1
    done
fi
exit "${UV_EXIT:-0}"
EOF
chmod +x "$TMP/bin/uv"

ok() { echo "ok   $1"; }
fail() {
    echo "FAIL $1"
    echo "     exit: $RC"
    echo "     stdout: $OUT"
    echo "     stderr: $ERR"
    echo "     uv calls: $LOG"
    FAILS=$((FAILS + 1))
}
check() { # check <description> <condition...>
    local desc=$1
    shift
    if "$@"; then ok "$desc"; else fail "$desc"; fi
}

# new_case: sets d to a fresh directory with an empty HOME for one case.
new_case() {
    CASE=$((CASE + 1))
    d="$TMP/case$CASE"
    mkdir -p "$d/home"
}

# jira_tree <base> <script>...: fake jira-communication skill below <base>,
# e.g. jira_tree "$d" utility/jira-qa-gather.py core/jira-issue.py
jira_tree() {
    local base=$1 f
    shift
    for f in "$@"; do
        mkdir -p "$base/skills/jira-communication/scripts/$(dirname "$f")"
        : >"$base/skills/jira-communication/scripts/$f"
    done
}

# run <case dir> <CLAUDE_PLUGIN_ROOT> [args...]: sets RC, OUT, ERR, LOG.
run() {
    local dir=$1 plugin_root=$2
    shift 2
    : >"$dir/uv.log"
    OUT=$(HOME="$dir/home" CLAUDE_PLUGIN_ROOT="$plugin_root" \
        UV_LOG="$dir/uv.log" PATH="$TMP/bin:$PATH" \
        "$BASH" "$SCRIPT" "$@" 2>"$dir/err")
    RC=$?
    ERR=$(<"$dir/err")
    LOG=$(<"$dir/uv.log")
}

has() { [[ "$1" == *"$2"* ]]; }
eq() { [[ "$1" == "$2" ]]; }

# --- usage ---------------------------------------------------------------
new_case
run "$d" ""
check "no argument exits 64" eq "$RC" 64
check "no argument prints the usage line" has "$ERR" "usage: qa-gather.sh <ISSUE-KEY>"
check "no argument runs nothing" eq "$LOG" ""

# --- preferred script ----------------------------------------------------
new_case
jira_tree "$d/plugin" utility/jira-qa-gather.py utility/qa-gather.py core/jira-issue.py
run "$d" "$d/plugin" ABC-1
check "jira-qa-gather.py is preferred over qa-gather.py and the fallback" \
    eq "$LOG" "uv|run|$d/plugin/skills/jira-communication/scripts/utility/jira-qa-gather.py|ABC-1"
check "the preferred script's exit status is returned" eq "$RC" 0

new_case
jira_tree "$d/plugin" utility/qa-gather.py
run "$d" "$d/plugin" ABC-2
check "the legacy qa-gather.py is used when jira-qa-gather.py is absent" \
    eq "$LOG" "uv|run|$d/plugin/skills/jira-communication/scripts/utility/qa-gather.py|ABC-2"

new_case
jira_tree "$d/plugin" utility/jira-qa-gather.py
run "$d" "$d/plugin" ABC-3 --json --max-siblings 3
check "extra arguments are passed through in order" \
    eq "$LOG" "uv|run|$d/plugin/skills/jira-communication/scripts/utility/jira-qa-gather.py|ABC-3|--json|--max-siblings|3"

new_case
jira_tree "$d/plugin" utility/jira-qa-gather.py
UV_EXIT=3 run "$d" "$d/plugin" ABC-4
check "a failing preferred script's exit status is returned" eq "$RC" 3

new_case
jira_tree "$d/home/.claude/plugins/cache/netresearch-claude-code-marketplace/jira-integration/3.32.3" \
    utility/jira-qa-gather.py
run "$d" "" ABC-5
check "the marketplace install under HOME is found without CLAUDE_PLUGIN_ROOT" \
    eq "$LOG" "uv|run|$d/home/.claude/plugins/cache/netresearch-claude-code-marketplace/jira-integration/3.32.3/skills/jira-communication/scripts/utility/jira-qa-gather.py|ABC-5"

# --- fallback ------------------------------------------------------------
fallback_calls() { # expected uv calls of the fallback for <scripts dir> <key>
    printf 'uv|run|%s/core/jira-issue.py|get|%s\nuv|run|%s/workflow/jira-comment.py|list|%s\nuv|run|%s/core/jira-worklog.py|list|%s' \
        "$1" "$2" "$1" "$2" "$1" "$2"
}

new_case
jira_tree "$d/plugin" core/jira-issue.py workflow/jira-comment.py core/jira-worklog.py
run "$d" "$d/plugin" ABC-6
S="$d/plugin/skills/jira-communication/scripts"
check "fallback exits 0" eq "$RC" 0
check "fallback announces itself on stderr" has "$ERR" "falling back to multi-call discovery"
check "fallback runs issue, comments and worklog in order" eq "$LOG" "$(fallback_calls "$S" ABC-6)"
check "fallback labels the three sections" \
    eq "$OUT" "$(printf '=== ISSUE ===\n=== COMMENTS ===\n=== WORKLOG ===')"

new_case
jira_tree "$d/plugin" core/jira-issue.py workflow/jira-comment.py core/jira-worklog.py
UV_FAIL=jira-worklog.py run "$d" "$d/plugin" ABC-7
check "fallback tolerates a failing worklog call" eq "$RC" 0

new_case
jira_tree "$d/plugin" core/jira-issue.py workflow/jira-comment.py core/jira-worklog.py
UV_FAIL=jira-issue.py run "$d" "$d/plugin" ABC-8
check "fallback fails when the issue call fails" eq "$RC" 1
check "fallback stops after a failing issue call" \
    eq "$LOG" "uv|run|$d/plugin/skills/jira-communication/scripts/core/jira-issue.py|get|ABC-8"

# --- nothing installed ---------------------------------------------------
new_case
run "$d" "" ABC-9
check "no jira-communication skill exits 1" eq "$RC" 1
check "no jira-communication skill prints the install hint" \
    has "$ERR" "Could not find the jira-communication skill"
check "no jira-communication skill runs nothing" eq "$LOG" ""

if [[ $FAILS -gt 0 ]]; then
    echo "$FAILS check(s) failed"
    exit 1
fi
echo "all checks passed"
