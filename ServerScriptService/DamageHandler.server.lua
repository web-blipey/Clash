-- Place in ServerScriptService

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local DamageEvent = RemoteEvents:WaitForChild("DamagePlayer")

-- Handle damage requests
DamageEvent.OnServerEvent:Connect(function(player, targetCharacter, damage)
	if not targetCharacter or not targetCharacter:FindFirstChild("Humanoid") then
		return
	end
	
	local targetHumanoid = targetCharacter:FindFirstChild("Humanoid")
	local attackerCharacter = player.Character
	
	-- Verify attacker is alive
	if not attackerCharacter or not attackerCharacter:FindFirstChild("Humanoid") then
		return
	end
	
	local attackerHumanoid = attackerCharacter:FindFirstChild("Humanoid")
	if attackerHumanoid.Health <= 0 then
		return
	end
	
	-- Apply damage
	targetHumanoid:TakeDamage(damage)
	
	print(player.Name .. " dealt " .. damage .. " damage to " ..  targetCharacter.Name)
end)