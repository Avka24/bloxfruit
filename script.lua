--[[
    Auto Farm Laut Blox Fruits v2.0
    Kompatibel dengan Ronix PC
    Fitur Lengkap dengan Performa Optimal
]]

-- Load required libraries
local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/shlexware/Rayfield/main/source'))()
local VirtualInputManager = game:GetService("VirtualInputManager")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")

-- Player references
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local Humanoid = Character:WaitForChild("Humanoid")

-- Configuration
local config = {
    autoBoat = true,
    autoSail = true,
    autoFarm = true,
    autoSeaBeast = true,
    autoChest = true,
    autoBounty = false,
    autoFruit = true,
    serverHop = true,
    lowPlayerServer = true,
    maxPlayersForHop = 8,
    hopDelay = 60,
    attackRange = 50,
    seaBeastPriority = true,
    aimOffset = Vector3.new(0, 3, 0),
    fruitScanRadius = 500,
    chestScanRadius = 300,
    playerScanRadius = 200,
    dodgeEnabled = true,
    dodgeDistance = 15,
    dodgeCooldown = 1
}

-- State variables
local lastDodgeTime = 0
local currentBoat = nil
local currentTarget = nil
local currentIsland = nil
local fruitWaypoints = {}
local chestWaypoints = {}
local serverHopAttempts = 0
local lastServerHopTime = 0

-- UI Setup
local Window = Rayfield:CreateWindow({
    Name = "Auto Farm Laut Blox Fruits",
    LoadingTitle = "Memuat Auto Farm...",
    LoadingSubtitle = "by Professional Script Developer",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "BloxFarmConfig",
        FileName = "LautConfig.json"
    },
    Discord = {
        Enabled = true,
        Invite = "invitelink",
        RememberJoins = true
    }
})

-- Main Tabs
local MainTab = Window:CreateTab("Main", 4483362458)
local FarmingTab = Window:CreateTab("Farming", 4483362458)
local PlayerTab = Window:CreateTab("Player", 4483362458)
local TeleportTab = Window:CreateTab("Teleport", 4483362458)
local SettingsTab = Window:CreateTab("Settings", 4483362458)

-- Main Section
MainTab:CreateToggle({
    Name = "Aktifkan Auto Farm",
    CurrentValue = true,
    Flag = "AutoFarmEnabled",
    Callback = function(Value)
        config.autoFarm = Value
    end,
})

MainTab:CreateToggle({
    Name = "Auto Boat",
    CurrentValue = true,
    Flag = "AutoBoatEnabled",
    Callback = function(Value)
        config.autoBoat = Value
    end,
})

MainTab:CreateToggle({
    Name = "Auto Sail",
    CurrentValue = true,
    Flag = "AutoSailEnabled",
    Callback = function(Value)
        config.autoSail = Value
    end,
})

-- Farming Section
FarmingTab:CreateToggle({
    Name = "Auto Kill Sea Beast",
    CurrentValue = true,
    Flag = "AutoSeaBeastEnabled",
    Callback = function(Value)
        config.autoSeaBeast = Value
    end,
})

FarmingTab:CreateToggle({
    Name = "Auto Collect Chest",
    CurrentValue = true,
    Flag = "AutoChestEnabled",
    Callback = function(Value)
        config.autoChest = Value
    end,
})

FarmingTab:CreateToggle({
    Name = "Auto Fruit Finder",
    CurrentValue = true,
    Flag = "AutoFruitEnabled",
    Callback = function(Value)
        config.autoFruit = Value
    end,
})

-- Player Section
PlayerTab:CreateToggle({
    Name = "Auto Bounty Hunt",
    CurrentValue = false,
    Flag = "AutoBountyEnabled",
    Callback = function(Value)
        config.autoBounty = Value
    end,
})

PlayerTab:CreateToggle({
    Name = "Auto Dodge",
    CurrentValue = true,
    Flag = "AutoDodgeEnabled",
    Callback = function(Value)
        config.dodgeEnabled = Value
    end,
})

-- Server Section
SettingsTab:CreateToggle({
    Name = "Auto Server Hop",
    CurrentValue = true,
    Flag = "AutoHopEnabled",
    Callback = function(Value)
        config.serverHop = Value
    end,
})

