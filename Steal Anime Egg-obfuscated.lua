-- ==========================================
-- ฝั่งแมพ: ตรวจสอบการรันผ่าน Loader
-- ==========================================

-- 1. ดึงค่าจาก getgenv() หรือ _G ออกมาเก็บไว้ในตัวแปร local
local supportedGames = (getgenv and getgenv().PayomboyZ_SupportedGames) or _G.PayomboyZ_SupportedGames

-- 2. เช็กว่ามีข้อมูลส่งมาจาก Loader จริงไหม (ถ้ารันตรงๆ จะติด Kick ตรงนี้)
if not supportedGames then
    game:GetService("Players").LocalPlayer:Kick("อย่าเอามือดีก๊อป URL กูไปรัน! รันผ่าน Loader เท่านั้นสัส")
    return
end

-- 3. [Optional] ลบค่าใน Global ทิ้งทันทีเพื่อความปลอดภัย (ไม่ให้แอบก๊อปค่าทีหลัง)
if getgenv and getgenv().PayomboyZ_SupportedGames then 
    getgenv().PayomboyZ_SupportedGames = nil 
end
_G.PayomboyZ_SupportedGames = nil

-- 4. ถ้าผ่าน ให้สคริปต์ทำงานต่อ
print("Auth Passed! Script Running...")

-- ==========================================
-- สคริปต์หลักของแมพวางต่อตรงนี้ได้เลย
-- ==========================================

--[[
    ╔═══════════════════════════════════════════════════════════════════════╗
    ║                        PAYOMBØYZ HUB V3.0                            ║
    ║        STEAL AN ANIME EGG • ULTIMATE AUTO FARM & EXPLOIT SUITE       ║
    ║                 Engineered by cook45 for clack                       ║
    ║   Obsidian Glassmorphic 2 • Mobile Responsive • Top-Level Modal      ║
    ║   Multi-Islands • Config Manager • Discord Webhook • Smart Engine    ║
    ╚═══════════════════════════════════════════════════════════════════════╝
]]

if not game:IsLoaded() then
    local loaded = false
    local loadedConnection = game.Loaded:Connect(function() loaded = true end)
    local loadWaitStart = os.clock()
    while not loaded and not game:IsLoaded() and (os.clock() - loadWaitStart) < 20 do
        task.wait(0.1)
    end
    loadedConnection:Disconnect()
    if not game:IsLoaded() then
        warn("[SAA] Game load timed out; UI startup cancelled")
        return
    end
end

local ScriptEnv = _G
if typeof(getgenv) == "function" then
    local envOk, env = pcall(getgenv)
    if envOk and type(env) == "table" then ScriptEnv = env end
end
local RunKey = "_PAYOMBZ_SAA_RUN_ID"
ScriptEnv[RunKey] = (tonumber(ScriptEnv[RunKey]) or 0) + 1
local RunId = ScriptEnv[RunKey]
local function isCurrentRun()
    return ScriptEnv[RunKey] == RunId
end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AssetDirectory = nil
task.spawn(function()
    local ok, result = pcall(function()
        return require(ReplicatedStorage.Directory.Assets).Directory
    end)
    if ok then AssetDirectory = result end
end)
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Stats = game:GetService("Stats")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
    local playerWaitStart = os.clock()
    repeat
        task.wait(0.1)
        LocalPlayer = Players.LocalPlayer
    until LocalPlayer or (os.clock() - playerWaitStart) >= 15
end
if not LocalPlayer then
    warn("[SAA] LocalPlayer was not available; UI startup cancelled")
    return
end

local charWaitStart = os.clock()
repeat
    task.wait(0.1)
