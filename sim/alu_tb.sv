`timescale 1ns/1ps




module alu_tb();

parameter N = 32;


logic [N-1:0] srca;
logic [N-1:0] srcb;
logic [2:0] alucontrol;
logic [N-1:0] aluresult;
logic zero; 


alu dut(
    .srca(srca),
    .srcb(srcb),
    .alucontrol(alucontrol),

    .aluresult(aluresult),
    .zero(zero)
    );


initial begin

    srca = 32'd10;srcb = 32'd20;alucontrol = 3'b000;#1;

    $display("%0d %b", aluresult, zero);

    #1;

    srca = 32'd10;srcb = 32'd20;alucontrol = 3'b001;#1;

    $display("%0d %b", $signed(aluresult), zero);
    
    #1;

    srca = 32'b0110;srcb = 32'b1001;alucontrol = 3'b010;#1;

    $display("%0d %b", $signed(aluresult), zero);

    #1;

    srca = 32'b0110;srcb = 32'b1001;alucontrol = 3'b011;#1;

    $display("%0d %b", $signed(aluresult), zero);

    

end


endmodule