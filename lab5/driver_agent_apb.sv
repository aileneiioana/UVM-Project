`include "uvm_macros.svh"
import uvm_pkg::*;

`ifndef __apb_driver
`define __apb_driver

//the driver takes "transaction" items and sends them to the DUT according to the communication protocol of the interface
class driver_agent_apb extends uvm_driver #(transaction_apb);
  
  //register the driver in the UVM factory
  `uvm_component_utils (driver_agent_apb)
  
  //declare the interface on which the driver will send the data
  virtual apb_interface_dut driver_apb_intf;
  
  //class constructor
  function new(string name = "driver_agent_apb", uvm_component parent = null);
    //call the parent class constructor
    super.new(name, parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    //first call the build_phase function of the parent class
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
  
  task send_transaction(transaction_apb info_to_send);
    $timeformat(-9, 2, " ns", 20);//when time is printed in the console with %t, it is shown in nanoseconds (-9), with 2 decimals, followed by the abbreviation " ns"
    
    @(posedge driver_apb_intf.pclk);
    driver_apb_intf.psel = 'b1;
    @(posedge driver_apb_intf.pclk);
  //  @(posedge driver_apb_intf.pclk);//data transmission is synchronized with the system clock
    driver_apb_intf.penable = 'b1;
    driver_apb_intf.paddr = info_to_send.addr;
  
	 @(posedge driver_apb_intf.pclk);

    
    `ifdef DEBUG
    $display("DRIVER_AGENT_APB, after transmission; [T=%0t]", $realtime);
    `endif;
  endtask
  
endclass
`endif