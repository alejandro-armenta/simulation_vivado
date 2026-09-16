`timescale 1ns/1ps;

module group_tb();

parameter N = 32;

    logic CLK;
    logic RESET;

    logic [N-1:0] PCOUT;

    group dut(.CLK(CLK), .RESET(RESET), .PCOUT(PCOUT));

    always begin
        CLK=0;#5;
        CLK=1;#5;
    end


    initial begin 
        RESET = 1;
        #1;
        RESET = 0;
        #1;

        $display("%h", PCOUT);

        repeat (5) begin 
            @(posedge CLK);
            #1;

            $display("%h", PCOUT);

        end
        $finish;
    end




endmodule