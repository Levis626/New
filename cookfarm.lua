-- [[ BYTEE HUB V3 - ULTIMATE EDITION - PART 1 / 10 ]] --
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local Config = {
    WindowSize = UDim2.new(0, 520, 0, 340),       
    BgColor = Color3.fromRGB(15, 17, 22),         
    SidebarColor = Color3.fromRGB(11, 12, 16),    
    ContainerColor = Color3.fromRGB(22, 25, 33),  
    ContainerActive = Color3.fromRGB(38, 43, 58), 
    Accent = Color3.fromRGB(255, 255, 255),       
    HighlightText = Color3.fromRGB(95, 145, 255), 
    TextPrimary = Color3.fromRGB(245, 245, 245),  
    TextSecondary = Color3.fromRGB(130, 135, 150),
    WarningYellow = Color3.fromRGB(240, 200, 80),
    CloseRed = Color3.fromRGB(255, 70, 70),       
    Discord = "https://discord.gg/rVFTeNfyxC",
    YouTube = "https://youtube.com/@thesyntezys?si=MxwEA0EzAhKy_mQh",
    YouTubeName = "Bytee Hub YouTube"
}

local CategoryIcons = {
    Dashboard   = "rbxassetid://10723415903",
    Information = "rbxassetid://10709772589",
    Farm        = "rbxassetid://10734952036",
    Combat      = "rbxassetid://10734975692",
    ESP         = "rbxassetid://10723343321",
    Staff       = "rbxassetid://10747373176",
    Settings    = "rbxassetid://10734950309"
}

local HubSettings = {
    GlowAllWhite = false,
    GlowColor = Color3.fromRGB(255, 255, 255),
    BoxEsp = false,
    HealthBar = false,
    TargetLines = false,
    SkeletonEsp = false,
    NameDistanceEsp = false,
    Noclip = false,
    InfiniteJump = false,
    FullBright = false
}

local ActiveDrawings = {}

local function MakeDraggable(obj)
    local dragging, dragStart, startPos
    obj.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = obj.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            obj.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    obj.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end
-- [[ BYTEE HUB V3 - ULTIMATE EDITION - PART 2 / 10 ]] --
local TasksFolder = Workspace:WaitForChild("Tasks", 3)
local PrisonerFolder = TasksFolder and TasksFolder:FindFirstChild("Prisoner")
local RocksFolder = PrisonerFolder and PrisonerFolder:FindFirstChild("Rocks")
local TrashesFolder = PrisonerFolder and PrisonerFolder:FindFirstChild("Trashes")
local JanitorFolder = TasksFolder and TasksFolder:FindFirstChild("Janitor")

local RemotesFolder = ReplicatedStorage:WaitForChild("Remotes", 3)
local ToolFolder = RemotesFolder and RemotesFolder:FindFirstChild("Tool")
local ToolEvent = ToolFolder and ToolFolder:FindFirstChild("Event")
local MineRemote = ToolEvent

local FarmLocations = {
    JanitorArea = Vector3.new(91.27, 13.8, -693.9)
}

local JanitorState = {
    AutoFarm = false,
    CleanDelay = 0.4,
    TpWait = 0.25,
    HitsPerPuddle = 3,
    PuddlesDone = 0,
    LastPuddle = "-"
}

local function equipMop()
    local char = LocalPlayer.Character
    if not char then return nil end
    local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not backpack or not humanoid then return nil end

    local mop = backpack:FindFirstChild("Mop")
    if mop then
        humanoid:EquipTool(mop)
        task.wait(0.25)
    end
    return char:FindFirstChild("Mop")
end

if not _G.ByteeHubJanitorLoop then
    _G.ByteeHubJanitorLoop = true
    task.spawn(function()
        while true do
            if JanitorState.AutoFarm and JanitorFolder and ToolEvent then
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if char and hrp then
                    local mop = char:FindFirstChild("Mop") or equipMop()
                    if mop then
                        local puddles = {}
                        for _, puddle in ipairs(JanitorFolder:GetChildren()) do
                            if puddle:IsA("BasePart") then
                                table.insert(puddles, puddle)
                            end
                        end
                        table.sort(puddles, function(a, b)
                            return (a.Position - hrp.Position).Magnitude < (b.Position - hrp.Position).Magnitude
                        end)
                        for _, puddle in ipairs(puddles) do
                            if not JanitorState.AutoFarm then break end
                            if puddle.Parent == JanitorFolder then
                                hrp.CFrame = CFrame.new(puddle.Position + Vector3.new(0, 3.5, 0))
                                task.wait(JanitorState.TpWait)
                                JanitorState.LastPuddle = puddle.Name
                                for _ = 1, JanitorState.HitsPerPuddle do
                                    if not JanitorState.AutoFarm then break end
                                    pcall(function() ToolEvent:FireServer("Mop", mop, puddle) end)
                                    task.wait(JanitorState.CleanDelay)
                                end
                                if puddle.Parent ~= JanitorFolder then
                                    JanitorState.PuddlesDone += 1
                                end
                            end
                        end
                    end
                end
            end
            task.wait(0.4)
        end
    end)
