local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer

----------------------------------------------------------------
-- INTEGRASI MODUL GAME (DARI FITUR KEMARIN)
----------------------------------------------------------------
local Packets = require(ReplicatedStorage.Modules.Packets)
local GameFunctions = require(ReplicatedStorage.Game.functions) 

-- Konfigurasi Filter Auto-Pickup
local TARGET_ITEMS = {
    ["Bloodfruit"] = true,
    ["Raw Gold"] = true,
}

-- Konfigurasi Fast Auto-Eat (Udah diubah ke 5 CPS & Min Health 50)
local MIN_HEALTH = 50
local ITEM_ARGUMENT = 6
local CPS = 5

----------------------------------------------------------------
-- WAYPOINTS
----------------------------------------------------------------
local waypoints = {
    {Vector3.new(-147.73, -30.07, -165.87), nil, true},
    {Vector3.new(-109.24, -24.17, -187.50), nil, true},
    {Vector3.new(-128.69, -35.00, -183.10), 0.01, false},
    {Vector3.new(-141.02, -11.87, -188.26), 0.01, false},
    {Vector3.new(-126.94, -7.79, -206.08), nil, true},
    {Vector3.new(-126.00, -3.75, -215.39), 0.01, false},
    {Vector3.new(102.89, -3.00, -326.25), 0.01, false},
    {Vector3.new(186.08, -3.47, -233.67), 0.01, false},
    {Vector3.new(223.61, -3.00, -204.31), 0.01, false},
    {Vector3.new(411.89, -3.67, 128.87), 0.01, false},
    {Vector3.new(453.57, 6.36, 139.23), 0.01, false},
    {Vector3.new(461.60, 16.56, 142.94), 0.01, false},
    {Vector3.new(478.62, 15.39, 150.73), nil, true},
    {Vector3.new(504.06, 12.74, 188.21), 0.01, false},
    {Vector3.new(467.13, 15.30, 238.22), nil, true},
    {Vector3.new(509.99, 12.53, 164.11), 0.01, false},
    {Vector3.new(519.12, -3.00, 147.19), 0.01, false},
    {Vector3.new(621.35, -3.27, -143.44), 0.01, false},
    {Vector3.new(624.31, 18.55, -164.57), 0.01, false},
    {Vector3.new(632.99, 29.21, -174.60), 0.01, false},
    {Vector3.new(663.02, 36.08, -189.45), nil, true},
    {Vector3.new(697.37, 27.11, -182.30), 0.01, false},
    {Vector3.new(727.39, 24.90, -221.17), 0.01, false},
    {Vector3.new(740.64, 20.49, -277.09), 0.01, false},
    {Vector3.new(699.72, 34.09, -297.40), 0.01, false},
    {Vector3.new(678.81, 52.51, -317.05), 0.01, false},
    {Vector3.new(682.06, 80.56, -372.30), 0.01, false},
    {Vector3.new(677.09, 78.95, -381.96), nil, true},
    {Vector3.new(633.86, 48.47, -357.08), 0.01, false},
    {Vector3.new(580.62, 13.45, -350.00), 0.01, false},
    {Vector3.new(609.73, -6.18, -353.38), nil, true},
    {Vector3.new(622.33, -6.21, -359.16), nil, true},
    {Vector3.new(636.71, -7.20, -375.39), nil, true},
    {Vector3.new(613.61, -6.25, -384.32), nil, true},
    {Vector3.new(557.05, 11.62, -393.43), 0.01, false},
    {Vector3.new(506.29, -4.67, -385.39), 0.01, false},
    {Vector3.new(22.75, -3.11, -523.12), 0.01, false},
    {Vector3.new(-65.09, -3.11, -527.69), 0.01, false},
    {Vector3.new(-79.71, 5.00, -533.88), 0.01, false},
    {Vector3.new(-202.26, 6.74, -622.02), 0.01, false},
    {Vector3.new(-212.27, 25.33, -625.94), nil, true},
    {Vector3.new(-232.01, -2.78, -638.53), 0.01, false},
    {Vector3.new(-262.32, -39.11, -656.54), 0.01, false},
    {Vector3.new(-226.31, -38.97, -633.08), 0.01, false},
    {Vector3.new(-149.40, -23.31, -563.70), 0.01, false},
    {Vector3.new(-118.20, -39.51, -611.25), 0.01, false},
    {Vector3.new(-146.85, -54.88, -631.76), 0.01, false},
    {Vector3.new(-177.84, -64.19, -608.29), 0.01, false},
    {Vector3.new(-211.72, -57.96, -629.11), nil, true},
    {Vector3.new(-177.84, -64.19, -608.29), 0.01, false},
    {Vector3.new(-158.42, -64.82, -591.58), 0.01, false},
    {Vector3.new(-175.88, -63.80, -553.14), 0.01, false},
    {Vector3.new(-164.27, -63.02, -521.57), 0.01, false},
    {Vector3.new(-190.30, -66.24, -464.96), 0.01, false},
    {Vector3.new(-166.16, -98.18, -452.94), 0.01, false},
    {Vector3.new(-91.88, -103.00, -425.60), 0.01, false},
    {Vector3.new(-50.10, -103.00, -430.36), 0.01, false},
    {Vector3.new(18.88, -99.85, -411.12), 0.01, false},
    {Vector3.new(25.49, -99.01, -373.50), 0.01, false},
    {Vector3.new(40.41, -95.68, -371.76), nil, true},
    {Vector3.new(57.69, -95.69, -355.40), nil, true},
    {Vector3.new(17.02, -98.66, -387.86), 0.01, false},
    {Vector3.new(18.76, -99.90, -416.97), 0.01, false},
    {Vector3.new(-87.45, -102.32, -431.01), 0.01, false},
    {Vector3.new(-122.78, -102.90, -335.43), 0.01, false},
    {Vector3.new(-112.94, -91.12, -279.20), 0.01, false},
    {Vector3.new(-153.35, -87.36, -257.07), 0.01, false},
    {Vector3.new(-224.83, -83.06, -259.45), 0.01, false},
    {Vector3.new(-245.45, -82.74, -245.67), nil, true},
    {Vector3.new(-224.83, -83.06, -259.45), 0.01, false},
    {Vector3.new(-245.03, -74.41, -297.54), 0.01, false},
    {Vector3.new(-252.99, -74.54, -314.63), 0.01, false},
    {Vector3.new(-303.95, -75.70, -371.95), nil, true},
    {Vector3.new(-252.99, -74.54, -314.63), 0.01, false},
    {Vector3.new(-245.03, -74.41, -297.54), 0.01, false},
    {Vector3.new(-224.83, -83.06, -259.45), 0.01, false},
    {Vector3.new(-153.35, -87.36, -257.07), 0.01, false},
    {Vector3.new(-89.26, -82.73, -218.67), 0.01, false},
    {Vector3.new(-49.30, -81.96, -213.02), 0.01, false},
    {Vector3.new(-10.98, -83.42, -182.03), 0.01, false},
    {Vector3.new(3.33, -80.45, -150.76), 0.01, false},
    {Vector3.new(46.73, -75.16, -141.67), 0.01, false},
    {Vector3.new(82.95, -71.91, -130.99), 0.01, false},
    {Vector3.new(92.68, -48.71, -48.34), 0.01, false},
    {Vector3.new(43.29, -36.63, -41.88), 0.01, false},
    {Vector3.new(-6.70, -32.38, -129.97), 0.01, false},
    {Vector3.new(-63.66, -35.00, -136.64), 3.5, false},
    {Vector3.new(-65.00, -35.03, -97.20), 0.01, false},
    {Vector3.new(-96.43, -35.47, -105.77), 0.01, false},
    {Vector3.new(-122.10, -36.63, -129.21), 0.01, false},
}

