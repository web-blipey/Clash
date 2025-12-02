--[[
    DEBUGGED CAMERA SYSTEM
    Every step is logged to Output window
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

print("========================================")
print("🎥 CAMERA SYSTEM STARTING")
print("========================================")

local player = Players.LocalPlayer
print("✓ Player found:", player. Name)

local character = script.Parent
print("✓ Character found:", character.Name)

local humanoid = character:WaitForChild("Humanoid")
print("✓ Humanoid found")

local rootPart = character:WaitForChild("HumanoidRootPart")
print("✓ RootPart found")

local camera = workspace.CurrentCamera
print("✓ Camera reference obtained")

-- Settings
local CAMERA_DISTANCE = 8
local CAMERA_HEIGHT = 2
local CAMERA_SIDE = 2
local MOUSE_SPEED = 0. 005
local MIN_PITCH = math.rad(-80)
local MAX_PITCH = math.rad(80)

print("✓ Settings configured")

-- State
local angleX = 0
local angleY = 0
local updateCount = 0
local mouseMovementDetected = false

print("✓ State variables initialized")

-- Disable default camera
print("🔧 Attempting to disable default camera...")
task.spawn(function()
    wait(0.1)
    local success, result = pcall(function()
        local PlayerModule = require(player. PlayerScripts:WaitForChild("PlayerModule"))
        print("  - PlayerModule loaded")
        
        local CameraModule = PlayerModule:GetCameras()
        print("  - CameraModule obtained")
        
        CameraModule:Disable()
        print("  - CameraModule disabled")
        
        local ControlModule = PlayerModule:GetControls()
        print("  - ControlModule obtained")
        
        ControlModule:Disable()
        print("  - ControlModule disabled")
    end)
    
    if success then
        print("✅ DEFAULT CAMERA DISABLED SUCCESSFULLY")
    else
        warn("⚠️ Failed to disable default camera:", result)
    end
end)

-- Force camera settings
print("🔧 Setting camera type to Scriptable...")
camera.CameraType = Enum.CameraType.Scriptable
print("✓ Camera type set:", camera.CameraType)

print("🔧 Setting camera subject...")
camera.CameraSubject = humanoid
print("✓ Camera subject set:", camera.CameraSubject)

print("🔧 Locking mouse to center...")
UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
print("✓ Mouse behavior set:", UserInputService.MouseBehavior)

print("🔧 Hiding mouse icon...")
UserInputService.MouseIconEnabled = false
print("✓ Mouse icon enabled:", UserInputService.MouseIconEnabled)

-- Update function
local function update()
    updateCount = updateCount + 1
    
    -- Debug every 60 frames (once per second at 60fps)
    if updateCount % 60 == 0 then
        print("📊 UPDATE #" .. updateCount)
        print("  Camera Type:", camera.CameraType)
        print("  Mouse Behavior:", UserInputService.MouseBehavior)
        print("  Mouse Icon Enabled:", UserInputService.MouseIconEnabled)
        print("  Angle X:", math.deg(angleX), "degrees")
        print("  Angle Y:", math.deg(angleY), "degrees")
        print("  Mouse Movement Detected:", mouseMovementDetected)
    end
    
    if not character. Parent then
        warn("⚠️ Character has no parent!")
        return
    end
    
    if not rootPart. Parent then
        warn("⚠️ RootPart has no parent!")
        return
    end
    
    if humanoid.Health <= 0 then
        warn("⚠️ Humanoid is dead!")
        return
    end
    
    -- Check if camera type changed
    if camera.CameraType ~= Enum.CameraType.Scriptable then
        warn("⚠️ Camera type changed!  Forcing back to Scriptable...")
        camera.CameraType = Enum. CameraType.Scriptable
    end
    
    -- Check if mouse behavior changed
    if UserInputService.MouseBehavior ~= Enum.MouseBehavior.LockCenter then
        warn("⚠️ Mouse behavior changed! Forcing back to LockCenter...")
        UserInputService. MouseBehavior = Enum. MouseBehavior.LockCenter
    end
    
    -- Get mouse movement
    local delta = UserInputService:GetMouseDelta()
    
    if delta. Magnitude > 0 then
        if not mouseMovementDetected then
            print("🎯 MOUSE MOVEMENT DETECTED!")
            print("  Delta X:", delta.X)
            print("  Delta Y:", delta.Y)
            mouseMovementDetected = true
        end
    end
    
    -- Update angles
    local oldX = angleX
    local oldY = angleY
    
    angleX = angleX - (delta.X * MOUSE_SPEED)
    angleY = math.clamp(angleY - (delta. Y * MOUSE_SPEED), MIN_PITCH, MAX_PITCH)
    
    if math.abs(angleX - oldX) > 0.001 or math.abs(angleY - oldY) > 0.001 then
        if updateCount % 60 == 0 then
            print("  Angle changed!  X:", math.deg(angleX), "Y:", math.deg(angleY))
        end
    end
    
    -- Rotate character to face camera (SHIFT LOCK)
    local faceCFrame = CFrame.new(rootPart. Position) * CFrame.Angles(0, angleX, 0)
    rootPart.CFrame = CFrame.new(rootPart. Position, rootPart.Position + faceCFrame.LookVector)
    
    -- Calculate camera position
    local offset = CFrame.new(rootPart. Position)
        * CFrame. Angles(0, angleX, 0)
        * CFrame. Angles(angleY, 0, 0)
        * CFrame.new(CAMERA_SIDE, CAMERA_HEIGHT, CAMERA_DISTANCE)
    
    local camPos = offset.Position
    local lookAt = rootPart.Position + Vector3.new(0, 1. 5, 0)
    
    -- Calculate distance from camera to character
    local distance = (camPos - rootPart.Position).Magnitude
    
    if updateCount % 60 == 0 then
        print("  Camera distance from character:", math.floor(distance * 100) / 100)
    end
    
    -- Set camera
    camera.CFrame = CFrame.new(camPos, lookAt)
    camera. FieldOfView = 70
end

print("🔧 Connecting update function to RenderStepped...")
local connection = RunService.RenderStepped:Connect(update)
print("✓ Connected to RenderStepped")

-- Create crosshair
print("🔧 Creating crosshair...")
wait(0.5)
local gui = player. PlayerGui:FindFirstChildOfClass("ScreenGui")
if not gui then
    print("  - Creating new ScreenGui")
    gui = Instance.new("ScreenGui")
    gui.ResetOnSpawn = false
    gui.Parent = player.PlayerGui
else
    print("  - Using existing ScreenGui:", gui.Name)
end

local cross = Instance.new("Frame")
cross.Name = "Crosshair"
cross.AnchorPoint = Vector2.new(0.5, 0. 5)
cross.Position = UDim2.new(0. 5, 0, 0. 5, 0)
cross. Size = UDim2.new(0, 4, 0, 4)
cross.BackgroundColor3 = Color3. new(1, 1, 1)
cross.BorderSizePixel = 0
cross. Parent = gui

local h = Instance.new("Frame")
h. AnchorPoint = Vector2. new(0.5, 0.5)
h.Position = UDim2.new(0.5, 0, 0.5, 0)
h.Size = UDim2. new(0, 20, 0, 2)
h. BackgroundColor3 = Color3.new(1, 1, 1)
h.BorderSizePixel = 0
h.Parent = cross

local v = Instance.new("Frame")
v.AnchorPoint = Vector2.new(0.5, 0.5)
v.Position = UDim2.new(0.5, 0, 0.5, 0)
v.Size = UDim2.new(0, 2, 0, 20)
v.BackgroundColor3 = Color3.new(1, 1, 1)
v.BorderSizePixel = 0
v.Parent = cross

print("✓ Crosshair created")

-- Monitor input every second
task.spawn(function()
    while true do
        wait(3)
        print("🔍 INPUT CHECK:")
        print("  MouseBehavior:", UserInputService.MouseBehavior)
        print("  MouseIconEnabled:", UserInputService.MouseIconEnabled)
        print("  MouseDeltaEnabled:", UserInputService.MouseDeltaSensitivity)
        
        local delta = UserInputService:GetMouseDelta()
        print("  Current MouseDelta:", delta)
        
        if delta.Magnitude > 0 then
            print("  ✅ Mouse is moving!")
        else
            print("  ❌ Mouse is NOT moving")
        end
    end
end)

print("========================================")
print("✅ CAMERA SYSTEM FULLY LOADED")
print("========================================")
print("If you see this message, the script loaded successfully!")
print("Watch for mouse movement detection above.")
print("Try moving your mouse now!")