SettingsTab:CreateToggle({
    Name = "Cari Server Sepi",
    CurrentValue = true,
    Flag = "LowPlayerServerEnabled",
    Callback = function(Value)
        config.lowPlayerServer = Value
    end,
})

SettingsTab:CreateSlider({
    Name = "Max Players untuk Hop",
    Range = {1, 20},
    Increment = 1,
    Suffix = "players",
    CurrentValue = 8,
    Flag = "MaxPlayersForHop",
    Callback = function(Value)
        config.maxPlayersForHop = Value
    end,
})

-- Utility functions
function getNearestIsland()
    local islands = {}
    for _, obj in pairs(Workspace:GetChildren()) do
        if obj.Name:find("Island") and obj:FindFirstChild("HumanoidRootPart") then
            table.insert(islands, obj)
        end
    end
    
    local nearestIsland = nil
    local shortestDistance = math.huge
    
    for _, island in pairs(islands) do
        local distance = (HumanoidRootPart.Position - island.HumanoidRootPart.Position).Magnitude
        if distance < shortestDistance then
            shortestDistance = distance
            nearestIsland = island
        end
    end
    
    return nearestIsland
end

function getBoat()
    local boats = {}
    for _, obj in pairs(Workspace.Boats:GetChildren()) do
        if obj:FindFirstChild("VehicleSeat") then
            table.insert(boats, obj)
        end
    end
    
    local nearestBoat = nil
    local shortestDistance = math.huge
    
    for _, boat in pairs(boats) do
        local distance = (HumanoidRootPart.Position - boat.VehicleSeat.Position).Magnitude
        if distance < shortestDistance then
            shortestDistance = distance
            nearestBoat = boat
        end
    end
    
    return nearestBoat
end

function buyBoat()
    local boatShop = Workspace:FindFirstChild("BoatShop")
    if boatShop then
        local boatModel = boatShop:FindFirstChild("BoatModel")
        if boatModel then
            local buyEvent = boatModel:FindFirstChild("BuyBoat")
            if buyEvent then
                firetouchinterest(HumanoidRootPart, buyEvent, 0)
                firetouchinterest(HumanoidRootPart, buyEvent, 1)
                return true
            end
        end
    end
    return false
end

function boardBoat(boat)
    if boat and boat:FindFirstChild("VehicleSeat") then
        local seat = boat.VehicleSeat
        local distance = (HumanoidRootPart.Position - seat.Position).Magnitude
        
        if distance < 15 then
            Humanoid.Sit = true
            wait(0.1)
            VirtualInputManager:SendKeyEvent(true, "E", false, game)
            wait(0.1)
            VirtualInputManager:SendKeyEvent(false, "E", false, game)
            return true
        else
            -- Move to boat
            Humanoid:MoveTo(seat.Position)
        end
    end
    return false
end

