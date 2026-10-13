-- DELTA MOBILE OPTIMIZED SCRIPT
-- Copie e cole no Delta Executer

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")
local head = character:WaitForChild("Head")

-- CONFIGURAÇÕES
local speedMultiplier = 48 -- Velocidade (24 é padrão, 48 é hack)
local auraColor = Color3.fromRGB(0, 255, 128)
local auraSize = 1.2
local espNeutralizeRadius = 250
local neutralizeInterval = 0.15 -- 150ms (melhor performance no mobile)

-- 1. SPEED & JUMP
local function applyMovementMods()
    humanoid.WalkSpeed = speedMultiplier
    humanoid.JumpPower = 60
    humanoid.UseJumpPower = true -- Pulo mais consistente
end
applyMovementMods()

-- 2. SUPER AURA (Otimizado para Mobile)
local aura = Instance.new("Part")
aura.Name = "SuperAura"
aura.Shape = Enum.PartType.Ball
aura.Size = Vector3.new(auraSize, auraSize, auraSize)
aura.Material = Enum.Material.Neon
aura.BrickColor = BrickColor.new(auraColor)
aura.CanCollide = false
aura.Transparency = 0.6
aura.Anchored = true
aura.Parent = character

local function updateAuraLoop()
    while character and character.Parent do
        if aura and aura.Parent then
            aura.CFrame = rootPart.CFrame
        end
        task.wait() -- Heartbeat implícito via task.wait()
    end
end
task.spawn(updateAuraLoop)

-- 3. ESP NEUTRALIZATION (Otimizado para Mobile)
local function neutralizeEnemyESP()
    local allPlayers = Players:GetPlayers()
    
    for _, otherPlayer in allPlayers do
        if otherPlayer ~= player and otherPlayer.Character then
            local otherHead = otherPlayer.Character:FindFirstChild("Head")
            if otherHead then
                local distance = (rootPart.Position - otherHead.Position).Magnitude
                
                if distance < espNeutralizeRadius then
                    -- Neutraliza Highlights (ESP visual)
                    local highlight = otherPlayer.Character:FindFirstChildWhichIsA("Highlight")
                    if highlight then
                        highlight:Destroy()
                    end
                    
                    -- Neutraliza Billboards (Nomes/HP)
                    local billboard = otherPlayer.Character:FindFirstChildWhichIsA("BillboardGui")
                    if billboard then
                        billboard.Enabled = false
                    end
                    
                    -- Opcional: Remove TrailEffects (se o jogo usar)
                    local trail = otherPlayer.Character:FindFirstChildWhichIsA("Trail")
                    if trail then
                        trail:Destroy()
                    end
                end
            end
        end
    end
end

-- Loop de Neutralização (Throttled para performance)
local function startNeutralizationLoop()
    while true do
        task.wait(neutralizeInterval)
        neutralizeEnemyESP()
    end
end
task.spawn(startNeutralizationLoop)

-- 4. RECONEXÃO AUTOMÁTICA (Reaplica ao respawnar)
local function onCharacterAdded(newChar)
    task.wait(1) -- Espera o personagem carregar
    local newHumanoid = newChar:FindFirstChild("Humanoid")
    local newRoot = newChar:FindFirstChild("HumanoidRootPart")
    
    if newHumanoid and newRoot then
        -- Reaplica Speed
        newHumanoid.WalkSpeed = speedMultiplier
        newHumanoid.JumpPower = 60
        
        -- Recria Aura
        if aura and aura.Parent then
            aura:Destroy()
        end
        local newAura = Instance.new("Part")
        newAura.Name = "SuperAura"
        newAura.Shape = Enum.PartType.Ball
        newAura.Size = Vector3.new(auraSize, auraSize, auraSize)
        newAura.Material = Enum.Material.Neon
        newAura.BrickColor = BrickColor.new(auraColor)
        newAura.CanCollide = false
        newAura.Transparency = 0.6
        newAura.Anchored = true
        newAura.Parent = newChar
        
        task.spawn(function()
            while newChar and newChar.Parent do
                if newAura and newAura.Parent then
                    newAura.CFrame = newRoot.CFrame
                end
                task.wait()
            end
        end)
    end
end

player.CharacterAdded:Connect(onCharacterAdded)

-- 5. UI DE STATUS (Opcional, para confirmar que está rodando)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "HackStatus"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local label = Instance.new("TextLabel")
label.Name = "StatusLabel"
label.Size = UDim2.new(0, 200, 0, 40)
label.Position = UDim2.new(0, 10, 0, 10)
label.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
label.BackgroundTransparency = 0.3
label.TextColor3 = Color3.fromRGB(0, 255, 128)
label.TextScaled = true
label.Font = Enum.Font.GothamBold
label.Text = "HACK ATIVO\nSpeed: 48 | Aura: ON\nESP Neutro: ON"
label.Parent = screenGui

print("[DELTA] Script executado com sucesso!")
print("[DELTA] Speed: " .. speedMultiplier)
print("[DELTA] Aura: Ativa")
print("[DELTA] ESP Neutralization: Ativa")
