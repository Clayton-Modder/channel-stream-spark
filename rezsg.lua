-- === NEON HUB v22 - TELEPORTE AVANÇADO ===
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
    AutoRevive = false,
    GodMode = false,
    LoopTeleport = false,
}

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game.CoreGui

local Icon = Instance.new("TextButton")
Icon.Size = UDim2.new(0,80,0,80)
Icon.Position = UDim2.new(1,-110,0,25)
Icon.BackgroundColor3 = Color3.fromRGB(0, 100, 255)
Icon.Text = "🌌"
Icon.TextSize = 42
Icon.Parent = ScreenGui
Instance.new("UICorner", Icon).CornerRadius = UDim.new(1,0)

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 440, 0, 780)
Main.Position = UDim2.new(0.5, -220, 0.5, -390)
Main.BackgroundColor3 = Color3.fromRGB(18,18,25)
Main.Visible = false
Main.Parent = ScreenGui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0,16)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1,0,0,65)
Title.BackgroundColor3 = Color3.fromRGB(0, 80, 200)
Title.Text = "🌌 TELEPORTE AVANÇADO v22"
Title.TextColor3 = Color3.new(1,1,1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 24
Title.Parent = Main

local Close = Instance.new("TextButton")
Close.Size = UDim2.new(0,45,0,45)
Close.Position = UDim2.new(1,-52,0,10)
Close.BackgroundTransparency = 1
Close.Text = "✕"
Close.TextColor3 = Color3.new(1,1,1)
Close.TextSize = 32
Close.Parent = Title

local Scrolling = Instance.new("ScrollingFrame")
Scrolling.Size = UDim2.new(1, -20, 1, -85)
Scrolling.Position = UDim2.new(0, 10, 0, 75)
Scrolling.BackgroundTransparency = 1
Scrolling.ScrollBarThickness = 8
Scrolling.Parent = Main

local UIList = Instance.new("UIListLayout", Scrolling)
UIList.Padding = UDim.new(0, 12)
UIList.SortOrder = Enum.SortOrder.LayoutOrder

UIList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    Scrolling.CanvasSize = UDim2.new(0, 0, 0, UIList.AbsoluteContentSize.Y + 60)
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

-- Opções Avançadas de Teleporte
Toggle("Aimbot", Settings.Aimbot, function(v) Settings.Aimbot = v end)
Toggle("Auto Reviver", Settings.AutoRevive, function(v) Settings.AutoRevive = v end)
Toggle("God Mode", Settings.GodMode, function(v) Settings.GodMode = v end)
Toggle("Noclip", Settings.Noclip, function(v) Settings.Noclip = v end)

-- TELEPORTE AVANÇADO
local TpPlayerBtn = Instance.new("TextButton")
TpPlayerBtn.Size = UDim2.new(1,-20,0,55)
TpPlayerBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
TpPlayerBtn.Text = "Teleport para Jogador Mais Próximo"
TpPlayerBtn.TextColor3 = Color3.new(1,1,1)
TpPlayerBtn.Font = Enum.Font.GothamBold
TpPlayerBtn.TextSize = 16
TpPlayerBtn.Parent = Scrolling
Instance.new("UICorner", TpPlayerBtn).CornerRadius = UDim.new(0,12)

TpPlayerBtn.MouseButton1Click:Connect(function()
    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end
    local closest, minDist = nil, math.huge
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (plr.Character.HumanoidRootPart.Position - myRoot.Position).Magnitude
            if dist < minDist then
                minDist = dist
                closest = plr.Character.HumanoidRootPart
            end
        end
    end
    if closest then myRoot.CFrame = closest.CFrame + Vector3.new(0,5,0) end
end)

local TpPortalBtn = Instance.new("TextButton")
TpPortalBtn.Size = UDim2.new(1,-20,0,55)
TpPortalBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
TpPortalBtn.Text = "Teleport para Portal Mais Próximo"
TpPortalBtn.TextColor3 = Color3.new(1,1,1)
TpPortalBtn.Font = Enum.Font.GothamBold
TpPortalBtn.TextSize = 16
TpPortalBtn.Parent = Scrolling
Instance.new("UICorner", TpPortalBtn).CornerRadius = UDim.new(0,12)

TpPortalBtn.MouseButton1Click:Connect(function()
    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end
    local closest, minDist = nil, math.huge
    for _, obj in ipairs(Workspace:GetDescendants()) do
        local name = obj.Name:lower()
        if name:find("portal") or name:find("gate") or name:find("tele") or name:find("door") then
            local pos = obj.Position or (obj.PrimaryPart and obj.PrimaryPart.Position)
            if pos then
                local dist = (pos - myRoot.Position).Magnitude
                if dist < minDist then
                    minDist = dist
                    closest = pos
                end
            end
        end
    end
    if closest then
        myRoot.CFrame = CFrame.new(closest + Vector3.new(0,6,0))
    end
end)

-- LOOP TELEPORT (Avançado)
local LoopTpBtn = Instance.new("TextButton")
LoopTpBtn.Size = UDim2.new(1,-20,0,55)
LoopTpBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
LoopTpBtn.Text = "Loop Teleport (Ativar/Desativar)"
LoopTpBtn.TextColor3 = Color3.new(1,1,1)
LoopTpBtn.Font = Enum.Font.GothamBold
LoopTpBtn.TextSize = 16
LoopTpBtn.Parent = Scrolling
Instance.new("UICorner", LoopTpBtn).CornerRadius = UDim.new(0,12)

LoopTpBtn.MouseButton1Click:Connect(function()
    Settings.LoopTeleport = not Settings.LoopTeleport
    LoopTpBtn.Text = Settings.LoopTeleport and "Loop Teleport: LIGADO" or "Loop Teleport (Ativar/Desativar)"
end)

-- PUXAR MOEDAS + ITENS
local PullBtn = Instance.new("TextButton")
PullBtn.Size = UDim2.new(1,-20,0,55)
PullBtn.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
PullBtn.Text = "Puxar Todas Moedas / Itens"
PullBtn.TextColor3 = Color3.new(1,1,1)
PullBtn.Font = Enum.Font.GothamBold
PullBtn.TextSize = 16
PullBtn.Parent = Scrolling
Instance.new("UICorner", PullBtn).CornerRadius = UDim.new(0,12)

PullBtn.MouseButton1Click:Connect(function()
    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Part") or obj:IsA("MeshPart") then
            local name = obj.Name:lower()
            if name:find("coin") or name:find("moeda") or name:find("money") or name:find("gem") or name:find("item") then
                obj.CFrame = myRoot.CFrame + Vector3.new(math.random(-3,3), 3, math.random(-3,3))
            end
        end
    end
end)

-- Loop Principal
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
    
    if Settings.LoopTeleport then
        local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if myRoot then
            myRoot.CFrame = myRoot.CFrame + myRoot.CFrame.LookVector * 0.5
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

-- Controles
Icon.MouseButton1Click:Connect(function() Main.Visible = not Main.Visible end)
Close.MouseButton1Click:Connect(function() Main.Visible = false end)

UserInputService.InputBegan:Connect(function(i)
    if i.KeyCode == Enum.KeyCode.Insert then
        Main.Visible = not Main.Visible
    end
end)

print("✅ TELEPORTE AVANÇADO ATIVADO!")
print("Use INSERT para abrir o menu")