end
-- [[ BYTEE HUB V3 - ULTIMATE EDITION - PART 3 / 10 ]] --
local AutoMine = {
    IsActive = false,
    NoclipConnection = nil,
    LockConnection = nil,
    OriginalCollisions = {},
    RunningThread = nil
}

local function clearFarmTable(t)
    for key in pairs(t) do t[key] = nil end
end

function AutoMine.FindClosestRock()
    if not RocksFolder then return nil end
    local char = LocalPlayer.Character
    local rootPart = char and char:FindFirstChild("HumanoidRootPart")
    if not rootPart then return nil end

    local closest
    local minDistance = math.huge
    for _, rock in ipairs(RocksFolder:GetChildren()) do
        if rock:IsA("BasePart") then
            local health = rock:GetAttribute("Health")
            local destroyed = rock:GetAttribute("Destroyed")
            if health and health > 0 and not destroyed then
                local distance = (rock.Position - rootPart.Position).Magnitude
                if distance < minDistance then
                    minDistance = distance
                    closest = rock
                end
            end
        end
    end
    return closest
end

function AutoMine.IsRockDead(rock)
    if not rock or not rock.Parent then return true end
    local health = rock:GetAttribute("Health")
    local destroyed = rock:GetAttribute("Destroyed")
    return (health and health <= 0) or destroyed == true
end

function AutoMine.Start()
    if AutoMine.IsActive or not RocksFolder or not ToolEvent then return end
    AutoMine.IsActive = true
    clearFarmTable(AutoMine.OriginalCollisions)

    AutoMine.NoclipConnection = RunService.Stepped:Connect(function()
        if not AutoMine.IsActive then return end
        local char = LocalPlayer.Character
        if not char then return end
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                if AutoMine.OriginalCollisions[part] == nil then
                    AutoMine.OriginalCollisions[part] = part.CanCollide
                end
                part.CanCollide = false
            end
        end
    end)

    AutoMine.RunningThread = task.spawn(function()
        while AutoMine.IsActive do
            local char = LocalPlayer.Character
            local humanoid = char and char:FindFirstChildOfClass("Humanoid")
            local rootPart = char and char:FindFirstChild("HumanoidRootPart")
            local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")

            if not humanoid or not rootPart or not backpack then
                task.wait(0.5)
                continue
            end

            local targetRock = AutoMine.FindClosestRock()
            if targetRock then
                AutoMine.LockConnection = RunService.Heartbeat:Connect(function()
                    if targetRock and targetRock.Parent and rootPart and rootPart.Parent then
                        rootPart.CFrame = targetRock.CFrame * CFrame.new(0, 3, 0)
                        rootPart.AssemblyLinearVelocity = Vector3.zero
                    end
                end)

                while AutoMine.IsActive and not AutoMine.IsRockDead(targetRock) do
                    pcall(function()
                        local tool = char:FindFirstChild("Pickaxe") or backpack:FindFirstChild("Pickaxe") or char:FindFirstChild("PremiumPickaxe") or backpack:FindFirstChild("PremiumPickaxe")
                        if tool then
                            if tool.Parent == backpack then tool.Parent = char end
                            ToolEvent:FireServer("MineOres", tool, targetRock)
                        end
                    end)
                    task.wait(0.05)
                end

                if AutoMine.LockConnection then
                    AutoMine.LockConnection:Disconnect()
                    AutoMine.LockConnection = nil
                end
            else
                task.wait(0.5)
            end
            task.wait(0.05)
        end
    end)
end

function AutoMine.Stop()
    AutoMine.IsActive = false
    AutoMine.RunningThread = nil
    if AutoMine.LockConnection then AutoMine.LockConnection:Disconnect() AutoMine.LockConnection = nil end
    if AutoMine.NoclipConnection then AutoMine.NoclipConnection:Disconnect() AutoMine.NoclipConnection = nil end
    pcall(function()
        local char = LocalPlayer.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") and AutoMine.OriginalCollisions[part] ~= nil then
                    part.CanCollide = AutoMine.OriginalCollisions[part]
                end
            end
        end
        clearFarmTable(AutoMine.OriginalCollisions)
    end)
end
-- [[ BYTEE HUB V3 - ULTIMATE EDITION - PART 4 / 10 ]] --
local AutoTrash = { IsActive = false, RunningThread = nil }

