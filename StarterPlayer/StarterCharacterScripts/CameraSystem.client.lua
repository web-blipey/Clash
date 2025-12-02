--[[
    DROP-IN SHOULDER CAMERA SYSTEM
    - Shift lock always enabled
    - Over-the-shoulder third person view
    - Mouse locked to center
    - Character faces camera direction
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local character = script.Parent
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")
local camera = workspace.CurrentCamera

-- Settings (adjust these to your preference)
local CAMERA_DISTANCE = 8
local CAMERA_HEIGHT = 2
local CAMERA_SIDE = 2
local MOUSE_SPEED = 0.005
local MIN_PITCH = math.rad(-80)
local MAX_PITCH = math.rad(80)

-- State
local angleX = 0
local angleY = 0
local running = false

print("Camera System Loading...")

-- Disable default camera
task.spawn(function()
    wait(0.1)
    local ok, module = pcall(function()
        return require(player.PlayerScripts:WaitForChild("PlayerModule"))
    end)
    if ok then
        module:GetCameras():Disable()
        print("Default camera disabled")
    end
end)

-- Force camera settings
camera.CameraType = Enum. CameraType.Scriptable
camera.CameraSubject = humanoid
UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
UserInputService.MouseIconEnabled = false

-- Update function
local function update()
    if not character. Parent then return end
    if not rootPart. Parent then return end
    if humanoid.Health <= 0 then return end
    
    -- Force settings every frame
    camera.CameraType = Enum. CameraType.Scriptable
    UserInputService.MouseBehavior = Enum.MouseBehavior. LockCenter
    
    -- Get mouse movement
    local delta = UserInputService:GetMouseDelta()
    angleX = angleX - (delta.X * MOUSE_SPEED)
    angleY = math.clamp(angleY - (delta.Y * MOUSE_SPEED), MIN_PITCH, MAX_PITCH)
    
    -- Rotate character to face camera (SHIFT LOCK)
    local faceCFrame = CFrame.new(rootPart.Position) * CFrame.Angles(0, angleX, 0)
    rootPart.CFrame = CFrame.new(rootPart. Position, rootPart.Position + faceCFrame.LookVector)
    
    -- Calculate camera position
    local offset = CFrame.new(rootPart. Position)
        * CFrame.Angles(0, angleX, 0)
        * CFrame. Angles(angleY, 0, 0)
        * CFrame.new(CAMERA_SIDE, CAMERA_HEIGHT, CAMERA_DISTANCE)
    
    local camPos = offset.Position
    local lookAt = rootPart.Position + Vector3.new(0, 1. 5, 0)
    
    -- Set camera
    camera.CFrame = CFrame.new(camPos, lookAt)
    camera.FieldOfView = 70
end

-- Connect to render
RunService.RenderStepped:Connect(update)

-- Create crosshair
wait(0.5)
local gui = player. PlayerGui:FindFirstChildOfClass("ScreenGui")
if not gui then
    gui = Instance. new("ScreenGui")
    gui.ResetOnSpawn = false
    gui.Parent = player.PlayerGui
end

local cross = Instance.new("Frame")
cross.Name = "Crosshair"
cross.AnchorPoint = Vector2.new(0.5, 0. 5)
cross.Position = UDim2.new(0. 5, 0, 0. 5, 0)
cross. Size = UDim2.new(0, 4, 0, 4)
cross.BackgroundColor3 = Color3.new(1, 1, 1)
cross.BorderSizePixel = 0
cross.Parent = gui

local h = Instance.new("Frame")
h.AnchorPoint = Vector2.new(0.5, 0. 5)
h.Position = UDim2.new(0. 5, 0, 0. 5, 0)
h. Size = UDim2.new(0, 20, 0, 2)
h.BackgroundColor3 = Color3.new(1, 1, 1)
h.BorderSizePixel = 0
h.Parent = cross

local v = Instance.new("Frame")
v.AnchorPoint = Vector2.new(0.5, 0.5)
v. Position = UDim2.new(0.5, 0, 0.5, 0)
v.Size = UDim2.new(0, 2, 0, 20)
v.BackgroundColor3 = Color3.new(1, 1, 1)
v. BorderSizePixel = 0
v.Parent = cross

print("✓ Camera System Active!")
print("✓ Shift Lock: ON")
print("✓ Mouse: LOCKED")