#ifndef NTT_H
#define NTT_H

#include "xil_types.h"

#define N 4096
#define NUM_Q 13

void create_polynomial(int32_t*, int32_t);
void nwc_ntt(int32_t, int32_t*, int32_t*, int32_t, int32_t*, int32_t*, int32_t*);
void brv_powers(int32_t*, int32_t, int32_t, int32_t);
int32_t mod_barrett(int64_t, int32_t);

#endif
