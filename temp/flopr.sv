module flopr(
    input logic         clk,
    input logic         reset,
    input logic [3:0]   d,
    output logic [3:0]  q
    );

    //si es reset reset 
    
    //si es clk clk 

    always_ff @(posedge clk, posedge reset) begin
        if (reset) q <= 4'b0;
        else q <= d;
    end

endmodule
