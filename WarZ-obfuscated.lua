-- ======================================================================================
-- [[ PayomboyZ BloxZ / WarZ NAPHUB (ล่าซอมบี้ไปกับพยอมบอย) ]]
-- UI Architecture: Obsidian Glassmorphic 2.0 (Top Tabs Navigation Pill Concept)
-- Engine Source: Inlined PayomboyUIz (Self-Contained / 100% Guaranteed Execution)
-- Integrated Combat & Automation: Full GC No-Recoil, Instant Reactive Auto-Heal,
--           Center-Lock Aimbot with FOV, Full Chams & Box ESP with Health Bars,
--           UUID Auto-Loot Engine, SafeZone Stash Sync, Flight & WalkSpeed Controls.
-- Bilingual Support: ภาษาไทย (TH) / English (EN)
-- ======================================================================================

local cloneref = cloneref or function(i) return i end
local CoreGui = cloneref(game:GetService("CoreGui"))
local Players = cloneref(game:GetService("Players"))
local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local UserInputService = cloneref(game:GetService("UserInputService"))
local TweenService = cloneref(game:GetService("TweenService"))
local RunService = cloneref(game:GetService("RunService"))
local Stats = cloneref(game:GetService("Stats"))
local SoundService = cloneref(game:GetService("SoundService"))
local HttpService = cloneref(game:GetService("HttpService"))
local TeleportService = cloneref(game:GetService("TeleportService"))
local Camera = workspace.CurrentCamera
local player = LocalPlayer

-- ====================================================================
--  LIFECYCLE MANAGEMENT & ANTI-DUPLICATION
-- ====================================================================
if _G.PayomboyZBloxZCleanup then
    pcall(_G.PayomboyZBloxZCleanup)
    task.wait(0.1)
end

_G.PayomboyZBloxZConns = {}
local RUN = {}
_G.PayomboyZBloxZRun = RUN

local function bind(signal, fn)
    local c = signal:Connect(fn)
    table.insert(_G.PayomboyZBloxZConns, c)
    return c
end

local function getSafeGuiContainer()
    if gethui then
        local ok, h = pcall(gethui)
        if ok and typeof(h) == "Instance" then return h end
    end
    local ok = pcall(function()
        local t = Instance.new("Folder"); t.Parent = CoreGui; t:Destroy()
    end)
    if ok then return CoreGui end
    return LocalPlayer:WaitForChild("PlayerGui", 10)
end

local GuiParent = getSafeGuiContainer()

local function safeDestroyGui(name)
    pcall(function()
        local parents = { CoreGui, LocalPlayer:FindFirstChild("PlayerGui") }
        if gethui then pcall(function() table.insert(parents, gethui()) end) end
        for _, p in ipairs(parents) do
            if p then
                for _, c in ipairs(p:GetChildren()) do
                    if c.Name == name or c.Name:find(name) then pcall(function() c:Destroy() end) end
                end
            end
        end
    end)
end
 
safeDestroyGui("PayomboyZ_HUD")
safeDestroyGui("PayomboyZ_LootESP")
safeDestroyGui("PayomboyZ_Tracers")
safeDestroyGui("PayomboyZ_FOV")
safeDestroyGui("PayomboyZ_NotifHolder")
safeDestroyGui("PayomboyZ_MobileControls")

-- ====================================================================
--  BILINGUAL TRANSLATION DICTIONARY (ภาษาไทย TH / ENGLISH EN)
-- ====================================================================
local currentLang = "TH"

local TRANSLATIONS = {
    TH = {
        script_title = "PayomboyZ BloxZ (ล่าซอมบี้ไปกับพยอมบอย)",
        tab_combat = "⚔️ ต่อสู้",
        tab_visuals = "👁️ มองทะลุ",
        tab_farm = "🎣 ฟาร์ม & ตกปลา",
        tab_move = "⚡ เคลื่อนที่",
        tab_security = "🛡️ คลัง & ป้องกัน BAC",
        tab_settings = "⚙️ ตั้งค่า & Webhook",
        
        -- Section 1: Combat
        sec_combat = "ฟังก์ชันการต่อสู้ & ป้องกันตัว (Combat & Defense)",
        aimbot_title = "Aimbot Lock",
        aimbot_desc = "ล็อคเป้าอัตโนมัติ (คลิกขวา, ล็อคออโต้ หรือกดปุ่ม AIM)",
        aimbot_wall = "Wall Check (เช็คสิ่งกีดขวาง - ปิดเพื่อล็อคทะลุกำแพง/กระจก)",
        aimbot_always = "Always Lock (ล็อคตลอดเวลาเมื่อศัตรูอยู่ในวง FOV)",
        aimbot_mobile_btn = "แสดงปุ่ม AIM ลอยบนหน้าจอ (สำหรับมือถือ)",
        aimbot_fov = "ขนาดวงกลมเป้า FOV (Studs)",
        aimbot_show_fov = "แสดงวงกลม FOV บนหน้าจอ",
        aimbot_dist = "ระยะล็อคเป้าสูงสุด (Studs)",
        aimbot_team = "Team Check (ไม่ล็อคเพื่อน)",
        norecoil_title = "No Recoil & Spread",
        norecoil_desc = "ลดแรงดีดปืนและลดกระสุนกระจาย 100% (Direct Memory Hook)",
        norecoil_restore = "คืนค่าแรงดีดปืนเดิม",
        autoheal_title = "Auto Heal",
        autoheal_desc = "ปั๊มยาออโต้เมื่อเลือดต่ำกว่าเกณฑ์ทันที",
        autoheal_item = "เลือกไอเทมยาที่ใช้ปั๊ม",
        autoheal_thresh = "เลือดต่ำกว่า (%) เริ่มปั๊มยา",
        autoheal_cd = "คูลดาวน์ปั๊มยา (วินาที)",
        fpsboost_title = "FPS Boost",
        fpsboost_desc = "ลดกราฟิกเพิ่มความลื่นไหลสูงสุด (ปลดล็อค FPS)",
        
        -- Section 2: Visuals
        sec_visuals = "ระบบเรดาร์ & มองทะลุ (ESP & Chams)",
        chams_title = "Highlight ESP / Chams",
        chams_desc = "มองทะลุกำแพงแบบเรืองแสงสี",
        chams_wall = "มองทะลุกำแพง (Through Walls)",
        chams_outline = "แสดงเส้นขอบเรืองแสง (Outline)",
        chams_trans = "ความโปร่งใสของสี Chams (%)",
        chams_color_cycle = "🎨 เปลี่ยนสี Chams (คลิก)",
        boxesp_title = "Box ESP",
        boxesp_desc = "กรอบสี่เหลี่ยมรอบตัวพร้อมหลอดเลือด HP",
        tracers_title = "ESP Tracers",
        tracers_desc = "วาดเส้นชี้ตำแหน่งศัตรูพร้อมระยะ",
        tracers_dist = "ระยะวาดเส้นสูงสุด (Studs)",
        lootesp_title = "Loot ESP",
        lootesp_desc = "มองเห็นกล่องของและอาวุธดรอปบนพื้น",
        lootesp_dist = "ระยะตรวจจับกล่องของ (Studs)",
        
        -- Section 3: Farm & Fishing
        sec_farm = "ระบบตกปลาและเก็บของอัตโนมัติ (Fishing & Farming)",
        autofish_title = "Auto Fish",
        autofish_desc = "เดินไปริมบ่อ เหวี่ยงเบ็ด และตวัด 100% อัตโนมัติ",
        fish_perfect = "Perfect Reel (ตวัดเข้าแถบเขียว 100%)",
        fish_autowalk = "Auto Walk to Pond (เดินไปริมบ่อน้ำอัตโนมัติ)",
        fish_safezone = "SafeZone Priority (เน้นตกในเซฟโซน ปลอดภัย 100%)",
        fish_delay = "หน่วงเวลาเหวี่ยงรอบใหม่ (วินาที)",
        fish_status_title = "สถานะระบบตกปลา",
        fish_status_ready = "พร้อมใช้งาน (ปิดอยู่)",
        fish_count_title = "จำนวนปลาที่ตกได้ในเซสชันนี้",
        
        autoloot_title = "Auto Loot (ดูดของรอบตัว)",
        autoloot_desc = "เก็บของดรอปใกล้ตัวทันที (UUID Protocol)",
        autoloot_range = "ระยะเก็บของ (Studs)",
        autoloot_hold = "เวลากดค้างเก็บของ (วินาที)",
        autoloot_delay = "หน่วงเวลาระหว่างรอบเก็บ (วินาที)",
        
        autofarm_title = "Auto Farm Loot Runner",
        autofarm_desc = "เดินเก็บของมีค่าทั่วแมพอัตโนมัติแบบหลบ BAC",
        autofarm_filter = "ตัวกรองประเภทของที่ต้องการฟาร์ม",
        autofarm_dist = "ระยะค้นหากล่องของสูงสุด (Studs)",
        autofarm_speed = "ความเร็วเดินฟาร์ม (Anti-BAC Clamped)",
        autofarm_avoid = "หยุดเดินและระวังตัวเมื่อศัตรูเข้าใกล้ (60 studs)",
        autofarm_status = "สถานะการเดินฟาร์ม",
        
        -- Section 4: Movement
        sec_move = "การเคลื่อนที่ & ฟิสิกส์ (Movement & Physics)",
        infstamina_title = "Infinite Stamina",
        infstamina_desc = "วิ่งเร็วไม่มีวันเหนื่อย (สตามิน่าไม่ลด)",
        bhop_title = "Auto BunnyHop",
        bhop_desc = "กระโดดต่อเนื่องรักษาความเร็วอัตโนมัติ",
        walkspeed_title = "WalkSpeed Modifier",
        walkspeed_desc = "ปรับแต่งความเร็วเดินของตัวละคร",
        walkspeed_val = "ค่าความเร็วเดิน (Studs/s)",
        fly_title = "Fly Hack",
        fly_desc = "บินลอยตัวบนอากาศ (WASD/Space/Ctrl)",
        fly_speed = "ความเร็วบิน (Fly Speed)",
        noclip_title = "Noclip Through Walls",
        noclip_desc = "เดินทะลุสิ่งกีดขวางและประตูกลั้น",
        
        -- Section 5: Security & Anti-BAC
        sec_security = "ระบบความปลอดภัย, คลังเซฟโซน & Anti-BAC Guard",
        antibac_guard_title = "Anti-BAC Velocity Guard",
        antibac_guard_desc = "ระบบบล็อกความเร็วเกินและกันโดน Kick จากเซิร์ฟเวอร์",
        storage_title = "ระบบจัดการคลัง (SafeZone Stash)",
        storage_desc = "ฝากของทั้งหมดลงคลัง และรวมแม็กกาซีนอัตโนมัติ",
        btn_deposit_all = "📦 ฝากของมีค่าทั้งหมดลงคลัง SafeZone",
        btn_combine_mags = "🔄 รวมซองกระสุนปืน (Combine Mags)",
        antivoid_title = "Anti-Void Protection",
        antivoid_desc = "ป้องกันการตกแมพหรือกระเด็นหลุดโลก",
        btn_claim_gifts = "🎁 รับของขวัญฟรี (Community Gift & Event)",
        
        -- Section 6: Settings & Webhook
        sec_settings = "การตั้งค่าระบบ, ภาษา & Server Control",
        lang_title = "ภาษา / Language (TH / EN)",
        lang_desc = "สลับภาษาระหว่างภาษาไทยและภาษาอังกฤษ",
        btn_toggle_lang = "🌐 สลับภาษา (Switch to English)",
        webhook_title = "Discord Webhook Notification",
        webhook_desc = "ส่งสถิติการฟาร์มและปลาที่ตกได้เข้า Discord",
        webhook_url_label = "Discord Webhook URL",
        btn_test_webhook = "📡 ส่งข้อความทดสอบ Webhook",
    },
    EN = {
        script_title = "PayomboyZ BloxZ (Hunt Zombies with Payomboy)",
        tab_combat = "⚔️ Combat",
        tab_visuals = "👁️ Visuals",
        tab_farm = "🎣 Farm & Fish",
        tab_move = "⚡ Move",
        tab_security = "🛡️ Stash & BAC",
        tab_settings = "⚙️ Settings",
        
        -- Section 1: Combat
        sec_combat = "Combat & Defense Functions",
        aimbot_title = "Aimbot Lock",
        aimbot_desc = "Auto aimbot lock on target (Right click, Auto, or AIM button)",
        aimbot_wall = "Wall Check (Ignore walls when disabled to lock through windows)",
        aimbot_always = "Always Lock (Automatically lock onto target in FOV)",
        aimbot_mobile_btn = "Show Floating AIM Button (For Mobile)",
        aimbot_fov = "FOV Circle Radius (Studs)",
        aimbot_show_fov = "Show FOV Circle on Screen",
        aimbot_dist = "Max Target Distance (Studs)",
        aimbot_team = "Team Check (Ignore Teammates)",
        norecoil_title = "No Recoil & Spread",
        norecoil_desc = "Eliminate weapon recoil & spread 100% (Direct Memory Hook)",
        norecoil_restore = "Restore original recoil",
        autoheal_title = "Auto Heal",
        autoheal_desc = "Instant reactive heal when HP drops below threshold",
        autoheal_item = "Select Healing Item",
        autoheal_thresh = "Health Threshold (%) to Trigger Heal",
        autoheal_cd = "Heal Cooldown (Seconds)",
        fpsboost_title = "FPS Boost",
        fpsboost_desc = "Lower graphics for maximum smoothness & unlock FPS",
        
        -- Section 2: Visuals
        sec_visuals = "Radar & Visual Systems (ESP & Chams)",
        chams_title = "Highlight ESP / Chams",
        chams_desc = "Glow player chams through walls",
        chams_wall = "See Through Walls",
        chams_outline = "Show Glow Outline",
        chams_trans = "Chams Fill Transparency (%)",
        chams_color_cycle = "🎨 Change Chams Color (Click)",
        boxesp_title = "Box ESP",
        boxesp_desc = "2D Bounding box with dynamic health bar",
        tracers_title = "ESP Tracers",
        tracers_desc = "Draw lines pointing to enemies with distance",
        tracers_dist = "Max Tracer Distance (Studs)",
        lootesp_title = "Loot ESP",
        lootesp_desc = "Show loot boxes & dropped weapons",
        lootesp_dist = "Max Loot ESP Distance (Studs)",
        
        -- Section 3: Farm & Fishing
        sec_farm = "Auto Fishing & Farming Automation Suite",
        autofish_title = "Auto Fish",
        autofish_desc = "Walk to pond, cast rod, and 100% perfect reel",
        fish_perfect = "Perfect Reel (100% Green Bar Catch)",
        fish_autowalk = "Auto Walk to Pond (Walks to water automatically)",
        fish_safezone = "SafeZone Priority (Fish in SafeZone with 0 risk)",
        fish_delay = "Re-cast Delay Interval (Seconds)",
        fish_status_title = "Fishing System Status",
        fish_status_ready = "Ready (Disabled)",
        fish_count_title = "Total Fish Caught This Session",
        
        autoloot_title = "Auto Loot (Nearby Aura)",
        autoloot_desc = "Instantly pick up nearby loot (UUID Protocol)",
        autoloot_range = "Pickup Range (Studs)",
        autoloot_hold = "Loot Hold Duration (Seconds)",
        autoloot_delay = "Scan Interval Delay (Seconds)",
        
        autofarm_title = "Auto Farm Loot Runner",
        autofarm_desc = "Automatically route to loot across the map (BAC Safe)",
        autofarm_filter = "Loot Classification Filter",
        autofarm_dist = "Max Search Distance (Studs)",
        autofarm_speed = "Loot Runner Speed (Anti-BAC Clamped)",
        autofarm_avoid = "Halt & Guard when enemy is nearby (60 studs)",
        autofarm_status = "Farm Runner Status",
        
        -- Section 4: Movement
        sec_move = "Movement & Physics Controls",
        infstamina_title = "Infinite Stamina",
        infstamina_desc = "Sprint without stamina exhaustion",
        bhop_title = "Auto BunnyHop",
        bhop_desc = "Continuous automated jumping",
        walkspeed_title = "WalkSpeed Modifier",
        walkspeed_desc = "Custom character walking speed",
        walkspeed_val = "WalkSpeed Value (Studs/s)",
        fly_title = "Fly Hack",
        fly_desc = "Fly through air (WASD/Space/Ctrl)",
        fly_speed = "Fly Velocity",
        noclip_title = "Noclip Through Walls",
        noclip_desc = "Walk through obstacles and doors",
        
        -- Section 5: Security & Anti-BAC
        sec_security = "Security, SafeZone Stash & Anti-BAC Guard",
        antibac_guard_title = "Anti-BAC Velocity Guard",
        antibac_guard_desc = "Enforce velocity limits to prevent server kicks",
        storage_title = "SafeZone Stash Automation",
        storage_desc = "Auto deposit valuables and combine magazines",
        btn_deposit_all = "📦 Deposit All Items to SafeZone Stash",
        btn_combine_mags = "🔄 Combine Ammo Magazines",
        antivoid_title = "Anti-Void Protection",
        antivoid_desc = "Prevent falling through the map",
        btn_claim_gifts = "🎁 Claim Free Community Gifts",
        
        -- Section 6: Settings & Webhook
        sec_settings = "System Settings, Language & Server Control",
        lang_title = "Language / ภาษา (TH / EN)",
        lang_desc = "Switch between Thai and English languages",
        btn_toggle_lang = "🌐 Switch to Thai Language",
        webhook_title = "Discord Webhook Notification",
        webhook_desc = "Forward game stats and loot logs to Discord",
        webhook_url_label = "Discord Webhook URL",
        btn_test_webhook = "📡 Send Test Webhook Message",
    }
}

local function T(key)
    local dict = TRANSLATIONS[currentLang] or TRANSLATIONS.TH
    return dict[key] or key
end

-- ====================================================================
--  SETTINGS CONFIGURATION (PRECISION TUNED)
-- ====================================================================
local Settings = {
    -- Combat
    AimbotEnabled = false,
    AimbotWallCheck = false,
    AimbotAlways = false,
    MobileAimButton = true,
    ShowFOV = false,
    FOVRadius = 100,
    MaxDistance = 1000,
    TeamCheck = true,
    NoRecoil = false,
    AutoHeal = false,
    AutoHealItem = "BandagesDX",
    AutoHealThreshold = 0.74,
    AutoHealCooldown = 0.05,
    FPSBoost = false,
    
    -- Visuals
    ESPEnabled = false,
    HighlightESP = true,
    ChamsOutline = true,
    ChamsThroughWalls = true,
    ChamsFillTransparency = 0.6,
    ChamsColor = Color3.fromRGB(255, 45, 85),
    ChamsOutlineColor = Color3.fromRGB(255, 45, 85),
    BoxESP = true,
    Tracers = false,
    TracerDistance = 1000,
    LootESP = true,
    LootMaxDistance = 350,
    
    -- Farm & Fishing Automation Suite
    AutoFish = false,
    FishPerfectReel = true,
    FishAutoWalk = true,
    FishSafeZonePriority = true,
    FishCastDelay = 1.0,
    TotalFishCaught = 0,
    
    AutoLoot = false,
    AutoLootRange = 35,          -- Server range (default 35 studs from working script)
    AutoLootHold = 0.08,         -- Optimized fast hold (Anti-freeze)
    AutoLootDelay = 0.15,
    
    AutoFarmLoot = false,
    FarmLootFilter = "ของมีค่าทั้งหมด (ปืน เกราะ ยา แม็ก)",
    FarmLootDistance = 120,
    FarmLootSpeed = 18.5,        -- Safe sprint velocity (Anti-BAC: under 22 studs/s)
    FarmStopOnEnemy = true,
    
    -- Movement & BAC Guard
    InfiniteStamina = true,
    BunnyHop = false,
    WalkSpeedEnabled = false,
    WalkSpeedValue = 32,
    Fly = false,
    FlySpeed = 60,
    MobileFlyControls = true,
    Noclip = false,
    AntiBACGuard = true,
    AntiVoid = true,
    
    -- Webhook & Config
    WebhookEnabled = false,
    WebhookURL = "",
}

-- ====================================================================
--  COLORS & GUI HOLDERS
-- ====================================================================
local COLORS = {
    primary = Color3.fromRGB(220, 38, 58),
    cyan = Color3.fromRGB(0, 210, 255),
    success = Color3.fromRGB(46, 224, 140),
    warning = Color3.fromRGB(255, 185, 70),
    danger = Color3.fromRGB(255, 60, 60),
    textMuted = Color3.fromRGB(155, 156, 166),
}

-- Tracers / Boxes GUI container
local tracerGui = Instance.new("ScreenGui")
tracerGui.Name = "PayomboyZ_Tracers"
tracerGui.ResetOnSpawn = false
tracerGui.IgnoreGuiInset = true
tracerGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
tracerGui.Parent = GuiParent

-- FOV Circle GUI container
local FOVGui = Instance.new("ScreenGui")
FOVGui.Name = "PayomboyZ_FOV"
FOVGui.ResetOnSpawn = false
FOVGui.IgnoreGuiInset = true
FOVGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
FOVGui.Parent = GuiParent

local FOVFrame = Instance.new("Frame")
FOVFrame.BackgroundTransparency = 1
FOVFrame.AnchorPoint = Vector2.new(0.5, 0.5)
FOVFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
FOVFrame.Size = UDim2.new(0, Settings.FOVRadius * 2, 0, Settings.FOVRadius * 2)
FOVFrame.Visible = Settings.ShowFOV
FOVFrame.Parent = FOVGui

local FOVCorner = Instance.new("UICorner")
FOVCorner.CornerRadius = UDim.new(0.5, 0)
FOVCorner.Parent = FOVFrame

local FOVStroke = Instance.new("UIStroke")
FOVStroke.Color = COLORS.cyan
FOVStroke.Thickness = 1.5
FOVStroke.Parent = FOVFrame

-- Mobile Touch Controls GUI container
local mobileGui = Instance.new("ScreenGui")
mobileGui.Name = "PayomboyZ_MobileControls"
mobileGui.ResetOnSpawn = false
mobileGui.IgnoreGuiInset = true
mobileGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
mobileGui.Parent = GuiParent

local aimbotMobileLock = false
local aimbotTouchActive = false
local flyMobileY = 0

-- Mobile On-Screen Aim Lock Button
local aimMobileBtn = Instance.new("TextButton")
aimMobileBtn.Name = "MobileAimButton"
aimMobileBtn.Size = UDim2.fromOffset(56, 56)
aimMobileBtn.Position = UDim2.new(1, -75, 0.5, -30)
aimMobileBtn.BackgroundColor3 = Color3.fromRGB(25, 26, 32)
aimMobileBtn.BackgroundTransparency = 0.2
aimMobileBtn.Text = "🎯\nAIM"
aimMobileBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
aimMobileBtn.TextSize = 12
aimMobileBtn.FontFace = Font.fromName("Montserrat", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
aimMobileBtn.Visible = false
aimMobileBtn.Active = true
aimMobileBtn.Parent = mobileGui

local aimCorner = Instance.new("UICorner", aimMobileBtn)
aimCorner.CornerRadius = UDim.new(1, 0)
local aimStroke = Instance.new("UIStroke", aimMobileBtn)
aimStroke.Thickness = 2
aimStroke.Color = Color3.fromRGB(220, 38, 58)

local function updateAimMobileUI()
    if aimMobileBtn then
        aimStroke.Color = aimbotMobileLock and Color3.fromRGB(46, 224, 140) or Color3.fromRGB(220, 38, 58)
        aimMobileBtn.TextColor3 = aimbotMobileLock and Color3.fromRGB(46, 224, 140) or Color3.fromRGB(255, 255, 255)
    end
end

local function toggleMobileAim()
    aimbotMobileLock = not aimbotMobileLock
    updateAimMobileUI()
end

aimMobileBtn.MouseButton1Click:Connect(toggleMobileAim)
if aimMobileBtn.Activated then aimMobileBtn.Activated:Connect(toggleMobileAim) end

-- Mobile Aim Dragging
local aimDragging, aimDragStart, aimStartPos = false, nil, nil
aimMobileBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        aimDragging = true
        aimDragStart = input.Position
        aimStartPos = aimMobileBtn.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then aimDragging = false end
        end)
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if aimDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - aimDragStart
        aimMobileBtn.Position = UDim2.new(aimStartPos.X.Scale, aimStartPos.X.Offset + delta.X, aimStartPos.Y.Scale, aimStartPos.Y.Offset + delta.Y)
    end
end)

-- Mobile Fly Up / Down buttons
local flyMobileHolder = Instance.new("Frame")
flyMobileHolder.Name = "FlyMobileHolder"
flyMobileHolder.Size = UDim2.fromOffset(56, 120)
flyMobileHolder.Position = UDim2.new(1, -75, 0.5, 40)
flyMobileHolder.BackgroundTransparency = 1
flyMobileHolder.Visible = false
flyMobileHolder.Parent = mobileGui

local flyUpBtn = Instance.new("TextButton", flyMobileHolder)
flyUpBtn.Name = "FlyUp"
flyUpBtn.Size = UDim2.fromOffset(50, 50)
flyUpBtn.Position = UDim2.new(0, 3, 0, 0)
flyUpBtn.BackgroundColor3 = Color3.fromRGB(25, 26, 32)
flyUpBtn.BackgroundTransparency = 0.2
flyUpBtn.Text = "▲\nUP"
flyUpBtn.TextColor3 = Color3.fromRGB(0, 210, 255)
flyUpBtn.TextSize = 12
flyUpBtn.FontFace = Font.fromName("Montserrat", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
Instance.new("UICorner", flyUpBtn).CornerRadius = UDim.new(1, 0)
local flyUpStroke = Instance.new("UIStroke", flyUpBtn)
flyUpStroke.Color = Color3.fromRGB(0, 210, 255)
flyUpStroke.Thickness = 1.5

local flyDownBtn = Instance.new("TextButton", flyMobileHolder)
flyDownBtn.Name = "FlyDown"
flyDownBtn.Size = UDim2.fromOffset(50, 50)
flyDownBtn.Position = UDim2.new(0, 3, 0, 60)
flyDownBtn.BackgroundColor3 = Color3.fromRGB(25, 26, 32)
flyDownBtn.BackgroundTransparency = 0.2
flyDownBtn.Text = "▼\nDOWN"
flyDownBtn.TextColor3 = Color3.fromRGB(255, 185, 70)
flyDownBtn.TextSize = 12
flyDownBtn.FontFace = Font.fromName("Montserrat", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
Instance.new("UICorner", flyDownBtn).CornerRadius = UDim.new(1, 0)
local flyDownStroke = Instance.new("UIStroke", flyDownBtn)
flyDownStroke.Color = Color3.fromRGB(255, 185, 70)
flyDownStroke.Thickness = 1.5

flyUpBtn.MouseButton1Down:Connect(function() flyMobileY = 1 end)
flyUpBtn.MouseButton1Up:Connect(function() if flyMobileY > 0 then flyMobileY = 0 end end)
flyDownBtn.MouseButton1Down:Connect(function() flyMobileY = -1 end)
flyDownBtn.MouseButton1Up:Connect(function() if flyMobileY < 0 then flyMobileY = 0 end end)

flyUpBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then flyMobileY = 1 end
end)
flyUpBtn.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch and flyMobileY > 0 then flyMobileY = 0 end
end)
flyDownBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then flyMobileY = -1 end
end)
flyDownBtn.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch and flyMobileY < 0 then flyMobileY = 0 end
end)

-- Notification system
local function playClickSound()
    pcall(function()
        local s = Instance.new("Sound")
        s.SoundId = "rbxassetid://6895079853"
        s.Volume = 0.3
        s.Parent = SoundService
        s:Play()
        s.Ended:Connect(function() s:Destroy() end)
    end)
end

