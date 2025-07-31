-- 🐾 Premium Pet Hatch Simulator: Luxe UI & Brighter Buttons
local Players          = game:GetService("Players")
local Workspace        = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

-- 🗂 Button references
local randomizeBtn, toggleBtn, autoBtn

-- 🐣 Pet definitions
local petTable = {
    ["Common Egg"]    = { "Dog", "Bunny", "Golden Lab" },
    ["Uncommon Egg"]  = { "Chicken", "Black Bunny", "Cat", "Deer" },
    ["Rare Egg"]      = { "Pig", "Monkey", "Rooster", "Orange Tabby", "Spotted Deer" },
    ["Legendary Egg"] = { "Cow", "Polar Bear", "Sea Otter", "Turtle", "Silver Monkey" },
    ["Mythical Egg"]  = { "Grey Mouse", "Brown Mouse", "Squirrel", "Red Giant Ant" },
    ["Bug Egg"]       = { "Snail", "Caterpillar", "Giant Ant", "Praying Mantis" },
    ["Night Egg"]     = { "Frog", "Hedgehog", "Mole", "Echo Frog", "Night Owl" },
    ["Bee Egg"]       = { "Bee", "Honey Bee", "Bear Bee", "Petal Bee" },
    ["Anti Bee Egg"]  = { "Wasp", "Moth", "Tarantula Hawk" },
    ["Oasis Egg"]     = { "Meerkat", "Sand Snake", "Axolotl" },
    ["Paradise Egg"]  = { "Ostrich", "Peacock", "Capybara" },
    ["Dinosaur Egg"]  = { "Raptor", "Triceratops", "Stegosaurus" },
    ["Primal Egg"]    = { "Parasaurolophus", "Iguanodon", "Pachycephalosaurus" },
    ["Zen Egg"]       = { "Shiba Inu", "Tanuki", "Nihonzaru" },
}

-- 🔧 State
local espEnabled   = true
local eggDataMap   = {}
local isBusy       = false
local autoRunning  = false
local bestPets     = {
    Raccoon=true, Dragonfly=true, ["Queen Bee"]=true, ["Disco Bee"]=true,
    ["Fennec Fox"]=true, Fox=true, ["Mimic Octopus"]=true,
    ["T-Rex"]=true, Spinosaurus=true, Kitsune=true
}

-- ✨ Glitch label effect
local function glitchLabelEffect(lbl)
    coroutine.wrap(function()
        local orig = lbl.TextColor3
        for _ = 1, 2 do
            lbl.TextColor3 = Color3.fromRGB(255, 215, 0)
            wait(0.07)
            lbl.TextColor3 = orig
            wait(0.07)
        end
    end)()
end

