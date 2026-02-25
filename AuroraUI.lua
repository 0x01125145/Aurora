local UserInputService = game:GetService("UserInputService")

local AuroraUI = {}
AuroraUI.__index = AuroraUI

local function make(instanceType, props)
	local obj = Instance.new(instanceType)
	for k, v in pairs(props or {}) do
		obj[k] = v
	end
	return obj
end

local function round(parent, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius or 8)
	c.Parent = parent
	return c
end

local function stroke(parent, color, transparency, thickness)
	local s = Instance.new("UIStroke")
	s.Color = color or Color3.fromRGB(60, 60, 70)
	s.Transparency = transparency or 0
	s.Thickness = thickness or 1
	s.Parent = parent
	return s
end

local function makeDraggable(dragHandle, target)
	local dragging = false
	local dragStart, startPos

	dragHandle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = target.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if not dragging then
			return
		end
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = input.Position - dragStart
			target.Position = UDim2.new(
				startPos.X.Scale,
				startPos.X.Offset + delta.X,
				startPos.Y.Scale,
				startPos.Y.Offset + delta.Y
			)
		end
	end)
end

function AuroraUI.new(parent)
	local self = setmetatable({}, AuroraUI)
	self.Parent = parent
	self.Tabs = {}
	self.ActiveTab = nil
	return self
end

function AuroraUI:CreateWindow(config)
	config = config or {}
	local title = config.Title or "AURORA"
	local subtitle = config.SubTitle or "Custom Hub"
	local size = config.Size or UDim2.fromOffset(560, 360)

	local gui = make("ScreenGui", {
		Name = "AURORA_CustomHub",
		IgnoreGuiInset = true,
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		Parent = self.Parent,
	})

	local root = make("Frame", {
		Name = "Root",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = size,
		BackgroundColor3 = Color3.fromRGB(13, 13, 16),
		BorderSizePixel = 0,
		Parent = gui,
	})
	round(root, 5)
	stroke(root, Color3.fromRGB(64, 70, 85), 0.15, 1)

	local header = make("Frame", {
		Name = "Header",
		Size = UDim2.new(1, 0, 0, 48),
		BackgroundColor3 = Color3.fromRGB(18, 18, 24),
		BorderSizePixel = 0,
		Parent = root,
	})
	round(header, 5)

	local headerFix = make("Frame", {
		Size = UDim2.new(1, 0, 0, 24),
		Position = UDim2.new(0, 0, 1, -24),
		BackgroundColor3 = header.BackgroundColor3,
		BorderSizePixel = 0,
		Parent = header,
	})

	local titleLabel = make("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(14, 4),
		Size = UDim2.new(1, -20, 0, 22),
		Font = Enum.Font.GothamBold,
		Text = title,
		TextColor3 = Color3.fromRGB(240, 245, 255),
		TextSize = 16,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = header,
	})

	local subLabel = make("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(14, 22),
		Size = UDim2.new(1, -20, 0, 18),
		Font = Enum.Font.Gotham,
		Text = subtitle,
		TextColor3 = Color3.fromRGB(140, 150, 170),
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = header,
	})

	makeDraggable(header, root)

	local tabsBar = make("Frame", {
		Name = "TabsBar",
		Position = UDim2.fromOffset(0, 48),
		Size = UDim2.new(0, 180, 1, -48),
		BackgroundColor3 = Color3.fromRGB(16, 16, 20),
		BorderSizePixel = 0,
		Parent = root,
	})

	local tabsLayout = make("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 6),
		Parent = tabsBar,
	})

	local tabsPadding = make("UIPadding", {
		PaddingTop = UDim.new(0, 12),
		PaddingLeft = UDim.new(0, 10),
		PaddingRight = UDim.new(0, 10),
		Parent = tabsBar,
	})

	local content = make("Frame", {
		Name = "Content",
		Position = UDim2.fromOffset(180, 48),
		Size = UDim2.new(1, -180, 1, -48),
		BackgroundTransparency = 1,
		Parent = root,
	})

	self.Gui = gui
	self.Root = root
	self.Content = content
	self.TabsBar = tabsBar
	return self
end

