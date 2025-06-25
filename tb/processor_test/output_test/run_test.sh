#!/bin/bash

# Define directories
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
XSIM_DIR="$SCRIPT_DIR/../../../project_ntt_accelerator/project_ntt_accelerator.sim/sim_ntt_processor_tb/behav/xsim"

# Step 1: Run the executable and supply inputs 8 and 0
echo "Running ntt_bench_bar with inputs 8 and 0..."
echo -e "8\n0" | "$SCRIPT_DIR/ntt_bench_bar" > /dev/null

# Step 2: Move input.txt to Vivado simulation directory
echo "Moving input.txt to Vivado simulation directory..."
mv "$SCRIPT_DIR/input.txt" "$XSIM_DIR/"

# Step 3: Run Vivado simulation for 450us
echo "Starting Vivado simulation for 450us..."
vivado -mode batch -source "$SCRIPT_DIR/run_sim.tcl" > /dev/null

# Step 4: Move output_processor.txt back to output_test directory
echo "Moving output_processor.txt back to output_test..."
mv "$XSIM_DIR/output_processor.txt" "$SCRIPT_DIR/"

# Step 5: Run the Python script to verify the output
echo "Running Python script to verify output..."
python3 "$SCRIPT_DIR/processor_output_test.py"

# Step 6: Cleanup Vivado temporary files in output_test only
echo "Cleaning up Vivado temporary files in output_test directory..."
rm -rf "$SCRIPT_DIR/.Xil"
find "$SCRIPT_DIR" -maxdepth 1 -name "*.jou" -type f -delete
find "$SCRIPT_DIR" -maxdepth 1 -name "*.log" -type f -delete

echo "Test sequence completed."
