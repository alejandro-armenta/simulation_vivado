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

        input logic [2:0] imm_ctrl,
        input logic [2:0] alu_ctrl,

        input logic WE
    );

    logic [DATA_WIDTH-1:0] pcnext;
    logic [DATA_WIDTH-1:0] pc;
    logic [DATA_WIDTH-1:0] instruction;

    logic [ADDRESS_WIDTH-1:0] rs1;
    logic [ADDRESS_WIDTH-1:0] rs2;
    logic [ADDRESS_WIDTH-1:0] dr;

    logic [6:0] opcode;
    logic [2:0] funct3;
    logic [6:0] func7;

    logic [DATA_WIDTH-1:0] REG_DATA_1;
    logic [DATA_WIDTH-1:0] REG_DATA_2;
    
    logic [DATA_WIDTH-1:0] imm_ext;

    logic [DATA_WIDTH-1:0] alu_result;
    logic zero;

    logic [DATA_WIDTH-1:0] RD;

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
        #(
          .N(ADDRESS_WIDTH),
          .M(DATA_WIDTH)
        )
        regFile(
            
            .CLK(CLK),

            .WE3(WE3),

            .A1(rs1),

            .RD1(REG_DATA_1),

            .A2(rs2),
            .RD2(REG_DATA_2),

            .A3(dr),

            .WD3(RD)
            );


    sign_extender 
    #(
      .DATA_WIDTH(DATA_WIDTH)
    )
    se(
      .instruction(instruction), 
      .imm_ctrl(imm_ctrl),
      .imm_ext(imm_ext)
    );

    
    alu 
    
    #(
      .N(DATA_WIDTH)
    )

    alu_
    (
      .srca(REG_DATA_1),
      .srcb(imm_ext),
      .alucontrol(alu_ctrl),
      .aluresult(alu_result),
      .zero(zero)
    );

    

    data_memory 
    #(
      .N(DATA_WIDTH),
      .DEPTH(DEPTH)
    )

    dataMemory(
      .CLK(CLK),
      
      .WE(WE),
      .A(alu_result),
      .WD(REG_DATA_2),
      
      .RD(RD)
    );

endmodule

