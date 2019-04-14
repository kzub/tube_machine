print("Loading sensor.lua") 

local _lowLevel = 180

if adc == nil then
  print("ERROR: NO ADC CONFIGURED")
else
  if adc.force_init_mode(adc.INIT_ADC) then
    print("changing to INIT_ADC mode, restarting...")
    node.restart()
  end

  print("Sensor value:", adc.read(0))
end

function isSensorLight ()
  local val = adc.read(0)
  -- print("isSensorLight:", val <= _lowLevel, val)
  return val <= _lowLevel
end