-- Random weight generator
local function getBiasedRandom()
    local function buildWeighted(startVal, endVal, bias)
        local vals = {}
        for i = math.floor(startVal*100), math.floor(endVal*100) do
            local v = i/100
            local w = math.exp(-((v - startVal)*bias))
            for _ = 1, math.floor(w*100) do
                table.insert(vals, v)
            end
        end
        return vals
    end
    local normal = buildWeighted(0.80, 2.20, 4)
    local rare   = buildWeighted(2.21, 10.00, 1.5)
    if math.random(100)==1 then
        return rare[math.random(#rare)]
    else
        return normal[math.random(#normal)]
    end
end

-- Check hatch readiness
local function isEggReady(egg)
    local rf = egg:FindFirstChild("ReadyToHatch")
    if rf and rf:IsA("BoolValue") then return rf.Value end
    local ht = egg:FindFirstChild("HatchTime")
    if ht and ht:IsA("NumberValue") then return ht.Value <= 0.05 end
    return true
end

-- ESP visuals
local function applyEggESP(egg, name, weight)
    if egg:FindFirstChild("PetBillboard", true) then egg:FindFirstChild("PetBillboard", true):Destroy() end
    if egg:FindFirstChild("ESPHighlight") then egg.ESPHighlight:Destroy() end
    if not espEnabled then return end

    local base = egg:FindFirstChildWhichIsA("BasePart")
    if not base then return end

    local ready = isEggReady(egg)
    local gui   = Instance.new("BillboardGui", base)
    gui.Name        = "PetBillboard"
    gui.Adornee     = base
    gui.Size        = UDim2.new(0, 270, 0, 50)
    gui.StudsOffset = Vector3.new(0, 4.5, 0)
    gui.AlwaysOnTop = true
    gui.MaxDistance = 500

    local lbl = Instance.new("TextLabel", gui)
    lbl.Size                   = UDim2.new(1, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text                   = string.format("%s | %s%s [%0.2f kg]",
                                egg.Name,
                                name,
                                ready and "" or " (Not Ready)",
                                weight)
    lbl.TextColor3            = ready and Color3.new(1,1,1) or Color3.fromRGB(160,160,160)
    lbl.TextStrokeTransparency = ready and 0 or 0.5
    lbl.TextScaled            = true
    lbl.Font                  = Enum.Font.FredokaOne
    glitchLabelEffect(lbl)

    local hi = Instance.new("Highlight", egg)
    hi.Name             = "ESPHighlight"
    hi.Adornee          = egg
    hi.FillColor        = Color3.fromRGB(255,200,0)
    hi.OutlineColor     = Color3.new(1,1,1)
    hi.FillTransparency = 0.7
    hi.DepthMode        = Enum.HighlightDepthMode.AlwaysOnTop
end

local function removeEggESP(egg)
    if egg:FindFirstChild("PetBillboard", true) then
        egg:FindFirstChild("PetBillboard", true):Destroy()
    end
    if egg:FindFirstChild("ESPHighlight") then
        egg.ESPHighlight:Destroy()
    end
end

-- Collect nearby eggs
local function getPlayerGardenEggs(radius)
    local t = {}
    local char = player.Character or player.CharacterAdded:Wait()
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return t end
    for _,m in ipairs(Workspace:GetDescendants()) do
        if m:IsA("Model") and petTable[m.Name] then
            if (m:GetModelCFrame().Position - root.Position).Magnitude <= (radius or 60) then
                table.insert(t, m)
            end
        end
    end
    return t
end

-- Initialize eggs
local function initializeEggs()
    for _,egg in ipairs(getPlayerGardenEggs(60)) do
        local pick   = petTable[egg.Name][math.random(#petTable[egg.Name])]
        local weight = getBiasedRandom()
        eggDataMap[egg] = { petName = pick, weight = weight }
        applyEggESP(egg, pick, weight)
    end
end

-- Randomize
local function randomizeNearbyEggs()
    for _,egg in ipairs(getPlayerGardenEggs(60)) do
        local data = eggDataMap[egg]
        if isEggReady(egg) then
            local pick   = petTable[egg.Name][math.random(#petTable[egg.Name])]
            local weight = getBiasedRandom()
            data = { petName = pick, weight = weight }
            eggDataMap[egg] = data
        end
        applyEggESP(egg, data.petName, data.weight)
    end
end

-- Flash effect
local function flashEffect(btn)
    local bg, txt = btn.BackgroundColor3, btn.TextColor3
    for _=1,3 do
        btn.BackgroundColor3, btn.TextColor3 = Color3.new(1,1,1), Color3.fromRGB(50,50,50)
        wait(0.05)
        btn.BackgroundColor3, btn.TextColor3 = bg, txt
        wait(0.05)
    end
end

-- Countdown & reroll
local function countdownAndRandomize()
    isBusy = true
    randomizeBtn.AutoButtonColor, toggleBtn.AutoButtonColor = false, false
    for i=10,1,-1 do
        randomizeBtn.Text = ("🎲 Rerolling… %02ds"):format(i)
        wait(1)
    end
    flashEffect(randomizeBtn)
    randomizeNearbyEggs()
    randomizeBtn.Text, randomizeBtn.AutoButtonColor = "🎲 Reroll Eggs", true
    toggleBtn.AutoButtonColor = true
    isBusy = false
end

-- 🌿 GUI Setup (smaller, scale-based)
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "PremiumPetHatchGui"
gui.ZIndexBehavior = Enum.ZIndexBehavior.Global

local frame = Instance.new("Frame", gui)
frame.AnchorPoint = Vector2.new(0.5,0.5)
frame.Position    = UDim2.new(0.5,0,0.5,0)
frame.Size        = UDim2.new(0.25,0,0.40,0)  -- 25% width, 40% height
frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
frame.BackgroundTransparency = 0.1
Instance.new("UICorner", frame).CornerRadius = UDim.new(0,20)

local stroke = Instance.new("UIStroke", frame)
stroke.Thickness       = 2
stroke.Color           = Color3.fromRGB(212,175,55)
stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

-- Title bar
local titleBar = Instance.new("Frame", frame)
titleBar.Size             = UDim2.new(1,0,0,40)
titleBar.Position         = UDim2.new(0,0,0,0)
titleBar.BackgroundColor3 = Color3.fromRGB(45,45,45)
titleBar.Active           = true
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0,20)

local title = Instance.new("TextLabel", titleBar)
title.Size                   = UDim2.new(1,0,1,0)
title.BackgroundTransparency = 1
title.Text                   = "✨ Egg Randomizer"
title.Font                   = Enum.Font.GothamBold
title.TextSize               = 18
title.TextColor3             = Color3.fromRGB(255,215,0)
title.AnchorPoint            = Vector2.new(0.5,0.5)
title.Position               = UDim2.new(0.5,0,0.5,0)

-- Dragging
do
    local dragging, dragInput, dragStart, startPos = false, nil, nil, nil
    titleBar.InputBegan:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then
            dragging, dragStart, startPos = true, inp.Position, frame.Position
            inp.Changed:Connect(function()
                if inp.UserInputState==Enum.UserInputState.End then dragging=false end
            end)
        end
    end)
    titleBar.InputChanged:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseMovement or inp.UserInputType==Enum.UserInputType.Touch then
            dragInput = inp
        end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if dragging and inp==dragInput then
            local delta = inp.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset+delta.X,
                startPos.Y.Scale, startPos.Y.Offset+delta.Y
            )
        end
    end)
end

-- Button factory (fixed offsets)
local function createBtn(text, yScale)
    local cont = Instance.new("Frame", frame)
    cont.Size     = UDim2.new(1,-20,0,30)
    cont.Position = UDim2.new(0,10,yScale,0)
    cont.BackgroundTransparency = 1
    local btn = Instance.new("TextButton", cont)
    btn.Size            = UDim2.new(1,0,1,0)
    btn.BackgroundColor3= Color3.fromRGB(240,240,240)
    btn.BorderSizePixel = 0
    btn.Font            = Enum.Font.GothamSemibold
    btn.TextSize        = 16
    btn.Text            = text
    btn.TextColor3      = Color3.fromRGB(30,30,30)
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,8)
    local grad = Instance.new("UIGradient", btn)
    grad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0,Color3.new(1,1,1)),
        ColorSequenceKeypoint.new(1,Color3.fromRGB(220,220,220)),
    })
    btn.MouseEnter:Connect(function() btn.BackgroundColor3=Color3.fromRGB(212,175,55) end)
    btn.MouseLeave:Connect(function() btn.BackgroundColor3=Color3.fromRGB(240,240,240) end)
    return btn
end

randomizeBtn = createBtn("🎲 Reroll Eggs",    0.25)
toggleBtn    = createBtn("👁️ ESP: ON",        0.45)
autoBtn      = createBtn("🔁 Auto Reroll: OFF", 0.65)

randomizeBtn.MouseButton1Click:Connect(function() if not isBusy then countdownAndRandomize() end end)
toggleBtn.MouseButton1Click:Connect(function()
    if not isBusy then
        espEnabled = not espEnabled
        toggleBtn.Text = espEnabled and "👁️ ESP: ON" or "👁️ ESP: OFF"
        for egg,data in pairs(eggDataMap) do
            if espEnabled then applyEggESP(egg,data.petName,data.weight) else removeEggESP(egg) end
        end
    end
end)
autoBtn.MouseButton1Click:Connect(function()
    autoRunning = not autoRunning
    autoBtn.Text = autoRunning and "🔁 Auto Reroll: ON" or "🔁 Auto Reroll: OFF"
    coroutine.wrap(function()
        while autoRunning do
            if not isBusy then countdownAndRandomize() end
            for _,d in pairs(eggDataMap) do
                if bestPets[d.petName] then autoRunning=false; autoBtn.Text="🔁 Auto Reroll: OFF"; break end
            end
            wait(1)
        end
    end)()
end)

initializeEggs()

-- Credit
local credit = Instance.new("TextLabel", frame)
credit.Size                   = UDim2.new(1,0,0,18)
credit.Position               = UDim2.new(0,0,0.90,0)
credit.BackgroundTransparency = 1
credit.Text                   = "Made by - LuckyEgg"
credit.Font                   = Enum.Font.Gotham
credit.TextSize               = 14
credit.TextColor3             = Color3.fromRGB(255,215,0)

