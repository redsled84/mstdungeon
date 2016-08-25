local sd = _G.source_directory
local Collision = require(sd .. "collision")
local Items = require(sd .. "items")
local Tiles = require(sd .. "tiles")
local Solids = require(sd .. "solids")
local tileSize = Tiles.tileSize
local Player = {}

function Player:initialize(x, y)
	self.x = x
	self.y = y
	self.w, self.h = (3 / 4) * tileSize, (3 / 4) * tileSize
	self.spd = 150
	self.action = false
	self.inventory = {}
	--needs to out of player class
	self.warning = {
		message = "",
		can = false,
		sx = 20,
		sy = 20,
		x = 20,
		y = 20,
		alpha = 255,
		da = 75,
		dp = 4
	}
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
end

function Player:collideWithItems(o, i)
	local col = Collision:aabb(self, o)
	if col then
		self:addItemToInventory(o)
		Items:removeItem(i)
	end
end

function Player:addItemToInventory(item)
	self.inventory[#self.inventory+1] = item
end

function Player:update(dt)
	self:movement(dt)
end

function Player:draw()
	love.graphics.setColor(255,255,255)
	love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)
	self:drawInventory()
	self:drawWarningMessage()
end

function Player:drawInventory()
	love.graphics.setColor(255,255,255)
	for i = 1, #self.inventory do
		local item = self.inventory[i]
		love.graphics.print(item.name, 10, 15*i)
	end
end

function Player:drawWarningMessage()
	if self.warning.can then
		local dt = love.timer.getDelta()
		if self.warning.y > 10 then
			love.graphics.setColor(255,0,0, self.warning.alpha)
			love.graphics.print(self.warning.message, self.warning.x, self.warning.y)
			self.warning.y = self.warning.y - self.warning.dp * dt
			self.warning.alpha = self.warning.alpha - self.warning.da * dt
		else
			self.warning.y = self.warning.sy
			self.warning.alpha = 255
			self.warning.message = ""
			self.warning.can = false
		end
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

function Player:useItem(key)
	if key == "1" and self.inventory[1] then
		local item1 = self.inventory[1]
		if item1.execute then
			local x, y = item1.execute()
			if not Solids:checkSolidPosition(x, y) then
				self.x, self.y = x, y
			else
				self.warning.message = "Cannot Teleport into a wall!"
				self.warning.can = true
			end
		end
		self.inventory[1] = nil
	end
end

return Player