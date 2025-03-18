`ifndef __monitor_agent_rename
`define __monitor_agent_rename
//`include "tranzactie_semafoare.sv"

class monitor_agent_rename extends uvm_monitor;
  
  //monitorul se adauga in baza de date UVM
  `uvm_component_utils (monitor_agent_rename) 
  
  //se declara colectorul de coverage care va inregistra valorile semnalelor de pe interfata citite de monitor
  coverage_agent_rename coverage_rename_inst; //colector_coverage_semafoare;
  
  //este creat portul prin care monitorul trimite spre exterior (la noi, informatia este accesata de scoreboard), prin intermediul agentului, tranzactiile extrase din traficul de pe interfata
  uvm_analysis_port #(tranzactie_agent_rename) port_date_monitor_rename;
  
  //declaratia interfetei de unde monitorul isi colecteaza datele
  virtual rename_interface_dut interfata_monitor_rename;
  
  tranzactie_agent_rename starea_preluata_a_renameului, aux_tr_rename;
  
  //constructorul clasei
  function new(string name = "monitor_agent_rename", uvm_component parent = null);
    
    //prima data se apeleaza constructorul clasei parinte
    super.new(name, parent);
    
    //se creeaza portul prin care monitorul trimite in exterior, prin intermediul agentului, datele pe care le-a cules din traficul de pe interfata
    port_date_monitor_rename = new("port_date_monitor_rename",this);
    
    //se creeaza colectorul de coverage (la creare, se apeleaza constructorul colectorului de coverage)
   coverage_rename_inst = coverage_agent_rename::type_id::create ("coverage_rename_inst", this);
    
    
    //se creeaza obiectul (tranzactia) in care se vor retine datele colectate de pe interfata la fiecare tact de ceas
    starea_preluata_a_renameului = tranzactie_agent_rename::type_id::create("date_noi");
    
    aux_tr_rename = tranzactie_agent_rename::type_id::create("datee_noi"); // folosim acest obiect de fiecare data cand transmitem datele pe portul de write pentru a nu lucra cu valoarea pointerului starea_preluata_a_renameului care se poate schimba pana cand aceasta este citita de catre scoreboard
  endfunction
  
  
  //se preia din baza de date interfata la care se va conecta monitorul pentru a citi date, si se "leaga" la interfata pe care deja monitorul o contine
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    if (!uvm_config_db#(virtual rename_interface_dut)::get(this, "", "rename_interface_dut", interfata_monitor_rename))
      `uvm_fatal("MONITOR_AGENT_rename", "Nu s-a putut accesa interfata monitorului")
  endfunction
        
  
  
  virtual function void connect_phase (uvm_phase phase);
    super.connect_phase(phase);
    
    //in faza UVM "connect", se face conexiunea intre pointerul catre monitor din instanta colectorului de coverage a acestui monitor si monitorul insusi 
	coverage_rename_inst.p_monitor = this;
    
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    
    forever begin
      
      //preluarea datelor de pe interfata se face la fiecare front negativ de ceas
      @(negedge interfata_monitor_rename.clk_i);
      
      //intarzii citirea datelor cu un tact, sa nu citesc iesirile DUT-ului inainte ca acesta sa nu primeasca valori pe intrari
     // repeat(2)@(negedge interfata_monitor_rename.clk);
      
      
      //preiau datele de pe interfata de iesire a DUT-ului (interfata_semafoare)
      
      //tranzactia cuprinzand datele culese de pe interfata se pune la dispozitie pe portul monitorului, daca modulul nu este in reset
      port_date_monitor_rename.write( aux_tr_rename); 
    //  `uvm_info("MONITOR_AGENT_SEMAFOARE", $sformatf("S-a receptionat tranzactia cu informatiile:"), UVM_NONE)
      //starea_preluata_a_semafoarelor.afiseaza_informatia_tranzactiei();
    end//forever begin
  endtask
endclass: monitor_agent_rename

`endif