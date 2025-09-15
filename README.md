# Codex

MATLAB scripts demonstrating closed-loop identification using a joint input-output approach.

## Files
- `main_closedloop_jointIO.m` – orchestrates data generation, identification and validation.
- `simulate_cl.m` – simulates closed-loop data given a plant and controller.
- `identify_Tyr_Tur.m` – estimates transfer functions from reference to output and input.
- `post_analysis.m` – compares estimated and true models and performs residual analysis.

## Requirements
MATLAB with the Control System and System Identification Toolboxes (or equivalent Octave packages).

## Usage
Run the main script from MATLAB:
```matlab
main_closedloop_jointIO
```
The script saves simulated datasets (`cl_data.mat`), identified models (`identified_models.mat`) and produces diagnostic plots.
