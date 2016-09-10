local libd = _G.library_directory
local Camera = require(libd .. "camera")
local CameraSystem = Camera(love.graphics.getWidth()/2, love.graphics.getHeight()/2)

function CameraSystem:initialize(maxScale, zoomSpeed, activate)
	self.scale = 1
	self.maxScale = maxScale
	self.zoomSpeed = zoomSpeed
	self.activate = activate or false
end

function CameraSystem:update(dt, x, y)
	if self.activate then
		if self.scale < self.maxScale then
			self.scale = self.scale + self.zoomSpeed * dt
		else
			self.scale = self.maxScale
		end
		self:lookAt(x, y)
		self:zoom(self.scale)
	end
end

return CameraSystem