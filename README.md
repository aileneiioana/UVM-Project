# UVM Verification – Student Exercise Template

SystemVerilog/UVM environment template used in the **UVM Verification lab** of the M.Sc. program *Electronic Systems and Integrated Communications* at **Transilvania University of Brașov**, where I taught the lab sessions (2nd semester, 2024 and 2025).

The template gives students a working two-agent UVM skeleton around a small DUT. The scoreboard contains a complete, commented **data checker** as a worked example; other parts are **intentionally incomplete**, and students finish the agents and the functional coverage themselves.

> **Student guide:** [`UVM_Template_Student_Guide.docx`](UVM_Template_Student_Guide.docx) explains how the template is built (with diagrams) and how to adapt it to your own DUT.

> The material was originally written in Romanian for Romanian-speaking students; code, comments, identifiers and file names have since been translated to English.

## The DUT

`my_dut` (`template_with_checker/design.sv`) is a combinational address comparator:

```
irq_o = psel_i && penable_i && valid_i && (paddr_i == addr_i)
```

It has two input interfaces, an APB-style bus (`psel`, `penable`, `paddr`) and a generic "rename" interface (`valid`, `addr`), and one output, `irq`.

## Environment architecture

```
top (testbench.sv)
 ├─ my_dut
 └─ test_example
     └─ verification_env
         ├─ apb_agent        (active)  driver, monitor, sequencer, apb_coverage
         ├─ rename_agent     (active)  driver, monitor, sequencer, rename_coverage
         └─ scoreboard                 one FIFO per monitor; data checker pulls and compares
```

| File | Role |
|---|---|
| `design.sv` | DUT |
| `testbench.sv` | `top` module: clock, interface instances, DUT instance, `run_test()` |
| `apb_interface_dut.sv`, `rename_interface_dut.sv` | Interfaces |
| `apb_transaction.sv`, `rename_transaction.sv` | Sequence items |
| `apb_sequence.sv`, `rename_sequence.sv` | Random sequences |
| `apb_driver.sv`, `rename_driver.sv` | Drivers |
| `apb_monitor.sv`, `rename_monitor.sv` | Monitors |
| `apb_coverage.sv`, `rename_coverage.sv` | Coverage collectors |
| `apb_agent.sv`, `rename_agent.sv` | Agents |
| `scoreboard.sv` | Scoreboard with the data checker (worked example) |
| `verification_env.sv` | Environment |
| `test_example.sv` | Example test: reset, both sequences in parallel, coverage and error report |

## The data checker (worked example)

A data checker compares the data seen on one interface with the data expected from another one. In this template the test sends **the same list of addresses on both interfaces**, and `scoreboard.sv` checks that they arrive identical:

1. Each monitor writes its transactions to the scoreboard, where they are stored in a `uvm_tlm_analysis_fifo` (one FIFO per agent).
2. In `run_phase`, the checker pulls one transaction from each FIFO with `get()` (blocking until one is available) and compares the addresses; a mismatch is reported with `` `uvm_error ``.
3. In `check_phase`, it reports transactions left without a pair and prints a summary (`Checker summary: N checks, M errors`). If nothing was compared, this is reported as an error.

In a real project, one FIFO holds what went **into** the DUT (expected data) and the other what came **out** of it (actual data).

## What students complete

- **APB agent**: the driver implements a simplified handshake (`psel`, `penable`, `paddr`); students extend it towards the APB protocol.
- **Functional coverage**: `apb_coverage.sv` has three bins (`min_addr` = 0, `medium_addr` = 1..6, `max_addr` = 7). The example test sends only addresses 1..6, so APB coverage is low (1 of 3 bins); students write stimulus that reaches the minimum and maximum. `rename_coverage.sv` has one bin per address and `irq` low and high. Students also add crosses that matter for their DUT.
- **Adapting the `rename` agent**: the generic `rename` agent is a starting point that students rename and adapt to their own DUT interface.

## How to run

`testbench.sv` already includes all the files it needs. The default test is `test_example`.

### EDA Playground

1. Create a new playground and select **UVM 1.2** and a SystemVerilog simulator (e.g. Synopsys VCS or Cadence Xcelium).
2. Copy the files of `template_with_checker/` into the playground: `design.sv` goes in the design pane, everything else in the testbench pane.
3. Run.

### Vivado simulator (xsim)

Vivado ships with UVM 1.2. From `template_with_checker/`:

```
xvlog -sv -L uvm testbench.sv
xelab top -L uvm -timescale 1ns/1ns -s top_sim
xsim top_sim -R
```

## Topics covered in the lab

- UVM testbench architecture: env, agents, driver, monitor, sequencer
- Transactions, sequences, and constrained-random stimulus
- Analysis ports and scoreboards
- Functional coverage: covergroups, bins, and crosses
