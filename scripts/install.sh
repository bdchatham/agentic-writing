#!/usr/bin/env bash
# install.sh — set up the agentic-writing toolkit, on a machine or in a repository.
#
# agentic-writing is a PUBLIC repository, so the fetch needs no auth.
#
#   # a machine, once: styles, the fallback Vale config, the artifact builder
#   curl -fsSL https://raw.githubusercontent.com/bdchatham/agentic-writing/main/scripts/install.sh | bash
#
#   # a repository, once: .vale.ini and a CI job, which you then commit
#   curl -fsSL .../scripts/install.sh | bash -s -- repo
#
#   # what a mode would do, without doing it
#   curl -fsSL .../scripts/install.sh | bash -s -- repo --dry-run
#
# THE TWO MODES DIFFER, AND THE DIFFERENCE MATTERS FOR CI.
#
#   machine   Writes outside any repository: a checkout, the user-level Vale
#             config that applies when a repository has none, and a symlink so
#             `vale` resolves the styles from any directory. Nothing it writes
#             reaches CI, because a CI runner has no home directory of yours.
#
#   repo      Writes files you commit. This is what makes the checks run for
#             everyone, on every branch, without each person installing
#             anything. Run it once per repository, not once per pull request.
#
# STYLES ARE FETCHED, NOT VENDORED. A consuming repository holds a .vale.ini and
# a pinned ref, and CI fetches the rules at that ref. The alternative copies 350K
# of rules into every repository, where each copy drifts until someone re-runs
# this script. Fetching keeps one source of truth, which is this repository's
# whole argument, and a pin keeps the fetch reproducible. The trade is that CI
# needs network, and a bad ref fails loudly rather than checking stale rules.
#
# WHAT THIS WILL NOT DO: overwrite a .vale.ini a repository already has, commit
# anything, or push. It reports and leaves those to you.
set -euo pipefail

REPO_URL="https://github.com/bdchatham/agentic-writing"
RAW="https://raw.githubusercontent.com/bdchatham/agentic-writing"
HOME_DIR="${AGENTIC_WRITING_HOME:-$HOME/.agentic-writing}"
REF="${AGENTIC_WRITING_REF:-main}"
DRY_RUN=false

say() { printf '%s\n' "$*"; }
do_or_say() { if $DRY_RUN; then say "  would: $*"; else eval "$*"; fi; }

install_machine() {
  say "agentic-writing: machine install (ref $REF)"

  if [ -d "$HOME_DIR/.git" ]; then
    say "  checkout exists at $HOME_DIR, updating"
    do_or_say "git -C '$HOME_DIR' fetch --quiet origin '$REF'"
    do_or_say "git -C '$HOME_DIR' checkout --quiet '$REF'"
    do_or_say "git -C '$HOME_DIR' merge --quiet --ff-only 'origin/$REF' || true"
  else
    say "  cloning into $HOME_DIR"
    do_or_say "git clone --quiet --branch '$REF' '$REPO_URL' '$HOME_DIR'"
  fi

  # macOS and Linux put the user Vale directory in different places.
  case "$(uname -s)" in
    Darwin) vale_dir="$HOME/Library/Application Support/vale" ;;
    *)      vale_dir="${XDG_CONFIG_HOME:-$HOME/.config}/vale" ;;
  esac
  do_or_say "mkdir -p '$vale_dir/styles'"

  for style in AgenticWriting config; do
    say "  linking $style into the user styles directory"
    do_or_say "ln -sfn '$HOME_DIR/styles/$style' '$vale_dir/styles/$style'"
  done

  if [ -f "$vale_dir/.vale.ini" ]; then
    say "  user Vale config exists, leaving it alone"
    say "    compare against $HOME_DIR/docs/vale-global-config.reference.ini"
  else
    say "  installing the fallback Vale config"
    do_or_say "cp '$HOME_DIR/docs/vale-global-config.reference.ini' '$vale_dir/.vale.ini'"
  fi

  say ""
  say "Done. The artifact builder lives at:"
  say "  $HOME_DIR/scripts/build-spec-artifact.sh"
  say ""
  say "A repository still needs its own setup, or CI checks nothing:"
  say "  cd <repo> && curl -fsSL $RAW/main/scripts/install.sh | bash -s -- repo"
}

install_repo() {
  if ! git rev-parse --show-toplevel >/dev/null 2>&1; then
    say "not inside a git repository. cd to one first." >&2
    exit 2
  fi
  root="$(git rev-parse --show-toplevel)"
  say "agentic-writing: repository install in $root (pinning ref $REF)"

  src="$HOME_DIR"
  if [ ! -d "$src/templates" ]; then
    src="$(mktemp -d)"
    say "  no local checkout, fetching templates at $REF"
    $DRY_RUN || git clone --quiet --depth 1 --branch "$REF" "$REPO_URL" "$src"
  fi

  if [ -f "$root/.vale.ini" ]; then
    say "  .vale.ini exists, leaving it alone"
    say "    compare against $src/templates/consumer.vale.ini"
  else
    say "  writing .vale.ini"
    do_or_say "sed 's|@REF@|$REF|g' '$src/templates/consumer.vale.ini' > '$root/.vale.ini'"
  fi

  wf="$root/.github/workflows/writing.yml"
  if [ -f "$wf" ]; then
    say "  writing.yml exists, leaving it alone"
  else
    say "  writing .github/workflows/writing.yml"
    do_or_say "mkdir -p '$root/.github/workflows'"
    do_or_say "sed 's|@REF@|$REF|g' '$src/templates/writing.yml' > '$wf'"
  fi

  # Fetch the rules now, so `vale` works immediately rather than failing with
  # E201 on a StylesPath that nothing has populated. A repository-local
  # .vale.ini means Vale never consults the user styles directory, so a machine
  # install does not cover this.
  say "  fetching the rules into .vale/styles"
  do_or_say "rm -rf '$root/.vale/styles'"
  do_or_say "mkdir -p '$root/.vale/styles'"
  do_or_say "cp -R '$src/styles/AgenticWriting' '$root/.vale/styles/'"
  do_or_say "cp -R '$src/styles/config' '$root/.vale/styles/'"
  if ! $DRY_RUN; then
    ( cd "$root" && vale sync >/dev/null 2>&1 ) || \
      say "    note: 'vale sync' did not run. Run it to fetch write-good and proselint."
  fi

  if ! grep -qxF '.vale/' "$root/.gitignore" 2>/dev/null; then
    say "  adding .vale/ to .gitignore"
    do_or_say "printf '\n# agentic-writing fetches the rules here\n.vale/\n' >> '$root/.gitignore'"
  fi

  say ""
  say "Commit these, and the checks run for everyone on every branch:"
  say "  .vale.ini  .github/workflows/writing.yml  .gitignore"
  say ""
  say "The rules themselves are in .vale/, which is gitignored. Re-run this to"
  say "refresh them, or raise the pin in .vale.ini and writing.yml together." 
  say ""
  say "Spec Kit is separate and this script does not install it. If this"
  say "repository writes specifications, it also needs a constitution:"
  say "  specify init --here --integration claude"
}

while [ $# -gt 0 ]; do
  case "$1" in
    --dry-run) DRY_RUN=true; shift ;;
    machine|repo) MODE="$1"; shift ;;
    -h|--help) sed -n '2,32p' "$0"; exit 0 ;;
    *) say "unknown argument: $1" >&2; exit 2 ;;
  esac
done

case "${MODE:-machine}" in
  machine) install_machine ;;
  repo)    install_repo ;;
esac
