module group

    #(
        parameter N = 32,
        parameter DEPTH = 64
    )

    (
        input logic CLK,
        input logic RESET
    );

    logic [N-1:0] pcnext;
    logic [N-1:0] pc;
    logic [N-1:0] instruction;

    program_counter 

        #(.N(N)) 

        register(
            .CLK(CLK), 
            .RESET(RESET),       
            .PCNext(pcnext),

            .PC(pc)
            );

    adder_4 

        #(.N(N)) 

        adder(
            .PC(pc),
            
            .PCPlus4(pcnext)
        );

    instruction_memory 

        #(
            .N(N),
            .DEPTH(DEPTH)
        )

        mem(
            .A(pc),

            .RD(instruction)
        );

    logic [4:0] rs1;
    logic [4:0] rs2;
    logic [4:0] dr;
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

    //register_file regFile();


endmodule

