--// MrDon Mobile Hub (Ultimate Fixed Noclip & Features)
--// Speed + Custom Speed Input + Noclip (Fixed) + Anti-Fall + ESP (10,000m Limit) + Fix Lag + Mobile GUI

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

--==================================================
-- SETTINGS
--==================================================

local speed = 50
local minSpeed = 5
local maxSpeed = 500
local MAX_ESP_DISTANCE = 10000

local speedEnabled = false
local noclipEnabled = false
local espEnabled = false
local fixLagLevel = 0

local FALL_LIMIT = -100
local lastSafeCFrame = nil
local espStorage = {}
local skeletonStorage = {}

--==================================================
-- GUI
--==================================================

local gui = Instance.new("ScreenGui")
gui.Name = "MrDonMobile"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = playerGui

--==================================================
-- OPEN BUTTON
--==================================================

local openButton = Instance.new("TextButton")
openButton.Size = UDim2.fromOffset(62, 62)
openButton.Position = UDim2.new(0, 15, 0.5, -31)
openButton.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
openButton.Text = "M"
openButton.TextColor3 = Color3.new(1, 1, 1)
openButton.TextSize = 25
openButton.Font = Enum.Font.GothamBold
openButton.Visible = false
openButton.Active = true
openButton.Parent = gui

local openCorner = Instance.new("UICorner")
openCorner.CornerRadius = UDim.new(1, 0)
openCorner.Parent = openButton

--==================================================
-- MAIN
--==================================================

local main = Instance.new("Frame")
main.Size = UDim2.fromOffset(320, 419)
main.Position = UDim2.new(0.5, -160, 0.5, -210)
main.BackgroundColor3 = Color3.fromRGB(18, 18, 23)
main.BorderSizePixel = 0
main.Active = true
main.Parent = gui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 18)
mainCorner.Parent = main

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(65, 65, 75)
stroke.Thickness = 1
stroke.Parent = main

--==================================================
-- HEADER
--==================================================

local header = Instance.new("TextButton")
header.Size = UDim2.new(1, -58, 0, 65)
header.Position = UDim2.fromOffset(0, 0)
header.BackgroundTransparency = 1
header.Text = ""
header.AutoButtonColor = false
header.Active = true
header.Parent = main

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -20, 0, 34)
title.Position = UDim2.fromOffset(15, 5)
title.BackgroundTransparency = 1
title.Text = "MrDon Mobile"
title.TextColor3 = Color3.new(1, 1, 1)
title.TextSize = 21
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.new(1, -20, 0, 22)
subtitle.Position = UDim2.fromOffset(15, 38)
subtitle.BackgroundTransparency = 1
subtitle.Text = "Speed • Noclip Fix • ESP • FixLag"
subtitle.TextColor3 = Color3.fromRGB(145, 145, 155)
subtitle.TextSize = 11
subtitle.Font = Enum.Font.Gotham
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.Parent = header

--==================================================
-- CLOSE
--==================================================

local close = Instance.new("TextButton")
close.Size = UDim2.fromOffset(42, 42)
close.Position = UDim2.new(1, -51, 0, 10)
close.BackgroundColor3 = Color3.fromRGB(38, 38, 46)
close.Text = "×"
close.TextColor3 = Color3.new(1, 1, 1)
close.TextSize = 27
close.Font = Enum.Font.GothamBold
close.Active = true
close.Parent = main

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 11)
closeCorner.Parent = close

--==================================================
-- BUTTON & INPUT CREATOR
--==================================================

local function makeButton(text, y)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -30, 0, 52)
    button.Position = UDim2.fromOffset(15, y)
    button.BackgroundColor3 = Color3.fromRGB(31, 31, 39)
    button.BorderSizePixel = 0
    button.Text = text
    button.TextColor3 = Color3.fromRGB(240, 240, 245)
    button.TextSize = 15
    button.Font = Enum.Font.GothamMedium
    button.AutoButtonColor = true
    button.Active = true
    button.Parent = main

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = button

    return button
end

