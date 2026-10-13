-- DELTA MOBILE V3.0 - VISUAL FIX & DEBUG
-- Corrigido para: Aura Visível, Menu no Topo e Indicador de ESP

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- CONFIGURAÇÕES AVANÇADAS
local CONFIG = {
    Speed = 48,
    JumpPower = 60,
    AuraColor = Color3.fromRGB(0, 255, 128),
    AuraSize = 1.5, -- Aumentado para ser mais visível
    ESPRadius = 300, -- Aumentado para cobrir mais área
    ESPInterval = 0.1, -- Mais rápido
    MenuDisplayOrder = 9999 -- Força o menu a ficar no topo
}

-- 1. SISTEMA DE UI ROBUSTO
local function createDebugUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "DeltaHackUI"
    screenGui.ResetOnSpawn = false
    screenGui.DisplayOrder = CONFIG.MenuDisplayOrder
    screenGui.IgnoreGuiInset = true
    screenGui.Parent = player:WaitForChild("PlayerGui")
    
    -- Painel Principal
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainPanel"
    mainFrame.Size = UDim2.new(0, 250, 0, 120)
    mainFrame.Position = UDim2.new(0, 10, 0, 10)
    mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    mainFrame.BackgroundTransparency = 0.2
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = mainFrame
    
    -- Título
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 30)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.TextColor3 = CONFIG.AuraColor
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.Text = "DELTA HACK ACTIVE"
    title.Parent = mainFrame
    
    -- Status de Velocidade
    local speedLabel = Instance.new("TextLabel")
    speedLabel.Name = "SpeedStatus"
    speedLabel.Size = UDim2.new(1, -10, 0, 25)
    speedLabel.Position = UDim2.new(0, 5, 0, 35)
    speedLabel.BackgroundTransparency = 1
    speedLabel.TextColor3 = Color3.new(1, 1, 1)
    speedLabel.TextScaled = true
    speedLabel.Font = Enum.Font.Code
    speedLabel.Text = "SPEED: " .. CONFIG.Speed
    speedLabel.Parent = mainFrame
    
    -- Status da Aura
    local auraLabel = Instance.new("TextLabel")
    auraLabel.Name = "AuraStatus"
    auraLabel.Size = UDim2.new(1, -10, 0, 25)
    auraLabel.Position = UDim2.new(0, 5, 0, 60)
    auraLabel.BackgroundTransparency = 1
    auraLabel.TextColor3 = CONFIG.AuraColor
    auraLabel.TextScaled = true
    auraLabel.Font = Enum.Font.Code
    auraLabel.Text = "AURA: VISIBLE (GLOW)"
    auraLabel.Parent = mainFrame
    
    -- Indicador de ESP (Distância)
    local espLabel = Instance.new("TextLabel")
    espLabel.Name = "ESPIndicator"
    espLabel.Size = UDim2.new(1, -10, 0, 25)
    espLabel.Position = UDim2.new(0, 5, 0, 85)
    espLabel.BackgroundTransparency = 1
    espLabel.TextColor3 = Color3.new(1, 1, 1)
    espLabel.TextScaled = true
    espLabel.Font = Enum.Font.Code
    espLabel.Text = "ESP NEUTRALIZE: [SCANING...]"
    espLabel.Parent = mainFrame
    
    return screenGui, espLabel
end

-- 2. CRIAÇÃO DA AURA MELHORADA
local function createEnhancedAura(character, rootPart)
    -- Remove auras antigas
    local oldAura = character:FindFirstChild("SuperAura")
    if oldAura then oldAura:Destroy() end
    
    -- Aura Principal
    local aura = Instance.new("Part")
    aura.Name = "SuperAura"
    aura.Shape = Enum.PartType.Ball
    aura.Size = Vector3.new(CONFIG.AuraSize, CONFIG.AuraSize, CONFIG.AuraSize)
    aura.Material = Enum.Material.Neon
    aura.BrickColor = BrickColor.new(CONFIG.AuraColor)
    aura.CanCollide = false
    aura.Transparency = 0.4 -- Mais opaca para ser vista
    aura.Anchored = true
    aura.CastShadow = false
    aura.Parent = character
    
    -- Adiciona Glow (Brilho)
    local glow = Instance.new("PointLight")
    glow.Name = "AuraGlow"
    glow.Color = CONFIG.AuraColor
    glow.Brightness = 2
    glow.Range = 15
    glow.Parent = aura
    
    -- Loop de Posicionamento
    task.spawn(function()
        while character and character.Parent do
            if aura and aura.Parent then
                aura.CFrame = rootPart.CFrame
            end
            task.wait()
        end
    end)
end

-- 3. LÓGICA DE ESP COM FEEDBACK VISUAL
local function startESPSystem(rootPart, espLabel)
    task.spawn(function()
        while true do
            task.wait(CONFIG.ESPInterval)
            local nearestDistance = math.huge
            local enemiesNeutralized = 0
            
            for _, otherPlayer in Players:GetPlayers() do
                if otherPlayer ~= player and otherPlayer.Character then
                    local otherHead = otherPlayer.Character:FindFirstChild("Head")
                    if otherHead then
                        local distance = (rootPart.Position - otherHead.Position).Magnitude
                        if distance < CONFIG.ESPRadius then
                            nearestDistance = math.min(nearestDistance, distance)
                            
                            -- Neutraliza
                            local highlight = otherPlayer.Character:FindFirstChildWhichIsA("Highlight")
                            if highlight then 
                                highlight:Destroy()
                                enemiesNeutralized += 1
                            end
                            
                            local billboard = otherPlayer.Character:FindFirstChildWhichIsA("BillboardGui")
                            if billboard then billboard.Enabled = false end
                        end
                    end
                end
            end
            
            -- Atualiza o Texto na Tela
            if espLabel and espLabel.Parent then
                if enemiesNeutralized > 0 then
                    espLabel.Text = "ESP NEUTRALIZE: [" .. enemiesNeutralized .. " CLEARED] (DIST: " .. math.floor(nearestDistance) .. "m)"
                    espLabel.TextColor3 = CONFIG.AuraColor
                else
                    espLabel.Text = "ESP NEUTRALIZE: [NO TARGETS IN " .. CONFIG.ESPRadius .. "m]"
                    espLabel.TextColor3 = Color3.new(1, 1, 1)
                end
            end
        end
    end)
end

-- 4. EXECUÇÃO PRINCIPAL
local function initialize()
    local character = player.Character or player.CharacterAdded:Wait()
    local rootPart = character:WaitForChild("HumanoidRootPart")
    
    -- Aplica Speed
    local humanoid = character:FindFirstChild("Humanoid")
    if humanoid then
        humanoid.WalkSpeed = CONFIG.Speed
        humanoid.JumpPower = CONFIG.JumpPower
    end
    
    -- Cria Aura
    createEnhancedAura(character, rootPart)
    
    -- Cria UI e Inicia ESP
    local _, espLabel = createDebugUI()
    startESPSystem(rootPart, espLabel)
    
    -- Reaplicar ao Respawn
    player.CharacterAdded:Connect(function(newChar)
        task.wait(1)
        local newRoot = newChar:WaitForChild("HumanoidRootPart")
        local newHumanoid = newChar:FindFirstChild("Humanoid")
        if newHumanoid then
            newHumanoid.WalkSpeed = CONFIG.Speed
            newHumanoid.JumpPower = CONFIG.JumpPower
        end
        createEnhancedAura(newChar, newRoot)
    end)
end

pcall(initialize, function(err)
    print("ERRO CRÍTICO: " .. tostring(err))
end)
