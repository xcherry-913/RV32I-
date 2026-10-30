`include "defines.v"
module ex(
    //from id_ex
    input [31:0] inst_i,
    input [31:0] inst_addr_i,
    input [31:0] op1_i,
    input [31:0] op2_i,
    input [4:0] rd_addr_i,
    input  gpr_wen_i,
    input [3:0] alu_ctrl_i,
    //input mem_read_i,   
    //input mem_write_i,
    //input [1:0] wb_sel_i,


    //to gpr
    output reg [4:0] rd_addr_o,
    output reg [31:0] rd_wdata_o,
    output reg gpr_wen_o
);

    //ALU
   always @(*) begin
    rd_addr_o = rd_addr_i;
    case(alu_ctrl_i)
        `ALU_ADD:begin
            rd_wdata_o = op1_i + op2_i;
            gpr_wen_o = 1'b1;
        end

        `ALU_SUB:begin
            rd_wdata_o = op1_i - op2_i;
            gpr_wen_o = 1'b1;
        end
        default:begin
            rd_wdata_o = 32'b0;
            gpr_wen_o = 1'b0;
        end
    endcase
   end 
endmodule