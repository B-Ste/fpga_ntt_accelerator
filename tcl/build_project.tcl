set script_dir [file dirname [info script]]
set origin_dir "$script_dir/.."
set project_name "project_ntt_accelerator"

# Create project
create_project $project_name $origin_dir/$project_name -part xczu9eg-ffvb1156-2-e
set_property board_part xilinx.com:zcu102:part0:3.4 [current_project]

# Add IP-Files
set_property ip_repo_paths "$origin_dir/ip" [get_filesets sources_1]
update_ip_catalog
set ips []
foreach ip [glob $origin_dir/ip/*] {
    set ipname [file tail $ip]
    set filename "$ip/$ipname.xci"
    lappend ips [file normalize "$filename"]
    }
add_files -norecurse -fileset [get_filesets sources_1] $ips

# Add source-files
add_files -fileset sources_1 $origin_dir/src/
update_compile_order -fileset sources_1

# Add simulation files in own filesets to permit easy simulation
set testbenches [glob -directory tb/ *.v */*.v]
foreach tb $testbenches {
    set tb_name [file rootname [file tail $tb]]
    create_fileset -simset "sim_$tb_name"
    current_fileset "sim_$tb_name"
    add_files -fileset "sim_$tb_name" $tb
    set_property top $tb_name [get_filesets "sim_$tb_name"]
    set_property top_lib xil_defaultlib [get_filesets "sim_$tb_name"]
    update_compile_order -fileset "sim_$tb_name"
}

delete_fileset sim_1
