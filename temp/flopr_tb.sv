`timescale 1ns/1ps


module flopr_tb();

    logic clk;
    logic reset;
    logic [3:0] d;
    logic [3:0] q;

    flopr dut(.clk(clk), .reset(reset), .d(d), .q(q));   

    always begin

        clk = 0;

        # 5;

        clk = 1;

        # 5;
        
    end

    initial begin

        $monitor("Time=%0t | clk=%b | reset=%b | d=%h | q=%h", $time, clk, reset, d, q);

        reset = 1;
        d = 4'hA; //stimulus
        #3;

        assert (q == 4'b0) else $fatal(1, "ale");

        #7;

        reset = 0;

        @(posedge clk);

        #1;

        assert (q == 4'hA) else $fatal(1, "ale");

        // test 2 

        d = 4'h5;

        @(posedge clk);

        #1;

        assert (q == 4'h5) else $fatal(1,"ale");

        d = 4'hF;

        #3;

        reset = 1;

        #0.1;

        assert (q == 4'b0) else $fatal(1,"ale");

        #5;

        reset = 0;

        $display("SUCCESS");

        $finish;

    end

endmodule
