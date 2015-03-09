
require "cord"
require "math"
require "svcd"

storm.n.adcife_init()

channels = {
    "A0" = storm.n.adcife_new(storm.io.A0, storm.n.adcife_ADC_REFGND, storm.n.adcife_1X, storm.n.adcife_12BIT),
    "A1" = storm.n.adcife_new(storm.io.A1, storm.n.adcife_ADC_REFGND, storm.n.adcife_1X, storm.n.adcife_12BIT),
    "A2" = storm.n.adcife_new(storm.io.A2, storm.n.adcife_ADC_REFGND, storm.n.adcife_1X, storm.n.adcife_12BIT),
    "A3" = storm.n.adcife_new(storm.io.A3, storm.n.adcife_ADC_REFGND, storm.n.adcife_1X, storm.n.adcife_12BIT),
    "A4" = storm.n.adcife_new(storm.io.A4, storm.n.adcife_ADC_REFGND, storm.n.adcife_1X, storm.n.adcife_12BIT),
    "A5" = storm.n.adcife_new(storm.io.A5, storm.n.adcife_ADC_REFGND, storm.n.adcife_1X, storm.n.adcife_12BIT),
}

MOTDs = {"Default message!!" }

SVCD.init("adcprobe", function()
    print "starting"
    SVCD.add_service(0x3003)
    -- LED flash attribute
    SVCD.add_attribute(0x3003, 0x4005, function(pay, srcip, srcport)
        local ps = storm.array.fromstr(pay)
        local adcch = ps:get(1)
        print ("got a request to measure adc",adcch)
        local value_mv = (channels[adcch]:sample() - 2047) * 3300 / 2047
        local val = storm.array.create(1, storm.array.INT32)
        val:set(1, value_mv)
        SVCD.notify(0x3003, 0x4010, val:as_str())
    end)
    -- LED control attribute
    SVCD.add_attribute(0x3003, 0x4006, function(pay, srcip, srcport)
        local ps = storm.array.fromstr(pay)
        local lednum = ps:get(1)
        local duration = ps:get_as(storm.array.INT16, 1)
        print ("got a request to turn on led",lednum, " for ", duration)
        local target
        if lednum == 0 then
            target=lr
        end
        if lednum == 1 then
            target=lg
        end
        if lednum == 2 then
            target=lb
        end

        if duration > 0 then
            target:on()
            storm.os.invokeLater(duration*storm.os.MILLISECOND, function()
                target:off()
            end)
        elseif duration == 0 then
            target:off()
        else
            target:on()
        end
    end)

    -- MOTD attribute
    SVCD.add_attribute(0x3003, 0x4008, function(pay, srcip, srcport)
        local parr = storm.array.fromstr(pay)
        -- Little hack to trim the length of the string to 19 max
        -- Because the bluetooth notify only allows 20
        if parr:get(1) > 19 then parr:set(1, 19) end
        -- remember that in our protocol we use pascal strings
        table.insert(MOTDs, parr:get_pstring(0))
    end)

    cord.new(function()
        while true do
            local msg = MOTDs[math.random(1,#MOTDs)]
            local arr = storm.array.create(#msg+1,storm.array.UINT8)
            arr:set_pstring(0, msg)
            SVCD.notify(0x3003, 0x4008, arr:as_str())
            cord.await(storm.os.invokeLater, 3*storm.os.SECOND)
        end
    end)
end)


cord.enter_loop()