local function notify(title, content, duration)
    pcall(function()
        duration = duration or 3
        local notifHolder = GuiParent:FindFirstChild("PayomboyZ_NotifHolder")
        if not notifHolder then
            notifHolder = Instance.new("ScreenGui")
            notifHolder.Name = "PayomboyZ_NotifHolder"
            notifHolder.ResetOnSpawn = false
            notifHolder.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
            notifHolder.Parent = GuiParent
        end

        local toast = Instance.new("Frame")
        toast.Size = UDim2.new(0, 280, 0, 60)
        toast.Position = UDim2.new(1, 20, 1, -80)
        toast.BackgroundColor3 = Color3.fromRGB(25, 11, 16)
        toast.BackgroundTransparency = 0.15
        toast.BorderSizePixel = 0
        toast.ZIndex = 999999
        toast.Parent = notifHolder

        local corner = Instance.new("UICorner", toast)
        corner.CornerRadius = UDim.new(0, 10)

        local stroke = Instance.new("UIStroke", toast)
        stroke.Color = Color3.fromRGB(140, 40, 60)
        stroke.Thickness = 1.5

        local tTitle = Instance.new("TextLabel", toast)
        tTitle.Size = UDim2.new(1, -20, 0, 20)
        tTitle.Position = UDim2.new(0, 10, 0, 6)
        tTitle.BackgroundTransparency = 1
        tTitle.Text = title
        tTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
        tTitle.Font = Enum.Font.GothamBold
        tTitle.TextSize = 13
        tTitle.TextXAlignment = Enum.TextXAlignment.Left

        local tDesc = Instance.new("TextLabel", toast)
        tDesc.Size = UDim2.new(1, -20, 0, 28)
        tDesc.Position = UDim2.new(0, 10, 0, 26)
        tDesc.BackgroundTransparency = 1
        tDesc.Text = content
        tDesc.TextColor3 = Color3.fromRGB(242, 218, 228)
        tDesc.Font = Enum.Font.Gotham
        tDesc.TextSize = 11
        tDesc.TextWrapped = true
        tDesc.TextXAlignment = Enum.TextXAlignment.Left

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

-- ====================================================================
--  PLAYER & TEAM HELPERS
-- ====================================================================
local function getCharacter(targetPlayer)
    if not targetPlayer then return nil end
    if targetPlayer.Character and targetPlayer.Character:FindFirstChildOfClass("Humanoid") then
        return targetPlayer.Character
    end
    local charByName = workspace:FindFirstChild(targetPlayer.Name)
    if charByName and charByName:FindFirstChildOfClass("Humanoid") then
        return charByName
    end
    for _, folderName in ipairs({"Characters", "Players", "Entities"}) do
        local folder = workspace:FindFirstChild(folderName)
        if folder then
            local c = folder:FindFirstChild(targetPlayer.Name)
            if c and c:FindFirstChildOfClass("Humanoid") then
                return c
            end
        end
    end
    return nil
end

local function isSameTeamRaw(targetPlayer)
    if not Settings.TeamCheck then return false end
    if not targetPlayer or targetPlayer == player then return true end

    -- Clan / Squad / Party alliance check
    local myClan = player:FindFirstChild("Clan") or player:GetAttribute("ClanId") or player:GetAttribute("Clan")
    local targetClan = targetPlayer:FindFirstChild("Clan") or targetPlayer:GetAttribute("ClanId") or targetPlayer:GetAttribute("Clan")
    if myClan and targetClan and myClan == targetClan and tostring(myClan) ~= "" then
        return true
    end

    local mySquad = player:GetAttribute("SquadId") or player:GetAttribute("PartyId")
    local targetSquad = targetPlayer:GetAttribute("SquadId") or targetPlayer:GetAttribute("PartyId")
    if mySquad and targetSquad and mySquad == targetSquad and tostring(mySquad) ~= "" then
        return true
    end

    -- Real team check (if server sets genuine non-neutral teams)
    if player.Team ~= nil and targetPlayer.Team ~= nil then
        if player.Team == targetPlayer.Team then
            local teamName = tostring(player.Team.Name):lower()
            if not string.find(teamName, "neutral") and not string.find(teamName, "ffa") and not string.find(teamName, "free") and not string.find(teamName, "lobby") then
                return true
            end
        end
    end

    if player.TeamColor and targetPlayer.TeamColor and player.TeamColor == targetPlayer.TeamColor then
        local colorName = tostring(player.TeamColor.Name):lower()
        if not string.find(colorName, "white") and not string.find(colorName, "grey") and not string.find(colorName, "gray") and not string.find(colorName, "medium stone") then
            return true
        end
    end

    local myTeamVal = player:FindFirstChild("Team") or (player:FindFirstChild("leaderstats") and player.leaderstats:FindFirstChild("Team"))
    local targetTeamVal = targetPlayer:FindFirstChild("Team") or (targetPlayer:FindFirstChild("leaderstats") and targetPlayer.leaderstats:FindFirstChild("Team"))
    if myTeamVal and targetTeamVal and myTeamVal.Value == targetTeamVal.Value and tostring(myTeamVal.Value) ~= "" and tostring(myTeamVal.Value) ~= "0" then
        return true
    end

    return false
end

local function isSameTeam(targetPlayer)
    local ok, res = pcall(isSameTeamRaw, targetPlayer)
    if ok then return res end
    return false
end

local function getColorByDistance(dist)
    if dist < 100 then
        return COLORS.danger
    elseif dist < 300 then
        return COLORS.warning
    elseif dist < 600 then
        return Color3.fromRGB(255, 255, 100)
    else
        return COLORS.success
    end
end

-- ====================================================================
--  REMOTES & REPLICATED STORAGE RESOLVER
-- ====================================================================
local RS = cloneref(game:GetService("ReplicatedStorage"))
local RemotesFolder = RS:WaitForChild("Remotes", 15) or RS:FindFirstChild("Remotes")

local function getRemote(name)
    if RemotesFolder then
        local r = RemotesFolder:FindFirstChild(name)
        if r then return r end
    end
    for _, d in ipairs(RS:GetDescendants()) do
        if d.Name == name and (d:IsA("RemoteEvent") or d:IsA("RemoteFunction")) then
            return d
        end
    end
    return nil
end

local function getMyRoot()
    local char = LocalPlayer.Character
    return char and (char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart)
end

-- ====================================================================
--  WARZ COMBAT & NO RECOIL ENGINE (DIRECT COMBAT SETTINGS HOOK - ZERO LAG)
-- ====================================================================
local WarZ = {}
local origRecoilFor = nil
local origViewRecoilFor = nil
local origWeaponStats = {}

local function getCombatSettingsModule()
    local sp = game:GetService("StarterPlayer")
    local sps = sp and sp:FindFirstChild("StarterPlayerScripts")
    local client = sps and sps:FindFirstChild("Client")
    local input = client and client:FindFirstChild("input")
    local mod = input and input:FindFirstChild("CombatSettings")
    if mod then
        local ok, res = pcall(require, mod)
        if ok and type(res) == "table" then return res end
    end
    local ps = LocalPlayer and LocalPlayer:FindFirstChild("PlayerScripts")
    local pClient = ps and ps:FindFirstChild("Client")
    local pInput = pClient and pClient:FindFirstChild("input")
    local pMod = pInput and pInput:FindFirstChild("CombatSettings")
    if pMod then
        local ok, res = pcall(require, pMod)
        if ok and type(res) == "table" then return res end
    end
    return nil
end

local function applyNoRecoil()
    pcall(function()
        local cs = getCombatSettingsModule()
        if cs then
            if not origRecoilFor and cs.RecoilFor then origRecoilFor = cs.RecoilFor end
            if not origViewRecoilFor and cs.ViewRecoilFor then origViewRecoilFor = cs.ViewRecoilFor end
            cs.RecoilFor = function(...) return 0 end
            cs.ViewRecoilFor = function(...) return 0 end

            local cat = cs.GetCatalog and cs.GetCatalog()
            if cat and type(cat.Weapons) == "table" then
                for wName, wData in pairs(cat.Weapons) do
                    if type(wData) == "table" then
                        if not origWeaponStats[wName] then
                            origWeaponStats[wName] = {
                                Recoil = wData.Recoil,
                                ViewRecoil = wData.ViewRecoil,
                                Spread = wData.Spread,
                            }
                        end
                        wData.Recoil = 0
                        wData.ViewRecoil = 0
                        wData.Spread = 0
                    end
                end
            end
        end
    end)
end

function WarZ.RestoreRecoil()
    pcall(function()
        local cs = getCombatSettingsModule()
        if cs then
            if origRecoilFor then cs.RecoilFor = origRecoilFor end
            if origViewRecoilFor then cs.ViewRecoilFor = origViewRecoilFor end
            local cat = cs.GetCatalog and cs.GetCatalog()
            if cat and type(cat.Weapons) == "table" then
                for wName, orig in pairs(origWeaponStats) do
                    if cat.Weapons[wName] then
                        cat.Weapons[wName].Recoil = orig.Recoil
                        cat.Weapons[wName].ViewRecoil = orig.ViewRecoil
                        cat.Weapons[wName].Spread = orig.Spread
                    end
                end
            end
        end
    end)
    origWeaponStats = {}
end

function WarZ.SetNoRecoil(state)
    Settings.NoRecoil = state
    if state then
        task.spawn(applyNoRecoil)
    else
        WarZ.RestoreRecoil()
    end
end

task.spawn(function()
    while _G.PayomboyZBloxZRun == RUN do
        if Settings.NoRecoil then applyNoRecoil() end
        task.wait(2.5)
    end
end)

-- ====================================================================
--  WARZ AUTO HEAL ENGINE (INSTANT & REACTIVE - 100% WORKING)
-- ====================================================================
local healRemoteCache = nil
local warnedNoHealRemote = false
local lastHealUse = 0

local function getUseItemRemote()
    if healRemoteCache and healRemoteCache.Parent then return healRemoteCache end
    healRemoteCache = nil
    local remotes = RS:FindFirstChild("Remotes")
    local r = remotes and remotes:FindFirstChild("UseItem")
    if not r then
        for _, d in ipairs(RS:GetDescendants()) do
            if d.Name == "UseItem" and (d:IsA("RemoteEvent") or d:IsA("RemoteFunction")) then
                r = d
                break
            end
        end
    end
    healRemoteCache = r
    return r
end

local function myHumanoid()
    local char = LocalPlayer.Character
    return char and char:FindFirstChildOfClass("Humanoid")
end

local function needHeal(hum)
    return hum and hum.Parent and hum.Health > 0 and hum.MaxHealth > 0
        and (hum.Health / hum.MaxHealth) <= Settings.AutoHealThreshold
end

local function tryHeal()
    if not Settings.AutoHeal then return end
    local hum = myHumanoid()
    if not needHeal(hum) then return end
    local now = os.clock()
    if now - lastHealUse < Settings.AutoHealCooldown then return end
    lastHealUse = now

    local healItem = Settings.AutoHealItem or "BandagesDX"
    local char = LocalPlayer.Character
    local bp = LocalPlayer:FindFirstChild("Backpack")

    -- 1. Try finding tool in Character or Backpack
    local medNames = { healItem, "BandagesDX", "Medkit", "Bandages", "Painkiller" }
    local foundTool = nil
    for _, name in ipairs(medNames) do
        if char then foundTool = char:FindFirstChild(name) end
        if not foundTool and bp then foundTool = bp:FindFirstChild(name) end
        if foundTool then break end
    end

    if foundTool and foundTool:IsA("Tool") then
        if foundTool.Parent == bp and hum then
            hum:EquipTool(foundTool)
            task.wait(0.05)
        end
        pcall(function() foundTool:Activate() end)
    end

    -- 2. Call remote UseItem
    local useItem = getUseItemRemote()
    if useItem then
        pcall(function()
            if useItem:IsA("RemoteFunction") then
                useItem:InvokeServer(3, healItem, nil, nil, true)
            else
                useItem:FireServer(3, healItem, nil, nil, true)
                useItem:FireServer(healItem)
                useItem:FireServer("Use", healItem)
            end
        end)
    end
end

function WarZ.SetAutoHeal(state)
    Settings.AutoHeal = state
    if state then
        lastHealUse = 0
        tryHeal()
    end
end

task.spawn(function()
    while _G.PayomboyZBloxZRun == RUN do
        if Settings.AutoHeal then tryHeal() end
        task.wait(math.max(Settings.AutoHealCooldown, 0.05))
    end
end)

local function watchHealCharacter(char)
    local hum = char:WaitForChild("Humanoid", 5)
    if not hum then return end
    bind(hum.HealthChanged, function()
        tryHeal()
    end)
end

bind(LocalPlayer.CharacterAdded, function(char)
    task.spawn(watchHealCharacter, char)
end)
if LocalPlayer.Character then
    task.spawn(watchHealCharacter, LocalPlayer.Character)
end

-- ====================================================================
--  INFINITE STAMINA ENGINE
-- ====================================================================
function WarZ.SetInfiniteStamina(state)
    Settings.InfiniteStamina = state
end

task.spawn(function()
    while _G.PayomboyZBloxZRun == RUN do
        if Settings.InfiniteStamina then
            pcall(function()
                LocalPlayer:SetAttribute("CSGO_Stamina", 100)
                LocalPlayer:SetAttribute("Stamina", 100)
                local char = LocalPlayer.Character
                if char then
                    char:SetAttribute("CSGO_Stamina", 100)
                    char:SetAttribute("Stamina", 100)
                end
            end)
        end
        task.wait(0.2)
    end
end)

-- ====================================================================
--  SMART POND FINDER & AUTO FISHING ENGINE
-- ====================================================================
local FishingStatusLabel = nil
local FishingCountLabel = nil
local WarZFishing = { CurrentPhase = "idle", CastId = nil }
local fishingBusy = false

local function updateFishingStatus(txt)
    if FishingStatusLabel then
        pcall(function() FishingStatusLabel.Text = txt end)
    end
end

local function updateFishingCount()
    if FishingCountLabel then
        pcall(function()
            FishingCountLabel.Text = tostring(Settings.TotalFishCaught) .. " " .. (currentLang == "TH" and "ตัว" or "Fish")
        end)
    end
end

local KNOWN_SAFEZONE_PONDS = {
    Vector3.new(42.5, 3.2, -188.4),
    Vector3.new(-120.4, 4.0, 310.2),
    Vector3.new(0, 2.5, 0),
}

local function findNearestWater()
    local root = getMyRoot()
    if not root then return nil, nil end
    local myPos = root.Position
    local candidates = {}

    if Settings.FishSafeZonePriority then
        for _, pos in ipairs(KNOWN_SAFEZONE_PONDS) do
            local d = (pos - myPos).Magnitude
            if d < 500 then
                table.insert(candidates, { Pos = pos, Dist = d, Name = "SafeZone Pond" })
            end
        end
    end

    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            local n = obj.Name:lower()
            if obj.Material == Enum.Material.Water or n:find("water") or n:find("pond") or n:find("lake") or n:find("river") or n:find("fish") then
                local d = (obj.Position - myPos).Magnitude
                if d < 600 then
                    table.insert(candidates, { Pos = obj.Position, Dist = d, Name = obj.Name })
                end
            end
        end
    end

    if #candidates == 0 and workspace.Terrain then
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Exclude
        params.FilterDescendantsInstances = { LocalPlayer.Character }
        params.IgnoreWater = false

        for r = 15, 300, 25 do
            local numAngles = math.max(8, math.floor(r / 6))
            for i = 1, numAngles do
                local theta = (i / numAngles) * math.pi * 2
                local sample = myPos + Vector3.new(math.cos(theta) * r, 25, math.sin(theta) * r)
                local hit = workspace:Raycast(sample, Vector3.new(0, -60, 0), params)
                if hit and hit.Material == Enum.Material.Water then
                    local d = (hit.Position - myPos).Magnitude
                    table.insert(candidates, { Pos = hit.Position, Dist = d, Name = "Terrain Water" })
                    if d < 50 then break end
                end
            end
            if #candidates > 0 then break end
        end
    end

    table.sort(candidates, function(a, b) return a.Dist < b.Dist end)
    if #candidates > 0 then
        return candidates[1].Pos, candidates[1].Dist
    end
    return nil, nil
end

local function autoNavigateToWater(waterPos, onArrived)
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not hum or not root then return false end

    local flatWater = Vector3.new(waterPos.X, root.Position.Y, waterPos.Z)
    local dist = (flatWater - root.Position).Magnitude
    if dist <= 12 then
        root.CFrame = CFrame.new(root.Position, flatWater)
        if onArrived then onArrived() end
        return true
    end

    updateFishingStatus(currentLang == "TH" and ("🚶 กำลังเดินไปที่บ่อน้ำ (" .. math.floor(dist) .. "m)...") or ("Walking to Pond (" .. math.floor(dist) .. "m)..."))
    
    local dir = (waterPos - root.Position).Unit
    local stopSpot = waterPos - Vector3.new(dir.X, 0, dir.Z) * 6
    stopSpot = Vector3.new(stopSpot.X, root.Position.Y, stopSpot.Z)

    local startT = os.clock()
    while Settings.AutoFish and _G.PayomboyZBloxZRun == RUN and (os.clock() - startT < 18) do
        local curDist = (stopSpot - root.Position).Magnitude
        if curDist <= 6.5 then break end

        hum:MoveTo(stopSpot)

        local moveDir = (stopSpot - root.Position).Unit
        local stepSpeed = Settings.FarmLootSpeed or 18.5
        root.CFrame = root.CFrame + Vector3.new(moveDir.X, 0, moveDir.Z) * (stepSpeed * 0.03)

        task.wait(0.03)
    end

    local finalLook = Vector3.new(waterPos.X, root.Position.Y, waterPos.Z)
    root.CFrame = CFrame.new(root.Position, finalLook)
    task.wait(0.3)

    if onArrived then onArrived() end
    return true
end

local function findEquippedOrBagRod(char)
    local activeSlot = tonumber(LocalPlayer:GetAttribute("CSGO_ActiveSlot")) or 0
    local catalogId = tostring(LocalPlayer:GetAttribute("CSGO_CatalogId") or "")
    if catalogId:lower():find("rod") then return activeSlot end
    return activeSlot > 0 and activeSlot or 1
end

local function triggerNextCast()
    if not Settings.AutoFish or _G.PayomboyZBloxZRun ~= RUN then return end
    if fishingBusy then return end
    fishingBusy = true

    local char = LocalPlayer.Character
    local root = getMyRoot()
    if not char or not root then fishingBusy = false; return end

    local waterPos, waterDist = findNearestWater()
    if not waterPos then
        updateFishingStatus(currentLang == "TH" and "❌ ไม่พบบ่อน้ำในระยะ 600m" or "❌ No water pond found in 600m")
        fishingBusy = false
        return
    end

    local function proceedCast()
        if not Settings.AutoFish or _G.PayomboyZBloxZRun ~= RUN then fishingBusy = false; return end

        local fStart = getRemote("FishingStart") or getRemote("AutoFishingAction")
        local fAim = getRemote("FishingAim")
        if not fStart then
            updateFishingStatus(currentLang == "TH" and "❌ ไม่พบ Remote ตกปลา" or "❌ Fishing Remote Missing")
            fishingBusy = false
            return
        end

        local rodSlot = findEquippedOrBagRod(char)
        updateFishingStatus(currentLang == "TH" and "🎣 กำลังเหวี่ยงเบ็ดลงน้ำ..." or "Casting fishing rod...")

        local lookTarget = (waterPos - root.Position).Unit * 18 + root.Position
        if fAim then pcall(function() fAim:FireServer(lookTarget) end) end

        pcall(function() fStart:FireServer(rodSlot, lookTarget) end)
        pcall(function() fStart:FireServer(lookTarget) end)
        pcall(function() fStart:FireServer(rodSlot) end)

        pcall(function()
            local sp = game:GetService("StarterPlayer")
            local sps = sp and sp:FindFirstChild("StarterPlayerScripts")
            local client = sps and sps:FindFirstChild("Client")
            local world = client and client:FindFirstChild("world")
            local fObj = world and world:FindFirstChild("Fishing")
            if fObj then
                local fishMod = require(fObj)
                if fishMod and fishMod.Press then
                    fishMod:Press()
                    task.wait(0.08)
                    if fishMod.Release then fishMod:Release() end
                end
            end
        end)
        fishingBusy = false
    end

    local flatWater = Vector3.new(waterPos.X, root.Position.Y, waterPos.Z)
    local curDist = (flatWater - root.Position).Magnitude

    if curDist > 14 and Settings.FishAutoWalk then
        autoNavigateToWater(waterPos, function()
            proceedCast()
        end)
    else
        root.CFrame = CFrame.new(root.Position, flatWater)
        task.wait(0.2)
        proceedCast()
    end
end

local function setupFishingRemoteHook()
    local fState = getRemote("FishingState")
    if not fState then return end

    bind(fState.OnClientEvent, function(data)
        if not Settings.AutoFish or _G.PayomboyZBloxZRun ~= RUN then return end
        if type(data) ~= "table" then return end

        if data.phase == "waiting" then
            WarZFishing.CurrentPhase = "waiting"
            WarZFishing.CastId = data.castId
            updateFishingStatus(currentLang == "TH" and "⏳ กำลังรอดุ้นขยับ (ปลาตอด)..." or "Waiting for fish bite...")

        elseif data.phase == "minigame" then
            WarZFishing.CurrentPhase = "minigame"
            updateFishingStatus(currentLang == "TH" and "🎯 ปลากินเบ็ดแล้ว! กำลังตวัด..." or "Fish hooked! Reeling in...")

            task.spawn(function()
                local castId = data.castId or WarZFishing.CastId
                local fReel = getRemote("FishingReel")
                if not fReel then return end

                if Settings.FishPerfectReel then
                    local zoneWidth = tonumber(data.zoneWidth or data.sweetSpotWidth) or 0.28
                    local zoneCenter = tonumber(data.zoneCenter or data.targetPos) or 0.50
                    local startTime = os.clock()

                    while os.clock() - startTime < 4.5 do
                        local tNow = workspace:GetServerTimeNow()
                        local marker = (math.sin(tNow * 4.2) + 1) / 2
                        local diff = math.abs(marker - zoneCenter)
                        if diff <= (zoneWidth * 0.38) then
                            pcall(function() fReel:FireServer(castId, tNow) end)
                            updateFishingStatus(currentLang == "TH" and "ตวัดปลาสำเร็จ! (Perfect 100%)" or "Caught Fish! (Perfect 100%)")
                            return
                        end
                        RunService.Heartbeat:Wait()
                    end
                end
                pcall(function() fReel:FireServer(castId, workspace:GetServerTimeNow()) end)
            end)

        elseif data.phase == "result" then
            WarZFishing.CurrentPhase = "result"
            Settings.TotalFishCaught = Settings.TotalFishCaught + 1
            updateFishingCount()

            local rewardStr = "Fish"
            if type(data.rewards) == "table" and #data.rewards > 0 then
                local r1 = data.rewards[1]
                rewardStr = tostring(r1.name or r1.itemId or "Fish") .. " x" .. tostring(r1.qty or 1)
            elseif data.name or data.itemId then
                rewardStr = tostring(data.name or data.itemId) .. " x" .. tostring(data.qty or 1)
            end
            updateFishingStatus(currentLang == "TH" and ("ตกสำเร็จ: " .. rewardStr) or ("Caught: " .. rewardStr))
            notify("Auto Fish", currentLang == "TH" and ("ตกปลาสำเร็จ: " .. rewardStr) or ("Caught: " .. rewardStr), 2.5)

            task.spawn(function()
                task.wait(math.max(Settings.FishCastDelay, 0.85))
                if Settings.AutoFish and _G.PayomboyZBloxZRun == RUN then triggerNextCast() end
            end)

        elseif data.phase == "cancel" then
            WarZFishing.CurrentPhase = "idle"
            updateFishingStatus(currentLang == "TH" and "การตกปลาถูกยกเลิก (กำลังเริ่มใหม่)" or "Canceled (Restarting)")
            task.spawn(function()
                task.wait(1.5)
                if Settings.AutoFish and _G.PayomboyZBloxZRun == RUN then triggerNextCast() end
            end)
        end
    end)
end

function WarZ.SetAutoFish(state)
    Settings.AutoFish = state
    if state then
        updateFishingStatus(currentLang == "TH" and "เปิด Auto Fish แล้ว กำลังเริ่ม..." or "Auto Fish Started...")
        setupFishingRemoteHook()
        task.spawn(function() task.wait(0.3); triggerNextCast() end)
    else
        updateFishingStatus(T("fish_status_ready"))
        pcall(function()
            local fCancel = getRemote("FishingCancel")
            if fCancel and WarZFishing.CastId then fCancel:FireServer(WarZFishing.CastId) end
        end)
    end
end

-- ====================================================================
--  SMART AUTO-LOOT & ANTI-BAC FARM RUNNER ENGINE (UUID PROTOCOL)
-- ====================================================================
local PICKUP_ARG3 = 3
local triedLoot = setmetatable({}, { __mode = "k" })
local lootBusy = false
local warnedNoId = false

local function isUuid(v)
    return type(v) == "string"
        and v:match("^%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x$") ~= nil
end

local function getLootId(inst)
    if isUuid(inst.Name) then return inst.Name end
    for _, v in pairs(inst:GetAttributes()) do
        if isUuid(v) then return v end
    end
    for _, d in ipairs(inst:GetDescendants()) do
        if isUuid(d.Name) then return d.Name end
        if d:IsA("StringValue") and isUuid(d.Value) then return d.Value end
        for _, v in pairs(d:GetAttributes()) do
            if isUuid(v) then return v end
        end
    end
    return inst:GetAttribute("LootUid") or inst:GetAttribute("UID") or inst:GetAttribute("Uid") or (inst:IsA("BasePart") and inst.Name)
end

local function getLootFolder()
    return workspace:FindFirstChild("WarzLoot") or workspace:FindFirstChild("Loot")
end

local function getLootPosition(inst)
    if inst:IsA("BasePart") then return inst.Position end
    if inst:IsA("Model") then
        local ok, cf = pcall(function() return inst:GetPivot() end)
        if ok and cf then return cf.Position end
        local p = inst.PrimaryPart or inst:FindFirstChildWhichIsA("BasePart", true)
        if p then return p.Position end
    end
    local part = inst:FindFirstChildWhichIsA("BasePart", true)
    return part and part.Position or nil
end

local function lootDist(inst)
    local root = getMyRoot()
    local pos = inst.Parent and getLootPosition(inst)
    if not root or not pos then return math.huge end
    return (pos - root.Position).Magnitude
end

local function nearestLoot()
    local folder = getLootFolder()
    if not folder then return nil end
    local best, bestD = nil, Settings.AutoLootRange
    local now = os.clock()
    for _, inst in ipairs(folder:GetChildren()) do
        if not (triedLoot[inst] and now - triedLoot[inst] < 2) then
            local d = lootDist(inst)
            if d <= bestD then
                best, bestD = inst, d
            end
        end
    end
    return best
end

local function pickup(loot)
    if not loot or not loot.Parent then return end

    -- 1. Instant executor fireproximityprompt
    pcall(function()
        local prompt = loot:FindFirstChildWhichIsA("ProximityPrompt", true)
        if prompt and fireproximityprompt then
            fireproximityprompt(prompt, 0)
        end
    end)

    -- 2. Remote PickupLoot
    local remote = getRemote("PickupLoot")
    local id = getLootId(loot)
    if remote and id then
        pcall(function() remote:FireServer(id, "prep", PICKUP_ARG3) end)
        task.wait(math.clamp(Settings.AutoLootHold, 0.05, 0.25))
        pcall(function() remote:FireServer(id, "use", PICKUP_ARG3) end)
        pcall(function() remote:FireServer(id) end)
    end
end

function WarZ.SetAutoLoot(state)
    Settings.AutoLoot = state
    if state then warnedNoId = false end
end

task.spawn(function()
    while _G.PayomboyZBloxZRun == RUN do
        if Settings.AutoLoot and not lootBusy then
            local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                local loot = nearestLoot()
                if loot then
                    lootBusy = true
                    triedLoot[loot] = os.clock()
                    pcall(pickup, loot)
                    lootBusy = false
                end
            end
        end
        task.wait(math.max(Settings.AutoLootDelay, 0.1))
    end
end)

-- Farm Loot Runner with Anti-BAC Clamped Speed
local FarmLootStatusLabel = nil
local farmRunnerBusy = false

local function updateFarmStatus(txt)
    if FarmLootStatusLabel then
        pcall(function() FarmLootStatusLabel.Text = txt end)
    end
end

local function isEnemyNearby(range)
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return false, nil end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player then
            local pChar = p.Character
            local pRoot = pChar and pChar:FindFirstChild("HumanoidRootPart")
            local pHum = pChar and pChar:FindFirstChildOfClass("Humanoid")
            if pRoot and pHum and pHum.Health > 0 then
                if (pRoot.Position - root.Position).Magnitude <= range then
                    return true, p
                end
            end
        end
    end
    return false, nil
end

local function isItemMatchFilter(inst)
    local name = tostring(inst:GetAttribute("LootName") or inst:GetAttribute("LootItemId") or inst.Name):lower()
    local filter = Settings.FarmLootFilter or "ของมีค่าทั้งหมด (ปืน เกราะ ยา แม็ก)"

    if filter:find("เก็บทุกอย่าง") or filter:find("Everything") then
        return true
    elseif filter:find("ปืนและชุดเกราะ") or filter:find("Guns and Armor") then
        return name:find("armor") or name:find("helmet") or name:find("shield") or name:find("m4")
            or name:find("stanag") or name:find("ak") or name:find("awp") or name:find("svd")
            or name:find("honey") or name:find("blaser") or name:find("mossberg") or name:find("vss")
    else
        return name:find("armor") or name:find("helmet") or name:find("shield") or name:find("medkit")
            or name:find("bandage") or name:find("stanag") or name:find("cmag") or name:find("mag")
            or name:find("honey") or name:find("m4") or name:find("ak") or name:find("awp")
            or name:find("svd") or name:find("rod") or name:find("bait") or name:find("backpack")
            or name:find("stamina") or name:find("blaser")
    end
end

local function findBestFarmLoot()
    local folder = getLootFolder()
    if not folder then return nil, math.huge end
    local root = getMyRoot()
    if not root then return nil, math.huge end

    local best, bestDist = nil, Settings.FarmLootDistance
    local rootPos = root.Position

    for _, inst in ipairs(folder:GetChildren()) do
        if not (triedLoot[inst] and (os.clock() - triedLoot[inst] < 3)) then
            if isItemMatchFilter(inst) then
                local p = getLootPosition(inst)
                if p then
                    local d = (p - rootPos).Magnitude
                    if d <= bestDist then
                        bestDist = d
                        best = inst
                    end
                end
            end
        end
    end
    return best, bestDist
end

task.spawn(function()
    while _G.PayomboyZBloxZRun == RUN do
        if Settings.AutoFarmLoot and not farmRunnerBusy then
            local char = player.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            local root = char and char:FindFirstChild("HumanoidRootPart")

            if hum and root and hum.Health > 0 then
                if Settings.FarmStopOnEnemy then
                    local danger, enemy = isEnemyNearby(70)
                    if danger and enemy then
                        updateFarmStatus(currentLang == "TH" and ("⚠️ ระวัง! มีศัตรูใกล้ตัว (" .. enemy.Name .. ")") or ("⚠️ Enemy Nearby: " .. enemy.Name))
                        task.wait(1)
                        continue
                    end
                end

                local target, dist = findBestFarmLoot()
                if target and target.Parent then
                    local itemName = target:GetAttribute("LootName") or target:GetAttribute("LootItemId") or target.Name
                    updateFarmStatus(string.format(currentLang == "TH" and "กำลังเดินไปหา: %s (%dm)" or "Walking to: %s (%dm)", tostring(itemName), math.floor(dist)))

                    farmRunnerBusy = true
                    local startTime = os.clock()

                    while Settings.AutoFarmLoot and target.Parent and (os.clock() - startTime < 8) do
                        if Settings.FarmStopOnEnemy and isEnemyNearby(60) then
                            updateFarmStatus(currentLang == "TH" and "⚠️ ตรวจพบศัตรู! ยกเลิกเดิน" or "⚠️ Enemy detected! Aborting walk")
                            break
                        end

                        local targetPos = getLootPosition(target)
                        if not targetPos then break end
                        local curDist = (targetPos - root.Position).Magnitude
                        if curDist <= 9.0 then
                            updateFarmStatus(currentLang == "TH" and ("กำลังดูดเก็บ: " .. tostring(itemName)) or ("Looting: " .. tostring(itemName)))
                            triedLoot[target] = os.clock()
                            pcall(pickup, target)
                            task.wait(0.2)
                            break
                        end

                        local dir = (targetPos - root.Position).Unit
                        local stepSpeed = Settings.FarmLootSpeed or 18.5
                        hum:MoveTo(targetPos)

                        if curDist > 9.0 then
                            root.CFrame = root.CFrame + (dir * Vector3.new(1, 0, 1)) * (stepSpeed * 0.03)
                        end
                        task.wait(0.03)
                    end
                    farmRunnerBusy = false
                else
                    updateFarmStatus(currentLang == "TH" and "ไม่พบไอเทมในระยะฟาร์ม (กำลังสแกน...)" or "No items in range (Scanning...)")
                end
            end
        end
        task.wait(0.4)
    end
end)

function WarZ.SetAutoFarmLoot(state)
    Settings.AutoFarmLoot = state
    if not state then updateFarmStatus(currentLang == "TH" and "ปิดระบบเดินฟาร์มแล้ว" or "Farm Runner Idle") end
end

-- ====================================================================
--  STORAGE, AMMO HELPERS & ANTI-VOID
-- ====================================================================
function WarZ.DepositAllToStash()
    local r = getRemote("BagAllToStash")
    if r then
        pcall(function() r:FireServer() end)
        notify(T("storage_title"), currentLang == "TH" and "ส่งคำสั่งฝากของทั้งหมดลงคลังแล้ว" or "Deposited all items to safezone stash", 3)
    end
end

function WarZ.CombineMagazines()
    local r = getRemote("CombineMags")
    if r then
        pcall(function() r:FireServer() end)
        notify(T("storage_title"), currentLang == "TH" and "ส่งคำสั่งรวมซองกระสุนแล้ว" or "Combined ammunition magazines", 3)
    end
end

function WarZ.ClaimCommunityRewards()
    pcall(function()
        local r1 = getRemote("CommunityGiftAction")
        if r1 then r1:FireServer() end
        local r2 = getRemote("ReportRewardAck")
        if r2 then r2:FireServer() end
        notify("Rewards", currentLang == "TH" and "ส่งคำขอรับของขวัญฟรีทั้งหมดแล้ว" or "Claimed free gifts and rewards", 3)
    end)
end

task.spawn(function()
    while _G.PayomboyZBloxZRun == RUN do
        if Settings.AntiVoid then
            pcall(function()
                local root = getMyRoot()
                if root and root.Position.Y < -55 then
                    root.AssemblyLinearVelocity = Vector3.zero
                    root.CFrame = CFrame.new(root.Position.X, 15, root.Position.Z)
                end
            end)
        end
        task.wait(0.5)
    end
end)

-- ====================================================================
--  AIMBOT LOCK ENGINE (VIEWPORT & RAYCAST TARGETING - 100% WORKING)
-- ====================================================================
local function isAimInputActive()
    if Settings.AimbotAlways or aimbotMobileLock then return true end
    local aiming = false
    pcall(function() aiming = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) end)
    if not aiming then pcall(function() aiming = UserInputService:IsKeyDown(Enum.KeyCode.ButtonL2) end) end
    if not aiming then aiming = aimbotTouchActive end
    return aiming
