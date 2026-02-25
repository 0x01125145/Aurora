local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local TextService = game:GetService("TextService")

local ICON_REGISTRY_URL = "https://raw.githubusercontent.com/0x01125145/Aurora/main/IconRegistry.lua"

local function getUiParent()
	local ok, ui = pcall(function()
		return gethui()
	end)
	if ok and ui then
		return ui
	end
	return game:GetService("CoreGui")
end

local function safeRandom(maxValue)
	local n = math.floor(tonumber(maxValue) or 0)
	if n < 1 then
		n = 1
	end
	return math.random(0, n)
end

local function getTabButtonWidth(labelText)
	local textBounds = TextService:GetTextSize(
		tostring(labelText),
		13,
		Enum.Font.GothamSemibold,
		Vector2.new(1000, 30)
	)
	local width = math.floor(textBounds.X + 44)
	return math.clamp(width, 82, 156)
end

local function loadIconRegistry()
	local ok, result = pcall(function()
		local source = game:HttpGet(ICON_REGISTRY_URL)
		local chunk = loadstring(source)
		if not chunk then
			return nil
		end
		return chunk()
	end)
	if not ok or type(result) ~= "table" or type(result.assets) ~= "table" then
		return { assets = {} }
	end
	return result
end

local function makeDraggable(handle, target)
	local dragging = false
	local dragStart = Vector2.new(0, 0)
	local startPos = target.Position

	handle.InputBegan:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 then
			return
		end
		dragging = true
		dragStart = input.Position
		startPos = target.Position
	end)

	handle.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if not dragging or input.UserInputType ~= Enum.UserInputType.MouseMovement then
			return
		end
		local delta = input.Position - dragStart
		target.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
	end)
end

local animatedGradients = {}

local function trackAnimatedGradient(gradient, phaseShift)
	if gradient then
		table.insert(animatedGradients, {
			gradient = gradient,
			phaseShift = phaseShift or 0,
		})
	end
	return gradient
end

local function getTabCycleColors()
	return ColorSequence.new({
		ColorSequenceKeypoint.new(0.00, Color3.fromRGB(90, 255, 170)),  -- green
		ColorSequenceKeypoint.new(0.28, Color3.fromRGB(245, 235, 105)), -- yellow
		ColorSequenceKeypoint.new(0.56, Color3.fromRGB(90, 220, 255)),  -- cyan
		ColorSequenceKeypoint.new(0.82, Color3.fromRGB(125, 155, 255)), -- blue
		ColorSequenceKeypoint.new(1.00, Color3.fromRGB(90, 255, 170)),  -- back to green
	})
end

local uiParent = getUiParent()
local Icons = loadIconRegistry()
local old = uiParent:FindFirstChild("AURORA_MainHub")
if old then
	old:Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name = "AURORA_MainHub"
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.DisplayOrder = 100
gui.Parent = uiParent

local root = Instance.new("Frame")
root.Name = "Root"
root.AnchorPoint = Vector2.new(0.5, 0.5)
root.Position = UDim2.fromScale(0.5, 0.5)
root.Size = UDim2.fromOffset(600, 450)
root.BackgroundTransparency = 1
root.BorderSizePixel = 0
root.Parent = gui

local rootScale = Instance.new("UIScale")
rootScale.Scale = 0.84
rootScale.Parent = root

local panel = Instance.new("Frame")
panel.Name = "Panel"
panel.Size = UDim2.fromScale(1, 1)
panel.BackgroundColor3 = Color3.fromRGB(8, 8, 10)
panel.BorderSizePixel = 0
panel.ClipsDescendants = true
panel.Parent = root

local panelCorner = Instance.new("UICorner")
panelCorner.CornerRadius = UDim.new(0, 6)
panelCorner.Parent = panel

local panelGradient = Instance.new("UIGradient")
panelGradient.Rotation = 90
panelGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(14, 14, 16)),
	ColorSequenceKeypoint.new(0.5, Color3.fromRGB(9, 9, 11)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(6, 6, 8)),
})
panelGradient.Parent = panel

local title = Instance.new("TextLabel")
title.BackgroundTransparency = 1
title.AnchorPoint = Vector2.new(0.5, 0)
title.Position = UDim2.new(0.5, 0, 0, -42)
title.Size = UDim2.fromOffset(320, 40)
title.Text = "AURORA"
title.TextXAlignment = Enum.TextXAlignment.Center
title.Font = Enum.Font.GothamBlack
title.TextSize = 34
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextTransparency = 1
title.Parent = root

