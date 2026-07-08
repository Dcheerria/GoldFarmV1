-- LocalScript, taruh di StarterPlayerScripts
-- Versi headless: semua fitur langsung aktif tanpa GUI.
-- Fix: FindPartsInRegion3 -> GetPartBoundsInBox + Gold Node cache,
--      CPU throttle adaptive, Optimazia auto-apply, connection cleanup.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer

----------------------------------------------------------------
-- INTEGRASI MODUL GAME (DIPROTEKSI)
----------------------------------------------------------------
local Packets, GameFunctions
pcall(function()
    Packets = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Packets"))
    GameFunctions = require(ReplicatedStorage:WaitForChild("Game"):WaitForChild("functions"))
end)

----------------------------------------------------------------
-- KONFIGURASI
----------------------------------------------------------------
local TARGET_ITEMS = {
    ["Bloodfruit"] = true,
    ["Raw Gold"] = true,
}

local MIN_HEALTH    = 50
local ITEM_ARGUMENT = 6
local CPS           = 5

local currentSpeed      = 16.5
local longWaitDuration  = 6.3
local ARRIVE_THRESHOLD  = 1.5
local TRIGGER_RADIUS    = 2
local clickInterval     = 0.1

----------------------------------------------------------------
-- WAYPOINTS: {Position, fixedWait or nil, isLongWait}
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

----------------------------------------------------------------
-- OPTIMAZIA: auto-apply saat startup (tanpa GUI)
----------------------------------------------------------------
local function applyOptimazia()
    pcall(function()
        Lighting.GlobalShadows = false
        Lighting.Technology = Enum.Technology.Compatibility
        Lighting.FogEnd = 100000
        Lighting.Brightness = 1
        Lighting.Ambient = Color3.fromRGB(128, 128, 128)
        Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)

        for _, child in ipairs(Lighting:GetChildren()) do
            if child:IsA("PostEffect") or child:IsA("Sky") or child:IsA("Atmosphere") then
                pcall(function() child.Enabled = false end)
            end
        end

        workspace.Terrain.Decoration = false
        workspace.Terrain.Transparency = 1

        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
    end)
end

applyOptimazia()

----------------------------------------------------------------
-- GOLD NODE CACHE (fix: gak pakai GetDescendants tiap loop)
-- Cache semua Gold Node sekali di awal, update otomatis kalau
-- ada yang spawn/despawn selama game jalan.
----------------------------------------------------------------
local goldNodes = {}

local function indexGoldNodes()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj.Name == "Gold Node" and obj:IsA("Model") then
            table.insert(goldNodes, obj)
        end
    end
end

indexGoldNodes()

workspace.DescendantAdded:Connect(function(obj)
    if obj.Name == "Gold Node" and obj:IsA("Model") then
        table.insert(goldNodes, obj)
    end
end)

workspace.DescendantRemoving:Connect(function(obj)
    for i, node in ipairs(goldNodes) do
        if node == obj then
            table.remove(goldNodes, i)
            break
        end
    end
end)

----------------------------------------------------------------
-- AUTOCLICKER (klik tengah layar)
----------------------------------------------------------------
local autoClickerActive = false
local autoClickRunId    = 0

local function getScreenCenter()
    local camera = workspace.CurrentCamera
    return camera and (camera.ViewportSize / 2) or Vector2.new(0, 0)
end

local function fireClickAt(pos)
    pcall(function()
        VirtualInputManager:SendTouchTap(pos, false)
    end)
end

local function runAutoClicker(thisRunId)
    while autoClickerActive and thisRunId == autoClickRunId do
        local pos = getScreenCenter()
        if pos.X > 0 then
            fireClickAt(pos)
        end
        task.wait(clickInterval)
    end
end

----------------------------------------------------------------
-- BACKGROUND WORKER 1: Fast Auto-Eat (5 CPS, min health 50)
----------------------------------------------------------------
task.spawn(function()
    local eatDelay = 1 / CPS
    while true do
        task.wait(eatDelay)
        pcall(function()
            local character = player.Character
            if not character then return end
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid and humanoid.Health > 0 and humanoid.Health <= MIN_HEALTH then
                if Packets and Packets.UseBagItem then
                    Packets.UseBagItem.send(ITEM_ARGUMENT)
                end
            end
        end)
    end
end)

----------------------------------------------------------------
-- BACKGROUND WORKER 2: Auto-Pickup radius 24 studs
----------------------------------------------------------------
task.spawn(function()
    while true do
        task.wait(0.1)
        pcall(function()
            local character = player.Character
            if not character then return end
            local hrp = character:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            local myPos = hrp.Position

            for _, item in ipairs(CollectionService:GetTagged("Pickup")) do
                if TARGET_ITEMS[item.Name] then
                    local ok, itemPos = pcall(function()
                        return item:GetPivot().Position
                    end)
                    if ok and (myPos - itemPos).Magnitude <= 24 then
                        pcall(function()
                            if GameFunctions and Packets and Packets.Pickup then
                                local validItem = GameFunctions.getItem(item)
                                if validItem then
                                    local entityId = validItem:GetAttribute("EntityID")
                                    if entityId then
                                        Packets.Pickup.send(entityId)
                                    end
                                end
                            end
                        end)
                    end
                end
            end
        end)
    end
end)

