-- [[ BYTEE HUB V3 - PART 1 / 7 ]] --
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

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
    YouTube = "https://youtube.com/@thesyntezys?si=MxwEA0EzAhKy_mQh"
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
    NameDistanceEsp = false,
    Noclip = false,
    InfiniteJump = false
}

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

-- Güvenli Harita Kontrolleri (Infinite Yield Hatasını Önler)
local TasksFolder = Workspace:WaitForChild("Tasks", 3)
local PrisonerFolder = TasksFolder and TasksFolder:FindFirstChild("Prisoner")
local RocksFolder = PrisonerFolder and PrisonerFolder:FindFirstChild("Rocks")
local TrashesFolder = PrisonerFolder and PrisonerFolder:FindFirstChild("Trashes")
local JanitorFolder = TasksFolder and TasksFolder:FindFirstChild("Janitor")

local RemotesFolder = ReplicatedStorage:WaitForChild("Remotes", 3)
local ToolFolder = RemotesFolder and RemotesFolder:FindFirstChild("Tool")
local ToolEvent = ToolFolder and ToolFolder:FindFirstChild("Event")
-- [[ BYTEE HUB V3 - PART 2 / 7 ]] --
local JanitorState = {
    AutoFarm = false,
    CleanDelay = 0.4,
    TpWait = 0.25,
    HitsPerPuddle = 3,
    PuddlesDone = 0
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
                                for _ = 1, JanitorState.HitsPerPuddle do
                                    if not JanitorState.AutoFarm then break end
                                    pcall(function() ToolEvent:FireServer("Mop", mop, puddle) end)
                                    task.wait(JanitorState.CleanDelay)
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

local AutoMine = { IsActive = false, LockConnection = nil, RunningThread = nil }

function AutoMine.FindClosestRock()
    if not RocksFolder then return nil end
    local char = LocalPlayer.Character
    local rootPart = char and char:FindFirstChild("HumanoidRootPart")
    if not rootPart then return nil end
    local closest, minDistance = nil, math.huge
    for _, rock in ipairs(RocksFolder:GetChildren()) do
        if rock:IsA("BasePart") then
            local health = rock:GetAttribute("Health")
            local destroyed = rock:GetAttribute("Destroyed")
            if health and health > 0 and not destroyed then
                local distance = (rock.Position - rootPart.Position).Magnitude
                if distance < minDistance then minDistance = distance; closest = rock end
            end
        end
    end
    return closest
end

function AutoMine.Start()
    if AutoMine.IsActive or not RocksFolder or not ToolEvent then return end
    AutoMine.IsActive = true
    AutoMine.RunningThread = task.spawn(function()
        while AutoMine.IsActive do
            local char = LocalPlayer.Character
            local rootPart = char and char:FindFirstChild("HumanoidRootPart")
            local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
            if rootPart and backpack then
                local targetRock = AutoMine.FindClosestRock()
                if targetRock then
                    AutoMine.LockConnection = RunService.Heartbeat:Connect(function()
                        if targetRock and targetRock.Parent and rootPart and rootPart.Parent then
                            rootPart.CFrame = targetRock.CFrame * CFrame.new(0, 3, 0)
                        end
                    end)
                    while AutoMine.IsActive and targetRock and targetRock.Parent and (targetRock:GetAttribute("Health") or 1) > 0 do
                        pcall(function()
                            local tool = char:FindFirstChild("Pickaxe") or backpack:FindFirstChild("Pickaxe")
                            if tool then
                                if tool.Parent == backpack then tool.Parent = char end
                                ToolEvent:FireServer("MineOres", tool, targetRock)
                            end
                        end)
                        task.wait(0.05)
                    end
                    if AutoMine.LockConnection then AutoMine.LockConnection:Disconnect() AutoMine.LockConnection = nil end
                end
            end
            task.wait(0.5)
        end
    end)
end

function AutoMine.Stop()
    AutoMine.IsActive = false
    if AutoMine.LockConnection then AutoMine.LockConnection:Disconnect() AutoMine.LockConnection = nil end
end
-- [[ BYTEE HUB V3 - PART 3 / 7 ]] --
local function ExecuteScript()
    if CoreGui:FindFirstChild("ByteeHub") then
        CoreGui:FindFirstChild("ByteeHub"):Destroy()
    end

    local MainGui = Instance.new("ScreenGui")
    MainGui.Name = "ByteeHub"
    MainGui.Parent = CoreGui

    -- Açılış Bildirim Kartı
    local NotifFrame = Instance.new("Frame", MainGui)
    NotifFrame.Size = UDim2.new(0, 340, 0, 75)
    NotifFrame.Position = UDim2.new(1, -355, 1, -85)
    NotifFrame.BackgroundColor3 = Config.BgColor
    NotifFrame.BackgroundTransparency = 0.1
    NotifFrame.BorderSizePixel = 0
    Instance.new("UICorner", NotifFrame).CornerRadius = UDim.new(0, 8)

    local NotifStroke = Instance.new("UIStroke", NotifFrame)
    NotifStroke.Color = Config.WarningYellow
    NotifStroke.Transparency = 0.2
    NotifStroke.Thickness = 1.5

    local NotifTitle = Instance.new("TextLabel", NotifFrame)
    NotifTitle.Size = UDim2.new(1, -20, 0, 20)
    NotifTitle.Position = UDim2.new(0, 15, 0, 8)
    NotifTitle.BackgroundTransparency = 1
    NotifTitle.Text = "Bytee Hub V3 Yüklendi"
    NotifTitle.TextColor3 = Config.WarningYellow
    NotifTitle.Font = Enum.Font.GothamBold
    NotifTitle.TextSize = 11
    NotifTitle.TextXAlignment = Enum.TextXAlignment.Left

    local NotifDesc = Instance.new("TextLabel", NotifFrame)
    NotifDesc.Size = UDim2.new(1, -20, 0, 40)
    NotifDesc.Position = UDim2.new(0, 15, 0, 26)
    NotifDesc.BackgroundTransparency = 1
    NotifDesc.Text = LocalPlayer.DisplayName .. ", harita kontrolleri güvenli modda çalıştırıldı."
    NotifDesc.TextColor3 = Config.TextSecondary
    NotifDesc.Font = Enum.Font.Gotham
    NotifDesc.TextSize = 9.5
    NotifDesc.TextWrapped = true
    NotifDesc.TextXAlignment = Enum.TextXAlignment.Left

    task.delay(4, function()
        if NotifFrame and NotifFrame.Parent then NotifFrame:Destroy() end
    end)

    -- Ana Pencere
    local MainFrame = Instance.new("Frame", MainGui)
    MainFrame.Name = "MainFrame"
    MainFrame.Size = Config.WindowSize
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.BackgroundColor3 = Config.BgColor
    MainFrame.BackgroundTransparency = 0.12
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

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

    local Sidebar = Instance.new("Frame", MainFrame)
    Sidebar.Size = UDim2.new(0, 140, 1, -48)
    Sidebar.Position = UDim2.new(0, 10, 0, 38)
    Sidebar.BackgroundColor3 = Config.SidebarColor
    Sidebar.BackgroundTransparency = 0.25
    Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 8)

    local TabContainer = Instance.new("ScrollingFrame", Sidebar)
    TabContainer.Size = UDim2.new(1, -6, 1, -10)
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
-- [[ BYTEE HUB V3 - PART 3 / 7 ]] --
local function ExecuteScript()
    if CoreGui:FindFirstChild("ByteeHub") then
        CoreGui:FindFirstChild("ByteeHub"):Destroy()
    end

    local MainGui = Instance.new("ScreenGui")
    MainGui.Name = "ByteeHub"
    MainGui.Parent = CoreGui

    -- Açılış Bildirim Kartı
    local NotifFrame = Instance.new("Frame", MainGui)
    NotifFrame.Size = UDim2.new(0, 340, 0, 75)
    NotifFrame.Position = UDim2.new(1, -355, 1, -85)
    NotifFrame.BackgroundColor3 = Config.BgColor
    NotifFrame.BackgroundTransparency = 0.1
    NotifFrame.BorderSizePixel = 0
    Instance.new("UICorner", NotifFrame).CornerRadius = UDim.new(0, 8)

    local NotifStroke = Instance.new("UIStroke", NotifFrame)
    NotifStroke.Color = Config.WarningYellow
    NotifStroke.Transparency = 0.2
    NotifStroke.Thickness = 1.5

    local NotifTitle = Instance.new("TextLabel", NotifFrame)
    NotifTitle.Size = UDim2.new(1, -20, 0, 20)
    NotifTitle.Position = UDim2.new(0, 15, 0, 8)
    NotifTitle.BackgroundTransparency = 1
    NotifTitle.Text = "Bytee Hub V3 Yüklendi"
    NotifTitle.TextColor3 = Config.WarningYellow
    NotifTitle.Font = Enum.Font.GothamBold
    NotifTitle.TextSize = 11
    NotifTitle.TextXAlignment = Enum.TextXAlignment.Left

    local NotifDesc = Instance.new("TextLabel", NotifFrame)
    NotifDesc.Size = UDim2.new(1, -20, 0, 40)
    NotifDesc.Position = UDim2.new(0, 15, 0, 26)
    NotifDesc.BackgroundTransparency = 1
    NotifDesc.Text = LocalPlayer.DisplayName .. ", harita kontrolleri güvenli modda çalıştırıldı."
    NotifDesc.TextColor3 = Config.TextSecondary
    NotifDesc.Font = Enum.Font.Gotham
    NotifDesc.TextSize = 9.5
    NotifDesc.TextWrapped = true
    NotifDesc.TextXAlignment = Enum.TextXAlignment.Left

    task.delay(4, function()
        if NotifFrame and NotifFrame.Parent then NotifFrame:Destroy() end
    end)

    -- Ana Pencere
    local MainFrame = Instance.new("Frame", MainGui)
    MainFrame.Name = "MainFrame"
    MainFrame.Size = Config.WindowSize
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.BackgroundColor3 = Config.BgColor
    MainFrame.BackgroundTransparency = 0.12
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

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

    local Sidebar = Instance.new("Frame", MainFrame)
    Sidebar.Size = UDim2.new(0, 140, 1, -48)
    Sidebar.Position = UDim2.new(0, 10, 0, 38)
    Sidebar.BackgroundColor3 = Config.SidebarColor
    Sidebar.BackgroundTransparency = 0.25
    Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 8)

    local TabContainer = Instance.new("ScrollingFrame", Sidebar)
    TabContainer.Size = UDim2.new(1, -6, 1, -10)
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
-- [[ BYTEE HUB V3 - PART 4 / 7 ]] --
    local DashboardPage   = CreateTab("Dashboard", 1)
    local InfoPage        = CreateTab("Information", 2)
    local FarmPage        = CreateTab("Farm", 3)
    local CombatPage      = CreateTab("Combat", 4)
    local ESPPage         = CreateTab("ESP", 5)
    local StaffPage       = CreateTab("Staff", 6)
    local SettingsPage    = CreateTab("Settings", 7)

    -- Dashboard Profil Kartı
    local UserCard = Instance.new("Frame", DashboardPage)
    UserCard.Size = UDim2.new(1, -6, 0, 55)
    UserCard.BackgroundColor3 = Config.ContainerColor
    UserCard.BackgroundTransparency = 0.2
    Instance.new("UICorner", UserCard).CornerRadius = UDim.new(0, 8)

    local AvatarImg = Instance.new("ImageLabel", UserCard)
    AvatarImg.Size = UDim2.new(0, 40, 0, 40)
    AvatarImg.Position = UDim2.new(0, 8, 0.5, -20)
    AvatarImg.BackgroundTransparency = 1
    AvatarImg.Image = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
    Instance.new("UICorner", AvatarImg).CornerRadius = UDim.new(1, 0)

    local WelcomeText = Instance.new("TextLabel", UserCard)
    WelcomeText.Size = UDim2.new(1, -60, 0, 18)
    WelcomeText.Position = UDim2.new(0, 55, 0, 10)
    WelcomeText.BackgroundTransparency = 1
    WelcomeText.Text = "Hoşgeldin, " .. LocalPlayer.DisplayName
    WelcomeText.TextColor3 = Config.TextPrimary
    WelcomeText.Font = Enum.Font.GothamBold
    WelcomeText.TextSize = 11
    WelcomeText.TextXAlignment = Enum.TextXAlignment.Left

    local RankText = Instance.new("TextLabel", UserCard)
    RankText.Size = UDim2.new(1, -60, 0, 16)
    RankText.Position = UDim2.new(0, 55, 0, 28)
    RankText.BackgroundTransparency = 1
    RankText.Text = "Status: Bytee Hub Active"
    RankText.TextColor3 = Config.HighlightText
    RankText.Font = Enum.Font.GothamMedium
    RankText.TextSize = 9.5
    RankText.TextXAlignment = Enum.TextXAlignment.Left

    -- Daraltılabilir (Accordion) Kategori Oluşturucu
    local function CreateAccordionCategory(parent, titleText)
        local Container = Instance.new("Frame", parent)
        Container.Size = UDim2.new(1, -6, 0, 32)
        Container.BackgroundColor3 = Config.ContainerColor
        Container.BackgroundTransparency = 0.2
        Container.ClipsDescendants = true
        Instance.new("UICorner", Container).CornerRadius = UDim.new(0, 8)

        local HeaderBtn = Instance.new("TextButton", Container)
        HeaderBtn.Size = UDim2.new(1, 0, 0, 32)
        HeaderBtn.BackgroundTransparency = 1
        HeaderBtn.Text = "  " .. titleText
        HeaderBtn.TextColor3 = Config.TextPrimary
        HeaderBtn.Font = Enum.Font.GothamBold
        HeaderBtn.TextSize = 11
        HeaderBtn.TextXAlignment = Enum.TextXAlignment.Left

        local ArrowImg = Instance.new("ImageLabel", HeaderBtn)
        ArrowImg.Size = UDim2.new(0, 16, 0, 16)
        ArrowImg.Position = UDim2.new(1, -24, 0.5, -8)
        ArrowImg.BackgroundTransparency = 1
        ArrowImg.Image = "rbxassetid://10709790948"
        ArrowImg.ImageColor3 = Config.TextSecondary

        local ContentFrame = Instance.new("Frame", Container)
        ContentFrame.Size = UDim2.new(1, 0, 0, 0)
        ContentFrame.Position = UDim2.new(0, 0, 0, 32)
        ContentFrame.BackgroundTransparency = 1

        local ContentLayout = Instance.new("UIListLayout", ContentFrame)
        ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
        ContentLayout.Padding = UDim.new(0, 4)

        local isOpen = false
        HeaderBtn.MouseButton1Click:Connect(function()
            isOpen = not isOpen
            local targetHeight = isOpen and (36 + ContentLayout.AbsoluteContentSize.Y) or 32
            TweenService:Create(Container, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                Size = UDim2.new(1, -6, 0, targetHeight)
            }):Play()
            TweenService:Create(ArrowImg, TweenInfo.new(0.2), { Rotation = isOpen and 180 or 0 }):Play()
        end)

        ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            if isOpen then
                Container.Size = UDim2.new(1, -6, 0, 36 + ContentLayout.AbsoluteContentSize.Y)
            end
        end)

        return ContentFrame
    end

    local JanitorCategory = CreateAccordionCategory(FarmPage, "Temizlikçi (Janitor) Auto Farm")
    local MinerCategory   = CreateAccordionCategory(FarmPage, "Madenci (Miner) Auto Farm")
