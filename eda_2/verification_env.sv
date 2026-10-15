`ifndef __verification_environment
`define __verification_environment

typedef scoreboard;//forward type definition, used to solve the cross dependency between the scoreboard and the coverage class (the scoreboard includes the coverage collector "coverage_sensor_values_read_ref", and the coverage collector references the scoreboard)
`include "sensor_agent.sv"
`include "actuator_agent.sv"
`include "button_agent.sv"
`include "coverage_sensor_values_read_ref.sv"
`include "scoreboard.sv"

class verification_env extends uvm_env;
  
  //register the verification environment in the factory
  `uvm_component_utils(verification_env)
  
  
  //declare the interfaces from which data will be collected
  virtual actuator_interface_dut monitor_actuator_intf;
  virtual button_interface_dut monitor_button_intf;
  virtual sensor_interface_dut monitor_sensor_intf;
  
  //declare the agents
  button_agent button_agent_inst;//active agent that drives stimuli and monitors the input interface
  
  sensor_agent sensor_agent_inst;//active agent that drives stimuli and monitors the input interface
  
  actuator_agent actuator_agent_inst;//passive agent that monitors the traffic on the DUT output interface (the actuator outputs)
  
  
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
    button_agent_inst = button_agent::type_id::create("button_agent_inst", this);
    sensor_agent_inst = sensor_agent::type_id::create("sensor_agent_inst", this);
    actuator_agent_inst = actuator_agent::type_id::create("actuator_agent_inst", this);
    IO_scoreboard = scoreboard::type_id::create("IO_scoreboard", this);
    
    
  endfunction
  

  //make the connections between components
  function void connect_phase(uvm_phase phase);
    `uvm_info("VERIFICATION ENVIRONMENT", "The connect phase has started", UVM_NONE);
    // get the interfaces from the database; if they cannot be retrieved, an error is reported
    assert(uvm_resource_db#(virtual actuator_interface_dut)::read_by_name(
      get_full_name(), "actuator_interface_dut", monitor_actuator_intf)) else `uvm_error("VERIFICATION ENVIRONMENT", "Could not retrieve actuator_interface_dut from the UVM database");
    
    assert(uvm_resource_db#(virtual button_interface_dut)::read_by_name(
      get_full_name(), "button_interface_dut", monitor_button_intf)) else `uvm_error("VERIFICATION ENVIRONMENT", "Could not retrieve button_interface_dut from the UVM database");
    
    assert(uvm_resource_db#(virtual sensor_interface_dut)::read_by_name(
      get_full_name(), "sensor_interface_dut", monitor_sensor_intf)) else `uvm_error("VERIFICATION ENVIRONMENT", "Could not retrieve sensor_interface_dut from the UVM database");
    
	//connect the scoreboard to the agents' data ports
    
button_agent_inst.from_monitor_agent_button.connect(IO_scoreboard.button_data_port);
    
sensor_agent_inst.from_monitor_sensor.connect(IO_scoreboard.sensor_data_port);
    
actuator_agent_inst.from_monitor_agent_actuator.connect(IO_scoreboard.actuator_data_port);

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