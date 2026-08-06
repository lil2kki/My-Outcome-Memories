-- local CosmeticModule = loadstring(game:HttpGet("https://github.com/lil2kki/My-Outcome-Memories/raw/HEAD/CosmeticModule.lua"))()
-- CosmeticModule:Init()
-- CosmeticModule:ApplyToPlayer(character, characterName)

local CosmeticModule = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local AnimationService = require(ReplicatedStorage.Modules.Services.AnimationSerivce)

local cachedData = {
    playerOwns = {},
    selected = {},
    cosmeticsData = {}
}

function CosmeticModule:FetchPlayerData()
    local data = ReplicatedStorage.Remotes.DataUpdate:InvokeServer("FetchData", { "playerowns", "selected" })
    if data then
        cachedData.playerOwns = data[1] or {}
        cachedData.selected = data[2] or {}
        cachedData.cosmeticsData = data[3] or {}
        return data
    end
    return nil
end

function CosmeticModule:Weld(part0, part1)
    if not part0 or not part1 then return end
    
    local weldCFrame = part0.CFrame:toObjectSpace(part1.CFrame)
    local weld = Instance.new("Weld")
    
    weld.Name = part1.Name .. "_Weld"
    weld.Part0 = part0
    weld.Part1 = part1
    weld.C0 = weldCFrame
    weld.Parent = part0
    
    return weld
end

function CosmeticModule:ApplyCosmetic(character, cosmeticsData)
    if not character or not cosmeticsData then return end
    
    print("Applying cosmetics to:", character.Name)
    local anims = nil
    local colorData = nil
    
    for category, item in pairs(cosmeticsData) do
        if category ~= "Emotes" then
            if category == "Colors" then
                colorData = {category = category, item = item}
                continue
            end
            
            local cosmeticFolder = ReplicatedStorage.ClientAssets.Cosmetics[category]
            if not cosmeticFolder then continue end
            
            local cosmeticItem = cosmeticFolder:FindFirstChild(item)
            if not cosmeticItem then continue end
            
            local belongsTo = cosmeticItem:GetAttribute("Belongs")
            if belongsTo then
                local belongsList = {}
                for char in string.gmatch(tostring(belongsTo), "[^,]+") do
                    table.insert(belongsList, char)
                end
                
                local characterName = character.Name:lower()
                if not table.find(belongsList, characterName) then
                    continue
                end
            end
            
            local uniqueScript = cosmeticItem:FindFirstChild("Unique")
            if uniqueScript then
                local success, result = pcall(function()
                    return require(uniqueScript).load(character)
                end)
                if success then
                    print("Loaded unique cosmetic:", item)
                end
            end
            
            if cosmeticItem:HasTag("ComesticGroup") then
                for _, child in pairs(cosmeticItem:GetChildren()) do
                    if child.Name == "Unique" then continue end
                    
                    local weldTo = child:GetAttribute("WeldTo")
                    if weldTo then
                        for _, descendant in pairs(child:GetDescendants()) do
                            if descendant:IsA("BasePart") then
                                descendant.CanCollide = false
                                descendant.Anchored = false
                                descendant.CanTouch = false
                                descendant.CanQuery = false
                                descendant.Massless = true
                            end
                        end
                        
                        child.PrimaryPart = child:FindFirstChild("Weld") or child.PrimaryPart
                        
                        local targetPart = nil
                        if character:FindFirstChild(weldTo, true) then
                            targetPart = character:FindFirstChild(weldTo, true)
                            if not targetPart:IsA("BasePart") then
                                for _, part in pairs(character:GetDescendants()) do
                                    if part:IsA("BasePart") and part.Name == weldTo then
                                        targetPart = part
                                        break
                                    end
                                end
                            end
                        end
                        
                        if targetPart then
                            if weldTo == "Cheese" then
                                targetPart = character.cheese.HumanoidRootPart
                            end
                            
                            child:PivotTo(targetPart.CFrame)
                            child.Parent = character
                            self:Weld(child.PrimaryPart, targetPart)
                        end
                    end
                end
                
                local animsFolder = cosmeticItem:FindFirstChild("Anims")
                if animsFolder then
                    anims = animsFolder
                end
            else
                local weldTo = cosmeticItem:GetAttribute("WeldTo")
                if weldTo then
                    for _, descendant in pairs(cosmeticItem:GetDescendants()) do
                        if descendant:IsA("BasePart") then
                            descendant.CanCollide = false
                            descendant.Anchored = false
                            descendant.CanTouch = false
                            descendant.CanQuery = false
                            descendant.Massless = true
                        end
                    end
                    
                    cosmeticItem.PrimaryPart = cosmeticItem:FindFirstChild("Weld") or cosmeticItem.PrimaryPart
                    
                    local targetPart = nil
                    if character:FindFirstChild(weldTo, true) then
                        targetPart = character:FindFirstChild(weldTo, true)
                        if not targetPart:IsA("BasePart") then
                            for _, part in pairs(character:GetDescendants()) do
                                if part:IsA("BasePart") and part.Name == weldTo then
                                    targetPart = part
                                    break
                                end
                            end
                        end
                    end
                    
                    if targetPart then
                        if weldTo == "Cheese" then
                            targetPart = character.cheese.HumanoidRootPart
                        end
                        
                        cosmeticItem:PivotTo(targetPart.CFrame)
                        cosmeticItem.Parent = character
                        self:Weld(cosmeticItem.PrimaryPart, targetPart)
                        
                        local animsFolder = cosmeticItem:FindFirstChild("Anims")
                        if animsFolder then
                            anims = animsFolder
                        end
                    end
                end
            end
        end
    end
    
    if colorData then
        local colorCategory = colorData.category
        local colorItem = colorData.item
        local colorFolder = ReplicatedStorage.ClientAssets.Cosmetics[colorCategory]
        
        if colorFolder then
            local colorModule = colorFolder:FindFirstChild(colorItem)
            if colorModule then
                local belongsTo = colorModule:GetAttribute("Belongs")
                if belongsTo then
                    local belongsList = {}
                    for char in string.gmatch(tostring(belongsTo), "[^,]+") do
                        table.insert(belongsList, char)
                    end
                    
                    local characterName = character.Name:lower()
                    if not table.find(belongsList, characterName) then
                        return anims
                    end
                end
                
                local success, colorHandler = pcall(function()
                    return require(colorModule)
                end)
                
                if success and colorHandler then
                    if colorHandler.Unique then
                        colorHandler.Unique(character)
                    end
                    
                    if colorHandler.Types == "ColorBased" then
                        for _, part in pairs(character:GetDescendants()) do
                            if part:IsA("BasePart") and colorHandler.Color[tostring(part.Color)] then
                                part.Color = colorHandler.Color[tostring(part.Color)]
                            end
                        end
                    elseif colorHandler.Types == "SpecficPart" then
                        for _, part in pairs(character:GetDescendants()) do
                            if part:IsA("BasePart") and table.find(colorHandler.Find, part.Name) then
                                part.Color = colorHandler.Color
                            end
                        end
                    end
                    
                    local animsFolder = colorModule:FindFirstChild("Anims")
                    if animsFolder then anims = animsFolder end
                end
            end
        end
    end
    
    return anims
