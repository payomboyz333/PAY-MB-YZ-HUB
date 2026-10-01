
-- ==============================================================================
-- [[ PAYOMBOYZ HUB - SNIPER ARENA ROBLOX ]]
-- UI Engine: Obsidian Glassmorphic 2 (Compact Window Edition)
-- Universal Target Scanner: Players + Workspace.World Entities (Bots/Match Targets)
-- Full Combat Suite: Smooth Aimbot + Silent Aim + TriggerBot + No Recoil + Dynamic FOV
-- Full Visuals Suite: Clean Box ESP + Tracers + HealthBar + VisCheck + Invisible Hitbox
-- ======================================================================================

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local SoundService = game:GetService("SoundService")
local Lighting = game:GetService("Lighting")
local Camera = workspace.CurrentCamera
local player = LocalPlayer

-- ==========================================
-- ⚙️ SETTINGS CONFIGURATION
-- ==========================================
local Settings = {
    -- Visuals
    ESPEnabled = true,
    BoxESP = true,
    Tracers = true,
    ShowNames = true,
    ShowDistance = true,
    ShowHealth = true,
    TeamCheck = true,
    WallCheck = true,
    MaxDistance = 1500,
    HighlightESP = false,
    
    -- Hitbox
    HitboxExpander = false,
    HitboxSize = 8,

    -- Combat
    AimbotEnabled = false,
    AimbotSmoothness = 0.25,
    AimPart = "Head", -- "Head" or "HumanoidRootPart"
    SilentAim = false,
    TriggerBot = false,
    NoRecoil = false,
    ShowFOV = true,
    FOVRadius = 150,

    -- Movement & Misc
    SpeedBoost = false,
    WalkSpeedValue = 28,
    Noclip = false,
    FastRespawn = false,
    InfiniteJump = false,
    FPSBoost = false,
}

-- ==========================================
-- 🎨 OBSIDIAN GLASS 2 COLOR PALETTE
-- ==========================================
local COLORS = {
    backdrop = Color3.fromRGB(12, 5, 8),
    shell = Color3.fromRGB(20, 10, 14),
    glass = Color3.fromRGB(32, 14, 20),
    glassDeep = Color3.fromRGB(25, 11, 16),
    glassRaised = Color3.fromRGB(48, 18, 28),
    userPanel = Color3.fromRGB(28, 12, 18),
    surface = Color3.fromRGB(42, 18, 26),
    surfaceRaised = Color3.fromRGB(58, 24, 34),
    surfaceHover = Color3.fromRGB(78, 30, 44),
    surfacePressed = Color3.fromRGB(34, 14, 20),
    input = Color3.fromRGB(20, 9, 13),
    inputFocus = Color3.fromRGB(36, 14, 22),
    divider = Color3.fromRGB(140, 40, 60),
    primary = Color3.fromRGB(255, 45, 85),
    primaryHover = Color3.fromRGB(255, 75, 110),
    primaryPressed = Color3.fromRGB(210, 30, 65),
    secondary = Color3.fromRGB(52, 18, 28),
    text = Color3.fromRGB(255, 255, 255),
    textMuted = Color3.fromRGB(242, 218, 228),
    textFaint = Color3.fromRGB(210, 168, 182),
    accent = Color3.fromRGB(255, 55, 85),
    
    -- ESP & Target Colors
    espEnemy = Color3.fromRGB(255, 60, 60),
    espEnemyVis = Color3.fromRGB(46, 224, 140),
    espEnemyWall = Color3.fromRGB(255, 140, 50),
    espFriend = Color3.fromRGB(80, 200, 255),
    espLocked = Color3.fromRGB(255, 220, 40),
    
    success = Color3.fromRGB(46, 224, 140),
    warning = Color3.fromRGB(255, 185, 70),
    danger = Color3.fromRGB(255, 60, 60),
    disabled = Color3.fromRGB(50, 25, 32),
}

-- Forward declarations
local tracers = {}
local espLabels = {}
local espBoxes = {}
local espHealthBars = {}
local currentLockedTarget = nil
local toggleFPSBoost
local noRecoilConn = nil
local triggerBotDebounce = false

-- ==========================================
-- 🔊 UI SOUND HELPERS & NOTIFICATIONS
-- ==========================================
local function playClickSound()
    pcall(function()
        local sound = Instance.new("Sound")
        sound.SoundId = "rbxassetid://6895079853"
        sound.Volume = 0.35
        sound.Parent = SoundService
        sound:Play()
        sound.Ended:Connect(function() sound:Destroy() end)
    end)
end

local function notify(title, content, duration)
    pcall(function()
        duration = duration or 3
        local parentGui = (typeof(gethui) == "function") and gethui() or CoreGui
        local notifHolder = parentGui:FindFirstChild("ObsidianGlass_NotifHolder")
        if not notifHolder then
            notifHolder = Instance.new("ScreenGui")
            notifHolder.Name = "ObsidianGlass_NotifHolder"
            notifHolder.ResetOnSpawn = false
            notifHolder.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
            notifHolder.Parent = parentGui
        end

        local toast = Instance.new("Frame")
        toast.Size = UDim2.new(0, 280, 0, 60)
        toast.Position = UDim2.new(1, 20, 1, -80)
        toast.BackgroundColor3 = COLORS.glass
        toast.BackgroundTransparency = 0.15
        toast.BorderSizePixel = 0
        toast.ZIndex = 999999
        toast.Parent = notifHolder

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 10)
        corner.Parent = toast

        local stroke = Instance.new("UIStroke")
        stroke.Color = COLORS.accent
        stroke.Thickness = 1.5
        stroke.Parent = toast

        local tTitle = Instance.new("TextLabel")
        tTitle.Size = UDim2.new(1, -20, 0, 20)
        tTitle.Position = UDim2.new(0, 10, 0, 6)
        tTitle.BackgroundTransparency = 1
        tTitle.Text = title
        tTitle.TextColor3 = COLORS.accent
        tTitle.Font = Enum.Font.GothamBold
        tTitle.TextSize = 13
        tTitle.TextXAlignment = Enum.TextXAlignment.Left
        tTitle.Parent = toast

        local tDesc = Instance.new("TextLabel")
        tDesc.Size = UDim2.new(1, -20, 0, 28)
        tDesc.Position = UDim2.new(0, 10, 0, 26)
        tDesc.BackgroundTransparency = 1
        tDesc.Text = content
        tDesc.TextColor3 = COLORS.text
        tDesc.Font = Enum.Font.Gotham
        tDesc.TextSize = 11
        tDesc.TextWrapped = true
        tDesc.TextXAlignment = Enum.TextXAlignment.Left
        tDesc.Parent = toast

        playClickSound()
        TweenService:Create(toast, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), { Position = UDim2.new(1, -300, 1, -80) }):Play()
        task.delay(duration, function()
            if toast and toast.Parent then
                local tw = TweenService:Create(toast, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In), { Position = UDim2.new(1, 20, 1, -80) })
                tw:Play()
                tw.Completed:Connect(function() toast:Destroy() end)
            end
        end)
    end)
end

-- ==========================================
-- 👤 AVATAR ASSET LOADER
-- ==========================================
local customAvatarAsset = nil
local function loadCustomAvatarImage()
    if customAvatarAsset then return customAvatarAsset end
    local avatarUrl = "https://raw.githubusercontent.com/aslamdunk7/paypmboygang/main/543199739_2812856088914181_3062917809445648175_n.jpg"
    local fileName = "payomboyz_avatar.jpg"

    pcall(function()
        if typeof(writefile) == "function" and (typeof(getcustomasset) == "function" or typeof(getsynasset) == "function") then
            local getAsset = getcustomasset or getsynasset
            local isFileExist = (typeof(isfile) == "function" and isfile(fileName))
            if not isFileExist then
                local imageBytes = game:HttpGet(avatarUrl)
                if imageBytes and #imageBytes > 0 then
                    writefile(fileName, imageBytes)
                end
            end
            if typeof(isfile) == "function" and isfile(fileName) then
                customAvatarAsset = getAsset(fileName)
            end
        end
    end)

    if not customAvatarAsset then
        customAvatarAsset = "rbxthumb://type=AvatarHeadShot&id=" .. LocalPlayer.UserId .. "&w=150&h=150"
    end
    return customAvatarAsset
