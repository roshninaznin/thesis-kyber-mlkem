# Thesis Logbook

## 2026-11-06 (Week 1)
- Host: HP ProBook 450 G8, i7-1165G7, 16 GB RAM, Windows 10 22H2 (build 19045)
- Environment: WSL2 (WSL 3.0.3.0), Ubuntu 26.04.1 LTS, kernel 6.18.54.1-microsoft-standard-WSL2
- Resources: 8 vCPU, 7.6 GiB RAM
- Decision: moved from VirtualBox to WSL2 (VirtualBox ran through Hyper-V; display corruption)
- Note: two Ubuntu distros exist (old "Ubuntu" = 24.04, thesis = "Ubuntu-26.04").
  Always open with `wsl -d Ubuntu-26.04` and check `lsb_release -d`.
- Toolchain:
  - Ubuntu clang version 18.1.8 (20ubuntu8)
  - Ubuntu clang version 21.1.8 (6ubuntu1)
  - gcc-15 (Ubuntu 15.2.0-16ubuntu1) 15.2.0
  - valgrind-3.26.0
  - GNU objdump (GNU Binutils for Ubuntu) 2.46

## 2026-11-07 (Week 1) — V0/V1 provenance
- Cloned pq-crystals/kyber twice: ~/thesis/kyber-v0, ~/thesis/kyber-v1
- V0 = b628ba78711bc28327dc7d2d5c074a00f061884e ("Replaced .gitignore symlink by actual file")
- V1 = 9b8d30698a3e7449aeb34e62339d4176f11e3c6c (Peter Schwabe, 2024-06-03, poly_frommsg fix)
- Verified: `git rev-parse 9b8d306^` == V0 (V0 is the direct parent of V1)
- Verified: `git diff --stat b628ba7 9b8d306` = 3 files (ref/poly.c, ref/verify.c, ref/verify.h), +13 -3
- Fix: masked assignment in poly_frommsg replaced by cmov_int16() defined in separate file verify.c
- Makefile check at b628ba7: CFLAGS spans lines 2-3; its -O3 is on line 3 (NISTFLAGS -O3 on line 4).
  A pattern-based sed on "^CFLAGS" would silently leave -O3 in place. Used `sed -i '3s/-O3/-Os/'`.
- Targets at b628ba7 live in ref/: test_kyber512, test_vectors512, test_speed512, libpqcrystals_kyber512_ref.so

## 2026-11-07 — V0 build (clang-18 18.1.8, -Os, no LTO)
- Build: OK (see results/v0/v0_build.log). test_kyber512 exit 0. Sizes sk=1632 pk=800 ct=768 (ML-KEM-512).
- test_vectors512 run twice: IDENTICAL. sha256 = 6730bb552c22d9d2176ffb5568e48eb30952cf1f065073ec5f9724f6a3c6ea85
- objdump poly_frommsg (18 lines, results/v0/v0_frommsg_clang18_Os.s):
  `bt %ecx,%r8d` then `jae` skips `mov $0x681,%edx` (0x681 = 1665).
  => conditional branch on bit j of secret msg[i]. CANDIDATE secret-dependent branch (to confirm with Valgrind, Week 2).
  Loop-control jumps (jne on j<8, i<32) are public and not leaks.

## 2026-11-07 — V1 build (clang-18 18.1.8, -Os, no LTO) and V0/V1 comparison
- Makefile: same layout as V0 (-O3 on line 3); same sed applied; diff = line 3 only.
- Build commands V0 vs V1: IDENTICAL (diff of build logs empty).
- test_kyber512 exit 0. test_vectors512 twice: IDENTICAL.
- V0 vs V1 test-vector output: IDENTICAL, sha256 6730bb55...ea85 => fix preserves functionality.
- V1 poly_frommsg: `bt` then `setb %dl` (no conditional jump on the secret bit), then `call cmov_int16@plt`.
  Only jumps left are loop-control `jne` (public counters).
- V1 cmov_int16: neg/xor/and/xor, no jumps (branch-free select).
- Observation for H3: protection relies on cmov_int16 being in a separate file (verify.c) and called via PLT.
  LTO could allow inlining -> must test in Week 3.
- GATE 1 status: V0 and V1 build and pass tests; V0 shows branch candidate, V1 does not. (Pre-registration + supervisor: pending)

## 2026-11-11 Pre-registration
- PREREGISTRATION.md committed as 1ccec53, before any Valgrind/dudect run.
- Gate 2 set to 2026-11-14 before commit (Week 1 ran ~3 days late).

## 2026-11-11 H1 run (clang-18.1.8, -Os, no LTO, Valgrind 3.26.0, WSL2)
- Controls: toy_leak L flagged / C clean (5c5e7be). V0 caught (below).
- V0 (b628ba7): FLAGGED. 256 errors, 1 context:
  conditional jump at poly_frommsg (poly.c:178), via dec -> indcpa_enc.
  Origin: client request at ct_valgrind.c:25 (s part of sk).
  Same binary: jae at 0x2027 = Valgrind address 0x4002027 - load base 0x4000000.
