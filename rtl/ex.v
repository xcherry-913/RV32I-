`include "defines.v"
module ex(
    //from id_ex
    input [2:0] fun3_i,
    input [31:0] inst_addr_i,
    input [31:0] op1_i,
    input [31:0] op2_i,
    input [31:0] imm_i,
    input [4:0] rd_addr_i,
    input  gpr_wen_i,
    input [3:0] alu_ctrl_i,
    //input mem_read_i,   
    //input mem_write_i,
    //input [1:0] wb_sel_i,

    //to gpr
    output reg [4:0] rd_addr_o,
    output reg [31:0] rd_wdata_o,
    output reg gpr_wen_o,

    //to pc/id_ex/if_id
    output reg [31:0] jump_pc_o,
    output reg jump_en_o,
    output reg flush_en_o

);
    wire [2:0] fun3;
    assign fun3   = fun3_i;


    wire alu_eq;
    wire alu_lts;//less than(signed)
    wire alu_ltu;//less than(unsigned)

    assign alu_eq  = op1_i == op2_i;
    assign alu_lts = $signed(op1_i) < $signed(op2_i);
    assign alu_ltu = op1_i < op2_i;

    //ALU
   always @(*) begin
    //默认赋值
    rd_addr_o = rd_addr_i;
    gpr_wen_o = gpr_wen_i;
    rd_wdata_o = 32'b0;
    jump_en_o = 1'b0;
    jump_pc_o = 32'b0;
    flush_en_o = 1'b0;
    case(alu_ctrl_i)
        `ALU_ADD:begin
            rd_wdata_o = op1_i + op2_i;
        end

        `ALU_SUB:begin
            rd_wdata_o = op1_i - op2_i;
        end

        `ALU_CMP:begin
            case(fun3[2:1])
                2'b00:begin
                    //000:beq   001:bne
                    jump_en_o = fun3[0] ? ~alu_eq : alu_eq;
                    jump_pc_o = jump_en_o ? inst_addr_i+imm_i : 32'b0;
                    flush_en_o = jump_en_o;
                end
                default :begin
                    jump_en_o = 1'b0;
                    jump_pc_o = 32'b0;
                    flush_en_o = 1'b0;
                end
            endcase
        end

        `ALU_JAL:begin
            jump_en_o = 1'b1;
            jump_pc_o = inst_addr_i+op1_i;
            flush_en_o = jump_en_o;
            rd_wdata_o = inst_addr_i + 4;
        end

        `ALU_LUI:begin
            rd_wdata_o = op1_i;
        end
        default:begin
            rd_wdata_o = 32'b0;
            jump_en_o = 1'b0;
            jump_pc_o = 32'b0;
            flush_en_o = 1'b0;
        end
    endcase
   end 
endmodule