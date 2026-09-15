`timescale 1ns/1ps

module memory_tb();

parameter N = 5;
parameter M = 32;

logic             CLK;

logic             WE3;
logic [N-1:0]     A1;
logic [M-1:0]    RD1;
logic [N-1:0]     A2;
logic [M-1:0]    RD2;
logic [N-1:0]     A3;
logic [M-1:0]     WD3;

memory dut(
    .CLK(CLK),
    .WE3(WE3),
    .A1(A1),
    .RD1(RD1),
    .A2(A2),
    .RD2(RD2),
    .A3(A3),
    .WD3(WD3)
);

always begin
    CLK = 0;#5;
    CLK = 1;#5;
end

initial begin

    WE3 = 0;
    A1 = 0;
    A2 = 0;
    A3 = 0;
    WD3 = 0;#5;

    @(negedge CLK);
    WE3 = 1;
    A3 = 5'd10;
    WD3 = 32'hDEADBEEF;
    
    //writing
    @(posedge CLK);

    @(negedge CLK);
    WE3 = 0;


    @(negedge CLK);
    WE3 = 1;
    A3 = 5'd20;
    WD3 = 32'hCAFEBABE;
    
    //writing
    @(posedge CLK);

    @(negedge CLK);
    WE3 = 0;

    #5;

    A1 = 5'd10;
    A2 = 5'd20;#1;

    $display("%h",RD1);
    $display("%h",RD2);

    dut.dump_memory();

    $finish;
end

endmodule