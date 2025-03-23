-- Instrumentation.lua
---------------------------------------------------------------------------
--- Written 2025
--- This file is part of the Nuclear Reactor Control System Instrumentation
--- For Bigger Reactors on the ATM9TTS 1.1.3 Server
--- Created by NP
---------------------------------------------------------------------------

function CreateReactorStatus(reactor)
    return {
        activity = CheckActivity(reactor),
        control_rod_depths = CheckRodDepths(reactor),
        fuel = CheckFuel(reactor),
        fuel_heat = CheckFuelHeat(reactor),
        waste = CheckWaste(reactor),
        power_stored = CheckPowerStorage(reactor)
    }
end

function CheckActivity(r)
    return r.active()
end

function CheckRodDepths(r)
    -- check rod depth
    num_rods = r.controlRodCount()
    rod_depths = {}

    for i = 0, num_rods - 1 do
        rod_depths[i + 1] = r.getControlRod(i).level()
    end

    return rod_depths
end

function CheckFuel(r)
    return r.fuelTank().fuel()
end

function CheckWaste(r)
    return r.fuelTank().waste()
end

function CheckPowerStorage(r)
    return r.battery().stored()
end

function CheckFuelHeat(r)
    return r.fuelTemperature()
end

