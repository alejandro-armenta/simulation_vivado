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

always_ff @(posedge CLK) begin
    if (WE) begin
        if (A < DEPTH) begin
            memarray[A] <= WD;    
        end
    end
end

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