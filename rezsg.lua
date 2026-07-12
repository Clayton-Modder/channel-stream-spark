-- 🔥 Aimbot Seguro - Sem Crash

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = Workspace.CurrentCamera

local aimbotEnabled = true
local fovValue = 140

print("✅ Script Seguro Carregado")

-- ÍCONE
local Icon = Instance.new("TextButton")
Icon.Size = UDim2.new(0, 70, 0, 70)
Icon.Position = UDim2.new(0, 20, 0.4, 0)
Icon.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
Icon.Text = "🎯"
Icon.TextScaled = true
Icon.Font = Enum.Font.GothamBold
Icon.TextColor3 = Color3.new(1,1,1)
Icon.Parent = LocalPlayer.PlayerGui:FindFirstChild("ScreenGui") or Instance.new("ScreenGui", LocalPlayer.PlayerGui)

-- MENU
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 360, 0, 380)
Main.Position = UDim2.new(0.5, -180, 0.5, -190)
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
Main.Draggable = true
Main.Visible = false
Main.Parent = LocalPlayer.PlayerGui.ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1,0,0,60)
Title.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
Title.Text = "🎯 Aimbot Seguro"
Title.TextColor3 = Color3.new(1,1,1)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold
Title.Parent = Main

local function CreateToggle(text, y, default, callback)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(0.9,0,0,55)
    f.Position = UDim2.new(0.05,0,0,y)
    f.BackgroundColor3 = Color3.fromRGB(35,35,45)
    f.Parent = Main

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.6,0,1,0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.new(1,1,1)
    lbl.TextScaled = true
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = f

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 110, 0, 45)
    btn.Position = UDim2.new(0.7,0,0.5,-22)
    btn.BackgroundColor3 = default and Color3.fromRGB(0,255,100) or Color3.fromRGB(255,60,60)
    btn.Text = default and "ON" or "OFF"
    btn.TextColor3 = Color3.new(1,1,1)
    btn.TextScaled = true
    btn.Parent = f

    local state = default
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.BackgroundColor3 = state and Color3.fromRGB(0,255,100) or Color3.fromRGB(255,60,60)
        btn.Text = state and "ON" or "OFF"
        callback(state)
    end)
end

CreateToggle("Aimbot Ativado", 80, true, function(v) aimbotEnabled = v end)

-- Aimbot Simples e Seguro
RunService.RenderStepped:Connect(function()
    if not aimbotEnabled then return end
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local closest = nil
    local minDist = fovValue

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") then
            local dist = (root.Position - plr.Character.Head.Position).Magnitude
            if dist < minDist then
                minDist = dist
                closest = plr
            end
        end
    end

    if closest and closest.Character and closest.Character:FindFirstChild("Head") then
        Camera.CFrame = Camera.CFrame:Lerp(CFrame.lookAt(Camera.CFrame.Position, closest.Character.Head.Position), 0.1)
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

print("Pressione F ou clique no ícone azul para abrir o menu")
