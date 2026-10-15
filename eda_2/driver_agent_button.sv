//this component was not adapted to this verification environment
`ifndef __input_driver_agent_button
`define __input_driver_agent_button

//the driver takes "transaction" items and sends them to the DUT according to the communication protocol of the interface
class driver_agent_button extends uvm_driver #(transaction_agent_button);
  
  //register the driver in the UVM factory
  `uvm_component_utils (driver_agent_button)
  
  //declare the interface on which the driver will send the data
  virtual button_interface_dut driver_button_intf;
  
  //class constructor
  function new(string name = "driver_agent_button", uvm_component parent = null);
    //call the parent class constructor
    super.new(name, parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    //first call the build_phase function of the parent class
    super.build_phase(phase);
    if (!uvm_config_db#(virtual button_interface_dut)::get(this, "", "button_interface_dut", driver_button_intf))begin
      `uvm_fatal("DRIVER_AGENT_BUTTON", "Could not access button_interface_dut")
    end
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    forever begin
      `uvm_info("DRIVER_AGENT_BUTTON", $sformatf("Waiting for a transaction from the sequencer"), UVM_LOW)
      seq_item_port.get_next_item(req);
      `uvm_info("DRIVER_AGENT_BUTTON", $sformatf("Received a transaction from the sequencer"), UVM_LOW)
      send_transaction(req);
      `uvm_info("DRIVER_AGENT_BUTTON", $sformatf("The transaction was sent on the interface"), UVM_LOW)
      seq_item_port.item_done();
    end
  endtask
   
  task send_transaction(transaction_agent_button info_to_send);
    $timeformat(-9, 2, " ns", 20);//when time is printed in the console with %t, it is shown in nanoseconds (-9), with 2 decimals, followed by the abbreviation " ns"
    @(posedge driver_button_intf.clk_i);//data transmission is synchronized with the system clock
    driver_button_intf.enable_i = info_to_send.enable;
    
    
    `ifdef DEBUG
    $display("DRIVER_AGENT_BUTTON, after transmission; [T=%0t]", $realtime);
    `endif;
  endtask
  
endclass
`endif