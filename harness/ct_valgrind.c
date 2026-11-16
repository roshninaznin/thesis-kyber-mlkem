/* ct_valgrind.c - Valgrind constant-time harness, pq-crystals Kyber ref, KYBER_K=2.
 * Marks the secret parts of sk undefined, runs decapsulation, and lets memcheck
 * report any branch or memory index that depends on them. */
#include <stdio.h>
#include <string.h>
#include <stdint.h>
#include <valgrind/memcheck.h>
#include "kem.h"
#include "params.h"

#define SECRET(p, n) VALGRIND_MAKE_MEM_UNDEFINED((p), (n))
#define PUBLIC(p, n) VALGRIND_MAKE_MEM_DEFINED((p), (n))

_Static_assert(KYBER_K == 2, "build with -DKYBER_K=2");
_Static_assert(KYBER_INDCPA_SECRETKEYBYTES == 768, "unexpected sk layout");
_Static_assert(CRYPTO_SECRETKEYBYTES == 768 + 800 + 32 + 32, "unexpected sk layout");
const char ct_anchor = 0;   /* known symbol: lets run_cell.sh compute the load address */
int main(void) {
    static uint8_t pk[CRYPTO_PUBLICKEYBYTES], sk[CRYPTO_SECRETKEYBYTES];
    static uint8_t ct[CRYPTO_CIPHERTEXTBYTES], ss_e[CRYPTO_BYTES], ss_d[CRYPTO_BYTES];

    if (crypto_kem_keypair(pk, sk) != 0) return 2;
    if (crypto_kem_enc(ct, ss_e, pk) != 0) return 2;

    SECRET(sk, KYBER_INDCPA_SECRETKEYBYTES);        /* s */
    SECRET(sk + CRYPTO_SECRETKEYBYTES - 32, 32);    /* z */
    int r = crypto_kem_dec(ss_d, ct, sk);
    PUBLIC(ss_d, sizeof ss_d);                      /* intended output */
    PUBLIC(&r, sizeof r);
    PUBLIC(sk, sizeof sk);

    int ok = (r == 0) && memcmp(ss_d, ss_e, CRYPTO_BYTES) == 0;
    printf("dec=%d match=%d anchor=%p\n", r, ok, (const void *)&ct_anchor);
    return ok ? 0 : 3;
}
