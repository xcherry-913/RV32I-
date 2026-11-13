//分离RAM存储和访存逻辑
module RAM(
    input clk,
    input rstn,
    input mem_read_i,
    input mem_write_i,
    input [2:0] fun3_i,
    input [31:0] mem_wdata,
    input [31:0] mem_waddr,
    input [31:0] mem_raddr,
    output reg [31:0] mem_rdata
);
    reg [31:0] mem [0:4095];
    wire [29:0] waddr = mem_waddr[31:2];
    wire [29:0] raddr = mem_raddr[31:2];
    reg  [3:0]  wstrb;
    reg [31:0]  wdata;

    //写存储选择逻辑
    always @(*) begin
        wstrb = 4'b0000;
        wdata = mem_wdata;
        if (rstn && mem_write_i) begin
            case (fun3_i)
                3'h0: begin//sb
                    wstrb = 4'b0001 << mem_waddr[1:0];//开启一个使能
                    wdata = {4{mem_wdata[7:0]}};
                end        
                3'h1: begin//sh
                    wstrb = mem_waddr[1] ? 4'b1100 : 4'b0011;//开启两个使能
                    wdata = {2{mem_wdata[15:0]}};
                end        //sw
                3'h2: wstrb = 4'b1111;
                default: wstrb = 4'b0000;
            endcase
        end
    end

    //RAM写逻辑
    always @(posedge clk) begin
        if (wstrb[0]) mem[waddr[11:0]][7:0]   <= wdata[7:0];
        if (wstrb[1]) mem[waddr[11:0]][15:8]  <= wdata[15:8];
        if (wstrb[2]) mem[waddr[11:0]][23:16] <= wdata[23:16];
        if (wstrb[3]) mem[waddr[11:0]][31:24] <= wdata[31:24];
    end

    //RAM读逻辑
    wire read_enable = rstn && !mem_write_i && mem_read_i;
    reg [31:0] read_data;
    always @(posedge clk) begin
        if (read_enable)
            read_data <= mem[raddr[11:0]];
    end

    //读存储选择逻辑
    reg ren;
    reg [2:0] fun3;
    reg [1:0] rsel;
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            ren <= 1'b0;
            fun3 <= 3'b0;
            rsel <= 2'b0;
        end else if (read_enable) begin
            ren <= 1'b1;
            fun3 <= fun3_i;
            rsel <= mem_raddr[1:0];
        end
    end

    wire [7:0]  rbyte = read_data[8*rsel +: 8];
    wire [15:0] rhalf = read_data[16*rsel[1] +: 16];
    always @(*) begin
        mem_rdata = 32'b0;
        if (ren) begin
            case (fun3)
                3'h0: mem_rdata = {{24{rbyte[7]}}, rbyte};
                3'h1: mem_rdata = {{16{rhalf[15]}}, rhalf};
                3'h2: mem_rdata = read_data;
                3'h4: mem_rdata = {24'b0, rbyte};
                3'h5: mem_rdata = {16'b0, rhalf};
                default: mem_rdata = 32'b0;
            endcase
        end
    end
endmodule
