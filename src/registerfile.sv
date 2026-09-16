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


//you cannot write to 0
always_ff @(posedge CLK) begin

    if(WE3) begin
        if(A3 != 0) begin
            memarray[A3] <= WD3;
        end
    end

end



always_comb begin
    RD1 = (A1 == 0) ? {M{1'b0}} : memarray[A1];
    RD2 = (A2 == 0) ? {M{1'b0}} : memarray[A2];
end


initial begin
    for(int i = 0; i < (1<<N); i++) begin
        memarray[i] = {M{1'b0}};
    end

    memarray[9] = 32'h4;
    memarray[5] = 32'h6;
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


