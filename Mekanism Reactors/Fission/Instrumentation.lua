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
        fuel = CheckFuel(reactor),
        heat = CheckFuelHeat(reactor),
        waste = CheckWaste(reactor),
        burn_rate = GetCurrentBurnRate(reactor),
        dmg_percent = GetDmgPercent(reactor),
    }
end

function CheckActivity(r)
    return r.getStatus()
end

function CheckFuel(r)
    return r.getFuelFilledPercentage()
end

function CheckWaste(r)
    return r.getWasteFilledPercentage()
end

function CheckFuelHeat(r)
    return r.getTemperature()
end

function GetCurrentBurnRate(r)
    return r.getActualBurnRate()    
end

function GetDmgPercent(r)
    return r.getDamagePercent()
end