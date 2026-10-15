`ifndef __test_example
`define __test_example

`include "uvm_macros.svh"
//include the files the test needs access to
`include "verification_env.sv"
`include "apb_sequence.sv"
`include "rename_sequence.sv"

class test_example extends uvm_test;
  `uvm_component_utils(test_example)
  
  
  //test constructor
  function new(string name = "test_example", uvm_component parent=null);
    super.new(name, parent);
  endfunction
  
  
  
  //instantiate the verification environment
  verification_env verif_env;
  
  //instantiate the sequences used by button_agent and sensor_agent
  rename_sequence rename_seq;
  apb_sequence apb_seq;
  
  
  //declare the virtual interfaces of the verification environment; they will later be bound to the real interfaces instantiated in the top module

  virtual apb_interface_dut vif_apb_dut;
  virtual rename_interface_dut vif_rename_dut;
  
   function void start_of_simulation_phase(uvm_phase phase);
    super.start_of_simulation_phase(phase);
    this.print();
    uvm_top.print_topology();
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    //create the verification environment declared above
    verif_env = verification_env::type_id::create("verif_env", this);
    
    //Get virtual IF handle from top_level and pass it to everything in env level
    if (!uvm_config_db#(virtual apb_interface_dut)::get(this, "", "apb_interface_dut", vif_apb_dut))
      `uvm_fatal("TEST", "Could not get the virtual interface type apb_interface_dut from the UVM database to create vif_apb_dut")
    if (!uvm_config_db#(virtual rename_interface_dut)::get(this, "", "rename_interface_dut", vif_rename_dut))
      `uvm_fatal("TEST", "Could not get the virtual interface type rename_interface_dut from the UVM database to create vif_rename_dut")

      //the virtual interfaces are used to create the connections with the agents
    uvm_config_db#(virtual rename_interface_dut)::set(this, "verif_env.rename_agent_inst.*", "rename_interface_dut",vif_rename_dut);
    uvm_config_db#(virtual apb_interface_dut)::set(this, "verif_env.apb_agent_inst.*", "apb_interface_dut",vif_apb_dut);

    //create the input data sequences, then randomize the fields declared with the "rand" keyword inside each sequence class

    apb_seq = apb_sequence::type_id::create("apb_seq");
    apb_seq.randomize();

    rename_seq = rename_sequence::type_id::create("rename_seq");
    rename_seq.randomize();
    
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    
    //call the run_phase function of the parent class
    super.run_phase(phase);
    
    //raise an objection signalling that an activity has started; until it is dropped, the simulator knows it must not end the "run" phase of the test; therefore we must make sure to drop the objection at the end of this task
    phase.raise_objection(this);
    
    //assert the reset signals in the interfaces
    apply_reset();
    `uvm_info("test_example", "real execution begins", UVM_NONE);
    
    //inside the fork/join block the sequences of the verification environment can be started in parallel
    fork
      
      begin 
      `ifdef DEBUG
        $display("starting sequence: apb_seq for the active agent apb_agent");
      `endif;
        apb_seq.start(verif_env.apb_agent_inst.sequencer_agent_apb_inst0);
      `ifdef DEBUG
        $display("finished running the sequence for the active agent apb_agent");
      `endif;
      
    
      end

      begin 
      `ifdef DEBUG
        $display("starting sequence: rename_seq for the active agent rename_agent");
      `endif;
        rename_seq.start(verif_env.rename_agent_inst.sequencer_agent_rename_inst0);
      `ifdef DEBUG
        $display("finished running the sequence for the active agent rename_agent");
      `endif;
      
    
      end
    join
    //after the sequences sending stimuli to the DUT have finished, all input signals are set to 0
    @(posedge vif_apb_dut.pclk);
    vif_apb_dut.psel     <= 0;
    vif_apb_dut.penable  <= 0;
    vif_apb_dut.paddr    <= 0;
    vif_rename_dut.addr  <= 0;
    vif_rename_dut.valid <= 0;
    #100//wait another 100 time units before dropping the objection, which will allow the simulator to end the activity
	//drop the objection 
    phase.drop_objection(this);
    endtask
  
  //reset the traffic on the interfaces
  virtual task apply_reset();
    vif_apb_dut.rst_n    <= 1;
    vif_apb_dut.paddr    <= 0;
    vif_apb_dut.penable  <= 0;
    vif_apb_dut.psel     <= 0;
    vif_rename_dut.addr  <= 0;
    vif_rename_dut.valid <= 0;
    `ifdef DEBUG
    $display("reset asserted");
    `endif;
    repeat(15) @(posedge vif_apb_dut.pclk);
    vif_apb_dut.rst_n <= 0;
    `ifdef DEBUG
    $display("%t reset deasserted", $time());
    `endif;
  endtask
  
  //in this phase, which runs after the run phase where the actual activity in the verification environment happens, we print the coverage values
  virtual function void report_phase(uvm_phase phase);
    uvm_report_server svr;
    super.report_phase(phase);
    $display("STDOUT: Coverage obtained for APB: %3.2f%% ",  		   verif_env.apb_agent_inst.monitor_apb_inst0.apb_coverage_collector.apb_states_cg.get_inst_coverage());

      
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
`endif