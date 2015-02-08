require "cord"
LCD = require "lcd"
LED = require "led"
Button = require "button"
ACC = require "acc"

-- Setup Section --

-------------------- Server --------------------

-- Server Main
	-- set up LCD (at I2C)
	-- set up button (plugged into D6)
	-- set up Buzzer (optional) (plugged into D2)
	-- set up network (on 47771) i.e. set up listening socket
	-- loop
		-- wait for start button to be pressed
		-- call storm.net.sendto funciton to send start packet to client
		-- wait until you receive an end packet from the client and close the listening socket -- use a signaling variable
		-- display the final result (do something fun)

--- call from network handler -- NOT IN MAIN LOOP
	-- check if it is an end packet
	-- if it is an end packet, flag the end signal variable and return
	-- else Compute Score (from payload, assuming INT data type)
	-- Get RGB values (map accel value to RGB value)
	-- Display Results (look at demo) (ascii bars & color)
	-- return


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
