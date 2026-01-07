require("Instrumentation")
local logs = require("Logging")

function main()
    -- Initalize Logs
    logs.OpenLogs()
    logs.RefreshLogs()

    -- Log Header
    logs.LogDebug("Steam Level (%), Steam Value (mB), Steam Input Rate (mb/t), Energy Stored (GFE), Energy Production (kFE/t)")

    -- Check reactor status
    turbine = peripheral.wrap("back")
    while true do
        status = GetTurbineStatus(turbine)
        logs.LogDebug(
            status.steam_level .. ", " ..
            status.steam_value .. ", " ..
            status.steam_input_rate .. ", " ..
            status.energy_stored .. ", " ..
            status.energy_production
        )
        sleep(1) -- Run once per second
    end

    -- Ensure logs are closed on exit
    logs.CloseLogs()
end

main()