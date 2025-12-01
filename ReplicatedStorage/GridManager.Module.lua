-- Place in ReplicatedStorage as a ModuleScript

local GridManager = {}
GridManager.__index = GridManager

function GridManager. new(gridSize, gridWidth, gridHeight)
	local self = setmetatable({}, GridManager)
	
	self.gridSize = gridSize or 4 -- Size of each grid cell in studs
	self.gridWidth = gridWidth or 100
	self.gridHeight = gridHeight or 100
	self.gridCells = {} -- Dictionary of occupied cells
	
	return self
end

-- Snap world position to grid
function GridManager:SnapToGrid(position)
	local snappedX = math.floor(position.X / self.gridSize + 0.5) * self. gridSize
	local snappedZ = math.floor(position.Z / self.gridSize + 0.5) * self.gridSize
	return Vector3. new(snappedX, position.Y, snappedZ)
end

-- Convert world position to grid coordinates
function GridManager:WorldToGrid(position)
	local gridX = math.floor(position.X / self.gridSize + 0.5)
	local gridZ = math.floor(position.Z / self.gridSize + 0.5)
	return Vector2.new(gridX, gridZ)
end

-- Convert grid coordinates to world position
function GridManager:GridToWorld(gridPos, yPosition)
	yPosition = yPosition or 0
	return Vector3.new(
		gridPos.X * self. gridSize,
		yPosition,
		gridPos.Y * self.gridSize
	)
end

-- Check if a cell is available
function GridManager:IsCellAvailable(gridPos)
	local key = tostring(gridPos.X) ..  "," .. tostring(gridPos.Y)
	return self. gridCells[key] == nil
end

-- Check if multiple cells are available for a structure
function GridManager:CanPlaceStructure(gridPos, sizeX, sizeZ)
	for x = 0, sizeX - 1 do
		for z = 0, sizeZ - 1 do
			local checkPos = Vector2.new(gridPos.X + x, gridPos.Y + z)
			if not self:IsCellAvailable(checkPos) then
				return false
			end
		end
	end
	return true
end

-- Occupy a cell with a structure
function GridManager:OccupyCell(gridPos, structure)
	local key = tostring(gridPos.X) .. "," .. tostring(gridPos. Y)
	self.gridCells[key] = structure
end

-- Free a cell
function GridManager:FreeCell(gridPos)
	local key = tostring(gridPos.X) .. "," .. tostring(gridPos.Y)
	self. gridCells[key] = nil
end

-- Occupy multiple cells for a structure
function GridManager:OccupyStructure(gridPos, sizeX, sizeZ, structure)
	for x = 0, sizeX - 1 do
		for z = 0, sizeZ - 1 do
			local cellPos = Vector2.new(gridPos.X + x, gridPos.Y + z)
			self:OccupyCell(cellPos, structure)
		end
	end
end

-- Free multiple cells for a structure
function GridManager:FreeStructure(gridPos, sizeX, sizeZ)
	for x = 0, sizeX - 1 do
		for z = 0, sizeZ - 1 do
			local cellPos = Vector2.new(gridPos.X + x, gridPos.Y + z)
			self:FreeCell(cellPos)
		end
	end
end

return GridManager