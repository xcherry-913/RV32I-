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
    input mem_read_i,   
    input mem_write_i,
    input wb_sel_i,

    input rs1_used_i,
    input rs2_used_i,
    input  [4:0] rs1_addr_i,
    input  [4:0] rs2_addr_i,

    //from ex_ram的数据前递
    input [31:0] EX_RAM_rd_wdata,
    input [4:0] EX_RAM_rd_addr,
    input EX_RAM_mem_read,
    input EX_RAM_gpr_wen,

    //from ram_wb的数据前递
    input [4:0] WB_rd_addr,
    input WB_gpr_wen,

    //from wb的数据前递
    input [31:0] WB_wdata,

    //to ALU
    output [3:0] alu_ctrl_o,
    output reg [31:0] alu_op1_o,
    output reg [31:0] alu_op2_o,

    //from ALU
    input [31:0] alu_out_i,

    //to pc/id_ex/if_id
    output [31:0] jump_pc_o,
    output reg jump_en_o,
    output flush_en_o,

    //to ex_ram
    output  [4:0] rd_addr_o,
    output  [31:0] rd_wdata_o,
    output  gpr_wen_o,
    output  wb_sel_o,

    output mem_read_o,   
    output mem_write_o,
    output [2:0] fun3_o,
    output [31:0] mem_wdata_o,
    output [31:0] mem_waddr_o,
    output [31:0] mem_raddr_o

    //from RAM
    //input [31:0] mem_rdata_i

);
    //EX的操作数选择
    reg [31:0] op1;
    reg [31:0] op2;

    //wire rs1_same1 = (rs1_addr_i == EX_RAM_rd_addr) || (rs1_addr_i == WB_rd_addr);
    //wire addr2_same = (rs2_addr_i == EX_RAM_rd_addr) || (rs2_addr_i == WB_rd_addr);

    always @(*) begin
        op1 = op1_i;
        if(rs1_used_i && (rs1_addr_i == EX_RAM_rd_addr) && EX_RAM_gpr_wen && (EX_RAM_rd_addr != 0))begin
            if(!EX_RAM_mem_read) op1 = EX_RAM_rd_wdata;
        end else if(rs1_used_i && (rs1_addr_i == WB_rd_addr) && WB_gpr_wen && (WB_rd_addr != 0))//load use stall
                op1 = WB_wdata;
        else op1 = op1_i;
    end


    always @(*) begin
        op2 = op2_i;
        if(rs2_used_i && (rs2_addr_i == EX_RAM_rd_addr) && EX_RAM_gpr_wen && (EX_RAM_rd_addr != 0))begin
            if(!EX_RAM_mem_read) op2 = EX_RAM_rd_wdata;
        end else if(rs2_used_i && (rs2_addr_i == WB_rd_addr) && WB_gpr_wen && (WB_rd_addr != 0))//load use stall
                op2 = WB_wdata;
        else op2 = op2_i;
    end

    wire [2:0] fun3;
    assign fun3 = fun3_i;
    assign fun3_o = fun3_i;
    //ALU的操作码和操作数选择
    assign alu_ctrl_o = alu_ctrl_i;
    always @(*) begin
        case(alu_ctrl_i)
        `ALU_CMP:begin
            alu_op1_o = imm_i;
            alu_op2_o = inst_addr_i;           
        end

        `ALU_JAL,`ALU_AUIPC:begin
            alu_op1_o = op1;
            alu_op2_o = inst_addr_i;
        end

        `ALU_STR:begin
            alu_op1_o = op1;
            alu_op2_o = imm_i; 
        end

        default:begin
            alu_op1_o = op1;
            alu_op2_o = op2;
        end
        endcase
    end

    //分支指令、跳转指令的JUMP控制信号生成
    wire op_eq;
    wire op_lts;//less than(signed)
    wire op_ltu;//less than(unsigned)

    assign op_eq  = op1 == op2;
    assign op_lts = $signed(op1) < $signed(op2);
    assign op_ltu = op1 < op2;

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
    assign mem_read_o = mem_read_i;
    assign mem_write_o = mem_write_i;
    assign mem_raddr_o = alu_out_i;
    assign mem_waddr_o = alu_out_i;
    reg [31:0] mem_wdata_r;
    assign mem_wdata_o = mem_wdata_r;

    assign wb_sel_o  = wb_sel_i;
    assign rd_addr_o = rd_addr_i;
    assign gpr_wen_o = gpr_wen_i; 
    reg [31:0] rd_wdata_r;
    assign rd_wdata_o = rd_wdata_r;

    wire [31:0] next_pc;
    assign next_pc = inst_addr_i + 4;

    always @(*) begin
        rd_wdata_r  = 32'b0;
        mem_wdata_r = 32'b0;
        case(alu_ctrl_i)
        `ALU_JAL,`ALU_JALR:rd_wdata_r = next_pc;
        `ALU_LUI:rd_wdata_r = op1;
        `ALU_CMP:rd_wdata_r = 32'b0;
        `ALU_STR:begin
            case(fun3[1:0])
                2'b00: mem_wdata_r = {24'b0,op2[7:0]};
                2'b01: mem_wdata_r = {16'b0,op2[15:0]};
                2'b10: mem_wdata_r = op2;
            endcase
        end
        default: begin
            rd_wdata_r = alu_out_i;
            mem_wdata_r = 32'b0;
        end
            
        endcase
    end


endmodule        
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
