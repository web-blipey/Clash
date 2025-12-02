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

-- Melee attack
local function performMeleeAttack()
	if tick() - lastAttackTime < attackCooldown then return end
	
	lastAttackTime = tick()
	print("⚔️ Attack!")
	
	local attackDirection = humanoidRootPart.CFrame.LookVector
	local attackPosition = humanoidRootPart. Position + attackDirection * (meleeRange / 2)
	local hitParts = workspace:GetPartBoundsInRadius(attackPosition, meleeRange / 2)
	
	for _, part in pairs(hitParts) do
		if part:IsDescendantOf(character) then continue end
		
		-- Hit player
		local enemyCharacter = part:FindFirstAncestorOfClass("Model")
		if enemyCharacter and enemyCharacter:FindFirstChild("Humanoid") then
			local enemyHumanoid = enemyCharacter:FindFirstChild("Humanoid")
			if enemyHumanoid and enemyHumanoid ~= humanoid then
				DamageEvent:FireServer(enemyCharacter, meleeDamage)
				print("✓ Hit player!")
			end
		end
		
		-- Hit wall
		if part.Parent and part.Parent. Name:match("_Wall") then
			local DamageWallEvent = RemoteEvents:FindFirstChild("DamageWall")
			if DamageWallEvent then
				DamageWallEvent:FireServer(part.Parent, meleeDamage)
				print("✓ Hit wall!")
			end
		end
	end
end

-- Movement handler (camera-relative with shift lock)
local function handleMovement()
	if not isAlive then return end
	
	local moveVector = Vector3.zero
	
	-- Get WASD input
	if UserInputService:IsKeyDown(Enum. KeyCode.W) then
		moveVector = moveVector + Vector3.new(0, 0, -1)
	end
	if UserInputService:IsKeyDown(Enum.KeyCode.S) then
		moveVector = moveVector + Vector3.new(0, 0, 1)
	end
	if UserInputService:IsKeyDown(Enum.KeyCode.A) then
		moveVector = moveVector + Vector3. new(-1, 0, 0)
	end
	if UserInputService:IsKeyDown(Enum.KeyCode.D) then
		moveVector = moveVector + Vector3.new(1, 0, 0)
	end
	
	-- If moving
	if moveVector.Magnitude > 0 then
		moveVector = moveVector.Unit
		
		-- With shift lock, character faces camera direction
		-- So we move relative to the character's facing direction
		local characterLookVector = humanoidRootPart.CFrame.LookVector
		local characterRightVector = humanoidRootPart.CFrame.RightVector
		
		-- Flatten to horizontal plane
		characterLookVector = Vector3.new(characterLookVector.X, 0, characterLookVector.Z). Unit
		characterRightVector = Vector3.new(characterRightVector.X, 0, characterRightVector.Z).Unit
		
		-- Calculate movement direction
		local moveDirection = (characterLookVector * -moveVector.Z) + (characterRightVector * moveVector.X)
		
		-- Move the humanoid
		humanoid:Move(moveDirection, false)
	else
		-- Stop when no input
		humanoid:Move(Vector3.zero, false)
	end
end

-- Input handling
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	
	-- Attack
	if input.UserInputType == Enum.UserInputType. MouseButton1 or input.KeyCode == Enum. KeyCode.E then
		if not _G.BuildModeActive then
			performMeleeAttack()
		end
	end
	
	-- Sprint
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

-- Death/Respawn
humanoid. Died:Connect(function()
	isAlive = false
	currentHealth = 0
	updateUI()
end)

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

updateUI()
humanoid. HealthChanged:Connect(function(health)
	currentHealth = health
	updateUI()
end)

-- Update movement every frame
RunService.Heartbeat:Connect(handleMovement)

print("✓ PlayerController loaded!")