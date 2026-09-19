`timescale 1ns/1ps;

module group_tb();
  
    parameter ADDRESS_WIDTH = 5;
    parameter DATA_WIDTH = 32;
    parameter DEPTH = 16;

    logic CLK;
    logic RESET;

    logic WE3;

    logic [2:0] imm_ctrl;
    logic [2:0] alu_ctrl;

    logic WE;

    group 

        #(
            .ADDRESS_WIDTH(ADDRESS_WIDTH),
            .DATA_WIDTH(DATA_WIDTH),
            .DEPTH(DEPTH)
        )

        dut(
            .CLK(CLK), 
            .RESET(RESET),
            
            .WE3(WE3),

            .imm_ctrl(imm_ctrl),

            .alu_ctrl(alu_ctrl),

            .WE(WE)
        );

    always begin
        CLK=0;#5;
        CLK=1;#5;
    end


    initial begin 

        @(posedge CLK);

        RESET = 1;
        WE3 = 0;


        @(negedge CLK);
        
        RESET = 0;
        
        WE3 = 1;

        WE = 0;

        // type load
        imm_ctrl = 3'b000;
        
        // suma
        alu_ctrl = 3'b000;
        
        
        @(posedge CLK);
        #1;

        dut.dataMemory.dump_memory();

        
        @(negedge CLK);
        
        // dont write to register file
        WE3 = 0;

        // write to memory
        WE = 1;

        // type store
        imm_ctrl = 3'b001;
        
        // suma
        alu_ctrl = 3'b000;
        
        @(posedge CLK);
        #1;

        dut.dataMemory.dump_memory();
        
        $finish;
    end


    initial begin
        /*
        $monitor(
          "%1t %h %h %h", 
          $time, 
          dut.pc, 
          dut.instruction, 
          RD
          );
          */
        end




endmodule