`ifndef __input_sequence_limit_val
`define __input_sequence_limit_val

//declare a class that generates a sequence of data
class sensor_limit_values_sequence extends uvm_sequence #(transaction_sensor);
  
  //register the new data type (sequence) in the UVM factory
  `uvm_object_utils(sensor_limit_values_sequence)
  
  //declare the sequence length
  int num_transactions =3;
  
  //constrain the length of the transaction sequence to a range of our choice
 /* constraint sequence_size_c{
    //constraints declared with the "soft" keyword can be overridden later
    soft num_transactions inside {[`10:`10+5]};
  }*/
  
  function new(string name="sensor_sequence");
    super.new(name);
  endfunction
    
  function void post_randomize();
    $display("SENSOR_SEQUENCE: Transaction sequence size=%0d", num_transactions);
   endfunction
  
  virtual task body();
    
    //`ifdef DEBUG
    //	$display("phase_shift= ", phase_shift);
    //`endif;
    `uvm_info("SENSOR_SEQUENCE", $sformatf("Started the sequence with a size of %-2d items", num_transactions), UVM_NONE)
    
    for (int i=0; i< num_transactions; i++) begin
      
      //create a transaction using the "req" handle
      req = transaction_sensor::type_id::create("req");
      
      //start creating the transaction
      start_item(req);
      //generate values for the boundary cases 
      								//minimum values
      assert (req.randomize() with {i == 0 -> temperature == 0; 
              						i == 0 -> humidity == 0;
              						i == 0 -> luminous_intensity == 0;
              						//limit values
              						i == 1 -> temperature == 22;
              						i == 1 -> humidity == 35;
              						i == 1 -> luminous_intensity == 200;
              						i == 2 -> temperature == 25;
              						i == 2 -> humidity == 50;
              						i == 2 -> luminous_intensity == 700;
              						//maximum values
              						i == 3 -> temperature == 40;
              						i == 3 -> humidity == 100;
                                    i == 3 -> luminous_intensity == 900;});
      								
      `ifdef DEBUG
      `uvm_info("SENSOR_SEQUENCE", $sformatf("At time %0t generated item %0d with the following information:\n ", $time, i), UVM_LOW)
        req.display_transaction_info();
      `endif;
      
      //transaction creation is finished; it can now go to the sequencer
      finish_item(req);
    end
    `uvm_info("SENSOR_SEQUENCE", $sformatf("All %0d transactions were generated", num_transactions), UVM_LOW)
  endtask
endclass
`endif