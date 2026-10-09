-- ==============================================================================
-- 🛡️ Anti-Tamper & Anti-Cheat Mitigation (ป้องกัน BAC Kick บนมือถือและ PC)
-- ==============================================================================
pcall(function()
    if type(getgc) ~= "function" then return end
    for i, v in getgc(true) do
        if typeof(v) ~= "table" or getrawmetatable(v) then continue end

        local is_recursive = false

        for _, value in v do
            if value == v then
                is_recursive = true
                break
            end
        end

        if not is_recursive then continue end

        local banindex: number?
        for _, value in v do
            if value == 1 or value == 2 or value == 3 then
                banindex = value
                break
            end
        end

        if banindex and v[banindex] == nil then
            setmetatable(v, {
                __newindex = function() end
            })
        end
    end
end)

-- ==============================================================================
-- PAYOMBØYZ Script HUB - Modern Dynamic Comic / Obsidian Glassmorphic 2 Engine
-- URL: https://raw.githubusercontent.com/Payomboyz0028/Yaranikaaaa/refs/heads/main/Start
-- Key Engine URL: https://raw.githubusercontent.com/payomboyz333/PAY-MB-YZ-HUB/refs/heads/main/Key-obfuscated.lua
-- Background: upscaled_Blackground Sep 28, 2026.png (Raw GitHub / Local Asset)
-- ==============================================================================

local _ENV = (getgenv and getgenv()) or _G

if _ENV.__PAYOMBOYZ_SCRIPT_LAUNCHED then
    warn("[PAYOMBØYZ HUB] Game script already running in this session, skipping duplicate loader.")
    return
end

-- Cleanup any previous UI instances cleanly
pcall(function()
    if _ENV.__PAYOMBOYZ_CURRENT_GUI and _ENV.__PAYOMBOYZ_CURRENT_GUI.Parent then
        _ENV.__PAYOMBOYZ_CURRENT_GUI:Destroy()
    end
    if _ENV.__PAYOMBOYZ_CURRENT_WINDOW and _ENV.__PAYOMBOYZ_CURRENT_WINDOW.Gui then
        _ENV.__PAYOMBOYZ_CURRENT_WINDOW.Gui:Destroy()
    end
    local cg = game:GetService("CoreGui")
    local plrs = game:GetService("Players")
    local lp = plrs.LocalPlayer
    local pg = lp and lp:FindFirstChildOfClass("PlayerGui")
    for _, target in ipairs({ cg, pg }) do
        if target then
            for _, name in ipairs({ "PayomboyZ_ToastLayer", "PayomboyZ_ToastUI", "PayomboyZ_LoaderUI", "RobloxLoaderGui" }) do
                local old = target:FindFirstChild(name)
                if old then pcall(function() old:Destroy() end) end
            end
        end
    end
end)

_ENV.__PAYOMBOYZ_HUB_ACTIVE = true

-- Cross-Executor HTTP Request Bridge
pcall(function()
    local fn = (typeof(request) == "function" and request)
            or (typeof(http_request) == "function" and http_request)
            or (typeof(syn) == "table" and typeof(syn.request) == "function" and syn.request)
            or (typeof(http) == "table" and typeof(http.request) == "function" and http.request)
    if fn then
        if typeof(request) ~= "function" and getgenv then getgenv().request = fn end
        if typeof(http_request) ~= "function" and getgenv then getgenv().http_request = fn end
    end
end)

local function safeFetch(url)
    if not url or url == "" then return "" end
    local ok, content = pcall(game.HttpGet, game, url)
    if ok and type(content) == "string" and #content > 50 and not content:find("automated source fetching") then
        return content
    end

    local httprequest = (typeof(request) == "function" and request)
                     or (typeof(http_request) == "function" and http_request)
                     or (typeof(syn) == "table" and typeof(syn.request) == "function" and syn.request)

    if httprequest then
        local okReq, res = pcall(function()
            local headers = {}
            local uis = game:GetService("UserInputService")
            if uis and not (uis.TouchEnabled and not uis.KeyboardEnabled) then
                headers["User-Agent"] = "Roblox/WinInet"
            end
            return httprequest({
                Url = url,
                Method = "GET",
                Headers = headers
            })
        end)
        if okReq and res and res.Body and #res.Body > 50 and not res.Body:find("automated source fetching") then
            return res.Body
        end
    end

    return (ok and content) or ""
end

local _isAuthenticating = false
local _isScriptLaunched = false

if not game:IsLoaded() then
    game.Loaded:Wait()
end

-- ==============================================================================
-- ⚙️ CONFIGURATION
-- ==============================================================================
local HubConfig = {
    HubName = "PAYOMBØYZ Script HUB",
    SavedKeyFile = "PayomboyZ_SavedKey.txt",
    GetKeyURL = "https://ads.luarmor.net/get_key?for=PBG-fVUxHRHebIHz",
    DiscordURL = "https://discord.gg/KmrgQwbcMD",
    VVIPURL = "https://payomboyz.rexzy.xyz/",
    StartURL = "https://raw.githubusercontent.com/Payomboyz0028/Yaranikaaaa/refs/heads/main/Start",
    KeyEngineURL = "https://raw.githubusercontent.com/payomboyz333/PAY-MB-YZ-HUB/refs/heads/main/Key-obfuscated.lua",
    BgRawURL = "https://raw.githubusercontent.com/payomboyz333/Library/main/upscaled_Blackground%20Sep%2028%2C%202026.png",
    BgFileName = "upscaled_Blackground Sep 28, 2026.png",
    LogoURL = "https://raw.githubusercontent.com/payomboyz333/Library/main/LogoPayomboyZ.png",
    LogoFileName = "LogoPayomboyZ.png"
}

-- ==============================================================================
-- 🌏 BILINGUAL LANGUAGE SYSTEM (TH / EN)
-- ==============================================================================
local _currentLang = "TH"

local LANG_TH = {
    hubTitle         = "PAYOMBØYZ HUB",
    archiveSubtitle  = "MANGA INTERFACE  /  PLAY MORE • WORK LESS",
    highVoltageSub   = "⚡ HIGH-VOLTAGE EXECUTION ENGINE • VVIP EDITION",
    activeService    = "ACTIVE SERVICE",
    studioName       = "PayomboyZ Studios",
    clientDelivery   = "Verified client delivery",
    secureAccess     = "SECURE ACCESS",
    enterPrompt      = "กรุณากรอก Key ของคุณเพื่อเริ่มใช้งาน",
    waitingKey       = "กำลังรอรับ Key...",
    inputPlaceholder = "กรุณากรอก Key ของคุณ...",
    redeemBtn        = "⚡ เข้าสู่ระบบ • LOGIN",
    getKeyBtn        = "รับ Key ฟรี • Get Free Key",
    discordBtn       = "Discord • เข้าร่วมชุมชน",
    copyHwidBtn      = "คัดลอก HWID • Copy HWID",
    clearKeyBtn      = "ล้างคีย์ที่บันทึก • Clear Saved Key",
    premiumBtn       = "สมัคร VVIP • Purchase VVIP",
    vipTitle         = "PAYOMBØYZ VIP",
    vvipExclusive    = "VVIP Exclusive Access",
    vvipPerksDesc    = "ปลดล็อกแมพ Slayers 2, MM2 & ฟีเจอร์ระดับพรีเมียม",
    vvipDiscordNote  = "เข้าร่วม Discord เพื่ออัปเกรดเป็น VVIP",
    vvipPillTags     = "VVIP Maps  |  Priority Support  |  Auto Farm Engine",
    verifying        = "🔍 [1/2] กำลังตรวจสอบคีย์...",
    superVIPOk       = "👑 [SUPER-VIP] ยืนยันสิทธิ์ Super-VIP สำเร็จ...",
    vipSuccess       = "⭐ [VIP] เข้าสู่ระบบสำเร็จ! กำลังรันเกม...",
    vvipSuccess      = "👑 [VVIP] ยืนยันสิทธิ์ VVIP สำเร็จ! กำลังรันเกม...",
    superVIPSuccess  = "👑 [SUPER-VIP] สิทธิ์ไม่จำกัดจอ! กำลังรันเกม...",
    vvipMapWarn      = "⚠️ แมพนี้ต้องใช้คีย์ VVIP! กำลังเปลี่ยนเส้นทาง...",
    keyEmpty         = "⚠️ กรุณากรอก Key ก่อนเข้าใช้งาน",
    keyBad           = "❌ Key ไม่ถูกต้องหรือหมดอายุ",
    copiedDiscord    = "คัดลอกลิงก์ Discord เรียบร้อยแล้ว!",
    copiedKey        = "คัดลอกลิงก์รับ Key เรียบร้อยแล้ว!",
    copiedHwid       = "คัดลอก HWID เรียบร้อยแล้ว!",
    copiedVvip       = "คัดลอกลิงก์ VVIP เรียบร้อยแล้ว!",
    keyCleared       = "🗑️ ล้างคีย์ที่บันทึกในเครื่องเรียบร้อยแล้ว",
    xenoBlocked      = "❌ ตัวรัน Xeno ไม่รองรับการใช้งาน กรุณาใช้ตัวรันอื่น",
    retrying         = "🔄 รันสคริปต์ไม่สำเร็จ กำลังลองใหม่อัตโนมัติ...",
    retryFailed      = "⚠️ โหลดสคริปต์ล้มเหลว กดลองใหม่ หรือรอสักครู่",
    langBtn          = "EN",
    tabUserInfo      = "ข้อมูลผู้ใช้",
    tabGameSupport   = "คลังเกมที่รองรับ",
    connectedStatus  = "เชื่อมต่อระบบ PAYOMBØYZ HUB แล้ว",
    systemReady      = "PAYOMBØYZ HUB พร้อมทำงาน",
    sessionLabel     = "เวลาใช้งาน",
    pingLabel        = "สถานะ PING",
    executorLabel    = "ตัวรัน (Executor)",
    deviceLabel      = "อุปกรณ์ (Device)",
    hwidLabel        = "สถานะ HWID",
    gameLabel        = "แมพปัจจุบัน",
    playBtn          = "🎮 เล่น",
    teleporting      = "กำลังวาร์ปไปยัง %s...",
    teleportBlocked  = "แมพบล็อกการ Teleport! คัดลอก PlaceId ให้แล้ว",
}

local LANG_EN = {
    hubTitle         = "PAYOMBØYZ HUB",
    archiveSubtitle  = "MANGA INTERFACE  /  PLAY MORE • WORK LESS",
    highVoltageSub   = "⚡ HIGH-VOLTAGE EXECUTION ENGINE • VVIP EDITION",
    activeService    = "ACTIVE SERVICE",
    studioName       = "PayomboyZ Studios",
    clientDelivery   = "Verified client delivery",
    secureAccess     = "SECURE ACCESS",
    enterPrompt      = "Enter your key to launch PAYOMBØYZ HUB",
    waitingKey       = "Waiting for key...",
    inputPlaceholder = "Paste your key here...",
    redeemBtn        = "⚡ LOGIN • เข้าสู่ระบบ",
    getKeyBtn        = "Get Free Key • รับคีย์ฟรี",
    discordBtn       = "Discord • Join Community",
    copyHwidBtn      = "Copy HWID • คัดลอก HWID",
    clearKeyBtn      = "Clear Saved Key • ล้างคีย์เดิม",
    premiumBtn       = "Purchase VVIP • สมัคร VVIP",
    vipTitle         = "PAYOMBØYZ VIP",
    vvipExclusive    = "VVIP Exclusive Access",
    vvipPerksDesc    = "Unlock Slayers 2, MM2 & exclusive features",
    vvipDiscordNote  = "Join Discord to Upgrade to VVIP",
    vvipPillTags     = "VVIP Maps  |  Priority Support  |  Auto Farm Engine",
    verifying        = "🔍 [1/2] Verifying key...",
    superVIPOk       = "👑 [SUPER-VIP] Super-VIP verified successfully...",
    vipSuccess       = "⭐ [VIP] Login successful! Launching game...",
    vvipSuccess      = "👑 [VVIP] VVIP access granted! Launching game...",
    superVIPSuccess  = "👑 [SUPER-VIP] Unlimited access! Launching game...",
    vvipMapWarn      = "⚠️ This map requires a VVIP key! Redirecting...",
    keyEmpty         = "⚠️ Please enter your key first",
    keyBad           = "❌ Invalid key or expired",
    copiedDiscord    = "Discord link copied to clipboard!",
    copiedKey        = "Get-Key link copied to clipboard!",
    copiedHwid       = "HWID copied to clipboard!",
    copiedVvip       = "VVIP link copied to clipboard!",
    keyCleared       = "🗑️ Saved key cleared from device",
    xenoBlocked      = "❌ Xeno executor is not supported. Please use another executor",
    retrying         = "🔄 Script failed to run, retrying automatically...",
    retryFailed      = "⚠️ Script load failed — click retry or wait",
    langBtn          = "TH",
    tabUserInfo      = "User Info",
    tabGameSupport   = "Game Support",
    connectedStatus  = "Connected to PAYOMBØYZ HUB",
    systemReady      = "PAYOMBØYZ HUB is ready",
    sessionLabel     = "Session",
    pingLabel        = "Ping",
    executorLabel    = "Executor",
    deviceLabel      = "Device",
    hwidLabel        = "HWID",
    gameLabel        = "Game",
    playBtn          = "🎮 Play",
    teleporting      = "Teleporting to %s...",
    teleportBlocked  = "Teleport blocked by server! Copied PlaceId to clipboard",
}

local function L(key)
    local t = (_currentLang == "TH") and LANG_TH or LANG_EN
    return t[key] or key
end

-- ==============================================================================
-- 🔐 REMOTE SECURE KEY LOADER (ดึงจาก Key Engine บน GitHub & Luarmor API Fallback)
-- ==============================================================================
local RemoteKeyDataCache = nil
local RemoteKeyDataLoading = false

local function GetRemoteKeyData()
    if RemoteKeyDataCache then return RemoteKeyDataCache end

    if RemoteKeyDataLoading then
        local waited = 0
        while RemoteKeyDataLoading and waited < 6 do
            task.wait(0.2)
            waited = waited + 0.2
            if RemoteKeyDataCache then return RemoteKeyDataCache end
        end
        return RemoteKeyDataCache
    end
    RemoteKeyDataLoading = true

    local prevKey = (getgenv and getgenv().script_key) or _G.script_key
    if getgenv then getgenv().script_key = nil end
    _G.script_key = nil

    local urls = {
        HubConfig.KeyEngineURL,
        "https://raw.githubusercontent.com/payomboyz333/PAY-MB-YZ-HUB/refs/heads/main/Key-obfuscated.lua",
        "https://raw.githubusercontent.com/payomboyz333/PAY-MB-YZ-HUB/refs/heads/main/Key.txt",
        "https://raw.githubusercontent.com/Payomboyz0028/Yaranikaaaa/refs/heads/main/Key"
    }

    local ok, data = pcall(function()
        for _, fetchUrl in ipairs(urls) do
            local finalUrl = fetchUrl
            if type(finalUrl) == "string" and finalUrl:find("raw.githubusercontent.com") and not finalUrl:find("%?") then
                finalUrl = finalUrl .. "?t=" .. tostring(os.time())
            end
            local raw = safeFetch(finalUrl)
            if raw and type(raw) == "string" and #raw > 50 and not raw:find("404: Not Found") and not raw:find("automated source fetching") then
                local fn = loadstring(raw, "=PayomboyZ_KeyEngine")
                if fn then
                    local res = fn()
                    if type(res) == "table" then return res end
                end
            end
        end

        local envKeys = (getgenv and getgenv().__PAYOMBOYZ_KEY_ENGINE) or _G.__PAYOMBOYZ_KEY_ENGINE
        if type(envKeys) == "table" then return envKeys end
        return nil
    end)

    if prevKey then
        if getgenv then getgenv().script_key = prevKey end
        _G.script_key = prevKey
    end

    RemoteKeyDataLoading = false

    if ok and type(data) == "table" then
        RemoteKeyDataCache = data
        if getgenv then getgenv().__PAYOMBOYZ_KEY_ENGINE = data end
        return RemoteKeyDataCache
    end

    return nil
end

local LuarmorSDKCache = nil
local LuarmorSDKLoading = false
local function getLuarmorSDK()
    if LuarmorSDKCache then return LuarmorSDKCache end
    if LuarmorSDKLoading then
        local waited = 0
        while LuarmorSDKLoading and waited < 8 do
            task.wait(0.2)
            waited = waited + 0.2
        end
        return LuarmorSDKCache
    end
    LuarmorSDKLoading = true
    local ok, lib = pcall(function()
        local sdkContent = safeFetch("https://sdkapi-public.luarmor.net/library.lua")
        if sdkContent and #sdkContent > 50 then
            local fn = loadstring(sdkContent)
            if fn then return fn() end
        end
        return loadstring(game:HttpGet("https://sdkapi-public.luarmor.net/library.lua"))()
    end)
    LuarmorSDKLoading = false
    if ok and type(lib) == "table" then
        LuarmorSDKCache = lib
        return lib
    end
    return nil
end

task.spawn(function()
    task.spawn(GetRemoteKeyData)
    task.spawn(getLuarmorSDK)
end)

local function IsSuperVIPKey(k)
    if not k or k == "" then return false end
    k = k:gsub("%s+", "")
    local engine = GetRemoteKeyData()
    if engine and type(engine) == "table" then
        if type(engine.IsSuperVIP) == "function" then
            return engine.IsSuperVIP(k)
        elseif engine.SuperVIP and engine.SuperVIP[k] then
            return true
        end
    end
    return false
end

local function IsVVIPKey(k)
    if not k or k == "" then return false end
    k = k:gsub("%s+", "")
    if IsSuperVIPKey(k) then return true end
    local engine = GetRemoteKeyData()
    if engine and type(engine) == "table" then
        if type(engine.IsVVIP) == "function" then
            return engine.IsVVIP(k)
        elseif engine.VVIP and engine.VVIP[k] then
            return true
        end
    end
    return false
end

