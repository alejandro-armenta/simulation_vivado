`timescale 1ns/1ps

module adder_tb;

    // 1. Parameters and Test Width
    localparam N = 8;

    // 2. Testbench Signals
    logic [N-1:0] a;
    logic [N-1:0] b;
    logic cin;
    
    logic [N-1:0] s;
    logic cout;

    // 3. Instantiate the Device Under Test (DUT)
    adder #(.N(N)) dut (
        .a   (a),
        .b   (b),
        .cin (cin),
        .s   (s),
        .cout(cout)
    );

    // 4. Stimulus Generation and Verification
    initial begin
        // Print header for readability in the console
        $display("Starting Adder Testbench (Width = %0d)...", N);
        $display("-----------------------------------------");

        // Case 1: Simple addition without carry
        a = 8'd10; b = 8'd20; cin = 1'b0;
        #10; // Wait for logic to settle
        assert({cout, s} == (a + b + cin)) 
            else $error("Case 1 Failed! Expected: %0d, Got: %0d", (a+b+cin), {cout, s});

        // Case 2: Addition with Carry-In
        a = 8'd45; b = 8'd55; cin = 1'b1;
        #10;
        assert({cout, s} == (a + b + cin)) 
            else $error("Case 2 Failed! Expected: %0d, Got: %0d", (a+b+cin), {cout, s});

        // Case 3: Maximum values (Testing Carry-Out / Overflow)
        a = 8'hFF; b = 8'h01; cin = 1'b0; // 255 + 1 = 256 (Requires 9 bits: cout=1, s=0)
        #10;
        assert({cout, s} == (a + b + cin)) 
            else $error("Case 3 Failed! Expected: %0d, Got: %0d", (a+b+cin), {cout, s});

        // Case 4: All ones (Absolute maximum stress test)
        a = 8'hFF; b = 8'hFF; cin = 1'b1;
        #10;
        assert({cout, s} == (a + b + cin)) 
            else $error("Case 4 Failed! Expected: %0d, Got: %0d", (a+b+cin), {cout, s});

        // Case 5: Zero addition
        a = 8'd0; b = 8'd0; cin = 1'b0;
        #10;
        assert({cout, s} == (a + b + cin)) 
            else $error("Case 5 Failed! Expected: 0, Got: %0d", {cout, s});

        // Finish simulation
        $display("-----------------------------------------");
        $display("Testbench complete. If no errors appeared, your design is correct!");
        $finish;
    end

    // Optional: Monitor changes in the console dynamically
    initial begin
        $monitor("Time=%0t | a=%d b=%d cin=%b | cout=%b s=%d", 
                 $time, a, b, cin, cout, s);
    end

endmodule
