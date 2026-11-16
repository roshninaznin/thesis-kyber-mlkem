#!/usr/bin/env bash
# run_matrix_mlkem.sh - mlkem-native session (H2, H4): controls, then 36 cells:
#   (v2, v3) x (clang-18, clang-21, gcc-15) x (Os, O2nv, O3) x (LTO off, on)
# Results go to results/mlkem.csv and results/mlkem/.
set -u
cd "$HOME/thesis/thesis-artifact" || exit 66
export CELLS_DIR="$PWD/results/mlkem" CELLS_CSV="$PWD/results/mlkem.csv"

# control 1: toy leak caught, toy constant-time code clean
clang-18 -Os -g -o harness/toy_leak harness/toy_leak.c || exit 1
valgrind -q --error-exitcode=1 harness/toy_leak L > /dev/null 2>&1; leak=$?
valgrind -q --error-exitcode=1 harness/toy_leak C > /dev/null 2>&1; clean=$?
if [ $leak -ne 1 ] || [ $clean -ne 0 ]; then echo "TOY CONTROL FAILED (L=$leak C=$clean) - stopping"; exit 1; fi
echo "toy control ok (L caught, C clean)"

# control 2: the planted leak in mlkem-native must be caught, by every compiler, with and without LTO
for cc in clang-18 clang-21 gcc-15; do
  for lto in off on; do
    harness/run_cell_mlkem.sh v2leak $cc Os $lto | tee /tmp/ctrl.$$
    grep -q '^\[FLAGGED\]' /tmp/ctrl.$$ || { echo "PLANTED-LEAK CONTROL NOT CAUGHT - stopping"; rm -f /tmp/ctrl.$$; exit 1; }
  done
done
rm -f /tmp/ctrl.$$

for v in v2 v3; do
  for cc in clang-18 clang-21 gcc-15; do
    for opt in Os O2nv O3; do
      for lto in off on; do
        harness/run_cell_mlkem.sh $v $cc $opt $lto
      done
    done
  done
done
