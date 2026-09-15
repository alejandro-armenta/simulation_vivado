`timescale 1ns/1ps

module decoder_tb_bad();

parameter N = 3;

logic [N-1:0] a;
logic [2**N - 1:0] y0;
logic [2**N - 1:0] y1;

decoder #(.N(N)) dut(.a(a), .y(y0)); 

decoder_bad #(.N(N)) dut_bad(.a(a), .y(y1)); 

initial begin

    a = 3'b000;

    #10;

    //el 3 bit tiene que estar prendido

    a = 3'b011;

    #1;

    $finish;
end

endmodule