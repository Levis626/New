-- SERVICES & REFERENCES
local cloneref = (cloneref or clonereference or function(instance) return instance end)
local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))
local RunService = cloneref(game:GetService("RunService"))
local Players = cloneref(game:GetService("Players"))
local Workspace = cloneref(game:GetService("Workspace"))
local VirtualInputManager = cloneref(game:GetService("VirtualInputManager"))
local CoreGui = cloneref(game:GetService("CoreGui"))
local LocalPlayer = Players.LocalPlayer

local ToolEvent = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Tool"):WaitForChild("Event")
local MineRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Tool"):WaitForChild("Event")

--------------------------------------------------------------------------------
-- KÜÇÜK / MİNNİK UI (MOBILE & PC COMPATIBLE)
--------------------------------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ByteeHubMiniUI"
ScreenGui.ResetOnSpawn = false
pcall(function() ScreenGui.Parent = CoreGui end)
if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

-- Ana Çerçeve (Boyut: 360x220 - Mobil için çok ideal ve küçük)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 360, 0, 220)
MainFrame.Position = UDim2.new(0.5, -180, 0.5, -110)
MainFrame.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner", MainFrame)
UICorner.CornerRadius = UDim.new(0, 8)

-- Başlık Çubuğu
local TitleBar = Instance.new("Frame", MainFrame)
TitleBar.Size = UDim2.new(1, 0, 0, 28)
TitleBar.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
TitleBar.BorderSizePixel = 0

local TitleCorner = Instance.new("UICorner", TitleBar)
TitleCorner.CornerRadius = UDim.new(0, 8)

local TitleText = Instance.new("TextLabel", TitleBar)
TitleText.Size = UDim2.new(1, -30, 1, 0)
TitleText.Position = UDim2.new(0, 8, 0, 0)
TitleText.Text = "Bytee Hub | Mini UI"
TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleText.TextSize = 12
TitleText.Font = Enum.Font.SourceSansBold
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.BackgroundTransparency = 1

-- UI Kapat/Aç Butonu (Mobil için küçük ekrana sabitleme)
local ToggleUIBtn = Instance.new("TextButton", ScreenGui)
ToggleUIBtn.Size = UDim2.new(0, 50, 0, 24)
ToggleUIBtn.Position = UDim2.new(0, 10, 0, 10)
ToggleUIBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
ToggleUIBtn.Text = "HUB"
ToggleUIBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleUIBtn.TextSize = 11
ToggleUIBtn.Font = Enum.Font.SourceSansBold
Instance.new("UICorner", ToggleUIBtn).CornerRadius = UDim.new(0, 6)

ToggleUIBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- Sol Kategori Butonları Alanı
local TabSidebar = Instance.new("Frame", MainFrame)
TabSidebar.Size = UDim2.new(0, 90, 1, -28)
TabSidebar.Position = UDim2.new(0, 0, 0, 28)
TabSidebar.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
TabSidebar.BorderSizePixel = 0

local SidebarList = Instance.new("UIListLayout", TabSidebar)
SidebarList.SortOrder = Enum.SortOrder.LayoutOrder
SidebarList.Padding = UDim.new(0, 4)

-- Sağ Özellik Sayfaları Alanı
local ContentContainer = Instance.new("Frame", MainFrame)
ContentContainer.Size = UDim2.new(1, -95, 1, -33)
ContentContainer.Position = UDim2.new(0, 95, 0, 31)
ContentContainer.BackgroundTransparency = 1

