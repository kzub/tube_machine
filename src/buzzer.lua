print("Loading buzzer.lua") 

local wireBuzzer = 0
local isBuzzing = false
local buzMuted = false

gpio.mode(wireBuzzer, gpio.OUTPUT)

function buzzerOn ()
	if buzMuted then 
		return
	end
	isBuzzing = true
  gpio.write(wireBuzzer, gpio.LOW)
end

function buzzerOff ()
	isBuzzing = false
  gpio.write(wireBuzzer, gpio.HIGH)
end

function buzzerMute ()
	if buzMuted then 
		buzMuted = false 
	else 
		buzMuted = true
		buzzerOff()
	end
end

function buzzerBeep ()
	if isBuzzing then
		return
	end
	buzzerOn()
  tmr.create():alarm(200, tmr.ALARM_SINGLE, function()
	  buzzerOff()
	end)
end

buzzerBeep()