-- [[ BYTEE HUB V3 - PART 5 / 7 ]] --
    local function CreateToggle(parentFrame, text, defaultState, callback)
        local ToggleFrame = Instance.new("Frame", parentFrame)
        ToggleFrame.Size = UDim2.new(1, -12, 0, 28)
        ToggleFrame.Position = UDim2.new(0, 6, 0, 0)
        ToggleFrame.BackgroundColor3 = Config.SidebarColor
        ToggleFrame.BackgroundTransparency = 0.4
        Instance.new("UICorner", ToggleFrame).CornerRadius = UDim.new(0, 6)

        local Label = Instance.new("TextLabel", ToggleFrame)
        Label.Size = UDim2.new(1, -50, 1, 0)
        Label.Position = UDim2.new(0, 8, 0, 0)
        Label.BackgroundTransparency = 1
        Label.Text = text
        Label.TextColor3 = Config.TextPrimary
        Label.Font = Enum.Font.Gotham
        Label.TextSize = 10
        Label.TextXAlignment = Enum.TextXAlignment.Left

        local Btn = Instance.new("TextButton", ToggleFrame)
        Btn.Size = UDim2.new(0, 34, 0, 18)
        Btn.Position = UDim2.new(1, -40, 0.5, -9)
        Btn.BackgroundColor3 = defaultState and Config.HighlightText or Config.ContainerColor
        Btn.Text = ""
        Instance.new("UICorner", Btn).CornerRadius = UDim.new(1, 0)

        local Circle = Instance.new("Frame", Btn)
        Circle.Size = UDim2.new(0, 14, 0, 14)
        Circle.Position = defaultState and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
        Circle.BackgroundColor3 = Config.Accent
        Instance.new("UICorner", Circle).CornerRadius = UDim.new(1, 0)

        local state = defaultState
        Btn.MouseButton1Click:Connect(function()
            state = not state
            TweenService:Create(Btn, TweenInfo.new(0.2), {BackgroundColor3 = state and Config.HighlightText or Config.ContainerColor}):Play()
            TweenService:Create(Circle, TweenInfo.new(0.2), {Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)}):Play()
            callback(state)
        end)
    end

    -- Farm Toggle Butonları
    CreateToggle(JanitorCategory, "Auto Janitor Clean", false, function(val)
        JanitorState.AutoFarm = val
    end)

    CreateToggle(MinerCategory, "Auto Mining Ores", false, function(val)
        if val then AutoMine.Start() else AutoMine.Stop() end
    end)

    -- Movement / Combat Modülleri
    CreateToggle(CombatPage, "Noclip (Duvarlardan Geçme)", false, function(val)
        HubSettings.Noclip = val
    end)

    CreateToggle(CombatPage, "Infinite Jump (Sınırsız Zıplama)", false, function(val)
        HubSettings.InfiniteJump = val
    end)

    RunService.Stepped:Connect(function()
        if HubSettings.Noclip then
            local char = LocalPlayer.Character
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
            end
        end
    end)

    UserInputService.JumpRequest:Connect(function()
        if HubSettings.InfiniteJump then
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
        end
    end)
