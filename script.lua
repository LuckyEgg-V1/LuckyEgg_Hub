-- [ SERVICES ]
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- [ PET TABLE ]
local petTable = {
	["Common Egg"] = {"Dog","Bunny","Golden Lab"},
	["Uncommon Egg"] = {"Chicken","Black Bunny","Cat","Deer"},
	["Rare Egg"] = {"Pig","Monkey","Rooster","Orange Tabby","Spotted Deer"},
	["Legendary Egg"] = {"Cow","Polar Bear","Sea Otter","Turtle","Silver Monkey"},
	["Mythical Egg"] = {"Grey Mouse","Brown Mouse","Squirrel","Red Giant Ant"},
	["Bug Egg"] = {"Snail","Caterpillar","Giant Ant","Praying Mantis"},
	["Night Egg"] = {"Frog","Hedgehog","Mole","Echo Frog","Night Owl"},
	["Bee Egg"] = {"Bee","Honey Bee","Bear Bee","Petal Bee"},
	["Anti Bee Egg"] = {"Wasp","Moth","Tarantula Hawk"},
	["Oasis Egg"] = {"Meerkat","Sand Snake","Axolotl"},
	["Paradise Egg"] = {"Ostrich","Peacock","Capybara"},
	["Dinosaur Egg"] = {"Raptor","Triceratops","Stegosaurus"},
	["Primal Egg"] = {"Parasaurolophus","Iguanodon","Pachycephalosaurus"},
	["Zen Egg"] = {"Shiba Inu","Tanuki","Kappa"},
}

-- [ STATE ]
local espEnabled = true
local truePetMap = {}
local autoRunning = false

-- [ GLITCH EFFECT ]
local function glitchLabelEffect(label)
	coroutine.wrap(function()
		local original = label.TextColor3
		for _ = 1, 2 do
			label.TextColor3 = Color3.new(1, 0, 0)
			wait(0.07)
			label.TextColor3 = original
			wait(0.07)
		end
	end)()
end

-- [ ESP LOGIC ]
local function removeEggESP(eggModel)
	for _, v in ipairs(eggModel:GetDescendants()) do
		if v.Name == "PetBillboard" or v.Name == "ESPHighlight" then
			v:Destroy()
		end
	end
end

local function applyEggESP(eggModel, petName)
	removeEggESP(eggModel)
	if not espEnabled then return end

	local basePart = eggModel:FindFirstChildWhichIsA("BasePart")
	if not basePart then return end

	local ready = true
	local hatchTime = eggModel:FindFirstChild("HatchTime")
	local readyFlag = eggModel:FindFirstChild("ReadyToHatch")

	if (hatchTime and hatchTime.Value > 0) or (readyFlag and not readyFlag.Value) then
		ready = false
	end

	local gui = Instance.new("BillboardGui", basePart)
	gui.Name = "PetBillboard"
	gui.Size = UDim2.new(0, 260, 0, 50)
	gui.StudsOffset = Vector3.new(0, 4.5, 0)
	gui.AlwaysOnTop = true
	gui.MaxDistance = 500

	local lbl = Instance.new("TextLabel", gui)
	lbl.Size = UDim2.new(1, 0, 1, 0)
	lbl.BackgroundTransparency = 1
	lbl.TextScaled = true
	lbl.Font = Enum.Font.FredokaOne
	lbl.Text = eggModel.Name.." | "..petName..(ready and "" or " (Not Ready)")
	lbl.TextColor3 = ready and Color3.new(1,1,1) or Color3.fromRGB(160,160,160)
	lbl.TextStrokeTransparency = ready and 0 or 0.5

	glitchLabelEffect(lbl)

	local hl = Instance.new("Highlight", eggModel)
	hl.Name = "ESPHighlight"
	hl.FillColor = Color3.fromRGB(255, 200, 0)
	hl.OutlineColor = Color3.new(1, 1, 1)
	hl.FillTransparency = 0.7
	hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	hl.Adornee = eggModel
end

-- [ DETECTION ]
local function getNearbyEggs(radius)
	local eggs = {}
	local char = player.Character or player.CharacterAdded:Wait()
	local root = char:FindFirstChild("HumanoidRootPart")
	if not root then return eggs end

	for _, m in pairs(Workspace:GetDescendants()) do
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

