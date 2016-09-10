local libd = _G.library_directory
local class = require(libd .. "middleclass")
local Timer = class("Timer")

function Timer:initialize(max)
	self.time = 0
	self.max = max
end

function Timer:update(dt, callback)
	self.time = self.time + dt
	if self.time > self.max then
		callback()
		self.time = 0
	end
end

return Timer