local Logging = {}

-- Log file paths
local err_log = "ReactorControl/logs/error.log"
local debug_log = "ReactorControl/logs/debug.log"
local info_log = "ReactorControl/logs/info.log"

local tick_count = 0 -- Track tick count for flushing

-- Get the current time in HH:MM:SS format
local function GetTimestamp()
    local time = textutils.formatTime(os.time(), true) -- 24-hour format
    return "[" .. time .. "] "
end

function Logging.OpenLogs()
    if not Logging.ERRORS then Logging.ERRORS = fs.open(err_log, "a") end
    if not Logging.DEBUG then Logging.DEBUG = fs.open(debug_log, "a") end
    if not Logging.INFO then Logging.INFO = fs.open(info_log, "a") end
end

function Logging.RefreshLogs()
    if Logging.ERRORS then Logging.ERRORS.close(); Logging.ERRORS = fs.open(err_log, "w") end
    if Logging.DEBUG then Logging.DEBUG.close(); Logging.DEBUG = fs.open(debug_log, "w") end
    if Logging.INFO then Logging.INFO.close(); Logging.INFO = fs.open(info_log, "w") end
end

function Logging.LogDebug(message)
    if Logging.DEBUG then
        Logging.DEBUG.writeLine(GetTimestamp() .. message)
    end
end

function Logging.LogError(message)
    if Logging.ERRORS then
        Logging.ERRORS.writeLine(GetTimestamp() .. "ERROR: " .. message)
    end
end

function Logging.LogInfo(message)
    if Logging.INFO then
        Logging.INFO.writeLine(GetTimestamp() .. message)
    end
end

function Logging.FlushLogs()
    tick_count = tick_count + 1
    if tick_count % 20 == 0 then  -- Flush every 20 ticks (1 second)
        if Logging.DEBUG then Logging.DEBUG.flush() end
        if Logging.ERRORS then Logging.ERRORS.flush() end
        if Logging.INFO then Logging.INFO.flush() end
    end
end

function Logging.CloseLogs()
    if Logging.ERRORS then Logging.ERRORS.close(); Logging.ERRORS = nil end
    if Logging.DEBUG then Logging.DEBUG.close(); Logging.DEBUG = nil end
    if Logging.INFO then Logging.INFO.close(); Logging.INFO = nil end
end

return Logging