local titleGradient = Instance.new("UIGradient")
titleGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(90, 255, 170)),
	ColorSequenceKeypoint.new(0.34, Color3.fromRGB(90, 220, 255)),
	ColorSequenceKeypoint.new(0.68, Color3.fromRGB(125, 155, 255)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(90, 255, 170)),
})
titleGradient.Parent = title
trackAnimatedGradient(titleGradient)

local dragHandle = Instance.new("Frame")
dragHandle.Name = "DragHandle"
dragHandle.AnchorPoint = Vector2.new(0.5, 0)
dragHandle.Position = UDim2.new(0.5, 0, 0, -44)
dragHandle.Size = UDim2.fromOffset(360, 54)
dragHandle.BackgroundTransparency = 1
dragHandle.BorderSizePixel = 0
dragHandle.Active = true
dragHandle.Parent = root

local particleLayer = Instance.new("Frame")
particleLayer.Size = UDim2.fromScale(1, 1)
particleLayer.BackgroundTransparency = 1
particleLayer.BorderSizePixel = 0
particleLayer.Parent = panel

local size = panel.AbsoluteSize
if size.X < 1 or size.Y < 1 then
	panel:GetPropertyChangedSignal("AbsoluteSize"):Wait()
	size = panel.AbsoluteSize
end

local particles = {}
for _ = 1, 80 do
	local dot = Instance.new("Frame")
	local s = math.random(1, 3)
	dot.Size = UDim2.fromOffset(s, s)
	dot.Position = UDim2.fromOffset(safeRandom(size.X), safeRandom(size.Y))
	dot.BackgroundColor3 = Color3.fromRGB(210, 210, 210)
	dot.BackgroundTransparency = math.random(58, 86) / 100
	dot.BorderSizePixel = 0
	dot.Parent = particleLayer

	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(1, 0)
	c.Parent = dot

	local v = Vector2.new(math.random(-100, 100), math.random(-100, 100))
	if v.Magnitude < 0.01 then
		v = Vector2.new(1, 0)
	end

	table.insert(particles, {
		ui = dot,
		pos = Vector2.new(dot.Position.X.Offset, dot.Position.Y.Offset),
		vel = v.Unit * math.random(5, 16),
	})
end

local tabBar = Instance.new("Frame")
tabBar.Name = "TabBar"
tabBar.AnchorPoint = Vector2.new(0.5, 0)
tabBar.Position = UDim2.new(0.5, 0, 1, 24)
tabBar.Size = UDim2.new(1, -104, 0, 46)
tabBar.BackgroundColor3 = Color3.fromRGB(8, 8, 10)
tabBar.BackgroundTransparency = 1
tabBar.BorderSizePixel = 0
tabBar.ClipsDescendants = true
tabBar.Parent = root

local tabBarCorner = Instance.new("UICorner")
tabBarCorner.CornerRadius = UDim.new(0, 6)
tabBarCorner.Parent = tabBar

local tabBarStroke = Instance.new("UIStroke")
tabBarStroke.Thickness = 1
tabBarStroke.Color = Color3.fromRGB(55, 66, 86)
tabBarStroke.Transparency = 1
tabBarStroke.Parent = tabBar

local tabBarGradient = Instance.new("UIGradient")
tabBarGradient.Rotation = 90
tabBarGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(14, 14, 16)),
	ColorSequenceKeypoint.new(0.5, Color3.fromRGB(9, 9, 11)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(6, 6, 8)),
})
tabBarGradient.Parent = tabBar

local tabContent = Instance.new("ScrollingFrame")
tabContent.Name = "TabContent"
tabContent.Size = UDim2.fromScale(1, 1)
tabContent.BackgroundTransparency = 1
tabContent.BorderSizePixel = 0
tabContent.ZIndex = 2
tabContent.CanvasSize = UDim2.fromOffset(0, 0)
tabContent.ScrollBarThickness = 3
tabContent.ScrollBarImageColor3 = Color3.fromRGB(48, 72, 108)
tabContent.ScrollBarImageTransparency = 1
tabContent.ScrollingDirection = Enum.ScrollingDirection.X
tabContent.VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar
tabContent.HorizontalScrollBarInset = Enum.ScrollBarInset.ScrollBar
tabContent.AutomaticCanvasSize = Enum.AutomaticSize.None
tabContent.ScrollingEnabled = true
tabContent.ElasticBehavior = Enum.ElasticBehavior.Never
tabContent.Parent = tabBar