end

-- ==========================================
-- 🌐 UNIVERSAL TARGET RESOLVER (ENGINE CORE)
-- Scans BOTH Real Players and Workspace.World Entities
-- Resolves Head & RootPart accurately (Collider.Head or direct)
-- ==========================================
local function isTargetVisible(targetHead)
    if not targetHead then return false end
    local origin = Camera.CFrame.Position
    local direction = targetHead.Position - origin
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    
    local filterList = { Camera }
    if player.Character then table.insert(filterList, player.Character) end
    rayParams.FilterDescendantsInstances = filterList
    
    local result = workspace:Raycast(origin, direction, rayParams)
    if not result then return true end
    if result.Instance and (result.Instance:IsDescendantOf(targetHead.Parent) or (targetHead.Parent.Parent and result.Instance:IsDescendantOf(targetHead.Parent.Parent))) then
        return true
    end
    return false
end

local function getAllTargets()
    local targets = {}
    local lpTeam = player:GetAttribute("Team")
    local lpFFA = player:GetAttribute("FFAPoint")

    -- 1. Real Players
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player and p.Character then
            local char = p.Character
            local hum = char:FindFirstChildOfClass("Humanoid")
            local head = char:FindFirstChild("Head") or (char:FindFirstChild("Collider") and char.Collider:FindFirstChild("Head"))
            local root = char:FindFirstChild("HumanoidRootPart") or (char:FindFirstChild("Collider") and char.Collider:FindFirstChild("HumanoidRootPart")) or char.PrimaryPart
            
            if hum and root and hum.Health > 0 then
                local targetTeam = p:GetAttribute("Team") or char:GetAttribute("Team") or (p.Team and p.Team.Name)
                local isEnemy = true
                if Settings.TeamCheck and lpFFA == nil and lpTeam ~= nil and targetTeam ~= nil then
                    isEnemy = (lpTeam ~= targetTeam)
                end

                table.insert(targets, {
                    id = "P_" .. p.Name,
                    name = p.Name,
                    displayName = p.DisplayName,
                    model = char,
                    player = p,
                    humanoid = hum,
                    head = head or root,
                    root = root,
                    team = tostring(targetTeam or "Neutral"),
                    isEnemy = isEnemy,
                    isBot = false,
                })
            end
        end
    end

    -- 2. Match Bot Entities in Workspace.World.<WorldId>.Entities
    local w = workspace:FindFirstChild("World")
    if w then
        for _, worldFolder in ipairs(w:GetChildren()) do
            local entFolder = worldFolder:FindFirstChild("Entities")
            if entFolder then
                for _, model in ipairs(entFolder:GetChildren()) do
                    if model:IsA("Model") and model ~= player.Character then
                        local hum = model:FindFirstChildOfClass("Humanoid")
                        local head = model:FindFirstChild("Head") or (model:FindFirstChild("Collider") and model.Collider:FindFirstChild("Head"))
                        local root = model:FindFirstChild("HumanoidRootPart") or (model:FindFirstChild("Collider") and model.Collider:FindFirstChild("HumanoidRootPart")) or model.PrimaryPart
                        
                        if hum and root and hum.Health > 0 then
                            local targetTeam = model:GetAttribute("Team")
                            local isEnemy = true
                            if Settings.TeamCheck and lpFFA == nil and lpTeam ~= nil and targetTeam ~= nil then
                                isEnemy = (lpTeam ~= targetTeam)
                            end

                            table.insert(targets, {
                                id = "B_" .. model.Name,
                                name = model.Name,
                                displayName = model.Name .. " [BOT]",
                                model = model,
                                player = nil,
                                humanoid = hum,
                                head = head or root,
                                root = root,
                                team = tostring(targetTeam or "Neutral"),
                                isEnemy = isEnemy,
                                isBot = true,
                            })
                        end
                    end
                end
            end
        end
    end

    return targets
end

-- ==========================================
-- 🎯 CLOSEST TARGET FINDER (Crosshair / FOV aware)
-- ==========================================
local function getClosestEnemyToCrosshair()
    local closest = nil
    local shortestDist = Settings.FOVRadius
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local all = getAllTargets()

    for _, target in ipairs(all) do
        if not target.isEnemy and Settings.TeamCheck then continue end
        local aimPart = (Settings.AimPart == "Head") and target.head or target.root
        if not aimPart then continue end

        local vec, onScreen = Camera:WorldToViewportPoint(aimPart.Position)
        if not onScreen or vec.Z <= 0 then continue end

        local screenPos = Vector2.new(vec.X, vec.Y)
        local dist2D = (screenPos - center).Magnitude

        if dist2D <= shortestDist then
            if Settings.WallCheck and not isTargetVisible(target.head) then
                continue
            end
            shortestDist = dist2D
            closest = target
        end
    end

    return closest
end

-- ==========================================
-- 🔑 LOGOUT & SHUTDOWN ENGINE
-- ==========================================
local function performLogoutKeyClear()
    pcall(function()
        local filesToDelete = { "PayomboyZ_LuarmorKey.txt", "PayomboyZ_VVIPKey.txt", "PayomboyZ_SavedKey.txt" }
        local del = (type(delfile) == "function" and delfile) or (type(deletefile) == "function" and deletefile)
        for _, file in ipairs(filesToDelete) do
            pcall(function()
                if isfile and isfile(file) then
                    if del then del(file) elseif type(writefile) == "function" then writefile(file, "") end
                end
            end)
        end
    end)
    pcall(function()
        if getgenv then
            getgenv().script_key = nil
            getgenv().PayomboyZ_InputKey = nil
            getgenv().PayomboyZ_LoggedOut = true
        end
        if _G then _G.script_key = nil end
    end)
end

local function stopAllScriptOperations()
    pcall(function()
        Settings.ESPEnabled = false
        Settings.HitboxExpander = false
        Settings.AimbotEnabled = false
        Settings.SilentAim = false
        Settings.TriggerBot = false
        Settings.NoRecoil = false
        Settings.ShowFOV = false
        Settings.SpeedBoost = false
        Settings.Noclip = false
        Settings.FastRespawn = false
        Settings.InfiniteJump = false

        if noRecoilConn then noRecoilConn:Disconnect(); noRecoilConn = nil end
        if toggleFPSBoost then toggleFPSBoost(false) end

        -- Clear drawings/UI
        for _, line in pairs(tracers) do pcall(function() line:Destroy() end) end
        for _, label in pairs(espLabels) do pcall(function() label:Destroy() end) end
        for _, box in pairs(espBoxes) do pcall(function() box:Destroy() end) end
        for _, bar in pairs(espHealthBars) do pcall(function() bar:Destroy() end) end
        tracers = {}; espLabels = {}; espBoxes = {}; espHealthBars = {}

        -- Restore hitboxes
        for _, t in ipairs(getAllTargets()) do
            pcall(function()
                local hl = t.model:FindFirstChild("PayomHighlight")
                if hl then hl:Destroy() end
                for _, part in ipairs({t.root, t.head}) do
                    if part and part:FindFirstChild("OrigSize") then
                        part.Size = part.OrigSize.Value
                        part.OrigSize:Destroy()
                        part.Transparency = (part == t.root) and 1 or 0
                    end
                end
            end)
        end
    end)
end

-- ==========================================
-- 🗑️ CLEANUP PREVIOUS INSTANCES
-- ==========================================
local parentGui = (typeof(gethui) == "function") and gethui() or CoreGui
for _, name in ipairs({"PayomboyZ_CompactUI", "PayomboyZ", "ESP_Tracers", "PayomFOV"}) do
    local existing = parentGui:FindFirstChild(name)
    if existing then existing:Destroy() end
end

-- Automatic purge of any stale highlights from old scripts
pcall(function()
    for _, p in ipairs(workspace:GetDescendants()) do
        if p.Name == "PayomHighlight" then
            p:Destroy()
        elseif p:IsA("BasePart") and (p.Name == "HumanoidRootPart" or p.Name == "UpperTorso" or p.Name == "LowerTorso") then
            local ov = p:FindFirstChild("OrigSize")
            if ov then
                p.Size = ov.Value
                ov:Destroy()
            end
        end
    end
end)