until (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")) or (os.clock() - charWaitStart > 8)

-----------------------------------------------------------------------------------------
-- 🛡️ 1. LOW-LEVEL ANTI-CHEAT BYPASS & CHARACTER HARDENING
-----------------------------------------------------------------------------------------
local function neuterCharacterAntiCheats(c)
    c = c or LocalPlayer.Character
    if not c then return end

    local pushBack = c:FindFirstChild("AntiCollisionHighSeedPushBack")
    if pushBack and pushBack:IsA("LocalScript") then
        pushBack.Disabled = true
    end

    local hum = c:FindFirstChildOfClass("Humanoid")
    if hum then
        pcall(function()
            hum.BreakJointsOnDeath = false
            hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
            hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
        end)
    end
end

pcall(neuterCharacterAntiCheats)
LocalPlayer.CharacterAdded:Connect(function(c)
    task.wait(0.2)
    pcall(neuterCharacterAntiCheats, c)
end)

if typeof(hookmetamethod) == "function" and not _G["_SAABypassHooked"] then
    _G["_SAABypassHooked"] = true
    local oldNewIndex
    oldNewIndex = hookmetamethod(game, "__newindex", newcclosure(function(self, key, value)
        -- Check the property name first: __newindex runs for every property write
        -- across the client, so avoid typeof/IsA work on the normal hot path.
        if (key == "Enabled" or key == "PlatformStand" or key == "Sit")
            and not checkcaller()
            and typeof(self) == "Instance" then
            if key == "Enabled" and value == false and self:IsA("Motor6D") then
                return nil
            end
            if (key == "PlatformStand" or key == "Sit") and self:IsA("Humanoid") then
                if (key == "PlatformStand" and value == true)
                    or (key == "Sit" and value == true and _G._SAA_IsStealing) then
                    return nil
                end
            end
        end
        return oldNewIndex(self, key, value)
    end))
end

pcall(function()
    Workspace:SetAttribute("ClientObbyAntiTp", false)
    local net = ReplicatedStorage:FindFirstChild("Network")
    if net and typeof(getconnections) == "function" then
        for _, rName in ipairs({"ClientCharacter: IntegrityViolation", "ClientCharacter: IntegrityHeartbeat", "ClientCharacter: CorrectionStarted"}) do
            local r = net:FindFirstChild(rName)
            if r and r:IsA("RemoteEvent") then
                for _, conn in ipairs(getconnections(r.OnClientEvent)) do
                    pcall(conn.Disconnect, conn)
                end
            end
        end
    end
end)

-----------------------------------------------------------------------------------------
-- 🌐 2. MODULE IMPORTS (EggCmds, PlacedEggRenderer, Rebirths)
-----------------------------------------------------------------------------------------
local EggCmds = nil
task.spawn(function()
    local ok, result = pcall(function() return require(ReplicatedStorage.Library.Client.EggCmds) end)
    if ok then EggCmds = result end
end)

local PlacedEggRenderer = nil
task.spawn(function()
    local ok, result = pcall(function() return require(ReplicatedStorage.Library.Client.Eggs.PlacedEggRenderer) end)
    if ok then PlacedEggRenderer = result end
end)

local RebirthsDir = nil
task.spawn(function()
    local ok, result = pcall(function() return require(ReplicatedStorage.Directory.Rebirths) end)
    if ok then RebirthsDir = result end
end)

-----------------------------------------------------------------------------------------
-- ⚙️ 3. CONFIGURATION & STATE
-----------------------------------------------------------------------------------------
local Cfg = {
    -- Steal
    AutoSteal = false,
    TargetIslands = { "All Islands" },
    TargetRarities = { "Common", "Uncommon", "Rare", "SuperRare", "Epic", "Legendary", "Mythic", "Cosmic", "Divine", "Secret" },
    MovementMode = "Blink (Instant)",
    PriorityMode = "Highest Rarity First",
    FlightSpeed = 160,
    StealDelay = 0.2,

    -- Base & Hatch
    AutoPlace = true,
    AllowedPlaceRarities = { "Common", "Uncommon", "Rare", "SuperRare", "Epic", "Legendary", "Mythic", "Cosmic", "Divine", "Secret", "Eternal" },
    AutoHatch = true,
    AutoTreadmill = false, -- ปิดเริ่มต้น: เปิดเองได้ในแท็บ Base & Heroes

    -- Selling
    AutoSell = false,
    AllowedSellRarities = { "Common", "Uncommon" },
    MinKeepPrice = "0",
    MinKeepRate = "0",
    AutoSellEggs = false,
    AllowedEggSellRarities = { "Common", "Uncommon", "Rare" },
    AutoSellInterval = 20,

    -- Rebirth & Fuse
    AutoRebirth = false,
    AutoFuse = false,
    AllowedFuseRarities = { "Common", "Uncommon", "Rare", "SuperRare", "Epic" },

    -- Claims & Upgrades
    AutoEquipBest = true,
    AutoUpgradeBase = true,
    AutoUpgradeTreadmill = true,
    AutoClaimDaily = true,
    AutoClaimOffline = true,
    AutoClaimGroup = true,
    AutoClaimStepBoost = true,

    -- Visuals & Anti-Lag
    EggESP = false,
    HidePlayers = false,
    FPSBoost = false,
    AntiAFK = true,

    -- Webhook & Config Profile
    WebhookEnabled = false,
    WebhookUrl = "",
    ActiveProfile = "Default",
    AutoLoadProfile = false,
}
getgenv().PayomboyZ_SAA_Config = Cfg
-- Preserve an in-flight cycle across reloads so a new run cannot start a second
-- character movement sequence on top of the one already yielding.
if _G._SAA_IsStealing == nil then
    _G._SAA_IsStealing = false
end

local ISLAND_TIERS = {
    { Id = "All Islands", Name = "All Islands (ทุกเกาะ)" },
    { Id = "OnePiece", Name = "1. One Piece" },
    { Id = "DemonSlayer", Name = "2. Demon Slayer" },
    { Id = "HeroArena", Name = "3. Hero Arena (MHA)" },
    { Id = "DarkStreet", Name = "4. Dark Street (Chainsaw)" },
    { Id = "Naruto", Name = "5. Naruto (Hidden Leaf)" },
    { Id = "Jujutsu", Name = "6. Jujutsu Kaisen" },
    { Id = "SoloLeveling", Name = "7. Solo Leveling" },
    { Id = "DragonBall", Name = "8. Dragon Ball" },
    { Id = "Legends", Name = "9. Legends" },
    { Id = "BlackClover", Name = "10. Black Clover" },
}

local RARITY_RANKS = {
    Common = 1, Uncommon = 2, Rare = 3, SuperRare = 4,
    Epic = 5, Legendary = 6, Mythic = 7, Cosmic = 8,
    Divine = 9, Secret = 10, Eternal = 11
}

local RARITY_COLORS = {
    Common = Color3.fromRGB(180, 180, 185),
    Uncommon = Color3.fromRGB(46, 204, 113),
    Rare = Color3.fromRGB(52, 152, 219),
    SuperRare = Color3.fromRGB(155, 89, 182),
    Epic = Color3.fromRGB(142, 68, 173),
    Legendary = Color3.fromRGB(241, 196, 15),
    Mythic = Color3.fromRGB(230, 126, 34),
    Cosmic = Color3.fromRGB(231, 76, 60),
    Divine = Color3.fromRGB(0, 240, 255),
    Secret = Color3.fromRGB(255, 50, 120),
    Eternal = Color3.fromRGB(255, 215, 0),
}

local function hasIsland(id)
    if table.find(Cfg.TargetIslands, "All Islands") then return true end
    return table.find(Cfg.TargetIslands, id) ~= nil
end

local function hasRarity(r)
    local selected = Cfg.TargetRarities
    -- Treat a legacy/empty multi-select as "all" so Auto Steal never silently
    -- scans zero eggs after loading an old profile.
    if type(selected) ~= "table" or #selected == 0 then return true end
    return selected[r] == true or table.find(selected, r) ~= nil
end

local function isPlaceRarityAllowed(r)
    if not r or not Cfg.AllowedPlaceRarities then return true end
    return table.find(Cfg.AllowedPlaceRarities, r) ~= nil
end

local function isSellRarityAllowed(r)
    if not r or not Cfg.AllowedSellRarities then return false end
    return table.find(Cfg.AllowedSellRarities, r) ~= nil
end

local function isEggSellRarityAllowed(r)
    if not r or not Cfg.AllowedEggSellRarities then return false end
    return table.find(Cfg.AllowedEggSellRarities, r) ~= nil
end

local function isFuseRarityAllowed(r)
    if not r or not Cfg.AllowedFuseRarities then return false end
    return table.find(Cfg.AllowedFuseRarities, r) ~= nil
end

local function parseInputNumber(str)
    if type(str) == "number" then return str end
    if type(str) ~= "string" or str == "" then return 0 end
    str = str:gsub(",", ""):gsub(" ", ""):upper()
    local num, suffix = str:match("([%d%.]+)([KMBTQ]?)")
    num = tonumber(num) or 0
    if suffix == "K" then
        return num * 1e3
    elseif suffix == "M" then
        return num * 1e6
    elseif suffix == "B" then
        return num * 1e9
    elseif suffix == "T" then
        return num * 1e12
    elseif suffix == "Q" then
        return num * 1e15
    end
    return num
end

local function shortNum(n)
    n = tonumber(n) or 0
    if n >= 1e12 then return string.format("%.2fT", n / 1e12)
    elseif n >= 1e9 then return string.format("%.2fB", n / 1e9)
    elseif n >= 1e6 then return string.format("%.2fM", n / 1e6)
    elseif n >= 1e3 then return string.format("%.2fK", n / 1e3)
    end
    return tostring(math.floor(n))
end

-----------------------------------------------------------------------------------------
-- 🌐 4. GLOBAL LOCALIZATION ENGINE (TH / EN)
-----------------------------------------------------------------------------------------
local CurrentLang = "TH"
local I18N_LISTENERS = {}

local DICT = {
    HUB_TITLE = { TH = "PAYOMBØYZ HUB • STEAL AN ANIME EGG", EN = "PAYOMBØYZ HUB • STEAL AN ANIME EGG" },
    HUB_SUBTITLE = { TH = "ระบบทำงานอัตโนมัติระดับสูง • Low-Level Bypass Active", EN = "High-Level Automation Suite • Low-Level Bypass Active" },
    
    -- Tabs (Icons are prepended by code, NOT duplicated here)
    TAB_STEAL = { TH = "ขโมยไข่ (Auto Steal)", EN = "Auto Steal" },
    TAB_REBIRTH_FUSE = { TH = "เกิดใหม่ & ผสมฮีโร่", EN = "Rebirth & Hero Fuse" },
    TAB_BASE = { TH = "แปลง & ฮีโร่", EN = "Base & Heroes" },
    TAB_CLAIMS = { TH = "รับของขวัญฟรี", EN = "Auto Claims" },
    TAB_VISUALS = { TH = "ESP & มุมมอง", EN = "ESP & Visuals" },
    TAB_SETTINGS = { TH = "ตั้งค่า & คอนฟิก", EN = "Settings & Config" },

    -- Radar Card
    RADAR_TITLE = { TH = "LIVE RADAR: BEST TARGET SCANNED (เรดาร์สแกนไข่สด)", EN = "LIVE RADAR: BEST TARGET SCANNED" },
    RADAR_SCANNING = { TH = "กำลังสแกนหาไข่ในสนาม...", EN = "Scanning field for eggs..." },
    RADAR_NO_TARGET = { TH = "ไม่พบไข่ที่ตรงเงื่อนไข", EN = "No eggs matching criteria" },
    RADAR_WAIT_SPAWN = { TH = "รอการเกิดไข่รอบถัดไป...", EN = "Waiting for next spawn wave..." },
    RADAR_SNIPE_BTN = { TH = "🚀 ขโมยทันที", EN = "🚀 Snipe Now" },
    RADAR_EST_VALUE = { TH = "💰 มูลค่าโดยประมาณ: $%s", EN = "💰 Est. Value: $%s" },
    RADAR_DIST_AWAY = { TH = "📍 %s • ห่าง %dม.", EN = "📍 %s • %dm away" },

    -- Auto Steal
    SEC_STEAL = { TH = "ตั้งค่าระบบขโมยไข่ (Auto Steal Configuration)", EN = "Auto Steal Configuration" },
    AUTO_STEAL = { TH = "เปิดระบบขโมยไข่อัตโนมัติ (Auto Steal)", EN = "Enable Auto Steal" },
    AUTO_STEAL_SUB = { TH = "วาร์ปไปหยิบไข่ รอคอนเฟิร์มขึ้นมือ แล้วนำกลับมาวางที่แปลงอัตโนมัติ", EN = "Warp to egg, confirm grab, and place back on your plot" },
    TARGET_ISLANDS = { TH = "เลือกโซนเกาะเป้าหมาย (Target Islands)", EN = "Target Islands (Multi-Select)" },
    ALLOWED_RARITIES = { TH = "ระดับไข่ที่จะขโมย (Target Egg Rarities)", EN = "Target Egg Rarities" },
    MOVE_MODE = { TH = "โหมดการเดินทาง (Movement Mode)", EN = "Movement Mode" },
    PRIORITY_MODE = { TH = "ลำดับความสำคัญ (Target Priority)", EN = "Target Priority" },
    FLIGHT_SPEED = { TH = "ความเร็วการบิน (Flight Speed)", EN = "Flight Speed" },
    STEAL_DELAY = { TH = "ระยะเวลาหน่วงระหว่างรอบ (Cycle Delay)", EN = "Cycle Delay (s)" },

    -- Base & Hatch
    SEC_BASE = { TH = "การจัดการแปลง & ฮีโร่ (Base & Heroes Engine)", EN = "Base & Heroes Engine" },
    AUTO_PLACE = { TH = "วางไข่ในคอกฮีโร่อัตโนมัติ (Auto Place Eggs)", EN = "Auto Place Eggs" },
    AUTO_PLACE_SUB = { TH = "หยิบไข่จากกระเป๋าและวางลงแปลงเป็นระเบียบ 1-2-3-4", EN = "Automatically equip eggs from backpack and place neatly on plot" },
    PLACE_RARITIES = { TH = "ระดับไข่ที่ยอมให้วาง (Allowed Place Rarities)", EN = "Allowed Place Rarities" },
    AUTO_HATCH = { TH = "ฟักฮีโร่อัตโนมัติ (Auto Hatch Heroes)", EN = "Auto Hatch Heroes" },
    AUTO_HATCH_SUB = { TH = "กดฟักฮีโร่บนแปลงทันทีที่ครบกำหนดเวลา (Growth 100%)", EN = "Hatch placed heroes instantly once growth reaches 100%" },
    AUTO_TREADMILL = { TH = "วิ่งลู่อัตโนมัติเมื่อว่าง (Auto Treadmill Farm)", EN = "Auto Treadmill Farm" },
    AUTO_TREADMILL_SUB = { TH = "ยืนฟาร์มความเร็วบนลู่วิ่งเมื่อไม่มีไข่ให้ขโมย", EN = "Farm speed power on treadmill when idle" },
    CLAIM_PLOT_BTN = { TH = "ตรวจสอบแปลงของฉัน (Check My Plot)", EN = "Check My Plot" },

    -- Auto Sell
    SEC_SELL = { TH = "ระบบขายฮีโร่ & ไข่อัตโนมัติ (Auto Sell Engine)", EN = "Auto Sell Engine" },
    AUTO_SELL = { TH = "ขายฮีโร่อัตโนมัติ (Auto Sell Heroes)", EN = "Auto Sell Heroes" },
    AUTO_SELL_SUB = { TH = "สแกนฮีโร่ในกระเป๋าที่ไม่ได้ติดตั้งลงแปลง และขายตามระดับที่กำหนด", EN = "Scan inventory and sell unplaced heroes of selected rarities" },
    SELL_RARITIES = { TH = "ระดับฮีโร่ที่ยอมให้ขาย (Allowed Hero Sell Rarities)", EN = "Allowed Hero Sell Rarities" },
    SELL_NOW_BTN = { TH = "ขายฮีโร่ตามระดับที่เลือกทันที (Sell Selected Heroes Now)", EN = "Sell Selected Heroes Now" },
    AUTO_SELL_EGGS = { TH = "ขายไข่อัตโนมัติ (Auto Sell Eggs)", EN = "Auto Sell Eggs" },
    AUTO_SELL_EGGS_SUB = { TH = "สแกนไข่ในกระเป๋าและขายตามระดับที่เลือก", EN = "Scan and sell eggs in backpack of selected rarities" },
    EGG_SELL_RARITIES = { TH = "ระดับไข่ที่ยอมให้ขาย (Allowed Egg Sell Rarities)", EN = "Allowed Egg Sell Rarities" },
    SELL_EGGS_NOW_BTN = { TH = "ขายไข่ตามระดับที่เลือกทันที (Sell Selected Eggs Now)", EN = "Sell Selected Eggs Now" },

    -- Rebirth
    SEC_REBIRTH = { TH = "ระบบเกิดใหม่ (Rebirth Engine)", EN = "Rebirth Engine" },
    AUTO_REBIRTH = { TH = "เกิดใหม่อัตโนมัติ (Auto Rebirth)", EN = "Auto Rebirth" },
    AUTO_REBIRTH_SUB = { TH = "กดเกิดใหม่อัตโนมัติทันทีที่มี Speed ถึงเกณฑ์ที่กำหนด", EN = "Automatically trigger rebirth once required speed is reached" },
    REBIRTH_NOW_BTN = { TH = "กดเกิดใหม่ทันที (Rebirth Now)", EN = "Rebirth Now" },
    REBIRTH_READY = { TH = "สถานะ: พร้อมเกิดใหม่แล้ว! (Ready to Rebirth!)", EN = "Status: Ready to Rebirth!" },
    REBIRTH_FARMING = { TH = "สถานะ: กำลังสะสม Speed (Farming Speed...)", EN = "Status: Farming Speed..." },

    -- Fuse Machine
    SEC_FUSE = { TH = "ตู้ผสมฮีโร่ (Hero Fuse Machine Engine)", EN = "Hero Fuse Machine Engine" },
    AUTO_FUSE = { TH = "ผสมฮีโร่อัตโนมัติเมื่อครบ 3 ตัว (Auto Fuse Heroes)", EN = "Auto Fuse 3 Heroes" },
    AUTO_FUSE_SUB = { TH = "สแกนฮีโร่ที่ชื่อเหมือนกัน 3 ตัว แล้วส่งเข้าตู้ผสมอัตโนมัติ", EN = "Scan 3 identical heroes and feed into Fuse Machine automatically" },
    FUSE_RARITIES = { TH = "ระดับฮีโร่ที่ยอมให้ผสม (Allowed Hero Fuse Rarities)", EN = "Allowed Hero Fuse Rarities" },
    FUSE_NOW_BTN = { TH = "ผสมฮีโร่ 3 ตัวที่ตรงกันทันที (Fuse 3 Heroes Now)", EN = "Fuse 3 Heroes Now" },

    -- Auto Claims
    SEC_CLAIMS = { TH = "รับของขวัญ & อัปเกรดอัตโนมัติ (Auto Claims & Upgrades)", EN = "Auto Claims & Upgrades" },
    EQUIP_BEST = { TH = "สวมใส่ฮีโร่ที่ดีที่สุดเสมอ (Auto Equip Best Heroes)", EN = "Auto Equip Best Heroes" },
    EQUIP_BEST_SUB = { TH = "เลือกใส่ฮีโร่ที่สร้างรายได้สูงที่สุดลงแปลงตลอดเวลา", EN = "Automatically equip heroes with the highest multiplier" },
    UPGRADE_BASE = { TH = "อัปเกรดแปลงอัตโนมัติ (Auto Upgrade Base)", EN = "Auto Upgrade Base" },
    UPGRADE_BASE_SUB = { TH = "ซื้ออัปเกรดขยายขนาดแปลงและช่องวางไข่อัตโนมัติ", EN = "Automatically upgrade plot area and egg slots" },
    UPGRADE_TM = { TH = "อัปเกรดลู่วิ่งอัตโนมัติ (Auto Upgrade Treadmill)", EN = "Auto Upgrade Treadmill" },
    UPGRADE_TM_SUB = { TH = "ซื้ออัปเกรดลู่วิ่งเพื่อเร่งความเร็วในการฟาร์ม Speed", EN = "Automatically upgrade treadmill for faster speed training" },
    CLAIM_DAILY = { TH = "รับของขวัญประจำวัน (Auto Claim Daily Login)", EN = "Claim Daily Login" },
    CLAIM_DAILY_SUB = { TH = "รับของขวัญล็อกอินรายวันอัตโนมัติ", EN = "Automatically collect daily login rewards" },
    CLAIM_OFFLINE = { TH = "รับเงินออฟไลน์ (Auto Claim Offline Cash)", EN = "Claim Offline Cash" },
    CLAIM_OFFLINE_SUB = { TH = "กดรับเงินที่สะสมตอนออฟไลน์ทันที", EN = "Collect pending offline earnings immediately" },
    CLAIM_GROUP = { TH = "รับรางวัลกลุ่ม (Auto Claim Group Gift)", EN = "Claim Group Rewards" },
    CLAIM_GROUP_SUB = { TH = "รับของขวัญกล่องกลุ่มฟรีเมื่อครบเวลา", EN = "Claim free group reward chests on cooldown" },
    CLAIM_STEP = { TH = "รับบูสต์ก้าวเดิน (Auto Claim Step Boost)", EN = "Claim Step Boost" },
    CLAIM_STEP_SUB = { TH = "รับโบนัสบูสต์ก้าวเดินเมื่อทำยอดถึงเกณฑ์", EN = "Claim step multiplier bonuses as available" },

    -- Visuals
    SEC_VISUALS = { TH = "ระบบ ESP & ปรับแต่งการมองเห็น (Visuals & Optimization)", EN = "Visuals & Optimization" },
    EGG_ESP = { TH = "เปิด ESP แสดงตำแหน่งไข่ (Egg ESP)", EN = "Egg ESP" },
    EGG_ESP_SUB = { TH = "แสดงกรอบป้ายชื่อและระยะห่างของไข่ในสนาม", EN = "Display name tags and distance to wild eggs" },
    HIDE_PLAYERS = { TH = "ซ่อนตัวผู้เล่นอื่น (Hide Other Players)", EN = "Hide Other Players" },
    HIDE_PLAYERS_SUB = { TH = "ซ่อนตัวละครคนอื่นเพื่อลดอาการแลค", EN = "Hide other player characters to reduce lag" },
    FPS_BOOST = { TH = "โหมดประหยัดทรัพยากร (FPS Boost / Anti-Lag)", EN = "FPS Boost / Anti-Lag" },
    FPS_BOOST_SUB = { TH = "ปรับภาพเป็น Smooth Plastic และปิดเอฟเฟกต์หนักเครื่อง", EN = "Optimize textures and disable heavy particles for maximum FPS" },

    -- Settings & Config
    SEC_CONFIG = { TH = "จัดการโปรไฟล์คอนฟิก (Configuration Profiles)", EN = "Configuration Profiles" },
    SAVE_CFG_BTN = { TH = "💾 บันทึกคอนฟิกปัจจุบัน (Save Config)", EN = "💾 Save Current Config" },
    LOAD_CFG_BTN = { TH = "📂 โหลดคอนฟิกที่เลือก (Load Config)", EN = "📂 Load Selected Config" },
    AUTOLOAD_CFG = { TH = "โหลดคอนฟิกนี้อัตโนมัติเมื่อเปิดสคริปต์ (Auto Load on Startup)", EN = "Auto Load Config on Startup" },
    AUTOLOAD_CFG_SUB = { TH = "เปิดสคริปต์รอบหน้าจะใช้การตั้งค่าโปรไฟล์นี้ทันที", EN = "Automatically load this config next time script executes" },

    SEC_WEBHOOK = { TH = "การแจ้งเตือน DISCORD WEBHOOK (Discord Notifications)", EN = "Discord Webhook Integration" },
    ENABLE_WEBHOOK = { TH = "เปิดระบบแจ้งเตือน Discord (Enable Webhook)", EN = "Enable Discord Webhook" },
    ENABLE_WEBHOOK_SUB = { TH = "ส่งสถิติการขโมยไข่แรร์ การเกิดใหม่ และการผสมสัตว์ไปยัง Discord", EN = "Send alerts for rare eggs, rebirths, and fusions" },
    TEST_WEBHOOK_BTN = { TH = "🧪 ส่งข้อความทดสอบ Webhook (Test Webhook)", EN = "🧪 Test Discord Webhook" },

    SEC_SERVER = { TH = "การจัดการเซิร์ฟเวอร์ (Server Utilities)", EN = "Server Utilities" },
    REJOIN_BTN = { TH = "เข้าเซิร์ฟเวอร์เดิมใหม่ (Rejoin Server)", EN = "Rejoin Current Server" },
    HOP_BTN = { TH = "ย้ายไปเซิร์ฟเวอร์คนน้อย (Server Hop)", EN = "Hop to Low-Player Server" },
    ANTI_AFK = { TH = "ระบบกันหลุด 20 นาที (Anti-AFK Protection)", EN = "Anti-AFK Protection" },
    ANTI_AFK_SUB = { TH = "ป้องกันเกมเตะเมื่อไม่ได้ขยับตัว", EN = "Prevent idle disconnect" },

    RADAR_SNIPE_NOW = { TH = "ขโมยทันที", EN = "Steal Now" },
    MIN_KEEP_PRICE = { TH = "มูลค่าราคาขายขั้นต่ำที่จะเก็บไว้ (Min Price to Keep)", EN = "Min Price to Keep (e.g. 1B, 500M)" },
    MIN_KEEP_RATE = { TH = "อัตราผลิตเงินต่ำสุดที่จะเก็บไว้ (Min Income/s to Keep)", EN = "Min Income/s to Keep (e.g. 100M/s)" },
    LANG_TOGGLE = { TH = "🇹🇭 ภาษาไทย", EN = "🇺🇸 English" },
    MODAL_DONE = { TH = "✓ เสร็จสิ้น (Done)", EN = "✓ Done" },
}

local function L(key, ...)
    local entry = DICT[key]
    local val = (entry and entry[CurrentLang]) or (entry and entry.TH) or key
    if ... then return string.format(val, ...) end
    return val
end

local function registerI18n(obj, prop, key, formatFn)
    table.insert(I18N_LISTENERS, { Object = obj, Property = prop, Key = key, FormatFn = formatFn })
    if obj and obj.Parent then
        local text = L(key)
        if formatFn then text = formatFn(text) end
        pcall(function() obj[prop] = text end)
    end
end

local function refreshAllI18n()
    for _, item in ipairs(I18N_LISTENERS) do
        if item.Object and item.Object.Parent then
            pcall(function()
                local text = L(item.Key)
                if item.FormatFn then text = item.FormatFn(text) end
                item.Object[item.Property] = text
            end)
        end
    end
end

-----------------------------------------------------------------------------------------
-- 📡 5. NETWORK ENDPOINTS
-----------------------------------------------------------------------------------------
local GameRemotes = ReplicatedStorage:FindFirstChild("GameRemotes")
local NetworkFolder = ReplicatedStorage:FindFirstChild("Network")
local function getRemote(folder, name)
    return folder and folder:FindFirstChild(name) or nil
end

local Net = {
    PlaceEgg = getRemote(GameRemotes, "PlaceEgg"),
    DropPet = getRemote(GameRemotes, "DropPet"),
    DropHeldEgg = getRemote(GameRemotes, "DropHeldEgg"),
    SellAll = getRemote(GameRemotes, "SellAll"),
    SellHeld = getRemote(GameRemotes, "SellHeld"),
    EquipBestPets = getRemote(GameRemotes, "EquipBestPets"),
    SpeedGain = getRemote(GameRemotes, "SpeedGain"),
    FuseAction = getRemote(GameRemotes, "FuseAction"),
    ClaimGroupGift = getRemote(GameRemotes, "ClaimGroupGift"),
    OfflineCashRequest = getRemote(GameRemotes, "OfflineCashRequest"),
    StepBoostClaim = getRemote(GameRemotes, "StepBoostClaim"),
    IndexClaim = getRemote(GameRemotes, "IndexClaim"),
    -- Rebirth: resolved lazily at call-time via getRebirthRemote() below — DO NOT cache here
    RebirthRequest = nil,
    DailyClaim = ReplicatedStorage:FindFirstChild("DailyLoginRemotes") and ReplicatedStorage.DailyLoginRemotes:FindFirstChild("Claim"),
    BaseUpgrade = getRemote(NetworkFolder, "Plots: RequestBaseUpgrade"),
    TreadmillUpgrade = getRemote(NetworkFolder, "Treadmills: RequestUpgrade"),
    SellAsset = getRemote(NetworkFolder, "AssetInventory: SellAsset"),
    SellAllAssets = getRemote(NetworkFolder, "AssetInventory: SellAllAssets"),
}

-- Resolve this endpoint when a steal actually starts. The game can create GameRemotes
-- after this script is loaded, so a startup-only reference can stay nil for the whole run.
local function getStealEggRemote()
    local remotes = ReplicatedStorage:FindFirstChild("GameRemotes")
    if not remotes then
        remotes = ReplicatedStorage:WaitForChild("GameRemotes", 3)
    end
    if not remotes then return nil end

    local remote = remotes:FindFirstChild("StealEgg")
    if not remote then
        remote = remotes:WaitForChild("StealEgg", 3)
    end
    if remote and remote:IsA("RemoteEvent") then return remote end
    return nil
end

local function requestStealEgg(egg)
    local remote = getStealEggRemote()
    if not remote then
        return false, "GameRemotes.StealEgg RemoteEvent is unavailable"
    end

    local ok, err = pcall(function()
        -- Matches LiveAreaEggStealPrompts in the current game build.
        remote:FireServer(egg, egg:GetAttribute("EggUid"))
    end)
    if not ok then return false, tostring(err) end
    return true
end

-----------------------------------------------------------------------------------------
-- 🔔 6. DISCORD WEBHOOK ENGINE
-----------------------------------------------------------------------------------------
local function sendWebhook(title, description, fields, color)
    if not Cfg.WebhookEnabled or not Cfg.WebhookUrl or Cfg.WebhookUrl == "" then return end
    task.spawn(function()
        pcall(function()
            local synEnv = ScriptEnv.syn
            local httpEnv = ScriptEnv.http
            local reqFn = (synEnv and synEnv.request) or (httpEnv and httpEnv.request)
                or ScriptEnv.http_request or ScriptEnv.request
            if not reqFn then return end

            local embed = {
                title = title or "PAYOMBØYZ HUB NOTIFICATION",
                description = description or "",
                color = color or 16723275,
                fields = fields or {},
                footer = { text = "Payombøyz Hub v3.0 • Steal An Anime Egg" },
                timestamp = DateTime.now():ToIsoDate()
            }

            local payload = {
                username = "Payombøyz Sentinel",
                avatar_url = "https://i.imgur.com/8Y1N8bH.png",
                embeds = { embed }
            }

            reqFn({
                Url = Cfg.WebhookUrl,
                Method = "POST",
                Headers = { ["Content-Type"] = "application/json" },
                Body = HttpService:JSONEncode(payload)
            })
        end)
    end)
end

-----------------------------------------------------------------------------------------
-- 💾 7. CONFIGURATION MANAGER (Save, Load, Auto-Load)
-----------------------------------------------------------------------------------------
local CONFIG_FOLDER = "SAA_Configs"
pcall(function()
    if typeof(isfolder) == "function" and not isfolder(CONFIG_FOLDER) then
        makefolder(CONFIG_FOLDER)
    end
end)

local function getSavedConfigs()
    local files = { "Default" }
    pcall(function()
        if typeof(listfiles) == "function" then
            for _, f in ipairs(listfiles(CONFIG_FOLDER)) do
                local name = f:match("([^/\\]+)%.json$")
                if name and not table.find(files, name) then
                    table.insert(files, name)
                end
            end
        end
    end)
    return files
end

local function saveConfig(name)
    name = (name and name ~= "") and name or "Default"
    Cfg.ActiveProfile = name
    local exportData = {
        AutoSteal = Cfg.AutoSteal,
        TargetIslands = Cfg.TargetIslands,
        TargetRarities = Cfg.TargetRarities,
        MovementMode = Cfg.MovementMode,
        PriorityMode = Cfg.PriorityMode,
        FlightSpeed = Cfg.FlightSpeed,
        StealDelay = Cfg.StealDelay,
        AutoPlace = Cfg.AutoPlace,
        AutoHatch = Cfg.AutoHatch,
        AutoTreadmill = Cfg.AutoTreadmill,
        AutoSell = Cfg.AutoSell,
        AllowedSellRarities = Cfg.AllowedSellRarities,
        AutoRebirth = Cfg.AutoRebirth,
        AutoFuse = Cfg.AutoFuse,
        AllowedFuseRarities = Cfg.AllowedFuseRarities,
        AutoEquipBest = Cfg.AutoEquipBest,
        AutoUpgradeBase = Cfg.AutoUpgradeBase,
        AutoUpgradeTreadmill = Cfg.AutoUpgradeTreadmill,
        AutoClaimDaily = Cfg.AutoClaimDaily,
        AutoClaimOffline = Cfg.AutoClaimOffline,
        AutoClaimGroup = Cfg.AutoClaimGroup,
        AutoClaimStepBoost = Cfg.AutoClaimStepBoost,
        EggESP = Cfg.EggESP,
        HidePlayers = Cfg.HidePlayers,
        FPSBoost = Cfg.FPSBoost,
        AntiAFK = Cfg.AntiAFK,
        WebhookEnabled = Cfg.WebhookEnabled,
        WebhookUrl = Cfg.WebhookUrl,
        AutoLoadProfile = Cfg.AutoLoadProfile
    }
    pcall(function()
        if typeof(writefile) == "function" then
            writefile(CONFIG_FOLDER .. "/" .. name .. ".json", HttpService:JSONEncode(exportData))
            if Cfg.AutoLoadProfile then
                writefile(CONFIG_FOLDER .. "/autoload.txt", name)
            end
        end
    end)
end

local function loadConfig(name)
    name = (name and name ~= "") and name or "Default"
    local path = CONFIG_FOLDER .. "/" .. name .. ".json"
    pcall(function()
        if typeof(readfile) == "function" and typeof(isfile) == "function" and isfile(path) then
            local raw = readfile(path)
            local data = HttpService:JSONDecode(raw)
            if type(data) == "table" then
                for k, v in pairs(data) do
                    Cfg[k] = v
                end
                Cfg.ActiveProfile = name
            end
        end
    end)
end

-- Check Auto-Load on startup
pcall(function()
    if typeof(isfile) == "function" and isfile(CONFIG_FOLDER .. "/autoload.txt") then
        local autoName = readfile(CONFIG_FOLDER .. "/autoload.txt"):gsub("%s+", "")
        if autoName ~= "" then
            loadConfig(autoName)
        end
    end
end)

-----------------------------------------------------------------------------------------
-- 🧭 8. CHARACTER & GEOMETRY HELPERS
-----------------------------------------------------------------------------------------
local function getChar() return LocalPlayer.Character end
local function getHrp()
    local c = getChar()
    return c and (c:FindFirstChild("HumanoidRootPart") or c:FindFirstChild("UpperTorso"))
end

local function getRoot()
    return getHrp()
end

local function logLine(tag, msg)
    print(string.format("[SAA][%s] %s", tostring(tag):upper(), tostring(msg)))
end
local function getHum()
    local c = getChar()
    return c and c:FindFirstChildOfClass("Humanoid")
end
local function isAlive()
    local h = getHum()
    return h and h.Health > 0
end

local function getMyPlot()
    local slot = LocalPlayer:GetAttribute("PlotSlot")
    if not slot then return nil end
    local plots = Workspace:FindFirstChild("Plots")
    return plots and plots:FindFirstChild(tostring(slot))
end

local function getHomePos()
    local p = getMyPlot()
    if p then
        -- PlayerSpawn is the actual ground-level spawn marker in this map; SpawnPoint
        -- can be an elevated visual marker and put the character several studs in the air.
        local sp = p:FindFirstChild("PlayerSpawn") or p:FindFirstChild("SpawnPoint") or p:FindFirstChild("CenterPoint")
        if sp then return sp.Position + Vector3.new(0, 3, 0) end
        return p:GetPivot().Position + Vector3.new(0, 3, 0)
    end
    -- Never send the character to an assumed world origin when plot data is late/missing.
    local root = getHrp()
    return root and root.Position or Vector3.new(0, 100, 0)
end

local function getPetArea()
    local p = getMyPlot()
    if p and p:FindFirstChild("ToUpdate") then
        return p.ToUpdate:FindFirstChild("PetArea")
    end
    return nil
end

local function getTreadmillPos()
    local p = getMyPlot()
    if p then
        local tb = p:FindFirstChild("TreadmillBottom")
        if tb then return tb.Position + Vector3.new(0, 2.5, 0) end
    end
    return nil
end

local function isHoldingEgg()
    local uid = LocalPlayer:GetAttribute("HeldEggUid")
    if typeof(uid) == "string" and uid ~= "" then return true end
    local c = getChar()
    if c then
        for _, ch in ipairs(c:GetChildren()) do
            if ch:IsA("Tool") and (ch.Name:find("Egg") or ch:GetAttribute("EggUid")) then
                return true
            end
        end
    end
    return false
end

local function getHeldEggUid()
    local uid = LocalPlayer:GetAttribute("HeldEggUid")
    if typeof(uid) == "string" and uid ~= "" then return uid end
    local c = getChar()
    if c then
        for _, child in ipairs(c:GetChildren()) do
            if child:IsA("Tool") and (child.Name:find("Egg") or child:GetAttribute("EggUid")) then
                uid = child:GetAttribute("EggUid") or child:GetAttribute("UID")
                if typeof(uid) == "string" and uid ~= "" then return uid end
            end
        end
    end
    return nil
end

-----------------------------------------------------------------------------------------
-- ⚡ 9. TRANSIT & MOVEMENT ENGINE
-----------------------------------------------------------------------------------------
local function instantBlink(destPos)
    local root = getHrp()
    if not root then return end
    root.AssemblyLinearVelocity = Vector3.zero
    root.AssemblyAngularVelocity = Vector3.zero
    root.CFrame = CFrame.new(destPos)
    root.AssemblyLinearVelocity = Vector3.zero
    root.AssemblyAngularVelocity = Vector3.zero
    RunService.Heartbeat:Wait()
    RunService.Heartbeat:Wait()
end

local function smoothGlide(destPos, speed)
    local root = getHrp()
    if not root then return end
    speed = speed or Cfg.FlightSpeed or 160
    local startPos = root.Position
    local dist = (destPos - startPos).Magnitude
    -- Keep long island hops at the configured speed instead of snapping the final stretch.
    local dur = math.clamp(dist / speed, 0.05, 25)
    -- 30 transform updates/sec keeps the route smooth while reducing the
    -- repeated character/network work on long island hops.
    local steps = math.max(1, math.ceil(dur * 30))
    local stepDelay = dur / steps

    for i = 1, steps do
        if not isAlive() then break end
        local alpha = i / steps
        root.CFrame = CFrame.new(startPos:Lerp(destPos, alpha))
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
        task.wait(stepDelay)
    end
    root.CFrame = CFrame.new(destPos)
end

local function undergroundGlide(destPos, speed)
    -- The previous implementation deliberately moved below the map floor.
    -- Keep the legacy option working, but travel at the requested surface height.
    smoothGlide(destPos, speed)
end

local function transitTo(targetPos)
    local mode = Cfg.MovementMode
    if mode:find("Glide") then
        smoothGlide(targetPos, Cfg.FlightSpeed)
    elseif mode:find("Underground") then
        undergroundGlide(targetPos, Cfg.FlightSpeed)
    else
        instantBlink(targetPos)
    end
end

local function transitCarriedEggToHome(targetPos)
    -- Mirror the reference script's safe-line/corridor return, but derive the
    -- route from this player's plot instead of copying another map's coordinates.
    local speed = math.min(tonumber(Cfg.FlightSpeed) or 90, 90)
    local root = getHrp()
    if not root then return end

    local safeBoundaryX = targetPos.X + 47
    local corridorZ = targetPos.Z + 54
    if root.Position.X > safeBoundaryX then
        local safeY = math.max(root.Position.Y, targetPos.Y, 70.4)
        local waypoints = {
            Vector3.new(root.Position.X, safeY, corridorZ),
            Vector3.new(safeBoundaryX, safeY, corridorZ),
            Vector3.new(targetPos.X, safeY, corridorZ),
        }
        for _, waypoint in ipairs(waypoints) do
            if not isAlive() then return end
            smoothGlide(waypoint, speed)
        end
    end
    smoothGlide(targetPos, speed)
end

-----------------------------------------------------------------------------------------
-- 🥚 10. WILD EGG SCANNER (MULTI-ISLAND SUPPORT)
-----------------------------------------------------------------------------------------
local FailedEggUntil = setmetatable({}, { __mode = "k" })

local function getSafeEggStandPosition(egg, eggPos)
    local root = getHrp()
    if not root or not egg or not egg.Parent then return nil end

    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = { LocalPlayer.Character, egg }
    params.IgnoreWater = true

    local hit = Workspace:Raycast(eggPos + Vector3.new(0, 12, 0), Vector3.new(0, -220, 0), params)
    if not hit or hit.Normal.Y < 0.55 then return nil end

    local standHeight = 3.5
    local hum = getHum()
    if hum then standHeight = math.max(standHeight, hum.HipHeight + root.Size.Y * 0.5 + 0.25) end
    local standPos = hit.Position + Vector3.new(0, standHeight, 0)
    -- Reject eggs floating far above a surface; their pivot is not a safe character target.
    if (standPos - eggPos).Magnitude > 40 then return nil end
    return standPos
end

local function scanWildEggs()
    local eggList = {}
    local lae = Workspace:FindFirstChild("LiveAreaEggs")
    if not lae then return eggList end

    local myPos = getHrp() and getHrp().Position or Vector3.zero

    for _, egg in ipairs(lae:GetChildren()) do
        if egg:IsA("Model") then
            local areaId = egg:GetAttribute("AreaId") or "OnePiece"
            local rarity = egg:GetAttribute("Rarity") or "Common"
            local eggType = egg:GetAttribute("EggType")
            local eggUid = egg:GetAttribute("EggUid")
            local isPlotPet = egg:GetAttribute("PlotPet") == true
            local carried = egg:GetAttribute("CarriedBy")

            local isIslandAllowed = hasIsland(areaId)
            local isRarityAllowed = hasRarity(rarity)

            if eggType ~= nil and not isPlotPet and carried == nil
                and (FailedEggUntil[egg] or 0) <= os.clock()
                and (eggUid == nil or typeof(eggUid) == "string")
                and isIslandAllowed and isRarityAllowed then
                local ok, pos = pcall(function() return egg:GetPivot().Position end)
                if not ok then
                    continue
                end
                -- Scanning stays cheap and includes every island. The destination is
                -- streamed and ground-checked only when a target is actually selected.
                local dist = (myPos - pos).Magnitude
                local rank = RARITY_RANKS[rarity] or 1

                table.insert(eggList, {
                    Model = egg,
                    Uid = eggUid,
                    Name = eggType,
                    Area = areaId,
                    Rarity = rarity,
                    Rank = rank,
                    Position = pos,
                    EggPosition = pos,
                    Distance = dist
                })
            end
        end
    end

    if Cfg.PriorityMode:find("Highest") then
        table.sort(eggList, function(a, b)
            if a.Rank == b.Rank then return a.Distance < b.Distance end
            return a.Rank > b.Rank
        end)
    elseif Cfg.PriorityMode:find("Lowest") then
        table.sort(eggList, function(a, b)
            if a.Rank == b.Rank then return a.Distance < b.Distance end
            return a.Rank < b.Rank
        end)
    else
        table.sort(eggList, function(a, b) return a.Distance < b.Distance end)
    end

    return eggList
end

-- The radar and worker used to enumerate and sort the same field independently.
-- Share a short-lived snapshot so a busy field is scanned at most once per interval.
local WildEggScanCache = { At = 0, Key = "", Eggs = {} }
local function getWildEggSnapshot(maxAge)
    local islands = table.concat(Cfg.TargetIslands or {}, ",")
    local rarities = table.concat(Cfg.TargetRarities or {}, ",")
    local key = islands .. "|" .. rarities .. "|" .. tostring(Cfg.PriorityMode)
    local now = os.clock()
    if key ~= WildEggScanCache.Key or now - WildEggScanCache.At >= (maxAge or 0.8) then
        WildEggScanCache.Eggs = scanWildEggs()
        WildEggScanCache.At = now
        WildEggScanCache.Key = key
    end
    return WildEggScanCache.Eggs
end

-----------------------------------------------------------------------------------------
-- 🎒 11. INVENTORY & PET MANAGEMENT
-----------------------------------------------------------------------------------------
local function getPlotInfo()
    -- PlotCmds does not expose the guessed GetState/GetLocalYourBaseBillboard methods.
    -- PlotSlot is the game's authoritative local-player mapping; never guess slot 3.
    local myPlot = getMyPlot()
    if not myPlot then return nil end

    local centerPoint = myPlot:FindFirstChild('CenterPoint', true)
    local toUpdate = myPlot:FindFirstChild('ToUpdate')
    local petArea = toUpdate and toUpdate:FindFirstChild('PetArea', true)

    return {
        Model = myPlot,
        CenterPoint = centerPoint or myPlot:FindFirstChildWhichIsA('BasePart', true),
        PetArea = petArea or centerPoint or myPlot:FindFirstChildWhichIsA('BasePart', true)
    }
end

local function claimPlot()
    -- The game assigns plots server-side when the player joins; it has no client claim
    -- action in PlotCmds. Report the authoritative slot instead of calling a missing API.
    local slot = LocalPlayer:GetAttribute("PlotSlot")
    if slot ~= nil then
        logLine("plot", "เซิร์ฟเวอร์กำหนดแปลงหมายเลข " .. tostring(slot) .. " ให้แล้ว")
        return true
    end
    warn("[SAA] PlotSlot has not been assigned by the server yet")
    return false
end

local function getEggInventoryData()
    local unplaced = {}
    local taken = {}
    local placedEggs = {}

    if EggCmds and EggCmds.GetOwnerRuntimeRecords then
        local ok, recs = pcall(EggCmds.GetOwnerRuntimeRecords, LocalPlayer.UserId)
        if ok and type(recs) == 'table' then
            for uid, rec in pairs(recs) do
                if rec.Placement then
                    local raw = rec.Placement.LocalCFrame or rec.Placement.Position
                    if typeof(raw) == 'CFrame' then
                        table.insert(taken, raw.Position)
                    elseif typeof(raw) == 'Vector3' then
                        table.insert(taken, raw)
                    elseif type(raw) == 'string' then
                        local parts = {}
                        for num in raw:gmatch('[-0-9%.eE]+') do
                            table.insert(parts, tonumber(num))
                        end
                        if #parts >= 3 then
                            table.insert(taken, Vector3.new(parts[1], parts[2], parts[3]))
                        end
                    end
                    table.insert(placedEggs, {
                        Uid = uid,
                        Category = rec.AssetCategory or rec.Category or rec.AssetId or 'Unknown',
                        Ready = (EggCmds.IsLocalEggReady and EggCmds.IsLocalEggReady(uid)) or false,
                        Record = rec
                    })
                else
                    table.insert(unplaced, {
                        Uid = uid,
                        Category = rec.AssetCategory or rec.Category or rec.AssetId or 'Unknown',
                        Rarity = rec.Rarity or 'Common'
                    })
                end
            end
        end
    end
    return unplaced, taken, placedEggs
end

local function waitForEggInventoryTransfer(uid, timeout)
    if not uid then return false end
    local deadline = os.clock() + (timeout or 5)
    repeat
        local unplaced, _, placed = getEggInventoryData()
        for _, egg in ipairs(unplaced) do
            if tostring(egg.Uid) == tostring(uid) then return true end
        end
        for _, egg in ipairs(placed) do
            if tostring(egg.Uid) == tostring(uid) then return true end
        end
        task.wait(0.15)
    until os.clock() >= deadline or not isCurrentRun()
    return false
end

local function findNextFreeEggSpot(pd, taken)
    local center = pd and (pd.CenterPoint or pd.PetArea)
    if not center then return nil, nil end
    local centerCf = center.CFrame
    local rows, cols = 3, 5
    local spacingX = 6
    local spacingZ = 6
    for r = 1, rows do
        for c = 1, cols do
            local offX = (c - (cols + 1) / 2) * spacingX
            local offZ = (r - (rows + 1) / 2) * spacingZ
            local localPos = Vector3.new(offX, 1.5, offZ)
            local worldPos = (centerCf * CFrame.new(localPos)).Position
            local occupied = false
            for _, pos in ipairs(taken) do
                if typeof(pos) == 'Vector3' and (pos - localPos).Magnitude < 2.8 then
                    occupied = true
                    break
                end
            end
            if not occupied then
                return CFrame.new(localPos), CFrame.new(worldPos)
            end
        end
    end
    return nil, nil
end

local function executePlaceEggBatch(maxCount, preferredUid, allowDuringStealCycle)
    if not Cfg.AutoPlace or (_G._SAA_IsStealing and not allowDuringStealCycle) then return 0 end
    local pd = getPlotInfo()
    if not pd or not pd.CenterPoint then return 0 end

    local unplaced, taken, _ = getEggInventoryData()
    if #unplaced == 0 or #taken >= 15 then return 0 end

    local queue = {}
    for _, egg in ipairs(unplaced) do
        if isPlaceRarityAllowed(egg.Rarity) then
            table.insert(queue, egg)
        end
    end
    if #queue == 0 then return 0 end
    if preferredUid then
        for i, egg in ipairs(queue) do
            if tostring(egg.Uid) == tostring(preferredUid) then
                table.remove(queue, i)
                table.insert(queue, 1, egg)
                break
            end
        end
    end

    local root = getRoot()
    if not root then return 0 end
    local origCf = root.CFrame
    local placedCount = 0

    local limit = math.min(maxCount or 5, #queue, 15 - #taken)
    for i = 1, limit do
        if not Cfg.AutoPlace or (_G._SAA_IsStealing and not allowDuringStealCycle) then break end
        local lcf, world = findNextFreeEggSpot(pd, taken)
        if not lcf or not world then break end

        local egg = queue[i]
        if EggCmds and EggCmds.RequestEquipTool then
            EggCmds.RequestEquipTool(egg.Uid)
        end
        root.CFrame = CFrame.new(world.Position + Vector3.new(0, 3, 0))
        root.AssemblyLinearVelocity = Vector3.zero
        task.wait(0.08)

        local ok, err = false, nil
        if EggCmds and EggCmds.RequestPlaceEgg then
            ok, err = EggCmds.RequestPlaceEgg(egg.Uid, lcf)
        end
        if EggCmds and EggCmds.RequestUnequipTool then
            EggCmds.RequestUnequipTool()
        end

        if ok then
            table.insert(taken, lcf.Position)
            placedCount = placedCount + 1
            logLine('place', string.format('วางไข่สำเร็จ: %s (%s)', egg.Category, egg.Rarity))
        else
            warn('[SAA] Place egg failed: ' .. tostring(err))
        end
        task.wait(0.08)
    end

    if placedCount > 0 then
        root.CFrame = origCf
        root.AssemblyLinearVelocity = Vector3.zero
        if PlacedEggRenderer and PlacedEggRenderer.Refresh then
            pcall(PlacedEggRenderer.Refresh)
        end
        sendWebhook('🥚 PLACED EGGS IN HERO PEN', string.format('Placed **%d** egg(s) in Hero Pen', placedCount), nil, 65280)
    end
    return placedCount
end

local function executePlaceEgg(preferredUid, allowDuringStealCycle)
    return executePlaceEggBatch(1, preferredUid, allowDuringStealCycle)
end

local function runAutoHatch()
    if not Cfg.AutoHatch or _G._SAA_IsStealing then return end
    local _, _, placedEggs = getEggInventoryData()
    local hatched = 0

    for _, egg in ipairs(placedEggs) do
        if egg.Ready and EggCmds then
            local ok1, err1 = EggCmds.RequestHatchEgg(egg.Uid)
            local ok2, err2, granted = EggCmds.RequestCompleteHatchEgg(egg.Uid)
            if ok2 then
                hatched = hatched + 1
                logLine("hatch", string.format("ฟักฮีโร่สำเร็จ: %s (UID: %s)", egg.Category, tostring(granted or egg.Uid)))
                sendWebhook("🐣 HERO HATCHED", string.format("Player **%s** hatched **%s** Hero!", LocalPlayer.Name, egg.Category), {
                    { name = "Hero", value = egg.Category, inline = true },
                    { name = "Granted UID", value = tostring(granted), inline = true }
                }, 16753920)
                task.wait(0.1)
            end
        end
    end
    return hatched
end

local function runAutoSell(forceManual)
    if not forceManual and (not Cfg.AutoSell and not Cfg.AutoSellEggs) then return end
    if _G._SAA_IsStealing then return end

    local rem = ReplicatedStorage:FindFirstChild("GameRemotes") and ReplicatedStorage.GameRemotes:FindFirstChild("SellShopRequest")
    if not rem then return end

    local ok, list = pcall(function() return rem:InvokeServer("List") end)
    if not ok or not list or not list.ok then return end

    local petsToSell = {}
    local eggsToSell = {}
    local minPrice = parseInputNumber(Cfg.MinKeepPrice)
    local minRate = parseInputNumber(Cfg.MinKeepRate)

    -- Filter unplaced Heroes
    if Cfg.AutoSell or forceManual then
        for _, p in ipairs(list.pets or {}) do
            if not p.placed and isSellRarityAllowed(p.rarity) then
                local pPrice = tonumber(p.price) or 0
                local pRate = tonumber(p.rate) or 0
                local keep = false
                if minPrice > 0 and pPrice >= minPrice then
                    keep = true
                end
                if minRate > 0 and pRate >= minRate then
                    keep = true
                end
                if not keep then
                    table.insert(petsToSell, p.uid)
                end
            end
        end
    end

    -- Filter unplaced Eggs
    if Cfg.AutoSellEggs or forceManual then
        for _, e in ipairs(list.eggs or {}) do
            if isEggSellRarityAllowed(e.rarity) then
                table.insert(eggsToSell, e.uid)
            end
        end
    end

    if #petsToSell == 0 and #eggsToSell == 0 then
        if forceManual then
            logLine("sell", "ไม่มีฮีโร่หรือไข่ที่ตรงเงื่อนไขการขาย (อาจติดเกณฑ์ราคาขั้นต่ำ หรือไม่ได้เลือก Rarity)")
        end
        return
    end

    local root = getRoot()
    if not root then return end
    local origCf = root.CFrame

    local stands = Workspace:FindFirstChild("Stands")
    local pads = stands and stands:FindFirstChild("Pads")
    local sellPad = pads and pads:FindFirstChild("SellShop")
    local sellPos = (sellPad and (sellPad.CFrame + Vector3.new(0, 3, 0))) or CFrame.new(533.35, 71, -421.46)

    root.CFrame = sellPos
    root.AssemblyLinearVelocity = Vector3.zero
    task.wait(0.2)

    local soldCount = 0
    local cashGained = 0

    if #petsToSell > 0 then
        local sellOk, sellRes = pcall(function() return rem:InvokeServer("Sell", "pet", petsToSell) end)
        if sellOk and sellRes and sellRes.ok then
            soldCount = soldCount + (sellRes.count or #petsToSell)
            cashGained = cashGained + (sellRes.total or 0)
        end
    end

    if #eggsToSell > 0 then
        local sellOk, sellRes = pcall(function() return rem:InvokeServer("Sell", "egg", eggsToSell) end)
        if sellOk and sellRes and sellRes.ok then
            soldCount = soldCount + (sellRes.count or #eggsToSell)
            cashGained = cashGained + (sellRes.total or 0)
        end
    end

    root.CFrame = origCf
    root.AssemblyLinearVelocity = Vector3.zero

    if soldCount > 0 then
        logLine("sell", string.format("ขายสำเร็จ: %d รายการ ได้รับเงิน $%s", soldCount, shortNum(cashGained)))
        sendWebhook("💰 HERO & EGG AUTO SELL", string.format("Player **%s** sold **%d** items for **$%s**", LocalPlayer.Name, soldCount, shortNum(cashGained)), {
            { name = "Items Sold", value = tostring(soldCount), inline = true },
            { name = "Cash Earned", value = "$" .. shortNum(cashGained), inline = true }
        }, 65280)
    end
end

-----------------------------------------------------------------------------------------
-- 🔄 12. REBIRTH & HERO FUSE MACHINE ENGINES
-----------------------------------------------------------------------------------------
local function getRebirthRemote()
    local rr = ReplicatedStorage:FindFirstChild("RebirthRemotes")
    if rr then
        local req = rr:FindFirstChild("Request")
        if req then return req end
    end
    local net = ReplicatedStorage:FindFirstChild("Network")
    if net then
        return net:FindFirstChild("Rebirths: RebirthRequest")
            or net:FindFirstChild("Rebirth: Request")
            or net:FindFirstChild("Rebirth: RequestRebirth")
    end
    local gr = ReplicatedStorage:FindFirstChild("GameRemotes")
    if gr then
        return gr:FindFirstChild("RebirthRequest")
            or gr:FindFirstChild("Rebirth")
    end
    return nil
end

local function getRebirthInfo()
    local curRebirth = LocalPlayer:GetAttribute("Rebirth")
        or LocalPlayer:GetAttribute("RebirthTier")
        or LocalPlayer:GetAttribute("Rebirths")
        or 0
    local curSpeed = LocalPlayer:GetAttribute("Speed")
        or LocalPlayer:GetAttribute("SpeedPower")
        or LocalPlayer:GetAttribute("TotalSpeed")
        or 0
    local nextTier = curRebirth + 1
    local reqSpeed = 0
    local cashMult = 1.0 + (curRebirth * 0.5)

    if RebirthsDir then
        local tier = RebirthsDir[nextTier]
        if tier then
            reqSpeed = (tier.Requirements and tier.Requirements.RequiredSpeedPower)
                or (tier.Requirements and tier.Requirements.RequiredSpeed)
                or tier.RequiredSpeed
                or tier.SpeedRequired
                or tier.Speed
                or 0
        end
    end

    if reqSpeed == 0 then
        reqSpeed = LocalPlayer:GetAttribute("RebirthRequiredSpeed")
            or LocalPlayer:GetAttribute("RequiredSpeed")
            or LocalPlayer:GetAttribute("NextRebirthSpeed")
            or 0
    end

    return {
        CurrentTier = curRebirth,
        CurrentSpeed = curSpeed,
        NextTier = nextTier,
        RequiredSpeed = reqSpeed,
        CashMultiplier = cashMult,
        IsReady = (reqSpeed == 0) or (curSpeed >= reqSpeed)
    }
end

local function fireRebirthRemote()
    local r = getRebirthRemote()
    if not r then return false end
    if r:IsA("RemoteFunction") then
        pcall(function() r:InvokeServer() end)
    else
        local ok = pcall(function() r:FireServer() end)
        if not ok then pcall(function() r:FireServer("Rebirth") end) end
        if not ok then pcall(function() r:FireServer(true) end) end
    end
    return true
end

local function runAutoRebirth()
    if not Cfg.AutoRebirth or _G._SAA_IsStealing then return end
    local info = getRebirthInfo()
    if not info.IsReady then return end
    local fired = fireRebirthRemote()
    if fired then
        print(string.format("[SAA-REBIRTH] Fired! Tier %d -> %d | Speed: %s / %s",
            info.CurrentTier, info.NextTier,
            tostring(info.CurrentSpeed), tostring(info.RequiredSpeed)))
        sendWebhook("REBIRTH COMPLETED", string.format("Player **%s** reached **Rebirth Tier %d** (Multiplier: x%.1f)", LocalPlayer.Name, info.NextTier, info.CashMultiplier + 0.5), {
            { name = "Rebirth Tier", value = tostring(info.NextTier), inline = true },
            { name = "Speed", value = tostring(info.CurrentSpeed), inline = true },
            { name = "Cash Mult", value = string.format("x%.1f", info.CashMultiplier + 0.5), inline = true }
        }, 65280)
        task.wait(2.5)
    end
end

local function runAutoFuse()
    if not Cfg.AutoFuse or _G._SAA_IsStealing then return end
    local rem = ReplicatedStorage:FindFirstChild("GameRemotes") and ReplicatedStorage.GameRemotes:FindFirstChild("SellShopRequest")
    if not rem then return end

    local ok, list = pcall(function() return rem:InvokeServer("List") end)
    if not ok or not list or not list.ok then return end

    local unplaced = {}
    for _, p in ipairs(list.pets or {}) do
        if not p.placed and isFuseRarityAllowed(p.rarity) then
            table.insert(unplaced, p)
        end
    end

    local groups = {}
    for _, p in ipairs(unplaced) do
        local name = p.name or p.id
        groups[name] = groups[name] or { Name = p.name or p.displayName, Rarity = p.rarity, Uids = {} }
        table.insert(groups[name].Uids, p.uid)
    end

    local fuseRem = ReplicatedStorage:FindFirstChild("GameRemotes") and ReplicatedStorage.GameRemotes:FindFirstChild("FuseAction")
    if not fuseRem then return end

    for name, group in pairs(groups) do
        if #group.Uids >= 3 then
            local root = getRoot()
            if not root then return end
            local origCf = root.CFrame

            -- Hitbox coordinate in Front of FuseMachine
            root.CFrame = CFrame.new(534.8, 74.0, -458.4)
            root.AssemblyLinearVelocity = Vector3.zero
            task.wait(0.15)

            pcall(function()
                fuseRem:FireServer("Insert", group.Uids[1])
                task.wait(0.08)
                fuseRem:FireServer("Insert", group.Uids[2])
                task.wait(0.08)
                fuseRem:FireServer("Insert", group.Uids[3])
                task.wait(0.12)
                fuseRem:FireServer("Start")
            end)

            task.wait(0.25)
            root.CFrame = origCf
            root.AssemblyLinearVelocity = Vector3.zero
            logLine("fuse", string.format("ผสมฮีโร่สำเร็จ: 3x %s (%s)", group.Name, group.Rarity))
            sendWebhook("🧬 HERO FUSION TRIGGERED", string.format("Fused 3x **%s** (%s) at Fuse Machine", group.Name, group.Rarity), nil, 16753920)
            task.wait(1.5)
            break
        end
    end
end

-----------------------------------------------------------------------------------------
-- 🎯 14. AUTO STEAL WORKFLOW (WITH CONFIRMATION WAIT)
-----------------------------------------------------------------------------------------
local function findCarryAreaPrompt(egg)
    if not egg or not egg.Parent then return nil end

    local ok, boundsCFrame, boundsSize = pcall(function()
        return egg:GetBoundingBox()
    end)
    local pivotPos = egg:GetPivot().Position
    local bestPrompt, bestDistance = nil, math.huge

    -- SmartProximityPrompt reparents the game's prompt to a Workspace part named
    -- SmartPromptPart; it is not a descendant of the egg model.
    for _, promptPart in ipairs(Workspace:GetChildren()) do
        if promptPart:IsA("BasePart") and promptPart.Name == "SmartPromptPart" then
            local prompt = promptPart:FindFirstChild("CarryAreaEgg")
            if prompt and prompt:IsA("ProximityPrompt") and prompt.Enabled then
                local matchesEgg = false
                if ok and typeof(boundsCFrame) == "CFrame" and typeof(boundsSize) == "Vector3" then
                    local localPos = boundsCFrame:PointToObjectSpace(promptPart.Position)
                    local margin = 1.25
                    matchesEgg = math.abs(localPos.X) <= boundsSize.X * 0.5 + margin
                        and math.abs(localPos.Y) <= boundsSize.Y * 0.5 + margin
                        and math.abs(localPos.Z) <= boundsSize.Z * 0.5 + margin
                else
                    matchesEgg = (promptPart.Position - pivotPos).Magnitude <= 2
                end

                local distance = (promptPart.Position - pivotPos).Magnitude
                if matchesEgg and distance < bestDistance then
                    bestPrompt, bestDistance = prompt, distance
                end
            end
        end
    end

    return bestPrompt
end

local function executeStealCycle(eggData)
    if _G._SAA_IsStealing or not eggData or not eggData.Model or not eggData.Model.Parent then return end
    _G._SAA_IsStealing = true
    _G._SAA_StealStartTime = os.clock()

    local grabbed = false
    local confirmed = false
    local returnedHome = false
    local heldUid = nil
    local returnPos = getHomePos()
    local ok, err = pcall(function()
        local egg = eggData.Model
        if egg:GetAttribute("CarriedBy") ~= nil or egg:GetAttribute("PlotPet") == true then
            return
        end

        local eggPos = egg:GetPivot().Position
        -- Ask Roblox to stream the destination before moving. Far islands can have
        -- egg models replicated before their collision floor is loaded locally.
        pcall(function()
            LocalPlayer:RequestStreamAroundAsync(eggPos, 10)
        end)
        task.wait(0.15)

        local grabPos = getSafeEggStandPosition(egg, eggPos)
        if not grabPos then
            error("Target island floor did not stream in")
        end
        transitTo(grabPos)
        -- Confirm the far-hop landed on a loaded surface before triggering the prompt.
        local movedRoot = getHrp()
        if not movedRoot or (movedRoot.Position - grabPos).Magnitude > 12 then
            error("Character was corrected away from the streamed target")
        end
        local floorParams = RaycastParams.new()
        floorParams.FilterType = Enum.RaycastFilterType.Exclude
        floorParams.FilterDescendantsInstances = { LocalPlayer.Character, egg }
        floorParams.IgnoreWater = true
        local floorHit = Workspace:Raycast(movedRoot.Position + Vector3.new(0, 2, 0), Vector3.new(0, -16, 0), floorParams)
        if not floorHit or floorHit.Normal.Y < 0.55 or (movedRoot.Position.Y - floorHit.Position.Y) > 8 then
            error("No loaded floor under character after island hop")
        end
        task.wait(0.12)

        local prompted = false
        local carryPrompt = findCarryAreaPrompt(egg)
        if carryPrompt and typeof(fireproximityprompt) == "function" then
            prompted = pcall(fireproximityprompt, carryPrompt)
        end
        -- Match the game's own CarryAreaEgg handler arguments if its prompt is unavailable.
        if not prompted then
            local sent, sendErr = requestStealEgg(egg)
            if not sent then error(sendErr) end
        end

        local grabConfirmed = false
        local waitStart = os.clock()
        -- CarryAreaEgg has a 1.2s hold duration. Give the normal prompt handler
        -- time to finish and replicate HeldEggUid before considering any fallback.
        local confirmationWindow = prompted and ((carryPrompt.HoldDuration or 0) + 0.8) or 0.85
        repeat
            task.wait(0.05)
            if isHoldingEgg() then
                grabConfirmed = true
                break
            end
        until (os.clock() - waitStart > confirmationWindow)

        -- Never race the prompt's own StealEgg request with a second request.
        if not grabConfirmed and egg.Parent and not prompted then
            local sent, sendErr = requestStealEgg(egg)
            if not sent then error(sendErr) end
            local retryWait = os.clock()
            repeat
                task.wait(0.05)
                if isHoldingEgg() then grabConfirmed = true break end
            until (os.clock() - retryWait > 0.4)
        end

        if isHoldingEgg() then
            grabbed = true
            heldUid = getHeldEggUid() or eggData.Uid
            local homePos = getHomePos()
            transitCarriedEggToHome(homePos)
            returnedHome = true
            task.wait(0.08)
            -- HeldEggUid only proves pickup. Wait until the owner inventory records
            -- this exact UID before treating the safe-area return as a successful steal.
            confirmed = waitForEggInventoryTransfer(heldUid, 6)
            if confirmed then
                if RARITY_RANKS[eggData.Rarity] and RARITY_RANKS[eggData.Rarity] >= 6 then
                    sendWebhook("🥚 RARE ANIME EGG STOLEN", string.format("Player **%s** stole **%s** (%s) from **%s**", LocalPlayer.Name, eggData.Name, eggData.Rarity, eggData.Area), {
                        { name = "Egg", value = eggData.Name, inline = true },
                        { name = "Rarity", value = eggData.Rarity, inline = true },
                        { name = "Zone", value = eggData.Area, inline = true }
                    }, 16723275)
                end
                if Cfg.AutoPlace then executePlaceEgg(heldUid, true) end
            end
        end
    end)

    -- A rejected/failed grab used to leave the player at the remote egg location.
    -- Always recover to the player's own plot before releasing the steal lock.
    if not grabbed and not returnedHome then
        pcall(function()
            transitTo(returnPos)
        end)
    end

    _G._SAA_IsStealing = false
    if not ok then
        FailedEggUntil[eggData.Model] = os.clock() + 4
        logLine("steal", err)
    elseif not confirmed then
        FailedEggUntil[eggData.Model] = os.clock() + 4
        logLine("steal", grabbed
            and ("Pickup confirmed but UID " .. tostring(heldUid) .. " did not appear in inventory after safe-area return")
            or "No HeldEggUid confirmation; retrying this egg after cooldown")
    else
        FailedEggUntil[eggData.Model] = nil
    end
    task.wait(Cfg.StealDelay or 0.2)
end

local _lastTreadmillGain = 0
local _treadmillOnBase = false

local function runTreadmillStep()
    -- Guard: ไม่ทำงานถ้า Steal active หรือกำลัง hold egg
    if not Cfg.AutoTreadmill or _G._SAA_IsStealing or isHoldingEgg() then
        _treadmillOnBase = false
        return
    end

    local tmPos = getTreadmillPos()
    if not tmPos then return end

    local root = getHrp()
    if not root then return end

    -- ย้ายไปลู่วิ่งเฉพาะถ้าห่างเกิน 5 studs
    if (root.Position - tmPos).Magnitude > 5 then
        root.CFrame = CFrame.new(tmPos)
        task.wait(0.08)
        _treadmillOnBase = true
    end

    -- Fire SpeedGain ทุก 0.8s ไม่ใช่ทุก tick (ลด spam)
    local now = os.clock()
    if now - _lastTreadmillGain >= 0.8 then
        _lastTreadmillGain = now
        if Net.SpeedGain then
            pcall(function() Net.SpeedGain:FireServer() end)
        end
    end
end

local function runAutoClaims()
    if Cfg.AutoClaimDaily and Net.DailyClaim then pcall(function() Net.DailyClaim:InvokeServer() end) end
    if Cfg.AutoClaimOffline and Net.OfflineCashRequest then pcall(function() Net.OfflineCashRequest:InvokeServer() end) end
    if Cfg.AutoClaimGroup and Net.ClaimGroupGift then pcall(function() Net.ClaimGroupGift:FireServer() end) end
    if Cfg.AutoClaimStepBoost and Net.StepBoostClaim then pcall(function() Net.StepBoostClaim:FireServer() end) end
    if Cfg.AutoUpgradeBase and Net.BaseUpgrade then pcall(function() Net.BaseUpgrade:FireServer() end) end
    if Cfg.AutoUpgradeTreadmill and Net.TreadmillUpgrade then pcall(function() Net.TreadmillUpgrade:InvokeServer() end) end
    if Cfg.AutoEquipBest and Net.EquipBestPets then pcall(function() Net.EquipBestPets:InvokeServer() end) end
end

-----------------------------------------------------------------------------------------
-- 👁️ 16. ESP & VISUALS
-----------------------------------------------------------------------------------------
local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "Obsidian_ESP"
pcall(function()
    local parent = (typeof(gethui) == "function" and gethui()) or CoreGui
    ESPFolder.Parent = parent
end)

local ActiveESP = {}

local function clearEggESP(egg)
    local data = ActiveESP[egg]
    if data then
        if data.Highlight and data.Highlight.Parent then data.Highlight:Destroy() end
        if data.Billboard and data.Billboard.Parent then data.Billboard:Destroy() end
        ActiveESP[egg] = nil
    end
end

local function clearAllESP()
    for egg, _ in pairs(ActiveESP) do
        clearEggESP(egg)
    end
    table.clear(ActiveESP)
end

local function updateEggESP()
    if not Cfg.EggESP then
        clearAllESP()
        return
    end

    local lae = Workspace:FindFirstChild("LiveAreaEggs")
    if not lae then
        clearAllESP()
        return
    end

    local myPos = getHrp() and getHrp().Position or Vector3.zero
    local currentEggs = {}
    local visibleCount = 0
    local maxVisibleEggs = 12

    for _, egg in ipairs(lae:GetChildren()) do
        if egg:IsA("Model") and egg:GetAttribute("CarriedBy") == nil then
            local rarity = egg:GetAttribute("Rarity") or "Common"
            local areaId = egg:GetAttribute("AreaId") or "OnePiece"
            local eggType = egg:GetAttribute("EggType") or egg.Name

            if hasIsland(areaId) and hasRarity(rarity) then
                if visibleCount >= maxVisibleEggs then break end
                local part = egg.PrimaryPart or egg:FindFirstChild("Hitbox") or egg:FindFirstChildWhichIsA("BasePart")
                if part then
                    visibleCount = visibleCount + 1
                    currentEggs[egg] = true
                    local esp = ActiveESP[egg]
                    local dist = math.floor((myPos - part.Position).Magnitude)
                    local rarColor = RARITY_COLORS[rarity] or Color3.fromRGB(255, 255, 255)

                    if not esp or not esp.Billboard or not esp.Billboard.Parent then
                        local hl = egg:FindFirstChild("SAA_ESP_HL") or Instance.new("Highlight")
                        hl.Name = "SAA_ESP_HL"
                        hl.Adornee = egg
                        hl.FillColor = rarColor
                        hl.FillTransparency = 0.65
                        hl.OutlineColor = Color3.new(1, 1, 1)
                        hl.OutlineTransparency = 0.2
                        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        hl.Parent = egg

                        local bg = part:FindFirstChild("SAA_ESP_BG") or Instance.new("BillboardGui")
                        bg.Name = "SAA_ESP_BG"
                        bg.Adornee = part
                        bg.AlwaysOnTop = true
                        bg.Size = UDim2.new(0, 150, 0, 48)
                        bg.StudsOffset = Vector3.new(0, 3.8, 0)
                        bg.Parent = part

                        local frame = Instance.new("Frame")
                        frame.Size = UDim2.fromScale(1, 1)
                        frame.BackgroundColor3 = Color3.fromRGB(15, 10, 18)
                        frame.BackgroundTransparency = 0.25
                        frame.BorderSizePixel = 0
                        frame.Parent = bg

                        local fc = Instance.new("UICorner") fc.CornerRadius = UDim.new(0, 8) fc.Parent = frame
                        local fs = Instance.new("UIStroke") fs.Color = rarColor fs.Thickness = 1.5 fs.Parent = frame

                        local assetData = AssetDirectory and AssetDirectory[eggType]
                        local eggIcon = (assetData and assetData.Egg and assetData.Egg.Icon)
                            or (assetData and assetData.Icon)
                            or "rbxassetid://135618011146990"

                        local img = Instance.new("ImageLabel")
                        img.Size = UDim2.fromOffset(36, 36)
                        img.Position = UDim2.new(0, 6, 0.5, -18)
                        img.BackgroundTransparency = 1
                        img.Image = eggIcon
                        img.ScaleType = Enum.ScaleType.Fit
                        img.Parent = frame

                        local txtName = Instance.new("TextLabel")
                        txtName.Size = UDim2.new(1, -48, 0, 18)
                        txtName.Position = UDim2.new(0, 46, 0, 4)
                        txtName.BackgroundTransparency = 1
                        txtName.Text = (assetData and assetData.Egg and assetData.Egg.DisplayName) or (eggType .. " Egg")
                        txtName.TextColor3 = rarColor
                        txtName.Font = Enum.Font.GothamBold
                        txtName.TextSize = 11
                        txtName.TextXAlignment = Enum.TextXAlignment.Left
                        txtName.Parent = frame

                        local txtSub = Instance.new("TextLabel")
                        txtSub.Size = UDim2.new(1, -48, 0, 14)
                        txtSub.Position = UDim2.new(0, 46, 0, 22)
                        txtSub.BackgroundTransparency = 1
                        txtSub.Text = string.format("%s • %s • %dm", rarity, areaId, dist)
                        txtSub.TextColor3 = Color3.fromRGB(220, 220, 220)
                        txtSub.Font = Enum.Font.GothamMedium
                        txtSub.TextSize = 9
                        txtSub.TextXAlignment = Enum.TextXAlignment.Left
                        txtSub.Parent = frame

                        ActiveESP[egg] = {
                            Highlight = hl,
                            Billboard = bg,
                            SubLabel = txtSub,
                            Stroke = fs,
                            Area = areaId,
                            Rarity = rarity
                        }

                        egg.AncestryChanged:Once(function(_, p)
                            if not p then clearEggESP(egg) end
                        end)
                    else
                        if esp.SubLabel and esp.SubLabel.Parent then
                            esp.SubLabel.Text = string.format("%s • %s • %dm", esp.Rarity, esp.Area, dist)
                        end
                    end
                end
            else
                if ActiveESP[egg] then clearEggESP(egg) end
            end
        end
    end

    for egg, _ in pairs(ActiveESP) do
        if not currentEggs[egg] or not egg.Parent then
            clearEggESP(egg)
        end
    end
end

local function applyAntiLag()
    if not Cfg.FPSBoost then return end
    pcall(function()
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        for _, v in ipairs(Workspace:GetDescendants()) do
            if v:IsA("BasePart") and not v:IsA("MeshPart") then
                v.Material = Enum.Material.SmoothPlastic
                v.Reflectance = 0
            elseif v:IsA("Decal") or v:IsA("Texture") then
                v.Transparency = 1
            elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
                v.Enabled = false
            end
        end
    end)
end

-----------------------------------------------------------------------------------------
-- 📱 17. RESPONSIVE UI ENGINE (PC & MOBILE SUPPORT)
-----------------------------------------------------------------------------------------
local parentGui = (typeof(gethui) == "function") and gethui() or CoreGui
if parentGui:FindFirstChild("ObsidianGlass2_UI") then
    parentGui.ObsidianGlass2_UI:Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name = "ObsidianGlass2_UI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.DisplayOrder = 99999
gui.Parent = parentGui

local uiScale = Instance.new("UIScale")
local camera = Workspace.CurrentCamera
local isTouchDevice = UserInputService.TouchEnabled

local function updateScale()
    if camera and camera.ViewportSize then
        local vp = camera.ViewportSize
        local scaleX = (vp.X - 16) / 920
        local scaleY = (vp.Y - 16) / 580
        local s = math.clamp(math.min(scaleX, scaleY), 0.38, 1.0)
        if isTouchDevice then
            s = math.clamp(s, 0.42, 0.82)
        end
        uiScale.Scale = s
    end
end
updateScale()
if camera then camera:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale) end
uiScale.Parent = gui

-- Main Shell Frame
local shell = Instance.new("Frame")
shell.Name = "MainShell"
shell.Size = UDim2.fromOffset(920, 580)
shell.AnchorPoint = Vector2.new(0.5, 0.5)
shell.Position = UDim2.new(0.5, 0, 0.5, 0)
shell.BackgroundColor3 = Color3.fromRGB(16, 12, 16)
shell.BackgroundTransparency = 0.08
shell.BorderSizePixel = 0
shell.ClipsDescendants = false
shell.Parent = gui

local shellCorner = Instance.new("UICorner") shellCorner.CornerRadius = UDim.new(0, 16) shellCorner.Parent = shell
local shellStroke = Instance.new("UIStroke") shellStroke.Color = Color3.fromRGB(255, 45, 75) shellStroke.Thickness = 1.6 shellStroke.Transparency = 0.35 shellStroke.Parent = shell

-- ❄️ Snow Animation inside MainShell
local snowLayer = Instance.new("Frame")
snowLayer.Name = "SnowLayer"
snowLayer.Size = UDim2.fromScale(1, 1)
snowLayer.BackgroundTransparency = 1
snowLayer.ZIndex = 2
snowLayer.ClipsDescendants = true
snowLayer.Parent = shell

task.spawn(function()
    local dots = {}
    for i = 1, 8 do
        local dot = Instance.new("Frame")
        dot.Size = UDim2.fromOffset(math.random(2, 4), math.random(2, 4))
        dot.Position = UDim2.new(math.random(), 0, math.random(), 0)
        dot.BackgroundColor3 = Color3.fromRGB(255, 230, 240)
        dot.BackgroundTransparency = math.random(40, 80) / 100
        dot.BorderSizePixel = 0
        local dc = Instance.new("UICorner") dc.CornerRadius = UDim.new(1, 0) dc.Parent = dot
        dot.Parent = snowLayer
        table.insert(dots, { frame = dot, spd = math.random(15, 35) / 100, drift = (math.random() - 0.5) * 0.2 })
    end
    while shell and shell.Parent and isCurrentRun() do
        for _, d in ipairs(dots) do
            local curX = d.frame.Position.X.Scale + (d.drift * 0.005)
            local curY = d.frame.Position.Y.Scale + (d.spd * 0.005)
            if curY > 1 then curY = -0.05 curX = math.random() end
            if curX > 1 then curX = 0 elseif curX < 0 then curX = 1 end
            d.frame.Position = UDim2.new(curX, 0, curY, 0)
        end
        task.wait(0.1)
    end
end)

-- Draggable Toggle Capsule
local capsule = Instance.new("Frame")
capsule.Name = "ObsidianToggleCapsule"
capsule.Size = UDim2.fromOffset(135, 44)
capsule.Position = UDim2.new(0, 20, 0, 520)
capsule.BackgroundColor3 = Color3.fromRGB(15, 12, 16)
capsule.BackgroundTransparency = 0.2
capsule.BorderSizePixel = 0
capsule.ZIndex = 9999
capsule.Parent = gui

local capCorner = Instance.new("UICorner") capCorner.CornerRadius = UDim.new(1, 0) capCorner.Parent = capsule
local capStroke = Instance.new("UIStroke") capStroke.Color = Color3.fromRGB(255, 45, 75) capStroke.Thickness = 1.2 capStroke.Parent = capsule

local capAvatar = Instance.new("ImageLabel")
capAvatar.Size = UDim2.fromOffset(32, 32)
capAvatar.Position = UDim2.new(0, 6, 0.5, -16)
capAvatar.BackgroundTransparency = 1
capAvatar.Parent = capsule
task.spawn(function()
    local ok, image = pcall(function()
        return Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.AvatarBust, Enum.ThumbnailSize.Size100x100)
    end)
    if ok and capAvatar.Parent then capAvatar.Image = image end
end)
local avCorner = Instance.new("UICorner") avCorner.CornerRadius = UDim.new(1, 0) avCorner.Parent = capAvatar

local capName = Instance.new("TextLabel")
capName.Size = UDim2.new(1, -44, 0, 15)
capName.Position = UDim2.new(0, 42, 0, 6)
capName.BackgroundTransparency = 1
capName.Text = "@" .. LocalPlayer.Name
capName.TextColor3 = Color3.fromRGB(240, 240, 245)
capName.Font = Enum.Font.GothamBold
capName.TextSize = 11
capName.TextXAlignment = Enum.TextXAlignment.Left
capName.Parent = capsule

local capStats = Instance.new("TextLabel")
capStats.Size = UDim2.new(1, -44, 0, 13)
capStats.Position = UDim2.new(0, 42, 0, 23)
capStats.BackgroundTransparency = 1
capStats.Text = "60 FPS • 50 ms"
capStats.TextColor3 = Color3.fromRGB(255, 110, 130)
capStats.Font = Enum.Font.Gotham
capStats.TextSize = 10
capStats.TextXAlignment = Enum.TextXAlignment.Left
capStats.Parent = capsule

local capDragging = false
local capDragStart, capStartPos
capsule.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        capDragging = true
        capDragStart = input.Position
        capStartPos = capsule.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then capDragging = false end
        end)
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if capDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - capDragStart
        capsule.Position = UDim2.new(capStartPos.X.Scale, capStartPos.X.Offset + delta.X, capStartPos.Y.Scale, capStartPos.Y.Offset + delta.Y)
    end
end)
capsule.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        local delta = (input.Position - capDragStart).Magnitude
        if delta < 6 then shell.Visible = not shell.Visible end
    end
