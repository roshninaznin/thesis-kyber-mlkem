#!/usr/bin/env bash
# run_flags.sh - V0-flags session (H7, H8): controls, then the 12 pre-registered cells.
#   clang-18 x (Os, O2nv, O3) x (no LTO | LTO + flags at compile | at link | at both)
# Results go to results/flags.csv and results/flags/, separate from the main matrix.
set -u
cd "$HOME/thesis/thesis-artifact" || exit 66
export CELLS_DIR="$PWD/results/flags" CELLS_CSV="$PWD/results/flags.csv"

# control 1: toy leak caught, toy constant-time code clean
clang-18 -Os -g -o harness/toy_leak harness/toy_leak.c || exit 1
valgrind -q --error-exitcode=1 harness/toy_leak L > /dev/null 2>&1; leak=$?
valgrind -q --error-exitcode=1 harness/toy_leak C > /dev/null 2>&1; clean=$?
if [ $leak -ne 1 ] || [ $clean -ne 0 ]; then echo "TOY CONTROL FAILED (L=$leak C=$clean) - stopping"; exit 1; fi
echo "toy control ok (L caught, C clean)"

# control 2: plain V0 must still be caught by the (extended) cell runner
harness/run_cell.sh v0 clang-18 Os off | tee /tmp/ctrl.$$
grep -q '^\[FLAGGED\]' /tmp/ctrl.$$ || { echo "V0 CONTROL NOT CAUGHT - stopping"; rm -f /tmp/ctrl.$$; exit 1; }
rm -f /tmp/ctrl.$$

for opt in Os O2nv O3; do
  harness/run_cell.sh v0 clang-18 $opt off compile
  for place in compile link both; do
    harness/run_cell.sh v0 clang-18 $opt on $place
  done
done
