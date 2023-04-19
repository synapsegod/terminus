# Terminus
Terminus is a singleton UI toolkit and window for running and altering exploit-variables during runtime.
Completely open sourced code to counter existing "pay to use" or "join my discord for a virus" terminals.
To toggle visibility use the right control key

## Usage
```lua
local Terminus = shared.Terminus or loadstring(game:HttpGet("https://raw.githubusercontent.com/synapsegod/terminus/main/main.lua"))()
```
GUI objects in Terminus can be created without necessarily having a variable to reference them, everything can be passed over when instantiating the object, see examples within each GUI object

Objects are one way bound with the Instance representing them
Fields marked with LINK will change their Instance depending on the property
So if you would normally do object:SetText("text") you can just do object.Text = "text"

## Style
All ui elements and terminals have a Style in them for their design
### Example
```lua
local MyStyle = Terminus:newStyle({
	ActiveColor = Color3.fromRGB(85, 170, 127),
	IdleColor = Color3.fromRGB(240, 240, 240),
	BackgroundColor = Color3.fromRGB(70, 70, 70),
})
```
### Fields
```lua
ActiveColor : Color3 =  Color3.fromRGB(0, 170, 255)
IdleColor : Color3 = Color3.fromRGB(240, 240, 240)
BackgroundColor : Color3 = Color3.fromRGB(70, 70, 70)
SlideTime : number = 0.25
EasingStyle : Enum.EasingStyle = Enum.EasingStyle.Quad
CornerRadius : number = 4
FontFace : Font = Font.new("rbxasset://fonts/families/Jura.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
Effects : boolean = true
Brighten : number = 0.1
```

## Terminal
Each exploit can have one "Window", this should be used once in your exploit unless you have a script that creates multiple exploits
The name must be unique
The Style property is only used for the button that represents this exploit
### Example
```
local Terminal = Terminus:new("MyExploit", {Style = MyStyle})
```
### Fields
```lua
Style : Style = Style:new()
```
### Methods
```lua
Terminal:CreateSwitch(parent : GuiObject? = Terminal.Window, properties : {[string] = any}?) : Switch
Terminal:CreateSlider(parent : GuiObject? = Terminal.Window, properties : {[string] = any}?) : Slider
Terminal:CreateDropdown(parent : GuiObject? = Terminal.Window, properties : {[string] = any}?) : Dropdown
Terminal:CreateTextField(parent : GuiObject? = Terminal.Window, properties : {[string] = any}?) : TextField
Terminal:CreateTextButton(parent : GuiObject? = Terminal.Window, properties : {[string] = any}?) : TextButton
Terminal:CreateTextLabel(parent : GuiObject? = Terminal.Window, properties : {[string] = any}?) : TextLabel
Terminal:CreateRow(parent : GuiObject? = Terminal.Window, properties : {[string] = any}?) : Row
Terminal:CreateLine(parent : GuiObject? = Terminal.Window, properties : {[string] = any}?) : Line
```

