#!/usr/bin/env bash
# fresh_clone_test.sh - reproducibility check from a clean copy.
# Clones the committed state of this repository into an empty directory, fetches all sources
# again from upstream at the pinned commits, re-applies the patches, re-runs all 84 cells once
# and compares them with the committed results. Nothing from the working copy is reused.
# Usage: harness/fresh_clone_test.sh [empty directory, default $HOME/thesis-fresh]
set -u
SRC="$HOME/thesis/thesis-artifact"; NEW=${1:-$HOME/thesis-fresh}
[ -e "$NEW" ] && { echo "$NEW already exists: remove it or name another directory"; exit 1; }
if ! git -C "$SRC" diff --quiet || ! git -C "$SRC" diff --cached --quiet; then
  echo "uncommitted changes in $SRC: commit them first, the test uses the committed state"; exit 1
fi
mkdir -p "$NEW/thesis" && git clone -q "$SRC" "$NEW/thesis/thesis-artifact" || exit 1
echo "fresh clone of commit $(git -C "$SRC" rev-parse --short=12 HEAD) in $NEW"

export HOME="$NEW"                      # every script resolves its paths from $HOME
cd "$HOME/thesis/thesis-artifact" || exit 1
harness/setup_sources.sh || exit 1
rm -f results/replication/r*.csv results/replication/*.tsv   # force a real re-run in the clone
ROUNDS=1 harness/replicate.sh
