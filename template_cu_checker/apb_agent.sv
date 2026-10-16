`include "uvm_macros.svh"
import uvm_pkg::*;

`ifndef __apb_agent
`define __apb_agent

//se includ dependentele folosite de agent
typedef class apb_monitor;//pre-declarare a clasei apb_monitor: monitorul si clasa de coverage se folosesc reciproc, iar fara ea compilarea ar da eroare
`include "apb_transaction.sv"
`include "apb_coverage.sv"
`include "apb_driver.sv"
`include "apb_monitor.sv"


class apb_agent extends uvm_agent;
  
  `uvm_component_utils (apb_agent)//se adauga agentul la baza de date a acestui proiect; de acolo, acelasi agent se va prelua ulterior spre a putea fi folosit
  
  
  //se instantiaza componentele de baza ale agentului: driverul, monitorul si sequencer-ul; driverul si monitorul sunt create de catre noi, pe cand sequencerul se ia direct din biblioteca UVM
  apb_driver apb_driver_inst0;
  
  apb_monitor  apb_monitor_inst0;
  
  uvm_sequencer #(apb_transaction) apb_sequencer_inst0;
  
  
  //se declara portul de comunicare al agentului cu scoreboardul/mediul de referinta; prin acest port agentul trimite spre verificare datele preluate de la monitor; a se observa ca intre monitor si agent (practic in interiorul agentului) comunicarea se face la nivel de tranzactie
  uvm_analysis_port #(apb_transaction) from_monitor_apb; //portul prin care monitorul trimite tranzactiile mai departe
  
  
  //se declara un camp in care spunem daca agentul este activ sau pasiv; un agent activ contine in plus, fata de agentul pasiv, driver si sequencer
  local int is_active = 1;  //0 inseamna agent pasiv; 1 inseamna agent activ
  
  
  //se declara constructorul clasei; acesta este un cod standard pentru toate componentele
  function new (string name = "apb_agent", uvm_component parent = null);
      super.new (name, parent);
    from_monitor_apb = new("from_monitor_apb", this);
  endfunction 
  
  
  //rularea unui mediu de verificare cuprinde mai multe faze; in faza "build", se "asambleaza" agentul, tinandu-se cont daca acesta este activ sau pasiv
  virtual function void build_phase (uvm_phase phase);
    
    //se apeleaza functia build_phase din clasa parinte (uvm_agent)
    super.build_phase(phase);
    
    //atat agentii activi, cat si agentii pasivi au nevoie de un monitor 
    apb_monitor_inst0 = apb_monitor::type_id::create ("apb_monitor_inst0", this);
    // daca agentul este activ, i se adauga atat sequencerul (componenta care aduce datele in agent) cat si driverul (componenta care preia datele de la sequencer si le transmite DUT-ului adaptandu-le protocolului de comunicatie al acestuia)
    if (is_active==1) begin
      apb_sequencer_inst0 = uvm_sequencer#(apb_transaction)::type_id::create ("apb_sequencer_inst0", this);
      apb_driver_inst0 = apb_driver::type_id::create ("apb_driver_inst0", this);
    end

  endfunction
  
  
  //rularea unui mediu de verificare cuprinde mai multe faze; in faza "connect", se realizeaza conexiunile intre componente; in cazul agentului, se realizeaza conexiunile intre sub-componentele agentului
  virtual function void connect_phase (uvm_phase phase);
    
    //se apeleaza functia connect_phase din clasa parinte (uvm_agent)
    super.connect_phase(phase);
    
    //se conecteaza portul agentului cu portul de comunicatie al monitorului din agent (monitorul nu poate trimite date in exterior decat prin intermediul agentului din care face parte)
    from_monitor_apb = apb_monitor_inst0.monitor_apb_data_port;
    
	// driverul primeste date de la sequencer, pentru a le transmite DUT-ului; daca agentul este activ, trebuie realizata si conexiunea intre sequencer si driver 
    if (is_active==1)begin
      apb_driver_inst0.seq_item_port.connect (apb_sequencer_inst0.seq_item_export);
    end
    
  endfunction
  
endclass

`endif