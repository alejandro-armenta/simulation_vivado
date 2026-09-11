vivado -mode batch -source run_sim.tcl -log ./build/vivado.log -journal ./build/vivado.jou 


#if [ -f "./build/ale_waves.wdb" ]; then
#    echo "Simulation complete. Launching Waveform GUI..."
#    cd ./build
#    xsim ale_waves.wdb -gui
#else
#    echo "ERROR: Simulation failed. Waveform file not generated."
#    exit 1
#fi