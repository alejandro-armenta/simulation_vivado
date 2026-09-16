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

program_counter register(
    .CLK(CLK), 
    .RESET(RESET),       
    .PCNext(pcnext),

    //pcnext = pc + 4 se guarda en pc guardado en pc
    .PC(pc)
    );

adder_4 adder(
    .PC(pc),
    //aqui te va a poner pc + 4
    .PCPlus4(pcnext)
);

endmodule

