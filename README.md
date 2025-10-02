# Codex

MATLAB scripts demonstrating closed-loop identification using a joint input-output approach.

## Files
- `main_closedloop_jointIO.m` – orchestrates data generation, identification and validation.
- `simulate_cl.m` – simulates closed-loop data given a plant and controller.
- `identify_Tyr_Tur.m` – estimates transfer functions from reference to output and input.
- `post_analysis.m` – compares estimated and true models and performs residual analysis.
- `TetrisGame/` – SwiftUI implementation of a Tetris game for iOS.

## Requirements
MATLAB with the Control System and System Identification Toolboxes (or equivalent Octave packages).

For the iOS project, Xcode 14 or later with the iOS SDK.

## Usage
Run the main script from MATLAB:
```matlab
main_closedloop_jointIO
```
The script saves simulated datasets (`cl_data.mat`), identified models (`identified_models.mat`) and produces diagnostic plots.

### iOS Tetris Game
1. Open the `TetrisGame` folder in Xcode (`File > Open...`).
2. Build and run the `TetrisGameApp` target on the iOS Simulator or a physical device.
3. Use the on-screen controls to move, rotate, soft drop, and hard drop the falling tetrominoes.
