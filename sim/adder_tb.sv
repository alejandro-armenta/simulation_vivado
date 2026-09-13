module adder_tb();

parameter N = 8;

logic [N-1:0] a, b;
logic cin;

logic [N-1:0] s;
logic cout;


adder #(.N(N)) dut(
    .a(a),
    .b(b),
    .cin(cin),
    .s(s),
    .cout(cout)
);

initial begin

a = 8'd10; b = 8'd20; cin = 0;#10;

a = 8'd45; b = 8'd55; cin = 1;#10;

a = 8'hFF; b = 8'h01; cin = 0;#10;

a = 8'hFF; b = 8'hFF; cin = 1;#10;

a = 8'd0; b = 8'd0; cin = 0;#10;

end

initial begin
    $monitor("Time=%5t a=%5d b=%5d cin=%b CARRY OUT=%b sum=%5d", 
             $time, a, b, cin, cout, s);
end


endmodule