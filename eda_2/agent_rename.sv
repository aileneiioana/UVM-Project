`include "tranzactie_agent_rename.sv"
`include "driver_agent_rename.sv"
`include "monitor_agent_rename.sv"



class agent_rename extends uvm_agent;

  `uvm_component_utils (agent_rename)//se adauga agentul la baza de date a acestui proiect; de acolo, acelasi agent se va prelua ulterior spre a putea fi folosit
  

  //se declara constructorul clasei; acesta este un cod standard pentru toate componentele
  function new (string name = "agent_rename", uvm_component parent = null);
      super.new (name, parent);

  endfunction 

endclass