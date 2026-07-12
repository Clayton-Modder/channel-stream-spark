-- 🔥 MENU MELHORADO + BALA MÁGICA FORTE

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = Workspace.CurrentCamera

local aimbotEnabled = true
local magicBulletEnabled = true
local pullEnabled = true
local noclipEnabled = false
local freezeEnabled = false
local freezeRadius = 150

-- ÍCONE FLUTUANTE
local Icon = Instance.new("TextButton")
Icon.Size = UDim2.new(0, 70, 0, 70)
Icon.Position = UDim2.new(0, 15, 0.4, 0)
Icon.BackgroundColor3 = Color3.fromRGB(255, 0, 100)
Icon.Text = "⚡"
Icon.TextScaled = true
Icon.Font = Enum.Font.GothamBold
Icon.TextColor3 = Color3.new(1,1,1)
Icon.BorderSizePixel = 0
Icon.Parent = LocalPlayer.PlayerGui:FindFirstChild("ScreenGui") or Instance.new("ScreenGui", LocalPlayer.PlayerGui)

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 380, 0, 520)
Main.Position = UDim2.new(0.5, -190, 0.5, -260)
Main.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
Main.BorderSizePixel = 0
Main.Draggable = true
Main.Visible = false
Main.Parent = LocalPlayer.PlayerGui.ScreenGui

-- Título bonito
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
CreateSwitch("💥 Bala Mágica (Silent Aim)", 135, true, function(v) magicBulletEnabled = v end)
CreateSwitch("🧲 Puxar Itens", 200, true, function(v) pullEnabled = v end)
CreateSwitch("👻 Noclip", 265, false, function(v) noclipEnabled = v end)
CreateSwitch("❄️ Congelar Próximos", 330, false, function(v) freezeEnabled = v end)

-- Ícone abre menu
Icon.MouseButton1Click:Connect(function()
    Main.Visible = not Main.Visible
end)

-- === BALA MÁGICA MELHORADA ===
local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
setreadonly(mt, false)

mt.__namecall = newcclosure(function(self, ...)
    local args = {...}
    local method = getnamecallmethod()

    if magicBulletEnabled and (method == "FireServer" or method == "InvokeServer") then
        local name = self.Name:lower()
        if name:find("bullet") or name:find("shoot") or name:find("gun") or name:find("fire") then
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

            if closest and closest.Character and closest.Character:FindFirstChild("Head") then
                args[1] = closest.Character.Head.Position + Vector3.new(0, 0.1, 0) -- Headshot
            end
        end
    end
    return oldNamecall(self, unpack(args))
end)

setreadonly(mt, true)

-- Aimbot Visual
RunService.RenderStepped:Connect(function()
    if not aimbotEnabled then return end
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local closest = nil
    local minDist = 200

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") then
            local dist = (root.Position - plr.Character.Head.Position).Magnitude
            if dist < minDist then
                minDist = dist
                closest = plr
            end
        end
    end

    if closest then
        Camera.CFrame = Camera.CFrame:Lerp(CFrame.lookAt(Camera.CFrame.Position, closest.Character.Head.Position), 0.12)
    end
end)

-- Congelar
RunService.Heartbeat:Connect(function()
    if not freezeEnabled then return end
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            if (root.Position - plr.Character.HumanoidRootPart.Position).Magnitude <= freezeRadius then
                local hum = plr.Character:FindFirstChild("Humanoid")
                if hum then
                    hum.WalkSpeed = 0
                    hum.JumpPower = 0
                end
            end
        end
    end
end)

-- Puxar Itens + Noclip (básico)
RunService.Heartbeat:Connect(function()
    if not pullEnabled then return end
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and (root.Position - obj.Position).Magnitude < 70 then
            local n = obj.Name:lower()
            if n:find("coin") or n:find("drop") or n:find("item") then
                obj.CFrame = root.CFrame + Vector3.new(0,3,0)
            end
        end
    end
end)

RunService.Stepped:Connect(function()
    if LocalPlayer.Character and noclipEnabled then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
end)

print("✅ MENU CARREGADO!")
print("Clique no botão rosa ⚡ para abrir o menu")
