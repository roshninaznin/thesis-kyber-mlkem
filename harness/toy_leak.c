/* toy_leak.c - detector control.
 * Valgrind MUST flag leaky_eq (mode L) and MUST NOT flag ct_eq (mode C). */
#include <stdio.h>
#include <string.h>
#include <stdint.h>
#include <valgrind/memcheck.h>

#define SECRET(p, n) VALGRIND_MAKE_MEM_UNDEFINED((p), (n))
#define PUBLIC(p, n) VALGRIND_MAKE_MEM_DEFINED((p), (n))

__attribute__((noinline))
static int leaky_eq(const uint8_t *a, const uint8_t *b, size_t n) {
    for (size_t i = 0; i < n; i++)
        if (a[i] != b[i]) return 0;      /* early exit = branch on secret */
    return 1;
}

__attribute__((noinline))
static int ct_eq(const uint8_t *a, const uint8_t *b, size_t n) {
    uint8_t d = 0;
    for (size_t i = 0; i < n; i++) d |= a[i] ^ b[i];
    uint32_t x = d;
    return (int)((x - 1) >> 31);         /* 1 if d == 0, else 0; no branch */
}

int main(int argc, char **argv) {
    int mode = (argc > 1) ? argv[1][0] : 'L';
    uint8_t key[16], guess[16];
    memset(key, 0x41, sizeof key);
    memset(guess, 0x41, sizeof guess);
    guess[15] = 0x42;

    SECRET(key, sizeof key);
    int ok = (mode == 'L') ? leaky_eq(key, guess, sizeof key)
                           : ct_eq(key, guess, sizeof key);
    PUBLIC(&ok, sizeof ok);

    printf("mode=%c ok=%d\n", mode, ok);
    return 0;
}