local tabOverlay = Instance.new("Frame")
tabOverlay.Name = "TabOverlay"
tabOverlay.Size = UDim2.fromScale(1, 1)
tabOverlay.BackgroundTransparency = 1
tabOverlay.BorderSizePixel = 0
tabOverlay.ZIndex = 6
tabOverlay.Parent = tabBar

local tabLayout = Instance.new("UIListLayout")
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
tabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
tabLayout.Padding = UDim.new(0, 6)
tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabLayout.Parent = tabContent

local tabPadding = Instance.new("UIPadding")
tabPadding.PaddingLeft = UDim.new(0, 8)
tabPadding.PaddingRight = UDim.new(0, 8)
tabPadding.Parent = tabContent

local activeUnderline
local activeUnderlineTween

activeUnderline = Instance.new("Frame")
activeUnderline.Name = "ActiveUnderline"
activeUnderline.AnchorPoint = Vector2.new(0.5, 1)
activeUnderline.Position = UDim2.new(0, 0, 1, -1)
activeUnderline.Size = UDim2.fromOffset(56, 2)
activeUnderline.BackgroundColor3 = Color3.fromRGB(95, 228, 255)
activeUnderline.BackgroundTransparency = 1
activeUnderline.BorderSizePixel = 0
activeUnderline.ZIndex = 6
activeUnderline.Parent = tabOverlay

local activeUnderlineGradient = Instance.new("UIGradient")
activeUnderlineGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(90, 255, 170)),
	ColorSequenceKeypoint.new(0.5, Color3.fromRGB(90, 220, 255)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(125, 155, 255)),
})
activeUnderlineGradient.Parent = activeUnderline

local function updateTabCanvas()
	local contentWidth = tabLayout.AbsoluteContentSize.X + tabPadding.PaddingLeft.Offset + tabPadding.PaddingRight.Offset
	tabContent.CanvasSize = UDim2.fromOffset(math.max(contentWidth, tabContent.AbsoluteSize.X), 0)
end

tabLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateTabCanvas)
tabContent:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateTabCanvas)

local tabParticleLayer = Instance.new("Frame")
tabParticleLayer.Name = "ParticleLayer"
tabParticleLayer.Size = UDim2.fromScale(1, 1)
tabParticleLayer.BackgroundTransparency = 1
tabParticleLayer.BorderSizePixel = 0
tabParticleLayer.ZIndex = 1
tabParticleLayer.Parent = tabBar

local tabParticles = {}
local tabSize = tabBar.AbsoluteSize
if tabSize.X < 1 or tabSize.Y < 1 then
	tabBar:GetPropertyChangedSignal("AbsoluteSize"):Wait()
	tabSize = tabBar.AbsoluteSize
end

for _ = 1, 22 do
	local dot = Instance.new("Frame")
	local s = math.random(1, 2)
	dot.Size = UDim2.fromOffset(s, s)
	dot.Position = UDim2.fromOffset(safeRandom(tabSize.X), safeRandom(tabSize.Y))
	dot.BackgroundColor3 = Color3.fromRGB(210, 210, 210)
	dot.BackgroundTransparency = math.random(62, 90) / 100
	dot.BorderSizePixel = 0
	dot.ZIndex = 1
	dot.Parent = tabParticleLayer

	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(1, 0)
	c.Parent = dot

	local v = Vector2.new(math.random(-100, 100), math.random(-100, 100))
	if v.Magnitude < 0.01 then
		v = Vector2.new(1, 0)
	end

	table.insert(tabParticles, {
		ui = dot,
		pos = Vector2.new(dot.Position.X.Offset, dot.Position.Y.Offset),
		vel = v.Unit * math.random(4, 10),
	})
end

