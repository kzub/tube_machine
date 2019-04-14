print("Loading laser.lua") 

local wireLaser = 6
local laserIsOn = false
gpio.mode(wireLaser, gpio.OUTPUT)

function laserOn ()
	laserIsOn = true
  gpio.write(wireLaser, gpio.HIGH)
end

function laserOff ()
	laserIsOn = false
  gpio.write(wireLaser, gpio.LOW)
end

function laserBeep ()
  laserOn()
  tmr.create():alarm(2000, tmr.ALARM_SINGLE, function()
	  laserOff ()
	end)
end

function laserPower ()
	if laserIsOn then 
		laserOff()
	else
		laserOn()
	end
end

laserBeep()