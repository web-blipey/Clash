-- Place in StarterPlayer > StarterCharacterScripts
-- UPDATED VERSION with camera-relative movement

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
humanoid.Health = maxHealth
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
	
	-- Create attack animation (optional - add your animation here)
	print("Melee attack!")
	
	-- Attack in the direction the character is facing (camera direction with shift lock)
	local attackDirection = humanoidRootPart.CFrame.LookVector
	local rayOrigin = humanoidRootPart.Position + Vector3.new(0, 2, 0) -- Chest height
	local rayDirection = attackDirection * meleeRange
	
	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = {character}
	raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
	
	-- Perform raycast
	local rayResult = workspace:Raycast(rayOrigin, rayDirection, raycastParams)
	
	-- Also use sphere detection for better hit detection
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
				-- Damage enemy (send to server)
				DamageEvent:FireServer(enemyCharacter, meleeDamage)
				hitSomething = true
				print("Hit player: " .. enemyCharacter.Name)
			end
		end
		
		-- Check if hit a wall
		if part.Parent and part.Parent. Name:match("_Wall") then
			local wall = part.Parent
			-- Use remote event to damage wall on server
			local DamageWallEvent = RemoteEvents:FindFirstChild("DamageWall")
			if DamageWallEvent then
				DamageWallEvent:FireServer(wall, meleeDamage)
				hitSomething = true
				print("Hit wall!")
			end
		end
	end
	
	if hitSomething then
		-- Optional: Add hit effect, sound, etc.
	end
end

-- Handle movement (camera-relative with WASD)
local function handleMovement()
	-- Get input
	local moveVector = Vector3.new()
	
	if UserInputService:IsKeyDown(Enum.KeyCode. W) then
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
	
	-- Normalize movement
	if moveVector.Magnitude > 0 then
		moveVector = moveVector. Unit
		
		-- Convert to camera-relative movement
		local cameraCFrame = camera.CFrame
		local cameraDirection = cameraCFrame.LookVector
		local cameraRight = cameraCFrame.RightVector
		
		-- Remove Y component for flat movement
		cameraDirection = Vector3.new(cameraDirection. X, 0, cameraDirection.Z). Unit
		cameraRight = Vector3.new(cameraRight.X, 0, cameraRight.Z).Unit
		
		-- Calculate world-space movement direction
		local worldMoveDirection = (cameraDirection * -moveVector.Z + cameraRight * moveVector.X)
		
		-- Note: With shift lock enabled, the character already faces camera direction
		-- So we just need to move the character using Humanoid:Move()
		humanoid:Move(worldMoveDirection, false)
	end
end

-- Input handling
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	
	-- Attack with left click or E key
	if input.UserInputType == Enum.UserInputType. MouseButton1 or input.KeyCode == Enum.KeyCode. E then
		-- Only attack if NOT in build mode (check global variable)
		if not _G.BuildModeActive then
			performMeleeAttack()
		end
	end
	
	-- Sprint with Left Shift (different from shift lock which uses Ctrl)
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

-- Update movement every frame
RunService. Heartbeat:Connect(function()
	if isAlive and not _G.BuildModeActive then
		handleMovement()
	end
end)

print("PlayerController loaded!")