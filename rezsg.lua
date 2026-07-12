-- 🔥 CHEAT MENU COMPLETO - Com Bala Mágica (Magic Bullet)

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
local aimFOV = 150

-- GUI (mesma base anterior)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 340, 0, 480)
Main.Position = UDim2.new(0.5, -170, 0.5, -240)
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Main.Draggable = true
Main.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1,0,0,50)
Title.BackgroundColor3 = Color3.fromRGB(0, 140, 255)
Title.Text = "🔥 CHEAT MENU"
Title.TextColor3 = Color3.new(1,1,1)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold
Title.Parent = Main

local function CreateSwitch(text, yPos, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.9,0,0,50)
    frame.Position = UDim2.new(0.05,0,0,yPos)
    frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
    frame.Parent = Main

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.65,0,1,0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.new(1,1,1)
    label.TextScaled = true
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(0,90,0,35)
    toggle.Position = UDim2.new(0.7,0,0.5,-17)
    toggle.BackgroundColor3 = default and Color3.fromRGB(0,170,0) or Color3.fromRGB(170,0,0)
    toggle.Text = default and "ON" or "OFF"
    toggle.TextColor3 = Color3.new(1,1,1)
    toggle.TextScaled = true
    toggle.Parent = frame

    local state = default
    toggle.MouseButton1Click:Connect(function()
        state = not state
        toggle.BackgroundColor3 = state and Color3.fromRGB(0,170,0) or Color3.fromRGB(170,0,0)
        toggle.Text = state and "ON" or "OFF"
        callback(state)
    end)
end

-- Switches
CreateSwitch("🔫 Aimbot Visual", 60, true, function(v) aimbotEnabled = v end)
CreateSwitch("💥 Bala Mágica (Silent Aim)", 120, true, function(v) magicBulletEnabled = v end)
CreateSwitch("🧲 Puxar Itens", 180, true, function(v) pullEnabled = v end)
CreateSwitch("👻 Noclip", 240, false, function(v) noclipEnabled = v end)

-- Slider FOV
local function CreateFOVSlider()
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.9,0,0,70)
    frame.Position = UDim2.new(0.05,0,0,300)
    frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
    frame.Parent = Main

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1,0,0,25)
    label.Text = "Aim FOV: " .. aimFOV
    label.TextColor3 = Color3.new(1,1,1)
    label.BackgroundTransparency = 1
    label.TextScaled = true
    label.Parent = frame

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1,-20,0,12)
    bar.Position = UDim2.new(0,10,0.6,0)
    bar.BackgroundColor3 = Color3.fromRGB(60,60,60)
    bar.Parent = frame

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0,22,0,22)
    knob.Position = UDim2.new(aimFOV/360,0,0.5,-11)
    knob.BackgroundColor3 = Color3.fromRGB(0,170,255)
    knob.Parent = bar
end

CreateFOVSlider()

-- === BALA MÁGICA (Magic Bullet) ===
local mt = getrawmetatable(game)
local old = mt.__namecall
setreadonly(mt, false)

mt.__namecall = newcclosure(function(self, ...)
    local args = {...}
    local method = getnamecallmethod()

    if magicBulletEnabled and method == "FireServer" and self.Name:lower():find("bullet") or self.Name:lower():find("shoot") or self.Name:lower():find("gun") then
        local closest = nil
        local minDist = aimFOV

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
            args[1] = closest.Character.Head.Position  -- Muda o alvo da bala
        end
    end

    return old(self, unpack(args))
end)

setreadonly(mt, true)

-- Aimbot Visual
RunService.RenderStepped:Connect(function()
    if not aimbotEnabled then return end
    -- (código do aimbot visual permanece igual)
    local closest = nil
    local minDist = aimFOV
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end

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
        Camera.CFrame = Camera.CFrame:Lerp(CFrame.lookAt(Camera.CFrame.Position, closest.Character.Head.Position), 0.1)
    end
end)

-- Puxar e Noclip (mesmo de antes)
RunService.Heartbeat:Connect(function()
    if not pullEnabled then return end
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and (root.Position - obj.Position).Magnitude < 80 then
            local n = obj.Name:lower()
            if n:find("coin") or n:find("drop") or n:find("item") then
                obj.CFrame = root.CFrame + Vector3.new(0,3,0)
            end
        end
    end
end)

RunService.Stepped:Connect(function()
    if LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = not noclipEnabled
            end
        end
    end
end)

print("✅ Menu com Bala Mágica carregado!")
print("Pressione INSERT para abrir o menu")
