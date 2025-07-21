
-- Polished Pet Hatch Simulator GUI Script
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

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
    ["Zen Egg"]       = { "Shiba Inu", "Tanuki", "Kappa" },
}

local espEnabled = true
local truePetMap = {}

-- Utility: create rounded button with hover tween
local function createButton(parent, text, positionY)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -24, 0, 40)
    btn.Position = UDim2.new(0, 12, 0, positionY)
    btn.BackgroundColor3 = Color3.fromRGB(75, 45, 100)
    btn.AutoButtonColor = false
    btn.Text = text
    btn.Font = Enum.Font.FredokaOne
    btn.TextSize = 18
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Parent = parent
    -- Rounded corners
    local corner = Instance.new("UICorner", btn)
    corner.CornerRadius = UDim.new(0, 8)
    -- Outline stroke
    local stroke = Instance.new("UIStroke", btn)
    stroke.Thickness = 1
    stroke.Transparency = 0.6
    -- Hover effect
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(95, 60, 120)}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(75, 45, 100)}):Play()
    end)
    return btn
end

-- Glitch text effect
local function glitchLabel(label)
    coroutine.wrap(function()
        local original = label.TextColor3
        for i = 1, 3 do
            label.TextColor3 = Color3.new(1, 0.2, 0.2)
            wait(0.05)
            label.TextColor3 = original
            wait(0.05)
        end
    end)()
end

-- ESP functions (unchanged core logic)
local function applyEggESP(eggModel, petName)
    -- [existing implementation with glitchLabel]
end
local function removeEggESP(eggModel)
    -- [existing implementation]
end
local function getPlayerGardenEggs(radius)
    -- [existing implementation]
end
local function randomizeNearbyEggs()
    -- [existing implementation]
end
local function countdownAndRandomize(button)
    -- [existing implementation]
end

-- 🎨 GUI Setup
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "PetHatchGui"
screenGui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 280, 0, 340)
frame.Position = UDim2.new(0, 30, 0, 100)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
frame.BorderSizePixel = 0
frame.Parent = screenGui

-- Background gradient
local gradient = Instance.new("UIGradient", frame)
gradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 40, 55)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(25, 25, 35))
})

gx
local cornerFrame = Instance.new("UICorner", frame)
cornerFrame.CornerRadius = UDim.new(0, 12)

-- Padding & Layout
local padding = Instance.new("UIPadding", frame)
padding.PaddingTop = UDim.new(0, 35)
padding.PaddingBottom = UDim.new(0, 12)
padding.PaddingLeft = UDim.new(0, 12)
padding.PaddingRight = UDim.new(0, 12)

local layout = Instance.new("UIListLayout", frame)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0, 10)

-- Title Bar
local titleBar = Instance.new("Frame", frame)
titleBar.Size = UDim2.new(1, 0, 0, 30)
titleBar.BackgroundTransparency = 1

local title = Instance.new("TextLabel", titleBar)
title.Size = UDim2.new(1, 0, 1, 0)
title.BackgroundTransparency = 1
title.Text = "🐾 Pet Randomizer ✨"
title.Font = Enum.Font.FredokaOne
title.TextSize = 20
title.TextColor3 = Color3.fromRGB(255, 255, 255)

titleBar.LayoutOrder = 1

-- Drag handling
local dragging, dragOffset
titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragOffset = input.Position - Vector2.new(frame.AbsolutePosition)
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        frame.Position = UDim2.new(0, input.Position.X - dragOffset.X, 0, input.Position.Y - dragOffset.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- Buttons
local randomizeBtn = createButton(frame, "🎲 Randomize Pets", 0)
randomizeBtn.LayoutOrder = 2
randomizeBtn.MouseButton1Click:Connect(function() countdownAndRandomize(randomizeBtn) end)

local toggleBtn = createButton(frame, "👁️ ESP: ON", 0)
toggleBtn.LayoutOrder = 3
toggleBtn.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    toggleBtn.Text = espEnabled and "👁️ ESP: ON" or "👁️ ESP: OFF"
    for _, egg in pairs(getPlayerGardenEggs(60)) do
        if espEnabled then applyEggESP(egg, truePetMap[egg]) else removeEggESP(egg) end
    end
end)

local autoBtn = createButton(frame, "🔁 Auto Randomize: OFF", 0)
autoBtn.LayoutOrder = 4
-- [auto randomize logic]
\ nlocal loadAgeBtn = createButton(frame, "🕒 Load Pet Age 50 Script", 0)
loadAgeBtn.LayoutOrder = 5

local mutationBtn = createButton(frame, "🔬 Pet Mutation Finder", 0)
mutationBtn.LayoutOrder = 6

-- Credit Label
local credit = Instance.new("TextLabel", frame)
credit.Size = UDim2.new(1, 0, 0, 20)
credit.BackgroundTransparency = 1
credit.Text = "Made by - MaoMao"
credit.Font = Enum.Font.FredokaOne
credit.TextSize = 14
credit.TextColor3 = Color3.fromRGB(150, 150, 150)
credit.TextTransparency = 0.3
credit.TextXAlignment = Enum.TextXAlignment.Right
credit.LayoutOrder = 7
