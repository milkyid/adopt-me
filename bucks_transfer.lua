local targetName = "usn" 

print("Waiting game loaded..")

repeat
    task.wait()
until
    game:IsLoaded()

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")


print("Waiting asset loaded..") 
repeat 
    task.wait(0.5) 
until 
    PlayerGui.AssetLoadUI.Enabled == false and PlayerGui.NewsApp.Enabled == true

local fsys = require(ReplicatedStorage:WaitForChild("Fsys"))
local function loadSafe(name)
    local success, module = pcall(function() return fsys.load(name) end)
    if not success or not module then
        task.spawn(function() pcall(fsys.load, name) end); task.wait(1)
        for i = 1, 15 do
            local val = debug.getupvalue(fsys.load, i)
            if typeof(val) == "table" and val[name] then return val[name] end
        end
    end
    return module
end

local routerClient = loadSafe("RouterClient")
local uiManager = loadSafe("UIManager")

local function dehash()
    local renamed = {}
    local upvals = debug.getupvalue(routerClient.init, 7)
    if upvals then
        table.foreach(upvals, function(n, r) renamed[n] = r; r.Name = n end)
    end
    return renamed
end

local remotes = dehash()

if not LocalPlayer.Character then
    remotes['TeamAPI/ChooseTeam']:InvokeServer("Parents", {dont_enter_location = true, source_for_logging = "intro_sequence"})
    if uiManager then uiManager.set_app_visibility('MainMenuApp', false); uiManager.set_app_visibility('NewsApp', false) end
    LocalPlayer.CharacterAdded:Wait(); task.wait(5)
end

if LocalPlayer.name ~= targetName then
    while true do
        local targetPlayer = Players:FindFirstChild(targetName)

        if targetPlayer then
            print("Target found: " .. targetName)

            remotes['LocationAPI/TeleToPlayer']:InvokeServer(targetPlayer)
            
            local t = tick()
            repeat task.wait(0.5) until (workspace.HouseInteriors:FindFirstChild("furniture")) or (tick()-t > 10)

            task.wait(5)
            print("Scanning for Mannequin...")

            local function getMannequinId()
                for _, v in ipairs(workspace.HouseInteriors.furniture:GetChildren()) do
                    for _, v1 in ipairs(v:GetChildren()) do
                        if v1.Name == "Mannequin" then
                            return v1:GetAttribute("furniture_unique"), v1:FindFirstChild("Mannequin"):GetAttribute("outfit_version")
                        end
                    end
                end
            end

            MannequinId, OutfitId = getMannequinId()

            if MannequinId and OutfitId then
                print("Mannequin found! Executing buy...")
                for i = 1, 3 do
                    local success, err = pcall(function()
                        local args = {targetPlayer, MannequinId, OutfitId, 100} 
                        remotes['AvatarAPI/BuyMannequinOutfit']:InvokeServer(unpack(args))
                        print("Buy Success!")
                        task.wait(1)
                        remotes['AvatarAPI/DeleteOutfit']:FireServer("player", "Outfit")
                    end)
                    if success then
                        task.wait(2)
                    else
                        warn("Failed buying mannequin.")
                        break
                    end
                end
            else
                print(MannequinId, OutfitId)
                warn("Mannequin not found.")
            end
        else
            warn("Target not found.")
        end

        print("Waiting 120s...")
        task.wait(120)
    end
else
    remotes['TeamAPI/Spawn']:InvokeServer()

    task.spawn(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/hassanxzayn-lua/Anti-afk/main/antiafkbyhassanxzyn"))();
    end)
end
