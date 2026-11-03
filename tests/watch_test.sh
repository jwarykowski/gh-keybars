#!/bin/sh
# ok and FAIL lines never fail
# shellcheck disable=SC2015
# gh-keybars once, against a fake gh that answers with what GitHub would,
# and a fake keybars-pro that logs its arguments.
set -eu

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
root=$(cd "$(dirname "$0")/.." && pwd)
log="$tmp/keybars.log"
export KEYBARS_PRO="$tmp/keybars-pro" GH_KEYBARS_STATE="$tmp/state"
mkdir "$tmp/bin"
printf '#!/bin/sh\necho "$*" >>"%s"\n' "$log" >"$KEYBARS_PRO"
# gh api graphql prints what's in $tmp/github, as --jq would
printf '#!/bin/sh\ncat "%s/github"\n' "$tmp" >"$tmp/bin/gh"
chmod +x "$KEYBARS_PRO" "$tmp/bin/gh"
PATH="$tmp/bin:$PATH"

fails=0
github() { printf '%s\n' "$@" | tr '|' '\t' >"$tmp/github"; }
want() {
  if [ "$(cat "$log" 2>/dev/null)" = "$2" ]; then
    echo "ok: $1"
  else
    printf 'FAIL: %s\nwant:\n%s\ngot:\n%s\n' "$1" "$2" "$(cat "$log" 2>/dev/null)" >&2
    fails=$((fails + 1))
  fi
  : >"$log"
}

github "pr|me/shop|1|OPEN|PENDING||feat/cart|main" "pr|me/shop|2|OPEN|SUCCESS|REVIEW_REQUIRED|fix/tax|main" \
  "ask|you/blog|9|||||main"
"$root/gh-keybars" once
want "the first check only remembers" ""

github "pr|me/shop|1|OPEN|FAILURE||feat/cart|main" "pr|me/shop|2|OPEN|SUCCESS|APPROVED|fix/tax|main" \
  "ask|you/blog|9|||||main" "ask|you/blog|10|||||main"
"$root/gh-keybars" once
want "what changed" "alert -q -source github -repo me/shop -branch feat/cart ci.failed
alert -q -source github -repo me/shop -branch main review.approved
alert -q -source github -repo you/blog -branch main pull_request.review_requested"

"$root/gh-keybars" once
want "nothing changed" ""

github "pr|me/shop|1|OPEN|PENDING||feat/cart|main" "pr|me/shop|2|MERGED|SUCCESS|APPROVED|fix/tax|main" \
  "pr|me/shop|3|OPEN|PENDING||feat/new|main"
out=$("$root/gh-keybars" once -n)
want "-n sends nothing" ""
if [ "$out" = "ci.running me/shop feat/cart
pull_request.merged me/shop main
ci.running me/shop feat/new" ]; then echo "ok: -n prints them"; else printf 'FAIL: -n printed:\n%s\n' "$out" >&2; fails=$((fails + 1)); fi
"$root/gh-keybars" once
want "-n didn't use them up" "alert -q -source github -repo me/shop -branch feat/cart ci.running
alert -q -source github -repo me/shop -branch main pull_request.merged
alert -q -source github -repo me/shop -branch feat/new ci.running"

printf '#!/bin/sh\nexit 1\n' >"$tmp/bin/gh"
if "$root/gh-keybars" once 2>/dev/null; then echo "FAIL: GitHub down went unnoticed" >&2; fails=$((fails + 1)); else echo "ok: GitHub down fails"; fi
"$root/gh-keybars" start -i 15 >/dev/null
"$root/gh-keybars" status | grep -q "^watching" && echo "ok: start" || { echo "FAIL: not watching" >&2; fails=$((fails + 1)); }
"$root/gh-keybars" start 2>/dev/null && { echo "FAIL: started twice" >&2; fails=$((fails + 1)); } || echo "ok: starts once"
"$root/gh-keybars" stop >/dev/null
"$root/gh-keybars" status | grep -q "^not watching" && echo "ok: stop" || { echo "FAIL: still watching" >&2; fails=$((fails + 1)); }
"$root/gh-keybars" start -i 5 2>/dev/null && { echo "FAIL: took -i 5" >&2; fails=$((fails + 1)); } || echo "ok: -i 15 or more"
"$root/gh-keybars" nonsense 2>/dev/null && fails=$((fails + 1)) || echo "ok: usage on nonsense"

[ "$fails" -eq 0 ] || {
  echo "$fails failed" >&2
  exit 1
}
