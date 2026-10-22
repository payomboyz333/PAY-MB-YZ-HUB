-- ================================================================
-- PAYOMBØYZ อนิเมะเต๋าไปกับพยอมบอย
-- Edited By Ayaya & ANON
-- Target: [🎉UPD 5] Anime Dice
-- Features:
--   1. Master Kai Tan Auto Farm (All-in-One Lv.1 - Max Account)
--   2. IRONCLAD Auto-Sell Protection (Never sells Huge, Titanic, Mutated, or 1/500+ units)
--   3. Auto Equip Best Immediately on Roll (Secures god rolls before any sell check)
--   4. Auto Max Skill Tree (86/86 Upgrades) with Live Progress Tracker
--   5. Auto Stop on Max Account (Stops when Rebirth 13, Frostfire & Tree are 100% maxed)
--   6. Dynamic Auto-Updating Dice Target & Tree HUD
--   7. Smart Budget Manager (Protects currency for Rebirth & Next Dice)
--   8. Bilingual System (EN Primary / TH Secondary) with Live Toggle
--   9. 8-Tab Clean Layout with Zero Overflow & Page Navigation (◀ / ▶)
--  10. Festival & Seasonal Particle Engine (6 Festivals + 5 Seasons + Auto)
--  11. Draggable HUD Pill: Avatar, Username, FPS, Ping, UI Toggle
-- ================================================================

-- ─── Single Instance Guard & Session Cleanup ─────────────────
pcall(function()
	if _G.AnimeDice_SessionCleanup then
		pcall(_G.AnimeDice_SessionCleanup)
	end
end)

local CURRENT_SESSION_ID = tick()
_G.AnimeDice_Session = CURRENT_SESSION_ID
local sessionStartTime = os.clock()

pcall(function()
	local cg = game:GetService("CoreGui")
	for _, c in ipairs(cg:GetChildren()) do
		if c.Name == "AnimeDiceHUD" or c.Name == "AnimeDice_TelemetryHUD" or c.Name == "RideAPetHUD" or c.Name:match("^%x%x%x%x%x%x%x%x%-%x%x%x%x") then
			c:Destroy()
		end
	end
	local pg = game:GetService("Players").LocalPlayer:FindFirstChildOfClass("PlayerGui")
	if pg then
		for _, c in ipairs(pg:GetChildren()) do
			if c.Name == "AnimeDiceHUD" or c.Name == "AnimeDice_TelemetryHUD" or c.Name == "RideAPetHUD" or c.Name:match("^%x%x%x%x%x%x%x%x%-%x%x%x%x") then
				c:Destroy()
			end
		end
	end
end)

-- ─── Services ────────────────────────────────────────────────
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local StarterGui = game:GetService("StarterGui")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer

-- ─── Config Persistence ──────────────────────────────────────
local CONFIG_FOLDER = "PayomboyZ Hub/" .. tostring(game.GameId)
local CONFIG_FILE = CONFIG_FOLDER .. "/Anime-Dice.json"
local savedConfig = {}
local saveQueued = false

local function ensureConfigFolder()
	if type(isfolder) ~= "function" or type(makefolder) ~= "function" then
		return false
	end
	pcall(function()
		if not isfolder("PayomboyZ Hub") then
			makefolder("PayomboyZ Hub")
		end
		if not isfolder(CONFIG_FOLDER) then
			makefolder(CONFIG_FOLDER)
		end
	end)
	return true
end

local function loadConfig()
	if type(isfile) ~= "function" or type(readfile) ~= "function" then
		return
	end
	local ok, decoded = pcall(function()
		if not isfile(CONFIG_FILE) then
			return nil
		end
		return HttpService:JSONDecode(readfile(CONFIG_FILE))
	end)
	if ok and type(decoded) == "table" then
		savedConfig = decoded
	end
end

local function scheduleConfigSave()
	if saveQueued or type(writefile) ~= "function" then
		return
	end
	saveQueued = true
	task.delay(0.25, function()
		saveQueued = false
		if not ensureConfigFolder() then
			return
		end
		pcall(function()
			writefile(CONFIG_FILE, HttpService:JSONEncode(savedConfig))
		end)
	end)
end

local function getSavedValue(key, fallback)
	if savedConfig[key] ~= nil then
		return savedConfig[key]
	end
	return fallback
end

local function saveSetting(key, value)
	savedConfig[key] = value
	scheduleConfigSave()
end

local function getSavedSelection(key, fallback, multiple)
	local value = getSavedValue(key, fallback)
	if multiple then
		return type(value) == "table" and value or fallback
	end
	if type(value) == "table" then
		return value[1] or fallback
	end
	return value or fallback
end

loadConfig()

-- ─── I18n System (EN Primary / TH Secondary) ─────────────────
local LANG = getSavedValue("AnimeDiceLanguage", "TH")
if LANG ~= "EN" and LANG ~= "TH" then
	LANG = "TH"
end

local i18n = {
	EN = {
		-- Window & Branding
		project_title   = "PAYOMBØYZ ANIME DICE AUTO-FARM",
		edited_by       = "Edited By Ayaya & ANON",
		window_collapse = "Minimize / Expand script window",

		-- Tab Titles (8 Tabs)
		tab_roll        = "Roll & Kai Tan",
		tab_plot        = "Plot & Farm",
		tab_shop        = "Shop & Upgrades",
		tab_units       = "Units & Progression",
		tab_towers      = "Tower & Quests",
		tab_sell        = "Smart Auto Sell",
		tab_potions     = "Boost Potions",
	tab_halloween   = "Halloween Event",
	header_hw_status = "Halloween Event Status & Teleport",
	halloween_teleport = "Teleport to Halloween Island",
	halloween_hub    = "Teleport to Main Hub",
	header_hw_tot   = "Auto Trick or Treat",
	halloween_tot   = "Auto Trick or Treat Doors",
	halloween_tot_inf = "Visits all 7 doors safely to farm Candy, Potions, and Jackpots.",
	halloween_tot_speed = "Door Walk Speed",
	header_hw_haunted = "Auto Haunted House Tower",
	halloween_haunted = "Auto Haunted House",
	halloween_haunted_inf = "Automates Haunted House tower runs to farm Pumpkins and Gears.",
	halloween_haunted_wing = "Select Haunted Wing",
	header_hw_dice  = "Auto Pumpkin Dice",
	halloween_pumpkin_dice = "Auto Roll Pumpkin Dice",
	halloween_pumpkin_dice_inf = "Rolls the Halloween Pumpkin Dice using collected Pumpkins.",
	halloween_dice_mode = "Roll Multiplier",
	header_hw_rewards = "Halloween Pass & Quests",
	halloween_pass  = "Auto Claim Pumpkin Pass",
	halloween_pass_inf = "Claims all unlocked free and premium pass tiers.",
	halloween_quests = "Auto Claim Halloween Quests",
	halloween_quests_inf = "Claims completed Hourly, Daily, and Event Halloween quests.",
	header_hw_shop  = "Halloween Candy Shop",
	halloween_shop  = "Auto Buy Candy Shop",
	halloween_shop_inf = "Buys selected items when Candy is available.",
	halloween_shop_item = "Select Shop Item",
		tab_settings    = "Settings & Misc",

		-- Master Kai Tan Auto Farm
		header_kaitan   = "⭐ Kai Tan Auto Farm (All-in-One Lv.1 - Max)",
		kaitan_tog      = "Auto Farm Kai Tan Mode",
		kaitan_inf      = "Fully automates everything from Level 1: Roll, Safe Sell, Collect, Equip Best, Buy Dice, Rebirth, Upgrades & Quests.",
		kaitan_btn      = "Trigger Kai Tan Full Pass",
		auto_stop_tog   = "Auto-Stop When Account Maxed",
		auto_stop_inf   = "Stops auto rolling when Rebirth (13), Dice (Frostfire), and Tree (86/86) are 100% completed.",

		-- Tab 1: Roll
		header_roll     = "Dice Rolling",
		fast_roll_tog   = "Fast Roll",
		fast_roll_inf   = "Roll continuously using the fastest safe server cooldown.",
		reset_counter   = "Reset roll counter",
		reset_btn       = "Reset",

		-- Tab 2: Plot & Farm
		header_plot     = "Plot Income & Teams",
		auto_collect    = "Collect Plot Income",
		auto_coll_inf   = "Collect income from every unlocked plot slot.",
		collect_sec     = "Collect interval",
		auto_equip      = "Equip Best Units",
		auto_equip_inf  = "Regularly equip the strongest available units.",
		equip_sec       = "Equip interval",
		collect_now     = "Collect now",
		collect_btn     = "Collect",

		-- Tab 3: Shop & Upgrades
		header_shop     = "Dice Shop",
		buy_dice_tog    = "Buy Better Dice",
		buy_dice_inf    = "Buy affordable dice and automatically equip the best one owned.",
		equip_dice_btn  = "Equip best owned dice",
		equip_btn       = "Equip",
		header_upgrade  = "Account Upgrades",
		auto_tree_tog   = "Auto Max Skill Tree (86/86)",
		auto_tree_inf   = "Systematically buy and unlock the entire upgrade tree until completely maxed.",
		buy_upg_tog     = "Buy Specific Upgrades",
		buy_upg_inf     = "Purchase selected account upgrades when affordable.",
		upg_branches    = "Branches to upgrade",
		buy_upg_btn     = "Buy available upgrades",
		buy_btn         = "Buy",

		-- Tab 4: Units & Progression
		header_level    = "Unit Leveling",
		level_tog       = "Level Plotted Units",
		level_inf       = "Level plotted units up to your selected target with budget protection.",
		min_rarity      = "Minimum rarity (plotted units)",
		target_lvl      = "Target level",
		run_pass_btn    = "Run a pass",
		run_btn         = "Run",
		header_grades   = "Unit Grades",
		reroll_grades   = "Reroll Unit Grades",
		reroll_grd_inf  = "Reroll eligible unit grades toward your target grade.",
		target_grade    = "Target grade",
		protect_s_plus  = "Overwrite protected tiers (S+)",
		header_traits   = "Unit Traits",
		reroll_traits   = "Reroll Unit Traits",
		reroll_trt_inf  = "Reroll eligible unit traits toward your target trait.",
		target_trait    = "Target trait",
		protect_shogun  = "Overwrite protected tiers (Samurai/Shogun)",
		header_rebirth  = "Rebirth",
		rebirth_tog     = "Rebirth Automatically",
		rebirth_inf     = "Rebirth automatically whenever the cost is affordable.",
		rebirth_now     = "Rebirth now",
		rebirth_btn     = "Rebirth",

		-- Tab 5: Tower & Quests
		header_tower    = "Tower Runs",
		tower_tog       = "Run Dragon Tower",
		tower_inf       = "Run Dragon Tower repeatedly and complete its floors.",
		re_equip_run    = "Re-equip before each run",
		equip_team_btn  = "Equip best team",
		header_quests   = "Quest Rewards",
		quests_tog      = "Claim Quest Rewards",
		quests_inf      = "Claim completed daily and weekly quest rewards.",
		claim_now_btn   = "Claim now",
		claim_btn       = "Claim",

		-- Tab 6: Smart Auto Sell
		header_sell     = "Inventory Selling",
		sell_tog        = "Auto Sell Units",
		sell_inf        = "Smart auto-sell: Sells selected rarities, supports selling duplicate Huge/Titanic (always preserves best copy).",
		sell_dup_huge   = "Sell Duplicate Huge",
		sell_dup_huge_inf = "Keep 1 best copy of each Huge unit and sell excess duplicates.",
		sell_dup_titanic = "Sell Duplicate Titanic",
		sell_dup_titanic_inf = "Keep 1 best copy of each Titanic unit and sell excess duplicates (for endgame max luck).",
	tower_hide_tog  = "Auto Hide Tower Screen",
	tower_hide_inf  = "Minimizes tower battle cards so the main screen stays visible.",
	sell_all_mut    = "Rarities to sell (any mutation)",
		sell_req_mut    = "Rarities requiring a mutation",
		sell_mut_list   = "Mutations to sell",
		sell_interval   = "Sell interval",
		sell_now_btn    = "Sell now",
		sell_btn        = "Sell",

		-- Tab 7: Boost Potions
		header_potions  = "Boost Potions",
		potions_tog     = "Use Best Potions",
		potions_inf     = "Use the best selected potion when its boost is inactive.",
		luck_potions    = "Luck potions",
		money_potions   = "Income potions",
		damage_potions  = "Damage potions",
		use_potions     = "Use potions now",
		use_btn         = "Use",

		-- Tab 8: Settings & Misc
		header_lang     = "Language Settings",
		lang_btn        = "Language: EN  (Switch TH)",
		lang_info       = "Click to switch language to Thai.",
		header_particle = "Festival Particles",
		particle_tog    = "Enable Decor Particles",
		particle_inf    = "Show effects by festival or season.",
		particle_drop   = "Festival & Season Theme",
		header_misc     = "Utilities",
		anti_afk_tog    = "Prevent Idle Kick (Anti-AFK)",
		anti_afk_inf    = "Send periodic input to prevent the Roblox 20-minute idle kick.",

		-- HUD & Notifications
		hud_fps         = "FPS",
		hud_ping        = "Ping",
		notif_collect   = "Collect",
		notif_nothing   = "Nothing to collect.",
		notif_levelup   = "Level Up",
		notif_no_level  = "No units eligible to level up.",
		notif_dice      = "Dice",
		notif_dice_best = "Best owned dice is already equipped.",
		notif_upgrades  = "Upgrades",
		notif_no_upg    = "Not enough cash for selected upgrades.",
		notif_tower     = "Tower",
		notif_team_upd  = "Best team updated.",
		notif_quests    = "Quests",
		notif_no_quest  = "No quest rewards available.",
		notif_rebirth   = "Rebirth",
		notif_max_lvl   = "Max level reached (%d)",
		notif_missing   = "Need $%s more",
		notif_potions   = "Potions",
		notif_no_pot    = "No eligible potions to use.",
		notif_sell      = "Sell",
		notif_no_sell   = "No eligible units to sell.",
	},
	TH = {
		-- Window & Branding
		project_title   = "PAYOMBØYZ อนิเมะเต๋าไปกับพยอมบอย",
		edited_by       = "Edited By Ayaya & ANON",
		window_collapse = "ย่อ / ขยาย หน้าต่างสคริปต์",

		-- Tab Titles (8 Tabs)
		tab_roll        = "สุ่มเต๋า & บอทไก่ตัน",
		tab_plot        = "ฟาร์มแปลง (Plot & Farm)",
		tab_shop        = "ร้านค้า & อัปเกรด (Shop & Upgrades)",
		tab_units       = "ยูนิต & จุติ (Units & Progression)",
		tab_towers      = "หอคอย & เควสต์ (Tower & Quests)",
		tab_sell        = "ขายยูนิตอัตโนมัติ (Smart Auto Sell)",
		tab_potions     = "น้ำยาบัฟ (Boost Potions)",
		tab_halloween   = "กิจกรรมฮาโลวีน (Halloween Event)",
		header_hw_status = "สถานะกิจกรรม & วาร์ปแผนที่",
		halloween_teleport = "วาร์ปแผนที่ไปเกาะฮาโลวีน (Teleport Island)",
		halloween_hub    = "วาร์ปกลับเมืองหลัก (Return Hub)",
		header_hw_tot   = "เคาะประตูฮาโลวีนอัตโนมัติ (Trick or Treat)",
		halloween_tot   = "เดินเคาะประตูอัตโนมัติ (Auto Trick or Treat)",
		halloween_tot_inf = "เดินเคาะประตูทั้ง 7 บานอย่างปลอดภัยเพื่อฟาร์ม Candy และแจ็กพอต",
		halloween_tot_speed = "ความเร็วในการเดินเคาะประตู",
		header_hw_haunted = "หอคอยบ้านผีสิงอัตโนมัติ (Haunted House)",
		halloween_haunted = "ลงหอคอยบ้านผีสิงอัตโนมัติ (Auto Haunted House)",
		halloween_haunted_inf = "ลงหอคอยบ้านผีสิงอัตโนมัติเพื่อฟาร์ม Pumpkins, Candy และไอเทมสวมใส่",
		halloween_haunted_wing = "เลือกชั้นหอคอยบ้านผีสิง",
		header_hw_dice  = "สุ่มเต๋าฟักทองอัตโนมัติ (Pumpkin Dice)",
		halloween_pumpkin_dice = "สุ่มเต๋าฟักทองอัตโนมัติ (Auto Roll Pumpkin Dice)",
		halloween_pumpkin_dice_inf = "สุ่มเต๋าฟักทองอัตโนมัติโดยใช้ Pumpkins ที่ฟาร์มได้",
		halloween_dice_mode = "จำนวนเต๋าที่สุ่มต่อครั้ง",
		header_hw_rewards = "รางวัลพาส & เควสต์ฮาโลวีน",
		halloween_pass  = "รับของรางวัล Pumpkin Pass อัตโนมัติ",
		halloween_pass_inf = "กดรับของรางวัลทุกขั้นใน Pumpkin Pass ที่ปลดล็อกแล้วโดยอัตโนมัติ",
		halloween_quests = "รับเควสต์ฮาโลวีนอัตโนมัติ",
		halloween_quests_inf = "กดรับเควสต์ฮาโลวีนรายชั่วโมงและรายวันที่ทำสำเร็จโดยอัตโนมัติ",
		header_hw_shop  = "ร้านค้าลูกกวาดฮาโลวีน (Candy Shop)",
		halloween_shop  = "ซื้อของร้านค้าฮาโลวีนอัตโนมัติ",
		halloween_shop_inf = "ซื้อน้ำยาหรือแจ็กพอตที่เลือกไว้เมื่อมี Candy เพียงพอ",
		halloween_shop_item = "เลือกไอเทมที่จะซื้อ",
		tab_settings    = "ตั้งค่า & อื่นๆ (Settings & Misc)",

		-- Master Kai Tan Auto Farm
		header_kaitan   = "⭐ โหมดฟาร์มไก่ตัน อัตโนมัติ (Kai Tan Lv.1 - Max)",
		kaitan_tog      = "เปิดบอทไก่ตัน (ฟาร์มตั้งแต่เวล 1)",
		kaitan_inf      = "ทำงานอัตโนมัติครบวงจร: ทอยเต๋า, เซฟตัวเทพ, เก็บเงินแปลง, ใส่ตัวเทพ, ซื้อเต๋าใหม่, จุติ, อัปเกรด, รับเควสต์",
		kaitan_btn      = "รันระบบไก่ตันหนึ่งรอบทันที",
		auto_stop_tog   = "หยุดฟาร์มอัตโนมัติเมื่อไอดีตัน 100%",
		auto_stop_inf   = "หยุดทอยเต๋าเมื่อจุติครบ (13), เต๋าตัน (Frostfire), และต้นไม้ตัน (86/86) สมบูรณ์แล้ว",

		-- Tab 1: Roll
		header_roll     = "ระบบทอยลูกเต๋า",
		fast_roll_tog   = "สุ่มเต๋าไว (Fast Roll)",
		fast_roll_inf   = "สุ่มเต๋าต่อเนื่องอัตโนมัติตามคูลดาวน์ที่เร็วและปลอดภัยที่สุด",
		reset_counter   = "รีเซ็ตตัวนับจำนวนครั้งที่สุ่ม",
		reset_btn       = "รีเซ็ต",

		-- Tab 2: Plot & Farm
		header_plot     = "จัดการพื้นที่ฟาร์ม (Plot)",
		auto_collect    = "เก็บเงินฟาร์มอัตโนมัติ",
		auto_coll_inf   = "เก็บเงินรายได้จากทุกช่องแปลงฟาร์มที่ปลดล็อกแล้ว",
		collect_sec     = "ระยะเวลาเก็บเงิน (วินาที)",
		auto_equip      = "สวมใส่ยูนิตที่ดีที่สุดอัตโนมัติ",
		auto_equip_inf  = "ใส่ยูนิตที่แข็งแกร่งที่สุดลงแปลงฟาร์มสม่ำเสมอ",
		equip_sec       = "ระยะเวลาสวมใส่ (วินาที)",
		collect_now     = "เก็บเงินตอนนี้ทันที",
		collect_btn     = "เก็บเงิน",

		-- Tab 3: Shop & Upgrades
		header_shop     = "ร้านค้าลูกเต๋า (Dice Shop)",
		buy_dice_tog    = "ซื้อลูกเต๋าที่ดีขึ้นอัตโนมัติ",
		buy_dice_inf    = "ซื้อเต๋าใหม่เมื่อเงินพอ และสวมใส่เต๋าที่ดีที่สุดให้อัตโนมัติ",
		equip_dice_btn  = "สวมใส่ลูกเต๋าที่ดีที่สุดที่มี",
		equip_btn       = "สวมใส่",
		header_upgrade  = "อัปเกรดไอดี (Account Upgrades)",
		auto_tree_tog   = "ออโต้ทำต้นไม้ตัน (ครบ 86 สกิล)",
		auto_tree_inf   = "ซื้อและปลดล็อกสายอัปเกรดต้นไม้ทั้งหมดอัตโนมัติจนกว่าจะตันครบทุกช่อง (Fortune, Luck, Money ฯลฯ)",
		buy_upg_tog     = "ซื้อเฉพาะสายที่เลือก",
		buy_upg_inf     = "ซื้อสายอัปเกรดไอดีที่เลือกไว้เมื่อมีเงินเพียงพอ",
		upg_branches    = "เลือกสายที่ต้องการอัปเกรด",
		buy_upg_btn     = "ซื้ออัปเกรดที่พร้อมซื้อตอนนี้",
		buy_btn         = "ซื้อทันที",

		-- Tab 4: Units & Progression
		header_level    = "อัปเลเวลยูนิต (Unit Leveling)",
		level_tog       = "อัปเลเวลยูนิตในแปลงฟาร์ม",
		level_inf       = "อัปเลเวลยูนิตที่วางอยู่ในแปลงจนถึงเลเวลเป้าหมาย (มีระบบกันเงินไม่ให้กระทบเต๋า/จุติ)",
		min_rarity      = "ระดับความหายากขั้นต่ำ (ยูนิตในแปลง)",
		target_lvl      = "เลเวลเป้าหมาย",
		run_pass_btn    = "อัปเลเวลหนึ่งรอบทันที",
		run_btn         = "เริ่มอัป",
		header_grades   = "รีเกรดยูนิต (Unit Grades)",
		reroll_grades   = "สุ่มเกรดยูนิตอัตโนมัติ",
		reroll_grd_inf  = "สุ่มเกรดยูนิตที่ผ่านเงื่อนไขไปจนถึงระดับเป้าหมาย",
		target_grade    = "เกรดเป้าหมาย",
		protect_s_plus  = "สุ่มทับระดับที่ป้องกันไว้ (S+)",
		header_traits   = "รีลักษณะพิเศษ (Unit Traits)",
		reroll_traits   = "สุ่มลักษณะยูนิตอัตโนมัติ",
		reroll_trt_inf  = "สุ่ม Trait ของยูนิตที่เลือกไปจนถึง Trait เป้าหมาย",
		target_trait    = "ลักษณะ (Trait) เป้าหมาย",
		protect_shogun  = "สุ่มทับระดับที่ป้องกันไว้ (Samurai/Shogun)",
		header_rebirth  = "จุติใหม่ (Rebirth)",
		rebirth_tog     = "จุติใหม่อัตโนมัติ (Auto Rebirth)",
		rebirth_inf     = "ทำการรีเบิร์ทอัตโนมัติทันทีเมื่อเงินและเงื่อนไขครบ",
		rebirth_now     = "รีเบิร์ทตอนนี้ทันที",
		rebirth_btn     = "รีเบิร์ท",

		-- Tab 5: Tower & Quests
		header_tower    = "ลงหอคอยมังกร (Tower Runs)",
		tower_tog       = "ลงหอคอยมังกรอัตโนมัติ",
		tower_inf       = "ลงหอคอย Dragon Tower ซ้ำๆ และผ่านชั้นให้อัตโนมัติ",
		re_equip_run    = "จัดทีมยูนิตที่ดีที่สุดก่อนลงทุกรอบ",
		equip_team_btn  = "จัดทีมยูนิตที่ดีที่สุดทันที",
		header_quests   = "ของรางวัลภารกิจ (Quests)",
		quests_tog      = "รับรางวัลเควสต์อัตโนมัติ",
		quests_inf      = "กดรับรางวัลภารกิจรายวันและรายสัปดาห์ที่ทำเสร็จแล้ว",
		claim_now_btn   = "กดรับรางวัลเควสต์ทันที",
		claim_btn       = "รับรางวัล",

		-- Tab 6: Smart Auto Sell
		header_sell     = "ขายยูนิตในกระเป๋า (Auto Sell)",
		sell_tog        = "ขายยูนิตอัตโนมัติ",
		sell_inf        = "ระบบขายอัจฉริยะ: ขายยูนิตตามเงื่อนไขที่เลือก รองรับขายตัว Huge/Titanic ที่ซ้ำ (เก็บตัวดาวสูงสุดไว้ 1 ตัวเสมอ)",
		sell_dup_huge   = "ขายตัว Huge ที่ซ้ำ (Sell Duplicate Huge)",
		sell_dup_huge_inf = "เก็บ Huge ที่ดีที่สุดประเภทละ 1 ตัว และขายตัวที่ซ้ำกัน",
		sell_dup_titanic = "ขายตัว Titanic ที่ซ้ำ (Sell Duplicate Titanic)",
		sell_dup_titanic_inf = "เก็บ Titanic ที่ดีที่สุดประเภทละ 1 ตัว และขายตัวที่ซ้ำกัน (สำหรับไอดีดวงตันที่ตัวล้นกระเป๋า)",
	tower_hide_tog  = "ซ่อนหน้าต่างหอคอยอัตโนมัติ",
	tower_hide_inf  = "ย่อการ์ดต่อสู้ของหอคอยอัตโนมัติ เพื่อให้มองเห็นหน้าจอเกมหลัก",
	sell_all_mut    = "ระดับความหายากที่จะขาย (ทุกการกลายพันธุ์)",
		sell_req_mut    = "ระดับความหายากที่ต้องมีการกลายพันธุ์ถึงจะขาย",
		sell_mut_list   = "การกลายพันธุ์ที่จะขาย (Mutations)",
		sell_interval   = "ระยะเวลาขาย (วินาที)",
		sell_now_btn    = "ขายยูนิตตามเงื่อนไขทันที",
		sell_btn        = "ขายทันที",

		-- Tab 7: Boost Potions
		header_potions  = "น้ำยาบัฟ (Boost Potions)",
		potions_tog     = "กดใช้น้ำยาที่ดีที่สุดอัตโนมัติ",
		potions_inf     = "ใช้น้ำยาบัฟที่ดีที่สุดเมื่อผลของบัฟนั้นหมดลง",
		luck_potions    = "น้ำยาเพิ่มดวง (Luck)",
		money_potions   = "น้ำยาเพิ่มเงิน (Income)",
		damage_potions  = "น้ำยาเพิ่มพลังโจมตี (Damage)",
		use_potions     = "กดใช้น้ำยาทันที",
		use_btn         = "ใช้น้ำยา",

		-- Tab 8: Settings & Misc
		header_lang     = "ตั้งค่าภาษา / Language",
		lang_btn        = "ภาษา: ไทย  (สลับ EN)",
		lang_info       = "คลิกเพื่อสลับเป็นภาษาอังกฤษ",
		header_particle = "อนุภาคตกแต่งตามเทศกาล (Particles)",
		particle_tog    = "เปิดใช้งานอนุภาคตกแต่ง",
		particle_inf    = "แสดงเอฟเฟกต์ตามเทศกาลหรือฤดูกาลในบรรยากาศหน้าต่างสคริปต์",
		particle_drop   = "เลือกธีมเทศกาล / ฤดูกาล",
		header_misc     = "ระบบเบ็ดเตล็ด",
		anti_afk_tog    = "ป้องกันการหลุดจากการอยู่เฉย (Anti-AFK)",
		anti_afk_inf    = "ส่งการขยับเมาส์จำลองเป็นระยะ เพื่อไม่ให้ Roblox เตะออกจากเกมหลัง 20 นาที",

		-- HUD & Notifications
		hud_fps         = "FPS",
		hud_ping        = "Ping",
		notif_collect   = "เก็บเงินฟาร์ม",
		notif_nothing   = "ไม่มีเงินให้เก็บในขณะนี้",
		notif_levelup   = "อัปเลเวลยูนิต",
		notif_no_level  = "ไม่มียูนิตที่สามารถอัปได้",
		notif_dice      = "ลูกเต๋า",
		notif_dice_best = "สวมใส่เต๋าที่ดีที่สุดอยู่แล้ว",
		notif_upgrades  = "อัปเกรดไอดี",
		notif_no_upg    = "เงินไม่พอสำหรับอัปเกรดที่เลือก",
		notif_tower     = "หอคอย",
		notif_team_upd  = "อัปเดตทีมเรียบร้อยแล้ว",
		notif_quests    = "ภารกิจ",
		notif_no_quest  = "ไม่มีเควสต์ที่พร้อมรับรางวัล",
		notif_rebirth   = "จุติใหม่ (Rebirth)",
		notif_max_lvl   = "ถึงเลเวลสูงสุดแล้ว (%d)",
		notif_missing   = "เงินขาดอีก $%s",
		notif_potions   = "น้ำยาบัฟ",
		notif_no_pot    = "ไม่มีน้ำยาที่พร้อมใช้",
		notif_sell      = "ขายยูนิต",
		notif_no_sell   = "ไม่มียูนิตที่เข้าเงื่อนไขการขาย",
	}
}

