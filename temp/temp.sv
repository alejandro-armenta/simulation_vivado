module instruction_decoder (
    input  logic [31:0] instruction,
    
    // Fields passed directly to Register File
    output logic [4:0]  rs1,        // Source Register 1
    output logic [4:0]  rs2,        // Source Register 2
    output logic [4:0]  rd,         // Destination Register
    
    // Control fields for the Control Unit / ALU
    output logic [6:0]  opcode,
    output logic [2:0]  funct3,
    output logic [6:0]  funct7
);

    // RISC-V fields are always at fixed bit positions
    assign opcode = instruction[6:0];
    assign rd     = instruction[11:7];
    assign funct3 = instruction[14:12];
    assign rs1    = instruction[19:15];
    assign rs2    = instruction[24:20];
    assign funct7 = instruction[31:25];

endmodule


module register_file #(
    parameter N = 32
) (
    input  logic         CLK,
    input  logic         WE3,        // Write Enable (from Control Unit)
    input  logic [4:0]   A1,         // Read Address 1 (rs1)
    input  logic [4:0]   A2,         // Read Address 2 (rs2)
    input  logic [4:0]   A3,         // Write Address (rd)
    input  logic [N-1:0] WD3,        // Write Data (Result from ALU or Memory)
    output logic [N-1:0] RD1,        // Read Data 1
    output logic [N-1:0] RD2         // Read Data 2
);

    // 32 registers, each N-bits wide
    logic [N-1:0] rf [31:0];

    // Combinational Read (Asynchronous)
    // In RISC-V, register x0 is hardwired to 0
    assign RD1 = (A1 == 5'b0) ? {N{1'b0}} : rf[A1];
    assign RD2 = (A2 == 5'b0) ? {N{1'b0}} : rf[A2];

    // Synchronous Write (Writes on rising edge if enabled)
    always_ff @(posedge CLK) begin
        if (WE3 && (A3 != 5'b0)) begin
            rf[A3] <= WD3;
        end
    end

endmodule


module group #(
    parameter N = 32,
    parameter DEPTH = 64
) (
    input  logic         CLK,
    input  logic         RESET,
    
    // Inputs for Writeback Stage (needed to write back data into registers)
    input  logic         REG_WRITE,  // Connect this to Control Unit Write Enable
    input  logic [N-1:0] WRITE_DATA, // Connect this to ALU Result or Data Memory output
    
    // Outputs representing the currently decoded state
    output logic [N-1:0] OUT_INST,
    output logic [N-1:0] REG_DATA_1, // rs1 contents (goes to ALU)
    output logic [N-1:0] REG_DATA_2  // rs2 contents (goes to ALU or Immediate Mux)
);

    // Internal routing wires
    logic [N-1:0] pcnext;
    logic [N-1:0] pc;
    
    // Decoded register index addresses
    logic [4:0]   rs1_addr;
    logic [4:0]   rs2_addr;
    logic [4:0]   rd_addr;
    
    // Decoded opcodes for your upcoming Control Unit
    logic [6:0]   opcode;
    logic [2:0]   funct3;
    logic [6:0]   funct7;

    // 1. PC Register
    program_counter #(.N(N)) register (
        .CLK   (CLK), 
        .RESET (RESET),       
        .PCNext(pcnext),
        .PC    (pc)
    );

    // 2. PC Adder (+4)
    adder_4 #(.N(N)) adder (
        .PC     (pc),
        .PCPlus4(pcnext)
    );

    // 3. Instruction Memory
    instruction_memory #(
        .N(N),
        .DEPTH(DEPTH)
    ) mem (
        .A (pc),
        .RD(OUT_INST)
    );

    // 4. NEW: Instruction Decoder
    instruction_decoder decoder (
        .instruction(OUT_INST),
        .rs1        (rs1_addr),
        .rs2        (rs2_addr),
        .rd         (rd_addr),
        .opcode     (opcode),
        .funct3     (funct3),
        .funct7     (funct7)
    );

    // 5. NEW: Register File
    register_file #(.N(N)) regfile (
        .CLK(CLK),
        .WE3(REG_WRITE),   // Driven by execution control logic
        .A1 (rs1_addr),    // rs1 from decoder
        .A2 (rs2_addr),    // rs2 from decoder
        .A3 (rd_addr),     // rd from decoder
        .WD3(WRITE_DATA),  // Data from writeback
        .RD1(REG_DATA_1),  // Output data 1
        .RD2(REG_DATA_2)   // Output data 2
    );

