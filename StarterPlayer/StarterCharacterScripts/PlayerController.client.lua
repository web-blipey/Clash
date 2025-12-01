-- Place in StarterPlayer > StarterCharacterScripts

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local character = script.Parent
local humanoid = character:WaitForChild("Humanoid")
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- Player stats
local playerClass = "Bruiser" -- Default class
local maxHealth = 100
local currentHealth = maxHealth
local isAlive = true

-- Combat settings
local meleeDamage = 20
local meleeRange = 8
local attackCooldown = 1
local lastAttackTime = 0

-- Movement settings
local walkSpeed = 16
local runSpeed = 20
local isRunning = false

-- Set humanoid properties
humanoid.MaxHealth = maxHealth
humanoid. Health = maxHealth
humanoid. WalkSpeed = walkSpeed

-- UI
local playerGui = player:WaitForChild("PlayerGui")
local screenGui = playerGui:WaitForChild("BuildingUI")
local healthLabel = screenGui:WaitForChild("HealthLabel")
local classLabel = screenGui:WaitForChild("ClassLabel")

-- Remote Events
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local DamageEvent = RemoteEvents:WaitForChild("DamagePlayer")

-- Update UI
local function updateUI()
	healthLabel.Text = string.format("HP: %d/%d", math.floor(currentHealth), maxHealth)
	classLabel.Text = "Class: " .. playerClass
end

-- Melee attack function
local function performMeleeAttack()
	if tick() - lastAttackTime < attackCooldown then
		return
	end
	
	lastAttackTime = tick()
	
	-- Create attack animation (optional - add your animation here)
	print("Melee attack!")
	
	-- Detect hits in front of player
	local rayOrigin = humanoidRootPart.Position
	local rayDirection = humanoidRootPart.CFrame.LookVector * meleeRange
	
	local raycastParams = RaycastParams. new()
	raycastParams. FilterDescendantsInstances = {character}
	raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
	
	local rayResult = workspace:Raycast(rayOrigin, rayDirection, raycastParams)
	
	-- Also use region detection for better hit detection
	local region = Region3.new(
		humanoidRootPart.Position - Vector3.new(meleeRange/2, 3, meleeRange/2),
		humanoidRootPart. Position + humanoidRootPart.CFrame.LookVector * meleeRange + Vector3.new(meleeRange/2, 3, meleeRange/2)
	)
	
	local hitParts = workspace:FindPartsInRegion3(region, character, 100)
	
	for _, part in pairs(hitParts) do
		-- Check if hit another player
		local enemyHumanoid = part. Parent:FindFirstChild("Humanoid")
		if enemyHumanoid and enemyHumanoid ~= humanoid then
			-- Damage enemy (send to server)
			DamageEvent:FireServer(part.Parent, meleeDamage)
		end
		
		-- Check if hit a wall
		if part.Parent. Name:match("_Wall") then
			local wall = part.Parent
			if _G.DamageWall then
				_G.DamageWall(wall, meleeDamage, character)
			end
		end
	end
end

-- Input handling
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	
	-- Attack with left click or E key
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.KeyCode == Enum.KeyCode.E then
		-- Only attack if not in build mode
		local buildScript = character:FindFirstChild("BuildingSystem")
		if buildScript and not buildScript. buildModeActive then
			performMeleeAttack()
		end
	end
	
	-- Sprint with Shift
	if input.KeyCode == Enum.KeyCode. LeftShift then
		isRunning = true
		humanoid.WalkSpeed = runSpeed
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.KeyCode == Enum.KeyCode. LeftShift then
		isRunning = false
		humanoid.WalkSpeed = walkSpeed
	end
end)

-- Handle death
humanoid.Died:Connect(function()
	isAlive = false
	currentHealth = 0
	updateUI()
end)

-- Handle respawn
player.CharacterAdded:Connect(function(newCharacter)
	character = newCharacter
	humanoid = character:WaitForChild("Humanoid")
	humanoidRootPart = character:WaitForChild("HumanoidRootPart")
	
	currentHealth = maxHealth
	isAlive = true
	
	humanoid.MaxHealth = maxHealth
	humanoid.Health = maxHealth
	
	updateUI()
end)

-- Update UI initially
updateUI()

-- Health monitoring
humanoid. HealthChanged:Connect(function(health)
	currentHealth = health
	updateUI()
end)