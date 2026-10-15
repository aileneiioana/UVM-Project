`ifndef __actuator_intf
`define __actuator_intf

 import uvm_pkg::*; 
 `include "uvm_macros.svh"

interface actuator_interface_dut;
  logic clk_i; 
  logic reset_n;
  logic heat_o;
  logic AC_o;
  logic dehumidifier_o;
  logic blinds_o;

  //  import uvm_pkg::*;
  
    //assertions on the interface
   property temperature_control;
     @(posedge clk_i) disable iff (reset_n!==0)//while reset is active, the assertion is not evaluated
     (AC_o + heat_o <=1);//heating and air conditioning cannot be on at the same time
  endproperty
  
  assert_temperature_control: assert property (temperature_control) 
    else `uvm_error("ACTUATOR_INTERFACE", $sformatf("assertion assert_temperature_control failed: heating element has value %0d and cooling element has value %0d", heat_o, AC_o));
    TEMPERATURE_CONTROL: cover property (temperature_control);//make sure the property was exercised at least once
      
      
      
      
endinterface


`endif