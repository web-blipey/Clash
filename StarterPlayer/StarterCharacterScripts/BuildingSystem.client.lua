-- Place in StarterPlayer > StarterCharacterScripts

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = script.Parent
local humanoid = character:WaitForChild("Humanoid")
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

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

-- Build mode state - MAKE THIS ACCESSIBLE
_G.BuildModeActive = false -- Global variable that other scripts can access
local previewPart = nil
local canPlace = false

-- Wall template (reference to a part in ReplicatedStorage)
local wallTemplate = ReplicatedStorage:WaitForChild("WallTemplate")

-- Materials
local VALID_MATERIAL_COLOR = Color3.fromRGB(0, 255, 0)
local INVALID_MATERIAL_COLOR = Color3. fromRGB(255, 0, 0)
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
	
	-- Make all descendants non-collidable and transparent
	for _, child in pairs(previewPart:GetDescendants()) do
		if child:IsA("BasePart") then
			child. CanCollide = false
			child.Transparency = PREVIEW_TRANSPARENCY
		end
	end
	
	-- Put preview in workspace (not camera)
	previewPart.Parent = workspace
	
	-- Position it in front of player initially
	local frontPosition = humanoidRootPart. Position + humanoidRootPart.CFrame.LookVector * 10
	previewPart.CFrame = CFrame.new(frontPosition)
	
	print("Preview created and visible!")
end

-- Update preview position and validity
local function updatePreview()
	if not previewPart or not _G.BuildModeActive then return end
	
	-- Get mouse position in world
	local mouse = player:GetMouse()
	
	-- Raycast from camera to mouse position
	local camera = workspace.CurrentCamera
	local mouseRay = camera:ScreenPointToRay(mouse.X, mouse.Y)
	
	local raycastParams = RaycastParams. new()
	raycastParams. FilterDescendantsInstances = {character, previewPart}
	raycastParams.FilterType = Enum. RaycastFilterType.Blacklist
	
	local rayResult = workspace:Raycast(mouseRay.Origin, mouseRay.Direction * 500, raycastParams)
	
	if rayResult then
		local hitPosition = rayResult.Position
		
		-- Snap to grid
		local snappedPos = gridManager:SnapToGrid(hitPosition)
		snappedPos = snappedPos + Vector3.new(0, wallTemplate.Size.Y / 2, 0)
		
		-- Keep current Y rotation, don't reset it
		local currentRotation = previewPart.Orientation. Y
		previewPart.CFrame = CFrame.new(snappedPos) * CFrame.Angles(0, math.rad(currentRotation), 0)
		
		-- Check if placement is valid
		local gridPos = gridManager:WorldToGrid(snappedPos)
		local wallData = wallTemplate:FindFirstChild("WallData")
		local sizeX = wallData and wallData.SizeX. Value or 1
		local sizeZ = wallData and wallData.SizeZ.Value or 1
		
		canPlace = currentWallCount < MAX_WALLS_PER_LIFE and 
		           gridManager:CanPlaceStructure(gridPos, sizeX, sizeZ)
		
		-- Update preview color
		local color = canPlace and VALID_MATERIAL_COLOR or INVALID_MATERIAL_COLOR
		previewPart. Color = color
		for _, child in pairs(previewPart:GetDescendants()) do
			if child:IsA("BasePart") then
				child.Color = color
			end
		end
	else
		-- If no hit, place in front of player
		local frontPosition = humanoidRootPart.Position + humanoidRootPart.CFrame.LookVector * 10
		local snappedPos = gridManager:SnapToGrid(frontPosition)
		snappedPos = snappedPos + Vector3.new(0, wallTemplate.Size.Y / 2, 0)
		previewPart.CFrame = CFrame.new(snappedPos)
	end
end

-- Place wall
local function placeWall()
	if not canPlace or currentWallCount >= MAX_WALLS_PER_LIFE then
		warn("Cannot place wall!  " .. currentWallCount .. "/" .. MAX_WALLS_PER_LIFE)
		return
	end
	
	local position = previewPart.CFrame. Position
	local rotation = previewPart. Orientation
	
	-- Send to server to create wall
	PlaceWallEvent:FireServer(position, rotation)
	
	currentWallCount = currentWallCount + 1
	updateWallCountUI()
	
	print("Wall placed! Remaining: " .. (MAX_WALLS_PER_LIFE - currentWallCount))
	
	-- Exit build mode after placing
	toggleBuildMode()
end

-- Rotate preview
local function rotatePreview()
	if previewPart then
		local currentY = previewPart. Orientation.Y
		previewPart.Orientation = Vector3.new(0, currentY + 90, 0)
		print("Preview rotated to: " .. (currentY + 90))
	end
end

-- Toggle build mode
function toggleBuildMode()
	_G.BuildModeActive = not _G.BuildModeActive
	
	if _G.BuildModeActive then
		print("Build mode ACTIVATED")
		createPreview()
	else
		print("Build mode DEACTIVATED")
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
	print("Wall count reset!")
end

-- Input handling
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	
	if input.KeyCode == Enum.KeyCode.B then
		toggleBuildMode()
	elseif input.KeyCode == Enum.KeyCode.R and _G.BuildModeActive then
		rotatePreview()
	elseif input.UserInputType == Enum.UserInputType.MouseButton1 and _G.BuildModeActive then
		placeWall()
	end
end)

-- Update preview every frame
RunService.RenderStepped:Connect(function()
	if _G.BuildModeActive then
		updatePreview()
	end
end)

-- Listen for humanoid death to reset walls
humanoid.Died:Connect(function()
	resetWallCount()
end)

-- Initialize
updateWallCountUI()
print("BuildingSystem loaded!")