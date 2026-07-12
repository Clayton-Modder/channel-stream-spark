-- === NEON AIM HUB v5 - UNIVERSAL (Suporte Múltiplos Jogos) ===
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local GameName = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name:lower()

print("🎮 Jogo Detectado: " .. GameName)

local Settings = {
    Aimbot = false,
    FOV = 160,
    Smoothing = 0.28,
    AimPart = "Head",
    TeamCheck = true,
    ESP = true,
    Boxes = true,
    HealthBar = true,
    Names = true,
    Noclip = false,
    Speed = 50,
    JumpPower = 50,
    ShowFOV = true,
}

-- ==================== DETECÇÃO DE JOGO ====================
local AimPartPriority = {"Head", "UpperTorso", "HumanoidRootPart", "Torso"}

if GameName:find("arsenal") or GameName:find("phantom") then
    Settings.FOV = 120
    Settings.Smoothing = 0.22
    print("🔧 Modo Arsenal/Phantom otimizado")
elseif GameName:find("bedwars") or GameName:find("skywars") then
    Settings.AimPart = "Head"
    print("🔧 Modo Bedwars otimizado")
end

-- GUI (Ícone + Menu)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game.CoreGui

local Icon = Instance.new("TextButton")
Icon.Size = UDim2.new(0,70,0,70)
Icon.Position = UDim2.new(1,-100,0,30)
Icon.BackgroundColor3 = Color3.fromRGB(0,255,200)
Icon.Text = "🔥"
Icon.TextSize = 36
Icon.Parent = ScreenGui
Instance.new("UICorner", Icon).CornerRadius = UDim.new(1,0)

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0,370,0,550)
Main.Position = UDim2.new(0.5,-185,0.5,-275)
Main.BackgroundColor3 = Color3.fromRGB(20,20,28)
Main.Visible = false
Main.Parent = ScreenGui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0,16)

-- Título
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1,0,0,55)
TitleBar.BackgroundColor3 = Color3.fromRGB(0,255,180)
TitleBar.Parent = Main
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0,16)

Instance.new("TextLabel", TitleBar).Text = "🔥 NEON UNIVERSAL HUB"
Instance.new("TextLabel", TitleBar).Size = UDim2.new(1,-60,1,0)
Instance.new("TextLabel", TitleBar).BackgroundTransparency = 1
Instance.new("TextLabel", TitleBar).TextColor3 = Color3.new(0,0,0)
Instance.new("TextLabel", TitleBar).Font = Enum.Font.GothamBold
Instance.new("TextLabel", TitleBar).TextSize = 21

local CloseBtn = Instance.new("TextButton")
CloseBtn.Text = "✕"
CloseBtn.Size = UDim2.new(0,40,0,40)
CloseBtn.Position = UDim2.new(1,-48,0,8)
CloseBtn.BackgroundTransparency = 1
CloseBtn.TextColor3 = Color3.fromRGB(255,60,60)
CloseBtn.TextSize = 30
CloseBtn.Parent = TitleBar

-- Scrolling
local Scrolling = Instance.new("ScrollingFrame")
Scrolling.Size = UDim2.new(1,-20,1,-75)
Scrolling.Position = UDim2.new(0,10,0,65)
Scrolling.BackgroundTransparency = 1
Scrolling.ScrollBarThickness = 6
Scrolling.CanvasSize = UDim2.new(0,0,0,950)
Scrolling.Parent = Main

local List = Instance.new("UIListLayout", Scrolling)
List.Padding = UDim.new(0,8)

local function Toggle(text, default, callback)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1,-10,0,50)
    f.BackgroundColor3 = Color3.fromRGB(35,35,45)
    f.Parent = Scrolling
    Instance.new("UICorner", f).CornerRadius = UDim.new(0,12)
    
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.7,0,1,0)
    lbl.BackgroundTransparency = 1
    lbl.Text = "   "..text
    lbl.TextColor3 = Color3.new(1,1,1)
    lbl.Font = Enum.Font.GothamSemibold
    lbl.TextSize = 18
    lbl.Parent = f
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0,80,0,35)
    btn.Position = UDim2.new(0.75,0,0.5,-17.5)
    btn.BackgroundColor3 = default and Color3.fromRGB(0,255,140) or Color3.fromRGB(220,50,50)
    btn.Text = default and "ON" or "OFF"
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamBold
    btn.Parent = f
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,10)
    
    btn.MouseButton1Click:Connect(function()
        default = not default
        btn.BackgroundColor3 = default and Color3.fromRGB(0,255,140) or Color3.fromRGB(220,50,50)
        btn.Text = default and "ON" or "OFF"
        callback(default)
    end)
end

-- Adicionando opções
Toggle("Aimbot", Settings.Aimbot, function(v) Settings.Aimbot = v end)
Toggle("Mostrar FOV", Settings.ShowFOV, function(v) Settings.ShowFOV = v end)
Toggle("ESP + Vida", Settings.ESP, function(v) Settings.ESP = v end)
Toggle("Noclip", Settings.Noclip, function(v) Settings.Noclip = v end)
Toggle("Team Check", Settings.TeamCheck, function(v) Settings.TeamCheck = v end)

