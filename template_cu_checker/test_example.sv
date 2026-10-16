`ifndef __test_example
`define __test_example

`include "uvm_macros.svh"
//se includ fisierele la care testul trebuie sa aiba acces
`include "verification_env.sv"
`include "apb_sequence.sv"
`include "rename_sequence.sv"

class test_example extends uvm_test;
  `uvm_component_utils(test_example)
  
  
  //se declara constructorul testului
  function new(string name = "test_example", uvm_component parent=null);
    super.new(name, parent);
  endfunction
  
  
  
  //se instantiaza mediul de verificare
  verification_env verif_env;
  
  //se instantiaza secventa folosita de button_agent si actuator_agent
  rename_sequence rename_seq;
  apb_sequence apb_seq;

  //aceleasi adrese sunt trimise pe ambele interfete, ca checkerul de date din scoreboard sa le poata compara una cate una
  bit [2:0] addr_list[$];
  
  
  //se instantiaza interfetele virtuale ale mediului de verificare; acestea vor fi ulterior corelate cu interfetele reale definite in apb_interface_dut.sv si rename_interface_dut.sv

  virtual apb_interface_dut vif_apb_dut;
  virtual rename_interface_dut vif_rename_dut;
  
   function void start_of_simulation_phase(uvm_phase phase);
    super.start_of_simulation_phase(phase);
    this.print();
    uvm_top.print_topology();
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    //se creaza mediul de verificare declarat mai sus
    verif_env = verification_env::type_id::create("verif_env", this);
    
    //ia handle-ul interfetei virtuale din top si il da tuturor componentelor din env
    if (!uvm_config_db#(virtual apb_interface_dut)::get(this, "", "apb_interface_dut", vif_apb_dut))
      `uvm_fatal("TEST", "Could not get the virtual interface type apb_interface_dut from the UVM database to create vif_apb_dut")
    if (!uvm_config_db#(virtual rename_interface_dut)::get(this, "", "rename_interface_dut", vif_rename_dut))
      `uvm_fatal("TEST", "Could not get the virtual interface type rename_interface_dut from the UVM database to create vif_rename_dut")

      //interfetele virtuale sunt folosite pentru a crea conexiunile cu agentii
    uvm_config_db#(virtual rename_interface_dut)::set(this, "verif_env.rename_agent_inst.*", "rename_interface_dut",vif_rename_dut);
    uvm_config_db#(virtual apb_interface_dut)::set(this, "verif_env.apb_agent_inst.*", "apb_interface_dut",vif_apb_dut);

    //Se creaza secventele de date de intrare (in cazul de fata avem doar o secventa, deoarece avem doar un agent activ), dandu-se apoi valori aleatoare campurilor declarate cu cuvantul cheie "rand" din interiorul clasei "secventa_intrari"

    apb_seq = apb_sequence::type_id::create("apb_seq");
    apb_seq.randomize();

    rename_seq = rename_sequence::type_id::create("rename_seq");
    rename_seq.randomize();

    //intre 10 si 15 adrese din intervalul 1..6: adresa minima (0) si cea maxima (7) nu sunt trimise niciodata,
    //deci din coverage-ul APB se atinge doar bin-ul medium_addr (1 din 3); extindeti intervalul ca sa atingeti min_addr si max_addr
    repeat ($urandom_range(10, 15)) addr_list.push_back($urandom_range(1, 6));
    apb_seq.addr_list    = addr_list;
    rename_seq.addr_list = addr_list;
    
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    
    //se apeleaza functia run_phase din clasa parinte
    super.run_phase(phase);
    
    //se activeaza un martor ("obiectie") ca am inceput o activitate; pana cand nu se termina activitatea, simulatorul va sti ca nu trebuie sa intrerupe faza "run" din rularea testului; de aceea trebuie sa avem grija ca la sfarsitul acestei functii sa dezactivam martorul de activitate
    phase.raise_objection(this);
    
    //se aserteaza semnalele de reset din interfete
    apply_reset();
    `uvm_info("test_example", "real execution begins", UVM_NONE);
    
    //in bulca fork join se pot porni in paralel secventele mediului de verificare
    fork
      
      begin 
      `ifdef DEBUG
        $display("starting sequence: apb_seq for the active agent apb_agent");
      `endif;
        apb_seq.start(verif_env.apb_agent_inst.apb_sequencer_inst0);
      `ifdef DEBUG
        $display("finished running the sequence for the active agent apb_agent");
      `endif;
      
    
      end

      begin 
      `ifdef DEBUG
        $display("starting sequence: rename_seq for the active agent rename_agent");
      `endif;
        rename_seq.start(verif_env.rename_agent_inst.rename_sequencer_inst0);
      `ifdef DEBUG
        $display("finished running the sequence for the active agent rename_agent");
      `endif;
      
    
      end
    join
    //dupa ce s-au terminat secventele care trimit stimuli DUT-ului, toate semnalele de intrare se pun in 0
    @(posedge vif_apb_dut.pclk);
    vif_apb_dut.psel     <= 0;
    vif_apb_dut.penable  <= 0;
    vif_apb_dut.paddr    <= 0;
    vif_rename_dut.addr  <= 0;
    vif_rename_dut.valid <= 0;
    #100//se mai asteapta 100 de unitati de timp inainte sa se dezactiveze martorul de activitate, actiune care va permite simulatorului sa incheie activitatea
	//se dezactiveaza martorul 
    phase.drop_objection(this);
    endtask
  
  //traficul de pe interfete este resetat
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
  
  //in aceasta faza, care se desfasoara dupa faza de run in care se intampla actiunea propriu-zisa in mediul de verificare, afisam valorile de coverage
  virtual function void report_phase(uvm_phase phase);
    uvm_report_server svr;
    super.report_phase(phase);
    $display("STDOUT: Coverage obtained for APB: %3.2f%% ",  		   verif_env.apb_agent_inst.apb_monitor_inst0.apb_coverage_collector.apb_states_cg.get_inst_coverage());
    $display("STDOUT: Coverage obtained for RENAME: %3.2f%% ", verif_env.rename_agent_inst.rename_monitor_inst0.rename_coverage_collector.rename_states_cg.get_inst_coverage());

      
    svr = uvm_report_server::get_server();
 
    //se numara cate erori si cate atentionari (WARNINGs) au fost pe parcursul testului; daca a existat macar una, inseamna ca testul a picat, si trebuie reparat
     $display("number of errors: %0d \nnumber of warnings: %0d",svr.get_severity_count(UVM_FATAL) + svr.get_severity_count(UVM_ERROR), svr.get_severity_count(UVM_WARNING));
      if((svr.get_severity_count(UVM_FATAL) + svr.get_severity_count(UVM_ERROR) > 0) ||
         (svr.get_severity_count(UVM_WARNING) > 0))
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

  	endfunction 
endclass
`endif