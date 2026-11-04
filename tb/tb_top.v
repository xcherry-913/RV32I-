
module tb_top();


wire [31:0] gp  = u_riscv_top.u_top.u_gpr.gpr[3];
wire [31:0] s10 = u_riscv_top.u_top.u_gpr.gpr[26];
wire [31:0] s11 = u_riscv_top.u_top.u_gpr.gpr[27];



reg clk = 1,rstn = 0;
reg [31:0] clk_cnt = 0;

always #5 clk = ~clk;

initial begin
    rstn = 0;
    #11
    rstn = 1;
end
riscv_top u_riscv_top(
    .clk  (clk  ),
    .rstn (rstn )
);

//设置ROM上电初始值
initial begin
    $readmemh("./inst_txt/rv32ui-p-jal.txt",u_riscv_top.u_ROM_inst.mem);
end

//测试寄存器数值
initial begin
    
    $timeformat(-9,2,"ns",0);
    $monitor("%0t gp=%0d s10=%0d s11=%0d",
            $time,
            gp,
            s10,
            s11);
    
    // while (1) begin
    //     @(posedge clk); 
    //     clk_cnt = clk_cnt + 1;
    //     $display("%0t,这是第%d个时钟周期",$time,clk_cnt);
    // end   
    wait(s10);
    #20;
    if(s11)begin
        $display("==========================");
        $display("PASS");
        $display("==========================");
    end else begin
        $display("==========================");
        $display("FAIL");
        $display("==========================");        
    end
end

initial begin
    #10000;
    $finish;
end

initial begin
    $fsdbDumpfile("tb_top.fsdb");
    $fsdbDumpvars(0,tb_top);
end
endmodule