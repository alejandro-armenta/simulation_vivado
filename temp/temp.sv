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
