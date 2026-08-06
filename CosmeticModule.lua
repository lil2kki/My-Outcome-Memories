
    local CosmeticModule = loadstring(
[[
-- CosmeticModule.lua
local CosmeticModule = {}

local function setupPart(p)
    for _, v in p:GetDescendants() do
        if v:IsA("BasePart") then
            v.CanCollide, v.Anchored, v.CanTouch, v.CanQuery, v.Massless 
            = false,        false,      false,      false,      true
        end
    end
end

local function findTarget(char, name)
    if name == "Cheese" then return char.cheese.HumanoidRootPart end
    local target = char:FindFirstChild(name, true)
    if target and not target:IsA("BasePart") then
        for _, v in char:GetDescendants() do
            if v:IsA("BasePart") and v.Name == name then target = v break end
        end
    end
    return target
end

local function weld(a, b)
    if not a or not b then return end
    local w = Instance.new("Weld")
    w.Name, w.Part0, w.Part1, w.C0, w.Parent = b.Name.."_Weld", a, b, a.CFrame:toObjectSpace(b.CFrame), a
    return w
end

local function applyColor(char, item)
    local mod = item
    
    print("applyColor", mod.Name)
    
    pcall(UnlockModule, mod)
    local ok, handler = pcall(require, mod)
    pcall(LockModule, mod)
    if not ok then return end
    
    if handler.Unique then handler.Unique(char) end
    if handler.Types == "ColorBased" then
        for _, p in char:GetDescendants() do
            if p:IsA("BasePart") and handler.Color[tostring(p.Color)] then
                p.Color = handler.Color[tostring(p.Color)]
            end
        end
    elseif handler.Types == "SpecficPart" then
        for _, p in char:GetDescendants() do
            if p:IsA("BasePart") and table.find(handler.Find, p.Name) then
                p.Color = handler.Color
            end
        end
    end
end

local function applyItem(char, item)
    local obj = item:Clone()

    print("applyItem", obj.Name)
    
    local unique = obj:FindFirstChild("Unique")
    if unique then
        pcall(UnlockModule, unique) 
        pcall(require(unique).load, char) 
        pcall(LockModule, unique)
    end
    
    local weldTo = obj:GetAttribute("WeldTo")
    if obj:HasTag("ComesticGroup") then
        for _, child in obj:GetChildren() do
            if child.Name == "Unique" then continue end
            setupPart(child)
            child.PrimaryPart = child:FindFirstChild("Weld") or child.PrimaryPart
            local target = findTarget(char, child:GetAttribute("WeldTo"))
            if target then
                child:PivotTo(target.CFrame)
                child.Parent = char
                weld(child.PrimaryPart, target)
            end
        end
    elseif weldTo then
        setupPart(obj)
        obj.PrimaryPart = obj:FindFirstChild("Weld") or obj.PrimaryPart
        local target = findTarget(char, weldTo)
        if target then
            obj:PivotTo(target.CFrame)
            obj.Parent = char
            weld(obj.PrimaryPart, target)
        end
    end
end

function CosmeticModule:Apply(character, itemsString)
    if not character or not itemsString or itemsString == "" then return end
    
    for item in string.gmatch(itemsString, "[^,]+") do
        for a, Folder in pairs(game.ReplicatedStorage.ClientAssets.Cosmetics:GetChildren()) do
            if not Folder:FindFirstChild(item) then continue end
            if Folder.Name == "Colors" then
                applyColor(character, Folder[item])
            else
                applyItem(character, Folder[item]) 
            end
        end
    end
    
    print("Applied cosmetics to", character.Name)
end

return CosmeticModule

]]
    )()
    CosmeticModule:Apply(player, player:GetAttribute("EquippedCosmetics"))
