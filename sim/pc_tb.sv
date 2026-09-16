module pc_tb();

parameter N = 32;

logic CLK;
logic RESET;
logic [N-1:0] PCNext;
logic [N-1:0] PC;

program_counter dut(
    .CLK(CLK), 
    .RESET(RESET), 
    .PCNext(PCNext), 
    .PC(PC)
);

    always begin
        CLK=0;#5;
        CLK=1;#5;
    end

    initial begin
        RESET = 0;
        PCNext = 32'hFFFFFFFF;

        #1;

        @(posedge CLK);

        #1;

        $display("%h",PC);

        RESET = 1;

        #1;

        $display("%h",PC);

        $finish;

    end

endmodule