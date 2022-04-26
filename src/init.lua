print("Initializing...")

function startup()
	dofile("wifi.lua")
	dofile("motor.lua")
	dofile("laser.lua")
	dofile("buzzer.lua")
	dofile("sensor.lua")
	dofile("grabber.lua")
	dofile("network-api.lua")
	dofile("app.lua")
end

-- few seconds to have time upload new app in case of runtime error =)
tmr.create():alarm(3000, tmr.ALARM_SINGLE, startup)
