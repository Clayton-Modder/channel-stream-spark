-- 🔥 MENU ATUALIZADO + VIDA INFINITA

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = Workspace.CurrentCamera

local aimbotEnabled = true
local magicBulletEnabled = true
local pullEnabled = true
local noclipEnabled = false
local freezeEnabled = false
local infiniteHealthEnabled = true  -- Nova função

-- ÍCONE FLUTUANTE
local Icon = Instance.new("TextButton")
Icon.Size = UDim2.new(0, 70, 0, 70)
Icon.Position = UDim2.new(0, 15, 0.4, 0)
Icon.BackgroundColor3 = Color3.fromRGB(255, 0, 100)
Icon.Text = "⚡"
Icon.TextScaled = true
Icon.Font = Enum.Font.GothamBold
Icon.TextColor3 = Color3.new(1,1,1)
Icon.Parent = LocalPlayer.PlayerGui:FindFirstChild("ScreenGui") or Instance.new("ScreenGui", LocalPlayer.PlayerGui)

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 380, 0, 580)
Main.Position = UDim2.new(0.5, -190, 0.5, -290)
Main.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
Main.Draggable = true
Main.Visible = false
Main.Parent = LocalPlayer.PlayerGui.ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1,0,0,60)
Title.BackgroundColor3 = Color3.fromRGB(255, 0, 100)
Title.Text = "⚡ ADVANCED CHEATS"
Title.TextColor3 = Color3.new(1,1,1)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold
Title.Parent = Main

local function CreateSwitch(text, yPos, default, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0.92,0,0,55)
    Frame.Position = UDim2.new(0.04,0,0,yPos)
    Frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
    Frame.Parent = Main

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.6,0,1,0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.new(1,1,1)
    Label.TextScaled = true
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Font = Enum.Font.GothamSemibold
    Label.Parent = Frame

    local Toggle = Instance.new("TextButton")
    Toggle.Size = UDim2.new(0, 110, 0, 40)
    Toggle.Position = UDim2.new(0.68,0,0.5,-20)
    Toggle.BackgroundColor3 = default and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 50, 50)
    Toggle.Text = default and "ON" or "OFF"
    Toggle.TextColor3 = Color3.new(1,1,1)
    Toggle.TextScaled = true
    Toggle.Font = Enum.Font.GothamBold
    Toggle.Parent = Frame

    local state = default
    Toggle.MouseButton1Click:Connect(function()
        state = not state
        Toggle.BackgroundColor3 = state and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 50, 50)
        Toggle.Text = state and "ON" or "OFF"
        callback(state)
    end)
end

-- Switches
CreateSwitch("🔫 Aimbot Visual", 70, true, function(v) aimbotEnabled = v end)
CreateSwitch("💥 Bala Mágica", 135, true, function(v) magicBulletEnabled = v end)
CreateSwitch("❤️ Vida Infinita", 200, true, function(v) infiniteHealthEnabled = v end)
CreateSwitch("🧲 Puxar Itens", 265, true, function(v) pullEnabled = v end)
CreateSwitch("👻 Noclip", 330, false, function(v) noclipEnabled = v end)
CreateSwitch("❄️ Congelar Jogadores", 395, false, function(v) freezeEnabled = v end)

-- Ícone abre menu
Icon.MouseButton1Click:Connect(function()
    Main.Visible = not Main.Visible
end)

-- === VIDA INFINITA ===
RunService.Heartbeat:Connect(function()
    if not infiniteHealthEnabled then return end
    local character = LocalPlayer.Character
    if character then
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.MaxHealth = 100000
            humanoid.Health = 100000
            humanoid.HealthDisplayDistance = 0  -- Esconde a barra de vida
        end
    end
end)

-- Bala Mágica
local mt = getrawmetatable(game)
local old = mt.__namecall
setreadonly(mt, false)
mt.__namecall = newcclosure(function(self, ...)
    local args = {...}
    if magicBulletEnabled and (getnamecallmethod() == "FireServer") then
        local name = self.Name:lower()
        if name:find("bullet") or name:find("shoot") or name:find("gun") then
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
                args[1] = closest.Character.Head.Position
            end
        end
    end
    return old(self, unpack(args))
end)
setreadonly(mt, true)

-- Outras funções (Aimbot, Congelar, etc.)
RunService.RenderStepped:Connect(function()
    if not aimbotEnabled then return end
    -- ... (aimbot visual)
end)

print("✅ MENU COM VIDA INFINITA CARREGADO!")
print("Clique no ⚡ rosa para abrir o menu")
