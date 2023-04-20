if shared.Terminus then return shared.Terminus end

local PlayerService = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Me = PlayerService.LocalPlayer
local Mouse = Me:GetMouse()
local Gui = Instance.new("ScreenGui")

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

local Terminals = {}
local Events = {}
local Terminus = {}
shared.Terminus = Terminus

function Terminus:Destroy()
	Gui:Destroy()
	shared.Termimus = nil
	
	for _, event in pairs (Events) do
		event:Disconnect()
	end
	
	for _, terminal in pairs (Terminals) do
		task.spawn(function()
			terminal:OnClose()
		end)
	end
	
	table.clear(Terminals)
	table.clear(Events)
end

function Terminus:newStyle(properties)
	return Style:new(properties)
end

local Terminal = {
	Style = Style:new()
}
Terminal.__index = Terminal

function Terminus:new(name, properties)
	assert(Terminals[name] == nil, name .. " already exists")

	local terminal = setmetatable(properties or {}, Terminal)
	Terminals[name] = terminal

	local window = Instance.new("Frame")
	window.Name = name
	window.BackgroundTransparency = 1
	window.Size = UDim2.new(1, 0, 1, 0)
	window.Parent = Gui.Frame.Content
	window.Visible = false
	
	local button = terminal:CreateTextButton(Gui.Frame.Sidebar, {Selectable = true, Style = terminal.Style})
	button.Instance.Text = name
	
	terminal.Window = window
	terminal.Button = button
	
	function button:OnSelected(state)
		terminal:Toggle(state)
	end

	return terminal
end

function Terminal:IsMouseOnTop()
	local mousePos = Vector2.new(Mouse.X, Mouse.Y)
	local windowPos = Gui.AbsolutePosition
	local windowSize = Gui.AbsoluteSize
	
	if mousePos.X >= windowPos.X and mousePos.X <= windowPos.X + windowSize.X then return true end
	if mousePos.Y >= windowPos.Y and mousePos.Y <= windowPos.Y + windowSize.Y then return true end
	
	return false
end

function Terminal:Toggle(state)
	if state == nil then state = not self.Window.Visible end
	
	self.Window.Visible = state
	if not state then return end
	
	for _, terminal in pairs (Terminals) do
		if terminal == self then continue end
		
		terminal.Window.Visible = false
	end
end

function Terminal:OnClose()
	
end

local Switch = {
	Style = Style:new(),
	State = false,
	AnchorPoint = Vector2.new(0, 0),
	Position = UDim2.new(0, 0, 0, 0)
}
Switch.__index = Switch

function Terminal:CreateSwitch(parent, properties)
	local object = setmetatable(properties or {}, Switch)

	local frame = Instance.new("Frame")
	local dot = Instance.new("Frame")
	local uicorner = Instance.new("UICorner")
	local uicorner_2 = Instance.new("UICorner")
	local button = Instance.new("TextButton")

	--Properties:

	frame.Name = "Switch"
	frame.AnchorPoint = object.AnchorPoint
	frame.Parent = parent or self.Window
	frame.BackgroundColor3 = object.Style.BackgroundColor
	frame.BorderSizePixel = 0
	frame.Size = UDim2.new(0, 40, 0, 20)
	frame.Position = object.Position

	dot.Name = "Dot"
	dot.Parent = frame
	dot.BackgroundColor3 = object.Style.IdleColor
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

	object.Instance = frame
	
	local proxy = setmetatable({}, {
		__call = function() return object end,
		__index = object,
		__newindex = function(_, k, v)
			object[k] = v

			if k == "AnchorPoint" then
				frame.AnchorPoint = v
			elseif k == "Position" then
				frame.Position = v
			end
		end,

	})
	
	if object.Style.Effects then
		button.MouseEnter:Connect(function()
			TweenService:Create(dot, TweenInfo.new(object.Style.SlideTime, object.Style.EasingStyle, Enum.EasingDirection.In), {
				BackgroundColor3 = object.Style.IdleColor:Lerp(Color3.new(1,1,1), object.Style.Brighten)
			}):Play()
			
			TweenService:Create(frame, TweenInfo.new(object.Style.SlideTime, object.Style.EasingStyle, Enum.EasingDirection.In), {
				BackgroundColor3 = (object.State and object.Style.ActiveColor or object.Style.BackgroundColor):Lerp(Color3.new(1,1,1), object.Style.Brighten)
			}):Play()
		end)

		button.MouseLeave:Connect(function()
			TweenService:Create(dot, TweenInfo.new(object.Style.SlideTime, object.Style.EasingStyle, Enum.EasingDirection.Out), {
				BackgroundColor3 = object.Style.IdleColor
			}):Play()
			
			TweenService:Create(frame, TweenInfo.new(object.Style.SlideTime, object.Style.EasingStyle, Enum.EasingDirection.Out), {
				BackgroundColor3 = (object.State and object.Style.ActiveColor or object.Style.BackgroundColor)
			}):Play()
		end)
	end

	button.Activated:Connect(function()
		proxy:Toggle()
	end)
	
	proxy:Toggle(object.State)
	
	return proxy
