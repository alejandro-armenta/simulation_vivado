module tb;

  // rows and columns

  // 8 rows and 4 columns

  // it is unpacked



int array [0:7][0:3];  

initial begin

  array[0][0] = 86;
  array[1][0] = 42;
  array[2][0] = 56;
  
  $display("i j value\n");
  
  // se esta moviendo en los rows;

  foreach (array[i, j]) begin
    $display("%0d %0d %0d", i, j, array[i][j]);
  end

end

endmodule
