-- 🔥 SCRIPT MELHORADO - ANTI ANTI-CHEAT 2026
-- Mira Auto + Puxador Forte + Teleporte + Noclip

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = Workspace.CurrentCamera

local aimbotEnabled = true
local pullEnabled = true
local noclipEnabled = false
local espEnabled = true

-- Configurações (ajustáveis)
local AIMBOT_FOV = 120
local AIMBOT_SMOOTHNESS = 0.08
local PULL_DISTANCE = 80
local PULL_STRENGTH = 0.6
local TELEPORT_KEY = Enum.KeyCode.F
local AIMBOT_KEY = Enum.KeyCode.Q
local PULL_KEY = Enum.KeyCode.E
local NOCLIP_KEY = Enum.KeyCode.N

-- Hook para esconder o script (Anti-Cheat Bypass)
local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
setreadonly(mt, false)

mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    
    if method == "FireServer" and self.Name:find("Ban") or self.Name:find("Kick") or self.Name:find("Report") then
        return
    end
    return oldNamecall(self, ...)
end)

setreadonly(mt, true)

-- Pegar jogador mais próximo (com verificação de time)
local function getClosestPlayer()
    local closest = nil
    local shortest = math.huge
    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local root = player.Character.HumanoidRootPart
            local distance = (myRoot.Position - root.Position).Magnitude
            
            if distance < shortest and distance <= AIMBOT_FOV then
                -- Evita mirar em aliados (se tiver time)
                if not (player.Team == LocalPlayer.Team and player.Team ~= nil) then
                    shortest = distance
                    closest = player
                end
            end
        end
    end
    return closest
end

-- Aimbot Melhorado (com prediction leve)
RunService.RenderStepped:Connect(function(delta)
    if not aimbotEnabled then return end
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end

    local target = getClosestPlayer()
    if target and target.Character and target.Character:FindFirstChild("Head") then
        local head = target.Character.Head
        local velocity = target.Character:FindFirstChild("HumanoidRootPart").Velocity
        
        local prediction = head.Position + (velocity * 0.1)
        local lookAt = CFrame.lookAt(Camera.CFrame.Position, prediction)
        
        Camera.CFrame = Camera.CFrame:Lerp(lookAt, AIMBOT_SMOOTHNESS)
    end
end)

-- Puxador de Itens Melhorado
RunService.Heartbeat:Connect(function()
    if not pullEnabled then return end
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end

    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj ~= root and obj.Position then
            local name = obj.Name:lower()
            if name:find("coin") or name:find("item") or name:find("drop") or name:find("gem") or name:find("tool") or obj:FindFirstChild("TouchInterest") then
                local distance = (root.Position - obj.Position).Magnitude
                if distance < PULL_DISTANCE and distance > 3 then
                    obj.CFrame = obj.CFrame:Lerp(root.CFrame + Vector3.new(0, 3, 0), PULL_STRENGTH)
                end
            end
        end
    end
end)

-- Teleporte Silencioso
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == TELEPORT_KEY then
        local target = getClosestPlayer()
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local root = LocalPlayer.Character.HumanoidRootPart
            root.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 4, 0)
        end
    end
end)

-- Toggles
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == AIMBOT_KEY then
        aimbotEnabled = not aimbotEnabled
        print("🔫 Aimbot:", aimbotEnabled and "ON" or "OFF")
    elseif input.KeyCode == PULL_KEY then
        pullEnabled = not pullEnabled
        print("🧲 Puxador:", pullEnabled and "ON" or "OFF")
    elseif input.KeyCode == NOCLIP_KEY then
        noclipEnabled = not noclipEnabled
        print("👻 Noclip:", noclipEnabled and "ON" or "OFF")
    end
end)

-- Noclip
RunService.Stepped:Connect(function()
    if not LocalPlayer.Character then return end
    for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = not noclipEnabled
        end
    end
end)

-- ESP Simples
local function createESP(plr)
    if plr == LocalPlayer then return end
    local char = plr.Character or plr.CharacterAdded:Wait()
    local highlight = Instance.new("Highlight")
    highlight.FillColor = Color3.fromRGB(255, 50, 50)
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 0.5
    highlight.Parent = char
end

for _, plr in ipairs(Players:GetPlayers()) do
    if plr.Character then createESP(plr) end
    plr.CharacterAdded:Connect(function() createESP(plr) end)
end

print("🚀 Script Melhorado Carregado!")
print("Teclas:")
print("   Q = Aimbot")
print("   E = Puxar Itens")
print("   F = Teleporte")
print("   N = Noclip")

warn("Use com moderação para evitar ban. Boa sorte!")