end

function Switch:Toggle(state)
	if state == nil then state = not self.State end
	
	if state then
		self.Instance.Dot:TweenPosition(UDim2.new(0, 20, 0, 0), Enum.EasingDirection.In, self.Style.EasingStyle, self.Style.SlideTime, true)
		TweenService:Create(self.Instance, TweenInfo.new(self.Style.SlideTime, self.Style.EasingStyle, Enum.EasingDirection.In), {["BackgroundColor3"] = self.Style.ActiveColor}):Play()
	else
		self.Instance.Dot:TweenPosition(UDim2.new(0, 0, 0, 0), Enum.EasingDirection.Out, self.Style.EasingStyle, self.Style.SlideTime, true)
		TweenService:Create(self.Instance, TweenInfo.new(self.Style.SlideTime, self.Style.EasingStyle, Enum.EasingDirection.In), {["BackgroundColor3"] = self.Style.BackgroundColor}):Play()
	end
	
	if self.State == state then return end
	self.State = state

	self:OnChanged(state)
end

function Switch:OnChanged(value)

end

local Slider = {
	Style = Style:new(),
	ShowTip = true,
	Minimum = 1,
	Maximum = 10,
	Fill = true,
	Value = 1,
	Size = UDim2.new(1, 0, 0, 20),
	AnchorPoint = Vector2.new(0, 0),
	Position = UDim2.new(0, 0, 0, 0)
}
Slider.__index = Slider

