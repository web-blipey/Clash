-- Place in StarterPlayer > StarterCharacterScripts

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = script.Parent
local humanoid = character:WaitForChild("Humanoid")
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local camera = workspace.CurrentCamera

-- FORCE DISABLE DEFAULT CONTROLS
player.CameraMaxZoomDistance = 0. 5
player.CameraMinZoomDistance = 0.5
player.CameraMode = Enum. CameraMode.LockFirstPerson

-- Wait for PlayerModule to load, then disable it
local PlayerModule
local success = pcall(function()
	PlayerModule = require(player:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule"))
end)

if success and PlayerModule then
	local CameraModule = PlayerModule:GetCameras()
	if CameraModule then
		-- Disable the default camera
		pcall(function()
			CameraModule:Update() -- Stop default updates
		end)
	end
end

-- Shoulder Surf Settings (Elden Ring style)
local CAMERA_OFFSET = Vector3.new(2, 2, 8) -- Right shoulder offset (X, Y, Distance)
local CAMERA_HEIGHT_OFFSET = 1.5 -- Additional height above character
local CAMERA_SMOOTHNESS = 0.15 -- Lower = smoother, higher = snappier
local MOUSE_SENSITIVITY = 0.003

-- Combat Camera Settings
local COMBAT_FOV = 70

-- Camera angles
local cameraAngleX = 0
local cameraAngleY = 0

-- UI for crosshair
local playerGui = player:WaitForChild("PlayerGui")
local screenGui = playerGui:WaitForChild("BuildingUI")

-- Create crosshair indicator
local crosshair = Instance.new("ImageLabel")
crosshair.Name = "Crosshair"
crosshair.Size = UDim2. new(0, 20, 0, 20)
crosshair.Position = UDim2.new(0. 5, -10, 0.5, -10)
crosshair.BackgroundTransparency = 1
crosshair.Image = "rbxasset://textures/ui/MouseLockedCursor.png"
crosshair. ImageColor3 = Color3.fromRGB(255, 255, 255)
crosshair.ImageTransparency = 0.3
crosshair.Parent = screenGui

-- FORCE camera to scriptable
camera.CameraType = Enum. CameraType.Scriptable

-- FORCE lock mouse to center
task.wait(0.5) -- Wait for everything to load
UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
UserInputService.MouseIconEnabled = false

-- Prevent camera from reverting
game:GetService("RunService"). RenderStepped:Connect(function()
	-- Keep forcing camera type
	if camera.CameraType ~= Enum.CameraType. Scriptable then
		camera. CameraType = Enum.CameraType.Scriptable
	end
	
	-- Keep forcing mouse lock
	if UserInputService.MouseBehavior ~= Enum.MouseBehavior.LockCenter then
		UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
	end
end)

-- Update camera position and rotation
local function updateCamera()
	if not character or not character.Parent then return end
	if not humanoidRootPart or not humanoidRootPart.Parent then return end
	if not humanoid or humanoid.Health <= 0 then return end
	
	-- Get mouse delta for camera rotation
	local mouseDelta = UserInputService:GetMouseDelta()
	
	-- Rotate camera based on mouse movement
	cameraAngleX = cameraAngleX - mouseDelta.Y * MOUSE_SENSITIVITY
	cameraAngleY = cameraAngleY - mouseDelta. X * MOUSE_SENSITIVITY
	
	-- Clamp vertical angle (prevent camera from going too high/low)
	cameraAngleX = math.clamp(cameraAngleX, -1. 4, 1.4) -- ~80 degrees up/down
	
	-- Rotate character to face camera direction (only horizontal)
	local targetCFrame = CFrame.new(humanoidRootPart. Position) * CFrame.Angles(0, cameraAngleY, 0)
	humanoidRootPart.CFrame = humanoidRootPart.CFrame:Lerp(targetCFrame, 0.3)
	
	-- Calculate camera position (Elden Ring style over-the-shoulder)
	local heightOffset = Vector3.new(0, CAMERA_HEIGHT_OFFSET, 0)
	local focusPoint = humanoidRootPart.Position + heightOffset
	
	-- Create camera CFrame with offset
	local cameraCFrame = CFrame.new(humanoidRootPart.Position)
		* CFrame.Angles(0, cameraAngleY, 0) -- Horizontal rotation
		* CFrame. Angles(cameraAngleX, 0, 0) -- Vertical rotation
		* CFrame. new(CAMERA_OFFSET) -- Apply offset (right shoulder)
	
	-- Smooth camera movement
	camera.CFrame = camera.CFrame:Lerp(cameraCFrame, CAMERA_SMOOTHNESS)
	
	-- Make camera look at focus point (slightly above character)
	camera.CFrame = CFrame.new(camera.CFrame.Position, focusPoint)
	
	-- Set FOV
	camera.FieldOfView = COMBAT_FOV
end

-- Initialize camera on spawn
local function initializeCamera()
	task.wait(0.2) -- Wait for character to fully load
	
	-- Force settings
	camera.CameraType = Enum.CameraType. Scriptable
	UserInputService.MouseBehavior = Enum.MouseBehavior. LockCenter
	UserInputService.MouseIconEnabled = false
	
	-- Reset camera angles
	cameraAngleX = 0
	cameraAngleY = 0
	
	print("✓ Shift Lock Camera: ACTIVE (Always On)")
end

-- Update camera every frame
RunService.RenderStepped:Connect(updateCamera)

-- Handle character respawn
player.CharacterAdded:Connect(function(newCharacter)
	character = newCharacter
	humanoid = character:WaitForChild("Humanoid")
	humanoidRootPart = character:WaitForChild("HumanoidRootPart")
	
	initializeCamera()
end)

-- Initialize on first load
initializeCamera()

print("✓ Custom ShiftLock Camera Loaded!")