local Tabs = {}
local function CreateTab(name)
    local TabBtn = Instance.new("TextButton", TabSidebar)
    TabBtn.Size = UDim2.new(1, -8, 0, 26)
    TabBtn.Position = UDim2.new(0, 4, 0, 0)
    TabBtn.BackgroundColor3 = Color3.fromRGB(32, 32, 38)
    TabBtn.Text = name
    TabBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
    TabBtn.TextSize = 11
    TabBtn.Font = Enum.Font.SourceSans
    Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 4)

    local Page = Instance.new("ScrollingFrame", ContentContainer)
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.BorderSizePixel = 0
    Page.ScrollBarThickness = 3
    Page.Visible = false

    local PageList = Instance.new("UIListLayout", Page)
    PageList.SortOrder = Enum.SortOrder.LayoutOrder
    PageList.Padding = UDim.new(0, 4)

    TabBtn.MouseButton1Click:Connect(function()
        for _, t in pairs(Tabs) do
            t.Page.Visible = false
            t.Btn.TextColor3 = Color3.fromRGB(180, 180, 180)
            t.Btn.BackgroundColor3 = Color3.fromRGB(32, 32, 38)
        end
        Page.Visible = true
        TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        TabBtn.BackgroundColor3 = Color3.fromRGB(50, 100, 220)
    end)

    Tabs[name] = {Btn = TabBtn, Page = Page}
    return Page
end

local function AddToggle(page, text, default, callback)
    local Toggle = Instance.new("TextButton", page)
    Toggle.Size = UDim2.new(1, -6, 0, 24)
    Toggle.BackgroundColor3 = default and Color3.fromRGB(40, 120, 60) or Color3.fromRGB(35, 35, 42)
    Toggle.Text = (default and "[ON] " or "[OFF] ") .. text
    Toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    Toggle.TextSize = 11
    Toggle.Font = Enum.Font.SourceSans
    Instance.new("UICorner", Toggle).CornerRadius = UDim.new(0, 4)

    local state = default
    Toggle.MouseButton1Click:Connect(function()
        state = not state
        Toggle.Text = (state and "[ON] " or "[OFF] ") .. text
        Toggle.BackgroundColor3 = state and Color3.fromRGB(40, 120, 60) or Color3.fromRGB(35, 35, 42)
        callback(state)
    end)
end

local function AddButton(page, text, callback)
    local Btn = Instance.new("TextButton", page)
    Btn.Size = UDim2.new(1, -6, 0, 24)
    Btn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    Btn.Text = text
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.TextSize = 11
    Btn.Font = Enum.Font.SourceSans
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 4)

    Btn.MouseButton1Click:Connect(callback)
end

-- TABS TANIMLAMA
local FarmPage = CreateTab("Auto Farm")
local EatPage = CreateTab("Auto Eat")
local CombatPage = CreateTab("Combat")

-- Varsayılan sekmeyi aç
Tabs["Auto Farm"].Page.Visible = true
Tabs["Auto Farm"].Btn.BackgroundColor3 = Color3.fromRGB(50, 100, 220)
Tabs["Auto Farm"].Btn.TextColor3 = Color3.fromRGB(255, 255, 255)

--------------------------------------------------------------------------------
-- 1. AUTO EAT / DRINK MANTIĞI
--------------------------------------------------------------------------------
local FOOD_TOOLS = { CerealBar = true, FoodPlate = true, Popcorn = true }
local DRINK_TOOLS = { WaterCup = true, Soda = true, BloxyCola = true }
local AutoHungerState = { Enabled = false, EatBelow = 50, DrinkBelow = 50 }
local RunningAutoHunger = true
local vendingMachines = {}

local function getCharacterHunger()
    local char = LocalPlayer.Character
    if not char or not char.Parent then return nil, nil end
    return char, char:FindFirstChildOfClass("Humanoid")
end

local function findAutoEatTool(names)
    local char = LocalPlayer.Character
    if char then
        for _, t in ipairs(char:GetChildren()) do
            if t:IsA("Tool") and names[t.Name] then return t end
        end
    end
    for _, t in ipairs(LocalPlayer.Backpack:GetChildren()) do
        if t:IsA("Tool") and names[t.Name] then return t end
    end
    return nil
end

local function stowLeftover(names)
    local char, humanoid = getCharacterHunger()
    if not humanoid then return end
    local equipped = char:FindFirstChildOfClass("Tool")
    if equipped and names[equipped.Name] then
        pcall(function() humanoid:UnequipTools() end)
    end
