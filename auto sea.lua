--[[
    Blox Fruits Auto Farm Laut - Complete Implementation
    Fully compatible with Xeno Executor
    Version 2.0
]]

-- Load libraries
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local VirtualInputManager = game:GetService("VirtualInputManager")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")

-- Player references
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local Humanoid = Character:WaitForChild("Humanoid")

-- Configuration
local Config = {
    AutoBoat = true,
    AutoSail = true,
    TargetIsland = "Random",
    AutoFarmSeaBeasts = true,
    AutoFarmPirates = true,
    AutoCollectChests = true,
    AutoBountyHunt = false,
    BountyThreshold = 500000,
    AutoFruitFinder = true,
    AutoFruitGrab = true,
    AutoServerHop = true,
    HopDelay = 300,
    LowPlayerServer = true,
    MaxPlayers = 8,
    AutoDodge = true,
    AutoReconnect = true,
    CombatMode = "Melee",
    AttackRange = 20,
    PriorityTarget = "SeaBeast",
    BoatSpeed = 50,
    FruitScanRange = 1000,
    ChestScanRange = 500,
    EnemyScanRange = 300
}

-- Cache variables
local CurrentBoat = nil
local CurrentTarget = nil
local LastServerHop = tick()
local Islands = {
    ["Jungle"] = Vector3.new(-1246, 15, 757),
    ["Pirate Village"] = Vector3.new(-1161, 15, 3889),
    ["Desert"] = Vector3.new(954, 7, 4134),
    ["Snow"] = Vector3.new(2324, 25, -716),
    ["Marine"] = Vector3.new(-3914, 19, 302),
    ["Sky"] = Vector3.new(-4867, 554, -2503)
}

-- UI Setup
local Window = Rayfield:CreateWindow({
    Name = "Blox Fruits Auto Farm Laut",
    LoadingTitle = "Loading Script...",
    LoadingSubtitle = "by Xeno Script Hub",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "BloxFarm",
        FileName = "SeaConfig"
    },
    Discord = {
        Enabled = true,
        Invite = "noinvitelink",
        RememberJoins = true
    }
})

-- Main Tabs
local FarmTab = Window:CreateTab("Auto Farm")
local CombatTab = Window:CreateTab("Combat")
local TravelTab = Window:CreateTab("Travel")
local MiscTab = Window:CreateTab("Misc")
local SettingsTab = Window:CreateTab("Settings")

-- UI Elements
FarmTab:CreateToggle({
    Name = "Auto Farm Sea Beasts",
    CurrentValue = Config.AutoFarmSeaBeasts,
    Flag = "AutoFarmSeaBeasts",
    Callback = function(Value) Config.AutoFarmSeaBeasts = Value end
})

FarmTab:CreateToggle({
    Name = "Auto Farm Pirates",
    CurrentValue = Config.AutoFarmPirates,
    Flag = "AutoFarmPirates",
    Callback = function(Value) Config.AutoFarmPirates = Value end
})

FarmTab:CreateToggle({
    Name = "Auto Collect Chests",
    CurrentValue = Config.AutoCollectChests,
    Flag = "AutoCollectChests",
    Callback = function(Value) Config.AutoCollectChests = Value end
})

CombatTab:CreateDropdown({
    Name = "Combat Mode",
    Options = {"Melee", "Sword", "Gun", "Fruit"},
    CurrentOption = Config.CombatMode,
    Flag = "CombatMode",
    Callback = function(Option) Config.CombatMode = Option end
})

CombatTab:CreateSlider({
    Name = "Attack Range",
    Range = {10, 50},
    Increment = 1,
    Suffix = "Studs",
    CurrentValue = Config.AttackRange,
    Flag = "AttackRange",
    Callback = function(Value) Config.AttackRange = Value end
})

CombatTab:CreateToggle({
    Name = "Auto Dodge",
    CurrentValue = Config.AutoDodge,
    Flag = "AutoDodge",
    Callback = function(Value) Config.AutoDodge = Value end
})

CombatTab:CreateDropdown({
    Name = "Priority Target",
    Options = {"SeaBeast", "Pirate", "Player", "Chest", "Fruit"},
    CurrentOption = Config.PriorityTarget,
    Flag = "PriorityTarget",
    Callback = function(Option) Config.PriorityTarget = Option end
})

