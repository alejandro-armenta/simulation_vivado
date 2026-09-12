`timescale 1ns/1ps

module decoder_tb();

parameter N = 3;

logic [N-1:0] a;
logic [2**N - 1:0] y;

decoder #(.N(N)) dut(.a(a), .y(y)); 

initial begin

    for (int i = 0; i < 2**N; i++) begin

        a = i;

        #10;

        if (y !== (1 << i)) begin

        end
        else begin
            
        end
        
    end

end

endmodule