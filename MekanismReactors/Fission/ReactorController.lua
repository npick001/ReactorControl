require("Instrumentation")
require("Control")
local logs = require("Logging")

function main()
	-- Initalize Logs
	logs.SetLogPaths("logs/FissionReactor/errors.log", "logs/FissionReactor/debug.log", "logs/FissionReactor/info.log")
	logs.OpenLogs()
	logs.RefreshLogs()

	-- Log Header
	logs.LogDebug(
		"Activity, Fuel (%), Heat (K), Waste (%), Coolant (%), Heated Coolant (%), Burn Rate (mb/t), Damage (%)"
	)

	-- Check reactor status
	local reactor
	while not reactor do
		for _, perph_name in pairs(peripheral.getNames()) do
			if peripheral.getType(perph_name) == "fissionReactorLogicAdapter" then
				logs.LogInfo("Fission Reactor Logic Adapter found: " .. perph_name)
				reactor = peripheral.wrap(perph_name)
				break
			end
		end
	end

	while true do
		ControlReactor(reactor, GetReactorStatus(reactor))
		sleep(1) -- Run once per second
	end

	-- Ensure logs are closed on exit
	logs.CloseLogs()
end

main()
