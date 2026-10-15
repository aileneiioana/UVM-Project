`include "uvm_macros.svh"
import uvm_pkg::*;

`define CLOCK_PERIOD 10


//`define DEBUG      //macro used to enable messages that we consider necessary only for debugging

//set the meaning of the simulator time units
`timescale 1ns/1ns

//include the files the top module needs access to

`include "apb_interface_dut.sv"
`include "rename_interface_dut.sv"
`include "test_example.sv"
`include "design.sv"

// Code your testbench here

module top();
   logic        clk;
   wire         rst_n;
   wire  [2:0]  paddr;
   wire         psel;
   wire         penable;
   wire         valid;
   wire  [2:0]  addr;
   wire         irq;
  //create the interface instances (one per agent); the interface signals are connected to the signals of the top module
  apb_interface_dut intf_apb();
  assign intf_apb.pclk = clk;
  assign rst_n         = intf_apb.rst_n;
  assign psel          = intf_apb.psel;
  assign penable       = intf_apb.penable;
  assign paddr         = intf_apb.paddr;
  
  rename_interface_dut intf_rename();
  assign intf_rename.clk = clk;
  assign valid = intf_rename.valid;
  assign addr  = intf_rename.addr;
  assign intf_rename.irq   = irq;
  
  initial begin
    //the 2 lines below enable waveform viewing (to view waveforms, the "Open EPWave after run" option in the "Tools & Simulators" section on the left of the page must also be checked)
    $dumpfile("dump.vcd");
    $dumpvars;
    //generate the clock
	clk = 1;
	forever begin 
    #(`CLOCK_PERIOD/2)  
    clk <= ~clk;
  end
	end
  
   initial
  	begin
      //store the interface instances in the UVM database
      uvm_config_db#(virtual apb_interface_dut)::set(null, "*", "apb_interface_dut", intf_apb);
      uvm_config_db#(virtual rename_interface_dut)::set(null, "*", "rename_interface_dut", intf_rename);
      //run the desired test
      run_test("test_example");
  	end

  // instantiate the DUT, connecting the signals of the top module to its ports
  my_dut DUT(
	.pclk_i                  (clk    ),
	.rst_n_i                 (rst_n   ),
	.psel_i                  (psel    ),
	.penable_i               (penable ),
  .paddr_i                 (paddr   ),
  .valid_i                 (valid   ),
  .addr_i                  (addr    ), 
  .irq_o                   (irq     )
);

endmodule