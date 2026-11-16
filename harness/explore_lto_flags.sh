#!/usr/bin/env bash
# explore_lto_flags.sh - EXPLORATORY, not pre-registered. V0, clang-18, -O2 -fno-vectorize, LTO on,
# both vectorizers off at link stage (= variant E of explore_lto_vec.sh, where the branch is back).
# Question: at which build stage does the "Fun with flags" set have to be given to remove the branch?
set -u
ROOT="$HOME/thesis/thesis-artifact"; OUT="$ROOT/results/exploratory/lto_flags"
mkdir -p "$OUT"; cd "$HOME/thesis/kyber-v0/ref" || exit 66
WARN="-Wall -Wextra -Wpedantic -Wmissing-prototypes -Wredundant-decls -Wshadow -Wpointer-arith"
NOVEC="-Wl,-mllvm,-vectorize-loops=false -Wl,-mllvm,-vectorize-slp=false"
CF="-mllvm -x86-cmov-converter=false -mllvm -disable-cgp-select2branch=true -mllvm -unswitch-threshold=1"
LF="-Wl,-mllvm,-x86-cmov-converter=false -Wl,-mllvm,-disable-cgp-select2branch=true -Wl,-mllvm,-unswitch-threshold=1"
SRCS="kex.c kem.c indcpa.c polyvec.c poly.c ntt.c cbd.c reduce.c verify.c fips202.c symmetric-shake.c randombytes.c $ROOT/harness/ct_valgrind.c"

try() {
  name=$1; shift
  cmd="clang-18 $WARN -O2 -fno-vectorize -fomit-frame-pointer -g -DKYBER_K=2 -flto -fuse-ld=lld $NOVEC $* -I. $SRCS -o $OUT/$name.bin"
  echo "$cmd" > "$OUT/$name.cmd"
  if ! $cmd > "$OUT/$name.build.log" 2>&1; then echo "$name: BUILD FAIL"; return; fi
  "$OUT/$name.bin" > "$OUT/$name.plain.log" 2>&1; run=$?
  valgrind --error-exitcode=1 --track-origins=yes "$OUT/$name.bin" > "$OUT/$name.valgrind.log" 2>&1; vg=$?
  ctx=$(grep -c 'Conditional jump' "$OUT/$name.valgrind.log")
  where=$(grep -A1 'Conditional jump' "$OUT/$name.valgrind.log" | grep -m1 'at 0x' | sed 's/.*at 0x[0-9A-F]*: //')
  echo "$name: run_exit=$run vg_exit=$vg branch_contexts=$ctx ${where:-}"
}

try 1_noflags
try 2_flags_compile $CF
try 3_flags_link    $LF
try 4_flags_both    $CF $LF
