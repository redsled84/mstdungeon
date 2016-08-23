local Collision = {}

function Collision:aabb(a, b)
	return a.x + a.w > b.x and a.x < b.x + b.w
		and a.y + a.h > b.y and a.y < b.y + b.h
end

function Collision:getSide(a, b)
	local aBottom = a.y + a.h
	local bBottom = b.y + b.h
	local aRight = a.x + a.w
	local bRight = b.x + b.w
	local bCollision = aBottom - b.y
	local tCollision = bBottom - a.y
	local lCollision = bRight - a.x
	local rCollision = aRight - b.x

	local nx, ny = 0, 0
	if tCollision < bCollision and tCollision < lCollision and tCollision < rCollision then
		ny = 1
	end
	if bCollision < tCollision and bCollision < lCollision and bCollision < rCollision then
		ny = -1
	end
	if lCollision < rCollision and lCollision < tCollision and lCollision < bCollision then
		nx = 1
	end
	if rCollision < lCollision and rCollision < tCollision and rCollision < bCollision then
		nx = -1
	end

	return nx, ny
end

function Collision:solve(nx, ny, a, b)
	local x, y = a.x, a.y
	local w, h = a.w, a.h
	if nx < 0 then
		x = b.x - w
	elseif nx > 0 then
		x = b.x + b.w
	end
	if ny < 0 then
		y = b.y - h
	elseif ny > 0 then
		y = b.y + b.h
	end
	return x, y 
end

return Collision