-- ==========================================
-- 🖥️ CREATE COMPACT OBSIDIAN GLASS MAIN UI
-- ==========================================
local gui = Instance.new("ScreenGui")
gui.Name = "PayomboyZ_CompactUI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.DisplayOrder = 99999
gui.Parent = parentGui

local uiScale = Instance.new("UIScale")
local function updateScale()
    if Camera and Camera.ViewportSize then
        local vp = Camera.ViewportSize
        local targetWidth, targetHeight = 490, 570
        local scaleX = (vp.X - 20) / targetWidth
        local scaleY = (vp.Y - 20) / targetHeight
        uiScale.Scale = math.clamp(math.min(scaleX, scaleY), 0.5, 1.0)
    end
end
updateScale()
if Camera then Camera:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale) end
uiScale.Parent = gui

-- Main Shell (490 x 570)
local shell = Instance.new("Frame")
shell.Name = "MainShell"
shell.Size = UDim2.fromOffset(490, 570)
shell.AnchorPoint = Vector2.new(0.5, 0.5)
shell.Position = UDim2.new(0.5, 0, 0.5, 0)
shell.BackgroundColor3 = COLORS.shell
shell.BackgroundTransparency = 0.15
shell.BorderSizePixel = 0
shell.ClipsDescendants = true
shell.Parent = gui

Instance.new("UICorner", shell).CornerRadius = UDim.new(0, 16)

local shellStroke = Instance.new("UIStroke")
shellStroke.Color = COLORS.accent
shellStroke.Thickness = 1.5
shellStroke.Transparency = 0.25
shellStroke.Parent = shell

-- Header Bar
local headerBar = Instance.new("Frame")
headerBar.Name = "HeaderBar"
headerBar.Size = UDim2.new(1, 0, 0, 44)
headerBar.BackgroundColor3 = COLORS.glassDeep
headerBar.BackgroundTransparency = 0.25
headerBar.BorderSizePixel = 0
headerBar.ZIndex = 10
headerBar.Parent = shell
Instance.new("UICorner", headerBar).CornerRadius = UDim.new(0, 16)

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -90, 0, 20)
titleLabel.Position = UDim2.new(0, 14, 0, 6)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "🎯 PayomboyZ | Sniper Arena"
titleLabel.TextColor3 = COLORS.text
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 14.5
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.ZIndex = 11
titleLabel.Parent = headerBar

local subTitleLabel = Instance.new("TextLabel")
subTitleLabel.Size = UDim2.new(1, -90, 0, 14)
subTitleLabel.Position = UDim2.new(0, 14, 0, 24)
subTitleLabel.BackgroundTransparency = 1
subTitleLabel.Text = "Elite Combat & Precision Target Engine"
subTitleLabel.TextColor3 = COLORS.textMuted
subTitleLabel.Font = Enum.Font.Gotham
subTitleLabel.TextSize = 10
subTitleLabel.TextXAlignment = Enum.TextXAlignment.Left
subTitleLabel.ZIndex = 11
subTitleLabel.Parent = headerBar

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.fromOffset(26, 26)
closeBtn.Position = UDim2.new(1, -34, 0, 9)
closeBtn.BackgroundColor3 = COLORS.glass
closeBtn.BackgroundTransparency = 0.2
closeBtn.Text = "✕"
closeBtn.TextColor3 = COLORS.textMuted
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 13
closeBtn.ZIndex = 12
closeBtn.Parent = headerBar
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)
closeBtn.MouseButton1Click:Connect(function() playClickSound(); shell.Visible = not shell.Visible end)

local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.fromOffset(26, 26)
minBtn.Position = UDim2.new(1, -66, 0, 9)
minBtn.BackgroundColor3 = COLORS.glass
minBtn.BackgroundTransparency = 0.2
minBtn.Text = "─"
minBtn.TextColor3 = COLORS.textMuted
minBtn.Font = Enum.Font.GothamBold
minBtn.TextSize = 12
minBtn.ZIndex = 12
minBtn.Parent = headerBar
Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 6)
minBtn.MouseButton1Click:Connect(function() playClickSound(); shell.Visible = not shell.Visible end)

-- Header Dragging
local dragging, dragInput, dragStart, startPos
headerBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true; dragStart = input.Position; startPos = shell.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
headerBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        shell.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Profile Bar
local profileBar = Instance.new("Frame")
profileBar.Size = UDim2.new(1, -24, 0, 42)
profileBar.Position = UDim2.new(0, 12, 0, 50)
profileBar.BackgroundColor3 = COLORS.userPanel
profileBar.BackgroundTransparency = 0.25
profileBar.BorderSizePixel = 0
profileBar.ZIndex = 10
profileBar.Parent = shell
Instance.new("UICorner", profileBar).CornerRadius = UDim.new(0, 10)

local avFrame = Instance.new("Frame")
avFrame.Size = UDim2.fromOffset(32, 32)
avFrame.Position = UDim2.new(0, 6, 0.5, -16)
avFrame.BackgroundColor3 = COLORS.glassDeep
avFrame.ZIndex = 11
avFrame.Parent = profileBar
Instance.new("UICorner", avFrame).CornerRadius = UDim.new(1, 0)
local avStroke = Instance.new("UIStroke")
avStroke.Color = COLORS.accent; avStroke.Thickness = 1.2; avStroke.Parent = avFrame

local avImg = Instance.new("ImageLabel")
avImg.Size = UDim2.fromScale(1, 1)
avImg.BackgroundTransparency = 1
avImg.Image = loadCustomAvatarImage()
avImg.ZIndex = 12
avImg.Parent = avFrame
Instance.new("UICorner", avImg).CornerRadius = UDim.new(1, 0)

local nameLbl = Instance.new("TextLabel")
nameLbl.Size = UDim2.new(1, -145, 0, 16)
nameLbl.Position = UDim2.new(0, 44, 0, 4)
nameLbl.BackgroundTransparency = 1
nameLbl.Text = LocalPlayer.DisplayName .. " (@" .. LocalPlayer.Name .. ")"
nameLbl.TextColor3 = COLORS.text
nameLbl.Font = Enum.Font.GothamBold
nameLbl.TextSize = 11
nameLbl.TextXAlignment = Enum.TextXAlignment.Left
nameLbl.ZIndex = 11
nameLbl.Parent = profileBar

local metricsLbl = Instance.new("TextLabel")
metricsLbl.Size = UDim2.new(1, -145, 0, 14)
metricsLbl.Position = UDim2.new(0, 44, 0, 20)
metricsLbl.BackgroundTransparency = 1
metricsLbl.Text = "⏱️ 00:00  •  ⚡ 60 FPS  •  📡 0 ms"
metricsLbl.TextColor3 = COLORS.accent
metricsLbl.Font = Enum.Font.GothamBold
metricsLbl.TextSize = 9.5
metricsLbl.TextXAlignment = Enum.TextXAlignment.Left
metricsLbl.ZIndex = 11
metricsLbl.Parent = profileBar

local logoutBtn = Instance.new("TextButton")
logoutBtn.Name = "LogoutButton"
logoutBtn.Size = UDim2.fromOffset(62, 24)
logoutBtn.Position = UDim2.new(1, -70, 0.5, -12)
logoutBtn.BackgroundColor3 = COLORS.surfacePressed
logoutBtn.BackgroundTransparency = 0.20
logoutBtn.Text = "Log out"
logoutBtn.TextColor3 = COLORS.danger
logoutBtn.Font = Enum.Font.GothamBold
logoutBtn.TextSize = 11
logoutBtn.ZIndex = 12
logoutBtn.Parent = profileBar
Instance.new("UICorner", logoutBtn).CornerRadius = UDim.new(0, 6)
local loStroke = Instance.new("UIStroke")
loStroke.Color = COLORS.danger; loStroke.Thickness = 1; loStroke.Transparency = 0.4; loStroke.Parent = logoutBtn

