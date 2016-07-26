local Grid = require "jumper.grid"
local Pathfinder = require "jumper.pathfinder"
local Delaunay = require "delaunay"
	local Point = Delaunay.Point
	local Edge = Delaunay.Edge
local Kruskals = require "kruskals"
local Room = require "room"
local Tiles = require "tiles"

local Dungeon = {}

function Dungeon:consts(MapWidth, MapHeight, MaxNumRooms, MinRoomSize, MaxRoomSize)
	tileSize = Tiles.tileSize
	local floor = math.floor
	self.MapWidth, self.MapHeight = MapWidth, MapHeight

	self.RoomPlacementAttempts = 0
	self.MaxRoomPlacementAttempts = 300

	self.NumRooms = 0
	self.MaxNumRooms = MaxNumRooms
	self.MinRoomSize, self.MaxRoomSize = MinRoomSize, MaxRoomSize
	self.Failed = false

	self.ExtraEdgesCounter = 0
	self.MaxExtraEdges = floor(self.MaxNumRooms * .08)
end

function Dungeon:initialize(MapWidth, MapHeight, MaxNumRooms, MinRoomSize, MaxRoomSize)
	self.Map = {}
	self.Rooms = {}
	self.Corridors = {}
	self.Doors = {}

	self:consts(MapWidth, MapHeight, MaxNumRooms, MinRoomSize, MaxRoomSize)
	self:generateDungeon()
end

function Dungeon:generateDungeon()
	self:generateMap()
	self:generateRooms()
	self:generateMST()
	self:generateCorridors()
	self:generateRoomDropoffs()
end

