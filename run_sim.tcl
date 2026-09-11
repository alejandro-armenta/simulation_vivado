#set TOP_MODULE "flopr"

set TESTBENCH_TOP "flops_tb"
set OUTPUT_DIR "./build"

if {[file exists $OUTPUT_DIR]} {
    file delete -force $OUTPUT_DIR
}

file mkdir $OUTPUT_DIR

cd $OUTPUT_DIR

exec xvlog -sv {*}[glob ../src/*.sv]

exec xvlog -sv {*}[glob ../sim/*.sv]

exec xelab -debug typical -top $TESTBENCH_TOP -snapshot ${TESTBENCH_TOP}_snapshot 

set xsim_cmd_file [open "xsim_cfg.tcl" w]

    puts $xsim_cmd_file "log_wave -r /" 

    puts $xsim_cmd_file "create_wave_config"

    puts $xsim_cmd_file "add_wave /"

    puts $xsim_cmd_file "run all" 

    #puts $xsim_cmd_file "exit" 

close $xsim_cmd_file

exec xsim ${TESTBENCH_TOP}_snapshot -gui -tclbatch xsim_cfg.tcl -wdb "ale_waves.wdb" >@ stdout

