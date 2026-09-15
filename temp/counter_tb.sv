`timescale 1ns / 1ps

module counter_tb();

parameter N = 8;

logic clk, reset;
logic [N-1:0] q;

counter #(.N(N)) dut(.clk(clk),.reset(reset),.q(q));

always begin
    clk = 0;#5;
    clk = 1;#5;
end

initial begin
    reset = 0;#5;
    reset = 1;#15;
    reset = 0;

    @(posedge clk);

    repeat(20) @(posedge clk);

    #5;
    reset = 1;#10;
    reset = 0;

    repeat(5) @(posedge clk);

    $finish;

end

initial begin
    $monitor("Time = %5t | Reset = %b | q = %d", $time, reset, q);
end




endmodule