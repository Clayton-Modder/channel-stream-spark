-- 🔥 CHEAT MENU COMPLETO - ANTI DETECT + PUXAR MOEDAS

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = Workspace.CurrentCamera

-- Variáveis
local aimbotEnabled = true
local magicBulletEnabled = true
local coinPullEnabled = true
local infiniteHealthEnabled = true
local aimKillEnabled = false
local noclipEnabled = false

-- === ANTI DETECT (Mais Avançado) ===
local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
local oldIndex = mt.__index

setreadonly(mt, false)

mt.__namecall = newcclosure(function(self, ...)
    local args = {...}
    local method = getnamecallmethod()
    local name = tostring(self)

    if magicBulletEnabled and (method == "FireServer" or method == "InvokeServer") then
        if name:lower():find("bullet") or name:lower():find("shoot") or name:lower():find("gun") or name:lower():find("fire") then
            local closest = nil
            local minDist = 9999
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
                args[1] = closest.Character.Head.Position + Vector3.new(0, math.random(-5,5)/10, 0)
            end
        end
    end
    return oldNamecall(self, unpack(args))
end)

setreadonly(mt, true)

-- ÍCONE
local Icon = Instance.new("TextButton")
Icon.Size = UDim2.new(0,75,0,75)
Icon.Position = UDim2.new(0,20,0.35,0)
Icon.BackgroundColor3 = Color3.fromRGB(255, 20, 147)
Icon.Text = "⚡"
Icon.TextScaled = true
Icon.Font = Enum.Font.GothamBold
Icon.TextColor3 = Color3.new(1,1,1)
Icon.BorderSizePixel = 0
Icon.Parent = LocalPlayer.PlayerGui:FindFirstChild("ScreenGui") or Instance.new("ScreenGui", LocalPlayer.PlayerGui)

-- MENU
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0,400,0,620)
Main.Position = UDim2.new(0.5,-200,0.5,-310)
Main.BackgroundColor3 = Color3.fromRGB(15,15,15)
Main.Draggable = true
Main.Visible = false
Main.Parent = LocalPlayer.PlayerGui.ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1,0,0,65)
Title.BackgroundColor3 = Color3.fromRGB(255,20,147)
Title.Text = "⚡ GROK CHEATS"
Title.TextColor3 = Color3.new(1,1,1)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold
Title.Parent = Main

local function CreateSwitch(text, y, default, callback)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(0.9,0,0,58)
    f.Position = UDim2.new(0.05,0,0,y)
    f.BackgroundColor3 = Color3.fromRGB(30,30,30)
    f.Parent = Main

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.62,0,1,0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.new(1,1,1)
    lbl.TextScaled = true
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Font = Enum.Font.GothamSemibold
    lbl.Parent = f

    local tog = Instance.new("TextButton")
    tog.Size = UDim2.new(0,115,0,42)
    tog.Position = UDim2.new(0.7,0,0.5,-21)
    tog.BackgroundColor3 = default and Color3.fromRGB(0,255,120) or Color3.fromRGB(255,60,60)
    tog.Text = default and "ON" or "OFF"
    tog.TextColor3 = Color3.new(1,1,1)
    tog.TextScaled = true
    tog.Font = Enum.Font.GothamBold
    tog.Parent = f

    local state = default
    tog.MouseButton1Click:Connect(function()
        state = not state
        tog.BackgroundColor3 = state and Color3.fromRGB(0,255,120) or Color3.fromRGB(255,60,60)
        tog.Text = state and "ON" or "OFF"
        callback(state)
    end)
end

CreateSwitch("🔫 Aimbot", 80, true, function(v) aimbotEnabled = v end)
CreateSwitch("💥 Bala Mágica", 145, true, function(v) magicBulletEnabled = v end)
CreateSwitch("❤️ Vida Infinita", 210, true, function(v) infiniteHealthEnabled = v end)
CreateSwitch("☠️ AimKill", 275, false, function(v) aimKillEnabled = v end)
CreateSwitch("🪙 Puxar Moedas", 340, true, function(v) coinPullEnabled = v end)
CreateSwitch("👻 Noclip", 405, false, function(v) noclipEnabled = v end)

-- Vida Infinita
RunService.Heartbeat:Connect(function()
    if infiniteHealthEnabled then
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
        if hum then
            hum.MaxHealth = 1e9
            hum.Health = 1e9
        end
    end
end)

-- Puxar Moedas (Melhorado)
RunService.Heartbeat:Connect(function()
    if not coinPullEnabled then return end
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end

    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") or obj:IsA("MeshPart") then
            local name = obj.Name:lower()
            if name:find("coin") or name:find("money") or name:find("gem") or name:find("cash") or name:find("drop") then
                local dist = (root.Position - obj.Position).Magnitude
                if dist < 120 then
                    obj.CFrame = root.CFrame + Vector3.new(0, 4, 0)
                end
            end
        end
    end
end)

-- AimKill
RunService.Heartbeat:Connect(function()
    if not aimKillEnabled then return end
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Humanoid") then
            if (root.Position - plr.Character.HumanoidRootPart.Position).Magnitude <= 35 then
                plr.Character.Humanoid:TakeDamage(20)
            end
        end
    end
end)

-- Aimbot Visual
RunService.RenderStepped:Connect(function()
    if not aimbotEnabled then return end
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if root then
        local closest = nil
        local min = 9999
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") then
                local d = (root.Position - plr.Character.Head.Position).Magnitude
                if d < min then min = d closest = plr end
            end
        end
        if closest then
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.lookAt(Camera.CFrame.Position, closest.Character.Head.Position), 0.1)
        end
    end
end)

-- Noclip
RunService.Stepped:Connect(function()
    if noclipEnabled and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
end)

-- Abrir Menu
Icon.MouseButton1Click:Connect(function()
    Main.Visible = not Main.Visible
end)

print("✅ SCRIPT COMPLETO CARREGADO!")
print("Clique no ⚡ rosa para abrir o menu")
