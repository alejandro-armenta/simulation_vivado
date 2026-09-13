module sillyfunction(input logic a,b,c, output logic y);

logic ab, bb, cb, n1, n2, n3;

always_comb begin
    
    {ab, bb, cb} = ~{a,b,c};

    n1 = ab & bb & cb;
    n2 = a & bb & cb;
    n3 = a & bb & c;

    y = n1 | n2 | n3;

end

endmodule