local function makeTextBox(placeholder, y)
    local box = Instance.new("TextBox")
    box.Size = UDim2.new(1, -30, 0, 52)
    box.Position = UDim2.fromOffset(15, y)
    box.BackgroundColor3 = Color3.fromRGB(31, 31, 39)
    box.BorderSizePixel = 0
    box.Text = ""
    box.PlaceholderText = placeholder
    box.PlaceholderColor3 = Color3.fromRGB(115, 115, 125)
    box.TextColor3 = Color3.fromRGB(240, 240, 245)
    box.TextSize = 15
    box.Font = Enum.Font.GothamMedium
    box.ClearTextOnFocus = false
    box.Active = true
    box.Parent = main

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = box

    return box
end

--==================================================
-- CONTROLS & WIDGETS
--==================================================

local speedButton  = makeButton("⚡ SPEED : OFF", 75)
local speedInput   = makeTextBox("Nhập số Speed (VD: 50)", 137)
local noclipButton = makeButton("👻 NOCLIP : OFF", 199)
local espButton    = makeButton("👁️ ESP : OFF", 261)
local fixLagButton = makeButton("🚀 FIX LAG : OFF [OFF]", 323)

--==================================================
-- HUMANOID
--==================================================

local function getHumanoid()
    local character = player.Character
    if not character then return nil end
    return character:FindFirstChildOfClass("Humanoid")
end

--==================================================
-- SPEED LOGIC
--==================================================

local function applySpeed()
    if not speedEnabled then return end
    local humanoid = getHumanoid()
    if humanoid then
        humanoid.WalkSpeed = speed
    end
end

speedButton.Activated:Connect(function()
    speedEnabled = not speedEnabled
    local humanoid = getHumanoid()
    if speedEnabled then
        applySpeed()
    else
        if humanoid then humanoid.WalkSpeed = 16 end
    end
    speedButton.Text = "⚡ SPEED : " .. (speedEnabled and "ON" or "OFF")
end)

speedInput.FocusLost:Connect(function(enterPressed)
    local num = tonumber(speedInput.Text)
    if num then
        if num < minSpeed then num = minSpeed end
        if num > maxSpeed then num = maxSpeed end
        speed = num
        speedInput.Text = tostring(speed)
        applySpeed()
    else
        speedInput.Text = tostring(speed)
    end
end)

RunService.Heartbeat:Connect(function()
    if speedEnabled then applySpeed() end
end)

--==================================================
-- NOCLIP (FIXED & OPTIMIZED)
--==================================================

noclipButton.Activated:Connect(function()
    noclipEnabled = not noclipEnabled
    noclipButton.Text = "👻 NOCLIP : " .. (noclipEnabled and "ON" or "OFF")
end)

RunService.Stepped:Connect(function()
    local character = player.Character
    if not character then return end

    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            if noclipEnabled then
                part.CanCollide = false
            else
                -- Khôi phục lại trạng thái va chạm chuẩn của nhân vật Roblox
                if part.Name == "HumanoidRootPart" then
                    part.CanCollide = false
                else
                    part.CanCollide = true
                end
            end
        end
    end
end)

--==================================================
-- ANTI-FALL
--==================================================

RunService.Heartbeat:Connect(function()
    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root then return end

    if root.Position.Y > FALL_LIMIT + 50 then
        lastSafeCFrame = root.CFrame
    end

    if noclipEnabled and root.Position.Y <= FALL_LIMIT then
        if lastSafeCFrame then
            root.CFrame = lastSafeCFrame + Vector3.new(0, 4, 0)
            root.AssemblyLinearVelocity = Vector3.zero
            root.AssemblyAngularVelocity = Vector3.zero
        end
    end
end)

--==================================================
-- ESP (Tên, Khoảng cách <= 10,000m, Avatar & Khung xương)
--==================================================

