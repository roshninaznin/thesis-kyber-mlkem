# Compiler-Configuration Assessment of Constant-Time Behaviour in ML-KEM

Artifact for a BSc thesis. It measures how the C compiler and its configuration
affect a known constant-time violation in ML-KEM (Kyber), CVE-2024-37880
("clangover"), and evaluates three countermeasures: the upstream source fix,
compiler flags, and the value barriers of mlkem-native.

## Scope and ethics

This is a defensive **detection** study. It finds, explains, mitigates and
re-checks a secret-dependent branch. It does **not** reproduce key recovery.
Exploitability is cited from published work (Purnal, CVE-2024-37880). No
attack code is included.

Detection uses Valgrind (ctgrind-style secret tainting) and dudect (timing
statistics), cross-checked against the disassembly. "NO ISSUE OBSERVED" means
nothing was detected on the executed path; it is not a proof of constant time.

## What is compared

| Name | Source |
|---|---|
| V0 | pq-crystals/kyber ref @ b628ba7 (vulnerable) |
| V1 | pq-crystals/kyber ref @ 9b8d306 (upstream fix, cmov_int16) |
| V0-flags | V0 built with the "Fun with flags" LLVM flag set |
| V2 | mlkem-native v2.0.0 @ d1b2fe7 (stock) |
| V3 | V2 with the three value barriers removed (patches/v3_no_barriers.patch) |
| v2leak | V2 with a planted leak, detector control (patches/v2leak_planted.patch) |

Compilers: clang 18.1.8, clang 21.1.8, gcc 15.2.0.
Optimisation: -Os, -O2 -fno-vectorize, -O3 (and -O1, -O3 -fno-vectorize as extras).
LTO: off / on. Target: x86-64. See ENVIRONMENT.md for exact versions.

## How to reproduce

Prerequisites: the compilers and Valgrind in ENVIRONMENT.md, plus git and internet.
All scripts resolve paths from `$HOME` and expect this repo at
`$HOME/thesis/thesis-artifact`.

Clean-room check (clones a fresh copy, re-fetches sources, re-runs 84 cells, ~10 min):

    harness/fresh_clone_test.sh

Step by step:

    harness/setup_sources.sh        # fetch/pin the five source trees under ../ 
    harness/run_matrix_ref.sh       # V0/V1 matrix        -> results/cells.csv
    harness/run_matrix_mlkem.sh     # V2/V3 + controls    -> results/mlkem.csv
    harness/run_flags.sh            # V0-flags (H7,H8)    -> results/flags.csv
    harness/run_purnal_extra.sh     # -O1, -O3nv          -> results/purnal_extra.csv
    harness/run_bench.sh            # decapsulation cycles-> results/bench/
    harness/run_dudect.sh           # timing, ~5-6 h      -> results/dudect/
    harness/run_dudect_extra.sh     # timing extras, ~2 h -> results/dudect_extra/
    harness/replicate.sh            # 84 cells x 5 keys   -> results/replication/
    harness/make_tables.sh          # tables from the CSVs-> results/TABLES.md
    harness/make_figure.sh          # six code forms      -> results/FIGURE_six_forms.txt

Each session re-runs its detector controls (toy_leak, planted V0/v2leak) and stops
if a control is not caught.

## Layout

    PREREGISTRATION.md   plan committed before any Valgrind/dudect result
    LOGBOOK.md           dated record of every run, decision and deviation
    ENVIRONMENT.md       machine, compiler and tool versions
    harness/             C harnesses and shell runners
    patches/             the V3 and v2leak source modifications
    third_party/dudect/  vendored dudect.h (MIT)
    results/             CSVs, per-cell logs, TABLES.md, FIGURE_six_forms.txt

## Headline findings

Reported as supported / not supported under the tested conditions only.

- V0 shows a secret-dependent branch under clang -Os and -O2 -fno-vectorize;
  V1, the flags, gcc, and -O3 do not. Valgrind and dudect agree on all 12 cells
  tested with both; the two flagged cells have |t| > 1000, the rest |t| < 3.
- LTO changes the outcome: it removes the branch from V0 by vectorising after
  inlining, and the fix's cmov_int16 is inlined under LTO yet stays unflagged.
- The flag mitigation must be given to the linker under LTO (-Wl,-mllvm,...);
  the driver-level form is ignored there (LLVM issue #44779, OptBisect docs).
- Removing mlkem-native's barriers changed the code in 18/18 configurations but
  produced no flagged branch; the planted-leak control was caught in 6/6.
- All 84 cells reproduced identically across five independent keys and from a
  fresh clone.

## Prior work

clangover / CVE-2024-37880 (Purnal 2024); the fix commit 9b8d306 and its LTO
discussion (pq-crystals/kyber issue #76); "Fun with flags" (Geimer & Maurice,
arXiv 2507.06112); CTGREP (ePrint 2026/2653); CT-KAT (ePrint 2026/1418);
dudect (Reparaz et al., DATE 2017); ctgrind (Langley 2010). See the thesis for
the full bibliography and how this work relates to each.
