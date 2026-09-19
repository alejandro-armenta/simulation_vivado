set repo_dir [pwd]

set OUTPUT_DIR "./vivado_schematic"

if {[file exists $OUTPUT_DIR]} {
    file delete -force $OUTPUT_DIR
}

file mkdir $OUTPUT_DIR

cd $OUTPUT_DIR

set_part xc7a200tfbg676-2

set src_files [glob -nocomplain "${repo_dir}/src/*.sv"]
puts $src_files

if {[llength $src_files] > 0} {
    read_verilog -sv $src_files
    synth_design -top group -rtl
    start_gui
}
else {
    error "no system verilog files"
}
