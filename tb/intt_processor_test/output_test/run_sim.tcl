# run_sim.tcl
open_project ../../../project_ntt_accelerator/project_ntt_accelerator.xpr
launch_simulation -simset [get_filesets sim_intt_processor_tb ]
run 100 us
exit
