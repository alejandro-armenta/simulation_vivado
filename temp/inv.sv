module inv(input logic [3:0] a, output logic [3:0] y);

always_comb begin
    //blocking assignment
    y = ~a;
end

endmodule