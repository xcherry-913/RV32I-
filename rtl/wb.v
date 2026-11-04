`include "defines.v"
module wb(
    //from ram_wb
    input  [4:0] rd_addr_i,
    input  [31:0] rd_wdata_EX_i,
    input  gpr_wen_i,
    input  wb_sel_i,

    //from RAM
    input [31:0] mem_rdata,

    //to GPR
    output gpr_wen_o,
    output [31:0] rd_wdata_o,
    output [4:0] rd_addr_o,

    //to ex(forward)
    output [31:0] WB_wdata

);
    assign gpr_wen_o = gpr_wen_i;
    assign rd_addr_o = rd_addr_i;
    assign rd_wdata_o = (wb_sel_i == `WB_ALU) ? rd_wdata_EX_i : mem_rdata;
    assign WB_wdata = rd_wdata_o;
endmodule