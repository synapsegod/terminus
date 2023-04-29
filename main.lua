if shared.Terminus then return shared.Terminus end

local PlayerService = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local Me = PlayerService.LocalPlayer
local Mouse = Me:GetMouse()
local Gui = Instance.new("ScreenGui")
local NotificationFrame = Instance.new("Frame", Gui)
NotificationFrame.BackgroundTransparency = 1
NotificationFrame.Size = UDim2.new(1, 0, 1, 0)
NotificationFrame.ZIndex = 2
NotificationFrame.Name = "Notifications"

local IsSynapse = pcall(function()
	syn.crypt.random(1)
end)

local function CreateProxy(object, __index, __newindex)
	return setmetatable({}, {
		__call = function() return object end,
		__index = object,
		__newindex = __newindex or function(_, k, v)
			assert(k ~= "Instance", "Locked field")
			object[k] = v
		end,
	})
end

--COLLECTION-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local Collection = {}
Collection.__index = Collection

local List = setmetatable({}, Collection)
List.__index = List

local ListForbiddenKeys = {
	"isEmpty", "isNotEmpty", "last", "length", "reversed"
}

local Map = setmetatable({}, Collection)
Map.__index = Map

local MapForbiddenKeys = {
	"isEmpty", "isNotEmpty", "length", "keys", "values", "keyvalues"
}

function Collection:new(data)
	local object = setmetatable({}, self)
	local data = data or {}

	object.__call = function()
		return object
	end

	object.__index = object

	object.__newindex = function(_, key, value)
		if type(value) == "function" then
			object[key] = value
		else
			data[key] = value
		end
	end

	return setmetatable(data, object)
end

function Collection:Clear()
	table.clear(self)
end

function Collection:Concat(separation)
	separation = separation or ", "
	local out = ""

	for key, value in pairs (self) do
		out = out .. tostring(key) .. ":" .. tostring(value) .. separation
	end

	return string.sub(out, 1, string.len(out) - string.len(separation))
end

function Collection:Export()
	local exported = {}
	for key, value in pairs (self) do
		exported[key] = value
	end
	return exported
end

--LIST-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