TravelTab:CreateToggle({
    Name = "Auto Buy & Ride Boat",
    CurrentValue = Config.AutoBoat,
    Flag = "AutoBoat",
    Callback = function(Value) Config.AutoBoat = Value end
})

TravelTab:CreateToggle({
    Name = "Auto Sail",
    CurrentValue = Config.AutoSail,
    Flag = "AutoSail",
    Callback = function(Value) Config.AutoSail = Value end
})

TravelTab:CreateDropdown({
    Name = "Target Island",
    Options = {"Random", "Jungle", "Pirate Village", "Desert", "Snow", "Marine", "Sky"},
    CurrentOption = Config.TargetIsland,
    Flag = "TargetIsland",
    Callback = function(Option) Config.TargetIsland = Option end
})

TravelTab:CreateSlider({
    Name = "Boat Speed",
    Range = {20, 100},
    Increment = 5,
    Suffix = "Speed",
    CurrentValue = Config.BoatSpeed,
    Flag = "BoatSpeed",
    Callback = function(Value) Config.BoatSpeed = Value end
})

MiscTab:CreateToggle({
    Name = "Auto Bounty Hunt",
    CurrentValue = Config.AutoBountyHunt,
    Flag = "AutoBountyHunt",
    Callback = function(Value) Config.AutoBountyHunt = Value end
})

MiscTab:CreateSlider({
    Name = "Bounty Threshold",
    Range = {100000, 5000000},
    Increment = 10000,
    Suffix = "Bounty",
    CurrentValue = Config.BountyThreshold,
    Flag = "BountyThreshold",
    Callback = function(Value) Config.BountyThreshold = Value end
})

MiscTab:CreateToggle({
    Name = "Auto Fruit Finder",
    CurrentValue = Config.AutoFruitFinder,
    Flag = "AutoFruitFinder",
    Callback = function(Value) Config.AutoFruitFinder = Value end
})

MiscTab:CreateToggle({
    Name = "Auto Fruit Grab",
    CurrentValue = Config.AutoFruitGrab,
    Flag = "AutoFruitGrab",
    Callback = function(Value) Config.AutoFruitGrab = Value end
})

MiscTab:CreateToggle({
    Name = "Auto Server Hop",
    CurrentValue = Config.AutoServerHop,
    Flag = "AutoServerHop",
    Callback = function(Value) Config.AutoServerHop = Value end
})

MiscTab:CreateToggle({
    Name = "Find Low Player Server",
    CurrentValue = Config.LowPlayerServer,
    Flag = "LowPlayerServer",
    Callback = function(Value) Config.LowPlayerServer = Value end
})

MiscTab:CreateToggle({
    Name = "Auto Reconnect",
    CurrentValue = Config.AutoReconnect,
    Flag = "AutoReconnect",
    Callback = function(Value) Config.AutoReconnect = Value end
})

SettingsTab:CreateSlider({
    Name = "Fruit Scan Range",
    Range = {500, 2000},
    Increment = 50,
    Suffix = "Studs",
    CurrentValue = Config.FruitScanRange,
    Flag = "FruitScanRange",
    Callback = function(Value) Config.FruitScanRange = Value end
})

SettingsTab:CreateSlider({
    Name = "Chest Scan Range",
    Range = {200, 1000},
    Increment = 50,
    Suffix = "Studs",
    CurrentValue = Config.ChestScanRange,
    Flag = "ChestScanRange",
    Callback = function(Value) Config.ChestScanRange = Value end
})

SettingsTab:CreateSlider({
    Name = "Enemy Scan Range",
    Range = {100, 500},
    Increment = 25,
    Suffix = "Studs",
    CurrentValue = Config.EnemyScanRange,
    Flag = "EnemyScanRange",
    Callback = function(Value) Config.EnemyScanRange = Value end
})

-- Utility Functions
function GetNearestBoat()
    local nearestBoat = nil
    local shortestDistance = math.huge
    
    for _, boat in pairs(Workspace.Boats:GetChildren()) do
        if boat:FindFirstChild("VehicleSeat") and boat.VehicleSeat:FindFirstChild("SeatWeld") == nil then
            local distance = (HumanoidRootPart.Position - boat.VehicleSeat.Position).Magnitude
            if distance < shortestDistance then
                nearestBoat = boat
                shortestDistance = distance
            end
        end
    end
    
    return nearestBoat
