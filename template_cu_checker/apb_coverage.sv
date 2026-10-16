`include "uvm_macros.svh"
import uvm_pkg::*;

`ifndef __apb_coverage_collector
`define __apb_coverage_collector

//aceasta clasa este folosita pentru a se vedea cate combinatii de intrari au fost trimise DUT-ului; aceasta clasa este doar de model, si probabil va fi modificata, deoarece in general nu ne intereseaza sa obtinem in simulare toate combinatiile posibile de intrari ale unui DUT
class apb_coverage extends uvm_component;
  
  //componenta se adauga in baza de date
  `uvm_component_utils(apb_coverage)
  
  //se declara pointerul catre monitorul care da datele asupra carora se vor face masuratorile de coverage
  apb_monitor p_monitor;
  
  covergroup apb_states_cg;
    option.per_instance = 1;
    //trei bin-uri: adresa minima (0), adresele medii (1 - 6) si adresa maxima (7)
    addr_cp: coverpoint p_monitor.sampled_apb_state.addr{
        bins min_addr    = {0};
        bins medium_addr = {[1:6]};
        bins max_addr    = {7};
    }
  endgroup
  
  //se creeaza grupul de coverage; ATENTIE! Fara functia de mai jos, grupul de coverage nu va putea esantiona niciodata date deoarece pana acum el a fost doar declarat, nu si creat
  function new(string name, uvm_component parent);
    super.new(name, parent);
    $cast(p_monitor, parent);//cu $cast, verificarea tipului se face in timpul rularii
    apb_states_cg = new();
  endfunction
  
endclass


`endif