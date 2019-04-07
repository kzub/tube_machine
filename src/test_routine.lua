capacity = 12
signal = false

local clock = os.clock
local routines = {}

function sleep(n)  -- seconds
	if n == nil then 
		coroutine.yield()
		return
	end

  local t0 = clock()
  while clock() - t0 < n do
  	coroutine.yield()
	end
end

function createRoutine(func) 
	table.insert(routines, coroutine.create(func))	
end

createRoutine(function ()
	print("hi")
	sleep()
	print("hi2")
	sleep()
	print("hi3")
end)

local tubesCount = 16

function isTubeFull ()
	return false
end

-- test 
createRoutine(function ()
	local i = 10
	while true do
		if isOn() then
			if isTubeFull() then
				moveNextTube()
				resetTubeLevel()
			end
			if isLastTube() && isBeeperOn() then
				beeper(true)
			end
		end
	end
end)

local run = true
while run do
	run = false
	for k,v in pairs(routines) do
		local status = coroutine.status(v)
		if status == 'suspended' then
			run = true
			coroutine.resume(v)
		end
	end
end
