`timescale 1ns/1ps

module flops_tb();

    logic clk;
    logic reset;
    logic [3:0] d;
    logic [3:0] q;

    flops dut(.clk(clk), .reset(reset), .d(d), .q(q));   

    always begin

        clk = 0;

        # 5;

        clk = 1;

        # 5;
        
    end

    initial begin

        reset = 0;

        d = 4'b0;

        @(negedge clk);

        reset = 1;

        @(negedge clk);

        reset = 0;

        @(negedge clk);

        d = 4'b1010;

        @(posedge clk);

        #1;

        @(negedge clk);

        d = 4'b0111;

        @(posedge clk);

        #1;

        @(negedge clk);

        d = 4'b1111;

        reset = 1;

        @(posedge clk);

        #1;

        @(negedge clk);

        reset = 0;

        $finish;

    end

endmodule