end

function CosmeticModule:PlayEmote(character, emoteData, characterName)
    if not character or not emoteData then return end
    
    print("Playing emote:", emoteData.AnimationId)
    
    local animation = AnimationService.RegisterAnimation(
        character,
        emoteData.AnimationId,
        characterName .. "_Emote",
        nil,
        true
    )
    
    animation:Play()
    
    if emoteData.MusicId and emoteData.MusicId ~= "rbxassetid://0" then
        local sound = Instance.new("Sound")
        sound.Name = "EmoteSong"
        sound.SoundId = emoteData.MusicId
        sound.Parent = script.Parent or character
        sound.Volume = emoteData.MusicVolume or 1
        sound.Looped = emoteData.IsLoop or false
        
        if emoteData.PlaybackRegion then
            sound.PlaybackRegionsEnabled = true
            sound.LoopRegion = emoteData.PlaybackRegion.LoopRegion
        end
        
        sound:Play()
        
        task.spawn(function()
            repeat task.wait()
            until not animation.IsPlaying
            
            TweenService:Create(sound, TweenInfo.new(0.5), {Volume = 0}):Play()
            task.wait(0.5)
            sound:Destroy()
        end)
    end
    
    return animation
end

function CosmeticModule:UpdateCharacter(characterModel, characterName, skinName, cosmeticsData, isEXE)
    if not characterModel or not characterName then return end
    
    for _, child in pairs(characterModel:GetChildren()) do
        child:Destroy()
    end
    
    local characterTemplate = nil
    local path = isEXE and "Characters.EXE" or "Characters.Survivors"
    
    if isEXE then
        characterTemplate = ReplicatedStorage.ClientAssets.Characters.EXE[characterName]
        if characterTemplate then
            characterTemplate = characterTemplate.Skins[skinName or "Default"]
        end
    else
        characterTemplate = ReplicatedStorage.ClientAssets.Characters.Survivors[characterName]
        if characterTemplate then
            characterTemplate = characterTemplate.Skins.Default
        end
    end
    
    if not characterTemplate then
        warn("Character template not found:", characterName)
        return
    end
    
    local newCharacter = characterTemplate:Clone()
    newCharacter.Parent = characterModel
    
    if newCharacter:FindFirstChild("HumanoidRootPart") then
        newCharacter.PrimaryPart = newCharacter.HumanoidRootPart
        newCharacter.PrimaryPart.Anchored = true
    end
    
    local anims = self:ApplyCosmetic(newCharacter, cosmeticsData)
    
    if newCharacter:FindFirstChild("Humanoid") and anims then
        local idleAnim = anims.Default and anims.Default.Idle
        if idleAnim then
            local animTrack = newCharacter.Humanoid:LoadAnimation(idleAnim)
            animTrack:Play(0)
        end
    end
    
    return newCharacter
