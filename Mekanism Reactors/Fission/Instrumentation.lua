-- Instrumentation.lua
---------------------------------------------------------------------------
--- Written 2025
--- This file is part of the Nuclear Reactor Control System Instrumentation
--- For Bigger Reactors on the ATM9TTS 1.1.3 Server
--- Created by NP
---------------------------------------------------------------------------
local RI = {}

function GetReactorStatus(reactor)
    return {
        activity = RI.CheckActivity(reactor),
        fuel = RI.CheckFuel(reactor),
        heat = RI.CheckFuelHeat(reactor),
        waste = RI.CheckWaste(reactor),
        coolant = RI.CheckCoolantLevels(reactor),
        heated_coolant = RI.CheckHeatedCoolantLevels(reactor),
        burn_rate = RI.GetCurrentBurnRate(reactor),
        dmg_percent = RI.GetDmgPercent(reactor),
    }
end

function RI.CheckActivity(r)
    return r.getStatus()
end

function RI.CheckFuel(r)
    return r.getFuelFilledPercentage() * 100
end

function RI.CheckWaste(r)
    return r.getWasteFilledPercentage() * 100
end

function RI.CheckFuelHeat(r)
    return r.getTemperature()
end

function RI.GetCurrentBurnRate(r)
    return r.getActualBurnRate()    
end

function RI.GetDmgPercent(r)
    return r.getDamagePercent()
end

function RI.CheckCoolantLevels(r)
    return r.getCoolantFilledPercentage() * 100
end

function RI.CheckHeatedCoolantLevels(r)
    return r.getHeatedCoolantFilledPercentage() * 100
end