# Abstract

## Overview
This repository contains a Verilog implementation of a 4x4 systolic array multiplier designed for efficient multiplication of 8-bit numbers. The design utilizes a systolic processing element (PE) architecture, Wallace Tree multipliers, and carry-save adders to perform parallel computations.

## Features
- **Systolic Array**: A 4x4 grid of processing elements (PEs) for parallel multiplication.
- **Wallace Tree Multiplier**: Optimizes partial product reduction for 8-bit inputs.
- **Carry-Save Adder**: Handles the accumulation of partial products with a 16-bit carry-save adder.
- **Clock and Reset**: Synchronized operation with active-low reset.

## Directory Structure
- `systolic_pe.v`: Module for a single systolic processing element.
- `wallaceTreeMultiplier8Bit.v`: Implementation of the Wallace Tree multiplier for 8-bit inputs.
- `carry_save_adder_16bit.v`: Carry-save adder module for 16-bit operations.
- `systolic_array_4x4.v`: Top-level module for the 4x4 systolic array.
- `top.v`: Main module integrating the systolic array.

## Usage
1. **Simulation**: Use a Verilog simulator (e.g., ModelSim, Vivado) to compile and simulate the design.
2. **Inputs**: Provide 32-bit `a_in` and `b_in` (4x8-bit values) along with `clk` and `rst_n`.
3. **Outputs**: Retrieve the 17-bit `sum_out` and 1-bit `cout` from the bottom-right PE.

## Diagrams
- The included images depict the systolic array layout and the detailed connection of a Wallace Tree multiplier with a carry-save adder.

## Dependencies
- Verilog 2001 compliant simulator.

## Contributing
Feel free to fork this repository and submit pull requests for improvements.