local tabs = { "Main", "Autofarm", "Teleport", "Player", "Settings", "Test" }
local tabIconKeys = {
	Main = "lucide-home",
	Autofarm = "lucide-play-circle",
	Teleport = "lucide-map-pin",
	Player = "lucide-user",
	Settings = "lucide-settings",
	Test = "lucide-flask-round",
}
local tabButtons = {}
local tabLabels = {}
local tabIcons = {}
local tabStrokes = {}
local tabGlosses = {}
local tabPages = {}
local tabPageMeta = {}
local activeTab
local switchToken = 0
local suppressUnderlineSnapUntil = 0

local contentHost = Instance.new("Frame")
contentHost.Name = "ContentHost"
contentHost.Position = UDim2.fromOffset(14, 14)
contentHost.Size = UDim2.new(1, -28, 1, -28)
contentHost.BackgroundTransparency = 1
contentHost.BorderSizePixel = 0
contentHost.ZIndex = 4
contentHost.Parent = panel

local function moveActiveUnderline(targetButton, instant)
	if not activeUnderline or not targetButton then
		return
	end

	activeUnderline.Visible = true
	activeUnderline.BackgroundTransparency = 0

	local width = math.clamp(targetButton.AbsoluteSize.X - 40, 34, 72)
	local buttonCenterX = (targetButton.AbsolutePosition.X - tabBar.AbsolutePosition.X) + (targetButton.AbsoluteSize.X * 0.5)
	local targetPos = UDim2.new(0, buttonCenterX, 1, -1)
	local targetSize = UDim2.fromOffset(width, 2)

	if activeUnderlineTween then
		activeUnderlineTween:Cancel()
		activeUnderlineTween = nil
	end

	if instant then
		activeUnderline.Position = targetPos
		activeUnderline.Size = targetSize
		return
	end

	activeUnderlineTween = TweenService:Create(
		activeUnderline,
		TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
		{ Position = targetPos, Size = targetSize }
	)
	suppressUnderlineSnapUntil = os.clock() + 0.32
	activeUnderlineTween:Play()
end

local function refreshUnderlineNextFrame()
	task.defer(function()
		if not gui.Parent then
			return
		end
		RunService.Heartbeat:Wait()
		if activeTab and activeTab.Parent then
			moveActiveUnderline(activeTab, true)
		end
	end)
end

tabContent:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
	if activeTab and os.clock() >= suppressUnderlineSnapUntil then
		moveActiveUnderline(activeTab, true)
	end
end)

tabBar:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
	if activeTab and os.clock() >= suppressUnderlineSnapUntil then
		moveActiveUnderline(activeTab, true)
	end
end)

tabBar:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
	if activeTab and os.clock() >= suppressUnderlineSnapUntil then
		moveActiveUnderline(activeTab, true)
	end
end)

local function focusTabButton(targetButton)
	if not targetButton or not targetButton.Parent then
		return
	end

	local buttonLeft = (targetButton.AbsolutePosition.X - tabContent.AbsolutePosition.X) + tabContent.CanvasPosition.X
	local buttonRight = buttonLeft + targetButton.AbsoluteSize.X
	local viewLeft = tabContent.CanvasPosition.X
	local viewRight = viewLeft + tabContent.AbsoluteSize.X
	local targetX = viewLeft

	if buttonLeft < viewLeft then
		targetX = buttonLeft - 8
	elseif buttonRight > viewRight then
		targetX = buttonRight - tabContent.AbsoluteSize.X + 8
	end

	local maxX = math.max(0, tabContent.CanvasSize.X.Offset - tabContent.AbsoluteSize.X)
	targetX = math.clamp(targetX, 0, maxX)

	if math.abs(targetX - tabContent.CanvasPosition.X) < 1 then
		return
	end

	TweenService:Create(
		tabContent,
		TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ CanvasPosition = Vector2.new(targetX, 0) }
	):Play()
end

