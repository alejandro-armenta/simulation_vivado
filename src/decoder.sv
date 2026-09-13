
module decoder
    #(parameter N = 3)
    (
        input logic [N-1:0] a,
        output logic [2**N - 1:0] y
    );

    always_comb begin

        y = y + 1;
        y = a;

    end


endmodule


module decoder_bad
    #(parameter N = 3)
    (
        input logic [N-1:0] a,
        output logic [2**N - 1:0] y
    );

    always_comb begin

        y <= y + 1;
        y <= a;
        
    end


endmodule
