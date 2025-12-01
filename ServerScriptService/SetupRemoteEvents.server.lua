-- Place in ServerScriptService (Run once to create remote events)

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Create RemoteEvents folder
local remoteEventsFolder = ReplicatedStorage:FindFirstChild("RemoteEvents")
if not remoteEventsFolder then
	remoteEventsFolder = Instance.new("Folder")
	remoteEventsFolder.Name = "RemoteEvents"
	remoteEventsFolder.Parent = ReplicatedStorage
end

-- Create PlaceWall event
if not remoteEventsFolder:FindFirstChild("PlaceWall") then
	local placeWall = Instance.new("RemoteEvent")
	placeWall. Name = "PlaceWall"
	placeWall.Parent = remoteEventsFolder
end

-- Create DestroyWall event
if not remoteEventsFolder:FindFirstChild("DestroyWall") then
	local destroyWall = Instance.new("RemoteEvent")
	destroyWall. Name = "DestroyWall"
	destroyWall. Parent = remoteEventsFolder
end

-- Create DamagePlayer event
if not remoteEventsFolder:FindFirstChild("DamagePlayer") then
	local damagePlayer = Instance.new("RemoteEvent")
	damagePlayer.Name = "DamagePlayer"
	damagePlayer.Parent = remoteEventsFolder
end

print("Remote Events Created!")