--written by WAHAHHAHAHAHH  /  https://www.roblox.com/users/4085080308  /  cframe_angles
--put in serverscriptservice
local players = game:GetService("Players")
local snakes = {} --making table with all snakes data
local apples = {}
local score = 0
local debris = game:GetService("Debris")
--settings
local snakePartsOnStart = 3
local taskwaitSpeed = .1
local appleLimit = 3
local mainSnakeCol = Color3.fromRGB(181, 255, 84)
local headSnakeCol = Color3.fromRGB(153, 213, 70)
local appleCol = Color3.fromRGB(240, 0, 4)
local appleTopCol = Color3.fromRGB(36, 36, 36)
local appleSpawnPosLimit = 50
--
-- creating remotes
local directionRemote = Instance.new("RemoteEvent") -- creating remotes
directionRemote.Name = "Direction"
directionRemote.Parent = game.ReplicatedStorage
local updateCameraRemote = Instance.new("RemoteEvent")
updateCameraRemote.Name = "updateCamera"
updateCameraRemote.Parent = game.ReplicatedStorage

local function createPart() -- function for creating part
	local part = Instance.new("Part")
	part.CanCollide = false
	part.Anchored = true
	part.Material = Enum.Material.SmoothPlastic
	return part
end
local function createSnakePart(player) -- function for creating a snake part
	local part = createPart()
	part.Color = mainSnakeCol
	part.Parent = workspace
	part.Size = Vector3.new(2,1,2)
	table.insert(snakes[player.Name].Parts,part)  -- inserting in player table
	part.Name = player.Name
	return part
end
local function createApplePart()
	local applePart = createPart()
	applePart.Shape = Enum.PartType.Ball
	applePart.Name = "Apple"
	applePart.Parent = workspace
	applePart.Color = appleCol
	appleSpawnPosLimit = math.clamp(appleSpawnPosLimit,5,math.huge)  -- making min value
	local x = math.random(-appleSpawnPosLimit,appleSpawnPosLimit) -- choosing random position
	local z = math.random(-appleSpawnPosLimit,appleSpawnPosLimit) -- choosing random position
	x = math.floor(x/4) * 4  -- making grid by x
	z = math.floor(z/4) * 4 -- making grid by z
	applePart.Position = Vector3.new(x,1,z)
	applePart.Size = Vector3.new(2,2,2)
	local appleTop = createPart()
	appleTop.Size = Vector3.new(.6,.3,.9)
	appleTop.Position = applePart.Position + Vector3.new(0,1,.5)
	appleTop.Parent = applePart
	appleTop.Name = "AppleTop"
	appleTop.Color = appleTopCol
	table.insert(apples,applePart) -- inserting in apple table
	coroutine.wrap(function() -- making new thread
		while task.wait(taskwaitSpeed) do  -- making a loop
			local parts = workspace:GetPartsInPart(applePart)  -- since .Touched not working on cancollide off we using :GetPartsInPart with a loop
			for _,part in pairs(parts) do
				local player = players:FindFirstChild(part.Name) -- checking if a snake touches apple . trying to find it in players because all snake parts named snake name
				if player then 
					createSnakePart(player) --creating snake part
					debris:AddItem(applePart,0) -- destroying apple
					table.remove(apples,table.find(apples,applePart)) --removing from table
					snakes[player.Name].Score += math.random(8,15) -- adjusting score
					print(player.Name .. " Score: " .. snakes[player.Name].Score)
					return -- ending loop
				end
			end
		end
	end)()
	return applePart
