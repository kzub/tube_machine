local data="/wifi/SSID/password HTTP"

function sendData(sck, data, pos, callback)
	local dataEnd = pos + 4
	print(string.sub(data, pos, dataEnd))

	if dataEnd >= #data then
		callback()
	else
		sendData(sck, data, dataEnd + 1, callback)
	end
end

-- sendData(0, "abcdefgqwertyuiop", 1, function()
-- 	print("ok")
-- end)


if string.find(data, "/wifi/[^/]+/[^/%s]+") ~= nil then
	local l, r = string.find(data, "/wifi/[^/]+/")
	local ssid = string.sub(data, l + 6, r - 1)
	_, r2 = string.find(data, "/wifi/[^%s]+%s")
	local password = string.sub(data, r + 1, r2 - 1)
	print(ssid, password)
	-- print("found", string.sub(data, string.find(data, "/wifi/%a+/%a+")))
end

