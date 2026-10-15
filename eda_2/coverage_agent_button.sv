`ifndef __input_coverage_collector_agent_button
`define __input_coverage_collector_agent_button

//this class is used to see how many input combinations were sent to the DUT; it is only a template and will probably be modified, since in general we are not interested in hitting every possible input combination of a DUT in simulation
class coverage_agent_button extends uvm_component;
  
  //register the component in the factory
  `uvm_component_utils(coverage_agent_button)
  
  //declare the handle to the monitor that provides the data on which coverage is measured
  monitor_agent_button p_monitor;
  
  covergroup button_cg;
    option.per_instance = 1;
    coverpoint p_monitor.sampled_button_state.enable;

    
    //presumably it is of interest to see which combinations occurred between the possible inputs

  endgroup
  
  //create the covergroup; WARNING! Without the function below the covergroup could never sample data, because so far it has only been declared, not created
  function new(string name, uvm_component parent);
    super.new(name, parent);
    $cast(p_monitor, parent);
    button_cg = new();
  endfunction
  
  //another way to end a class declaration is to write "endclass: class_name"; this is useful especially when several classes are declared in the same file; however, it is recommended that each file contain no more than one class declaration
endclass: coverage_agent_button


`endif