end

local function collectVendingMachines()
    local list = {}
    for _, inst in ipairs(Workspace:GetDescendants()) do
        if inst:IsA("RemoteEvent") and inst.Parent and inst.Parent:IsA("Configuration") then
            local text = inst.Parent:GetAttribute("Text") or ""
            if text:find("Buy Food") or text:find("Buy Drink") then
                local machine = inst:FindFirstAncestorOfClass("Model")
                if machine then
                    table.insert(list, { event = inst, kind = text:find("Food") and "Food" or "Drink", model = machine, price = tonumber(text:match("%$(%d+)")) or 3 })
                end
            end
        end
    end
    return list
end

local function getNearestMachine(kind)
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local best, bestDist = nil, math.huge
    for _, m in ipairs(vendingMachines) do
        if m.kind == kind and m.event.Parent then
            local ok, pos = pcall(function() return m.model:GetPivot().Position end)
            if ok and pos then
                local d = root and (pos - root.Position).Magnitude or 0
                if d < bestDist then best, bestDist = m, d end
            end
        end
    end
    return best, bestDist
end

local function consumeAutoHunger(kind, toolNames, statName, thresholdOf)
    local actions, misses = 0, 0
    while RunningAutoHunger and AutoHungerState.Enabled and actions < 50 and misses < 3 do
        local threshold = thresholdOf()
        local stat = LocalPlayer:GetAttribute(statName)
        if not stat or stat >= threshold then break end
        local tool = findAutoEatTool(toolNames)
        if not tool then
            local machineKind = (kind == "Eat") and "Food" or "Drink"
            local nearest = getNearestMachine(machineKind)
            if not nearest then vendingMachines = collectVendingMachines() nearest = getNearestMachine(machineKind) end
            if not nearest then break end
            if (LocalPlayer:GetAttribute("Money") or 0) < nearest.price then break end
            nearest.event:FireServer()
            local t0 = os.clock()
            repeat task.wait(0.15) tool = findAutoEatTool(toolNames) until tool or os.clock() - t0 > 3
            if not tool then misses += 1 task.wait(1) continue end
        end
        local _, humanoid = getCharacterHunger()
        if not humanoid then break end
        if tool.Parent == LocalPlayer.Backpack then
            humanoid:EquipTool(tool)
            local t0 = os.clock()
            while RunningAutoHunger and AutoHungerState.Enabled and tool.Parent == LocalPlayer.Backpack and os.clock() - t0 < 2 do task.wait(0.1) end
            task.wait(0.3)
        end
        if not tool.Parent then actions += 1 continue end
        local t0 = os.clock()
        while RunningAutoHunger and AutoHungerState.Enabled and tool.Parent and tool:GetAttribute("OnCooldown") and os.clock() - t0 < 6 do task.wait(0.15) end
        if not RunningAutoHunger or not AutoHungerState.Enabled or not tool.Parent then actions += 1 continue end
        local before = LocalPlayer:GetAttribute(statName) or 0
        ToolEvent:FireServer(kind, tool)
        actions += 1
        local t1 = os.clock()
        while RunningAutoHunger and AutoHungerState.Enabled and os.clock() - t1 < 4 do
            if not tool.Parent then break end
            if (LocalPlayer:GetAttribute(statName) or 0) ~= before then break end
            task.wait(0.1)
        end
        if (LocalPlayer:GetAttribute(statName) or 0) ~= before then misses = 0 else misses += 1 end
        task.wait(0.5)
    end
    stowLeftover(toolNames)
end

task.spawn(function()
    while true do
        task.wait(1)
        pcall(function()
            if not RunningAutoHunger or not AutoHungerState.Enabled then return end
            local hunger = LocalPlayer:GetAttribute("Hunger")
            local thirst = LocalPlayer:GetAttribute("Thirst")
            if hunger and hunger < AutoHungerState.EatBelow then
                consumeAutoHunger("Eat", FOOD_TOOLS, "Hunger", function() return AutoHungerState.EatBelow end)
            end
            if thirst and thirst < AutoHungerState.DrinkBelow then
                consumeAutoHunger("Drink", DRINK_TOOLS, "Thirst", function() return AutoHungerState.DrinkBelow end)
            end
        end)
    end
end)

