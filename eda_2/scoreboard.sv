`ifndef __ambient_scoreboard
`define __ambient_scoreboard

//declare the suffixes of the analysis imp ports used to receive data from each agent
`uvm_analysis_imp_decl(_actuator)
`uvm_analysis_imp_decl(_sensor)
`uvm_analysis_imp_decl(_button)

class scoreboard extends uvm_scoreboard;
  
  //register the component in the UVM factory
  `uvm_component_utils(scoreboard)
  
  //declare the ports through which the scoreboard receives data from the agents; this data reflects the functionality of the DUT
  //note that the suffixes declared above become part of the ports' data type
  //for each declared port we specify which scoreboard type it belongs to (here there is only one class defining the scoreboard, named "scoreboard") and what data type is carried on that port
  uvm_analysis_imp_actuator #(transaction_agent_actuator, scoreboard) actuator_data_port;
  uvm_analysis_imp_sensor #(transaction_sensor, scoreboard) sensor_data_port;
  uvm_analysis_imp_button #(transaction_agent_button, scoreboard) button_data_port;
  
  //declare the coverage collector used to record which values the sensor generated while the DUT was enabled (enable = 1)
  coverage_sensor_values_read_ref scoreboard_coverage_collector;
  
  //to record the desired coverage we need to know what values came from the sensors
  transaction_sensor received_sensor_transaction;
  //declare the objects that hold the data predicted by the reference model; this data is compared with the data at the DUT output
  transaction_agent_actuator ref_predicted_transaction, initial_actuator_transaction, ref_computed_transaction, dut_transaction;// initial_actuator_transaction is a transaction that never changes, holding the default actuator values after reset; 
  
  //list holding the actuator transactions computed by the reference model; a list is used because the model computes the actuator state faster than the DUT, so these results must be kept until the DUT data is also collected
  transaction_agent_actuator ref_transaction_list [$];
  
  bit enable;
  
   //class constructor
  function new(string name="scoreboard", uvm_component parent=null);
    //first call the parent class constructor
    super.new(name, parent);
    //create the ports
    actuator_data_port = new("actuator_data_port", this);
    sensor_data_port = new("sensor_data_port", this);
    button_data_port = new("button_data_port", this);
    
    //create the transaction predicted by the reference model:
    ref_predicted_transaction = new();
    
    //create the transaction needed for coverage:
    received_sensor_transaction = new();
	
	initial_actuator_transaction = new();
	
	ref_transaction_list.push_back(initial_actuator_transaction);
    
    ref_computed_transaction = new();
	dut_transaction  = new();
    
    //create the coverage collector (on creation, the coverage collector's constructor is called)
    scoreboard_coverage_collector = coverage_sensor_values_read_ref::type_id::create("scoreboard_coverage_collector", this);
    
  endfunction
  
  
  virtual function void connect_phase (uvm_phase phase);
    super.connect_phase(phase);
    
    //in the UVM "connect" phase, the monitor handle inside this monitor's coverage collector instance is connected to the monitor itself 
    ///fsm_actuator_coverage_collector.p_scoreboard = this;
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction
  
  function transaction_agent_actuator compute_result(transaction_sensor aux_tr_sensor);
  received_sensor_transaction = aux_tr_sensor.copy();
  ref_predicted_transaction = new();
  if (enable ==1) begin
	if (received_sensor_transaction.temperature <= 22)
      ref_predicted_transaction.Heat_i = 1;
    else
      ref_predicted_transaction.Heat_i = 0;
    
    if (received_sensor_transaction.temperature > 25)
      ref_predicted_transaction.AC_i = 1;
    else
      if (received_sensor_transaction.temperature <= 22)
      	ref_predicted_transaction.AC_i = 0;
		else
			ref_predicted_transaction.AC_i = ref_transaction_list[ref_transaction_list.size()-1].AC_i;;
    
    if (received_sensor_transaction.humidity > 50)
      ref_predicted_transaction.Dehumidifier_i = 1;
    else
      if (received_sensor_transaction.humidity <= 35)
      	ref_predicted_transaction.Dehumidifier_i = 0;
		else
		ref_predicted_transaction.Dehumidifier_i = ref_transaction_list[ref_transaction_list.size()-1].Dehumidifier_i;
    
    if (received_sensor_transaction.luminous_intensity > 700)
      ref_predicted_transaction.Blinds_i = 1; // blinds are closed, light is blocked
    else
      if (received_sensor_transaction.luminous_intensity <= 200 )
      	ref_predicted_transaction.Blinds_i = 0; // blinds are open, light is let through
		else
		ref_predicted_transaction.Blinds_i = ref_transaction_list[ref_transaction_list.size()-1].Blinds_i;
      end// if (enable == 1)
        else//otherwise (if the device is off, i.e. enable is 0) put the actuators in their initial state
      begin
        ref_predicted_transaction.Blinds_i = 0;
        ref_predicted_transaction.Heat_i = 0;
        ref_predicted_transaction.AC_i = 0;
        ref_predicted_transaction.Dehumidifier_i = 0;
      end
	  `ifdef DEBUG
       `uvm_info("SCOREBOARD", $sformatf("evaluated the new transaction with the following information"), UVM_LOW)
       received_sensor_transaction.display_transaction_info();
       `uvm_info("SCOREBOARD", $sformatf("the predicted transaction would be"), UVM_LOW)
       ref_predicted_transaction.display_transaction_info();
     `endif
	  return ref_predicted_transaction;
  endfunction
  
  
  
  //every UVM analysis imp port has a write function attached; the suffix declared at the top of this file for each port is automatically appended to the write function name, giving the names below
  //the write functions of each data port are called by the components that put data on that port (see the files where the agents are declared); here these functions are implemented, so the scoreboard knows how to react when it receives data on each port
  function void write_sensor(input transaction_sensor new_sensor_transaction);  
    `uvm_info("SCOREBOARD", $sformatf("Received from the sensor agent the transaction with the following information:\n"), UVM_LOW)
    new_sensor_transaction.display_transaction_info();
   // if ((enable == 1 && posedge_for_enable_detected == 0) || negedge_for_enable_detected == 1) // only data received in the START state is accepted, not in the OFF state; also, since the agent's monitor reads data with one clock cycle of delay, reading on the enable negedge is accepted too 
    $display($sformatf("when the sensor data was received, enable was %d",enable));
    
	    received_sensor_transaction = new();
        received_sensor_transaction = new_sensor_transaction.copy();
		ref_computed_transaction = compute_result(received_sensor_transaction);
		ref_transaction_list.push_back(ref_computed_transaction);
		`ifdef DEBUG
		$display("ref_transaction_list: ");
	foreach (ref_transaction_list[i])	
    ref_transaction_list[i].display_transaction_info();
      
      `endif
      
  endfunction : write_sensor
  
  function void write_button(input transaction_agent_button new_button_transaction);  
    `uvm_info("SCOREBOARD", $sformatf("Received from the button agent the transaction with the following information:\n"), UVM_LOW)
    new_button_transaction.display_button_transaction_info();
    `ifdef DEBUG
      $display("the transaction predicted by the reference model is");
      ref_predicted_transaction.display_transaction_info();
    `endif
    
   enable = new_button_transaction.enable;
   if (enable == 0) begin //if enable went to 0, the actuators take their default values
   ref_transaction_list.push_back(initial_actuator_transaction);
   
   end
  endfunction : write_button
  
  //the "actuator_data_port" receives data from the DUT output; this means that when data arrives on this port, we have already received the data from the active agents that stimulate the DUT inputs; 
  function void write_actuator(input transaction_agent_actuator new_actuator_transaction);
    
    //always create a new object (declared at the top of the file) before sending the data to the comparator. Otherwise, if we worked with the new_actuator_transaction handle, the value at its address could be overwritten by the next transaction, losing the data of the previous transaction and invalidating the comparison
	dut_transaction = new();
	dut_transaction = new_actuator_transaction.copy();
	
    
	  fork
      check_data_match(dut_transaction);
    join_none
    
      
  endfunction : write_actuator
  
          
  function check_data_match(transaction_agent_actuator actuator_transaction_to_check);
  int found = 0;
  $display("1. reached checking");
     foreach (ref_transaction_list[i])
     if (actuator_transaction_to_check.compare(ref_transaction_list[i]) ==1)//note! the name "compare" is used to call the do_compare function declared in the transaction class
	 found = 1;
	 
	 if (found == 0)
      begin
        `uvm_error("SCOREBOARD", $sformatf(" the data generated by the reference model does not match the data coming from the DUT.\n") )
        $display("DUT data:\n");
        actuator_transaction_to_check.display_transaction_info(); 
        
      end
	  `ifdef DEBUG
    else
	begin
      `uvm_info("SCOREBOARD", $sformatf("The DUT behaved the same as the verification environment for the evaluated transaction" ), UVM_LOW)
	  actuator_transaction_to_check.display_transaction_info();
    end
	`endif
	while (ref_transaction_list.size()>2) //choose a number (here 2) representing the maximum number of transactions processed by the reference model before the DUT response is also collected
		ref_transaction_list.pop_front();
  endfunction
endclass
`endif