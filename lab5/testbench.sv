`include "uvm_macros.svh"
import uvm_pkg::*;

`define PERIOADA_CEASULUI 10


`ifndef 10//numarul minim de tranzactii care se vor genera pe interfata de intrare
  `define 10 10
`endif

//`define DEBUG      //parametru folosit pentru a activa mesaje pe care noi le stabilim ca ar fi necesare doar la debug

//stabilirea semnificatiei unitatilor de timp din simulator
`timescale 1ns/1ns

//includerea fisierelor la care modulul de top trebuie sa aiba acces

`include "apb_interface_dut.sv"
`include "test_exemplu.sv"
`include "design.sv"

// Code your testbench here

module top();
   logic clk;
   wire  rst_n;
   wire  [2:0] paddr;
   wire         psel;
   wire         penable;
  //sunt create instantele interfetelor (in acest proiect sunt 2 agenti, deci vor fi 2 interfete); se leaga semnalele interfetelor de semnalele din modulul de top
  apb_interface_dut intf_apb();
  assign intf_apb.pclk = clk;
  assign rst_n         = intf_apb.rst_n;
  assign psel          = intf_apb.psel;
  assign penable       = intf_apb.penable;
  assign paddr         = intf_apb.paddr;
  
  
  initial begin
    //cele 2 linii de mai jos permit vizualizarea formelor de unda (pentru a vizualiza formele de unda trebuie bifata si optiunea "Open EPWave after run" din sectiunea "Tools & Simulators" aflata in stanga paginii)
    $dumpfile("dump.vcd");
    $dumpvars;
    //se genereaza ceasul
	clk = 1;
	forever begin 
    #(`PERIOADA_CEASULUI/2)  
    clk <= ~clk;
  end
	end
  
   initial
  	begin
      //se salveaza instantele interfetelor in baza de date UVM
      uvm_config_db#(virtual apb_interface_dut)::set(null, "*", "apb_interface_dut", intf_apb);

      //se ruleaza testul dorit
      run_test("test_exemplu");
  	end

  // se instantiaza DUT-ul, facandu-se legaturile intre semnalele din modulul de top si semnalele acestuia
  apb_slave DUT(
	.pclk_i                   (clk    ),
	.rst_n_i                 (rst_n   ),
	.psel_i                  (psel    ),
	.penable_i               (penable ),
  .paddr_i                 (paddr   )
);

endmodule