function List:new(data)
	data = data or {}
	local collection = Collection.new(List, data)

	collection().__index = function(_, key)
		if key == "isEmpty" then
			return #collection == 0
		elseif key == "isNotEmpty" then
			return #collection ~= 0
		elseif key == "first" then
			return collection[1]
		elseif key == "last" then
			return collection[#collection]
		elseif key == "length" then
			return #collection
		elseif key == "reversed" then
			local newList = self:new()

			for i = #collection, 1, -1 do
				newList[i] = collection[i]
			end

			return newList
		end

		return collection()[key]
	end

	collection().__newindex = function(_, key, value)
		assert(not table.find(ListForbiddenKeys, key), "Key forbidden")

		if type(value) == "function" then
			collection()[key] = value
		else
			assert(type(key) == "number", "Key must be a number inside collection: " .. tostring(key))
			rawset(data, key, value)
		end
	end

	collection().__add = function(_, otherList)
		local copy = self:new(table.clone(collection))

		copy:AddAll(table.clone(otherList))

		return copy
	end

	collection().__lt = function(_, otherList)
		return #collection < #otherList
	end

	collection().__le = function(_, otherList)
		return #collection >= #otherList
	end

	return collection
end

function List:Generate(length, generator)
	local list = List:new()

	for i = 1, length do
		list[i] = generator(i)
	end

	return list
end

function List:AsMap()
	local map = Map:new()

	for key, value in pairs (self) do
		map[tostring(key)] = value
	end

	return map
end

function List:Add(value)
	table.insert(self, value)
	
	return self
end

function List:AddAll(values)
	for key, value in pairs (values) do
		table.insert(self, value)
	end
	
	return self
end

function List:Contains(element)
	for key, value in pairs (self) do
		if value == element then return true end
	end

	return false
end

function List:ElementAt(index)
	return self[index]
end

function List:FillRange(start, stop, element)
	for i = start, stop do
		table.insert(self, start + (i - 1), element)
	end
	
	return self
end

function List:ForEach(action)
	for _, v in pairs (self) do
		action(v)
	end
end

function List:IndexOf(element, start)
	start = start or 1

	for i = start, #self do
		if self[i] == element then return i end
	end

	return -1
end

function List:IndexWhere(testFunction, start)
	start = start or 1

	for i = start, #self do
		if testFunction(self[i]) == true then return i end
	end

	return -1
end

function List:Insert(index, element)
	table.insert(self, index, element)
end

function List:Remove(element)
	local index = table.find(self, element)
	if index then table.remove(self, index) return true end

	return false
end

function List:RemoveAt(index)
	local value = self[index]
	table.remove(self, index)

	return value
end

function List:RemoveWhere(checkFunction)
	local i = 1
	while i <= #self do
		if checkFunction(self[i]) == true then
			table.remove(self, i)
			i = i - 1
		end

		i = i + 1
	end

	return self
end

function List:RemoveLast()
	local value = self[#self]

	table.remove(self, #self)

	return value
end

function List:Sort(comparator)
	table.sort(self, comparator)
	
	return self
end

function List:Where(testFunction)
	local passed = List:new()

	for index, value in pairs (self) do
		if testFunction(index, value) == true then
			passed:Add(value)
		end
	end

	return passed
end

function List:FirstWhere(testFunction)
	for index, value in pairs (self) do
		if testFunction(index, value) == true then
			return value
		end
	end
end

function List:Convert(convertFunction)
	local converted = List:new()
	
	for index, value in pairs(self) do
		converted[index] = convertFunction(index, value)
	end
	
	return converted
end

function List:Concat(separation)
	return table.concat(self, separation)
end

--MAP-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

function Map:new(data)
	data = data or {}
	local collection = Collection.new(Map, data)

	local length = 0
	for _, _ in pairs (collection) do length = length + 1 end

	collection().__index = function(_, key)
		if key == "isEmpty" then
			return length == 0
		elseif key == "isNotEmpty" then
			return length ~= 0
		elseif key == "length" then
			return length
		elseif key == "keys" then
			local keys = {}

			for k, _ in pairs (collection) do
				table.insert(keys, k)
			end

			return keys
		elseif key == "values" then
			local values = {}

			for _, v in pairs (collection) do
				table.insert(values, v)
			end

			return values
		elseif key == "keyvalues" then
			local keyvalues = {}

			for k, v in pairs (collection) do
				table.insert(keyvalues, {Key = k, Value = v})
			end

			return keyvalues
		end

		return collection()[key]
	end

	collection().__newindex = function(_, key, value)
		assert(not table.find(MapForbiddenKeys, key), "Key forbidden")

		if type(value) == "function" then
			collection()[key] = value
		else
			if value == nil and rawget(data, key) ~= nil then
				length = length - 1
			elseif value ~= nil and rawget(data, key) == nil then
				length = length + 1
			end

			rawset(data, key, value)
		end
	end

	collection().__add = function(_, otherList)
		local copy = Map:new(table.clone(collection))

		copy:AddAll(otherList)

		return copy
	end

	collection().__lt = function(_, otherList)
		return collection.length < otherList.length
	end

	collection().__le = function(_, otherList)
		return collection.length >= otherList.length
	end

	return collection
end

function Map:ToList()
	local list = List:new()

	for key, value in pairs (self) do
		list:Add(value)
	end

	return list
end

function Map:AddAll(otherMap)
	for key, value in pairs (otherMap) do
		self[key] = value
	end
	
	return self
end

function Map:ContainsKey(key)
	return self[key] ~= nil
end

function Map:ContainsValue(value)
	for _, v in pairs (self) do
		if v == value then return true end
	end

	return false
end

function Map:ForEach(action)
	for i, v in pairs (self) do
		action(i, v)
	end
end

function Map:Map(convertFunction)
	local newMap = Map:new()

	for key, value in pairs (self) do
		newMap[key] = convertFunction(key, value)
	end

	return newMap
end

function Map:FirstWhere(testFunction)
	for k, v in pairs (self) do
		if testFunction(k, v) == true then
			return {Key = k, Value = v}
		end
	end
end

function Map:Where(testFunction)
	local where = Map:new()

	for k, v in pairs (self) do
		if testFunction(k, v) == true then
			where[k] = v
		end
	end

	return where
end

function Map:Remove(value)
	for k, v in pairs (self) do
		if v == value then
			self[k] = nil
			return true
		end
	end

	return false
end

function Map:RemoveWhere(testFunction)
	for k, v in pairs (self) do
		if testFunction(k, v) == true then
			self[k] = nil
		end
	end
	
	return self
end

function Map:PutIfAbsent(key, ifAbsent)
	if self[key] == nil then
		self[key] = ifAbsent()
	end

	return self[key]
end

function Map:Concat(separation, valueSeparation)
	separation = separation or ","
	valueSeparation = valueSeparation or ":"
	local out = ""

	for key, value in pairs (self) do
		out = out .. "{".. tostring(key) .. ":" .. tostring(value) .. "}" .. separation
	end

	return string.sub(out, 1, string.len(out) - string.len(separation))
end

--STYLE-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local Style = {
	ActiveColor = Color3.fromRGB(0, 170, 255),
	IdleColor = Color3.fromRGB(240, 240, 240),
	BackgroundColor = Color3.fromRGB(70, 70, 70),
	SlideTime = 0.25,
	EasingStyle = Enum.EasingStyle.Quad,
	CornerRadius = 4,
	FontFace = Font.fromEnum(Enum.Font.Jura),
	Effects = true,
	Brighten = 0.1,
	SmallTextSize = 10,
	NormalTextSize = 14,
	HeaderTextSize = 18
}
Style.__index = Style

function Style:new(properties)
	return setmetatable(properties or {}, Style)
end

function Style:Clone(properties)
	local copy = Style:new()
	
	for key, value in pairs (self) do
		copy[key] = value
	end
	
	for key, value in pairs (properties or {}) do
		copy[key] = value
	end
	
	return copy
end

local Terminals = {}
local Events = {}
local Terminus = {
	List = List,
	Map = Map,
	Debug = false,
}
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

function Terminus:CreateStyle(properties)
	return Style:new(properties)
end

--TERMINAL-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local TerminalTemporaryParent = Instance.new("Frame", Gui)
TerminalTemporaryParent.Visible = false
TerminalTemporaryParent.Name = "TemporaryParent"
local Terminal = {
	ClassName = "Terminal",
	ScrollContent = false,
	Padding = 5,
	Instance = TerminalTemporaryParent
}
Terminal.__index = Terminal

function Terminus:new(name, properties)
	assert(Terminals[name] == nil, name .. " already exists")

	local object = setmetatable(properties or {}, Terminal)
	object.Style = object.Style or Style:new()
	object.Name = name
	Terminals[name] = object
	
	if object.ScrollContent then
		local window = Instance.new("ScrollingFrame")
		window.Name = name
		window.BackgroundTransparency = 1
		window.Size = UDim2.new(1, 0, 1, 0)
		window.Parent = Gui.Frame.Content
		window.Visible = false
		window.ScrollBarThickness = 4
		window.ScrollBarImageColor3 = object.Style.ActiveColor
		window.ScrollBarImageTransparency = 0
		
		local sort = Instance.new("UIListLayout")
		sort.Padding = UDim.new(0, object.Padding)
		sort.SortOrder = Enum.SortOrder.LayoutOrder
		sort.FillDirection = Enum.FillDirection.Vertical
		sort.HorizontalAlignment = Enum.HorizontalAlignment.Left
		sort.VerticalAlignment = Enum.VerticalAlignment.Top
		sort.Parent = window
		
		object.Instance = window
		
		window.ChildAdded:Connect(function(child)
			child:GetPropertyChangedSignal("Size"):Connect(function()
				window.CanvasSize = UDim2.new(0, 0, 0, sort.AbsoluteContentSize.Y)
			end)
			
			window.CanvasSize = UDim2.new(0, 0, 0, sort.AbsoluteContentSize.Y)
		end)
	else
		local window = Instance.new("Frame")
		window.Name = name
		window.BackgroundTransparency = 1
		window.Size = UDim2.new(1, 0, 1, 0)
		window.Parent = Gui.Frame.Content
		window.Visible = false
		
		object.Instance = window
	end

	object.Button = object:CreateTextButton(Gui.Frame.Sidebar, {
		Style = object.Style:Clone(),
		Text = name,
		Selectable = true,
		Selected = false,
		OnSelected = function(self, state)
			object:Toggle(state)
		end,
	})
	
	local proxy = CreateProxy(object, nil, function(t, k, v)
		assert(k ~= "Instance" and k ~= "ClassName" and k ~= "Name", "Forbidden write")
		
		object[k] = v
	end)
	
	object.Button:Toggle(true)
	
	if object.Debug then print("Created terminal", name) end
	
	return proxy
end

function Terminal:GetStorage()
	local path = "Terminus\\" .. self.Name
	
	
	return path
end

function Terminal:ImportSettings()
	if RunService:IsStudio() then return {} end
	
	local path = self:GetStorage()
	if not isfolder(path) then return {} end
	
	local exists = isfile(path .. "\\Settings.json")
	if exists then
		local data = HttpService:JSONDecode(readfile(path .. "\\Settings.json"))
		if Terminus.Debug then
			print("Settings", self.Name)
			for k, v in pairs (data) do print("	", k, v) end
		end
		return data
	end
	
	return {}
end

function Terminal:ExportSettings(data)
	if RunService:IsStudio() then return end
	
	local path = self:GetStorage()
	if not isfolder(path) then
		makefolder(path)
	end
	
	writefile(path .. "\\Settings.json", HttpService:JSONEncode(data))
end

function Terminal:IsMouseOnTop()
	local mousePos = Vector2.new(Mouse.X, Mouse.Y)
	local windowPos = Gui.Frame.AbsolutePosition
	local windowSize = Gui.Frame.AbsoluteSize
	
	if not Gui.Enabled then return false end
	
	return mousePos.X >= windowPos.X and mousePos.X <= windowPos.X + windowSize.X and mousePos.Y >= windowPos.Y and mousePos.Y <= windowPos.Y + windowSize.Y
end

function Terminal:Toggle(state)
	if state == nil then state = not self.Instance.Visible end
	
	self.Instance.Visible = state
	if not state then return end
	
	for _, terminal in pairs (Terminals) do
		if terminal == self then continue end
		
		terminal.Button.Selected = false
		terminal.Button:SetState()
		terminal.Instance.Visible = false
	end
end

function Terminal:OnClose()
	
end

--SWITCH-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local Switch = {
	ClassName = "Switch",
	State = false,
	AnchorPoint = Vector2.new(0, 0),
	Position = UDim2.new(0, 0, 0, 0),
	Height = 20,
}
Switch.__index = Switch

function Terminal:CreateSwitch(parent, properties)
	local object = setmetatable(properties or {}, Switch)
	object.Style = object.Style or self.Style

	local frame = Instance.new("Frame")
	local dot = Instance.new("Frame")
	local uicorner = Instance.new("UICorner")
	local uicorner_2 = Instance.new("UICorner")
	local button = Instance.new("TextButton")

	--Properties:

	frame.Name = "Switch"
	frame.AnchorPoint = object.AnchorPoint
	frame.Parent = (typeof(parent) == "Instance" and parent) or (typeof(parent) == "table" and parent.Instance) or self.Instance
	frame.BackgroundColor3 = object.Style.BackgroundColor
	frame.BorderSizePixel = 0
	frame.Size = UDim2.new(0, object.Height * 2, 0, object.Height)
	frame.Position = object.Position

	dot.Name = "Dot"
	dot.Parent = frame
	dot.BackgroundColor3 = object.Style.IdleColor
	dot.Size = UDim2.new(0, object.Height, 0, object.Height)

	uicorner.CornerRadius = UDim.new(0, object.Height / 2)
	uicorner.Parent = dot

	uicorner_2.CornerRadius = UDim.new(0, object.Height / 2)
	uicorner_2.Parent = frame

	button.Name = "Button"
	button.Parent = frame
	button.BackgroundTransparency = 1
	button.Size = UDim2.new(1, 0, 1, 0)
	button.Text = ""

	object.Instance = frame
	
	local proxy = CreateProxy(object, nil, function(_, k, v)
		assert(k ~= "Instance", "Locked field")
		object[k] = v

		if k == "AnchorPoint" then
			frame.AnchorPoint = v
		elseif k == "Position" then
			frame.Position = v
		end
	end)
	
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
	
	if Terminus.Debug then print("Created", object.ClassName) end
	
	proxy:SetState()
	
	return proxy
end

function Switch:SetState()
	if Terminus.Debug then print(self.ClassName, "SetState", self.State) end
	
	if self.State then
		self.Instance.Dot:TweenPosition(UDim2.new(0, self.Height, 0, 0), Enum.EasingDirection.In, self.Style.EasingStyle, self.Style.SlideTime, true)
		TweenService:Create(self.Instance, TweenInfo.new(self.Style.SlideTime, self.Style.EasingStyle, Enum.EasingDirection.In), {["BackgroundColor3"] = self.Style.ActiveColor}):Play()
	else
		self.Instance.Dot:TweenPosition(UDim2.new(0, 0, 0, 0), Enum.EasingDirection.Out, self.Style.EasingStyle, self.Style.SlideTime, true)
		TweenService:Create(self.Instance, TweenInfo.new(self.Style.SlideTime, self.Style.EasingStyle, Enum.EasingDirection.In), {["BackgroundColor3"] = self.Style.BackgroundColor}):Play()
	end
end

function Switch:Toggle(state)
	if state == nil then state = not self.State end
	
	if Terminus.Debug then print(self.ClassName, "Toggle", state) end
	
	self.State = state
	self:SetState()
	
	if Terminus.Debug then print(self.ClassName, "OnChanged", state) end
	local bool, arg = pcall(function()
		self:OnChanged(state)
	end)
	if not bool and Terminus.Debug then warn(arg) end
end

function Switch:OnChanged(value)

end

--SLIDER-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local Slider = {
	ClassName = "Slider",
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
	object.Style = object.Style or self.Style
	if self.ScrollContent and (not parent or parent == self) and object.Size.X.Offset <= 0 and object.Size.X.Scale == 1 then object.Size = object.Size - UDim2.new(0, 0, 0, 4) end

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
	window.Parent = (typeof(parent) == "Instance" and parent) or (typeof(parent) == "table" and parent.Instance) or self.Instance
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
	tip.TextSize = object.Style.SmallTextSize
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
	
	local proxy = CreateProxy(object, nil, function(_, k, v)
		assert(k ~= "Instance", "Locked field")
		object[k] = v

		if k == "AnchorPoint" then
			window.AnchorPoint = v
		elseif k == "Position" then
			window.Position = v
		elseif k == "Size" then
			window.Size = v
		end
	end)
	
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
		
		proxy:OnFinished()
	end)
	
	window:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		proxy:SetState()
	end)
	
	if Terminus.Debug then print("Created", object.ClassName) end
	
	proxy:SetState()

	return proxy
end

function Slider:SetState()
	local value = self.Value
	if Terminus.Debug then print(self.ClassName, "SetState", value) end
	
	local container = self.Instance.Container
	local dot = container.Dot
	local tip = container.Tip
	local leftBar = container.LeftBar
	local rightBar = container.RightBar

	local totalLength = container.AbsoluteSize.X
	local alpha = (value / self.Maximum)
	local x = totalLength * alpha
	
	dot:TweenPosition(UDim2.new(x / totalLength, 0, 0.5, 0), Enum.EasingDirection.Out, self.Style.EasingStyle, self.Style.SlideTime, true)
	tip:TweenPosition(UDim2.new(x / totalLength, 0, 0, -8), Enum.EasingDirection.Out, self.Style.EasingStyle, self.Style.SlideTime, true)

	if self.Fill then
		leftBar:TweenSize(UDim2.new(x / totalLength, 0, 0, 6), Enum.EasingDirection.Out, self.Style.EasingStyle, self.Style.SlideTime, true)
		rightBar.Position = UDim2.new(1, 0, 0.5, 0) --UDim2.new(x / totalLength, 0, 0.5, 0)
		rightBar:TweenSize(UDim2.new(-(totalLength - x) / totalLength, 0, 0, 6), Enum.EasingDirection.Out, self.Style.EasingStyle, self.Style.SlideTime, true)
	end

	tip.Text = value
end

function Slider:SetValue(value)
	if Terminus.Debug then print(self.ClassName, "SetValue", value) end
	
	self.Value = value
	
	task.spawn(function()
		if Terminus.Debug then print(self.ClassName, "OnChanged", value) end
		local bool, arg = pcall(function()
			self:OnChanged(value)
		end)
		if not bool and Terminus.Debug then warn(arg) end
	end)
	
	self:SetState(value)
end

function Slider:OnChanged(value)
	
end

function Slider:OnFinished()
	
end

--DROPDOWN-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local Dropdown = {
	ClassName = "Dropdown",
	Padding = 2,
	MaxDisplay = 3 * 20,
	CloseOnSelect = false,
	MultiSelect = true,
	MinSelection = 0,
	MaxSelection = 999,
	IsOpen = false,
	Title = "Dropdown",
	
	Size = UDim2.new(1, 0, 0, 20),
	Position = UDim2.new(0, 0, 0, 0),
	AnchorPoint = Vector2.new(0, 0),
}
Dropdown.__index = Dropdown

function Terminal:CreateDropdown(parent, properties)
	local object = setmetatable(properties or {}, Dropdown)
	object.Style = object.Style or self.Style
	if self.ScrollContent and (not parent or parent == self) and object.Size.X.Offset <= 0 and object.Size.X.Scale == 1 then object.Size = object.Size - UDim2.new(0, 0, 0, 4) end
	
	object.Selected = object.Selected or (object.MultiSelect and {} or nil)
	object.Items = object.Items or {}
	object.Built = {}
	
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
	window.AnchorPoint = object.AnchorPoint
	window.Parent = (typeof(parent) == "Instance" and parent) or (typeof(parent) == "table" and parent.Instance) or self.Instance
	window.BackgroundColor3 = object.Style.BackgroundColor
	window.Size = object.Size
	window.Position = object.Position
	window.ClipsDescendants = true
	window.ZIndex = 2

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
	header.Size = UDim2.new(1, -30, 0, object.Size.Y.Offset)
	header.FontFace = object.Style.FontFace
	header.Text = object.Title
	header.TextColor3 = Color3.fromRGB(240, 240, 240)
	header.TextSize = object.Style.NormalTextSize
	header.TextXAlignment = Enum.TextXAlignment.Left

	scroll.Name = "Scroll"
	scroll.Parent = window
	scroll.Active = true
	scroll.BackgroundTransparency = 1.000
	scroll.BorderSizePixel = 0
	scroll.Position = UDim2.new(0, 1, 0, object.Size.Y.Offset + object.Padding)
	scroll.Size = UDim2.new(1, -2, 1, -object.Size.Y.Offset - object.Padding)
	scroll.ScrollBarThickness = 4
	scroll.ScrollBarImageColor3 = object.Style.ActiveColor
	scroll.ScrollBarImageTransparency = 0
	scroll.Visible = false
	
	button.Name = "Button"
	button.Parent = window
	button.BackgroundTransparency = 1.000
	button.Size = UDim2.new(1, 0, 0, object.Size.Y.Offset)
	button.Text = ""
	button.TextColor3 = Color3.fromRGB(0, 0, 0)
	button.TextSize = object.Style.NormalTextSize
	
	sort.Padding = UDim.new(0, object.Padding)
	sort.Name = "Sort"
	sort.Parent = scroll
	
	uicorner_2.CornerRadius = UDim.new(0, object.Style.CornerRadius)
	uicorner_2.Parent = window
	
	object.Instance = window
	
	local proxy = CreateProxy(object, nil, function(_, k, v)
		assert(k ~= "Instance", "Locked field")
		object[k] = v

		if k == "Title" then
			header.Text = v
		elseif k == "AnchorPoint" then
				window.AnchorPoint = v
		elseif k == "Position" then
				window.Position = v
		elseif k == "Size" then
			window.Size = v
		end
	end)
	
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
	
	if Terminus.Debug then print("Created", object.ClassName) end
	
	proxy:Toggle(object.IsOpen)
	
	for _, item in pairs (object.Items) do
		local built = proxy:ItemBuilder(item)
		built.Instance.Parent = scroll
	end
	
	scroll.CanvasSize = UDim2.new(0, 0, 0, scroll.Sort.AbsoluteContentSize.Y)
	
	return proxy
end

function Dropdown:ItemBuilder(item)
	local object = self
	
	local button = Terminal:CreateTextButton(self, {
		Style = self.Style,
		Text = tostring(item),
		Selectable = object.MultiSelect,
		Selected = self:IsSelected(item),
		Size = UDim2.new(1, 0, 0, 20),
		OnSelected = function(self, state)
			object:Select(item)
			self.Selected = object:IsSelected(item)
			self:SetState()
		end,
		OnActivated = function()
			object:Select(item)
		end,
	})
	
	return button
end

function Dropdown:Select(item)
	if Terminus.Debug then print(self.ClassName, "Select", item) end
	
	if self.MultiSelect then
		local index = table.find(self.Selected, item)
		if index then
			if #self.Selected > self.MinSelection then
				table.remove(self.Selected, index)
			end
		else
			if #self.Selected < self.MaxSelection then
				table.insert(self.Selected, item)
			end
		end
		
		--self:SetState()
		
		if self.CloseOnSelect then
			self:Toggle(false)
		end
	else
		if self.CloseOnSelect then
			self:Toggle(false)
		end
		
		if self:IsSelected(item) then
			self.Selected = nil
		else
			self.Selected = item
		end
	end
	
	if Terminus.Debug then print(self.ClassName, "OnSelected", item) end
	
	local bool, arg = pcall(function()
		self:OnSelected(item)
	end)
	if not bool and Terminus.Debug then warn(arg) end
end

function Dropdown:IsSelected(item)
	if self.MultiSelect then
		for _, item2 in pairs (self.Selected) do
			if item2 == item then return true end
		end
	end
	
	return self.Selected == item
end

function Dropdown:Toggle(state)
	if state == nil then
		state = not self.IsOpen
	end
	
	if Terminus.Debug then print(self.ClassName, "Toggle", state) end
	
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
		
		local dropTween = TweenService:Create(instance, TweenInfo.new(self.Style.SlideTime, self.Style.EasingStyle, Enum.EasingDirection.In),
			{["Size"] = self.Size + UDim2.new(0, 0, 0, self.Padding + (math.clamp(scroll.Sort.AbsoluteContentSize.Y, 0, self.MaxDisplay)))}
		)
		dropTween:Play()

		scroll.Visible = true
	else
		TweenService:Create(
			arrow, TweenInfo.new(self.Style.SlideTime, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
				["Rotation"] = 90,
				["ImageColor3"] = self.Style.IdleColor
			}
		):Play()
		
		local dropTween = TweenService:Create(instance, TweenInfo.new(self.Style.SlideTime, self.Style.EasingStyle, Enum.EasingDirection.In),
			{["Size"] = self.Size}
		)
		dropTween:Play()

		dropTween.Completed:Connect(function(playbackState)
			if playbackState ~= Enum.PlaybackState.Completed then return end
			
			scroll.Visible = false
		end)
	end
end

function Dropdown:OnSelected(value)
	
end

--TEXTFIELD-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local TextField = {
	ClassName = "TextField",
	NumbersOnly = false,
	OnlyUpdateOnEnter = false,
	Size = UDim2.new(1, 0, 0, 20),
	Position = UDim2.new(0, 0, 0, 0),
	AnchorPoint = Vector2.new(0, 0),
	Text = "",
	PlaceholderText = "",
	PlaceholderColor = Color3.fromRGB(200, 200, 200)
}
TextField.__index = TextField

function Terminal:CreateTextField(parent, properties)
	local object = setmetatable(properties or {}, TextField)
	object.Style = object.Style or self.Style
	if self.ScrollContent and (not parent or parent == self) and object.Size.X.Offset <= 0 and object.Size.X.Scale == 1 then object.Size = object.Size - UDim2.new(0, 0, 0, 4) end
	
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
	box.TextSize = object.Style.NormalTextSize
	box.FontFace = object.Style.FontFace
	box.Text = formatText(object.Text)
	box.PlaceholderText = object.PlaceholderText
	box.PlaceholderColor3 = object.PlaceholderColor
	box.Parent = (typeof(parent) == "Instance" and parent) or (typeof(parent) == "table" and parent.Instance) or self.Instance
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, object.Style.CornerRadius)
	corner.Parent = box
	
	object.Instance = box
	
	local proxy = CreateProxy(object, nil, function(t, k, v)
		assert(k ~= "Instance", "Locked field")
		if k ~= "Text" then
			object[k] = v
		end

		if k == "Text" then
			local formatted = formatText(v)
			if formatted == object.Text then return end

			object.Text = formatted
			box.Text = formatted
			
			if object.NumbersOnly then
				if string.len(formatted) == 0 then
					t:OnChanged(nil)
				else
					t:OnChanged(tonumber(formatted))
				end
			else
				t:OnChanged(formatted)
			end
		elseif k == "Size" then
			box.Size = v
		elseif k == "Position" then
			box.Position = v
		elseif k == "AnchorPoint" then
			box.AnchorPoint = v
		end
	end)
	
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
	
	local function onInput()
		local formatted = formatText(box.Text)
		box.Text = formatted

		if object.Text == formatted then return end

		object.Text = formatted
		if object.NumbersOnly then
			if string.len(formatted) == 0 then
				proxy:OnChanged(nil)
			else
				proxy:OnChanged(tonumber(formatted))
			end
		else
			proxy:OnChanged(formatted)
		end
	end
	
	if object.OnlyUpdateOnEnter then
		box.FocusLost:Connect(function(enterPressed, input)
			if not enterPressed then return end
			onInput()
		end)
	else
		box:GetPropertyChangedSignal("Text"):Connect(onInput)
	end
	
	if Terminus.Debug then print("Created", object.ClassName) end
	
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

--TEXTBUTTON-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local TextButton = {
	ClassName = "TextButton",
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
	object.Style = object.Style or self.Style
	if self.ScrollContent and (not parent or parent == self) and object.Size.X.Offset <= 0 and object.Size.X.Scale == 1 then object.Size = object.Size - UDim2.new(0, 0, 0, 4) end
	
	local button = Instance.new("TextButton")
	button.BackgroundColor3 = object.Selected and object.Style.ActiveColor or object.Style.BackgroundColor
	button.Size = object.Size
	button.FontFace = object.Style.FontFace
	button.AutoButtonColor = false
	button.TextSize = object.Style.NormalTextSize
	button.Text = object.Text
	button.TextColor3 = Color3.fromRGB(240, 240, 240)
	button.ClipsDescendants = true
	button.Parent = (typeof(parent) == "Instance" and parent) or (typeof(parent) == "table" and parent.Instance) or self.Instance
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, object.Style.CornerRadius)
	corner.Parent = button
	
	object.Instance = button
	
	local proxy = CreateProxy(object, nil, function(_, k, v)
		assert(k ~= "Instance", "Locked field")
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
	end)
	
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
		
		if object.Selectable then
			proxy:Toggle()
		else
			proxy:OnActivated()
		end
	end)
	
	if Terminus.Debug then print("Created", object.ClassName) end
	
	proxy:SetState()
	
	return proxy
