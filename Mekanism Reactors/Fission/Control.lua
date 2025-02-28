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
    print((status.activity and "Active" or "Not Active")
        .. ", " .. status.fuel .. " mB"
        .. ", " .. status.heat .. " K"
        .. ", " .. status.waste .. " mB"
        .. ", " .. status.burn_rate .. " mb/t"
        .. ", " .. status.dmg_percent .. " %")

    -- if dmg is too high, shut down reactor
    -- make sure the reactor is active or an error will occur
    if status.dmg_percent >= 50 then
        reactor.scram()
        print("Reactor shut down due to high damage")
        return
    end

    -- if the reactor is too hot, shut it down
    if status.heat >= 1000 then
        reactor.scram()
        print("Reactor shut down due to high heat")
        return
    end

    -- if reactor is active, control rods
    if status.activity then 
        -- if heat is too high, step the rods in
        --if status.fuel_heat >= 1500 then
            --StepRodsInsert(reactor)
        --    return
        --end

        -- if heat is too low, step the rods out
        --if status.fuel_heat <= 1000 then
            --StepRodsExtract(reactor)
        --    return
        --end        
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