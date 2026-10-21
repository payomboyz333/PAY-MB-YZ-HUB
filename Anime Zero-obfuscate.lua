-- Initialize PayomboyUIz readiness flags
getgenv().loaded = true
_G.loaded = true
loaded = true

-- Immediate Anti-AFK Daemon (Protects immediately on script boot & persists across teleports/loads)
pcall(function()
	local vu = game:GetService("VirtualUser")
	local players = game:GetService("Players")
	local lp = players.LocalPlayer or players.PlayerAdded:Wait()
	if getgenv()._PayomboyZ_AntiAfkConnection then
		getgenv()._PayomboyZ_AntiAfkConnection:Disconnect()
		getgenv()._PayomboyZ_AntiAfkConnection = nil
	end
	getgenv()._PayomboyZ_AntiAfkConnection = lp.Idled:Connect(function()
		pcall(function()
			vu:CaptureController()
			vu:ClickButton2(Vector2.new())
		end)
	end)
	if not getgenv()._PayomboyZ_AntiAfkLoop then
		getgenv()._PayomboyZ_AntiAfkLoop = true
		task.spawn(function()
			while true do
				task.wait(60)
				pcall(function()
					vu:CaptureController()
					vu:ClickButton2(Vector2.new())
				end)
			end
		end)
	end
end)

-- PAYOMBØYZ HUB | Anime Zero | PayomboyUIz UI
-- KAITUN edition: every automation is force-enabled on execute (settings: gacha.K, search "KAITUN SETTINGS")
if not game:IsLoaded() then
	game.Loaded:Wait()
end
task.wait(3)

local SCRIPT_VERSION = "PayomboyZ v6.0"
local GAME_NAME = "Anime Zero"
local GAME_KEY = "AnimeZero"

-- ====================================================================
-- GAME ENGINE — PURE LEIK-LAON (Anime Zero)
-- ====================================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local Lighting = game:GetService("Lighting")
local GuiService = game:GetService("GuiService")
local VirtualUser = game:GetService("VirtualUser")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer

local hasHttpGet = typeof(game.HttpGet) == "function"
local hasLoadstring = typeof(loadstring) == "function"
local hasQueueOnTeleport = typeof(queue_on_teleport) == "function"
local httpRequest = (typeof(request) == "function" and request)
	or (typeof(http_request) == "function" and http_request)
	or (type(http) == "table" and typeof(http.request) == "function" and http.request)
	or nil


local function waitPath(root, ...)
	local node = root
	for _, name in { ... } do
		node = node:WaitForChild(name, 20)
		if not node then
			error("missing " .. name .. "; join a gameplay run first", 0)
		end
	end
	return node
end

local IN_LOBBY = ReplicatedStorage:FindFirstChild("lobby") ~= nil
local IN_RUN = not IN_LOBBY and ReplicatedStorage:FindFirstChild("game") ~= nil
if not (IN_LOBBY or IN_RUN) then
	error("unsupported place", 0)
end

local RunStore, EnemyStore, PlayerNamespace, CharacterPackets, RunPackets, Maps, CharacterController, MovementController
local Enemies
local LobbyPackets, Account, Levels, MilestoneConfig, QuestConfig, CodesConfig, EconomyConfig, RollConfig, GamemodeEnum, QueueRoomStore
local TraitConfig, EmotesConfig, AccessoryConfig, CraftConfig, SkillTreeConfig, CharacterLevels, SkillTreePackets

local gacha = {}

-- ===================== KAITUN SETTINGS (edit here) =====================
gacha.K = {
	Mode = false,                      -- true: every execution force-enables the flags in On (overrides saved toggles)
	Skip = {},                         -- flags to leave alone, e.g. { AutoSummon = true, AutoTrait = true }
	AutoProgress = true,               -- Story: always queue the first map that still has chapters to clear
	TraitStopRarity = "Mythic",        -- AutoTrait keeps rolling until the trait is this rarity or better
	LeaveMinutes = 20,                 -- stuck-run guard: leave a run that lasts longer than this
	SelfFile = "Relwx_AnimeZero.lua",  -- save THIS script under this name in your executor workspace to survive teleports
	Loader = nil,                      -- or a ready loader string, e.g. 'loadstring(game:HttpGet("https://.../x.lua"))()'
	On = {
		-- in a run
		"AutoFarm", "AutoArise", "AutoSkill", "AutoSkillG", "DynamicMovement", "AutoDodgeIgris", "AutoRetreat", "Failsafe", "SwitchOnCooldown",
		"AutoNextChapter", "AutoRetry", "AutoLeave", "AutoLeaveRun",
		-- in the lobby
		"AutoJoin", "JoinAuto", "AutoDelivery", "AutoMilestones", "AutoDaily", "AutoQuests", "AutoAchievements",
		"AutoRedeemCodes", "AutoSkipTutorial", "AutoSummon", "SummonFavourite", "AutoTrait", "AutoEmote",
		"AutoUnlockSlots", "AutoCraft", "AutoSkillTree", "AutoEvolve", "AutoBestAccessory", "AutoBestTitle",
		"AutoRarestCharacters",
		-- safety / upkeep
		"AntiAfk", "AntiGameplayPause", "AutoReconnect", "FpsBoost", "DisableCombatCursor", "AutoSaveConfig", "AutoLoadConfig",
	},
}
-- Deliberately NOT enabled: SummonBuyLucky (spends gems), AutoLeaveRuns (conflicts with AutoNextChapter),
-- SkillCombo / UltBossOnly (play-style choices), Fly / NoClip / WalkSpeed / InfJump, ESP, webhooks (need your URL).

if IN_RUN then
	RunStore = require(waitPath(ReplicatedStorage, "game", "stores", "runStore"))
	EnemyStore = require(waitPath(ReplicatedStorage, "game", "stores", "enemyStore"))
	PlayerNamespace = require(waitPath(ReplicatedStorage, "game", "stores", "playerNamespace"))
	CharacterPackets = require(waitPath(ReplicatedStorage, "game", "packets", "characterPackets"))
	RunPackets = require(waitPath(ReplicatedStorage, "game", "packets", "runPackets"))
	Maps = require(waitPath(ReplicatedStorage, "global", "constants", "maps"))
	CharacterController = require(waitPath(LocalPlayer, "PlayerScripts", "game", "controllers", "characterController"))
	MovementController = (function()
		local ok, mod = pcall(require, waitPath(LocalPlayer, "PlayerScripts", "game", "controllers", "movementController"))
		return ok and mod or nil
	end)()
	Enemies = require(waitPath(ReplicatedStorage, "global", "constants", "enemies"))
else
	LobbyPackets = require(waitPath(ReplicatedStorage, "lobby", "packets"))
	Account = require(waitPath(ReplicatedStorage, "global", "stores", "accountNamespace"))
	Levels = require(waitPath(ReplicatedStorage, "global", "utils", "levelProgression"))
	MilestoneConfig = require(waitPath(ReplicatedStorage, "assets", "config", "levelMilestoneConfig"))
	QuestConfig = require(waitPath(ReplicatedStorage, "assets", "config", "questConfig"))
	CodesConfig = (function()
		local p = ReplicatedStorage:FindFirstChild("assets")
		p = p and p:FindFirstChild("config")
		p = p and p:FindFirstChild("codesConfig")
		if p then
			local ok, res = pcall(require, p)
			if ok then return res end
		end
		return {}
	end)()
	EconomyConfig = require(waitPath(ReplicatedStorage, "assets", "config", "economyConfig"))
	RollConfig = require(waitPath(ReplicatedStorage, "assets", "config", "characterRollConfig"))
	GamemodeEnum = require(waitPath(ReplicatedStorage, "lobby", "enums", "gamemodeSelectEnum"))
	QueueRoomStore = require(waitPath(ReplicatedStorage, "lobby", "stores", "ququeRoomStore"))
	TraitConfig = require(waitPath(ReplicatedStorage, "assets", "config", "Traits", "traitConfig"))
	EmotesConfig = require(waitPath(ReplicatedStorage, "assets", "config", "emotesConfig"))
	AccessoryConfig = require(waitPath(ReplicatedStorage, "assets", "config", "accessoryConfig"))
	gacha.TitleConfig = require(waitPath(ReplicatedStorage, "assets", "config", "titleConfig"))
	gacha.EvolutionConfig = require(waitPath(ReplicatedStorage, "assets", "config", "evolutionConfig"))
	CraftConfig = require(waitPath(ReplicatedStorage, "assets", "config", "accessoryCraftConfig"))
	SkillTreeConfig = require(waitPath(ReplicatedStorage, "assets", "config", "characterSkillTreeConfig"))
	CharacterLevels = require(waitPath(ReplicatedStorage, "global", "utils", "characterLevelProgression"))
	SkillTreePackets = require(waitPath(ReplicatedStorage, "lobby", "modules", "skillTree", "skillTreePackets"))
end

local function createFeatureAPI(namespace)
	assert(type(namespace) == "string" and namespace ~= "", "namespace required")
	assert(type(getgenv) == "function", "getgenv unavailable")
	local env = getgenv()
	assert(type(env) == "table", "getgenv did not return a table")
	local previous = env[namespace]
	if previous ~= nil then
		assert(type(previous) == "table" and type(previous.Unload) == "function", "namespace occupied")
		local ok, err = pcall(previous.Unload)
		if not ok then
			warn("Previous cleanup: " .. tostring(err))
		end
	end

	local API = {
		State = {},
		Unloaded = false,
	}
	local cleanup = {}

	function API.Track(dispose)
		assert(type(dispose) == "function", "cleanup must be callable")
		if API.Unloaded then
			local ok, err = pcall(dispose)
			if not ok then
				warn("Cleanup: " .. tostring(err))
			end
		else
			table.insert(cleanup, dispose)
		end
		return dispose
	end

	function API.Unload()
		if API.Unloaded then
			return
		end
		API.Unloaded = true
		for index = #cleanup, 1, -1 do
			local dispose = table.remove(cleanup, index)
			local ok, err = pcall(dispose)
			if not ok then
				warn("Cleanup: " .. tostring(err))
			end
		end
		table.clear(API.State)
		if env[namespace] == API then
			env[namespace] = nil
		end
	end

	env[namespace] = API
	return API
end

local function attachUI(API, Window)
	assert(type(API) == "table" and type(API.Track) == "function", "FeatureAPI required")
	assert(type(Window) == "table" and type(Window.Destroy) == "function", "UI window required")
	API.Track(function()
		pcall(function()
			Window:Destroy()
		end)
	end)
	local gui = Window.Gui
	if typeof(gui) == "Instance" then
		local destroying = gui.Destroying:Connect(function()
			task.defer(API.Unload)
		end)
		API.Track(function()
			destroying:Disconnect()
		end)
	end
end


local API = createFeatureAPI("Relwx_AnimeZero")

local MaterialConfig
do
	local node = ReplicatedStorage:FindFirstChild("assets")
	node = node and node:FindFirstChild("config")
	node = node and node:FindFirstChild("materialConfig")
	if node then
		local ok, config = pcall(require, node)
		if ok and type(config) == "table" then
			MaterialConfig = config
		end
	end
end

local CharacterNames
do
	local node = ReplicatedStorage:FindFirstChild("global")
	node = node and node:FindFirstChild("constants")
	node = node and node:FindFirstChild("characters")
	if node then
		local ok, config = pcall(require, node)
		if ok and type(config) == "table" and type(config.charactersByName) == "table" then
			CharacterNames = config.charactersByName
		end
	end
end

local DIFFICULTY_NAMES = { "Easy", "Medium", "Hard", "Nightmare" }
local FARM_MODES = { "Front", "Orbit", "Behind", "Above", "Below" }
local TARGET_MODES = { "Nearest", "Ranged First", "Lowest HP", "Bosses First", "Biggest Pack" }
local RETREAT_ACTIONS = { "Fly Up", "Leave Run" }
local SKILL_LABELS = { "Skill 1", "Skill 2", "Skill 3", "Ultimate" }
local SKILL_SLOT = { ["Skill 1"] = 1, ["Skill 2"] = 2, ["Skill 3"] = 3, ["Ultimate"] = 4 }
local LEAVE_ACTION = 3
local POSE_RETARGET_DISTANCE = 1.5

local CONFIG_FILE = "PayomboyZ_AnimeZero_Config.json"
local LEGACY_CONFIG_FILE = "RELWX_HUB_Config.json"
local Config = {}
local hasFiles = typeof(readfile) == "function" and typeof(writefile) == "function" and typeof(isfile) == "function"

local function LoadConfig()
	if not (hasFiles or (typeof(readfile) == "function" and typeof(isfile) == "function")) then return end
	local fileToRead = nil
	pcall(function()
		if isfile(CONFIG_FILE) then
			fileToRead = CONFIG_FILE
		elseif isfile(LEGACY_CONFIG_FILE) then
			fileToRead = LEGACY_CONFIG_FILE
		end
	end)
	if not fileToRead then return end
	pcall(function()
		local content = readfile(fileToRead)
		if content and #content > 0 then
			local data = HttpService:JSONDecode(content)
			if type(data) == "table" then
				for k, v in pairs(data) do
					if type(k) == "string" then
						Config[k] = v
						if _FlagsRaw then _FlagsRaw[k] = v end
					end
				end
			end
		end
	end)
	if getgenv then
		if not getgenv().configs then getgenv().configs = {} end
		for k, v in pairs(Config) do
			getgenv().configs[k] = v
		end
	end
end
LoadConfig()

if getgenv then
	if not getgenv().configs then getgenv().configs = {} end
	for k, v in pairs(Config) do
		getgenv().configs[k] = v
	end
end

local _FlagsRaw = {
	AutoFarm = false,
	AutoArise = false,
	FarmMode = "Front",
	Failsafe = true,
	FailsafeMode = "Leave Run",
	FailsafeSeconds = 6,
	FailsafeScanLeave = true,
	EmptyRoomLeaveDelay = 4,
	MoveSpeed = 150,
	AttackDistance = 5,
	HeightOffset = 8,
	OrbitSpeed = 180,
	AutoSkill = false,
	AutoSkillG = true,
	DynamicMovement = true,
	SkillSlots = { 1, 2, 3 },
	SkillCombo = false,
	UltBossOnly = false,
	UltBossPriority = false,
	AutoDodgeIgris = false,
	ComboOrder = { 1, 2, 3 },
	ComboDelay = 0,
	SkillRange = 25,
	SkillMinEnemies = 1,
	TargetMode = "Nearest",
	AutoRetreat = false,
	RetreatHealth = 30,
	RetreatResume = 70,
	RetreatAction = "Fly Up",
	RetreatHeight = 60,
	RetreatMaxSeconds = 15,
	SwitchOnCooldown = false,
	SwitchUltMode = "Don't Consider Ultimates",
	WebhookUrl = "",
	WebhookResults = false,
	WebhookRolls = false,
	WebhookKicked = false,
	WebhookHuTao = false,
	PingEnabled = false,
	PingUserId = "",
	PingMaterials = {},
	PingMinTier = "Off",
	AutoJoin = false,
	AutoUnlockNextStage = false,
	JoinAuto = false,
	JoinChoice = "",
	JoinChapter = 0,
	JoinDifficulty = "Easy",
	JoinPlayers = 1,
	JoinFriendsOnly = false,
	JoinDelay = 5,
	AutoDelivery = false,
	AutoMilestones = false,
	AutoDaily = false,
	AutoQuests = false,
	AutoSummon = false,
	SummonType = "Normal",
	SummonPayment = "money",
	SummonSlot = 1,
	SummonDelay = 2,
	ProtectRarity = "Mythic",
	SummonStopCharacters = {},
	SummonFavourite = false,
	SummonBuyLucky = false,
	AutoTrait = false,
	TraitCharacter = "Equipped Character",
	TraitTargets = {},
	TraitStopRarity = "None",
	AutoEmote = false,
	EmoteTargets = {},
	EmoteStopRarity = "None",
	EmoteStopAllOwned = false,
	AutoUnlockSlots = false,
	TraitDelay = 1,
	AutoCraft = false,
	CraftItems = {},
	CraftTarget = 1,
	AutoSkillTree = false,
	AutoEvolve = false,
	AutoBestAccessory = false,
	AutoBestTitle = false,
	BestGearStat = "Damage",
	AutoRarestCharacters = false,
	AutoAchievements = false,
	AutoRedeemCodes = false,
	AutoSkipTutorial = false,
	SkillTreeCharacters = {},
	SkillTreeBranches = {},
	SkillTreeMaxTier = 5,
	AutoNextChapter = false,
	AutoRetry = false,
	AutoLeave = true,
	ResultDelay = 2,
	AutoLeaveRun = false,
	LeaveMinutes = 10,
	AutoLeaveRuns = false,
	LeaveRuns = 5,
	WalkSpeedEnabled = false,
	WalkSpeed = 32,
	InfJump = false,
	NoClip = false,
	InstantProximityPrompt = false,
	Fly = false,
	FlySpeed = 60,
	AntiGameplayPause = false,
	AutoReconnect = false,
	Disable3DRendering = false,
	DisableCombatCursor = false,
	FpsBoost = false,
	UltraFpsBoost = false,
	DisableSkillVfx = false,
	DisablePlayerAnimations = false,
	AntiAfk = true,
	AutoSaveConfig = true,
	AutoLoadConfig = true,
	Language = "TH",
}

for k, v in pairs(Config) do
	_FlagsRaw[k] = v
end

local SaveToken = 0
local function SaveConfig(instant)
	if not (typeof(writefile) == "function" and HttpService) then return end
	if Flags and Flags.AutoSaveConfig == false and not instant then return end
	SaveToken = SaveToken + 1
	local token = SaveToken
	local function commit()
		if token ~= SaveToken then return end
		pcall(function()
			for k, v in pairs(_FlagsRaw) do
				if type(v) == "boolean" or type(v) == "number" or type(v) == "string" or type(v) == "table" then
					Config[k] = v
				end
			end
			writefile(CONFIG_FILE, HttpService:JSONEncode(Config))
		end)
	end
	if instant then
		commit()
	else
		task.delay(0.3, commit)
	end
end

local Flags = setmetatable({}, {
	__index = _FlagsRaw,
	__newindex = function(_, k, v)
		_FlagsRaw[k] = v
		if type(k) == "string" then
			Config[k] = v
			if getgenv and getgenv().configs then
				getgenv().configs[k] = v
			end
			SaveConfig()
		end
	end,
	__iter = function()
		return next, _FlagsRaw, nil
	end
})

local STATS_FOLDER = "Relwx/" .. GAME_KEY
local STATS_FILE = STATS_FOLDER .. "/stats.json"
local hasFiles = typeof(readfile) == "function" and typeof(writefile) == "function" and typeof(isfile) == "function"

local Stats = {
	wins = 0,
	losses = 0,
	rollHits = 0,
	kicked = 0,
	kills = 0,
	money = 0,
	gems = 0,
	xp = 0,
	materials = {},
}

local function loadStats()
	if not hasFiles then
		return
	end
	local ok, decoded = pcall(function()
		if isfile(STATS_FILE) then
			return HttpService:JSONDecode(readfile(STATS_FILE))
		end
		return nil
	end)
	if ok and type(decoded) == "table" then
		for key, value in pairs(decoded) do
			if key == "materials" then
				if type(value) == "table" then
					Stats.materials = value
				end
			elseif type(Stats[key]) == "number" and type(value) == "number" then
				Stats[key] = value
			end
		end
	end
end

local function saveStats()
	if not hasFiles then
		return
	end
	pcall(function()
		if typeof(makefolder) == "function" and typeof(isfolder) == "function" then
			if not isfolder("Relwx") then
				makefolder("Relwx")
			end
			if not isfolder(STATS_FOLDER) then
				makefolder(STATS_FOLDER)
			end
		end
		writefile(STATS_FILE, HttpService:JSONEncode(Stats))
	end)
end

local function resetStats()
	for key, value in pairs(Stats) do
		if type(value) == "number" then
			Stats[key] = 0
		end
	end
	Stats.materials = {}
	saveStats()
end

loadStats()

local function materialInfo(id)
	local entry = MaterialConfig and (MaterialConfig[tonumber(id)] or MaterialConfig[tostring(id)])
	if type(entry) == "table" then
		return tostring(entry.Name or id), tonumber(entry.Tier) or 0, entry.Icon
	end
	return "Material " .. tostring(id), 0
end

local function ownedMaterials()
	local ok, all = pcall(function()
		local node = ReplicatedStorage:FindFirstChild("global")
		node = node and node:FindFirstChild("stores")
		node = node and node:FindFirstChild("accountNamespace")
		local account = node and require(node).getLocalPlayerAccount()
		local material = account and (account.state or account).material
		return material and material:getAll()
	end)
	return if ok and type(all) == "table" then all else nil
end

local MATERIAL_LABELS = {}
local MATERIAL_BY_LABEL = {}
local MATERIAL_TIER_OPTIONS = { "Off" }
do
	local maxTier = 0
	local ids = {}
	for id, entry in pairs(MaterialConfig or {}) do
		if type(entry) == "table" and entry.Name then
			table.insert(ids, tostring(id))
		end
	end
	table.sort(ids, function(a, b)
		return (tonumber(a) or 0) < (tonumber(b) or 0)
	end)
	for _, id in ipairs(ids) do
		local name, tier = materialInfo(id)
		local label = string.format("%s (T%d)", name, tier)
		table.insert(MATERIAL_LABELS, label)
		MATERIAL_BY_LABEL[label] = id
		maxTier = math.max(maxTier, tier)
	end
	for tier = 1, maxTier do
		table.insert(MATERIAL_TIER_OPTIONS, tostring(tier))
	end
end

local function webhookUrl()
	local url = string.gsub(tostring(Flags.WebhookUrl or ""), "%s+", "")
	for _, host in ipairs({ "discord%.com", "discordapp%.com", "ptb%.discord%.com", "canary%.discord%.com" }) do
		if string.find(url, "^https://" .. host .. "/api/webhooks/") then
			return url
		end
	end
	return nil
end

local thumbCache = {}

local function thumbnail(kind, id)
	id = tostring(id or ""):match("%d+")
	if not id or not httpRequest then
		return nil
	end
	local key = kind .. id
	if thumbCache[key] then
		return thumbCache[key]
	end
	local path
	if kind == "user" then
		path = "users/avatar-headshot?userIds=" .. id .. "&size=150x150&format=Png"
	elseif kind == "place" then
		path = "places/gameicons?placeIds=" .. id .. "&size=150x150&format=Png"
	else
		path = "assets?assetIds=" .. id .. "&size=420x420&format=Png"
	end
	local ok, response = pcall(httpRequest, { Url = "https://thumbnails.roblox.com/v1/" .. path, Method = "GET" })
	if not ok or type(response) ~= "table" then
		return nil
	end
	local okDecode, decoded = pcall(HttpService.JSONDecode, HttpService, tostring(response.Body))
	local entry = okDecode and type(decoded) == "table" and type(decoded.data) == "table" and decoded.data[1]
	local image = type(entry) == "table" and entry.state == "Completed" and entry.imageUrl or nil
	if image then
		thumbCache[key] = image
	end
	return image
end