local DEFAULT_SPEED = 16.5
local currentSpeed = DEFAULT_SPEED
local DEFAULT_LONG_WAIT = 6.3
local longWaitDuration = DEFAULT_LONG_WAIT
local ARRIVE_THRESHOLD = 1.5

local showIndicator = false
local autoClickerPanelOpen = false
local autoClickerActive = false
local clickInterval = 0.1

----------------------------------------------------------------
-- ROOT GUI
----------------------------------------------------------------
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ControlPanelGui"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = player:WaitForChild("PlayerGui")

local menuButton = Instance.new("TextButton")
menuButton.Name = "MenuButton"
menuButton.Size = UDim2.new(0, 34, 0, 34)
menuButton.Position = UDim2.new(0, 10, 0, 10)
menuButton.Text = "☰"
menuButton.TextSize = 16
menuButton.Font = Enum.Font.GothamBold
menuButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
menuButton.TextColor3 = Color3.fromRGB(255, 255, 255)
menuButton.ZIndex = 100
menuButton.Parent = screenGui

local menuButtonCorner = Instance.new("UICorner")
menuButtonCorner.CornerRadius = UDim.new(1, 0)
menuButtonCorner.Parent = menuButton

local panel = Instance.new("Frame")
panel.Name = "ControlPanel"
panel.Size = UDim2.new(0, 170, 0, 0)
panel.AutomaticSize = Enum.AutomaticSize.Y
panel.Position = UDim2.new(0, 10, 0, 50)
panel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
panel.BackgroundTransparency = 0.15
panel.Visible = false
panel.ZIndex = 90
panel.Parent = screenGui

