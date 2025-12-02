-- Place in StarterPlayer > StarterCharacterScripts
-- DELETE all other camera scripts (ShiftLockCamera, ForceThirdPerson, DisableDefaultCamera)

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
local CAMERA_DISTANCE = 8
local CAMERA_HEIGHT = 2
local CAMERA_SIDE_OFFSET = 2
local MOUSE_SENSITIVITY = 0.2
local FOV = 70

-- State
local cameraAngleX = 0
local cameraAngleY = 0

print("🎮 Custom Camera System Loading...")

-- STEP 1: Completely disable default controls
local controls = require(player.PlayerScripts:WaitForChild("PlayerModule")):GetControls()
controls:Disable()

-- STEP 2: Get camera module and disable it
local cameraModule = require(player.PlayerScripts:WaitForChild("PlayerModule")):GetCameras()
cameraModule:Disable()

print("✓ Default systems disabled")

-- STEP 3: Set up camera
camera.CameraType = Enum. CameraType.Scriptable
UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
UserInputService.MouseIconEnabled = false

-- Create crosshair
task.wait(0.5)
local playerGui = player:WaitForChild("PlayerGui")
local screenGui = playerGui:WaitForChild("BuildingUI")

local crosshair = Instance.new("ImageLabel")
crosshair.Name = "Crosshair"
crosshair.Size = UDim2. new(0, 20, 0, 20)
crosshair.Position = UDim2.new(0.5, -10, 0.5, -10)
crosshair.BackgroundTransparency = 1
crosshair.Image = "rbxasset://textures/ui/MouseLockedCursor.png"
crosshair. ImageColor3 = Color3.fromRGB(255, 255, 255)
crosshair.ImageTransparency = 0.3
crosshair.Parent = screenGui

print("✓ Camera locked and shift-lock enabled")

-- Movement state
local moveVector = Vector3.zero
local walkSpeed = 16
local runSpeed = 20
local isRunning = false

-- STEP 4: Handle movement input
local function updateMovementInput()
    moveVector = Vector3.zero
    
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then
        moveVector = moveVector + Vector3.new(0, 0, -1)
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then
        moveVector = moveVector + Vector3.new(0, 0, 1)
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then
        moveVector = moveVector + Vector3. new(-1, 0, 0)
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then
        moveVector = moveVector + Vector3.new(1, 0, 0)
    end
    
    if moveVector.Magnitude > 0 then
        moveVector = moveVector.Unit
    end
end

-- STEP 5: Update camera and character every frame
RunService.RenderStepped:Connect(function()
    if not character or not character. Parent then return end
    if not humanoidRootPart or not humanoidRootPart. Parent then return end
    if not humanoid or humanoid.Health <= 0 then return end
    
    -- Force camera settings
    camera.CameraType = Enum.CameraType.Scriptable
    UserInputService.MouseBehavior = Enum.MouseBehavior. LockCenter
    
    -- Get mouse movement
    local delta = UserInputService:GetMouseDelta()
    
    -- Update camera angles
    cameraAngleX = cameraAngleX - delta.Y * MOUSE_SENSITIVITY * 0.01
    cameraAngleY = cameraAngleY - delta.X * MOUSE_SENSITIVITY * 0.01
    cameraAngleX = math.clamp(cameraAngleX, -math.rad(80), math.rad(80))
    
    -- SHIFT LOCK: Rotate character to face camera direction
    humanoidRootPart.CFrame = CFrame.new(humanoidRootPart. Position) * CFrame. Angles(0, cameraAngleY, 0)
    
    -- Calculate camera position
    local camCFrame = CFrame.new(humanoidRootPart.Position)
        * CFrame.Angles(0, cameraAngleY, 0)
        * CFrame. Angles(cameraAngleX, 0, 0)
        * CFrame.new(CAMERA_SIDE_OFFSET, CAMERA_HEIGHT, CAMERA_DISTANCE)
    
    -- Point camera at character
    local focusPos = humanoidRootPart.Position + Vector3.new(0, 1. 5, 0)
    camera.CFrame = CFrame.new(camCFrame.Position, focusPos)
    camera. FieldOfView = FOV
    
    -- Handle movement
    updateMovementInput()
    
    if moveVector.Magnitude > 0 then
        -- Move relative to character facing direction (shift lock style)
        local moveDir = humanoidRootPart.CFrame:VectorToWorldSpace(moveVector)
        humanoid:Move(Vector3.new(moveDir.X, 0, moveDir.Z), false)
    else
        humanoid:Move(Vector3.zero, false)
    end
    
    -- Set walk speed
    humanoid.WalkSpeed = isRunning and runSpeed or walkSpeed
end)

-- STEP 6: Sprint input
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum. KeyCode.LeftShift then
        isRunning = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.LeftShift then
        isRunning = false
    end
end)

-- Handle respawn
player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoid = character:WaitForChild("Humanoid")
    humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    cameraAngleX = 0
    cameraAngleY = 0
    
    task.wait(0.1)
    camera.CameraType = Enum. CameraType. Scriptable
    UserInputService. MouseBehavior = Enum. MouseBehavior.LockCenter
    UserInputService.MouseIconEnabled = false
end)

print("✓ Custom Camera System Active!")
print("   - Shift lock: ALWAYS ON")
print("   - Camera distance:", CAMERA_DISTANCE)
print("   - Mouse: LOCKED")