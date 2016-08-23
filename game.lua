_G.source_directory = "src."
local sd = _G.source_directory
_G.library_directory = "libs."
local libd = _G.library_directory
local inspect = require(libd .. "inspect")

local Dungeon = require(sd .. "dungeon")
local Player = require(sd .. "player")
local Tiles = require(sd .. "tiles")
local Solids = require(sd .. "solids")
local CameraSystem = require(sd .. "camerasystem")

local tileSize = Tiles.tileSize
local game = {}

function game.load()
	Dungeon:initialize()
	Player:initialize(Dungeon:getRandomRoomPosition())

	local map = Dungeon.Map
	local width, height = Dungeon.MapWidth, Dungeon.MapHeight
	Solids:generateSolids(map, width, height)

	CameraSystem:initialize(1, .1)
end

function game.update(dt)
	Player:update(dt)
	for i = 1, #Solids.solids do
		local solid = Solids.solids[i]
		Player:collide(solid)
	end

	-- CameraSystem:update(dt, Player.x, Player.y)
end

function game.draw()
	CameraSystem:draw(function()
		Dungeon:draw()
		Player:draw()

		--black overlay
		love.graphics.setColor(0,0,0, 100)
		local width = love.graphics.getWidth()
		local height = love.graphics.getHeight()
		love.graphics.rectangle("fill", 0, 0, width, height)
	end)
end

return game