local panelCorner = Instance.new("UICorner")
panelCorner.CornerRadius = UDim.new(0, 8)
panelCorner.Parent = panel

local panelPadding = Instance.new("UIPadding")
panelPadding.PaddingTop = UDim.new(0, 8)
panelPadding.PaddingBottom = UDim.new(0, 8)
panelPadding.PaddingLeft = UDim.new(0, 8)
panelPadding.PaddingRight = UDim.new(0, 8)
panelPadding.Parent = panel

local panelLayout = Instance.new("UIListLayout")
panelLayout.SortOrder = Enum.SortOrder.LayoutOrder
panelLayout.Padding = UDim.new(0, 5)
panelLayout.Parent = panel

menuButton.MouseButton1Click:Connect(function()
    panel.Visible = not panel.Visible
end)

----------------------------------------------------------------
-- Helper builders
----------------------------------------------------------------
local ROW_HEIGHT = 28
local TEXT_SIZE = 12

local function newButton(order, text, bgColor)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, ROW_HEIGHT)
    btn.Text = text
    btn.TextSize = TEXT_SIZE
    btn.Font = Enum.Font.GothamBold
    btn.BackgroundColor3 = bgColor
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.LayoutOrder = order
    btn.Parent = panel

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 6)
    c.Parent = btn

    return btn
end

local function newLabeledInput(order, labelText, defaultValue)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, ROW_HEIGHT)
    row.BackgroundTransparency = 1
    row.LayoutOrder = order
    row.Parent = panel

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.58, -3, 1, 0)
    label.Text = labelText
    label.TextSize = TEXT_SIZE
    label.Font = Enum.Font.Gotham
    label.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextXAlignment = Enum.TextXAlignment.Center
    label.Parent = row

    local labelCorner = Instance.new("UICorner")
    labelCorner.CornerRadius = UDim.new(0, 6)
    labelCorner.Parent = label

    local box = Instance.new("TextBox")
    box.Size = UDim2.new(0.42, -3, 1, 0)
    box.Position = UDim2.new(0.58, 3, 0, 0)
    box.Text = tostring(defaultValue)
    box.TextSize = TEXT_SIZE
    box.Font = Enum.Font.GothamBold
    box.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    box.TextColor3 = Color3.fromRGB(255, 255, 255)
    box.ClearTextOnFocus = false
    box.Parent = row

    local boxCorner = Instance.new("UICorner")
    boxCorner.CornerRadius = UDim.new(0, 6)
    boxCorner.Parent = box

    return box
end

local function newStatusLabel(order, defaultText)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 24)
    lbl.Text = defaultText
    lbl.TextSize = 11
    lbl.Font = Enum.Font.Gotham
    lbl.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    lbl.TextColor3 = Color3.fromRGB(220, 220, 220)
    lbl.TextWrapped = true
    lbl.LayoutOrder = order
    lbl.Parent = panel

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 6)
    c.Parent = lbl

    return lbl
end

