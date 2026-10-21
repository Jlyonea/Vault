#!/bin/sh
# Shared helpers for vault git hooks. Protected branch patterns: protected-branches.txt (extended regex, case-insensitive).

VAULT_HOOKS_DIR=${0%/*}
PROTECTED_FILE="$VAULT_HOOKS_DIR/protected-branches.txt"

block() {
	echo "" >&2
	echo "[vault guardrail] BLOCKED: $1" >&2
	echo "[vault guardrail] Protected branches only change through Pull Request." >&2
	echo "" >&2
	exit 1
}

# Fail closed: if a check cannot run, the operation is blocked.
PROTECTED_PATTERNS=$(tr -d '\r' < "$PROTECTED_FILE")
[ -n "$PROTECTED_PATTERNS" ] || block "could not load protected branch patterns from '$PROTECTED_FILE'."

is_protected() {
	[ -n "$1" ] || return 1
	result=$(printf '%s\n' "$1" | grep -Eiq -e "$PROTECTED_PATTERNS"; echo "rc=$?")
	case $result in
		rc=0) return 0 ;;
		rc=1) return 1 ;;
		*) block "could not check branch '$1' against protected patterns." ;;
	esac
}

# Sets CURRENT_BRANCH (empty on detached HEAD).
read_current_branch() {
	head_info=$(git symbolic-ref --short -q HEAD; echo "rc=$?")
	case $head_info in
		rc=1) CURRENT_BRANCH= ;;
		*rc=0) CURRENT_BRANCH=${head_info%?rc=0} ;;
		*) block "could not read the current branch." ;;
	esac
}

# Runs the repository's own hook (.git/hooks/<name>) so local hooks keep working.
run_local_hook() {
	[ "$VAULT_HOOK_CHAINED" = 1 ] && return 0
	name=$1
	shift
	local_hook="$(git rev-parse --git-common-dir)/hooks/$name"
	if [ -x "$local_hook" ]; then
		VAULT_HOOK_CHAINED=1 "$local_hook" "$@" || exit $?
	fi
}
