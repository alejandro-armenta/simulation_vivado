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
    output logic [1:0]  result_src,

    // alu controler
    output logic [2:0]  alu_ctrl
    
  );

  logic [1:0] aluop;
  logic branch;
  logic jump;
  


  always_comb begin 
    

    case (opcode)

      // load word
      7'b0000011:begin 
        
        WE3 = 1;imm_ctrl = 3'b000;alu_src = 1;WE = 0;result_src = 2'b01;branch = 0;aluop = 2'b00;jump = 0;

      end 

      // store word
      7'b0100011:begin 
        
        WE3 = 0;imm_ctrl = 3'b001;alu_src = 1;WE = 1;result_src = 2'bxx;branch = 0;aluop = 2'b00;jump = 0;

      end 

      // r type
      7'b0110011:begin 
        
        WE3 = 1;imm_ctrl = 3'bxxx;alu_src = 0;WE = 0;result_src = 2'b00;branch = 0;aluop = 2'b10;jump = 0;

      end


      // beq
      7'b1100011:begin 
        
        WE3 = 0;imm_ctrl = 3'b010;alu_src = 0;WE = 0;result_src = 2'bxx;branch = 1;aluop = 2'b01;jump = 0;

      end 

      // adi   
      7'b0010011:begin 
        
        WE3 = 1;imm_ctrl = 3'b000;alu_src = 1;WE = 0;result_src = 2'b00;branch = 0;aluop = 2'b10;jump = 0;

      end


      // jal
      7'b1101111:begin 
        
        WE3 = 1;imm_ctrl = 3'b011;alu_src = 0;WE = 0;result_src = 2'b10;branch = 0;aluop = 2'bxx;jump = 1;

      end 

      default: begin

        WE3 = 0;imm_ctrl = 3'bxxx;alu_src = 0;WE = 0;result_src = 2'bxx;branch = 0;aluop = 2'bxx;jump = 0;

      end
    
    endcase

  end


  always_comb begin 
    case (aluop)

      2'b00: alu_ctrl = 3'b000;
      2'b01: alu_ctrl = 3'b001;

      2'b10: begin
        
        case (func3)
          
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
    pc_source =  jump | (branch & zero);
  end

endmodule