----------------------------------------------------------------
-- ISI PANEL
----------------------------------------------------------------
local startButton = newButton(1, "Start Path", Color3.fromRGB(45, 45, 45))
local speedBox = newLabeledInput(2, "Speed:", DEFAULT_SPEED)
local longWaitBox = newLabeledInput(3, "Long Wait (s):", DEFAULT_LONG_WAIT)
local indicatorToggle = newButton(4, "Show Next Point: OFF", Color3.fromRGB(80, 30, 30))

local autoClickerPanelToggle = newButton(5, "Autoclicker Panel: OFF", Color3.fromRGB(60, 60, 30))
local intervalBox = newLabeledInput(6, "Click Interval (s):", clickInterval)
local activateClickerButton = newButton(7, "Activate Autoclicker", Color3.fromRGB(80, 30, 30))
local goldsLabel = newStatusLabel(8, "Golds Earned: 0")
local optimaziaButton = newButton(9, "Optimazia: OFF", Color3.fromRGB(40, 40, 80))

local statusLabel = newStatusLabel(10, "Status: Idle")

speedBox.FocusLost:Connect(function()
    local num = tonumber(speedBox.Text)
    if num and num > 0 then
        currentSpeed = num
        speedBox.Text = tostring(num)
    else
        speedBox.Text = tostring(currentSpeed)
    end
end)

longWaitBox.FocusLost:Connect(function()
    local num = tonumber(longWaitBox.Text)
    if num and num >= 0 then
        longWaitDuration = num
        longWaitBox.Text = tostring(num)
    else
        longWaitBox.Text = tostring(longWaitDuration)
    end
end)

intervalBox.FocusLost:Connect(function()
    local num = tonumber(intervalBox.Text)
    if num and num > 0 then
        clickInterval = num
        intervalBox.Text = tostring(num)
    else
        intervalBox.Text = tostring(clickInterval)
    end
end)

----------------------------------------------------------------
-- OPTIMAZIA
----------------------------------------------------------------
local Lighting = game:GetService("Lighting")
local optimaziaOn = false
local loopThrottle = 0 

local origLighting = {}
local origTerrainDecoration = workspace.Terrain.Decoration
local origTerrainTransparency = workspace.Terrain.Transparency
local origQuality = settings().Rendering.QualityLevel

local function saveOrigLighting()
    origLighting.GlobalShadows = Lighting.GlobalShadows
    origLighting.Technology = Lighting.Technology
    origLighting.FogEnd = Lighting.FogEnd
    origLighting.FogStart = Lighting.FogStart
    origLighting.Brightness = Lighting.Brightness
    origLighting.Ambient = Lighting.Ambient
    origLighting.OutdoorAmbient = Lighting.OutdoorAmbient

    origLighting.effects = {}
    for _, child in ipairs(Lighting:GetChildren()) do
        if child:IsA("PostEffect") or child:IsA("Sky") or child:IsA("Atmosphere") then
            origLighting.effects[child] = child.Enabled ~= nil and child.Enabled or true
        end
    end
end

local function applyOptimazia()
    Lighting.GlobalShadows = false
    Lighting.Technology = Enum.Technology.Compatibility
    Lighting.FogEnd = 100000 
    Lighting.Brightness = 1
    Lighting.Ambient = Color3.fromRGB(128, 128, 128)
    Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)

    for _, child in ipairs(Lighting:GetChildren()) do
        if child:IsA("PostEffect") or child:IsA("Sky") or child:IsA("Atmosphere") then
            if child:FindFirstChildWhichIsA("BoolValue") == nil then
                pcall(function() child.Enabled = false end)
            end
        end
    end

    workspace.Terrain.Decoration = false
    workspace.Terrain.Transparency = 1

    pcall(function()
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
    end)

    loopThrottle = 0.03
end

local function restoreOptimazia()
    Lighting.GlobalShadows = origLighting.GlobalShadows
    Lighting.Technology = origLighting.Technology
    Lighting.FogEnd = origLighting.FogEnd
    Lighting.FogStart = origLighting.FogStart
    Lighting.Brightness = origLighting.Brightness
    Lighting.Ambient = origLighting.Ambient
    Lighting.OutdoorAmbient = origLighting.OutdoorAmbient

    for child, wasEnabled in pairs(origLighting.effects) do
        pcall(function() child.Enabled = wasEnabled end)
    end

    workspace.Terrain.Decoration = origTerrainDecoration
    workspace.Terrain.Transparency = origTerrainTransparency

    pcall(function()
        settings().Rendering.QualityLevel = origQuality
    end)

    loopThrottle = 0
