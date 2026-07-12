-- === NEON HUB v19 - ANTI-DETECÇÃO ATIVADO ===
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local Settings = {
    Aimbot = false,
    FOV = 100,
    Smoothing = 0.13,      -- Mais humano
    Speed = 50,
    Noclip = false,
    Fling = false,
    FlingAll = false,
    KillAura = false,
    AutoRevive = false,
    GodMode = false,
    AntiDetect = true,     -- Sistema Anti-Detecção
}

-- ANTI-DETECÇÃO
local detectionRisk = 0
local lastAction = tick()

local function AntiDetectDelay(min, max)
    if not Settings.AntiDetect then return end
    task.wait(math.random(min*10, max*10)/10)
end

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game.CoreGui

local Icon = Instance.new("TextButton")
Icon.Size = UDim2.new(0,75,0,75)
Icon.Position = UDim2.new(1,-100,0,30)
Icon.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
Icon.Text = "🛡️"
Icon.TextSize = 38
Icon.Parent = ScreenGui
Instance.new("UICorner", Icon).CornerRadius = UDim.new(1,0)

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 410, 0, 720)
Main.Position = UDim2.new(0.5, -205, 0.5, -360)
Main.BackgroundColor3 = Color3.fromRGB(20,20,25)
Main.Visible = false
Main.Parent = ScreenGui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0,16)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1,0,0,60)
Title.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
Title.Text = "🛡️ NEON HUB v19 - ANTI DETECT"
Title.TextColor3 = Color3.new(1,1,1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 22
Title.Parent = Main

local Close = Instance.new("TextButton")
Close.Size = UDim2.new(0,40,0,40)
Close.Position = UDim2.new(1,-48,0,10)
Close.BackgroundTransparency = 1
Close.Text = "✕"
Close.TextColor3 = Color3.new(1,1,1)
Close.TextSize = 30
Close.Parent = Title

-- Scrolling
local Scrolling = Instance.new("ScrollingFrame")
Scrolling.Size = UDim2.new(1, -20, 1, -80)
Scrolling.Position = UDim2.new(0, 10, 0, 70)
Scrolling.BackgroundTransparency = 1
Scrolling.ScrollBarThickness = 8
Scrolling.Parent = Main

local UIList = Instance.new("UIListLayout", Scrolling)
UIList.Padding = UDim.new(0, 12)
UIList.SortOrder = Enum.SortOrder.LayoutOrder

UIList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    Scrolling.CanvasSize = UDim2.new(0, 0, 0, UIList.AbsoluteContentSize.Y + 40)
end)

local function Toggle(text, def, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 58)
    frame.BackgroundColor3 = Color3.fromRGB(35,35,45)
    frame.Parent = Scrolling
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0,12)
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.65, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = "   " .. text
    label.TextColor3 = Color3.new(1,1,1)
    label.Font = Enum.Font.GothamSemibold
    label.TextSize = 18
    label.Parent = frame
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 90, 0, 40)
    btn.Position = UDim2.new(0.72, 0, 0.5, -20)
    btn.BackgroundColor3 = def and Color3.fromRGB(0, 255, 120) or Color3.fromRGB(255, 60, 60)
    btn.Text = def and "ON" or "OFF"
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 16
    btn.Parent = frame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,10)
    
    btn.MouseButton1Click:Connect(function()
        def = not def
        btn.BackgroundColor3 = def and Color3.fromRGB(0,255,120) or Color3.fromRGB(255,60,60)
        btn.Text = def and "ON" or "OFF"
        callback(def)
    end)
end

Toggle("Aimbot (Cabeça)", Settings.Aimbot, function(v) Settings.Aimbot = v end)
Toggle("Auto Reviver", Settings.AutoRevive, function(v) Settings.AutoRevive = v end)
Toggle("Kill Aura", Settings.KillAura, function(v) Settings.KillAura = v end)
Toggle("God Mode", Settings.GodMode, function(v) Settings.GodMode = v end)
Toggle("Noclip", Settings.Noclip, function(v) Settings.Noclip = v end)
Toggle("Fling Mais Próximo", Settings.Fling, function(v) Settings.Fling = v end)
Toggle("Anti Detecção", Settings.AntiDetect, function(v) Settings.AntiDetect = v end)

-- LOOP COM ANTI-DETECÇÃO
RunService.RenderStepped:Connect(function()
    if Settings.Aimbot then
        AntiDetectDelay(0.01, 0.04)
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
            local dx = (tPos.X - mPos.X) * Settings.Smoothing * 1.6
            local dy = (tPos.Y - mPos.Y) * Settings.Smoothing * 1.6
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
    
    if Settings.KillAura then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if myRoot then
                    local dist = (plr.Character.HumanoidRootPart.Position - myRoot.Position).Magnitude
                    if dist < 22 then
                        plr.Character.Humanoid:TakeDamage(25)
                    end
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

-- Controles
Icon.MouseButton1Click:Connect(function() Main.Visible = not Main.Visible end)
Close.MouseButton1Click:Connect(function() Main.Visible = false end)

UserInputService.InputBegan:Connect(function(i)
    if i.KeyCode == Enum.KeyCode.Insert then
        Main.Visible = not Main.Visible
    end
end)

print("✅ ANTI-DETECÇÃO ATIVADO!")
print("Use com moderação para evitar ban")
