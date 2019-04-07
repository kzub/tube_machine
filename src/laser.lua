print("Loading laser.lua") 

local wireLaser = 1
gpio.mode(wireLaser, gpio.OUTPUT)

function laserOn ()
  gpio.write(wireLaser, gpio.HIGH)
end

function laserOff ()
  gpio.write(wireLaser, gpio.LOW)
end

-- laserOn() for start