local function IsValidKeyFormat(k)
    if not k or type(k) ~= "string" then return false end
    local clean = k:gsub("%s+", "")
    return #clean >= 20 and #clean <= 65 and clean:match("^[A-Za-z0-9_%-]+$") ~= nil
end

local function VerifyKey(key)
    if not key or key == "" then return false, L("keyEmpty") end
    key = key:gsub("%s+", "")

    -- 1. Fast path: SuperVIP & VVIP directly from Engine
    if IsSuperVIPKey(key) then
        return true, "👑 " .. L("superVIPSuccess"), true, true
    end
    if IsVVIPKey(key) then
        return true, "👑 " .. L("vvipSuccess"), true, false
    end

    -- 2. Verify through GitHub KeyEngine
    local engine = GetRemoteKeyData()
    if engine and type(engine.VerifyKey) == "function" then
        local ok, reason, isVvip, isSuperVip = engine.VerifyKey(key)
        if ok then
            return true, reason or "✅ " .. L("vipSuccess"), isVvip, isSuperVip
        elseif type(reason) == "string" and (reason:find("หมดอายุ") or reason:find("ระงับ") or reason:find("ล็อคเครื่องอื่น")) then
            return false, reason, false, false
        end
    end

    -- 3. Verify through Luarmor SDK fallback
    local sdk = getLuarmorSDK()
    if sdk then
        local targetScriptIds = {
            "fcaefd984d0c3cd3a7335c0cf332c860",
            "54dc54601645ac0bc7238ec1a6868759"
        }
        for _, sid in ipairs(targetScriptIds) do
            local status = nil
            pcall(function()
                sdk.script_id = sid
                status = sdk.check_key(key)
            end)
            if status and type(status) == "table" and status.code then
                if status.code == "KEY_VALID" then
                    local isVvip = IsVVIPKey(key)
                    return true, "✅ " .. (isVvip and L("vvipSuccess") or L("vipSuccess")), isVvip, false
                elseif status.code == "KEY_INCORRECT" then
                    return false, "❌ " .. L("keyBad"), false, false
                elseif status.code == "KEY_EXPIRED" then
                    return false, "❌ Key หมดอายุแล้ว", false, false
                elseif status.code == "KEY_BANNED" then
                    return false, "❌ Key ถูกระงับการใช้งาน", false, false
                elseif status.code == "KEY_HWID_LOCKED" then
                    return false, "❌ Key ติดล็อคเครื่องอื่น", false, false
                end
            end
        end
    end

    -- 4. Mobile / Safe-Pass Resilience
    if IsValidKeyFormat(key) then
        return true, "✅ " .. L("vipSuccess"), false, false
    end

    return false, "❌ " .. L("keyBad"), false, false
end

-- ==============================================================================
-- 🎮 SMART ROUTER & UNIVERSE ID RESOLVER
-- ==============================================================================
local SupportedGames = {
    -- 🆓 แมพฟรี
    [13379208636] = { Name = "Attack On Titan Revolution", IsVVIP = false, URL = "https://raw.githubusercontent.com/payomboyz333/PAY-MB-YZ-HUB/refs/heads/main/AOTR-obfuscated.lua" },
    [14916516914] = { Name = "Attack On Titan Revolution", IsVVIP = false, URL = "https://raw.githubusercontent.com/payomboyz333/PAY-MB-YZ-HUB/refs/heads/main/AOTR-obfuscated.lua" },
    [14932214603] = { Name = "Attack On Titan Revolution", IsVVIP = false, URL = "https://raw.githubusercontent.com/payomboyz333/PAY-MB-YZ-HUB/refs/heads/main/AOTR-obfuscated.lua" },
    [125039473548047] = { Name = "Anime Card Farm", IsVVIP = false, URL = "https://raw.githubusercontent.com/payomboyz333/PAY-MB-YZ-HUB/refs/heads/main/Anime%20Card%20Farm-obfuscated.lua" },
    [122446657157717] = { Name = "Arena Sniper", IsVVIP = false, URL = "https://raw.githubusercontent.com/payomboyz333/PAY-MB-YZ-HUB/refs/heads/main/Sniper%20Arena-obfuscated.lua" },
    [126042865144779] = { Name = "Arena Sniper", IsVVIP = false, URL = "https://raw.githubusercontent.com/payomboyz333/PAY-MB-YZ-HUB/refs/heads/main/Sniper%20Arena-obfuscated.lua" },
    [119259569670784] = { Name = "Arena Sniper", IsVVIP = false, URL = "https://raw.githubusercontent.com/payomboyz333/PAY-MB-YZ-HUB/refs/heads/main/Sniper%20Arena-obfuscated.lua" },
    [90165746516953] = { Name = "Arena Sniper", IsVVIP = false, URL = "https://raw.githubusercontent.com/payomboyz333/PAY-MB-YZ-HUB/refs/heads/main/Sniper%20Arena-obfuscated.lua" },
    [74424488747487] = { Name = "Arena Sniper", IsVVIP = false, URL = "https://raw.githubusercontent.com/payomboyz333/PAY-MB-YZ-HUB/refs/heads/main/Sniper%20Arena-obfuscated.lua" },
    [104973076655377] = { Name = "Capybara Vs Plant", IsVVIP = false, URL = "https://raw.githubusercontent.com/payomboyz333/PAY-MB-YZ-HUB/refs/heads/main/CapybaraVsPlant-obfuscated.lua" },
    [128736949265057] = { Name = "Gakuran", IsVVIP = false, URL = "https://raw.githubusercontent.com/payomboyz333/PAY-MB-YZ-HUB/refs/heads/main/Gakurun-obfuscated.lua" },
    [126509999114328] = { Name = "99 Nights", IsVVIP = false, URL = "https://raw.githubusercontent.com/payomboyz333/PAY-MB-YZ-HUB/refs/heads/main/99Night-obfuscated.lua" },
    [79546208627805] = { Name = "99 Nights", IsVVIP = false, URL = "https://raw.githubusercontent.com/payomboyz333/PAY-MB-YZ-HUB/refs/heads/main/99Night-obfuscated.lua" },
    [2753915549] = { Name = "Blox Fruit", IsVVIP = false, URL = "https://raw.githubusercontent.com/payomboyz333/PAY-MB-YZ-HUB/refs/heads/main/Blox%20Fruit-obfuscated.lua" },
    [79091703265657] = { Name = "Blox Fruit", IsVVIP = false, URL = "https://raw.githubusercontent.com/payomboyz333/PAY-MB-YZ-HUB/refs/heads/main/Blox%20Fruit-obfuscated.lua" },
    [4442272183] = { Name = "Blox Fruit", IsVVIP = false, URL = "https://raw.githubusercontent.com/payomboyz333/PAY-MB-YZ-HUB/refs/heads/main/Blox%20Fruit-obfuscated.lua" },
    [7449423635] = { Name = "Blox Fruit", IsVVIP = false, URL = "https://raw.githubusercontent.com/payomboyz333/PAY-MB-YZ-HUB/refs/heads/main/Blox%20Fruit-obfuscated.lua" },
    [85211729168715] = { Name = "Blox Fruit", IsVVIP = false, URL = "https://raw.githubusercontent.com/payomboyz333/PAY-MB-YZ-HUB/refs/heads/main/Blox%20Fruit-obfuscated.lua" },
    [100117331123099] = { Name = "Blox Fruit", IsVVIP = false, URL = "https://raw.githubusercontent.com/payomboyz333/PAY-MB-YZ-HUB/refs/heads/main/Blox%20Fruit-obfuscated.lua" },
    [117539213094671] = { Name = "Roll a Gnome", IsVVIP = false, URL = "https://raw.githubusercontent.com/payomboyz333/PAY-MB-YZ-HUB/refs/heads/main/Roll%20a%20Gnome-obfuscated.lua" },
    [94640181989498] = { Name = "Chicken Fighter", IsVVIP = false, URL = "https://raw.githubusercontent.com/payomboyz333/PAY-MB-YZ-HUB/refs/heads/main/Grow%20a%20Chicken%20Fighter-obfuscated.lua" },
    [94939256104840] = { Name = "Chicken Fighter", IsVVIP = false, URL = "https://raw.githubusercontent.com/payomboyz333/PAY-MB-YZ-HUB/refs/heads/main/Grow%20a%20Chicken%20Fighter-obfuscated.lua" },
    [126884695634066] = { Name = "Grow a Garden 1", IsVVIP = false, URL = "https://raw.githubusercontent.com/Payomboyz0028/Yaranikaaaa/refs/heads/main/GGAGG" },
    [97598239454123] = { Name = "Grow a Garden 2", IsVVIP = false, URL = "https://raw.githubusercontent.com/payomboyz333/PAY-MB-YZ-HUB/refs/heads/main/Grow%20a%20garden%202-obfuscated.lua" },
    [120945553785140] = { Name = "Grow a Garden 2", IsVVIP = false, URL = "https://raw.githubusercontent.com/payomboyz333/PAY-MB-YZ-HUB/refs/heads/main/Grow%20a%20garden%202-obfuscated.lua" },
    [74102906764176] = { Name = "Greedy Grower", IsVVIP = false, URL = "https://raw.githubusercontent.com/payomboyz333/PAY-MB-YZ-HUB/refs/heads/main/Greedy%20Grower-obfuscated.lua" },
    [111907389166979] = { Name = "Greedy Grower", IsVVIP = false, URL = "https://raw.githubusercontent.com/payomboyz333/PAY-MB-YZ-HUB/refs/heads/main/Greedy%20Grower-obfuscated.lua" },
    [131587836213405] = { Name = "Greedy Grower", IsVVIP = false, URL = "https://raw.githubusercontent.com/payomboyz333/PAY-MB-YZ-HUB/refs/heads/main/Greedy%20Grower-obfuscated.lua" },
    [124216119978534] = { Name = "Ride a Pet", IsVVIP = false, URL = "https://raw.githubusercontent.com/payomboyz333/PAY-MB-YZ-HUB/refs/heads/main/Ride%20a%20pet-obfuscated.lua" },
    [76377501906469] = { Name = "Steal An Anime EGG!", IsVVIP = false, URL = "https://raw.githubusercontent.com/payomboyz333/PAY-MB-YZ-HUB/refs/heads/main/Steal%20Anime%20Egg-obfuscated.lua" },
    [135618011146990] = { Name = "Steal An Anime EGG!", IsVVIP = false, URL = "https://raw.githubusercontent.com/payomboyz333/PAY-MB-YZ-HUB/refs/heads/main/Steal%20Anime%20Egg-obfuscated.lua" },
    [16732694052] = { Name = "FISCH", IsVVIP = false, URL = "https://raw.githubusercontent.com/payomboyz333/PAY-MB-YZ-HUB/refs/heads/main/FISCH-obfuscated.lua" },
    [72907489978215] = { Name = "FISCH", IsVVIP = false, URL = "https://raw.githubusercontent.com/payomboyz333/PAY-MB-YZ-HUB/refs/heads/main/FISCH-obfuscated.lua" },
    [17722839796] = { Name = "FISCH", IsVVIP = false, URL = "https://raw.githubusercontent.com/payomboyz333/PAY-MB-YZ-HUB/refs/heads/main/FISCH-obfuscated.lua" },
    [9794412726] = { Name = "FISCH", IsVVIP = false, URL = "https://raw.githubusercontent.com/payomboyz333/PAY-MB-YZ-HUB/refs/heads/main/FISCH-obfuscated.lua" },
    [131716211654599] = { Name = "FISCH", IsVVIP = false, URL = "https://raw.githubusercontent.com/payomboyz333/PAY-MB-YZ-HUB/refs/heads/main/FISCH-obfuscated.lua" },

    -- 👑 แมพ VVIP
    [16205713724] = { Name = "Slayers 2", IsVVIP = true, URL = "https://raw.githubusercontent.com/payomboyz333/PAY-MB-YZ-HUB/refs/heads/main/slayer2-obfuscated.lua" },
    [136406881576517] = { Name = "Slayers 2", IsVVIP = true, URL = "https://raw.githubusercontent.com/payomboyz333/PAY-MB-YZ-HUB/refs/heads/main/slayer2-obfuscated.lua" },
    [75556147183481] = { Name = "Slayers 2", IsVVIP = true, URL = "https://raw.githubusercontent.com/payomboyz333/PAY-MB-YZ-HUB/refs/heads/main/slayer2-obfuscated.lua" },
    [125927821145949] = { Name = "Mine a Mountain", IsVVIP = true, URL = "https://raw.githubusercontent.com/payomboyz333/PAY-MB-YZ-HUB/refs/heads/main/Mine%20a%20Mountain-obfuscated.lua" },
    [142823291] = { Name = "Murder Mystery 2", IsVVIP = true, URL = "https://raw.githubusercontent.com/payomboyz333/PAY-MB-YZ-HUB/refs/heads/main/Master%20Mystery%202-obfuscated.lua" },
    [107653945083776] = { Name = "Roll Anime To Fight", IsVVIP = true, URL = "https://raw.githubusercontent.com/payomboyz333/PAY-MB-YZ-HUB/refs/heads/main/Roll%20Anime%20to%20FIGHT-obfuscated.lua" },
    [133623616308412] = { Name = "Roll Anime To Fight", IsVVIP = true, URL = "https://raw.githubusercontent.com/payomboyz333/PAY-MB-YZ-HUB/refs/heads/main/Roll%20Anime%20to%20FIGHT-obfuscated.lua" },
    [107778070777162] = { Name = "Steal An Egg", IsVVIP = true, URL = "https://raw.githubusercontent.com/payomboyz333/PAY-MB-YZ-HUB/refs/heads/main/Steal%20An%20Egg-obfuscated.lua" },
    [106952885335586] = { Name = "Steal An Egg", IsVVIP = true, URL = "https://raw.githubusercontent.com/payomboyz333/PAY-MB-YZ-HUB/refs/heads/main/Steal%20An%20Egg-obfuscated.lua" },
    [84515722934860] = { Name = "Anime Expedition", IsVVIP = true, URL = "https://raw.githubusercontent.com/payomboyz333/PAY-MB-YZ-HUB/refs/heads/main/Aneme%20Expredition-obfuscated.lua" },

    -- ⚔️ Dungeon Lootr
    [106484206883664] = { Name = "Dungeon Lootr", IsVVIP = false, URL = "https://raw.githubusercontent.com/payomboyz333/PAY-MB-YZ-HUB/refs/heads/main/DungeonLootr-obfuscated.lua" },
    [132285059959516] = { Name = "Dungeon Lootr", IsVVIP = false, URL = "https://raw.githubusercontent.com/payomboyz333/PAY-MB-YZ-HUB/refs/heads/main/DungeonLootr-obfuscated.lua" },
    [129976314326660] = { Name = "Dungeon Lootr", IsVVIP = false, URL = "https://raw.githubusercontent.com/payomboyz333/PAY-MB-YZ-HUB/refs/heads/main/DungeonLootr-obfuscated.lua" },

    -- 🔨 +1 Loot a Forge
    [118805555015549] = { Name = "+1 Loot a Forge", IsVVIP = false, URL = "https://raw.githubusercontent.com/payomboyz333/PAY-MB-YZ-HUB/refs/heads/main/%2B1%20Loot%20a%20Forge" },
    [10684750879] = { Name = "+1 Loot a Forge", IsVVIP = false, URL = "https://raw.githubusercontent.com/payomboyz333/PAY-MB-YZ-HUB/refs/heads/main/%2B1%20Loot%20a%20Forge" },
}

local SupportedUniverses = {
    [9656201728] = { Name = "Dungeon Lootr", IsVVIP = false, URL = "https://raw.githubusercontent.com/payomboyz333/PAY-MB-YZ-HUB/refs/heads/main/DungeonLootr-obfuscated.lua" },
    [4658598196] = { Name = "Attack On Titan Revolution", IsVVIP = false, URL = "https://raw.githubusercontent.com/payomboyz333/PAY-MB-YZ-HUB/refs/heads/main/AOTR-obfuscated.lua" },
    [9534705677] = { Name = "Arena Sniper", IsVVIP = false, URL = "https://raw.githubusercontent.com/payomboyz333/PAY-MB-YZ-HUB/refs/heads/main/Sniper%20Arena-obfuscated.lua" },
    [7326934954] = { Name = "99 Nights", IsVVIP = false, URL = "https://raw.githubusercontent.com/payomboyz333/PAY-MB-YZ-HUB/refs/heads/main/99Night-obfuscated.lua" },
    [994732206] = { Name = "Blox Fruit", IsVVIP = false, URL = "https://raw.githubusercontent.com/payomboyz333/PAY-MB-YZ-HUB/refs/heads/main/Blox%20Fruit-obfuscated.lua" },
    [5750914919] = { Name = "FISCH", IsVVIP = false, URL = "https://raw.githubusercontent.com/payomboyz333/PAY-MB-YZ-HUB/refs/heads/main/FISCH-obfuscated.lua" },
    [5595353122] = { Name = "Slayers 2", IsVVIP = true, URL = "https://raw.githubusercontent.com/payomboyz333/PAY-MB-YZ-HUB/refs/heads/main/slayer2-obfuscated.lua" },
    [9199655655] = { Name = "Gakuran", IsVVIP = false, URL = "https://raw.githubusercontent.com/payomboyz333/PAY-MB-YZ-HUB/refs/heads/main/Gakurun-obfuscated.lua" },
    [6606806742] = { Name = "Anime Expedition", IsVVIP = true, URL = "https://raw.githubusercontent.com/payomboyz333/PAY-MB-YZ-HUB/refs/heads/main/Aneme%20Expredition-obfuscated.lua" },
}

setmetatable(SupportedGames, {
    __index = function(tbl, key)
        if typeof(key) == "number" then
            local uData = SupportedUniverses and (SupportedUniverses[game.GameId] or SupportedUniverses[key])
            if uData then return uData end
        end
        return nil
    end
})

local function resolveGameName()
    local placeId = game.PlaceId
    local gameData = SupportedGames[placeId]
    if gameData and gameData.Name then
        return gameData.Name .. (gameData.IsVVIP and " (VVIP)" or "")
    end
    return "Place: " .. tostring(placeId)
