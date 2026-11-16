#!/usr/bin/env bash
# run_cell_mlkem.sh - one matrix cell for the mlkem-native variants:
#   v2 = stock v2.0.0, v3 = value barriers removed, v2leak = planted leak (control).
#   build -> functional tests -> Valgrind -> check flagged instructions -> one CSV row.
# Same checks and status rules as run_cell.sh; only the build step differs.
# Usage: harness/run_cell_mlkem.sh <v2|v3|v2leak> <clang-18|clang-21|gcc-15> <Os|O2nv|O3> <off|on>
#   CELLS_DIR / CELLS_CSV (environment): write results somewhere other than results/cells.
set -u
[ $# -eq 4 ] || { echo "usage: $0 <v2|v3|v2leak> <compiler> <Os|O2nv|O3> <off|on>"; exit 64; }
V=$1; CC=$2; OPT=$3; LTO=$4; LABEL=$V

ROOT="$HOME/thesis/thesis-artifact"
SRC="$HOME/thesis/mlkem-native-$V"
OUT="${CELLS_DIR:-$ROOT/results/cells}/${LABEL}_${CC}_${OPT}_lto-${LTO}"
CSV="${CELLS_CSV:-$ROOT/results/cells.csv}"

# ---- 1. translate the cell name into compiler flags -------------------------
case "$CC" in clang-*) FAM=clang;; gcc-*) FAM=gcc;; *) echo "bad compiler: $CC"; exit 64;; esac
case "$OPT" in
  Os)   OFLAGS="-Os";;
  O2nv) if [ $FAM = clang ]; then OFLAGS="-O2 -fno-vectorize"; else OFLAGS="-O2 -fno-tree-vectorize"; fi;;
  O3)   OFLAGS="-O3";;
  *) echo "bad opt: $OPT"; exit 64;;
esac
case "$LTO" in
  off) LFLAGS="";;
  on)  if [ $FAM = clang ]; then LFLAGS="-flto -fuse-ld=lld"; else LFLAGS="-flto"; fi;;
  *) echo "bad lto: $LTO"; exit 64;;
esac
[ -d "$SRC" ] || { echo "no source dir: $SRC"; exit 66; }
command -v "$CC" > /dev/null || { echo "compiler not found: $CC"; exit 66; }

WARN="-Wall -Wextra -Wpedantic -Wmissing-prototypes -Wredundant-decls -Wshadow -Wpointer-arith"
DEFS="-DMLK_CONFIG_PARAMETER_SET=512 -DMLK_CONFIG_NAMESPACE_PREFIX=mlkem"
FLAGS="$WARN $OFLAGS -fomit-frame-pointer -g $DEFS $LFLAGS"