local function T(key)
	if i18n[LANG] and i18n[LANG][key] then
		return i18n[LANG][key]
	end
	return (i18n.TH and i18n.TH[key]) or (i18n.EN and i18n.EN[key]) or tostring(key)
end

-- ─── Live Hot-Swapping Translation Maps ───────────────────────
local en_to_th = {}
local th_to_en = {}

local function rebuildTranslationMaps()
	table.clear(en_to_th)
	table.clear(th_to_en)
	for k, enVal in pairs(i18n.EN) do
		local thVal = i18n.TH[k]
		if type(enVal) == "string" and type(thVal) == "string" then
			en_to_th[enVal] = thVal
			th_to_en[thVal] = enVal
		end
	end

	local tab_keys = {
		"tab_roll", "tab_plot", "tab_shop", "tab_units",
		"tab_towers", "tab_sell", "tab_potions", "tab_halloween", "tab_settings"
	}
	for i, key in ipairs(tab_keys) do
		local enT = ("%s (%d/9)"):format(i18n.EN[key], i)
		local thT = ("%s (%d/9)"):format(i18n.TH[key], i)
		en_to_th[enT] = thT
		th_to_en[thT] = enT
	end

	en_to_th["Language: EN  (Switch TH)"] = "ภาษา: ไทย  (สลับ EN)"
	th_to_en["ภาษา: ไทย  (สลับ EN)"] = "Language: EN  (Switch TH)"
	en_to_th["Switch TH"] = "Switch EN"
	th_to_en["Switch EN"] = "Switch TH"
end
rebuildTranslationMaps()

local langBtnInstance
local function refreshAllUIText(targetLang)
	local targetMap = (targetLang == "TH") and en_to_th or th_to_en
	local core = game:GetService("CoreGui")
	local main = core:FindFirstChild("@main", true)
	if not main and LocalPlayer:FindFirstChild("PlayerGui") then
		main = LocalPlayer.PlayerGui:FindFirstChild("@main", true)
	end
	if not main then return end

	for _, desc in ipairs(main:GetDescendants()) do
		if desc:IsA("TextLabel") or desc:IsA("TextButton") then
			local current = desc.Text
			if targetMap[current] then
				desc.Text = targetMap[current]
			end
		end
	end

	if langBtnInstance then
		pcall(function()
			langBtnInstance:SetText(targetLang == "EN" and "Switch TH" or "Switch EN")
		end)
	end

	local credit = main:FindFirstChild("CreditLabel")
	if credit then
		credit.Text = T("window_collapse")
	end
end

local function showNotification(title, message)
	title, message = tostring(title or "Anime Dice"), tostring(message or "")
	task.spawn(function()
		if not pcall(StarterGui.SetCore, StarterGui, "SendNotification", {
			Title = title,
			Text = message,
			Duration = 3,
		}) then
			warn(("[%s] %s"):format(title, message))
		end
	end)
end

-- ─── Helper Modules & Remotes ────────────────────────────────
local unpackValues = unpack or table.unpack
local moduleCache = {}
local function safeRequire(moduleScript)
	if not moduleScript then return nil end
	if moduleCache[moduleScript] then
		return moduleCache[moduleScript]
	end
	local loaded, result = pcall(require, moduleScript)
	if loaded then
		moduleCache[moduleScript] = result
		return result
	end
end

local function fireRemote(remote, ...)
	if not remote then return false end
	return pcall(remote.FireServer, remote, ...)
end

local function invokeRemote(remote, ...)
	if not remote then return false end
	return pcall(remote.InvokeServer, remote, ...)
end

local sessionActive = true
local function runWorker(isActive, action)
	task.spawn(function()
		while sessionActive and isActive() and LocalPlayer.Parent ~= nil do
			local nextInterval = action()
			task.wait(tonumber(nextInterval) or 1)
		end
	end)
end

local Network = ReplicatedStorage:WaitForChild("Network")
local RollDice = Network:WaitForChild("RollService"):WaitForChild("RF"):WaitForChild("RollDice")
local SellInventory = Network:WaitForChild("SellService"):WaitForChild("RF"):WaitForChild("SellInventory")
local CollectBalance = Network:WaitForChild("PlotService"):WaitForChild("RE"):WaitForChild("CollectBalance")
local EquipBest = Network:WaitForChild("PlotService"):WaitForChild("RE"):WaitForChild("EquipBest")
local LevelUpSlot = Network:WaitForChild("PlotService"):WaitForChild("RE"):WaitForChild("LevelUpSlot")
local BuyDice = Network:WaitForChild("DiceShopService"):WaitForChild("RE"):WaitForChild("BuyDice")
local EquipDice = Network:WaitForChild("DiceShopService"):WaitForChild("RE"):WaitForChild("EquipDice")
local Rebirth = Network:WaitForChild("RebirthService"):WaitForChild("RE"):WaitForChild("Rebirth")
local BuyUpgrade = Network:WaitForChild("RE"):WaitForChild("BuyUpgrade")
local Claim = Network:WaitForChild("QuestService"):WaitForChild("RE"):WaitForChild("Claim")
local PlayTower = Network:WaitForChild("Towers"):WaitForChild("RF"):WaitForChild("PlayTower")
local CompleteTowerFloor = Network:WaitForChild("Towers"):WaitForChild("RF"):WaitForChild("CompleteTowerFloor")
local CancelTower = Network:WaitForChild("Towers"):WaitForChild("RF"):WaitForChild("CancelTower")
local EquipBestTowerTeam = Network:WaitForChild("Towers"):WaitForChild("RE"):WaitForChild("EquipBestTowerTeam")
local Roll = Network:WaitForChild("GradeService"):WaitForChild("RE"):WaitForChild("Roll")
local Roll2 = Network:WaitForChild("TraitService"):WaitForChild("RE"):WaitForChild("Roll")

-- Halloween Event Remotes
local HalloweenService = Network:WaitForChild("HalloweenService", 10)
local HW_RF = HalloweenService and HalloweenService:FindFirstChild("RF")
local HW_RE = HalloweenService and HalloweenService:FindFirstChild("RE")
local TeleportHalloweenRF = HW_RF and HW_RF:FindFirstChild("Teleport")
local BuyOfferHalloweenRE = HW_RE and HW_RE:FindFirstChild("BuyOffer")
local ClaimPathHalloweenRE = HW_RE and HW_RE:FindFirstChild("ClaimPath")
local ClaimAllPathHalloweenRE = HW_RE and HW_RE:FindFirstChild("ClaimAllPath")
local SeenIntroHalloweenRE = HW_RE and HW_RE:FindFirstChild("SeenIntro")

local HalloweenQuestService = Network:WaitForChild("HalloweenQuestService", 10)
local HW_Q_RE = HalloweenQuestService and HalloweenQuestService:FindFirstChild("RE")
local ClaimHalloweenQuestRE = HW_Q_RE and HW_Q_RE:FindFirstChild("Claim")

local PumpkinDiceService = Network:WaitForChild("PumpkinDiceService", 10)
local PD_RF = PumpkinDiceService and PumpkinDiceService:FindFirstChild("RF")
local PD_RE = PumpkinDiceService and PumpkinDiceService:FindFirstChild("RE")
local RollPumpkinDiceRF = PD_RF and PD_RF:FindFirstChild("Roll")
local SetAutoSellPumpkinDiceRE = PD_RE and PD_RE:FindFirstChild("SetAutoSell")
local UnequipUnit = Network:WaitForChild("UnitService"):WaitForChild("RF"):WaitForChild("Unequip")
local Use = Network:WaitForChild("BoostService"):WaitForChild("RE"):WaitForChild("Use")
local Features = ReplicatedStorage:WaitForChild("Framework"):WaitForChild("Features")

local rarityOptions = {
	"Common",
	"Uncommon",
	"Rare",
	"Epic",
	"Legendary",
	"Mythical",
	"Divine",
	"Exotic",
	"Celestial",
	"Exclusive",
	"Secret I",
	"Secret II",
}

local mutationOptions = {
	"Silver",
	"Gold",
	"Emerald",
	"Diamond",
	"Ruby",
	"Rainbow",
}

local upgradeOptions = {
	"Luck",
	"Fortune",
	"Roll Speed",
	"Unit Storage",
	"Money",
	"Sell",
	"Damage",
	"Health",
	"Walkspeed",
}

local allowedPotionTiers = {
	I = true,
	II = true,
	III = true,
	IV = true,
	V = true,
	VI = true,
	VII = true,
	VIII = true,
	IX = true,
	X = true,
	XI = true,
	XII = true,
	XIII = true,
	XIV = true,
}

local function selectionToSet(values)
	local selectedValues = {}
	if type(values) == "table" then
		for k, v in pairs(values) do
			if type(k) == "number" then
				selectedValues[tostring(v)] = true
			elseif v == true then
				selectedValues[tostring(k)] = true
			elseif type(v) == "string" then
				selectedValues[tostring(v)] = true
			end
		end
	elseif type(values) == "string" then
		for part in string.gmatch(values, "[^,%s]+") do
			selectedValues[part] = true
		end
	end
	return selectedValues
end

local numberSuffixes = {
	{ 1e24, "Y" },
	{ 1e21, "Z" },
	{ 1e18, "E" },
	{ 1e15, "Q" },
	{ 1e12, "T" },
	{ 1e9, "B" },
	{ 1e6, "M" },
	{ 1e3, "k" },
}

local function formatNumber(number)
	local n = tonumber(number) or 0
	for _, entry in ipairs(numberSuffixes) do
		if n >= entry[1] then
			return ("%.2f%s"):format(n / entry[1], entry[2])
		end
	end
	return tostring(math.floor(n))
end

-- ─── FORWARD DECLARATIONS FOR UNIFIED KAI TAN ENGINE ────────
local getDiceCatalog
local getDiceState
local equipBestDice
local buyAffordableDice
local getNextDiceInfo
local getNextRebirthCost
local getReserveMoney
local getInventoryUsage
local getCollectibleSlots
local collectPlotBalances
local runLevelUpPass
local getRebirthState
local tryRebirth
local buyMaxTreeUpgrades
local buySelectedUpgrades
local claimCompletedQuests
local findSellableUnitIds
local sellSelectedUnits
local useAvailablePotions
local startTowerAutomation
local simulateActivity
local startFastRoll
local refreshStatus
local refreshKaiTanHUD
local refreshShopHUD
local checkAccountMaxed
local logTelemetry = function(...) end
local updateTelemetryHUD = function(...) end
local latestTelemetryLog = "ระบบพร้อมทำงาน (System Ready)"
local getUnitQuality

local smartEquipBestUnits
local kaiTanAutoFarmEnabled = getSavedValue("AnimeDiceKaiTanMode", false) == true
local kaiTanGeneration = 0
local autoStopOnMax = getSavedValue("AnimeDiceAutoStopOnMax", false) == true
local autoMaxTreeEnabled = getSavedValue("AnimeDiceAutoMaxTree", true) == true
local treeGeneration = 0
local fastRollEnabled = getSavedValue("AnimeDiceFastRoll", false) == true
local fastRollGeneration = 0
local autoCollectEnabled = getSavedValue("AnimeDiceAutoCollect", false) == true
local collectGeneration = 0
local autoEquipEnabled = getSavedValue("AnimeDiceAutoEquipBest", false) == true
local equipGeneration = 0
local autoBuyDiceEnabled = getSavedValue("AnimeDiceAutoBuyDice", false) == true
local diceGeneration = 0
local autoUpgradeEnabled = getSavedValue("AnimeDiceAutoUpgrades", false) == true
local upgradeGeneration = 0
local autoLevelEnabled = getSavedValue("AnimeDiceAutoLevelUp", false) == true
local levelGeneration = 0
local autoRebirthEnabled = getSavedValue("AnimeDiceAutoRebirth", false) == true
local rebirthGeneration = 0
local autoTowerEnabled = getSavedValue("AnimeDiceAutoTower", false) == true
local towerGeneration = 0
local autoQuestEnabled = getSavedValue("AnimeDiceAutoClaimQuests", false) == true
local questGeneration = 0
local autoSellEnabled = getSavedValue("AnimeDiceAutoSell", false) == true
local sellGeneration = 0
local autoPotionsEnabled = getSavedValue("AnimeDiceAutoPotions", false) == true
local potionGeneration = 0
local antiAfkEnabled = getSavedValue("AnimeDiceAntiAfk", true) == true

-- ─── CORE IMPLEMENTATIONS: DICE & STATE ──────────────────────
local diceCatalogCache = nil
getDiceCatalog = function()
	if diceCatalogCache and #diceCatalogCache > 0 then
		return diceCatalogCache
	end
	local catalog = safeRequire(Features.Rolling.Dice)
	local ok, definitions = catalog and pcall(catalog.GetAll)
	if not ok or type(definitions) ~= "table" then
		return {}
	end
	local entries = {}
	for name, config in pairs(definitions) do
		entries[#entries + 1] = {
			name = name,
			price = tonumber(config.price) or 0,
			luck = tonumber(config.luck) or 1,
			rarity = config.rarity or "Common",
		}
	end
	-- Sort descending by luck (highest luck dice first)
	table.sort(entries, function(left, right)
		if left.luck ~= right.luck then
			return left.luck > right.luck
		end
		return left.price > right.price
	end)
	diceCatalogCache = entries
	return entries
end

getDiceState = function()
	local dataController = safeRequire(Features.Data.DataController)
	if not dataController then
		return {}, 0, nil
	end
	local ownedOk, owned = pcall(dataController.OwnedDice)
	local moneyOk, money = pcall(dataController.Money)
	local equippedOk, equipped = pcall(dataController.Dice)
	local ownedMap = {}
	if ownedOk and type(owned) == "table" then
		for k, v in pairs(owned) do
			if v then
				ownedMap[tostring(k)] = true
			end
		end
	end
	ownedMap["Basic"] = true -- Starter dice is always owned

	local eqDiceName = nil
	if equippedOk and equipped then
		if type(equipped) == "string" then
			eqDiceName = equipped
		elseif type(equipped) == "table" then
			if equipped.___X and type(equipped.___X.Dice) == "string" then
				eqDiceName = equipped.___X.Dice
			elseif type(equipped.name) == "string" then
				eqDiceName = equipped.name
			elseif type(equipped[1]) == "string" then
				eqDiceName = equipped[1]
			end
		end
	end
	if not eqDiceName and dataController.Dice and dataController.Dice.___X and type(dataController.Dice.___X.Dice) == "string" then
		eqDiceName = dataController.Dice.___X.Dice
	end

	return ownedMap, (moneyOk and tonumber(money) or 0), (eqDiceName or "Basic")
end

equipBestDice = function()
	local ownedDice, _, equippedDiceName = getDiceState()
	local catalog = getDiceCatalog()
	local bestDiceName = nil
	local bestLuck = -1
	for _, entry in ipairs(catalog) do
		if ownedDice[entry.name] and entry.luck > bestLuck then
			bestLuck = entry.luck
			bestDiceName = entry.name
		end
	end
	if bestDiceName and equippedDiceName ~= bestDiceName then
		fireRemote(EquipDice, bestDiceName)
		return bestDiceName
	end
	return bestDiceName or equippedDiceName
end

buyAffordableDice = function()
	local ownedDice, money = getDiceState()
	local catalog = getDiceCatalog()
	-- Always ensure best owned dice is equipped first
	equipBestDice()

	local purchasedDiceCount = 0
	-- Buy unowned dice in order of highest luck first
	for _, entry in ipairs(catalog) do
		if entry.price > 0 and not ownedDice[entry.name] and money >= entry.price then
			fireRemote(BuyDice, entry.name)
			money = money - entry.price
			ownedDice[entry.name] = true
			purchasedDiceCount = purchasedDiceCount + 1
			task.wait(0.3)
		end
	end

	if purchasedDiceCount > 0 then
		task.wait(0.5)
		equipBestDice()
		task.delay(1.2, function()
			equipBestDice()
		end)
	end
	return purchasedDiceCount
end

getNextDiceInfo = function()
	local ownedDice, money = getDiceState()
	local catalog = getDiceCatalog()
	local nextTarget = nil
	-- Search lowest price unowned dice
	for i = #catalog, 1, -1 do
		local entry = catalog[i]
		if entry.price > 0 and not ownedDice[entry.name] then
			if not nextTarget or entry.price < nextTarget.price then
				nextTarget = entry
			end
		end
	end
	return nextTarget
end

-- ─── CORE IMPLEMENTATIONS: REBIRTH & BUDGET ──────────────────
getRebirthState = function()
	local dataController = safeRequire(Features.Data.DataController)
	local rebirths = safeRequire(Features.Rebirth.Rebirths)
	if not dataController or not rebirths then
		return 0, 0, nil
	end
	local rebirthOk, rebirthValue = pcall(dataController.Rebirth)
	local moneyOk, moneyValue = pcall(dataController.Money)
	local count = rebirthOk and tonumber(rebirthValue) or 0
	local nextOk, nextRebirth = pcall(rebirths.GetNext, count)
	return count, (moneyOk and tonumber(moneyValue) or 0), (nextOk and nextRebirth or nil)
end

getNextRebirthCost = function()
	local _, _, nextRebirth = getRebirthState()
	return (nextRebirth and tonumber(nextRebirth.cost)) or math.huge
end

getReserveMoney = function(currentMoney)
	local nextRebirthCost = getNextRebirthCost()
	local nextDice = getNextDiceInfo()
	local nextDiceCost = nextDice and nextDice.price or math.huge
	local reserve = 0
	-- If wallet has >= 70% of next rebirth cost, protect it!
	if nextRebirthCost < math.huge and currentMoney >= (nextRebirthCost * 0.70) then
		reserve = math.max(reserve, nextRebirthCost)
	end
	-- If wallet has >= 70% of next dice cost, protect it!
	if nextDiceCost < math.huge and currentMoney >= (nextDiceCost * 0.70) then
		reserve = math.max(reserve, nextDiceCost)
	end
	return reserve
end

tryRebirth = function()
	local currentRebirth, money, nextRebirth = getRebirthState()
	if not nextRebirth or money < nextRebirth.cost then
		return false
	end
	fireRemote(Rebirth)
	task.wait(0.8)
	local newRebirth = getRebirthState()
	if newRebirth and newRebirth > currentRebirth then
		showNotification(T("notif_rebirth"), ("Rebirth %d · luck x%s"):format(newRebirth, tostring(nextRebirth.luckMultiplier or "?")))
		task.wait(0.4)
		equipBestDice()
		fireRemote(EquipBest)
		return true
	end
	return false
end

-- ─── CORE IMPLEMENTATIONS: INVENTORY, PLOTS & SAFE SELLING ───
getInventoryUsage = function()
	local dataController = safeRequire(Features.Data.DataController)
	local entryRegistry = safeRequire(Features.Inventory.EntryRegistry)
	local buffController = safeRequire(Features.Buffs.BuffController)
	if not dataController or not entryRegistry or not buffController then
		return 0, 100
	end

	local inventoryOk, inventory = pcall(dataController.Inventory)
	if not inventoryOk or type(inventory) ~= "table" then
		return 0, 100
	end

	local unitCount = 0
	for _, entry in pairs(inventory) do
		local config = entryRegistry.getEntryConfig(entry.name)
		if config and config.kind == "Unit" then
			unitCount += 1
		end
	end
	local _, storage = pcall(buffController.GetBuff, "Unit Storage")
	local _, extraRolls = pcall(buffController.GetBuff, "Rolls")
	return unitCount, (tonumber(storage) or 100) + (tonumber(extraRolls) or 1) - 1
end

