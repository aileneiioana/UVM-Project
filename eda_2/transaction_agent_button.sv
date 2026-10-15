`ifndef __transaction_agent_button
`define __transaction_agent_button

//a transaction is the set of data transferred at a given moment on an interface
class transaction_agent_button extends uvm_sequence_item;
  
  //register the transaction component in the factory
  `uvm_object_utils(transaction_agent_button)
  
  rand bit enable;

  
  //class constructor; this function is called when an object of the transaction class is created
  function new(string name = "sequence_item");//the name is arbitrary and is not used anywhere else
    super.new(name);
  	enable = 0;

  endfunction
  
  //function that displays a transaction
  function void display_button_transaction_info();
  
    $display("TRANSACTION_AGENT_BUTTON: enable value is: %0h",enable);

  endfunction
  
  function transaction_agent_button copy();
	copy = new();
	copy.enable = this.enable;
	return copy;
  endfunction

  
endclass


`endif