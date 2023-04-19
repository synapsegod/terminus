if shared.Terminus then return shared.Terminus end

local PlayerService = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Me = PlayerService.LocalPlayer
local Mouse = Me:GetMouse()
local Gui = Instance.new("ScreenGui")

local function build()
	local frame = Instance.new("Frame")
	local uiCorner = Instance.new("UICorner")
	local topbar = Instance.new("Frame")
	local uiCorner_2 = Instance.new("UICorner")
	local frame_2 = Instance.new("Frame")
	local buttonBar = Instance.new("Frame")
	local uiGridLayout = Instance.new("UIGridLayout")
	local closeButton = Instance.new("Frame")
	local uiCorner_3 = Instance.new("UICorner")
	local frame_4 = Instance.new("Frame")
	local button_2 = Instance.new("TextButton")
	local frame_5 = Instance.new("Frame")
	local title = Instance.new("TextButton")
	local sidebar = Instance.new("ScrollingFrame")
	local uiListLayout = Instance.new("UIListLayout")
	local content = Instance.new("Frame")

	pcall(function()
		syn.protect(Gui)
	end)
	
	Gui.Name = "TERMINUS"
	Gui.Parent = Me:WaitForChild("PlayerGui")
	Gui.ResetOnSpawn = false
	Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

	frame.Parent = Gui
	frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	frame.Position = UDim2.new(0.25, -50, 0.25, 0)
	frame.Size = UDim2.new(0.5, 100, 0.5, 0)
	frame.SizeConstraint = Enum.SizeConstraint.RelativeYY

	uiCorner.CornerRadius = UDim.new(0, 6)
	uiCorner.Parent = frame

	topbar.Name = "Topbar"
	topbar.Parent = frame
	topbar.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
	topbar.Size = UDim2.new(1, 0, 0, 16)

	uiCorner_2.CornerRadius = UDim.new(0, 6)
	uiCorner_2.Parent = topbar

	frame_2.Parent = topbar
	frame_2.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
	frame_2.BorderSizePixel = 0
	frame_2.Position = UDim2.new(0, 0, 1, -6)
	frame_2.Size = UDim2.new(1, 0, 0, 6)

	buttonBar.Name = "ButtonBar"
	buttonBar.Parent = topbar
	buttonBar.BackgroundTransparency = 1.000
	buttonBar.Position = UDim2.new(0.5, 0, 0, 0)
	buttonBar.Size = UDim2.new(0.5, 0, 1, 0)

	uiGridLayout.Parent = buttonBar
	uiGridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
	uiGridLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uiGridLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	uiGridLayout.CellPadding = UDim2.new(0, 0, 0, 0)
	uiGridLayout.CellSize = UDim2.new(0, 32, 1, 0)

	closeButton.Name = "CloseButton"
	closeButton.Parent = buttonBar
	closeButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	closeButton.Position = UDim2.new(1, -32, 0, 0)
	closeButton.Size = UDim2.new(0, 32, 0, 16)

	uiCorner_3.CornerRadius = UDim.new(0, 6)
	uiCorner_3.Parent = closeButton

	frame_4.Parent = closeButton
	frame_4.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	frame_4.BorderSizePixel = 0
	frame_4.Position = UDim2.new(0, 0, 1, -8)
	frame_4.Size = UDim2.new(1, 0, 0, 8)
	
	button_2.Name = "Button"
	button_2.Parent = closeButton
	button_2.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	button_2.BackgroundTransparency = 1.000
	button_2.Size = UDim2.new(1, 0, 1, 0)
	button_2.Font = Enum.Font.SciFi
	button_2.Text = "X"
	button_2.TextColor3 = Color3.fromRGB(240, 240, 240)
	button_2.TextScaled = true
	button_2.TextSize = 14.000
	button_2.TextStrokeColor3 = Color3.fromRGB(240, 240, 240)
	button_2.TextWrapped = true

	frame_5.Parent = closeButton
	frame_5.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	frame_5.BorderSizePixel = 0
	frame_5.Size = UDim2.new(0, 8, 0, 8)

	title.Name = "Title"
	title.Parent = topbar
	title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	title.BackgroundTransparency = 1.000
	title.BorderSizePixel = 0
	title.Position = UDim2.new(0, 5, 0, 0)
	title.Size = UDim2.new(0.5, -5, 1, 0)
	title.Font = Enum.Font.SciFi
	title.Text = "Terminus"
	title.TextColor3 = Color3.fromRGB(0, 0, 0)
	title.TextScaled = true
	title.TextSize = 14.000
	title.TextWrapped = true
	title.TextXAlignment = Enum.TextXAlignment.Left

	sidebar.Name = "Sidebar"
	sidebar.Parent = frame
	sidebar.Active = true
	sidebar.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
	sidebar.BackgroundTransparency = 1.000
	sidebar.BorderSizePixel = 0
	sidebar.Position = UDim2.new(0, 2, 0, 20)
	sidebar.Size = UDim2.new(0, 98, 1, -25)
	sidebar.ScrollBarThickness = 4
	sidebar.CanvasSize = UDim2.new(0, 0, 0, 0)

	uiListLayout.Parent = sidebar
	uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder

	content.Name = "Content"
	content.Parent = frame
	content.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	content.BackgroundTransparency = 1.000
	content.Position = UDim2.new(0, 105, 0, 21)
	content.Size = UDim2.new(1, -110, 1, -26)
	
	button_2.Activated:Connect(function()
		shared.Terminus:Destroy()
	end)
	
	title.MouseButton1Down:Connect(function()
		local absoluteSize = frame.AbsoluteSize
		local dragOffset = Vector2.new(Mouse.X, Mouse.Y) - frame.AbsolutePosition
		
		while UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
			local mousePos = Vector2.new(Mouse.X, Mouse.Y)
			local position = mousePos - dragOffset
			
			frame.Position = UDim2.new(0, position.X, 0, position.Y)
			
			RunService.RenderStepped:Wait()
		end
	end)
