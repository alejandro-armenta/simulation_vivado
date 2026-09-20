`timescale 1ns/1ps;

module group_tb();
  
    parameter ADDRESS_WIDTH = 5;

    parameter DATA_WIDTH = 32;
    
    parameter DEPTH = 16;

    logic pc_source;

    logic CLK;

    logic RESET;

    logic WE3;

    logic [2:0] imm_ctrl;

    logic alu_src;

    logic [2:0] alu_ctrl;

    logic WE;

    logic result_src;

    group 

        #(
            .ADDRESS_WIDTH(ADDRESS_WIDTH),

            .DATA_WIDTH(DATA_WIDTH),
            
            .DEPTH(DEPTH)
        )

        dut(
            .pc_source(pc_source),

            .CLK(CLK), 
            
            .RESET(RESET),
            
            .WE3(WE3),

            .imm_ctrl(imm_ctrl),

            .alu_src(alu_src),
            
            .alu_ctrl(alu_ctrl),
            
            .WE(WE),

            .result_src(result_src)
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
        
        pc_source = 0;

        WE3 = 1;

        WE = 0;

        // type load
        imm_ctrl = 3'b000;

        alu_src = 1;

        // suma
        alu_ctrl = 3'b000;
        
        result_src = 1;

        
        @(posedge CLK);
        #1;


        
        @(negedge CLK);
        
        pc_source = 0;

        // dont write to register file
        WE3 = 0;

        // write to memory
        WE = 1;

        // type store
        imm_ctrl = 3'b001;
        
        alu_src = 0;

        // suma
        alu_ctrl = 3'b000;

        result_src = 1;
        
        @(posedge CLK);
        #1;

        // ALU
        @(negedge CLK);
        
        pc_source = 0;

        // write to register file
        WE3 = 1;

        // dont write to memory
        WE = 0;

        // type store
        imm_ctrl = 3'bx;
        
        alu_src = 0;

        // or
        alu_ctrl = 3'b011;

        result_src = 0;

        @(posedge CLK);
        #1;


        @(negedge CLK);
        
        pc_source = 1;

        WE3 = 0;
        
        imm_ctrl = 3'b010;
        
        alu_src = 0;
        
        alu_ctrl = 3'b001;
        
        WE = 0;

        result_src = 0;


        @(posedge CLK);
        #1;
        
        @(negedge CLK);
        
        pc_source = 0;

        //repeat (5) begin
        //   
        //end 
        
        // dut.regFile.dump_memory();
        
        $finish;
    end


    initial begin
      
        $monitor(
          "%1t %h %h", 
          $time, 
          dut.pc, 
          dut.instruction
          );
        end




endmodule