require "cord"
require "svcd"
sh = require "stormsh"

service_id = 100
attr_id = 200
server_ip = "2001:470:4956:1:1cf:2c0b:f0af:2e86"
server_port = "7788"

sock = storm.net.udpsocket(server_port, function() end)


onReceive = function(pay, srcip, srcport) 
	print("got payload: ", pay, " from ", srcip, " portnum: ", srcport)
	local handle = cord.await(storm.net.sendto, sock, pay, server_ip, 7788)
	if handle ~= 1 then
		print "FAIL"
	else
		print "OK"
	end 
end


SVCD.init("bearcast-agent", function()
	print('initialized')
	SVCD.add_service(service_id)
	SVCD.add_attribute(service_id, attr_id, onReceive)
	--SVCD.advertise()	
end)

sendMessage = function()
	storm.net.sendto(sock, storm.mp.pack("hi"), server_ip, server_port)
end

sh.start()
cord.enter_loop()









