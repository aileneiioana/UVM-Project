`include "uvm_macros.svh"
import uvm_pkg::*;

`ifndef __scoreboard
`define __scoreboard

class scoreboard extends uvm_scoreboard;
  
  //se adauga componenta in baza de date UVM
  `uvm_component_utils(scoreboard)
  
  //porturile prin care scoreboardul primeste tranzactiile culese de monitoare;
  //fiecare port trimite tot ce primeste in propriul FIFO (vezi connect_phase)
  uvm_analysis_export #(apb_transaction)    apb_data_port;
  uvm_analysis_export #(rename_transaction) rename_data_port;

  //cate un FIFO pentru fiecare agent: monitoarele scriu in ele in timpul simularii,
  //iar checkerul scoate tranzactiile, in ordinea in care au sosit
  uvm_tlm_analysis_fifo #(apb_transaction)    apb_fifo;
  uvm_tlm_analysis_fifo #(rename_transaction) rename_fifo;

  //statisticile checkerului, afisate in check_phase
  int num_checks = 0;
  int num_errors = 0;
  
  function new(string name="scoreboard", uvm_component parent=null);
    super.new(name, parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    apb_data_port    = new("apb_data_port", this);
    rename_data_port = new("rename_data_port", this);
    apb_fifo         = new("apb_fifo", this);
    rename_fifo      = new("rename_fifo", this);
  endfunction
  
  virtual function void connect_phase (uvm_phase phase);
    super.connect_phase(phase);
    //orice tranzactie care ajunge pe un port este pusa in FIFO-ul acelui port
    apb_data_port.connect(apb_fifo.analysis_export);
    rename_data_port.connect(rename_fifo.analysis_export);
  endfunction

  //CHECKERUL DE DATE
  //Un checker de date compara datele vazute pe o interfata cu datele asteptate de pe alta interfata.
  //Aici testul trimite aceeasi lista de adrese pe ambele interfete, deci a n-a tranzactie scoasa
  //din FIFO-ul APB trebuie sa aiba aceeasi adresa ca a n-a tranzactie scoasa din FIFO-ul rename.
  //In proiectul vostru, un FIFO contine ce a INTRAT in DUT (datele asteptate), iar celalalt contine
  //ce a IESIT din DUT (datele reale).
  virtual task run_phase(uvm_phase phase);
    apb_transaction    apb_tr;
    rename_transaction rename_tr;
    super.run_phase(phase);

    forever begin
      //get() asteapta pana cand FIFO-ul contine o tranzactie, apoi o scoate
      apb_fifo.get(apb_tr);
      rename_fifo.get(rename_tr);
      num_checks++;

      if (apb_tr.addr != rename_tr.addr) begin
        num_errors++;
        `uvm_error("SCOREBOARD", $sformatf("Data mismatch on transaction %0d: APB addr = %0h, rename addr = %0h", num_checks, apb_tr.addr, rename_tr.addr))
      end
      else
        `uvm_info("SCOREBOARD", $sformatf("Transaction %0d: same data on both interfaces (addr = %0h): OK", num_checks, apb_tr.addr), UVM_LOW)
    end
  endtask

  //dupa faza de run: fiecare tranzactie trebuie sa fi avut o pereche si trebuie sa se fi verificat ceva
  virtual function void check_phase (uvm_phase phase);
    super.check_phase(phase);

    if (apb_fifo.used() != 0 || rename_fifo.used() != 0)
      `uvm_error("SCOREBOARD", $sformatf("Transactions left without a pair: %0d in the APB FIFO, %0d in the rename FIFO", apb_fifo.used(), rename_fifo.used()))

    //un checker care nu a verificat nimic nu demonstreaza nimic: semnalam acest lucru
    if (num_checks == 0)
      `uvm_error("SCOREBOARD", "No transactions were compared, so nothing was checked")
    else
      `uvm_info("SCOREBOARD", $sformatf("Checker summary: %0d checks, %0d errors", num_checks, num_errors), UVM_NONE)
  endfunction
endclass
`endif
