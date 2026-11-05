module hazard_unit(
    //from id
    input [4:0] id_rs1_addr_i,
    input [4:0] id_rs2_addr_i,

    //from id_ex or ex
    input [4:0] ex_rd_addr_i,
    input ex_mem_read_i,
    input rs1_used_i,
    input rs2_used_i,

    //to id_ex 
    output load_use_stall
);
  wire rs1_same_rd ;
  assign rs1_same_rd = (id_rs1_addr_i == ex_rd_addr_i);
  wire rs2_same_rd ;  
  assign rs2_same_rd= (id_rs2_addr_i == ex_rd_addr_i);

  assign load_use_stall = (rs1_used_i || rs2_used_i) && (rs1_same_rd || rs2_same_rd) && (ex_mem_read_i) &&(ex_rd_addr_i !=0);
endmodule