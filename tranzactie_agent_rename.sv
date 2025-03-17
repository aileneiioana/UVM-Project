`ifndef __rename_transaction
`define __rename_transaction

//o tranzactie este formata din totalitatea datelor transmise la un moment dat pe o interfata
class tranzactie_agent_rename extends uvm_sequence_item;
  
  //componenta tranzactie se adauga in baza de date
  `uvm_object_utils(tranzactie_agent_rename)


  //constructorul clasei; această funcție este apelată când se creează un obiect al clasei "tranzactie"
  function new(string name = "tranzactie_agent_rename");//numele dat este ales aleatoriu, si nu mai este folosit in alta parte
    super.new(name);
  endfunction
 
  //functie de afisare a unei tranzactii
  function void afiseaza_informatia_tranzactiei();
     //////
  endfunction
  
  //functie prin care se compara 2 tranzactii
  virtual function bit do_compare(uvm_object rhs, uvm_comparer comparer);
    //primele 4 linii le putem considera cod standard, pe care nu il modificam
    bit res;
	tranzactie_agent_rename _obj;
	$cast(_obj, rhs);
	//////
	return res;
  endfunction
  
  //functie pentru "deep copy"
  function tranzactie_agent_rename copy();
	copy = new();
  //////////
	return copy;
  endfunction
  
endclass


`endif