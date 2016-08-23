math.randomseed(os.time())
math.random();math.random();math.random();

local game = require "game"
local title = "Organized Dungeon Generator / FPS: "

function love.load()
	game.load()
end

function love.update(dt)
	game.update(dt)
	love.window.setTitle(title .. tostring(love.timer.getFPS()) ..' '.. tostring(collectgarbage("count")))
end

function love.draw()
	game.draw()
end

function love.keypressed(key)
	local quit = love.event.quit
	if key == "escape" then
		quit()
	end
	if key == "r" then
		game.load()
	end
end

function love.mousepressed(x, y, button)

end