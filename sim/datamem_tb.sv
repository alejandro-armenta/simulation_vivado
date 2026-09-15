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
    #(
        .N(N),
        .DEPTH(DEPTH)
    )
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

    #10;

    WE=1;A=32'd8;WD=32'hDEADBEEF;

    @(posedge CLK);

    #1;

    WE=0;A=32'd8;WD=0;

    #1;

    $display("%h",RD);

    #1;

    WE=1;A=32'd4;WD=32'hCAFEBABE;

    @(posedge CLK);

    #1;

    WE=0;A=32'd4;WD=0;

    #1;

    $display("%h",RD);

    //dut.dump_memory();

    $finish;
end

endmodule