end

function TextButton:Toggle(state)
	local state = state or not self.Selected
	
	self.Selected = state
	self:SetState()
	self:OnSelected(state)
end

function TextButton:SetState()
	if Terminus.Debug then print(self.ClassName, "SetState", self.Selected) end
	
	if self.Selectable then
		if self.Selected then
			TweenService:Create(self.Instance, TweenInfo.new(self.Style.SlideTime, self.Style.EasingStyle, Enum.EasingDirection.In), {
				BackgroundColor3 = self.Style.ActiveColor
			}):Play()
		else
			TweenService:Create(self.Instance, TweenInfo.new(self.Style.SlideTime, self.Style.EasingStyle, Enum.EasingDirection.Out), {
				BackgroundColor3 = self.Style.BackgroundColor
			}):Play()
		end
	end
end

function TextButton:OnSelected(state)
	
end

function TextButton:OnActivated()
	
end

--TEXTLABEL-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local TextLabel = {
	ClassName = "TextLabel",
	Text = "",
	Size = UDim2.new(1, 0, 0, 20),
	Position = UDim2.new(0, 0, 0, 0),
	AnchorPoint = Vector2.new(0, 0),
	TextColor = Color3.fromRGB(240, 240, 240)
}
TextLabel.__index = TextLabel

function Terminal:CreateTextLabel(parent, properties)
	local object = setmetatable(properties or {}, TextLabel)
	object.Style = object.Style or self.Style
	if self.ScrollContent and (not parent or parent == self) and object.Size.X.Offset <= 0 and object.Size.X.Scale == 1 then object.Size = object.Size - UDim2.new(0, 0, 0, 4) end
	
	local label = Instance.new("TextButton")
	label.Name = "TextLabel"
	label.AnchorPoint = object.AnchorPoint
	label.BackgroundColor3 = object.Style.BackgroundColor
	label.Size = object.Size
	label.Position = object.Position
	label.FontFace = object.Style.FontFace
	label.AutoButtonColor = false
	label.Text = object.Text
	label.TextSize = object.Style.NormalTextSize
	label.TextColor3 = object.TextColor
	label.Parent = (typeof(parent) == "Instance" and parent) or (typeof(parent) == "table" and parent.Instance) or self.Instance

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
	
	local proxy = CreateProxy(object, nil, function(_, k, v)
		assert(k ~= "Instance", "Locked field")
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
	end)
	
	if Terminus.Debug then print("Created", object.ClassName) end

	return proxy
