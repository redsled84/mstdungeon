math.randomseed(os.time())
math.random();math.random();math.random();
local Dungeon = require "dungeon"
local Tiles = require "tiles"
local tileSize = Tiles.tileSize
local suit = require "suit"

function love.load()
	Dungeon:initialize(100, 70, 15, 6, 11)

	sliders = {
		{
			slider = {value = 100, min = 40, max = 300},
			text = "Map Width"
		},
		{
			slider = {value = 70, min = 40, max = 250},
			text = "Map Height"
		},
		{
			slider = {value = 15, min = 5, max = 60},
			text = "Max Number of Rooms"
		},
		{
			slider = {value = 6, min = 4, max = 18},
			text = "Min Room Size"
		},
		{
			slider = {value = 11, min = 7, max = 25},
			text = "Max Room Size"
		},
		{
			slider = {value = tileSize, min = 2, max = 24},
			text = "Tilesize"
		}
	}
	viewOptions = false
end

local timer, timerMax = 0, .5
local title = "Organized Dungeon Generator / FPS: "
function love.update(dt)
	timer = timer + dt
	if timer > timerMax then
		timer = 0
		collectgarbage("collect")
		-- print(collectgarbage("count"))
		-- print(Dungeon.RoomPlacementAttempts)
	end

	if viewOptions then
		suit.layout:reset(30,30)

		for i, v in ipairs(sliders) do
			suit.layout:row(0, 200)
			suit.Label(v.text, suit.layout:col(150, 20))
			suit.layout:push(suit.layout:row(300, 40))
				suit.Slider(v.slider, suit.layout:col(160, 20))
				suit.Label(("%d"):format(v.slider.value), suit.layout:col(50, 20))
			suit.layout:pop()
		end
	end

	love.window.setTitle(title .. tostring(love.timer.getFPS()) ..' '.. tostring(collectgarbage("count")))
end

function love.draw()
	Dungeon:draw()

	if viewOptions then
		love.graphics.setColor(0,150,255,230)
		love.graphics.rectangle("fill", 10, 10, 240, 390)
		suit.draw()

		love.graphics.setColor(0,0,0,100)
		love.graphics.rectangle("fill", 260, 20, 260, 48)
		love.graphics.setColor(255,255,255,255)
		love.graphics.print("Press 'O' to toggle the options", 270, 20)
		love.graphics.print("Press 'R' to generate a new dungeon", 270, 42)
	else
		love.graphics.setColor(0,0,0,100)
		love.graphics.rectangle("fill", 20, 20, 260, 48)
		love.graphics.setColor(255,255,255,255)
		love.graphics.print("Press 'O' to toggle the options", 20, 20)
		love.graphics.print("Press 'R' to generate a new dungeon", 20, 42)
	end
end

function love.keypressed(key)
	local quit = love.event.quit
	local sliders = sliders
	if key == "escape" then
		quit()
	end
	if key == "r" then
		local floor = math.ceil
		local MapWidth = ceil(sliders[1].slider.value)
		local MapHeight = ceil(sliders[2].slider.value)
		local MaxNumRooms = ceil(sliders[3].slider.value)
		local MinRoomSize = ceil(sliders[4].slider.value)
		local MaxRoomSize = ceil(sliders[5].slider.value)
		Tiles.tileSize = ceil(sliders[6].slider.value)
		Dungeon:initialize(MapWidth, MapHeight, MaxNumRooms, MinRoomSize, MaxRoomSize)
	end
	if key == "o" then
		viewOptions = not viewOptions
	end
end