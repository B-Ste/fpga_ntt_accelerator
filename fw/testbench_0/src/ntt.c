#include "ntt.h"
#include "math.h"

int32_t mod_addition(int32_t a, int32_t q) {
    return a > q ? a - q : a;
}

int32_t mod_subtraction(int32_t a, int32_t q) {
    return a < 0 ? a + q : a;
}

#define L 30
int32_t mod_barrett(int64_t a, int32_t q) {
    const uint64_t lpower_2Lp3 = 1LL << (2 * L + 3);
    const uint64_t lpower_Lm2 = 1LL << (L - 2);
    const uint64_t lpower_Lp5 = 1LL << (L +  5);
    const uint64_t lpower_Lp1 = 1LL << (L + 1);
    const uint64_t lambda = lpower_2Lp3 / q;
    uint64_t q_hat = floor(floor(a / lpower_Lm2) * lambda) / lpower_Lp5;
    int64_t r0 = (a - q_hat * q) & (lpower_Lp1 - 1);
    int64_t r1 = r0 - q;
    return r1 >= 0 ? r1 : r0;
}

void ntt(int32_t q, int32_t* psis, int32_t* a) {
    int t = N;
    for (int m = 1; m < N; m *= 2) {
        t /= 2;
        for (int i = 0; i < m; i++) {
            int j_1 = 2 * i * t;
            int j_2 = j_1 + t - 1;
            int32_t w = psis[m + i];
            for (int j = j_1; j <= j_2; j++) {
                int32_t U = a[j];
                int32_t V = mod_barrett((int64_t) w * a[j + t], q);
                a[j] = mod_addition(U + V, q);
                a[j + t] = mod_subtraction(U - V, q);
            }
        }
    }
}

void intt(int32_t inv_n, int32_t q, int32_t* psis, int32_t* a) {
    int t = 1;
    for (int m = N; m > 1; m /= 2) {
        int j_1 = 0;
        int h = m / 2;
        for (int i = 0; i < h; i++) {
            int j_2 = j_1 + t - 1;
            int32_t w = psis[h + i];
            for (int j = j_1; j <= j_2; j++) {
                int32_t U = a[j];
                int32_t V = a[j + t];
                int32_t inner = mod_subtraction(U - V, q);
                a[j] = mod_addition(U + V, q);
                a[j + t] = mod_barrett((int64_t) w * inner, q);
            }
            j_1 += 2 * t;
        }
        t *= 2;
    }
    for (int j = 0; j < N; j++) a[j] = mod_barrett((int64_t) a[j] * inv_n, q);
}

void nwc_ntt(int32_t q, int32_t* psis, int32_t* psi_ns, int32_t n_neg, int32_t* a, int32_t* b, int32_t* c) {
    ntt(q, psis, a);
    ntt(q, psis, b);
    for (int i = 0; i < N; i++) c[i] = mod_barrett((int64_t) a[i] * b[i], q);
    intt(n_neg, q, psi_ns, c);
}

void create_polynomial(int32_t* a, int32_t q) {
	for (int i = 0; i < N; i++) {
		a[i] = mod_barrett(i, q);
	}
}

int32_t brv(int32_t i, int32_t n) {
    int32_t brv = 0;
    while (n--) {
        brv = (brv << 1) | (i & 1);
        i >>= 1;
    }
    return brv;
}

void brv_powers(int32_t *brv_pwr, int32_t p, int32_t q, int32_t n) {
    int32_t tmp = 1;
    brv_pwr[0] = 1;
    for (int i = 1; i < n; i++) {
        int32_t r = mod_barrett((int64_t) tmp * p, q);
        brv_pwr[brv(i, 12)] = r;
        tmp = r;
    }
}
