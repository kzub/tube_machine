print("Loading grabber.lua")

local minPositon = 140
local maxPosition = 350

local servoUsDelay = maxPosition
local wireServo = 5
local pulses = 100

gpio.mode(wireServo, gpio.OUTPUT)
gpio.write(wireServo, gpio.LOW)

function grabberSet (usDelay)
	pulses = 60
	servoUsDelay = usDelay
end

function grabberOn ()
	pulses = 60
	servoUsDelay = minPositon
end

function grabberOff ()
	pulses = 50
	servoUsDelay = maxPosition
end

function grabberChange ()
	if servoUsDelay == minPositon then
		grabberOff()
	else
		grabberOn()
	end
end

tmr.create():alarm(20, tmr.ALARM_AUTO, function()
	if pulses <= 0 then
		return
	end

	pulses = pulses - 1

    gpio.write(wireServo, gpio.HIGH)
    if servoUsDelay > 0 then
    	tmr.delay(servoUsDelay)
    end
    gpio.write(wireServo, gpio.LOW)
end)