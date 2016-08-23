local Room = {}

function Room.new(x, y, w, h)
	local room = {}

	room.x, room.y = x, y
	room.w, room.h = w, h
	room.midpoint = {x = x + w / 2, y = y + h / 2}

	return room
end

return Room