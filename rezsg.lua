-- === NEON AIM HUB v6 - AIMBOT PRECISO (Gruda na Cabeça) ===
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local Settings = {
    Aimbot = false,
    FOV = 90,          -- Reduzi um pouco para mais precisão
    Smoothing = 0.18,  -- Mais suave e preciso
    AimPart = "Head",
    TeamCheck = true,
    ShowFOV = true,
}

-- GUI (Ícone + Menu resumido)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game.CoreGui

local Icon = Instance.new("TextButton")
Icon.Size = UDim2.new(0,70,0,70)
Icon.Position = UDim2.new(1,-100,0,30)
Icon.BackgroundColor3 = Color3.fromRGB(0,255,200)
Icon.Text = "🎯"
Icon.TextSize = 36
Icon.Parent = ScreenGui
Instance.new("UICorner", Icon).CornerRadius = UDim.new(1,0)

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0,360,0,400)
Main.Position = UDim2.new(0.5,-180,0.5,-200)
Main.BackgroundColor3 = Color3.fromRGB(20,20,28)
Main.Visible = false
Main.Parent = ScreenGui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0,16)

-- Título
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1,0,0,50)
TitleBar.BackgroundColor3 = Color3.fromRGB(0,255,180)
TitleBar.Parent = Main
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0,16)

Instance.new("TextLabel", TitleBar).Text = "🎯 AIMBOT PRECISO v6"
Instance.new("TextLabel", TitleBar).Size = UDim2.new(1,0,1,0)
Instance.new("TextLabel", TitleBar).BackgroundTransparency = 1
Instance.new("TextLabel", TitleBar).TextColor3 = Color3.new(0,0,0)
Instance.new("TextLabel", TitleBar).Font = Enum.Font.GothamBold
Instance.new("TextLabel", TitleBar).TextSize = 22

local CloseBtn = Instance.new("TextButton")
CloseBtn.Text = "✕"
CloseBtn.Size = UDim2.new(0,40,0,40)
CloseBtn.Position = UDim2.new(1,-45,0,5)
CloseBtn.BackgroundTransparency = 1
CloseBtn.TextColor3 = Color3.fromRGB(255,60,60)
CloseBtn.TextSize = 28
CloseBtn.Parent = TitleBar

-- Toggle Simples
local function CreateToggle(text, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1,-20,0,50)
    frame.Position = UDim2.new(0,10,0,60)
    frame.BackgroundColor3 = Color3.fromRGB(35,35,45)
    frame.Parent = Main
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0,12)
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.6,0,1,0)
    label.BackgroundTransparency = 1
    label.Text = "   " .. text
    label.TextColor3 = Color3.new(1,1,1)
    label.Font = Enum.Font.GothamSemibold
    label.TextSize = 18
    label.Parent = frame
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0,80,0,35)
    btn.Position = UDim2.new(0.75,0,0.5,-17.5)
    btn.BackgroundColor3 = default and Color3.fromRGB(0,255,100) or Color3.fromRGB(255,60,60)
    btn.Text = default and "ON" or "OFF"
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamBold
    btn.Parent = frame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,10)
    
    btn.MouseButton1Click:Connect(function()
        default = not default
        btn.BackgroundColor3 = default and Color3.fromRGB(0,255,100) or Color3.fromRGB(255,60,60)
        btn.Text = default and "ON" or "OFF"
        callback(default)
    end)
end

CreateToggle("Aimbot (Gruda na Cabeça)", Settings.Aimbot, function(v) Settings.Aimbot = v end)
CreateToggle("Mostrar FOV", Settings.ShowFOV, function(v) Settings.ShowFOV = v end)

-- FOV Circle
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 3
FOVCircle.Color = Color3.fromRGB(0, 255, 150)
FOVCircle.Transparency = 0.6
FOVCircle.NumSides = 100

-- ==================== AIMBOT PRECISO ====================
RunService.RenderStepped:Connect(function()
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    FOVCircle.Radius = Settings.FOV
    FOVCircle.Visible = Settings.ShowFOV and Settings.Aimbot
    
    if Settings.Aimbot then
        local closest = nil
        local bestDist = Settings.FOV + 10
        local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                if Settings.TeamCheck and player.Team == LocalPlayer.Team then continue end
                
                -- Prioridade máxima para a cabeça
                local targetPart = player.Character:FindFirstChild("Head") or 
                                  player.Character:FindFirstChild("UpperTorso") or 
                                  player.Character:FindFirstChild("HumanoidRootPart")
                
                if targetPart then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                    if onScreen then
                        local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                        if dist < bestDist then
                            bestDist = dist
                            closest = targetPart
                        end
                    end
                end
            end
        end
        
        if closest then
            local targetPos = Camera:WorldToViewportPoint(closest.Position)
            local mousePos = UserInputService:GetMouseLocation()
            
            -- Cálculo mais preciso
            local deltaX = (targetPos.X - mousePos.X) * Settings.Smoothing
            local deltaY = (targetPos.Y - mousePos.Y) * Settings.Smoothing
            
            mousemoverel(deltaX, deltaY)
        end
    end
end)

-- Controles
Icon.MouseButton1Click:Connect(function() Main.Visible = not Main.Visible end)
CloseBtn.MouseButton1Click:Connect(function() Main.Visible = false end)

UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Insert then
        Main.Visible = not Main.Visible
    end
end)

print("✅ AIMBOT PRECISO ATIVADO!")
print("Ele agora gruda forte na cabeça. Ajuste o FOV e Smoothing se precisar.")
