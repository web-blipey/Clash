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
local CAMERA_OFFSET = Vector3.new(2, 2, 8) -- Right shoulder offset (X, Y, Distance from character)
local CAMERA_HEIGHT_OFFSET = 1. 5
local CAMERA_SMOOTHNESS = 0. 15
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
crosshair. ImageColor3 = Color3. fromRGB(255, 255, 255)
crosshair.ImageTransparency = 0.3
crosshair.Parent = screenGui

-- Set camera to scriptable
camera.CameraType = Enum.CameraType. Scriptable
camera.CameraSubject = humanoid

-- Initialize
task.spawn(function()
	task.wait(0.1)
	
	UserInputService.MouseBehavior = Enum.MouseBehavior. LockCenter
	UserInputService.MouseIconEnabled = false
	
	print("✓ Camera initialized in THIRD PERSON")
end)

-- Update camera position and rotation
local function updateCamera()
	if not character or not character. Parent then return end
	if not humanoidRootPart or not humanoidRootPart.Parent then return end
	if not humanoid or humanoid.Health <= 0 then return end
	
	-- Get mouse delta for camera rotation
	local mouseDelta = UserInputService:GetMouseDelta()
	
	-- Rotate camera based on mouse movement
	cameraAngleX = cameraAngleX - mouseDelta.Y * MOUSE_SENSITIVITY
	cameraAngleY = cameraAngleY - mouseDelta. X * MOUSE_SENSITIVITY
	
	-- Clamp vertical angle
	cameraAngleX = math.clamp(cameraAngleX, -1. 4, 1.4)
	
	-- Rotate character to face camera direction (smoothly)
	local targetCFrame = CFrame.new(humanoidRootPart.Position) * CFrame. Angles(0, cameraAngleY, 0)
	humanoidRootPart.CFrame = humanoidRootPart.CFrame:Lerp(targetCFrame, 0.3)
	
	-- Calculate focus point (where camera looks at)
	local focusPoint = humanoidRootPart.Position + Vector3.new(0, CAMERA_HEIGHT_OFFSET, 0)
	
	-- Calculate camera position BEHIND and to the side of character
	local cameraCFrame = CFrame.new(humanoidRootPart.Position)
		* CFrame.Angles(0, cameraAngleY, 0) -- Rotate around character
		* CFrame.Angles(cameraAngleX, 0, 0) -- Vertical tilt
		* CFrame.new(CAMERA_OFFSET) -- Move camera back and to side
	
	-- Get the camera position from the CFrame
	local cameraPosition = cameraCFrame.Position
	
	-- Create final camera CFrame looking at focus point
	local finalCFrame = CFrame.new(cameraPosition, focusPoint)
	
	-- Smooth camera movement
	camera.CFrame = camera.CFrame:Lerp(finalCFrame, CAMERA_SMOOTHNESS)
	
	-- Set FOV
	camera.FieldOfView = COMBAT_FOV
	
	-- Keep camera type locked
	if camera.CameraType ~= Enum.CameraType.Scriptable then
		camera.CameraType = Enum.CameraType.Scriptable
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
	camera.CameraType = Enum.CameraType. Scriptable
	camera.CameraSubject = humanoid
	UserInputService.MouseBehavior = Enum.MouseBehavior. LockCenter
	UserInputService.MouseIconEnabled = false
end)

print("✓ ShiftLock Camera Loaded (Third Person)")