require "cord"
sh = require "stormsh"
ACC = require "acc"
REG = require "reg"
LCD = require "lcd"

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

function lcd_setup()
    lcd = LCD:new(storm.i2c.EXT, 0x7c, storm.i2c.EXT, 0xc4)
end

function test_lcd()
    cord.new(function ()
        lcd:init(2, 1)
        lcd:writeString("THE INTERNET OF")
        lcd:setCursor(1, 0)
        lcd:writeString("THINGS, Spr '15")
        while true do
            lcd:setBackColor(255, 255, 0)
            cord.await(storm.os.invokeLater, storm.os.SECOND)
            lcd:setBackColor(0, 255, 0)
            cord.await(storm.os.invokeLater, storm.os.SECOND)
            lcd:setBackColor(255, 255, 255)
            cord.await(storm.os.invokeLater, storm.os.SECOND)
        end
    end)
end

acc_setup()
lcd_setup()


-- start a coroutine that provides a REPL
sh.start()

-- enter the main event loop. This puts the processor to sleep
-- in between events
cord.enter_loop()
