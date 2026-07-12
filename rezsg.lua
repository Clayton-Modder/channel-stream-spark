-- 🔥 MENU MELHORADO + CONGELAR JOGADORES + ÍCONE

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = Workspace.CurrentCamera

local aimbotEnabled = true
local magicBulletEnabled = true
local pullEnabled = true
local noclipEnabled = false
local freezeEnabled = false
local freezeRadius = 150

local menuOpen = true

-- === ÍCONE FLUTUANTE PARA ABRIR MENU ===
local Icon = Instance.new("TextButton")
Icon.Size = UDim2.new(0, 60, 0, 60)
Icon.Position = UDim2.new(0, 20, 0.5, -30)
Icon.BackgroundColor3 = Color3.fromRGB(0, 140, 255)
Icon.Text = "🔥"
Icon.TextScaled = true
Icon.Font = Enum.Font.GothamBold
Icon.TextColor3 = Color3.new(1,1,1)
Icon.Parent = LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("ScreenGui") or Instance.new("ScreenGui", LocalPlayer.PlayerGui)

Icon.MouseButton1Click:Connect(function()
    menuOpen = not menuOpen
    MainFrame.Visible = menuOpen
end)

-- === MENU PRINCIPAL ===
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 360, 0, 520)
MainFrame.Position = UDim2.new(0.5, -180, 0.5, -260)
MainFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
MainFrame.Draggable = true
MainFrame.Visible = true
MainFrame.Parent = LocalPlayer.PlayerGui.ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1,0,0,55)
Title.BackgroundColor3 = Color3.fromRGB(0, 110, 220)
Title.Text = "🔥 ADVANCED CHEAT MENU"
Title.TextColor3 = Color3.new(1,1,1)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

local function CreateSwitch(text, y, default, callback)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(0.92,0,0,55)
    f.Position = UDim2.new(0.04,0,0,y)
    f.BackgroundColor3 = Color3.fromRGB(35,35,35)
    f.Parent = MainFrame

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.65,0,1,0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.new(1,1,1)
    lbl.TextScaled = true
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = f

    local tog = Instance.new("TextButton")
    tog.Size = UDim2.new(0, 100, 0, 38)
    tog.Position = UDim2.new(0.72,0,0.5,-19)
    tog.BackgroundColor3 = default and Color3.fromRGB(0,200,0) or Color3.fromRGB(200,0,0)
    tog.Text = default and "ON" or "OFF"
    tog.TextColor3 = Color3.new(1,1,1)
    tog.TextScaled = true
    tog.Parent = f

    local state = default
    tog.MouseButton1Click:Connect(function()
        state = not state
        tog.BackgroundColor3 = state and Color3.fromRGB(0,200,0) or Color3.fromRGB(200,0,0)
        tog.Text = state and "ON" or "OFF"
        callback(state)
    end)
end

-- Switches
CreateSwitch("🔫 Aimbot Visual", 70, true, function(v) aimbotEnabled = v end)
CreateSwitch("💥 Bala Mágica", 135, true, function(v) magicBulletEnabled = v end)
CreateSwitch("🧲 Puxar Itens", 200, true, function(v) pullEnabled = v end)
CreateSwitch("👻 Noclip", 265, false, function(v) noclipEnabled = v end)
CreateSwitch("❄️ Congelar Jogadores", 330, false, function(v) freezeEnabled = v end)

-- Slider Raio de Congelamento
local function CreateRadiusSlider()
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.92,0,0,80)
    frame.Position = UDim2.new(0.04,0,0,400)
    frame.BackgroundColor3 = Color3.fromRGB(35,35,35)
    frame.Parent = MainFrame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1,0,0,30)
    label.Text = "Raio de Congelamento: " .. freezeRadius
    label.TextColor3 = Color3.new(1,1,1)
    label.BackgroundTransparency = 1
    label.TextScaled = true
    label.Parent = frame

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1,-30,0,12)
    bar.Position = UDim2.new(0,15,0.65,0)
    bar.BackgroundColor3 = Color3.fromRGB(60,60,60)
    bar.Parent = frame

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0,26,0,26)
    knob.Position = UDim2.new(freezeRadius/350,0,0.5,-13)
    knob.BackgroundColor3 = Color3.fromRGB(0,170,255)
    knob.Parent = bar

    local dragging = false
    knob.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)

    UserInputService.InputChanged:Connect(function(i)
        if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
            local percent = math.clamp((i.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
            freezeRadius = math.floor(percent * 350)
            knob.Position = UDim2.new(percent, 0, 0.5, -13)
            label.Text = "Raio de Congelamento: " .. freezeRadius
        end
    end)
end

CreateRadiusSlider()

-- === CONGELAR JOGADORES ===
RunService.Heartbeat:Connect(function()
    if not freezeEnabled then return end
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (root.Position - plr.Character.HumanoidRootPart.Position).Magnitude
            if dist <= freezeRadius then
                local hum = plr.Character:FindFirstChild("Humanoid")
                if hum then
                    hum.WalkSpeed = 0
                    hum.JumpPower = 0
                    plr.Character.HumanoidRootPart.Velocity = Vector3.new(0,0,0)
                end
            end
        end
    end
end)

-- Outras funções (Aimbot, Bala Mágica, etc.) mantidas...
print("✅ Menu Melhorado Carregado!")
print("Clique no ícone 🔥 para abrir/fechar o menu")
