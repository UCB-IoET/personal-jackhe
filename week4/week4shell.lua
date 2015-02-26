require "cord"
svcd = require "svcd"

function onconnect(state)
   if tmrhandle ~= nil then
       storm.os.cancel(tmrhandle)
       tmrhandle = nil
   end
   if state == 1 then
       storm.os.invokePeriodically(1*storm.os.SECOND, function()
           tmrhandle = storm.bl.notify(char_handle, 
              string.format("Time: %d", storm.os.now(storm.os.SHIFT_16)))
       end)
   end
end


storm.bl.enable("jacknode", onconnect, function()
   	local svc_handle = storm.bl.addservice(0x1348)
   	print("started service: " .. svc_handle)
   	char_handle = storm.bl.addcharacteristic(svc_handle, 0x1348, function(x)
       print ("received: " .. x)
   	end)
	print("done: " ..  char_handle)
end)

sh = require "stormsh"

-- start a coroutine that provides a REPL
sh.start()

cord.enter_loop()
