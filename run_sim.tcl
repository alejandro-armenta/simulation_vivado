set TESTBENCH_TOP "mux4_8"
set OUTPUT_DIR "./build"

if {[file exists $OUTPUT_DIR]} {
    file delete -force $OUTPUT_DIR
}

file mkdir $OUTPUT_DIR

cd $OUTPUT_DIR

exec xvlog -sv {*}[glob ../src/*.sv]
exec xvlog -sv {*}[glob ../sim/*.sv]

set elab_output [exec xelab -debug typical -top $TESTBENCH_TOP -snapshot ${TESTBENCH_TOP}_snapshot]

puts $elab_output

# Split xelab output into individual lines
set output_lines [split $elab_output "\n"]
set trigger_fail 0

foreach line $output_lines {
    # If any line contains an ERROR, mark as failure
    if {[regexp "ERROR:" $line]} {
        set trigger_fail 1
        break
    }
    
    # If a line contains a WARNING, but IS NOT the library path warning, mark as failure
    if {[regexp "WARNING:" $line] && ![regexp "XSIM 43-3431" $line]} {
        set trigger_fail 1
        break
    }
}

if {$trigger_fail} {
    error "ERROR: xelab finished with real errors or strict warnings. Stopping execution!"
}