end

--ROW-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local Row = {
	ClassName = "Row",
	Size = UDim2.new(1, 0, 0, 20),
	Layout = {},
	Position = UDim2.new(0, 0, 0, 0),
	AnchorPoint = Vector2.new(0, 0),
}
Row.__index = Row

function Terminal:CreateRow(parent, properties)
	local object = setmetatable(properties or {}, Row)
	object.Style = object.Style or self.Style
	if self.ScrollContent and (not parent or parent == self) and object.Size.X.Offset <= 0 and object.Size.X.Scale == 1 then object.Size = object.Size - UDim2.new(0, 0, 0, 4) end
	object.Items = object.Items or {}
	object.Columns = {}
	
	local container = Instance.new("TextButton")
	container.Name = "Row"
	container.AnchorPoint = object.AnchorPoint
	container.BackgroundColor3 = object.Style.BackgroundColor
	container.Size = object.Size
	container.Position = object.Position
	container.AutoButtonColor = false
	container.Text = ""
	container.ClipsDescendants = true
	container.Parent = (typeof(parent) == "Instance" and parent) or (typeof(parent) == "table" and parent.Instance) or self.Instance

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
	
	local proxy = CreateProxy(object, nil, function(_, k, v)
		assert(k ~= "Instance", "Locked field")
		object[k] = v

		if k == "Size" then
			container.Size = v
		elseif k == "Position" then
			container.Position = v
		elseif k == "AnchorPoint" then
			container.AnchorPoint = v
		end
	end)
	
	if Terminus.Debug then print("Created", object.ClassName) end
	
	return proxy
