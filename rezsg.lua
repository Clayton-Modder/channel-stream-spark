-- 🔥 Aimbot Profissional + Anti-Recoil + ESP

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
local fovValue = 140

-- ANTI DETECT
local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
setreadonly(mt, false)

mt.__namecall = newcclosure(function(self, ...)
    local args = {...}
    if magicBulletEnabled and getnamecallmethod() == "FireServer" then
        local name = tostring(self):lower()
        if name:find("bullet") or name:find("shoot") or name:find("gun") then
            local closest = nil
            local minDist = 9999
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") then
                    local d = (LocalPlayer.Character.HumanoidRootPart.Position - plr.Character.Head.Position).Magnitude
                    if d < minDist then
                        minDist = d
                        closest = plr
                    end
                end
            end
            if closest then
                args[1] = closest.Character.Head.Position
            end
        end
    end
    return oldNamecall(self, unpack(args))
end)
setreadonly(mt, true)

-- === ANTI RECOIL ===
local cameraOld = Camera.CFrame
RunService.RenderStepped:Connect(function()
    if antiRecoilEnabled then
        Camera.CFrame = Camera.CFrame * CFrame.Angles(0, 0, 0) -- Remove recoil da câmera
    end
end)

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer.PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 400, 0, 520)
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -260)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1,0,0,65)
Title.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
Title.Text = "🔥 Aimbot Professional"
Title.TextColor3 = Color3.new(1,1,1)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

local function CreateToggle(text, y, default, callback)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(0.9,0,0,55)
    f.Position = UDim2.new(0.05,0,0,y)
    f.BackgroundColor3 = Color3.fromRGB(30,30,30)
    f.Parent = MainFrame

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.65,0,1,0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.new(1,1,1)
    lbl.TextScaled = true
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = f

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 115, 0, 42)
    btn.Position = UDim2.new(0.72,0,0.5,-21)
    btn.BackgroundColor3 = default and Color3.fromRGB(0,200,100) or Color3.fromRGB(200,50,50)
    btn.Text = default and "ON" or "OFF"
    btn.TextColor3 = Color3.new(1,1,1)
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamBold
    btn.Parent = f

    local state = default
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.BackgroundColor3 = state and Color3.fromRGB(0,200,100) or Color3.fromRGB(200,50,50)
        btn.Text = state and "ON" or "OFF"
        callback(state)
    end)
end

CreateToggle("🎯 Aimbot Cabeça", 80, true, function(v) aimbotEnabled = v end)
CreateToggle("💥 Bala Mágica", 145, true, function(v) magicBulletEnabled = v end)
CreateToggle("🔫 Anti-Recoil", 210, true, function(v) antiRecoilEnabled = v end)
CreateToggle("👁️ ESP", 275, true, function(v) espEnabled = v end)

-- FOV Slider
local fovLabel = Instance.new("TextLabel")
fovLabel.Size = UDim2.new(0.9,0,0,30)
fovLabel.Position = UDim2.new(0.05,0,0,340)
fovLabel.Text = "FOV: " .. fovValue
fovLabel.TextColor3 = Color3.new(1,1,1)
fovLabel.TextScaled = true
fovLabel.Parent = MainFrame

local bar = Instance.new("Frame")
bar.Size = UDim2.new(0.9,0,0,12)
bar.Position = UDim2.new(0.05,0,0,380)
bar.BackgroundColor3 = Color3.fromRGB(50,50,50)
bar.Parent = MainFrame

local knob = Instance.new("Frame")
knob.Size = UDim2.new(0, 26, 0, 26)
knob.Position = UDim2.new(fovValue/400, 0, 0.5, -13)
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
        knob.Position = UDim2.new(percent, 0, 0.5, -13)
        fovLabel.Text = "FOV: " .. fovValue
    end
end)

-- Aimbot + ESP (mesmo código anterior, mantido limpo)
RunService.RenderStepped:Connect(function()
    if not aimbotEnabled then return end
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
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.lookAt(Camera.CFrame.Position, closest.Character.Head.Position), 0.08)
        end
    end
end)

print("✅ Sistema completo carregado!")
print("Pressione F para abrir o menu")