local function characterArt(id)
	local info = CharacterNames and CharacterNames[tostring(id)]
	local skills = info and info.skills
	local last = type(skills) == "table" and skills[#skills]
	return type(last) == "table" and last.icon or nil
end

-- ชื่อสำรอง (id ตัวละครทั้งหมดที่พบในไฟล์ dump ของเกม) ใช้เมื่อเกมไม่มี displayName
gacha.NAME_FALLBACK = {
	shanks = "Shanks", sung_jinwoo = "Sung Jinwoo", guts = "Guts", alucard = "Alucard", ichigo = "Ichigo",
	goku = "Goku", saber = "Saber", killua = "Killua", yhwach = "Yhwach", luffy = "Luffy", nagumo = "Nagumo",
	escanor = "Escanor", gojo = "Gojo", miyabi = "Miyabi", sukuna = "Sukuna", juuzou = "Juuzou",
	hutao = "Hu Tao", katakuri = "Katakuri",
}
function gacha.prettyName(id)
	id = tostring(id)
	if gacha.NAME_FALLBACK[id] then
		return gacha.NAME_FALLBACK[id]
	end
	local s = id:gsub("_", " "):gsub("(%l)(%u)", "%1 %2")
	return (s:gsub("(%a)([%w']*)", function(a, b)
		return a:upper() .. b
	end))
end

local function characterName(id)
	local info = CharacterNames and CharacterNames[tostring(id)]
	local name = info and info.displayName
	if type(name) == "string" and name ~= "" then
		return name
	end
	return gacha.prettyName(id)
end

local function postWebhook(content, embed)
	local url = webhookUrl()
	if not url or not httpRequest then
		return false
	end
	local thumbAsset = embed.thumbAsset
	local extra = embed.extraEmbeds or {}
	embed.thumbAsset = nil
	embed.extraEmbeds = nil
	for _, item in ipairs(extra) do
		local icon = item.iconAsset
		item.iconAsset = nil
		if icon and item.author then
			item.author.icon_url = thumbnail("asset", icon)
		end
	end
	embed.author = {
		name = LocalPlayer.DisplayName .. " (@" .. LocalPlayer.Name .. ")",
		icon_url = thumbnail("user", LocalPlayer.UserId),
	}
	if thumbAsset then
		local image = thumbnail("asset", thumbAsset)
		if image then
			embed.thumbnail = { url = image }
		end
	end
	embed.footer = { text = GAME_NAME, icon_url = thumbnail("place", game.PlaceId) }
	embed.timestamp = DateTime.now():ToIsoDate()
	local ok, response = pcall(httpRequest, {
		Url = url,
		Method = "POST",
		Headers = { ["Content-Type"] = "application/json" },
		Body = HttpService:JSONEncode({ username = "Relwx", content = content, embeds = { embed, table.unpack(extra) } }),
	})
	return ok and type(response) == "table" and (tonumber(response.StatusCode) or 0) < 300
end

local function sendWebhook(content, embed)
	task.spawn(postWebhook, content, embed)
end

local function formatNumber(value)
	local text = tostring(math.floor(tonumber(value) or 0))
	return (text:reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", ""))
end

local function formatTime(seconds)
	seconds = math.max(math.floor(tonumber(seconds) or 0), 0)
	if seconds >= 60 then
		return string.format("%dm %02ds", seconds // 60, seconds % 60)
	end
	return seconds .. "s"
end

local function field(name, value, inline)
	return { name = name, value = value, inline = inline ~= false }
end

local function statLine(icon, label, value)
	return string.format("%s %s  **%s**", icon, label, value)
end

local function totalsFields()
	local runs = Stats.wins + Stats.losses
	local rate = if runs > 0 then string.format("%d%%", math.floor(Stats.wins / runs * 100 + 0.5)) else "-"
	return {
		field("\u{200B}", "**━━━━━━━━  Session  ━━━━━━━━**", false),
		field("Record", table.concat({
			statLine("🏆", "Wins", formatNumber(Stats.wins)),
			statLine("💀", "Losses", formatNumber(Stats.losses)),
			statLine("📈", "Win Rate", rate),
		}, "\n")),
		field("Earned", table.concat({
			statLine("💰", "Money", formatNumber(Stats.money)),
			statLine("💎", "Gems", formatNumber(Stats.gems)),
			statLine("✨", "XP", formatNumber(Stats.xp)),
		}, "\n")),
		field("Activity", table.concat({
			statLine("⚔️", "Kills", formatNumber(Stats.kills)),
			statLine("🎲", "Pulls", formatNumber(Stats.rollHits)),
			statLine("🚪", "Kicks", formatNumber(Stats.kicked)),
		}, "\n")),
	}
end

local function withTotals(fields)
	for _, entry in ipairs(totalsFields()) do
		table.insert(fields, entry)
	end
	return fields
end

local TIER_COLORS = { 12370112, 5763719, 3447003, 10181046, 16705372, 15548997 }

local function rarityColor(rarity)
	local entry = RollConfig and RollConfig.rarities and RollConfig.rarities[rarity]
	local color = entry and entry.color
	if typeof(color) == "ColorSequence" then
		color = color.Keypoints[1].Value
	end
	if typeof(color) == "Color3" then
		return tonumber(color:ToHex(), 16)
	end
	return 16766720
end

local function pingContent(lines)
	if not Flags.PingEnabled or #lines == 0 then
		return nil
	end
	local userId = string.gsub(tostring(Flags.PingUserId or ""), "%D", "")
	if userId == "" then
		return nil
	end
	return "<@" .. userId .. "> " .. table.concat(lines, ", ")
end

local function recordRun(participant)
	local status = participant.status:get()
	if status ~= "victory" and status ~= "failed" then
		return
	end
	local materials = {}
	for id, count in tostring(participant.materials:get()):gmatch("(%d+):(%d+)") do
		materials[id] = (materials[id] or 0) + (tonumber(count) or 0)
	end
	local money = participant.earned:get() + participant.bonus:get()
	local gems = participant.gems:get()
	local xp = participant.xp:get()
	local kills = participant.kills:get()
	if status == "victory" then
		Stats.wins += 1
	else
		Stats.losses += 1
	end
	Stats.kills += kills
	Stats.money += money
	Stats.gems += gems
	Stats.xp += xp
	local drops, pingLines = {}, {}
	local minTier = tonumber(Flags.PingMinTier)
	for id, count in pairs(materials) do
		Stats.materials[id] = (Stats.materials[id] or 0) + count
		local name, tier, icon = materialInfo(id)
		table.insert(drops, { id = id, name = name, tier = tier, count = count, icon = icon })
		if table.find(Flags.PingMaterials, id) or (minTier and tier >= minTier) then
			table.insert(pingLines, string.format("%s x%d", name, count))
		end
	end
	table.sort(drops, function(a, b)
		if a.tier ~= b.tier then
			return a.tier > b.tier
		end
		return a.name < b.name
	end)
	saveStats()
	local unit = participant.unit and participant.unit:get()
	if Flags.WebhookHuTao and unit == "hutao" then
		local userId = string.gsub(tostring(Flags.PingUserId or ""), "%D", "")
		sendWebhook(if Flags.PingEnabled and userId ~= "" then "<@" .. userId .. "> Hu Tao dropped" else nil, {
			title = "🔥 Hu Tao Drop",
			description = string.format("> **%s** dropped from the raid", characterName(unit)),
			color = rarityColor("Zenless"),
			thumbAsset = characterArt(unit),
			fields = withTotals({}),
		})
	end
	if not Flags.WebhookResults then
		return
	end
	local state = RunStore.store.state
	local win = status == "victory"
	local mapName = tostring(Maps and Maps.currentMap or "?")
	mapName = mapName:sub(1, 1):upper() .. mapName:sub(2)
	local difficulty = DIFFICULTY_NAMES[tonumber(state.difficulty:get())] or tostring(state.difficulty:get())
	local store = PlayerNamespace.getLocalPlayerStore()
	local character = store and store.state.character:get()
	local owned = ownedMaterials()
	local dropEmbeds = {}
	for index, drop in ipairs(drops) do
		if index > 8 then
			table.insert(dropEmbeds, { color = 9807270, description = string.format("-# +%d more", #drops - 8) })
			break
		end
		local value = owned and owned[tostring(drop.id)]
		if type(value) == "table" and type(value.get) == "function" then
			value = value:get()
		end
		local total = tonumber(value)
		table.insert(dropEmbeds, {
			color = TIER_COLORS[math.clamp(drop.tier, 1, #TIER_COLORS)],
			author = { name = string.format("%s ×%d", drop.name, drop.count) .. (if total then string.format(" (%s)", formatNumber(total)) else "") },
			iconAsset = drop.icon,
		})
	end
	local fields = {
		field("Run", table.concat({
			statLine("⏱️", "Time", formatTime(participant.elapsed:get())),
			statLine("⚔️", "Kills", formatNumber(kills)),
			statLine("💥", "Damage", formatNumber(participant.damage:get())),
		}, "\n")),
		field("Rewards", table.concat({
			statLine("💰", "Money", "+" .. formatNumber(money)),
			statLine("💎", "Gems", "+" .. formatNumber(gems)),
			statLine("✨", "XP", "+" .. formatNumber(xp)),
		}, "\n")),
		field("Drops", if #dropEmbeds > 0 then "-# listed below" else "-# none"),
	}
	withTotals(fields)
	sendWebhook(pingContent(pingLines), {
		title = (win and "🏆 Victory" or "💀 Defeat") .. "  ·  " .. mapName,
		description = string.format(
			"> 📖 Chapter **%s**  ·  🎚️ **%s**\n> 🧍 Playing as **%s**",
			tostring(state.chapter:get()),
			difficulty,
			character and characterName(character) or "?"
		),
		color = win and 5763719 or 15548997,
		thumbAsset = character and characterArt(character),
		fields = fields,
		extraEmbeds = dropEmbeds,
	})
end

local function recordRollHit(character, rarity)
	Stats.rollHits += 1
	saveStats()
	if Flags.WebhookRolls then
		sendWebhook(nil, {
			title = "🎲 " .. tostring(rarity) .. " Pull",
			description = string.format("> **%s**\n> Slot **%d**", characterName(character), Flags.SummonSlot),
			color = rarityColor(rarity),
			thumbAsset = characterArt(character),
			fields = withTotals({}),
		})
	end
end

do
	local lastKickAt = 0
	local connection = GuiService.ErrorMessageChanged:Connect(function()
		local ok, message = pcall(GuiService.GetErrorMessage, GuiService)
		if not ok or type(message) ~= "string" or message == "" or os.clock() - lastKickAt < 5 then
			return
		end
		lastKickAt = os.clock()
		Stats.kicked += 1
		saveStats()
		if Flags.WebhookKicked then
			task.spawn(postWebhook, nil, {
				title = "🚪 Disconnected",
				description = "```\n" .. message .. "\n```",
				color = 15548997,
				fields = withTotals({}),
			})
		end
	end)
	API.Track(function()
		connection:Disconnect()
	end)
end

local function statsRows()
	return {
		{ Text = "Wins", Value = formatNumber(Stats.wins), Tone = "Success" },
		{ Text = "Losses", Value = formatNumber(Stats.losses), Tone = "Error" },
		{ Text = "Roll Hits", Value = formatNumber(Stats.rollHits), Tone = "Accent" },
		{ Text = "Kicked", Value = formatNumber(Stats.kicked), Tone = Stats.kicked > 0 and "Warning" or "Muted" },
		{ Text = "Kills", Value = formatNumber(Stats.kills), Tone = "Muted" },
		{ Text = "Money", Value = formatNumber(Stats.money), Tone = "Muted" },
		{ Text = "Gems", Value = formatNumber(Stats.gems), Tone = "Muted" },
		{ Text = "XP", Value = formatNumber(Stats.xp), Tone = "Muted" },
	}
end

local runtime = {
	exitAt = 0,
	ariseTried = setmetatable({}, { __mode = "k" }),
	target = nil,
	targetGap = math.huge,
	resultKey = nil,
	resultSeenAt = 0,
	resultActedKey = nil,
	resultActedAt = 0,
	leftRunAt = nil,
	tween = nil,
	poseTarget = nil,
	wallArea = nil,
	wallTries = 0,
	wallAt = 0,
	skip = {},
	watchId = nil,
	watchHealth = nil,
	watchAt = 0,
	anchorId = nil,
	anchorDir = Vector3.zAxis,
	orbitAngle = 0,
	lastTick = os.clock(),
	retreating = false,
	retreatAt = 0,
	retreatBlockUntil = 0,
	retreatSpot = nil,
	retreatLeftAt = nil,
	retreatCheckAt = 0,
	runsDone = 0,
	dodging = false,
	dodgeSpot = nil,
	recordedKey = nil,
	switchAt = 0,
	skillReadyAt = 0,
	rubble = nil,
	searchArea = nil,
	searchPoints = nil,
	searchPoint = nil,
	idleSince = nil,
	failsafeLeftAt = nil,
	searchSwept = false,
	comboIndex = 1,
	comboSince = nil,
	comboCastAt = 0,
	lastCombatDash = 0,
	lastWaitDash = 0,
	patrolPoint = nil,
	patrolNextAt = 0,
}

local function characterParts()
	local character = LocalPlayer.Character
	if not character then
		return nil, nil, nil
	end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local root = character:FindFirstChild("HumanoidRootPart")
	if not (humanoid and root and humanoid.Health > 0) then
		return nil, nil, nil
	end
	return character, root, humanoid
end

local function runState()
	return RunStore.store.state
end

local function myParticipant()
	return runState().participants:get(tostring(LocalPlayer.UserId))
end

local function inActiveRun()
	local participant = myParticipant()
	return participant ~= nil and participant.status:get() == "active"
end

local function nearestEnemy(origin)
	local clock = os.clock()
	local pool = {}
	local current
	for id, enemy in pairs(EnemyStore.store.state:getAll()) do
		local skipUntil = runtime.skip[id]
		if skipUntil and clock >= skipUntil then
			runtime.skip[id] = nil
			skipUntil = nil
		end
		local health = enemy.health:get()
		if health > 0 and not skipUntil then
			local position = enemy.position:get()
			local info = Enemies.enemiesByName[enemy.name:get()]
			local entry = {
				id = id,
				position = position,
				distance = (position - origin).Magnitude,
				health = health,
				boss = info ~= nil and info.boss == true,
				ranged = info ~= nil and (tonumber(info.attackRange) or 0) > 10,
				pack = 0,
				guarded = enemy.guardedAt and enemy.guardedAt:get() ~= nil,
			}
			table.insert(pool, entry)
			if id == runtime.target then
				current = entry
			end
		end
	end
	if #pool == 0 then
		return nil, nil
	end
	local open = {}
	for _, entry in ipairs(pool) do
		if not entry.guarded then
			table.insert(open, entry)
		end
	end
	if #open > 0 then
		pool = open
		if current and current.guarded then
			current = nil
		end
	end
	local mode = Flags.TargetMode
	local better = function(a, b)
		return a.distance < b.distance
	end
	local class
	if mode == "Ranged First" then
		class = "ranged"
	elseif mode == "Bosses First" then
		class = "boss"
	elseif mode == "Lowest HP" then
		better = function(a, b)
			if a.health ~= b.health then
				return a.health < b.health
			end
			return a.distance < b.distance
		end
	elseif mode == "Biggest Pack" then
		for _, a in ipairs(pool) do
			for _, b in ipairs(pool) do
				if (a.position - b.position).Magnitude <= 18 then
					a.pack += 1
				end
			end
		end
		better = function(a, b)
			if a.pack ~= b.pack then
				return a.pack > b.pack
			end
			return a.distance < b.distance
		end
	end
	local hasClass = false
	if class then
		for _, entry in ipairs(pool) do
			if entry[class] then
				hasClass = true
				break
			end
		end
	end
	if current and mode ~= "Nearest" and (not class or current[class] or not hasClass) then
		return current.id, current.position
	end
	local best
	for _, entry in ipairs(pool) do
		if (not hasClass or entry[class]) and (not best or better(entry, best)) then
			best = entry
		end
	end
	return best.id, best.position
end

local function enemiesWithin(origin, range)
	local count = 0
	for _, enemy in pairs(EnemyStore.store.state:getAll()) do
		if enemy.health:get() > 0 and (enemy.position:get() - origin).Magnitude <= range then
			count += 1
		end
	end
	return count
end

local function targetsWithin(origin, range)
	local count = enemiesWithin(origin, range)
	local rubble = runtime.rubble
	if rubble and rubble.Parent and rubble.CanCollide and (rubble.Position - origin).Magnitude <= range + rubble.Size.Magnitude / 2 then
		count += 1
	end
	return count
end

local function releasePose()
	local tween = runtime.tween
	runtime.tween = nil
	runtime.poseTarget = nil
	if tween then
		tween:Cancel()
	end
end

local function tweenTo(root, target, wait)
	local previous = runtime.tween
	if previous then
		previous:Cancel()
	end
	local distance = (root.Position - target.Position).Magnitude
	local duration = math.max(distance / Flags.MoveSpeed, 0.05)
	local tween = TweenService:Create(root, TweenInfo.new(duration, Enum.EasingStyle.Linear), { CFrame = target })
	runtime.tween = tween
	tween:Play()
	if wait then
		local deadline = os.clock() + duration + 0.5
		while runtime.tween == tween and not API.Unloaded and os.clock() < deadline do
			task.wait()
		end
		if runtime.tween == tween then
			runtime.tween = nil
		end
		root.AssemblyLinearVelocity = Vector3.zero
	end
end

local function holdPose(root, desired, focus, up)
	local last = runtime.poseTarget
	local moved = not last or (last.Position - desired).Magnitude > POSE_RETARGET_DISTANCE
	if moved then
		local target = CFrame.lookAt(desired, focus, up)
		runtime.poseTarget = target
		tweenTo(root, target, false)
		return
	end
	local tween = runtime.tween
	if tween and tween.PlaybackState == Enum.PlaybackState.Playing then
		return
	end
	local target = CFrame.lookAt(last.Position, focus, up)
	runtime.poseTarget = target
	root.CFrame = target
	root.AssemblyLinearVelocity = Vector3.zero
	root.AssemblyAngularVelocity = Vector3.zero
end

function runtime.groundAt(position, character, distance)
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	local exclude = { character }
	local enemies = Workspace:FindFirstChild("enemies")
	if enemies then
		table.insert(exclude, enemies)
	end
	local World = Workspace:FindFirstChild("World")
	local areas = World and World:FindFirstChild("Areas")
	if areas then
		table.insert(exclude, areas)
	end
	for _, name in ipairs({ "effects", "_effects", "visualizeParts" }) do
		local folder = Workspace:FindFirstChild(name)
		if folder then
			table.insert(exclude, folder)
		end
	end
	local origin = position + Vector3.new(0, 4, 0)
	local direction = Vector3.new(0, -(distance or 400), 0)
	for _ = 1, 8 do
		params.FilterDescendantsInstances = exclude
		local result = Workspace:Raycast(origin, direction, params)
		if not result or result.Instance.CanCollide then
			return result and result.Position or nil
		end
		table.insert(exclude, result.Instance)
	end
	return nil
end

function runtime.farmPose(position, dt, padding)
	local mode = Flags.FarmMode
	local distance = Flags.AttackDistance + (padding or 0)
	local dir = runtime.anchorDir
	local desired
	if mode == "Behind" then
		desired = position - dir * distance
	elseif mode == "Orbit" then
		runtime.orbitAngle += math.rad(Flags.OrbitSpeed) * dt
		desired = position + Vector3.new(math.cos(runtime.orbitAngle), 0, math.sin(runtime.orbitAngle)) * distance
	elseif mode == "Above" then
		desired = position + Vector3.new(0, Flags.HeightOffset + (padding or 0), 0)
	elseif mode == "Below" then
		desired = position - Vector3.new(0, Flags.HeightOffset + (padding or 0), 0)
	else
		desired = position + dir * distance
	end
	local up = if mode == "Above" or mode == "Below" then dir else Vector3.yAxis
	local focus = if up == Vector3.yAxis then Vector3.new(position.X, desired.Y, position.Z) else position
	return desired, focus, up
end

function runtime.areaZone(area)
	local World = Workspace:FindFirstChild("World")
	local areas = World and World:FindFirstChild("Areas")
	if not areas then
		return nil
	end
	local mapConfig = Maps and Maps.mapsByName[Maps.currentMap]
	local areaConfig = mapConfig and mapConfig.areas[area]
	local zone = areaConfig and areaConfig.zone and areas:FindFirstChild(tostring(areaConfig.zone))
	return zone or areas:FindFirstChild(tostring(area))
end

function runtime.searchPointsFor(area, character)
	local World = Workspace:FindFirstChild("World")
	local zone = runtime.areaZone(area)
	if not (zone and zone:IsA("BasePart")) then
		return nil
	end
	local size = zone.Size
	local nx = math.max(math.ceil(size.X / 60), 1)
	local nz = math.max(math.ceil(size.Z / 60), 1)
	local points = {}
	for ix = 1, nx do
		for iz = 1, nz do
			local column = if ix % 2 == 0 then nz - iz + 1 else iz
			local offset = Vector3.new((ix - 0.5) / nx - 0.5, 0, (column - 0.5) / nz - 0.5) * size
			local ground = runtime.groundAt(zone.CFrame:PointToWorldSpace(offset), character)
			if ground then
				table.insert(points, ground + Vector3.new(0, 3.5, 0))
			end
		end
	end
	return if #points > 0 then points else nil
end

local function aliveEnemyCount()
	local count = 0
	if EnemyStore and EnemyStore.store and EnemyStore.store.state then
		for _, enemy in pairs(EnemyStore.store.state:getAll()) do
			local h = enemy.health and enemy.health:get() or 0
			if h > 0 then
				count += 1
			end
		end
	end
	return count
end

local function areaEntryPosition(area, character)
	local World = Workspace:FindFirstChild("World")
	local zone = runtime.areaZone(area)
	if zone and zone:IsA("BasePart") then
		local ground = runtime.groundAt(zone.Position - Vector3.new(0, 4, 0), character, zone.Size.Y * 3)
		local groundY = if ground then ground.Y else zone.Position.Y - zone.Size.Y / 2
		return Vector3.new(zone.Position.X, groundY, zone.Position.Z)
	end
	local areaEntries = World and World:FindFirstChild("AreaEntries")
	local entry = areaEntries and areaEntries:FindFirstChild(tostring(area))
	if entry and entry:IsA("BasePart") then
		return entry.Position
	end
	local spawns = World and World:FindFirstChild("Spawns")
	local spawn = spawns and spawns:FindFirstChild(tostring(area))
	if spawn and spawn:IsA("BasePart") then
		return spawn.Position
	end
	local markers = World and World:FindFirstChild("Markers")
	if markers then
		local floorFolder = markers:FindFirstChild("Floor" .. tostring(area)) or markers:FindFirstChild(tostring(area))
		if floorFolder then
			local respawn = floorFolder:FindFirstChild("Respawn") or floorFolder:FindFirstChild("Barrier")
			if respawn and respawn:IsA("BasePart") then
				return respawn.Position
			end
		end
	end
	return nil
end

function runtime.holdSafe(root, character, area)
	local World = Workspace:FindFirstChild("World")
	local zone = runtime.areaZone(area)
	local inside = true
	if zone and zone:IsA("BasePart") then
		local localPos = zone.CFrame:PointToObjectSpace(root.Position)
		inside = math.abs(localPos.X) <= zone.Size.X / 2 and math.abs(localPos.Z) <= zone.Size.Z / 2 and math.abs(localPos.Y) <= zone.Size.Y / 2
	end
	local ground = inside and runtime.groundAt(root.Position, character)
	local spot = if ground then ground + Vector3.new(0, 3.5, 0) else nil
	if not spot then
		local center = areaEntryPosition(area, character)
		spot = center and center + Vector3.new(0, 3.5, 0)
	end
	if not spot then
		releasePose()
		return
	end
	local last = runtime.poseTarget
	if last and (last.Position - spot).Magnitude <= POSE_RETARGET_DISTANCE * 2 then
		spot = last.Position
	end
	local look = root.CFrame.LookVector
	local flat = Vector3.new(look.X, 0, look.Z)
	holdPose(root, spot, spot + (if flat.Magnitude > 0.05 then flat.Unit else Vector3.zAxis), Vector3.yAxis)
end

function runtime.canDash()
	if not MovementController then return false end
	local ok, cd = pcall(MovementController.getDashCooldown)
	return ok and type(cd) == "number" and cd <= 0
end

function runtime.performDash(targetPos)
	if not runtime.canDash() then return false end
	local _, root = characterParts()
	local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
	if root and targetPos and hum then
		local dir = (targetPos - root.Position) * Vector3.new(1, 0, 1)
		if dir.Magnitude > 0.1 then
			hum:Move(dir.Unit, false)
			root.CFrame = CFrame.lookAt(root.Position, root.Position + dir.Unit)
		end
	end
	local ok = pcall(MovementController.dash)
	if not ok and CharacterPackets and CharacterPackets.performDash then
		pcall(function() CharacterPackets.performDash:fire() end)
	end
	return ok
end

function runtime.stepLivelyMovement(root, character, area, clock)
	if not Flags.DynamicMovement then
		runtime.holdSafe(root, character, area)
		return
	end
	local center = areaEntryPosition(area, character)
	if not center then
		runtime.holdSafe(root, character, area)
		return
	end
	local flat = Vector3.new(root.Position.X - center.X, 0, root.Position.Z - center.Z)
	local dist = flat.Magnitude

	-- If far from area center, run & dash towards center
	if dist > 20 then
		local desired = center + Vector3.new(0, 3.5, 0)
		holdPose(root, desired, desired + Vector3.new(-flat.X, 0, -flat.Z), Vector3.yAxis)
		if dist > 25 and (clock - (runtime.lastWaitDash or 0) > 1.5) then
			if runtime.performDash(desired) then
				runtime.lastWaitDash = clock
			end
		end
		return
	end

	-- Around center: lively roaming / patrolling
	if not runtime.patrolPoint or (clock - (runtime.patrolNextAt or 0) > 2) or (root.Position - runtime.patrolPoint).Magnitude < 3 then
		local angle = math.random() * math.pi * 2
		local radius = math.random(5, 14)
		local offset = Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
		local ground = runtime.groundAt(center + offset, character)
		runtime.patrolPoint = ground and (ground + Vector3.new(0, 3.5, 0)) or (center + offset + Vector3.new(0, 3.5, 0))
		runtime.patrolNextAt = clock + math.random(18, 30) / 10
	end

	local targetPos = runtime.patrolPoint
	local toTarget = Vector3.new(targetPos.X - root.Position.X, 0, targetPos.Z - root.Position.Z)
	local lookDir = if toTarget.Magnitude > 0.1 then toTarget.Unit else Vector3.zAxis
	holdPose(root, targetPos, targetPos + lookDir, Vector3.yAxis)

	-- Periodically dash while patrolling to look lively
	if (clock - (runtime.lastWaitDash or 0) > 2.5) and toTarget.Magnitude > 5 then
		if runtime.performDash(targetPos) then
			runtime.lastWaitDash = clock
		end
	end
end

function runtime.failsafe(root, character, area, clock)
	if not Flags.Failsafe then
		runtime.idleSince = nil
		return false
	end
	if not runtime.idleSince then
		runtime.idleSince = clock
	end
	if clock - runtime.idleSince < Flags.FailsafeSeconds then
		return false
	end
	local function leave()
		local startedAt = runState().startedAt:get()
		if startedAt and runtime.failsafeLeftAt ~= startedAt then
			runtime.failsafeLeftAt = startedAt
			RunPackets.endAction:fire(LEAVE_ACTION)
		end
		return false
	end
	if Flags.FailsafeMode == "Leave Run" then
		return leave()
	end
	if runtime.searchArea ~= area or not runtime.searchPoints then
		runtime.searchArea = area
		runtime.searchPoints = {}
		runtime.searchPoint = nil
		runtime.searchSwept = false
	end
	local point = runtime.searchPoint
	if point then
		local flat = Vector3.new(point.X - root.Position.X, 0, point.Z - root.Position.Z)
		if flat.Magnitude <= 8 and math.abs(point.Y - root.Position.Y) <= 8 then
			point = nil
		end
	end
	if not point then
		if #runtime.searchPoints == 0 then
			if runtime.searchSwept and Flags.FailsafeScanLeave then
				return leave()
			end
			runtime.searchSwept = true
			runtime.searchPoints = runtime.searchPointsFor(area, character) or {}
			if #runtime.searchPoints == 0 then
				return false
			end
		end
		local points = runtime.searchPoints
		local bestIndex, bestDistance
		for index, candidate in ipairs(points) do
			local distance = (candidate - root.Position).Magnitude
			if not bestDistance or distance < bestDistance then
				bestIndex, bestDistance = index, distance
			end
		end
		point = table.remove(points, bestIndex)
		runtime.searchPoint = point
	end
	local flat = Vector3.new(point.X - root.Position.X, 0, point.Z - root.Position.Z)
	holdPose(root, point, point + (if flat.Magnitude > 0.05 then flat.Unit else Vector3.zAxis), Vector3.yAxis)
	return true
end

function runtime.retreatSpotFrom(origin)
	local push = Vector3.zero
	for _, enemy in pairs(EnemyStore.store.state:getAll()) do
		if enemy.health:get() > 0 then
			local offset = origin - enemy.position:get()
			local flat = Vector3.new(offset.X, 0, offset.Z)
			if flat.Magnitude < 80 then
				push += (if flat.Magnitude > 0.05 then flat.Unit else Vector3.xAxis) * (80 - flat.Magnitude)
			end
		end
	end
	local away = if push.Magnitude > 0.05 then push.Unit * 40 else Vector3.zero
	return origin + away + Vector3.new(0, Flags.RetreatHeight, 0)
end

function runtime.retreatThreatened(spot)
	for _, enemy in pairs(EnemyStore.store.state:getAll()) do
		if enemy.health:get() > 0 then
			local offset = enemy.position:get() - spot
			if Vector3.new(offset.X, 0, offset.Z).Magnitude < 25 then
				return true
			end
		end
	end
	return false
end

local function updateRetreat(root, humanoid)
	if not Flags.AutoRetreat or humanoid.Health <= 0 then
		if runtime.retreating then
			runtime.retreating = false
			runtime.retreatSpot = nil
			releasePose()
		end
		return false
	end
	local clock = os.clock()
	local ratio = humanoid.Health / math.max(humanoid.MaxHealth, 1) * 100
	if runtime.retreating then
		local timedOut = clock - runtime.retreatAt >= Flags.RetreatMaxSeconds
		if ratio >= math.max(Flags.RetreatResume, Flags.RetreatHealth + 5) or timedOut then
			runtime.retreating = false
			runtime.retreatSpot = nil
			if timedOut then
				runtime.retreatBlockUntil = clock + 20
			end
			releasePose()
			return false
		end
	elseif ratio <= Flags.RetreatHealth and clock >= runtime.retreatBlockUntil then
		if Flags.RetreatAction == "Leave Run" then
			local startedAt = runState().startedAt:get()
			if startedAt and runtime.retreatLeftAt ~= startedAt then
				runtime.retreatLeftAt = startedAt
				RunPackets.endAction:fire(LEAVE_ACTION)
			end
			return true
		end
		runtime.retreating = true
		runtime.retreatAt = clock
		runtime.retreatCheckAt = clock
		runtime.retreatSpot = runtime.retreatSpotFrom(root.Position)
	end
	if not runtime.retreating then
		return false
	end
	if clock - runtime.retreatCheckAt >= 1 then
		runtime.retreatCheckAt = clock
		if runtime.retreatThreatened(runtime.retreatSpot) then
			runtime.retreatSpot = runtime.retreatSpotFrom(runtime.retreatSpot - Vector3.new(0, Flags.RetreatHeight, 0))
		end
	end
	runtime.target = nil
	runtime.anchorId = nil
	runtime.targetGap = math.huge
	local look = root.CFrame.LookVector
	holdPose(root, runtime.retreatSpot, runtime.retreatSpot + Vector3.new(look.X, 0, look.Z) + Vector3.new(0, 0, 0.01), Vector3.yAxis)
	return true
end

function runtime.comboFromText(text)
	local order = {}
	for token in string.gmatch(string.lower(tostring(text or "")), "%w+") do
		local slot = if token == "u" or token == "ult" or token == "ultimate" then 4 else tonumber(token)
		if slot and SKILL_SLOT["Skill " .. slot] or slot == 4 then
			table.insert(order, slot)
		end
	end
	return order
end

function runtime.activeSkillSlots()
	if Flags.SkillCombo then
		local order = Flags.ComboOrder
		if #order == 0 then
			return {}
		end
		if runtime.comboIndex > #order then
			runtime.comboIndex = 1
		end
		return { order[runtime.comboIndex] }
	end
	return Flags.SkillSlots
end

function runtime.skillCooldown(store, slot)
	local character = store.state.character:get()
	local ok, key = pcall(PlayerNamespace.skillCooldownKey, character, slot)
	return store.state.cooldowns:get(if ok and type(key) == "string" then key else "skill" .. slot)
end

function runtime.ultReady(store)
	return (tonumber(store.state.ultProgress:get()) or 0) >= 100 and LocalPlayer:GetAttribute("UltimateLocked") ~= true
end

local function skillReady(store)
	if not Flags.AutoSkill then
		return false
	end
	if Flags.AutoSkillG and runtime.ultReady(store) and runtime.ultAllowed() then
		return true
	end
	local now = Workspace:GetServerTimeNow()
	for _, slot in ipairs(runtime.activeSkillSlots()) do
		if slot == 4 then
			if runtime.ultReady(store) and runtime.ultAllowed() then
				return true
			end
		else
			local cooldown = runtime.skillCooldown(store, slot)
			local till = cooldown and cooldown:get()
			if not till or till <= now then
				return true
			end
		end
	end
	return false
end

function runtime.areaBlocker(area)
	local mapConfig = Maps and Maps.mapsByName[Maps.currentMap]
	local areaConfig = mapConfig and mapConfig.areas[area]
	local mapFolder = Workspace:FindFirstChild("World") and Workspace.World:FindFirstChild("Map")
	local border = areaConfig and areaConfig.border and mapFolder and mapFolder:FindFirstChild(areaConfig.border)
	if not border then
		return nil
	end
	local maxHealth = border:GetAttribute("RubbleMaxHealth")
	local health = border:GetAttribute("RubbleHealth") or maxHealth
	if maxHealth == nil or (tonumber(health) or 0) <= 0 then
		return nil
	end
	return border:FindFirstChild("Blocker")
end

function runtime.rubbleFor(area, state, root)
	local wave = state.wave:get()
	local waveCount = state.waveCount:get()
	if wave <= 0 or waveCount <= 0 or wave < waveCount or state.remaining:get() > 0 then
		return nil
	end
	if enemiesWithin(root.Position, math.huge) > 0 then
		return nil
	end
	return runtime.liveRubble(runtime.areaBlocker(area))
end

function runtime.liveRubble(blocker)
	if blocker and blocker.Parent and blocker:IsA("BasePart") and blocker.CanCollide then
		return blocker
	end
	return nil
end

function runtime.holdRubble(root, blocker)
	local center = blocker.Position
	if runtime.anchorId ~= blocker then
		runtime.anchorId = blocker
		local away = Vector3.new(root.Position.X - center.X, 0, root.Position.Z - center.Z)
		runtime.anchorDir = if away.Magnitude > 0.05 then away.Unit else Vector3.zAxis
	end
	holdPose(root, center, center - runtime.anchorDir, Vector3.yAxis)
end

function runtime.raidExit()
	if Workspace:GetAttribute("RaidExitOpen") ~= true then
		return nil
	end
	local markers = Workspace:FindFirstChild("World") and Workspace.World:FindFirstChild("Markers")
	local exit = markers and markers:FindFirstChild("Exit")
	local prompt = exit and exit:FindFirstChild("ExitPrompt")
	if exit and exit:IsA("BasePart") and prompt and prompt:IsA("ProximityPrompt") and prompt.Enabled then
		return exit, prompt
	end
	return nil
end

function runtime.useRaidExit(root, exit, prompt)
	local look = root.CFrame.LookVector
	local flat = Vector3.new(look.X, 0, look.Z)
	local spot = exit.Position
	holdPose(root, spot, spot + (if flat.Magnitude > 0.05 then flat.Unit else Vector3.zAxis), Vector3.yAxis)
	if (root.Position - spot).Magnitude > prompt.MaxActivationDistance - 2 or os.clock() - runtime.exitAt < 2 then
		return
	end
	runtime.exitAt = os.clock()
	if typeof(fireproximityprompt) == "function" then
		pcall(fireproximityprompt, prompt)
	else
		pcall(function()
			prompt:InputHoldBegin()
			task.wait(prompt.HoldDuration + 0.05)
			prompt:InputHoldEnd()
		end)
	end
end

function runtime.ariseSpot(root)
	local folder = Workspace:FindFirstChild("AriseShadows")
	if not folder then
		return nil
	end
	local now = Workspace:GetServerTimeNow()
	local best, bestPrompt, bestGap
	for _, spot in ipairs(folder:GetChildren()) do
		local prompt = spot:FindFirstChildWhichIsA("ProximityPrompt", true)
		local expires = spot:GetAttribute("ExpiresAt")
		if prompt and prompt.Enabled and spot:GetAttribute("RaisedBy") == nil
			and (type(expires) ~= "number" or expires > now)
			and os.clock() - (runtime.ariseTried[spot] or 0) > 3 then
			local gap = (spot:GetPivot().Position - root.Position).Magnitude
			if not bestGap or gap < bestGap then
				best, bestPrompt, bestGap = spot, prompt, gap
			end
		end
	end
	return best, bestPrompt
end

function runtime.stepArise(root)
	if not Flags.AutoArise then
		return false
	end
	local spot, prompt = runtime.ariseSpot(root)
	if not spot then
		return false
	end
	local position = spot:GetPivot().Position
	local look = root.CFrame.LookVector
	local flat = Vector3.new(look.X, 0, look.Z)
	holdPose(root, position + Vector3.new(0, 3, 0), position + Vector3.new(0, 3, 0) + (if flat.Magnitude > 0.05 then flat.Unit else Vector3.zAxis), Vector3.yAxis)
	if (root.Position - position).Magnitude > prompt.MaxActivationDistance - 1 then
		return true
	end
	runtime.ariseTried[spot] = os.clock()
	if typeof(fireproximityprompt) == "function" then
		pcall(fireproximityprompt, prompt)
	else
		pcall(function()
			prompt:InputHoldBegin()
			task.wait(prompt.HoldDuration + 0.05)
			prompt:InputHoldEnd()
		end)
	end
	return true
end

function runtime.igrisThreats()
	local threats = {}
	for _, enemy in pairs(EnemyStore.store.state:getAll()) do
		local name = enemy.name:get()
		if enemy.health:get() > 0 and string.sub(tostring(name), 1, 9) == "soloIgris" then
			local started = enemy.attackStartedAt:get()
			local info = Enemies.enemiesByName[name]
			local attack = started and info and info.attacks and info.attacks[enemy.attackIndex:get()]
			if attack then
				local kind = runtime.igrisDanger(attack, Workspace:GetServerTimeNow() - started)
				if kind then
					local look = enemy.attackCFrame:get().LookVector
					local flat = Vector3.new(look.X, 0, look.Z)
					local position = enemy.position:get()
					table.insert(threats, {
						attack = attack,
						kind = kind,
						position = Vector3.new(position.X, 0, position.Z),
						look = if flat.Magnitude > 0.05 then flat.Unit else Vector3.zAxis,
					})
				end
			end
		end
	end
	return threats
end

function runtime.igrisDanger(attack, age)
	local lunge = attack.lunge
	if lunge then
		local start = tonumber(lunge.start) or 4.45
		if age >= start - 0.6 and age <= (tonumber(attack.hitTime) or start) + 0.3 then
			return "lunge"
		end
	end
	local spikes = attack.spikes
	if spikes then
		local first = tonumber(spikes.first) or 1
		local last = first + (tonumber(spikes.telegraph) or 1) + (tonumber(spikes.gap) or 0.5) * ((tonumber(spikes.waves) or 1) - 1)
		if age >= first - 0.3 and age <= last + 0.4 then
			return "spikes"
		end
	end
	local times = {}
	if type(attack.hits) == "table" then
		for _, hit in ipairs(attack.hits) do
			table.insert(times, tonumber(hit.time))
		end
	else
		table.insert(times, tonumber(attack.hitTime))
	end
	if type(attack.slam) == "table" then
		table.insert(times, tonumber(attack.slam.time))
	end
	for _, time in ipairs(times) do
		if age >= time - 0.45 and age <= time + 0.25 then
			return "melee"
		end
	end
	return nil
end

function runtime.flatGap(from, to, point)
	local line = to - from
	local length = line.Magnitude
	if length < 0.05 then
		return (point - from).Magnitude
	end
	local along = math.clamp((point - from):Dot(line) / (length * length), 0, 1)
	return (point - (from + line * along)).Magnitude
end

function runtime.dodgeUnsafe(point, threats)
	local flat = Vector3.new(point.X, 0, point.Z)
	for _, threat in ipairs(threats) do
		local offset = flat - threat.position
		local distance = offset.Magnitude
		local lunge = threat.attack.lunge
		if distance < (if threat.kind == "lunge" then (tonumber(lunge.distance) or 60) + 25 else 32) then
			return true
		end
		local spikes = threat.attack.spikes
		if threat.kind == "spikes" and distance < (tonumber(spikes.range) or 120) + 15 then
			local spread = (spikes.lanes and tonumber(spikes.lanes.spreadAngle)) or tonumber(spikes.spread) or 45
			if offset.Unit:Dot(threat.look) > math.cos(math.rad(spread / 2 + 20)) then
				return true
			end
		end
	end
	return false
end

function runtime.dodgeGround(character, point)
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = { character, Workspace:FindFirstChild("enemies") }
	return Workspace:Raycast(point + Vector3.new(0, 6, 0), Vector3.new(0, -80, 0), params) ~= nil
end

function runtime.stepDodge(root)
	if not Flags.AutoDodgeIgris then
		runtime.dodging = false
		runtime.dodgeSpot = nil
		return false
	end
	local threats = runtime.igrisThreats()
	if #threats == 0 then
		runtime.dodging = false
		runtime.dodgeSpot = nil
		return false
	end
	local spot = runtime.dodgeSpot
	if not spot or runtime.dodgeUnsafe(spot, threats) then
		spot = nil
		if not runtime.dodgeUnsafe(root.Position, threats) then
			spot = root.Position
		else
			local here = Vector3.new(root.Position.X, 0, root.Position.Z)
			local best, bestCost
			for _, radius in ipairs({ 30, 50, 75, 100, 130 }) do
				for step = 0, 23 do
					local angle = step * math.pi / 12
					local candidate = root.Position + Vector3.new(math.cos(angle), 0, math.sin(angle)) * radius
					if not runtime.dodgeUnsafe(candidate, threats) and runtime.dodgeGround(root.Parent, candidate) then
						local cost = radius
						local flat = Vector3.new(candidate.X, 0, candidate.Z)
						for _, threat in ipairs(threats) do
							if runtime.flatGap(here, flat, threat.position) < 15 then
								cost += 200
							end
						end
						if not bestCost or cost < bestCost then
							best, bestCost = candidate, cost
						end
					end
				end
				if bestCost and bestCost < 200 then
					break
				end
			end
			spot = best
		end
		runtime.dodgeSpot = spot
	end
	if not spot then
		runtime.dodging = false
		return false
	end
	spot = Vector3.new(spot.X, root.Position.Y, spot.Z)
	local nearest, nearestGap
	for _, threat in ipairs(threats) do
		local gap = (threat.position - Vector3.new(spot.X, 0, spot.Z)).Magnitude
		if not nearestGap or gap < nearestGap then
			nearest, nearestGap = threat.position, gap
		end
	end
	local focus = Vector3.new(nearest.X, spot.Y, nearest.Z)
	if (focus - spot).Magnitude < 0.05 then
		focus = spot + Vector3.zAxis
	end
	runtime.dodging = true
	runtime.target = nil
	runtime.anchorId = nil
	runtime.targetGap = math.huge
	holdPose(root, spot, focus, Vector3.yAxis)
	return true
end

function runtime.refreshPose()
	runtime.anchorId = nil
	releasePose()
end

local function stepFarm()
	local character, root, humanoid = characterParts()
	if not root or not inActiveRun() then
		runtime.retreating = false
		runtime.target = nil
		runtime.anchorId = nil
		runtime.targetGap = math.huge
		runtime.rubble = nil
		runtime.searchPoints = nil
		runtime.idleSince = nil
		releasePose()
		return
	end
	if updateRetreat(root, humanoid) then
		runtime.rubble = nil
		return
	end
	if runtime.stepDodge(root) then
		runtime.rubble = nil
		return
	end
	if runtime.stepArise(root) then
		runtime.anchorId = nil
		return
	end
	local exit, prompt = runtime.raidExit()
	if exit and enemiesWithin(root.Position, math.huge) == 0 then
		runtime.target = nil
		runtime.anchorId = nil
		runtime.targetGap = math.huge
		runtime.rubble = nil
		runtime.idleSince = nil
		runtime.useRaidExit(root, exit, prompt)
		return
	end
	local state = runState()
	local clock = os.clock()
	local wave = state.wave:get()
	local waveCount = state.waveCount:get()
	local totalAlive = aliveEnemyCount()
	local betweenAreas = (state.remaining:get() == 0 or totalAlive == 0)
		and state.startedAt:get() ~= nil
		and state.finishedAt:get() == nil
		and (wave == 0 or (waveCount > 0 and wave >= waveCount))
	if betweenAreas then
		runtime.target = nil
		runtime.targetGap = math.huge
		local area = state.area:get()
		if runtime.wallArea ~= area then
			runtime.wallArea = area
			runtime.wallTries = 0
		end
		local blocker = runtime.rubbleFor(area, state, root)
		runtime.rubble = blocker or nil
		if blocker then
			runtime.idleSince = nil
			runtime.emptySince = nil
			runtime.searchPoints = nil
			runtime.holdRubble(root, blocker)
			local store = PlayerNamespace.getLocalPlayerStore()
			if store and not store.state.blocking:get() and not store.state.cooldowns:get("m1") then
				CharacterPackets.performM1:fire()
			end
			return
		end
		local target = areaEntryPosition(area + 1, character) or areaEntryPosition(area, character)
		if target and (target - root.Position).Magnitude > 15 then
			if runtime.wallTries < 4 and clock - runtime.wallAt >= 1.2 then
				tweenTo(root, CFrame.new(target + Vector3.new(0, 3.5, 0)), true)
				runtime.wallTries += 1
				runtime.wallAt = os.clock()
				return
			end
		end
		runtime.anchorId = nil
		if totalAlive == 0 then
			runtime.emptySince = runtime.emptySince or clock
			if clock - runtime.emptySince >= (Flags.EmptyRoomLeaveDelay or 4) and (Flags.AutoLeave or Flags.AutoFarm) then
				local startedAt = state.startedAt:get()
				if startedAt and runtime.leftRunAt ~= startedAt then
					runtime.leftRunAt = startedAt
					RunPackets.endAction:fire(LEAVE_ACTION)
				end
				return
			end
		else
			runtime.emptySince = nil
		end
		if runtime.failsafe(root, character, area, clock) then
			return
		end
		runtime.holdSafe(root, character, area)
		return
	end
	runtime.wallTries = 0
	runtime.rubble = nil
	local id, position = nearestEnemy(root.Position)
	runtime.target = id
	if id then
		runtime.idleSince = nil
		runtime.emptySince = nil
		runtime.searchPoints = nil
	else
		runtime.anchorId = nil
		runtime.targetGap = math.huge
		local area = state.area:get()
		local blocker = runtime.rubbleFor(area, state, root)
		if blocker then
			runtime.idleSince = nil
			runtime.emptySince = nil
			runtime.rubble = blocker
			runtime.holdRubble(root, blocker)
			return
		end
		local totalAlive = aliveEnemyCount()
		if totalAlive == 0 then
			runtime.emptySince = runtime.emptySince or clock
			local target = areaEntryPosition(area + 1, character) or areaEntryPosition(area, character)
			if target and (target - root.Position).Magnitude > 15 and (clock - runtime.emptySince < 2.5) then
				tweenTo(root, CFrame.new(target + Vector3.new(0, 3.5, 0)), true)
				return
			end
			if clock - runtime.emptySince >= (Flags.EmptyRoomLeaveDelay or 4) then
				if Flags.AutoLeave or Flags.AutoFarm then
					local startedAt = state.startedAt:get()
					if startedAt and runtime.leftRunAt ~= startedAt then
						runtime.leftRunAt = startedAt
						RunPackets.endAction:fire(LEAVE_ACTION)
					end
					return
				end
			end
		else
			runtime.emptySince = nil
		end
		if runtime.failsafe(root, character, area, clock) then
			return
		end
		runtime.stepLivelyMovement(root, character, area, clock)
		return
	end
	local health = EnemyStore.store.state:get(id).health:get()
	if runtime.watchId ~= id or runtime.watchHealth ~= health then
		runtime.watchId = id
		runtime.watchHealth = health
		runtime.watchAt = clock
	elseif clock - runtime.watchAt >= 10 then
		runtime.skip[id] = clock + 15
		runtime.watchId = nil
		runtime.anchorId = nil
		releasePose()
		return
	end
	local dt = math.min(clock - runtime.lastTick, 0.2)
	runtime.lastTick = clock
	if runtime.anchorId ~= id then
		runtime.anchorId = id
		local away = Vector3.new(root.Position.X - position.X, 0, root.Position.Z - position.Z)
		runtime.anchorDir = if away.Magnitude > 0.05 then away.Unit else Vector3.zAxis
		runtime.orbitAngle = math.atan2(runtime.anchorDir.Z, runtime.anchorDir.X)
	end
	local desired, focus, up = runtime.farmPose(position, dt)
	holdPose(root, desired, focus, up)
	local gap = (desired - position).Magnitude
	runtime.targetGap = gap
	if Flags.DynamicMovement and (root.Position - position).Magnitude > 14 and (clock - (runtime.lastCombatDash or 0) > 1.2) then
		if runtime.performDash(position) then
			runtime.lastCombatDash = clock
		end
	end
	local store = PlayerNamespace.getLocalPlayerStore()
	if store and skillReady(store) and targetsWithin(root.Position, Flags.SkillRange) >= Flags.SkillMinEnemies then
		if runtime.skillReadyAt == 0 then
			runtime.skillReadyAt = clock
		end
		if clock - runtime.skillReadyAt < 0.6 then
			return
		end
	else
		runtime.skillReadyAt = 0
	end
	if store and not store.state.blocking:get() and not store.state.cooldowns:get("m1") then
		CharacterPackets.performM1:fire()
	end
end

function runtime.ultAllowed()
	return not Flags.UltBossOnly or runtime.targetIsBoss()
end

function runtime.targetIsBoss()
	local id = runtime.target
	local enemy = id and EnemyStore.store.state:get(id)
	local info = enemy and Enemies.enemiesByName[enemy.name:get()]
	return info ~= nil and info.boss == true
end

local function stepSkill()
	local _, root = characterParts()
	if not root or not inActiveRun() or runtime.retreating then
		return
	end
	if targetsWithin(root.Position, Flags.SkillRange) < Flags.SkillMinEnemies then
		return
	end
	local store = PlayerNamespace.getLocalPlayerStore()
	local now = Workspace:GetServerTimeNow()
	if (Flags.AutoSkillG or Flags.UltBossPriority) and store and runtime.ultReady(store) and runtime.ultAllowed() then
		local ok, started = pcall(CharacterController.performSkill, 4)
		if ok and started then
			runtime.skillReadyAt = 0
			task.wait(0.05)
			return
		end
	end
	if Flags.SkillCombo then
		local slots = runtime.activeSkillSlots()
		local slot = slots[1]
		local clock = os.clock()
		if not slot or clock - runtime.comboCastAt < Flags.ComboDelay then
			return
		end
		if slot == 4 and not runtime.ultAllowed() then
			runtime.comboIndex += 1
			runtime.comboSince = nil
			return
		end
		local cooldown = store and slot ~= 4 and runtime.skillCooldown(store, slot)
		local till = cooldown and cooldown:get()
		if till and till > now then
			runtime.comboSince = nil
			return
		end
		runtime.comboSince = runtime.comboSince or clock
		local ok, started = pcall(CharacterController.performSkill, slot)
		if ok and started then
			runtime.comboIndex += 1
			runtime.comboSince = nil
			runtime.comboCastAt = clock
			runtime.skillReadyAt = 0
			task.wait(0.05)
		elseif clock - runtime.comboSince >= 3 then
			runtime.comboIndex += 1
			runtime.comboSince = nil
		end
		return
	end
	for _, slot in ipairs(Flags.SkillSlots) do
		local ready = false
		if slot == 4 then
			ready = runtime.ultReady(store) and runtime.ultAllowed()
		else
			local cooldown = store and runtime.skillCooldown(store, slot)
			local till = cooldown and cooldown:get()
			ready = not till or till <= now
		end
		if ready then
			local ok, started = pcall(CharacterController.performSkill, slot)
			if ok and started then
				runtime.skillReadyAt = 0
				task.wait(0.05)
				return
			end
		end
	end
end

local function skillsOnCooldown()
	local store = PlayerNamespace.getLocalPlayerStore()
	if not store or #Flags.SkillSlots == 0 then
		return false
	end
	local now = Workspace:GetServerTimeNow()
	for _, slot in ipairs(Flags.SkillSlots) do
		if slot ~= 4 then
			local cooldown = runtime.skillCooldown(store, slot)
			local till = cooldown and cooldown:get()
			if not till or till <= now then
				return false
			end
		elseif Flags.SwitchUltMode == "Consider Ultimates" and runtime.ultReady(store) and runtime.ultAllowed() then
			return false
		end
	end
	return true
end

local function stepSwitch()
	local _, root = characterParts()
	if not root or not inActiveRun() or runtime.retreating then
		return
	end
	local clock = os.clock()
	if clock - runtime.switchAt < 1 then
		return
	end
	local store = PlayerNamespace.getLocalPlayerStore()
	local gate = store and store.state.cooldowns:get("characterSwitch")
	local till = gate and gate:get()
	if till and till > Workspace:GetServerTimeNow() then
		return
	end
	if targetsWithin(root.Position, Flags.SkillRange) < 1 or not skillsOnCooldown() then
		return
	end
	runtime.switchAt = clock
	pcall(CharacterController.performSwitch)
end

local function stepRecord()
	local participant = myParticipant()
	if not participant then
		return
	end
	local status = participant.status:get()
	if status ~= "victory" and status ~= "failed" then
		return
	end
	local key = tostring(runState().startedAt:get()) .. status
	if runtime.recordedKey == key then
		return
	end
	runtime.recordedKey = key
	runtime.runsDone += 1
	recordRun(participant)
end

local function stepRun()
	local participant = myParticipant()
	if not participant then
		return
	end
	local state = runState()
	local clock = os.clock()
	local finishedAt = state.finishedAt:get()
	local status = participant.status:get()
	local isFinished = (finishedAt ~= nil)
		or (status ~= "active")
		or (LocalPlayer.PlayerGui and LocalPlayer.PlayerGui:GetAttribute("EndScreenActive") == true)
		or (LocalPlayer.PlayerGui and LocalPlayer.PlayerGui:FindFirstChild("EndScreen") and LocalPlayer.PlayerGui.EndScreen.Enabled)

	if not isFinished then
		runtime.resultKey = nil
		local startedAt = state.startedAt:get()
		if
			Flags.AutoLeaveRun
			and startedAt
			and runtime.leftRunAt ~= startedAt
			and Workspace:GetServerTimeNow() - startedAt >= Flags.LeaveMinutes * 60
		then
			runtime.leftRunAt = startedAt
			RunPackets.endAction:fire(LEAVE_ACTION)
		end
		return
	end
	if participant.travelStatus:get() ~= "idle" then
		return
	end
	stepRecord()
	local key = finishedAt or (if status ~= "active" then status else "finished")
	if runtime.resultKey ~= key then
		runtime.resultKey = key
		runtime.resultSeenAt = clock
		runtime.resultActedKey = nil
	end
	if clock - runtime.resultSeenAt < Flags.ResultDelay then
		return
	end
	if runtime.resultActedKey == key and clock - runtime.resultActedAt < 6 then
		return
	end
	local action
	if Flags.AutoLeaveRuns and runtime.runsDone >= Flags.LeaveRuns then
		action = LEAVE_ACTION
	elseif Flags.AutoNextChapter and (state.canNext and state.canNext:get()) then
		action = 2
	elseif Flags.AutoRetry then
		action = 1
	elseif Flags.AutoLeave or Flags.AutoFarm then
		action = LEAVE_ACTION
	end
	if not action then
		return
	end
	runtime.resultActedKey = key
	runtime.resultActedAt = clock
	RunPackets.endAction:fire(action)
end

local function startWorker(name, interval, gate, step)
	task.spawn(function()
		while not API.Unloaded do
			if gate() then
				local ok, err = pcall(step)
				if not ok then
					warn("[" .. GAME_NAME .. "] " .. name .. ": " .. tostring(err))
					task.wait(1)
				end
			end
			task.wait(interval)
		end
	end)
end

if IN_RUN then
	startWorker("Farm", 0, function()
		return Flags.AutoFarm
	end, stepFarm)
	startWorker("Arise", 0.1, function()
		return Flags.AutoArise and not Flags.AutoFarm
	end, function()
		local _, root = characterParts()
		local busy = root ~= nil and inActiveRun() and runtime.stepArise(root)
		if runtime.arising and not busy then
			releasePose()
		end
		runtime.arising = busy
	end)
	startWorker("Dodge", 0, function()
		return Flags.AutoDodgeIgris and not Flags.AutoFarm
	end, function()
		local _, root = characterParts()
		local was = runtime.dodging
		local busy = root ~= nil and inActiveRun() and runtime.stepDodge(root)
		if was and not busy then
			runtime.dodging = false
			releasePose()
		end
	end)
	startWorker("Skill", 0.03, function()
		return Flags.AutoSkill
	end, stepSkill)
	startWorker("Switch", 0.25, function()
		return Flags.SwitchOnCooldown
	end, stepSwitch)
	startWorker("Record", 0.5, function()
		return true
	end, stepRecord)
	startWorker("Run", 0.5, function()
		return Flags.AutoNextChapter or Flags.AutoRetry or Flags.AutoLeave or Flags.AutoLeaveRun or Flags.AutoLeaveRuns
	end, stepRun)
end

API.Track(function()
	releasePose()
	Flags.AutoFarm = false
	Flags.AutoArise = false
	Flags.AutoSkill = false
	Flags.AutoRetreat = false
	Flags.SwitchOnCooldown = false
	Flags.AutoNextChapter = false
	Flags.AutoRetry = false
	Flags.AutoLeave = false
	Flags.AutoLeaveRun = false
	Flags.AutoLeaveRuns = false
	Flags.AutoDodgeIgris = false
end)


local lobby = {
	requestId = 0,
	queueStatus = "idle",
	windowRoom = nil,
	summonId = nil,
	summonSentAt = 0,
	summonDone = true,
	pending = {},
	joinAt = 0,
	joinTries = 0,
	codesBusy = false,
	traitId = nil,
	traitSentAt = 0,
	traitDone = true,
	skillPending = nil,
	skillSentAt = 0,
	summonCount = 0,
	summonLast = "-",
	traitCount = 0,
	traitLast = "-",
	emoteId = nil,
	emoteSentAt = 0,
	emoteDone = true,
	emoteCount = 0,
	emoteLast = "-",
	unlockSentAt = 0,
	convertSentAt = 0,
	skipLabels = {},
	joinLabel = nil,
	joinLabelAt = 0,
}

local GAMEMODE_LABELS = {}
local GAMEMODE_CHOICES = {}
local CHAPTER_LABELS = {}
local RARITY_OPTIONS = { "None" }
local DIFFICULTY_LABELS = { "Easy", "Medium", "Hard", "Nightmare" }
local DIFFICULTY_INDEX = { Easy = 1, Medium = 2, Hard = 3, Nightmare = 4 }
local DIFFICULTY_GAMEMODES = { Story = true, Defend = true }
local CHARACTER_IDS = {}
local TRAIT_LABELS = {}
local TRAIT_BY_LABEL = {}
local CRAFT_LABELS = {}
local CRAFT_BY_LABEL = {}
local BRANCH_LABELS = {}
gacha.TRAIT_CHARACTER_OPTIONS = { "Equipped Character" }
gacha.TRAIT_RARITY_OPTIONS = { "None" }
gacha.TRAIT_RARITY_RANK = {}
gacha.EMOTE_NAMES = {}
gacha.EMOTE_RARITY = {}
gacha.EMOTE_RARITY_OPTIONS = { "None" }
gacha.EMOTE_RARITY_RANK = {}
if IN_LOBBY then
	local maxChapter = 1
	local ids = {}
	for id in pairs(GamemodeEnum.Gamemode) do
		table.insert(ids, id)
	end
	table.sort(ids)
	for _, gamemode in ipairs(ids) do
		local mapIds = {}
		for _, entry in pairs(GamemodeEnum.Gamemode[gamemode].Maps) do
			local mapId = if type(entry) == "table" then entry.Id else entry
			if type(mapId) == "string" then
				table.insert(mapIds, mapId)
			end
		end
		table.sort(mapIds)
		for _, mapId in ipairs(mapIds) do
			local info = GamemodeEnum.Map[gamemode .. "_" .. mapId]
			local label = gamemode .. " - " .. (info and info.DisplayName or mapId)
			local chapters = 0
			if info and info.Chapters then
				for chapter in pairs(info.Chapters) do
					chapters = math.max(chapters, tonumber(chapter) or 0)
				end
			end
			maxChapter = math.max(maxChapter, chapters)
			table.insert(GAMEMODE_LABELS, label)
			GAMEMODE_CHOICES[label] = {
				gamemode = gamemode,
				map = mapId,
				chapters = chapters,
				fixedDifficulty = tonumber(GamemodeEnum.Gamemode[gamemode].FixedDifficulty),
			}
		end
	end
	table.insert(CHAPTER_LABELS, "Highest Unlocked")
	for chapter = 1, maxChapter do
		table.insert(CHAPTER_LABELS, tostring(chapter))
	end
	for _, rarity in ipairs(RollConfig.rarityOrder) do
		table.insert(RARITY_OPTIONS, rarity)
	end
	Flags.JoinChoice = GAMEMODE_LABELS[1]
	for id in pairs(SkillTreeConfig.characters) do
		table.insert(CHARACTER_IDS, id)
	end
	table.sort(CHARACTER_IDS)
	for _, trait in pairs(TraitConfig) do
		if type(trait) == "table" and trait.Enabled ~= false and trait.Name then
			local label = trait.Name .. " (" .. tostring(trait.Rarity) .. ")"
			table.insert(TRAIT_LABELS, label)
			TRAIT_BY_LABEL[label] = tonumber(trait.Id)
		end
	end
	table.sort(TRAIT_LABELS)
	for _, rarity in ipairs({ "Common", "Uncommon", "Rare", "Epic", "Legendary", "Exotic", "Mythic", "Arcane", "Zenless" }) do
		for _, trait in pairs(TraitConfig) do
			if type(trait) == "table" and trait.Rarity == rarity and trait.Enabled ~= false then
				table.insert(gacha.TRAIT_RARITY_OPTIONS, rarity)
				break
			end
		end
		for _, emote in ipairs(EmotesConfig) do
			if emote.rarity == rarity then
				table.insert(gacha.EMOTE_RARITY_OPTIONS, rarity)
				break
			end
		end
	end
	for _, emote in ipairs(EmotesConfig) do
		table.insert(gacha.EMOTE_NAMES, emote.name)
		gacha.EMOTE_RARITY[emote.name] = emote.rarity
	end
	for key, recipe in pairs(CraftConfig) do
		local accessory = AccessoryConfig[recipe.CarftID]
		if accessory and accessory.Name then
			local needs = {}
			for pair in string.gmatch(tostring(recipe.Misc or ""), "[^|]+") do
				local material, amount = string.match(pair, "^%s*([^,]+)%s*,%s*(%d+)")
				if material then
					table.insert(needs, { id = material, amount = tonumber(amount) })
				end
			end
			table.insert(CRAFT_LABELS, accessory.Name)
			CRAFT_BY_LABEL[accessory.Name] = { key = tostring(key), accessory = tostring(recipe.CarftID), needs = needs }
		end
	end
	table.sort(CRAFT_LABELS)
	for _, branch in ipairs(SkillTreeConfig.branchOrder) do
		table.insert(BRANCH_LABELS, branch)
	end
end

do
	local LOBBY_OPTIONS_FILE = STATS_FOLDER .. "/lobby_options.json"
	if IN_LOBBY then
		pcall(function()
			if not hasFiles then
				return
			end
			if typeof(makefolder) == "function" and typeof(isfolder) == "function" then
				if not isfolder("Relwx") then
					makefolder("Relwx")
				end
				if not isfolder(STATS_FOLDER) then
					makefolder(STATS_FOLDER)
				end
			end
			writefile(LOBBY_OPTIONS_FILE, HttpService:JSONEncode({
				gamemodeLabels = GAMEMODE_LABELS,
				gamemodeChoices = GAMEMODE_CHOICES,
				chapterLabels = CHAPTER_LABELS,
				rarityOptions = RARITY_OPTIONS,
				characterIds = CHARACTER_IDS,
				traitLabels = TRAIT_LABELS,
				traitByLabel = TRAIT_BY_LABEL,
				craftLabels = CRAFT_LABELS,
				craftByLabel = CRAFT_BY_LABEL,
				branchLabels = BRANCH_LABELS,
				traitRarityOptions = gacha.TRAIT_RARITY_OPTIONS,
				emoteNames = gacha.EMOTE_NAMES,
				emoteRarity = gacha.EMOTE_RARITY,
				emoteRarityOptions = gacha.EMOTE_RARITY_OPTIONS,
			}))
		end)
	else
		local ok, cached = pcall(function()
			if hasFiles and isfile(LOBBY_OPTIONS_FILE) then
				return HttpService:JSONDecode(readfile(LOBBY_OPTIONS_FILE))
			end
			return nil
		end)
		if ok and type(cached) == "table" then
			local function copyList(target, source)
				if type(source) == "table" then
					table.clear(target)
					for _, value in ipairs(source) do
						table.insert(target, value)
					end
				end
			end
			local function copyMap(target, source)
				if type(source) == "table" then
					for key, value in pairs(source) do
						target[key] = value
					end
				end
			end
			copyList(GAMEMODE_LABELS, cached.gamemodeLabels)
			copyMap(GAMEMODE_CHOICES, cached.gamemodeChoices)
			copyList(CHAPTER_LABELS, cached.chapterLabels)
			copyList(RARITY_OPTIONS, cached.rarityOptions)
			copyList(CHARACTER_IDS, cached.characterIds)
			copyList(TRAIT_LABELS, cached.traitLabels)
			copyMap(TRAIT_BY_LABEL, cached.traitByLabel)
			copyList(CRAFT_LABELS, cached.craftLabels)
			copyMap(CRAFT_BY_LABEL, cached.craftByLabel)
			copyList(BRANCH_LABELS, cached.branchLabels)
			copyList(gacha.TRAIT_RARITY_OPTIONS, cached.traitRarityOptions)
			copyList(gacha.EMOTE_NAMES, cached.emoteNames)
			copyMap(gacha.EMOTE_RARITY, cached.emoteRarity)
			copyList(gacha.EMOTE_RARITY_OPTIONS, cached.emoteRarityOptions)
			Flags.JoinChoice = GAMEMODE_LABELS[1]
		end
	end
end

for _, id in ipairs(CHARACTER_IDS) do
	table.insert(gacha.TRAIT_CHARACTER_OPTIONS, id)
end
for index, rarity in ipairs(gacha.TRAIT_RARITY_OPTIONS) do
	gacha.TRAIT_RARITY_RANK[rarity] = index
end
for index, rarity in ipairs(gacha.EMOTE_RARITY_OPTIONS) do
	gacha.EMOTE_RARITY_RANK[rarity] = index
end

local function nextRequestId()
	lobby.requestId = lobby.requestId % 65535 + 1
	return lobby.requestId
end

local function accountSnapshot()
	local ok, store = pcall(Account.getLocalPlayerAccount)
	if not ok or not store then
		return nil
	end
	local okTable, snapshot = pcall(store.toTable, store)
	return okTable and snapshot or nil
end

local function getDeliveryQuestCount()
	local ok, state = pcall(function()
		local account = Account.getLocalPlayerAccount()
		return account and account.state
	end)
	if not ok or type(state) ~= "table" then
		return 0
	end
	local quests = state.quests
	local progress = quests and quests.progress
	local entries = progress and progress.entries
	local value = entries and entries["delivery.dailyCount"]
	local count = (type(value) == "table" and (value.current or value.count)) or tonumber(value) or 0
	return math.max(0, tonumber(count) or 0)
end

local function playerLevel(snapshot)
	local ok, progress = pcall(Levels.getProgress, tonumber(snapshot.currencies.xp) or 0)
	return ok and type(progress) == "table" and tonumber(progress.level) or 0
end

local function notPending(key, seconds)
	local clock = os.clock()
	local sent = lobby.pending[key]
	if sent and clock - sent < seconds then
		return false
	end
	lobby.pending[key] = clock
	return true
end

local function stepMilestones()
	local snapshot = accountSnapshot()
	if not snapshot then
		return
	end
	local level = playerLevel(snapshot)
	for key in pairs(MilestoneConfig.milestones) do
		local milestone = tonumber(key)
		if milestone and milestone <= level and snapshot.claimedLevelMilestones[tostring(milestone)] ~= true then
			if notPending("milestone" .. milestone, 6) then
				LobbyPackets.claimLevelMilestone:fire({ level = milestone, requestId = nextRequestId() })
				task.wait(0.35)
			end
		end
	end
end

local function stepDaily()
	local snapshot = accountSnapshot()
	if not snapshot then
		return
	end
	local rewards = snapshot.dailyReward.rewards
	for day = 1, 7 do
		if (rewards[day] or rewards[tostring(day)]) == "available" and notPending("daily" .. day, 6) then
			LobbyPackets.claimDailyReward:fire(day)
			task.wait(0.5)
		end
	end
end

local function stepQuests()
	local snapshot = accountSnapshot()
	if not snapshot then
		return
	end
	local quests = snapshot.quests
	for id in pairs(QuestConfig.quests) do
		if quests.completed[id] == true and quests.claimed[id] ~= true and notPending("quest" .. id, 6) then
			LobbyPackets.claimQuestReward:fire({ questId = id, requestId = nextRequestId() })
			task.wait(0.4)
		end
	end
end

local function stepSummon()
	local clock = os.clock()
	if not lobby.summonDone and clock - lobby.summonSentAt < 8 then
		return
	end
	if clock - lobby.summonSentAt < Flags.SummonDelay then
		return
	end
	local snapshot = accountSnapshot()
	if not snapshot then
		return
	end
	local slot = snapshot.UnlockedCharacters["Slot" .. Flags.SummonSlot]
	if not slot or slot.Unlocked ~= true then
		return
	end
	local threshold = table.find(RollConfig.rarityOrder, Flags.ProtectRarity)
	local current = RollConfig.rarityByCharacter[slot.Character]
	local currentIndex = current and table.find(RollConfig.rarityOrder, current)
	if threshold and currentIndex and currentIndex >= threshold then
		return
	end
	if slot.Character ~= "" and table.find(Flags.SummonStopCharacters, slot.Character) then
		return
	end
	local costs = EconomyConfig.rollCosts.character
	local payment, need
	if Flags.SummonType == "Lucky" then
		payment, need = "luckySpins", costs.Lucky.amount
	elseif Flags.SummonPayment == "rolls" then
		payment, need = "rolls", costs.NormalDice.amount
	else
		payment, need = "money", costs.Normal.amount
	end
	if (tonumber(snapshot.currencies[payment]) or 0) < need then
		local conversion = EconomyConfig.currencyConversions.luckySpins
		local gems = tonumber(snapshot.currencies.gems) or 0
		if payment == "luckySpins" and Flags.SummonBuyLucky and gems >= conversion.cost.amount and clock - lobby.convertSentAt > 3 then
			lobby.convertSentAt = clock
			LobbyPackets.convertGemsToLuckySpins:fire({
				amount = math.min(10, math.floor(gems / conversion.cost.amount)),
				requestId = nextRequestId(),
			})
		end
		return
	end
	lobby.summonDone = false
	lobby.summonSentAt = clock
	lobby.summonId = nextRequestId()
	LobbyPackets.rollCharacter:fire({
		spinType = Flags.SummonType,
		slot = Flags.SummonSlot,
		paymentCurrency = payment,
		requestId = lobby.summonId,
	})
end

function gacha.traitById(id)
	for _, trait in pairs(id and TraitConfig or {}) do
		if type(trait) == "table" and tonumber(trait.Id) == id then
			return trait
		end
	end
	return nil
end

local function stepTrait()
	if not lobby.traitDone and os.clock() - lobby.traitSentAt < 7 then
		return
	end
	if os.clock() - lobby.traitSentAt < Flags.TraitDelay then
		return
	end
	local snapshot = accountSnapshot()
	local character = Flags.TraitCharacter
	if character == "Equipped Character" then
		character = snapshot and snapshot.character
	end
	local data = snapshot and character and snapshot.CharactersData[character]
	local minRank = gacha.TRAIT_RARITY_RANK[Flags.TraitStopRarity] or 1
	if not data or (#Flags.TraitTargets == 0 and minRank <= 1) then
		return
	end
	local current = tonumber(data.TraitData and data.TraitData.Trait)
	if current and table.find(Flags.TraitTargets, current) then
		return
	end
	local currentTrait = gacha.traitById(current)
	local currentRank = currentTrait and gacha.TRAIT_RARITY_RANK[currentTrait.Rarity]
	if minRank > 1 and currentRank and currentRank >= minRank then
		return
	end
	local cost = EconomyConfig.rollCosts.trait
	if (tonumber(snapshot.currencies[cost.currency]) or 0) < cost.amount then
		return
	end
	lobby.traitDone = false
	lobby.traitSentAt = os.clock()
	lobby.traitId = nextRequestId()
	LobbyPackets.rollTrait:fire({ character = character, requestId = lobby.traitId })
end

function gacha.emoteGoalReached(owned)
	if Flags.EmoteStopAllOwned and #gacha.EMOTE_NAMES > 0 then
		local all = true
		for _, name in ipairs(gacha.EMOTE_NAMES) do
			if not owned[name] then
				all = false
				break
			end
		end
		if all then
			return true
		end
	end
	for _, name in ipairs(Flags.EmoteTargets) do
		if owned[name] then
			return true
		end
	end
	local minRank = gacha.EMOTE_RARITY_RANK[Flags.EmoteStopRarity] or 1
	if minRank > 1 then
		for name, has in pairs(owned) do
			local rank = has and gacha.EMOTE_RARITY_RANK[gacha.EMOTE_RARITY[name]]
			if rank and rank >= minRank then
				return true
			end
		end
	end
	return false
end

function gacha.stepEmote()
	if not lobby.emoteDone and os.clock() - lobby.emoteSentAt < 7 then
		return
	end
	if os.clock() - lobby.emoteSentAt < 0.5 then
		return
	end
	local snapshot = accountSnapshot()
	if not snapshot then
		return
	end
	if gacha.emoteGoalReached(snapshot.emotes and snapshot.emotes.owned or {}) then
		Flags.AutoEmote = false
		return
	end
	local cost = EconomyConfig.rollCosts.emote
	if (tonumber(snapshot.currencies[cost.currency]) or 0) < cost.amount then
		return
	end
	lobby.emoteDone = false
	lobby.emoteSentAt = os.clock()
	lobby.emoteId = nextRequestId()
	LobbyPackets.rollEmote:fire({ requestId = lobby.emoteId })
end

function gacha.stepUnlockSlots()
	if os.clock() - lobby.unlockSentAt < 3 then
		return
	end
	local snapshot = accountSnapshot()
	if not snapshot then
		return
	end
	for slot = 2, 4 do
		local data = snapshot.UnlockedCharacters["Slot" .. slot]
		if data and data.Unlocked ~= true then
			local cost = tonumber(EconomyConfig.characterSlotUnlockCosts[slot])
			if cost and (tonumber(snapshot.currencies.money) or 0) >= cost then
				lobby.unlockSentAt = os.clock()
				LobbyPackets.unlockCharacterSlot:fire({ slot = slot, requestId = nextRequestId() })
			end
			return
		end
	end
end

local function stepCraft()
	local snapshot = accountSnapshot()
	if not snapshot then
		return
	end
	for _, label in ipairs(if #Flags.CraftItems > 0 then Flags.CraftItems else CRAFT_LABELS) do
		local recipe = CRAFT_BY_LABEL[label]
		if recipe and (tonumber(snapshot.accessory[recipe.accessory]) or 0) < Flags.CraftTarget then
			local enough = #recipe.needs > 0
			for _, need in ipairs(recipe.needs) do
				if (tonumber(snapshot.material[need.id]) or 0) < need.amount then
					enough = false
					break
				end
			end
			if enough and notPending("craft" .. recipe.key, 3) then
				LobbyPackets.craftAccessory:fire(recipe.key)
				task.wait(0.6)
				return
			end
		end
	end
end

local function stepSkillTree()
	if lobby.skillPending and os.clock() - lobby.skillSentAt < 6 then
		return
	end
	lobby.skillPending = nil
	local snapshot = accountSnapshot()
	if not snapshot or #Flags.SkillTreeBranches == 0 then
		return
	end
	for _, character in ipairs(Flags.SkillTreeCharacters) do
		local data = snapshot.CharactersData[character]
		local config = SkillTreeConfig.characters[character]
		if data and config and data.Progression then
			local skills = data.Progression.Skills or {}
			local ok, tokens = pcall(CharacterLevels.getAvailableTokens, character, data.Progression.Xp, skills)
			if ok and tokens then
				for _, branch in ipairs(Flags.SkillTreeBranches) do
					local tier = (tonumber(skills[branch]) or 1) + 1
					local node = config.branches[branch] and config.branches[branch].tiers[tier]
					if node and tier <= Flags.SkillTreeMaxTier and node.cost <= tokens then
						lobby.skillSentAt = os.clock()
						lobby.skillPending = nextRequestId()
						SkillTreePackets.purchaseCharacterSkill:fire({
							character = character,
							branch = branch,
							tier = tier,
							requestId = lobby.skillPending,
						})
						return
					end
				end
			end
		end
	end
end

local function roomState(number)
	local namespace = QueueRoomStore.namespace
	local ok, store = pcall(namespace.getStore, namespace, "room " .. number)
	return ok and store and store.state or nil
end

function gacha.pickAutoStory()
	if not (Flags.AutoUnlockNextStage or (Flags.JoinAuto and gacha.K.AutoProgress)) then
		return nil
	end
	local snapshot = accountSnapshot()
	local progress = snapshot and snapshot.achievements and snapshot.achievements.progress
	if not progress then
		return nil
	end
	local now = os.clock()
	for _, label in ipairs(GAMEMODE_LABELS) do
		local choice = GAMEMODE_CHOICES[label]
		if choice and choice.gamemode == "Story" and choice.chapters > 0 and (lobby.skipLabels[label] or 0) < now then
			local cleared = tonumber(progress["story." .. string.lower(choice.map) .. ".cleared"]) or 0
			if cleared < choice.chapters then
				return label, cleared + 1
			end
		end
	end
	return nil
end

local function stepJoin()
	if lobby.queueStatus == "inQuque" or lobby.queueStatus == "teleporting" then
		lobby.joinLabel = nil
		pcall(function()
			LobbyPackets.startQuqueNow:fire()
		end)
		return
	end
	if lobby.joinLabel and os.clock() - lobby.joinLabelAt > 25 then
		lobby.skipLabels[lobby.joinLabel] = os.clock() + 900
		warn("[" .. GAME_NAME .. "] queue for " .. tostring(lobby.joinLabel) .. " was not accepted; trying another map")
		lobby.joinLabel = nil
	end
	local _, root = characterParts()
	local pickLabel = Flags.JoinChoice
	if (not pickLabel or pickLabel == "" or not GAMEMODE_CHOICES[pickLabel]) and GAMEMODE_LABELS[1] then
		pickLabel = GAMEMODE_LABELS[1]
		Flags.JoinChoice = pickLabel
	end
	local choice = GAMEMODE_CHOICES[pickLabel]
	local autoWantedChapter = nil
	if Flags.AutoUnlockNextStage or Flags.JoinAuto then
		local autoLabel, autoCh = gacha.pickAutoStory()
		if autoLabel and GAMEMODE_CHOICES[autoLabel] then
			choice, pickLabel = GAMEMODE_CHOICES[autoLabel], autoLabel
			autoWantedChapter = autoCh
		end
	end
	if not root or not choice then
		return
	end
	if os.clock() - gacha.lobbyStart < Flags.JoinDelay or gacha.deliveryBusy() then
		return
	end

	local targetRoom = lobby.windowRoom
	if not targetRoom and root then
		local rooms = Workspace.Systems:FindFirstChild("QuqueRooms")
		for _, folder in ipairs(rooms and rooms:GetChildren() or {}) do
			local hitbox = folder:FindFirstChild("JoinHitbox") or folder:FindFirstChild("RingVFX")
			if hitbox and (hitbox.Position - root.Position).Magnitude < 25 then
				targetRoom = tonumber(folder.Name)
				break
			end
		end
	end

	if targetRoom then
		local wanted = autoWantedChapter or Flags.JoinChapter
		if wanted == 0 then
			local snapshot = accountSnapshot()
			local progress = snapshot and snapshot.achievements and snapshot.achievements.progress
			local cleared = progress and tonumber(progress["story." .. string.lower(choice.map) .. ".cleared"]) or 0
			wanted = cleared + 1
		end
		local chapter = if choice.chapters > 0 then math.clamp(wanted, 1, choice.chapters) else 0
		local floor = if choice.gamemode == "Trials" then math.clamp(wanted, 1, 100) else 0
		local difficulty = choice.fixedDifficulty
			or if DIFFICULTY_GAMEMODES[choice.gamemode] then DIFFICULTY_INDEX[Flags.JoinDifficulty] or 1 else 1

		LobbyPackets.createQuque:fire({
			gamemode = choice.gamemode,
			map = choice.map,
			chapter = chapter,
			floor = floor,
			difficulty = difficulty,
			maxPlayers = Flags.JoinPlayers,
			friendsOnly = Flags.JoinFriendsOnly,
			roomNumber = targetRoom,
		})
		lobby.joinLabel, lobby.joinLabelAt = pickLabel, os.clock()
		lobby.windowRoom = nil
		lobby.joinAt = os.clock()

		task.defer(function()
			task.wait(0.3)
			pcall(function()
				local pgui = LocalPlayer:FindFirstChild("PlayerGui")
				local qGui = pgui and pgui:FindFirstChild("UI Animation (Finished)") and pgui["UI Animation (Finished)"]:FindFirstChild("Quque")
				local staerBtn = qGui and qGui:FindFirstChild("StaerButton", true)
				if staerBtn then
					local btn = if staerBtn:IsA("GuiButton") then staerBtn else staerBtn:FindFirstChildWhichIsA("GuiButton")
					if btn and typeof(firesignal) == "function" then
						firesignal(btn.Activated)
					end
				end
			end)
			task.wait(0.3)
			pcall(function()
				LobbyPackets.startQuqueNow:fire()
			end)
		end)

		task.wait(3)
		return
	end
	if os.clock() - lobby.joinAt < 4 then
		return
	end
	local rooms = Workspace.Systems:FindFirstChild("QuqueRooms")
	local best, bestDistance
	for _, folder in ipairs(rooms and rooms:GetChildren() or {}) do
		local number = tonumber(folder.Name)
		local state = number and roomState(number)
		local hitbox = folder:FindFirstChild("JoinHitbox")
		local inside = folder:FindFirstChild("Inside")
		if state and hitbox and inside and state.status:get() == "idle" then
			local distance = (hitbox.Position - root.Position).Magnitude
			if not bestDistance or distance < bestDistance then
				best = Vector3.new(hitbox.Position.X, inside.Position.Y + 2.5, hitbox.Position.Z)
				bestDistance = distance
			end
		end
	end
	if not best then
		return
	end
	lobby.joinAt = os.clock()
	lobby.joinTries += 1
	if lobby.joinTries % 2 == 0 then
		tweenTo(root, CFrame.new(best + Vector3.new(0, 0, 40)), true)
		task.wait(0.3)
	end
	tweenTo(root, CFrame.new(best), true)
	lobby.joinAt = os.clock()
end

gacha.BEST_STATS = { "Damage", "HP", "Critical Chance", "Coins", "Exp", "Drop Rate" }
gacha.gearSentAt = 0
gacha.evolveSentAt = 0

function gacha.buffScore(entry)
	local total = 0
	for _, buff in ipairs(type(entry) == "table" and type(entry.Buffs) == "table" and entry.Buffs or {}) do
		if buff.Type == Flags.BestGearStat then
			total += tonumber(buff.Percent) or 0
		end
	end
	return total
end

function gacha.stepEvolve()
	if os.clock() - gacha.evolveSentAt < 5 then
		return
	end
	local snapshot = accountSnapshot()
	local character = snapshot and snapshot.character
	local data = character and snapshot.CharactersData[character]
	local recipe = character and gacha.EvolutionConfig[character]
	if not data or not recipe or data.IsUltimateUnlocked == true then
		return
	end
	for _, cost in ipairs(recipe.currencies or {}) do
		if (tonumber(snapshot.currencies[cost.currency]) or 0) < (tonumber(cost.amount) or 0) then
			return
		end
	end
	for pair in string.gmatch(tostring(recipe.ultimate or ""), "[^|]+") do
		local material, amount = string.match(pair, "^%s*([^,]+)%s*,%s*(%d+)")
		if material and (tonumber(snapshot.material[material]) or 0) < tonumber(amount) then
			return
		end
	end
	gacha.evolveSentAt = os.clock()
	LobbyPackets.evolveCharacter:fire(character)
end

function gacha.stepBestGear()
	if os.clock() - gacha.gearSentAt < 4 then
		return
	end
	local snapshot = accountSnapshot()
	if not snapshot then
		return
	end
	if Flags.AutoBestAccessory then
		local best, bestScore = {}, {}
		for id, count in pairs(snapshot.accessory or {}) do
			local entry = AccessoryConfig[tonumber(id)] or AccessoryConfig[tostring(id)]
			local slot = entry and entry.Slot
			local score = gacha.buffScore(entry)
			if slot and (tonumber(count) or 0) > 0 and score > (bestScore[slot] or 0) then
				best[slot], bestScore[slot] = tostring(id), score
			end
		end
		local equipped = type(snapshot.equippedAccessories) == "table" and snapshot.equippedAccessories or {}
		for slot, id in pairs(best) do
			if tostring(equipped[slot] or "") ~= id then
				gacha.gearSentAt = os.clock()
				LobbyPackets.setEquippedAccessory:fire(id)
				return
			end
		end
	end
	if Flags.AutoBestTitle then
		local best, bestScore = nil, 0
		for id, entry in pairs(gacha.TitleConfig) do
			local owned = snapshot.title and (snapshot.title[id] == true or snapshot.title[tostring(id)] == true)
			local score = gacha.buffScore(entry)
			if owned and score > bestScore then
				best, bestScore = id, score
			end
		end
		if best and tostring(snapshot.equippedTitle) ~= tostring(best) then
			gacha.gearSentAt = os.clock()
			LobbyPackets.equipTitle:fire(best)
			return
		end
	end
	if Flags.AutoRarestCharacters then
		local ranked = {}
		for slot = 1, 4 do
			local data = snapshot.UnlockedCharacters["Slot" .. slot]
			if data and data.Unlocked == true and data.Character ~= "" then
				local rarity = RollConfig.rarityByCharacter[data.Character]
				table.insert(ranked, { slot = slot, rank = rarity and table.find(RollConfig.rarityOrder, rarity) or 0 })
			end
		end
		table.sort(ranked, function(a, b)
			if a.rank ~= b.rank then
				return a.rank > b.rank
			end
			return a.slot < b.slot
		end)
		local gameSlots = 0
		for key in pairs(snapshot.EquippedCharacterSlots or {}) do
			gameSlots = math.max(gameSlots, tonumber(string.match(tostring(key), "%d+")) or 0)
		end
		local top = {}
		for index = 1, math.min(gameSlots, #ranked) do
			top[ranked[index].slot] = true
		end
		local equipped = {}
		for gameSlot = 1, gameSlots do
			equipped[tonumber(snapshot.EquippedCharacterSlots["Slot" .. gameSlot]) or 0] = gameSlot
		end
		for index = 1, math.min(gameSlots, #ranked) do
			local want = ranked[index].slot
			if not equipped[want] then
				for gameSlot = 1, gameSlots do
					local current = tonumber(snapshot.EquippedCharacterSlots["Slot" .. gameSlot]) or 0
					if not top[current] then
						gacha.gearSentAt = os.clock()
						LobbyPackets.equipCharacterSlot:fire({ slot = want, gameSlot = gameSlot, requestId = nextRequestId() })
						return
					end
				end
			end
		end
	end
end

function gacha.stepAchievements()
	LobbyPackets.claimAchievementRewards:fire({ requestId = nextRequestId() })
end

function gacha.stepSkipTutorial()
	if LocalPlayer:GetAttribute("TutorialPending") ~= true then
		return
	end
	local remote = ReplicatedStorage:FindFirstChild("TutorialRemote")
	if remote then
		remote:FireServer("skip")
		task.wait(5)
	end
end

gacha.lobbyStart = os.clock()
gacha.delivery = nil
gacha.deliverySentAt = 0

function gacha.deliveryNpc(name)
	local systems = Workspace:FindFirstChild("Systems")
	local npcs = systems and systems:FindFirstChild("NPCS")
	local npc = npcs and npcs:FindFirstChild(name)
	if not npc then
		local scattered = systems and systems:FindFirstChild("ScatteredNPCS")
		npc = scattered and scattered:FindFirstChild(name)
	end
	local part = npc and npc:FindFirstChild("HumanoidRootPart")
	return if part and part:IsA("BasePart") then part else nil
end

function gacha.stepDelivery()
	local state = gacha.delivery
	local _, root = characterParts()
	if not root then
		return
	end
	local clock = os.clock()
	if not state then
		if clock - gacha.deliverySentAt > 5 then
			gacha.deliverySentAt = clock
			LobbyPackets.deliveryAction:fire({ action = "refresh", requestId = nextRequestId() })
		end
		return
	end
	if state.status == "carrying" then
		local target = gacha.deliveryNpc(tostring(state.target))
		if target and (target.Position - root.Position).Magnitude > 4 then
			tweenTo(root, target.CFrame * CFrame.new(0, 0, -3), true)
		end
		return
	end
	if clock - gacha.deliverySentAt < 3 then
		return
	end
	local giver = gacha.deliveryNpc("Heiyun")
	local action
	if state.status == "delivered" then
		action = "claim"
	elseif state.status == "none" and (tonumber(state.dailyCount) or 0) < (tonumber(state.dailyLimit) or 0) then
		action = "request"
	end
	if not action then
		return
	end
	if giver and (giver.Position - root.Position).Magnitude > 10 then
		tweenTo(root, giver.CFrame * CFrame.new(0, 0, -5), true)
	end
	gacha.deliverySentAt = os.clock()
	LobbyPackets.deliveryAction:fire({ action = action, requestId = nextRequestId() })
end

function gacha.deliveryBusy()
	local state = gacha.delivery
	if not Flags.AutoDelivery or not state then
		return false
	end
	return state.status == "carrying"
		or state.status == "delivered"
		or (state.status == "none" and (tonumber(state.dailyCount) or 0) < (tonumber(state.dailyLimit) or 0))
end

local function redeemAllCodes(onDone)
	if lobby.codesBusy then
		return
	end
	lobby.codesBusy = true
	task.spawn(function()
		local redeemed = {}
		local snapshot = accountSnapshot()
		if snapshot and type(snapshot.cdk) == "table" then
			for _, code in pairs(snapshot.cdk) do
				redeemed[string.lower(tostring(code))] = true
			end
		end
		local codes = {}
		local seen = {}
		for _, entry in pairs(CodesConfig) do
			if type(entry) == "table" and type(entry.Code) == "string" and not seen[string.lower(entry.Code)] then
				seen[string.lower(entry.Code)] = true
				table.insert(codes, entry.Code)
			end
		end
		for _, code in ipairs({ "TYASHIRA", "TYFRIGID", "NEWRAID", "SORRYFORDELAY" }) do
			if not seen[string.lower(code)] then
				seen[string.lower(code)] = true
				table.insert(codes, code)
			end
		end
		table.sort(codes)
		local sent = 0
		for _, code in ipairs(codes) do
			if API.Unloaded then
				break
			end
			if not redeemed[string.lower(code)] then
				LobbyPackets.redeemCode:fire(code)
				sent += 1
				task.wait(1.2)
			end
		end
		lobby.codesBusy = false
		if onDone and not API.Unloaded then
			onDone(sent, #codes)
		end
	end)
end

if IN_LOBBY then
	local function listen(event, handler)
		local ok, handle = pcall(function()
			return event:on(handler)
		end)
		if not ok then
			warn("[" .. GAME_NAME .. "] listener: " .. tostring(handle))
			return
		end
		API.Track(function()
			local kind = typeof(handle)
			if kind == "function" then
				pcall(handle)
			elseif kind == "RBXScriptConnection" then
				handle:Disconnect()
			elseif kind == "table" and type(handle.Disconnect) == "function" then
				pcall(handle.Disconnect, handle)
			end
		end)
	end
	listen(LobbyPackets.deliveryState, function(state)
		if type(state) == "table" then
			gacha.delivery = state
		end
	end)
	listen(LobbyPackets.updateClientQuqueStatus, function(status)
		lobby.queueStatus = status
	end)
	listen(LobbyPackets.toggleQuqueWindow, function(data)
		lobby.windowRoom = if data.open then data.roomNumber else nil
	end)
	listen(LobbyPackets.characterRolled, function(data)
		if data.requestId == lobby.summonId then
			lobby.summonDone = true
			task.spawn(function()
				task.wait(0.4)
				local snapshot = accountSnapshot()
				local slot = snapshot and snapshot.UnlockedCharacters["Slot" .. Flags.SummonSlot]
				local rarity = slot and RollConfig.rarityByCharacter[slot.Character]
				local threshold = table.find(RollConfig.rarityOrder, Flags.ProtectRarity)
				local index = rarity and table.find(RollConfig.rarityOrder, rarity)
				lobby.summonCount += 1
				lobby.summonLast = if slot and slot.Character ~= "" then characterName(slot.Character) else "-"
				local wanted = slot ~= nil and table.find(Flags.SummonStopCharacters, slot.Character) ~= nil
				if ((threshold and index and index >= threshold) or wanted) and not API.Unloaded then
					recordRollHit(slot.Character, rarity)
					if Flags.SummonFavourite and slot.Favourite ~= true then
						LobbyPackets.setCharacterSlotFavourite:fire({
							slot = Flags.SummonSlot,
							favourite = true,
							requestId = nextRequestId(),
						})
					end
				end
			end)
		end
	end)
	listen(LobbyPackets.traitRolled, function(data)
		if data.requestId == lobby.traitId then
			lobby.traitDone = true
			lobby.traitCount += 1
			task.spawn(function()
				task.wait(0.4)
				local snapshot = accountSnapshot()
				local character = Flags.TraitCharacter
				if character == "Equipped Character" then
					character = snapshot and snapshot.character
				end
				local entry = snapshot and character and snapshot.CharactersData[character]
				local id = entry and entry.TraitData and tonumber(entry.TraitData.Trait)
				local trait = gacha.traitById(id)
				lobby.traitLast = if trait and trait.Name then tostring(trait.Name) else "-"
			end)
		end
	end)
	listen(LobbyPackets.emoteRolled, function(data)
		if data.requestId == lobby.emoteId then
			lobby.emoteDone = true
			if data.success then
				lobby.emoteCount += 1
				lobby.emoteLast = tostring(data.emote)
			end
		end
	end)
	listen(SkillTreePackets.characterSkillPurchaseResult, function(data)
		if data.requestId == lobby.skillPending then
			lobby.skillPending = nil
		end
	end)
	startWorker("Trait", 0.2, function()
		return Flags.AutoTrait
	end, stepTrait)
	startWorker("Craft", 1, function()
		return Flags.AutoCraft
	end, stepCraft)
	startWorker("Delivery", 1, function()
		return Flags.AutoDelivery
	end, gacha.stepDelivery)
	task.delay(3, function()
		pcall(function()
			LobbyPackets.deliveryAction:fire({ action = "refresh", requestId = nextRequestId() })
		end)
	end)
	startWorker("Evolve", 3, function()
		return Flags.AutoEvolve
	end, gacha.stepEvolve)
	startWorker("BestGear", 5, function()
		return Flags.AutoBestAccessory or Flags.AutoBestTitle or Flags.AutoRarestCharacters
	end, gacha.stepBestGear)
	startWorker("Achievements", 30, function()
		return Flags.AutoAchievements
	end, gacha.stepAchievements)
	startWorker("SkipTutorial", 2, function()
		return Flags.AutoSkipTutorial
	end, gacha.stepSkipTutorial)
	startWorker("RedeemCodes", 2, function()
		return Flags.AutoRedeemCodes
	end, function()
		if not gacha.codesAt or os.clock() - gacha.codesAt > 600 then
			gacha.codesAt = os.clock()
			redeemAllCodes()
		end
	end)
	startWorker("SkillTree", 1, function()
		return Flags.AutoSkillTree
	end, stepSkillTree)
	startWorker("Join", 0.5, function()
		return Flags.AutoJoin
	end, stepJoin)
	startWorker("Milestones", 2, function()
		return Flags.AutoMilestones
	end, stepMilestones)
	startWorker("Daily", 3, function()
		return Flags.AutoDaily
	end, stepDaily)
	startWorker("Quests", 3, function()
		return Flags.AutoQuests
	end, stepQuests)
	startWorker("Summon", 0.5, function()
		return Flags.AutoSummon
	end, stepSummon)
	startWorker("Emote", 0.3, function()
		return Flags.AutoEmote
	end, gacha.stepEmote)
	startWorker("UnlockSlots", 1, function()
		return Flags.AutoUnlockSlots
	end, gacha.stepUnlockSlots)
	API.Track(function()
		Flags.AutoJoin = false
		Flags.AutoMilestones = false
		Flags.AutoDaily = false
		Flags.AutoQuests = false
		Flags.AutoSummon = false
		Flags.AutoTrait = false
		Flags.AutoEmote = false
		Flags.AutoUnlockSlots = false
		Flags.AutoCraft = false
		Flags.AutoSkillTree = false
		Flags.AutoEvolve = false
		Flags.AutoDelivery = false
		Flags.AutoBestAccessory = false
		Flags.AutoBestTitle = false
		Flags.AutoRarestCharacters = false
		Flags.AutoAchievements = false
		Flags.AutoRedeemCodes = false
		Flags.AutoSkipTutorial = false
	end)
end

local PlayerApi = {}
local walkSnapshots = setmetatable({}, { __mode = "k" })
local noclipSnapshots = setmetatable({}, { __mode = "k" })
local promptSnapshots = setmetatable({}, { __mode = "k" })
local fpsSnapshots = setmetatable({}, { __mode = "k" })
local flyState = {
	connection = nil,
	humanoid = nil,
	priorPlatformStand = nil,
}
local infJumpConnection = nil
local noclipConnection = nil
local promptConnection = nil
local fpsConnection = nil
PlayerApi.perf = {
	ultra = setmetatable({}, { __mode = "k" }),
	ultraConnection = nil,
	ultraGlobal = nil,
	vfx = setmetatable({}, { __mode = "k" }),
	vfxConnections = {},
	anim = {},
}
local reconnectConnections = {}
local renderPrior = nil
local renderCover = nil

function PlayerApi.setWalkSpeedEnabled(value)
	Flags.WalkSpeedEnabled = value == true
	local _, _, humanoid = characterParts()
	if not humanoid then
		return
	end
	if Flags.WalkSpeedEnabled then
		if walkSnapshots[humanoid] == nil then
			walkSnapshots[humanoid] = humanoid.WalkSpeed
		end
		humanoid.WalkSpeed = Flags.WalkSpeed
	elseif walkSnapshots[humanoid] ~= nil then
		humanoid.WalkSpeed = walkSnapshots[humanoid]
		walkSnapshots[humanoid] = nil
	end
end

function PlayerApi.setWalkSpeed(value)
	Flags.WalkSpeed = value
	if Flags.WalkSpeedEnabled then
		local _, _, humanoid = characterParts()
		if humanoid then
			if walkSnapshots[humanoid] == nil then
				walkSnapshots[humanoid] = humanoid.WalkSpeed
			end
			humanoid.WalkSpeed = value
		end
	end
end

function PlayerApi.setInfJump(value)
	Flags.InfJump = value == true
	if infJumpConnection then
		infJumpConnection:Disconnect()
		infJumpConnection = nil
	end
	if not Flags.InfJump then
		return
	end
	infJumpConnection = UserInputService.JumpRequest:Connect(function()
		if API.Unloaded or not Flags.InfJump then
			return
		end
		local _, _, humanoid = characterParts()
		if humanoid then
			humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
		end
	end)
	API.Track(function()
		if infJumpConnection then
			infJumpConnection:Disconnect()
			infJumpConnection = nil
		end
	end)
end

local function applyNoclip(character)
	for _, part in ipairs(character:GetDescendants()) do
		if part:IsA("BasePart") then
			if noclipSnapshots[part] == nil then
				noclipSnapshots[part] = part.CanCollide
			end
			part.CanCollide = false
		end
	end
end

local function restoreNoclip()
	for part, prior in pairs(noclipSnapshots) do
		if part.Parent then
			part.CanCollide = prior
		end
		noclipSnapshots[part] = nil
	end
end

function PlayerApi.setNoClip(value)
	Flags.NoClip = value == true
	if noclipConnection then
		noclipConnection:Disconnect()
		noclipConnection = nil
	end
	if not Flags.NoClip then
		restoreNoclip()
		return
	end
	local character = LocalPlayer.Character
	if character then
		applyNoclip(character)
	end
	noclipConnection = RunService.Stepped:Connect(function()
		if API.Unloaded or not Flags.NoClip then
			return
		end
		local live = LocalPlayer.Character
		if live then
			applyNoclip(live)
		end
	end)
	API.Track(function()
		if noclipConnection then
			noclipConnection:Disconnect()
			noclipConnection = nil
		end
		restoreNoclip()
	end)
end

local function snapshotPrompt(prompt)
	if promptSnapshots[prompt] == nil then
		promptSnapshots[prompt] = {
			HoldDuration = prompt.HoldDuration,
			MaxActivationDistance = prompt.MaxActivationDistance,
			RequiresLineOfSight = prompt.RequiresLineOfSight,
		}
	end
	prompt.HoldDuration = 0
	prompt.MaxActivationDistance = 50
	prompt.RequiresLineOfSight = false
end

local function restorePrompts()
	for prompt, prior in pairs(promptSnapshots) do
		if prompt.Parent then
			prompt.HoldDuration = prior.HoldDuration
			prompt.MaxActivationDistance = prior.MaxActivationDistance
			prompt.RequiresLineOfSight = prior.RequiresLineOfSight
		end
		promptSnapshots[prompt] = nil
	end
end

function PlayerApi.setInstantProximityPrompt(value)
	Flags.InstantProximityPrompt = value == true
	if promptConnection then
		promptConnection:Disconnect()
		promptConnection = nil
	end
	if not Flags.InstantProximityPrompt then
		restorePrompts()
		return
	end
	for _, inst in ipairs(Workspace:GetDescendants()) do
		if inst:IsA("ProximityPrompt") then
			snapshotPrompt(inst)
		end
	end
	promptConnection = Workspace.DescendantAdded:Connect(function(inst)
		if Flags.InstantProximityPrompt and inst:IsA("ProximityPrompt") then
			snapshotPrompt(inst)
		end
	end)
	API.Track(function()
		if promptConnection then
			promptConnection:Disconnect()
			promptConnection = nil
		end
		restorePrompts()
	end)
end

local function stopFly()
	if flyState.connection then
		flyState.connection:Disconnect()
		flyState.connection = nil
	end
	if flyState.humanoid and flyState.humanoid.Parent and flyState.priorPlatformStand ~= nil then
		flyState.humanoid.PlatformStand = flyState.priorPlatformStand
	end
	flyState.humanoid = nil
	flyState.priorPlatformStand = nil
	local _, root = characterParts()
	if root then
		root.AssemblyLinearVelocity = Vector3.zero
	end
end

function PlayerApi.setFly(value)
	Flags.Fly = value == true
	stopFly()
	if not Flags.Fly then
		return
	end
	local _, root, humanoid = characterParts()
	if not (root and humanoid) then
		return
	end
	flyState.humanoid = humanoid
	flyState.priorPlatformStand = humanoid.PlatformStand
	humanoid.PlatformStand = true
	flyState.connection = RunService.RenderStepped:Connect(function()
		if API.Unloaded or not Flags.Fly then
			return
		end
		if UserInputService:GetFocusedTextBox() then
			return
		end
		local _, liveRoot, liveHumanoid = characterParts()
		if not (liveRoot and liveHumanoid) then
			return
		end
		local camera = Workspace.CurrentCamera
		if not camera then
			return
		end
		local move = Vector3.zero
		if UserInputService:IsKeyDown(Enum.KeyCode.W) then
			move += camera.CFrame.LookVector
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.S) then
			move -= camera.CFrame.LookVector
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.A) then
			move -= camera.CFrame.RightVector
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.D) then
			move += camera.CFrame.RightVector
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
			move += Vector3.yAxis
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
			move -= Vector3.yAxis
		end
		if move.Magnitude > 0 then
			liveRoot.AssemblyLinearVelocity = move.Unit * Flags.FlySpeed
		else
			liveRoot.AssemblyLinearVelocity = Vector3.zero
		end
		liveHumanoid.PlatformStand = true
	end)
	API.Track(stopFly)
end

function PlayerApi.setFlySpeed(value)
	Flags.FlySpeed = value
end

local antiPauseGen = 0

function PlayerApi.setNoGameplayPaused(value)
	Flags.AntiGameplayPause = value == true
	antiPauseGen += 1
	local gen = antiPauseGen
	if not Flags.AntiGameplayPause then
		return
	end
	task.spawn(function()
		while not API.Unloaded and Flags.AntiGameplayPause and gen == antiPauseGen do
			pcall(function()
				GuiService:ClearError()
			end)
			local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
			if playerGui then
				local pause = playerGui:FindFirstChild("GameplayPaused")
				if pause and pause:IsA("GuiObject") then
					pause.Enabled = false
				end
			end
			task.wait(1)
		end
	end)
end

function PlayerApi.setAutoReconnect(value)
	Flags.AutoReconnect = value == true
	for _, conn in ipairs(reconnectConnections) do
		conn:Disconnect()
	end
	table.clear(reconnectConnections)
	if not Flags.AutoReconnect then
		return
	end
	local attemptToken = 0
	local function reconnect()
		if API.Unloaded or not Flags.AutoReconnect then
			return
		end
		attemptToken += 1
		local token = attemptToken
		task.spawn(function()
			task.wait(1.5)
			if API.Unloaded or not Flags.AutoReconnect or token ~= attemptToken then
				return
			end
			pcall(function()
				TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
			end)
			task.wait(4)
			if API.Unloaded or not Flags.AutoReconnect or token ~= attemptToken then
				return
			end
			pcall(function()
				TeleportService:Teleport(game.PlaceId, LocalPlayer)
			end)
		end)
	end
	table.insert(reconnectConnections, GuiService.ErrorMessageChanged:Connect(function()
		if Flags.AutoReconnect then
			reconnect()
		end
	end))
	table.insert(reconnectConnections, TeleportService.TeleportInitFailed:Connect(function(player)
		if player == LocalPlayer and Flags.AutoReconnect then
			reconnect()
		end
	end))
	API.Track(function()
		for _, conn in ipairs(reconnectConnections) do
			conn:Disconnect()
		end
		table.clear(reconnectConnections)
	end)
end

function PlayerApi.setDisable3D(value)
	Flags.Disable3DRendering = value == true
	if Flags.Disable3DRendering then
		if renderPrior == nil and typeof(RunService.Set3dRenderingEnabled) == "function" then
			renderPrior = true
		end
		pcall(function()
			RunService:Set3dRenderingEnabled(false)
		end)
		if not renderCover then
			local gui = Instance.new("ScreenGui")
			gui.Name = "RelwxRenderCover"
			gui.IgnoreGuiInset = true
			gui.DisplayOrder = -100
			gui.ResetOnSpawn = false
			local frame = Instance.new("Frame")
			frame.BackgroundColor3 = Color3.new(0, 0, 0)
			frame.Size = UDim2.fromScale(1, 1)
			frame.BorderSizePixel = 0
			frame.Parent = gui
			gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
			renderCover = gui
			API.Track(function()
				if renderCover then
					renderCover:Destroy()
					renderCover = nil
				end
			end)
		end
	else
		pcall(function()
			RunService:Set3dRenderingEnabled(true)
		end)
		if renderCover then
			renderCover:Destroy()
			renderCover = nil
		end
	end
end

local FPS_CLASSES = {
	ParticleEmitter = true,
	Trail = true,
	Beam = true,
	Fire = true,
	Smoke = true,
	Sparkles = true,
}

local function softenEffect(inst)
	if fpsSnapshots[inst] ~= nil then
		return
	end
	if FPS_CLASSES[inst.ClassName] then
		fpsSnapshots[inst] = { kind = "enabled", value = inst.Enabled }
		inst.Enabled = false
	end
end

function PlayerApi.setFpsBoost(value)
	Flags.FpsBoost = value == true
	if fpsConnection then
		fpsConnection:Disconnect()
		fpsConnection = nil
	end
	if not Flags.FpsBoost then
		for inst, prior in pairs(fpsSnapshots) do
			if inst.Parent and prior.kind == "enabled" then
				inst.Enabled = prior.value
			end
			fpsSnapshots[inst] = nil
		end
		if fpsSnapshots.lighting then
			local prior = fpsSnapshots.lighting
			Lighting.GlobalShadows = prior.GlobalShadows
			Lighting.FogEnd = prior.FogEnd
			fpsSnapshots.lighting = nil
		end
		return
	end
	fpsSnapshots.lighting = {
		GlobalShadows = Lighting.GlobalShadows,
		FogEnd = Lighting.FogEnd,
	}
	Lighting.GlobalShadows = false
	Lighting.FogEnd = 1e6
	local scanned = 0
	for _, inst in ipairs(Workspace:GetDescendants()) do
		softenEffect(inst)
		scanned += 1
		if scanned >= 4000 then
			break
		end
	end
	fpsConnection = Workspace.DescendantAdded:Connect(function(inst)
		if Flags.FpsBoost then
			softenEffect(inst)
		end
	end)
	API.Track(function()
		if fpsConnection then
			fpsConnection:Disconnect()
			fpsConnection = nil
		end
	end)
end

function PlayerApi.perf.ultraSoften(inst)
	local snaps = PlayerApi.perf.ultra
	if snaps[inst] ~= nil then
		return
	end
	if inst:IsA("BasePart") then
		snaps[inst] = { Material = inst.Material, CastShadow = inst.CastShadow, Reflectance = inst.Reflectance }
		inst.Material = Enum.Material.SmoothPlastic
		inst.CastShadow = false
		inst.Reflectance = 0
	elseif inst:IsA("Decal") or inst:IsA("Texture") then
		snaps[inst] = { Transparency = inst.Transparency }
		inst.Transparency = 1
	elseif FPS_CLASSES[inst.ClassName] or inst:IsA("Light") then
		snaps[inst] = { Enabled = inst.Enabled }
		inst.Enabled = false
	end
end

function PlayerApi.perf.restoreSnapshots(snaps)
	for inst, prior in pairs(snaps) do
		if typeof(inst) == "Instance" and inst.Parent then
			for prop, value in pairs(prior) do
				pcall(function()
					inst[prop] = value
				end)
			end
		end
		snaps[inst] = nil
	end
end

function PlayerApi.setUltraFpsBoost(value)
	Flags.UltraFpsBoost = value == true
	if PlayerApi.perf.ultraConnection then
		PlayerApi.perf.ultraConnection:Disconnect()
		PlayerApi.perf.ultraConnection = nil
	end
	if not Flags.UltraFpsBoost then
		PlayerApi.perf.restoreSnapshots(PlayerApi.perf.ultra)
		local prior = PlayerApi.perf.ultraGlobal
		PlayerApi.perf.ultraGlobal = nil
		if prior then
			pcall(function()
				settings().Rendering.QualityLevel = prior.QualityLevel
			end)
			local terrain = Workspace.Terrain
			terrain.WaterWaveSize = prior.WaterWaveSize
			terrain.WaterReflectance = prior.WaterReflectance
			Lighting.GlobalShadows = prior.GlobalShadows
			for effect, enabled in pairs(prior.post) do
				if effect.Parent then
					effect.Enabled = enabled
				end
			end
		end
		return
	end
	if not PlayerApi.perf.ultraGlobal then
		local terrain = Workspace.Terrain
		local prior = {
			WaterWaveSize = terrain.WaterWaveSize,
			WaterReflectance = terrain.WaterReflectance,
			GlobalShadows = Lighting.GlobalShadows,
			post = {},
		}
		pcall(function()
			prior.QualityLevel = settings().Rendering.QualityLevel
			settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
		end)
		PlayerApi.perf.ultraGlobal = prior
		terrain.WaterWaveSize = 0
		terrain.WaterReflectance = 0
		Lighting.GlobalShadows = false
		for _, effect in ipairs(Lighting:GetDescendants()) do
			if effect:IsA("PostEffect") then
				prior.post[effect] = effect.Enabled
				effect.Enabled = false
			end
		end
	end
	PlayerApi.perf.ultraConnection = Workspace.DescendantAdded:Connect(function(inst)
		if Flags.UltraFpsBoost then
			PlayerApi.perf.ultraSoften(inst)
		end
	end)
	API.Track(function()
		if PlayerApi.perf.ultraConnection then
			PlayerApi.perf.ultraConnection:Disconnect()
			PlayerApi.perf.ultraConnection = nil
		end
	end)
	task.spawn(function()
		for index, inst in ipairs(Workspace:GetDescendants()) do
			if not Flags.UltraFpsBoost then
				return
			end
			PlayerApi.perf.ultraSoften(inst)
			if index % 1000 == 0 then
				task.wait()
			end
		end
	end)
end

PlayerApi.perf.VFX_FOLDERS = { "effects", "_effects" }

function PlayerApi.perf.hideSkillVfx(inst)
	local snaps = PlayerApi.perf.vfx
	if snaps[inst] ~= nil or inst.Name == "aoeIndicator" or inst:FindFirstAncestor("aoeIndicator") then
		return
	end
	if inst:IsA("BillboardGui") or inst:FindFirstAncestorWhichIsA("BillboardGui") then
		return
	end
	if inst:IsA("ParticleEmitter") then
		snaps[inst] = { Enabled = inst.Enabled, Transparency = inst.Transparency }
		inst.Enabled = false
		inst.Transparency = NumberSequence.new(1)
		inst:Clear()
	elseif FPS_CLASSES[inst.ClassName] or inst:IsA("Light") then
		snaps[inst] = { Enabled = inst.Enabled }
		inst.Enabled = false
	elseif inst:IsA("BasePart") then
		snaps[inst] = { LocalTransparencyModifier = inst.LocalTransparencyModifier }
		inst.LocalTransparencyModifier = 1
	elseif inst:IsA("Decal") or inst:IsA("Texture") then
		snaps[inst] = { Transparency = inst.Transparency }
		inst.Transparency = 1
	end
end

function PlayerApi.setDisableSkillVfx(value)
	Flags.DisableSkillVfx = value == true
	for _, connection in ipairs(PlayerApi.perf.vfxConnections) do
		connection:Disconnect()
	end
	table.clear(PlayerApi.perf.vfxConnections)
	if not Flags.DisableSkillVfx then
		PlayerApi.perf.restoreSnapshots(PlayerApi.perf.vfx)
		return
	end
	for _, name in ipairs(PlayerApi.perf.VFX_FOLDERS) do
		local folder = Workspace:FindFirstChild(name)
		if folder then
			for _, inst in ipairs(folder:GetDescendants()) do
				PlayerApi.perf.hideSkillVfx(inst)
			end
			table.insert(PlayerApi.perf.vfxConnections, folder.DescendantAdded:Connect(function(inst)
				if Flags.DisableSkillVfx then
					PlayerApi.perf.hideSkillVfx(inst)
				end
			end))
		end
	end
	API.Track(function()
		for _, connection in ipairs(PlayerApi.perf.vfxConnections) do
			connection:Disconnect()
		end
		table.clear(PlayerApi.perf.vfxConnections)
	end)
end

function PlayerApi.perf.freezeAnimator(animator)
	if PlayerApi.perf.anim[animator] then
		return
	end
	for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
		track:Stop(0)
	end
	PlayerApi.perf.anim[animator] = animator.AnimationPlayed:Connect(function(track)
		if Flags.DisablePlayerAnimations then
			track:Stop(0)
		end
	end)
end

function PlayerApi.perf.freezeCharacter(character)
	if not character then
		return
	end
	local humanoid = character:WaitForChild("Humanoid", 10)
	local animator = humanoid and humanoid:WaitForChild("Animator", 10)
	if animator and Flags.DisablePlayerAnimations then
		PlayerApi.perf.freezeAnimator(animator)
	end
end

function PlayerApi.perf.watchPlayerAnimations(player)
	task.spawn(PlayerApi.perf.freezeCharacter, player.Character)
	PlayerApi.perf.anim[player] = player.CharacterAdded:Connect(function(character)
		if Flags.DisablePlayerAnimations then
			PlayerApi.perf.freezeCharacter(character)
		end
	end)
end

function PlayerApi.perf.releaseAnimations()
	for key, connection in pairs(PlayerApi.perf.anim) do
		connection:Disconnect()
		PlayerApi.perf.anim[key] = nil
	end
end

function PlayerApi.setDisablePlayerAnimations(value)
	Flags.DisablePlayerAnimations = value == true
	PlayerApi.perf.releaseAnimations()
	if not Flags.DisablePlayerAnimations then
		return
	end
	for _, player in ipairs(Players:GetPlayers()) do
		PlayerApi.perf.watchPlayerAnimations(player)
	end
	PlayerApi.perf.anim.playerAdded = Players.PlayerAdded:Connect(PlayerApi.perf.watchPlayerAnimations)
	API.Track(PlayerApi.perf.releaseAnimations)
end

local COMBAT_CURSOR_BIND = "PayomboyZDisableCombatCursor"

function PlayerApi.setDisableCombatCursor(value)
	Flags.DisableCombatCursor = value == true
	pcall(RunService.UnbindFromRenderStep, RunService, COMBAT_CURSOR_BIND)
	if Flags.DisableCombatCursor then
		RunService:BindToRenderStep(COMBAT_CURSOR_BIND, Enum.RenderPriority.Last.Value + 10, function()
			local crosshair = LocalPlayer.PlayerGui:FindFirstChild("Crosshair")
			if crosshair and crosshair:IsA("ScreenGui") and crosshair.Enabled then
				crosshair.Enabled = false
			end
			UserInputService.MouseBehavior = Enum.MouseBehavior.Default
			UserInputService.MouseIconEnabled = true
		end)
		API.Track(function()
			pcall(RunService.UnbindFromRenderStep, RunService, COMBAT_CURSOR_BIND)
			local crosshair = LocalPlayer.PlayerGui:FindFirstChild("Crosshair")
			if crosshair and crosshair:IsA("ScreenGui") then
				crosshair.Enabled = true
			end
		end)
	else
		local crosshair = LocalPlayer.PlayerGui:FindFirstChild("Crosshair")
		if crosshair and crosshair:IsA("ScreenGui") then
			crosshair.Enabled = true
		end
	end
end

local MenuApi = {}
local antiAfkConnection = nil
local antiAfkGen = 0

function MenuApi.setAntiAfk(value)
	Flags.AntiAfk = value == true
	antiAfkGen += 1
	local gen = antiAfkGen
	if antiAfkConnection then
		antiAfkConnection:Disconnect()
		antiAfkConnection = nil
	end
	if not Flags.AntiAfk then
		return
	end
	antiAfkConnection = LocalPlayer.Idled:Connect(function()
		if API.Unloaded or not Flags.AntiAfk then
			return
		end
		pcall(function()
			VirtualUser:CaptureController()
			VirtualUser:ClickButton2(Vector2.new())
		end)
	end)
	task.spawn(function()
		while not API.Unloaded and Flags.AntiAfk and gen == antiAfkGen do
			task.wait(60)
			if API.Unloaded or not Flags.AntiAfk or gen ~= antiAfkGen then
				break
			end
			pcall(function()
				VirtualUser:CaptureController()
				VirtualUser:ClickButton2(Vector2.new())
			end)
		end
	end)
	API.Track(function()
		if antiAfkConnection then
			antiAfkConnection:Disconnect()
			antiAfkConnection = nil
		end
		antiAfkGen += 1
	end)
end

do
	local characterConn = LocalPlayer.CharacterAdded:Connect(function()
		task.wait(0.2)
		if API.Unloaded then
			return
		end
		if Flags.WalkSpeedEnabled then
			PlayerApi.setWalkSpeedEnabled(true)
		end
		if Flags.NoClip then
			PlayerApi.setNoClip(true)
		end
		if Flags.Fly then
			PlayerApi.setFly(true)
		end
	end)
	API.Track(function()
		characterConn:Disconnect()
	end)
end

local VisualApi = {
	supported = type(Drawing) == "table" and type(Drawing.new) == "function",
	cfg = {
		EspMobs = false,
		EspPlayers = false,
		EspNpcs = false,
		EspDelivery = false,
		EspBoxes = true,
		EspNames = true,
		EspDistance = true,
		EspHealth = true,
		EspTracers = false,
		EspChams = false,
		EspMobColor = Color3.fromRGB(255, 120, 50),
		EspBossColor = Color3.fromRGB(255, 205, 70),
		EspPlayerColor = Color3.fromRGB(120, 255, 150),
		EspNpcColor = Color3.fromRGB(0, 210, 255),
		EspDeliveryColor = Color3.fromRGB(255, 200, 0),
		FullBright = false,
		CustomFov = false,
		Fov = 90,
	},
	pool = {},
	chams = {},
	maxHealth = {},
	connection = nil,
	lighting = nil,
	fovPrior = nil,
}

function VisualApi.drawing(kind, props)
	local object = Drawing.new(kind)
	for key, value in pairs(props) do
		object[key] = value
	end
	return object
end

function VisualApi.entry(key)
	local entry = VisualApi.pool[key]
	if entry then
		return entry
	end
	local draw = VisualApi.drawing
	entry = {
		box = draw("Square", { Thickness = 1, Filled = false, Visible = false }),
		text = draw("Text", { Size = 14, Center = true, Outline = true, Visible = false }),
		tracer = draw("Line", { Thickness = 1, Visible = false }),
		barBack = draw("Line", { Thickness = 4, Color = Color3.new(0, 0, 0), Visible = false }),
		bar = draw("Line", { Thickness = 2, Visible = false }),
	}
	VisualApi.pool[key] = entry
	return entry
end

function VisualApi.hideEntry(entry)
	for _, object in pairs(entry) do
		object.Visible = false
	end
end

function VisualApi.removeEntry(key)
	local entry = VisualApi.pool[key]
	if not entry then
		return
	end
	VisualApi.pool[key] = nil
	for _, object in pairs(entry) do
		pcall(object.Remove, object)
	end
end

function VisualApi.setCham(key, model, color)
	local highlight = VisualApi.chams[key]
	if not model then
		if highlight then
			VisualApi.chams[key] = nil
			highlight:Destroy()
		end
		return
	end
	if not highlight or highlight.Adornee ~= model or not highlight.Parent then
		if highlight then
			highlight:Destroy()
		end
		highlight = Instance.new("Highlight")
		highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		highlight.FillTransparency = 0.6
		highlight.OutlineTransparency = 0
		highlight.Adornee = model
		highlight.Parent = (gethui and gethui()) or game:GetService("CoreGui")
		VisualApi.chams[key] = highlight
	end
	highlight.FillColor = color
	highlight.OutlineColor = color
end

function VisualApi.collect(origin)
	local cfg = VisualApi.cfg
	local targets = {}
	if cfg.EspMobs and IN_RUN and EnemyStore then
		local ok, all = pcall(function()
			return EnemyStore.store.state:getAll()
		end)
		if ok and type(all) == "table" then
			for id, enemy in pairs(all) do
				local health = enemy.health:get()
				if health > 0 then
					local name = enemy.name:get()
					local info = Enemies.enemiesByName[name]
					local key = "mob:" .. tostring(id)
					local maxHealth = math.max(VisualApi.maxHealth[key] or 0, health, info and tonumber(info.baseHealth) or 0)
					VisualApi.maxHealth[key] = maxHealth
					local boss = info ~= nil and info.boss == true
					local height = info and tonumber(info.height) or 6
					local position = enemy.position:get()
					table.insert(targets, {
						key = key,
						label = (info and info.displayName) or name,
						top = position + Vector3.new(0, height / 2, 0),
						bottom = position - Vector3.new(0, height / 2, 0),
						position = position,
						health = health,
						maxHealth = maxHealth,
						color = if boss then cfg.EspBossColor else cfg.EspMobColor,
					})
				end
			end
		end
	end
	local function addModel(key, model, label, color)
		local root = model:FindFirstChild("HumanoidRootPart")
		if not (root and root:IsA("BasePart")) then
			return
		end
		local humanoid = model:FindFirstChildOfClass("Humanoid")
		table.insert(targets, {
			key = key,
			model = model,
			label = label,
			top = root.Position + Vector3.new(0, 3, 0),
			bottom = root.Position - Vector3.new(0, 3, 0),
			position = root.Position,
			health = humanoid and humanoid.Health,
			maxHealth = humanoid and humanoid.MaxHealth,
			color = color,
		})
	end
	if cfg.EspPlayers then
		for _, player in ipairs(Players:GetPlayers()) do
			local character = player.Character
			if player ~= LocalPlayer and character then
				addModel("player:" .. player.UserId, character, player.DisplayName, cfg.EspPlayerColor)
			end
		end
	end
	local deliveryRoot
	if cfg.EspDelivery and IN_LOBBY and gacha.delivery and gacha.delivery.target then
		deliveryRoot = gacha.deliveryNpc(tostring(gacha.delivery.target))
		if deliveryRoot and deliveryRoot.Parent then
			addModel("delivery", deliveryRoot.Parent, "Deliver: " .. deliveryRoot.Parent.Name, cfg.EspDeliveryColor)
		end
	end
	if cfg.EspNpcs and IN_LOBBY then
		local systems = Workspace:FindFirstChild("Systems")
		for _, folderName in ipairs({ "NPCS", "ScatteredNPCS" }) do
			local folder = systems and systems:FindFirstChild(folderName)
			if folder then
				for _, model in ipairs(folder:GetChildren()) do
					if model:IsA("Model") and not (deliveryRoot and deliveryRoot.Parent == model) then
						addModel("npc:" .. model:GetFullName(), model, model.Name, cfg.EspNpcColor)
					end
				end
			end
		end
	end
	return targets
end

function VisualApi.render()
	local cfg = VisualApi.cfg
	local camera = Workspace.CurrentCamera
	if not camera then
		return
	end
	local _, root = characterParts()
	local origin = root and root.Position or camera.CFrame.Position
	local seen = {}
	local viewport = camera.ViewportSize
	for _, target in ipairs(VisualApi.collect(origin)) do
		seen[target.key] = true
		local entry = VisualApi.entry(target.key)
		local top, topOn = camera:WorldToViewportPoint(target.top)
		local bottom, bottomOn = camera:WorldToViewportPoint(target.bottom)
		VisualApi.setCham(target.key, cfg.EspChams and target.model or nil, target.color)
		if not (topOn or bottomOn) or top.Z <= 0 then
			VisualApi.hideEntry(entry)
		else
			local height = math.max(math.abs(bottom.Y - top.Y), 6)
			local width = height * 0.6
			local x = (top.X + bottom.X) / 2 - width / 2
			local y = math.min(top.Y, bottom.Y)
			entry.box.Visible = cfg.EspBoxes
			entry.box.Position = Vector2.new(x, y)
			entry.box.Size = Vector2.new(width, height)
			entry.box.Color = target.color
			local parts = {}
			if cfg.EspNames then
				table.insert(parts, target.label)
			end
			if cfg.EspDistance then
				table.insert(parts, "[" .. math.floor((target.position - origin).Magnitude) .. "m]")
			end
			if cfg.EspHealth and target.health and not (target.maxHealth and target.maxHealth > 0) then
				table.insert(parts, formatNumber(math.floor(target.health)) .. " HP")
			end
			entry.text.Visible = #parts > 0
			entry.text.Text = table.concat(parts, " ")
			entry.text.Position = Vector2.new(x + width / 2, y - 16)
			entry.text.Color = target.color
			local showBar = cfg.EspHealth and target.health ~= nil and target.maxHealth ~= nil and target.maxHealth > 0
			entry.barBack.Visible = showBar
			entry.bar.Visible = showBar
			if showBar then
				local fraction = math.clamp(target.health / target.maxHealth, 0, 1)
				local barX = x - 5
				entry.barBack.From = Vector2.new(barX, y + height + 1)
				entry.barBack.To = Vector2.new(barX, y - 1)
				entry.bar.From = Vector2.new(barX, y + height)
				entry.bar.To = Vector2.new(barX, y + height - height * fraction)
				entry.bar.Color = Color3.fromRGB(255, 60, 60):Lerp(Color3.fromRGB(80, 255, 100), fraction)
			end
			entry.tracer.Visible = cfg.EspTracers
			entry.tracer.From = Vector2.new(viewport.X / 2, viewport.Y)
			entry.tracer.To = Vector2.new(x + width / 2, y + height)
			entry.tracer.Color = target.color
		end
	end
	for key in pairs(VisualApi.pool) do
		if not seen[key] then
			VisualApi.removeEntry(key)
			VisualApi.maxHealth[key] = nil
		end
	end
	for key in pairs(VisualApi.chams) do
		if not seen[key] then
			VisualApi.setCham(key, nil)
		end
	end
	if cfg.CustomFov then
		camera.FieldOfView = cfg.Fov
	end
end

function VisualApi.clear()
	for key in pairs(VisualApi.pool) do
		VisualApi.removeEntry(key)
	end
	for key in pairs(VisualApi.chams) do
		VisualApi.setCham(key, nil)
	end
	table.clear(VisualApi.maxHealth)
end

function VisualApi.refresh()
	local cfg = VisualApi.cfg
	local espOn = VisualApi.supported and (cfg.EspMobs or cfg.EspPlayers or cfg.EspNpcs or cfg.EspDelivery)
	local active = espOn or cfg.CustomFov
	if not espOn then
		VisualApi.clear()
	end
	if active and not VisualApi.connection and not API.Unloaded then
		VisualApi.connection = RunService.RenderStepped:Connect(function()
			local ok, err = pcall(VisualApi.render)
			if not ok then
				warn("Visuals: " .. tostring(err))
			end
		end)
	elseif not active and VisualApi.connection then
		VisualApi.connection:Disconnect()
		VisualApi.connection = nil
	end
end

function VisualApi.set(key, value)
	VisualApi.cfg[key] = value
	VisualApi.refresh()
end

function VisualApi.setCustomFov(value)
	local camera = Workspace.CurrentCamera
	if value and not VisualApi.cfg.CustomFov and camera then
		VisualApi.fovPrior = camera.FieldOfView
	end
	VisualApi.cfg.CustomFov = value == true
	if not VisualApi.cfg.CustomFov and VisualApi.fovPrior and camera then
		camera.FieldOfView = VisualApi.fovPrior
		VisualApi.fovPrior = nil
	end
	VisualApi.refresh()
end

VisualApi.BRIGHT = {
	Ambient = Color3.new(1, 1, 1),
	OutdoorAmbient = Color3.new(1, 1, 1),
	Brightness = 2,
	ClockTime = 14,
	FogEnd = 1e6,
	GlobalShadows = false,
}

function VisualApi.setFullBright(value)
	VisualApi.cfg.FullBright = value == true
	if VisualApi.lightConn then
		VisualApi.lightConn:Disconnect()
		VisualApi.lightConn = nil
	end
	if VisualApi.cfg.FullBright then
		if not VisualApi.lighting then
			VisualApi.lighting = {}
			for key in pairs(VisualApi.BRIGHT) do
				VisualApi.lighting[key] = Lighting[key]
			end
		end
		local function apply()
			for key, value2 in pairs(VisualApi.BRIGHT) do
				if Lighting[key] ~= value2 then
					Lighting[key] = value2
				end
			end
		end
		apply()
		VisualApi.lightConn = Lighting.Changed:Connect(function()
			if VisualApi.cfg.FullBright and not API.Unloaded then
				apply()
			end
		end)
	elseif VisualApi.lighting then
		for key, value2 in pairs(VisualApi.lighting) do
			pcall(function()
				Lighting[key] = value2
			end)
		end
		VisualApi.lighting = nil
	end
end

API.Track(function()
	if VisualApi.connection then
		VisualApi.connection:Disconnect()
		VisualApi.connection = nil
	end
	VisualApi.clear()
	VisualApi.setCustomFov(false)
	VisualApi.setFullBright(false)
end)

VisualApi.streamer = {
	alias = "Relwx",
	originals = setmetatable({}, { __mode = "k" }),
	watched = setmetatable({}, { __mode = "k" }),
	connections = {},
	humanoidName = nil,
}

function VisualApi.streamerNames()
	local names = { LocalPlayer.Name, LocalPlayer.DisplayName, "@" .. LocalPlayer.Name }
	table.sort(names, function(a, b)
		return #a > #b
	end)
	return names
end

function VisualApi.maskText(text)
	local alias = VisualApi.streamer.alias
	for _, name in ipairs(VisualApi.streamerNames()) do
		if name ~= "" then
			local escaped = string.gsub(name, "%p", "%%%0")
			text = string.gsub(text, escaped, alias)
		end
	end
	text = string.gsub(text, tostring(LocalPlayer.UserId), alias)
	return text
end

function VisualApi.maskObject(object)
	if not (object:IsA("TextLabel") or object:IsA("TextButton") or object:IsA("TextBox")) then
		return
	end
	local state = VisualApi.streamer
	local function apply()
		if not VisualApi.cfg.StreamerMode then
			return
		end
		local text = object.Text
		local masked = VisualApi.maskText(text)
		if masked ~= text then
			state.originals[object] = text
			object.Text = masked
		end
	end
	if not state.watched[object] then
		state.watched[object] = object:GetPropertyChangedSignal("Text"):Connect(apply)
	end
	apply()
end

function VisualApi.maskCharacter(character)
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if humanoid and humanoid.DisplayName ~= VisualApi.streamer.alias then
		VisualApi.streamer.humanoidName = VisualApi.streamer.humanoidName or { humanoid = humanoid, value = humanoid.DisplayName }
		humanoid.DisplayName = VisualApi.streamer.alias
	end
end

function VisualApi.setStreamerMode(value)
	VisualApi.cfg.StreamerMode = value == true
	local state = VisualApi.streamer
	for _, connection in ipairs(state.connections) do
		connection:Disconnect()
	end
	table.clear(state.connections)
	local roots = { LocalPlayer:FindFirstChildOfClass("PlayerGui"), Workspace }
	pcall(function()
		table.insert(roots, game:GetService("CoreGui"))
	end)
	if type(gethui) == "function" then
		pcall(function()
			table.insert(roots, gethui())
		end)
	end
	if VisualApi.cfg.StreamerMode and not API.Unloaded then
		for _, root in ipairs(roots) do
			pcall(function()
				for _, object in ipairs(root:GetDescendants()) do
					VisualApi.maskObject(object)
				end
				table.insert(state.connections, root.DescendantAdded:Connect(function(object)
					VisualApi.maskObject(object)
				end))
			end)
		end
		VisualApi.maskCharacter(LocalPlayer.Character)
		table.insert(state.connections, LocalPlayer.CharacterAdded:Connect(function(character)
			state.humanoidName = nil
			character:WaitForChild("Humanoid", 10)
			if VisualApi.cfg.StreamerMode then
				VisualApi.maskCharacter(character)
			end
		end))
		return
	end
	for object, connection in pairs(state.watched) do
		connection:Disconnect()
		state.watched[object] = nil
	end
	for object, text in pairs(state.originals) do
		pcall(function()
			if object.Parent then
				object.Text = text
			end
		end)
		state.originals[object] = nil
	end
	if state.humanoidName then
		pcall(function()
			state.humanoidName.humanoid.DisplayName = state.humanoidName.value
		end)
		state.humanoidName = nil
	end
end

API.Track(function()
	VisualApi.setStreamerMode(false)
end)

function VisualApi.buildTab(tab)
	local Esp = tab:AddLeftGroupbox({ Name = "ESP", Icon = "eye" })
	local function toggle(box, name, key)
		box:CreateToggle({
			Name = name,
			CurrentValue = VisualApi.cfg[key],
			Flag = key,
			Callback = function(value)
				VisualApi.set(key, value == true)
			end,
		})
	end
	local function color(box, name, key)
		box:CreateColorPicker({
			Name = name,
			Default = VisualApi.cfg[key],
			Flag = key,
			Callback = function(value)
				if typeof(value) == "Color3" then
					VisualApi.cfg[key] = value
				end
			end,
		})
	end
	Esp:CreateStatus({
		Name = "Drawing",
		Style = "Row",
		UpdateRate = 5,
		Update = function()
			if VisualApi.supported then
				return nil
			end
			return "Executor has no Drawing library", "Error"
		end,
	})
	toggle(Esp, "Mob ESP", "EspMobs")
	color(Esp, "Mob colour", "EspMobColor")
	color(Esp, "Boss colour", "EspBossColor")
	toggle(Esp, "Player ESP", "EspPlayers")
	color(Esp, "Player colour", "EspPlayerColor")
	toggle(Esp, "NPC ESP", "EspNpcs")
	color(Esp, "NPC colour", "EspNpcColor")
	toggle(Esp, "Delivery Target ESP", "EspDelivery")
	color(Esp, "Delivery colour", "EspDeliveryColor")
	Esp:CreateDivider()
	for _, pair in ipairs({ { "Boxes", "EspBoxes" }, { "Names", "EspNames" }, { "Distance", "EspDistance" }, { "Health", "EspHealth" }, { "Tracers", "EspTracers" }, { "Chams", "EspChams" } }) do
		toggle(Esp, pair[1], pair[2])
	end

	local Graphics = tab:AddRightGroupbox({ Name = "Graphics", Icon = "sun" })
	Graphics:CreateToggle({
		Name = "Full Bright",
		CurrentValue = false,
		Flag = "FullBright",
		Callback = function(value)
			VisualApi.setFullBright(value == true)
		end,
	})
	Graphics:CreateToggle({
		Name = "Custom FOV",
		CurrentValue = false,
		Flag = "CustomFov",
		Callback = function(value)
			VisualApi.setCustomFov(value == true)
		end,
	})
	Graphics:CreateSlider({
		Name = "FOV",
		Range = { 30, 120 },
		Increment = 1,
		CurrentValue = VisualApi.cfg.Fov,
		Flag = "Fov",
		Callback = function(value)
			VisualApi.cfg.Fov = tonumber(value) or VisualApi.cfg.Fov
		end,
	})

	local Privacy = tab:AddRightGroupbox({ Name = "Privacy", Icon = "eye-off" })
	Privacy:CreateToggle({
		Name = "Streamer Mode",
		CurrentValue = false,
		Flag = "StreamerMode",
		Callback = function(value)
			VisualApi.setStreamerMode(value == true)
		end,
	})
end

function VisualApi.sync(readFlag)
	local cfg = VisualApi.cfg
	for _, key in ipairs({ "EspMobs", "EspPlayers", "EspNpcs", "EspDelivery", "EspBoxes", "EspNames", "EspDistance", "EspHealth", "EspTracers", "EspChams" }) do
		local value = readFlag(key, cfg[key])
		if type(value) == "boolean" then
			cfg[key] = value
		end
	end
	for _, key in ipairs({ "EspMobColor", "EspBossColor", "EspPlayerColor", "EspNpcColor", "EspDeliveryColor" }) do
		local value = readFlag(key, nil)
		if typeof(value) == "Color3" then
			cfg[key] = value
		end
	end
	cfg.Fov = tonumber(readFlag("Fov", cfg.Fov)) or cfg.Fov
	VisualApi.setFullBright(readFlag("FullBright", false) == true)
	VisualApi.setCustomFov(readFlag("CustomFov", false) == true)
	VisualApi.setStreamerMode(readFlag("StreamerMode", false) == true)
	VisualApi.refresh()
end



-- ====================================================================
-- PAYOMBØYZ UI LAYER — PayomboyUIz × PayomboyZ Engine
-- All game workers (Farm/Skill/Run/Lobby) already running above
-- ====================================================================

local PAYOMBOY_URL = "https://raw.githubusercontent.com/payomboyz333/Library/refs/heads/main/PayomboyUIz"
local function getPayomboyLibrary()
	local raw = game:HttpGet(PAYOMBOY_URL)
	raw = raw:gsub("Enum%.FontWeight%.Black", "Enum.FontWeight.Heavy")
	local cleanCode = raw:match("^(.-return%s+library)") or raw

		-- 0. Fix fakecallback blocking on uninitialized loaded flag
	cleanCode = cleanCode:gsub("if not loaded then repeat task%.wait%(%) until loaded end", "")
	-- 0.1 Preserve existing getgenv().configs from being wiped by PayomboyUIz
	cleanCode = cleanCode:gsub("getgenv%(%)%.configs%s*=%s*{.-}\n", "if not getgenv().configs then getgenv().configs = {} end\n")

	-- 1. Anti-bounce: turn off circular loop and tighten tween
	cleanCode = cleanCode:gsub("uipage%.Circular%s*=%s*true;", "uipage.Circular = false;")
	cleanCode = cleanCode:gsub("uipage%.TweenTime%s*=%s*0%.5;", "uipage.TweenTime = 0.2;")
	cleanCode = cleanCode:gsub("uipage%.EasingStyle%s*=%s*Enum%.EasingStyle%.Cubic;", "uipage.EasingStyle = Enum.EasingStyle.Quad;")

	-- 2. Deterministic tab switching without breaking @drawer_clip
	cleanCode = cleanCode:gsub("uipage:JumpToIndex%(tabIndex%)", [=[if activeDetailClose then activeDetailClose(true, false) end
			for _, _c in ipairs(page:GetChildren()) do
				if _c:IsA("ScrollingFrame") and _c.LayoutOrder == tabIndex then
					uipage:JumpTo(_c)
					break
				end
			end]=])

	cleanCode = cleanCode:gsub("prevNavBtn%%.MouseButton1Click:Connect%%(function%%()%%s*uipage:Previous%%()%%s*end%%)", [=[prevNavBtn.MouseButton1Click:Connect(function()\n\t\tif activeDetailClose then activeDetailClose(true, false) end\n\t\tuipage:Previous()\n\tend)]=])

	cleanCode = cleanCode:gsub("nextNavBtn%%.MouseButton1Click:Connect%%(function%%()%%s*uipage:Next%%()%%s*end%%)", [=[nextNavBtn.MouseButton1Click:Connect(function()\n\t\tif activeDetailClose then activeDetailClose(true, false) end\n\t\tuipage:Next()\n\tend)]=])

	-- 3. Detail Panel aesthetics (Solid dark grey with back button visible)
	cleanCode = cleanCode:gsub("backButton%.Visible%s*=%s*false", "backButton.Visible = true")
	cleanCode = cleanCode:gsub('detailTitle%.Position%s*=%s*UDim2%.new%(0,14,0,0%)', 'detailTitle.Position = UDim2.new(0,50,0,0)')
	cleanCode = cleanCode:gsub("detailPanel%.BackgroundColor3%s*=%s*Color3%.fromRGB%(26,25,29%);", "detailPanel.BackgroundColor3 = Color3.fromRGB(24, 25, 32); detailPanel.BackgroundTransparency = 0.02;")

	-- 4. Main background transparency so custom manga artwork is visible
	cleanCode = cleanCode:gsub("main%.BackgroundTransparency%s*=%s*0;", "main.BackgroundTransparency = 0.15;")
	cleanCode = cleanCode:gsub('page%.Name%s*=%s*"@page";', 'page.Name = "@page";page.ZIndex = 5;')

	-- 5. ScreenGui Sibling mode so all card layers render reliably
	cleanCode = cleanCode:gsub('args%.IgnoreGuiInset%s*=%s*true', 'args.IgnoreGuiInset = true; args.ZIndexBehavior = Enum.ZIndexBehavior.Sibling')

	-- 6. Card frame grey background & ZIndex elevation
	cleanCode = cleanCode:gsub("box_frame%.BackgroundTransparency%s*=%s*0;box_frame%.BackgroundColor3%s*=%s*Color3%.fromRGB%(42,%s*43,%s*48%);", [=[box_frame.ZIndex = 8;
			box_frame.BackgroundColor3 = Color3.fromRGB(30, 31, 38);
			box_frame.BackgroundTransparency = 0.04;]=])

	cleanCode = cleanCode:gsub("local CARD_MIN_WIDTH,CARD_MAX_WIDTH%s*=%s*155,260", "local CARD_MIN_WIDTH,CARD_MAX_WIDTH = 185,185")
	cleanCode = cleanCode:gsub("innerTitle%.TextSize%s*=%s*11;", "innerTitle.TextSize = 12;")
	cleanCode = cleanCode:gsub("rowTitle%.TextSize%s*=%s*11;", "rowTitle.TextSize = 12;")
	cleanCode = cleanCode:gsub("init.create_corner(4,box_frame)", "init.create_corner(6,box_frame)")
	cleanCode = cleanCode:gsub("local cardStroke%s*=%s*init%.stroke%(box_frame,0%.45,1,Color3%.fromRGB%(66,67,74%)%)", "local cardStroke = init.stroke(box_frame,0.35,1,Color3.fromRGB(68,71,82))")

	-- Card hover & restore states
	cleanCode = cleanCode:gsub("init%.tween%(box_frame,0%.2,Enum%.EasingStyle%.Circular,{BackgroundColor3%s*=%s*Color3%.fromRGB%(42,43,48%)}%)", "init.tween(box_frame,0.2,Enum.EasingStyle.Circular,{BackgroundColor3 = Color3.fromRGB(30,31,38)})")
	cleanCode = cleanCode:gsub("init%.tween%(cardStroke,0%.2,Enum%.EasingStyle%.Circular,{Color%s*=%s*Color3%.fromRGB%(66,67,74%),Transparency%s*=%s*0%.45}%)", "init.tween(cardStroke,0.2,Enum.EasingStyle.Circular,{Color = Color3.fromRGB(68,71,82),Transparency = 0.35})")
	cleanCode = cleanCode:gsub("init%.tween%(box_frame,0%.25,Enum%.EasingStyle%.Circular,{BackgroundColor3%s*=%s*Color3%.fromRGB%(54,55,62%)}%)", "init.tween(box_frame,0.25,Enum.EasingStyle.Circular,{BackgroundColor3 = Color3.fromRGB(42,44,52)})")
	cleanCode = cleanCode:gsub("init%.tween%(box_frame,0%.25,Enum%.EasingStyle%.Circular,{BackgroundColor3%s*=%s*Color3%.fromRGB%(42,%s*43,%s*48%)}%)", "init.tween(box_frame,0.25,Enum.EasingStyle.Circular,{BackgroundColor3 = Color3.fromRGB(30,31,38)})")

	local fn, compileErr = loadstring(cleanCode)
	if not fn then
		error("Failed to compile PayomboyUIz: " .. tostring(compileErr), 0)
	end
	return fn()
end

local function mountCustomBackground(main)
	if not main or main:FindFirstChild("MangaArtBackground") then return end
	main.BackgroundTransparency = 0.15
	main.BackgroundColor3 = Color3.fromRGB(18, 19, 24)

	local bg = Instance.new("ImageLabel")
	bg.Name = "MangaArtBackground"
	bg.Size = UDim2.fromScale(1, 1)
	bg.Position = UDim2.fromScale(0, 0)
	bg.BackgroundTransparency = 1
	bg.ScaleType = Enum.ScaleType.Crop
	bg.ImageTransparency = 0.08
	bg.ZIndex = 1
	bg.Parent = main
	local bgCorner = Instance.new("UICorner")
	bgCorner.CornerRadius = UDim.new(0, 10)
	bgCorner.Parent = bg

	local tint = Instance.new("Frame")
	tint.Name = "GlassTintOverlay"
	tint.Size = UDim2.fromScale(1, 1)
	tint.Position = UDim2.fromScale(0, 0)
	tint.BackgroundColor3 = Color3.fromRGB(14, 15, 20)
	tint.BackgroundTransparency = 0.45
	tint.BorderSizePixel = 0
	tint.ZIndex = 2
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
				if res and (res.StatusCode == 200 or res.Status == 200) and res.Body then
					body = res.Body
				end
			end
			if not body then body = game:HttpGet(rawUrl) end
			if body and #body > 0 and typeof(writefile) == "function" then
				writefile(fileName, body)
				if typeof(getAsset) == "function" then
					bg.Image = getAsset(fileName)
				end
			end
		end)
	end)
end

local function findMainWindow()
	local roots = { game:GetService("CoreGui") }
	if type(gethui) == "function" then
		pcall(function() table.insert(roots, gethui()) end)
	end
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

local library = getPayomboyLibrary()
local window  = library.create()

task.defer(function()
	local m = findMainWindow()
	if m then mountCustomBackground(m) end
end)

-- Automatic Dungeon Mouse Interaction (Unlocks mouse when UI is open, restores combat control when closed)
local UI_MOUSE_OVERRIDE_BIND = "PayomboyZ_UI_MouseOverride"
pcall(RunService.UnbindFromRenderStep, RunService, UI_MOUSE_OVERRIDE_BIND)

local function updateDungeonMouseInteraction()
	local m = findMainWindow()
	local isUiOpen = (m and m.Visible == true)
	if isUiOpen or Flags.DisableCombatCursor then
		UserInputService.MouseBehavior = Enum.MouseBehavior.Default
		UserInputService.MouseIconEnabled = true
		local crosshair = LocalPlayer.PlayerGui:FindFirstChild("Crosshair")
		if crosshair and crosshair:IsA("ScreenGui") and crosshair.Enabled then
			crosshair.Enabled = false
		end
	else
		-- When UI is closed and player has not forced DisableCombatCursor
		local crosshair = LocalPlayer.PlayerGui:FindFirstChild("Crosshair")
		if crosshair and crosshair:IsA("ScreenGui") and not crosshair.Enabled then
			crosshair.Enabled = true
		end
	end
end

RunService:BindToRenderStep(UI_MOUSE_OVERRIDE_BIND, Enum.RenderPriority.Last.Value + 10, updateDungeonMouseInteraction)
API.Track(function()
	pcall(RunService.UnbindFromRenderStep, RunService, UI_MOUSE_OVERRIDE_BIND)
end)

-- ==============================================================================
-- 🔘 PAYOMBØYZ FLOATING TOGGLE CAPSULE (DRAGGABLE + KEYBINDS)
-- ==============================================================================
local function setupFloatingToggle()
	local parentGui = (typeof(gethui) == "function") and gethui() or game:GetService("CoreGui")
	if parentGui:FindFirstChild("PayomboyZ_ToggleGui") then
		pcall(function() parentGui.PayomboyZ_ToggleGui:Destroy() end)
	end
	if parentGui:FindFirstChild("PayomboyZ_ToggleCapsule") then
		pcall(function() parentGui.PayomboyZ_ToggleCapsule:Destroy() end)
	end

	local toggleGui = Instance.new("ScreenGui")
	toggleGui.Name = "PayomboyZ_ToggleGui"
	toggleGui.ResetOnSpawn = false
	toggleGui.DisplayOrder = 999999
	toggleGui.Parent = parentGui

	local toggleCapsule = Instance.new("Frame")
	toggleCapsule.Name = "ObsidianToggleCapsule"
	toggleCapsule.Size = UDim2.fromOffset(210, 52)
	toggleCapsule.Position = UDim2.new(0, 16, 0.45, 0)
	toggleCapsule.BackgroundColor3 = Color3.fromRGB(18, 19, 24)
	toggleCapsule.BackgroundTransparency = 0.15
	toggleCapsule.BorderSizePixel = 0
	toggleCapsule.ClipsDescendants = true
	toggleCapsule.ZIndex = 99999
	toggleCapsule.Parent = toggleGui

	local tcCorner = Instance.new("UICorner")
	tcCorner.CornerRadius = UDim.new(0, 16)
	tcCorner.Parent = toggleCapsule

	local tcStroke = Instance.new("UIStroke")
	tcStroke.Color = Color3.fromRGB(255, 45, 85)
	tcStroke.Thickness = 1.5
	tcStroke.Transparency = 0.2
	tcStroke.Parent = toggleCapsule

	-- Avatar / Logo Frame
	local capAvatarFrame = Instance.new("Frame")
	capAvatarFrame.Size = UDim2.fromOffset(38, 38)
	capAvatarFrame.Position = UDim2.new(0, 7, 0.5, -19)
	capAvatarFrame.BackgroundColor3 = Color3.fromRGB(28, 12, 18)
	capAvatarFrame.BorderSizePixel = 0
	capAvatarFrame.ZIndex = 100000
	capAvatarFrame.Parent = toggleCapsule

	local caCorner = Instance.new("UICorner")
	caCorner.CornerRadius = UDim.new(1, 0)
	caCorner.Parent = capAvatarFrame

	local caStroke = Instance.new("UIStroke")
	caStroke.Color = Color3.fromRGB(255, 45, 85)
	caStroke.Thickness = 1.2
	caStroke.Transparency = 0.3
	caStroke.Parent = capAvatarFrame

	local capAvatarImg = Instance.new("ImageLabel")
	capAvatarImg.Size = UDim2.fromScale(1, 1)
	capAvatarImg.BackgroundTransparency = 1
	capAvatarImg.Image = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(LocalPlayer.UserId) .. "&w=150&h=150"
	capAvatarImg.ZIndex = 100001
	capAvatarImg.Parent = capAvatarFrame

	local caiCorner = Instance.new("UICorner")
	caiCorner.CornerRadius = UDim.new(1, 0)
	caiCorner.Parent = capAvatarImg

	-- Branding Label
	local capUserLabel = Instance.new("TextLabel")
	capUserLabel.Size = UDim2.new(1, -54, 0, 17)
	capUserLabel.Position = UDim2.new(0, 52, 0, 8)
	capUserLabel.BackgroundTransparency = 1
	capUserLabel.Text = "PAYOMBØYZ • @" .. tostring(LocalPlayer.Name)
	capUserLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	capUserLabel.Font = Enum.Font.GothamBold
	capUserLabel.TextSize = 11
	capUserLabel.TextXAlignment = Enum.TextXAlignment.Left
	capUserLabel.ZIndex = 100000
	capUserLabel.Parent = toggleCapsule

	-- Realtime FPS & Ping Metrics
	local capMetricsLabel = Instance.new("TextLabel")
	capMetricsLabel.Size = UDim2.new(1, -54, 0, 15)
	capMetricsLabel.Position = UDim2.new(0, 52, 0, 27)
	capMetricsLabel.BackgroundTransparency = 1
	capMetricsLabel.Text = "⚡ 60 FPS  •  📡 0 ms"
	capMetricsLabel.TextColor3 = Color3.fromRGB(255, 55, 85)
	capMetricsLabel.Font = Enum.Font.GothamBold
	capMetricsLabel.TextSize = 10
	capMetricsLabel.TextXAlignment = Enum.TextXAlignment.Left
	capMetricsLabel.ZIndex = 100000
	capMetricsLabel.Parent = toggleCapsule

	-- FPS & Ping Loop
	task.spawn(function()
		local frameCount = 0
		local lastFpsTime = tick()
		local fpsVal = 60
		local fpsConn = RunService.RenderStepped:Connect(function()
			frameCount = frameCount + 1
			local now = tick()
			if now - lastFpsTime >= 1 then
				fpsVal = frameCount
				frameCount = 0
				lastFpsTime = now
			end
		end)
		while toggleGui and toggleGui.Parent and toggleCapsule and toggleCapsule.Parent do
			local pingVal = 0
			pcall(function()
				pingVal = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
			end)
			capMetricsLabel.Text = string.format("⚡ %d FPS  •  📡 %d ms", fpsVal, pingVal)
			task.wait(0.8)
		end
		if fpsConn then fpsConn:Disconnect() end
	end)

	-- Click & Drag Button
	local capBtn = Instance.new("TextButton")
	capBtn.Size = UDim2.fromScale(1, 1)
	capBtn.BackgroundTransparency = 1
	capBtn.Text = ""
	capBtn.ZIndex = 100005
	capBtn.Parent = toggleCapsule

	local function toggleUI()
		local m = findMainWindow()
		if m then
			m.Visible = not m.Visible
			if m.Visible then
				UserInputService.MouseBehavior = Enum.MouseBehavior.Default
				UserInputService.MouseIconEnabled = true
			else
				if not Flags.DisableCombatCursor and not IN_LOBBY then
					pcall(function()
						UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
					end)
				end
			end
		end
	end

	-- Dragging Handler with Threshold
	local dragging = false
	local dragInput = nil
	local dragStart = nil
	local startPos = nil
	local hasDragged = false

	capBtn.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			hasDragged = false
			dragStart = input.Position
			startPos = toggleCapsule.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	capBtn.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - dragStart
			if math.abs(delta.X) > 3 or math.abs(delta.Y) > 3 then
				hasDragged = true
			end
			toggleCapsule.Position = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + delta.X,
				startPos.Y.Scale, startPos.Y.Offset + delta.Y
			)
		end
	end)

	capBtn.MouseButton1Click:Connect(function()
		if not hasDragged then
			toggleUI()
		end
	end)

	-- Keyboard Toggle Shortcuts: RightControl, RightShift, LeftAlt
	UserInputService.InputBegan:Connect(function(input, processed)
		if processed then return end
		if input.KeyCode == Enum.KeyCode.RightControl or input.KeyCode == Enum.KeyCode.RightShift or input.KeyCode == Enum.KeyCode.LeftAlt then
			toggleUI()
		end
	end)
end

task.defer(setupFloatingToggle)

-- Helpers
local function idsFromLabels(options)
	if type(options) == "string" then options = { options } end
	local ids = {}
	for _, label in ipairs(options or {}) do
		local id = MATERIAL_BY_LABEL[label]
		if id then table.insert(ids, id) end
	end
	return ids
end

local function slotsFromOptions(options)
	local slots = {}
	if type(options) == "string" then options = { options } end
	for _, label in ipairs(options or {}) do
		local slot = SKILL_SLOT[label]
		if slot then table.insert(slots, slot) end
	end
	table.sort(slots)
	return slots
end

local function firstOption(option)
	return if type(option) == "table" then option[1] else option
end

local function listFromOptions(options)
	if type(options) == "string" then return { options } end
	local list = {}
	for _, value in ipairs(options or {}) do table.insert(list, value) end
	return list
end

local function traitIdsFromLabels(options)
	local ids = {}
	for _, label in ipairs(listFromOptions(options)) do
		local id = TRAIT_BY_LABEL[label]
		if id then table.insert(ids, id) end
	end
	return ids
end

local function readFlag(name, default)
	if Config[name] ~= nil then return Config[name] end
	if _FlagsRaw[name] ~= nil then return _FlagsRaw[name] end
	local cfg = getgenv and getgenv().configs
	if type(cfg) == "table" and cfg[name] ~= nil then return cfg[name] end
	return default
end

-- KAITUN defaults
do
	local K = gacha.K
	if K.Mode then
		for _, key in ipairs(K.On) do
			if not K.Skip[key] and Flags[key] ~= nil then
				Flags[key] = true
			end
		end
		if IN_LOBBY then Flags.JoinChapter = 0 end
		if not GAMEMODE_CHOICES[Flags.JoinChoice] and #GAMEMODE_LABELS > 0 then
			local pick = GAMEMODE_LABELS[1]
			for _, label in ipairs(GAMEMODE_LABELS) do
				if string.sub(label, 1, 8) == "Story - " then pick = label; break end
			end
			Flags.JoinChoice = pick
		end
		if not K.Skip.AutoTrait then
			if K.TraitStopRarity and gacha.TRAIT_RARITY_RANK[K.TraitStopRarity] then
				Flags.TraitStopRarity = K.TraitStopRarity
			elseif #gacha.TRAIT_RARITY_OPTIONS > 1 then
				Flags.TraitStopRarity = gacha.TRAIT_RARITY_OPTIONS[#gacha.TRAIT_RARITY_OPTIONS]
			end
		end
		if not K.Skip.AutoSkillTree then
			if #CHARACTER_IDS > 0 then Flags.SkillTreeCharacters = table.clone(CHARACTER_IDS) end
			if #BRANCH_LABELS > 0 then Flags.SkillTreeBranches = table.clone(BRANCH_LABELS) end
		end
		Flags.LeaveMinutes = math.clamp(tonumber(K.LeaveMinutes) or 20, 1, 60)
		Flags.EmoteStopAllOwned = true
	end
end

-- Sync from saved config
do
	local function syncFlags()
		for _, name in ipairs({ "AutoFarm","AutoArise","AutoSkill","AutoSkillG","DynamicMovement","AutoNextChapter","AutoRetry",
			"AutoLeaveRun","AutoJoin","AutoUnlockNextStage","JoinAuto","JoinFriendsOnly","AutoDelivery","AutoMilestones","AutoDaily",
			"AutoQuests","AutoSummon","AutoTrait","AutoEmote","AutoUnlockSlots","SummonFavourite","SummonBuyLucky",
			"AutoCraft","AutoSkillTree","AutoEvolve","AutoBestAccessory","AutoBestTitle","AutoRarestCharacters",
			"AutoAchievements","AutoRedeemCodes","AutoSkipTutorial","AutoRetreat","SwitchOnCooldown","SkillCombo",
			"PingEnabled","UltBossPriority","AutoLeaveRuns","AutoDodgeIgris",
			"WebhookResults","WebhookRolls","WebhookKicked","WebhookHuTao",
			"Disable3DRendering","FpsBoost","UltraFpsBoost","DisableSkillVfx","DisablePlayerAnimations",
			"DisableCombatCursor","AntiGameplayPause","AutoReconnect","AutoSaveConfig","AutoLoadConfig",
		}) do
			Flags[name] = readFlag(name, false) == true
		end
		Flags.AutoLeave = readFlag("AutoLeave", true) == true
		Flags.AntiAfk = readFlag("AntiAfk", true) == true
		for _, name in ipairs({ "WebhookUrl","PingUserId" }) do
			local value = readFlag(name, "")
			if type(value) == "string" then Flags[name] = value end
		end
		Flags.PingMaterials = idsFromLabels(readFlag("PingMaterials", {}))
		local pingTier = firstOption(readFlag("PingMinTier", "Off"))
		if table.find(MATERIAL_TIER_OPTIONS, tostring(pingTier)) then
			Flags.PingMinTier = tostring(pingTier)
		end
		local targetMode = firstOption(readFlag("TargetMode", nil))
		if table.find(TARGET_MODES, targetMode) then Flags.TargetMode = targetMode end
		local switchUltMode = firstOption(readFlag("SwitchUltMode", nil))
		if switchUltMode == "Consider Ultimates" or switchUltMode == "Don't Consider Ultimates" then
			Flags.SwitchUltMode = switchUltMode
		end
		local retreatAction = firstOption(readFlag("RetreatAction", nil))
		if table.find(RETREAT_ACTIONS, retreatAction) then Flags.RetreatAction = retreatAction end
		for _, name in ipairs({ "RetreatHealth","RetreatResume","RetreatHeight","RetreatMaxSeconds",
			"JoinPlayers","JoinDelay","SummonSlot","SummonDelay","TraitDelay","CraftTarget","SkillTreeMaxTier",
			"MoveSpeed","AttackDistance","HeightOffset","OrbitSpeed","SkillRange","SkillMinEnemies",
			"ComboDelay","ResultDelay","LeaveMinutes","LeaveRuns",
		}) do
			local value = tonumber(readFlag(name, Flags[name]))
			if value then Flags[name] = value end
		end
		local mode = firstOption(readFlag("FarmMode", nil))
		if table.find(FARM_MODES, mode) then Flags.FarmMode = mode end
		do
			local joinChoice = firstOption(readFlag("JoinChoice", nil))
			if GAMEMODE_CHOICES[joinChoice] then Flags.JoinChoice = joinChoice end
			local chapter = readFlag("JoinChapter", nil)
			if type(chapter) == "table" then chapter = chapter[1] end
			Flags.JoinChapter = if chapter == "Highest Unlocked" then 0 else tonumber(chapter) or Flags.JoinChapter
			local joinDiff = firstOption(readFlag("JoinDifficulty", nil))
			if DIFFICULTY_INDEX[joinDiff] then Flags.JoinDifficulty = joinDiff end
			local spinType = firstOption(readFlag("SummonType", nil))
			if spinType == "Normal" or spinType == "Lucky" then Flags.SummonType = spinType end
			local payment = firstOption(readFlag("SummonPayment", nil))
			if payment then Flags.SummonPayment = string.lower(tostring(payment)) end
			Flags.SummonSlot = tonumber(firstOption(readFlag("SummonSlot", nil))) or Flags.SummonSlot
			local protect = firstOption(readFlag("ProtectRarity", nil))
			if protect then Flags.ProtectRarity = protect end
			local traitChar = firstOption(readFlag("TraitCharacter", nil))
			if table.find(gacha.TRAIT_CHARACTER_OPTIONS, traitChar) then Flags.TraitCharacter = traitChar end
			Flags.TraitTargets = traitIdsFromLabels(readFlag("TraitTargets", {}))
			Flags.SummonStopCharacters = listFromOptions(readFlag("SummonStopCharacters", {}))
			local bestStat = firstOption(readFlag("BestGearStat", nil))
			if table.find(gacha.BEST_STATS, bestStat) then Flags.BestGearStat = bestStat end
			Flags.EmoteTargets = listFromOptions(readFlag("EmoteTargets", {}))
			Flags.EmoteStopAllOwned = readFlag("EmoteStopAllOwned", false) == true
			local traitRarity = firstOption(readFlag("TraitStopRarity", "None"))
			if gacha.TRAIT_RARITY_RANK[traitRarity] then Flags.TraitStopRarity = traitRarity end
			local emoteRarity = firstOption(readFlag("EmoteStopRarity", "None"))
			if gacha.EMOTE_RARITY_RANK[emoteRarity] then Flags.EmoteStopRarity = emoteRarity end
			Flags.CraftItems = listFromOptions(readFlag("CraftItems", {}))
			Flags.SkillTreeCharacters = listFromOptions(readFlag("SkillTreeCharacters", {}))
			Flags.SkillTreeBranches = listFromOptions(readFlag("SkillTreeBranches", BRANCH_LABELS))
			Flags.SkillTreeMaxTier = tonumber(readFlag("SkillTreeMaxTier", 5)) or 5
		end
		local comboOrder = readFlag("ComboOrder", nil)
		if type(comboOrder) == "string" then
			Flags.ComboOrder = runtime.comboFromText(comboOrder)
		end
		local choice = readFlag("SkillChoice", nil)
		if choice ~= nil then Flags.SkillSlots = slotsFromOptions(choice) end
	end

	PlayerApi.setNoGameplayPaused(false)
	MenuApi.setAntiAfk(readFlag("AntiAfk", true) == true)
	syncFlags()
	VisualApi.sync(readFlag)
	PlayerApi.setDisableCombatCursor(readFlag("DisableCombatCursor", false) == true)
end

API.Track(function()
	pcall(function() if library.destroy then library.destroy() end end)
end)

local Locales = {
	TH = {
		Tab_Home = "หน้าหลัก (Home)",
		Tab_Farm = "ฟาร์ม (Farm)",
		Tab_Lobby = "เข้าห้อง (Lobby)",
		Tab_Gacha = "สุ่มตัว (Gacha)",
		Tab_Upgrade = "พัฒนา (Upgrade)",
		Tab_Player = "ผู้เล่น (Player)",
		Tab_Visuals = "ภาพ/ESP (Visuals)",
		Tab_Webhook = "แจ้งเตือน (Webhook)",
		Tab_Settings = "ตั้งค่า (Settings)",
	},
	EN = {
		Tab_Home = "Home",
		Tab_Farm = "Farm",
		Tab_Lobby = "Lobby",
		Tab_Gacha = "Gacha",
		Tab_Upgrade = "Upgrade",
		Tab_Player = "Player",
		Tab_Visuals = "Visuals",
		Tab_Webhook = "Webhook",
		Tab_Settings = "Settings",
	}
}
Flags.Language = readFlag("Language", "TH")


-- ====================================================================
-- 9 ORGANIZED TABS (DIRECT METHOD CHAINING — RIDE A PET STYLE)
-- ====================================================================

-- ── 1. หน้าหลัก (Home) ────────────────────────────────────────────────



-- Rarity color helper for gacha & roll menus
function gacha.rarityColor3(rarity)
	local entry = RollConfig and RollConfig.rarities and RollConfig.rarities[rarity]
	local c = entry and entry.color
	if typeof(c) == "ColorSequence" then
		c = c.Keypoints[1].Value
	end
	if typeof(c) == "Color3" then
		return c
	end
	local byName = {
		Common = Color3.fromRGB(176, 178, 186), Uncommon = Color3.fromRGB(110, 205, 120),
		Rare = Color3.fromRGB(80, 150, 255), Epic = Color3.fromRGB(175, 105, 255),
		Legendary = Color3.fromRGB(255, 190, 60), Exotic = Color3.fromRGB(255, 140, 70),
		Mythic = Color3.fromRGB(255, 85, 95), Arcane = Color3.fromRGB(70, 225, 235),
		Zenless = Color3.fromRGB(255, 235, 110), Secret = Color3.fromRGB(255, 110, 200),
	}
	if byName[tostring(rarity)] then
		return byName[tostring(rarity)]
	end
	local palette = {
		Color3.fromRGB(176, 178, 186), Color3.fromRGB(110, 205, 120), Color3.fromRGB(80, 150, 255),
		Color3.fromRGB(175, 105, 255), Color3.fromRGB(255, 190, 60), Color3.fromRGB(255, 85, 95),
		Color3.fromRGB(255, 110, 200),
	}
	local order = RollConfig and RollConfig.rarityOrder or {}
	local rank = table.find(order, rarity)
	return rank and palette[math.clamp(rank, 1, #palette)] or palette[1]
end

-- Character choices helper for Gacha / Upgrade menus
function gacha.characterChoices()
	local charOptions, charColors, rarityColors, charLabels = {}, {}, {}, {}
	do
		local rankOf = {}
		for i, r in ipairs((RollConfig and RollConfig.rarityOrder) or {}) do
			rankOf[r] = i
		end
		local function rarityOf(id)
			local r = RollConfig and RollConfig.rarityByCharacter and RollConfig.rarityByCharacter[id]
			if r == nil then
				local info = CharacterNames and CharacterNames[tostring(id)]
				r = info and info.rarity
			end
			return r
		end
		for _, id in ipairs(CHARACTER_IDS) do
			table.insert(charOptions, id)
			charColors[id] = gacha.rarityColor3(rarityOf(id))
			local r = rarityOf(id)
			charLabels[id] = characterName(id) .. (r and ("  ·  " .. tostring(r)) or "")
		end
		table.sort(charOptions, function(a, b)
			local ra, rb = rankOf[rarityOf(a)] or 0, rankOf[rarityOf(b)] or 0
			if ra ~= rb then
				return ra > rb
			end
			return a < b
		end)
		for _, r in ipairs(RARITY_OPTIONS) do
			if r ~= "None" then
				rarityColors[r] = gacha.rarityColor3(r)
			end
		end
	end
	return charOptions, charColors, charLabels, rarityColors
end

local FAILSAFE_MODES = { "Move Across Area", "Leave Run" }

local function buildPayomboyUI()
	local charChoices, charColors, charLabels = gacha.characterChoices()
	local traitCharOptions = { "Equipped Character" }
	for _, id in ipairs(charChoices) do table.insert(traitCharOptions, id) end

	-- ── 1. หน้าหลัก (Home) ────────────────────────────────────────────────
	local tabHome = window.create("หน้าหลัก (Home)")
	tabHome.Header({ Title = "Script & Session Status" })

	local card_home = tabHome.Toggle({
		Title = "PAYOMBØYZ HUB",
		Info = "Session info, performance, and report",
		Default = false,
		HasToggle = false,
		Callback = function() end,
	})
	card_home:Button({
		Title = "Print & Copy Report",
		Text = "Print Report",
		Callback = function()
			pcall(function()
				local snap = accountSnapshot()
				local curChar = currentCharacter(snap)
				local lines = {
					"========== รายงานตัวละคร PAYOMBØYZ HUB ==========",
					"ผู้เล่น: " .. LocalPlayer.DisplayName .. " (@" .. LocalPlayer.Name .. ")  UserId: " .. tostring(LocalPlayer.UserId),
					"เวอร์ชัน: " .. tostring(SCRIPT_VERSION) .. " | โหมด: " .. (IN_LOBBY and "LOBBY" or "RUN"),
					"ตัวละคร: " .. tostring(characterName(curChar)),
					"เงิน: " .. tostring(snap and snap.currencies and snap.currencies.money or 0),
					"เพชร: " .. tostring(snap and snap.currencies and snap.currencies.gems or 0),
					"XP: " .. tostring(snap and snap.currencies and snap.currencies.xp or 0),
					"เวลาทำงาน: " .. tostring(math.floor(os.clock() - (gacha.lobbyStart or os.clock()))) .. "s",
					"=================================================",
				}
				local text = table.concat(lines, "\n")
				print(text)
				if typeof(setclipboard) == "function" then setclipboard(text) end
			end)
		end,
	})
	card_home:Button({
		Title = "Rejoin Server",
		Text = "Rejoin",
		Callback = function()
			pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId) end)
		end,
	})
	card_home:Button({
		Title = "Reset Session Stats",
		Text = "Reset Stats",
		Callback = function() pcall(resetStats) end,
	})

	-- ── 2. ฟาร์ม (Farm) ───────────────────────────────────────────────────
	local tabFarm = window.create("ฟาร์ม (Farm)")

	tabFarm.Header({ Title = "Combat & Movement" })

	local card_farm = tabFarm.Toggle({
		Title = "Auto Farm",
		Info = "Lock onto enemies and attack automatically",
		Default = Flags.AutoFarm,
		HasToggle = true,
		Callback = function(v)
			Flags.AutoFarm = v == true
			if getgenv and getgenv().configs then getgenv().configs["AutoFarm"] = v == true end
			if not Flags.AutoFarm then runtime.target = nil end
			print("[PayomboyZ] Auto Farm: " .. tostring(Flags.AutoFarm))
		end,
	})
	card_farm:Dropdown({
		Title = "Target Priority",
		List = TARGET_MODES,
		Default = Flags.TargetMode,
		Multi = false,
		Callback = function(v)
			local s = firstOption(v)
			if table.find(TARGET_MODES, s) then Flags.TargetMode = s end
		end,
	})
	card_farm:Dropdown({
		Title = "Farm Mode",
		List = FARM_MODES,
		Default = Flags.FarmMode,
		Multi = false,
		Callback = function(v)
			local s = firstOption(v)
			if table.find(FARM_MODES, s) then Flags.FarmMode = s; runtime.refreshPose() end
		end,
	})
	card_farm:Slider({ Title = "Attack Distance", Min = 2, Max = 25, Default = Flags.AttackDistance, Round = 1, Suffix = " studs",
		Callback = function(v) Flags.AttackDistance = v; runtime.refreshPose() end })
	card_farm:Slider({ Title = "Height Offset", Min = -5, Max = 15, Default = Flags.HeightOffset, Round = 1, Suffix = " studs",
		Callback = function(v) Flags.HeightOffset = v; runtime.refreshPose() end })
	card_farm:Slider({ Title = "Orbit Speed", Min = 0, Max = 30, Default = Flags.OrbitSpeed, Round = 1,
		Callback = function(v) Flags.OrbitSpeed = v end })
	card_farm:Toggle({ Title = "Auto Dodge Igris", Info = "Dodge ground markers during Igris fight", Default = Flags.AutoDodgeIgris,
		Callback = function(v) Flags.AutoDodgeIgris = v == true end })
	card_farm:Toggle({ Title = "Dynamic Movement & Dash (Q)", Info = "Roam, patrol, and Dash (Q) while waiting for mobs or closing distance", Default = Flags.DynamicMovement,
		Callback = function(v)
			Flags.DynamicMovement = v == true
			if getgenv and getgenv().configs then getgenv().configs["DynamicMovement"] = v == true end
		end })

	local card_skills = tabFarm.Toggle({
		Title = "Skills & Arise",
		Info = "Cast abilities and summon shadows",
		Default = Flags.AutoSkill,
		HasToggle = true,
		Callback = function(v)
			Flags.AutoSkill = v == true
			if getgenv and getgenv().configs then getgenv().configs["AutoSkill"] = v == true end
		end,
	})
	card_skills:Toggle({ Title = "Auto Arise", Info = "Raise defeated bosses as shadows", Default = Flags.AutoArise,
		Callback = function(v) Flags.AutoArise = v == true end })
	card_skills:Toggle({ Title = "Auto Skill G (Ultimate)", Info = "Automatically casts Ultimate (Key G) when charged (100%)", Default = Flags.AutoSkillG,
		Callback = function(v)
			Flags.AutoSkillG = v == true
			if getgenv and getgenv().configs then getgenv().configs["AutoSkillG"] = v == true end
		end })
	card_skills:Dropdown({
		Title = "Skills To Use",
		List = SKILL_LABELS,
		Default = { "Skill 1", "Skill 2", "Skill 3" },
		Multi = true,
		Callback = function(v) Flags.SkillSlots = slotsFromOptions(v) end,
	})
	card_skills:Toggle({ Title = "Ultimate On Bosses Only", Default = Flags.UltBossPriority,
		Callback = function(v)
			Flags.UltBossPriority = v == true
			Flags.UltBossOnly = v == true
			if getgenv and getgenv().configs then
				getgenv().configs["UltBossPriority"] = v == true
				getgenv().configs["UltBossOnly"] = v == true
			end
		end })
	card_skills:Slider({ Title = "Combo Delay", Min = 0.1, Max = 2, Default = Flags.ComboDelay, Round = 0.1, Suffix = "s",
		Callback = function(v) Flags.ComboDelay = v end })

	local card_switch = tabFarm.Toggle({
		Title = "Switch Characters",
		Info = "Rotate active party hero on skill cooldown",
		Default = Flags.SwitchOnCooldown,
		HasToggle = true,
		Callback = function(v)
			Flags.SwitchOnCooldown = v == true
			if getgenv and getgenv().configs then getgenv().configs["SwitchOnCooldown"] = v == true end
		end,
	})
	card_switch:Dropdown({
		Title = "Switch Logic",
		List = { "Don't Consider Ultimates", "Consider Ultimates" },
		Default = Flags.SwitchUltMode,
		Multi = false,
		Callback = function(v)
			local s = firstOption(v)
			if s == "Consider Ultimates" or s == "Don't Consider Ultimates" then Flags.SwitchUltMode = s end
		end,
	})

	tabFarm.Header({ Title = "Safety & Run Exit" })

	local card_retreat = tabFarm.Toggle({
		Title = "Retreat To Heal",
		Info = "Evade danger when low on health",
		Default = Flags.AutoRetreat,
		HasToggle = true,
		Callback = function(v)
			Flags.AutoRetreat = v == true
			if getgenv and getgenv().configs then getgenv().configs["AutoRetreat"] = v == true end
		end,
	})
	card_retreat:Dropdown({
		Title = "Retreat Action",
		List = RETREAT_ACTIONS,
		Default = Flags.RetreatAction,
		Multi = false,
		Callback = function(v)
			local s = firstOption(v)
			if table.find(RETREAT_ACTIONS, s) then Flags.RetreatAction = s end
		end,
	})
	card_retreat:Slider({ Title = "Retreat Health", Min = 10, Max = 70, Default = Flags.RetreatHealth, Round = 1, Suffix = "%",
		Callback = function(v) Flags.RetreatHealth = v end })
	card_retreat:Slider({ Title = "Resume Health", Min = 50, Max = 100, Default = Flags.RetreatResume, Round = 1, Suffix = "%",
		Callback = function(v) Flags.RetreatResume = v end })
	card_retreat:Slider({ Title = "Retreat Height", Min = 10, Max = 60, Default = Flags.RetreatHeight, Round = 1, Suffix = " studs",
		Callback = function(v) Flags.RetreatHeight = v end })
	card_retreat:Slider({ Title = "Max Retreat Time", Min = 5, Max = 30, Default = Flags.RetreatMaxSeconds, Round = 1, Suffix = "s",
		Callback = function(v) Flags.RetreatMaxSeconds = v end })

	local card_failsafe = tabFarm.Toggle({
		Title = "Failsafe Protection",
		Info = "Automatic actions when mobs fail to spawn",
		Default = Flags.Failsafe,
		HasToggle = true,
		Callback = function(v)
			Flags.Failsafe = v == true
			runtime.idleSince = nil
		end,
	})
	card_failsafe:Dropdown({
		Title = "Action When Stuck",
		List = FAILSAFE_MODES,
		Default = Flags.FailsafeMode,
		Multi = false,
		Callback = function(v)
			local s = firstOption(v)
			if s == "Move Across Area" or s == "Leave Run" then Flags.FailsafeMode = s end
		end,
	})
	card_failsafe:Slider({ Title = "Trigger After", Min = 5, Max = 60, Default = Flags.FailsafeSeconds, Round = 1, Suffix = "s",
		Callback = function(v) Flags.FailsafeSeconds = v end })
	card_failsafe:Toggle({ Title = "Scan Area Before Leave", Default = Flags.FailsafeScanLeave,
		Callback = function(v) Flags.FailsafeScanLeave = v == true end })

	local card_runend = tabFarm.Toggle({
		Title = "Run Completion",
		Info = "Next chapter, retry, and auto leave logic",
		Default = Flags.AutoNextChapter,
		HasToggle = true,
		Callback = function(v)
			Flags.AutoNextChapter = v == true
		end,
	})
	card_runend:Toggle({ Title = "Auto Retry On Fail", Default = Flags.AutoRetry,
		Callback = function(v) Flags.AutoRetry = v == true end })
	card_runend:Toggle({ Title = "Auto Leave On Finish", Default = Flags.AutoLeave,
		Callback = function(v) Flags.AutoLeave = v == true end })
	card_runend:Slider({ Title = "Result Screen Delay", Min = 1, Max = 10, Default = Flags.ResultDelay, Round = 1, Suffix = "s",
		Callback = function(v) Flags.ResultDelay = v end })
	card_runend:Toggle({ Title = "Leave After Clears", Default = Flags.AutoLeaveRuns,
		Callback = function(v) Flags.AutoLeaveRuns = v == true end })
	card_runend:Slider({ Title = "Target Clear Runs", Min = 1, Max = 50, Default = Flags.LeaveRuns, Round = 1, Suffix = " runs",
		Callback = function(v) Flags.LeaveRuns = v end })
	card_runend:Slider({ Title = "Leave If Exceeds Time", Min = 5, Max = 45, Default = Flags.LeaveMinutes, Round = 1, Suffix = " min",
		Callback = function(v) Flags.LeaveMinutes = v end })

	-- ── 3. เข้าห้อง (Lobby) ────────────────────────────────────────────────
	local tabLobby = window.create("เข้าห้อง (Lobby)")

	tabLobby.Header({ Title = "Matchmaking & Quests" })

	local card_join = tabLobby.Toggle({
		Title = "Auto Join",
		Info = "Automatically queue into game modes",
		Default = Flags.AutoJoin,
		HasToggle = true,
		Callback = function(v)
			Flags.AutoJoin = v == true
			if getgenv and getgenv().configs then getgenv().configs["AutoJoin"] = v == true end
			if not Flags.AutoJoin and lobby.queueStatus == "inQuque" then
				pcall(function() LobbyPackets.leaveQuque:fire() end)
			end
			print("[PayomboyZ] Auto Join toggled: " .. tostring(Flags.AutoJoin))
		end,
	})
	card_join:Toggle({
		Title = "ปลดล็อคด่านใหม่ (Auto Unlock Next Stage)",
		Info = "ลงด่านสูงสุดที่ยังไม่ผ่านเพื่อปลดล็อคบทถัดไป (ปิด = เล่นตามด่านที่เลือก)",
		Default = Flags.AutoUnlockNextStage,
		Callback = function(v)
			Flags.AutoUnlockNextStage = v == true
			Flags.JoinAuto = v == true
		end,
	})
	card_join:Dropdown({
		Title = "Mode",
		List = GAMEMODE_LABELS,
		Default = Flags.JoinChoice ~= "" and Flags.JoinChoice or GAMEMODE_LABELS[1],
		Multi = false,
		Callback = function(v)
			local s = firstOption(v)
			if GAMEMODE_CHOICES[s] then Flags.JoinChoice = s end
		end,
	})
	card_join:Dropdown({
		Title = "Chapter",
		List = CHAPTER_LABELS,
		Default = tostring(Flags.JoinChapter == 0 and "Highest Unlocked" or Flags.JoinChapter),
		Multi = false,
		Callback = function(v)
			local s = firstOption(v)
			Flags.JoinChapter = if s == "Highest Unlocked" then 0 else tonumber(s) or 1
		end,
	})
	card_join:Dropdown({
		Title = "Difficulty",
		List = DIFFICULTY_LABELS,
		Default = Flags.JoinDifficulty,
		Multi = false,
		Callback = function(v)
			local s = firstOption(v)
			if DIFFICULTY_INDEX[s] then Flags.JoinDifficulty = s end
		end,
	})
	card_join:Slider({ Title = "Max Players", Min = 1, Max = 6, Default = Flags.JoinPlayers, Round = 1,
		Callback = function(v) Flags.JoinPlayers = v end })
	card_join:Toggle({ Title = "Friends Only", Default = Flags.JoinFriendsOnly,
		Callback = function(v) Flags.JoinFriendsOnly = v == true end })
	card_join:Slider({ Title = "Join Delay", Min = 0, Max = 60, Default = Flags.JoinDelay, Round = 1, Suffix = "s",
		Callback = function(v) Flags.JoinDelay = v end })
	card_join:Button({
		Title = "Leave Queue",
		Text = "Leave Queue",
		Callback = function()
			if not IN_LOBBY then return end
			pcall(function() LobbyPackets.leaveQuque:fire() end)
		end,
	})

	local card_delivery = tabLobby.Toggle({
		Title = "Auto Delivery",
		Info = "Automatically deliver items to quest NPCs (50/50)",
		Default = Flags.AutoDelivery,
		HasToggle = true,
		Callback = function(v)
			Flags.AutoDelivery = v == true
			if getgenv and getgenv().configs then getgenv().configs["AutoDelivery"] = v == true end
			print("[PayomboyZ] Auto Delivery: " .. tostring(Flags.AutoDelivery))
		end,
	})

	tabLobby.Header({ Title = "Daily Rewards" })

	local card_rewards = tabLobby.Toggle({
		Title = "Daily Rewards & Codes",
		Info = "Login gifts, quests, milestones, codes, tutorial",
		Default = false,
		HasToggle = false,
		Callback = function() end,
	})
	card_rewards:Toggle({ Title = "Auto Daily Reward", Default = Flags.AutoDaily,
		Callback = function(v) Flags.AutoDaily = v == true end })
	card_rewards:Toggle({ Title = "Auto Claim Quests", Default = Flags.AutoQuests,
		Callback = function(v) Flags.AutoQuests = v == true end })
	card_rewards:Toggle({ Title = "Auto Claim Milestones", Default = Flags.AutoMilestones,
		Callback = function(v) Flags.AutoMilestones = v == true end })
	card_rewards:Toggle({ Title = "Auto Claim Achievements", Default = Flags.AutoAchievements,
		Callback = function(v) Flags.AutoAchievements = v == true end })
	card_rewards:Toggle({ Title = "Auto Redeem Codes", Default = Flags.AutoRedeemCodes,
		Callback = function(v) Flags.AutoRedeemCodes = v == true end })
	card_rewards:Toggle({ Title = "Auto Skip Tutorial", Default = Flags.AutoSkipTutorial,
		Callback = function(v) Flags.AutoSkipTutorial = v == true end })
	card_rewards:Button({
		Title = "Redeem All Codes",
		Text = "Redeem All",
		Callback = function()
			if not IN_LOBBY then return end
			pcall(function() redeemAllCodes() end)
		end,
	})

	-- ── 4. สุ่มตัว (Gacha) ─────────────────────────────────────────────────
	local tabGacha = window.create("สุ่มตัว (Gacha)")

	tabGacha.Header({ Title = "Summon & Rerolls" })

	local card_summon = tabGacha.Toggle({
		Title = "Auto Summon",
		Info = "Automatically roll character banner",
		Default = Flags.AutoSummon,
		HasToggle = true,
		Callback = function(v) Flags.AutoSummon = v == true end,
	})
	card_summon:Dropdown({
		Title = "Type",
		List = { "Normal", "Lucky" },
		Default = Flags.SummonType,
		Multi = false,
		Callback = function(v)
			local s = firstOption(v)
			if s == "Normal" or s == "Lucky" then Flags.SummonType = s end
		end,
	})
	card_summon:Slider({ Title = "Slot", Min = 1, Max = 4, Default = Flags.SummonSlot, Round = 1,
		Callback = function(v) Flags.SummonSlot = v end })
	card_summon:Dropdown({
		Title = "Stop Characters",
		List = charChoices,
		Default = Flags.SummonStopCharacters,
		Multi = true,
		Callback = function(v) Flags.SummonStopCharacters = listFromOptions(v) end,
	})
	card_summon:Slider({ Title = "Delay", Min = 0.1, Max = 3, Default = Flags.SummonDelay, Round = 0.1, Suffix = "s",
		Callback = function(v) Flags.SummonDelay = v end })
	card_summon:Toggle({ Title = "Buy Lucky Potions", Default = Flags.SummonBuyLucky,
		Callback = function(v) Flags.SummonBuyLucky = v == true end })
	card_summon:Toggle({ Title = "Auto Favourite Pulls", Default = Flags.SummonFavourite,
		Callback = function(v) Flags.SummonFavourite = v == true end })

	local card_trait = tabGacha.Toggle({
		Title = "Auto Trait",
		Info = "Reroll character traits until target reached",
		Default = Flags.AutoTrait,
		HasToggle = true,
		Callback = function(v) Flags.AutoTrait = v == true end,
	})
	card_trait:Dropdown({
		Title = "Character",
		List = traitCharOptions,
		Default = Flags.TraitCharacter,
		Multi = false,
		Callback = function(v)
			local s = firstOption(v)
			if table.find(traitCharOptions, s) then Flags.TraitCharacter = s end
		end,
	})
	card_trait:Dropdown({
		Title = "Stop Rarity",
		List = gacha.TRAIT_RARITY_OPTIONS,
		Default = Flags.TraitStopRarity,
		Multi = false,
		Callback = function(v)
			local s = firstOption(v)
			if gacha.TRAIT_RARITY_RANK[s] then Flags.TraitStopRarity = s end
		end,
	})
	card_trait:Dropdown({
		Title = "Target Traits",
		List = TRAIT_LABELS,
		Default = Flags.TraitTargets,
		Multi = true,
		Callback = function(v) Flags.TraitTargets = traitIdsFromLabels(v) end,
	})
	card_trait:Slider({ Title = "Delay", Min = 0.1, Max = 2, Default = Flags.TraitDelay, Round = 0.1, Suffix = "s",
		Callback = function(v) Flags.TraitDelay = v end })

	local card_emote = tabGacha.Toggle({
		Title = "Auto Emotes",
		Info = "Roll emotes until target obtained",
		Default = Flags.AutoEmote,
		HasToggle = true,
		Callback = function(v) Flags.AutoEmote = v == true end,
	})
	card_emote:Dropdown({
		Title = "Target Emotes",
		List = gacha.EMOTE_NAMES,
		Default = Flags.EmoteTargets,
		Multi = true,
		Callback = function(v) Flags.EmoteTargets = listFromOptions(v) end,
	})
	card_emote:Dropdown({
		Title = "Stop Rarity",
		List = gacha.EMOTE_RARITY_OPTIONS,
		Default = Flags.EmoteStopRarity,
		Multi = false,
		Callback = function(v)
			local s = firstOption(v)
			if gacha.EMOTE_RARITY_RANK[s] then Flags.EmoteStopRarity = s end
		end,
	})
	card_emote:Toggle({ Title = "Stop All Owned", Default = Flags.EmoteStopAllOwned,
		Callback = function(v) Flags.EmoteStopAllOwned = v == true end })
	card_emote:Slider({ Title = "Delay", Min = 0.1, Max = 2, Default = Flags.EmoteDelay, Round = 0.1, Suffix = "s",
		Callback = function(v) Flags.EmoteDelay = v end })

	local card_slots = tabGacha.Toggle({
		Title = "Unlock Slots",
		Info = "Automatically unlock team slots when eligible",
		Default = Flags.AutoUnlockSlots,
		HasToggle = true,
		Callback = function(v) Flags.AutoUnlockSlots = v == true end,
	})
	card_slots:Slider({ Title = "Check Delay", Min = 1, Max = 5, Default = Flags.UnlockSlotsDelay, Round = 1, Suffix = "s",
		Callback = function(v) Flags.UnlockSlotsDelay = v end })

	-- ── 5. พัฒนา (Upgrade) ────────────────────────────────────────────────
	local tabProg = window.create("พัฒนา (Upgrade)")

	tabProg.Header({ Title = "Skill Tree & Crafting" })

	local card_tree = tabProg.Toggle({
		Title = "Auto Skill Tree",
		Info = "Upgrade character skill nodes automatically",
		Default = Flags.AutoSkillTree,
		HasToggle = true,
		Callback = function(v) Flags.AutoSkillTree = v == true end,
	})
	card_tree:Dropdown({
		Title = "Characters",
		List = charChoices,
		Default = Flags.SkillTreeCharacters,
		Multi = true,
		Callback = function(v) Flags.SkillTreeCharacters = listFromOptions(v) end,
	})
	card_tree:Dropdown({
		Title = "Branches",
		List = BRANCH_LABELS,
		Default = Flags.SkillTreeBranches,
		Multi = true,
		Callback = function(v) Flags.SkillTreeBranches = listFromOptions(v) end,
	})
	card_tree:Slider({ Title = "Max Tier", Min = 2, Max = 5, Default = Flags.SkillTreeMaxTier, Round = 1,
		Callback = function(v) Flags.SkillTreeMaxTier = v end })

	local card_evolve = tabProg.Toggle({
		Title = "Auto Evolve",
		Info = "Evolve equipped characters when requirements met",
		Default = Flags.AutoEvolve,
		HasToggle = true,
		Callback = function(v) Flags.AutoEvolve = v == true end,
	})

	local card_craft = tabProg.Toggle({
		Title = "Auto Craft",
		Info = "Craft selected accessories in forge",
		Default = Flags.AutoCraft,
		HasToggle = true,
		Callback = function(v) Flags.AutoCraft = v == true end,
	})
	card_craft:Dropdown({
		Title = "Accessories",
		List = CRAFT_LABELS,
		Default = Flags.CraftItems,
		Multi = true,
		Callback = function(v) Flags.CraftItems = listFromOptions(v) end,
	})
	card_craft:Slider({ Title = "Craft Until Owned", Min = 1, Max = 20, Default = Flags.CraftTarget, Round = 1,
		Callback = function(v) Flags.CraftTarget = v end })

	local card_gear = tabProg.Toggle({
		Title = "Best Gear",
		Info = "Equip highest stat gear and rarest heroes",
		Default = false,
		HasToggle = false,
		Callback = function() end,
	})
	card_gear:Toggle({ Title = "Equip Best Accessory", Default = Flags.AutoBestAccessory,
		Callback = function(v) Flags.AutoBestAccessory = v == true end })
	card_gear:Toggle({ Title = "Equip Best Title", Default = Flags.AutoBestTitle,
		Callback = function(v) Flags.AutoBestTitle = v == true end })
	card_gear:Dropdown({
		Title = "Best By Stat",
		List = gacha.BEST_STATS,
		Default = Flags.BestGearStat,
		Multi = false,
		Callback = function(v)
			local s = firstOption(v)
			if table.find(gacha.BEST_STATS, s) then Flags.BestGearStat = s end
		end,
	})
	card_gear:Toggle({ Title = "Equip Rarest Characters", Default = Flags.AutoRarestCharacters,
		Callback = function(v) Flags.AutoRarestCharacters = v == true end })

	-- ── 6. ผู้เล่น (Player) ────────────────────────────────────────────────
	local tabPlayer = window.create("ผู้เล่น (Player)")

	tabPlayer.Header({ Title = "Movement & Flight" })

	local card_move = tabPlayer.Toggle({
		Title = "Movement Utilities",
		Info = "Speed, infinite jump, noclip, instant prompt",
		Default = false,
		HasToggle = false,
		Callback = function() end,
	})
	card_move:Toggle({ Title = "WalkSpeed Enabled", Default = Flags.WalkSpeedEnabled,
		Callback = function(v) PlayerApi.setWalkSpeedEnabled(v == true) end })
	card_move:Slider({ Title = "Speed", Min = 16, Max = 250, Default = Flags.WalkSpeed, Round = 1,
		Callback = function(v) PlayerApi.setWalkSpeed(v) end })
	card_move:Toggle({ Title = "Infinite Jump", Default = Flags.InfJump,
		Callback = function(v) PlayerApi.setInfJump(v == true) end })
	card_move:Toggle({ Title = "Noclip", Default = Flags.NoClip,
		Callback = function(v) PlayerApi.setNoClip(v == true) end })
	card_move:Toggle({ Title = "Instant ProximityPrompt", Default = Flags.InstantProximityPrompt,
		Callback = function(v) PlayerApi.setInstantProximityPrompt(v == true) end })

	local card_fly = tabPlayer.Toggle({
		Title = "Fly",
		Info = "Fly freely across map boundaries",
		Default = Flags.Fly,
		HasToggle = true,
		Callback = function(v) PlayerApi.setFly(v == true) end,
	})
	card_fly:Slider({ Title = "Fly Speed", Min = 10, Max = 400, Default = Flags.FlySpeed, Round = 1,
		Callback = function(v) PlayerApi.setFlySpeed(v) end })

	tabPlayer.Header({ Title = "Optimization & Session" })

	local card_perf = tabPlayer.Toggle({
		Title = "Performance & FPS",
		Info = "Disable 3D, textures, VFX, animations",
		Default = false,
		HasToggle = false,
		Callback = function() end,
	})
	card_perf:Toggle({ Title = "Disable 3D Rendering", Default = Flags.Disable3DRendering,
		Callback = function(v) Flags.Disable3DRendering = v == true; PlayerApi.setDisable3D(v == true) end })
	card_perf:Toggle({ Title = "FPS Boost (Lighting)", Default = Flags.FpsBoost,
		Callback = function(v) Flags.FpsBoost = v == true; PlayerApi.setFpsBoost(v == true) end })
	card_perf:Toggle({ Title = "Ultra FPS Boost (Potato)", Default = Flags.UltraFpsBoost,
		Callback = function(v) Flags.UltraFpsBoost = v == true; PlayerApi.setUltraFpsBoost(v == true) end })
	card_perf:Toggle({ Title = "Disable Skill VFX", Default = Flags.DisableSkillVfx,
		Callback = function(v) Flags.DisableSkillVfx = v == true; PlayerApi.setDisableSkillVfx(v == true) end })
	card_perf:Toggle({ Title = "Disable Player Animations", Default = Flags.DisablePlayerAnimations,
		Callback = function(v) Flags.DisablePlayerAnimations = v == true; PlayerApi.setDisablePlayerAnimations(v == true) end })
	card_perf:Toggle({ Title = "Disable Combat Cursor", Default = Flags.DisableCombatCursor,
		Callback = function(v) Flags.DisableCombatCursor = v == true; PlayerApi.setDisableCombatCursor(v == true) end })

	local card_sess = tabPlayer.Toggle({
		Title = "Session Utilities",
		Info = "No pause, auto reconnect, anti-AFK",
		Default = false,
		HasToggle = false,
		Callback = function() end,
	})
	card_sess:Toggle({ Title = "No Gameplay Paused", Default = Flags.AntiGameplayPause,
		Callback = function(v) Flags.AntiGameplayPause = v == true; PlayerApi.setNoGameplayPaused(v == true) end })
	card_sess:Toggle({ Title = "Auto Reconnect On Kick", Default = Flags.AutoReconnect,
		Callback = function(v) Flags.AutoReconnect = v == true; PlayerApi.setAutoReconnect(v == true) end })
	card_sess:Toggle({ Title = "Anti-AFK (Prevent Kick)", Default = Flags.AntiAfk,
		Callback = function(v) Flags.AntiAfk = v == true; MenuApi.setAntiAfk(v == true) end })

	-- ── 7. ภาพ/ESP (Visuals) ──────────────────────────────────────────────
	local tabVisual = window.create("ภาพ/ESP (Visuals)")
	local vcfg = VisualApi.cfg or {}

	tabVisual.Header({ Title = "ESP & Vision" })

	local card_esp = tabVisual.Toggle({
		Title = "ESP Master",
		Info = "Highlight mobs, players, NPCs, delivery boxes",
		Default = false,
		HasToggle = false,
		Callback = function() end,
	})
	card_esp:Toggle({ Title = "ESP Mobs & Bosses", Default = vcfg.Mobs == true,
		Callback = function(v) if VisualApi.cfg then VisualApi.cfg.Mobs = v == true end end })
	card_esp:Toggle({ Title = "ESP Players", Default = vcfg.Players == true,
		Callback = function(v) if VisualApi.cfg then VisualApi.cfg.Players = v == true end end })
	card_esp:Toggle({ Title = "ESP NPCs", Default = vcfg.Npcs == true,
		Callback = function(v) if VisualApi.cfg then VisualApi.cfg.Npcs = v == true end end })
	card_esp:Toggle({ Title = "ESP Delivery Target", Default = vcfg.Delivery == true,
		Callback = function(v) if VisualApi.cfg then VisualApi.cfg.Delivery = v == true end end })

	local card_view = tabVisual.Toggle({
		Title = "Visual Tweaks",
		Info = "Fullbright, custom camera FOV, streamer mode",
		Default = false,
		HasToggle = false,
		Callback = function() end,
	})
	card_view:Toggle({ Title = "Fullbright", Default = readFlag("FullBright", false) == true,
		Callback = function(v) VisualApi.setFullBright(v == true) end })
	card_view:Toggle({ Title = "Custom FOV", Default = readFlag("CustomFov", false) == true,
		Callback = function(v) VisualApi.setCustomFov(v == true) end })
	card_view:Slider({ Title = "FOV Value", Min = 40, Max = 120, Default = vcfg.Fov or 70, Round = 1, Suffix = "°",
		Callback = function(v)
			if VisualApi.cfg then VisualApi.cfg.Fov = v end
			if readFlag("CustomFov", false) then pcall(function() workspace.CurrentCamera.FieldOfView = v end) end
		end })
	card_view:Toggle({ Title = "Streamer Mode", Info = "Hide player username on screen", Default = readFlag("StreamerMode", false) == true,
		Callback = function(v) VisualApi.setStreamerMode(v == true) end })

	-- ── 8. แจ้งเตือน (Webhook) ─────────────────────────────────────────────
	local tabWebhook = window.create("แจ้งเตือน (Webhook)")

	tabWebhook.Header({ Title = "Discord Notifications" })

	local card_hook = tabWebhook.Toggle({
		Title = "Discord Webhook",
		Info = "Send match results, rolls, and alerts",
		Default = false,
		HasToggle = false,
		Callback = function() end,
	})
	card_hook:Textbox({
		Title = "Webhook URL",
		Default = Flags.WebhookUrl,
		Callback = function(v) Flags.WebhookUrl = tostring(v or "") end,
	})
	card_hook:Toggle({ Title = "Send Match Results", Default = Flags.WebhookResults,
		Callback = function(v) Flags.WebhookResults = v == true end })
	card_hook:Toggle({ Title = "Send Gacha Rolls", Default = Flags.WebhookRolls,
		Callback = function(v) Flags.WebhookRolls = v == true end })
	card_hook:Toggle({ Title = "Send Disconnect Alerts", Default = Flags.WebhookKicked,
		Callback = function(v) Flags.WebhookKicked = v == true end })
	card_hook:Toggle({ Title = "Send Hu Tao Drops", Default = Flags.WebhookHuTao,
		Callback = function(v) Flags.WebhookHuTao = v == true end })
	card_hook:Button({
		Title = "Test Webhook",
		Text = "Send Test",
		Callback = function() pcall(testWebhook) end,
	})

	local card_ping = tabWebhook.Toggle({
		Title = "Discord Ping Alerts",
		Info = "Mention Discord user ID on rare drops",
		Default = Flags.PingEnabled,
		HasToggle = true,
		Callback = function(v) Flags.PingEnabled = v == true end,
	})
	card_ping:Textbox({
		Title = "Discord User ID",
		Default = Flags.PingUserId,
		Callback = function(v) Flags.PingUserId = tostring(v or "") end,
	})
	card_ping:Dropdown({
		Title = "Min Material Tier",
		List = MATERIAL_TIER_OPTIONS,
		Default = Flags.PingMinTier,
		Multi = false,
		Callback = function(v)
			local s = firstOption(v)
			if table.find(MATERIAL_TIER_OPTIONS, s) then Flags.PingMinTier = s end
		end,
	})
	card_ping:Dropdown({
		Title = "Ping Materials",
		List = MATERIAL_LABELS,
		Default = Flags.PingMaterials,
		Multi = true,
		Callback = function(v) Flags.PingMaterials = idsFromLabels(v) end,
	})
	card_ping:Button({
		Title = "Test Ping",
		Text = "Send Test Ping",
		Callback = function() pcall(testPing) end,
	})

	-- ── 9. ตั้งค่า (Settings) ──────────────────────────────────────────────
	local tabSettings = window.create("ตั้งค่า (Settings)")

	tabSettings.Header({ Title = "UI & Server Control" })

	local card_lang = tabSettings.Toggle({
		Title = "System Configuration",
		Info = "Language preference, server controls",
		Default = false,
		HasToggle = false,
		Callback = function() end,
	})
	card_lang:Dropdown({
		Title = "Active Language",
		List = { "ภาษาไทย (TH)", "English (EN)" },
		Default = (Flags.Language == "EN") and "English (EN)" or "ภาษาไทย (TH)",
		Multi = false,
		Callback = function(v)
			local choice = firstOption(v)
			Flags.Language = (choice == "English (EN)") and "EN" or "TH"
			print("[PayomboyZ] Language set to: " .. Flags.Language)
		end,
	})
	card_lang:Button({
		Title = "Rejoin Server",
		Text = "Rejoin",
		Callback = function()
			pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId) end)
		end,
	})
	card_lang:Button({
		Title = "Reset Session Stats",
		Text = "Reset Stats",
		Callback = function() pcall(resetStats) end,
	})

	tabSettings.Header({ Title = "Config & Storage" })

	local card_cfg = tabSettings.Toggle({
		Title = "Config Management",
		Info = "Auto Save and Auto Load script configuration",
		Default = false,
		HasToggle = false,
		Callback = function() end,
	})
	card_cfg:Toggle({
		Title = "Auto Save Config",
		Info = "Automatically saves settings to file upon change",
		Default = Flags.AutoSaveConfig,
		Callback = function(v)
			Flags.AutoSaveConfig = v == true
			if getgenv and getgenv().configs then getgenv().configs["AutoSaveConfig"] = v == true end
		end,
	})
	card_cfg:Toggle({
		Title = "Auto Load Config",
		Info = "Automatically load saved settings upon script execution",
		Default = Flags.AutoLoadConfig,
		Callback = function(v)
			Flags.AutoLoadConfig = v == true
			if getgenv and getgenv().configs then getgenv().configs["AutoLoadConfig"] = v == true end
		end,
	})
	card_cfg:Button({
		Title = "Save Config Now",
		Text = "Save Config",
		Callback = function()
			SaveConfig(true)
			print("[PayomboyZ] Configuration saved successfully to: " .. tostring(CONFIG_FILE))
		end,
	})
	card_cfg:Button({
		Title = "Load Config Now",
		Text = "Load Config",
		Callback = function()
			LoadConfig()
			syncFlags()
			print("[PayomboyZ] Configuration loaded successfully from: " .. tostring(CONFIG_FILE))
		end,
	})

	print("[PayomboyZ HUB] UI Loaded completely in " .. (IN_LOBBY and "LOBBY" or "RUN") .. " mode")
	getgenv().loaded = true
	_G.loaded = true
	loaded = true
end
buildPayomboyUI()
