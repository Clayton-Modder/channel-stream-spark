-- 🔥 CHEAT MENU - Bala Mágica com Raio de Dano (AoE 123)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = Workspace.CurrentCamera

local aimbotEnabled = true
local magicBulletEnabled = true
local aoeRadius = 123
local pullEnabled = true
local noclipEnabled = false
local aimFOV = 150

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 350, 0, 500)
Main.Position = UDim2.new(0.5, -175, 0.5, -250)
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
    label.Text = text
    label.TextColor3 = Color3.new(1,1,1)
    label.BackgroundTransparency = 1
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

CreateSwitch("🔫 Aimbot Visual", 60, true, function(v) aimbotEnabled = v end)
CreateSwitch("💥 Bala Mágica + Raio 123", 120, true, function(v) magicBulletEnabled = v end)
CreateSwitch("🧲 Puxar Itens", 180, true, function(v) pullEnabled = v end)
CreateSwitch("👻 Noclip", 240, false, function(v) noclipEnabled = v end)

-- === BALA MÁGICA COM RAIO DE DANO ===
local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
setreadonly(mt, false)

mt.__namecall = newcclosure(function(self, ...)
    local args = {...}
    local method = getnamecallmethod()

    if magicBulletEnabled and method == "FireServer" then
        local name = self.Name:lower()
        if name:find("bullet") or name:find("shoot") or name:find("gun") or name:find("fire") then
            local target = nil
            local minDist = aimFOV
            local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

            if myRoot then
                for _, plr in ipairs(Players:GetPlayers()) do
                    if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") then
                        local dist = (myRoot.Position - plr.Character.Head.Position).Magnitude
                        if dist < minDist then
                            minDist = dist
                            target = plr
                        end
                    end
                end
            end

            if target and target.Character and target.Character:FindFirstChild("Head") then
                local headPos = target.Character.Head.Position
                args[1] = headPos  -- Magic Bullet

                -- === RAIO DE DANO (AoE) ===
                spawn(function()
                    wait(0.05) -- pequeno delay para sincronizar
                    local explosion = Instance.new("Explosion")
                    explosion.Position = headPos
                    explosion.BlastRadius = aoeRadius
                    explosion.BlastPressure = 500000
                    explosion.Parent = Workspace
                    
                    -- Efeito visual extra
                    local part = Instance.new("Part")
                    part.Shape = Enum.PartType.Ball
                    part.Material = Enum.Material.Neon
                    part.Color = Color3.fromRGB(255, 0, 0)
                    part.Size = Vector3.new(5,5,5)
                    part.Position = headPos
                    part.Anchored = true
                    part.CanCollide = false
                    part.Transparency = 0.3
                    part.Parent = Workspace
                    game:GetService("Debris"):AddItem(part, 1.5)
                end)
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
    local minDist = aimFOV

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

-- Puxar Itens + Noclip (mantidos)
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

print("✅ Bala Mágica com Raio de 123 studs ativada!")
print("Pressione INSERT para abrir o menu")
