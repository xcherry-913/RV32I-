module top(
    input clk,
    input rstn,

    //to ROM
    output [31:0] rom_addr_o,

    //from ROM
    input  [31:0] rom_inst_i
);

    //load use stall
    wire load_use_stall;

    wire [31:0] pc;

    //IF
    wire [31:0] if_inst;
    wire [31:0] if_inst_addr;

    //IF_ID
    wire [31:0] if_id_inst;
    wire [31:0] if_id_inst_addr;

    //ID
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
    wire        id_wb_sel;
    wire        id_rs1_used;
    wire        id_rs2_used;

    //GPR
    wire [31:0] gpr_rs1_data;
    wire [31:0] gpr_rs2_data;

    //ID_EX
    wire [2:0]  ex_fun3;
    wire [31:0] ex_inst_addr;
    wire [31:0] ex_op1;
    wire [31:0] ex_op2;
    wire [31:0] ex_imm;
    wire [4:0]  ex_rd_addr;
    wire        ex_gpr_wen;
    wire [3:0]  ex_alu_ctrl;
    wire        ex_mem_read;
    wire        ex_mem_write;
    wire        ex_wb_sel;
    wire [4:0]  ex_rs1_addr;
    wire [4:0]  ex_rs2_addr;
    wire        ex_rs1_used;
    wire        ex_rs2_used;

    //EX
    wire [4:0]  ex_rd_addr_o;
    wire [31:0] ex_rd_wdata_o;
    wire        ex_gpr_wen_o;
    wire        ex_wb_sel_o;

    wire [2:0]  ex_fun3_o;
    wire [31:0] ex_mem_wdata_o;
    wire [31:0] ex_mem_waddr_o;
    wire [31:0] ex_mem_raddr_o;
    wire        ex_mem_read_o;
    wire        ex_mem_write_o;

    wire        flush_en;
    wire        jump_en;
    wire [31:0] jump_pc;

    //EX <-> ALU
    wire [3:0]  ex_alu_ctrl_o;
    wire [31:0] ex_alu_op1_o;
    wire [31:0] ex_alu_op2_o;
    wire [31:0] alu_out;

    //EX_RAM
    wire [4:0]  mem_rd_addr;
    wire [31:0] mem_rd_wdata_EX;
    wire        mem_gpr_wen;
    wire        mem_wb_sel;
    wire        mem_read;
    wire        mem_write;
    wire [2:0]  mem_fun3;
    wire [31:0] mem_store_data;
    wire [31:0] mem_write_addr;
    wire [31:0] mem_read_addr;

    //EX_RAM前递
    wire [31:0] EX_RAM_rd_wdata;
    wire [4:0]  EX_RAM_rd_addr;
    wire        EX_RAM_mem_read;
    wire        EX_RAM_gpr_wen;

    //RAM
    wire [31:0] ram_rdata;

    //RAM_WB
    wire [4:0]  wb_rd_addr;
    wire [31:0] wb_rd_wdata_EX;
    wire        wb_gpr_wen;
    wire        wb_sel;

    wire [4:0]  WB_rd_addr;
    wire        WB_gpr_wen;

    //WB
    wire [4:0]  wb_rd_addr_final;
    wire [31:0] wb_rd_wdata_final;
    wire        wb_gpr_wen_final;
    wire [31:0] WB_wdata;

    //=======================================
    //第一级流水：IF
    //=======================================
    pc_reg u_pc_reg (
        .clk       (clk),
        .rstn      (rstn),
        .jump_en_i (jump_en),
        .jump_pc_i (jump_pc),
        .load_use_stall_i(load_use_stall),
        .pc_o      (pc)
    );

    ifetch u_ifetch (
        .pc_i        (pc),
        .rom_inst_i  (rom_inst_i),
        .rom_addr_o  (rom_addr_o),
        .inst_addr_o (if_inst_addr),
        .inst_o      (if_inst)
    );

    if_id u_if_id (
        .clk         (clk),
        .rstn        (rstn),
        .flush_en_i  (flush_en),
        .load_use_stall_i(load_use_stall),

        .inst_i      (if_inst),
        .inst_addr_i (if_inst_addr),
        .inst_o      (if_id_inst),
        .inst_addr_o (if_id_inst_addr)
    );

    //=======================================
    //第二级流水：ID + GPR
    //=======================================
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
        .imm_o       (id_imm),

        .rs1_used_o  (id_rs1_used),
        .rs2_used_o  (id_rs2_used)
    );

    gpr u_gpr (
        .clk        (clk),
        .rstn       (rstn),

        .rs1_addr_i (id_rs1_addr),
        .rs2_addr_i (id_rs2_addr),
        .rs1_data_o (gpr_rs1_data),
        .rs2_data_o (gpr_rs2_data),

        .rd_addr_i  (wb_rd_addr_final),
        .rd_wdata_i (wb_rd_wdata_final),
        .wen        (wb_gpr_wen_final)
    );
    hazard_unit u_hazard_unit(
        .id_rs1_addr_i  (id_rs1_addr  ),
        .id_rs2_addr_i  (id_rs2_addr  ),
        .ex_rd_addr_i   (ex_rd_addr   ),
        .ex_mem_read_i  (ex_mem_read  ),
        .rs1_used_i     (ex_rs1_used     ),
        .rs2_used_i     (ex_rs2_used     ),
        .load_use_stall (load_use_stall )
    );
    
    id_ex u_id_ex (
        .clk         (clk),
        .rstn        (rstn),
        .flush_en_i  (flush_en),
        .load_use_stall_i(load_use_stall),

        .fun3_i      (id_fun3),
        .inst_addr_i (id_inst_addr),
        .op1_i       (id_op1),
        .op2_i       (id_op2),
        .rd_addr_i   (id_rd_addr),
        .gpr_wen_i   (id_gpr_wen),
        .alu_ctrl_i  (id_alu_ctrl),
        .mem_read_i  (id_mem_read),
        .mem_write_i (id_mem_write),
        .wb_sel_i    (id_wb_sel),
        .imm_i       (id_imm),

        //补充：用于数据前递
        .rs1_addr_i  (id_rs1_addr),
        .rs2_addr_i  (id_rs2_addr),
        .rs1_used_i  (id_rs1_used),
        .rs2_used_i  (id_rs2_used),

        .fun3_o      (ex_fun3),
        .inst_addr_o (ex_inst_addr),
        .op1_o       (ex_op1),
        .op2_o       (ex_op2),
        .rd_addr_o   (ex_rd_addr),
        .gpr_wen_o   (ex_gpr_wen),
        .alu_ctrl_o  (ex_alu_ctrl),
        .mem_read_o  (ex_mem_read),
        .mem_write_o (ex_mem_write),
        .wb_sel_o    (ex_wb_sel),
        .imm_o       (ex_imm),

        .rs1_addr_o  (ex_rs1_addr),
        .rs2_addr_o  (ex_rs2_addr),
        .rs1_used_o  (ex_rs1_used),
        .rs2_used_o  (ex_rs2_used)
    );

    //=======================================
    //第三级流水：EX + ALU
    //=======================================
    ex u_ex (
        .fun3_i      (ex_fun3),
        .inst_addr_i (ex_inst_addr),
        .op1_i       (ex_op1),
        .op2_i       (ex_op2),
        .imm_i       (ex_imm),
        .rd_addr_i   (ex_rd_addr),
        .gpr_wen_i   (ex_gpr_wen),
        .alu_ctrl_i  (ex_alu_ctrl),
        .mem_read_i  (ex_mem_read),
        .mem_write_i (ex_mem_write),
        .wb_sel_i    (ex_wb_sel),

        .rs1_used_i  (ex_rs1_used),
        .rs2_used_i  (ex_rs2_used),
        .rs1_addr_i  (ex_rs1_addr),
        .rs2_addr_i  (ex_rs2_addr),

        //数据前递：来自 EX_RAM、RAM_WB和WB
        .EX_RAM_rd_wdata (EX_RAM_rd_wdata),
        .EX_RAM_rd_addr  (EX_RAM_rd_addr),
        .EX_RAM_mem_read (EX_RAM_mem_read),
        .EX_RAM_gpr_wen  (EX_RAM_gpr_wen),

        .WB_rd_addr      (WB_rd_addr),
        .WB_gpr_wen      (WB_gpr_wen),

        .WB_wdata        (WB_wdata),

        .alu_ctrl_o  (ex_alu_ctrl_o),
        .alu_op1_o   (ex_alu_op1_o),
        .alu_op2_o   (ex_alu_op2_o),
        .alu_out_i   (alu_out),

        .jump_pc_o   (jump_pc),
        .jump_en_o   (jump_en),
        .flush_en_o  (flush_en),

        .rd_addr_o   (ex_rd_addr_o),
        .rd_wdata_o  (ex_rd_wdata_o),
        .gpr_wen_o   (ex_gpr_wen_o),
        .wb_sel_o    (ex_wb_sel_o),

        .mem_read_o  (ex_mem_read_o),
        .mem_write_o (ex_mem_write_o),
        .fun3_o      (ex_fun3_o),
        .mem_wdata_o (ex_mem_wdata_o),
        .mem_waddr_o (ex_mem_waddr_o),
        .mem_raddr_o (ex_mem_raddr_o)
    );

    ALU u_alu (
        .alu_ctrl_i (ex_alu_ctrl_o),
        .op1_i      (ex_alu_op1_o),
        .op2_i      (ex_alu_op2_o),
        .alu_out_o  (alu_out)
    );


    ex_ram u_ex_ram (
        .clk          (clk),
        .rstn         (rstn),

        .rd_addr_i    (ex_rd_addr_o),
        .rd_wdata_EX_i(ex_rd_wdata_o),
        .gpr_wen_i    (ex_gpr_wen_o),
        .wb_sel_i     (ex_wb_sel_o),

        .mem_read_i   (ex_mem_read_o),
        .mem_write_i  (ex_mem_write_o),
        .fun3_i       (ex_fun3_o),
        .mem_wdata_i  (ex_mem_wdata_o),
        .mem_waddr_i  (ex_mem_waddr_o),
        .mem_raddr_i  (ex_mem_raddr_o),

        .rd_addr_o    (mem_rd_addr),
        .rd_wdata_EX_o(mem_rd_wdata_EX),
        .gpr_wen_o    (mem_gpr_wen),
        .wb_sel_o     (mem_wb_sel),

        .mem_read_o   (mem_read),
        .mem_write_o  (mem_write),
        .fun3_o       (mem_fun3),
        .mem_wdata_o  (mem_store_data),
        .mem_waddr_o  (mem_write_addr),
        .mem_raddr_o  (mem_read_addr),

        //前递给EX
        .EX_RAM_rd_wdata (EX_RAM_rd_wdata),
        .EX_RAM_rd_addr  (EX_RAM_rd_addr),
        .EX_RAM_mem_read (EX_RAM_mem_read),
        .EX_RAM_gpr_wen  (EX_RAM_gpr_wen)
    );

    RAM u_ram (
        .clk           (clk),
        .rstn          (rstn),

        .rd_addr_i     (mem_rd_addr),
        .rd_wdata_EX_i (mem_rd_wdata_EX),
        .gpr_wen_i     (mem_gpr_wen),
        .wb_sel_i      (mem_wb_sel),

        .mem_read_i    (mem_read),
        .mem_write_i   (mem_write),
        .fun3_i        (mem_fun3),
        .mem_wdata     (mem_store_data),
        .mem_waddr     (mem_write_addr),
        .mem_raddr     (mem_read_addr),

        .mem_rdata     (ram_rdata)
    );

    //=======================================
    //第四级流水：RAM_WB
    //=======================================
    ram_wb u_ram_wb (
        .clk          (clk),
        .rstn         (rstn),

        .rd_addr_i    (mem_rd_addr),
        .rd_wdata_EX_i(mem_rd_wdata_EX),
        .gpr_wen_i    (mem_gpr_wen),
        .wb_sel_i     (mem_wb_sel),

        .rd_addr_o    (wb_rd_addr),
        .rd_wdata_EX_o(wb_rd_wdata_EX),
        .gpr_wen_o    (wb_gpr_wen),
        .wb_sel_o     (wb_sel),

        //前递给EX
        .WB_rd_addr   (WB_rd_addr),
        .WB_gpr_wen   (WB_gpr_wen)
    );

    //=======================================
    //第五级流水：WB+GPR写
    //=======================================
    wb u_wb (
        .rd_addr_i      (wb_rd_addr),
        .rd_wdata_EX_i  (wb_rd_wdata_EX),
        .gpr_wen_i      (wb_gpr_wen),
        .wb_sel_i       (wb_sel),
        .mem_rdata      (ram_rdata),

        .gpr_wen_o      (wb_gpr_wen_final),
        .rd_wdata_o     (wb_rd_wdata_final),
        .rd_addr_o      (wb_rd_addr_final),

        //前递给EX
        .WB_wdata       (WB_wdata)
    );

endmodule
