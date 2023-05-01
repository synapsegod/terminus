# Terminus
Terminus is a singleton UI toolkit and window with interactive components.
Completely open sourced code to counter existing "pay to use" or "join my discord for a virus" terminals.
To toggle visibility use the right control key

## Usage
```lua
local Terminus = game:GetService("RunService"):IsStudio() and require(game.ReplicatedFirst:WaitForChild("Terminus")) or (shared.Terminus or loadstring(game:HttpGet("https://raw.githubusercontent.com/synapsegod/terminus/main/main.lua"))())
```

GUI objects in Terminus can be created without necessarily having a variable to reference them, everything can be passed over when instantiating the object, see examples within each GUI object

Changing properties marked with STATE forces the component to call SetState()
Changing properties marked with LINKED will force the component to update its instances that utilize said property.
Properties that are readonly are marked with READONLY

## Terminal
Each program can have one "Window", this should be used once in your exploit unless you have a script that creates multiple programs
The name **must** be unique
Using ImportSettings and ExportSettings lets you store a table for your program, can be found under workspace\NAME\Settings.json

### Fields
```lua
ClassName : string = "Terminal" -> READONLY
ScrollContent : boolean = false -> READONLY
Padding : number = 5 -> LINKED
Visible : boolean = false -> STATE
Instance : GuiObject -> READONLY
```

### Methods
```lua
Terminal:CreateSwitch(parent : GuiObject? | Component? = Terminal.Instance, properties : {[string] = any}?) : Switch
Terminal:CreateSlider(parent : GuiObject? | Component? = Terminal.Instance, properties : {[string] = any}?) : Slider
Terminal:CreateDropdown(parent : GuiObject? | Component? = Terminal.Instance, properties : {[string] = any}?) : Dropdown
Terminal:CreateTextField(parent : GuiObject? | Component? = Terminal.Instance, properties : {[string] = any}?) : TextField
Terminal:CreateTextButton(parent : GuiObject? | Component? = Terminal.Instance, properties : {[string] = any}?) : TextButton
Terminal:CreateTextLabel(parent : GuiObject? | Component? = Terminal.Instance, properties : {[string] = any}?) : TextLabel
Terminal:CreateRow(parent : GuiObject? | Component? = Terminal.Instance, properties : {[string] = any}?) : Row
Terminal:CreateLine(parent : GuiObject? | Component? = Terminal.Instance, properties : {[string] = any}?) : Line
Terminal:CreateSearchbar(parent : GuiObject? | Component? = Terminal.Instance, properties : {[string] = any}?) : Searchbar
Terminal:SetState()
Terminal:GetStorage() : string
Terminal:ImportSettings() : {[string] = any?}
Terminal:ExportSettings(data : {[string] = any?})
Terminal:IsMouseOnTop() : boolean
Terminal:Toggle(state : boolean = not self.Visible)
Terminal:OnClose()
```

## Style
All ui elements and terminals have a Style in them for their design.
If a component has no style parameter it uses the style of the Terminal, which consecutively, defaults if it terminal has none either.

### Fields
```lua
Colors : {} = {
	Orange = Color3.fromRGB(255, 170, 0),
	Blue = Color3.fromRGB(0, 170, 255),
	Green = Color3.fromRGB(0, 170, 127),
	Pink = Color3.fromRGB(255, 49, 149),
	Black = Color3.fromRGB(30, 30, 30),
	Purple = Color3.fromRGB(147, 93, 255),
	Red = Color3.fromRGB(255, 92, 92)
}
ActiveColor : Color3 = Color3.fromRGB(0, 170, 255)
IdleColor : Color3 = Color3.fromRGB(240, 240, 240)
BackgroundColor : Color3 = Color3.fromRGB(70, 70, 70)
SlideTime : number = 0.25
EasingStyle : EasingStyle = Enum.EasingStyle.Quad
CornerRadius : number = 4
FontFace : Font = Font.fromEnum(Enum.Font.Jura)
Effects : boolean = true
Brighten : number = 0.1
SmallTextSize : number = 10
NormalTextSize : number = 14
HeaderTextSize : number = 18
Animated : boolean = true
```

### Methods
```lua
Style:Clone(properties : {}) : Style
```

## Switch
A switch is used for a boolean value; on off switch

### Fields
```lua
ClassName : string = "Switch" -> READONLY
Style : Style = self.Style
State : boolean = false -> STATE
AnchorPoint : Vector2 = Vector2.new(0, 0) -> LINKED
Position : UDim2 = UDim2.new(0, 0, 0, 0) -> LINKED
Height : number = 20 -> LINKED
Instance : GuiObject -> READONLY
```

### Methods
```lua
Switch:SetState()
Switch:Toggle(state : boolean? = not self.State)
Switch:OnChanged(value : boolean)
```

## Slider
The slider is used to select a number in a specific range

### Fields
```lua
ClassName : string = "Slider" -> READONLY
Style : Style = self.Style
ShowTip : boolean = true
Minimum : number = 1
Maximum : number = 10
Fill : boolean = true
Value : number = 1 -> STATE
Size : UDim2 = UDim2.new(1, 0, 0, 20) -> LINKED
AnchorPoint : Vector2 = Vector2.new(0, 0) -> LINKED
Position : UDim2 = UDim2.new(0, 0, 0, 0) -> LINKED
Instance : GuiObject -> READONLY
```

### Methods
```lua
Slider:SetState()
Slider:SetValue(value : number)
Slider:OnChanged(value : number)
Slider:OnFinished()
```

