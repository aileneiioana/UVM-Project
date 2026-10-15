`ifndef __tx_line_agent_button
`define __tx_line_agent_button

typedef class monitor_agent_button;

//include the dependencies used by the agent
`include "transaction_agent_button.sv"
`include "coverage_agent_button.sv"
`include "driver_agent_button.sv"
`include "monitor_agent_button.sv"

class button_agent extends uvm_agent;
  
  `uvm_component_utils (button_agent)//register the agent in this project's UVM factory; from there, the same agent can later be retrieved and used
  
  
  //instantiate the basic components of the agent: driver, monitor and sequencer; the driver and the monitor are written by us, while the sequencer is taken directly from the UVM library
  driver_agent_button driver_agent_button_inst0;
  
  monitor_agent_button  monitor_agent_button_inst0;
  
  uvm_sequencer #(transaction_agent_button) sequencer_agent_button_inst0;
  
  
  //declare the agent's communication port towards the scoreboard/reference model; through this port the agent sends the data collected by the monitor for checking; note that between the monitor and the agent (i.e. inside the agent) communication happens at transaction level
  uvm_analysis_port #(transaction_agent_button) from_monitor_agent_button;
  
  
  //declare a field that says whether the agent is active or passive; compared to a passive agent, an active agent also contains a driver and a sequencer
  local int is_active = 1;
  
  
  //class constructor; this is standard code for all components
  function new (string name = "button_agent", uvm_component parent = null);
      super.new (name, parent);
    from_monitor_agent_button = new("from_monitor_agent_button", this);
  endfunction 
  
  
  //running a verification environment consists of several phases; in the "build" phase the agent is "assembled", taking into account whether it is active or passive
  virtual function void build_phase (uvm_phase phase);
    
    //call the build_phase function of the parent class (uvm_agent)
    super.build_phase(phase);
    
    //both active and passive agents need a monitor 
    monitor_agent_button_inst0 = monitor_agent_button::type_id::create ("monitor_agent_button_inst0", this);
    // if the agent is active, add both the sequencer (the component that brings data into the agent) and the driver (the component that takes data from the sequencer and sends it to the DUT, adapting it to the DUT's communication protocol)
    if (is_active==1) begin
      sequencer_agent_button_inst0 = uvm_sequencer#(transaction_agent_button)::type_id::create ("sequencer_agent_button_inst0", this);
      driver_agent_button_inst0 = driver_agent_button::type_id::create ("driver_agent_button_inst0", this);
    end

  endfunction
  
  
  //running a verification environment consists of several phases; in the "connect" phase the connections between components are made; for an agent, these are the connections between its sub-components
  virtual function void connect_phase (uvm_phase phase);
    
    //call the connect_phase function of the parent class (uvm_agent)
    super.connect_phase(phase);
    
    //connect the agent's port to the communication port of the monitor inside the agent (the monitor can only send data outside through the agent it belongs to)
    from_monitor_agent_button = monitor_agent_button_inst0.monitor_button_data_port;
    
	// the driver receives data from the sequencer and passes it to the DUT; if the agent is active, the sequencer must also be connected to the driver 
    if (is_active==1)begin
      driver_agent_button_inst0.seq_item_port.connect (sequencer_agent_button_inst0.seq_item_export);
    end
    
  endfunction
  
endclass

`endif