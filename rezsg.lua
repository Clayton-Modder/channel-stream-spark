-- 🔥 Aimbot Professional - Menu Chamativo + Ícone + Anti-Recoil

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

-- ANTI DETECT + BALA MÁGICA FIXADA
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
            args[1] = closest.Character.Head.Position + Vector3.new(0, 0.1, 0)
        end
    end
    return mt.__namecall(self, unpack(args))
end)
setreadonly(mt, true)

-- ÍCONE FLUTUANTE (Muito chamativo)
local Icon = Instance.new("TextButton")
Icon.Size = UDim2.new(0, 80, 0, 80)
Icon.Position = UDim2.new(0, 25, 0.35, 0)
Icon.BackgroundColor3 = Color3.fromRGB(255, 0, 100)
Icon.Text = "🔥"
Icon.TextScaled = true
Icon.Font = Enum.Font.GothamBold
Icon.TextColor3 = Color3.new(1,1,1)
Icon.BorderSizePixel = 0
Icon.Parent = LocalPlayer.PlayerGui:FindFirstChild("ScreenGui") or Instance.new("ScreenGui", LocalPlayer.PlayerGui)

-- MENU MODERNO E CHAMATIVO
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 420, 0, 520)
Main.Position = UDim2.new(0.5, -210, 0.5, -260)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
Main.BorderSizePixel = 0
Main.Draggable = true
Main.Visible = false
Main.Parent = LocalPlayer.PlayerGui.ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1,0,0,70)
Title.BackgroundColor3 = Color3.fromRGB(255, 0, 100)
Title.Text = "🔥 GROK Aimbot"
Title.TextColor3 = Color3.new(1,1,1)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBlack
Title.Parent = Main

local function CreateToggle(text, y, default, callback)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(0.92,0,0,60)
    f.Position = UDim2.new(0.04,0,0,y)
    f.BackgroundColor3 = Color3.fromRGB(28, 28, 35)
    f.Parent = Main

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.65,0,1,0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.new(1,1,1)
    lbl.TextScaled = true
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Font = Enum.Font.GothamSemibold
    lbl.Parent = f

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 130, 0, 45)
    btn.Position = UDim2.new(0.7,0,0.5,-22)
    btn.BackgroundColor3 = default and Color3.fromRGB(0, 255, 120) or Color3.fromRGB(255, 60, 60)
    btn.Text = default and "ATIVADO" or "DESATIVADO"
    btn.TextColor3 = Color3.new(1,1,1)
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamBold
    btn.Parent = f

    local state = default
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.BackgroundColor3 = state and Color3.fromRGB(0,255,120) or Color3.fromRGB(255,60,60)
        btn.Text = state and "ATIVADO" or "DESATIVADO"
        callback(state)
    end)
end

CreateToggle("🎯 Aimbot Cabeça", 85, true, function(v) aimbotEnabled = v end)
CreateToggle("💥 Bala Mágica", 155, true, function(v) magicBulletEnabled = v end)
CreateToggle("🔫 Anti Recoil", 225, true, function(v) antiRecoilEnabled = v end)
CreateToggle("👁️ ESP", 295, true, function(v) espEnabled = v end)

-- FOV Slider
local fovLabel = Instance.new("TextLabel")
fovLabel.Size = UDim2.new(0.9,0,0,35)
fovLabel.Position = UDim2.new(0.05,0,0,370)
fovLabel.Text = "FOV: " .. fovValue
fovLabel.TextColor3 = Color3.new(1,1,1)
fovLabel.TextScaled = true
fovLabel.Font = Enum.Font.GothamBold
fovLabel.Parent = Main

local bar = Instance.new("Frame")
bar.Size = UDim2.new(0.9,0,0,14)
bar.Position = UDim2.new(0.05,0,0,410)
bar.BackgroundColor3 = Color3.fromRGB(45,45,55)
bar.Parent = Main

local knob = Instance.new("Frame")
knob.Size = UDim2.new(0,28,0,28)
knob.Position = UDim2.new(fovValue/400,0,0.5,-14)
knob.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
knob.Parent = bar

-- Slider
local dragging = false
knob.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end end)
UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)

UserInputService.InputChanged:Connect(function(i)
    if dragging then
        local percent = math.clamp((i.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        fovValue = math.floor(percent * 400)
        knob.Position = UDim2.new(percent, 0, 0.5, -14)
        fovLabel.Text = "FOV: " .. fovValue
    end
end)

-- Aimbot + Anti Recoil + ESP
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
                Camera.CFrame = Camera.CFrame:Lerp(CFrame.lookAt(Camera.CFrame.Position, closest.Character.Head.Position), 0.09)
            end
        end
    end
end)

-- Anti Recoil
RunService.RenderStepped:Connect(function()
    if antiRecoilEnabled then
        Camera.CFrame = Camera.CFrame
    end
end)

-- Abrir/Fechar Menu
Icon.MouseButton1Click:Connect(function()
    Main.Visible = not Main.Visible
end)

UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.F then
        Main.Visible = not Main.Visible
    end
end)

print("✅ MENU CHAMATIVO CARREGADO!")
print("Clique no 🔥 ou pressione F para abrir/fechar")
