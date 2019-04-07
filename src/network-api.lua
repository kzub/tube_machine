 print("Loading network-api.lua") 

local sv = net.createServer(net.TCP, 5) -- 5s timeout

function receiver(sck, data)
  local result = "error"
  print("in:", data)
  if string.find(data, "/motor/fwd/%d+") ~= nil then
  	result = "ok"
  	local steps = 1
  	steps = tonumber(string.sub(data, string.find(data, "%d+")))
		print("motor fwd", steps)
  	motorStep(steps)
	end

	if string.find(data, "/motor/bwd/%d+") ~= nil then
		result = "ok"
  	local steps = 1
  	steps = tonumber(string.sub(data, string.find(data, "%d+")))
		print("motor bwd", steps*(-1))
  	motorStep(steps*(-1))
	end

	if string.find(data, "/motor/stop") ~= nil then
		result = "ok"
		print("motor stop")
  	motorStop()
	end

	if string.find(data, "/sensor/status") ~= nil then
		print("sensor status")
		result = tostring(isSensorLight())
	end

	if string.find(data, "/app/start") ~= nil then
		print("appplication start")
		startProgram()
		result = "ok"
	end

	if string.find(data, "/app/stop") ~= nil then
		print("appplication stop")
		stopProgram()
		result = "ok"
	end

  sck:send('{"result":"'..result..'"}', function ()
  	print("close socket")
  	sck:close()
  end)
end

if sv then
  sv:listen(80, function(conn)
    conn:on("receive", receiver)
  end)
else
	print("createServer error")
end