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

local Settings = {
	ToggleKey = "Return"
}

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

function List:PickRandom(start, stop)
	start = start or 1
	stop = stop or self.length
	
	return self[math.random(start, stop)]
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
	--these are just colors that look good, meant for static use
	Colors = {
		Orange = Color3.fromRGB(255, 170, 0),
		Blue = Color3.fromRGB(0, 170, 255),
		Green = Color3.fromRGB(0, 170, 127),
		Pink = Color3.fromRGB(255, 49, 149),
		Black = Color3.fromRGB(30, 30, 30),
		Purple = Color3.fromRGB(147, 93, 255),
		Red = Color3.fromRGB(255, 92, 92)
	},
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
	HeaderTextSize = 18,
	Animated = true
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

--OBJECT-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local ObjectFields = {}
ObjectFields.Object = {
	ClassName = function()
		error("Readonly")
	end,
	ID = function()
		error("Readonly")
	end,
}
ObjectFields.Object.__index = ObjectFields.Object

local Class = {
	ClassName = "Object",
}
Class.__index = Class

function Class:Extend(classname, properties, fields)
	assert(ObjectFields[classname] == nil, classname .. " already exists")
	
	fields = setmetatable(fields or {}, ObjectFields[self.ClassName])
	rawset(fields, "__index", fields)
	ObjectFields[classname] = fields
	
	local object = {}
	object.ClassName = classname
	object.__index = object
	
	object = setmetatable(object, self)
	for k, v in pairs (properties or {}) do object[k] = v end

	local proxy = setmetatable({}, {
		__call = function() return object end,
		__index = object,
		__newindex = function(t, k, v)
			if k == "__index" then
				object[k] = v
				return
			end

			object[k] = (fields[k] and (fields[k](t, v) or v)) or v
		end
	})
	rawset(proxy, "__index", proxy)

	return proxy
end

function Class:new(properties)
	local fields = ObjectFields[self.ClassName]
	
	local object = {}
	object.ID = HttpService:GenerateGUID(false)
	object = setmetatable(object, self)
	for k, v in pairs (properties or {}) do object[k] = v end

	local proxy = setmetatable({}, {
		__call = function() return object end,
		__index = object,
		__newindex = function(t, k, v)
			object[k] = (fields[k] and (fields[k](t, v) or v)) or v
		end
	})
	rawset(proxy, "__index", proxy)

	return proxy
end

local Object = setmetatable({}, {
	__call = function() return Class end,
	__index = Class,
	__newindex = function(k, v)
		error("Cannot write to Object " .. tostring(v) .. "=" .. tostring(v) )
	end
})
rawset(Object, "__index", Object)

local Terminals = {}
local Events = {}
local Terminus = Object:Extend("Terminus", {
	List = List,
	Map = Map,
	Debug = RunService:IsStudio(),
})
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

--COMPONENT-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local Component = Object:Extend("Component", {
	Style = Style:new(),
	Size = UDim2.new(1, -4, 0, 20),
	Position = UDim2.new(0, 0, 0, 0),
	AnchorPoint = Vector2.new(0, 0),
}, {
	["Instance"] = function(t, v)
		assert(rawget(t, "Instance") == nil, "Readonly")
		t().Instance = v
		
		v.Destroying:Connect(function()
			t:OnDestroyed()
		end)
	end,
	Size = function(t, v)
		if not t.Instance then return end
		t.Instance.Size = v
	end,
	Position = function(t, v)
		if not t.Instance then return end
		t.Instance.Position = v
	end,
	AnchorPoint = function(t, v)
		if not t.Instance then return end
		t.Instance.AnchorPoint = v
	end
})

function Component:new(properties)
	local object = Object.new(self, properties)
	
	return object
end

function Component:OnDestroyed()
	if Terminus.Debug then
		print("Destroyed", self.ClassName, self.ID)
	end
end

--TERMINAL-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local TerminalTemporaryParent = Instance.new("Frame", Gui)
TerminalTemporaryParent.Visible = false
TerminalTemporaryParent.Name = "TemporaryParent"

local Terminal = Component:Extend("Terminal", {
	ScrollContent = true,
	Padding = 5,
	Visible = false,
	Instance = TerminalTemporaryParent
}, {
	Size = function(self, v)
		error("Unused")
	end,
	Position = function(self, v)
		error("Unused")
	end,
	AnchorPoint = function(self, v)
		error("Unused")
	end,
	Visible = function(self, v)
		self().Visible = v
		self:SetState()
	end,
	Padding = function(self, v)
		if self.ScrollContent then
			local sort = self.Instance:FindFirstChildOfClass("UIListLayout")
			sort.Padding = UDim.new(0, self.Padding)
			self.Instance.CanvasSize = UDim2.new(0, 0, 0, sort.AbsoluteContentSize.Y)
		end
	end,
})

