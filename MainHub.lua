local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local AuroraUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/0x01125145/Aurora/main/AuroraUI.lua"))()

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
	local oldBack = uiParent:FindFirstChild("AURORA_HubBackground")
	if oldBack then
		oldBack:Destroy()
	end
	local oldOverlay = uiParent:FindFirstChild("AURORA_HubOverlay")
	if oldOverlay then
		oldOverlay:Destroy()
	end
	local backGui = Instance.new("ScreenGui")
	backGui.Name = "AURORA_HubBackground"
	backGui.IgnoreGuiInset = true
	backGui.ResetOnSpawn = false
	backGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	backGui.DisplayOrder = 0
	backGui.Parent = uiParent

	local background = Instance.new("Frame")
	background.Size = UDim2.fromScale(1, 1)
	background.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
	background.BorderSizePixel = 0
	background.Parent = backGui

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
	particleLayer.Active = false
	particleLayer.Parent = backGui

	local particles = {}
	local viewport = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1920, 1080)
	for _ = 1, 90 do
		local dot = Instance.new("Frame")
		local s = math.random(1, 3)
		dot.Size = UDim2.fromOffset(s, s)
		dot.Position = UDim2.fromOffset(
			math.random(0, math.max(1, math.floor(viewport.X))),
			math.random(0, math.max(1, math.floor(viewport.Y)))
		)
		dot.BackgroundColor3 = Color3.fromRGB(210, 210, 210)
		dot.BackgroundTransparency = math.random(58, 86) / 100
		dot.BorderSizePixel = 0
		dot.Active = false
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

	local function updateParticles(dt)
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
	end

	if RunService and RunService.Heartbeat then
		RunService.Heartbeat:Connect(updateParticles)
	else
		task.spawn(function()
			while backGui.Parent do
				updateParticles(1 / 60)
				task.wait(1 / 60)
			end
		end)
	end
end

createBackground()

local ui = AuroraUI.new(getUiParent())
ui:CreateWindow({
	Title = "AURORA",
	SubTitle = "Custom Main Hub",
	Size = UDim2.fromOffset(560, 360),
})
ui.Gui.DisplayOrder = 100

local function createHubTopOverlay(root)
	local existing = root:FindFirstChild("AURORA_HubTopOverlay")
	if existing then
		existing:Destroy()
	end

	local overlay = Instance.new("Frame")
	overlay.Name = "AURORA_HubTopOverlay"
	overlay.Size = UDim2.fromScale(1, 1)
	overlay.BackgroundTransparency = 1
	overlay.BorderSizePixel = 0
	overlay.ZIndex = 50
	overlay.Active = false
	overlay.Parent = root

	local particles = {}
	local absoluteSize = root.AbsoluteSize

	for _ = 1, 22 do
		local dot = Instance.new("Frame")
		local s = math.random(1, 2)
		dot.Size = UDim2.fromOffset(s, s)
		dot.Position = UDim2.fromOffset(
			math.random(0, math.max(1, math.floor(absoluteSize.X))),
			math.random(0, math.max(1, math.floor(absoluteSize.Y)))
		)
		dot.BackgroundColor3 = Color3.fromRGB(235, 240, 255)
		dot.BackgroundTransparency = math.random(72, 90) / 100
		dot.BorderSizePixel = 0
		dot.ZIndex = 51
		dot.Active = false
		dot.Parent = overlay

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
			vel = v.Unit * math.random(5, 13),
		})
	end

	local function updateHubParticles(dt)
		if not overlay.Parent then
			return
		end

		local sz = root.AbsoluteSize
		for _, p in ipairs(particles) do
			p.pos += p.vel * dt
			if p.pos.X < 0 or p.pos.X > sz.X then
				p.vel = Vector2.new(-p.vel.X, p.vel.Y)
				p.pos = Vector2.new(math.clamp(p.pos.X, 0, sz.X), p.pos.Y)
			end
			if p.pos.Y < 0 or p.pos.Y > sz.Y then
				p.vel = Vector2.new(p.vel.X, -p.vel.Y)
				p.pos = Vector2.new(p.pos.X, math.clamp(p.pos.Y, 0, sz.Y))
			end
			p.ui.Position = UDim2.fromOffset(p.pos.X, p.pos.Y)
		end
	end

	if RunService and RunService.Heartbeat then
		local conn
		conn = RunService.Heartbeat:Connect(function(dt)
			if not overlay.Parent then
				if conn then
					conn:Disconnect()
				end
				return
			end
			updateHubParticles(dt)
		end)
	else
		task.spawn(function()
			while overlay.Parent do
				updateHubParticles(1 / 60)
				task.wait(1 / 60)
			end
		end)
	end
end

createHubTopOverlay(ui.Root)

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