-- FOV Circle
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2.5
FOVCircle.Color = Color3.fromRGB(0, 255, 200)
FOVCircle.Transparency = 0.65
FOVCircle.NumSides = 100

-- ESP
local ESPDrawings = {}

local function CreateESP(plr)
    if plr == LocalPlayer then return end
    local box = Drawing.new("Square")
    box.Thickness = 2
    box.Filled = false
    box.Color = Color3.fromRGB(0,255,200)
    
    local name = Drawing.new("Text")
    name.Size = 15
    name.Color = Color3.new(1,1,1)
    name.Outline = true
    name.Center = true
    
    local health = Drawing.new("Square")
    health.Filled = true
    health.Color = Color3.fromRGB(0,255,0)
    
    ESPDrawings[plr] = {Box=box, Name=name, Health=health}
end

for _, p in pairs(Players:GetPlayers()) do CreateESP(p) end
Players.PlayerAdded:Connect(CreateESP)

-- ==================== MAIN LOOP ====================
RunService.RenderStepped:Connect(function()
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    FOVCircle.Radius = Settings.FOV
    FOVCircle.Visible = Settings.ShowFOV and Settings.Aimbot
    
    -- AIMBOT
    if Settings.Aimbot then
        local closestPart = nil
        local minDist = Settings.FOV
        
        local screenCenter = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
        
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                if Settings.TeamCheck and player.Team == LocalPlayer.Team then continue end
                
                for _, partName in ipairs(AimPartPriority) do
                    local part = player.Character:FindFirstChild(partName)
                    if part then
                        local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
                        if onScreen then
                            local dist = (Vector2.new(pos.X, pos.Y) - screenCenter).Magnitude
                            if dist < minDist then
                                minDist = dist
                                closestPart = part
                                break
                            end
                        end
                    end
                end
            end
        end
        
        if closestPart then
            local targetPos = Camera:WorldToViewportPoint(closestPart.Position)
            local mousePos = UserInputService:GetMouseLocation()
            local delta = (Vector2.new(targetPos.X, targetPos.Y) - mousePos) * Settings.Smoothing
            mousemoverel(delta.X, delta.Y)
        end
    end
    
    -- ESP
    if Settings.ESP then
        for plr, draw in pairs(ESPDrawings) do
            if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                local root = plr.Character.HumanoidRootPart
                local hum = plr.Character:FindFirstChild("Humanoid")
                local head = plr.Character:FindFirstChild("Head")
                
                if hum and head then
                    local rootPos = Camera:WorldToViewportPoint(root.Position)
                    local headPos = Camera:WorldToViewportPoint(head.Position)
                    
                    if rootPos.Z > 0 then
                        local height = (headPos.Y - (Camera:WorldToViewportPoint(root.Position - Vector3.new(0,3,0)).Y))
                        
                        draw.Box.Size = Vector2.new(height * 0.6, height * 1.6)
                        draw.Box.Position = Vector2.new(rootPos.X - draw.Box.Size.X/2, rootPos.Y - draw.Box.Size.Y/2)
                        draw.Box.Visible = Settings.Boxes
                        
                        draw.Name.Text = plr.Name .. " ["..math.floor(hum.Health).."]"
                        draw.Name.Position = Vector2.new(rootPos.X, headPos.Y - 20)
                        draw.Name.Visible = Settings.Names
                        
                        local hpPct = hum.Health / hum.MaxHealth
                        draw.Health.Size = Vector2.new(5, height * 1.6 * hpPct)
                        draw.Health.Position = Vector2.new(rootPos.X - draw.Box.Size.X/2 - 12, rootPos.Y - draw.Box.Size.Y/2 + (height * 1.6 * (1 - hpPct)))
                        draw.Health.Visible = Settings.HealthBar
                    end
                end
            else
                draw.Box.Visible = false
                draw.Name.Visible = false
                draw.Health.Visible = false
            end
        end
    end
    
    -- Movement
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        local hum = LocalPlayer.Character.Humanoid
        hum.WalkSpeed = Settings.Speed
        hum.JumpPower = Settings.JumpPower
        
        if Settings.Noclip then
            for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
                if v:IsA("BasePart") then v.CanCollide = false end
            end
        end
    end
end)

-- Controles
Icon.MouseButton1Click:Connect(function() Main.Visible = not Main.Visible end)
CloseBtn.MouseButton1Click:Connect(function() Main.Visible = false end)

UserInputService.InputBegan:Connect(function(i)
    if i.KeyCode == Enum.KeyCode.Insert then Main.Visible = not Main.Visible end
end)

print("✅ UNIVERSAL HUB CARREGADO!")
print("Funciona em Arsenal, Phantom Forces, Bedwars, MM2, etc.")
