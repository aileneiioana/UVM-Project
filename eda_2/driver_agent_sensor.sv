`ifndef __sensor_driver
`define __sensor_driver

//the driver takes "transaction" items and sends them to the DUT according to the communication protocol of the interface
class driver_agent_sensor extends uvm_driver #(transaction_sensor);
  
  //register the driver in the UVM factory
  `uvm_component_utils (driver_agent_sensor)
  
  //declare the interface on which the driver will send the data
  virtual sensor_interface_dut driver_sensor_intf;
  
  //class constructor
  function new(string name = "driver_agent_sensor", uvm_component parent = null);
    //call the parent class constructor
    super.new(name, parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    //first call the build_phase function of the parent class
    super.build_phase(phase);
    if (!uvm_config_db#(virtual sensor_interface_dut)::get(this, "", "sensor_interface_dut", driver_sensor_intf))begin
      `uvm_fatal("DRIVER_AGENT_SENSOR", "Could not access the sensor interface")
    end
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    forever begin
      `uvm_info("DRIVER_AGENT_SENSOR", $sformatf("Waiting for a transaction from the sequencer"), UVM_LOW)
      seq_item_port.get_next_item(req);
      `uvm_info("DRIVER_AGENT_SENSOR", $sformatf("Received a transaction from the sequencer"), UVM_LOW)
      send_transaction(req);
      `uvm_info("DRIVER_AGENT_SENSOR", $sformatf("The transaction was sent on the interface"), UVM_LOW)
      seq_item_port.item_done();
    end
  endtask
  
  task send_transaction(transaction_sensor info_to_send);
    $timeformat(-9, 2, " ns", 20);//when time is printed in the console with %t, it is shown in nanoseconds (-9), with 2 decimals, followed by the abbreviation " ns"
    
	//wait ready
    $display("%0t DRIVER_AGENT_SENSOR: wait ready", $time());
    wait(driver_sensor_intf.ready_o)
    $display("%0t DRIVER_AGENT_SENSOR: READY arrived", $time());
    @(posedge driver_sensor_intf.clk_i);
    driver_sensor_intf.valid_i = 'b1;
  //  @(posedge driver_sensor_intf.clk_i);//data transmission is synchronized with the system clock
    driver_sensor_intf.temperature_i = info_to_send.temperature;
    driver_sensor_intf.humidity_i = info_to_send.humidity;
    driver_sensor_intf.luminous_intensity_i = info_to_send.luminous_intensity;
	 @(posedge driver_sensor_intf.clk_i);
    driver_sensor_intf.valid_i = 'b0;
    
    `ifdef DEBUG
    $display("DRIVER_AGENT_SENSOR, after transmission; [T=%0t]", $realtime);
    `endif;
  endtask
  
endclass
`endif