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


`timescale 1ns/1ps

module fetch_cycle_tb;

    parameter N = 32;

    logic             CLK;
    logic             RESET;
    logic [N-1:0]     PC_OUT;

    // Instantiate our top-level loop module
    fetch_cycle #(
        .N(N)
    ) dut (
        .CLK(CLK),
        .RESET(RESET),
        .PC_OUT(PC_OUT)
    );

    // Clock Generator (100MHz / 10ns period)
    always begin
        CLK = 0;
        #5;
        CLK = 1;
        #5;
    end

    // Stimulus Process
    initial begin
        RESET = 1;
        @(posedge CLK);
        #1;
        RESET = 0; // Release reset to start sequential counting

        $display("--- Testing PC + Adder Loop ---");
        
        // Let it run for 5 clock cycles and observe the auto-increment
        repeat (5) begin
            @(posedge CLK);
            #1; // Wait a moment after the edge for propagation
            $display("Clock Tick! Current PC Address = %0d (0x%h)", PC_OUT, PC_OUT);
        end

        $display("\n--- Loop Test Bench Complete ---");
        $finish;
    end

endmodule


module alu #(
    parameter M = 32
) (
    input  logic [M-1:0] SrcA,       // Operand A (typically from Register File RD1)
    input  logic [M-1:0] SrcB,       // Operand B (from Register File RD2 or Immediate value)
    input  logic [2:0]   ALUControl, // Control signal choosing the operation
    output logic [M-1:0] ALUResult,  // Output data path
    output logic         Zero        // High if ALUResult is completely 0 (for branches)
);

    always_comb begin
        case (ALUControl)
            3'b000:  ALUResult = SrcA + SrcB;                      // ADD
            3'b001:  ALUResult = SrcA - SrcB;                      // SUB
            3'b010:  ALUResult = SrcA & SrcB;                      // AND
            3'b011:  ALUResult = SrcA | SrcB;                      // OR
            3'b101:  ALUResult = ($signed(SrcA) < $signed(SrcB)) ?  // SLT (Signed Comparison)
                                 {{(M-1){1'b0}}, 1'b1} : {M{1'b0}};
            default: ALUResult = {M{1'bx}};                        // Undefined op code
        endcase
    end

    // The Zero flag is set to 1 if the ALU result equals 0, otherwise it is 0.
    assign Zero = (ALUResult == {M{1'b0}});

endmodule

