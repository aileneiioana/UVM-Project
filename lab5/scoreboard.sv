`include "uvm_macros.svh"
import uvm_pkg::*;

`ifndef __ambient_scoreboard
`define __ambient_scoreboard

//se declara prefixele pe care le vor avea elementele folosite pentru a prelua datele de la agentul de intrari, respectiv de la agentul de semafoare
`uvm_analysis_imp_decl(_apb)

class scoreboard extends uvm_scoreboard;
  
  //se adauga componenta in baza de date UVM
  `uvm_component_utils(scoreboard)
  
  //se declara porturile prin intermediul carora scoreboardul primeste datele de la agenti, aceste date reflectand functionalitatea DUT-ului
  //a se observa ca prefixele declarate mai sus intra in componenta tipului de data al porturilor
  //pentru fiecare port declarat, se spune carui tip de scoreboard ii apartine (in situatia de fata avem doar o clasa care defineste scoreboardul cu numele "scoreboard") portul, si ce tip de date vor fi vehiculate pe portul respectiv
  uvm_analysis_imp_apb #(tranzactie_apb, scoreboard) port_pentru_datele_de_laapb;
  
  //pentru a inregistra coverage-ul dorit avem nevoie sa stim atat ce valori au venit de la apbi
  tranzactie_apb tranzactie_venita_de_la_apb;
  
  bit enable;
  
   //constructorul clasei
  function new(string name="scoreboard", uvm_component parent=null);
    //se apeleaza mai intai constructorul clasei parinte
    super.new(name, parent);
    //crearea porturilor
    port_pentru_datele_de_laapb = new("pentru_datele_de_laapb", this);
    
    
    //se creeaza tranzactia necesare pentru coverage:
    tranzactie_venita_de_la_apb = new();    
  endfunction
  
  
  virtual function void connect_phase (uvm_phase phase);
    super.connect_phase(phase);
    
    //in faza UVM "connect", se face conexiunea intre pointerul catre monitor din instanta colectorului de coverage a acestui monitor si monitorul insusi 
    ///colector_coverage_fsm_actuator_inteligenta.p_scoreboard = this;
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction
  
  
  //fiecare port de analiza UVM are atasata o functie write; prefixul declarat la inceputul acestui fisier pentru fiecare port se ataseaza automat functiei write, obtinand denumirile de mai jos
  //functiile write ale fiecarui port de date sunt apelate de componentele care pun date pe respectivul port (a se vedea fisierele unde sunt declarati agentii); aici, respectivele functii sunt implementate, pentru ca scoreboardul sa stie cum sa reactioneze atunci cand primeste date pe fiecare din porturi
  function void write_apb(input tranzactie_apb tranzactie_noua_apb);  
    `uvm_info("SCOREBOARD", $sformatf("S-a primit de la agentul apb tranzactia cu informatia:\n"), UVM_LOW)
    tranzactie_noua_apb.afiseaza_informatia_tranzactiei();
   // if ((enable == 1 && posedge_for_enable_detected == 0) || negedge_for_enable_detected == 1) // se accepta doar datele primite in starea START, nu si un starea OFF; de asemenea, deoarece datele se citesc cu un tact intarziere de monitorul agentului, se accepta si citirea pe negedge de enable 
    $display($sformatf("cand s-au primit date de la apbi, enable a fost %d",enable));
    
	    tranzactie_venita_de_la_apb = new();
        tranzactie_venita_de_la_apb = tranzactie_noua_apb.copy();
      
  endfunction : write_apb
  
          
  function verifica_corespondenta_datelor();
  //checker
  endfunction
endclass
`endif