end

--LINE-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local Line = {
	ClassName = "Line",
	Size = UDim2.new(1, 0, 0, 1),
	Position = UDim2.new(0, 0, 0, 0),
	AnchorPoint = Vector2.new(0, 0),
}
Line.__index = Line

function Terminal:CreateLine(parent, properties)
	local object = setmetatable(properties or {}, Line)
	object.Style = object.Style or self.Style
	if self.ScrollContent and (not parent or parent == self) and object.Size.X.Offset <= 0 and object.Size.X.Scale == 1 then object.Size = object.Size - UDim2.new(0, 0, 0, 4) end
	
	local line = Instance.new("Frame")
	line.Name = "Line"
	line.AnchorPoint = object.AnchorPoint
	line.BackgroundColor3 = object.Style.IdleColor
	line.BorderSizePixel = 0
	line.Position = object.Position
	line.Size = object.Size
	line.Parent = (typeof(parent) == "Instance" and parent) or (typeof(parent) == "table" and parent.Instance) or self.Instance
	
	object.Instance = line
	
	local proxy = CreateProxy(object, nil, function(_, k, v)
		assert(k ~= "Instance", "Locked field")
		object[k] = v

		if k == "Size" then
			line.Size = v
		elseif k == "Position" then
			line.Position = v
		elseif k == "AnchorPoint" then
			line.AnchorPoint = v
		end
	end)
	
	if Terminus.Debug then print("Created", object.ClassName) end
	
	return proxy
