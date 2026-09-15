module instruction_memory_tb();

parameter N = 32;
parameter DEPTH = 64;

logic [N-1:0]     A;
logic [N-1:0]    RD;

instruction_memory dut(.A(A),.RD(RD));

initial begin

    #1;

    A = 32'h00000000;

    #1;

    $display("%h",RD);

    #1;

    A = 32'h00000004;

    #1;

    $display("%h",RD);

    #1;

    A = 32'h00000008;

    #1;

    $display("%h",RD);

    #1;

    A = 32'h0000000C;

    #1;

    $display("%h",RD);

    //dut.dump_memory();

end

endmodule