`timescale 1ns/1ps

module datamem_tb();

parameter N = 32;
parameter DEPTH = 64;

logic           CLK;
logic           WE;

logic [N-1:0]   A;
logic [N-1:0]   WD;
logic [N-1:0]   RD;

data_memory 
    dut(
    .CLK(CLK),
    .WE(WE),
    .A(A),
    .WD(WD),
    .RD(RD)
);

always begin
    CLK = 0;#5;
    CLK = 1;#5;
end

initial begin

    WE=0;A=0;WD=0;

    #1;

    WE=1;A=0;WD=32'hCAFEBABE;

    @(posedge CLK);

    #1;

    WE=0;A=0;WD=0;

    $display("%h",RD);

    #1;

    WE=0;A=DEPTH + 5;WD=0;

    #1;

    $display("Out-of-bounds Addr %0d: Expected = xxxxxxxx, Got = %h", A, RD);

    //dut.dump_memory();

    $finish;
end

endmodule