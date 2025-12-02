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

-- Remote Events
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local PlaceWallEvent = RemoteEvents:WaitForChild("PlaceWall")

-- Building Settings
local MAX_WALLS_PER_LIFE = 3
local WALL_LIFETIME = 10
local currentWallCount = 0

-- Build mode state
_G.BuildModeActive = false
local previewPart = nil
local canPlace = false
local currentRotationY = 0

-- Wall template
local wallTemplate = ReplicatedStorage:WaitForChild("WallTemplate")

-- Materials
local VALID_MATERIAL_COLOR = Color3.fromRGB(0, 255, 0)
local INVALID_MATERIAL_COLOR = Color3.fromRGB(255, 0, 0)
local PREVIEW_TRANSPARENCY = 0.5

-- UI
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
	
	-- Make all descendants transparent and non-collidable
	for _, child in pairs(previewPart:GetDescendants()) do
		if child:IsA("BasePart") then
			child. CanCollide = false
			child.Transparency = PREVIEW_TRANSPARENCY
		end
	end
	
	previewPart.Parent = workspace
	currentRotationY = 0
	
	-- Position upright in front of player
	local frontPosition = humanoidRootPart. Position + humanoidRootPart.CFrame.LookVector * 10
	local snappedPos = gridManager:SnapToGrid(frontPosition)
	
	-- KEY FIX: Make wall UPRIGHT (vertical)
	-- Orientation is (X, Y, Z) where X=pitch, Y=yaw, Z=roll
	-- Set X and Z to 0 to keep it vertical, only Y for rotation
	previewPart.CFrame = CFrame.new(snappedPos + Vector3.new(0, wallTemplate.Size.Y / 2, 0))
	previewPart. Orientation = Vector3.new(0, 0, 0) -- Completely upright
	
	print("Preview created upright!")
end

-- Update preview
local function updatePreview()
	if not previewPart or not _G.BuildModeActive then return end
	
	local mouse = player:GetMouse()
	local camera = workspace.CurrentCamera
	local mouseRay = camera:ScreenPointToRay(mouse.X, mouse.Y)
	
	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = {character, previewPart}
	raycastParams.FilterType = Enum. RaycastFilterType.Blacklist
	
	local rayResult = workspace:Raycast(mouseRay.Origin, mouseRay.Direction * 500, raycastParams)
	
	if rayResult then
		local hitPosition = rayResult.Position
		local snappedPos = gridManager:SnapToGrid(hitPosition)
		snappedPos = snappedPos + Vector3.new(0, wallTemplate.Size.Y / 2, 0)
		
		-- Keep wall UPRIGHT with Y rotation only
		previewPart.CFrame = CFrame.new(snappedPos) * CFrame.Angles(0, math.rad(currentRotationY), 0)
		
		-- Check validity
		local gridPos = gridManager:WorldToGrid(snappedPos)
		local wallData = wallTemplate:FindFirstChild("WallData")
		local sizeX = wallData and wallData.SizeX. Value or 1
		local sizeZ = wallData and wallData.SizeZ.Value or 1
		
		canPlace = currentWallCount < MAX_WALLS_PER_LIFE and 
		           gridManager:CanPlaceStructure(gridPos, sizeX, sizeZ)
		
		-- Update color
		local color = canPlace and VALID_MATERIAL_COLOR or INVALID_MATERIAL_COLOR
		previewPart.Color = color
		for _, child in pairs(previewPart:GetDescendants()) do
			if child:IsA("BasePart") then
				child.Color = color
			end
		end
	else
		-- Default position in front
		local frontPosition = humanoidRootPart.Position + humanoidRootPart.CFrame.LookVector * 10
		local snappedPos = gridManager:SnapToGrid(frontPosition)
		snappedPos = snappedPos + Vector3.new(0, wallTemplate.Size.Y / 2, 0)
		previewPart.CFrame = CFrame.new(snappedPos) * CFrame.Angles(0, math.rad(currentRotationY), 0)
	end
end

-- Place wall
local function placeWall()
	if not canPlace or currentWallCount >= MAX_WALLS_PER_LIFE then
		warn("Cannot place wall!  " .. currentWallCount .. "/" .. MAX_WALLS_PER_LIFE)
		return
	end
	
	local position = previewPart.CFrame.Position
	local rotationY = currentRotationY
	
	PlaceWallEvent:FireServer(position, rotationY)
	
	currentWallCount = currentWallCount + 1
	updateWallCountUI()
	
	print("Wall placed!  Remaining: " .. (MAX_WALLS_PER_LIFE - currentWallCount))
	toggleBuildMode()
end

-- Rotate preview
local function rotatePreview()
	if previewPart then
		currentRotationY = currentRotationY + 90
		if currentRotationY >= 360 then
			currentRotationY = 0
		end
		print("Rotated to: " .. currentRotationY ..  "°")
	end
end

-- Toggle build mode
function toggleBuildMode()
	_G.BuildModeActive = not _G.BuildModeActive
	
	if _G.BuildModeActive then
		print("Build mode ON")
		createPreview()
	else
		print("Build mode OFF")
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

-- Reset on death
function resetWallCount()
	currentWallCount = 0
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

humanoid.Died:Connect(resetWallCount)
updateWallCountUI()

print("✓ BuildingSystem loaded!")