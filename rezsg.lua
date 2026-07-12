-- === NEON HUB v25 - MENU COM OPÇÕES VISÍVEIS ===
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local Settings = {
    Aimbot = false,
    FOV = 110,
    Smoothing = 0.13,
    Speed = 60,
    Noclip = false,
    AutoRevive = false,
    KillAura = false,
    GodMode = false,
}

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game.CoreGui

-- Ícone
local Icon = Instance.new("TextButton")
Icon.Size = UDim2.new(0, 80, 0, 80)
Icon.Position = UDim2.new(1, -100, 0, 40)
Icon.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
Icon.Text = "🩸"
Icon.TextSize = 40
Icon.Font = Enum.Font.GothamBold
Icon.TextColor3 = Color3.new(1,1,1)
Icon.Parent = ScreenGui
Instance.new("UICorner", Icon).CornerRadius = UDim.new(1, 0)

-- Janela
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 420, 0, 680)
Main.Position = UDim2.new(0.5, -210, 0.5, -340)
Main.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
Main.Visible = false
Main.Parent = ScreenGui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 16)

-- Título
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 60)
TitleBar.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
TitleBar.Parent = Main
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 16)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -60, 1, 0)
Title.BackgroundTransparency = 1
Title.Text = "🩸 NEON HUB"
Title.TextColor3 = Color3.new(1,1,1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 24
Title.Parent = TitleBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 45, 0, 45)
CloseBtn.Position = UDim2.new(1, -52, 0, 8)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.new(1,1,1)
CloseBtn.TextSize = 30
CloseBtn.Parent = TitleBar

-- Scrolling
local Scrolling = Instance.new("ScrollingFrame")
Scrolling.Size = UDim2.new(1, -20, 1, -80)
Scrolling.Position = UDim2.new(0, 10, 0, 70)
Scrolling.BackgroundTransparency = 1
Scrolling.ScrollBarThickness = 8
Scrolling.Parent = Main

local ListLayout = Instance.new("UIListLayout", Scrolling)
ListLayout.Padding = UDim.new(0, 15)
ListLayout.SortOrder = Enum.SortOrder.LayoutOrder

ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    Scrolling.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y + 60)
end)

local function CreateToggle(text, default, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -20, 0, 62)
    Frame.BackgroundColor3 = Color3.fromRGB(32, 32, 40)
    Frame.Parent = Scrolling
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 12)
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.65, 0, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = "   " .. text
    Label.TextColor3 = Color3.new(1,1,1)
    Label.Font = Enum.Font.GothamSemibold
    Label.TextSize = 18
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame
    
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(0, 95, 0, 42)
    Btn.Position = UDim2.new(0.78, 0, 0.5, -21)
    Btn.BackgroundColor3 = default and Color3.fromRGB(0, 255, 140) or Color3.fromRGB(255, 60, 60)
    Btn.Text = default and "ON" or "OFF"
    Btn.TextColor3 = Color3.new(1,1,1)
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 16
    Btn.Parent = Frame
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 12)
    
    Btn.MouseButton1Click:Connect(function()
        default = not default
        Btn.BackgroundColor3 = default and Color3.fromRGB(0,255,140) or Color3.fromRGB(255,60,60)
        Btn.Text = default and "ON" or "OFF"
        callback(default)
    end)
end

-- OPÇÕES
CreateToggle("Aimbot (Cabeça)", Settings.Aimbot, function(v) Settings.Aimbot = v end)
CreateToggle("Auto Reviver", Settings.AutoRevive, function(v) Settings.AutoRevive = v end)
CreateToggle("Kill Aura", Settings.KillAura, function(v) Settings.KillAura = v end)
CreateToggle("God Mode", Settings.GodMode, function(v) Settings.GodMode = v end)
CreateToggle("Noclip", Settings.Noclip, function(v) Settings.Noclip = v end)
CreateToggle("Fling Mais Próximo", Settings.Fling, function(v) Settings.Fling = v end)
CreateToggle("Fling Todos", Settings.FlingAll, function(v) Settings.FlingAll = v end)

-- Loop
RunService.RenderStepped:Connect(function()
    if Settings.Aimbot then
        local best = nil
        local minDist = Settings.FOV
        local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
        
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                if Settings.TeamCheck and plr.Team == LocalPlayer.Team then continue end
                local head = plr.Character:FindFirstChild("Head")
                if head then
                    local pos, onScr = Camera:WorldToViewportPoint(head.Position)
                    if onScr then
                        local dist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                        if dist < minDist then
                            minDist = dist
                            best = head
                        end
                    end
                end
            end
        end
        
        if best then
            local tPos = Camera:WorldToViewportPoint(best.Position)
            local mPos = UserInputService:GetMouseLocation()
            local dx = (tPos.X - mPos.X) * Settings.Smoothing * 1.7
            local dy = (tPos.Y - mPos.Y) * Settings.Smoothing * 1.7
            mousemoverel(dx, dy)
        end
    end
    
    if Settings.AutoRevive then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr.Character then
                local hum = plr.Character:FindFirstChild("Humanoid")
                if hum and hum.Health <= 0 then
                    hum.Health = hum.MaxHealth
                end
            end
        end
    end
    
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = Settings.Speed
        if Settings.Noclip then
            for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end
    end
end)

-- ABRIR MENU
Icon.MouseButton1Click:Connect(function()
    Main.Visible = not Main.Visible
end)

CloseBtn.MouseButton1Click:Connect(function()
    Main.Visible = false
end)

UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Insert then
        Main.Visible = not Main.Visible
    end
end)

print("✅ MENU CARREGADO COM SUCESSO!")
print("Pressione INSERT ou clique no ícone 🩸")