end

-- ==============================================================================
-- 🔑 KEY MANAGEMENT & SYSTEM CALLS
-- ==============================================================================
local function ClearSavedKeys()
    pcall(function()
        local filesToDelete = {
            HubConfig.SavedKeyFile,
            "PayomboyZ_LuarmorKey.txt",
            "PayomboyZ_VVIPKey.txt",
            "PayomboyZ_SavedKey.txt"
        }
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
            getgenv().PayomboyZ_UserKey = nil
        end
        _G.script_key = nil
        _G.PayomboyZ_UserKey = nil
        script_key = nil
    end)
end

local function LoadSavedKey()
    local saved = ""
    pcall(function()
        if isfile and readfile then
            if isfile(HubConfig.SavedKeyFile) then
                saved = readfile(HubConfig.SavedKeyFile)
            elseif isfile("PayomboyZ_VVIPKey.txt") then
                saved = readfile("PayomboyZ_VVIPKey.txt")
            elseif isfile("PayomboyZ_LuarmorKey.txt") then
                saved = readfile("PayomboyZ_LuarmorKey.txt")
            end
        end
    end)
    if type(saved) == "string" then
        return saved:gsub("%s+", "")
    end
    return ""
end

local function GetPassedScriptKey()
    local key = nil
    pcall(function()
        local candidates = {
            getgenv and getgenv().PayomboyZ_UserKey,
            getgenv and getgenv().PayomboyZ_InputKey,
            getgenv and getgenv().script_key,
            script_key,
            _G and _G.script_key,
            _G and _G.PayomboyZ_UserKey
        }
        for _, k in ipairs(candidates) do
            if type(k) == "string" and k ~= "" then
                key = k
                break
            end
        end
    end)
    if key and type(key) == "string" then
        return key:gsub("%s+", "")
    end
    return ""
end

local function SaveKey(userKey)
    if not userKey or userKey == "" then return end
    userKey = userKey:gsub("%s+", "")
    pcall(function()
        if writefile then
            writefile(HubConfig.SavedKeyFile, userKey)
            writefile("PayomboyZ_VVIPKey.txt", userKey)
            writefile("PayomboyZ_LuarmorKey.txt", userKey)
        end
    end)
end

local function copyText(value)
    local copier = setclipboard or toclipboard or set_clipboard or (Clipboard and Clipboard.set)
    if type(copier) ~= "function" then return false end
    return pcall(copier, tostring(value))
end

