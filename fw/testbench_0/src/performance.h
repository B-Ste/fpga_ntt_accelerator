/* See LICENSE file for license and copyright information */

#ifndef ARM_V8_TIMING_H
#define ARM_V8_TIMING_H

#include <stdint.h>
#include "xil_printf.h"
#include "stdio.h"

#define ARMV8_PMCR_E            (1 << 0) /* Enable all counters */
#define ARMV8_PMCR_P            (1 << 1) /* Reset all counters */
#define ARMV8_PMCR_C            (1 << 2) /* Cycle counter reset */
#define ARMV8_PMCR_D            (1 << 3) /* Unset 64-cycle counting */

#define ARMV8_PMUSERENR_EN      (1 << 0) /* EL0 access enable */
#define ARMV8_PMUSERENR_CR      (1 << 2) /* Cycle counter read enable */
#define ARMV8_PMUSERENR_ER      (1 << 3) /* Event counter read enable */

#define ARMV8_PMCNTENSET_EL0_EN (1 << 31) /* Performance Monitors Count Enable Set register */

uint64_t time_start;
uint64_t time_delta;
uint64_t time_comb;
uint64_t initiations;
float t;

#define START_TIMING time_start = arm_v8_get_timing();

#define INTERMEDIATE_TIME 							\
	time_delta  = arm_v8_get_timing();  			\
	time_delta -= time_start;      					\
	time_comb += time_delta;						\
	initiations++;

#define STOP_TIMING                     			\
	t = (float)time_comb;    						\
    t /=  1200;									\
    t /= initiations;								\
    printf("Timing over %lu iterations: %f us \n\r", initiations, t);	\
    time_comb = 0; initiations = 0;					\

// #define STOP_TIMING  printf("TIMING: %lu cycles %f ms \n\r", (uint64_t)(arm_v8_get_timing()-time_start), (float)((arm_v8_get_timing()-time_start)/1200000));


static inline uint64_t arm_v8_get_timing(void)
{
  uint64_t result = 0;

  asm volatile("MRS %0, PMCCNTR_EL0" : "=r" (result));

  return result;
}

static inline void arm_v8_timing_init(void)
{
  uint32_t value = 0;
  time_comb = 0;
  initiations = 0;

  /* Enable Performance Counter */
  asm volatile("MRS %0, PMCR_EL0" : "=r" (value));
  value |= ARMV8_PMCR_E; /* Enable */
  value |= ARMV8_PMCR_C; /* Cycle counter reset */
  value |= ARMV8_PMCR_P; /* Reset all counters */
  value ^= ARMV8_PMCR_D;
  asm volatile("MSR PMCR_EL0, %0" : : "r" (value));

  /* Enable cycle counter register */
  asm volatile("MRS %0, PMCNTENSET_EL0" : "=r" (value));
  value |= ARMV8_PMCNTENSET_EL0_EN;
  asm volatile("MSR PMCNTENSET_EL0, %0" : : "r" (value));
}

static inline void arm_v8_timing_terminate(void)
{
  uint32_t value = 0;
  uint32_t mask = 0;

  /* Disable Performance Counter */
  asm volatile("MRS %0, PMCR_EL0" : "=r" (value));
  mask = 0;
  mask |= ARMV8_PMCR_E; /* Enable */
  mask |= ARMV8_PMCR_C; /* Cycle counter reset */
  mask |= ARMV8_PMCR_P; /* Reset all counters */
  asm volatile("MSR PMCR_EL0, %0" : : "r" (value & ~mask));

  /* Disable cycle counter register */
  asm volatile("MRS %0, PMCNTENSET_EL0" : "=r" (value));
  mask = 0;
  mask |= ARMV8_PMCNTENSET_EL0_EN;
  asm volatile("MSR PMCNTENSET_EL0, %0" : : "r" (value & ~mask));
}

static inline void arm_v8_reset_timing(void)
{
  uint32_t value = 0;
  asm volatile("MRS %0, PMCR_EL0" : "=r" (value));
  value |= ARMV8_PMCR_C; /* Cycle counter reset */
  asm volatile("MSR PMCR_EL0, %0" : : "r" (value));
}

#endif  /*ARM_V8_TIMING_H*/
