`include "uvm_macros.svh"
import uvm_pkg::*;

`ifndef __rename_transaction
`define __rename_transaction

//a transaction is the set of data transferred at a given moment on an interface
class transaction_rename extends uvm_sequence_item;
  
  //register the transaction component in the factory
  `uvm_object_utils(transaction_rename)
  
  rand bit[2:0] addr;
       bit      irq; //output, so it is not rand
  
  
  //class constructor; this function is called when an object of the transaction class is created
  function new(string name = "sequence_item_rename");//the name is arbitrary and is not used anywhere else
    super.new(name);  
  	addr = 0;
    irq  = 0;
  endfunction
  
  //function that displays a transaction
  function void display_transaction_info();
    $display("Address: %0h, IRQ: %b", addr, irq);
  endfunction
  
  function transaction_rename copy();
	copy = new();
	copy.addr = this.addr;
  copy.irq = this.irq;
	return copy;
  endfunction

endclass
`endif