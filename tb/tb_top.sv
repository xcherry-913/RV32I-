
module tb_top();

wire [31:0] gp  = u_riscv_top.u_top.u_gpr.gpr[3];
wire [31:0] s10 = u_riscv_top.u_top.u_gpr.gpr[26];
wire [31:0] s11 = u_riscv_top.u_top.u_gpr.gpr[27];



logic clk = 1,rstn = 0;
logic [31:0] clk_cnt = 0;

always #5 clk = ~clk;

riscv_top u_riscv_top(
    .clk  (clk  ),
    .rstn (rstn )
);

//设置ROM和RAM的上电初始�??
string rom_file;

initial begin
    rstn = 0;

    if (!$value$plusargs("TEST=%s", rom_file))
        $fatal();

    $display("=============================================");    
    $display("TEST=%s", rom_file);
    $display("=============================================");

    $readmemh(rom_file, u_riscv_top.u_ROM_inst.mem);

    $readmemh(rom_file, u_riscv_top.u_top.u_ram.mem);
    
    repeat(2) @(posedge clk);
    
    @(negedge clk);rstn = 1;
    
end
//测试寄存器数�?
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
    //     $display("%0t,这是�?%d个时钟周�?",$time,clk_cnt);
    // end   
    wait(s10);
    #20;
    if(s11)begin
        $display("==========================");
        $display("PASS");
        $display("==========================");
        $finish;
    end else begin
        $display("==========================");
        $display("FAIL");
        $display("==========================");    
        $fatal();    
    end
end

initial begin
    #10000;
    $fatal(1, "FAIL:TIMEOUT");
end

string WAVE;
initial begin
    if(!$value$plusargs("WAVE=%s",WAVE)) WAVE = "tb_top.fsdb";
    $fsdbDumpfile(WAVE);
    $fsdbDumpvars(0,tb_top);
end
endmodule