function AutoTrash.Start()
    if AutoTrash.IsActive then return end
    AutoTrash.IsActive = true
    AutoTrash.RunningThread = task.spawn(function()
        while AutoTrash.IsActive do
            local char = LocalPlayer.Character
            local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")

            if char and backpack then
                pcall(function()
                    local trashTool = char:FindFirstChild("SmallTrash") or backpack:FindFirstChild("SmallTrash") or char:FindFirstChild("BigTrash") or backpack:FindFirstChild("BigTrash")
                    local rootPart = char:FindFirstChild("HumanoidRootPart")
                    local humanoid = char:FindFirstChildOfClass("Humanoid")

                    if trashTool and rootPart and humanoid then
                        local dumpster = Workspace.Map.Cells.Basement["Recyclement Room"].Props["Opened Trash"].Trash
                        rootPart.CFrame = dumpster.CFrame * CFrame.new(0, 2, 0)
                        if not AutoTrash.IsActive then return end
                        task.wait(0.3)
                        if trashTool.Parent == backpack then humanoid:EquipTool(trashTool) end
                        dumpster.Prompt.Interact.Event:FireServer()
                        task.wait(0.3)
                    else
                        local activeBin
                        if TrashesFolder then
                            for _, bin in ipairs(TrashesFolder:GetChildren()) do
                                local prompt = bin:FindFirstChild("Prompt")
                                if prompt and prompt:GetAttribute("Enabled") == true then
                                    activeBin = bin
                                    break
                                end
                            end
                        end

                        if activeBin and activeBin.Prompt and rootPart then
                            rootPart.CFrame = activeBin.Prompt.Parent.CFrame * CFrame.new(0, 2, 0)
                            if not AutoTrash.IsActive then return end
                            task.wait(0.3)
                            activeBin.Prompt.Interact.Event:FireServer()
                            task.wait(0.5)
                        else
                            task.wait(1)
                        end
                    end
                end)
            end
            if not AutoTrash.IsActive then break end
            task.wait(0.1)
        end
    end)
end

function AutoTrash.Stop()
    AutoTrash.IsActive = false
    AutoTrash.RunningThread = nil
end

local function cleanNearestPuddle()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local mop = (char and char:FindFirstChild("Mop")) or equipMop()
    if not hrp or not mop or not JanitorFolder then return end

    local nearest, nearestDistance = nil, math.huge
    for _, puddle in ipairs(JanitorFolder:GetChildren()) do
        if puddle:IsA("BasePart") then
            local distance = (puddle.Position - hrp.Position).Magnitude
            if distance < nearestDistance then
                nearestDistance = distance
                nearest = puddle
            end
        end
    end

    if not nearest then return end
    hrp.CFrame = CFrame.new(nearest.Position + Vector3.new(0, 3.5, 0))
    task.wait(0.3)
    for _ = 1, JanitorState.HitsPerPuddle do
        if not nearest.Parent then break end
        pcall(function() ToolEvent:FireServer("Mop", mop, nearest) end)
        task.wait(JanitorState.CleanDelay)
    end
end

local function teleportToJanitor()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then hrp.CFrame = CFrame.new(FarmLocations.JanitorArea) end
end

local function cycleAllPuddles()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp or not JanitorFolder then return end
    task.spawn(function()
        for _, puddle in ipairs(JanitorFolder:GetChildren()) do
            if puddle:IsA("BasePart") then
                hrp.CFrame = CFrame.new(puddle.Position + Vector3.new(0, 3.5, 0))
                task.wait(0.5)
            end
        end
    end)
end

local function unlockFists()
    pcall(function()
        ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Quests"):WaitForChild("Pushups"):WaitForChild("Function"):InvokeServer("Submit", 300)
    end)
