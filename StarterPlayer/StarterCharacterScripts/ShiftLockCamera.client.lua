-- Place in StarterPlayer > StarterCharacterScripts

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = script.Parent
local humanoid = character:WaitForChild("Humanoid")
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local camera = workspace.CurrentCamera

-- Shoulder Surf Settings (Elden Ring style)
local CAMERA_OFFSET = Vector3.new(2, 2, 8) -- Right shoulder offset
local CAMERA_HEIGHT_OFFSET = 1.5
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

-- Set camera to scriptable FIRST
camera.CameraType = Enum.CameraType.Scriptable
camera.CameraSubject = humanoid

-- Initialize immediately
task.spawn(function()
	-- Small delay to ensure character is loaded
	task.wait(0.1)
	
	-- Force third person settings
	UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
	UserInputService.MouseIconEnabled = false
	
	-- Set initial camera position (THIRD PERSON)
	local initialCFrame = CFrame.new(humanoidRootPart.Position)
		* CFrame.new(CAMERA_OFFSET)
	camera.CFrame = initialCFrame
	
	print("✓ Camera initialized in THIRD PERSON")
end)

-- Update camera position and rotation
local function updateCamera()
	if not character or not character. Parent then return end
	if not humanoidRootPart or not humanoidRootPart. Parent then return end
	if not humanoid or humanoid.Health <= 0 then return end
	
	-- Get mouse delta for camera rotation
	local mouseDelta = UserInputService:GetMouseDelta()
	
	-- Rotate camera based on mouse movement
	cameraAngleX = cameraAngleX - mouseDelta.Y * MOUSE_SENSITIVITY
	cameraAngleY = cameraAngleY - mouseDelta. X * MOUSE_SENSITIVITY
	
	-- Clamp vertical angle
	cameraAngleX = math.clamp(cameraAngleX, -1. 4, 1.4)
	
	-- Rotate character to face camera direction (smoothly)
	local targetCFrame = CFrame.new(humanoidRootPart.Position) * CFrame.Angles(0, cameraAngleY, 0)
	humanoidRootPart.CFrame = humanoidRootPart.CFrame:Lerp(targetCFrame, 0.3)
	
	-- Calculate focus point
	local heightOffset = Vector3.new(0, CAMERA_HEIGHT_OFFSET, 0)
	local focusPoint = humanoidRootPart.Position + heightOffset
	
	-- Create camera CFrame with offset (THIRD PERSON)
	local cameraCFrame = CFrame.new(humanoidRootPart.Position)
		* CFrame. Angles(0, cameraAngleY, 0)
		* CFrame. Angles(cameraAngleX, 0, 0)
		* CFrame.new(CAMERA_OFFSET) -- This creates the distance! 
	
	-- Smooth camera movement
	camera.CFrame = camera.CFrame:Lerp(cameraCFrame, CAMERA_SMOOTHNESS)
	
	-- Make camera look at focus point
	camera.CFrame = CFrame.new(camera.CFrame.Position, focusPoint)
	
	-- Set FOV
	camera.FieldOfView = COMBAT_FOV
	
	-- Keep camera type locked
	if camera.CameraType ~= Enum.CameraType. Scriptable then
		camera. CameraType = Enum.CameraType.Scriptable
	end
end

-- Update every frame
RunService.RenderStepped:Connect(updateCamera)

-- Handle respawn
player.CharacterAdded:Connect(function(newCharacter)
	character = newCharacter
	humanoid = character:WaitForChild("Humanoid")
	humanoidRootPart = character:WaitForChild("HumanoidRootPart")
	
	cameraAngleX = 0
	cameraAngleY = 0
	
	task.wait(0.1)
	camera.CameraType = Enum. CameraType.Scriptable
	camera.CameraSubject = humanoid
	UserInputService.MouseBehavior = Enum.MouseBehavior. LockCenter
	UserInputService.MouseIconEnabled = false
end)

print("✓ ShiftLock Camera Loaded (Third Person)")