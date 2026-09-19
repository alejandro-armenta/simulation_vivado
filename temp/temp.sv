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

    logic [DATA_WIDTH-1:0]    alu_result;
    logic                    zero;

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
        .alu_result(alu_result),
        .zero(zero)
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

        // Pre-load some dummy values into registers for execution testing
        // (Simulating historical state before we turn off reset)
        @(negedge CLK);
        WE3 = 1; A3 = 5; WD3 = 32'h0000000A; // x5 = 10
        @(negedge CLK);
        WE3 = 1; A3 = 6; WD3 = 32'h00000014; // x6 = 20
        @(negedge CLK);
        WE3 = 0; // Turn off write enable

        // Release reset after a couple cycles
        #(CLK_PERIOD * 2);
        @(negedge CLK);
        RESET = 0;
        $display("[TB INFO] Reset released. Starting execution...\n");

        // Let the processor run for 10 clock cycles to watch propagation
        repeat (10) begin
            @(posedge CLK);
        end

        // End simulation safely
        $display("\n[TB INFO] Simulation finished.");
        $finish;
    end

    // 6. Dynamic Runtime Log (Monitors internal and external signals together)
    initial begin
        // Print clean table column headers
        $display("\n%-10s | %-8s | %-8s | %-8s | %-8s | %-10s | %-4s", 
                 "Time", "PC", "Inst", "SrcA", "ImmExt", "ALU Result", "Zero");
        $display("---------------------------------------------------------------------------------------");
        
        forever begin
            @(posedge CLK);
            #(CLK_PERIOD / 10); // Tiny pause to allow always_comb ALU logic to fully settle
            
            if (!RESET) begin
                $display("%-10t | %-8h | %-8h | %-8h | %-8h | %-10h | %-4b", 
                         $time, 
                         dut.pc, 
                         dut.instruction, 
                         dut.REG_DATA_1, // Probing internal SrcA 
                         dut.imm_ext,    // Probing internal SrcB
                         alu_result,     // Top-level output
                         zero            // Top-level output
                );
            end
        end
    end

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
    
    // Control inputs remaining at the top level
    logic                    WE3;
    logic                    WE;
    logic [DATA_WIDTH-1:0]    WD;

    // Output tracking
    logic [DATA_WIDTH-1:0]    RD;

    // 3. Instantiate the Device Under Test (DUT)
    group #(
        .ADDRESS_WIDTH(ADDRESS_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .DEPTH(DEPTH)
    ) dut (
        .CLK(CLK),
        .RESET(RESET),
        .WE3(WE3),
        .WE(WE),
        .WD(WD),
        .RD(RD)
    );

    // 4. Clock Generation
    initial begin
        CLK = 0;
        forever #(CLK_PERIOD/2) CLK = ~CLK;
    end

    // 5. Stimulus Block
    initial begin
        // Initialize controls to safe states
        RESET = 1;
        WE3   = 0;
        WE    = 0;
        WD    = 0;

        // Print initial memory state at startup
        #1;
        $display("========================================");
        $display("--- INITIAL INSTRUCTION MEMORY DUMP ----");
        $display("========================================");
        dut.mem.dump_memory(); 
        $display("========================================\n");

        // Release reset to start processing instructions from a.hex
        #(CLK_PERIOD * 2);
        @(negedge CLK);
        RESET = 0;
        $display("[TB INFO] Reset released. Starting execution...\n");

        // Step 1: Let the processor execute instructions for 5 cycles
        // Set WE3 high to allow instructions to write results back to 'dr' via RD
        WE3 = 1; 
        repeat (5) begin
            @(posedge CLK);
        end

        // Step 2: Simulate a scenario where you want to write to Data Memory
        $display("\n[TB INFO] Testing a memory write scenario...");
        @(negedge CLK);
        WE3 = 0; // Turn off register write for this cycle
        WE  = 1; // Turn on Data Memory write
        WD  = 32'h5555AAAA; // Payload data to write

        @(posedge CLK);
        #(CLK_PERIOD/10);
        WE  = 0; // Turn off memory write
        WE3 = 1; // Restore register write capability

        // Let it run a few final cycles
        repeat (5) begin
            @(posedge CLK);
        end

        // End simulation safely
        $display("\n[TB INFO] Simulation finished.");
        $finish;
    end

    // 6. Complete Datapath Runtime Log
    initial begin
        // Print clean table column headers
        $display("\n%-10s | %-8s | %-8s | %-3s | %-3s | %-3s | %-8s | %-8s | %-8s", 
                 "Time", "PC", "Inst", "rs1", "rs2", "dr", "SrcA", "ALU Res", "Reg WD (RD)");
        $display("---------------------------------------------------------------------------------------------");
        
        forever begin
            @(posedge CLK);
            #(CLK_PERIOD / 10); // Settle delay
            
            if (!RESET) begin
                $display("%-10t | %-8h | %-8h | x%-2d | x%-2d | x%-2d | %-8h | %-8h | %-8h", 
                         $time, 
                         dut.pc, 
                         dut.instruction, 
                         dut.rs1,
                         dut.rs2,
                         dut.dr,
                         dut.REG_DATA_1,
                         dut.alu_result,
                         RD // Top-level output hooked directly to register file write-back input WD3
                );
            end
        end
    end