local function createESP(targetPlayer)
    if targetPlayer == player then return end

    local function setupCharacter(char)
        local head = char:WaitForChild("Head", 5)
        if not head then return end

        if char:FindFirstChild("MrDonESP") then
            char.MrDonESP:Destroy()
        end

        local billboard = Instance.new("BillboardGui")
        billboard.Name = "MrDonESP"
        billboard.Size = UDim2.new(0, 150, 0, 50)
        billboard.StudsOffset = Vector3.new(0, 2.8, 0)
        billboard.AlwaysOnTop = true
        billboard.Adornee = head
        billboard.Parent = char

        local container = Instance.new("Frame")
        container.Size = UDim2.new(1, 0, 1, 0)
        container.BackgroundTransparency = 1
        container.Parent = billboard

        local avatarImg = Instance.new("ImageLabel")
        avatarImg.Size = UDim2.new(0, 36, 0, 36)
        avatarImg.Position = UDim2.new(0, 0, 0, 5)
        avatarImg.BackgroundTransparency = 1
        avatarImg.Image = "rbxthumb://type=AvatarHeadShot&id=" .. targetPlayer.UserId .. "&w=150&h=150"
        avatarImg.Parent = container

        local avatarCorner = Instance.new("UICorner")
        avatarCorner.CornerRadius = UDim.new(1, 0)
        avatarCorner.Parent = avatarImg

        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(1, -40, 0, 22)
        nameLabel.Position = UDim2.new(0, 42, 0, 4)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = targetPlayer.Name
        nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        nameLabel.TextSize = 13
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        nameLabel.TextStrokeTransparency = 0.5
        nameLabel.Parent = container

        local distLabel = Instance.new("TextLabel")
        distLabel.Size = UDim2.new(1, -40, 0, 20)
        distLabel.Position = UDim2.new(0, 42, 0, 22)
        distLabel.BackgroundTransparency = 1
        distLabel.TextColor3 = Color3.fromRGB(100, 220, 255)
        distLabel.TextSize = 11
        distLabel.Font = Enum.Font.GothamMedium
        distLabel.TextXAlignment = Enum.TextXAlignment.Left
        distLabel.TextStrokeTransparency = 0.5
        distLabel.Parent = container

        if Drawing and Drawing.new then
            local bones = {
                {"Head", "UpperTorso"},
                {"UpperTorso", "LowerTorso"},
                {"UpperTorso", "LeftUpperArm"},
                {"LeftUpperArm", "LeftLowerArm"},
                {"UpperTorso", "RightUpperArm"},
                {"RightUpperArm", "RightLowerArm"},
                {"LowerTorso", "LeftUpperLeg"},
                {"LeftUpperLeg", "LeftLowerLeg"},
                {"LowerTorso", "RightUpperLeg"},
                {"RightUpperLeg", "RightLowerLeg"}
            }

            for _, bone in ipairs(bones) do
                local line = Drawing.new("Line")
                line.Visible = false
                line.Color = Color3.fromRGB(0, 255, 255)
                line.Thickness = 1.5
                line.Transparency = 0.7
                table.insert(skeletonStorage, {Line = line, Bone = bone, Character = char, TargetPlayer = targetPlayer})
            end
        end

        local connection
        connection = RunService.RenderStepped:Connect(function()
            if not espEnabled or not char or not char.Parent or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
                billboard.Enabled = false
                return
            end

            local myRoot = player.Character.HumanoidRootPart
            local targetRoot = char:FindFirstChild("HumanoidRootPart")

            if targetRoot then
                local distance = math.floor((myRoot.Position - targetRoot.Position).Magnitude)
                if distance <= MAX_ESP_DISTANCE then
                    distLabel.Text = "[" .. distance .. "m]"
                    billboard.Enabled = true
                else
                    billboard.Enabled = false
                end
            else
                billboard.Enabled = false
            end
        end)

        table.insert(espStorage, {Billboard = billboard, Connection = connection})
    end

    if targetPlayer.Character then
        setupCharacter(targetPlayer.Character)
    end
    targetPlayer.CharacterAdded:Connect(setupCharacter)
end