end)

task.spawn(function()
    local lastTime = os.clock()
    local frames = 0
    while capsule and capsule.Parent and isCurrentRun() do
        frames = frames + 1
        local now = os.clock()
        if now - lastTime >= 1 then
            local fps = frames / (now - lastTime)
            local ping = 0
            pcall(function() ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue()) end)
            capStats.Text = string.format("%d FPS • %d ms", math.floor(fps), ping)
            frames = 0
            lastTime = now
        end
        task.wait(0.1)
    end
end)

-----------------------------------------------------------------------------------------
-- 📱 18. TOP-LEVEL DROPDOWN MODAL OVERLAY (100% MOBILE & PC FRIENDLY)
-----------------------------------------------------------------------------------------
local modalOverlay = Instance.new("Frame")
modalOverlay.Name = "TopDropdownModalOverlay"
modalOverlay.Size = UDim2.fromScale(1, 1)
modalOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
modalOverlay.BackgroundTransparency = 0.45
modalOverlay.ZIndex = 8000
modalOverlay.Visible = false
modalOverlay.Parent = shell

local modalBox = Instance.new("Frame")
modalBox.Name = "ModalBox"
modalBox.Size = UDim2.fromOffset(460, 400)
modalBox.AnchorPoint = Vector2.new(0.5, 0.5)
modalBox.Position = UDim2.new(0.5, 0, 0.5, 0)
modalBox.BackgroundColor3 = Color3.fromRGB(22, 16, 22)
modalBox.BorderSizePixel = 0
modalBox.ZIndex = 8001
modalBox.Parent = modalOverlay

