`timescale 1ns/1ps;

module group_tb();
  
    parameter ADDRESS_WIDTH = 5;

    parameter DATA_WIDTH = 32;
    
    parameter DEPTH = 16;

    logic CLK;

    logic RESET;

    group 

        #(
            .ADDRESS_WIDTH(ADDRESS_WIDTH),

            .DATA_WIDTH(DATA_WIDTH),
            
            .DEPTH(DEPTH)
        )

        dut(
            .CLK(CLK), 
            .RESET(RESET)
        );

    always begin

        CLK=0;#5;
      
        CLK=1;#5;
    
    end


    initial begin 

        @(posedge CLK);

        RESET = 1;

        @(negedge CLK);
        
        RESET = 0;
        
        repeat (20) @(posedge CLK);

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