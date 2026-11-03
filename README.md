# gh-keybars

A [GitHub CLI](https://cli.github.com) extension that puts your pull
requests on the keyboard through [keybars Pro](https://keybars.app/pro/),
with no webhooks to set up: it checks GitHub every minute and sends what
changed.

On your pull requests:

- checks running, passed or failed: `ci.running`, `ci.passed`, `ci.failed`
- a review approved, or asking for changes: `review.approved`,
  `review.changes_requested`
- merged: `pull_request.merged`

And `pull_request.review_requested` when someone asks for your review.

They're the events keybars Pro's GitHub connection sends, from GitHub, so
the marketplace's GitHub packs play them as they are. Use this or the
connection for a repository, not both, or you'll see things twice.

## requirements

- keybars Pro running, with its command installed: App settings, Command
  line, **Install the command-line tool**
- gh, signed in (`gh auth login`); Linux or macOS

## install

```sh
gh extension install jwarykowski/gh-keybars
keybars-pro market install github-ci-pack review-nudges merge-confetti
gh keybars start
```

## use

| command | |
|---|---|
| `gh keybars start [-i seconds]` | watch in the background, every minute or every `-i` seconds (15 or more) |
| `gh keybars stop` | stop it |
| `gh keybars status` | whether it's watching |
| `gh keybars watch [-i seconds]` | watch in this terminal |
| `gh keybars once [-n]` | check now; `-n` prints the events instead of sending them |

The first check only notes where things are, so starting doesn't replay
old news. It looks at pull requests you opened that were updated in the
last week. Ones in organisations that enforce SAML are left out until your
gh token is authorised for them (GitHub, Settings, Applications).

State and the log live in `~/.local/state/gh-keybars` (`$XDG_STATE_HOME`).

## development

`make check` runs shellcheck and the tests, which answer for gh and log
what would be sent to keybars Pro.

## licence

MIT