local mbCorner = Instance.new("UICorner") mbCorner.CornerRadius = UDim.new(0, 14) mbCorner.Parent = modalBox
local mbStroke = Instance.new("UIStroke") mbStroke.Color = Color3.fromRGB(255, 45, 75) mbStroke.Thickness = 1.5 mbStroke.Parent = modalBox

local mbHeader = Instance.new("Frame")
mbHeader.Size = UDim2.new(1, 0, 0, 48)
mbHeader.BackgroundColor3 = Color3.fromRGB(30, 20, 30)
mbHeader.BorderSizePixel = 0
mbHeader.ZIndex = 8002
mbHeader.Parent = modalBox
local mbhCorner = Instance.new("UICorner") mbhCorner.CornerRadius = UDim.new(0, 14) mbhCorner.Parent = mbHeader

local mbTitle = Instance.new("TextLabel")
mbTitle.Size = UDim2.new(1, -120, 1, 0)
mbTitle.Position = UDim2.new(0, 16, 0, 0)
mbTitle.BackgroundTransparency = 1
mbTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
mbTitle.Font = Enum.Font.GothamBold
mbTitle.TextSize = 13
mbTitle.TextXAlignment = Enum.TextXAlignment.Left
mbTitle.ZIndex = 8003
mbTitle.Parent = mbHeader

