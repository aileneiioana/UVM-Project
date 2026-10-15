`include "uvm_macros.svh"
import uvm_pkg::*;

`ifndef __apb_coverage_collector
`define __apb_coverage_collector

//this class is used to see how many input combinations were sent to the DUT; it is only a template and will probably be modified, since in general we are not interested in hitting every possible input combination of a DUT in simulation
class coverage_apb extends uvm_component;
  
  //register the component in the factory
  `uvm_component_utils(coverage_apb)
  
  //declare the handle to the monitor that provides the data on which coverage is measured
  monitor_apb p_monitor;
  
  covergroup apb_states_cg;
    option.per_instance = 1;
    //one bin per address value: paddr is 3 bits wide (0..7), so 8 bins in total;
    //the coverage reported is the share of the 8 addresses that were actually seen on the bus
    addr_cp: coverpoint p_monitor.sampled_apb_state.addr{
        bins addr_value[] = {[0:7]};
    }
  endgroup
  
  //create the covergroup; WARNING! Without the function below the covergroup could never sample data, because so far it has only been declared, not created
  function new(string name, uvm_component parent);
    super.new(name, parent);
    $cast(p_monitor, parent);//with the use of $cast, type check will occur during runtime
    apb_states_cg = new();
  endfunction
  
endclass


`endif