logoutBtn.MouseButton1Click:Connect(function()
    playClickSound(); stopAllScriptOperations(); performLogoutKeyClear()
    pcall(function()
        local pg = (typeof(gethui) == "function") and gethui() or CoreGui
        for _, n in ipairs({"ESP_Tracers", "PayomFOV", "ObsidianGlass_NotifHolder"}) do
            local f = pg:FindFirstChild(n); if f then f:Destroy() end
        end
    end)
    if gui and gui.Parent then gui:Destroy() end
    pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/aslamdunk7/paypmboygang/refs/heads/main/Start"))() end)
end)

-- Realtime metrics loop
task.spawn(function()
    local startTime = os.time()
    local frameCount = 0
    local lastFpsTime = tick()
    local fpsVal = 60
    local conn = RunService.RenderStepped:Connect(function()
        frameCount = frameCount + 1
        local now = tick()
        if now - lastFpsTime >= 1 then fpsVal = frameCount; frameCount = 0; lastFpsTime = now end
    end)
    while task.wait(0.8) do
        if not gui or not gui.Parent then if conn then conn:Disconnect() end; break end
        local elapsed = os.time() - startTime
        local ping = 0
        pcall(function() ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue()) end)
        metricsLbl.Text = string.format("⏱️ %02d:%02d  •  ⚡ %d FPS  •  📡 %d ms",
            math.floor(elapsed / 60), elapsed % 60, fpsVal, ping)
    end
end)

-- ==========================================
-- 📑 TAB NAVIGATION SYSTEM
-- ==========================================
local tabContainer = Instance.new("Frame")
tabContainer.Name = "TabContainer"
tabContainer.Size = UDim2.new(1, -24, 0, 32)
tabContainer.Position = UDim2.new(0, 12, 0, 96)
tabContainer.BackgroundColor3 = COLORS.glassDeep
tabContainer.BackgroundTransparency = 0.4
tabContainer.ZIndex = 10
tabContainer.Parent = shell
Instance.new("UICorner", tabContainer).CornerRadius = UDim.new(0, 8)

local tabLayout = Instance.new("UIListLayout")
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.Padding = UDim.new(0, 4)
tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
tabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
tabLayout.Parent = tabContainer

local currentTab = "Combat"
local tabPages = {}
local tabButtons = {}

local contentScroll = Instance.new("ScrollingFrame")
contentScroll.Name = "ContentScroll"
contentScroll.Size = UDim2.new(1, -24, 1, -136)
contentScroll.Position = UDim2.new(0, 12, 0, 132)
contentScroll.BackgroundTransparency = 1
contentScroll.BorderSizePixel = 0
contentScroll.ScrollBarThickness = 3
contentScroll.ScrollBarImageColor3 = COLORS.accent
contentScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
contentScroll.ZIndex = 10
contentScroll.Parent = shell

local function createTabPage(tabName)
    local page = Instance.new("Frame")
    page.Name = tabName .. "_Page"
    page.Size = UDim2.new(1, 0, 0, 0)
    page.BackgroundTransparency = 1
    page.Visible = (tabName == currentTab)
    page.Parent = contentScroll

    local grid = Instance.new("UIGridLayout")
    grid.CellSize = UDim2.new(0, 224, 0, 52)
    grid.CellPadding = UDim2.new(0, 8, 0, 6)
    grid.SortOrder = Enum.SortOrder.LayoutOrder
    grid.Parent = page

    grid:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        page.Size = UDim2.new(1, 0, 0, grid.AbsoluteContentSize.Y)
        if page.Visible then
            contentScroll.CanvasSize = UDim2.new(0, 0, 0, grid.AbsoluteContentSize.Y + 20)
        end
    end)

    tabPages[tabName] = page
    return page
end

local function switchTab(tabName)
    currentTab = tabName
    playClickSound()
    for name, page in pairs(tabPages) do
        page.Visible = (name == tabName)
        if page.Visible then
            local grid = page:FindFirstChildOfClass("UIGridLayout")
            if grid then
                contentScroll.CanvasSize = UDim2.new(0, 0, 0, grid.AbsoluteContentSize.Y + 20)
            end
        end
    end
    for name, btn in pairs(tabButtons) do
        local isSelected = (name == tabName)
        TweenService:Create(btn, TweenInfo.new(0.2), {
            BackgroundColor3 = isSelected and COLORS.primary or COLORS.glass,
            BackgroundTransparency = isSelected and 0.15 or 0.5
        }):Play()
        btn.TextColor3 = isSelected and COLORS.text or COLORS.textMuted
    end
end

local function addTabButton(icon, title, tabName)
    local btn = Instance.new("TextButton")
    btn.Name = tabName .. "_TabBtn"
    btn.Size = UDim2.new(0.24, -2, 1, -4)
    btn.BackgroundColor3 = (tabName == currentTab) and COLORS.primary or COLORS.glass
    btn.BackgroundTransparency = (tabName == currentTab) and 0.15 or 0.5
    btn.Text = icon .. " " .. title
    btn.TextColor3 = (tabName == currentTab) and COLORS.text or COLORS.textMuted
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    btn.ZIndex = 11
    btn.Parent = tabContainer
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    btn.MouseButton1Click:Connect(function() switchTab(tabName) end)
    tabButtons[tabName] = btn
end

-- Initialize 4 Tab Pages
createTabPage("Combat")
createTabPage("Visuals")
createTabPage("Movement")
createTabPage("Settings")

addTabButton("🎯", "Combat", "Combat")
addTabButton("👁️", "Visuals", "Visuals")
addTabButton("⚡", "Movement", "Movement")
addTabButton("⚙️", "Settings", "Settings")

-- ==========================================
-- 🛠️ UI CONTROLS BUILDER (TOGGLE & SLIDER)
-- ==========================================
local function createObsidianToggle(tabName, name, iconText, titleText, descText, defaultValue, callback)
    local parentPage = tabPages[tabName] or tabPages["Combat"]
    local card = Instance.new("Frame")
    card.Name = name .. "_Card"
    card.Size = UDim2.new(0, 224, 0, 52)
    card.BackgroundColor3 = defaultValue and COLORS.glassRaised or COLORS.glassDeep
    card.BackgroundTransparency = 0.15
    card.BorderSizePixel = 0
    card.ZIndex = 11
    card.Parent = parentPage
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 10)

    local cardStroke = Instance.new("UIStroke")
    cardStroke.Color = defaultValue and COLORS.accent or COLORS.surfaceHover
    cardStroke.Thickness = 1.2
    cardStroke.Transparency = defaultValue and 0.2 or 0.6
    cardStroke.Parent = card

    local iconLabel = Instance.new("TextLabel")
    iconLabel.Size = UDim2.fromOffset(26, 26)
    iconLabel.Position = UDim2.new(0, 8, 0.5, -13)
    iconLabel.BackgroundTransparency = 1
    iconLabel.Text = iconText
    iconLabel.TextSize = 16
    iconLabel.ZIndex = 12
    iconLabel.Parent = card

    local tTitle = Instance.new("TextLabel")
    tTitle.Size = UDim2.new(1, -78, 0, 16)
    tTitle.Position = UDim2.new(0, 36, 0, 8)
    tTitle.BackgroundTransparency = 1
    tTitle.Text = titleText
    tTitle.TextColor3 = COLORS.text
    tTitle.Font = Enum.Font.GothamBold
    tTitle.TextSize = 11.5
    tTitle.TextXAlignment = Enum.TextXAlignment.Left
    tTitle.ZIndex = 12
    tTitle.Parent = card

    local tDesc = Instance.new("TextLabel")
    tDesc.Size = UDim2.new(1, -78, 0, 14)
    tDesc.Position = UDim2.new(0, 36, 0, 26)
    tDesc.BackgroundTransparency = 1
    tDesc.Text = descText
    tDesc.TextColor3 = COLORS.textMuted
    tDesc.Font = Enum.Font.Gotham
    tDesc.TextSize = 9.5
    tDesc.TextXAlignment = Enum.TextXAlignment.Left
    tDesc.ZIndex = 12
    tDesc.Parent = card

    local pill = Instance.new("Frame")
    pill.Size = UDim2.fromOffset(36, 18)
    pill.Position = UDim2.new(1, -42, 0.5, -9)
    pill.BackgroundColor3 = defaultValue and COLORS.primary or COLORS.surface
    pill.ZIndex = 12
    pill.Parent = card
    Instance.new("UICorner", pill).CornerRadius = UDim.new(1, 0)

    local pillKnob = Instance.new("Frame")
    pillKnob.Size = UDim2.fromOffset(14, 14)
    pillKnob.Position = defaultValue and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
    pillKnob.BackgroundColor3 = COLORS.text
    pillKnob.ZIndex = 13
    pillKnob.Parent = pill
    Instance.new("UICorner", pillKnob).CornerRadius = UDim.new(1, 0)

    local state = defaultValue
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.fromScale(1, 1)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.ZIndex = 15
    btn.Parent = card

    btn.MouseButton1Click:Connect(function()
        state = not state
        playClickSound()
        TweenService:Create(card, TweenInfo.new(0.2), {BackgroundColor3 = state and COLORS.glassRaised or COLORS.glassDeep}):Play()
        TweenService:Create(cardStroke, TweenInfo.new(0.2), {Color = state and COLORS.accent or COLORS.surfaceHover, Transparency = state and 0.2 or 0.6}):Play()
        TweenService:Create(pill, TweenInfo.new(0.2), {BackgroundColor3 = state and COLORS.primary or COLORS.surface}):Play()
        TweenService:Create(pillKnob, TweenInfo.new(0.2), {Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)}):Play()
        notify(titleText, state and "เปิดใช้งานแล้ว ✓" or "ปิดการใช้งาน", 2)
        callback(state)
    end)

    return card