local mbDoneBtn = Instance.new("TextButton")
mbDoneBtn.Size = UDim2.fromOffset(90, 32)
mbDoneBtn.Position = UDim2.new(1, -100, 0.5, -16)
mbDoneBtn.BackgroundColor3 = Color3.fromRGB(255, 35, 65)
mbDoneBtn.BorderSizePixel = 0
mbDoneBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
mbDoneBtn.Font = Enum.Font.GothamBold
mbDoneBtn.TextSize = 12
mbDoneBtn.ZIndex = 8003
mbDoneBtn.Parent = mbHeader
registerI18n(mbDoneBtn, "Text", "MODAL_DONE")
local mbdCorner = Instance.new("UICorner") mbdCorner.CornerRadius = UDim.new(0, 8) mbdCorner.Parent = mbDoneBtn

local mbScroll = Instance.new("ScrollingFrame")
mbScroll.Size = UDim2.new(1, -24, 1, -64)
mbScroll.Position = UDim2.new(0, 12, 0, 56)
mbScroll.BackgroundTransparency = 1
mbScroll.BorderSizePixel = 0
mbScroll.ScrollBarThickness = 4
mbScroll.ScrollBarImageColor3 = Color3.fromRGB(255, 45, 75)
mbScroll.ZIndex = 8002
mbScroll.Parent = modalBox

local mbLayout = Instance.new("UIListLayout")
mbLayout.Padding = UDim.new(0, 6)
mbLayout.Parent = mbScroll

mbLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    mbScroll.CanvasSize = UDim2.new(0, 0, 0, mbLayout.AbsoluteContentSize.Y + 16)
end)

