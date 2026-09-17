module group

    #(
        parameter N = 32,
        parameter DEPTH = 64
    )

    (
        input logic CLK,
        input logic RESET,

        output logic [N-1:0] OUT_INST
    );

logic [N-1:0] pcnext;
logic [N-1:0] pc;

program_counter 

    #(.N(N)) 

    register(
        .CLK(CLK), 
        .RESET(RESET),       
        .PCNext(pcnext),

        //pcnext = pc + 4 se guarda en pc guardado en pc
        .PC(pc)
        );

adder_4 

    #(.N(N)) 

    adder(
        .PC(pc),
        //aqui te va a poner pc + 4
        .PCPlus4(pcnext)
    );

instruction_memory 

    #(
        .N(N),
        .DEPTH(DEPTH)
    )

    mem(
        .A(pc),
        .RD(OUT_INST)
    );


endmodule