endmodule


module group #(
    parameter ADDR_WIDTH = 5,   // Was N in your register file
    parameter DATA_WIDTH = 32,  // Was M in your register file
    parameter DEPTH      = 64
) (
    input  logic                  CLK,
    input  logic                  RESET,

    // Inputs for Writeback (to write back data into the register file)
    input  logic                  REG_WRITE,  // Connects to WE3
    input  logic [DATA_WIDTH-1:0] WRITE_DATA, // Connects to WD3

    // Outputs representing the currently decoded state
    output logic [DATA_WIDTH-1:0] OUT_INST,
    output logic [DATA_WIDTH-1:0] REG_DATA_1, // Connects to RD1
    output logic [DATA_WIDTH-1:0] REG_DATA_2  // Connects to RD2
);

    // Internal wires for the program counter loop
    logic [DATA_WIDTH-1:0] pcnext;
    logic [DATA_WIDTH-1:0] pc;

    // Decoded register address indices
    logic [ADDR_WIDTH-1:0] rs1_addr;
    logic [ADDR_WIDTH-1:0] rs2_addr;
    logic [ADDR_WIDTH-1:0] rd_addr;

    // 1. Program Counter Register
    program_counter #(
        .N(DATA_WIDTH)
    ) register (
        .CLK   (CLK), 
        .RESET (RESET),       
        .PCNext(pcnext),
        .PC    (pc)
    );

    // 2. PC Adder (+4)
    adder_4 #(
        .N(DATA_WIDTH)
    ) adder (
        .PC     (pc),
        .PCPlus4(pcnext)
    );

    // 3. Instruction Memory
    instruction_memory #(
        .N    (DATA_WIDTH),
        .DEPTH(DEPTH)
    ) mem (
        .A (pc),
        .RD(OUT_INST)
    );

    // 4. Instruction Decoder
    // Splits the raw bits into individual address ports
    instruction_decoder decoder (
        .instruction(OUT_INST),
        .rs1        (rs1_addr),
        .rs2        (rs2_addr),
        .rd         (rd_addr),
        .opcode     (), // Left open if not yet exposed at top-level
        .funct3     (),
        .funct7     ()
    );

    // 5. Your exact Register File Module integrated
    register_file #(
        .N(ADDR_WIDTH), // Maps to N (Address width, e.g., 5 bits)
        .M(DATA_WIDTH)  // Maps to M (Data width, e.g., 32 bits)
    ) regfile (
        .CLK(CLK),
        .WE3(REG_WRITE),
        .A1 (rs1_addr),
        .RD1(REG_DATA_1),
        .A2 (rs2_addr),
        .RD2(REG_DATA_2),
        .A3 (rd_addr),
        .WD3(WRITE_DATA)
    );

endmodule



