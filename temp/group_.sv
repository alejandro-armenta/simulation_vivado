module fetch_cycle #(
    parameter N = 32
) (
    input  logic         CLK,
    input  logic         RESET,
    output logic [N-1:0] PC_OUT // Exported so you can see where the PC points
);

    // Internal Wires (Signals connecting the modules)
    logic [N-1:0] pc_current;
    logic [N-1:0] pc_next;

    // Output assignment so external modules (like Instruction Memory) can read the PC
    assign PC_OUT = pc_current;

    // 1. Instantiate the Program Counter
    program_counter #(
        .N(N)
    ) pc_reg (
        .CLK(CLK),
        .RESET(RESET),
        .PC_NEXT(pc_next), // Receives the calculated address from the adder
        .PC(pc_current)    // Outputs the current address
    );

    // 2. Instantiate the PC Adder
    pc_adder #(
        .N(N)
    ) pc_add (
        .PC(pc_current),    // Takes the current address from the PC register
        .PC_PLUS_4(pc_next) // Calculates PC + 4 and sends it back to pc_next
    );

endmodule
