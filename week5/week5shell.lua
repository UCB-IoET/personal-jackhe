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

init_adc = function ()
    storm.n.adcife_init()
end

init_a0 = function()
    return storm.n.adcife_new(storm.io.A0, storm.n.adcife_ADC_REFGND, storm.n.adcife_1X, storm.n.adcife_12BIT)
end

measure = function(adc)
    return (adc:sample() - 2047) * 3300 / 2047
end

contMeasure = function(adc)
    cord.new(function()
        while(run) do
        
        end
    end)
end

-- start a coroutine that provides a REPL
sh.start()

-- enter the main event loop. This puts the processor to sleep
-- in between events
cord.enter_loop()
