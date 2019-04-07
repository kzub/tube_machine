print("Loading app.lua") 

-- constants
local _delayBetweenChecks = 200
local _sensorFailsToDoStep = 5
local _motorStepsPerTube = 50
local _tubesMaxPos = 28

local programmWorks = false
local sensorFailsCount = 0
local tubesCurPos = 1

function startProgram() 
	laserOn()
	sensorFailsCount = 0
	tubesCurPos = 1
	programmWorks = true
end

function stopProgram() 
	programmWorks = false
	laserOff()
	buzzerOff()
end

--  loop routine
tmr.create():alarm(_delayBetweenChecks, tmr.ALARM_AUTO, function()
  if programmWorks == false then
  	return
  end

  if isSensorLight() == false then
  	print("sensor low:", sensorFailsCount + 1, "tube:", tubesCurPos)
  	sensorFailsCount = sensorFailsCount + 1
  end

  if sensorFailsCount >= _sensorFailsToDoStep then
  	print("switch to next tube:", tubesCurPos + 1)
  	buzzerBeep()
  	motorStep(_motorStepsPerTube)
  	sensorFailsCount = 0
  	tubesCurPos = tubesCurPos + 1
  end

  if tubesCurPos >= _tubesMaxPos then
  	print("buzzer on for last tube:", tubesCurPos)
  	buzzerOn()
  end

end)