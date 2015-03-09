
require "cord"
sh = require "stormsh"
sh.start()
-- in global scope now
require "svcd"

probes = {}

cord.new(function()
    cord.await(SVCD.init, "adcclient")
    SVCD.advert_received = function(pay, srcip, srcport)
        local adv = storm.mp.unpack(pay)
        for k,v in pairs(adv) do
            --These are the services
            if k == 0x3003 then
                --Characteristic
                for kk,vv in pairs(v) do
                    if vv == 0x4005 and k == 0x3003 then
                        -- This is an ADC measure service
                        if probes[srcip] == nil then
                            print ("Discovered ADC probe: ", srcip)
                        end
                        probes[srcip] = storm.os.now(storm.os.SHIFT_16)
                    end
                end
            end
        end
    end
end)

function measure(serial, adc)
    SVCD.subscribe("fe80::212:6d02:0:"..serial,0x3003, 0x4010, function(msg)
        local arr = storm.array.fromstr(msg)
        print ("Got Measurement: ",arr:get_as(storm.array.INT32, 0)
    end)
    cord.new(function()
        local cmd = storm.array.create(2, storm.array.UINT8)
        cmd:set(1, adc)
        local stat = cord.await(SVCD.write, "fe80::212:6d02:0:"..serial, 0x3003, 0x4005, cmd:as_str(), 300)
        if stat ~= SVCD.OK then
            print "FAIL"
        else
            print "OK"
        end
        -- don't spam
        cord.await(storm.os.invokeLater,50*storm.os.MILLISECOND)
    end)
end

function get_motd(serial)
    SVCD.subscribe("fe80::212:6d02:0:"..serial,0x3003, 0x4008, function(msg)
        local arr = storm.array.fromstr(msg)
        print ("Got MOTD: ",arr:get_pstring(0))
    end)
end

cord.enter_loop()

