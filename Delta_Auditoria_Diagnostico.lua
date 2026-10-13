-- DELTA MOBILE BULLETPROOF SCRIPT
-- Versão 2.0 - Com Debug e UI Forçada

-- 1. VERIFICAÇÃO DE AMBIENTE
if not game or not game.Players or not game.Players.LocalPlayer then
    print("[ERRO] Ambiente Roblox não detectado.")
    return
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- 2. FUNÇÃO DE LOG (Para ver erros na tela do jogo)
local function log(msg, color)
    color = color or "info"
    local screenGui = player:FindFirstChild("PlayerGui")
    if not screenGui then return end
    
    local existingGui = screenGui:FindFirstChild("DeltaHackLog")
    if not existingGui then
        existingGui = Instance.new("ScreenGui")
        existingGui.Name = "DeltaHackLog"
        existingGui.ResetOnSpawn = false
        existingGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        existingGui.Parent = screenGui
    end
    
    local label = Instance.new("TextLabel")
    label.Name = "Log_" .. os.time()
    label.Size = UDim2.new(0, 300, 0, 30)
    label.Position = UDim2.new(0, 10, 0, 10)
    label.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    label.BackgroundTransparency = 0.2
    label.TextColor3 = color == "error" and Color3.fromRGB(255, 50, 50) or (color == "success" and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 255, 255))
    label.TextScaled = true
    label.Font = Enum.Font.Code
    label.Text = msg
    label.Parent = existingGui
    
    -- Remove após 5 segundos
    task.delay(5, function()
        if label and label.Parent then
            label:Destroy()
        end
    end)
end

-- 3. CONFIGURAÇÕES
local CONFIG = {
    Speed = 48,
    JumpPower = 60,
    AuraColor = Color3.fromRGB(0, 255, 128),
    AuraSize = 1.2,
    ESPRadius = 250,
    ESPInterval = 0.15
}

-- 4. FUNÇÕES PRINCIPAIS
local function applySpeed(character)
    local humanoid = character:FindFirstChild("Humanoid")
    if humanoid then
        humanoid.WalkSpeed = CONFIG.Speed
        humanoid.JumpPower = CONFIG.JumpPower
        log("Speed: " .. CONFIG.Speed, "success")
    end
end

local function createAura(character, rootPart)
    local existingAura = character:FindFirstChild("SuperAura")
    if existingAura then existingAura:Destroy() end
    
    local aura = Instance.new("Part")
    aura.Name = "SuperAura"
    aura.Shape = Enum.PartType.Ball
    aura.Size = Vector3.new(CONFIG.AuraSize, CONFIG.AuraSize, CONFIG.AuraSize)
    aura.Material = Enum.Material.Neon
    aura.BrickColor = BrickColor.new(CONFIG.AuraColor)
    aura.CanCollide = false
    aura.Transparency = 0.6
    aura.Anchored = true
    aura.Parent = character
    
    task.spawn(function()
        while character and character.Parent do
            if aura and aura.Parent then
                aura.CFrame = rootPart.CFrame
            end
            task.wait()
        end
    end)
    log("Aura Criada", "success")
end

local function neutralizeESP(rootPart)
    local allPlayers = Players:GetPlayers()
    for _, otherPlayer in allPlayers do
        if otherPlayer ~= player and otherPlayer.Character then
            local otherHead = otherPlayer.Character:FindFirstChild("Head")
            if otherHead then
                local distance = (rootPart.Position - otherHead.Position).Magnitude
                if distance < CONFIG.ESPRadius then
                    -- Remove Highlights
                    local highlight = otherPlayer.Character:FindFirstChildWhichIsA("Highlight")
                    if highlight then highlight:Destroy() end
                    
                    -- Remove Billboards
                    local billboard = otherPlayer.Character:FindFirstChildWhichIsA("BillboardGui")
                    if billboard then billboard.Enabled = false end
                end
            end
        end
    end
end

-- 5. LOOP PRINCIPAL
local function startSystem()
    local character = player.Character or player.CharacterAdded:Wait()
    local rootPart = character:WaitForChild("HumanoidRootPart")
    
    -- Aplica Speed Inicial
    applySpeed(character)
    createAura(character, rootPart)
    
    -- Loop de ESP
    task.spawn(function()
        while true do
            task.wait(CONFIG.ESPInterval)
            pcall(function()
                neutralizeESP(rootPart)
            end)
        end
    end)
    
    -- Reaplicar ao respawnar
    player.CharacterAdded:Connect(function(newChar)
        task.wait(1)
        local newRoot = newChar:WaitForChild("HumanoidRootPart")
        applySpeed(newChar)
        createAura(newChar, newRoot)
    end)
    
    log("SISTEMA ATIVO", "success")
end

-- 6. EXECUÇÃO SEGURA
pcall(function()
    startSystem()
end, function(err)
    log("ERRO: " .. tostring(err), "error")
end)
