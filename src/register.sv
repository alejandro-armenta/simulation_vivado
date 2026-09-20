

module register

  #(parameter N = 32)
(
    input logic CLK,
    input logic RESET,
    input logic [N-1:0] PCNext,
    output logic [N-1:0] PC
);

always_ff @(posedge CLK, posedge RESET) begin

    if (RESET) begin
        PC <= {N{1'b0}};    
    end else begin
        PC <= PCNext;
    end

end

endmodule