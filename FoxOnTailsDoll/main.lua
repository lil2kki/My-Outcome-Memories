print("[FoxOnTailsDoll] Now loading... Made by lil2kki <3")

game.ReplicatedStorage.ClientAssets.Sounds.mus.Game.Round.ChaseThemes.TailsDoll.Default.NormalChase:Destroy()
game.ReplicatedStorage.ClientAssets.Sounds.mus.Game.Round.ChaseThemes["2011x"].FeelstheRabbit.NormalChase:Clone()
.Parent = game.ReplicatedStorage.ClientAssets.Sounds.mus.Game.Round.ChaseThemes.TailsDoll.Default

game.ReplicatedStorage.ClientAssets.Characters.EXE.TailsDoll.Skins.Default:Destroy()
game.ReplicatedStorage.ClientAssets.Characters.Survivors.Tails.Skins.Default:Clone()
.Parent = game.ReplicatedStorage.ClientAssets.Characters.EXE.TailsDoll.Skins

game.ReplicatedStorage.ClientAssets.Characters.EXE.TailsDoll.scriptstuff.Animate:Destroy()
game.ReplicatedStorage.ClientAssets.Characters.Survivors.Tails.scriptstuff.Animate:Clone()
.Parent = game.ReplicatedStorage.ClientAssets.Characters.EXE.TailsDoll.scriptstuff

while game.ReplicatedStorage.ClientAssets.Characters.EXE.TailsDoll.scriptstuff.Animate.Anims:FindFirstChild("SelectPose")
do game.ReplicatedStorage.ClientAssets.Characters.EXE.TailsDoll.scriptstuff.Animate.Anims:FindFirstChild("SelectPose"):Destroy() end
game.ReplicatedStorage.ClientAssets.Characters.Survivors.Tails.scriptstuff.Animate.Anims.Canon.Walk:Clone()
.Parent = game.ReplicatedStorage.ClientAssets.Characters.EXE.TailsDoll.scriptstuff.Animate.Anims
game.ReplicatedStorage.ClientAssets.Characters.EXE.TailsDoll.scriptstuff.Animate.Anims.Walk.Name = "SelectPose"

