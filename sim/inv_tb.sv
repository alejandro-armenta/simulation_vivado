module inv_tb();

logic [3:0] a, y;

inv dut(.a(a), .y(y));

initial begin
    
    a = 4'b0;

    #10;
    

    a = 4'b1111;

    #10;

    a = 4'b1010;

    #10;

    a = 4'b0110;

    #10;

    
    $finish;

end

endmodule