end

saveOrigLighting()

optimaziaButton.MouseButton1Click:Connect(function()
    optimaziaOn = not optimaziaOn
    optimaziaButton.Text = "Optimazia: " .. (optimaziaOn and "ON" or "OFF")
    optimaziaButton.BackgroundColor3 = optimaziaOn
        and Color3.fromRGB(30, 90, 40)
        or Color3.fromRGB(40, 40, 80)

    if optimaziaOn then
        applyOptimazia()
    else
        restoreOptimazia()
    end
end)

----------------------------------------------------------------
-- NEXT-POINT INDICATOR
----------------------------------------------------------------
local indicatorFolder = Instance.new("Folder")
indicatorFolder.Name = "PathIndicatorFolder"
indicatorFolder.Parent = workspace

local sourceAttachment = nil 
local markerPool = {} 
local beamPool = {} 

local nextLongIndexFor = {}
do
    local n = #waypoints
    local lastLongIndex = nil
    for i = n, 1, -1 do
        if waypoints[i][3] then
            lastLongIndex = i
            break
        end
    end
    local nextLong = lastLongIndex
    for i = n, 1, -1 do
        if waypoints[i][3] then
            nextLong = i
        end
        nextLongIndexFor[i] = nextLong
    end
end

local function getOrCreateMarker(idx)
    if markerPool[idx] then
        return markerPool[idx]
    end

    local part = Instance.new("Part")
    part.Name = "PathBendMarker"
    part.Shape = Enum.PartType.Ball
    part.Size = Vector3.new(1.2, 1.2, 1.2)
    part.Anchored = true
    part.CanCollide = false
    part.CanQuery = false
    part.Material = Enum.Material.Neon
    part.Color = Color3.fromRGB(255, 200, 0)
    part.Transparency = 1
    part.Parent = indicatorFolder

    local attachment = Instance.new("Attachment")
    attachment.Parent = part

    local entry = {part = part, attachment = attachment}
    markerPool[idx] = entry
    return entry
end

local function getOrCreateBeam(idx)
    if beamPool[idx] then
        return beamPool[idx]
    end

    local beam = Instance.new("Beam")
    beam.Name = "PathBendBeam"
    beam.Width0 = 0.4
    beam.Width1 = 0.15
    beam.Color = ColorSequence.new(Color3.fromRGB(255, 200, 0))
    beam.Transparency = NumberSequence.new(0.2)
    beam.FaceCamera = true
    beam.Enabled = false
    beam.Parent = indicatorFolder

    beamPool[idx] = beam
    return beam
end

local function setupIndicatorForCharacter(hrp)
    if sourceAttachment then
        sourceAttachment:Destroy()
    end
    sourceAttachment = Instance.new("Attachment")
    sourceAttachment.Name = "PathIndicatorSource"
    sourceAttachment.Parent = hrp
end

local function updateIndicatorPath(fromIndex)
    local n = #waypoints
    local targetLongIndex = nextLongIndexFor[fromIndex]

    local pathIndices = {}
    local i = fromIndex
    while true do
        table.insert(pathIndices, i)
        if i == targetLongIndex then break end
        i += 1
        if i > n then i = 1 end
        if #pathIndices > n then break end
    end

    local segmentCount = #pathIndices

    for k, wpIndex in ipairs(pathIndices) do
        local marker = getOrCreateMarker(k)
        marker.part.Position = waypoints[wpIndex][1]
        if k == segmentCount then
            marker.part.Size = Vector3.new(2, 2, 2)
        else
            marker.part.Size = Vector3.new(1.2, 1.2, 1.2)
        end
    end

    for k, entry in pairs(markerPool) do
        if k > segmentCount then
            entry.part.Transparency = 1
        end
    end

    for k = 1, segmentCount do
        local beam = getOrCreateBeam(k)
        if k == 1 then
            beam.Attachment0 = sourceAttachment
        else
            beam.Attachment0 = markerPool[k - 1].attachment
        end
        beam.Attachment1 = markerPool[k].attachment
    end

    for k, beam in pairs(beamPool) do
        if k > segmentCount then
            beam.Enabled = false
        end
    end

    return segmentCount
