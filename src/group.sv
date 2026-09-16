module group
(
    input logic CLK,
    input logic RESET,

    output logic PCOUT
);

program_counter ale(.CLK(CLK), .RESET(RESET), );


endmodule