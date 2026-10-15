`include "uvm_macros.svh"
import uvm_pkg::*;

`ifndef __scoreboard
`define __scoreboard

`uvm_analysis_imp_decl(_apb)
`uvm_analysis_imp_decl(_rename)

class scoreboard extends uvm_scoreboard;
  
  `uvm_component_utils(scoreboard)
  
  uvm_analysis_imp_apb #(transaction_apb, scoreboard) apb_data_port;
  uvm_analysis_imp_rename #(transaction_rename, scoreboard) rename_data_port;

  transaction_apb    received_apb_transaction;
  transaction_rename received_rename_transaction;

  //transaction_apb    apb_transactions[$];
  //transaction_rename rename_transactions[$];

  bit enable;
  
  function new(string name="scoreboard", uvm_component parent=null);
    super.new(name, parent);
    apb_data_port = new("apb_data_port", this);
    rename_data_port = new("rename_data_port", this);
    
    received_apb_transaction = new();   
    received_rename_transaction = new();   
  endfunction
  
  virtual function void connect_phase (uvm_phase phase);
    super.connect_phase(phase);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction
  
  function void write_apb(input transaction_apb new_apb_transaction);  
    `uvm_info("SCOREBOARD", $sformatf("Received from the APB agent the transaction with the following information:\n"), UVM_LOW)
    new_apb_transaction.display_transaction_info();
    
    $display($sformatf("when the APB data was received, enable was %d", enable));
    
    received_apb_transaction = new_apb_transaction.copy();
    //apb_transactions.push_back(received_apb_transaction);
  endfunction : write_apb

  function void write_rename(input transaction_rename new_rename_transaction);  
    `uvm_info("SCOREBOARD", $sformatf("Received from the rename agent the transaction with the following information:\n"), UVM_LOW)
    new_rename_transaction.display_transaction_info();
    
    $display($sformatf("when the rename data was received, enable was %d", enable));
    
    received_rename_transaction = new_rename_transaction.copy();
    //rename_transactions.push_back(received_rename_transaction);
  endfunction : write_rename

 /*  virtual function void check_phase (uvm_phase phase);
   foreach(rename_transactions[i]) begin
      //checker 1
      if (rename_transactions[i].irq == 1) begin
        if(rename_transactions[i].addr != apb_transactions[i].paddr)
          `uvm_error("SCOREBOARD checker 1", $sformatf("IRQ asserted wrong, address on apb is %h and on rename is %h", apb_transactions[i].paddr, rename_transactions[i].addr))
        else 
          `uvm_info("SCOREBOARD checker 1", "IRQ ASSERTED: OK", UVM_LOW)
      end
      //checker 2
      if((rename_transactions[i].addr == apb_transactions[i].paddr) && (rename_transactions[i].irq == 0))
        `uvm_error("SCOREBOARD checker 2", "IRQ expected but not asserted")
      else 
        `uvm_info("SCOREBOARD checker 2", "IRQ ASSERTED: OK", UVM_LOW)
    end
  endfunction*/
endclass
`endif
