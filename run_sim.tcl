set_param messaging.defaultLimit 0  

set TESTBENCH_TOP "sim_lib.register_file_tb" 

set SNAPSHOT_NAME "snapshot"

set OUTPUT_DIR "./build"  

#if {[file exists $OUTPUT_DIR]} {
#    file delete -force $OUTPUT_DIR
#}

#file mkdir $OUTPUT_DIR

cd $OUTPUT_DIR

# Function to generate a .prj file and compile it safely
proc compile_library {lib_name files} {
    if {[llength $files] == 0} { return }
    
    set prj_filename "${lib_name}.prj"

    set prj_file [open $prj_filename w]
    
    # Write files into the project structure cleanly
    foreach file $files {
        puts $prj_file "sv $lib_name $file"
    }

    close $prj_file
    
    # Run the compiler via the project file
    puts "Compiling library $lib_name with [llength $files] files..."
    
    if {[catch { exec xvlog -work $lib_name -prj $prj_filename } log_out]} {
        puts $log_out
        file delete -force $prj_filename
        exit 1
    }
    
    # Clean up the temporary project file
    file delete -force $prj_filename
}

# 1. Compile source files
set src_files [glob -nocomplain ../src/*.sv]
compile_library "design_lib" $src_files

# 2. Compile simulation files
set sim_files [glob -nocomplain ../sim/*.sv]
compile_library "sim_lib" $sim_files


puts "Elaborating design top: $TESTBENCH_TOP into snapshot: $SNAPSHOT_NAME"
set elab_output [exec xelab -debug typical -L design_lib -L sim_lib -top $TESTBENCH_TOP -snapshot $SNAPSHOT_NAME]  

set output_lines [split $elab_output "\n"]  

set local_fail 0

foreach line $output_lines {      
    if {[regexp "ERROR:" $line]} {         puts $line; set local_fail 1 }           
    if {[regexp "WARNING:" $line] && ![regexp "XSIM 43-3431" $line]} { puts $line; set local_fail 1 } 
}

if {$local_fail} { error "ERROR: xelab finished with errors or strict warnings." }


puts "Launching Vivado Simulator GUI..."
set ale [exec xsim $SNAPSHOT_NAME --runall]
puts $ale
