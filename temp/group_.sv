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

`timescale 1ns/1ps

module alu_tb;

    // Parameters
    parameter N = 32;

    // Testbench Signals
    logic [N-1:0] srca;
    logic [N-1:0] srcb;
    logic [2:0]   alucontrol;
    logic [N-1:0] aluresult;
    logic         zero;

    // Instantiate the Device Under Test (DUT)
    alu #(
        .N(N)
    ) dut (
        .srca(srca),
        .srcb(srcb),
        .alucontrol(alucontrol),
        .aluresult(aluresult),
        .zero(zero)
    );

    // Stimulus Process
    initial begin
        $display("--- Starting ALU Testbench ---");

        // --- TEST 1: ADD (3'b000) ---
        $display("\n[Test 1] ADD: 10 + 20");
        srca = 32'd10;
        srcb = 32'd20;
        alucontrol = 3'b000;
        #1; // Wait for combinational evaluation
        $display("Result = %0d, Zero = %b", aluresult, zero);
        if (aluresult !== 32'd30 || zero !== 1'b0) $error("ADD failed!");

        // --- TEST 2: SUB (3'b001) ---
        $display("\n[Test 2] SUB: 50 - 15");
        srca = 32'd50;
        srcb = 32'd15;
        alucontrol = 3'b001;
        #1;
        $display("Result = %0d, Zero = %b", aluresult, zero);
        if (aluresult !== 32'd35 || zero !== 1'b0) $error("SUB failed!");

        // --- TEST 3: Zero Flag Verification ---
        $display("\n[Test 3] SUB resulting in Zero: 25 - 25");
        srca = 32'd25;
        srcb = 32'd25;
        alucontrol = 3'b001;
        #1;
        $display("Result = %0d, Zero = %b", aluresult, zero);
        if (aluresult !== 32'd0 || zero !== 1'b1) $error("Zero flag tracking failed!");

        // --- TEST 4: AND (3'b010) ---
        $display("\n[Test 4] Bitwise AND: 32'h00FF_FFFF & 32'hFFFF_FF00");
        srca = 32'h00FF_FFFF;
        srcb = 32'hFFFF_FF00;
        alucontrol = 3'b010;
        #1;
        $display("Result = %h, Zero = %b", aluresult, zero);
        if (aluresult !== 32'h00FF_FF00) $error("AND failed!");

        // --- TEST 5: OR (3'b011) ---
        $display("\n[Test 5] Bitwise OR: 32'hF000_0000 | 32'h0000_000F");
        srca = 32'hF000_0000;
        srcb = 32'h0000_000F;
        alucontrol = 3'b011;
        #1;
        $display("Result = %h, Zero = %b", aluresult, zero);
        if (aluresult !== 32'hF000_000F) $error("OR failed!");

        // --- TEST 6: SLT (3'b101) Positive Comparison ---
        $display("\n[Test 6] SLT: 5 < 15 (Should be True -> 1)");
        srca = 32'd5;
        srcb = 32'd15;
        alucontrol = 3'b101;
        #1;
        $display("Result = %0d, Zero = %b", aluresult, zero);
        if (aluresult !== 32'd1) $error("SLT positive comparison failed!");

        // --- TEST 7: SLT (3'b101) Signed Negative Comparison ---
        // 32'hFFFFFFFB is -5 in two's complement.
        $display("\n[Test 7] SLT Signed Check: -5 < 3 (Should be True -> 1)");
        srca = 32'hFFFFFFFB; // -5
        srcb = 32'd3;         // 3
        alucontrol = 3'b101;
        #1;
        $display("Result = %0d, Zero = %b", aluresult, zero);
        if (aluresult !== 32'd1) $error("SLT Signed operation failed! Checked unsigned instead of signed.");

        // --- TEST 8: SLT (3'b101) False Condition ---
        $display("\n[Test 8] SLT False Condition: 20 < 10 (Should be False -> 0)");
        srca = 32'd20;
        srcb = 32'd10;
        alucontrol = 3'b101;
        #1;
        $display("Result = %0d, Zero = %b", aluresult, zero);
        if (aluresult !== 32'd0 || zero !== 1'b1) $error("SLT false evaluation failed!");

        $display("\n--- ALU Testbench Finished Successfully ---");
        $finish;
    end

endmodule
