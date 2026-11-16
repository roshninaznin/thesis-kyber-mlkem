#!/usr/bin/env bash
# explore_lto_vec.sh - EXPLORATORY, not pre-registered. V0, clang-18, -O2 -fno-vectorize, LTO on.
# Question: is V0 unflagged under LTO only because the code is vectorized at link time?
set -u
ROOT="$HOME/thesis/thesis-artifact"; OUT="$ROOT/results/exploratory/lto_vec"
mkdir -p "$OUT"; cd "$HOME/thesis/kyber-v0/ref" || exit 66
WARN="-Wall -Wextra -Wpedantic -Wmissing-prototypes -Wredundant-decls -Wshadow -Wpointer-arith"
BASE="clang-18 $WARN -O2 -fno-vectorize -fomit-frame-pointer -g -DKYBER_K=2 -flto -fuse-ld=lld -I."
SRCS="kex.c kem.c indcpa.c polyvec.c poly.c ntt.c cbd.c reduce.c verify.c fips202.c symmetric-shake.c randombytes.c $ROOT/harness/ct_valgrind.c"

try() {
  name=$1; shift
  cmd="$BASE $* $SRCS -o $OUT/$name.bin"
  echo "$cmd" > "$OUT/$name.cmd"
  if ! $cmd > "$OUT/$name.build.log" 2>&1; then echo "$name: BUILD FAIL"; return; fi
  "$OUT/$name.bin" > "$OUT/$name.plain.log" 2>&1; run=$?
  valgrind --error-exitcode=1 --track-origins=yes "$OUT/$name.bin" > "$OUT/$name.valgrind.log" 2>&1; vg=$?
  pandn=$(objdump -d "$OUT/$name.bin" | grep -c pandn)
  ctx=$(grep -c 'Conditional jump' "$OUT/$name.valgrind.log")
  where=$(grep -A1 'Conditional jump' "$OUT/$name.valgrind.log" | grep -m1 'at 0x' | sed 's/.*at 0x[0-9A-F]*: //')
  echo "$name: run_exit=$run pandn=$pandn vg_exit=$vg branch_contexts=$ctx ${where:-}"
}

try A_baseline
try B_compile_noslp      -fno-slp-vectorize
try C_link_noloop        -Wl,-mllvm,-vectorize-loops=false
try D_link_noslp         -Wl,-mllvm,-vectorize-slp=false
try E_link_noloop_noslp  -Wl,-mllvm,-vectorize-loops=false -Wl,-mllvm,-vectorize-slp=false
