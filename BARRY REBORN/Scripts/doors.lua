repeat
    task.wait()
until game:IsLoaded() and game.Players.LocalPlayer and game.Players.LocalPlayer.Character

--#region Setup
if getgenv then
    if getgenv().DGEM_LOADED == true then
        repeat
            task.wait()
        until false
    end
    getgenv().DGEM_LOADED = true
end
local entities = {
    AllEntities = {
        "All",
        "Ambush",
        "Eyes",
        "Glitch",
        "Grundge",
        "Halt",
        "Hide",
        "None",
        "Random",
        "Rush",
        "Screech",
        "Seek",
        "Shadow",
        "Smiler",
        "Timothy",
        "Trashbag",
        "Trollface"
    },
    DeveloperEntities = {
        "Trollface",
        "None",
        "Smiler"
    },
    CustomEntities = {
        "Grundge",
        "Trashbag",
        "None"
    },
    RegularEntities = {
        "All",
        "Ambush",
        "Eyes",
        "Glitch",
        "Halt",
        "Hide",
        "Random",
        "None",
        "Rush",
        "Screech",
        "Seek",
        "Shadow",
        "Timothy"
    }
}
for _, tb in pairs(entities) do
    table.sort(tb)
end

if not isfile("interactedWithDiscordPrompt.txt") then
    writefile("interactedWithDiscordPrompt.txt", ".")
    local Inviter = loadstring(game:HttpGet("https://raw.githubusercontent.com/RegularVynixu/Utilities/main/Discord%20Inviter/Source.lua"))()
    Inviter.Prompt({
        name = "Zepsyy's Exploiting Community",
        invite = "discord.gg/scripters",
    })
end
--#endregion

--#region Window
local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/shlexware/Rayfield/main/source'))()

local Window = Rayfield:CreateWindow({
    Name = "Doors Entity Replicator | " .. (identifyexecutor and identifyexecutor() or syn and "Synapse X" or "Unknown"),
    LoadingTitle = "Loading Doors Entity Spawner",
    LoadingSubtitle = "Made by Zepsyy and Spongus",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = nil, -- Create a custom folder for your hub/game
        FileName = "L.N.K v1" -- ZEPSYY I TOLD YOU ITS NOT GONNA BE NAMED LINK  
    },
    Discord = {
        Enabled = false,
        Invite = "scripters", -- The Discord invite code, do not include discord.gg/
        RememberJoins = false -- Set this to false to make them join the discord every time they load it up
    },
    KeySystem = false
})
--#endregion
--#region Connections & Variables

--//MAIN VARIABLES\\--
local Debris = game:GetService("Debris")


local player = game.Players.LocalPlayer
local Character = player.Character or player.CharacterAdded:Wait()
local RootPart = Character:FindFirstChild("HumanoidRootPart")
local Humanoid = Character:FindFirstChild("Humanoid")

local allLimbs = {}

for i, v in pairs(Character:GetChildren()) do
    if v:IsA("BasePart") then
        table.insert(allLimbs, v)
    end
end

--//MAIN USABLE FUNCTIONS\\--

function removeDebris(obj, Duration)
    Debris:AddItem(obj, Duration)
end

-- Services

local Players = game:GetService("Players")
local RS = game:GetService("RunService")
local ReSt = game:GetService("ReplicatedStorage")
local TextService = game:GetService("TextService")
local TS = game:GetService("TweenService")


local Plr = Players.LocalPlayer
local Char = Plr.Character or Plr.CharacterAdded:Wait()
local Root = Char:WaitForChild("HumanoidRootPart")
local Hum = Char:WaitForChild("Humanoid")

local ModuleScripts = {
    MainGame = require(Plr.PlayerGui.MainUI.Initiator.Main_Game),
    SeekIntro = require(Plr.PlayerGui.MainUI.Initiator.Main_Game.RemoteListener.Cutscenes.SeekIntro),
}
local Connections = {}


local function playSound(soundId, source, properties)
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://" .. soundId
    sound.PlayOnRemove = true
    for i, v in next, properties do
        if i ~= "SoundId" and i ~= "Parent" and i ~= "PlayOnRemove" then
            sound[i] = v
        end
    end
    sound.Parent = source
    sound:Destroy()
end

local function drag(model, dest, speed)
    local reached = false
    Connections.Drag = RS.Stepped:Connect(function(_, step)
        if model.Parent then
            local seekPos = model.PrimaryPart.Position
            local newDest = Vector3.new(dest.X, seekPos.Y, dest.Z)
            local diff = newDest - seekPos
            if diff.Magnitude > 0.1 then
                model:SetPrimaryPartCFrame(CFrame.lookAt(seekPos + diff.Unit * math.min(step * speed, diff.Magnitude - 0.05), newDest))
            else
                Connections.Drag:Disconnect()
                reached = true
            end
        else
            Connections.Drag:Disconnect()
        end
    end)
    repeat
        task.wait()
    until reached
end

local function jumpscareSeek()
    Hum.Health = 0
    workspace.Ambience_Seek:Stop()
    local func = getconnections(ReSt.Bricks.Jumpscare.OnClientEvent)[1].Function
    debug.setupvalue(func, 1, false)
    func("Seek")
end

