print("Loading app.lua") 

-- constants
local _delayBetweenChecks = 200
local _sensorFailsToDoStep = 5
local _motorStepsPerTube = 201 -- ~5631 steps for 360 turnover
local _tubesMaxPos = 28

local programmWorks = false
local sensorFailsCount = 0
local tubesCurPos = 1
local wip = false

local circleCounts = 0

function measureCircle ()
  print("measureCircle")
  circleCounts = 0
  laserOn()
  buzzerBeep()
  measureCircleStep1()
end

function measureCircleStep1 () 
  if isSensorLight() == true then
    motorStep(1, measureCircleStep1)
  else
    print("measure marker length...")
    measureCircleStep2()
  end
end

function measureCircleStep2 () 
  if isSensorLight() == false then
      circleCounts = circleCounts + 1
      motorStep(1, measureCircleStep2)
  else
    print("marker length:", circleCounts)
    print("measure rest circle length...")
    measureCircleStep3()
  end
end

function measureCircleStep3 ()
  if isSensorLight() == true then
    circleCounts = circleCounts + 1
    motorStep(1, measureCircleStep3)
  else
    buzzerBeep()
    laserOff()
    print("full cirlce length:", circleCounts)
    print("tubes:", _tubesMaxPos)
    print("per tube:", circleCounts/_tubesMaxPos)
  end
end

function startProgram() 
	laserOn()
  buzzerBeep()
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
  if programmWorks == false or wip == true then
  	return
  end

  if isSensorLight() == false then
  	print("sensor low:", sensorFailsCount + 1, "tube:", tubesCurPos)
  	sensorFailsCount = sensorFailsCount + 1
  else
    sensorFailsCount = 0
  end

  if (sensorFailsCount >= _sensorFailsToDoStep) and (tubesCurPos < _tubesMaxPos) then
  	print("switch to next tube:", tubesCurPos + 1)
  	buzzerBeep()
    wip = true
  	motorStep(_motorStepsPerTube, function ()
      wip = false
    end)
  	sensorFailsCount = 0
  	tubesCurPos = tubesCurPos + 1
  end

  if tubesCurPos >= _tubesMaxPos then
  	print("buzzer on for last tube:", tubesCurPos)
  	buzzerOn()
  end

end)