function Terminal:new(name, properties)
	assert(Terminals[name] == nil, name .. " already exists")
	
	properties = properties or {}
	
	local object = Component.new(self, properties)
	object.Style = object.Style or Style:new({
		ActiveColor = Map:new(Style.Colors):ToList():PickRandom()
	})
	object.Name = name
	
	if object.ScrollContent then
		local window = Instance.new("ScrollingFrame")
		window.Name = name
		window.BackgroundTransparency = 1
		window.Size = UDim2.new(1, 0, 1, 0)
		window.Parent = Gui.Frame.Content
		window.Visible = object.Visible
		window.ScrollBarThickness = 4
		window.ScrollBarImageColor3 = object.Style.ActiveColor
		window.ScrollBarImageTransparency = 0
		
		local sort = Instance.new("UIListLayout")
		sort.Name = "Sort"
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
		window.Visible = object.Visible
		
		object.Instance = window
	end
	
	Terminals[name] = object

	object.Button = Terminal:CreateTextButton(Gui.Frame.Sidebar, {
		Style = object.Style,
		Text = name,
		Selectable = true,
		Selected = object.Visible,
		OnSelected = function(self, state)
			object:Toggle()
		end,
	})
	
	object:SetState()
	
	if Terminus.Debug then print("Created terminal", name) end
	
	return object
end

function Terminus:new(...)
	return Terminal:new(...)
end

function Terminal:SetState()
	self.Instance.Visible = self.Visible
	self.Button.Selected = self.Visible
	
	if self.ScrollContent then
		self.Instance.ScrollBarImageColor3 = self.Style.ActiveColor
		self.Instance:FindFirstChildOfClass("UIListLayout").Padding = UDim.new(0, self.Padding)
	end
end

function Terminal:IsMouseOnTop()
	local mousePos = Vector2.new(Mouse.X, Mouse.Y)
	local windowPos = Gui.Frame.AbsolutePosition
	local windowSize = Gui.Frame.AbsoluteSize
	
	if not Gui.Enabled then return false end
	
	return mousePos.X >= windowPos.X and mousePos.X <= windowPos.X + windowSize.X and mousePos.Y >= windowPos.Y and mousePos.Y <= windowPos.Y + windowSize.Y
end

function Terminal:Toggle(state)
	if state == nil then state = not self.Visible end
	
	self.Visible = state
	if not state then return end
	
	for _, terminal in pairs (Terminals) do
		if terminal == self then continue end
		
		terminal.Visible = false
	end
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

function Terminal:OnClose()
	
end

--SWITCH-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local Switch = Component:Extend("Switch", {
	Style = Component.Style:Clone({BackgroundColor = Color3.fromRGB(50, 50, 50)}),
	State = false,
	Height = 20
}, {
	Size = function()
		error("Unused")
	end,
	Height = function(self, v)
		self.Instance.Size = UDim2.new(0, v * 2, 0, v)
		self.Instance.Dot.Size = UDim2.new(0, v, 0, v)
	end,
	State = function(self, v)
		self().State = v
		self:SetState()
	end,
})

function Switch:new(parent, properties)
	local object = Component.new(self, properties)

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
	
	if object.Style.Effects then
		button.MouseEnter:Connect(function()
			TweenService:Create(dot, TweenInfo.new(object.Style.Animated and object.Style.SlideTime or 0, object.Style.EasingStyle, Enum.EasingDirection.In), {
				BackgroundColor3 = object.Style.IdleColor:Lerp(Color3.new(1,1,1), object.Style.Brighten)
			}):Play()
			
			TweenService:Create(frame, TweenInfo.new(object.Style.Animated and object.Style.SlideTime or 0, object.Style.EasingStyle, Enum.EasingDirection.In), {
				BackgroundColor3 = (object.State and object.Style.ActiveColor or object.Style.BackgroundColor):Lerp(Color3.new(1,1,1), object.Style.Brighten)
			}):Play()
		end)

		button.MouseLeave:Connect(function()
			TweenService:Create(dot, TweenInfo.new(object.Style.Animated and object.Style.SlideTime or 0, object.Style.EasingStyle, Enum.EasingDirection.Out), {
				BackgroundColor3 = object.Style.IdleColor
			}):Play()
			
			TweenService:Create(frame, TweenInfo.new(object.Style.Animated and object.Style.SlideTime or 0, object.Style.EasingStyle, Enum.EasingDirection.Out), {
				BackgroundColor3 = (object.State and object.Style.ActiveColor or object.Style.BackgroundColor)
			}):Play()
		end)
	end

	button.Activated:Connect(function()
		object:Toggle()
	end)
	
	object:SetState()
	
	return object
end

function Switch:SetState()
	if Terminus.Debug then print(self.ClassName, "SetState", self.State) end
	
	if self.State then
		self.Instance.Dot:TweenPosition(UDim2.new(0, self.Height, 0, 0), Enum.EasingDirection.In, self.Style.EasingStyle, self.Style.Animated and self.Style.SlideTime or 0, true)
		TweenService:Create(self.Instance, TweenInfo.new(self.Style.Animated and self.Style.SlideTime or 0, self.Style.EasingStyle, Enum.EasingDirection.In), {["BackgroundColor3"] = self.Style.ActiveColor}):Play()
	else
		self.Instance.Dot:TweenPosition(UDim2.new(0, 0, 0, 0), Enum.EasingDirection.Out, self.Style.EasingStyle, self.Style.Animated and self.Style.SlideTime or 0, true)
		TweenService:Create(self.Instance, TweenInfo.new(self.Style.Animated and self.Style.SlideTime or 0, self.Style.EasingStyle, Enum.EasingDirection.In), {["BackgroundColor3"] = self.Style.BackgroundColor}):Play()
	end