# ---- 2. build ---------------------------------------------------------------
rm -rf "$OUT"; mkdir -p "$OUT"; cd "$SRC" || exit 66
LIB=$(ls mlkem/src/*.c mlkem/src/fips202/*.c | tr '\n' ' ')
B_CT="$CC $FLAGS -Imlkem -Iexamples/basic $LIB $ROOT/harness/ct_valgrind_mlkem.c -o $OUT/ct_valgrind512"
printf '%s\n' "$B_CT" > "$OUT/cmd.txt"

src_commit=$(git rev-parse --short=12 HEAD)
if ! git diff --quiet; then src_commit="$src_commit+patch-$(git diff | sha256sum | cut -c1-8)"; fi
cc_version=$($CC --version | head -1)
tests=NA; kat=NA; vg_exit=NA; vg_err=NA; vg_ctx=NA; loc=NA; origin=NA; insn=NA; sha=NA

if ! $B_CT > "$OUT/build.log" 2>&1; then
  build=fail; status="BUILD FAIL"
else
  build=ok
  sha=$(sha256sum "$OUT/ct_valgrind512" | cut -d' ' -f1)

  # ---- 3. functional tests (a broken build must never count as "clean") -----
  if "$OUT/ct_valgrind512" > "$OUT/plain.log" 2>&1; then tests=pass; else tests=fail; fi
  if grep -q 'kat=1' "$OUT/plain.log"; then kat=pass; else kat=fail; fi   # upstream known answers

  # ---- 4. Valgrind ----------------------------------------------------------
  valgrind --error-exitcode=1 --track-origins=yes "$OUT/ct_valgrind512" > "$OUT/valgrind.log" 2>&1
  vg_exit=$?
  vg_err=$(sed -n 's/.*ERROR SUMMARY: \([0-9,]*\) errors from \([0-9,]*\) contexts.*/\1/p' "$OUT/valgrind.log" | tr -d ,)
  vg_ctx=$(sed -n 's/.*ERROR SUMMARY: \([0-9,]*\) errors from \([0-9,]*\) contexts.*/\2/p' "$OUT/valgrind.log" | tr -d ,)

  # ---- 5. look up every reported address in THIS binary's disassembly -------
  objdump -d --no-show-raw-insn "$OUT/ct_valgrind512" > "$OUT/disasm.s"
  grep -A1 -E 'Conditional jump|Use of uninitialised' "$OUT/valgrind.log" \
    | grep -oE 'at 0x[0-9A-F]+' | cut -d' ' -f2 | sort -u > "$OUT/vg_addrs.txt"
  loc=$(grep -A1 -E 'Conditional jump|Use of uninitialised' "$OUT/valgrind.log" \
    | grep -m1 'at 0x' | sed 's/.*at 0x[0-9A-F]*: //')
  # load address = (address the program printed for ct_anchor) - (address of ct_anchor in the file)
  run_a=$(grep -oE 'anchor=0x[0-9a-fA-F]+' "$OUT/valgrind.log" | head -1 | cut -d= -f2)
  file_a=$(nm "$OUT/ct_valgrind512" | awk '$3=="ct_anchor"{print "0x"$1}')
  base=$(( ${run_a:-0} - ${file_a:-0} ))
  all_branch=yes; insn=""
  while read -r a; do
    off=$(printf '%x' $(( a - base )))
    m=$(grep -m1 -E "^ +$off:" "$OUT/disasm.s" | awk '{print $2}')
    insn="$insn$off:${m:-NOTFOUND} "
    grep -B8 -A4 -E "^ +$off:" "$OUT/disasm.s" >> "$OUT/flagged_insn.s"
    case "${m:-}" in jmp*|"") all_branch=no;; j*) ;; *) all_branch=no;; esac
  done < "$OUT/vg_addrs.txt"

  # ---- 6. does every taint origin point at our SECRET() marks? --------------
  n_org=$(grep -c 'created by a client request' "$OUT/valgrind.log")
  n_own=$(grep -A1 'created by a client request' "$OUT/valgrind.log" | grep -c 'ct_valgrind_mlkem\.c')
  if [ "$n_org" -gt 0 ] && [ "$n_org" -eq "$n_own" ]; then origin=sk; else origin=other; fi

  # ---- 7. status, exactly as defined in PREREGISTRATION.md section 4-5 ------
  if [ $tests != pass ] || [ $kat != pass ]; then status="INCONCLUSIVE"
  elif [ "${vg_err:-x}" = 0 ] && [ $vg_exit -eq 0 ]; then status="NO ISSUE OBSERVED"; origin=NA; insn=NA; loc=NA
  elif [ "${vg_err:-0}" -gt 0 ] 2>/dev/null && [ $origin = sk ] && [ $all_branch = yes ]; then status="FLAGGED"
  else status="REVIEW"
  fi
fi

# ---- 8. one CSV row ---------------------------------------------------------
[ -f "$CSV" ] || echo "variant,src_commit,cc,cc_version,opt,lto,build,tests,kat,vg_exit,vg_errors,vg_contexts,vg_first_location,vg_origin,insn_at_addr,status,binary_sha256,date_utc" > "$CSV"
echo "$LABEL,$src_commit,$CC,\"$cc_version\",$OPT,$LTO,$build,$tests,$kat,$vg_exit,$vg_err,$vg_ctx,\"$loc\",$origin,\"${insn% }\",$status,$sha,$(date -u +%FT%TZ)" >> "$CSV"
echo "[$status] $LABEL $CC $OPT lto=$LTO | tests=$tests kat=$kat | vg_errors=$vg_err contexts=$vg_ctx | $loc | $insn"
