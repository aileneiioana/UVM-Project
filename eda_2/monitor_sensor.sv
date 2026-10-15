`ifndef __sensor_monitor
`define __sensor_monitor
//`include "transaction_traffic_lights.sv"

class monitor_sensor extends uvm_monitor;
  
  //register the monitor in the UVM factory
  `uvm_component_utils (monitor_sensor) 
  
  //declare the coverage collector that will record the values of the interface signals read by the monitor
  coverage_sensor sensor_coverage_collector; 
  
  //create the port through which the monitor sends out (in our case to the scoreboard), via the agent, the transactions extracted from the interface traffic
  uvm_analysis_port #(transaction_sensor) monitor_sensor_data_port;
  
  //declaration of the interface from which the monitor collects its data
  //virtual sensor_interface monitor_sensor_intf;
  virtual sensor_interface_dut monitor_sensor_intf;
  
  transaction_sensor sampled_sensor_state, aux_tr_sensor;
  
  //class constructor
  function new(string name = "monitor_sensor", uvm_component parent = null);
    
    //first call the parent class constructor
    super.new(name, parent);
    
    
    
    //create the port through which the monitor sends out, via the agent, the data it collected from the interface traffic
    monitor_sensor_data_port = new("monitor_sensor_data_port",this);
    
    //create the coverage collector (on creation, the coverage collector's constructor is called)
    
    sensor_coverage_collector = coverage_sensor::type_id::create ("sensor_coverage_collector", this);
    
    
    //create the object (transaction) that will hold the data collected from the interface on every clock cycle
    sampled_sensor_state = transaction_sensor::type_id::create("new_data");
    
    aux_tr_sensor = transaction_sensor::type_id::create("new_data_copy");
  endfunction
  
  
  //get from the database the interface the monitor will connect to in order to read data, and bind it to the interface handle the monitor already contains
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    if (!uvm_config_db#(virtual sensor_interface_dut)::get(this, "", "sensor_interface_dut", monitor_sensor_intf))
        `uvm_fatal("MONITOR_SENSOR", "Could not access the monitor interface")
  endfunction
        
  
  
  virtual function void connect_phase (uvm_phase phase);
    super.connect_phase(phase);
    
    //in the UVM "connect" phase, the monitor handle inside this monitor's coverage collector instance is connected to the monitor itself 
	sensor_coverage_collector.p_monitor = this;
    
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    
    forever begin
      
      
        
      
      //!!!!wait until the data is valid
      wait(monitor_sensor_intf.valid_i); 
      //I want to sample valid_i only on falling clock edges
      @(negedge monitor_sensor_intf.clk_i); 
      //sample the data from the DUT output interface
      sampled_sensor_state.temperature = monitor_sensor_intf.temperature_i;
      sampled_sensor_state.humidity = monitor_sensor_intf.humidity_i;
	  sampled_sensor_state.luminous_intensity = monitor_sensor_intf.luminous_intensity_i;

      aux_tr_sensor = sampled_sensor_state.copy();//I don't want to use the sampled_sensor_state handle to send the data, because its contents change and the scoreboard would read different data 
      
       //the transaction holding the data collected from the interface is made available on the monitor's port
      monitor_sensor_data_port.write(aux_tr_sensor); 
      `uvm_info("MONITOR_SENSOR", $sformatf("Received the transaction with the following information:"), UVM_NONE)
      aux_tr_sensor.display_transaction_info();
	  
      //sample the values of the output signals for coverage
      sensor_coverage_collector.sensor_states_cg.sample();
      
	  @(negedge monitor_sensor_intf.clk_i); //this wait was added because sometimes one transaction was interpreted as two identical back-to-back transactions (valid was read as 1 on two consecutive clock edges); in the current implementation two transactions cannot come back to back
      
      
    end//forever begin
  endtask
  
  
endclass: monitor_sensor

`endif