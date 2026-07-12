-- === NEON AIM HUB v12 - Portal TP + Dano em Todos ===
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local Settings = {
    Aimbot = false,
    FOV = 95,
    Smoothing = 0.11,
    Strength = 1.85,
    TeamCheck = true,
    ShowFOV = true,
    Speed = 50,
    Noclip = false,
    Fling = false,
    FlingAll = false,
    DamageAll = false,     -- Nova: Dano/Facada em todos
}

-- GUI (mantida)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game.CoreGui

local Icon = Instance.new("TextButton")
Icon.Size = UDim2.new(0,70,0,70)
Icon.Position = UDim2.new(1,-95,0,35)
Icon.BackgroundColor3 = Color3.fromRGB(255,50,50)
Icon.Text = "🔥"
Icon.TextSize = 35
Icon.Parent = ScreenGui
Instance.new("UICorner", Icon).CornerRadius = UDim.new(1,0)

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 400, 0, 680)
Main.Position = UDim2.new(0.5, -200, 0.5, -340)
Main.BackgroundColor3 = Color3.fromRGB(18,18,25)
Main.Visible = false
Main.Parent = ScreenGui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0,16)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1,0,0,55)
Title.BackgroundColor3 = Color3.fromRGB(255,50,50)
Title.Text = "🔥 NEON HUB v12"
Title.TextColor3 = Color3.new(1,1,1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 23
Title.Parent = Main
Instance.new("UICorner", Title).CornerRadius = UDim.new(0,16)

local Close = Instance.new("TextButton")
Close.Size = UDim2.new(0,40,0,40)
Close.Position = UDim2.new(1,-48,0,8)
Close.BackgroundTransparency = 1
Close.Text = "✕"
Close.TextColor3 = Color3.new(1,1,1)
Close.TextSize = 30
Close.Parent = Main

-- Scrolling
local Scrolling = Instance.new("ScrollingFrame")
Scrolling.Size = UDim2.new(1,-20,1,-70)
Scrolling.Position = UDim2.new(0,10,0,65)
Scrolling.BackgroundTransparency = 1
Scrolling.ScrollBarThickness = 6
Scrolling.CanvasSize = UDim2.new(0,0,0,1100)
Scrolling.Parent = Main

local List = Instance.new("UIListLayout", Scrolling)
List.Padding = UDim.new(0,10)

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
    btn.Size = UDim2.new(0,85,0,38)
    btn.Position = UDim2.new(0.72,0,0.5,-19)
    btn.BackgroundColor3 = def and Color3.fromRGB(0,255,120) or Color3.fromRGB(255,70,70)
    btn.Text = def and "ON" or "OFF"
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamBold
    btn.Parent = f
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,10)
    
    btn.MouseButton1Click:Connect(function()
        def = not def
        btn.BackgroundColor3 = def and Color3.fromRGB(0,255,120) or Color3.fromRGB(255,70,70)
        btn.Text = def and "ON" or "OFF"
        cb(def)
    end)
end

-- Opções
Toggle("Aimbot (Cabeça)", Settings.Aimbot, function(v) Settings.Aimbot = v end)
Toggle("Mostrar FOV", Settings.ShowFOV, function(v) Settings.ShowFOV = v end)
Toggle("Noclip", Settings.Noclip, function(v) Settings.Noclip = v end)
Toggle("Fling Mais Próximo", Settings.Fling, function(v) Settings.Fling = v end)
Toggle("Fling Todos", Settings.FlingAll, function(v) Settings.FlingAll = v end)
Toggle("Dano/Facada em Todos", Settings.DamageAll, function(v) Settings.DamageAll = v end)

-- Teleport para Portal
local PortalBtn = Instance.new("TextButton")
PortalBtn.Size = UDim2.new(1,-20,0,50)
PortalBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
PortalBtn.Text = "Teleport para Portal Mais Próximo"
PortalBtn.TextColor3 = Color3.new(1,1,1)
PortalBtn.Font = Enum.Font.GothamBold
PortalBtn.TextSize = 16
PortalBtn.Parent = Scrolling
Instance.new("UICorner", PortalBtn).CornerRadius = UDim.new(0,12)

PortalBtn.MouseButton1Click:Connect(function()
    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end
    
    local closestPortal = nil
    local minDist = math.huge
    
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj.Name:lower():find("portal") or obj.Name:lower():find("gate") or 
           (obj:IsA("Part") and obj.Transparency < 0.8 and obj.Size.Magnitude < 30) then
            local dist = (obj.Position - myRoot.Position).Magnitude
            if dist < minDist then
                minDist = dist
                closestPortal = obj
            end
        end
    end
    
    if closestPortal then
        myRoot.CFrame = closestPortal.CFrame + Vector3.new(0,5,0)
        print("Teletransportado para portal!")
    else
        print("Nenhum portal encontrado.")
    end
end)

-- Teleport para Jogador (mantido)
local TpBtn = Instance.new("TextButton")
TpBtn.Size = UDim2.new(1,-20,0,50)
TpBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
TpBtn.Text = "Teleport para Jogador Mais Próximo"
TpBtn.TextColor3 = Color3.new(1,1,1)
TpBtn.Font = Enum.Font.GothamBold
TpBtn.TextSize = 16
TpBtn.Parent = Scrolling
Instance.new("UICorner", TpBtn).CornerRadius = UDim.new(0,12)

TpBtn.MouseButton1Click:Connect(function()
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

-- FLING + DANO
local function Fling(targetChar)
    if not targetChar or not targetChar:FindFirstChild("HumanoidRootPart") then return end
    local root = targetChar.HumanoidRootPart
    local bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bv.Velocity = Vector3.new(math.random(-120,120), 120, math.random(-120,120))
    bv.Parent = root
    game.Debris:AddItem(bv, 1)
end

local function DamageAll()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Humanoid") then
            plr.Character.Humanoid:TakeDamage(25)  -- Dano forte
        end
    end
end

RunService.RenderStepped:Connect(function()
    -- Aimbot (mantido)
    if Settings.Aimbot then
        -- (código completo do aimbot anterior)
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
    
    -- Fling
    if Settings.Fling then
        local closest = nil
        local minD = math.huge
        local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if myRoot then
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                    local d = (plr.Character.HumanoidRootPart.Position - myRoot.Position).Magnitude
                    if d < minD then
                        minD = d
                        closest = plr.Character
                    end
                end
            end
            if closest then Fling(closest) end
        end
    end
    
    if Settings.FlingAll then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then Fling(plr.Character) end
        end
    end
    
    if Settings.DamageAll then
        DamageAll()
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

print("✅ Portal TP + Dano em Todos adicionados!")
