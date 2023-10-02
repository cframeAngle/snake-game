--written by WAHAHHAHAHAHH  /  https://www.roblox.com/users/4085080308  /  cframe_angles
--put in starterplayerscripts or startercharacterscripts
local uis = game:GetService("UserInputService")
local directionRemote = game.ReplicatedStorage:WaitForChild("Direction")
local updateCameraRemote = game.ReplicatedStorage:WaitForChild("updateCamera")
local cam = workspace.CurrentCamera
cam.CameraType = Enum.CameraType.Scriptable
uis.InputBegan:Connect(function(key,bool)
	if bool then return end
	if key.KeyCode == Enum.KeyCode.W then
		directionRemote:FireServer(Vector3.new(0,0,2))
	elseif key.KeyCode == Enum.KeyCode.A then
		directionRemote:FireServer(Vector3.new(2,0,0))
	elseif key.KeyCode == Enum.KeyCode.D then
		directionRemote:FireServer(Vector3.new(-2,0,0))
	elseif key.KeyCode == Enum.KeyCode.S then
		directionRemote:FireServer(Vector3.new(0,0,-2))
	end
end)
updateCameraRemote.OnClientEvent:Connect(function(part)
	cam.CFrame = CFrame.new(part + Vector3.new(0,45,0) , part ) * CFrame.Angles(0,0,-math.rad(90))
end)