AddToggle(EatPage, "Auto Eat / Drink", false, function(v) AutoHungerState.Enabled = v end)
--------------------------------------------------------------------------------
-- 2. AUTO FARM MANTIĞI
--------------------------------------------------------------------------------
local FarmState = { AutoCook = false, AutoFish = false, AutoSell = false, SellInterval = 20 }

-- AUTO COOK
local farmSteps = {
    {name = "Cut", cframe = CFrame.new(43.00, 7.54, -298.80), path = "Cut"},
    {name = "Cook", cframe = CFrame.new(37.12, 7.54, -297.77), path = "Cook"},
    {name = "Boil", cframe = CFrame.new(32.07, 7.54, -296.28), path = "Simmer"},
    {name = "Combine", cframe = CFrame.new(41.81, 7.54, -294.10), path = "Assemble"},
    {name = "To take", cframe = CFrame.new(48.75, 7.54, -296.25), path = "Take"},
    {name = "Deposit", cframe = CFrame.new(16.09, 7.54, -314.13), path = "Deposit"}
}

local function checkStep(step)
    local tasks = workspace:FindFirstChild("Tasks")
    if not tasks then return nil end
    local cook = tasks:FindFirstChild("Cook")
    if not cook then return nil end
    local taskObj = cook:FindFirstChild(step.path)
    if not taskObj then return nil end
    local root = taskObj:FindFirstChild("RootPart")
    if not root then return nil end
    local prompt = root:FindFirstChild("Prompt")
    if not prompt then return nil end
    local interact = prompt:FindFirstChild("Interact")
    if not interact then return nil end
    local event = interact:FindFirstChild("Event")
    if not event or not event:IsA("RemoteEvent") then return nil end
    return event
end

task.spawn(function()
    while true do
        if FarmState.AutoCook then
            for index, step in ipairs(farmSteps) do
                if not FarmState.AutoCook then break end
                local char = LocalPlayer.Character
                local rootPart = char and char:FindFirstChild("HumanoidRootPart")
                if rootPart then
                    rootPart.CFrame = step.cframe
                    task.wait(0.3)
                    local event = checkStep(step)
                    if event then pcall(function() event:FireServer() end) end
                end
                if index <= 3 then task.wait(10.0) else task.wait(2.0) end
            end
        end
        task.wait(0.5)
    end
end)

-- AUTO FISH
local FishingSystem = ReplicatedStorage:WaitForChild("FishingSystem")
local FishingModules = FishingSystem:WaitForChild("FishingModules")
local MinigameSystem = require(FishingModules:WaitForChild("MinigameSystem"))
local PowerBarSystem = require(FishingModules:WaitForChild("PowerBarSystem"))
local SoundManager = require(FishingModules:WaitForChild("SoundManager"))
local GUIManager = require(FishingModules:WaitForChild("GUIManager"))

local function getRod()
   local character = LocalPlayer.Character
   if character then
       for _, child in ipairs(character:GetChildren()) do
           if child:IsA("Tool") and string.find(string.lower(child.Name), "rod") then return child end
       end
   end
   local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
   if backpack then
       for _, child in ipairs(backpack:GetChildren()) do
           if child:IsA("Tool") and string.find(string.lower(child.Name), "rod") then return child end
       end
   end
   return nil
end

local function getElements()
   local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
   local fishingGui = playerGui and playerGui:FindFirstChild("FishingGui")
   local fishing = fishingGui and fishingGui:FindFirstChild("Fishing")
   local bar = fishing and fishing:FindFirstChild("Bar")
   return bar and bar:FindFirstChild("PlayerZone"), bar and bar:FindFirstChild("FishMarker")
