local targetName = "ArtzGeming" 

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
    PlayerGui.AssetLoadUI.Enabled == false and LocalPlayer:GetAttribute("file_load_status_debug") == "Done"

local Fsys = require(ReplicatedStorage:WaitForChild("Fsys"))

local  function ModuleLoader(name)
    local cache = debug.getupvalue(Fsys.load, 4)
    print('Waiting for', name)
    repeat
        task.wait()
    until typeof(cache[name]) == 'table'

    return cache[name]

end
local RouterClient = ModuleLoader("RouterClient")
local UIManager = ModuleLoader("UIManager")
local InteriorsM = ModuleLoader("InteriorsM")
local ClientData = ModuleLoader("ClientData")

local function Dehasher()
    local renamed = {}
    local upvals = debug.getupvalue(RouterClient.init, 7)
    if upvals then
        table.foreach(upvals, function(n, r) renamed[n] = r; r.Name = n end)
    end
    return renamed
end

local function GetBucks()
    for k, v in pairs(ClientData.get_data()[LocalPlayer.name]) do
        if k == "money" then
            return v
        end
    end
end

local function GetMannequin()
    for _, v in ipairs(workspace.HouseInteriors.furniture:GetChildren()) do
        for _, v1 in ipairs(v:GetChildren()) do
            if v1.Name == "Mannequin" then
                return v1:GetAttribute("furniture_unique"), v1:FindFirstChild("Mannequin"):GetAttribute("outfit_version")
            end
        end
    end
end

local function FormatNumber(n)
    return tostring(n):reverse():gsub("%d%d%d", "%1,"):reverse():gsub("^,", "")
end

local Remotes = Dehasher()

if not LocalPlayer.Character then
    Remotes['TeamAPI/ChooseTeam']:InvokeServer("Parents", {dont_enter_location = true, source_for_logging = "intro_sequence"})
    UIManager.set_app_visibility('MainMenuApp', false) 
    UIManager.set_app_visibility('NewsApp', false) 
    LocalPlayer.CharacterAdded:Wait()
    task.wait(5)
    if UIManager.is_visible("DailyLoginApp") then
        Remotes['DailyLoginAPI/ClaimDailyReward']:InvokeServer()
        UIManager.set_app_visibility("DailyLoginApp", false)
    end
end

task.spawn(function() -- cr to hassan :D
    task.wait(5)
    loadstring(game:HttpGet("https://raw.githubusercontent.com/hassanxzayn-lua/Anti-afk/main/antiafkbyhassanxzyn"))();
end)

task.spawn(function()
    while task.wait(5) do
        if UIManager.is_visible("PlaytimePayoutsApp") then
            Remotes['PayAPI/Collect']:FireServer()
            Remotes['PayAPI/DisablePopups']:FireServer()
            UIManager.set_app_visibility("PlaytimePayoutsApp", false)
            print("Paycheck Collected")
        end
    end
end)

task.spawn(function()
    while task.wait(5) do
        if UIManager.is_visible("DialogApp") then
            UIManager.set_app_visibility("DialogApp", false)
        end
        if PlayerGui.DialogApp.Enabled then
            PlayerGui.DialogApp.Enabled = false
        end
    end
end)

task.spawn(function()
    task.wait(10)
    for _, v in pairs(PlayerGui:GetChildren()) do
        if v:IsA("ScreenGui") then
            if UIManager.is_visible(v.name) then
                UIManager.set_app_visibility(v.name, false)
            end
            if v.Enabled then
                v.Enabled = false
            end
        end
    end
end)

-- some gpt shit
task.spawn(function()

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "AdoptMeBucksMonitor"
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.ResetOnSpawn = false
    
    pcall(function() ScreenGui.Parent = game.CoreGui end)
    if ScreenGui.Parent ~= game.CoreGui then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25) 
    MainFrame.BackgroundTransparency = 0.1
    MainFrame.BorderSizePixel = 0
    MainFrame.Position = UDim2.new(0.5, 0, 0.05, 0) 
    MainFrame.AnchorPoint = Vector2.new(0.5, 0)
    MainFrame.Size = UDim2.new(0.3, 0, 0.12, 0) 
    MainFrame.Parent = ScreenGui

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0.2, 0)
    UICorner.Parent = MainFrame

    local UIStroke = Instance.new("UIStroke")
    UIStroke.Color = Color3.fromRGB(255, 255, 255)
    UIStroke.Thickness = 2
    UIStroke.Transparency = 0.8
    UIStroke.Parent = MainFrame

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Name = "Title"
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Position = UDim2.new(0, 0, 0.1, 0)
    TitleLabel.Size = UDim2.new(1, 0, 0.3, 0)
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    TitleLabel.TextScaled = true
    TitleLabel.Parent = MainFrame
    
    if LocalPlayer.Name == targetName then
        TitleLabel.Text = "🛡️ RECEIVER ACCOUNT 🛡️"
        TitleLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    else
        TitleLabel.Text = "💸 SENDER ACCOUNT 💸"
        TitleLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    end

    local BucksLabel = Instance.new("TextLabel")
    BucksLabel.Name = "BucksValue"
    BucksLabel.BackgroundTransparency = 1
    BucksLabel.Position = UDim2.new(0, 0, 0.4, 0)
    BucksLabel.Size = UDim2.new(1, 0, 0.5, 0)
    BucksLabel.Font = Enum.Font.FredokaOne 
    BucksLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    BucksLabel.TextScaled = true
    BucksLabel.Text = "Loading..."
    BucksLabel.Parent = MainFrame

    while task.wait(1) do
        local success, money = pcall(GetBucks)
        if success and money then
            BucksLabel.Text = "$ " .. FormatNumber(money)
        else
            BucksLabel.Text = "Syncing..."
        end
    end
end)


if LocalPlayer.name ~= targetName then
    while true do
        local currentBucks = GetBucks()
        if currentBucks >= 100 then
            local targetPlayer = Players:FindFirstChild(targetName)

            if targetPlayer then
                print("Target found: " .. targetName)
                Remotes['LocationAPI/TeleToPlayer']:InvokeServer(targetPlayer)
                
                local t = tick()
                repeat task.wait(0.5) until (workspace.HouseInteriors:FindFirstChild("furniture")) or (tick()-t > 10)
                    
                task.wait(5)
                print("Scanning for Mannequin...")

                MannequinId, OutfitId = GetMannequin()

                if MannequinId and OutfitId then
                    print("Mannequin found! Executing buy...")
                    for i = 1, 3 do
                        if GetBucks() < 100 then LocalPlayer:Kick("Bucks not enough to send!") end
                        local success, err = pcall(function()
                            local args = {targetPlayer, MannequinId, OutfitId, 100} 
                            Remotes['AvatarAPI/BuyMannequinOutfit']:InvokeServer(unpack(args))
                            print("Buy Success!")
                            task.wait(1)
                            Remotes['AvatarAPI/DeleteOutfit']:FireServer("player", "Outfit")
                        end)
                        if success then
                            task.wait(1)
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
        else
            LocalPlayer:Kick("Bucks not enough to send!")
        end
        print("Waiting 120s...")
        task.wait(115)
    end
else
    while true do
        if InteriorsM:get_current_location().destination_id ~= "housing" then
            Remotes['TeamAPI/Spawn']:InvokeServer()
        end
        task.wait(5)
    end
end