local function connectSeek(room)
    local seekMoving = workspace.SeekMoving
    local seekRig = seekMoving.SeekRig

    -- Intro
    seekMoving:SetPrimaryPartCFrame(room.RoomStart.CFrame * CFrame.new(0, 0, -15))
    seekRig.AnimationController:LoadAnimation(seekRig.AnimRaise):Play()
    task.spawn(function()
        task.wait(7)
        workspace.Footsteps_Seek:Play()
    end)
    workspace.Ambience_Seek:Play()
    ModuleScripts.SeekIntro(ModuleScripts.MainGame)
    seekRig.AnimationController:LoadAnimation(seekRig.AnimRun):Play()
    Char:SetPrimaryPartCFrame(room.RoomEnd.CFrame * CFrame.new(0, 0, 20))
    ModuleScripts.MainGame.chase = true
    Hum.WalkSpeed = 22
    
    -- Movement
    task.spawn(function()
        local nodes = {}
        for _, v in next, workspace.CurrentRooms:GetChildren() do
            for i2, v2 in next, v:GetAttributes() do
                if string.find(i2, "Seek") and v2 then
                    nodes[#nodes + 1] = v.RoomEnd
                end
            end
        end
        for _, v in next, nodes do
            if seekMoving.Parent and not seekMoving:GetAttribute("IsDead") then
                drag(seekMoving, v.Position, 15)
            end
        end
    end)

    -- Killing
    task.spawn(function()
        while seekMoving.Parent do
            if (Root.Position - seekMoving.PrimaryPart.Position).Magnitude <= 30 and Hum.Health > 0 and not seekMoving.GetAttribute(seekMoving, "IsDead") then
                Connections.Drag:Disconnect()
                workspace.Footsteps_Seek:Stop()
                ModuleScripts.MainGame.chase = false
                Hum.WalkSpeed = 15
                
                -- Crucifix / death
                if not Char.FindFirstChild(Char, "Crucifix") then
                    jumpscareSeek()
                else
                    seekMoving.Figure.Repent:Play()
                    seekMoving:SetAttribute("IsDead", true)
                    workspace.Ambience_Seek.TimePosition = 92.6
                    task.spawn(function()
                        ModuleScripts.MainGame.camShaker:ShakeOnce(35, 25, 0.15, 0.15)
                        task.wait(0.5)
                        ModuleScripts.MainGame.camShaker:ShakeOnce(5, 25, 4, 4)
                    end)

                    -- Crucifix float
                    local model = Instance.new("Model")
                    model.Name = "Crucifix"
                    local hl = Instance.new("Highlight")
                    local crucifix = Char.Crucifix
                    local fakeCross = crucifix.Handle:Clone()
                    fakeCross:FindFirstChild("EffectLight").Enabled = true
                    ModuleScripts.MainGame.camShaker:ShakeOnce(35, 25, 0.15, 0.15)
                    model.Parent = workspace
                    -- hl.Parent = model
                    -- hl.FillTransparency = 1
                    -- hl.OutlineColor = Color3.fromRGB(75, 177, 255)
                    fakeCross.Anchored = true
                    fakeCross.Parent = model
                    crucifix:Destroy()
                    for i, v in pairs(fakeCross:GetChildren()) do
                        if v.Name == "E" and v:IsA("BasePart") then
                            v.Transparency = 0
                            v.CanCollide = false
                        end
                        if v:IsA("Motor6D") then
                            v.Name = "Motor6D"
                        end
                    end
        


                    -- Seek death
                    task.wait(4)
                    seekMoving.Figure.Scream:Play()
                    playSound(11464351694, workspace, {
                        Volume = 3
                    })
                    game.TweenService:Create(seekMoving.PrimaryPart, TweenInfo.new(4), {
                        CFrame = seekMoving.PrimaryPart.CFrame - Vector3.new(0, 10, 0)
                    }):Play()
                    task.wait(4)
                    seekMoving:Destroy()
                    fakeCross.Anchored = false
                    fakeCross.CanCollide = true
                    task.wait(0.5)
                    model:Remove()
                end
                break
            end
            task.wait()
        end
    end)
end

-- Setup

local newIdx;
newIdx = hookmetamethod(game, "__newindex", newcclosure(function(t, k, v)
    if k == "WalkSpeed" and not checkcaller() then
        if ModuleScripts.MainGame.chase then
            v = ModuleScripts.MainGame.crouching and 17 or 22
        else
            v = ModuleScripts.MainGame.crouching and 10 or 15
        end
    end
    return newIdx(t, k, v)
end))

-- Scripts
 
local roomConnection;
roomConnection = workspace.CurrentRooms.ChildAdded:Connect(function(room)
    local trigger = room:WaitForChild("TriggerEventCollision", 1)
    if trigger then
        roomConnection:Disconnect()
        local collision = trigger.Collision:Clone()
        collision.Parent = room
        trigger:Destroy()
        local touchedConnection;
        touchedConnection = collision.Touched:Connect(function(p)
            if p:IsDescendantOf(Char) then
                touchedConnection:Disconnect()
                connectSeek(room)
            end
        end)
    end
end)
--#endregion
--#region Tabs
local MainTab = Window:CreateTab("Entity Spawning", 4370345144)
local DoorsMods = Window:CreateTab("Doors Modifications", 10722835155)
local ConfigEntities = Window:CreateTab("Configure Entities", 8285095937)
local publicServers = Window:CreateTab("Special Servers", 9692125126)
local Tools = Window:CreateTab("Tools", 29402763) 
local CharacterMods = Window:CreateTab("Character Modifications", 483040244)
local global = Window:CreateTab("Global", 1588352259) 
--#endregion
    
--#region Special Servers


publicServers:CreateSection("Server Identifier")
publicServers:CreateLabel("Current Server Identification: " .. game.JobId)
publicServers:CreateButton({
    Name = "Copy Server Identification",
    Callback = function()
        (syn and syn.write_clipboard or setclipboard)(game.JobId)
    end
})
publicServers:CreateSection("Features")
publicServers:CreateButton({
    Name = "Join Empty Special Server",
    Callback = function()
        game.Players.LocalPlayer:Kick("\nJoining Special Server... Please Wait")
        wait();
        (queue_on_teleport or syn and syn.queue_on_teleport)("loadstring(game:HttpGet\"https://raw.githubusercontent.com/sponguss/Doors-Entity-Replicator/main/source.lua\")()")
        game:GetService("TeleportService"):Teleport(game.PlaceId, game.Players.LocalPlayer)
    end
})
publicServers:CreateButton({
    Name = "Free Revive",
    Callback = function()
        (queue_on_teleport or syn and syn.queue_on_teleport)("loadstring(game:HttpGet\"https://raw.githubusercontent.com/sponguss/Doors-Entity-Replicator/main/source.lua\")()")
        game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, game.Players.LocalPlayer)
    end
})
publicServers:CreateLabel("WARNING: FREE REVIVING REQUIRES TO BE IN A SPECIAL SERVER WITH COMPANY")
publicServers:CreateSection("Server-Hopping")
publicServers:CreateButton({
    Name = "Join Random Special Server",
    Callback = function()
        local tb = game:GetService("HttpService"):JSONDecode(game:HttpGet(("https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=Asc&limit=100"):format(tostring(game.PlaceId))));
        (queue_on_teleport or syn and syn.queue_on_teleport)("loadstring(game:HttpGet\"https://raw.githubusercontent.com/sponguss/Doors-Entity-Replicator/main/source.lua\")()")
        game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, tb.data[math.random(1, #tb.data)].id, game.Players.LocalPlayer)
    end,
})
publicServers:CreateInput({
    Name = "Join Specific Player",
    PlaceholderText = game.Players.LocalPlayer.Name,
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        local tb = game:GetService("HttpService"):JSONDecode(game:HttpGet(("https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=Asc&limit=100"):format(tostring(game.PlaceId))))
        for _, server in pairs(tb.data) do
            for _, player in pairs(server.players) do
                if player.name == Text or player.UserId == Text then
                    (queue_on_teleport or syn and syn.queue_on_teleport)("loadstring(game:HttpGet\"https://raw.githubusercontent.com/sponguss/Doors-Entity-Replicator/main/source.lua\")()")
                    game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, server.id, game.Players.LocalPlayer)
                end
            end
        end
    end,
})
publicServers:CreateInput({
    Name = "Join Special Server",
    PlaceholderText = "Insert Server Identification",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        (queue_on_teleport or syn and syn.queue_on_teleport)("loadstring(game:HttpGet\"https://raw.githubusercontent.com/sponguss/Doors-Entity-Replicator/main/source.lua\")()")
        game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, Text, game.Players.LocalPlayer)
    end,
})
--#endregion
--#region Entity Configuration
--[[
local EntitiesFolder = game:GetService("ReplicatedStorage"):FindFirstChild("Entities")

_G.ScreechConfig = false
_G.TimothyConfig = false
_G.HaltConfig = false
_G.GlitchConfig = false

_G.HaltModel = 0
_G.TimothyModel = 0
_G.ScreechModel = 0
_G.GlitchModel = 0

local function connectEntity(entitytype, id, entityname)
    if entitytype == "3d" then
        game:GetService("Debris"):AddItem(game:GetService("ReplicatedStorage"):WaitForChild("Entities"):FindFirstChild(entityname), 0)
        local customentity = game:GetObjects("rbxassetid://" .. id)[1]
        if customentity then
        customentity.Name = entityname
        customentity.Parent = game:GetService("ReplicatedStorage"):FindFirstChild("Entities")
        local isCustom = Instance.new("StringValue")
        isCustom.Name = "isCustom"
        isCustom.Parent = customentity
        end
    elseif entitytype == string.lower("2d") then
        error("entity cannot be changed because entity is 2D.")
    end
end

ConfigEntities:CreateSection("3D Entities")

ConfigEntities:CreateParagraph({
    Title = "Warning",
    Content = "This setting is for developers only, if you wish to continue, please join discord.gg/scripters for the original entity models to edit."
})

ConfigEntities:CreateToggle({
    Name = "Screech Configuration",
    CurrentValue = false,
    Flag = "AddScreechConfig",
    Callback = function(Value)
        _G.ScreechConfig = Value

    end,
})

game:GetService("RunService").RenderStepped:Connect(function()
    if _G.ScreechConfig == true then
        connectEntity("3d", _G.ScreechModel, "Screech")
    else
        connectEntity("3d", "11799696044", "Screech")
    end
end)

game:GetService("RunService").RenderStepped:Connect(function()
    if _G.GlitchConfig == true then
        connectEntity("3d", _G.GlitchModel, "Glitch")
    else
        connectEntity("3d", "11689725604", "Glitch")
    end
end)

game:GetService("RunService").RenderStepped:Connect(function()
    if _G.TimothyConfig == true then
        connectEntity("3d", _G.TimothyModel, "Spider")
    else
        connectEntity("3d", "11689711982", "Spider")
    end
end)

game:GetService("RunService").RenderStepped:Connect(function()
    if _G.HaltConfig == true then
        connectEntity("3d", _G.HaltModel, "Shade")
    else
        connectEntity("3d", "11689715035", "Shade")
    end
end)
ConfigEntities:CreateInput({
    Name = "Set Screech Model",
    PlaceholderText = "ex: 123456789",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        _G.ScreechModel = Text
    end,
})

ConfigEntities:CreateToggle({
    Name = "Glitch Configuration",
    CurrentValue = false,
    Flag = "AddGlitchConfig",
    Callback = function(Value)
        _G.GlitchConfig = Value

    end,
})

ConfigEntities:CreateInput({
    Name = "Set Glitch Model",
    PlaceholderText = "ex: 123456789",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        _G.GlitchModel = Text
    end,
})

ConfigEntities:CreateToggle({
    Name = "Timothy Configuration",
    CurrentValue = false,
    Flag = "AddTimothyConfig",
    Callback = function(Value)
        _G.TimothyConfig = Value

    end,
})


ConfigEntities:CreateInput({
    Name = "Set Timothy Model",
    PlaceholderText = "ex: 123456789",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        _G.TimothyModel = Text
    end,
})

ConfigEntities:CreateToggle({
    Name = "Halt Configuration",
    CurrentValue = false,
    Flag = "AddHaltConfig",
    Callback = function(Value)
        _G.HaltConfig = Value

    end,
})

ConfigEntities:CreateInput({
    Name = "Set Halt Model",
    PlaceholderText = "ex: 123456789",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        _G.HaltModel = Text
    end,
})

ConfigEntities:CreateSection("2D Entities")
]]
ConfigEntities:CreateLabel("Disabled temporarily due to issues")
--#endregion
--#region Doors Modifications
--#region UI Mods
DoorsMods:CreateSection("Game UI Modifications")

DoorsMods:CreateInput({
    Name = "Set Knobs Amount",
    PlaceholderText = game.Players.LocalPlayer.PlayerGui.PermUI.Topbar.Knobs.Text,
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        require(game.ReplicatedStorage.ReplicaDataModule).event.Knobs:Fire(tonumber(Text))
    end,
})

DoorsMods:CreateInput({
    Name = "Set Revives Amount",
    PlaceholderText = game.Players.LocalPlayer.PlayerGui.PermUI.Topbar.Revives.Text,
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        require(game.ReplicatedStorage.ReplicaDataModule).event.Revives:Fire(tonumber(Text))
    end,
})

DoorsMods:CreateInput({
    Name = "Set Boosts Amount",
    PlaceholderText = game.Players.LocalPlayer.PlayerGui.PermUI.Topbar.Boosts.Text,
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        require(game.ReplicatedStorage.ReplicaDataModule).event.Boosts:Fire(tonumber(Text))
    end,
})

DoorsMods:CreateInput({
    Name = "Show Bottom Text",
    PlaceholderText = "Your lighter ran out of fuel...",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        firesignal(game.ReplicatedStorage.Bricks.Caption.OnClientEvent, Text)
    end,
})


DoorsMods:CreateButton({
    Name = "Start Heartbeat Minigame",
    Callback = function()
        firesignal(game.ReplicatedStorage.Bricks.ClutchHeartbeat.OnClientEvent)
    end,
})

DoorsMods:CreateButton({
    Name = "Get All Achievements",
    Callback = function()
        for i, v in pairs(require(game.ReplicatedStorage.Achievements)) do
            spawn(function()
                require(game.Players.LocalPlayer.PlayerGui.MainUI.Initiator.Main_Game.RemoteListener.Modules.AchievementUnlock)(nil, i)
            end)
        end
    end,
})
--#endregion
--#region Modify Rooms
DoorsMods:CreateSection("Modify Rooms")

