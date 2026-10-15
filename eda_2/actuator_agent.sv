`ifndef __tx_line_agent_actuator
`define __tx_line_agent_actuator

typedef class monitor_agent_actuator;

//include the dependencies used by the agent
`include "coverage_agent_actuator.sv"
`include "transaction_agent_actuator.sv"
`include "monitor_agent_actuator.sv"
  


class actuator_agent extends uvm_agent;
  
  `uvm_component_utils (actuator_agent)//register the agent in this project's UVM factory; from there, the same agent can later be retrieved and used
  
  
  //instantiate the basic components of the agent: driver, monitor and sequencer; the driver and the monitor are written by us, while the sequencer is taken directly from the UVM library
 // driver_agent_inputs driver_agent_inputs_inst0;
  
  monitor_agent_actuator  monitor_agent_actuator_inst0;
  
//  uvm_sequencer #(transaction) sequencer_agent_inputs_inst0;
  
  
  //declare the agent's communication port towards the scoreboard/reference model; through this port the agent sends the data collected by the monitor for checking; note that between the monitor and the agent (i.e. inside the agent) communication happens at transaction level
  uvm_analysis_port #(transaction_agent_actuator) from_monitor_agent_actuator;
  
  
  //declare a field that says whether the agent is active or passive; compared to a passive agent, an active agent also contains a driver and a sequencer
  local int is_active = 0;
  
  
  //class constructor; this is standard code for all components
  function new (string name = "actuator_agent", uvm_component parent = null);
      super.new (name, parent);
    from_monitor_agent_actuator = new("from_monitor_agent_actuator", this);
  endfunction 
  
  
  //running a verification environment consists of several phases; in the "build" phase the agent is "assembled", taking into account whether it is active or passive
  virtual function void build_phase (uvm_phase phase);
    
    //call the build_phase function of the parent class (uvm_agent)
    super.build_phase(phase);
    
    //both active and passive agents need a monitor 
    monitor_agent_actuator_inst0 = monitor_agent_actuator::type_id::create ("monitor_agent_actuator_inst0", this);
    // if the agent is active, add both the sequencer (the component that brings data into the agent) and the driver (the component that takes data from the sequencer and sends it to the DUT, adapting it to the DUT's communication protocol)
  endfunction
  
  virtual function void connect_phase (uvm_phase phase);
    
    //call the connect_phase function of the parent class (uvm_agent)
    super.connect_phase(phase);
    
    //connect the agent's port to the communication port of the monitor inside the agent (the monitor can only send data outside through the agent it belongs to)
    from_monitor_agent_actuator = monitor_agent_actuator_inst0.monitor_actuator_data_port;
    
	// the driver receives data from the sequencer and passes it to the DUT; if the agent is active, the sequencer must also be connected to the driver 
  //  if (is_active==1)begin
    //  driver_agent_actuator_inst0.seq_item_port.connect //(sequencer_agent_actuator_inst0.seq_item_export);
  //  end
    
  endfunction
  
endclass

`endif