end

function CosmeticModule:GetAvailableCosmetics(characterName, category)
    if not characterName or not category then return {} end
    
    local result = {}
    local cosmeticFolder = ReplicatedStorage.ClientAssets.Cosmetics[category]
    
    if not cosmeticFolder then return result end
    
    for _, item in pairs(cosmeticFolder:GetChildren()) do
        local belongsTo = item:GetAttribute("Belongs")
        if belongsTo then
            local belongsList = {}
            for char in string.gmatch(tostring(belongsTo), "[^,]+") do
                table.insert(belongsList, char)
            end
            
            if table.find(belongsList, characterName:lower()) then
                table.insert(result, item.Name)
            end
        end
    end
    
    return result
end

function CosmeticModule:SelectCosmetic(characterName, category, item, slot, isEXE)
    local data = {}
    local prefix = isEXE and "EXE" or "Survivors"
    
    if isEXE then
        data = {prefix, characterName, category, item, slot}
    else
        data = {prefix, characterName, category, item}
    end
    
    if slot then
        table.insert(data, slot)
    end
    
    local result = ReplicatedStorage.Remotes.DataUpdate:InvokeServer("Select", data)
    return result
end

function CosmeticModule:PreviewEmote(character, emoteName, characterName, isEXE)
    local data = {}
    local prefix = isEXE and "EXE" or "Survivors"
    
    if isEXE then
        data = {prefix, characterName, emoteName}
    else
        data = {prefix, characterName, emoteName}
    end
    
    local result = ReplicatedStorage.Remotes.DataUpdate:InvokeServer("PreviewEmote", unpack(data))
    return result
end

function CosmeticModule:ApplyToPlayer(character, characterName)
    if not character or not characterName then
        warn("Character and character name required")
        return
    end
    
    local data = self:FetchPlayerData()
    if not data then
        warn("Failed to fetch player data")
        return
    end
    
    local cosmetics = cachedData.selected.SelectedCosmetics
    if cosmetics and cosmetics[characterName] then
        return self:ApplyCosmetic(character, cosmetics[characterName])
    end
    
    return nil
end

function CosmeticModule:ApplySkin(character, characterName, skinName, isEXE)
    local path = isEXE and "EXE" or "Survivors"
    local characterData = ReplicatedStorage.ClientAssets.Characters[path][characterName]
    
    if not characterData then
        warn("Character not found:", characterName)
        return
    end
    
    local skinTemplate = characterData.Skins[skinName or "Default"]
    if not skinTemplate then
        warn("Skin not found:", skinName)
        return
    end
    
    local newCharacter = skinTemplate:Clone()
    
    local cosmeticsData = {}
    
    return newCharacter
end

function CosmeticModule:HasCosmetic(characterName, category, item)
    if not cachedData.playerOwns then
        self:FetchPlayerData()
    end
    
    local playerCosmetics = cachedData.playerOwns[characterName]
    if not playerCosmetics then return false end
    
    local categoryData = playerCosmetics[category]
    if not categoryData then return false end
    
    return categoryData[item] ~= nil
end

function CosmeticModule:GetPlayerCosmetics(characterName)
    if not cachedData.playerOwns then
        self:FetchPlayerData()
    end
    
    return cachedData.playerOwns[characterName] or {}
end

function CosmeticModule:Init()
    self:FetchPlayerData()
    print("CosmeticModule initialized")
end

return CosmeticModule
