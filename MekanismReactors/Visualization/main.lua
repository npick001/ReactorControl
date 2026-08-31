local gui = require("/apis/gui")
require("/ReactorControl/MekanismReactors/Fission/Control")
-- require("/ReactorControl/MekanismReactors/Fission/Logging")
-- local Reactor = require("/apis/reactor")
-- local Controller = require("Control")

require("Elements")

function main()
    local reactor = peripheral.wrap("back")
    for _, perph_name in pairs(peripheral.getNames()) do
        if peripheral.getType(perph_name) == "fissionReactorLogicAdaptor" then
            logs.LogInfo("Fission Reactor Logic Adaptor found: " .. perph_name)
            reactor = peripheral.wrap(perph_name)
            break
        end
    end
    
    local monitor_0, monitor_1 = initMonitors()

    local main_display = gui.initializeDisplay(monitor_0)
    local debug_display = gui.initializeDisplay(monitor_1)
    local activity_button = createActiveButton(main_display, reactor)
    local debug_log = createDebugLog(debug_display, reactor)
    local log_button = createLogButton(debug_display, debug_log)

    while true do
        -- Controller.control(reactor, status, debug_log)
        -- ControlReactor(reactor, GetReactorStatus(reactor))

        main_display:render()
        debug_display:render()
        parallel.waitForAny(delta, gui.doEvents)
    end
end

function reactorControl()

end

function delta()
    sleep(0.5)
end

function initMonitors()
    local monitor_0 = peripheral.wrap("monitor_0")
    local monitor_1 = peripheral.wrap("monitor_1")

    monitor_0.setTextScale(1)
    monitor_0.clear()
    monitor_0.setCursorPos(1, 1)

    monitor_1.setTextScale(0.5)
    monitor_1.clear()
    monitor_1.setCursorPos(1, 1)

    return monitor_0, monitor_1
end

main()