endmodule


module sign_extender
  #(
    parameter DATA_WIDTH = 32
  )
  (
    input  logic [DATA_WIDTH - 1 : 0] instruction,
    input  logic [2:0]                imm_ctrl,
    output logic [DATA_WIDTH - 1 : 0] imm_ext
  );

  always_comb begin
    case (imm_ctrl)
      // 3'b000: I-type (e.g., addi, lw)
      3'b000: begin
        imm_ext = { {20{instruction[31]}}, instruction[31:20] };
      end

      // 3'b001: S-type (e.g., sw, sb) -> 12-bit split immediate
      3'b001: begin
        imm_ext = { {20{instruction[31]}}, instruction[31:25], instruction[11:7] };
      end

      // Default safe fallback -> outputs 32 bits of 0
      default: begin 
        imm_ext = {DATA_WIDTH{1'b0}};
      end
    endcase
  end

endmodule


`timescale 1ns/1ps

module tb_group();

    // 1. Parameters matching your design
    localparam ADDRESS_WIDTH = 5;
    localparam DATA_WIDTH    = 32;
    localparam DEPTH         = 64;
    localparam CLK_PERIOD    = 10;

    // 2. Testbench driven control signals
    logic       CLK;
    logic       RESET;
    logic       WE3;
    logic [2:0] imm_ctrl;
    logic [2:0] alu_ctrl;
    logic       WE;

    // 3. Instantiate the Device Under Test (DUT)
    group #(
        .ADDRESS_WIDTH(ADDRESS_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .DEPTH(DEPTH)
    ) dut (
        .CLK(CLK),
        .RESET(RESET),
        .WE3(WE3),
        .imm_ctrl(imm_ctrl),
        .alu_ctrl(alu_ctrl),
        .WE(WE)
    );

    // 4. Clock Generation
    initial begin
        CLK = 0;
        forever #(CLK_PERIOD/2) CLK = ~CLK;
    end

    // 5. Stimulus Block
    initial begin
        // Initialize control signals to safe baseline defaults
        RESET    = 1;
        WE3      = 0;
        imm_ctrl = 3'b000; // Default I-type
        alu_ctrl = 3'b000; // Default ADD
        WE       = 0;

        // Print initial memory state at startup
        #1;
        $display("========================================");
        $display("--- INITIAL INSTRUCTION MEMORY DUMP ----");
        $display("========================================");
        dut.mem.dump_memory(); 
        $display("========================================\n");

        // Release reset to start stepping through a.hex instructions
        #(CLK_PERIOD * 2);
        @(negedge CLK);
        RESET = 0;
        $display("[TB INFO] Reset released. Beginning Execution.\n");

        // --- CYCLE 1: Simulating an I-type Instruction (e.g., addi) ---
        @(negedge CLK);
        WE3      = 1;      // Enable register file writeback
        imm_ctrl = 3'b000; // Sign extender set to I-type
        alu_ctrl = 3'b000; // ALU operation set to ADD
        WE       = 0;      // Disable data memory write

        // --- CYCLE 2: Simulating an S-type Store Instruction (e.g., sw) ---
        @(negedge CLK);
        WE3      = 0;      // Disable register file writeback (Stores don't write to registers)
        imm_ctrl = 3'b001; // Sign extender set to your new S-type split layout!
        alu_ctrl = 3'b000; // ALU computes: Base Register (rs1) + S-Immediate offset
        WE       = 1;      // Enable data memory write (latches REG_DATA_2 into RAM)

        // --- CYCLE 3: Clear controls back to safe state ---
        @(negedge CLK);
        WE       = 0;
        WE3      = 1;
        imm_ctrl = 3'b000;

        // Let it cycle through remaining instructions
        repeat (5) @(posedge CLK);

        $display("\n[TB INFO] Simulation finished.");
        $finish;
    end

    // 6. Complete Datapath Runtime Log
    initial begin
        $display("\n%-10s | %-8s | %-8s | %-3s | %-8s | %-8s | %-8s | %-2s | %-8s", 
                 "Time", "PC", "Inst", "Imm", "SrcA (r1)", "SrcB (imm)", "ALU Res", "WE", "RAM In(r2)");
        $display("-----------------------------------------------------------------------------------------------------");
        
        forever begin
            @(posedge CLK);
            #(CLK_PERIOD / 10); // Settle delay for combinational signals
            
            if (!RESET) begin
                $display("%-10t | %-8h | %-8h | 3'b%03b | %-8h | %-8h | %-8h | %-2b | %-8h", 
                         $time, 
                         dut.pc, 
                         dut.instruction, 
                         imm_ctrl,
                         dut.REG_DATA_1,
                         dut.imm_ext,
                         dut.alu_result,
                         WE,
                         dut.REG_DATA_2 // This is the data now being sent directly to data memory input WD
                );
            end
        end
    end

endmodule