DoorsMods:CreateColorPicker({
    Name = "Set Room Color",
    Color = Color3.fromRGB(89, 69, 72),
    Flag = "RoomColor",
    Callback = function(color)
        local room = workspace.CurrentRooms[game.Players.LocalPlayer:GetAttribute("CurrentRoom")]
        if color == Color3.fromRGB(89, 69, 72) then
            room.LightBase.SurfaceLight.Enabled = true
            room.LightBase.SurfaceLight.Color = Color3.fromRGB(89, 69, 72)
            for _, thing in pairs(room.Assets:GetDescendants()) do
                if thing:FindFirstChild"LightFixture" then
                    thing.LightFixture.Neon.Color = Color3.fromRGB(195, 161, 141)
                    for _, light in pairs(thing.LightFixture:GetChildren()) do
                        if light:IsA("SpotLight") or light:IsA("PointLight") then
                            light.Color = Color3.fromRGB(235, 167, 98)
                        end
                    end
                end
            end
            return
        end
        room.LightBase.SurfaceLight.Enabled = true
        room.LightBase.SurfaceLight.Color = color
        for _, thing in pairs(room.Assets:GetDescendants()) do
            if thing:FindFirstChild"LightFixture" then
                thing.LightFixture.Neon.Color = color
                for _, light in pairs(thing.LightFixture:GetChildren()) do
                    if light:IsA("SpotLight") or light:IsA("PointLight") then
                        light.Color = color
                    end
                end
            end
        end
    end
})

DoorsMods:CreateParagraph({
    Title = "Warning",
    Content = "If you'd like to reset the room's color, leave it as 89,69,72"
})

DoorsMods:CreateButton({
    Name = "Spawn Red Room",
    Callback = function()
        firesignal(game.ReplicatedStorage.Bricks.UseEventModule.OnClientEvent, "tryp", workspace.CurrentRooms[game.Players.LocalPlayer:GetAttribute("CurrentRoom")], 9e307)
        -- Imagine someone actually waits 90000000000000000... seconds for the red room to run out, would be crazy 
    end,
})

DoorsMods:CreateButton({
    Name = "Break Lights",
    Callback = function()
        firesignal(game.ReplicatedStorage.Bricks.UseEventModule.OnClientEvent, "breakLights", workspace.CurrentRooms[game.Players.LocalPlayer:GetAttribute("CurrentRoom")], 0.416, 60) 
    end,
})

DoorsMods:CreateInput({
    Name = "Flicker Lights",
    PlaceholderText = "time in seconds...",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        firesignal(game.ReplicatedStorage.Bricks.UseEventModule.OnClientEvent, "flickerLights", game.Players.LocalPlayer:GetAttribute("CurrentRoom"), tonumber(Text)) 
    end,
})

DoorsMods:CreateInput({
    Name = "Set Door Text",
    PlaceholderText = "gahaa lolz",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        local r = workspace.CurrentRooms[game.Players.LocalPlayer:GetAttribute("CurrentRoom")]
        r.Door.Sign.Stinker.Text = Text
        r.Door.Sign.Stinker.Highlight.Text = Text
        r.Door.Sign.Stinker.Shadow.Text = Text
    end,    
})
--#endregion
--#region Modify Entities
DoorsMods:CreateSection("Modify Entities")

local EnabledEntities = {
    EnabledScreech = false,
    EnabledHalt = false,
    EnabledGlitch = false,
}

DoorsMods:CreateToggle({
    Name = "Ignore Screech",
    CurrentValue = false,
    Flag = "IgnoreScreech",
    Callback = function(Value)
        EnabledEntities.EnabledScreech = Value
    end,
})

DoorsMods:CreateToggle({
    Name = "Ignore Glitch",
    CurrentValue = false,
    Flag = "IgnoreGlitch",
    Callback = function(Value)
        EnabledEntities.EnabledGlitch = Value
    end,
})

DoorsMods:CreateToggle({
    Name = "Ignore Halt",
    CurrentValue = false,
    Flag = "IgnoreHalt",
    Callback = function(Value)
        EnabledEntities.EnabledHalt = Value
    end,
})

workspace.Camera.ChildAdded:Connect(function(c)
    if c.Name == "Screech" then
        wait(0.1)
        if EnabledEntities.EnabledScreech then
            removeDebris(c, 0)
        end
    end
    if c.Name == "Shade" then
        wait(.1)
        if EnabledEntities.EnabledHalt then
            removeDebris(c, 0)
        end
    end
end)

workspace.CurrentRooms.ChildAdded:Connect(function()
    if EnabledEntities.EnabledGlitch then
        local currentRoom = game.Players.LocalPlayer:GetAttribute("CurrentRoom")
        local roomAmt = #workspace.CurrentRooms:GetChildren()
        local lastRoom = game.ReplicatedStorage.GameData.LatestRoom.Value
        if roomAmt >= 4 and currentRoom < lastRoom - 3 then
            game.Players.LocalPlayer.Character:PivotTo(CFrame.new(lastRoom.RoomStart.Position))
        end
    end
end)
--#endregion
--#region Global Doors Mods

DoorsMods:CreateSection("Global Doors Modifications")

local thanksgivingEnabled = false
DoorsMods:CreateButton({
    Name = "Enable Thanksgiving Update",
    Callback = function()
        if thanksgivingEnabled then
            return Rayfield:Notify({
                Title = "Error",
                Content = "You have already ran this",
                Duration = 6.5,
                Image = 4483362458,
                Actions = {},
            })
        end
        thanksgivingEnabled = true
        loadstring(game:HttpGet("https://raw.githubusercontent.com/ZepsyyCodesLUA/Utilities/main/DOORSthanksgiving"))()
    end,
})

DoorsMods:CreateToggle({
    Name = "Timestop",
    CurrentValue = false,
    Flag = "timestop",
    Callback = function(val)
        if val == true then
            game.Players.LocalPlayer.GameplayPaused = true
        else
            game.Players.LocalPlayer.GameplayPaused = false
        end
    end    
})

--#endregion
--#endregion
--#region Character Mods
local con
local con2
local isJumping = false

CharacterMods:CreateSection("Post-Death")
CharacterMods:CreateInput({
    Name = "Set Guiding Light",
    PlaceholderText = "message 1~message 2",
    RemoveTextAfterFocusLost = true,
    Callback = function(Text)
        game.Players.LocalPlayer.Character.Humanoid.Health = 0
        debug.setupvalue(getconnections(game.ReplicatedStorage.Bricks.DeathHint.OnClientEvent)[1].Function, 1, Text:split"~")
    end
})
CharacterMods:CreateLabel("This input will instantly kill you when used... Be careful with it")

CharacterMods:CreateButton({
    Name = "Instant Death",
    Callback = function()
        game.Players.LocalPlayer.Character.Humanoid.Health = 0
    end
})
CharacterMods:CreateButton({
    Name = "Revive",
    Callback = function()
        game.ReplicatedStorage.Bricks.Revive:FireServer()
    end
})
CharacterMods:CreateParagraph({
    Title = "Warning",
    Content = "The revive button requires you to have atleast 1 revive, the special thing about it, is that it can bypass the \"You can only revive in a run once\" message, and other things"
})

CharacterMods:CreateSection("Movement")
CharacterMods:CreateToggle({
    Name = "Enable Jumping",
    CurrentValue = false,
    Flag = "enableJump",
    Callback = function(val)
        if val == true then
            con = game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
                if gameProcessed then
                    return
                end
                if input.KeyCode == Enum.KeyCode.Space then
                    isJumping = true
                    repeat
                        task.wait()
                        if game.Players.LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid"):GetState() == Enum.HumanoidStateType.Freefall then
                        else
                            game.Players.LocalPlayer.Character:FindFirstChildOfClass('Humanoid'):ChangeState(3)
                        end
                    until isJumping == false
                end
            end)
            con2 = game:GetService("UserInputService").InputEnded:Connect(function(input, gameProcessed)
                if gameProcessed then
                    return
                end
                if input.KeyCode == Enum.KeyCode.Space then
                    isJumping = false
                end
            end)
        else
            con:Disconnect()
            con2:Disconnect()
        end
    end
})

local Speed = 15

local EVC = CharacterMods:CreateToggle({
    Name = "Enable Velocity Cheat",
    CurrentValue = false,
    Callback = function()
    end
})

CharacterMods:CreateSlider({
    Name = "Velocity",
    Range = {
        15,
        100
    },
    Increment = 5,
    Suffix = "studs/s",
    CurrentValue = 15,
    Flag = "speed",
    Callback = function(val)
        for _, child in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do
            if child.ClassName == "Part" then
                child.CustomPhysicalProperties = PhysicalProperties.new(999, 0.3, 0.5)
            end
        end
        Speed = tonumber(val)
    end
})



game:GetService("RunService").RenderStepped:Connect(function()
    if EVC.CurrentValue == true then
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Speed
    end
end)
--#endregion
--#region Tools
--#region Vitamins
_G.VitaminsDurability = 0