-- [ RANDOMIZER ]
local function randomizeEggs()
	local eggs = getNearbyEggs(60)
	for _, e in ipairs(eggs) do
		truePetMap[e] = petTable[e.Name][math.random(#petTable[e.Name])]
		applyEggESP(e, truePetMap[e])
	end
	print("Randomized", #eggs, "eggs.")
end

-- [ UI FLASH ]
local function flash(btn)
	local orig = btn.BackgroundColor3
	for _ = 1, 3 do
		btn.BackgroundColor3 = Color3.new(1,1,1)
		wait(0.05)
		btn.BackgroundColor3 = orig
		wait(0.05)
	end
end

-- [ TIMER ]
local function countdown(btn)
	for i = 10, 1, -1 do
		btn.Text = "🎲 in: "..i
		wait(1)
	end
	flash(btn)
	randomizeEggs()
	btn.Text = "🎲 Randomize Pets"
end

-- [ GUI SETUP ]
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "PetHatchGui"

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 280, 0, 330)
frame.Position = UDim2.new(0, 20, 0, 80)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.BackgroundTransparency = 0.1
frame.BorderSizePixel = 0
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)
Instance.new("UIStroke", frame).Thickness = 1

-- [ TITLE BAR ]
local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 32)
title.BackgroundTransparency = 1
title.Text = "🥚 EggHub - Pet Randomizer ✨"
title.Font = Enum.Font.FredokaOne
title.TextSize = 22
title.TextColor3 = Color3.new(1, 1, 1)

-- [ DRAG LOGIC ]
local dragBtn = Instance.new("TextButton", title)
dragBtn.Size = UDim2.new(1, 1, 1, 0)
dragBtn.BackgroundTransparency = 1
dragBtn.Text = ""
local dragging, offset

dragBtn.MouseButton1Down:Connect(function()
	dragging = true
	offset = Vector2.new(mouse.X - frame.AbsolutePosition.X, mouse.Y - frame.AbsolutePosition.Y)
end)
dragBtn.MouseButton1Up:Connect(function()
	dragging = false
end)
RunService.RenderStepped:Connect(function()
	if dragging then
		frame.Position = UDim2.new(0, mouse.X - offset.X, 0, mouse.Y - offset.Y)
	end
end)

-- [ BUTTON FACTORY ]
local function makeBtn(posY, text)
	local b = Instance.new("TextButton", frame)
	b.Size = UDim2.new(1, -20, 0, 40)
	b.Position = UDim2.new(0, 10, 0, posY)
	b.Text = text
	b.Font = Enum.Font.FredokaOne
	b.TextSize = 16
	b.TextColor3 = Color3.new(1, 1, 1)
	b.BackgroundColor3 = Color3.fromRGB(60, 60, 100)
	Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
	Instance.new("UIStroke", b).Thickness = 1
	return b
end

-- [ BUTTONS ]
local btnRandom = makeBtn(50, "🎲 Randomize Pets")
btnRandom.MouseButton1Click:Connect(function() countdown(btnRandom) end)

local btnESP = makeBtn(100, "👁️ ESP: ON")
btnESP.MouseButton1Click:Connect(function()
	espEnabled = not espEnabled
	btnESP.Text = espEnabled and "👁️ ESP: ON" or "👁️ ESP: OFF"
	for _, e in ipairs(getNearbyEggs(60)) do
		if espEnabled then applyEggESP(e, truePetMap[e])
		else removeEggESP(e) end
	end
end)

local btnAuto = makeBtn(150, "🔁 Auto Randomize: OFF")
btnAuto.MouseButton1Click:Connect(function()
	autoRunning = not autoRunning
	btnAuto.Text = autoRunning and "🔁 Auto Randomize: ON" or "🔁 Auto Randomize: OFF"
	coroutine.wrap(function()
		while autoRunning do
			countdown(btnRandom)
			for _, pet in pairs(truePetMap) do
				if pet and ({["Raccoon"] = true, ["T-Rex"] = true, ["Queen Bee"] = true})[pet] then
					autoRunning = false
					btnAuto.Text = "🔁 Auto Randomize: OFF"
					return
				end
			end
			wait(1)
		end
	end)()
end)

local btnAge = makeBtn(200, "🕒 Load Pet Age 50 Script")
btnAge.MouseButton1Click:Connect(function()
	loadstring(game:HttpGet("https://raw.githubusercontent.com/ShiraInuba01/maomaoscripts/main/Lvl50Egg.txt"))()
end)

local btnMut = makeBtn(250, "🔬 Pet Mutation Finder")
btnMut.MouseButton1Click:Connect(function()
	loadstring(game:HttpGet("https://raw.githubusercontent.com/ShiraInuba01/maomaoscripts/main/PetMutationFinder.txt"))()
end)

-- [ CLOSE BUTTON ]
local btnClose = Instance.new("ImageButton", frame)
btnClose.Size = UDim2.new(0, 24, 0, 24)
btnClose.Position = UDim2.new(1, -28, 0, 4)
btnClose.Image = "rbxassetid://7733960981"

btnClose.BackgroundTransparency = 1
btnClose.MouseButton1Click:Connect(function() gui:Destroy() end)

-- [ CREDIT ]
local credit = Instance.new("TextLabel", frame)
credit.Size = UDim2.new(1, 0, 0, 18)
credit.Position = UDim2.new(0, 0, 1, -20)
credit.BackgroundTransparency = 1
credit.Text = "Made by - MaoMao"
credit.Font = Enum.Font.FredokaOne
credit.TextSize = 14
credit.TextColor3 = Color3.fromRGB(200, 200, 200)
