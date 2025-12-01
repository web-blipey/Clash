-- Place in ServerScriptService

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Debris = game:GetService("Debris")

-- Load GridManager
local GridManager = require(ReplicatedStorage:WaitForChild("GridManager"))
local gridManager = GridManager.new(4, 100, 100)

-- Remote Events folder
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local PlaceWallEvent = RemoteEvents:WaitForChild("PlaceWall")
local DestroyWallEvent = RemoteEvents:WaitForChild("DestroyWall")

-- Wall settings
local WALL_LIFETIME = 10
local WALL_MAX_HEALTH = 100

-- Wall template
local wallTemplate = ReplicatedStorage:WaitForChild("WallTemplate")

-- Walls folder in workspace
local wallsFolder = workspace:FindFirstChild("Walls")
if not wallsFolder then
	wallsFolder = Instance.new("Folder")
	wallsFolder. Name = "Walls"
	wallsFolder.Parent = workspace
end

-- Player wall tracking
local playerWalls = {} -- [player] = {wall1, wall2, wall3}

-- Place wall function
local function placeWall(player, position, rotation)
	-- Create wall
	local wall = wallTemplate:Clone()
	wall.Name = player.Name .. "_Wall"
	wall.CFrame = CFrame.new(position) * CFrame.Angles(0, math.rad(rotation.Y), 0)
	wall. Transparency = 0
	wall. CanCollide = true
	wall. Anchored = true

	-- Add ownership data
	local ownerValue = Instance.new("StringValue")
	ownerValue. Name = "Owner"
	ownerValue.Value = player.Name
	ownerValue.Parent = wall

	-- Add health data
	local healthValue = Instance.new("NumberValue")
	healthValue.Name = "Health"
	healthValue.Value = WALL_MAX_HEALTH
	healthValue.Parent = wall

	local maxHealthValue = Instance.new("NumberValue")
	maxHealthValue. Name = "MaxHealth"
	maxHealthValue.Value = WALL_MAX_HEALTH
	maxHealthValue.Parent = wall

	-- Add placement time
	local placementTime = Instance.new("NumberValue")
	placementTime.Name = "PlacementTime"
	placementTime.Value = tick()
	placementTime.Parent = wall

	-- Get wall size from template
	local wallData = wall:FindFirstChild("WallData")
	local sizeX = wallData and wallData.SizeX.Value or 1
	local sizeZ = wallData and wallData.SizeZ.Value or 1

	-- Mark grid as occupied
	local gridPos = gridManager:WorldToGrid(position)
	gridManager:OccupyStructure(gridPos, sizeX, sizeZ, wall)

	-- Store grid position for cleanup
	local gridPosValue = Instance.new("Vector3Value")
	gridPosValue.Name = "GridPosition"
	gridPosValue.Value = Vector3.new(gridPos.X, gridPos.Y, 0)
	gridPosValue.Parent = wall

	local gridSizeValue = Instance.new("Vector3Value")
	gridSizeValue.Name = "GridSize"
	gridSizeValue.Value = Vector3.new(sizeX, sizeZ, 0)
	gridSizeValue.Parent = wall

	wall.Parent = wallsFolder

	-- Track player's walls
	if not playerWalls[player] then
		playerWalls[player] = {}
	end
	table.insert(playerWalls[player], wall)

	-- Auto-destroy after lifetime
	Debris:AddItem(wall, WALL_LIFETIME)

	-- Clean up grid when destroyed
	wall. AncestryChanged:Connect(function(_, parent)
		if parent == nil then
			local gridPosVal = wall:FindFirstChild("GridPosition")
			local gridSizeVal = wall:FindFirstChild("GridSize")
			if gridPosVal and gridSizeVal then
				local gPos = Vector2.new(gridPosVal. Value.X, gridPosVal.Value.Y)
				local gSize = gridSizeVal.Value
				gridManager:FreeStructure(gPos, gSize.X, gSize.Y)
			end

			-- Remove from player tracking
			if playerWalls[player] then
				for i, w in ipairs(playerWalls[player]) do
					if w == wall then
						table.remove(playerWalls[player], i)
						break
					end
				end
			end
		end
	end)

	print(player.Name .. " placed a wall!")
end

-- Damage wall function
local function damageWall(wall, damage, attacker)
	local healthValue = wall:FindFirstChild("Health")
	if not healthValue then return end

	healthValue.Value = healthValue.Value - damage

	-- Update visual based on health
	local healthPercent = healthValue.Value / wall.MaxHealth. Value
	if healthPercent < 0.3 then
		wall.Color = Color3.fromRGB(139, 69, 19) -- Damaged brown
	end

	-- Destroy if health depleted
	if healthValue.Value <= 0 then
		-- Create destruction effect
		local explosion = Instance.new("Explosion")
		explosion.Position = wall. Position
		explosion.BlastRadius = 5
		explosion.BlastPressure = 0 -- No damage to players
		explosion.Parent = workspace

		wall:Destroy()
		print("Wall destroyed by " .. (attacker and attacker.Name or "unknown"))
	end
end

-- Listen for wall placement requests
PlaceWallEvent.OnServerEvent:Connect(placeWall)

-- Export damage function for other scripts
_G.DamageWall = damageWall