## Switch
### Example
```lua
local switch = Terminal:CreateSwitch(nil, {
	State = true,
	OnChanged = function(self, state)
		print("State", state)
	end
})
```
### Fields
```lua
Style : Style = Style:new()
State : boolean = false
AnchorPoint : Vector2 = Vector2.new(0, 0) LINK
Position : UDim2 = UDim2.new(0, 0, 0, 0) LINK
Instance : GuiObject
````
### Methods
```lua
Switch:Toggle(state : boolean?)
Switch:OnChanged(value : boolean)
```

## Slider
The slider is used to select a number between a specific range
### Example
```lua
Terminal:CreateSlider(nil, {
	Style = MyStyle,
	Minimum = 0,
	Maximum = 15,
	Value = 10,
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.new(0.5, 0, 0.5, 0),
	Size = UDim2.new(1, -20, 0, 20),
	OnChanged = function(self, value)
		print("Slider changed", value)
	end
})
```
### Fields
```lua
Style : Style = Style:new()
ShowTip : boolean = true
Minimum : number = 1
Maximum : number = 10
Fill : boolean = true
Value : number = 1
Size : UDim2 = UDim2.new(1, 0, 0, 20) LINK
AnchorPoint : Vector2 = Vector2.new(0, 0) LINK
Position : UDim2 = UDim2.new(0, 0, 0, 0) LINK
Instance : GuiObject
```
### Methods
```lua
Slider:SetValue(value : number)
Slider:OnChanged(value : number)
```

## Dropdown
The dropdown is used to select one or more of many in a list of items
### Example
```lua
Terminal:CreateDropdown(nil, {
	Style = MyStyle,
	Items = {"Item1", "Item2", "Item3"},
	Selected = {"Item1", "Item3"},
	MultiSelect = true,
	CloseOnSelect = false,
	Title = "My dropdown",
	OnSelected = function(self, value)
		
	end,
	OnToggleDone = function(self, value)
		--Scroll.CanvasSize = UDim2.new(0, Sorter.AbsoluteContentSize.X, 0, Sorter.AbsoluteContentSize.Y)
	end,
})
```
### Fields
```lua
Style : Style = Style:new()
Padding : number = 2
Items : {string} = {}
Selected : {string} = {}
MaxDisplay : number = 3
CloseOnSelect : boolean = true
MultiSelect : boolean = true
IsOpen : boolean = false
Title : string = "Dropdown" LINK
Instance : GuiObject
```
### Methods
```lua
Dropdown:Select(item : string)
Dropdown:AddItem(item : string)
Dropdown:RemoveItem(item : string)
Dropdown:IsSelected(item : string)
Dropdown:Toggle(state : boolean?)
Dropdown:OnToggleStart(state : boolean)
Dropdown:OnToggleDone(state : boolean)
Dropdown:OnSelected(item : string?)
```

## TextField
A textfield is used to input text or a number
### Fields
```lua
Style : Style = Style:new()
NumbersOnly : boolean = false
Size : UDim2 = UDim2.new(1, 0, 0, 20) LINK
Position : UDim2 = UDim2.new(0, 0, 0, 0) LINK
AnchorPoint : Vector2 = Vector2.new(0, 0) LINK
Text : string = "" LINK
Instance : GuiObject
```
### Methods
```lua
TextField:OnChanged(text : string)
TextField:Trim() : string
```

## TextButton
A button that makes use of its Style object
### Example
```lua
Terminal:CreateTextButton(Scroll, {
	Style = MyStyle,
	Text = RUNNING and "Stop" or "Start",
	Selectable = true,
	OnSelected = function(self, state)
		RUNNING = state
		self.Text = state and "Stop" or "Start"
		if RUNNING then
			--start
		else
			--stop
		end
	end,
})
```
### Fields
```lua
Style : Style = Style:new()
Splash : boolean = true
Selectable : boolean = true
Selected : boolean = false
Text : string = "Button" LINK
Size : UDim2 = UDim2.new(1, 0, 0, 26) LINK
Position : UDim2 = UDim2.new(0, 0, 0, 0) LINK
AnchorPoint : Vector2 = Vector2.new(0, 0) LINK
Instance : TextButton
```
### Methods
```lua
TextButton:Toggle(state : boolean?)
TextButton:OnSelected(state : boolean)
TextButton:OnActivated()
```

## TextLabel
A basic text label that makes use of its Style object
### Example
```lua
Terminal:CreateTextLabel(nil, {Style = MyStyle, Text = "My exploit header"})
```
### Fields
```lua
Style : Style = Style:new()
Text : string = "" LINK
Size : UDim2 = UDim2.new(1, 0, 0, 26) LINK
Position : UDim2 = UDim2.new(0, 0, 0, 0) LINK
AnchorPoint : Vector2 = Vector2.new(0, 0) LINK
TextColor : Color3 = Color3.fromRGB(240, 240, 240) LINK
Instance : TextButton
```

## Row
A row that splits its children into different or equally distributed sizes
#Layout must be equal to #Items or it will all be evenly divided
Items inside should be centered if not full-scaled
Items should consist of either GuiObjects or Terminus generated GUI objects (object.Instance will be used)
### Example
```lua
Terminal:CreateRow(Scroll, {
	Style = MyStyle,
	Layout = {0.5, 0.5},
	Size = UDim2.new(1, 0, 0, 20),
	Items = {
		Terminal:CreateTextLabel(nil, {
			Style = MyStyle,
			Text = "My switch 2"
		}),
		Terminal:CreateSwitch(Scroll, {
			Style = MyStyle,
			State = true,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			OnChanged = function(self, state)

			end,
		})
	}
})
```
### Fields
```lua
Style : Style = Style:new()
Size : UDim2 = UDim2.new(1, 0, 1, 0) LINK
Layout : {number} = {}
Items : {GuiObject | object}
Position : UDim2 = UDim2.new(0, 0, 0, 0) LINK
AnchorPoint : Vector2 = Vector2.new(0, 0) LINK
```

## Line
A simple horizontal line
### Example
```lua
Terminal:CreateLine(Scroll, {
	Style = MyStyle,
	Size = UDim2.new(1, -10, 0, 1)
})
```
### Fields
```lua
Style : Style = Style:new()
Size : UDim2 = UDim2.new(1, 0, 1, 0) LINK
Position : UDim2 = UDim2.new(0, 0, 0, 0) LINK
AnchorPoint : Vector2 = Vector2.new(0, 0) LINK
```
