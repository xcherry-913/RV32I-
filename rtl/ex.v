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

    //to ALU
    output [3:0] alu_ctrl_o,
    output reg [31:0] alu_op1_o,
    output reg [31:0] alu_op2_o,

    //from ALU
    input [31:0] alu_out_i,

    //to gpr
    output  [4:0] rd_addr_o,
    output  reg [31:0] rd_wdata_o,
    output  gpr_wen_o,

    //to pc/id_ex/if_id
    output [31:0] jump_pc_o,
    output reg jump_en_o,
    output flush_en_o

);
    assign alu_ctrl_o = alu_ctrl_i;

    assign rd_addr_o = rd_addr_i;
    assign gpr_wen_o = gpr_wen_i;    

    wire [2:0] fun3;
    assign fun3 = fun3_i;


    //分支指令判断
    wire op_eq;
    wire op_lts;//less than(signed)
    wire op_ltu;//less than(unsigned)

    assign op_eq  = op1_i == op2_i;
    assign op_lts = $signed(op1_i) < $signed(op2_i);
    assign op_ltu = op1_i < op2_i;

    //操作数选择
    always @(*) begin
        case(alu_ctrl_i)
        `ALU_CMP:begin
            alu_op1_o = imm_i;
            alu_op2_o = inst_addr_i;           
        end

        `ALU_JAL,`ALU_AUIPC:begin
            alu_op1_o = op1_i;
            alu_op2_o = inst_addr_i;
        end

        default:begin
            alu_op1_o = op1_i;
            alu_op2_o = op2_i;
        end
        endcase
    end

    //JUMP控制信号生成
    assign jump_pc_o = jump_en_o ? alu_out_i : 32'b0;
    assign flush_en_o = jump_en_o;

    always @(*) begin
        case(alu_ctrl_i)
        `ALU_CMP:begin
            case(fun3[2:1])                
                2'b00:begin
                    //0:beq   1:bne
                    jump_en_o = fun3[0] ? ~op_eq : op_eq;
                end

                2'b10:begin
                    //0:blt   1:bge
                    jump_en_o = fun3[0] ? ~op_lts : op_lts;
                end                

                2'b11:begin
                    //0:bltu   1:bgeu
                    jump_en_o = fun3[0] ? ~op_ltu : op_ltu;
                end 
                 
                default :begin
                    jump_en_o = 1'b0;
                end  
            endcase
        end

        `ALU_JAL,`ALU_JALR:jump_en_o = 1'b1;

        default : jump_en_o = 1'b0;
        endcase
    end
     


    //输出逻辑
    wire [31:0] next_pc;
    assign next_pc = inst_addr_i + 4;

    always @(*) begin
        case(alu_ctrl_i)
        `ALU_JAL,`ALU_JALR:rd_wdata_o = next_pc;
        `ALU_LUI:rd_wdata_o = op1_i;
        `ALU_CMP:rd_wdata_o = 32'b0;
        default : rd_wdata_o = alu_out_i;
        endcase
    end
        
//    always @(*) begin
//     //默认赋值
//     rd_addr_o = rd_addr_i;
//     gpr_wen_o = gpr_wen_i;
//     rd_wdata_o = 32'b0;
//     jump_en_o = 1'b0;
//     jump_pc_o = 32'b0;
//     flush_en_o = 1'b0;
//     case(alu_ctrl_i)
//         `ALU_ADD:rd_wdata_o = op1_i + op2_i;
//         `ALU_SUB:rd_wdata_o = op1_i - op2_i;
//         `ALU_AND:rd_wdata_o = op1_i & op2_i;
//         `ALU_OR :rd_wdata_o = op1_i | op2_i;
//         `ALU_XOR:rd_wdata_o = op1_i ^ op2_i;
//         `ALU_SLL:rd_wdata_o = op1_i << op2_i[4:0];
//         `ALU_SRL:rd_wdata_o = op1_i >> op2_i[4:0];
//         `ALU_SRA:rd_wdata_o = $signed(op1_i) >>> op2_i[4:0];
//         `ALU_SLT:rd_wdata_o = ($signed(op1_i) < $signed(op2_i)) ? 32'd1 : 32'd0;
//         `ALU_SLTU:rd_wdata_o = op1_i < op2_i ? 32'b1 : 32'b0;

//         `ALU_CMP:begin
//             case(fun3[2:1])
//                 2'b00:begin
//                     //0:beq   1:bne
//                     jump_en_o = fun3[0] ? ~alu_eq : alu_eq;
//                     jump_pc_o = jump_en_o ? inst_addr_i+imm_i : 32'b0;
//                     flush_en_o = jump_en_o;
//                 end

//                 2'b10:begin
//                     //0:blt   1:bge
//                     jump_en_o = fun3[0] ? ~alu_lts : alu_lts;
//                     jump_pc_o = jump_en_o ? inst_addr_i+imm_i : 32'b0;
//                     flush_en_o = jump_en_o;
//                 end                

//                 2'b11:begin
//                     //0:bltu   1:bgeu
//                     jump_en_o = fun3[0] ? ~alu_ltu : alu_ltu;
//                     jump_pc_o = jump_en_o ? inst_addr_i+imm_i : 32'b0;
//                     flush_en_o = jump_en_o;
//                 end                

//                 default :begin
//                     jump_en_o = 1'b0;
//                     jump_pc_o = 32'b0;
//                     flush_en_o = 1'b0;
//                 end
//             endcase
//         end

//         `ALU_JAL:begin
//             jump_en_o = 1'b1;
//             jump_pc_o = inst_addr_i+op1_i;
//             flush_en_o = jump_en_o;
//             rd_wdata_o = inst_addr_i + 4;
//         end

//         `ALU_JALR:begin
//             jump_en_o = 1'b1;
//             jump_pc_o = (op1_i+op2_i) & ~(32'b1);
//             flush_en_o = jump_en_o;
//             rd_wdata_o = inst_addr_i + 4;            
//         end

//         `ALU_LUI:begin
//             rd_wdata_o = op1_i;
//         end

//         `ALU_AUIPC:begin
//             rd_wdata_o = op1_i+inst_addr_i;
//         end     

//         default:begin
//             rd_wdata_o = 32'b0;
//             jump_en_o = 1'b0;
//             jump_pc_o = 32'b0;
//             flush_en_o = 1'b0;
//         end
//     endcase
//    end 
endmodule