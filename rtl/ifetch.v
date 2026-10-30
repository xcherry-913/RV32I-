//取值模块
module ifetch(
    //from PC_REG
    input  [31:0] pc_i,

    //from ROM
    input [31:0] rom_inst_i,

    //to ROM
    output [31:0] rom_addr_o,

    //to if_id
    output [31:0] inst_addr_o,
    output [31:0] inst_o
);
    assign rom_addr_o = (pc_i>>2);//地址对齐
    assign inst_addr_o = pc_i;
    assign inst_o = rom_inst_i;

endmodule