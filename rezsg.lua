-- === NEON AIM HUB v9 - Com Speed + Teleport ===
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
}

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game.CoreGui

local Icon = Instance.new("TextButton")
Icon.Size = UDim2.new(0,70,0,70)
Icon.Position = UDim2.new(1,-95,0,35)
Icon.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
Icon.Text = "🔥"
Icon.TextSize = 35
Icon.Parent = ScreenGui
Instance.new("UICorner", Icon).CornerRadius = UDim.new(1,0)

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 380, 0, 520)
Main.Position = UDim2.new(0.5, -190, 0.5, -260)
Main.BackgroundColor3 = Color3.fromRGB(18,18,25)
Main.Visible = false
Main.Parent = ScreenGui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0,16)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1,0,0,55)
Title.BackgroundColor3 = Color3.fromRGB(255,50,50)
Title.Text = "🔥 NEON HUB v9"
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
Scrolling.CanvasSize = UDim2.new(0,0,0,700)
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

local function Slider(text, min, max, def, cb)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1,-20,0,70)
    f.BackgroundColor3 = Color3.fromRGB(35,35,45)
    f.Parent = Scrolling
    Instance.new("UICorner", f).CornerRadius = UDim.new(0,12)
    
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1,0,0,25)
    lbl.BackgroundTransparency = 1
    lbl.Text = text .. ": " .. def
    lbl.TextColor3 = Color3.new(1,1,1)
    lbl.Font = Enum.Font.Gotham
    lbl.Parent = f
    
    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(0.9,0,0,12)
    bar.Position = UDim2.new(0.05,0,0.6,0)
    bar.BackgroundColor3 = Color3.fromRGB(60,60,70)
    bar.Parent = f
    Instance.new("UICorner", bar).CornerRadius = UDim.new(1,0)
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((def-min)/(max-min),0,1,0)
    fill.BackgroundColor3 = Color3.fromRGB(0,255,150)
    fill.Parent = bar
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1,0)
    
    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local conn = RunService.RenderStepped:Connect(function()
                local mouseX = UserInputService:GetMouseLocation().X
                local percent = math.clamp((mouseX - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
                local val = math.floor(min + (max - min) * percent)
                fill.Size = UDim2.new(percent,0,1,0)
                lbl.Text = text .. ": " .. val
                cb(val)
            end)
            local stop
            stop = UserInputService.InputEnded:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 then
                    conn:Disconnect()
                    stop:Disconnect()
                end
            end)
        end
    end)
end

-- Opções
Toggle("Aimbot (Cabeça)", Settings.Aimbot, function(v) Settings.Aimbot = v end)
Toggle("Mostrar FOV", Settings.ShowFOV, function(v) Settings.ShowFOV = v end)
Toggle("Noclip", Settings.Noclip, function(v) Settings.Noclip = v end)
Slider("Speed", 16, 120, Settings.Speed, function(v) Settings.Speed = v end)

-- Teleport Button
local TpBtn = Instance.new("TextButton")
TpBtn.Size = UDim2.new(1,-20,0,50)
TpBtn.Position = UDim2.new(0,10,0,300)
TpBtn.BackgroundColor3 = Color3.fromRGB(0,170,255)
TpBtn.Text = "Teleport para Jogador Mais Próximo"
TpBtn.TextColor3 = Color3.new(1,1,1)
TpBtn.Font = Enum.Font.GothamBold
TpBtn.TextSize = 16
TpBtn.Parent = Scrolling
Instance.new("UICorner", TpBtn).CornerRadius = UDim.new(0,12)

TpBtn.MouseButton1Click:Connect(function()
    local closest = nil
    local shortest = math.huge
    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    
    if not myRoot then return end
    
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (plr.Character.HumanoidRootPart.Position - myRoot.Position).Magnitude
            if dist < shortest then
                shortest = dist
                closest = plr.Character.HumanoidRootPart
            end
        end
    end
    
    if closest then
        myRoot.CFrame = closest.CFrame + Vector3.new(0, 4, 0)
        print("Teletransportado!")
    end
end)

-- FOV Circle
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 3
FOVCircle.Color = Color3.fromRGB(255, 80, 80)
FOVCircle.Transparency = 0.55

-- Main Loop
RunService.RenderStepped:Connect(function()
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    FOVCircle.Radius = Settings.FOV
    FOVCircle.Visible = Settings.ShowFOV and Settings.Aimbot
    
    -- Aimbot (mesmo do anterior)
    if Settings.Aimbot then
        local bestTarget = nil
        local closestDist = Settings.FOV
        local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
        
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                if Settings.TeamCheck and plr.Team == LocalPlayer.Team then continue end
                local head = plr.Character:FindFirstChild("Head")
                if head then
                    local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
                    if onScreen then
                        local dist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                        if dist < closestDist then
                            closestDist = dist
                            bestTarget = head
                        end
                    end
                end
            end
        end
        
        if bestTarget then
            local targetPos = Camera:WorldToViewportPoint(bestTarget.Position)
            local mouse = UserInputService:GetMouseLocation()
            local deltaX = (targetPos.X - mouse.X) * Settings.Smoothing * Settings.Strength
            local deltaY = (targetPos.Y - mouse.Y) * Settings.Smoothing * Settings.Strength
            mousemoverel(deltaX, deltaY)
        end
    end
    
    -- Speed + Noclip
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
    if i.KeyCode == Enum.KeyCode.Insert then Main.Visible = not Main.Visible end
end)

print("✅ Speed + Teleport adicionados!")
