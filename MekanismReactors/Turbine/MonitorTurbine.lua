require("Instrumentation")
local logs = require("Logging")

function main()
    -- Initalize Logs
    logs.SetLogPaths("logs/Turbine/errors.log", "logs/Turbine/debug.log", "logs/Turbine/info.log")
    logs.OpenLogs()
    logs.RefreshLogs()

    -- Log Header
    logs.LogDebug("Steam Level (%), Steam Value (mB), Steam Input Rate (mb/t), Energy Stored (GFE), Energy Production (kFE/t)")
    print("Steam Level (%), Steam Value (mB), Steam Input Rate (mb/t), Energy Stored (GFE), Energy Production (kFE/t)")

    -- Check reactor status
    for _, perph_name in pairs(peripheral.getNames()) do
        if peripheral.getType(perph_name) == "turbineValve" then
            logs.LogInfo("Turbine found: " .. perph_name)
            turbine = peripheral.wrap(perph_name)
            break
        end
    end
    while true do
        status = GetTurbineStatus(turbine)
        logs.LogDebug(
            status.steam_level .. ", " ..
            status.steam_value .. ", " ..
            status.steam_input_rate .. ", " ..
            status.energy_stored .. ", " ..
            status.energy_production
        )
        print(status.steam_level .. ", " ..
            status.steam_value .. ", " ..
            status.steam_input_rate .. ", " ..
            status.energy_stored .. ", " ..
            status.energy_production)
        sleep(1) -- Run once per second
    end

    -- Ensure logs are closed on exit
    logs.CloseLogs()
end

main()