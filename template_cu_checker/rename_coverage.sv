`include "uvm_macros.svh"
import uvm_pkg::*;

`ifndef __rename_coverage_collector
`define __rename_coverage_collector

//aceasta clasa este folosita pentru a se vedea cate combinatii de intrari au fost trimise DUT-ului; aceasta clasa este doar de model, si probabil va fi modificata, deoarece in general nu ne intereseaza sa obtinem in simulare toate combinatiile posibile de intrari ale unui DUT
class rename_coverage extends uvm_component;
  
  //componenta se adauga in baza de date
  `uvm_component_utils(rename_coverage)
  
  //se declara pointerul catre monitorul care da datele asupra carora se vor face masuratorile de coverage
  rename_monitor p_monitor;
  
  covergroup rename_states_cg;
    option.per_instance = 1;
    //cate un bin pentru fiecare adresa: addr are 3 biti (0..7), deci 8 bin-uri in total
    addr_cp: coverpoint p_monitor.sampled_rename_state.addr{
        bins addr_value[] = {[0:7]};
    }
    //irq trebuie vazut si pe 0 si pe 1; irq = 1 apare doar daca in acelasi ciclu exista un acces APB cu aceeasi adresa
    irq_cp: coverpoint p_monitor.sampled_rename_state.irq{
        bins irq_low  = {0};
        bins irq_high = {1};
    }
  endgroup
  
  //se creeaza grupul de coverage; ATENTIE! Fara functia de mai jos, grupul de coverage nu va putea esantiona niciodata date deoarece pana acum el a fost doar declarat, nu si creat
  function new(string name, uvm_component parent);
    super.new(name, parent);
    $cast(p_monitor, parent);//cu $cast, verificarea tipului se face in timpul rularii
    rename_states_cg = new();
  endfunction
  
endclass


`endif