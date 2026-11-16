#!/usr/bin/env bash
# run_dudect.sh - H5: dudect on 8 cells x 3 repetitions, fixed budget per run
# (10 million measurements or 30 minutes, whichever comes first; PREREGISTRATION.md section 7).
# Repetitions are the outer loop, so every cell is measured once before any cell is repeated.
# Safe to re-run after an interruption: finished runs (log contains FINAL) are skipped.
set -u
ROOT="$HOME/thesis/thesis-artifact"; OUT="$ROOT/results/dudect"; CSV="$OUT/dudect.csv"
MAXMEAS=${MAXMEAS:-10000000}; MAXSEC=${MAXSEC:-1800}; REPS=${REPS:-3}; CORE=${CORE:-2}
mkdir -p "$OUT"
WARN="-Wall -Wextra -Wpedantic -Wmissing-prototypes -Wredundant-decls -Wshadow -Wpointer-arith"
KLIB="kex.c kem.c indcpa.c polyvec.c poly.c ntt.c cbd.c reduce.c verify.c fips202.c symmetric-shake.c randombytes.c"
CF="-mllvm -x86-cmov-converter=false -mllvm -disable-cgp-select2branch=true -mllvm -unswitch-threshold=1"
INC="-I$ROOT/third_party/dudect"; H="$ROOT/harness/dudect_dec.c"
CELLS="v0_Os v1_Os v0_O2nv v1_O2nv v0_Os_lto v0flags_Os v2_Os v3_Os"

build() {  # build <cell> <source dir> <command...>
  cell=$1; dir=$2; shift 2
  cd "$dir" || exit 66
  echo "$*" > "$OUT/$cell.cmd"
  "$@" > "$OUT/$cell.build.log" 2>&1 || { echo "BUILD FAIL $cell (see $OUT/$cell.build.log)"; exit 1; }
}
ref()   { v=$1; cell=$2; shift 2
  build "$cell" "$HOME/thesis/kyber-$v/ref" clang-18 $WARN "$@" -fomit-frame-pointer -DKYBER_K=2 -I. $INC $KLIB "$H" -lm -o "$OUT/$cell.bin"; }
mlkem() { v=$1; cell=$2; shift 2; d="$HOME/thesis/mlkem-native-$v"
  build "$cell" "$d" clang-18 $WARN "$@" -fomit-frame-pointer -DDUT_MLKEM -DMLK_CONFIG_PARAMETER_SET=512 -DMLK_CONFIG_NAMESPACE_PREFIX=mlkem -Imlkem $INC $(cd "$d" && ls mlkem/src/*.c mlkem/src/fips202/*.c) "$H" -lm -o "$OUT/$cell.bin"; }

ref v0 v0_Os      -Os
ref v1 v1_Os      -Os
ref v0 v0_O2nv    -O2 -fno-vectorize
ref v1 v1_O2nv    -O2 -fno-vectorize
ref v0 v0_Os_lto  -Os -flto -fuse-ld=lld
ref v0 v0flags_Os -Os $CF
mlkem v2 v2_Os    -Os
mlkem v3 v3_Os    -Os
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
