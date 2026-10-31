module pc_reg(
    input clk,
    input rstn,
    input jump_en_i,
    input [31:0] jump_pc_i,
    output reg [31:0] pc_o
);
    always @(posedge clk,negedge rstn) begin
        if(!rstn) pc_o <= 32'b0;
        else if(jump_en_i) pc_o <= jump_pc_i;
        else pc_o <= pc_o + 4;
    end    
endmodule