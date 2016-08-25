_G.source_directory = "src."
local sd = _G.source_directory
_G.library_directory = "libs."
local libd = _G.library_directory
local inspect = require(libd .. "inspect")

local Dungeon = require(sd .. "dungeon")
local Items = require(sd .. "items")
local Player = require(sd .. "player")
local Solids = require(sd .. "solids")
local Tiles = require(sd .. "tiles")
local CameraSystem = require(sd .. "camerasystem")

local tileSize = Tiles.tileSize
local game = {}

local function move()	
	return love.mouse.getX(), love.mouse.getY()
end

function game.load()
	Dungeon:initialize()
	Player:initialize(Dungeon:getRandomRoomPosition())

	local map = Dungeon.Map
	local width, height = Dungeon.MapWidth, Dungeon.MapHeight
	Solids:generateSolids(map, width, height)

	local x1, y1 = Dungeon:getRandomRoomPosition()
	Items:newItem(x1, y1, 8, 8, "teleportation", false, move)

	CameraSystem:initialize(1, .1)
end

function game.update(dt)
	Player:update(dt)
	for i = 1, #Solids.solids do
		local solid = Solids.solids[i]
		Player:collideWithSolids(solid)
	end
	for i = 1, #Items.items do
		local item = Items.items[i]
		Player:collideWithItems(item, i)
	end

	-- CameraSystem:update(dt, Player.x, Player.y)
end

function game.draw()
	CameraSystem:draw(function()
		Dungeon:draw()
		Player:draw()

		Items:draw()

		--black overlay
		love.graphics.setColor(0,0,0, 60)
		local width = love.graphics.getWidth()
		local height = love.graphics.getHeight()
		love.graphics.rectangle("fill", 0, 0, width, height)
	end)
end

function game.keypressed(key)
	Player:actionKey(key)
	Player:useItem(key)
end

function game.keyreleased(key)
	Player:releaseActionKey(key)
end

return game