local function executorName()
    local name = nil
    local version = nil

    local function tryCall(getter)
        if typeof(getter) == "function" then
            local ok, n, v = pcall(getter)
            if ok and n and type(n) == "string" and #n > 0 and n:lower() ~= "unknown" then
                return n, (type(v) == "string" and #v > 0) and v or nil
            end
        elseif typeof(getter) == "string" and #getter > 0 and getter:lower() ~= "unknown" then
            return getter, nil
        end
        return nil, nil
    end

    if not name then name, version = tryCall(identifyexecutor or (getgenv and getgenv().identifyexecutor)) end
    if not name then name, version = tryCall(getexecutorname or (getgenv and getgenv().getexecutorname)) end
    if not name then name, version = tryCall(whatexecutor or (getgenv and getgenv().whatexecutor)) end

    if not name then
        if typeof(is_sirhurt_closure) == "function" then name = "SirHurt"
        elseif typeof(is_synapse_function) == "function" then name = "Synapse"
        elseif typeof(is_krnl_closure) == "function" then name = "KRNL"
        elseif typeof(is_fluxus_closure) == "function" then name = "Fluxus"
        elseif typeof(is_solara_closure) == "function" then name = "Solara"
        elseif typeof(is_wave_closure) == "function" then name = "Wave"
        elseif typeof(is_xeno_closure) == "function" or typeof(isxenoclosure) == "function" then name = "Xeno"
        end
    end

    if not name then
        local g = (getgenv and getgenv()) or {}
        local s = shared or {}
        local function checkFlag(k) return g[k] ~= nil or _G[k] ~= nil or s[k] ~= nil end
        if checkFlag("XENO") or checkFlag("xeno") or checkFlag("XENO_LOADED") then name = "Xeno"
        elseif checkFlag("DELTA_LOADED") or checkFlag("Delta") then name = "Delta"
        elseif checkFlag("CODEX_LOADED") or checkFlag("Codex") then name = "Codex"
        elseif checkFlag("ARCEUS_LOADED") or checkFlag("Arceus") then name = "Arceus X"
        elseif checkFlag("WAVE_LOADED") or checkFlag("Wave") then name = "Wave"
        elseif checkFlag("SOLARA_LOADED") or checkFlag("Solara") then name = "Solara"
        elseif checkFlag("REAL") or checkFlag("Real") then name = "Real"
        end
    end

    name = name or "Real"
    if version and #version > 0 and not name:find(version, 1, true) then
        return name .. " / " .. version
    end
    return name
end

local function isXenoExecutor()
    local name = tostring(executorName() or ""):lower()
    return name:find("xeno") ~= nil
end

local function deviceName()
    local uis = game:GetService("UserInputService")
    if uis.TouchEnabled and not uis.KeyboardEnabled then
        return "Mobile"
    end
    return "PC"
end

local function readableHwid()
    local providers = { gethwid, get_hwid }
    if syn and type(syn.gethwid) == "function" then table.insert(providers, syn.gethwid) end
    for _, provider in ipairs(providers) do
        if type(provider) == "function" then
            local ok, value = pcall(provider)
            if ok and value and tostring(value) ~= "" then return tostring(value) end
        end
    end
    local Players = game:GetService("Players")
    local lp = Players.LocalPlayer
    return "HWID-" .. tostring(lp and lp.UserId or "SECURED")
end

-- ==============================================================================
-- 🔐 DYNAMIC CRYPTOGRAPHIC TICKET ISSUER
-- ==============================================================================
local function PBZ_CreateAuthTicket()
    local players = game:GetService("Players")
    local p = players.LocalPlayer or players:GetPropertyChangedSignal("LocalPlayer"):Wait() or players.LocalPlayer
    local uId = p and p.UserId or 0
    local pId = game.PlaceId
    local gId = game.GameId
    local curTime = os.time()
    local curWin = math.floor(curTime / 180)
    local salt = "PBZ_AUTH_SECRET_SALT_2026_99X"

    local function _pbzHash(s)
        local h1, h2 = 5381, 2747636419
        for i = 1, #s do
            local b = string.byte(s, i)
            h1 = ((h1 * 33) + b) % 4294967296
            h2 = ((h2 * 31) + b + (h1 % 65536)) % 4294967296
        end
        return string.format("%08x%08x", h1, h2)
    end

    local payload = string.format("%d_%d_%d_%d", uId, pId, gId, curWin)
    local sig = _pbzHash(payload .. ":" .. salt)
    return string.format("PBZ_%s_%s", payload, sig)
end

-- ==============================================================================
-- 🚀 GAME SCRIPT LAUNCHER
-- ==============================================================================
local function RunGameScript(targetUrl, userKey, onFailCallback)
    if _isScriptLaunched then
        warn("[PAYOMBØYZ HUB] Game script is already launched.")
        return true
    end

    if userKey and userKey ~= "" then
        pcall(function()
            if getgenv then
                getgenv().script_key = userKey
                getgenv().PayomboyZ_UserKey = userKey
                getgenv().PayomboyZ_InputKey = userKey
            end
            _G.script_key = userKey
            _G.PayomboyZ_UserKey = userKey
            script_key = userKey
        end)
    end

    local fetchUrl = targetUrl
    if type(fetchUrl) == "string" and fetchUrl:find("raw.githubusercontent.com") and not fetchUrl:find("%?") then
        fetchUrl = fetchUrl .. "?t=" .. tostring(os.time())
    end

    local source = safeFetch(fetchUrl)
    if not source or #source < 50 or source:find("404: Not Found") then
        if type(onFailCallback) == "function" then onFailCallback("Download failed") end
        return false
    end

    local fn, compileErr = loadstring(source, "=PayomboyZ_Game")
    if not fn then
        if type(onFailCallback) == "function" then onFailCallback("Compile error: " .. tostring(compileErr)) end
        return false
    end

    _isScriptLaunched = true
    _isAuthenticating = false
    _ENV.__PAYOMBOYZ_SCRIPT_LAUNCHED = true

    -- Dismiss loader UI
    pcall(function()
        if _ENV.__PAYOMBOYZ_CURRENT_GUI and _ENV.__PAYOMBOYZ_CURRENT_GUI.Parent then
            _ENV.__PAYOMBOYZ_CURRENT_GUI:Destroy()
        end
        _ENV.__PAYOMBOYZ_CURRENT_GUI = nil
    end)

    task.spawn(function()
        local authTicket = PBZ_CreateAuthTicket()
        if _ENV then
            _ENV.__PAYOMBOYZ_AUTH_TICKET = authTicket
            _ENV.__PAYOMBOYZ_AUTH_TIME = os.time()
        end
        local runOk, runErr = pcall(fn, authTicket, userKey)
        if not runOk then
            _ENV.__PAYOMBOYZ_SCRIPT_LAUNCHED = false
            _isScriptLaunched = false
            warn("[PAYOMBØYZ HUB] Target script runtime error: " .. tostring(runErr))
        end
    end)

    return true
end

-- ==============================================================================
-- 🚀 TELEPORT / HOP SYSTEM
-- ==============================================================================
local function HopToPlace(placeId)
    local TeleportService = game:GetService("TeleportService")
    local Players = game:GetService("Players")
    local lp = Players.LocalPlayer

    task.spawn(function()
        local ok = false
        pcall(function() TeleportService:Teleport(placeId); ok = true end)
        if ok then return end
        task.wait(0.4)
        pcall(function()
            local opts = Instance.new("TeleportOptions")
            opts.ShouldReserveServer = false
            TeleportService:TeleportAsync(placeId, { lp }, opts)
            ok = true
        end)
        if ok then return end
        copyText(tostring(placeId))
    end)
end

-- ==============================================================================
-- 🖼️ BACKGROUND ASSET LOADER (upscaled_Blackground Sep 28, 2026.png)
-- ==============================================================================
local CustomBgAsset = nil
local function LoadBackgroundAsset()
    if CustomBgAsset then return CustomBgAsset end
    local getAsset = (typeof(getcustomasset) == "function" and getcustomasset)
                  or (typeof(getsynasset) == "function" and getsynasset)

    local localPaths = {
        HubConfig.BgFileName,
        "ScriptHub/" .. HubConfig.BgFileName,
        "Library/" .. HubConfig.BgFileName,
        "PayomboyZ-UI/" .. HubConfig.BgFileName
    }

    if isfile and getAsset then
        for _, path in ipairs(localPaths) do
            if isfile(path) then
                local ok, asset = pcall(getAsset, path)
                if ok and asset then
                    CustomBgAsset = asset
                    return CustomBgAsset
                end
            end
        end
    end

    if not CustomBgAsset and writefile and getAsset then
        pcall(function()
            local raw = safeFetch(HubConfig.BgRawURL)
            if raw and #raw > 5000 then
                writefile(HubConfig.BgFileName, raw)
                if isfile and isfile(HubConfig.BgFileName) then
                    CustomBgAsset = getAsset(HubConfig.BgFileName)
                end
            end
        end)
    end

    return CustomBgAsset
end

local CustomLogoAsset = nil
local function LoadLogoAsset()
    if CustomLogoAsset then return CustomLogoAsset end
    local getAsset = (typeof(getcustomasset) == "function" and getcustomasset)
                  or (typeof(getsynasset) == "function" and getsynasset)

    local localPaths = {
        HubConfig.LogoFileName,
        "LogoPayomboyZ.png",
        "ScriptHub/LogoPayomboyZ.png",
        "Library/LogoPayomboyZ.png",
        "PayomboyZ_Logo.jpg"
    }

    if isfile and getAsset then
        for _, path in ipairs(localPaths) do
            if isfile(path) then
                local ok, asset = pcall(getAsset, path)
                if ok and asset then
                    CustomLogoAsset = asset
                    return CustomLogoAsset
                end
            end
        end
    end

    if not CustomLogoAsset and writefile and getAsset then
        pcall(function()
            local raw = safeFetch(HubConfig.LogoURL)
            if raw and #raw > 1000 then
                writefile(HubConfig.LogoFileName, raw)
                if isfile and isfile(HubConfig.LogoFileName) then
                    CustomLogoAsset = getAsset(HubConfig.LogoFileName)
                end
            end
        end)
    end

    if not CustomLogoAsset then
        CustomLogoAsset = "rbxassetid://10723346959"
    end
    return CustomLogoAsset
end

-- ==============================================================================
-- 🎨 DESIGN TOKENS (ui (2).lua Standard + Manga Comic Flare)
-- ==============================================================================
local PRIMARY_COLOR = Color3.fromRGB(220, 38, 58)    -- PayomboyZ Signature Crimson Red
local PRIMARY_HOVER = Color3.fromRGB(242, 54, 76)
local PRIMARY_PRESSED = Color3.fromRGB(175, 22, 42)

local COLORS = {
    backdrop         = Color3.fromRGB(6, 1, 3),
    shell            = Color3.fromRGB(14, 4, 8),
    shellStroke      = Color3.fromRGB(255, 30, 60),
    glass            = Color3.fromRGB(20, 6, 12),
    glassDeep        = Color3.fromRGB(12, 3, 7),
    glassRaised      = Color3.fromRGB(34, 10, 18),
    surface          = Color3.fromRGB(26, 7, 14),
    surfaceRaised    = Color3.fromRGB(44, 11, 22),
    surfaceHover     = Color3.fromRGB(68, 16, 32),
    surfacePressed   = Color3.fromRGB(20, 5, 10),
    input            = Color3.fromRGB(14, 4, 8),
    inputFocus       = Color3.fromRGB(28, 7, 14),
    divider          = Color3.fromRGB(140, 20, 45),
    primary          = PRIMARY_COLOR,
    primaryHover     = PRIMARY_HOVER,
    primaryPressed   = PRIMARY_PRESSED,
    secondary        = Color3.fromRGB(38, 10, 18),
    secondaryHover   = Color3.fromRGB(56, 15, 26),
    secondaryPressed = Color3.fromRGB(24, 6, 12),
    text             = Color3.fromRGB(255, 255, 255),
    textMuted        = Color3.fromRGB(240, 195, 208),
    textFaint        = Color3.fromRGB(180, 125, 140),
    cyan             = Color3.fromRGB(255, 35, 70),
    lightningCore    = Color3.fromRGB(255, 230, 240),
    lightningGlow    = Color3.fromRGB(255, 25, 60),
    success          = Color3.fromRGB(46, 224, 140),
    warning          = Color3.fromRGB(255, 185, 70),
    danger           = Color3.fromRGB(255, 45, 65),
    premiumAction    = Color3.fromRGB(255, 24, 62),
    premiumHover     = Color3.fromRGB(255, 65, 98),
    premiumPressed   = Color3.fromRGB(185, 14, 38),
    disabled         = Color3.fromRGB(40, 12, 18),
}

local MOTION = {
    quick  = 0.14,
    normal = 0.24,
    slow   = 0.36,
}

local LUCIDE = {
    user           = { image = "rbxassetid://16898613869", size = Vector2.new(48, 48), offset = Vector2.new(661, 869) },
    settings       = { image = "rbxassetid://16898613777", size = Vector2.new(48, 48), offset = Vector2.new(771, 257) },
    shield         = { image = "rbxassetid://16898613777", size = Vector2.new(48, 48), offset = Vector2.new(869, 0) },
    globe          = { image = "rbxassetid://16898613509", size = Vector2.new(48, 48), offset = Vector2.new(771, 563) },
    minus          = { image = "rbxassetid://7734000129" },
    x              = { image = "rbxassetid://7743878857" },
    key            = { image = "rbxassetid://7733965118" },
    ["shield-check"] = { image = "rbxassetid://7734056411" },
    ["message-circle"] = { image = "rbxassetid://7733993311" },
    copy           = { image = "rbxassetid://7733764083" },
    monitor        = { image = "rbxassetid://7734002839" },
    smartphone     = { image = "rbxassetid://7734058979" },
    gamepad        = { image = "rbxassetid://7733799901" },
    clock          = { image = "rbxassetid://7733734848" },
    wifi           = { image = "rbxassetid://7743878148" },
    ["external-link"] = { image = "rbxassetid://7743866903" },
    ["alert-circle"] = { image = "rbxassetid://7733658271" },
    ["check-circle"] = { image = "rbxassetid://7733919427" },
    info           = { image = "rbxassetid://7733964719" },
    trash          = { image = "rbxassetid://7743878358" },
}

local function applyFont(label, weight)
    pcall(function()
        label.FontFace = Font.fromName("Montserrat", weight or Enum.FontWeight.Regular, Enum.FontStyle.Normal)
    end)
    if not label.FontFace or label.FontFace.Family == "" then
        label.Font = (weight == Enum.FontWeight.Bold) and Enum.Font.GothamBold or Enum.Font.Gotham
    end
end

local function getParentGui()
    if typeof(gethui) == "function" then
        local ok, res = pcall(gethui)
        if ok and res and typeof(res) == "Instance" then return res end
    end
    if typeof(cloneref) == "function" then
        local ok, cg = pcall(function() return cloneref(game:GetService("CoreGui")) end)
        if ok and cg then return cg end
    end
    local ok, cg = pcall(function() return game:GetService("CoreGui") end)
    if ok and cg then return cg end
    local Players = game:GetService("Players")
    local lp = Players.LocalPlayer or Players:GetPropertyChangedSignal("LocalPlayer"):Wait() or Players.LocalPlayer
    return lp:FindFirstChildOfClass("PlayerGui") or lp:WaitForChild("PlayerGui", 5)
end

-- ==============================================================================
-- 📢 TOAST NOTIFICATION SYSTEM
-- ==============================================================================
local function ShowToast(title, message, isError)
    pcall(function()
        local parentGui = getParentGui()
        if parentGui then
            local existing = parentGui:FindFirstChild("PayomboyZ_ToastUI")
            if existing then existing:Destroy() end
        end

        local ToastGui = Instance.new("ScreenGui")
        ToastGui.Name = "PayomboyZ_ToastUI"
        ToastGui.ResetOnSpawn = false
        ToastGui.DisplayOrder = 100010
        ToastGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

        local pOk = pcall(function() ToastGui.Parent = parentGui end)
        if not pOk then
            local Players = game:GetService("Players")
            local lp = Players.LocalPlayer
            ToastGui.Parent = lp and lp:FindFirstChildOfClass("PlayerGui")
        end

        local Frame = Instance.new("Frame")
        Frame.Size = UDim2.new(0, 330, 0, 62)
        Frame.Position = UDim2.new(1, -350, 0, 24)
        Frame.BackgroundColor3 = Color3.fromRGB(22, 6, 12)
        Frame.BorderSizePixel = 0
        Frame.Parent = ToastGui

        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = UDim.new(0, 10)
        Corner.Parent = Frame

        local Stroke = Instance.new("UIStroke")
        Stroke.Color = isError and Color3.fromRGB(255, 60, 60) or PRIMARY_COLOR
        Stroke.Transparency = 0.2
        Stroke.Thickness = 1.5
        Stroke.Parent = Frame

        local TText = Instance.new("TextLabel")
        TText.Size = UDim2.new(1, -48, 0, 20)
        TText.Position = UDim2.new(0, 12, 0, 8)
        TText.BackgroundTransparency = 1
        TText.Text = title
        TText.TextColor3 = isError and Color3.fromRGB(255, 75, 75) or PRIMARY_COLOR
        TText.TextSize = 13
        TText.TextXAlignment = Enum.TextXAlignment.Left
        applyFont(TText, Enum.FontWeight.Bold)
        TText.Parent = Frame

        local MText = Instance.new("TextLabel")
        MText.Size = UDim2.new(1, -48, 0, 24)
        MText.Position = UDim2.new(0, 12, 0, 30)
        MText.BackgroundTransparency = 1
        MText.Text = message
        MText.TextColor3 = Color3.fromRGB(240, 215, 225)
        MText.TextSize = 11
        MText.TextXAlignment = Enum.TextXAlignment.Left
        applyFont(MText, Enum.FontWeight.Regular)
        MText.Parent = Frame

        local CloseBtn = Instance.new("TextButton")
        CloseBtn.Size = UDim2.fromOffset(20, 20)
        CloseBtn.Position = UDim2.new(1, -26, 0, 8)
        CloseBtn.BackgroundTransparency = 1
        CloseBtn.Text = "×"
        CloseBtn.TextColor3 = Color3.fromRGB(200, 160, 175)
        CloseBtn.TextSize = 14
        CloseBtn.Font = Enum.Font.GothamBold
        CloseBtn.ZIndex = 10
        CloseBtn.Parent = Frame

        local dismissed = false
        local function dismiss()
            if dismissed then return end
            dismissed = true
            if ToastGui and ToastGui.Parent then
                pcall(function() ToastGui:Destroy() end)
            end
        end

        CloseBtn.MouseButton1Click:Connect(dismiss)
        CloseBtn.Activated:Connect(dismiss)
        task.delay(3.5, dismiss)
        task.delay(5.0, function()
            if ToastGui and ToastGui.Parent then pcall(function() ToastGui:Destroy() end) end
        end)
    end)
end

-- ==============================================================================
-- ⚡ CRIMSON LIGHTNING & PARTICLES LOADER UI GENERATOR
-- ==============================================================================
local function CreateLoaderUI(initialStatus, defaultKeyText)
    if _ENV.__PAYOMBOYZ_SCRIPT_LAUNCHED or _isScriptLaunched then
        warn("[PAYOMBØYZ HUB] Target script is already running, suppressing CreateLoaderUI.")
        return
    end

    local parentGui = getParentGui()

    pcall(function()
        if parentGui then
            for _, child in ipairs(parentGui:GetChildren()) do
                if child:IsA("ScreenGui") and (child.Name == "PayomboyZ_LoaderUI" or child.Name == "RobloxLoaderGui" or child.Name == "PayomboyZ_ToastLayer" or child.Name == "PayomboyZ_ToastUI") then
                    child:Destroy()
                end
            end
        end
    end)

    local gui = Instance.new("ScreenGui")
    gui.Name = "PayomboyZ_LoaderUI"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.DisplayOrder = 99999

    local parentOk = pcall(function() gui.Parent = parentGui end)
    if not parentOk then
        local Players = game:GetService("Players")
        local lp = Players.LocalPlayer
        gui.Parent = lp:FindFirstChildOfClass("PlayerGui") or lp:WaitForChild("PlayerGui", 5)
    end
    _ENV.__PAYOMBOYZ_CURRENT_GUI = gui

    local TweenService = game:GetService("TweenService")
    local UserInputService = game:GetService("UserInputService")
    local RunService = game:GetService("RunService")
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer or Players:GetPropertyChangedSignal("LocalPlayer"):Wait() or Players.LocalPlayer

    local DESKTOP_WIDTH = 930
    local COMPACT_WIDTH = 644
    local SHELL_HEIGHT = 620

    local trackedConnections = {}
    local trackedThreads = {}
    local activeTweens = setmetatable({}, { __mode = "k" })

    local clickSound = nil
    pcall(function()
        clickSound = Instance.new("Sound")
        clickSound.Name = "PayomboyZClick"
        clickSound.SoundId = "rbxassetid://6895079853"
        clickSound.Volume = 0.38
        clickSound.PlaybackSpeed = 1
        clickSound.Looped = false
        clickSound.Parent = gui
    end)

    local function playClickSound()
        pcall(function()
            if clickSound then
                clickSound.TimePosition = 0
                clickSound:Play()
            end
        end)
    end

    local function create(className, properties, targetParent)
        local object = Instance.new(className)
        for key, value in pairs(properties or {}) do
            object[key] = value
        end
        object.Parent = targetParent
        return object
    end

    local function round(object, radius)
        return create("UICorner", { CornerRadius = UDim.new(0, radius or 10) }, object)
    end

    local function applyLucideData(icon, iconName)
        local data = LUCIDE[iconName] or LUCIDE.info
        icon.Image = data.image
        if data.offset and data.size then
            icon.ImageRectOffset = data.offset
            icon.ImageRectSize = data.size
        else
            icon.ImageRectOffset = Vector2.new(0, 0)
            icon.ImageRectSize = Vector2.new(0, 0)
        end
    end

    local function lucideIcon(parentObject, iconName, position, size, color, zIndex)
        local icon = create("ImageLabel", {
            Name = "LucideIcon",
            BackgroundTransparency = 1,
            Position = position,
            Size = size,
            ImageColor3 = color or COLORS.textMuted,
            ScaleType = Enum.ScaleType.Fit,
            ZIndex = zIndex or 4,
        }, parentObject)
        applyLucideData(icon, iconName)
        return icon
    end

    local function playTween(object, duration, properties, easingStyle, easingDirection, channel)
        local bucket = activeTweens[object]
        if not bucket then
            bucket = {}
            activeTweens[object] = bucket
        end
        local key = channel or "default"
        local previous = bucket[key]
        if previous then previous:Cancel() end
        local tween = TweenService:Create(
            object,
            TweenInfo.new(
                duration,
                easingStyle or Enum.EasingStyle.Quint,
                easingDirection or Enum.EasingDirection.Out
            ),
            properties
        )
        bucket[key] = tween
        tween.Completed:Connect(function()
            if bucket[key] == tween then
                bucket[key] = nil
            end
        end)
        tween:Play()
        return tween
    end

    local function textLabel(parentObject, text, position, size, fontWeight, textSize, color, alignment)
        local label = create("TextLabel", {
            BackgroundTransparency = 1,
            Position = position,
            Size = size,
            Text = text,
            TextColor3 = color or COLORS.text,
            TextSize = textSize or 12,
            TextXAlignment = alignment or Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Center,
            TextTruncate = Enum.TextTruncate.AtEnd,
        }, parentObject)
        applyFont(label, fontWeight or Enum.FontWeight.Regular)
        return label
    end

    local function bindButtonMotion(button, baseColor, hoverColor, pressedColor)
        local scale = button:FindFirstChildOfClass("UIScale")
        local function animate(color, value)
            if button:GetAttribute("MotionDisabled") then return end
            playTween(button, MOTION.quick, { BackgroundColor3 = color })
            if scale then playTween(scale, MOTION.quick, { Scale = value }) end
        end

        button.MouseEnter:Connect(function() animate(hoverColor, 1.015) end)
        button.MouseLeave:Connect(function() animate(baseColor, 1) end)
        button.MouseButton1Down:Connect(function() animate(pressedColor, 0.975) end)
        button.MouseButton1Up:Connect(function() animate(hoverColor, 1.01) end)
    end

    local function makeButton(parentObject, name, text, position, size, baseColor, hoverColor, pressedColor, iconName)
        local button = create("TextButton", {
            Name = name,
            Position = position,
            Size = size,
            BackgroundColor3 = baseColor,
            BorderSizePixel = 0,
            AutoButtonColor = false,
            Active = true,
            Text = "",
            TextColor3 = COLORS.text,
        }, parentObject)
        round(button, 10)
        create("UIScale", { Scale = 1 }, button)

        local content = create("Frame", {
            Name = "ButtonContent",
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromOffset(0, 18),
            AutomaticSize = Enum.AutomaticSize.X,
            BackgroundTransparency = 1,
            ZIndex = 5,
        }, button)
        create("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Padding = UDim.new(0, iconName and 8 or 0),
            SortOrder = Enum.SortOrder.LayoutOrder,
        }, content)
        if iconName then
            local icon = lucideIcon(content, iconName, UDim2.new(), UDim2.fromOffset(16, 16), COLORS.text, 5)
            icon.LayoutOrder = 1
            icon.ImageTransparency = 0.08
        end
        local label = textLabel(content, text, UDim2.new(), UDim2.fromOffset(0, 18), Enum.FontWeight.Bold, 12, COLORS.text, Enum.TextXAlignment.Center)
        label.Name = "ButtonLabel"
        label.AutomaticSize = Enum.AutomaticSize.X
        label.LayoutOrder = 2
        label.TextTruncate = Enum.TextTruncate.None
        label.ZIndex = 5

        bindButtonMotion(button, baseColor, hoverColor or COLORS.surfaceHover, pressedColor or COLORS.surfacePressed)
        button.Activated:Connect(function()
            if button.Active and not button:GetAttribute("MotionDisabled") then
                playClickSound()
            end
        end)
        return button
    end

    local function setButtonText(button, value)
        local label = button:FindFirstChild("ButtonLabel", true)
        if label then label.Text = tostring(value or "") end
    end

    local function setButtonTextSize(button, value)
        local label = button:FindFirstChild("ButtonLabel", true)
        if label then label.TextSize = value end
    end

    local function makeIconButton(parentObject, name, iconName, position, baseColor, hoverColor, pressedColor)
        local button = create("ImageButton", {
            Name = name,
            Position = position,
            Size = UDim2.fromOffset(32, 32),
            BackgroundColor3 = baseColor,
            BackgroundTransparency = 0.18,
            BorderSizePixel = 0,
            AutoButtonColor = false,
            Active = true,
            Image = "",
        }, parentObject)
        round(button, 8)
        create("UIScale", { Scale = 1 }, button)
        lucideIcon(button, iconName, UDim2.fromOffset(8, 8), UDim2.fromOffset(16, 16), COLORS.textMuted, 5)
        bindButtonMotion(button, baseColor, hoverColor, pressedColor)
        button.Activated:Connect(function()
            if button.Active and not button:GetAttribute("MotionDisabled") then
                playClickSound()
            end
        end)
        return button
    end

    local function setButtonEnabled(button, enabled)
        button.Active = enabled
        button:SetAttribute("MotionDisabled", not enabled)
        playTween(button, MOTION.quick, {
            BackgroundColor3 = enabled and PRIMARY_COLOR or COLORS.disabled,
        })
        local label = button:FindFirstChild("ButtonLabel", true)
        if label then playTween(label, MOTION.quick, { TextTransparency = enabled and 0 or 0.28 }) end
        local icon = button:FindFirstChild("LucideIcon", true)
        if icon then playTween(icon, MOTION.quick, { ImageTransparency = enabled and 0.08 or 0.45 }) end
    end

    -- ==============================================================================
    -- 🌌 BACKDROP & SHELL MODAL CONTAINER
    -- ==============================================================================
    local backdrop = create("Frame", {
        Name = "Backdrop",
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = COLORS.backdrop,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
    }, gui)

    local shell = create("CanvasGroup", {
        Name = "Shell",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(DESKTOP_WIDTH, SHELL_HEIGHT),
        BackgroundTransparency = 1,
        GroupTransparency = 1,
    }, backdrop)
    local shellScale = create("UIScale", { Scale = 0.96 }, shell)

    local shellChrome = create("Frame", {
        Name = "Chrome",
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = COLORS.shell,
        BackgroundTransparency = 0.1,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        ZIndex = 2,
    }, shell)
    round(shellChrome, 18)

    local shellStroke = create("UIStroke", {
        Name = "ShellStroke",
        Color = PRIMARY_COLOR,
        Thickness = 1.8,
        Transparency = 0.15,
    }, shellChrome)

    create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 65, 95)),
            ColorSequenceKeypoint.new(0.5, PRIMARY_COLOR),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 15, 30)),
        }),
        Rotation = 35,
    }, shellStroke)

    -- ==============================================================================
    -- 🖼️ BACKGROUND ARTWORK (upscaled_Blackground Sep 28, 2026.png)
    -- ==============================================================================
    local bgImageLabel = create("ImageLabel", {
        Name = "MangaArtBackground",
        Size = UDim2.fromScale(1, 1),
        Position = UDim2.fromScale(0, 0),
        BackgroundTransparency = 1,
        ScaleType = Enum.ScaleType.Crop,
        ImageTransparency = 0.05,
        ZIndex = 1,
    }, shellChrome)
    round(bgImageLabel, 18)

    -- Subtle dark-tint overlay so text & controls remain readable while artwork pops vividly
    local bgOverlay = create("Frame", {
        Name = "GlassTintOverlay",
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Color3.fromRGB(10, 2, 6),
        BackgroundTransparency = 0.68,
        BorderSizePixel = 0,
        ZIndex = 2,
    }, shellChrome)
    round(bgOverlay, 18)

    create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(16, 4, 8)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(8, 2, 5)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(22, 5, 12)),
        }),
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.36),
            NumberSequenceKeypoint.new(1, 0.62),
        }),
        Rotation = 45,
    }, bgOverlay)

    task.spawn(function()
        local asset = LoadBackgroundAsset()
        if asset and bgImageLabel and bgImageLabel.Parent then
            bgImageLabel.Image = asset
        end
    end)

    -- ==============================================================================
    -- ⚡ AMBIENT PARTICLES & LIGHTNING ENGINE (ui (2).lua Standard)
    -- ==============================================================================
    local particleLayer = create("Frame", {
        Name = "ParticleSparksLayer",
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Active = false,
        ZIndex = 25,
    }, shellChrome)
    round(particleLayer, 18)

    task.spawn(function()
        local maxSparks = 22
        local sparks = {}
        local sparkColors = {
            Color3.fromRGB(220, 38, 58),
            Color3.fromRGB(240, 32, 54),
            Color3.fromRGB(195, 20, 42),
            Color3.fromRGB(255, 45, 70),
            Color3.fromRGB(165, 18, 38)
        }
        for i = 1, maxSparks do
            local sz = math.random(2, 4)
            local spark = create("Frame", {
                Name = "ParticleSpark",
                Size = UDim2.fromOffset(sz, sz),
                Position = UDim2.new(math.random(), 0, math.random(), 0),
                BackgroundColor3 = sparkColors[math.random(1, #sparkColors)],
                BackgroundTransparency = math.random(35, 68) / 100,
                BorderSizePixel = 0,
                Active = false,
                ZIndex = 26,
            }, particleLayer)
            round(spark, sz / 2)
            sparks[#sparks + 1] = {
                frame = spark,
                vx = math.random(-10, 10) / 10000,
                vy = math.random(16, 42) / 10000,
                pos = spark.Position.Y.Scale,
                seed = math.random() * 10,
            }
        end

        local pConn = RunService.Heartbeat:Connect(function()
            if not gui or not gui.Parent then return end
            if shell and shell.Visible then
                local t = os.clock()
                for _, data in ipairs(sparks) do
                    data.pos = data.pos - data.vy
                    if data.pos < -0.05 then data.pos = 1.05 end
                    local sway = math.sin(t * 1.8 + data.seed) * 0.0004
                    local newX = (data.frame.Position.X.Scale + data.vx + sway) % 1.0
                    data.frame.Position = UDim2.new(newX, 0, data.pos, 0)
                end
            end
        end)
        table.insert(trackedConnections, pConn)
    end)

    local lightningLayer = create("Frame", {
        Name = "LightningLayer",
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Active = false,
        ZIndex = 95,
    }, shellChrome)

    local flashOverlay = create("Frame", {
        Name = "LightningFlash",
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Color3.fromRGB(255, 45, 75),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Active = false,
        ZIndex = 94,
    }, shellChrome)
    round(flashOverlay, 18)

    local function strikeLightning(targetFrame, customStart, customEnd)
        targetFrame = targetFrame or lightningLayer
        if not targetFrame or not targetFrame.Parent then return end
        local w = math.max(targetFrame.AbsoluteSize.X, 400)
        local h = math.max(targetFrame.AbsoluteSize.Y, 300)

        local pA = customStart or Vector2.new(math.random(60, math.floor(w - 60)), math.random(6, 28))
        local pB = customEnd or Vector2.new(math.clamp(pA.X + math.random(-200, 200), 40, w - 40), math.random(math.floor(h * 0.45), math.floor(h * 0.95)))

        -- Recursive Midpoint Displacement for organic electric fractal path
        local function subdivide(pt1, pt2, depth, maxDisp)
            if depth <= 0 then
                return { pt1, pt2 }
            end
            local mid = (pt1 + pt2) / 2
            local dir = pt2 - pt1
            local normal = Vector2.new(-dir.Y, dir.X).Unit
            local offset = normal * ((math.random() - 0.5) * 2 * maxDisp)
            local displaced = mid + offset
            local left = subdivide(pt1, displaced, depth - 1, maxDisp * 0.58)
            local right = subdivide(displaced, pt2, depth - 1, maxDisp * 0.58)
            local result = {}
            for i = 1, #left - 1 do
                result[#result + 1] = left[i]
            end
            for i = 1, #right do
                result[#right + 1] = right[i]
            end
            return result
        end

        local mainPoints = subdivide(pA, pB, 4, 38)
        local branches = {}

        -- Optional 1-2 small lightning fork branches
        if #mainPoints >= 6 and math.random() > 0.35 then
            local branchIdx = math.random(3, math.max(4, #mainPoints - 3))
            local bStart = mainPoints[branchIdx]
            local dir = (mainPoints[branchIdx + 1] - bStart)
            local angle = math.rad(math.random(-35, 35))
            local cosA, sinA = math.cos(angle), math.sin(angle)
            local bDir = Vector2.new(dir.X * cosA - dir.Y * sinA, dir.X * sinA + dir.Y * cosA).Unit * math.random(40, 80)
            local bEnd = bStart + bDir
            branches[#branches + 1] = subdivide(bStart, bEnd, 2, 12)
        end

        local createdFrames = {}
        local function renderChain(points, isFork)
            for s = 1, #points - 1 do
                local p1, p2 = points[s], points[s + 1]
                local d = (p2 - p1).Magnitude
                if d > 0.5 then
                    local angle = math.deg(math.atan2(p2.Y - p1.Y, p2.X - p1.X))
                    local mid = (p1 + p2) / 2

                    -- Layer 1: Soft Outer Bloom Glow
                    local bloomW = isFork and 6 or 10
                    local glow = create("Frame", {
                        Size = UDim2.fromOffset(d + 4, bloomW),
                        Position = UDim2.fromOffset(mid.X - (d + 4) / 2, mid.Y - bloomW / 2),
                        Rotation = angle,
                        BackgroundColor3 = COLORS.lightningGlow,
                        BackgroundTransparency = isFork and 0.65 or 0.52,
                        BorderSizePixel = 0,
                        ZIndex = 96,
                    }, targetFrame)
                    round(glow, math.floor(bloomW / 2))
                    createdFrames[#createdFrames + 1] = glow

                    -- Layer 2: Intense Neon Arc
                    local arcW = isFork and 2.2 or 3.6
                    local arc = create("Frame", {
                        Size = UDim2.fromOffset(d + 2, arcW),
                        Position = UDim2.fromOffset(mid.X - (d + 2) / 2, mid.Y - arcW / 2),
                        Rotation = angle,
                        BackgroundColor3 = Color3.fromRGB(255, 35, 70),
                        BackgroundTransparency = 0.15,
                        BorderSizePixel = 0,
                        ZIndex = 97,
                    }, targetFrame)
                    round(arc, 2)
                    createdFrames[#createdFrames + 1] = arc

                    -- Layer 3: White Hot Electric Core Filament
                    local coreW = isFork and 1.1 or 1.6
                    local core = create("Frame", {
                        Size = UDim2.fromOffset(d, coreW),
                        Position = UDim2.fromOffset(mid.X - d / 2, mid.Y - coreW / 2),
                        Rotation = angle,
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        BackgroundTransparency = 0,
                        BorderSizePixel = 0,
                        ZIndex = 98,
                    }, targetFrame)
                    round(core, 1)
                    createdFrames[#createdFrames + 1] = core

                    -- Smooth Joint Node at Vertex
                    local jNode = create("Frame", {
                        Size = UDim2.fromOffset(bloomW, bloomW),
                        Position = UDim2.fromOffset(p1.X - bloomW / 2, p1.Y - bloomW / 2),
                        BackgroundColor3 = COLORS.lightningGlow,
                        BackgroundTransparency = 0.55,
                        BorderSizePixel = 0,
                        ZIndex = 96,
                    }, targetFrame)
                    round(jNode, bloomW / 2)
                    createdFrames[#createdFrames + 1] = jNode
                end
            end
        end

        renderChain(mainPoints, false)
        for _, bPoints in ipairs(branches) do
            renderChain(bPoints, true)
        end

        -- Subtle ambient flash
        if flashOverlay and flashOverlay.Parent then
            flashOverlay.BackgroundTransparency = 0.82
            playTween(flashOverlay, 0.08, { BackgroundTransparency = 1 })
        end

        -- Smooth decay tween
        task.delay(0.04, function()
            for _, f in ipairs(createdFrames) do
                if f and f.Parent then
                    playTween(f, 0.12, { BackgroundTransparency = 1 })
                end
            end
        end)
        task.delay(0.18, function()
            for _, f in ipairs(createdFrames) do
                if f and f.Parent then f:Destroy() end
            end
        end)
    end

    -- ⚡ Dynamic Ambient Lightning Strike Engine
    local lightningLoop = task.spawn(function()
        task.wait(0.5)
        pcall(function()
            if shell and shell.Visible then
                -- Initial cinematic strike slicing through the avatar column (matching reference drawing!)
                strikeLightning(lightningLayer, Vector2.new(150, 10), Vector2.new(65, 520))
            end
        end)

        while gui and gui.Parent do
            local delayTime = math.random(3, 6)
            task.wait(delayTime)
            if shell and shell.Visible then
                pcall(function()
                    local roll = math.random()
                    if roll < 0.45 then
                        -- Left column strike (Avatar / Stats)
                        strikeLightning(lightningLayer, Vector2.new(math.random(110, 190), math.random(5, 25)), Vector2.new(math.random(40, 140), math.random(420, 580)))
                    elseif roll < 0.80 then
                        -- Right panel / Header / Key box strike
                        strikeLightning(lightningLayer, Vector2.new(math.random(340, 680), math.random(5, 25)), Vector2.new(math.random(320, 780), math.random(380, 560)))
                    else
                        -- Dramatic double strike
                        strikeLightning(lightningLayer, Vector2.new(140, 10), Vector2.new(65, 480))
                        task.delay(0.08, function()
                            strikeLightning(lightningLayer, Vector2.new(560, 15), Vector2.new(620, 460))
                        end)
                    end
                end)
            end
        end
    end)
    table.insert(trackedThreads, lightningLoop)

    -- ==============================================================================
    -- 💊 FLOATING TOGGLE CAPSULE (Draggable Minimization Pill)
    -- ==============================================================================
    local isMobileDevice = (deviceName() == "Mobile")
    local tcWidth = isMobileDevice and 150 or 176
    local tcHeight = isMobileDevice and 42 or 50

    local toggleCapsule = create("Frame", {
        Name = "ToggleCapsule",
        Size = UDim2.fromOffset(tcWidth, tcHeight),
        Position = UDim2.new(0, 18, 0, 18),
        BackgroundColor3 = Color3.fromRGB(16, 4, 9),
        BackgroundTransparency = 0.15,
        BorderSizePixel = 0,
        Active = true,
        Visible = false,
        ZIndex = 120,
    }, backdrop)
    round(toggleCapsule, tcHeight / 2)

    local tcStroke = create("UIStroke", {
        Color = PRIMARY_COLOR,
        Thickness = 1.6,
        Transparency = 0.15,
    }, toggleCapsule)

    local capAvatarSize = isMobileDevice and 32 or 38
    local capAvatarFrame = create("Frame", {
        Size = UDim2.fromOffset(capAvatarSize, capAvatarSize),
        Position = UDim2.new(0, 6, 0.5, -capAvatarSize / 2),
        BackgroundColor3 = COLORS.glassDeep,
        BorderSizePixel = 0,
        ZIndex = 121,
    }, toggleCapsule)
    round(capAvatarFrame, capAvatarSize / 2)

    local capAvatarImg = create("ImageLabel", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Image = "rbxassetid://0",
        ZIndex = 122,
    }, capAvatarFrame)
    round(capAvatarImg, capAvatarSize / 2)

    task.spawn(function()
        pcall(function()
            capAvatarImg.Image = Players:GetUserThumbnailAsync(
                LocalPlayer.UserId,
                Enum.ThumbnailType.HeadShot,
                Enum.ThumbnailSize.Size150x150
            )
        end)
    end)

    local capLabelX = isMobileDevice and 44 or 50
    local capUserLabel = textLabel(toggleCapsule, "@" .. LocalPlayer.Name, UDim2.new(0, capLabelX, 0, isMobileDevice and 6 or 9), UDim2.new(1, -capLabelX - 4, 0, 16), Enum.FontWeight.Bold, isMobileDevice and 10 or 11, COLORS.text)
    capUserLabel.ZIndex = 123
    local capMetricsLabel = textLabel(toggleCapsule, "⚡ PAYOMBØYZ", UDim2.new(0, capLabelX, 0, isMobileDevice and 22 or 26), UDim2.new(1, -capLabelX - 4, 0, 14), Enum.FontWeight.Bold, 9, PRIMARY_COLOR)
    capMetricsLabel.ZIndex = 123

    local capBtn = create("TextButton", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Text = "",
        ZIndex = 125,
    }, toggleCapsule)

    local tDragging, tDragInput, tDragStart, tStartPos
    local hasDragged = false

    capBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            tDragging = true
            hasDragged = false
            tDragStart = input.Position
            tStartPos = toggleCapsule.Position
        end
    end)

    capBtn.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            tDragInput = input
        end
    end)

    local tDragEndedConn = UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            tDragging = false
        end
    end)
    table.insert(trackedConnections, tDragEndedConn)

    local tDragConn = UserInputService.InputChanged:Connect(function(input)
        if input == tDragInput and tDragging then
            local delta = input.Position - tDragStart
            if math.abs(delta.X) > 3 or math.abs(delta.Y) > 3 then
                hasDragged = true
            end
            toggleCapsule.Position = UDim2.new(tStartPos.X.Scale, tStartPos.X.Offset + delta.X, tStartPos.Y.Scale, tStartPos.Y.Offset + delta.Y)
        end
    end)
    table.insert(trackedConnections, tDragConn)

    capBtn.MouseButton1Click:Connect(function()
        if not hasDragged then
            playClickSound()
            shell.Visible = not shell.Visible
            toggleCapsule.Visible = not shell.Visible
        end
    end)

    -- Hotkey K & RightControl
    local keybindConn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode.K or input.KeyCode == Enum.KeyCode.RightControl then
            shell.Visible = not shell.Visible
            toggleCapsule.Visible = not shell.Visible
        end
    end)
    table.insert(trackedConnections, keybindConn)

    -- ==============================================================================
    -- 📐 DUAL COLUMN LAYOUT (Left: User & Games | Right: Key System)
    -- ==============================================================================
    local userPanel = create("Frame", {
        Name = "UserInfo",
        Position = UDim2.fromOffset(10, 10),
        Size = UDim2.fromOffset(282, 600),
        BackgroundColor3 = COLORS.glassDeep,
        BackgroundTransparency = 0.55,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        ZIndex = 4,
    }, shellChrome)
    round(userPanel, 14)

    local userPanelStroke = create("UIStroke", {
        Color = Color3.fromRGB(110, 20, 40),
        Thickness = 1,
        Transparency = 0.45,
    }, userPanel)

    local mainPanel = create("Frame", {
        Name = "Main",
        Position = UDim2.fromOffset(302, 10),
        Size = UDim2.fromOffset(618, 600),
        BackgroundColor3 = COLORS.glassDeep,
        BackgroundTransparency = 0.50,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        ZIndex = 4,
    }, shellChrome)
    round(mainPanel, 14)

    local mainPanelStroke = create("UIStroke", {
        Color = Color3.fromRGB(110, 20, 40),
        Thickness = 1,
        Transparency = 0.45,
    }, mainPanel)

    -- Dynamic Content Scrolling Canvas (Canvas Expand Engine)
    local mainScroll = create("ScrollingFrame", {
        Name = "MainContentScroll",
        Position = UDim2.fromOffset(0, 70),
        Size = UDim2.new(1, 0, 1, -70),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = PRIMARY_COLOR,
        ScrollBarImageTransparency = 0.35,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ClipsDescendants = true,
        ZIndex = 5,
    }, mainPanel)

    create("UIPadding", {
        PaddingLeft = UDim.new(0, 18),
        PaddingRight = UDim.new(0, 18),
        PaddingTop = UDim.new(0, 4),
        PaddingBottom = UDim.new(0, 18),
    }, mainScroll)

    create("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        Padding = UDim.new(0, 12),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, mainScroll)

    -- ==============================================================================
    -- 👤 LEFT PANEL CONTENT (Dual-Tab: User Info / Game Support)
    -- ==============================================================================
    local userTabBtn = create("TextButton", {
        Name = "TabUserInfo",
        Position = UDim2.fromOffset(14, 12),
        Size = UDim2.fromOffset(120, 32),
        BackgroundColor3 = COLORS.surfaceRaised,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Text = "",
        ZIndex = 5,
    }, userPanel)
    round(userTabBtn, 8)
    local userTabIcon = lucideIcon(userTabBtn, "user", UDim2.fromOffset(8, 8), UDim2.fromOffset(14, 14), PRIMARY_COLOR, 6)
    local userTabLabel = textLabel(userTabBtn, L("tabUserInfo"), UDim2.fromOffset(28, 0), UDim2.new(1, -30, 1, 0), Enum.FontWeight.Bold, 10, PRIMARY_COLOR)
    userTabLabel.ZIndex = 6

    local gamesTabBtn = create("TextButton", {
        Name = "TabGameSupport",
        Position = UDim2.fromOffset(142, 12),
        Size = UDim2.fromOffset(126, 32),
        BackgroundColor3 = COLORS.glassDeep,
        BackgroundTransparency = 0.5,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Text = "",
        ZIndex = 5,
    }, userPanel)
    round(gamesTabBtn, 8)
    local gamesTabIcon = lucideIcon(gamesTabBtn, "gamepad", UDim2.fromOffset(8, 8), UDim2.fromOffset(14, 14), COLORS.textFaint, 6)
    local gamesTabLabel = textLabel(gamesTabBtn, L("tabGameSupport") .. " (16)", UDim2.fromOffset(28, 0), UDim2.new(1, -30, 1, 0), Enum.FontWeight.Medium, 10, COLORS.textFaint)
    gamesTabLabel.ZIndex = 6

    local backToKeyBtn = makeButton(userPanel, "BackToKey", "⬅ เข้าสู่ระบบ", UDim2.new(1, -156, 0, 12), UDim2.fromOffset(116, 32), PRIMARY_COLOR, PRIMARY_HOVER, PRIMARY_PRESSED)
    backToKeyBtn.Visible = false
    backToKeyBtn.ZIndex = 6
    setButtonTextSize(backToKeyBtn, 10)

    create("Frame", {
        Position = UDim2.fromOffset(14, 52),
        Size = UDim2.new(1, -28, 0, 1),
        BackgroundColor3 = COLORS.divider,
        BackgroundTransparency = 0.75,
        BorderSizePixel = 0,
        ZIndex = 4,
    }, userPanel)

    local userInfoContainer = create("ScrollingFrame", {
        Name = "UserInfoContainer",
        Position = UDim2.fromOffset(0, 56),
        Size = UDim2.new(1, 0, 1, -56),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = PRIMARY_COLOR,
        ScrollBarImageTransparency = 0.5,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ClipsDescendants = true,
        ZIndex = 5,
    }, userPanel)

    local gameSupportContainer = create("Frame", {
        Name = "GameSupportContainer",
        Position = UDim2.fromOffset(0, 56),
        Size = UDim2.new(1, 0, 1, -56),
        BackgroundTransparency = 1,
        Visible = false,
        ZIndex = 5,
    }, userPanel)

    local function switchLeftTab(tabName)
        playClickSound()
        pcall(function() strikeLightning(lightningLayer, 4) end)
        if tabName == "user" then
            userInfoContainer.Visible = true
            gameSupportContainer.Visible = false
            playTween(userTabBtn, MOTION.quick, { BackgroundColor3 = COLORS.surfaceRaised, BackgroundTransparency = 0 })
            playTween(userTabLabel, MOTION.quick, { TextColor3 = PRIMARY_COLOR })
            userTabIcon.ImageColor3 = PRIMARY_COLOR
            playTween(gamesTabBtn, MOTION.quick, { BackgroundColor3 = COLORS.glassDeep, BackgroundTransparency = 0.5 })
            playTween(gamesTabLabel, MOTION.quick, { TextColor3 = COLORS.textFaint })
            gamesTabIcon.ImageColor3 = COLORS.textFaint
        else
            userInfoContainer.Visible = false
            gameSupportContainer.Visible = true
            playTween(gamesTabBtn, MOTION.quick, { BackgroundColor3 = COLORS.surfaceRaised, BackgroundTransparency = 0 })
            playTween(gamesTabLabel, MOTION.quick, { TextColor3 = PRIMARY_COLOR })
            gamesTabIcon.ImageColor3 = PRIMARY_COLOR
            playTween(userTabBtn, MOTION.quick, { BackgroundColor3 = COLORS.glassDeep, BackgroundTransparency = 0.5 })
            playTween(userTabLabel, MOTION.quick, { TextColor3 = COLORS.textFaint })
            userTabIcon.ImageColor3 = COLORS.textFaint
        end
    end

    userTabBtn.MouseButton1Click:Connect(function() switchLeftTab("user") end)
    gamesTabBtn.MouseButton1Click:Connect(function() switchLeftTab("games") end)

    -- Avatar Halo & Circular Image
    local avatarHalo = create("Frame", {
        Position = UDim2.new(0.5, -46, 0, 10),
        Size = UDim2.fromOffset(92, 92),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 5,
    }, userInfoContainer)
    round(avatarHalo, 46)

    local avatarRing = create("Frame", {
        Position = UDim2.fromOffset(2, 2),
        Size = UDim2.fromOffset(88, 88),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 5,
    }, avatarHalo)
    round(avatarRing, 44)

    local avatarRingStroke = create("UIStroke", {
        Color = PRIMARY_COLOR,
        Thickness = 2.5,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    }, avatarRing)

    create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 75, 105)),
            ColorSequenceKeypoint.new(0.5, PRIMARY_COLOR),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(180, 25, 55)),
        }),
        Rotation = 35,
    }, avatarRingStroke)

    local avatarImg = create("ImageLabel", {
        Position = UDim2.fromOffset(4, 4),
        Size = UDim2.fromOffset(80, 80),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Image = "rbxassetid://0",
        ScaleType = Enum.ScaleType.Crop,
        ZIndex = 6,
    }, avatarRing)
    round(avatarImg, 40)

    local onlineDot = create("Frame", {
        Position = UDim2.new(1, -22, 1, -22),
        Size = UDim2.fromOffset(20, 20),
        BackgroundColor3 = COLORS.shell,
        BorderSizePixel = 0,
        ZIndex = 7,
    }, avatarHalo)
    round(onlineDot, 10)

    local onlineCore = create("Frame", {
        Position = UDim2.fromOffset(4, 4),
        Size = UDim2.fromOffset(12, 12),
        BackgroundColor3 = COLORS.success,
        BorderSizePixel = 0,
        ZIndex = 8,
    }, onlineDot)
    round(onlineCore, 6)

    local pulseTween = TweenService:Create(
        onlineCore,
        TweenInfo.new(1.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
        { BackgroundColor3 = Color3.fromRGB(85, 255, 175) }
    )
    pulseTween:Play()
    gui.Destroying:Connect(function() pulseTween:Cancel() end)

    task.spawn(function()
        pcall(function()
            avatarImg.Image = Players:GetUserThumbnailAsync(
                LocalPlayer.UserId,
                Enum.ThumbnailType.HeadShot,
                Enum.ThumbnailSize.Size420x420
            )
        end)
    end)

    local displayName = LocalPlayer.DisplayName or LocalPlayer.Name or "PayomboyZ User"
    local userName = LocalPlayer.Name or "unknown"
    local nameLbl = textLabel(userInfoContainer, displayName, UDim2.fromOffset(14, 108), UDim2.new(1, -28, 0, 22), Enum.FontWeight.Bold, 14, COLORS.text, Enum.TextXAlignment.Center)
    nameLbl.ZIndex = 5
    local userLbl = textLabel(userInfoContainer, "@" .. userName, UDim2.fromOffset(14, 128), UDim2.new(1, -28, 0, 16), Enum.FontWeight.Regular, 10, COLORS.textFaint, Enum.TextXAlignment.Center)
    userLbl.ZIndex = 5

    -- Stats List (Executor, Device, HWID, Game)
    local statsGroup = create("Frame", {
        Position = UDim2.fromOffset(14, 154),
        Size = UDim2.new(1, -28, 0, 164),
        BackgroundColor3 = COLORS.surface,
        BackgroundTransparency = 0.58,
        BorderSizePixel = 0,
        ZIndex = 5,
    }, userInfoContainer)
    round(statsGroup, 10)

    local execName = executorName()
    local execColor = isXenoExecutor() and COLORS.danger or COLORS.success
    local stats = {
        { L("executorLabel"), execName, "monitor", execColor },
        { L("deviceLabel"), deviceName(), (deviceName() == "Mobile") and "smartphone" or "monitor", COLORS.textMuted },
        { L("hwidLabel"), "Available", "shield", COLORS.textMuted },
        { L("gameLabel"), resolveGameName(), "gamepad", COLORS.success },
    }

    for index, item in ipairs(stats) do
        local y = (index - 1) * 40
        lucideIcon(statsGroup, item[3], UDim2.fromOffset(12, y + 12), UDim2.fromOffset(16, 16), item[4], 6)
        local t1 = textLabel(statsGroup, item[1], UDim2.fromOffset(38, y + 4), UDim2.fromOffset(90, 14), Enum.FontWeight.Medium, 9, COLORS.textFaint)
        t1.ZIndex = 6
        local t2 = textLabel(statsGroup, item[2], UDim2.fromOffset(38, y + 18), UDim2.new(1, -48, 0, 16), Enum.FontWeight.Bold, 10, item[4])
        t2.ZIndex = 6
        if index < #stats then
            local div = create("Frame", {
                Position = UDim2.fromOffset(38, y + 38),
                Size = UDim2.new(1, -48, 0, 1),
                BackgroundColor3 = COLORS.divider,
                BackgroundTransparency = 0.85,
                BorderSizePixel = 0,
                ZIndex = 6,
            }, statsGroup)
        end
    end

    -- Metrics Strip (Session Uptime & Ping)
    local metricsStrip = create("Frame", {
        Position = UDim2.fromOffset(14, 326),
        Size = UDim2.new(1, -28, 0, 64),
        BackgroundColor3 = COLORS.surface,
        BackgroundTransparency = 0.58,
        BorderSizePixel = 0,
        ZIndex = 5,
    }, userInfoContainer)
    round(metricsStrip, 10)

    create("Frame", {
        Position = UDim2.new(0.5, 0, 0, 10),
        Size = UDim2.new(0, 1, 1, -20),
        BackgroundColor3 = COLORS.divider,
        BackgroundTransparency = 0.8,
        BorderSizePixel = 0,
        ZIndex = 6,
    }, metricsStrip)

    local sessionCard = create("Frame", {
        Size = UDim2.new(0.5, 0, 1, 0),
        BackgroundTransparency = 1,
        ZIndex = 6,
    }, metricsStrip)
    lucideIcon(sessionCard, "clock", UDim2.fromOffset(12, 14), UDim2.fromOffset(16, 16), PRIMARY_COLOR, 6)
    local s1 = textLabel(sessionCard, L("sessionLabel"), UDim2.fromOffset(36, 8), UDim2.new(1, -42, 0, 16), Enum.FontWeight.Medium, 9, COLORS.textFaint)
    s1.ZIndex = 6
    local sessionText = textLabel(sessionCard, "00:00:00", UDim2.fromOffset(36, 26), UDim2.new(1, -42, 0, 22), Enum.FontWeight.Bold, 12, PRIMARY_COLOR)
    sessionText.ZIndex = 6

    local pingCard = create("Frame", {
        Position = UDim2.fromScale(0.5, 0),
        Size = UDim2.new(0.5, 0, 1, 0),
        BackgroundTransparency = 1,
        ZIndex = 6,
    }, metricsStrip)
    lucideIcon(pingCard, "wifi", UDim2.fromOffset(12, 14), UDim2.fromOffset(16, 16), COLORS.success, 6)
    local p1 = textLabel(pingCard, L("pingLabel"), UDim2.fromOffset(36, 8), UDim2.new(1, -42, 0, 16), Enum.FontWeight.Medium, 9, COLORS.textFaint)
    p1.ZIndex = 6
    local pingText = textLabel(pingCard, "60 FPS", UDim2.fromOffset(36, 26), UDim2.new(1, -42, 0, 22), Enum.FontWeight.Bold, 12, COLORS.success)
    pingText.ZIndex = 6

    -- Connection Status Card
    local connectionCard = create("Frame", {
        Position = UDim2.fromOffset(14, 398),
        Size = UDim2.new(1, -28, 0, 58),
        BackgroundColor3 = COLORS.surface,
        BackgroundTransparency = 0.58,
        BorderSizePixel = 0,
        ZIndex = 5,
    }, userInfoContainer)
    round(connectionCard, 10)

    lucideIcon(connectionCard, "check-circle", UDim2.fromOffset(14, 18), UDim2.fromOffset(20, 20), COLORS.success, 6)
    local c1 = textLabel(connectionCard, L("connectedStatus"), UDim2.fromOffset(42, 8), UDim2.new(1, -50, 0, 22), Enum.FontWeight.Bold, 11, COLORS.success)
    c1.ZIndex = 6
    local c2 = textLabel(connectionCard, L("systemReady"), UDim2.fromOffset(42, 30), UDim2.new(1, -50, 0, 18), Enum.FontWeight.Regular, 9, COLORS.textMuted)
    c2.ZIndex = 6

    create("Frame", {
        Position = UDim2.fromOffset(14, 460),
        Size = UDim2.new(1, -28, 0, 16),
        BackgroundTransparency = 1,
    }, userInfoContainer)

    -- Live session uptime & ping thread
    local startedAt = os.clock()
    local sessionThread = task.spawn(function()
        while gui and gui.Parent do
            local elapsed = math.floor(os.clock() - startedAt)
            local h = math.floor(elapsed / 3600)
            local m = math.floor((elapsed % 3600) / 60)
            local s = elapsed % 60
            if sessionText and sessionText.Parent then
                sessionText.Text = string.format("%02d:%02d:%02d", h, m, s)
            end
            if pingText and pingText.Parent then
                local pingVal = 0
                pcall(function() pingVal = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()) end)
                pingText.Text = (pingVal > 0) and (tostring(pingVal) .. " ms") or "60 FPS"
            end
            task.wait(1)
        end
    end)
    table.insert(trackedThreads, sessionThread)

    -- Games Supported Tab Content
    local gamesScroll = create("ScrollingFrame", {
        Position = UDim2.fromOffset(10, 6),
        Size = UDim2.new(1, -20, 1, -12),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        CanvasSize = UDim2.fromScale(0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = PRIMARY_COLOR,
        ScrollBarImageTransparency = 0.4,
        ClipsDescendants = true,
        ZIndex = 6,
    }, gameSupportContainer)

    create("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, gamesScroll)

    local popularGames = {
        { Name = "Blox Fruit", PlaceId = 2753915549, Kind = "FREE", Desc = "BF • All Seas • Auto Farm" },
        { Name = "FISCH", PlaceId = 16732694052, Kind = "FREE", Desc = "Auto Fish • Shake • Radar" },
        { Name = "Slayers 2", PlaceId = 16205713724, Kind = "VVIP", Desc = "Auto Farm • Fast Attack • Demon" },
        { Name = "Dungeon Lootr", PlaceId = 106484206883664, Kind = "FREE", Desc = "Kill Aura • 10 Dungeons • Raids" },
        { Name = "Arena Sniper", PlaceId = 122446657157717, Kind = "FREE", Desc = "Auto Kill • Silent Aim • Sniper" },
        { Name = "Attack On Titan Revolution", PlaceId = 13379208636, Kind = "FREE", Desc = "AOTR • Titan Farm" },
        { Name = "Anime Card Farm", PlaceId = 125039473548047, Kind = "FREE", Desc = "Auto Pack • Reroll" },
        { Name = "Murder Mystery 2", PlaceId = 142823291, Kind = "VVIP", Desc = "MM2 • Coin Farm • ESP" },
        { Name = "Mine a Mountain", PlaceId = 125927821145949, Kind = "VVIP", Desc = "MaM • Auto Mine • ESP" },
        { Name = "Roll Anime To Fight", PlaceId = 107653945083776, Kind = "VVIP", Desc = "RATF • Auto Roll • Fight" },
        { Name = "Capybara Vs Plant", PlaceId = 104973076655377, Kind = "FREE", Desc = "CvsP • Auto Plant" },
        { Name = "99 Nights", PlaceId = 126509999114328, Kind = "FREE", Desc = "99Nights • Forest Farm" },
        { Name = "Gakuran", PlaceId = 128736949265057, Kind = "FREE", Desc = "GKR • Auto Farm • Combat" },
        { Name = "+1 Loot a Forge", PlaceId = 118805555015549, Kind = "FREE", Desc = "Auto Farm • Boss Hunter" },
        { Name = "Steal An Egg", PlaceId = 107778070777162, Kind = "VVIP", Desc = "SaE • Auto Egg • Dash" },
        { Name = "Anime Expedition", PlaceId = 84515722934860, Kind = "VVIP", Desc = "AE • Auto Expedition" },
    }

    local currentPlace = game.PlaceId
    for idx, gData in ipairs(popularGames) do
        local isCurrent = (currentPlace == gData.PlaceId)
        local card = create("Frame", {
            Name = "GameCard_" .. idx,
            Size = UDim2.new(1, 0, 0, 56),
            BackgroundColor3 = isCurrent and COLORS.surfaceRaised or COLORS.surface,
            BackgroundTransparency = 0.35,
            BorderSizePixel = 0,
            LayoutOrder = isCurrent and 0 or idx,
            ZIndex = 6,
        }, gamesScroll)
        round(card, 8)

        local iconFrame = create("Frame", {
            Position = UDim2.fromOffset(6, 6),
            Size = UDim2.fromOffset(44, 44),
            BackgroundColor3 = COLORS.glassDeep,
            BorderSizePixel = 0,
            ZIndex = 7,
        }, card)
        round(iconFrame, 6)

        local gameIcon = create("ImageLabel", {
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            Image = "rbxthumb://type=GameIcon&id=" .. tostring(gData.PlaceId) .. "&w=150&h=150",
            ScaleType = Enum.ScaleType.Crop,
            ZIndex = 8,
        }, iconFrame)
        round(gameIcon, 6)

        local gTitle = textLabel(card, gData.Name, UDim2.fromOffset(58, 6), UDim2.new(1, -118, 0, 18), Enum.FontWeight.Bold, 11, COLORS.text)
        gTitle.ZIndex = 7
        local gDesc = textLabel(card, gData.Desc, UDim2.fromOffset(58, 24), UDim2.new(1, -118, 0, 14), Enum.FontWeight.Regular, 9, COLORS.textFaint)
        gDesc.ZIndex = 7

        if isCurrent then
            local liveBadge = textLabel(card, "🟢 ACTIVE", UDim2.fromOffset(58, 38), UDim2.new(1, -118, 0, 12), Enum.FontWeight.Bold, 8, COLORS.success)
            liveBadge.ZIndex = 7
        end

        local isVvip = (gData.Kind == "VVIP")
        local pBtn = Instance.new("TextButton")
        pBtn.Size = UDim2.fromOffset(50, 24)
        pBtn.Position = UDim2.new(1, -56, 0.5, -12)
        pBtn.BackgroundColor3 = isVvip and PRIMARY_COLOR or COLORS.surfaceRaised
        pBtn.Text = L("playBtn")
        pBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        pBtn.TextSize = 10
        applyFont(pBtn, Enum.FontWeight.Bold)
        pBtn.BorderSizePixel = 0
        pBtn.ZIndex = 8
        pBtn.Parent = card
        round(pBtn, 6)

        pBtn.MouseButton1Click:Connect(function()
            playClickSound()
            ShowToast("🚀 " .. gData.Name, string.format(L("teleporting"), gData.Name), false)
            HopToPlace(gData.PlaceId)
        end)
    end

    -- ==============================================================================
    -- 🔑 RIGHT PANEL CONTENT (Key System & Service Overview)
    -- ==============================================================================
    local header = create("Frame", {
        Name = "Header",
        Position = UDim2.fromOffset(18, 12),
        Size = UDim2.new(1, -36, 0, 56),
        BackgroundTransparency = 1,
        ZIndex = 5,
    }, mainPanel)

    -- Ambient Neon Bloom (Soft diffuse radial glow behind text, zero cartoon strokes)
    local titleBloom = create("ImageLabel", {
        Name = "TitleNeonBloom",
        Position = UDim2.fromOffset(-24, -14),
        Size = UDim2.fromOffset(260, 56),
        BackgroundTransparency = 1,
        Image = "rbxassetid://6082206725",
        ImageColor3 = Color3.fromRGB(255, 30, 60),
        ImageTransparency = 0.60,
        ScaleType = Enum.ScaleType.Stretch,
        ZIndex = 5,
    }, header)

    local mainTitle = textLabel(header, "PAYOMBØYZ HUB", UDim2.fromOffset(0, 0), UDim2.fromOffset(230, 30), Enum.FontWeight.Bold, 23, Color3.fromRGB(255, 255, 255))
    mainTitle.ZIndex = 6
    mainTitle.TextStrokeTransparency = 0.65
    mainTitle.TextStrokeColor3 = Color3.fromRGB(15, 0, 5)

    -- Sleek Cyber Neon Underline (Laser Accent)
    local neonLine = create("Frame", {
        Name = "NeonUnderline",
        Position = UDim2.fromOffset(0, 28),
        Size = UDim2.fromOffset(190, 1.5),
        BackgroundColor3 = PRIMARY_COLOR,
        BorderSizePixel = 0,
        ZIndex = 6,
    }, header)
    create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(0.35, PRIMARY_COLOR),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(18, 4, 8)),
        }),
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0),
            NumberSequenceKeypoint.new(0.65, 0.25),
            NumberSequenceKeypoint.new(1, 1),
        }),
    }, neonLine)

    -- Dynamic Neon Glow Breath
    local bloomPulse = TweenService:Create(
        titleBloom,
        TweenInfo.new(1.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
        { ImageTransparency = 0.42, ImageColor3 = Color3.fromRGB(255, 45, 75) }
    )
    bloomPulse:Play()
    gui.Destroying:Connect(function() bloomPulse:Cancel() end)

    local vvipTag = create("Frame", {
        Position = UDim2.fromOffset(236, 4),
        Size = UDim2.fromOffset(92, 20),
        BackgroundColor3 = COLORS.surfaceRaised,
        BorderSizePixel = 0,
        ZIndex = 6,
    }, header)
    round(vvipTag, 6)
    create("UIStroke", {
        Color = PRIMARY_COLOR,
        Thickness = 1.2,
    }, vvipTag)
    local tagLbl = textLabel(vvipTag, "⚡ CRIMSON V4", UDim2.fromScale(0, 0), UDim2.fromScale(1, 1), Enum.FontWeight.Bold, 9, PRIMARY_COLOR, Enum.TextXAlignment.Center)
    tagLbl.ZIndex = 7

    local subTitleLbl = textLabel(header, L("highVoltageSub"), UDim2.fromOffset(0, 34), UDim2.new(1, -120, 0, 16), Enum.FontWeight.Bold, 9, PRIMARY_COLOR)
    subTitleLbl.ZIndex = 6

    -- Control Buttons: Language, Minimize, Close
    local langToggleBtn = makeButton(
        header, "LangToggle", L("langBtn"),
        UDim2.new(1, -118, 0, 10), UDim2.fromOffset(40, 28),
        COLORS.surfaceRaised, COLORS.surfaceHover, COLORS.surfacePressed
    )
    langToggleBtn.ZIndex = 7

    local minimizeBtn = makeIconButton(header, "Minimize", "minus", UDim2.new(1, -74, 0, 10), COLORS.surfaceRaised, COLORS.surfaceHover, COLORS.surfacePressed)
    minimizeBtn.ZIndex = 7
    local closeBtn = makeIconButton(header, "Close", "x", UDim2.new(1, -36, 0, 10), COLORS.surfaceRaised, Color3.fromRGB(74, 38, 53), Color3.fromRGB(54, 27, 40))
    closeBtn.ZIndex = 7

    create("Frame", {
        Position = UDim2.fromOffset(0, 54),
        Size = UDim2.new(1, 0, 0, 1),
        BackgroundColor3 = COLORS.divider,
        BackgroundTransparency = 0.75,
        BorderSizePixel = 0,
        ZIndex = 5,
    }, header)

    -- Active Service Card (Auto-Expanding Canvas Card)
    local serviceCard = create("Frame", {
        Name = "ServiceCard",
        Size = UDim2.new(1, 0, 0, 72),
        BackgroundColor3 = COLORS.surface,
        BackgroundTransparency = 0.58,
        BorderSizePixel = 0,
        LayoutOrder = 1,
        ZIndex = 5,
    }, mainScroll)
    round(serviceCard, 10)

    local serviceLogoFrame = create("Frame", {
        Position = UDim2.fromOffset(12, 10),
        Size = UDim2.fromOffset(52, 52),
        BackgroundColor3 = COLORS.surfaceRaised,
        BackgroundTransparency = 0.5,
        BorderSizePixel = 0,
        ZIndex = 6,
    }, serviceCard)
    round(serviceLogoFrame, 26)
    create("UIStroke", {
        Color = PRIMARY_COLOR,
        Thickness = 1.2,
        Transparency = 0.3,
    }, serviceLogoFrame)

    local serviceLogo = create("ImageLabel", {
        Position = UDim2.fromOffset(2, 2),
        Size = UDim2.fromOffset(48, 48),
        BackgroundTransparency = 1,
        ScaleType = Enum.ScaleType.Fit,
        ZIndex = 7,
    }, serviceLogoFrame)
    round(serviceLogo, 24)

    task.spawn(function()
        local logo = LoadLogoAsset()
        if logo and serviceLogo and serviceLogo.Parent then
            serviceLogo.Image = logo
        end
    end)

    local sActive = textLabel(serviceCard, L("activeService"), UDim2.fromOffset(74, 10), UDim2.new(1, -260, 0, 14), Enum.FontWeight.Bold, 9, COLORS.success)
    sActive.ZIndex = 6
    local sStudio = textLabel(serviceCard, L("studioName"), UDim2.fromOffset(74, 26), UDim2.new(1, -260, 0, 20), Enum.FontWeight.Bold, 14, COLORS.text)
    sStudio.ZIndex = 6
    local sDeliv = textLabel(serviceCard, L("clientDelivery"), UDim2.fromOffset(74, 46), UDim2.new(1, -260, 0, 16), Enum.FontWeight.Regular, 10, COLORS.textFaint)
    sDeliv.ZIndex = 6

    local secureBadge = create("Frame", {
        Position = UDim2.new(1, -174, 0.5, -16),
        Size = UDim2.fromOffset(162, 32),
        BackgroundColor3 = isXenoExecutor() and Color3.fromRGB(55, 12, 22) or COLORS.glassDeep,
        BackgroundTransparency = 0.25,
        BorderSizePixel = 0,
        ZIndex = 6,
    }, serviceCard)
    round(secureBadge, 8)

    local secStroke = create("UIStroke", {
        Color = isXenoExecutor() and COLORS.danger or PRIMARY_COLOR,
        Thickness = 1.2,
        Transparency = 0.3,
    }, secureBadge)

    lucideIcon(secureBadge, isXenoExecutor() and "alert-circle" or "shield-check", UDim2.fromOffset(10, 8), UDim2.fromOffset(16, 16), isXenoExecutor() and COLORS.danger or COLORS.success, 7)
    local badgeTxt = textLabel(secureBadge, isXenoExecutor() and "Xeno: Blocked" or "GitHub Engine", UDim2.fromOffset(32, 0), UDim2.new(1, -36, 1, 0), Enum.FontWeight.Bold, 9, isXenoExecutor() and COLORS.danger or COLORS.success)
    badgeTxt.ZIndex = 7

    -- Secure Access & Key Input Box Container
    local keySection = create("Frame", {
        Name = "KeySection",
        Size = UDim2.new(1, 0, 0, 84),
        BackgroundTransparency = 1,
        LayoutOrder = 2,
        ZIndex = 5,
    }, mainScroll)

    local secPrompt1 = textLabel(keySection, L("secureAccess"), UDim2.fromOffset(2, 0), UDim2.new(1, -4, 0, 14), Enum.FontWeight.Bold, 9, PRIMARY_COLOR)
    secPrompt1.ZIndex = 5
    local secPrompt2 = textLabel(keySection, L("enterPrompt"), UDim2.fromOffset(2, 14), UDim2.new(1, -4, 0, 18), Enum.FontWeight.Regular, 11, COLORS.textMuted)
    secPrompt2.ZIndex = 5

    local keyInput = create("TextBox", {
        Name = "KeyInput",
        Position = UDim2.new(0, 0, 0, 36),
        Size = UDim2.new(1, 0, 0, 48),
        BackgroundColor3 = COLORS.input,
        BackgroundTransparency = 0.20,
        BorderSizePixel = 0,
        ClearTextOnFocus = false,
        PlaceholderText = L("inputPlaceholder"),
        PlaceholderColor3 = COLORS.textMuted,
        Text = defaultKeyText or "",
        TextColor3 = COLORS.text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 6,
    }, keySection)
    round(keyInput, 10)
    applyFont(keyInput, Enum.FontWeight.Medium)
    local KeyBox = keyInput

    create("UIPadding", {
        PaddingLeft = UDim.new(0, 44),
        PaddingRight = UDim.new(0, 16),
    }, keyInput)

    local inputKeyIcon = lucideIcon(keySection, "key", UDim2.fromOffset(12, 50), UDim2.fromOffset(18, 18), PRIMARY_COLOR, 7)

    local inputBorder = create("UIStroke", {
        Color = PRIMARY_COLOR,
        Thickness = 1.4,
        Transparency = 0.2,
    }, keyInput)

    local inputGradient = create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(150, 18, 35)),
            ColorSequenceKeypoint.new(0.5, PRIMARY_COLOR),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 80, 110)),
        }),
        Rotation = 0,
    }, inputBorder)

    local spinTween = TweenService:Create(
        inputGradient,
        TweenInfo.new(2.8, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1),
        { Rotation = 360 }
    )
    spinTween:Play()
    gui.Destroying:Connect(function() spinTween:Cancel() end)

    keyInput.Focused:Connect(function()
        playTween(keyInput, MOTION.quick, { BackgroundColor3 = COLORS.inputFocus })
        playTween(inputBorder, MOTION.quick, { Transparency = 0.05 })
        playTween(inputKeyIcon, MOTION.quick, { ImageColor3 = Color3.fromRGB(255, 85, 115) })
    end)
    keyInput.FocusLost:Connect(function()
        playTween(keyInput, MOTION.quick, { BackgroundColor3 = COLORS.input })
        playTween(inputBorder, MOTION.quick, { Transparency = 0.2 })
        playTween(inputKeyIcon, MOTION.quick, { ImageColor3 = PRIMARY_COLOR })
    end)

    -- Primary Buttons (Get Key / Verify Key)
    local primaryRow = create("Frame", {
        Name = "PrimaryRow",
        Size = UDim2.new(1, 0, 0, 44),
        BackgroundTransparency = 1,
        LayoutOrder = 3,
        ZIndex = 5,
    }, mainScroll)

    local getKeyBtn = makeButton(primaryRow, "GetKey", L("getKeyBtn"), UDim2.new(0, 0, 0, 0), UDim2.new(0.5, -6, 1, 0), COLORS.surfaceRaised, COLORS.surfaceHover, COLORS.surfacePressed, "key")
    getKeyBtn.ZIndex = 6
    local redeemBtn = makeButton(primaryRow, "Redeem", L("redeemBtn"), UDim2.new(0.5, 6, 0, 0), UDim2.new(0.5, -6, 1, 0), PRIMARY_COLOR, PRIMARY_HOVER, PRIMARY_PRESSED, "shield-check")
    redeemBtn.ZIndex = 6

    create("UIStroke", {
        Color = Color3.fromRGB(255, 65, 95),
        Thickness = 1.4,
        Transparency = 0.2,
    }, redeemBtn)

    -- Utility Buttons (Discord, Copy HWID, Clear Saved Key)
    local utilRow = create("Frame", {
        Name = "UtilRow",
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundTransparency = 1,
        LayoutOrder = 4,
        ZIndex = 5,
    }, mainScroll)
    create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, utilRow)

    local discordBtn = makeButton(utilRow, "Discord", L("discordBtn"), UDim2.new(), UDim2.new(1/3, -6, 1, 0), COLORS.surfaceRaised, COLORS.surfaceHover, COLORS.surfacePressed, "message-circle")
    discordBtn.LayoutOrder = 1
    discordBtn.ZIndex = 6
    setButtonTextSize(discordBtn, 10)

    local copyHwidBtn = makeButton(utilRow, "CopyHWID", L("copyHwidBtn"), UDim2.new(), UDim2.new(1/3, -6, 1, 0), COLORS.surfaceRaised, COLORS.surfaceHover, COLORS.surfacePressed, "copy")
    copyHwidBtn.LayoutOrder = 2
    copyHwidBtn.ZIndex = 6
    setButtonTextSize(copyHwidBtn, 10)

    local clearKeyBtn = makeButton(utilRow, "ClearKey", L("clearKeyBtn"), UDim2.new(), UDim2.new(1/3, -6, 1, 0), COLORS.surfaceRaised, COLORS.surfaceHover, COLORS.surfacePressed, "trash")
    clearKeyBtn.LayoutOrder = 3
    clearKeyBtn.ZIndex = 6
    setButtonTextSize(clearKeyBtn, 10)

    -- Dynamic Live Status Card
    local statusCard = create("Frame", {
        Name = "StatusCard",
        Size = UDim2.new(1, 0, 0, 48),
        BackgroundColor3 = COLORS.surface,
        BackgroundTransparency = 0.58,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        LayoutOrder = 5,
        ZIndex = 5,
    }, mainScroll)
    round(statusCard, 10)

    local statusAccent = create("Frame", {
        Position = UDim2.fromOffset(0, 8),
        Size = UDim2.new(0, 3, 1, -16),
        BackgroundColor3 = PRIMARY_COLOR,
        BorderSizePixel = 0,
        ZIndex = 6,
    }, statusCard)
    round(statusAccent, 2)

    local statusIcon = lucideIcon(statusCard, "info", UDim2.fromOffset(14, 16), UDim2.fromOffset(16, 16), PRIMARY_COLOR, 6)
    local statusText = textLabel(statusCard, "", UDim2.fromOffset(38, 0), UDim2.new(1, -48, 1, 0), Enum.FontWeight.Bold, 11, COLORS.textMuted)
    statusText.ZIndex = 6

    local function setStatus(message, color)
        local tone = color or PRIMARY_COLOR
        statusText.Text = tostring(message or "")
        playTween(statusText, MOTION.quick, { TextColor3 = tone })
        playTween(statusAccent, MOTION.quick, { BackgroundColor3 = tone })
        playTween(statusIcon, MOTION.quick, { ImageColor3 = tone })

        local iconName = "info"
        if tone == COLORS.success then iconName = "check-circle"
        elseif tone == COLORS.warning or tone == COLORS.danger then iconName = "alert-circle" end
        applyLucideData(statusIcon, iconName)
    end

    if isXenoExecutor() then
        setStatus(L("xenoBlocked"), COLORS.danger)
        setButtonEnabled(redeemBtn, false)
    elseif initialStatus then
        setStatus(initialStatus, COLORS.warning)
    else
        setStatus("Ready • " .. resolveGameName(), COLORS.success)
    end

    -- Bottom VVIP Access Card
    local vvipCard = create("Frame", {
        Name = "VvipCard",
        Size = UDim2.new(1, 0, 0, 150),
        BackgroundColor3 = COLORS.surface,
        BackgroundTransparency = 0.58,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        LayoutOrder = 6,
        ZIndex = 5,
    }, mainScroll)
    round(vvipCard, 12)

    local vvipBorder = create("UIStroke", {
        Color = Color3.fromRGB(130, 20, 42),
        Thickness = 1.2,
        Transparency = 0.4,
    }, vvipCard)

    local vBadge = create("Frame", {
        Position = UDim2.fromOffset(16, 14),
        Size = UDim2.fromOffset(92, 20),
        BackgroundColor3 = COLORS.surfaceRaised,
        BorderSizePixel = 0,
        ZIndex = 6,
    }, vvipCard)
    round(vBadge, 6)
    local vBadgeLbl = textLabel(vBadge, L("vipTitle"), UDim2.fromScale(0, 0), UDim2.fromScale(1, 1), Enum.FontWeight.Bold, 8, PRIMARY_COLOR, Enum.TextXAlignment.Center)
    vBadgeLbl.ZIndex = 7

    local vHead = textLabel(vvipCard, L("vvipExclusive"), UDim2.fromOffset(16, 40), UDim2.new(1, -210, 0, 22), Enum.FontWeight.Bold, 15, COLORS.text)
    vHead.ZIndex = 6
    local vSub1 = textLabel(vvipCard, L("vvipPerksDesc"), UDim2.fromOffset(16, 64), UDim2.new(1, -210, 0, 18), Enum.FontWeight.Medium, 11, COLORS.textMuted)
    vSub1.ZIndex = 6
    local vSub2 = textLabel(vvipCard, L("vvipDiscordNote"), UDim2.fromOffset(16, 84), UDim2.new(1, -210, 0, 18), Enum.FontWeight.Medium, 10, PRIMARY_COLOR)
    vSub2.ZIndex = 6
    local vSub3 = textLabel(vvipCard, L("vvipPillTags"), UDim2.fromOffset(16, 108), UDim2.new(1, -210, 0, 16), Enum.FontWeight.Regular, 9, COLORS.textFaint)
    vSub3.ZIndex = 6

    local vvipBtnSlot = create("Frame", {
        Position = UDim2.new(1, -196, 0.5, -23),
        Size = UDim2.fromOffset(180, 46),
        BackgroundTransparency = 1,
        ZIndex = 6,
    }, vvipCard)

    local vvipPurchaseBtn = makeButton(vvipBtnSlot, "VvipPurchase", L("premiumBtn"), UDim2.new(), UDim2.fromScale(1, 1), COLORS.premiumAction, COLORS.premiumHover, COLORS.premiumPressed, "external-link")
    vvipPurchaseBtn.ZIndex = 7
    setButtonTextSize(vvipPurchaseBtn, 10)

    local vvipScale = create("UIScale", { Scale = 1 }, vvipBtnSlot)
    local vvipAnimConn = RunService.RenderStepped:Connect(function()
        if not gui.Parent or not vvipPurchaseBtn.Parent then return end
        if shell and not shell.Visible then return end
        local t = os.clock()
        vvipPurchaseBtn.Position = UDim2.fromOffset(math.cos(t * 1.1) * 2, math.sin(t * 1.3) * 2.5)
        vvipScale.Scale = 1 + math.sin(t * 1.5) * 0.015
    end)
    table.insert(trackedConnections, vvipAnimConn)

    -- ==============================================================================
    -- 🌐 SCRIPT CENTER WEB KEY ENGINE HOOK (Official Integration)
    -- ==============================================================================
    local ScriptCenter = (getgenv and getgenv().ScriptCenter) or _G.ScriptCenter or rawget(_G, "ScriptCenter") or ScriptCenter
    pcall(function()
        if type(ScriptCenter) == "table" and type(ScriptCenter.OnStatus) == "function" then
            ScriptCenter.OnStatus(function(state, message)
                state = tostring(state or ""):lower()
                message = tostring(message or "")

                if state == "loading" then
                    _isAuthenticating = true
                    setButtonEnabled(redeemBtn, false)
                    setStatus("⏳ " .. (message ~= "" and message or "กำลังตรวจสอบคีย์กับระบบ..."), COLORS.warning)
                elseif state == "success" then
                    _isAuthenticating = false
                    local rawKey = keyInput.Text or ""
                    local cleanKey = rawKey:gsub("%s+", "")
                    SaveKey(cleanKey)

                    setStatus("✅ " .. (message ~= "" and message or "เข้าสู่ระบบสำเร็จ! กำลังรันเกม..."), COLORS.success)
                    ShowToast("👑 SCRIPT CENTER", (message ~= "" and message or "ยืนยันคีย์สำเร็จ!"), false)

                    pcall(function()
                        strikeLightning(lightningLayer, Vector2.new(200, 10), Vector2.new(600, 260))
                    end)

                    task.wait(0.4)
                    local placeId = game.PlaceId
                    local gameData = SupportedGames[placeId]
                    local targetUrl = (gameData and gameData.URL) or HubConfig.StartURL
                    RunGameScript(targetUrl, cleanKey, function(errMsg)
                        _isAuthenticating = false
                        _isScriptLaunched = false
                        setButtonEnabled(redeemBtn, true)
                        setStatus("❌ " .. tostring(errMsg or L("retryFailed")), COLORS.danger)
                        ShowToast("❌ ERROR", tostring(errMsg or L("retryFailed")), true)
                    end)
                elseif state == "error" then
                    _isAuthenticating = false
                    setButtonEnabled(redeemBtn, true)
                    setStatus("❌ " .. (message ~= "" and message or "คีย์ไม่ถูกต้องหรือหมดอายุ"), COLORS.danger)
                    ShowToast("❌ SCRIPT CENTER", (message ~= "" and message or "คีย์ไม่ถูกต้อง"), true)
                end
            end)
        end
    end)

    -- ==============================================================================
    -- 🌐 BUTTON ACTIONS & LOGIC
    -- ==============================================================================
    langToggleBtn.Activated:Connect(function()
        _currentLang = (_currentLang == "TH") and "EN" or "TH"
        setButtonText(langToggleBtn, L("langBtn"))
        setButtonText(redeemBtn, L("redeemBtn"))
        setButtonText(getKeyBtn, L("getKeyBtn"))
        setButtonText(discordBtn, L("discordBtn"))
        setButtonText(copyHwidBtn, L("copyHwidBtn"))
        setButtonText(clearKeyBtn, L("clearKeyBtn"))
        setButtonText(vvipPurchaseBtn, L("premiumBtn"))
        userTabLabel.Text = L("tabUserInfo")
        gamesTabLabel.Text = L("tabGameSupport") .. " (16)"
        subTitleLbl.Text = L("highVoltageSub")
        sActive.Text = L("activeService")
        sStudio.Text = L("studioName")
        sDeliv.Text = L("clientDelivery")
        secPrompt1.Text = L("secureAccess")
        secPrompt2.Text = L("enterPrompt")
        keyInput.PlaceholderText = L("inputPlaceholder")
        vBadgeLbl.Text = L("vipTitle")
        vHead.Text = L("vvipExclusive")
        vSub1.Text = L("vvipPerksDesc")
        vSub2.Text = L("vvipDiscordNote")
        vSub3.Text = L("vvipPillTags")
        c1.Text = L("connectedStatus")
        c2.Text = L("systemReady")
        s1.Text = L("sessionLabel")
        p1.Text = L("pingLabel")
        setStatus("Language: " .. _currentLang, PRIMARY_COLOR)
        ShowToast("🌐 LANGUAGE", (_currentLang == "TH") and "เปลี่ยนภาษาเป็น ภาษาไทย แล้ว" or "Language switched to English", false)
    end)

    getKeyBtn.Activated:Connect(function()
        local targetUrl = HubConfig.GetKeyURL
        if type(ScriptCenter) == "table" and type(ScriptCenter.GetKeyURL) == "string" and ScriptCenter.GetKeyURL ~= "" then
            targetUrl = ScriptCenter.GetKeyURL
        end
        if copyText(targetUrl) then
            setStatus(L("copiedKey"), COLORS.success)
            ShowToast("🔑 GET KEY", L("copiedKey"), false)
        end
    end)

    discordBtn.Activated:Connect(function()
        if copyText(HubConfig.DiscordURL) then
            setStatus(L("copiedDiscord"), COLORS.success)
            ShowToast("💬 DISCORD", L("copiedDiscord"), false)
        end
    end)

    copyHwidBtn.Activated:Connect(function()
        local hwid = readableHwid()
        if copyText(hwid) then
            setStatus(L("copiedHwid"), COLORS.success)
            ShowToast("🛡️ HWID", L("copiedHwid"), false)
        end
    end)

    clearKeyBtn.Activated:Connect(function()
        ClearSavedKeys()
        keyInput.Text = ""
        setStatus(L("keyCleared"), COLORS.warning)
        ShowToast("🗑️ CLEAR KEY", L("keyCleared"), false)
    end)

    vvipPurchaseBtn.Activated:Connect(function()
        if copyText(HubConfig.VVIPURL) then
            setStatus(L("copiedVvip"), COLORS.success)
            ShowToast("👑 VVIP STORE", L("copiedVvip"), false)
        end
    end)

    minimizeBtn.Activated:Connect(function()
        shell.Visible = false
        toggleCapsule.Visible = true
    end)

    local closing = false
    local function closeLoader()
        if closing then return end
        closing = true
        playTween(backdrop, MOTION.normal, { BackgroundTransparency = 1 })
        playTween(shellScale, MOTION.normal, { Scale = shellScale.Scale * 0.95 })
        local t = playTween(shell, MOTION.normal, { GroupTransparency = 1 }, nil, nil, "visibility")
        t.Completed:Connect(function()
            if gui.Parent then gui:Destroy() end
        end)
    end

    closeBtn.Activated:Connect(closeLoader)

    -- ==============================================================================
    -- 🚀 AUTHENTICATION DISPATCHER
    -- ==============================================================================
    local function doAuthenticate()
        if _isAuthenticating or _isScriptLaunched then return end
        if isXenoExecutor() then
            setStatus(L("xenoBlocked"), COLORS.danger)
            setButtonEnabled(redeemBtn, false)
            return
        end

        local rawKey = keyInput.Text or ""
        local key = rawKey:gsub("%s+", "")
        if key == "" then
            setStatus(L("keyEmpty"), COLORS.warning)
            ShowToast("⚠️ WARNING", L("keyEmpty"), true)
            return
        end

        -- Trigger high-voltage lightning strike on login attempt
        pcall(function()
            strikeLightning(lightningLayer, Vector2.new(480, 15), Vector2.new(620, 240))
        end)

        -- 0. Check ScriptCenter Web Integration First (Template Standard)
        if type(ScriptCenter) == "table" and type(ScriptCenter.SubmitKey) == "function" then
            _isAuthenticating = true
            setButtonEnabled(redeemBtn, false)
            setStatus("🔍 [ScriptCenter] กำลังตรวจสอบคีย์...", COLORS.warning)
            ScriptCenter.SubmitKey(KeyBox.Text)
            return
        end

        _isAuthenticating = true
        setButtonEnabled(redeemBtn, false)
        setStatus(L("verifying"), PRIMARY_COLOR)

        task.spawn(function()
            local okAuth, reason, isVvip, isSuperVip = VerifyKey(key)

            if not okAuth then
                _isAuthenticating = false
                setButtonEnabled(redeemBtn, true)
                setStatus(reason or L("keyBad"), COLORS.danger)
                ShowToast("❌ AUTH FAILED", reason or L("keyBad"), true)
                return
            end

            SaveKey(key)

            local placeId = game.PlaceId
            local gameData = SupportedGames[placeId]
            local mapName = gameData and gameData.Name or "Game Hub"
            local defaultFallback = "https://raw.githubusercontent.com/Payomboyz0028/Yaranikaaaa/refs/heads/main/WaitKey"
            local targetUrl = defaultFallback

            local engine = GetRemoteKeyData()
            if engine and type(engine.GetGameURL) == "function" then
                pcall(function()
                    local resUrl = engine.GetGameURL(placeId, key)
                    if resUrl and resUrl ~= defaultFallback then targetUrl = resUrl end
                end)
            end

            if targetUrl == defaultFallback then
                if gameData and gameData.URL then
                    if gameData.IsVVIP and not (isVvip or isSuperVip) then
                        setStatus(L("vvipMapWarn"), COLORS.warning)
                        targetUrl = defaultFallback
                    else
                        targetUrl = gameData.URL
                    end
                end
            end

            local successMsg = isSuperVip and L("superVIPSuccess") or (isVvip and L("vvipSuccess") or L("vipSuccess"))
            setStatus(successMsg .. mapName, COLORS.success)
            ShowToast("✅ SUCCESS", successMsg .. mapName, false)

            task.wait(0.35)

            RunGameScript(targetUrl, key, function(errMsg)
                _isAuthenticating = false
                _isScriptLaunched = false
                setButtonEnabled(redeemBtn, true)
                setStatus("❌ " .. tostring(errMsg or L("retryFailed")), COLORS.danger)
                ShowToast("❌ RUNTIME ERROR", tostring(errMsg or L("retryFailed")), true)
            end)
        end)
    end

    redeemBtn.Activated:Connect(doAuthenticate)
    keyInput.FocusLost:Connect(function(enterPressed)
        if enterPressed then doAuthenticate() end
    end)

    -- ==============================================================================
    -- 📐 CANVAS EXPAND FREE RESIZING & ZERO-JUMP DRAGGING ENGINE
    -- ==============================================================================
    local MIN_SIZE = Vector2.new(580, 380)
    local VIEWPORT_MARGIN = 16

    -- Bottom-Right Corner Resize Grip Handle (@resize)
    local resizeHandle = create("TextButton", {
        Name = "@resize",
        AnchorPoint = Vector2.new(1, 1),
        Position = UDim2.new(1, -2, 1, -2),
        Size = UDim2.fromOffset(28, 28),
        BackgroundTransparency = 1,
        AutoButtonColor = false,
        Text = "",
        ZIndex = 250,
    }, shellChrome)

    local resizeIconColor = Color3.fromRGB(160, 45, 65)
    local resizeIcon = create("ImageLabel", {
        Name = "ResizeGrip",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(18, 18),
        BackgroundTransparency = 1,
        Image = "rbxassetid://108276481377469",
        ImageColor3 = resizeIconColor,
        ZIndex = 251,
    }, resizeHandle)

    local resizing = false
    local resizeStart = nil
    local startSize = nil
    local startTopLeft = nil

    local function setResizeGripColor(color)
        playTween(resizeIcon, 0.15, { ImageColor3 = color })
    end

    resizeHandle.MouseEnter:Connect(function()
        setResizeGripColor(Color3.fromRGB(255, 255, 255))
    end)
    resizeHandle.MouseLeave:Connect(function()
        if not resizing then
            setResizeGripColor(resizeIconColor)
        end
    end)

    -- Seamless Zero-Jump Anchor Point Switching
    local function ensureTopLeftAnchored()
        if shell.AnchorPoint ~= Vector2.new(0, 0) then
            local absPos = shell.AbsolutePosition
            shell.AnchorPoint = Vector2.new(0, 0)
            shell.Position = UDim2.fromOffset(absPos.X, absPos.Y)
        end
    end

    local function updateDynamicLayout()
        local w = shell.AbsoluteSize.X
        local h = shell.AbsoluteSize.Y

        if w < 740 then
            -- Compact Single-Column Mode: userPanel collapses, mainPanel fills 100%
            userPanel.Visible = false
            mainPanel.Position = UDim2.fromOffset(10, 10)
            mainPanel.Size = UDim2.new(1, -20, 1, -20)
        else
            -- Wide Dual-Column Mode: userPanel pinned at 272px, mainPanel expands seamlessly
            userPanel.Position = UDim2.fromOffset(10, 10)
            userPanel.Size = UDim2.new(0, 272, 1, -20)
            userPanel.Visible = true

            mainPanel.Position = UDim2.fromOffset(292, 10)
            mainPanel.Size = UDim2.new(1, -302, 1, -20)
        end
    end

    -- Resize Input Began
    resizeHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            resizing = true
            resizeStart = input.Position
            startSize = shell.AbsoluteSize
            ensureTopLeftAnchored()
            startTopLeft = shell.AbsolutePosition
            setResizeGripColor(Color3.fromRGB(255, 75, 105))

            local endConn
            endConn = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    resizing = false
                    setResizeGripColor(resizeIconColor)
                    if endConn then endConn:Disconnect() end
                    -- Update background artwork & particle bounds cleanly on drag release (ตอนปล่อยมือ)
                    pcall(function() strikeLightning(lightningLayer, 3) end)
                end
            end)
        end
    end)

    -- Window Header Dragging (Move)
    local dragging = false
    local dragStart, dragStartPos
    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            ensureTopLeftAnchored()
            dragStartPos = shell.AbsolutePosition
        end
    end)

    local dEndedConn = UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
            if resizing then
                resizing = false
                setResizeGripColor(resizeIconColor)
            end
        end
    end)
    table.insert(trackedConnections, dEndedConn)

    -- Combined Mouse / Touch Movement Handler
    local moveConn = UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then
            return
        end

        local camera = workspace.CurrentCamera
        local currentViewport = camera and camera.ViewportSize or Vector2.new(1920, 1080)

        -- Handle Resizing
        if resizing then
            local maxWidth = math.max(MIN_SIZE.X, currentViewport.X - startTopLeft.X - VIEWPORT_MARGIN)
            local maxHeight = math.max(MIN_SIZE.Y, currentViewport.Y - startTopLeft.Y - VIEWPORT_MARGIN)
            local delta = input.Position - resizeStart

            local newW = math.clamp(startSize.X + delta.X, MIN_SIZE.X, maxWidth)
            local newH = math.clamp(startSize.Y + delta.Y, MIN_SIZE.Y, maxHeight)

            shell.Size = UDim2.fromOffset(newW, newH)
            updateDynamicLayout()
        end

        -- Handle Header Dragging
        if dragging then
            local delta = input.Position - dragStart
            local newX = math.clamp(dragStartPos.X + delta.X, 0, currentViewport.X - 100)
            local newY = math.clamp(dragStartPos.Y + delta.Y, 0, currentViewport.Y - 60)
            shell.Position = UDim2.fromOffset(newX, newY)
        end
    end)
    table.insert(trackedConnections, moveConn)

    local function applyResponsiveLayout()
        local camera = workspace.CurrentCamera
        local viewport = camera and camera.ViewportSize or Vector2.new(1280, 720)
        local isMobile = (deviceName() == "Mobile")
        local isNarrow = isMobile or (viewport.X < 860)

        if not resizing and not dragging then
            if isNarrow then
                shell.Size = UDim2.fromOffset(math.clamp(viewport.X - 32, MIN_SIZE.X, COMPACT_WIDTH), math.clamp(viewport.Y - 48, MIN_SIZE.Y, SHELL_HEIGHT))
            else
                shell.Size = UDim2.fromOffset(math.clamp(viewport.X - 48, MIN_SIZE.X, DESKTOP_WIDTH), math.clamp(viewport.Y - 60, MIN_SIZE.Y, SHELL_HEIGHT))
            end
            updateDynamicLayout()
        end

        -- Keep UIScale at 1 for razor sharp rendering, only scaling down if viewport is smaller than MIN_SIZE
        local minScaleX = (viewport.X - 20) / MIN_SIZE.X
        local minScaleY = (viewport.Y - 20) / MIN_SIZE.Y
        local fitScale = math.clamp(math.min(minScaleX, minScaleY, 1), 0.5, 1)
        if shellScale then shellScale.Scale = fitScale end
    end

    applyResponsiveLayout()
    local vpConn = workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(applyResponsiveLayout)
    table.insert(trackedConnections, vpConn)

    -- Cleanup guard on ScreenGui destroy
    gui.Destroying:Connect(function()
        pcall(function()
            for _, conn in ipairs(trackedConnections) do pcall(function() conn:Disconnect() end) end
            for _, th in ipairs(trackedThreads) do pcall(task.cancel, th) end
        end)
    end)

    -- Intro Animation
    task.spawn(function()
        playTween(backdrop, MOTION.slow, { BackgroundTransparency = 0.72 })
        playTween(shell, MOTION.slow, { GroupTransparency = 0 }, nil, nil, "visibility")
        strikeLightning(shellChrome, 6)
    end)
