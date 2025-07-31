-- 🐾 Premium Pet Hatch Simulator: Luxe UI & Brighter Buttons
local Players          = game:GetService("Players")
local Workspace        = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")

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
local eggDataMap   = {}      -- maps each egg Model to { petName=string, weight=number }
local isBusy       = false
local autoRunning  = false
local bestPets     = {
    Raccoon=true, Dragonfly=true, ["Queen Bee"]=true, ["Disco Bee"]=true,
    ["Fennec Fox"]=true, Fox=true, ["Mimic Octopus"]=true,
    ["T-Rex"]=true, Spinosaurus=true, Kitsune=true
}

-- ✨ Glitch label effect (gold flash)
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
    local function buildWeightedTable(startVal, endVal, biasFactor)
        local values = {}
        for i = math.floor(startVal * 100), math.floor(endVal * 100) do
            local val = i / 100
            local weight = math.exp(-((val - startVal) * biasFactor))
            local count = math.floor(weight * 100)
            for _ = 1, count do
                table.insert(values, val)
            end
        end
        return values
    end
    local normalRange = buildWeightedTable(0.80, 2.20, 4)
    local rareRange   = buildWeightedTable(2.21, 10.00, 1.5)
    if math.random(100) == 1 then
        return rareRange[math.random(#rareRange)]
    else
        return normalRange[math.random(#normalRange)]
    end
end

-- Determine if an egg is ready to reroll
local function isEggReady(egg)
    local rf = egg:FindFirstChild("ReadyToHatch")
    if rf and rf:IsA("BoolValue") then
        return rf.Value
    end
    local ht = egg:FindFirstChild("HatchTime")
    if ht and ht:IsA("NumberValue") then
        return ht.Value <= 0.05
    end
    return true
end

-- 🖼 ESP visuals
local function applyEggESP(egg, petName, weight)
    local oldBill = egg:FindFirstChild("PetBillboard", true)
    if oldBill then oldBill:Destroy() end
    if egg:FindFirstChild("ESPHighlight") then egg.ESPHighlight:Destroy() end
    if not espEnabled then return end

    local base = egg:FindFirstChildWhichIsA("BasePart")
    if not base then return end

    local ready = isEggReady(egg)
    local gui = Instance.new("BillboardGui")
    gui.Name           = "PetBillboard"
    gui.Adornee        = base
    gui.Parent         = base
    gui.Size           = UDim2.new(0, 270, 0, 50)
    gui.StudsOffset    = Vector3.new(0, 4.5, 0)
    gui.AlwaysOnTop    = true
    gui.MaxDistance    = 500

    local lbl = Instance.new("TextLabel", gui)
    lbl.Size                    = UDim2.new(1, 0, 1, 0)
    lbl.BackgroundTransparency  = 1
    lbl.Text                   = string.format(
        "%s | %s%s [%0.2f kg]",
        egg.Name,
        petName,
        ready and "" or " (Not Ready)",
        weight
    )
    lbl.TextColor3            = ready and Color3.new(1, 1, 1) or Color3.fromRGB(160, 160, 160)
    lbl.TextStrokeTransparency = ready and 0 or 0.5
    lbl.TextScaled            = true
    lbl.Font                  = Enum.Font.FredokaOne

    glitchLabelEffect(lbl)

    local hi = Instance.new("Highlight", egg)
    hi.Name             = "ESPHighlight"
    hi.Adornee          = egg
    hi.FillColor        = Color3.fromRGB(255, 200, 0)
    hi.OutlineColor     = Color3.new(1, 1, 1)
    hi.FillTransparency = 0.7
    hi.DepthMode        = Enum.HighlightDepthMode.AlwaysOnTop
end

local function removeEggESP(egg)
    local oldBill = egg:FindFirstChild("PetBillboard", true)
    if oldBill then oldBill:Destroy() end
    if egg:FindFirstChild("ESPHighlight") then egg.ESPHighlight:Destroy() end
end

-- 🌱 Egg collection
local function getPlayerGardenEggs(radius)
    local out = {}
    local char = player.Character or player.CharacterAdded:Wait()
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return out end
    for _, m in pairs(Workspace:GetDescendants()) do
        if m:IsA("Model") and petTable[m.Name] then
            if (m:GetModelCFrame().Position - root.Position).Magnitude <= (radius or 60) then
                table.insert(out, m)
            end
        end
    end
    return out
end

-- Initialize all eggs with a starting pick + weight and ESP
local function initializeEggs()
    for _, egg in ipairs(getPlayerGardenEggs(60)) do
        local pick   = petTable[egg.Name][math.random(#petTable[egg.Name])]
        local weight = getBiasedRandom()
        eggDataMap[egg] = { petName = pick, weight = weight }
        applyEggESP(egg, pick, weight)
    end
end

-- 🌟 Randomize only ready eggs, but ESP all
local function randomizeNearbyEggs()
    for _, egg in ipairs(getPlayerGardenEggs(60)) do
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

-- ⚡ Flash effect
local function flashEffect(btn)
    local bg, txt = btn.BackgroundColor3, btn.TextColor3
    for _ = 1, 3 do
        btn.BackgroundColor3, btn.TextColor3 = Color3.new(1, 1, 1), Color3.fromRGB(50, 50, 50)
        wait(0.05)
        btn.BackgroundColor3, btn.TextColor3 = bg, txt
        wait(0.05)
    end
end

-- ⏳ Countdown & lock
local function countdownAndRandomize()
    isBusy = true
    randomizeBtn.AutoButtonColor, toggleBtn.AutoButtonColor = false, false
    for i = 10, 1, -1 do
        randomizeBtn.Text = string.format("🎲 Rerolling… %02ds", i)
        wait(1)
    end
    flashEffect(randomizeBtn)
    randomizeNearbyEggs()
    randomizeBtn.Text, randomizeBtn.AutoButtonColor = "🎲 Reroll Eggs", true
    toggleBtn.AutoButtonColor = true
    isBusy = false
end

-- 🌿 Luxe GUI Setup
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name           = "PremiumPetHatchGui"
gui.ZIndexBehavior = Enum.ZIndexBehavior.Global

local frame = Instance.new("Frame", gui)
frame.Size              = UDim2.new(0, 320, 0, 360)
frame.Position          = UDim2.new(0.5, -160, 0.5, -180)
frame.BackgroundColor3  = Color3.fromRGB(30, 30, 30)
frame.BackgroundTransparency = 0.1
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 20)

local stroke = Instance.new("UIStroke", frame)
stroke.Thickness         = 2
stroke.Color             = Color3.fromRGB(212, 175, 55)
stroke.ApplyStrokeMode   = Enum.ApplyStrokeMode.Border

local titleBar = Instance.new("Frame", frame)
titleBar.Size               = UDim2.new(1, 0, 0, 50)
titleBar.BackgroundColor3   = Color3.fromRGB(45, 45, 45)
titleBar.Active             = true
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 20)

local title = Instance.new("TextLabel", titleBar)
title.Size                  = UDim2.new(1, 0, 1, 0)
title.BackgroundTransparency = 1
title.Text                 = "✨ Egg Randomizer"
title.Font                 = Enum.Font.GothamBold
title.TextSize             = 24
title.TextColor3           = Color3.fromRGB(255, 215, 0)
title.AnchorPoint          = Vector2.new(0.5, 0.5)
title.Position             = UDim2.new(0.5, 0, 0.5, 0)

-- ✋ Dragging functionality (mouse and touch)
local dragging = false
local dragInput, dragStart, startPos

titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        dragging   = true
        dragStart  = input.Position
        startPos   = frame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

titleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement
    or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

local function createPremiumButton(text, yOffset)
    local container = Instance.new("Frame", frame)
    container.Size = UDim2.new(0.92, 0, 0.13, 0)           -- 92% width, 13% height per button
    container.Position = UDim2.new(0.04, 0, yScale, 0)     -- yScale = 0.25, 0.40, 0.55... for button stacking
    container.BackgroundTransparency = 1

    local btn = Instance.new("TextButton", container)
    btn.Size            = UDim2.new(1, 0, 1, 0)
    btn.BackgroundColor3= Color3.fromRGB(240, 240, 240)
    btn.BorderSizePixel = 0
    btn.Font            = Enum.Font.GothamSemibold
    btn.TextSize        = 20
    btn.Text            = text
    btn.TextColor3      = Color3.fromRGB(30, 30, 30)
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,12)

    local grad = Instance.new("UIGradient", btn)
    grad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.new(1,1,1)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(220,220,220)),
    })

    btn.MouseEnter:Connect(function()
        btn.BackgroundColor3 = Color3.fromRGB(212,175,55)
    end)
    btn.MouseLeave:Connect(function()
        btn.BackgroundColor3 = Color3.fromRGB(240,240,240)
    end)

    return btn
