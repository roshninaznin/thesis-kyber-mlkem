#!/usr/bin/env bash
# run_purnal_extra.sh - EXPLORATORY, not pre-registered. The two configurations from Purnal's
# clangover report that the pre-registered matrix does not contain: -O1 and -O3 -fno-vectorize.
# V0 and V1, three compilers, no LTO = 12 cells, same runner and status rules as the matrix.
set -u
cd "$HOME/thesis/thesis-artifact" || exit 66
export CELLS_DIR="$PWD/results/purnal_extra" CELLS_CSV="$PWD/results/purnal_extra.csv"

# control: plain V0 clang-18 -Os must still be FLAGGED with the extended runner
harness/run_cell.sh v0 clang-18 Os off | tee /tmp/ctrl.$$
grep -q '^\[FLAGGED\]' /tmp/ctrl.$$ || { echo "V0 CONTROL NOT CAUGHT - stopping"; rm -f /tmp/ctrl.$$; exit 1; }
rm -f /tmp/ctrl.$$

for opt in O1 O3nv; do
  for cc in clang-18 clang-21 gcc-15; do
    for v in v0 v1; do
      harness/run_cell.sh $v $cc $opt off
    done
  done
done
