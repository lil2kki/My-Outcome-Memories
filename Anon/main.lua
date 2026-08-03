_G.OMAnon_Name         = _G.OMAnon_Name or "LocalPlayer"
_G.OMAnon_DisplayName  = _G.OMAnon_DisplayName or "LocalPlayer"

print("[OMAnon] Now loading... Made by lil2kki <3")

function repl(label)
    if not label:IsA("TextLabel") and not label:IsA("TextButton") then return end
    if not label.Parent then return end
    local text = label.Text
    if string.find(text, game.Players.LocalPlayer.DisplayName) or string.find(text, game.Players.LocalPlayer.Name) then
        --warn("OMAnon repl at ", label:GetFullName())
        text = text:gsub(game.Players.LocalPlayer.Name, _G.OMAnon_Name)
        text = text:gsub(game.Players.LocalPlayer.DisplayName, _G.OMAnon_DisplayName)
        label.Text = text
    end
end

function onDescendantAdded(label)
    if not label:IsA("TextLabel") and not label:IsA("TextButton") then return end
    if not label.Parent then return end
    repl(label)
    if not _G.OMAnon_WasExecuted then label:GetPropertyChangedSignal("Text"):Connect(function() repl(label) end) end
end

for _, v in ipairs(game.Players.LocalPlayer.PlayerGui:GetDescendants()) do onDescendantAdded(v) end
game.Players.LocalPlayer.PlayerGui.DescendantAdded:Connect(onDescendantAdded)

for _, v in ipairs(workspace.Lobby:GetDescendants()) do 
    if v.Name == "skibidi board" then 
        if not _G.OMAnon_WasExecuted then v.DescendantAdded:Connect(repl) end
        for _, a in ipairs(v:GetDescendants()) do repl(a) end
    end
end

_G.OMAnon_WasExecuted = true

print("[OMAnon] Working on all texts for you! ~")