- V1 (9b8d306): NO ISSUE OBSERVED. 0 errors. dec=0 match=1 in both.
- H1: supported under the tested conditions.
- Limits: one key, one ciphertext, executed path only. Not a proof for V1.
  Exploitability not tested; cited from clangover (CVE-2024-37880).
- Evidence commit: 884aac3.

## 2026-11-11 Kyber-ref matrix, 36 cells (raw results: eac953c)
- Session controls: toy_leak L caught / C clean; V0 clang-18 -Os no-LTO FLAGGED. Both ok.
- All 36 cells: build ok, tests pass, KAT pass. No BUILD FAIL / INCONCLUSIVE / REVIEW.
- FLAGGED (4): V0 x {clang-18.1.8, clang-21.1.8} x {-Os, -O2 -fno-vectorize}, LTO off.
  -Os: 1 branch context (jae). -O2nv: 8 contexts (inner loop unrolled). 256 errors each.
- NO ISSUE OBSERVED (32): all V1 cells (18); all gcc-15 cells; all -O3 cells; all LTO-on cells.
- Gate 2: H1 holds (4 of 4 matched V0/V1 pairs where V0 is flagged). Matrix timing 3m03s,
  so no fallback is needed for V0/V1.
- H3 (LTO changes the flagged set in at least one cell): supported. 4 cells change.
  Direction was not predicted: LTO removes the flag on V0; V1 stays unflagged.
- Root cause (disassembly, clang-18 -Os LTO): poly_frommsg and cmov_int16 no longer exist as
  functions (inlined into indcpa_enc). The bit-select loop is emitted as SSE2 mask code
  (pshufd/pand/pcmpeqd/packssdw/pandn, 0x0681 table in .rodata). No conditional branch.
- Observation: with LTO on, -O2 -fno-vectorize still produces vector code
  (pandn: 0 without LTO, 22 with LTO, same command line otherwise). Mechanism not yet shown.
- NOT concluded: that LTO fixes or mitigates CVE-2024-37880. Source is unchanged; the branch
  appears and disappears through optimizer choices. Valgrind silence is not a CT proof.
- Also noted, needs literature check before any claim: clang-21 still emits the branch.

## 2026-11-11 EXPLORATORY (not pre-registered): link-time vectorizer flags
- Motivated by the matrix: V0 clang-18 -O2 -fno-vectorize is flagged without LTO, not with LTO.
- Setup: V0, clang-18.1.8, -O2 -fno-vectorize -flto -fuse-ld=lld, one flag change per variant.
  A baseline:                           pandn=22, 0 branch contexts (reproduces matrix cell)
  B compile-time -fno-slp-vectorize:    pandn=24, 0
  C link-time -vectorize-loops=false:   pandn=2,  0
  D link-time -vectorize-slp=false:     pandn=22, 0
  E link-time both off:                 pandn=0,  8 branch contexts at poly_frommsg (poly.c:178)
- Run twice, same result. Raw: f296a82.
- Reading: compile-stage -fno-vectorize / -fno-slp-vectorize did not control the LTO link-stage
  optimizer here. Either vectorizer alone removes the branch; with both off at link stage the
  secret-dependent branch is back. V0 under LTO was masked by vectorization, not fixed.
- Limits: one compiler, one opt level. E was not put through run_cell.sh's three-condition
  check, so it is not recorded as FLAGGED. Novelty unknown until checked against
  "Fun with flags" (arXiv 2507.06112).
- Consequence for H8: flag placement under LTO matters; link-stage placement must be tested.

## 2026-11-11 Before the V0-flags run (H7, H8): definitions fixed in advance
- Literature re-check (arXiv 2507.06112 v1): flag set confirmed; tested Clang 12/18 at -O3/-Os;
  LTO and linker-stage flags are not discussed there.
- Flag set, compile form: -mllvm -x86-cmov-converter=false -mllvm -disable-cgp-select2branch=true
  -mllvm -unswitch-threshold=1, plus -fno-vectorize at -O3.
- Flag set, link form (clarification, not in the pre-registration): the same three options as
  -Wl,-mllvm,<opt>, plus -Wl,-mllvm,-vectorize-loops=false at -O3 as the link-stage
  counterpart of -fno-vectorize.
- Tooling change: run_cell.sh gets an optional 5th argument (compile|link|both) and
  CELLS_DIR/CELLS_CSV overrides. Four-argument behaviour is unchanged; the session re-runs
  V0 clang-18 -Os as a control to show that.
- Known design limit, stated before the run: with LTO on, V0 is already unflagged without any
  flags (matrix). The nine LTO cells may therefore all be unflagged whatever the placement,
  in which case H8 cannot be decided by this design. A separate exploratory test follows.

