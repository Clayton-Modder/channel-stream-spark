-- === MENU UI CHAMATIVO + AIMBOT + ESP + NOCLIP PARA DELTA ===
-- Cole todo o código no Delta Executor e execute

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Configurações
local Settings = {
    Aimbot = false,
    FOV = 120,
    AimPart = "Head",
    Smoothing = 0.25,
    TeamCheck = true,
    ESP = true,
    Noclip = false,
    Speed = 50,
    ShowFOV = true
}

-- GUI Principal (Chamativa Neon)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NeonAimbotHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game.CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 320, 0, 420)
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -210)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 50)
Title.BackgroundTransparency = 1
Title.Text = "🔥 NEON AIM HUB 🔥"
Title.TextColor3 = Color3.fromRGB(0, 255, 200)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 22
Title.Parent = MainFrame

-- Função para criar toggles e sliders bonitos
local function CreateToggle(parent, text, default, callback)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(1, -20, 0, 40)
    ToggleFrame.BackgroundTransparency = 1
    ToggleFrame.Parent = parent
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.7, 0, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.new(1,1,1)
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 16
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = ToggleFrame
    
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(0, 60, 0, 30)
    Button.Position = UDim2.new(0.8, 0, 0.5, -15)
    Button.BackgroundColor3 = default and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 50, 50)
    Button.Text = default and "ON" or "OFF"
    Button.TextColor3 = Color3.new(1,1,1)
    Button.Font = Enum.Font.GothamBold
    Button.Parent = ToggleFrame
    
    Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 8)
    
    Button.MouseButton1Click:Connect(function()
        default = not default
        Button.BackgroundColor3 = default and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 50, 50)
        Button.Text = default and "ON" or "OFF"
        callback(default)
    end)
    return ToggleFrame
end

local function CreateSlider(parent, text, min, max, default, callback)
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Size = UDim2.new(1, -20, 0, 50)
    SliderFrame.BackgroundTransparency = 1
    SliderFrame.Parent = parent
    
    local Label = Instance.new("TextLabel")
    Label.Text = text .. ": " .. default
    Label.Size = UDim2.new(1, 0, 0, 20)
    Label.BackgroundTransparency = 1
    Label.TextColor3 = Color3.new(1,1,1)
    Label.Font = Enum.Font.Gotham
    Label.Parent = SliderFrame
    
    local Bar = Instance.new("Frame")
    Bar.Size = UDim2.new(1, 0, 0, 8)
    Bar.Position = UDim2.new(0, 0, 0, 30)
    Bar.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    Bar.Parent = SliderFrame
    Instance.new("UICorner", Bar)
    
    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new((default-min)/(max-min), 0, 1, 0)
    Fill.BackgroundColor3 = Color3.fromRGB(0, 255, 200)
    Fill.Parent = Bar
    Instance.new("UICorner", Fill)
    
    local dragging = false
    Bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    
    RunService.RenderStepped:Connect(function()
        if dragging then
            local mouseX = UserInputService:GetMouseLocation().X
            local barPos = Bar.AbsolutePosition.X
            local barSize = Bar.AbsoluteSize.X
            local percent = math.clamp((mouseX - barPos) / barSize, 0, 1)
            local value = math.floor(min + (max - min) * percent)
            Fill.Size = UDim2.new(percent, 0, 1, 0)
            Label.Text = text .. ": " .. value
            callback(value)
        end
    end)
end

-- Adiciona elementos no menu
local Scrolling = Instance.new("ScrollingFrame")
Scrolling.Size = UDim2.new(1, -20, 1, -70)
Scrolling.Position = UDim2.new(0, 10, 0, 60)
Scrolling.BackgroundTransparency = 1
Scrolling.ScrollBarThickness = 6
Scrolling.Parent = MainFrame

CreateToggle(Scrolling, "Aimbot", Settings.Aimbot, function(v) Settings.Aimbot = v end)
CreateSlider(Scrolling, "FOV", 30, 300, Settings.FOV, function(v) Settings.FOV = v end)
CreateToggle(Scrolling, "ESP + HP", Settings.ESP, function(v) Settings.ESP = v end)
CreateToggle(Scrolling, "Noclip", Settings.Noclip, function(v) Settings.Noclip = v end)
CreateSlider(Scrolling, "Speed Fast", 16, 100, Settings.Speed, function(v) Settings.Speed = v end)
CreateToggle(Scrolling, "Mostrar Círculo FOV", Settings.ShowFOV, function(v) Settings.ShowFOV = v end)

