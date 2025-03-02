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

-- Status variables
local previous_status = {}
local coolant_derivative = 0 -- will be used to determine if coolant is increasing or decreasing
local fuel_derivative = 0 -- will be used to determine if fuel is increasing or decreasing
local force_scrammed = false

-- Rolling average for burn rate calculations
--local burn_rate_rolling_avg = logs.LoadBurnRate() -- rolling average of the burn rate
local burn_rate_rolling_avg = 9.2 -- default burn rate for initial transient period
local alpha = 0.1 -- smoothing factor for the rolling average for exponential smoothing

-- Burn rate stability control, when burn rate stablizes, write to file for 
-- reading in on startup. This removes burn rate transient periods on startup
local burn_rate_stable_threshold = 0.05  -- Max allowed change for stability
local stability_ticks_required = 20      -- Number of ticks to consider stable
local stability_tick_count = 0

-- control reactor based on passed status
-- designed to be run each tick, making minor control adjustments   
function ControlReactor(reactor, status)
    logs.OpenLogs()

    if not status then
        logs.LogError("ERROR: ControlReactor(): No reactor status provided")
        return
    end

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

    -- Try to reactivate the reactor if it was force scrammed
    if force_scrammed then
        RC.TryReactivatingReactor(reactor, status)
    end
end

---------------------------------------------------------------
---
--- Control Functions
---
---------------------------------------------------------------
-- Log changes in reactor state
function RC.LogStateChanges(previous, current)
    -- Handle the edge case of no previous status
    if previous.fuel == nil then
        logs.LogError("No previous status provided")
        return
    end

    -- check for reactor activity changes
    if previous.activity ~= current.activity then
        logs.LogInfo("Reactor is now " .. (current.activity and "active" or "inactive"))
    end

    -- check for fuel burn rate changes
    if previous.burn_rate ~= current.burn_rate then
        logs.LogInfo("Burn rate changed to " .. current.burn_rate .. " mb/t")

        -- calculate the rolling average of the burn rate using exponential smoothing
        -- for more info on this algorithm view: https://en.wikipedia.org/wiki/Exponential_smoothing
        -- essentially uses a smoothing factor and uses the properies of time series to smooth the value
        -- over time to arrive at the "best" burn rate for the reactor based on input data (fuel rate, coolant rate)
        burn_rate_rolling_avg = (alpha * current.burn_rate) + ((1 - alpha) * burn_rate_rolling_avg)

        logs.LogInfo("Updated rolling average burn rate: " .. string.format("%.2f", burn_rate_rolling_avg) .. " mb/t")
    end

    -- check for fuel level changes
    -- goal is to have derivative == 0 for stable fuel levels
    -- used to determine the optimal burn rate based on the fuel and coolant intake
    if previous.fuel ~= current.fuel then
        logs.LogInfo("Fuel level changed to " .. current.fuel .. " %")

        fuel_derivative = current.fuel - previous.fuel
        if fuel_derivative > 0 then
            logs.LogInfo("Fuel level is increasing, can increase burn rate")
        elseif fuel_derivative < 0 then
            logs.LogInfo("Fuel level is decreasing, should reduce burn rate")
        end
    else
        fuel_derivative = 0
    end

    -- check for coolant derivative changes
    -- goal is to have derivative == 0 for stable coolant levels
    -- used to determine the optimal burn rate based on the coolant intake
    if previous.coolant ~= current.coolant then
        logs.LogInfo("Coolant level changed to " .. current.coolant .. " %")

        coolant_derivative = current.coolant - previous.coolant
        if coolant_derivative > 0 then
            logs.LogInfo("Coolant level is increasing, increase burn rate")
        elseif coolant_derivative < 0 then
            logs.LogInfo("Coolant level is decreasing, reduce burn rate")
        end
    else 
        coolant_derivative = 0
    end
end

-- Old burn rate functions left here for reference
function RC.IncreaseBurnRate(reactor)
    local current_burn_rate = burn_rate_rolling_avg
    reactor.setBurnRate(math.min(current_burn_rate + 0.1, reactor.getMaxBurnRate()))
    logs.LogDebug("Increasing burn rate to " .. (current_burn_rate + 0.1) .. " mb/t")
end
function RC.DecreaseBurnRate(reactor)
    local current_burn_rate = burn_rate_rolling_avg
    reactor.setBurnRate(math.max(current_burn_rate - 0.2, 0)) -- Ensuring it doesn't go negative
    logs.LogDebug("Decreasing burn rate to " .. (current_burn_rate - 0.2) .. " mb/t")
end

function RC.Scram(r)
    force_scrammed = true
    r.scram()
end

