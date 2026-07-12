-- 🔥 CHEAT MENU COM SWITCHES + SLIDER FOV

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = Workspace.CurrentCamera

local aimbotEnabled = true
local pullEnabled = true
local noclipEnabled = false
local aimFOV = 150  -- Valor inicial

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 320, 0, 420)
Main.Position = UDim2.new(0.5, -160, 0.5, -210)
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 50)
Title.BackgroundColor3 = Color3.fromRGB(0, 140, 255)
Title.Text = "🔥 CHEAT MENU"
Title.TextColor3 = Color3.new(1,1,1)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold
Title.Parent = Main

-- Função para criar Switch (ON/OFF)
local function CreateSwitch(text, yPos, defaultState, callback)
    local SwitchFrame = Instance.new("Frame")
    SwitchFrame.Size = UDim2.new(0.9, 0, 0, 50)
    SwitchFrame.Position = UDim2.new(0.05, 0, 0, yPos)
    SwitchFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    SwitchFrame.Parent = Main

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.6, 0, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.new(1,1,1)
    Label.TextScaled = true
    Label.Font = Enum.Font.GothamSemibold
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = SwitchFrame

    local Toggle = Instance.new("TextButton")
    Toggle.Size = UDim2.new(0, 80, 0, 30)
    Toggle.Position = UDim2.new(0.75, 0, 0.5, -15)
    Toggle.BackgroundColor3 = defaultState and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(170, 0, 0)
    Toggle.Text = defaultState and "ON" or "OFF"
    Toggle.TextColor3 = Color3.new(1,1,1)
    Toggle.TextScaled = true
    Toggle.Font = Enum.Font.GothamBold
    Toggle.Parent = SwitchFrame

    local enabled = defaultState

    Toggle.MouseButton1Click:Connect(function()
        enabled = not enabled
        if enabled then
            Toggle.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
            Toggle.Text = "ON"
        else
            Toggle.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
            Toggle.Text = "OFF"
        end
        callback(enabled)
    end)
end

-- Função Slider para FOV
local function CreateSlider(yPos)
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Size = UDim2.new(0.9, 0, 0, 70)
    SliderFrame.Position = UDim2.new(0.05, 0, 0, yPos)
    SliderFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    SliderFrame.Parent = Main

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, 0, 0, 25)
    Label.BackgroundTransparency = 1
    Label.Text = "Aim FOV: " .. aimFOV
    Label.TextColor3 = Color3.new(1,1,1)
    Label.TextScaled = true
    Label.Font = Enum.Font.GothamSemibold
    Label.Parent = SliderFrame

    local Bar = Instance.new("Frame")
    Bar.Size = UDim2.new(1, -20, 0, 10)
    Bar.Position = UDim2.new(0, 10, 0.6, 0)
    Bar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    Bar.Parent = SliderFrame

    local Knob = Instance.new("Frame")
    Knob.Size = UDim2.new(0, 20, 0, 20)
    Knob.Position = UDim2.new((aimFOV/360), 0, 0.5, -10)
    Knob.BackgroundColor3 = Color3.fromRGB(0, 140, 255)
    Knob.Parent = Bar

    local dragging = false

    Knob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mousePos = UserInputService:GetMouseLocation().X
            local barPos = Bar.AbsolutePosition.X
            local barSize = Bar.AbsoluteSize.X
            
            local percent = math.clamp((mousePos - barPos) / barSize, 0, 1)
            aimFOV = math.floor(percent * 360)
            
            Knob.Position = UDim2.new(percent, 0, 0.5, -10)
            Label.Text = "Aim FOV: " .. aimFOV
        end
    end)
end

-- Criando os Switches e Slider
CreateSwitch("🔫 Mira Automática", 60, true, function(state) aimbotEnabled = state end)
CreateSwitch("🧲 Puxar Itens", 120, true, function(state) pullEnabled = state end)
CreateSwitch("👻 Noclip", 180, false, function(state) noclipEnabled = state end)

CreateSlider(250)

-- Aimbot com FOV controlável
RunService.RenderStepped:Connect(function()
    if not aimbotEnabled then return end
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end

    local closest = nil
    local minDist = aimFOV

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") then
            local dist = (character.HumanoidRootPart.Position - plr.Character.Head.Position).Magnitude
            if dist < minDist then
                minDist = dist
                closest = plr
            end
        end
    end

    if closest then
        Camera.CFrame = Camera.CFrame:Lerp(
            CFrame.lookAt(Camera.CFrame.Position, closest.Character.Head.Position), 
            0.1
        )
    end
end)

-- Puxar Itens
RunService.Heartbeat:Connect(function()
    if not pullEnabled then return end
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            local d = (root.Position - obj.Position).Magnitude
            if d < 80 then
                local n = obj.Name:lower()
                if n:find("coin") or n:find("drop") or n:find("item") or n:find("gem") then
                    obj.CFrame = root.CFrame + Vector3.new(0, 3, 0)
                end
            end
        end
    end
end)

-- Noclip
RunService.Stepped:Connect(function()
    if LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = not noclipEnabled
            end
        end
    end
end)

print("✅ Menu com Slider carregado!")
print("Pressione INSERT para mostrar/esconder o menu")
