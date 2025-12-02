-- Place in StarterPlayer > StarterPlayerScripts

local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- IMPORTANT: Set these BEFORE trying to disable the default camera
player.CameraMaxZoomDistance = 128
player.CameraMinZoomDistance = 0.5
player.CameraMode = Enum. CameraMode.Classic

print("✓ Camera settings applied FIRST")

-- Now try to disable default camera module
task.wait(0.5)

local success, err = pcall(function()
	local playerModule = require(player:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule"))
	local cameraModule = playerModule:GetCameras()
	
	if cameraModule then
		print("Default camera module found - will be overridden by custom camera")
	end
end)

-- Force settings again after module loads
player.CameraMaxZoomDistance = 128
player.CameraMinZoomDistance = 0.5
player.CameraMode = Enum.CameraMode. Classic

print("✓ Camera overrides applied")
print("   Max Zoom:", player.CameraMaxZoomDistance)
print("   Min Zoom:", player.CameraMinZoomDistance)
print("   Camera Mode:", player.CameraMode)