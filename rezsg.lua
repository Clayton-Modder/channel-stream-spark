-- SIMPLIFIED VERSION - TESTE AGORA

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

local aimbotEnabled = false
local freezeEnabled = false
local freezeRadius = 150

print("Script carregado! Pressione F para abrir menu")

-- Menu Simples
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer.PlayerGui

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 280, 0, 300)
Frame.Position = UDim2.new(0.5, -140, 0.5, -150)
Frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
Frame.Draggable = true
Frame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1,0,0,50)
Title.BackgroundColor3 = Color3.fromRGB(0,100,200)
Title.Text = "MENU DE TESTE"
Title.TextColor3 = Color3.new(1,1,1)
Title.TextScaled = true
Title.Parent = Frame

-- Botões
local function btn(text, y, callback)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0.9,0,0,45)
    b.Position = UDim2.new(0.05,0,0,y)
    b.BackgroundColor3 = Color3.fromRGB(40,40,40)
    b.Text = text
    b.TextColor3 = Color3.new(1,1,1)
    b.TextScaled = true
    b.Parent = Frame
    b.MouseButton1Click:Connect(callback)
end

btn("🔫 Aimbot: OFF", 60, function()
    aimbotEnabled = not aimbotEnabled
    print("Aimbot:", aimbotEnabled)
end)

btn("❄️ Congelar: OFF", 120, function()
    freezeEnabled = not freezeEnabled
    print("Congelar:", freezeEnabled)
end)

btn("Fechar Menu", 220, function() Frame.Visible = false end)

-- Aimbot Simples
RunService.RenderStepped:Connect(function()
    if not aimbotEnabled then return end
    if not LocalPlayer.Character then return end
    
    local closest = nil
    local minDist = 99999
    
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") then
            local dist = (LocalPlayer.Character.HumanoidRootPart.Position - plr.Character.Head.Position).Magnitude
            if dist < minDist then
                minDist = dist
                closest = plr
            end
        end
    end
    
    if closest then
        Camera.CFrame = Camera.CFrame:Lerp(CFrame.lookAt(Camera.CFrame.Position, closest.Character.Head.Position), 0.15)
    end
end)

-- Congelar
RunService.Heartbeat:Connect(function()
    if not freezeEnabled then return end
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Humanoid") then
            local dist = (root.Position - plr.Character.HumanoidRootPart.Position).Magnitude
            if dist <= freezeRadius then
                plr.Character.Humanoid.WalkSpeed = 0
                plr.Character.Humanoid.JumpPower = 0
            end
        end
    end
end)

-- Abrir menu com F
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.F then
        Frame.Visible = not Frame.Visible
    end
end)
