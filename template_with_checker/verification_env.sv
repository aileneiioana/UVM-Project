`include "uvm_macros.svh"
import uvm_pkg::*;

`ifndef __verification_environment
`define __verification_environment

typedef scoreboard;//forward type definition, used to solve the cross dependency between the scoreboard and the coverage class (the scoreboard includes the coverage collector, and the coverage collector references the scoreboard)
`include "apb_agent.sv"
`include "rename_agent.sv"
`include "scoreboard.sv"

class verification_env extends uvm_env;
  
  //register the verification environment in the factory
  `uvm_component_utils(verification_env)
  
  
  //declare the interfaces from which data will be collected
  virtual apb_interface_dut monitor_apb_intf;
  virtual rename_interface_dut monitor_rename_intf;

  //declare the agents
  
  apb_agent apb_agent_inst;//active agent that drives stimuli and monitors the input interface
  rename_agent rename_agent_inst;//active agent that drives stimuli and monitors the input interface
  
  //declare the scoreboard components (only one in our case)
  scoreboard IO_scoreboard;
  
  
  //class constructor
  function new(string name, uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
  
  //create the components of the verification environment
  virtual function void build_phase (uvm_phase phase);
    
    //call the build_phase function of the parent class
    super.build_phase(phase);
    apb_agent_inst = apb_agent::type_id::create("apb_agent_inst", this);
    rename_agent_inst = rename_agent::type_id::create("rename_agent_inst", this);
    IO_scoreboard = scoreboard::type_id::create("IO_scoreboard", this);
    
    
  endfunction
  

  //make the connections between components
  function void connect_phase(uvm_phase phase);
    `uvm_info("VERIFICATION ENVIRONMENT", "The connect phase has started", UVM_NONE);
    // get the interfaces from the database; if they cannot be retrieved, an error is reported
    assert(uvm_resource_db#(virtual apb_interface_dut)::read_by_name(
      get_full_name(), "apb_interface_dut", monitor_apb_intf)) else `uvm_error("VERIFICATION ENVIRONMENT", "Could not retrieve apb_interface_dut from the UVM database");
    assert(uvm_resource_db#(virtual rename_interface_dut)::read_by_name(
      get_full_name(), "rename_interface_dut", monitor_rename_intf)) else `uvm_error("VERIFICATION ENVIRONMENT", "Could not retrieve rename_interface_dut from the UVM database");
	//connect the scoreboard to the agents' data ports
    
apb_agent_inst.from_monitor_apb.connect(IO_scoreboard.apb_data_port);
rename_agent_inst.from_monitor_rename.connect(IO_scoreboard.rename_data_port);
    `uvm_info("VERIFICATION ENVIRONMENT", "The connect phase has finished", UVM_HIGH);
  endfunction: connect_phase
  
  task run_phase(uvm_phase phase);
    //phase.raise_objection(this);
    `uvm_info("VERIFICATION ENVIRONMENT", "The run phase of the verification environment (RUN PHASE) has started.", UVM_NONE);
    begin
      //INTERFACE TRAFFIC INITIALIZATION CODE CAN BE WRITTEN HERE IF NEEDED
    end
    //phase.drop_objection(this);
  endtask
  
endclass


`endif