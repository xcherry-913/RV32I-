`include "defines.v"

module id(
    //from if_id
    input [31:0] inst_addr_i,
    input [31:0] inst_i,

    //to gpr 
    //补充：to id_ex；原因：便于数据前递
    output  [4:0] rs1_addr_o,
    output  [4:0] rs2_addr_o,

    //from gpr
    input [31:0] rs1_data_i,
    input [31:0] rs2_data_i,

    //to id_ex
    output [2:0] fun3_o,
    output [31:0] inst_addr_o,
    output reg [31:0] op1_o,
    output reg [31:0] op2_o,
    output [4:0] rd_addr_o,
    output reg  gpr_wen,
    output reg [3:0] alu_ctrl,
    output reg  mem_read,   
    output reg  mem_write,
    output reg  wb_sel,
    output reg  [31:0] imm_o,

    //补充:to id_ex，做数据前递选择
    output reg  rs1_used_o,   
    output reg  rs2_used_o

);

    assign inst_addr_o = inst_addr_i;
    //编码ALU操作和写回选择
    // localparam ALU_ADD = 4'b0000;
    // localparam ALU_SUB = 4'b0001;



    // localparam WB_ALU = 2'b00;
    // localparam WB_MEM = 2'b01;
    // localparam WB_PC4 = 2'b10;

    //分解指令
    wire [6:0] opcode;
    wire [2:0] fun3;
    wire [6:0] fun7;
    wire [31:0] imm_I;
    wire [31:0] imm_S;
    wire [31:0] imm_B;
    wire [31:0] imm_U;
    wire [31:0] imm_J;
    

    assign opcode   = inst_i[6:0];
    assign rd_addr_o  = inst_i[11:7];
    assign fun3   = inst_i[14:12];assign fun3_o = fun3;
    assign rs1_addr_o = inst_i[19:15];
    assign rs2_addr_o = inst_i[24:20];
    assign fun7   = inst_i[31:25];

    assign imm_I = {{20{inst_i[31]}}, inst_i[31:20]};

    assign imm_S = {{20{inst_i[31]}}, inst_i[31:25], inst_i[11:7]};

    assign imm_B = {{19{inst_i[31]}}, inst_i[31], inst_i[7],
                    inst_i[30:25], inst_i[11:8], 1'b0};

    assign imm_U = {inst_i[31:12], 12'b0};

    assign imm_J = {{11{inst_i[31]}}, inst_i[31], inst_i[19:12],
                    inst_i[20], inst_i[30:21], 1'b0};
    

    always @(*) begin
        op1_o = 32'b0;
        op2_o = 32'b0;
        gpr_wen = 1'b0;  
        alu_ctrl = 4'b0;
        mem_read = 1'b0;
        mem_write = 1'b0;
        wb_sel = 1'b0;
        imm_o = 32'b0;

        rs1_used_o = 1'b0;
        rs2_used_o = 1'b0;
        case(opcode)
            //I型指令
            `INST_TYPE_I : begin
                op1_o = rs1_data_i;rs1_used_o = 1'b1;
                op2_o = imm_I;
                gpr_wen = 1'b1;
                wb_sel = `WB_ALU;
                case(fun3)
                    `INST_ADDI: alu_ctrl = `ALU_ADD;
                    `INST_SLTI: alu_ctrl = `ALU_SLT;
                    `INST_SLTIU: alu_ctrl = `ALU_SLTU;
                    `INST_XORI: alu_ctrl = `ALU_XOR;
                    `INST_ORI: alu_ctrl = `ALU_OR;
                    `INST_ANDI: alu_ctrl = `ALU_AND;
                    `INST_SLLI: alu_ctrl = `ALU_SLL;
                    `INST_SRI: alu_ctrl = (fun7 == 7'b0)?`ALU_SRL :`ALU_SRA;
                    default:begin
                        op1_o = 32'b0;
                        op2_o = 32'b0;
                        gpr_wen = 1'b0;  
                        alu_ctrl = 4'b0;   
                        wb_sel = 1'b0;     
                        imm_o = 32'b0;  
                        rs1_used_o = 1'b0;
                        rs2_used_o = 1'b0;           
                    end
                endcase
            end

            //R型指令
            `INST_TYPE_R_M:begin
                op1_o = rs1_data_i;rs1_used_o = 1'b1;
                op2_o = rs2_data_i;rs2_used_o = 1'b1;
                gpr_wen = 1'b1;
                wb_sel = `WB_ALU;  
                case (fun3)
                    `INST_ADD_SUB: alu_ctrl = (fun7 == 7'b0)? `ALU_ADD : `ALU_SUB;
                    `INST_SLT: alu_ctrl = `ALU_SLT;
                    `INST_SLTU: alu_ctrl = `ALU_SLTU;
                    `INST_XOR: alu_ctrl = `ALU_XOR;
                    `INST_OR: alu_ctrl = `ALU_OR;
                    `INST_AND: alu_ctrl = `ALU_AND;
                    `INST_SLL: alu_ctrl = `ALU_SLL;
                    `INST_SR: alu_ctrl = (fun7 == 7'b0)?`ALU_SRL :`ALU_SRA;                    
                    default: begin
                        op1_o = 32'b0;
                        op2_o = 32'b0;
                        gpr_wen = 1'b0;  
                        alu_ctrl = 4'b0;   
                        wb_sel = 2'b0;    
                        imm_o = 32'b0;                      
                    end

                endcase
            end

            //分支跳转指令
            `INST_TYPE_B : begin
                //所有的B型指令都是一样的译码输出，不需要case
                //区分放在ex模块，根据fun3的3位做不同选择
                    // `INST_BEQ,`INST_BNE:begin
                    op1_o = rs1_data_i;rs1_used_o = 1'b1;
                    op2_o = rs2_data_i;rs2_used_o = 1'b1;
                    alu_ctrl = `ALU_CMP;     
                    imm_o = imm_B;                     
            end

            //JAL指令
            `INST_JAL:begin
                op1_o = imm_J;
                gpr_wen = 1'b1;  
                alu_ctrl = `ALU_JAL;   
                wb_sel = `WB_ALU;   
            end
            //JALR指令
            `INST_JALR:begin 
                op1_o = rs1_data_i;rs1_used_o = 1'b1;
                op2_o = imm_I;
                gpr_wen = 1'b1;  
                alu_ctrl = `ALU_JALR;   
                wb_sel = `WB_ALU;                    
            end            

            //加载高位立即数指令
            `INST_LUI:begin
                op1_o = imm_U;
                gpr_wen = 1'b1;  
                alu_ctrl = `ALU_LUI;   
                wb_sel = `WB_ALU;                  
            end

            `INST_AUIPC:begin
                op1_o = imm_U;
                gpr_wen = 1'b1;  
                alu_ctrl = `ALU_AUIPC;   
                wb_sel = `WB_ALU;                  
            end

            //存储指令
            `INST_TYPE_S:begin
                op1_o = rs1_data_i;rs1_used_o = 1'b1;
                op2_o = rs2_data_i;rs2_used_o = 1'b1;
                alu_ctrl = `ALU_STR;
                mem_write = 1'b1;
                wb_sel = `WB_MEM;
                imm_o = imm_S;
            end

            //加载指令
            `INST_TYPE_L:begin
                op1_o = rs1_data_i;rs1_used_o = 1'b1;
                op2_o = imm_I;
                alu_ctrl = `ALU_ADD;
                mem_read = 1'b1;
                wb_sel = `WB_MEM;
                gpr_wen = 1'b1;
            end

            default :begin
                op1_o = 32'b0;
                op2_o = 32'b0;
                gpr_wen = 1'b0;  
                alu_ctrl = 4'b0;
                mem_read = 1'b0;
                mem_write = 1'b0;
                wb_sel = 1'b0;
                imm_o = 32'b0;
                rs1_used_o = 1'b0;
                rs2_used_o = 1'b0;
            end
        endcase
    end

endmodule