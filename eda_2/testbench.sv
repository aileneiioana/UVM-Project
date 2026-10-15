`include "uvm_macros.svh"
import uvm_pkg::*;

`define CLOCK_PERIOD 10


`ifndef MIN_NUM_TRANSACTIONS //minimum number of transactions that will be generated on the input interface
  `define MIN_NUM_TRANSACTIONS 10
`endif

//`define DEBUG      //macro used to enable messages that we consider necessary only for debugging

//set the meaning of the simulator time units
`timescale 1ns/1ns

//include the files the top module needs access to

//`include "actuator_interface.sv"
//`include "button_interface.sv"
//`include "sensor_interface_dut.sv"
//`include "test_ambient_base.sv"
//`include "test_limit_values.sv"
//`include "test_temperature_regulation.sv"
//`include "test_humidity_regulation.sv"
//`include "test_light_intensity_values.sv"
//`include "test_sensor_functionality.sv"
//`include "test_multiple_button_presses.sv"
//`include "test_fast_button_presses.sv"
//`include "test_ambient_full.sv"
//`include "test_frequent_button_presses.sv"


// Code your testbench here
// or browse Examples
module top();
  logic clk;
  parameter DATA_WIDTH = 6;
	wire reset_n;
	wire enable;
	wire valid;
	wire [DATA_WIDTH-1:0] temperature;
	wire [DATA_WIDTH  :0] humidity;
	wire [DATA_WIDTH+3:0] luminous;
	wire heat;
	wire AC;
	wire dehumidifier;
	wire blinds;
	wire ready;
  
  //create the interface instances (one per agent); the interface signals are connected to the signals of the top module
  sensor_interface_dut intf_sensor();
  assign intf_sensor.clk_i                = clk;
  assign reset_n = intf_sensor.reset_n;
  assign valid = intf_sensor.valid_i;
  assign intf_sensor.ready_o              = ready;
  assign luminous = intf_sensor.luminous_intensity_i;
  assign temperature = intf_sensor.temperature_i;
  assign humidity = intf_sensor.humidity_i;
                              
  
  button_interface_dut intf_button();
   assign intf_button.clk_i = clk;
   assign enable = intf_button.enable_i;
                                 
  actuator_interface_dut intf_actuator();
  assign intf_actuator.clk_i = clk;
  assign intf_actuator.heat_o = heat;
  assign intf_actuator.AC_o = AC;
  assign intf_actuator.dehumidifier_o = dehumidifier;
  assign intf_actuator.blinds_o = blinds;
  
  
  initial begin
    //the 2 lines below enable waveform viewing (to view waveforms, the "Open EPWave after run" option in the "Tools & Simulators" section on the left of the page must also be checked)
    $dumpfile("dump.vcd");
    $dumpvars;
    //generate the clock
	clk = 1;
	forever #(`CLOCK_PERIOD/2)  clk <= ~clk;
	end
  
   initial
  	begin
      //store the interface instances in the UVM database
      uvm_config_db#(virtual sensor_interface_dut)::set(null, "*", "sensor_interface_dut", intf_sensor);
      uvm_config_db#(virtual button_interface_dut)::set(null, "*", "button_interface_dut", intf_button);
      uvm_config_db#(virtual actuator_interface_dut)::set(null, "*", "actuator_interface_dut", intf_actuator);

      //run the desired test
      run_test("test_ambient_full");
  	end
  
//  initial //the free simulator cannot print more than 5000 lines of messages
//    begin
//      #2000
//      $finish();
//    end

  // instantiate the DUT, connecting the signals of the top module to its ports
  ambient DUT(
	.clk_i                 (clk         ),
	.reset_n               (reset_n     ),
	.enable_i              (enable      ),
	.temperature_i         (temperature ),
	.humidity_i            (humidity    ),
	.luminous_intensity_i  (luminous    ),
	.valid_i			   (valid       ),
	.heat_o		           (heat        ),
    .AC_o                  (AC          ),
	.dehumidifier_o        (dehumidifier),
	.blinds_o              (blinds      ),
	.ready_o               (ready       )
);


endmodule