Tools:CreateButton({
    Name = "Obtain Vitamins",
    Callback = function()
        local Vitamins = game:GetObjects("rbxassetid://11685698403")[1]
        local idle = Vitamins.Animations:FindFirstChild("idle")
        local open = Vitamins.Animations:FindFirstChild("open")
        local tweenService = game:GetService("TweenService")
        local sound_open = Vitamins.Handle:FindFirstChild("sound_open")
        local char = game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacteAdded:Wait()
        local hum = char:WaitForChild("Humanoid")
        local idleTrack = hum.Animator:LoadAnimation(idle)
        local openTrack = hum.Animator:LoadAnimation(open)
        local Durability = 35
        local InTrans = false
        local Duration = math.random(5, 8)
        local xUsed = tonumber(_G.VitaminsDurability)
        local v1 = {};
        function v1.AddDurability()
            InTrans = true
            hum:SetAttribute("SpeedBoost", 11)
            task.spawn(function()
                repeat
                    task.wait(.1)
                    hum:SetAttribute("SpeedBoost", hum:GetAttribute"SpeedBoost" - .1)
                until hum:GetAttribute("SpeedBoost") <= 0
            end)
            wait(Duration)
            InTrans = false
        end
        function v1.SetupVitamins()
            Vitamins.Parent = game.Players.LocalPlayer.Backpack
            Vitamins.Name = "FakeVitamins"
            for slotNum, tool in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
                if tool.Name == "FakeVitamins" then
                    local slot = game.Players.LocalPlayer.PlayerGui:WaitForChild("MainUI").MainFrame.Hotbar:FindFirstChild(slotNum)
                    -- while task.wait() do
                    --     slot.DurabilityNumber.Text = "x"..xUsed
                    -- end
                    -- slot.DurabilityNumber.Text = "x"..xUsed
                    game:GetService("RunService").RenderStepped:Connect(function()
                        slot.DurabilityNumber.Visible = true
                        slot.DurabilityNumber.Text = "x" .. xUsed
                    end)
                    Vitamins.Activated:Connect(function()
                        if not InTrans then
                            xUsed -= 1
                            task.spawn(function()
                                slot.DurabilityNumber.Visible = true
                                slot.DurabilityNumber.Text = "x" .. xUsed
                                openTrack:Play()
                                sound_open:Play()
                                tweenService:Create(workspace.CurrentCamera, TweenInfo.new(0.2), {
                                    FieldOfView = 100
                                }):Play()
                                v1.AddDurability()
                            end)
                            if xUsed == 0 then
                                delay(sound_open.TimeLength + .2, function()
                                    Vitamins:Destroy()
                                end)
                            end
                        end
                    end)
                end
            end
            Vitamins.Equipped:Connect(function()
                idleTrack:Play()
            end)
            Vitamins.Unequipped:Connect(function()
                idleTrack:Stop()
            end)
        end
        v1.SetupVitamins()
        function v1.AddLoop()
            while task.wait() do
                if InTrans then
                    wait()
                    hum.WalkSpeed = Durability
                else
                    hum.WalkSpeed = 16
                end
            end
        end
        while task.wait() do
            v1.AddLoop()
        end
        return v1
    end
})

Tools:CreateInput({
    Name = "Vitamin Durability",
    PlaceholderText = "ex: 100",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        local durability = tonumber(Text)
        if durability then
            _G.VitaminsDurability = Text
        elseif not durability or durability == '0' then
            Rayfield:Notify({
                Title = "ERROR",
                Content = "Please enter a valid number.",
                Duration = 5,
                Image = 4483362458,
                Actions = {},
            })
        end
    end,    
})
 
Tools:CreateParagraph({
    Title = "NOTE",
    Content = "These are fake vitamins but works just as efficient as the actual ones do. So others can't see you holding the item globally. Please do not include decimals or fractions in this written piece meaning that this script will be caused to break and no longer function."
})
--#endregion

