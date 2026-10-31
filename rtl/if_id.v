`include "defines.v"

module if_id(
    input clk,
    input rstn,
    input [31:0] inst_i,
    input [31:0] inst_addr_i,
    input flush_en_i,

    output reg [31:0] inst_o,
    output reg [31:0] inst_addr_o
);
    always @(posedge clk ,negedge rstn) begin
        if(!rstn || flush_en_i) begin
            inst_o <= `INST_NOP;
            inst_addr_o <= 32'b0;
        end else begin
            inst_addr_o <= inst_addr_i;
            inst_o <= inst_i;
        end
    end
endmodule