`timescale 1ns/1ps

module tb_decoder_good;

    parameter N = 3;
    
    // Testbench signals
    logic [N-1:0] a;
    logic [2**N - 1:0] y;
    
    // Verification variables
    int error_count = 0;

    // Instantiate the GOOD decoder
    decoder_good #(.N(N)) dut (
        .a(a),
        .y(y)
    );

    initial begin
        $display("--------------------------------------------------");
        $display("Starting GOOD Decoder Testbench (Self-Checking)");
        $display("--------------------------------------------------");
        
        // Loop through every possible input value (0 to 7 for N=3)
        for (int i = 0; i < (2**N); i++) begin
            
            // 1. Apply the stimulus
            a = i;
            
            // 2. Wait a microscopic delay (optional, but good for waveform viewing)
            #10; 
            
            // 3. Self-checking logic: Verify if only the i-th bit is set
            if (y !== (1 << i)) begin
                $display("[FAIL] Input a = %0d | Expected y = %b | Got y = %b", a, (1 << i), y);
                error_count++;
            } else begin
                $display("[PASS] Input a = %0d | Output y = %b", a, y);
            end
        end

        // Final report
        $display("--------------------------------------------------");
        if (error_count == 0) begin
            $display(">>> TEST PASSED SUCCESSFULLY! All cases matched. <<<");
        end else begin
            $display(">>> TEST FAILED! Total errors: %0d <<<", error_count);
        end
        $display("--------------------------------------------------");
        
        $finish;
    end

endmodule


// Included the GOOD module here for easy single-file simulation
module decoder_good #(parameter N = 3) (
    input  logic [N-1:0] a,
    output logic [2**N - 1:0] y
);
    always_comb begin
        y = 0;      // GOOD: Instantaneous blocking assignment
        y[a] = 1;   // GOOD: Instantaneous blocking assignment
    end
endmodule