end

local currentSegmentCount = 0

local function setIndicatorVisible(visible)
    showIndicator = visible
    for k, entry in pairs(markerPool) do
        if k <= currentSegmentCount then
            entry.part.Transparency = visible and 0.2 or 1
        end
    end
    for k, beam in pairs(beamPool) do
        if k <= currentSegmentCount then
            beam.Enabled = visible
        else
            beam.Enabled = false
        end
    end
end

local function updateIndicatorTarget(fromIndex)
    currentSegmentCount = updateIndicatorPath(fromIndex)
    setIndicatorVisible(showIndicator)
end

indicatorToggle.MouseButton1Click:Connect(function()
    showIndicator = not showIndicator
    indicatorToggle.Text = "Show Next Point: " .. (showIndicator and "ON" or "OFF")
    indicatorToggle.BackgroundColor3 = showIndicator
        and Color3.fromRGB(30, 90, 40)
        or Color3.fromRGB(80, 30, 30)
    setIndicatorVisible(showIndicator)
end)

----------------------------------------------------------------
-- AUTOCLICKER
----------------------------------------------------------------
local reticle = Instance.new("Frame")
reticle.Name = "AutoClickTarget"
reticle.AnchorPoint = Vector2.new(0.5, 0.5)
reticle.Size = UDim2.new(0, 40, 0, 40)
reticle.Position = UDim2.new(0.5, 0, 0.5, 0)
reticle.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
reticle.BackgroundTransparency = 0.4
reticle.Visible = false
reticle.ZIndex = 95
reticle.Parent = screenGui

local reticleCorner = Instance.new("UICorner")
reticleCorner.CornerRadius = UDim.new(1, 0)
reticleCorner.Parent = reticle

local reticleStroke = Instance.new("UIStroke")
reticleStroke.Thickness = 2
reticleStroke.Color = Color3.fromRGB(255, 255, 255)
reticleStroke.Parent = reticle

local reticleDot = Instance.new("Frame")
reticleDot.AnchorPoint = Vector2.new(0.5, 0.5)
reticleDot.Size = UDim2.new(0, 6, 0, 6)
reticleDot.Position = UDim2.new(0.5, 0, 0.5, 0)
reticleDot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
reticleDot.ZIndex = 96
reticleDot.Parent = reticleDot

local reticleDotCorner = Instance.new("UICorner")
reticleDotCorner.CornerRadius = UDim.new(1, 0)
reticleDotCorner.Parent = reticleDot

local dragging = false
local dragInput = nil
local dragStart = nil
local startPos = nil
local dragEndConn = nil 

local function updateDrag(input)
    local delta = input.Position - dragStart
    reticle.Position = UDim2.new(
        startPos.X.Scale, startPos.X.Offset + delta.X,
        startPos.Y.Scale, startPos.Y.Offset + delta.Y
    )
end

reticle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = reticle.Position

        if dragEndConn then
            dragEndConn:Disconnect()
            dragEndConn = nil
        end

        dragEndConn = input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
                if dragEndConn then
                    dragEndConn:Disconnect()
                    dragEndConn = nil
                end
            end
        end)
    end
end)

reticle.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if reticle.Visible and input == dragInput and dragging then
        updateDrag(input)
    end
end)

autoClickerPanelToggle.MouseButton1Click:Connect(function()
    autoClickerPanelOpen = not autoClickerPanelOpen
    autoClickerPanelToggle.Text = "Autoclicker Panel: " .. (autoClickerPanelOpen and "ON" or "OFF")
    autoClickerPanelToggle.BackgroundColor3 = autoClickerPanelOpen
        and Color3.fromRGB(90, 90, 30)
        or Color3.fromRGB(60, 60, 30)
    reticle.Visible = autoClickerPanelOpen

    if not autoClickerPanelOpen and autoClickerActive then
        autoClickerActive = false
        activateClickerButton.Text = "Activate Autoclicker"
        activateClickerButton.BackgroundColor3 = Color3.fromRGB(80, 30, 30)
    end
end)