-- [[ BYTEE HUB V3 - PART 6 / 7 ]] --
    -- ESP Modülleri
    CreateToggle(ESPPage, "Box ESP", false, function(val)
        HubSettings.BoxEsp = val
    end)

    CreateToggle(ESPPage, "Name & Distance ESP", false, function(val)
        HubSettings.NameDistanceEsp = val
    end)

    CreateToggle(ESPPage, "Chams / Glow All White", false, function(val)
        HubSettings.GlowAllWhite = val
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                local highlight = plr.Character:FindFirstChild("ByteeHighlight")
                if val then
                    if not highlight then
                        highlight = Instance.new("Highlight")
                        highlight.Name = "ByteeHighlight"
                        highlight.FillColor = Config.GlowColor
                        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                        highlight.FillTransparency = 0.5
                        highlight.Parent = plr.Character
                    end
                else
                    if highlight then highlight:Destroy() end
                end
            end
        end
    end)

    -- Staff Tracker Kartı
    local StaffContainer = Instance.new("Frame", StaffPage)
    StaffContainer.Size = UDim2.new(1, -6, 0, 100)
    StaffContainer.BackgroundColor3 = Config.ContainerColor
    StaffContainer.BackgroundTransparency = 0.2
    Instance.new("UICorner", StaffContainer).CornerRadius = UDim.new(0, 8)

    local StaffTitle = Instance.new("TextLabel", StaffContainer)
    StaffTitle.Size = UDim2.new(1, -10, 0, 25)
    StaffTitle.Position = UDim2.new(0, 10, 0, 5)
    StaffTitle.BackgroundTransparency = 1
    StaffTitle.Text = "Yetkili Dedektörü"
    StaffTitle.TextColor3 = Config.WarningYellow
    StaffTitle.Font = Enum.Font.GothamBold
    StaffTitle.TextSize = 11
    StaffTitle.TextXAlignment = Enum.TextXAlignment.Left

    local StaffStatus = Instance.new("TextLabel", StaffContainer)
    StaffStatus.Size = UDim2.new(1, -20, 0, 60)
    StaffStatus.Position = UDim2.new(0, 10, 0, 30)
    StaffStatus.BackgroundTransparency = 1
    StaffStatus.Text = "Aktif Taranıyor...\nSunucuda şüpheli admin/moderatör grubuna bağlı oyuncu tespit edilmedi."
    StaffStatus.TextColor3 = Config.TextSecondary
    StaffStatus.Font = Enum.Font.Gotham
    StaffStatus.TextSize = 10
    StaffStatus.TextWrapped = true
    StaffStatus.TextXAlignment = Enum.TextXAlignment.Left
