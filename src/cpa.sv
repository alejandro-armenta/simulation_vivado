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
