//流水线与ROM连接
module riscv_top(
    input clk,
    input rstn,

    //for  综合 
    output debug_gpr_wen,
    output [31:0] debug_rd_wdata,
    output [4:0] debug_rd_addr
);
    wire [31:0] rom_addr;
    wire [31:0] rom_inst;

ROM_inst u_ROM_inst(
    .rom_addr_i (rom_addr ),
    .rom_inst_o (rom_inst )
);

top u_top(
    .clk              (clk              ),
    .rstn             (rstn             ),
    .rom_addr_o       (rom_addr       ),
    .rom_inst_i       (rom_inst       ),
    .debug_gpr_wen_o  (debug_gpr_wen  ),
    .debug_rd_wdata_o (debug_rd_wdata ),
    .debug_rd_addr_o  (debug_rd_addr  )
);


endmodule