local currentModalCloseCallback = nil
mbDoneBtn.MouseButton1Click:Connect(function()
    modalOverlay.Visible = false
    if currentModalCloseCallback then
        currentModalCloseCallback()
        currentModalCloseCallback = nil
    end
end)

local function openDropdownModal(titleText, options, selectedItems, isMulti, onSelectionChange)
    for _, c in ipairs(mbScroll:GetChildren()) do
        if c:IsA("TextButton") then c:Destroy() end
    end

    mbTitle.Text = titleText
    modalOverlay.Visible = true

    local tempSelected = {}
    if isMulti then
        for _, it in ipairs(selectedItems or {}) do table.insert(tempSelected, it) end
    else
        tempSelected = { selectedItems }
    end

    local optionButtons = {}

    local function refreshButtons()
        for optVal, btn in pairs(optionButtons) do
            local isSel = isMulti and (table.find(tempSelected, optVal) ~= nil) or (tempSelected[1] == optVal)
            btn.BackgroundColor3 = isSel and Color3.fromRGB(48, 25, 38) or Color3.fromRGB(28, 20, 28)
            btn.TextColor3 = isSel and Color3.fromRGB(255, 55, 85) or Color3.fromRGB(230, 230, 235)
            local checkMark = btn:FindFirstChild("CheckMark")
            if checkMark then checkMark.Visible = isSel end
        end
    end

    for _, opt in ipairs(options) do
        local optBtn = Instance.new("TextButton")
        optBtn.Size = UDim2.new(1, 0, 0, 38) -- Big touch target for mobile
        optBtn.BackgroundColor3 = Color3.fromRGB(28, 20, 28)
        optBtn.BorderSizePixel = 0
        optBtn.Font = Enum.Font.GothamBold
        optBtn.TextSize = 12
        optBtn.TextColor3 = Color3.fromRGB(230, 230, 235)
        optBtn.TextXAlignment = Enum.TextXAlignment.Left
        optBtn.Text = "   " .. opt
        optBtn.ZIndex = 8004
        optBtn.Parent = mbScroll

        local obc = Instance.new("UICorner") obc.CornerRadius = UDim.new(0, 8) obc.Parent = optBtn

        local check = Instance.new("TextLabel")
        check.Name = "CheckMark"
        check.Size = UDim2.fromOffset(24, 38)
        check.Position = UDim2.new(1, -30, 0, 0)
        check.BackgroundTransparency = 1
        check.Text = "✓"
        check.TextColor3 = Color3.fromRGB(46, 204, 113)
        check.Font = Enum.Font.GothamBold
        check.TextSize = 14
        check.ZIndex = 8005
        check.Visible = false
        check.Parent = optBtn

        optionButtons[opt] = optBtn

        optBtn.MouseButton1Click:Connect(function()
            if isMulti then
                local idx = table.find(tempSelected, opt)
                if idx then
                    table.remove(tempSelected, idx)
                else
                    table.insert(tempSelected, opt)
                end
                refreshButtons()
                onSelectionChange(tempSelected)
            else
                tempSelected = { opt }
                refreshButtons()
                onSelectionChange(opt)
                modalOverlay.Visible = false
            end
        end)
    end

    refreshButtons()
    currentModalCloseCallback = function()
        if isMulti then onSelectionChange(tempSelected) end
    end
end

-----------------------------------------------------------------------------------------
-- 🏛️ 19. MAIN CONTAINER LAYOUT
-----------------------------------------------------------------------------------------
local container = Instance.new("Frame")
container.Name = "MainContentContainer"
container.Size = UDim2.fromScale(1, 1)
container.BackgroundTransparency = 1
container.ZIndex = 5
container.Parent = shell

-- Left Sidebar / User Panel (Width 220)
local userPanel = Instance.new("Frame")
userPanel.Name = "UserPanel"
userPanel.Size = UDim2.new(0, 220, 1, 0)
userPanel.BackgroundColor3 = Color3.fromRGB(20, 15, 20)
userPanel.BackgroundTransparency = 0.25
userPanel.BorderSizePixel = 0
userPanel.Parent = container

local upCorner = Instance.new("UICorner") upCorner.CornerRadius = UDim.new(0, 16) upCorner.Parent = userPanel

-- Sidebar Header User Profile Card
local profCard = Instance.new("Frame")
profCard.Size = UDim2.new(1, -20, 0, 62)
profCard.Position = UDim2.new(0, 10, 0, 14)
profCard.BackgroundColor3 = Color3.fromRGB(28, 20, 28)
profCard.BackgroundTransparency = 0.3
profCard.BorderSizePixel = 0
profCard.Parent = userPanel

local pcCorner = Instance.new("UICorner") pcCorner.CornerRadius = UDim.new(0, 10) pcCorner.Parent = profCard
local pcStroke = Instance.new("UIStroke") pcStroke.Color = Color3.fromRGB(255, 45, 75) pcStroke.Thickness = 1 pcStroke.Transparency = 0.5 pcStroke.Parent = profCard

local pAvatar = Instance.new("ImageLabel")
pAvatar.Size = UDim2.fromOffset(42, 42)
pAvatar.Position = UDim2.new(0, 10, 0.5, -21)
pAvatar.BackgroundTransparency = 1
pAvatar.Parent = profCard
task.spawn(function()
    local ok, image = pcall(function()
        return Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.AvatarBust, Enum.ThumbnailSize.Size100x100)
    end)
    if ok and pAvatar.Parent then pAvatar.Image = image end
end)
local pavCorner = Instance.new("UICorner") pavCorner.CornerRadius = UDim.new(1, 0) pavCorner.Parent = pAvatar

local pName = Instance.new("TextLabel")
pName.Size = UDim2.new(1, -62, 0, 19)
pName.Position = UDim2.new(0, 60, 0, 12)
pName.BackgroundTransparency = 1
pName.Text = LocalPlayer.DisplayName
pName.TextColor3 = Color3.fromRGB(255, 255, 255)
pName.Font = Enum.Font.GothamBold
pName.TextSize = 14
pName.TextXAlignment = Enum.TextXAlignment.Left
pName.Parent = profCard

local pBadge = Instance.new("TextLabel")
pBadge.Size = UDim2.new(1, -62, 0, 15)
pBadge.Position = UDim2.new(0, 60, 0, 33)
pBadge.BackgroundTransparency = 1
pBadge.Text = "@" .. LocalPlayer.Name .. " • VERIFIED"
pBadge.TextColor3 = Color3.fromRGB(255, 65, 95)
pBadge.Font = Enum.Font.GothamBold
pBadge.TextSize = 10
pBadge.TextXAlignment = Enum.TextXAlignment.Left
pBadge.Parent = profCard

-- Tab Navigation Scroll
local tabScroll = Instance.new("ScrollingFrame")
tabScroll.Size = UDim2.new(1, -16, 1, -94)
tabScroll.Position = UDim2.new(0, 8, 0, 86)
tabScroll.BackgroundTransparency = 1
tabScroll.BorderSizePixel = 0
tabScroll.ScrollBarThickness = 2
tabScroll.ScrollBarImageColor3 = Color3.fromRGB(255, 45, 75)
tabScroll.Parent = userPanel

local tabLayout = Instance.new("UIListLayout")
tabLayout.Padding = UDim.new(0, 6)
tabLayout.Parent = tabScroll

-- Right Main Panel
local mainPanel = Instance.new("Frame")
mainPanel.Name = "MainPanel"
mainPanel.Size = UDim2.new(1, -232, 1, 0)
mainPanel.Position = UDim2.new(0, 226, 0, 0)
mainPanel.BackgroundTransparency = 1
mainPanel.Parent = container

-- Header inside MainPanel
local mainHeader = Instance.new("Frame")
mainHeader.Size = UDim2.new(1, 0, 0, 52)
mainHeader.BackgroundTransparency = 1
mainHeader.Parent = mainPanel

local hubTitle = Instance.new("TextLabel")
hubTitle.Size = UDim2.new(1, -180, 0, 22)
hubTitle.Position = UDim2.new(0, 10, 0, 6)
hubTitle.BackgroundTransparency = 1
hubTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
hubTitle.Font = Enum.Font.GothamBold
hubTitle.TextSize = 14
hubTitle.TextXAlignment = Enum.TextXAlignment.Left
hubTitle.Parent = mainHeader
registerI18n(hubTitle, "Text", "HUB_TITLE")

local hubSub = Instance.new("TextLabel")
hubSub.Size = UDim2.new(1, -180, 0, 16)
hubSub.Position = UDim2.new(0, 10, 0, 28)
hubSub.BackgroundTransparency = 1
hubSub.TextColor3 = Color3.fromRGB(170, 160, 170)
hubSub.Font = Enum.Font.Gotham
hubSub.TextSize = 11
hubSub.TextXAlignment = Enum.TextXAlignment.Left
hubSub.Parent = mainHeader
registerI18n(hubSub, "Text", "HUB_SUBTITLE")

local headerActions = Instance.new("Frame")
headerActions.Size = UDim2.fromOffset(170, 36)
headerActions.Position = UDim2.new(1, -175, 0, 8)
headerActions.BackgroundTransparency = 1
headerActions.Parent = mainHeader

-- Drag the main window from the title side of the header.
mainHeader.Active = true
local shellDragging = false
local shellDragStart, shellStartPos
mainHeader.InputBegan:Connect(function(input)
    local inputType = input.UserInputType
    if (inputType == Enum.UserInputType.MouseButton1 or inputType == Enum.UserInputType.Touch)
        and input.Position.X < headerActions.AbsolutePosition.X then
        shellDragging = true
        shellDragStart = input.Position
        shellStartPos = shell.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if shellDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - shellDragStart
        shell.Position = UDim2.new(
            shellStartPos.X.Scale, shellStartPos.X.Offset + delta.X,
            shellStartPos.Y.Scale, shellStartPos.Y.Offset + delta.Y
        )
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        shellDragging = false
    end
end)

local haLayout = Instance.new("UIListLayout")
haLayout.FillDirection = Enum.FillDirection.Horizontal
haLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
haLayout.VerticalAlignment = Enum.VerticalAlignment.Center
haLayout.Padding = UDim.new(0, 8)
haLayout.Parent = headerActions

-- 🌐 Language Switcher Pill Button
local langBtn = Instance.new("TextButton")
langBtn.Size = UDim2.fromOffset(110, 30)
langBtn.BackgroundColor3 = Color3.fromRGB(35, 25, 35)
langBtn.BackgroundTransparency = 0.2
langBtn.TextColor3 = Color3.fromRGB(255, 210, 220)
langBtn.Font = Enum.Font.GothamBold
langBtn.TextSize = 12
langBtn.BorderSizePixel = 0
langBtn.Parent = headerActions
registerI18n(langBtn, "Text", "LANG_TOGGLE")

local lbCorner = Instance.new("UICorner") lbCorner.CornerRadius = UDim.new(0, 8) lbCorner.Parent = langBtn
local lbStroke = Instance.new("UIStroke") lbStroke.Color = Color3.fromRGB(255, 45, 75) lbStroke.Thickness = 1 lbStroke.Transparency = 0.4 lbStroke.Parent = langBtn

langBtn.MouseButton1Click:Connect(function()
    CurrentLang = (CurrentLang == "TH") and "EN" or "TH"
    refreshAllI18n()
end)

-- ❌ Close / Minimize Button
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.fromOffset(30, 30)
closeBtn.BackgroundColor3 = Color3.fromRGB(40, 20, 25)
closeBtn.BackgroundTransparency = 0.2
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255, 90, 100)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 14
closeBtn.BorderSizePixel = 0
closeBtn.Parent = headerActions

local cbCorner = Instance.new("UICorner") cbCorner.CornerRadius = UDim.new(0, 8) cbCorner.Parent = closeBtn
local cbStroke = Instance.new("UIStroke") cbStroke.Color = Color3.fromRGB(255, 45, 75) cbStroke.Thickness = 1 cbStroke.Transparency = 0.5 cbStroke.Parent = closeBtn

closeBtn.MouseButton1Click:Connect(function()
    shell.Visible = false
end)

-- Pages Container
local pagesContainer = Instance.new("Frame")
pagesContainer.Size = UDim2.new(1, 0, 1, -54)
pagesContainer.Position = UDim2.new(0, 0, 0, 54)
pagesContainer.BackgroundTransparency = 1
pagesContainer.Parent = mainPanel

-----------------------------------------------------------------------------------------
-- 📑 20. TAB BUILDER & PAGE CONTROLS (SINGLE ICON FIX)
-----------------------------------------------------------------------------------------
local TABS = {}
local ACTIVE_TAB = 1

local function switchTab(index)
    ACTIVE_TAB = index
    for i, tab in ipairs(TABS) do
        local isActive = (i == index)
        tab.Page.Visible = isActive
        tab.Button.BackgroundColor3 = isActive and Color3.fromRGB(255, 35, 65) or Color3.fromRGB(28, 22, 28)
        tab.Button.TextColor3 = isActive and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(180, 170, 180)
        tab.Indicator.Visible = isActive
    end
end

local function createTab(tabNameKey, icon)
    local tabIdx = #TABS + 1

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 38)
    btn.BackgroundColor3 = Color3.fromRGB(28, 22, 28)
    btn.BackgroundTransparency = 0.2
    btn.Text = "   " .. icon .. "  " .. L(tabNameKey)
    btn.TextColor3 = Color3.fromRGB(180, 170, 180)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.BorderSizePixel = 0
    btn.Parent = tabScroll
    registerI18n(btn, "Text", tabNameKey, function(txt)
        return "   " .. icon .. "  " .. txt
    end)

    local bCorner = Instance.new("UICorner") bCorner.CornerRadius = UDim.new(0, 8) bCorner.Parent = btn

    local ind = Instance.new("Frame")
    ind.Size = UDim2.new(0, 3, 0.7, 0)
    ind.Position = UDim2.new(0, 0, 0.15, 0)
    ind.BackgroundColor3 = Color3.fromRGB(255, 45, 75)
    ind.BorderSizePixel = 0
    ind.Visible = false
    ind.Parent = btn

    local page = Instance.new("ScrollingFrame")
    page.Name = "Page_" .. tabIdx
    page.Size = UDim2.fromScale(1, 1)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = Color3.fromRGB(255, 45, 75)
    page.Visible = false
    page.Parent = pagesContainer

    local pageLayout = Instance.new("UIListLayout")
    pageLayout.Padding = UDim.new(0, 10)
    pageLayout.Parent = page

    local pagePad = Instance.new("UIPadding")
    pagePad.PaddingLeft = UDim.new(0, 10)
    pagePad.PaddingRight = UDim.new(0, 14)
    pagePad.PaddingTop = UDim.new(0, 4)
    pagePad.PaddingBottom = UDim.new(0, 24)
    pagePad.Parent = page

    pageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        page.CanvasSize = UDim2.new(0, 0, 0, pageLayout.AbsoluteContentSize.Y + 30)
    end)

    btn.MouseButton1Click:Connect(function()
        switchTab(tabIdx)
    end)

    local tabData = { Button = btn, Page = page, Indicator = ind, Layout = pageLayout }
    table.insert(TABS, tabData)

    return page
end

-----------------------------------------------------------------------------------------
-- 🧩 21. UI COMPONENT GENERATORS (WITH LARGER FONTS & MODAL DROPDOWNS)
-----------------------------------------------------------------------------------------
local function addSectionCard(page, titleKey)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, 34)
    card.BackgroundColor3 = Color3.fromRGB(30, 20, 26)
    card.BackgroundTransparency = 0.3
    card.BorderSizePixel = 0
    card.Parent = page

    local cCorner = Instance.new("UICorner") cCorner.CornerRadius = UDim.new(0, 8) cCorner.Parent = card
    local cStroke = Instance.new("UIStroke") cStroke.Color = Color3.fromRGB(255, 45, 75) cStroke.Thickness = 1 cStroke.Transparency = 0.7 cStroke.Parent = card

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -20, 1, 0)
    lbl.Position = UDim2.new(0, 12, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = Color3.fromRGB(255, 95, 120)
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = card
    registerI18n(lbl, "Text", titleKey)

    return card
end

local function addToggle(page, titleKey, subKey, defaultVal, callback)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, 52)
    card.BackgroundColor3 = Color3.fromRGB(22, 16, 22)
    card.BackgroundTransparency = 0.25
    card.BorderSizePixel = 0
    card.Parent = page

    local cCorner = Instance.new("UICorner") cCorner.CornerRadius = UDim.new(0, 8) cCorner.Parent = card
    local cStroke = Instance.new("UIStroke") cStroke.Color = Color3.fromRGB(255, 45, 75) cStroke.Thickness = 1 cStroke.Transparency = 0.85 cStroke.Parent = card

    local tLabel = Instance.new("TextLabel")
    tLabel.Size = UDim2.new(1, -75, 0, 20)
    tLabel.Position = UDim2.new(0, 12, 0, 6)
    tLabel.BackgroundTransparency = 1
    tLabel.TextColor3 = Color3.fromRGB(245, 245, 250)
    tLabel.Font = Enum.Font.GothamBold
    tLabel.TextSize = 12
    tLabel.TextXAlignment = Enum.TextXAlignment.Left
    tLabel.Parent = card
    registerI18n(tLabel, "Text", titleKey)

    local sLabel = Instance.new("TextLabel")
    sLabel.Size = UDim2.new(1, -75, 0, 16)
    sLabel.Position = UDim2.new(0, 12, 0, 28)
    sLabel.BackgroundTransparency = 1
    sLabel.TextColor3 = Color3.fromRGB(160, 150, 160)
    sLabel.Font = Enum.Font.Gotham
    sLabel.TextSize = 11
    sLabel.TextXAlignment = Enum.TextXAlignment.Left
    sLabel.Parent = card
    registerI18n(sLabel, "Text", subKey)

    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.fromOffset(46, 24)
    toggleBtn.Position = UDim2.new(1, -58, 0.5, -12)
    toggleBtn.BackgroundColor3 = defaultVal and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(45, 35, 45)
    toggleBtn.BorderSizePixel = 0
    toggleBtn.Text = ""
    toggleBtn.Parent = card

    local tbCorner = Instance.new("UICorner") tbCorner.CornerRadius = UDim.new(1, 0) tbCorner.Parent = toggleBtn

    local knob = Instance.new("Frame")
    knob.Size = UDim2.fromOffset(18, 18)
    knob.Position = defaultVal and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel = 0
    knob.Parent = toggleBtn
    local kCorner = Instance.new("UICorner") kCorner.CornerRadius = UDim.new(1, 0) kCorner.Parent = knob

    local state = defaultVal
    toggleBtn.MouseButton1Click:Connect(function()
        state = not state
        TweenService:Create(toggleBtn, TweenInfo.new(0.2), {
            BackgroundColor3 = state and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(45, 35, 45)
        }):Play()
        TweenService:Create(knob, TweenInfo.new(0.2), {
            Position = state and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
        }):Play()
        if callback then callback(state) end
    end)

    return card
