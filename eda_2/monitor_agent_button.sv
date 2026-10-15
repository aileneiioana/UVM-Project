//this component was not adapted to this verification environment
`ifndef __output_monitor_agent_button
`define __output_monitor_agent_button
`include "transaction_agent_button.sv"

//`include "transaction_traffic_lights.sv"

class monitor_agent_button extends uvm_monitor;
  
  //register the monitor in the UVM factory
  `uvm_component_utils (monitor_agent_button) 
  
  //declare the coverage collector that will record the values of the interface signals read by the monitor
  coverage_agent_button button_coverage_collector_inst;
  
  //create the port through which the monitor sends out (in our case to the scoreboard), via the agent, the transactions extracted from the interface traffic
  uvm_analysis_port #(transaction_agent_button) monitor_button_data_port;
  
  //declaration of the interface from which the monitor collects its data
  virtual button_interface_dut monitor_button_intf;
  
  transaction_agent_button sampled_button_state, aux_tr_button;
  
  
  //class constructor
  function new(string name = "monitor_agent_button", uvm_component parent = null);
    
    //first call the parent class constructor
    super.new(name, parent);
    
    //create the port through which the monitor sends out, via the agent, the data it collected from the interface traffic
    monitor_button_data_port = new("monitor_button_data_port",this);
    
    //create the coverage collector (on creation, the coverage collector's constructor is called)
    button_coverage_collector_inst = coverage_agent_button::type_id::create ("button_coverage_collector_inst", this);
    
    
    //create the object (transaction) that will hold the data collected from the interface on every clock cycle
    sampled_button_state = transaction_agent_button::type_id::create("new_data");
    
    aux_tr_button = transaction_agent_button::type_id::create("new_data_copy");
  endfunction
  
  
  //get from the database the interface the monitor will connect to in order to read data, and bind it to the interface handle the monitor already contains
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
      if (!uvm_config_db#(virtual button_interface_dut)::get(this, "", "button_interface_dut", monitor_button_intf))
        `uvm_fatal("MONITOR_AGENT_BUTTON", "Could not access the monitor interface")
  endfunction
        
  
  
  virtual function void connect_phase (uvm_phase phase);
    super.connect_phase(phase);
    
    //in the UVM "connect" phase, the monitor handle inside this monitor's coverage collector instance is connected to the monitor itself 
	button_coverage_collector_inst.p_monitor = this;
    
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    
    forever begin
      
      //data is sampled from the interface on every falling clock edge
      @(negedge monitor_button_intf.clk_i);
            
      
      //sample the data from the DUT interface (button_interface_dut)
      sampled_button_state.enable = monitor_button_intf.enable_i;
      
      aux_tr_button = sampled_button_state.copy();
      
       //the transaction holding the data collected from the interface is made available on the monitor's port
     monitor_button_data_port.write(aux_tr_button); 
      
      //sample the values of the output signals for coverage
      button_coverage_collector_inst.button_cg.sample();
      
    end//forever begin
  endtask
  
endclass: monitor_agent_button

`endif