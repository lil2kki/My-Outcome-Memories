_G.OMAnon_Name         = _G.OMAnon_Name or "LocalPlayer"
_G.OMAnon_DisplayName  = _G.OMAnon_DisplayName or "LocalPlayer"

print("[OMAnon] Now loading... Made by lil2kki <3")

if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local textConnections = {}

local function filter(label)
    if not label:IsA("TextLabel") and not label:IsA("TextButton") then return false end
    if not label.Parent then return false end
    local path = label:GetFullName()
    if path:find("skibidi board") then return true end
    if path:find("FUNPanel.Frame.ScrollingFrame.EX.TextButton") then return true end
    if path:find("FUNPanel.Frame.targ") then return true end
    if path:find(".Teamname") then return true end
    if path:find(".user") then return true end
    if path:find(".selected") then return true end
    return false
end

local function repl(label)
    if not filter(label) then return end
    local text = label.Text
    if string.find(text, LocalPlayer.DisplayName) or string.find(text, LocalPlayer.Name) then
        if not string.find(label:GetFullName(), "skibidi board") then
            warn("OMAnon repl at ", label:GetFullName())
        end
        text = text:gsub(LocalPlayer.Name, _G.OMAnon_Name)
        text = text:gsub(LocalPlayer.DisplayName, _G.OMAnon_DisplayName)
        label.Text = text
    end
end

local function cleanupLabel(label)
    local conn = textConnections[label]
    if conn then
        conn:Disconnect()
        textConnections[label] = nil
    end
end

local function onDescendantAdded(label)
    if not filter(label) then return end
    repl(label)
    if textConnections[label] then textConnections[label]:Disconnect() end
    textConnections[label] = label:GetPropertyChangedSignal("Text"):Connect(function() repl(label) end)
    label.Destroying:Connect(function() cleanupLabel(label) end)
end

for _, v in ipairs(LocalPlayer.PlayerGui:GetDescendants()) do
    onDescendantAdded(v)
end
LocalPlayer.PlayerGui.DescendantAdded:Connect(onDescendantAdded)

for _, v in ipairs(workspace.Lobby:GetDescendants()) do
    if v.Name == "skibidi board" then
        v.DescendantAdded:Connect(repl)
        for _, a in ipairs(v:GetDescendants()) do repl(a) end
    end
end

print("[OMAnon] Working on all texts for you! ~")