function getClosestEnemy()
    local closestEnemy = nil
    local shortestDistance = math.huge
    
    -- Check for Sea Beasts
    if config.autoSeaBeast then
        for _, enemy in pairs(Workspace.SeaBeasts:GetChildren()) do
            if enemy:FindFirstChild("HumanoidRootPart") and enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
                local distance = (HumanoidRootPart.Position - enemy.HumanoidRootPart.Position).Magnitude
                if distance < config.attackRange and distance < shortestDistance then
                    shortestDistance = distance
                    closestEnemy = enemy
                end
            end
        end
    end
    
    -- Check for NPCs
    for _, npc in pairs(Workspace.NPCs:GetChildren()) do
        if npc:FindFirstChild("HumanoidRootPart") and npc:FindFirstChild("Humanoid") and npc.Humanoid.Health > 0 then
            local distance = (HumanoidRootPart.Position - npc.HumanoidRootPart.Position).Magnitude
            if distance < config.attackRange and distance < shortestDistance then
                shortestDistance = distance
                closestEnemy = npc
            end
        end
    end
    
    -- Check for Players if bounty hunting is enabled
    if config.autoBounty then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
                local bounty = player:GetAttribute("Bounty") or 0
                if bounty >= 100000 then -- Only target high bounty players
                    local distance = (HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                    if distance < config.playerScanRadius and distance < shortestDistance then
                        shortestDistance = distance
                        closestEnemy = player.Character
                    end
                end
            end
        end
    end
    
    return closestEnemy
end

function attackEnemy(enemy)
    if not enemy or not enemy:FindFirstChild("HumanoidRootPart") then return end
    
    -- Face the enemy
    local targetPosition = enemy.HumanoidRootPart.Position + config.aimOffset
    HumanoidRootPart.CFrame = CFrame.new(HumanoidRootPart.Position, Vector3.new(targetPosition.X, HumanoidRootPart.Position.Y, targetPosition.Z))
    
    -- Attack logic
    local combatFramework = require(ReplicatedStorage:WaitForChild("CombatFramework"))
    local combatModule = debug.getupvalue(combatFramework, 2)
    local cooldown = combatModule.activeController.timeToNextAttack
    
    if cooldown <= 0 then
        combatModule.activeController:attack()
    end
    
    -- Use skills if available
    local skills = {
        "Z",
        "X",
        "C",
        "V",
        "F"
    }
    
    for _, skill in pairs(skills) do
        VirtualInputManager:SendKeyEvent(true, skill, false, game)
        wait(0.1)
        VirtualInputManager:SendKeyEvent(false, skill, false, game)
    end
end

function dodgeAttack()
    if os.clock() - lastDodgeTime < config.dodgeCooldown then return end
    
    -- Check for incoming projectiles
    for _, obj in pairs(Workspace:GetChildren()) do
        if obj.Name:find("Projectile") or obj.Name:find("Bullet") then
            local distance = (HumanoidRootPart.Position - obj.Position).Magnitude
            if distance < 20 then
                -- Calculate dodge direction
                local dodgeDirection = (HumanoidRootPart.Position - obj.Position).Unit * config.dodgeDistance
                local newPosition = HumanoidRootPart.Position + dodgeDirection
                
                -- Teleport to dodge
                HumanoidRootPart.CFrame = CFrame.new(newPosition)
                lastDodgeTime = os.clock()
                break
            end
        end
    end
end

function scanForFruits()
    fruitWaypoints = {}
    for _, obj in pairs(Workspace:GetChildren()) do
        if obj.Name:find("Fruit") and obj:FindFirstChild("Handle") then
            local distance = (HumanoidRootPart.Position - obj.Handle.Position).Magnitude
            if distance < config.fruitScanRadius then
                table.insert(fruitWaypoints, obj.Handle)
            end
        end
    end
end

function scanForChests()
    chestWaypoints = {}
    for _, obj in pairs(Workspace:GetChildren()) do
        if obj.Name:find("Chest") and obj:FindFirstChild("Chest") then
            local distance = (HumanoidRootPart.Position - obj.Chest.Position).Magnitude
            if distance < config.chestScanRadius then
                table.insert(chestWaypoints, obj.Chest)
            end
        end
    end
end

function collectNearestFruit()
    if #fruitWaypoints == 0 then return false end
    
    local nearestFruit = nil
    local shortestDistance = math.huge
    
    for _, fruit in pairs(fruitWaypoints) do
        local distance = (HumanoidRootPart.Position - fruit.Position).Magnitude
        if distance < shortestDistance then
            shortestDistance = distance
            nearestFruit = fruit
        end
    end
    
    if nearestFruit then
        Humanoid:MoveTo(nearestFruit.Position)
        if shortestDistance < 10 then
            firetouchinterest(HumanoidRootPart, nearestFruit, 0)
            firetouchinterest(HumanoidRootPart, nearestFruit, 1)
            return true
        end
    end
    
    return false
end

function collectNearestChest()
    if #chestWaypoints == 0 then return false end
    
    local nearestChest = nil
    local shortestDistance = math.huge
    
    for _, chest in pairs(chestWaypoints) do
        local distance = (HumanoidRootPart.Position - chest.Position).Magnitude
        if distance < shortestDistance then
            shortestDistance = distance
            nearestChest = chest
        end
    end
    
    if nearestChest then
        Humanoid:MoveTo(nearestChest.Position)
        if shortestDistance < 10 then
            firetouchinterest(HumanoidRootPart, nearestChest, 0)
            firetouchinterest(HumanoidRootPart, nearestChest, 1)
            return true
        end
    end
    
    return false
end

function shouldServerHop()
    if not config.serverHop then return false end
    if os.time() - lastServerHopTime < config.hopDelay then return false end
    
    -- Check player count
    if config.lowPlayerServer and #Players:GetPlayers() > config.maxPlayersForHop then
        return true
    end
    
    -- Check if no targets available
    if config.autoSeaBeast and #Workspace.SeaBeasts:GetChildren() == 0 then
        return true
    end
    
    return false
end

function serverHop()
    if serverHopAttempts > 3 then 
        Rayfield:Notify({
            Title = "Server Hop",
            Content = "Gagal pindah server setelah 3 percobaan. Menonaktifkan auto hop.",
            Duration = 6.5,
            Image = 4483362458,
            Actions = {
                Ignore = {
                    Name = "Oke",
                    Callback = function()
                        config.serverHop = false
                    end
                },
            },
        })
        return
    end
    
    serverHopAttempts = serverHopAttempts + 1
    lastServerHopTime = os.time()
    
    Rayfield:Notify({
        Title = "Server Hop",
        Content = "Mencari server baru... (Percobaan "..serverHopAttempts..")",
        Duration = 6.5,
        Image = 4483362458,
    })
    
    -- Server hop logic
    local servers = {}
    local req = syn.request({
        Url = "https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100",
        Method = "GET"
    })
    
    if req.StatusCode == 200 then
        local body = HttpService:JSONDecode(req.Body)
        for _, server in pairs(body.data) do
            if server.playing < config.maxPlayersForHop and server.id ~= game.JobId then
                table.insert(servers, server.id)
            end
        end
    end
    
    if #servers > 0 then
        local randomServer = servers[math.random(1, #servers)]
        TeleportService:TeleportToPlaceInstance(game.PlaceId, randomServer, LocalPlayer)
    else
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end
end

-- Main loop
local RunService = game:GetService("RunService")
RunService.Heartbeat:Connect(function()
    if not config.autoFarm then return end
    
    -- Auto Boat
    if config.autoBoat and not currentBoat then
        currentBoat = getBoat()
        if not currentBoat then
            if buyBoat() then
                wait(3) -- Wait for boat to spawn
                currentBoat = getBoat()
            end
        else
            boardBoat(currentBoat)
        end
    end
    
    -- Auto Sail
    if config.autoSail and currentBoat then
        currentIsland = getNearestIsland()
        if currentIsland then
            local boatSeat = currentBoat:FindFirstChild("VehicleSeat")
            if boatSeat then
                local targetPosition = currentIsland.HumanoidRootPart.Position
                Humanoid:MoveTo(targetPosition)
            end
        end
    end
    
    -- Scan for targets and items
    scanForFruits()
    scanForChests()
    
    -- Priority: Sea Beasts
    if config.autoSeaBeast then
        currentTarget = getClosestEnemy()
        if currentTarget then
            attackEnemy(currentTarget)
            if config.dodgeEnabled then
                dodgeAttack()
            end
            return -- Focus on combat first
        end
    end
    
    -- Collect fruits
    if config.autoFruit and #fruitWaypoints > 0 then
        if collectNearestFruit() then return end
    end
    
    -- Collect chests
    if config.autoChest and #chestWaypoints > 0 then
        if collectNearestChest() then return end
    end
    
    -- Server hop if conditions met
    if shouldServerHop() then
        serverHop()
    end
end)

-- Auto Reconnect
game:GetService("Players").LocalPlayer.OnTeleport:Connect(function(state)
    if state == Enum.TeleportState.Started then
        local code = [[
            loadstring(game:HttpGet('https://raw.githubusercontent.com/Avka24/bloxfruit/refs/heads/main/script.lua'))()
        ]]
        local queueonteleport = (syn and syn.queue_on_teleport) or queue_on_teleport or (fluxus and fluxus.queue_on_teleport)
        if queueonteleport then
            queueonteleport(code)
        end
    end
end)

-- Initialize
Rayfield:Notify({
    Title = "Auto Farm Laut",
    Content = "Script berhasil diaktifkan!",
    Duration = 6.5,
    Image = 4483362458,
})
