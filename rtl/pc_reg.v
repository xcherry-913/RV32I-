module pc_reg(
    input clk,
    input rstn,
    output reg [31:0] pc_o
);
    always @(posedge clk,negedge rstn) begin
        if(!rstn) pc_o <= 32'b0;
        else pc_o <= pc_o + 4;
    end    
endmodule