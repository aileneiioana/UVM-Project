`include "uvm_macros.svh"
import uvm_pkg::*;

`ifndef __scoreboard
`define __scoreboard

//declare the suffixes of the analysis imp ports used to receive data from each agent
`uvm_analysis_imp_decl(_apb)
`uvm_analysis_imp_decl(_rename)

class scoreboard extends uvm_scoreboard;
  
  //register the component in the UVM factory
  `uvm_component_utils(scoreboard)
  
  //ports through which the scoreboard receives the transactions collected by the monitors
  uvm_analysis_imp_apb #(transaction_apb, scoreboard) apb_data_port;
  uvm_analysis_imp_rename #(transaction_rename, scoreboard) rename_data_port;

  transaction_apb    received_apb_transaction;
  transaction_rename received_rename_transaction;

  //all transactions received during the run; the checker uses them in check_phase
  transaction_apb    apb_transactions[$];
  transaction_rename rename_transactions[$];

  //simulation time at which each transaction was sampled by its monitor;
  //both monitors sample on the falling edge of the same clock, so two transactions
  //with the same time stamp happened in the same clock cycle
  time apb_times[$];
  time rename_times[$];
  
  function new(string name="scoreboard", uvm_component parent=null);
    super.new(name, parent);
    apb_data_port = new("apb_data_port", this);
    rename_data_port = new("rename_data_port", this);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction
  
  virtual function void connect_phase (uvm_phase phase);
    super.connect_phase(phase);
  endfunction
  
  //called by the APB monitor (through the agent) every time it collects a transaction
  function void write_apb(input transaction_apb new_apb_transaction);  
    `uvm_info("SCOREBOARD", $sformatf("Received from the APB agent the transaction with the following information:\n"), UVM_LOW)
    new_apb_transaction.display_transaction_info();
    
    //store a copy, so later transactions do not overwrite this one
    received_apb_transaction = new_apb_transaction.copy();
    apb_transactions.push_back(received_apb_transaction);
    apb_times.push_back($time);
  endfunction : write_apb

  //called by the rename monitor (through the agent) every time it collects a transaction
  function void write_rename(input transaction_rename new_rename_transaction);  
    `uvm_info("SCOREBOARD", $sformatf("Received from the rename agent the transaction with the following information:\n"), UVM_LOW)
    new_rename_transaction.display_transaction_info();
    
    received_rename_transaction = new_rename_transaction.copy();
    rename_transactions.push_back(received_rename_transaction);
    rename_times.push_back($time);
  endfunction : write_rename

  //THE CHECKER
  //A checker compares what the DUT actually did with what it should have done according to the specification.
  //Specification of my_dut: irq = psel && penable && valid && (paddr == addr)
  //i.e. irq must be 1 exactly in the clock cycles where an APB access and a valid rename
  //transaction happen at the same time AND have the same address.
  //check_phase runs after the run phase, when all transactions have been collected.
  virtual function void check_phase (uvm_phase phase);
    int num_checks = 0;
    int num_errors = 0;
    super.check_phase(phase);

    foreach (rename_transactions[i]) begin
      int apb_idx      = -1;
      bit irq_expected = 0;

      //find the APB access (if any) that happened in the same clock cycle as this rename transaction
      foreach (apb_times[j])
        if (apb_times[j] == rename_times[i])
          apb_idx = j;

      //reference model: what irq should be, according to the specification
      if (apb_idx != -1)
        irq_expected = (apb_transactions[apb_idx].addr == rename_transactions[i].addr);

      num_checks++;

      //checker 1: the DUT raised irq, but it should not have
      if ((rename_transactions[i].irq == 1) && (irq_expected == 0)) begin
        num_errors++;
        if (apb_idx == -1)
          `uvm_error("SCOREBOARD checker 1", $sformatf("[T=%0t] IRQ asserted wrong: there is no APB access in this cycle (rename addr = %0h)", rename_times[i], rename_transactions[i].addr))
        else
          `uvm_error("SCOREBOARD checker 1", $sformatf("[T=%0t] IRQ asserted wrong: address on apb is %0h and on rename is %0h", rename_times[i], apb_transactions[apb_idx].addr, rename_transactions[i].addr))
      end
      //checker 2: irq should have been raised, but the DUT did not raise it
      else if ((rename_transactions[i].irq == 0) && (irq_expected == 1)) begin
        num_errors++;
        `uvm_error("SCOREBOARD checker 2", $sformatf("[T=%0t] IRQ expected but not asserted: address on apb and on rename is %0h", rename_times[i], rename_transactions[i].addr))
      end
      //the DUT behaved as specified
      else
        `uvm_info("SCOREBOARD", $sformatf("[T=%0t] IRQ = %0b as expected: OK", rename_times[i], rename_transactions[i].irq), UVM_LOW)
    end

    //a checker that checked nothing proves nothing: make this visible
    if (num_checks == 0)
      `uvm_error("SCOREBOARD", "No rename transactions were received, so nothing was checked")
    else
      `uvm_info("SCOREBOARD", $sformatf("Checker summary: %0d checks, %0d errors", num_checks, num_errors), UVM_NONE)
  endfunction
endclass
`endif