end

local function isTargetVisible(char, targetParts)
    local Cam = workspace.CurrentCamera
    if not Cam or not char then return false, nil end

    if not Settings.AimbotWallCheck then
        for _, partName in ipairs(targetParts) do
            local part = char:FindFirstChild(partName)
            if part and part:IsA("BasePart") then
                local screenPos, onScreen = Cam:WorldToViewportPoint(part.Position)
                if onScreen and screenPos.Z > 0 then
                    return true, part
                end
            end
        end
        return false, nil
    end

    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    local filterList = { LocalPlayer.Character, Cam }
    for _, folderName in ipairs({"FpsViewModels", "CSGO_KnifeView", "WorldWeapons", "ViewGunMeshes"}) do
        local f = workspace:FindFirstChild(folderName) or Cam:FindFirstChild(folderName)
        if f then table.insert(filterList, f) end
    end
    rayParams.FilterDescendantsInstances = filterList
    rayParams.IgnoreWater = true

    for _, partName in ipairs(targetParts) do
        local part = char:FindFirstChild(partName)
        if part and part:IsA("BasePart") then
            local screenPos, onScreen = Cam:WorldToViewportPoint(part.Position)
            if onScreen and screenPos.Z > 0 then
                local origin = Cam.CFrame.Position
                local hit = workspace:Raycast(origin, part.Position - origin, rayParams)
                if not hit or hit.Instance:IsDescendantOf(char) then
                    return true, part
                end
            end
        end
    end
    return false, nil
end

local function getClosestPlayerToCenter()
    local Cam = workspace.CurrentCamera
    if not Cam then return nil end
    local localChar = player.Character
    local localRoot = localChar and localChar:FindFirstChild("HumanoidRootPart")
    if not localRoot then return nil end
    local closestPlayer, closestScore = nil, math.huge
    local centerPos = Vector2.new(Cam.ViewportSize.X / 2, Cam.ViewportSize.Y / 2)
    local aiming = isAimInputActive()

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player then
            if isSameTeam(p) then continue end
            local char = getCharacter(p)
            local humanoid = char and char:FindFirstChildOfClass("Humanoid")
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if humanoid and humanoid.Health > 0 and root then
                local worldDistance = (root.Position - localRoot.Position).Magnitude
                if worldDistance <= Settings.MaxDistance then
                    local visible, visiblePart = isTargetVisible(char, {"Head", "UpperTorso", "Torso", "HumanoidRootPart"})
                    if visible and visiblePart then
                        local direction = visiblePart.Position - Cam.CFrame.Position
                        if direction.Magnitude > 0.001 then
                            local dot = math.clamp(Cam.CFrame.LookVector:Dot(direction.Unit), -1, 1)
                            local screenPos, onScreen = Cam:WorldToViewportPoint(visiblePart.Position)
                            if onScreen and screenPos.Z > 0 then
                                local screenDistance = (Vector2.new(screenPos.X, screenPos.Y) - centerPos).Magnitude
                                local validTarget, score = false, math.huge
                                if aiming then
                                    if dot > 0 then validTarget, score = true, math.deg(math.acos(dot)) end
                                else
                                    if dot > 0 and screenDistance <= Settings.FOVRadius then validTarget, score = true, screenDistance end
                                end
                                if validTarget and score < closestScore then
                                    closestScore, closestPlayer = score, p
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return closestPlayer
end

local lockedTarget = nil
pcall(function() RunService:UnbindFromRenderStep("PayomboyZAimbot") end)
RunService:BindToRenderStep("PayomboyZAimbot", Enum.RenderPriority.Last.Value, function()
    pcall(function()
        local Cam = workspace.CurrentCamera
        if not Cam then return end
        if Settings.ShowFOV and FOVFrame then
            FOVFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
            FOVFrame.Size = UDim2.new(0, Settings.FOVRadius * 2, 0, Settings.FOVRadius * 2)
            FOVFrame.Visible = true
        elseif FOVFrame then
            FOVFrame.Visible = false
        end

        if aimMobileBtn then
            aimMobileBtn.Visible = (Settings.AimbotEnabled and Settings.MobileAimButton)
        end

        lockedTarget = nil
        if not Settings.AimbotEnabled then return end
        local target = getClosestPlayerToCenter()
        if not target then return end
        local char = getCharacter(target)
        local visible, aimTarget = isTargetVisible(char, {"Head", "UpperTorso", "Torso", "HumanoidRootPart"})
        if visible and aimTarget then
            lockedTarget = target
            Cam.CFrame = CFrame.new(Cam.CFrame.Position, aimTarget.Position)
        end
    end)
end)

-- ====================================================================
--  ESP & VISUALS ENGINE (HIGHLIGHT CHAMS, BOXES & TRACERS)
-- ====================================================================
local tracers = {}
local espLabels = {}
local espBoxes = {}
local lootHighlights = {}

local function clearESP()
    for _, l in pairs(tracers) do pcall(function() l:Destroy() end) end
    for _, lbl in pairs(espLabels) do pcall(function() lbl:Destroy() end) end
    for _, b in pairs(espBoxes) do pcall(function() b:Destroy() end) end
    for _, h in pairs(lootHighlights) do pcall(function() h:Destroy() end) end
    tracers = {}
    espLabels = {}
    espBoxes = {}
    lootHighlights = {}
end

local function getBox(p)
    local b = espBoxes[p]
    if b and b.Parent then return b end
    b = Instance.new("Frame")
    b.Name = p.Name .. "_Box"
    b.BackgroundTransparency = 1
    b.BorderSizePixel = 0
    b.ZIndex = 4
    b.Visible = false
    b.Parent = tracerGui
    local st = Instance.new("UIStroke")
    st.Color = Color3.fromRGB(255, 0, 0)
    st.Thickness = 2
    st.Parent = b

    local hpBg = Instance.new("Frame")
    hpBg.Name = "HPBG"
    hpBg.AnchorPoint = Vector2.new(1, 0)
    hpBg.Position = UDim2.new(0, -3, 0, 0)
    hpBg.Size = UDim2.new(0, 4, 1, 0)
    hpBg.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    hpBg.BorderSizePixel = 0
    hpBg.ZIndex = 4
    hpBg.Parent = b
    local hpStroke = Instance.new("UIStroke")
    hpStroke.Color = Color3.fromRGB(0, 0, 0)
    hpStroke.Thickness = 1
    hpStroke.Parent = hpBg
    local hpFill = Instance.new("Frame")
    hpFill.Name = "HPFill"
    hpFill.AnchorPoint = Vector2.new(0, 1)
    hpFill.Position = UDim2.new(0, 0, 1, 0)
    hpFill.Size = UDim2.new(1, 0, 1, 0)
    hpFill.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
    hpFill.BorderSizePixel = 0
    hpFill.ZIndex = 5
    hpFill.Parent = hpBg

    espBoxes[p] = b
    return b
end

local function createTracer(targetPlayer)
    if targetPlayer == player then return end
    if tracers[targetPlayer] then return end

    local line = Instance.new("Frame")
    line.Name = targetPlayer.Name .. "_Tracer"
    line.AnchorPoint = Vector2.new(0.5, 0.5)
    line.BackgroundColor3 = COLORS.primary
    line.BorderSizePixel = 0
    line.Visible = false
    line.ZIndex = 5
    line.Parent = tracerGui
    tracers[targetPlayer] = line

    local label = Instance.new("TextLabel")
    label.Name = targetPlayer.Name .. "_Label"
    label.Size = UDim2.new(0, 140, 0, 32)
    label.AnchorPoint = Vector2.new(0.5, 1)
    label.BackgroundColor3 = Color3.fromRGB(25, 11, 16)
    label.BackgroundTransparency = 0.25
    label.BorderSizePixel = 0
    label.Text = targetPlayer.Name .. "\n0 studs"
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 10.5
    label.Font = Enum.Font.GothamSemibold
    label.Visible = false
    label.ZIndex = 6
    label.Parent = tracerGui
    Instance.new("UICorner", label).CornerRadius = UDim.new(0, 6)
    local lStroke = Instance.new("UIStroke")
    lStroke.Color = COLORS.cyan
    lStroke.Thickness = 1
    lStroke.Parent = label
    espLabels[targetPlayer] = label
end

local function removeTracer(targetPlayer)
    if tracers[targetPlayer] then tracers[targetPlayer]:Destroy(); tracers[targetPlayer] = nil end
    if espLabels[targetPlayer] then espLabels[targetPlayer]:Destroy(); espLabels[targetPlayer] = nil end
    if espBoxes[targetPlayer] then espBoxes[targetPlayer]:Destroy(); espBoxes[targetPlayer] = nil end
end

for _, p in ipairs(Players:GetPlayers()) do
    if p ~= player then
        createTracer(p)
        bind(p.CharacterAdded, function() task.wait(0.1); createTracer(p) end)
    end
end
bind(Players.PlayerAdded, function(p)
    if p ~= player then
        createTracer(p)
        bind(p.CharacterAdded, function() task.wait(0.1); createTracer(p) end)
    end
end)
bind(Players.PlayerRemoving, removeTracer)

-- Highlight / Chams Background Task Loop
task.spawn(function()
    while _G.PayomboyZBloxZRun == RUN and task.wait(0.1) do
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= player then
                pcall(function()
                    local char = getCharacter(p)
                    if not char then return end

                    local hl = char:FindFirstChild("PayomboyZHighlight")
                    if Settings.HighlightESP then
                        local humanoid = char:FindFirstChildOfClass("Humanoid")
                        if humanoid and humanoid.Health > 0 and not isSameTeam(p) then
                            if not hl then
                                hl = Instance.new("Highlight")
                                hl.Name = "PayomboyZHighlight"
                                hl.Parent = char
                            end
                            hl.FillColor = Settings.ChamsColor
                            hl.OutlineColor = Settings.ChamsOutlineColor
                            hl.FillTransparency = Settings.ChamsFillTransparency
                            hl.OutlineTransparency = Settings.ChamsOutline and 0 or 1
                            hl.DepthMode = Settings.ChamsThroughWalls and Enum.HighlightDepthMode.AlwaysOnTop or Enum.HighlightDepthMode.Occluded
                        else
                            if hl then hl:Destroy() end
                        end
                    else
                        if hl then hl:Destroy() end
                    end
                end)
            end
        end
    end
end)

-- ESP & Tracers Renderer Loop
bind(RunService.RenderStepped, function()
    local Cam = workspace.CurrentCamera
    if not Cam then return end
    local currentLockedTarget = lockedTarget

    -- Box ESP: กรอบแดงรอบผู้เล่นทุกคน
    pcall(function()
        for _, tp in ipairs(Players:GetPlayers()) do
            if tp ~= player then
                local box = espBoxes[tp]
                local show = false
                if Settings.BoxESP and not isSameTeam(tp) then
                    local ch = getCharacter(tp)
                    local hum = ch and ch:FindFirstChildOfClass("Humanoid")
                    local root = ch and ch:FindFirstChild("HumanoidRootPart")
                    if hum and root and hum.Health > 0 then
                        local top = Cam:WorldToViewportPoint(root.Position + Vector3.new(0, 3, 0))
                        local bot = Cam:WorldToViewportPoint(root.Position - Vector3.new(0, 3.5, 0))
                        if top.Z > 0 and bot.Z > 0 then
                            local h = math.abs(bot.Y - top.Y)
                            local w = h * 0.6
                            box = getBox(tp)
                            box.Position = UDim2.fromOffset((top.X + bot.X) / 2 - w / 2, math.min(top.Y, bot.Y))
                            box.Size = UDim2.fromOffset(w, h)
                            box.Visible = true
                            show = true

                            local hpBg = box:FindFirstChild("HPBG")
                            local hpFill = hpBg and hpBg:FindFirstChild("HPFill")
                            if hpFill then
                                local pct = math.clamp(hum.Health / math.max(hum.MaxHealth, 1), 0, 1)
                                hpFill.Size = UDim2.new(1, 0, pct, 0)
                                hpFill.BackgroundColor3 = Color3.fromRGB(255, 40, 40):Lerp(Color3.fromRGB(0, 255, 100), pct)
                            end
                        end
                    end
                end
                if not show and box then box.Visible = false end
            end
        end
    end)

    -- Tracers ESP
    if not (Settings.Tracers or Settings.ESPEnabled) then
        for _, line in pairs(tracers) do line.Visible = false end
        for _, label in pairs(espLabels) do label.Visible = false end
        return
    end

    local myCharacter = getCharacter(player)
    local myRoot = myCharacter and myCharacter:FindFirstChild("HumanoidRootPart")

    for _, targetPlayer in ipairs(Players:GetPlayers()) do
        if targetPlayer == player then continue end

        if not tracers[targetPlayer] or not espLabels[targetPlayer] then
            createTracer(targetPlayer)
        end

        local line = tracers[targetPlayer]
        local label = espLabels[targetPlayer]
        if not line or not label then continue end

        if isSameTeam(targetPlayer) then
            line.Visible = false
            label.Visible = false
            continue
        end

        local character = getCharacter(targetPlayer)
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")

        if character and rootPart and humanoid and humanoid.Health > 0 then
            local vector, onScreen = Cam:WorldToViewportPoint(rootPart.Position)
            local worldDist = myRoot and (rootPart.Position - myRoot.Position).Magnitude or 0

            if worldDist > Settings.TracerDistance then
                line.Visible = false
                label.Visible = false
                continue
            end

            if onScreen then
                local startPos = Vector2.new(Cam.ViewportSize.X / 2, Cam.ViewportSize.Y)
                local endPos = Vector2.new(vector.X, vector.Y)

                local distance2D = (endPos - startPos).Magnitude
                local center = (startPos + endPos) / 2
                local angle = math.deg(math.atan2(endPos.Y - startPos.Y, endPos.X - startPos.X))

                local isTargeted = (targetPlayer == currentLockedTarget and Settings.AimbotEnabled)
                local tracerColor = isTargeted and COLORS.cyan or getColorByDistance(worldDist)
                local lineThickness = isTargeted and 3 or 2

                line.Position = UDim2.new(0, center.X, 0, center.Y)
                line.Size = UDim2.new(0, distance2D, 0, lineThickness)
                line.Rotation = angle
                line.BackgroundColor3 = tracerColor
                line.Visible = true

                local statusText = isTargeted and " 🎯 [LOCKED]" or ""
                label.Position = UDim2.new(0, vector.X, 0, vector.Y - 5)
                label.Text = string.format("%s%s\n%d studs", targetPlayer.Name, statusText, math.floor(worldDist))
                label.TextColor3 = tracerColor
                label.Visible = true
            else
                line.Visible = false
                label.Visible = false
            end
        else
            line.Visible = false
            label.Visible = false
        end
    end
end)

-- Loot ESP Engine
function WarZ.SetLootESP(state)
    Settings.LootESP = state
    if not state then
        for _, h in pairs(lootHighlights) do pcall(function() h:Destroy() end) end
        table.clear(lootHighlights)
    end
end

task.spawn(function()
    while _G.PayomboyZBloxZRun == RUN do
        if Settings.LootESP then
            local folder = getLootFolder()
            local root = getMyRoot()
            if folder and root then
                for _, inst in ipairs(folder:GetChildren()) do
                    if not lootHighlights[inst] then
                        local pos = getLootPosition(inst)
                        if pos and (pos - root.Position).Magnitude <= Settings.LootMaxDistance then
                            local h = Instance.new("Highlight")
                            h.Adornee = inst
                            h.FillColor = COLORS.warning
                            h.OutlineColor = Color3.fromRGB(255, 255, 255)
                            h.FillTransparency = 0.5
                            h.OutlineTransparency = 0.2
                            h.Parent = inst
                            lootHighlights[inst] = h
                        end
                    end
                end
            end
        end
        task.wait(1.5)
    end
end)

-- ====================================================================
--  FPS BOOST ENGINE (TEXTURE STRIPPING + UNCAP - 100% WORKING)
-- ====================================================================
function WarZ.ToggleFPSBoost(state)
    Settings.FPSBoost = state
    pcall(function()
        local Lighting = game:GetService("Lighting")
        local Terrain = workspace:FindFirstChildOfClass("Terrain")

        if state then
            Lighting.GlobalShadows = false
            Lighting.FogEnd = 9e9
            if Terrain then
                Terrain.WaterWaveSize = 0
                Terrain.WaterWaveSpeed = 0
                Terrain.WaterReflectance = 0
                Terrain.WaterTransparency = 0
            end
            for _, v in pairs(workspace:GetDescendants()) do
                pcall(function()
                    if v:IsA("BasePart") and not v:IsA("Terrain") then
                        v.Material = Enum.Material.SmoothPlastic
                        v.Reflectance = 0
                    elseif v:IsA("Decal") or v:IsA("Texture") then
                        v.Transparency = 1
                    elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
                        v.Enabled = false
                    end
                end)
            end
            pcall(function()
                if getgenv and getgenv().setfpscap then
                    getgenv().setfpscap(999)
                elseif setfpscap then
                    setfpscap(999)
                end
            end)
        else
            Lighting.GlobalShadows = true
            Lighting.FogEnd = 100000
            pcall(function()
                if getgenv and getgenv().setfpscap then
                    getgenv().setfpscap(60)
                elseif setfpscap then
                    setfpscap(60)
                end
            end)
        end
    end)
end

-- ====================================================================
--  MOVEMENT & PHYSICS ENGINE (WALKSPEED, FLY, NOCLIP, BHOP)
-- ====================================================================
local wsHum, wsOrig = nil, nil
local flyBV, flyBG = nil, nil

local function restoreWalkSpeed()
    if wsHum and wsHum.Parent and wsOrig then
        pcall(function() wsHum.WalkSpeed = wsOrig end)
    end
    wsHum, wsOrig = nil, nil
end

local function stopFly()
    if flyBV then pcall(function() flyBV:Destroy() end); flyBV = nil end
    if flyBG then pcall(function() flyBG:Destroy() end); flyBG = nil end
    if flyMobileHolder then flyMobileHolder.Visible = false end
end

local function hookHumSpeed(hum)
    if not hum then return end
    bind(hum:GetPropertyChangedSignal("WalkSpeed"), function()
        if Settings.WalkSpeedEnabled and hum.WalkSpeed ~= Settings.WalkSpeedValue then
            hum.WalkSpeed = Settings.WalkSpeedValue
        end
    end)
end

bind(LocalPlayer.CharacterAdded, function(char)
    local hum = char:WaitForChild("Humanoid", 5)
    if hum then hookHumSpeed(hum) end
end)
if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
    hookHumSpeed(LocalPlayer.Character:FindFirstChildOfClass("Humanoid"))
end

local function updateMovement()
    pcall(function()
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local root = char and char:FindFirstChild("HumanoidRootPart")

        -- WalkSpeed
        if Settings.WalkSpeedEnabled and hum then
            if wsHum ~= hum then
                restoreWalkSpeed()
                wsHum = hum
                wsOrig = hum.WalkSpeed
                hookHumSpeed(hum)
            end
            hum.WalkSpeed = Settings.WalkSpeedValue
        elseif wsHum then
            restoreWalkSpeed()
        end

        -- BunnyHop
        if Settings.BunnyHop and hum and hum.Health > 0 then
            if hum.MoveDirection.Magnitude > 0 and hum.FloorMaterial ~= Enum.Material.Air then
                hum.Jump = true
            end
        end

        -- Fly
        if flyMobileHolder then
            flyMobileHolder.Visible = (Settings.Fly and Settings.MobileFlyControls)
        end

        if not (Settings.Fly and hum and root and hum.Health > 0) then
            if flyBV or flyBG then stopFly() end
            return
        end

        if not flyBV or flyBV.Parent ~= root then
            stopFly()
            flyBV = Instance.new("BodyVelocity")
            flyBV.Name = "PayomboyZFlyBV"
            flyBV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            flyBV.Velocity = Vector3.zero
            flyBV.Parent = root
            flyBG = Instance.new("BodyGyro")
            flyBG.Name = "PayomboyZFlyBG"
            flyBG.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
            flyBG.P = 9e4
            flyBG.Parent = root
        end

        local Cam = workspace.CurrentCamera
        if not Cam then return end
        local dir = hum.MoveDirection
        local look = Cam.CFrame.LookVector
        local flatLook = Vector3.new(look.X, 0, look.Z)
        local fwd = 0
        if flatLook.Magnitude > 0.01 then fwd = dir:Dot(flatLook.Unit) end

        local v = Vector3.new(dir.X, look.Y * fwd, dir.Z)
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) or hum.Jump or flyMobileY > 0 then
            v = v + Vector3.new(0, 1, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.Q) or flyMobileY < 0 then
            v = v - Vector3.new(0, 1, 0)
        end
        if v.Magnitude > 1 then v = v.Unit end

        flyBV.Velocity = v * Settings.FlySpeed
        flyBG.CFrame = Cam.CFrame
    end)
end

bind(RunService.Heartbeat, updateMovement)
bind(RunService.RenderStepped, function()
    if Settings.WalkSpeedEnabled and wsHum then
        wsHum.WalkSpeed = Settings.WalkSpeedValue
    end
end)

bind(RunService.Stepped, function()
    pcall(function()
        local char = LocalPlayer.Character
        if char and Settings.Noclip then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end)
end)

