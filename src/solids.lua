-- A solid is a square that collides with Player
-- and returns a collision response
local libd = _G.library_directory
local sd = _G.source_directory
local class = require(libd .. "middleclass")
local Tiles = require(sd .. "tiles")
local Solids = { solids={} }

function Solids:newSolid(x, y, w, h, tileType, open)
	self.solids[#self.solids+1] = {
		x = x,
		y = y,
		w = w,
		h = h,
		tileType = tileType,
		open = open or nil
	}
end

function Solids:generateSolids(map, width, height)
	if #self.solids > 0 then
		for i = #self.solids, 1, -1 do
			self.solids[i] = nil
		end
	end

	for y = height, 1, -1 do
		for x = width, 1, -1 do
			local n = map[y][x]
			local min, max = Tiles.Door, Tiles.BRWall
			local tileType, open
			local cwall = Tiles.CorridorWall
			if n >= min and n <= max or n == cwall then
				local mx, my = Tiles.tileSize * x, Tiles.tileSize * y

				if n == Tiles.Door then
					tileType = "door"
					open = false
				else
					tileType = "solid"
				end

				self:newSolid(mx, my, Tiles.tileSize, Tiles.tileSize, tileType, open)
			end
		end
	end
end

return Solids