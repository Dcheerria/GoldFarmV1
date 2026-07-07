local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")

local player = Players.LocalPlayer

----------------------------------------------------------------
-- INTEGRASI MODUL GAME & KONFIGURASI
----------------------------------------------------------------
local Packets = require(ReplicatedStorage.Modules.Packets)
local GameFunctions = require(ReplicatedStorage.Game.functions) 

-- Filter Auto-Pickup
local TARGET_ITEMS = {
    ["Bloodfruit"] = true,
    ["Raw Gold"] = true,
}

-- Konfigurasi Fast Auto-Eat (5 CPS & Min Health 50)
local MIN_HEALTH = 50
local ITEM_ARGUMENT = 6
local CPS = 5

-- Konfigurasi Pergerakan & Jeda Rute
local currentSpeed = 16.5
local longWaitDuration = 6.3
local ARRIVE_THRESHOLD = 1.5

-- Status Kontrol Internal Skrip
local isRunning = true -- Langsung TRUE biar Autostart
local runId = 1
local autoClickerActive = false
local clickInterval = 0.1 -- Kecepatan getok batu emas (0.1 detik)
local bodyVelocity = nil

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

----------------------------------------------------------------
-- LOGIKA KOORDINAT KLIK (Lock Tengah Layar)
----------------------------------------------------------------
local function getScreenCenter()
    local camera = workspace.CurrentCamera
    if camera then
        return camera.ViewportSize / 2
    end
    return Vector2.new(0, 0)
end

local function fireClickAt(pos)
    pcall(function()
        VirtualInputManager:SendTouchTap(pos, false)
    end)
end

local autoClickRunId = 0
local function runAutoClicker(thisRunId)
    while autoClickerActive and thisRunId == autoClickRunId do
        local centerPos = getScreenCenter()
        if centerPos.X > 0 then
            fireClickAt(centerPos)
        end
        task.wait(clickInterval)
    end
end

----------------------------------------------------------------
-- 🟢 BACKGROUND WORKERS (SISTEM OTOMATISASI BELAKANG LAYAR)
----------------------------------------------------------------

-- 1. Fast Auto-Eat 5 CPS (Min Health 50)
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

-- 2. Filter Auto-Pickup Radius 24 Studs (Bloodfruit & Raw Gold) - FIXED TYPO HERE
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
                        end)
                    end
                end
            end
        end
    end
end)

-- 3. Auto-Toggle Autoclicker Pas Dekat "Gold Node" (Radius 2 Studs)
local TRIGGER_RADIUS = 2 
task.spawn(function()
    while true do
        task.wait(0.2) 
        local character = player.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            local hrp = character.HumanoidRootPart
            local myPos = hrp.Position
            local foundNodeClose = false
            
            local regionSize = Vector3.new(TRIGGER_RADIUS * 2, TRIGGER_RADIUS * 2, TRIGGER_RADIUS * 2)
            local region = Region3.new(myPos - (regionSize/2), myPos + (regionSize/2))
            local partsInRegion = workspace:FindPartsInRegion3(region, character, 100)
            
            for _, part in ipairs(partsInRegion) do
                if part.Name == "Gold Node" or (part.Parent and part.Parent.Name == "Gold Node") then
                    foundNodeClose = true
                    break 
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
        end
    end
end)

----------------------------------------------------------------
-- LOGIKA MOVEMENT & AUTOSTART LOOP
----------------------------------------------------------------
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
        RunService.Heartbeat:Wait()
    end
    if bodyVelocity then bodyVelocity.Velocity = Vector3.zero end
end

local function runPathLoop(thisRunId)
    local character, hrp, humanoid = getCharacterParts()
    bodyVelocity = createBodyVelocity(hrp)

    while isRunning and thisRunId == runId do
        for i, waypoint in ipairs(waypoints) do
            if not isRunning or thisRunId ~= runId then break end

            local targetPos = waypoint[1]
            local fixedWait = waypoint[2]
            local isLongWait = waypoint[3]
            local waitTime = isLongWait and longWaitDuration or fixedWait

            moveToPoint(hrp, targetPos, thisRunId)

            if not isRunning or thisRunId ~= runId then break end

            if waitTime and waitTime > 0 then
                task.wait(waitTime)
            end
        end
    end
end

-- Eksekusi Utama
print("[BOT SYSTEM] Autostart diaktifkan tanpa error!")
task.spawn(runPathLoop, runId)