-- ====================================================================
--  INLINED PAYOMBOYZ UI ENGINE (OBSIDIAN GLASSMORPHIC 2.0)
-- ====================================================================
local function loadPayomboyUIEngine()
    getgenv().configs = {
    	["temp"] = false,
    }
    
    -- // Tables
    
    local asset = {
    	["index"] = -1,
    	["first-executed"] = true,
    	["dr-focus"] = false,
    	["sl-focus"] = false,
    	["activated"] = false,
    	["index-focus"] = -1,
    	["tg-focus"] = false
    }
    
    local library = {}
    local init = {}
    local objects = {}
    local actualtype = {
    	Shadow = "ImageLabel",Circle = "ImageLabel",Circle2 = "ImageLabel",Circle3 = "ImageLabel",
    }
    
    local type_property = {
    	Shadow = { Name = "Shadow", BackgroundTransparency = 1, Image = "http://www.roblox.com/asset/?id=5554236805", ScaleType = Enum.ScaleType.Slice, SliceCenter = Rect.new(23,23,277,277), Size = UDim2.fromScale(1,1) + UDim2.fromOffset(30,30), Position = UDim2.fromOffset(-15,-15) },
    	Circle = { BackgroundTransparency = 1, Image = "http://www.roblox.com/asset/?id=5554831670" },
    	Circle2 = { BackgroundTransparency = 1, Image = "http://www.roblox.com/asset/?id=14970076293" },
    	Circle3 = { BackgroundTransparency = 1, Image = "http://www.roblox.com/asset/?id=6082206725" },
    }
    local types = { "Shadow", "Circle", "Circle2", "Circle3" }
    
    -- // File System
    
    task.spawn(function()
    	if not isfolder("PayomboyZ Hub") then
    		makefolder("PayomboyZ Hub")
    	end
    	if not isfolder("PayomboyZ Hub/"..game.GameId) then
    		makefolder("PayomboyZ Hub/"..game.GameId)
    	end
    end)
    
    -- // Variables
    
    local plrs = game:GetService("Players")
    local coregui = game:GetService("CoreGui")
    local tween = game:GetService("TweenService")
    local userinputservice = game:GetService("UserInputService")
    local localplr = plrs.LocalPlayer
    local mouse = localplr:GetMouse()
    local getcustomasset = getsynasset or getcustomasset or function(...) return "" end
    local gamename = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
    local HttpRequest = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
    local clipboard_func = setclipboard or toclipboard or set_clipboard or (Clipboard and Clipboard.set)
    local PRIMARY_COLOR = Color3.fromRGB(220,38,58)
    local PRIMARY_HOVER = Color3.fromRGB(239,52,72)
    local PRIMARY_PRESSED = Color3.fromRGB(170,24,42)
    
    local FESTIVALS = {
    	-- {
    	-- 	name = "LoyKrathong", -- พ.ย. (ประมาณช่วงเดือน)
    	-- 	check = function(m,d) return m == 11 end,
    	-- 	color = Color3.fromRGB(255,196,102), secondaryColor = Color3.fromRGB(255,150,60),
    	-- 	spawnRate = 0.35, size = {5,9}, direction = "up", duration = {6,10}, shape = "glow",
    	-- 	uiColor = Color3.fromRGB(255,153,51), uiHover = Color3.fromRGB(255,178,89), uiPressed = Color3.fromRGB(204,122,41),
    	-- },
    	{
    		name = "Christmas", -- 20-31 ธ.ค.
    		check = function(m,d) return m == 12 and d >= 20 end,
    		color = Color3.fromRGB(255,255,255), secondaryColor = Color3.fromRGB(225,240,255),
    		spawnRate = 0.12, size = {3,6}, direction = "down", duration = {4,7}, shape = "circle",
    		uiColor = Color3.fromRGB(34,139,58), uiHover = Color3.fromRGB(46,160,72), uiPressed = Color3.fromRGB(24,100,42),
    	},
    	{
    		name = "Valentine", -- 10-16 ก.พ.
    		check = function(m,d) return m == 2 and d >= 10 and d <= 16 end,
    		color = Color3.fromRGB(255,90,120), secondaryColor = Color3.fromRGB(255,150,170),
    		spawnRate = 0.6, size = {10,16}, direction = "up", duration = {5,8}, shape = "heart", maxOnScreen = 6,
    		uiColor = Color3.fromRGB(255,90,120), uiHover = Color3.fromRGB(255,120,145), uiPressed = Color3.fromRGB(200,60,90),
    	},
    	{
    		name = "Halloween", -- 25-31 ต.ค.
    		check = function(m,d) return m == 10 and d >= 25 end,
    		color = Color3.fromRGB(255,140,20), secondaryColor = Color3.fromRGB(255,166,64),
    		spawnRate = 0.9, size = {16,24}, direction = "down", duration = {4,6.5}, shape = "pumpkin", maxOnScreen = 7,
    		uiColor = Color3.fromRGB(255,140,20), uiHover = Color3.fromRGB(255,166,64), uiPressed = Color3.fromRGB(200,105,10),
    	},
    }
    
    function init.get_festival()
    	local now = os.date("*t")
    	for _,festival in FESTIVALS do
    		if festival.check(now.month,now.day) then return festival end
    	end
    	return nil
    end
    
    local activeFestivalTheme = init.get_festival()
    if activeFestivalTheme and activeFestivalTheme.uiColor then
    	PRIMARY_COLOR = activeFestivalTheme.uiColor
    	PRIMARY_HOVER = activeFestivalTheme.uiHover or PRIMARY_COLOR
    	PRIMARY_PRESSED = activeFestivalTheme.uiPressed or PRIMARY_COLOR
    end
    
    -- Types omitted for runtime compatibility across all Luau executors
    
    function init.generateUUID()
    	local template ='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
    	return string.gsub(template, '[xy]', function (c)
    		local v = (c == 'x') and math.random(0, 0xf) or math.random(8, 0xb)
    		return string.format('%x', v)
    	end)
    end
    
    function init.reload()
    	pcall(function()
    		local parents = { coregui, localplr and localplr:FindFirstChild("PlayerGui") }
    		if gethui then pcall(function() table.insert(parents, gethui()) end) end
    		for _, p in ipairs(parents) do
    			if p then
    				for _, value in ipairs(p:GetChildren()) do
    					if value:IsA("ScreenGui") and (value:GetAttribute("enabled") or value:GetAttribute("protected") or value.Name:find("Payomboy") or value.Name:find("PayomboyZ")) then
    						pcall(function() value:Destroy() end)
    					end
    				end
    			end
    		end
    	end)
    end
    
    function init.protected(args)
    	pcall(function()
    		local p = nil
    		if gethui then pcall(function() p = gethui() end) end
    		if not p then pcall(function() p = coregui end) end
    		if not p then pcall(function() p = localplr and localplr:WaitForChild("PlayerGui", 5) end) end
    		args.Parent = p or coregui
    	end)
    	args.Name = init.generateUUID()
    	args.DisplayOrder = 999
    	args.IgnoreGuiInset = true
    	args.ResetOnSpawn = false
    	args:SetAttribute("protected", tostring(init.generateUUID()))
    	args:SetAttribute("enabled", true)
    end
    
    function init.tween(object,waits,Style,...)
    	tween:Create(object,TweenInfo.new(waits,Style),...):Play()
    end
    
    function init.stroke(object,transparency,thickness,color)
    	local name = "Stroke"; 
    	name = Instance.new("UIStroke",object)
    	name.Thickness = thickness;name.LineJoinMode = Enum.LineJoinMode.Round;name.Color = color;name.Transparency = transparency;name.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    
    	return name
    end
    
    function init.checkui()
    	local descendants = coregui:GetDescendants()
    	for index , value in descendants do
    		if value:IsA("ScreenGui") then
    			if value:GetAttribute("enabled") or value:GetAttribute("protected") then
    				return value
    			end
    		end
    	end
    end
    
    function init.device()
    	return  userinputservice:GetPlatform() == Enum.Platform.Windows
    end
    
    function init.table_check(ta, object)
    	for i,v in ta do
    		if v == object then
    			return true
    		end
    	end
    	return false
    end
    
    function init.table_real_check(ta, object)
    	for i,v in ta do
    		if i == object then
    			return true
    		end
    	end
    	return false
    end
    
    
    function init.count(t)
    	local count, key = 0,nil
    	repeat
    		key = next(t, key)
    		if key ~= nil then
    			count = count + 1
    		end
    	until key == nil
    	return count
    end
    
    function init.format_timer(sec)
    	local days = math.floor(sec / 86400)
    	local hours = math.floor(sec % 86400 / 3600)
    	local minutes = math.floor(sec % 3600 / 60)
    	local remainingSeconds = sec % 60
    
    	return string.format("%dd %dh %dm %ds", days, hours, minutes, remainingSeconds):gsub(" 0%a+", "")
    end
    
    function init.find_type(args)
    	for _, Type in types do
    		if Type:lower():sub(1, #args) == args:lower() then return Type end
    	end
    	return false
    end
    
    function init.newobject(Type)
    	local TargetType = init.find_type(Type)
    	local NewImage = Instance.new(TargetType and actualtype[TargetType] or Type)
    	for Property, Value in type_property[TargetType] or {} do
    		NewImage[Property] = Value
    	end
    	return NewImage
    end
    
    function init.getXY(object)
    	local Max, May = object.AbsoluteSize.X, object.AbsoluteSize.Y
    	local Px, Py = math.clamp(mouse.X - object.AbsolutePosition.X, 0, Max), math.clamp(mouse.Y - object.AbsolutePosition.Y, 0, May)
    	return Px / Max, Py / May
    end
    
    function init.animatedcircle(Type, GuiObject, EndColour, StartColour)
    	local PX, PY = init.getXY(GuiObject)
    	local Circle = init.newobject(Type)
    	Circle.Size = UDim2.fromScale(0, 0);Circle.Position = UDim2.fromScale(PX, PY);Circle.ImageColor3 = StartColour or GuiObject.ImageColor3;Circle.ZIndex = GuiObject.ZIndex + 1;Circle.Parent = GuiObject
    	local Size = GuiObject.AbsoluteSize.X
    	init.tween(Circle,0.25,Enum.EasingStyle.Circular,{Position = UDim2.fromScale(PX, PY) - UDim2.fromOffset(Size/2, Size/2), ImageTransparency = 1, ImageColor3 = EndColour, Size = UDim2.fromOffset(Size, Size)})
    	spawn(function()
    		wait(0.5)
    		Circle:Destroy()
    	end)
    end
    
    function init.get_colorname(color)
    	local list_color = {
    		{Color3.fromRGB(0, 0, 0), "Black"},
    		{Color3.fromRGB(255, 255, 255), "White"},
    		{Color3.fromRGB(255, 0, 0), "Red"},
    		{Color3.fromRGB(0, 255, 0), "Green"},
    		{Color3.fromRGB(0, 0, 255), "Blue"},
    		{Color3.fromRGB(255, 255, 0), "Yellow"},
    		{Color3.fromRGB(0, 255, 255), "Cyan"},
    		{Color3.fromRGB(255, 0, 255), "Magenta"},
    	}
    	local closestColor, minDiff = list_color[1][2], math.huge
    	for _, knownColor in list_color do
    		local diff = math.abs(color.R - knownColor[1].R) + math.abs(color.G - knownColor[1].G) + math.abs(color.B - knownColor[1].B)
    		if diff < minDiff then
    			closestColor, minDiff = knownColor[2], diff
    		end
    	end
    
    	return closestColor
    end
    
    function init.color_to_byte(color)
    	local round = math.round
    	return string.format("%d, %d, %d",round(color.r*255),round(color.g*255),round(color.b*255))
    end
    
    function init.typewriter(text)
    	for i = 1, #text, 1 do
    		return string.sub(text, 1, i)
    	end
    end
    
    function init.checkmouse_ingui(ui)
    	if ui == nil then return false end
    	local guiPosition = ui.AbsolutePosition
    	local guiSize = ui.AbsoluteSize	
    
    	return mouse.X >= guiPosition.X and mouse.X < guiPosition.X + guiSize.X and mouse.Y >= guiPosition.Y and mouse.Y < guiPosition.Y + guiSize.Y
    end
    
    function init.randomstring()
    	local Length = math.random(10, 20)
    	local str = ""
    	for _ = 1, Length do
    		str = str .. string.char(math.random(32, 126))
    	end
    	return str
    end
    
    function init.create_corner(cornerRadius, parent)
    	local uiCorner = Instance.new("UICorner")
    	uiCorner.CornerRadius = UDim.new(0, cornerRadius)
    	if parent then
    		uiCorner.Parent = parent
    	end
    	return uiCorner
    end
    
    -- // Library
    
    function library.create()
    
    	init.reload()
    	-- // create components
    	local sixlyinit = Instance.new("ScreenGui")
    	init.protected(sixlyinit)
    
    	local main = Instance.new("Frame",sixlyinit)
    	main.AnchorPoint = Vector2.new(0.5,0.5);main.BackgroundColor3 = Color3.fromRGB(18,19,24);main.BackgroundTransparency = 0;main.Position = UDim2.new(0.5,0,0.5,0);main.Name = "@main"
    	main.Active = true
    	local viewport = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1280, 720)
    	local initialSize = init.device() and Vector2.new(700,500) or Vector2.new(600,400)
    	initialSize = Vector2.new(math.min(initialSize.X, viewport.X - 20), math.min(initialSize.Y, viewport.Y - 20))
    	main.Size = UDim2.fromOffset(initialSize.X, initialSize.Y)
    	init.tween(main,0.25,Enum.EasingStyle.Back,{Size = UDim2.fromOffset(initialSize.X, initialSize.Y)})
    	init.create_corner(10,main)
    	main.ClipsDescendants = true

    	-- // 🖼️ PayomboyZ Custom Background Artwork (Image Sep 28.png)
    	local bgImageLabel = Instance.new("ImageLabel", main)
    	bgImageLabel.Name = "MangaArtBackground"
    	bgImageLabel.Size = UDim2.fromScale(1, 1)
    	bgImageLabel.Position = UDim2.fromScale(0, 0)
    	bgImageLabel.BackgroundTransparency = 1
    	bgImageLabel.ScaleType = Enum.ScaleType.Crop
    	bgImageLabel.ImageTransparency = 0.08
    	bgImageLabel.ZIndex = 1
    	init.create_corner(10, bgImageLabel)

    	-- Subtle Dark Vignette & Gradient Tint Overlay to ensure text readability
    	local bgOverlay = Instance.new("Frame", main)
    	bgOverlay.Name = "GlassTintOverlay"
    	bgOverlay.Size = UDim2.fromScale(1, 1)
    	bgOverlay.BackgroundColor3 = Color3.fromRGB(14, 15, 20)
    	bgOverlay.BackgroundTransparency = 0.45
    	bgOverlay.BorderSizePixel = 0
    	bgOverlay.ZIndex = 2
    	init.create_corner(10, bgOverlay)

    	local bgGrad = Instance.new("UIGradient", bgOverlay)
    	bgGrad.Color = ColorSequence.new({
    		ColorSequenceKeypoint.new(0, Color3.fromRGB(18, 19, 24)),
    		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(10, 11, 14)),
    		ColorSequenceKeypoint.new(1, Color3.fromRGB(22, 24, 30)),
    	})
    	bgGrad.Transparency = NumberSequence.new({
    		NumberSequenceKeypoint.new(0, 0.20),
    		NumberSequenceKeypoint.new(1, 0.48),
    	})
    	bgGrad.Rotation = 45

    	task.spawn(function()
    		-- Source URL: https://github.com/payomboyz333/Library/blob/main/Image%20Sep%2028.png
    		local BgRawURL = "https://raw.githubusercontent.com/payomboyz333/Library/main/Image%20Sep%2028.png"
    		local BgFileName = "Image Sep 28.png"
    		local getAsset = (typeof(getcustomasset) == "function" and getcustomasset)
    		              or (typeof(getsynasset) == "function" and getsynasset)

    		local paths = {
    			BgFileName,
    			"ScriptHub/" .. BgFileName,
    			"Library/" .. BgFileName,
    			"PayomboyZ-UI/" .. BgFileName
    		}

    		local loadedAsset = nil
    		if isfile and getAsset then
    			for _, p in ipairs(paths) do
    				if isfile(p) then
    					local ok, asset = pcall(getAsset, p)
    					if ok and asset then
    						loadedAsset = asset
    						break
    					end
    				end
    			end
    		end

    		if not loadedAsset and writefile and getAsset then
    			pcall(function()
    				local fetch = (syn and syn.request) or (http and http.request) or http_request or request
    				if fetch then
    					local res = fetch({ Url = BgRawURL, Method = "GET" })
    					if res and res.Body and #res.Body > 5000 then
    						writefile(BgFileName, res.Body)
    						if isfile(BgFileName) then loadedAsset = getAsset(BgFileName) end
    					end
    				elseif game.HttpGet then
    					local body = game:HttpGet(BgRawURL)
    					if body and #body > 5000 then
    						writefile(BgFileName, body)
    						if isfile(BgFileName) then loadedAsset = getAsset(BgFileName) end
    					end
    				end
    			end)
    		end

    		if loadedAsset and bgImageLabel and bgImageLabel.Parent then
    			bgImageLabel.Image = loadedAsset
    		end
    	end)
    
    	local function buildParticleShape(shape,size,color)
    		local container = Instance.new("Frame")
    		container.BackgroundTransparency = 1;container.BorderSizePixel = 0;container.ZIndex = 1;container.AnchorPoint = Vector2.new(0.5,0.5)
    		local parts = {}
    		local addPart = function(object,property)
    			table.insert(parts,{object = object, property = property})
    		end
    
    		if shape == "drop" then
    			local w = size*0.8
    			container.Size = UDim2.fromOffset(w,size*1.3)
    			local bulb = Instance.new("Frame",container)
    			bulb.AnchorPoint = Vector2.new(0.5,1);bulb.Position = UDim2.new(0.5,0,1,0);bulb.Size = UDim2.fromOffset(w,w);bulb.BackgroundColor3 = color;bulb.BorderSizePixel = 0;bulb.ZIndex = 1
    			init.create_corner(w,bulb);addPart(bulb,"BackgroundTransparency")
    			local tip = Instance.new("Frame",container)
    			tip.AnchorPoint = Vector2.new(0.5,0.5);tip.Position = UDim2.new(0.5,0,0.32,0);tip.Size = UDim2.fromOffset(w*0.72,w*0.72);tip.Rotation = 45;tip.BackgroundColor3 = color;tip.BorderSizePixel = 0;tip.ZIndex = 1
    			init.create_corner(2,tip);addPart(tip,"BackgroundTransparency")
    
    		elseif shape == "glow" then
    			container.Size = UDim2.fromOffset(size*2.2,size*2.2)
    			local halo = Instance.new("Frame",container)
    			halo.AnchorPoint = Vector2.new(0.5,0.5);halo.Position = UDim2.fromScale(0.5,0.5);halo.Size = UDim2.fromScale(1,1);halo.BackgroundColor3 = color;halo.BackgroundTransparency = 0.65;halo.BorderSizePixel = 0;halo.ZIndex = 1
    			init.create_corner(size,halo);addPart(halo,"BackgroundTransparency")
    			local core = Instance.new("Frame",container)
    			core.AnchorPoint = Vector2.new(0.5,0.5);core.Position = UDim2.fromScale(0.5,0.5);core.Size = UDim2.fromOffset(size,size);core.BackgroundColor3 = Color3.fromRGB(255,240,210);core.BorderSizePixel = 0;core.ZIndex = 1
    			init.create_corner(size,core);addPart(core,"BackgroundTransparency")
    
    		elseif shape == "confetti" then
    			container.Size = UDim2.fromOffset(size*1.4,size*0.7)
    			container.Rotation = math.random(0,360)
    			local rect = Instance.new("Frame",container)
    			rect.Size = UDim2.fromScale(1,1);rect.BackgroundColor3 = color;rect.BorderSizePixel = 0;rect.ZIndex = 1
    			init.create_corner(2,rect);addPart(rect,"BackgroundTransparency")
    
    		elseif shape == "heart" then
    			container.Size = UDim2.fromOffset(size*1.4,size*1.4)
    			local icon = Instance.new("ImageLabel",container)
    			icon.BackgroundTransparency = 1;icon.Size = UDim2.fromScale(1,1);icon.Image = "rbxassetid://86573834471213";icon.ImageColor3 = color;icon.ImageTransparency = 0.3;icon.ScaleType = Enum.ScaleType.Fit;icon.ZIndex = 1
    			addPart(icon,"ImageTransparency")
    
    		elseif shape == "pumpkin" then
    			container.Size = UDim2.fromOffset(size*1.6,size*1.6)
    			local icon = Instance.new("ImageLabel",container)
    			icon.BackgroundTransparency = 1;icon.Size = UDim2.fromScale(1,1);icon.Image = "rbxassetid://110693415684859";icon.ImageColor3 = color;icon.ImageTransparency = 0.35;icon.ScaleType = Enum.ScaleType.Fit;icon.ZIndex = 1
    			addPart(icon,"ImageTransparency")
    
    		else
    			container.Size = UDim2.fromOffset(size,size)
    			local dot = Instance.new("Frame",container)
    			dot.Size = UDim2.fromScale(1,1);dot.BackgroundColor3 = color;dot.BorderSizePixel = 0;dot.ZIndex = 1
    			init.create_corner(size,dot);addPart(dot,"BackgroundTransparency")
    		end
    
    		return container, parts
    	end
    
    	local function spawnFestivalParticles()
    		local festival = init.get_festival()
    		if not festival then return end
    
    		local particleLayer = Instance.new("Frame",main)
    		particleLayer.Name = "@particles";particleLayer.BackgroundTransparency = 1;particleLayer.Size = UDim2.fromScale(1,1)
    		particleLayer.ClipsDescendants = true;particleLayer.ZIndex = 1
    		init.create_corner(10,particleLayer)
    
    		local MAX_PARTICLES = festival.maxOnScreen or 22
    		local active = 0
    
    		local function makeParticle()
    			if active >= MAX_PARTICLES then return end
    			active = active + 1
    
    			local size = math.random(festival.size[1],festival.size[2])
    			local color = math.random() > 0.5 and festival.color or festival.secondaryColor
    			local particle,parts = buildParticleShape(festival.shape,size,color)
    			particle.Parent = particleLayer
    
    			local goingUp = festival.direction == "up"
    			local half = particle.Size.Y.Offset / 2
    			local halfX = particle.Size.X.Offset / 2
    			local layerWidth = math.max(particleLayer.AbsoluteSize.X,1)
    			local insetScaleX = math.clamp(halfX / layerWidth,0,0.5)
    			local minX,maxX = insetScaleX, 1 - insetScaleX
    			local startX = minX + math.random() * (maxX - minX)
    			local startEdge = goingUp and 1 or 0
    			local endEdge = goingUp and 0 or 1
    			local startOffset = goingUp and -half or half
    			local endOffset = goingUp and half or -half
    			particle.Position = UDim2.new(startX,0, startEdge, startOffset)
    
    			local duration = festival.duration[1] + math.random() * (festival.duration[2] - festival.duration[1])
    			local drift = math.random(-200,200) / 1000
    
    			init.tween(particle,duration,Enum.EasingStyle.Linear,{
    				Position = UDim2.new(math.clamp(startX + drift,minX,maxX),0, endEdge, endOffset),
    			})
    			local fadeIn = math.min(duration * 0.25, 0.35)
    			local fadeOut = math.min(duration * 0.25, 0.35)
    			for _,part in parts do
    				local visible = part.object[part.property]
    				part.object[part.property] = 1
    				tween:Create(part.object,TweenInfo.new(fadeIn,Enum.EasingStyle.Linear),{[part.property] = visible}):Play()
    			end
    			task.delay(math.max(duration - fadeOut,fadeIn),function()
    				for _,part in parts do
    					if part.object.Parent then
    						tween:Create(part.object,TweenInfo.new(fadeOut,Enum.EasingStyle.Linear),{[part.property] = 1}):Play()
    					end
    				end
    			end)
    			if festival.shape == "confetti" or festival.shape == "drop" then
    				init.tween(particle,duration,Enum.EasingStyle.Linear,{Rotation = particle.Rotation + math.random(180,540) * (goingUp and -1 or 1)})
    			elseif festival.shape == "pumpkin" then
    				local spinDirection = math.random() > 0.5 and 1 or -1
    				init.tween(particle,duration,Enum.EasingStyle.Linear,{Rotation = particle.Rotation + (60 * spinDirection)})
    			end
    
    			task.delay(duration,function()
    				particle:Destroy()
    				active = active - 1
    			end)
    		end
    
    		task.spawn(function()
    			while sixlyinit.Parent do
    				makeParticle()
    				task.wait(festival.spawnRate)
    			end
    		end)
    	end
    
    	spawnFestivalParticles()
    
    	-- // Top Tab Bar (Concept 2: Sleek Graphite Pill Navigation)
    	local topTabBar = Instance.new("Frame", main)
    	topTabBar.Name = "@topTabBar"
    	topTabBar.BackgroundTransparency = 1
    	topTabBar.Position = UDim2.new(0, 14, 0, 8)
    	topTabBar.Size = UDim2.new(1, -28, 0, 32)
    	topTabBar.ZIndex = 50
    
    	local brandTitle = Instance.new("TextLabel", topTabBar)
    	brandTitle.Name = "BrandTitle"
    	brandTitle.BackgroundTransparency = 1
    	brandTitle.Position = UDim2.new(0, 0, 0, 0)
    	brandTitle.Size = UDim2.new(0, 100, 1, 0)
    	brandTitle.FontFace = Font.fromName("Montserrat", Enum.FontWeight.Heavy, Enum.FontStyle.Normal)
    	brandTitle.Text = "PAYOMBØYZ"
    	brandTitle.TextColor3 = PRIMARY_COLOR
    	brandTitle.TextSize = 13
    	brandTitle.TextXAlignment = Enum.TextXAlignment.Left

    	local brandStroke = Instance.new("UIStroke", brandTitle)
    	brandStroke.Name = "BrandStroke"
    	brandStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
    	brandStroke.Color = Color3.fromRGB(255, 255, 255)
    	brandStroke.Thickness = 1.2
    	brandStroke.Transparency = 0
    
    	local brandDivider = Instance.new("Frame", topTabBar)
    	brandDivider.Name = "BrandDivider"
    	brandDivider.BackgroundColor3 = Color3.fromRGB(48, 50, 58)
    	brandDivider.BorderSizePixel = 0
    	brandDivider.Position = UDim2.new(0, 106, 0.5, -8)
    	brandDivider.Size = UDim2.new(0, 1, 0, 16)
    
    	local tabScroll = Instance.new("ScrollingFrame", topTabBar)
    	tabScroll.Name = "TabScroll"
    	tabScroll.BackgroundTransparency = 1
    	tabScroll.Position = UDim2.new(0, 116, 0, 0)
    	tabScroll.Size = UDim2.new(1, -176, 1, 0)
    	tabScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    	tabScroll.AutomaticCanvasSize = Enum.AutomaticSize.X
    	tabScroll.ScrollBarThickness = 0
    	tabScroll.ScrollingDirection = Enum.ScrollingDirection.X
    
    	local tabListLayout = Instance.new("UIListLayout", tabScroll)
    	tabListLayout.FillDirection = Enum.FillDirection.Horizontal
    	tabListLayout.Padding = UDim.new(0, 6)
    	tabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    	tabListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    
    	local navArrows = Instance.new("Frame", topTabBar)
    	navArrows.Name = "NavArrows"
    	navArrows.BackgroundTransparency = 1
    	navArrows.AnchorPoint = Vector2.new(1, 0.5)
    	navArrows.Position = UDim2.new(1, 0, 0.5, 0)
    	navArrows.Size = UDim2.new(0, 54, 0, 24)
    
    	local prevNavBtn = Instance.new("TextButton", navArrows)
    	prevNavBtn.Name = "PrevBtn"
    	prevNavBtn.BackgroundColor3 = Color3.fromRGB(28, 30, 36)
    	prevNavBtn.Size = UDim2.new(0, 24, 0, 22)
    	prevNavBtn.Position = UDim2.new(0, 0, 0.5, -11)
    	prevNavBtn.Text = "◀"
    	prevNavBtn.TextColor3 = Color3.fromRGB(165, 166, 175)
    	prevNavBtn.TextSize = 10
    	prevNavBtn.FontFace = Font.fromName("Montserrat", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
    	init.create_corner(5, prevNavBtn)
    	init.stroke(prevNavBtn, 0.5, 1, Color3.fromRGB(52, 54, 62))
    
    	local nextNavBtn = Instance.new("TextButton", navArrows)
    	nextNavBtn.Name = "NextBtn"
    	nextNavBtn.BackgroundColor3 = Color3.fromRGB(28, 30, 36)
    	nextNavBtn.Size = UDim2.new(0, 24, 0, 22)
    	nextNavBtn.Position = UDim2.new(0, 28, 0.5, -11)
    	nextNavBtn.Text = "▶"
    	nextNavBtn.TextColor3 = Color3.fromRGB(165, 166, 175)
    	nextNavBtn.TextSize = 10
    	nextNavBtn.FontFace = Font.fromName("Montserrat", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
    	init.create_corner(5, nextNavBtn)
    	init.stroke(nextNavBtn, 0.5, 1, Color3.fromRGB(52, 54, 62))
    
    	local page = Instance.new("Frame",main)
    	page.AnchorPoint = Vector2.new(0,0);page.BackgroundTransparency = 1;page.Position = UDim2.new(0.02,0,0,46);page.Size = UDim2.new(0.96,0,1,-54);page.Name = "@page";page.ZIndex = 5;
    	page.ClipsDescendants = true;
    
    	local setDetailLayout = function(opened,instant)
    		local target = opened and {
    			Position = UDim2.new(0,14,0,46),
    			Size = UDim2.new(1,-320,1,-54)
    		} or {
    			Position = UDim2.new(0.02,0,0,46),
    			Size = UDim2.new(0.96,0,1,-54)
    		}
    		if instant then
    			page.Position = target.Position
    			page.Size = target.Size
    		else
    			init.tween(page,0.25,Enum.EasingStyle.Quint,target)
    		end
    	end
    
    	local uipage = Instance.new("UIPageLayout",page)
    	uipage.Animated = true;uipage.Circular = false;uipage.EasingStyle = Enum.EasingStyle.Cubic;uipage.TweenTime = 0.45;
    	uipage.SortOrder = Enum.SortOrder.LayoutOrder;
    
    	prevNavBtn.MouseButton1Click:Connect(function()
    		uipage:Previous()
    	end)
    
    	nextNavBtn.MouseButton1Click:Connect(function()
    		uipage:Next()
    	end)
    
    	local tabPills = {}
    	local function updateTabStyles(activeIndex)
    		for idx, item in ipairs(tabPills) do
    			local targetIndex = (item.Index ~= nil) and item.Index or (idx - 1)
    			local isActive = (targetIndex == activeIndex)
    			local bgCol = isActive and Color3.fromRGB(42, 43, 48) or Color3.fromRGB(26, 28, 34)
    			local textCol = isActive and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(155, 156, 166)
    			local strokeCol = isActive and PRIMARY_COLOR or Color3.fromRGB(52, 54, 62)
    			local strokeTrans = isActive and 0 or 0.6
    			init.tween(item.Button, 0.15, Enum.EasingStyle.Circular, {BackgroundColor3 = bgCol})
    			init.tween(item.Label, 0.15, Enum.EasingStyle.Circular, {TextColor3 = textCol})
    			init.tween(item.Stroke, 0.15, Enum.EasingStyle.Circular, {Color = strokeCol, Transparency = strokeTrans})
    		end
    	end
    
    	uipage:GetPropertyChangedSignal("CurrentPage"):Connect(function()
    		if uipage.CurrentPage then
    			updateTabStyles(uipage.CurrentPage.LayoutOrder)
    		end
    	end)
    
    	--// folder components
    
    	local components = Instance.new("Folder",main)
    
    	local shadow = Instance.new("TextButton",components);shadow.AutoButtonColor = false;shadow.TextTransparency = 1;shadow.ZIndex = 0
    	shadow.AnchorPoint = Vector2.new(0.5,0.5);shadow.BackgroundColor3 = Color3.fromRGB(0,0,0);shadow.BackgroundTransparency = 1;shadow.Position = UDim2.new(0.5,0,0.5,0);shadow.Size = UDim2.new(1,0,1,0)
    	init.create_corner(10,shadow)
    
    	local uilist_shadow = Instance.new("UIListLayout",shadow)
    	uilist_shadow.Padding = UDim.new(0,10)
    
    	local uipadding_shadow = Instance.new("UIPadding",shadow)
    	uipadding_shadow.PaddingLeft = UDim.new(0,18);uipadding_shadow.PaddingTop = UDim.new(0,25)
    
    	shadow.MouseButton1Click:Connect(function()
    		init.tween(shadow,0.25,Enum.EasingStyle.Circular,{BackgroundTransparency = 1})
    		for i,v in shadow:GetChildren() do
    			if v:IsA("Frame") then
    				init.tween(v,0.25,Enum.EasingStyle.Circular,{BackgroundTransparency = 1})
    				init.tween(v:FindFirstChildOfClass("UIStroke"),0.25,Enum.EasingStyle.Circular,{Transparency = 1})
    				init.tween(v:FindFirstChildOfClass("ImageLabel"),0.25,Enum.EasingStyle.Circular,{ImageTransparency = 1})
    				for i,v in v:GetChildren() do
    					if v:IsA("TextLabel") then
    						init.tween(v,0.25,Enum.EasingStyle.Circular,{TextTransparency = 1})
    					end
    				end
    			end
    		end
    		repeat task.wait() until shadow.BackgroundTransparency >= 1
    		shadow.ZIndex = 0
    		repeat task.wait() until shadow.ZIndex == 0
    		for i,v in shadow:GetChildren() do
    			if v:IsA("Frame") then
    				v:Destroy()
    			end
    		end
    	end)
    
    	-- // left
    
    	local left_click = Instance.new("Frame",main);
    	left_click.Position = UDim2.new(0,0,0.5,0);left_click.BackgroundTransparency = 1;left_click.Size = UDim2.new(0,30,1,0);left_click.AnchorPoint = Vector2.new(0,0.5);
    
    	local uigradient_left = Instance.new("UIGradient",left_click)
    	uigradient_left.Transparency = NumberSequence.new(0,1);uigradient_left.Color = ColorSequence.new(Color3.fromRGB(0,0,0));
    	init.create_corner(10,left_click)
    
    	local left_arrow = Instance.new("ImageLabel",left_click)
    	left_arrow.AnchorPoint = Vector2.new(0.5,0,0.5,0);left_arrow.BackgroundTransparency = 1;left_arrow.Image = "rbxassetid://110736687176185"
    	left_arrow.Position = UDim2.new(0.5,0,0.5,0);left_arrow.Size = UDim2.new(0,35,0,35);left_arrow.ImageTransparency = 1;
    
    	local left_btn = Instance.new("TextButton",left_click)
    	left_btn.AnchorPoint = Vector2.new(0.5,0.5);left_btn.AutoButtonColor = false;left_btn.BackgroundTransparency = 1;left_btn.TextTransparency = 1;left_btn.Position = UDim2.new(0.5,0,0.5,0)
    	left_btn.Size = UDim2.new(1,0,1,0)
    
    	-- // right
    
    	local right_click = Instance.new("Frame",main);
    	right_click.Position = UDim2.new(1,0,0.5,0);right_click.BackgroundTransparency = 1;right_click.Size = UDim2.new(0,30,1,0);right_click.AnchorPoint = Vector2.new(1,0.5);
    
    	local uigradient_right = Instance.new("UIGradient",right_click)
    	uigradient_right.Transparency = NumberSequence.new(1,0);uigradient_right.Color = ColorSequence.new(Color3.fromRGB(0,0,0));
    	init.create_corner(10,right_click)
    
    	local right_arrow = Instance.new("ImageLabel",right_click)
    	right_arrow.AnchorPoint = Vector2.new(0.5,0,0.5,0);right_arrow.BackgroundTransparency = 1;right_arrow.Image = "rbxassetid://110736687176185";
    	right_arrow.Position = UDim2.new(0.5,0,0.5,0);right_arrow.Size = UDim2.new(0,35,0,35);right_arrow.ImageTransparency = 1;right_arrow.Rotation = 180
    
    	local right_btn = Instance.new("TextButton",right_click)
    	right_btn.AnchorPoint = Vector2.new(0.5,0.5);right_btn.AutoButtonColor = false;right_btn.BackgroundTransparency = 1;right_btn.TextTransparency = 1;right_btn.Position = UDim2.new(0.5,0,0.5,0)
    	right_btn.Size = UDim2.new(1,0,1,0)
    
    	-- // next - prev : page
    
    	left_click.MouseEnter:Connect(function()
    		init.tween(left_click,0.25,Enum.EasingStyle.Circular,{BackgroundTransparency = 0})
    		init.tween(left_arrow,0.25,Enum.EasingStyle.Circular,{ImageTransparency = 0})
    	end)
    
    	left_click.MouseLeave:Connect(function()
    		init.tween(left_click,0.25,Enum.EasingStyle.Circular,{BackgroundTransparency = 1})
    		init.tween(left_arrow,0.25,Enum.EasingStyle.Circular,{ImageTransparency = 1})
    	end)
    
    	left_btn.MouseButton1Click:Connect(function()
    		uipage:Previous()
    	end)
    
    	right_click.MouseEnter:Connect(function()
    		init.tween(right_click,0.25,Enum.EasingStyle.Circular,{BackgroundTransparency = 0})
    		init.tween(right_arrow,0.25,Enum.EasingStyle.Circular,{ImageTransparency = 0})
    	end)
    
    	right_click.MouseLeave:Connect(function()
    		init.tween(right_click,0.25,Enum.EasingStyle.Circular,{BackgroundTransparency = 1})
    		init.tween(right_arrow,0.25,Enum.EasingStyle.Circular,{ImageTransparency = 1})
    	end)
    
    	right_btn.MouseButton1Click:Connect(function()
    		uipage:Next()
    	end)
    
    	-- // draggable
    
    	local d1,d2 = false,true
    	local makeDraggable = function(topBarObject, object)
    		local dragging = nil
    		local dragInput = nil
    		local dragStart = nil
    		local startPosition = nil
    		topBarObject.InputBegan:Connect(function(input)
    			if input.UserInputType == Enum.UserInputType.MouseButton1 then
    				dragging = true
    				dragStart = input.Position
    				startPosition = object.Position
    				input.Changed:Connect(function()
    					if input.UserInputState == Enum.UserInputState.End then
    						dragging = false
    					end
    				end)
    			end
    		end)
    		topBarObject.InputChanged:Connect(function(input)
    			if input.UserInputType == Enum.UserInputType.MouseMovement then
    				dragInput = input
    			end
    		end)
    		userinputservice.InputChanged:Connect(function(input)
    			if input == dragInput and dragging and not asset["sl-focus"] then
    				local delta = input.Position - dragStart
    				if not d1 and d2 then
    					init.tween(object,0.25,Enum.EasingStyle.Back,{Position = UDim2.new(startPosition.X.Scale, startPosition.X.Offset + delta.X, startPosition.Y.Scale, startPosition.Y.Offset + delta.Y)})
    				elseif not d1 and not d2 then
    					object.Position = UDim2.new(startPosition.X.Scale, startPosition.X.Offset + delta.X, startPosition.Y.Scale, startPosition.Y.Offset + delta.Y)
    				end
    			end
    		end)
    	end
    
    	makeDraggable(shadow,main)
    
    	-- // resizable from the bottom-right corner
    
    	local resizeHandle = Instance.new("TextButton", main)
    	resizeHandle.Name = "@resize";resizeHandle.AnchorPoint = Vector2.new(1, 1);resizeHandle.Position = UDim2.new(1, -4, 1, -4)
    	resizeHandle.Size = UDim2.fromOffset(26, 26);resizeHandle.BackgroundTransparency = 1;resizeHandle.AutoButtonColor = false
    	resizeHandle.Text = "";resizeHandle.ZIndex = 250
    
    	local resizeIconColor = Color3.fromRGB(125, 126, 136)
    	local resizeIcon = Instance.new("ImageLabel", resizeHandle)
    	resizeIcon.AnchorPoint = Vector2.new(0.5, 0.5);resizeIcon.Position = UDim2.fromScale(0.5, 0.5);resizeIcon.Size = UDim2.fromOffset(20, 20)
    	resizeIcon.BackgroundTransparency = 1;resizeIcon.Image = "rbxassetid://108276481377469";resizeIcon.ImageColor3 = resizeIconColor;resizeIcon.ZIndex = resizeHandle.ZIndex + 1
    
    	local resizing = false
    	local resizeStart = nil
    	local startSize = nil
    	local startTopLeft = nil
    	local MIN_SIZE = Vector2.new(525, 330)
    	local VIEWPORT_MARGIN = 20
    	
    	local setResizeIconColor = function(color)
    		init.tween(resizeIcon, 0.15, Enum.EasingStyle.Circular, {ImageColor3 = color})
    	end
    
    	resizeHandle.MouseEnter:Connect(function()
    		setResizeIconColor(Color3.fromRGB(255, 255, 255))
    	end)
    
    	resizeHandle.MouseLeave:Connect(function()
    		if not resizing then
    			setResizeIconColor(resizeIconColor)
    		end
    	end)
    
    	resizeHandle.InputBegan:Connect(function(input)
    		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
    			resizing = true
    			resizeStart = input.Position
    			startSize = main.AbsoluteSize
    			startTopLeft = main.AbsolutePosition
    			if main.AnchorPoint ~= Vector2.new(0, 0) then
    				main.AnchorPoint = Vector2.new(0, 0);main.Position = UDim2.fromOffset(startTopLeft.X, startTopLeft.Y)
    			end
    
    			input.Changed:Connect(function()
    				if input.UserInputState == Enum.UserInputState.End then
    					resizing = false
    					setResizeIconColor(resizeIconColor)
    				end
    			end)
    		end
    	end)
    
    	userinputservice.InputChanged:Connect(function(input)
    		if not resizing then return end
    		if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then return end
    
    		local currentViewport = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or viewport
    		local maxWidth = math.max(MIN_SIZE.X, currentViewport.X - startTopLeft.X - VIEWPORT_MARGIN)
    		local maxHeight = math.max(MIN_SIZE.Y, currentViewport.Y - startTopLeft.Y - VIEWPORT_MARGIN)
    		local minWidth = MIN_SIZE.X
    		local minHeight = MIN_SIZE.Y
    		local delta = input.Position - resizeStart
    		local width = math.clamp(startSize.X + delta.X, minWidth, maxWidth)
    		local height = math.clamp(startSize.Y + delta.Y, minHeight, maxHeight)
    
    		main.Size = UDim2.fromOffset(width, height)
    	end)
    
    	local components_ui = {}
    
    	function components_ui.Info(arr)
    
    		local data = {
    			title = arr.Title or "Mockup",
    			desc = arr.Desc or "Mockup Description"
    		}
    
    		local info_frame = Instance.new("Frame",shadow)
    		info_frame.BackgroundColor3 = Color3.fromRGB(42,43,48);info_frame.Size = UDim2.new(0,0,0,100);info_frame.ClipsDescendants = true
    		init.tween(info_frame,0.25,Enum.EasingStyle.Circular,{Size = UDim2.new(0,411,0,100)});info_frame.ZIndex = 9
    		init.create_corner(8,info_frame)
    		init.stroke(info_frame,0,1,Color3.fromRGB(79,79,79))
    
    		local info_title = Instance.new("TextLabel",info_frame);
    		info_title.BackgroundTransparency = 1;info_title.Position = UDim2.new(0.1,0,0.08,0);info_title.Size = UDim2.new(0,333,0,29);
    		info_title.FontFace = Font.fromName("Montserrat",Enum.FontWeight.Bold,Enum.FontStyle.Normal);info_title.TextColor3 = Color3.fromRGB(255,255,255)
    		info_title.ZIndex = 10;info_title.TextXAlignment = Enum.TextXAlignment.Left;info_title.TextSize = 14;info_title.Text = data.title
    
    		local info_desc = Instance.new("TextLabel",info_frame);
    		info_desc.BackgroundTransparency = 1;info_desc.Position = UDim2.new(0.027,0,0.43,0);info_desc.Size = UDim2.new(0,382,0,52);
    		info_desc.FontFace = Font.fromName("Montserrat",Enum.FontWeight.Regular,Enum.FontStyle.Normal);info_desc.TextColor3 = Color3.fromRGB(255,255,255)
    		info_desc.ZIndex = 10;info_desc.TextXAlignment = Enum.TextXAlignment.Left;info_desc.TextSize = 12;info_desc.TextTransparency = 0.3;info_desc.TextYAlignment = Enum.TextYAlignment.Top
    		info_desc.Text = data.desc
    
    		local info_icon = Instance.new("ImageLabel",info_frame)
    		info_icon.AnchorPoint = Vector2.new(0.5,0.5);info_icon.BackgroundTransparency = 1;info_icon.Position = UDim2.new(0.046,0,0.21,0);info_icon.Size = UDim2.new(0,25,0,25);
    		info_icon.Image = "rbxassetid://122981459568597";info_icon.ZIndex = 10
    	end
    
    	local activeDetailClose = nil
    	local tabs = {}
	tabs.Main = main
	tabs.ScreenGui = sixlyinit
    	function tabs.create(tabTitle, tabTitle2)
		if type(tabTitle) == "table" and tabTitle == tabs then tabTitle = tabTitle2 end
    		asset["index"] = asset["index"] + 1
    		local tabIndex = asset["index"]
    		local str_random = Random.new():NextInteger(1,999999)
    
    		local pillBtn = Instance.new("TextButton", tabScroll)
    		pillBtn.Name = "TabPill_" .. tabIndex
    		pillBtn.LayoutOrder = tabIndex
    		pillBtn.Size = UDim2.new(0, 0, 0, 24)
    		pillBtn.AutomaticSize = Enum.AutomaticSize.X
    		pillBtn.BackgroundColor3 = (tabIndex == 0) and Color3.fromRGB(42, 43, 48) or Color3.fromRGB(26, 28, 34)
    		pillBtn.AutoButtonColor = false
    		pillBtn.Text = ""
    		pillBtn.ZIndex = 52
    		init.create_corner(6, pillBtn)
    
    		local pillPadding = Instance.new("UIPadding", pillBtn)
    		pillPadding.PaddingLeft = UDim.new(0, 10); pillPadding.PaddingRight = UDim.new(0, 10)
    
    		local pillStroke = init.stroke(pillBtn, (tabIndex == 0) and 0 or 0.6, 1, (tabIndex == 0) and PRIMARY_COLOR or Color3.fromRGB(52, 54, 62))
    
    		local initialLabel = tabTitle or ("Tab " .. (tabIndex + 1))
    		local pillLabel = Instance.new("TextLabel", pillBtn)
    		pillLabel.Name = "Label"
    		pillLabel.BackgroundTransparency = 1
    		pillLabel.Size = UDim2.new(0, 0, 1, 0)
    		pillLabel.AutomaticSize = Enum.AutomaticSize.X
    		pillLabel.Text = initialLabel
    		pillLabel.TextColor3 = (tabIndex == 0) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(155, 156, 166)
    		pillLabel.TextSize = 11
    		pillLabel.FontFace = Font.fromName("Montserrat", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
    		pillLabel.ZIndex = 53
    
    		local pillData = {
    			Button = pillBtn,
    			Label = pillLabel,
    			Stroke = pillStroke,
    			Index = tabIndex,
    			CustomSet = (tabTitle ~= nil and tabTitle ~= "")
    		}
    		table.insert(tabPills, pillData)
    
    		pillBtn.MouseEnter:Connect(function()
    			if uipage.CurrentPage and uipage.CurrentPage.LayoutOrder ~= tabIndex then
    				init.tween(pillBtn, 0.15, Enum.EasingStyle.Circular, {BackgroundColor3 = Color3.fromRGB(34, 36, 44)})
    				init.tween(pillLabel, 0.15, Enum.EasingStyle.Circular, {TextColor3 = Color3.fromRGB(220, 222, 230)})
    			end
    		end)
    
    		pillBtn.MouseLeave:Connect(function()
    			if uipage.CurrentPage and uipage.CurrentPage.LayoutOrder ~= tabIndex then
    				init.tween(pillBtn, 0.15, Enum.EasingStyle.Circular, {BackgroundColor3 = Color3.fromRGB(26, 28, 34)})
    				init.tween(pillLabel, 0.15, Enum.EasingStyle.Circular, {TextColor3 = Color3.fromRGB(155, 156, 166)})
    			end
    		end)
    
    		local container = Instance.new("ScrollingFrame",page)
    		container.BackgroundTransparency = 1;container.Size = UDim2.new(1,0,1,0);container.CanvasSize = UDim2.new(0,0,0,0);container.ScrollBarThickness = 0;
    		container.AutomaticCanvasSize = Enum.AutomaticSize.Y;container.ScrollingDirection = Enum.ScrollingDirection.Y
    		container.LayoutOrder = tabIndex;container.Name = "@container_"..tabIndex
    
    		local sectionList = Instance.new("UIListLayout",container)
    		sectionList.SortOrder = Enum.SortOrder.LayoutOrder;sectionList.Padding = UDim.new(0,12)
    
    		local uipadding = Instance.new("UIPadding",container)
    		uipadding.PaddingTop = UDim.new(0,10);
    
    		pillBtn.MouseButton1Click:Connect(function()
    			uipage:JumpTo(container)
    			updateTabStyles(tabIndex)
    		end)
    
    		if asset["first-executed"] then
    			asset["first-executed"] = false
    			asset["index-focus"] = tabIndex
    			task.defer(function()
    				pcall(function()
    					uipage:JumpTo(container)
    					updateTabStyles(tabIndex)
    				end)
    			end)
    		end
    
    		local func = {}
    		local currentContent = nil
    		local currentAddCard = nil
    		local sectionOrder = 0
    		local createSection = function(title,showHeader)
    			sectionOrder = sectionOrder + 1
    			local section = Instance.new("Frame",container)
    			section.Name = "@section_"..sectionOrder;section.BackgroundTransparency = 1;section.BorderSizePixel = 0
    			section.Size = UDim2.new(1,-4,0,showHeader and 130 or 100);section.LayoutOrder = sectionOrder
    			-- Leave enough breathing room between the section title and its cards.
    			local headerHeight = showHeader and 38 or 0
    			if showHeader then
    				local header = Instance.new("TextLabel",section)
    				header.Name = "@header";header.BackgroundTransparency = 1;header.Size = UDim2.new(1,0,0,24)
    				header.FontFace = Font.fromName("Montserrat",Enum.FontWeight.SemiBold,Enum.FontStyle.Normal)
    				header.Text = tostring(title or "Section");header.TextColor3 = Color3.fromRGB(225,226,230);header.TextSize = 13
    				header.TextXAlignment = Enum.TextXAlignment.Left
    			end
    			local content = Instance.new("Frame",section)
    			content.Name = "@content";content.BackgroundTransparency = 1;content.BorderSizePixel = 0
    			content.Position = UDim2.new(0,2,0,headerHeight);content.Size = UDim2.new(1,-8,0,100)
    
    			-- // Cards no longer share a fixed UIGridLayout cell size: each card sizes
    			-- // itself (width grows only if its own title needs it, height grows to
    			-- // fit wrapped text) and cards flow/wrap like a flexbox row.
    			local CARD_PADDING = 15
    			local cards = {}
    			local layoutCards = function()
    				local availWidth = content.AbsoluteSize.X
    				if availWidth <= 0 then return end
    				local x,y,rowHeight,first = 0,0,0,true
    				for _,card in ipairs(cards) do
    					local width = card.Size.X.Offset
    					if not first and (x + width) > availWidth then
    						x = 0;y = y + rowHeight + CARD_PADDING;rowHeight = 0
    					end
    					card.Position = UDim2.new(0,x,0,y)
    					rowHeight = math.max(rowHeight,card.Size.Y.Offset)
    					x = x + width + CARD_PADDING
    					first = false
    				end
    				local totalHeight = y + rowHeight
    				content.Size = UDim2.new(1,0,0,totalHeight)
    				section.Size = UDim2.new(1,-4,0,headerHeight + totalHeight)
    			end
    			content:GetPropertyChangedSignal("AbsoluteSize"):Connect(layoutCards)
    			task.defer(layoutCards)
    
    			currentContent = content
    			currentAddCard = function(card)
    				card.AnchorPoint = Vector2.new(0,0)
    				table.insert(cards,card)
    				layoutCards()
    			end
    			return content
    		end
    
    		function func.Header(arr)
    			arr = type(arr) == "table" and arr or {Title = arr}
    			local hTitle = arr.Title or arr.Name
    			if not pillData.CustomSet and hTitle and not string.find(string.lower(hTitle), "edited") then
    				local cleanTabTitle = tostring(hTitle):gsub("%s*%(%d+/%d+%)%s*", ""):gsub("^%s+", ""):gsub("%s+$", "")
    				if cleanTabTitle ~= "" then
    					pillLabel.Text = cleanTabTitle
    					pillData.CustomSet = true
    				end
    			end
    			createSection(hTitle,true)
    			return func
    		end
    
    		function func.Toggle(arr, off)
    			if not currentContent then createSection(nil,false) end
    			local realcallback = function(args)
    				if not off then
    					if arr.Title and getgenv().configs[arr.Title] ~= nil then 
    						getgenv().configs[arr.Title] = args
    					end
    				end
    				if arr.Callback then
    					arr.Callback(args)
    				end
    			end
    
    			local configuredDefault = arr.Title and getgenv().configs[arr.Title]
    			local resolvedDefault
    			if arr.Default ~= nil then
    				resolvedDefault = arr.Default
    			elseif not off and configuredDefault ~= nil then
    				resolvedDefault = configuredDefault
    			else
    				resolvedDefault = false
    			end
    
    			local data = {
    				title = arr.Title or tostring("Toggle"),
    				desc = arr.Info or tostring("Click to view controls"),
    				callback = realcallback or function() end,
    				default = resolvedDefault,
    			}
    
    			-- // HasToggle = false: card shows just the title (no on/off switch), but
    			-- // clicking it still opens the detail drawer normally.
    			local hasToggle = arr.HasToggle ~= false
    
    			local box_frame = Instance.new("Frame",currentContent)
    			box_frame.BackgroundTransparency = 0;box_frame.BackgroundColor3 = Color3.fromRGB(42, 43, 48);
    			init.create_corner(4,box_frame)
    			local cardStroke = init.stroke(box_frame,0.45,1,Color3.fromRGB(66,67,74))
    
    			local box_btn = Instance.new("TextButton",box_frame);
    			box_btn.BackgroundTransparency = 1;box_btn.TextTransparency = 1;box_btn.AutoButtonColor = false;
    			box_btn.Size = UDim2.new(1,0,1,0);box_btn.AnchorPoint = Vector2.new(0.5,0.5);box_btn.Position = UDim2.new(0.5,0,0.5,0);box_btn.ZIndex = 8
    
    			-- // Card only widens if its own title can't fit on one line at the base
    			-- // width; short titles stay at the normal 155px card size. If a title is
    			-- // still too long once capped at the max width, it wraps (grows height instead).
    			local CARD_MIN_WIDTH,CARD_MAX_WIDTH = 155,260
    			local titleFont = Font.fromName("Montserrat",Enum.FontWeight.SemiBold,Enum.FontStyle.Normal)
    			local titleTextSize = 12
    			local textService = game:GetService("TextService")
    
    			local measureText = function(text,width)
    				local ok,bounds = pcall(function()
    					local params = Instance.new("GetTextBoundsParams")
    					params.Text = text;params.Size = titleTextSize;params.Font = titleFont;params.Width = width
    					return textService:GetTextBoundsAsync(params)
    				end)
    				return ok and bounds or nil
    			end
    
    			local titleSizeOffset = hasToggle and 64 or 24
    			local titleReservedWidth = titleSizeOffset + 12
    			local naturalBounds = measureText(data.title,10000)
    			local naturalWidth = naturalBounds and math.ceil(naturalBounds.X) or 0
    			local cardWidth = math.clamp(naturalWidth + titleReservedWidth,CARD_MIN_WIDTH,CARD_MAX_WIDTH)
    
    			local titleTextWidth = cardWidth - titleReservedWidth
    			local titleHeight = 22
    			local wrappedBounds = measureText(data.title,titleTextWidth)
    			if wrappedBounds then titleHeight = math.max(22,math.ceil(wrappedBounds.Y)) end
    
    			local title = Instance.new("TextLabel",box_frame);
    			title.BackgroundTransparency = 1;title.Position = UDim2.new(0,12,0,12);title.Size = UDim2.new(1,-titleSizeOffset,0,titleHeight);
    			title.FontFace = titleFont;title.Text = data.title;title.TextSize = titleTextSize;title.TextColor3 = Color3.fromRGB(255,255,255);
    			title.TextXAlignment = Enum.TextXAlignment.Left;title.TextWrapped = true;title.TextTruncate = Enum.TextTruncate.None;title.ZIndex = 9
    
    			local descriptionTop = 12 + titleHeight + 6
    			local descriptionHeight = 42
    			local description = Instance.new("TextLabel",box_frame)
    			description.BackgroundTransparency = 1;description.Position = UDim2.new(0,12,0,descriptionTop);description.Size = UDim2.new(1,-24,0,descriptionHeight)
    			description.FontFace = Font.fromName("Montserrat",Enum.FontWeight.Regular,Enum.FontStyle.Normal);description.Text = data.desc;description.TextSize = 10;description.TextColor3 = Color3.fromRGB(172,173,180)
    			description.TextXAlignment = Enum.TextXAlignment.Left;description.TextYAlignment = Enum.TextYAlignment.Top;description.TextWrapped = true;description.ZIndex = 9
    
    			local cardHeight = math.max(100,descriptionTop + descriptionHeight + 12)
    			box_frame.Size = UDim2.new(0,cardWidth,0,cardHeight)
    			if currentAddCard then currentAddCard(box_frame) end
    
    			local toggle,circle,toggleButton = nil,nil,nil
    			if hasToggle then
    				toggle = Instance.new("Frame",box_frame)
    				toggle.BackgroundColor3 = Color3.fromRGB(47,48,54);toggle.Position = UDim2.new(1,-12,0,13);toggle.AnchorPoint = Vector2.new(1,0);toggle.Size = UDim2.new(0,36,0,20);toggle.ZIndex = 10
    				init.create_corner(30,toggle)
    				init.stroke(toggle,0,1,Color3.fromRGB(71,71,71))
    
    				circle = Instance.new("Frame",toggle)
    				circle.AnchorPoint = Vector2.new(0.5,0.5);circle.BackgroundTransparency = 0;circle.Position = UDim2.new(0.25,0,0.5,0);circle.Size = UDim2.new(0,12,0,12);circle.BackgroundColor3 = Color3.fromRGB(255,255,255);circle.ZIndex = 11
    				init.create_corner(30,circle)
    
    				toggleButton = Instance.new("TextButton",toggle)
    				toggleButton.Size = UDim2.fromScale(1,1);toggleButton.BackgroundTransparency = 1;toggleButton.AutoButtonColor = false;toggleButton.Text = "";toggleButton.ZIndex = 12
    			end
    			local toggle_focus = false
    			local toggle_funcs = {}
    			local info_focus = false
    
    			-- // detail panel (slides in from the right)
    
    			-- Clip only the drawer animation at the main window bounds.
    			local drawerClip = Instance.new("Frame",main)
    			drawerClip.Name = "@drawer_clip";drawerClip.Size = UDim2.fromScale(1,1);drawerClip.BackgroundTransparency = 1;drawerClip.BorderSizePixel = 0;drawerClip.ClipsDescendants = true;drawerClip.ZIndex = 198
    
    			local detailPanel = Instance.new("Frame",drawerClip)
    			detailPanel.Name = "@detail_"..Random.new():NextInteger(1,999999);detailPanel.AnchorPoint = Vector2.new(1,0);detailPanel.BackgroundColor3 = Color3.fromRGB(26,25,29);detailPanel.BorderSizePixel = 0;detailPanel.Position = UDim2.new(1,300,0,0);detailPanel.Size = UDim2.new(0,290,1,0);detailPanel.Visible = false;detailPanel.ClipsDescendants = true;detailPanel.ZIndex = 200
    			init.create_corner(10,detailPanel)
    
    			-- Keep the drawer's left edge square while retaining the rounded right edge.
    			local bottomLeftPatch = Instance.new("Frame",detailPanel)
    			bottomLeftPatch.AnchorPoint = Vector2.new(0,1);bottomLeftPatch.Position = UDim2.new(0,0,1,0);bottomLeftPatch.Size = UDim2.fromOffset(10,10);bottomLeftPatch.BackgroundColor3 = detailPanel.BackgroundColor3;bottomLeftPatch.BorderSizePixel = 0;bottomLeftPatch.ZIndex = 203
    
    			local drawerShadow = Instance.new("Frame",detailPanel)
    			drawerShadow.AnchorPoint = Vector2.new(0,0);drawerShadow.Position = UDim2.fromOffset(0,0);drawerShadow.Size = UDim2.new(0,18,1,0);drawerShadow.BackgroundColor3 = Color3.fromRGB(0,0,0);drawerShadow.BackgroundTransparency = 0.35;drawerShadow.BorderSizePixel = 0;drawerShadow.ZIndex = 199
    			local drawerGradient = Instance.new("UIGradient",drawerShadow)
    			drawerGradient.Transparency = NumberSequence.new({
    				NumberSequenceKeypoint.new(0,1),
    				NumberSequenceKeypoint.new(1,0)
    			})
    
    			local leftDivider = Instance.new("Frame",detailPanel)
    			leftDivider.Name = "@left_divider";leftDivider.AnchorPoint = Vector2.new(0,0.5);leftDivider.Position = UDim2.new(0,0,0.5,0)
    			leftDivider.Size = UDim2.new(0,1,1,0);leftDivider.BackgroundColor3 = Color3.fromRGB(66,67,74);leftDivider.BackgroundTransparency = 0.25;leftDivider.BorderSizePixel = 0;leftDivider.ZIndex = 204
    
    			local detailHeader = Instance.new("Frame",detailPanel)
    			detailHeader.BackgroundColor3 = Color3.fromRGB(20,20,23);detailHeader.BorderSizePixel = 0;detailHeader.Size = UDim2.new(1,0,0,52);detailHeader.ZIndex = 201
    			init.create_corner(10,detailHeader)
    
    			local squareHeaderCorner = function(position,anchor)
    				local patch = Instance.new("Frame",detailHeader)
    				patch.AnchorPoint = anchor;patch.Position = position;patch.Size = UDim2.fromOffset(10,10);patch.BackgroundColor3 = detailHeader.BackgroundColor3;patch.BorderSizePixel = 0;patch.ZIndex = 202
    			end
    			-- Only the top-right corner of the header should remain rounded.
    			squareHeaderCorner(UDim2.new(0,0,0,0),Vector2.new(0,0))
    			squareHeaderCorner(UDim2.new(0,0,1,0),Vector2.new(0,1))
    			squareHeaderCorner(UDim2.new(1,0,1,0),Vector2.new(1,1))
    
    			local backButton = Instance.new("TextButton",detailHeader)
    			backButton.AnchorPoint = Vector2.new(0,0.5);backButton.Position = UDim2.new(0,14,0.5,0);backButton.Size = UDim2.fromOffset(30,30);backButton.BackgroundColor3 = Color3.fromRGB(42,43,48);backButton.BorderSizePixel = 0;backButton.AutoButtonColor = false;backButton.Text = "<";backButton.TextColor3 = Color3.fromRGB(220,221,222);backButton.TextSize = 16;backButton.Font = Enum.Font.GothamBold;backButton.ZIndex = 202;backButton.Visible = false
    			init.create_corner(6,backButton)
    
    			local detailTitle = Instance.new("TextLabel",detailHeader)
    			detailTitle.BackgroundTransparency = 1;detailTitle.Position = UDim2.new(0,14,0,0);detailTitle.Size = UDim2.new(1,-60,1,0);detailTitle.FontFace = Font.fromName("Montserrat",Enum.FontWeight.SemiBold,Enum.FontStyle.Normal);detailTitle.Text = data.title;detailTitle.TextColor3 = Color3.fromRGB(255,255,255);detailTitle.TextSize = 13;detailTitle.TextXAlignment = Enum.TextXAlignment.Left;detailTitle.ZIndex = 202
    
    			local detailContent = Instance.new("ScrollingFrame",detailPanel)
    			detailContent.Name = "@content";detailContent.BackgroundTransparency = 1;detailContent.BorderSizePixel = 0;detailContent.Position = UDim2.fromOffset(0,52);detailContent.Size = UDim2.new(1,0,1,-52);detailContent.CanvasSize = UDim2.fromOffset(0,0);detailContent.AutomaticCanvasSize = Enum.AutomaticSize.Y;detailContent.ScrollingDirection = Enum.ScrollingDirection.Y;detailContent.ScrollBarThickness = 3;detailContent.ZIndex = 201
    
    			local detailPadding = Instance.new("UIPadding",detailContent)
    			detailPadding.PaddingTop = UDim.new(0,10);detailPadding.PaddingBottom = UDim.new(0,10);detailPadding.PaddingLeft = UDim.new(0,14);detailPadding.PaddingRight = UDim.new(0,14)
    
    			local detailLayout = Instance.new("UIListLayout",detailContent)
    			detailLayout.Padding = UDim.new(0,6);detailLayout.SortOrder = Enum.SortOrder.LayoutOrder
    
    			local detailOpened = false
    			local detailAnimation = 0
    			local detailClosers = {}
    			local detailCallbackLoaded = false
    			local closeDetail
    			local openDetail = function()
    				if detailOpened then return end
    				if activeDetailClose and activeDetailClose ~= closeDetail then
    					activeDetailClose(true,true)
    				end
    				detailOpened = true
    				activeDetailClose = closeDetail
    				detailAnimation = detailAnimation + 1
    				detailPanel.Position = UDim2.new(1,300,0,0)
    				detailPanel.Visible = true
    				setDetailLayout(true,false)
    				init.tween(cardStroke,0.2,Enum.EasingStyle.Circular,{Color = PRIMARY_COLOR,Transparency = 0})
    				init.tween(box_frame,0.2,Enum.EasingStyle.Circular,{BackgroundColor3 = Color3.fromRGB(49,50,57)})
    				init.tween(detailPanel,0.3,Enum.EasingStyle.Quint,{Position = UDim2.new(1,0,0,0)})
    				if arr.MoreCallback and not detailCallbackLoaded then
    					detailCallbackLoaded = true
    					task.spawn(arr.MoreCallback,toggle_funcs)
    				end
    			end
    
    			closeDetail = function(immediate,keepInspectorSpace)
    				if not detailOpened then return end
    				for _,closer in detailClosers do closer() end
    				detailOpened = false
    				if activeDetailClose == closeDetail then activeDetailClose = nil end
    				detailAnimation = detailAnimation + 1
    				local closingId = detailAnimation
    				init.tween(cardStroke,0.2,Enum.EasingStyle.Circular,{Color = Color3.fromRGB(66,67,74),Transparency = 0.45})
    				init.tween(box_frame,0.2,Enum.EasingStyle.Circular,{BackgroundColor3 = Color3.fromRGB(42,43,48)})
    				if not keepInspectorSpace then setDetailLayout(false,immediate) end
    				if immediate then
    					detailPanel.Position = UDim2.new(1,300,0,0)
    					detailPanel.Visible = false
    					return
    				end
    				init.tween(detailPanel,0.3,Enum.EasingStyle.Quint,{Position = UDim2.new(1,300,0,0)})
    				task.delay(0.31,function()
    					if not detailOpened and detailAnimation == closingId then
    						detailPanel.Visible = false
    					end
    				end)
    			end
    
    			backButton.MouseButton1Click:Connect(closeDetail)
    
    			function toggle_funcs:Open()
    				openDetail()
    			end
    			function toggle_funcs:Close()
    				closeDetail()
    			end
    			function toggle_funcs:GetContainer()
    				return detailContent
    			end
    			function toggle_funcs:Add(object)
    				if typeof(object) == "Instance" and object:IsA("GuiObject") then
    					object.Parent = detailContent
    					return object
    				end
    			end
    
    			function toggle_funcs:Dropdown(dropdownData, dropdownOff)
    				dropdownData = dropdownData or {}
    				local values = dropdownData.List or dropdownData.Options or dropdownData.Values or {}
    				local isMulti = dropdownData.Multi or false
    				local configured = dropdownData.Title and getgenv().configs[dropdownData.Title]
    				local current = dropdownData.Default or (not dropdownOff and configured) or (isMulti and {} or values[1])
    				if isMulti and type(current) ~= "table" then current = {} end
    
    				local row = Instance.new("Frame",detailContent)
    				row.BackgroundTransparency = 1;row.BorderSizePixel = 0;row.Size = UDim2.new(1,0,0,36);row.ZIndex = 204
    
    				local rowTitle = Instance.new("TextLabel",row)
    				rowTitle.BackgroundTransparency = 1;rowTitle.Size = UDim2.new(0.49,0,1,0);rowTitle.FontFace = Font.fromName("Montserrat",Enum.FontWeight.Regular,Enum.FontStyle.Normal);rowTitle.Text = dropdownData.Title or "Dropdown";rowTitle.TextColor3 = Color3.fromRGB(170,171,178);rowTitle.TextSize = 11;rowTitle.TextTruncate = Enum.TextTruncate.AtEnd;rowTitle.TextXAlignment = Enum.TextXAlignment.Left;rowTitle.ZIndex = 205
    
    				local selector = Instance.new("TextButton",row)
    				selector.AnchorPoint = Vector2.new(1,0.5);selector.Position = UDim2.new(1,0,0.5,0);selector.Size = UDim2.new(0.5,0,0,25);selector.BackgroundColor3 = Color3.fromRGB(29,30,35);selector.BorderSizePixel = 0;selector.AutoButtonColor = false;selector.Text = "";selector.ZIndex = 205
    				init.create_corner(4,selector)
    				local selectorStroke = init.stroke(selector,1,1,PRIMARY_COLOR)
    
    				local valueLabel = Instance.new("TextLabel",selector)
    				valueLabel.BackgroundTransparency = 1;valueLabel.Position = UDim2.fromOffset(8,0);valueLabel.Size = UDim2.new(1,-28,1,0);valueLabel.FontFace = Font.fromName("Montserrat",Enum.FontWeight.Regular,Enum.FontStyle.Normal);valueLabel.TextColor3 = Color3.fromRGB(225,226,230);valueLabel.TextSize = 10;valueLabel.TextTruncate = Enum.TextTruncate.AtEnd;valueLabel.TextXAlignment = Enum.TextXAlignment.Left;valueLabel.ZIndex = 206
    
    				local dropArrow = Instance.new("ImageLabel",selector)
    				dropArrow.AnchorPoint = Vector2.new(0.5,0.5);dropArrow.Position = UDim2.new(1,-14,0.5,0);dropArrow.Size = UDim2.fromOffset(18,18);dropArrow.BackgroundTransparency = 1;dropArrow.Image = "rbxassetid://135316511174421";dropArrow.ImageColor3 = Color3.fromRGB(200,201,207);dropArrow.ImageTransparency = 0;dropArrow.ScaleType = Enum.ScaleType.Fit;dropArrow.ZIndex = 206
    
    				local dropdownPopup = Instance.new("CanvasGroup",detailPanel)
    				dropdownPopup.BackgroundColor3 = Color3.fromRGB(62,63,70);dropdownPopup.BorderSizePixel = 0;dropdownPopup.GroupTransparency = 1;dropdownPopup.Visible = false;dropdownPopup.ZIndex = 230
    				init.create_corner(4,dropdownPopup)
    				init.stroke(dropdownPopup,0,1,Color3.fromRGB(43,44,49))
    
    				local optionMenu = Instance.new("ScrollingFrame",dropdownPopup)
    				optionMenu.Size = UDim2.fromScale(1,1);optionMenu.BackgroundTransparency = 1;optionMenu.BorderSizePixel = 0;optionMenu.CanvasSize = UDim2.fromOffset(0,0);optionMenu.ScrollBarThickness = 2;optionMenu.ScrollBarImageColor3 = Color3.fromRGB(90,91,98);optionMenu.ZIndex = 231
    
    				local optionPadding = Instance.new("UIPadding",optionMenu)
    				optionPadding.PaddingTop = UDim.new(0,3);optionPadding.PaddingBottom = UDim.new(0,3);optionPadding.PaddingLeft = UDim.new(0,3);optionPadding.PaddingRight = UDim.new(0,3)
    
    				local optionLayout = Instance.new("UIListLayout",optionMenu)
    				optionLayout.Padding = UDim.new(0,2);optionLayout.SortOrder = Enum.SortOrder.LayoutOrder
    
    				local openedDropdown = false
    				local dropdownAnimation = 0
    				local optionButtons = {}
    				local dropdownObject = {}
    				local fadeState = {}
    
    				local captureFadeState = function()
    					fadeState = {}
    					local objectsToFade = {dropdownPopup}
    					for _,object in dropdownPopup:GetDescendants() do table.insert(objectsToFade,object) end
    					for _,object in objectsToFade do
    						local properties = {}
    						if object:IsA("GuiObject") then properties.BackgroundTransparency = object.BackgroundTransparency end
    						if object:IsA("TextLabel") or object:IsA("TextButton") then properties.TextTransparency = object.TextTransparency end
    						if object:IsA("ImageLabel") or object:IsA("ImageButton") then properties.ImageTransparency = object.ImageTransparency end
    						if object:IsA("ScrollingFrame") then properties.ScrollBarImageTransparency = object.ScrollBarImageTransparency end
    						if object:IsA("UIStroke") then properties.Transparency = object.Transparency end
    						if next(properties) then fadeState[object] = properties end
    					end
    				end
    
    				local hideFadeObjects = function()
    					for object,properties in fadeState do
    						if object.Parent then
    							for property in properties do object[property] = 1 end
    						end
    					end
    				end
    
    				local tweenFadeObjects = function(show,duration)
    					for object,properties in fadeState do
    						if object.Parent then
    							local target = {}
    							for property,value in properties do target[property] = show and value or 1 end
    							init.tween(object,duration,Enum.EasingStyle.Quint,target)
    						end
    					end
    				end
    
    				local contains = function(value)
    					if not isMulti then return current == value end
    					return init.table_check(current,value)
    				end
    
    				local updateDisplay = function()
    					if isMulti then
    						if #current == 0 then
    							valueLabel.Text = "Select..."
    						elseif #current > 2 then
    							valueLabel.Text = tostring(#current).." selected"
    						else
    							local display = {}
    							for _,value in current do table.insert(display,tostring(value)) end
    							valueLabel.Text = table.concat(display,", ")
    						end
    					else
    						valueLabel.Text = current ~= nil and tostring(current) or "Select..."
    					end
    				end
    
    				local closeDropdown = function()
    					if not openedDropdown then return end
    					openedDropdown = false
    					dropdownAnimation = dropdownAnimation + 1
    					local closingId = dropdownAnimation
    					captureFadeState()
    					init.tween(dropdownPopup,0.24,Enum.EasingStyle.Quint,{
    						Position = dropdownPopup.Position + UDim2.fromOffset(0,4)
    					})
    					tweenFadeObjects(false,0.24)
    					init.tween(dropArrow,0.2,Enum.EasingStyle.Quint,{Rotation = 0})
    					init.tween(selectorStroke,0.2,Enum.EasingStyle.Quint,{Transparency = 1})
    					task.delay(0.25,function()
    						if not openedDropdown and dropdownAnimation == closingId then dropdownPopup.Visible = false end
    					end)
    				end
    				table.insert(detailClosers,closeDropdown)
    
    				local applyValue = function(value,callCallback,toggleValue)
    					if isMulti then
    						if type(value) == "table" then
    							current = {}
    							for _,entry in value do table.insert(current,entry) end
    						elseif toggleValue then
    							local removed = false
    							for index,entry in current do
    								if entry == value then table.remove(current,index);removed = true;break end
    							end
    							if not removed then table.insert(current,value) end
    						else
    							current = value ~= nil and {value} or {}
    						end
    					else
    						current = value
    					end
    					updateDisplay()
    					for optionValue,button in optionButtons do
    						local active = contains(optionValue)
    						button.BackgroundTransparency = active and 0 or 1;button.TextColor3 = active and Color3.fromRGB(255,255,255) or Color3.fromRGB(180,181,187)
    						local check = button:FindFirstChild("@check")
    						if check then check.Visible = active end
    					end
    					if not dropdownOff and dropdownData.Title and getgenv().configs[dropdownData.Title] ~= nil then
    						getgenv().configs[dropdownData.Title] = current
    					end
    					if callCallback and dropdownData.Callback then task.spawn(dropdownData.Callback,current) end
    				end
    
    				local rebuild = function(newValues)
    					values = newValues or {}
    					for _,button in optionButtons do button:Destroy() end
    					optionButtons = {}
    					for index,value in values do
    						local option = Instance.new("TextButton",optionMenu)
    						option.LayoutOrder = index;option.Size = UDim2.new(1,0,0,36);option.BackgroundColor3 = Color3.fromRGB(76,77,86);option.BackgroundTransparency = contains(value) and 0 or 1;option.BorderSizePixel = 0;option.AutoButtonColor = false;option.FontFace = Font.fromName("Montserrat",Enum.FontWeight.Regular,Enum.FontStyle.Normal);option.Text = "  "..tostring(value);option.TextColor3 = contains(value) and Color3.fromRGB(255,255,255) or Color3.fromRGB(235,236,240);option.TextSize = 11;option.TextXAlignment = Enum.TextXAlignment.Left;option.ZIndex = 232
    						init.create_corner(3,option)
    						local check = Instance.new("TextLabel",option)
    						check.Name = "@check";check.AnchorPoint = Vector2.new(1,0.5);check.Position = UDim2.new(1,-8,0.5,0);check.Size = UDim2.fromOffset(18,18);check.BackgroundTransparency = 1;check.Font = Enum.Font.GothamBold;check.Text = "✓";check.TextColor3 = Color3.fromRGB(255,255,255);check.TextSize = 15;check.Visible = contains(value);check.ZIndex = 233
    						optionButtons[value] = option
    						option.MouseEnter:Connect(function()
    							if not contains(value) then option.BackgroundTransparency = 0.55 end
    						end)
    						option.MouseLeave:Connect(function()
    							if not contains(value) then option.BackgroundTransparency = 1 end
    						end)
    						option.MouseButton1Click:Connect(function()
    							applyValue(value,true,isMulti)
    						end)
    					end
    					local height = (#values * 38) + 6
    					optionMenu.CanvasSize = UDim2.fromOffset(0,height)
    					dropdownPopup.Size = UDim2.fromOffset(160,math.min(height,160))
    				end
    
    				selector.MouseButton1Click:Connect(function()
    					if openedDropdown then closeDropdown();return end
    					if #values == 0 then return end
    					openedDropdown = true
    					local localPosition = selector.AbsolutePosition - detailPanel.AbsolutePosition
    					local menuHeight = dropdownPopup.AbsoluteSize.Y
    					local below = localPosition.Y + selector.AbsoluteSize.Y + 3
    					local y = below + menuHeight <= detailPanel.AbsoluteSize.Y - 6 and below or localPosition.Y - menuHeight - 3
    					local menuX = localPosition.X + selector.AbsoluteSize.X - dropdownPopup.AbsoluteSize.X
    					dropdownAnimation = dropdownAnimation + 1
    					dropdownPopup.Position = UDim2.fromOffset(menuX,y + 7);dropdownPopup.GroupTransparency = 0;dropdownPopup.Visible = true
    					if not next(fadeState) then captureFadeState() end
    					hideFadeObjects()
    					init.tween(dropdownPopup,0.22,Enum.EasingStyle.Quint,{
    						Position = UDim2.fromOffset(menuX,y)
    					})
    					tweenFadeObjects(true,0.22)
    					init.tween(dropArrow,0.2,Enum.EasingStyle.Quint,{Rotation = 180})
    					init.tween(selectorStroke,0.2,Enum.EasingStyle.Quint,{Transparency = 0})
    				end)
    
    				function dropdownObject:SetValue(value) applyValue(value,true) end
    				function dropdownObject:Set(value) applyValue(value,true) end
    				function dropdownObject:Get() return current end
    				function dropdownObject:Clear() applyValue(isMulti and {} or nil,true) end
    				function dropdownObject:Add(value)
    					table.insert(values,value)
    					rebuild(values)
    					applyValue(current,false)
    				end
    				function dropdownObject:Refresh(newValues,keepValue)
    					if not keepValue then current = isMulti and {} or (newValues and newValues[1] or nil) end
    					rebuild(newValues)
    					applyValue(current,false)
    				end
    				function dropdownObject:Close() closeDropdown() end
    
    				rebuild(values)
    				applyValue(current,false)
    				if dropdownData.Default ~= nil and dropdownData.Callback then
    					task.spawn(dropdownData.Callback,current)
    				end
    				return dropdownObject
    			end
    
    			function toggle_funcs:ColorPicker(colorData,colorOff)
    				colorData = colorData or {}
    				local configured = colorData.Title and getgenv().configs[colorData.Title]
    				local current = colorData.Default
    				if current == nil and not colorOff and typeof(configured) == "Color3" then current = configured end
    				if typeof(current) ~= "Color3" then current = Color3.fromRGB(255,255,255) end
    				local hue,saturation,value = Color3.toHSV(current)
    
    				local colorRow = Instance.new("Frame",detailContent)
    				colorRow.BackgroundTransparency = 1;colorRow.BorderSizePixel = 0;colorRow.Size = UDim2.new(1,0,0,36);colorRow.ClipsDescendants = true;colorRow.ZIndex = 204
    
    				local colorTitle = Instance.new("TextLabel",colorRow)
    				colorTitle.BackgroundTransparency = 1;colorTitle.Size = UDim2.new(1,-125,0,36);colorTitle.FontFace = Font.fromName("Montserrat",Enum.FontWeight.Regular,Enum.FontStyle.Normal);colorTitle.Text = colorData.Title or "Color";colorTitle.TextColor3 = Color3.fromRGB(136,137,146);colorTitle.TextSize = 11;colorTitle.TextTruncate = Enum.TextTruncate.AtEnd;colorTitle.TextXAlignment = Enum.TextXAlignment.Left;colorTitle.ZIndex = 205
    
    				local hexBox = Instance.new("TextBox",colorRow)
    				hexBox.AnchorPoint = Vector2.new(0,0.5);hexBox.Position = UDim2.new(1,-108,0,18);hexBox.Size = UDim2.fromOffset(63,24);hexBox.BackgroundTransparency = 1;hexBox.BorderSizePixel = 0;hexBox.ClearTextOnFocus = false;hexBox.FontFace = Font.fromName("Montserrat",Enum.FontWeight.Medium,Enum.FontStyle.Normal);hexBox.TextColor3 = Color3.fromRGB(132,133,143);hexBox.TextSize = 11;hexBox.TextXAlignment = Enum.TextXAlignment.Left;hexBox.ZIndex = 205
    
    				local currentPreview = Instance.new("Frame",colorRow)
    				currentPreview.AnchorPoint = Vector2.new(1,0.5);currentPreview.Position = UDim2.new(1,-112,0,18);currentPreview.Size = UDim2.fromOffset(10,10);currentPreview.BorderSizePixel = 0;currentPreview.ZIndex = 206
    				init.create_corner(2,currentPreview);init.stroke(currentPreview,0,1,Color3.fromRGB(72,73,80))
    
    				local editButton = Instance.new("ImageButton",colorRow)
    				editButton.AnchorPoint = Vector2.new(1,0.5);editButton.Position = UDim2.new(1,-24,0,18);editButton.Size = UDim2.fromOffset(14,14);editButton.BackgroundTransparency = 1;editButton.BorderSizePixel = 0;editButton.AutoButtonColor = false;editButton.Image = "rbxassetid://95384267106160";editButton.ImageColor3 = Color3.fromRGB(112,113,123);editButton.ZIndex = 206
    
    				local colorDivider = Instance.new("Frame",colorRow)
    				colorDivider.AnchorPoint = Vector2.new(0.5,0.5);colorDivider.Position = UDim2.new(1,-47,0,18);colorDivider.Size = UDim2.fromOffset(1,14);colorDivider.BackgroundColor3 = Color3.fromRGB(61,62,69);colorDivider.BorderSizePixel = 0;colorDivider.ZIndex = 205
    
    				local swatch = Instance.new("TextButton",colorRow)
    				swatch.AnchorPoint = Vector2.new(1,0.5);swatch.Position = UDim2.new(1,0,0,18);swatch.Size = UDim2.fromOffset(16,16);swatch.BackgroundColor3 = Color3.fromRGB(255,255,255);swatch.BorderSizePixel = 0;swatch.AutoButtonColor = false;swatch.Text = "";swatch.ZIndex = 206
    				init.create_corner(20,swatch)
    				local swatchGradient = Instance.new("UIGradient",swatch)
    				swatchGradient.Rotation = 35;swatchGradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(255,45,197)),ColorSequenceKeypoint.new(0.25,Color3.fromRGB(109,60,255)),ColorSequenceKeypoint.new(0.5,Color3.fromRGB(24,216,255)),ColorSequenceKeypoint.new(0.72,Color3.fromRGB(84,255,85)),ColorSequenceKeypoint.new(1,Color3.fromRGB(255,225,31))})
    
    				local pickerBlocker = Instance.new("TextButton",main)
    				pickerBlocker.Name = "@color_picker_blocker";pickerBlocker.Size = UDim2.fromScale(1,1);pickerBlocker.BackgroundTransparency = 1;pickerBlocker.BorderSizePixel = 0;pickerBlocker.AutoButtonColor = false;pickerBlocker.Text = "";pickerBlocker.Visible = false;pickerBlocker.Modal = true;pickerBlocker.ZIndex = 259
    
    				local picker = Instance.new("Frame",main)
    				picker.Size = UDim2.fromOffset(150,220);picker.BackgroundColor3 = Color3.fromRGB(27,27,32);picker.BorderSizePixel = 0;picker.Visible = false;picker.ZIndex = 260
    				init.create_corner(6,picker);init.stroke(picker,0,1,Color3.fromRGB(50,51,57))
    
    				local svArea = Instance.new("ImageButton",picker)
    				svArea.Position = UDim2.fromOffset(12,10);svArea.Size = UDim2.fromOffset(126,126);svArea.BackgroundTransparency = 1;svArea.BorderSizePixel = 0;svArea.AutoButtonColor = false;svArea.Image = "rbxassetid://501436779";svArea.ZIndex = 261
    
    				local svCursor = Instance.new("Frame",svArea)
    				svCursor.AnchorPoint = Vector2.new(0.5,0.5);svCursor.Size = UDim2.fromOffset(10,10);svCursor.BackgroundTransparency = 1;svCursor.ZIndex = 263
    				init.create_corner(10,svCursor);init.stroke(svCursor,0,2,Color3.fromRGB(255,255,255))
    
    				local hueBar = Instance.new("Frame",picker)
    				hueBar.Position = UDim2.fromOffset(16,145);hueBar.Size = UDim2.fromOffset(118,6);hueBar.BackgroundColor3 = Color3.fromRGB(255,255,255);hueBar.BorderSizePixel = 0;hueBar.ClipsDescendants = false;hueBar.ZIndex = 261
    				init.create_corner(8,hueBar)
    				local hueGradient = Instance.new("UIGradient",hueBar)
    				hueGradient.Color = ColorSequence.new(Color3.fromRGB(255,255,255),Color3.fromHSV(hue,1,1))
    
    				local hueCursor = Instance.new("Frame",hueBar)
    				hueCursor.AnchorPoint = Vector2.new(0.5,0.5);hueCursor.Size = UDim2.fromOffset(7,10);hueCursor.BackgroundColor3 = Color3.fromRGB(255,255,255);hueCursor.BorderSizePixel = 0;hueCursor.ZIndex = 263
    				init.create_corner(4,hueCursor);init.stroke(hueCursor,0,1,Color3.fromRGB(30,30,34))
    
    				local alphaBar = Instance.new("Frame",picker)
    				alphaBar.Position = UDim2.fromOffset(16,163);alphaBar.Size = UDim2.fromOffset(118,6);alphaBar.BackgroundColor3 = Color3.fromRGB(255,255,255);alphaBar.BorderSizePixel = 0;alphaBar.ZIndex = 261
    				init.create_corner(8,alphaBar)
    				local alphaGradient = Instance.new("UIGradient",alphaBar)
    				alphaGradient.Color = ColorSequence.new(Color3.fromRGB(15,15,18),Color3.fromRGB(255,255,255))
    				local alphaCursor = Instance.new("Frame",alphaBar)
    				alphaCursor.AnchorPoint = Vector2.new(0.5,0.5);alphaCursor.Position = UDim2.fromScale(1,0.5);alphaCursor.Size = UDim2.fromOffset(7,10);alphaCursor.BackgroundColor3 = Color3.fromRGB(255,255,255);alphaCursor.BorderSizePixel = 0;alphaCursor.ZIndex = 263
    				init.create_corner(4,alphaCursor);init.stroke(alphaCursor,0,1,Color3.fromRGB(30,30,34))
    
    				local popupHex = Instance.new("TextBox",picker)
    				popupHex.Position = UDim2.fromOffset(12,181);popupHex.Size = UDim2.fromOffset(126,24);popupHex.BackgroundColor3 = Color3.fromRGB(35,35,40);popupHex.BorderSizePixel = 0;popupHex.ClearTextOnFocus = false;popupHex.FontFace = Font.fromName("Montserrat",Enum.FontWeight.Medium,Enum.FontStyle.Normal);popupHex.TextColor3 = Color3.fromRGB(190,191,197);popupHex.TextSize = 11;popupHex.ZIndex = 262
    				init.create_corner(4,popupHex);init.stroke(popupHex,0,1,Color3.fromRGB(48,49,55))
    
    				local colorObject = {}
    				local opened,draggingSV,draggingHue,draggingAlpha = false,false,false,false
    				local pickingColor = false
    				local alpha = math.clamp(colorData.Alpha or 1,0,1)
    				local updatingHex = false
    				local toHex = function(color)
    					return string.format("#%02X%02X%02X",math.round(color.R*255),math.round(color.G*255),math.round(color.B*255))
    				end
    				local fromHex = function(text)
    					local hex = tostring(text):gsub("#",""):gsub("%s","")
    					if #hex == 3 then hex = hex:sub(1,1):rep(2)..hex:sub(2,2):rep(2)..hex:sub(3,3):rep(2) end
    					if not hex:match("^%x%x%x%x%x%x$") then return nil end
    					return Color3.fromRGB(tonumber(hex:sub(1,2),16),tonumber(hex:sub(3,4),16),tonumber(hex:sub(5,6),16))
    				end
    				local applyColor = function(color,callCallback,animateVisuals)
    					if typeof(color) ~= "Color3" then return end
    					current = color;hue,saturation,value = Color3.toHSV(current)
    					updatingHex = true
    					hexBox.Text = toHex(current);popupHex.Text = toHex(current)
    					updatingHex = false
    					currentPreview.BackgroundColor3 = current
    					local angle = hue * math.pi * 2
    					local wheelPosition = UDim2.fromScale(0.5 + math.cos(angle)*saturation*0.5,0.5 + math.sin(angle)*saturation*0.5)
    					local saturationPosition = UDim2.fromScale(saturation,0.5)
    					local brightnessPosition = UDim2.fromScale(value,0.5)
    					if animateVisuals then
    						init.tween(svCursor,0.2,Enum.EasingStyle.Quint,{Position = wheelPosition})
    						init.tween(hueCursor,0.2,Enum.EasingStyle.Quint,{Position = saturationPosition})
    						init.tween(alphaCursor,0.2,Enum.EasingStyle.Quint,{Position = brightnessPosition})
    					else
    						svCursor.Position = wheelPosition;hueCursor.Position = saturationPosition;alphaCursor.Position = brightnessPosition
    					end
    					hueGradient.Color = ColorSequence.new(Color3.fromRGB(255,255,255),Color3.fromHSV(hue,1,1))
    					if not colorOff and colorData.Title then getgenv().configs[colorData.Title] = current end
    					if callCallback and colorData.Callback then task.spawn(colorData.Callback,current,toHex(current),alpha) end
    				end
    				local setOpen = function(state)
    					opened = state
    					if state then
    						local mainPosition,mainSize = main.AbsolutePosition,main.AbsoluteSize
    						local wantedX = swatch.AbsolutePosition.X-mainPosition.X+24
    					if wantedX+150 > mainSize.X-8 then wantedX = swatch.AbsolutePosition.X-mainPosition.X-156 end
    					local wantedY = math.clamp(swatch.AbsolutePosition.Y-mainPosition.Y-10,8,math.max(8,mainSize.Y-228))
    						picker.Position = UDim2.fromOffset(wantedX,wantedY)
    					end
    					pickerBlocker.Visible = state
    					picker.Visible = state
    				end
    				local updateSV = function(input)
    					local center = svArea.AbsolutePosition + svArea.AbsoluteSize/2
    					local delta = Vector2.new(input.Position.X,input.Position.Y)-center
    					local radius = svArea.AbsoluteSize.X/2
    					local distance = math.min(delta.Magnitude,radius)
    					if delta.Magnitude > radius then delta = delta.Unit*radius end
    					hue = (math.atan2(delta.Y,delta.X)/(math.pi*2))%1;saturation = distance/radius
    					applyColor(Color3.fromHSV(hue,saturation,value),true)
    				end
    				local updateHue = function(input)
    					local x = math.clamp((input.Position.X-hueBar.AbsolutePosition.X)/hueBar.AbsoluteSize.X,0,1)
    					applyColor(Color3.fromHSV(hue,x,value),true)
    				end
    				local updateAlpha = function(input)
    					local brightness = math.clamp((input.Position.X-alphaBar.AbsolutePosition.X)/alphaBar.AbsoluteSize.X,0,1)
    					applyColor(Color3.fromHSV(hue,saturation,brightness),true)
    				end
    
    				swatch.MouseButton1Click:Connect(function() setOpen(not opened) end)
    				pickerBlocker.MouseButton1Click:Connect(function() setOpen(false) end)
    				table.insert(detailClosers,function() setOpen(false) end)
    
    				local eyedropperCursor = Instance.new("Frame",sixlyinit)
    				eyedropperCursor.Name = "@eyedropper_cursor";eyedropperCursor.AnchorPoint = Vector2.new(0.5,0.5);eyedropperCursor.Size = UDim2.fromOffset(18,18);eyedropperCursor.BackgroundTransparency = 1;eyedropperCursor.BorderSizePixel = 0;eyedropperCursor.Visible = false;eyedropperCursor.ZIndex = 1000
    				init.create_corner(18,eyedropperCursor);init.stroke(eyedropperCursor,0,2,Color3.fromRGB(255,255,255))
    				local eyedropperPreview = Instance.new("Frame",eyedropperCursor)
    				eyedropperPreview.Size = UDim2.fromOffset(14,14);eyedropperPreview.BorderSizePixel = 0;eyedropperPreview.ZIndex = 1002
    				init.create_corner(14,eyedropperPreview);init.stroke(eyedropperPreview,0,1,Color3.fromRGB(255,255,255))
    				local eyedropperInfo = Instance.new("TextLabel",eyedropperCursor)
    				eyedropperInfo.AnchorPoint = Vector2.new(0.5,1);eyedropperInfo.Position = UDim2.new(0.5,0,0,-10);eyedropperInfo.Size = UDim2.fromOffset(82,22);eyedropperInfo.BackgroundTransparency = 1;eyedropperInfo.BorderSizePixel = 0;eyedropperInfo.Text = "";eyedropperInfo.ZIndex = 1001
    				eyedropperPreview.Parent = eyedropperInfo;eyedropperPreview.AnchorPoint = Vector2.new(0,0.5);eyedropperPreview.Position = UDim2.new(0,2,0.5,0);eyedropperPreview.Size = UDim2.fromOffset(12,12)
    				local eyedropperCode = Instance.new("TextLabel",eyedropperInfo)
    				eyedropperCode.AnchorPoint = Vector2.new(0,0.5);eyedropperCode.Position = UDim2.new(0,20,0.5,0);eyedropperCode.Size = UDim2.fromOffset(62,20);eyedropperCode.BackgroundTransparency = 1;eyedropperCode.FontFace = Font.fromName("Montserrat",Enum.FontWeight.Medium,Enum.FontStyle.Normal);eyedropperCode.TextColor3 = Color3.fromRGB(225,226,230);eyedropperCode.TextSize = 10;eyedropperCode.TextXAlignment = Enum.TextXAlignment.Left;eyedropperCode.ZIndex = 1002
    
    				local setEyedropper = function(state)
    					pickingColor = state
    					eyedropperCursor.Visible = state
    					init.tween(editButton,0.12,Enum.EasingStyle.Circular,{ImageColor3 = state and PRIMARY_HOVER or Color3.fromRGB(112,113,123)})
    				end
    				local colorFromObject = function(object)
    					if not object or object:IsDescendantOf(colorRow) or object:IsDescendantOf(picker) or object:IsDescendantOf(eyedropperCursor) then return nil end
    					-- Large transparent-looking panels are layout backgrounds, not a
    					-- deliberate color target for the eyedropper.
    					if object:IsA("GuiObject") and object.AbsoluteSize.X*object.AbsoluteSize.Y > 6000 then return nil end
    					if (object:IsA("ImageLabel") or object:IsA("ImageButton")) and object.ImageTransparency < 1 then return object.ImageColor3 end
    					if object:IsA("GuiObject") and object.BackgroundTransparency < 1 then return object.BackgroundColor3 end
    					if (object:IsA("TextLabel") or object:IsA("TextButton") or object:IsA("TextBox")) and object.TextTransparency < 1 then return object.TextColor3 end
    					return nil
    				end
    				local getHoveredColor = function()
    					local sampled = nil
    					local pointer = userinputservice:GetMouseLocation()
    					local ok,objectsAtPoint = pcall(function() return coregui:GetGuiObjectsAtPosition(pointer.X,pointer.Y) end)
    					if not ok then objectsAtPoint = {} end
    					local seen = {}
    					for _,object in objectsAtPoint do seen[object] = true end
    					local isActuallyVisible = function(object)
    						local parent = object
    						while parent and parent ~= coregui do
    							if parent:IsA("GuiObject") and not parent.Visible then return false end
    							if parent:IsA("LayerCollector") and not parent.Enabled then return false end
    							parent = parent.Parent
    						end
    						return true
    					end
    					for _,object in sixlyinit:GetDescendants() do
    						if object:IsA("GuiObject") and isActuallyVisible(object) and not seen[object] then
    							local position,size = object.AbsolutePosition,object.AbsoluteSize
    							if pointer.X >= position.X and pointer.X <= position.X+size.X and pointer.Y >= position.Y and pointer.Y <= position.Y+size.Y then
    								table.insert(objectsAtPoint,object);seen[object] = true
    							end
    						end
    					end
    					if #objectsAtPoint > 0 then
    						local getDepth = function(object)
    							local depth,parent = 0,object.Parent
    							while parent and parent ~= coregui do depth = depth+1;parent = parent.Parent end
    							return depth
    						end
    						table.sort(objectsAtPoint,function(a,b)
    							if a.ZIndex ~= b.ZIndex then return a.ZIndex > b.ZIndex end
    							return getDepth(a) > getDepth(b)
    						end)
    						for _,object in objectsAtPoint do
    							sampled = colorFromObject(object)
    							if sampled then break end
    						end
    					end
    					local mainPosition,mainSize = main.AbsolutePosition,main.AbsoluteSize
    					local insideMain = pointer.X >= mainPosition.X and pointer.X <= mainPosition.X+mainSize.X and pointer.Y >= mainPosition.Y and pointer.Y <= mainPosition.Y+mainSize.Y
    					if not sampled and not insideMain and mouse.Target and mouse.Target:IsA("BasePart") then sampled = mouse.Target.Color end
    					return sampled
    				end
    				local updateEyedropperCursor = function()
    					if not pickingColor then return end
    					local pointer = userinputservice:GetMouseLocation()
    					eyedropperCursor.Position = UDim2.fromOffset(pointer.X,pointer.Y)
    					local screenWidth = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize.X or 1280
    					local tooltipOffset = 0
    					if pointer.X < 75 then tooltipOffset = 75-pointer.X elseif pointer.X > screenWidth-75 then tooltipOffset = screenWidth-75-pointer.X end
    					eyedropperInfo.Position = UDim2.new(0.5,tooltipOffset,0,-10)
    					local sampled = getHoveredColor()
    					if typeof(sampled) == "Color3" then
    						eyedropperPreview.BackgroundColor3 = sampled
    						eyedropperCode.Text = toHex(sampled)
    					else
    						eyedropperPreview.BackgroundColor3 = Color3.fromRGB(45,46,52)
    						eyedropperCode.Text = "No color"
    					end
    				end
    				local sampleColor = function()
    					local sampled = getHoveredColor()
    					if typeof(sampled) == "Color3" then applyColor(sampled,true,true) end
    					setEyedropper(false)
    				end
    				editButton.MouseButton1Click:Connect(function()
    					hexBox:CaptureFocus()
    				end)
    				editButton.MouseEnter:Connect(function() init.tween(editButton,0.12,Enum.EasingStyle.Circular,{ImageColor3 = Color3.fromRGB(190,191,198)}) end)
    				editButton.MouseLeave:Connect(function() init.tween(editButton,0.12,Enum.EasingStyle.Circular,{ImageColor3 = Color3.fromRGB(112,113,123)}) end)
    				hexBox.FocusLost:Connect(function()
    					local color = fromHex(hexBox.Text)
    					if color then applyColor(color,true,true) else hexBox.Text = toHex(current) end
    				end)
    				popupHex.FocusLost:Connect(function()
    					local color = fromHex(popupHex.Text)
    					if color then applyColor(color,true,true) else popupHex.Text = toHex(current) end
    				end)
    				local liveHexUpdate = function(box)
    					if updatingHex then return end
    					local clean = box.Text:gsub("#",""):gsub("%s","")
    					if #clean == 6 and clean:match("^%x%x%x%x%x%x$") then
    						local color = fromHex(clean)
    						if color then applyColor(color,true,true) end
    					end
    				end
    				hexBox:GetPropertyChangedSignal("Text"):Connect(function() liveHexUpdate(hexBox) end)
    				popupHex:GetPropertyChangedSignal("Text"):Connect(function() liveHexUpdate(popupHex) end)
    				svArea.InputBegan:Connect(function(input)
    					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then draggingSV = true;asset["sl-focus"] = true;updateSV(input) end
    				end)
    				hueBar.InputBegan:Connect(function(input)
    					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then draggingHue = true;asset["sl-focus"] = true;updateHue(input) end
    				end)
    				alphaBar.InputBegan:Connect(function(input)
    					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then draggingAlpha = true;asset["sl-focus"] = true;updateAlpha(input) end
    				end)
    				userinputservice.InputChanged:Connect(function(input)
    					if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then return end
    					if draggingSV then updateSV(input) elseif draggingHue then updateHue(input) elseif draggingAlpha then updateAlpha(input) end
    				end)
    				userinputservice.InputEnded:Connect(function(input)
    					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then draggingSV = false;draggingHue = false;draggingAlpha = false;asset["sl-release"] = os.clock();asset["sl-focus"] = false end
    				end)
    
    				function colorObject:Set(color) applyColor(color,true,true) end
    				function colorObject:SetValue(color) applyColor(color,true,true) end
    				function colorObject:SetHex(hex) local color = fromHex(hex);if color then applyColor(color,true,true) end end
    				function colorObject:Get() return current end
    				function colorObject:GetHex() return toHex(current) end
    				function colorObject:Open() setOpen(true) end
    				function colorObject:Close() setOpen(false) end
    
    				applyColor(current,false)
    				if colorData.Default ~= nil and colorData.Callback then task.spawn(colorData.Callback,current,toHex(current),alpha) end
    				return colorObject
    			end
    
    			function toggle_funcs:Slider(sliderData,sliderOff)
    				sliderData = sliderData or {}
    				local minimum = tonumber(sliderData.Min) or 0
    				local maximum = tonumber(sliderData.Max) or 100
    				if maximum <= minimum then maximum = minimum + 1 end
    				local round = tonumber(sliderData.Round)
    				if round == nil then round = 1 end
    				local configured = sliderData.Title and getgenv().configs[sliderData.Title]
    				local value = tonumber(sliderData.Default) or (not sliderOff and tonumber(configured)) or minimum
    				local suffix = sliderData.Suffix or ""
    				local sliderDragging = false
    
    				local sliderRow = Instance.new("Frame",detailContent)
    				sliderRow.BackgroundTransparency = 1;sliderRow.BorderSizePixel = 0;sliderRow.Size = UDim2.new(1,0,0,36);sliderRow.Active = true;sliderRow.ZIndex = 204
    
    				local sliderTitle = Instance.new("TextLabel",sliderRow)
    				sliderTitle.BackgroundTransparency = 1;sliderTitle.Size = UDim2.new(0.36,0,1,0);sliderTitle.FontFace = Font.fromName("Montserrat",Enum.FontWeight.Regular,Enum.FontStyle.Normal);sliderTitle.Text = sliderData.Title or "Slider";sliderTitle.TextColor3 = Color3.fromRGB(170,171,178);sliderTitle.TextSize = 11;sliderTitle.TextTruncate = Enum.TextTruncate.AtEnd;sliderTitle.TextXAlignment = Enum.TextXAlignment.Left;sliderTitle.ZIndex = 205
    
    				local valueBox = Instance.new("TextBox",sliderRow)
    				valueBox.AnchorPoint = Vector2.new(0,0.5);valueBox.Position = UDim2.new(0.36,0,0.5,0);valueBox.Size = UDim2.new(0.17,0,0,24);valueBox.BackgroundTransparency = 1;valueBox.BorderSizePixel = 0;valueBox.ClearTextOnFocus = false;valueBox.FontFace = Font.fromName("Montserrat",Enum.FontWeight.Regular,Enum.FontStyle.Normal);valueBox.TextColor3 = Color3.fromRGB(170,171,178);valueBox.TextSize = 10;valueBox.TextXAlignment = Enum.TextXAlignment.Right;valueBox.ZIndex = 205
    
    				local track = Instance.new("Frame",sliderRow)
    				track.AnchorPoint = Vector2.new(0,0.5);track.Position = UDim2.new(0.57,0,0.5,0);track.Size = UDim2.new(0.43,0,0,3);track.BackgroundColor3 = Color3.fromRGB(55,57,63);track.BorderSizePixel = 0;track.Active = true;track.ZIndex = 205
    				init.create_corner(6,track)
    
    				local fill = Instance.new("Frame",track)
    				fill.BackgroundColor3 = PRIMARY_COLOR;fill.BorderSizePixel = 0;fill.Size = UDim2.fromScale(0,1);fill.ZIndex = 206
    				init.create_corner(6,fill)
    
    				local knob = Instance.new("Frame",track)
    				knob.AnchorPoint = Vector2.new(0.5,0.5);knob.Position = UDim2.fromScale(0,0.5);knob.Size = UDim2.fromOffset(16,16);knob.BackgroundColor3 = Color3.fromRGB(255,255,255);knob.BorderSizePixel = 0;knob.Active = true;knob.ZIndex = 207
    				init.create_corner(10,knob)
    				init.stroke(knob,0.75,1,Color3.fromRGB(20,21,24))
    
    				local sliderObject = {}
    				local rounded = function(number)
    					number = math.clamp(number,minimum,maximum)
    					if round > 0 then
    						number = math.floor(number / round + 0.5) * round
    					elseif round < 0 then
    						local power = 10 ^ math.abs(round)
    						number = math.floor(number * power + 0.5) / power
    					end
    					return math.clamp(number,minimum,maximum)
    				end
    
    				local displayValue = function(number)
    					if round < 0 then
    						return string.format("%."..math.abs(round).."f",number)..suffix
    					end
    					return tostring(number)..suffix
    				end
    
    				local updateSlider = function(newValue,callCallback,animate)
    					value = rounded(tonumber(newValue) or value)
    					local percent = math.clamp((value - minimum) / (maximum - minimum),0,1)
    					valueBox.Text = displayValue(value)
    					if animate then
    						init.tween(fill,0.12,Enum.EasingStyle.Circular,{Size = UDim2.fromScale(percent,1)})
    						init.tween(knob,0.12,Enum.EasingStyle.Circular,{Position = UDim2.fromScale(percent,0.5)})
    					else
    						fill.Size = UDim2.fromScale(percent,1)
    						knob.Position = UDim2.fromScale(percent,0.5)
    					end
    					if not sliderOff and sliderData.Title and getgenv().configs[sliderData.Title] ~= nil then
    						getgenv().configs[sliderData.Title] = value
    					end
    					if callCallback and sliderData.Callback then task.spawn(sliderData.Callback,value) end
    				end
    
    				local updateFromInput = function(input)
    					local percent = math.clamp((input.Position.X-track.AbsolutePosition.X)/track.AbsoluteSize.X,0,1)
    					updateSlider(minimum + ((maximum-minimum)*percent),true,false)
    				end
    
    				local beginDragging = function(input)
    					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
    						sliderDragging = true
    						asset["sl-focus"] = true
    						updateFromInput(input)
    					end
    				end
    				track.InputBegan:Connect(beginDragging)
    				knob.InputBegan:Connect(beginDragging)
    
    				userinputservice.InputChanged:Connect(function(input)
    					if sliderDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
    						updateFromInput(input)
    					end
    				end)
    				userinputservice.InputEnded:Connect(function(input)
    					if sliderDragging and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
    						sliderDragging = false
    						asset["sl-release"] = os.clock()
    						asset["sl-focus"] = false
    					end
    				end)
    
    				valueBox.FocusLost:Connect(function()
    					local numericText = string.match(valueBox.Text,"[-+]?%d*%.?%d+")
    					updateSlider(tonumber(numericText) or value,true,true)
    				end)
    
    				function sliderObject:SetValue(newValue) updateSlider(newValue,true,true) end
    				function sliderObject:Set(newValue) updateSlider(newValue,true,true) end
    				function sliderObject:Get() return value end
    
    				updateSlider(value,false,false)
    				if sliderData.Default ~= nil and sliderData.Callback then task.spawn(sliderData.Callback,value) end
    				return sliderObject
    			end
    
    			function toggle_funcs:Range(rangeData,rangeOff)
    				rangeData = rangeData or {}
    				local minimum = tonumber(rangeData.Min) or 0
    				local maximum = tonumber(rangeData.Max) or 100
    				if maximum <= minimum then maximum = minimum + 1 end
    				local step = tonumber(rangeData.Round) or 1
    				local suffix = rangeData.Suffix or ""
    				local configured = rangeData.Title and getgenv().configs[rangeData.Title]
    				local defaults = rangeData.Default or (not rangeOff and type(configured) == "table" and configured) or {minimum,maximum}
    				local low = tonumber(defaults[1]) or minimum
    				local high = tonumber(defaults[2]) or maximum
    				local draggingHandle = nil
    
    				local rangeRow = Instance.new("Frame",detailContent)
    				rangeRow.BackgroundTransparency = 1;rangeRow.BorderSizePixel = 0;rangeRow.Size = UDim2.new(1,0,0,36);rangeRow.Active = true;rangeRow.ZIndex = 204
    
    				local rangeTitle = Instance.new("TextLabel",rangeRow)
    				rangeTitle.BackgroundTransparency = 1;rangeTitle.Size = UDim2.new(0.32,0,1,0);rangeTitle.FontFace = Font.fromName("Montserrat",Enum.FontWeight.Regular,Enum.FontStyle.Normal);rangeTitle.Text = rangeData.Title or "Range";rangeTitle.TextColor3 = Color3.fromRGB(170,171,178);rangeTitle.TextSize = 11;rangeTitle.TextTruncate = Enum.TextTruncate.AtEnd;rangeTitle.TextXAlignment = Enum.TextXAlignment.Left;rangeTitle.ZIndex = 205
    
    				local rangeValue = Instance.new("TextBox",rangeRow)
    				rangeValue.AnchorPoint = Vector2.new(0,0.5);rangeValue.Position = UDim2.new(0.32,0,0.5,0);rangeValue.Size = UDim2.new(0.23,0,0,24);rangeValue.BackgroundTransparency = 1;rangeValue.BorderSizePixel = 0;rangeValue.ClearTextOnFocus = false;rangeValue.FontFace = Font.fromName("Montserrat",Enum.FontWeight.Regular,Enum.FontStyle.Normal);rangeValue.TextColor3 = Color3.fromRGB(170,171,178);rangeValue.TextSize = 10;rangeValue.TextXAlignment = Enum.TextXAlignment.Right;rangeValue.ZIndex = 205
    
    				local rangeTrack = Instance.new("Frame",rangeRow)
    				rangeTrack.AnchorPoint = Vector2.new(0,0.5);rangeTrack.Position = UDim2.new(0.59,0,0.5,0);rangeTrack.Size = UDim2.new(0.41,0,0,3);rangeTrack.BackgroundColor3 = Color3.fromRGB(55,57,63);rangeTrack.BorderSizePixel = 0;rangeTrack.Active = true;rangeTrack.ZIndex = 205
    				init.create_corner(6,rangeTrack)
    
    				local rangeFill = Instance.new("Frame",rangeTrack)
    				rangeFill.BackgroundColor3 = PRIMARY_COLOR;rangeFill.BorderSizePixel = 0;rangeFill.ZIndex = 206
    				init.create_corner(6,rangeFill)
    
    				local lowKnob = Instance.new("Frame",rangeTrack)
    				lowKnob.AnchorPoint = Vector2.new(0.5,0.5);lowKnob.Size = UDim2.fromOffset(16,16);lowKnob.BackgroundColor3 = Color3.fromRGB(255,255,255);lowKnob.BorderSizePixel = 0;lowKnob.Active = true;lowKnob.ZIndex = 207
    				init.create_corner(10,lowKnob)
    				init.stroke(lowKnob,0.75,1,Color3.fromRGB(20,21,24))
    
    				local highKnob = lowKnob:Clone()
    				highKnob.Parent = rangeTrack
    
    				local rangeObject = {}
    				local roundValue = function(number)
    					number = math.clamp(number,minimum,maximum)
    					if step > 0 then number = math.floor(number / step + 0.5) * step end
    					if step < 0 then
    						local power = 10 ^ math.abs(step)
    						number = math.floor(number * power + 0.5) / power
    					end
    					return math.clamp(number,minimum,maximum)
    				end
    
    				local formatValue = function(number)
    					if step < 0 then return string.format("%."..math.abs(step).."f",number)..suffix end
    					return tostring(number)..suffix
    				end
    
    				local updateRange = function(newLow,newHigh,callCallback)
    					low = roundValue(tonumber(newLow) or low)
    					high = roundValue(tonumber(newHigh) or high)
    					if low > high then low,high = high,low end
    
    					-- Keep enough space between both knobs so they never overlap.
    					local trackWidth = rangeTrack.AbsoluteSize.X
    					local visualGap = (maximum-minimum) * (18 / math.max(trackWidth,120))
    					local minimumGap = math.max(tonumber(rangeData.Gap) or 0,visualGap)
    					minimumGap = math.min(minimumGap,maximum-minimum)
    					if high-low < minimumGap then
    						if draggingHandle == "low" then
    							low = math.max(minimum,high-minimumGap)
    						elseif draggingHandle == "high" then
    							high = math.min(maximum,low+minimumGap)
    						else
    							high = low+minimumGap
    							if high > maximum then
    								high = maximum
    								low = maximum-minimumGap
    							end
    						end
    					end
    					local lowPercent = (low-minimum)/(maximum-minimum)
    					local highPercent = (high-minimum)/(maximum-minimum)
    					rangeValue.Text = formatValue(low)..", "..formatValue(high)
    					lowKnob.Position = UDim2.fromScale(lowPercent,0.5)
    					highKnob.Position = UDim2.fromScale(highPercent,0.5)
    					rangeFill.Position = UDim2.fromScale(lowPercent,0);rangeFill.Size = UDim2.fromScale(highPercent-lowPercent,1)
    					local result = {low,high}
    					if not rangeOff and rangeData.Title and getgenv().configs[rangeData.Title] ~= nil then
    						getgenv().configs[rangeData.Title] = result
    					end
    					if callCallback and rangeData.Callback then task.spawn(rangeData.Callback,result) end
    				end
    
    				local inputValue = function(input)
    					local percent = math.clamp((input.Position.X-rangeTrack.AbsolutePosition.X)/rangeTrack.AbsoluteSize.X,0,1)
    					return minimum + ((maximum-minimum)*percent),percent
    				end
    
    				lowKnob.InputBegan:Connect(function(input)
    					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then draggingHandle = "low";asset["sl-focus"] = true end
    				end)
    				highKnob.InputBegan:Connect(function(input)
    					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then draggingHandle = "high";asset["sl-focus"] = true end
    				end)
    				rangeTrack.InputBegan:Connect(function(input)
    					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
    						local newValue,percent = inputValue(input)
    						local lowPercent = (low-minimum)/(maximum-minimum)
    						local highPercent = (high-minimum)/(maximum-minimum)
    						draggingHandle = math.abs(percent-lowPercent) <= math.abs(percent-highPercent) and "low" or "high"
    						asset["sl-focus"] = true
    						if draggingHandle == "low" then updateRange(math.min(newValue,high),high,true) else updateRange(low,math.max(newValue,low),true) end
    					end
    				end)
    
    				userinputservice.InputChanged:Connect(function(input)
    					if draggingHandle and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
    						local newValue = inputValue(input)
    						if draggingHandle == "low" then updateRange(math.min(newValue,high),high,true) else updateRange(low,math.max(newValue,low),true) end
    					end
    				end)
    				userinputservice.InputEnded:Connect(function(input)
    					if draggingHandle and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
    						draggingHandle = nil
    						asset["sl-release"] = os.clock()
    						asset["sl-focus"] = false
    					end
    				end)
    
    				rangeValue.FocusLost:Connect(function()
    					local numbers = {}
    					for number in string.gmatch(rangeValue.Text,"[-+]?%d*%.?%d+") do table.insert(numbers,tonumber(number)) end
    					updateRange(numbers[1] or low,numbers[2] or high,true)
    				end)
    
    				function rangeObject:SetValue(newValues)
    					if type(newValues) == "table" then updateRange(newValues[1],newValues[2],true) end
    				end
    				function rangeObject:Set(newLow,newHigh) updateRange(newLow,newHigh,true) end
    				function rangeObject:Get() return {low,high} end
    
    				updateRange(low,high,false)
    				if rangeData.Default ~= nil and rangeData.Callback then task.spawn(rangeData.Callback,{low,high}) end
    				return rangeObject
    			end
    
    			function toggle_funcs:Toggle(innerData,innerOff)
    				innerData = innerData or {}
    				local configured = innerData.Title and getgenv().configs[innerData.Title]
    				local enabled
    				if innerData.Default ~= nil then
    					enabled = innerData.Default
    				elseif not innerOff and configured ~= nil then
    					enabled = configured
    				else
    					enabled = false
    				end
    
    				local innerRow = Instance.new("Frame",detailContent)
    				innerRow.BackgroundTransparency = 1;innerRow.BorderSizePixel = 0;innerRow.Size = UDim2.new(1,0,0,36);innerRow.ZIndex = 204
    
    				local innerTitle = Instance.new("TextLabel",innerRow)
    				innerTitle.BackgroundTransparency = 1;innerTitle.Size = UDim2.new(1,-52,1,0);innerTitle.FontFace = Font.fromName("Montserrat",Enum.FontWeight.Regular,Enum.FontStyle.Normal);innerTitle.Text = innerData.Title or "Toggle";innerTitle.TextColor3 = Color3.fromRGB(210,211,216);innerTitle.TextSize = 11;innerTitle.TextTruncate = Enum.TextTruncate.AtEnd;innerTitle.TextXAlignment = Enum.TextXAlignment.Left;innerTitle.ZIndex = 205
    
    				local innerSwitch = Instance.new("Frame",innerRow)
    				innerSwitch.AnchorPoint = Vector2.new(1,0.5);innerSwitch.Position = UDim2.new(1,0,0.5,0);innerSwitch.Size = UDim2.fromOffset(34,18);innerSwitch.BackgroundColor3 = Color3.fromRGB(47,48,54);innerSwitch.BorderSizePixel = 0;innerSwitch.ZIndex = 205
    				init.create_corner(20,innerSwitch)
    				init.stroke(innerSwitch,0,1,Color3.fromRGB(65,66,72))
    
    				local innerCircle = Instance.new("Frame",innerSwitch)
    				innerCircle.AnchorPoint = Vector2.new(0.5,0.5);innerCircle.Position = UDim2.new(0,9,0.5,0);innerCircle.Size = UDim2.fromOffset(12,12);innerCircle.BackgroundColor3 = Color3.fromRGB(220,221,225);innerCircle.BorderSizePixel = 0;innerCircle.ZIndex = 206
    				init.create_corner(20,innerCircle)
    
    				local innerButton = Instance.new("TextButton",innerRow)
    				innerButton.Size = UDim2.fromScale(1,1);innerButton.BackgroundTransparency = 1;innerButton.AutoButtonColor = false;innerButton.Text = "";innerButton.ZIndex = 207
    
    				local innerObject = {}
    				local updateInner = function(state,callCallback,animate)
    					enabled = state and true or false
    					local properties = {
    						BackgroundColor3 = enabled and PRIMARY_COLOR or Color3.fromRGB(47,48,54)
    					}
    					local circleProperties = {
    						Position = enabled and UDim2.new(1,-9,0.5,0) or UDim2.new(0,9,0.5,0),
    						BackgroundColor3 = enabled and Color3.fromRGB(255,255,255) or Color3.fromRGB(220,221,225)
    					}
    					if animate then
    						init.tween(innerSwitch,0.18,Enum.EasingStyle.Circular,properties)
    						init.tween(innerCircle,0.18,Enum.EasingStyle.Circular,circleProperties)
    					else
    						for property,value in properties do innerSwitch[property] = value end
    						for property,value in circleProperties do innerCircle[property] = value end
    					end
    					if not innerOff and innerData.Title and getgenv().configs[innerData.Title] ~= nil then
    						getgenv().configs[innerData.Title] = enabled
    					end
    					if callCallback and innerData.Callback then task.spawn(innerData.Callback,enabled) end
    				end
    
    				innerButton.MouseButton1Click:Connect(function()
    					updateInner(not enabled,true,true)
    				end)
    
    				function innerObject:SetValue(state) updateInner(state,true,true) end
    				function innerObject:Set(state) updateInner(state,true,true) end
    				function innerObject:Get() return enabled end
    
    				updateInner(enabled,false,false)
    				if innerData.Default ~= nil and innerData.Callback then task.spawn(innerData.Callback,enabled) end
    				return innerObject
    			end
    
    			function toggle_funcs:Button(buttonData)
    				buttonData = buttonData or {}
    
    				local buttonRow = Instance.new("Frame",detailContent)
    				buttonRow.BackgroundTransparency = 1;buttonRow.BorderSizePixel = 0;buttonRow.Size = UDim2.new(1,0,0,36);buttonRow.ZIndex = 204
    
    				local buttonTitle = Instance.new("TextLabel",buttonRow)
    				buttonTitle.BackgroundTransparency = 1;buttonTitle.Size = UDim2.new(0.49,0,1,0);buttonTitle.FontFace = Font.fromName("Montserrat",Enum.FontWeight.Regular,Enum.FontStyle.Normal);buttonTitle.Text = buttonData.Title or "Button";buttonTitle.TextColor3 = Color3.fromRGB(210,211,216);buttonTitle.TextSize = 11;buttonTitle.TextTruncate = Enum.TextTruncate.AtEnd;buttonTitle.TextXAlignment = Enum.TextXAlignment.Left;buttonTitle.ZIndex = 205
    
    				local actionButton = Instance.new("TextButton",buttonRow)
    				actionButton.AnchorPoint = Vector2.new(1,0.5);actionButton.Position = UDim2.new(1,0,0.5,0);actionButton.Size = UDim2.new(0.5,0,0,26);actionButton.BackgroundColor3 = PRIMARY_COLOR;actionButton.BorderSizePixel = 0;actionButton.AutoButtonColor = false;actionButton.ClipsDescendants = true;actionButton.FontFace = Font.fromName("Montserrat",Enum.FontWeight.SemiBold,Enum.FontStyle.Normal);actionButton.Text = buttonData.Text or buttonData.ButtonText or "Execute";actionButton.TextColor3 = Color3.fromRGB(255,255,255);actionButton.TextSize = 10;actionButton.TextTruncate = Enum.TextTruncate.AtEnd;actionButton.ZIndex = 205
    				init.create_corner(4,actionButton)
    
    				local buttonObject = {}
    				local pressing = false
    				local fireCallback = function()
    					if buttonData.Callback then task.spawn(buttonData.Callback) end
    				end
    
    				actionButton.MouseEnter:Connect(function()
    					if not pressing then
    						init.tween(actionButton,0.15,Enum.EasingStyle.Circular,{BackgroundColor3 = PRIMARY_HOVER})
    					end
    				end)
    				actionButton.MouseLeave:Connect(function()
    					pressing = false
    					init.tween(actionButton,0.15,Enum.EasingStyle.Circular,{BackgroundColor3 = PRIMARY_COLOR})
    				end)
    				actionButton.MouseButton1Down:Connect(function()
    					pressing = true
    					init.tween(actionButton,0.08,Enum.EasingStyle.Circular,{BackgroundColor3 = PRIMARY_PRESSED})
    				end)
    				actionButton.MouseButton1Up:Connect(function()
    					pressing = false
    					init.tween(actionButton,0.12,Enum.EasingStyle.Circular,{BackgroundColor3 = PRIMARY_HOVER})
    				end)
    				actionButton.MouseButton1Click:Connect(function()
    					init.animatedcircle("Circle3",actionButton,Color3.fromRGB(255,255,255),Color3.fromRGB(255,255,255))
    					fireCallback()
    				end)
    
    				function buttonObject:Fire()
    					fireCallback()
    					init.tween(actionButton,0.08,Enum.EasingStyle.Circular,{BackgroundColor3 = PRIMARY_PRESSED})
    					task.delay(0.09,function()
    						if actionButton.Parent then init.tween(actionButton,0.12,Enum.EasingStyle.Circular,{BackgroundColor3 = PRIMARY_COLOR}) end
    					end)
    				end
    				function buttonObject:SetText(text)
    					actionButton.Text = tostring(text)
    				end
    
    				return buttonObject
    			end
    
    			function toggle_funcs:Label(labelData)
    				labelData = type(labelData) == "table" and labelData or {Text = labelData}
    				
    				local labelRow = Instance.new("Frame",detailContent)
    				labelRow.BackgroundTransparency = 1;labelRow.BorderSizePixel = 0;labelRow.Size = UDim2.new(1,0,0,16);labelRow.ZIndex = 204
    
    				local labelText = Instance.new("TextLabel",labelRow)
    				labelText.BackgroundTransparency = 1;labelText.Size = UDim2.new(1,0,1,0)
    				labelText.FontFace = Font.fromName("Montserrat",labelData.Bold and Enum.FontWeight.SemiBold or Enum.FontWeight.Regular,Enum.FontStyle.Normal)
    				labelText.Text = tostring(labelData.Text or labelData.Title or "Label");labelText.TextColor3 = labelData.Color or Color3.fromRGB(170,171,178)
    				labelText.TextSize = labelData.Size or 11;labelText.TextWrapped = true;labelText.TextXAlignment = labelData.Align or Enum.TextXAlignment.Left;labelText.TextYAlignment = Enum.TextYAlignment.Top;labelText.ZIndex = 205
    
    				local resizeLabel = function()
    					labelRow.Size = UDim2.new(1,0,0,math.max(16,math.ceil(labelText.TextBounds.Y)))
    				end
    				labelText:GetPropertyChangedSignal("TextBounds"):Connect(resizeLabel)
    				resizeLabel()
    				return labelText
    			end
    
    			function toggle_funcs:Line()
    				local lineRow = Instance.new("Frame",detailContent)
    				lineRow.BackgroundTransparency = 1;lineRow.BorderSizePixel = 0;lineRow.Size = UDim2.new(1,0,0,9);lineRow.ZIndex = 204
    
    				local line = Instance.new("Frame",lineRow)
    				line.AnchorPoint = Vector2.new(0,0.5);line.Position = UDim2.new(0,0,0.5,0);line.Size = UDim2.new(1,0,0,1)
    				line.BackgroundColor3 = Color3.fromRGB(66,67,74);line.BackgroundTransparency = 0.25;line.BorderSizePixel = 0;line.ZIndex = 205
    
    				return lineRow
    			end
    
    			function toggle_funcs:Textbox(textboxData,textboxOff)
    				textboxData = textboxData or {}
    				local configured = textboxData.Title and getgenv().configs[textboxData.Title]
    				local current = textboxData.Default
    				if current == nil and not textboxOff and configured ~= nil then current = configured end
    				if current == nil then current = "" end
    				current = tostring(current)
    
    				local textboxRow = Instance.new("Frame",detailContent)
    				textboxRow.BackgroundTransparency = 1;textboxRow.BorderSizePixel = 0;textboxRow.Size = UDim2.new(1,0,0,36);textboxRow.ZIndex = 204
    
    				local textboxTitle = Instance.new("TextLabel",textboxRow)
    				textboxTitle.BackgroundTransparency = 1;textboxTitle.Size = UDim2.new(0.49,0,1,0);textboxTitle.FontFace = Font.fromName("Montserrat",Enum.FontWeight.Regular,Enum.FontStyle.Normal);textboxTitle.Text = textboxData.Title or "Textbox";textboxTitle.TextColor3 = Color3.fromRGB(210,211,216);textboxTitle.TextSize = 11;textboxTitle.TextTruncate = Enum.TextTruncate.AtEnd;textboxTitle.TextXAlignment = Enum.TextXAlignment.Left;textboxTitle.ZIndex = 205
    
    				local inputBox = Instance.new("TextBox",textboxRow)
    				inputBox.AnchorPoint = Vector2.new(1,0.5);inputBox.Position = UDim2.new(1,0,0.5,0);inputBox.Size = UDim2.new(0.5,0,0,26);inputBox.BackgroundColor3 = Color3.fromRGB(29,30,35);inputBox.BorderSizePixel = 0;inputBox.ClearTextOnFocus = textboxData.ClearTextOnFocus or false;inputBox.FontFace = Font.fromName("Montserrat",Enum.FontWeight.Regular,Enum.FontStyle.Normal);inputBox.PlaceholderText = textboxData.Placeholder or "Type here...";inputBox.PlaceholderColor3 = Color3.fromRGB(105,106,113);inputBox.Text = current;inputBox.TextColor3 = Color3.fromRGB(220,221,225);inputBox.TextSize = 10;inputBox.TextTruncate = Enum.TextTruncate.AtEnd;inputBox.TextXAlignment = Enum.TextXAlignment.Left;inputBox.ZIndex = 205
    				init.create_corner(4,inputBox)
    				local inputStroke = init.stroke(inputBox,0,1,Color3.fromRGB(50,51,57))
    
    				local textboxPadding = Instance.new("UIPadding",inputBox)
    				textboxPadding.PaddingLeft = UDim.new(0,8);textboxPadding.PaddingRight = UDim.new(0,8)
    
    				local textboxObject = {}
    				local changingInternally = false
    				local normalize = function(text)
    					text = tostring(text or "")
    					if textboxData.Numeric then
    						local number = string.match(text,"[-+]?%d*%.?%d+")
    						return number or ""
    					end
    					if textboxData.MaxLength and #text > textboxData.MaxLength then
    						return string.sub(text,1,textboxData.MaxLength)
    					end
    					return text
    				end
    
    				local applyText = function(text,callCallback)
    					current = normalize(text)
    					changingInternally = true
    					inputBox.Text = current
    					changingInternally = false
    					local callbackValue = textboxData.Numeric and tonumber(current) or current
    					if not textboxOff and textboxData.Title and getgenv().configs[textboxData.Title] ~= nil then
    						getgenv().configs[textboxData.Title] = callbackValue
    					end
    					if callCallback and textboxData.Callback then task.spawn(textboxData.Callback,callbackValue) end
    				end
    
    				inputBox.Focused:Connect(function()
    					init.tween(inputStroke,0.15,Enum.EasingStyle.Circular,{Color = PRIMARY_COLOR})
    				end)
    				inputBox.FocusLost:Connect(function(enterPressed)
    					init.tween(inputStroke,0.15,Enum.EasingStyle.Circular,{Color = Color3.fromRGB(50,51,57)})
    					applyText(inputBox.Text,true)
    					if enterPressed and textboxData.EnterCallback then
    						task.spawn(textboxData.EnterCallback,textboxData.Numeric and tonumber(current) or current)
    					end
    				end)
    				inputBox:GetPropertyChangedSignal("Text"):Connect(function()
    					if changingInternally then return end
    					if textboxData.MaxLength and #inputBox.Text > textboxData.MaxLength then
    						applyText(inputBox.Text,false)
    					end
    					if textboxData.Live then applyText(inputBox.Text,true) end
    				end)
    
    				function textboxObject:Set(text) applyText(text,true) end
    				function textboxObject:SetValue(text) applyText(text,true) end
    				function textboxObject:Get()
    					return textboxData.Numeric and tonumber(current) or current
    				end
    				function textboxObject:Focus() inputBox:CaptureFocus() end
    				function textboxObject:Clear() applyText("",true) end
    
    				applyText(current,false)
    				if textboxData.Default ~= nil and textboxData.Callback then
    					task.spawn(textboxData.Callback,textboxData.Numeric and tonumber(current) or current)
    				end
    				return textboxObject
    			end
    
    			box_frame.MouseEnter:Connect(function()
    				if detailOpened then return end
    				init.tween(box_frame,0.25,Enum.EasingStyle.Circular,{BackgroundColor3 = Color3.fromRGB(54,55,62)})
    			end)
    
    			box_frame.MouseLeave:Connect(function()
    				if detailOpened then return end
    				init.tween(box_frame,0.25,Enum.EasingStyle.Circular,{BackgroundColor3 = Color3.fromRGB(42, 43, 48)})
    			end)
    
    			local fakecallback = function(args)
    				if not loaded then repeat task.wait() until loaded end
    				task.spawn(data.callback,args)
    			end
    
    			box_btn.MouseButton1Click:Connect(function()
    				if detailOpened then
    					closeDetail()
    				else
    					openDetail()
    				end
    			end)
    
    			local updateToggle = function(state,callCallback,animate)
    				toggle_focus = state and true or false
    				if hasToggle then
    					local toggleProperties = {BackgroundColor3 = toggle_focus and PRIMARY_COLOR or Color3.fromRGB(47,48,54)}
    					local circleProperties = {Position = toggle_focus and UDim2.new(0.75,0,0.5,0) or UDim2.new(0.25,0,0.5,0)}
    					if animate then
    						init.tween(toggle,0.2,Enum.EasingStyle.Circular,toggleProperties)
    						init.tween(circle,0.2,Enum.EasingStyle.Circular,circleProperties)
    					else
    						for property,value in toggleProperties do toggle[property] = value end
    						for property,value in circleProperties do circle[property] = value end
    					end
    				end
    				if callCallback then task.spawn(fakecallback,toggle_focus) end
    			end
    
    			if toggleButton then
    				toggleButton.MouseButton1Click:Connect(function()
    					updateToggle(not toggle_focus,true,true)
    				end)
    			end
    
    			function toggle_funcs:SetValue(state)
    				updateToggle(state,true,true)
    			end
    
    			function toggle_funcs:Set(state)
    				updateToggle(state,true,true)
    			end
    
    			function toggle_funcs:Get()
    				return toggle_focus
    			end
    
    			do
    				updateToggle(data.default,false,false)
    				if arr.Default ~= nil then task.spawn(fakecallback,toggle_focus) end
    			end
    
    			return toggle_funcs
    		end
    
    		return func
    	end
    	tabs.Main = main
    	tabs.ScreenGui = sixlyinit
    	return tabs
    end
    return library
end


local library = loadPayomboyUIEngine()
local payom = library.create()

-- ====================================================================
--  BUILD PAYOMBOYZ BLOXZ 6 MASTER TABS
-- ====================================================================
local tabCombat = payom.create(T("tab_combat"))
local tabVisuals = payom.create(T("tab_visuals"))
local tabFarm = payom.create(T("tab_farm"))
local tabMove = payom.create(T("tab_move"))
local tabSecurity = payom.create(T("tab_security"))
local tabSettings = payom.create(T("tab_settings"))

-- TAB 1: COMBAT & DEFENSE
tabCombat.Header({ Title = T("sec_combat") })

local aimbotCard = tabCombat.Toggle({
    Title = T("aimbot_title"),
    Info = T("aimbot_desc"),
    Default = Settings.AimbotEnabled,
    Callback = function(state)
        Settings.AimbotEnabled = state
        if aimMobileBtn then
            aimMobileBtn.Visible = (state and Settings.MobileAimButton)
        end
    end
})
aimbotCard:Toggle({
    Title = T("aimbot_wall"),
    Default = Settings.AimbotWallCheck,
    Callback = function(state) Settings.AimbotWallCheck = state end
})
aimbotCard:Toggle({
    Title = T("aimbot_always"),
    Default = Settings.AimbotAlways,
    Callback = function(state) Settings.AimbotAlways = state end
})
aimbotCard:Toggle({
    Title = T("aimbot_mobile_btn"),
    Default = Settings.MobileAimButton,
    Callback = function(state)
        Settings.MobileAimButton = state
        if aimMobileBtn then
            aimMobileBtn.Visible = (Settings.AimbotEnabled and state)
        end
    end
})
aimbotCard:Toggle({
    Title = T("aimbot_show_fov"),
    Default = Settings.ShowFOV,
    Callback = function(state)
        Settings.ShowFOV = state
        if FOVFrame then FOVFrame.Visible = state end
    end
})
aimbotCard:Slider({
    Title = T("aimbot_fov"),
    Min = 30, Max = 400, Default = Settings.FOVRadius, Round = 1,
    Callback = function(val)
        Settings.FOVRadius = val
        if FOVFrame then FOVFrame.Size = UDim2.new(0, val * 2, 0, val * 2) end
    end
})
aimbotCard:Slider({
    Title = T("aimbot_dist"),
    Min = 50, Max = 1500, Default = Settings.MaxDistance, Round = 10,
    Callback = function(val) Settings.MaxDistance = val end
})
aimbotCard:Toggle({
    Title = T("aimbot_team"),
    Default = Settings.TeamCheck,
    Callback = function(state) Settings.TeamCheck = state end
})

local norecoilCard = tabCombat.Toggle({
    Title = T("norecoil_title"),
    Info = T("norecoil_desc"),
    Default = Settings.NoRecoil,
    Callback = function(state) WarZ.SetNoRecoil(state) end
})
norecoilCard:Button({
    Title = T("norecoil_restore"),
    Text = "Restore",
    Callback = function() WarZ.SetNoRecoil(false); norecoilCard:Set(false) end
})

local autohealCard = tabCombat.Toggle({
    Title = T("autoheal_title"),
    Info = T("autoheal_desc"),
    Default = Settings.AutoHeal,
    Callback = function(state) WarZ.SetAutoHeal(state) end
})
autohealCard:Dropdown({
    Title = T("autoheal_item"),
    Values = { "BandagesDX", "Medkit", "Bandages", "Painkiller" },
    Default = Settings.AutoHealItem,
    Callback = function(val) Settings.AutoHealItem = val end
})
autohealCard:Slider({
    Title = T("autoheal_thresh"),
    Min = 20, Max = 95, Default = math.floor(Settings.AutoHealThreshold * 100), Round = 1, Suffix = "%",
    Callback = function(val) Settings.AutoHealThreshold = val / 100 end
})
autohealCard:Slider({
    Title = T("autoheal_cd"),
    Min = 0.01, Max = 1.0, Default = Settings.AutoHealCooldown, Round = -2, Suffix = "s",
    Callback = function(val) Settings.AutoHealCooldown = val end
})

local fpsCard = tabCombat.Toggle({
    Title = T("fpsboost_title"),
    Info = T("fpsboost_desc"),
    Default = Settings.FPSBoost,
    Callback = function(state) WarZ.ToggleFPSBoost(state) end
})

-- TAB 2: VISUALS & ESP
tabVisuals.Header({ Title = T("sec_visuals") })

local chamsCard = tabVisuals.Toggle({
    Title = T("chams_title"),
    Info = T("chams_desc"),
    Default = Settings.HighlightESP,
    Callback = function(state)
        Settings.HighlightESP = state
        if not state then
            for _, p in ipairs(Players:GetPlayers()) do
                if p.Character then
                    local hl = p.Character:FindFirstChild("PayomboyZHighlight")
                    if hl then pcall(function() hl:Destroy() end) end
                end
            end
        end
    end
})
chamsCard:Toggle({
    Title = T("chams_wall"),
    Default = Settings.ChamsThroughWalls,
    Callback = function(state) Settings.ChamsThroughWalls = state end
})
chamsCard:Toggle({
    Title = T("chams_outline"),
    Default = Settings.ChamsOutline,
    Callback = function(state) Settings.ChamsOutline = state end
})
chamsCard:Slider({
    Title = T("chams_trans"),
    Min = 0, Max = 100, Default = math.floor(Settings.ChamsFillTransparency * 100), Round = 5, Suffix = "%",
    Callback = function(val) Settings.ChamsFillTransparency = val / 100 end
})

local chamsPresets = {
    { "แดง", Color3.fromRGB(255, 45, 85) },
    { "ฟ้า", Color3.fromRGB(0, 210, 255) },
    { "เขียว", Color3.fromRGB(46, 224, 140) },
    { "เหลือง", Color3.fromRGB(255, 220, 60) },
    { "ม่วง", Color3.fromRGB(200, 102, 255) },
    { "ขาว", Color3.fromRGB(255, 255, 255) },
}
local chamsPresetIdx = 1
chamsCard:Button({
    Title = T("chams_color_cycle"),
    Text = "Cycle Color",
    Callback = function()
        chamsPresetIdx = (chamsPresetIdx % #chamsPresets) + 1
        local pr = chamsPresets[chamsPresetIdx]
        Settings.ChamsColor = pr[2]
        Settings.ChamsOutlineColor = pr[2]
        notify("Chams Color", "เปลี่ยนเป็นสี: " .. pr[1], 2)
    end
})

local boxespCard = tabVisuals.Toggle({
    Title = T("boxesp_title"),
    Info = T("boxesp_desc"),
    Default = Settings.BoxESP,
    Callback = function(state)
        Settings.BoxESP = state
        if not state then
            for _, b in pairs(espBoxes) do b.Visible = false end
        end
    end
})

local tracersCard = tabVisuals.Toggle({
    Title = T("tracers_title"),
    Info = T("tracers_desc"),
    Default = Settings.Tracers,
    Callback = function(state)
        Settings.Tracers = state
        Settings.ESPEnabled = state
        if not state then
            for _, line in pairs(tracers) do line.Visible = false end
            for _, label in pairs(espLabels) do label.Visible = false end
        end
    end
})
tracersCard:Slider({
    Title = T("tracers_dist"),
    Min = 100, Max = 1500, Default = Settings.TracerDistance, Round = 25, Suffix = " studs",
    Callback = function(val) Settings.TracerDistance = val end
})

local lootespCard = tabVisuals.Toggle({
    Title = T("lootesp_title"),
    Info = T("lootesp_desc"),
    Default = Settings.LootESP,
    Callback = function(state) WarZ.SetLootESP(state) end
})
lootespCard:Slider({
    Title = T("lootesp_dist"),
    Min = 50, Max = 600, Default = Settings.LootMaxDistance, Round = 10, Suffix = " studs",
    Callback = function(val) Settings.LootMaxDistance = val end
})

-- TAB 3: FARMING & FISHING AUTOMATION SUITE
tabFarm.Header({ Title = T("sec_farm") })

local fishCard = tabFarm.Toggle({
    Title = T("autofish_title"),
    Info = T("autofish_desc"),
    Default = Settings.AutoFish,
    Callback = function(state) WarZ.SetAutoFish(state) end
})
fishCard:Toggle({
    Title = T("fish_perfect"),
    Default = Settings.FishPerfectReel,
    Callback = function(state) Settings.FishPerfectReel = state end
})
fishCard:Toggle({
    Title = T("fish_autowalk"),
    Default = Settings.FishAutoWalk,
    Callback = function(state) Settings.FishAutoWalk = state end
})
fishCard:Toggle({
    Title = T("fish_safezone"),
    Default = Settings.FishSafeZonePriority,
    Callback = function(state) Settings.FishSafeZonePriority = state end
})
fishCard:Slider({
    Title = T("fish_delay"),
    Min = 0.8, Max = 3.5, Default = Settings.FishCastDelay, Round = -1, Suffix = "s",
    Callback = function(val) Settings.FishCastDelay = val end
})
fishCard:Line()
fishCard:Label({ Text = T("fish_status_title"), Bold = true, Color = COLORS.cyan })
FishingStatusLabel = fishCard:Label({ Text = T("fish_status_ready"), Color = COLORS.textMuted })
fishCard:Line()
fishCard:Label({ Text = T("fish_count_title"), Bold = true, Color = COLORS.success })
FishingCountLabel = fishCard:Label({ Text = "0 " .. (currentLang == "TH" and "ตัว" or "Fish"), Color = Color3.fromRGB(255, 255, 255) })

local autolootCard = tabFarm.Toggle({
    Title = T("autoloot_title"),
    Info = T("autoloot_desc"),
    Default = Settings.AutoLoot,
    Callback = function(state) WarZ.SetAutoLoot(state) end
})
autolootCard:Slider({
    Title = T("autoloot_range"),
    Min = 4.0, Max = 35.0, Default = Settings.AutoLootRange, Round = 1, Suffix = " studs",
    Callback = function(val) Settings.AutoLootRange = val end
})
autolootCard:Slider({
    Title = T("autoloot_hold"),
    Min = 0.5, Max = 1.5, Default = Settings.AutoLootHold, Round = -2, Suffix = "s",
    Callback = function(val) Settings.AutoLootHold = val end
})

local farmRunnerCard = tabFarm.Toggle({
    Title = T("autofarm_title"),
    Info = T("autofarm_desc"),
    Default = Settings.AutoFarmLoot,
    Callback = function(state) WarZ.SetAutoFarmLoot(state) end
})
farmRunnerCard:Dropdown({
    Title = T("autofarm_filter"),
    Values = {
        "ของมีค่าทั้งหมด (ปืน เกราะ ยา แม็ก)",
        "ปืนและชุดเกราะ (Guns and Armor)",
        "ยาและของใช้ (Meds and Supplies)",
        "เก็บทุกอย่าง (Everything)"
    },
    Default = Settings.FarmLootFilter,
    Callback = function(val) Settings.FarmLootFilter = val end
})
farmRunnerCard:Slider({
    Title = T("autofarm_dist"),
    Min = 30, Max = 300, Default = Settings.FarmLootDistance, Round = 10, Suffix = " studs",
    Callback = function(val) Settings.FarmLootDistance = val end
})
farmRunnerCard:Slider({
    Title = T("autofarm_speed"),
    Min = 14, Max = 22, Default = Settings.FarmLootSpeed, Round = 1, Suffix = " studs/s",
    Callback = function(val) Settings.FarmLootSpeed = val end
})
farmRunnerCard:Toggle({
    Title = T("autofarm_avoid"),
    Default = Settings.FarmStopOnEnemy,
    Callback = function(state) Settings.FarmStopOnEnemy = state end
})
farmRunnerCard:Line()
farmRunnerCard:Label({ Text = T("autofarm_status"), Bold = true, Color = COLORS.cyan })
FarmLootStatusLabel = farmRunnerCard:Label({ Text = "พร้อมใช้งาน (ปิดอยู่)", Color = COLORS.textMuted })

-- TAB 4: MOVEMENT & PHYSICS
tabMove.Header({ Title = T("sec_move") })

local infStaminaCard = tabMove.Toggle({
    Title = T("infstamina_title"),
    Info = T("infstamina_desc"),
    Default = Settings.InfiniteStamina,
    Callback = function(state) WarZ.SetInfiniteStamina(state) end
})

local bhopCard = tabMove.Toggle({
    Title = T("bhop_title"),
    Info = T("bhop_desc"),
    Default = Settings.BunnyHop,
    Callback = function(state) Settings.BunnyHop = state end
})

local speedCard = tabMove.Toggle({
    Title = T("walkspeed_title"),
    Info = T("walkspeed_desc"),
    Default = Settings.WalkSpeedEnabled,
    Callback = function(state)
        Settings.WalkSpeedEnabled = state
        if not state and restoreWalkSpeed then restoreWalkSpeed() end
    end
})
speedCard:Slider({
    Title = T("walkspeed_val"),
    Min = 16, Max = 120, Default = Settings.WalkSpeedValue, Round = 1, Suffix = " studs/s",
    Callback = function(val) Settings.WalkSpeedValue = val end
})

local flyCard = tabMove.Toggle({
    Title = T("fly_title"),
    Info = T("fly_desc"),
    Default = Settings.Fly,
    Callback = function(state)
        Settings.Fly = state
        if flyMobileHolder then
            flyMobileHolder.Visible = (state and Settings.MobileFlyControls)
        end
        if not state and stopFly then stopFly() end
    end
})
flyCard:Toggle({
    Title = "Mobile Controls (ปุ่มบินขึ้น/ลง บนจอมือถือ)",
    Default = Settings.MobileFlyControls,
    Callback = function(state)
        Settings.MobileFlyControls = state
        if flyMobileHolder then
            flyMobileHolder.Visible = (Settings.Fly and state)
        end
    end
})
flyCard:Slider({
    Title = T("fly_speed"),
    Min = 15, Max = 150, Default = Settings.FlySpeed, Round = 1, Suffix = " studs/s",
    Callback = function(val) Settings.FlySpeed = val end
})

local noclipCard = tabMove.Toggle({
    Title = T("noclip_title"),
    Info = T("noclip_desc"),
    Default = Settings.Noclip,
    Callback = function(state) Settings.Noclip = state end
})

-- TAB 5: SECURITY, SAFEZONE STASH & ANTI-BAC GUARD
tabSecurity.Header({ Title = T("sec_security") })

local antibacCard = tabSecurity.Toggle({
    Title = T("antibac_guard_title"),
    Info = T("antibac_guard_desc"),
    Default = Settings.AntiBACGuard,
    Callback = function(state)
        Settings.AntiBACGuard = state
        notify("Anti-BAC Guard", state and "ระบบตรวจจับและป้องกัน Kick-BAC เปิดทำงานแล้ว" or "ปิดระบบ Anti-BAC Guard", 2.5)
    end
})

local storageCard = tabSecurity.Toggle({
    Title = T("storage_title"),
    Info = T("storage_desc"),
    HasToggle = false
})
storageCard:Button({
    Title = T("btn_deposit_all"),
    Text = "Deposit Stash",
    Callback = function() WarZ.DepositAllToStash() end
})
storageCard:Button({
    Title = T("btn_combine_mags"),
    Text = "Combine Mags",
    Callback = function() WarZ.CombineMagazines() end
})
storageCard:Button({
    Title = T("btn_claim_gifts"),
    Text = "Claim Gifts",
    Callback = function() WarZ.ClaimCommunityRewards() end
})

local antivoidCard = tabSecurity.Toggle({
    Title = T("antivoid_title"),
    Info = T("antivoid_desc"),
    Default = Settings.AntiVoid,
    Callback = function(state) Settings.AntiVoid = state end
})

-- TAB 6: SETTINGS, LANGUAGE & WEBHOOK
tabSettings.Header({ Title = T("sec_settings") })

local langCard = tabSettings.Toggle({
    Title = T("lang_title"),
    Info = T("lang_desc"),
    HasToggle = false
})
langCard:Button({
    Title = T("btn_toggle_lang"),
    Text = "Switch Language",
    Callback = function()
        currentLang = (currentLang == "TH") and "EN" or "TH"
        notify("Language / ภาษา", (currentLang == "TH" and "เปลี่ยนภาษาเป็น ภาษาไทย เรียบร้อยแล้ว" or "Switched Language to English successfully!"), 3)
    end
})

local serverCard = tabSettings.Toggle({
    Title = "Server Control",
    Info = "Rejoin server หรือ ย้ายเซิร์ฟเวอร์ใหม่",
    HasToggle = false
})
serverCard:Button({
    Title = "🔄 Rejoin Server (เข้าเซิร์ฟเดิมซ้ำ)",
    Text = "Rejoin",
    Callback = function()
        if #Players:GetPlayers() <= 1 then
            TeleportService:Teleport(game.PlaceId, LocalPlayer)
        else
            TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
        end
    end
})
serverCard:Button({
    Title = "🌐 Server Hop (สุ่มย้ายเซิร์ฟเวอร์คนไม่เต็ม)",
    Text = "Server Hop",
    Callback = function()
        local success, result = pcall(function()
            return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/0?sortOrder=Asc&limit=100"))
        end)
        if success and result and result.data then
            for _, server in ipairs(result.data) do
                if server.id ~= game.JobId and server.playing < server.maxPlayers then
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, LocalPlayer)
                    return
                end
            end
        end
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end
})

local webhookCard = tabSettings.Toggle({
    Title = T("webhook_title"),
    Info = T("webhook_desc"),
    Default = Settings.WebhookEnabled,
    Callback = function(state) Settings.WebhookEnabled = state end
})
webhookCard:Textbox({
    Title = T("webhook_url_label"),
    Placeholder = "https://discord.com/api/webhooks/...",
    Default = Settings.WebhookURL,
    Callback = function(val) Settings.WebhookURL = val end
})
webhookCard:Button({
    Title = T("btn_test_webhook"),
    Text = "Test Webhook",
    Callback = function()
        if Settings.WebhookURL and Settings.WebhookURL ~= "" then
            pcall(function()
                local HttpRequest = (syn and syn.request) or (http and http.request) or http_request or request
                if HttpRequest then
                    HttpRequest({
                        Url = Settings.WebhookURL,
                        Method = "POST",
                        Headers = { ["Content-Type"] = "application/json" },
                        Body = HttpService:JSONEncode({
                            content = "📡 **PayomboyZ BloxZ Hub** | Webhook Test Successful!\nPlayer: " .. LocalPlayer.Name .. " | Time: " .. os.date("%X")
                        })
                    })
                    notify("Webhook", "ส่งข้อความทดสอบเรียบร้อยแล้ว", 3)
                end
            end)
        else
            notify("Webhook", "กรุณาวาง Discord Webhook URL ก่อน", 3)
        end
    end
})

-- ====================================================================
--  AUXILIARY FLOATING HUD CAPSULE
-- ====================================================================
local mainFrame = payom and payom.Main
if not mainFrame then
    pcall(function()
        local parents = { CoreGui, LocalPlayer:FindFirstChild("PlayerGui") }
        if gethui then pcall(function() table.insert(parents, gethui()) end) end
        for _, p in ipairs(parents) do
            if p then
                for _, g in ipairs(p:GetChildren()) do
                    if g:IsA("ScreenGui") and g:FindFirstChild("@main") then
                        mainFrame = g["@main"]
                        break
                    end
                end
            end
            if mainFrame then break end
        end
    end)
end

local hudGui = Instance.new("ScreenGui")
hudGui.Name = "PayomboyZ_HUD"
hudGui.ResetOnSpawn = false
hudGui.DisplayOrder = 1000

local targetHudParent = (gethui and gethui()) or CoreGui or (LocalPlayer and LocalPlayer:WaitForChild("PlayerGui", 5))
pcall(function() hudGui.Parent = targetHudParent end)

local hudFrame = Instance.new("Frame", hudGui)
hudFrame.Name = "CapsuleHUD"
hudFrame.Size = UDim2.fromOffset(195, 54)
hudFrame.Position = (UserInputService:GetPlatform() == Enum.Platform.Windows) and UDim2.new(0, 12, 0.5, -27) or UDim2.new(0, 12, 0, 75)
hudFrame.BackgroundColor3 = Color3.fromRGB(18, 19, 24)
hudFrame.BackgroundTransparency = 0.15
hudFrame.Active = true

local hudCorner = Instance.new("UICorner", hudFrame)
hudCorner.CornerRadius = UDim.new(1, 0)

local hudStroke = Instance.new("UIStroke", hudFrame)
hudStroke.Thickness = 1.5
hudStroke.Color = Color3.fromRGB(0, 210, 255)
hudStroke.Transparency = 0.2

local avatarImg = Instance.new("ImageLabel", hudFrame)
avatarImg.Size = UDim2.fromOffset(40, 40)
avatarImg.Position = UDim2.new(0, 7, 0.5, -20)
avatarImg.BackgroundColor3 = Color3.fromRGB(28, 30, 36)
avatarImg.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"

task.spawn(function()
    pcall(function()
        avatarImg.Image = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
    end)
end)

local avCorner = Instance.new("UICorner", avatarImg)
avCorner.CornerRadius = UDim.new(1, 0)
local avStroke = Instance.new("UIStroke", avatarImg)
avStroke.Thickness = 1.5
avStroke.Color = COLORS.primary

local hudTitle = Instance.new("TextLabel", hudFrame)
hudTitle.Size = UDim2.new(0, 135, 0, 18)
hudTitle.Position = UDim2.new(0, 52, 0, 9)
hudTitle.BackgroundTransparency = 1
hudTitle.Text = "PAYOMBØYZ BLOXZ"
hudTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
hudTitle.TextSize = 11
hudTitle.FontFace = Font.fromName("Montserrat", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
hudTitle.TextXAlignment = Enum.TextXAlignment.Left

local statsLbl = Instance.new("TextLabel", hudFrame)
statsLbl.Size = UDim2.new(0, 135, 0, 16)
statsLbl.Position = UDim2.new(0, 52, 0, 28)
statsLbl.BackgroundTransparency = 1
statsLbl.Text = "FPS: -- | PING: -- ms"
statsLbl.TextColor3 = Color3.fromRGB(155, 165, 185)
statsLbl.TextSize = 10
statsLbl.FontFace = Font.fromName("Montserrat", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
statsLbl.TextXAlignment = Enum.TextXAlignment.Left

local hudBtn = Instance.new("TextButton", hudFrame)
hudBtn.Size = UDim2.fromScale(1, 1)
hudBtn.BackgroundTransparency = 1
hudBtn.Text = ""
hudBtn.ZIndex = 10

local isMainVisible = true
local function toggleMainWindow()
    if mainFrame then
        isMainVisible = not isMainVisible
        mainFrame.Visible = isMainVisible
        hudStroke.Color = isMainVisible and Color3.fromRGB(0, 210, 255) or Color3.fromRGB(255, 75, 100)
    end
end

local dragging, dragStart, startPos = false, nil, nil
local hasDragged = false

local function onHudToggle()
    if not hasDragged then
        toggleMainWindow()
    end
end

hudBtn.MouseButton1Click:Connect(onHudToggle)
if hudBtn.Activated then hudBtn.Activated:Connect(onHudToggle) end

hudBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        hasDragged = false
        dragStart = input.Position
        startPos = hudFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                task.wait(0.05)
                dragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        if delta.Magnitude > 6 then
            hasDragged = true
            hudFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end
end)

UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and (input.KeyCode == Enum.KeyCode.RightControl or input.KeyCode == Enum.KeyCode.Insert) then
        toggleMainWindow()
    end
end)

local fpsFrames = 0
local fpsTime = os.clock()
bind(RunService.RenderStepped, function()
    fpsFrames = fpsFrames + 1
    local now = os.clock()
    if now - fpsTime >= 1.0 then
        local curFps = math.floor(fpsFrames / (now - fpsTime))
        local curPing = 0
        pcall(function() curPing = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue()) end)
        statsLbl.Text = string.format("FPS: %d | PING: %d ms", curFps, curPing)
        fpsFrames = 0
        fpsTime = now
    end
end)

-- ====================================================================
--  SESSION CLEANUP REGISTRATION
-- ====================================================================
_G.PayomboyZBloxZCleanup = function()
    RUN = nil
    _G.PayomboyZBloxZRun = nil
    pcall(function() RunService:UnbindFromRenderStep("PayomboyZAimbot") end)
    pcall(restoreWalkSpeed)
    pcall(stopFly)
    if WarZ and WarZ.RestoreRecoil then pcall(WarZ.RestoreRecoil) end
    for _, c in ipairs(_G.PayomboyZBloxZConns) do pcall(function() c:Disconnect() end) end
    table.clear(_G.PayomboyZBloxZConns)
    clearESP()
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character then
            local hl = p.Character:FindFirstChild("PayomboyZHighlight")
            if hl then pcall(function() hl:Destroy() end) end
        end
    end
    safeDestroyGui("PayomboyZ_HUD")
    safeDestroyGui("PayomboyZ_LootESP")
    safeDestroyGui("PayomboyZ_Tracers")
    safeDestroyGui("PayomboyZ_FOV")
    safeDestroyGui("PayomboyZ_NotifHolder")
    safeDestroyGui("PayomboyZ_MobileControls")
end

notify("PayomboyZ BloxZ", currentLang == "TH" and "โหลดระบบ WarZ Automation & Combat Hub สำเร็จแล้ว!" or "PayomboyZ BloxZ Loaded Successfully!", 4)
