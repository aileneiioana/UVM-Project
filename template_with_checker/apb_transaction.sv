`include "uvm_macros.svh"
import uvm_pkg::*;

`ifndef __apb_transaction
`define __apb_transaction

//a transaction is the set of data transferred at a given moment on an interface
class apb_transaction extends uvm_sequence_item;
  
  //register the transaction component in the factory
  `uvm_object_utils(apb_transaction)
  
  rand bit[2:0] addr;
  
  //class constructor; this function is called when an object of the transaction class is created
  function new(string name = "sequence_item_rename");//the name is arbitrary and is not used anywhere else
    super.new(name);  
  	addr = 0;
  endfunction
  
  //function that displays a transaction
  function void display_transaction_info();
    $display("Address: %0h", addr);
  endfunction
  
  function apb_transaction copy();
	copy = new();
	copy.addr = this.addr;
	return copy;
  endfunction

endclass
`endif