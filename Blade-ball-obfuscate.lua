-- ==============================================================================
-- 🔒 PAYOMBØYZ CORE SECURITY & BAC BYPASS SUITE
-- Script: PAYOMBØYZ Master Blade Ball & Broken Blade Hybrid Suite
-- Architecture: Obsidian Glassmorphic 2.0 (Top Tabs Navigation Pill Concept)
-- Target: Blade Ball (PvP / Arena / Training / Tutorial) & Broken Blade (RPG)
-- Blueprint Spec: SCRIPT_PLAY_UI_BLUEPRINT_SPEC.md (Image Sep 28.png + Master Tabs + Floating Capsule HUD)
-- Bilingual Support: ภาษาไทย (TH) / English (EN)
-- ==============================================================================

-- ==============================================================================
-- 🛡️ PART 1: ADVANCED BAC (BLADE BALL ANTI-CHEAT) BYPASS SHIELD
-- ==============================================================================
if getgenv()._PayomboyZ_BAC_Shield then
    pcall(function()
        if _G.PayomboyZ_BB_Cleanup then _G.PayomboyZ_BB_Cleanup() end
    end)
    getgenv()._PayomboyZ_BAC_Shield = nil
    task.wait(0.1)
end
getgenv()._PayomboyZ_BAC_Shield = true

local cloneref = cloneref or function(i) return i end
local ContentProvider = cloneref(game:GetService("ContentProvider"))
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
local VirtualInputManager = cloneref(game:GetService("VirtualInputManager"))
local GuiService = cloneref(game:GetService("GuiService"))
local Lighting = cloneref(game:GetService("Lighting"))
local Camera = workspace.CurrentCamera

local hook = hookfunction or detour_function or (replaceclosure and function(old, new) return replaceclosure(old, new) end)
local cclosure = newcclosure or function(f) return f end
local renv = getrenv and getrenv() or _G
local set_readonly = setreadonly or (make_writeable and function(t, v) if v then make_writeable(t) else make_readonly(t) end end)

local function isRelevantCaller()
    for i = 3, 7 do
        local src = debug.info(i, "s")
        if src and (
            src:find("RemoveLoadingScreen") or
            src:find("Loading") or
            src:find("Detection") or
            src:find("AntiCheat") or
            src:find("BAC")
        ) then
            return true
        end
    end
    if getcallingscript then
        local ok, scr = pcall(getcallingscript)
        if ok and scr then
            local n = tostring(scr)
            if n:find("RemoveLoadingScreen") or n:find("Loading") or n:find("Detection") or n:find("AntiCheat") then
                return true
            end
        end
    end
    return false
end

-- 1. Hook renv.math.random to spoof 0 for BAC loading integrity
if hook and renv and renv.math and renv.math.random then
    local origRandom
    origRandom = hook(renv.math.random, cclosure(function(...)
        if isRelevantCaller() then return 0 end
        return origRandom(...)
    end))
end

-- 2. Hook ContentProvider.PreloadAsync for instantaneous integrity bypass
if hook and ContentProvider and ContentProvider.PreloadAsync then
    local origPreload
    origPreload = hook(ContentProvider.PreloadAsync, cclosure(function(self, assets, callback)
        if self ~= ContentProvider then return origPreload(self, assets, callback) end
        if isRelevantCaller() and type(assets) == "table" then
            if callback then
                for _, asset in ipairs(assets) do
                    task.spawn(pcall, callback, asset, Enum.AssetFetchStatus.Success)
                end
            end
            return
        end
        return origPreload(self, assets, callback)
    end))
end

-- 3. Metatable __namecall hook for PreloadAsync
local mt = getrawmetatable and getrawmetatable(game)
if mt and set_readonly then
    local origNamecall = mt.__namecall
    set_readonly(mt, false)
    mt.__namecall = cclosure(function(self, ...)
        local method = getnamecallmethod and getnamecallmethod()
        local args = { ... }
        if method == "PreloadAsync" and self == ContentProvider and isRelevantCaller() then
            pcall(function()
                local assets, callback = args[1], args[2]
                if type(assets) == "table" and callback then
                    for _, asset in ipairs(assets) do
                        task.spawn(pcall, callback, asset, Enum.AssetFetchStatus.Success)
                    end
                end
            end)
            return
        end
        return origNamecall(self, ...)
    end)
    set_readonly(mt, true)
end

-- 4. Hook debug.info & getfenv for callstack/upvalue anti-detection
if hook then
    pcall(function()
        local orig_dinfo
        orig_dinfo = hook(getrenv().debug.info, cclosure(function(f, t)
            if type(f) == "function" then
                return "[C]"
            elseif f == 4 and t == "s" then
                return "ReplicatedStorage.Controllers.SwordsController "
            end
            return orig_dinfo(f, t)
        end))
        local orig_gfenv
        orig_gfenv = hook(getrenv().getfenv, cclosure(function(l)
            if l ~= nil and type(l) == "number" and (l >= 1 and l <= 10) then
                return orig_gfenv(10)
            end
            return orig_gfenv(l)
        end))
    end)
end

-- 5. Queue on teleport persistence
if queue_on_teleport then
    pcall(function()
        queue_on_teleport([[
            if readfile and isfile and isfile("PayomboyZ Hub/BladeBall.luau") then
                loadstring(readfile("PayomboyZ Hub/BladeBall.luau"))()
            end
        ]])
    end)
end

-- ==============================================================================
-- 🌐 PART 2: ENVIRONMENT DETECTION & RUNTIME STATE
-- ==============================================================================
local raidworld = false
local dragonworld = false
local normalrpgworld = false
local isBrokenBlade = false
local isStandardBladeBall = true

if game.PlaceId == 135348858107730 or game.PlaceId == 91071552992781 then
    raidworld = true
    isBrokenBlade = true
    isStandardBladeBall = false
    if game.PlaceId == 91071552992781 then dragonworld = true end
elseif game.PlaceId == 97387256206808 then
    normalrpgworld = true
    isBrokenBlade = true
    isStandardBladeBall = false
end

if workspace:FindFirstChild("EnemyService") then
    isBrokenBlade = true
end

if workspace:FindFirstChild("Balls") or workspace:FindFirstChild("TrainingBalls") then
    isStandardBladeBall = true
end

-- Lifecycle Management
if _G.PayomboyZBrokenBladeCleanup then
    pcall(_G.PayomboyZBrokenBladeCleanup)
    task.wait(0.05)
end

_G.PayomboyZBrokenBladeConns = {}
local RUN = {}
_G.PayomboyZBrokenBladeRun = RUN

local function bind(signal, fn)
    local c = signal:Connect(fn)
    table.insert(_G.PayomboyZBrokenBladeConns, c)
    return c
end

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

safeDestroyGui("PayomboyZ_BB_HUD")
safeDestroyGui("GlobalColorScreen")

-- ==============================================================================
-- ⚙️ PART 3: SETTINGS & CONFIGURATION MANAGER
-- ==============================================================================
local defaultSettings = {
    -- ── Blade Ball Core (PvP) ──
    Auto_Parry = false,
    Parry_Mode = "Hybrid", -- "Legit (Keypress)", "Rage (Remote)", "Hybrid"
    Parry_Key = "F",
    Parry_Distance = 35,
    Auto_Spam_Clash = false,
    Spam_Distance = 14,
    Spam_Rate = 0.03,
    Curve_Detection = true,
    Ping_Compensation = true,
    Reaction_Jitter = 0.025,

    -- ── Bonus Feature 1: Visuals & ESP ──
    Parry_Range_Visual = false,
    Ball_Tracer = false,
    Ball_Highlight = false,
    Ball_HUD = false,

    -- ── Bonus Feature 2: Auto Defense & Curve Dash ──
    Auto_Defensive_Skill = false,
    Emergency_Threshold = 0.12,
    Defensive_Key = "Q",

    -- ── Broken Blade (RPG Mode) ──
    Auto_Farm = false,
    Select_Enemy = "Multi Select",
    Mode_Farm = "Above",
    Disc = 5,
    Select_Weapon = "1",
    Select_Skill = { "Z", "X", "C" },
    Auto_Skill = false,
    Auto_Block_RPG = false,
    Block_Button_RPG = "F",
    Block_Delay_RPG = 0.05,
    Auto_Summon_Eclipse = false,
    Selected_Difficult_Eclipse = "Easy",
    Auto_Raid = false,
    Selected_Raid = "Easy",
    Auto_Broken_Expanse_Join_Raid = false,
    Auto_Find_Quest = false,
    Selected_Chest = "Secret Chest",
    Chest_Amount = 1,
    Selected_Chest2 = "None",
    Chest_Amount2 = 1,
    One_Priority = "Farm", Two_Priority = "None", Three_Priority = "None", Four_Priority = "None", Five_Priority = "None", Six_Priority = "None", Seven_Priority = "None",
    One_Select = "", Two_Select = "", Three_Select = "", Four_Select = "", Five_Select = "", Six_Select = "", Seven_Select = "", Eight_Select = "", Nine_Select = "", Ten_Select = "", Eleven_Select = "", Twelve_Select = "",
    Selected_Sword = "",

    -- ── Misc & System ──
    Screen_CPUStart = false,
    Screen_cpu = "Black",
    Auto_Rejoin = true,
    Auto_Execute = true,

    -- ── Webhook ──
    Send_Webhook = false,
    Webhook_Link = "",
    Webhook_Notify = { "Aura Crate", "Secret Chest" },
    Pings_Userid = "",
    Send_Webhook_Pings = false,
}

if not _G.Settings then
    _G.Settings = defaultSettings
else
    for k, v in pairs(defaultSettings) do
        if _G.Settings[k] == nil then
            _G.Settings[k] = v
        end
    end
end

local ModeFarm2 = CFrame.new(0, _G.Settings.Disc, 0) * CFrame.Angles(math.rad(-90), 0, 0)
local function updateModeFarm()
    local disc = _G.Settings.Disc or 5
    if _G.Settings.Mode_Farm == "Below" then
        ModeFarm2 = CFrame.new(0, -disc, 0) * CFrame.Angles(math.rad(90), 0, 0)
    elseif _G.Settings.Mode_Farm == "Behind" then
        ModeFarm2 = CFrame.new(0, 0, disc)
    elseif _G.Settings.Mode_Farm == "Above" then
        ModeFarm2 = CFrame.new(0, disc, 0) * CFrame.Angles(math.rad(-90), 0, 0)
    else
        ModeFarm2 = CFrame.new(0, 0, disc)
    end
end
updateModeFarm()

local CONFIG_ROOT = "PayomboyZ Hub"
local CONFIG_GAME = CONFIG_ROOT .. "/BladeBall"
pcall(function()
    if makefolder and isfolder then
        if not isfolder(CONFIG_ROOT) then makefolder(CONFIG_ROOT) end
        if not isfolder(CONFIG_GAME) then makefolder(CONFIG_GAME) end
    end
end)

local function getSavedConfigPath(name)
    name = name or ("Settings_" .. LocalPlayer.UserId)
    return CONFIG_GAME .. "/" .. name .. ".json"
end

local function saveConfig(name)
    pcall(function()
        if writefile then
            local p = getSavedConfigPath(name)
            writefile(p, HttpService:JSONEncode(_G.Settings))
        end
    end)
end

local function loadConfig(name)
    pcall(function()
        if readfile and isfile then
            local p = getSavedConfigPath(name)
            if isfile(p) then
                local data = HttpService:JSONDecode(readfile(p))
                for k, v in pairs(data) do _G.Settings[k] = v end
                updateModeFarm()
            end
        end
    end)
end

-- ==============================================================================
-- 🌐 PART 4: BILINGUAL TRANSLATION DICTIONARY (TH / EN)
-- ==============================================================================
local currentLang = "TH"

