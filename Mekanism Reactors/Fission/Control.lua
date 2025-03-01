-- Control.lua
---------------------------------------------------------------
--- Written 2025
--- This file is part of the Nuclear Reactor Control System I&C
--- For Bigger Reactors on the ATM9TTS 1.1.3 Server
--- Created by NP
---------------------------------------------------------------
local RC = {}

-- Logging files
local logs = require("Logging")
local previous_status = {}

function ControlReactor(reactor, status)
    logs.OpenLogs()

    if not status then
        logs.LogError("ERROR: ControlReactor(): No reactor status provided")
        return
    end

    -- control reactor based on passed status
    -- designed to be run each tick, make minor control adjustments   

    -- Log reactor status
    logs.LogDebug(
        (status.activity and "Active" or "Not Active") ..
        ", " .. status.fuel .. " %" ..
        ", " .. status.heat .. " K" ..
        ", " .. status.waste .. " %" ..
        ", " .. status.coolant .. " %" ..
        ", " .. status.heated_coolant .. " %" ..
        ", " .. status.burn_rate .. " mb/t" ..
        ", " .. status.dmg_percent .. " %"
    )

    -- Control Reactor Systems
    RC.LogStateChanges(previous_status, status)
    RC.CheckCoolantLevels(reactor, status)
    RC.CheckHeatedCoolantLevels(reactor, status)
    RC.MitigateDamage(reactor, status)
    RC.ControlTemperature(reactor, status)
    RC.MaintainFuelLevel(reactor, status)
    RC.ManageWasteLevels(reactor, status)
    
    -- Write log updates, flushing the buffers
    logs.FlushLogs()

    previous_status = status
end

---------------------------------------------------------------
---
--- Control Functions
---
---------------------------------------------------------------
-- Log changes in reactor state
function RC.LogStateChanges(previous, current)
    
    -- check for reactor status changes
    if previous.activity ~= current.activity then
        logs.LogInfo("Reactor is now " .. (current.activity and "active" or "inactive"))
    end

    -- check for fuel burn rate changes
    if previous.burn_rate ~= current.burn_rate then
        logs.LogInfo("Burn rate changed to " .. current.burn_rate .. " mb/t")
    end
end

function RC.IncreaseBurnRate(reactor)
    -- slowly increase burn rate

end

function RC.DecreaseBurnRate(reactor)
    -- slowly decrease burn rate
end

function RC.Scram(r)
    r.scram()
end

function RC.CheckCoolantLevels(r, status)
    --logs.LogInfo("CheckCoolantLevels")
    -- if coolant level is low, shut down reactor
    if not status then
        logs.LogError("CheckCoolantLevels Function: No reactor status provided")
        return
    end
    local coolant_level = status.coolant
    if coolant_level <= 20 and r.activity then
        RC.Scram(r)
        logs.LogError("Reactor shut down due to low coolant")
        logs.LogDebug("ERROR: Reactor shut down due to low coolant")
        return
    end
end

function RC.CheckHeatedCoolantLevels(r, status)
    --logs.LogInfo("CheckHeatedCoolantLevels")
    -- if heated coolant level is high, shut down reactor
    local heated_coolant_level = status.heated_coolant
    if heated_coolant_level >= 80 and r.activity then
        RC.Scram(r)
        logs.LogError("Reactor shut down due to high heated coolant level")
        logs.LogDebug("ERROR: Reactor shut down due to high heated coolant level")
        return
    end
end

function RC.MitigateDamage(r, status)
    --logs.LogInfo("MitigateDamage")

    -- Critical Damage
    -- Never should be on
    if status.dmg_percent >= 80 then     
        if r.activity then
            RC.Scram(r)
            logs.LogError("Reactor shut down due to critical damage")
            logs.LogDebug("ERROR: Reactor shut down due to critical damage")
        else
            logs.LogInfo("Critical reactor damage detected, but reactor is already shut down")
        end  
        return
    end

    -- Moderate to High Damage
    -- Never should be on
    if status.dmg_percent >= 30 and status.dmg_percent <= 79 then     
        if r.activity then
            RC.Scram(r)
            logs.LogError("Reactor shut down due to high damage")
            logs.LogDebug("ERROR: Reactor shut down due to high damage")
        else
            logs.LogInfo("High reactor damage detected, but reactor is already shut down")
        end  
        return
    end

    -- Low Damage
    -- Can be on if necessary
    if status.dmg_percent >= 10 and status.dmg_percent <= 29 then
        logs.LogInfo("Low reactor damage detected")
        return
    end
end

function RC.ControlTemperature(r, status)
    --logs.LogInfo("ControlTemperature")
    if status.heat >= 1000 then
        RC.Scram(r)
        logs.LogError("Reactor shut down due to high heat")
        logs.LogDebug("ERROR: Reactor shut down due to high heat")
        return
    end
end

function RC.MaintainFuelLevel(r, status)
    --logs.LogInfo("MaintainFuelLevel")

    -- if fuel level is low, shut down reactor
    local fuel_level = status.fuel

    --logs.LogInfo("Fuel level: " .. fuel_level)
    if fuel_level <= 10 then
        RC.Scram(r)
        logs.LogDebug("ERROR: Reactor shut down due to low fuel")
        logs.LogInfo("Low fuel level detected, reactor shut down")
        return
    end

    -- if fuel level is high, increase burn rate
    -- TODO: Create algorithm for handling incrementally increasing burn rate SAFELY
    if fuel_level >= 90 then
        RC.IncreaseBurnRate(r)
        --logs.LogDebug("Increased burn rate due to high fuel level")
        --logs.LogInfo("High fuel level detected, increased burn rate")
        return
    end
end

function RC.ManageWasteLevels(r, status)
    --logs.LogInfo("ManageWasteLevels")

    -- if waste level is high, shut down reactor
    local waste_level = status.waste
    if waste_level >= 80 then
        RC.Scram(r)
        logs.LogDebug("ERROR: Reactor shut down due to high waste")
        logs.LogInfo("High waste level detected, reactor shut down")
        return
    end
end