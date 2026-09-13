set_param messaging.defaultLimit 0  
set TESTBENCH_TOP "decoder_tb" 
set SNAPSHOT_NAME "decoder_snapshot"
set OUTPUT_DIR "./build"  

if {[file exists $OUTPUT_DIR]} {
    file delete -force $OUTPUT_DIR
}

file mkdir $OUTPUT_DIR

cd $OUTPUT_DIR

# 1. Compile ALL Design Files in ONE shot (Massive Speedup)
set src_files [glob -nocomplain ../src/*.sv]
if {[llength $src_files] > 0} {
    puts "Compiling all source files incrementally..."     
    if {[catch { exec xvlog -work design_lib -sv {*}$src_files } log_out]} {         
        puts "COMPILATION FAILED:\n$log_out"         
        exit 1         
    }
}

# 2. Compile ALL Simulation Files in ONE shot
set sim_files [glob -nocomplain ../sim/*.sv]
if {[llength $sim_files] > 0} {
    puts "Compiling all simulation files incrementally..."     
    if {[catch { exec xvlog -work sim_lib -sv {*}$sim_files } log_out]} {         
        puts "COMPILATION FAILED:\n$log_out"         
        exit 1         
    }    
}  

# 3. Elaborate Design and generate Snapshot
puts "Elaborating design top: $TESTBENCH_TOP into snapshot: $SNAPSHOT_NAME"
set elab_output [exec xelab -debug typical -L design_lib -L sim_lib -top sim_lib.$TESTBENCH_TOP -snapshot $SNAPSHOT_NAME]  
set output_lines [split $elab_output "\n"]  

set local_fail 0
foreach line $output_lines {      
    if {[regexp "ERROR:" $line]} {         puts $line; set local_fail 1 }           
    if {[regexp "WARNING:" $line] && ![regexp "XSIM 43-3431" $line]} { puts $line; set local_fail 1 } 
}

if {$local_fail} { error "ERROR: xelab finished with errors or strict warnings." }

# 4. Launch Simulation in Vivado GUI
puts "Launching Vivado Simulator GUI..."
exec xsim $SNAPSHOT_NAME -gui &
