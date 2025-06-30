# run_sim.tcl
open_project ../../../project_ntt_accelerator/project_ntt_accelerator.xpr
launch_simulation -simset [get_filesets sim_ntt_processor_tb ]
run 1000 us
exit
