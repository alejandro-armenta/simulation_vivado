module mux2_n

    #(parameter width = 8)

    (
        input logic [width - 1:0] d0, d1,
        input logic s,
        output logic [width - 1:0] y
    );

    assign y = s ? d1 : d0;

endmodule


module mux4_8
    (
        input logic [7:0] d0, d1, d2, d3,
        input logic [1:0] s,
        output logic [7:0] y
    );

    logic [7:0] low, high;

    mux2_n lowmux(d0, d1, s[0], low);
    mux2_n highmux(d2, d3, s[0], high);
    mux2_n outmux(low, high, s[1], y);

endmodule