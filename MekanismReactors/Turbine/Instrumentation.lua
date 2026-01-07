-- Instrumentation.lua
---------------------------------------------------------------------------
--- Written 2026
--- This file is part of the Turbine Control System (TCS) Instrumentation
--- For Mekanism Turbines on the Stoneblock 4 1.5.0 Server
--- Created by NP
---------------------------------------------------------------------------
local TI = {}

function GetTurbineStatus(turbine)
    return {
        steam_level = TI.CheckSteamLevel(turbine),
        steam_value = TI.GetSteamValue(turbine),
        steam_input_rate = TI.GetSteamInputRate(turbine),
        energy_stored = TI.GetEnergyStored(turbine),
        energy_capacity = TI.GetEnergyCapacity(turbine),
        energy_production = TI.GetEnergyProduction(turbine),
    }
end

function CheckSteamLevel(t)
    return t.getSteamFilledPercentage() * 100
end

function TI.GetSteamValue(t)
    return t.getSteam()
end

function TI.GetSteamInputRate(t)
    return t.getLastSteamSteamInputRate()
end

function TI.GetEnergyStored(t)
    return t.getEnergy()
end

function TI.GetEnergyCapacity(t)
    return t.getEnergyCapacity()
end

function TI.GetEnergyProduction(t)
    return t.getProductionRate()
end

return TI