end

local Style = {
	ActiveColor = Color3.fromRGB(0, 170, 255),
	IdleColor = Color3.fromRGB(240, 240, 240),
	BackgroundColor = Color3.fromRGB(70, 70, 70),
	SlideTime = 0.25,
	EasingStyle = Enum.EasingStyle.Quad,
	CornerRadius = 4,
	FontFace = Font.new("rbxasset://fonts/families/Jura.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
	Effects = true,
	Brighten = 0.1
}
Style.__index = Style

function Style:new(properties)
	return setmetatable(properties or {}, Style)
end

local Events = {}
local Terminus = {}
shared.Terminus = Terminus

function Terminus:Destroy()
	if not Gui.Parent then return end
	
	Gui:Destroy()
	for _, event in pairs (Events) do
		event:Disconnect()
	end
	
	shared.Termimus = nil
end

function Terminus:newStyle(properties)
	return Style:new(properties)
end


local Terminals = {}
local Terminal = {
	HorizontalAlignment = Enum.HorizontalAlignment.Center,
	VerticalAlignment = Enum.VerticalAlignment.Top,
	Padding = 5,
	Style = Style:new()
}
Terminal.__index = Terminal

function Terminus:new(name, properties)
	assert(Terminals[name] == nil, name .. " already exists")

	local terminal = setmetatable(properties or {}, Terminal)
	Terminals[name] = terminal

	local window = Instance.new("ScrollingFrame")
	window.Name = name
	window.BackgroundTransparency = 1
	window.Size = UDim2.new(1, 0, 1, 0)
	window.CanvasSize = UDim2.new(0, 0, 0, 0)
	window.ScrollBarThickness = 4
	window.Parent = Gui.Frame.Content
	window.Visible = false

	local sorter = Instance.new("UIListLayout", window)
	sorter.FillDirection = Enum.FillDirection.Vertical
	sorter.HorizontalAlignment = terminal.HorizontalAlignment
	sorter.VerticalAlignment = terminal.VerticalAlignment
	sorter.Padding = UDim.new(0, terminal.Padding)
	
	terminal.Window = window
	
	local button = terminal:CreateTextButton(Gui.Frame.Sidebar, {Selectable = true, Style = terminal.Style})
	button.Instance.Text = name
	
	function button:OnSelected(state)
		window.Visible = state
		
		for _, otherTerminal in pairs (Terminals) do
			if otherTerminal == terminal then continue end

			otherTerminal.Window.Visible = not state
		end
	end

	window.ChildAdded:Connect(function(_)
		RunService.Stepped:Wait()

		window.CanvasSize = UDim2.new(0, sorter.AbsoluteContentSize.X, 0, sorter.AbsoluteContentSize.Y)
	end)

	return terminal
end

local Switch = {
	State = false,
	Style = Style:new()
}
Switch.__index = Switch

function Terminal:CreateSwitch(parent, properties)
	local switch = setmetatable(properties or {}, Switch)

	local frame = Instance.new("Frame")
	local dot = Instance.new("Frame")
	local uicorner = Instance.new("UICorner")
	local uicorner_2 = Instance.new("UICorner")
	local button = Instance.new("TextButton")

	--Properties:

	frame.Name = "Switch"
	frame.Parent = parent or self.Window
	frame.BackgroundColor3 = switch.Style.BackgroundColor
	frame.BorderSizePixel = 0
	frame.Size = UDim2.new(0, 40, 0, 20)
	frame.Position = UDim2.new(0, 0, 0, 0)

	dot.Name = "Dot"
	dot.Parent = frame
	dot.BackgroundColor3 = switch.Style.IdleColor
	dot.Size = UDim2.new(0, 20, 0, 20)

	uicorner.CornerRadius = UDim.new(0, 10)
	uicorner.Parent = dot

	uicorner_2.CornerRadius = UDim.new(0, 10)
	uicorner_2.Parent = frame

	button.Name = "Button"
	button.Parent = frame
	button.BackgroundTransparency = 1
	button.Size = UDim2.new(1, 0, 1, 0)
	button.Text = ""

	switch.Instance = frame
	
	if switch.Style.Effects then
		button.MouseEnter:Connect(function()
			TweenService:Create(dot, TweenInfo.new(switch.Style.SlideTime, switch.Style.EasingStyle, Enum.EasingDirection.In), {
				BackgroundColor3 = switch.Style.IdleColor:Lerp(Color3.new(1,1,1), switch.Style.Brighten)
			}):Play()
			
			TweenService:Create(frame, TweenInfo.new(switch.Style.SlideTime, switch.Style.EasingStyle, Enum.EasingDirection.In), {
				BackgroundColor3 = (switch.State and switch.Style.ActiveColor or switch.Style.BackgroundColor):Lerp(Color3.new(1,1,1), switch.Style.Brighten)
			}):Play()
		end)

		button.MouseLeave:Connect(function()
			TweenService:Create(dot, TweenInfo.new(switch.Style.SlideTime, switch.Style.EasingStyle, Enum.EasingDirection.Out), {
				BackgroundColor3 = switch.Style.IdleColor
			}):Play()
			
			TweenService:Create(frame, TweenInfo.new(switch.Style.SlideTime, switch.Style.EasingStyle, Enum.EasingDirection.Out), {
				BackgroundColor3 = (switch.State and switch.Style.ActiveColor or switch.Style.BackgroundColor)
			}):Play()
		end)
	end

	button.Activated:Connect(function()
		switch:Toggle()
	end)

	return switch
end

function Switch:Toggle(state)
	if state == nil then state = not self.State end
	if self.State == state then return end

	self.State = state

	if self.State then
		self.Instance.Dot:TweenPosition(UDim2.new(0, 20, 0, 0), Enum.EasingDirection.In, self.Style.EasingStyle, self.Style.SlideTime, true)
		TweenService:Create(self.Instance, TweenInfo.new(self.Style.SlideTime, self.Style.EasingStyle, Enum.EasingDirection.In), {["BackgroundColor3"] = self.Style.ActiveColor}):Play()
	else
		self.Instance.Dot:TweenPosition(UDim2.new(0, 0, 0, 0), Enum.EasingDirection.Out, self.Style.EasingStyle, self.Style.SlideTime, true)
		TweenService:Create(self.Instance, TweenInfo.new(self.Style.SlideTime, self.Style.EasingStyle, Enum.EasingDirection.In), {["BackgroundColor3"] = self.Style.BackgroundColor}):Play()
	end

	self:OnChanged(self.State)
end

function Switch:OnChanged(value)

end

local Slider = {
	ShowTip = true,
	Minimum = 1,
	Maximum = 10,
	Fill = true,
	Style = Style:new(),
	Value = -1,
}
Slider.__index = Slider

function Terminal:CreateSlider(parent, properties)
	local slider = setmetatable(properties or {}, Slider)

	local window = Instance.new("Frame")
	local container = Instance.new("Frame")
	local leftBar = Instance.new("Frame")
	local uicorner = Instance.new("UICorner")
	local rightBar = Instance.new("Frame")
	local uicorner_2 = Instance.new("UICorner")
	local dot = Instance.new("Frame")
	local uicorner_3 = Instance.new("UICorner")
	local tip = Instance.new("TextLabel")
	local uicorner_4 = Instance.new("UICorner")
	local button = Instance.new("TextButton")

	window.Name = "Slider"
	window.Parent = parent or self.Window
	window.BackgroundTransparency = 1.000
	window.Size = UDim2.new(1, 0, 0, 20)

	container.Name = "Container"
	container.Parent = window
	container.BackgroundTransparency = 1.000
	container.Position = UDim2.new(0, 10, 0, 0)
	container.Size = UDim2.new(1, -20, 1, 0)

	leftBar.Name = "LeftBar"
	leftBar.Parent = container
	leftBar.BackgroundColor3 = slider.Fill and slider.Style.ActiveColor or slider.Style.BackgroundColor
	leftBar.AnchorPoint = Vector2.new(0, 0.5)
	leftBar.BorderSizePixel = 0
	leftBar.Position = UDim2.new(0, 0, 0.5, 0)
	leftBar.Size = UDim2.new(0.5, 0, 0, 6)

	uicorner.CornerRadius = UDim.new(0, 3)
	uicorner.Parent = leftBar

	rightBar.Name = "RightBar"
	rightBar.Parent = container
	rightBar.BackgroundColor3 = slider.Style.BackgroundColor
	rightBar.AnchorPoint = Vector2.new(0, 0.5)
	rightBar.BorderSizePixel = 0
	rightBar.Position = UDim2.new(0.5, 0, 0.5, 0)
	rightBar.Size = UDim2.new(0.5, 0, 0, 6)

	uicorner_2.CornerRadius = UDim.new(0, 3)
	uicorner_2.Parent = rightBar

	dot.Name = "Dot"
	dot.Parent = container
	dot.AnchorPoint = Vector2.new(0.5, 0.5)
	dot.BackgroundColor3 = slider.Style.IdleColor
	dot.Position = UDim2.new(0.5, 0, 0.5, 0)
	dot.Size = UDim2.new(0, 20, 0, 20)

	uicorner_3.CornerRadius = UDim.new(0, 10)
	uicorner_3.Parent = dot

	tip.Name = "Tip"
	tip.Parent = container
	tip.AnchorPoint = Vector2.new(0.5, 0)
	tip.BackgroundColor3 = slider.Style.IdleColor
	tip.Position = UDim2.new(0.5, 0, 0, 0)
	tip.Size = UDim2.new(0, 20, 0, 16)
	tip.Visible = false
	tip.FontFace = slider.Style.FontFace
	tip.Text = ""
	tip.TextColor3 = Color3.fromRGB(0, 0, 0)
	tip.TextSize = 10.000
	tip.ZIndex = 2

	uicorner_4.CornerRadius = UDim.new(0, 4)
	uicorner_4.Parent = tip

	button.Name = "Button"
	button.Parent = container
	button.BackgroundTransparency = 1.000
	button.Size = UDim2.new(1, 0, 1, 0)
	button.FontFace = slider.Style.FontFace
	button.Text = ""
	button.TextColor3 = Color3.fromRGB(0, 0, 0)
	
	if slider.Style.Effects then
		button.MouseEnter:Connect(function()
			TweenService:Create(dot, TweenInfo.new(slider.Style.SlideTime, slider.Style.EasingStyle, Enum.EasingDirection.In), {
				BackgroundColor3 = slider.Style.IdleColor:Lerp(Color3.new(1,1,1), slider.Style.Brighten)
			}):Play()
			
			TweenService:Create(leftBar, TweenInfo.new(slider.Style.SlideTime, slider.Style.EasingStyle, Enum.EasingDirection.In), {
				BackgroundColor3 = (slider.Fill and slider.Style.ActiveColor or slider.Style.BackgroundColor):Lerp(Color3.new(1,1,1), slider.Style.Brighten)
			}):Play()
			
			TweenService:Create(rightBar, TweenInfo.new(slider.Style.SlideTime, slider.Style.EasingStyle, Enum.EasingDirection.In), {
				BackgroundColor3 = slider.Style.BackgroundColor:Lerp(Color3.new(1,1,1), slider.Style.Brighten)
			}):Play()
		end)

		button.MouseLeave:Connect(function()
			TweenService:Create(dot, TweenInfo.new(slider.Style.SlideTime, slider.Style.EasingStyle, Enum.EasingDirection.Out), {
				BackgroundColor3 = slider.Style.IdleColor
			}):Play()
			
			TweenService:Create(leftBar, TweenInfo.new(slider.Style.SlideTime, slider.Style.EasingStyle, Enum.EasingDirection.In), {
				BackgroundColor3 = (slider.Fill and slider.Style.ActiveColor or slider.Style.BackgroundColor)
			}):Play()
			
			TweenService:Create(rightBar, TweenInfo.new(slider.Style.SlideTime, slider.Style.EasingStyle, Enum.EasingDirection.In), {
				BackgroundColor3 = slider.Style.BackgroundColor
			}):Play()
		end)
	end

	button.MouseButton1Down:Connect(function()
		if slider.ShowTip then
			tip.Visible = true
		end
		
		local startPos = container.AbsolutePosition
		local totalLength = container.AbsoluteSize.X
		
		while UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
			local mousePos = Vector2.new(Mouse.X, Mouse.Y)
			local offset = mousePos - startPos

			local x = math.clamp(offset.X, 0, totalLength)
			local alpha = x / totalLength
			local value = math.clamp(math.round(alpha * slider.Maximum), slider.Minimum, slider.Maximum)
			
			slider:SetValue(value)
			
			RunService.Stepped:Wait()
		end
		
		tip.Visible = false
	end)
	
	slider.Instance = window
	slider:SetValue(slider.Minimum)

	return slider
end

function Slider:SetValue(value)
	if self.Value == value then return end
	
	local container = self.Instance.Container
	local dot = container.Dot
	local tip = container.Tip
	local leftBar = container.LeftBar
	local rightBar = container.RightBar
	
	local totalLength = container.AbsoluteSize.X
	local alpha = (value / self.Maximum)
	local x = totalLength * alpha
	
	dot:TweenPosition(UDim2.new(0, x, 0.5, 0), Enum.EasingDirection.Out, self.Style.EasingStyle, self.Style.SlideTime, true)
	tip:TweenPosition(UDim2.new(0, x, 0, -8), Enum.EasingDirection.Out, self.Style.EasingStyle, self.Style.SlideTime, true)
	
	if self.Fill then
		leftBar:TweenSize(UDim2.new(0, x, 0, 6), Enum.EasingDirection.Out, self.Style.EasingStyle, self.Style.SlideTime, true)
		rightBar:TweenSizeAndPosition(UDim2.new(0, totalLength - x, 0, 6), UDim2.new(0, x, 0.5, 0), Enum.EasingDirection.Out, self.Style.EasingStyle, self.Style.SlideTime, true)
	end

	tip.Text = value

	if value ~= self.Value then
		self.Value = value

		task.spawn(function()
			self:OnChanged(value)
		end)
	end
end

function Slider:OnChanged(value)
	
end

local Dropdown = {
	Style = Style:new(),
	Padding = 2,
	CloseOnSelect = true,
	MultiSelect = true,
	IsOpen = false,
}
Dropdown.__index = Dropdown

function Terminal:CreateDropdown(parent, properties)
	local dropdown = setmetatable(properties or {}, Dropdown)
	dropdown.Selected = {}
	dropdown.Buttons = {}
	dropdown.Items = dropdown.Items or {"Item1", "Item2", "Item3"}
	
	local window = Instance.new("Frame")
	local arrow = Instance.new("ImageLabel")
	local header = Instance.new("TextLabel")
	local button = Instance.new("TextButton")
	local drop = Instance.new("Frame")
	local uicorner = Instance.new("UICorner")
	local scroll = Instance.new("ScrollingFrame")
	local sort = Instance.new("UIListLayout")
	local uicorner_2 = Instance.new("UICorner")

	--Properties:

	window.Name = "Dropdown"
	window.Parent = parent or self.Window
	window.BackgroundColor3 = dropdown.Style.BackgroundColor
	window.Size = UDim2.new(1, 0, 0, 20)
	window.ZIndex = 3

	arrow.Name = "Arrow"
	arrow.Parent = window
	arrow.BackgroundTransparency = 1.000
	arrow.Position = UDim2.new(1, -22, 0, 2)
	arrow.Rotation = 90.000
	arrow.Size = UDim2.new(0, 16, 0, 16)
	arrow.Image = "rbxassetid://12610560290"
	arrow.ImageColor3 = dropdown.Style.IdleColor

	header.Name = "Header"
	header.Parent = window
	header.BackgroundTransparency = 1.000
	header.Position = UDim2.new(0, 5, 0, 0)
	header.Size = UDim2.new(1, -30, 0, 20)
	header.FontFace = dropdown.Style.FontFace
	header.Text = "Dropdown"
	header.TextColor3 = Color3.fromRGB(240, 240, 240)
	header.TextSize = 14.000
	header.TextXAlignment = Enum.TextXAlignment.Left

	button.Name = "Button"
	button.Parent = window
	button.BackgroundTransparency = 1.000
	button.Size = UDim2.new(1, 0, 0, 20)
	button.Text = ""
	button.TextColor3 = Color3.fromRGB(0, 0, 0)
	button.TextSize = 14.000

	drop.Name = "Drop"
	drop.Parent = window
	drop.BackgroundColor3 = dropdown.Style.BackgroundColor
	drop.BorderSizePixel = 0
	drop.Position = UDim2.new(0, 0, 0, 25)
	drop.Size = UDim2.new(1, 0, 0, 20)
	drop.Visible = false

	uicorner.CornerRadius = UDim.new(0, dropdown.Style.CornerRadius)
	uicorner.Parent = drop

	scroll.Name = "Scroll"
	scroll.Parent = drop
	scroll.Active = true
	scroll.BackgroundTransparency = 1.000
	scroll.BorderSizePixel = 0
	scroll.Position = UDim2.new(0, 1, 0, 1)
	scroll.Size = UDim2.new(1, -2, 1, -2)
	scroll.ScrollBarThickness = 4
	
	sort.Padding = UDim.new(0, dropdown.Padding)
	sort.Parent = scroll
	
	uicorner_2.CornerRadius = UDim.new(0, dropdown.Style.CornerRadius)
	uicorner_2.Parent = window
	
	dropdown.Instance = window
	
	if dropdown.Style.Effects then
		button.MouseEnter:Connect(function()
			TweenService:Create(
				window, TweenInfo.new(dropdown.Style.SlideTime, dropdown.Style.EasingStyle, Enum.EasingDirection.In), {
					BackgroundColor3 = dropdown.Style.BackgroundColor:Lerp(Color3.new(1,1,1), dropdown.Style.Brighten)
				}
			):Play()
		end)

		button.MouseLeave:Connect(function()
			TweenService:Create(
				window, TweenInfo.new(dropdown.Style.SlideTime, dropdown.Style.EasingStyle, Enum.EasingDirection.Out), {BackgroundColor3 = dropdown.Style.BackgroundColor}
			):Play()
		end)
	end
	
	button.Activated:Connect(function()
		dropdown:Toggle()
	end)
	
	for _, item in pairs (dropdown.Items) do
		dropdown:AddItem(item)
	end
	
	scroll.CanvasSize = UDim2.new(0, 0, 0, sort.AbsoluteContentSize.Y)
	
	return dropdown
end

function Dropdown:Select(item)
	if self.MultiSelect then
		local index = table.find(self.Selected, item)
		if index then
			table.remove(self.Selected, index)
		else
			table.insert(self.Selected, item)
		end
		
		for _, button in pairs (self.Buttons) do
			if button.Name == item then
				if index then
					button.BackgroundColor3 = self.Style.BackgroundColor
				else
					button.BackgroundColor3 = self.Style.ActiveColor
				end
			end
		end
	else
		if self.Selected == item then return end
		
		if self.CloseOnSelect then
			self:Toggle(false)
		end
		
		self.Selected = item
	end
	
	self:OnSelected(self.Selected)
end

function Dropdown:AddItem(item)
	local itemButton = Instance.new("TextButton")
	itemButton.AutoButtonColor = false
	itemButton.BackgroundColor3 = self.Style.BackgroundColor
	itemButton.BorderSizePixel = 1
	itemButton.Size = UDim2.new(1, -4, 0, 20)
	itemButton.Name = item
	itemButton.FontFace = self.Style.FontFace
	itemButton.Text = item
	itemButton.TextSize = 14
	itemButton.TextWrapped = true
	itemButton.TextColor3 = Color3.fromRGB(240, 240, 240)
	itemButton.Parent = self.Instance.Drop.Scroll

	local rounding = Instance.new("UICorner", itemButton)
	rounding.CornerRadius = UDim.new(0, self.Style.CornerRadius)

	table.insert(self.Buttons, itemButton)
	
	if self.Style.Effects then
		itemButton.MouseEnter:Connect(function()
			local isSelected = self:IsSelected(item)
			TweenService:Create(
				itemButton, TweenInfo.new(self.Style.SlideTime, self.Style.EasingStyle, Enum.EasingDirection.In),
				{BackgroundColor3 = (isSelected and self.Style.ActiveColor or self.Style.BackgroundColor):Lerp(Color3.new(1,1,1), self.Style.Brighten)}
			):Play()
		end)

		itemButton.MouseLeave:Connect(function()
			local isSelected = self:IsSelected(item)
			TweenService:Create(
				itemButton, TweenInfo.new(self.Style.SlideTime, self.Style.EasingStyle, Enum.EasingDirection.In),
				{BackgroundColor3 = isSelected and self.Style.ActiveColor or self.Style.BackgroundColor}
			):Play()
		end)
	end

	itemButton.Activated:Connect(function()
		self:Select(item)
	end)
end

function Dropdown:IsSelected(item)
	if self.MultiSelect then
		for _, item2 in pairs (self.Selected) do
			if item2 == item then return true end
		end
	end
	
	return self.Selected == item
end

function Dropdown:RemoveItem(item)
	if not table.find(self.Items, item) then return end
	
	if self:IsSelected(item) then
		self:Select(item)
	end
	
	for i, button in pairs (self.Buttons) do
		if button.Name == item then
			button:Destroy()
			table.remove(self.Buttons, i)
			break
		end
	end
	
	table.remove(self.Items, table.find(self.Items, item))
end

function Dropdown:SetTitle(title)
	self.Instance.Header.Text = title
end

function Dropdown:Toggle(state)
	if state == nil then
		state = not self.IsOpen
	end
	if state == self.IsOpen then return end
	
	self.IsOpen = state
	
	local instance = self.Instance
	local arrow = instance.Arrow
	local drop = instance.Drop
	
	if state then
		TweenService:Create(
			arrow, TweenInfo.new(self.Style.SlideTime, self.Style.EasingStyle, Enum.EasingDirection.In), {
				["Rotation"] = -90,
				["ImageColor3"] = self.Style.ActiveColor
			}
		):Play()
		TweenService:Create(instance, TweenInfo.new(self.Style.SlideTime, self.Style.EasingStyle, Enum.EasingDirection.In), {["Size"] = UDim2.new(1, 0, 0, #self.Items * 20 + 20)}):Play()
		TweenService:Create(drop, TweenInfo.new(self.Style.SlideTime, self.Style.EasingStyle, Enum.EasingDirection.In), {["Size"] = UDim2.new(1, 0, 0, #self.Items * 20)}):Play()

		drop.Visible = true
	else
		TweenService:Create(instance, TweenInfo.new(self.Style.SlideTime, self.Style.EasingStyle, Enum.EasingDirection.In), {["Size"] = UDim2.new(1, 0, 0, 20)}):Play()
		
		TweenService:Create(
			arrow, TweenInfo.new(self.Style.SlideTime, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
				["Rotation"] = 90,
				["ImageColor3"] = self.Style.IdleColor
			}
		):Play()
		
		local dropTween = TweenService:Create(drop, TweenInfo.new(self.Style.SlideTime, self.Style.EasingStyle, Enum.EasingDirection.In), {["Size"] = UDim2.new(1, 0, 0, 0)})
		dropTween:Play()

		dropTween.Completed:Connect(function(playbackState)
			if playbackState == Enum.PlaybackState.Completed then
				drop.Visible = false
			end
		end)
	end
end

function Dropdown:OnSelected(value)
	if value == nil then
		self:SetTitle("Nothing selected")
		return
	end
	
	if self.MultiSelect then
		self:SetTitle(table.concat(value, ", "))
	else
		self:SetTitle(value)
	end
end

local TextField = {
	NumbersOnly = false,
	Style = Style:new(),
	Value = ""
}
TextField.__index = TextField

function Terminal:CreateTextField(parent, properties)
	local field = setmetatable(properties or {}, TextField)
	
	local box = Instance.new("TextBox")
	box.BackgroundColor3 = field.Style.BackgroundColor
	box.Size = UDim2.new(1, 0, 0, 20)
	box.FontFace = field.Style.FontFace
	box.TextColor3 = Color3.fromRGB(240, 240, 240)
	box.TextWrapped = true
	box.ClearTextOnFocus = field.ClearOnFocus
	box.TextSize = 14
	box.Text = ""
	box.Parent = parent or self.Window
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, field.Style.CornerRadius)
	corner.Parent = box
	
	if field.Style.Effects then
		box.MouseEnter:Connect(function()
			TweenService:Create(box, TweenInfo.new(field.Style.SlideTime, field.Style.EasingStyle, Enum.EasingDirection.In), {
				BackgroundColor3 = field.Style.BackgroundColor:Lerp(Color3.new(1,1,1), field.Style.Brighten)
			}):Play()
		end)
		
		box.MouseLeave:Connect(function()
			TweenService:Create(box, TweenInfo.new(field.Style.SlideTime, field.Style.EasingStyle, Enum.EasingDirection.Out), {
				BackgroundColor3 = field.Style.BackgroundColor
			}):Play()
		end)
	end
	
	box:GetPropertyChangedSignal("Text"):Connect(function()
		local text = box.Text
		
		if field.NumbersOnly then
			local i = string.len(text)
			
			while i > 0 do
				local char = string.sub(text, i, i)
				if not tonumber(char) then
					text = string.sub(text, 1, i - 1) .. string.sub(text, i + 1)
				end
				i = i - 1
			end
			
			box.Text = text
		end
		
		if text == field.Value then return end
		field.Value = text
		
		field:OnChanged(text)
	end)
	
	box.Text = field.Value
	
	return field
end

function TextField:OnChanged(value)
	
end

local TextButton = {
	Style = Style:new(),
	Splash = true,
	Selectable = true,
	Selected = false
}
TextButton.__index = TextButton

function Terminal:CreateTextButton(parent, properties)
	local object = setmetatable(properties or {}, TextButton)
	
	local button = Instance.new("TextButton")
	button.BackgroundColor3 = object.IsActive and object.Style.ActiveColor or object.Style.BackgroundColor
	button.Size = UDim2.new(1, 0, 0, 26)
	button.FontFace = object.Style.FontFace
	button.AutoButtonColor = false
	button.TextSize = 14
	button.TextColor3 = Color3.fromRGB(240, 240, 240)
	button.ClipsDescendants = true
	button.Parent = parent or self.Window
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, object.Style.CornerRadius)
	corner.Parent = button
	
	object.Instance = button
	
	if object.Style.Effects then
		button.MouseEnter:Connect(function()
			TweenService:Create(button, TweenInfo.new(object.Style.SlideTime, object.Style.EasingStyle, Enum.EasingDirection.In), {
				BackgroundColor3 = (object.Selected and object.Style.ActiveColor or object.Style.BackgroundColor):Lerp(Color3.new(1,1,1), object.Style.Brighten)
			}):Play()
		end)

		button.MouseLeave:Connect(function()
			TweenService:Create(button, TweenInfo.new(object.Style.SlideTime, object.Style.EasingStyle, Enum.EasingDirection.Out), {
				BackgroundColor3 = object.Selected and object.Style.ActiveColor or object.Style.BackgroundColor
			}):Play()
		end)
	end
	
	button.Activated:Connect(function()
		object:Toggle()
		
		if object.Splash then
			local pos = Vector2.new(Mouse.X, Mouse.Y) - button.AbsolutePosition
			local splash = Instance.new("Frame")
			splash.AnchorPoint = Vector2.new(0.5, 0.5)
			splash.BackgroundColor3 = object.IsActive and object.Style.IdleColor or object.Style.ActiveColor
			splash.BackgroundTransparency = 0.5
			splash.Size = UDim2.new(0, 0, 0, 0)
			splash.Position = UDim2.new(0, pos.X, 0, pos.Y)
			splash.Parent = button
			
			local corner = Instance.new("UICorner")
			corner.CornerRadius = UDim.new(0.5, 0)
			corner.Parent = splash
			
			local tween = TweenService:Create(
				splash, TweenInfo.new(object.Style.SlideTime, object.Style.EasingStyle, Enum.EasingDirection.In), {
					Size = UDim2.new(0, 100, 0, 100),
					BackgroundTransparency = 1
				}
			)
			tween:Play()
			tween.Completed:Connect(function()
				splash:Destroy()
				tween:Destroy()
			end)
		end
		
	end)
	
	return object
end

function TextButton:Toggle(state)
	if self.Selectable == false then return end
	if state == nil then state = not self.Selected end
	if self.Selected == state then return end
	
	self.Selected = state
	
	if state then
		TweenService:Create(self.Instance, TweenInfo.new(self.Style.SlideTime, self.Style.EasingStyle, Enum.EasingDirection.In), {
			BackgroundColor3 = self.Style.ActiveColor
		}):Play()
	else
		TweenService:Create(self.Instance, TweenInfo.new(self.Style.SlideTime, self.Style.EasingStyle, Enum.EasingDirection.Out), {
			BackgroundColor3 = self.Style.BackgroundColor
		}):Play()
	end
	
	task.spawn(function()
		self:OnSelected(state)
	end)
end

function TextButton:OnSelected(state)
	
end

local TextLabel = {
	Style = Style:new(),
}
TextLabel.__index = TextLabel

function Terminal:CreateTextLabel(parent, properties)
	local object = setmetatable(properties or {}, TextLabel)
	
	local label = Instance.new("TextButton")
	label.BackgroundColor3 = object.IsActive and object.Style.ActiveColor or object.Style.BackgroundColor
	label.Size = UDim2.new(1, 0, 0, 20)
	label.FontFace = object.Style.FontFace
	label.AutoButtonColor = false
	label.Text = ""
	label.TextSize = 14
	label.TextColor3 = Color3.fromRGB(240, 240, 240)
	label.ClipsDescendants = true
	label.Parent = parent or self.Window

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, object.Style.CornerRadius)
	corner.Parent = label

	object.Instance = label
	
	if object.Style.Effects then
		label.MouseEnter:Connect(function()
			TweenService:Create(label, TweenInfo.new(object.Style.SlideTime, object.Style.EasingStyle, Enum.EasingDirection.In), {
				BackgroundColor3 = object.Style.BackgroundColor:Lerp(Color3.new(1,1,1), object.Style.Brighten)
			}):Play()
		end)

		label.MouseLeave:Connect(function()
			TweenService:Create(label, TweenInfo.new(object.Style.SlideTime, object.Style.EasingStyle, Enum.EasingDirection.Out), {
				BackgroundColor3 = object.Style.BackgroundColor
			}):Play()
		end)
	end
	
	return object
end

function TextLabel:SetText(text)
	self.Instance.Text = text
end

build()

table.insert(Events, UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	
	if input.KeyCode == Enum.KeyCode.RightControl then
		Gui.Enabled = not Gui.Enabled
	end
end))

return Terminus