local function setActiveTab(btn)
	if activeTab == btn then
		focusTabButton(activeTab)
		activeUnderline.BackgroundTransparency = 0
		moveActiveUnderline(activeTab, false)
		return
	end

	switchToken = switchToken + 1
	local token = switchToken

	if activeTab then
		activeTab.BackgroundColor3 = Color3.fromRGB(20, 24, 30)
		if tabLabels[activeTab] then
			tabLabels[activeTab].TextTransparency = 0.22
		end
		if tabIcons[activeTab] then
			tabIcons[activeTab].ImageTransparency = 0.35
		end
		if tabStrokes[activeTab] then
			tabStrokes[activeTab].Transparency = 0.62
		end
		if tabPages[activeTab] then
			local oldMeta = tabPageMeta[activeTab]
			if oldMeta then
				TweenService:Create(oldMeta.Title, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextTransparency = 1 }):Play()
				TweenService:Create(oldMeta.Info, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextTransparency = 1 }):Play()
			end
			local oldPage = tabPages[activeTab]
			task.delay(0.12, function()
				if token == switchToken and oldPage then
					oldPage.Visible = false
				end
			end)
		end
	end
	activeTab = btn
	activeTab.BackgroundColor3 = Color3.fromRGB(36, 52, 78)
	if tabLabels[activeTab] then
		tabLabels[activeTab].TextTransparency = 0
	end
	if tabIcons[activeTab] then
		tabIcons[activeTab].ImageTransparency = 0.05
	end
	if tabStrokes[activeTab] then
		tabStrokes[activeTab].Transparency = 0.2
	end
	if tabPages[activeTab] then
		local activeMeta = tabPageMeta[activeTab]
		tabPages[activeTab].Visible = true
		if activeMeta then
			activeMeta.Title.TextTransparency = 1
			activeMeta.Info.TextTransparency = 1
			TweenService:Create(activeMeta.Title, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextTransparency = 0 }):Play()
			TweenService:Create(activeMeta.Info, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextTransparency = 0 }):Play()
		end
	end
	activeUnderline.BackgroundTransparency = 0
	focusTabButton(activeTab)
	task.defer(function()
		if activeTab == btn then
			moveActiveUnderline(activeTab, false)
		end
	end)
end

