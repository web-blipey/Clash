-- Place in StarterPlayer > StarterCharacterScripts

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = script.Parent
local humanoid = character:WaitForChild("Humanoid")

-- Load GridManager
local GridManager = require(ReplicatedStorage:WaitForChild("GridManager"))
local gridManager = GridManager.new(4, 100, 100)

-- Remote Events (create these in ReplicatedStorage)
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local PlaceWallEvent = RemoteEvents:WaitForChild("PlaceWall")
local DestroyWallEvent = RemoteEvents:WaitForChild("DestroyWall")

-- Building Settings
local MAX_WALLS_PER_LIFE = 3
local WALL_LIFETIME = 10 -- seconds
local currentWallCount = 0
local placedWalls = {}

-- Build mode state
local buildModeActive = false
local previewPart = nil
local canPlace = false

-- Wall template (reference to a part in ReplicatedStorage)
local wallTemplate = ReplicatedStorage:WaitForChild("WallTemplate")

-- Materials
local VALID_MATERIAL_COLOR = Color3.fromRGB(0, 255, 0)
local INVALID_MATERIAL_COLOR = Color3.fromRGB(255, 0, 0)
local PREVIEW_TRANSPARENCY = 0.5

-- UI Elements
local playerGui = player:WaitForChild("PlayerGui")
local screenGui = playerGui:WaitForChild("BuildingUI")
local wallCountLabel = screenGui:WaitForChild("WallCountLabel")

-- Create preview part
local function createPreview()
	if previewPart then
		previewPart:Destroy()
	end
	
	previewPart = wallTemplate:Clone()
	previewPart.Name = "WallPreview"
	previewPart. CanCollide = false
	previewPart.Anchored = true
	previewPart. Transparency = PREVIEW_TRANSPARENCY
	previewPart.Parent = workspace
	
	-- Make all descendants non-collidable
	for _, child in pairs(previewPart:GetDescendants()) do
		if child:IsA("BasePart") then
			child. CanCollide = false
			child.Transparency = PREVIEW_TRANSPARENCY
		end
	end
	
	previewPart.Parent = workspace. CurrentCamera
end

-- Update preview position and validity
local function updatePreview()
	if not previewPart or not buildModeActive then return end
	
	local mouse = player:GetMouse()
	local ray = Ray.new(mouse.Hit.Position, Vector3.new(0, -100, 0))
	local hit, position = workspace:FindPartOnRay(ray, character)
	
	if hit then
		-- Snap to grid
		local snappedPos = gridManager:SnapToGrid(position)
		snappedPos = snappedPos + Vector3.new(0, wallTemplate.Size.Y / 2, 0)
		previewPart.CFrame = CFrame.new(snappedPos) * CFrame. Angles(0, math.rad(previewPart.Orientation.Y), 0)
		
		-- Check if placement is valid
		local gridPos = gridManager:WorldToGrid(snappedPos)
		local wallSize = wallTemplate:FindFirstChild("WallData")
		local sizeX = wallSize and wallSize.SizeX. Value or 1
		local sizeZ = wallSize and wallSize.SizeZ.Value or 1
		
		canPlace = currentWallCount < MAX_WALLS_PER_LIFE and 
		           gridManager:CanPlaceStructure(gridPos, sizeX, sizeZ)
		
		-- Update preview color
		local color = canPlace and VALID_MATERIAL_COLOR or INVALID_MATERIAL_COLOR
		for _, child in pairs(previewPart:GetDescendants()) do
			if child:IsA("BasePart") then
				child.Color = color
			end
		end
	end
end

-- Place wall
local function placeWall()
	if not canPlace or currentWallCount >= MAX_WALLS_PER_LIFE then
		warn("Cannot place wall!")
		return
	end
	
	local position = previewPart.CFrame. Position
	local rotation = previewPart. Orientation
	
	-- Send to server to create wall
	PlaceWallEvent:FireServer(position, rotation)
	
	currentWallCount = currentWallCount + 1
	updateWallCountUI()
	
	-- Exit build mode after placing
	toggleBuildMode()
end

-- Rotate preview
local function rotatePreview()
	if previewPart then
		local currentY = previewPart. Orientation.Y
		previewPart.Orientation = Vector3.new(0, currentY + 90, 0)
	end
end

-- Toggle build mode
function toggleBuildMode()
	buildModeActive = not buildModeActive
	
	if buildModeActive then
		createPreview()
	else
		if previewPart then
			previewPart:Destroy()
			previewPart = nil
		end
	end
end

-- Update wall count UI
function updateWallCountUI()
	local remaining = MAX_WALLS_PER_LIFE - currentWallCount
	wallCountLabel.Text = string.format("Walls: %d/%d", remaining, MAX_WALLS_PER_LIFE)
end

-- Reset wall count on respawn
function resetWallCount()
	currentWallCount = 0
	placedWalls = {}
	updateWallCountUI()
end

-- Input handling
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	
	if input.KeyCode == Enum.KeyCode.B then
		toggleBuildMode()
	elseif input.KeyCode == Enum.KeyCode.R and buildModeActive then
		rotatePreview()
	elseif input.UserInputType == Enum.UserInputType.MouseButton1 and buildModeActive then
		placeWall()
	end
end)

-- Update preview every frame
RunService.RenderStepped:Connect(function()
	if buildModeActive then
		updatePreview()
	end
end)

-- Listen for humanoid death to reset walls
humanoid.Died:Connect(function()
	resetWallCount()
end)

-- Initialize
updateWallCountUI()