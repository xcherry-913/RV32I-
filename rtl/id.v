`include "defines.v"

module id(
    //from if_id
    input [31:0] inst_addr_i,
    input [31:0] inst_i,

    //to gpr
    output  [4:0] rs1_addr_o,
    output  [4:0] rs2_addr_o,

    //from gpr
    input [31:0] rs1_data_i,
    input [31:0] rs2_data_i,

    //to id_ex
    output [31:0] inst_o,
    output [31:0] inst_addr_o,
    output reg [31:0] op1_o,
    output reg [31:0] op2_o,
    output [4:0] rd_addr_o,
    output reg  gpr_wen,
    output reg [3:0] alu_ctrl,
    output reg  mem_read,   
    output reg  mem_write,
    output reg  [1:0] wb_sel
);
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
    assign fun3   = inst_i[14:12];
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
        case(opcode)
            `INST_TYPE_I : begin
                case(fun3)
                    `INST_ADDI:begin
                        op1_o = rs1_data_i;
                        op2_o = imm_I;
                        gpr_wen = 1'b1;
                        alu_ctrl = `ALU_ADD;
                        wb_sel = `WB_ALU;
                    end

                    default:begin
                        op1_o = 32'b0;
                        op2_o = 32'b0;
                        gpr_wen = 1'b0;  
                        alu_ctrl = 4'b0;   
                        wb_sel = 2'b0;                  
                    end
                endcase
            end

            `INST_TYPE_R_M:begin
                case (fun3)
                    `INST_ADD_SUB: begin
                        op1_o = rs1_data_i;
                        op2_o = rs2_data_i;
                        gpr_wen = 1'b1;
                        alu_ctrl = (fun7 == 7'b0)? `ALU_ADD : `ALU_SUB;
                        wb_sel = `WB_ALU;            
                    end
                    default: begin
                        op1_o = 32'b0;
                        op2_o = 32'b0;
                        gpr_wen = 1'b0;  
                        alu_ctrl = 4'b0;   
                        wb_sel = 2'b0;                          
                    end

                endcase
            end


            default :begin
                        op1_o = 32'b0;
                        op2_o = 32'b0;
                        gpr_wen = 1'b0;  
                        alu_ctrl = 4'b0;
                        mem_read = 1'b0;
                        mem_write = 1'b0;
                        wb_sel = 2'b0;
            end
        endcase
    end

    assign inst_o = inst_i;
    assign inst_addr_o = inst_addr_i;


endmodule