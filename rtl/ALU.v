`include "defines.v"
module ALU(
    //from EX
    input [3:0] alu_ctrl_i,
    input [31:0] op1_i,
    input [31:0] op2_i,

    //to EX
    output reg [31:0] alu_out_o
);
   always @(*) begin
    alu_out_o = 32'b0;
    case(alu_ctrl_i)
        `ALU_AUIPC,`ALU_JAL,`ALU_CMP,`ALU_ADD,`ALU_STR:
                 alu_out_o = op1_i + op2_i;
        `ALU_SUB:alu_out_o = op1_i - op2_i;
        `ALU_AND:alu_out_o = op1_i & op2_i;
        `ALU_OR :alu_out_o = op1_i | op2_i;
        `ALU_XOR:alu_out_o = op1_i ^ op2_i;
        `ALU_SLL:alu_out_o = op1_i << op2_i[4:0];
        `ALU_SRL:alu_out_o = op1_i >> op2_i[4:0];
        `ALU_SRA:alu_out_o = $signed(op1_i) >>> op2_i[4:0];
        `ALU_SLT:alu_out_o = ($signed(op1_i) < $signed(op2_i)) ? 32'd1 : 32'd0;
        `ALU_SLTU:alu_out_o = op1_i < op2_i ? 32'b1 : 32'b0;
        `ALU_JALR:alu_out_o = (op1_i+op2_i) & ~(32'b1);
        default :alu_out_o = 32'b0;
    endcase
   end 
    
endmodule