end

function BuyBoat()
    local boatShop = Workspace:FindFirstChild("BoatShop")
    if boatShop then
        local closestDealer = nil
        local minDistance = math.huge
        
        for _, dealer in pairs(boatShop:GetChildren()) do
            if dealer:FindFirstChild("Head") then
                local distance = (HumanoidRootPart.Position - dealer.Head.Position).Magnitude
                if distance < minDistance then
                    closestDealer = dealer
                    minDistance = distance
                end
            end
        end
        
        if closestDealer and minDistance < 20 then
            fireclickdetector(closestDealer:FindFirstChildOfType("ClickDetector"))
            task.wait(1)
            -- Select cheapest boat
            if Player.PlayerGui:FindFirstChild("BoatShop") then
                local frame = Player.PlayerGui.BoatShop.Frame.MainFrame
                for _, button in pairs(frame:GetChildren()) do
                    if button:IsA("TextButton") and button.Name ~= "Exit" then
                        fireclickdetector(button:FindFirstChildOfType("ClickDetector"))
                        break
                    end
                end
            end
        else
            -- Move to boat shop
            Humanoid:MoveTo(boatShop:GetModelCFrame().Position)
        end
    end
end

function BoardBoat(boat)
    if boat and boat:FindFirstChild("VehicleSeat") then
        local seat = boat.VehicleSeat
        if seat:FindFirstChild("SeatWeld") == nil then
            Humanoid.Sit = true
            HumanoidRootPart.CFrame = seat.CFrame * CFrame.new(0, -1, 0)
            task.wait(0.5)
            firetouchinterest(HumanoidRootPart, seat, 0)
            firetouchinterest(HumanoidRootPart, seat, 1)
            CurrentBoat = boat
        end
    end
end

