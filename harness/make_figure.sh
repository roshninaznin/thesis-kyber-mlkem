#!/usr/bin/env bash
# make_figure.sh - extract the six compiled forms of poly.c:178 (the Kyber bit-select)
# from the committed disassembly, into results/FIGURE_six_forms.txt. Derived artifact.
set -u
cd "$HOME/thesis/thesis-artifact" || exit 66
OUT=results/FIGURE_six_forms.txt
fm() { awk '/<pqcrystals_kyber512_ref_poly_frommsg>:/,/^$/' "$1"; }

{
echo "Six compiled forms of the same source line (ref/poly.c:178):"
echo "    r->coeffs[8*i+j] = mask & ((KYBER_Q+1)/2);   /* KYBER_Q+1)/2 = 1665 = 0x681 */"
echo "All from this project's own binaries. Loop-counter branches (cmp \$0x8 / \$0x20) are not"
echo "secret-dependent; the secret byte is read through %rsi."
echo
echo "=== (1) V0, clang-18 -Os, no LTO : secret-dependent BRANCH (bt -> jae) ==="
fm results/cells/v0_clang-18_Os_lto-off/disasm.s
echo
echo "=== (2) V1, clang-18 -Os, no LTO : out-of-line call (setb -> call cmov_int16) ==="
fm results/cells/v1_clang-18_Os_lto-off/disasm.s
echo
echo "=== (3) V0-flags, clang-18 -Os, no LTO : conditional move (bt -> cmovae), no branch ==="
fm results/flags/v0-flags-compile_clang-18_Os_lto-off/disasm.s
echo
echo "=== (4) V0, gcc-15 -Os, no LTO : mask arithmetic (sar/and/neg/and), no branch ==="
fm results/cells/v0_gcc-15_Os_lto-off/disasm.s
echo
echo "=== (5) V0, clang-18 -O3, no LTO : vector path + DORMANT scalar branch (not executed) ==="
echo "    Entry guards on buffer overlap (addresses, not secret); non-overlapping inputs take"
echo "    the vector path at 332e. The branchy scalar code below is the fall-through."
fm results/cells/v0_clang-18_O3_lto-off/disasm.s | head -20
echo "    [... scalar fall-through with testb (%rsi..)/je continues; full function in the file ...]"
echo
echo "=== (6) V0, clang-18 -Os, LTO on : inlined into indcpa_enc, vectorised (pandn), no branch ==="
echo "    poly_frommsg no longer exists as a function; the bit-select is SSE2 mask code."
grep -n -B2 -A10 -m1 'pandn' results/cells/v0_clang-18_Os_lto-on/disasm.s | sed 's/^/    /'
} > "$OUT"

echo "wrote $OUT ($(wc -l < "$OUT") lines)"