## 2026-11-11 V0-flags, 12 pre-registered cells (raw: 5f8655a)
- Controls ok: toy L caught / C clean; plain V0 clang-18 -Os FLAGGED (2027:jae) with the
  extended run_cell.sh, same as before the change.
- All 12 cells: build ok, tests pass, KAT pass, NO ISSUE OBSERVED.
- H7 (no LTO, flags remove the flagged branch): supported. Informative cells are -Os and
  -O2nv (FLAGGED without flags, unflagged with flags). -O3 was already unflagged.
- H8 (under LTO the outcome depends on flag placement): not supported under the tested
  conditions. All nine LTO cells are unflagged for every placement, as they are without any
  flags, so this design cannot separate the placements (limit stated in advance, 227cd7b).

## 2026-11-11 V0-flags root cause + EXPLORATORY flag placement under LTO (raw: d7c8fc9)
- Root cause for H7 (V0-flags, clang-18 -Os, no LTO, same source line poly.c:178):
  bt / mov $0x681 / cmovae. The jae of plain V0 is replaced by a conditional move.
- EXPLORATORY, not pre-registered. Setup: V0, clang-18.1.8, -O2 -fno-vectorize, LTO,
  both vectorizers off at link stage (the configuration where the branch is present).
  1 no protective flags:          8 branch contexts at poly_frommsg (poly.c:178)
  2 flags to the compiler only:   8 branch contexts, same location
  3 flags to the linker only:     0
  4 flags to both:                0
  Two runs, summary lines identical.
- Reading: with LTO, code generation happens at link stage; -mllvm options given only to the
  compiler driver did not change the outcome here. In the nine pre-registered LTO cells the
  absence of a flagged branch is explained by vectorization, not by the protective flags.
- Limits: artificial configuration (vectorizers disabled on purpose); one compiler, one opt
  level; three-condition check not applied, so not recorded as FLAGGED/NO ISSUE cells.
  arXiv 2507.06112 v1 does not discuss LTO; novelty NOT claimed until a wider search is done.

## 2026-11-11 V2 provenance
- mlkem-native v2.0.0 = d1b2fe782888bdb761a50336012923180be7f502 (pq-code-package/mlkem-native),
  cloned to ~/thesis/mlkem-native-v2. Upstream run_func_512 and run_kat_512 pass with clang-18.

