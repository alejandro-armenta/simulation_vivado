
module alu
#(parameter N = 32)
(
      input logic [N-1:0] srca, 
      input logic [N-1:0] srcb,

      input logic [2:0] alucontrol,
      
      output logic [N-1:0] aluresult,

      output logic zero 
);


always_comb begin

    case (alucontrol)

        3'b000: aluresult = srca + srcb; 
        3'b001: aluresult = srca - srcb; 
        
        3'b010: aluresult = srca & srcb; 
        3'b011: aluresult = srca | srcb; 

        3'b101: begin 
            
            logic slt;

            logic [N-2:0] padding; 
            
            slt = ($signed(srca) < $signed(srcb));

            padding = {(N-1){1'b0}};

            aluresult =  slt ? {padding, 1'b1} : {N{1'b0}}; 

        end

        default: aluresult = {N{1'bx}};

    endcase

    zero = (aluresult == {N{1'b0}});

end


endmodule