--#region Dropdown
local toolList = {
    "Skeleton Key",
    "Crucifix",
    "Christmas Guns",
    "Candle",
    "Gummy Flashlight",
    "Gun"
}
table.sort(toolList)
local toolFuncs = {
    ["Skeleton Key"] = function()
        if not isfile("skellyKey.rbxm") then
            writefile("skellyKey.rbxm", game:HttpGet"https://raw.githubusercontent.com/sponguss/Doors-Entity-Replicator/main/skellyKey.rbxm")
        end
        local keyTool = game:GetObjects((getcustomasset or getsynasset)("skellyKey.rbxm"))[1]
        keyTool:SetAttribute("uses", 5)
        local function setupRoom(room)
            local thing = loadstring(game:HttpGet"https://raw.githubusercontent.com/sponguss/Doors-Entity-Replicator/main/skellyKeyRoomRep.lua")()
            local newdoor = thing.CreateDoor({
                CustomKeyNames = {
                    "SkellyKey"
                },
                Sign = true,
                Light = true,
                Locked = true
            })
            newdoor.Model.Parent = workspace
            newdoor.Model:PivotTo(room:WaitForChild"Door".Door.CFrame)
            newdoor.Model.Parent = room
            room:WaitForChild"Door":Destroy()
            thing.ReplicateDoor({
                Model = newdoor.Model,
                Config = {
                    CustomKeyNames = {
                        "SkellyKey"
                    }
                },
                Debug = {
                    OnDoorPreOpened = function()
                    end
                }
            })
        end
        keyTool.Equipped:Connect(function()
            for _, room in pairs(workspace.CurrentRooms:GetChildren()) do
                if room:WaitForChild"Door":FindFirstChild"Lock" and not room:GetAttribute("Replaced") then
                    room:SetAttribute("Replaced", true)
                    setupRoom(room)
                end
            end
            con = workspace.CurrentRooms.ChildAdded:Connect(function(room)
                if room:WaitForChild"Door":FindFirstChild"Lock" and not room:GetAttribute("Replaced") then
                    room:SetAttribute("Replaced", true)
                    setupRoom(room)
                end
            end)
        end)
        keyTool.Unequipped:Connect(function()
            con:Disconnect()
        end)
        if Plr.PlayerGui.MainUI.ItemShop.Visible then
            loadstring(game:HttpGet("https://raw.githubusercontent.com/RegularVynixu/Utilities/main/Doors/Custom%20Shop%20Items/Source.lua"))().CreateItem(keyTool, {
                Title = "Skeleton Key",
                Desc = "Five uses, holds secrets",
                Image = "https://static.wikia.nocookie.net/doors-game/images/8/88/Icon_crucifix2.png/revision/latest/scale-to-width-down/350?cb=20220728033038",
                Price = 100,
                Stack = 1,
            })
        else
            keyTool.Parent = game.Players.LocalPlayer.Backpack
        end
    end,
    ["Crucifix"] = function() 
        -- Original crucifix was made by Zepsyy
        -- Rewritten by Spongus

        local Configuration = {
            -- IF YOU MODIFY ANY OF THESE VALUES YOU ARE NOT ALLOWED TO PUBLISH/RELEASE THE MODIFIED SCRIPT WITHOUT PERMISSION OF ZEPSYY OR SPONGUS
            -- UNLESS COMPLETE CREDITS ARE GIVEN TO ZEPSYY FOR THE SCRIPTING

            -- Tables are used to switch between versions of the crucifix
            CurrentCrucifix = 1;
            CrucifixName = {
                "Crucifix"
            };
            CrucifixDescription = {
                "The devil's nightmare"
            };
            CrucifixTool = {
                "rbxassetid://11822556646"
            }; -- The tool of the crucifix
            CrucifixChains = {"rbxassetid://11584227521"}; -- The model of the chains
            CrucifixCracks = {
                Color3.fromRGB(110, 153, 202),
                "Neon"
            }; -- If your crucifix has cracks, set their color and material here
            Uses = 1;
            Trapping = {
                CustomEntities = {
                    Enabled = true;
                    UseChains = true;
                    FreezeEntity = true;
                    TimeToRise = 6; -- The entity will instantly be deleted after this time runs out
                    RiseHeight=50;
                    OnCrucifixUsed = function(monster, crucifix, config) -- Fires before the entity is cloned
                    end;
                    OnCrucifixEnd=function(monster, crucifix, config) -- Fires before the entity is destroyed
                    end;
                },
                Eyes = {
                    Enabled = true;
                },
                Halt = {
                    Enabled = true;
                }
            }
        }
        local function IsVisible(part)
            local vec, found = workspace.CurrentCamera:WorldToViewportPoint(part.Position)
            local cfg = RaycastParams.new()
            cfg.FilterType = Enum.RaycastFilterType.Blacklist
            cfg.FilterDescendantsInstances = {
                part
            }
            local cast = workspace:Raycast(part.Position, (game.Players.LocalPlayer.Character.UpperTorso.Position - part.Position), cfg)
            if (found and vec.Z > 0) and cast and cast.Instance.Parent == game.Players.LocalPlayer.Character then
                return true
            end
        end
        local Equipped = false
        local Plr = game:GetService"Players".LocalPlayer
        local Char = Plr.Character or Plr.CharacterAdded:Wait()
        local Hum = Char:WaitForChild("Humanoid")
        local RightArm = Char:WaitForChild("RightUpperArm")
        local LeftArm = Char:WaitForChild("LeftUpperArm")
        local RightC1 = RightArm.RightShoulder.C1
        local LeftC1 = LeftArm.LeftShoulder.C1
        local SelfModules = {
            Functions = loadstring(
            game:HttpGet("https://raw.githubusercontent.com/RegularVynixu/Utilities/main/Functions.lua")
        )(),
            CustomShop = loadstring(
            game:HttpGet(
                "https://raw.githubusercontent.com/RegularVynixu/Utilities/main/Doors/Custom%20Shop%20Items/Source.lua"
            )
        )(),
        }
        local ModuleScripts = {
            MainGame = require(Plr.PlayerGui.MainUI.Initiator.Main_Game),
            SeekIntro = require(Plr.PlayerGui.MainUI.Initiator.Main_Game.RemoteListener.Cutscenes.SeekIntro),
        }
        local CrucifixTool = game:GetObjects(Configuration["CrucifixTool"][Configuration["CurrentCrucifix"]])[1]
        CrucifixTool.Name = Configuration["CrucifixName"][Configuration["CurrentCrucifix"]]
        CrucifixTool.Equipped:Connect(function()
            Equipped = true
            Char:SetAttribute("Hiding", true)
            for _, v in next, Hum:GetPlayingAnimationTracks() do
                v:Stop()
            end
            RightArm.Name = "R_Arm"
            LeftArm.Name = "L_Arm"
            RightArm.RightShoulder.C1 = RightC1 * CFrame.Angles(math.rad(-90), math.rad(-15), 0)
            LeftArm.LeftShoulder.C1 = LeftC1
            * CFrame.new(-0.2, -0.3, -0.5)
            * CFrame.Angles(math.rad(-125), math.rad(25), math.rad(25))
        end)
        CrucifixTool.Unequipped:Connect(function()
            Equipped = false
            Char:SetAttribute("Hiding", nil)
            RightArm.Name = "RightUpperArm"
            LeftArm.Name = "LeftUpperArm"
            RightArm.RightShoulder.C1 = RightC1
            LeftArm.LeftShoulder.C1 = LeftC1
        end)
        CrucifixTool.Parent = game.Players.LocalPlayer.Backpack
        local Plr = game:GetService("Players").LocalPlayer
        local Char = Plr.Character or Plr.CharacterAdded:Wait()
        local Root = Char:WaitForChild("HumanoidRootPart")
        local function dupeCrucifix(time, entityRoot)
            local Cross = Instance.new("Model")
            for _, thing in pairs(CrucifixTool:GetChildren()) do
                thing:Clone().Parent=Cross
            end
            local weld=Instance.new("ManualWeld", Cross.Handle)
            weld.Part0=Cross.Handle
            if Cross:FindFirstChild"Cracks" then
                weld.Part1=Cross.Cracks
                Cross.Cracks.Color = Configuration.CrucifixCracks[1]
                Cross.Cracks.Material = Configuration.CrucifixCracks[2]
            end
            Cross.Parent = workspace
            Cross.Name = Configuration.CrucifixName[Configuration.CurrentCrucifix] .. "Cracked"
            local fakeCross = Cross.Handle
    
            ModuleScripts.MainGame.camShaker:ShakeOnce(35, 25, 0.15, 0.15)
            Cross:PivotTo(CFrame.lookAt(CrucifixTool.Handle.Position, entityRoot.Position))
            fakeCross.Anchored = true
            Configuration.Uses -= 1
            if Configuration.Uses == 0 then
                CrucifixTool:Destroy()
            end
            task.wait(time)
            fakeCross.Anchored = false
            Cross.Cracks.Anchored=false
            fakeCross.CanCollide = true
            task.wait(0.5)
            Cross:Remove()
        end
        local function HandleEntity(ins)
            wait(.01) -- Wait for the attribute
            if ins:GetAttribute("IsCustomEntity") == true and ins:GetAttribute("ClonedByCrucifix") ~= true then
                local Chains
                if Configuration.Trapping.CustomEntities.UseChains then
                    Chains = game:GetObjects(Configuration.CrucifixChains[Configuration.CurrentCrucifix])[1]
                    Chains.Parent = workspace
                end
                repeat
                    task.wait()
                until Equipped and ins.Parent ~= nil and ins.PrimaryPart and IsVisible(ins.PrimaryPart) and (Root.Position - ins.PrimaryPart.Position).magnitude <= 25
                Configuration.Trapping.CustomEntities.OnCrucifixUsed(ins, CrucifixTool, Configuration)
                local c=ins
                if Configuration.Trapping.CustomEntities.FreezeEntity then
                    c = ins:Clone()
                    c:SetAttribute("ClonedByCrucifix", true)
                    c.PrimaryPart.Anchored = true
                    c.Parent = ins.Parent
                    ins:Destroy()
                end
                task.spawn(dupeCrucifix, Configuration.Trapping.CustomEntities.TimeToRise, c.PrimaryPart)
                if Configuration.Trapping.CustomEntities.UseChains then
                    local EntityRoot = c.PrimaryPart
                    local Fake_FaceAttach = Instance.new("Attachment", EntityRoot)
                    for i, beam in pairs(Chains:GetDescendants()) do
                        if beam:IsA("BasePart") then
                            beam.CanCollide = false
                        end
                        if beam.Name == "Beam" then
                            beam.Attachment1 = Fake_FaceAttach
                        end
                    end
                    Chains:SetPrimaryPartCFrame(EntityRoot.CFrame * CFrame.new(0, -3.5, 0) * CFrame.Angles(math.rad(90), 0, 0))
                    task.wait(1.35)
                    task.spawn(function()
                        while task.wait() do
                            if Chains:FindFirstChild('Base') then
                                Chains.Base.CFrame = Chains.Base.CFrame * CFrame.Angles(0, 0 , math.rad(0.5))
                            end
                        end
                    end)
                    task.spawn(function()
                        while task.wait() do
                            for i, beam in pairs(Chains:GetDescendants()) do
                                if beam.Name == "Beam" then
                                    beam.TextureLength = beam.TextureLength + 0.035
                                end
                            end
                        end
                    end)
                    game.TweenService:Create(EntityRoot, TweenInfo.new(Configuration.Trapping.CustomEntities.TimeToRise), {
                        CFrame = EntityRoot.CFrame * CFrame.new(0, Configuration.Trapping.CustomEntities.RiseHeight, 0)
                    }):Play()
                    task.wait(1.5)
                    game:GetService("Debris"):AddItem(c, 0)
                    game:GetService("Debris"):AddItem(Chains, 0)
                end
                Configuration.Trapping.CustomEntities.OnCrucifixEnd(c,CrucifixTool,Configuration)
            elseif ins.Name == "Lookman" and Configuration["Trapping"].Eyes.Enabled == true then
                local c = ins
                task.spawn(function()
                    repeat
                        task.wait()
                    until Equipped and c.Core.Attachment.Eyes.Enabled == true
                    local pos = c.Core.Position
                    task.spawn(function()
                        c:SetAttribute("Killing", true)
                        ModuleScripts.MainGame.camShaker:ShakeOnce(10, 10, 5, 0.15)
                        wait(1.2)
                        c.Core.Initiate:Stop()
                        c.Core.Repent:Play()
                        delay(c.Core.Repent.TimeLength, function()
                            c.Core.Attachment.Angry.Enabled = false
                        end)
                        c.Core.Attachment.Angry.Enabled = true
                        ModuleScripts.MainGame.camShaker:ShakeOnce(4, 4, c.Core.Repent.TimeLength, 0.15)
                        wait(2 + c.Core.Repent.TimeLength + .1)
                        ModuleScripts.MainGame.camShaker:ShakeOnce(8, 8, c.Core.Repent.TimeLength * 2, 0.15)
                        c.Core.Repent:Play()
                        c.Core.Attachment.Angry.Enabled = true
                        wait(c.Core.Repent.TimeLength + .1)
                        c.Core.Repent:Play()
                        task.spawn(dupeCrucifix, 4, c.Core)
                        ModuleScripts.MainGame.camShaker:ShakeOnce(10, 10, c.Core.Scream.TimeLength + 2, 0.15);
                        wait(2)
                        c.Core.Scream:Play();
                        game:GetService("TweenService"):Create(c.Core:FindFirstChild"whisper" or c.Core:FindFirstChild"Ambience", TweenInfo.new(c.Core.Scream.TimeLength + 2.2), {
                            Volume = 0
                        }):Play()
                        for _, l in pairs(c:GetDescendants()) do
                            if l:IsA("PointLight") then
                                game:GetService("TweenService"):Create(l, TweenInfo.new(c.Core.Scream.TimeLength + 2.2), {
                                    Brightness = 0
                                }):Play()
                            end
                        end
                        game:GetService("TweenService"):Create(c.Core, TweenInfo.new(c.Core.Scream.TimeLength, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                            CFrame = CFrame.new(c.Core.CFrame.X, c.Core.CFrame.Y - 12, c.Core.CFrame.Z)
                        }):Play()
                    end)
                    local col = game.Players.LocalPlayer.Character.Collision
                    local function CFrameToOrientation(cf)
                        local x, y, z = cf:ToOrientation()
                        return Vector3.new(math.deg(x), math.deg(y), math.deg(z))
                    end
                    while c.Parent ~= nil and c.Core.Attachment.Eyes.Enabled == true do
                    -- who's the boss now huh?
                        col.Orientation = CFrameToOrientation(CFrame.lookAt(col.Position, pos) * CFrame.Angles(0, math.pi, 0))
                        task.wait()
                    end
                end)
            elseif ins.Name == "Shade" and ins.Parent == workspace.CurrentCamera and ins:GetAttribute("ClonedByCrucifix") == nil and Configuration.Trapping.Halt.Enabled then
                task.spawn(function()
                    repeat
                        task.wait()
                    until IsVisible(ins) and (Root.Position - ins.Position).Magnitude <= 12.5 and Equipped
                    local clone = ins:Clone()
                    clone:SetAttribute("ClonedByCrucifix", true)
                    clone.CFrame = ins.CFrame
                    clone.Parent = ins.Parent
                    clone.Anchored = true
                    ins:Remove()
                    task.spawn(dupeCrucifix, 13, ins)
                    ModuleScripts.MainGame.camShaker:ShakeOnce(40, 10, 5, 0.15)
                    for _, thing in pairs(clone:GetDescendants()) do
                        if thing:IsA("SpotLight") then
                            game:GetService("TweenService"):Create(thing, TweenInfo.new(5), {
                                Brightness = thing.Brightness * 5
                            }):Play()
                        elseif thing:IsA("Sound") and thing.Name ~= "Burst" then
                            game:GetService("TweenService"):Create(thing, TweenInfo.new(5), {
                                Volume = 0
                            }):Play()
                        elseif thing:IsA("TouchTransmitter") then
                            thing:Destroy()
                        end
                    end
                    for _, pc in pairs(clone:GetDescendants()) do
                        if pc:IsA("ParticleEmitter") then
                            pc.Color = ColorSequence.new{
                                ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0, 4)),
                                ColorSequenceKeypoint.new(0.48, Color3.fromRGB(182, 0, 3)),
                                ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 0, 4))
                            }
                        end
                    end
                    local light
                    light = game.Lighting["Ambience_Shade"]
                    wait(5)
                    clone.Burst.PlaybackSpeed = 0.5
                    clone.Burst:Stop()
                    clone.Burst:Play()
                    light.TintColor = Color3.fromRGB(215, 253, 255)
                    game:GetService("TweenService"):Create(clone, TweenInfo.new(6), {
                        CFrame = CFrame.new(clone.CFrame.X, clone.CFrame.Y - 12, clone.CFrame.Z)
                    }):Play()
                    wait(8.2)
                    game:GetService("Debris"):AddItem(clone, 0)
                    game.ReplicatedStorage.Bricks.ShadeResult:FireServer()
                end)
            end
        end
        workspace.ChildAdded:Connect(HandleEntity)
        workspace.CurrentCamera.ChildAdded:Connect(HandleEntity)
        for _, thing in pairs(workspace:GetChildren()) do
            HandleEntity(thing)
        end
        for _, thing in pairs(workspace.CurrentCamera:GetChildren()) do
            HandleEntity(thing)
        end
        if Plr.PlayerGui.MainUI.ItemShop.Visible then
            SelfModules.CustomShop.CreateItem(CrucifixTool, {
                Title = Configuration["CrucifixName"][Configuration["CurrentCrucifix"]],
                Desc = Configuration["CrucifixDescription"][Configuration["CurrentCrucifix"]],
                Image = "https://static.wikia.nocookie.net/doors-game/images/8/88/Icon_crucifix2.png/revision/latest/scale-to-width-down/350?cb=20220728033038",
                Price = 300,
                Stack = 1,
            })
        end
    end,
    ["Christmas Guns"] = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/NotTypicalAdmin/ChristmasGuns/main/main"))()
    end,
    ["Candle"] = function()
        local Functions = loadstring(game:HttpGet("https://raw.githubusercontent.com/RegularVynixu/Utilities/main/Functions.lua"))()
        local CustomShop = loadstring(game:HttpGet("https://raw.githubusercontent.com/RegularVynixu/Utilities/main/Doors/Custom%20Shop%20Items/Source.lua"))()
        local Candle = game:GetObjects("rbxassetid://11630702537")[1]
        Candle.Parent = game.Players.LocalPlayer.Backpack
        local plr = game.Players.LocalPlayer
        local Char = plr.Character or plr.CharacterAdded:Wait()
        local Hum = Char:FindFirstChild("Humanoid")
        local RightArm = Char:FindFirstChild("RightUpperArm")
        local LeftArm = Char:FindFirstChild("LeftUpperArm")
        local RightC1 = RightArm.RightShoulder.C1
        local LeftC1 = LeftArm.LeftShoulder.C1
        local AnimIdle = Instance.new("Animation")
        AnimIdle.AnimationId = "rbxassetid://9982615727"
        AnimIdle.Name = "IDleloplolo"
        local cam = workspace.CurrentCamera
        Candle.Handle.Top.Flame.GuidingLighteffect.EffectLight.LockedToPart = true
        Candle.Handle.Material = Enum.Material.Salt
        local track = Hum.Animator:LoadAnimation(AnimIdle)
        track.Looped = true
        local Equipped = false
        for i, v in pairs(Candle:GetDescendants()) do
            if v:IsA("BasePart") then
                v.CanCollide = false
            end
        end
        Candle.Equipped:Connect(function()
            for _, v in next, Hum:GetPlayingAnimationTracks() do
                v:Stop()
            end
            Equipped = true
        -- RightArm.Name = "R_Arm"
            track:Play()
        -- RightArm.RightShoulder.C1 = RightC1 * CFrame.Angles(math.rad(-90), math.rad(-15), 0)
        end)
        Candle.Unequipped:Connect(function()
            RightArm.Name = "RightUpperArm"
            track:Stop()
            Equipped = false
        -- RightArm.RightShoulder.C1 = RightC1
        end)
        cam.ChildAdded:Connect(function(screech)
            if screech.Name == "Screech" and math.random(1, 400) ~= 1 then
                if not Equipped then
                    return
                end
                if Equipped then
                    game:GetService("Debris"):AddItem(screech, 0.05)
                end
            end
        end)
        Candle.TextureId = "rbxassetid://11622366799"
    -- Create custom shop item
        if plr.PlayerGui.MainUI.ItemShop.Visible then
            CustomShop.CreateItem(Candle, {
                Title = "Guiding Candle",
                Desc = "קг๏ςєє๔ คՇ ץ๏ยг ๏ฬภ гเรк.",
                Image = "rbxassetid://11622366799",
                Price = 75,
                Stack = 1,
            })
        else
            Candle.Parent = game.Players.LocalPlayer.Backpack
        end
    end,
    ["Gummy Flashlight"] = function()
        if workspace:FindFirstChild("Gummy Flashlight") then
            firetouchinterest(game.Players.LocalPlayer.Character.Head, workspace["Gummy Flashlight"].Handle, 0)
            task.wait()
            firetouchinterest(game.Players.LocalPlayer.Character.Head, workspace["Gummy Flashlight"].Handle, 1)
        else
            return Rayfield:Notify({
                Title = "Error",
                Content = "This script must be executed at elevator due to it being REPLICATED (ServerSided)",
                Duration = 6.5,
                Image = 4483362458,
                Actions = {},
            })
        end
    end,
    ["Gun"] = function()
        if not isfile("Hole.rbxm") then
            writefile("Hole.rbxm", game:HttpGet"https://cdn.discordapp.com/attachments/969056040094138378/1044313717107593277/Hole.rbxm")
        end
        loadstring(game:HttpGet"hhttps://raw.githubusercontent.com/ZepsyyCodesLUA/Utilities/main/Doors/Pistol.lua")()
    end
}
local selectedTool = Tools:CreateDropdown({
    Name = "Select Tool",
    Options = toolList,
    CurrentOption = "Crucifix",
    Flag = "selectedTool",
    Callback = function()
    end
})
Tools:CreateButton({
    Name = "Obtain Selected Tool",
    Callback = function()
        toolFuncs[selectedTool.CurrentOption]()
    end
})
Tools:CreateKeybind({
    Name = "Keybind Tool",
    CurrentKeybind = "T",
    HoldToInteract = false,
    Flag = "toolKeybind", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
    Callback = function(Keybind)
        toolFuncs[selectedTool.CurrentOption]()
    end,
})
--#endregion
--#endregion
--#region Global