local TRANSLATIONS = {
    TH = {
        script_title = "PAYOMBØYZ — Master Blade Ball",
        tab_parry = "⚔️ ออโต้แพรี่ & PvP",
        tab_clash = "⚡ แคลช & สแปม",
        tab_visuals = "👁️ วิชวล & บอล ESP",
        tab_defense = "🌀 สกิลป้องกัน & แดช",
        tab_rpg_farm = "👹 RPG ฟาร์ม & มอน",
        tab_rpg_boss = "🏰 RPG บอส & เรด",
        tab_misc = "⚡ ปรับแต่ง & ลดแลค",
        tab_settings = "⚙️ ตั้งค่า & Webhook",

        -- Tab 1: Auto Parry
        sec_parry = "ระบบออโต้แพรี่ขั้นสูง (Advanced Auto Parry Suite)",
        parry_card = "เปิดใช้งาน Auto Parry (ปัดบอลอัตโนมัติ)",
        parry_card_desc = "คำนวณวิถี ความเร็ว ค่าปิง และความโค้งของลูกบอล ปัดบอลแม่นยำ 100%",
        parry_mode = "โหมดการแพรี่ (Parry Execution Mode)",
        parry_dist = "ระยะตรวจจับแพรี่ (Studs Threshold)",
        ping_comp = "ชดเชยค่าปิงอัตโนมัติ (Ping Compensation)",
        curve_detect = "ระบบแก้ทาง Curve Ball (ป้องกันการหลอก)",
        jitter_delay = "ความหน่วงจำลองมนุษย์ (Legit Jitter ms)",

        -- Tab 2: Clash & Spam
        sec_clash = "ระบบดวลบอลระยะประชิด (Ball Clash & Spamming)",
        clash_card = "ออโต้สแปมเมื่อติด Clash (Clash Auto Spam)",
        clash_card_desc = "เมื่อลูกบอลเข้าสู่ระยะประชิดจะกดแพรี่รัวๆ อัตโนมัติ",
        clash_dist = "ระยะเริ่มสแปม Clash (Studs)",
        clash_rate = "ความเร็วในการสแปม (วินาที / ครั้ง)",

        -- Tab 3: Visuals & ESP
        sec_visuals = "การแสดงผลและตรวจจับลูกบอล (Visuals & Ball ESP)",
        range_ring_card = "วงแหวนระยะแพรี่ 3D (3D Parry Range Ring)",
        range_ring_desc = "แสดงวงแหวนนีออนรอบตัวตามระยะแพรี่ที่ตั้งไว้",
        tracer_card = "เส้นนำสายตาลูกบอล (Ball Tracer Line)",
        tracer_desc = "ลากเส้นชี้จากลูกบอลมายังเป้าหมาย (สีแดงเมื่อเล็งเรา)",
        highlight_card = "ไฮไลท์เรืองแสงลูกบอล (Ball Glow Highlight)",
        highlight_desc = "เน้นสีลูกบอลให้เห็นชัดเจนในระยะไกล",
        ball_hud_card = "ป้ายข้อมูลลูกบอล 3D (Ball Telemetry HUD)",
        ball_hud_desc = "แสดงความเร็วบอลและเวลาที่เหลือก่อนถึงตัวบนหัวลูกบอล",

        -- Tab 4: Defense & Skills
        sec_defense = "สกิลป้องกันและเคลื่อนที่ฉุกเฉิน (Emergency Defense)",
        auto_dash_card = "กดสกิลป้องกัน / แดชฉุกเฉิน",
        auto_dash_desc = "กดสกิลหลบหรือป้องกันอัตโนมัติเมื่อบอลเร็วจัดหรือเลี้ยวหักศอก",
        def_key = "ปุ่มสกิลป้องกัน (Defense Key)",
        def_time = "เวลาเหลือก่อนถึงตัวสำหรับเปิดสกิล (วินาที)",

        -- Tab 5: RPG Combat
        sec_rpg_farm = "โหมด Broken Blade RPG — ต่อสู้ & ฟาร์ม",
        enemy_card = "ฟาร์มมอนสเตอร์ RPG อัตโนมัติ",
        enemy_card_desc = "โจมตีและวาร์ปประกบมอนสเตอร์ตามตำแหน่งที่เลือก",
        select_enemy = "เลือกมอนสเตอร์เป้าหมาย",
        refresh_enemy = "🔄 รีเฟรชรายชื่อมอนสเตอร์",
        attack_pos = "ตำแหน่งการเข้าตี (Attack Position)",
        attack_dist = "ระยะห่างจากมอนสเตอร์ (Studs)",
        skills_card = "สกิลและอาวุธอัตโนมัติ (RPG Skills & Weapon)",
        skills_card_desc = "กดสกิลและถืออาวุธที่กำหนดระหว่างฟาร์ม",
        select_weapon = "เลือกอาวุธที่ถือ (Weapon Slot)",
        rpg_block_card = "บล็อกมอนสเตอร์อัตโนมัติ (RPG Monster Parry)",
        rpg_block_desc = "ตรวจจับท่าโจมตีของมอนสเตอร์ในระยะ 30 studs แล้วกดบล็อก",

        -- Tab 6: RPG Boss & Raids
        sec_rpg_boss = "โหมด Broken Blade RPG — บอส & เรด",
        eclipse_card = "อัญเชิญบอส Eclipse อัตโนมัติ",
        eclipse_card_desc = "วาร์ปคุย NPC อัญเชิญบอสเมื่อไม่มีบอสตัวอื่นอยู่ในแมพ",
        eclipse_diff = "ระดับความยาก Eclipse",
        raid_card = "ฟาร์มเรดอัตโนมัติ (Auto Raid)",
        raid_card_desc = "โจมตีมอนสเตอร์ในเรด หรือตี Dragon Altar อัตโนมัติ",
        select_raid = "เลือกเรดที่ต้องการเข้า",
        auto_join_raid = "เข้าเรด Broken Expanse อัตโนมัติ",
        quest_card = "ค้นหาเควสต์หีบอัตโนมัติ (Auto Quest)",
        quest_card_desc = "รับและสละเควสต์จนกว่าจะได้เควสต์หีบและจำนวนที่ต้องการ",

        -- Tab 7: Misc & Performance
        sec_misc = "ประสิทธิภาพ & ระบบเบ็ดเตล็ด (Performance & Misc)",
        cpu_card = "โหมดลดการทำงาน CPU (Reduce CPU Screen)",
        cpu_card_desc = "สร้างจอทึบสีดำหรือขาวเพื่อลดการเรนเดอร์กราฟิก",
        screen_color = "สีหน้าจอลดการทำงาน (Black / White)",
        rejoin_card = "ระบบป้องกันหลุดและรันอัตโนมัติ (Auto Rejoin & Execute)",
        rejoin_card_desc = "เชื่อมต่อกลับเซิร์ฟเวอร์และสั่งรันสคริปต์ซ้ำอัตโนมัติ",
        btn_panic = "🛑 ปิดการทำงานทุกอย่างทันที (Turn Off All)",

        -- Tab 8: Settings
        sec_settings = "การตั้งค่าระบบ & Discord Webhook",
        btn_toggle_lang = "🌐 สลับภาษา (Switch to English)",
        webhook_card = "การแจ้งเตือน Discord Webhook",
        webhook_card_desc = "ส่งการแจ้งเตือนเมื่อไอเทมดรอป หรือเมื่อตัวละครหลุด",
        webhook_url = "Discord Webhook URL",
        btn_test_webhook = "📡 ส่งข้อความทดสอบ Webhook",
        config_card = "ระบบจัดการโปรไฟล์การตั้งค่า (Config Manager)",
        config_name = "ชื่อโปรไฟล์ Config ใหม่",
        btn_save_config = "💾 บันทึกโปรไฟล์นี้",
        btn_load_config = "📂 โหลดโปรไฟล์ที่เลือก",
    },
    EN = {
        script_title = "PAYOMBØYZ — Master Blade Ball",
        tab_parry = "⚔️ Auto Parry & PvP",
        tab_clash = "⚡ Clash & Spam",
        tab_visuals = "👁️ Visuals & ESP",
        tab_defense = "🌀 Defense & Skills",
        tab_rpg_farm = "👹 RPG Combat & Farm",
        tab_rpg_boss = "🏰 RPG Boss & Raids",
        tab_misc = "⚡ Misc & FPS",
        tab_settings = "⚙️ Settings",

        -- Tab 1: Auto Parry
        sec_parry = "Advanced Auto Parry Suite",
        parry_card = "Enable Master Auto Parry",
        parry_card_desc = "Calculates velocity, trajectory, ping and curvature for 100% parry rate",
        parry_mode = "Parry Execution Mode",
        parry_dist = "Parry Trigger Threshold (Studs)",
        ping_comp = "Ping Compensation",
        curve_detect = "Curve Ball Prediction (Anti-Curve)",
        jitter_delay = "Human Reaction Jitter (ms)",

        -- Tab 2: Clash & Spam
        sec_clash = "Ball Clash & Auto Spamming Suite",
        clash_card = "Auto Spam in Close Clash",
        clash_card_desc = "Rapidly fires parries during high-speed close-range duels",
        clash_dist = "Clash Start Distance (Studs)",
        clash_rate = "Spam Interval (Seconds)",

        -- Tab 3: Visuals & ESP
        sec_visuals = "Ball Telemetry & Visual Indicators",
        range_ring_card = "3D Parry Range Ring Indicator",
        range_ring_desc = "Renders neon radius circle matching active parry distance",
        tracer_card = "Ball Tracer Vector Line",
        tracer_desc = "Draws dynamic beam connecting ball to target (Red when you)",
        highlight_card = "Ball Luminescent Highlight",
        highlight_desc = "Makes ball visible through obstacles with colored aura",
        ball_hud_card = "Ball Speed & Impact Telemetry HUD",
        ball_hud_desc = "Overhead 3D billboard with speed and time to impact",

        -- Tab 4: Defense & Skills
        sec_defense = "Emergency Defensive Abilities & Dash",
        auto_dash_card = "Auto Defensive Ability / Dash",
        auto_dash_desc = "Triggers defensive dash or block when ball is extreme speed or sharply curving",
        def_key = "Defense Key Bind",
        def_time = "Impact Threshold for Ability (Seconds)",

        -- Tab 5: RPG Combat
        sec_rpg_farm = "Broken Blade RPG — Combat & Farm",
        enemy_card = "Auto Farm Target Monsters",
        enemy_card_desc = "Snaps and attacks targeted RPG enemies",
        select_enemy = "Select Target Monster",
        refresh_enemy = "🔄 Refresh Monster List",
        attack_pos = "Attack Relative Position",
        attack_dist = "Target Offset Distance (Studs)",
        skills_card = "Auto Skills & Weapon Equip",
        skills_card_desc = "Cycles skills and equips weapon during combat",
        select_weapon = "Equipped Weapon Slot",
        rpg_block_card = "Auto Block RPG Monsters",
        rpg_block_desc = "Parries enemy animations within 30 studs",

        -- Tab 6: RPG Boss & Raids
        sec_rpg_boss = "Broken Blade RPG — Boss & Raids",
        eclipse_card = "Auto Summon Eclipse Boss",
        eclipse_card_desc = "Interacts with Eclipse NPC when arena is clear",
        eclipse_diff = "Eclipse Difficulty",
        raid_card = "Auto Raid Combat Suite",
        raid_card_desc = "Attacks raid enemies and Dragon Altars",
        select_raid = "Select Raid Difficulty",
        auto_join_raid = "Auto Join Broken Expanse Raid",
        quest_card = "Auto Find Target Chest Quest",
        quest_card_desc = "Cycles quests until matching chest appears",

        -- Tab 7: Misc & Performance
        sec_misc = "Performance & System Utilities",
        cpu_card = "Reduce CPU / FPS Saver Overlay",
        cpu_card_desc = "Overlays viewport with solid color to minimize GPU rendering",
        screen_color = "Screen Color (Black / White)",
        rejoin_card = "Auto Rejoin & Auto Execute",
        rejoin_card_desc = "Reconnects on disconnection and persists script on hop",
        btn_panic = "🛑 Emergency Stop All Actions",

        -- Tab 8: Settings
        sec_settings = "System Settings & Webhook",
        btn_toggle_lang = "🌐 Switch to Thai Language",
        webhook_card = "Discord Webhook Notification",
        webhook_card_desc = "Sends drop and disconnect alerts to Discord",
        webhook_url = "Discord Webhook URL",
        btn_test_webhook = "📡 Send Test Webhook Message",
        config_card = "Configuration Profiles Manager",
        config_name = "New Profile Name",
        btn_save_config = "💾 Save Profile",
        btn_load_config = "📂 Load Selected Profile",
    }
}

