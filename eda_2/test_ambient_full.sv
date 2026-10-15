`include "uvm_macros.svh"
//include the files the test needs access to
`include "verification_env.sv"

`include "fast_switch_sequence.sv"
`include "button_presses_sequence.sv"
`include "button_inputs_sequence.sv"
`include "frequent_button_presses_sequence.sv"

`include "sensor_temperature_sequence.sv"
`include "sensor_humidity_sequence.sv"
`include "sensor_random_sequence.sv"
`include "sensor_limit_values_sequence.sv"
`include "sensor_light_intensity_sequence.sv"


class test_ambient_full extends uvm_test;
  `uvm_component_utils(test_ambient_full)
  
  
  //test constructor
  function new(string name = "test_ambient_full", uvm_component parent=null);
    super.new(name, parent);
  endfunction
  
  
  
  //instantiate the verification environment
  verification_env ambient_verif_env;
  
  //instantiate the sequences used by button_agent and sensor_agent
  button_inputs_sequence button_inputs_seq;
  fast_switch_sequence fast_switch_seq;
  button_presses_sequence button_presses_seq;
 frequent_button_presses_sequence frequent_button_presses_seq;
  
  sensor_temperature_sequence sensor_temperature_seq;
  sensor_humidity_sequence sensor_humidity_seq;
  sensor_random_sequence sensor_random_seq;
  sensor_limit_values_sequence sensor_limit_values_seq;
  sensor_light_intensity_sequence sensor_light_intensity_seq;

  
  
  
  //declare the virtual interfaces of the verification environment; they will later be bound to the real interfaces instantiated in the top module
  //virtual inputs_interface_dut vif_inputs_dut;
  //virtual traffic_lights_interface vif_traffic_lights
  virtual actuator_interface_dut vif_actuator_dut;
  virtual button_interface_dut vif_button_dut;
  virtual sensor_interface_dut vif_sensor_dut;
  
   function void start_of_simulation_phase(uvm_phase phase);
    super.start_of_simulation_phase(phase);
    this.print();
    uvm_top.print_topology();
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    //create the verification environment declared above
    ambient_verif_env = verification_env::type_id::create("ambient_verif_env", this);
    
    //Get virtual IF handle from top_level and pass it to everything in env level
    if (!uvm_config_db#(virtual button_interface_dut)::get(this, "", "button_interface_dut", vif_button_dut))
      `uvm_fatal("TEST", "Could not get the virtual interface type button_interface_dut from the UVM database to create vif_button_dut")
      
    if (!uvm_config_db#(virtual sensor_interface_dut)::get(this, "", "sensor_interface_dut", vif_sensor_dut))
      `uvm_fatal("TEST", "Could not get the virtual interface type sensor_interface_dut from the UVM database to create vif_sensor_dut")
      
    if (!uvm_config_db#(virtual actuator_interface_dut)::get(this, "", "actuator_interface_dut", vif_actuator_dut))
      `uvm_fatal("TEST", "Could not get the virtual interface type actuator_interface_dut from the UVM database to create vif_actuator_dut")
      
      
      //the virtual interfaces are used to create the connections with the agents
    uvm_config_db#(virtual button_interface_dut)::set(this, "ambient_verif_env.button_agent_inst.*", "button_interface_dut",vif_button_dut);
    uvm_config_db#(virtual sensor_interface_dut)::set(this, "ambient_verif_env.sensor_agent_inst.*", "sensor_interface_dut",vif_sensor_dut);
    uvm_config_db#(virtual actuator_interface_dut)::set(this, "ambient_verif_env.actuator_agent_inst.*", "actuator_interface_dut",vif_actuator_dut);
    
    //create the input data sequences, then randomize the fields declared with the "rand" keyword inside each sequence class
   
    button_inputs_seq =  button_inputs_sequence::type_id::create("button_inputs_seq");
    button_inputs_seq.randomize();
    
    fast_switch_seq = fast_switch_sequence::type_id::create("fast_switch_seq");
    fast_switch_seq.randomize();
    
    button_presses_seq = button_presses_sequence::type_id::create("button_presses_seq");
    button_presses_seq.randomize();
    
    frequent_button_presses_seq  =  frequent_button_presses_sequence::type_id::create("frequent_button_presses_seq");
    frequent_button_presses_seq.randomize();
    
    sensor_temperature_seq = sensor_temperature_sequence::type_id::create("sensor_temperature_seq");
    sensor_temperature_seq.randomize();
    
    sensor_humidity_seq =  sensor_humidity_sequence ::type_id::create("sensor_humidity_seq");
    sensor_humidity_seq.randomize();
    
    sensor_random_seq = sensor_random_sequence::type_id::create("sensor_random_seq");
    sensor_random_seq.randomize();
    
    sensor_limit_values_seq = sensor_limit_values_sequence::type_id::create("sensor_limit_values_seq");
    sensor_limit_values_seq.randomize();
    
    sensor_light_intensity_seq = sensor_light_intensity_sequence::type_id::create("sensor_light_intensity_seq");
    sensor_light_intensity_seq.randomize();
    
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    
    //call the run_phase function of the parent class
    super.run_phase(phase);
    
    //raise an objection signalling that an activity has started; until it is dropped, the simulator knows it must not end the "run" phase of the test; therefore we must make sure to drop the objection at the end of this task
    phase.raise_objection(this);
    
    //assert the reset signals in the interfaces
    apply_reset();
    `uvm_info("test_ambient_full", "real execution begins", UVM_NONE);
    
    //inside the fork/join block the sequences of the verification environment can be started in parallel
    fork
      begin
     `ifdef DEBUG
        $display("starting the sequence for the active agent button_agent");
      `endif;       
button_inputs_seq.start(ambient_verif_env.button_agent_inst.sequencer_agent_button_inst0);     fast_switch_seq.start(ambient_verif_env.button_agent_inst.sequencer_agent_button_inst0);
button_presses_seq.start(ambient_verif_env.button_agent_inst.sequencer_agent_button_inst0);      frequent_button_presses_seq.start(ambient_verif_env.button_agent_inst.sequencer_agent_button_inst0);
      `ifdef DEBUG
        $display("finished running the sequence for the active agent button_agent");
      `endif;
      end
      
      begin 
      `ifdef DEBUG
        $display("starting the sequence for the active agent sensor_agent");
      `endif;
        sensor_temperature_seq.start(ambient_verif_env.sensor_agent_inst.sequencer_agent_sensor_inst0);     sensor_humidity_seq.start(ambient_verif_env.sensor_agent_inst.sequencer_agent_sensor_inst0);       sensor_random_seq.start(ambient_verif_env.sensor_agent_inst.sequencer_agent_sensor_inst0);      sensor_limit_values_seq.start(ambient_verif_env.sensor_agent_inst.sequencer_agent_sensor_inst0);      sensor_light_intensity_seq.start(ambient_verif_env.sensor_agent_inst.sequencer_agent_sensor_inst0);
      `ifdef DEBUG
        $display("finished running the sequence for the active agent sensor_agent");
      `endif;
      
    
      end
    join
    //after the sequences sending stimuli to the DUT have finished, all input signals are set to 0
    @(posedge vif_sensor_dut.clk_i);
    vif_sensor_dut.temperature_i <= 0;
    vif_sensor_dut.humidity_i <= 0;
    vif_sensor_dut.luminous_intensity_i <= 0;
    vif_sensor_dut.valid_i <= 0;
   // vif_sensor_dut.ready_o <= 0;
    vif_button_dut.enable_i <= 0;
    #100//wait another 100 time units before dropping the objection, which will allow the simulator to end the activity
	//drop the objection 
    phase.drop_objection(this);
    endtask
  
  //reset the traffic on the interfaces
  virtual task apply_reset();
    vif_sensor_dut.reset_n <= 1;
    vif_sensor_dut.temperature_i <= 0;
    vif_sensor_dut.humidity_i <= 0;
    vif_sensor_dut.luminous_intensity_i <= 0;
    vif_sensor_dut.valid_i <= 0;
   // vif_sensor_dut.ready_o <= 0;
    vif_button_dut.enable_i <= 0;
    `ifdef DEBUG
    $display("reset asserted");
    `endif;
    repeat(15) @(posedge vif_sensor_dut.clk_i);
    vif_sensor_dut.reset_n <= 0;
    `ifdef DEBUG
    $display("%t reset deasserted", $time());
    `endif;
  endtask
  
  //in this phase, which runs after the run phase where the actual activity in the verification environment happens, we print the coverage values
  virtual function void report_phase(uvm_phase phase);
    uvm_report_server svr;
    super.report_phase(phase);
    $display("STDOUT: Coverage obtained for the sensor: %3.2f%% ",  		   ambient_verif_env.sensor_agent_inst.monitor_sensor_inst0.sensor_coverage_collector.sensor_states_cg.get_inst_coverage());
    
    $display("STDOUT: Coverage obtained for the button: %3.2f%% ",  		   ambient_verif_env.button_agent_inst.monitor_agent_button_inst0.button_coverage_collector_inst.button_cg.get_inst_coverage());
    
    $display("STDOUT: Coverage obtained for the actuator: %3.2f%% ",  		   ambient_verif_env.actuator_agent_inst.monitor_agent_actuator_inst0.coverage_actuator_inst.actuator_cg.get_inst_coverage());
    
    //NOT SURE WHETHER A MONITOR IS NEEDED IN THIS CASE.
    $display("STDOUT: Coverage obtained for the scoreboard: %3.2f%% ",  		   ambient_verif_env.IO_scoreboard.scoreboard_coverage_collector.processed_data_cg.get_inst_coverage());

      
    svr = uvm_report_server::get_server();
 
    //count how many errors and warnings occurred during the test; if there was at least one, the test failed and must be fixed
     $display("number of errors: %0d \nnumber of warnings: %0d",svr.get_severity_count(UVM_FATAL) + svr.get_severity_count(UVM_ERROR), svr.get_severity_count(UVM_WARNING));
      if(svr.get_severity_count(UVM_FATAL) +
         svr.get_severity_count(UVM_ERROR)>0 +
       svr.get_severity_count(UVM_WARNING) > 0) 
		begin
     			`uvm_info(get_type_name(), "---------------------------------------", UVM_NONE)
     			`uvm_info(get_type_name(), "----            TEST FAIL          ----", UVM_NONE)
     			`uvm_info(get_type_name(), "---------------------------------------", UVM_NONE)
    		end
    	else 
		begin
     			`uvm_info(get_type_name(), "---------------------------------------", UVM_NONE)
     			`uvm_info(get_type_name(), "----           TEST PASS           ----", UVM_NONE)
     			`uvm_info(get_type_name(), "---------------------------------------", UVM_NONE)
    		end
    
    //end the test
        $finish();
  	endfunction 
  
endclass