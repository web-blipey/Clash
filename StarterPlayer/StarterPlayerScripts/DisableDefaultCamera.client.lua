-- Place in StarterPlayer > StarterPlayerScripts

local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Just set camera settings, don't try to disable the module
player.CameraMaxZoomDistance = 128
player.CameraMinZoomDistance = 0.5
player.CameraMode = Enum.CameraMode. Classic

print("✓ Camera initialized for custom control")