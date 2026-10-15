module my_dut(pclk_i, rst_n_i, psel_i, penable_i, paddr_i, valid_i, addr_i, irq_o);

  input pclk_i;
  input rst_n_i;
  input [2:0] paddr_i;
  input psel_i;
  input penable_i;
  input valid_i;
  input [2:0] addr_i;
  output irq_o;

assign irq_o = (psel_i && penable_i && valid_i && (paddr_i == addr_i)) ? 1'b1 : 1'b0;

endmodule