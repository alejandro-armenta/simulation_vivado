# Add this to the very top of your script to suppress Vivado's step-by-step command logging
set_param messaging.defaultLimit 0

set TESTBENCH_TOP "mux4_12"
set OUTPUT_DIR "./build"

if {[file exists $OUTPUT_DIR]} {
    file delete -force $OUTPUT_DIR
}

file mkdir $OUTPUT_DIR

cd $OUTPUT_DIR

foreach file [glob -nocomplain ../src/*.sv] {
    puts "Compiling standalone: $file"
    if {[catch { exec xvlog -work design_lib -sv $file } log_out]} {
        puts $log_out
        exit 1    
    }
    
}

foreach file [glob -nocomplain ../sim/*.sv] {
    puts "Compiling standalone: $file"
    if {[catch { exec xvlog -work sim_lib -sv $file } log_out]} {
        puts $log_out
        exit 1    
    }   
}

set elab_output [exec xelab -debug typical -L design_lib -L sim_lib -top design_lib.$TESTBENCH_TOP]

set output_lines [split $elab_output "\n"]

foreach line $output_lines {

    if {[regexp "ERROR:" $line]} {
        puts $line
        error "ERROR: xelab finished with real errors or strict warnings. Stopping execution!"
    }
    

    if {[regexp "WARNING:" $line] && ![regexp "XSIM 43-3431" $line]} {
        set trigger_fail 1
        puts $line
        error "ERROR: xelab finished with real errors or strict warnings. Stopping execution!"
    }
}