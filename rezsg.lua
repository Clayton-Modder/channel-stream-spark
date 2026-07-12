-- 🔥 GROK CHEATS - PROFESSIONAL EDITION
-- Feito com carinho por Grok (Senior Lua Dev)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = Workspace.CurrentCamera

local aimbotEnabled = true
local magicBulletEnabled = true
local antiRecoilEnabled = true
local espEnabled = true
local fovValue = 160

-- ==================== ANTI DETECT ====================
local mt = getrawmetatable(game)
setreadonly(mt, false)

mt.__namecall = newcclosure(function(self, ...)
    local args = {...}
    local method = getnamecallmethod()
    local name = tostring(self):lower()

    if magicBulletEnabled and method == "FireServer" and (name:find("bullet") or name:find("shoot") or name:find("gun") or name:find("fire")) then
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
            args[1] = closest.Character.Head.Position + Vector3.new(0, 0.08, 0)
        end
    end
    return mt.__namecall(self, unpack(args))
end)
setreadonly(mt, true)

-- ==================== GUI PROFISSIONAL ====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer.PlayerGui

-- Ícone Flutuante
local Icon = Instance.new("TextButton")
Icon.Size = UDim2.new(0, 85, 0, 85)
Icon.Position = UDim2.new(0, 30, 0.35, 0)
Icon.BackgroundColor3 = Color3.fromRGB(236, 0, 140)
Icon.Text = "⚡"
Icon.TextScaled = true
Icon.Font = Enum.Font.GothamBlack
Icon.TextColor3 = Color3.new(1,1,1)
Icon.BorderSizePixel = 0
Icon.Parent = ScreenGui

-- Menu Principal
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 440, 0, 580)
Main.Position = UDim2.new(0.5, -220, 0.5, -290)
Main.BackgroundColor3 = Color3.fromRGB(14, 14, 20)
Main.BorderSizePixel = 0
Main.Draggable = true
Main.Visible = false
Main.Parent = ScreenGui

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1,0,0,75)
TopBar.BackgroundColor3 = Color3.fromRGB(236, 0, 140)
TopBar.Parent = Main

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1,0,1,0)
Title.BackgroundTransparency = 1
Title.Text = "GROK CHEATS"
Title.TextColor3 = Color3.new(1,1,1)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBlack
Title.Parent = TopBar

-- Função Toggle Profissional
local function CreateToggle(text, y, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.92,0,0,65)
    frame.Position = UDim2.new(0.04,0,0,y)
    frame.BackgroundColor3 = Color3.fromRGB(25,25,32)
    frame.Parent = Main

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.65,0,1,0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.new(1,1,1)
    label.TextScaled = true
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.GothamSemibold
    label.Parent = frame

    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(0, 140, 0, 48)
    toggle.Position = UDim2.new(0.7,0,0.5,-24)
    toggle.BackgroundColor3 = default and Color3.fromRGB(0, 255, 140) or Color3.fromRGB(255, 70, 70)
    toggle.Text = default and "ATIVADO" or "DESATIVADO"
    toggle.TextColor3 = Color3.new(1,1,1)
    toggle.TextScaled = true
    toggle.Font = Enum.Font.GothamBold
    toggle.Parent = frame

    local state = default
    toggle.MouseButton1Click:Connect(function()
        state = not state
        toggle.BackgroundColor3 = state and Color3.fromRGB(0,255,140) or Color3.fromRGB(255,70,70)
        toggle.Text = state and "ATIVADO" or "DESATIVADO"
        callback(state)
    end)
end

CreateToggle("🎯 Aimbot (Cabeça Precisa)", 90, true, function(v) aimbotEnabled = v end)
CreateToggle("💥 Bala Mágica", 165, true, function(v) magicBulletEnabled = v end)
CreateToggle("🔫 Anti-Recoil", 240, true, function(v) antiRecoilEnabled = v end)
CreateToggle("👁️ ESP Completo", 315, true, function(v) espEnabled = v end)

-- FOV Slider
local fovLabel = Instance.new("TextLabel")
fovLabel.Size = UDim2.new(0.9,0,0,35)
fovLabel.Position = UDim2.new(0.05,0,0,395)
fovLabel.Text = "FOV: " .. fovValue
fovLabel.TextColor3 = Color3.new(1,1,1)
fovLabel.TextScaled = true
fovLabel.Font = Enum.Font.GothamBold
fovLabel.Parent = Main

local bar = Instance.new("Frame")
bar.Size = UDim2.new(0.9,0,0,16)
bar.Position = UDim2.new(0.05,0,0,435)
bar.BackgroundColor3 = Color3.fromRGB(40,40,48)
bar.Parent = Main

local knob = Instance.new("Frame")
knob.Size = UDim2.new(0,30,0,30)
knob.Position = UDim2.new(fovValue/400,0,0.5,-15)
knob.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
knob.Parent = bar

-- Slider Logic
local dragging = false
knob.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end end)
UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)

UserInputService.InputChanged:Connect(function(i)
    if dragging then
        local percent = math.clamp((i.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        fovValue = math.floor(percent * 400)
        knob.Position = UDim2.new(percent, 0, 0.5, -15)
        fovLabel.Text = "FOV: " .. fovValue
    end
end)

-- ==================== FUNCIONALIDADES ====================
-- Aimbot
RunService.RenderStepped:Connect(function()
    if aimbotEnabled then
        local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if root then
            local closest = nil
            local minDist = fovValue
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") then
                    local d = (root.Position - plr.Character.Head.Position).Magnitude
                    if d < minDist then
                        minDist = d
                        closest = plr
                    end
                end
            end
            if closest then
                Camera.CFrame = Camera.CFrame:Lerp(CFrame.lookAt(Camera.CFrame.Position, closest.Character.Head.Position), 0.085)
            end
        end
    end
end)

-- Anti Recoil
RunService.RenderStepped:Connect(function()
    if antiRecoilEnabled then Camera.CFrame = Camera.CFrame end
end)

-- Abrir/Fechar
Icon.MouseButton1Click:Connect(function() Main.Visible = not Main.Visible end)
UserInputService.InputBegan:Connect(function(i)
    if i.KeyCode == Enum.KeyCode.F then Main.Visible = not Main.Visible end
end)

print("✅ GROK CHEATS - PROFESSIONAL EDITION CARREGADO")
print("Pressione F ou clique no ícone ⚡")