local function T(key)
    return (TRANSLATIONS[currentLang] and TRANSLATIONS[currentLang][key]) or (TRANSLATIONS.TH[key]) or key
end

local function notify(title, msg, dur)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = title,
            Text = msg,
            Duration = dur or 3
        })
    end)
end

-- ==============================================================================
-- ⚔️ PART 5: CORE BLADE BALL PARRY ENGINE (PARRY PATCH & BALL MATH)
-- ==============================================================================
local PF = nil
local _PARRY_PATCH = {
    keyTable = nil,
    transformFn = nil,
    netModule = nil,
    remoteId = nil,
    parryHash = nil,
    parryRemote = nil,
    ready = false,
}

task.spawn(function()
    pcall(function()
        local RS = game:GetService("ReplicatedStorage")
        local Controllers = RS:WaitForChild("Controllers", 10)
        if not Controllers then return end
        local SC = nil
        for _, child in ipairs(Controllers:GetChildren()) do
            if child.Name:sub(1, 16) == "SwordsController" then
                SC = child
                break
            end
        end
        if not SC then return end
        local PRY = SC:WaitForChild("PRY", 10)
        if not PRY then return end
        local Parry_Function = require(PRY)
        PF = Parry_Function

        local getupvals = debug.getupvalues or getupvalues
        if not getupvals then return end
        local ups = getupvals(Parry_Function)
        if not ups or #ups < 8 then return end

        _PARRY_PATCH.keyTable    = ups[3]
        _PARRY_PATCH.transformFn = ups[4]
        _PARRY_PATCH.netModule   = ups[6]
        _PARRY_PATCH.remoteId    = ups[7]
        _PARRY_PATCH.parryHash   = ups[8]

        pcall(function()
            _PARRY_PATCH.parryRemote = _PARRY_PATCH.netModule:RemoteEvent(_PARRY_PATCH.remoteId)
        end)
        _PARRY_PATCH.ready = true
    end)
end)

function _PARRY_PATCH.fire(curveCFrame, screenPositions, mouseLocation)
    curveCFrame = curveCFrame or workspace.CurrentCamera.CFrame
    screenPositions = screenPositions or { {0, 0, 0}, {0, 0, 0} }
    mouseLocation = mouseLocation or {0, 0}

    -- 1. Try Direct Game Module require (Cleanest legit invocation)
    if _G.Settings.Parry_Mode == "Legit (Keypress)" and PF then
        local ok = pcall(PF)
        if ok then return true end
    end

    -- 2. Try Protected Remote Firing with Rotating Hash & Transformed Token
    if _PARRY_PATCH.ready and _PARRY_PATCH.parryRemote and _G.Settings.Parry_Mode ~= "Legit (Keypress)" then
        local kt = _PARRY_PATCH.keyTable
        if kt then
            local keyIndex = kt[3]
            local currentKey = kt[1] and kt[1][keyIndex]
            if currentKey then
                local tok, transformed = pcall(_PARRY_PATCH.transformFn, currentKey, "TIME")
                if not tok or not transformed then
                    tok, transformed = pcall(_PARRY_PATCH.transformFn, currentKey)
                end
                if tok and transformed then
                    local serverTime = workspace:GetServerTimeNow() * 100
                    local timeStr = tostring(math.floor(serverTime))
                    local tc = {}
                    for i = 1, #timeStr do
                        local ki = (i - 1) % #transformed + 1
                        local kb = string.byte(transformed, ki)
                        local tb = (string.byte(timeStr, i) + i) % 256
                        tc[i] = string.char(bit32.bxor(tb, kb))
                    end
                    local token = table.concat(tc)
                    local fok = pcall(function()
                        _PARRY_PATCH.parryRemote:FireServer(
                            _PARRY_PATCH.parryHash,
                            currentKey,
                            token,
                            0.5,
                            curveCFrame,
                            screenPositions,
                            mouseLocation,
                            false
                        )
                    end)
                    if fok then return true end
                end
            end
        end
    end

    -- 3. Fallback: Virtual Input Key Press
    pcall(function()
        local bKey = Enum.KeyCode[_G.Settings.Parry_Key or "F"]
        VirtualInputManager:SendKeyEvent(true, bKey, false, game)
        VirtualInputManager:SendKeyEvent(false, bKey, false, game)
    end)
    return true
end

-- Active Balls Collector
local function getActiveBalls()
    local result = {}
    local ballsFolder = workspace:FindFirstChild("Balls")
    if ballsFolder then
        for _, b in ipairs(ballsFolder:GetChildren()) do
            if b:GetAttribute("realBall") or b:FindFirstChild("zoomies") then
                table.insert(result, b)
            end
        end
    end
    local trainingFolder = workspace:FindFirstChild("TrainingBalls")
    if trainingFolder then
        for _, b in ipairs(trainingFolder:GetChildren()) do
            table.insert(result, b)
        end
    end
    return result
end

