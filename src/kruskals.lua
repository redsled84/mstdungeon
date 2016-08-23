local UnionFind = require "src.unionfind"

local function Kruskals(V, E)
	-- Initialize the SetMap and sets tables
	UnionFind:initialize()
	-- Loop the graph's vertices
	for i = 1, #V do
		local v = V[i]
		-- Insert individual sets into the SetMap
		UnionFind.sets[#UnionFind.sets+1] = UnionFind.makeSet(v)
	end

	-- Initialize a table to store MST values
	local T = {}
	-- Loop the graph's edges
	for i = 1, #E do
		local edge = E[i]
		-- Getting vertices from edges (In this case the points [p1, p2] stored in each edge)
		local p1, p2 = edge.p1, edge.p2
		-- Get the sets from the SetMap from inputting a vertice
		local u, v = UnionFind.getSetFromValue(V, p1), UnionFind.getSetFromValue(V, p2)
		-- If sets don't have the same root
		if UnionFind.findSet(u) ~= UnionFind.findSet(v) then
			-- Add edge to minimum spanning tree table
			T[#T+1] = edge
			-- Union sets
			UnionFind.union(u, v)
		end
	end

	-- Return the MST
	return T
end

return Kruskals