-- Place in StarterGui as a LocalScript

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Create ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BuildingUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Wall Count Label
local wallCountLabel = Instance.new("TextLabel")
wallCountLabel.Name = "WallCountLabel"
wallCountLabel. Size = UDim2.new(0, 200, 0, 50)
wallCountLabel.Position = UDim2. new(0, 10, 0, 10)
wallCountLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
wallCountLabel.BackgroundTransparency = 0.5
wallCountLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
wallCountLabel. TextScaled = true
wallCountLabel.Font = Enum.Font.GothamBold
wallCountLabel.Text = "Walls: 3/3"
wallCountLabel. Parent = screenGui

-- Health Label
local healthLabel = Instance. new("TextLabel")
healthLabel.Name = "HealthLabel"
healthLabel.Size = UDim2.new(0, 200, 0, 50)
healthLabel.Position = UDim2.new(0, 10, 0, 70)
healthLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
healthLabel.BackgroundTransparency = 0.5
healthLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
healthLabel. TextScaled = true
healthLabel.Font = Enum.Font. GothamBold
healthLabel.Text = "HP: 100/100"
healthLabel.Parent = screenGui

-- Class Label
local classLabel = Instance.new("TextLabel")
classLabel.Name = "ClassLabel"
classLabel.Size = UDim2. new(0, 200, 0, 50)
classLabel.Position = UDim2. new(0, 10, 0, 130)
classLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
classLabel.BackgroundTransparency = 0.5
classLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
classLabel.TextScaled = true
classLabel.Font = Enum.Font.GothamBold
classLabel.Text = "Class: Bruiser"
classLabel.Parent = screenGui

-- Controls Label
local controlsLabel = Instance. new("TextLabel")
controlsLabel.Name = "ControlsLabel"
controlsLabel.Size = UDim2.new(0, 300, 0, 150)
controlsLabel.Position = UDim2.new(1, -310, 1, -160)
controlsLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
controlsLabel. BackgroundTransparency = 0.7
controlsLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
controlsLabel.TextSize = 14
controlsLabel. Font = Enum.Font. Gotham
controlsLabel.Text = [[
CONTROLS:
B - Toggle Build Mode
R - Rotate Wall
Left Click - Place Wall / Attack
E - Attack
Shift - Sprint
]]
controlsLabel.TextXAlignment = Enum.TextXAlignment.Left
controlsLabel.Parent = screenGui

print("UI Setup Complete!")