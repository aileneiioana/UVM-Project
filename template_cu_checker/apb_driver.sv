`include "uvm_macros.svh"
import uvm_pkg::*;

`ifndef __apb_driver
`define __apb_driver

//driverul va prelua date de tip "tranzactie", pe care le va trimite DUT-ului, conform protocolul de comunicatie de pe interfata
class apb_driver extends uvm_driver #(apb_transaction);
  
  //driverul se adauga in baza de date UVM
  `uvm_component_utils (apb_driver)
  
  //este declarata interfata pe care driverul va trimite datele
  virtual apb_interface_dut driver_apb_intf;
  
  //constructorul clasei
  function new(string name = "apb_driver", uvm_component parent = null);
    //este apelat constructorul clasei parinte
    super.new(name, parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    //este apelata mai intai functia build_phase din clasa parinte
    super.build_phase(phase);
    if (!uvm_config_db#(virtual apb_interface_dut)::get(this, "", "apb_interface_dut", driver_apb_intf))begin
      `uvm_fatal("DRIVER_AGENT_APB", "Could not access the APB interface")
    end
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    forever begin
      `uvm_info("DRIVER_AGENT_APB", $sformatf("Waiting for a transaction from the sequencer"), UVM_LOW)
      seq_item_port.get_next_item(req);
      `uvm_info("DRIVER_AGENT_APB", $sformatf("Received a transaction from the sequencer"), UVM_LOW)
      send_transaction(req);
      `uvm_info("DRIVER_AGENT_APB", $sformatf("The transaction was sent on the interface"), UVM_LOW)
      seq_item_port.item_done();
    end
  endtask
  
  task send_transaction(apb_transaction info_to_send);
    $timeformat(-9, 2, " ns", 20);//cand se va afisa in consola timpul, folosind directiva %t timpul va fi afisat in nanosecunde (-9), cu 2 zecimale, iar dupa valoare se va afisa abrevierea " ns"
    
    @(posedge driver_apb_intf.pclk);
    driver_apb_intf.psel = 'b1;
    @(posedge driver_apb_intf.pclk);
  //  @(posedge driver_apb_intf.pclk);//transmiterea datelor se sincronizeaza cu ceasul de sistem
    driver_apb_intf.penable = 'b1;
    driver_apb_intf.paddr = info_to_send.addr;
  
	 @(posedge driver_apb_intf.pclk);
    driver_apb_intf.psel = 'b0;
    driver_apb_intf.penable = 'b0;
    `ifdef DEBUG
    $display("DRIVER_AGENT_APB, after transmission; [T=%0t]", $realtime);
    `endif;
  endtask
  
endclass
`endif