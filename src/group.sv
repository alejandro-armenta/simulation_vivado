module group
#(parameter N = 32)
(
    input logic CLK,
    input logic RESET,

    output logic [N-1:0] PCOUT
);

logic [N-1:0] pcnext;
logic [N-1:0] pc;

always_comb begin
    PCOUT = pc;
end

program_counter ale(
    .CLK(CLK), 
    .RESET(RESET), 
    .PCNext(pcnext),
    .PC(pc)
    );

adder_4 adder(
    .PC(pc),
    .PCPlus4(pcnext)
);

endmodule

