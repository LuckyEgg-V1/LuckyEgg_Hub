-- Professional UI Enhancement for Pet Hatch Simulator
-- Core functionality unchanged; design and layout updated

local Players      = game:GetService("Players")
local Workspace    = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local UserInput    = game:GetService("UserInputService")
local RunService   = game:GetService("RunService")
local player       = Players.LocalPlayer
local mouse        = player:GetMouse()

-- Egg → Possible Pets Mapping (unchanged)
local petTable = {
    ["Common Egg"]    = {"Dog","Bunny","Golden Lab"},
    ["Uncommon Egg"]  = {"Chicken","Black Bunny","Cat","Deer"},
    ["Rare Egg"]      = {"Pig","Monkey","Rooster","Orange Tabby","Spotted Deer"},
    ["Legendary Egg"] = {"Cow","Polar Bear","Sea Otter","Turtle","Silver Monkey"},
    ["Mythical Egg"]  = {"Grey Mouse","Brown Mouse","Squirrel","Red Giant Ant"},
    ["Bug Egg"]       = {"Snail","Caterpillar","Giant Ant","Praying Mantis"},
    ["Night Egg"]     = {"Frog","Hedgehog","Mole","Echo Frog","Night Owl"},
    ["Bee Egg"]       = {"Bee","Honey Bee","Bear Bee","Petal Bee"},
    ["Anti Bee Egg"]  = {"Wasp","Moth","Tarantula Hawk"},
    ["Oasis Egg"]     = {"Meerkat","Sand Snake","Axolotl"},
    ["Paradise Egg"]  = {"Ostrich","Peacock","Capybara"},
    ["Dinosaur Egg"]  = {"Raptor","Triceratops","Stegosaurus"},
    ["Primal Egg"]    = {"Parasaurolophus","Iguanodon","Pachycephalosaurus","Spinosaurus","Dilophosaurus"},
    ["Zen Egg"]       = {"Shiba Inu","Tanuki","Kappa","Kitsune"},
}

local espEnabled  = true
local truePetMap  = {}
local autoRunning = false

-- Label glitch effect
local function glitchLabelEffect(label)
    coroutine.wrap(function()
        local original = label.TextColor3
        for i=1,2 do
            label.TextColor3 = Color3.new(1,0,0)
            wait(0.07)
            label.TextColor3 = original
            wait(0.07)
        end
    end)()
end

-- Remove existing ESP visuals
local function removeEggESP(eggModel)
    for _,v in ipairs(eggModel:GetDescendants()) do
        if v.Name == "PetBillboard" or v.Name == "ESPHighlight" then
            v:Destroy()
        end
    end
end

-- Apply ESP labels and highlights to an egg
local function applyEggESP(eggModel, petName)
    removeEggESP(eggModel)
    if not espEnabled then return end
    local basePart = eggModel:FindFirstChildWhichIsA("BasePart")
    if not basePart then return end

    -- Determine hatch readiness
    local ready = true
    local hatchTime = eggModel:FindFirstChild("HatchTime")
    local readyFlag = eggModel:FindFirstChild("ReadyToHatch")
    if (hatchTime and hatchTime.Value > 0) or (readyFlag and not readyFlag.Value) then
        ready = false
    end

    -- Billboard GUI
    local gui = Instance.new("BillboardGui", basePart)
    gui.Name = "PetBillboard"
    gui.Size = UDim2.new(0, 270, 0, 50)
    gui.StudsOffset = Vector3.new(0, 4.5, 0)
    gui.AlwaysOnTop = true
    gui.MaxDistance = 500

    local lbl = Instance.new("TextLabel", gui)
    lbl.Size = UDim2.new(1, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.TextScaled = true
    lbl.Font = Enum.Font.FredokaOne
    lbl.Text = eggModel.Name .. " | " .. petName .. (ready and "" or " (Not Ready)")
    lbl.TextColor3 = ready and Color3.new(1,1,1) or Color3.fromRGB(160,160,160)
    lbl.TextStrokeTransparency = ready and 0 or 0.5
    glitchLabelEffect(lbl)

    -- Highlight
    local hl = Instance.new("Highlight", eggModel)
    hl.Name = "ESPHighlight"
    hl.FillColor = Color3.fromRGB(255,200,0)
    hl.OutlineColor = Color3.new(1,1,1)
    hl.FillTransparency = 0.7
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Adornee = eggModel
end

-- Get eggs within radius of player
local function getNearbyEggs(radius)
    local eggs = {}
    local char = player.Character or player.CharacterAdded:Wait()
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return eggs end
    for _,m in pairs(Workspace:GetDescendants()) do
        if m:IsA("Model") and petTable[m.Name] then
            local dist = (m:GetModelCFrame().Position - root.Position).Magnitude
            if dist <= (radius or 60) then
                truePetMap[m] = truePetMap[m] or petTable[m][math.random(#petTable[m])]
                table.insert(eggs, m)
            end
        end
    end
    return eggs
end

-- Randomize pet assignments
local function randomizeEggs()
    local eggs = getNearbyEggs(60)
    for _,e in ipairs(eggs) do
        truePetMap[e] = petTable[e.Name][math.random(#petTable[e.Name])]
        applyEggESP(e, truePetMap[e])
    end
    print("Randomized", #eggs, "eggs.")
end

-- Button flash effect
local function flash(btn)
    local orig = btn.BackgroundColor3
    for i=1,3 do
        btn.BackgroundColor3 = Color3.new(1,1,1)
        wait(0.05)
        btn.BackgroundColor3 = orig
        wait(0.05)
    end
end

-- Countdown timer for randomize button
local function countdown(btn)
    for i=10,1,-1 do
        btn.Text = "🎲 in: "..i
        wait(1)
    end
    flash(btn)
    randomizeEggs()
    btn.Text = "🎲 Randomize Pets"
end

-- GUI Setup - Professional Dark Theme & Layout
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "PetHatchGui"

-- Main container
local frame = Instance.new("Frame", gui)
frame.Name = "MainFrame"
frame.AnchorPoint = Vector2.new(0,0)
frame.Position = UDim2.new(0, 20, 0, 80)
frame.Size = UDim2.new(0, 280, 0, 380)
frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
frame.BorderSizePixel = 0
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)
local frameStroke = Instance.new("UIStroke", frame)
frameStroke.Color = Color3.fromRGB(50,50,50)
frameStroke.Thickness = 1

-- Padding & Layout for consistent spacing
local padding = Instance.new("UIPadding", frame)
padding.PaddingTop = UDim.new(0, 8)
padding.PaddingBottom = UDim.new(0,8)
padding.PaddingLeft = UDim.new(0,8)
padding.PaddingRight = UDim.new(0,8)

local layout = Instance.new("UIListLayout", frame)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0, 6)

-- Title Bar
local titleBar = Instance.new("Frame", frame)
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1,0,0,36)
titleBar.BackgroundColor3 = Color3.fromRGB(40,40,40)
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 12)

-- Gradient Accent
local grad = Instance.new("UIGradient", titleBar)
grad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(98, 0, 238)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(55, 0, 179)),
})