----------------------------------------------------------------
-- BACKGROUND WORKER 3: Auto-detect Gold Node (pakai cache, fix
-- FindPartsInRegion3 deprecated -> GetPartBoundsInBox)
----------------------------------------------------------------
task.spawn(function()
    local overlapParams = OverlapParams.new()

    while true do
        task.wait(0.2)
        pcall(function()
            local character = player.Character
            if not character then return end
            local hrp = character:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            local myPos = hrp.Position

            local foundNodeClose = false

            -- cek dari cache goldNodes (jauh lebih ringan dari GetDescendants tiap frame)
            for _, node in ipairs(goldNodes) do
                if node and node.Parent then
                    local ok, nodePos = pcall(function()
                        return node:GetPivot().Position
                    end)
                    if ok and (myPos - nodePos).Magnitude <= TRIGGER_RADIUS then
                        foundNodeClose = true
                        break
                    end
                end
            end

            -- fallback: kalau cache kosong, cek pakai GetPartBoundsInBox
            -- (pengganti FindPartsInRegion3 yang deprecated)
            if not foundNodeClose and #goldNodes == 0 then
                local regionSize = Vector3.new(TRIGGER_RADIUS * 2, TRIGGER_RADIUS * 2, TRIGGER_RADIUS * 2)
                local parts = {}
                pcall(function()
                    parts = workspace:GetPartBoundsInBox(CFrame.new(myPos), regionSize, overlapParams)
                end)
                for _, part in ipairs(parts) do
                    if part.Name == "Gold Node"
                        or (part.Parent and part.Parent.Name == "Gold Node") then
                        foundNodeClose = true
                        break
                    end
                end
            end

            if foundNodeClose then
                if not autoClickerActive then
                    autoClickerActive = true
                    autoClickRunId += 1
                    task.spawn(runAutoClicker, autoClickRunId)
                end
            else
                if autoClickerActive then
                    autoClickerActive = false
                    autoClickRunId += 1
                end
            end
        end)
    end
end)

----------------------------------------------------------------
-- MOVEMENT LOGIC (BodyVelocity + adaptive CPU throttle)
----------------------------------------------------------------
local isRunning  = true
local runId      = 1
local bodyVelocity = nil

local function getCharacterParts()
    local character = player.Character or player.CharacterAdded:Wait()
    local hrp = character:WaitForChild("HumanoidRootPart")
    local humanoid = character:WaitForChild("Humanoid")
    return character, hrp, humanoid
end

local function createBodyVelocity(hrp)
    -- hapus BodyVelocity lama kalau ada (biar gak numpuk)
    local old = hrp:FindFirstChild("PathBodyVelocity")
    if old then old:Destroy() end

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
        local toTarget   = targetPos - currentPos
        local distance   = toTarget.Magnitude

        if distance <= ARRIVE_THRESHOLD then
            if bodyVelocity then bodyVelocity.Velocity = Vector3.zero end
            reached = true
        else
            if bodyVelocity then
                bodyVelocity.Velocity = toTarget.Unit * currentSpeed
            end
        end

        -- adaptive throttle: jauh -> hemat CPU (~20fps), deket -> full precision
        if distance > 50 then
            task.wait(0.03)
        else
            RunService.Heartbeat:Wait()
        end
    end
    if bodyVelocity then bodyVelocity.Velocity = Vector3.zero end
end

local function runPathLoop(thisRunId)
    local _, hrp, _ = getCharacterParts()
    bodyVelocity = createBodyVelocity(hrp)

    -- respawn handler: kalau character mati/respawn, restart loop
    local respawnConn
    respawnConn = player.CharacterAdded:Connect(function(newChar)
        if bodyVelocity then
            pcall(function() bodyVelocity:Destroy() end)
            bodyVelocity = nil
        end
        respawnConn:Disconnect()
        task.wait(1) -- tunggu character fully loaded
        runId += 1
        task.spawn(runPathLoop, runId)
    end)

    while isRunning and thisRunId == runId do
        for i, waypoint in ipairs(waypoints) do
            if not isRunning or thisRunId ~= runId then break end

            local targetPos  = waypoint[1]
            local fixedWait  = waypoint[2]
            local isLongWait = waypoint[3]
            local waitTime   = isLongWait and longWaitDuration or fixedWait

            -- cek hrp masih valid sebelum gerak
            if not hrp or not hrp.Parent then break end

            moveToPoint(hrp, targetPos, thisRunId)

            if not isRunning or thisRunId ~= runId then break end

            if waitTime and waitTime > 0 then
                task.wait(waitTime)
            end
        end
    end

    if bodyVelocity then
        pcall(function() bodyVelocity:Destroy() end)
        bodyVelocity = nil
    end
end

----------------------------------------------------------------
-- AUTO BED SPAWN: klik BedButton tiap kali SpawnGui muncul
-- (handle first load + respawn setelah mati)
----------------------------------------------------------------
task.spawn(function()
    local playerGui = player:WaitForChild("PlayerGui")

    local function tryClickBed(spawnGui)
        pcall(function()
            local customization = spawnGui:WaitForChild("Customization", 10)
            if not customization then return end
            local bedButton = customization:WaitForChild("BedButton", 10)
            if not bedButton then return end

            -- klik tiap 5s selama SpawnGui masih visible/ada
            while spawnGui and spawnGui.Parent and spawnGui.Enabled ~= false do
                pcall(function() bedButton:Activate() end)
                print("[BOT] BedButton diklik.")
                task.wait(5)
            end
        end)
    end

    -- handle SpawnGui yang udah ada saat script jalan
    local existing = playerGui:FindFirstChild("SpawnGui")
    if existing then
        task.spawn(tryClickBed, existing)
    end

    -- handle SpawnGui yang muncul setelah mati/respawn
    playerGui.ChildAdded:Connect(function(child)
        if child.Name == "SpawnGui" then
            task.spawn(tryClickBed, child)
        end
    end)
end)
print("[BOT] Starting... Optimazia ON, semua worker aktif.")
task.spawn(runPathLoop, runId)
