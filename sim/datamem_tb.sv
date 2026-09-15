`timescale 1ns/1ps

module datamem_tb();

parameter N = 32;

logic           CLK;
logic           WE;

logic [N-1:0]   A;
logic [N-1:0]   WD;
logic [N-1:0]   RD;

data_memory dut(
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

    dut.dump_memory();

    $finish;
end

endmodule