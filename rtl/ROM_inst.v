module ROM_inst(
    //from riscv_top
    input [31:0] rom_addr_i,

    //to riscv_top
    output [31:0] rom_inst_o
);
    reg [31:0] mem [0:1023];

    assign rom_inst_o = mem[rom_addr_i];
endmodule