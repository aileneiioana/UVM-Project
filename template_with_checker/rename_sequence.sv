`include "uvm_macros.svh"
import uvm_pkg::*;

`ifndef __rename_sequence
`define __rename_sequence

//declare a class that generates a sequence of data
class rename_sequence extends uvm_sequence #(rename_transaction);
  
  //register the new data type (sequence) in the UVM factory
  `uvm_object_utils(rename_sequence)
  
  //declare the sequence length
  rand int num_transactions;

  //optional: when the test fills this list, the sequence sends exactly these addresses, in this order
  bit [2:0] addr_list[$];
  
  //constrain the length of the transaction sequence to a range of our choice
  constraint sequence_size_c{
    //constraints declared with the "soft" keyword can be overridden later
    soft num_transactions inside {[10:10+5]};
  }
  
  function new(string name="rename_sequence");
    super.new(name);
  endfunction
    
  function void post_randomize();
    $display("RENAME_SEQUENCE: Transaction sequence size=%0d", num_transactions);
   endfunction
  
  virtual task body();
    //a list given by the test sets the number of transactions
    if (addr_list.size() > 0)
      num_transactions = addr_list.size();
    
    //`ifdef DEBUG
    //	$display("phase_shift= ", phase_shift);
    //`endif;
    `uvm_info("RENAME_SEQUENCE", $sformatf("Started the sequence with a size of %-2d items", num_transactions), UVM_NONE)
    
    for (int i=0; i< num_transactions; i++) begin
      
      //create a transaction using the "req" handle
      req = rename_transaction::type_id::create("req");
      
      //start creating the transaction
      start_item(req);
      //generate random values within the ranges of interest for the rename transaction 
      if (addr_list.size() > 0)
        //the address comes from the list given by the test, so nothing is randomized
        req.addr = addr_list[i];
      else
        assert (req.randomize() with {addr inside {[0:7]};});
      `ifdef DEBUG
      `uvm_info("RENAME_SEQUENCE", $sformatf("At time %0t generated item %0d with the following information:\n ", $time, i), UVM_LOW)
        req.display_transaction_info();
      `endif;
      
      //transaction creation is finished; it can now go to the sequencer
      finish_item(req);
    end
    `uvm_info("RENAME_SEQUENCE", $sformatf("All %0d transactions were generated", num_transactions), UVM_LOW)
  endtask
endclass
`endif