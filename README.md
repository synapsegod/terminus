# Terminus
Terminus is a singleton UI toolkit and window for running your roblox exploits
## Usage
```lua
local Terminus = shared.Terminus or loadstring(game:HttpGet("https://raw.githubusercontent.com/synapsegod/terminus/main/main.lua"))()
```
## Terminal Class
### Creation
```
local Terminal = Terminus:new("MyExploit")
```
### Switch
```lua
local switch = Terminal:CreateSwitch(parent : GuiObject? | Terminal.Window, properties : {[string] = any})
```
