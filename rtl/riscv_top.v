//流水线与ROM连接
module riscv_top(
    input clk,
    input rstn
);


wire [31:0] rom_addr_o;
wire [31:0] rom_inst_i;
top u_top(
    .clk        (clk        ),
    .rstn       (rstn       ),
    .rom_addr_o (rom_addr_o ),
    .rom_inst_i (rom_inst_i )
);

ROM_inst u_ROM_inst(
    .rom_addr_i (rom_addr_o ),
    .rom_inst_o (rom_inst_i )
);
    
endmodule