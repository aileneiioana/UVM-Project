`ifndef __monitor_agent_actuator
`define __monitor_agent_actuator
//`include "transaction_traffic_lights.sv"

class monitor_agent_actuator extends uvm_monitor;
  
  //register the monitor in the UVM factory
  `uvm_component_utils (monitor_agent_actuator) 
  
  //declare the coverage collector that will record the values of the interface signals read by the monitor
  coverage_agent_actuator coverage_actuator_inst; //coverage_collector_traffic_lights;
  
  //create the port through which the monitor sends out (in our case to the scoreboard), via the agent, the transactions extracted from the interface traffic
  uvm_analysis_port #(transaction_agent_actuator) monitor_actuator_data_port;
  
  //declaration of the interface from which the monitor collects its data
  virtual actuator_interface_dut monitor_actuator_intf;
  
  transaction_agent_actuator sampled_actuator_state, aux_tr_actuator;
  
  //class constructor
  function new(string name = "monitor_agent_actuator", uvm_component parent = null);
    
    //first call the parent class constructor
    super.new(name, parent);
    
    //create the port through which the monitor sends out, via the agent, the data it collected from the interface traffic
    monitor_actuator_data_port = new("monitor_actuator_data_port",this);
    
    //create the coverage collector (on creation, the coverage collector's constructor is called)
   coverage_actuator_inst = coverage_agent_actuator::type_id::create ("coverage_actuator_inst", this);
    
    
    //create the object (transaction) that will hold the data collected from the interface on every clock cycle
    sampled_actuator_state = transaction_agent_actuator::type_id::create("new_data");
    
    aux_tr_actuator = transaction_agent_actuator::type_id::create("new_data_copy"); // we use this object every time we send data on the write port, so that we don't work with the sampled_actuator_state handle, whose contents may change before the scoreboard reads it
  endfunction
  
  
  //get from the database the interface the monitor will connect to in order to read data, and bind it to the interface handle the monitor already contains
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    if (!uvm_config_db#(virtual actuator_interface_dut)::get(this, "", "actuator_interface_dut", monitor_actuator_intf))
      `uvm_fatal("MONITOR_AGENT_ACTUATOR", "Could not access the monitor interface")
  endfunction
        
  
  
  virtual function void connect_phase (uvm_phase phase);
    super.connect_phase(phase);
    
    //in the UVM "connect" phase, the monitor handle inside this monitor's coverage collector instance is connected to the monitor itself 
	coverage_actuator_inst.p_monitor = this;
    
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    
    forever begin
      
      //data is sampled from the interface on every falling clock edge
      @(negedge monitor_actuator_intf.clk_i);
      
      //delay reading the data by one clock cycle, so as not to read the DUT outputs before it has received values on its inputs
     // repeat(2)@(negedge monitor_actuator_intf.clk);
      
      
      //sample the data from the DUT output interface
    sampled_actuator_state.Heat_i =  monitor_actuator_intf.heat_o;
      sampled_actuator_state.AC_i =  monitor_actuator_intf.AC_o;
      sampled_actuator_state.Blinds_i =  monitor_actuator_intf.blinds_o;
      sampled_actuator_state.Dehumidifier_i =  monitor_actuator_intf.dehumidifier_o;
      
     
      aux_tr_actuator = sampled_actuator_state.copy();//sample the values of the output signals for coverage
      coverage_actuator_inst.actuator_cg.sample();
      
      //the transaction holding the data collected from the interface is made available on the monitor's port
      monitor_actuator_data_port.write( aux_tr_actuator); 
    //  `uvm_info("MONITOR_AGENT_TRAFFIC_LIGHTS", $sformatf("Received the transaction with the following information:"), UVM_NONE)
      //sampled_traffic_lights_state.display_transaction_info();
    end//forever begin
  endtask
endclass: monitor_agent_actuator

`endif