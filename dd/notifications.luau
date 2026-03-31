--   Notif.Config -> table you can tweak
--   Notif.new(message: string, kind?: "Warning" | "Normal")

type Kind = "Warning" | "Normal"
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local TextService = game:GetService("TextService")
local Imp = game:GetObjects("rbxassetid://140110964502286")[1]
Imp.Parent = game.CoreGui

local Notif = {}

Notif.Config = {
	Parent = nil,
	DisplayTime = 3.2,
	Gap = 5,
	Padding = 10,
	BackgroundColor = Color3.fromRGB(26, 29, 33),
	WarningColor = Color3.fromRGB(255, 239, 66),
	ErrorColor = Color3.fromRGB(121, 0, 0),
	TextColor = Color3.fromRGB(240, 240, 240),
	ShadowTransparency = 1, --// i rlly didnt want to fix this LOL
	MinHeight = 25,
}

function Notif.new(message: string, kind: Kind?)
	task.spawn(function()
		kind = kind or "Normal"

		local parent
		if Notif.Config.Parent then
			parent = Notif.Config.Parent
		else
			local player = Players.LocalPlayer

			if identifyexecutor then
				parent = game:GetService("CoreGui")
			else
				parent = player:WaitForChild("PlayerGui")
			end
		end

		local screenGuiName = "NocturnalNotification"
		local screenGui = parent:FindFirstChild(screenGuiName)
		if not screenGui then
			screenGui = Instance.new("ScreenGui")
			screenGui.Name = screenGuiName
			screenGui.ResetOnSpawn = false
			screenGui.DisplayOrder = 1000
			screenGui.Parent = parent
			screenGui.IgnoreGuiInset = true
		end

		local containerName = "Notif_Container"
		local containerFrame = screenGui:FindFirstChild(containerName)
		if not containerFrame then
			containerFrame = Instance.new("Frame")
			containerFrame.Name = containerName
			containerFrame.AnchorPoint = Vector2.new(1, 0)
			containerFrame.Position = UDim2.new(1, -10, 0, 10)
			containerFrame.Size = UDim2.new(0, 0, 0, 0)
			containerFrame.BackgroundTransparency = 1
			containerFrame.Parent = screenGui
		end

		local root = Instance.new("Frame")
		root.Name = "NotifRoot"
		root.BackgroundTransparency = 1
		root.AnchorPoint = Vector2.new(1, 0)
		root.Position = UDim2.new(1, -10, 0, 10)
		root.Parent = containerFrame

		local bg = Imp.Background:Clone()
		bg.Parent = root
		local label = bg.Label

		label.Text = " "..message
		label.TextColor3 = Notif.Config.TextColor
		label.TextWrapped = false
		label.TextTransparency = 1

		local padding = Notif.Config.Padding or 12
		local textBounds = TextService:GetTextSize(message, label.TextSize, label.Font, Vector2.new(1e6, math.huge))
		local textWidth = math.ceil(textBounds.X)
		local targetHeight = math.clamp(textBounds.Y, Notif.Config.MinHeight, 9999)
		local finalWidth = textWidth + padding * 2

		root.Size = UDim2.new(0, finalWidth, 0, targetHeight)
		bg.Size = UDim2.new(1, 0, 1, 0)
		label.Size = UDim2.new(1, 0, 1, 0)

		local existing = 0
		for _, child in containerFrame:GetChildren() do
			if child:IsA("Frame") and child ~= root then
				existing = existing + 1
			end
		end
		local yOffset = existing * (targetHeight + Notif.Config.Gap)
		root.Position = UDim2.new(1, -50, 0, 10 + yOffset)

		local offscreenOffset = finalWidth + 0
		root.Position = root.Position + UDim2.new(0, offscreenOffset, 0, 0)

		local inTweenInfo = TweenInfo.new(0.52, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
		local inTween = TweenService:Create(root, inTweenInfo, { Position = UDim2.new(1, -10, 0, 10 + yOffset) })
		inTween:Play()

		bg.Size = UDim2.new(1, 0, 0, targetHeight * 0.98)
		local bgTween = TweenService:Create(bg, TweenInfo.new(0.42, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), { Size = UDim2.new(1, 0, 0, targetHeight) })
		bgTween:Play()

		local textFadeTwe = TweenService:Create(label, TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { TextTransparency = 0 })
		textFadeTwe:Play()

		task.spawn(function()
			while root and root.Parent do
				if bg and bg:FindFirstChild("UIGradient") then
					local grad = bg.UIGradient
					grad.Rotation = (grad.Rotation or 0) + 1
					if grad.Rotation >= 180 then
						grad.Rotation = -180
					end
				end
				task.wait()
			end
		end)

		task.delay(Notif.Config.DisplayTime, function()
			if not root or not root.Parent then return end

			local outTweenInfo = TweenInfo.new(0.42, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
			local outPos = TweenService:Create(root, outTweenInfo, { Position = root.Position + UDim2.new(0, offscreenOffset, 0, 0) })
			local outFade = TweenService:Create(label, TweenInfo.new(0.32, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { TextTransparency = 1 })
			local outShrink = TweenService:Create(bg, TweenInfo.new(0.42, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Size = UDim2.new(1, 0, 0, 0) })

			outPos:Play()
			outFade:Play()
			outShrink:Play()

			outPos.Completed:Wait()
			if root and root.Parent then
				root:Destroy()
			end

			local children = {}
			for _, child in containerFrame:GetChildren() do
				if child:IsA("Frame") then
					table.insert(children, child)
				end
			end

			table.sort(children, function(a, b)
				return a.Position.Y.Offset < b.Position.Y.Offset
			end)

			for idx, child in children do
				local newY = 10 + (idx - 1) * (targetHeight + Notif.Config.Gap)
				local t = TweenService:Create(child, TweenInfo.new(0.36, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), { Position = UDim2.new(1, -10, 0, newY) })
				t:Play()
			end
		end)
	end)
end

return Notif :: NocturnalNotification