end

local function createObsidianSlider(tabName, name, iconText, titleText, minVal, maxVal, defaultVal, suffix, callback)
    local parentPage = tabPages[tabName] or tabPages["Combat"]
    local card = Instance.new("Frame")
    card.Name = name .. "_SliderCard"
    card.Size = UDim2.new(0, 224, 0, 52)
    card.BackgroundColor3 = COLORS.glassDeep
    card.BackgroundTransparency = 0.15
    card.BorderSizePixel = 0
    card.ZIndex = 11
    card.Parent = parentPage
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 10)

    local cardStroke = Instance.new("UIStroke")
    cardStroke.Color = COLORS.surfaceHover
    cardStroke.Thickness = 1.2
    cardStroke.Transparency = 0.6
    cardStroke.Parent = card

    local iconLabel = Instance.new("TextLabel")
    iconLabel.Size = UDim2.fromOffset(26, 26)
    iconLabel.Position = UDim2.new(0, 8, 0, 6)
    iconLabel.BackgroundTransparency = 1
    iconLabel.Text = iconText
    iconLabel.TextSize = 16
    iconLabel.ZIndex = 12
    iconLabel.Parent = card

    local tTitle = Instance.new("TextLabel")
    tTitle.Size = UDim2.new(1, -86, 0, 16)
    tTitle.Position = UDim2.new(0, 36, 0, 6)
    tTitle.BackgroundTransparency = 1
    tTitle.Text = titleText
    tTitle.TextColor3 = COLORS.text
    tTitle.Font = Enum.Font.GothamBold
    tTitle.TextSize = 11
    tTitle.TextXAlignment = Enum.TextXAlignment.Left
    tTitle.ZIndex = 12
    tTitle.Parent = card

    local valLabel = Instance.new("TextLabel")
    valLabel.Size = UDim2.fromOffset(45, 16)
    valLabel.Position = UDim2.new(1, -50, 0, 6)
    valLabel.BackgroundTransparency = 1
    valLabel.Text = tostring(defaultVal) .. (suffix or "")
    valLabel.TextColor3 = COLORS.accent
    valLabel.Font = Enum.Font.GothamBold
    valLabel.TextSize = 11
    valLabel.TextXAlignment = Enum.TextXAlignment.Right
    valLabel.ZIndex = 12
    valLabel.Parent = card

    local sliderTrack = Instance.new("Frame")
    sliderTrack.Size = UDim2.new(1, -20, 0, 6)
    sliderTrack.Position = UDim2.new(0, 10, 0, 34)
    sliderTrack.BackgroundColor3 = COLORS.surface
    sliderTrack.BorderSizePixel = 0
    sliderTrack.ZIndex = 12
    sliderTrack.Parent = card
    Instance.new("UICorner", sliderTrack).CornerRadius = UDim.new(1, 0)

    local initialPct = math.clamp((defaultVal - minVal) / (maxVal - minVal), 0, 1)
    local sliderFill = Instance.new("Frame")
    sliderFill.Size = UDim2.new(initialPct, 0, 1, 0)
    sliderFill.BackgroundColor3 = COLORS.primary
    sliderFill.BorderSizePixel = 0
    sliderFill.ZIndex = 13
    sliderFill.Parent = sliderTrack
    Instance.new("UICorner", sliderFill).CornerRadius = UDim.new(1, 0)

    local isSliding = false
    local function updateFromInput(input)
        local trackPos = sliderTrack.AbsolutePosition.X
        local trackWidth = sliderTrack.AbsoluteSize.X
        local pct = math.clamp((input.Position.X - trackPos) / trackWidth, 0, 1)
        local curVal = math.floor(minVal + (maxVal - minVal) * pct)
        sliderFill.Size = UDim2.new(pct, 0, 1, 0)
        valLabel.Text = tostring(curVal) .. (suffix or "")
        callback(curVal)
    end

    sliderTrack.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isSliding = true
            updateFromInput(input)
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then isSliding = false end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if isSliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateFromInput(input)
        end
    end)

    return card
end

-- ==========================================
-- 💎 DRAGGABLE TOGGLE CAPSULE
-- ==========================================
local toggleCapsule = Instance.new("Frame")
toggleCapsule.Name = "ObsidianToggleCapsule"
toggleCapsule.Size = UDim2.fromOffset(220, 56)
toggleCapsule.Position = UDim2.new(0, 15, 0.5, -28)
toggleCapsule.BackgroundColor3 = COLORS.shell
toggleCapsule.BackgroundTransparency = 0.18
toggleCapsule.BorderSizePixel = 0
toggleCapsule.ClipsDescendants = true
toggleCapsule.ZIndex = 99999
toggleCapsule.Parent = gui
Instance.new("UICorner", toggleCapsule).CornerRadius = UDim.new(0, 16)

local tcStroke = Instance.new("UIStroke")
tcStroke.Color = COLORS.accent; tcStroke.Thickness = 1.5; tcStroke.Transparency = 0.2; tcStroke.Parent = toggleCapsule

local capAvFrame = Instance.new("Frame")
capAvFrame.Size = UDim2.fromOffset(40, 40)
capAvFrame.Position = UDim2.new(0, 8, 0.5, -20)
capAvFrame.BackgroundColor3 = COLORS.glassDeep
capAvFrame.ZIndex = 3
capAvFrame.Parent = toggleCapsule
Instance.new("UICorner", capAvFrame).CornerRadius = UDim.new(1, 0)
local capAvStroke = Instance.new("UIStroke")
capAvStroke.Color = COLORS.primary; capAvStroke.Thickness = 1.5; capAvStroke.Parent = capAvFrame

local capAvImg = Instance.new("ImageLabel")
capAvImg.Size = UDim2.fromScale(1, 1)
capAvImg.BackgroundTransparency = 1
capAvImg.Image = loadCustomAvatarImage()
capAvImg.ZIndex = 4; capAvImg.Parent = capAvFrame
Instance.new("UICorner", capAvImg).CornerRadius = UDim.new(1, 0)

local capUserLbl = Instance.new("TextLabel")
capUserLbl.Size = UDim2.new(1, -56, 0, 16)
capUserLbl.Position = UDim2.new(0, 54, 0, 10)
capUserLbl.BackgroundTransparency = 1
capUserLbl.Text = "@" .. LocalPlayer.Name
capUserLbl.TextColor3 = COLORS.text
capUserLbl.Font = Enum.Font.GothamBold
capUserLbl.TextSize = 11.5
capUserLbl.TextXAlignment = Enum.TextXAlignment.Left
capUserLbl.ZIndex = 3; capUserLbl.Parent = toggleCapsule

