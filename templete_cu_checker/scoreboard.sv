`include "uvm_macros.svh"
import uvm_pkg::*;

`ifndef __scoreboard
`define __scoreboard

`uvm_analysis_imp_decl(_apb)
`uvm_analysis_imp_decl(_rename)

class scoreboard extends uvm_scoreboard;
  
  `uvm_component_utils(scoreboard)
  
  uvm_analysis_imp_apb #(tranzactie_apb, scoreboard) port_pentru_datele_de_la_apb;
  uvm_analysis_imp_rename #(tranzactie_rename, scoreboard) port_pentru_datele_de_la_rename;

  tranzactie_apb    tranzactie_venita_de_la_apb;
  tranzactie_rename tranzactie_venita_de_la_rename;

  //tranzactie_apb    tranzactii_apb[$];
  //tranzactie_rename tranzactii_rename[$];

  bit enable;
  
  function new(string name="scoreboard", uvm_component parent=null);
    super.new(name, parent);
    port_pentru_datele_de_la_apb = new("pentru_datele_de_la_apb", this);
    port_pentru_datele_de_la_rename = new("pentru_datele_de_la_rename", this);
    
    tranzactie_venita_de_la_apb = new();   
    tranzactie_venita_de_la_rename = new();   
  endfunction
  
  virtual function void connect_phase (uvm_phase phase);
    super.connect_phase(phase);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction
  
  function void write_apb(input tranzactie_apb tranzactie_noua_apb);  
    `uvm_info("SCOREBOARD", $sformatf("S-a primit de la agentul apb tranzactia cu informatia:\n"), UVM_LOW)
    tranzactie_noua_apb.afiseaza_informatia_tranzactiei();
    
    $display($sformatf("cand s-au primit date de la apb, enable a fost %d", enable));
    
    tranzactie_venita_de_la_apb = tranzactie_noua_apb.copy();
    //tranzactii_apb.push_back(tranzactie_venita_de_la_apb);
  endfunction : write_apb

  function void write_rename(input tranzactie_rename tranzactie_noua_rename);  
    `uvm_info("SCOREBOARD", $sformatf("S-a primit de la agentul rename tranzactia cu informatia:\n"), UVM_LOW)
    tranzactie_noua_rename.afiseaza_informatia_tranzactiei();
    
    $display($sformatf("cand s-au primit date de la rename, enable a fost %d", enable));
    
    tranzactie_venita_de_la_rename = tranzactie_noua_rename.copy();
    //tranzactii_rename.push_back(tranzactie_venita_de_la_rename);
  endfunction : write_rename

 /*  virtual function void check_phase (uvm_phase phase);
   foreach(tranzactii_rename[i]) begin
      //checker 1
      if (tranzactii_rename[i].irq == 1) begin
        if(tranzactii_rename[i].addr != tranzactii_apb[i].paddr)
          `uvm_error("SCOREBOARD checker 1", $sformatf("IRQ asserted wrong, address on apb is %h and on rename is %h", tranzactii_apb[i].paddr, tranzactii_rename[i].addr))
        else 
          `uvm_info("SCOREBOARD checker 1", "IRQ ASSERTED: OK", UVM_LOW)
      end
      //checker 2
      if((tranzactii_rename[i].addr == tranzactii_apb[i].paddr) && (tranzactii_rename[i].irq == 0))
        `uvm_error("SCOREBOARD checker 2", "IRQ expected but not asserted")
      else 
        `uvm_info("SCOREBOARD checker 2", "IRQ ASSERTED: OK", UVM_LOW)
    end
  endfunction*/
endclass
`endif
