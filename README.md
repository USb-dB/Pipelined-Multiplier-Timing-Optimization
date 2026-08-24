# Pipelined Multiplier RTL and Timing Optimization

A small FPGA digital-design project demonstrating RTL design, functional verification, static timing analysis (STA), critical-path identification, and synthesis-aware RTL optimization using Intel Quartus Prime and TimeQuest.

## Target

- FPGA: Intel/Altera Cyclone IV E `EP4CE22F17C6`
- Tool flow: Verilog → ModelSim → Quartus Prime → TimeQuest
- Clock constraint: 10 ns (100 MHz)

## Design

The design is an unsigned 8×8 pipelined multiplier. Partial products are accumulated across registered stages, with a `valid_in`/`valid_out` pipeline to maintain throughput.

## Verification

The ModelSim testbench checks:

- 12 × 5 = 60
- 8 × 7 = 56
- 15 × 3 = 45
- 6 × 9 = 54

The testbench also demonstrates back-to-back valid inputs and pipeline latency.
![ModelSim Simulation Waveform](results/modelsim_waveform.png)
## Timing Optimization

### Baseline

The initial RTL used a serial chain of additions in Stage 3. TimeQuest identified the Stage-2-to-Stage-3 path as the critical path.

| Metric | Baseline |
|---|---:|
| Fmax | **135.72 MHz** |
| Worst setup slack | **2.632 ns** |
| Critical data-path delay | **7.318 ns** |
| Critical path | `stage2_b[0] → stage3_sum[15]` |

### Optimized V1

The Stage-3 partial-product additions were restructured into a balanced two-level addition tree while preserving the pipeline structure and functionality.

| Metric | Baseline | Optimized V1 |
|---|---:|---:|
| Fmax | 135.72 MHz | **166.89 MHz** |
| Worst setup slack | 2.632 ns | **4.008 ns** |
| Critical data-path delay | 7.318 ns | **5.944 ns** |

Fmax improvement:

**23.0%**

The optimization moved the critical path to Stage 2, indicating that the original Stage-3 bottleneck was reduced.

### Optimized V2 experiment

A second experiment also balanced the Stage-2 partial-product additions. It did **not** improve the result further:

| Metric | Optimized V1 | Optimized V2 |
|---|---:|---:|
| Fmax | **166.89 MHz** | 165.70 MHz |
| Worst setup slack | **4.008 ns** | 3.965 ns |

This result is retained as an example of synthesis-aware optimization: a more explicit RTL restructuring does not necessarily produce better timing when the synthesis tool already optimizes the logic effectively.

## Repository Structure

```text
rtl/
  baseline/                         Original RTL
  optimized/                       Balanced-adder RTL variants
simulation/
  tb_pipelined_multiplier.v        ModelSim testbench
quartus/
  Pipelined_Multiplier.qpf
  Pipelined_Multiplier.qsf
  timing.sdc
results/
  *.rpt                            TimeQuest timing reports
  modelsim_transcript.txt          Functional simulation transcript
docs/
  modelsim_waveform.png            Simulation waveform
```

## Reproduction

1. Open the Quartus project under `quartus/`.
2. Use `EP4CE22F17C6` as the target device.
3. Compile the optimized design.
4. Open **Tools → Timing Analyzer**.
5. Run the timing analysis using `timing.sdc`.
6. Compare the generated Fmax and setup-slack results with the reports in `results/`.

For ModelSim, compile `rtl/optimized/pipelined_multiplier_optimized.v` together with `simulation/tb_pipelined_multiplier.v`, then simulate `pipelined_multiplier_tb`.

## Notes

The reported timing values are from the author's Quartus/TimeQuest runs and are retained in the repository as `.rpt` evidence. The project is intended as a compact study of RTL-to-STA optimization rather than as a production multiplier IP core.