end
coroutine.wrap(function()
	while task.wait(taskwaitSpeed) do
		for _,player in pairs(players:GetPlayers()) do
			local character = player.Character or player.CharacterAdded:Wait()
			if character and snakes[player.Name] then -- checking if char is spawned and snakes has a player data table
				snakes[player.Name].MoveTo = snakes[player.Name].MoveTo + snakes[player.Name].Direction --calculating direction
				local part = table.remove(snakes[player.Name].Parts,1)
				if part == nil then continue end -- checking if 1st part exist
				table.insert(snakes[player.Name].Parts,part) -- inserting back
				part.Position = snakes[player.Name].MoveTo -- updating moveto pos
				for _,part in pairs(snakes[player.Name].Parts) do  -- recoloring all parts
					if part:IsA("BasePart") then
						part.Color = mainSnakeCol
					end
				end
				snakes[player.Name].Parts[#snakes[player.Name].Parts].Color = headSnakeCol -- coloring snake front part
				updateCameraRemote:FireClient(player,snakes[player.Name].Parts[#snakes[player.Name].Parts].Position)  -- updating player cam cf
				local origin = snakes[player.Name].Parts[#snakes[player.Name].Parts].Position 
				local direction = nil
				if snakes[player.Name].Direction == Vector3.new(0,0,-2) then   -- calculatin direction
					direction = snakes[player.Name].Parts[#snakes[player.Name].Parts].CFrame.LookVector * 2
				elseif snakes[player.Name].Direction == Vector3.new(0,0,2) then
					direction = snakes[player.Name].Parts[#snakes[player.Name].Parts].CFrame.LookVector * -2
				elseif snakes[player.Name].Direction == Vector3.new(2,0,0) then
					direction = snakes[player.Name].Parts[#snakes[player.Name].Parts].CFrame.RightVector * 2
				elseif snakes[player.Name].Direction == Vector3.new(-2,0,0) then
					direction = snakes[player.Name].Parts[#snakes[player.Name].Parts].CFrame.RightVector * -2
				end
				local params = RaycastParams.new()
				params.FilterType = Enum.RaycastFilterType.Exclude
				params.FilterDescendantsInstances = { snakes[player.Name].Parts[#snakes[player.Name].Parts] }
				local result = workspace:Raycast(origin,direction,params) --raycasting ( so we can know if snake touches itself )
				if result then
					local inst = result.Instance
					if table.find(snakes[player.Name].Parts,result.Instance) then --if yes then restarting
						for _,part in pairs(snakes[player.Name].Parts) do
							if part:IsA("Part") then
								debris:AddItem(part,0)
							end
						end
						table.clear(snakes[player.Name].Parts)
						snakes[player.Name].MoveTo = Vector3.new()
						snakes[player.Name].Direction = Vector3.new(0,0,2)
						print(player.Name .. " Died with Score: " .. snakes[player.Name].Score)
						snakes[player.Name].Score = 0
						snakePartsOnStart = math.clamp(snakePartsOnStart,1,math.huge)
						for i = 1,snakePartsOnStart do 
							createSnakePart(player)
						end
					--[[elseif inst.Name == "Apple" then -- another way to eat apple ( using raycasting )
						createSnakePart(player)
						debris:AddItem(inst,0)
						table.remove(apples,table.find(apples,inst))]]
					end
				end
			end
		end
		appleLimit = math.clamp(appleLimit,1,math.huge)
		if #apples < appleLimit then --checking if there are enough apples to spawn new one
			createApplePart()
		end
	end
end)()
players.PlayerAdded:Connect(function(player)
	snakes[player.Name] = { --making a table
		Direction = Vector3.new(0,0,2),
		MoveTo = Vector3.new(),
		Parts = {},
		Score = 0,
	}
	snakePartsOnStart = math.clamp(snakePartsOnStart,1,math.huge)
	for i = 1,snakePartsOnStart do 
		createSnakePart(player)
	end
	player.CharacterAdded:Connect(function(character)
		task.wait(.1)
		for _,part in pairs(character:GetDescendants()) do --making char invisible
			if part:IsA("BasePart") then
				part.Transparency = 1
			end
		end
	end)
end)
players.PlayerRemoving:Connect(function(player)
	for _,part in pairs(snakes[player.Name].Parts) do
		if part:IsA("BasePart") then
			debris:AddItem(part,0)
		end
	end
	table.remove(snakes,table.find(snakes,player.Name)) --removing player table and snake on leave
end)
directionRemote.OnServerEvent:Connect(function(player,dir)
	local character = player.Character or player.CharacterAdded:Wait()
	if character and snakes[player.Name] then
		if snakes[player.Name].Direction == Vector3.new(0,0,2) and dir == Vector3.new(0,0,-2) --checking if player tries to move snake back
			or snakes[player.Name].Direction == Vector3.new(2,0,0) and dir == Vector3.new(-2,0,0)
			or snakes[player.Name].Direction == Vector3.new(0,0,-2) and dir == Vector3.new(0,0,2)
			or snakes[player.Name].Direction == Vector3.new(-2,0,0) and dir == Vector3.new(2,0,0) then
			return
		else
			snakes[player.Name].Direction = dir --if not updating die
		end
	end
end)