end

--SEARCHBAR-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local Searchbar = {
	ClassName = "Searchbar",
	Size = UDim2.new(1, 0, 0, 20),
	Position = UDim2.new(0, 0, 0, 0),
	AnchorPoint = Vector2.new(0, 0),
	MaxDisplay = 3 * 20,
	Padding = 2,
	OnlyUpdateOnEnter = true,
	PlaceholderText = "Search...",
	PlaceholderColor = Color3.fromRGB(200, 200, 200),
	
	IsOpen = false
}
Searchbar.__index = Searchbar

function Terminal:CreateSearchbar(parent, properties)
	local object = setmetatable(properties or {}, Searchbar)
	if self.ScrollContent and (not parent or parent == self) and object.Size.X.Offset <= 0 and object.Size.X.Scale == 1 then object.Size = object.Size - UDim2.new(0, 0, 0, 4) end
	object.Style = object.Style or self.Style
	object.Items = object.Items or {}
	
	local proxy = CreateProxy(object, nil, function(t, k , v)
		assert(k ~= "Instance", "Locked field")
		
		object[k] = v
		
		if k == "Size" then
			object.Instance.Size = UDim2.new(v.X.Scale, v.X.Offset, 0, 20)
		elseif k == "Position" then
			object.Instance.Position = v
		elseif k == "AnchorPoint" then
			object.Instance.AnchorPoint = v
		end
	end)
	
	local frame = Instance.new("Frame")
	frame.Name = "Searchbar"
	frame.AnchorPoint = object.AnchorPoint
	frame.BackgroundColor3 = object.Style.BackgroundColor
	frame.Size = UDim2.new(object.Size.X.Scale, object.Size.X.Offset, 0, 20)
	frame.Position = object.Position
	frame.BorderSizePixel = 0
	frame.Parent = (typeof(parent) == "Instance" and parent) or (typeof(parent) == "table" and parent.Instance) or self.Instance
	
	local rounding = Instance.new("UICorner")
	rounding.CornerRadius = UDim.new(0, object.Style.CornerRadius)
	rounding.Parent = frame
	
	object.Instance = frame
	
	local searchGlass = Instance.new("ImageButton")
	searchGlass.Name = "Glass"
	searchGlass.Parent = frame
	searchGlass.BackgroundTransparency = 1.000
	searchGlass.Position = UDim2.new(1, -20, 0, 2)
	searchGlass.Size = UDim2.new(0, 16, 0, 16)
	searchGlass.Image = "rbxassetid://395920720"
	searchGlass.ImageColor3 = object.Style.IdleColor
	
	local scroll = Instance.new("ScrollingFrame")
	scroll.Name = "Scroll"
	scroll.Parent = frame
	scroll.Active = true
	scroll.BackgroundTransparency = 1.000
	scroll.BorderSizePixel = 0
	scroll.Position = UDim2.new(0, 1, 0, object.Size.Y.Offset + object.Padding)
	scroll.Size = UDim2.new(1, -2, 1, -object.Size.Y.Offset - object.Padding)
	scroll.ScrollBarThickness = 4
	scroll.ScrollBarImageColor3 = object.Style.ActiveColor
	scroll.ScrollBarImageTransparency = 0
	scroll.Visible = false
	
	local sort = Instance.new("UIListLayout")
	sort.Padding = UDim.new(0, object.Padding)
	sort.Name = "Sort"
	sort.Parent = scroll
	
	local textfield = self:CreateTextField(frame, {
		Style = object.Style:Clone({
			Effects = false
		}),
		Size = UDim2.new(1, - 20, 0, 20),
		PlaceholderText = object.PlaceholderText,
		PlaceholderColor = object.PlaceholderColor,
		OnlyUpdateOnEnter = object.OnlyUpdateOnEnter,
		Text = "",
		OnChanged = function(self, value)
			proxy:Search(string.lower(value))
		end,
	})
	textfield.Instance.BackgroundTransparency = 1
	object.Searchbar = textfield
	
	if object.Style.Effects then
		textfield.Instance.MouseEnter:Connect(function()
			TweenService:Create(frame, TweenInfo.new(object.Style.SlideTime, object.Style.EasingStyle, Enum.EasingDirection.In), {
				BackgroundColor3 = object.Style.BackgroundColor:Lerp(Color3.new(1,1,1), object.Style.Brighten)
			}):Play()
		end)

		textfield.Instance.MouseLeave:Connect(function()
			TweenService:Create(frame, TweenInfo.new(object.Style.SlideTime, object.Style.EasingStyle, Enum.EasingDirection.Out), {
				BackgroundColor3 = object.Style.BackgroundColor
			}):Play()
		end)
		
		searchGlass.MouseEnter:Connect(function()
			TweenService:Create(searchGlass, TweenInfo.new(object.Style.SlideTime, object.Style.EasingStyle, Enum.EasingDirection.In), {
				ImageColor3 = object.Style.ActiveColor
			}):Play()
		end)
		
		searchGlass.MouseLeave:Connect(function()
			TweenService:Create(searchGlass, TweenInfo.new(object.Style.SlideTime, object.Style.EasingStyle, Enum.EasingDirection.In), {
				ImageColor3 = object.Style.IdleColor
			}):Play()
		end)
	end
	
	if Terminus.Debug then print("Created", object.ClassName) end
	
	return proxy
