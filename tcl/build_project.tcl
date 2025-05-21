set script_dir [file dirname [info script]]
set origin_dir "$script_dir/.."
set project_name "project_ntt_accelerator"

# Create project
create_project $project_name $origin_dir/$project_name -part xczu9eg-ffvb1156-2-e
set_property board_part xilinx.com:zcu102:part0:3.4 [current_project]

# Add source-files
add_files -fileset [get_filesets sources_1] $origin_dir/src/
update_compile_order -fileset sources_1

# Add simulation files in own filesets to permit easy simulation
set testbenches [glob "tb/*/*.v"]
foreach tb $testbenches {
    set tb_name [file rootname [file tail $tb]]
    create_fileset -simset "sim_$tb_name"
    add_files -fileset "sim_$tb_name" $tb
    update_compile_order -fileset "sim_$tb_name"
}

delete_fileset sim_1
