local Menu = {}

function Menu:initialize()
	self.viewOptions = false
	self.x, self.y = 10, 10
	self.w, self.h = 600, 400
end

function Menu:draw()
	if self.viewOptions then
		love.graphics.setColor(255,255,255,150)
		love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)
		love.graphics.setColor(255,255,255,240)
		love.graphics.rectangle("line", self.x, self.y, self.w, self.h)
	end
end

function Menu:keypressed(key)
	if key == "o" then
		self.viewOptions = not self.viewOptions
	end
end

return Menu