end

local function castRod()
   if PowerBarSystem:IsCharging() then VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0) task.wait(0.15) end
   VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
   local start = os.clock()
   while os.clock() - start < 1.0 do
       RunService.Heartbeat:Wait()
       if PowerBarSystem:IsCharging() then break end
   end
   while os.clock() - start < 5 do
       RunService.Heartbeat:Wait()
       if PowerBarSystem:GetCurrentPower() >= 99.5 then break end
       if not PowerBarSystem:IsCharging() and os.clock() - start > 0.5 then break end
   end
   VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
end

local lastClick = 0
RunService.Heartbeat:Connect(function()
   if not FarmState.AutoFish or not MinigameSystem:IsActive() then return end
   pcall(function()
       local phase = MinigameSystem:GetPhase()
       if phase == "shake" then
           if os.clock() - lastClick > 0.04 then
               MinigameSystem:HandleClick(SoundManager, GUIManager)
               lastClick = os.clock()
           end
       elseif phase == "reel" then
           local zone, marker = getElements()
           if zone and marker then
               local zonePos = zone.Position.X.Scale
               local fishPos = marker.Position.X.Scale
               if fishPos > zonePos + 0.01 then MinigameSystem:SetHolding(true)
               elseif fishPos < zonePos - 0.01 then MinigameSystem:SetHolding(false)
               else MinigameSystem:SetHolding(false) end
           end
       end
   end)
end)

task.spawn(function()
   while true do
       task.wait(0.1)
       if not FarmState.AutoFish then continue end
       pcall(function()
           if MinigameSystem:IsActive() then
               while MinigameSystem:IsActive() and FarmState.AutoFish do task.wait(0.1) end
               task.wait(0.5)
           end
           if not FarmState.AutoFish then return end
           local character = LocalPlayer.Character
           local humanoid = character and character:FindFirstChildOfClass("Humanoid")
           if not character or not humanoid or humanoid.Health <= 0 then task.wait(1) return end

           humanoid.WalkSpeed = 0
           pcall(function() humanoid.JumpPower = 0 end)
           local rod = getRod()
           if not rod then task.wait(1) return end
           if rod.Parent ~= character then humanoid:EquipTool(rod) task.wait(0.8) end
           castRod()
       end)
   end
end)

task.spawn(function()
   while true do
       task.wait(FarmState.SellInterval)
       if FarmState.AutoSell then pcall(function() FishingSystem.InventoryEvents.Inventory_SellAll:InvokeServer() end) end
   end
end)

-- AUTO MINE
local RocksFolder = Workspace:WaitForChild("Tasks"):WaitForChild("Prisoner"):WaitForChild("Rocks")
local AutoMine = { IsActive = false, NoclipConnection = nil, RunningThread = nil }

function AutoMine.FindClosestRock()
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
                if distance < minDistance then minDistance = distance closest = rock end
            end
        end
    end
    return closest
end

function AutoMine.Start()
    if AutoMine.IsActive then return end
    AutoMine.IsActive = true
    AutoMine.NoclipConnection = RunService.Stepped:Connect(function()
        if not AutoMine.IsActive then return end
        local char = LocalPlayer.Character
        if not char then return end
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end)
    AutoMine.RunningThread = task.spawn(function()
        while AutoMine.IsActive do
            local char = LocalPlayer.Character
            local rootPart = char and char:FindFirstChild("HumanoidRootPart")
            local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
            local targetRock = AutoMine.FindClosestRock()
            if targetRock and rootPart then
                rootPart.CFrame = targetRock.CFrame * CFrame.new(0, 3, 0)
                rootPart.AssemblyLinearVelocity = Vector3.zero
                pcall(function()
                    local tool = char:FindFirstChild("Pickaxe") or backpack:FindFirstChild("Pickaxe") or char:FindFirstChild("PremiumPickaxe") or backpack:FindFirstChild("PremiumPickaxe")
                    if tool then
                        if tool.Parent == backpack then tool.Parent = char end
                        MineRemote:FireServer("MineOres", tool, targetRock)
                    end
                end)
            end
            task.wait(0.1)
        end
    end)