global:CreateSection("Global Morphs")

local figureMorphEnabled
global:CreateToggle({
    Name = "Become Figure",
    CurrentValue = false,
    Flag = "figureBecome",
    Callback = function(val)
        figureMorphEnabled=val
        local figure = workspace.CurrentRooms:FindFirstChild("FigureRagdoll", true)
        if not figure then
            return Rayfield:Notify({
                Title = "Error",
                Content = "Figure was not found, please execute this at door 49",
                Duration = 6,
                Image = 4483362458,
                Actions = {}
            })
        elseif workspace.CurrentRooms:FindFirstChild("51") then
            return Rayfield:Notify({
                Title = "Error",
                Content = "An issue ocurred while trying to morph into figure, figure's AI must NOT be enabled for this to work (the script must be executed before the cutscene)",
                Duration = 6,
                Image = 4483362458,
                Actions = {}
            })
        end
        if sethiddenproperty then
            repeat
                sethiddenproperty(game.Players.LocalPlayer, "MaxSimulationRadius", 10000)
                sethiddenproperty(game.Players.LocalPlayer, "SimulationRadius", 10000)
                task.wait()
            until figureMorphEnabled == false
        end
        for _, part in pairs(figure:GetDescendants()) do
            if part:IsA("BasePart") then
                part:SetAttribute("CollisionValueSave", part.CanCollide)
                part.CanCollide = false
                task.spawn(function()
                    repeat
                        task.wait()
                    until figureMorphEnabled == false
                    part.CanCollide = part:GetAttribute"CollisionValueSave"
                end)
            end
        end
        task.spawn(function()
            -- HeadMoveAnimation
            task.spawn(function()
                repeat
                    game:GetService"TweenService":Create(figure.Head, TweenInfo.new(3), {
                        Orientation = Vector3.new(0, 55, 0)
                    }):Play()
                    wait(3)
                    game:GetService"TweenService":Create(figure.Head, TweenInfo.new(3), {
                        Orientation = Vector3.new(0, 125, 0)
                    }):Play()
                    wait(3)
                    game:GetService"TweenService":Create(figure.Head, TweenInfo.new(3), {
                        Orientation = Vector3.new(0, 90, 0)
                    }):Play()
                    wait(math.random(6, 20))
                until figureMorphEnabled == false
            end)
        end)
        repeat
            figure:PivotTo(game.Players.LocalPlayer.Character.PrimaryPart.CFrame + Vector3.new(0, 5, 0))
            task.wait()
        until figureMorphEnabled == false
    end
})
global:CreateLabel("This script uses networkownership to move figure, which means it must have NO AI whatsoever")
global:CreateSection("Global Entity Modifications")
local removeEntities
local rmEntitiesCon
local rmEntitiesConTwo
global:CreateToggle({
    Name = "Remove All Entities",
    CurrentValue = false,
    Flag = "removeEntities",
    Callback = function(Value)
        -- im so good at the game
        removeEntities = Value
        if Value == true then
            rmEntitiesConTwo = workspace.CurrentRooms.ChildAdded:Connect(function(c)
                if c:WaitForChild"Base" then
                    task.spawn(function()
                        local p = Instance.new("ParticleEmitter", c.Base)
                        p.Brightness = 500
                        p.Color = ColorSequence.new(Color3.fromRGB(0, 80, 255))
                        p.LightEmission = 10000
                        p.LightInfluence = 0
                        p.Orientation = Enum.ParticleOrientation.FacingCamera
                        p.Size = NumberSequence.new(0.2)
                        p.Squash = NumberSequence.new(0)
                        p.Texture = "rbxassetid://2581223252"
                        p.Transparency = NumberSequence.new(0)
                        p.ZOffset = 0
                        p.EmissionDirection = Enum.NormalId.Top
                        p.Lifetime = NumberRange.new(2.5)
                        p.Rate = 500
                        p.Rotation = NumberRange.new(0)
                        p.RotSpeed = NumberRange.new(0)
                        p.Speed = 10
                        p.SpreadAngle = Vector2.new(0, 0)
                        p.Shape = Enum.ParticleEmitterShape.Box
                        p.ShapeInOut = Enum.ParticleEmitterShapeInOut.Outward
                        p.ShapeStyle = Enum.ParticleEmitterShapeStyle.Volume
                        p.Drag = 0
                    end)
                end
            end)
            rmEntitiesCon = workspace.ChildAdded:Connect(function(c)
                if c.Name == "Lookman" then
                    if not game:GetService"Players":GetPlayers()[2] then
                        local originalPos = c:FindFirstChildWhichIsA"BasePart".Position
                        task.wait()
                        c:PivotTo(0, 59049, 0)
                        for _, sound in pairs(c:GetDescendants()) do
                            if sound:IsA"Sound" then
                                sound.Volume = 0
                            end
                        end
                        local col = game.Players.LocalPlayer.Character.Collision
                        local function CFrameToOrientation(cf)
                            local x, y, z = cf:ToOrientation()
                            return Vector3.new(math.deg(x), math.deg(y), math.deg(z))
                        end
                        while c.Parent ~= nil and c.Core.Attachment.Eyes.Enabled == true do
                            col.Orientation = CFrameToOrientation(CFrame.lookAt(col.Position, originalPos) * CFrame.Angles(0, math.pi, 0))
                            task.wait()
                        end
                    else
                        repeat
                            task.wait()
                        until c.Core.Attachment.Eyes.Enabled == true
                        task.wait(.02)
                        local door = workspace.CurrentRooms[game.ReplicatedStorage.GameData.LatestRoom.Value]:WaitForChild"Door"
                        local lp = game.Players.LocalPlayer
                        local char = lp.Character
                        local pos = char.PrimaryPart.CFrame
                        char:PivotTo(door.Hidden.CFrame)
                        if door:FindFirstChild"ClientOpen" then
                            door.ClientOpen:FireServer()
                        end
                        task.wait(.2)
                        local HasKey = false
                        for i, v in ipairs(door.Parent:GetDescendants()) do
                            if v.Name == "KeyObtain" then
                                HasKey = v
                            end
                        end
                        if HasKey then
                            game.Players.LocalPlayer.Character:PivotTo(CFrame.new(HasKey.Hitbox.Position))
                            wait(0.3)
                            fireproximityprompt(HasKey.ModulePrompt, 0)
                            game.Players.LocalPlayer.Character:PivotTo(CFrame.new(door.Door.Position))
                            wait(0.3)
                            fireproximityprompt(door.Lock.UnlockPrompt, 0)
                            return
                        end
                        char:PivotTo(pos)
                    end
                end
            end)
            local val = game.ReplicatedStorage.GameData.ChaseStart
            local savedVal = val.Value
            task.spawn(function()
                repeat
                    if not game:GetService"Players":GetPlayers()[2] then
                        repeat
                            task.wait()
                        until val.Value ~= savedVal
                        savedVal = val.Value
                        repeat
                            task.wait()
                        until workspace.CurrentRooms:FindFirstChild(tostring(val.Value))
                        local room = workspace.CurrentRooms[tostring(val.Value - 1)]
                        local thing = loadstring(game:HttpGet"https://raw.githubusercontent.com/RegularVynixu/Utilities/main/Doors/Door%20Replication/Source.lua")()
                        local newdoor = thing.CreateDoor({
                            CustomKeyNames = {
                                "SkellyKey"
                            },
                            Sign = true,
                            Light = true,
                            Locked = (room:WaitForChild"Door":FindFirstChild"Lock" and true or false)
                        })
                        newdoor.Model.Parent = workspace
                        newdoor.Model:PivotTo(room:WaitForChild("Door").Door.CFrame)
                        newdoor.Model.Parent = room
                        room:WaitForChild("Door"):Destroy()
                        thing.ReplicateDoor({
                            Model = newdoor.Model,
                            Config = {},
                            Debug = {
                                OnDoorPreOpened = function()
                                end
                            }
                        })
                        return
                    else
                        repeat
                            task.wait()
                        until val.Value ~= savedVal
                        savedVal = val.Value
                        repeat
                            task.wait()
                        until workspace.CurrentRooms:FindFirstChild(tostring(val.Value)) and workspace.CurrentRooms:FindFirstChild(tostring(val.Value - 2)).Door.Light.Attachment.PointLight.Enabled == true
                        xpcall(function()
                            if removeEntities == true and game.ReplicatedStorage.GameData.ChaseEnd.Value - val.Value < 3 and game.ReplicatedStorage.GameData.ChaseStart.Value ~= 50 then
                                local lp = game.Players.LocalPlayer
                                local char = lp.Character
                                local pos = char.PrimaryPart.CFrame
                                local door = workspace.CurrentRooms[tostring(val.Value)]:WaitForChild("Door")
                                local HasKey = false
                                for i, v in ipairs(door.Parent:GetDescendants()) do
                                    if v.Name == "KeyObtain" then
                                        HasKey = v
                                    end
                                end
                                if HasKey then
                                    game.Players.LocalPlayer.Character:PivotTo(CFrame.new(HasKey.Hitbox.Position))
                                    wait(0.3)
                                    fireproximityprompt(HasKey.ModulePrompt, 0)
                                    game.Players.LocalPlayer.Character:PivotTo(CFrame.new(door.Door.Position))
                                    wait(0.3)
                                    fireproximityprompt(door.Lock.UnlockPrompt, 0)
                                    return
                                end
                                char:PivotTo(door.Hidden.CFrame)
                                if door:FindFirstChild"ClientOpen" then
                                    door.ClientOpen:FireServer()
                                end
                                task.wait(.2)
                                char:PivotTo(pos)
                            end
                        end, function(...)
                            print(...)
                        end)
                    end
                until removeEntities == false
            end)
            if not game:GetService"Players":GetPlayers()[2] and removeEntities == true then
                repeat
                    task.wait()
                until workspace.CurrentRooms:FindFirstChild(tostring(savedVal))
                local room = workspace.CurrentRooms[tostring(savedVal)]
                local thing = loadstring(game:HttpGet"https://raw.githubusercontent.com/RegularVynixu/Utilities/main/Doors/Door%20Replication/Source.lua")()
                local newdoor = thing.CreateDoor({
                    CustomKeyNames = {
                        "SkellyKey"
                    },
                    Sign = true,
                    Light = true,
                    Locked = {
                        room.Door:FindFirstChild"Lock" and true or false
                    }
                })
                newdoor.Model.Parent = workspace
                newdoor.Model:PivotTo(room:WaitForChild("Door").Door.CFrame)
                newdoor.Model.Parent = room
                room:WaitForChild("Door"):Destroy()
                thing.ReplicateDoor({
                    Model = newdoor.Model,
                    Config = {},
                    Debug = {
                        OnDoorPreOpened = function()
                        end
                    }
                })
            else
                repeat
                    task.wait()
                until workspace.CurrentRooms:FindFirstChild(tostring(savedVal)) and workspace.CurrentRooms:FindFirstChild(tostring(savedVal - 2)).Door.Light.Attachment.PointLight.Enabled == true
                if removeEntities == true then
                    local lp = game.Players.LocalPlayer
                    local char = lp.Character
                    local pos = char.PrimaryPart.CFrame
                    local door = workspace.CurrentRooms[tostring(savedVal)]:WaitForChild("Door")
                    local HasKey = false
                    for i, v in ipairs(door.Parent:GetDescendants()) do
                        if v.Name == "KeyObtain" then
                            HasKey = v
                        end
                    end
                    if HasKey then
                        game.Players.LocalPlayer.Character:PivotTo(CFrame.new(HasKey.Hitbox.Position))
                        wait(0.3)
                        fireproximityprompt(HasKey.ModulePrompt, 0)
                        game.Players.LocalPlayer.Character:PivotTo(CFrame.new(door.Door.Position))
                        wait(0.3)
                        fireproximityprompt(door.Lock.UnlockPrompt, 0)
                        return
                    else
                        char:PivotTo(door.Hidden.CFrame)
                        if door:FindFirstChild"ClientOpen" then
                            door.ClientOpen:FireServer()
                        end
                        task.wait(.2)
                        char:PivotTo(pos)
                    end
                end
            end
        else
            rmEntitiesCon:Disconnect()
            rmEntitiesConTwo:Disconnect()
        end
    end,
})
global:CreateParagraph({
    Title = "Warning",
    Content = "This setting is VERY dangerous, as it will remove every entity excepting for seek, figure, halt and screech. This setting is very powerful as it is also replicated to the WHOLE entire server, meaning everyone will notice that rush/ambush/eyes... isnt spawning. Please if you're gonna use this feature USE IT IN A PRIVATE SERVER to prevent ruining everyone's fun"
})

