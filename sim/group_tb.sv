`timescale 1ns/1ps;

module group_tb();

    parameter N = 32;
    parameter DEPTH = 64;

    logic CLK;
    logic RESET;

    logic [N-1:0] OUT_INST;

    group 

        #(
            .N(N),
            .DEPTH(DEPTH)
        )

        dut(
            .CLK(CLK), 
            .RESET(RESET), 
            .OUT_INST(OUT_INST)
        );

    always begin
        CLK=0;#5;
        CLK=1;#5;
    end


    initial begin 
        RESET = 1;
        #20;
        
        $display("%h", OUT_INST);

        RESET = 0;

        repeat (3) begin

            @(posedge CLK);
            #1;

            $display("%h", OUT_INST);

        end
        
        $finish;
    end


    initial begin
        //$monitor("%t %h", $time, OUT_INST);
    end




endmodule