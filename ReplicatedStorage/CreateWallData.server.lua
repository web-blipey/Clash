-- Select WallTemplate in ReplicatedStorage and run this in Command Bar:

local wallTemplate = game:GetService("ReplicatedStorage"):WaitForChild("WallTemplate")

local wallData = Instance.new("Folder")
wallData.Name = "WallData"
wallData. Parent = wallTemplate

local sizeX = Instance.new("IntValue")
sizeX.Name = "SizeX"
sizeX.Value = 2
sizeX.Parent = wallData

local sizeZ = Instance.new("IntValue")
sizeZ.Name = "SizeZ"
sizeZ.Value = 1
sizeZ.Parent = wallData

print("Wall Data Created!")