global:CreateButton({
    Name = "Agressive Figure",
    Callback = function()
        if workspace.CurrentRooms["51"] then
            local char = game.Players.LocalPlayer.Character
            local pos=char.HumanoidRootPart.CFrame
            local door = workspace.CurrentRooms["51"].Door
            char:PivotTo(door.Hidden.CFrame)
            if door:FindFirstChild"ClientOpen" then
                door.ClientOpen:FireServer()
            end
            task.wait(.2)
            char:PivotTo(pos)
        else
            Rayfield:Notify({
                Title = "Error",
                Content = "You must be in room 49 or 50 to use this.",
                Duration = 6.5,
                Image = 4483362458,
                Actions = {},
            })
        end
    end
})
global:CreateParagraph({
    Title = "Functionality",
    Content = "The button \"Agressive Figure\" will make figure know where each player is... This will make door 50 incredibly harder. IF THIS IS USED IN SINGLEPLAYER, FIGURE WILL BE DELETED MOST LIKELY"
})
--#endregion
--#region IN-DEV, DO NOT TOUCH.
-- local chatCon

-- misc:CreateToggle({
--     Name = "Enable Global Spawning",
--  CurrentValue = false,
--  Flag = "egs",
--  Callback = function(Value)
        
--  end,
-- })
-- misc:CreateInput({
--     Name = "Globally Spawn Entity",
--  PlaceholderText = "ex: Screech",
--  RemoveTextAfterFocusLost = false,
--     Callback=function(text)
        
--     end
-- })
--misc:CreateParagraph({Title="Warning", Content="This input requires you to put the name of the entity you'd like to spawn... Aswell, this will only work with people that are using the same gui"})