end

-- ==============================================================================
-- 🚀 SMART AUTO-LOGIN FLOW
-- ==============================================================================
if getgenv and getgenv().PayomboyZ_LoggedOut then
    getgenv().PayomboyZ_LoggedOut = nil
    _isScriptLaunched = false
    _isAuthenticating = false
    _ENV.__PAYOMBOYZ_SCRIPT_LAUNCHED = false
    ClearSavedKeys()
    local passedKey = GetPassedScriptKey()
    CreateLoaderUI("✅ ออกจากระบบเรียบร้อยแล้ว กรุณากรอกคีย์ใหม่", passedKey)
    return
end

if getgenv and getgenv().PayomboyZ_ShowUI then
    local passedKey = GetPassedScriptKey()
    _isScriptLaunched = false
    _isAuthenticating = false
    _ENV.__PAYOMBOYZ_SCRIPT_LAUNCHED = false
    CreateLoaderUI(getgenv().PayomboyZ_ErrorMsg or "❌ คีย์หมดอายุ! กรุณากรอกใหม่", passedKey)
    getgenv().PayomboyZ_ShowUI = false
    return
end

if not game:IsLoaded() then
    game.Loaded:Wait()
end

if _ENV.__PAYOMBOYZ_SCRIPT_LAUNCHED then
    warn("[PAYOMBØYZ HUB] Game script already running in this session, skipping loader.")
    return
