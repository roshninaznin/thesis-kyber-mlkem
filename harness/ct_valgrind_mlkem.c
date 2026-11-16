/* ct_valgrind_mlkem.c - Valgrind constant-time harness for mlkem-native, ML-KEM-512.
 * Same taint model as ct_valgrind.c: s (first 768 bytes of sk) and z (last 32 bytes) are
 * secret; pk and H(pk) inside sk stay public. Only decapsulation runs on tainted data.
 * Build with -DMLK_CONFIG_PARAMETER_SET=512 -DMLK_CONFIG_NAMESPACE_PREFIX=mlkem. */
#include <stdio.h>
#include <string.h>
#include <stdint.h>
#include <stddef.h>
#include <sys/types.h>
#include <sys/random.h>
#include <valgrind/memcheck.h>
#include "mlkem_native.h"
#include "expected_test_vectors.h"   /* upstream known answers (examples/basic) */

#define SECRET(p, n) VALGRIND_MAKE_MEM_UNDEFINED((p), (n))
#define PUBLIC(p, n) VALGRIND_MAKE_MEM_DEFINED((p), (n))
#define SK_BYTES MLKEM512_SECRETKEYBYTES
#define PK_BYTES MLKEM512_PUBLICKEYBYTES
#define CT_BYTES MLKEM512_CIPHERTEXTBYTES

_Static_assert(MLK_CONFIG_PARAMETER_SET == 512, "build with -DMLK_CONFIG_PARAMETER_SET=512");
_Static_assert(SK_BYTES == 768 + 800 + 32 + 32, "unexpected sk layout");

const char ct_anchor = 0;   /* known symbol: lets the cell runner compute the load address */

/* mlkem-native does not ship a random source; the consumer provides randombytes(). */
int randombytes(uint8_t *out, size_t outlen);
int randombytes(uint8_t *out, size_t outlen) {
    while (outlen > 0) {
        ssize_t n = getrandom(out, outlen, 0);
        if (n < 0) return -1;
        out += n; outlen -= (size_t)n;
    }
    return 0;
}

int main(void) {
    static uint8_t pk[PK_BYTES], sk[SK_BYTES], ct[CT_BYTES], ss_e[MLKEM_BYTES], ss_d[MLKEM_BYTES];
    uint8_t coins[2 * MLKEM_SYMBYTES];
    int kat, r, ok;

    /* 1. known-answer test, everything public: is this build functionally correct? */
    memcpy(coins, test_vector_d, MLKEM_SYMBYTES);
    memcpy(coins + MLKEM_SYMBYTES, test_vector_z, MLKEM_SYMBYTES);
    kat = mlkem_keypair_derand(pk, sk, coins) == 0
       && memcmp(pk, test_vector_pk, PK_BYTES) == 0
       && memcmp(sk, test_vector_sk, SK_BYTES) == 0
       && mlkem_enc_derand(ct, ss_e, pk, test_vector_m) == 0
       && memcmp(ct, test_vector_ct, CT_BYTES) == 0
       && memcmp(ss_e, test_vector_ss, MLKEM_BYTES) == 0
       && mlkem_dec(ss_d, ct, sk) == 0
       && memcmp(ss_d, test_vector_ss, MLKEM_BYTES) == 0;

    /* 2. fresh key and ciphertext, then decapsulation with the secret parts of sk tainted */
    if (mlkem_keypair(pk, sk) != 0) return 2;
    if (mlkem_enc(ct, ss_e, pk) != 0) return 2;

    SECRET(sk, 768);                 /* s */
    SECRET(sk + SK_BYTES - 32, 32);  /* z */
    r = mlkem_dec(ss_d, ct, sk);
    PUBLIC(ss_d, sizeof ss_d);       /* intended output */
    PUBLIC(&r, sizeof r);
    PUBLIC(sk, sizeof sk);

    ok = (r == 0) && memcmp(ss_d, ss_e, MLKEM_BYTES) == 0;
    printf("dec=%d match=%d kat=%d anchor=%p\n", r, ok, kat, (const void *)&ct_anchor);
    return (ok && kat) ? 0 : 3;
}
