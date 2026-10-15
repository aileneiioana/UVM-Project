`include "uvm_macros.svh"
import uvm_pkg::*;

`ifndef __rename_agent
`define __rename_agent

//include the dependencies used by the agent
typedef class rename_monitor;//forward type definition, used to solve the cross dependency between the monitor and the coverage class (the monitor includes the coverage collector, and the coverage collector references the monitor)
`include "rename_transaction.sv"
`include "rename_coverage.sv"
`include "rename_driver.sv"
`include "rename_monitor.sv"


class rename_agent extends uvm_agent;
  
  `uvm_component_utils (rename_agent)//register the agent in this project's UVM factory; from there, the same agent can later be retrieved and used
  
  
  //instantiate the basic components of the agent: driver, monitor and sequencer; the driver and the monitor are written by us, while the sequencer is taken directly from the UVM library
  rename_driver rename_driver_inst0;
  
  rename_monitor  rename_monitor_inst0;
  
  uvm_sequencer #(rename_transaction) rename_sequencer_inst0;
  
  
  //declare the agent's communication port towards the scoreboard/reference model; through this port the agent sends the data collected by the monitor for checking; note that between the monitor and the agent (i.e. inside the agent) communication happens at transaction level
  uvm_analysis_port #(rename_transaction) from_monitor_rename; //from_monitor_agent_traffic_lights;
  
  
  //declare a field that says whether the agent is active or passive; compared to a passive agent, an active agent also contains a driver and a sequencer
  local int is_active = 1;  //0 means passive agent; 1 means active agent
  
  
  //class constructor; this is standard code for all components
  function new (string name = "rename_agent", uvm_component parent = null);
      super.new (name, parent);
    from_monitor_rename = new("from_monitor_rename", this);
  endfunction 
  
  
  //running a verification environment consists of several phases; in the "build" phase the agent is "assembled", taking into account whether it is active or passive
  virtual function void build_phase (uvm_phase phase);
    
    //call the build_phase function of the parent class (uvm_agent)
    super.build_phase(phase);
    
    //both active and passive agents need a monitor 
    rename_monitor_inst0 = rename_monitor::type_id::create ("rename_monitor_inst0", this);
    // if the agent is active, add both the sequencer (the component that brings data into the agent) and the driver (the component that takes data from the sequencer and sends it to the DUT, adapting it to the DUT's communication protocol)
    if (is_active==1) begin
      rename_sequencer_inst0 = uvm_sequencer#(rename_transaction)::type_id::create ("rename_sequencer_inst0", this);
      rename_driver_inst0 = rename_driver::type_id::create ("rename_driver_inst0", this);
    end

  endfunction
  
  
  //running a verification environment consists of several phases; in the "connect" phase the connections between components are made; for an agent, these are the connections between its sub-components
  virtual function void connect_phase (uvm_phase phase);
    
    //call the connect_phase function of the parent class (uvm_agent)
    super.connect_phase(phase);
    
    //connect the agent's port to the communication port of the monitor inside the agent (the monitor can only send data outside through the agent it belongs to)
    from_monitor_rename = rename_monitor_inst0.monitor_rename_data_port;
    
	// the driver receives data from the sequencer and passes it to the DUT; if the agent is active, the sequencer must also be connected to the driver 
    if (is_active==1)begin
      rename_driver_inst0.seq_item_port.connect (rename_sequencer_inst0.seq_item_export);
    end
    
  endfunction
  
endclass

`endif