-- Círculo FOV
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2
FOVCircle.NumSides = 100
FOVCircle.Radius = Settings.FOV
FOVCircle.Color = Color3.fromRGB(0, 255, 200)
FOVCircle.Transparency = 0.7
FOVCircle.Visible = false

-- ESP Drawings
local ESPObjects = {}

local function CreateESP(player)
    if player == LocalPlayer then return end
    local Box = Drawing.new("Square")
    Box.Thickness = 2
    Box.Filled = false
    Box.Color = Color3.fromRGB(0, 255, 200)
    Box.Transparency = 1
    
    local Name = Drawing.new("Text")
    Name.Size = 16
    Name.Color = Color3.new(1,1,1)
    Name.Outline = true
    
    local HealthBar = Drawing.new("Square")
    HealthBar.Thickness = 1
    HealthBar.Filled = true
    HealthBar.Color = Color3.fromRGB(0, 255, 0)
    
    ESPObjects[player] = {Box = Box, Name = Name, HealthBar = HealthBar}
end

Players.PlayerAdded:Connect(CreateESP)
for _, p in pairs(Players:GetPlayers()) do CreateESP(p) end

-- Aimbot Logic
local function GetClosestTarget()
    local closest, dist = nil, Settings.FOV
    local mousePos = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character:FindFirstChild(Settings.AimPart) then
            if Settings.TeamCheck and player.Team == LocalPlayer.Team then continue end
            
            local part = player.Character[Settings.AimPart]
            local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
            if not onScreen then continue end
            
            local magnitude = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
            if magnitude < dist then
                dist = magnitude
                closest = part
            end
        end
    end
    return closest
end

-- Main Loop
RunService.RenderStepped:Connect(function()
    -- Atualiza FOV Circle
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    FOVCircle.Radius = Settings.FOV
    FOVCircle.Visible = Settings.ShowFOV and Settings.Aimbot
    
    -- Aimbot
    if Settings.Aimbot then
        local target = GetClosestTarget()
        if target then
            local targetPos = Camera:WorldToViewportPoint(target.Position)
            local mouse = UserInputService:GetMouseLocation()
            local smooth = (Vector2.new(targetPos.X, targetPos.Y) - mouse) * Settings.Smoothing
            mousemoverel(smooth.X, smooth.Y)
        end
    end
    
    -- ESP
    if Settings.ESP then
        for player, drawings in pairs(ESPObjects) do
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Head") and player.Character.Humanoid.Health > 0 then
                local root = player.Character.HumanoidRootPart
                local head = player.Character.Head
                local humanoid = player.Character.Humanoid
                
                local rootPos, onScreen = Camera:WorldToViewportPoint(root.Position)
                if onScreen then
                    local headPos = Camera:WorldToViewportPoint(head.Position)
                    local legPos = Camera:WorldToViewportPoint(root.Position - Vector3.new(0,3,0))
                    
                    local height = (headPos.Y - legPos.Y)
                    drawings.Box.Size = Vector2.new(height/1.5, height)
                    drawings.Box.Position = Vector2.new(rootPos.X - drawings.Box.Size.X/2, rootPos.Y - drawings.Box.Size.Y/2)
                    drawings.Box.Visible = true
                    
                    drawings.Name.Text = player.Name .. " [" .. math.floor(humanoid.Health) .. " HP]"
                    drawings.Name.Position = Vector2.new(rootPos.X - drawings.Name.TextBounds.X/2, headPos.Y - 25)
                    drawings.Name.Visible = true
                    
                    -- Health Bar
                    local healthPercent = humanoid.Health / humanoid.MaxHealth
                    drawings.HealthBar.Size = Vector2.new(4, height * healthPercent)
                    drawings.HealthBar.Position = Vector2.new(rootPos.X - drawings.Box.Size.X/2 - 8, rootPos.Y - drawings.Box.Size.Y/2 + (height * (1 - healthPercent)))
                    drawings.HealthBar.Visible = true
                else
                    drawings.Box.Visible = false
                    drawings.Name.Visible = false
                    drawings.HealthBar.Visible = false
                end
            else
                drawings.Box.Visible = false
                drawings.Name.Visible = false
                drawings.HealthBar.Visible = false
            end
        end
    else
        for _, drawings in pairs(ESPObjects) do
            drawings.Box.Visible = false
            drawings.Name.Visible = false
            drawings.HealthBar.Visible = false
        end
    end
    
    -- Noclip
    if Settings.Noclip and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
    
    -- Speed Fast
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = Settings.Speed
    end
end)

-- Toggle Menu com Insert
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Insert then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

print("✅ Menu Neon + Aimbot + ESP carregado! Pressione INSERT para abrir.")
