-- === NEON HUB v15 - Sobreviva o Assassino ===
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local Settings = {
    Aimbot = false,
    FOV = 100,
    Smoothing = 0.12,
    Speed = 55,
    Noclip = false,
    Fling = false,
    FlingAll = false,
    DamageAll = false,
    AutoRevive = false,      -- Auto Reviver
    KillAura = false,        -- Nova: Kill Aura
    GodMode = false,         -- Nova: God Mode
}

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game.CoreGui

local Icon = Instance.new("TextButton")
Icon.Size = UDim2.new(0,75,0,75)
Icon.Position = UDim2.new(1,-100,0,30)
Icon.BackgroundColor3 = Color3.fromRGB(255, 40, 40)
Icon.Text = "🩸"
Icon.TextSize = 40
Icon.Parent = ScreenGui
Instance.new("UICorner", Icon).CornerRadius = UDim.new(1,0)

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 410, 0, 680)
Main.Position = UDim2.new(0.5, -205, 0.5, -340)
Main.BackgroundColor3 = Color3.fromRGB(20,20,25)
Main.Visible = false
Main.Parent = ScreenGui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0,16)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1,0,0,60)
Title.BackgroundColor3 = Color3.fromRGB(200,0,0)
Title.Text = "🩸 SOBREVIVA O ASSASSINO"
Title.TextColor3 = Color3.new(1,1,1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 22
Title.Parent = Main

-- Scrolling
local Scrolling = Instance.new("ScrollingFrame")
Scrolling.Size = UDim2.new(1,-20,1,-80)
Scrolling.Position = UDim2.new(0,10,0,70)
Scrolling.BackgroundTransparency = 1
Scrolling.ScrollBarThickness = 6
Scrolling.CanvasSize = UDim2.new(0,0,0,1300)
Scrolling.Parent = Main

local function Toggle(text, def, cb)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1,-20,0,55)
    f.BackgroundColor3 = Color3.fromRGB(35,35,45)
    f.Parent = Scrolling
    Instance.new("UICorner", f).CornerRadius = UDim.new(0,12)
    
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.65,0,1,0)
    lbl.BackgroundTransparency = 1
    lbl.Text = "   "..text
    lbl.TextColor3 = Color3.new(1,1,1)
    lbl.Font = Enum.Font.GothamSemibold
    lbl.TextSize = 18
    lbl.Parent = f
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0,90,0,38)
    btn.Position = UDim2.new(0.7,0,0.5,-19)
    btn.BackgroundColor3 = def and Color3.fromRGB(0,255,120) or Color3.fromRGB(255,60,60)
    btn.Text = def and "ON" or "OFF"
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamBold
    btn.Parent = f
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,10)
    
    btn.MouseButton1Click:Connect(function()
        def = not def
        btn.BackgroundColor3 = def and Color3.fromRGB(0,255,120) or Color3.fromRGB(255,60,60)
        btn.Text = def and "ON" or "OFF"
        cb(def)
    end)
end

Toggle("Aimbot (Cabeça)", Settings.Aimbot, function(v) Settings.Aimbot = v end)
Toggle("Auto Reviver", Settings.AutoRevive, function(v) Settings.AutoRevive = v end)
Toggle("Kill Aura (Dano)", Settings.KillAura, function(v) Settings.KillAura = v end)
Toggle("God Mode", Settings.GodMode, function(v) Settings.GodMode = v end)
Toggle("Noclip", Settings.Noclip, function(v) Settings.Noclip = v end)
Toggle("Fling Mais Próximo", Settings.Fling, function(v) Settings.Fling = v end)
Toggle("Fling Todos", Settings.FlingAll, function(v) Settings.FlingAll = v end)

-- Auto Reviver Corrigido
RunService.Heartbeat:Connect(function()
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
    
    if Settings.GodMode and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.MaxHealth = math.huge
        LocalPlayer.Character.Humanoid.Health = math.huge
    end
    
    if Settings.KillAura then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Humanoid") then
                local dist = (plr.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                if dist < 20 then
                    plr.Character.Humanoid:TakeDamage(35)
                end
            end
        end
    end
end)

-- Aimbot (mantido forte)
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
            local dx = (tPos.X - mPos.X) * Settings.Smoothing * Settings.Strength
            local dy = (tPos.Y - mPos.Y) * Settings.Smoothing * Settings.Strength
            mousemoverel(dx, dy)
        end
    end
    
    -- Speed + Noclip
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = Settings.Speed
        if Settings.Noclip then
            for _, p in pairs(LocalPlayer.Character:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = false end
            end
        end
    end
end)

-- Controles
Icon.MouseButton1Click:Connect(function() Main.Visible = not Main.Visible end)
Close.MouseButton1Click:Connect(function() Main.Visible = false end)

UserInputService.InputBegan:Connect(function(i)
    if i.KeyCode == Enum.KeyCode.Insert then Main.Visible = not Main.Visible end
end)

print("✅ Cheat para Sobreviva o Assassino carregado!")
print("Use INSERT para abrir o menu")
