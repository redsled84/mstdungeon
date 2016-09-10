local UnionFind = {}

function UnionFind:initialize()
	self.SetMap = {}
	self.sets = {}
end

function UnionFind.makeSet(value)
	local set = {}

	set.value = value
	set.rank = 0
	set.parent = set
	UnionFind.SetMap[set] = set

	return set
end

function UnionFind.findSet(x)
	local parent = x
	
	if parent ~= parent.parent then
		parent = UnionFind.findSet(parent.parent)
	end
	
	return parent
end

--little helper function for getting the set associated with a given point (vertex)
function UnionFind.getSetFromValue(t, value)
	for i = 1, #t do
		local v = t[i]
		if v == value then
			return UnionFind.sets[i]
		end
	end
end

function UnionFind.union(x, y)
	local xRoot = UnionFind.findSet(x)
	local yRoot = UnionFind.findSet(y)

	if xRoot.value == yRoot.value then return end

	if xRoot.rank >= yRoot.rank then
		if xRoot.rank == yRoot.rank then xRoot.rank = xRoot.rank + 1 end
		yRoot.parent = xRoot
	else
		xRoot.parent = yRoot
	end
end

return UnionFind