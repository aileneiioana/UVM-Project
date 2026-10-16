# UVM Verification – Student Exercise Template

SystemVerilog/UVM template used in the **UVM Verification lab** of the M.Sc. program *Electronic Systems and Integrated Communications* at **Transilvania University of Brașov**, where I taught the lab sessions (2nd semester, 2024 and 2025).

It is a working two-agent UVM testbench around a small DUT. Students keep its structure, replace the DUT with their own and complete the agents, the coverage and the checker.

## Start here

| Document | What it is |
| --- | --- |
| [`UVM_Template_Student_Guide.docx`](UVM_Template_Student_Guide.docx) | How the template is built (with diagrams), the 10 steps to make it yours, and Git, APB and req/ack basics |
| [`Vivado_User_Guide.docx`](Vivado_User_Guide.docx) | How to create the Vivado project, run the simulation and get the coverage report. **Follow it when you run the project.** |

## What is in the repository

[`template_with_checker/`](template_with_checker): the UVM environment.

- **DUT** (`design.sv`): `irq_o = psel_i && penable_i && valid_i && (paddr_i == addr_i)`
- **Agents:** `apb_agent` and a generic `rename_agent` (replace `rename` with your own interface name)
- **Scoreboard:** one FIFO per agent and a data checker that compares them
- **Top:** `testbench.sv` includes every other file; the default test is `test_example`

## Expected result of the unchanged template

- `Checker summary: N checks, 0 errors` and `TEST PASS`
- APB coverage **33.33%**: the test sends only addresses 1–6, so the `min_addr` and `max_addr` bins stay empty. Reaching them is part of the exercise.

## Run from the command line (Vivado xsim)

From `template_with_checker/`:

```
xvlog -sv -L uvm testbench.sv
xelab top -L uvm -timescale 1ns/1ns -s top_sim
xsim top_sim -R
```

To run another test: `xsim top_sim -R -testplusarg UVM_TESTNAME=<test_class_name>`.

## Topics covered in the lab

- UVM testbench architecture: env, agents, driver, monitor, sequencer
- Transactions, sequences, and constrained-random stimulus
- Analysis ports, TLM FIFOs and scoreboards
- Functional coverage: covergroups, bins, and crosses

> The material was originally written in Romanian for Romanian-speaking students; code, comments, identifiers and file names have since been translated to English.