end

local function addSlider(page, titleKey, min, max, defaultVal, callback)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, 52)
    card.BackgroundColor3 = Color3.fromRGB(22, 16, 22)
    card.BackgroundTransparency = 0.25
    card.BorderSizePixel = 0
    card.Parent = page

    local cCorner = Instance.new("UICorner") cCorner.CornerRadius = UDim.new(0, 8) cCorner.Parent = card
    local cStroke = Instance.new("UIStroke") cStroke.Color = Color3.fromRGB(255, 45, 75) cStroke.Thickness = 1 cStroke.Transparency = 0.85 cStroke.Parent = card

    local tLabel = Instance.new("TextLabel")
    tLabel.Size = UDim2.new(1, -70, 0, 20)
    tLabel.Position = UDim2.new(0, 12, 0, 6)
    tLabel.BackgroundTransparency = 1
    tLabel.TextColor3 = Color3.fromRGB(245, 245, 250)
    tLabel.Font = Enum.Font.GothamBold
    tLabel.TextSize = 12
    tLabel.TextXAlignment = Enum.TextXAlignment.Left
    tLabel.Parent = card
    registerI18n(tLabel, "Text", titleKey)

    local valLabel = Instance.new("TextLabel")
    valLabel.Size = UDim2.fromOffset(55, 20)
    valLabel.Position = UDim2.new(1, -65, 0, 6)
    valLabel.BackgroundTransparency = 1
    valLabel.Text = tostring(defaultVal)
    valLabel.TextColor3 = Color3.fromRGB(255, 95, 120)
    valLabel.Font = Enum.Font.GothamBold
    valLabel.TextSize = 12
    valLabel.TextXAlignment = Enum.TextXAlignment.Right
    valLabel.Parent = card

    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, -24, 0, 8)
    track.Position = UDim2.new(0, 12, 0, 34)
    track.BackgroundColor3 = Color3.fromRGB(40, 30, 40)
    track.BorderSizePixel = 0
    track.Parent = card
    local trCorner = Instance.new("UICorner") trCorner.CornerRadius = UDim.new(1, 0) trCorner.Parent = track

    local fill = Instance.new("Frame")
    local initRatio = (defaultVal - min) / (max - min)
    fill.Size = UDim2.new(initRatio, 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(255, 45, 75)
    fill.BorderSizePixel = 0
    fill.Parent = track
    local fCorner = Instance.new("UICorner") fCorner.CornerRadius = UDim.new(1, 0) fCorner.Parent = fill

    local dragging = false
    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            local posX = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
            fill.Size = UDim2.new(posX, 0, 1, 0)
            local currentVal = min + (max - min) * posX
            if max - min > 10 then currentVal = math.floor(currentVal) else currentVal = math.floor(currentVal * 10) / 10 end
            valLabel.Text = tostring(currentVal)
            if callback then callback(currentVal) end
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local posX = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
            fill.Size = UDim2.new(posX, 0, 1, 0)
            local currentVal = min + (max - min) * posX
            if max - min > 10 then currentVal = math.floor(currentVal) else currentVal = math.floor(currentVal * 10) / 10 end
            valLabel.Text = tostring(currentVal)
            if callback then callback(currentVal) end
        end
    end)

    return card
end

-- 📱 Multi-Select Dropdown connected to Top-Level Modal (Solves mobile clipping!)
local function addDropdown(page, titleKey, options, defaultSelected, isMulti, callback)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, 52)
    card.BackgroundColor3 = Color3.fromRGB(22, 16, 22)
    card.BackgroundTransparency = 0.25
    card.BorderSizePixel = 0
    card.Parent = page

    local cCorner = Instance.new("UICorner") cCorner.CornerRadius = UDim.new(0, 8) cCorner.Parent = card
    local cStroke = Instance.new("UIStroke") cStroke.Color = Color3.fromRGB(255, 45, 75) cStroke.Thickness = 1 cStroke.Transparency = 0.85 cStroke.Parent = card

    local tLabel = Instance.new("TextLabel")
    tLabel.Size = UDim2.new(0.46, 0, 1, 0)
    tLabel.Position = UDim2.new(0, 12, 0, 0)
    tLabel.BackgroundTransparency = 1
    tLabel.TextColor3 = Color3.fromRGB(245, 245, 250)
    tLabel.Font = Enum.Font.GothamBold
    tLabel.TextSize = 12
    tLabel.TextXAlignment = Enum.TextXAlignment.Left
    tLabel.Parent = card
    registerI18n(tLabel, "Text", titleKey)

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.50, 0, 0, 32)
    btn.Position = UDim2.new(0.48, 0, 0.5, -16)
    btn.BackgroundColor3 = Color3.fromRGB(34, 25, 34)
    btn.BorderSizePixel = 0
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    btn.TextColor3 = Color3.fromRGB(255, 215, 225)
    btn.TextTruncate = Enum.TextTruncate.AtEnd
    btn.Parent = card
    local bCorner = Instance.new("UICorner") bCorner.CornerRadius = UDim.new(0, 8) bCorner.Parent = btn
    local bStroke = Instance.new("UIStroke") bStroke.Color = Color3.fromRGB(255, 45, 75) bStroke.Thickness = 1 bStroke.Transparency = 0.7 bStroke.Parent = btn

    local selectedState = isMulti and (defaultSelected or {}) or { defaultSelected }
    local function formatBtnText()
        if isMulti then
            if #selectedState == 0 then return "None" end
            if #selectedState == #options then return "All Selected (" .. #options .. ")" end
            return table.concat(selectedState, ", ")
        else
            return tostring(selectedState[1] or "Select...")
        end
    end
    btn.Text = formatBtnText()

    btn.MouseButton1Click:Connect(function()
        openDropdownModal(L(titleKey), options, selectedState, isMulti, function(newSelection)
            selectedState = isMulti and newSelection or { newSelection }
            btn.Text = formatBtnText()
            if callback then callback(isMulti and selectedState or selectedState[1]) end
        end)
    end)

    return card
end

local function addInputBox(page, titleKey, placeholderText, defaultVal, callback)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, 52)
    card.BackgroundColor3 = Color3.fromRGB(22, 16, 22)
    card.BackgroundTransparency = 0.25
    card.BorderSizePixel = 0
    card.Parent = page

    local cCorner = Instance.new("UICorner") cCorner.CornerRadius = UDim.new(0, 8) cCorner.Parent = card
    local cStroke = Instance.new("UIStroke") cStroke.Color = Color3.fromRGB(255, 45, 75) cStroke.Thickness = 1 cStroke.Transparency = 0.85 cStroke.Parent = card

    local tLabel = Instance.new("TextLabel")
    tLabel.Size = UDim2.new(0.40, 0, 1, 0)
    tLabel.Position = UDim2.new(0, 12, 0, 0)
    tLabel.BackgroundTransparency = 1
    tLabel.TextColor3 = Color3.fromRGB(245, 245, 250)
    tLabel.Font = Enum.Font.GothamBold
    tLabel.TextSize = 12
    tLabel.TextXAlignment = Enum.TextXAlignment.Left
    tLabel.Parent = card
    registerI18n(tLabel, "Text", titleKey)

    local box = Instance.new("TextBox")
    box.Size = UDim2.new(0.56, 0, 0, 32)
    box.Position = UDim2.new(0.42, 0, 0.5, -16)
    box.BackgroundColor3 = Color3.fromRGB(30, 22, 30)
    box.BorderSizePixel = 0
    box.TextColor3 = Color3.fromRGB(255, 255, 255)
    box.PlaceholderColor3 = Color3.fromRGB(150, 140, 150)
    box.PlaceholderText = placeholderText or "Enter text..."
    box.Text = defaultVal or ""
    box.Font = Enum.Font.Gotham
    box.TextSize = 11
    box.ClearTextOnFocus = false
    box.Parent = card

    local bc = Instance.new("UICorner") bc.CornerRadius = UDim.new(0, 8) bc.Parent = box
    local bs = Instance.new("UIStroke") bs.Color = Color3.fromRGB(255, 45, 75) bs.Thickness = 1 bs.Transparency = 0.7 bs.Parent = box

    box.FocusLost:Connect(function()
        if callback then callback(box.Text) end
    end)

    return card, box
end

local function addButton(page, textKey, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 38)
    btn.BackgroundColor3 = Color3.fromRGB(255, 35, 65)
    btn.BorderSizePixel = 0
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.Parent = page
    registerI18n(btn, "Text", textKey)

    local bCorner = Instance.new("UICorner") bCorner.CornerRadius = UDim.new(0, 8) bCorner.Parent = btn
    btn.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)
    return btn
end

-----------------------------------------------------------------------------------------
-- 📡 22. 2D LIVE RADAR CARD (Spec from StealAnEggSRC.lua)
-----------------------------------------------------------------------------------------
local function addRadarCard(page)
    local card = Instance.new("Frame")
    card.Name = "EggRadarCard"
    card.Size = UDim2.new(1, 0, 0, 132)
    card.BackgroundColor3 = Color3.fromRGB(22, 16, 24)
    card.BackgroundTransparency = 0.15
    card.BorderSizePixel = 0
    card.Parent = page

    local cCorner = Instance.new("UICorner") cCorner.CornerRadius = UDim.new(0, 10) cCorner.Parent = card
    local cStroke = Instance.new("UIStroke") cStroke.Color = Color3.fromRGB(0, 240, 255) cStroke.Thickness = 1.5 cStroke.Transparency = 0.4 cStroke.Parent = card

    local liveDot = Instance.new("Frame")
    liveDot.Size = UDim2.fromOffset(8, 8)
    liveDot.Position = UDim2.new(0, 12, 0, 10)
    liveDot.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
    liveDot.BorderSizePixel = 0
    liveDot.Parent = card
    local ldCorner = Instance.new("UICorner") ldCorner.CornerRadius = UDim.new(1, 0) ldCorner.Parent = liveDot

    local radarTitle = Instance.new("TextLabel")
    radarTitle.Size = UDim2.new(1, -30, 0, 18)
    radarTitle.Position = UDim2.new(0, 26, 0, 5)
    radarTitle.BackgroundTransparency = 1
    radarTitle.TextColor3 = Color3.fromRGB(0, 240, 255)
    radarTitle.Font = Enum.Font.GothamBold
    radarTitle.TextSize = 11
    radarTitle.TextXAlignment = Enum.TextXAlignment.Left
    radarTitle.Parent = card
    registerI18n(radarTitle, "Text", "RADAR_TITLE")

    local vf = Instance.new("Frame")
    vf.Size = UDim2.fromOffset(84, 84)
    vf.Position = UDim2.new(0, 12, 0, 32)
    vf.BackgroundColor3 = Color3.fromRGB(15, 10, 18)
    vf.BorderSizePixel = 0
    vf.Parent = card
    local vfCorner = Instance.new("UICorner") vfCorner.CornerRadius = UDim.new(0, 10) vfCorner.Parent = vf
    local vfStroke = Instance.new("UIStroke") vfStroke.Color = Color3.fromRGB(255, 45, 75) vfStroke.Thickness = 1.8 vfStroke.Parent = vf

    local vfImage = Instance.new("ImageLabel")
    vfImage.Size = UDim2.new(1, -8, 1, -8)
    vfImage.Position = UDim2.new(0, 4, 0, 4)
    vfImage.BackgroundTransparency = 1
    vfImage.Image = "rbxassetid://135618011146990"
    vfImage.ScaleType = Enum.ScaleType.Fit
    vfImage.Parent = vf

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, -225, 0, 20)
    nameLabel.Position = UDim2.new(0, 106, 0, 30)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = L("RADAR_SCANNING")
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 13
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Parent = card

    local locLabel = Instance.new("TextLabel")
    locLabel.Size = UDim2.new(1, -225, 0, 16)
    locLabel.Position = UDim2.new(0, 106, 0, 52)
    locLabel.BackgroundTransparency = 1
    locLabel.Text = L("RADAR_WAIT_SPAWN")
    locLabel.TextColor3 = Color3.fromRGB(190, 185, 200)
    locLabel.Font = Enum.Font.GothamMedium
    locLabel.TextSize = 10
    locLabel.TextXAlignment = Enum.TextXAlignment.Left
    locLabel.Parent = card

    local rateLabel = Instance.new("TextLabel")
    rateLabel.Size = UDim2.new(1, -225, 0, 16)
    rateLabel.Position = UDim2.new(0, 106, 0, 72)
    rateLabel.BackgroundTransparency = 1
    rateLabel.Text = "💰 อัตราผลิตเงิน: +$0/s • ⏱️ ฟัก: 0s"
    rateLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
    rateLabel.Font = Enum.Font.GothamBold
    rateLabel.TextSize = 10
    rateLabel.TextXAlignment = Enum.TextXAlignment.Left
    rateLabel.Parent = card

    local priceLabel = Instance.new("TextLabel")
    priceLabel.Size = UDim2.new(1, -225, 0, 16)
    priceLabel.Position = UDim2.new(0, 106, 0, 92)
    priceLabel.BackgroundTransparency = 1
    priceLabel.Text = string.format(L("RADAR_EST_VALUE"), "0")
    priceLabel.TextColor3 = Color3.fromRGB(46, 204, 113)
    priceLabel.Font = Enum.Font.GothamBold
    priceLabel.TextSize = 10
    priceLabel.TextXAlignment = Enum.TextXAlignment.Left
    priceLabel.Parent = card

    local snipeBtn = Instance.new("TextButton")
    snipeBtn.Size = UDim2.fromOffset(102, 42)
    snipeBtn.Position = UDim2.new(1, -114, 0, 52)
    snipeBtn.BackgroundColor3 = Color3.fromRGB(255, 35, 65)
    snipeBtn.BorderSizePixel = 0
    snipeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    snipeBtn.Font = Enum.Font.GothamBold
    snipeBtn.TextSize = 11
    snipeBtn.Text = "🚀 " .. L("RADAR_SNIPE_NOW")
    snipeBtn.Parent = card

    local sbCorner = Instance.new("UICorner") sbCorner.CornerRadius = UDim.new(0, 8) sbCorner.Parent = snipeBtn
    local sbStroke = Instance.new("UIStroke") sbStroke.Color = Color3.fromRGB(255, 120, 140) sbStroke.Thickness = 1.2 sbStroke.Parent = snipeBtn

    local currentBestEgg = nil
    snipeBtn.MouseButton1Click:Connect(function()
        if currentBestEgg and not _G._SAA_IsStealing then
            task.spawn(function()
                executeStealCycle(currentBestEgg)
            end)
        end
    end)

    task.spawn(function()
        while card and card.Parent and isCurrentRun() do
            pcall(function()
                local eggs = getWildEggSnapshot(1.5)
                if #eggs > 0 then
                    local egg = eggs[1]
                    currentBestEgg = egg

                    local assetData = AssetDirectory and AssetDirectory[egg.Name]
                    local eggDisplayName = (assetData and assetData.Egg and assetData.Egg.DisplayName) or (assetData and assetData.DisplayName) or (egg.Name .. " Egg")
                    local eggIcon = (assetData and assetData.Egg and assetData.Egg.Icon)
                        or (assetData and assetData.Icon)
                        or "rbxassetid://135618011146990"

                    vfImage.Image = eggIcon

                    local col = RARITY_COLORS[egg.Rarity] or Color3.fromRGB(255, 255, 255)
                    nameLabel.Text = eggDisplayName .. " (" .. egg.Rarity .. ")"
                    nameLabel.TextColor3 = col
                    vfStroke.Color = col

                    local oddsText = (assetData and assetData.Rarity and assetData.Rarity.DefaultRarityValue) or ""
                    locLabel.Text = string.format("📍 %s (ห่าง %d studs) %s", egg.Area, math.floor(egg.Distance), oddsText ~= "" and ("• " .. oddsText) or "")

                    local earnRate = (assetData and tonumber(assetData.EarningRate)) or 0
                    local growthTime = (assetData and assetData.Egg and assetData.Egg.GrowthTime) or "?"
                    rateLabel.Text = string.format("💰 ผลิต: +$%s/s  •  ⏱️ ฟัก: %ss", shortNum(earnRate), tostring(growthTime))

                    local estPrice = (egg.Rank or 1) * 25000
                    priceLabel.Text = string.format("💎 มูลค่าขายประเมิน: ~$%s", shortNum(estPrice))
                else
                    currentBestEgg = nil
                    nameLabel.Text = L("RADAR_NO_TARGET")
                    nameLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
                    locLabel.Text = L("RADAR_WAIT_SPAWN")
                    rateLabel.Text = "💰 ผลิต: +$0/s  •  ⏱️ ฟัก: 0s"
                    priceLabel.Text = string.format(L("RADAR_EST_VALUE"), "0")
                    vfStroke.Color = Color3.fromRGB(80, 70, 80)
                end
            end)
            task.wait(1.25)
        end
    end)
end

-- TAB 1: AUTO STEAL
local pSteal = createTab("TAB_STEAL", "⚡")
addRadarCard(pSteal)
addSectionCard(pSteal, "SEC_STEAL")
addToggle(pSteal, "AUTO_STEAL", "AUTO_STEAL_SUB", Cfg.AutoSteal, function(v) Cfg.AutoSteal = v end)

local islandNames = {}
for _, t in ipairs(ISLAND_TIERS) do table.insert(islandNames, t.Id) end
addDropdown(pSteal, "TARGET_ISLANDS", islandNames, Cfg.TargetIslands, true, function(sel) Cfg.TargetIslands = sel end)

local rarityNames = { "Common", "Uncommon", "Rare", "SuperRare", "Epic", "Legendary", "Mythic", "Cosmic", "Divine", "Secret" }
-- Older saved profiles can contain an empty multi-select; that makes hasRarity()
-- reject every egg. Restore the default selection before building the dropdown.
if type(Cfg.TargetRarities) ~= "table" or #Cfg.TargetRarities == 0 then
    Cfg.TargetRarities = table.clone(rarityNames)
end
addDropdown(pSteal, "ALLOWED_RARITIES", rarityNames, Cfg.TargetRarities, true, function(sel) Cfg.TargetRarities = sel end)