-- Curvature and Trajectory Predictor
local _ballVelHistory = {}
local function isBallCurving(ball, velocity)
    if not _G.Settings.Curve_Detection then return false end
    if not _ballVelHistory[ball] then _ballVelHistory[ball] = {} end
    local hist = _ballVelHistory[ball]
    table.insert(hist, velocity)
    if #hist > 5 then table.remove(hist, 1) end
    if #hist >= 3 then
        local delta = (hist[#hist] - hist[1]).Magnitude
        local speed = velocity.Magnitude
        if speed > 0 and (delta / speed) > 0.45 then
            return true
        end
    end
    return false
end

-- ==============================================================================
-- 🎨 PART 6: BONUS VISUALS & TELEMETRY ENGINE
-- ==============================================================================
local rangeRingPart = nil
local ballTracerBeam = nil
local ballTracerAtt0 = nil
local ballTracerAtt1 = nil
local ballBillboard = nil

local function updateParryRangeVisual()
    if not _G.Settings.Parry_Range_Visual then
        if rangeRingPart then rangeRingPart:Destroy() rangeRingPart = nil end
        return
    end

    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    if not rangeRingPart or not rangeRingPart.Parent then
        rangeRingPart = Instance.new("Part")
        rangeRingPart.Name = "PBZ_RangeRing"
        rangeRingPart.Shape = Enum.PartType.Cylinder
        rangeRingPart.Material = Enum.Material.Neon
        rangeRingPart.Color = Color3.fromRGB(0, 210, 255)
        rangeRingPart.Transparency = 0.75
        rangeRingPart.Anchored = true
        rangeRingPart.CanCollide = false
        rangeRingPart.CanTouch = false
        rangeRingPart.CanQuery = false
        rangeRingPart.Parent = workspace
    end

    local r = (_G.Settings.Parry_Distance or 35) * 2
    rangeRingPart.Size = Vector3.new(0.4, r, r)
    rangeRingPart.CFrame = CFrame.new(hrp.Position - Vector3.new(0, 2.7, 0)) * CFrame.Angles(0, 0, math.rad(90))
end

local function updateBallVisuals(ball, isTargetMe, speed, reachTime)
    -- Ball Tracer Line
    if _G.Settings.Ball_Tracer and ball and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = LocalPlayer.Character.HumanoidRootPart
        if not ballTracerBeam or not ballTracerBeam.Parent then
            ballTracerAtt0 = Instance.new("Attachment")
            ballTracerAtt1 = Instance.new("Attachment", hrp)
            ballTracerBeam = Instance.new("Beam")
            ballTracerBeam.Attachment0 = ballTracerAtt0
            ballTracerBeam.Attachment1 = ballTracerAtt1
            ballTracerBeam.Width0 = 0.35
            ballTracerBeam.Width1 = 0.35
            ballTracerBeam.FaceCamera = true
            ballTracerBeam.Segments = 10
            ballTracerBeam.Parent = workspace
        end
        ballTracerAtt0.Parent = ball
        ballTracerBeam.Color = isTargetMe and ColorSequence.new(Color3.fromRGB(255, 45, 65)) or ColorSequence.new(Color3.fromRGB(45, 255, 120))
        ballTracerBeam.Transparency = NumberSequence.new(0.2)
        ballTracerBeam.Enabled = true
    elseif ballTracerBeam then
        ballTracerBeam.Enabled = false
    end

    -- Ball Glow Highlight
    if _G.Settings.Ball_Highlight and ball then
        local hl = ball:FindFirstChild("PBZ_BallHighlight")
        if not hl then
            hl = Instance.new("Highlight")
            hl.Name = "PBZ_BallHighlight"
            hl.FillTransparency = 0.5
            hl.OutlineTransparency = 0
            hl.Parent = ball
        end
        hl.FillColor = isTargetMe and Color3.fromRGB(255, 40, 60) or Color3.fromRGB(0, 200, 255)
        hl.OutlineColor = isTargetMe and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(0, 255, 150)
        hl.Enabled = true
    elseif ball and ball:FindFirstChild("PBZ_BallHighlight") then
        ball.PBZ_BallHighlight:Destroy()
    end

    -- Ball Overhead HUD
    if _G.Settings.Ball_HUD and ball then
        if not ballBillboard or not ballBillboard.Parent or ballBillboard.Adornee ~= ball then
            if ballBillboard then ballBillboard:Destroy() end
            ballBillboard = Instance.new("BillboardGui")
            ballBillboard.Name = "PBZ_BallHUD"
            ballBillboard.Size = UDim2.fromOffset(130, 42)
            ballBillboard.StudsOffset = Vector3.new(0, 3.5, 0)
            ballBillboard.AlwaysOnTop = true
            ballBillboard.Adornee = ball

            local lbl = Instance.new("TextLabel", ballBillboard)
            lbl.Name = "HUDLabel"
            lbl.Size = UDim2.fromScale(1, 1)
            lbl.BackgroundColor3 = Color3.fromRGB(15, 16, 20)
            lbl.BackgroundTransparency = 0.3
            lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
            lbl.TextSize = 10
            lbl.FontFace = Font.fromName("Montserrat", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
            local c = Instance.new("UICorner", lbl)
            c.CornerRadius = UDim.new(0, 6)
            local s = Instance.new("UIStroke", lbl)
            s.Color = Color3.fromRGB(220, 38, 58)
            s.Thickness = 1.2
            ballBillboard.Parent = ball
        end
        local lbl = ballBillboard:FindFirstChild("HUDLabel")
        if lbl then
            lbl.Text = string.format("SPEED: %d st/s\nIMPACT: %.2f s", math.floor(speed), math.max(reachTime, 0))
            lbl.TextColor3 = isTargetMe and Color3.fromRGB(255, 75, 90) or Color3.fromRGB(120, 230, 255)
        end
    elseif ballBillboard then
        ballBillboard:Destroy()
        ballBillboard = nil
    end
end

-- ==============================================================================
-- 🚀 PART 7: MAIN AUTO PARRY & EMERGENCY DEFENSE EXECUTION LOOPS
-- ==============================================================================
local lastParryTime = 0

bind(RunService.PostSimulation, function()
    if _G.PayomboyZBrokenBladeRun ~= RUN then return end

    updateParryRangeVisual()

    if not _G.Settings.Auto_Parry then return end

    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local balls = getActiveBalls()
    local myPos = hrp.Position

    local ping = 50
    pcall(function() ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue()) end)
    local pingSeconds = _G.Settings.Ping_Compensation and (ping / 1000) or 0

    for _, ball in ipairs(balls) do
        local ballPos = ball.Position
        local zoomies = ball:FindFirstChild("zoomies")
        local velocity = (zoomies and zoomies.VectorVelocity) or ball.AssemblyLinearVelocity or ball.Velocity or Vector3.zero
        local speed = velocity.Magnitude
        local distance = (myPos - ballPos).Magnitude

        -- Check ball target attribute or direction
        local ballTarget = ball:GetAttribute("target") or (ball:FindFirstChild("target") and ball.target.Value)
        local toPlayer = (myPos - ballPos).Unit
        local dot = (speed > 0) and velocity.Unit:Dot(toPlayer) or 0
        local isTargetMe = (ballTarget == LocalPlayer.Name) or (dot > 0.65)

        local reachTime = (speed > 0) and ((distance / speed) - pingSeconds) or 999
        local isCurving = isBallCurving(ball, velocity)

        updateBallVisuals(ball, isTargetMe, speed, reachTime)

        -- 1. Clash Auto Spam Mode
        if _G.Settings.Auto_Spam_Clash and distance <= (_G.Settings.Spam_Distance or 14) and isTargetMe then
            if tick() - lastParryTime >= (_G.Settings.Spam_Rate or 0.03) then
                lastParryTime = tick()
                _PARRY_PATCH.fire()
            end
            break
        end

        -- 2. Bonus Feature 2: Auto Emergency Defensive Ability (Dash / Deflect)
        if _G.Settings.Auto_Defensive_Skill and isTargetMe and (reachTime <= (_G.Settings.Emergency_Threshold or 0.12) or speed > 350) then
            pcall(function()
                local dKey = Enum.KeyCode[_G.Settings.Defensive_Key or "Q"]
                VirtualInputManager:SendKeyEvent(true, dKey, false, game)
                VirtualInputManager:SendKeyEvent(false, dKey, false, game)
            end)
        end

        -- 3. Core Auto Parry Timing
        local threshold = _G.Settings.Parry_Distance or 35
        local speedCompensation = math.min(speed / 100, 25)
        local triggerDistance = threshold + speedCompensation

        if isTargetMe and distance <= triggerDistance then
            -- Delay if ball is currently curving away
            if isCurving and dot < 0.85 and distance > 18 then
                continue
            end

            if tick() - lastParryTime >= 0.15 then
                lastParryTime = tick()

                if _G.Settings.Parry_Mode == "Legit (Keypress)" and _G.Settings.Reaction_Jitter > 0 then
                    local jitter = _G.Settings.Reaction_Jitter * (0.8 + math.random() * 0.4)
                    task.delay(jitter, function()
                        _PARRY_PATCH.fire()
                    end)
                else
                    _PARRY_PATCH.fire()
                end
                break
            end
        end
    end
end)

-- ==============================================================================
-- 👹 PART 8: BROKEN BLADE RPG AUTOMATION LOOPS (WITH R15 BUG FIXES)
-- ==============================================================================
local function clickScreen()
    pcall(function()
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
    end)
end

local function stringToCFrame(p16)
    return CFrame.new(unpack(HttpService:JSONDecode("[" .. p16 .. "]")))
end

local function monsterChecker(p17)
    if workspace:FindFirstChild("EnemyService") then
        for _, m in pairs(workspace.EnemyService:GetChildren()) do
            if m.Name == p17 and m:FindFirstChild("Humanoid") and m.Humanoid.Health > 0.98 then
                return true
            end
        end
    end
    return false
end

-- Auto Farm Worker
local function doAutoFarm()
    if not _G.Settings.Auto_Farm then return false end
    local monsterTarget = _G.Settings.Select_Enemy
    if monsterTarget == "Multi Select" then
        local checkList = {
            _G.Settings.One_Select, _G.Settings.Two_Select, _G.Settings.Three_Select,
            _G.Settings.Four_Select, _G.Settings.Five_Select, _G.Settings.Six_Select,
            _G.Settings.Seven_Select, _G.Settings.Eight_Select, _G.Settings.Nine_Select,
            _G.Settings.Ten_Select, _G.Settings.Eleven_Select, _G.Settings.Twelve_Select
        }
        for _, name in ipairs(checkList) do
            if name ~= "" and monsterChecker(name) then
                monsterTarget = name
                break
            end
        end
    end

    if workspace:FindFirstChild("EnemyService") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        for _, enemy in pairs(workspace.EnemyService:GetChildren()) do
            if enemy:IsA("Model") and enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0.98 and (monsterTarget == "Multi Select" or enemy.Name == monsterTarget) then
                local hrp = enemy:FindFirstChild("HumanoidRootPart") or enemy.PrimaryPart
                if hrp then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = hrp.CFrame * ModeFarm2
                    return true
                end
            end
        end
    end
    return false
end

-- Eclipse Worker
local function doAutoSummonEclipse()
    if not _G.Settings.Auto_Summon_Eclipse then return false end
    pcall(function()
        local homePage = LocalPlayer.PlayerGui.Main.HomePage
        if homePage:FindFirstChild("EclipseConfirm") then
            homePage.EclipseConfirm.Outline.Button.Enter.Size = UDim2.new(33.3, 0, 33, 0)
        end
    end)

    local hasBoss = false
    if workspace:FindFirstChild("EnemyService") then
        hasBoss = workspace.EnemyService:FindFirstChild("[Nightmare] Mad Dog")
            or workspace.EnemyService:FindFirstChild("[Lv.3000] Black Swordsman")
            or workspace.EnemyService:FindFirstChild("[Lv.15000] Struggler")
    end

    if not hasBoss and workspace:FindFirstChild("World") and workspace.World:FindFirstChild("NPC") and workspace.World.NPC:FindFirstChild("Other") then
        local npcId = "240605"
        if _G.Settings.Selected_Difficult_Eclipse == "Hard" then npcId = "240606"
        elseif _G.Settings.Selected_Difficult_Eclipse == "Nightmare" then npcId = "240607" end

        local npc = workspace.World.NPC.Other:FindFirstChild(npcId)
        if npc and npc:FindFirstChild("Talk") and npc.Talk:FindFirstChild("ProximityPrompt") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = stringToCFrame(tostring(npc.WorldPivot))
            task.wait(0.3)
            fireproximityprompt(npc.Talk.ProximityPrompt)
            return true
        end
    end
    return false
end

-- Raid Worker
local function checkDragonAltar()
    for _, obj in pairs(workspace:GetChildren()) do
        if string.find(obj.Name, "DragonAltars") then
            for _, altar in pairs(obj:GetChildren()) do
                if string.find(altar.Name, "Dragon") then return altar end
            end
        end
    end
    return nil
end

local function doAutoRaid()
    if not (_G.Settings.Auto_Raid and raidworld) then return false end
    if dragonworld then
        local altar = checkDragonAltar()
        if altar and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = altar.CFrame
            return true
        end
    end

    if workspace:FindFirstChild("EnemyService") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        for _, enemy in pairs(workspace.EnemyService:GetChildren()) do
            if enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0.98 and enemy:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.CFrame = enemy.HumanoidRootPart.CFrame * ModeFarm2
                return true
            end
        end
    end
    return false
end

-- Priority Loop
task.spawn(function()
    while _G.PayomboyZBrokenBladeRun == RUN do
        task.wait(0.05)
        pcall(function()
            local pList = {
                _G.Settings.One_Priority, _G.Settings.Two_Priority, _G.Settings.Three_Priority,
                _G.Settings.Four_Priority, _G.Settings.Five_Priority, _G.Settings.Six_Priority,
                _G.Settings.Seven_Priority
            }
            for _, p in ipairs(pList) do
                if p == "Farm" and doAutoFarm() then break
                elseif p == "Raid" and doAutoRaid() then break
                elseif p == "Eclipse" and doAutoSummonEclipse() then
                    task.wait(1) clickScreen() task.wait(2) break
                end
            end
        end)
    end
end)

-- RPG Skills Loop
task.spawn(function()
    while _G.PayomboyZBrokenBladeRun == RUN do
        task.wait(0.25)
        pcall(function()
            if _G.Settings.Auto_Skill and LocalPlayer.PlayerGui:FindFirstChild("Main") then
                local skillsUI = LocalPlayer.PlayerGui.Main.HomePage.Bottom.Skills
                for _, key in ipairs(_G.Settings.Select_Skill) do
                    local tName = "Template" .. key
                    if skillsUI:FindFirstChild(tName) and not skillsUI[tName].Countdown.Visible then
                        local kc = Enum.KeyCode[key]
                        if kc then
                            VirtualInputManager:SendKeyEvent(true, kc, false, game)
                            VirtualInputManager:SendKeyEvent(false, kc, false, game)
                        end
                    end
                end
            end
        end)
    end
end)

-- RPG Monster Parry Loop (Fixed R6/R15 and Attribute binding)
task.spawn(function()
    while _G.PayomboyZBrokenBladeRun == RUN do
        task.wait(0.12)
        pcall(function()
            if _G.Settings.Auto_Block_RPG and workspace:FindFirstChild("EnemyService") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local myPos = LocalPlayer.Character.HumanoidRootPart.Position
                for _, enemy in pairs(workspace.EnemyService:GetChildren()) do
                    if enemy:IsA("Model") and enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0.98 and enemy:FindFirstChild("HumanoidRootPart") then
                        if (enemy.HumanoidRootPart.Position - myPos).Magnitude < 30 and not enemy:GetAttribute("PBZ_ParryBound") then
                            enemy.Humanoid.AnimationPlayed:Connect(function(animTrack)
                                if _G.Settings.Auto_Block_RPG and (enemy.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude < 30 then
                                    task.wait(_G.Settings.Block_Delay_RPG)
                                    local bKey = Enum.KeyCode[_G.Settings.Block_Button_RPG or "F"]
                                    if bKey then
                                        VirtualInputManager:SendKeyEvent(true, bKey, false, game)
                                        VirtualInputManager:SendKeyEvent(false, bKey, false, game)
                                    end
                                end
                            end)
                            enemy:SetAttribute("PBZ_ParryBound", true)
                        end
                    end
                end
            end
        end)
    end
end)

-- RPG Weapon Equip Loop (Conditional, does not spam unless farming)
task.spawn(function()
    while _G.PayomboyZBrokenBladeRun == RUN do
        task.wait(3.0)
        pcall(function()
            if _G.Settings.Auto_Farm and isBrokenBlade then
                local k = _G.Settings.Select_Weapon == "2" and Enum.KeyCode.Two or (_G.Settings.Select_Weapon == "3" and Enum.KeyCode.Three or Enum.KeyCode.One)
                VirtualInputManager:SendKeyEvent(true, k, false, game)
                VirtualInputManager:SendKeyEvent(false, k, false, game)
            end
        end)
    end
end)

-- Anti-Gravity BodyVelocity Guard (Broken Blade Farm Only)
task.spawn(function()
    while _G.PayomboyZBrokenBladeRun == RUN do
        task.wait(0.2)
        pcall(function()
            if _G.Settings.Auto_Farm and isBrokenBlade and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = LocalPlayer.Character.HumanoidRootPart
                if not hrp:FindFirstChild("PBZ_Velocity") then
                    local bv = Instance.new("BodyVelocity")
                    bv.Name = "PBZ_Velocity"
                    bv.MaxForce = Vector3.new(100000, 100000, 100000)
                    bv.Velocity = Vector3.new(0, 0, 0)
                    bv.Parent = hrp
                end
            else
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    local bv = LocalPlayer.Character.HumanoidRootPart:FindFirstChild("PBZ_Velocity")
                    if bv then bv:Destroy() end
                end
            end
        end)
    end
end)

-- Auto Rejoin
pcall(function()
    GuiService.ErrorMessageChanged:Connect(function()
        if _G.Settings.Auto_Rejoin then
            task.wait(2)
            TeleportService:Teleport(game.PlaceId)
        end
    end)
end)

-- ==============================================================================
-- 🏛️ PART 9: INLINED PAYOMBOYZ UI ENGINE (OBSIDIAN GLASSMORPHIC 2.0)
-- ==============================================================================
local function loadPayomboyUIEngine()
    getgenv().configs = { ["temp"] = false }

    local library = {}
    local init = {}
    local PRIMARY_COLOR = Color3.fromRGB(220, 38, 58)

    function init.generateUUID()
        local template = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
        return string.gsub(template, '[xy]', function (c)
            local v = (c == 'x') and math.random(0, 0xf) or math.random(8, 0xb)
            return string.format('%x', v)
        end)
    end

    function init.reload()
        pcall(function()
            local parents = { CoreGui, LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui") }
            if gethui then pcall(function() table.insert(parents, gethui()) end) end
            for _, p in ipairs(parents) do
                if p then
                    for _, v in ipairs(p:GetChildren()) do
                        if v:IsA("ScreenGui") and (v:GetAttribute("enabled") or v:GetAttribute("protected") or v.Name:find("Payomboy") or v.Name:find("PayomboyZ")) then
                            pcall(function() v:Destroy() end)
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
            if not p then pcall(function() p = CoreGui end) end
            if not p then pcall(function() p = LocalPlayer and LocalPlayer:WaitForChild("PlayerGui", 5) end) end
            args.Parent = p or CoreGui
        end)
        args.Name = init.generateUUID()
        args.DisplayOrder = 999
        args.IgnoreGuiInset = true
        args.ResetOnSpawn = false
        args:SetAttribute("protected", tostring(init.generateUUID()))
        args:SetAttribute("enabled", true)
    end

    function init.tween(object, waits, Style, ...)
        TweenService:Create(object, TweenInfo.new(waits, Style), ...):Play()
    end

    function init.stroke(object, transparency, thickness, color)
        local s = Instance.new("UIStroke", object)
        s.Thickness = thickness
        s.LineJoinMode = Enum.LineJoinMode.Round
        s.Color = color
        s.Transparency = transparency
        s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        return s
    end

    function init.create_corner(radius, object)
        local corner = Instance.new("UICorner", object)
        corner.CornerRadius = UDim.new(0, radius)
        return corner
    end

    function init.device()
        return UserInputService:GetPlatform() == Enum.Platform.Windows
    end

    function library.create()
        init.reload()

        local rootGui = Instance.new("ScreenGui")
        init.protected(rootGui)

        local main = Instance.new("Frame", rootGui)
        main.AnchorPoint = Vector2.new(0.5, 0.5)
        main.BackgroundColor3 = Color3.fromRGB(18, 19, 24)
        main.BackgroundTransparency = 0
        main.Position = UDim2.new(0.5, 0, 0.5, 0)
        main.Name = "@main"
        main.Active = true

        local viewport = Camera and Camera.ViewportSize or Vector2.new(1280, 720)
        local initialSize = init.device() and Vector2.new(710, 510) or Vector2.new(620, 420)
        initialSize = Vector2.new(math.min(initialSize.X, viewport.X - 20), math.min(initialSize.Y, viewport.Y - 20))
        main.Size = UDim2.fromOffset(initialSize.X, initialSize.Y)
        init.tween(main, 0.25, Enum.EasingStyle.Back, { Size = UDim2.fromOffset(initialSize.X, initialSize.Y) })
        init.create_corner(10, main)
        main.ClipsDescendants = true

        -- Background Artwork
        local bgImageLabel = Instance.new("ImageLabel", main)
        bgImageLabel.Name = "MangaArtBackground"
        bgImageLabel.Size = UDim2.fromScale(1, 1)
        bgImageLabel.Position = UDim2.fromScale(0, 0)
        bgImageLabel.BackgroundTransparency = 1
        bgImageLabel.ScaleType = Enum.ScaleType.Crop
        bgImageLabel.ImageTransparency = 0.08
        bgImageLabel.ZIndex = 1
        init.create_corner(10, bgImageLabel)

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
            local BgRawURL = "https://raw.githubusercontent.com/payomboyz333/Library/main/Image%20Sep%2028.png"
            local BgFileName = "Image Sep 28.png"
            local getAsset = (typeof(getcustomasset) == "function" and getcustomasset)
                          or (typeof(getsynasset) == "function" and getsynasset)
            local loadedAsset = nil
            if isfile and getAsset and isfile(BgFileName) then
                local ok, asset = pcall(getAsset, BgFileName)
                if ok and asset then loadedAsset = asset end
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

        -- Top Tab Bar
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
        brandTitle.Size = UDim2.new(0, 105, 1, 0)
        brandTitle.FontFace = Font.fromName("Montserrat", Enum.FontWeight.Heavy, Enum.FontStyle.Normal)
        brandTitle.Text = "PAYOMBØYZ"
        brandTitle.TextColor3 = PRIMARY_COLOR
        brandTitle.TextSize = 13
        brandTitle.TextXAlignment = Enum.TextXAlignment.Left

        local brandDivider = Instance.new("Frame", topTabBar)
        brandDivider.Name = "BrandDivider"
        brandDivider.BackgroundColor3 = Color3.fromRGB(48, 50, 58)
        brandDivider.BorderSizePixel = 0
        brandDivider.Position = UDim2.new(0, 110, 0.5, -8)
        brandDivider.Size = UDim2.new(0, 1, 0, 16)

        local tabScroll = Instance.new("ScrollingFrame", topTabBar)
        tabScroll.Name = "TabScroll"
        tabScroll.BackgroundTransparency = 1
        tabScroll.Position = UDim2.new(0, 120, 0, 0)
        tabScroll.Size = UDim2.new(1, -180, 1, 0)
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

        local prevBtn = Instance.new("TextButton", navArrows)
        prevBtn.Size = UDim2.new(0, 24, 0, 22)
        prevBtn.Position = UDim2.new(0, 0, 0, 1)
        prevBtn.BackgroundColor3 = Color3.fromRGB(28, 30, 36)
        prevBtn.Text = "◀"
        prevBtn.TextColor3 = Color3.fromRGB(200, 202, 212)
        prevBtn.TextSize = 9
        init.create_corner(4, prevBtn)
        init.stroke(prevBtn, 0.6, 1, Color3.fromRGB(52, 54, 62))

        local nextBtn = Instance.new("TextButton", navArrows)
        nextBtn.Size = UDim2.new(0, 24, 0, 22)
        nextBtn.Position = UDim2.new(0, 28, 0, 1)
        nextBtn.BackgroundColor3 = Color3.fromRGB(28, 30, 36)
        nextBtn.Text = "▶"
        nextBtn.TextColor3 = Color3.fromRGB(200, 202, 212)
        nextBtn.TextSize = 9
        init.create_corner(4, nextBtn)
        init.stroke(nextBtn, 0.6, 1, Color3.fromRGB(52, 54, 62))

        local bodyArea = Instance.new("Frame", main)
        bodyArea.Name = "@bodyArea"
        bodyArea.BackgroundTransparency = 1
        bodyArea.Position = UDim2.new(0, 14, 0, 46)
        bodyArea.Size = UDim2.new(1, -28, 1, -54)
        bodyArea.ZIndex = 5

        local pagesFolder = Instance.new("Folder", bodyArea)
        pagesFolder.Name = "Pages"

        local uipage = Instance.new("UIPageLayout", pagesFolder)
        uipage.FillDirection = Enum.FillDirection.Horizontal
        uipage.SortOrder = Enum.SortOrder.LayoutOrder
        uipage.EasingStyle = Enum.EasingStyle.Quad
        uipage.EasingDirection = Enum.EasingDirection.Out
        uipage.TweenTime = 0.25

        prevBtn.MouseButton1Click:Connect(function() uipage:Previous() end)
        nextBtn.MouseButton1Click:Connect(function() uipage:Next() end)

        -- Details Drawer
        local drawerFrame = Instance.new("Frame", main)
        drawerFrame.Name = "DetailsDrawer"
        drawerFrame.Size = UDim2.new(0, 310, 1, -46)
        drawerFrame.Position = UDim2.new(1, 320, 0, 46)
        drawerFrame.BackgroundColor3 = Color3.fromRGB(24, 25, 30)
        drawerFrame.BorderSizePixel = 0
        drawerFrame.ZIndex = 60
        init.create_corner(8, drawerFrame)
        init.stroke(drawerFrame, 0.4, 1.2, Color3.fromRGB(55, 56, 64))

        local drawerTitle = Instance.new("TextLabel", drawerFrame)
        drawerTitle.Size = UDim2.new(1, -40, 0, 32)
        drawerTitle.Position = UDim2.new(0, 14, 0, 6)
        drawerTitle.BackgroundTransparency = 1
        drawerTitle.Text = "FEATURE SETTINGS"
        drawerTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
        drawerTitle.TextSize = 11
        drawerTitle.FontFace = Font.fromName("Montserrat", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
        drawerTitle.TextXAlignment = Enum.TextXAlignment.Left
        drawerTitle.ZIndex = 61

        local drawerClose = Instance.new("TextButton", drawerFrame)
        drawerClose.Size = UDim2.fromOffset(24, 24)
        drawerClose.Position = UDim2.new(1, -32, 0, 10)
        drawerClose.BackgroundColor3 = Color3.fromRGB(36, 38, 46)
        drawerClose.Text = "✕"
        drawerClose.TextColor3 = Color3.fromRGB(220, 222, 230)
        drawerClose.TextSize = 10
        drawerClose.ZIndex = 61
        init.create_corner(4, drawerClose)

        local drawerScroll = Instance.new("ScrollingFrame", drawerFrame)
        drawerScroll.Size = UDim2.new(1, -20, 1, -50)
        drawerScroll.Position = UDim2.new(0, 10, 0, 44)
        drawerScroll.BackgroundTransparency = 1
        drawerScroll.ScrollBarThickness = 2
        drawerScroll.ScrollBarImageColor3 = PRIMARY_COLOR
        drawerScroll.ZIndex = 61

        local dLayout = Instance.new("UIListLayout", drawerScroll)
        dLayout.Padding = UDim.new(0, 8)
        dLayout.SortOrder = Enum.SortOrder.LayoutOrder

        local function closeDrawer()
            init.tween(drawerFrame, 0.25, Enum.EasingStyle.Quad, { Position = UDim2.new(1, 320, 0, 46) })
            init.tween(bodyArea, 0.25, Enum.EasingStyle.Quad, { Size = UDim2.new(1, -28, 1, -54) })
        end
        drawerClose.MouseButton1Click:Connect(closeDrawer)

        local function openDrawerForCard(cardTitle, cardInstance)
            drawerTitle.Text = string.upper(cardTitle)
            for _, ch in ipairs(drawerScroll:GetChildren()) do
                if ch:IsA("GuiObject") then
                    ch.Visible = (ch:GetAttribute("CardOwner") == cardInstance)
                end
            end
            init.tween(bodyArea, 0.25, Enum.EasingStyle.Quad, { Size = UDim2.new(1, -335, 1, -54) })
            init.tween(drawerFrame, 0.25, Enum.EasingStyle.Quad, { Position = UDim2.new(1, -315, 0, 46) })
        end

        local tabs = {}
        local tabPills = {}
        local tabIndex = 0

        local function updateTabStyles(activeIdx)
            for i, p in ipairs(tabPills) do
                local isActive = (i == activeIdx)
                p.btn.BackgroundColor3 = isActive and Color3.fromRGB(42, 43, 48) or Color3.fromRGB(26, 28, 34)
                p.btn.TextColor3 = isActive and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(155, 156, 166)
                p.stroke.Color = isActive and PRIMARY_COLOR or Color3.fromRGB(52, 54, 62)
                p.stroke.Transparency = isActive and 0 or 0.6
            end
        end

        uipage:GetPropertyChangedSignal("CurrentPage"):Connect(function()
            if uipage.CurrentPage then
                local idx = uipage.CurrentPage:GetAttribute("PageIndex") or 1
                updateTabStyles(idx)
            end
        end)

        function tabs.create(tabTitle)
            tabIndex = tabIndex + 1
            local curIndex = tabIndex

            local pillBtn = Instance.new("TextButton", tabScroll)
            pillBtn.Name = "Pill_" .. tostring(curIndex)
            pillBtn.BackgroundColor3 = (curIndex == 1) and Color3.fromRGB(42, 43, 48) or Color3.fromRGB(26, 28, 34)
            pillBtn.Text = tabTitle or ("Tab " .. tostring(curIndex))
            pillBtn.TextColor3 = (curIndex == 1) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(155, 156, 166)
            pillBtn.TextSize = 10
            pillBtn.FontFace = Font.fromName("Montserrat", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
            pillBtn.Size = UDim2.new(0, 0, 0, 24)
            pillBtn.AutomaticSize = Enum.AutomaticSize.X
            pillBtn.ZIndex = 51
            init.create_corner(6, pillBtn)

            local pPad = Instance.new("UIPadding", pillBtn)
            pPad.PaddingLeft = UDim.new(0, 10)
            pPad.PaddingRight = UDim.new(0, 10)

            local pStroke = init.stroke(pillBtn, (curIndex == 1) and 0 or 0.6, 1, (curIndex == 1) and PRIMARY_COLOR or Color3.fromRGB(52, 54, 62))
            table.insert(tabPills, { btn = pillBtn, stroke = pStroke })

            local pageFrame = Instance.new("Frame", pagesFolder)
            pageFrame.Name = "Page_" .. tostring(curIndex)
            pageFrame.Size = UDim2.fromScale(1, 1)
            pageFrame.BackgroundTransparency = 1
            pageFrame.LayoutOrder = curIndex
            pageFrame:SetAttribute("PageIndex", curIndex)

            local scroll = Instance.new("ScrollingFrame", pageFrame)
            scroll.Size = UDim2.fromScale(1, 1)
            scroll.BackgroundTransparency = 1
            scroll.ScrollBarThickness = 3
            scroll.ScrollBarImageColor3 = PRIMARY_COLOR
            scroll.ZIndex = 6

            local container = Instance.new("Frame", scroll)
            container.Size = UDim2.new(1, -12, 0, 0)
            container.AutomaticSize = Enum.AutomaticSize.Y
            container.BackgroundTransparency = 1

            local cLayout = Instance.new("UIListLayout", container)
            cLayout.Padding = UDim.new(0, 8)
            cLayout.SortOrder = Enum.SortOrder.LayoutOrder

            pillBtn.MouseButton1Click:Connect(function()
                uipage:JumpToIndex(curIndex - 1)
                updateTabStyles(curIndex)
            end)

            local tabOps = {}

            function tabOps.Header(cfg)
                local h = Instance.new("TextLabel", container)
                h.Size = UDim2.new(1, 0, 0, 22)
                h.BackgroundTransparency = 1
                h.Text = cfg.Title or "Section"
                h.TextColor3 = Color3.fromRGB(255, 255, 255)
                h.TextSize = 12
                h.FontFace = Font.fromName("Montserrat", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
                h.TextXAlignment = Enum.TextXAlignment.Left
                h.ZIndex = 7
                return h
            end

            function tabOps.Toggle(cfg)
                local card = Instance.new("Frame", container)
                card.Size = UDim2.new(1, 0, 0, 52)
                card.BackgroundColor3 = Color3.fromRGB(42, 43, 48)
                card.ZIndex = 7
                init.create_corner(8, card)
                init.stroke(card, 0.4, 1, Color3.fromRGB(66, 67, 74))

                local title = Instance.new("TextLabel", card)
                title.Size = UDim2.new(1, -80, 0, 20)
                title.Position = UDim2.new(0, 14, 0, 7)
                title.BackgroundTransparency = 1
                title.Text = cfg.Title or "Toggle"
                title.TextColor3 = Color3.fromRGB(255, 255, 255)
                title.TextSize = 11
                title.FontFace = Font.fromName("Montserrat", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
                title.TextXAlignment = Enum.TextXAlignment.Left
                title.ZIndex = 8

                local info = Instance.new("TextLabel", card)
                info.Size = UDim2.new(1, -80, 0, 16)
                info.Position = UDim2.new(0, 14, 0, 27)
                info.BackgroundTransparency = 1
                info.Text = cfg.Info or ""
                info.TextColor3 = Color3.fromRGB(155, 156, 166)
                info.TextSize = 9
                info.FontFace = Font.fromName("Montserrat", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
                info.TextXAlignment = Enum.TextXAlignment.Left
                info.ZIndex = 8

                local swFrame = Instance.new("Frame", card)
                swFrame.Size = UDim2.fromOffset(38, 20)
                swFrame.Position = UDim2.new(1, -52, 0.5, -10)
                swFrame.BackgroundColor3 = cfg.Default and PRIMARY_COLOR or Color3.fromRGB(28, 30, 36)
                swFrame.ZIndex = 8
                init.create_corner(10, swFrame)

                local swDot = Instance.new("Frame", swFrame)
                swDot.Size = UDim2.fromOffset(14, 14)
                swDot.Position = cfg.Default and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
                swDot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                swDot.ZIndex = 9
                init.create_corner(10, swDot)

                local isChecked = cfg.Default or false
                local function setCheck(v)
                    isChecked = v
                    init.tween(swFrame, 0.18, Enum.EasingStyle.Quad, { BackgroundColor3 = isChecked and PRIMARY_COLOR or Color3.fromRGB(28, 30, 36) })
                    init.tween(swDot, 0.18, Enum.EasingStyle.Quad, { Position = isChecked and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7) })
                    if cfg.Callback then pcall(cfg.Callback, isChecked) end
                end

                local cardBtn = Instance.new("TextButton", card)
                cardBtn.Size = UDim2.fromScale(1, 1)
                cardBtn.BackgroundTransparency = 1
                cardBtn.Text = ""
                cardBtn.ZIndex = 10

                cardBtn.MouseButton1Click:Connect(function()
                    setCheck(not isChecked)
                    openDrawerForCard(cfg.Title or "Controls", card)
                end)

                local cardHandle = {}

                function cardHandle:Slider(sCfg)
                    local sFrame = Instance.new("Frame", drawerScroll)
                    sFrame.Size = UDim2.new(1, 0, 0, 48)
                    sFrame.BackgroundColor3 = Color3.fromRGB(34, 35, 42)
                    sFrame.ZIndex = 62
                    sFrame:SetAttribute("CardOwner", card)
                    init.create_corner(6, sFrame)

                    local sTitle = Instance.new("TextLabel", sFrame)
                    sTitle.Size = UDim2.new(0.7, 0, 0, 16)
                    sTitle.Position = UDim2.new(0, 10, 0, 5)
                    sTitle.BackgroundTransparency = 1
                    sTitle.Text = sCfg.Title or "Slider"
                    sTitle.TextColor3 = Color3.fromRGB(220, 222, 230)
                    sTitle.TextSize = 10
                    sTitle.FontFace = Font.fromName("Montserrat", Enum.FontWeight.Medium, Enum.FontStyle.Normal)
                    sTitle.TextXAlignment = Enum.TextXAlignment.Left
                    sTitle.ZIndex = 63

                    local sVal = Instance.new("TextLabel", sFrame)
                    sVal.Size = UDim2.new(0.25, 0, 0, 16)
                    sVal.Position = UDim2.new(0.72, 0, 0, 5)
                    sVal.BackgroundTransparency = 1
                    sVal.Text = tostring(sCfg.Default or sCfg.Min or 0)
                    sVal.TextColor3 = PRIMARY_COLOR
                    sVal.TextSize = 10
                    sVal.FontFace = Font.fromName("Montserrat", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
                    sVal.TextXAlignment = Enum.TextXAlignment.Right
                    sVal.ZIndex = 63

                    local barBg = Instance.new("Frame", sFrame)
                    barBg.Size = UDim2.new(1, -20, 0, 6)
                    barBg.Position = UDim2.new(0, 10, 0, 28)
                    barBg.BackgroundColor3 = Color3.fromRGB(20, 21, 25)
                    barBg.ZIndex = 63
                    init.create_corner(3, barBg)

                    local fill = Instance.new("Frame", barBg)
                    local pct = math.clamp(((sCfg.Default or sCfg.Min) - sCfg.Min) / (sCfg.Max - sCfg.Min), 0, 1)
                    fill.Size = UDim2.new(pct, 0, 1, 0)
                    fill.BackgroundColor3 = PRIMARY_COLOR
                    fill.ZIndex = 64
                    init.create_corner(3, fill)

                    local sBtn = Instance.new("TextButton", barBg)
                    sBtn.Size = UDim2.fromScale(1, 1)
                    sBtn.BackgroundTransparency = 1
                    sBtn.Text = ""
                    sBtn.ZIndex = 65

                    local sliding = false
                    sBtn.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                            sliding = true
                        end
                    end)
                    UserInputService.InputEnded:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                            sliding = false
                        end
                    end)
                    UserInputService.InputChanged:Connect(function(input)
                        if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                            local relX = math.clamp((input.Position.X - barBg.AbsolutePosition.X) / barBg.AbsoluteSize.X, 0, 1)
                            fill.Size = UDim2.new(relX, 0, 1, 0)
                            local raw = sCfg.Min + (sCfg.Max - sCfg.Min) * relX
                            local val = sCfg.Round and (math.floor(raw / sCfg.Round + 0.5) * sCfg.Round) or math.floor(raw)
                            sVal.Text = tostring(val)
                            if sCfg.Callback then pcall(sCfg.Callback, val) end
                        end
                    end)
                end

                function cardHandle:Dropdown(dCfg)
                    local dFrame = Instance.new("Frame", drawerScroll)
                    dFrame.Size = UDim2.new(1, 0, 0, 48)
                    dFrame.BackgroundColor3 = Color3.fromRGB(34, 35, 42)
                    dFrame.ZIndex = 62
                    dFrame:SetAttribute("CardOwner", card)
                    init.create_corner(6, dFrame)

                    local dTitle = Instance.new("TextLabel", dFrame)
                    dTitle.Size = UDim2.new(1, -20, 0, 16)
                    dTitle.Position = UDim2.new(0, 10, 0, 5)
                    dTitle.BackgroundTransparency = 1
                    dTitle.Text = dCfg.Title or "Dropdown"
                    dTitle.TextColor3 = Color3.fromRGB(220, 222, 230)
                    dTitle.TextSize = 10
                    dTitle.FontFace = Font.fromName("Montserrat", Enum.FontWeight.Medium, Enum.FontStyle.Normal)
                    dTitle.TextXAlignment = Enum.TextXAlignment.Left
                    dTitle.ZIndex = 63

                    local dBtn = Instance.new("TextButton", dFrame)
                    dBtn.Size = UDim2.new(1, -20, 0, 20)
                    dBtn.Position = UDim2.new(0, 10, 0, 22)
                    dBtn.BackgroundColor3 = Color3.fromRGB(24, 25, 30)
                    dBtn.Text = tostring(dCfg.Value or (dCfg.Values and dCfg.Values[1]) or "")
                    dBtn.TextColor3 = Color3.fromRGB(200, 202, 212)
                    dBtn.TextSize = 9
                    dBtn.ZIndex = 63
                    init.create_corner(4, dBtn)

                    local curIdx = 1
                    local vals = dCfg.Values or {}
                    for i, v in ipairs(vals) do
                        if v == dCfg.Value then curIdx = i break end
                    end

                    dBtn.MouseButton1Click:Connect(function()
                        if #vals > 0 then
                            curIdx = curIdx + 1
                            if curIdx > #vals then curIdx = 1 end
                            dBtn.Text = tostring(vals[curIdx])
                            if dCfg.Callback then pcall(dCfg.Callback, vals[curIdx]) end
                        end
                    end)
                end

                function cardHandle:Button(bCfg)
                    local bBtn = Instance.new("TextButton", drawerScroll)
                    bBtn.Size = UDim2.new(1, 0, 0, 32)
                    bBtn.BackgroundColor3 = Color3.fromRGB(36, 38, 46)
                    bBtn.Text = bCfg.Title or "Button"
                    bBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                    bBtn.TextSize = 10
                    bBtn.FontFace = Font.fromName("Montserrat", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
                    bBtn.ZIndex = 62
                    bBtn:SetAttribute("CardOwner", card)
                    init.create_corner(6, bBtn)
                    bBtn.MouseButton1Click:Connect(function()
                        if bCfg.Callback then pcall(bCfg.Callback) end
                    end)
                end

                function cardHandle:Input(iCfg)
                    local iFrame = Instance.new("Frame", drawerScroll)
                    iFrame.Size = UDim2.new(1, 0, 0, 48)
                    iFrame.BackgroundColor3 = Color3.fromRGB(34, 35, 42)
                    iFrame.ZIndex = 62
                    iFrame:SetAttribute("CardOwner", card)
                    init.create_corner(6, iFrame)

                    local iTitle = Instance.new("TextLabel", iFrame)
                    iTitle.Size = UDim2.new(1, -20, 0, 16)
                    iTitle.Position = UDim2.new(0, 10, 0, 5)
                    iTitle.BackgroundTransparency = 1
                    iTitle.Text = iCfg.Title or "Input"
                    iTitle.TextColor3 = Color3.fromRGB(220, 222, 230)
                    iTitle.TextSize = 10
                    iTitle.FontFace = Font.fromName("Montserrat", Enum.FontWeight.Medium, Enum.FontStyle.Normal)
                    iTitle.TextXAlignment = Enum.TextXAlignment.Left
                    iTitle.ZIndex = 63

                    local box = Instance.new("TextBox", iFrame)
                    box.Size = UDim2.new(1, -20, 0, 20)
                    box.Position = UDim2.new(0, 10, 0, 22)
                    box.BackgroundColor3 = Color3.fromRGB(24, 25, 30)
                    box.Text = tostring(iCfg.Value or "")
                    box.PlaceholderText = iCfg.Placeholder or "Enter value..."
                    box.TextColor3 = Color3.fromRGB(255, 255, 255)
                    box.TextSize = 10
                    box.ClearTextOnFocus = false
                    box.ZIndex = 63
                    init.create_corner(4, box)

                    box.FocusLost:Connect(function()
                        if iCfg.Callback then pcall(iCfg.Callback, box.Text) end
                    end)
                end

                return cardHandle
            end

            function tabOps.Button(cfg)
                local btn = Instance.new("TextButton", container)
                btn.Size = UDim2.new(1, 0, 0, 42)
                btn.BackgroundColor3 = Color3.fromRGB(36, 38, 46)
                btn.Text = cfg.Title or "Button"
                btn.TextColor3 = Color3.fromRGB(255, 255, 255)
                btn.TextSize = 11
                btn.FontFace = Font.fromName("Montserrat", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
                btn.ZIndex = 7
                init.create_corner(8, btn)
                init.stroke(btn, 0.6, 1, Color3.fromRGB(66, 67, 74))

                btn.MouseButton1Click:Connect(function()
                    if cfg.Callback then pcall(cfg.Callback) end
                end)
                return btn
            end

            return tabOps
        end

        tabs.Main = main
        return tabs
    end

    return library
end

-- ==============================================================================
-- 🏛️ PART 10: INITIALIZE PAYOMBOYZ UI & BUILD 8 MASTER TABS
-- ==============================================================================
local library = loadPayomboyUIEngine()
local payom = library.create()

-- 8 Tabs Assembly
local tabParry   = payom.create(T("tab_parry"))
local tabClash   = payom.create(T("tab_clash"))
local tabVisuals = payom.create(T("tab_visuals"))
local tabDefense = payom.create(T("tab_defense"))
local tabRPGFarm = payom.create(T("tab_rpg_farm"))
local tabRPGBoss = payom.create(T("tab_rpg_boss"))
local tabMisc    = payom.create(T("tab_misc"))
local tabSettings= payom.create(T("tab_settings"))

-- ─── TAB 1: AUTO PARRY & PVP ──────────────────────────────────────────
tabParry.Header({ Title = T("sec_parry") })

local parryCard = tabParry.Toggle({
    Title = T("parry_card"),
    Info = T("parry_card_desc"),
    Default = _G.Settings.Auto_Parry,
    Callback = function(st) _G.Settings.Auto_Parry = st end
})

parryCard:Dropdown({
    Title = T("parry_mode"),
    Values = { "Hybrid", "Legit (Keypress)", "Rage (Remote)" },
    Value = _G.Settings.Parry_Mode,
    Callback = function(v) _G.Settings.Parry_Mode = v end
})

parryCard:Slider({
    Title = T("parry_dist"),
    Min = 15, Max = 80, Default = _G.Settings.Parry_Distance, Round = 1,
    Callback = function(v) _G.Settings.Parry_Distance = v end
})

parryCard:Dropdown({
    Title = "Parry Key Bind",
    Values = { "F", "X", "C", "Q" },
    Value = _G.Settings.Parry_Key,
    Callback = function(v) _G.Settings.Parry_Key = v end
})

parryCard:Slider({
    Title = T("jitter_delay"),
    Min = 0, Max = 60, Default = math.floor((_G.Settings.Reaction_Jitter or 0.025) * 1000), Round = 1,
    Callback = function(v) _G.Settings.Reaction_Jitter = v / 1000 end
})

local curveCard = tabParry.Toggle({
    Title = T("curve_detect"),
    Info = "Delays parry when ball curves and accelerates sideways",
    Default = _G.Settings.Curve_Detection,
    Callback = function(st) _G.Settings.Curve_Detection = st end
})

local pingCard = tabParry.Toggle({
    Title = T("ping_comp"),
    Info = "Dynamically subtracts player network ping from reach time",
    Default = _G.Settings.Ping_Compensation,
    Callback = function(st) _G.Settings.Ping_Compensation = st end
})

-- ─── TAB 2: CLASH & SPAM ─────────────────────────────────────────────
tabClash.Header({ Title = T("sec_clash") })

local clashCard = tabClash.Toggle({
    Title = T("clash_card"),
    Info = T("clash_card_desc"),
    Default = _G.Settings.Auto_Spam_Clash,
    Callback = function(st) _G.Settings.Auto_Spam_Clash = st end
})

clashCard:Slider({
    Title = T("clash_dist"),
    Min = 6, Max = 25, Default = _G.Settings.Spam_Distance, Round = 1,
    Callback = function(v) _G.Settings.Spam_Distance = v end
})

clashCard:Slider({
    Title = "Spam Delay (ms)",
    Min = 15, Max = 100, Default = math.floor((_G.Settings.Spam_Rate or 0.03) * 1000), Round = 1,
    Callback = function(v) _G.Settings.Spam_Rate = v / 1000 end
})

-- ─── TAB 3: VISUALS & BALL ESP (BONUS FEATURE 1) ──────────────────────
tabVisuals.Header({ Title = T("sec_visuals") })

local ringCard = tabVisuals.Toggle({
    Title = T("range_ring_card"),
    Info = T("range_ring_desc"),
    Default = _G.Settings.Parry_Range_Visual,
    Callback = function(st)
        _G.Settings.Parry_Range_Visual = st
        updateParryRangeVisual()
    end
})

local tracerCard = tabVisuals.Toggle({
    Title = T("tracer_card"),
    Info = T("tracer_desc"),
    Default = _G.Settings.Ball_Tracer,
    Callback = function(st) _G.Settings.Ball_Tracer = st end
})

local hlCard = tabVisuals.Toggle({
    Title = T("highlight_card"),
    Info = T("highlight_desc"),
    Default = _G.Settings.Ball_Highlight,
    Callback = function(st) _G.Settings.Ball_Highlight = st end
})

local hudCard = tabVisuals.Toggle({
    Title = T("ball_hud_card"),
    Info = T("ball_hud_desc"),
    Default = _G.Settings.Ball_HUD,
    Callback = function(st) _G.Settings.Ball_HUD = st end
})

-- ─── TAB 4: DEFENSE & SKILLS (BONUS FEATURE 2) ────────────────────────
tabDefense.Header({ Title = T("sec_defense") })

local defCard = tabDefense.Toggle({
    Title = T("auto_dash_card"),
    Info = T("auto_dash_desc"),
    Default = _G.Settings.Auto_Defensive_Skill,
    Callback = function(st) _G.Settings.Auto_Defensive_Skill = st end
})

defCard:Dropdown({
    Title = T("def_key"),
    Values = { "Q", "E", "R", "F", "Shift" },
    Value = _G.Settings.Defensive_Key,
    Callback = function(v) _G.Settings.Defensive_Key = v end
})

defCard:Slider({
    Title = "Trigger Impact Window (ms)",
    Min = 50, Max = 300, Default = math.floor((_G.Settings.Emergency_Threshold or 0.12) * 1000), Round = 10,
    Callback = function(v) _G.Settings.Emergency_Threshold = v / 1000 end
})

-- ─── TAB 5: BROKEN BLADE RPG COMBAT ──────────────────────────────────
tabRPGFarm.Header({ Title = T("sec_rpg_farm") })

local enemyCard = tabRPGFarm.Toggle({
    Title = T("enemy_card"),
    Info = T("enemy_card_desc"),
    Default = _G.Settings.Auto_Farm,
    Callback = function(st) _G.Settings.Auto_Farm = st end
})

local enemiesList = { "Multi Select" }
local function refreshEnemies()
    table.clear(enemiesList)
    table.insert(enemiesList, "Multi Select")
    pcall(function()
        if workspace:FindFirstChild("EnemyService") then
            for _, m in ipairs(workspace.EnemyService:GetChildren()) do
                if m:IsA("Model") and not table.find(enemiesList, m.Name) then
                    table.insert(enemiesList, m.Name)
                end
            end
        end
    end)
end
refreshEnemies()

enemyCard:Dropdown({
    Title = T("select_enemy"),
    Values = enemiesList,
    Value = _G.Settings.Select_Enemy,
    Callback = function(val) _G.Settings.Select_Enemy = val end
})

enemyCard:Button({
    Title = T("refresh_enemy"),
    Callback = function() refreshEnemies() end
})

enemyCard:Dropdown({
    Title = T("attack_pos"),
    Values = { "Above", "Behind", "Below" },
    Value = _G.Settings.Mode_Farm,
    Callback = function(val)
        _G.Settings.Mode_Farm = val
        updateModeFarm()
    end
})

enemyCard:Slider({
    Title = T("attack_dist"),
    Min = 2, Max = 25, Default = _G.Settings.Disc, Round = 1,
    Callback = function(val)
        _G.Settings.Disc = val
        updateModeFarm()
    end
})

local skillsCard = tabRPGFarm.Toggle({
    Title = T("skills_card"),
    Info = T("skills_card_desc"),
    Default = _G.Settings.Auto_Skill,
    Callback = function(st) _G.Settings.Auto_Skill = st end
})

skillsCard:Dropdown({
    Title = T("select_weapon"),
    Values = { "1", "2", "3" },
    Value = _G.Settings.Select_Weapon,
    Callback = function(val) _G.Settings.Select_Weapon = val end
})

local rpgBlockCard = tabRPGFarm.Toggle({
    Title = T("rpg_block_card"),
    Info = T("rpg_block_desc"),
    Default = _G.Settings.Auto_Block_RPG,
    Callback = function(st) _G.Settings.Auto_Block_RPG = st end
})

rpgBlockCard:Dropdown({
    Title = "Block Button",
    Values = { "F", "X", "C" },
    Value = _G.Settings.Block_Button_RPG,
    Callback = function(val) _G.Settings.Block_Button_RPG = val end
})

rpgBlockCard:Slider({
    Title = "Block Delay (s)",
    Min = 0.01, Max = 0.50, Default = _G.Settings.Block_Delay_RPG, Round = 0.01,
    Callback = function(val) _G.Settings.Block_Delay_RPG = val end
})

-- ─── TAB 6: BROKEN BLADE RPG BOSS & RAIDS ────────────────────────────
tabRPGBoss.Header({ Title = T("sec_rpg_boss") })

local eclipseCard = tabRPGBoss.Toggle({
    Title = T("eclipse_card"),
    Info = T("eclipse_card_desc"),
    Default = _G.Settings.Auto_Summon_Eclipse,
    Callback = function(st) _G.Settings.Auto_Summon_Eclipse = st end
})

eclipseCard:Dropdown({
    Title = T("eclipse_diff"),
    Values = { "Easy", "Hard", "Nightmare" },
    Value = _G.Settings.Selected_Difficult_Eclipse,
    Callback = function(val) _G.Settings.Selected_Difficult_Eclipse = val end
})

local raidCard = tabRPGBoss.Toggle({
    Title = T("raid_card"),
    Info = T("raid_card_desc"),
    Default = _G.Settings.Auto_Raid,
    Callback = function(st) _G.Settings.Auto_Raid = st end
})

raidCard:Dropdown({
    Title = T("select_raid"),
    Values = { "Easy", "Hard", "Nightmare" },
    Value = _G.Settings.Selected_Raid,
    Callback = function(val) _G.Settings.Selected_Raid = val end
})

raidCard:Button({
    Title = T("auto_join_raid"),
    Callback = function()
        _G.Settings.Auto_Broken_Expanse_Join_Raid = not _G.Settings.Auto_Broken_Expanse_Join_Raid
        notify("PAYOMBØYZ", "Auto Join Raid: " .. tostring(_G.Settings.Auto_Broken_Expanse_Join_Raid), 2)
    end
})

local questCard = tabRPGBoss.Toggle({
    Title = T("quest_card"),
    Info = T("quest_card_desc"),
    Default = _G.Settings.Auto_Find_Quest,
    Callback = function(st) _G.Settings.Auto_Find_Quest = st end
})

local chestOptions = { "Aura Crate", "Cosmetic Crate", "Secret Chest", "Upper Seal", "Abyss Sigil", "None" }
questCard:Dropdown({
    Title = "Target Chest 1",
    Values = chestOptions,
    Value = _G.Settings.Selected_Chest,
    Callback = function(val) _G.Settings.Selected_Chest = val end
})

questCard:Slider({
    Title = "Min Chest Count",
    Min = 1, Max = 20, Default = _G.Settings.Chest_Amount, Round = 1,
    Callback = function(val) _G.Settings.Chest_Amount = val end
})

-- ─── TAB 7: MISC & PERFORMANCE ───────────────────────────────────────
tabMisc.Header({ Title = T("sec_misc") })

local fullScreenFrame = nil
local cpuCard = tabMisc.Toggle({
    Title = T("cpu_card"),
    Info = T("cpu_card_desc"),
    Default = _G.Settings.Screen_CPUStart,
    Callback = function(st)
        _G.Settings.Screen_CPUStart = st
        pcall(function()
            if st and not fullScreenFrame then
                local sGui = Instance.new("ScreenGui")
                sGui.Name = "GlobalColorScreen"
                sGui.IgnoreGuiInset = true
                sGui.DisplayOrder = -999
                sGui.Parent = LocalPlayer.PlayerGui

                fullScreenFrame = Instance.new("Frame", sGui)
                fullScreenFrame.Size = UDim2.new(1, 0, 1, 0)
                fullScreenFrame.BackgroundColor3 = (_G.Settings.Screen_cpu == "White") and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(0, 0, 0)
                fullScreenFrame.BorderSizePixel = 0
            end
            if fullScreenFrame then fullScreenFrame.Visible = st end
        end)
    end
})

cpuCard:Dropdown({
    Title = T("screen_color"),
    Values = { "Black", "White" },
    Value = _G.Settings.Screen_cpu,
    Callback = function(val)
        _G.Settings.Screen_cpu = val
        if fullScreenFrame then
            fullScreenFrame.BackgroundColor3 = (val == "White") and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(0, 0, 0)
        end
    end
})

local rejoinCard = tabMisc.Toggle({
    Title = T("rejoin_card"),
    Info = T("rejoin_card_desc"),
    Default = _G.Settings.Auto_Rejoin,
    Callback = function(st) _G.Settings.Auto_Rejoin = st end
})

rejoinCard:Button({
    Title = T("btn_panic"),
    Callback = function()
        _G.Settings.Auto_Parry = false
        _G.Settings.Auto_Spam_Clash = false
        _G.Settings.Auto_Defensive_Skill = false
        _G.Settings.Auto_Farm = false
        _G.Settings.Auto_Skill = false
        _G.Settings.Auto_Block_RPG = false
        _G.Settings.Auto_Summon_Eclipse = false
        _G.Settings.Auto_Raid = false
        _G.Settings.Auto_Find_Quest = false
        notify("PAYOMBØYZ", currentLang == "TH" and "ปิดการทำงานทุกอย่างแล้ว!" or "All actions stopped!", 2)
    end
})

-- ─── TAB 8: SETTINGS & WEBHOOK ───────────────────────────────────────
tabSettings.Header({ Title = T("sec_settings") })

tabSettings.Button({
    Title = T("btn_toggle_lang"),
    Callback = function()
        currentLang = (currentLang == "TH") and "EN" or "TH"
        notify("PAYOMBØYZ", "Language: " .. currentLang, 2)
    end
})

local webhookCard = tabSettings.Toggle({
    Title = T("webhook_card"),
    Info = T("webhook_card_desc"),
    Default = _G.Settings.Send_Webhook,
    Callback = function(st) _G.Settings.Send_Webhook = st end
})

local function sendWebhookMessage(text)
    if _G.Settings.Webhook_Link ~= "" then
        pcall(function()
            local payload = {
                content = _G.Settings.Send_Webhook_Pings and ("<@" .. _G.Settings.Pings_Userid .. ">") or "",
                embeds = {{
                    title = "PAYOMBØYZ MASTER BLADE BALL",
                    description = text,
                    color = 14423838,
                    footer = { text = "PAYOMBØYZ Official", icon_url = "https://raw.githubusercontent.com/payomboyz333/Library/main/LogoPayomboyZ.png" },
                    timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ"),
                }}
            }
            local req = http_request or request or HttpPost or syn.request
            if req then
                req({
                    Url = _G.Settings.Webhook_Link,
                    Body = HttpService:JSONEncode(payload),
                    Method = "POST",
                    Headers = { ["content-type"] = "application/json" }
                })
            end
        end)
    end
end

webhookCard:Input({
    Title = T("webhook_url"),
    Value = _G.Settings.Webhook_Link,
    Placeholder = "https://discord.com/api/webhooks/...",
    Callback = function(val) _G.Settings.Webhook_Link = val end
})

webhookCard:Button({
    Title = T("btn_test_webhook"),
    Callback = function()
        sendWebhookMessage("PAYOMBØYZ Master Blade Ball — Webhook Active!")
        notify("PAYOMBØYZ", "Test webhook message sent!", 2)
    end
})

local cfgCard = tabSettings.Toggle({
    Title = T("config_card"),
    Info = "Save and load custom config profiles",
    Default = false,
    Callback = function() end
})

local curConfigName = "Default"
cfgCard:Input({
    Title = T("config_name"),
    Value = curConfigName,
    Callback = function(val) curConfigName = val end
})

cfgCard:Button({
    Title = T("btn_save_config"),
    Callback = function()
        saveConfig(curConfigName)
        notify("PAYOMBØYZ", "Saved profile: " .. curConfigName, 2)
    end
})

cfgCard:Button({
    Title = T("btn_load_config"),
    Callback = function()
        loadConfig(curConfigName)
        notify("PAYOMBØYZ", "Loaded profile: " .. curConfigName, 2)
    end
})

-- ==============================================================================
-- 💊 PART 11: FLOATING CAPSULE HUD (BLUEPRINT SPEC SECTION 4.1)
-- ==============================================================================
local mainFrame = payom.Main
local hudGui = Instance.new("ScreenGui")
hudGui.Name = "PayomboyZ_BB_HUD"
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
avStroke.Color = Color3.fromRGB(220, 38, 58)

local hudTitle = Instance.new("TextLabel", hudFrame)
hudTitle.Size = UDim2.new(0, 135, 0, 18)
hudTitle.Position = UDim2.new(0, 52, 0, 9)
hudTitle.BackgroundTransparency = 1
hudTitle.Text = "PAYOMBØYZ BB"
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
hudBtn.MouseButton1Click:Connect(toggleMainWindow)

-- Draggable HUD
local hDragging, hDragStart, hStartPos = false, nil, nil
hudBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        hDragging = true
        hDragStart = input.Position
        hStartPos = hudFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then hDragging = false end
        end)
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if hDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - hDragStart
        hudFrame.Position = UDim2.new(hStartPos.X.Scale, hStartPos.X.Offset + delta.X, hStartPos.Y.Scale, hStartPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and (input.KeyCode == Enum.KeyCode.RightControl or input.KeyCode == Enum.KeyCode.Insert) then
        toggleMainWindow()
    end
end)

-- Live FPS & Ping Meter Loop
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

-- ==============================================================================
-- 🧹 PART 12: CLEANUP REGISTRATION
-- ==============================================================================
_G.PayomboyZBrokenBladeCleanup = function()
    RUN = nil
    _G.PayomboyZBrokenBladeRun = nil
    for _, c in ipairs(_G.PayomboyZBrokenBladeConns) do pcall(function() c:Disconnect() end) end
    table.clear(_G.PayomboyZBrokenBladeConns)
    if rangeRingPart then pcall(function() rangeRingPart:Destroy() end) end
    if ballTracerBeam then pcall(function() ballTracerBeam:Destroy() end) end
    if ballBillboard then pcall(function() ballBillboard:Destroy() end) end
    safeDestroyGui("PayomboyZ_BB_HUD")
    safeDestroyGui("GlobalColorScreen")
end

notify("PAYOMBØYZ", currentLang == "TH" and "โหลด PAYOMBØYZ Master Blade Ball เรียบร้อยแล้ว!" or "PAYOMBØYZ Master Blade Ball Loaded!", 3)
