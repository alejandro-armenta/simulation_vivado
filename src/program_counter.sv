module group

    #(
        parameter ADDRESS_WIDTH = 5,
        parameter DATA_WIDTH = 32,
        parameter DEPTH = 64
    )

    (
        input logic CLK,
        input logic RESET,
        
        input logic WE3,
        input logic [ADDRESS_WIDTH-1:0] A3,
        input logic [DATA_WIDTH-1:0] WD3,

        output logic [DATA_WIDTH-1:0] REG_DATA_1,
        output logic [DATA_WIDTH-1:0] REG_DATA_2
        
        );

    logic [DATA_WIDTH-1:0] pcnext;
    logic [DATA_WIDTH-1:0] pc;
    logic [DATA_WIDTH-1:0] instruction;

    program_counter 

        #(.N(DATA_WIDTH)) 

        register(
            .CLK(CLK), 
            .RESET(RESET),       
            .PCNext(pcnext),

            .PC(pc)
            );

    adder_4 

        #(.N(DATA_WIDTH)) 

        adder(
            .PC(pc),
            
            .PCPlus4(pcnext)
        );

    instruction_memory 

        #(
            .N(DATA_WIDTH),
            .DEPTH(DEPTH)
        )

        mem(
            .A(pc),

            .RD(instruction)
        );

    logic [ADDRESS_WIDTH-1:0] rs1;
    logic [ADDRESS_WIDTH-1:0] rs2;
    logic [ADDRESS_WIDTH-1:0] dr;

    logic [6:0] opcode;
    logic [2:0] funct3;
    logic [6:0] func7;

    decoder 
    
        dec(
            .instruction(instruction),

            .rs1(rs1),
            .rs2(rs2),
            .dr(dr),

            .opcode(opcode),
            .funct3(funct3),
            .func7(func7)
        );

    register_file

    regFile(
        
        .CLK(CLK),

        .WE3(WE3),

        .A1(rs1),

        .RD1(REG_DATA_1),

        .A2(rs2),
        .RD2(REG_DATA_2),

        .A3(A3),

        .WD3(WD3)
        );


    alu alu_();

endmodule

