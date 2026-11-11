// simple dual port ram
// 基地址：0x1000
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


    //to WB
    output reg [31:0] mem_rdata

);
    reg  [31:0] mem [0:511];
    wire [31:0]ram_base_addr = 32'h1000;

    wire [8:0] waddr = (mem_waddr-ram_base_addr)>>2;
    wire [8:0] raddr = (mem_raddr-ram_base_addr)>>2;
    wire [1:0] wsel  = mem_waddr[1:0];
    wire [1:0] rsel  = mem_raddr[1:0];

    wire [7:0]  rbyte = mem[raddr][8*rsel  +: 8];
    wire [15:0] rhalf = mem[raddr][16*rsel[1] +: 16];

    //integer i;
    always @(posedge clk, negedge rstn) begin
        if (!rstn) begin
            mem_rdata <= 32'b0;
            //for (i=0;i<512;i=i+1)
                //mem[i] <= 32'b0;
        end else begin
            if (mem_write_i) begin
                case (fun3_i)
                //依次：SB SH SW
                3'h0: mem[waddr][8*wsel  +: 8]   <= mem_wdata[7:0];    
                3'h1: mem[waddr][16*wsel[1] +: 16] <= mem_wdata[15:0];//2字节对齐
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