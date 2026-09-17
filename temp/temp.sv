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
