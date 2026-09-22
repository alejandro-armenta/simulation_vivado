module mux4_n
  
  #(parameter N = 32)
  
  (
    input logic [N-1:0] a,
    input logic [N-1:0] b,
    input logic [N-1:0] c,
    input logic [N-1:0] d,
    
    input logic [1:0] sel,

    output logic [N-1:0] out
  );

  always_comb begin

    case (sel)

      2'b00: out = a;
      2'b01: out = b;
      2'b10: out = c;
      2'b10: out = d;
      
      default: out = {N{1'b0}};
    endcase

  end
  
endmodule