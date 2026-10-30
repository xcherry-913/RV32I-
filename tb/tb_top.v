
module tb_top();
reg clk = 1,rstn = 0;
reg [31:0] clk_cnt = 0;
initial begin
    forever #5 clk = ~clk;
end

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
    $readmemh("/mnt/d/UESTC/Graduate1/RISCV/risc_v_project/phase1/tb/rom.txt",u_riscv_top.u_ROM_inst.mem);
end

//测试寄存器数值
initial begin
    
    $timeformat(-9,2,"ns",0);
    $monitor("%0t pc_reg =%0h x27=%0d x28=%0d x29=%0d",
            $time,
            u_riscv_top.u_top.u_pc_reg.pc_o,
            u_riscv_top.u_top.u_gpr.gpr[27],
            u_riscv_top.u_top.u_gpr.gpr[28],
            u_riscv_top.u_top.u_gpr.gpr[29]);
    
    // while (1) begin
    //     @(posedge clk); 
    //     clk_cnt = clk_cnt + 1;
    //     $display("%0t,这是第%d个时钟周期",$time,clk_cnt);
    // end   
end

initial begin
    #100;
    $finish;
end

initial begin
    $fsdbDumpfile("tb_top.fsdb");
    $fsdbDumpvars(0,tb_top);
end
endmodule