-- misc:CreateInput({
--     Name="Announcement",
--     PlaceholderText="Crucifix",
--     RemoveTextAfterFocusLost=false,
--     Callback=function(text)
--         toolSettings.Title=text
--     end
-- })

-- misc:CreateButton({
--     Name="Create Tool",
--     Callback=function()
--         local Functions = loadstring(game:HttpGet("https://raw.githubusercontent.com/RegularVynixu/Utilities/main/Functions.lua"))()
--         local CustomShop = loadstring(game:HttpGet("https://raw.githubusercontent.com/RegularVynixu/Utilities/main/Doors/Custom%20Shop%20Items/Source.lua"))()
--         local tool = LoadCustomInstance(tool)

--         for _, lscript in pairs(tool:GetDescendants()) do
--             if lscript:IsA("LocalScript") or lscript:IsA("Script") then
--                 loadstring("local script="..lscript:GetFullName().."\n\n"..lscript.Source)()
--             end
--         end

--         CustomShop.CreateItem(tool, toolSettings)
--     end
-- })

-- local EntityCreatorInstance

-- EntityCreator:CreateButton({
--     Name="Save/Spawn Entity",
--     Callback=function()
--         Rayfield:Notify({
--             Title = "Question",
--             Content = "Would you like to save your entity to a LUA file, or to spawn it directly",
--             Duration = 120,
--             Image = 4483362458,
--             Actions = { -- Notification Buttons
--                 Save = {
--                     Name = "Save",
--                     Callback = function()
--                         print("The user tapped Okay!")
--                     end
--                 },
--                 Spawn = {
--                     Name = "Spawn",
--                     Callback = function()
--                         print("The user tapped Okay!")
--                     end
--                 },
--             },
--         })
--     end
-- })
-- EntityCreator:CreateSection("Entity Appearance")

-- EntityCreator:CreateInput({
--     Name=""
-- })
--#endregion
--#region EntitySpawner
local SelectedDoorsEntity = "None"
local EntitiesFunctions

MainTab:CreateButton({
    Name = "Spawn Selected Entity",
    Callback = function()
        local e
        task.spawn(function()
            e = spawnEntity(SelectedDoorsEntity)
        end)
        -- Rayfield:Notify({
        --     Title = "Spawned Entity",
        --     Content = "The entity "..SelectedDoorsEntity.." has spawned",
        --     Duration = 5,
        --     Image = 4483362458,
        --     Actions = {
        --         Okay={
        --             Name="Ok!",
        --             Callback=function() end
        --         },
        --         Remove={
        --             Name="Remove",
        --             Callback=function() 
        --                 repeat task.wait() until typeof(e)=="Instance"
        --                 e:Destroy()
        --             end
        --         }
        --     },
        -- })
    end
})
local SelectedEntityLabel = MainTab:CreateLabel("You currently have the entity " .. SelectedDoorsEntity .. " selected")
task.spawn(function()
    while true do
        SelectedEntityLabel:Set("You currently have the entity " .. SelectedDoorsEntity .. " selected")
        task.wait(.5)
    end
end)

MainTab:CreateSection("Doors Entities")
local CanEntityKill = false

local Creator = loadstring(game:HttpGet("https://raw.githubusercontent.com/RegularVynixu/Utilities/main/Doors%20Entity%20Spawner/Source.lua"))()

local old
old = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
    local args = {
        ...
    }
    if getnamecallmethod() == "FireServer" and self.Name == "Screech" then
        if game.Players.LocalPlayer.Character:FindFirstChild"Crucifix" then
            wait(.02)
            local screech = workspace.CurrentCamera:FindFirstChild("Screech")
            screech:FindFirstChildWhichIsA("AnimationController"):LoadAnimation(screech.Animations.Caught)
            screech.Animations.Attack.AnimationId = "rbxassetid://10493727264"
            local snd = game.Players.LocalPlayer.PlayerGui.MainUI.Initiator.Main_Game.RemoteListener.Modules.Screech.Attack
            snd:Stop()
            snd.Parent.Caught:Play()
            return old(self, false)
        end
        if args[1] == false and CanEntityKill then
            game.Players.LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid").Health -= 40
            debug.setupvalue(getconnections(game.ReplicatedStorage.Bricks.DeathHint.OnClientEvent)[1].Function, 1, {
                "You died to Screech again...",
                "It lurks in dark rooms.",
                "It will almost never attack you if your holding a light source.",
                "However, if you suspect that it is around, look for it and stare it down."
            })
            return nil
        end
    end
    return old(self, ...)
end))

function spawnEntity(sel)
    sel = sel:lower()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/sponguss/Doors-Entity-Replicator/main/ui_cache/" .. sel .. ".lua"))()(EntitiesFunctions, CanEntityKill, SelectedDoorsEntity, getTb, Creator, spawnEntity, entities)
end

MainTab:CreateDropdown({
    Name = "Select Doors Entity",
    Options = entities.RegularEntities,
    CurrentOption = "None",
    Flag = "spongusDoorsEntityDropdown", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
    Callback = function(Option)
        SelectedDoorsEntity = Option
    end,
})

MainTab:CreateKeybind({
    Name = "Keybind Entity",
    CurrentKeybind = "Q",
    HoldToInteract = false,
    Flag = "EntityKeybind", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
    Callback = function(Keybind)
        local e
        task.spawn(function()
            spawnEntity(SelectedDoorsEntity)
        end)
        -- Rayfield:Notify({
        --     Title = "Spawned Entity",
        --     Content = "The entity "..SelectedDoorsEntity.." has spawned",
        --     Duration = 5,
        --     Image = 4483362458,
        --     Actions = {
        --         Okay={
        --             Name="Ok!",
        --             Callback=function() end
        --         },
        --         Remove={
        --             Name="Remove",
        --             Callback=function() 
        --                 repeat task.wait() until typeof(e)=="Instance"
        --                 e:Destroy()
        --             end
        --         }
        --     },
        -- })
    end,
})

MainTab:CreateSection("Developer Entities")
MainTab:CreateDropdown({
    Name = "Select Developer Entity",
    Options = entities.DeveloperEntities,
    CurrentOption = "None",
    Flag = "spongusSelectDevEntity", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
    Callback = function(Option)
        SelectedDoorsEntity = Option
    end,
})
MainTab:CreateSection("Custom Entities")
MainTab:CreateDropdown({
    Name = "Select Custom Entity",
    Options = entities.CustomEntities,
    CurrentOption = "None",
    Flag = "spongusDoorsCustomEntityDropdown", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
    Callback = function(Option)
        SelectedDoorsEntity = Option
    end,
})
MainTab:CreateSection("Entity Configuration")
MainTab:CreateToggle({
    Name = "Toggle Killing",
    CurrentValue = false,
    Flag = "killToggle",
    Callback = function(Value)
        CanEntityKill = Value
    end,
})

local con
local old = game.Players.LocalPlayer:GetAttribute("CurrentRoom")
MainTab:CreateToggle({
    Name = "Run Each Room",
    CurrentValue = false,
    Flag = "runEachRoomToggle",
    Callback = function(Value)
        if Value then
            con = workspace.CurrentRooms.ChildAdded:Connect(function()
                repeat
                    task.wait()
                until old ~= game.Players.LocalPlayer:GetAttribute("CurrentRoom")
                old = game.Players.LocalPlayer:GetAttribute("CurrentRoom")
                local e
                task.spawn(function()
                    e = spawnEntity(SelectedDoorsEntity)
                end)
                -- Rayfield:Notify({
                --     Title = "Spawned Entity",
                --     Content = "The entity "..SelectedDoorsEntity.." has spawned",
                --     Duration = 5,
                --     Image = 4483362458,
                --     Actions = {
                --         Okay={
                --             Name="Ok!",
                --             Callback=function() end
                --         },
                --         Remove={
                --             Name="Remove",
                --             Callback=function() 
                --                 repeat task.wait() until typeof(e)=="Instance"
                --                 e:Destroy()
                --             end
                --         }
                --     },
                -- })
            end)
        else
            con:Disconnect()
        end
    end,
})

local disabled = false
MainTab:CreateInput({
    Name = "Run Entity Each",
    PlaceholderText = "seconds",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        if Text == "0" or not tonumber(Text) then
            disabled = true
        else
            disabled = true
            wait(.1)
            disabled = false
            while disabled ~= true do
                task.wait(tonumber(Text))
                task.spawn(function()
                    local e
                    task.spawn(function()
                        e = spawnEntity(SelectedDoorsEntity)
                    end)
                    -- Rayfield:Notify({
                    --     Title = "Spawned Entity",
                    --     Content = "The entity "..SelectedDoorsEntity.." has spawned",
                    --     Duration = 5,
                    --     Image = 4483362458,
                    --     Actions = {
                    --         Okay={
                    --             Name="Ok!",
                    --             Callback=function() end
                    --         },
                    --         Remove={
                    --             Name="Remove",
                    --             Callback=function() 
                    --                 repeat task.wait() until typeof(e)=="Instance"
                    --                 e:Destroy()
                    --             end
                    --         }
                    --     },
                    -- })
                end)
            end
        end
    end,
})
