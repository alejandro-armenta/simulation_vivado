`timescale 1ns/1ps

module testbench();

logic a, b, c, y;

sillyfunction dut(.a(a),.b(b),.c(c),.y(y));

initial begin

a=0;b=0;c=0;#10;

if(y===1) $display("SUCCESS"); else $error("000 failed");

a=0;b=0;c=1;#10;

if(y===0) $display("SUCCESS"); else $error("001 failed");

a=0;b=1;c=0;#10;

if(y===0) $display("SUCCESS"); else $error("010 failed");

a=0;b=1;c=1;#10;

if(y===0) $display("SUCCESS"); else $error("011 failed");

a=1;b=0;c=0;#10;

if(y===1) $display("SUCCESS"); else $error("100 failed");

a=1;b=0;c=1;#10;

if(y===1) $display("SUCCESS"); else $error("101 failed");

a=1;b=1;c=0;#10;

if(y===0) $display("SUCCESS"); else $error("110 failed");

a=1;b=1;c=1;#10;

if(y===0) $display("SUCCESS"); else $error("111 failed");

end

endmodule