getCollectibleSlots = function()
	local dataController = safeRequire(Features.Data.DataController)
	local plotConfig = safeRequire(Features.Plot.PlotConfig)
	if not dataController or not plotConfig then
		return {}, 0
	end

	local rebirthOk, rebirthValue = pcall(dataController.Rebirth)
	local slotsOk, slots = pcall(dataController.Slots)
	if not slotsOk or type(slots) ~= "table" then
		return {}, 0
	end

	local rebirthCount = rebirthOk and tonumber(rebirthValue) or 0
	local collectibleSlots, totalBalance = {}, 0
	for index = 1, tonumber(plotConfig.GetMaxSlots()) or 13 do
		if (tonumber(plotConfig.GetSlotRebirthRequirement(index)) or math.huge) <= rebirthCount then
			local slotData = slots[tostring(index)]
			local balance = slotData and tonumber(slotData.balance) or 0
			if balance > 0 then
				collectibleSlots[#collectibleSlots + 1] = index
				totalBalance += balance
			end
		end
	end
	return collectibleSlots, totalBalance
end

collectPlotBalances = function()
	local collectibleSlots, totalBalance = getCollectibleSlots()
	for _, entry in ipairs(collectibleSlots) do
		fireRemote(CollectBalance, entry)
		task.wait(0.04)
	end
	return #collectibleSlots, totalBalance
end

-- Auto Sell Configurations
local sellMutationOptions = {
	"No mutation",
	unpackValues(mutationOptions),
}
local sellAnyMutationRarities = selectionToSet(getSavedSelection("AnimeDiceSellRaritiesAll", { "Common", "Uncommon" }, true))
local sellSelectedMutationRarities = selectionToSet(getSavedSelection("AnimeDiceSellMutatedRarities", {}, true))
local selectedSellMutations = selectionToSet(getSavedSelection("AnimeDiceSellMutations", {}, true))
local sellDuplicateHugeEnabled = getSavedValue("AnimeDiceSellDuplicateHuge", true) == true
local sellDuplicateTitanicEnabled = getSavedValue("AnimeDiceSellDuplicateTitanic", false) == true
local autoHideTowerEnabled = getSavedValue("AnimeDiceAutoHideTower", true) == true

-- ─── SMART EQUIP & KAI TAN SAFE SELECTION ──────────────────
getUnitQuality = function(entry)
	if not entry or not entry.name then return -1 end
	local entryRegistry = safeRequire(Features.Inventory.EntryRegistry)
	local raritiesMod = safeRequire(ReplicatedStorage.Framework.Other.Rarities)
	if not entryRegistry then return -1 end
	local cfg = entryRegistry.getEntryConfig(entry.name)
	if not cfg or cfg.kind ~= "Unit" then return -1 end
	local attrs = entry.attributes or {}
	local variant = cfg.variant or attrs.variant
	local nameLower = tostring(entry.name):lower()

	local variantScore = 0
	if variant == "Titanic" or nameLower:find("titanic") then
		variantScore = 20000000
	elseif variant == "Huge" or nameLower:find("huge") then
		variantScore = 10000000
	end

	local rollChance = 0
	if cfg.chance then pcall(function() rollChance = tonumber(cfg.chance()) or 0 end) end
	if rollChance == 0 and cfg.rollChance then pcall(function() rollChance = tonumber(cfg.rollChance()) or 0 end) end

	local rarityScore = 0
	if raritiesMod and cfg.rarity then
		local rOk, rDef = pcall(raritiesMod.Get, cfg.rarity)
		if rOk and rDef and rDef.sortOrder then
			rarityScore = rDef.sortOrder * 10000
		end
	end

	local mutationBonus = 0
	local mut = attrs.mutation
	if mut == "Rainbow" then mutationBonus = 50000
	elseif mut == "Diamond" then mutationBonus = 40000
	elseif mut == "Ruby" then mutationBonus = 30000
	elseif mut == "Emerald" then mutationBonus = 20000
	elseif mut == "Gold" then mutationBonus = 10000
	elseif mut == "Silver" then mutationBonus = 5000
	end

	return variantScore + (rollChance * 2) + rarityScore + mutationBonus
end

smartEquipBestUnits = function()
	local dataController = safeRequire(Features.Data.DataController)
	local entryRegistry = safeRequire(Features.Inventory.EntryRegistry)

	if not dataController or not entryRegistry then
		pcall(function() fireRemote(EquipBest) end)
		return
	end

	local slotsOk, slots = pcall(dataController.Slots)
	local invOk, inv = pcall(dataController.Inventory)
	if not slotsOk or not invOk or type(slots) ~= "table" or type(inv) ~= "table" then
		pcall(function() fireRemote(EquipBest) end)
		return
	end

	local plottedUnitIds = {}
	local worstPlottedId = nil
	local worstPlottedScore = math.huge

	for _, slotEntry in pairs(slots) do
		if slotEntry and slotEntry.unitId then
			local uId = slotEntry.unitId
			plottedUnitIds[uId] = true
			local uData = inv[uId]
			local score = getUnitQuality(uData)
			if score < worstPlottedScore then
				worstPlottedScore = score
				worstPlottedId = uId
			end
		end
	end

	local bestBackpackId = nil
	local bestBackpackScore = -1
	local bestBackpackName = ""

	for uId, entry in pairs(inv) do
		if not plottedUnitIds[uId] and (entry.amount or 0) > 0 then
			local score = getUnitQuality(entry)
			if score > bestBackpackScore then
				bestBackpackScore = score
				bestBackpackId = uId
				bestBackpackName = tostring(entry.name)
			end
		end
	end

	-- If backpack holds a unit with significantly higher quality than the worst plotted unit,
	-- unequip the worst unit to make room, then let EquipBest seat the god unit!
	if bestBackpackId and bestBackpackScore > (worstPlottedScore + 200) then
		if worstPlottedId and UnequipUnit then
			pcall(function() invokeRemote(UnequipUnit, worstPlottedId) end)
			task.wait(0.08)
		end
		logTelemetry(("สวมใส่ยูนิตระดับเทพ %s ลงแปลง"):format(bestBackpackName))
	end

	pcall(function() fireRemote(EquipBest) end)
end

-- 1. NEVER sell if unit is placed on plot (guarded by smartEquipBestUnits)
-- 2. NEVER sell if unit is locked by player
-- 3. NEVER sell if variant is Huge or Titanic
-- 4. KAI TAN SMART HOLD: Never sell backpack units if their quality is >= worst plotted unit (hold upgrade potential)
-- 5. Mutated units: only sold if explicitly enabled in mutation dropdown
-- 6. FULL USER CONTROL: Honors user dropdown selections for all rarities (Common to Secret)
findSellableUnitIds = function()
	local dataController = safeRequire(Features.Data.DataController)
	local entryRegistry = safeRequire(Features.Inventory.EntryRegistry)
	if not dataController or not entryRegistry then
		return {}
	end
	local ok, result = pcall(dataController.Inventory)
	local slotsOk, slots = pcall(dataController.Slots)
	if not ok or type(result) ~= "table" then
		return {}
	end

	local plottedUnitIds = {}
	if slotsOk and type(slots) == "table" then
		for _, entry in pairs(slots) do
			if entry and entry.unitId then
				plottedUnitIds[entry.unitId] = true
			end
		end
	end

	local unitIdsToSell = {}

	-- Count total units for emergency capacity safeguard
	local totalBagUnits = 0
	for _, entry in pairs(result) do
		if type(entry) == "table" and entry.name then
			local cfg = entryRegistry.getEntryConfig(entry.name)
			if cfg and cfg.kind == "Unit" then
				totalBagUnits += 1
			end
		end
	end

	-- Handle duplicate Huge units (or emergency purge when bag >= 160 units)
	if sellDuplicateHugeEnabled or totalBagUnits >= 160 then
		local hugeUnitsByKind = {}
		for key, entry in pairs(result) do
			if type(entry) == "table" and entry.name and not plottedUnitIds[key] then
				local cfg = entryRegistry.getEntryConfig(entry.name)
				if cfg and cfg.kind == "Unit" then
					local attrs = entry.attributes or {}
					if not attrs.locked then
						local variant = cfg.variant or attrs.variant
						local nameLower = tostring(entry.name):lower()
						local isTitanic = variant == "Titanic" or nameLower:find("titanic")
						local isHuge = (variant == "Huge" or nameLower:find("huge")) and not isTitanic
						if isHuge then
							hugeUnitsByKind[entry.name] = hugeUnitsByKind[entry.name] or {}
							table.insert(hugeUnitsByKind[entry.name], {
								id = key,
								quality = getUnitQuality(entry)
							})
						end
					end
				end
			end
		end
		-- Keep the #1 highest quality Huge unit of each kind, sell excess duplicates
		for _, list in pairs(hugeUnitsByKind) do
			if #list > 1 then
				table.sort(list, function(a, b) return a.quality > b.quality end)
				for i = 2, #list do
					unitIdsToSell[#unitIdsToSell + 1] = list[i].id
				end
			end
		end
	end

	-- Handle duplicate Titanic units if enabled
	if sellDuplicateTitanicEnabled then
		local titanicUnitsByKind = {}
		for key, entry in pairs(result) do
			if type(entry) == "table" and entry.name and not plottedUnitIds[key] then
				local cfg = entryRegistry.getEntryConfig(entry.name)
				if cfg and cfg.kind == "Unit" then
					local attrs = entry.attributes or {}
					if not attrs.locked then
						local variant = cfg.variant or attrs.variant
						local nameLower = tostring(entry.name):lower()
						local isTitanic = variant == "Titanic" or nameLower:find("titanic")
						if isTitanic then
							titanicUnitsByKind[entry.name] = titanicUnitsByKind[entry.name] or {}
							table.insert(titanicUnitsByKind[entry.name], {
								id = key,
								quality = getUnitQuality(entry)
							})
						end
					end
				end
			end
		end
		-- Keep the #1 highest quality Titanic unit of each kind, sell excess duplicates
		for _, list in pairs(titanicUnitsByKind) do
			if #list > 1 then
				table.sort(list, function(a, b) return a.quality > b.quality end)
				for i = 2, #list do
					unitIdsToSell[#unitIdsToSell + 1] = list[i].id
				end
			end
		end
	end

	-- Process standard units based on user authority
	for key, entry in pairs(result) do
		local unitId = key
		local attributes = entry.attributes or {}
		local entryConfig = entryRegistry.getEntryConfig(entry.name)
		if not entryConfig or entryConfig.kind ~= "Unit" or (entry.amount or 0) <= 0 then
			continue
		end

		-- RULE 1: Never sell plotted units
		if plottedUnitIds[unitId] then
			continue
		end

		-- RULE 2: Never sell locked units
		if attributes.locked then
			continue
		end

		-- RULE 3: NEVER SELL TITANIC (ANY VARIANT) AND PROTECT BASE HUGE
		local variant = entryConfig.variant or attributes.variant
		local nameLower = tostring(entry.name):lower()
		local isTitanic = variant == "Titanic" or nameLower:find("titanic")
		local isHuge = variant == "Huge" or nameLower:find("huge")

		-- Titanic is ALWAYS protected 100%
		if isTitanic then
			continue
		end

		-- Huge units are handled above via duplicate manager, skip from standard pass
		if isHuge then
			continue
		end

		local mutationName = attributes.mutation and tostring(attributes.mutation) or "No mutation"
		local rarityOk, detectedRarity = pcall(function()
			return entryConfig and entryConfig.getRarity(attributes)
		end)
		local rarity = (rarityOk and detectedRarity) or (entryConfig and entryConfig.rarity)
		local rarityName = tostring(rarity)

		-- RULE 4: USER SELECTION CRITERIA
		-- 1) Any unit whose rarity is in sellAnyMutationRarities is sold (mutated or unmutated)
		-- 2) Any unit whose rarity is in sellSelectedMutationRarities is sold if its mutation is in selectedSellMutations
		local shouldSell = false
		if sellAnyMutationRarities[rarityName] then
			shouldSell = true
		elseif sellSelectedMutationRarities[rarityName] and selectedSellMutations[mutationName] then
			shouldSell = true
		end

		if shouldSell then
			unitIdsToSell[#unitIdsToSell + 1] = unitId
		end
	end
	return unitIdsToSell
end

sellSelectedUnits = function()
	-- ALWAYS promote highest quality backpack units to plot first!
	smartEquipBestUnits()
	task.wait(0.08)
	local unitIds = findSellableUnitIds()
	if #unitIds == 0 then
		return 0, 0
	end
	local ok, result, soldUnitCount = false, 0, 0
	pcall(function()
		local netPkg = safeRequire(ReplicatedStorage.Packages.Network)
		if netPkg and netPkg.ClientComm then
			local comm = netPkg.ClientComm.new(ReplicatedStorage.Network, false, "SellService")
			local fn = comm:GetFunction("SellInventory")
			local _, cash = fn(unitIds)
			if cash then
				ok = true
				result = tonumber(cash) or 0
				soldUnitCount = #unitIds
			end
		end
	end)
	if not ok then
		ok, result, soldUnitCount = invokeRemote(SellInventory, unitIds)
	end
	if ok then
		local soldCash = tonumber(result) or 0
		local count = tonumber(soldUnitCount) or #unitIds
		if count > 0 then
			logTelemetry(("ขายยูนิตขยะ %d ตัว (+$%s)"):format(count, formatNumber(soldCash)))
		end
		return soldCash, count
	end
	return 0, 0
end

-- ─── CORE IMPLEMENTATIONS: LEVEL UP & SKILL TREE MAXER ───────
local targetLevel = math.max(math.floor(tonumber(getSavedValue("AnimeDiceLevelUpTarget", 10)) or 10), 1)
local minimumRarity = tostring(getSavedSelection("AnimeDiceLevelUpRarity", "Common", false))

local function getLevelModules()
	return safeRequire(Features.Data.DataController),
		safeRequire(Features.Inventory.EntryRegistry),
		safeRequire(ReplicatedStorage.Framework.Other.Rarities),
		safeRequire(Features.Inventory.Kinds.Unit.UnitUtil)
end

runLevelUpPass = function(generationToken)
	smartEquipBestUnits()
	task.wait(0.05)
	local dataController, entryRegistry, rarityModule, unitUtil = getLevelModules()
	if not dataController or not entryRegistry or not rarityModule or not unitUtil then
		return 0
	end

	local slotsOk, slots = pcall(dataController.Slots)
	local inventoryOk, inventory = pcall(dataController.Inventory)
	if not slotsOk or not inventoryOk or type(slots) ~= "table" or type(inventory) ~= "table" then
		return 0
	end

	local minimumRarityOk, minimumRarityResult = pcall(function()
		return rarityModule.Get(minimumRarity).sortOrder
	end)
	local minimumRarityOrder = minimumRarityOk and minimumRarityResult or 0
	local levelsPurchased = 0

	local moneyOk, rawMoney = pcall(dataController.Money)
	local currentMoney = moneyOk and tonumber(rawMoney) or 0
	local reserveMoney = getReserveMoney(currentMoney)
	local spendableMoney = math.max(0, currentMoney - reserveMoney)
	local budgetForPass = spendableMoney * 0.50
	local spentThisPass = 0

	for key, entry in pairs(slots) do
		if not sessionActive or (generationToken and not autoLevelEnabled and not kaiTanAutoFarmEnabled) then
			break
		end
		local slotIndex = tonumber(key)
		if not (slotIndex and entry.unitId) then
			continue
		end

		local unitData = inventory[entry.unitId]
		local unitConfig = unitData and entryRegistry.getEntryConfig(unitData.name)
		if not unitConfig or unitConfig.kind ~= "Unit" then
			continue
		end

		local rarityOk, unitRarityOrder = pcall(function()
			return rarityModule.Get(unitConfig.getRarity(unitData.attributes or {})).sortOrder
		end)
		if not rarityOk or unitRarityOrder < minimumRarityOrder then
			continue
		end

		while sessionActive and (not generationToken or (autoLevelEnabled and generationToken == levelGeneration) or kaiTanAutoFarmEnabled) do
			if spentThisPass >= budgetForPass then
				break
			end
			local curInvOk, currentInventory = pcall(dataController.Inventory)
			local currentUnit = curInvOk and currentInventory[entry.unitId]
			if not currentUnit then
				break
			end
			if (tonumber(currentUnit.attributes.level) or 1) >= targetLevel then
				break
			end
			local curMoneyOk, curMoney = pcall(dataController.Money)
			local liveMoney = curMoneyOk and tonumber(curMoney) or 0
			local levelPrice = unitUtil.GetLevelPrice(currentUnit.name, currentUnit.attributes)
			if not curMoneyOk or levelPrice > (liveMoney - reserveMoney) or (spentThisPass + levelPrice) > budgetForPass then
				break
			end

			fireRemote(LevelUpSlot, slotIndex)
			levelsPurchased += 1
			spentThisPass += levelPrice
			task.wait(0.12)
		end
	end
	return levelsPurchased
end

-- ─── AUTO MAX TREE IMPLEMENTATION (86/86 NODES) ──────────────
local selectedUpgrades = selectionToSet(getSavedSelection("AnimeDiceUpgradeBranches", upgradeOptions, true))

buyMaxTreeUpgrades = function()
	local dataController = safeRequire(Features.Data.DataController)
	local upgrades = safeRequire(Features.Upgrades.Upgrades)
	local upgradeTree = safeRequire(Features.Upgrades.TreeStructure)
	if not dataController or not upgrades or not upgradeTree then
		return 0, 0, 86
	end
	local ok, userUpgrades = pcall(dataController.Upgrades)
	local moneyOk, rawMoney = pcall(dataController.Money)
	if not ok or type(userUpgrades) ~= "table" then
		return 0, 0, 86
	end
	local currentMoney = moneyOk and tonumber(rawMoney) or 0
	local reserveMoney = getReserveMoney(currentMoney)
	local availableMoney = math.max(0, currentMoney - reserveMoney)

	local purchasedCount = 0
	local totalNodes = 0
	local purchasedNodes = {}
	for name, _ in pairs(upgrades) do
		totalNodes += 1
		if userUpgrades[name] then
			purchasedCount += 1
			purchasedNodes[name] = true
		end
	end

	-- Find all reachable unpurchased nodes
	local candidates = {}
	for name, config in pairs(upgrades) do
		if not purchasedNodes[name] and config.price ~= nil then
			local baseName = string.match(name, "^(.*)%s+(%S+)$") or name
			local isBranchSelected = autoMaxTreeEnabled or kaiTanAutoFarmEnabled or selectedUpgrades[baseName]

			if isBranchSelected then
				local parentOk, parentName = pcall(upgradeTree.GetParent, name)
				local parentUnlocked = not parentOk
					or not parentName
					or parentName == "Start"
					or purchasedNodes[parentName] == true

				if parentUnlocked then
					candidates[#candidates + 1] = {
						name = name,
						price = tonumber(config.price) or 0
					}
				end
			end
		end
	end
	table.sort(candidates, function(a, b) return a.price < b.price end)

	local boughtThisPass = 0
	for _, node in ipairs(candidates) do
		if availableMoney >= node.price then
			fireRemote(BuyUpgrade, node.name)
			purchasedNodes[node.name] = true
			availableMoney -= node.price
			boughtThisPass += 1
			purchasedCount += 1
			task.wait(0.08)
		end
	end
	return boughtThisPass, purchasedCount, totalNodes
end

buySelectedUpgrades = function()
	return buyMaxTreeUpgrades()
end

claimCompletedQuests = function()
	local dataController = safeRequire(Features.Data.DataController)
	local questConfig = safeRequire(Features.Quests.QuestConfig)
	if not dataController or not questConfig then
		return 0
	end
	local claimed = 0
	for _, periodName in ipairs({ "Daily", "Weekly" }) do
		local loaded, questData = pcall(dataController.Quests[periodName])
		local period = questConfig.Periods[periodName]
		if loaded and type(questData) == "table" and period then
			for _, quest in ipairs(period.quests or {}) do
				if (questData.progress[quest.id] or 0) >= quest.target and not questData.claimed[quest.id] then
					fireRemote(Claim, periodName, quest.id, questData.expiresAt)
					claimed += 1
					task.wait(0.2)
				end
			end
		end
	end
	return claimed
end

-- ─── CORE IMPLEMENTATIONS: BOOST POTIONS ─────────────────────
local potionCategoryNames = {
	Luck = "Luck",
	Money = "Income",
	Damage = "Damage",
}
local selectedPotionTiers = {
	Luck = selectionToSet(getSavedSelection("AnimeDicePotionLuck", { "Normal", "Dragon" }, true)),
	Money = selectionToSet(getSavedSelection("AnimeDicePotionMoney", { "Normal", "Dragon" }, true)),
	Damage = selectionToSet(getSavedSelection("AnimeDicePotionDamage", {}, true)),
}
local enabledPotionCategories = {}
local function refreshPotionSelection()
	local selectedCategories = {}
	for key, entry in pairs(selectedPotionTiers) do
		local mappedCategory = potionCategoryNames[key]
		for k2 in pairs(entry) do
			local tierName = k2
			selectedCategories[tierName == "Normal" and mappedCategory or tierName .. " " .. mappedCategory] = true
		end
	end
	enabledPotionCategories = selectedCategories
end
refreshPotionSelection()

useAvailablePotions = function()
	local dataController = safeRequire(Features.Data.DataController)
	local entryRegistry = safeRequire(Features.Inventory.EntryRegistry)
	if not dataController or not entryRegistry then
		return 0
	end

	local inventoryOk, inventory = pcall(dataController.Inventory)
	local activeOk, activeEntries = pcall(dataController.ActiveEntries)
	if not inventoryOk or type(inventory) ~= "table" then
		return 0
	end
	if not activeOk or type(activeEntries) ~= "table" then
		activeEntries = {}
	end

	local now = workspace:GetServerTimeNow()
	local activeCategories = {}
	for _, activePotion in pairs(activeEntries) do
		local config = entryRegistry.getEntryConfig(activePotion.name)
		local remaining = tonumber(activePotion.remaining) or 0
		if type(activePotion.startedAt) == "number" then
			remaining -= now - activePotion.startedAt
		end
		if config and config.kind == "Boost" and remaining > 0 then
			activeCategories[config.category] = true
		end
	end

	local bestByCategory = {}
	for inventoryKey, inventoryEntry in pairs(inventory) do
		local config = entryRegistry.getEntryConfig(inventoryEntry.name)
		local category = config and config.category
		if config and config.kind == "Boost" and (inventoryEntry.amount or 0) > 0
			and enabledPotionCategories[category] and not activeCategories[category]
		then
			local tier = config.tier or 0
			if not bestByCategory[category] or tier > bestByCategory[category].tier then
				bestByCategory[category] = { key = inventoryKey, tier = tier }
			end
		end
	end

	local used = 0
	for _, potion in pairs(bestByCategory) do
		fireRemote(Use, potion.key)
		used += 1
		task.wait(0.2)
	end
	return used
end

-- ─── CORE IMPLEMENTATIONS: ANTI-AFK ──────────────────────────
simulateActivity = function()
	local camera = workspace.CurrentCamera
	if not camera then return end
	local position = camera.ViewportSize / 2
	pcall(function()
		VirtualInputManager:SendMouseMoveEvent(position.X + 2, position.Y, game)
		task.wait(0.04)
		VirtualInputManager:SendMouseMoveEvent(position.X, position.Y, game)
	end)
end

LocalPlayer.Idled:Connect(function()
	if antiAfkEnabled or kaiTanAutoFarmEnabled then
		simulateActivity()
	end
end)

-- ─── CHECK ACCOUNT MAXED ─────────────────────────────────────
checkAccountMaxed = function()
	local curRebirth = getRebirthState() or 0
	local ownedDice = getDiceState()
	local dataController = safeRequire(Features.Data.DataController)
	local userUpgrades = (dataController and pcall(dataController.Upgrades) and dataController.Upgrades()) or {}
	local upgCount = 0
	for _ in pairs(userUpgrades) do upgCount += 1 end

	local isMaxRebirth = curRebirth >= 13
	local isMaxDice = ownedDice["Frostfire"] == true
	local isMaxTree = upgCount >= 86

	return (isMaxRebirth and isMaxDice and isMaxTree), isMaxRebirth, isMaxDice, upgCount
end

-- ─── UI LIBRARY INITIALIZATION & 8 TABS SETUP ────────────────
local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/SixZensED/Script/refs/heads/main/l4.lua"))()
local NewWindow = library.create()

-- ─── PAYOMBØYZ CUSTOM BACKGROUND ARTWORK (Image Sep 28.png) ────
local function mountPayomboyZBackground()
	local function findMainWindow()
		local roots = { game:GetService("CoreGui") }
		if type(gethui) == "function" then pcall(function() table.insert(roots, gethui()) end) end
		for _, root in ipairs(roots) do
			for _, gui in ipairs(root:GetChildren()) do
				if gui:IsA("ScreenGui") then
					local m = gui:FindFirstChild("@main")
					if m then return m end
				end
			end
		end
		return nil
	end

	local main = findMainWindow()
	if not main or main:FindFirstChild("MangaArtBackground") then return end

	main.BackgroundTransparency = 0.18
	main.BackgroundColor3 = Color3.fromRGB(18, 19, 24)

	local bg = Instance.new("ImageLabel")
	bg.Name = "MangaArtBackground"
	bg.Size = UDim2.fromScale(1, 1)
	bg.Position = UDim2.fromScale(0, 0)
	bg.BackgroundTransparency = 1
	bg.ScaleType = Enum.ScaleType.Crop
	bg.ImageTransparency = 0.08
	bg.ZIndex = 0
	bg.Parent = main

	local bgCorner = Instance.new("UICorner")
	bgCorner.CornerRadius = UDim.new(0, 10)
	bgCorner.Parent = bg

	local tint = Instance.new("Frame")
	tint.Name = "GlassTintOverlay"
	tint.Size = UDim2.fromScale(1, 1)
	tint.Position = UDim2.fromScale(0, 0)
	tint.BackgroundColor3 = Color3.fromRGB(12, 13, 18)
	tint.BackgroundTransparency = 0.42
	tint.BorderSizePixel = 0
	tint.ZIndex = 0
	tint.Parent = main

	local tintCorner = Instance.new("UICorner")
	tintCorner.CornerRadius = UDim.new(0, 10)
	tintCorner.Parent = tint

	local grad = Instance.new("UIGradient")
	grad.Rotation = 45
	grad.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(18, 19, 24)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(10, 11, 14)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(22, 24, 30))
	})
	grad.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.20),
		NumberSequenceKeypoint.new(0.5, 0.35),
		NumberSequenceKeypoint.new(1, 0.48)
	})
	grad.Parent = tint

	for _, ch in ipairs(main:GetChildren()) do
		if ch ~= bg and ch ~= tint and ch:IsA("GuiObject") and ch.ZIndex < 2 then
			ch.ZIndex = 2
		end
	end

	local fileName = "Image Sep 28.png"
	local rawUrl = "https://raw.githubusercontent.com/payomboyz333/Library/main/Image%20Sep%2028.png"
	task.spawn(function()
		local getAsset = getsynasset or getcustomasset
		if typeof(isfile) == "function" and isfile(fileName) and typeof(getAsset) == "function" then
			pcall(function() bg.Image = getAsset(fileName) end)
			return
		end
		pcall(function()
			local req = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
			local body = nil
			if type(req) == "function" then
				local res = req({ Url = rawUrl, Method = "GET" })
				if res and (res.StatusCode == 200 or res.Status == 200) and res.Body then body = res.Body end
			end
			if not body and game.HttpGet then body = game:HttpGet(rawUrl) end
			if body and #body > 0 and typeof(writefile) == "function" then
				writefile(fileName, body)
				if typeof(getAsset) == "function" then bg.Image = getAsset(fileName) end
			end
		end)
	end)
