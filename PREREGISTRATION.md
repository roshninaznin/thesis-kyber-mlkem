# Pre-registration
Thesis: Compiler-Configuration Assessment of Constant-Time Behavior in ML-KEM:
Source Fixes, Compiler Flags and Barrier Ablation under LTO
Author: Hasibul Islam Shanto
Drafted 2026-11-07, committed 2026-11-11, BEFORE any Valgrind / dudect results (V0/V1 build + objdump only so far).

## 1. Scope
- Defensive measurement study. Detects, explains and measures constant-time violations
  introduced by compilers in ML-KEM code, and evaluates countermeasures.
- Key recovery is NOT reproduced. Exploitability is cited from published work
  (clangover / CVE-2024-37880; KyberSlash, TCHES 2025).
- Out of scope: Spectre/speculative leakage, power/EM, other architectures than x86-64.

## 2. Code variants (ML-KEM-512)
- V0       pq-crystals/kyber ref @ b628ba78711b (known vulnerable, CVE-2024-37880)
- V1       pq-crystals/kyber ref @ 9b8d30698a3e (upstream fix, cmov_int16), direct child of V0
- V0-flags V0 source unchanged, built with LLVM flags from "Fun with flags" (arXiv 2507.06112):
           -mllvm -x86-cmov-converter=false -mllvm -disable-cgp-select2branch=true
           -mllvm -unswitch-threshold=1 (+ -fno-vectorize at -O3)
- V2       mlkem-native v2.0.0 (d1b2fe7), portable C only, MLK_CONFIG_PARAMETER_SET 512
- V3       V2 with every value barrier and opt-blocker made a pass-through (sensitivity control)

## 3. Build matrix
- Compilers: clang-18 (18.1.8), clang-21 (21.1.8), gcc-15 (15.2.0)
- Optimization: -Os | -O2 + no-vectorize (clang: -fno-vectorize, gcc: -fno-tree-vectorize) | -O3
  (plain -O3 is a baseline, not a documented clangover trigger)
- LTO: off | on (clang: -flto -fuse-ld=lld ; gcc: -flto)
- Main matrix: 3 x 3 x 2 x 4 (V0,V1,V2,V3) = 72 cells (stretch target)
- V0-flags: clang-18 only x 3 opt levels x 4 placements
  (no LTO; LTO with flags at compile only / link only / both) = 12 cells
- Pre-registered fallbacks, chosen at Gate 2 from pilot timing only:
  60 = drop gcc-15 for V0/V1 ; 48 = V0/V1 on clang-18 only. No other cuts.
- Every cell records: exact compile + link command, compiler version, binary sha256.

## 4. Detectors and controls
- objdump: finds CANDIDATE branches/divisions only. Never a finding on its own.
- Valgrind memcheck (ctgrind-style): secret part of sk (first 384*k bytes) and z (last 32 bytes)
  marked undefined; pk and H(pk) inside sk stay public; shared-secret output marked defined.
- A cell is FLAGGED only if all three agree: Valgrind warning location + taint origin in the
  secret key + matching conditional branch in the SAME binary's disassembly.
- Controls each session: toy_leak (must be caught); V0 clang-18 -Os (must be caught);
  mlkem-native planted leak (must be caught). If a control is not caught, the session's
  cells are INCONCLUSIVE.
- Known blind spot: stock Valgrind does not flag secret-dependent division (KyberSlash class);
  div/idiv in secret functions reported as binary candidates only.

## 5. Cell status (exactly one per cell)
- FLAGGED | NO ISSUE OBSERVED | INCONCLUSIVE (tests fail or controls not caught) | BUILD FAIL
- INCONCLUSIVE and BUILD FAIL are never counted as evidence either way.

## 6. Hypotheses (each reported as supported / not supported under tested conditions)
- H1  V0 @ clang-18 -Os has a Valgrind-flagged secret-dependent branch in poly_frommsg;
      V1 under the same configuration does not.
- H2  V2 (stock mlkem-native) has no flagged cell.
- H3  Enabling LTO changes the set of flagged cells in at least one cell.
- H4  V3 has at least one flagged cell that V2 does not.
- H5  dudect max|t| is larger for V0 than V1 at clang-18 -Os under the budget below.
- H6a V1 costs < 5% decapsulation cycles vs V0 (same compiler, flags, tool).
- H6b V2 costs < 5% decapsulation cycles vs V3 (same compiler, flags, tool).
      (5% is this study's criterion, not a general standard.)
- H7  Without LTO, V0-flags @ clang-18 has no flagged branch in poly_frommsg.
- H8  With LTO, whether V0-flags stays clean depends on where the flags are passed.
- Negative results are worded narrowly: "not supported under the tested conditions".
  An unsupported H4 does NOT mean barriers are unnecessary; an unsupported H3 does NOT mean LTO is safe.

## 7. Timing statistics (If-time tier)
- dudect (oreparaz/dudect, vendored commit recorded). Classes: fixed valid ciphertext vs fresh
  valid ciphertexts; fixed key; input preparation outside the timed region.
- Budget per run: 10 million measurements or 30 minutes, whichever first; 3 repetitions per cell;
  about 8 cells. Report max|t|, crop index, N, and dudect's own label
  (>500 "Definitely not constant time", >10 "Probably not constant time").
  4.5 is mentioned only as a secondary reference.
- RTLF on the same raw samples, alpha = 0.01 per cell, Holm correction across cells.
- Runs are exploratory; any signal is re-run once on fresh data before reporting.
- No adding samples after looking at results.
- Environment caveat: WSL2/VM timing is noisy; timing results are labelled with their platform.

## 8. Gates and stop rules
- Gate 2 (2026-11-14): H1 must hold before the matrix starts.
- If a stock V2 cell is FLAGGED: stop, re-check controls and tests, then disclose privately
  to the maintainers before publishing details.
- Experiments freeze on Tuesday of Week 5.

## 9. Deviations
- Any change to this plan is written in LOGBOOK.md with date and reason, and reported in the
  thesis as a deviation from this pre-registration.