end

function AutoMine.Stop()
    AutoMine.IsActive = false
    if AutoMine.NoclipConnection then AutoMine.NoclipConnection:Disconnect() AutoMine.NoclipConnection = nil end
end

-- AUTO TRASH
local TrashesFolder = Workspace:WaitForChild("Tasks"):WaitForChild("Prisoner"):WaitForChild("Trashes")
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
                        task.wait(0.3)
                        if trashTool.Parent == backpack then humanoid:EquipTool(trashTool) end
                        dumpster.Prompt.Interact.Event:FireServer()
                    else
                        local activeBin
                        for _, bin in ipairs(TrashesFolder:GetChildren()) do
                            local prompt = bin:FindFirstChild("Prompt")
                            if prompt and prompt:GetAttribute("Enabled") == true then activeBin = bin break end
                        end
                        if activeBin and activeBin.Prompt and rootPart then
                            rootPart.CFrame = activeBin.Prompt.Parent.CFrame * CFrame.new(0, 2, 0)
                            task.wait(0.3)
                            activeBin.Prompt.Interact.Event:FireServer()
                        end
                    end
                end)
            end
            task.wait(0.5)
        end
    end)
end

function AutoTrash.Stop()
    AutoTrash.IsActive = false
end

-- AUTO JANITOR
local JanitorTasks = Workspace:WaitForChild("Tasks"):WaitForChild("Janitor")
local farmingJanitor = false

local function getMop()
    local char = LocalPlayer.Character
    if char then
        local equipped = char:FindFirstChild("Mop")
        if equipped and equipped:IsA("Tool") then return equipped, true end
    end
    local bagMop = LocalPlayer.Backpack:FindFirstChild("Mop")
    if bagMop and bagMop:IsA("Tool") then return bagMop, false end
    return nil, false
end

local function nearestPuddle(origin)
    local best, bestDist = nil, math.huge
    for _, child in ipairs(JanitorTasks:GetChildren()) do
        if child:IsA("BasePart") and child.Size.Y < 0.5 then
            local dist = (child.Position - origin).Magnitude
            if dist < bestDist then best, bestDist = child, dist end
        end
    end
    return best
end

task.spawn(function()
    while true do
        if farmingJanitor then
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local mop, equipped = getMop()
                local puddle = nearestPuddle(hrp.Position)
                if mop and puddle then
                    if not equipped then char.Humanoid:EquipTool(mop) end
                    hrp.CFrame = CFrame.new(puddle.Position + Vector3.new(0, 3.2, 0))
                    ToolEvent:FireServer("Mop", mop, puddle)
                end
            end
        end
        task.wait(0.4)
    end
end)

-- ÖZELLİKLERİ MİNİ UI'A BAĞLAMA
AddToggle(FarmPage, "Auto Fish", false, function(v)
    FarmState.AutoFish = v
    if not v then
        local char = LocalPlayer.Character
        local humanoid = char and char:FindFirstChildOfClass("Humanoid")
        if humanoid then humanoid.WalkSpeed = 16 end
    end
end)
AddToggle(FarmPage, "Auto Sell Fish", false, function(v) FarmState.AutoSell = v end)
AddToggle(FarmPage, "Auto Cook", false, function(v) FarmState.AutoCook = v end)
AddToggle(FarmPage, "Auto Mine", false, function(v) if v then AutoMine.Start() else AutoMine.Stop() end end)
AddToggle(FarmPage, "Auto Trash", false, function(v) if v then AutoTrash.Start() else AutoTrash.Stop() end end)
AddToggle(FarmPage, "Auto Janitor", false, function(v) farmingJanitor = v end)

AddButton(CombatPage, "Load Mobile Aimbot", function()
    loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-Aimbot-Mobile-34677"))()
end)