end

function Switch:Toggle(state)
	if state == nil then state = not self.State end
	
	if Terminus.Debug then print(self.ClassName, "Toggle", state) end
	
	self.State = state
	
	if Terminus.Debug then print(self.ClassName, "OnChanged", state) end
	local bool, arg = pcall(function()
		self:OnChanged(state)
	end)
	if not bool and Terminus.Debug then warn(arg) end
end

function Switch:OnChanged(value)

end

--SLIDER-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local Slider = Component:Extend("Slider", {
	ShowTip = true,
	Minimum = 1,
	Maximum = 10,
	Fill = true,
	Value = 1,
}, {
	Value = function(self, v)
		self().Value = v
		self:SetState()
	end,
})

function Slider:new(parent, properties)
	local object = Component.new(self, properties)
	
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
	
	if object.Style.Effects then
		button.MouseEnter:Connect(function()
			TweenService:Create(dot, TweenInfo.new(object.Style.Animated and object.Style.SlideTime or 0, object.Style.EasingStyle, Enum.EasingDirection.In), {
				BackgroundColor3 = object.Style.IdleColor:Lerp(Color3.new(1,1,1), object.Style.Brighten)
			}):Play()
			
			TweenService:Create(leftBar, TweenInfo.new(object.Style.Animated and object.Style.SlideTime or 0, object.Style.EasingStyle, Enum.EasingDirection.In), {
				BackgroundColor3 = (object.Fill and object.Style.ActiveColor or object.Style.BackgroundColor):Lerp(Color3.new(1,1,1), object.Style.Brighten)
			}):Play()
			
			TweenService:Create(rightBar, TweenInfo.new(object.Style.Animated and object.Style.SlideTime or 0, object.Style.EasingStyle, Enum.EasingDirection.In), {
				BackgroundColor3 = object.Style.BackgroundColor:Lerp(Color3.new(1,1,1), object.Style.Brighten)
			}):Play()
		end)

		button.MouseLeave:Connect(function()
			TweenService:Create(dot, TweenInfo.new(object.Style.Animated and object.Style.SlideTime or 0, object.Style.EasingStyle, Enum.EasingDirection.Out), {
				BackgroundColor3 = object.Style.IdleColor
			}):Play()
			
			TweenService:Create(leftBar, TweenInfo.new(object.Style.Animated and object.Style.SlideTime or 0, object.Style.EasingStyle, Enum.EasingDirection.In), {
				BackgroundColor3 = (object.Fill and object.Style.ActiveColor or object.Style.BackgroundColor)
			}):Play()
			
			TweenService:Create(rightBar, TweenInfo.new(object.Style.Animated and object.Style.SlideTime or 0, object.Style.EasingStyle, Enum.EasingDirection.In), {
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
			
			object:SetValue(value)
			
			RunService.Stepped:Wait()
		end
		
		tip.Visible = false
		
		object:OnFinished()
	end)
	
	window:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		object:SetState()
	end)
	
	object:SetState()

	return object
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
	
	dot:TweenPosition(UDim2.new(x / totalLength, 0, 0.5, 0), Enum.EasingDirection.Out, self.Style.EasingStyle, self.Style.Animated and self.Style.SlideTime or 0, true)
	tip:TweenPosition(UDim2.new(x / totalLength, 0, 0, -8), Enum.EasingDirection.Out, self.Style.EasingStyle, self.Style.Animated and self.Style.SlideTime or 0, true)

	if self.Fill then
		leftBar:TweenSize(UDim2.new(x / totalLength, 0, 0, 6), Enum.EasingDirection.Out, self.Style.EasingStyle, self.Style.Animated and self.Style.SlideTime or 0, true)
		rightBar.Position = UDim2.new(1, 0, 0.5, 0) --UDim2.new(x / totalLength, 0, 0.5, 0)
		rightBar:TweenSize(UDim2.new(-(totalLength - x) / totalLength, 0, 0, 6), Enum.EasingDirection.Out, self.Style.EasingStyle, self.Style.Animated and self.Style.SlideTime or 0, true)
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
end

function Slider:OnChanged(value)
	
end

function Slider:OnFinished()
	
end

--DROPDOWN-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local Dropdown = Component:Extend("Dropdown", {
	Padding = 2,
	MaxDisplay = 300,
	CloseOnSelect = false,
	MultiSelect = true,
	MinSelection = 0,
	MaxSelection = 999,
	IsOpen = false,
	Title = "Dropdown",
}, {
	Padding = function(self, v)
		local scroll = self.Instance.Scroll
		
		scroll.Sort.Padding = UDim.new(0, v)
		scroll.CanvasSize = UDim2.new(0, 0, 0, scroll.Sort.AbsoluteContentSize.Y)
	end,
	
	Title = function(self, v)
		self.Instance.Header.Text = v
	end,
})

function Dropdown:new(parent, properties)
	local object = Component.new(self, properties)
	
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
	
	if object.Style.Effects then
		button.MouseEnter:Connect(function()
			TweenService:Create(
				window, TweenInfo.new(object.Style.Animated and object.Style.SlideTime or 0, object.Style.EasingStyle, Enum.EasingDirection.In), {
					BackgroundColor3 = object.Style.BackgroundColor:Lerp(Color3.new(1,1,1), object.Style.Brighten)
				}
			):Play()
		end)

		button.MouseLeave:Connect(function()
			TweenService:Create(
				window, TweenInfo.new(object.Style.Animated and object.Style.SlideTime or 0, object.Style.EasingStyle, Enum.EasingDirection.Out), {BackgroundColor3 = object.Style.BackgroundColor}
			):Play()
		end)
	end
	
	button.Activated:Connect(function()
		object:Toggle()
	end)
	
	object:Toggle(object.IsOpen)
	
	for _, item in pairs (object.Items) do
		local built = object:ItemBuilder(item)
		if type(built) == "table" then built.Instance.Parent = scroll else built.Parent = scroll end
	end
	
	scroll.CanvasSize = UDim2.new(0, 0, 0, scroll.Sort.AbsoluteContentSize.Y)
	
	return object
end

function Dropdown:ItemBuilder(item)
	local object = self
	
	return Terminal:CreateTextButton(self, {
		Style = self.Style,
		Text = tostring(item),
		Selectable = object.MultiSelect,
		Selected = self:IsSelected(item),
		Size = UDim2.new(1, 0, 0, 20),
		OnSelected = function(self, state)
			object:Select(item)
			self.Selected = object:IsSelected(item)
		end,
		OnActivated = function()
			object:Select(item)
		end,
	})
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
			arrow, TweenInfo.new(self.Style.Animated and self.Style.SlideTime or 0, self.Style.EasingStyle, Enum.EasingDirection.In), {
				["Rotation"] = -90,
				["ImageColor3"] = self.Style.ActiveColor
			}
		):Play()
		
		local dropTween = TweenService:Create(instance, TweenInfo.new(self.Style.Animated and self.Style.SlideTime or 0, self.Style.EasingStyle, Enum.EasingDirection.In),
			{["Size"] = self.Size + UDim2.new(0, 0, 0, self.Padding + (math.clamp(scroll.Sort.AbsoluteContentSize.Y, 0, self.MaxDisplay)))}
		)
		dropTween:Play()

		scroll.Visible = true
	else
		TweenService:Create(
			arrow, TweenInfo.new(self.Style.Animated and self.Style.SlideTime or 0, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
				["Rotation"] = 90,
				["ImageColor3"] = self.Style.IdleColor
			}
		):Play()
		
		local dropTween = TweenService:Create(instance, TweenInfo.new(self.Style.Animated and self.Style.SlideTime or 0, self.Style.EasingStyle, Enum.EasingDirection.In),
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

local TextField = Component:Extend("TextField", {
	NumbersOnly = false,
	OnlyUpdateOnEnter = false,
	Text = "",
	PlaceholderText = "Enter a value",
	PlaceholderColor = Color3.fromRGB(200, 200, 200)
}, {
	Text = function(self, v)
		local formatted = self:FormatText(v)

		self().Text = formatted
		self.Instance.Text = formatted

		self:OnChanged(self.NumbersOnly and tonumber(formatted) or formatted)
	end,
	PlaceholderText = function(self, v)
		self.Instance.PlaceholderText = v
	end,
	PlaceholderColor = function(self, v)
		self.Instance.PlaceholderColor3 = v
	end,
})

function TextField:new(parent, properties)
	local object = Component.new(self, properties)
	
	local box = Instance.new("TextBox")
	box.Name = "Field"
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
	box.Text = object:FormatText(object.Text)
	box.PlaceholderText = object.PlaceholderText
	box.PlaceholderColor3 = object.PlaceholderColor
	box.Parent = (typeof(parent) == "Instance" and parent) or (typeof(parent) == "table" and parent.Instance) or self.Instance
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, object.Style.CornerRadius)
	corner.Parent = box
	
	object.Instance = box
	
	if object.Style.Effects then
		box.MouseEnter:Connect(function()
			TweenService:Create(box, TweenInfo.new(object.Style.Animated and object.Style.SlideTime or 0, object.Style.EasingStyle, Enum.EasingDirection.In), {
				BackgroundColor3 = object.Style.BackgroundColor:Lerp(Color3.new(1,1,1), object.Style.Brighten)
			}):Play()
		end)
		
		box.MouseLeave:Connect(function()
			TweenService:Create(box, TweenInfo.new(object.Style.Animated and object.Style.SlideTime or 0, object.Style.EasingStyle, Enum.EasingDirection.Out), {
				BackgroundColor3 = object.Style.BackgroundColor
			}):Play()
		end)
	end
	
	local function onInput()
		if box.Text == object.Text then return end
		object.Text = box.Text
	end
	
	if object.OnlyUpdateOnEnter then
		box.FocusLost:Connect(function(enterPressed, input)
			if not enterPressed then return end
			onInput()
		end)
	else
		box:GetPropertyChangedSignal("Text"):Connect(onInput)
	end
	
	return object
