local libd = _G.library_directory
local class = require(libd .. "class")
local Enemy = class("Enemy")

function Enemy:initialize(x, y, w, h, minAP, maxAP, health)
	self.x = x
	self.y = y
	self.w = w
	self.h = h
	self.minAP = minAP
	self.maxAP = maxAP
	self.health = health
	self.state = "idle"
end

return Enemy