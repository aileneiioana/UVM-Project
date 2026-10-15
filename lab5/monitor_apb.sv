`include "uvm_macros.svh"
import uvm_pkg::*;

`ifndef __apb_monitor
`define __apb_monitor
//`include "transaction_traffic_lights.sv"

class monitor_apb extends uvm_monitor;
  
  //register the monitor in the UVM factory
  `uvm_component_utils (monitor_apb) 
  
  //declare the coverage collector that will record the values of the interface signals read by the monitor
  coverage_apb apb_coverage_collector; 
  
  //create the port through which the monitor sends out (in our case to the scoreboard), via the agent, the transactions extracted from the interface traffic
  uvm_analysis_port #(transaction_apb) monitor_apb_data_port;
  
  //declaration of the interface from which the monitor collects its data
  //virtual apb_interface monitor_apb_intf;
  virtual apb_interface_dut monitor_apb_intf;
  
  transaction_apb sampled_apb_state, aux_tr_apb;
  
  //class constructor
  function new(string name = "monitor_apb", uvm_component parent = null);
    
    //first call the parent class constructor
    super.new(name, parent);
    
    //create the port through which the monitor sends out, via the agent, the data it collected from the interface traffic
    monitor_apb_data_port = new("monitor_apb_data_port",this);
    
    //create the coverage collector (on creation, the coverage collector's constructor is called)
    
    apb_coverage_collector = coverage_apb::type_id::create ("apb_coverage_collector", this);
    
    
    //create the object (transaction) that will hold the data collected from the interface on every clock cycle
    sampled_apb_state = transaction_apb::type_id::create("new_data");
    
    aux_tr_apb = transaction_apb::type_id::create("new_data_copy");
  endfunction
  
  
  //get from the database the interface the monitor will connect to in order to read data, and bind it to the interface handle the monitor already contains
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    if (!uvm_config_db#(virtual apb_interface_dut)::get(this, "", "apb_interface_dut", monitor_apb_intf))
        `uvm_fatal("MONITOR_APB", "Could not access the monitor interface")
  endfunction
        
  
  
  virtual function void connect_phase (uvm_phase phase);
    super.connect_phase(phase);
    
    //in the UVM "connect" phase, the monitor handle inside this monitor's coverage collector instance is connected to the monitor itself 
	apb_coverage_collector.p_monitor = this;
    
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    
    forever begin
      
      //!!!!wait until the data is valid
      wait(monitor_apb_intf.psel && monitor_apb_intf.penable); 
      //I want to sample valid_i only on falling clock edges
      @(negedge monitor_apb_intf.pclk); 
      //sample the data from the DUT output interface
      sampled_apb_state.addr = monitor_apb_intf.paddr;
    
      aux_tr_apb = sampled_apb_state.copy();//I don't want to use the sampled_apb_state handle to send the data, because its contents change and the scoreboard would read different data 
      
       //the transaction holding the data collected from the interface is made available on the monitor's port
      monitor_apb_data_port.write(aux_tr_apb); 
      `uvm_info("MONITOR_APB", $sformatf("Received the transaction with the following information:"), UVM_NONE)
      aux_tr_apb.display_transaction_info();
	  
      //sample the values of the output signals for coverage
      apb_coverage_collector.apb_states_cg.sample();
      
	  @(negedge monitor_apb_intf.pclk); //this wait was added because sometimes one transaction was interpreted as two identical back-to-back transactions (valid was read as 1 on two consecutive clock edges); in the current implementation two transactions cannot come back to back
      
      
    end//forever begin
  endtask
  
  
endclass: monitor_apb

`endif