local libd = _G.library_directory
local Grid = require(libd .. "jumper.grid")
local Pathfinder = require(libd .. "jumper.pathfinder")

local sd = _G.source_directory
local Bullet = require(sd .. "bullet")
local CameraSystem = require(sd .. "camerasystem")
local Collision = require(sd .. "collision")
local Items = require(sd .. "items")
local Tiles = require(sd .. "tiles")
local Timer = require(sd .. "timer")
local tileSize = Tiles.tileSize
local Player = {}

function Player:initialize(x, y)
	self.x = x
	self.y = y
	self.w, self.h = (3 / 4) * tileSize, (3 / 4) * tileSize
	self.spd = 110
	self.action = false
	self.inventory = {}
	self.bullets = {}
	self.minAP = 3
	self.maxAP = 6
	self.bulletSpd = 235
	self.canShoot = true
	self.rof = .2
	self.shootTimer = Timer:new(self.rof)
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

function Player:collideWithSolids(o)
	local col = Collision:aabb(self, o)
	if col then
		if o.tileType == "solid" then
			local nx, ny = Collision:getSide(self, o)
			self.x, self.y = Collision:solve(nx, ny, self, o)
		elseif o.tileType == "door" then
			if not o.open then
				local nx, ny = Collision:getSide(self, o)
				self.x, self.y = Collision:solve(nx, ny, self, o)
			end
		end
	end

	--Opening doors
	local doorBounds = {
		x = self.x - 5,
		y = self.y - 5,
		w = self.w + 10,
		h = self.h + 10
	}
	local col = Collision:aabb(doorBounds, o)
	if col and o.tileType == "door" then
		if self.action and not o.open then
			o.open = true
		end
	end

	self:collideBulletsWithSolids(o)
end

function Player:collideBulletsWithSolids(o)
	for i = #self.bullets, 1, -1 do
		local b = self.bullets[i]
		local col = Collision:aabb(b, o)
		if col then
			table.remove(self.bullets, i)
		end
	end
end

function Player:update(dt)
	self:movement(dt)
	self:updateBullets(dt)
	self:updateTimers(dt)
	self:shootBullets()
end

function Player:updateBullets(dt)
	for i = 1, #self.bullets do
		local b = self.bullets[i]
		b:update(dt)
	end
end

function Player:updateTimers(dt)
	if not self.canShoot then
		self.shootTimer:update(dt, function()
			self.canShoot = true
		end)
	end
end

function Player:shootBullets()
	if love.mouse.isDown(1) and self.canShoot then
		local x, y = CameraSystem:worldCoords(love.mouse.getX(), love.mouse.getY())
		local atkPower = math.random(self.minAP, self.maxAP)
		local x1, y1 = self.x + self.w / 2, self.y + self.h / 2
		local bullet = Bullet:new(x1, y1, x, y, 8, 8, atkPower, self.bulletSpd)
		self.bullets[#self.bullets+1] = bullet
		self.canShoot = false
	end
end

function Player:draw()
	love.graphics.setColor(255,255,255)
	love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)
end

function Player:drawBullets()
	for i = #self.bullets, 1, -1 do
		local b = self.bullets[i]
		love.graphics.setColor(255,0,255)
		love.graphics.rectangle("fill", b.x1, b.y1, b.w, b.h)
	end
end

function Player:actionKey(key)
	if key == "f" and not self.action then
		self.action = true
	end
end

function Player:releaseActionKey(key)
	if key == "f" and self.action then
		self.action = false
	end
end

return Player