module group

    #(
        parameter ADDRESS_WIDTH = 5,

        parameter DATA_WIDTH = 32,
        
        parameter DEPTH = 64
    )

    (
        input logic pc_source,

        input logic CLK,

        input logic RESET,

        input logic WE3,

        input logic [2:0] imm_ctrl,

        input logic alu_src,
        
        input logic [2:0] alu_ctrl,
        
        input logic WE,

        input logic result_src
    );

    logic [DATA_WIDTH-1:0] pcnext;
    
    logic [DATA_WIDTH-1:0] pcplus4;

    logic [DATA_WIDTH-1:0] pc;
    
    logic [DATA_WIDTH-1:0] instruction;

    logic [ADDRESS_WIDTH-1:0] rs1;
    
    logic [ADDRESS_WIDTH-1:0] rs2;
    
    logic [ADDRESS_WIDTH-1:0] destR;

    logic [6:0] opcode;
    
    logic [2:0] funct3;
    
    logic [6:0] func7;

    logic [DATA_WIDTH-1:0] srcA;
    
    logic [DATA_WIDTH-1:0] REG_DATA_2;
    
    logic [DATA_WIDTH-1:0] imm_ext;
    
    logic [DATA_WIDTH-1:0] srcB;

    logic [DATA_WIDTH-1:0] pc_target;
    
    logic [DATA_WIDTH-1:0] alu_result;
    
    logic zero;
    
    logic [DATA_WIDTH-1:0] RD;
    
    logic [DATA_WIDTH-1:0] result;

    mux2_n 
    
    #(.N(DATA_WIDTH))
    
    mux0(
      
      .a(pcplus4),

      .b(pc_target),

      .sel(pc_source),

      .out(pcnext)
    );
    

    register 

    #(.N(DATA_WIDTH)) 

    register_
    (
      .CLK(CLK), 
      
      .RESET(RESET),  

      .PCNext(pcnext),

      .PC(pc)
    );



    adder_4 

    #(.N(DATA_WIDTH)) 

    adder_4_
    
    (

        .PC(pc),
        
        .PCPlus4(pcplus4)

    );

    instruction_memory 

    #(
        .N(DATA_WIDTH),
        .DEPTH(DEPTH)
    )

    instruction_memory_
    (
        .A(pc),
        .RD(instruction)
    );

    
    decoder 

    decoder_
    
    (
        .instruction(instruction),

        .rs1(rs1),
        .rs2(rs2),
        .dr(destR),

        .opcode(opcode),
        .funct3(funct3),
        .func7(func7)
    );

    register_file

    #(
      .N(ADDRESS_WIDTH),
      .M(DATA_WIDTH)
    )
    
    register_file_
    
    (
        
        .CLK(CLK),

        .WE3(WE3),

        .A1(rs1),

        .RD1(srcA),

        .A2(rs2),
        .RD2(REG_DATA_2),

        .A3(destR),

        .WD3(result)
        );


    sign_extender 
    
    #(
      .DATA_WIDTH(DATA_WIDTH)
    )
    
    sign_extender_
    
    (
      .instruction(instruction), 
      .imm_ctrl(imm_ctrl),
      .imm_ext(imm_ext)
    );


    mux2_n 
    
    #(.N(DATA_WIDTH))
    
    mux1(
      .a(REG_DATA_2),
      .b(imm_ext),
      .sel(alu_src),

      .out(srcB)
    );
    

    adder 
    
    #(.N(DATA_WIDTH))
    
    adder_
    (
      .a(pc),
      .b(imm_ext),
      .out(pc_target)
      );


    alu 
    
    #(
      .N(DATA_WIDTH)
    )

    alu_
    (
      .srca(srcA),
      .srcb(srcB),
      .alucontrol(alu_ctrl),
      .aluresult(alu_result),
      .zero(zero)
    );

    

    data_memory 

    #(
      .N(DATA_WIDTH),
      .DEPTH(DEPTH)
    )

    data_memory_
    
    (
      .CLK(CLK),
      
      .WE(WE),
      .A(alu_result),
      .WD(REG_DATA_2),
      
      .RD(RD)
    );


    mux2_n 

    #(.N(DATA_WIDTH))
    
    mux2(
      .a(alu_result),
      .b(RD),

      .sel(result_src),

      .out(result)
    );

endmodule

