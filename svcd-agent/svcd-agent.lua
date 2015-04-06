require "cord"
require "svcd"
sh = require "stormsh"

service_id = 0x3030
attr_id = 0x4040
server_ip = "2001:470:1f04:5f2::2"
server_port = "7788"

sock = storm.net.udpsocket(server_port, function() end)


onReceive = function(pay, srcip, srcport) 
	print("got payload: ", pay, " from ", srcip, " portnum: ", srcport)
	-- local handle = cord.await(storm.net.sendto, sock, pay, server_ip, 7788)
	--if handle ~= 1 then
	--	print "FAIL"
	--else
	--	print "OK"
	--end 
	SVCD.notify(0x3050, 0x4050, 'what')
end


SVCD.init("bearcast-agent", function()
	print('initialized')
	SVCD.add_service(service_id)
	SVCD.add_attribute(service_id, attr_id, onReceive)
	--cord.new(function()
	--	while true do
	--		SVCD.notify(0x3030, 0x4040, 'what')
	--		cord.await(storm.os.invokeLater, 3*storm.os.SECOND)
	--	end
	--end)
end)

sendMessage = function()
	storm.net.sendto(sock, storm.mp.pack("hi"), server_ip, server_port)
	print('send message')
end

sh.start()
cord.enter_loop()









