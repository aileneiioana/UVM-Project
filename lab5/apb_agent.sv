`include "uvm_macros.svh"
import uvm_pkg::*;

`ifndef __apb_agent
`define __apb_agent

//include the dependencies used by the agent
typedef class monitor_apb;//forward type definition, used to solve the cross dependency between the monitor and the coverage class (the monitor includes the coverage collector, and the coverage collector references the monitor)
`include "transaction_apb.sv"
`include "coverage_apb.sv"
`include "driver_agent_apb.sv"
`include "monitor_apb.sv"


class apb_agent extends uvm_agent;
  
  `uvm_component_utils (apb_agent)//register the agent in this project's UVM factory; from there, the same agent can later be retrieved and used
  
  
  //instantiate the basic components of the agent: driver, monitor and sequencer; the driver and the monitor are written by us, while the sequencer is taken directly from the UVM library
  driver_agent_apb driver_agent_apb_inst0;
  
  monitor_apb  monitor_apb_inst0;
  
  uvm_sequencer #(transaction_apb) sequencer_agent_apb_inst0;
  
  
  //declare the agent's communication port towards the scoreboard/reference model; through this port the agent sends the data collected by the monitor for checking; note that between the monitor and the agent (i.e. inside the agent) communication happens at transaction level
  uvm_analysis_port #(transaction_apb) from_monitor_apb; //from_monitor_agent_traffic_lights;
  
  
  //declare a field that says whether the agent is active or passive; compared to a passive agent, an active agent also contains a driver and a sequencer
  local int is_active = 1;  //0 means passive agent; 1 means active agent
  
  
  //class constructor; this is standard code for all components
  function new (string name = "apb_agent", uvm_component parent = null);
      super.new (name, parent);
    from_monitor_apb = new("from_monitor_apb", this);
  endfunction 
  
  
  //running a verification environment consists of several phases; in the "build" phase the agent is "assembled", taking into account whether it is active or passive
  virtual function void build_phase (uvm_phase phase);
    
    //call the build_phase function of the parent class (uvm_agent)
    super.build_phase(phase);
    
    //both active and passive agents need a monitor 
    monitor_apb_inst0 = monitor_apb::type_id::create ("monitor_apb_inst0", this);
    // if the agent is active, add both the sequencer (the component that brings data into the agent) and the driver (the component that takes data from the sequencer and sends it to the DUT, adapting it to the DUT's communication protocol)
    if (is_active==1) begin
      sequencer_agent_apb_inst0 = uvm_sequencer#(transaction_apb)::type_id::create ("sequencer_agent_apb_inst0", this);
      driver_agent_apb_inst0 = driver_agent_apb::type_id::create ("driver_agent_apb_inst0", this);
    end

  endfunction
  
  
  //running a verification environment consists of several phases; in the "connect" phase the connections between components are made; for an agent, these are the connections between its sub-components
  virtual function void connect_phase (uvm_phase phase);
    
    //call the connect_phase function of the parent class (uvm_agent)
    super.connect_phase(phase);
    
    //connect the agent's port to the communication port of the monitor inside the agent (the monitor can only send data outside through the agent it belongs to)
    from_monitor_apb = monitor_apb_inst0.monitor_apb_data_port;
    
	// the driver receives data from the sequencer and passes it to the DUT; if the agent is active, the sequencer must also be connected to the driver 
    if (is_active==1)begin
      driver_agent_apb_inst0.seq_item_port.connect (sequencer_agent_apb_inst0.seq_item_export);
    end
    
  endfunction
  
endclass

`endif