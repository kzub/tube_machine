print("Loading motor.lua") 
local wire1 = 1
local wire2 = 2
local wire3 = 3
local wire4 = 4
local button = 5

local _motorStep = 50
local _delayBetweenSteps = 25 -- ms

gpio.mode(wire1, gpio.OUTPUT)--set four wires as output
gpio.mode(wire2, gpio.OUTPUT)
gpio.mode(wire3, gpio.OUTPUT)
gpio.mode(wire4, gpio.OUTPUT)
gpio.mode(button, gpio.INPUT, gpio.PULLUP)

function sequence(a, b, c, d)--four step sequence to stepper motor
  gpio.write(wire1, a)
  gpio.write(wire2, b)
  gpio.write(wire3, c)
  gpio.write(wire4, d)
end

local mRun = 0
local mRunTicks = 0

-- PUBLIC
function motorStep(count)
  if count > 0 then
    if mRunTicks < 0 then -- reset if opposite direction
      mRunTicks = 0
    end
  else
    if mRunTicks > 0 then -- reset if opposite direction
      mRunTicks = 0
    end
  end
  mRunTicks = mRunTicks + count
end

function motorStop()
  mRunTicks = 0
end

-- PRIVATE
function mCheckRun()
  if gpio.read(button) == 0 then 
    mRunTicks = _motorStep
  end

  if mRunTicks > 0 then
    mRunTicks = mRunTicks - 1
    return 1
  end

  if mRunTicks < 0 then
    mRunTicks = mRunTicks + 1
    return -1
  end

  return 0
end

function mBackwardStep ()
  sequence(gpio.HIGH, gpio.LOW, gpio.LOW, gpio.LOW)
  sequence(gpio.HIGH, gpio.HIGH, gpio.LOW, gpio.LOW)
  sequence(gpio.LOW, gpio.HIGH, gpio.LOW, gpio.LOW)
  sequence(gpio.LOW, gpio.HIGH, gpio.HIGH, gpio.LOW)
  sequence(gpio.LOW, gpio.LOW, gpio.HIGH, gpio.LOW)
  sequence(gpio.LOW, gpio.LOW, gpio.HIGH, gpio.HIGH)
  sequence(gpio.LOW, gpio.LOW, gpio.LOW, gpio.HIGH)
  sequence(gpio.HIGH, gpio.LOW, gpio.LOW, gpio.HIGH)
end

function mForwardStep ()
  sequence(gpio.LOW, gpio.LOW, gpio.LOW, gpio.HIGH)
  sequence(gpio.LOW, gpio.LOW, gpio.HIGH, gpio.HIGH)
  sequence(gpio.LOW, gpio.LOW, gpio.HIGH, gpio.LOW)
  sequence(gpio.LOW, gpio.HIGH, gpio.HIGH, gpio.LOW)
  sequence(gpio.LOW, gpio.HIGH, gpio.LOW, gpio.LOW)
  sequence(gpio.HIGH, gpio.HIGH, gpio.LOW, gpio.LOW)
  sequence(gpio.HIGH, gpio.LOW, gpio.LOW, gpio.LOW)
  sequence(gpio.HIGH, gpio.LOW, gpio.LOW, gpio.HIGH)
end

function mStop ()
  sequence(gpio.LOW, gpio.LOW, gpio.LOW, gpio.LOW)
end

-- motor loop routine
tmr.create():alarm(_delayBetweenSteps, tmr.ALARM_AUTO, function()
  if mRun > 0 then
    mForwardStep()
  elseif mRun < 0 then
    mBackwardStep()
  else
    mStop()
  end         
  mRun = mCheckRun()
end)


