require "cord"
sh = require "stormsh"

-- start input and outputs

running = false
task = nil
value = 1

setup = function()
    storm.io.set_mode(storm.io.OUTPUT, storm.io.D2)
    storm.io.set(0, storm.io.D2)
end

start_oscilate = function(delay)
    -- body
    running = true
    storm.io.set_mode(storm.io.OUTPUT, storm.io.D2)
    storm.io.set(value, storm.io.D2)
    while true do
        value = 1 - value
        storm.io.set(value, storm.io.D2)
    end

end

stop_oscilate = function()
    -- body
    running = false
    storm.os.cancel(task)
end

-- start a coroutine that provides a REPL
sh.start()

-- enter the main event loop. This puts the processor to sleep
-- in between events
cord.enter_loop()