function Terminal:CreateSlider(parent, properties)
	local object = setmetatable(properties or {}, Slider)

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
	window.AnchorPoint = object.AnchorPoint
	window.Position = object.Position
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
	leftBar.BackgroundColor3 = object.Fill and object.Style.ActiveColor or object.Style.BackgroundColor
	leftBar.AnchorPoint = Vector2.new(0, 0.5)
	leftBar.BorderSizePixel = 0
	leftBar.Position = UDim2.new(0, 0, 0.5, 0)
	leftBar.Size = UDim2.new(0.5, 0, 0, 6)

	uicorner.CornerRadius = UDim.new(0, 3)
	uicorner.Parent = leftBar

	rightBar.Name = "RightBar"
	rightBar.Parent = container
	rightBar.BackgroundColor3 = object.Style.BackgroundColor
	rightBar.AnchorPoint = Vector2.new(0, 0.5)
	rightBar.BorderSizePixel = 0
	rightBar.Position = UDim2.new(0.5, 0, 0.5, 0)
	rightBar.Size = UDim2.new(0.5, 0, 0, 6)

	uicorner_2.CornerRadius = UDim.new(0, 3)
	uicorner_2.Parent = rightBar

	dot.Name = "Dot"
	dot.Parent = container
	dot.AnchorPoint = Vector2.new(0.5, 0.5)
	dot.BackgroundColor3 = object.Style.IdleColor
	dot.Position = UDim2.new(0.5, 0, 0.5, 0)
	dot.Size = UDim2.new(0, 20, 0, 20)

	uicorner_3.CornerRadius = UDim.new(0, 10)
	uicorner_3.Parent = dot

	tip.Name = "Tip"
	tip.Parent = container
	tip.AnchorPoint = Vector2.new(0.5, 0)
	tip.BackgroundColor3 = object.Style.IdleColor
	tip.Position = UDim2.new(0.5, 0, 0, 0)
	tip.Size = UDim2.new(0, 20, 0, 16)
	tip.Visible = false
	tip.FontFace = object.Style.FontFace
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
	button.FontFace = object.Style.FontFace
	button.Text = ""
	button.TextColor3 = Color3.fromRGB(0, 0, 0)
	
	object.Instance = window
	
	local proxy = setmetatable({}, {
		__call = function() return object end,
		__index = object,
		__newindex = function(_, k, v)
			object[k] = v

			if k == "AnchorPoint" then
				window.AnchorPoint = v
			elseif k == "Position" then
				window.Position = v
			elseif k == "Size" then
				window.Size = v
			end
		end,

	})
	
	if object.Style.Effects then
		button.MouseEnter:Connect(function()
			TweenService:Create(dot, TweenInfo.new(object.Style.SlideTime, object.Style.EasingStyle, Enum.EasingDirection.In), {
				BackgroundColor3 = object.Style.IdleColor:Lerp(Color3.new(1,1,1), object.Style.Brighten)
			}):Play()
			
			TweenService:Create(leftBar, TweenInfo.new(object.Style.SlideTime, object.Style.EasingStyle, Enum.EasingDirection.In), {
				BackgroundColor3 = (object.Fill and object.Style.ActiveColor or object.Style.BackgroundColor):Lerp(Color3.new(1,1,1), object.Style.Brighten)
			}):Play()
			
			TweenService:Create(rightBar, TweenInfo.new(object.Style.SlideTime, object.Style.EasingStyle, Enum.EasingDirection.In), {
				BackgroundColor3 = object.Style.BackgroundColor:Lerp(Color3.new(1,1,1), object.Style.Brighten)
			}):Play()
		end)

		button.MouseLeave:Connect(function()
			TweenService:Create(dot, TweenInfo.new(object.Style.SlideTime, object.Style.EasingStyle, Enum.EasingDirection.Out), {
				BackgroundColor3 = object.Style.IdleColor
			}):Play()
			
			TweenService:Create(leftBar, TweenInfo.new(object.Style.SlideTime, object.Style.EasingStyle, Enum.EasingDirection.In), {
				BackgroundColor3 = (object.Fill and object.Style.ActiveColor or object.Style.BackgroundColor)
			}):Play()
			
			TweenService:Create(rightBar, TweenInfo.new(object.Style.SlideTime, object.Style.EasingStyle, Enum.EasingDirection.In), {
				BackgroundColor3 = object.Style.BackgroundColor
			}):Play()
		end)
	end

	button.MouseButton1Down:Connect(function()
		if object.ShowTip then
			tip.Visible = true
		end
		
		local startPos = container.AbsolutePosition
		local totalLength = container.AbsoluteSize.X
		
		while UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
			local mousePos = Vector2.new(Mouse.X, Mouse.Y)
			local offset = mousePos - startPos

			local x = math.clamp(offset.X, 0, totalLength)
			local alpha = x / totalLength
			local value = math.clamp(math.round(alpha * object.Maximum), object.Minimum, object.Maximum)
			
			proxy:SetValue(value)
			
			RunService.Stepped:Wait()
		end
		
		tip.Visible = false
	end)
	
	proxy:SetValue(object.Value)

	return proxy
end

function Slider:SetValue(value)
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
	
	if self.Value == value then return end
	
	self.Value = value

	task.spawn(function()
		self:OnChanged(value)
	end)
end

function Slider:OnChanged(value)
	
end

local Dropdown = {
	Style = Style:new(),
	Padding = 2,
	MaxDisplay = 3,
	CloseOnSelect = true,
	MultiSelect = true,
	IsOpen = false,
	Title = "Dropdown"
}
Dropdown.__index = Dropdown

