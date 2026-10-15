`ifndef __sensor_intf
`define __sensor_intf

interface sensor_interface_dut;
  logic  clk_i; 
  logic  reset_n;
  logic [9:0] luminous_intensity_i;
  logic [5:0] temperature_i;
  logic [6:0] humidity_i;
  logic  valid_i;
  logic  ready_o;
  
 import uvm_pkg::*;
      
      

          
          
   property temperature_interval;
     @(posedge clk_i) disable iff (reset_n==1)//while reset is active, the assertion is not evaluated
          temperature_i >= 0 && temperature_i <= 40;//the temperature range is [0,40]
  endproperty
  
     assert_temperature_interval: assert property (temperature_interval) 
       else `uvm_error("SENSOR_INTERFACE", $sformatf("assertion assert_temperature_interval failed: temperature has value %0d", temperature_i));
       TEMPERATURE_INTERVAL: cover property (temperature_interval);//make sure the property was exercised at least once
      
              
              
              
              
   property humidity_interval;
     @(posedge clk_i) disable iff (reset_n==1)//while reset is active, the assertion is not evaluated
        humidity_i >= 0 && humidity_i <= 100;//the humidity range is [0,100]
  endproperty
  
     assert_humidity_interval: assert property (humidity_interval) 
       else `uvm_error("SENSOR_INTERFACE", $sformatf("assertion assert_humidity_interval failed: humidity has value %0d", humidity_i));
       HUMIDITY_INTERVAL: cover property (humidity_interval);//make sure the property was exercised at least once
      
                  
                  
    property luminous_intensity_interval;
      @(posedge clk_i) disable iff (reset_n==1)//while reset is active, the assertion is not evaluated
         luminous_intensity_i >= 0 && luminous_intensity_i <= 900;//the luminous intensity range is [0,900]
  endproperty
  
      assert_luminous_intensity_interval: assert property (luminous_intensity_interval) 
        else `uvm_error("SENSOR_INTERFACE", $sformatf("assertion assert_luminous_intensity_interval failed: luminous intensity has value %0d", luminous_intensity_i));
        LUMINOUS_INTENSITY_INTERVAL: cover property (luminous_intensity_interval);//make sure the property was exercised at least once
      
endinterface


`endif