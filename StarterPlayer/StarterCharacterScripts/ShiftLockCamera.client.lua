-- Place in StarterPlayer > StarterCharacterScripts

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ContextActionService = game:GetService("ContextActionService")

local player = Players.LocalPlayer
local character = script.Parent
local humanoid = character:WaitForChild("Humanoid")
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local camera = workspace.CurrentCamera

-- Camera Settings
local SHIFT_LOCK_ENABLED = true
local shiftLockActive = false

-- Shoulder Surf Settings (Elden Ring style)
local CAMERA_OFFSET = Vector3.new(2, 2, 8) -- Right shoulder offset (X, Y, Distance)
local CAMERA_HEIGHT_OFFSET = 1.5 -- Additional height above character
local CAMERA_SMOOTHNESS = 0.15 -- Lower = smoother, higher = snappier
local MOUSE_SENSITIVITY = 0.003

-- Combat Camera Settings
local COMBAT_FOV = 70 -- Field of view during combat
local NORMAL_FOV = 70
local LOCK_ON_FOV = 65 -- Slightly zoomed when locked on

-- Camera angles
local cameraAngleX = 0
local cameraAngleY = 0
local targetCameraOffset = CAMERA_OFFSET

-- Mouse lock
local mouseLocked = false

-- UI for shift lock indicator
local playerGui = player:WaitForChild("PlayerGui")
local screenGui = playerGui:WaitForChild("BuildingUI")

-- Create shift lock indicator
local shiftLockIndicator = Instance.new("ImageLabel")
shiftLockIndicator.Name = "ShiftLockIndicator"
shiftLockIndicator.Size = UDim2. new(0, 40, 0, 40)
shiftLockIndicator.Position = UDim2.new(0.5, -20, 0.9, -20)
shiftLockIndicator.BackgroundTransparency = 1
shiftLockIndicator.Image = "rbxasset://textures/ui/MouseLockedCursor.png" -- Default Roblox cursor
shiftLockIndicator.ImageTransparency = 1 -- Hidden by default
shiftLockIndicator.Parent = screenGui

-- Set camera to scriptable
camera.CameraType = Enum.CameraType. Scriptable

-- Disable default camera scripts
local function disableDefaultCamera()
	local cameraScript = player:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule"):WaitForChild("CameraModule")
	if cameraScript then
		-- Keep the module but we'll override its behavior
		print("Default camera module found")
	end
end

-- Toggle shift lock
local function toggleShiftLock()
	if not SHIFT_LOCK_ENABLED then return end
	
	shiftLockActive = not shiftLockActive
	
	if shiftLockActive then
		-- Enable shift lock
		UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
		shiftLockIndicator.ImageTransparency = 0
		mouseLocked = true
		print("Shift Lock: ON")
	else
		-- Disable shift lock
		UserInputService.MouseBehavior = Enum.MouseBehavior.Default
		shiftLockIndicator.ImageTransparency = 1
		mouseLocked = false
		print("Shift Lock: OFF")
	end
end

-- Update camera position and rotation
local function updateCamera()
	if not character or not humanoidRootPart or not humanoid or humanoid.Health <= 0 then
		return
	end
	
	-- Get mouse delta for camera rotation
	local mouseDelta = UserInputService:GetMouseDelta()
	
	if shiftLockActive then
		-- Rotate camera based on mouse movement
		cameraAngleX = cameraAngleX - mouseDelta.Y * MOUSE_SENSITIVITY
		cameraAngleY = cameraAngleY - mouseDelta. X * MOUSE_SENSITIVITY
		
		-- Clamp vertical angle (prevent camera from going too high/low)
		cameraAngleX = math.clamp(cameraAngleX, -1. 4, 1.4) -- ~80 degrees up/down
		
		-- Rotate character to face camera direction (only horizontal)
		humanoidRootPart.CFrame = CFrame.new(humanoidRootPart.Position) * CFrame.Angles(0, cameraAngleY, 0)
	end
	
	-- Calculate camera position (Elden Ring style over-the-shoulder)
	local rootPartCFrame = humanoidRootPart.CFrame
	
	-- Create offset based on camera angles
	local cameraCFrame = CFrame.new(humanoidRootPart.Position)
		* CFrame.Angles(0, cameraAngleY, 0) -- Horizontal rotation
		* CFrame. Angles(cameraAngleX, 0, 0) -- Vertical rotation
		* CFrame.new(targetCameraOffset) -- Apply offset
	
	-- Add height offset
	local heightOffset = Vector3.new(0, CAMERA_HEIGHT_OFFSET, 0)
	local focusPoint = humanoidRootPart.Position + heightOffset
	
	-- Smooth camera movement
	camera.CFrame = camera.CFrame:Lerp(cameraCFrame, CAMERA_SMOOTHNESS)
	
	-- Make camera look at focus point (slightly above character)
	camera.CFrame = CFrame.new(camera.CFrame.Position, focusPoint)
	
	-- Set FOV
	camera.FieldOfView = COMBAT_FOV
end

-- Handle input
local function onInputBegan(input, gameProcessed)
	if gameProcessed then return end
	
	-- Toggle shift lock with Shift key
	if input.KeyCode == Enum.KeyCode. LeftShift or input.KeyCode == Enum. KeyCode.RightShift then
		-- Check if player is also trying to sprint
		-- We'll use a different key for shift lock
	end
end

-- Bind shift lock to a specific action
ContextActionService:BindAction(
	"ToggleShiftLock",
	function(actionName, inputState, inputObject)
		if inputState == Enum.UserInputState.Begin then
			toggleShiftLock()
		end
	end,
	false, -- Don't create a touch button
	Enum.KeyCode. LeftControl -- Use Left Ctrl for shift lock (or change to your preference)
)

-- Alternative: Auto-enable shift lock on spawn
task.wait(0.5)
toggleShiftLock() -- Auto-enable shift lock

-- Update camera every frame
RunService.RenderStepped:Connect(updateCamera)

-- Handle character respawn
player.CharacterAdded:Connect(function(newCharacter)
	character = newCharacter
	humanoid = character:WaitForChild("Humanoid")
	humanoidRootPart = character:WaitForChild("HumanoidRootPart")
	
	cameraAngleX = 0
	cameraAngleY = 0
	
	-- Re-enable shift lock after respawn
	task.wait(0.5)
	if not shiftLockActive then
		toggleShiftLock()
	end
end)

print("ShiftLock Camera System Loaded!")
print("Press LEFT CTRL to toggle Shift Lock")