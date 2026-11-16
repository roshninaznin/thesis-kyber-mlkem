#!/usr/bin/env bash
# run_matrix_ref.sh - session control, then all 36 Kyber-ref cells:
#   (V0, V1) x (clang-18, clang-21, gcc-15) x (Os, O2nv, O3) x (LTO off, on)
set -u
cd "$HOME/thesis/thesis-artifact" || exit 66

# control: the toy leak must be caught and the toy constant-time code must be clean
clang-18 -Os -g -o harness/toy_leak harness/toy_leak.c || exit 1
valgrind -q --error-exitcode=1 harness/toy_leak L > /dev/null 2>&1; leak=$?
valgrind -q --error-exitcode=1 harness/toy_leak C > /dev/null 2>&1; clean=$?
if [ $leak -ne 1 ] || [ $clean -ne 0 ]; then echo "TOY CONTROL FAILED (L=$leak C=$clean) - stopping"; exit 1; fi
echo "toy control ok (L caught, C clean)"

for v in v0 v1; do
  for cc in clang-18 clang-21 gcc-15; do
    for opt in Os O2nv O3; do
      for lto in off on; do
        harness/run_cell.sh $v $cc $opt $lto
      done
    done
  done
done
