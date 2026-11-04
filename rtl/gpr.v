module gpr(
    input clk,
    input rstn,

    //form inst_decoder
    input [4:0] rs1_addr_i,
    input [4:0] rs2_addr_i,

    //to inst_decoder
    output [31:0] rs1_data_o,
    output [31:0] rs2_data_o,

    //from wb
    input [4:0] rd_addr_i,
    input [31:0] rd_wdata_i,
    input wen
);
    reg [31:0] gpr [0:31];
    //gpr读取数据
    assign rs1_data_o = (rs1_addr_i == 5'b0) ? 32'b0 : (
                                            //添加数据旁路，解决写后读的数据冒险
                                            //具体原理为，指令1写且指令2读的时候，直接把要写的数据给rs1或rs2，避免它们读出旧数据
                                             ((rs1_addr_i == rd_addr_i) && wen) ? rd_wdata_i : gpr[rs1_addr_i]
                                             );
    assign rs2_data_o = (rs2_addr_i == 5'b0) ? 32'b0 : (
                                             ((rs2_addr_i == rd_addr_i) && wen) ? rd_wdata_i : gpr[rs2_addr_i]
                                            );

    //gpr写入数据

    integer i;
    always @(posedge clk,negedge rstn) begin
        if(!rstn) begin
            for(i=0;i<=31;i=i+1)begin
                gpr[i] <= 32'b0;
            end
        end else begin
            if(rd_addr_i != 5'b0 && wen)
                 gpr[rd_addr_i] <= rd_wdata_i;
        end
    end
endmodule