end

task.defer(function()
	task.wait(0.15)
	pcall(mountPayomboyZBackground)
end)

-- 8 Organized Tabs (Zero bottom overflow)
local tab_roll      = NewWindow.create() -- Tab 1 (1/9): Roll & Kai Tan
local tab_plot      = NewWindow.create() -- Tab 2 (2/9): Plot Income & Teams
local tab_shop      = NewWindow.create() -- Tab 3 (3/9): Dice Shop & Upgrades
local tab_units     = NewWindow.create() -- Tab 4 (4/9): Unit Leveling, Grades & Rebirth
local tab_towers    = NewWindow.create() -- Tab 5 (5/9): Dragon Tower & Quests
local tab_sell      = NewWindow.create() -- Tab 6 (6/9): Smart Auto Sell
local tab_potions   = NewWindow.create() -- Tab 7 (7/9): Boost Potions
local tab_halloween = NewWindow.create() -- Tab 8 (8/9): Halloween Event
local tab_settings  = NewWindow.create() -- Tab 9 (9/9): Settings, Particles & Anti-AFK

-- ─── TAB 1: Master Kai Tan & Roll (1/9) ──────────────────────
tab_roll.Header({ Title = T("tab_roll") .. " (1/9)" })
tab_roll.Header({ Title = T("header_kaitan") })

local kaiTanStatusLabel
local rollStatusLabel
local diceTargetStatusLabel
local treeProgressStatusLabel
local totalRolls = 0
local rollStartedAt
local lastRoll = "—"
local accountMaxedAnnounced = false

local function getRollCooldown()
	local buffController = safeRequire(Features.Buffs.BuffController)
	if not buffController then return 2.5 end
	local ok, cooldown = pcall(buffController.GetBuff, "Roll Duration")
	return ok and type(cooldown) == "number" and math.max(cooldown, 0) or 2.5
end

refreshStatus = function(state)
	if not rollStatusLabel then return end
	local elapsed = rollStartedAt and os.clock() - rollStartedAt or 0
	local rate = elapsed > 1 and totalRolls / elapsed * 60 or 0
	local used, capacity = getInventoryUsage()
	local inventoryText = used and ("Inventory: %d/%d units"):format(used, capacity) or "Inventory: unavailable"
	if used and capacity and used >= capacity then
		inventoryText ..= " (FULL)"
	end
	rollStatusLabel.Text = table.concat({
		("Cooldown: %.2fs · Rolls: %d (%.1f/min)"):format(getRollCooldown(), totalRolls, rate),
		"Last: " .. lastRoll,
		inventoryText,
		state or (fastRollEnabled and "Running" or "Stopped"),
	}, "\n")
end

refreshShopHUD = function()
	local _, money, eqDice = getDiceState()
	local nextDice = getNextDiceInfo()
	if diceTargetStatusLabel then
		if nextDice then
			local missing = math.max(0, nextDice.price - money)
			local statusStr = missing == 0 and "READY TO BUY!" or ("Need: $%s"):format(formatNumber(missing))
			diceTargetStatusLabel.Text = ("Equipped: %s | Target: %s ($%s, Luck: x%s)\nStatus: %s"):format(
				eqDice or "Basic",
				nextDice.name,
				formatNumber(nextDice.price),
				tostring(nextDice.luck),
				statusStr
			)
		else
			diceTargetStatusLabel.Text = ("Equipped: %s | Target: MAXED (Frostfire Owned!)\nStatus: All Dice Completed"):format(eqDice or "Frostfire")
		end
	end

	if treeProgressStatusLabel then
		local dataController = safeRequire(Features.Data.DataController)
		local userUpgrades = (dataController and pcall(dataController.Upgrades) and dataController.Upgrades()) or {}
		local upgCount = 0
		for _ in pairs(userUpgrades) do upgCount += 1 end
		local pct = math.floor(upgCount / 86 * 100)
		treeProgressStatusLabel.Text = ("Tree Progress: %d/86 Upgrades (%d%%)\nStatus: %s"):format(
			upgCount,
			pct,
			upgCount >= 86 and "MAXED (ต้นไม้ตันแล้ว 100%)" or (autoMaxTreeEnabled and "Auto Maxing Active..." or "Manual Selection")
		)
	end
end

refreshKaiTanHUD = function()
	refreshShopHUD()
	if not kaiTanStatusLabel then return end
	local _, money, eqDice = getDiceState()
	local curRebirth = getRebirthState() or 0
	local used, cap = getInventoryUsage()
	local invStr = ("%d/%d"):format(used or 0, cap or 100)
	local isMaxed, isMaxRb, isMaxD, upgCount = checkAccountMaxed()

	if isMaxed then
		kaiTanStatusLabel.Text = table.concat({
			"🎉 [KAI TAN 100% COMPLETED] ไอดีตันสมบูรณ์แล้ว!",
			("Rebirth: 13/13 (MAX)  |  Dice: %s (MAX)"):format(eqDice or "Frostfire"),
			("Tree: 86/86 (MAX)  |  Cash: $%s"):format(formatNumber(money)),
		}, "\n")
	else
		kaiTanStatusLabel.Text = table.concat({
			("⭐ [KAI TAN] Status: %s"):format(kaiTanAutoFarmEnabled and "RUNNING (ACTIVE)" or "OFF"),
			("Rebirth: %d/13  |  Equipped Dice: %s  |  Tree: %d/86"):format(curRebirth, eqDice or "Basic", upgCount),
			("Cash: $%s  |  Inventory: %s"):format(formatNumber(money), invStr),
		}, "\n")
	end
end

