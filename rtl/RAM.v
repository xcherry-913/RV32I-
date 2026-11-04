// simple dual port ram
module RAM(
    input clk,
    input rstn,

    input  [4:0] rd_addr_i,
    input  [31:0] rd_wdata_EX_i,
    input  gpr_wen_i,
    input  wb_sel_i,
    input  mem_read_i,   
    input  mem_write_i,
    input  [2:0] fun3_i,
    input  [31:0] mem_wdata,
    input  [31:0] mem_waddr,
    input  [31:0] mem_raddr,


    //to WB(directly)
    output reg [31:0] mem_rdata,

    //to WB(reg)
    output  [4:0] rd_addr_o,
    output  [31:0] rd_wdata_EX_o,
    output  gpr_wen_o,
    output  wb_sel_o
);
    assign rd_addr_o = rd_addr_i;
    assign rd_wdata_EX_o = rd_wdata_EX_i;
    assign gpr_wen_o = gpr_wen_i;
    assign wb_sel_o = wb_sel_i;

    localparam DEPTH = 1024;
    reg [31:0] mem [0:DEPTH-1];

    wire [29:0] waddr = mem_waddr[31:2];
    wire [29:0] raddr = mem_raddr[31:2];
    wire [1:0]  wsel  = mem_waddr[1:0];
    wire [1:0]  rsel  = mem_raddr[1:0];

    // 读侧先取出字节/半字，便于符号扩展
    wire [7:0]  rbyte = mem[raddr][8*rsel  +: 8];
    wire [15:0] rhalf = mem[raddr][16*rsel +: 16];

    integer i;
    always @(posedge clk, negedge rstn) begin
        if (!rstn) begin
            mem_rdata <= 32'b0;
            for (i=0;i<DEPTH;i=i+1)
                mem[i] <= 32'b0;
        end else begin
            if (mem_write_i) begin
                case (fun3_i)
                //依次：SB SH SW
                3'h0: mem[waddr][8*wsel  +: 8]   <= mem_wdata[7:0];    
                3'h1: mem[waddr][16*wsel +: 16] <= mem_wdata[15:0];
                3'h2: mem[waddr] <= mem_wdata;         
                endcase
            end else if (mem_read_i) begin
                case (fun3_i)
                //依次：LB LH LW LBU LHU 
                3'h0: mem_rdata <= {{24{rbyte[7]}},  rbyte};   
                3'h1: mem_rdata <= {{16{rhalf[15]}}, rhalf};        
                3'h2: mem_rdata <= mem[raddr];                        
                3'h4: mem_rdata <= {24'b0, rbyte};                  
                3'h5: mem_rdata <= {16'b0, rhalf};            
                default: mem_rdata <= 32'b0;
                endcase
            end
        end
    end

endmodule