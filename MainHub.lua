local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local AuroraUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/0x01125145/0X0/refs/heads/main/AuroraUI.lua"))()

local function getUiParent()
	local ok, ui = pcall(function()
		return gethui()
	end)
	if ok and ui then
		return ui
	end
	return game:GetService("CoreGui")
end

local function createBackground()
	local uiParent = getUiParent()
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "AURORA_HubBackground"
	screenGui.IgnoreGuiInset = true
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.DisplayOrder = -100
	screenGui.Parent = uiParent

	local background = Instance.new("Frame")
	background.Size = UDim2.fromScale(1, 1)
	background.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
	background.BorderSizePixel = 0
	background.Parent = screenGui

	local gradient = Instance.new("UIGradient")
	gradient.Rotation = 90
	gradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(10, 10, 10)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0)),
	})
	gradient.Parent = background

	local particleLayer = Instance.new("Frame")
	particleLayer.Size = UDim2.fromScale(1, 1)
	particleLayer.BackgroundTransparency = 1
	particleLayer.BorderSizePixel = 0
	particleLayer.Parent = background

	local particles = {}
	local viewport = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1920, 1080)
	for _ = 1, 90 do
		local dot = Instance.new("Frame")
		local s = math.random(1, 3)
		dot.Size = UDim2.fromOffset(s, s)
		dot.Position = UDim2.fromOffset(math.random(0, viewport.X), math.random(0, viewport.Y))
		dot.BackgroundColor3 = Color3.fromRGB(210, 210, 210)
		dot.BackgroundTransparency = math.random(58, 86) / 100
		dot.BorderSizePixel = 0
		dot.Parent = particleLayer

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(1, 0)
		corner.Parent = dot

		local v = Vector2.new(math.random(-100, 100), math.random(-100, 100))
		if v.Magnitude < 0.01 then
			v = Vector2.new(1, 0)
		end

		table.insert(particles, {
			ui = dot,
			pos = Vector2.new(dot.Position.X.Offset, dot.Position.Y.Offset),
			vel = v.Unit * math.random(6, 22),
		})
	end

	RunService.Heartbeat:Connect(function(dt)
		if workspace.CurrentCamera then
			viewport = workspace.CurrentCamera.ViewportSize
		end
		for _, p in ipairs(particles) do
			p.pos += p.vel * dt
			if p.pos.X < 0 or p.pos.X > viewport.X then
				p.vel = Vector2.new(-p.vel.X, p.vel.Y)
				p.pos = Vector2.new(math.clamp(p.pos.X, 0, viewport.X), p.pos.Y)
			end
			if p.pos.Y < 0 or p.pos.Y > viewport.Y then
				p.vel = Vector2.new(p.vel.X, -p.vel.Y)
				p.pos = Vector2.new(p.pos.X, math.clamp(p.pos.Y, 0, viewport.Y))
			end
			p.ui.Position = UDim2.fromOffset(p.pos.X, p.pos.Y)
		end
	end)
end

createBackground()

local ui = AuroraUI.new(getUiParent())
ui:CreateWindow({
	Title = "AURORA",
	SubTitle = "Custom Main Hub",
	Size = UDim2.fromOffset(560, 360),
})

local mainTab = ui:AddTab({ Title = "Main" })
local combatTab = ui:AddTab({ Title = "Combat" })
local visualTab = ui:AddTab({ Title = "Visual" })
local playerTab = ui:AddTab({ Title = "Player" })
local teleportsTab = ui:AddTab({ Title = "Teleports" })
ui:AddTab({ Title = "Settings" })

local mainInfo = mainTab:AddSection("Overview")
mainInfo:AddParagraph("Status: Connected")
mainInfo:AddParagraph("Game: " .. tostring(game.PlaceId))

local quick = mainTab:AddSection("Quick Actions")
quick:AddButton("Rejoin Server", function()
	game:GetService("TeleportService"):Teleport(game.PlaceId, Players.LocalPlayer)
end)
quick:AddButton("Copy PlaceId", function()
	if setclipboard then
		setclipboard(tostring(game.PlaceId))
	end
end)

local combat = combatTab:AddSection("Combat Module")
combat:AddParagraph("Design your Kill Aura / Auto Parry / Weapon tools here.")

local visual = visualTab:AddSection("Visual Module")
visual:AddParagraph("Design your ESP / Tracers / Chams here.")

local player = playerTab:AddSection("Player Module")
player:AddParagraph("Design movement and utility tools here.")

local tps = teleportsTab:AddSection("Teleports Module")
tps:AddParagraph("Design saved locations and route teleports here.")