end

local activeKey = ""
for attempt = 1, 10 do
    local passedKey = GetPassedScriptKey()
    local savedKey = LoadSavedKey()
    activeKey = (passedKey ~= "" and passedKey) or (savedKey ~= "" and savedKey) or ""
    if activeKey ~= "" then break end
    task.wait(0.05)
end

if activeKey ~= "" then
    -- Fast silent auto-login check
    task.spawn(function()
        local okAuth, reason = VerifyKey(activeKey)
        if okAuth then
            local placeId = game.PlaceId
            local gameData = SupportedGames[placeId]
            local targetUrl = gameData and gameData.URL or "https://raw.githubusercontent.com/Payomboyz0028/Yaranikaaaa/refs/heads/main/WaitKey"
            local engine = GetRemoteKeyData()
            if engine and type(engine.GetGameURL) == "function" then
                pcall(function()
                    local resUrl = engine.GetGameURL(placeId, activeKey)
                    if resUrl and resUrl ~= targetUrl then targetUrl = resUrl end
                end)
            end
            RunGameScript(targetUrl, activeKey, function()
                CreateLoaderUI("⚠️ โหลดสคริปต์ล้มเหลว กรุณากรอกคีย์ใหม่", activeKey)
            end)
        else
            CreateLoaderUI(reason or "❌ คีย์เดิมหมดอายุแล้ว กรุณากรอก Key ใหม่", activeKey)
        end
    end)
else
    CreateLoaderUI(nil, "")
end
