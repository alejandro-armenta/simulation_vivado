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
        
        // addi 10
        @(posedge CLK);
        #1;

        // addi -10
        @(posedge CLK);
        #1;

        @(posedge CLK);
        #1;

        @(posedge CLK);
        #1;

        // sw 20 en el 8
        @(posedge CLK);
        #1;

        @(posedge CLK);
        #1;

        
        // se salta una instruction 
        @(posedge CLK);
        #1;
        
        @(posedge CLK);
        #1;
        
        
        dut.register_file_.dump_memory();


        // dut.data_memory_.dump_memory();

        $finish;
        
    end


    initial begin
      
        // $monitor(
        //   "%1t %h %h", 
        //   $time, 
        //   dut.pc, 
        //   dut.instruction
        //   );
        
    end

endmodule