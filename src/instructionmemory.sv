module instruction_memory
#(
    parameter N = 32,
    parameter DEPTH = 64
)
(
    input logic [N-1:0]     A,
    output logic [N-1:0]    RD
);

logic [N-1:0] memarray[DEPTH-1:0];

logic [N-1:0] word_addr;

always_comb begin
    
    word_addr = A >> 2;

    if (word_addr < DEPTH) begin

        RD = memarray[word_addr];

    end else begin

        RD = {N{1'bx}};
        
    end
end

initial begin
    $readmemh("a.hex", memarray);
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