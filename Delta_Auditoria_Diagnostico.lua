-- Delta_Auditoria_Diagnostico.lua
-- Diagnóstico passivo para ambiente autorizado.
-- Não dispara RemoteEvents, não altera atributos do personagem e não destaca itens escondidos.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

if not LocalPlayer then
    warn("[Auditoria] Não foi possível obter LocalPlayer. Execute dentro de uma experiência Roblox.")
    return
end

local oldGui = game:GetService("CoreGui"):FindFirstChild("DeltaAuditoriaDiagnostico")
if oldGui then oldGui:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "DeltaAuditoriaDiagnostico"
gui.ResetOnSpawn = false
pcall(function() gui.Parent = game:GetService("CoreGui") end)
if not gui.Parent then gui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local frame = Instance.new("Frame")
frame.Name = "Main"
frame.Size = UDim2.new(0, 320, 0, 390)
frame.Position = UDim2.new(0.5, -160, 0.5, -195)
frame.BackgroundColor3 = Color3.fromRGB(24, 27, 34)
frame.BorderSizePixel = 0
frame.Parent = gui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -44, 0, 38)
title.Position = UDim2.new(0, 12, 0, 4)
title.BackgroundTransparency = 1
title.Text = "Auditoria • Diagnóstico passivo"
title.TextColor3 = Color3.fromRGB(245, 245, 245)
title.TextSize = 16
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = frame

local close = Instance.new("TextButton")
close.Size = UDim2.new(0, 30, 0, 30)
close.Position = UDim2.new(1, -36, 0, 7)
close.BackgroundColor3 = Color3.fromRGB(160, 55, 55)
close.Text = "X"
close.TextColor3 = Color3.new(1,1,1)
close.Font = Enum.Font.GothamBold
close.TextSize = 14
close.Parent = frame
Instance.new("UICorner", close).CornerRadius = UDim.new(0, 7)
close.MouseButton1Click:Connect(function() gui:Destroy() end)

local scan = Instance.new("TextButton")
scan.Size = UDim2.new(1, -24, 0, 38)
scan.Position = UDim2.new(0, 12, 0, 48)
scan.BackgroundColor3 = Color3.fromRGB(55, 105, 175)
scan.Text = "Executar diagnóstico"
scan.TextColor3 = Color3.new(1,1,1)
scan.Font = Enum.Font.GothamBold
scan.TextSize = 14
scan.Parent = frame
Instance.new("UICorner", scan).CornerRadius = UDim.new(0, 7)

local output = Instance.new("TextLabel")
output.Size = UDim2.new(1, -24, 1, -100)
output.Position = UDim2.new(0, 12, 0, 94)
output.BackgroundColor3 = Color3.fromRGB(15, 17, 22)
output.TextColor3 = Color3.fromRGB(225, 230, 238)
output.TextSize = 12
output.Font = Enum.Font.Code
output.TextXAlignment = Enum.TextXAlignment.Left
output.TextYAlignment = Enum.TextYAlignment.Top
output.TextWrapped = true
output.Text = "Toque em 'Executar diagnóstico'.\n\nEste script só lê informações que o cliente consegue acessar."
output.Parent = frame
Instance.new("UICorner", output).CornerRadius = UDim.new(0, 7)

-- Arrastar a janela usando mouse ou toque.
local dragging, dragStart, startPos
frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
frame.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

local function safeFullName(obj)
    local ok, value = pcall(function() return obj:GetFullName() end)
    return ok and value or obj.Name
end

local function runDiagnostics()
    local lines = {}
    local function add(s) table.insert(lines, s) end
    add("AUDITORIA PASSIVA — " .. os.date("%H:%M:%S"))
    add("Jogador: " .. LocalPlayer.Name)

    local character = LocalPlayer.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        add(string.format("Movimento observado: WalkSpeed=%.2f", humanoid.WalkSpeed))
        local jumpValue = humanoid.UseJumpPower and humanoid.JumpPower or humanoid.JumpHeight
        add(string.format("Salto observado: %s=%.2f", humanoid.UseJumpPower and "JumpPower" or "JumpHeight", jumpValue))
    else
        add("Personagem/Humanoid ainda não disponível.")
    end

    local keywordObjects, remotes = {}, {}
    local keywords = {"key", "chave", "door", "porta", "gate", "portao", "portão"}
    local function hasKeyword(name)
        local lower = string.lower(name)
        for _, word in ipairs(keywords) do
            if string.find(lower, word, 1, true) then return true end
        end
        return false
    end

    -- Apenas lista objetos acessíveis; não revela nem marca visualmente objetos.
    local count = 0
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if hasKeyword(obj.Name) and (obj:IsA("Model") or obj:IsA("BasePart") or obj:IsA("Tool") or obj:IsA("ProximityPrompt")) then
            count += 1
            if #keywordObjects < 12 then table.insert(keywordObjects, safeFullName(obj)) end
        end
        if count >= 500 then break end
    end
    add("Objetos com nomes relacionados a chaves/portas: " .. tostring(count) .. (count >= 500 and "+ (limite de busca)" or ""))
    for _, path in ipairs(keywordObjects) do add(" • " .. path) end
    if #keywordObjects == 0 then add(" • Nenhum objeto correspondente encontrado no Workspace acessível.") end

    for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            if #remotes < 20 then
                table.insert(remotes, (obj:IsA("RemoteEvent") and "RemoteEvent: " or "RemoteFunction: ") .. safeFullName(obj))
            end
        end
    end
    add("Remotos encontrados em ReplicatedStorage: " .. tostring(#remotes) .. (#remotes >= 20 and "+ (mostrando até 20)" or ""))
    for _, path in ipairs(remotes) do add(" • " .. path) end
    if #remotes == 0 then add(" • Nenhum remoto encontrado nessa área acessível.") end

    add("")
    add("LEMBRETE: nomes/objetos/remotos não provam vulnerabilidade.")
    add("Não foram enviados comandos nem alterado o personagem.")
    local report = table.concat(lines, "\n")
    output.Text = report
    print("\n========== RELATÓRIO DE AUDITORIA ==========\n" .. report .. "\n============================================")
end

scan.MouseButton1Click:Connect(function()
    output.Text = "Executando leitura..."
    local ok, err = pcall(runDiagnostics)
    if not ok then
        output.Text = "Erro no diagnóstico:\n" .. tostring(err)
        warn("[Auditoria] " .. tostring(err))
    end
end)

print("[Auditoria] Interface carregada. Toque em 'Executar diagnóstico'.")