-- Title Text
local title = Instance.new("TextLabel", titleBar)
title.AnchorPoint = Vector2.new(0.5,0.5)
title.Position = UDim2.new(0.5,0,0.5,0)
title.Size = UDim2.new(0.8,0,1,0)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 20
title.TextColor3 = Color3.fromRGB(255,255,255)
title.Text = "🥚 EggHub - Pet Randomizer"

-- Drag overlay
local dragBtn = Instance.new("TextButton", titleBar)
dragBtn.Size = UDim2.new(1,0,1,0)
dragBtn.BackgroundTransparency = 1
dragBtn.Text = ""

local dragging, offset

dragBtn.MouseButton1Down:Connect(function()
    dragging = true
    offset = Vector2.new(mouse.X - frame.AbsolutePosition.X, mouse.Y - frame.AbsolutePosition.Y)
end)

dragBtn.MouseButton1Up:Connect(function() dragging = false end)
RunService.RenderStepped:Connect(function()
    if dragging then
        frame.Position = UDim2.new(0, mouse.X - offset.X, 0, mouse.Y - offset.Y)
    end
end)

-- Button Factory with hover effects
local function makeBtn(text)
    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(1,0,0,40)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 16
    btn.Text = text
    btn.BackgroundColor3 = Color3.fromRGB(45,45,45)
    btn.TextColor3 = Color3.fromRGB(230,230,230)

    local corner = Instance.new("UICorner", btn)
    corner.CornerRadius = UDim.new(0,8)

    local stroke = Instance.new("UIStroke", btn)
    stroke.Color = Color3.fromRGB(70,70,70)
    stroke.Thickness = 1

    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(60,60,60)}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(45,45,45)}):Play()
    end)

    return btn
end

-- Buttons and Bindings
local btnRandom = makeBtn("🎲 Randomize Pets")
btnRandom.MouseButton1Click:Connect(function() countdown(btnRandom) end)

local btnESP = makeBtn("👁️ ESP: ON")
btnESP.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    btnESP.Text = espEnabled and "👁️ ESP: ON" or "👁️ ESP: OFF"
    for _,e in ipairs(getNearbyEggs(60)) do
        if espEnabled then applyEggESP(e, truePetMap[e]) else removeEggESP(e) end
    end
end)

local btnAuto = makeBtn("🔁 Auto Randomize: OFF")
btnAuto.MouseButton1Click:Connect(function()
    autoRunning = not autoRunning
    btnAuto.Text = autoRunning and "🔁 Auto Randomize: ON" or "🔁 Auto Randomize: OFF"
    coroutine.wrap(function()
        while autoRunning do
            countdown(btnRandom)
            for _,pet in pairs(truePetMap) do
                if pet and ({["Raccoon"]=true,["T-Rex"]=true,["Queen Bee"]=true})[pet] then
                    autoRunning = false
                    btnAuto.Text = "🔁 Auto Randomize: OFF"
                    return
                end
            end
            wait(1)
        end
    end)()
end)

local btnAge = makeBtn("🕒 Load Pet Age 50 Script")
btnAge.MouseButton1Click:Connect(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/ShiraInuba01/maomaoscripts/main/Lvl50Egg.txt"))()
end)

local btnMut = makeBtn("🔬 Pet Mutation Finder")
btnMut.MouseButton1Click:Connect(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/ShiraInuba01/maomaoscripts/main/PetMutationFinder.txt"))()
end)

-- Close Button
local btnClose = Instance.new("ImageButton", titleBar)
btnClose.AnchorPoint = Vector2.new(1,0)
btnClose.Position = UDim2.new(1,-4,0,4)
btnClose.Size = UDim2.new(0,24,0,24)
btnClose.Image = "rbxassetid://3926305904"
btnClose.BackgroundTransparency = 1
btnClose.MouseButton1Click:Connect(function() gui:Destroy() end)

-- Credit Footer
local credit = Instance.new("TextLabel", frame)
credit.Size = UDim2.new(1,0,0,18)
credit.BackgroundTransparency = 1
credit.Font = Enum.Font.Gotham
credit.TextSize = 12
credit.Text = "Made by - MaoMao"
credit.TextColor3 = Color3.fromRGB(150,150,150)

-- End of script: All functions and UI are fully implemented, professionally styled.
