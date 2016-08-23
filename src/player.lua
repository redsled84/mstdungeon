local Collision = require "src.collision"
local Tiles = require "src.tiles"
local tileSize = Tiles.tileSize
local Player = {}

function Player:initialize(x, y)
	self.x = x
	self.y = y
	self.w, self.h = tileSize, tileSize
	self.spd = 200
end

function Player:movement(dt)
	local key = love.keyboard
	if key.isDown("d") then
		self.x = self.x + self.spd * dt
	end
	if key.isDown("a") then
		self.x = self.x - self.spd * dt
	end
	if key.isDown("s") then
		self.y = self.y + self.spd * dt
	end
	if key.isDown("w") then
		self.y = self.y - self.spd * dt
	end
end

function Player:collide(o)
	local col = Collision:aabb(self, o)
	if col then
		local nx, ny = Collision:getSide(self, o)
		self.x, self.y = Collision:solve(nx, ny, self, o)
	end
end

function Player:update(dt)
	self:movement(dt)
end

function Player:draw()
	love.graphics.setColor(255,255,255)
	love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)
end

return Player