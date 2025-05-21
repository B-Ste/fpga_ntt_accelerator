proc create_tb {name} {
    close [open "tb/${name}.v" w]
    set set_name [file tail $name]
    create_fileset -simset "sim_$set_name"
    add_files -fileset "sim_$set_name" "tb/${name}.v"
    update_compile_order -fileset "sim_$set_name"
}

proc create_src {name} {
    close [open "src/${name}.v" w]
    add_files -fileset sources_1 src/${name}.v
    update_compile_order -fileset sources_1
}
