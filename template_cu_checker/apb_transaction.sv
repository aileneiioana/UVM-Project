`include "uvm_macros.svh"
import uvm_pkg::*;

`ifndef __apb_transaction
`define __apb_transaction

//o tranzactie este formata din totalitatea datelor transmise la un moment dat pe o interfata
class apb_transaction extends uvm_sequence_item;
  
  //componenta tranzactie se adauga in baza de date
  `uvm_object_utils(apb_transaction)
  
  rand bit[2:0] addr;
  
  //constructorul clasei; această funcție este apelată când se creează un obiect al clasei "tranzactie"
  function new(string name = "sequence_item_rename");//numele dat este ales aleatoriu, si nu mai este folosit in alta parte
    super.new(name);  
  	addr = 0;
  endfunction
  
  //functie de afisare a unei tranzactii
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