print("Loading buzzer.lua") 

local wireBuzzer = 1
gpio.mode(wireBuzzer, gpio.OUTPUT)

function buzzerOn ()
  gpio.write(wireBuzzer, gpio.LOW)
end

function buzzerOff ()
  gpio.write(wireBuzzer, gpio.HIGH)
end

function buzzerBeep ()
  buzzerOn()
  tmr.create():alarm(200, tmr.ALARM_SINGLE, function()
	  buzzerOff ()
	end)
end

-- buzzerOn() for start