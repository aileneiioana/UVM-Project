`include "uvm_macros.svh"
import uvm_pkg::*;

`ifndef __rename_driver
`define __rename_driver

//driverul va prelua date de tip "tranzactie", pe care le va trimite DUT-ului, conform protocolul de comunicatie de pe interfata
class rename_driver extends uvm_driver #(rename_transaction);
  
  //driverul se adauga in baza de date UVM
  `uvm_component_utils (rename_driver)
  
  //este declarata interfata pe care driverul va trimite datele
  virtual rename_interface_dut driver_rename_intf;
  
  //constructorul clasei
  function new(string name = "rename_driver", uvm_component parent = null);
    //este apelat constructorul clasei parinte
    super.new(name, parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    //este apelata mai intai functia build_phase din clasa parinte
    super.build_phase(phase);
    if (!uvm_config_db#(virtual rename_interface_dut)::get(this, "", "rename_interface_dut", driver_rename_intf))begin
      `uvm_fatal("DRIVER_AGENT_RENAME", "Could not access the rename interface")
    end
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    forever begin
      `uvm_info("DRIVER_AGENT_RENAME", $sformatf("Waiting for a transaction from the sequencer"), UVM_LOW)
      seq_item_port.get_next_item(req);
      `uvm_info("DRIVER_AGENT_RENAME", $sformatf("Received a transaction from the sequencer"), UVM_LOW)
      send_transaction(req);
      `uvm_info("DRIVER_AGENT_RENAME", $sformatf("The transaction was sent on the interface"), UVM_LOW)
      seq_item_port.item_done();
    end
  endtask
  
  task send_transaction(rename_transaction info_to_send);
    $timeformat(-9, 2, " ns", 20);//cand se va afisa in consola timpul, folosind directiva %t timpul va fi afisat in nanosecunde (-9), cu 2 zecimale, iar dupa valoare se va afisa abrevierea " ns"
    
    driver_rename_intf.valid = 'b1;
    driver_rename_intf.addr = info_to_send.addr;
	 @(posedge driver_rename_intf.clk);
   driver_rename_intf.valid = 'b0;

    
    `ifdef DEBUG
    $display("DRIVER_AGENT_RENAME, after transmission; [T=%0t]", $realtime);
    `endif;
  endtask
  
endclass
`endif