`include "uvm_macros.svh"
import uvm_pkg::*;

`ifndef __verification_environment
`define __verification_environment

typedef scoreboard;//pre-declarare a clasei scoreboard, ca sa poata fi folosita inainte de definitia ei
`include "apb_agent.sv"
`include "rename_agent.sv"
`include "scoreboard.sv"

class verification_env extends uvm_env;
  
  //se adauga mediul de verificare in baza de date
  `uvm_component_utils(verification_env)
  
  
  //se declara interfetele de pe care se vor prelua date
  virtual apb_interface_dut monitor_apb_intf;
  virtual rename_interface_dut monitor_rename_intf;

  //se declara agentii
  
  apb_agent apb_agent_inst;//agentul activ care furnizeaza stimuli si monitorizeaza interfata de intrare
  rename_agent rename_agent_inst;//agentul activ care furnizeaza stimuli si monitorizeaza interfata de intrare
  
  //se declara componentele de tip scoreboard (una singura in cazul nostru)
  scoreboard IO_scoreboard;
  
  
  //constructorul clasei
  function new(string name, uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
  
  //se creaza componentele mediului de verificare
  virtual function void build_phase (uvm_phase phase);
    
    //se apeleaza functia build_phase din clasa parinte
    super.build_phase(phase);
    apb_agent_inst = apb_agent::type_id::create("apb_agent_inst", this);
    rename_agent_inst = rename_agent::type_id::create("rename_agent_inst", this);
    IO_scoreboard = scoreboard::type_id::create("IO_scoreboard", this);
    
    
  endfunction
  

  //se creaza conexiunile intre componente
  function void connect_phase(uvm_phase phase);
    `uvm_info("VERIFICATION ENVIRONMENT", "The connect phase has started", UVM_NONE);
    // se preiau interfetele din baza de date; daca nu se pot prelua interfetele, se va da eroare
    assert(uvm_resource_db#(virtual apb_interface_dut)::read_by_name(
      get_full_name(), "apb_interface_dut", monitor_apb_intf)) else `uvm_error("VERIFICATION ENVIRONMENT", "Could not retrieve apb_interface_dut from the UVM database");
    assert(uvm_resource_db#(virtual rename_interface_dut)::read_by_name(
      get_full_name(), "rename_interface_dut", monitor_rename_intf)) else `uvm_error("VERIFICATION ENVIRONMENT", "Could not retrieve rename_interface_dut from the UVM database");
	//conectarea scoreboardului la porturile de date ale agentilor
    
apb_agent_inst.from_monitor_apb.connect(IO_scoreboard.apb_data_port);
rename_agent_inst.from_monitor_rename.connect(IO_scoreboard.rename_data_port);
    `uvm_info("VERIFICATION ENVIRONMENT", "The connect phase has finished", UVM_HIGH);
  endfunction: connect_phase
  
  task run_phase(uvm_phase phase);
    //phase.raise_objection(this);
    `uvm_info("VERIFICATION ENVIRONMENT", "The run phase of the verification environment (RUN PHASE) has started.", UVM_NONE);
    begin
      //AICI SE POATE SCRIE UN COD DE INITIALIZARE A TRAFICULUI PE INTERFETE DACA ESTE NEVOIE
    end
    //phase.drop_objection(this);
  endtask
  
endclass


`endif