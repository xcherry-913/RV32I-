
module id_ex(
    input clk,
    input rstn,
    input [2:0] fun3_i,
    input [31:0] inst_addr_i,
    input [31:0] op1_i,
    input [31:0] op2_i,
    input [4:0] rd_addr_i,
    input  gpr_wen_i,
    input [3:0] alu_ctrl_i,
    input mem_read_i,   
    input mem_write_i,
    input wb_sel_i,
    input [31:0] imm_i,
    input flush_en_i,
    input  [4:0] rs1_addr_i,
    input  [4:0] rs2_addr_i,
    input  rs1_used_i,   
    input  rs2_used_i,


    output reg [2:0] fun3_o,
    output reg [31:0] inst_addr_o,
    output reg [31:0] op1_o,
    output reg [31:0] op2_o,
    output reg [4:0] rs1_addr_o,
    output reg [4:0] rs2_addr_o,
    output reg [4:0] rd_addr_o,
    output reg  gpr_wen_o,
    output reg [3:0] alu_ctrl_o,
    output reg  mem_read_o,   
    output reg  mem_write_o,
    output reg  wb_sel_o,
    output reg  [31:0] imm_o,
    output reg  rs1_used_o,   
    output reg  rs2_used_o
);
   always @(posedge clk,negedge rstn) begin
        if(!rstn || flush_en_i)begin
            fun3_o <= 3'b0;
            inst_addr_o <= 32'b0;
            op1_o <= 32'b0;
            op2_o <= 32'b0;
            rd_addr_o <= 5'b0;
            gpr_wen_o <= 1'b0;
            alu_ctrl_o <= 4'b0;
            mem_read_o <= 1'b0;
            mem_write_o <= 1'b0;
            wb_sel_o <= 1'b0;  
            imm_o <= 32'b0;   
            rs1_addr_o <= 5'b0;       
            rs2_addr_o <= 5'b0;  
            rs1_used_o <= 1'b0;     
            rs2_used_o <= 1'b0;     
        end else begin
            fun3_o <= fun3_i;
            inst_addr_o <= inst_addr_i;
            op1_o <= op1_i;
            op2_o <= op2_i;
            rd_addr_o <= rd_addr_i;
            gpr_wen_o <= gpr_wen_i;
            alu_ctrl_o <= alu_ctrl_i;
            mem_read_o <= mem_read_i;
            mem_write_o <= mem_write_i;
            wb_sel_o <= wb_sel_i;  
            imm_o <= imm_i;  
            rs1_addr_o <= rs1_addr_i;
            rs2_addr_o <= rs2_addr_i;
            rs1_used_o <= rs1_used_i;     
            rs2_used_o <= rs2_used_i;     
        end
   end 
endmodule