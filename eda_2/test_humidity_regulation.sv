class test_humidity_regulation extends test_ambient_base;
  `uvm_component_utils(test_humidity_regulation)
  
  
  //test constructor
  function new(string name = "test_limit_values", uvm_component parent=null);
    super.new(name, parent);
  endfunction
  
   function void start_of_simulation_phase(uvm_phase phase);
    super.start_of_simulation_phase(phase);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    
    //raise an objection signalling that an activity has started; until it is dropped, the simulator knows it must not end the "run" phase of the test; therefore we must make sure to drop the objection at the end of this task
    phase.raise_objection(this);
    
    //assert the reset signals in the interfaces
    apply_reset();
    `uvm_info("TEST_HUMIDITY_REGULATION", "real execution begins", UVM_NONE);
    //inside the fork/join block the sequences of the verification environment can be started in parallel
    fork
      begin
     `ifdef DEBUG
        $display("starting sequence: button_inputs_seq for the active agent button_agent");
      `endif; 
     	button_inputs_seq.start(ambient_verif_env.button_agent_inst.sequencer_agent_button_inst0);
      `ifdef DEBUG
        $display("finished running the sequence for the active agent button_agent");
      `endif;
      end
      
      begin 
      `ifdef DEBUG
        $display("starting sequence: sensor_humidity_seq for the active agent sensor_agent");
      `endif;
        sensor_humidity_seq.start(ambient_verif_env.sensor_agent_inst.sequencer_agent_sensor_inst0);
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
  //  vif_sensor_dut.ready_o <= 0;
    vif_button_dut.enable_i <= 0;
    #100//wait another 100 time units before dropping the objection, which will allow the simulator to end the activity
	//drop the objection 
    phase.drop_objection(this);
    endtask
  
  
  //in this phase, which runs after the run phase where the actual activity in the verification environment happens, we print the coverage values
  virtual function void report_phase(uvm_phase phase);
    super.report_phase(phase);
  	endfunction 
endclass