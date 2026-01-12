# Reactor Control System

Lua-based control systems for managing nuclear reactors and turbines in Minecraft modpacks, specifically designed for ComputerCraft integration.

## Overview

This repository contains automated control systems for:
- **Bigger Reactors** - Energy production reactors
- **Mekanism Fission Reactors** - Advanced nuclear fission systems
- **Mekanism Industrial Turbines** - Steam-powered energy generation

Originally developed for ATM9TTS version 1.1.3 server, with Mekanism Turbine support added for Stoneblock 4 1.5.0.

## Features

### Bigger Reactors Control
- **Automated Power Management**: Activates/deactivates based on energy storage levels (5-95% thresholds)
- **Temperature Control**: Maintains fuel temperature between 1000-1500K using control rod adjustments
- **Safety Systems**: Automatic shutdown when power capacity reaches 95%

### Mekanism Fission Reactor Control
- **Advanced Safety Systems**: 
  - Automatic SCRAM on critical damage or coolant loss
  - Emergency coolant injection from waste tanks
  - Multiple safety threshold monitoring
- **Temperature Management**: Dynamic burn rate adjustments to maintain optimal operating temperature
- **Fuel Management**: Automated refueling and waste disposal
- **Coolant System Control**: Monitors and maintains coolant/heated coolant levels
- **Adaptive Learning**: Exponential smoothing algorithm for optimal burn rate calculation
- **Comprehensive Logging**: Debug, info, and error logs with timestamps

### Mekanism Turbine Monitoring
- **Real-time Monitoring**: Steam levels, input rates, and energy production
- **Data Logging**: Continuous logging of turbine performance metrics
- **Status Display**: Console output for quick status checks

### Visualization System (WIP)
- GUI-based reactor monitoring using ComputerCraft monitors
- Multi-monitor layout support
- Interactive controls for reactor management

## Project Structure

```
ReactorControl/
├── BiggerReactors/
│   ├── ReactorController.lua    # Main control loop
│   ├── Control.lua              # Control logic and rod management
│   └── Instrumentation.lua      # Sensor readings and status
│
├── MekanismReactors/
│   ├── Logging.lua              # Shared logging system
│   ├── pull.lua                 # Repository update utility
│   ├── ReloadRepo.lua           # Code reload utility
│   │
│   ├── Fission/
│   │   ├── ReactorController.lua    # Main control loop
│   │   ├── Control.lua              # Advanced control algorithms
│   │   └── Instrumentation.lua      # Reactor status monitoring
│   │
│   ├── Turbine/
│   │   ├── MonitorTurbine.lua       # Turbine monitoring system
│   │   └── Instrumentation.lua      # Turbine sensor readings
│   │
│   └── Visualization/
│       ├── main.lua                 # GUI main program
│       ├── Elements.lua             # GUI elements
│       ├── determine_layout.lua     # Monitor layout manager
│       └── layout.config            # Monitor configuration
```

## Installation

1. Clone or download this repository to your ComputerCraft computer
2. Ensure peripheral connections:
   - **Bigger Reactors**: Connect reactor to computer (default: "right")
   - **Mekanism Fission**: Uses `fissionReactorLogicAdaptor` peripheral
   - **Mekanism Turbine**: Uses `turbineValve` peripheral
3. Run the appropriate controller script for your reactor type

## Usage

### Bigger Reactors
```lua
> ReactorController.lua
```

### Mekanism Fission Reactor
```lua
> cd MekanismReactors/Fission
> ReactorController.lua
```

### Mekanism Turbine Monitoring
```lua
> cd MekanismReactors/Turbine
> MonitorTurbine.lua
```

## Logging

The Mekanism systems generate detailed logs in the `logs/` directory:
- `errors.log` - Critical errors and exceptions
- `debug.log` - Detailed operational data (CSV format)
- `info.log` - State changes and important events
- `burn_rate.log` - Learned optimal burn rate (persistent across restarts)

## Safety Features

### Mekanism Fission Reactor
- **SCRAM Conditions**: Triggered by damage >40%, critical coolant loss, or emergency situations
- **Automatic Recovery**: Attempts to restore safe operating conditions before reactivation
- **Coolant Injection**: Emergency coolant from waste tanks when needed
- **Adaptive Control**: Learning system prevents restart transients by saving optimal burn rates

## Technical Details

### Control Algorithms
- **Exponential Smoothing**: Used for burn rate optimization (α = 0.1)
- **Threshold-based Control**: Multi-level thresholds for different operational parameters
- **State Machine Logic**: Comprehensive state tracking and change detection
- **Derivative Monitoring**: Tracks rate of change for fuel and coolant levels

### Performance
- **Bigger Reactors**: 0.5s update cycle
- **Mekanism Systems**: 1s update cycle
- **Log Flushing**: Periodic buffer flushes prevent data loss

## Requirements

- ComputerCraft or CC: Tweaked
- Bigger Reactors mod (for BiggerReactors control)
- Mekanism mod (for Mekanism control systems)
- Appropriate peripheral connections

## Author

Created by NP (2025-2026)
