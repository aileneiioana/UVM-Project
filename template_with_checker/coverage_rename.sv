`include "uvm_macros.svh"
import uvm_pkg::*;

`ifndef __rename_coverage_collector
`define __rename_coverage_collector

//this class is used to see how many input combinations were sent to the DUT; it is only a template and will probably be modified, since in general we are not interested in hitting every possible input combination of a DUT in simulation
class coverage_rename extends uvm_component;
  
  //register the component in the factory
  `uvm_component_utils(coverage_rename)
  
  //declare the handle to the monitor that provides the data on which coverage is measured
  monitor_rename p_monitor;
  
  covergroup rename_states_cg;
    option.per_instance = 1;
    //one bin per address value: addr is 3 bits wide (0..7), so 8 bins in total
    addr_cp: coverpoint p_monitor.sampled_rename_state.addr{
        bins addr_value[] = {[0:7]};
    }
    //irq must be seen both low and high; irq = 1 needs an APB access with the same address in the same cycle
    irq_cp: coverpoint p_monitor.sampled_rename_state.irq{
        bins irq_low  = {0};
        bins irq_high = {1};
    }
  endgroup
  
  //create the covergroup; WARNING! Without the function below the covergroup could never sample data, because so far it has only been declared, not created
  function new(string name, uvm_component parent);
    super.new(name, parent);
    $cast(p_monitor, parent);//with the use of $cast, type check will occur during runtime
    rename_states_cg = new();
  endfunction
  
endclass


`endif