local autoClickRunId = 0
local totalClicks = 0

local function getReticleScreenPosition()
    local absPos = reticle.AbsolutePosition
    local absSize = reticle.AbsoluteSize
    return absPos + absSize / 2
end

local function fireClickAt(pos)
    pcall(function()
        VirtualInputManager:SendTouchTap(pos, false)
    end)
end

local function runAutoClicker(thisRunId)
    totalClicks = 0
    while autoClickerActive and thisRunId == autoClickRunId do
        local pos = getReticleScreenPosition()
        fireClickAt(pos)
        totalClicks += 1
        task.wait(clickInterval)
    end
end

activateClickerButton.MouseButton1Click:Connect(function()
    if not autoClickerPanelOpen then
        autoClickerPanelOpen = true
        autoClickerPanelToggle.Text = "Autoclicker Panel: ON"
        autoClickerPanelToggle.BackgroundColor3 = Color3.fromRGB(90, 90, 30)
        reticle.Visible = true
    end

    autoClickerActive = not autoClickerActive
    activateClickerButton.Text = autoClickerActive and "Deactivate Autoclicker" or "Activate Autoclicker"
    activateClickerButton.BackgroundColor3 = autoClickerActive
        and Color3.fromRGB(30, 90, 40)
        or Color3.fromRGB(80, 30, 30)

    if autoClickerActive then
        autoClickRunId += 1
        task.spawn(runAutoClicker, autoClickRunId)
    else
        autoClickRunId += 1
    end
end)

----------------------------------------------------------------
-- 🟢 BACKGROUND WORKERS (SUNTIKAN OTOMATISASI)
----------------------------------------------------------------

-- 1. SUNTIKAN: Fast Auto-Eat 5 CPS di Background (Min Health 50)
task.spawn(function()
    local eatDelay = 1 / CPS
    while true do
        task.wait(eatDelay)
        local character = player.Character
        if character and character:FindFirstChild("Humanoid") then
            local humanoid = character.Humanoid
            if humanoid.Health > 0 and humanoid.Health <= MIN_HEALTH then
                pcall(function()
                    Packets.UseBagItem.send(ITEM_ARGUMENT)
                end)
            end
        end
    end
end)

-- 2. SUNTIKAN: Filter Auto-Pickup Radius 24 Studs di Background
task.spawn(function()
    while true do
        task.wait(0.1) 
        local character = player.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            local myPos = character.HumanoidRootPart.Position
            
            for _, item in ipairs(CollectionService:GetTagged("Pickup")) do
                if TARGET_ITEMS[item.Name] and (item:IsA("BasePart") or item:IsA("Model")) then
                    local itemPos = item:GetPivot().Position
                    if (myPos - itemPos).Magnitude <= 24 then
                        pcall(function()
                            local validItem = GameFunctions.getItem(item)
                            if validItem then
                                local entityId = validItem:GetAttribute("EntityID")
                                if entityId then
                                    Packets.Pickup.send(entityId)
                                end
                            end
                         pcall)
                    end
                end
            end
        end
    end
end)

-- 3. SUNTIKAN: Auto-Toggle Autoclicker Berdasarkan Jarak Gold Node (Radius 2 Studs)
local TRIGGER_RADIUS = 2 

task.spawn(function()
    while true do
        task.wait(0.2) -- Scan hemat CPU tiap 0.2 detik
        local character = player.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            local hrp = character.HumanoidRootPart
            local myPos = hrp.Position
            local foundNodeClose = false
            
            -- Scan area kecil berukuran 4x4x4 studs di sekitar posisi karakter
            local regionSize = Vector3.new(TRIGGER_RADIUS * 2, TRIGGER_RADIUS * 2, TRIGGER_RADIUS * 2)
            local region = Region3.new(myPos - (regionSize/2), myPos + (regionSize/2))
            local partsInRegion = workspace:FindPartsInRegion3(region, character, 100)
            
            for _, part in ipairs(partsInRegion) do
                if part.Name == "Gold Node" or (part.Parent and part.Parent.Name == "Gold Node") then
                    foundNodeClose = true
                    break 
                end
            end
            
            -- Logika Saklar Otomatis Autoclicker
            if foundNodeClose then
                if not autoClickerActive then
                    autoClickerActive = true
                    activateClickerButton.Text = "Deactivate Autoclicker"
                    activateClickerButton.BackgroundColor3 = Color3.fromRGB(30, 90, 40)
                    autoClickRunId += 1
                    task.spawn(runAutoClicker, autoClickRunId)
                    statusLabel.Text = "Status: Menambang Gold Node..."
                end
            else
                if autoClickerActive then
                    autoClickerActive = false
                    activateClickerButton.Text = "Activate Autoclicker"
                    activateClickerButton.BackgroundColor3 = Color3.fromRGB(80, 30, 30)
                    autoClickRunId += 1
                end
            end
        end
    end
end)