end

function TextField:FormatText(value)
	if self.NumbersOnly then
		local i = string.len(value)

		while i > 0 do
			local char = string.sub(value, i, i)
			if not tonumber(char) then
				value = string.sub(value, 1, i - 1) .. string.sub(value, i + 1)
			end
			i = i - 1
		end
	end

	return value
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

local TextButton = Component:Extend("TextButton", {
	Splash = true,
	Selectable = true,
	Selected = false,
	Text = "Button",
	Size = UDim2.new(1, -4, 0, 26),
}, {
	Text = function(self, v)
		self.Instance.Text = v
	end,
	Selected = function(self, v)
		self().Selected = v
		self:SetState()
	end,
})

function TextButton:new(parent, properties)
	local object = Component.new(self, properties)
	
	local button = Instance.new("TextButton")
	button.BackgroundColor3 = object.Selected and object.Style.ActiveColor or object.Style.BackgroundColor
	button.Size = object.Size
	button.FontFace = object.Style.FontFace
	button.AutoButtonColor = false
	button.TextSize = object.Style.NormalTextSize
	button.Text = object.Text
	button.TextColor3 = Color3.fromRGB(240, 240, 240)
	button.ClipsDescendants = true
	button.Parent = (typeof(parent) == "Instance" and parent) or (typeof(parent) == "table" and parent.Instance)
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, object.Style.CornerRadius)
	corner.Parent = button
	
	object.Instance = button
	
	if object.Style.Effects then
		button.MouseEnter:Connect(function()
			TweenService:Create(button, TweenInfo.new(object.Style.Animated and object.Style.SlideTime or 0, object.Style.EasingStyle, Enum.EasingDirection.In), {
				BackgroundColor3 = (object.Selected and object.Style.ActiveColor or object.Style.BackgroundColor):Lerp(Color3.new(1,1,1), object.Style.Brighten)
			}):Play()
		end)

		button.MouseLeave:Connect(function()
			TweenService:Create(button, TweenInfo.new(object.Style.Animated and object.Style.SlideTime or 0, object.Style.EasingStyle, Enum.EasingDirection.Out), {
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
				splash, TweenInfo.new(object.Style.Animated and object.Style.SlideTime or 0, object.Style.EasingStyle, Enum.EasingDirection.In), {
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
			object:Toggle()
		else
			object:OnActivated()
		end
	end)
	
	object:SetState()
	
	return object
end

function TextButton:Toggle(state)
	local state = state or not self.Selected
	
	self.Selected = state
	self:OnSelected(state)
end

function TextButton:SetState()
	if Terminus.Debug then print(self.ClassName, "SetState", self.Selected) end
	
	if self.Selectable then
		if self.Selected then
			TweenService:Create(self.Instance, TweenInfo.new(self.Style.Animated and self.Style.SlideTime or 0, self.Style.EasingStyle, Enum.EasingDirection.In), {
				BackgroundColor3 = self.Style.ActiveColor
			}):Play()
		else
			TweenService:Create(self.Instance, TweenInfo.new(self.Style.Animated and self.Style.SlideTime or 0, self.Style.EasingStyle, Enum.EasingDirection.Out), {
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

local TextLabel = Component:Extend("TextLabel", {
	Text = "",
	TextColor = Color3.fromRGB(240, 240, 240)
}, {
	Text = function(self, v)
		self.Instance.Text = v
	end,
	TextColor = function(self, v)
		self.Instance.TextColor3 = v
	end,
})

function TextLabel:new(parent, properties)
	local object = Component.new(self, properties)
	
	local label = Instance.new("TextButton")
	label.Name = "TextLabel"
	label.AnchorPoint = object.AnchorPoint
	label.BackgroundColor3 = object.Style.BackgroundColor
	label.Size = object.Size
	label.Position = object.Position
	label.FontFace = object.Style.FontFace
	label.AutoButtonColor = false
	label.TextWrapped = true
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
			TweenService:Create(label, TweenInfo.new(object.Style.Animated and object.Style.SlideTime or 0, object.Style.EasingStyle, Enum.EasingDirection.In), {
				BackgroundColor3 = object.Style.BackgroundColor:Lerp(Color3.new(1,1,1), object.Style.Brighten)
			}):Play()
		end)

		label.MouseLeave:Connect(function()
			TweenService:Create(label, TweenInfo.new(object.Style.Animated and object.Style.SlideTime or 0, object.Style.EasingStyle, Enum.EasingDirection.Out), {
				BackgroundColor3 = object.Style.BackgroundColor
			}):Play()
		end)
	end

	return object
end

--ROW-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local Row = Component:Extend("Row", {}, {
	Layout = function(self, v)
		self().Layout = v
		self:SetState()
	end,
})

function Row:new(parent, properties)
	local object = Component.new(self, properties)
	object.Columns = {}
	object.Items = object.Items or {}
	object.Layout = object.Layout or {}
	
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
			TweenService:Create(container, TweenInfo.new(object.Style.Animated and object.Style.SlideTime or 0, object.Style.EasingStyle, Enum.EasingDirection.In), {
				BackgroundColor3 = object.Style.BackgroundColor:Lerp(Color3.new(1,1,1), object.Style.Brighten)
			}):Play()
		end)

		container.MouseLeave:Connect(function()
			TweenService:Create(container, TweenInfo.new(object.Style.Animated and object.Style.SlideTime or 0, object.Style.EasingStyle, Enum.EasingDirection.Out), {
				BackgroundColor3 = object.Style.BackgroundColor
			}):Play()
		end)
	end
	
	local function resize()
		local amountItems = #object.Items
		if #object.Layout ~= amountItems then
			object.Layout = {}

			for i = 1, amountItems do
				object.Layout[i] = 1 / amountItems
			end
		end
		
		for i, column in pairs (object.Columns) do
			column.Size = UDim2.new(object.Layout[i], 0, 1, 0)
		end
	end
	
	object:SetState()
	
	for i, item in pairs (object.Items) do
		local width = object.Layout[i]
		local column = Instance.new("Frame")
		column.BackgroundTransparency = 1
		column.Name = i
		column.Size = UDim2.new(width, 0, 1, 0)
		column.Parent = container

		if typeof(item) == "Instance" then
			item.Parent = column
		elseif typeof(item) == "table" then
			item.Instance.Parent = column
		end

		object.Columns[i] = column
	end
	
	return object
end

function Row:SetState()
	local amountItems = #self.Items
	if #self.Layout ~= amountItems then
		self().Layout = {}

		for i = 1, amountItems do
			self.Layout[i] = 1 / amountItems
		end
	end

	for i, column in pairs (self.Columns) do
		column.Size = UDim2.new(self.Layout[i], 0, 1, 0)
	end
end

--LINE-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local Line = Component:Extend("Line", {
	Size = UDim2.new(1, -4, 0, 1),
})

function Line:new(parent, properties)
	local object = Component.new(self, properties)
	
	local line = Instance.new("Frame")
	line.Name = "Line"
	line.AnchorPoint = object.AnchorPoint
	line.BackgroundColor3 = object.Style.IdleColor
	line.BorderSizePixel = 0
	line.Position = object.Position
	line.Size = object.Size
	line.Parent = (typeof(parent) == "Instance" and parent) or (typeof(parent) == "table" and parent.Instance) or self.Instance
	
	object.Instance = line
	
	return object
end

--SEARCHBAR-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local Searchbar = Component:Extend("Searchbar", {
	MaxDisplay = 300,
	Padding = 2,
	SearchOnEnter = true,
	PlaceholderText = "Search...",
	PlaceholderColor = Color3.fromRGB(200, 200, 200),
	ShowAllOnEmpty = false,
	CloseOnSelection = true,
	IsOpen = false
}, {
	Padding = function(self, v)
		local scroll = self.Instance.Scroll

		scroll.Sort.Padding = UDim.new(0, v)
		scroll.CanvasSize = UDim2.new(0, 0, 0, scroll.Sort.AbsoluteContentSize.Y)
	end,
	PlaceholderText = function(self, v)
		self.Searchbar.PlaceholderText = v
	end,
	PlaceholderColor = function(self, v)
		self.Searchbar.PlaceholderColor3 = v
	end,
})

function Searchbar:new(parent, properties)
	local object = Component.new(self, properties)
	object.Items = object.Items or {}
	
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
	
	object.Instance = frame
	
	searchGlass.Activated:Connect(function()
		if object.IsOpen then
			object:Toggle(false)
		else
			object:Search(object.Searchbar.Text)
		end
	end)
	
	local textfield = Terminal:CreateTextField(frame, {
		Style = object.Style:Clone({
			Effects = false
		}),
		Size = UDim2.new(1, - 20, 0, 20),
		PlaceholderText = object.PlaceholderText,
		PlaceholderColor = object.PlaceholderColor,
		OnlyUpdateOnEnter = object.SearchOnEnter,
		Text = "",
		OnChanged = function(self, value)
			object:Search(string.lower(value))
		end,
	})
	textfield.Instance.BackgroundTransparency = 1
	object.Searchbar = textfield
	
	if object.Style.Effects then
		textfield.Instance.MouseEnter:Connect(function()
			TweenService:Create(frame, TweenInfo.new(object.Style.Animated and object.Style.SlideTime or 0, object.Style.EasingStyle, Enum.EasingDirection.In), {
				BackgroundColor3 = object.Style.BackgroundColor:Lerp(Color3.new(1,1,1), object.Style.Brighten)
			}):Play()
		end)

		textfield.Instance.MouseLeave:Connect(function()
			TweenService:Create(frame, TweenInfo.new(object.Style.Animated and object.Style.SlideTime or 0, object.Style.EasingStyle, Enum.EasingDirection.Out), {
				BackgroundColor3 = object.Style.BackgroundColor
			}):Play()
		end)
		
		searchGlass.MouseEnter:Connect(function()
			if object.IsOpen then return end
			
			TweenService:Create(searchGlass, TweenInfo.new(object.Style.Animated and object.Style.SlideTime or 0, object.Style.EasingStyle, Enum.EasingDirection.In), {
				ImageColor3 = object.Style.ActiveColor
			}):Play()
		end)
		
		searchGlass.MouseLeave:Connect(function()
			if object.IsOpen then return end
			
			TweenService:Create(searchGlass, TweenInfo.new(object.Style.Animated and object.Style.SlideTime or 0, object.Style.EasingStyle, Enum.EasingDirection.In), {
				ImageColor3 = object.Style.IdleColor
			}):Play()
		end)
	end
	
	object:Toggle(object.IsOpen)
	
	return object
end

function Searchbar:Clear()
	for _, child in pairs (self.Instance.Scroll:GetChildren()) do
		if child:IsA("UIListLayout") then continue end

		child:Destroy()
	end
end

function Searchbar:Search(keyword)
	if Terminus.Debug then print(self.ClassName, "Search", keyword) end
	
	local instance = self.Instance
	local scroll = instance.Scroll
	local searchbar = self
	local found = {}
	
	if string.len(keyword) == 0 and not self.ShowAllOnEmpty then
		return
	end
	
	self:Clear()
	
	for _, item in pairs (self.Items) do
		if string.find(string.lower(item), keyword) then
			table.insert(found, item)
			local built = self:ItemBuilder(item)
			if type(built) == "table" then
				built.Instance.Parent = scroll
			else
				built.Parent = scroll
			end
		end
	end
	
	if Terminus.Debug then print(self.ClassName, "Search Results", found) end
	
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
	
	self.IsOpen = state
	
	local instance = self.Instance
	local scroll = instance.Scroll

	if state then
		TweenService:Create(instance.Glass, TweenInfo.new(self.Style.Animated and self.Style.SlideTime or 0, self.Style.EasingStyle, Enum.EasingDirection.In), {
			ImageColor3 = self.Style.ActiveColor
		}):Play()
		
		local size = UDim2.new(1, 0, 0, 20 + self.Padding + (math.clamp(scroll.Sort.AbsoluteContentSize.Y, 0, self.MaxDisplay)))
		local dropTween = TweenService:Create(instance, TweenInfo.new(self.Style.Animated and self.Style.SlideTime or 0, self.Style.EasingStyle, Enum.EasingDirection.In),
			{["Size"] = size}
		)
		dropTween:Play()

		scroll.Visible = true
	else
		TweenService:Create(instance.Glass, TweenInfo.new(self.Style.Animated and self.Style.SlideTime or 0, self.Style.EasingStyle, Enum.EasingDirection.In), {
			ImageColor3 = self.Style.IdleColor
		}):Play()
		
		local dropTween = TweenService:Create(instance, TweenInfo.new(self.Style.Animated and self.Style.SlideTime or 0, self.Style.EasingStyle, Enum.EasingDirection.In),
			{["Size"] = UDim2.new(1, 0, 0, 20)}
		)
		dropTween:Play()

		dropTween.Completed:Connect(function(playbackState)
			if playbackState ~= Enum.PlaybackState.Completed then return end
			
			self.Searchbar.Text = ""
			
			scroll.Visible = false
			self:Clear()
		end)
	end
end

function Searchbar:Select(item)
	if self.CloseOnSelection then
		self:Toggle(false)
	end
	
	self:OnSelected(item)
end

function Searchbar:ItemBuilder(item)
	local searchbar = self
	
	return Terminal:CreateTextButton(TerminalTemporaryParent, {
		Style = self.Style:Clone(),
		Selectable = false,
		Text = item,
		Size = UDim2.new(1, -4, 0, self.Size.Y.Offset),
		OnActivated = function(self)
			searchbar:Select(item)
		end,
	})
end

function Searchbar:OnSelected(item)
	
end

--LISTVIEW-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local ListView = Component:Extend("ListView", {
	Size = UDim2.new(1, -4, 1, 0),
	Padding = 2
}, {
	Padding = function(self, v)
		local scroll = self.Instance

		scroll.Sort.Padding = UDim.new(0, v)
		scroll.CanvasSize = UDim2.new(0, 0, 0, scroll.Sort.AbsoluteContentSize.Y)
	end,
})

function ListView:new(parent, properties)
	local object = Component.new(self, properties)
	
	object.Items = object.Items or {}
	object.Built = {}
	
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
	
	for _, item in pairs (object.Items) do
		object:AddItem(item)
	end
	
	scroll.CanvasSize = UDim2.new(0, 0, 0, scroll.Sort.AbsoluteContentSize.Y)
	
	return object
end

function ListView:ItemBuilder(item)
	return Terminal:CreateTextLabel(TerminalTemporaryParent, {
		Style = self.Style:Clone(),
		Text = tostring(item),
	})
end

function ListView:AddItem(item)
	local built = self:ItemBuilder(item)
	if type(built) == "table" then built.Instance.Parent = self.Instance else built.Parent = self.Instance end
	
	table.insert(self.Built, {Item = item, Component = built})
	
	self.Instance.CanvasSize = UDim2.new(0, 0, 0, self.Instance.Sort.AbsoluteContentSize.Y)
end

function ListView:RemoveItem(item)
	for i = 1, #self.Built do
		local data = self.Built[i]
		if data.Item == item then
			if type(data.Component) == "table" then data.Component.Instance:Destroy() else data.Component:Destroy() end
			
			table.remove(self.Component, i)
			i = i - 1
		end
	end
	
	self.Instance.CanvasSize = UDim2.new(0, 0, 0, self.Instance.Sort.AbsoluteContentSize.Y)
end

--NOTICE-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local Notice = Component:Extend("Notice", {
	Title = "Notice",
	Body = "This is a notice",
	Dismissable = true,
	Size = UDim2.new(0, 200, 0, 150),
	Position = UDim2.new(0.5, 0, 0.5, 0),
	AnchorPoint = Vector2.new(0.5, 0.5),
}, {
	Title = function(self, v)
		self.Instance.Header.Text = v
	end,
	Body = function(self, v)
		self.Instance.Body.Text = v
	end,
})

function Notice:new(properties)
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
		frame:TweenPosition(object.Position, object.Style.EasingDirection, object.Style.EasingStyle, object.Style.Animated and object.Style.SlideTime or 0, true)
	else
		frame.Position = object.Position
	end
	
	if object.Dismissable then
		dismissField.Activated:Connect(function()
			object:Close()
		end)
	end
	
	button.Activated:Connect(function()
		object:Close()
	end)
	
	return object
end

function Notice:Close()
	if self.Style.Effects then
		self.Instance.Frame:TweenPosition(self.Position + UDim2.new(1, 0, 0, 0), self.Style.EasingDirection, self.Style.EasingStyle, self.Style.Animated and self.Style.SlideTime or 0, false, function()
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

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

function Terminal:CreateSwitch(parent, ...)
	parent = parent or self
	return Switch:new(parent, ...)
end

function Terminal:CreateSlider(parent, ...)
	parent = parent or self
	return Slider:new(parent, ...)
end

function Terminal:CreateDropdown(parent, ...)
	parent = parent or self
	return Dropdown:new(parent, ...)
end

function Terminal:CreateTextField(parent, ...)
	parent = parent or self
	return TextField:new(parent, ...)
end

function Terminal:CreateTextButton(parent, ...)
	parent = parent or self
	return TextButton:new(parent, ...)
end

function Terminal:CreateTextLabel(parent, ...)
	parent = parent or self
	return TextLabel:new(parent, ...)
end

function Terminal:CreateRow(parent, ...)
	parent = parent or self
	return Row:new(parent, ...)
end

function Terminal:CreateLine(parent, ...)
	parent = parent or self
	return Line:new(parent, ...)
end

function Terminal:CreateSearchbar(parent, ...)
	parent = parent or self
	return Searchbar:new(parent, ...)
end

function Terminal:CreateNotice(parent, ...)
	parent = parent or self
	return Notice:new(parent, ...)
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
	
	local name = ""
	for i = 1, 10 do
		name = name .. string.char(math.random(97, 122))
	end

	Gui.Name = name
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
	
	local terminal = Terminus:new("Settings", {
		ScrollContent = true
	})
	
	for k, v in pairs (terminal:ImportSettings()) do
		Settings[k] = v
	end
	
	terminal:CreateTextLabel(nil, {
		Text = "Settings"
	})
	
	terminal:CreateLine(nil)
	
	terminal:CreateRow(nil, {
		Layout = {0.5, 0.5},
		Size = UDim2.new(1, 0, 0, 24),
		Items = {
			terminal:CreateTextLabel(nil, {
				Text = "Toggle Key"
			}),
			terminal:CreateTextButton(nil, {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new(0.5, 0, 0.5, 0),
				Size = UDim2.new(1, 0, 0, 24),

				Text = Settings.ToggleKey,
				Selectable = false,
				OnActivated = function(self, state)
					self.Text = "Awaiting input"
					
					local input = UserInputService.InputBegan:Wait()
					local inputString = string.sub(tostring(input.KeyCode), string.len("Enum.KeyCode.") + 1)
					
					self.Text = inputString
					wait(RunService.RenderStepped:Wait())
					Settings.ToggleKey = inputString
					
					terminal:ExportSettings(Settings)
				end,
			}),
		}
	})
end

build()

table.insert(Events, UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	
	if input.KeyCode == Enum.KeyCode[Settings.ToggleKey] then
		Gui.Enabled = not Gui.Enabled
	end
end))

return Terminus
