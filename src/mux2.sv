module mux2_n
  
  #(parameter N = 32)
  
  (
    input logic [N-1:0] a,
    input logic [N-1:0] b,
    
    input logic sel,

    output logic [N-1:0] out
  );

  always_comb begin
      out = sel ? b : a;
  end
  
endmodule