----------------------------------------------------------------
-- MOVEMENT LOGIC (BodyVelocity)
----------------------------------------------------------------
local isRunning = false
local runId = 0
local bodyVelocity = nil
local totalGolds = 0

local function getCharacterParts()
    local character = player.Character or player.CharacterAdded:Wait()
    local hrp = character:WaitForChild("HumanoidRootPart")
    local humanoid = character:WaitForChild("Humanoid")
    return character, hrp, humanoid
end

local function createBodyVelocity(hrp)
    local bv = Instance.new("BodyVelocity")
    bv.Name = "PathBodyVelocity"
    bv.MaxForce = Vector3.new(1, 1, 1) * math.huge
    bv.Velocity = Vector3.zero
    bv.P = 1250
    bv.Parent = hrp
    return bv
end

local function moveToPoint(hrp, targetPos, thisRunId)
    local reached = false

    while isRunning and thisRunId == runId and not reached do
        local currentPos = hrp.Position
        local toTarget = targetPos - currentPos
        local distance = toTarget.Magnitude

        if distance <= ARRIVE_THRESHOLD then
            bodyVelocity.Velocity = Vector3.zero
            reached = true
        else
            local direction = toTarget.Unit
            bodyVelocity.Velocity = direction * currentSpeed
        end

        if loopThrottle > 0 and distance > 50 then
            task.wait(loopThrottle)
        else
            RunService.Heartbeat:Wait()
        end
    end

    if bodyVelocity then
        bodyVelocity.Velocity = Vector3.zero
    end
end

local function runPathLoop(thisRunId)
    local character, hrp, humanoid = getCharacterParts()

    bodyVelocity = createBodyVelocity(hrp)
    setupIndicatorForCharacter(hrp)
    setIndicatorVisible(showIndicator)

    while isRunning and thisRunId == runId do
        for i, waypoint in ipairs(waypoints) do
            if not isRunning or thisRunId ~= runId then break end

            local targetPos = waypoint[1]
            local fixedWait = waypoint[2]
            local isLongWait = waypoint[3]
            local waitTime = isLongWait and longWaitDuration or fixedWait

            updateIndicatorTarget(i)

            statusLabel.Text = string.format("Menuju titik %d/%d", i, #waypoints)
            moveToPoint(hrp, targetPos, thisRunId)

            if not isRunning or thisRunId ~= runId then break end

            if waitTime and waitTime > 0 then
                statusLabel.Text = string.format("Diam di titik %d/%d (%.1fs)", i, #waypoints, waitTime)
                task.wait(waitTime)
            end

            if isLongWait then
                totalGolds += 6
                goldsLabel.Text = "Golds Earned: " .. totalGolds
            end
        end
    end

    if bodyVelocity then
        bodyVelocity:Destroy()
        bodyVelocity = nil
    end

    setIndicatorVisible(false)

    if thisRunId == runId then
        statusLabel.Text = "Status: Idle"
    end
end

startButton.MouseButton1Click:Connect(function()
    if not isRunning then
        isRunning = true
        runId += 1
        startButton.Text = "Stop Path"
        statusLabel.Text = "Status: Starting..."
        task.spawn(runPathLoop, runId)
    else
        isRunning = false
        runId += 1
        startButton.Text = "Start Path"
        statusLabel.Text = "Status: Stopping..."

        if bodyVelocity then
            bodyVelocity:Destroy()
            bodyVelocity = nil
        end

        setIndicatorVisible(false)
    end
end)
