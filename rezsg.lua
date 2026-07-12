-- 🔥 MENU CHEAT ROBLOX - Carregado via GitHub Style

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = Workspace.CurrentCamera

local aimbotEnabled = true
local pullEnabled = true
local noclipEnabled = false

-- === MENU GUI ===
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 300, 0, 350)
Frame.Position = UDim2.new(0.5, -150, 0.5, -175)
Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1,0,0,50)
Title.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
Title.Text = "🔥 CHEAT MENU"
Title.TextColor3 = Color3.new(1,1,1)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold
Title.Parent = Frame

local function AddButton(text, posY, func)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9,0,0,50)
    btn.Position = UDim2.new(0.05,0,0,posY)
    btn.BackgroundColor3 = Color3.fromRGB(35,35,35)
    btn.Text = text
    btn.TextColor3 = Color3.new(1,1,1)
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamSemibold
    btn.Parent = Frame
    btn.MouseButton1Click:Connect(func)
end

AddButton("🔫 Aimbot: ON", 60, function() 
    aimbotEnabled = not aimbotEnabled 
    print("Aimbot:", aimbotEnabled and "ON" or "OFF") 
end)

AddButton("🧲 Puxar Itens: ON", 120, function() 
    pullEnabled = not pullEnabled 
    print("Pull:", pullEnabled and "ON" or "OFF") 
end)

AddButton("👻 Noclip: OFF", 180, function() 
    noclipEnabled = not noclipEnabled 
    print("Noclip:", noclipEnabled and "ON" or "OFF") 
end)

AddButton("📍 Teleportar Mais Próximo", 240, function()
    local closest = nil
    local dist = math.huge
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local d = (root.Position - p.Character.HumanoidRootPart.Position).Magnitude
            if d < dist then dist = d closest = p end
        end
    end
    if closest then
        root.CFrame = closest.Character.HumanoidRootPart.CFrame + Vector3.new(0,5,0)
    end
end)

-- Aimbot
RunService.RenderStepped:Connect(function()
    if not aimbotEnabled then return end
    local target = nil
    local minDist = 9999
    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end
    
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") then
            local d = (myRoot.Position - plr.Character.Head.Position).Magnitude
            if d < minDist and d < 150 then
                minDist = d
                target = plr
            end
        end
    end
    
    if target then
        Camera.CFrame = Camera.CFrame:Lerp(CFrame.lookAt(Camera.CFrame.Position, target.Character.Head.Position), 0.12)
    end
end)

-- Puxar Itens
RunService.Heartbeat:Connect(function()
    if not pullEnabled then return end
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    for _, v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") and (root.Position - v.Position).Magnitude < 70 then
            local n = v.Name:lower()
            if n:find("coin") or n:find("drop") or n:find("item") then
                v.CFrame = root.CFrame + Vector3.new(0,3,0)
            end
        end
    end
end)

-- Noclip
RunService.Stepped:Connect(function()
    if LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = not noclipEnabled
            end
        end
    end
end)

print("✅ Menu carregado! Pressione INSERT para abrir/fechar")
