/* bench_dec.c - cycle count of one decapsulation (valid ciphertext, fixed key).
 * Kyber ref: build inside ref/ with -DKYBER_K=2.  mlkem-native: add -DBENCH_MLKEM. */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <stddef.h>
#include <x86intrin.h>

#ifdef BENCH_MLKEM
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

#define WARMUP 2000
#define N 20000

static int cmp_u64(const void *a, const void *b) {
    uint64_t x = *(const uint64_t *)a, y = *(const uint64_t *)b;
    return (x > y) - (x < y);
}

int main(void) {
    static uint8_t pk[PK_BYTES], sk[SK_BYTES], ct[CT_BYTES], ss_e[SS_BYTES], ss_d[SS_BYTES];
    static uint64_t t[N];
    unsigned aux;
    int bad = 0;

    if (KEYPAIR(pk, sk) != 0 || ENC(ct, ss_e, pk) != 0) return 2;
    for (int i = 0; i < WARMUP; i++) bad |= DEC(ss_d, ct, sk);
    for (int i = 0; i < N; i++) {
        _mm_lfence();
        uint64_t t0 = __rdtsc();
        bad |= DEC(ss_d, ct, sk);
        uint64_t t1 = __rdtscp(&aux);
        t[i] = t1 - t0;
    }
    bad |= memcmp(ss_d, ss_e, SS_BYTES) != 0;
    qsort(t, N, sizeof t[0], cmp_u64);
    printf("median=%llu q1=%llu q3=%llu min=%llu n=%d ok=%d\n",
           (unsigned long long)t[N / 2], (unsigned long long)t[N / 4],
           (unsigned long long)t[3 * N / 4], (unsigned long long)t[0], N, !bad);
    return bad ? 3 : 0;
}
