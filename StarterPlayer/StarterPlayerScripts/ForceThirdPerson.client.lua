-- Place in StarterPlayer > StarterPlayerScripts

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

print("🎮 Setting up Third Person Camera...")

-- Set camera zoom settings to allow third person
player.CameraMaxZoomDistance = 128
player.CameraMinZoomDistance = 0.5

-- IMPORTANT: Use Classic mode so our script can take over
player.CameraMode = Enum.CameraMode.Classic

-- Lock these settings every frame
RunService.Heartbeat:Connect(function()
	-- Only fix if they're wrong
	if player.CameraMaxZoomDistance ~= 128 then
		player.CameraMaxZoomDistance = 128
	end
	
	if player.CameraMinZoomDistance ~= 0.5 then
		player.CameraMinZoomDistance = 0. 5
	end
	
	if player.CameraMode ~= Enum.CameraMode.Classic then
		player.CameraMode = Enum.CameraMode.Classic
	end
end)

print("✓ Camera settings locked!")