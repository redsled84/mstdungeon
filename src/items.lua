local sd = _G.source_directory
local libd = _G.library_directory
local Items = { items = {} }

function Items:newItem(x, y, w, h, name, consumable, f)
	local item = {
		x = x,
		y = y,
		w = w,
		h = h,
		name = name,
		consumable = consumable or false,
		dropped = true
	}

	item.execute = f or false

	self.items[#self.items+1] = item
end

function Items:removeItem(i)
	self.items[i] = nil
end

function Items:draw()
	for i = 1, #self.items do
		local item = self.items[i]
		love.graphics.setColor(0,255,0)
		love.graphics.rectangle("fill", item.x, item.y, item.w, item.h)
	end
end

return Items