function gimme_mons(filename)
-- read the layout.config file
-- return all the monitors aliased

-- "main_monitor" from "monitor_X"

    if fs.exists(filename) then
        local file = fs.open(filename, "r")
        if file then
            local monitors = {}
            local line = file.readLine()

            while line ~= nil do
                -- split each line into key and value
                local tokens = require "cc.strings".split(line, ":")
                local key = tokens[1]
                local value = tokens[2]

                -- wrap the peripheral and store it in the monitors table
                monitors[key] = peripheral.wrap(value)
            end

            for monitor in monitors do
                print("Monitor " .. monitor .. " mapped to " .. monitors[monitor].getName())
            end

            file.close()
            return monitors
        end
    end
end

return gimme_mons("layout.config")