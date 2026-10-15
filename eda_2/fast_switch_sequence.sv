`ifndef __input_sequence_switch
`define __input_sequence_switch

//declare a class that generates a sequence of data
class fast_switch_sequence extends uvm_sequence #(transaction_agent_button);
  
  //register the new data type (sequence) in the UVM factory
  `uvm_object_utils(fast_switch_sequence)
  
  //declare the sequence length
  rand int num_transactions;
  
  //constrain the length of the transaction sequence to a range of our choice
  constraint sequence_size_c{
    //constraints declared with the "soft" keyword can be overridden later
    soft num_transactions inside {[10:10+5]};
  }
  
  function new(string name="input_sequence");
    super.new(name);
  endfunction
    
  function void post_randomize();
    $display("INPUT_SEQUENCE: Transaction sequence size=%0d", num_transactions);
   endfunction
  
  virtual task body();
    
    //`ifdef DEBUG
    //	$display("phase_shift= ", phase_shift);
    //`endif;
    `uvm_info("INPUT_SEQUENCE", $sformatf("Started the sequence with a size of %-2d items", num_transactions), UVM_NONE)
    
    for (int i=0; i< num_transactions-1; i++) begin//the last transaction is generated outside the for loop, to keep the module running (enable = 1) and thus allow all temperature transactions to be sent
      
      //create a transaction using the "req" handle
      req = transaction_agent_button::type_id::create("req");
      
      //start creating the transaction
      start_item(req);
      //randomize the transaction contents (here, the module enable signal)
      assert (req.randomize() with { i%2==0 -> enable == 1; i%2 ==1 -> enable == 0;});
      `ifdef DEBUG
      `uvm_info("INPUT_SEQUENCE", $sformatf("At time %0t generated item %0d with the following information:\n ", $time, i), UVM_LOW)
        req.display_button_transaction_info();
      `endif;
      
      //transaction creation is finished; it can now go to the sequencer
      finish_item(req);
    end
    
    //the last transaction leaves enable at 1 until the fork/join block in the test finishes running
    req = transaction_agent_button::type_id::create("req");
    start_item(req);
    req.enable = 1;
    finish_item(req);
    
    `uvm_info("INPUT_SEQUENCE", $sformatf("All %0d transactions were generated", num_transactions), UVM_LOW)
  endtask
endclass
`endif