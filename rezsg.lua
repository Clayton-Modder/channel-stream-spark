-- === NEON AIM HUB v8 - AIMBOT PRECISO NA CABEÇA ===
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local Settings = {
    Aimbot = false,
    FOV = 95,           -- FOV bom para precisão
    Smoothing = 0.11,   -- Gruda forte
    Strength = 1.85,    -- Força extra de puxada
    TeamCheck = true,
    ShowFOV = true,
}

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game.CoreGui

local Icon = Instance.new("TextButton")
Icon.Size = UDim2.new(0,70,0,70)
Icon.Position = UDim2.new(1,-95,0,35)
Icon.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
Icon.Text = "🎯"
Icon.TextSize = 38
Icon.Font = Enum.Font.GothamBold
Icon.Parent = ScreenGui
Instance.new("UICorner", Icon).CornerRadius = UDim.new(1,0)

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 360, 0, 340)
Main.Position = UDim2.new(0.5, -180, 0.5, -170)
Main.BackgroundColor3 = Color3.fromRGB(15,15,22)
Main.Visible = false
Main.Parent = ScreenGui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0,16)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1,0,0,55)
Title.BackgroundColor3 = Color3.fromRGB(255,50,50)
Title.Text = "🎯 AIMBOT NA CABEÇA v8"
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

-- Toggle
local function Toggle(text, def, cb)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1,-30,0,60)
    f.Position = UDim2.new(0,15,0,80)
    f.BackgroundColor3 = Color3.fromRGB(35,35,45)
    f.Parent = Main
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
    btn.BackgroundColor3 = def and Color3.fromRGB(0,255,100) or Color3.fromRGB(255,70,70)
    btn.Text = def and "ON" or "OFF"
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamBold
    btn.Parent = f
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,10)
    
    btn.MouseButton1Click:Connect(function()
        def = not def
        btn.BackgroundColor3 = def and Color3.fromRGB(0,255,100) or Color3.fromRGB(255,70,70)
        btn.Text = def and "ON" or "OFF"
        cb(def)
    end)
end

Toggle("Aimbot (Gruda na Cabeça)", Settings.Aimbot, function(v) Settings.Aimbot = v end)
Toggle("Mostrar FOV", Settings.ShowFOV, function(v) Settings.ShowFOV = v end)

local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 3
FOVCircle.Color = Color3.fromRGB(255, 80, 80)
FOVCircle.Transparency = 0.55

-- AIMBOT FORTE E PRECISO
RunService.RenderStepped:Connect(function()
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    FOVCircle.Radius = Settings.FOV
    FOVCircle.Visible = Settings.ShowFOV and Settings.Aimbot
    
    if not Settings.Aimbot then return end
    
    local bestTarget = nil
    local closestDist = Settings.FOV + 5
    local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            if Settings.TeamCheck and player.Team == LocalPlayer.Team then continue end
            
            local head = player.Character:FindFirstChild("Head")
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
        local mousePos = UserInputService:GetMouseLocation()
        
        local deltaX = (targetPos.X - mousePos.X) * Settings.Smoothing * Settings.Strength
        local deltaY = (targetPos.Y - mousePos.Y) * Settings.Smoothing * Settings.Strength
        
        mousemoverel(deltaX, deltaY)
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

print("✅ AIMBOT NA CABEÇA ATIVADO!")
print("Teste com FOV 95 e Smoothing 0.11")