end

randomizeBtn = createPremiumButton("🎲 Reroll Eggs",    80)
toggleBtn    = createPremiumButton("👁️ ESP: ON",        150)
autoBtn      = createPremiumButton("🔁 Auto Reroll: OFF", 220)

randomizeBtn.MouseButton1Click:Connect(function()
    if not isBusy then countdownAndRandomize() end
end)

toggleBtn.MouseButton1Click:Connect(function()
    if not isBusy then
        espEnabled = not espEnabled
        toggleBtn.Text = espEnabled and "👁️ ESP: ON" or "👁️ ESP: OFF"
        for egg, data in pairs(eggDataMap) do
            if espEnabled then
                applyEggESP(egg, data.petName, data.weight)
            else
                removeEggESP(egg)
            end
        end
    end
end)

autoBtn.MouseButton1Click:Connect(function()
    autoRunning = not autoRunning
    autoBtn.Text = autoRunning and "🔁 Auto Reroll: ON" or "🔁 Auto Reroll: OFF"
    coroutine.wrap(function()
        while autoRunning do
            if not isBusy then countdownAndRandomize() end
            for _, data in pairs(eggDataMap) do
                if bestPets[data.petName] then
                    autoRunning = false
                    autoBtn.Text = "🔁 Auto Reroll: OFF"
                    break
                end
            end
            wait(1)
        end
    end)()
end)

-- initialize on load
initializeEggs()

local credit = Instance.new("TextLabel", frame)
credit.Size                  = UDim2.new(1, 0, 0, 20)
credit.Position              = UDim2.new(0, 0, 1, -30)
credit.BackgroundTransparency= 1
credit.Text                  = "Made by - LuckyEgg"
credit.Font                  = Enum.Font.Gotham
credit.TextSize              = 16
credit.TextColor3            = Color3.fromRGB(255,215,0)
