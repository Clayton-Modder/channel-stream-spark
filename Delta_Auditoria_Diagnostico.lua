-- Delta_Auditoria_Menu_Corrigido.lua
-- Interface mobile + diagnóstico somente leitura.
-- Não ativa cheats, não dispara remotos e não modifica o personagem.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

if not LocalPlayer then
    warn("[Auditoria] LocalPlayer indisponível. Execute dentro de uma experiência Roblox.")
    return
end

local ok, err = pcall(function()
    local playerGui = LocalPlayer:WaitForChild("PlayerGui", 10)
    if not playerGui then error("PlayerGui não ficou disponível.") end

    -- Limpa a versão anterior desta interface.
    local old = playerGui:FindFirstChild("DeltaAuditoriaMenu")
    if old then old:Destroy() end

    local gui = Instance.new("ScreenGui")
    gui.Name = "DeltaAuditoriaMenu"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = false
    gui.DisplayOrder = 999
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent = playerGui

    local function corner(obj, radius)
        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, radius or 8)
        c.Parent = obj
    end

    local function makeButton(parent, text, size, pos, color)
        local b = Instance.new("TextButton")
        b.Size = size
        b.Position = pos
        b.BackgroundColor3 = color or Color3.fromRGB(49, 91, 145)
        b.BorderSizePixel = 0
        b.Text = text
        b.TextColor3 = Color3.fromRGB(255,255,255)
        b.TextSize = 14
        b.Font = Enum.Font.GothamBold
        b.AutoButtonColor = true
        b.Parent = parent
        corner(b, 8)
        return b
    end

    local frame = Instance.new("Frame")
    frame.Name = "Main"
    frame.AnchorPoint = Vector2.new(0.5, 0.5)
    frame.Size = UDim2.new(0.88, 0, 0, 390)
    frame.Position = UDim2.new(0.5, 0, 0.5, 0)
    frame.BackgroundColor3 = Color3.fromRGB(24, 27, 34)
    frame.BorderSizePixel = 0
    frame.Parent = gui
    corner(frame, 12)

    local sizeConstraint = Instance.new("UISizeConstraint")
    sizeConstraint.MinSize = Vector2.new(270, 320)
    sizeConstraint.MaxSize = Vector2.new(430, 520)
    sizeConstraint.Parent = frame

    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 44)
    header.BackgroundColor3 = Color3.fromRGB(34, 39, 49)
    header.BorderSizePixel = 0
    header.Parent = frame
    corner(header, 12)

    local title = Instance.new("TextLabel")
    title.BackgroundTransparency = 1
    title.Position = UDim2.new(0, 12, 0, 0)
    title.Size = UDim2.new(1, -100, 1, 0)
    title.Text = "AUDITORIA • DELTA"
    title.TextColor3 = Color3.fromRGB(245,245,245)
    title.TextSize = 15
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header

    local minimize = makeButton(header, "—", UDim2.new(0, 34, 0, 30), UDim2.new(1, -76, 0, 7), Color3.fromRGB(74, 83, 99))
    local close = makeButton(header, "×", UDim2.new(0, 34, 0, 30), UDim2.new(1, -38, 0, 7), Color3.fromRGB(150, 55, 55))

    local status = Instance.new("TextLabel")
    status.BackgroundTransparency = 1
    status.Position = UDim2.new(0, 12, 0, 48)
    status.Size = UDim2.new(1, -24, 0, 24)
    status.Text = "Pronto • somente leitura"
    status.TextColor3 = Color3.fromRGB(150, 220, 170)
    status.TextSize = 12
    status.Font = Enum.Font.Gotham
    status.TextXAlignment = Enum.TextXAlignment.Left
    status.Parent = frame

    local runButton = makeButton(frame, "Executar diagnóstico", UDim2.new(1, -24, 0, 38), UDim2.new(0, 12, 0, 76))
    local clearButton = makeButton(frame, "Limpar relatório", UDim2.new(1, -24, 0, 32), UDim2.new(0, 12, 0, 120), Color3.fromRGB(70, 76, 88))

    local output = Instance.new("TextLabel")
    output.Name = "Report"
    output.Position = UDim2.new(0, 12, 0, 160)
    output.Size = UDim2.new(1, -24, 1, -172)
    output.BackgroundColor3 = Color3.fromRGB(13, 15, 20)
    output.BorderSizePixel = 0
    output.TextColor3 = Color3.fromRGB(225, 230, 238)
    output.TextSize = 12
    output.Font = Enum.Font.Code
    output.TextXAlignment = Enum.TextXAlignment.Left
    output.TextYAlignment = Enum.TextYAlignment.Top
    output.TextWrapped = true
    output.Text = "Toque em 'Executar diagnóstico'.\n\nEste menu não altera o jogo."
    output.Parent = frame
    corner(output, 8)

    local reopen = makeButton(gui, "AUDIT", UDim2.new(0, 64, 0, 48), UDim2.new(0, 14, 0.55, 0), Color3.fromRGB(40, 112, 82))
    reopen.Visible = false
    corner(reopen, 24)

    -- Arrastar usando toque ou mouse.
    local dragging, dragInput, dragStart, startPos
    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    header.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input == dragInput or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    minimize.Activated:Connect(function()
        frame.Visible = false
        reopen.Visible = true
    end)
    reopen.Activated:Connect(function()
        frame.Visible = true
        reopen.Visible = false
    end)
    close.Activated:Connect(function()
        gui:Destroy()
    end)
    clearButton.Activated:Connect(function()
        output.Text = "Relatório limpo.\nToque em 'Executar diagnóstico'."
        status.Text = "Pronto • relatório limpo"
    end)

    local function safeFullName(obj)
        local good, value = pcall(function() return obj:GetFullName() end)
        return good and value or obj.Name
    end

    local function diagnose()
        local lines = {}
        local function add(s) table.insert(lines, s) end
        add("DIAGNÓSTICO PASSIVO")
        add("Horário: " .. os.date("%H:%M:%S"))
        add("Jogador: " .. tostring(LocalPlayer.Name))
        add("")

        local character = LocalPlayer.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            add(string.format("WalkSpeed observado: %.2f", humanoid.WalkSpeed))
            if humanoid.UseJumpPower then
                add(string.format("JumpPower observado: %.2f", humanoid.JumpPower))
            else
                add(string.format("JumpHeight observado: %.2f", humanoid.JumpHeight))
            end
        else
            add("Personagem/Humanoid: ainda indisponível")
        end

        local words = {"key", "chave", "door", "porta", "gate", "portao", "portão"}
        local matches = {}
        for _, obj in ipairs(Workspace:GetDescendants()) do
            local name = string.lower(obj.Name)
            local matched = false
            for _, word in ipairs(words) do
                if string.find(name, word, 1, true) then matched = true break end
            end
            if matched and (obj:IsA("Model") or obj:IsA("BasePart") or obj:IsA("Tool") or obj:IsA("ProximityPrompt")) then
                if #matches < 15 then table.insert(matches, safeFullName(obj)) end
            end
        end
        add("")
        add("Objetos com nomes relacionados a chaves/portas (máx. 15): " .. tostring(#matches))
        if #matches == 0 then add(" - Nenhum encontrado por nome.") end
        for _, path in ipairs(matches) do add(" - " .. path) end

        local remoteNames = {}
        for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                if #remoteNames < 20 then
                    local kind = obj:IsA("RemoteEvent") and "RemoteEvent" or "RemoteFunction"
                    table.insert(remoteNames, kind .. ": " .. safeFullName(obj))
                end
            end
        end
        add("")
        add("Remotos visíveis em ReplicatedStorage (máx. 20): " .. tostring(#remoteNames))
        if #remoteNames == 0 then add(" - Nenhum encontrado nessa área.") end
        for _, remote in ipairs(remoteNames) do add(" - " .. remote) end

        add("")
        add("Nota: descoberta por nome não comprova vulnerabilidade.")
        add("Nenhum evento foi chamado e nenhum atributo foi alterado.")
        return table.concat(lines, "\n")
    end

    runButton.Activated:Connect(function()
        status.Text = "Lendo informações acessíveis..."
        output.Text = "Executando diagnóstico..."
        task.spawn(function()
            local good, result = pcall(diagnose)
            if good then
                output.Text = result
                status.Text = "Concluído • somente leitura"
                print("[Delta Auditoria]\n" .. result)
            else
                output.Text = "Falha no diagnóstico:\n" .. tostring(result)
                status.Text = "Erro • veja o relatório"
                warn("[Delta Auditoria] " .. tostring(result))
            end
        end)
    end)

    print("[Delta Auditoria] Menu criado no PlayerGui. Toque em 'Executar diagnóstico'.")
end)

if not ok then
    warn("[Delta Auditoria] Não foi possível criar a interface: " .. tostring(err))
end