local capMetricsLbl = Instance.new("TextLabel")
capMetricsLbl.Size = UDim2.new(1, -56, 0, 14)
capMetricsLbl.Position = UDim2.new(0, 54, 0, 27)
capMetricsLbl.BackgroundTransparency = 1
capMetricsLbl.Text = "⚡ 60 FPS  •  📡 0 ms"
capMetricsLbl.TextColor3 = COLORS.accent
capMetricsLbl.Font = Enum.Font.GothamBold
capMetricsLbl.TextSize = 9.5
capMetricsLbl.TextXAlignment = Enum.TextXAlignment.Left
capMetricsLbl.ZIndex = 3; capMetricsLbl.Parent = toggleCapsule

task.spawn(function()
    local frameCount = 0; local lastFpsTime = tick(); local fpsVal = 60
    local renderConn = RunService.RenderStepped:Connect(function()
        frameCount = frameCount + 1
        local now = tick()
        if now - lastFpsTime >= 1 then fpsVal = frameCount; frameCount = 0; lastFpsTime = now end
    end)
    while task.wait(0.8) do
        if not gui or not gui.Parent or not toggleCapsule or not toggleCapsule.Parent then
            if renderConn then renderConn:Disconnect() end; break
        end
        local pingVal = 0
        pcall(function() pingVal = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue()) end)
        capMetricsLbl.Text = string.format("⚡ %d FPS  •  📡 %d ms", fpsVal, pingVal)
    end
end)

local capBtn = Instance.new("TextButton")
capBtn.Size = UDim2.fromScale(1, 1); capBtn.BackgroundTransparency = 1
capBtn.Text = ""; capBtn.ZIndex = 10; capBtn.Parent = toggleCapsule

local tDragging, tDragInput, tDragStart, tStartPos
local hasDragged = false

capBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        tDragging = true; hasDragged = false
        tDragStart = input.Position; tStartPos = toggleCapsule.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then tDragging = false end
        end)
    end
end)
capBtn.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        tDragInput = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == tDragInput and tDragging then
        local delta = input.Position - tDragStart
        if math.abs(delta.X) > 3 or math.abs(delta.Y) > 3 then hasDragged = true end
        toggleCapsule.Position = UDim2.new(tStartPos.X.Scale, tStartPos.X.Offset + delta.X, tStartPos.Y.Scale, tStartPos.Y.Offset + delta.Y)
    end
end)
capBtn.MouseButton1Click:Connect(function()
    if not hasDragged then playClickSound(); shell.Visible = not shell.Visible end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.K or input.KeyCode == Enum.KeyCode.RightControl then
        shell.Visible = not shell.Visible
    end
end)

-- ==========================================
-- 🎯 COMBAT TAB CONTROLS
-- ==========================================
createObsidianToggle("Combat", "AimbotToggle", "🎯", "Aimbot Lock", "Smooth lock เป้าหมายใน FOV", Settings.AimbotEnabled, function(state)
    Settings.AimbotEnabled = state
end)

createObsidianToggle("Combat", "SilentAimToggle", "🔇", "Silent Aim", "หันทิศทางกระสุนหาหัวทันทีที่ยิง", Settings.SilentAim, function(state)
    Settings.SilentAim = state
end)

createObsidianToggle("Combat", "TriggerBotToggle", "⚡", "TriggerBot", "เล็งโดนศัตรู ยิงอัตโนมัติทันที", Settings.TriggerBot, function(state)
    Settings.TriggerBot = state
end)

createObsidianToggle("Combat", "NoRecoilToggle", "🎪", "No Recoil", "ยิงแล้วกล้องนิ่ง ไม่ดีดขึ้น", Settings.NoRecoil, function(state)
    Settings.NoRecoil = state
    if noRecoilConn then noRecoilConn:Disconnect(); noRecoilConn = nil end
    if state then
        local lastCF = Camera.CFrame
        noRecoilConn = RunService.RenderStepped:Connect(function()
            if not Settings.NoRecoil then return end
            local cur = Camera.CFrame
            local _, cy, _ = cur:ToEulerAnglesYXZ()
            local _, ly, _ = lastCF:ToEulerAnglesYXZ()
            local yawDelta = cy - ly
            if math.abs(yawDelta) < 0.01 then
                Camera.CFrame = CFrame.new(cur.Position) * CFrame.fromEulerAnglesYXZ(select(1, lastCF:ToEulerAnglesYXZ()), cy, 0)
            end
            lastCF = Camera.CFrame
        end)
    end
end)

createObsidianToggle("Combat", "FOVToggle", "⭕", "Show FOV Circle", "แสดงขอบเขตล็อกเป้าบนหน้าจอ", Settings.ShowFOV, function(state)
    Settings.ShowFOV = state
end)

createObsidianSlider("Combat", "FOVSlider", "📏", "FOV Radius", 50, 350, Settings.FOVRadius, "px", function(val)
    Settings.FOVRadius = val
end)

createObsidianSlider("Combat", "SmoothSlider", "🎚️", "Aimbot Smooth", 5, 100, math.floor(Settings.AimbotSmoothness * 100), "%", function(val)
    Settings.AimbotSmoothness = val / 100
end)

-- ==========================================
-- 👁️ VISUALS TAB CONTROLS
-- ==========================================
createObsidianToggle("Visuals", "ESPMasterToggle", "🔍", "ESP Master", "เปิด/ปิด ระบบตรวจจับศัตรูทั้งหมด", Settings.ESPEnabled, function(state)
    Settings.ESPEnabled = state
    if not state then
        for _, line in pairs(tracers) do line.Visible = false end
        for _, label in pairs(espLabels) do label.Visible = false end
        for _, box in pairs(espBoxes) do box.Visible = false end
    end
end)

createObsidianToggle("Visuals", "BoxESPToggle", "📦", "Box ESP", "กรอบเหลี่ยมรอบตัวเป้าหมาย", Settings.BoxESP, function(state)
    Settings.BoxESP = state
    if not state then for _, box in pairs(espBoxes) do box.Visible = false end end
end)

createObsidianToggle("Visuals", "TracersToggle", "📐", "Tracers", "เส้นชี้เป้าจากล่างจอ", Settings.Tracers, function(state)
    Settings.Tracers = state
    if not state then for _, line in pairs(tracers) do line.Visible = false end end
end)

createObsidianToggle("Visuals", "TeamCheckToggle", "🛡️", "Team Check", "คัดแยกทีม ไม่ล็อก/ไม่ขึ้นเพื่อน", Settings.TeamCheck, function(state)
    Settings.TeamCheck = state
end)

createObsidianToggle("Visuals", "WallCheckToggle", "🧱", "Wall Check", "เปลี่ยนสีเขียว/ส้ม เมื่อมองเห็น", Settings.WallCheck, function(state)
    Settings.WallCheck = state
end)

createObsidianToggle("Visuals", "HitboxToggle", "💥", "Hitbox Expander", "ขยายส่วนตรวจจับ (ไม่บังจอชมพู)", Settings.HitboxExpander, function(state)
    Settings.HitboxExpander = state
    if not state then
        for _, t in ipairs(getAllTargets()) do
            pcall(function()
                for _, part in ipairs({t.root, t.head}) do
                    if part and part:FindFirstChild("OrigSize") then
                        part.Size = part.OrigSize.Value
                        part.OrigSize:Destroy()
                        part.Transparency = (part == t.root) and 1 or 0
                    end
                end
            end)
        end
    end
end)

createObsidianSlider("Visuals", "HitboxSlider", "📐", "Hitbox Size", 4, 16, Settings.HitboxSize, "st", function(val)
    Settings.HitboxSize = val
end)

-- ==========================================
-- ⚡ MOVEMENT TAB CONTROLS
-- ==========================================
createObsidianToggle("Movement", "SpeedToggle", "🏃", "Speed Boost", "เพิ่มความเร็วการวิ่งในแผนที่", Settings.SpeedBoost, function(state)
    Settings.SpeedBoost = state
    if not state and player.Character then
        local hum = player.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = 22 end
    end
end)

