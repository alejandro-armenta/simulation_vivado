module adder_4
#(parameter N = 32)
(
    input logic [N-1:0] PC,
    output logic [N-1:0] PCPlus4
);

always_comb begin
    PCPlus4 = PC + 32'd4;
end

endmodule


module adder
#(parameter N = 32)
(
  input logic [N-1:0] a,
  input logic [N-1:0] b,

  output logic [N-1:0] out
);

always_comb begin
    out = a + b;
end

endmodule