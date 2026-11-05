module ex_ram(
    input clk,
    input rstn,

    input  [4:0] rd_addr_i,
    input  [31:0] rd_wdata_EX_i,
    input  gpr_wen_i,
    input  wb_sel_i,
    input  mem_read_i,   
    input  mem_write_i,
    input  [2:0] fun3_i,
    input  [31:0] mem_wdata_i,
    input  [31:0] mem_waddr_i,
    input  [31:0] mem_raddr_i,

    //to ram_wb
    output  reg [4:0] rd_addr_o,
    output  reg [31:0] rd_wdata_EX_o,
    output  reg gpr_wen_o,
    output  reg wb_sel_o,

    //to RAM
    output  reg mem_read_o,   
    output  reg mem_write_o,
    output  reg [2:0] fun3_o,
    output  reg [31:0] mem_wdata_o,
    output  reg [31:0] mem_waddr_o,
    output  reg [31:0] mem_raddr_o,

    //to ex(forwarding)
    output reg [31:0] EX_RAM_rd_wdata,
    output reg [4:0] EX_RAM_rd_addr,
    output reg EX_RAM_mem_read,
    output reg EX_RAM_gpr_wen
);
    always @(posedge clk ,negedge rstn) begin
        if(!rstn) begin
            rd_addr_o <= 5'b0;
            rd_wdata_EX_o<= 32'b0;
            gpr_wen_o <= 1'b0;
            wb_sel_o  <= 1'b0;
            mem_read_o <= 1'b0;  
            mem_write_o<= 1'b0;
            fun3_o     <= 3'b0;
            mem_wdata_o<= 32'b0;
            mem_waddr_o<= 32'b0;
            mem_raddr_o<= 32'b0;

            EX_RAM_rd_wdata <= 32'b0;
            EX_RAM_rd_addr <= 5'b0;
            EX_RAM_gpr_wen <= 1'b0;
            EX_RAM_mem_read<= 1'b0;
        end else begin
            rd_addr_o <= rd_addr_i;
            rd_wdata_EX_o<= rd_wdata_EX_i;
            gpr_wen_o <= gpr_wen_i;
            wb_sel_o  <= wb_sel_i;

            mem_read_o <= mem_read_i;  
            mem_write_o<= mem_write_i;
            fun3_o     <= fun3_i;
            mem_wdata_o<= mem_wdata_i;
            mem_waddr_o<= mem_waddr_i;
            mem_raddr_o<= mem_raddr_i;

            EX_RAM_rd_wdata <= rd_wdata_EX_i;
            EX_RAM_rd_addr <= rd_addr_i;
            EX_RAM_gpr_wen <= gpr_wen_i;
            EX_RAM_mem_read<= mem_read_i;
        end
    end
endmodule