createObsidianSlider("Movement", "SpeedSlider", "⚡", "WalkSpeed", 16, 75, Settings.WalkSpeedValue, "", function(val)
    Settings.WalkSpeedValue = val
    if Settings.SpeedBoost and player.Character then
        local hum = player.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = val end
    end
end)

createObsidianToggle("Movement", "InfJumpToggle", "🦘", "Infinite Jump", "กระโดดกลางอากาศต่อเนื่อง", Settings.InfiniteJump, function(state)
    Settings.InfiniteJump = state
end)

createObsidianToggle("Movement", "NoclipToggle", "🧱", "Noclip", "เดินทะลุสิ่งกีดขวางได้อิสระ", Settings.Noclip, function(state)
    Settings.Noclip = state
end)

createObsidianToggle("Movement", "FastRespawnToggle", "⚡", "Fast Respawn", "เกิดใหม่ทันทีหลังโดนยิง", Settings.FastRespawn, function(state)
    Settings.FastRespawn = state
end)

createObsidianToggle("Movement", "FPSBoostToggle", "🚀", "FPS Boost", "ลดเอฟเฟกต์ เพิ่มความลื่นไหล", Settings.FPSBoost, function(state)
    Settings.FPSBoost = state
    toggleFPSBoost(state)
end)

-- ==========================================
-- ⚙️ SETTINGS TAB CONTROLS
-- ==========================================
createObsidianToggle("Settings", "NamesToggle", "🏷️", "Show Names & HP", "แสดงชื่อและเลือดบนหัว", Settings.ShowNames, function(state)
    Settings.ShowNames = state
end)

createObsidianToggle("Settings", "DistToggle", "📏", "Show Distance", "แสดงระยะห่าง (studs)", Settings.ShowDistance, function(state)
    Settings.ShowDistance = state
end)

-- ==========================================
-- 🎯 ESP GUI & FOV CIRCLE INITIALIZATION
-- ==========================================
local tracerGui = Instance.new("ScreenGui")
tracerGui.Name = "ESP_Tracers"
tracerGui.ResetOnSpawn = false
tracerGui.IgnoreGuiInset = true
tracerGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
tracerGui.DisplayOrder = 99998
tracerGui.Parent = parentGui

local FOVGui = Instance.new("ScreenGui")
FOVGui.Name = "PayomFOV"
FOVGui.ResetOnSpawn = false
FOVGui.IgnoreGuiInset = true
FOVGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
FOVGui.DisplayOrder = 99997
FOVGui.Parent = parentGui

local FOVFrame = Instance.new("Frame")
FOVFrame.BackgroundTransparency = 1
FOVFrame.AnchorPoint = Vector2.new(0.5, 0.5)
FOVFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
FOVFrame.Size = UDim2.new(0, Settings.FOVRadius * 2, 0, Settings.FOVRadius * 2)
FOVFrame.Visible = Settings.ShowFOV
FOVFrame.ZIndex = 5

Instance.new("UICorner", FOVFrame).CornerRadius = UDim.new(0.5, 0)
local FOVStroke = Instance.new("UIStroke")
FOVStroke.Color = COLORS.accent
FOVStroke.Thickness = 1.5
FOVStroke.Parent = FOVFrame

-- Crosshair center tick
for _, dir in ipairs({"H", "V"}) do
    local cross = Instance.new("Frame")
    cross.BackgroundColor3 = COLORS.accent
    cross.BackgroundTransparency = 0.3
    cross.BorderSizePixel = 0
    cross.AnchorPoint = Vector2.new(0.5, 0.5)
    cross.ZIndex = 6
    if dir == "H" then
        cross.Size = UDim2.new(0, 10, 0, 1.5)
        cross.Position = UDim2.new(0.5, 0, 0.5, 0)
    else
        cross.Size = UDim2.new(0, 1.5, 0, 10)
        cross.Position = UDim2.new(0.5, 0, 0.5, 0)
    end
    cross.Parent = FOVFrame
end
FOVFrame.Parent = FOVGui

-- ==========================================
-- 🚀 FPS BOOST LOGIC
-- ==========================================
function toggleFPSBoost(state)
    local Terrain = workspace:FindFirstChildOfClass("Terrain")
    if state then
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 9e9
        if Terrain then
            Terrain.WaterWaveSize = 0; Terrain.WaterWaveSpeed = 0
            Terrain.WaterReflectance = 0; Terrain.WaterTransparency = 0
        end
        for _, v in pairs(workspace:GetDescendants()) do
            pcall(function()
                if v:IsA("BasePart") and not v:IsA("Terrain") then
                    v.Material = Enum.Material.SmoothPlastic; v.Reflectance = 0
                elseif v:IsA("Decal") or v:IsA("Texture") then
                    v.Transparency = 1
                elseif v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles") then
                    v.Enabled = false
                end
            end)
        end
    else
        Lighting.GlobalShadows = true; Lighting.FogEnd = 100000
    end
end

-- ==========================================
-- ♾️ MOVEMENT HOOKS
-- ==========================================
UserInputService.JumpRequest:Connect(function()
    if Settings.InfiniteJump and player.Character then
        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

player.CharacterAdded:Connect(function(char)
    if Settings.FastRespawn then
        task.spawn(function()
            local humanoid = char:WaitForChild("Humanoid", 3)
            if humanoid then
                humanoid.Died:Connect(function()
                    if Settings.FastRespawn then task.wait(0.1); player:LoadCharacter() end
                end)
            end
        end)
    end
end)

RunService.Stepped:Connect(function()
    if not Settings.Noclip then return end
    pcall(function()
        local char = player.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end
    end)
end)

-- WalkSpeed Loop
RunService.Heartbeat:Connect(function()
    if Settings.SpeedBoost and player.Character then
        local hum = player.Character:FindFirstChildOfClass("Humanoid")
        if hum and hum.WalkSpeed ~= Settings.WalkSpeedValue then
            hum.WalkSpeed = Settings.WalkSpeedValue
        end
    end
end)

-- ==========================================
-- 💥 HITBOX EXPANDER BACKGROUND WORKER
-- Invisible transparent hit surface — NO PINK SCREEN FLOOD
-- ==========================================
task.spawn(function()
    while task.wait(0.1) do
        if not Settings.HitboxExpander then continue end
        local targets = getAllTargets()
        for _, t in ipairs(targets) do
            if t.isEnemy or not Settings.TeamCheck then
                pcall(function()
                    -- Target Root & Head
                    for _, part in ipairs({t.root, t.head}) do
                        if part and part:IsA("BasePart") then
                            if not part:FindFirstChild("OrigSize") then
                                local ov = Instance.new("Vector3Value")
                                ov.Name = "OrigSize"
                                ov.Value = part.Size
                                ov.Parent = part
                            end
                            local s = Settings.HitboxSize
                            part.Size = Vector3.new(s, s, s)
                            part.Transparency = 1 -- 100% Invisible hit volume!
                            part.CanCollide = false
                        end
                    end
                end)
            end
        end
    end
end)

-- ==========================================
-- 🎨 ESP COMPONENT FACTORY
-- ==========================================
local function getOrCreateESP(id)
    if not tracers[id] then
        -- Tracer Line
        local line = Instance.new("Frame")
        line.Name = id .. "_Tracer"
        line.AnchorPoint = Vector2.new(0.5, 0.5)
        line.BackgroundColor3 = COLORS.espEnemy
        line.BorderSizePixel = 0
        line.Visible = false
        line.ZIndex = 5
        line.Parent = tracerGui
        tracers[id] = line

        -- Name/Distance Label
        local label = Instance.new("TextLabel")
        label.Name = id .. "_Label"
        label.Size = UDim2.new(0, 140, 0, 32)
        label.AnchorPoint = Vector2.new(0.5, 1)
        label.BackgroundColor3 = COLORS.glassDeep
        label.BackgroundTransparency = 0.25
        label.BorderSizePixel = 0
        label.TextColor3 = COLORS.text
        label.TextSize = 10
        label.Font = Enum.Font.GothamBold
        label.Visible = false
        label.ZIndex = 7
        label.Parent = tracerGui
        Instance.new("UICorner", label).CornerRadius = UDim.new(0, 6)
        local lStroke = Instance.new("UIStroke")
        lStroke.Color = COLORS.espEnemy; lStroke.Thickness = 1; lStroke.Parent = label
        espLabels[id] = label

        -- Box Frame
        local box = Instance.new("Frame")
        box.Name = id .. "_Box"
        box.BackgroundTransparency = 1
        box.BorderSizePixel = 0
        box.Visible = false
        box.ZIndex = 6
        box.Parent = tracerGui
        local bStroke = Instance.new("UIStroke")
        bStroke.Color = COLORS.espEnemy; bStroke.Thickness = 1.5; bStroke.Parent = box
        espBoxes[id] = box
    end

    return tracers[id], espLabels[id], espBoxes[id]
end

-- ==========================================
-- 🎯 MAIN COMBAT & ESP RENDER LOOP
-- ==========================================
local mouseDown = false
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then mouseDown = true end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then mouseDown = false end
end)

