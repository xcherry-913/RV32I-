module ram_wb(
    input clk,
    input rstn,

    input  [4:0] rd_addr_i,
    input  [31:0] rd_wdata_EX_i,
    input  gpr_wen_i,
    input  wb_sel_i,

    output  reg [4:0] rd_addr_o,
    output  reg [31:0] rd_wdata_EX_o,
    output  reg gpr_wen_o,
    output  reg wb_sel_o,

    //to EX(forwarding)
    output reg [4:0] WB_rd_addr,
    output reg WB_gpr_wen
);
    always @(posedge clk ,negedge rstn) begin
        if(!rstn) begin
            rd_addr_o <= 5'b0;
            rd_wdata_EX_o<= 32'b0;
            gpr_wen_o <= 1'b0;
            wb_sel_o  <= 1'b0;
            WB_gpr_wen <= 1'b0;
            WB_rd_addr <= 5'b0;
        end else begin
            rd_addr_o <= rd_addr_i;
            rd_wdata_EX_o<= rd_wdata_EX_i;
            gpr_wen_o <= gpr_wen_i;
            wb_sel_o  <= wb_sel_i;

            WB_gpr_wen <= gpr_wen_i;
            WB_rd_addr <= rd_addr_i;
        end
    end
    
endmodule