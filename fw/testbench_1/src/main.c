#include "xparameters.h"
#include "xgpio.h"
#include "xil_types.h"
#include "xil_io.h"

#define SHARED_MEM_BASE 0xFFFC0000
#define CPS 1200000000

#define ARMV8_PMCR_E            (1 << 0) /* Enable all counters */
#define ARMV8_PMCR_P            (1 << 1) /* Reset all counters */
#define ARMV8_PMCR_C            (1 << 2) /* Cycle counter reset */
#define ARMV8_PMCR_D            (1 << 3) /* Unset 64-cycle counting */

#define ARMV8_PMCNTENSET_EL0_EN (1 << 31) /* Performance Monitors Count Enable Set register */

volatile uint64_t* write_p = (uint64_t*) SHARED_MEM_BASE + 1;
XGpio gpio;

static inline void arm_v8_timing_init(void)
{
  uint32_t value = 0;

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

static inline uint64_t arm_v8_get_timing(void)
{
  uint64_t result = 0;

  asm volatile("MRS %0, PMCCNTR_EL0" : "=r" (result));

  return result;
}

int get_output_ready() {
	return (XGpio_DiscreteRead(&gpio, 1) & 2) != 0;
}

int main() {
    XGpio_Initialize(&gpio, XPAR_AXI_GPIO_0_DEVICE_ID);
	XGpio_SetDataDirection(&gpio, 1, 0b111110);

    arm_v8_timing_init();

    while(!*write_p);
    write_p++;
    uint64_t start = arm_v8_get_timing();

    int state = 0;
    uint64_t executions = 0;
    while(write_p != (uint64_t*) 0xFFFFFFFF) {
        int i = get_output_ready();
        uint64_t time = arm_v8_get_timing();
        if (time - start >= CPS) break;
        if (i != state) {
            if (i == 1) {
            	executions++;
            	*write_p = executions;
            }
            state = i;
        }
    }

    return 0;
}
