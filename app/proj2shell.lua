require "cord"
sh = require "stormsh"
ACC = require "acc"
REG = require "reg"

function scan_i2c()
    for i=0x00,0xFE,2 do
        local arr = storm.array.create(1, storm.array.UINT8)
        local rv = cord.await(storm.i2c.read,  storm.i2c.INT + i,  
                        storm.i2c.START + storm.i2c.STOP, arr)
        if (rv == storm.i2c.OK) then
            print (string.format("Device found at 0x%02x",i ));
        end
    end
end

function acc_setup() 
	ac1 = ACC:new()
	cord.new(function() ac1:init() end)
end

function print_acc()
	while true do
		aax, aay, aaz = ac1:get_mg()
		print("aax = " .. aax .. " aay = " .. aay .." aaz = " .. aaz)
		cord.await(storm.os.invokeLater, 500*storm.os.MILLISECOND)
	end
end

acc_setup()


-- start a coroutine that provides a REPL
sh.start()

-- enter the main event loop. This puts the processor to sleep
-- in between events
cord.enter_loop()
