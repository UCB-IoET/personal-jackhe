require "cord"
LCD = require "lcd"
LED = require "led"
Button = require "button"
ACC = require "acc"
shield = require "starter"

-- Setup Section --

-------------------- Server --------------------

-- Server Main
function server_main()
	-- set up LCD (at I2C)
	lcd_setup()
	-- set up button (plugged into D6)
	shield.Button.start()
	btn1 = Button:new("D6")	
	-- set up Buzzer (optional) (plugged into D2)
	-- set up network (on 47771) i.e. set up listening socket
	--server = function() 
	ssock = storm.net.udpsocket(47771, s_handler)
	running = true
	-- loop
	while running do
		-- wait for start button to be pressed
		print("push button 1")
		shield.Button.when(1, "FALLING", btn1)
		-- call storm.net.sendto funciton to send start packet to client
		msg = "-2"
		storm.net.sendto(C_PORT, msg, "ff02::1", 47772)
		-- wait until you receive an end packet from the client and close the listening socket -- use a signaling variable
		-- display the final result (do something fun)
	end
end

--- call from network handler -- NOT IN MAIN LOOP
function s_handler(payload, from, port)
	print (string.format("from %s port %d: %s",from,port,payload))
	-- check if it is an end packet
	if payload == -1 then
		running = false
		return
	-- if it is an end packet, flag the end signal variable and return
	-- else Compute Score (from payload, assuming INT data type)
	else
		compute_score(payload)
	end
	-- Get RGB values (map accel value to RGB value)
	-- Display Results (look at demo) (ascii bars & color)
	-- return
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

--- Call either server or client main function here
cord.enter_loop()