function AuroraUI:AddTab(config)
	config = config or {}
	local title = config.Title or "Tab"

	local button = make("TextButton", {
		AutoButtonColor = false,
		Size = UDim2.new(1, 0, 0, 34),
		BackgroundColor3 = Color3.fromRGB(24, 24, 30),
		Text = title,
		Font = Enum.Font.Gotham,
		TextSize = 13,
		TextColor3 = Color3.fromRGB(185, 195, 215),
		Parent = self.TabsBar,
	})
	round(button, 5)

	local page = make("ScrollingFrame", {
		Visible = false,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 1, 0),
		CanvasSize = UDim2.new(0, 0, 0, 0),
		ScrollBarThickness = 4,
		Parent = self.Content,
	})
	local pageLayout = make("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 8),
		Parent = page,
	})
	make("UIPadding", {
		PaddingTop = UDim.new(0, 12),
		PaddingLeft = UDim.new(0, 12),
		PaddingRight = UDim.new(0, 12),
		PaddingBottom = UDim.new(0, 12),
		Parent = page,
	})

	pageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		page.CanvasSize = UDim2.fromOffset(0, pageLayout.AbsoluteContentSize.Y + 24)
	end)

	local tab = {
		Button = button,
		Page = page,
	}

	function tab:AddSection(sectionTitle)
		local section = make("Frame", {
			AutomaticSize = Enum.AutomaticSize.Y,
			Size = UDim2.new(1, 0, 0, 0),
			BackgroundColor3 = Color3.fromRGB(19, 19, 25),
			BorderSizePixel = 0,
			Parent = page,
		})
		round(section, 5)
		stroke(section, Color3.fromRGB(58, 64, 80), 0.2, 1)

		make("TextLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, -24, 0, 26),
			Position = UDim2.fromOffset(12, 8),
			Font = Enum.Font.GothamBold,
			Text = sectionTitle or "Section",
			TextColor3 = Color3.fromRGB(220, 230, 255),
			TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = section,
		})

		local holder = make("Frame", {
			AutomaticSize = Enum.AutomaticSize.Y,
			Size = UDim2.new(1, -24, 0, 0),
			Position = UDim2.fromOffset(12, 34),
			BackgroundTransparency = 1,
			Parent = section,
		})
		local layout = make("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 6),
			Parent = holder,
		})

		local sectionApi = {}

		function sectionApi:AddParagraph(text)
			make("TextLabel", {
				AutomaticSize = Enum.AutomaticSize.Y,
				Size = UDim2.new(1, 0, 0, 0),
				BackgroundTransparency = 1,
				Font = Enum.Font.Gotham,
				Text = text or "",
				TextWrapped = true,
				TextColor3 = Color3.fromRGB(170, 178, 196),
				TextSize = 12,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Top,
				Parent = holder,
			})
		end

		function sectionApi:AddButton(text, callback)
			local b = make("TextButton", {
				AutoButtonColor = false,
				Size = UDim2.new(1, 0, 0, 30),
				BackgroundColor3 = Color3.fromRGB(31, 35, 46),
				Text = text or "Button",
				Font = Enum.Font.Gotham,
				TextColor3 = Color3.fromRGB(230, 236, 255),
				TextSize = 12,
				Parent = holder,
			})
			round(b, 5)
			b.MouseButton1Click:Connect(function()
				if callback then
					callback()
				end
			end)
		end

		return sectionApi
	end

	local function selectTab()
		if self.ActiveTab then
			self.ActiveTab.Page.Visible = false
			self.ActiveTab.Button.BackgroundColor3 = Color3.fromRGB(24, 24, 30)
			self.ActiveTab.Button.TextColor3 = Color3.fromRGB(185, 195, 215)
		end
		self.ActiveTab = tab
		tab.Page.Visible = true
		tab.Button.BackgroundColor3 = Color3.fromRGB(37, 49, 72)
		tab.Button.TextColor3 = Color3.fromRGB(235, 242, 255)
	end

	button.MouseButton1Click:Connect(selectTab)
	table.insert(self.Tabs, tab)
	if #self.Tabs == 1 then
		selectTab()
	end
	return tab
end

return AuroraUI