end

function Searchbar:Search(keyword)
	local instance = self.Instance
	local scroll = instance.Scroll
	local searchbar = self
	local found = {}
	
	for _, child in pairs (scroll:GetChildren()) do
		if child:IsA("UIListLayout") then continue end
		
		child:Destroy()
	end
	
	if string.len(keyword) == 0 then
		self:Toggle(false)
		return
	end
	
	for _, item in pairs (self.Items) do
		if string.find(string.lower(item), keyword) then
			
			local button = Terminal:CreateTextButton(scroll, {
				Style = self.Style:Clone(),
				Selectable = false,
				Text = item,
				Size = UDim2.new(1, -4, 0, instance.Size.Y.Offset),
				OnActivated = function(self)
					searchbar:Toggle(false)
					searchbar:OnSelected(item)
				end,
			})
			
			table.insert(found, item)
		end
	end
	
	if #found == 0 then
		Terminal:CreateTextField(scroll, {
			Style = self.Style:Clone(),
			Text = "No results",
			Size = UDim2.new(1, -4, 0, 20),
			TextColor = Color3.fromRGB(240, 240, 240),
		})
	end
	
	scroll.CanvasSize = UDim2.new(0, 0, 0, scroll.Sort.AbsoluteContentSize.Y)
	
	self:Toggle(true)
	
	return found
end

function Searchbar:Toggle(state)
	if state == nil then
		state = not self.IsOpen
	end
	
	local instance = self.Instance
	local scroll = instance.Scroll

	if state then
		local size = UDim2.new(1, 0, 0, 20 + self.Padding + (math.clamp(scroll.Sort.AbsoluteContentSize.Y, 0, self.MaxDisplay)))
		local dropTween = TweenService:Create(instance, TweenInfo.new(self.Style.SlideTime, self.Style.EasingStyle, Enum.EasingDirection.In),
			{["Size"] = size}
		)
		dropTween:Play()

		scroll.Visible = true
	else
		local dropTween = TweenService:Create(instance, TweenInfo.new(self.Style.SlideTime, self.Style.EasingStyle, Enum.EasingDirection.In),
			{["Size"] = UDim2.new(1, 0, 0, 20)}
		)
		dropTween:Play()

		dropTween.Completed:Connect(function(playbackState)
			if playbackState ~= Enum.PlaybackState.Completed then return end

			scroll.Visible = false
			for _, child in pairs (scroll:GetChildren()) do
				if child:IsA("UIListLayout") then continue end

				child:Destroy()
			end
		end)
	end
	
	if self.IsOpen == state then return end
	self.IsOpen = state
end

function Searchbar:OnSelected(item)
	
end

--LISTVIEW-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local ListView = {
	ClassName = "ListView",
	Size = UDim2.new(0, 200, 0, 150),
	Position = UDim2.new(0.5, 0, 0.5, 0),
	AnchorPoint = Vector2.new(0.5, 0.5),
}
ListView.__index = ListView

function Terminal:CreateListView(parent, properties)
	local object = setmetatable(properties or {}, ListView)
	if self.ScrollContent and (not parent or parent == self) and object.Size.X.Offset <= 0 and object.Size.X.Scale == 1 then object.Size = object.Size - UDim2.new(0, 0, 0, 4) end
	object.Style = object.Style or self.Style
	object.Items = object.Items or {}
	
	local scroll = Instance.new("ScrollingFrame")
	scroll.Name = "Scroll"
	scroll.Parent = (typeof(parent) == "Instance" and parent) or (typeof(parent) == "table" and parent.Instance) or self.Instance
	scroll.Active = true
	scroll.BackgroundTransparency = 0
	scroll.BackgroundColor3 = object.Style.BackgroundColor
	scroll.BorderSizePixel = 0
	scroll.Position = object.Position
	scroll.Size = object.Size
	scroll.ScrollBarThickness = 4
	scroll.ScrollBarImageColor3 = object.Style.ActiveColor
	scroll.ScrollBarImageTransparency = 0
	scroll.Visible = false

	local sort = Instance.new("UIListLayout")
	sort.Padding = UDim.new(0, object.Padding)
	sort.Name = "Sort"
	sort.Parent = scroll
	
	local rounding = Instance.new("UICorner")
	rounding.CornerRadius = UDim.new(0, object.Style.CornerRadius)
	rounding.Parent = scroll
	
	object.Instance = scroll
	
	local proxy = CreateProxy(object, nil, function(t, k , v)
		assert(k ~= "Instance", "Locked field")

		object[k] = v

		if k == "Size" then
			object.Instance.Size = UDim2.new(v.X.Scale, v.X.Offset, 0, 20)
		elseif k == "Position" then
			object.Instance.Position = v
		elseif k == "AnchorPoint" then
			object.Instance.AnchorPoint = v
		end
	end)
	
	for _, item in pairs (object.Items) do
		local built = proxy:ItemBuilder(item)
		built.Instance.Parent = scroll
	end
	
	scroll.CanvasSize = UDim2.new(0, 0, 0, scroll.Sort.AbsoluteContentSize.Y)
	
	return proxy
