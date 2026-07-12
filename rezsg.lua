-- === NEON AIM HUB v2 - Organizado + Movable + Ícone ===
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local Settings = {
    Aimbot = false,
    FOV = 140,
    Smoothing = 0.22,
    AimPart = "Head",
    TeamCheck = true,
    ESP = true,
    Noclip = false,
    Speed = 50,
    ShowFOV = true
}

-- ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NeonHubV2"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game.CoreGui

-- ÍCONE FLUTUANTE (Canto superior direito)
local IconButton = Instance.new("TextButton")
IconButton.Size = UDim2.new(0, 60, 0, 60)
IconButton.Position = UDim2.new(1, -80, 0, 20)
IconButton.BackgroundColor3 = Color3.fromRGB(0, 255, 200)
IconButton.Text = "🔥"
IconButton.TextSize = 30
IconButton.Font = Enum.Font.GothamBold
IconButton.Parent = ScreenGui
Instance.new("UICorner", IconButton).CornerRadius = UDim.new(1, 0)

-- MENU PRINCIPAL
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 340, 0, 460)
MainFrame.Position = UDim2.new(0.5, -170, 0.5, -230)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 14)

-- Barra de Título (arrastar + fechar)
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 50)
TitleBar.BackgroundColor3 = Color3.fromRGB(0, 255, 180)
TitleBar.Parent = MainFrame
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 14)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -50, 1, 0)
Title.BackgroundTransparency = 1
Title.Text = "🔥 NEON AIM HUB"
Title.TextColor3 = Color3.new(0,0,0)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 20
Title.Parent = TitleBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 40, 0, 40)
CloseBtn.Position = UDim2.new(1, -45, 0, 5)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.new(1,0,0)
CloseBtn.TextSize = 28
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = TitleBar

-- Tornar o menu arrastável
local dragging, dragInput, dragStart, startPos
TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement) then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)

-- Fechar menu
CloseBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false end)
IconButton.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

-- Scrolling Frame para opções
local Scrolling = Instance.new("ScrollingFrame")
Scrolling.Size = UDim2.new(1, -20, 1, -70)
Scrolling.Position = UDim2.new(0, 10, 0, 60)
Scrolling.BackgroundTransparency = 1
Scrolling.ScrollBarThickness = 6
Scrolling.CanvasSize = UDim2.new(0,0,0,600)
Scrolling.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout", Scrolling)
UIListLayout.Padding = UDim.new(0, 8)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- Funções de UI
local function AddToggle(text, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 45)
    frame.BackgroundColor3 = Color3.fromRGB(30,30,38)
    frame.Parent = Scrolling
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0,8)
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.65,0,1,0)
    label.BackgroundTransparency = 1
    label.Text = "  " .. text
    label.TextColor3 = Color3.new(1,1,1)
    label.Font = Enum.Font.Gotham
    label.TextSize = 17
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 70, 0, 30)
    btn.Position = UDim2.new(0.8,0,0.5,-15)
    btn.BackgroundColor3 = default and Color3.fromRGB(0,255,120) or Color3.fromRGB(255,60,60)
    btn.Text = default and "ON" or "OFF"
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamBold
    btn.Parent = frame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,8)
    
    btn.MouseButton1Click:Connect(function()
        default = not default
        btn.BackgroundColor3 = default and Color3.fromRGB(0,255,120) or Color3.fromRGB(255,60,60)
        btn.Text = default and "ON" or "OFF"
        callback(default)
    end)
end

local function AddSlider(text, minv, maxv, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 65)
    frame.BackgroundColor3 = Color3.fromRGB(30,30,38)
    frame.Parent = Scrolling
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0,8)
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1,0,0,25)
    label.BackgroundTransparency = 1
    label.Text = text .. ": " .. default
    label.TextColor3 = Color3.new(1,1,1)
    label.Font = Enum.Font.Gotham
    label.TextSize = 16
    label.Parent = frame
    
    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(0.9,0,0,10)
    bar.Position = UDim2.new(0.05,0,0.6,0)
    bar.BackgroundColor3 = Color3.fromRGB(50,50,60)
    bar.Parent = frame
    Instance.new("UICorner", bar).CornerRadius = UDim.new(1,0)
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default-minv)/(maxv-minv), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 255, 200)
    fill.Parent = bar
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1,0)
    
    -- Lógica do slider (simplificada)
    bar.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            local conn
            conn = RunService.RenderStepped:Connect(function()
                local mouse = UserInputService:GetMouseLocation()
                local rel = math.clamp((mouse.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
                local val = math.floor(minv + (maxv - minv) * rel)
                fill.Size = UDim2.new(rel, 0, 1, 0)
                label.Text = text .. ": " .. val
                callback(val)
                if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then conn:Disconnect() end
            end)
        end
    end)
end

-- Adicionando seções organizadas
AddToggle("Aimbot", Settings.Aimbot, function(v) Settings.Aimbot = v end)
AddSlider("FOV", 40, 300, Settings.FOV, function(v) Settings.FOV = v end)
AddToggle("Mostrar Círculo FOV", Settings.ShowFOV, function(v) Settings.ShowFOV = v end)
AddToggle("ESP + Vida (HP)", Settings.ESP, function(v) Settings.ESP = v end)
AddToggle("Noclip", Settings.Noclip, function(v) Settings.Noclip = v end)
AddSlider("Velocidade Fast", 16, 120, Settings.Speed, function(v) Settings.Speed = v end)

-- =================== LÓGICA DO AIMBOT + ESP ===================
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2.5
FOVCircle.Color = Color3.fromRGB(0, 255, 200)
FOVCircle.Transparency = 0.6
FOVCircle.Visible = false

local ESP = {}

-- (O resto da lógica de Aimbot + ESP continua igual ao script anterior - otimizado)
RunService.RenderStepped:Connect(function()
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    FOVCircle.Radius = Settings.FOV
    FOVCircle.Visible = Settings.ShowFOV and Settings.Aimbot
    
    if Settings.Aimbot then
        local target = nil
        local closestDist = Settings.FOV
        local mousePos = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
        
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild(Settings.AimPart) then
                if Settings.TeamCheck and plr.Team == LocalPlayer.Team then continue end
                local pos, onScr = Camera:WorldToViewportPoint(plr.Character[Settings.AimPart].Position)
                if onScr then
                    local dist = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
                    if dist < closestDist then
                        closestDist = dist
                        target = plr.Character[Settings.AimPart]
                    end
                end
            end
        end
        
        if target then
            local tPos = Camera:WorldToViewportPoint(target.Position)
            local mPos = UserInputService:GetMouseLocation()
            local move = (Vector2.new(tPos.X, tPos.Y) - mPos) * Settings.Smoothing
            mousemoverel(move.X, move.Y)
        end
    end
    
    -- Speed + Noclip (mesmo código do anterior)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = Settings.Speed
    end
    
    if Settings.Noclip and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
end)

-- Tecla INSERT
UserInputService.InputBegan:Connect(function(i)
    if i.KeyCode == Enum.KeyCode.Insert then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

print("✅ Menu Organizado + Ícone + Movimentável carregado!")
print("Pressione INSERT ou clique no ícone 🔥")
