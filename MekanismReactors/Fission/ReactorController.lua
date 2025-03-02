require("Instrumentation")
require("Control")
local logs = require("Logging")

function main()
    -- Initalize Logs
    logs.OpenLogs()
    logs.RefreshLogs()

    -- Log Header
    logs.LogDebug("Activity, Fuel (%), Heat (K), Waste (%), Coolant (%), Heated Coolant (%), Burn Rate (mb/t), Damage (%)")

    -- Check reactor status
    reactor = peripheral.wrap("back")
    while true do
        ControlReactor(reactor, GetReactorStatus(reactor))
        sleep(1) -- Run once per second
    end

    -- Ensure logs are closed on exit
    logs.CloseLogs()
end

main()