function RC.CheckCoolantLevels(r, status)
    -- if coolant level is low, shut down reactor
    if not status then
        logs.LogError("CheckCoolantLevels Function: No reactor status provided")
        return
    end
    local coolant_level = status.coolant
    if coolant_level <= 20 and status.activity then
        RC.Scram(r)
        logs.LogError("Reactor shut down due to low coolant")
        logs.LogDebug("ERROR: Reactor shut down due to low coolant")
        return
    end
end

function RC.CheckHeatedCoolantLevels(r, status)
    -- if heated coolant level is high, shut down reactor
    local heated_coolant_level = status.heated_coolant
    if heated_coolant_level >= 80 and status.activity then
        RC.Scram(r)
        logs.LogError("Reactor shut down due to high heated coolant level")
        logs.LogDebug("ERROR: Reactor shut down due to high heated coolant level")
        return
    end
end

function RC.MitigateDamage(r, status)
    -- Critical Damage
    -- Never should be on
    if status.dmg_percent >= 80 then     
        if status.activity then
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
        if status.activity then
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
    if status.heat >= 1000 and status.activity then
        RC.Scram(r)
        logs.LogError("Reactor shut down due to high heat")
        logs.LogDebug("ERROR: Reactor shut down due to high heat")
        return
    end
end

function RC.MaintainFuelLevel(r, status)
    -- if fuel level is low, shut down reactor
    local fuel_level = status.fuel

    --logs.LogInfo("Fuel level: " .. fuel_level)
    if fuel_level <= 10 then
        RC.Scram(r)
        logs.LogDebug("ERROR: Reactor shut down due to low fuel")
        logs.LogInfo("Low fuel level detected, reactor shut down")
        return
    end

    RC.OptimizeBurnRate(r, status)    
end

function RC.ManageWasteLevels(r, status)
    -- if waste level is high, shut down reactor
    local waste_level = status.waste
    if waste_level >= 80 and status.activity then
        RC.Scram(r)
        logs.LogError("Reactor shut down due to high waste")
        logs.LogDebug("ERROR: Reactor shut down due to high waste")
        logs.LogInfo("High waste level detected, reactor shut down")
        return
    end
end

function RC.OptimizeBurnRate(r, status)
    local new_burn_rate = burn_rate_rolling_avg  -- Use the smoothed burn rate

    local coolant_above_threshold = status.coolant >= 50
    local fuel_above_threshold = status.fuel >= 50

    local coolant_increasing = coolant_derivative >= 0 and coolant_above_threshold
    local fuel_increasing = fuel_derivative >= 0 and fuel_above_threshold

    -- Adjust burn rate based on coolant and fuel trends
    if coolant_increasing and fuel_increasing then
        new_burn_rate = new_burn_rate + 0.1
    elseif coolant_derivative < 0 and fuel_derivative < 0 then
        new_burn_rate = new_burn_rate - 0.1
    elseif coolant_increasing and fuel_derivative == 0 then
        new_burn_rate = new_burn_rate + 0.1
    elseif coolant_derivative < 0 and fuel_derivative == 0 then
        new_burn_rate = new_burn_rate - 0.1
    end

    -- Smooth out the burn rate using a rolling average
    burn_rate_rolling_avg = (burn_rate_rolling_avg * 0.9) + (new_burn_rate * 0.1)
    reactor.setBurnRate(burn_rate_rolling_avg)

    -- Check if fluctuations have subsided
    if math.abs(burn_rate_rolling_avg - new_burn_rate) < burn_rate_stable_threshold then
        stability_tick_count = stability_tick_count + 1
    else
        -- Reset if fluctuation is detected
        stability_tick_count = 0
    end

    -- Only save the burn rate if stability is maintained
    if stability_tick_count >= stability_ticks_required then
        logs.SaveBurnRate(burn_rate_rolling_avg)
        logs.LogInfo("Burn rate stabilized at " .. burn_rate_rolling_avg .. ", saving to file.")
        stability_tick_count = 0
    end
end

function RC.TryReactivatingReactor(r, status)
    -- Check all the reactor status items, only if these items are within
    -- the acceptable range, should the reactor be reactivated

    -- coolant     
    -- fuel 
    -- heated coolant
    -- waste
    -- damage
    -- heat
    local coolant_acceptable = status.coolant >= 70 and coolant_derivative >= 0
    local fuel_acceptable = status.fuel >= 70 and fuel_derivative >= 0
    local heated_coolant_acceptable = status.heated_coolant <= 50
    local waste_acceptable = status.waste <= 50
    local damage_acceptable = status.dmg_percent <= 10
    local heat_acceptable = status.heat <= 800

    if coolant_acceptable and fuel_acceptable and
        heated_coolant_acceptable and waste_acceptable and
        damage_acceptable and heat_acceptable then
        r.activate()
        logs.LogInfo("Reactor reactivated after all systems checked and declared acceptable for startup")
        force_scrammed = false -- once we reactivate, the reactor was no longer force scrammed
    end
end