#!/usr/bin/env bash
# run_bench.sh - H6a/H6b: decapsulation cycle counts, clang-18, no LTO, -Os and -O3.
# Builds V0, V1, V2, V3 with the same flags as the matrix cells (without -g), then runs them
# round-robin (so that slow drift of the machine hits all variants alike), pinned to one core.
# Output: results/bench/bench.csv (one row per run) and a summary table.
set -u
ROOT="$HOME/thesis/thesis-artifact"; OUT="$ROOT/results/bench"; CSV="$OUT/bench.csv"
ROUNDS=${ROUNDS:-11}; CORE=${CORE:-2}
mkdir -p "$OUT"
WARN="-Wall -Wextra -Wpedantic -Wmissing-prototypes -Wredundant-decls -Wshadow -Wpointer-arith"
KLIB="kex.c kem.c indcpa.c polyvec.c poly.c ntt.c cbd.c reduce.c verify.c fips202.c symmetric-shake.c randombytes.c"

for opt in Os O3; do
  for v in v0 v1; do
    cd "$HOME/thesis/kyber-$v/ref" || exit 66
    cmd="clang-18 $WARN -$opt -fomit-frame-pointer -DKYBER_K=2 -I. $KLIB $ROOT/harness/bench_dec.c -o $OUT/bench_${v}_$opt"
    echo "$cmd" > "$OUT/bench_${v}_$opt.cmd"; $cmd || { echo "BUILD FAIL $v $opt"; exit 1; }
  done
  for v in v2 v3; do
    cd "$HOME/thesis/mlkem-native-$v" || exit 66
    cmd="clang-18 $WARN -$opt -fomit-frame-pointer -DBENCH_MLKEM -DMLK_CONFIG_PARAMETER_SET=512 -DMLK_CONFIG_NAMESPACE_PREFIX=mlkem -Imlkem $(ls mlkem/src/*.c mlkem/src/fips202/*.c | tr '\n' ' ') $ROOT/harness/bench_dec.c -o $OUT/bench_${v}_$opt"
    echo "$cmd" > "$OUT/bench_${v}_$opt.cmd"; $cmd || { echo "BUILD FAIL $v $opt"; exit 1; }
  done
done

echo "variant,opt,round,median,q1,q3,min,n,ok" > "$CSV"
for r in $(seq 1 "$ROUNDS"); do
  for opt in Os O3; do
    for v in v0 v1 v2 v3; do
      line=$(taskset -c "$CORE" "$OUT/bench_${v}_$opt") || { echo "RUN FAIL $v $opt: $line"; exit 1; }
      echo "$v,$opt,$r,$(echo "$line" | sed -E 's/[a-z0-9]+=//g; s/ /,/g')" >> "$CSV"
    done
  done
  echo "round $r/$ROUNDS done"
done

# summary: median over rounds of the per-run medians, and the spread between rounds
awk -F, 'NR>1 { k=$1","$2; n[k]++; a[k,n[k]]=$4 }
  END { for (k in n) { m=n[k]; for (i=1;i<=m;i++) for (j=i+1;j<=m;j++) if (a[k,j]<a[k,i]) { t=a[k,i]; a[k,i]=a[k,j]; a[k,j]=t }
          printf "%s,%d,%d,%d\n", k, a[k,int((m+1)/2)], a[k,1], a[k,m] } }' "$CSV" | sort > "$OUT/summary.csv"
echo; echo "variant,opt,median_of_medians,lowest_round,highest_round"; cat "$OUT/summary.csv"; echo
# paired overhead per round (both variants measured in the same round), then quartiles over rounds
# decision rule (LOGBOOK, fixed before the run): "< 5%" is
#   supported      if the upper quartile of the per-round overhead is below 5%,
#   not supported  if the lower quartile is above 5%,
#   inconclusive   otherwise (the platform is too noisy to decide).
pair() {  # pair <label> <new> <base> <opt>
  awk -F, -v L="$1" -v A="$2" -v B="$3" -v O="$4" 'NR>1 && $2==O { if ($1==A) a[$3]=$4; if ($1==B) b[$3]=$4 }
    END { m=0; for (r in a) if (r in b) { m++; x[m]=(a[r]-b[r])*100/b[r] }
          for (i=1;i<=m;i++) for (j=i+1;j<=m;j++) if (x[j]<x[i]) { t=x[i]; x[i]=x[j]; x[j]=t }
          lo=x[int((m+3)/4)]; hi=x[int((3*m+1)/4)]
          v = (hi < 5) ? "supported" : (lo > 5) ? "not supported" : "inconclusive"
          printf "%s %s: median %+.2f%%  quartiles %+.2f%% .. %+.2f%%  range %+.2f%% .. %+.2f%%  (%d rounds)  -> %s\n", L, O, x[int((m+1)/2)], lo, hi, x[1], x[m], m, v }' "$CSV"
}
for opt in Os O3; do
  pair "H6a V1 vs V0" v1 v0 $opt
  pair "H6b V2 vs V3" v2 v3 $opt
done | tee "$OUT/overhead.txt"
