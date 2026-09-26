
module tb;

  parameter int MEM_SIZE = 8;

  parameter int ADDR_WIDTH = $clog2(MEM_SIZE);

  // this is initialized to zero
  bit [15:0] mem[MEM_SIZE];

  bit [ADDR_WIDTH-1:0] addr;

  initial begin

    $display("%d %d", MEM_SIZE, ADDR_WIDTH);
    

    // addr = {1'b1, {(ADDR_WIDTH-1){1'b0}}};
    // addr = { {(ADDR_WIDTH-1){1'b0}}, 1'b1};

    // es un buffer circular
    
    addr = ADDR_WIDTH'(9);
    
    mem[addr] = 16'hFFFF;

    foreach (mem[i]) begin
      $display("%h", mem[i]);
    end
  end


endmodule: tb

