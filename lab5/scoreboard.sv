`include "uvm_macros.svh"
import uvm_pkg::*;

`ifndef __ambient_scoreboard
`define __ambient_scoreboard

//declare the suffixes of the analysis imp ports used to receive data from each agent
`uvm_analysis_imp_decl(_apb)

class scoreboard extends uvm_scoreboard;
  
  //register the component in the UVM factory
  `uvm_component_utils(scoreboard)
  
  //declare the ports through which the scoreboard receives data from the agents; this data reflects the functionality of the DUT
  //note that the suffixes declared above become part of the ports' data type
  //for each declared port we specify which scoreboard type it belongs to (here there is only one class defining the scoreboard, named "scoreboard") and what data type is carried on that port
  uvm_analysis_imp_apb #(transaction_apb, scoreboard) apb_data_port;
  
  //to record the desired coverage we need to know what values came from the APB agent
  transaction_apb received_apb_transaction;
  
  bit enable;
  
   //class constructor
  function new(string name="scoreboard", uvm_component parent=null);
    //first call the parent class constructor
    super.new(name, parent);
    //create the ports
    apb_data_port = new("apb_data_port", this);
    
    
    //create the transaction needed for coverage:
    received_apb_transaction = new();    
  endfunction
  
  
  virtual function void connect_phase (uvm_phase phase);
    super.connect_phase(phase);
    
    //in the UVM "connect" phase, the monitor handle inside this monitor's coverage collector instance is connected to the monitor itself 
    ///fsm_actuator_coverage_collector.p_scoreboard = this;
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction
  
  
  //every UVM analysis imp port has a write function attached; the suffix declared at the top of this file for each port is automatically appended to the write function name, giving the names below
  //the write functions of each data port are called by the components that put data on that port (see the files where the agents are declared); here these functions are implemented, so the scoreboard knows how to react when it receives data on each port
  function void write_apb(input transaction_apb new_apb_transaction);  
    `uvm_info("SCOREBOARD", $sformatf("Received from the APB agent the transaction with the following information:\n"), UVM_LOW)
    new_apb_transaction.display_transaction_info();
   // if ((enable == 1 && posedge_for_enable_detected == 0) || negedge_for_enable_detected == 1) // only data received in the START state is accepted, not in the OFF state; also, since the agent's monitor reads data with one clock cycle of delay, reading on the enable negedge is accepted too 
    $display($sformatf("when the APB data was received, enable was %d",enable));
    
	    received_apb_transaction = new();
        received_apb_transaction = new_apb_transaction.copy();
      
  endfunction : write_apb
  
          
  function check_data_match();
  //checker
  endfunction
endclass
`endif