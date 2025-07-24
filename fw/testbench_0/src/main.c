#include "xparameters.h"
#include "xil_printf.h"
#include "xgpio.h"
#include "xil_types.h"
#include "xil_io.h"
#include "stdlib.h"

#include "ntt.h"
#include "performance.h"

void set_start();
void reset_start();
int get_start_ready();
int get_output_ready();
int get_memory_writable();
int get_computation_started();
int get_computation_finished();

XGpio gpio;

UINTPTR poly0 = (UINTPTR) XPAR_AXI_BRAM_CTRL_0_S_AXI_BASEADDR;
UINTPTR poly1 = (UINTPTR) XPAR_AXI_BRAM_CTRL_2_S_AXI_BASEADDR;
UINTPTR result = (UINTPTR) XPAR_AXI_BRAM_CTRL_4_S_AXI_BASEADDR;
int32_t poly0_s[N];
int32_t poly1_s[N];
int32_t polyr[N];

int32_t forward_twiddles[N];
int32_t backward_twiddles[N];

const int32_t modulus[NUM_Q] = {1063321601, 1063452673, 1064697857, 1065484289, 1065811969, 1068236801,
    1068433409, 1068564481, 1069219841, 1070727169, 1071513601, 1072496641, 1073479681};
const int32_t psi[NUM_Q] = {210627128, 528517222, 152301028, 433219053, 644958739, 932161456,
    839237106, 485176247, 429380462, 1026271992, 250036504, 378716967, 371836615};
const int32_t psi_neg[NUM_Q] = {806968250, 496328859, 1011460660, 468376471, 167589381, 773385751,
    280720051, 320928324, 491001446, 874272385, 284619963, 371608897, 730652244};
const int32_t n_neg[NUM_Q] = {1063062001, 1063193041, 1064437921, 1065224161, 1065551761, 1067976001,
    1068172561, 1068303601, 1068958801, 1070465761, 1071252001, 1072234801, 1073217601};

int main() {
	XGpio_Initialize(&gpio, XPAR_AXI_GPIO_0_DEVICE_ID);
	XGpio_SetDataDirection(&gpio, 1, 0b111110);

	arm_v8_timing_init();

	int mod_i = 0;
	int q = modulus[mod_i];
	int psi_p = psi[mod_i];
	int psi_n = psi_neg[mod_i];
	int n_n = n_neg[mod_i];

	brv_powers(&(forward_twiddles[0]), psi_p, q, N);
	brv_powers(&(backward_twiddles[0]), psi_n, q, N);

	xil_printf("Initialization done\r\n");
	xil_printf("Running correctness and sequential timing test\r\n");

	int iterations = 100;
	int failed = 0;

	for (int k = 0; k < iterations; k++) {
		for (unsigned int i = 0; i < 4096; i++) {
			unsigned int a = mod_barrett(rand(), q);
			unsigned int b = mod_barrett(rand(), q);
			Xil_Out32((UINTPTR)(poly0 + 4 * i), a);
			Xil_Out32((UINTPTR)(poly1 + 4 * i), b);
			poly0_s[i] = a;
			poly1_s[i] = b;
		}

		while(!get_start_ready());

		START_TIMING
		set_start();
		reset_start();

		while(!get_output_ready());
		INTERMEDIATE_TIME

		nwc_ntt(q, &(forward_twiddles[0]), &(backward_twiddles[0]), n_n, poly0_s, poly1_s, &(polyr[0]));

		for (int i = 0; i < N; i++) {
			int a_i = polyr[i];
			int b_i = (int32_t) Xil_In32((UINTPTR)(result + 4 * i));
			if (a_i != b_i) {
				failed += 1;
				// xil_printf("failed line %i, a_i = %i, b_i = %i, k = %i\r\n", i, a_i, b_i, k);
			}
		}
	}

	STOP_TIMING

	if (failed) xil_printf("Failed correctness test\r\n");
	else xil_printf("Passed correctness test\r\n");

	xil_printf("Start computation only sequential timing test\r\n");

	for (int k = 0; k < iterations; k++) {
		for (unsigned int i = 0; i < 4096; i++) {
			unsigned int a = mod_barrett(rand(), q);
			unsigned int b = mod_barrett(rand(), q);
			Xil_Out32((UINTPTR)(poly0 + 4 * i), a);
			Xil_Out32((UINTPTR)(poly1 + 4 * i), b);
			poly0_s[i] = a;
			poly1_s[i] = b;
		}

		while(!get_start_ready());

		set_start();
		reset_start();

		while(!get_computation_started());
		START_TIMING

		while(!get_computation_finished());
		INTERMEDIATE_TIME

		while(!get_output_ready());
	}

	STOP_TIMING

	xil_printf("Finished computation only sequential timing test\r\n");

	return 0;
}

void set_start() {
	XGpio_DiscreteWrite(&gpio, 1, 1);
}

void reset_start() {
	XGpio_DiscreteWrite(&gpio, 1, 0);
}

int get_start_ready() {
	return (XGpio_DiscreteRead(&gpio, 1) & 4) != 0;
}

int get_output_ready() {
	return (XGpio_DiscreteRead(&gpio, 1) & 2) != 0;
}

int get_memory_writable() {
	return (XGpio_DiscreteRead(&gpio, 1) & 8) != 0;
}

int get_computation_started() {
	return (XGpio_DiscreteRead(&gpio, 1) & 16) != 0;
}

int get_computation_finished() {
	return (XGpio_DiscreteRead(&gpio, 1) & 32) != 0;
}
