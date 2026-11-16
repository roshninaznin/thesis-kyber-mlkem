#!/usr/bin/env bash
# replicate.sh - EXPLORATORY robustness check, not pre-registered.
# Re-runs all 84 pre-registered cells ROUNDS times. Every run draws a fresh random key and a
# fresh ciphertext, so this addresses the "one key, one ciphertext" limit of the main runs.
# Each round writes results/replication/r<N>.csv; per-cell files go to results/replication/r<N>/
# (not committed). At the end every round is compared with the original CSVs.
set -u
cd "$HOME/thesis/thesis-artifact" || exit 66
ROUNDS=${ROUNDS:-5}; OUT="$PWD/results/replication"; mkdir -p "$OUT"

for r in $(seq 1 "$ROUNDS"); do
  export CELLS_DIR="$OUT/r$r" CELLS_CSV="$OUT/r$r.csv"
  if [ -f "$CELLS_CSV" ] && [ "$(wc -l < "$CELLS_CSV")" -eq 85 ]; then echo "round $r already complete"; continue; fi
  rm -rf "$CELLS_DIR" "$CELLS_CSV"
  for cc in clang-18 clang-21 gcc-15; do for opt in Os O2nv O3; do for lto in off on; do
    for v in v0 v1; do harness/run_cell.sh $v $cc $opt $lto > /dev/null; done
    for v in v2 v3; do harness/run_cell_mlkem.sh $v $cc $opt $lto > /dev/null; done
  done; done; done
  for opt in Os O2nv O3; do
    harness/run_cell.sh v0 clang-18 $opt off compile > /dev/null
    for place in compile link both; do harness/run_cell.sh v0 clang-18 $opt on $place > /dev/null; done
  done
  echo "round $r done: $(( $(wc -l < "$CELLS_CSV") - 1 )) cells"
done

# compare: key = variant,compiler,opt,lto ; value = status|errors|contexts|first location|instructions
key='{ print $1","$3","$5","$6 "\t" $16"|"$11"|"$12"|"$13"|"$15 }'
cat results/cells.csv results/flags.csv results/mlkem.csv | grep -v '^variant,' | grep -v '^v2leak,' \
  | awk -F, "$key" | sort -u > "$OUT/original.tsv"
echo; echo "original cells: $(wc -l < "$OUT/original.tsv")   (flags.csv contains one extra control row for v0 clang-18 Os off)"
for r in $(seq 1 "$ROUNDS"); do
  grep -v '^variant,' "$OUT/r$r.csv" | awk -F, "$key" | sort -u > "$OUT/r$r.tsv"
  same=$(comm -12 "$OUT/original.tsv" "$OUT/r$r.tsv" | wc -l)
  echo "round $r: $(wc -l < "$OUT/r$r.tsv") cells, identical to original (status, error count, contexts, location, instructions): $same"
  comm -13 "$OUT/original.tsv" "$OUT/r$r.tsv" | sed 's/^/   DIFFERENT in this round: /'
done
