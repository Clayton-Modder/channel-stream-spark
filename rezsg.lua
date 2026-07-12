-- === TESTE MENU SIMPLES ===
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game.CoreGui

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 400, 0, 300)
Main.Position = UDim2.new(0.5, -200, 0.5, -150)
Main.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
Main.Visible = false
Main.Parent = ScreenGui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 16)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 50)
Title.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
Title.Text = "TESTE MENU"
Title.TextColor3 = Color3.new(1,1,1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 24
Title.Parent = Main

local Close = Instance.new("TextButton")
Close.Size = UDim2.new(0, 40, 0, 40)
Close.Position = UDim2.new(1, -45, 0, 5)
Close.BackgroundTransparency = 1
Close.Text = "✕"
Close.TextColor3 = Color3.new(1,1,1)
Close.TextSize = 28
Close.Parent = Title

-- Botão para abrir
local OpenBtn = Instance.new("TextButton")
OpenBtn.Size = UDim2.new(0, 80, 0, 80)
OpenBtn.Position = UDim2.new(0.5, -40, 0.5, -40)
OpenBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
OpenBtn.Text = "ABRIR"
OpenBtn.TextColor3 = Color3.new(1,1,1)
OpenBtn.TextSize = 18
OpenBtn.Parent = ScreenGui
Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(1, 0)

OpenBtn.MouseButton1Click:Connect(function()
    Main.Visible = not Main.Visible
end)

Close.MouseButton1Click:Connect(function()
    Main.Visible = false
end)

print("✅ MENU DE TESTE CARREGADO!")
print("Clique no botão vermelho para abrir")
