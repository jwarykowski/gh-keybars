# gh-keybars

A gh extension (one bash script, `gh-keybars`) that polls GitHub and sends
what changed on your pull requests to keybars Pro as its GitHub events.
README.md has the detail; this file is what to keep in mind while working
here.

## Commands

- `make check`: shellcheck, then the tests, which put a fake `gh` (it
  prints what `--jq` would) and a fake `keybars-pro` on PATH.
- `GH_KEYBARS_STATE=/tmp/x ./gh-keybars once -n` twice checks against the
  real GitHub and prints what it would send.

## Keep in mind

- gh only installs extensions from repositories named `gh-<name>`, with an
  executable of the same name at the top.
- bash 3.2 (macOS): no associative arrays; the diff is in awk.
- The events and their branches must match what keybars Pro's GitHub
  connection sends (the relay's GitHub provider): checks carry the head
  branch; reviews, review requests and merges the base branch; the
  repository is `owner/name`. A rename there breaks the packs here.
- It searches rather than reading `viewer.pullRequests`: SAML-protected
  organisations return null nodes and errors there, which stop gh's `--jq`.

## Related repos (in ~/development)

- `keybars-pro`: the app, the `keybars-pro` command and the GitHub packs
  (`internal/market/defaults`).
- `relay`: the GitHub provider whose events this mirrors.
