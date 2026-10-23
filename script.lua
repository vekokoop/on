-- Blockspin Elite Stealth & Farm Hub (iPad / Delta Optimized)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Clean up old UI if exists
if CoreGui:FindFirstChild("BlockspinEliteHub") then
    CoreGui.BlockspinEliteHub:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BlockspinEliteHub"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

-- Floating Toggle Button (Optimized for iPad Touch)
local ToggleButton = Instance.new("TextButton")
ToggleButton.Parent = ScreenGui
ToggleButton.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
ToggleButton.Position = UDim2.new(0.02, 0, 0.2, 0)
ToggleButton.Size = UDim2.new(0, 50, 0, 50)
ToggleButton.Font = Enum.Font.FredokaOne
ToggleButton.Text = "🛡️"
ToggleButton.TextColor3 = Color3.fromRGB(0, 255, 170)
ToggleButton.TextSize = 22
ToggleButton.Draggable = true
Instance.new("UICorner", ToggleButton).CornerRadius = UDim.new(1, 0)

-- Main Scrolling Frame (iPad Friendly UI)
local MainFrame = Instance.new("ScrollingFrame")
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
MainFrame.Position = UDim2.new(0.12, 0, 0.15, 0)
MainFrame.Size = UDim2.new(0, 450, 0, 360)
MainFrame.Visible = true
MainFrame.Draggable = true
MainFrame.CanvasSize = UDim2.new(0, 0, 1.8, 0)
MainFrame.ScrollBarThickness = 6
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

-- Title Bar
local Title = Instance.new("TextLabel")
Title.Parent = MainFrame
Title.BackgroundColor3 = Color3.fromRGB(25, 25, 38)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Font = Enum.Font.FredokaOne
Title.Text = "  Blockspin Elite Hub [iPad Edition]"
Title.TextColor3 = Color3.fromRGB(0, 255, 170)
Title.TextSize = 15
Title.TextXAlignment = Enum.TextXAlignment.Left
Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 12)

-- Toggle UI visibility
ToggleButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

----------------------------------------------------
-- SETTINGS & VARIABLES
----------------------------------------------------
local Settings = {
    Aimbot = false,
    FOV = 120,
    ESP = false,
    AutoFarmJob = false,
    InfiniteStamina = false
}

-- FOV Circle for Aimbot
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = false
FOVCircle.Radius = Settings.FOV
FOVCircle.Color = Color3.fromRGB(0, 255, 170)
FOVCircle.Thickness = 2
FOVCircle.Filled = false
FOVCircle.Transparency = 0.8
FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

----------------------------------------------------
-- UI GENERATOR HELPERS
----------------------------------------------------
local function AddButton(name, posY, callback)
    local btn = Instance.new("TextButton")
    btn.Parent = MainFrame
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    btn.Position = UDim2.new(0.05, 0, 0, posY)
    btn.Size = UDim2.new(0.9, 0, 0, 38)
    btn.Font = Enum.Font.SourceSansBold
    btn.Text = name .. ": [OFF]"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 15
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.BackgroundColor3 = state and Color3.fromRGB(0, 170, 90) or Color3.fromRGB(30, 30, 45)
        btn.Text = name .. (state and ": [ON]" : ": [OFF]")
        callback(state)
    end)
    return btn
end

local function AddHeader(text, posY)
    local lbl = Instance.new("TextLabel")
    lbl.Parent = MainFrame
    lbl.BackgroundTransparency = 1
    lbl.Position = UDim2.new(0.05, 0, 0, posY)
    lbl.Size = UDim2.new(0.9, 0, 0, 25)
    lbl.Font = Enum.Font.FredokaOne
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(180, 180, 220)
    lbl.TextSize = 14
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    return lbl
end

----------------------------------------------------
-- FEATURE 1: ESP (Wallhack)
----------------------------------------------------
local espHighlights = {}
RunService.RenderStepped:Connect(function()
    pcall(function()
        if Settings.ESP then
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    local char = player.Character
                    if not espHighlights[player] then
                        local hl = Instance.new("Highlight")
                        hl.Parent = char
                        hl.Adornee = char
                        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        hl.FillColor = (player.Team == LocalPlayer.Team) and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 50, 50)
                        espHighlights[player] = hl
                    end
                elseif espHighlights[player] then
                    espHighlights[player]:Destroy()
                    espHighlights[player] = nil
                end
            end
        else
            for _, hl in pairs(espHighlights) do
                if hl then hl:Destroy() end
            end
            espHighlights = {}
        end
    end)
end)

----------------------------------------------------
-- FEATURE 2: AIMBOT (Head Lock + FOV Circle)
----------------------------------------------------
local function GetClosestPlayer()
    local target, shortest = nil, Settings.FOV
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
            local char = p.Character
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                local head = char.Head
                local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
                if onScreen then
                    local dist = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)).Magnitude
                    if dist < shortest then
                        shortest = dist
                        target = head
                    end
                end
            end
        end
    end
    return target
end

RunService.RenderStepped:Connect(function()
    pcall(function()
        FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        FOVCircle.Radius = Settings.FOV
        if Settings.Aimbot then
            local t = GetClosestPlayer()
            if t then
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, t.Position)
            end
        end
    end)
end)

----------------------------------------------------
-- FEATURE 3: AUTO-FARM JOBS (Janitor / Chef Prompts)
----------------------------------------------------
task.spawn(function()
    while true do
        pcall(function()
            if Settings.AutoFarmJob then
                for _, obj in pairs(workspace:GetDescendants()) do
                    if obj:IsA("ProximityPrompt") and Settings.AutoFarmJob then
                        fireproximityprompt(obj)
                    end
                end
            end
        end)
        task.wait(1.5)
    end
end)

----------------------------------------------------
-- BUILD UI SECTIONS & BUTTONS
----------------------------------------------------
AddHeader("--- COMBAT & AIM ---", 45)
AddButton("Aimbot (Head Lock + FOV)", 75, function(v) Settings.Aimbot = v FOVCircle.Visible = v end)

AddHeader("--- VISUALS (ESP) ---", 125)
AddButton("ESP Wallhack (Red/Green)", 155, function(v) Settings.ESP = v end)

AddHeader("--- AUTO-FARM & JOBS ---", 205)
AddButton("Auto-Farm Jobs (Janitor/Chef)", 235, function(v) Settings.AutoFarmJob = v end)

AddHeader("--- STABILITY & PROTECTION ---", 285)
-- Footer status notice
local StatusLbl = Instance.new("TextLabel")
StatusLbl.Parent = MainFrame
StatusLbl.BackgroundTransparency = 1
StatusLbl.Position = UDim2.new(0.05, 0, 0, 320)
StatusLbl.Size = UDim2.new(0.9, 0, 0, 30)
StatusLbl.Font = Enum.Font.SourceSansItalic
StatusLbl.Text = "Status: Stealth & Safe pcall Active 🛡️"
StatusLbl.TextColor3 = Color3.fromRGB(150, 150, 190)
StatusLbl.TextSize:ge = 13
StatusLbl.TextXAlignment = Enum.TextXAlignment.Center

print("Blockspin Elite Hub Loaded Successfully!")
