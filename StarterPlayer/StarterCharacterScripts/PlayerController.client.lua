-- Place in StarterPlayer > StarterCharacterScripts

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = script.Parent
local humanoid = character:WaitForChild("Humanoid")
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local camera = workspace.CurrentCamera

-- DISABLE DEFAULT MOVEMENT
local PlayerModule
pcall(function()
	PlayerModule = require(player:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule"))
	local ControlModule = PlayerModule:GetControls()
	if ControlModule then
		ControlModule:Disable() -- Disable default WASD controls
		print("✓ Default controls disabled")
	end
end)

-- Player stats
local playerClass = "Bruiser"
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
humanoid.WalkSpeed = walkSpeed

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
	
	print("⚔️ Melee attack!")
	
	-- Attack in the direction the character is facing
	local attackDirection = humanoidRootPart.CFrame.LookVector
	local rayOrigin = humanoidRootPart.Position + Vector3.new(0, 2, 0)
	local rayDirection = attackDirection * meleeRange
	
	local raycastParams = RaycastParams. new()
	raycastParams. FilterDescendantsInstances = {character}
	raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
	
	local rayResult = workspace:Raycast(rayOrigin, rayDirection, raycastParams)
	
	-- Sphere detection for better hit detection
	local attackPosition = humanoidRootPart.Position + attackDirection * (meleeRange / 2)
	local hitParts = workspace:GetPartBoundsInRadius(attackPosition, meleeRange / 2)
	
	local hitSomething = false
	
	for _, part in pairs(hitParts) do
		if part:IsDescendantOf(character) then continue end
		
		-- Check if hit another player
		local enemyCharacter = part:FindFirstAncestorOfClass("Model")
		if enemyCharacter and enemyCharacter:FindFirstChild("Humanoid") then
			local enemyHumanoid = enemyCharacter:FindFirstChild("Humanoid")
			if enemyHumanoid and enemyHumanoid ~= humanoid then
				DamageEvent:FireServer(enemyCharacter, meleeDamage)
				hitSomething = true
				print("✓ Hit player: " .. enemyCharacter. Name)
			end
		end
		
		-- Check if hit a wall
		if part.Parent and part.Parent. Name:match("_Wall") then
			local wall = part.Parent
			local DamageWallEvent = RemoteEvents:FindFirstChild("DamageWall")
			if DamageWallEvent then
				DamageWallEvent:FireServer(wall, meleeDamage)
				hitSomething = true
				print("✓ Hit wall!")
			end
		end
	end
end

-- Custom movement handler (camera-relative)
local function handleMovement(deltaTime)
	if not isAlive then return end
	
	-- Get input
	local moveDirection = Vector3.new()
	
	if UserInputService:IsKeyDown(Enum.KeyCode. W) then
		moveDirection = moveDirection + Vector3.new(0, 0, -1)
	end
	if UserInputService:IsKeyDown(Enum. KeyCode.S) then
		moveDirection = moveDirection + Vector3.new(0, 0, 1)
	end
	if UserInputService:IsKeyDown(Enum.KeyCode.A) then
		moveDirection = moveDirection + Vector3.new(-1, 0, 0)
	end
	if UserInputService:IsKeyDown(Enum. KeyCode.D) then
		moveDirection = moveDirection + Vector3.new(1, 0, 0)
	end
	
	-- If there's input, move the character
	if moveDirection. Magnitude > 0 then
		moveDirection = moveDirection.Unit
		
		-- Get camera direction (for camera-relative movement)
		local cameraCFrame = camera.CFrame
		local cameraLook = cameraCFrame.LookVector
		local cameraRight = cameraCFrame.RightVector
		
		-- Flatten to horizontal plane
		cameraLook = Vector3.new(cameraLook.X, 0, cameraLook.Z). Unit
		cameraRight = Vector3.new(cameraRight. X, 0, cameraRight.Z).Unit
		
		-- Calculate world movement direction
		local worldDirection = (cameraLook * -moveDirection. Z) + (cameraRight * moveDirection.X)
		
		-- Move humanoid
		humanoid:Move(worldDirection, false)
	end
end

-- Input handling
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	
	-- Attack
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.KeyCode == Enum. KeyCode.E then
		if not _G.BuildModeActive then
			performMeleeAttack()
		end
	end
	
	-- Sprint
	if input.KeyCode == Enum.KeyCode.LeftShift then
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

-- Initialize
updateUI()

-- Health monitoring
humanoid. HealthChanged:Connect(function(health)
	currentHealth = health
	updateUI()
end)

-- Update movement every frame
RunService.Heartbeat:Connect(handleMovement)

print("✓ PlayerController loaded!")