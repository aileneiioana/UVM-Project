# UVM Verification – Lab Materials & Projects

SystemVerilog/UVM verification environments used in the **UVM Verification lab** of the M.Sc. program *Electronic Systems and Integrated Communications* at **Transilvania University of Brașov**, where I taught the lab sessions (2nd semester, 2024 and 2025).

The repository covers the full UVM flow, from a minimal single-agent APB environment up to a multi-agent environment with a reference model, functional coverage, and SVA assertions.

> The material was originally written in Romanian for Romanian-speaking students; code, comments, identifiers and file names have since been translated to English.

## Contents

| Folder | What it is | Highlights |
|---|---|---|
| [`lab5/`](lab5) | Introductory APB lab | APB agent (driver, monitor, sequence), scoreboard, functional coverage, example test |
| [`template_with_checker/`](template_with_checker) | Reusable environment template with a checker | APB agent plus a generic `*_rename` agent skeleton that students copy and adapt to their own DUT |
| [`eda_2/`](eda_2) | Ambient-control environment (multi-agent) | 3 agents (sensor, button, actuator), scoreboard with reference model, coverage collectors, SVA assertions, 10 directed and constrained-random tests |
| `Specificatie Inmultire matrici 2024.docx` / `.pdf` | Verification project specification | Team project (M.Sc., 2023–2024): systolic matrix multiplier with APB configuration and req/ack memory interfaces |

## Environment architecture (`eda_2/`)

```
top
 └─ test (test_*.sv)
     └─ verification_env            (UVM env)
         ├─ sensor_agent            temperature / humidity / luminous intensity stimulus
         │   ├─ driver, monitor, sequencer
         │   └─ coverage_sensor
         ├─ button_agent            button stimulus (single, multiple, fast presses)
         │   └─ coverage_agent_button
         ├─ actuator_agent          passive: observes heat / AC / dehumidifier / blinds outputs
         │   └─ coverage_agent_actuator
         └─ scoreboard              reference model + comparison against DUT outputs
```

- **Interfaces with SVA**: `sensor_interface_dut.sv` checks input value ranges; `actuator_interface.sv` checks the control behaviour. Each property is paired with a `cover property`.
- **Coverage**: bins target the DUT's decision thresholds and boundary values, e.g. the exact temperature, humidity, and light levels that switch actuators.
- **Tests**: basic smoke test, boundary values, temperature and humidity regulation, light-intensity control, button stress (multiple, rapid, frequent presses), and a full combined test.

The DUT in `eda_2/design.sv` is an FSM-based ambient controller written by Pascu Marius (2021), used here as the design under test for the lab.

## How to run

The environments are self-contained and were run on [EDA Playground](https://www.edaplayground.com):

1. Create a new playground and select **UVM 1.2** and a SystemVerilog simulator (e.g. Synopsys VCS or Cadence Xcelium).
2. Copy the files of one folder into the playground: `design.sv` goes in the design pane, everything else in the testbench pane.
3. In `testbench.sv`, un-comment the `include` lines for the interfaces and the test you want.
4. The default test is set in `run_test()` in `testbench.sv`; to run another one, add `+UVM_TESTNAME=<test_class_name>` to the run options, for example `+UVM_TESTNAME=test_ambient_base`.

## Topics covered in the lab

- UVM testbench architecture: env, agents, driver, monitor, sequencer
- Transactions, sequences, and constrained-random stimulus
- Analysis ports and scoreboards with reference models
- Functional coverage: covergroups, bins, and coverage-driven test writing
- SystemVerilog Assertions in interfaces