RunService.RenderStepped:Connect(function()
    -- 1. FOV Circle Resizing & Color
    if FOVFrame and FOVFrame.Parent then
        FOVFrame.Visible = Settings.ShowFOV
        local fovDiam = Settings.FOVRadius * 2
        if FOVFrame.Size.X.Offset ~= fovDiam then
            FOVFrame.Size = UDim2.new(0, fovDiam, 0, fovDiam)
        end
    end

    -- 2. Target Acquisition
    local target = getClosestEnemyToCrosshair()
    currentLockedTarget = target

    -- Dynamic FOV Color
    if FOVStroke then
        FOVStroke.Color = target and COLORS.espLocked or COLORS.accent
    end

    -- 3. Aimbot Logic
    if Settings.AimbotEnabled and target then
        local aimPart = (Settings.AimPart == "Head") and target.head or target.root
        if aimPart then
            local targetCF = CFrame.new(Camera.CFrame.Position, aimPart.Position)
            local smooth = math.clamp(Settings.AimbotSmoothness, 0.05, 1.0)
            Camera.CFrame = Camera.CFrame:Lerp(targetCF, smooth)
        end
    end

    -- 4. Silent Aim Logic (Redirect on click)
    if Settings.SilentAim and target and mouseDown then
        local aimPart = (Settings.AimPart == "Head") and target.head or target.root
        if aimPart then
            local savedCF = Camera.CFrame
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, aimPart.Position)
            task.defer(function() Camera.CFrame = savedCF end)
        end
    end

    -- 5. TriggerBot Logic (Instant snap-shot when crosshair passes enemy)
    if Settings.TriggerBot and not triggerBotDebounce then
        local centerRay = Camera:ViewportPointToRay(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        local rayParams = RaycastParams.new()
        rayParams.FilterType = Enum.RaycastFilterType.Exclude
        local filter = { Camera }
        if player.Character then table.insert(filter, player.Character) end
        rayParams.FilterDescendantsInstances = filter

        local res = workspace:Raycast(centerRay.Origin, centerRay.Direction * 1500, rayParams)
        if res and res.Instance then
            for _, t in ipairs(getAllTargets()) do
                if (t.isEnemy or not Settings.TeamCheck) and (res.Instance:IsDescendantOf(t.model)) then
                    triggerBotDebounce = true
                    task.spawn(function()
                        if typeof(mouse1click) == "function" then
                            mouse1click()
                        elseif typeof(mouse1press) == "function" and typeof(mouse1release) == "function" then
                            mouse1press(); task.wait(0.02); mouse1release()
                        end
                        task.wait(0.12)
                        triggerBotDebounce = false
                    end)
                    break
                end
            end
        end
    end

    -- 6. ESP Rendering Engine
    if not Settings.ESPEnabled then
        for _, l in pairs(tracers) do l.Visible = false end
        for _, lb in pairs(espLabels) do lb.Visible = false end
        for _, b in pairs(espBoxes) do b.Visible = false end
        return
    end

    local myRoot = player.Character and (player.Character:FindFirstChild("HumanoidRootPart") or player.Character.PrimaryPart)
    local screenBottom = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
    local allTargets = getAllTargets()
    local activeIds = {}

    for _, t in ipairs(allTargets) do
        activeIds[t.id] = true
        local line, label, box = getOrCreateESP(t.id)

        -- Team Filtering
        if not t.isEnemy and Settings.TeamCheck then
            line.Visible = false; label.Visible = false; box.Visible = false
            continue
        end

        local rootPart = t.root
        local headPart = t.head
        local humanoid = t.humanoid

        if rootPart and humanoid and humanoid.Health > 0 then
            local dist = myRoot and (rootPart.Position - myRoot.Position).Magnitude or 0
            if dist > Settings.MaxDistance then
                line.Visible = false; label.Visible = false; box.Visible = false
                continue
            end

            local vector, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
            if onScreen and vector.Z > 0 then
                -- Determine Color
                local isLocked = (target and target.id == t.id)
                local isVis = Settings.WallCheck and isTargetVisible(headPart)
                local espCol = isLocked and COLORS.espLocked or (isVis and COLORS.espEnemyVis or COLORS.espEnemyWall)
                if not t.isEnemy then espCol = COLORS.espFriend end

                -- Tracers
                if Settings.Tracers then
                    local target2D = Vector2.new(vector.X, vector.Y)
                    local dist2D = (target2D - screenBottom).Magnitude
                    local center2D = (screenBottom + target2D) / 2
                    local angle = math.deg(math.atan2(target2D.Y - screenBottom.Y, target2D.X - screenBottom.X))

                    line.Position = UDim2.new(0, center2D.X, 0, center2D.Y)
                    line.Size = UDim2.new(0, dist2D, 0, isLocked and 2.5 or 1.2)
                    line.Rotation = angle
                    line.BackgroundColor3 = espCol
                    line.Visible = true
                else
                    line.Visible = false
                end

                -- Box ESP
                local headVec, headOnScreen = headPart and Camera:WorldToViewportPoint(headPart.Position + Vector3.new(0, 0.8, 0))
                local footVec, footOnScreen = Camera:WorldToViewportPoint(rootPart.Position - Vector3.new(0, 2.5, 0))

                if Settings.BoxESP and headOnScreen and footOnScreen then
                    local boxH = math.abs(footVec.Y - headVec.Y)
                    local boxW = math.clamp(boxH * 0.65, 12, 200)
                    box.Position = UDim2.new(0, vector.X - boxW / 2, 0, headVec.Y)
                    box.Size = UDim2.new(0, boxW, 0, boxH)
                    local bStroke = box:FindFirstChildOfClass("UIStroke")
                    if bStroke then bStroke.Color = espCol end
                    box.Visible = true
                else
                    box.Visible = false
                end

                -- Label with HP and Distance
                if Settings.ShowNames or Settings.ShowDistance or Settings.ShowHealth then
                    local hpPct = math.floor((humanoid.Health / humanoid.MaxHealth) * 100)
                    local lockTag = isLocked and " 🎯" or ""
                    local nameStr = Settings.ShowNames and (t.displayName .. lockTag) or ""
                    local infoStr = string.format("%d studs  HP:%d%%", math.floor(dist), hpPct)
                    
                    label.Position = UDim2.new(0, vector.X, 0, (headVec and headVec.Y or vector.Y) - 34)
                    label.Text = nameStr .. "\n" .. infoStr
                    label.TextColor3 = espCol
                    local lStroke = label:FindFirstChildOfClass("UIStroke")
                    if lStroke then lStroke.Color = espCol end
                    label.Visible = true
                else
                    label.Visible = false
                end
            else
                line.Visible = false; label.Visible = false; box.Visible = false
            end
        else
            line.Visible = false; label.Visible = false; box.Visible = false
        end
    end

    -- Cleanup stale visual components
    for id, _ in pairs(tracers) do
        if not activeIds[id] then
            if tracers[id] then tracers[id]:Destroy(); tracers[id] = nil end
            if espLabels[id] then espLabels[id]:Destroy(); espLabels[id] = nil end
            if espBoxes[id] then espBoxes[id]:Destroy(); espBoxes[id] = nil end
        end
    end
end)

notify("PayomboyZ Hub", "โหลดสำเร็จ! Sniper Arena v3 (Pro FPS Edition) พร้อมใช้งาน 🎯", 4)
