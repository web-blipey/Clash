-- Place in StarterPlayer > StarterCharacterScripts

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = script.Parent
local humanoid = character:WaitForChild("Humanoid")
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local camera = workspace.CurrentCamera

-- Camera Settings
local CAMERA_DISTANCE = 8
local CAMERA_HEIGHT = 2
local CAMERA_SIDE_OFFSET = 2
local CAMERA_SMOOTHNESS = 0.2
local MOUSE_SENSITIVITY = 0.003
local COMBAT_FOV = 70

-- Camera angles
local cameraAngleX = 0
local cameraAngleY = 0
local isActive = false

-- Wait for UI
task.wait(0.5)
local playerGui = player:WaitForChild("PlayerGui")
local screenGui = playerGui:WaitForChild("BuildingUI")

-- Create crosshair
local crosshair = Instance.new("ImageLabel")
crosshair.Name = "Crosshair"
crosshair.Size = UDim2.new(0, 20, 0, 20)
crosshair.Position = UDim2.new(0.5, -10, 0.5, -10)
crosshair.BackgroundTransparency = 1
crosshair.Image = "rbxasset://textures/ui/MouseLockedCursor.png"
crosshair. ImageColor3 = Color3.fromRGB(255, 255, 255)
crosshair.ImageTransparency = 0.3
crosshair.Parent = screenGui

-- Disable default camera controls
task.spawn(function()
	local playerScripts = player:WaitForChild("PlayerScripts")
	local playerModule = require(playerScripts:WaitForChild("PlayerModule"))
	
	-- Get camera module
	local cameraModule = playerModule:GetCameras()
	
	-- Disable it
	if cameraModule then
		cameraModule:GetActiveCamera():Disconnect()
		print("✓ Default camera disabled")
	end
end)

-- Initialize camera
local function initializeCamera()
	-- Set camera to scriptable
	camera.CameraType = Enum. CameraType.Scriptable
	
	-- Lock mouse to center
	UserInputService. MouseBehavior = Enum. MouseBehavior.LockCenter
	UserInputService.MouseIconEnabled = false
	
	-- Reset angles to face forward
	cameraAngleX = 0
	cameraAngleY = 0
	
	isActive = true
	
	print("✓ Shift Lock Camera Active")
	print("   Camera Distance:", CAMERA_DISTANCE)
end

-- Update camera every frame
local function updateCamera()
	if not isActive then return end
	if not character or not character.Parent then return end
	if not humanoidRootPart or not humanoidRootPart.Parent then return end
	if not humanoid or humanoid.Health <= 0 then return end
	
	-- Force camera type
	camera.CameraType = Enum. CameraType.Scriptable
	
	-- Get mouse delta
	local mouseDelta = UserInputService:GetMouseDelta()
	
	-- Update camera angles from mouse movement
	cameraAngleY = cameraAngleY - (mouseDelta.X * MOUSE_SENSITIVITY)
	cameraAngleX = cameraAngleX - (mouseDelta.Y * MOUSE_SENSITIVITY)
	
	-- Clamp vertical angle
	cameraAngleX = math.clamp(cameraAngleX, -1. 4, 1.4)
	
	-- Rotate character to face camera direction (SHIFT LOCK BEHAVIOR)
	local targetRotation = CFrame.new(humanoidRootPart. Position) * CFrame.Angles(0, cameraAngleY, 0)
	humanoidRootPart.CFrame = CFrame.new(humanoidRootPart. Position, humanoidRootPart.Position + targetRotation.LookVector)
	
	-- Calculate camera position behind character
	local characterPosition = humanoidRootPart.Position
	
	-- Horizontal rotation (around character)
	local horizontalAngle = CFrame.Angles(0, cameraAngleY, 0)
	
	-- Vertical rotation (camera tilt)
	local verticalAngle = CFrame.Angles(cameraAngleX, 0, 0)
	
	-- Combine rotations and apply offset
	local cameraOffset = horizontalAngle * verticalAngle * Vector3.new(CAMERA_SIDE_OFFSET, CAMERA_HEIGHT, CAMERA_DISTANCE)
	
	-- Final camera position
	local cameraPosition = characterPosition + cameraOffset
	
	-- Where the camera looks (slightly above character center)
	local lookAtPosition = characterPosition + Vector3.new(0, 1. 5, 0)
	
	-- Create final camera CFrame
	local newCameraCFrame = CFrame.lookAt(cameraPosition, lookAtPosition)
	
	-- Apply with smoothing
	camera.CFrame = camera.CFrame:Lerp(newCameraCFrame, CAMERA_SMOOTHNESS)
	
	-- Set field of view
	camera. FieldOfView = COMBAT_FOV
end

-- Start camera system
task.wait(0.2)
initializeCamera()

-- Update every frame
RunService.RenderStepped:Connect(updateCamera)

-- Handle respawn
player.CharacterAdded:Connect(function(newCharacter)
	character = newCharacter
	humanoid = character:WaitForChild("Humanoid")
	humanoidRootPart = character:WaitForChild("HumanoidRootPart")
	
	task.wait(0.2)
	initializeCamera()
end)

print("✓ Shift Lock Camera System Loaded")