local gui = require("/apis/gui")
require("/ReactorControl/MekanismReactors/Fission/Instrumentation")

function createActiveButton(display, reactor)
    local display_width, display_height = display.window:getSize()

    local activity_button = gui.Text:new {
        x = display_width - 9,
        y = 1,
        width = 8,
        height = 1,
    }
    display.window:addElement(activity_button)

    local function update(active)
        activity_button:setText(active and " active " or "inactive")
        activity_button:setBGColor(active and colors.green or colors.red)
    end
    function activity_button:monitor_touch(e)
        if e.display ~= peripheral.getName(display.device) then
            return
        end

        local active = reactor.getStatus()
        if active then
            reactor.scram()
        else
            reactor.activate()
        end
        update(reactor.getStatus())
    end

    update(reactor.getStatus())
    return activity_button
end

function createDebugLog(display, reactor)
    local display_width, display_height = display.window:getSize()

    local debug_log = gui.Text:new {
        x = 1,
        y = 1,
        width = display_width - 11,
        height = display_height - 2,
        bg_color = colors.white,
        text_color = colors.black,
        auto_scroll = true,
    }
    display.window:addElement(debug_log)

    debug_log.logging = false
    local function log()
        -- local status = {
        --     activity = false,
        --     fuel = 0,
        --     waste = 0,
        -- }
        local status = GetReactorStatus(reactor)

        debug_log:write( 
           "[" .. os.clock() .. "]\n"
            .. "Reactor Status: " .. (status.activity and "Active" or "Not Active")
            .. ", " .. status.fuel .. " mB"
            .. ", " .. status.waste .. " mB"
            .. "\n"
        )

        -- set timer until next log
        local time_to_wait = 1
        local timer_id = os.startTimer(time_to_wait)
        debug_log.timer = function(self, e)
            if e.id == timer_id then
                if debug_log.logging then
                    log()
                else
                    os.cancelTimer(timer_id)
                end
            end
        end
    end

    function debug_log.startLogging()
        debug_log.logging = true
        log()
    end

    function debug_log.endLogging()
        debug_log.logging = false
    end

    return debug_log
end

function createLogButton(display, debug_log)
    local display_width, display_height = display.window:getSize()

    -- [log: on ]
    -- [log: off]
    local log_button = gui.Text:new {
        x = display_width - 9,
        y = 1,
        width = 8,
        height = 1,
    }
    display.window:addElement(log_button)

    local function update()
        log_button:setText("log: " .. (debug_log.logging and "on" or "off"))
        log_button:setBGColor(debug_log.logging and colors.green or colors.red)
    end

    function log_button:monitor_touch(e)
        if e.display ~= peripheral.getName(display.device) then
            return
        end

        if not debug_log.logging then
            debug_log:startLogging()
        else
            debug_log:endLogging()
        end

        update()
    end

    update()
    return log_button
end
