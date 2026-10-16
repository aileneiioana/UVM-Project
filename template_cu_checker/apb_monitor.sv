`include "uvm_macros.svh"
import uvm_pkg::*;

`ifndef __apb_monitor
`define __apb_monitor

class apb_monitor extends uvm_monitor;
  
  //monitorul se adauga in baza de date UVM
  `uvm_component_utils (apb_monitor) 
  
  //se declara colectorul de coverage care va inregistra valorile semnalelor de pe interfata citite de monitor
  apb_coverage apb_coverage_collector; 
  
  //este creat portul prin care monitorul trimite spre exterior (la noi, informatia este accesata de scoreboard), prin intermediul agentului, tranzactiile extrase din traficul de pe interfata
  uvm_analysis_port #(apb_transaction) monitor_apb_data_port;
  
  //declaratia interfetei de unde monitorul isi colecteaza datele
  virtual apb_interface_dut monitor_apb_intf;
  
  apb_transaction sampled_apb_state, aux_tr_apb;
  
  //constructorul clasei
  function new(string name = "apb_monitor", uvm_component parent = null);
    
    //se apeleaza mai intai constructorul clasei parinte
    super.new(name, parent);
    
    //se creeaza portul prin care monitorul trimite in exterior, prin intermediul agentului, datele pe care le-a cules din traficul de pe interfata
    monitor_apb_data_port = new("monitor_apb_data_port",this);
    
    //se creeaza colectorul de coverage (la creare, se apeleaza constructorul colectorului de coverage)
    
    apb_coverage_collector = apb_coverage::type_id::create ("apb_coverage_collector", this);
    
    
    //se creeaza obiectul (tranzactia) in care se vor retine datele colectate de pe interfata la fiecare tact de ceas
    sampled_apb_state = apb_transaction::type_id::create("new_data");
    
    aux_tr_apb = apb_transaction::type_id::create("new_data_copy");
  endfunction
  
  
  //se preia din baza de date interfata la care se va conecta monitorul pentru a citi date, si se "leaga" la interfata pe care deja monitorul o contine
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    if (!uvm_config_db#(virtual apb_interface_dut)::get(this, "", "apb_interface_dut", monitor_apb_intf))
        `uvm_fatal("MONITOR_APB", "Could not access the monitor interface")
  endfunction
        
  
  
  virtual function void connect_phase (uvm_phase phase);
    super.connect_phase(phase);
    
    //in faza UVM "connect", se face conexiunea intre pointerul catre monitor din instanta colectorului de coverage a acestui monitor si monitorul insusi 
	apb_coverage_collector.p_monitor = this;
    
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    
    forever begin
      //esantionam pe fiecare front descrescator de ceas, cand semnalele sunt stabile
      @(negedge monitor_apb_intf.pclk);
      //un transfer are loc doar in ciclurile in care aceasta conditie este adevarata; un esantion pe ciclu = o tranzactie pe transfer
      if (monitor_apb_intf.psel && monitor_apb_intf.penable) begin
        //preiau datele de pe interfata DUT-ului
        sampled_apb_state.addr = monitor_apb_intf.paddr;

        aux_tr_apb = sampled_apb_state.copy();//nu vreau sa folosesc pointerul sampled_apb_state pentru a trimite datele, deoarece continutul acestuia se schimba, iar scoreboardul va citi alte date 

         //tranzactia cuprinzand datele culese de pe interfata se pune la dispozitie pe portul monitorului, daca modulul nu este in reset
        monitor_apb_data_port.write(aux_tr_apb); 
        `uvm_info("MONITOR_APB", $sformatf("Received the transaction with the following information:"), UVM_NONE)
        aux_tr_apb.display_transaction_info();

        //se inregistreaza valorile de pe cele doua semnale de iesire
        apb_coverage_collector.apb_states_cg.sample();

      end
    end//forever begin
  endtask
  
  
endclass: apb_monitor

`endif