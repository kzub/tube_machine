 print("Loading network-api.lua")

local sv = net.createServer(net.TCP, 5) -- 5s timeout
local HTTPHEAD = "HTTP/1.1 200 OK\nContent-Type: text/html\n\n"

function sendFile(sck, file, recurrent)
	local data = file.readline()
	if data == nil then
		print("sendFile: close socket")
  	sck:close()
	  file.close()
		return
	end
	if recurrent == nil then
		data = HTTPHEAD..data
	end
	sck:send(data, function()
		sendFile(sck, file, true)
	end)
end

function receiver(sck, data)
  local result = "error"
  print("in:", data)


  if string.find(data, "/grabber/set/%d+") ~= nil then
  	result = "ok"
  	local usDelay = 800
  	usDelay = tonumber(string.sub(data, string.find(data, "%d+")))
  	print("grabber set", usDelay)
  	grabberSet(usDelay)

	elseif string.find(data, "/grabber/change") ~= nil then
  	result = "ok"
  	print("grabber change")
  	grabberChange();

	elseif string.find(data, "/motor/fwd/%d+") ~= nil then
  	result = "ok"
  	local steps = 1
  	steps = tonumber(string.sub(data, string.find(data, "%d+")))
		print("motor fwd", steps)
  	motorStep(steps)

	elseif string.find(data, "/motor/bwd/%d+") ~= nil then
		result = "ok"
  	local steps = 1
  	steps = tonumber(string.sub(data, string.find(data, "%d+")))
		print("motor bwd", steps*(-1))
  	motorStep(steps*(-1))

	elseif string.find(data, "/motor/stop") ~= nil then
		result = "ok"
		print("motor stop")
  	motorStop()

	elseif string.find(data, "/buzzer/mute") ~= nil then
		print("buzzer mute")
		result = "ok"
		buzzerMute()

	elseif string.find(data, "/laser/power") ~= nil then
		result = "ok"
		print("laser turn")
  	laserPower()

	elseif string.find(data, "/app/start") ~= nil then
		print("application start")
		startProgram()
		result = "ok"

	elseif string.find(data, "/app/stop") ~= nil then
		print("application stop")
		stopProgram()
		result = "ok"

	elseif string.find(data, "/measure/360") ~= nil then

		print("measure 360 circle")
		measureCircle()
		result = "ok"

	elseif string.find(data, "/wifi/[^/]+/[^/]+") ~= nil then
		local l, r = string.find(data, "/wifi/[^/]+/")
		local ssid = string.sub(data, l + 6, r - 1)
		_, r2 = string.find(data, "/wifi/[^%s]+%s")
		local password = string.sub(data, r + 1, r2 - 1)
		print("wifi station mode:", ssid, password)
		wifiModeSTA(ssid, password)
		result = "ok"

	elseif string.find(data, "/wifi%-ip") ~= nil then
		print("wifi-ip req")
		result = WIFI_STA_IP

	elseif string.find(data, "GET / HTTP") ~= nil then
		print("web root /")
		if file.open("controller.html") then
			sendFile(sck, file)
			return
		else
			print("controller.html not found")
	  end
		result = "fail to open file"
	end

  sck:send(HTTPHEAD..'{"result":"'..result..'"}', function ()
  	print("receiver: close socket")
  	sck:close()
  end)
end

if sv then
	print('try to listen')
  sv:listen(80, function(conn)
    conn:on("receive", receiver)
  end)
else
	print("createServer error")
end