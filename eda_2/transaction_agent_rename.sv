`ifndef __rename_transaction
`define __rename_transaction

//a transaction is the set of data transferred at a given moment on an interface
class transaction_agent_rename extends uvm_sequence_item;
  
  //register the transaction component in the factory
  `uvm_object_utils(transaction_agent_rename)


  //class constructor; this function is called when an object of the transaction class is created
  function new(string name = "transaction_agent_rename");//the name is arbitrary and is not used anywhere else
    super.new(name);
  endfunction
 
  //function that displays a transaction
  function void display_transaction_info();
     //////
  endfunction
  
  //function that compares 2 transactions
  virtual function bit do_compare(uvm_object rhs, uvm_comparer comparer);
    //the first 4 lines can be considered standard code, which we do not modify
    bit res;
	transaction_agent_rename _obj;
	$cast(_obj, rhs);
	//////
	return res;
  endfunction
  
  //function for "deep copy"
  function transaction_agent_rename copy();
	copy = new();
  //////////
	return copy;
  endfunction
  
endclass


`endif