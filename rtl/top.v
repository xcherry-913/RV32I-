//流水线顶层，未与ROM连接
`include "defines.v"
module top(
    input clk,
    input rstn,

    //to ROM
    output [31:0] rom_addr_o,

    //from ROM
    input  [31:0] rom_inst_i
);


    wire [31:0] pc;


    //取指
    wire [31:0] if_inst;
    wire [31:0] if_inst_addr;

    //IF_ID 流水线寄存器
    wire [31:0] if_id_inst;
    wire [31:0] if_id_inst_addr;

    //译码
    wire [4:0]  id_rs1_addr;
    wire [4:0]  id_rs2_addr;
    wire [2:0]  id_fun3;
    wire [31:0] id_inst_addr;
    wire [31:0] id_op1;
    wire [31:0] id_op2;
    wire [31:0] id_imm;
    wire [4:0]  id_rd_addr;
    wire        id_gpr_wen;
    wire [3:0]  id_alu_ctrl;
    wire        id_mem_read;
    wire        id_mem_write;
    wire [1:0]  id_wb_sel;

    //GPR 输出
    wire [31:0] gpr_rs1_data;
    wire [31:0] gpr_rs2_data;

    //ID_EX 流水线寄存器输出
    wire [2:0]  ex_fun3;
    wire [31:0] ex_inst_addr;
    wire [31:0] ex_op1;
    wire [31:0] ex_op2;
    wire [31:0] ex_imm;
    wire [4:0]  ex_rd_addr;
    wire        ex_gpr_wen;
    wire [3:0]  ex_alu_ctrl;
    wire        ex_mem_read;   // 当前 ex 模块未使用，先留着
    wire        ex_mem_write;  // 当前 ex 模块未使用，先留着
    wire [1:0]  ex_wb_sel;     // 当前 ex 模块未使用，先留着


    //EX输出
    wire [4:0]  wb_rd_addr;
    wire [31:0] wb_rd_wdata;
    wire        wb_gpr_wen;
    wire        flush_en;
    wire        jump_en;
    wire [31:0] jump_pc;

    //=======================================
    //第一级流水：pc+ifetch
    //=======================================

    pc_reg u_pc_reg (
        .clk  (clk),
        .rstn (rstn),
        .jump_en_i(jump_en),
        .jump_pc_i(jump_pc),
        .pc_o (pc)
    );

    ifetch u_ifetch (
        .pc_i        (pc),
        .rom_inst_i  (rom_inst_i),
        .rom_addr_o  (rom_addr_o),
        .inst_addr_o (if_inst_addr),
        .inst_o      (if_inst)
    );

    // ---- IF_ID ----
    if_id u_if_id (
        .clk         (clk),
        .rstn        (rstn),
        .flush_en_i  (flush_en),
        .inst_i      (if_inst),
        .inst_addr_i (if_inst_addr),
        .inst_o      (if_id_inst),
        .inst_addr_o (if_id_inst_addr)
    );

    //=======================================
    //第二级流水：id译码+gpr读
    //=======================================

    // ---- 译码 ----
    id u_id (
        .inst_addr_i (if_id_inst_addr),
        .inst_i      (if_id_inst),
        .rs1_addr_o  (id_rs1_addr),
        .rs2_addr_o  (id_rs2_addr),
        .rs1_data_i  (gpr_rs1_data),
        .rs2_data_i  (gpr_rs2_data),
        .fun3_o      (id_fun3),
        .inst_addr_o (id_inst_addr),
        .op1_o       (id_op1),
        .op2_o       (id_op2),
        .rd_addr_o   (id_rd_addr),
        .gpr_wen     (id_gpr_wen),
        .alu_ctrl    (id_alu_ctrl),
        .mem_read    (id_mem_read),
        .mem_write   (id_mem_write),
        .wb_sel      (id_wb_sel),
        .imm_o       (id_imm)
    );

    // ---- 通用寄存器堆 ----
    gpr u_gpr (
        .clk         (clk),
        .rstn        (rstn),
        .rs1_addr_i  (id_rs1_addr),
        .rs2_addr_i  (id_rs2_addr),
        .rs1_data_o  (gpr_rs1_data),
        .rs2_data_o  (gpr_rs2_data),
        .rd_addr_i   (wb_rd_addr),
        .rd_wdata_i  (wb_rd_wdata),
        .wen         (wb_gpr_wen)
    );

    // ---- ID/EX ----
    id_ex u_id_ex (
        .clk         (clk),
        .rstn        (rstn),
        .flush_en_i  (flush_en),
        .fun3_i      (id_fun3),
        .inst_addr_i (id_inst_addr),
        .op1_i       (id_op1),
        .op2_i       (id_op2),
        .imm_i       (id_imm),
        .rd_addr_i   (id_rd_addr),
        .gpr_wen_i   (id_gpr_wen),
        .alu_ctrl_i  (id_alu_ctrl),
        .mem_read_i  (id_mem_read),
        .mem_write_i (id_mem_write),
        .wb_sel_i    (id_wb_sel),
        .fun3_o      (ex_fun3),
        .inst_addr_o (ex_inst_addr),
        .op1_o       (ex_op1),
        .op2_o       (ex_op2),
        .imm_o       (ex_imm),
        .rd_addr_o   (ex_rd_addr),
        .gpr_wen_o   (ex_gpr_wen),
        .alu_ctrl_o  (ex_alu_ctrl),
        .mem_read_o  (ex_mem_read),
        .mem_write_o (ex_mem_write),
        .wb_sel_o    (ex_wb_sel)
    );

    //=======================================
    //第三级流水：执行+写回gpr
    //=======================================

    // ---- 执行 ----
    ex u_ex (
        .fun3_i      (ex_fun3),
        .inst_addr_i (ex_inst_addr),
        .op1_i       (ex_op1),
        .op2_i       (ex_op2),
        .imm_i       (ex_imm),
        .rd_addr_i   (ex_rd_addr),
        .gpr_wen_i   (ex_gpr_wen),
        .alu_ctrl_i  (ex_alu_ctrl),
        .rd_addr_o   (wb_rd_addr),
        .rd_wdata_o  (wb_rd_wdata),
        .gpr_wen_o   (wb_gpr_wen),
        .jump_pc_o   (jump_pc),
        .jump_en_o   (jump_en),
        .flush_en_o  (flush_en)

    );

endmodule