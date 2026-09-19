`timescale 1ns/1ps;

module group_tb();
  
    parameter ADDRESS_WIDTH = 5;
    parameter DATA_WIDTH = 32;
    parameter DEPTH = 64;

    logic CLK;
    logic RESET;

    logic WE3;
    logic [ADDRESS_WIDTH-1:0] A3;
    logic [DATA_WIDTH-1:0] WD3;

    logic WE;
    logic [DATA_WIDTH-1:0] WD;
    logic [DATA_WIDTH-1:0] RD;

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
            .A3(A3),
            .WD3(WD3),
            .WE(WE),
            .WD(WD),

            .RD(RD)

        );

    always begin
        CLK=0;#5;
        CLK=1;#5;
    end


    initial begin 

        #1;

        RESET = 1;

        WE3 = 0;
        A3 = 0;
        WD3 = 0;
        WE = 0;
        WD = 0;

        //$display("%h", REG_DATA_1);
        #1;
    
        RESET = 0;

        repeat (5) begin

            @(posedge CLK);
            #1;

            //$display("%h", REG_DATA_1);

        end
        
        $finish;
    end


    initial begin
        $monitor(
          "%1t %h %h %h", 
          $time, 
          dut.pc, 
          dut.instruction, 
          RD
        );
    end




endmodule