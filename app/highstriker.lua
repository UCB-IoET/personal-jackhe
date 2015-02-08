require "cord"
LCD = require "lcd"
LED = require "led"
Button = require "button"
ACC = require "acc"

-- Setup Section --
function acc_setup()
	ac1 = ACC:new()
	cord.new(function()
		ac1:init()
		ac1:calibrate()
	end)
end

function lcd_setup()
	lcd = LCD:new(storm.i2c.EXT, 0x7c, storm.i2c.EXT, 0xc4)
end

function wait_ms(period)
	cord.await(storm.os.invokeLater, period*storm.os.MILLISECOND)
end

C_PORT = 47772
S_PORT = 47771

button_block = true

-------------------- Server --------------------

-- Server Main
function server_main()
	-- set up LCD (at I2C)
	lcd_setup()
	-- set up button (plugged into D6)
	btn1 = Button:new("D6")
	btn1:whenever("RISING",function() button_block = false end)
	-- set up Buzzer (optional) (plugged into D2)
	-- set up network (on 47771) i.e. set up listening socket
	--server = function()
	ssock = storm.net.udpsocket(S_PORT, s_handler)
	-- loop
	while true do
		-- wait for start button to be pressed
		print("push button 1")
		while button_block do
			wait_ms(10)
		end
		button_block = true
		-- call storm.net.sendto funciton to send start packet to client
		msg = "-2"
		-- TODO: Hack, change later for ACK based handshake
		for i = 1, 5 do
			storm.net.sendto(C_PORT, msg, "ff02::1", 47772)
		end
		-- wait until you receive an end packet from the client and close the listening socket -- use a signaling variable
		-- display the final result (do something fun)
		running = true
		while running do
			wait_ms(10)
		end
	end
end



--- call from network handler -- NOT IN MAIN LOOP
function s_handler(payload, from, port)
	print (string.format("from %s port %d: %s",from,port,payload))
	-- check if it is an end packet
	local num = tonumber(payload)
	if num == -1 then
		running = false
		return
	-- if it is an end packet, flag the end signal variable and return
	-- else Compute Score (from payload, assuming INT data type)
	else
		compute_score(num)
	end
	-- Get RGB values (map accel value to RGB value)
	-- Display Results (look at demo) (ascii bars & color)
end

-- what is a minimum accel score??
function compute_score(x)
	r = math.max((-510*x)/255 + 255, 0)
	b = math.min(510*x/255,255)
	g = math.max(510*x/255 - 255,0)
	lcd:setBackColor(r,g,b)
	lcd:init(2, 1)
    lcd:writeString("Score: " .. x)
end

-------------------- Client --------------------

-- Client Main
	-- set up accelerometer
	-- set up network (port 47772)

-- Client network handler
	-- check if it is a start packet if yes continue
	-- clear the old max score
	-- start tracking accl readings to compute the magnitude of the acceleration
	-- normalize it to 0-255 with 0 be 0, 255 be 4g
	-- keep track of the max every 50ms
	-- the total time for this should be less than 2s
	-- at 2s send the max back to server

client_running = false

function client_main()
	acc_setup()
	-- create client socket
	csock = storm.net.udpsocket(C_PORT, client_handler)
	print("Started Client")
end

client_handler = function(payload, from, port)
	if client_running then
		return
	end
	client_running  = true
	print (string.format("received from %s port %d: %s",from,port,payload))
	local max_acc = 0
	local period = 50
	local count = 2000 / 50
	local aax, aay, aaz, m, m_norm = 0, 0, 0, 0, 0
	while count > 0 do
		aax, aay, aaz = ac1:get_mg()
		print("aax = " .. aax .. " aay = " .. aay .." aaz = " .. aaz)
		m = math.sqrt(aax^2 + aay^2 + aaz^2) - 1000 -- remove gravity
		m_norm = m * 255 / 10000
		max_acc = math.max(m_norm, max_acc)
		print("max accl = " .. max_acc)
		wait_ms(50)
		count = count - 1
	end
	storm.net.sendto(csock, tostring(max_acc), "ff02::1", S_PORT)
	print(string.format("finished measurement, max accl: %d", max_acc))
	wait_ms(100)
	storm.net.sendto(csock, "-1", "ff02::1", S_PORT)
	print("sent end")
	client_running = false
end

--- Call either server or client main function here

--- temp shell
sh = require "stormsh"
sh.start()
cord.enter_loop()
