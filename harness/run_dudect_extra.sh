#!/usr/bin/env bash
# run_dudect_extra.sh - EXPLORATORY, not pre-registered. dudect on four cells outside the
# pre-registered eight, same harness, same fixed budget (10 million measurements or 30 minutes),
# 3 repetitions, repetition as outer loop. Finished runs are skipped on re-run.
#   v1_Os_lto, v1_O2nv_lto : the initial fix under LTO (questioned by Bernstein, Roeckx, Masken3)
#   v0_O3                  : branch present in the binary but not executed (static look)
#   v0_O1                  : configuration from Purnal's report, not in our matrix
set -u
ROOT="$HOME/thesis/thesis-artifact"; OUT="$ROOT/results/dudect_extra"; CSV="$OUT/dudect_extra.csv"
MAXMEAS=${MAXMEAS:-10000000}; MAXSEC=${MAXSEC:-1800}; REPS=${REPS:-3}; CORE=${CORE:-2}
mkdir -p "$OUT"
WARN="-Wall -Wextra -Wpedantic -Wmissing-prototypes -Wredundant-decls -Wshadow -Wpointer-arith"
KLIB="kex.c kem.c indcpa.c polyvec.c poly.c ntt.c cbd.c reduce.c verify.c fips202.c symmetric-shake.c randombytes.c"
INC="-I$ROOT/third_party/dudect"; H="$ROOT/harness/dudect_dec.c"
CELLS="v1_Os_lto v1_O2nv_lto v0_O3 v0_O1"

ref() { v=$1; cell=$2; shift 2
  cd "$HOME/thesis/kyber-$v/ref" || exit 66
  set -- clang-18 $WARN "$@" -fomit-frame-pointer -DKYBER_K=2 -I. $INC $KLIB "$H" -lm -o "$OUT/$cell.bin"
  echo "$*" > "$OUT/$cell.cmd"
  "$@" > "$OUT/$cell.build.log" 2>&1 || { echo "BUILD FAIL $cell (see $OUT/$cell.build.log)"; exit 1; }
}
ref v1 v1_Os_lto   -Os -flto -fuse-ld=lld
ref v1 v1_O2nv_lto -O2 -fno-vectorize -flto -fuse-ld=lld
ref v0 v0_O3       -O3
ref v0 v0_O1       -O1
echo "built: $CELLS"

[ -f "$CSV" ] || echo "cell,rep,measurements,seconds,max_abs_t,test_index,n_in_test,label,date_utc" > "$CSV"
for rep in $(seq 1 "$REPS"); do
  for cell in $CELLS; do
    log="$OUT/${cell}_rep$rep.log"
    if grep -q '^FINAL' "$log" 2>/dev/null; then echo "skip $cell rep $rep (already done)"; continue; fi
    echo "$(date +%H:%M:%S) start $cell rep $rep"
    taskset -c "$CORE" "$OUT/$cell.bin" "$MAXMEAS" "$MAXSEC" > "$log" 2>&1
    fin=$(grep '^FINAL' "$log") || { echo "RUN FAIL $cell rep $rep"; exit 1; }
    echo "$cell,$rep,$(echo "$fin" | sed -E 's/^FINAL //; s/[a-z_]+=//g; s/ /,/g'),$(date -u +%FT%TZ)" >> "$CSV"
    echo "   $fin"
  done
done
echo; echo "all runs done"; column -s, -t "$CSV" 2>/dev/null || cat "$CSV"
