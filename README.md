# Verificare UVM – template pentru exercițiile studenților

Template SystemVerilog/UVM folosit la **laboratorul de Verificare UVM** din programul de master *Sisteme Electronice și Comunicații Integrate* de la **Universitatea Transilvania din Brașov**, unde am predat laboratorul (semestrul 2, 2024 și 2025).

Este un testbench UVM funcțional, cu două agente, în jurul unui DUT mic. Studenții păstrează structura, pun DUT-ul lor în locul celui existent și completează agentele, coverage-ul și checkerul.

> Pe acest branch (`main_romanian`) codul și numele fișierelor sunt în engleză, ca pe `main`; comentariile din cod și documentele sunt în română.

## De aici începeți

| Document | Ce conține |
| --- | --- |
| [`Ghid_student_template_UVM.docx`](Ghid_student_template_UVM.docx) | Cum e construit template-ul (cu scheme), cei 10 pași ca să-l faceți al vostru și noțiuni de bază despre Git, APB și req/ack |
| [`Ghid_de_utilizare_Vivado.docx`](Ghid_de_utilizare_Vivado.docx) | Cum creați proiectul în Vivado, rulați simularea și obțineți raportul de coverage. **Folosiți-l când rulați proiectul.** |

## Ce conține repository-ul

[`template_cu_checker/`](template_cu_checker): mediul UVM.

- **DUT** (`design.sv`): `irq_o = psel_i && penable_i && valid_i && (paddr_i == addr_i)`
- **Agente:** `apb_agent` și un agent generic `rename_agent` (înlocuiți `rename` cu numele interfeței voastre)
- **Scoreboard:** câte un FIFO pentru fiecare agent și un checker de date care le compară
- **Top:** `testbench.sv` include toate celelalte fișiere; testul implicit este `test_example`

Exemple din anii anteriori (cod mai vechi, cu nume în română):

- [`exemplu_proiect_ttvf_senzori/`](exemplu_proiect_ttvf_senzori): un proiect complet de student (senzori, buton, actuator), cu mai multe agente și teste;
- [`exemplu_documentatie_proiect/`](exemplu_documentatie_proiect): un exemplu de specificație (`Specificatie Inmultire matrici 2024`, .docx și .pdf);
- [`templete_cu_checker_2025/`](templete_cu_checker_2025): versiunea din 2025 a template-ului, înainte de reorganizare.

## Rezultatul așteptat pentru template-ul neschimbat

- `Checker summary: N checks, 0 errors` și `TEST PASS`
- Coverage APB **33.33%**: testul trimite doar adresele 1–6, deci bin-urile `min_addr` și `max_addr` rămân goale. Atingerea lor face parte din exercițiu.

## Rulare din linia de comandă (Vivado xsim)

Din folderul `template_cu_checker/`:

```
xvlog -sv -L uvm testbench.sv
xelab top -L uvm -timescale 1ns/1ns -s top_sim
xsim top_sim -R
```

Pentru alt test: `xsim top_sim -R -testplusarg UVM_TESTNAME=<numele_clasei_de_test>`.

## Ce se acoperă la laborator

- Arhitectura unui testbench UVM: env, agente, driver, monitor, sequencer
- Tranzacții, secvențe și stimuli aleatori cu constrângeri
- Porturi de analiză, FIFO-uri TLM și scoreboard-uri
- Coverage funcțional: covergroup-uri, bin-uri și cross-uri
