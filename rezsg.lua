-- 🔥 GROK CHEATS v2 - ANTI DETECT FORTE + FUNÇÕES APELONAS

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

local menuOpen = true

-- === ANTI DETECT APELONA ===
local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
local oldIndex = mt.__index

setreadonly(mt, false)

mt.__namecall = newcclosure(function(self, ...)
    local args = {...}
    local method = getnamecallmethod()
    local name = tostring(self):lower()

    -- Bloqueio total de detecção
    if method == "FireServer" and (name:find("ban") or name:find("kick") or name:find("report") or name:find("cheat") or name:find("detect")) then
        return
    end

    -- Randomização para Bala Mágica
    if magicBulletEnabled and (method == "FireServer") and (name:find("bullet") or name:find("shoot") or name:find("gun")) then
        if math.random(1,3) == 1 then wait(0.001) end -- Micro delay aleatório
    end

    return oldNamecall(self, unpack(args))
end)

mt.__index = newcclosure(function(self, key)
    if key == "Kick" then return function() end end
    return oldIndex(self, key)
end)

setreadonly(mt, true)

-- === MENU FIXADO (Não some mais) ===
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local Icon = Instance.new("TextButton")
Icon.Size = UDim2.new(0, 65, 0, 65)
Icon.Position = UDim2.new(0, 20, 0.4, 0)
Icon.BackgroundColor3 = Color3.fromRGB(255, 20, 147)
Icon.Text = "⚡"
Icon.TextScaled = true
Icon.Font = Enum.Font.GothamBold
Icon.TextColor3 = Color3.new(1,1,1)
Icon.Parent = ScreenGui

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 400, 0, 650)
Main.Position = UDim2.new(0.5, -200, 0.5, -325)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Main.BorderSizePixel = 0
Main.Draggable = true
Main.Visible = false
Main.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1,0,0,70)
Title.BackgroundColor3 = Color3.fromRGB(255,20,147)
Title.Text = "⚡ GROK CHEATS APELÃO"
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
    lbl.Size = UDim2.new(0.6,0,1,0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.new(1,1,1)
    lbl.TextScaled = true
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = f

    local tog = Instance.new("TextButton")
    tog.Size = UDim2.new(0,120,0,42)
    tog.Position = UDim2.new(0.68,0,0.5,-21)
    tog.BackgroundColor3 = default and Color3.fromRGB(0,255,100) or Color3.fromRGB(255,50,50)
    tog.Text = default and "ON" or "OFF"
    tog.TextColor3 = Color3.new(1,1,1)
    tog.TextScaled = true
    tog.Font = Enum.Font.GothamBold
    tog.Parent = f

    local state = default
    tog.MouseButton1Click:Connect(function()
        state = not state
        tog.BackgroundColor3 = state and Color3.fromRGB(0,255,100) or Color3.fromRGB(255,50,50)
        tog.Text = state and "ON" or "OFF"
        callback(state)
    end)
end

-- Funções Apelonas
CreateSwitch("🔫 Aimbot", 85, true, function(v) aimbotEnabled = v end)
CreateSwitch("💥 Bala Mágica", 150, true, function(v) magicBulletEnabled = v end)
CreateSwitch("❤️ Vida Infinita", 215, true, function(v) infiniteHealthEnabled = v end)
CreateSwitch("☠️ AimKill (Dano)", 280, false, function(v) aimKillEnabled = v end)
CreateSwitch("🪙 Puxar Moedas", 345, true, function(v) coinPullEnabled = v end)
CreateSwitch("👻 Noclip", 410, false, function(v) noclipEnabled = v end)

-- Icon + Tecla F
Icon.MouseButton1Click:Connect(function() Main.Visible = not Main.Visible end)

UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.F then
        Main.Visible = not Main.Visible
    end
end)

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

-- Puxar Moedas
RunService.Heartbeat:Connect(function()
    if not coinPullEnabled then return end
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            local n = obj.Name:lower()
            if n:find("coin") or n:find("money") or n:find("gem") or n:find("drop") then
                if (root.Position - obj.Position).Magnitude < 130 then
                    obj.CFrame = root.CFrame + Vector3.new(0,4,0)
                end
            end
        end
    end
end)

-- AimKill
RunService.Heartbeat:Connect(function()
    if not aimKillEnabled then return end
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if root then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Humanoid") then
                if (root.Position - plr.Character.HumanoidRootPart.Position).Magnitude <= 40 then
                    plr.Character.Humanoid:TakeDamage(30)
                end
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
        local minDist = 9999
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") then
                local d = (root.Position - plr.Character.Head.Position).Magnitude
                if d < minDist then minDist = d closest = plr end
            end
        end
        if closest then
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.lookAt(Camera.CFrame.Position, closest.Character.Head.Position), 0.11)
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

print("✅ SCRIPT APELÃO CARREGADO!")
print("Pressione F ou clique no ⚡ para abrir o menu")
