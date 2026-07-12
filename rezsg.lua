-- 🔥 SCRIPT COM MENU - Mira Auto + Puxar + Teleporte + Noclip
-- Pressione INSERT para abrir/fechar o menu

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Camera = Workspace.CurrentCamera

-- Variáveis
local aimbotEnabled = true
local pullEnabled = true
local noclipEnabled = false
local menuOpen = true

-- Criar GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CheatMenu"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 280, 0, 320)
MainFrame.Position = UDim2.new(0.5, -140, 0.5, -160)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 50)
Title.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
Title.Text = "🔥 MENU DE CHEATS"
Title.TextColor3 = Color3.new(1,1,1)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

-- Função para criar botão
local function CreateButton(name, yOffset, callback)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(0.9, 0, 0, 45)
    Btn.Position = UDim2.new(0.05, 0, 0, yOffset)
    Btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Btn.Text = name
    Btn.TextColor3 = Color3.new(1,1,1)
    Btn.TextScaled = true
    Btn.Font = Enum.Font.GothamSemibold
    Btn.Parent = MainFrame
    
    Btn.MouseButton1Click:Connect(function()
        callback()
        -- Efeito de clique
        Btn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
        wait(0.1)
        Btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    end)
    return Btn
end

-- Botões do Menu
CreateButton("🔫 Mira Automática: " .. (aimbotEnabled and "ON" or "OFF"), 60, function()
    aimbotEnabled = not aimbotEnabled
    print("Aimbot:", aimbotEnabled and "ON" or "OFF")
end)

CreateButton("🧲 Puxar Itens: " .. (pullEnabled and "ON" or "OFF"), 115, function()
    pullEnabled = not pullEnabled
    print("Puxador:", pullEnabled and "ON" or "OFF")
end)

CreateButton("👻 Noclip: " .. (noclipEnabled and "ON" or "OFF"), 170, function()
    noclipEnabled = not noclipEnabled
    print("Noclip:", noclipEnabled and "ON" or "OFF")
end)

CreateButton("📍 Teleportar para Mais Próximo", 225, function()
    local target = getClosestPlayer()
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 4, 0)
    end
end)

-- Funções principais (mesmas do script anterior, mas otimizadas)

local function getClosestPlayer()
    local closest = nil
    local shortest = math.huge
    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (myRoot.Position - plr.Character.HumanoidRootPart.Position).Magnitude
            if dist < shortest and dist <= 150 then
                if not (plr.Team == LocalPlayer.Team and plr.Team ~= nil) then
                    shortest = dist
                    closest = plr
                end
            end
        end
    end
    return closest
end

-- Aimbot
RunService.RenderStepped:Connect(function()
    if not aimbotEnabled then return end
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end

    local target = getClosestPlayer()
    if target and target.Character and target.Character:FindFirstChild("Head") then
        local headPos = target.Character.Head.Position
        local lookAt = CFrame.lookAt(Camera.CFrame.Position, headPos)
        Camera.CFrame = Camera.CFrame:Lerp(lookAt, 0.1)
    end
end)

-- Puxar Itens
RunService.Heartbeat:Connect(function()
    if not pullEnabled then return end
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end

    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and (obj.Position - root.Position).Magnitude < 80 then
            local n = obj.Name:lower()
            if n:find("coin") or n:find("drop") or n:find("item") or n:find("gem") then
                obj.CFrame = root.CFrame + Vector3.new(0, 3, 0)
            end
        end
    end
end)

-- Noclip
RunService.Stepped:Connect(function()
    if not LocalPlayer.Character then return end
    for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = not noclipEnabled
        end
    end
end)

-- Abrir/Fechar Menu com INSERT
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Insert then
        menuOpen = not menuOpen
        MainFrame.Visible = menuOpen
    end
end)

print("✅ Menu carregado! Pressione INSERT para abrir/fechar")