addDropdown(pSteal, "MOVE_MODE", { "Blink (Instant)", "Glide (Smooth Safe)", "Underground (Stealth)" }, Cfg.MovementMode, false, function(sel) Cfg.MovementMode = sel end)
addDropdown(pSteal, "PRIORITY_MODE", { "Highest Rarity First", "Lowest Rarity First", "Nearest Distance" }, Cfg.PriorityMode, false, function(sel) Cfg.PriorityMode = sel end)
addSlider(pSteal, "FLIGHT_SPEED", 50, 300, Cfg.FlightSpeed, function(v) Cfg.FlightSpeed = v end)
addSlider(pSteal, "STEAL_DELAY", 0.1, 2.0, Cfg.StealDelay, function(v) Cfg.StealDelay = v end)

-- TAB 2: REBIRTH & FUSE MACHINE
local pRebirthFuse = createTab("TAB_REBIRTH_FUSE", "🔄")
addSectionCard(pRebirthFuse, "SEC_REBIRTH")

local rbCard = Instance.new("Frame")
rbCard.Size = UDim2.new(1, 0, 0, 56)
rbCard.BackgroundColor3 = Color3.fromRGB(24, 18, 24)
rbCard.BackgroundTransparency = 0.2
rbCard.BorderSizePixel = 0
rbCard.Parent = pRebirthFuse
local rbcCorner = Instance.new("UICorner") rbcCorner.CornerRadius = UDim.new(0, 8) rbcCorner.Parent = rbCard
local rbcStroke = Instance.new("UIStroke") rbcStroke.Color = Color3.fromRGB(255, 45, 75) rbcStroke.Thickness = 1 rbcStroke.Transparency = 0.8 rbcStroke.Parent = rbCard

local rbTitle = Instance.new("TextLabel")
rbTitle.Size = UDim2.new(1, -20, 0, 20)
rbTitle.Position = UDim2.new(0, 12, 0, 6)
rbTitle.BackgroundTransparency = 1
rbTitle.TextColor3 = Color3.fromRGB(255, 220, 230)
rbTitle.Font = Enum.Font.GothamBold
rbTitle.TextSize = 12
rbTitle.TextXAlignment = Enum.TextXAlignment.Left
rbTitle.Parent = rbCard

local rbSub = Instance.new("TextLabel")
rbSub.Size = UDim2.new(1, -20, 0, 18)
rbSub.Position = UDim2.new(0, 12, 0, 28)
rbSub.BackgroundTransparency = 1
rbSub.TextColor3 = Color3.fromRGB(170, 160, 170)
rbSub.Font = Enum.Font.Gotham
rbSub.TextSize = 11
rbSub.TextXAlignment = Enum.TextXAlignment.Left
rbSub.Parent = rbCard

task.spawn(function()
    while rbCard and rbCard.Parent and isCurrentRun() do
        pcall(function()
            local info = getRebirthInfo()
            rbTitle.Text = string.format("Rebirth %d  •  (Speed: %s / %s)", info.CurrentTier, shortNum(info.CurrentSpeed), shortNum(info.RequiredSpeed))
            local status = info.IsReady and L("REBIRTH_READY") or L("REBIRTH_FARMING")
            rbSub.Text = string.format("Cash Mult: x%.1f  •  %s", info.CashMultiplier, status)
        end)
        task.wait(1.0)
    end
end)

addToggle(pRebirthFuse, "AUTO_REBIRTH", "AUTO_REBIRTH_SUB", Cfg.AutoRebirth, function(v) Cfg.AutoRebirth = v end)
addButton(pRebirthFuse, "REBIRTH_NOW_BTN", function()
    if Net.RebirthRequest then Net.RebirthRequest:FireServer("Rebirth") end
end)

addSectionCard(pRebirthFuse, "SEC_FUSE")
addToggle(pRebirthFuse, "AUTO_FUSE", "AUTO_FUSE_SUB", Cfg.AutoFuse, function(v) Cfg.AutoFuse = v end)
addDropdown(pRebirthFuse, "FUSE_RARITIES", { "Common", "Uncommon", "Rare", "SuperRare", "Epic", "Legendary", "Mythic", "Cosmic" }, Cfg.AllowedFuseRarities, true, function(sel) Cfg.AllowedFuseRarities = sel end)
addButton(pRebirthFuse, "FUSE_NOW_BTN", function() runAutoFuse() end)

-- TAB 3: BASE, HEROES & SELL
local pBase = createTab("TAB_BASE", "🏠")
addSectionCard(pBase, "SEC_BASE")
addToggle(pBase, "AUTO_PLACE", "AUTO_PLACE_SUB", Cfg.AutoPlace, function(v) Cfg.AutoPlace = v end)
addDropdown(pBase, "PLACE_RARITIES", { "Common", "Uncommon", "Rare", "SuperRare", "Epic", "Legendary", "Mythic", "Cosmic", "Divine", "Secret" }, Cfg.AllowedPlaceRarities, true, function(sel) Cfg.AllowedPlaceRarities = sel end)
addToggle(pBase, "AUTO_HATCH", "AUTO_HATCH_SUB", Cfg.AutoHatch, function(v) Cfg.AutoHatch = v end)
addToggle(pBase, "AUTO_TREADMILL", "AUTO_TREADMILL_SUB", Cfg.AutoTreadmill, function(v) Cfg.AutoTreadmill = v end)

addSectionCard(pBase, "SEC_SELL")
addToggle(pBase, "AUTO_SELL", "AUTO_SELL_SUB", Cfg.AutoSell, function(v) Cfg.AutoSell = v end)
addDropdown(pBase, "SELL_RARITIES", { "Common", "Uncommon", "Rare", "SuperRare", "Epic", "Legendary", "Mythic", "Cosmic", "Divine" }, Cfg.AllowedSellRarities, true, function(sel) Cfg.AllowedSellRarities = sel end)
addInputBox(pBase, "MIN_KEEP_PRICE", "ใส่ราคาขั้นต่ำ เช่น 1B, 500M หรือ 0", tostring(Cfg.MinKeepPrice or "0"), function(val)
    Cfg.MinKeepPrice = val
end)
addInputBox(pBase, "MIN_KEEP_RATE", "ใส่อัตราผลิตเงิน เช่น 100M หรือ 0", tostring(Cfg.MinKeepRate or "0"), function(val)
    Cfg.MinKeepRate = val
end)
addButton(pBase, "SELL_NOW_BTN", function() runAutoSell(true) end)

addToggle(pBase, "AUTO_SELL_EGGS", "AUTO_SELL_EGGS_SUB", Cfg.AutoSellEggs, function(v) Cfg.AutoSellEggs = v end)
addDropdown(pBase, "EGG_SELL_RARITIES", { "Common", "Uncommon", "Rare", "SuperRare", "Epic", "Legendary", "Mythic" }, Cfg.AllowedEggSellRarities, true, function(sel) Cfg.AllowedEggSellRarities = sel end)
addButton(pBase, "SELL_EGGS_NOW_BTN", function() runAutoSell(true) end)
addButton(pBase, "CLAIM_PLOT_BTN", function() pcall(claimPlot) end)

-- TAB 4: CLAIMS & UPGRADES
local pClaims = createTab("TAB_CLAIMS", "🎁")
addSectionCard(pClaims, "SEC_CLAIMS")
addToggle(pClaims, "EQUIP_BEST", "EQUIP_BEST_SUB", Cfg.AutoEquipBest, function(v) Cfg.AutoEquipBest = v end)
addToggle(pClaims, "UPGRADE_BASE", "UPGRADE_BASE_SUB", Cfg.AutoUpgradeBase, function(v) Cfg.AutoUpgradeBase = v end)
addToggle(pClaims, "UPGRADE_TM", "UPGRADE_TM_SUB", Cfg.AutoUpgradeTreadmill, function(v) Cfg.AutoUpgradeTreadmill = v end)
addToggle(pClaims, "CLAIM_DAILY", "CLAIM_DAILY_SUB", Cfg.AutoClaimDaily, function(v) Cfg.AutoClaimDaily = v end)
addToggle(pClaims, "CLAIM_OFFLINE", "CLAIM_OFFLINE_SUB", Cfg.AutoClaimOffline, function(v) Cfg.AutoClaimOffline = v end)
addToggle(pClaims, "CLAIM_GROUP", "CLAIM_GROUP_SUB", Cfg.AutoClaimGroup, function(v) Cfg.AutoClaimGroup = v end)
addToggle(pClaims, "CLAIM_STEP", "CLAIM_STEP_SUB", Cfg.AutoClaimStepBoost, function(v) Cfg.AutoClaimStepBoost = v end)

-- TAB 5: VISUALS & ESP
local pVis = createTab("TAB_VISUALS", "👁")
addSectionCard(pVis, "SEC_VISUALS")
addToggle(pVis, "EGG_ESP", "EGG_ESP_SUB", Cfg.EggESP, function(v)
    Cfg.EggESP = v
    if not v then
        for _, c in ipairs(ESPFolder:GetChildren()) do c:Destroy() end
    end
end)
addToggle(pVis, "HIDE_PLAYERS", "HIDE_PLAYERS_SUB", Cfg.HidePlayers, function(v)
    Cfg.HidePlayers = v
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            for _, part in ipairs(p.Character:GetDescendants()) do
                if part:IsA("BasePart") or part:IsA("Decal") then
                    part.LocalTransparencyModifier = v and 1 or 0
                end
            end
        end
    end
end)
addToggle(pVis, "FPS_BOOST", "FPS_BOOST_SUB", Cfg.FPSBoost, function(v)
    Cfg.FPSBoost = v
    if v then applyAntiLag() end
end)

-- TAB 6: SETTINGS & CONFIG
local pSettings = createTab("TAB_SETTINGS", "🛠")
addSectionCard(pSettings, "SEC_CONFIG")

local cfgNameBox = nil
_, cfgNameBox = addInputBox(pSettings, "Active Profile Name", "Default", Cfg.ActiveProfile, function(txt)
    Cfg.ActiveProfile = txt
end)

addButton(pSettings, "SAVE_CFG_BTN", function()
    local name = (cfgNameBox and cfgNameBox.Text ~= "") and cfgNameBox.Text or Cfg.ActiveProfile
    saveConfig(name)
end)

local configFiles = getSavedConfigs()
addDropdown(pSettings, "Load Profile", configFiles, Cfg.ActiveProfile, false, function(sel)
    loadConfig(sel)
    if cfgNameBox then cfgNameBox.Text = sel end
end)

addToggle(pSettings, "AUTOLOAD_CFG", "AUTOLOAD_CFG_SUB", Cfg.AutoLoadProfile, function(v)
    Cfg.AutoLoadProfile = v
    if v and cfgNameBox then
        pcall(function() writefile(CONFIG_FOLDER .. "/autoload.txt", cfgNameBox.Text) end)
    end
end)

addSectionCard(pSettings, "SEC_WEBHOOK")
addToggle(pSettings, "ENABLE_WEBHOOK", "ENABLE_WEBHOOK_SUB", Cfg.WebhookEnabled, function(v) Cfg.WebhookEnabled = v end)
addInputBox(pSettings, "Webhook URL", "https://discord.com/api/webhooks/...", Cfg.WebhookUrl, function(txt)
    Cfg.WebhookUrl = txt
end)
addButton(pSettings, "TEST_WEBHOOK_BTN", function()
    sendWebhook("🧪 DISCORD WEBHOOK TEST", string.format("Webhook successfully connected from **%s** (@%s)!", LocalPlayer.DisplayName, LocalPlayer.Name), {
        { name = "Game", value = "Steal An Anime Egg", inline = true },
        { name = "Place ID", value = tostring(game.PlaceId), inline = true }
    }, 65280)
end)

addSectionCard(pSettings, "SEC_SERVER")
addToggle(pSettings, "ANTI_AFK", "ANTI_AFK_SUB", Cfg.AntiAFK, function(v) Cfg.AntiAFK = v end)
addButton(pSettings, "REJOIN_BTN", function()
    TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
end)
addButton(pSettings, "HOP_BTN", function()
    local x = {}
    pcall(function()
        local req = request({ Url = string.format("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Desc&limit=100", game.PlaceId) })
        local body = HttpService:JSONDecode(req.Body)
        if body and body.data then
            for _, s in ipairs(body.data) do
                if type(s) == "table" and s.maxPlayers > s.playing and s.id ~= game.JobId then
                    table.insert(x, s.id)
                end
            end
        end
    end)
    if #x > 0 then
        TeleportService:TeleportToPlaceInstance(game.PlaceId, x[math.random(1, #x)], LocalPlayer)
    else
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end
end)

-- Default Tab Active
switchTab(1)

-- Keybind toggle (Insert / RightControl)
UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and (input.KeyCode == Enum.KeyCode.RightControl or input.KeyCode == Enum.KeyCode.Insert) then
        shell.Visible = not shell.Visible
    end
end)

-----------------------------------------------------------------------------------------
-- ⚡ 24. SMART UNIFIED ORCHESTRATOR (COOPERATIVE STATE MACHINE v3.1)
-----------------------------------------------------------------------------------------
-- Priority order:
--   P1. Holding egg (place it NOW)
--   P2. Auto Hatch (fire prompt if growth >= 100%)
--   P3. Upkeep: Rebirth / Fuse / Claims (throttled to 2s)
--   P4. Auto Sell (throttled to user interval)
--   P5. Auto Steal (if no higher priority active)
--   P6. Treadmill IDLE (ONLY when AutoSteal OFF or no eggs found)
--
-- Key fix: Treadmill now cached to avoid scanWildEggs every tick.
-- Treadmill NEVER interrupts a steal cycle.
task.spawn(function()
    local lastSellTime = 0
    local lastUpkeepTime = 0
    local lastScanTime = 0
    local lastPlaceAttempt = 0
    local lastHatchTime = 0
    local cachedEggCount = 0
    local hatchInFlight = false
    local rebirthInFlight = false
    local claimsInFlight = false

    while isCurrentRun() do
        -- รอ character
        if not isAlive() then
            task.wait(1.0)
            continue
        end

        local now = os.clock()

        -- Safety watchdog: clear stuck steal flag
        -- Long smooth routes can legitimately take several seconds; 4s cleared the lock
        -- mid-route and let placement/treadmill workers move the character concurrently.
        if _G._SAA_IsStealing and (now - (_G._SAA_StealStartTime or 0) > 30.0) then
            _G._SAA_IsStealing = false
        end

        -- P1: กำลัง hold ไข่ -> กลับบ้าน + วาง (highest priority)
        -- *** ทำงานนอก pcall เพราะมี task.wait ข้างใน ***
        if isHoldingEgg() then
            -- executeStealCycle owns movement while active. A second return here
            -- can cross the safe-area boundary at the same time and cancel the carry.
            if not _G._SAA_IsStealing then
                local root = getHrp()
                local homePos = getHomePos()
                if root and (root.Position - homePos).Magnitude > 6 then
                    _G._SAA_IsStealing = true
                    _G._SAA_StealStartTime = os.clock()
                    pcall(function() transitCarriedEggToHome(homePos) end)
                    _G._SAA_IsStealing = false
                end
                -- The game has not transferred a still-held egg into inventory yet;
                -- do not hammer the inventory/placement calls while it remains held.
            end
            task.wait(0.35)
            continue
        end

        -- P1.5: วางไข่จากในกระเป๋าลงคอกอัตโนมัติ 1-2-3-4
        if Cfg.AutoPlace and not _G._SAA_IsStealing and (now - lastPlaceAttempt >= 5.0) then
            lastPlaceAttempt = now
            pcall(function() executePlaceEggBatch(3) end)
        end

        -- P2: Hatch ฮีโร่บนแปลง
        if Cfg.AutoHatch and not _G._SAA_IsStealing and not hatchInFlight and now - lastHatchTime >= 8.0 then
            lastHatchTime = now
            hatchInFlight = true
            task.spawn(function()
                local ok, err = pcall(runAutoHatch)
                if not ok then warn("[SAA][HATCH] " .. tostring(err)) end
                hatchInFlight = false
            end)
        end

        -- P3: Upkeep (Rebirth, Fuse, Claims) ทุก 2s
        if now - lastUpkeepTime >= 8.0 then
            lastUpkeepTime = now
            if not _G._SAA_IsStealing then
                -- These remote calls may yield. Keep them off the scheduler that scans for eggs.
                if Cfg.AutoRebirth and not rebirthInFlight then
                    rebirthInFlight = true
                    task.spawn(function()
                        local ok, err = pcall(runAutoRebirth)
                        if not ok then warn("[SAA][REBIRTH] " .. tostring(err)) end
                        rebirthInFlight = false
                    end)
                end
                if Cfg.AutoFuse then pcall(runAutoFuse) end
                if not claimsInFlight then
                    claimsInFlight = true
                    task.spawn(function()
                        local ok, err = pcall(runAutoClaims)
                        if not ok then warn("[SAA][CLAIMS] " .. tostring(err)) end
                        claimsInFlight = false
                    end)
                end
            end
            if Cfg.EggESP then pcall(updateEggESP) end
        end

        -- P4: Auto Sell
        if Cfg.AutoSell and (now - lastSellTime >= (Cfg.AutoSellInterval or 20)) then
            if not _G._SAA_IsStealing then
                lastSellTime = now
                pcall(runAutoSell)
            end
        end

        -- P5: Auto Steal (มี task.wait ภายใน executeStealCycle - ต้องทำนอก pcall)
        if Cfg.AutoSteal and not _G._SAA_IsStealing then
            if now - lastScanTime >= 0.8 then
                lastScanTime = now
                local eggs = getWildEggSnapshot(0.8)
                cachedEggCount = #eggs
                if cachedEggCount > 0 then
                    executeStealCycle(eggs[1])
                    task.wait(0.15)
                    continue
                end
            elseif cachedEggCount > 0 then
                local eggs = getWildEggSnapshot(0.8)
                if #eggs > 0 then
                    executeStealCycle(eggs[1])
                    task.wait(0.15)
                    continue
                else
                    cachedEggCount = 0
                end
            end
        end

        -- P6: Treadmill IDLE
        local canTreadmill = Cfg.AutoTreadmill
            and not _G._SAA_IsStealing
            and not isHoldingEgg()
            and (not Cfg.AutoSteal or cachedEggCount == 0)

        if canTreadmill then
            pcall(runTreadmillStep)
        end

        task.wait(0.35)
    end
end)

-- Anti-AFK Worker
task.spawn(function()
    LocalPlayer.Idled:Connect(function()
        if Cfg.AntiAFK and isCurrentRun() then
            pcall(function()
                local vu = game:GetService("VirtualUser")
                vu:Button2Down(Vector2.zero, Workspace.CurrentCamera.CFrame)
                task.wait(1)
                vu:Button2Up(Vector2.zero, Workspace.CurrentCamera.CFrame)
            end)
        end
    end)
end)

print("[PAYOMBØYZ HUB] Obsidian Glass 3.0 Initialized with Mobile Responsive Modal, Multi-Islands, Config Profiles & Webhook")