startFastRoll = function(generation)
	fastRollGeneration += 1
	local currentGen = generation or fastRollGeneration
	if not fastRollEnabled and not kaiTanAutoFarmEnabled then
		return
	end
	rollStartedAt = rollStartedAt or os.clock()

	task.spawn(function()
		while sessionActive and (fastRollEnabled or kaiTanAutoFarmEnabled) and (currentGen == fastRollGeneration or currentGen == kaiTanGeneration) and LocalPlayer.Parent ~= nil do
			-- Check account maxed condition if auto-stop is enabled
			if kaiTanAutoFarmEnabled and autoStopOnMax then
				local isMaxed = checkAccountMaxed()
				if isMaxed then
					refreshStatus("Paused (Account 100% Maxed)")
					break
				end
			end

			-- 1. ROLL DICE
			local succeeded, rolls = invokeRemote(RollDice)
			if succeeded and type(rolls) == "table" and #rolls > 0 then
				totalRolls += #rolls
				local names = {}
				for _, roll in ipairs(rolls) do
					names[#names + 1] = roll.mutation and roll.mutation .. " " .. tostring(roll.result)
						or tostring(roll.result)
				end
				lastRoll = table.concat(names, ", ")
				refreshStatus()
				task.wait(math.max(getRollCooldown() - 0.25, 0.1))
			else
				task.wait(0.25)
			end

			-- 2. Emergency inventory capacity guard (clears junk if bag reaches >= capacity - 2)
			local used, capacity = getInventoryUsage()
			if used and capacity and used >= (capacity - 2) then
				smartEquipBestUnits()
				task.wait(0.06)
				sellSelectedUnits()
			end
		end
	end)
end

-- ─── MASTER KAI TAN DETERMINISTIC ROUND-ROBIN COORDINATOR ─────
-- Zero-clashing architecture: exactly one subsystem runs per timeslice.
-- 100% stable for 20+ multi-boxed accounts running 24/7 without remote spam/deadlocks.
local function runKaiTanCoordinator()
	kaiTanGeneration += 1
	local currentGen = kaiTanGeneration
	if not kaiTanAutoFarmEnabled then return end

	-- Ensure Anti-AFK & initial equip
	simulateActivity()
	logTelemetry("เริ่มต้นระบบฟาร์มไก่ตัน Kai Tan (Lv.1 - Max)")
	task.spawn(function()
		equipBestDice()
		smartEquipBestUnits()
	end)

	-- Start Fast Roll
	startFastRoll(currentGen)

	-- Central Coordinator Worker (Deterministic Round-Robin Timeslices)
	task.spawn(function()
		local step = 0
		while sessionActive and kaiTanAutoFarmEnabled and currentGen == kaiTanGeneration and LocalPlayer.Parent ~= nil do
			step = (step % 9) + 1

			-- Check if account reached 100% maxed
			local isMaxed = checkAccountMaxed()
			if isMaxed then
				if not accountMaxedAnnounced then
					accountMaxedAnnounced = true
					showNotification("KAI TAN COMPLETED!", "🎉 ไอดีนี้ตันสมบูรณ์แล้ว 100%! (Rebirth 13/13 | เต๋า Frostfire | ต้นไม้ 86/86)")
					logTelemetry("🎉 ไอดีไก่ตันสมบูรณ์ 100% แล้ว!")
				end
				if autoStopOnMax then
					fastRollGeneration += 1
					refreshStatus("Paused (Account 100% Maxed)")
					refreshKaiTanHUD()
					break
				end
			end

			-- TIMESLICE 1: Collect Plot Balances
			if step == 1 then
				pcall(collectPlotBalances)

			-- TIMESLICE 2: Smart Quality Equip Best Units
			elseif step == 2 then
				pcall(smartEquipBestUnits)

			-- TIMESLICE 3: Safe Auto Sell (sells inferior duplicates that match user dropdown)
			elseif step == 3 then
				pcall(sellSelectedUnits)

			-- TIMESLICE 4: Auto Buy & Equip Best Dice
			elseif step == 4 then
				pcall(function()
					local bought = buyAffordableDice()
					local equipped = equipBestDice()
					if bought and bought > 0 and equipped then
						logTelemetry("ซื้อและสวมใส่เต๋า " .. tostring(equipped) .. " สำเร็จ")
					end
				end)

			-- TIMESLICE 5: Auto Max Skill Tree Upgrades
			elseif step == 5 then
				pcall(function()
					local boughtCount = buyMaxTreeUpgrades()
					if boughtCount and boughtCount > 0 then
						local _, _, _, upgCount = checkAccountMaxed()
						logTelemetry("อัปเกรดต้นไม้ (" .. tostring(upgCount) .. "/86)")
					end
				end)

			-- TIMESLICE 6: Auto Rebirth Check
			elseif step == 6 then
				pcall(function()
					local rebirthed = tryRebirth()
					if rebirthed then
						local curRebirth = getRebirthState()
						logTelemetry("Rebirth สำเร็จ! ขึ้นสู่เทียร์ " .. tostring(curRebirth))
					end
				end)

			-- TIMESLICE 7: Auto Level Plotted Units
			elseif step == 7 then
				pcall(runLevelUpPass)

			-- TIMESLICE 8: Auto Claim Quests & Boost Potions
			elseif step == 8 then
				pcall(claimCompletedQuests)
				task.wait(0.06)
				pcall(useAvailablePotions)

			-- TIMESLICE 9: Refresh HUD Telemetry
			elseif step == 9 then
				refreshKaiTanHUD()
			end

			task.wait(1.1)
		end
	end)
end

local kaiTanToggleControl = tab_roll.Toggle({
	Title = T("kaitan_tog"),
	Info = T("kaitan_inf"),
	Default = kaiTanAutoFarmEnabled,
	Callback = function(enabled)
		saveSetting("AnimeDiceKaiTanMode", enabled)
		kaiTanAutoFarmEnabled = enabled
		kaiTanGeneration += 1
		if enabled then
			runKaiTanCoordinator()
		else
			fastRollGeneration += 1
			refreshStatus("Stopped")
			refreshKaiTanHUD()
		end
	end,
})

kaiTanStatusLabel = kaiTanToggleControl:Label({ Text = "Loading Kai Tan Status...", Size = 10 })

kaiTanToggleControl:Toggle({
	Title = T("auto_stop_tog"),
	Info = T("auto_stop_inf"),
	Default = autoStopOnMax,
	Callback = function(enabled)
		saveSetting("AnimeDiceAutoStopOnMax", enabled)
		autoStopOnMax = enabled
	end,
})

kaiTanToggleControl:Button({
	Title = T("kaitan_btn"),
	Text = T("run_btn"),
	Callback = function()
		task.spawn(function()
			equipBestDice()
			smartEquipBestUnits()
			collectPlotBalances()
			buyAffordableDice()
			tryRebirth()
			buyMaxTreeUpgrades()
			runLevelUpPass()
			sellSelectedUnits()
			claimCompletedQuests()
			refreshKaiTanHUD()
			showNotification("Kai Tan Pass", "Full account pass completed!")
		end)
	end,
})

tab_roll.Header({ Title = T("header_roll") })

local fastRollControl = tab_roll.Toggle({
	Title = T("fast_roll_tog"),
	Info = T("fast_roll_inf"),
	Default = fastRollEnabled,
	Callback = function(enabled)
		saveSetting("AnimeDiceFastRoll", enabled)
		fastRollEnabled = enabled
		fastRollGeneration += 1
		local currentGen = fastRollGeneration
		if enabled then
			startFastRoll(currentGen)
		else
			refreshStatus("Stopped")
		end
	end,
})
rollStatusLabel = fastRollControl:Label({ Text = "Loading roll status...", Size = 10 })
fastRollControl:Button({
	Title = T("reset_counter"),
	Text = T("reset_btn"),
	Callback = function()
		totalRolls = 0
		rollStartedAt = (fastRollEnabled or kaiTanAutoFarmEnabled) and os.clock() or nil
		lastRoll = "—"
		refreshStatus()
	end,
})

refreshStatus()
refreshKaiTanHUD()
if kaiTanAutoFarmEnabled then
	runKaiTanCoordinator()
elseif fastRollEnabled then
	startFastRoll()
end

-- ─── TAB 2: Plot & Farm (2/9) ────────────────────────────────
tab_plot.Header({ Title = T("tab_plot") .. " (2/9)" })
tab_plot.Header({ Title = T("header_plot") })

do
	local collectInterval = math.max(tonumber(getSavedValue("AnimeDiceCollectInterval", 15)) or 15, 1)
	local equipInterval = math.max(tonumber(getSavedValue("AnimeDiceEquipInterval", 10)) or 10, 2)

	local collectControls = tab_plot.Toggle({
		Title = T("auto_collect"),
		Info = T("auto_coll_inf"),
		Default = autoCollectEnabled,
		Callback = function(enabled)
			saveSetting("AnimeDiceAutoCollect", enabled)
			autoCollectEnabled = enabled
			collectGeneration += 1
			local activeCollectGeneration = collectGeneration
			if enabled then
				runWorker(function()
					return autoCollectEnabled and activeCollectGeneration == collectGeneration and sessionActive
				end, function()
					collectPlotBalances()
					return collectInterval
				end)
			end
		end,
	})
	collectControls:Slider({
		Title = T("collect_sec"),
		Min = 1,
		Max = 60,
		Round = 1,
		Default = collectInterval,
		Suffix = "s",
		Callback = function(interval)
			saveSetting("AnimeDiceCollectInterval", interval)
			collectInterval = math.max(tonumber(interval) or 15, 1)
		end,
	})
	local equipControls = tab_plot.Toggle({
		Title = T("auto_equip"),
		Info = T("auto_equip_inf"),
		Default = autoEquipEnabled,
		Callback = function(enabled)
			saveSetting("AnimeDiceAutoEquipBest", enabled)
			autoEquipEnabled = enabled
			equipGeneration += 1
			local activeEquipGeneration = equipGeneration
			if enabled then
				runWorker(function()
					return autoEquipEnabled and activeEquipGeneration == equipGeneration and sessionActive
				end, function()
					smartEquipBestUnits()
					return equipInterval
				end)
			end
		end,
	})
	equipControls:Slider({
		Title = T("equip_sec"),
		Min = 2,
		Max = 120,
		Round = 1,
		Default = equipInterval,
		Suffix = "s",
		Callback = function(interval)
			saveSetting("AnimeDiceEquipInterval", interval)
			equipInterval = math.max(tonumber(interval) or 10, 2)
		end,
	})
	collectControls:Button({
		Title = T("collect_now"),
		Text = T("collect_btn"),
		Callback = function()
			task.spawn(function()
				local collectedSlotCount, collectedBalance = collectPlotBalances()
				local notificationText = collectedSlotCount > 0
						and ("%d slots  ·  +$%s"):format(collectedSlotCount, formatNumber(collectedBalance))
					or T("notif_nothing")
				showNotification(T("notif_collect"), notificationText)
			end)
		end,
	})
end

-- ─── TAB 3: Shop & Upgrades (3/9) ────────────────────────────
tab_shop.Header({ Title = T("tab_shop") .. " (3/9)" })
tab_shop.Header({ Title = T("header_shop") })

do
	local diceControls = tab_shop.Toggle({
		Title = T("buy_dice_tog"),
		Info = T("buy_dice_inf"),
		Default = autoBuyDiceEnabled,
		Callback = function(enabled)
			saveSetting("AnimeDiceAutoBuyDice", enabled)
			autoBuyDiceEnabled = enabled
			diceGeneration += 1
			local activeDiceGeneration = diceGeneration
			if enabled then
				runWorker(function()
					return autoBuyDiceEnabled and activeDiceGeneration == diceGeneration and sessionActive
				end, function()
					buyAffordableDice()
					equipBestDice()
					refreshShopHUD()
					return 3
				end)
			end
		end,
	})
	diceTargetStatusLabel = diceControls:Label({ Text = "Calculating Dice Target...", Size = 10 })
	diceControls:Button({
		Title = T("equip_dice_btn"),
		Text = T("equip_btn"),
		Callback = function()
			task.spawn(function()
				local equippedDice = equipBestDice()
				local notificationText = equippedDice and "Equipped: " .. equippedDice or T("notif_dice_best")
				refreshShopHUD()
				showNotification(T("notif_dice"), notificationText)
			end)
		end,
	})
end

tab_shop.Header({ Title = T("header_upgrade") })

do
	local treeControls = tab_shop.Toggle({
		Title = T("auto_tree_tog"),
		Info = T("auto_tree_inf"),
		Default = autoMaxTreeEnabled,
		Callback = function(enabled)
			saveSetting("AnimeDiceAutoMaxTree", enabled)
			autoMaxTreeEnabled = enabled
			treeGeneration += 1
			local activeTreeGen = treeGeneration
			if enabled then
				runWorker(function()
					return autoMaxTreeEnabled and activeTreeGen == treeGeneration and sessionActive
				end, function()
					buyMaxTreeUpgrades()
					refreshShopHUD()
					return 4
				end)
			end
		end,
	})
	treeProgressStatusLabel = treeControls:Label({ Text = "Loading Tree Progress (86 Nodes)...", Size = 10 })

	local upgradeControls = tab_shop.Toggle({
		Title = T("buy_upg_tog"),
		Info = T("buy_upg_inf"),
		Default = autoUpgradeEnabled,
		Callback = function(enabled)
			saveSetting("AnimeDiceAutoUpgrades", enabled)
			autoUpgradeEnabled = enabled
			upgradeGeneration += 1
			local activeUpgradeGeneration = upgradeGeneration
			if enabled then
				runWorker(function()
					return autoUpgradeEnabled and activeUpgradeGeneration == upgradeGeneration and sessionActive
				end, function()
					buySelectedUpgrades()
					refreshShopHUD()
					return 5
				end)
			end
		end,
	})
	local upgradeDropdownOptions = table.clone(upgradeOptions)
	upgradeControls:Dropdown({
		Title = T("upg_branches"),
		List = upgradeOptions,
		Default = getSavedSelection("AnimeDiceUpgradeBranches", upgradeDropdownOptions, true),
		Multi = true,
		Callback = function(selectedUpgradeNames)
			saveSetting("AnimeDiceUpgradeBranches", selectedUpgradeNames)
			selectedUpgrades = selectionToSet(selectedUpgradeNames)
		end,
	})
	upgradeControls:Button({
		Title = T("buy_upg_btn"),
		Text = T("buy_btn"),
		Callback = function()
			task.spawn(function()
				local bought, count, total = buyMaxTreeUpgrades()
				refreshShopHUD()
				local notificationText = bought > 0 and ("%d upgrade(s) bought (%d/%d)"):format(bought, count, total)
					or T("notif_no_upg")
				showNotification(T("notif_upgrades"), notificationText)
			end)
		end,
	})
	refreshShopHUD()
end

-- ─── TAB 4: Units & Progression (4/9) ────────────────────────
tab_units.Header({ Title = T("tab_units") .. " (4/9)" })
tab_units.Header({ Title = T("header_level") })

do
	local levelControls = tab_units.Toggle({
		Title = T("level_tog"),
		Info = T("level_inf"),
		Default = autoLevelEnabled,
		Callback = function(enabled)
			saveSetting("AnimeDiceAutoLevelUp", enabled)
			autoLevelEnabled = enabled
			levelGeneration += 1
			local activeLevelGeneration = levelGeneration
			if enabled then
				runWorker(function()
					return autoLevelEnabled and activeLevelGeneration == levelGeneration and sessionActive
				end, function()
					runLevelUpPass(activeLevelGeneration)
					return 5
				end)
			end
		end,
	})
	levelControls:Dropdown({
		Title = T("min_rarity"),
		List = rarityOptions,
		Default = getSavedSelection("AnimeDiceLevelUpRarity", "Common", false),
		Callback = function(selectedRarity)
			minimumRarity = tostring(selectedRarity)
			saveSetting("AnimeDiceLevelUpRarity", minimumRarity)
		end,
	})
	local targetLevelText = tostring(targetLevel)
	levelControls:Textbox({
		Title = T("target_lvl"),
		Placeholder = targetLevelText,
		Default = tostring(getSavedValue("AnimeDiceLevelUpTarget", targetLevelText)),
		Numeric = true,
		Callback = function(levelValue)
			local parsedLevel = tonumber(levelValue)
			if parsedLevel and parsedLevel >= 1 then
				targetLevel = math.floor(parsedLevel)
				saveSetting("AnimeDiceLevelUpTarget", tostring(targetLevel))
				return
			end
			warn("[AutoLevelUp] invalid value, target level unchanged:", targetLevel)
		end,
	})
	levelControls:Button({
		Title = T("run_pass_btn"),
		Text = T("run_btn"),
		Callback = function()
			task.spawn(function()
				local levelsPurchased = runLevelUpPass()
				local notificationText = levelsPurchased > 0 and ("%d level(s)"):format(levelsPurchased)
					or T("notif_no_level")
				showNotification(T("notif_levelup"), notificationText)
			end)
		end,
	})
end

local function createRerollSection(options)
	tab_units.Header({ Title = options.header })
	local initialEnabled = getSavedValue(options.enabledKey, false) == true
	local enabled = initialEnabled
	local generation = 0
	local overwriteProtected = getSavedValue(options.overwriteKey, false) == true
	local target = tostring(getSavedSelection(options.targetKey, options.defaultTarget, false))

	local function getModules()
		return safeRequire(Features.Data.DataController),
			safeRequire(Features.Inventory.EntryRegistry),
			safeRequire(options.definitions)
	end

	local function runPass()
		local dataController, entryRegistry, definitions = getModules()
		if not dataController or not entryRegistry or not definitions then
			return 0
		end

		local inventoryOk, inventory = pcall(dataController.Inventory)
		if not inventoryOk or type(inventory) ~= "table" then
			return 0
		end

		local entryController = safeRequire(Features.Inventory.EntryController)
		local currency = 0
		if entryController and typeof(entryController.GetAmount) == "function" then
			local ok, amt = pcall(entryController.GetAmount, options.currency)
			if ok and type(amt) == "number" then
				currency = amt
			end
		end
		if currency <= 0 and inventory[options.currency] then
			currency = tonumber(inventory[options.currency].amount) or 0
		end

		if currency <= 0 then
			return 0
		end

		local targetOrder = (definitions[target] or {}).order or 0

		-- Prioritize units in order of value:
		-- 1. Plotted units (actively earning income on plot)
		-- 2. Tower team units
		-- 3. Highest tier backpack units (Titanic, Huge)
		local unitIds = {}
		local seen = {}

		local slotsOk, slots = pcall(dataController.Slots)
		if slotsOk and type(slots) == "table" then
			for _, slot in pairs(slots) do
				if slot and slot.unitId and not seen[slot.unitId] then
					seen[slot.unitId] = true
					unitIds[#unitIds + 1] = slot.unitId
				end
			end
		end

		local teamOk, team = pcall(function() return dataController.TowerTeam and dataController.TowerTeam() end)
		if teamOk and type(team) == "table" then
			for _, uId in pairs(team) do
				if uId and not seen[uId] and inventory[uId] then
					seen[uId] = true
					unitIds[#unitIds + 1] = uId
				end
			end
		end

		for unitId, entry in pairs(inventory) do
			if not seen[unitId] and type(entry) == "table" and entry.name then
				local config = entryRegistry.getEntryConfig(entry.name)
				if config and config.kind == "Unit" then
					local nameLower = entry.name:lower()
					if nameLower:find("titanic") or nameLower:find("huge") then
						seen[unitId] = true
						unitIds[#unitIds + 1] = unitId
					end
				end
			end
		end

		local rolls = 0
		for _, unitId in ipairs(unitIds) do
			while sessionActive and currency > 0 do
				local curOk, currentInventory = pcall(dataController.Inventory)
				local unit = curOk and currentInventory[unitId]
				if not unit or not unit.attributes then
					break
				end

				local currentAttr = unit.attributes[options.attribute]
				local currentDef = definitions[currentAttr]
				local currentOrder = currentDef and currentDef.order or 0

				if currentOrder >= targetOrder then
					break
				end
				if currentDef and currentDef.protected and not overwriteProtected then
					break
				end

				fireRemote(options.remote, unitId, true)
				currency -= 1
				rolls += 1
				task.wait(0.35)
			end
			if not sessionActive or currency <= 0 then
				break
			end
		end
		return rolls
	end

	local controls = tab_units.Toggle({
		Title = options.toggleTitle,
		Info = options.info,
		Default = initialEnabled,
		Callback = function(value)
			saveSetting(options.enabledKey, value)
			enabled = value
			generation += 1
			local activeGeneration = generation
			if value then
				runWorker(function()
					return enabled and activeGeneration == generation and sessionActive
				end, function()
					runPass()
					return 6
				end)
			end
		end,
	})

	-- AUTO-START on script boot if saved as enabled
	if initialEnabled then
		generation += 1
		local activeGeneration = generation
		runWorker(function()
			return enabled and activeGeneration == generation and sessionActive
		end, function()
			runPass()
			return 6
		end)
	end

	local definitions = select(3, getModules()) or {}
	local ordered = {}
	for name, config in pairs(definitions) do
		ordered[#ordered + 1] = { name = name, order = config.order or 0 }
	end
	table.sort(ordered, function(left, right)
		return left.order < right.order
	end)
	local targets = {}
	for _, entry in ipairs(ordered) do
		targets[#targets + 1] = entry.name
	end

	controls:Dropdown({
		Title = options.targetTitle,
		List = targets,
		Default = target,
		Callback = function(value)
			target = tostring(value)
			saveSetting(options.targetKey, target)
		end,
	})
	controls:Toggle({
		Title = options.overwriteTitle,
		Default = overwriteProtected,
		Callback = function(value)
			overwriteProtected = value
			saveSetting(options.overwriteKey, value)
		end,
	})
	controls:Button({
		Title = T("run_pass_btn"),
		Text = T("run_btn"),
		Callback = function()
			task.spawn(function()
				local rolls = runPass()
				showNotification(options.notificationTitle, rolls > 0 and ("%d roll(s)"):format(rolls) or "Nothing to roll.")
			end)
		end,
	})
end

createRerollSection({
	header = T("header_grades"),
	toggleTitle = T("reroll_grades"),
	info = T("reroll_grd_inf"),
	targetTitle = T("target_grade"),
	overwriteTitle = T("protect_s_plus"),
	notificationTitle = "Grade",
	enabledKey = "AnimeDiceAutoGrade",
	targetKey = "AnimeDiceGradeTarget",
	overwriteKey = "AnimeDiceGradeOverwrite",
	defaultTarget = "S",
	currency = "Gems",
	attribute = "grade",
	definitions = Features.Grades.Grades,
	remote = Roll,
})

createRerollSection({
	header = T("header_traits"),
	toggleTitle = T("reroll_traits"),
	info = T("reroll_trt_inf"),
	targetTitle = T("target_trait"),
	overwriteTitle = T("protect_shogun"),
	notificationTitle = "Trait",
	enabledKey = "AnimeDiceAutoTrait",
	targetKey = "AnimeDiceTraitTarget",
	overwriteKey = "AnimeDiceTraitOverwrite",
	defaultTarget = "Damage I",
	currency = "Trait Reroll",
	attribute = "trait",
	definitions = Features.Traits.Traits,
	remote = Roll2,
})

tab_units.Header({ Title = T("header_rebirth") })

do
	local rebirthControls = tab_units.Toggle({
		Title = T("rebirth_tog"),
		Info = T("rebirth_inf"),
		Default = autoRebirthEnabled,
		Callback = function(enabled)
			saveSetting("AnimeDiceAutoRebirth", enabled)
			autoRebirthEnabled = enabled
			rebirthGeneration += 1
			local activeRebirthGeneration = rebirthGeneration
			if enabled then
				runWorker(function()
					return autoRebirthEnabled and activeRebirthGeneration == rebirthGeneration and sessionActive
				end, function()
					tryRebirth()
					return 3
				end)
			end
		end,
	})
	rebirthControls:Button({
		Title = T("rebirth_now"),
		Text = T("rebirth_btn"),
		Callback = function()
			task.spawn(function()
				local currentRebirth, availableMoney, nextRebirth = getRebirthState()
				if not nextRebirth then
					local displayedRebirth = currentRebirth or 0
					showNotification(T("notif_rebirth"), T("notif_max_lvl"):format(displayedRebirth))
					return
				end
				if not tryRebirth() then
					local missingMoney = formatNumber(nextRebirth.cost - availableMoney)
					showNotification(T("notif_rebirth"), T("notif_missing"):format(missingMoney))
				end
			end)
		end,
	})
end

-- ─── TAB 5: Tower & Quests (5/9) ─────────────────────────────
tab_towers.Header({ Title = T("tab_towers") .. " (5/9)" })
tab_towers.Header({ Title = T("header_tower") })

do
	local equipBestTowerTeamEnabled = getSavedValue("AnimeDiceTowerReEquip", true) == true

	local function runTowerOnce(generationToken)
		if not sessionActive or not autoTowerEnabled or generationToken ~= towerGeneration then
			return false
		end
		local started, accepted = invokeRemote(PlayTower, "Dragon Tower")
		if not started or not accepted then
			invokeRemote(CancelTower)
			task.wait(0.3)
			started, accepted = invokeRemote(PlayTower, "Dragon Tower")
			if not started or not accepted then
				return false
			end
		end
		local emptyRetries = 0
		while sessionActive and autoTowerEnabled and generationToken == towerGeneration and LocalPlayer.Parent ~= nil do
			task.wait(0.3)
			local ok, result = invokeRemote(CompleteTowerFloor)
			if ok and type(result) == "table" and #result > 0 then
				emptyRetries = 0
				local done = false
				for _, entry in ipairs(result) do
					if entry.action == "ended" then
						done = true
						break
					end
				end
				if done then return true end
			else
				emptyRetries += 1
				if emptyRetries > 8 then
					break
				end
			end
		end
		return false
	end

	startTowerAutomation = function(generationToken)
		if not generationToken then
			towerGeneration += 1
			generationToken = towerGeneration
		end
		local activeTowerGeneration = generationToken
		if not autoTowerEnabled then
			return
		end
		task.spawn(function()
			if equipBestTowerTeamEnabled then
				fireRemote(EquipBestTowerTeam)
				task.wait(0.5)
			end
			local SetAutoTower = Network and Network:FindFirstChild("Towers") and Network.Towers:FindFirstChild("RE") and Network.Towers.RE:FindFirstChild("SetAutoTower")
			if SetAutoTower then
				fireRemote(SetAutoTower, "Dragon Tower")
			end
			local towerController = safeRequire(Features.Towers.TowerController)
			while sessionActive and autoTowerEnabled and activeTowerGeneration == towerGeneration and LocalPlayer.Parent ~= nil do
				local uiRefs = safeRequire(Features.UI.UIReferences)
				local towerScreen = uiRefs and uiRefs.Root and uiRefs.Root:FindFirstChild("Tower") and uiRefs.Root.Tower:FindFirstChild("Screen")
				local isTowerRunning = towerScreen and (towerScreen.Visible or (towerScreen.Parent and towerScreen.Parent:FindFirstChild("Hidden") and towerScreen.Parent.Hidden.Visible))

				if not isTowerRunning then
					if towerController and typeof(towerController.startTower) == "function" then
						pcall(towerController.startTower, "Dragon Tower")
					else
						runTowerOnce(activeTowerGeneration)
					end
				end

				if autoTowerEnabled and activeTowerGeneration == towerGeneration and equipBestTowerTeamEnabled then
					fireRemote(EquipBestTowerTeam)
				end
				task.wait(4.0)
			end
		end)
	end

	local towerControls = tab_towers.Toggle({
		Title = T("tower_tog"),
		Info = T("tower_inf"),
		Default = autoTowerEnabled,
		Callback = function(enabled)
			saveSetting("AnimeDiceAutoTower", enabled)
			autoTowerEnabled = enabled
			towerGeneration += 1
			local activeTowerGen = towerGeneration
			if enabled then
				startTowerAutomation(activeTowerGen)
			else
				local SetAutoTower = Network and Network:FindFirstChild("Towers") and Network.Towers:FindFirstChild("RE") and Network.Towers.RE:FindFirstChild("SetAutoTower")
				if SetAutoTower then
					fireRemote(SetAutoTower, false)
				end
				invokeRemote(CancelTower)
			end
		end,
	})
	towerControls:Toggle({
		Title = T("re_equip_run"),
		Default = equipBestTowerTeamEnabled,
		Callback = function(equipBest)
			saveSetting("AnimeDiceTowerReEquip", equipBest)
			equipBestTowerTeamEnabled = equipBest
		end,
	})
	towerControls:Button({
		Title = T("equip_team_btn"),
		Text = T("equip_btn"),
		Callback = function()
			task.spawn(function()
				fireRemote(EquipBestTowerTeam)
				task.wait(1.1)
				showNotification(T("notif_tower"), T("notif_team_upd"))
			end)
		end,
	})
end

tab_towers.Header({ Title = T("header_quests") })

do
	local questControls = tab_towers.Toggle({
		Title = T("quests_tog"),
		Info = T("quests_inf"),
		Default = autoQuestEnabled,
		Callback = function(enabled)
			saveSetting("AnimeDiceAutoClaimQuests", enabled)
			autoQuestEnabled = enabled
			questGeneration += 1
			local activeQuestGeneration = questGeneration
			if enabled then
				runWorker(function()
					return autoQuestEnabled and activeQuestGeneration == questGeneration and sessionActive
				end, function()
					claimCompletedQuests()
					return 10
				end)
			end
		end,
	})
	questControls:Button({
		Title = T("claim_now_btn"),
		Text = T("claim_btn"),
		Callback = function()
			task.spawn(function()
				local claimedQuestCount = claimCompletedQuests()
				local notificationText = claimedQuestCount > 0 and ("%d quest(s) claimed"):format(claimedQuestCount)
					or T("notif_no_quest")
				showNotification(T("notif_quests"), notificationText)
			end)
		end,
	})
end

-- ─── TAB 6: Smart Auto Sell (6/9) ────────────────────────────
tab_sell.Header({ Title = T("tab_sell") .. " (6/9)" })
tab_sell.Header({ Title = T("header_sell") })

do
	local sellInterval = math.max(tonumber(getSavedValue("AnimeDiceSellInterval", 4)) or 4, 1)

	local sellControls = tab_sell.Toggle({
		Title = T("sell_tog"),
		Info = T("sell_inf"),
		Default = autoSellEnabled,
		Callback = function(enabled)
			saveSetting("AnimeDiceAutoSell", enabled)
			autoSellEnabled = enabled
			sellGeneration += 1
			local activeSellGeneration = sellGeneration
			if enabled then
				runWorker(function()
					return autoSellEnabled and activeSellGeneration == sellGeneration and sessionActive
				end, function()
					sellSelectedUnits()
					return sellInterval
				end)
			end
		end,
	})
	sellControls:Toggle({
		Title = T("sell_dup_huge"),
		Info = T("sell_dup_huge_inf"),
		Default = sellDuplicateHugeEnabled,
		Callback = function(enabled)
			saveSetting("AnimeDiceSellDuplicateHuge", enabled)
			sellDuplicateHugeEnabled = enabled
		end,
	})
	sellControls:Toggle({
		Title = T("sell_dup_titanic"),
		Info = T("sell_dup_titanic_inf"),
		Default = sellDuplicateTitanicEnabled,
		Callback = function(enabled)
			saveSetting("AnimeDiceSellDuplicateTitanic", enabled)
			sellDuplicateTitanicEnabled = enabled
		end,
	})
	sellControls:Dropdown({
		Title = T("sell_all_mut"),
		List = rarityOptions,
		Default = getSavedSelection("AnimeDiceSellRaritiesAll", { "Common", "Uncommon" }, true),
		Multi = true,
		Callback = function(rarities)
			saveSetting("AnimeDiceSellRaritiesAll", rarities)
			sellAnyMutationRarities = selectionToSet(rarities)
		end,
	})
	sellControls:Dropdown({
		Title = T("sell_req_mut"),
		List = rarityOptions,
		Default = getSavedSelection("AnimeDiceSellMutatedRarities", {}, true),
		Multi = true,
		Callback = function(rarities)
			saveSetting("AnimeDiceSellMutatedRarities", rarities)
			sellSelectedMutationRarities = selectionToSet(rarities)
		end,
	})
	sellControls:Dropdown({
		Title = T("sell_mut_list"),
		List = sellMutationOptions,
		Default = getSavedSelection("AnimeDiceSellMutations", {}, true),
		Multi = true,
		Callback = function(mutations)
			saveSetting("AnimeDiceSellMutations", mutations)
			selectedSellMutations = selectionToSet(mutations)
		end,
	})
	sellControls:Slider({
		Title = T("sell_interval"),
		Min = 1,
		Max = 30,
		Round = 1,
		Default = sellInterval,
		Suffix = "s",
		Callback = function(interval)
			saveSetting("AnimeDiceSellInterval", interval)
			sellInterval = math.max(tonumber(interval) or 4, 1)
		end,
	})
	sellControls:Button({
		Title = T("sell_now_btn"),
		Text = T("sell_btn"),
		Callback = function()
			task.spawn(function()
				local moneyEarned, unitsSold = sellSelectedUnits()
				local notificationText = unitsSold > 0
						and ("%d units  ·  +$%s"):format(unitsSold, formatNumber(moneyEarned))
					or T("notif_no_sell")
				showNotification(T("notif_sell"), notificationText)
			end)
		end,
	})
end

-- ─── TAB 7: Boost Potions (7/9) ──────────────────────────────
tab_potions.Header({ Title = T("tab_potions") .. " (7/9)" })
tab_potions.Header({ Title = T("header_potions") })

do
	local potionControls = tab_potions.Toggle({
		Title = T("potions_tog"),
		Info = T("potions_inf"),
		Default = autoPotionsEnabled,
		Callback = function(enabled)
			saveSetting("AnimeDiceAutoPotions", enabled)
			autoPotionsEnabled = enabled
			potionGeneration += 1
			local activePotionGeneration = potionGeneration
			if enabled then
				runWorker(function()
					return autoPotionsEnabled and activePotionGeneration == potionGeneration and sessionActive
				end, function()
					useAvailablePotions()
					return 6
				end)
			end
		end,
	})

	for _, entry in ipairs({ "Luck", "Money", "Damage" }) do
		local potionCategory = entry
		local dropdownKey = potionCategory == "Luck" and "luck_potions"
			or potionCategory == "Money" and "money_potions"
			or "damage_potions"
		local potionConfigFlag = "AnimeDicePotion" .. potionCategory

		potionControls:Dropdown({
			Title = T(dropdownKey),
			List = { "Normal", "Dragon", "Cursed", "Pirate" },
			Default = getSavedSelection(potionConfigFlag, potionCategory == "Damage" and {} or { "Normal", "Dragon" }, true),
			Multi = true,
			Callback = function(selectedTiers)
				saveSetting(potionConfigFlag, selectedTiers)
				selectedPotionTiers[potionCategory] = selectionToSet(selectedTiers)
				refreshPotionSelection()
			end,
		})
	end

	potionControls:Button({
		Title = T("use_potions"),
		Text = T("use_btn"),
		Callback = function()
			task.spawn(function()
				local potionsUsed = useAvailablePotions()
				local notificationText = potionsUsed > 0 and ("%d potion(s) used"):format(potionsUsed)
					or T("notif_no_pot")
				showNotification(T("notif_potions"), notificationText)
			end)
		end,
	})
end

-- ??? TAB 8: Halloween Event (8/9) ?????????????????????????????
; (function()
	tab_halloween.Header({ Title = T("tab_halloween") .. " (8/9)" })
tab_halloween.Header({ Title = T("header_hw_status") })

local halloweenStatusLabel
local autoTrickOrTreatEnabled = getSavedValue("AnimeDiceAutoToT", false) == true
local totWalkSpeed = math.clamp(tonumber(getSavedValue("AnimeDiceToTSpeed", 42)) or 42, 20, 50)
local autoHauntedHouseEnabled = getSavedValue("AnimeDiceAutoHaunted", false) == true
local selectedHauntedWing = tostring(getSavedSelection("AnimeDiceHauntedWing", "Front Yard", false))
local autoRollPumpkinDiceEnabled = getSavedValue("AnimeDiceAutoPumpkinDice", false) == true
local pumpkinDiceRollMulti = tonumber(getSavedValue("AnimeDicePumpkinDiceMulti", 1)) or 1
local autoClaimPumpkinPassEnabled = getSavedValue("AnimeDiceAutoPumpkinPass", true) == true
local autoClaimHalloweenQuestsEnabled = getSavedValue("AnimeDiceAutoHalloweenQuests", true) == true
local autoBuyCandyShopEnabled = getSavedValue("AnimeDiceAutoCandyShop", false) == true
local selectedCandyShopItem = tostring(getSavedSelection("AnimeDiceCandyShopItem", "Candy Pot III", false))

local totGeneration = 0
local hauntedGeneration = 0
local pumpkinDiceGeneration = 0
local halloweenClaimGeneration = 0

-- Helper: Get Halloween Currencies
local function getHalloweenCurrencies()
	local candy, pumpkins = 0, 0
	local entryController = safeRequire(Features.Inventory.EntryController)
	if entryController and typeof(entryController.GetAmount) == "function" then
		candy = tonumber(entryController.GetAmount("Candy")) or 0
		pumpkins = tonumber(entryController.GetAmount("Pumpkins")) or 0
	else
		local dc = safeRequire(Features.Data.DataController)
		local inv = dc and pcall(dc.Inventory) and dc.Inventory() or {}
		candy = tonumber(inv["Candy"] and inv["Candy"].amount) or 0
		pumpkins = tonumber(inv["Pumpkins"] and inv["Pumpkins"].amount) or 0
	end
	return candy, pumpkins
end

-- Helper: Check if Player is on Halloween Island
local function isPlayerOnHalloweenIsland()
	local char = LocalPlayer.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	return hrp and hrp.Position.Z > 9000
end

-- Helper: Teleport Player
local function teleportToHalloweenLocation(destination)
	if TeleportHalloweenRF then
		local ok, res = pcall(function()
			return TeleportHalloweenRF:InvokeServer(destination)
		end)
		if ok and res then
			showNotification("Halloween Teleport", destination == "Island" and "Teleported to Halloween Island!" or "Teleported to Hub!")
			return true
		end
	end
	showNotification("Halloween Teleport", "Teleport failed, please try again.")
	return false
end

-- Optimal precomputed door path coordinates (ring sequence)
local OPTIMAL_HALLOWEEN_DOORS = {
	Vector3.new(-1873.3, -16.5, 11365.1), -- Door 1
	Vector3.new(-1799.5, -16.5, 11360.6), -- Door 4
	Vector3.new(-1806.8, -16.5, 11322.6), -- Door 5
	Vector3.new(-1873.3, -16.5, 11316.4), -- Door 2
	Vector3.new(-1915.1, -16.5, 11268.3), -- Door 6
	Vector3.new(-1993.9, -16.5, 11360.6), -- Door 7
	Vector3.new(-2078.3, -16.5, 11351.7), -- Door 3
}

local currentDoorIdx = 0

local function refreshHalloweenDashboard()
	if not halloweenStatusLabel then return end
	local candy, pumpkins = getHalloweenCurrencies()
	local onIsland = isPlayerOnHalloweenIsland()
	local readyAt = LocalPlayer:GetAttribute("TrickOrTreatReadyAt") or 0
	local now = workspace:GetServerTimeNow()
	local totReadyText = readyAt <= now and "READY! ??" or string.format("Refilling in %ds", math.max(0, math.ceil(readyAt - now)))
	local uiRefs = safeRequire(Features.UI.UIReferences)
	local towerScreen = uiRefs and uiRefs.Root and uiRefs.Root:FindFirstChild("Tower") and uiRefs.Root.Tower:FindFirstChild("Screen")
	local floorText = towerScreen and towerScreen.Visible and towerScreen:FindFirstChild("Floor") and towerScreen.Floor.Text or "Inactive"

	halloweenStatusLabel.Text = table.concat({
		string.format("?? Location: %s", onIsland and "Halloween Island ??" or "Main Hub ??"),
		string.format("?? Candy: %s  |  ?? Pumpkins: %s", formatNumber(candy), formatNumber(pumpkins)),
		string.format("?? Trick or Treat: %s", totReadyText),
		string.format("?? Haunted House: %s (Floor: %s)", autoHauntedHouseEnabled and selectedHauntedWing or "Off", floorText),
	}, "\n")
end

local hwStatusControl = tab_halloween.Toggle({
	Title = T("header_hw_status"),
	Info = "Live Halloween telemetry, Island teleport, and status.",
	Default = false,
})

halloweenStatusLabel = hwStatusControl:Label({ Text = "Loading Halloween Status...", Size = 10 })

hwStatusControl:Button({
	Title = T("halloween_teleport"),
	Text = "Island",
	Callback = function()
		task.spawn(teleportToHalloweenLocation, "Island")
	end,
})

hwStatusControl:Button({
	Title = T("halloween_hub"),
	Text = "Hub",
	Callback = function()
		task.spawn(teleportToHalloweenLocation, "Hub")
	end,
})

-- SECTION 2: Auto Trick or Treat
tab_halloween.Header({ Title = T("header_hw_tot") })

local function runTrickOrTreatStep()
	local char = LocalPlayer.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if not hrp then return 1.5 end

	-- Ensure player is on Halloween Island
	if not isPlayerOnHalloweenIsland() then
		if TeleportHalloweenRF then
			pcall(function() TeleportHalloweenRF:InvokeServer("Island") end)
			task.wait(2.0)
		end
		return 2.0
	end

	-- Check readyAt
	local readyAt = LocalPlayer:GetAttribute("TrickOrTreatReadyAt") or 0
	local now = workspace:GetServerTimeNow()
	if readyAt > now then
		local waitSeconds = math.min(readyAt - now, 4.0)
		return math.max(waitSeconds, 0.8)
	end

	currentDoorIdx = (currentDoorIdx % #OPTIMAL_HALLOWEEN_DOORS) + 1
	local targetPos = OPTIMAL_HALLOWEEN_DOORS[currentDoorIdx]

	local startPos = hrp.Position
	local dist = (startPos - targetPos).Magnitude
	local safeSpeed = math.clamp(totWalkSpeed, 20, 50)
	local travelTime = math.max(dist / safeSpeed, 1.2)

	local tween = TweenService:Create(hrp, TweenInfo.new(travelTime, Enum.EasingStyle.Linear), {
		CFrame = CFrame.new(targetPos)
	})
	tween:Play()
	tween.Completed:Wait()

	-- Pause at door to allow server knock detection
	task.wait(2.2)
	refreshHalloweenDashboard()
	return 0.4
end

local totControls = tab_halloween.Toggle({
	Title = T("halloween_tot"),
	Info = T("halloween_tot_inf"),
	Default = autoTrickOrTreatEnabled,
	Callback = function(enabled)
		saveSetting("AnimeDiceAutoToT", enabled)
		autoTrickOrTreatEnabled = enabled
		totGeneration += 1
		local curGen = totGeneration
		if enabled then
			runWorker(function()
				return autoTrickOrTreatEnabled and curGen == totGeneration and sessionActive
			end, function()
				return runTrickOrTreatStep()
			end)
		end
	end,
})

totControls:Slider({
	Title = T("halloween_tot_speed"),
	Min = 25,
	Max = 50,
	Default = totWalkSpeed,
	Callback = function(speed)
		totWalkSpeed = math.clamp(speed, 20, 50)
		saveSetting("AnimeDiceToTSpeed", totWalkSpeed)
	end,
})

-- SECTION 3: Auto Haunted House Tower
tab_halloween.Header({ Title = T("header_hw_haunted") })

local HAUNTED_WINGS = {
	"Front Yard",
	"Foyer",
	"Crypt",
	"Attic",
	"Bell Tower",
	"The Abyss",
}

local function runHauntedHouseStep()
	local uiRefs = safeRequire(Features.UI.UIReferences)
	local towerScreen = uiRefs and uiRefs.Root and uiRefs.Root:FindFirstChild("Tower") and uiRefs.Root.Tower:FindFirstChild("Screen")
	local isTowerRunning = towerScreen and (towerScreen.Visible or (towerScreen.Parent and towerScreen.Parent:FindFirstChild("Hidden") and towerScreen.Parent.Hidden.Visible))

	if isTowerRunning then
		return 3.5
	end

	if equipBestTowerTeamEnabled and EquipBestTowerTeam then
		fireRemote(EquipBestTowerTeam)
		task.wait(0.4)
	end

	local wing = selectedHauntedWing or "Front Yard"
	local towerController = safeRequire(Features.Towers.TowerController)
	if towerController and typeof(towerController.startTower) == "function" then
		pcall(towerController.startTower, wing)
	else
		pcall(function() PlayTower:InvokeServer(wing) end)
	end

	if SetAutoTower then
		fireRemote(SetAutoTower, wing)
	end

	refreshHalloweenDashboard()
	return 4.0
end

local hauntedControls = tab_halloween.Toggle({
	Title = T("halloween_haunted"),
	Info = T("halloween_haunted_inf"),
	Default = autoHauntedHouseEnabled,
	Callback = function(enabled)
		saveSetting("AnimeDiceAutoHaunted", enabled)
		autoHauntedHouseEnabled = enabled
		hauntedGeneration += 1
		local curGen = hauntedGeneration
		if enabled then
			runWorker(function()
				return autoHauntedHouseEnabled and curGen == hauntedGeneration and sessionActive
			end, function()
				return runHauntedHouseStep()
			end)
		else
			if SetAutoTower then fireRemote(SetAutoTower, false) end
			invokeRemote(CancelTower)
		end
	end,
})

hauntedControls:Dropdown({
	Title = T("halloween_haunted_wing"),
	List = HAUNTED_WINGS,
	Default = selectedHauntedWing,
	Callback = function(wing)
		selectedHauntedWing = tostring(wing)
		saveSetting("AnimeDiceHauntedWing", selectedHauntedWing)
	end,
})

-- SECTION 4: Auto Pumpkin Dice
tab_halloween.Header({ Title = T("header_hw_dice") })

local function runPumpkinDiceStep()
	if not RollPumpkinDiceRF then return 4.0 end
	local _, pumpkins = getHalloweenCurrencies()
	local multi = pumpkinDiceRollMulti or 1
	local cost = 1 * multi

	if pumpkins < cost then
		return 4.0
	end

	-- Auto inventory management
	local used, capacity = getInventoryUsage()
	if used and capacity and used >= (capacity - multi) then
		sellSelectedUnits()
		task.wait(0.3)
	end

	local ok, res = pcall(function()
		return RollPumpkinDiceRF:InvokeServer(multi)
	end)

	if ok and type(res) == "table" and res.ok then
		refreshHalloweenDashboard()
		return 0.8
	end
	return 2.5
end

local pumpkinDiceControls = tab_halloween.Toggle({
	Title = T("halloween_pumpkin_dice"),
	Info = T("halloween_pumpkin_dice_inf"),
	Default = autoRollPumpkinDiceEnabled,
	Callback = function(enabled)
		saveSetting("AnimeDiceAutoPumpkinDice", enabled)
		autoRollPumpkinDiceEnabled = enabled
		pumpkinDiceGeneration += 1
		local curGen = pumpkinDiceGeneration
		if enabled then
			runWorker(function()
				return autoRollPumpkinDiceEnabled and curGen == pumpkinDiceGeneration and sessionActive
			end, function()
				return runPumpkinDiceStep()
			end)
		end
	end,
})

pumpkinDiceControls:Dropdown({
	Title = T("halloween_dice_mode"),
	List = { "Roll x1", "Roll x5 (Multi)" },
	Default = pumpkinDiceRollMulti == 5 and "Roll x5 (Multi)" or "Roll x1",
	Callback = function(val)
		pumpkinDiceRollMulti = tostring(val):find("5") and 5 or 1
		saveSetting("AnimeDicePumpkinDiceMulti", pumpkinDiceRollMulti)
	end,
})

-- SECTION 5: Halloween Pass & Quests
tab_halloween.Header({ Title = T("header_hw_rewards") })

local function runHalloweenClaimStep()
	-- Claim Pumpkin Pass tiers
	if autoClaimPumpkinPassEnabled and ClaimAllPathHalloweenRE then
		pcall(function() ClaimAllPathHalloweenRE:FireServer() end)
	end

	-- Claim Halloween Quests
	if autoClaimHalloweenQuestsEnabled and ClaimHalloweenQuestRE then
		pcall(function()
			local HQ = safeRequire(Features.Halloween.HalloweenQuests)
			local DC = safeRequire(Features.Data.DataController)
			if HQ and DC and DC.Halloween then
				for _, period in ipairs(HQ.PERIODS or { "Hourly", "Daily" }) do
					local pCfg = HQ[period]
					local dKey = pCfg and pCfg.dataKey
					local data = dKey and DC.Halloween[dKey]
					if data and data.ids then
						local ids = data.ids()
						for _, id in ipairs(ids) do
							local prog = data.progress and data.progress[id] and data.progress[id]() or 0
							local claimed = data.claimed and data.claimed[id] and data.claimed[id]() or false
							local target = 999999
							for _, q in ipairs(pCfg.pool or {}) do
								if q.id == id then target = q.target break end
							end
							if prog >= target and not claimed then
								ClaimHalloweenQuestRE:FireServer(period, id)
								task.wait(0.25)
							end
						end
					end
				end
			end
		end)
	end
	refreshHalloweenDashboard()
	return 8.0
end

tab_halloween.Toggle({
	Title = T("halloween_pass"),
	Info = T("halloween_pass_inf"),
	Default = autoClaimPumpkinPassEnabled,
	Callback = function(enabled)
		saveSetting("AnimeDiceAutoPumpkinPass", enabled)
		autoClaimPumpkinPassEnabled = enabled
	end,
})

tab_halloween.Toggle({
	Title = T("halloween_quests"),
	Info = T("halloween_quests_inf"),
	Default = autoClaimHalloweenQuestsEnabled,
	Callback = function(enabled)
		saveSetting("AnimeDiceAutoHalloweenQuests", enabled)
		autoClaimHalloweenQuestsEnabled = enabled
	end,
})

-- SECTION 6: Halloween Candy Shop
tab_halloween.Header({ Title = T("header_hw_shop") })

local CANDY_SHOP_OFFERS = {
	"Candy Pot III",
	"Pumpkin Pot III",
	"Spooky Luck III",
	"Pumpkin Jackpot",
	"Witch's Jackpot",
	"Haunted Potion",
	"Candy Pot II",
	"Pumpkin Pot II",
	"Spooky Luck II",
}

local function runCandyShopStep()
	if not autoBuyCandyShopEnabled or not BuyOfferHalloweenRE then return 8.0 end
	local candy = getHalloweenCurrencies()
	local HS = safeRequire(Features.Halloween.HalloweenShop)
	if not HS then return 8.0 end

	local targetIdx = nil
	local targetCost = 999999
	for i, item in ipairs(HS) do
		if item.name == selectedCandyShopItem then
			targetIdx = i
			targetCost = item.cost or 0
			break
		end
	end

	if targetIdx and candy >= targetCost then
		pcall(function()
			BuyOfferHalloweenRE:FireServer(targetIdx)
		end)
		refreshHalloweenDashboard()
		return 4.0
	end
	return 8.0
end

local candyShopControls = tab_halloween.Toggle({
	Title = T("halloween_shop"),
	Info = T("halloween_shop_inf"),
	Default = autoBuyCandyShopEnabled,
	Callback = function(enabled)
		saveSetting("AnimeDiceAutoCandyShop", enabled)
		autoBuyCandyShopEnabled = enabled
	end,
})

candyShopControls:Dropdown({
	Title = T("halloween_shop_item"),
	List = CANDY_SHOP_OFFERS,
	Default = selectedCandyShopItem,
	Callback = function(item)
		selectedCandyShopItem = tostring(item)
		saveSetting("AnimeDiceCandyShopItem", selectedCandyShopItem)
	end,
})

-- Periodic claim & shop worker
runWorker(function()
	return (autoClaimPumpkinPassEnabled or autoClaimHalloweenQuestsEnabled or autoBuyCandyShopEnabled) and sessionActive
end, function()
	runHalloweenClaimStep()
	if autoBuyCandyShopEnabled then
		runCandyShopStep()
	end
	return 8.0
end)

-- Dashboard status refresher
task.spawn(function()
	task.wait(1.0)
	while sessionActive do
		pcall(refreshHalloweenDashboard)
		task.wait(3.0)
	end
end)

-- ─── TAB 8: Settings & Misc (9/9) ────────────────────────────
	-- Auto-start workers on boot if saved as enabled
	if autoTrickOrTreatEnabled then
		totGeneration += 1
		local curGen = totGeneration
		runWorker(function() return autoTrickOrTreatEnabled and curGen == totGeneration and sessionActive end, function()
			return runTrickOrTreatStep()
		end)
	end
	if autoHauntedHouseEnabled then
		hauntedGeneration += 1
		local curGen = hauntedGeneration
		runWorker(function() return autoHauntedHouseEnabled and curGen == hauntedGeneration and sessionActive end, function()
			return runHauntedHouseStep()
		end)
	end
	if autoRollPumpkinDiceEnabled then
		pumpkinDiceGeneration += 1
		local curGen = pumpkinDiceGeneration
		runWorker(function() return autoRollPumpkinDiceEnabled and curGen == pumpkinDiceGeneration and sessionActive end, function()
			return runPumpkinDiceStep()
		end)
	end
end)()

particle_generation = 0
active_particles_count = 0
clear_all_particles = nil

; (function()
	tab_settings.Header({ Title = T("tab_settings") .. " (9/9)" })
tab_settings.Header({ Title = T("header_lang") })

local langControls = tab_settings.Toggle({
	Title = T("header_lang"),
	Info = T("lang_info"),
	Default = LANG == "TH",
	Callback = function(isThai)
		local newLang = isThai and "TH" or "EN"
		if newLang ~= LANG then
			LANG = newLang
			saveSetting("AnimeDiceLanguage", newLang)
			refreshAllUIText(newLang)
			showNotification(
				T("header_lang"),
				newLang == "TH" and "เปลี่ยนภาษาเป็นไทยแล้ว!"
					or "Switched to English!"
			)
		end
	end,
})

langBtnInstance = langControls:Button({
	Title = T("lang_btn"),
	Text = LANG == "EN" and "Switch TH" or "Switch EN",
	Callback = function()
		local newLang = LANG == "EN" and "TH" or "EN"
		LANG = newLang
		saveSetting("AnimeDiceLanguage", newLang)
		langControls:Set(LANG == "TH")
		refreshAllUIText(newLang)
		showNotification(
			T("header_lang"),
			newLang == "TH" and "เปลี่ยนภาษาเป็นไทยแล้ว!"
				or "Switched to English!"
		)
	end,
})

tab_settings.Header({ Title = T("header_particle") })

local particle_enabled = getSavedValue("AnimeDiceParticleEnabled", true) == true
local particle_theme_setting = getSavedValue("AnimeDiceParticleTheme", "Auto (ตามปฏิทินจริง)")
local particle_generation = 0
local active_particles_count = 0
local clear_all_particles

local FESTIVALS = {
	{
		name = "NewYear",
		label = "ปีใหม่ (New Year)",
		check = function(m, d) return (m == 12 and d >= 31) or (m == 1 and d <= 5) end,
		color = Color3.fromRGB(255, 215, 0), secondaryColor = Color3.fromRGB(255, 80, 140),
		spawnRate = 0.18, size = {8, 14}, direction = "down", duration = {4, 7}, shape = "confetti", maxOnScreen = 20,
	},
	{
		name = "Valentine",
		label = "วาเลนไทน์ (Valentine)",
		check = function(m, d) return m == 2 and d >= 10 and d <= 16 end,
		color = Color3.fromRGB(255, 90, 120), secondaryColor = Color3.fromRGB(255, 150, 170),
		spawnRate = 0.5, size = {12, 18}, direction = "up", duration = {5, 8}, shape = "heart", maxOnScreen = 8,
	},
	{
		name = "Songkran",
		label = "สงกรานต์ (Songkran)",
		check = function(m, d) return m == 4 and d >= 12 and d <= 16 end,
		color = Color3.fromRGB(0, 210, 255), secondaryColor = Color3.fromRGB(60, 160, 255),
		spawnRate = 0.15, size = {7, 12}, direction = "down", duration = {3.5, 6}, shape = "drop", maxOnScreen = 22,
	},
	{
		name = "Halloween",
		label = "ฮาโลวีน (Halloween)",
		check = function(m, d) return m == 10 and d >= 24 and d <= 31 end,
		color = Color3.fromRGB(255, 140, 20), secondaryColor = Color3.fromRGB(255, 166, 64),
		spawnRate = 0.7, size = {16, 24}, direction = "down", duration = {4, 6.5}, shape = "pumpkin", maxOnScreen = 8,
	},
	{
		name = "LoyKrathong",
		label = "ลอยกระทง (Loy Krathong)",
		check = function(m, d) return m == 11 and d >= 10 and d <= 25 end,
		color = Color3.fromRGB(255, 196, 102), secondaryColor = Color3.fromRGB(255, 150, 60),
		spawnRate = 0.35, size = {6, 11}, direction = "up", duration = {6, 10}, shape = "glow", maxOnScreen = 16,
	},
	{
		name = "Christmas",
		label = "คริสต์มาส (Christmas)",
		check = function(m, d) return m == 12 and d >= 20 and d <= 30 end,
		color = Color3.fromRGB(255, 255, 255), secondaryColor = Color3.fromRGB(225, 240, 255),
		spawnRate = 0.12, size = {3, 7}, direction = "down", duration = {4, 7}, shape = "circle", maxOnScreen = 25,
	},
}

local SEASONS = {
	Summer = {
		name = "Summer",
		label = "ฤดูร้อน (Summer)",
		check = function(m, d) return m == 3 or m == 4 or (m == 5 and d <= 15) end,
		color = Color3.fromRGB(255, 200, 60), secondaryColor = Color3.fromRGB(255, 130, 30),
		spawnRate = 0.28, size = {5, 10}, direction = "up", duration = {5, 9}, shape = "glow", maxOnScreen = 16,
	},
	Rainy = {
		name = "Rainy",
		label = "ฤดูฝน (Rainy)",
		check = function(m, d) return (m == 5 and d > 15) or (m >= 6 and m <= 9) or (m == 10 and d <= 15) end,
		color = Color3.fromRGB(100, 200, 255), secondaryColor = Color3.fromRGB(160, 230, 255),
		spawnRate = 0.18, size = {6, 11}, direction = "down", duration = {3.5, 6}, shape = "drop", maxOnScreen = 20,
	},
	Autumn = {
		name = "Autumn",
		label = "ฤดูใบไม้ร่วง (Autumn)",
		check = function(m, d) return (m == 10 and d > 15) or m == 11 end,
		color = Color3.fromRGB(225, 115, 35), secondaryColor = Color3.fromRGB(210, 160, 40),
		spawnRate = 0.24, size = {9, 15}, direction = "down", duration = {4.5, 7.5}, shape = "leaf", maxOnScreen = 16,
	},
	Winter = {
		name = "Winter",
		label = "ฤดูหนาว (Winter)",
		check = function(m, d) return m == 12 or m == 1 end,
		color = Color3.fromRGB(240, 248, 255), secondaryColor = Color3.fromRGB(180, 220, 255),
		spawnRate = 0.15, size = {3, 6}, direction = "down", duration = {4, 7}, shape = "circle", maxOnScreen = 22,
	},
	Spring = {
		name = "Spring",
		label = "ฤดูใบไม้ผลิ (Spring)",
		check = function(m, d) return m == 2 end,
		color = Color3.fromRGB(255, 180, 210), secondaryColor = Color3.fromRGB(255, 140, 185),
		spawnRate = 0.22, size = {8, 14}, direction = "down", duration = {4.5, 7.5}, shape = "petal", maxOnScreen = 18,
	},
}

local themeOptionsList = {
	"Auto (ตามปฏิทินจริง)",
	"ปีใหม่ (New Year)",
	"วาเลนไทน์ (Valentine)",
	"สงกรานต์ (Songkran)",
	"ฮาโลวีน (Halloween)",
	"ลอยกระทง (Loy Krathong)",
	"คริสต์มาส (Christmas)",
	"ฤดูร้อน (Summer)",
	"ฤดูฝน (Rainy)",
	"ฤดูใบไม้ร่วง (Autumn)",
	"ฤดูหนาว (Winter)",
	"ฤดูใบไม้ผลิ (Spring)",
}

local function get_main_particles_layer()
	local CoreGui = game:GetService("CoreGui")
	for _, g in ipairs(CoreGui:GetChildren()) do
		if g:IsA("ScreenGui") and g:FindFirstChild("@main") then
			local main = g["@main"]
			local pLayer = main:FindFirstChild("@particles")
			if not pLayer then
				pLayer = Instance.new("Frame")
				pLayer.Name = "@particles"
				pLayer.BackgroundTransparency = 1
				pLayer.Size = UDim2.fromScale(1, 1)
				pLayer.ClipsDescendants = true
				pLayer.ZIndex = 1
				local c = Instance.new("UICorner", pLayer)
				c.CornerRadius = UDim.new(0, 10)
				pLayer.Parent = main
			end
			return pLayer
		end
	end
	local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui")
	if PlayerGui then
		for _, g in ipairs(PlayerGui:GetChildren()) do
			if g:IsA("ScreenGui") and g:FindFirstChild("@main") then
				local main = g["@main"]
				local pLayer = main:FindFirstChild("@particles")
				if not pLayer then
					pLayer = Instance.new("Frame")
					pLayer.Name = "@particles"
					pLayer.BackgroundTransparency = 1
					pLayer.Size = UDim2.fromScale(1, 1)
					pLayer.ClipsDescendants = true
					pLayer.ZIndex = 1
					local c = Instance.new("UICorner", pLayer)
					c.CornerRadius = UDim.new(0, 10)
					pLayer.Parent = main
				end
				return pLayer
			end
		end
	end
	return nil
end

clear_all_particles = function()
	particle_generation += 1
	active_particles_count = 0
	local pLayer = get_main_particles_layer()
	if pLayer then
		for _, ch in ipairs(pLayer:GetChildren()) do
			if ch:IsA("GuiObject") and ch.Name ~= "UICorner" then
				pcall(function() ch:Destroy() end)
			end
		end
	end
end

local function get_active_particle_theme()
	local sel = tostring(particle_theme_setting or "Auto")
	if sel:find("Auto") then
		local now = os.date("*t")
		local m, d = now.month, now.day
		for _, fest in ipairs(FESTIVALS) do
			if fest.check(m, d) then
				return fest
			end
		end
		for _, sea in pairs(SEASONS) do
			if sea.check(m, d) then
				return sea
			end
		end
		return SEASONS.Rainy
	end

	for _, fest in ipairs(FESTIVALS) do
		if sel == fest.label or sel:find(fest.name, 1, true) or fest.label:find(sel, 1, true) then
			return fest
		end
	end
	for _, sea in pairs(SEASONS) do
		if sel == sea.label or sel:find(sea.name, 1, true) or sea.label:find(sel, 1, true) then
			return sea
		end
	end
	return SEASONS.Rainy
end

local function buildParticleShape(shape, size, color)
	local container = Instance.new("Frame")
	container.BackgroundTransparency = 1
	container.BorderSizePixel = 0
	container.ZIndex = 1
	container.AnchorPoint = Vector2.new(0.5, 0.5)
	local parts = {}
	local function addPart(obj, prop)
		table.insert(parts, { object = obj, property = prop })
	end

	if shape == "drop" then
		local w = size * 0.8
		container.Size = UDim2.fromOffset(w, size * 1.3)
		local bulb = Instance.new("Frame", container)
		bulb.AnchorPoint = Vector2.new(0.5, 1)
		bulb.Position = UDim2.new(0.5, 0, 1, 0)
		bulb.Size = UDim2.fromOffset(w, w)
		bulb.BackgroundColor3 = color
		bulb.BorderSizePixel = 0
		bulb.ZIndex = 1
		Instance.new("UICorner", bulb).CornerRadius = UDim.new(1, 0)
		addPart(bulb, "BackgroundTransparency")

		local tip = Instance.new("Frame", container)
		tip.AnchorPoint = Vector2.new(0.5, 0.5)
		tip.Position = UDim2.new(0.5, 0, 0.32, 0)
		tip.Size = UDim2.fromOffset(w * 0.72, w * 0.72)
		tip.Rotation = 45
		tip.BackgroundColor3 = color
		tip.BorderSizePixel = 0
		tip.ZIndex = 1
		Instance.new("UICorner", tip).CornerRadius = UDim.new(0, 2)
		addPart(tip, "BackgroundTransparency")

	elseif shape == "glow" then
		container.Size = UDim2.fromOffset(size * 2.2, size * 2.2)
		local halo = Instance.new("Frame", container)
		halo.AnchorPoint = Vector2.new(0.5, 0.5)
		halo.Position = UDim2.fromScale(0.5, 0.5)
		halo.Size = UDim2.fromScale(1, 1)
		halo.BackgroundColor3 = color
		halo.BackgroundTransparency = 0.65
		halo.BorderSizePixel = 0
		halo.ZIndex = 1
		Instance.new("UICorner", halo).CornerRadius = UDim.new(1, 0)
		addPart(halo, "BackgroundTransparency")

		local core = Instance.new("Frame", container)
		core.AnchorPoint = Vector2.new(0.5, 0.5)
		core.Position = UDim2.fromScale(0.5, 0.5)
		core.Size = UDim2.fromOffset(size, size)
		core.BackgroundColor3 = Color3.fromRGB(255, 240, 210)
		core.BorderSizePixel = 0
		core.ZIndex = 1
		Instance.new("UICorner", core).CornerRadius = UDim.new(1, 0)
		addPart(core, "BackgroundTransparency")

	elseif shape == "confetti" then
		container.Size = UDim2.fromOffset(size * 1.4, size * 0.7)
		container.Rotation = math.random(0, 360)
		local rect = Instance.new("Frame", container)
		rect.Size = UDim2.fromScale(1, 1)
		rect.BackgroundColor3 = color
		rect.BorderSizePixel = 0
		rect.ZIndex = 1
		Instance.new("UICorner", rect).CornerRadius = UDim.new(0, 2)
		addPart(rect, "BackgroundTransparency")

	elseif shape == "heart" then
		container.Size = UDim2.fromOffset(size * 1.4, size * 1.4)
		local icon = Instance.new("ImageLabel", container)
		icon.BackgroundTransparency = 1
		icon.Size = UDim2.fromScale(1, 1)
		icon.Image = "rbxassetid://86573834471213"
		icon.ImageColor3 = color
		icon.ImageTransparency = 0.3
		icon.ScaleType = Enum.ScaleType.Fit
		icon.ZIndex = 1
		addPart(icon, "ImageTransparency")

	elseif shape == "pumpkin" then
		container.Size = UDim2.fromOffset(size * 1.6, size * 1.6)
		local icon = Instance.new("ImageLabel", container)
		icon.BackgroundTransparency = 1
		icon.Size = UDim2.fromScale(1, 1)
		icon.Image = "rbxassetid://110693415684859"
		icon.ImageColor3 = color
		icon.ImageTransparency = 0.35
		icon.ScaleType = Enum.ScaleType.Fit
		icon.ZIndex = 1
		addPart(icon, "ImageTransparency")

	elseif shape == "petal" then
		container.Size = UDim2.fromOffset(size * 1.3, size * 0.8)
		container.Rotation = math.random(0, 360)
		local petal = Instance.new("Frame", container)
		petal.Size = UDim2.fromScale(1, 1)
		petal.BackgroundColor3 = color
		petal.BorderSizePixel = 0
		petal.ZIndex = 1
		Instance.new("UICorner", petal).CornerRadius = UDim.new(0.6, 0)
		addPart(petal, "BackgroundTransparency")

	elseif shape == "leaf" then
		container.Size = UDim2.fromOffset(size * 1.4, size * 0.9)
		container.Rotation = math.random(0, 360)
		local leaf = Instance.new("Frame", container)
		leaf.Size = UDim2.fromScale(1, 1)
		leaf.BackgroundColor3 = color
		leaf.BorderSizePixel = 0
		leaf.ZIndex = 1
		Instance.new("UICorner", leaf).CornerRadius = UDim.new(0.5, 0)
		addPart(leaf, "BackgroundTransparency")

	else -- circle
		container.Size = UDim2.fromOffset(size, size)
		local dot = Instance.new("Frame", container)
		dot.Size = UDim2.fromScale(1, 1)
		dot.BackgroundColor3 = color
		dot.BorderSizePixel = 0
		dot.ZIndex = 1
		Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
		addPart(dot, "BackgroundTransparency")
	end

	return container, parts
end

-- Particle Background Animation Loop
task.spawn(function()
	local mySession = CURRENT_SESSION_ID
	while _G.AnimeDice_Session == mySession do
		task.wait(0.18)
		if _G.AnimeDice_Session ~= mySession then break end
		if particle_enabled then
			local pLayer = get_main_particles_layer()
			if pLayer and pLayer.Parent and pLayer.Parent.Visible then
				local theme = get_active_particle_theme()
				local maxOnScreen = theme.maxOnScreen or 20
				if active_particles_count < maxOnScreen then
					active_particles_count += 1
					local thisGen = particle_generation
					task.spawn(function()
						if _G.AnimeDice_Session ~= mySession or particle_generation ~= thisGen then
							active_particles_count = math.max(0, active_particles_count - 1)
							return
						end
						local size = math.random(theme.size[1], theme.size[2])
						local color = math.random() > 0.5 and theme.color or theme.secondaryColor
						local particle, parts = buildParticleShape(theme.shape, size, color)
						if not particle then
							active_particles_count = math.max(0, active_particles_count - 1)
							return
						end
						particle.Parent = pLayer

						local goingUp = theme.direction == "up"
						local half = particle.Size.Y.Offset / 2
						local halfX = particle.Size.X.Offset / 2
						local layerWidth = math.max(pLayer.AbsoluteSize.X, 1)
						local insetScaleX = math.clamp(halfX / layerWidth, 0, 0.5)
						local minX, maxX = insetScaleX, 1 - insetScaleX
						local startX = minX + math.random() * (maxX - minX)
						local startEdge = goingUp and 1 or 0
						local endEdge = goingUp and 0 or 1
						local startOffset = goingUp and -half or half
						local endOffset = goingUp and half or -half
						particle.Position = UDim2.new(startX, 0, startEdge, startOffset)

						local duration = theme.duration[1] + math.random() * (theme.duration[2] - theme.duration[1])
						local drift = math.random(-180, 180) / 1000

						local moveTween = TweenService:Create(particle, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
							Position = UDim2.new(math.clamp(startX + drift, minX, maxX), 0, endEdge, endOffset)
						})
						moveTween:Play()

						local fadeIn = math.min(duration * 0.25, 0.35)
						local fadeOut = math.min(duration * 0.25, 0.35)
						for _, part in ipairs(parts) do
							part.object[part.property] = 1
							TweenService:Create(part.object, TweenInfo.new(fadeIn, Enum.EasingStyle.Linear), {
								[part.property] = (part.property == "ImageTransparency" and 0.3 or 0)
							}):Play()
						end

						task.delay(math.max(duration - fadeOut, fadeIn), function()
							if particle_generation == thisGen and _G.AnimeDice_Session == mySession then
								for _, part in ipairs(parts) do
									if part.object and part.object.Parent then
										TweenService:Create(part.object, TweenInfo.new(fadeOut, Enum.EasingStyle.Linear), {
											[part.property] = 1
										}):Play()
									end
								end
							end
						end)

						if theme.shape == "confetti" or theme.shape == "drop" then
							TweenService:Create(particle, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
								Rotation = particle.Rotation + math.random(180, 540) * (goingUp and -1 or 1)
							}):Play()
						elseif theme.shape == "pumpkin" then
							TweenService:Create(particle, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
								Rotation = math.random(-25, 25)
							}):Play()
						elseif theme.shape == "petal" or theme.shape == "leaf" then
							TweenService:Create(particle, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
								Rotation = particle.Rotation + math.random(90, 360)
							}):Play()
						end

						task.delay(duration + 0.1, function()
							active_particles_count = math.max(0, active_particles_count - 1)
							pcall(function() particle:Destroy() end)
						end)
					end)
				end
				task.wait(theme.spawnRate or 0.2)
			end
		end
	end
end)

local particleControls = tab_settings.Toggle({
	Title = T("particle_tog"),
	Info = T("particle_inf"),
	Default = particle_enabled,
	Callback = function(enabled)
		saveSetting("AnimeDiceParticleEnabled", enabled)
		particle_enabled = enabled
		if not enabled then
			clear_all_particles()
		end
	end,
})

particleControls:Dropdown({
	Title = T("particle_drop"),
	List = themeOptionsList,
	Default = particle_theme_setting,
	Callback = function(theme)
		particle_theme_setting = tostring(theme)
		saveSetting("AnimeDiceParticleTheme", particle_theme_setting)
		clear_all_particles()
	end,
})

tab_settings.Header({ Title = T("header_misc") })

do
	local antiAfkGeneration = 0
	local controls = tab_settings.Toggle({
		Title = T("anti_afk_tog"),
		Info = T("anti_afk_inf"),
		Default = antiAfkEnabled,
		Callback = function(enabled)
			saveSetting("AnimeDiceAntiAfk", enabled)
			antiAfkEnabled = enabled
			antiAfkGeneration += 1
			local generation = antiAfkGeneration
			if enabled then
				runWorker(function()
					return antiAfkEnabled and generation == antiAfkGeneration
				end, function()
					simulateActivity()
					return 60
				end)
			end
		end,
	})
	controls:Label("Sends mouse move every 60s & when idle.")
end
end)()

-- ─── Script Title, Credit & Navigation (PagePrev / PageNext) ──
task.spawn(function()
	task.wait(0.35)
	pcall(function()
		local function decorateMain(main)
			if not main then return end

			-- 1. Script Title Label
			local tLbl = main:FindFirstChild("ScriptTitleLabel")
			if not tLbl then
				tLbl = Instance.new("TextLabel")
				tLbl.Name = "ScriptTitleLabel"
				tLbl.Size = UDim2.new(1, -70, 0, 18)
				tLbl.Position = UDim2.new(0, 16, 0, 4)
				tLbl.BackgroundTransparency = 1
				tLbl.Text = "PAYOMBØYZ อนิเมะเต๋าไปกับพยอมบอย"
				tLbl.TextColor3 = Color3.fromRGB(255, 35, 55)
				tLbl.Font = Enum.Font.GothamBlack
				tLbl.TextSize = 12
				tLbl.TextXAlignment = Enum.TextXAlignment.Left
				tLbl.ZIndex = 50
				tLbl.Parent = main
			else
				tLbl.Text = "PAYOMBØYZ อนิเมะเต๋าไปกับพยอมบอย"
			end

			-- 2. Script SubTitle
			local subLbl = main:FindFirstChild("ScriptSubTitleLabel")
			if not subLbl then
				subLbl = Instance.new("TextLabel")
				subLbl.Name = "ScriptSubTitleLabel"
				subLbl.Size = UDim2.new(1, -70, 0, 14)
				subLbl.Position = UDim2.new(0, 16, 0, 21)
				subLbl.BackgroundTransparency = 1
				subLbl.Text = "Edited By Ayaya & ANON (Kai Tan Edition)"
				subLbl.TextColor3 = Color3.fromRGB(0, 210, 255)
				subLbl.Font = Enum.Font.GothamBold
				subLbl.TextSize = 10
				subLbl.TextXAlignment = Enum.TextXAlignment.Left
				subLbl.ZIndex = 50
				subLbl.Parent = main
			else
				subLbl.Text = "Edited By Ayaya & ANON (Kai Tan Edition)"
			end

			-- 3. Bottom Credit Label
			local cLbl = main:FindFirstChild("CreditLabel")
			if not cLbl then
				cLbl = Instance.new("TextLabel")
				cLbl.Name = "CreditLabel"
				cLbl.Size = UDim2.new(0, 180, 0, 18)
				cLbl.Position = UDim2.new(1, -34, 1, -22)
				cLbl.BackgroundTransparency = 1
				cLbl.Text = T("window_collapse")
				cLbl.TextColor3 = Color3.fromRGB(155, 165, 185)
				cLbl.Font = Enum.Font.GothamMedium
				cLbl.TextSize = 11
				cLbl.TextXAlignment = Enum.TextXAlignment.Right
				cLbl.ZIndex = 50
				cLbl.Parent = main
			else
				cLbl.Text = T("window_collapse")
			end

			-- 4. Top Navigation Left Button (◀)
			local prevBtn = main:FindFirstChild("PagePrevBtn")
			if not prevBtn then
				prevBtn = Instance.new("TextButton")
				prevBtn.Name = "PagePrevBtn"
				prevBtn.Size = UDim2.new(0, 26, 0, 20)
				prevBtn.Position = UDim2.new(1, -66, 0, 8)
				prevBtn.BackgroundColor3 = Color3.fromRGB(22, 28, 44)
				prevBtn.BorderSizePixel = 0
				prevBtn.Text = "◀"
				prevBtn.TextColor3 = Color3.fromRGB(255, 35, 55)
				prevBtn.Font = Enum.Font.GothamBold
				prevBtn.TextSize = 11
				prevBtn.ZIndex = 60
				prevBtn.Parent = main
				local c = Instance.new("UICorner", prevBtn)
				c.CornerRadius = UDim.new(0, 6)
				prevBtn.MouseButton1Click:Connect(function()
					pcall(function()
						local page = main:FindFirstChild("@page")
						local uipage = page and page:FindFirstChildWhichIsA("UIPageLayout")
						if uipage then uipage:Previous() end
					end)
				end)
			end

			-- 5. Top Navigation Right Button (▶)
			local nextBtn = main:FindFirstChild("PageNextBtn")
			if not nextBtn then
				nextBtn = Instance.new("TextButton")
				nextBtn.Name = "PageNextBtn"
				nextBtn.Size = UDim2.new(0, 26, 0, 20)
				nextBtn.Position = UDim2.new(1, -34, 0, 8)
				nextBtn.BackgroundColor3 = Color3.fromRGB(22, 28, 44)
				nextBtn.BorderSizePixel = 0
				nextBtn.Text = "▶"
				nextBtn.TextColor3 = Color3.fromRGB(255, 35, 55)
				nextBtn.Font = Enum.Font.GothamBold
				nextBtn.TextSize = 11
				nextBtn.ZIndex = 60
				nextBtn.Parent = main
				local c = Instance.new("UICorner", nextBtn)
				c.CornerRadius = UDim.new(0, 6)
				nextBtn.MouseButton1Click:Connect(function()
					pcall(function()
						local page = main:FindFirstChild("@page")
						local uipage = page and page:FindFirstChildWhichIsA("UIPageLayout")
						if uipage then uipage:Next() end
					end)
				end)
			end

			-- ScrollingFrame automatic sizing
			pcall(function()
				local page = main:FindFirstChild("@page")
				if page then
					for _, sc in ipairs(page:GetChildren()) do
						if sc:IsA("ScrollingFrame") then
							sc.CanvasSize = UDim2.new(0, 0, 0, 0)
							sc.AutomaticCanvasSize = Enum.AutomaticSize.Y
							sc.ScrollBarThickness = 2
							sc.ScrollBarImageColor3 = Color3.fromRGB(255, 35, 55)
							sc.ClipsDescendants = true
						end
					end
				end
				main.ClipsDescendants = true
			end)

			-- Ensure @particles container
			local pLayer = main:FindFirstChild("@particles")
			if not pLayer then
				pLayer = Instance.new("Frame")
				pLayer.Name = "@particles"
				pLayer.BackgroundTransparency = 1
				pLayer.Size = UDim2.fromScale(1, 1)
				pLayer.ClipsDescendants = true
				pLayer.ZIndex = 1
				local c = Instance.new("UICorner", pLayer)
				c.CornerRadius = UDim.new(0, 10)
				pLayer.Parent = main
			end
		end

		local CoreGui = game:GetService("CoreGui")
		for _, gui in ipairs(CoreGui:GetChildren()) do
			if gui:IsA("ScreenGui") and gui:FindFirstChild("@main") then
				decorateMain(gui["@main"])
			end
		end
		local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui")
		if PlayerGui then
			for _, gui in ipairs(PlayerGui:GetChildren()) do
				if gui:IsA("ScreenGui") and gui:FindFirstChild("@main") then
					decorateMain(gui["@main"])
				end
			end
		end
	end)
end)

-- ─── Floating HUD Button (Avatar, DisplayName, FPS, Ping) ────
local HudGui
local StatsLabel
local isMobile = UserInputService.TouchEnabled and not UserInputService.MouseEnabled

; (function()
	HudGui = Instance.new("ScreenGui")
	HudGui.Name           = "AnimeDiceHUD"
	HudGui.ResetOnSpawn   = false
	HudGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	HudGui.DisplayOrder   = 999
	pcall(function() HudGui.Parent = game:GetService("CoreGui") end)
	if not HudGui.Parent then
		HudGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
	end

	-- Pill container
	local HudFrame = Instance.new("Frame")
	HudFrame.Name                  = "HudFrame"
	HudFrame.Size                  = UDim2.new(0, 195, 0, 54)
	HudFrame.Position              = isMobile
		and UDim2.new(0, 10, 0, 70)
		or  UDim2.new(0, 10, 0.5, -27)
	HudFrame.BackgroundColor3      = Color3.fromRGB(8, 11, 20)
	HudFrame.BackgroundTransparency = 0.12
	HudFrame.BorderSizePixel        = 0
	HudFrame.Active                 = true
	HudFrame.Parent                 = HudGui
	Instance.new("UICorner", HudFrame).CornerRadius = UDim.new(1, 0)

	local hudStroke = Instance.new("UIStroke")
	hudStroke.Color        = Color3.fromRGB(255, 35, 55)
	hudStroke.Thickness    = 1.5
	hudStroke.Transparency = 0.20
	hudStroke.Parent       = HudFrame

	-- Avatar Thumbnail
	local AvatarImg = Instance.new("ImageLabel")
	AvatarImg.Name               = "Avatar"
	AvatarImg.Size               = UDim2.new(0, 40, 0, 40)
	AvatarImg.Position           = UDim2.new(0, 7, 0.5, -20)
	AvatarImg.BackgroundColor3   = Color3.fromRGB(18, 22, 34)
	AvatarImg.BorderSizePixel    = 0
	AvatarImg.ScaleType          = Enum.ScaleType.Fit
	AvatarImg.Parent             = HudFrame
	Instance.new("UICorner", AvatarImg).CornerRadius = UDim.new(1, 0)

	pcall(function()
		AvatarImg.Image = Players:GetUserThumbnailAsync(
			LocalPlayer.UserId,
			Enum.ThumbnailType.HeadShot,
			Enum.ThumbnailSize.Size48x48
		)
	end)

	local avatarStroke = Instance.new("UIStroke")
	avatarStroke.Color        = Color3.fromRGB(255, 35, 55)
	avatarStroke.Thickness    = 1.5
	avatarStroke.Transparency = 0.15
	avatarStroke.Parent       = AvatarImg

	-- Username Display
	local UserLabel = Instance.new("TextLabel")
	UserLabel.Name               = "UserName"
	UserLabel.Size               = UDim2.new(1, -57, 0, 19)
	UserLabel.Position           = UDim2.new(0, 53, 0, 7)
	UserLabel.BackgroundTransparency = 1
	UserLabel.Text               = LocalPlayer.DisplayName
	UserLabel.TextColor3         = Color3.fromRGB(240, 250, 255)
	UserLabel.TextSize           = 13
	UserLabel.Font               = Enum.Font.GothamBold
	UserLabel.TextXAlignment     = Enum.TextXAlignment.Left
	UserLabel.TextTruncate       = Enum.TextTruncate.AtEnd
	UserLabel.Parent             = HudFrame

	-- FPS / Ping Stats Label
	StatsLabel = Instance.new("TextLabel")
	StatsLabel.Name               = "Stats"
	StatsLabel.Size               = UDim2.new(1, -57, 0, 16)
	StatsLabel.Position           = UDim2.new(0, 53, 0, 28)
	StatsLabel.BackgroundTransparency = 1
	StatsLabel.Text               = T("hud_fps") .. ": -- | " .. T("hud_ping") .. ": --"
	StatsLabel.TextColor3         = Color3.fromRGB(255, 45, 65)
	StatsLabel.TextSize           = 11
	StatsLabel.Font               = Enum.Font.GothamMedium
	StatsLabel.TextXAlignment     = Enum.TextXAlignment.Left
	StatsLabel.Parent             = HudFrame

	-- Invisible Click Area
	local HudBtn = Instance.new("TextButton")
	HudBtn.Size                   = UDim2.new(1, 0, 1, 0)
	HudBtn.BackgroundTransparency = 1
	HudBtn.Text                   = ""
	HudBtn.Parent                 = HudFrame

	-- Dragging Logic
	do
		local dragging, dragStart, startPos, dragInput
		HudBtn.InputBegan:Connect(function(inp)
			if inp.UserInputType == Enum.UserInputType.MouseButton1
			or inp.UserInputType == Enum.UserInputType.Touch then
				dragging  = true
				dragStart = inp.Position
				startPos  = HudFrame.Position
				inp.Changed:Connect(function()
					if inp.UserInputState == Enum.UserInputState.End then
						dragging = false
					end
				end)
			end
		end)
		HudBtn.InputChanged:Connect(function(inp)
			if inp.UserInputType == Enum.UserInputType.MouseMovement
			or inp.UserInputType == Enum.UserInputType.Touch then
				dragInput = inp
			end
		end)
		UserInputService.InputChanged:Connect(function(inp)
			if inp == dragInput and dragging then
				local delta = inp.Position - dragStart
				HudFrame.Position = UDim2.new(
					startPos.X.Scale, startPos.X.Offset + delta.X,
					startPos.Y.Scale, startPos.Y.Offset + delta.Y
				)
			end
		end)
	end

	-- Window Toggle Function
	local ui_visible = true
	local function toggle_script_window()
		ui_visible = not ui_visible
		pcall(function()
			local CoreGui = game:GetService("CoreGui")
			for _, g in ipairs(CoreGui:GetChildren()) do
				if g:IsA("ScreenGui") and g:FindFirstChild("@main") then
					g.Enabled = ui_visible
					g["@main"].Visible = ui_visible
				end
			end
			local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui")
			if PlayerGui then
				for _, g in ipairs(PlayerGui:GetChildren()) do
					if g:IsA("ScreenGui") and g:FindFirstChild("@main") then
						g.Enabled = ui_visible
						g["@main"].Visible = ui_visible
					end
				end
			end
		end)

		TweenService:Create(hudStroke, TweenInfo.new(0.2), {
			Color = ui_visible and Color3.fromRGB(0, 210, 255) or Color3.fromRGB(255, 75, 100)
		}):Play()
	end

	HudBtn.MouseButton1Click:Connect(toggle_script_window)

	UserInputService.InputBegan:Connect(function(inp, processed)
		if not processed and (inp.KeyCode == Enum.KeyCode.RightControl or inp.KeyCode == Enum.KeyCode.Insert) then
			toggle_script_window()
		end
	end)
end)()

-- ════════════════════════════════════════════════════════════════
-- TOP-RIGHT AUTONOMOUS TELEMETRY MONITORING DASHBOARD
-- ════════════════════════════════════════════════════════════════
local TelemetryHUD = {}

local function buildTelemetryHUD()
	local parentGui = game:GetService("CoreGui")
	if not pcall(function() return parentGui.Name end) then
		parentGui = LocalPlayer:FindFirstChildOfClass("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui")
	end

	if parentGui:FindFirstChild("AnimeDice_TelemetryHUD") then
		pcall(function() parentGui.AnimeDice_TelemetryHUD:Destroy() end)
	end

	local TelemetryGui = Instance.new("ScreenGui")
	TelemetryGui.Name = "AnimeDice_TelemetryHUD"
	TelemetryGui.ResetOnSpawn = false
	TelemetryGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	TelemetryGui.DisplayOrder = 998
	TelemetryGui.Parent = parentGui
	TelemetryHUD.Gui = TelemetryGui

	local isCollapsed = false
	local EXPANDED_HEIGHT = 304
	local COLLAPSED_HEIGHT = 30

	local TelemetryFrame = Instance.new("Frame")
	TelemetryFrame.Name = "TelemetryFrame"
	TelemetryFrame.Size = UDim2.new(0, 350, 0, EXPANDED_HEIGHT)
	TelemetryFrame.Position = isMobile
		and UDim2.new(1, -360, 0, 70)
		or UDim2.new(1, -360, 0, 15)
	TelemetryFrame.BackgroundColor3 = Color3.fromRGB(14, 8, 12)
	TelemetryFrame.BackgroundTransparency = 0.08
	TelemetryFrame.BorderSizePixel = 0
	TelemetryFrame.Active = true
	TelemetryFrame.ClipsDescendants = true
	TelemetryFrame.Parent = TelemetryGui
	TelemetryHUD.Frame = TelemetryFrame

	local hudCorner = Instance.new("UICorner")
	hudCorner.CornerRadius = UDim.new(0, 10)
	hudCorner.Parent = TelemetryFrame

	local hudStroke = Instance.new("UIStroke")
	hudStroke.Color = Color3.fromRGB(255, 45, 75)
	hudStroke.Thickness = 1.6
	hudStroke.Transparency = 0.20
	hudStroke.Parent = TelemetryFrame

	-- Header Bar
	local headerFrame = Instance.new("Frame")
	headerFrame.Name = "Header"
	headerFrame.Size = UDim2.new(1, 0, 0, 30)
	headerFrame.BackgroundColor3 = Color3.fromRGB(32, 12, 18)
	headerFrame.BackgroundTransparency = 0.15
	headerFrame.BorderSizePixel = 0
	headerFrame.Parent = TelemetryFrame

	local headerCorner = Instance.new("UICorner")
	headerCorner.CornerRadius = UDim.new(0, 10)
	headerCorner.Parent = headerFrame

	local headerTitle = Instance.new("TextLabel")
	headerTitle.Size = UDim2.new(1, -95, 1, 0)
	headerTitle.Position = UDim2.new(0, 10, 0, 0)
	headerTitle.BackgroundTransparency = 1
	headerTitle.Text = "⚡ ANIME DICE MONITOR"
	headerTitle.TextColor3 = Color3.fromRGB(255, 55, 80)
	headerTitle.Font = Enum.Font.GothamBold
	headerTitle.TextSize = 13
	headerTitle.TextXAlignment = Enum.TextXAlignment.Left
	headerTitle.Parent = headerFrame

	-- Live Status Indicator Badge
	local liveBadge = Instance.new("TextLabel")
	liveBadge.Size = UDim2.new(0, 48, 0, 19)
	liveBadge.Position = UDim2.new(1, -78, 0, 5)
	liveBadge.BackgroundColor3 = Color3.fromRGB(46, 224, 140)
	liveBadge.BackgroundTransparency = 0.8
	liveBadge.Text = "● LIVE"
	liveBadge.TextColor3 = Color3.fromRGB(46, 224, 140)
	liveBadge.Font = Enum.Font.GothamBold
	liveBadge.TextSize = 10.5
	liveBadge.Parent = headerFrame

	local lbCorner = Instance.new("UICorner")
	lbCorner.CornerRadius = UDim.new(0, 4)
	lbCorner.Parent = liveBadge

	-- Minimize / Maximize Button
	local minBtn = Instance.new("TextButton")
	minBtn.Size = UDim2.new(0, 24, 0, 22)
	minBtn.Position = UDim2.new(1, -28, 0, 4)
	minBtn.BackgroundTransparency = 1
	minBtn.Text = "—"
	minBtn.TextColor3 = Color3.fromRGB(255, 215, 225)
	minBtn.Font = Enum.Font.GothamBold
	minBtn.TextSize = 14
	minBtn.Parent = headerFrame

	-- Body Content Frame
	local bodyFrame = Instance.new("Frame")
	bodyFrame.Name = "Body"
	bodyFrame.Size = UDim2.new(1, -14, 1, -36)
	bodyFrame.Position = UDim2.new(0, 7, 0, 32)
	bodyFrame.BackgroundTransparency = 1
	bodyFrame.Parent = TelemetryFrame

	-- Minimize Toggle Logic
	minBtn.MouseButton1Click:Connect(function()
		isCollapsed = not isCollapsed
		minBtn.Text = isCollapsed and "+" or "—"
		bodyFrame.Visible = not isCollapsed
		TweenService:Create(TelemetryFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = UDim2.new(0, 350, 0, isCollapsed and COLLAPSED_HEIGHT or EXPANDED_HEIGHT)
		}):Play()
	end)

	-- Draggable Header Logic
	local dragging, dragStart, startPos, dragInput
	headerFrame.InputBegan:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = inp.Position
			startPos = TelemetryFrame.Position
			inp.Changed:Connect(function()
				if inp.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)
	headerFrame.InputChanged:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch then
			dragInput = inp
		end
	end)
	UserInputService.InputChanged:Connect(function(inp)
		if inp == dragInput and dragging then
			local delta = inp.Position - dragStart
			TelemetryFrame.Position = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + delta.X,
				startPos.Y.Scale, startPos.Y.Offset + delta.Y
			)
		end
	end)

	-- Card 1: Kai Tan Automation State Badge
	local hudStatusBadge = Instance.new("TextLabel")
	hudStatusBadge.Size = UDim2.new(1, 0, 0, 24)
	hudStatusBadge.Position = UDim2.new(0, 0, 0, 0)
	hudStatusBadge.BackgroundColor3 = Color3.fromRGB(36, 14, 22)
	hudStatusBadge.BackgroundTransparency = 0.25
	hudStatusBadge.Text = "🌾 สถานะ: กำลังเริ่มต้นระบบ..."
	hudStatusBadge.TextColor3 = Color3.fromRGB(255, 205, 75)
	hudStatusBadge.Font = Enum.Font.GothamBold
	hudStatusBadge.TextSize = 12
	hudStatusBadge.Parent = bodyFrame
	Instance.new("UICorner", hudStatusBadge).CornerRadius = UDim.new(0, 6)
	TelemetryHUD.StatusBadge = hudStatusBadge

	-- Card 2: Dice & Target Progression Box
	local diceBox = Instance.new("Frame")
	diceBox.Size = UDim2.new(1, 0, 0, 58)
	diceBox.Position = UDim2.new(0, 0, 0, 28)
	diceBox.BackgroundColor3 = Color3.fromRGB(24, 12, 18)
	diceBox.BackgroundTransparency = 0.25
	diceBox.BorderSizePixel = 0
	diceBox.Parent = bodyFrame
	Instance.new("UICorner", diceBox).CornerRadius = UDim.new(0, 6)

	local hudDiceText = Instance.new("TextLabel")
	hudDiceText.Size = UDim2.new(1, -10, 0, 18)
	hudDiceText.Position = UDim2.new(0, 6, 0, 2)
	hudDiceText.BackgroundTransparency = 1
	hudDiceText.Text = "🎲 เต๋า: -  ➔  🎯 เป้าหมาย: -"
	hudDiceText.TextColor3 = Color3.fromRGB(255, 245, 245)
	hudDiceText.Font = Enum.Font.GothamBold
	hudDiceText.TextSize = 11.5
	hudDiceText.TextXAlignment = Enum.TextXAlignment.Left
	hudDiceText.Parent = diceBox
	TelemetryHUD.DiceText = hudDiceText

	local hudDiceBarBg = Instance.new("Frame")
	hudDiceBarBg.Size = UDim2.new(1, -12, 0, 16)
	hudDiceBarBg.Position = UDim2.new(0, 6, 0, 22)
	hudDiceBarBg.BackgroundColor3 = Color3.fromRGB(12, 6, 9)
	hudDiceBarBg.BorderSizePixel = 0
	hudDiceBarBg.Parent = diceBox
	Instance.new("UICorner", hudDiceBarBg).CornerRadius = UDim.new(0, 4)

	local hudDiceBarFill = Instance.new("Frame")
	hudDiceBarFill.Size = UDim2.new(0, 0, 1, 0)
	hudDiceBarFill.BackgroundColor3 = Color3.fromRGB(255, 45, 75)
	hudDiceBarFill.BorderSizePixel = 0
	hudDiceBarFill.Parent = hudDiceBarBg
	Instance.new("UICorner", hudDiceBarFill).CornerRadius = UDim.new(0, 4)
	TelemetryHUD.DiceBarFill = hudDiceBarFill

	local hudDiceBarText = Instance.new("TextLabel")
	hudDiceBarText.Size = UDim2.fromScale(1, 1)
	hudDiceBarText.BackgroundTransparency = 1
	hudDiceBarText.Text = "$0 / $0 (0%)"
	hudDiceBarText.TextColor3 = Color3.fromRGB(255, 255, 255)
	hudDiceBarText.Font = Enum.Font.GothamBold
	hudDiceBarText.TextSize = 10.5
	hudDiceBarText.ZIndex = 3
	hudDiceBarText.Parent = hudDiceBarBg
	TelemetryHUD.DiceBarText = hudDiceBarText

	local hudDiceSubText = Instance.new("TextLabel")
	hudDiceSubText.Size = UDim2.new(1, -10, 0, 16)
	hudDiceSubText.Position = UDim2.new(0, 6, 0, 40)
	hudDiceSubText.BackgroundTransparency = 1
	hudDiceSubText.Text = "💰 ขาดอีก: - | โชคเต๋า: -"
	hudDiceSubText.TextColor3 = Color3.fromRGB(220, 180, 190)
	hudDiceSubText.Font = Enum.Font.Gotham
	hudDiceSubText.TextSize = 10.5
	hudDiceSubText.TextXAlignment = Enum.TextXAlignment.Left
	hudDiceSubText.Parent = diceBox
	TelemetryHUD.DiceSubText = hudDiceSubText

	-- Card 3: Skill Tree & Rebirth Box
	local treeBox = Instance.new("Frame")
	treeBox.Size = UDim2.new(1, 0, 0, 46)
	treeBox.Position = UDim2.new(0, 0, 0, 90)
	treeBox.BackgroundColor3 = Color3.fromRGB(24, 12, 18)
	treeBox.BackgroundTransparency = 0.25
	treeBox.BorderSizePixel = 0
	treeBox.Parent = bodyFrame
	Instance.new("UICorner", treeBox).CornerRadius = UDim.new(0, 6)

	local hudTreeText = Instance.new("TextLabel")
	hudTreeText.Size = UDim2.new(1, -10, 0, 18)
	hudTreeText.Position = UDim2.new(0, 6, 0, 2)
	hudTreeText.BackgroundTransparency = 1
	hudTreeText.Text = "🌳 ต้นไม้: 0/86 (0%)  |  🔄 Rebirth: 0/13"
	hudTreeText.TextColor3 = Color3.fromRGB(255, 245, 245)
	hudTreeText.Font = Enum.Font.GothamBold
	hudTreeText.TextSize = 11.5
	hudTreeText.TextXAlignment = Enum.TextXAlignment.Left
	hudTreeText.Parent = treeBox
	TelemetryHUD.TreeText = hudTreeText

	local hudTreeBarBg = Instance.new("Frame")
	hudTreeBarBg.Size = UDim2.new(1, -12, 0, 16)
	hudTreeBarBg.Position = UDim2.new(0, 6, 0, 23)
	hudTreeBarBg.BackgroundColor3 = Color3.fromRGB(12, 6, 9)
	hudTreeBarBg.BorderSizePixel = 0
	hudTreeBarBg.Parent = treeBox
	Instance.new("UICorner", hudTreeBarBg).CornerRadius = UDim.new(0, 4)

	local hudTreeBarFill = Instance.new("Frame")
	hudTreeBarFill.Size = UDim2.new(0, 0, 1, 0)
	hudTreeBarFill.BackgroundColor3 = Color3.fromRGB(46, 224, 140)
	hudTreeBarFill.BorderSizePixel = 0
	hudTreeBarFill.Parent = hudTreeBarBg
	Instance.new("UICorner", hudTreeBarFill).CornerRadius = UDim.new(0, 4)
	TelemetryHUD.TreeBarFill = hudTreeBarFill

	local hudTreeBarText = Instance.new("TextLabel")
	hudTreeBarText.Size = UDim2.fromScale(1, 1)
	hudTreeBarText.BackgroundTransparency = 1
	hudTreeBarText.Text = "0 / 86 Upgrades (0%)"
	hudTreeBarText.TextColor3 = Color3.fromRGB(255, 255, 255)
	hudTreeBarText.Font = Enum.Font.GothamBold
	hudTreeBarText.TextSize = 10.5
	hudTreeBarText.ZIndex = 3
	hudTreeBarText.Parent = hudTreeBarBg
	TelemetryHUD.TreeBarText = hudTreeBarText

	-- Card 4: Plot & Inventory Box
	local plotBox = Instance.new("Frame")
	plotBox.Size = UDim2.new(1, 0, 0, 48)
	plotBox.Position = UDim2.new(0, 0, 0, 140)
	plotBox.BackgroundColor3 = Color3.fromRGB(24, 12, 18)
	plotBox.BackgroundTransparency = 0.25
	plotBox.BorderSizePixel = 0
	plotBox.Parent = bodyFrame
	Instance.new("UICorner", plotBox).CornerRadius = UDim.new(0, 6)

	local hudPlotText = Instance.new("TextLabel")
	hudPlotText.Size = UDim2.new(1, -10, 0, 18)
	hudPlotText.Position = UDim2.new(0, 6, 0, 3)
	hudPlotText.BackgroundTransparency = 1
	hudPlotText.Text = "⚔️ ยูนิตบนแปลง: -  |  💰 เงินบนแปลง: -"
	hudPlotText.TextColor3 = Color3.fromRGB(255, 245, 245)
	hudPlotText.Font = Enum.Font.GothamBold
	hudPlotText.TextSize = 11
	hudPlotText.TextXAlignment = Enum.TextXAlignment.Left
	hudPlotText.Parent = plotBox
	TelemetryHUD.PlotText = hudPlotText

	local hudInvText = Instance.new("TextLabel")
	hudInvText.Size = UDim2.new(1, -10, 0, 18)
	hudInvText.Position = UDim2.new(0, 6, 0, 24)
	hudInvText.BackgroundTransparency = 1
	hudInvText.Text = "🎒 กระเป๋า: -  |  🎲 สุ่มแล้ว: -"
	hudInvText.TextColor3 = Color3.fromRGB(225, 195, 205)
	hudInvText.Font = Enum.Font.Gotham
	hudInvText.TextSize = 11
	hudInvText.TextXAlignment = Enum.TextXAlignment.Left
	hudInvText.Parent = plotBox
	TelemetryHUD.InvText = hudInvText

	-- Card 5: Real-Time Telemetry & Live Activity Log Box
	local diagBox = Instance.new("Frame")
	diagBox.Size = UDim2.new(1, 0, 0, 74)
	diagBox.Position = UDim2.new(0, 0, 0, 192)
	diagBox.BackgroundColor3 = Color3.fromRGB(20, 10, 15)
	diagBox.BackgroundTransparency = 0.25
	diagBox.BorderSizePixel = 0
	diagBox.Parent = bodyFrame
	Instance.new("UICorner", diagBox).CornerRadius = UDim.new(0, 6)

	local hudPerfText = Instance.new("TextLabel")
	hudPerfText.Size = UDim2.new(1, -10, 0, 18)
	hudPerfText.Position = UDim2.new(0, 6, 0, 3)
	hudPerfText.BackgroundTransparency = 1
	hudPerfText.Text = "⚡ FPS: --  |  📶 Ping: -- ms  |  ⏱️ Uptime: 00:00:00"
	hudPerfText.TextColor3 = Color3.fromRGB(255, 75, 100)
	hudPerfText.Font = Enum.Font.GothamBold
	hudPerfText.TextSize = 11
	hudPerfText.TextXAlignment = Enum.TextXAlignment.Left
	hudPerfText.Parent = diagBox
	TelemetryHUD.PerfText = hudPerfText

	local hudLogText = Instance.new("TextLabel")
	hudLogText.Size = UDim2.new(1, -10, 0, 48)
	hudLogText.Position = UDim2.new(0, 6, 0, 22)
	hudLogText.BackgroundTransparency = 1
	hudLogText.Text = "📜 บันทึก: " .. latestTelemetryLog
	hudLogText.TextColor3 = Color3.fromRGB(255, 215, 115)
	hudLogText.Font = Enum.Font.Gotham
	hudLogText.TextSize = 10.5
	hudLogText.TextWrapped = true
	hudLogText.TextXAlignment = Enum.TextXAlignment.Left
	hudLogText.TextYAlignment = Enum.TextYAlignment.Top
	hudLogText.Parent = diagBox
	TelemetryHUD.LogText = hudLogText