end

function ListView:ItemBuilder(item)
	return Terminal:CreateTextLabel(nil, {
		Style = self.Style:Clone(),
		Text = tostring(item),
	})
end

function ListView:AddItem(item)
	table.insert(self.Items, item)
	
	local built = self:ItemBuilder(item)
	built.Instance.Parent = self.Instance
	
	self.Instance.CanvasSize = UDim2.new(0, 0, 0, self.Instance.Sort.AbsoluteContentSize.Y)
end

--NOTICE-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local Notice = {
	ClassName = "Notice",
	Size = UDim2.new(0, 200, 0, 150),
	Position = UDim2.new(0.5, 0, 0.5, 0),
	AnchorPoint = Vector2.new(0.5, 0.5),
	Title = "Notice",
	Body = "This is a notice",
	Dismissable = true
}
Notice.__index = Notice

function Terminal:CreateNotice(properties)
	local object = setmetatable(properties or {}, Notice)
	object.Style = object.Style or self.Style
	
	local dismissField = Instance.new("TextButton")
	dismissField.Name = "Notice"
	dismissField.BackgroundTransparency = 1
	dismissField.Size = UDim2.new(1, 0, 1, 0)
	dismissField.Text = ""
	dismissField.ClipsDescendants = true
	dismissField.Parent = Gui.Frame
	
	dismissField.Active = object.Dismissable
	
	local frame = Instance.new("Frame")
	frame.Name = "Frame"
	frame.AnchorPoint = object.AnchorPoint
	frame.BackgroundColor3 = object.Style.BackgroundColor
	frame.Size = object.Size
	frame.Position = object.Position - UDim2.new(1, 0, 0, 0)
	frame.BorderSizePixel = 0
	frame.Parent = dismissField
	
	local rounding = Instance.new("UICorner")
	rounding.CornerRadius = UDim.new(0, object.Style.CornerRadius)
	rounding.Parent = frame
	
	local header = Instance.new("TextLabel")
	header.Parent = frame
	header.Name = "Header"
	header.BackgroundColor3 = object.Style.ActiveColor
	header.BorderSizePixel = 0
	header.Size = UDim2.new(1, 0, 0, 20)
	header.FontFace = object.Style.FontFace
	header.Text = object.Title
	header.TextColor3 = Color3.fromRGB(240, 240, 240)
	header.TextSize = object.Style.HeaderTextSize
	header.TextXAlignment = Enum.TextXAlignment.Center
	header.TextWrapped = true
	
	rounding:Clone().Parent = header
	
	local bottomFlat = Instance.new("Frame")
	bottomFlat.BorderSizePixel = 0
	bottomFlat.BackgroundColor3 = object.Style.ActiveColor
	bottomFlat.Size = UDim2.new(1, 0, 0, object.Style.CornerRadius)
	bottomFlat.Position = UDim2.new(0, 0, 0, 20 - object.Style.CornerRadius)
	bottomFlat.Parent = frame
	
	local body = Instance.new("TextLabel")
	body.Parent = frame
	body.Name = "Body"
	body.BackgroundColor3 = object.Style.BackgroundColor
	body.BackgroundTransparency = 1
	body.Size = UDim2.new(1, 0, 1, -20)
	body.Position = UDim2.new(0, 0, 0, 20)
	body.FontFace = object.Style.FontFace
	body.Text = object.Body
	body.TextColor3 = Color3.fromRGB(240, 240, 240)
	body.TextSize = object.Style.NormalTextSize
	body.TextXAlignment = Enum.TextXAlignment.Center
	body.TextYAlignment = Enum.TextYAlignment.Center
	body.TextWrapped = true
	
	local button = Instance.new("TextButton")
	button.Size = UDim2.new(1, 0, 1, 0)
	button.BackgroundTransparency = 1
	button.Text = ""
	button.Parent = frame
	
	object.Instance = dismissField
	
	if object.Style.Effects then
		frame:TweenPosition(object.Position, object.Style.EasingDirection, object.Style.EasingStyle, object.Style.SlideTime, true)
	else
		frame.Position = object.Position
	end
	
	local proxy = CreateProxy(object, nil, function(_, k, v)
		assert(k ~= "Instance", "Locked field")
		object[k] = v

		if k == "Size" then
			frame.Size = v
		elseif k == "Position" then
			frame.Position = v
		elseif k == "AnchorPoint" then
			frame.AnchorPoint = v
		elseif k == "Title" then
			header.Text = v
		elseif k == "Body" then
			body.Text = v
		end
	end)
	
	if object.Dismissable then
		dismissField.Activated:Connect(function()
			proxy:Close()
		end)
	end
	
	button.Activated:Connect(function()
		proxy:Close()
	end)
	
	return proxy
end

function Notice:Close()
	if self.Style.Effects then
		self.Instance.Frame:TweenPosition(self.Position + UDim2.new(1, 0, 0, 0), self.Style.EasingDirection, self.Style.EasingStyle, self.Style.SlideTime, false, function()
			self.Instance:Destroy()
			self:OnClosed()
		end)
	else
		self.Instance:Destroy()
		self:OnClosed()
	end
end

function Notice:OnClosed()
	
end

--INITIALIZE-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

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
	frame.Position = UDim2.new(0.5, -50, 0.25, 0)
	frame.Size = UDim2.new(0.5, 200, 0.75, 0)
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
	button_2.TextSize = Style.NormalTextSize
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
	title.TextSize = Style.NormalTextSize
	title.TextWrapped = true
	title.TextXAlignment = Enum.TextXAlignment.Left

	sidebar.Name = "Sidebar"
	sidebar.Parent = frame
	sidebar.Active = true
	sidebar.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
	sidebar.BackgroundTransparency = 1.000
	sidebar.BorderSizePixel = 0
	sidebar.Position = UDim2.new(0, 2, 0, 20)
	sidebar.Size = UDim2.new(0, 148, 1, -25)
	sidebar.ScrollBarThickness = 4
	sidebar.CanvasSize = UDim2.new(0, 0, 0, 0)

	uiListLayout.Parent = sidebar
	uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder

	content.Name = "Content"
	content.Parent = frame
	content.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	content.BackgroundTransparency = 1.000
	content.Position = UDim2.new(0, 152, 0, 21)
	content.Size = UDim2.new(1, -154, 1, -26)

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
