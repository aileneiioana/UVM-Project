`ifndef __actuator_transaction
`define __actuator_transaction

//a transaction is the set of data transferred at a given moment on an interface
class transaction_agent_actuator extends uvm_sequence_item;
  
  //register the transaction component in the factory
  `uvm_object_utils(transaction_agent_actuator)

  rand bit Heat_i;
  rand bit AC_i;
  rand bit Blinds_i;
  rand bit Dehumidifier_i;
 
  

  //class constructor; this function is called when an object of the transaction class is created
  function new(string name = "sequence_item");//the name is arbitrary and is not used anywhere else
    super.new(name);
  	Heat_i = 0;
  	AC_i = 0;
  	Blinds_i = 0;
  	Dehumidifier_i = 0;
  endfunction
  
  //function that displays a transaction
  function void display_transaction_info();
    $display("Heat: %0h, AC: %0h, Blinds: %0h, Dehumidifier: %0h",Heat_i,AC_i,Blinds_i,Dehumidifier_i); 
     
  endfunction
  
  //function that compares 2 transactions
  virtual function bit do_compare(uvm_object rhs, uvm_comparer comparer);
    //the first 4 lines can be considered standard code, which we do not modify
    bit res;
	transaction_agent_actuator _obj;
	$cast(_obj, rhs);
	res = super.do_compare(_obj, comparer) &
	      Heat_i == _obj.Heat_i &
    	  AC_i == _obj.AC_i &
    	  Blinds_i == _obj.Blinds_i &
    	  Dehumidifier_i == _obj.Dehumidifier_i;
    `uvm_info(get_name(), $sformatf("In transaction_agent_actuator::do_compare(), the comparison result is %0b", res), UVM_LOW)
	return res;
  endfunction
  
  //function for "deep copy"
  function transaction_agent_actuator copy();
	copy = new();
	copy.Heat_i = this.Heat_i;
	copy.AC_i = this.AC_i;
	copy.Blinds_i = this.Blinds_i;
	copy.Dehumidifier_i = this.Dehumidifier_i;
	return copy;
  endfunction

  
endclass


`endif