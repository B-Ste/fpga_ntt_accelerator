proc create_tb {name} {
    close [open "tb/${name}.v" w]
    create_fileset -simset "sim_$name"
    add_files -fileset "sim_$name" "tb/${name}.v"
    update_compile_order -fileset "sim_$name"
}