`timescale 1ns/1ps

module tb_group();

    // 1. Parameters matching your design
    localparam ADDRESS_WIDTH = 5;
    localparam DATA_WIDTH    = 32;
    localparam DEPTH         = 64;
    localparam CLK_PERIOD    = 10; // 100MHz clock

    // 2. Testbench signals
    logic                    CLK;
    logic                    RESET;
    logic                    WE3;
    logic [ADDRESS_WIDTH-1:0] A3;
    logic [DATA_WIDTH-1:0]    WD3;

    logic [DATA_WIDTH-1:0]    REG_DATA_1;
    logic [DATA_WIDTH-1:0]    REG_DATA_2;

    // 3. Instantiate the Device Under Test (DUT)
    group #(
        .ADDRESS_WIDTH(ADDRESS_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .DEPTH(DEPTH)
    ) dut (
        .CLK(CLK),
        .RESET(RESET),
        .WE3(WE3),
        .A3(A3),
        .WD3(WD3),
        .REG_DATA_1(REG_DATA_1),
        .REG_DATA_2(REG_DATA_2)
    );

    // 4. Clock Generation (Runs continuously)
    initial begin
        CLK = 0;
        forever #(CLK_PERIOD/2) CLK = ~CLK;
    end

    // 5. Stimulus Block
    initial begin
        // Initialize inputs to safe values
        RESET = 1;
        WE3   = 0;
        A3    = 0;
        WD3   = 0;

        // Display current loaded instructions at startup
        #1;
        $display("========================================");
        $display("--- INITIAL INSTRUCTION MEMORY DUMP ----");
        $display("========================================");
        dut.mem.dump_memory(); // Hierarchical call to your memory function
        $display("========================================\n");

        // Release reset after 2 clock cycles
        #(CLK_PERIOD * 2);
        @(negedge CLK);
        RESET = 0;
        $display("[TB INFO] Reset released. Starting execution...\n");

        // Let the processor run for 15 clock cycles
        // Watch your wave viewer or console to track PC changes and register data
        repeat (15) begin
            @(posedge CLK);
            // Optional: You can add runtime displays here to track instructions
            $display("Time: %0t | PC: %h | Inst: %h", $time, dut.pc, dut.instruction);
        end

        // Example: Simulating a synchronous manual register file write from the outside
        $display("\n[TB INFO] Testing external manual write to Register file...");
        @(negedge CLK);
        WE3 = 1;
        A3  = 5;          // Target register x5
        WD3 = 32'hDEADBEEF; // Data to write
        
        @(posedge CLK);   // Data latches on next positive edge
        #(CLK_PERIOD/2);  // Wait briefly to allow propagation
        WE3 = 0;          // Turn off write enable

        // End simulation safely
        $display("\n[TB INFO] Simulation finished.");
        $finish;
    end

    // 6. Optional: Monitor signal changes in the console
    initial begin
        $monitor("At time %0t: REG_DATA_1 = %h, REG_DATA_2 = %h", 
                 $time, REG_DATA_1, REG_DATA_2);
    end

endmodule


    // Enhanced Internal Signal Debug Monitor
    initial begin
        // Print header for readable log columns
        $display("\n%-10s | %-8s | %-8s | %-3s (%-8s) | %-3s (%-8s)", 
                 "Time", "PC", "Inst", "A1", "REG_DATA_1", "A2", "REG_DATA_2");
        $display("---------------------------------------------------------------------------------");
        
        forever begin
            // Sample values right after the positive clock edge when signals have stabilized
            @(posedge CLK);
            #(CLK_PERIOD / 10); // Tiny delay to allow combinational logic (decoder) to settle
            
            // Only print if Reset is inactive so the log stays clean during startup
            if (!RESET) begin
                $display("%-10t | %-8h | %-8h | x%-20d (%-8h) | x%-20d (%-8h)", 
                         $time, 
                         dut.pc, 
                         dut.instruction, 
                         dut.rs1,        // Probing internal decoder output / RegFile A1 input
                         REG_DATA_1,     // Top-level output
                         dut.rs2,        // Probing internal decoder output / RegFile A2 input
                         REG_DATA_2      // Top-level output
                );
            end
        end
    end



    module sign_extender
    #(
        parameter DATA_WIDTH = 32
    )
    (
        input  logic [31:0]            instruction, // The raw 32-bit instruction
        input  logic [2:0]             ImmSrc,      // Control signal specifying the format
        output logic [DATA_WIDTH-1:0]  imm_ext      // The sign-extended 32-bit immediate
    );

    always_comb begin
        case (ImmSrc)
            // I-type (e.g., addi, lw, jalr) -> 12-bit signed immediate
            3'b000: imm_ext = { {20{instruction[31]}}, instruction[31:20] };

            // S-type (e.g., sw, sb) -> 12-bit signed split immediate
            3'b001: imm_ext = { {20{instruction[31]}}, instruction[31:25], instruction[11:7] };

            // B-type (e.g., beq, bne) -> 13-bit signed conditional branch offset (LSB is always 0)
            3'b010: imm_ext = { {19{instruction[31]}}, instruction[31], instruction[7], instruction[30:25], instruction[11:8], 1'b0 };

            // U-type (e.g., lui, auipc) -> 20-bit upper immediate (lower 12 bits zeroed)
            3'b011: imm_ext = { instruction[31:12], 12'b0 };

            // J-type (e.g., jal) -> 21-bit signed unconditional jump offset (LSB is always 0)
            3'b100: imm_ext = { {11{instruction[31]}}, instruction[31], instruction[19:12], instruction[20], instruction[30:21], 1'b0 };

            // Default safe fallback (Output zero)
            default: imm_ext = {DATA_WIDTH{1'b0}};
        endcase
    end

endmodule
