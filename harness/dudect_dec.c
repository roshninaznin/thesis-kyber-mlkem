/* dudect_dec.c - dudect leakage-detection harness for decapsulation (H5).
 * Classes (PREREGISTRATION.md section 7): class 0 = one fixed valid ciphertext, class 1 = a
 * fresh valid ciphertext per measurement; fixed key; inputs are prepared outside the timed region.
 * This is a statistical detection test (do the two timing distributions differ?), nothing more.
 * Usage: dudect_dec [max_measurements] [max_seconds]   (defaults 10000000 and 1800)
 * Kyber ref: build inside ref/ with -DKYBER_K=2.  mlkem-native: add -DDUT_MLKEM. */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <stddef.h>
#include <time.h>

/* dudect ships its own randombytes(); rename it so it cannot clash with the library's. */
#define randombytes dudect_randombytes
#define DUDECT_IMPLEMENTATION
#include "dudect.h"
#undef randombytes

#ifdef DUT_MLKEM
#include <sys/types.h>
#include <sys/random.h>
#include "mlkem_native.h"
#define SK_BYTES MLKEM512_SECRETKEYBYTES
#define PK_BYTES MLKEM512_PUBLICKEYBYTES
#define CT_BYTES MLKEM512_CIPHERTEXTBYTES
#define SS_BYTES MLKEM_BYTES
#define KEYPAIR mlkem_keypair
#define ENC mlkem_enc
#define DEC mlkem_dec
int randombytes(uint8_t *out, size_t outlen);
int randombytes(uint8_t *out, size_t outlen) {
    while (outlen > 0) {
        ssize_t n = getrandom(out, outlen, 0);
        if (n < 0) return -1;
        out += n; outlen -= (size_t)n;
    }
    return 0;
}
#else
#include "kem.h"
#define SK_BYTES CRYPTO_SECRETKEYBYTES
#define PK_BYTES CRYPTO_PUBLICKEYBYTES
#define CT_BYTES CRYPTO_CIPHERTEXTBYTES
#define SS_BYTES CRYPTO_BYTES
#define KEYPAIR crypto_kem_keypair
#define ENC crypto_kem_enc
#define DEC crypto_kem_dec
#endif

#define BATCH 10000   /* measurements per dudect batch */

static uint8_t pk[PK_BYTES], sk[SK_BYTES], fixed_ct[CT_BYTES];

uint8_t do_one_computation(uint8_t *data) {
    uint8_t ss[SS_BYTES];
    int r = DEC(ss, data, sk);
    return (uint8_t)(ss[0] ^ (uint8_t)r);
}

void prepare_inputs(dudect_config_t *c, uint8_t *input_data, uint8_t *classes) {
    uint8_t ss[SS_BYTES];
    for (size_t i = 0; i < c->number_measurements; i++) {
        classes[i] = randombit();
        if (classes[i] == 0) {
            memcpy(input_data + i * c->chunk_size, fixed_ct, CT_BYTES);
        } else if (ENC(input_data + i * c->chunk_size, ss, pk) != 0) {
            abort();
        }
    }
}

int main(int argc, char **argv) {
    size_t max_meas = (argc > 1) ? (size_t)strtoull(argv[1], NULL, 10) : 10000000u;
    long max_sec = (argc > 2) ? strtol(argv[2], NULL, 10) : 1800;
    uint8_t ss[SS_BYTES];
    dudect_config_t config = { .chunk_size = CT_BYTES, .number_measurements = BATCH };
    dudect_ctx_t ctx;
    size_t done = 0;
    time_t start = time(NULL);

    if (KEYPAIR(pk, sk) != 0 || ENC(fixed_ct, ss, pk) != 0) return 2;
    dudect_init(&ctx, &config);
    /* fixed budget: run to the limit whatever dudect says on the way (no optional stopping) */
    while (done < max_meas && (long)(time(NULL) - start) < max_sec) {
        (void)dudect_main(&ctx);
        done += BATCH;
    }

    ttest_ctx_t *best = max_test(&ctx);
    int idx = -1;
    for (int i = 0; i < DUDECT_TESTS; i++) if (ctx.ttest_ctxs[i] == best) idx = i;
    double t = fabs(t_compute(best));
    const char *label = (t > t_threshold_bananas) ? "definitely_not_constant_time"
                      : (t > t_threshold_moderate) ? "probably_not_constant_time"
                      : "maybe_constant_time";
    /* test_index: 0 = uncropped, 1..100 = cropped at that percentile index, 101 = second order */
    printf("FINAL measurements=%zu seconds=%ld max_abs_t=%.2f test_index=%d n_in_test=%.0f label=%s\n",
           done, (long)(time(NULL) - start), t, idx, best->n[0] + best->n[1], label);
    dudect_free(&ctx);
    return 0;
}