for index, name in ipairs(tabs) do
	local tabPhaseStep = 2 / #tabs
	local buttonWidth = getTabButtonWidth(name)
	local tabButton = Instance.new("TextButton")
	tabButton.Name = name .. "Tab"
	tabButton.Size = UDim2.fromOffset(buttonWidth, 30)
	tabButton.LayoutOrder = index
	tabButton.BackgroundColor3 = Color3.fromRGB(26, 34, 50)
	tabButton.BackgroundTransparency = 0.22
	tabButton.AutoButtonColor = false
	tabButton.BorderSizePixel = 0
	tabButton.Font = Enum.Font.GothamSemibold
	tabButton.TextSize = 13
	tabButton.Text = ""
	tabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	tabButton.ZIndex = 3
	tabButton.Parent = tabContent

	local tabButtonCorner = Instance.new("UICorner")
	tabButtonCorner.CornerRadius = UDim.new(0, 6)
	tabButtonCorner.Parent = tabButton

	local tabButtonStroke = Instance.new("UIStroke")
	tabButtonStroke.Thickness = 1
	tabButtonStroke.Color = Color3.fromRGB(150, 185, 235)
	tabButtonStroke.Transparency = 0.62
	tabButtonStroke.Parent = tabButton
	tabStrokes[tabButton] = tabButtonStroke

	local tabButtonGradient = Instance.new("UIGradient")
	tabButtonGradient.Rotation = 90
	tabButtonGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(56, 78, 112)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(23, 31, 46)),
	})
	tabButtonGradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.12),
		NumberSequenceKeypoint.new(1, 0.38),
	})
	tabButtonGradient.Parent = tabButton

	local icon = Instance.new("ImageLabel")
	icon.Name = "Icon"
	icon.BackgroundTransparency = 1
	icon.Position = UDim2.fromOffset(8, 7)
	icon.Size = UDim2.fromOffset(16, 16)
	icon.Image = Icons.assets[tabIconKeys[name] or ""] or ""
	icon.ImageColor3 = Color3.fromRGB(255, 255, 255)
	icon.ImageTransparency = 0.35
	icon.ZIndex = 5
	icon.Parent = tabButton

	local iconGradient = Instance.new("UIGradient")
	iconGradient.Rotation = 0
	iconGradient.Color = getTabCycleColors()
	iconGradient.Parent = icon
	local tabPhaseShift = (index - 1) * tabPhaseStep
	trackAnimatedGradient(iconGradient, tabPhaseShift)
	tabIcons[tabButton] = icon

	local tabText = Instance.new("TextLabel")
	tabText.Name = "Label"
	tabText.BackgroundTransparency = 1
	tabText.Position = UDim2.fromOffset(26, 0)
	tabText.Size = UDim2.new(1, -30, 1, 0)
	tabText.Font = Enum.Font.GothamSemibold
	tabText.TextSize = 13
	tabText.Text = name
	tabText.TextXAlignment = Enum.TextXAlignment.Center
	tabText.TextYAlignment = Enum.TextYAlignment.Center
	tabText.TextColor3 = Color3.fromRGB(255, 255, 255)
	tabText.ZIndex = 5
	tabText.Parent = tabButton

	local tabTextGradient = Instance.new("UIGradient")
	tabTextGradient.Rotation = 0
	tabTextGradient.Color = getTabCycleColors()
	tabTextGradient.Parent = tabText
	trackAnimatedGradient(tabTextGradient, tabPhaseShift)

	local gloss = Instance.new("Frame")
	gloss.Name = "Gloss"
	gloss.Size = UDim2.new(1, -2, 0, 10)
	gloss.Position = UDim2.fromOffset(1, 1)
	gloss.BackgroundColor3 = Color3.fromRGB(170, 200, 235)
	gloss.BackgroundTransparency = 0.9
	gloss.BorderSizePixel = 0
	gloss.ZIndex = tabButton.ZIndex + 1
	gloss.Parent = tabButton
	tabGlosses[tabButton] = gloss

	local glossCorner = Instance.new("UICorner")
	glossCorner.CornerRadius = UDim.new(0, 5)
	glossCorner.Parent = gloss

	local glossGradient = Instance.new("UIGradient")
	glossGradient.Rotation = 90
	glossGradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.35),
		NumberSequenceKeypoint.new(1, 1),
	})
	glossGradient.Parent = gloss

	local page = Instance.new("Frame")
	page.Name = name .. "Page"
	page.Size = UDim2.fromScale(1, 1)
	page.BackgroundTransparency = 1
	page.BorderSizePixel = 0
	page.Visible = false
	page.ZIndex = 4
	page.Parent = contentHost

	local pageTitle = Instance.new("TextLabel")
	pageTitle.BackgroundTransparency = 1
	pageTitle.Position = UDim2.fromOffset(4, 4)
	pageTitle.Size = UDim2.new(1, -8, 0, 30)
	pageTitle.Font = Enum.Font.GothamBold
	pageTitle.TextSize = 24
	pageTitle.TextXAlignment = Enum.TextXAlignment.Left
	pageTitle.Text = name
	pageTitle.TextColor3 = Color3.fromRGB(215, 230, 255)
	pageTitle.ZIndex = 5
	pageTitle.Parent = page

	local pageInfo = Instance.new("TextLabel")
	pageInfo.BackgroundTransparency = 1
	pageInfo.Position = UDim2.fromOffset(4, 36)
	pageInfo.Size = UDim2.new(1, -8, 0, 22)
	pageInfo.Font = Enum.Font.Gotham
	pageInfo.TextSize = 14
	pageInfo.TextXAlignment = Enum.TextXAlignment.Left
	pageInfo.Text = name .. " content area"
	pageInfo.TextColor3 = Color3.fromRGB(150, 165, 192)
	pageInfo.ZIndex = 5
	pageInfo.Parent = page

	tabPages[tabButton] = page
	tabPageMeta[tabButton] = { Title = pageTitle, Info = pageInfo }

	tabButton.MouseButton1Click:Connect(function()
		setActiveTab(tabButton)
	end)

	table.insert(tabButtons, tabButton)
	tabLabels[tabButton] = tabText
end

updateTabCanvas()

