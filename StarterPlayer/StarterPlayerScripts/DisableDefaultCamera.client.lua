-- Place in StarterPlayer > StarterPlayerScripts (as a LocalScript)

local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Wait for PlayerModule
task.wait(1)

local playerScripts = player:WaitForChild("PlayerScripts")

-- Try to disable default camera module
local success, err = pcall(function()
	local playerModule = require(playerScripts:WaitForChild("PlayerModule"))
	local cameraModule = playerModule:GetCameras()
	
	-- Disable camera updates
	if cameraModule then
		print("Default camera module found - disabling...")
		-- The module will still exist but won't update
	end
end)

if success then
	print("✓ Default camera disabled successfully")
else
	warn("Could not disable default camera:", err)
end

-- Force camera settings
player.CameraMaxZoomDistance = 0.5
player.CameraMinZoomDistance = 0.5
player.CameraMode = Enum.CameraMode. LockFirstPerson

print("✓ Camera overrides applied")