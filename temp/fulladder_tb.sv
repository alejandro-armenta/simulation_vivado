`timescale 1ns/1ps

module fulladder_tb();

    // 1. Shared Input Signals
    logic a, b, cin;

    // 2. Separate Output Signals to Compare
    logic s_correct, cout_correct;
    logic s_buggy,   cout_buggy;

    // 3. Instantiate Correct Module (Using Blocking '=')
    fulladder dut_correct (
        .a(a), .b(b), .cin(cin),
        .s(s_correct), .cout(cout_correct)
    );

    fulladder_buggy dut_buggy (
        .a(a), .b(b), .cin(cin),
        .s(s_buggy), .cout(cout_buggy)
    );

    // 5. Stimulus Block
    initial begin
        
        a = 0; b = 0; cin = 0;

        #10;
        
        a = 1; b = 0; cin = 0;
        
        #10; 
              
        $finish;
    end

endmodule