function GetRandomIsland()
    local keys = {}
    for k in pairs(Islands) do table.insert(keys, k) end
    return keys[math.random(1, #keys)]
end

function GetIslandPosition(islandName)
    if islandName == "Random" then
        islandName = GetRandomIsland()
    end
    return Islands[islandName]
end

function GetNearestEnemy()
    local enemies = {}
    local priorityTargets = {}
    
    -- Sea Beasts
    if Config.AutoFarmSeaBeasts then
        for _, beast in pairs(Workspace:GetChildren()) do
            if beast.Name == "SeaBeast" and beast:FindFirstChild("Humanoid") and beast.Humanoid.Health > 0 then
                local distance = (HumanoidRootPart.Position - beast:FindFirstChild("HumanoidRootPart").Position).Magnitude
                if distance < Config.EnemyScanRange then
                    table.insert(enemies, {Type = "SeaBeast", Object = beast, Distance = distance})
                    if Config.PriorityTarget == "SeaBeast" then
                        table.insert(priorityTargets, {Type = "SeaBeast", Object = beast, Distance = distance})
                    end
                end
            end
        end
    end
    
    -- Pirates
    if Config.AutoFarmPirates then
        for _, npc in pairs(Workspace.NPCs:GetChildren()) do
            if (npc.Name:find("Pirate") or npc.Name:find("Bandit")) and npc:FindFirstChild("Humanoid") and npc.Humanoid.Health > 0 then
                local distance = (HumanoidRootPart.Position - npc:FindFirstChild("HumanoidRootPart").Position).Magnitude
                if distance < Config.EnemyScanRange then
                    table.insert(enemies, {Type = "Pirate", Object = npc, Distance = distance})
                    if Config.PriorityTarget == "Pirate" then
                        table.insert(priorityTargets, {Type = "Pirate", Object = npc, Distance = distance})
                    end
                end
            end
        end
    end
    
    -- Players (for bounty)
    if Config.AutoBountyHunt then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= Player and player:FindFirstChild("leaderstats") then
                local bounty = player.leaderstats:FindFirstChild("Bounty") or player.leaderstats:FindFirstChild("฿ounty")
                if bounty and tonumber(bounty.Value) >= Config.BountyThreshold then
                    local char = player.Character
                    if char and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
                        local distance = (HumanoidRootPart.Position - char:FindFirstChild("HumanoidRootPart").Position).Magnitude
                        if distance < Config.EnemyScanRange then
                            table.insert(enemies, {Type = "Player", Object = char, Distance = distance})
                            if Config.PriorityTarget == "Player" then
                                table.insert(priorityTargets, {Type = "Player", Object = char, Distance = distance})
                            end
                        end
                    end
                end
            end
        end
    end
    
    -- Chests
    if Config.AutoCollectChests then
        for _, chest in pairs(Workspace:GetChildren()) do
            if chest.Name:find("Chest") and chest:FindFirstChild("Chest") then
                local distance = (HumanoidRootPart.Position - chest.Position).Magnitude
                if distance < Config.ChestScanRange then
                    table.insert(enemies, {Type = "Chest", Object = chest, Distance = distance})
                    if Config.PriorityTarget == "Chest" then
                        table.insert(priorityTargets, {Type = "Chest", Object = chest, Distance = distance})
                    end
                end
            end
        end
    end
    
    -- Fruits
    if Config.AutoFruitFinder and Config.AutoFruitGrab then
        for _, fruit in pairs(Workspace:GetChildren()) do
            if fruit:FindFirstChild("Handle") and fruit.Name:find("Fruit") then
                local distance = (HumanoidRootPart.Position - fruit.Handle.Position).Magnitude
                if distance < Config.FruitScanRange then
                    table.insert(enemies, {Type = "Fruit", Object = fruit, Distance = distance})
                    if Config.PriorityTarget == "Fruit" then
                        table.insert(priorityTargets, {Type = "Fruit", Object = fruit, Distance = distance})
                    end
                end
            end
        end
    end
    
    -- Return priority target if exists, otherwise closest enemy
    if #priorityTargets > 0 then
        table.sort(priorityTargets, function(a, b) return a.Distance < b.Distance end)
        return priorityTargets[1].Object, priorityTargets[1].Type
    elseif #enemies > 0 then
        table.sort(enemies, function(a, b) return a.Distance < b.Distance end)
        return enemies[1].Object, enemies[1].Type
    end
    
    return nil
end

function AttackTarget(target, targetType)
    if not target then return end
    
    local targetPos = target:FindFirstChild("HumanoidRootPart") and target.HumanoidRootPart.Position or target.Position
    
    -- Move to target
    if (HumanoidRootPart.Position - targetPos).Magnitude > Config.AttackRange then
        Humanoid:MoveTo(targetPos)
        return
    end
    
    -- Face target
    HumanoidRootPart.CFrame = CFrame.new(HumanoidRootPart.Position, Vector3.new(targetPos.X, HumanoidRootPart.Position.Y, targetPos.Z))
    
    -- Combat based on mode
    if Config.CombatMode == "Melee" then
        -- Melee attacks
        VirtualInputManager:SendKeyEvent(true, "Z", false, game)
        task.wait(0.1)
        VirtualInputManager:SendKeyEvent(false, "Z", false, game)
        
        VirtualInputManager:SendKeyEvent(true, "X", false, game)
        task.wait(0.1)
        VirtualInputManager:SendKeyEvent(false, "X", false, game)
    elseif Config.CombatMode == "Sword" then
        -- Sword attacks
        VirtualInputManager:SendKeyEvent(true, "C", false, game)
        task.wait(0.1)
        VirtualInputManager:SendKeyEvent(false, "C", false, game)
    elseif Config.CombatMode == "Gun" then
        -- Gun attacks
        VirtualInputManager:SendKeyEvent(true, "V", false, game)
        task.wait(0.1)
        VirtualInputManager:SendKeyEvent(false, "V", false, game)
    elseif Config.CombatMode == "Fruit" then
        -- Fruit attacks
        VirtualInputManager:SendKeyEvent(true, "F", false, game)
        task.wait(0.1)
        VirtualInputManager:SendKeyEvent(false, "F", false, game)
    end
    
    -- Collect chest or fruit
    if targetType == "Chest" or targetType == "Fruit" then
        if (HumanoidRootPart.Position - targetPos).Magnitude < 10 then
            firetouchinterest(HumanoidRootPart, target, 0)
            firetouchinterest(HumanoidRootPart, target, 1)
        end
    end
end

function DodgeAttack()
    if not Config.AutoDodge then return end
    
    -- Check for incoming attacks
    for _, part in pairs(Workspace:GetPartsInPart(HumanoidRootPart, 15)) do
        if part:FindFirstChild("creator") or part.Name:find("Hitbox") then
            -- Perform dodge
            Humanoid.Jump = true
            local dodgeDir = (HumanoidRootPart.Position - part.Position).Unit * 10
            HumanoidRootPart.Velocity = Vector3.new(dodgeDir.X, Humanoid.JumpPower, dodgeDir.Z)
            return
        end
    end
end

function SailToIsland()
    if not Config.AutoSail or not Config.TargetIsland then return end
    
    local targetPos = GetIslandPosition(Config.TargetIsland)
    if not targetPos then return end
    
    if CurrentBoat then
        -- Calculate direction
        local direction = (targetPos - CurrentBoat.VehicleSeat.Position).Unit
        local forward = CurrentBoat.VehicleSeat.CFrame.LookVector
        
        -- Calculate angle between current direction and target direction
        local angle = math.atan2(direction.X, direction.Z) - math.atan2(forward.X, forward.Z)
        angle = (angle + math.pi) % (2 * math.pi) - math.pi
        
        -- Steer boat
        if angle > 0.1 then
            VirtualInputManager:SendKeyEvent(true, "A", false, game)
            VirtualInputManager:SendKeyEvent(false, "A", false, game)
        elseif angle < -0.1 then
            VirtualInputManager:SendKeyEvent(true, "D", false, game)
            VirtualInputManager:SendKeyEvent(false, "D", false, game)
        end
        
        -- Move forward
        VirtualInputManager:SendKeyEvent(true, "W", false, game)
    else
        -- Move to target position on foot
        Humanoid:MoveTo(targetPos)
    end
end

function CheckServerHop()
    if not Config.AutoServerHop or tick() - LastServerHop < Config.HopDelay then return end
    
    local shouldHop = false
    
    -- Check player count
    if Config.LowPlayerServer and #Players:GetPlayers() > Config.MaxPlayers then
        shouldHop = true
    end
    
    -- Check for targets
    if Config.AutoFarmSeaBeasts and #Workspace:GetChildren("SeaBeast") == 0 then
        shouldHop = true
    end
    
    if shouldHop then
        ServerHop()
        LastServerHop = tick()
    end
end

function ServerHop()
    local servers = {}
    local success, result = pcall(function()
        return game:GetService("HttpService"):JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"))
    end)
    
    if success and result and result.data then
        for _, server in pairs(result.data) do
            if server.playing and (not Config.LowPlayerServer or server.playing < Config.MaxPlayers) and server.id ~= game.JobId then
                table.insert(servers, server.id)
            end
        end
    end
    
    if #servers > 0 then
        TeleportService:TeleportToPlaceInstance(game.PlaceId, servers[math.random(1, #servers)], Player)
    else
        TeleportService:Teleport(game.PlaceId, Player)
    end
end

-- Main Loop
RunService.Heartbeat:Connect(function()
    -- Update character references
    if not Character or not Character.Parent then
        Character = Player.Character or Player.CharacterAdded:Wait()
        HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
        Humanoid = Character:WaitForChild("Humanoid")
    end
    
    -- Auto Boat Logic
    if Config.AutoBoat then
        if not CurrentBoat or not CurrentBoat.Parent then
            local boat = GetNearestBoat()
            if boat then
                BoardBoat(boat)
            else
                BuyBoat()
            end
        end
    end
    
    -- Auto Sail Logic
    SailToIsland()
    
    -- Combat Logic
    DodgeAttack()
    
    local target, targetType = GetNearestEnemy()
    if target then
        AttackTarget(target, targetType)
    end
    
    -- Server Management
    CheckServerHop()
end)

-- Auto Reconnect
game:GetService("Players").LocalPlayer.OnTeleport:Connect(function(State)
    if State == Enum.TeleportState.Started and Config.AutoReconnect then
        local script = [[
            wait(5)
            loadstring(game:HttpGet("https://raw.githubusercontent.com/your-repo/main.lua"))()
        ]]
        queue_on_teleport(script)
    end
end)

-- Initialize
Rayfield:LoadConfiguration()
Rayfield:Notify({
    Title = "Script Loaded",
    Content = "Blox Fruits Auto Farm Laut is now running!",
    Duration = 6.5,
    Image = nil,
    Actions = {
        Ignore = {
            Name = "Okay",
            Callback = function() end
        },
    },
})
