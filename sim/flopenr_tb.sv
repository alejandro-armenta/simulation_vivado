`timescale 1ns/1ps

module flopenr_tb();

    logic clk, reset, en;

    logic [3:0] d, q;

    flopenr dut(.clk(clk), .reset(reset), .en(en), .d(d), .q(q));

    always begin

        clk = 0;

        #5;

        clk = 1;

        #5;

    end

    initial begin

        reset = 0;
        en = 0;
        d = 4'b0;

        #2;

        reset = 1;

        #10;

        reset = 0;

        @(posedge clk);

        d = 4'b1010;

        @(posedge clk);

        en = 1;

        @(posedge clk);

        d = 4'b0111; // q should become 0111

        @(posedge clk);

        en = 0;

        d = 4'b1111; // q should become 0111

        #3;

        reset = 1;

        #5;

        reset = 0;

        #20;

        $finish;
    end

endmodule