end
-- [[ BYTEE HUB V3 - ULTIMATE EDITION - PART 5 / 10 ]] --
local function ExecuteScript()
    if CoreGui:FindFirstChild("ByteeHub") then
        CoreGui:FindFirstChild("ByteeHub"):Destroy()
    end

    local MainGui = Instance.new("ScreenGui")
    MainGui.Name = "ByteeHub"
    MainGui.Parent = CoreGui

    -- Intro Screen
    local IntroGui = Instance.new("Frame", MainGui)
    IntroGui.Size = UDim2.new(1, 0, 1, 0)
    IntroGui.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
    IntroGui.ZIndex = 999

    local IntroText = Instance.new("TextLabel", IntroGui)
    IntroText.Size = UDim2.new(0, 400, 0, 100)
    IntroText.Position = UDim2.new(0.5, 0, 0.5, 0)
    IntroText.AnchorPoint = Vector2.new(0.5, 0.5)
    IntroText.BackgroundTransparency = 1
    IntroText.Text = "Bytee Hub V3"
    IntroText.TextColor3 = Color3.fromRGB(255, 255, 255)
    IntroText.Font = Enum.Font.GothamBold
    IntroText.TextSize = 36
    IntroText.TextTransparency = 1
    IntroText.ZIndex = 1000

    TweenService:Create(IntroText, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()

    task.delay(2.5, function()
        if IntroGui and IntroGui.Parent then
            TweenService:Create(IntroText, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {TextTransparency = 1}):Play()
            TweenService:Create(IntroGui, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {BackgroundTransparency = 1}):Play()
            task.wait(0.6)
            IntroGui:Destroy()

            -- Bildirim Kartı
            local NotifFrame = Instance.new("Frame", MainGui)
            NotifFrame.Size = UDim2.new(0, 360, 0, 85)
            NotifFrame.Position = UDim2.new(1, 380, 1, -95)
            NotifFrame.BackgroundColor3 = Config.BgColor
            NotifFrame.BackgroundTransparency = 0.1
            Instance.new("UICorner", NotifFrame).CornerRadius = UDim.new(0, 8)

            local NotifStroke = Instance.new("UIStroke", NotifFrame)
            NotifStroke.Color = Config.WarningYellow
            NotifStroke.Transparency = 0.2
            NotifStroke.Thickness = 1.5

            local NotifTitle = Instance.new("TextLabel", NotifFrame)
            NotifTitle.Size = UDim2.new(1, -25, 0, 20)
            NotifTitle.Position = UDim2.new(0, 20, 0, 8)
            NotifTitle.BackgroundTransparency = 1
            NotifTitle.Text = "Bytee Hub Security Notice"
            NotifTitle.TextColor3 = Config.WarningYellow
            NotifTitle.Font = Enum.Font.GothamBold
            NotifTitle.TextSize = 11
            NotifTitle.TextXAlignment = Enum.TextXAlignment.Left

            local NotifDesc = Instance.new("TextLabel", NotifFrame)
            NotifDesc.Size = UDim2.new(1, -25, 0, 45)
            NotifDesc.Position = UDim2.new(0, 20, 0, 28)
            NotifDesc.BackgroundTransparency = 1
            NotifDesc.Text = LocalPlayer.DisplayName .. ", hello, everything you do in this script is your responsibility. Have a good game!"
            NotifDesc.TextColor3 = Config.TextSecondary
            NotifDesc.Font = Enum.Font.Gotham
            NotifDesc.TextSize = 9.5
            NotifDesc.TextWrapped = true
            NotifDesc.TextXAlignment = Enum.TextXAlignment.Left

            TweenService:Create(NotifFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Position = UDim2.new(1, -375, 1, -95) }):Play()
            task.delay(5, function()
                if NotifFrame and NotifFrame.Parent then
                    local outTween = TweenService:Create(NotifFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.In), { Position = UDim2.new(1, 380, 1, -95) })
                    outTween:Play()
                    outTween.Completed:Connect(function() NotifFrame:Destroy() end)
                end
            end)
        end
    end)

    local TopPill = Instance.new("TextButton", MainGui)
    TopPill.Name = "TopPill"
    TopPill.Size = UDim2.new(0, 150, 0, 32)
    TopPill.Position = UDim2.new(0.5, 0, 0, 10)
    TopPill.AnchorPoint = Vector2.new(0.5, 0)
    TopPill.BackgroundColor3 = Config.BgColor
    TopPill.BackgroundTransparency = 0.15
    TopPill.Text = "[ Bytee Hub ]"
    TopPill.TextColor3 = Config.TextPrimary
    TopPill.Font = Enum.Font.GothamBold
    TopPill.TextSize = 13
    TopPill.Visible = false
    Instance.new("UICorner", TopPill).CornerRadius = UDim.new(0, 8)

    local MainFrame = Instance.new("Frame", MainGui)
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 0, 0, 0)
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.BackgroundColor3 = Config.BgColor
    MainFrame.BackgroundTransparency = 0.12
    MainFrame.ClipsDescendants = true
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)
    -- [[ BYTEE HUB V3 - ULTIMATE EDITION - PART 6 / 10 ]] --
    local TopBar = Instance.new("Frame", MainFrame)
    TopBar.Size = UDim2.new(1, 0, 0, 38)
    TopBar.BackgroundTransparency = 1

    local Title = Instance.new("TextLabel", TopBar)
    Title.Text = "Bytee Hub V3"
    Title.Size = UDim2.new(0, 200, 1, 0)
    Title.Position = UDim2.new(0, 15, 0, 0)
    Title.BackgroundTransparency = 1
    Title.TextColor3 = Config.TextPrimary
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 14
    Title.TextXAlignment = Enum.TextXAlignment.Left

    local CloseBtn = Instance.new("TextButton", TopBar)
    CloseBtn.Size = UDim2.new(0, 30, 0, 30)
    CloseBtn.Position = UDim2.new(1, -35, 0, 4)
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.Text = "×"
    CloseBtn.TextColor3 = Config.CloseRed
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextSize = 22

    local MinimizeBtn = Instance.new("TextButton", TopBar)
    MinimizeBtn.Size = UDim2.new(0, 30, 0, 30)
    MinimizeBtn.Position = UDim2.new(1, -65, 0, 4)
    MinimizeBtn.BackgroundTransparency = 1
    MinimizeBtn.Text = "-"
    MinimizeBtn.TextColor3 = Config.TextSecondary
    MinimizeBtn.Font = Enum.Font.GothamBold
    MinimizeBtn.TextSize = 20

    local Sidebar = Instance.new("Frame", MainFrame)
    Sidebar.Size = UDim2.new(0, 140, 1, -48)
    Sidebar.Position = UDim2.new(0, 10, 0, 38)
    Sidebar.BackgroundColor3 = Config.SidebarColor
    Sidebar.BackgroundTransparency = 0.25
    Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 8)

    local TabContainer = Instance.new("ScrollingFrame", Sidebar)
    TabContainer.Size = UDim2.new(1, -6, 1, -52)
    TabContainer.Position = UDim2.new(0, 3, 0, 5)
    TabContainer.BackgroundTransparency = 1
    TabContainer.ScrollBarThickness = 0
    TabContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y

    local TabList = Instance.new("UIListLayout", TabContainer)
    TabList.SortOrder = Enum.SortOrder.LayoutOrder
    TabList.Padding = UDim.new(0, 4)

    local PagesContainer = Instance.new("Frame", MainFrame)
    PagesContainer.Size = UDim2.new(1, -170, 1, -48)
    PagesContainer.Position = UDim2.new(0, 160, 0, 38)
    PagesContainer.BackgroundTransparency = 1

    local ProfileFrame = Instance.new("Frame", Sidebar)
    ProfileFrame.Size = UDim2.new(1, -10, 0, 40)
    ProfileFrame.Position = UDim2.new(0, 5, 1, -45)
    ProfileFrame.BackgroundColor3 = Config.ContainerColor
    ProfileFrame.BackgroundTransparency = 0.2
    Instance.new("UICorner", ProfileFrame).CornerRadius = UDim.new(0, 6)

    local ProfileImage = Instance.new("ImageLabel", ProfileFrame)
    ProfileImage.Size = UDim2.new(0, 26, 0, 26)
    ProfileImage.Position = UDim2.new(0, 5, 0.5, -13)
    ProfileImage.BackgroundColor3 = Config.SidebarColor
    ProfileImage.Image = "rbxthumb://type=AvatarHeadShot&id=" .. LocalPlayer.UserId .. "&w=150&h=150"
    Instance.new("UICorner", ProfileImage).CornerRadius = UDim.new(1, 0)

    local ProfileName = Instance.new("TextLabel", ProfileFrame)
    ProfileName.Size = UDim2.new(1, -38, 0, 14)
    ProfileName.Position = UDim2.new(0, 36, 0, 4)
    ProfileName.BackgroundTransparency = 1
    ProfileName.Text = LocalPlayer.DisplayName
    ProfileName.TextColor3 = Config.TextPrimary
    ProfileName.Font = Enum.Font.GothamBold
    ProfileName.TextSize = 10
    ProfileName.TextXAlignment = Enum.TextXAlignment.Left

    local SessionTime = Instance.new("TextLabel", ProfileFrame)
    SessionTime.Size = UDim2.new(1, -38, 0, 12)
    SessionTime.Position = UDim2.new(0, 36, 0, 18)
    SessionTime.BackgroundTransparency = 1
    SessionTime.Text = "Session: 0s"
    SessionTime.TextColor3 = Config.TextSecondary
    SessionTime.Font = Enum.Font.Gotham
    SessionTime.TextSize = 9
    SessionTime.TextXAlignment = Enum.TextXAlignment.Left

    local startTime = os.time()
    task.spawn(function()
        while MainGui.Parent and task.wait(1) do
            SessionTime.Text = "Session: " .. (os.time() - startTime) .. "s"
        end
    end)

    MainFrame.Size = UDim2.new(0, 100, 0, 60)
    TweenService:Create(MainFrame, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Size = Config.WindowSize }):Play()

    local function OpenMainUI()
        MainFrame.Visible = true
        TopPill.Visible = false
        MainFrame.Size = UDim2.new(0, 100, 0, 60)
        TweenService:Create(MainFrame, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Size = Config.WindowSize }):Play()
    end

    local function CloseUI()
        local anim = TweenService:Create(MainFrame, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.In), { Size = UDim2.new(0, 0, 0, 0) })
        anim:Play()
        anim.Completed:Connect(function()
            MainFrame.Visible = false
            TopPill.Visible = true
        end)
    end

    TopPill.MouseButton1Click:Connect(OpenMainUI)
    MinimizeBtn.MouseButton1Click:Connect(CloseUI)

    CloseBtn.MouseButton1Click:Connect(function()
        local anim = TweenService:Create(MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.In), { Size = UDim2.new(0, 0, 0, 0) })
        anim:Play()
        anim.Completed:Connect(function()
            for _, data in pairs(ActiveDrawings) do
                if data.Box then data.Box:Remove() end
                if data.Bones then for _, line in pairs(data.Bones) do line:Remove() end end
            end
            MainGui:Destroy()
        end)
    end)
    -- [[ BYTEE HUB V3 - ULTIMATE EDITION - PART 7 / 10 ]] --
    local Tabs, Pages = {}, {}

    local function CreateTab(name, layoutOrder)
        local TabBtn = Instance.new("TextButton", TabContainer)
        TabBtn.Size = UDim2.new(1, 0, 0, 28)
        TabBtn.BackgroundColor3 = (layoutOrder == 1) and Config.ContainerActive or Config.ContainerColor
        TabBtn.BackgroundTransparency = 0.2
        TabBtn.Text = "      " .. name
        TabBtn.TextColor3 = Config.TextPrimary
        TabBtn.Font = Enum.Font.GothamMedium
        TabBtn.TextSize = 11
        TabBtn.TextXAlignment = Enum.TextXAlignment.Left
        TabBtn.LayoutOrder = layoutOrder
        Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 6)

        if CategoryIcons[name] then
            local IconImg = Instance.new("ImageLabel", TabBtn)
            IconImg.Size = UDim2.new(0, 16, 0, 16)
            IconImg.Position = UDim2.new(0, 8, 0.5, -8)
            IconImg.BackgroundTransparency = 1
            IconImg.Image = CategoryIcons[name]
            IconImg.ImageColor3 = Config.TextPrimary
        end

        local Page = Instance.new("ScrollingFrame", PagesContainer)
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency = 1
        Page.ScrollBarThickness = 2
        Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
        Page.Visible = (layoutOrder == 1)

        local PageLayout = Instance.new("UIListLayout", Page)
        PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
        PageLayout.Padding = UDim.new(0, 6)

        Tabs[name] = TabBtn
        Pages[name] = Page

        TabBtn.MouseButton1Click:Connect(function()
            for _, btn in pairs(Tabs) do
                TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Config.ContainerColor}):Play()
            end
            for _, p in pairs(Pages) do p.Visible = false end
            TweenService:Create(TabBtn, TweenInfo.new(0.2), {BackgroundColor3 = Config.ContainerActive}):Play()
            Page.Visible = true
        end)

        return Page
    end

    local function CreateButton(parent, text, callback)
        local Btn = Instance.new("TextButton", parent)
        Btn.Size = UDim2.new(1, -10, 0, 32)
        Btn.BackgroundColor3 = Config.ContainerColor
        Btn.BackgroundTransparency = 0.2
        Btn.Text = text
        Btn.TextColor3 = Config.TextPrimary
        Btn.Font = Enum.Font.GothamBold
        Btn.TextSize = 11
        Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
        Btn.MouseButton1Click:Connect(function() if callback then callback() end end)
        return Btn
    end

    local function CreateToggle(parent, text, defaultState, callback)
        local ToggleFrame = Instance.new("Frame", parent)
        ToggleFrame.Size = UDim2.new(1, -10, 0, 32)
        ToggleFrame.BackgroundColor3 = Config.ContainerColor
        ToggleFrame.BackgroundTransparency = 0.2
        Instance.new("UICorner", ToggleFrame).CornerRadius = UDim.new(0, 6)

        local Label = Instance.new("TextLabel", ToggleFrame)
        Label.Size = UDim2.new(0.7, 0, 1, 0)
        Label.Position = UDim2.new(0, 10, 0, 0)
        Label.BackgroundTransparency = 1
        Label.Text = text
        Label.TextColor3 = Config.TextPrimary
        Label.Font = Enum.Font.GothamMedium
        Label.TextSize = 11
        Label.TextXAlignment = Enum.TextXAlignment.Left

        local Indicator = Instance.new("TextButton", ToggleFrame)
        Indicator.Size = UDim2.new(0, 36, 0, 18)
        Indicator.Position = UDim2.new(1, -44, 0.5, -9)
        Indicator.BackgroundColor3 = defaultState and Color3.fromRGB(60, 180, 100) or Color3.fromRGB(35, 40, 52)
        Indicator.Text = defaultState and "ON" or "OFF"
        Indicator.TextColor3 = defaultState and Config.Accent or Config.TextSecondary
        Indicator.Font = Enum.Font.GothamBold
        Indicator.TextSize = 9
        Instance.new("UICorner", Indicator).CornerRadius = UDim.new(0, 9)

        local state = defaultState
        Indicator.MouseButton1Click:Connect(function()
            state = not state
            Indicator.BackgroundColor3 = state and Color3.fromRGB(60, 180, 100) or Color3.fromRGB(35, 40, 52)
            Indicator.Text = state and "ON" or "OFF"
            Indicator.TextColor3 = state and Config.Accent or Config.TextSecondary
            if callback then callback(state) end
        end)
        return ToggleFrame
    end

    local DashboardPage = CreateTab("Dashboard", 1)
    local InfoPage      = CreateTab("Information", 2)
    local FarmPage      = CreateTab("Farm", 3)
    local CombatPage    = CreateTab("Combat", 4)
    local EspPage       = CreateTab("ESP", 5)
    local StaffPage     = CreateTab("Staff", 6)
    local SettingsPage  = CreateTab("Settings", 7)
    -- [[ BYTEE HUB V3 - ULTIMATE EDITION - PART 8 / 10 ]] --
    -- FARM TAB UI --
    local FarmTitle = Instance.new("TextLabel", FarmPage)
    FarmTitle.Size = UDim2.new(1, -10, 0, 20)
    FarmTitle.BackgroundTransparency = 1
    FarmTitle.Text = "Farming"
    FarmTitle.TextColor3 = Config.HighlightText
    FarmTitle.Font = Enum.Font.GothamBold
    FarmTitle.TextSize = 12
    FarmTitle.TextXAlignment = Enum.TextXAlignment.Left

    CreateToggle(FarmPage, "Auto Mine", false, function(state)
        if state then AutoMine.Start() else AutoMine.Stop() end
    end)

    CreateToggle(FarmPage, "Auto Trash (EXP)", false, function(state)
        if state then AutoTrash.Start() else AutoTrash.Stop() end
    end)

    CreateButton(FarmPage, "Unlock Fists", unlockFists)

    local JanitorTitle = Instance.new("TextLabel", FarmPage)
    JanitorTitle.Size = UDim2.new(1, -10, 0, 20)
    JanitorTitle.BackgroundTransparency = 1
    JanitorTitle.Text = "Janitor Farm"
    JanitorTitle.TextColor3 = Config.HighlightText
    JanitorTitle.Font = Enum.Font.GothamBold
    JanitorTitle.TextSize = 12
    JanitorTitle.TextXAlignment = Enum.TextXAlignment.Left

    CreateToggle(FarmPage, "Janitor Auto Farm", false, function(state) JanitorState.AutoFarm = state end)
    CreateButton(FarmPage, "Equip Mop", function() equipMop() end)
    CreateButton(FarmPage, "Clean Nearest Puddle", function() task.spawn(cleanNearestPuddle) end)
    CreateButton(FarmPage, "Teleport to Janitor Area", teleportToJanitor)
    CreateButton(FarmPage, "Cycle Through All Puddles", cycleAllPuddles)

    -- DASHBOARD TAB UI --
    local function CreateCard(parent, titleText, initialVal)
        local Card = Instance.new("Frame", parent)
        Card.Size = UDim2.new(1, -10, 0, 34)
        Card.BackgroundColor3 = Config.ContainerColor
        Card.BackgroundTransparency = 0.2
        Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 6)

        local TitleLbl = Instance.new("TextLabel", Card)
        TitleLbl.Size = UDim2.new(0.6, 0, 1, 0)
        TitleLbl.Position = UDim2.new(0, 10, 0, 0)
        TitleLbl.BackgroundTransparency = 1
        TitleLbl.Text = titleText
        TitleLbl.TextColor3 = Config.TextSecondary
        TitleLbl.Font = Enum.Font.GothamMedium
        TitleLbl.TextSize = 11
        TitleLbl.TextXAlignment = Enum.TextXAlignment.Left

        local ValLbl = Instance.new("TextLabel", Card)
        ValLbl.Size = UDim2.new(0.4, -10, 1, 0)
        ValLbl.Position = UDim2.new(0.6, 0, 0, 0)
        ValLbl.BackgroundTransparency = 1
        ValLbl.Text = initialVal
        ValLbl.TextColor3 = Config.HighlightText
        ValLbl.Font = Enum.Font.GothamBold
        ValLbl.TextSize = 11
        ValLbl.TextXAlignment = Enum.TextXAlignment.Right
        return ValLbl
    end

    local FpsLabel    = CreateCard(DashboardPage, "FPS Rate", "calculating...")
    local PingLabel   = CreateCard(DashboardPage, "MS (Ping)", "calculating...")
    local PlayerLabel = CreateCard(DashboardPage, "Server Players", "0 / 0")
    local FriendLabel = CreateCard(DashboardPage, "Active Friends", "0")

    local ResetBtn = Instance.new("TextButton", DashboardPage)
    ResetBtn.Size = UDim2.new(1, -10, 0, 34)
    ResetBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
    ResetBtn.BackgroundTransparency = 0.2
    ResetBtn.Text = "RESET SCRIPT"
    ResetBtn.TextColor3 = Config.Accent
    ResetBtn.Font = Enum.Font.GothamBold
    ResetBtn.TextSize = 11
    Instance.new("UICorner", ResetBtn).CornerRadius = UDim.new(0, 6)
    ResetBtn.MouseButton1Click:Connect(function() ExecuteScript() end)

    local frameCount, lastTime = 0, os.clock()
    RunService.RenderStepped:Connect(function()
        if not MainGui.Parent then return end
        frameCount += 1
        local currentTime = os.clock()
        if currentTime - lastTime >= 1 then
            FpsLabel.Text = tostring(frameCount) .. " FPS"
            frameCount = 0
            lastTime = currentTime
        end
    end)

    task.spawn(function()
        while MainGui.Parent and task.wait(1.5) do
            local ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
            PingLabel.Text = tostring(ping) .. " ms"
            PlayerLabel.Text = #Players:GetPlayers() .. " / " .. Players.MaxPlayers
            local friendsInServer = 0
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and LocalPlayer:IsFriendsWith(p.UserId) then friendsInServer += 1 end
            end
            FriendLabel.Text = tostring(friendsInServer)
        end
    end)
    -- [[ BYTEE HUB V3 - ULTIMATE EDITION - PART 9 / 10 ]] --
    -- ESP TAB UI --
    CreateToggle(EspPage, "Glow ESP (All White)", false, function(state) HubSettings.GlowAllWhite = state end)
    CreateToggle(EspPage, "2D Box ESP", false, function(state) HubSettings.BoxEsp = state end)
    CreateToggle(EspPage, "Health Bar ESP", false, function(state) HubSettings.HealthBar = state end)
    CreateToggle(EspPage, "Target ESP (Top Lines)", false, function(state) HubSettings.TargetLines = state end)
    CreateToggle(EspPage, "Skeleton ESP", false, function(state) HubSettings.SkeletonEsp = state end)
    CreateToggle(EspPage, "Name & Distance ESP", false, function(state) HubSettings.NameDistanceEsp = state end)

    -- COMBAT TAB UI --
    CreateButton(CombatPage, "AIMBOT SCRIPT [MOBILE]", function()
        loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-Aimbot-Mobile-34677"))()
    end)

    -- INFORMATION TAB UI --
    local YTBtn = CreateButton(InfoPage, Config.YouTubeName, function()
        if setclipboard then setclipboard(Config.YouTube) end
    end)
    local DCBtn = CreateButton(InfoPage, "Discord Server", function()
        if setclipboard then setclipboard(Config.Discord) end
    end)

    -- STAFF TAB UI --
    local StaffNoticeBox = Instance.new("Frame", StaffPage)
    StaffNoticeBox.Size = UDim2.new(1, -10, 0, 80)
    StaffNoticeBox.BackgroundColor3 = Config.ContainerColor
    StaffNoticeBox.BackgroundTransparency = 0.2
    Instance.new("UICorner", StaffNoticeBox).CornerRadius = UDim.new(0, 6)

    local StaffText = Instance.new("TextLabel", StaffNoticeBox)
    StaffText.Size = UDim2.new(1, -20, 1, 0)
    StaffText.Position = UDim2.new(0, 10, 0, 0)
    StaffText.BackgroundTransparency = 1
    StaffText.Text = "Yetkili Dedektörü Aktif!\nSunucudaki yetkililer ve şüpheli roller anlık olarak izlenmektedir."
    StaffText.TextColor3 = Config.TextPrimary
    StaffText.Font = Enum.Font.GothamMedium
    StaffText.TextSize = 11
    StaffText.TextWrapped = true

    -- SETTINGS TAB UI --
    CreateToggle(SettingsPage, "Noclip (Walk Through Walls)", false, function(state) HubSettings.Noclip = state end)
    CreateToggle(SettingsPage, "Infinite Jump", false, function(state) HubSettings.InfiniteJump = state end)
    CreateToggle(SettingsPage, "FullBright (Remove Darkness)", false, function(state) HubSettings.FullBright = state end)
    -- [[ BYTEE HUB V3 - ULTIMATE EDITION - PART 10 / 10 ]] --
    -- RENDER LOOP FOR ESP & UTILITIES --
    RunService.RenderStepped:Connect(function()
        if not MainGui.Parent then return end

        if HubSettings.Noclip and LocalPlayer.Character then
            for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end

        if HubSettings.FullBright then
            game:GetService("Lighting").Brightness = 2
            game:GetService("Lighting").ClockTime = 14
            game:GetService("Lighting").GlobalShadows = false
        end

        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local char = p.Character
                local root = char.HumanoidRootPart
                local humanoid = char:FindFirstChildOfClass("Humanoid")

                -- Glow ESP
                local glow = char:FindFirstChild("ByteeHubGlow")
                if HubSettings.GlowAllWhite then
                    if not glow then
                        glow = Instance.new("Highlight")
                        glow.Name = "ByteeHubGlow"
                        glow.Parent = char
                    end
                    glow.FillColor = HubSettings.GlowColor
                    glow.FillTransparency = 0.4
                    glow.OutlineColor = Color3.fromRGB(255, 255, 255)
                    glow.OutlineTransparency = 0
                else
                    if glow then glow:Destroy() end
                end

                -- Health Bar ESP
                local uiHolder = char:FindFirstChild("ByteeHubHealthUI")
                if HubSettings.HealthBar and humanoid then
                    if not uiHolder then
                        uiHolder = Instance.new("BillboardGui")
                        uiHolder.Name = "ByteeHubHealthUI"
                        uiHolder.Size = UDim2.new(0, 100, 0, 40)
                        uiHolder.StudsOffset = Vector3.new(0, 3.2, 0)
                        uiHolder.AlwaysOnTop = true
                        uiHolder.Parent = char

                        local bgBar = Instance.new("Frame", uiHolder)
                        bgBar.Size = UDim2.new(0, 60, 0, 6)
                        bgBar.Position = UDim2.new(0.5, -30, 0, 0)
                        bgBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                        Instance.new("UICorner", bgBar).CornerRadius = UDim.new(1, 0)

                        local fgBar = Instance.new("Frame", bgBar)
                        fgBar.Name = "HealthFg"
                        fgBar.Size = UDim2.new(1, 0, 1, 0)
                        fgBar.BackgroundColor3 = Color3.fromRGB(60, 220, 80)
                        Instance.new("UICorner", fgBar).CornerRadius = UDim.new(1, 0)
                    end
                else
                    if uiHolder then uiHolder:Destroy() end
                end

                -- Target Line ESP
                local linePart = char:FindFirstChild("ByteeHubTargetLine")
                if HubSettings.TargetLines then
                    if not linePart then
                        linePart = Instance.new("Part")
                        linePart.Name = "ByteeHubTargetLine"
                        linePart.Size = Vector3.new(0.1, 50, 0.1)
                        linePart.Anchored = true
                        linePart.CanCollide = false
                        linePart.Transparency = 0.4
                        linePart.BrickColor = BrickColor.new("Cyan")
                        linePart.Parent = char
                    end
                    linePart.CFrame = CFrame.new(root.Position + Vector3.new(0, 25, 0))
                else
                    if linePart then linePart:Destroy() end
                end
            end
        end
    end)

    UserInputService.JumpRequest:Connect(function()
        if HubSettings.InfiniteJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end)

    MakeDraggable(MainFrame)
    MakeDraggable(TopPill)
end

ExecuteScript()
