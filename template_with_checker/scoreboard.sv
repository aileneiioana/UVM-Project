`include "uvm_macros.svh"
import uvm_pkg::*;

`ifndef __scoreboard
`define __scoreboard

class scoreboard extends uvm_scoreboard;
  
  //register the component in the UVM factory
  `uvm_component_utils(scoreboard)
  
  //ports through which the scoreboard receives the transactions collected by the monitors;
  //each port forwards everything it receives into its own FIFO (see connect_phase)
  uvm_analysis_export #(apb_transaction)    apb_data_port;
  uvm_analysis_export #(rename_transaction) rename_data_port;

  //one FIFO per agent: the monitors write into them during the simulation,
  //and the checker pulls the transactions out, in the order they arrived
  uvm_tlm_analysis_fifo #(apb_transaction)    apb_fifo;
  uvm_tlm_analysis_fifo #(rename_transaction) rename_fifo;

  //checker statistics, printed in check_phase
  int num_checks = 0;
  int num_errors = 0;
  
  function new(string name="scoreboard", uvm_component parent=null);
    super.new(name, parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    apb_data_port    = new("apb_data_port", this);
    rename_data_port = new("rename_data_port", this);
    apb_fifo         = new("apb_fifo", this);
    rename_fifo      = new("rename_fifo", this);
  endfunction
  
  virtual function void connect_phase (uvm_phase phase);
    super.connect_phase(phase);
    //every transaction that reaches a port is stored in that port's FIFO
    apb_data_port.connect(apb_fifo.analysis_export);
    rename_data_port.connect(rename_fifo.analysis_export);
  endfunction

  //THE DATA CHECKER
  //A data checker compares the data seen on one interface with the data expected from another one.
  //Here the test sends the same list of addresses on both interfaces, so the n-th transaction pulled
  //from the APB FIFO must carry the same address as the n-th transaction pulled from the rename FIFO.
  //In your project, one FIFO holds what went INTO the DUT (the expected data) and the other holds
  //what came OUT of the DUT (the actual data).
  virtual task run_phase(uvm_phase phase);
    apb_transaction    apb_tr;
    rename_transaction rename_tr;
    super.run_phase(phase);

    forever begin
      //get() blocks until the FIFO holds a transaction, then pulls it out
      apb_fifo.get(apb_tr);
      rename_fifo.get(rename_tr);
      num_checks++;

      if (apb_tr.addr != rename_tr.addr) begin
        num_errors++;
        `uvm_error("SCOREBOARD", $sformatf("Data mismatch on transaction %0d: APB addr = %0h, rename addr = %0h", num_checks, apb_tr.addr, rename_tr.addr))
      end
      else
        `uvm_info("SCOREBOARD", $sformatf("Transaction %0d: same data on both interfaces (addr = %0h): OK", num_checks, apb_tr.addr), UVM_LOW)
    end
  endtask

  //after the run phase: every transaction must have had a pair, and something must have been checked
  virtual function void check_phase (uvm_phase phase);
    super.check_phase(phase);

    if (apb_fifo.used() != 0 || rename_fifo.used() != 0)
      `uvm_error("SCOREBOARD", $sformatf("Transactions left without a pair: %0d in the APB FIFO, %0d in the rename FIFO", apb_fifo.used(), rename_fifo.used()))

    //a checker that checked nothing proves nothing: make this visible
    if (num_checks == 0)
      `uvm_error("SCOREBOARD", "No transactions were compared, so nothing was checked")
    else
      `uvm_info("SCOREBOARD", $sformatf("Checker summary: %0d checks, %0d errors", num_checks, num_errors), UVM_NONE)
  endfunction
endclass
`endif