end
buildTelemetryHUD()

logTelemetry = function(msg)
	if not msg or msg == "" then return end
	latestTelemetryLog = ("[%s] %s"):format(os.date("%H:%M:%S"), tostring(msg))
	pcall(function()
		if TelemetryHUD.LogText and TelemetryHUD.LogText.Parent then
			TelemetryHUD.LogText.Text = "📜 " .. latestTelemetryLog
		end
	end)
end

updateTelemetryHUD = function()
	if not TelemetryHUD.Frame or not TelemetryHUD.Frame.Parent then return end
	pcall(function()
		local elapsed = math.floor(os.clock() - sessionStartTime)
		local hours = math.floor(elapsed / 3600)
		local mins = math.floor((elapsed % 3600) / 60)
		local secs = elapsed % 60
		local uptimeStr = ("%02d:%02d:%02d"):format(hours, mins, secs)

		local ownedDice, money, eqDice = getDiceState()
		local nextDice = getNextDiceInfo()
		local curRebirth, _, nextRebirth = getRebirthState()
		local isMaxed, isMaxRb, isMaxD, upgCount = checkAccountMaxed()
		local usedInv, capInv = getInventoryUsage()
		local collectibleSlots, totalBalance = getCollectibleSlots()

		-- Status Badge
		if TelemetryHUD.StatusBadge then
			if isMaxed then
				TelemetryHUD.StatusBadge.Text = "🏆 ไก่ตันสมบูรณ์ 100% (Account Maxed)"
				TelemetryHUD.StatusBadge.TextColor3 = Color3.fromRGB(46, 224, 140)
			elseif kaiTanAutoFarmEnabled then
				TelemetryHUD.StatusBadge.Text = "🌾 ฟาร์มไก่ตันอัตโนมัติ (Kai Tan Active)"
				TelemetryHUD.StatusBadge.TextColor3 = Color3.fromRGB(255, 205, 75)
			else
				TelemetryHUD.StatusBadge.Text = "⏸️ สแตนด์บาย (Idle / Standby)"
				TelemetryHUD.StatusBadge.TextColor3 = Color3.fromRGB(180, 195, 215)
			end
		end

		-- Dice Tracker & Progress
		if TelemetryHUD.DiceText then
			if not nextDice or isMaxD then
				TelemetryHUD.DiceText.Text = ("🎲 เต๋า: %s (MAX TIER REACHED)"):format(eqDice or "Frostfire")
				if TelemetryHUD.DiceBarFill then TelemetryHUD.DiceBarFill.Size = UDim2.new(1, 0, 1, 0) end
				if TelemetryHUD.DiceBarText then TelemetryHUD.DiceBarText.Text = "ปลดล็อคครบทุกเต๋าแล้ว 100%" end
				if TelemetryHUD.DiceSubText then TelemetryHUD.DiceSubText.Text = ("💰 เงินปัจจุบัน: $%s | โชคเต๋า: MAX"):format(formatNumber(money)) end
			else
				TelemetryHUD.DiceText.Text = ("🎲 เต๋า: %s  ➔  🎯 เป้าหมาย: %s ($%s)"):format(eqDice or "Basic", nextDice.name, formatNumber(nextDice.price))
				local ratio = math.clamp(money / math.max(nextDice.price, 1), 0, 1)
				if TelemetryHUD.DiceBarFill then TelemetryHUD.DiceBarFill.Size = UDim2.new(ratio, 0, 1, 0) end
				if TelemetryHUD.DiceBarText then TelemetryHUD.DiceBarText.Text = ("$%s / $%s (%.1f%%)"):format(formatNumber(money), formatNumber(nextDice.price), ratio * 100) end
				local missing = math.max(nextDice.price - money, 0)
				if TelemetryHUD.DiceSubText then TelemetryHUD.DiceSubText.Text = ("💰 ขาดอีก: $%s | โชคเป้าหมาย: +%s%%"):format(formatNumber(missing), formatNumber(nextDice.luck or 0)) end
			end
		end

		-- Skill Tree & Rebirth Progress
		local treePct = math.clamp((upgCount or 0) / 86, 0, 1)
		if TelemetryHUD.TreeText then
			TelemetryHUD.TreeText.Text = ("🌳 ต้นไม้: %d/86 (%.1f%%)  |  🔄 Rebirth: %d/13"):format(upgCount or 0, treePct * 100, curRebirth or 0)
		end
		if TelemetryHUD.TreeBarFill then TelemetryHUD.TreeBarFill.Size = UDim2.new(treePct, 0, 1, 0) end
		if TelemetryHUD.TreeBarText then TelemetryHUD.TreeBarText.Text = ("%d / 86 อัปเกรด (%.1f%%)"):format(upgCount or 0, treePct * 100) end

		-- Plot & Inventory
		local invRatio = (usedInv or 0) / math.max(capInv or 100, 1)
		local invStatus = invRatio >= 0.9 and "⚠️ ใกล้เต็ม" or "ปลอดภัย"
		if TelemetryHUD.PlotText then
			TelemetryHUD.PlotText.Text = ("⚔️ บนแปลง: %d แปลง  |  💰 เงินบนแปลง: $%s"):format(#collectibleSlots, formatNumber(totalBalance))
		end
		if TelemetryHUD.InvText then
			TelemetryHUD.InvText.Text = ("🎒 กระเป๋า: %d/%d (%s)  |  🎲 สุ่มแล้ว: %s ครั้ง"):format(usedInv or 0, capInv or 100, invStatus, formatNumber(totalRolls))
		end

		-- Telemetry Performance
		local fps = 60
		if #fps_samples > 0 then
			local sum = 0
			for _, v in ipairs(fps_samples) do sum += v end
			fps = math.floor(sum / #fps_samples)
		end
		local ping = math.floor(LocalPlayer:GetNetworkPing() * 1000)
		if TelemetryHUD.PerfText then
			TelemetryHUD.PerfText.Text = ("⚡ FPS: %d  |  📶 Ping: %dms  |  ⏱️ รัน: %s"):format(fps, ping, uptimeStr)
		end
	end)
end

task.spawn(function()
	task.wait(0.2)
	updateTelemetryHUD()
end)

-- ─── FPS & Ping Real-Time Sampling Loop & HUD Refresh ────────
local fps_samples = {}
local fpsPingConn
local lastTelemetryTick = 0
fpsPingConn = RunService.RenderStepped:Connect(function(dt)
	if _G.AnimeDice_Session ~= CURRENT_SESSION_ID then
		if fpsPingConn then fpsPingConn:Disconnect() end
		return
	end
	table.insert(fps_samples, 1 / math.max(dt, 0.001))
	if #fps_samples > 24 then
		table.remove(fps_samples, 1)
	end
	local sum = 0
	for _, v in ipairs(fps_samples) do
		sum += v
	end
	local fps = math.floor(sum / #fps_samples)
	local ping = math.floor(LocalPlayer:GetNetworkPing() * 1000)
	if StatsLabel and StatsLabel.Parent then
		StatsLabel.Text = T("hud_fps") .. ": " .. fps .. " | " .. T("hud_ping") .. ": " .. ping .. "ms"
	end

	-- Refresh Telemetry HUD every 1 second
	local now = os.clock()
	if now - lastTelemetryTick >= 1.0 then
		lastTelemetryTick = now
		updateTelemetryHUD()
	end
end)

-- ─── Session Cleanup Registration ────────────────────────────
_G.AnimeDice_SessionCleanup = function()
	sessionActive = false
	kaiTanGeneration += 1
	fastRollGeneration += 1
	collectGeneration += 1
	equipGeneration += 1
	diceGeneration += 1
	treeGeneration += 1
	upgradeGeneration += 1
	levelGeneration += 1
	rebirthGeneration += 1
	towerGeneration += 1
	questGeneration += 1
	sellGeneration += 1
	potionGeneration += 1
	pcall(function() invokeRemote(CancelTower) end)

	particle_generation += 1
	active_particles_count = 0
	if clear_all_particles then
		pcall(clear_all_particles)
	end
	if fpsPingConn then
		pcall(function() fpsPingConn:Disconnect() end)
	end
	pcall(function()
		local cg = game:GetService("CoreGui")
		if cg:FindFirstChild("AnimeDiceHUD") then
			cg.AnimeDiceHUD:Destroy()
		end
		if cg:FindFirstChild("AnimeDice_TelemetryHUD") then
			cg.AnimeDice_TelemetryHUD:Destroy()
		end
		local pg = LocalPlayer:FindFirstChildOfClass("PlayerGui")
		if pg and pg:FindFirstChild("AnimeDiceHUD") then
			pg.AnimeDiceHUD:Destroy()
		end
		if pg and pg:FindFirstChild("AnimeDice_TelemetryHUD") then
			pg.AnimeDice_TelemetryHUD:Destroy()
		end
	end)
end

-- ─── Boot-Launch Saved Active Workers ────────────────────────
task.spawn(function()
	task.wait(1.0)
	if not sessionActive then return end
	if autoCollectEnabled then
		collectGeneration += 1
		local curGen = collectGeneration
		local colInt = math.max(tonumber(getSavedValue("AnimeDiceCollectInterval", 15)) or 15, 1)
		runWorker(function() return autoCollectEnabled and curGen == collectGeneration and sessionActive end, function()
			collectPlotBalances()
			return colInt
		end)
	end
	if autoEquipEnabled then
		equipGeneration += 1
		local curGen = equipGeneration
		local eqInt = math.max(tonumber(getSavedValue("AnimeDiceEquipInterval", 10)) or 10, 2)
		runWorker(function() return autoEquipEnabled and curGen == equipGeneration and sessionActive end, function()
			smartEquipBestUnits()
			return eqInt
		end)
	end
	if autoBuyDiceEnabled then
		diceGeneration += 1
		local curGen = diceGeneration
		runWorker(function() return autoBuyDiceEnabled and curGen == diceGeneration and sessionActive end, function()
			buyAffordableDice()
			equipBestDice()
			refreshShopHUD()
			return 3
		end)
	end
	if autoMaxTreeEnabled and not kaiTanAutoFarmEnabled then
		treeGeneration += 1
		local curGen = treeGeneration
		runWorker(function() return autoMaxTreeEnabled and curGen == treeGeneration and sessionActive end, function()
			buyMaxTreeUpgrades()
			refreshShopHUD()
			return 4
		end)
	end
	if autoUpgradeEnabled and not kaiTanAutoFarmEnabled then
		upgradeGeneration += 1
		local curGen = upgradeGeneration
		runWorker(function() return autoUpgradeEnabled and curGen == upgradeGeneration and sessionActive end, function()
			buySelectedUpgrades()
			refreshShopHUD()
			return 5
		end)
	end
	if autoLevelEnabled and not kaiTanAutoFarmEnabled then
		levelGeneration += 1
		local curGen = levelGeneration
		runWorker(function() return autoLevelEnabled and curGen == levelGeneration and sessionActive end, function()
			runLevelUpPass(curGen)
			return 5
		end)
	end
	if autoRebirthEnabled and not kaiTanAutoFarmEnabled then
		rebirthGeneration += 1
		local curGen = rebirthGeneration
		runWorker(function() return autoRebirthEnabled and curGen == rebirthGeneration and sessionActive end, function()
			tryRebirth()
			return 3
		end)
	end
	if autoTowerEnabled and startTowerAutomation then
		towerGeneration += 1
		startTowerAutomation(towerGeneration)
	end
	if autoQuestEnabled and not kaiTanAutoFarmEnabled then
		questGeneration += 1
		local curGen = questGeneration
		runWorker(function() return autoQuestEnabled and curGen == questGeneration and sessionActive end, function()
			claimCompletedQuests()
			return 8
		end)
	end
	if autoSellEnabled then
		sellGeneration += 1
		local curGen = sellGeneration
		local sInt = math.max(tonumber(getSavedValue("AnimeDiceSellInterval", 4)) or 4, 1)
		runWorker(function() return autoSellEnabled and curGen == sellGeneration and sessionActive end, function()
			sellSelectedUnits()
			return sInt
		end)
	end
	if autoPotionsEnabled and not kaiTanAutoFarmEnabled then
		potionGeneration += 1
		local curGen = potionGeneration
		runWorker(function() return autoPotionsEnabled and curGen == potionGeneration and sessionActive end, function()
			useAvailablePotions()
			return 6
		end)
	end
end)

getgenv().loaded = true
