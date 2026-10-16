`include "uvm_macros.svh"
import uvm_pkg::*;

`ifndef __rename_sequence
`define __rename_sequence

//se declara o clasa care genereaza o secventa de date
class rename_sequence extends uvm_sequence #(rename_transaction);
  
  //noul tip de data (secventa) se adauga la baza de date UVM
  `uvm_object_utils(rename_sequence)
  
  //se declara dimensiunea sirului
  rand int num_transactions;

  //optional: daca testul completeaza aceasta lista, secventa trimite exact aceste adrese, in aceasta ordine
  bit [2:0] addr_list[$];
  
  //se constrange dimensiunea sirului de tranzactii intr-un interval ales de noi
  constraint sequence_size_c{
    //constrangerile declarate cu cuvantul cheie "soft" se pot suprascrie ulterior
    soft num_transactions inside {[10:10+5]};
  }
  
  function new(string name="rename_sequence");
    super.new(name);
  endfunction
    
  function void post_randomize();
    $display("RENAME_SEQUENCE: Transaction sequence size=%0d", num_transactions);
   endfunction
  
  virtual task body();
    //daca testul a dat o lista, ea stabileste numarul de tranzactii
    if (addr_list.size() > 0)
      num_transactions = addr_list.size();
    
    //`ifdef DEBUG
    //	$display("phase_shift= ", phase_shift);
    //`endif;
    `uvm_info("RENAME_SEQUENCE", $sformatf("Started the sequence with a size of %-2d items", num_transactions), UVM_NONE)
    
    for (int i=0; i< num_transactions; i++) begin
      
      //se creaza o tranzactie folosindu-se cuvantul cheie "req"
      req = rename_transaction::type_id::create("req");
      
      //se incepe crearea tranzactiei
      start_item(req);
      //se genereaza random valori in intervalele de interes pt fiecare rename 
      if (addr_list.size() > 0)
        //adresa vine din lista data de test, deci nu se mai randomizeaza nimic
        req.addr = addr_list[i];
      else
        assert (req.randomize() with {addr inside {[0:7]};});
      `ifdef DEBUG
      `uvm_info("RENAME_SEQUENCE", $sformatf("At time %0t generated item %0d with the following information:\n ", $time, i), UVM_LOW)
        req.display_transaction_info();
      `endif;
      
      //s-a terminat crearea tranzactiei; aceasta poate pleca catre sequencer
      finish_item(req);
    end
    `uvm_info("RENAME_SEQUENCE", $sformatf("All %0d transactions were generated", num_transactions), UVM_LOW)
  endtask
endclass
`endif