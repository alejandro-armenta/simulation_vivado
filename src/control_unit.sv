module control_unit
  
  (
    input logic [6:0]   opcode,
    input logic [2:0]   func3,
    input logic [6:0]   func7,

    input logic         zero,

    output logic        pc_source,

    // main controler
    output logic        WE3,
    output logic [2:0]  imm_ctrl,
    output logic        alu_src,
    output logic        WE,
    output logic        result_src,

    // alu controler
    output logic [2:0]  alu_ctrl
    
  );

  logic [1:0] aluop;
  logic branch;


  always_comb begin 
    

    case (opcode)

      // r type
      7'b0110011:begin 
        
        WE3 = 1;
        imm_ctrl = 3'bxxx;
        alu_src = 0;
        WE = 0;
        result_src = 0;

        branch = 0;
        aluop = 2'b10;

      end 

      7'b0110011:begin 
        
        WE3 = 1;
        imm_ctrl = 3'bxxx;
        alu_src = 0;
        WE = 0;
        result_src = 0;

        branch = 0;
        aluop = 2'b10;

      end 

      7'b0110011:begin 
        
        WE3 = 1;
        imm_ctrl = 3'bxxx;
        alu_src = 0;
        WE = 0;
        result_src = 0;

        branch = 0;
        aluop = 2'b10;

      end 


      7'b0110011:begin 
        
        WE3 = 1;
        imm_ctrl = 3'bxxx;
        alu_src = 0;
        WE = 0;
        result_src = 0;

        branch = 0;
        aluop = 2'b10;

      end 
      default: begin
          // Maintain defaults safely
      end
    
    endcase
    // aluop = 2'b00;
    // branch = 0;

  end


  always_comb begin 
    case (aluop)

      2'b00: alu_ctrl = 3'b000;
      2'b01: alu_ctrl = 3'b001;

      2'b10: begin
        
        case (func3)
          // alu_ctrl = 3'b000;
          3'b000: begin
            
            logic [1:0] a = {opcode[5],func7[5]};
            
            case (a)
              
              2'b00: alu_ctrl = 3'b000;
              2'b01: alu_ctrl = 3'b000;
              2'b10: alu_ctrl = 3'b000;
              2'b11: alu_ctrl = 3'b001;

              default: alu_ctrl = 3'b000;  
            
            endcase
          
          end

          3'b010: alu_ctrl = 3'b101;
          3'b110: alu_ctrl = 3'b011;
          3'b111: alu_ctrl = 3'b010;

          default: alu_ctrl = 3'b000;     
        
        endcase

      end

    default: alu_ctrl = 3'b000;

    endcase
  end


  always_comb begin
    pc_source = branch & zero;
  end

endmodule