module adder
#(parameter N = 8)
(
    input logic [N-1:0] a, b,
    input logic cin,

    output logic [N-1:0] s,
    output logic cout
);

always_comb begin
    {cout, s} = a + b + cin;
end

endmodule


module subtractor
#(parameter N = 8)
(
    input logic [N-1:0] a, b,
    output logic [N-1:0] s
);

always_comb begin
    s = a - b;
end

endmodule


module comparator
#(parameter N = 8)
(
    input logic [N-1:0] a, b,
    output logic eq, neq, lt, leq, gt, gte
);

always_comb begin 

    eq = (a == b);
    neq = (a != b);
    lt = (a < b);
    leq = (a <= b);
    gt = (a > b);
    gte = (a >= b);


end

endmodule

module nor32 (
    input wire [31:0] channels,
    output wire out_nor
);
    assign out_nor = ~(|channels); // Reduction NOR: true only if all bits are 0
endmodule


module counter
#(parameter N = 8)
(
    input logic clk,
    input logic reset,
    output logic [N-1:0] q
);

always_ff @( posedge clk, posedge reset ) begin
    if (reset) q <= 0;
    else q <= q + 1;
end

endmodule


