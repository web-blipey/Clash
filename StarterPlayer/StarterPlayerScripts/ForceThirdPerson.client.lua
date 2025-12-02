-- Place in StarterPlayer > StarterPlayerScripts

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

print("🎮 Forcing Third Person Camera Settings...")

-- Function to force settings
local function forceSettings()
	player.CameraMaxZoomDistance = 128
	player.CameraMinZoomDistance = 0.5
	player.CameraMode = Enum.CameraMode.Classic
end

-- Force immediately
forceSettings()

-- Keep forcing every frame (aggressive!)
RunService.Heartbeat:Connect(function()
	if player.CameraMaxZoomDistance ~= 128 or 
	   player.CameraMinZoomDistance ~= 0. 5 or 
	   player.CameraMode ~= Enum.CameraMode.Classic then
		
		warn("⚠️ Camera settings were changed!  Forcing back to third person...")
		forceSettings()
	end
end)

print("✓ Camera settings locked to third person!")
print("   CameraMaxZoomDistance:", player.CameraMaxZoomDistance)
print("   CameraMinZoomDistance:", player.CameraMinZoomDistance)
print("   CameraMode:", player.CameraMode)