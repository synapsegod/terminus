# Terminus
Terminus is a singleton UI toolkit and window for running and altering exploit-variables during runtime.
Completely open sourced code to counter existing "pay to use" or "join my discord for a virus" terminals.
To toggle visibility use the right control key
## Usage
```lua
local Terminus = shared.Terminus or loadstring(game:HttpGet("https://raw.githubusercontent.com/synapsegod/terminus/main/main.lua"))()
```
## Quick example
```lua
local Terminus = shared.Terminus or loadstring(game:HttpGet("https://raw.githubusercontent.com/synapsegod/terminus/main/main.lua"))()
local MyStyle = Terminus:newStyle({
	ActiveColor = Color3.fromRGB(85, 170, 127),
	IdleColor = Color3.fromRGB(240, 240, 240),
	BackgroundColor = Color3.fromRGB(70, 70, 70),
	SlideTime = 0.25,
	EasingStyle = Enum.EasingStyle.Quad,
	CornerRadius = 4,
	FontFace = Font.new("rbxasset://fonts/families/Ubuntu.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
	Effects = true,
	Brighten = 0.1
})
local Terminal = Terminus:new("MyExploit")
local switch = Terminal:CreateSwitch(nil, {
  Style = MyStyle
})
function switch:OnChanged(value)
  print("Switchvalue is now", value)
end

local slider = Terminal:CreateSlider(nil, {
  Style = MyStyle,
  Minimum = 0,
  Maximum = 100
})

function slider:OnChanged(value)
  print("Slidervalue is now", value)
end
```
## Style
All ui elements and terminals have a Style in them for their design
### Creation
```lua
local styleForMyButton = Terminus:newStyle(properties : {[string] = any})
```
### Fields
```lua
ActiveColor : Color3 =  Color3.fromRGB(0, 170, 255)
IdleColor : Color3 = Color3.fromRGB(240, 240, 240)
BackgroundColor : Color3 = Color3.fromRGB(70, 70, 70)
SlideTime : number = 0.25
EasingStyle : Enum.EasingStyle = Enum.EasingStyle.Quad
CornerRadius : number = 4
FontFace : Font = Font.new("Zekton", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
Effects : boolean = true
Brighten : number = 0.1
```
## Terminal
### Creation
```
local Terminal = Terminus:new("MyExploit")
```
### Fields
```lua
Style : Style = Style:new()
HorizontalAlignment : Enum.HorizontalAlignment = Enum.HorizontalAlignment.Center
VerticalAlignment : Enum.VerticalAlignment = Enum.VerticalAlignment.Top
Padding : number = 5
```
### Methods
Specify desired object fields with the properties parameter instead of after object creation
GuiObject associated with object can be found with object.Instance
For exact GuiObject layout browse [main](https://github.com/synapsegod/terminus/blob/main/main.lua)
```lua
Terminal:CreateSwitch(parent : GuiObject? | Terminal.Window, properties : {[string] = any}) : Switch
Terminal:CreateSlider(parent : GuiObject? | Terminal.Window, properties : {[string] = any}) : Slider
Terminal:CreateDropdown(parent : GuiObject? | Terminal.Window, properties : {[string] = any}) : Dropdown
Terminal:CreateTextField(parent : GuiObject? | Terminal.Window, properties : {[string] = any}) : TextField
Terminal:CreateTextButton(parent : GuiObject? | Terminal.Window, properties : {[string] = any}) : TextButton
```
## Switch
### Fields
```lua
State : boolean = false
Style : Style = Style:new()
Instance : GuiObject
````
### Methods
```lua
Switch:Toggle(state : boolean?)
Switch:OnChanged(value : boolean)
```
## Slider
### Fields
```lua
ShowTip : boolean = true
Minimum : number = 1
Maximum : number = 10
Fill : boolean = true
Style : Style = Style:new()
Value : number = -1
Instance : GuiObject
```
### Methods
```lua
Slider:SetValue(value : number)
Slider:OnChanged(value : number)
```
## Dropdown
### Fields
```lua
Style : Style = Style:new()
Padding : number = 2
CloseOnSelect : boolean = true
MultiSelect : boolean = true
IsOpen : boolean = false
Instance : GuiObject
```
### Methods
```lua
Dropdown:Select(item : string)
Dropdown:AddItem(item : string)
Dropdown:RemoveItem(item : string)
Dropdown:IsSelected(item : string)
Dropdown:SetTitle(title : string)
Dropdown:Toggle(state : boolean?)
Dropdown:OnSelected(item : string?)
```
## TextField
### Fields
```lua
Style : Style = Style:new()
NumbersOnly : boolean = false
Value : string = ""
Instance : GuiObject
```
### Methods
```lua
TextField:OnChanged(text : string)
```
## TextButton
### Fields
```lua
Style : Style = Style:new()
Splash : boolean = true
Selectable : boolean = true
Selected : boolean = false
Instance : TextButton
```
### Methods
```lua
TextButton:Toggle(state : boolean?)
TextButton:OnSelected(state : boolean)
```
## TextLabel
### Fields
```lua
Style : Style = Style:new()
Instance : TextButton
```
### Methods
```lua
TextLabel:SetText(text : string)
```
