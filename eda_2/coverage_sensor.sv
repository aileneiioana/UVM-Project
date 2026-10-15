`ifndef __sensor_coverage_collector
`define __sensor_coverage_collector

//this class is used to see how many input combinations were sent to the DUT; it is only a template and will probably be modified, since in general we are not interested in hitting every possible input combination of a DUT in simulation
class coverage_sensor extends uvm_component;
  
  //register the component in the factory
  `uvm_component_utils(coverage_sensor)
  
  //declare the handle to the monitor that provides the data on which coverage is measured
  monitor_sensor p_monitor;
  
  covergroup sensor_states_cg;
    option.per_instance = 1;
    coverpoint p_monitor.sampled_sensor_state.temperature{
        bins heating_on = {[0:21]};
        bins temperature_limit_val = {22};
      	bins heating_off = {[23:40]};
    }
    coverpoint p_monitor.sampled_sensor_state.humidity{
        bins dehumidifier_off = {[0:34]};
        bins off_limit_value = {35};
        bins on_limit_value = {50};
        bins dehumidifier_on ={[51:100]};
    }
    coverpoint p_monitor.sampled_sensor_state.luminous_intensity{
        bins blinds_open = {[0:199]};
        bins open_limit_value = {200};
        bins close_limit_value = {700};
        bins blinds_close = {[701:900]};
    }
  endgroup
  
  //create the covergroup; WARNING! Without the function below the covergroup could never sample data, because so far it has only been declared, not created
  function new(string name, uvm_component parent);
    super.new(name, parent);
    $cast(p_monitor, parent);//with the use of $cast, type check will occur during runtime
    sensor_states_cg = new();
  endfunction
  
endclass


`endif