## 2026-11-11 Before the mlkem-native run (H2, H4): definitions fixed in advance
- Build: default configuration (portable C, no native backends), separate translation units
  (mlkem/src/*.c, mlkem/src/fips202/*.c) so that LTO is a meaningful factor.
  -DMLK_CONFIG_PARAMETER_SET=512 -DMLK_CONFIG_NAMESPACE_PREFIX=mlkem. Same warning/opt/LTO
  flags as the Kyber-ref cells.
- Barriers in this configuration: the empty-asm value barrier, 3 functions in verify.h, used at
  4 call sites (compress.c poly_frommsg; verify.h cmask_neg_i16, cmask_nonzero_u16, ct_memcmp).
  The volatile opt-blocker variant is not compiled in this configuration.
- V2 = v2.0.0 unmodified. V3 = V2 with the three asm barrier statements deleted.
- V2leak (control, pre-registered as "planted leak"): poly_frommsg selects the coefficient with
  an if on the secret bit plus a volatile counter, so the branch cannot be optimized away.
- Harness ct_valgrind_mlkem.c: same taint model as ct_valgrind.c (s and z secret, decapsulation
  only). Functional check: upstream expected_test_vectors.h (keypair_derand, enc_derand, dec).
- Session control: V2leak must be FLAGGED for all three compilers, LTO off and on, else stop.

## 2026-11-11 mlkem-native session: controls + 36 cells (raw: 22b3598)
- Controls ok: toy L caught / C clean. V2leak FLAGGED 6 of 6 (clang-18, clang-21, gcc-15,
  LTO off and on): 256 errors, 1 context, mlkem_poly_frommsg (compress.c:722), je, origin sk.
  The harness can see a secret-dependent branch inside mlkem-native decapsulation.
- All 36 cells: build ok, tests pass, upstream known answers pass.
- V2 (stock v2.0.0): 18 of 18 NO ISSUE OBSERVED. H2: supported.
- V3 (three asm value barriers deleted): 18 of 18 NO ISSUE OBSERVED.
  H4: not supported under the tested conditions.
- Not concluded: that the barriers are unnecessary. Three compilers, three opt levels, x86-64,
  one key and ciphertext, executed path only. The selection is also written as mask arithmetic
  independently of the barrier.

## 2026-11-11 Follow-up to H4: did removing the barriers change the code at all?
- V2 vs V3 disassembly, all 18 configurations: different in 18 of 18. The barriers do affect
  code generation. (Line counts from diff are not a size measure: one function growing by a
  few bytes shifts every later address.)
- clang-18 -Os, mlkem_poly_frommsg: both variants use neg / shr $0x10 / and $0x681 (mask
  arithmetic), no branch on the message bit. V3 differs in register use and load placement,
  function is 6 bytes longer.
- Reading of H4: removing the barriers changes the generated code but did not turn the
  mask-arithmetic selection into a secret-dependent branch in any tested configuration.

## 2026-11-11 Before the performance run (H6a, H6b): definitions fixed in advance
- Metric: rdtsc cycles for one decapsulation of a valid ciphertext, fixed key; 2000 warm-up
  calls, then 20000 measured calls per run; per-run median.
- Design: clang-18, no LTO, -Os and -O3, matrix flags without -g. 11 rounds; in each round all
  four variants run once (round-robin), pinned to one core with taskset.
- Overhead is computed per round from the two runs of that round (V1 vs V0; V2 vs V3).
- Decision rule for "< 5%", per opt level: supported if the upper quartile of the 11 per-round
  overheads is below 5%; not supported if the lower quartile is above 5%; otherwise
  inconclusive. Reason: round-to-round noise on a VM is of the same size as the threshold.
- Platform label: WSL2 on a laptop; cycle counts are not comparable to published numbers.

## 2026-11-11 Performance run (raw: 71f58a4), clang-18.1.8, no LTO, WSL2, 11 rounds
- Median cycles per decapsulation (median of per-run medians):
  -Os: V0 99324, V1 108725, V2 80404, V3 77137.   -O3: V0 91157, V1 88025, V2 57364, V3 53878.
- Round-to-round spread per variant: about 3% to 11%.
- H6a (V1 vs V0 < 5%):  -Os +9.46% (quartiles +7.20 .. +10.08): not supported.
                        -O3 -3.36% (quartiles -4.54 .. -3.24): supported.
- H6b (V2 vs V3 < 5%):  -Os +4.17% (quartiles +2.65 .. +4.24): supported.
                        -O3 +6.59% (quartiles +4.34 .. +6.74): inconclusive.
- Reading: the cost of the source fix depends on the optimization level. Not investigated:
  why. Hypothesis only: at -Os, V1 makes 256 non-inlined calls to cmov_int16 per decapsulation.
- Limits: one compiler, no LTO, noisy VM; not re-run to chase a different verdict.

## 2026-11-11 Exploratory note on H6b at -O3
- clang-18 -O3 no LTO, instructions using xmm registers: V2 5741 of 10285, V3 6226 of 10731.
  At -Os: 443 vs 451. Consistent with the barriers inhibiting some vectorization at -O3.
  Static count only; not a proof of where the time goes.

## 2026-11-11 Before the dudect run (H5): definitions fixed in advance
- Tool: oreparaz/dudect at dc269651fb25 (2024-03-20), dudect.h vendored in third_party/dudect,
  sha256 3fb3b2bd7f9e... Thresholds are dudect's own: |t| > 10 probably not, > 500 definitely not.
- Harness dudect_dec.c: class 0 = one fixed valid ciphertext, class 1 = a fresh valid ciphertext
  per measurement; fixed key; ciphertexts generated outside the timed region.
- Budget per run: 10,000,000 measurements or 1800 s, whichever first. The run always goes to the
  budget; dudect's intermediate verdicts do not stop it. 3 repetitions, repetition as outer loop.
- Cells (clang-18, no LTO unless stated): V0 -Os, V1 -Os, V0 -O2nv, V1 -O2nv, V0 -Os LTO,
  V0-flags -Os, V2 -Os, V3 -Os. Same flags as the matrix cells, without -g.
- Reported per run: measurements, seconds, max |t|, index of the test giving it (0 uncropped,
  1..100 cropped, 101 second order), measurements in that test, dudect label.
- H5 decision rule: supported if max |t| of every V0 -Os repetition is larger than max |t| of
  every V1 -Os repetition. The other six cells are descriptive.
- DEVIATION from PREREGISTRATION.md section 7: RTLF is not run. Reason: dudect does not keep raw
  samples; storing 240 million samples and adding a second toolchain is out of scope for the
  remaining time. Consequence: timing evidence rests on dudect alone; no Holm-corrected RTLF
  result will be reported.
- Platform: WSL2 on a laptop. A large |t| is evidence of a timing difference between the two
  classes on this machine; a small |t| is not evidence of constant time.

## 2026-11-11 dudect session (H5), 18:49-22:04 local, no interruption
- 24 of 24 runs reached the full budget of 10,000,000 measurements (394 s to 566 s each).
- max |t| per repetition:
  V0 -Os       1011.78 / 1898.99 / 1789.31   definitely not constant time (all three)
  V1 -Os          2.05 /    1.90 /    2.65   maybe constant time
  V0 -O2nv     3017.43 / 2771.88 / 2409.22   definitely not constant time (all three)
  V1 -O2nv        2.18 /    1.59 /    1.48   maybe constant time
  V0 -Os LTO      2.86 /    2.22 /    1.54   maybe constant time
  V0-flags -Os    1.13 /    1.98 /    1.16   maybe constant time
  V2 -Os          2.20 /    2.07 /    1.43   maybe constant time
  V3 -Os          2.90 /    1.15 /    1.71   maybe constant time
- H5: supported. Smallest V0 -Os value 1011.78 > largest V1 -Os value 2.65.
- Agreement with Valgrind on all 8 cells: the two FLAGGED cells are the two with |t| > 500;
  the six unflagged cells all have |t| < 3.
- Limits: a large |t| shows a timing difference between the fixed and the fresh ciphertext
  class on this machine, not exploitability. A small |t| is not a proof of constant time.
  Attribution to poly_frommsg rests on Valgrind plus the fact that the difference disappears
  in V1, V0-flags and V0 with LTO. RTLF not run (deviation recorded before the run).
- Conditions: WSL2 laptop on mains power; light browser use during part of repetition 1.

## 2026-11-11 Prior-work check (before writing)
- clang 20: clangover branch already reported by Arranz-Olmos et al., OOPSLA 2026 (Clang 18 and
  20; -O0/-Os). Our clang 21.1.8 result extends this by one version. Not claimed as new.
- LTO and the cmov_int16 fix: Bernstein asked on pqc-forum, 2024-06-03, whether the fix breaks
  under -flto. Our data: cmov_int16 is inlined under LTO, yet no flagged branch in 9 of 9 V1 LTO
  cells and no dudect signal. No prior measurement of LTO as a factor found so far.
- -fno-vectorize / -fno-slp-vectorize not applied at LTO link stage: known LLVM issue #44779.
  Flag order confound ruled out (our command has -O2 before -fno-vectorize; works without LTO).
- -mllvm not reaching LTO passes: documented and intended (LLVM OptBisect docs; D79629 rejected).
  Our part: the consequence for the Fun-with-flags mitigation set. Not found in CT literature.
- Barrier ablation of mlkem-native: no prior report found; maintainers call the barrier
  hardening "a purely preventative measure" (v1.1.0 release notes).
- mlkem-native v2.0.0 ct-tests.yml: clang 6/20/21/22, gcc 4.8/14/15/16; -O0 -O1 -O2 -O3 -Os -Oz
  -Ofast; patched Valgrind (also flags variable-latency division). No LTO in the CT tests.
- Valgrind + dudect over a compiler matrix: done by CT-KAT (ePrint 2026/1418). Standard practice.
- Performance cost of the fix: no published figure found.
- Bibliography fix: RTLF is the 33rd USENIX Security Symposium (2024), not the 32nd.
- OPEN: CTGREP (ePrint 2026/2653) discusses -flto; full text not yet read. No novelty wording
  for the LTO results until this is checked by hand. LLVM issue search for clangover also open.

## 2026-11-12 CTGREP (ePrint 2026/2653, 2026-10-26) read in full; open item closed
- LTO appears twice, both descriptive: section 3 (pipeline background, "-flto ... merged into a
  single LLVM module and re-optimized") and section 4.4 (their instrumentation covers passes
  "including link time optimization"). No LTO factor in the results. No mention of linker, lld
  or -Wl. No value barriers. No Valgrind or dudect (compiler-internal differential analysis).
- Their scope: Clang 14/18/20, six platforms, ~4300 flags x 6 opt levels; GCC not covered.
- Their mitigation test (section 7): Fun-with-flags set on BearSSL, Clang 18, flags appended at
  driver level. Two bypasses, both from other flags (--disable-select-optimize=false,
  --fast-isel). They extend the set with -mllvm --disable-select-optimize=true and
  -mllvm --fast-isel=false. We tested the original three-flag set only (as pre-registered).
- mlkem-native: "The ML-KEM maintainers had mitigated the identified issues in mlkem-native
  before our report". Consistent with H2.
- Conclusion: CTGREP does not report (a) LTO measured as a factor for clangover, (b) stage of
  flag placement under LTO, (c) barrier ablation. Wording stays "to our knowledge".
- Apparent mismatch to explain: their Table 1 lists clangover on x86-64 at all levels except
  -O0; our V0 -O3 cells are NO ISSUE OBSERVED. Their oracle is static (branch present in the
  IR/binary), ours is dynamic (branch executed). Purnal's report says branch and vector code
  sit side by side at -O2/-O3. Checked next on our own -O3 binaries.

## 2026-11-12 CORRECTION to the 2026-11-11 prior-work entry
- That entry says "no flagged branch in 9 of 9 V1 LTO cells and no dudect signal". The dudect
  part is wrong: the dudect cell with LTO was V0 (v0_Os_lto), not V1. V1 with LTO was never run
  under dudect. Evidence for V1 with LTO is Valgrind only (9 of 9 NO ISSUE OBSERVED).
  The earlier line is left in place; this entry supersedes it.

## 2026-11-12 Prior-work check, sources read first-hand
- llvm/llvm-project issue search: "poly_frommsg" 0 results; "clangover" returns only fuzzy
  matches (clangd, clang-cl, ...), none about clangover on the first page.
- llvm-project #44779 "Thin LTO ignores -fno-vectorize and -fno-slp-vectorize": Open since
  2020-04-05. Comment there: the internal options "are subsequently unconditionally overridden
  to true by the linker code that sets up the LTO configurations"; a 2020 fix made the
  linker-side internal options usable as a workaround. Matches our clang 18/21 observations.
- LLVM OptBisect docs: "LTO passes are not affected by options passed to the driver-invoked
  LLVM invocation via -mllvm." Documentation basis for the flag-placement result.
- LTO and the cmov_int16 fix was questioned by Bernstein (pqc-forum, 2024-06-03), kroeckx
  (pq-crystals/kyber issue #76, 2024-06-04, still open) and Masken3 (comment on 9b8d306,
  2024-06-10). The author answered "Yes" on 2024-06-13 and called all such fixes "very hacky
  workarounds". No measurement is given in those threads.
- Purnal's clangover README: Clang 15-18; -Os, -O1, -O2 -fno-vectorize, -O3 -fno-vectorize.
  We tested two of these four (-Os, -O2 -fno-vectorize). -O1 and -O3 -fno-vectorize not tested.
- V1 is the initial fix commit 9b8d306. Whether pq-crystals main still uses it: not yet checked.

## 2026-11-12 EXPLORATORY: static look at V0 -O3 (no LTO), prompted by CTGREP Table 1
- First attempt (count "bt/test followed by a jump") was invalid: it reported 0 on
  v0_clang-18_O2nv, a cell with 8 known secret-dependent branches. Discarded.
- Reading the code instead. Control v0_clang-18_O2nv: testb $bit,(%rsi,%rax,1) / je, eight
  times, matching the 8 Valgrind contexts.
- v0_clang-18_O3 and v0_clang-21_O3 both contain the same testb/(je|jne) sequence on the message
  byte. clang-18 -O3 starts with two address comparisons (msg+0x20 vs r, r+0x200 vs msg) that
  jump away when the 32-byte input and the 512-byte output do not overlap; the branchy scalar
  code is the fall-through. The comparison is on addresses, not on secret data.
- Reading: at -O3 the secret-dependent branch is present in the binary but not executed on the
  tested path (buffers never overlap in decapsulation). This reconciles our NO ISSUE OBSERVED
  with CTGREP's static "all levels except -O0" and matches Purnal's 2024 remark that branch and
  vector code sit side by side. Not new; confirmed on our binaries including clang 21.1.8.
- Consequence for wording: NO ISSUE OBSERVED must never be read as "branch absent". The earlier
  phrase "under LTO the branch disappears" is to be re-checked per cell before it is used.

## 2026-11-12 Quality-completion list and freeze rule (decided before any of it is run)
- Remaining experimental work, all EXPLORATORY (not pre-registered) and reported as such:
  (1) finish the static look at V0 -O3 with LTO and gcc; (2) replicate all 84 cells five times
  with fresh keys; (3) Purnal's two untested configurations (-O1, -O3 -fno-vectorize) and dudect
  on V1 with LTO and on V0 -O3.
- Freeze: after (3) no further experiments, whatever the outcome. Then reproducibility package,
  tables/figures, writing.
- Replication, definition fixed in advance: a cell is "replicated" in a round if status, error
  count, context count, first location and flagged instruction offsets all equal the original
  run. Every round uses a new random key and ciphertext. Any difference is reported per cell;
  the original status is not changed afterwards.

## 2026-11-12 Replication result (raw: 2db1707)
- 5 rounds x 84 cells = 420 runs, each with a fresh random key and ciphertext, 27 min.
- 84 of 84 cells identical to the original run in every round (status, error count, context
  count, first location, flagged instruction offsets). No differing cell.
- The limit "one key, one ciphertext" becomes "six independent keys and ciphertexts per cell".
  Still executed-path only: the dormant -O3 branch was not exercised in any of the six runs.

## 2026-11-12 Before the last exploratory runs: definitions fixed in advance
- Tooling: run_cell.sh gets two more optimisation names, O1 (-O1) and O3nv (-O3 -fno-vectorize;
  gcc: -fno-tree-vectorize). Existing names unchanged; the session re-runs V0 clang-18 -Os as
  a control.
- (3a) Valgrind, 12 cells: V0 and V1 x clang-18, clang-21, gcc-15 x {-O1, -O3 -fno-vectorize},
  no LTO. These are the two configurations of Purnal's report missing from our matrix.
- (3b) dudect, 4 cells x 3 repetitions, same harness and fixed budget as the H5 session:
  V1 -Os LTO, V1 -O2nv LTO, V0 -O3, V0 -O1 (all clang-18).
- No hypothesis is attached; results are descriptive. After these runs: freeze.

## 2026-11-12 Last exploratory runs (raw: 22f6581 and the dudect_extra commit)
- (3a) Valgrind, 12 cells, no LTO. Control V0 clang-18 -Os FLAGGED (2027:jae) with the extended
  runner. V0 -O1: FLAGGED on clang-18 and clang-21 (1 context, jae). V0 -O3 -fno-vectorize:
  FLAGGED on clang-18 and clang-21 (15 contexts). All V1 cells and all gcc-15 cells: NO ISSUE
  OBSERVED. All four configurations of Purnal's report are now covered; on clang 18.1.8 and
  21.1.8 each of them flags V0 and none flags V1.
- (3b) dudect, 12 of 12 runs to the full budget, 17:57-19:25 local, no interruption. max |t|:
  V1 -Os LTO     2.06 / 1.71 / 1.44      maybe constant time
  V1 -O2nv LTO   1.21 / 2.57 / 1.75      maybe constant time
  V0 -O3         2.22 / 1.45 / 1.47      maybe constant time (branch present, not executed)
  V0 -O1      2458.90 / 2615.82 / 2130.90  definitely not constant time
- dudect and Valgrind now agree on 12 of 12 cells tested with both.
- V1 with LTO: cmov_int16 is inlined, yet neither Valgrind (9 cells, six keys each) nor dudect
  (2 cells, 30 million measurements each) shows a secret-dependent branch or timing difference.
  This is a statement about these builds, not about LTO in general.

## 2026-11-12 EXPERIMENT FREEZE
- No further experiments. Totals: 84 pre-registered cells; 420 replication runs; 12 + 9
  exploratory Valgrind cells/variants; 36 dudect runs; 88 benchmark runs.
- Remaining work is analysis of existing binaries and logs, the reproducibility package,
  tables/figures and writing.

## 2026-11-12 Static look completed (analysis of existing binaries; no new experiment)
- clang-18 -O3 no LTO: jump target 332e is vector code (movq (%rsi),%xmm13; punpcklbw ...).
  Confirms the reading: non-overlapping buffers take the vector path, the branchy scalar code is
  the fall-through for overlapping buffers.
- Where the constant 0x681 is used: clang-18 -Os 1 mov (after jae); clang-18 -O3 8 mov (dormant
  scalar copy); clang-18 -O3 LTO 2 mov, each followed by cmove/cmovns (conditional move, no
  branch), next to pandn vector code; gcc-15 -Os and/add only.
- gcc-15 -Os poly_frommsg: sar / and $1 / neg / and $0x681, a literal translation of the source
  mask arithmetic. No branch on the message bit, no vector code.
- Not examined: two mov $0x681 sites in gcc-15 -O3. The gcc -O3 statement rests on Valgrind
  (six keys), not on reading the code.
- Six forms of poly.c:178 observed: jae (clang -Os), vector plus dormant testb/je (clang -O3),
  pandn (clang LTO), cmovae (flags), sar/and/neg/and (gcc), call cmov_int16 (V1).

## 2026-11-13 Repository history: author identity unified
- Every commit now carries one author identity (Hasibul Islam Shanto). Commit dates, messages and
  file contents are unchanged; the commit ids changed as a consequence.
- Commit ids written in earlier entries are the ids at the time of writing. Current history, old -> new:
    cc7db9e -> b5a8d1b  2026-11-06  Week 1: WSL2 environment and toolchain
    bd795bd -> 7cfb7d9  2026-11-07  V0/V1 provenance verified
    c03659b -> 844e7c7  2026-11-07  Note b628ba7 Makefile layout
    3e7c6fa -> caa335a  2026-11-07  V0 clang-18 -Os: branch candidate in poly_frommsg
    3565710 -> ef9a07b  2026-11-07  V1 clang-18 -Os: no branch on secret; V0/V1 matched comparison
    b70f664 -> f2b3ae4  2026-11-11  Pre-registration (before any Valgrind/dudect results)
    2ec5cc0 -> 8c5647e  2026-11-11  Log pre-registration hash
    e3d7712 -> 23a71ff  2026-11-11  toy_leak control: L flagged, C clean (clang-18 -Os)
    3713c86 -> 3a309be  2026-11-11  ct_valgrind on V0/V1 clang-18 -Os (H1 run)
    e873436 -> 3749349  2026-11-11  Ignore compiled binaries
    1c1f123 -> d5efc11  2026-11-11  H1 supported: V0 flagged, V1 clean (clang-18 -Os)
    a7989ad -> 81e0f57  2026-11-11  run_cell.sh: automated cell runner; reproduces H1 by script
    b2ce97c -> f1e2545  2026-11-11  Kyber-ref matrix: 36 cells (V0/V1 x 3 compilers x 3 opt x LTO), raw results
    07aca79 -> 2665188  2026-11-11  Log matrix results, H3, and LTO root cause
    2df259a -> 444ac8c  2026-11-11  Exploratory: link-time vectorizer flags on V0 clang-18 O2nv LTO (raw)
    0a909a9 -> 309aeea  2026-11-11  Exploratory LTO vectorizer result: replicated, logged
    c6ccb32 -> 199b278  2026-11-11  Fix V0-flags definitions before the run
    4989232 -> fef51d5  2026-11-11  V0-flags: 12 pre-registered cells + controls (raw)
    dbc8a8b -> de4bfb5  2026-11-11  Log H7 supported, H8 undecided by design
    5d5ac93 -> b6278f5  2026-11-11  Exploratory: protective flag placement under LTO with vectorizers off (raw, 2 runs)
    028a854 -> d7adfda  2026-11-11  Log V0-flags root cause and exploratory LTO placement result
    a551460 -> 61ab808  2026-11-11  V2 provenance verified
    645cf55 -> 47a0ccb  2026-11-11  Fix mlkem-native definitions before the run
    88030f0 -> 3efd827  2026-11-11  mlkem-native: controls + 36 cells (V2, V3), raw results
    f77b779 -> 993be54  2026-11-11  Log H2 supported, H4 not supported under tested conditions
    f8895dc -> f468747  2026-11-11  Log V2/V3 code comparison
    3fb12ed -> afc1572  2026-11-11  Fix performance definitions before the run
    42d1033 -> 40d72e0  2026-11-11  Performance: decapsulation cycles, V0-V3, clang-18 -Os/-O3, 11 rounds (raw)
    f5503b7 -> 1dbd2d8  2026-11-11  Log H6a/H6b results
    ab7021e -> 0b3b462  2026-11-11  Vendor dudect; fix H5 definitions; record RTLF deviation
    45c0616 -> f9e6eb7  2026-11-11  dudect harness and session runner
    7d5f6e5 -> cb8edbe  2026-11-11  dudect: 8 cells x 3 repetitions, fixed budget (raw)
    10b9cbe -> 9074a5a  2026-11-11  Log H5 supported; dudect agrees with Valgrind on 8 of 8 cells
    a812c33 -> 3f4c016  2026-11-11  Log prior-work check; CTGREP still open
    8bdb8c3 -> 75048e5  2026-11-12  CTGREP read in full; novelty wording settled; -O3 static check pending
    575d8a9 -> 2285eaa  2026-11-12  Correct dudect/V1-LTO statement; log first-hand prior-work sources
    c1bf6ae -> b31f8bc  2026-11-12  Exploratory: dormant branch in V0 -O3 binaries (static vs dynamic)
    3f6b086 -> a0dd8b7  2026-11-12  Quality-completion list, freeze rule, replication definition
    1dfb9d1 -> 7ccd1cf  2026-11-12  Replication: 84 cells x 5 rounds with fresh keys (raw)
    625b95e -> 37537ee  2026-11-12  Log replication result; define last exploratory runs
    50b35c0 -> 4ba5796  2026-11-12  Exploratory: Purnal's -O1 and -O3 -fno-vectorize configurations, 12 cells (raw)
    52488bb -> 518936c  2026-11-12  Exploratory: dudect on V1 LTO, V0 -O3, V0 -O1 (raw)
    536b859 -> d7bf803  2026-11-12  Log last exploratory results; experiment freeze
    afdb546 -> e4ff12b  2026-11-12  Static look completed; six code forms of poly.c:178
    0ad7561 -> c955932  2026-11-12  Reproducibility: source setup, environment record, fresh-clone test
    5f7ff24 -> 6d71739  2026-11-12  Fresh-clone reproducibility test result
    4c3a5eb -> 5dbd575  2026-11-12  Thesis tables generated from result CSVs
    1948e12 -> 0a2a504  2026-11-12  Six compiled forms of poly.c:178, extracted from own binaries
    09f4e99 -> c4a0580  2026-11-12  Add README for the reproducibility package
    9bc91e5 -> abbe2c9  2026-11-12  Add verified bibliography for the thesis
    8deb671 -> 7a3b904  2026-11-12  Add LaTeX thesis skeleton (main.tex)
    0a8cc82 -> 94c2991  2026-11-13  Switch write-up to IEEE format; write full methodology
- Correction to the pre-registration entry: it cites commit 1ccec53. That was the id of the
  pre-registration commit when it was made. The same commit is now f2b3ae4: author date
  2026-11-11 12:20:41 +0600, identical file tree (4be12a2a62b0). Only the commit id differs.
