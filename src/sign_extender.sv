module sign_extender
  #(
    parameter DATA_WIDTH = 32
  )
  (
    input logic [DATA_WIDTH - 1 : 0] instruction,

    input logic [2:0] imm_ctrl,

    output logic [DATA_WIDTH - 1 : 0] imm_ext
  );

  always_comb begin
    
    case (imm_ctrl)
      
      3'b000: begin
        
        imm_ext = 
        {
          {20 {instruction[31]}}, 
          
          instruction[31:20]
        };

      end

      3'b001: begin 

        imm_ext = 
        {
          {20 {instruction[31]}}, 
          
          instruction[31:25],

          instruction[11:7]
        };

      end

      3'b010: begin 

        imm_ext = 
        
        {
          {20 {instruction[31]}}, 
          
          instruction[7],

          instruction[30:25],

          instruction[11:8],

          1'b0
        };

      end

      3'b011: begin 

        imm_ext = 
        
        {
          {12 {instruction[31]}}, 
          
          instruction[19:12],
          
          instruction[20],

          instruction[30:21],

          1'b0
        };

      end
      

      default: begin 
      
        imm_ext = 
        {
          DATA_WIDTH

          {
            1'b0
          }

        };

    end

    endcase


  end

endmodule