RunService.RenderStepped:Connect(function()
    if not espEnabled or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
        for _, item in ipairs(skeletonStorage) do
            if item.Line then item.Line.Visible = false end
        end
        return
    end

    local myRoot = player.Character.HumanoidRootPart

    for _, item in ipairs(skeletonStorage) do
        local line = item.Line
        local bone = item.Bone
        local char = item.Character

        if char and char.Parent then
            local targetRoot = char:FindFirstChild("HumanoidRootPart")
            if targetRoot then
                local distance = (myRoot.Position - targetRoot.Position).Magnitude
                if distance <= MAX_ESP_DISTANCE then
                    local p1 = char:FindFirstChild(bone[1])
                    local p2 = char:FindFirstChild(bone[2])

                    if p1 and p2 then
                        local pos1, onScreen1 = Camera:WorldToViewportPoint(p1.Position)
                        local pos2, onScreen2 = Camera:WorldToViewportPoint(p2.Position)

                        if onScreen1 or onScreen2 then
                            line.From = Vector2.new(pos1.X, pos1.Y)
                            line.To = Vector2.new(pos2.X, pos2.Y)
                            line.Visible = true
                        else
                            line.Visible = false
                        end
                    else
                        line.Visible = false
                    end
                else
                    line.Visible = false
                end
            else
                line.Visible = false
            end
        else
            line.Visible = false
        end
    end
end)

local function toggleESP()
    espEnabled = not espEnabled
    espButton.Text = "👁️ ESP : " .. (espEnabled and "ON" or "OFF")
    
    if espEnabled then
        for _, p in ipairs(Players:GetPlayers()) do
            createESP(p)
        end
    else
        for _, data in ipairs(espStorage) do
            if data.Billboard then data.Billboard:Destroy() end
            if data.Connection then data.Connection:Disconnect() end
        end
        espStorage = {}
        for _, item in ipairs(skeletonStorage) do
            if item.Line then item.Line:Remove() end
        end
        skeletonStorage = {}
    end
end

espButton.Activated:Connect(toggleESP)

Players.PlayerAdded:Connect(function(p)
    if espEnabled then
        createESP(p)
    end
end)

--==================================================
-- FIX LAG (3 Chế độ)
--==================================================

local function applyFixLag()
    if fixLagLevel == 0 then
        Lighting.GlobalShadows = true
        Lighting.Brightness = 2
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") then
                obj.Material = Enum.Material.Plastic
            end
        end
        return
    end

    Lighting.GlobalShadows = false
    Lighting.Brightness = 1

    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            if fixLagLevel == 1 then
                obj.CastShadow = false
            elseif fixLagLevel == 2 then
                obj.CastShadow = false
                if obj.Material ~= Enum.Material.SmoothPlastic and obj.Material ~= Enum.Material.Neon then
                    obj.Material = Enum.Material.SmoothPlastic
                end
            elseif fixLagLevel == 3 then
                obj.CastShadow = false
                if obj.Material ~= Enum.Material.SmoothPlastic and obj.Material ~= Enum.Material.Neon then
                    obj.Material = Enum.Material.SmoothPlastic
                end
                if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Fire") or obj:IsA("Smoke") then
                    obj.Enabled = false
                end
            end
        end
    end
end

fixLagButton.Activated:Connect(function()
    fixLagLevel = (fixLagLevel + 1) % 4
    local labels = {"OFF", "MỨC 1", "MỨC 2", "MỨC 3"}
    local statusText = labels[fixLagLevel + 1]
    fixLagButton.Text = "🚀 FIX LAG : " .. (fixLagLevel > 0 and "ON" or "OFF") .. " [" .. statusText .. "]"
    applyFixLag()
end)

--==================================================
-- RESPAWN HANDLER
--==================================================

player.CharacterAdded:Connect(function(character)
    character:WaitForChild("Humanoid", 5)
    task.wait(0.25)
    lastSafeCFrame = nil
    if speedEnabled then applySpeed() end
end)

--==================================================
-- CLOSE / OPEN
--==================================================

close.Activated:Connect(function()
    main.Visible = false
    openButton.Visible = true
end)

openButton.Activated:Connect(function()
    main.Visible = true
    openButton.Visible = false
end)

--==================================================
-- MOBILE DRAG
--==================================================

local dragging = false
local dragStart = nil
local startPosition = nil

header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPosition = main.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if not dragging then return end
    if input.UserInputType == Enum.UserInputType.Touch then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(
            startPosition.X.Scale, startPosition.X.Offset + delta.X,
            startPosition.Y.Scale, startPosition.Y.Offset + delta.Y
        )
    end
end)

UserInputService.TouchEnded:Connect(function()
    dragging = false
end)
  