function Terminal:CreateDropdown(parent, properties)
	local object = setmetatable(properties or {}, Dropdown)
	object.Selected = object.Selected or {}
	object.Buttons = {}
	object.Items = object.Items or {}
	
	local window = Instance.new("Frame")
	local arrow = Instance.new("ImageLabel")
	local header = Instance.new("TextLabel")
	local scroll = Instance.new("ScrollingFrame")
	local button = Instance.new("TextButton")
	local uicorner = Instance.new("UICorner")
	local sort = Instance.new("UIListLayout")
	local uicorner_2 = Instance.new("UICorner")

	--Properties:

	window.Name = "Dropdown"
	window.Parent = parent or self.Window
	window.BackgroundColor3 = object.Style.BackgroundColor
	window.Size = UDim2.new(1, 0, 0, 20)
	window.ClipsDescendants = true
	window.ZIndex = 3

	arrow.Name = "Arrow"
	arrow.Parent = window
	arrow.BackgroundTransparency = 1.000
	arrow.Position = UDim2.new(1, -22, 0, 2)
	arrow.Rotation = 90.000
	arrow.Size = UDim2.new(0, 16, 0, 16)
	arrow.Image = "rbxassetid://12610560290"
	arrow.ImageColor3 = object.Style.IdleColor

	header.Name = "Header"
	header.Parent = window
	header.BackgroundTransparency = 1.000
	header.Position = UDim2.new(0, 5, 0, 0)
	header.Size = UDim2.new(1, -30, 0, 20)
	header.FontFace = object.Style.FontFace
	header.Text = object.Title
	header.TextColor3 = Color3.fromRGB(240, 240, 240)
	header.TextSize = 14.000
	header.TextXAlignment = Enum.TextXAlignment.Left

	scroll.Name = "Scroll"
	scroll.Parent = window
	scroll.Active = true
	scroll.BackgroundTransparency = 1.000
	scroll.BorderSizePixel = 0
	scroll.Position = UDim2.new(0, 1, 0, 20 + object.Padding)
	scroll.Size = UDim2.new(1, -2, 1, -object.Padding)
	scroll.ScrollBarThickness = 4
	scroll.Visible = false
	scroll.CanvasSize = UDim2.new(0, 0, 0, 20 + (#object.Items * (20 + object.Padding)))
	
	button.Name = "Button"
	button.Parent = window
	button.BackgroundTransparency = 1.000
	button.Size = UDim2.new(1, 0, 0, 20)
	button.Text = ""
	button.TextColor3 = Color3.fromRGB(0, 0, 0)
	button.TextSize = 14.000
	
	sort.Padding = UDim.new(0, object.Padding)
	sort.Name = "Sort"
	sort.Parent = scroll
	
	uicorner_2.CornerRadius = UDim.new(0, object.Style.CornerRadius)
	uicorner_2.Parent = window
	
	object.Instance = window
	
	local proxy = setmetatable({}, {
		__call = function() return object end,
		__index = object,
		__newindex = function(_, k, v)
			object[k] = v

			if k == "Title" then
				header.Text = v
			end
		end
	})
	
	if object.Style.Effects then
		button.MouseEnter:Connect(function()
			TweenService:Create(
				window, TweenInfo.new(object.Style.SlideTime, object.Style.EasingStyle, Enum.EasingDirection.In), {
					BackgroundColor3 = object.Style.BackgroundColor:Lerp(Color3.new(1,1,1), object.Style.Brighten)
				}
			):Play()
		end)

		button.MouseLeave:Connect(function()
			TweenService:Create(
				window, TweenInfo.new(object.Style.SlideTime, object.Style.EasingStyle, Enum.EasingDirection.Out), {BackgroundColor3 = object.Style.BackgroundColor}
			):Play()
		end)
	end
	
	button.Activated:Connect(function()
		proxy:Toggle()
	end)
	
	for _, item in pairs (object.Items) do
		proxy:AddItem(item)
	end
	
	proxy:Toggle(object.IsOpen)
	
	return proxy
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
	local scroll = self.Instance.Scroll
	
	local itemButton = Instance.new("TextButton")
	itemButton.AutoButtonColor = false
	itemButton.BackgroundColor3 = self:IsSelected(item) and self.Style.ActiveColor or self.Style.BackgroundColor
	itemButton.BorderSizePixel = 1
	itemButton.Size = UDim2.new(1, -4, 0, 20)
	itemButton.Name = item
	itemButton.FontFace = self.Style.FontFace
	itemButton.Text = item
	itemButton.TextSize = 14
	itemButton.TextWrapped = true
	itemButton.TextColor3 = Color3.fromRGB(240, 240, 240)
	itemButton.Parent = scroll

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
	
	scroll.CanvasSize = UDim2.new(0, 0, 0, 20 + (#self.Items * (20 + self.Padding)))
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
	
	local scroll = self.Instance.Scroll
	
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
	scroll.CanvasSize = UDim2.new(0, 0, 0, 20 + (#self.Items * (20 + self.Padding)))
end

function Dropdown:Toggle(state)
	if state == nil then
		state = not self.IsOpen
	end
	
	self.IsOpen = state
	
	local instance = self.Instance
	local arrow = instance.Arrow
	local scroll = instance.Scroll
	
	if state then
		TweenService:Create(
			arrow, TweenInfo.new(self.Style.SlideTime, self.Style.EasingStyle, Enum.EasingDirection.In), {
				["Rotation"] = -90,
				["ImageColor3"] = self.Style.ActiveColor
			}
		):Play()
		
		local size = nil
		if self.MaxDisplay < #self.Items then
			size = UDim2.new(1, 0, 0, 20 + self.Padding + (math.clamp(#self.Items, 1, self.MaxDisplay) * (20 + self.Padding)))
			
		else
			size = UDim2.new(1, 0, 0, 20 + self.Padding + scroll.Sort.AbsoluteContentSize.Y)
		end
		local dropTween = TweenService:Create(instance, TweenInfo.new(self.Style.SlideTime, self.Style.EasingStyle, Enum.EasingDirection.In),
			{["Size"] = size}
		)
		dropTween:Play()
		
		dropTween.Completed:Connect(function(playbackState)
			if playbackState ~= Enum.PlaybackState.Completed then return end
			
			self:OnToggleDone()
		end)

		scroll.Visible = true
	else
		TweenService:Create(
			arrow, TweenInfo.new(self.Style.SlideTime, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
				["Rotation"] = 90,
				["ImageColor3"] = self.Style.IdleColor
			}
		):Play()
		
		local dropTween = TweenService:Create(instance, TweenInfo.new(self.Style.SlideTime, self.Style.EasingStyle, Enum.EasingDirection.In),
			{["Size"] = UDim2.new(1, 0, 0, 20)}
		)
		dropTween:Play()

		dropTween.Completed:Connect(function(playbackState)
			if playbackState ~= Enum.PlaybackState.Completed then return end
			
			scroll.Visible = false
			self:OnToggleDone()
		end)
	end
	
	task.spawn(function()
		self:OnToggleStart(state)
	end)
end

function Dropdown:OnToggleStart(state)

end

function Dropdown:OnToggleDone(state)
	
end

function Dropdown:OnSelected(value)
	if value == nil then
		self.Title = "Nothing selected"
		return
	end
	
	if self.MultiSelect then
		self.Title = table.concat(value, ", ")
	else
		self.Title = value
	end
end

local TextField = {
	Style = Style:new(),
	NumbersOnly = false,
	Size = UDim2.new(1, 0, 0, 20),
	Position = UDim2.new(0, 0, 0, 0),
	AnchorPoint = Vector2.new(0, 0),
	Text = "",
	
}
TextField.__index = TextField

function Terminal:CreateTextField(parent, properties)
	local object = setmetatable(properties or {}, TextField)
	
	local function formatText(text)
		if object.NumbersOnly then
			local i = string.len(text)

			while i > 0 do
				local char = string.sub(text, i, i)
				if not tonumber(char) then
					text = string.sub(text, 1, i - 1) .. string.sub(text, i + 1)
				end
				i = i - 1
			end
		end

		return text
	end
	
	local box = Instance.new("TextBox")
	box.AnchorPoint = object.AnchorPoint
	box.BackgroundColor3 = object.Style.BackgroundColor
	box.Size = object.Size
	box.Position = object.Position
	box.FontFace = object.Style.FontFace
	box.TextColor3 = Color3.fromRGB(240, 240, 240)
	box.TextWrapped = true
	box.ClearTextOnFocus = object.ClearOnFocus
	box.TextSize = 14
	box.Text = formatText(object.Text)
	box.Parent = parent or self.Window
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, object.Style.CornerRadius)
	corner.Parent = box
	
	object.Instance = box
	
	local proxy = setmetatable({}, {
		__call = function() return object end,
		__index = object,
		__newindex = function(_, k, v)
			if k ~= "Text" then
				object[k] = v
			end

			if k == "Text" then
				local formatted = formatText(v)
				box.Text = formatted
				object.Text = formatted
			elseif k == "Size" then
				box.Size = v
			elseif k == "Position" then
				box.Position = v
			elseif k == "AnchorPoint" then
				box.AnchorPoint = v
			end
		end,
	})
	
	if object.Style.Effects then
		box.MouseEnter:Connect(function()
			TweenService:Create(box, TweenInfo.new(object.Style.SlideTime, object.Style.EasingStyle, Enum.EasingDirection.In), {
				BackgroundColor3 = object.Style.BackgroundColor:Lerp(Color3.new(1,1,1), object.Style.Brighten)
			}):Play()
		end)
		
		box.MouseLeave:Connect(function()
			TweenService:Create(box, TweenInfo.new(object.Style.SlideTime, object.Style.EasingStyle, Enum.EasingDirection.Out), {
				BackgroundColor3 = object.Style.BackgroundColor
			}):Play()
		end)
	end
	
	box:GetPropertyChangedSignal("Text"):Connect(function()
		local text = formatText(box.Text)
		box.Text = text
		proxy.Text = text
		proxy:OnChanged(text)
	end)
	
	return proxy
end

function TextField:OnChanged(value)
	
end

function TextField:Trim()
	local original = self.Text
	local length = string.len(original)
	local text = ""
	
	for i = 1, length do
		local at = string.sub(original, i, i)
		if at == " " then continue end
		
		text = text .. at
	end
	
	return text
end

local TextButton = {
	Style = Style:new(),
	Splash = true,
	Selectable = true,
	Selected = false,
	Text = "Button",
	Size = UDim2.new(1, 0, 0, 26),
	Position = UDim2.new(0, 0, 0, 0),
	AnchorPoint = Vector2.new(0, 0)
}
TextButton.__index = TextButton

function Terminal:CreateTextButton(parent, properties)
	local object = setmetatable(properties or {}, TextButton)
	
	local button = Instance.new("TextButton")
	button.BackgroundColor3 = object.Selected and object.Style.ActiveColor or object.Style.BackgroundColor
	button.Size = UDim2.new(1, 0, 0, 26)
	button.FontFace = object.Style.FontFace
	button.AutoButtonColor = false
	button.TextSize = 14
	button.Text = object.Text
	button.TextColor3 = Color3.fromRGB(240, 240, 240)
	button.ClipsDescendants = true
	button.Parent = parent or self.Window
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, object.Style.CornerRadius)
	corner.Parent = button
	
	object.Instance = button
	
	local proxy = setmetatable({}, {
		__call = function() return object end,
		__index = object,
		__newindex = function(_, k, v)
			object[k] = v

			if k == "Text" then
				button.Text = v
			elseif k == "Size" then
				button.Size = v
			elseif k == "Position" then
				button.Position = v
			elseif k == "AnchorPoint" then
				button.AnchorPoint = v
			end
		end,
	})
	
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
		task.spawn(function()
			if object.Selectable then
				proxy:Toggle()
			else
				proxy:OnActivated()
			end
		end)
		
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
	
	if object.Selectable then
		proxy:Toggle(object.Selected)
	end
	
	return proxy
end

function TextButton:Toggle(state)
	if not self.Selectable then return end
	if state == nil then state = not self.Selected end
	
	if state then
		TweenService:Create(self.Instance, TweenInfo.new(self.Style.SlideTime, self.Style.EasingStyle, Enum.EasingDirection.In), {
			BackgroundColor3 = self.Style.ActiveColor
		}):Play()
	else
		TweenService:Create(self.Instance, TweenInfo.new(self.Style.SlideTime, self.Style.EasingStyle, Enum.EasingDirection.Out), {
			BackgroundColor3 = self.Style.BackgroundColor
		}):Play()
	end
	
	if self.Selected == state then return end
	self.Selected = state
	
	task.spawn(function()
		self:OnSelected(state)
	end)
end

function TextButton:OnSelected(state)
	
end

function TextButton:OnActivated()
	
end

local TextLabel = {
	Style = Style:new(),
	Text = "",
	Size = UDim2.new(1, 0, 0, 20),
	Position = UDim2.new(0, 0, 0, 0),
	AnchorPoint = Vector2.new(0, 0),
	TextColor = Color3.fromRGB(240, 240, 240)
}
TextLabel.__index = TextLabel

function Terminal:CreateTextLabel(parent, properties)
	local object = setmetatable(properties or {}, TextLabel)
	
	local label = Instance.new("TextButton")
	label.AnchorPoint = object.AnchorPoint
	label.BackgroundColor3 = object.Style.BackgroundColor
	label.Size = object.Size
	label.Position = object.Position
	label.FontFace = object.Style.FontFace
	label.AutoButtonColor = false
	label.Text = object.Text
	label.TextSize = 14
	label.TextColor3 = object.TextColor
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

	return setmetatable({}, {
		__call = function() return object end,
		__index = object,
		__newindex = function(_, k, v)
			object[k] = v

			if k == "Text" then
				label.Text = v
			elseif k == "Size" then
				label.Size = v
			elseif k == "TextColor" then
				label.TextColor3 = v
			elseif k == "Position" then
				label.Position = v
			elseif k == "AnchorPoint" then
				label.AnchorPoint = v
			end
		end,
	})
end

local Row = {
	Style = Style:new(),
	Size = UDim2.new(1, 0, 1, 0),
	Layout = {},
	Position = UDim2.new(0, 0, 0, 0),
	AnchorPoint = Vector2.new(0, 0),
}
Row.__index = Row

function Terminal:CreateRow(parent, properties)
	local object = setmetatable(properties or {}, Row)
	object.Items = object.Items or {}
	object.Columns = {}
	
	local container = Instance.new("TextButton")
	container.AnchorPoint = object.AnchorPoint
	container.BackgroundColor3 = object.Style.BackgroundColor
	container.Size = object.Size
	container.Position = object.Position
	container.AutoButtonColor = false
	container.Text = ""
	container.ClipsDescendants = true
	container.Parent = parent or self.Window

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, object.Style.CornerRadius)
	corner.Parent = container
	
	local sort = Instance.new("UIListLayout")
	sort.FillDirection = Enum.FillDirection.Horizontal
	sort.Padding = UDim.new(0, 0)
	sort.Parent = container

	object.Instance = container

	if object.Style.Effects then
		container.MouseEnter:Connect(function()
			TweenService:Create(container, TweenInfo.new(object.Style.SlideTime, object.Style.EasingStyle, Enum.EasingDirection.In), {
				BackgroundColor3 = object.Style.BackgroundColor:Lerp(Color3.new(1,1,1), object.Style.Brighten)
			}):Play()
		end)

		container.MouseLeave:Connect(function()
			TweenService:Create(container, TweenInfo.new(object.Style.SlideTime, object.Style.EasingStyle, Enum.EasingDirection.Out), {
				BackgroundColor3 = object.Style.BackgroundColor
			}):Play()
		end)
	end
	
	local amountItems = #object.Items
	if #object.Layout ~= amountItems then
		object.Layout = {}
		
		for i = 1, amountItems do
			object.Layout[i] = 1 / amountItems
		end
	end
	
	for i, item in pairs (object.Items) do
		local width = object.Layout[i]
		local column = Instance.new("Frame")
		object.Columns[i] = column
		
		column.BackgroundTransparency = 1
		column.Name = i
		column.Size = UDim2.new(width, 0, 1, 0)
		column.Parent = container
		
		if typeof(item) == "Instance" then
			item.Parent = column
		elseif typeof(item) == "table" then
			item.Instance.Parent = column
		end
	end
	
	return setmetatable({}, {
		__call = function() return object end,
		__index = object,
		__newindex = function(_, k, v)
			object[k] = v

			if k == "Size" then
				container.Size = v
			elseif k == "Position" then
				container.Position = v
			elseif k == "AnchorPoint" then
				container.AnchorPoint = v
			end
		end,
	})
end

local Line = {
	Style = Style:new(),
	Size = UDim2.new(1, 0, 0, 1),
	Position = UDim2.new(0, 0, 0, 0),
	AnchorPoint = Vector2.new(0, 0),
}
Line.__index = Line

function Terminal:CreateLine(parent, properties)
	local object = setmetatable(properties or {}, Line)
	
	local line = Instance.new("Frame")
	line.AnchorPoint = object.AnchorPoint
	line.BackgroundColor3 = object.Style.IdleColor
	line.BorderSizePixel = 0
	line.Position = object.Position
	line.Size = object.Size
	line.Parent = parent or self.Window
	
	object.Instance = line
	
	return setmetatable({}, {
		__call = function() return object end,
		__index = object,
		__newindex = function(_, k, v)
			object[k] = v

			if k == "Size" then
				line.Size = v
			elseif k == "Position" then
				line.Position = v
			elseif k == "AnchorPoint" then
				line.AnchorPoint = v
			end
		end,
	})
end

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
	buttonBar.Position = UDim2.new(1, -40, 0, 0)
	buttonBar.Size = UDim2.new(0, 40, 1, 0)

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
	title.Size = UDim2.new(1, -50, 1, 0)
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
		Terminus:Destroy()
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

build()

table.insert(Events, UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	
	if input.KeyCode == Enum.KeyCode.RightControl then
		Gui.Enabled = not Gui.Enabled
	end
end))

return Terminus
