print("Loading app.lua")

-- constants
local _delayBetweenChecks = 100
local _sensorFailsToDoStep = 5
local _motorStepsPerTube = 201 -- ~5633 steps for 360 turnover
local _tubesMaxPos = 28 --

local programmWorks = false
local sensorFailsCount = 0
local tubesCurPos = 1
local wip = false
---------------------------------------------------------------------------------
-- ставим что-то тонкое и замеряем сколько шагов двигателя занимает полный оборот
---------------------------------------------------------------------------------
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
    print("per tube:", circleCounts / _tubesMaxPos)
  end
end
---------------------------------------------------------------------------------
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
---------------------------------------------------------------------------------

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
    grabberOn()
  	buzzerBeep()
    wip = true

    tmr.create():alarm(1200, tmr.ALARM_SINGLE, function()
    	motorStep(_motorStepsPerTube, function ()
        wip = false
        grabberOff()
      end)
    end)
  	sensorFailsCount = 0
  	tubesCurPos = tubesCurPos + 1
  end

  if tubesCurPos >= _tubesMaxPos then
  	print("buzzer on for last tube:", tubesCurPos)
    grabberOn()
  	buzzerOn()
    laserOff()
    wip = true
  end

end)

---------------------------------------------------------------------------------
