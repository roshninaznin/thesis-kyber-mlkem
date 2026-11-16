#!/usr/bin/env bash
# run_cell.sh - one matrix cell for the Kyber ref variants (V0/V1):
#   build -> functional tests -> Valgrind -> check flagged instructions -> one CSV row.
# Usage: harness/run_cell.sh <v0|v1> <clang-18|clang-21|gcc-15> <Os|O2nv|O3> <off|on> [compile|link|both]
#   5th argument (clang only): add the "Fun with flags" LLVM flag set at that build stage (V0-flags).
#   CELLS_DIR / CELLS_CSV (environment): write results somewhere other than results/cells.
set -u
[ $# -eq 4 ] || [ $# -eq 5 ] || { echo "usage: $0 <v0|v1> <compiler> <Os|O2nv|O3> <off|on> [compile|link|both]"; exit 64; }
V=$1; CC=$2; OPT=$3; LTO=$4; PLACE=${5:-none}

ROOT="$HOME/thesis/thesis-artifact"
SRC="$HOME/thesis/kyber-$V/ref"
if [ $PLACE = none ]; then LABEL=$V; else LABEL="$V-flags-$PLACE"; fi
OUT="${CELLS_DIR:-$ROOT/results/cells}/${LABEL}_${CC}_${OPT}_lto-${LTO}"
CSV="${CELLS_CSV:-$ROOT/results/cells.csv}"
KAT=6730bb552c22d9d2176ffb5568e48eb30952cf1f065073ec5f9724f6a3c6ea85  # test_vectors512, LOGBOOK

# ---- 1. translate the cell name into compiler flags -------------------------
case "$CC" in clang-*) FAM=clang;; gcc-*) FAM=gcc;; *) echo "bad compiler: $CC"; exit 64;; esac
case "$OPT" in
  Os)   OFLAGS="-Os";;
  O2nv) if [ $FAM = clang ]; then OFLAGS="-O2 -fno-vectorize"; else OFLAGS="-O2 -fno-tree-vectorize"; fi;;
  O3)   OFLAGS="-O3";;
  O1)   OFLAGS="-O1";;
  O3nv) if [ $FAM = clang ]; then OFLAGS="-O3 -fno-vectorize"; else OFLAGS="-O3 -fno-tree-vectorize"; fi;;
  *) echo "bad opt: $OPT"; exit 64;;
esac
case "$LTO" in
  off) LFLAGS="";;
  on)  if [ $FAM = clang ]; then LFLAGS="-flto -fuse-ld=lld"; else LFLAGS="-flto"; fi;;
  *) echo "bad lto: $LTO"; exit 64;;
esac
# V0-flags: flag set from arXiv 2507.06112, in compiler-driver form and in linker (LTO) form
PFLAGS=""
if [ $PLACE != none ]; then
  [ $FAM = clang ] || { echo "flag set is clang-only"; exit 64; }
  CF="-mllvm -x86-cmov-converter=false -mllvm -disable-cgp-select2branch=true -mllvm -unswitch-threshold=1"
  LF="-Wl,-mllvm,-x86-cmov-converter=false -Wl,-mllvm,-disable-cgp-select2branch=true -Wl,-mllvm,-unswitch-threshold=1"
  if [ $OPT = O3 ]; then CF="$CF -fno-vectorize"; LF="$LF -Wl,-mllvm,-vectorize-loops=false"; fi
  case "$PLACE" in
    compile) PFLAGS="$CF";;
    link)    [ $LTO = on ] || { echo "link placement needs lto=on"; exit 64; }; PFLAGS="$LF";;
    both)    [ $LTO = on ] || { echo "both placement needs lto=on"; exit 64; }; PFLAGS="$CF $LF";;
    *) echo "bad placement: $PLACE"; exit 64;;
  esac
fi
[ -d "$SRC" ] || { echo "no source dir: $SRC"; exit 66; }
command -v "$CC" > /dev/null || { echo "compiler not found: $CC"; exit 66; }

WARN="-Wall -Wextra -Wpedantic -Wmissing-prototypes -Wredundant-decls -Wshadow -Wpointer-arith"
LIB="kex.c kem.c indcpa.c polyvec.c poly.c ntt.c cbd.c reduce.c verify.c fips202.c symmetric-shake.c"
FLAGS="$WARN $OFLAGS -fomit-frame-pointer -g -DKYBER_K=2 $LFLAGS $PFLAGS"

# ---- 2. build ---------------------------------------------------------------
rm -rf "$OUT"; mkdir -p "$OUT"; cd "$SRC" || exit 66
B_CT="$CC $FLAGS -I. $LIB randombytes.c $ROOT/harness/ct_valgrind.c -o $OUT/ct_valgrind512"
B_TV="$CC $FLAGS $LIB test_vectors.c -o $OUT/test_vectors512"
printf '%s\n%s\n' "$B_CT" "$B_TV" > "$OUT/cmd.txt"

src_commit=$(git rev-parse --short=12 HEAD)
cc_version=$($CC --version | head -1)
tests=NA; kat=NA; vg_exit=NA; vg_err=NA; vg_ctx=NA; loc=NA; origin=NA; insn=NA; sha=NA

if ! { $B_CT && $B_TV; } > "$OUT/build.log" 2>&1; then
  build=fail; status="BUILD FAIL"
else
  build=ok
  sha=$(sha256sum "$OUT/ct_valgrind512" | cut -d' ' -f1)

  # ---- 3. functional tests (a broken build must never count as "clean") -----
  if "$OUT/ct_valgrind512" > "$OUT/plain.log" 2>&1; then tests=pass; else tests=fail; fi
  if [ "$("$OUT/test_vectors512" | sha256sum | cut -d' ' -f1)" = "$KAT" ]; then kat=pass; else kat=fail; fi

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
  n_own=$(grep -A1 'created by a client request' "$OUT/valgrind.log" | grep -c 'ct_valgrind\.c')
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