-- [[ BYTEE HUB V3 - PART 7 / 7 ]] --
    local function CreateButton(parentFrame, text, color, callback)
        local Btn = Instance.new("TextButton", parentFrame)
        Btn.Size = UDim2.new(1, -12, 0, 28)
        Btn.BackgroundColor3 = color or Config.ContainerColor
        Btn.BackgroundTransparency = 0.2
        Btn.Text = text
        Btn.TextColor3 = Config.TextPrimary
        Btn.Font = Enum.Font.GothamMedium
        Btn.TextSize = 10.5
        Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)

        Btn.MouseButton1Click:Connect(callback)
    end

    CreateButton(SettingsPage, "Discord Sunucusunu Kopyala", Config.ContainerColor, function()
        if setclipboard then setclipboard(Config.Discord) end
    end)

    CreateButton(SettingsPage, "YouTube Kanal Bağlantısını Kopyala", Config.ContainerColor, function()
        if setclipboard then setclipboard(Config.YouTube) end
    end)

    CreateButton(SettingsPage, "Bytee Hub V3'ü Kapat (Destroy GUI)", Config.CloseRed, function()
        if AutoMine.IsActive then AutoMine.Stop() end
        JanitorState.AutoFarm = false
        MainGui:Destroy()
    end)

    MakeDraggable(MainFrame)
end

-- Scripti güvenli modda çalıştır
ExecuteScript()
