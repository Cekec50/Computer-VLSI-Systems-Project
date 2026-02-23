# Computer & VLSI Systems Project

This project is a Verilog-based implementation of a simple 16-bit CPU. The design is structured for both simulation using ModelSim/QuestaSim and for synthesis on Intel/Altera FPGA development boards (specifically targeting Cyclone III and Cyclone V families). It serves as an educational example of digital system design, from HDL-based implementation to simulation, synthesis, and hardware deployment. This project was developed as a part of the Computer VLSI Systems course at the University of Belgrade, School of Electrical Engineering.

## Tech Stack

*   **Hardware Description Languages:** Verilog, SystemVerilog
*   **Simulation:** ModelSim / Questa Sim
*   **Synthesis:** Intel Quartus Prime
*   **Build Automation:** GNU Make

## Features

The project implements a simple CPU with the following features:

*   **16-bit Data Path:** The CPU operates on 16-bit data words.
*   **Harvard-style Architecture:** Implied by the separation of instruction and data handling.
*   **Core CPU Components:**
    *   **ALU:** An Arithmetic Logic Unit supporting `ADD`, `SUB`, `MUL`, and `DIV`.
    *   **Registers:** Includes a Program Counter (PC), Stack Pointer (SP), Accumulator (ACC), and Instruction Registers (IR).
    *   **Memory:** A memory module for data storage.
*   **Basic Instruction Set:**
    *   Data Transfer: `MOV`
    *   Arithmetic: `ADD`, `SUB`, `MUL`, `DIV`
    *   I/O: `IN`, `OUT`
    *   Control: `STOP`
*   **Addressing Modes:** Supports both direct and indirect addressing for memory operations.
*   **Hardware Peripherals:** Includes modules for interfacing with common FPGA board components:
    *   Seven-Segment Display (SSD) driver
    *   Binary Coded Decimal (BCD) converter
    *   Clock Divider (`clk_div`)
    *   Push-button Debouncer

## Getting Started

Follow these instructions to set up the project for simulation and synthesis.

### Prerequisites

1.  **Intel Quartus Prime & ModelSim:** This project is configured for **Quartus Prime 13.1** and the bundled **ModelSim Altera Starter Edition**. Download and install it from the official Intel website.
2.  **Environment Configuration:** The `tooling/makefile` contains hardcoded paths to the Quartus and ModelSim executables. You **must** verify and update these paths to match your local installation.

    *   Open `tooling/makefile`.
    *   Modify `SIMUL_TOOL_EXE_DIR_PATH` to point to your `modelsim_ase/win32aloem/` directory.
    *   Modify `SYNTH_TOOL_EXE_DIR_PATH` to point to your `quartus/bin/` directory.

    *Example (paths may vary):*
    ```makefile
    SIMUL_TOOL_EXE_DIR_PATH = C:\altera\13.1\modelsim_ase\win32aloem
    SYNTH_TOOL_EXE_DIR_PATH = C:\altera\13.1\quartus\bin
    ```
3.  **GNU Make:** The project includes a Windows version of `make` at `tooling/xpack/bin/make.exe`. For simplicity, it is recommended to run all commands from within the `tooling` directory.

### Simulation

To compile and run a simulation of the CPU design:

1.  Navigate to the `tooling` directory in your terminal.
2.  Run the main simulation command:

    ```sh
    ./xpack/bin/make simul_all
    ```
    This command creates the work library, compiles the Verilog source files, and runs a shell-based simulation.

3.  To run the simulation and open the GUI for waveform analysis:

    ```sh
    ./xpack/bin/make simul_run_gui
    ```

### Synthesis

To synthesize the design for an FPGA:

1.  First, ensure your target device is correctly configured in `tooling/makefile`. You can set the `SYNTH_TOP_LEVEL_MODULE` and `SYNTH_DEVICE_FAMILY` variables.

2.  Navigate to the `tooling` directory.
3.  Run the full synthesis flow:

    ```sh
    ./xpack/bin/make synth_all
    ```
    This command will perform mapping (analysis & synthesis), fitting (place & route), assembly, and static timing analysis.

4.  To program the target device after a successful synthesis:

    ```sh
    ./xpack/bin/make synth_pgm
    ```

### Cleaning Up

To remove all generated simulation and synthesis files:

```sh
# From the tooling directory
./xpack/bin/make clean
```

## Project Structure

```
.
├── src/
│   ├── simulation/     # Top-level testbenches and files for simulation
│   └── synthesis/      # Verilog modules intended for FPGA synthesis
│       ├── modules/    # Core CPU and peripheral modules (ALU, MEM, etc.)
│       └── DE0_...     # Top-level files for specific FPGA boards
├── tooling/
│   ├── config/         # Configuration files, including source file lists and run scripts
│   ├── makefile        # The main makefile for automating tasks
│   └── xpack/          # Contains a distributable binary pack for make on Windows
└── uvm_macros.svh      # SystemVerilog macros for UVM (Universal Verification Methodology)
```

## Usage

Once the project is running (either in simulation or on hardware), its behavior is driven by the program loaded into the memory (`tooling/mem_init.mif`).

*   **In Simulation:** You can observe the CPU's internal state (registers, PC, ACC) and its interaction with memory through the waveform viewer (e.g., ModelSim GUI). The `out` port of the `cpu` module reflects the result of `OUT` instructions.
*   **On Hardware:** The `OUT` instructions will typically drive the seven-segment displays or other general-purpose I/O pins on the FPGA board, allowing you to see the results of the computation. Input can be provided via on-board switches or buttons.
