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
local CAMERA_SMOOTHNESS = 0.15
local MOUSE_SENSITIVITY = 0.003
local COMBAT_FOV = 70

-- Camera angles
local cameraAngleX = 0
local cameraAngleY = 0

-- UI
local playerGui = player:WaitForChild("PlayerGui")
local screenGui = playerGui:WaitForChild("BuildingUI")

-- Create crosshair
local crosshair = Instance.new("ImageLabel")
crosshair.Name = "Crosshair"
crosshair.Size = UDim2. new(0, 20, 0, 20)
crosshair.Position = UDim2.new(0.5, -10, 0.5, -10)
crosshair.BackgroundTransparency = 1
crosshair.Image = "rbxasset://textures/ui/MouseLockedCursor.png"
crosshair. ImageColor3 = Color3.fromRGB(255, 255, 255)
crosshair.ImageTransparency = 0.3
crosshair.Parent = screenGui

-- FORCE camera settings
camera.CameraType = Enum. CameraType. Scriptable
UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
UserInputService.MouseIconEnabled = false

-- Update camera every frame
local function updateCamera()
	if not character or not character.Parent then return end
	if not humanoidRootPart or not humanoidRootPart.Parent then return end
	if not humanoid or humanoid.Health <= 0 then return end
	
	-- Get mouse delta
	local mouseDelta = UserInputService:GetMouseDelta()
	
	-- Update camera angles
	cameraAngleY = cameraAngleY - mouseDelta.X * MOUSE_SENSITIVITY
	cameraAngleX = cameraAngleX - mouseDelta.Y * MOUSE_SENSITIVITY
	cameraAngleX = math.clamp(cameraAngleX, -1. 4, 1.4)
	
	-- Rotate character to face camera direction
	local targetCFrame = CFrame.new(humanoidRootPart.Position) * CFrame.Angles(0, cameraAngleY, 0)
	humanoidRootPart.CFrame = humanoidRootPart.CFrame:Lerp(targetCFrame, 0.3)
	
	-- Calculate camera position
	local rootPosition = humanoidRootPart. Position
	
	-- Create rotation CFrame
	local horizontalRotation = CFrame. Angles(0, cameraAngleY, 0)
	local verticalRotation = CFrame. Angles(cameraAngleX, 0, 0)
	
	-- Calculate offset from character
	local offset = horizontalRotation * verticalRotation * Vector3.new(CAMERA_SIDE_OFFSET, CAMERA_HEIGHT, CAMERA_DISTANCE)
	
	-- Final camera position
	local cameraPosition = rootPosition + offset
	
	-- Focus point (slightly above character's center)
	local focusPosition = rootPosition + Vector3.new(0, 1. 5, 0)
	
	-- Create camera CFrame looking at character
	local targetCameraFrame = CFrame.lookAt(cameraPosition, focusPosition)
	
	-- Smooth transition
	camera.CFrame = camera.CFrame:Lerp(targetCameraFrame, CAMERA_SMOOTHNESS)
	camera. FieldOfView = COMBAT_FOV
	
	-- Keep camera type locked
	if camera.CameraType ~= Enum.CameraType. Scriptable then
		camera. CameraType = Enum.CameraType.Scriptable
	end
end

-- Connect to RenderStepped
RunService. RenderStepped:Connect(updateCamera)

-- Handle respawn
player.CharacterAdded:Connect(function(newCharacter)
	character = newCharacter
	humanoid = character:WaitForChild("Humanoid")
	humanoidRootPart = character:WaitForChild("HumanoidRootPart")
	
	cameraAngleX = 0
	cameraAngleY = 0
	
	task.wait(0.1)
	camera.CameraType = Enum. CameraType.Scriptable
	UserInputService.MouseBehavior = Enum.MouseBehavior. LockCenter
	UserInputService.MouseIconEnabled = false
end)

print("✓ Third Person Camera Loaded!")