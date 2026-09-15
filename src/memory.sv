module register_file
#(
    parameter N = 5,
    parameter M = 32
)
(

    input logic             CLK,
    input logic             WE3,

    input logic [N-1:0]     A1,
    output logic [M-1:0]    RD1,

    input logic [N-1:0]     A2,
    output logic [M-1:0]    RD2,

    input logic [N-1:0]     A3,
    input logic [M-1:0]     WD3

);

logic [M-1:0] memarray [(1<<N)-1:0];


//synchronous write
always_ff @(posedge CLK) begin

    if(WE3) begin
        memarray[A3] <= WD3;
    end

end


//asynchronous
always_comb begin
    RD1 = memarray[A1];
    RD2 = memarray[A2];
end


task automatic dump_memory();

    for(int i = 0; i < (1<<N); i++) begin
        $display(
            "%d | %h | %b", 
            i, 
            memarray[i], 
            memarray[i]
        );
    end

endtask

endmodule


module data_memory
#(
    parameter N = 32,
    parameter DEPTH = 64
)
(
    input logic             CLK, 
    input logic             WE, 
    input logic [N-1:0]     A,
    input logic [N-1:0]     WD,
    output logic [N-1:0]    RD
);

logic [N-1:0] memarray[DEPTH-1:0];


always_comb begin
    if (A < DEPTH) begin
        RD = memarray[A];
    end else begin
        RD = {N{1'bx}};
    end
end

task automatic dump_memory();

    for(int i = 0; i < DEPTH; i++) begin
        $display(
            "%d | %h | %b", 
            i, 
            memarray[i], 
            memarray[i]
        );
    end

endtask

endmodule