local function tryUpdatePlayer(player)
    if not player:IsA("Model") then return end
    if player:GetAttribute("Character") ~= "TailsDoll" then return end
    if player:GetAttribute("Skin") ~= "Default" then return end

    print("[FoxOnTailsDoll] Prebuild updating model for " .. player.Name .. "...")

    if player:FindFirstChild("OverlayModel") then
        warn("[FoxOnTailsDoll] Player already have OverlayModel, update cancelled")
        return
    end

    -- sometimes game spam errors without it lol
    if not player:FindFirstChild("BeingChased") then
        local BeingChased = Instance.new("ObjectValue")
        BeingChased.Name = "BeingChased"
        BeingChased.Value = player
        BeingChased.Parent = player
    end
    
    if player:WaitForChild("Animate") and player:WaitForChild("Humanoid") then
    
        local Animate = game.ReplicatedStorage.ClientAssets.Characters.Survivors.Tails.scriptstuff.Animate:Clone()
        Animate.Name = "Tails"..Animate.Name
        Animate.Parent = player
        Animate.Enabled = true

        function loadTrack(id)
            local anim = Instance.new("Animation")
            anim.AnimationId = id
            local track = player.Humanoid.Animator:LoadAnimation(anim)
            return track
        end
        function playWhileTrack(track, myTrack)
            myTrack:Play(0.1)
            track.Stopped:Once(function() myTrack:Stop(0.1) end)
            return myTrack
        end

        local ServerBrustHit = loadTrack("rbxassetid://75852355428865")

        local ServerBrustHitForReachout = loadTrack("rbxassetid://75852355428865")
        
        local Strangled = player.Humanoid.Animator:LoadAnimation(Animate.Anims.Strangled)
        local StrangledR = player.Humanoid.Animator:LoadAnimation(Animate.Anims.StrangledR)
        local CanonIdle = player.Humanoid.Animator:LoadAnimation(Animate.Anims.Canon.Idle)
        local Glide = player.Humanoid.Animator:LoadAnimation(Animate.Anims.Glide)
        local Jump = player.Humanoid.Animator:LoadAnimation(Animate.Anims.Jump)

        local SitTails = loadTrack("rbxassetid://132926716277265")
        local Pipebomb = loadTrack("rbxassetid://137946742808216")
        local Cory = loadTrack("rbxassetid://118810363050448")

        player.Humanoid.Animator.AnimationPlayed:Connect(function(track)
            --print("PLAYED: "..track.Name.." - "..track.Animation.AnimationId)
            local id = track.Animation.AnimationId
            if id == "rbxassetid://92259033776440" then playWhileTrack(track, SitTails) end
            if id == "rbxassetid://112656139256072" then playWhileTrack(track, Cory) end
            if id == "rbxassetid://100732265533480" then playWhileTrack(track, Pipebomb):AdjustSpeed(0.815) end
            if track.Name == "DoubleJump" then 
                Jump:Play(0.1)
                Jump:AdjustSpeed(2)
            end
            if track.Name == "Glide" and Glide.Animation.AnimationId ~= track.Animation.AnimationId then -- Glide
                local Flying = game.ReplicatedStorage.ClientAssets.Sounds.sfx.Game.Survivors.Tails.Flying:Clone()
                Flying.Parent = player.HumanoidRootPart
                Flying:Play()
                Glide:Play(0.1)
                track.Stopped:Once(function() 
                    Glide:Stop(1)
                    Flying.PlaybackSpeed = 0.75
                    task.wait(0.25)
                    Flying.PlaybackSpeed = 0.5
                    task.wait(0.25)
                    Flying.PlaybackSpeed = 0.35
                    task.wait(0.25)
                    Flying:Destroy() 
                end)
            end
            if id == "rbxassetid://138468646867674" or id == "rbxassetid://101931899083669" then -- swings
                ServerBrustHit:Play(0.1)
                ServerBrustHit:AdjustSpeed(2)
            end
            if id == "rbxassetid://107665101569245" then -- kill
                Strangled:Play(0.1)
                Strangled:AdjustSpeed(0.25)
                track.Stopped:Once(function() Strangled:Stop(0.1) end)
            end
            if id == "rbxassetid://85130598698132" then -- reachout step1
                --huh
                ServerBrustHitForReachout:Play(0.1)
                task.wait(1)
                ServerBrustHitForReachout:AdjustSpeed(0)
            end
            if id == "rbxassetid://87184553255122" then -- reachout step2
                track.Stopped:Once(function() ServerBrustHitForReachout:Stop(0.1) end)
                task.wait(0.5)
                if not track.IsPlaying then ServerBrustHitForReachout:Stop(0.1) end
            end
        end)

        player.AttributeChanged:Connect(function(attr)
            if attr == "StunDur" or attr == "BurnDur" then
                local val = player:GetAttribute(attr)
                if val and val > 0 then
                    player:SetAttribute("State", "alt")
                elseif not val or val <= 0 then
                    player:SetAttribute("State", "default")
                end
            end
        end)

        print("[FoxOnTailsDoll] Tails animatior added!")
    end

    print("[FoxOnTailsDoll] Character ready! Updating " .. player:GetFullName() .. "...")
    
    -- Char Model
    local ogHRP = player:FindFirstChild("HumanoidRootPart", true)
    if not ogHRP then return end

    for _, v in ipairs(player:GetDescendants()) do
        if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
            v:SetAttribute("HiddenAway", "FOR TAILS")
            v:SetAttribute("doesntcount", true)
            v.Color = Color3.new(0/255, 0/255, 0/255)
            v.Material = Enum.Material.Neon
            v.LocalTransparencyModifier = 1
            v.Changed:Connect(function(property)
                if property == "LocalTransparencyModifier" then
                    v.LocalTransparencyModifier = 1
                end
                if property == "Transparency" and v.Name == "Head" then
                    --warn(v:GetFullName(), v.Transparency)
                    for _, ov in ipairs(player.OverlayModel:GetDescendants()) do 
                        if not ov:GetAttribute("IgnoreTransparency") then
                            pcall(function() ov.Transparency = v.Transparency end)
                        end
                    end
                end
            end)
        end
        if v:IsA("SurfaceGui") then v.Enabled = false end
        if v:IsA("SurfaceAppearance") then v:Destroy() end
    end

    -- Overlay Model
    local OverlayModel = game.ReplicatedStorage.ClientAssets.Characters.Survivors.Tails.Skins.Default:Clone()
    OverlayModel.Name = "OverlayModel"
    OverlayModel.Parent = player

    local myHRP = OverlayModel:FindFirstChild("HumanoidRootPart", true)
    if not myHRP then OverlayModel:Destroy() return end

    for _, v in ipairs(OverlayModel:GetDescendants()) do
        if v:IsA("Humanoid") then v:Destroy() end
        if v:IsA("Animator") then v:Destroy() end
        if v:IsA("BasePart") then
            v.CanCollide = false
            v.Anchored = false
            v.CanTouch = false
            v.CanQuery = false
            v.Massless = true
            if v.Transparency > 0 then v:SetAttribute("IgnoreTransparency", true) end
        end
    end

    player:FindFirstChild("DiamondPOS", true).Parent = OverlayModel.canon.Cylinder
    player:FindFirstChild("ReachOutVFXA", true).Parent = OverlayModel.canon.Cylinder
    player:FindFirstChild("RootAttachment", true).Parent = OverlayModel.canon.Cylinder

    -- yooo (im stupidoo)
    local hrpY = -1.4
    local weld = Instance.new("Weld")
    weld.Part0 = ogHRP
    weld.Part1 = myHRP
    weld.C0 = CFrame.new()
    weld.C1 = CFrame.new(0, -hrpY, 0) 
    weld.Parent = myHRP
    myHRP:PivotTo(ogHRP.CFrame * CFrame.new(0, hrpY, 0))

    -- sounds and stuff...
    player.DescendantAdded:Connect(function(desc)
        -- if desc:GetFullName():find(".FOVMultiplier") then return end
        -- print(desc.ClassName, desc:GetFullName())

        if desc.Name == "Rolling" then desc:Destroy() end -- NO ROLL VELOC
        if desc.ClassName == "Attachment" then desc.Parent = OverlayModel.canon.Cylinder end
        if desc.ClassName == "ParticleEmitter" then desc.Parent = OverlayModel.canon.Cylinder end

        if not desc:IsA("Sound") then return end
        if not desc.Parent or not desc.Parent.Parent then return end
        if desc:GetAttribute("IsMyCloneToIgnore") then return end

        print(desc.ClassName, desc:GetFullName())

        local path = desc:GetFullName()
        
        -- game.ReplicatedStorage.ClientAssets.Sounds.sfx.Game.Survivors.Tails.Lines.BurstLine1:Play() -- get out of here
        -- game.ReplicatedStorage.ClientAssets.Sounds.sfx.Game.Survivors.Tails.Lines.BurstLine2:Play() -- back off
        -- game.ReplicatedStorage.ClientAssets.Sounds.sfx.Game.Survivors.Tails.Lines.BurstLine3:Play() -- careful!
        -- game.ReplicatedStorage.ClientAssets.Sounds.sfx.Game.Survivors.Tails.Lines.BurstLine4:Play() -- move!
        -- game.ReplicatedStorage.ClientAssets.Sounds.sfx.Game.Survivors.Tails.Lines.BurstLine5:Play() -- burn
        -- game.ReplicatedStorage.ClientAssets.Sounds.sfx.Game.Survivors.Tails.Lines.ChargeLine:Play() -- stand by
        -- game.ReplicatedStorage.ClientAssets.Sounds.sfx.Game.Survivors.Tails.Lines.GetAway.DefaultLine1:Play() -- cut in a close idk
        -- game.ReplicatedStorage.ClientAssets.Sounds.sfx.Game.Survivors.Tails.Lines.GetAway.DefaultLine2:Play() -- im otta here!
        -- game.ReplicatedStorage.ClientAssets.Sounds.sfx.Game.Survivors.Tails.Lines.LaserLine1:Play() -- hit 'em
        -- game.ReplicatedStorage.ClientAssets.Sounds.sfx.Game.Survivors.Tails.Lines.LaserLine2:Play() -- impact
        -- game.ReplicatedStorage.ClientAssets.Sounds.sfx.Game.Survivors.Tails.Lines.LaserLine3:Play() -- derict hit
        -- game.ReplicatedStorage.ClientAssets.Sounds.sfx.Game.Survivors.Tails.Lines.LaserLine4:Play() -- got it

        if path:find(".Swings") then
            desc.SoundId = game.ReplicatedStorage.ClientAssets.Sounds.sfx.Game.EXE.Swing.SoundId
            return
        end
        
        if path:find(".Hurt") then
            if desc.Parent:FindFirstChild("CustomSpeech") then desc:Destroy() return end
            local Sounds = {
                game.ReplicatedStorage.ClientAssets.Sounds.sfx.Game.Survivors.Tails.Lines.BurstLine2,--:Play() -- back off
                game.ReplicatedStorage.ClientAssets.Sounds.sfx.Game.Survivors.Tails.Lines.BurstLine2,--:Play() -- back off
                game.ReplicatedStorage.ClientAssets.Sounds.sfx.Game.Survivors.Tails.Lines.BurstLine4,-- move!
                game.ReplicatedStorage.ClientAssets.Sounds.sfx.Game.Survivors.Tails.Lines.BurstLine1,--:Play() -- get out of here
            }
            local sound = Sounds[math.random(1, #Sounds)]:Clone()
            sound:SetAttribute("IsMyCloneToIgnore", true)
            sound.Name = "CustomSpeech"
            sound.Parent = desc.Parent
            sound.Volume = 0.25 + desc.Volume
            sound:Play()
            sound.Ended:Once(function() sound:Destroy() end)
            game.Debris:AddItem(sound, 3)
            desc:Destroy()
            return
        end

        if path:find(".Downed") or (path:find(".Default") and path:find("Line")) then
            if desc.Parent:FindFirstChild("CustomSpeech") then desc:Destroy() return end
            local Sounds = {
                game.ReplicatedStorage.ClientAssets.Sounds.sfx.Game.Survivors.Tails.Lines.ChargeLine,-- stand by
                game.ReplicatedStorage.ClientAssets.Sounds.sfx.Game.Survivors.Tails.Lines.BurstLine1,--:Play() -- get out of here
                game.ReplicatedStorage.ClientAssets.Sounds.sfx.Game.Survivors.Tails.Lines.BurstLine1,--:Play() -- get out of here
                game.ReplicatedStorage.ClientAssets.Sounds.sfx.Game.Survivors.Tails.Lines.BurstLine2,--:Play() -- back off
                game.ReplicatedStorage.ClientAssets.Sounds.sfx.Game.Survivors.Tails.Lines.ChargeLine,-- stand by
                game.ReplicatedStorage.ClientAssets.Sounds.sfx.Game.Survivors.Tails.Lines.BurstLine4,-- move!
                game.ReplicatedStorage.ClientAssets.Sounds.sfx.Game.Survivors.Tails.Lines.BurstLine1,--:Play() -- get out of here
                game.ReplicatedStorage.ClientAssets.Sounds.sfx.Game.Survivors.Tails.Lines.BurstLine5,-- burn
                game.ReplicatedStorage.ClientAssets.Sounds.sfx.Game.Survivors.Tails.Lines.ChargeLine,-- stand by
                game.ReplicatedStorage.ClientAssets.Sounds.sfx.Game.Survivors.Tails.Lines.ChargeLine,-- stand by
            }
            local sound = Sounds[math.random(1, #Sounds)]:Clone()
            sound:SetAttribute("IsMyCloneToIgnore", true)
            sound.Name = "CustomSpeech"
            sound.Parent = desc.Parent
            sound.Volume = 0.25 + desc.Volume
            sound:Play()
            sound.Ended:Once(function() sound:Destroy() end)
            game.Debris:AddItem(sound, 3)
            desc:Destroy()
            return
        end

        if desc.Name:find("Retract") then
            if desc.Parent:FindFirstChild("CustomSpeech") then desc:Destroy() return end
            local sound = game.ReplicatedStorage.ClientAssets.Sounds.sfx.Game.Survivors.Tails.Lines.ChargeLine:Clone()
            sound:SetAttribute("IsMyCloneToIgnore", true)
            sound.Parent = desc.Parent
            sound.Volume = 0.5 + desc.Volume
            sound:Play()
            sound.Ended:Once(function() sound:Destroy() end)
            game.Debris:AddItem(sound, 3)
            desc:Destroy()
        end

        if desc.Name:find("Unleashed") then
            if desc.Parent:FindFirstChild("CustomSpeech") then desc:Destroy() return end
            local sound = game.ReplicatedStorage.ClientAssets.Sounds.sfx.Game.Survivors.Tails.Lines.GetAway.DefaultLine1:Clone()
            sound:SetAttribute("IsMyCloneToIgnore", true)
            sound.Parent = desc.Parent
            sound.Volume = 0.5 + desc.Volume
            sound:Play()
            sound.Ended:Once(function() sound:Destroy() end)
            game.Debris:AddItem(sound, 3)
            desc:Destroy()
        end
    end)

    print("[FoxOnTailsDoll] Updating finished for", player.Name .. "!")
end


local function onPlayerAdded(player)
    -- Check if they already spawned in
    if player.Character then tryUpdatePlayer(player.Character) end
    -- Listen for the player (re)spawning
    _G.FoxOnTailsDollCharacterAddedConn = _G.FoxOnTailsDollCharacterAddedConn or {}
    if _G.FoxOnTailsDollCharacterAddedConn[player.Name] then
        _G.FoxOnTailsDollCharacterAddedConn[player.Name]:Disconnect()
        print("[FoxOnTailsDoll] Previous FoxOnTailsDollCharacterAddedConn disconnected for", player.Name)
    end
    _G.FoxOnTailsDollCharacterAddedConn[player.Name] = player.CharacterAdded:Connect(tryUpdatePlayer) 
end

for _, player in game.Players:GetPlayers() do onPlayerAdded(player) end

if _G.FoxOnTailsDollPlayerAddedConn then
    _G.FoxOnTailsDollPlayerAddedConn:Disconnect()
    print("[FoxOnTailsDoll] Previous FoxOnTailsDollPlayerAddedConn disconnected")
end
_G.FoxOnTailsDollPlayerAddedConn = game.Players.PlayerAdded:Connect(onPlayerAdded)
