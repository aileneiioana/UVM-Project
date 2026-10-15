# UVM Verification – Student Exercise Template

SystemVerilog/UVM environment template used in the **UVM Verification lab** of the M.Sc. program *Electronic Systems and Integrated Communications* at **Transilvania University of Brașov**, where I taught the lab sessions (2nd semester, 2024 and 2025).

The template gives students a working two-agent UVM skeleton around a small DUT. The scoreboard contains a complete, commented **checker** as a worked example; other parts are **intentionally incomplete**, and students finish the agents and the functional coverage themselves.

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
         ├─ apb_agent        (active)  driver, monitor, sequencer, coverage_apb
         ├─ rename_agent     (active)  driver, monitor, sequencer, coverage_rename
         └─ scoreboard                 collects transactions from both monitors; checker in check_phase
```

| File | Role |
|---|---|
| `design.sv` | DUT |
| `testbench.sv` | `top` module: clock, interface instances, DUT instance, `run_test()` |
| `apb_interface_dut.sv`, `rename_interface_dut.sv` | Interfaces |
| `transaction_apb.sv`, `transaction_rename.sv` | Sequence items |
| `apb_sequence.sv`, `rename_sequence.sv` | Random sequences |
| `driver_agent_apb.sv`, `driver_agent_rename.sv` | Drivers |
| `monitor_apb.sv`, `monitor_rename.sv` | Monitors |
| `coverage_apb.sv`, `coverage_rename.sv` | Coverage collectors |
| `apb_agent.sv`, `rename_agent.sv` | Agents |
| `scoreboard.sv` | Scoreboard with the checker (worked example) |
| `verification_env.sv` | Environment |
| `test_example.sv` | Example test: reset, both sequences in parallel, coverage and error report |

## The checker (worked example)

A checker compares what the DUT actually did with what it should have done according to its specification. In `scoreboard.sv`:

1. The `write_apb` / `write_rename` functions store every transaction received from the monitors, together with the simulation time at which it was sampled.
2. In `check_phase` (after the run phase), each rename transaction is paired with the APB access sampled in the **same clock cycle**: both monitors sample on the falling edge of the same clock, so equal time stamps mean the same cycle.
3. A small reference model computes the expected `irq` from the specification, and two checks compare it with the `irq` the DUT produced:
   - **checker 1**: `irq` asserted when it should not be;
   - **checker 2**: `irq` expected but not asserted.
4. A summary reports the number of checks and errors. If nothing was checked, this is reported as an error, since a checker that checked nothing proves nothing.

## What students complete

- **APB agent**: the driver implements a simplified handshake (`psel`, `penable`, `paddr`); students extend it towards the APB protocol.
- **Functional coverage**: `coverage_apb.sv` and `coverage_rename.sv` have one bin per address value (0..7) and, for rename, `irq` low and high, so the reported percentage is real. Students add crosses and bins that matter for their DUT (e.g. address match × `irq`).
- **Adapting the `rename` agent**: the generic `rename` agent is a starting point that students rename and adapt to their own DUT interface.

## How to run

`testbench.sv` already includes all the files it needs. The default test is `test_example`.

### EDA Playground

1. Create a new playground and select **UVM 1.2** and a SystemVerilog simulator (e.g. Synopsys VCS or Cadence Xcelium).
2. Copy the files of `template_with_checker/` into the playground: `design.sv` goes in the design pane, everything else in the testbench pane.
3. Run.

### Vivado simulator (xsim)

Tested with Vivado 2025.2, which ships with UVM 1.2. From `template_with_checker/`:

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