local function playOpenIntro()
	for _, btn in ipairs(tabButtons) do
		btn.BackgroundTransparency = 1
		if tabLabels[btn] then
			tabLabels[btn].TextTransparency = 1
		end
		if tabIcons[btn] then
			tabIcons[btn].ImageTransparency = 1
		end
		if tabStrokes[btn] then
			tabStrokes[btn].Transparency = 1
		end
		if tabGlosses[btn] then
			tabGlosses[btn].BackgroundTransparency = 1
		end
	end

	local grow = TweenService:Create(rootScale, TweenInfo.new(0.34, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 })
	local titleIn = TweenService:Create(title, TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextTransparency = 0 })
	grow:Play()
	titleIn:Play()
	grow.Completed:Wait()

	local barIn = TweenService:Create(
		tabBar,
		TweenInfo.new(0.24, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{
			Position = UDim2.new(0.5, 0, 1, 8),
			BackgroundTransparency = 0,
		}
	)
	local strokeIn = TweenService:Create(tabBarStroke, TweenInfo.new(0.24, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Transparency = 0.35 })
	local scrollIn = TweenService:Create(tabContent, TweenInfo.new(0.24, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { ScrollBarImageTransparency = 0.25 })
	barIn:Play()
	strokeIn:Play()
	scrollIn:Play()

	for i, btn in ipairs(tabButtons) do
		task.delay(0.025 * i, function()
			if not btn.Parent then
				return
			end
			local t = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
			TweenService:Create(btn, t, { BackgroundTransparency = 0.22 }):Play()
			if tabLabels[btn] then
				TweenService:Create(tabLabels[btn], t, { TextTransparency = 0.22 }):Play()
			end
			if tabIcons[btn] then
				TweenService:Create(tabIcons[btn], t, { ImageTransparency = 0.35 }):Play()
			end
			if tabStrokes[btn] then
				TweenService:Create(tabStrokes[btn], t, { Transparency = 0.62 }):Play()
			end
			if tabGlosses[btn] then
				TweenService:Create(tabGlosses[btn], t, { BackgroundTransparency = 0.9 }):Play()
			end
		end)
	end

	task.delay(0.2, function()
		if not gui.Parent or not tabButtons[1] then
			return
		end
		focusTabButton(tabButtons[1])
		moveActiveUnderline(tabButtons[1], true)
		setActiveTab(tabButtons[1])
		task.delay(0.05, function()
			if gui.Parent and activeTab == tabButtons[1] then
				moveActiveUnderline(tabButtons[1], true)
				refreshUnderlineNextFrame()
			end
		end)
	end)
end

if tabButtons[1] then
	task.defer(playOpenIntro)
end

makeDraggable(dragHandle, root)

local conn
local gradientPhase = 0
conn = RunService.Heartbeat:Connect(function(dt)
	if not gui.Parent then
		if conn then
			conn:Disconnect()
		end
		return
	end

	local panelSize = panel.AbsoluteSize
	if panelSize.X < 1 or panelSize.Y < 1 then
		return
	end
	local tabPanelSize = tabBar.AbsoluteSize
	if tabPanelSize.X < 1 or tabPanelSize.Y < 1 then
		return
	end

	for _, p in ipairs(particles) do
		if p.ui and p.ui.Parent then
			p.pos = p.pos + (p.vel * dt)
			if p.pos.X < 0 or p.pos.X > panelSize.X then
				p.vel = Vector2.new(-p.vel.X, p.vel.Y)
				p.pos = Vector2.new(math.clamp(p.pos.X, 0, panelSize.X), p.pos.Y)
			end
			if p.pos.Y < 0 or p.pos.Y > panelSize.Y then
				p.vel = Vector2.new(p.vel.X, -p.vel.Y)
				p.pos = Vector2.new(p.pos.X, math.clamp(p.pos.Y, 0, panelSize.Y))
			end
			p.ui.Position = UDim2.fromOffset(p.pos.X, p.pos.Y)
		end
	end

	for _, p in ipairs(tabParticles) do
		if p.ui and p.ui.Parent then
			p.pos = p.pos + (p.vel * dt)
			if p.pos.X < 0 or p.pos.X > tabPanelSize.X then
				p.vel = Vector2.new(-p.vel.X, p.vel.Y)
				p.pos = Vector2.new(math.clamp(p.pos.X, 0, tabPanelSize.X), p.pos.Y)
			end
			if p.pos.Y < 0 or p.pos.Y > tabPanelSize.Y then
				p.vel = Vector2.new(p.vel.X, -p.vel.Y)
				p.pos = Vector2.new(p.pos.X, math.clamp(p.pos.Y, 0, tabPanelSize.Y))
			end
			p.ui.Position = UDim2.fromOffset(p.pos.X, p.pos.Y)
		end
	end

	gradientPhase = (gradientPhase + dt * 0.65) % 2
	local offsetX = gradientPhase - 1
	for _, entry in ipairs(animatedGradients) do
		local gradient = entry.gradient
		if gradient and gradient.Parent then
			local shifted = ((gradientPhase + entry.phaseShift) % 2) - 1
			gradient.Offset = Vector2.new(shifted, 0)
		end
	end
end)
