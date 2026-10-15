`include "uvm_macros.svh"
import uvm_pkg::*;

`ifndef __apb_coverage_collector
`define __apb_coverage_collector

//this class is used to see how many input combinations were sent to the DUT; it is only a template and will probably be modified, since in general we are not interested in hitting every possible input combination of a DUT in simulation
class apb_coverage extends uvm_component;
  
  //register the component in the factory
  `uvm_component_utils(apb_coverage)
  
  //declare the handle to the monitor that provides the data on which coverage is measured
  apb_monitor p_monitor;
  
  covergroup apb_states_cg;
    option.per_instance = 1;
    //three bins: the minimum address (0), the medium addresses (1 to 6) and the maximum address (7)
    addr_cp: coverpoint p_monitor.sampled_apb_state.addr{
        bins min_addr    = {0};
        bins medium_addr = {[1:6]};
        bins max_addr    = {7};
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