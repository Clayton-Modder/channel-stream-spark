-- 🔥 Aimbot Professional - MENU ULTRA MODERNO

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = Workspace.CurrentCamera

local aimbotEnabled = true
local magicBulletEnabled = true
local antiRecoilEnabled = true
local espEnabled = true
local fovValue = 160

-- ANTI DETECT + BALA MÁGICA
local mt = getrawmetatable(game)
setreadonly(mt, false)
mt.__namecall = newcclosure(function(self, ...)
    local args = {...}
    if magicBulletEnabled and getnamecallmethod() == "FireServer" then
        local name = tostring(self):lower()
        if name:find("bullet") or name:find("shoot") or name:find("gun") then
            local closest = nil
            local minDist = 9999
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") then
                    local d = (LocalPlayer.Character.HumanoidRootPart.Position - plr.Character.Head.Position).Magnitude
                    if d < minDist then minDist = d closest = plr end
                end
            end
            if closest then
                args[1] = closest.Character.Head.Position
            end
        end
    end
    return mt.__namecall(self, unpack(args))
end)
setreadonly(mt, true)

-- ÍCONE FLUTUANTE
local Icon = Instance.new("TextButton")
Icon.Size = UDim2.new(0, 85, 0, 85)
Icon.Position = UDim2.new(0, 20, 0.35, 0)
Icon.BackgroundColor3 = Color3.fromRGB(255, 0, 120)
Icon.Text = "⚡"
Icon.TextScaled = true
Icon.Font = Enum.Font.GothamBold
Icon.TextColor3 = Color3.new(1,1,1)
Icon.Parent = LocalPlayer.PlayerGui:FindFirstChild("ScreenGui") or Instance.new("ScreenGui", LocalPlayer.PlayerGui)

-- MENU COM DESIGN MODERNO
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 440, 0, 560)
Main.Position = UDim2.new(0.5, -220, 0.5, -280)
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
Main.BorderSizePixel = 0
Main.Draggable = true
Main.Active = true
Main.Visible = false
Main.Parent = LocalPlayer.PlayerGui.ScreenGui

-- Efeito de borda
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = Main

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1,0,0,80)
Title.BackgroundColor3 = Color3.fromRGB(255, 0, 120)
Title.Text = "GROK CHEATS"
Title.TextColor3 = Color3.new(1,1,1)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBlack
Title.Parent = Main

local UICornerTitle = Instance.new("UICorner")
UICornerTitle.CornerRadius = UDim.new(0, 12)
UICornerTitle.Parent = Title

local function CreateToggle(text, y, default, callback)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(0.9,0,0,65)
    f.Position = UDim2.new(0.05,0,0,y)
    f.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
    f.Parent = Main

    local UIC = Instance.new("UICorner")
    UIC.CornerRadius = UDim.new(0, 10)
    UIC.Parent = f

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.65,0,1,0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.new(1,1,1)
    lbl.TextScaled = true
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Font = Enum.Font.GothamSemibold
    lbl.Parent = f

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 140, 0, 48)
    btn.Position = UDim2.new(0.7,0,0.5,-24)
    btn.BackgroundColor3 = default and Color3.fromRGB(0, 255, 140) or Color3.fromRGB(255, 70, 70)
    btn.Text = default and "ON" or "OFF"
    btn.TextColor3 = Color3.new(1,1,1)
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamBold
    btn.Parent = f

    local UIC2 = Instance.new("UICorner")
    UIC2.CornerRadius = UDim.new(0, 10)
    UIC2.Parent = btn

    local state = default
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.BackgroundColor3 = state and Color3.fromRGB(0,255,140) or Color3.fromRGB(255,70,70)
        btn.Text = state and "ON" or "OFF"
        callback(state)
    end)
end

CreateToggle("🎯 Aimbot Cabeça", 90, true, function(v) aimbotEnabled = v end)
CreateToggle("💥 Bala Mágica", 165, true, function(v) magicBulletEnabled = v end)
CreateToggle("🔫 Anti-Recoil", 240, true, function(v) antiRecoilEnabled = v end)
CreateToggle("👁️ ESP", 315, true, function(v) espEnabled = v end)

-- FOV Slider
local fovLabel = Instance.new("TextLabel")
fovLabel.Size = UDim2.new(0.9,0,0,35)
fovLabel.Position = UDim2.new(0.05,0,0,390)
fovLabel.Text = "FOV: " .. fovValue
fovLabel.TextColor3 = Color3.new(1,1,1)
fovLabel.TextScaled = true
fovLabel.Font = Enum.Font.GothamBold
fovLabel.Parent = Main

local bar = Instance.new("Frame")
bar.Size = UDim2.new(0.9,0,0,16)
bar.Position = UDim2.new(0.05,0,0,430)
bar.BackgroundColor3 = Color3.fromRGB(45,45,55)
bar.Parent = Main

local UICBar = Instance.new("UICorner")
UICBar.CornerRadius = UDim.new(0, 8)
UICBar.Parent = bar

local knob = Instance.new("Frame")
knob.Size = UDim2.new(0, 32, 0, 32)
knob.Position = UDim2.new(fovValue/400,0,0.5,-16)
knob.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
knob.Parent = bar

local UICKnob = Instance.new("UICorner")
UICKnob.CornerRadius = UDim.new(0, 16)
UICKnob.Parent = knob

-- Slider Logic
local dragging = false
knob.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end end)
UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)

UserInputService.InputChanged:Connect(function(i)
    if dragging then
        local percent = math.clamp((i.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        fovValue = math.floor(percent * 400)
        knob.Position = UDim2.new(percent, 0, 0.5, -16)
        fovLabel.Text = "FOV: " .. fovValue
    end
end)

-- Funções do Aimbot
RunService.RenderStepped:Connect(function()
    if aimbotEnabled then
        local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if root then
            local closest = nil
            local minDist = fovValue
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") then
                    local d = (root.Position - plr.Character.Head.Position).Magnitude
                    if d < minDist then
                        minDist = d
                        closest = plr
                    end
                end
            end
            if closest then
                Camera.CFrame = Camera.CFrame:Lerp(CFrame.lookAt(Camera.CFrame.Position, closest.Character.Head.Position), 0.085)
            end
        end
    end
end)

-- Abrir/Fechar
Icon.MouseButton1Click:Connect(function()
    Main.Visible = not Main.Visible
end)

UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.F then
        Main.Visible = not Main.Visible
    end
end)

print("✅ MENU ULTRA MODERNO CARREGADO!")
print("Clique no ícone ⚡ ou pressione F")
