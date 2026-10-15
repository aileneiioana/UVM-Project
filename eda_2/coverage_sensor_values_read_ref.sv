//this coverage component records data coming from the reference model implemented in the scoreboard
//it records which sensor value ranges were processed while the DUT was enabled
`ifndef __fsm_coverage_collector
`define __fsm_coverage_collector
class coverage_sensor_values_read_ref extends uvm_component;
  
  //register the component in the factory
  `uvm_component_utils(coverage_sensor_values_read_ref)
  
  //declare the handle to the scoreboard that provides the data on which coverage is measured
  scoreboard p_scoreboard;
  
  
  
  covergroup processed_data_cg;
    option.per_instance = 1;
    module_state: coverpoint p_scoreboard.enable;
    temperature_val: coverpoint p_scoreboard.received_sensor_transaction.temperature{
      option.weight = 0;//I am not interested in recording the values of this coverpoint on its own (they are already collected by the collector in the agent's monitor); I only want to use its data when computing cross coverage
      bins value_ranges[5] = {[0:40]};//the range of possible sensor values is split into 5 consecutive, equally sized sub-ranges (here roughly: 0:7, 8:15, 16:23, 24:31, 32:40); if at least one value from each sub-range is hit, all desired values are considered covered
    }
    humidity_val: coverpoint p_scoreboard.received_sensor_transaction.humidity{
      option.weight = 0;//I am not interested in recording the values of this coverpoint on its own (they are already collected by the collector in the agent's monitor); I only want to use its data when computing cross coverage
      bins value_ranges[5] = {[0:100]};//the range of possible sensor values is split into 5 consecutive, equally sized sub-ranges (here roughly: 0:20, 21:40, 41:60, 61:80, 81:100); if at least one value from each sub-range is hit, all desired values are considered covered
    }
    light_intensity_val: coverpoint p_scoreboard.received_sensor_transaction.luminous_intensity{
      option.weight = 0;//I am not interested in recording the values of this coverpoint on its own (they are already collected by the collector in the agent's monitor); I only want to use its data when computing cross coverage
      bins value_ranges[5] = {[0:900]};//the range of possible sensor values is split into 5 consecutive, equally sized sub-ranges (here roughly: 0:179, 180:359, 360:539, 540:719, 720:900); if at least one value from each sub-range is hit, all desired values are considered covered
    }
    
    //roughly, I want to see how many sensor values were processed by the DUT (the DUT reads the values only when enable is 1)
    temperature_cross: cross module_state, temperature_val{
      ignore_bins ignore_disabled_module_values = temperature_cross with (module_state == 0);//I am not interested in recording sensor values when they are not read by the DUT
  }
    humidity_cross: cross module_state, humidity_val{
       ignore_bins ignore_disabled_module_values = humidity_cross with (module_state == 0);//I am not interested in recording sensor values when they are not read by the DUT
    }
    luminosity_cross: cross module_state, light_intensity_val{
       ignore_bins ignore_disabled_module_values = luminosity_cross with (module_state == 0);//I am not interested in recording sensor values when they are not read by the DUT
    }
  endgroup
  
  //create the covergroup; WARNING! Without the function below the covergroup could never sample data, because so far it has only been declared, not created
  function new(string name, uvm_component parent);
    super.new(name, parent);
    $cast(p_scoreboard, parent);
    processed_data_cg = new();
  endfunction
  
endclass

`endif