require("Instrumentation")
require("Control")

function main()
    -- Check reactor status
    reactor = peripheral.wrap("back")
    while true do
        ControlReactor(reactor, CreateReactorStatus(reactor))
        sleep(0.5)
    end
end

main()