## Dropdown
The dropdown is used to select one or more of many in a list of items
If you want a custom item inside the dropdown (can be a Component) utility the ItemBuilder function

### Fields
```lua
ClassName : string = "Dropdown" -> READONLY
Items : {string} = {}
Selected : {string} | any? = {} | nil
Style : Style = self.Style
Padding : number = 2 -> LINKED
MaxDisplay : number = 300
CloseOnSelect : boolean = false
MultiSelect : boolean = true
IsOpen : boolean = false
Title : string = "Dropdown" -> LINKED
Size : UDim2 = UDim2.new(1, 0, 0, 20) -> LINKED
Position : UDim2 = UDim2.new(0, 0, 0, 0) -> LINKED
AnchorPoint : Vector2 = Vector2.new(0, 0) -> LINKED
Instance : GuiObject -> READONLY
```

### Methods
```lua
Dropdown:ItemBuilder(item : any) : GuiObject | Component
Dropdown:Select(item : any)
Dropdown:IsSelected(item : any)
Dropdown:Toggle(state : boolean? = not self.IsOpen)
Dropdown:OnSelected(item : any)
```

## TextField
A textfield is used to input text or numbers

### Fields
```lua
ClassName : string = "TextField" -> READONLY
Style : Style = self.Style
NumbersOnly : boolean = false
OnlyUpdateOnEnter : boolean = false
Size : UDim2 = UDim2.new(1, 0, 0, 20) -> LINKED
Position : UDim2 = UDim2.new(0, 0, 0, 0) -> LINKED
AnchorPoint : Vector2 = Vector2.new(0, 0) -> LINKED
Text : string = "" LINKED
PlaceholderText : string = "" -> LINKED
PlaceholderColor : Color3 = Color3.fromRGB(200, 200, 200) -> LINKED
Instance : GuiObject -> READONLY
```

### Methods
```lua
TextField:OnChanged(text : string | number?)
TextField:Trim() : string
```

## TextButton
A text button

### Fields
```lua
ClassName : string = "TextButton" -> READONLY
Style : Style = self.Style
Splash : boolean = true
Selectable : boolean = true
Selected : boolean = false -> STATE
Text : string = "Button" -> LINKED
Size : UDim2 = UDim2.new(1, 0, 0, 26) -> LINKED
Position : UDim2 = UDim2.new(0, 0, 0, 0) -> LINKED
AnchorPoint : Vector2 = Vector2.new(0, 0) -> LINKED
Instance : GuiObject -> READONLY
```

### Methods
```lua
TextButton:SetState()
TextButton:Toggle(state : boolean? = not self.Selected)
TextButton:OnSelected(state : boolean)
TextButton:OnActivated()
```

## TextLabel
A text label

### Fields
```lua
ClassName : string = "TextLabel" -> READONLY
Style : Style = self.Style
Text : string = "" -> LINKED
Size : UDim2 = UDim2.new(1, 0, 0, 20) -> LINKED
Position : UDim2 = UDim2.new(0, 0, 0, 0) -> LINKED
AnchorPoint : Vector2 = Vector2.new(0, 0) -> LINKED
TextColor : Color3 = Color3.fromRGB(240, 240, 240) -> LINKED
Instance : GuiObject -> READONLY
```

## Row
A row that splits its children into different or equally distributed sizes
#Layout must be equal to #Items or [if nil] it will be evenly divided
Items inside should be centered if not full-scaled (use Position and AnchorPoint)
Can contain GuiObjects or Components
For example you want a 0.25 - 0.75 split then Layout = {0.25, 0.75}
If you have more or less than 2 items it will reset to 1 / #Items

### Fields
```lua
ClassName : string = "Row" -> READONLY
Style : Style = Style:new()
Layout : {number} = {} -> LINKED
Items : {GuiObject | object} -> READONLY
Size : UDim2 = UDim2.new(1, 0, 0, 20) -> LINKED
Position : UDim2 = UDim2.new(0, 0, 0, 0) -> LINKED
AnchorPoint : Vector2 = Vector2.new(0, 0) -> LINKED
```

## Line
A simple line

### Fields
```lua
ClassName : string = "Line" -> READONLY
Style : Style = Terminal.Style
Size : UDim2 = UDim2.new(1, 0, 0, 1) -> LINKED
Position : UDim2 = UDim2.new(0, 0, 0, 0) -> LINKED
AnchorPoint : Vector2 = Vector2.new(0, 0) -> LINKED
Instance : GuiObject -> READONLY
```

## Searchbar
Similar to Dropdown, except it is searchable

### Fields
```lua
ClassName : string = "Searchbar" -> READONLY
Style : Style = Terminal.Style
MaxDisplay : number = 300
Padding : number = 2 -> LINKED
SearchOnEnter : boolean = true
PlaceholderText : string = "Search..." -> LINKED
PlaceholderColor : Color3 = Color3.fromRGB(200, 200, 200) -> LINKED
ShowAllOnEmpty : boolean = false
CloseOnSelection : boolean = true
IsOpen : boolean = false
Size : UDim2 = UDim2.new(1, 0, 0, 20) -> LINKED
Position : UDim2 = UDim2.new(0, 0, 0, 0) -> LINKED
AnchorPoint : Vector2 = Vector2.new(0, 0) -> LINKED
Instance : GuiObject -> READONLY
```

### Methods
```lua
Searchbar:Clear()
Searchbar:Search(keyword : string)
Searchbar:Toggle(state : boolean = not self.IsOpen)
Searchbar:Select(item : string)
Searchbar:ItemBuilder(item : string) : Instance | Component
Searchbar:OnSelected(item : string)
```
## ListView
TODO
