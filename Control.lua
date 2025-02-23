-- Control.lua
---------------------------------------------------------------
--- Written 2025
--- This file is part of the Nuclear Reactor Control System I&C
--- For Bigger Reactors on the ATM9TTS 1.1.3 Server
--- Created by NP
---------------------------------------------------------------

function ControlReactor(reactor, status)
    -- control reactor based on passed status
    -- designed to be run each tick, make minor control adjustments
    print("Reactor Status[Active, Fuel Lvl, Waste Lvl, Stored Power]: " .. (status.activity and "Active" or "Not Active")
        .. ", " .. status.fuel .. " mB"
        .. ", " .. status.waste .. " mB"
        .. ", " .. status.power_stored .. " RF")

    -- if power is too high, deactivate reactor
    local power_capacity = reactor.battery().capacity()
    local power_upper_threshold = power_capacity * 0.95
    local power_lower_threshold = power_capacity * 0.05
    if status.power_stored >= power_upper_threshold then
        reactor.setActive(false)
        return
    end

    -- if power is too low, activate reactor
    if status.power_stored <= power_lower_threshold then
        reactor.setActive(true)
        return
    end

    -- if reactor is active, control rods
    if status.activity then 
        -- if heat is too high, step the rods in
        if status.fuel_heat >= 1500 then
            StepRodsInsert(reactor)
            return
        end

        -- if heat is too low, step the rods out
        if status.fuel_heat <= 1000 then
            StepRodsExtract(reactor)
            return
        end        
    end 
end

function StepRodsInsert(reactor)
    -- step rods
    num_rods = reactor.controlRodCount()

    for i = 0, num_rods - 1 do
        rod_depth = reactor.getControlRod(i).level()
        if rod_depth < 100 then
            reactor.getControlRod(i).setLevel(rod_depth + 1)
            print("Stepped rod " .. i .. " to depth " .. (rod_depth + 1))
        end
    end
end

function StepRodsExtract(reactor)
    -- step rods
    num_rods = reactor.controlRodCount()

    for i = 0, num_rods - 1 do
        rod_depth = reactor.getControlRod(i).level()
        if rod_depth > 0 then
            reactor.getControlRod(i).setLevel(rod_depth - 1)
            print("Stepped rod " .. i .. " to depth " .. (rod_depth - 1))
        end
    end
end