function Dungeon:generateMap()
	for y = 1, self.MapHeight do
		local temp = {}
		for x = 1, self.MapWidth do
			temp[#temp+1] = Tiles.Solid
		end
		self.Map[#self.Map+1] = temp
	end
end

function Dungeon:generateRooms()
	while not self.Failed and self.NumRooms <= self.MaxNumRooms do
		local x, y, w, h
		repeat
			w, h = self:getRandomDimensions()
			x, y = self:getRandomPosition(w, h)

			if self.RoomPlacementAttempts >= self.MaxRoomPlacementAttempts then
				self.Failed = true
				return
			end
			
			self.RoomPlacementAttempts = self.RoomPlacementAttempts + 1
		until not self:checkArea(x, y, w, h, Tiles.Floor)

		self:newArea(x, y, w, h, Tiles.Floor)
		self.NumRooms = self.NumRooms + 1
	end
end

function Dungeon:newArea(x, y, w, h, tile1)
	for my = y, y + h do
		for mx = x, x + w do
			if my >= y + 1 and my <= y + h - 1 and 
			mx >= x + 1 and mx <= x + w - 1 then
				self.Map[my][mx] = tile1
			else
				self:addWalls(mx, my, x, y, w, h)
			end
		end
	end
	self:addPathObstacles(x, y, w, h)
	self.Rooms[#self.Rooms+1] = Room.new(x, y, w, h)
end

function Dungeon:addWalls(mx, my, x, y, w, h)
	-- Add vertical walls
	if mx == x or mx == x + w and my > y and my < y + h then
		self.Map[my][mx] = Tiles.HWall
	end
	-- Add horizontal walls
	if my == y or my == y + h and mx > x and mx < x + w then
		self.Map[my][mx] = Tiles.VWall
	end

	-- Add Top Left Corner
	if my == y and mx == x then
		self.Map[my][mx] = Tiles.TLWall
	-- Add Top Right Corner
	end
	if my == y and mx == x + w then
		self.Map[my][mx] = Tiles.TRWall
	end

	-- Add Bottom Left corner
	if my == y + h and mx == x then
		self.Map[my][mx] = Tiles.BLWall
	-- Add Bottom Right corner
	end
	if my == y + h and mx == x + w then
		self.Map[my][mx] = Tiles.BRWall
	end
end

function Dungeon:addPathObstacles(x, y, w, h, tile)
	local tile = tile or Tiles.Pepper
	-- Top Left corner
	self.Map[y-1][x] = tile
	self.Map[y][x-1] = tile
	-- Top Right corner
	self.Map[y][x+w+1] = tile
	self.Map[y-1][x+w] = tile
	-- Bottom Left corner
	self.Map[y+h+1][x] = tile
	self.Map[y+h][x-1] = tile
	-- Bottom Right corner
	self.Map[y+h+1][x+w] = tile
	self.Map[y+h][x+w+1] = tile
end

function Dungeon:checkArea(x, y, w, h, tile)
	for my = y-3, y + h+3 do
		for mx = x-3, x + w+3 do
			if self.Map[my][mx] == tile then
				return true
			end
		end
	end
	return false
end

function Dungeon:getRandomDimensions()
	local random = math.random
	return random(self.MinRoomSize, self.MaxRoomSize),
		random(self.MinRoomSize, self.MaxRoomSize)
end

function Dungeon:getRandomPosition(w, h)
	local random = math.random
	return random(4, self.MapWidth - w - 4), random(4, self.MapHeight - h - 4)
end

function Dungeon:generateMST()
	self:generateGraph()
	self.MST = Kruskals(self.Points, self.Edges)
	-- self:generateExtraEdges()
end

local function compare(a, b) if a:length() < b:length() then return a end end
function Dungeon:generateGraph()
	self.Points = self:generatePoints()
	local triangles = Delaunay.triangulate(unpack(self.Points))
	self.Edges = {}

	for i = 1, #triangles do
		local p1 = triangles[i].p1
		local p2 = triangles[i].p2
		local p3 = triangles[i].p3

		if #self.Edges > 1 then
			local edge1 = Edge(p1, p2)
			local edge2 = Edge(p2, p3)
			local edge3 = Edge(p1, p3)

			if not self:edgeAdded(self.Edges, edge1) then
				self.Edges[#self.Edges+1] = edge1
			end
			if not self:edgeAdded(self.Edges, edge2) then
				self.Edges[#self.Edges+1] = edge2
			end
			if not self:edgeAdded(self.Edges, edge3) then
				self.Edges[#self.Edges+1] = edge3
			end
		else
		    self.Edges[#self.Edges+1] = Edge(p1, p2)
			self.Edges[#self.Edges+1] = Edge(p2, p3)
			self.Edges[#self.Edges+1] = Edge(p1, p3)
		end
	end

	local sort = table.sort
	sort(self.Edges, compare)
end

function Dungeon:generateExtraEdges()
	local extraEdges = {}
	local random = math.random

	while self.ExtraEdgesCounter < self.MaxExtraEdges do
		local rn = random(1, #self.Edges)
		local randomEdge = self.Edges[rn]
		if not self:edgeAdded(self.MST, randomEdge) then
			extraEdges[#extraEdges+1] = randomEdge
			self.ExtraEdgesCounter = self.ExtraEdgesCounter + 1
		end
	end

	for i = 1, #extraEdges do
		local extraEdge = extraEdges[i]
		self.MST[#self.MST+1] = extraEdge
	end
end

function Dungeon:generatePoints()
	local points = {}
	local ceil = math.ceil

	for i = 1, #self.Rooms do
		local room = self.Rooms[i]
		local x = ceil(room.x + room.w / 2)
		local y = ceil(room.y + room.h / 2)
		points[i] = Point(x * tileSize, y * tileSize)
	end

	return points
end

function Dungeon:edgeAdded(edges, edge)
	for i = 1, #edges do
		local temp = self.Edges[i]
		if temp:same(edge) then
			return true
		end
	end
	return false
end

function Dungeon:generateCorridors()
	local pairedRooms = self:generatePairedRooms()
	self:generateCorridorPaths(pairedRooms)
end

function Dungeon:generatePairedRooms()
	local pairedRooms = {}

	for i = 1, #self.MST do
		local edge = self.MST[i]
		local r1 = self:getRoomFromPoint(edge.p1)
		local r2 = self:getRoomFromPoint(edge.p2)
		
		pairedRooms[#pairedRooms+1] = {r1 = r1, r2 = r2}
	end

	return pairedRooms
end

function Dungeon:getRoomFromPoint(point)
	local ceil = math.ceil
	for i = 1, #self.Rooms do
		local room = self.Rooms[i]
		local p = Point(ceil(room.x + room.w / 2) * tileSize,
			ceil(room.y + room.h / 2) * tileSize)

		if p == point then
			return room
		end
	end
end

function Dungeon:generateCorridorPaths(pairedRooms)
	local walkable = function(value) 
		if value < Tiles.Dropoff1 then
			return true 
		else
			return false
		end
	end
	local grid = Grid(self.Map)
	local finder = Pathfinder(grid, 'ASTAR', walkable) 
	finder:setMode('ORTHOGONAL')
	ceil = math.ceil

	for i = 1, #pairedRooms do
		local pr = pairedRooms[i]
		-- Get the center positions of the paired rooms
		local x1, y1 = ceil(pr.r1.x + pr.r1.w / 2),
			ceil(pr.r1.y + pr.r1.h / 2)
		local x2, y2 = ceil(pr.r2.x + pr.r2.w / 2),
			ceil(pr.r2.y + pr.r2.h / 2)
		local Path = finder:getPath(x1, y1, x2, y2)
		if Path == nil then
			print(self.map[y1][x1], self.map[y2][x2], 'Door Positions:',
				tostring(x1), tostring(y1), tostring(x2), tostring(y2))
		else
			local doorCounter = 0
			local nodes = {}
			for node, count in Path:nodes() do
				local x, y = node:getX(), node:getY()
				nodes[#nodes+1] = {x = x, y = y}
				-- Add door from room 1
				if doorCounter == 0 and self.Map[y][x] == Tiles.HWall or self.Map[y][x] == Tiles.VWall then
					self.Map[y][x] = Tiles.Door
					doorCounter = doorCounter + 1
				end

				-- Add corridor tile
				if self.Map[y][x] == Tiles.Solid or self.Map[y][x] == Tiles.CorridorWall then
					self.Map[y][x] = Tiles.Corridor
				end
			end
			-- Add door from room 2
			for i=#nodes, 1, -1 do
				local x, y = nodes[i].x, nodes[i].y
				if doorCounter == 1 and self.Map[y][x] == Tiles.HWall or self.Map[y][x] == Tiles.VWall then
					self.Map[y][x] = Tiles.Door
					break
				end
			end

			-- Add dropoffs here
			self:addCorridorDropoffs(nodes)

			doorCounter = nil
			nodes = nil
		end
	end

	grid, finder = nil
end

--[[ Adds walls around corridor paths
-- Implement by calling in generateCorridorPaths, 3nd for loop
function Dungeon:addCorridorWalls(x, y)
	-- horizontal part of corridor
	if self.Map[y-1][x] == Tiles.Solid or self.Map[y-1][x] == Tiles.Pepper then
		self.Map[y-1][x] = Tiles.CorridorWall
	end
	if self.Map[y+1][x] == Tiles.Solid or self.Map[y+1][x] == Tiles.Pepper then
		self.Map[y+1][x] = Tiles.CorridorWall
	end
	-- vertical part of corridor
	if self.Map[y][x-1] == Tiles.Solid or self.Map[y][x-1] == Tiles.Pepper then
		self.Map[y][x-1] = Tiles.CorridorWall
	end
	if self.Map[y][x+1] == Tiles.Solid or self.Map[y][x+1] == Tiles.Pepper then
		self.Map[y][x+1] = Tiles.CorridorWall
	end

	-- bottom right corner
	if self.Map[y+1][x+1] == Tiles.Solid or self.Map[y+1][x+1] == Tiles.Pepper then
		self.Map[y+1][x+1] = Tiles.CorridorWall
	end
	-- bottom left corner
	if self.Map[y+1][x-1] == Tiles.Solid or self.Map[y+1][x-1] == Tiles.Pepper then
		self.Map[y+1][x-1] = Tiles.CorridorWall
	end
	-- top right corner
	if self.Map[y-1][x+1] == Tiles.Solid or self.Map[y-1][x+1] == Tiles.Pepper then
		self.Map[y-1][x+1] = Tiles.CorridorWall
	end
	-- top left corner
	if self.Map[y-1][x-1] == Tiles.Solid or self.Map[y-1][x-1] == Tiles.Pepper then
		self.Map[y-1][x-1] = Tiles.CorridorWall
	end
end
]]

local function yCompare(a, b) if a.y < b.y then return a end end
function Dungeon:addCorridorDropoffs(nodes)
	-- Sort nodes from smallest y to largest y
	local sort = table.sort
	sort(nodes, yCompare)

	for i = 1, #nodes do
		local node = nodes[i]
		local x, y = node.x, node.y
		if self.Map[y][x] == Tiles.Corridor then
			local dropoff1 = self.Map[y+1][x]
			local dropoff2 = self.Map[y+2][x]
			local dropoff3 = self.Map[y+3][x]
			if dropoff1 == Tiles.Solid or dropoff1 >= Tiles.Dropoff1 then
				self.Map[y+1][x] = Tiles.Dropoff1
			end
			if dropoff2 == Tiles.Solid or dropoff2 >= Tiles.Dropoff1 then
				self.Map[y+2][x] = Tiles.Dropoff2
			end
			if dropoff3 == Tiles.Solid or dropoff3 == Tiles.Pepper then
				self.Map[y+3][x] = Tiles.Dropoff3
			end
		end
	end
end

function Dungeon:generateRoomDropoffs()
	for i = 1, #self.Rooms do
		local room = self.Rooms[i]
		local y = room.y + room.h
		for x = room.x, room.x + room.w do
			if self.Map[y+1][x] == Tiles.Solid or self.Map[y+1][x] == Tiles.Pepper then
				self.Map[y+1][x] = Tiles.Dropoff1
			end
			if self.Map[y+2][x] == Tiles.Solid or self.Map[y+2][x] == Tiles.Pepper then
				self.Map[y+2][x] = Tiles.Dropoff2
			end
			if self.Map[y+3][x] == Tiles.Solid or self.Map[y+3][x] == Tiles.Pepper then
				self.Map[y+3][x] = Tiles.Dropoff3
			end
			if self.Map[y+4][x] == Tiles.Solid or self.Map[y+4][x] == Tiles.Pepper then
				self.Map[y+4][x] = Tiles.Dropoff4
			end
		end
	end
end

function Dungeon:realCoords(x, y)
	return (x - 1), (y - 1)
end

function Dungeon:draw()
	for y = 1, self.MapHeight do
		for x = 1, self.MapWidth do
			local mx, my = self:realCoords(x, y)
			-- local mx, my = x, y
			if self.Map[y][x] == Tiles.Solid then
				love.graphics.setColor(255,0,0,45)
			elseif self.Map[y][x] == Tiles.Floor then
				love.graphics.setColor(255,255,255)
			elseif self.Map[y][x] == Tiles.Corridor then
				love.graphics.setColor(0,255,0)
			elseif self.Map[y][x] == Tiles.HWall then
				love.graphics.setColor(255,175,0)
			elseif self.Map[y][x] == Tiles.VWall then
				love.graphics.setColor(175,255,0)
			elseif self.Map[y][x] == Tiles.TLWall then
				love.graphics.setColor(0,0,255)
			elseif self.Map[y][x] == Tiles.TRWall then
				love.graphics.setColor(0,255,255)
			elseif self.Map[y][x] == Tiles.BLWall then
				love.graphics.setColor(255,0,255)
			elseif self.Map[y][x] == Tiles.BRWall then
				love.graphics.setColor(255,0,0)
			elseif self.Map[y][x] == Tiles.Door then
				love.graphics.setColor(0,0,255, 100)
			elseif self.Map[y][x] == Tiles.CorridorWall then
				love.graphics.setColor(255,255,0)
			elseif self.Map[y][x] == Tiles.Dropoff1 then
				love.graphics.setColor(60,60,60,240)
			elseif self.Map[y][x] == Tiles.Dropoff2 then
				love.graphics.setColor(60,60,60,180)
			elseif self.Map[y][x] == Tiles.Dropoff3 then
				love.graphics.setColor(60,60,60,120)
			elseif self.Map[y][x] == Tiles.Dropoff4 then
				love.graphics.setColor(60,60,60,60)
			elseif self.Map[y][x] == Tiles.Pepper then
				-- love.graphics.setColor(0,0,0)
				love.graphics.setColor(255,0,0,45)
			end
			if self.Map[y][x] > Tiles.Solid and self.Map[y][x] < Tiles.Pepper then
				love.graphics.rectangle("fill", mx * tileSize, my * tileSize, tileSize, tileSize)
			end
			mx, my = nil, nil
		end
	end
	-- self:drawGrid()
	-- self:drawMST()
end

function Dungeon:drawGrid()
	local alpha = 175
	for y = 1, self.MapHeight do
		for x = 1, self.MapWidth do
			local mx, my = self:realCoords(x, y)
			love.graphics.setColor(0,0,0, alpha)
			love.graphics.rectangle("line", mx*tileSize, my*tileSize, tileSize, tileSize)
		end
	end
end

function Dungeon:drawMST()
	local alpha = 255
	for i = 1, #self.MST do
		local p1 = self.MST[i].p1
		local p2 = self.MST[i].p2
		love.graphics.setColor(0,255,0)
		love.graphics.line(p1.x - 1, p1.y - 1, p2.x - 1, p2.y - 1)
		love.graphics.line(p1.x, p1.y, p2.x, p2.y)
		love.graphics.line(p1.x + 1, p1.y + 1, p2.x + 1, p2.y + 1)
	end
end

return Dungeon