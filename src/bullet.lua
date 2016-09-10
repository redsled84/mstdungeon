local libd = _G.library_directory
local class = require(libd .. "middleclass")
local Bullet = class("Bullet")

function Bullet:initialize(x1, y1, x2, y2, w, h, atkPwr, spd)
	self.x1 = x1
	self.y1 = y1
	self.x2 = x2
	self.y2 = y2
	self.dx = x2 - x1
	self.dy = y2 - y1
	self.w = w
	self.h = h
	self.atkPwr = atkPwr
	self.distance = math.sqrt(math.pow(x2-x1, 2)+math.pow(y2-y1, 2))
	self.spd = spd
	self.directionX = 0
	self.directionY = 0
end

function Bullet:update(dt)
	self.directionX = self.dx / self.distance
	self.directionY = self.dy / self.distance

	self.x1 = self.x1 + self.directionX * self.spd * dt
	self.y1 = self.y1 + self.directionY * self.spd * dt
end

return Bullet