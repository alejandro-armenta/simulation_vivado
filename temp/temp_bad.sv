`timescale 1ns/1ps

module tb_decoder;

    parameter N = 3;
    logic [N-1:0] a;
    logic [2**N - 1:0] y;

    // Instantiate the BAD decoder (using <= in always_comb)
    decoder_bad #(.N(N)) dut (
        .a(a),
        .y(y)
    );

    initial begin
        $display("Starting decoder test...");
        
        // Initialize inputs
        a = 3'b000;
        #10; // Wait for initial settling

        // Test Case: Change 'a' and check 'y' immediately
        a = 3'b011; // Change input to 3
        
        // CRITICAL: We check the output in the same time step (#0 delay)
        if (y[3] == 1'b1) begin
            $display("[SUCCESS] y[3] updated instantly!");
        end else begin
            $display("[ERROR] Mismatch found! a = %0d, but y = %b", a, y);
            $display("        Reason: Non-blocking assignment delayed the update to the NBA region.");
        end

        // Wait 1ns to let the NBA region settle
        #1;
        $display("[INFO] After 1ns delay: a = %0d, y = %b", a, y);

        $finish;
    end

endmodule

// The faulty module for reference
module decoder_bad #(parameter N = 3) (
    input  logic [N-1:0] a,
    output logic [2**N - 1:0] y
);
    always_comb begin
        y <= 0;     // BAD: Non-blocking in combinational logic
        y[a] <= 1;  // BAD: Non-blocking in combinational logic
    end
endmodule
