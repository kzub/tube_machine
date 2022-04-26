print("Loading motor.lua")
local wire1 = 1
local wire2 = 2
local wire3 = 3
local wire4 = 4

local _delayBetweenSteps = 15 -- ms

gpio.mode(wire1, gpio.OUTPUT)--set four wires as output
gpio.mode(wire2, gpio.OUTPUT)
gpio.mode(wire3, gpio.OUTPUT)
gpio.mode(wire4, gpio.OUTPUT)

local mRun = 0
local mRunTicks = 0
local callbackWhenDone = nil

local seqNum = 0;
function seqInc ()
  seqNum = seqNum + 1
  if seqNum > 4 then
    seqNum = 1
  end
  return seqNum
end

function sequence(sn, a, b, c, d)--four step sequence to stepper motor
  if seqNum ~= sn then
    return
  end
  gpio.write(wire1, a)
  gpio.write(wire2, b)
  gpio.write(wire3, c)
  gpio.write(wire4, d)
end


-- PUBLIC
function motorStep(count, callback)
  count = count * 4 -- min motor step
  callbackWhenDone = callback
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
  if mRunTicks > 0 then
    mRunTicks = mRunTicks - 1
    return 1
  end

  if mRunTicks < 0 then
    mRunTicks = mRunTicks + 1
    return -1
  end

  if callbackWhenDone ~= nil then
    local cbCopy = callbackWhenDone
    callbackWhenDone = nil
    cbCopy()
  end

  return 0
end

function mBackwardStep ()
  sequence(1, gpio.HIGH, gpio.LOW,  gpio.LOW,  gpio.LOW)
  -- sequence(gpio.HIGH, gpio.HIGH, gpio.LOW,  gpio.LOW)
  sequence(2, gpio.LOW,  gpio.HIGH, gpio.LOW,  gpio.LOW)
  -- sequence(gpio.LOW,  gpio.HIGH, gpio.HIGH, gpio.LOW)
  sequence(3, gpio.LOW,  gpio.LOW,  gpio.HIGH, gpio.LOW)
  -- sequence(gpio.LOW,  gpio.LOW,  gpio.HIGH, gpio.HIGH)
  sequence(4, gpio.LOW,  gpio.LOW,  gpio.LOW,  gpio.HIGH)
  -- sequence(gpio.HIGH, gpio.LOW,  gpio.LOW,  gpio.HIGH)
end

function mForwardStep ()
  sequence(1, gpio.LOW,  gpio.LOW,  gpio.LOW,  gpio.HIGH)
  -- sequence(gpio.LOW,  gpio.LOW,  gpio.HIGH, gpio.HIGH)
  sequence(2, gpio.LOW,  gpio.LOW,  gpio.HIGH, gpio.LOW)
  -- sequence(gpio.LOW,  gpio.HIGH, gpio.HIGH, gpio.LOW)
  sequence(3, gpio.LOW,  gpio.HIGH, gpio.LOW,  gpio.LOW)
  -- sequence(gpio.HIGH, gpio.HIGH, gpio.LOW,  gpio.LOW)
  sequence(4, gpio.HIGH, gpio.LOW,  gpio.LOW,  gpio.LOW)
  -- sequence(gpio.HIGH, gpio.LOW,  gpio.LOW,  gpio.HIGH)
end

function mStop ()
  seqNum = 0
  sequence(0, gpio.LOW, gpio.LOW, gpio.LOW, gpio.LOW)
end

-- motor loop routine
tmr.create():alarm(_delayBetweenSteps, tmr.ALARM_AUTO, function()
  if mRun > 0 then
    seqInc()
    mForwardStep()
  elseif mRun < 0 then
    seqInc()
    mBackwardStep()
  else
    mStop()
  end
  mRun = mCheckRun()
end)


