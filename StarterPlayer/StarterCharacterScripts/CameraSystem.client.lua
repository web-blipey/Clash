-- Place in StarterPlayer > StarterCharacterScripts

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()
local character = script.Parent
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

local camera = workspace.CurrentCamera
camera.CameraSubject = humanoid

-- Camera settings
local X_SENSITIVITY = 0.5
local Y_SENSITIVITY = 0.5
local CAMERA_OFFSET = Vector3.new(2, 2, 8)
local MIN_Y = math.rad(-80)
local MAX_Y = math.rad(80)

-- State
local rotX = 0
local rotY = 0
local cameraConnection

print("🎥 Camera System Starting...")

-- Disable default camera
task.spawn(function()
    task.wait(0.1)
    
    local PlayerModule = player. PlayerScripts:WaitForChild("PlayerModule")
    
    -- Get camera module
    local CameraModule = require(PlayerModule:WaitForChild("CameraModule"))
    local CameraScript = CameraModule.new()
    
    -- Disconnect all camera connections
    if CameraScript then
        CameraScript:Disable()
    end
    
    print("✓ Default camera disabled")
end)

-- FORCE camera to scriptable
camera.CameraType = Enum. CameraType.Scriptable

-- Lock cursor
UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
UserInputService.MouseIconEnabled = false

-- Unbind default camera rotation
ContextActionService:UnbindAction("CameraMovement")

-- Create our camera update function
local function updateCamera()
    if not character or not character.Parent then return end
    if not rootPart or not rootPart. Parent then return end
    
    -- Keep camera scriptable
    if camera.CameraType ~= Enum.CameraType. Scriptable then
        camera. CameraType = Enum.CameraType.Scriptable
    end
    
    -- Keep mouse locked
    if UserInputService. MouseBehavior ~= Enum.MouseBehavior.LockCenter then
        UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
    end
    
    -- Get mouse movement
    local delta = UserInputService:GetMouseDelta()
    
    -- Update rotation
    rotX = rotX - delta.X * X_SENSITIVITY * 0.01
    rotY = math.clamp(rotY - delta.Y * Y_SENSITIVITY * 0.01, MIN_Y, MAX_Y)
    
    -- SHIFT LOCK: Rotate character to match camera
    local charCFrame = CFrame.new(rootPart. Position) * CFrame.Angles(0, rotX, 0)
    rootPart.CFrame = CFrame.new(rootPart.Position, rootPart.Position + charCFrame.LookVector)
    
    -- Calculate camera position
    local cameraCFrame = CFrame.new(rootPart.Position)
        * CFrame.Angles(0, rotX, 0)
        * CFrame. Angles(rotY, 0, 0)
        * CFrame.new(CAMERA_OFFSET)
    
    local cameraPosition = cameraCFrame. Position
    local focusPosition = rootPart.Position + Vector3.new(0, 1. 5, 0)
    
    -- Set camera
    camera.CFrame = CFrame.new(cameraPosition, focusPosition)
    camera. FieldOfView = 70
end

-- Connect update to RenderStepped
cameraConnection = RunService.RenderStepped:Connect(updateCamera)

-- Create crosshair
task.wait(0.5)
local playerGui = player:WaitForChild("PlayerGui")
local screenGui = playerGui:FindFirstChild("BuildingUI") or playerGui:FindFirstChildOfClass("ScreenGui")

if screenGui then
    local crosshair = Instance.new("Frame")
    crosshair.Name = "Crosshair"
    crosshair.AnchorPoint = Vector2.new(0.5, 0. 5)
    crosshair. Position = UDim2.new(0.5, 0, 0.5, 0)
    crosshair.Size = UDim2.new(0, 4, 0, 4)
    crosshair. BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    crosshair.BorderSizePixel = 0
    crosshair.Parent = screenGui
    
    local horizontal = Instance.new("Frame")
    horizontal.AnchorPoint = Vector2.new(0.5, 0.5)
    horizontal.Position = UDim2.new(0. 5, 0, 0. 5, 0)
    horizontal.Size = UDim2. new(0, 20, 0, 2)
    horizontal.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    horizontal.BorderSizePixel = 0
    horizontal.Parent = crosshair
    
    local vertical = Instance.new("Frame")
    vertical.AnchorPoint = Vector2.new(0. 5, 0.5)
    vertical.Position = UDim2.new(0.5, 0, 0.5, 0)
    vertical.Size = UDim2.new(0, 2, 0, 20)
    vertical.BackgroundColor3 = Color3. fromRGB(255, 255, 255)
    vertical. BorderSizePixel = 0
    vertical.Parent = crosshair
end

-- Handle respawn
player.CharacterAdded:Connect(function(newChar)
    if cameraConnection then
        cameraConnection:Disconnect()
    end
    
    character = newChar
    humanoid = character:WaitForChild("Humanoid")
    rootPart = character:WaitForChild("HumanoidRootPart")
    
    rotX = 0
    rotY = 0
    
    task.wait(0.1)
    
    camera.CameraType = Enum.CameraType.Scriptable
    camera.CameraSubject = humanoid
    UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
    UserInputService.MouseIconEnabled = false
    
    cameraConnection = RunService.RenderStepped:Connect(updateCamera)
end)

-- Cleanup
character. AncestryChanged:Connect(function()
    if not character.Parent and cameraConnection then
        cameraConnection:Disconnect()
    end
end)

print("✓ Camera System Active!")
print("✓ Shift Lock: ENABLED")
print("✓ Mouse: LOCKED")
print("✓ Camera Distance:", CAMERA_OFFSET.Z)