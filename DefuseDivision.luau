local Library
local Notification
local startTime = os.clock()
local req_func = syn and syn.request or request
local function formatMS(seconds)
	if seconds < 0.001 then
		return string.format("%.3f µs", seconds * 1e6) --// microseconds
	elseif seconds < 1 then
		return string.format("%.3f ms", seconds * 1000) --// milliseconds
	else
		return string.format("%.3f s", seconds) --// seconds
	end
end

-- [[ hooks ]]
hookfunction(game:GetService("Stats").GetMemoryUsageMbForTag, function()
	coroutine.yield()
end)

local function fetch(a)
	return loadstring(
		game:HttpGetAsync(
			"https://github.com/Storm99999/Nocturnal-Remastered/blob/main/dd/" .. a .. ".luau?raw=true"
		)
	)()
end

if not getgenv().noct_notif then
	Notification = fetch("notifications")
	getgenv().noct_notif = Notification
else
	Notification = getgenv().noct_notif
end

Library = fetch("library")
getgenv().noct_lib = Library
writefile(
	"nocturnal/assets/paimon.webm",
	game:HttpGetAsync("https://github.com/Storm99999/whitelistkeys/blob/main/paimon.webm?raw=true")
)

--[[ defuse division ]]
local Services = setmetatable({}, {
	__index = function(self, idx)
		return game.GetService(game, idx)
	end,
})

type ResolverRecord = {
	history: { number: number, number2: number }, -- { time, hrpYaw, headYawDelta }
	lastSeenTime: number,
	bestOffsetScores: { [number]: number } | nil,
}

-- [[ services ]]
local runService, httpService, lightService, playerService, inputService, replicatedStorage, tweenService =
	Services.RunService,
	Services.HttpService,
	Services.Lighting,
	Services.Players,
	Services.UserInputService,
	Services.ReplicatedStorage,
	Services.TweenService

local getasset = syn and getsynasset or getcustomasset
local spoof = Instance.new("Animation", Services.CoreGui)
spoof.AnimationId = "rbxassetid://91725123526082"

-- [[ gui ]]
local window = Library:createWindow({})
window:createWatermark({ Text = 'nocturnal<font color="#724b84">.vip</font>' })
window:createBindList({})
window:createPreview({})

-- [[ self ]]
local nocturnal: {} = {
	connections = {},
	characters = {},
	threads = {},
	circle = nil,
	jumpcircle = nil,
	flashed = false,
	loadcomplete = false,
	sense = fetch("esp"),
	skins = { knife = { name = "", image = "" }, ak47 = "" },
	grenades = { "Flashbang", "SmokeGrenade", "Molotov", "HEGrenade", "Incendiary" },
	textures = {
		None = "",
		Hex = "http://www.roblox.com/asset/?id=488275840",
		Stars = "http://www.roblox.com/asset/?id=7209784983",
	},
	remotes = {
		hurtself = { replicatedStorage.Import.Remotes.HurtSelf },
	},
	bindables = {
		jump = { replicatedStorage.MovementBindables.jumping },
		land = { replicatedStorage.MovementBindables.landed },
	},
	action = debug.getupvalue(getconnections(replicatedStorage.MovementBindables.forceCrouch.Event)[1].Function, 1),
	configuration = require(playerService.LocalPlayer.PlayerScripts.controller.modules.config),
	cameraRotation = require(playerService.LocalPlayer.PlayerScripts.controller.modules.cameraRotation),
	completeMove = replicatedStorage.MovementBindables.setPosition,
	skies = {
		["Purple Nebula"] = {
			["SkyboxBk"] = "rbxassetid://159454299",
			["SkyboxDn"] = "rbxassetid://159454296",
			["SkyboxFt"] = "rbxassetid://159454293",
			["SkyboxLf"] = "rbxassetid://159454286",
			["SkyboxRt"] = "rbxassetid://159454300",
			["SkyboxUp"] = "rbxassetid://159454288",
		},

		["Night Sky"] = {
			["SkyboxBk"] = "rbxassetid://12064107",
			["SkyboxDn"] = "rbxassetid://12064152",
			["SkyboxFt"] = "rbxassetid://12064121",
			["SkyboxLf"] = "rbxassetid://12063984",
			["SkyboxRt"] = "rbxassetid://12064115",
			["SkyboxUp"] = "rbxassetid://12064131",
		},

		["Pink Daylight"] = {
			["SkyboxBk"] = "rbxassetid://271042516",
			["SkyboxDn"] = "rbxassetid://271077243",
			["SkyboxFt"] = "rbxassetid://271042556",
			["SkyboxLf"] = "rbxassetid://271042310",
			["SkyboxRt"] = "rbxassetid://271042467",
			["SkyboxUp"] = "rbxassetid://271077958",
		},

		["Morning Glow"] = {
			["SkyboxBk"] = "rbxassetid://1417494030",
			["SkyboxDn"] = "rbxassetid://1417494146",
			["SkyboxFt"] = "rbxassetid://1417494253",
			["SkyboxLf"] = "rbxassetid://1417494402",
			["SkyboxRt"] = "rbxassetid://1417494499",
			["SkyboxUp"] = "rbxassetid://1417494643",
		},

		["Setting Sun"] = {
			["SkyboxBk"] = "rbxassetid://626460377",
			["SkyboxDn"] = "rbxassetid://626460216",
			["SkyboxFt"] = "rbxassetid://626460513",
			["SkyboxLf"] = "rbxassetid://626473032",
			["SkyboxRt"] = "rbxassetid://626458639",
			["SkyboxUp"] = "rbxassetid://626460625",
		},

		["Seaside Sky"] = {
			["SkyboxBk"] = "http://www.roblox.com/asset/?id=4495864450",
			["SkyboxDn"] = "http://www.roblox.com/asset/?id=4495864887",
			["SkyboxFt"] = "http://www.roblox.com/asset/?id=4495865458",
			["SkyboxLf"] = "http://www.roblox.com/asset/?id=4495866035",
			["SkyboxRt"] = "http://www.roblox.com/asset/?id=4495866584",
			["SkyboxUp"] = "http://www.roblox.com/asset/?id=4495867486",
		},

		["Fade Blue"] = {
			["SkyboxBk"] = "rbxassetid://153695414",
			["SkyboxDn"] = "rbxassetid://153695352",
			["SkyboxFt"] = "rbxassetid://153695452",
			["SkyboxLf"] = "rbxassetid://153695320",
			["SkyboxRt"] = "rbxassetid://153695383",
			["SkyboxUp"] = "rbxassetid://153695471",
		},

		["Elegant Morning"] = {
			["SkyboxBk"] = "rbxassetid://153767241",
			["SkyboxDn"] = "rbxassetid://153767216",
			["SkyboxFt"] = "rbxassetid://153767266",
			["SkyboxLf"] = "rbxassetid://153767200",
			["SkyboxRt"] = "rbxassetid://153767231",
			["SkyboxUp"] = "rbxassetid://153767288",
		},

		["Neptune"] = {
			["SkyboxBk"] = "rbxassetid://218955819",
			["SkyboxDn"] = "rbxassetid://218953419",
			["SkyboxFt"] = "rbxassetid://218954524",
			["SkyboxLf"] = "rbxassetid://218958493",
			["SkyboxRt"] = "rbxassetid://218957134",
			["SkyboxUp"] = "rbxassetid://218950090",
		},

		["Redshift"] = {
			["SkyboxBk"] = "rbxassetid://401664839",
			["SkyboxDn"] = "rbxassetid://401664862",
			["SkyboxFt"] = "rbxassetid://401664960",
			["SkyboxLf"] = "rbxassetid://401664881",
			["SkyboxRt"] = "rbxassetid://401664901",
			["SkyboxUp"] = "rbxassetid://401664936",
		},

		["Aesthetic Night"] = {
			["SkyboxBk"] = "rbxassetid://1045964490",
			["SkyboxDn"] = "rbxassetid://1045964368",
			["SkyboxFt"] = "rbxassetid://1045964655",
			["SkyboxLf"] = "rbxassetid://1045964655",
			["SkyboxRt"] = "rbxassetid://1045964655",
			["SkyboxUp"] = "rbxassetid://1045962969",
		},
	},
	parts = {
		"Head",
		"UpperTorso",
		"LowerTorso",
		"LeftUpperArm",
		"LeftLowerArm",
		"LeftHand",
		"RightUpperArm",
		"RightLowerArm",
		"RightHand",
		"LeftUpperLeg",
		"LeftLowerLeg",
		"LeftFoot",
		"RightUpperLeg",
		"RightLowerLeg",
		"RightFoot",
	},
	edges = {
		{ 1, 2 },
		{ 2, 4 },
		{ 4, 3 },
		{ 3, 1 },
		{ 5, 6 },
		{ 6, 8 },
		{ 8, 7 },
		{ 7, 5 },
		{ 1, 5 },
		{ 2, 6 },
		{ 3, 7 },
		{ 4, 8 },
	},
	weapons = {
		ak47 = {
			class = "rifle",
			damage = 36,
			headshot_multiplier = 4.0,
			armor_ratio = 0.77,
			mag_size = 30,
			ammo_reserve = 90,
			rpm = 600,
			spread_standing = 0.002,
			spread_crouch = 0.0015,
			spread_air = 0.015,
			recoil = "high",
		},
		m4a4 = {
			class = "rifle",
			damage = 33,
			headshot_multiplier = 4.0,
			armor_ratio = 0.70,
			mag_size = 30,
			ammo_reserve = 90,
			rpm = 666,
			spread_standing = 0.002,
			spread_crouch = 0.0014,
			spread_air = 0.014,
			recoil = "medium",
		},
		m4a1 = {
			class = "rifle",
			damage = 38,
			headshot_multiplier = 3.475,
			armor_ratio = 0.70,
			mag_size = 20,
			ammo_reserve = 80,
			rpm = 600,
			spread_standing = 0.0018,
			spread_crouch = 0.0013,
			spread_air = 0.013,
			recoil = "low",
		},
		famas = {
			class = "rifle",
			damage = 30,
			headshot_multiplier = 4.0,
			armor_ratio = 0.70,
			mag_size = 25,
			ammo_reserve = 90,
			rpm = 666,
			spread_standing = 0.0025,
			spread_crouch = 0.0020,
			spread_air = 0.016,
			recoil = "medium",
		},
		galil = {
			class = "rifle",
			damage = 30,
			headshot_multiplier = 4.0,
			armor_ratio = 0.775,
			mag_size = 35,
			ammo_reserve = 90,
			rpm = 666,
			spread_standing = 0.0022,
			spread_crouch = 0.0017,
			spread_air = 0.015,
			recoil = "medium",
		},
		aug = {
			class = "rifle",
			damage = 28,
			headshot_multiplier = 4.0,
			armor_ratio = 0.90,
			mag_size = 30,
			ammo_reserve = 90,
			rpm = 600,
			spread_standing = 0.0020,
			spread_crouch = 0.0016,
			spread_air = 0.014,
			recoil = "medium",
		},
		sg553 = {
			class = "rifle",
			damage = 30,
			headshot_multiplier = 4.0,
			armor_ratio = 1.0,
			mag_size = 30,
			ammo_reserve = 90,
			rpm = 545,
			spread_standing = 0.0021,
			spread_crouch = 0.0017,
			spread_air = 0.014,
			recoil = "medium",
		},
		ssg08 = {
			class = "sniper",
			damage = 115,
			headshot_multiplier = 4.0,
			armor_ratio = 0.85,
			mag_size = 10,
			ammo_reserve = 30,
			rpm = 48,
			spread_standing = 0.0001,
			spread_crouch = 0,
			spread_air = 0.001,
			recoil = "low",
		},
		awp = {
			class = "sniper",
			damage = 115,
			headshot_multiplier = 4.0,
			armor_ratio = 0.975,
			mag_size = 5,
			ammo_reserve = 30,
			rpm = 41,
			spread_standing = 0.0001,
			spread_crouch = 0,
			spread_air = 0.001,
			recoil = "none",
		},
		g3sg1 = {
			class = "sniper",
			damage = 80,
			headshot_multiplier = 4.0,
			armor_ratio = 0.825,
			mag_size = 20,
			ammo_reserve = 90,
			rpm = 240,
			spread_standing = 0.0018,
			spread_crouch = 0.0012,
			spread_air = 0.012,
			recoil = "high",
		},
		scar20 = {
			class = "sniper",
			damage = 80,
			headshot_multiplier = 4.0,
			armor_ratio = 0.825,
			mag_size = 20,
			ammo_reserve = 90,
			rpm = 240,
			spread_standing = 0.0018,
			spread_crouch = 0.0012,
			spread_air = 0.012,
			recoil = "high",
		},
		negev = {
			class = "lmg",
			damage = 35,
			headshot_multiplier = 4.0,
			armor_ratio = 0.71,
			mag_size = 150,
			ammo_reserve = 300,
			rpm = 800,
			spread_standing = 0.0030,
			spread_crouch = 0.0025,
			spread_air = 0.018,
			recoil = "very high",
		},
		m249 = {
			class = "lmg",
			damage = 32,
			headshot_multiplier = 4.0,
			armor_ratio = 0.80,
			mag_size = 100,
			ammo_reserve = 200,
			rpm = 750,
			spread_standing = 0.0028,
			spread_crouch = 0.0023,
			spread_air = 0.017,
			recoil = "high",
		},
		p90 = {
			class = "smg",
			damage = 26,
			headshot_multiplier = 4.0,
			armor_ratio = 0.69,
			mag_size = 50,
			ammo_reserve = 100,
			rpm = 857,
			spread_standing = 0.0025,
			spread_crouch = 0.0020,
			spread_air = 0.015,
			recoil = "low",
		},
		ump45 = {
			class = "smg",
			damage = 35,
			headshot_multiplier = 4.0,
			armor_ratio = 0.65,
			mag_size = 25,
			ammo_reserve = 100,
			rpm = 666,
			spread_standing = 0.0023,
			spread_crouch = 0.0018,
			spread_air = 0.014,
			recoil = "medium",
		},
		mac10 = {
			class = "smg",
			damage = 29,
			headshot_multiplier = 4.0,
			armor_ratio = 0.575,
			mag_size = 30,
			ammo_reserve = 100,
			rpm = 800,
			spread_standing = 0.0027,
			spread_crouch = 0.0021,
			spread_air = 0.016,
			recoil = "high",
		},
		mp7 = {
			class = "smg",
			damage = 29,
			headshot_multiplier = 4.0,
			armor_ratio = 0.625,
			mag_size = 30,
			ammo_reserve = 120,
			rpm = 750,
			spread_standing = 0.0026,
			spread_crouch = 0.0020,
			spread_air = 0.015,
			recoil = "medium",
		},
		mp9 = {
			class = "smg",
			damage = 26,
			headshot_multiplier = 4.0,
			armor_ratio = 0.60,
			mag_size = 30,
			ammo_reserve = 120,
			rpm = 857,
			spread_standing = 0.0025,
			spread_crouch = 0.0019,
			spread_air = 0.015,
			recoil = "medium",
		},
		ppbizon = {
			class = "smg",
			damage = 27,
			headshot_multiplier = 4.0,
			armor_ratio = 0.63,
			mag_size = 64,
			ammo_reserve = 120,
			rpm = 750,
			spread_standing = 0.0028,
			spread_crouch = 0.0022,
			spread_air = 0.016,
			recoil = "low",
		},
		deserteagle = {
			class = "pistol",
			damage = 53,
			headshot_multiplier = 3.9,
			armor_ratio = 0.932,
			mag_size = 7,
			ammo_reserve = 35,
			rpm = 266,
			spread_standing = 0.0019,
			spread_crouch = 0.0016,
			spread_air = 0.008,
			recoil = "very high",
		},
		r8revolver = {
			class = "pistol",
			damage = 86,
			headshot_multiplier = 4.0,
			armor_ratio = 0.932,
			mag_size = 8,
			ammo_reserve = 30,
			rpm = 120,
			spread_standing = 0.0021,
			spread_crouch = 0.0017,
			spread_air = 0.009,
			recoil = "very high",
		},
		fiveseven = {
			class = "pistol",
			damage = 32,
			headshot_multiplier = 4.0,
			armor_ratio = 0.9115,
			mag_size = 20,
			ammo_reserve = 100,
			rpm = 400,
			spread_standing = 0.0020,
			spread_crouch = 0.0017,
			spread_air = 0.009,
			recoil = "low",
		},
		p250 = {
			class = "pistol",
			damage = 38,
			headshot_multiplier = 4.0,
			armor_ratio = 0.60,
			mag_size = 13,
			ammo_reserve = 52,
			rpm = 400,
			spread_standing = 0.0018,
			spread_crouch = 0.0014,
			spread_air = 0.008,
			recoil = "medium",
		},
		glock = {
			class = "pistol",
			damage = 30,
			headshot_multiplier = 4.0,
			armor_ratio = 0.47,
			mag_size = 20,
			ammo_reserve = 120,
			rpm = 400,
			spread_standing = 0.0023,
			spread_crouch = 0.0019,
			spread_air = 0.010,
			recoil = "medium",
		},
		p2000 = {
			class = "pistol",
			damage = 35,
			headshot_multiplier = 4.0,
			armor_ratio = 0.505,
			mag_size = 13,
			ammo_reserve = 62,
			rpm = 400,
			spread_standing = 0.0022,
			spread_crouch = 0.0018,
			spread_air = 0.009,
			recoil = "medium",
		},
		usp = {
			class = "pistol",
			damage = 40,
			headshot_multiplier = 4.0,
			armor_ratio = 0.50,
			mag_size = 12,
			ammo_reserve = 52,
			rpm = 400,
			spread_standing = 0.0021,
			spread_crouch = 0.0017,
			spread_air = 0.009,
			recoil = "low",
		},
	},
	dbg = nil,
	network = nil,
	attemptFireFunc = nil,
	getSecuredFolder = function()
		local a = workspace:FindFirstChild("_securefolder")
		if a then
			return a
		else
			a = Instance.new("Folder", workspace)
			a.Name = "_securefolder"
			return a
		end
		return nil
	end,
}

nocturnal.velocity = nocturnal.configuration.velocity
nocturnal.multipliers = nocturnal.configuration.moveStateMultipliers

-- [[ flags ]]
pcall(function()
	setfflag("AdornShadingAPI", "true")
end)

-- [[ imports ]]
--// locales
local ChrModels
local GlowModel
local WeatherPart
local Mouse = playerService.LocalPlayer:GetMouse()
local EffectsPart

do
	--// paimon webm
	nocturnal.paimon = game:GetObjects("rbxassetid://13119197703")[1]
	nocturnal.paimon.Parent = Services.CoreGui
	nocturnal.paimon.VideoFrame.Video = ""
	nocturnal.paimon.VideoFrame.Draggable = true
	nocturnal.paimon.VideoFrame["Bloxy Cola"].Video = ""
	----nocturnal.paimon.VideoFrame['Bloxy Cola'].Looped = true
	--nocturnal.paimon.VideoFrame['Bloxy Cola'].Playing = true
	nocturnal.paimon.VideoFrame["Bloxy Cola"].Draggable = true
	nocturnal.paimon.VideoFrame["Bloxy Cola"].BorderSizePixel = 0
	nocturnal.paimon.VideoFrame["Bloxy Cola"].BackgroundTransparency = 1
	nocturnal.paimon.Enabled = false
end

do
	--// custom models
	ChrModels = game:GetObjects("rbxassetid://12194933496")[1]
	ChrModels.Parent = replicatedStorage

	table.insert(nocturnal.characters, "None")

	for idx, character in ChrModels:GetChildren() do
		table.insert(nocturnal.characters, character.Name or "Unknown")
	end
end

do
	GlowModel = game:GetObjects("rbxassetid://140079653901085")[1]
	GlowModel.Parent = Services.CoreGui
end

do
	WeatherPart = game:GetObjects("rbxassetid://74271026090606")[1]
	WeatherPart.Parent = Services.CoreGui
end

do
	nocturnal.jumpcircle = game:GetObjects("rbxassetid://14871756509")[1]
	nocturnal.jumpcircle.Parent = Services.CoreGui
end

do
	EffectsPart = game:GetObjects("rbxassetid://100323444411174")[1]
	EffectsPart.Parent = Services.CoreGui
end

do
	local lib = loadstring(game:HttpGet("https://github.com/Storm99999/nocturnal/blob/main/l?raw=true"))()

	local lib2 = lib.new({
		NotificationLifetime = 3,
		NotificationPosition = "Middle",

		TextFont = Enum.Font.Code,
		TextColor = Color3.fromRGB(255, 255, 255),
		TextSize = 15,

		TextStrokeTransparency = 0,
		TextStrokeColor = Color3.fromRGB(0, 0, 0),
	})

	lib2:BuildNotificationUI()

	nocturnal.dbg = lib2
end

do
	local network

	for idx, v in getgc(true) do
		if typeof(v) == "function" then
			local info = debug.getinfo(v)
			if info.name == "AttemptSlash" then
				local ups = getupvalues(v)
				for idx, upvalue in ups do
					if typeof(upvalue) == "table" then
						if upvalue.Send then
							network = upvalue
						end
					end
				end
			elseif info.name == "AttemptFire" then
				local ups = getupvalues(v)

				if #ups > 0 then
					nocturnal.attemptFireFunc = v
				end
			end
		end
	end

	nocturnal.network = network
end

do
	local player = playerService.LocalPlayer

	local folder = Instance.new("Folder", workspace)
	Mouse.TargetFilter = folder

	local LIFETIME = 1.5

	function nocturnal:Beam(p0, p1)
		if Library.Flags.t_btt ~= "" then
			p1 += Vector3.new(-0.1, 0.2, 0)

			local a = Instance.new("Part", folder)
			a.Size = Vector3.zero
			a.Anchored = true
			a.CanCollide = false
			a.Transparency = 1
			a.Position = p0
			a.CanQuery = false

			local b = Instance.new("Part", folder)
			b.Size = Vector3.zero
			b.Anchored = true
			b.CanCollide = false
			b.CanQuery = false
			b.Transparency = 1
			b.Position = p1

			local at0 = Instance.new("Attachment", a)
			local at1 = Instance.new("Attachment", b)

			local beam = Instance.new("Beam", a)
			beam.Attachment0 = at0
			beam.Attachment1 = at1
			beam.FaceCamera = true
			beam.Width0 = 0.5
			beam.Width1 = 0.5
			beam.LightEmission = 6
			beam.Texture = Library.Flags.t_btt or "rbxassetid://446111271"
			beam.TextureMode = Enum.TextureMode.Static
			beam.TextureSpeed = 2
			beam.TextureLength = 1.3
			beam.Color = ColorSequence.new(Library.Flags.t_btc)

			task.delay(LIFETIME, function()
				a:Destroy()
				b:Destroy()
			end)
		else
			local beam = Instance.new("Part", workspace.ServerIgnore)

			beam.Name = "U()()()()()()+45+52432+42+423+423+423+42+3423+42+3/(3+3)"
			beam.Anchored = true
			beam.CanCollide = false
			beam.CanQuery = false
			beam.Material = "Neon"
			beam.Color = Library.Flags.t_btc
			beam.Size = Vector3.new(0.05, 0.05, (p0 - p1).Magnitude)
			beam.CFrame = CFrame.new(p0, p1) * CFrame.new(0, 0, -beam.Size.Z / 2)

			--// out
			tweenService
				:Create(
					beam,
					TweenInfo.new(LIFETIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{ Transparency = 1 }
				)
				:Play()
			task.delay(LIFETIME + 0.1, function()
				beam:Destroy()
			end)
		end
	end
end

function nocturnal:Draw(inst: DrawingObject, properties: DrawingProperties)
	local object = Drawing.new(inst)

	for idx, property in properties or {} do
		local succ, err = pcall(function()
			object[idx] = property
		end)

		if not succ then
			warn(err)
		end
	end

	return object
end

function nocturnal:FireBullet(player: Player, rayResult: RayResult, damage: number): ()
	local old = getthreadidentity()
	setthreadidentity(2)
	local cameraPos = workspace.CurrentCamera.CFrame.Position
	local gunName = playerService.LocalPlayer.Gun.Value
	local bulletId = getupvalue(nocturnal.attemptFireFunc, 19)
	local bulletInfo = {
		("PLR_%*_%*"):format(player.Name, rayResult.Instance.Name),
		{ rayResult.Instance.Position.X, rayResult.Instance.Position.Y, rayResult.Instance.Position.Z },
	}
	local shotArgs = {
		workspace:GetServerTimeNow(),
		gunName,
		{ cameraPos.X, cameraPos.Y, cameraPos.Z },
		{ { rayResult.Position, { bulletInfo } } },
		{ false, bulletId, { 1 }, false },
		{ { ["X"] = rayResult.Position.X, ["Y"] = rayResult.Position.Y, ["Z"] = rayResult.Position.Z } },
	}

	nocturnal.network:Send("Shot", shotArgs)
	playerService.LocalPlayer.PlayerGui.Values[gunName].Ammo.Value = playerService.LocalPlayer.PlayerGui.Values[gunName].Ammo.Value
		- 1
	setupvalue(nocturnal.attemptFireFunc, 19, bulletId + 1)
	setthreadidentity(old)

	if Library.Flags.t_bt then
		nocturnal:Beam(workspace.CurrentCamera.CFrame.Position, rayResult.Position)
	end

	if Library.Flags.ro_hs then
		local sound = Instance.new("Sound")
		sound.Name = "Hitsound_1"
		sound.Parent = Services.SoundService
		sound.SoundId = nocturnal:getSound(true)
		sound.Volume = 0.8
		sound.PlayOnRemove = true

		sound:Destroy()
	end

	if Library.Flags.ro_hl then
		if not Library.Flags.ro_effects then
			nocturnal.dbg:Notify(
				string.format(
					"Hit %s in %s for %s damage",
					player.Name,
					rayResult.Instance.Name,
					tostring(damage) or "100"
				)
			)
		else
			Notification.new(
				string.format(
					"Hit %s in %s for %s damage",
					player.Name,
					rayResult.Instance.Name,
					tostring(damage) or "100"
				)
			)
		end
	end
end

function nocturnal:gcptest(): ()
	local localPlayer = playerService.LocalPlayer
	local character = localPlayer.Character
	local hrp = character and character:FindFirstChild("HumanoidRootPart")
	if not hrp then
		return nil
	end

	local closestPlayer = nil
	local closestDist = math.huge

	for _, plr in playerService:GetPlayers() do
		if
			plr ~= localPlayer
			and plr.PlayerStates
			and plr.PlayerStates.Team.Value ~= localPlayer.PlayerStates.Team.Value
		then
			local char = plr.Character
			local root = char and char:FindFirstChild("HumanoidRootPart")
			local hum = char and char:FindFirstChildOfClass("Humanoid")

			if root and hum and hum.Health > 0 and plr.PlayerStates and plr.PlayerStates.Alive.Value then
				local dist = (root.Position - hrp.Position).Magnitude
				if dist < closestDist then
					closestDist = dist
					closestPlayer = plr
				end
			end
		end
	end

	return closestPlayer
end

function nocturnal:raycastToPlayer(targetPlayer)
	local localPlayer = playerService.LocalPlayer
	local char = targetPlayer.Character
	local targetRoot = char and char:FindFirstChild("HumanoidRootPart")
	if not targetRoot then
		return nil
	end

	local origin = workspace.CurrentCamera.CFrame.Position
	local direction = (targetRoot.Position - origin) * 1000

	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Blacklist
	params.FilterDescendantsInstances = { localPlayer.Character, workspace.CurrentCamera }
	params.IgnoreWater = true

	return workspace:Raycast(origin, direction, params)
end

function nocturnal:Transparency(t: number): number
	return 1 - t
end

function nocturnal:Units(a: number): number
	return (a * 0.075)
end

function nocturnal:Map(): string
	local map = workspace:FindFirstChild("Map")

	if map and map:FindFirstChild("Mapname") and typeof(map.Mapname.Value) == "string" then
		return map.Mapname.Value
	end

	return "Unknown"
end

function nocturnal:GetCharacterOverMouse(target)
	local target = Mouse.Target
	if not target then
		return nil
	end
	local model = target:FindFirstAncestorOfClass("Model")
	if not model then
		return nil
	end
	local enemy = playerService:GetPlayerFromCharacter(model) and model or nil
	if not enemy then
		return nil
	end

	return nocturnal:isTarget(enemy) and enemy or nil
end

function nocturnal:replicateCharacter(_c): ()
	local i = Instance.new("Model", workspace.ServerIgnore)
	i.Name = "Hitindicator"

	for _, v in _c:GetDescendants() do
		if v:IsA("BasePart") and v.Transparency ~= 1 then
			local a = v:Clone()
			a.CanCollide = false
			a.Parent = i
			a.Anchored = true
			a.Color = Library.Flags.t_hmc
			a.Material = "ForceField"
			a.Transparency = 0.75
			a.Reflectance = 0
			a.CollisionGroup = "Smoke"
			if a:IsA("MeshPart") then
				a.TextureID = ""
			end
			for _, c in a:GetChildren() do
				if not c:IsA("SpecialMesh") then
					c:Destroy()
				else
					c.TextureId = ""
				end
			end
		end
	end

	return i
end

local Import = replicatedStorage:WaitForChild("Import")
local Guns = Import:WaitForChild("Guns")
local Viewmodels = Import.Assets.Weapons
local Skins = Import.Assets:WaitForChild("Skins")
local WeaponsIndex = require(replicatedStorage.Import.WeaponsIndex)

local baseCT, baseT = Viewmodels.CTKnife.Viewmodel:Clone(), Viewmodels.TKnife.Viewmodel:Clone()
baseCT.Parent = game.CoreGui
baseT.Parent = game.CoreGui

local selectedSkins = {
	ak47 = "None",
	awp = "None",
	ssg08 = "None",
	deserteagle = "None",
	m4a1 = "None",
	ctknife = "None",
	tknife = "None",
}

local guiNames = {
	ak47 = "AK47",
	awp = "AWP",
	ssg08 = "SSG08",
	deserteagle = "DesertEagle",
	m4a1 = "M4A1",
	ctknife = "CTKnife",
	tknife = "TKnife",
}

function nocturnal:ChangeKnife(knife: string, skin: string): ()
	if knife == "None" then
		return
	end
	if knife == "Shadow Daggers" then
		knife = "push"
	end

	local sourceKnife = Viewmodels:FindFirstChild(knife)
	if not sourceKnife then
		return warn("source knife not found:", knife)
	end

	local sourceVM = sourceKnife:FindFirstChild("Viewmodel")
	if not sourceVM then
		return warn("source knife has no Viewmodel:", knife)
	end

	require(Viewmodels.CTKnife).Viewmodel = require(sourceKnife).Viewmodel
	require(Viewmodels.TKnife).Viewmodel = require(sourceKnife).Viewmodel

	if skin and skin ~= "None" then
		local skinFolder = Skins:FindFirstChild(knife:lower())
		if not skinFolder then
			return warn("bad skin folder")
		end

		local skinPath = skinFolder:FindFirstChild(skin)
		if not skinPath then
			return warn("bad skin path")
		end

		local texture = skinPath:FindFirstChildOfClass("SurfaceAppearance")
		if not texture then
			return warn("no SurfaceAppearance")
		end

		for _, vm in { require(Viewmodels.CTKnife).Viewmodel, require(Viewmodels.TKnife).Viewmodel } do
			for _, obj in vm:GetDescendants() do
				if obj:IsA("SurfaceAppearance") then
					local clone = texture:Clone()
					clone.Parent = obj.Parent
					obj:Destroy()
				end
			end
		end
	end
end

function nocturnal:GunSkin(gun: string, skin: string)
	if gun == "None" or skin == "None" then
		return
	end
	if not nocturnal:isAlive(playerService.LocalPlayer) then
		return
	end

	local actualGun = gun
	if gun == "ctknife" or gun == "tknife" then
		actualGun = Library.Flags.skin_weapon
	end
	if actualGun == "Shadow Daggers" then
		actualGun = "push"
	end

	local cam = workspace.CurrentCamera
	local vm = cam:FindFirstChild("Arms")
	if not vm then
		return
	end

	-- ref ReplicatedStorage.Import.Assets.Skins
	local gunFolder = Skins:FindFirstChild(actualGun:lower())
	if not gunFolder then
		return warn("No skins folder for gun:", actualGun)
	end

	local skinFolder = gunFolder:FindFirstChild(skin)
	if not skinFolder then
		return warn("Invalid skin:", skin)
	end

	local sourceSA = skinFolder:FindFirstChildOfClass("SurfaceAppearance")
	if not sourceSA then
		return warn("Skin has no SurfaceAppearance")
	end

	-- update ui using the original gun name, not actualGun
	local guiName = guiNames[gun]
	if guiName then
		local guiObj = playerService.LocalPlayer.PlayerGui.Display.Overlay.Loadout:FindFirstChild(guiName)
		if guiObj then
			if guiObj:FindFirstChild("Image") then
				guiObj.Image.Image = WeaponsIndex:Query(actualGun, "Image")
			end
			if guiObj:FindFirstChild("Namer") then
				guiObj.Namer.Text = WeaponsIndex:Query(actualGun, "Name") .. " | " .. skin
			end
		end
	end

	-- Apply
	local templateSA = sourceSA:Clone()
	for _, obj in vm:GetDescendants() do
		if obj:IsA("SurfaceAppearance") then
			local parentName = obj.Parent.Name:lower()
			if parentName ~= "glove" and parentName ~= "sleeve" then
				local parent = obj.Parent
				obj:Destroy()
				local newSA = templateSA:Clone()
				newSA.Parent = parent
			end
		end
	end

	if gun == "ctknife" or gun == "tknife" then
		if nocturnal.skins.knife.name ~= "" then
			local guiName = guiNames[gun]
			if guiName then
				local guiObj = playerService.LocalPlayer.PlayerGui.Display.Overlay.Loadout:FindFirstChild(guiName)
				if guiObj then
					if guiObj:FindFirstChild("Image") then
						guiObj.Image.Image = nocturnal.skins.knife.image
					end
					if guiObj:FindFirstChild("Namer") then
						guiObj.Namer.Text = nocturnal.skins.knife.name
					end
				end
			end
		end
	end
end

function nocturnal:Glove(gloveName)
	if gloveName == "None" then
		return
	end

	local glovesFolder = ReplicatedStorage.Import.Assets.Gloves
	local gFolder = glovesFolder:FindFirstChild(gloveName)
	if not gFolder then
		return warn("No glove:", gloveName)
	end

	local vm = workspace.CurrentCamera:FindFirstChild("Arms")
	if not vm then
		return
	end

	local leftArm = vm:FindFirstChild("Left Arm", true)
	local rightArm = vm:FindFirstChild("Right Arm", true)
	if not leftArm or not rightArm then
		return
	end

	-- remove old gloves
	if leftArm:FindFirstChild("Glove") then
		leftArm.Glove:Destroy()
	end
	if rightArm:FindFirstChild("Glove") then
		rightArm.Glove:Destroy()
	end

	-- weld helper
	local function weld(a, b)
		local w = Instance.new("WeldConstraint")
		w.Part0 = a
		w.Part1 = b
		w.Parent = a
	end

	-- LEFT
	local leftModel = gFolder:FindFirstChild("Left")
	if leftModel then
		local clone = leftModel:Clone()
		clone.Name = "Glove"
		clone.Parent = leftArm

		local armPart = leftArm
		if armPart then
			for _, p in clone:GetDescendants() do
				if p:IsA("BasePart") then
					p.Anchored = false
					weld(p, armPart)
					p.CFrame = armPart.CFrame -- hopeful it worksredo uit no
				end
			end
		end
	end

	-- RIGHT
	local rightModel = gFolder:FindFirstChild("Right")
	if rightModel then
		local clone = rightModel:Clone()
		clone.Name = "Glove"
		clone.Parent = rightArm

		local armPart = rightArm
		if armPart then
			for _, p in clone:GetDescendants() do
				if p:IsA("BasePart") then
					p.Anchored = false
					weld(p, armPart)
					p.CFrame = armPart.CFrame
				end
			end
		end
	end
end

local lastSkinToken = nil

workspace.CurrentCamera.ChildAdded:Connect(function(child)
	if child.Name == "Arms" then
		if not playerService.LocalPlayer:FindFirstChild("Gun") then
			return
		end
		local token = math.random(-100000, 1000000)
		lastSkinTaskToken = token

		task.wait(0.1)

		if lastSkinTaskToken ~= token then
			return
		end

		local gunName = playerService.LocalPlayer.Gun.Value:lower()
		local skinName = selectedSkins[gunName] or "None"
		nocturnal:GunSkin(gunName, skinName)
	end
end)

local function dbg(...)
	if true then
		print("[gm]", ...)
	end
end

local path = replicatedStorage:WaitForChild("Import")
if not path then
	return
end
local guns = path:FindFirstChild("Guns")
if not guns then
	return
end
local weaponsFolder = guns:FindFirstChild("Weapons")
if not weaponsFolder then
	return
end

local function matchesName(name, patterns)
	if not name then
		return false
	end
	local lower = name:lower()
	for _, pat in patterns do
		if lower:find(pat:lower(), 1, true) then
			return true
		end
	end
	return false
end

local savedValues = {} -- [Instance] = originalNumber
local savedAttributes = {} -- [Instance] = { attrName = originalValue, ... }

-- save defaults n shieet
for _, inst in weaponsFolder:GetDescendants() do
	if inst:IsA("NumberValue") or inst:IsA("IntValue") then
		if savedValues[inst] == nil then
			savedValues[inst] = inst.Value
		end
	end
	local ok, attrs = pcall(function()
		return inst:GetAttributes()
	end)
	if ok and attrs then
		for k, v in attrs do
			savedAttributes[inst] = savedAttributes[inst] or {}
			if savedAttributes[inst][k] == nil then
				savedAttributes[inst][k] = v
			end
		end
	end
end

dbg("Saved defaults for", tostring(#(next(savedValues) and savedValues or {}) ~= 0 and "values/attrs" or "nothing"))

function nocturnal:applyOverride(patterns, newValue)
	for _, inst in (weaponsFolder:GetDescendants()) do
		if (inst:IsA("NumberValue") or inst:IsA("IntValue")) and matchesName(inst.Name, patterns) then
			local ok, _ = pcall(function()
				inst.Value = newValue
			end)
			if ok then
				dbg("Override value:", inst:GetFullName(), "->", newValue)
			end
		end

		for _, pat in patterns do
			local ok, cur = pcall(function()
				return inst:GetAttribute(pat)
			end)
			if ok and cur ~= nil then
				local s, _ = pcall(function()
					inst:SetAttribute(pat, newValue)
				end)
				if s then
					dbg("Override attr:", inst:GetFullName(), pat, "->", newValue)
				end
			end
		end
	end
end

function nocturnal:restoreDefaults(patterns)
	for inst, original in savedValues do
		if
			inst
			and inst.Parent
			and (inst:IsA("NumberValue") or inst:IsA("IntValue"))
			and matchesName(inst.Name, patterns)
		then
			local ok, _ = pcall(function()
				inst.Value = original
			end)
			if ok then
				dbg("Restored value:", inst:GetFullName(), "->", original)
			end
		end
	end

	for inst, attrs in savedAttributes do
		if inst and inst.Parent then
			for attrName, original in attrs do
				for _, pat in patterns do
					if attrName:lower():find(pat:lower(), 1, true) then
						local ok, _ = pcall(function()
							inst:SetAttribute(attrName, original)
						end)
						if ok then
							dbg("Restored attr:", inst:GetFullName(), attrName, "->", tostring(original))
						end
					end
				end
			end
		end
	end
end

local resolverData: { [number]: ResolverRecord } = {}

local function cframeToYawDeg(cf: CFrame): number
	local lv = cf.LookVector
	-- yaw = atan2(x, z) in degrees
	return math.deg(math.atan2(lv.X, lv.Z))
end

local function clampAngleDeg(a: number): number
	-- normalize to -180..180
	local x = ((a + 180) % 360) - 180
	return x
end

local function getRecord(p: Player): ResolverRecord
	local id = p.UserId
	local rec = resolverData[id]
	if not rec then
		rec = { history = {}, lastSeenTime = 0, bestOffsetScores = {} }
		resolverData[id] = rec
	end

	return rec
end

function nocturnal:resolverRecordObservation(p: Player, hrpYaw: number, headYawDelta: number)
	local rec = getRecord(p)
	table.insert(rec.history, 1, { tick(), hrpYaw, headYawDelta }) -- newest first
	-- trim ts history size
	local maxHistory = math.clamp(Library.Flags.rage_rsh or 6, 1, 24)
	while #rec.history > maxHistory do
		table.remove(rec.history, #rec.history)
	end

	rec.lastSeenTime = tick()
end

function nocturnal:resolverRegisterHit(p: Player, offsetGuess: number)
	if not p then
		return
	end
	local rec = getRecord(p)
	local rounded = math.floor(offsetGuess + 0.5)
	rec.bestOffsetScores[rounded] = (rec.bestOffsetScores[rounded] or 0) + 1
end

local function samplePlayerYaw(p: Player): (number, number)
	if not p or not p.Character then
		return nil
	end
	local c = p.Character
	local hrp = c:FindFirstChild("HumanoidRootPart") or c:FindFirstChild("Torso") or c:FindFirstChild("UpperTorso")
	if not hrp then
		return nil
	end

	local torsoPart = c:FindFirstChild("UpperTorso") or c:FindFirstChild("Torso")
	local neck: Motor6D? = nil
	if torsoPart then
		neck = torsoPart:FindFirstChild("Neck")
	end

	local hrpYaw = cframeToYawDeg(hrp.CFrame)

	local headYawDelta = 0
	if neck then
		local c0 = neck.C0
		local _, _, z = c0:ToEulerAnglesXYZ()
		local head = c:FindFirstChild("Head")
		if head then
			local headYaw = math.deg(math.atan2(head.CFrame.LookVector.X, head.CFrame.LookVector.Z))
			headYawDelta = clampAngleDeg(headYaw - hrpYaw)
		else
			headYawDelta = 0
		end
	else
		local head = c:FindFirstChild("Head")
		if head then
			local headYaw = math.deg(math.atan2(head.CFrame.LookVector.X, head.CFrame.LookVector.Z))
			headYawDelta = clampAngleDeg(headYaw - hrpYaw)
		else
			headYawDelta = 0
		end
	end

	return hrpYaw, headYawDelta
end

local function scoreYawExposure(targetPos: Vector3, yawDeg: number): number
	local rad = math.rad(yawDeg)
	local dir = Vector3.new(math.sin(rad), 0, math.cos(rad))
	local start = targetPos + Vector3.new(0, 1.5, 0)
	local ignore = { playerService.LocalPlayer.Character, workspace.CurrentCamera }
	local dist = 0
	local rays = 3

	for i = 1, rays do
		local offset = Vector3.new(0, (i - 2) * 0.2, 0)
		local r = Ray.new(start + offset, dir * 120)
		local hit, pos = workspace:FindPartOnRayWithIgnoreList(r, ignore)
		dist = dist + (hit and (pos - start).Magnitude or 120)
	end

	return dist
end

-- offsets used in brute force x)
local BRUTE_OFFSETS = { 0, 30, -30, 60, -60, 90, -90, 180 }

function nocturnal:resolvePlayerYaw(p: Player): number
	if not p or not p.Character then
		return 0
	end

	-- exit when resolver disabled
	if not Library.Flags.rage_rs then
		local c = p.Character
		local hrp = c:FindFirstChild("HumanoidRootPart") or c:FindFirstChild("Torso") or c:FindFirstChild("UpperTorso")
		return hrp and cframeToYawDeg(hrp.CFrame) or 0
	end

	-- sample iinfo and record it
	local sample = samplePlayerYaw(p)
	local hrpYaw, headDelta = nil, nil
	if sample then
		hrpYaw, headDelta = sample
		nocturnal:resolverRecordObservation(p, hrpYaw, headDelta)
	else
		local c = p.Character
		local hrp = c
			and (c:FindFirstChild("HumanoidRootPart") or c:FindFirstChild("Torso") or c:FindFirstChild("UpperTorso"))
		return hrp and cframeToYawDeg(hrp.CFrame) or 0
	end

	local rec = getRecord(p)

	-- resolver mode selection
	local mode = Library.Flags.rage_rsm or "Safe"
	local useLBYChecks = Library.Flags.rage_lby or false

	local velMag = 0
	do
		local humanoidRoot = p.Character
			and (p.Character:FindFirstChild("HumanoidRootPart") or p.Character:FindFirstChild("Torso"))
		if humanoidRoot and humanoidRoot:IsA("BasePart") then
			velMag = (humanoidRoot.Velocity or Vector3.new()).Magnitude
		end
	end

	if useLBYChecks and velMag < 0.5 then
		return hrpYaw
	end

	if mode == "Safe" then
		if math.abs(headDelta) < 10 then
			return hrpYaw
		else
			local guess = clampAngleDeg(hrpYaw + headDelta * 0.5)
			return guess
		end
	end

	if mode == "Brute" then
		local best = hrpYaw
		local bestScore = -math.huge
		local targetPos = (
			p.Character
				and (p.Character:FindFirstChild("HumanoidRootPart") or p.Character:FindFirstChild("Torso") or p.Character:FindFirstChild(
					"UpperTorso"
				))
			or nil
		)
		if not targetPos then
			return hrpYaw
		end
		local pos = targetPos.Position
		for _, off in BRUTE_OFFSETS do
			local candYaw = clampAngleDeg(hrpYaw + off)
			local s = scoreYawExposure(pos, candYaw)
			if s > bestScore then
				bestScore = s
				best = candYaw
			end
		end
		return best
	end

	if mode == "Aggressive" then
		local sum, count = 0, 0

		for i = 1, #rec.history do
			local entry = rec.history[i]
			if entry then
				sum = sum + entry[3]
				count = count + 1
			end
		end

		if count == 0 then
			return hrpYaw
		end
		local avgDelta = sum / count
		-- i assume head delta indicates real facing?; guess it by combining hrp + avgDelta
		local guess = clampAngleDeg(hrpYaw + avgDelta)
		return guess
	end

	if mode == "Adaptive" then
		local recScores = rec.bestOffsetScores or {}

		local bestScore, bestOffset = -math.huge, nil
		for offsetStr, score in recScores do
			local off = tonumber(offsetStr) or offsetStr
			if score > bestScore then
				bestScore = score
				bestOffset = off
			end
		end
		if bestOffset then
			return clampAngleDeg(hrpYaw + bestOffset)
		else
			-- brute
			local targetPosInstance = p.Character
				and (
					p.Character:FindFirstChild("HumanoidRootPart")
					or p.Character:FindFirstChild("Torso")
					or p.Character:FindFirstChild("UpperTorso")
				)
			if targetPosInstance then
				local pos = targetPosInstance.Position
				local best, bscore = hrpYaw, -math.huge
				for _, off in BRUTE_OFFSETS do
					local cand = clampAngleDeg(hrpYaw + off)
					local s = scoreYawExposure(pos, cand)
					if s > bscore then
						bscore = s
						best = cand
					end
				end
				return best
			else
				return hrpYaw
			end
		end
	end

	return hrpYaw
end

function nocturnal:resolverGetRecord(p: Player)
	return resolverData[p.UserId]
end

local function getLimbCandidates(char)
	if not char then
		return {}
	end
	local names = {
		"LeftHand",
		"RightHand",
		"LeftLowerArm",
		"RightLowerArm",
		"LeftUpperArm",
		"RightUpperArm",
		"Left Arm",
		"Right Arm",
		"LeftArm",
		"RightArm",
		"Hand",
		"RightHand",
		"LeftHand",
	}
	local parts = {}

	for _, n in names do
		local p = char:FindFirstChild(n, true)
		if p and p:IsA("BasePart") then
			parts[#parts + 1] = p
		end
	end

	return parts
end

local function samplePointsOnPart(part)
	if not part or not part:IsA("BasePart") then
		return {}
	end
	local size = part.Size
	local center = part.Position
	local cf = part.CFrame
	local samples = {}

	samples[#samples + 1] = center

	local localDirs = {
		Vector3.new(size.X / 2, 0, 0),
		Vector3.new(-size.X / 2, 0, 0),
		Vector3.new(0, size.Y / 2, 0),
		Vector3.new(0, -size.Y / 2, 0),
		Vector3.new(0, 0, size.Z / 2),
		Vector3.new(0, 0, -size.Z / 2),
	}
	for _, ld in localDirs do
		samples[#samples + 1] = (cf * CFrame.new(ld)).Position
	end

	local qx, qy, qz = size.X * 0.25, size.Y * 0.25, size.Z * 0.25
	local midDirs = {
		Vector3.new(qx, qy, 0),
		Vector3.new(-qx, qy, 0),
		Vector3.new(qx, -qy, 0),
		Vector3.new(-qx, -qy, 0),
		Vector3.new(qx, 0, qz),
		Vector3.new(-qx, 0, qz),
		Vector3.new(qx, 0, -qz),
		Vector3.new(-qx, 0, -qz),
		Vector3.new(0, qy, qz),
		Vector3.new(0, -qy, qz),
		Vector3.new(0, qy, -qz),
		Vector3.new(0, -qy, -qz),
	}
	for _, md in midDirs do
		samples[#samples + 1] = (cf * CFrame.new(md)).Position
	end

	local cam = workspace.CurrentCamera
	if cam then
		local toCam = (cam.CFrame.Position - center)
		if toCam.Magnitude > 0 then
			local offset = math.min(part.Size.Magnitude * 0.35, 2)
			samples[#samples + 1] = center + toCam.Unit * offset
		end
	end

	if #samples > 24 then
		local out = {}
		for i = 1, 24 do
			out[i] = samples[i]
		end
		return out
	end

	return samples
end

function nocturnal:getBestVisibleSample(part)
	if not part or not part:IsA("BasePart") then
		return nil, 0
	end

	local cam = workspace.CurrentCamera
	local startPart = playerService.LocalPlayer.Character.Head

	local start = (startPart and startPart.Position) or (cam and cam.CFrame.Position) or Vector3.new(0, 0, 0)
	local samples = samplePointsOnPart(part)
	if #samples == 0 then
		return nil, 0
	end

	local bestScore = -math.huge
	local bestPos = nil
	local visibleCount = 0

	for _, s in samples do
		local params = RaycastParams.new()
		params.FilterDescendantsInstances = { playerService.LocalPlayer.Character, workspace.CurrentCamera }
		params.FilterType = Enum.RaycastFilterType.Exclude
		params.IgnoreWater = true

		local dir = s - start
		if dir.Magnitude <= 0.001 then
			local score = 1000
			if score > bestScore then
				bestScore = score
				bestPos = s
			end
			visibleCount = visibleCount + 1
			continue
		end

		local res = workspace:Raycast(start, dir.Unit * math.min(dir.Magnitude, 4000), params)
		local visible = false
		if not res then
			visible = true
		else
			if res.Instance and res.Instance:IsDescendantOf(part.Parent) then
				visible = true
			end
		end

		local facing = 0
		if cam then
			local toCam = (cam.CFrame.Position - s)
			if toCam.Magnitude > 0 then
				facing = math.clamp((toCam.Unit:Dot((part.CFrame.LookVector * -1)) + 1) / 2, 0, 1)
			end
		end

		local dist = (s - start).Magnitude
		local distFactor = 1 / math.max(dist, 1)

		local score = (visible and 1 or 0) * 100 + facing * 25 + distFactor * 10

		if visible then
			visibleCount = visibleCount + 1
		end

		if score > bestScore then
			bestScore = score
			bestPos = s
		end
	end

	local frac = visibleCount / #samples
	return bestPos, frac
end

local function raycastFromHeadTo(point)
	local cam = workspace.CurrentCamera
	local start = (playerService.LocalPlayer.Character.Head and playerService.LocalPlayer.Character.Head.Position)
		or (cam and cam.CFrame.Position)
		or Vector3.new(0, 0, 0)
	local dir = point - start
	if dir.Magnitude <= 0.001 then
		return true, nil
	end

	local params = RaycastParams.new()
	params.FilterDescendantsInstances = { playerService.LocalPlayer.Character, workspace.CurrentCamera }
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.IgnoreWater = true

	local res = workspace:Raycast(start, dir.Unit * math.min(dir.Magnitude, 4000), params)
	if not res then
		return true, nil
	end

	return false, res.Instance
end

local function evaluatePartVisibility(part)
	if not part or not part:IsA("BasePart") then
		return 0, 0
	end
	local samples = samplePointsOnPart(part)
	if #samples == 0 then
		return 0, 0
	end

	local visibleCount = 0
	local camFacingSum = 0
	local cam = workspace.CurrentCamera
	local startPart = playerService.LocalPlayer.Character.Head

	local start = (startPart and startPart.Position) or (cam and cam.CFrame.Position) or Vector3.new(0, 0, 0)
	--	local start = (head and head.Position) or (cam and cam.CFrame.Position) or Vector3.new(0,0,0)

	for _, s in samples do
		local params = RaycastParams.new()
		params.FilterDescendantsInstances = { playerService.LocalPlayer.Character, workspace.CurrentCamera }
		params.FilterType = Enum.RaycastFilterType.Exclude
		params.IgnoreWater = true

		local r = workspace:Raycast(start, (s - start).Unit * math.min((s - start).Magnitude, 4000), params)
		if not r then
			visibleCount = visibleCount + 1
		else
			if r.Instance and r.Instance:IsDescendantOf(part.Parent) then
				visibleCount = visibleCount + 1
			end
		end

		if cam then
			local toCam = (cam.CFrame.Position - s)
			if toCam.Magnitude > 0 then
				local facing = math.clamp((toCam.Unit:Dot((part.CFrame.LookVector * -1)) + 1) / 2, 0, 1)
				camFacingSum = camFacingSum + facing
			end
		end
	end

	local frac = visibleCount / #samples
	local avgFacing = (#samples > 0) and (camFacingSum / #samples) or 0
	return frac, avgFacing
end

function nocturnal:isVisibleFromHead(part: BasePart): boolean
	if not part or not playerService.LocalPlayer.Character.Head then
		return false
	end
	local start = playerService.LocalPlayer.Character.Head.Position
	local dir = part.Position - start
	if dir.Magnitude <= 0.001 then
		return true
	end

	local params = RaycastParams.new()
	params.FilterDescendantsInstances = { playerService.LocalPlayer.Character, workspace.CurrentCamera }
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.IgnoreWater = true

	local result = workspace:Raycast(start, dir.Unit * math.min(dir.Magnitude, 3000), params)
	if not result then
		return true
	end
	if result.Instance and result.Instance:IsDescendantOf(part.Parent) then
		return true
	end

	return false
end

local function chooseHitPart(p: Player)
	if not p or not p.Character then
		return nil
	end

	local mode = Library.Flags.rage_hb or "Head"
	local headPart = p.Character:FindFirstChild("Head")
	local upperTorso = p.Character:FindFirstChild("UpperTorso") or p.Character:FindFirstChild("Torso")

	local candidates = {}

	local function addCandidate(part, priority)
		if part and part:IsA("BasePart") then
			if not (part.Name:lower() == "part") then
				candidates[#candidates + 1] = { part = part, basePriority = priority or 1 }
			end
		end
	end

	if mode == "Head" then
		addCandidate(headPart, 3)
		addCandidate(upperTorso, 1)
	elseif mode == "Body" then
		addCandidate(upperTorso, 3)
		addCandidate(headPart, 1)
	elseif mode == "Auto" or mode == "Prefer Safe" then
		addCandidate(headPart, (mode == "Auto") and 2 or 1)
		addCandidate(upperTorso, (mode == "Prefer Safe") and 2 or 1)
	else
		addCandidate(headPart, 2)
		addCandidate(upperTorso, 2)
	end

	if Library.Flags.rage_ab then
		local limbs = getLimbCandidates(p.Character)
		for _, limb in limbs do
			addCandidate(limb, 1)
		end
	end

	local cam = workspace.CurrentCamera
	local bestScore = -math.huge
	local bestPart = nil
	local myPos = playerService.LocalPlayer.Character.Head and playerService.LocalPlayer.Character.Head.Position
		or (cam and cam.CFrame.Position)
		or playerService.LocalPlayer.Character.PrimaryPart.Position

	for _, cand in candidates do
		local part = cand.part
		if not part then
			continue
		end
		-- skip if invalid
		if not part:IsDescendantOf(p.Character) then
			continue
		end

		local frac, facing = evaluatePartVisibility(part) -- fraction visible, average facing
		local dist = (part.Position - playerService.LocalPlayer.Character.PrimaryPart.Position).Magnitude
		local distFactor = 1 / math.max(dist, 1)

		-- base priority head/torso get boosted
		local baseP = cand.basePriority or 1

		-- compute ts:
		-- visible fraction is primary; multiply by facing and add base + dist
		local score = frac * (0.7 + 0.3 * facing) * 100
		score = score + (baseP * 10) + (distFactor * 5)

		-- fully invisible parts get de-prioritized unless autowall allowed
		if
			frac <= 0 --[[and not library.flags.rage_autowall]]
		then
			score = score - 1000
		end

		if score > bestScore then
			bestScore = score
			bestPart = part
		end
	end

	if not bestPart then
		if mode == "Body" then
			return upperTorso or headPart
		else
			return headPart or upperTorso
		end
	end

	return bestPart
end

local weaponStats = require(replicatedStorage.Import.v_weapon)
local defaultStats: {} = {}
local Mouse = playerService.LocalPlayer:GetMouse()

-- [[ first and last time ever in my life using pairs ]]
for name, data in pairs(weaponStats) do
	if type(data) == "table" then
		defaultStats[name] = table.clone(data)
	end
end

local function getPlayerFromPart(part)
	if not part then
		return nil
	end
	local model = part:FindFirstAncestorWhichIsA("Model")
	if not model then
		return nil
	end

	return playerService:GetPlayerFromCharacter(model)
end

do
	local function x(window: any)
		assert(window and window.createTab, "err")

		-- LEGIT TAB
		do
			local LocalPlayer = playerService.LocalPlayer

			local tab = window:createTab({ Text = "Legit", Small = true })

			local aimSec = tab:createSection({ Text = "Aimbot", Location = 1 })
			aimSec
				:createToggle({ Text = "Smoothbot", Flag = "aim_enabled", Mode = "Hold" })
				:createBind({ Flag = "aim_key", Mode = "Hold", Text = "", Callback = function(a) end, Ignore = true })
			aimSec:createToggle({ Text = "Wall Check", Flag = "aim_wc" })
			aimSec:createToggle({ Text = "Team Check", Flag = "aim_tc" })
			aimSec:createToggle({ Text = "Prediction", Flag = "aim_pred" })
			aimSec
				:createToggle({
					Text = "FOV Circle",
					Flag = "aim_fov",
					Callback = function(a)
						if not nocturnal.circle then
							return
						end
						nocturnal.circle.Visible = a
					end,
				})
				:createColorpicker({
					Text = "FOV Color",
					Default = Color3.fromRGB(255, 255, 255),
					Flag = "fovcolr",
					Callback = function(a)
						if not nocturnal.circle then
							return
						end
						nocturnal.circle.Color = a
					end,
				})
			aimSec:createDropdown({
				Text = "Hitboxes",
				Options = { "Closest", "Head", "Body" },
				Default = "Closest",
				Flag = "aim_hb",
			})
			aimSec:createDropdown({
				Text = "Conditions",
				Options = { "No Flash", "No Smoke" },
				Default = "",
				Flag = "aim_conditions",
			})
			aimSec:createDropdown({
				Text = "Activation",
				Options = { "MouseButton1", "MouseButton2" },
				Default = "MouseButton2",
				Flag = "aim_activate",
			})
			aimSec:createDropdown({
				Text = "Smoothing",
				Options = { "Linear", "Exponential", "WeightedAverage", "EaseInOut", "DistanceCurve", "ComplexCurve" },
				Default = "Linear",
				Flag = "aim_st",
			})
			aimSec:createSlider({ Text = "Smoothness", Min = 0, Max = 100, Value = 15, Flag = "aim_smoothing" })
			aimSec:createSlider({ Text = "Prediction", Min = 0, Max = 1000, Value = 0, Flag = "aim_predict" })
			aimSec:createSlider({
				Text = "FOV Radius",
				Min = 1,
				Max = 500,
				Value = 50,
				Flag = "aim_radius",
				Callback = function(a)
					if not nocturnal.circle then
						return
					end
					nocturnal.circle.Radius = a
				end,
			})

			local function isInSmoke(character)
				local smokeFolder = workspace:FindFirstChild("SmokeDebugParts")
				if not smokeFolder then
					return false
				end
				if not character then
					return false
				end

				local head = character:FindFirstChild("Head")
				if not head then
					return false
				end

				-- If folder is empty = no smoke
				if #smokeFolder:GetDescendants() == 0 then
					return false
				end

				local params = OverlapParams.new()
				params.FilterType = Enum.RaycastFilterType.Include
				params.FilterDescendantsInstances = { smokeFolder }

				local touchingSmoke = workspace:GetPartBoundsInRadius(head.Position, 4, params)
				return (#touchingSmoke > 0)
			end

			--// Flash detection
			local function isFlashed()
				local gui = LocalPlayer:WaitForChild("PlayerGui")
				return gui:FindFirstChild("Flash") ~= nil
			end

			local function triggerStep()
				local char = playerService.LocalPlayer.Character
				if not char then
					return
				end
				--if not nocturnal:isAlive(playerService.LocalPlayer) then return end
				local ignores = {}
				local seen = {}
				local ignoreConditions = Library.Flags["tr_ign"]
				local conditions = Library.Flags["tr_hb"] or {}
				local hitchance = Library.Flags["tr_chance"] or 100
				local delay = (Library.Flags["tr_dl"] or 0) / 1000
				if not ignoreConditions then
					if table.find(conditions, "No Smoke") then
					else
						table.insert(ignores, workspace.SmokeDebugParts)
					end

					if table.find(conditions, "No Flash") then
						if isFlashed() then
							return -- blocked by flash
						end
					end
				end

				local function addIgnore(inst)
					if not inst then
						return
					end
					if seen[inst] then
						return
					end
					seen[inst] = true
					table.insert(ignores, inst)
				end

				-- always ignore ts
				addIgnore(playerService.LocalPlayer.Character)

				-- ignore
				local cam = workspace.CurrentCamera
				addIgnore(cam)

				-- oh
				for _, name in { "IgnoreParts", "MiscStorage", "ReactionHolder", "Ragdolls", "SmokeDebugParts" } do
					local inst = workspace:FindFirstChild(name)
					if inst then
						addIgnore(inst)
					end
				end

				local rayParams = RaycastParams.new()
				rayParams.FilterType = Enum.RaycastFilterType.Blacklist
				rayParams.FilterDescendantsInstances = ignores
				rayParams.IgnoreWater = true

				local screenRay = cam:ScreenPointToRay(Mouse.X, Mouse.Y)
				local origin = screenRay.Origin
				local direction = screenRay.Direction * 9999

				local rayResult = workspace:Raycast(origin, direction, rayParams)

				if rayResult and rayResult.Instance then
					local Target = rayResult.Instance
					local Position = rayResult.Position

					local charModel = Target:FindFirstAncestorOfClass("Model")
					local TargetPlayer = nil
					if charModel then
						TargetPlayer = playerService:GetPlayerFromCharacter(charModel)
					end

					if TargetPlayer and nocturnal:isTarget(TargetPlayer) then
						task.delay(delay, function()
							task.spawn(function()
								if hitchance < 100 then
									if math.random(1, 100) > hitchance then
										return
									end
								end

								mouse1press()
								task.wait(0.1)
								mouse1release()
							end)
						end)
					else
					end
				end
			end

			local renderConnectionXD

			local triggerSec = tab:createSection({ Text = "Triggerbot", Location = 2 })

			triggerSec
				:createToggle({
					Text = "Triggerbot",
					Flag = "tr_enabled",
					Callback = function(enabled)
						local lp = playerService.LocalPlayer
						local ignore = {}
						local partNames = {
							"HumanoidRootPart",
							"Head",
							"LeftLowerLeg",
							"LeftUpperLeg",
							"RightLowerLeg",
							"RightUpperLeg",
							"LeftLowerArm",
							"RightUpperArm",
						}
						local playersCache = {}
						local updateCacheRunning = false

						ignore[#ignore + 1] = lp.Character
						ignore[#ignore + 1] = workspace.CurrentCamera
						for _, objName in { "Map.Clips", "ServerIgnore", "Ragdolls", "Ray_Ignore" } do
							local obj = workspace
							for part in objName:gmatch("[^%.]+") do
								obj = obj:FindFirstChild(part)
								if not obj then
									break
								end
							end
							if obj then
								ignore[#ignore + 1] = obj
							end
						end

						local function updatePlayerCache()
							for _, player in playerService:GetPlayers() do
								if player ~= lp and nocturnal:isTarget(player) and nocturnal:isAlive(player) then
									local parts = {}
									local char = player.Character
									if char then
										for _, name in partNames do
											local p = char:FindFirstChild(name)
											if p then
												parts[#parts + 1] = p
											end
										end
									end
									playersCache[player] = parts
								else
									playersCache[player] = nil
								end
							end
						end

						if enabled then
							updatePlayerCache()
							renderConnectionXD = runService.RenderStepped:Connect(function()
								if not nocturnal.loadcomplete then
									return
								end
								local cursor =
									Vector2.new(inputService:GetMouseLocation().X, inputService:GetMouseLocation().Y)

								for player, parts in playersCache do
									if parts then
										for _, part in parts do
											if nocturnal:partIsVisible(part, ignore) then
												local pos = part.Position
												local topPos = pos + Vector3.new(0, part.Size.Y * 0.5, 0)
												local screenPos = nocturnal:worldToScreen_Test(pos)
												local topScreenPos = nocturnal:worldToScreen_Test(topPos)
												if screenPos and topScreenPos then
													local radius = (topScreenPos - screenPos).Magnitude * 1.3
													if (cursor - screenPos).Magnitude <= radius then
														local chance = Library.Flags["tr_chance"] or 100
														if chance >= 100 or math.random(1, 100) <= chance then
															local delay = Library.Flags.tr_rd
																	and math.random(
																		Library.Flags.tr_dlmin / 1000,
																		Library.Flags.tr_dlmax / 1000
																	)
																or Library.Flags.tr_dlmin / 1000

															task.delay(delay, function()
																local gun = lp:FindFirstChild("Gun")
																local gunName = gun and gun.Value or nil

																-- Quickscope only for snipers
																local isSniper = gunName
																	and table.find({ "AWP", "SSG08" }, gunName)

																if Library.Flags.tr_qs and isSniper then
																	if not lp.PlayerGui.Display.Scope.Visible then
																		mouse2click() -- scope in
																		task.wait(0.08)
																		mouse2click() -- n out
																	end
																end

																-- imprortantz
																if isSniper then
																	mouse1click()
																else
																	mouse1press()
																	task.wait(0.08)
																	mouse1release()
																end
															end)
														end
													end
												end
											end
										end
									end
								end
							end)

							-- wtf is this monstrosity
							if not updateCacheRunning then
								updateCacheRunning = true
								task.spawn(function()
									while enabled do
										updatePlayerCache()
										task.wait(1)
									end
									updateCacheRunning = false
								end)
							end
						elseif renderConnectionXD then
							renderConnectionXD:Disconnect()
							renderConnectionXD = nil
						end
					end,
				})
				:createBind({ Flag = "tr_key", Text = "", Callback = function(a) end })

			triggerSec:createToggle({ Text = "Ignore Conditions", Flag = "tr_ign" })
			triggerSec:createToggle({ Text = "Quick Scope", Flag = "tr_qs" })
			triggerSec:createToggle({ Text = "Randomize Delay", Flag = "tr_rd" })
			triggerSec:createToggle({ Text = "Use fire function", Flag = "tr_uff" })
			triggerSec:createDropdown({
				Text = "Conditions",
				Options = { "No Smoke", "No Flash" },
				Flag = "tr_hb",
				Multichoice = true,
			})
			triggerSec:createSlider({ Text = "Hitchance", Min = 0, Max = 100, Value = 100, Flag = "tr_chance" })
			triggerSec:createSlider({ Text = "Delay", Min = 0, Max = 500, Value = 0, Flag = "tr_dlmin" })
			triggerSec:createSlider({ Text = "Max Delay", Min = 0, Max = 500, Value = 15, Flag = "tr_dlmax" })

			local automaticGuns = {
				"ak47",
				"deserteagle",
				"galil",
				"m4a1",
				"m4a4",
				"aug",
				"famas",
				"sg556",
				"ssg08",
				"scar20",
				"g3sg1",
			}

			local smoothX = 0
			local smoothY = 0
			local SMOOTHING = 0.15
			local enabled = false
			local strength = 15
			local inputConnection
			local currentIndex = 1
			local lastGunName = ""
			local remainderX = 0
			local remainderY = 0
			local lastShootTime = 0
			local isHolding = false

			local guns = {}

			local function normalizeName(str)
				return str:lower():gsub("%W", "")
			end

			local function addGun(name, id, rpm, pattern)
				local gunData = {
					name = name,
					id = id,
					rpm = rpm,
					recoilPattern = pattern,
				}
				guns[normalizeName(name)] = gunData
			end

			addGun("AUG", 1, 600, {
				{ 0, 0 },
				{ 2.222882090266193, 2.959465127391366 },
				{ 2.311439259414717, 9.569831750358858 },
				{ 0.036375035481399, 20.29080815488128 },
				{ -3.486687033130921, 33.33760877746562 },
				{ -0.696092814076953, 47.719471242662486 },
				{ 3.406308922998944, 63.00722365715827 },
				{ 10.23175762119175, 73.05811444055955 },
				{ 13.634832385761529, 80.79069498307169 },
				{ 20.112250083198767, 87.04543847771787 },
				{ 12.248423980575575, 92.76442285759437 },
				{ 9.74565333249188, 95.90836601095208 },
				{ 16.474184154655358, 95.55639296395766 },
				{ 16.90945636392498, 99.20489779079602 },
				{ 5.440400492255662, 100.80211604472088 },
				{ -12.701747810559304, 95.33934851869235 },
				{ -28.349707159956427, 89.00127065104394 },
				{ -30.033165669765374, 92.0479680324646 },
				{ -32.75261229576271, 94.93571781786714 },
				{ -36.76204638765153, 94.48739845596984 },
				{ -24.74547690252887, 95.20343152580047 },
				{ -9.05785924129152, 96.83774207974264 },
				{ -1.51068331115752, 99.58276227796799 },
				{ -4.095434680791485, 100.19796535993362 },
				{ 4.158934426047507, 98.9371775155192 },
				{ 18.982421985349266, 93.52702258914763 },
				{ 28.528317604105002, 93.59727361737633 },
				{ 20.39315174592432, 96.057521872506 },
				{ 12.01218410664915, 97.51933275754548 },
				{ 10.347007170845933, 98.39823477438577 },
			})

			addGun("AK-47", 223, 600, {
				{ 0, 0 },
				{ -3.827636948042893, 3.536428966243171 },
				{ 0.121165492837354, 12.858673756857806 },
				{ -1.2711849271449, 27.3605424641275 },
				{ -1.673201892334844, 42.59346607107974 },
				{ 4.463792920096362, 58.71875911296247 },
				{ 8.463622955365372, 72.67738087743321 },
				{ 14.916891507104577, 82.44516349926568 },
				{ 6.659815463504096, 89.56268273045887 },
				{ -14.204224560583262, 87.50140293913717 },
				{ -25.256739579340184, 88.79593779505954 },
				{ -18.72588913668821, 94.24987228877819 },
				{ -26.59217048249592, 97.27814488836974 },
				{ -39.409618443331674, 93.0454935198128 },
				{ -40.88200003044932, 95.54752111932157 },
				{ -20.961300410160202, 96.32584448266331 },
				{ -11.518010220412572, 99.81424250132606 },
				{ -4.469909867720372, 105.0723284161461 },
				{ 9.006248167423479, 104.23676761877519 },
				{ 25.569507149111917, 99.84373539025064 },
				{ 15.319282441848282, 98.60579327997657 },
				{ 18.375680236201855, 99.97202892515732 },
				{ 15.15648101008768, 104.87009656981306 },
				{ 10.791329701463264, 106.53245487581405 },
				{ 20.24546987089886, 105.00756071856401 },
				{ 23.60397143167229, 107.61090682106477 },
				{ 13.116273340229377, 107.37700253644354 },
				{ -3.151668316018399, 105.73756331715488 },
				{ -25.88902421233086, 95.27387044126002 },
				{ -33.11802738944682, 95.29814441612216 },
			})

			local m4_pattern = {
				{ 0, 0 },
				{ 0.593149889668485, 2.930082298076452 },
				{ 0.467599252492137, 5.400722402012841 },
				{ -1.378824494413463, 11.98730717748309 },
				{ 0.743137048487199, 21.072202025117463 },
				{ -2.338073017301649, 31.569213818164247 },
				{ -4.224184381458436, 43.389298022518524 },
				{ 2.503264604071358, 50.51859139356511 },
				{ 6.470252451534178, 56.27880589304245 },
				{ 15.527316925591018, 59.026697413775985 },
				{ 13.51870087620907, 63.99068138062866 },
				{ 6.304251496325907, 66.54484911498237 },
				{ -6.052203590640147, 64.92335880146629 },
				{ -15.786608052241583, 65.18757929727312 },
				{ -26.49450945007401, 63.29534907815819 },
				{ -26.19777190292132, 64.75552981186893 },
				{ -22.388620350606082, 66.73098770213686 },
				{ -27.052202746705014, 67.17494607446021 },
				{ -33.18877939802228, 66.14283556099245 },
				{ -31.85382799345042, 66.96288788980127 },
			}
			addGun("M4A1", 38965, 666, m4_pattern)
			addGun("M4A4", 38965, 666, m4_pattern)

			addGun("Galil", 51191, 666, {
				{ 0, 0 },
				{ 2.077857360333431, 2.2495791915748 },
				{ 0.84905967703718, 4.320737884655506 },
				{ 3.926628908955945, 9.600868451319947 },
				{ 9.878246473373661, 16.64580929760077 },
				{ 9.610986697477262, 27.24516674668283 },
				{ 10.348841239807621, 39.491856466554964 },
				{ 13.543698774729389, 47.8876427165137 },
				{ 18.857784390941106, 52.38716250570664 },
				{ 16.752095014806955, 59.13697827354003 },
				{ 5.836141504877478, 63.73169390877232 },
				{ -9.263443306404396, 61.69368912201999 },
				{ -23.656323275486606, 56.026531404243286 },
				{ -28.247377265885998, 59.31030128398085 },
				{ -34.18087082527084, 60.851591552511316 },
				{ -37.206360793860995, 60.89928135879738 },
				{ -37.46303242021487, 61.42658780711642 },
				{ -35.33600421746067, 65.20123224456778 },
				{ -22.77034676496905, 68.70240197702267 },
				{ -15.882469056314447, 70.28856495028266 },
				{ -3.504446085339037, 68.62000759309504 },
				{ 11.883290462649704, 64.5911905993017 },
				{ 14.845132251834926, 65.80351656607756 },
				{ 9.085302674062307, 67.68469887133408 },
				{ 15.277462271420456, 66.62934078310957 },
				{ 20.446102778540503, 66.00408093783584 },
				{ 28.53232902404034, 64.70948476457252 },
				{ 23.816550318189243, 66.88135940333831 },
				{ 7.701462592979505, 64.19958597166527 },
				{ -4.625359659193873, 62.81916414149335 },
				{ -11.590448854725855, 65.58327903562795 },
				{ -8.447212343366624, 69.61683997367848 },
				{ -15.697920921000085, 67.8866752748851 },
				{ -27.362147060743442, 60.787564568812854 },
				{ -34.386819438864435, 60.222093510077556 },
			})

			addGun("FAMAS", 39623, 666, {
				{ 0, 0 },
				{ -1.877815022167983, 2.079078040335055 },
				{ -1.426179848701379, 4.089731689589768 },
				{ -4.674170905270299, 9.166690224882464 },
				{ -5.059926312817549, 17.511982131036916 },
				{ -4.829737947224267, 28.00479403960494 },
				{ 2.133248053065285, 36.944696369981145 },
				{ 10.023502190160348, 42.58014824188317 },
				{ 6.799453673709023, 48.616225146981414 },
				{ -2.808361360608417, 52.33993838841711 },
				{ -11.2405348202883, 55.377992427353846 },
				{ -17.728389875589517, 56.09346446621464 },
				{ -15.248130804657796, 58.9965342239173 },
				{ -3.790672139233781, 60.978173199405056 },
				{ 1.998792580115771, 63.540701008489314 },
				{ 11.769860271029623, 62.076755974402914 },
				{ 14.687762038554872, 62.559386758757384 },
				{ 22.026346708750697, 62.51747243935909 },
				{ 23.65776018255924, 64.99417882973863 },
				{ 21.44342079302596, 66.44315965353461 },
				{ 8.8897989150064, 65.57737159884616 },
				{ 7.642004828003477, 67.07702991367877 },
				{ 12.924750299289633, 66.67644776964391 },
				{ 20.3412830318508, 63.52183674863727 },
				{ 28.183528005820083, 58.10815697074985 },
			})

			addGun("DesertEagle", 12345, 267, {
				{ 0, 0 },
				{ 26.815728296829917, 31.242901752599302 },
				{ -3.317230599950525, 20.126243666122814 },
				{ -4.224166803398816, 20.04172356428791 },
				{ -6.864289752463892, 27.10308534055652 },
				{ 5.954570401516337, 49.902621304156646 },
			})

			addGun("SG553", 43500, 545, {
				{ 0, 0 },
				{ -1.215159144305283, 2.650864194067308 },
				{ -2.618407656774418, 3.651866709266545 },
				{ -4.291565951560159, 8.348016470560214 },
				{ -6.330926582732133, 15.668227603086684 },
				{ -9.084359618215505, 25.60337745135338 },
				{ -11.757968841367424, 36.88227720284397 },
				{ -17.84508324999042, 41.423232447816495 },
				{ -13.370099555467132, 46.835712850673055 },
				{ -16.40630589884911, 50.64931017629117 },
				{ -21.35455060165442, 53.23281715283949 },
				{ -22.494471985656265, 54.6858596698778 },
				{ -20.543077665297403, 56.160205368166444 },
				{ -23.218487361519657, 58.45440816461879 },
				{ -22.798920368114253, 62.3404571123458 },
				{ -27.467867871087886, 61.13523506386782 },
				{ -33.165482656974405, 55.39129592091709 },
				{ -38.099669269626965, 53.316678174597996 },
				{ -39.86374461968676, 52.50356028941025 },
				{ -26.687739853239083, 52.69534223377693 },
				{ -9.897473142475858, 49.44997475867327 },
				{ 1.832035880559232, 48.17248219674433 },
				{ 5.409636462911261, 51.24526285286948 },
				{ 9.216100324666591, 54.59600906676643 },
				{ 10.530411125907179, 57.09293496413695 },
				{ 17.159815740618065, 56.73051897049839 },
				{ 25.701734591473766, 56.199076980113674 },
				{ 22.86749972905878, 59.03727578253211 },
				{ 18.58425981293327, 60.4570151316226 },
				{ 6.707106347665074, 58.079326656754674 },
			})

			addGun("P90", 6213, 857, {
				{ 0, 0 },
				{ -1.512070031220564, 1.784402786107674 },
				{ -1.181923377554774, 3.833282948043264 },
				{ -0.264386755521403, 6.400265241308062 },
				{ -1.800011498190314, 12.111488811975322 },
				{ -7.163571771027064, 19.546904748335855 },
				{ -13.318876696492715, 25.517330917057944 },
				{ -18.287408069519337, 34.033993055117456 },
				{ -13.928956070470129, 41.09336069807538 },
				{ -9.031323748218979, 47.744421662848445 },
				{ -8.043590828965746, 53.46668318557177 },
				{ -6.498529637177525, 59.293671815402945 },
				{ -8.044275963067669, 62.93453341440814 },
				{ -14.365420054144886, 63.023877233652996 },
				{ -16.988639992033058, 64.6704754239666 },
				{ -20.40519553884497, 65.89516762316259 },
				{ -25.582678906773978, 65.86951149268306 },
				{ -19.487293407532594, 66.72277151663869 },
				{ -11.426798052066282, 67.49219366706103 },
				{ -6.299983400446152, 68.05728138495427 },
				{ -1.254667102614459, 68.72804710169068 },
				{ 5.8048074962751, 68.25262616618589 },
				{ 12.993267232345637, 66.65153132448035 },
				{ 10.87420813974665, 66.4065173546085 },
				{ 13.045518128567108, 66.93650734722254 },
				{ 7.232342853502791, 67.04767897723622 },
				{ -0.12188806673845, 66.80789041067476 },
				{ -10.210045274443079, 65.78391255434829 },
				{ -11.600580452376517, 66.7600566297424 },
				{ -8.853378843126213, 68.51867531267273 },
				{ -10.642455583940183, 69.06526953853155 },
				{ -12.804184302226597, 70.05803515297393 },
				{ -9.942870443396561, 71.11183610096859 },
				{ -2.436996423130546, 70.8411274207295 },
				{ 1.698459319626697, 70.45761649007778 },
				{ -0.13108053372384, 70.99542307869986 },
				{ -1.176436970292167, 71.18735815037697 },
				{ -7.362773158946855, 70.6132398965314 },
				{ -13.139624364699346, 69.63728070997941 },
				{ -12.146584458478959, 70.69232434769319 },
				{ -6.019828368607975, 70.54590369723525 },
				{ 3.618721732332158, 68.38871034939729 },
				{ 8.090226364203057, 67.6957067970777 },
				{ 14.023176425925595, 67.42785748261434 },
				{ 21.738500878522313, 65.76917718481411 },
				{ 25.953251285617917, 66.19516451951796 },
				{ 31.75911340998358, 64.4525847588505 },
				{ 29.752867007511647, 65.82218516729442 },
				{ 23.829489275210094, 67.45773858594109 },
				{ 26.005728884437456, 66.67315878109392 },
			})

			addGun("TEC-9", 789, 500, {
				{ 0, 0 },
				{ 0.880322281355544, 3.265015837788265 },
				{ 5.027892833203274, 9.517318345146377 },
				{ 12.16499727455663, 18.939061732815976 },
				{ 6.097899214738125, 30.973237460498478 },
				{ -5.879380921126691, 40.736889764253334 },
				{ -15.723294887320817, 48.42705906222121 },
				{ -22.063723563836074, 55.48058988381391 },
				{ -18.280071837224753, 64.53692889667806 },
				{ -12.005599282440626, 69.90449288403624 },
				{ -15.348433960507627, 73.76284897555597 },
				{ -6.68600251282103, 74.4915455058785 },
				{ 2.998030336869031, 74.03781034492327 },
				{ -1.960094140523081, 75.07349844261849 },
				{ -15.076828926748462, 69.36073729753723 },
				{ -30.031410487349145, 61.42710649400129 },
				{ -40.05520688741513, 59.205534669344345 },
				{ -29.42060668078121, 62.961290745821785 },
				{ -17.403641429556902, 66.62058769838534 },
				{ -22.652774866973616, 69.41403279522797 },
				{ -11.905632587224972, 71.91120924048946 },
				{ -11.273021906845724, 73.99454417964753 },
				{ -18.67896562713895, 74.79542804707944 },
				{ -29.736817009004966, 70.34885008098765 },
				{ -17.1731657113077, 69.2662132345869 },
				{ -21.486166021371073, 68.66149714233903 },
				{ -18.974547398535005, 70.33549566981972 },
				{ -19.729108917903314, 71.98949681097534 },
				{ -23.114432789266495, 73.60889195441071 },
				{ -8.085763390695933, 78.06549552943666 },
				{ 11.250896317422013, 75.67432921399583 },
				{ 6.334824448913242, 74.28588216303629 },
			})

			addGun("MP7", 61649, 750, {
				{ 0, 0 },
				{ 0.069722261010226, 2.231823956006918 },
				{ -0.539265619331843, 3.842846630586771 },
				{ -1.982688601023381, 5.443074608031464 },
				{ -4.767971685332896, 10.23289258093878 },
				{ -9.365273666132982, 17.215859539211465 },
				{ -8.934055947462792, 25.626696786704613 },
				{ -13.803392936114664, 31.963612794930242 },
				{ -15.267230898544634, 38.490344617429415 },
				{ -20.415280418934753, 40.098545840856985 },
				{ -23.44685053098605, 41.821108849271006 },
				{ -19.318140373914662, 46.0493126896639 },
				{ -9.702244133638631, 48.055330095735215 },
				{ -0.688345730884087, 48.844519729354815 },
				{ 6.624638240861757, 49.11976206525047 },
				{ 7.0270841238404, 51.639012318148424 },
				{ 3.986837788414581, 54.300692077713805 },
				{ 2.05390170315993, 54.9549056459694 },
				{ 0.229793583182369, 55.7914527362092 },
				{ 2.01453583240772, 57.211289392253484 },
				{ 1.00019995581589, 59.21155833636318 },
				{ -6.609532398984631, 57.6564216071025 },
				{ -16.47697057292021, 52.977069235396996 },
				{ -18.47362801424918, 52.867936099664554 },
				{ -23.070832483685642, 51.64112147608396 },
				{ -21.98901064271035, 50.57935689471713 },
				{ -22.455623777677403, 49.73649257083267 },
				{ -22.594137105632267, 50.69525541573308 },
				{ -24.99847629299043, 50.909889526624134 },
				{ -25.28629793562176, 52.36981933757136 },
			})

			addGun("Bizon", 36387, 750, {
				{ 0, 0 },
				{ -0.582141432484473, 2.367243502948205 },
				{ -1.855503827259798, 3.709796919028985 },
				{ -3.376870912830269, 7.463520353804084 },
				{ -7.264901196002766, 13.534209159776184 },
				{ -13.570614494623563, 20.64947346779465 },
				{ -12.103615303123995, 30.63328502044935 },
				{ -7.390266415400039, 40.02538569735912 },
				{ -7.138940716200523, 48.31069999261444 },
				{ 1.97282250723648, 51.09965839205379 },
				{ 8.906182302422538, 53.44132061005176 },
				{ 11.706796509320172, 57.62689361873855 },
				{ 18.811316544989662, 58.854898708570076 },
				{ 15.608242047951416, 62.42543422345876 },
				{ 2.863741364136844, 61.96909433871203 },
				{ 2.65207250265792, 63.55380657710129 },
				{ 9.005738813476594, 63.61771308372924 },
				{ 11.894269668195744, 63.550825474889464 },
				{ 9.963005155437706, 64.97376429539108 },
				{ 13.317547412914601, 66.45951177162632 },
				{ 19.493237662270836, 66.26161849556772 },
				{ 26.8363251131168, 64.2083979056375 },
				{ 30.858447268607865, 64.17664741933349 },
				{ 34.232032725748226, 63.760663908353486 },
				{ 37.62988029896281, 62.71389132528789 },
				{ 37.56585539124334, 60.831739832458034 },
				{ 35.52792727547551, 61.26415847324031 },
				{ 33.9812245640443, 62.87659063513206 },
				{ 33.2004481449899, 64.48789763060152 },
				{ 22.65249095196128, 66.38417354965132 },
				{ 21.26242703409898, 67.61384034363908 },
				{ 20.582122827878383, 68.98673393089028 },
				{ 25.47572743070285, 68.01744811617388 },
				{ 17.97299352588149, 68.81117919588591 },
				{ 18.429620252686263, 65.78238790208763 },
				{ 21.06951728045704, 63.407945223002855 },
				{ 14.870455719923367, 63.86010827648909 },
				{ 16.045712134156393, 64.58860193518366 },
				{ 12.096573170028742, 66.76104033520129 },
				{ 13.266818375851658, 67.78670338198113 },
				{ 20.65162666847717, 64.6542848815072 },
				{ 27.283789528587654, 62.54420721009337 },
				{ 33.514430389121316, 57.818100858642495 },
				{ 35.934386702945226, 56.16980030941529 },
				{ 32.395647615207245, 59.02989682536549 },
				{ 33.20918582105514, 60.95475080604174 },
				{ 38.29112142994005, 59.535854168924374 },
				{ 44.067550581786286, 57.12918182298811 },
				{ 35.11956878697619, 60.01584433405053 },
				{ 25.8885286658902, 62.943032917989385 },
				{ 24.98176945948776, 63.92974076495835 },
				{ 27.24263064852074, 61.17392857094359 },
				{ 26.74501699342961, 60.84344601647423 },
				{ 27.611169450540466, 61.69702642249755 },
				{ 32.224855948934305, 60.01627629463034 },
				{ 26.12150065128629, 61.7564502573249 },
				{ 19.28198086278661, 64.04913965786078 },
				{ 11.16227820989455, 65.54959301716585 },
				{ -2.077480649994077, 63.04241260248134 },
				{ -5.19613296855344, 61.92030876367257 },
				{ -2.677008887927787, 62.9737655049631 },
				{ 5.254405273523558, 62.992287457280284 },
				{ 0.975086186704296, 63.407568825310655 },
				{ -1.939458337556546, 65.4765796871913 },
			})

			addGun("MAC10", 34079, 800, {
				{ 0, 0 },
				{ -2.216265608511797, 1.461116006276989 },
				{ -2.836459362876889, 3.351547418637371 },
				{ -1.406327428770925, 6.342249414568317 },
				{ 0.556743466247412, 12.995027116747531 },
				{ 5.684998101480691, 21.330194759279696 },
				{ 11.387954151874638, 33.217957748332175 },
				{ 15.621702454453395, 43.53435527503768 },
				{ 12.819615792044228, 52.13201721445581 },
				{ 17.15811580194303, 56.88315258498569 },
				{ 19.10167048422839, 62.42713371374432 },
				{ 21.352819737257896, 68.01014587163301 },
				{ 20.14025434967339, 71.69234568071437 },
				{ 19.02135982623825, 73.80955449280587 },
				{ 14.283659911651643, 75.35607874292698 },
				{ 4.017739802072862, 75.5128588771158 },
				{ -10.299311879612603, 72.36080488437743 },
				{ -11.198744678666092, 72.04781161596837 },
				{ -16.888913820179386, 70.23191534189347 },
				{ -13.601467086543366, 70.1921674175055 },
				{ -16.6028616072341, 69.06595069768801 },
				{ -22.544873219293308, 68.65545908909985 },
				{ -27.897930878523088, 69.66959140545633 },
				{ -19.938715497499413, 70.28209198828176 },
				{ -13.415231580192136, 71.14079715355797 },
				{ -5.549540349070455, 71.61887988702242 },
				{ 5.044795954116022, 70.85569266175654 },
				{ 6.310069788201267, 72.77640626282708 },
				{ -4.145436904313783, 70.27521096298422 },
				{ -2.979041884004872, 69.82867039819234 },
			})

			addGun("UMP", 59299, 666, {
				{ 0, 0 },
				{ -0.447553756112138, 3.243738451604018 },
				{ -2.231461892378343, 7.238728258247353 },
				{ -2.976766668521302, 15.906990552500382 },
				{ -5.35721912562942, 26.792683294427118 },
				{ -10.11874597116931, 38.12034706556247 },
				{ -11.152413439937625, 51.041045364875416 },
				{ -5.702217034356321, 59.727106153423904 },
				{ -7.8529200778257, 65.60631127361019 },
				{ -3.330994662930442, 72.2227322684621 },
				{ 6.066472142757123, 76.41772907832035 },
				{ 12.923315539753292, 78.58697508248648 },
				{ 12.692295235931336, 80.3519411385217 },
				{ 15.075631597538367, 83.50939719533861 },
				{ 14.91476769939795, 86.2534297680375 },
				{ 19.498492763345915, 84.61397580353535 },
				{ 22.323626327482767, 83.48969495195203 },
				{ 15.915778941400887, 86.06219403446718 },
				{ 6.494144835598191, 87.19699076298707 },
				{ 6.801493482263551, 86.0469817103183 },
				{ 13.433801244092885, 83.2001819591268 },
				{ 21.68096708698191, 82.08393905900269 },
				{ 19.756676279979178, 83.23670173779946 },
				{ 9.050028164895055, 82.68500404709634 },
				{ 7.136943489910397, 82.0058823979918 },
			})

			local mp9_pattern = {
				{ 0, 0 },
				{ -0.303841782200537, 2.792520937197335 },
				{ -1.714246580759466, 4.97084994129804 },
				{ -0.129029042347133, 10.535952845419471 },
				{ -0.901293606581709, 19.311699153554947 },
				{ 3.998611274271228, 30.028988294012752 },
				{ 3.341943383093199, 40.45287580120788 },
				{ -0.641041518577608, 51.47268699816286 },
				{ 4.627529780025419, 58.492765783097276 },
				{ 15.06362952745987, 63.28853968383331 },
				{ 26.124826520243406, 63.3353622862474 },
				{ 38.84815962732787, 60.287559889991606 },
				{ 38.385904513091084, 65.18130494771448 },
				{ 38.8075067742448, 70.70395303284664 },
				{ 27.147945618041742, 74.47004173424 },
				{ 20.57277390427629, 78.87152204943186 },
				{ 11.561928871693835, 82.51159483356491 },
				{ 4.569040979901547, 85.6109957633187 },
				{ -5.917495281551617, 85.02938723688243 },
				{ -20.875237022946248, 79.84398112916276 },
				{ -18.311550065162884, 81.05245661690122 },
				{ -10.104635303211097, 82.48064333550738 },
				{ 0.229841004104084, 83.00842072678327 },
				{ 1.717147328390929, 84.12207197094625 },
				{ -6.955472220565271, 83.12287646316292 },
				{ -20.101689834400027, 79.46463695906648 },
				{ -23.070392703624595, 81.21791875947281 },
				{ -28.353669272463446, 83.53887227124113 },
				{ -23.61221702787463, 86.29136070516171 },
				{ -21.134777391438586, 88.89361865890962 },
			}
			addGun("MP9", 50729, 857, mp9_pattern)
			addGun("MP9_alt", 50729, 857, mp9_pattern)

			addGun("Negev", 57966, 800, {
				{ 0, 0 },
				{ 0.985554778432676, 3.684132561804101 },
				{ 4.101272703940044, 8.69501274604477 },
				{ 4.164124204583452, 18.724777646426602 },
				{ 0.518603328801917, 30.703316600239717 },
				{ -4.081871401739883, 43.94827811875222 },
				{ -1.262865427267654, 58.26377789783995 },
				{ 0.044465207097377, 71.36539947174965 },
				{ -5.703553041690306, 86.44162990790446 },
				{ -15.145664438784877, 96.9298457416128 },
				{ -17.994706935075282, 106.00369618820932 },
				{ -14.762811224237133, 113.87978484450936 },
				{ -3.990184519724612, 117.21960376435045 },
				{ 7.81948797874669, 118.91115736096783 },
				{ 23.62625079596893, 120.10096655864663 },
				{ 28.75592901307781, 122.7706595248827 },
				{ 35.05883322824389, 124.76862762551856 },
				{ 29.972981058348715, 126.80877385524619 },
				{ 27.97098835779552, 129.223542113227 },
				{ 30.540992527552923, 131.73049719898506 },
				{ 34.21806462694504, 134.57854501851642 },
				{ 38.91279549535921, 134.2381443739862 },
				{ 38.39614569892081, 134.27276418636217 },
				{ 28.103806342812362, 133.55135900269775 },
				{ 15.237097678312008, 133.64206386033456 },
				{ 4.264023214910731, 135.8944646293456 },
				{ -12.341046708202605, 135.71342674507338 },
				{ -20.829597955416816, 135.86968828589883 },
				{ -17.787871141419522, 136.08799782581931 },
				{ -11.472353419794587, 136.89358621288986 },
				{ -1.920802229520826, 137.54473856346314 },
				{ 3.874480389396064, 138.9486042938063 },
				{ 7.852193929344909, 142.32433117233117 },
				{ 17.150335974496798, 145.67915660410426 },
				{ 21.185109605477532, 148.46418499725556 },
				{ 25.555792922631426, 149.78256656618183 },
				{ 19.196603104320086, 149.11599228290137 },
				{ 6.070646967869495, 145.78396764537501 },
				{ -6.717592482224916, 143.37322282537806 },
				{ -18.60443479883614, 142.16704271135134 },
				{ -29.41416406856539, 139.12488982647437 },
				{ -26.2801707657242, 138.18264663935562 },
				{ -15.840498941592747, 137.69492770873322 },
				{ -15.071897807951752, 138.30049581700422 },
				{ -17.651577945520906, 140.7602083076362 },
				{ -25.606085718236486, 141.50273821565207 },
				{ -24.347572308278103, 142.75234194065928 },
				{ -20.339488429183596, 143.4676400449643 },
				{ -23.047150589210112, 142.42563542422758 },
				{ -22.06231053472401, 141.55667720778686 },
				{ -17.41503054109683, 144.01377953915656 },
				{ -8.940244355646819, 148.01972319640652 },
				{ 1.554105076978439, 149.27054386956078 },
				{ 9.146623814278652, 149.41237690269682 },
				{ 6.089733871583919, 148.05086206071783 },
				{ -5.260693659867555, 143.48551719423918 },
				{ -19.96316629771239, 136.1698906447916 },
				{ -30.933933076683587, 134.43612399773482 },
				{ -44.579189288785074, 132.89708722537705 },
				{ -54.3266107638741, 130.46862103406107 },
				{ -51.88929971318348, 131.1818477933149 },
				{ -45.40000962314569, 133.83772728647332 },
				{ -43.33237398655774, 135.59556438313746 },
				{ -47.89527656705219, 137.26967443116826 },
				{ -49.05208086894835, 142.32060384327804 },
				{ -40.22213937918015, 140.5170483991216 },
				{ -25.117042307962222, 132.24499450866278 },
				{ -17.09335097901886, 125.41351808722196 },
				{ -16.78227219691709, 119.89606105943516 },
				{ -19.009792164650417, 119.39837817063153 },
				{ -14.22445992924781, 121.79602244618809 },
				{ -10.065110381888505, 124.64156304034904 },
				{ -13.901405040875176, 125.95457271561857 },
				{ -21.96319015321947, 126.32205914252971 },
				{ -23.620390044146802, 127.9499009569824 },
				{ -20.29501402392886, 132.1331398287987 },
				{ -8.322243025610602, 134.63131671050942 },
				{ 6.891113156576055, 132.04591865626205 },
				{ 21.871345502420315, 127.9806770626795 },
				{ 26.926207805482917, 127.44653306729867 },
				{ 33.40180042514775, 127.50353240900851 },
				{ 28.56435639447287, 128.38792905261997 },
				{ 27.554864944014938, 132.0422649040514 },
				{ 30.691937165788318, 135.2221561926079 },
				{ 33.70180682425932, 135.75825682267478 },
				{ 38.165803517202384, 134.2334993405417 },
				{ 37.62610603140598, 133.72257156885058 },
				{ 27.40897545143463, 132.80486405358852 },
				{ 17.114344110776045, 135.17501558974857 },
				{ 2.779419394627588, 138.2837534344268 },
				{ -12.87244033403568, 135.99420546155343 },
				{ -20.924433944141796, 135.16300059405583 },
				{ -17.69094902637014, 134.995607341243 },
				{ -11.31017402089798, 135.72718111754403 },
				{ -3.445172281372707, 138.66437931645746 },
				{ 3.373485089007222, 143.46528708693035 },
				{ 8.499824714010987, 145.80392328255564 },
				{ 17.29801541035648, 145.75159358192445 },
				{ 21.099226669568154, 146.96388907324285 },
				{ 25.3670375287258, 147.7056576016038 },
				{ 20.40311284022905, 149.61472298161695 },
				{ 6.968834172085077, 149.7524443046743 },
				{ -8.584348738236368, 145.02846963705747 },
				{ -18.74343406582596, 141.26892623393445 },
				{ -28.833488314320466, 137.14559636417195 },
				{ -25.463141155397835, 135.89271311572904 },
				{ -15.02896893836856, 135.47958480400325 },
				{ -14.712054096370348, 138.50574271366986 },
				{ -17.851230895735753, 142.19313945157512 },
				{ -25.2828615544982, 140.98595232565162 },
				{ -23.836108225361183, 141.38781569632343 },
				{ -19.804083022044917, 141.8442084649643 },
				{ -22.558336533942303, 140.84136945227215 },
				{ -22.15597033165013, 142.66047267747555 },
				{ -16.65045769475723, 146.08724358072317 },
				{ -8.940244355646819, 148.01972319640652 },
				{ 1.554105076978439, 149.27054386956078 },
				{ 9.146623814278652, 149.41237690269682 },
				{ 6.089733871583919, 148.05086206071783 },
				{ -3.409067281123054, 145.43737056558803 },
				{ -19.525506565309275, 141.07288079327992 },
				{ -32.841524677616235, 137.06813740094177 },
				{ -44.64149090083515, 132.8556726646392 },
				{ -53.598484025644446, 129.19391816801937 },
				{ -50.89275429321312, 129.45498680162524 },
				{ -46.25300090286596, 133.84745087290316 },
				{ -44.5385614952901, 139.09547779355208 },
				{ -49.22221809498269, 139.61464266054327 },
				{ -48.757208628414276, 141.7550106685705 },
				{ -39.26197141351423, 138.65796715095325 },
				{ -23.9949931767764, 129.9810061092713 },
				{ -16.049474079122422, 123.18586104585358 },
				{ -16.201394981190322, 120.94935030590912 },
				{ -19.01602615470947, 120.3519877360056 },
				{ -13.782995373504752, 121.11877127880344 },
				{ -9.493350159342405, 123.27704686029273 },
				{ -13.340885053581806, 124.40458004078316 },
				{ -21.46018547525462, 124.83486043119741 },
				{ -23.270173776108862, 128.47890217092728 },
				{ -19.65154751940541, 134.2254479982155 },
				{ -8.04034043810163, 134.59968252979874 },
				{ 7.009484246893028, 131.05321530118144 },
				{ 21.897630900703536, 126.65242615244469 },
				{ 26.896001037459403, 126.09574409678267 },
				{ 32.77118100544909, 128.3922768922543 },
				{ 29.38716034734682, 132.41335788762413 },
				{ 28.160363151386615, 135.22601249996035 },
				{ 30.978281773937127, 135.18832523152452 },
				{ 33.782748364362725, 134.261078391195 },
				{ 38.12225803263848, 132.22173176058635 },
			})

			local function getGun()
				local gunObj = playerService.LocalPlayer:FindFirstChild("Gun")
				if gunObj and gunObj:IsA("StringValue") then
					local currentGun = gunObj.Value
					if currentGun == "" or currentGun == "USP" or currentGun == "Zeus" then
						return nil
					end

					return guns[normalizeName(currentGun)]
				end

				return nil
			end

			local function resetRecoil()
				currentIndex = 1
				isHolding = false
				remainderX = 0
				remainderY = 0
				smoothX = 0
				smoothY = 0
				lastShootTime = 0
			end

			inputService.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					isHolding = true
				end
			end)

			inputService.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					isHolding = false
					resetRecoil()
				end
			end)

			runService.RenderStepped:Connect(function()
				if not enabled then
					return
				end
				if Library.Flags.rcs_cm ~= "Custom" then
					return
				end
				if not isHolding then
					return
				end
				if window.Gui.Visible or Library.Flags.gm_r then
					return
				end

				local gun = getGun()
				if not gun then
					resetRecoil()
					return
				end

				local now = tick()
				local interval = 60 / gun.rpm

				if now - lastShootTime >= interval then
					lastShootTime = now

					local pattern = gun.recoilPattern
					local curr = pattern[currentIndex]
					local prev = pattern[currentIndex - 1] or { 0, 0 }

					if curr then
						local mul = Library.Flags.rcs_red / 100

						local moveX = ((curr[1] - prev[1]) * mul) + remainderX
						local moveY = ((curr[2] - prev[2]) * mul) + remainderY

						local fx = math.floor(moveX + 0.5)
						local fy = math.floor(moveY + 0.5)

						remainderX = moveX - fx
						remainderY = moveY - fy

						smoothX += fx
						smoothY += fy

						if currentIndex < #pattern then
							currentIndex += 1
						end
					end
				end

				local smoothing = math.clamp((Library.Flags.rcs_red / 100) * 0.15, 0.02, 0.3)

				if math.abs(smoothX) > 0.01 or math.abs(smoothY) > 0.01 then
					local dx = smoothX * smoothing
					local dy = smoothY * smoothing

					local ix = math.floor(dx + 0.5)
					local iy = math.floor(dy + 0.5)

					smoothX -= ix
					smoothY -= iy

					mousemoverel(ix, iy)
				end
			end)

			local function handleRCS(input, gameProcessed)
				if not enabled then
					return
				end
				if
					input.UserInputType == Enum.UserInputType.MouseButton1
					and not window.Gui.Visible
					and not Library.Flags.gm_r
				then
					if rawequal(Library.Flags.rcs_cm, "Linear") then
						resetRecoil() -- pls work
						isHolding = false
						if
							LocalPlayer:FindFirstChild("Gun")
							and table.find(automaticGuns, LocalPlayer.Gun.Value:lower())
						then
							while inputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
								local moveY = math.max(strength / 100 * 10, 1) -- minimum of 1 pixel
								mousemoverel(0, moveY)
								task.wait()
							end
						end
					end
				end
			end

			local rcsSec = tab:createSection({ Text = "Recoil Control", Location = 2 })

			rcsSec:createToggle({
				Text = "Enabled",
				Flag = "rcs_enabled",
				Callback = function(val)
					enabled = val
					if enabled then
						inputConnection = inputService.InputBegan:Connect(handleRCS)
					else
						if inputConnection then
							inputConnection:Disconnect()
							inputConnection = nil
						end
					end
				end,
			})

			rcsSec:createToggle({
				Text = "Remove recoil on snipers",
				Flag = "rcs_reconsnipers",
			})

			rcsSec:createDropdown({
				Text = "Compensation mode",
				Options = { "Linear", "Custom" },
				Default = "Custom",
				Flag = "rcs_cm",
			})

			rcsSec:createSlider({
				Text = "Strength (%)",
				Min = 0,
				Max = 100,
				Value = 15,
				Flag = "rcs_red",
				Callback = function(val)
					strength = val
				end,
			})
		end

		-- RAGE TAB
		do
			local conn
			local tab = window:createTab({ Text = "Rage", Small = true })
			local rageSec = tab:createSection({ Text = "Ragebot", Location = 1 })
			local ragebotConn

			rageSec:createToggle({
				Text = "Enabled",
				Flag = "rage_enabled",
				Callback = function(a)
					if a then
						ragebotConn = runService.Heartbeat:Connect(function(dt: number)
							if nocturnal:isAlive(playerService.LocalPlayer) then
								local bestDist = math.huge
								local bestPlayer = nil
								for _, p in playerService:GetPlayers() do
									if p ~= playerService.LocalPlayer and p.Character and p.Character.Parent then
										-- alive check
										local humanoidOther = p.Character:FindFirstChildOfClass("Humanoid")

										if nocturnal:isAlive(p) then
											local okTeam = true
											pcall(function()
												if
													playerService.LocalPlayer.PlayerStates.Team
													and p.PlayerStates.Team
													and playerService.LocalPlayer.PlayerStates.Team.Value
														== p.PlayerStates.Team.Value
												then
													okTeam = false
												end
											end)
											if not okTeam then
												continue
											end

											local c = p.Character
											local pHRP = c
												and (
													c:FindFirstChild("HumanoidRootPart")
													or c:FindFirstChild("UpperTorso")
													or c:FindFirstChild("Torso")
												)
											local hrp = playerService.LocalPlayer.Character
												and playerService.LocalPlayer.Character:FindFirstChild(
													"HumanoidRootPart"
												)
											if not hrp then
												continue
											end

											if pHRP then
												local d = (pHRP.Position - hrp.Position).Magnitude
												if d < bestDist then
													bestDist = d
													bestPlayer = p
												end
											end
										end
									end
								end

								if bestPlayer then
									local targetPart = chooseHitPart(bestPlayer)
									if targetPart then
										local frac, _ = evaluatePartVisibility(targetPart)
										local visible = frac > 0

										if not visible then
											if not Library.Flags.rage_aw then
												return
											end

											local lp = playerService.LocalPlayer
											local char = lp.Character
											if not char then
												return
											end
											local origin = char.Head.Position
											local dir = targetPart.Position - origin
											if dir.Magnitude <= 0.001 then
												return
											end

											local ignore = { char, workspace.CurrentCamera }
											local wallsHit = 0
											local canHit = false
											local unitDir = dir.Unit

											while wallsHit < 4 do
												local params = RaycastParams.new()
												params.FilterType = Enum.RaycastFilterType.Exclude
												params.FilterDescendantsInstances = ignore
												params.CollisionGroup = "ShootCast"
												params.IgnoreWater = true

												local result = workspace:Raycast(origin, unitDir * 10000, params)
												if not result then
													break
												end

												if
													result.Instance
													and result.Instance:IsDescendantOf(bestPlayer.Character)
												then
													canHit = true
													local currentGun = string.lower(
														playerService.LocalPlayer:FindFirstChild("Gun").Value
													)
													local weaponData = nocturnal.weapons[currentGun]
													if not weaponData then
														return
													end

													local predictedDmg =
														nocturnal.weapons[string.lower(currentGun)].damage
													nocturnal._lastShot = nocturnal._lastShot or {}
													local lastShot = nocturnal._lastShot[currentGun] or 0
													local timeSinceLast = tick() - lastShot
													local fireDelay = 60 / weaponData.rpm --// seconds per shot

													if timeSinceLast >= fireDelay then
														--// Update last shot time
														nocturnal._lastShot[currentGun] = tick()
														task.spawn(function()
															nocturnal:FireBullet(bestPlayer, result, predictedDmg)
														end)
													end

													break
												end

												wallsHit += 1
												table.insert(ignore, result.Instance)
												origin = result.Position + unitDir * 0.05
											end

											if not canHit then
												return
											end
										else
											local aimPos = targetPart.Position

											-- if limbs/part has visible sample, prefer that precise sample
											local bestSample, sampleFrac = nocturnal:getBestVisibleSample(targetPart)
											if bestSample and sampleFrac > 0 then
												if nocturnal.resolvePlayerYaw and Library.Flags.rage_rs then
													local resolvedYaw = nocturnal:resolvePlayerYaw(bestPlayer)
													if resolvedYaw then
														local rad = math.rad(resolvedYaw)
														local forward = Vector3.new(math.sin(rad), 0, math.cos(rad))

														bestSample = bestSample + forward * 0.02
													end
												end
												aimPos = bestSample
											else
												if nocturnal.resolvePlayerYaw and Library.Flags.rage_rs then
													local resolvedYaw = nocturnal:resolvePlayerYaw(bestPlayer)
													if resolvedYaw then
														local rad = math.rad(resolvedYaw)
														local forward = Vector3.new(math.sin(rad), 0, math.cos(rad))
														aimPos = aimPos + forward * 0.15
													end
												end
											end

											if Library.Flags.rage_as then
												local currentGun =
													string.lower(playerService.LocalPlayer:FindFirstChild("Gun").Value)
												local weaponData = nocturnal.weapons[currentGun]
												if not weaponData then
													return
												end

												--// Init lastShot if needed
												nocturnal._lastShot = nocturnal._lastShot or {}
												local lastShot = nocturnal._lastShot[currentGun] or 0
												local timeSinceLast = tick() - lastShot
												local fireDelay = 60 / weaponData.rpm --// seconds per shot

												if timeSinceLast >= fireDelay then
													--// Update last shot time
													nocturnal._lastShot[currentGun] = tick()

													local origin = playerService.LocalPlayer.Character.Head.Position
													local dir = (aimPos - origin)
													if dir.Magnitude <= 0.001 then
														dir = workspace.CurrentCamera.CFrame.LookVector * 1
													end
													local params = RaycastParams.new()
													params.FilterDescendantsInstances =
														{ playerService.LocalPlayer.Character, workspace.CurrentCamera }
													params.FilterType = Enum.RaycastFilterType.Exclude
													params.CollisionGroup = "ShootCast"
													params.IgnoreWater = true

													local result = workspace:Raycast(
														origin,
														dir.Unit * math.min(dir.Magnitude + 2, 4000),
														params
													)

													local hitPos, hitNormal, hitInstance
													if result then
														hitPos = result.Position
														hitNormal = result.Normal
														hitInstance = result.Instance
													else
														hitPos = aimPos
														hitNormal = Vector3.new(0, 1, 0)
														hitInstance = nil
													end

													pcall(function()
														local predictedDmg = weaponData.damage
														if hitInstance and hitInstance.Name == "Head" then
															predictedDmg = predictedDmg * weaponData.headshot_multiplier
														end

														if predictedDmg > 0 then
															if
																result
																and result.Instance
																and result.Instance:IsDescendantOf(bestPlayer.Character)
															then
																task.spawn(function()
																	nocturnal:FireBullet(
																		bestPlayer,
																		result,
																		predictedDmg
																	)
																end)
															end

															if Library.Flags.t_hm then
																if Library.Flags.t_hmm == "Character" then
																	local clone = nocturnal:replicateCharacter(
																		bestPlayer.Character
																	)
																	if Library.Flags.ro_effects then
																		for Index, Part in clone:GetDescendants() do
																			if Part:IsA("BasePart") then
																				tweenService
																					:Create(
																						Part,
																						TweenInfo.new(
																							0.86,
																							Enum.EasingStyle.Quart,
																							Enum.EasingDirection.Out
																						),
																						{ Transparency = 1 }
																					)
																					:Play()
																			end
																		end
																	end
																	Services.Debris:AddItem(clone, 2)
																else
																	task.spawn(function()
																		local hit = Instance.new("Part")
																		hit.Transparency = 1
																		hit.Anchored = true
																		hit.CanCollide = false
																		hit.Size = Vector3.new(0.3, 0.3, 0.3)
																		hit.Position = hitPos
																		local selection = Instance.new("SelectionBox")
																		selection.LineThickness = 0
																		selection.SurfaceTransparency = 0.5
																		selection.Color3 = Library.Flags.t_hmc
																		selection.SurfaceColor3 = Library.Flags.t_hmc
																		selection.Parent = hit
																		selection.Adornee = hit
																		hit.Parent = workspace.ServerIgnore
																		hit.CollisionGroup = "Smoke"
																		task.wait(3)
																		tweenService
																			:Create(
																				selection,
																				TweenInfo.new(
																					0.1,
																					Enum.EasingStyle.Quad,
																					Enum.EasingDirection.Out
																				),
																				{ SurfaceTransparency = 1 }
																			)
																			:Play()
																		hit:Destroy()
																	end)
																end
															end

															if Library.Flags.o_dt then
																task.delay(0.1, function()
																	if
																		result
																		and result.Instance
																		and result.Instance:IsDescendantOf(
																			bestPlayer.Character
																		)
																	then
																		task.spawn(function()
																			nocturnal:FireBullet(
																				bestPlayer,
																				result,
																				predictedDmg
																			)
																		end)
																	end

																	if Library.Flags.t_hm then
																		if Library.Flags.t_hmm == "Character" then
																			local clone = nocturnal:replicateCharacter(
																				bestPlayer.Character
																			)
																			if Library.Flags.ro_effects then
																				for Index, Part in
																					clone:GetDescendants()
																				do
																					if Part:IsA("BasePart") then
																						tweenService
																							:Create(
																								Part,
																								TweenInfo.new(
																									0.86,
																									Enum.EasingStyle.Quart,
																									Enum.EasingDirection.Out
																								),
																								{ Transparency = 1 }
																							)
																							:Play()
																					end
																				end
																			end
																			Services.Debris:AddItem(clone, 2)
																		else
																			task.spawn(function()
																				local hit = Instance.new("Part")
																				hit.Transparency = 1
																				hit.Anchored = true
																				hit.CanCollide = false
																				hit.Size = Vector3.new(0.3, 0.3, 0.3)
																				hit.Position = hitPos
																				local selection =
																					Instance.new("SelectionBox")
																				selection.LineThickness = 0
																				selection.SurfaceTransparency = 0.5
																				selection.Color3 = Library.Flags.t_hmc
																				selection.SurfaceColor3 =
																					Library.Flags.t_hmc
																				selection.Parent = hit
																				selection.Adornee = hit
																				hit.Parent = workspace.ServerIgnore
																				hit.CollisionGroup = "Smoke"
																				task.wait(3)
																				tweenService
																					:Create(
																						selection,
																						TweenInfo.new(
																							0.1,
																							Enum.EasingStyle.Quad,
																							Enum.EasingDirection.Out
																						),
																						{ SurfaceTransparency = 1 }
																					)
																					:Play()
																				hit:Destroy()
																			end)
																		end
																	end
																end)
															end
														else
															if Library.Flags.ro_hl then
																Notification.new("Unable to send hit; Dmg too low")
															end
														end
													end)
												end -- firerate check
											end -- autoshoot
										end -- visible/autowall
									end -- targetPart
								end -- bestPlayer
							end -- rage enabled & alive
						end)
					else
						if ragebotConn then
							ragebotConn:Disconnect()
							ragebotConn = nil
						end
					end
				end,
			})

			rageSec:createToggle({ Text = "Silent Aim", Flag = "rage_sa" })
			rageSec:createToggle({
				Text = "Force fire",
				Flag = "rage_sa2",
				Callback = function(a)
					if a then
						local lastShot = 0
						conn = runService.Heartbeat:Connect(function(dt: number)
							if not inputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
								return
							end

							if not nocturnal:isAlive(playerService.LocalPlayer) then
								return
							end

							if playerService.LocalPlayer.Gun.Value:lower():find("nova") then
								return
							end

							if tick() - lastShot < 0.1 then
								return
							end
							lastShot = tick()

							local targetPlayer = nocturnal:gcptest()
							if not targetPlayer then
								return
							end
							local head = targetPlayer.Character.Head

							local params = RaycastParams.new()
							local list =
								{ playerService.LocalPlayer.Character, workspace.CurrentCamera, workspace.ServerIgnore }
							params.FilterType = Enum.RaycastFilterType.Blacklist
							if Library.Flags.rage_wbb then
								table.insert(list, workspace.Map)
							end
							params.FilterDescendantsInstances = list
							params.CollisionGroup = "ShootCast"

							local result = workspace:Raycast(
								workspace.CurrentCamera.CFrame.Position,
								head.Position - workspace.CurrentCamera.CFrame.Position,
								params
							)

							if
								result
								and result.Instance
								and result.Instance:IsDescendantOf(targetPlayer.Character)
							then
								task.spawn(function()
									nocturnal:FireBullet(targetPlayer, result)
								end)
							end
						end)
					else
						if conn then
							conn:Disconnect()
							conn = nil
						end
					end
				end,
			})
			rageSec:createToggle({ Text = "Auto Shoot", Flag = "rage_as" })
			rageSec:createToggle({ Text = "Auto Wall", Flag = "rage_aw" })
			rageSec:createToggle({ Text = "Allow Bodyaim", Flag = "rage_ab" })
			rageSec:createToggle({ Text = "Allow Wallbang", Flag = "rage_wbb" })
			rageSec:createToggle({ Text = "Force safe point", Flag = "rage_fsp" })
			rageSec:createDropdown({
				Text = "Hitbox Priority",
				Options = { "Head", "Body", "Auto", "Prefer Safe" },
				Default = "Head",
				Flag = "rage_hb",
			})
			rageSec:createSeperator({})
			rageSec:createToggle({ Text = "Resolver", Flag = "rage_rs" })
			rageSec:createToggle({ Text = "LBY Checking", Flag = "rage_lby" })
			rageSec:createSlider({ Text = "Resolver History", Min = 1, Max = 12, Value = 12, Flag = "rage_rsh" })

			rageSec:createDropdown({
				Text = "Resolver Mode",
				Options = { "Aggressive", "Safe", "Bruteforce" },
				Default = "Safe",
				Flag = "rage_rsm",
			})

			local aaSec = tab:createSection({ Text = "Anti-Aim", Location = 2 })
			aaSec:createToggle({ Text = "Enabled", Flag = "aa_enabled" })
			aaSec:createToggle({ Text = "Upside Down", Flag = "aa_upside" })
			aaSec:createSlider({ Text = "Yaw", Min = 0, Max = 180, Value = 90, Flag = "aa_yaw" })
			aaSec:createSlider({ Text = "Pitch", Min = 0, Max = 90, Value = 90, Flag = "aa_pitch" })
			aaSec:createSlider({ Text = "Jitter/Spin Speed", Min = 1, Max = 150, Value = 10, Flag = "aa_js" })
			aaSec:createDropdown({
				Text = "AA Mode",
				Options = { "Static", "Jitter", "Spin", "Freestanding", "Custom" },
				Default = "Freestanding",
				Flag = "aa_mode",
			})
			aaSec:createDropdown({
				Text = "Angle Mode",
				Options = { "Down", "Up", "Troll", "In Torso", "Shake" },
				Default = "Down",
				Flag = "aa_cangle",
			})
			aaSec:createSeperator({})
			aaSec:createToggle({ Text = "Desync", Flag = "aa_desync" })
			aaSec
				:createToggle({ Text = "Visualize angles", Flag = "aa_desyncv" })
				:createColorpicker({ Text = "Color", Default = Color3.fromRGB(255, 0, 255), Flag = "aa_desynccolor" })
			aaSec:createSlider({ Text = "Desync ticks", Min = 1, Max = 5000, Value = 10, Flag = "desync_ticks" })

			aaSec:createDropdown({
				Text = "Desync Mode",
				Options = { "Offset", "Extrapolate", "Anti-Ragebot" },
				Default = "Offset",
				Flag = "aa_desyncmode",
			})
			aaSec:createSeperator({})

			aaSec:createToggle({ Text = "Fake Yaw", Flag = "aa_fy" })
			aaSec:createSlider({ Text = "Fake Offset", Min = 0, Max = 90, Value = 0, Flag = "aa_fo" })
			aaSec:createSeperator({})
			aaSec
				:createToggle({ Text = "Manual Left", Flag = "uutyutyut" })
				:createBind({ Flag = "aa_ml", Callback = function() end, PlsIgnore = true })
			aaSec
				:createToggle({ Text = "Manual Back", Flag = "uutyutyut2" })
				:createBind({ Flag = "aa_mb", Callback = function() end, PlsIgnore = true })
			aaSec
				:createToggle({ Text = "Manual Right", Flag = "uutyutyut3" })
				:createBind({ Flag = "aa_mr", Callback = function() end, PlsIgnore = true })
			local lagtick = 0
			local lagconn
			local fakelagSec = tab:createSection({ Text = "Fake Lag", Location = 2 })
			fakelagSec
				:createToggle({ Text = "Fakelag", Flag = "fakelag_enabled", Callback = function(a) end })
				:createBind({
					Flag = "fakelag_key",
					Callback = function()
						if
							Library.Flags.fakelag_enabled
							and rawequal(Library.Flags.fakelag_mode, "Prevent Replication")
						then
							settings().Network.IncomingReplicationLag = 9e9
						else
							settings().Network.IncomingReplicationLag = 0
						end
					end,
				})
			fakelagSec
				:createToggle({ Text = "Visualize lag", Flag = "fakelag_vis" })
				:createColorpicker({ Text = "Color", Default = Color3.fromRGB(255, 255, 255), Flag = "fakelag_color" })
			fakelagSec:createDropdown({
				Text = "Lag mode",
				Options = { "Instance", "Prevent Replication", "Physics" },
				Default = "Instance",
				Flag = "fakelag_mode",
			})
			fakelagSec:createSlider({ Text = "Lag ticks", Min = 1, Max = 20, Value = 10, Flag = "fakelag_ticks" })

			task.spawn(function()
				local Sleeping = false

				runService.PostSimulation:Connect(function()
					if
						nocturnal.loadcomplete
						and nocturnal:isAlive(playerService.LocalPlayer)
						and Library.Flags.fakelag_enabled
						and Library.Flags.fakelag_mode == "Physics"
					then
						Sleeping = not Sleeping
						sethiddenproperty(
							playerService.LocalPlayer.Character.HumanoidRootPart,
							"NetworkIsSleeping",
							Sleeping
						)
					end
				end)

				--[[

				table.insert(nocturnal.connections, inputService.InputBegan:Connect(function(input, gp)
					
				end))

				]]
			end)

			task.spawn(function()
				while task.wait(1 / 20) do
					lagtick = math.clamp(lagtick + 1, 0, Library.Flags.fakelag_ticks or 5)
					if
						nocturnal.loadcomplete
						and nocturnal:isAlive(playerService.LocalPlayer)
						and Library.Flags.fakelag_enabled
						and rawequal(Library.Flags.fakelag_mode, "Instance")
					then
						if rawequal(lagtick, (math.random(1, Library.Flags.fakelag_ticks))) then
							Services.NetworkClient:SetOutgoingKBPSLimit(9e9)
							nocturnal.getSecuredFolder():ClearAllChildren()
							lagtick = 0

							if Library.Flags.fakelag_vis then
								local i = Instance.new("Model", nocturnal.getSecuredFolder())
								i.Name = "FakeChar2"
								for _, v: BasePart in playerService.LocalPlayer.Character:GetDescendants() do
									if v:IsA("BasePart") and v.Transparency ~= 1 then
										local a = v:Clone()
										a.CanCollide = false
										a.Parent = i
										v.CanQuery = false
										a.Anchored = true
										a.Color = Library.Flags.fakelag_color
										a.Material = "ForceField"
										a.Transparency = 0.6
										a.Reflectance = 0

										if a:IsA("MeshPart") then
											a.TextureID = ""
										end

										for _, c in a:GetChildren() do
											if not c:IsA("SpecialMesh") then
												c:Destroy()
											else
												c.TextureId = ""
											end
										end
									end
								end
							end
						else
							if Library.Flags.fakelag_enabled then
								Services.NetworkClient:SetOutgoingKBPSLimit(1)
							end
						end
					else
						nocturnal.getSecuredFolder():ClearAllChildren()
						Services.NetworkClient:SetOutgoingKBPSLimit(9e9)
					end
				end
			end)

			local gunSec = tab:createSection({ Text = "Gun Modulation", Location = 1 })

			--patterns Ammo + StoredAmmo -> 9999
			--[[gunSec:createToggle({
				Text = "Infinite Ammo",
				Flag = "gm_ammo",
				Callback = function(value)
					local pats = {"Ammo", "StoredAmmo"}
					if value then nocturnal:applyOverride(pats, 9999) else nocturnal:restoreDefaults(pats) end
				end
			})]]

			gunSec:createToggle({
				Text = "Fire Rate",
				Flag = "gm_fr",
				Callback = function(enabled)
					for name, data in pairs(weaponStats) do
						if type(data) == "table" then
							if enabled then
								data["Fire_Rate_RPM"] = 100000
							else
								data["Fire_Rate_RPM"] = defaultStats[name]["Fire_Rate_RPM"]
							end
						end
					end
				end,
			})

			local noSpreadFields = {
				"Standing_Inaccuracy",
				"Crouching_Inaccuracy",
				"Running_Inaccuracy",
				"Ladder_Inaccuracy",
				"Inaccuracy_at_Jump_Apex",
				"Inaccuracy_After_Landing",
				"Inaccuracy_From_Firing",
				"Recoil_Amount",
				"Recoil_Angle_Variance",
				"Recoil_Amount_Variance",
				"Accurate_Range_Stand",
				"Accurate_Range_Crouch",
			}

			gunSec:createToggle({
				Text = "No Spread",
				Flag = "gm_s",
				Callback = function(enabled)
					local pats = { "Spread", "maxinaccuracy", "Move", "Land", "Crouch", "Stand" }
					if enabled then
						nocturnal:applyOverride(pats, 0)
					else
						nocturnal:restoreDefaults(pats)
					end

					for name, data in pairs(weaponStats) do
						if type(data) == "table" then
							if enabled then
								for _, field in ipairs(noSpreadFields) do
									if field:find("Range") then
										data[field] = 999999
									else
										data[field] = 0
									end
								end
							else
								-- restore every field
								for _, field in ipairs(noSpreadFields) do
									data[field] = defaultStats[name][field]
								end
							end
						end
					end
				end,
			})

			local seed = require(replicatedStorage.Import.GunWork.Client.CSSpread.Seed)
			local genFunc = seed.GenerateRecoilTable
			local recoilTable
			local name, val = debug.getupvalue(genFunc, 1)
			recoilTable = name

			if not recoilTable then
				return
			end

			local originalRecoil = {}

			local function overrideRecoil()
				for k, sub in recoilTable do
					originalRecoil[k] = originalRecoil[k] or {}
					for i = 1, #sub do
						originalRecoil[k][i] = originalRecoil[k][i] or { sub[i][1], sub[i][2] }
						sub[i][1] = 0
						sub[i][2] = 0
					end
				end
			end

			local function restoreRecoil()
				for k, sub in recoilTable do
					if originalRecoil[k] then
						for i = 1, #sub do
							if originalRecoil[k][i] then
								sub[i][1] = originalRecoil[k][i][1]
								sub[i][2] = originalRecoil[k][i][2]
							end
						end
					end
				end
			end

			gunSec:createToggle({
				Text = "No Recoil",
				Flag = "gm_r",
				Callback = function(value)
					if value then
						overrideRecoil()
					else
						restoreRecoil()
					end
				end,
			})

			local circleColor = Color3.fromRGB(255, 255, 255)
			local circleHeight = -3
			local circleLines = {}
			local knifebotconn
			local knifeSec = tab:createSection({ Text = "Knifebot", Location = 2 })
			knifeSec:createToggle({
				Text = "Enabled",
				Flag = "kb_enabled",
				Callback = function(a)
					if a then
						knifebotconn = runService.RenderStepped:Connect(function()
							if nocturnal.loadcomplete and nocturnal:isAlive(playerService.LocalPlayer) then
								local hrp = playerService.LocalPlayer.Character.PrimaryPart

								if Library.Flags.kb_vis then
									local center = hrp.Position + Vector3.new(0, circleHeight, 0)
									local points = {}

									for i = 0, 360 do
										local theta = (i / 360) * math.pi * 2
										local offset = Vector3.new(
											math.cos(theta) * Library.Flags.kb_range or 20,
											0,
											math.sin(theta) * Library.Flags.kb_range or 20
										)
										local worldPoint = center + offset
										local screenPos, onScreen =
											workspace.CurrentCamera:WorldToViewportPoint(worldPoint)
										points[i + 1] = Vector2.new(screenPos.X, screenPos.Y)
									end

									for i = 1, 360 do
										local line = circleLines[i]
										line.From = points[i]
										line.To = points[i % 360 + 1]
									end
								end
							end
						end)
					else
					end
				end,
			})

			knifeSec
				:createToggle({
					Text = "Visualize range",
					Flag = "kb_vis",
					Callback = function(a)
						if not nocturnal.loadcomplete then
							return
						end

						for idx, line in circleLines do
							line.Visible = a
						end
					end,
				})
				:createColorpicker({
					Text = "Range color",
					Default = Color3.fromRGB(255, 0, 0),
					Flag = "kb_rc",
					Callback = function(a)
						if not nocturnal.loadcomplete then
							return
						end

						for idx, line in circleLines do
							line.Color = a
						end
					end,
				})

			knifeSec:createSlider({ Text = "Range", Min = 1, Max = 20, Value = 20, Flag = "kb_range" })

			for i = 1, 360 do
				table.insert(
					circleLines,
					nocturnal:Draw("Line", { Color = circleColor, Thickness = 2, ZIndex = 999, Visible = false })
				)
			end
		end

		-- VISUALS TAB
		do
			local tab = window:createTab({ Text = "Visuals", Small = true })

			local espSection = tab:createSection({ Text = "ESP", Location = 1 })
			espSection:createToggle({ Text = "Enabled", Flag = "esp_enabled" })
			espSection
				:createToggle({ Text = "Boxes", Flag = "esp_boxes" })
				:createColorpicker({ Text = "Box Color", Default = Color3.fromRGB(250, 10, 20), Flag = "esp_boxcolor" })
			espSection
				:createToggle({ Text = "Box Fill", Flag = "esp_boxfill" })
				:createColorpicker({
					Text = "Fill Color",
					Default = Color3.fromRGB(255, 255, 255),
					Flag = "esp_fillcolor",
				})
			espSection:createToggle({ Text = "Health Bars", Flag = "esp_health" }):createColorpicker({
				Text = "Fill Color",
				Default = Color3.fromRGB(255, 255, 255),
				Flag = "esp_healthcolor",
			})
			espSection
				:createToggle({ Text = "Names", Flag = "esp_names" })
				:createColorpicker({
					Text = "Fill Color",
					Default = Color3.fromRGB(255, 255, 255),
					Flag = "esp_namecolor",
				})
			espSection:createToggle({ Text = "Skeleton", Flag = "esp_skeleton" }):createColorpicker({
				Text = "Fill Color",
				Default = Color3.fromRGB(255, 255, 255),
				Flag = "esp_skeletoncolor",
			})
			espSection
				:createToggle({ Text = "Distance", Flag = "esp_dist" })
				:createColorpicker({
					Text = "Fill Color",
					Default = Color3.fromRGB(255, 255, 255),
					Flag = "esp_distcolor",
				})
			espSection
				:createToggle({ Text = "Offscreen Arrows", Flag = "esp_arr" })
				:createColorpicker({
					Text = "Fill Color",
					Default = Color3.fromRGB(255, 255, 255),
					Flag = "esp_arrcolor",
				})

			espSection:createDropdown({
				Text = "Box Style",
				Options = { "2D", "3D" },
				Default = "2D",
				Flag = "esp_style",
			})

			local enemy, friendly = tab:createMultisection({
				Text = "Chams",
				Sections = { "Enemy", "Friendly" },
				Text1 = "Enemy",
				Text2 = "Friendly",
				Location = 1,
			})
			enemy
				.createToggle({ Section = 1, Text = "Enabled", Flag = "echams_enabled" })
				:createColorpicker({
					Text = "Cham Color",
					Default = Color3.fromRGB(162, 164, 189),
					Flag = "chams_ecolor",
				})
			enemy.createToggle({ Section = 1, Text = "Cham Outline", Flag = "echams_oenabled" }):createColorpicker({
				Text = "Outline Color",
				Default = Color3.fromRGB(255, 255, 255),
				Flag = "chams_eocolor",
			})
			enemy
				.createToggle({ Section = 1, Text = "Cham Visible", Flag = "echams_ovenabled" })
				:createColorpicker({
					Text = "Visible Color",
					Default = Color3.fromRGB(0, 0, 0),
					Flag = "chams_evocolor",
				})

			enemy.createToggle({ Section = 1, Text = "Cham Throughwalls", Flag = "echams_etw" })
			enemy.createSlider({
				Section = 1,
				Text = "Cham Transparency",
				Min = 0,
				Max = 1,
				Value = 0.5,
				Step = 0.1,
				Flag = "chams_ealpha",
			})
			enemy.createDropdown({
				Section = 1,
				Text = "Cham Type",
				Options = {
					"BoxHandleAdornment",
					"Materialistic",
					"Highlight",
					"Glow",
					"Laminate",
					"Wireframe",
					"LayeredGlow",
					"OutlineGlow",
				},
				Default = "BoxHandleAdornment",
				Flag = "chams_etype",
			})
			local ragdollConn

			enemy
				.createToggle({
					Section = 1,
					Text = "Ragdoll Chams",
					Flag = "rchams_enabled",
					Callback = function(enabled)
						-- disconnect previous connection
						if ragdollConn then
							ragdollConn:Disconnect()
							ragdollConn = nil
						end

						if not enabled then
							return
						end

						local holder = workspace:FindFirstChild("Ragdolls")
						if not holder then
							return
						end

						ragdollConn = holder.ChildAdded:Connect(function(child)
							if not child:IsA("Model") or child.Name == "FakeChar" or child.Name == "FakeChar2" then
								return
							end

							local chamType = Library.Flags.rchams_etype
							local chamColor = Library.Flags.rchams_ecolor

							if chamType == "Materialistic" then
								for _, part in child:GetDescendants() do
									if part:IsA("BasePart") then
										local sa = part:FindFirstChildOfClass("SurfaceAppearance")
										if sa then
											sa:Destroy()
										end
										for _, v in part:GetDescendants() do
											if v:IsA("Texture") or v:IsA("Decal") then
												v:Destroy()
											end
										end
										part.Color = chamColor
										part.Material = Enum.Material.ForceField
									end
								end
								return
							elseif chamType == "Highlight" then
								local inst = Instance.new("Highlight", child)
								inst.FillColor = chamColor
								inst.FillTransparency = 0.75
								return
							end

							for _, name in nocturnal.parts do
								local part = child:FindFirstChild(name)
								if part and part:IsA("BasePart") and part.Transparency < 1 then
									local existing = part:FindFirstChild("Chams")
									if existing then
										existing.Color3 = chamColor
										continue
									end

									if name == "Head" then
										local cyl = Instance.new("CylinderHandleAdornment")
										cyl.Name = "Chams"
										cyl.AlwaysOnTop = true
										cyl.ZIndex = (chamType == "BoxHandleAdornment" and 4 or -1)
										cyl.Adornee = part
										cyl.Color3 = chamColor
										cyl.Transparency = (chamType == "BoxHandleAdornment" and 0.1 or -9999999)
										cyl.Height = part.Size.Y + 0.3
										cyl.Radius = part.Size.X * 0.5 + 0.2
										cyl.CFrame = CFrame.new(Vector3.new(), Vector3.new(0, 1, 0))
										cyl.Parent = part
									else
										local box = Instance.new("BoxHandleAdornment")
										box.Name = "Chams"
										box.AlwaysOnTop = true
										box.ZIndex = (chamType == "BoxHandleAdornment" and 4 or -1)
										box.Adornee = part
										box.Color3 = chamColor
										box.Transparency = (chamType == "BoxHandleAdornment" and 0.1 or -99999999)
										box.Size = part.Size + Vector3.new(0.02, 0.02, 0.02)
										box.Parent = part
									end
								end
							end
						end)
					end,
				})
				:createColorpicker({
					Text = "Cham Color",
					Default = Color3.fromRGB(255, 0, 0),
					Flag = "rchams_ecolor",
				})
			enemy.createDropdown({
				Section = 1,
				Text = "Ragdoll Cham Type",
				Options = { "BoxHandleAdornment", "Materialistic", "Highlight", "Glow" },
				Default = "Neon",
				Flag = "rchams_etype",
			})

			friendly
				.createToggle({ Section = 2, Text = "Enabled", Flag = "chams_enabled" })
				:createColorpicker({ Text = "Cham Color", Default = Color3.fromRGB(85, 255, 0), Flag = "chams_fcolor" })
			friendly.createToggle({ Section = 2, Text = "Cham Outline", Flag = "chams_oenabled" }):createColorpicker({
				Text = "Outline Color",
				Default = Color3.fromRGB(255, 255, 255),
				Flag = "chams_focolor",
			})
			friendly.createToggle({ Section = 2, Text = "Cham Throughwalls", Flag = "chams_etw" })
			friendly.createSlider({
				Section = 2,
				Text = "Cham Transparency",
				Min = 0,
				Max = 1,
				Value = 0.5,
				Step = 0.1,
				Flag = "chams_falpha",
			})

			friendly.createDropdown({
				Section = 2,
				Text = "Cham Type",
				Options = { "BoxHandleAdornment", "Viewport", "Materialistic", "Highlight" },
				Default = "BoxHandleAdornment",
				Flag = "chams_ftype",
			})

			local effectsSection = tab:createSection({ Text = "World", Location = 2 })
			effectsSection:createToggle({
				Text = "No Shadows",
				Flag = "world_noshadows",
				Callback = function(a)
					lightService.GlobalShadows = a
				end,
			})
			local nosmokeConn
			effectsSection:createToggle({
				Text = "No Smoke",
				Flag = "world_nosmoke",
				Callback = function(a)
					if a then
						nosmokeConn = workspace.SmokeDebugParts.ChildAdded:Connect(function(a)
							task.wait(0.9)
							for idx, obj in a:GetDescendants() do
								if obj:IsA("ParticleEmitter") then
									obj.Enabled = false
									obj.Transparency = NumberSequence.new(1)
								end
							end
						end)
					else
						if nosmokeConn then
							nosmokeConn:Disconnect()
							nosmokeConn = nil
						end
					end
				end,
			})
			effectsSection:createToggle({ Text = "No Flash", Flag = "world_noflash" })
			effectsSection:createToggle({
				Text = "No Lights",
				Flag = "world_nolights",
				Callback = function(a)
					if a then
						for idx, light in workspace:GetDescendants() do
							if light:IsA("Light") then
								light:Destroy()
							end
						end
					end
				end,
			})
			effectsSection:createToggle({ Text = "Brightness", Flag = "world_brightness" })
			effectsSection:createSlider({
				Text = "Brightness Amount",
				Min = 0,
				Max = 100,
				Value = 10,
				Flag = "world_brightness_amount",
			})
			effectsSection:createSeperator({})
			local smokeConn = nil
			effectsSection
				:createToggle({
					Text = "Smoke Color",
					Flag = "world_csc",
					Callback = function(a)
						if a then
							smokeConn = workspace.SmokeDebugParts.ChildAdded:Connect(function(a)
								task.wait(0.5)
								if Library.Flags.world_nosmoke then
									return
								end
								for idx, obj in a:GetDescendants() do
									if obj:IsA("ParticleEmitter") then
										obj.Color = ColorSequence.new(Library.Flags.world_cscolor)
										obj.Transparency = NumberSequence.new(Library.Flags.world_smoketrans)

										if Library.Flags.world_smoketype == "ForceField" then
											obj.Parent.Material = "ForceField"
											obj.Parent.Transparency = 0.5
											obj.Enabled = false
										end
									end
								end
							end)
						else
							if smokeConn then
								smokeConn:Disconnect()
								smokeConn = nil
							end
						end
					end,
				})
				:createColorpicker({ Text = "Smoke Color", Default = Color3.fromRGB(255, 0, 0), Flag = "world_cscolor" })
			effectsSection:createSlider({
				Text = "Smoke Transparency",
				Min = 0,
				Max = 0.9,
				Value = 0.3,
				Step = 0.1,
				Flag = "world_smoketrans",
			})
			effectsSection:createDropdown({
				Text = "Smoke Type",
				Options = { "Normal", "ForceField" },
				Default = "Normal",
				Flag = "world_smoketype",
			})

			local molotovConn = nil

			effectsSection:createLabel({ Text = "Molotov Color" })
			effectsSection:createToggle({
				Text = "Enabled",
				Flag = "world_cmc",
				Callback = function(e)
					if e then
						molotovConn = workspace.ReactionHolder.ChildAdded:Connect(function(a)
							task.wait(0.5)
							for idx, obj in a:GetDescendants() do
								if obj:IsA("ParticleEmitter") and obj.Name == "Fire" then
									obj.Color = ColorSequence.new(Library.Flags.world_pmc1)
								end

								if obj:IsA("ParticleEmitter") and obj.Name == "Fire4" then
									obj.Color = ColorSequence.new({
										ColorSequenceKeypoint.new(0, Library.Flags.world_pmc1),
										ColorSequenceKeypoint.new(1, Library.Flags.world_pmc1),
									})
								end

								if obj:IsA("ParticleEmitter") and obj.Name == "FireCore" then
									obj.Color = ColorSequence.new(Library.Flags.world_smc)
								end

								if obj:IsA("ParticleEmitter") and obj.Name == "Glow" then
									obj.Color = ColorSequence.new(Library.Flags.world_pmc1)
								end
							end
						end)
					else
						if molotovConn then
							molotovConn:Disconnect()
							molotovConn = nil
						end
					end
				end,
			})
			effectsSection
				:createToggle({ Text = "Primary", Flag = "world_pmc" })
				:createColorpicker({
					Text = "Primary Color",
					Default = Color3.fromRGB(255, 170, 0),
					Flag = "world_pmc1",
				})
			effectsSection
				:createToggle({ Text = "Secondary", Flag = "world_smc" })
				:createColorpicker({
					Text = "Secondary Color",
					Default = Color3.fromRGB(185, 124, 255),
					Flag = "world_smc",
				})
			effectsSection:createSeperator({})

			effectsSection:createToggle({ Text = "Custom skybox", Flag = "world_skybox" })
			effectsSection:createToggle({
				Text = "Custom weather",
				Flag = "world_weather",
				Callback = function(a)
					if a then
						WeatherPart.Parent = workspace
					else
						WeatherPart.Parent = Services.CoreGui
					end
				end,
			})

			local skyValues: { string } = {}
			table.insert(skyValues, "None")

			for idx, sky in nocturnal.skies do
				table.insert(skyValues, idx)
			end

			effectsSection:createDropdown({
				Text = "Skybox",
				Options = skyValues,
				Default = "None",
				Flag = "world_skyboxcustom",
				Callback = function(a)
					if not a then
						return
					end
					if a == "None" then
						return
					end
					lightService:FindFirstChildOfClass("Sky"):Destroy()
					local skybox = Instance.new("Sky", Services.Lighting)
					skybox.SkyboxLf = nocturnal.skies[a].SkyboxLf
					skybox.SkyboxBk = nocturnal.skies[a].SkyboxBk
					skybox.SkyboxDn = nocturnal.skies[a].SkyboxDn
					skybox.SkyboxFt = nocturnal.skies[a].SkyboxFt
					skybox.SkyboxRt = nocturnal.skies[a].SkyboxRt
					skybox.SkyboxUp = nocturnal.skies[a].SkyboxUp
					skybox.Name = "skeibocks"
				end,
			})

			effectsSection:createDropdown({
				Text = "Weather",
				Options = { "Snow", "Rain" },
				Default = "Snow",
				Flag = "world_weatherstate",
				Callback = function(a)
					for idx, emitter in WeatherPart:GetChildren() do
						emitter.Enabled = rawequal(emitter.Name, a)
					end
				end,
			})

			effectsSection:createSeperator({})

			local mapFolder = workspace:WaitForChild("Map")
			local defaultLighting = {}

			-- Restore lighting from ref worrkspace.Map.LightingSettings
			local function Restore()
				local map = workspace:FindFirstChild("Map")
				if not map then
					return
				end

				local ls = map:FindFirstChild("LightingSettings")
				if not ls then
					return
				end

				local addFolder = ls:FindFirstChild("Add")
				local propsFolder = ls:FindFirstChild("Properties")

				lightService:ClearAllChildren()

				if addFolder then
					for _, instanceTemplate in addFolder:GetChildren() do
						local existing = lightService:FindFirstChild(instanceTemplate.Name)
						if existing then
							existing:Destroy()
						end
						-- clone the template into Lighting
						local cloned = instanceTemplate:Clone()
						cloned.Parent = lightService
					end
				end

				if propsFolder then
					for _, valueObj in propsFolder:GetChildren() do
						local propName = valueObj.Name

						-- computezzzzzzz
						local ok, writeErr
						if
							valueObj:IsA("Color3Value")
							or valueObj:IsA("NumberValue")
							or valueObj:IsA("BoolValue")
							or valueObj:IsA("Vector3Value")
							or valueObj:IsA("StringValue")
						then
							local val = valueObj.Value
							ok, writeErr = pcall(function()
								lightService[propName] = val
							end)

							if not ok then
								warn(
									("Restore: failed to set Lighting.%s from %s (%s)"):format(
										propName,
										valueObj.ClassName,
										tostring(writeErr)
									)
								)
							end
						else
							if rawget(valueObj, "Value") ~= nil then
								local val = valueObj.Value
								ok, writeErr = pcall(function()
									lightService[propName] = val
								end)
								if not ok then
									warn(
										("reestore: unsupported value type for %s, failed to set Lighting.%s"):format(
											valueObj.Name,
											propName
										)
									)
								end
							else
								continue
							end
						end
					end
				end
			end

			local function GetOrCreateNamedEffect(name, className)
				local existing = lightService:FindFirstChild(name)
				if existing then
					if existing.ClassName ~= className then
						existing:Destroy()
					else
						return existing
					end
				end
				local inst = Instance.new(className)
				inst.Name = name
				inst.Parent = lightService
				return inst
			end

			local function RemoveNamedEffect(name)
				local inst = lightService:FindFirstChild(name)
				if inst then
					inst:Destroy()
				end
			end

			task.spawn(function()
				local lastMaster = nil
				while task.wait() do
					local masterOn = Library.Flags.world_amb == true

					if lastMaster == nil then
						lastMaster = masterOn
					elseif lastMaster and not masterOn then
						-- master was on, now turned off
						Restore()
					end

					lastMaster = masterOn

					if not masterOn then
						-- if master toggle is off, skip applying values
						continue
					end

					if Library.Flags.world_ambc ~= nil then
						lightService.Ambient = Library.Flags.world_ambc
					end
					if Library.Flags.world_csbc ~= nil then
						lightService.ColorShift_Bottom = Library.Flags.world_csbc
					end
					if Library.Flags.world_cstc ~= nil then
						lightService.ColorShift_Top = Library.Flags.world_cstc
					end

					if Library.Flags.world_eds ~= nil then
						lightService.EnvironmentDiffuseScale = Library.Flags.world_eds
					end
					if Library.Flags.world_ess ~= nil then
						lightService.EnvironmentSpecularScale = Library.Flags.world_ess
					end
					if Library.Flags.world_brightness2 ~= nil then
						lightService.Brightness = Library.Flags.world_brightness2
					end
					if Library.Flags.world_ct ~= nil then
						lightService.ClockTime = Library.Flags.world_ct
					end

					-- ---------- Bloom ----------
					if Library.Flags.world_bloom ~= nil and Library.Flags.world_bloom == true then
						local b = GetOrCreateNamedEffect("nBloom", "BloomEffect")
						-- Enabled
						b.Enabled = true
						if Library.Flags.world_bi ~= nil then
							b.Intensity = Library.Flags.world_bi
						end
						if Library.Flags.world_bs ~= nil then
							b.Size = Library.Flags.world_bs
						end
						if Library.Flags.world_bt ~= nil then
							b.Threshold = Library.Flags.world_bt
						end
					else
						-- If bloom flag is false/nil, disable or remove the effect
						local b = lightService:FindFirstChild("nBloom")
						if b then
							-- prefer disabling rather than destroying if you expect to toggle on/off frequently
							b.Enabled = false
						end
					end

					-- ---------- SunRays ----------
					if Library.Flags.world_sr ~= nil and Library.Flags.world_sr == true then
						local s = GetOrCreateNamedEffect("nSunRays", "SunRaysEffect")
						s.Enabled = true
						if Library.Flags.world_sri ~= nil then
							s.Intensity = Library.Flags.world_sri
						end
						if Library.Flags.world_srs ~= nil then
							s.Spread = Library.Flags.world_srs
						end
					else
						local s = lightService:FindFirstChild("nSunRays")
						if s then
							s.Enabled = false
						end
					end

					-- ---------- ColorCorrection ----------
					if Library.Flags.world_cc ~= nil and Library.Flags.world_cc == true then
						local c = GetOrCreateNamedEffect("nColorCorrection", "ColorCorrectionEffect")
						c.Enabled = true
						if Library.Flags.world_ccc ~= nil then
							c.TintColor = Library.Flags.world_ccc
						end
						if Library.Flags.world_ccs ~= nil then
							c.Saturation = Library.Flags.world_ccs
						end
						if Library.Flags.world_cccont ~= nil then
							c.Contrast = Library.Flags.world_cccont
						end
						if Library.Flags.world_ccb ~= nil then
							c.Brightness = Library.Flags.world_ccb
						end
					else
						local c = lightService:FindFirstChild("nColorCorrection")
						if c then
							c.Enabled = false
						end
					end

					if Library.Flags.world_fog then
						local c = GetOrCreateNamedEffect("nAtmo", "Atmosphere")
						if Library.Flags.world_fogdecayc ~= nil then
							c.Decay = Library.Flags.world_fogdecayc
						end
						if Library.Flags.world_fogc ~= nil then
							c.Color = Library.Flags.world_fogc
						end
						if Library.Flags.world_fogstart ~= nil then
							c.Glare = Library.Flags.world_fogstart
						end
						if Library.Flags.world_fogend ~= nil then
							c.Haze = Library.Flags.world_fogend
						end
						if Library.Flags.world_fogdensity ~= nil then
							c.Density = Library.Flags.world_fogdensity
						end
					end

					if Library.Flags.world_clouds then
						local terrain = workspace.Terrain

						local clouds = nil
						for _, c in terrain:GetChildren() do
							if c:IsA("Clouds") then
								if not clouds then
									clouds = c
								else
									c:Destroy()
								end
							end
						end

						if not clouds then
							clouds = Instance.new("Clouds")
							clouds.Parent = terrain
						end

						clouds.Enabled = true
						if Library.Flags.world_cloudscover ~= nil then
							clouds.Cover = Library.Flags.world_cloudscover
						end
						if Library.Flags.world_cloudc ~= nil then
							clouds.Color = Library.Flags.world_cloudc
						end
						if Library.Flags.world_cloudsdensity ~= nil then
							clouds.Density = Library.Flags.world_cloudsdensity
						end
					end
				end
			end)

			local function Effect() end

			local function SaveCurrentLighting() end

			local function MasterOK()
				return false
			end

			effectsSection
				:createToggle({
					Text = "Ambience",
					Flag = "world_amb",
					Callback = function(a) end,
				})
				:createColorpicker({
					Text = "Ambient Color",
					Flag = "world_ambc",
					Default = Color3.fromRGB(0, 0, 0),
					Callback = function(col)
						if MasterOK() then
							lightService.Ambient = col
							SaveCurrentLighting()
						end
					end,
				})

			-- Colorshift Bottom
			effectsSection:createToggle({ Text = "Colorshift Bottom", Flag = "world_csb" }):createColorpicker({
				Text = "Bottom Color",
				Flag = "world_csbc",
				Default = Color3.new(0, 0, 0),
				Callback = function(col)
					if MasterOK() then
						lightService.ColorShift_Bottom = col
						SaveCurrentLighting()
					end
				end,
			})

			-- Colorshift Top
			effectsSection:createToggle({ Text = "Colorshift Top", Flag = "world_cst" }):createColorpicker({
				Text = "Top Color",
				Flag = "world_cstc",
				Default = Color3.new(0, 0, 0),
				Callback = function(col)
					if MasterOK() then
						lightService.ColorShift_Top = col
						SaveCurrentLighting()
					end
				end,
			})

			-- Environment Diffuse
			effectsSection:createSlider({
				Text = "Environment Diffuse",
				Min = 0,
				Max = 1,
				Value = 0.35,
				Step = 0.1,
				Flag = "world_eds",
				Callback = function(v)
					if MasterOK() then
						lightService.EnvironmentDiffuseScale = v
						SaveCurrentLighting()
					end
				end,
			})

			-- Environment Specular
			effectsSection:createSlider({
				Text = "Environment Specular",
				Min = 0,
				Max = 1,
				Value = 1,
				Step = 0.1,
				Flag = "world_ess",
				Callback = function(v)
					if MasterOK() then
						lightService.EnvironmentSpecularScale = v
						SaveCurrentLighting()
					end
				end,
			})

			-- Brightness
			effectsSection:createSlider({
				Text = "Brightness",
				Min = 0,
				Max = 10,
				Value = 3,
				Flag = "world_brightness2",
				Callback = function(v)
					if MasterOK() then
						lightService.Brightness = v
						SaveCurrentLighting()
					end
				end,
			})

			-- Clock Time
			effectsSection:createSlider({
				Text = "Clock time",
				Min = 0,
				Max = 24,
				Value = 13,
				Step = 0.1,
				Flag = "world_ct",
				Callback = function(v)
					if MasterOK() then
						lightService.ClockTime = v
						SaveCurrentLighting()
					end
				end,
			})

			effectsSection:createToggle({ Text = "Bloom", Flag = "world_bloom" })
			effectsSection:createSlider({
				Text = "Bloom Intensity",
				Min = 0,
				Max = 10,
				Value = 4,
				Flag = "world_bi",
				Callback = function(v) end,
			})
			effectsSection:createSlider({
				Text = "Bloom Size",
				Min = 0,
				Max = 50,
				Value = 15,
				Flag = "world_bs",
				Callback = function(v) end,
			})
			effectsSection:createSlider({
				Text = "Bloom Threshold",
				Min = 0,
				Max = 1,
				Value = 0.15,
				Step = 0.01,
				Flag = "world_bt",
				Callback = function(v) end,
			})

			effectsSection:createToggle({ Text = "Sun Rays", Flag = "world_sr" })
			effectsSection:createSlider({
				Text = "Intensity",
				Min = 0,
				Max = 1,
				Value = 0.01,
				Step = 0.01,
				Flag = "world_sri",
				Callback = function(v) end,
			})
			effectsSection:createSlider({
				Text = "Spread",
				Min = 0,
				Max = 1,
				Value = 0.1,
				Step = 0.1,
				Flag = "world_srs",
				Callback = function(v) end,
			})

			effectsSection:createToggle({ Text = "Color correction", Flag = "world_cc" }):createColorpicker({
				Text = "Correction Color",
				Default = Color3.fromRGB(255, 85, 255),
				Flag = "world_ccc",
				Callback = function(col) end,
			})
			effectsSection:createSlider({
				Text = "Saturation",
				Min = 0,
				Max = 1,
				Value = 0,
				Step = 0.1,
				Flag = "world_ccs",
				Callback = function(v) end,
			})
			effectsSection:createSlider({
				Text = "Contrast",
				Min = 0,
				Max = 1,
				Value = 0,
				Step = 0.1,
				Flag = "world_cccont",
				Callback = function(v) end,
			})
			effectsSection:createSlider({
				Text = "Brightness",
				Min = 0,
				Max = 1,
				Value = 0,
				Step = 0.1,
				Flag = "world_ccb",
				Callback = function(v) end,
			})
			effectsSection:createSeperator({})
			effectsSection:createToggle({ Text = "Fog", Flag = "world_fog" }):createColorpicker({
				Text = "Fog Color",
				Default = Color3.fromRGB(255, 85, 255),
				Flag = "world_fogc",
				Callback = function(col) end,
			})
			effectsSection:createToggle({ Text = "Decay", Flag = "world_fogdecay" }):createColorpicker({
				Text = "Decay Color",
				Default = Color3.fromRGB(255, 85, 255),
				Flag = "world_fogdecayc",
				Callback = function(col) end,
			})
			effectsSection:createSlider({
				Text = "Glare",
				Min = 0,
				Max = 5,
				Value = 0,
				Step = 0.1,
				Flag = "world_fogstart",
				Callback = function(v) end,
			})
			effectsSection:createSlider({
				Text = "Haze",
				Min = 0,
				Max = 5,
				Value = 0,
				Step = 0.1,
				Flag = "world_fogend",
				Callback = function(v) end,
			})
			effectsSection:createSlider({
				Text = "Density",
				Min = 0,
				Max = 1,
				Value = 0,
				Step = 0.1,
				Flag = "world_fogdensity",
				Callback = function(v) end,
			})
			effectsSection:createSeperator({})
			effectsSection:createToggle({ Text = "Clouds", Flag = "world_clouds" }):createColorpicker({
				Text = "Cloud Color",
				Default = Color3.new(0.262745, 0.262745, 0.262745),
				Flag = "world_cloudc",
				Callback = function(col) end,
			})
			effectsSection:createSlider({
				Text = "Density",
				Min = 0,
				Max = 1,
				Value = 1,
				Step = 0.1,
				Flag = "world_cloudsdensity",
				Callback = function(v) end,
			})
			effectsSection:createSlider({
				Text = "Cover",
				Min = 0,
				Max = 1,
				Value = 0.625,
				Step = 0.1,
				Flag = "world_cloudscover",
				Callback = function(v) end,
			})

			local vmSection = tab:createSection({ Text = "Viewmodel", Location = 2 })
			local gChamConnection
			local sChamConnection
			vmSection
				:createToggle({
					Text = "Gun Chams",
					Flag = "vm_gc",
					Callback = function(a)
						if a then
							gChamConnection = workspace.CurrentCamera.ChildAdded:Connect(function(c)
								if c:IsA("Model") then
									for idx, part in c:GetDescendants() do
										if part:IsA("MeshPart") then
											local partname = string.lower(part.Name)
											if
												partname:find("glove")
												or partname:find("arm")
												or partname:find("sleeve")
												or partname:find("joint")
											then
												continue
											else
												if part:FindFirstChildOfClass("SurfaceAppearance") then
													part:FindFirstChildOfClass("SurfaceAppearance"):Destroy()
												end

												part.TextureID = ""
												part.Material = Enum.Material.Neon
												part.Color = Library.Flags.vm_gcc or Color3.fromRGB(0, 170, 255)
												part.Reflectance = Library.Flags.vm_gcr / 10

												if Library.Flags.vm_gct == "Pulse" then
													local LEG_TIME = 1
													local EASING_STYLE = Enum.EasingStyle.Linear
													local EASING_DIR = Enum.EasingDirection.InOut

													local function startPulse(part)
														local toOpaque = tweenService:Create(
															part,
															TweenInfo.new(LEG_TIME, EASING_STYLE, EASING_DIR),
															{ Transparency = 0 }
														)
														local toFaded = tweenService:Create(
															part,
															TweenInfo.new(LEG_TIME, EASING_STYLE, EASING_DIR),
															{ Transparency = 0.9 }
														)

														task.spawn(function()
															while part and part.Parent do
																toOpaque:Play()
																toOpaque.Completed:Wait()
																toFaded:Play()
																toFaded.Completed:Wait()
																task.wait(0.5)
															end
														end)
													end
													startPulse(part)
												elseif Library.Flags.vm_gct == "Tween" then
													local function tweenColor(part)
														task.spawn(function()
															while part and part.Parent do
																local tweenInfo = TweenInfo.new(
																	1.3,
																	Enum.EasingStyle["Quart"],
																	Enum.EasingDirection.InOut
																)
																local tween = tweenService:Create(
																	part,
																	tweenInfo,
																	{ Color = Color3.fromRGB(255, 255, 255) }
																)
																tween:Play()
																tween.Completed:Wait()

																local tween2 = tweenService:Create(
																	part,
																	tweenInfo,
																	{ Color = Library.Flags.vm_gcc }
																)
																tween2:Play()
																tween2.Completed:Wait()
															end
														end)
													end

													part.Material = "ForceField"
													tweenColor(part)
												elseif Library.Flags.vm_gct == "ForceField" then
													part.Material = "ForceField"
												elseif Library.Flags.vm_gct == "Flat" then
													part.Material = "Neon"
												elseif Library.Flags.vm_gct == "Glass" then
													part.Material = "Glass"
													part.Transparency = 0.55
												elseif Library.Flags.vm_gct == "Smooth" then
													part.Material = "SmoothPlastic"
												elseif Library.Flags.vm_gct == "ForceOverlay" then
													part.Material = "Plastic"
													part.Reflectance = 999999
												end

												part.TextureID = nocturnal.textures[Library.Flags.vm_gctex]
											end
										end
									end
								end
							end)

							table.insert(nocturnal.connections, gChamConnection)
						else
							if gChamConnection then
								gChamConnection:Disconnect()
								gChamConnection = nil
							end
						end
					end,
				})
				:createColorpicker({ Text = "Gun Color", Default = Color3.fromRGB(71, 184, 255), Flag = "vm_gcc" })
			vmSection:createDropdown({
				Text = "Gun Cham Type",
				Options = { "Pulse", "ForceField", "Flat", "Glass", "Tween", "Smooth", "ForceOverlay" },
				Default = "Pulse",
				Flag = "vm_gct",
			})
			vmSection:createSlider({
				Text = "Gun Reflectance",
				Min = 0,
				Max = 1,
				Value = 0,
				Step = 0.1,
				Flag = "vm_gcr",
			})
			vmSection
				:createToggle({
					Text = "Sleeve Chams",
					Flag = "vm_sc",
					Callback = function(a)
						if a then
							sChamConnection = workspace.CurrentCamera.ChildAdded:Connect(function(c)
								if c:IsA("Model") then
									for idx, child in c:GetDescendants() do
										if
											string.find(child.Name:lower(), "glove")
											or string.find(child.Name:lower(), "sleeve")
										then
											if child:FindFirstChildOfClass("SurfaceAppearance") then
												child:FindFirstChildOfClass("SurfaceAppearance"):Destroy()
											end

											child.Parent.Transparency = 1
											child.Material = Enum.Material.Neon
											child.Color = Library.Flags.vm_scc

											if Library.Flags.vm_sct == "Pulse" then
												child.TextureID = ""
												local LEG_TIME = 1
												local EASING_STYLE = Enum.EasingStyle.Linear
												local EASING_DIR = Enum.EasingDirection.InOut

												local function startPulse(part)
													local toOpaque = tweenService:Create(
														part,
														TweenInfo.new(LEG_TIME, EASING_STYLE, EASING_DIR),
														{ Transparency = 0 }
													)
													local toFaded = tweenService:Create(
														part,
														TweenInfo.new(LEG_TIME, EASING_STYLE, EASING_DIR),
														{ Transparency = 0.9 }
													)

													task.spawn(function()
														while part and part.Parent do
															toOpaque:Play()
															toOpaque.Completed:Wait()
															toFaded:Play()
															toFaded.Completed:Wait()
															task.wait(0.5)
														end
													end)
												end
												startPulse(child)
											elseif Library.Flags.vm_sct == "ForceField" then
												child.Material = "ForceField"
											elseif Library.Flags.vm_sct == "Flat" then
												child.Material = "Neon"
												child.Transparency = 0.55
												child.TextureID = ""
											elseif Library.Flags.vm_sct == "Tween" then
												local function tweenColor(part)
													task.spawn(function()
														while part and part.Parent do
															local tweenInfo = TweenInfo.new(
																1.3,
																Enum.EasingStyle["Quart"],
																Enum.EasingDirection.InOut
															)
															local tween = tweenService:Create(
																part,
																tweenInfo,
																{ Color = Color3.fromRGB(255, 255, 255) }
															)
															tween:Play()
															tween.Completed:Wait()

															local tween2 = tweenService:Create(
																part,
																tweenInfo,
																{ Color = Library.Flags.vm_scc }
															)
															tween2:Play()
															tween2.Completed:Wait()
														end
													end)
												end

												child.Material = "ForceField"
												tweenColor(child)
											elseif Library.Flags.vm_sct == "Glass" then
												child.Material = "Glass"
												child.Transparency = 0.55
												child.TextureID = ""
											elseif Library.Flags.vm_sct == "Remove" then
												child.Transparency = 1
											end

											child.TextureID = nocturnal.textures[Library.Flags.vm_sctex]
										end
									end
								end
							end)

							table.insert(nocturnal.connections, sChamConnection)
						else
							if sChamConnection then
								sChamConnection:Disconnect()
								sChamConnection = nil
							end
						end
					end,
				})
				:createColorpicker({ Text = "Sleeve Color", Default = Color3.fromRGB(71, 184, 255), Flag = "vm_scc" })
			vmSection:createDropdown({
				Text = "Sleeve Cham Type",
				Options = { "ForceField", "Pulse", "Flat", "Glass", "Tween", "Remove" },
				Default = "Pulse",
				Flag = "vm_sct",
			})
			vmSection:createDropdown({
				Text = "Gun Forcefield texture",
				Options = { "None", "Hex", "Stars" },
				Default = "None",
				Flag = "vm_gctex",
			})
			vmSection:createDropdown({
				Text = "Sleeve Forcefield texture",
				Options = { "None", "Hex", "Stars" },
				Default = "None",
				Flag = "vm_sctex",
			})
			vmSection:createSeperator({})
			vmSection:createToggle({ Text = "Enabled", Flag = "vm_enabledchanger" })
			vmSection:createSlider({ Text = "Viewmodel X", Min = -10, Max = 10, Value = 0, Step = 0.1, Flag = "vm_x" })
			vmSection:createSlider({ Text = "Viewmodel Y", Min = -10, Max = 10, Value = 0, Step = 0.1, Flag = "vm_y" })
			vmSection:createSlider({ Text = "Viewmodel Z", Min = -10, Max = 10, Value = 0, Step = 0.1, Flag = "vm_z" })

			local tracersSection = tab:createSection({ Text = "Tracers", Location = 2 })
			tracersSection
				:createToggle({ Text = "Bullet Tracers", Flag = "t_bt" })
				:createColorpicker({ Text = "Tracer Color", Default = Color3.fromRGB(255, 255, 255), Flag = "t_btc" })
			tracersSection:createTextbox({ Text = "Texture", Default = "rbxassetid://446111271", Flag = "t_btt" })
			tracersSection
				:createToggle({ Text = "Hitmarkers", Flag = "t_hm" })
				:createColorpicker({ Text = "Hitmarker Color", Default = Color3.fromRGB(255, 255, 255), Flag = "t_hmc" })
			tracersSection:createDropdown({
				Text = "Hitmarker Type",
				Options = { "Part", "Character" },
				Default = "Part",
				Flag = "t_hmm",
			})

			--> Self
			local savedData = {}
			local charConn

			local function isVisualPart(inst)
				return inst:IsA("BasePart") or inst:IsA("MeshPart") or inst:IsA("UnionOperation")
			end

			local function saveAndStripPart(part)
				if not part or not part.Parent or savedData[part] then
					return
				end
				-- recordinkz
				local entry = {
					props = {
						Material = part.Material,
						Color = part.Color,
						Transparency = part.Transparency,
						BrickColor = part.BrickColor,
						Reflectance = part.Reflectance,
						Size = part.Size,
						-- we do NOT store CFrame because we shouldn't move parts
					},
					clonedChildren = {}, -- clones of decals/meshes/surfaceappearance
				}
				-- clone & remove visual children we want to restore later
				for _, child in part:GetChildren() do
					if child:IsA("SurfaceAppearance") or child:IsA("Decal") or child:IsA("Texture") then
						local ok, clone = pcall(function()
							return child:Clone()
						end)
						if ok and clone then
							entry.clonedChildren[#entry.clonedChildren + 1] = clone
						end
						pcall(function()
							child:Destroy()
						end)
					end
				end

				savedData[part] = entry
			end

			local function applyChamsToPart(part, color)
				if not part then
					return
				end
				if part.Name == "HumanoidRootPart" then
					return
				end
				pcall(function()
					part.Material = Enum.Material.ForceField
					part.Color = color
					part.Transparency = 0
				end)
			end

			-- restore saved visuals for a part
			local function restorePart(part)
				local entry = savedData[part]
				if not entry then
					return
				end
				pcall(function()
					local p = part
					local props = entry.props
					if props then
						if props.Material then
							p.Material = props.Material
						end
						if props.Color then
							p.Color = props.Color
						end
						if props.Transparency then
							p.Transparency = props.Transparency
						end
						if props.BrickColor then
							p.BrickColor = props.BrickColor
						end
						if props.Reflectance then
							p.Reflectance = props.Reflectance
						end
						if props.Size then
							p.Size = props.Size
						end
					end
					-- reparent cloned children back onto the part
					for _, clone in entry.clonedChildren do
						-- clones were created earlier and not parented soo parent them back
						if clone and not clone.Parent then
							clone.Parent = p
						end
					end
				end)
				-- forget saved state for that part
				savedData[part] = nil
			end

			-- Apply ts
			local function applyChamsToCharacter(character, color)
				if not character then
					return
				end
				for _, desc in character:GetDescendants() do
					if isVisualPart(desc) then
						saveAndStripPart(desc)
						applyChamsToPart(desc, color)
					end
				end
			end

			local function restoreCharacterVisuals(character)
				if not character then
					return
				end
				for part, _ in savedData do
					if part and part.Parent then
						restorePart(part)
					else
						-- just drop it from savedData atp
						savedData[part] = nil
					end
				end
			end

			local function setSelfChams(enabled, color)
				local char = playerService.LocalPlayer.Character
				if enabled then
					savedData = {}
					if char then
						applyChamsToCharacter(char, color)
					end
					if charConn then
						charConn:Disconnect()
						charConn = nil
					end
					charConn = playerService.LocalPlayer.CharacterAdded:Connect(function(c)
						task.wait(1)
						applyChamsToCharacter(c, color)
					end)
				else
					if char then
						restoreCharacterVisuals(char)
					end
					if charConn then
						charConn:Disconnect()
						charConn = nil
					end
					-- clear saved table
					savedData = {}
				end
			end

			local selfSection = tab:createSection({ Text = "Self", Location = 1 })
			selfSection
				:createToggle({
					Text = "Self Chams",
					Flag = "l_sc",
					Callback = function(a)
						setSelfChams(a, Library.Flags.l_scc)
					end,
				})
				:createColorpicker({ Text = "Cham Color", Default = Color3.fromRGB(255, 255, 255), Flag = "l_scc" })
			selfSection:createDropdown({
				Text = "Self Cham Type",
				Options = { "ForceField", "Glass" },
				Default = "Forcefield",
				Flag = "l_sct",
			})
			selfSection:createSeperator({})
			local jumpConn
			selfSection
				:createToggle({
					Text = "Jump Circle",
					Flag = "l_jc",
					Callback = function(a)
						if a then
							jumpConn = nocturnal.bindables.jump[1].Event:Connect(function()
								local emitter = nocturnal.jumpcircle:Clone()
								emitter.Parent = workspace.Ragdolls
								emitter.CFrame = playerService.LocalPlayer.Character.PrimaryPart.CFrame
									- Vector3.new(0, 3, 0)
								emitter.ParticleEmitter.Color = ColorSequence.new(Library.Flags.l_jcc)
								emitter.ParticleEmitter:Emit(1)
								task.delay(emitter.ParticleEmitter.Lifetime.Max, function()
									emitter:Destroy()
								end)
							end)
						else
							if jumpConn then
								jumpConn:Disconnect()
								jumpConn = nil
							end
						end
					end,
				})
				:createColorpicker({ Text = "Circle Color", Default = Color3.fromRGB(255, 255, 255), Flag = "l_jcc" })

			local hatConn
			local Triangles: { any } = {}

			for i = 1, 30 do
				Triangles[i] = nocturnal:Draw("Triangle", {
					Visible = false,
					Filled = true,
					ZIndex = 1,
				})
			end

			local Camera = workspace.CurrentCamera
			selfSection
				:createToggle({
					Text = "China Hat",
					Flag = "l_chinahat",
					Callback = function(a)
						if a then
							for _, triangle in Triangles do
								triangle.Visible = true
							end

							hatConn = runService.RenderStepped:Connect(function()
								if not nocturnal:isAlive(playerService.LocalPlayer) then
									return
								end
								local Head: BasePart? =
									playerService.LocalPlayer.Character:FindFirstChild("Head") :: BasePart?
								if not Head then
									return
								end

								local Position: Vector3 = Head.Position
								local TopScreen: Vector3 =
									Camera:WorldToViewportPoint(Position + Vector3.new(0, 1.5, 0))

								for i = 1, 30 do
									local LastAngle: number = (i / 30) * math.pi * 2.3
									local NextAngle: number = ((i + 1) / 30) * math.pi * 2.3

									local LastPos = Position
										+ Vector3.new(math.cos(LastAngle), 0, math.sin(LastAngle)) * 1.5
									local NextPos = Position
										+ Vector3.new(math.cos(NextAngle), 0, math.sin(NextAngle)) * 1.5

									local LastScreen = Camera:WorldToViewportPoint(LastPos)
									local NextScreen = Camera:WorldToViewportPoint(NextPos)

									local Triangle: any = Triangles[i]

									Triangle.PointA = Vector2.new(TopScreen.X, TopScreen.Y)
									Triangle.PointB = Vector2.new(LastScreen.X, LastScreen.Y)
									Triangle.PointC = Vector2.new(NextScreen.X, NextScreen.Y)
									Triangle.Color = Library.Flags.l_chcolor2 == Color3.fromRGB(255, 255, 254)
											and Color3.fromHSV((tick() % 5 / 5 - (i / #Triangles)) % 1, 0.5, 1)
										or Library.Flags.l_chcolor2
									Triangle.Transparency = nocturnal:Transparency(0.5)
									Triangle.Visible = true
								end
							end)
						else
							if hatConn then
								hatConn:Disconnect()
								hatConn = nil

								for _, triangle in Triangles do
									triangle.Visible = false
								end
							end
						end
					end,
				})
				:createColorpicker({ Text = "Hat Color", Default = Color3.fromRGB(255, 255, 254), Flag = "l_chcolor2" })

			local motor
			local part

			local function motorZ(char: Character): () -> Instance
				task.spawn(function()
					if motor then
						motor:Destroy()
					end

					if not part then
						return
					end
					if not char:FindFirstChild("UpperTorso") then
						return
					end

					part.Parent = workspace.CurrentCamera
					motor = Instance.new("Motor6D")
					motor.MaxVelocity = 0.1
					motor.Part0 = part
					motor.Part1 = char:FindFirstChild("UpperTorso")
					motor.C0 = CFrame.new(0, 2, 0) * CFrame.Angles(0, math.rad(-90), 0)
					motor.C1 = CFrame.new(0, motor.Part1.Size.Y / 2, 0.45) * CFrame.Angles(0, math.rad(90), 0)
					motor.Parent = part
				end)
			end

			-- thanks moerii for this
			local capeConn
			selfSection:createToggle({
				Text = "Cape",
				Flag = "s_cape",
				Callback = function(a)
					if a then
						part = Instance.new("Part")
						part.Size = Vector3.new(2, 4, 0.1)
						part.CanCollide = false
						part.CanQuery = false
						part.Massless = true
						part.Transparency = 0
						part.Material = Enum.Material.Neon
						part.Color = Color3.fromRGB(123, 79, 144)
						part.CastShadow = false
						part.Parent = workspace.CurrentCamera

						local capesurface = Instance.new("SurfaceGui")
						capesurface.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
						capesurface.Adornee = part
						capesurface.Parent = part

						local decal = Instance.new("ImageLabel")
						decal.Image = "http://www.roblox.com/asset/?id=105309005544103"
						decal.Size = UDim2.fromScale(1, 1)
						decal.BackgroundTransparency = 1
						decal.Parent = capesurface

						if nocturnal:isAlive(playerService.LocalPlayer) then
							motorZ(playerService.LocalPlayer.Character)
						end

						task.spawn(function()
							repeat
								if motor and nocturnal:isAlive(playerService.LocalPlayer) then
									local v = replicatedStorage.MovementBindables.getVelocity:Invoke()
									local velo = math.min(v.Magnitude, 90)
									motor.DesiredAngle = math.rad(6)
										+ math.rad(velo)
										+ (velo > 1 and math.abs(math.cos(tick() * 5)) / 3 or 0)
								end

								task.wait()
							until not Library.Flags.s_cape
						end)

						capeConn = playerService.LocalPlayer.CharacterAdded:Connect(function(c)
							task.delay(1, function()
								motorZ(c)
							end)
						end)
					else
						part = nil
						motor = nil
						if capeConn then
							capeConn:Disconnect()
							capeConn = nil
						end
					end
				end,
			})

			local camera = workspace.CurrentCamera

			local oldOffsets = {} :: { [Instance]: any }
			local tpConn: RBXScriptConnection?
			local tpConn2: RBXScriptConnection?

			local function applyThirdPerson(enabled: boolean)
				local arms = camera:FindFirstChild("Arms")
				if not arms then
					return
				end

				local offset = arms:FindFirstChild("Offset")
				if not offset then
					return
				end

				if enabled then
					if oldOffsets[offset] == nil then
						oldOffsets[offset] = offset.Value
					end

					if offset:IsA("CFrameValue") then
						offset.Value = oldOffsets[offset] * CFrame.new(999, 999, 999)
					elseif offset:IsA("Vector3Value") then
						offset.Value = oldOffsets[offset] + Vector3.new(999, 999, 999)
					end
				else
					local old = oldOffsets[offset]
					if old ~= nil then
						offset.Value = old
						oldOffsets[offset] = nil
					end
				end
			end

			selfSection
				:createToggle({
					Text = "Thirdperson",
					Flag = "l_tp",
					Callback = function(enabled)
						-- cleanup
						if tpConn then
							tpConn:Disconnect()
							tpConn = nil
						end
						if tpConn2 then
							tpConn2:Disconnect()
							tpConn2 = nil
						end

						applyThirdPerson(enabled)

						if not enabled then
							return
						end

						tpConn = camera.ChildAdded:Connect(function(child)
							if child.Name == "Arms" then
								applyThirdPerson(true)
							end
						end)

						tpConn2 = camera.DescendantAdded:Connect(function(desc)
							if desc.Name == "Offset" then
								applyThirdPerson(true)
							end
						end)
					end,
				})
				:createBind({
					Flag = "s_tpb",
					Callback = function() end,
				})

			local animConn
			selfSection:createToggle({
				Text = "Disable animations",
				Flag = "l_da",
				Callback = function(enabled)
					if enabled then
						if nocturnal:isAlive(playerService.LocalPlayer) then
							for idx, element in playerService.LocalPlayer.Character:GetDescendants() do
								if element:IsA("Animator") then
									--element:Destroy()
								end

								if element.Name == "Animate" then
									element.Disabled = true
								end
							end
						end

						animConn = playerService.LocalPlayer.CharacterAdded:Connect(function(c)
							task.wait(0.5)

							for idx, element in c:GetDescendants() do
								if element:IsA("Animator") then
									--element:Destroy()
								end

								if element.Name == "Animate" then
									element.Disabled = true
								end
							end
						end)
					else
						if animConn then
							animConn:Disconnect()
							animConn = nil
						end
					end
				end,
			})

			selfSection:createSeperator({})
			local effectConnections = {}

			selfSection
				:createToggle({
					Text = "Halo Wings",
					Flag = "l_halowings",
					Callback = function(enabled)
						if enabled then
							if nocturnal:isAlive(playerService.LocalPlayer) then
								local effect = EffectsPart["HaloWings"]
								for idx, attachment in effect:GetChildren() do
									if attachment:IsA("Attachment") and attachment:FindFirstChild("Attach") then
										local c = attachment:Clone()
										c.Parent = playerService.LocalPlayer.Character[attachment.Attach.Value]

										for increment, particle in c:GetDescendants() do
											if particle:IsA("ParticleEmitter") then
												particle.Color = ColorSequence.new(Library.Flags.l_halowingscolor)
											end
										end
									end
								end
							end

							effectConnections["l_halowings"] = playerService.LocalPlayer.CharacterAdded:Connect(
								function(c)
									task.wait(0.5)

									local effect = EffectsPart["HaloWings"]
									for idx, attachment in effect:GetChildren() do
										if attachment:IsA("Attachment") and attachment:FindFirstChild("Attach") then
											attachment:Clone().Parent =
												playerService.LocalPlayer.Character[attachment.Attach.Value]
										end
									end
								end
							)
						else
							if effectConnections["l_halowings"] then
								effectConnections["l_halowings"]:Disconnect()
								effectConnections["l_halowings"] = nil
							end

							if nocturnal:isAlive(playerService.LocalPlayer) then
								for idx, att in playerService.LocalPlayer.Character:GetDescendants() do
									if att:IsA("Attachment") and att:FindFirstChild("Attach") then
										att:Destroy()
									end
								end
							end
						end
					end,
				})
				:createColorpicker({
					Text = "Wings Color",
					Default = Color3.fromRGB(255, 39, 233),
					Flag = "l_halowingscolor",
					Callback = function(a)
						if nocturnal.loadcomplete and nocturnal:isAlive(playerService.LocalPlayer) then
							for idx, att in playerService.LocalPlayer.Character:GetDescendants() do
								if att:IsA("Attachment") and att:FindFirstChild("Attach") then
									for increment, emitter in att:GetChildren() do
										if emitter:IsA("ParticleEmitter") then
											emitter.Color = ColorSequence.new(a)
										end
									end
								end
							end
						end
					end,
				})

			selfSection
				:createToggle({
					Text = "Aura Circle",
					Flag = "l_auracircle",
					Callback = function(enabled)
						if enabled then
							if nocturnal.loadcomplete and nocturnal:isAlive(playerService.LocalPlayer) then
								local effect = EffectsPart["Aura Circle"]
								for idx, attachment in effect:GetChildren() do
									if attachment:IsA("Attachment") and attachment:FindFirstChild("Attach") then
										local c = attachment:Clone()
										c.Parent = playerService.LocalPlayer.Character[attachment.Attach.Value]

										for increment, particle in c:GetDescendants() do
											if particle:IsA("ParticleEmitter") then
												particle.Color = ColorSequence.new(Library.Flags.l_auracirclecolor)
											end
										end
									end
								end
							end

							effectConnections["l_auracircle"] = playerService.LocalPlayer.CharacterAdded:Connect(
								function(c)
									task.wait(0.5)

									local effect = EffectsPart["Aura Circle"]
									for idx, attachment in effect:GetChildren() do
										if attachment:IsA("Attachment") and attachment:FindFirstChild("Attach") then
											attachment:Clone().Parent =
												playerService.LocalPlayer.Character[attachment.Attach.Value]
										end
									end
								end
							)
						else
							if effectConnections["l_auracircle"] then
								effectConnections["l_auracircle"]:Disconnect()
								effectConnections["l_auracircle"] = nil
							end

							if nocturnal:isAlive(playerService.LocalPlayer) then
								for idx, att in playerService.LocalPlayer.Character:GetDescendants() do
									if att:IsA("Attachment") and att:FindFirstChild("Attach") then
										att:Destroy()
									end
								end
							end
						end
					end,
				})
				:createColorpicker({
					Text = "Circle Color",
					Default = Color3.fromRGB(255, 39, 233),
					Flag = "l_auracirclecolor",
					Callback = function(a)
						if nocturnal.loadcomplete and nocturnal:isAlive(playerService.LocalPlayer) then
							for idx, att in playerService.LocalPlayer.Character:GetDescendants() do
								if att:IsA("Attachment") and att:FindFirstChild("Attach") then
									for increment, emitter in att:GetChildren() do
										if emitter:IsA("ParticleEmitter") then
											emitter.Color = ColorSequence.new(a)
										end
									end
								end
							end
						end
					end,
				})

			local screenSection = tab:createSection({ Text = "Screen", Location = 1 })
			local renderconn

			screenSection:createToggle({
				Text = "Remove Scope",
				Flag = "s_rs",
				Callback = function(a)
					local scope = playerService.LocalPlayer.PlayerGui.Display.Scope.Main
					if a then
						renderconn = runService.RenderStepped:Connect(function()
							local d = playerService.LocalPlayer.PlayerGui:FindFirstChild("Display")
							if d then
								local scope = playerService.LocalPlayer.PlayerGui.Display.Scope.Main
								scope.Visible = false
								scope.Parent.Outline.Visible = false
							end
						end)
					else
						if renderconn then
							renderconn:Disconnect()
							renderconn = nil
						end
					end
				end,
			})
			local fovconn

			screenSection:createToggle({
				Text = "Keep FOV",
				Flag = "s_kf",
				Callback = function(a)
					if a then
						fovconn = workspace.CurrentCamera:GetPropertyChangedSignal("FieldOfView"):Connect(function()
							workspace.CurrentCamera.FieldOfView = Library.Flags.s_fov
						end)
					else
						if fovconn then
							fovconn:Disconnect()
							fovconn = nil
						end
					end
				end,
			})
			screenSection:createSlider({
				Text = "Field of View",
				Min = 1,
				Max = 120,
				Value = 80,
				Step = 1,
				Flag = "s_fov",
				Callback = function(a)
					workspace.CurrentCamera.FieldOfView = a
				end,
			})
			screenSection:createToggle({ Text = "Aspect Ratio", Flag = "s_ar" })
			screenSection:createSlider({ Text = "Ratio", Min = 0, Max = 1, Value = 0, Step = 0.1, Flag = "s_arr" })
			screenSection:createSeperator({})
			local Camera = workspace.CurrentCamera
			local LocalPlayer = playerService.LocalPlayer

			local c = {
				nocturnal:Draw("Line", { ZIndex = 999 }),
				nocturnal:Draw("Line", { ZIndex = 999 }),
				nocturnal:Draw("Line", { ZIndex = 999 }),
				nocturnal:Draw("Line", { ZIndex = 999 }),
			}

			local currentPos = Vector2.new(0, 0)
			local rotation = 0

			local function rotatePoint(p, center, a)
				local s, cr = math.sin(a), math.cos(a)
				local dx, dy = p.X - center.X, p.Y - center.Y
				return Vector2.new(dx * cr - dy * s + center.X, dx * s + dy * cr + center.Y)
			end

			local function updateCrosshair(screenPos)
				Camera = workspace.CurrentCamera or Camera
				if not Camera then
					return
				end
				local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
				local gap = Library.Flags.s_chg or 5
				local len = Library.Flags.s_chl or 5

				if screenPos then
					currentPos = currentPos:Lerp(screenPos, 0.2)
				else
					currentPos = currentPos:Lerp(center, 0.2)
				end

				if Library.Flags.s_chspin then
					rotation = (rotation + 0.02) % (math.pi * 2)
				end

				local pts = {
					{
						Vector2.new(currentPos.X - gap, currentPos.Y),
						Vector2.new(currentPos.X - gap - len, currentPos.Y),
					},
					{
						Vector2.new(currentPos.X + gap, currentPos.Y),
						Vector2.new(currentPos.X + gap + len, currentPos.Y),
					},
					{
						Vector2.new(currentPos.X, currentPos.Y - gap),
						Vector2.new(currentPos.X, currentPos.Y - gap - len),
					},
					{
						Vector2.new(currentPos.X, currentPos.Y + gap),
						Vector2.new(currentPos.X, currentPos.Y + gap + len),
					},
				}

				for i = 1, 4 do
					local line = c[i]
					local from = rotatePoint(pts[i][1], currentPos, rotation)
					local to = rotatePoint(pts[i][2], currentPos, rotation)
					line.From, line.To = from, to
					line.Thickness = Library.Flags.s_chw or 2
					line.Visible = Library.Flags.s_ch == true
					line.Color = Library.Flags.s_chc or Color3.fromRGB(255, 255, 255)
				end
			end

			runService.RenderStepped:Connect(function()
				if not Library.Flags.s_ch then
					for i = 1, 4 do
						if c[i] then
							c[i].Visible = false
						end
					end
					return
				end

				if Library.Flags.s_chf then
					local barrelOrFlash

					for _, descendant in Camera:GetDescendants() do
						if descendant:IsA("BasePart") then
							local nameLower = descendant.Name:lower()
							if nameLower:find("barrel") or nameLower:find("flash") then
								barrelOrFlash = descendant
								break
							end
						end
					end

					if barrelOrFlash then
						local origin = barrelOrFlash.Position
						local direction = (Camera.CFrame.LookVector * 500)
						local raycastParams = RaycastParams.new()
						raycastParams.FilterDescendantsInstances = { LocalPlayer.Character }
						raycastParams.FilterType = Enum.RaycastFilterType.Exclude

						local raycastResult = workspace:Raycast(origin, direction, raycastParams)
						if raycastResult then
							local hitPos = raycastResult.Position
							local screenPos, onScreen = Camera:WorldToViewportPoint(hitPos)
							if onScreen and not LocalPlayer.PlayerGui.Display.Scope.Visible then
								updateCrosshair(Vector2.new(screenPos.X, screenPos.Y))
							else
								updateCrosshair(Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2))
							end
						else
							updateCrosshair(Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2))
						end
					else
						updateCrosshair(Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2))
					end
				else
					updateCrosshair(nil)
				end
			end)

			screenSection
				:createToggle({
					Text = "Crosshair",
					Flag = "s_ch",
					Callback = function(enabled)
						if not enabled then
							for i = 1, 4 do
								if c[i] then
									c[i].Visible = false
								end
							end
						else
							local cam = workspace.CurrentCamera
							if cam then
								currentPos = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
							end
							updateCrosshair(currentPos)
						end
					end,
				})
				:createColorpicker({ Text = "Crosshair Color", Default = Color3.fromRGB(255, 255, 255), Flag = "s_chc" })

			screenSection:createToggle({ Text = "Follow barrel", Flag = "s_chf", Callback = function(enabled) end })

			screenSection:createToggle({
				Text = "Spin",
				Flag = "s_chspin",
				Callback = function(v)
					if not v then
						rotation = 0
					end
				end,
			})
			screenSection:createSlider({
				Text = "Crosshair Gap",
				Min = 0,
				Max = 20,
				Value = 5,
				Flag = "s_chg",
				Callback = function(v) end,
			})
			screenSection:createSlider({
				Text = "Crosshair Width",
				Min = 0,
				Max = 20,
				Value = 2,
				Flag = "s_chw",
				Callback = function(v) end,
			})
			screenSection:createSlider({
				Text = "Crosshair Length",
				Min = 1,
				Max = 60,
				Value = 5,
				Flag = "s_chl",
				Callback = function(v) end,
			})

			-- init
			local cam = workspace.CurrentCamera
			if cam then
				currentPos = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
				updateCrosshair(currentPos)
			end

			screenSection:createSeperator({})
			screenSection:createDropdown({
				Text = "Watermark Type",
				Options = { "Default", "NocturnalV2", "atlanta", "nocturnalsense" },
				Default = "Default",
				Flag = "noct_wmtype2",
				Callback = function(wm)
					getgenv().noct_watermark = wm
				end,
			})
		end

		do
			local tab = window:createTab({ Text = "Misc", Small = true })
			local otherSec = tab:createSection({ Text = "Exploits", Location = 1 })
			otherSec
				:createToggle({ Text = "Peek Assist", Flag = "o_pa" })
				:createBind({ Flag = "pa_key", Text = "", Callback = function(a) end })
			otherSec
				:createToggle({ Text = "Double Tap", Flag = "o_dt" })
				:createBind({ Flag = "dt_key", Text = "", Callback = function(a) end })
			otherSec
				:createToggle({
					Text = "Kill All",
					Flag = "o_ka",
					Callback = function(a)
						if a then
							task.spawn(function()
								while Library.Flags.o_ka do
									if nocturnal:isAlive(playerService.LocalPlayer) then
										for idx, player in playerService:GetPlayers() do
											if nocturnal:isTarget(player) and nocturnal:isAlive(player) then
												if not player.Character then
													continue
												end

												local head = player.Character.Head
												local params = RaycastParams.new()
												local list = {
													playerService.LocalPlayer.Character,
													workspace.CurrentCamera,
													workspace.ServerIgnore,
													workspace.Map,
												}
												params.FilterType = Enum.RaycastFilterType.Blacklist
												params.FilterDescendantsInstances = list
												params.CollisionGroup = "ShootCast"

												local result = workspace:Raycast(
													workspace.CurrentCamera.CFrame.Position,
													head.Position - workspace.CurrentCamera.CFrame.Position,
													params
												)

												if
													result
													and result.Instance
													and result.Instance:IsDescendantOf(player.Character)
												then
													task.spawn(function()
														nocturnal:FireBullet(player, result)
													end)
												end
											end
										end
									end

									task.wait(0.1)
								end
							end)
						end
					end,
				})
				:createBind({ Flag = "ka_key", Text = "", Callback = function(a) end })

			local Y_AXIS = Vector3.new(0, 1, 0)
			local WALL_AREA_RATIO_THRESHOLD = 0.60

			local function isWall(part)
				local size = part.Size

				--// face areas
				local areaUp = size.X * size.Z
				local areaRight = size.Y * size.Z
				local areaLook = size.X * size.Y

				local totalArea = areaUp + areaRight + areaLook
				if totalArea <= 0 then
					return false
				end

				local cf = part.CFrame
				local wUp = 1 - math.abs(cf.UpVector:Dot(Y_AXIS))
				local wRight = 1 - math.abs(cf.RightVector:Dot(Y_AXIS))
				local wLook = 1 - math.abs(cf.LookVector:Dot(Y_AXIS))

				local wallArea = areaUp * wUp + areaRight * wRight + areaLook * wLook

				return (wallArea / totalArea) >= WALL_AREA_RATIO_THRESHOLD
			end

			otherSec
				:createToggle({
					Text = "Noclip",
					Flag = "o_nc",
					Callback = function(enabled)
						local map = workspace:FindFirstChild("Map")
						if not map then
							return
						end

						for _, part in map:GetDescendants() do
							if part:IsA("BasePart") and isWall(part) then
								if enabled then
									replicatedStorage.MovementBindables.removeCollidable:Fire(part)
								else
									replicatedStorage.MovementBindables.addCollidable:Fire(part)
								end
							end
						end
					end,
				})
				:createBind({
					Flag = "nc_key",
					Text = "",
					Callback = function() end,
				})

			otherSec
				:createToggle({
					Text = "Teleport to Plantsite",
					Flag = "o_tpb",
					Callback = function(a)
						local map = workspace:FindFirstChild("Map")
						if not map then
							return
						end
						local defuseparts = map:FindFirstChild("DefuseParts")
						if not defuseparts then
							return
						end

						local part = defuseparts:GetChildren()[1]
						if not part then
							return
						end

						nocturnal.completeMove:Fire(part.Position + Vector3.new(0, 5, 0))
					end,
				})
				:createBind({ Flag = "tpb_key", Text = "", Callback = function(a) end })
			local invisconn
			otherSec
				:createToggle({
					Text = "Invisible",
					Flag = "o_invis",
					Callback = function(a)
						if a then
							invisconn = runService.RenderStepped:Connect(function()
								if nocturnal:isAlive(playerService.LocalPlayer) then
									local root = playerService.LocalPlayer.Character.PrimaryPart
									if root then
										root.CFrame *= CFrame.new(0, -25, 0)
									end
								end
							end)
						else
							if invisconn then
								invisconn:Disconnect()
								invisconn = nil
							end
						end
					end,
				})
				:createBind({ Flag = "invis_key", Text = "", Callback = function(a) end })
			local pxSurfConn
			local targetY

			local function getNearestWallNormal(hrp)
				local directions = {
					hrp.CFrame.LookVector * -1, --// backward
					hrp.CFrame.RightVector, --// right
					-hrp.CFrame.RightVector, --// left
				}

				local closestNormal = nil
				local closestDistance = math.huge

				for _, dir in directions do
					local ray = Ray.new(hrp.Position, dir.Unit * 5) --// 5 studz
					local part, hitPos, normal = workspace:FindPartOnRay(ray, hrp.Parent)
					if part then
						local dist = (hitPos - hrp.Position).Magnitude
						if dist < closestDistance then
							closestDistance = dist
							closestNormal = normal
						end
					end
				end

				return closestNormal
			end

			otherSec
				:createToggle({
					Text = "Pixel Surf",
					Flag = "o_psurf",
					Callback = function(enabled)
						local player = playerService.LocalPlayer
						if not nocturnal:isAlive(player) then
							return
						end
						local hrp = player.Character and player.Character.PrimaryPart
						if not hrp then
							return
						end

						if enabled then
							targetY = hrp.Position.Y
							local surfMode = Library.Flags.o_psm or "Float"

							pxSurfConn = runService.Heartbeat:Connect(function(deltaTime)
								if not nocturnal:isAlive(player) then
									return
								end
								local hrp = player.Character and player.Character.PrimaryPart
								if not hrp then
									return
								end

								local speed = Library.Flags.o_psp * 100

								if surfMode == "Float" then
									local lookVector = workspace.CurrentCamera.CFrame.LookVector
									local moveDir = Vector3.new(lookVector.X, 0, lookVector.Z)
									if moveDir.Magnitude == 0 then
										return
									end
									moveDir = moveDir.Unit
									local displacement = moveDir * speed * deltaTime
									local newPos = hrp.Position + displacement
									newPos = Vector3.new(newPos.X, targetY, newPos.Z)

									nocturnal.completeMove:Fire(newPos)
								elseif surfMode == "WallLock" then
									local wallNormal = getNearestWallNormal(hrp)
									if not wallNormal then
										return
									end

									local lookVector = workspace.CurrentCamera.CFrame.LookVector
									local forward = Vector3.new(lookVector.X, 0, lookVector.Z)
									if forward.Magnitude == 0 then
										return
									end
									forward = forward.Unit

									--// Project move along wall planez
									local moveDir = (forward - forward:Dot(wallNormal) * wallNormal)
									if moveDir.Magnitude == 0 then
										return
									end
									moveDir = moveDir.Unit

									local displacement = moveDir * speed * deltaTime
									local newPos = hrp.Position + displacement
									newPos = Vector3.new(newPos.X, targetY, newPos.Z)

									nocturnal.completeMove:Fire(newPos)
								end
							end)
						else
							if pxSurfConn then
								pxSurfConn:Disconnect()
								pxSurfConn = nil
							end
						end
					end,
				})
				:createBind({ Flag = "surf_key", Text = "", Callback = function(a) end })

			otherSec:createDropdown({
				Text = "Surf Mode",
				Options = { "Float", "WallLock" },
				Default = "Float",
				Flag = "o_psm",
			})
			otherSec:createSlider({ Text = "Surf Speed", Min = 0.1, Max = 10, Value = 0.5, Step = 0.1, Flag = "o_psp" })

			otherSec:createToggle({ Text = "Anti Fire", Flag = "o_af" })
			otherSec:createToggle({ Text = "Infinite Money", Flag = "o_im" })

			local netSec = tab:createSection({ Text = "Network", Location = 2 })
			local btConn

			netSec:createToggle({
				Text = "Backtrack",
				Flag = "net_bt",
				Callback = function(enabled)
					if not enabled then
						if btConn then
							btConn:Disconnect()
							btConn = nil
						end
						return
					end

					btConn = runService.RenderStepped:Connect(function()
						local lp = playerService.LocalPlayer
						if not lp.Character or not nocturnal:isAlive(lp) then
							return
						end

						if Library.Flags.net_btt == "Parts" then
							for _, v in playerService:GetPlayers() do
								if v ~= lp and v.Character and nocturnal:isTarget(v) and nocturnal:isAlive(v) then
									if not Library.Flags.rage_sa then
										local track = Instance.new("Part")
										track.Name = v.Name
										track.Anchored = true
										track.CanCollide = false
										track.Material = Enum.Material.ForceField
										track.Color = Library.Flags.net_btcc
										track.Transparency = Library.Flags.net_bttrans
										track.Size = v.Character.Head.Size
										track.CFrame = v.Character.Head.CFrame
										track.Parent = workspace

										if not Library.Flags.net_vbt then
											track.Transparency = 1
										end

										local tag = Instance.new("ObjectValue")
										tag.Name = "PlayerName"
										tag.Value = v
										tag.Parent = track

										task.delay(Library.Flags.net_btms / 10000, function()
											if track then
												track:Destroy()
											end
										end)
									end
								end
							end
							return
						end

						local v = nocturnal:gcptest()
						if
							not v
							or v == lp
							or not v.Character
							or not nocturnal:isAlive(v)
							or not nocturnal:isTarget(v)
						then
							return
						end

						local root = v.Character.PrimaryPart
						local lpRoot = lp.Character.PrimaryPart
						if not root or not lpRoot then
							return
						end

						if
							Library.Flags.net_btt == "Characters"
							and not workspace:FindFirstChild("BacktrackChar_" .. v.Name)
						then
							local model = Instance.new("Model")
							model.Name = "BacktrackChar_" .. v.Name
							model.Parent = workspace

							for _, e in v.Character:GetDescendants() do
								if e:IsA("BasePart") and e.Transparency ~= 1 then
									local a = e:Clone()
									a.Anchored = true
									a.CanCollide = false
									a.CanQuery = true
									a.Material = Enum.Material.ForceField
									a.Color = Library.Flags.net_btcc
									a.Transparency = Library.Flags.net_bttrans
									a.Reflectance = 0
									a.Parent = model

									local tag = Instance.new("ObjectValue")
									tag.Name = "PlayerName"
									tag.Value = v
									tag.Parent = a

									if a:IsA("MeshPart") then
										a.TextureID = ""
									end

									for _, c in a:GetChildren() do
										if not c:IsA("SpecialMesh") then
											c:Destroy()
										else
											c.TextureId = ""
										end
									end
								end
							end

							task.delay(Library.Flags.net_btms / 10000, function()
								if model then
									model:Destroy()
								end
							end)
						end

						if
							Library.Flags.net_btt == "BoxHandleAdornments"
							and not workspace:FindFirstChild("BacktrackChar_" .. v.Name)
						then
							local model = Instance.new("Model")
							model.Name = "BacktrackChar_" .. v.Name
							model.Parent = workspace

							for _, e in v.Character:GetDescendants() do
								if e:IsA("BasePart") and e.Transparency ~= 1 then
									local a = e:Clone()
									a.Anchored = true
									a.CanCollide = false
									a.CanQuery = true
									a.Transparency = 1
									a.Parent = model

									local tag = Instance.new("ObjectValue")
									tag.Name = "PlayerName"
									tag.Value = v
									tag.Parent = a

									local box = Instance.new("BoxHandleAdornment")
									box.AlwaysOnTop = true
									box.ZIndex = 4
									box.Adornee = a
									box.Color3 = Library.Flags.net_btcc
									box.Transparency = Library.Flags.net_bttrans
									box.Size = a.Size + Vector3.new(0.02, 0.02, 0.02)
									box.Parent = a
								end
							end

							task.delay(Library.Flags.net_btms / 10000, function()
								if model then
									model:Destroy()
								end
							end)
						end
					end)
				end,
			})

			netSec
				:createToggle({ Text = "Visualize Backtrack", Flag = "net_vbt" })
				:createColorpicker({
					Text = "Backtrack Color",
					Default = Color3.fromRGB(255, 255, 255),
					Flag = "net_btcc",
				})
			netSec:createDropdown({
				Text = "Backtrack Type",
				Options = { "Parts", "Characters", "BoxHandleAdornments" },
				Default = "Characters",
				Flag = "net_btt",
			})
			netSec:createSlider({
				Text = "Backtrack Transparency",
				Min = 0,
				Max = 1,
				Value = 0.5,
				Step = 0.1,
				Flag = "net_bttrans",
			})
			netSec:createSlider({ Text = "Backtrack Delay (ms)", Min = 1, Max = 10000, Value = 400, Flag = "net_btms" })

			local realOthersSec = tab:createSection({ Text = "Other", Location = 1 })
			realOthersSec:createToggle({ Text = "Hitsounds", Flag = "ro_hs" })
			realOthersSec:createDropdown({
				Text = "Sound",
				Options = {
					"aimhook",
					"skeet.cc",
					"neverlose",
					"baimware",
					"osu",
					"rust",
					"bag",
					"sit",
					"reminder",
					"uwu",
					"zing",
					"crowbar",
					"ara ara",
					"burp",
					"mario",
					"laugh",
					"huh",
					"4.ogg",
					"808perc",
					"bubble pop 1.ogg",
					"quake4",
					"saya_cute",
					"mario coin",
					"Custom",
				},
				Default = "aimhook",
				Flag = "ro_s",
			})
			realOthersSec:createToggle({ Text = "Killsounds", Flag = "ro_ks" })
			realOthersSec:createDropdown({
				Text = "Sound",
				Options = {
					"aimhook",
					"skeet.cc",
					"neverlose",
					"baimware",
					"osu",
					"rust",
					"bag",
					"sit",
					"reminder",
					"uwu",
					"zing",
					"crowbar",
					"ara ara",
					"burp",
					"mario",
					"laugh",
					"huh",
					"Custom",
				},
				Default = "rust",
				Flag = "ro_ksound",
			})
			realOthersSec:createSeperator({})
			realOthersSec:createTextbox({
				Text = "Custom Killsound Id",
				Default = "rbxassetid://5709456554",
				Flag = "ro_cksoundid",
			})
			realOthersSec:createTextbox({
				Text = "Custom Hitsound Id",
				Default = "rbxassetid://138378419413244",
				Flag = "ro_chsoundid",
			})
			realOthersSec:createSeperator({})
			realOthersSec:createToggle({ Text = "Enable fluent effects", Flag = "ro_effects" })
			realOthersSec:createToggle({ Text = "Hitlogs", Flag = "ro_hl" })
			realOthersSec:createToggle({
				Text = "Emotional Support",
				Flag = "ro_es",
				Callback = function(a)
					nocturnal.paimon.Enabled = a
				end,
			})
			realOthersSec:createToggle({ Text = "Session Stats", Flag = "ro_sstats" })
			local conn
			local realName = playerService.LocalPlayer.Name
			local displayName = playerService.LocalPlayer.DisplayName

			function filterText(obj)
				if not obj:IsA("TextLabel") and not obj:IsA("TextButton") and not obj:IsA("TextBox") then
					return
				end

				if typeof(obj.Text) ~= "string" then
					return
				end

				local fake = Library.Flags.ro_cn or "Nocturnal user"

				obj.Text = obj.Text:gsub(realName, fake):gsub(displayName, fake)
			end

			function scanGui()
				for _, v in playerService.LocalPlayer.PlayerGui:GetDescendants() do
					filterText(v)
				end
			end

			realOthersSec:createToggle({
				Text = "Streamer mode",
				Flag = "ro_sm",
				Callback = function(enabled)
					if enabled then
						scanGui()

						conn = playerService.LocalPlayer.PlayerGui.DescendantAdded:Connect(function(obj)
							filterText(obj)
						end)
					else
						if conn then
							conn:Disconnect()
							conn = nil
						end
					end
				end,
			})
			realOthersSec:createTextbox({ Text = "Custom name", Default = "Nocturnal User", Flag = "ro_cn" })
			realOthersSec:createSeperator({})

			realOthersSec:createToggle({ Text = "Bomb timer", Flag = "ro_bt" })
			realOthersSec:createToggle({ Text = "Grenade timer", Flag = "ro_gt" })
			realOthersSec:createSeperator({})
			realOthersSec:createToggle({ Text = "Grenade trajectory", Flag = "ro_traj" }):createColorpicker({
				Text = "Line Color",
				Default = Color3.fromRGB(255, 255, 255),
				Flag = "ro_trajc",
				Callback = function(a)
					if not nocturnal.loadcomplete then
						return
					end
					for i = 1, #nocturnal.points do
						nocturnal.points[i].Color = a
					end
				end,
			})

			local movementSec = tab:createSection({ Text = "Movement", Location = 2 })
			movementSec:createToggle({ Text = "Bunny hop", Flag = "m_bhop" })
			movementSec:createDropdown({
				Text = "Bunnyhop Type",
				Options = { "Legit", "Rage" },
				Default = "Legit",
				Flag = "m_bhoptype",
			})
			movementSec:createToggle({ Text = "Speed", Flag = "m_speed" })
			movementSec:createSlider({
				Text = "Amount",
				Min = 1,
				Max = 10,
				Value = 2,
				Step = 0.1,
				Flag = "m_speedamount",
			})
			movementSec:createDropdown({
				Text = "Speed Type",
				Options = { "Multiplier1", "Multiplier2" },
				Default = "Multiplier1",
				Flag = "m_speedtype",
			})
			movementSec:createToggle({ Text = "Ladder modulation", Flag = "m_as" })
			movementSec:createSlider({ Text = "Ladder Speed", Min = 160, Max = 1500, Value = 160, Flag = "m_bhopspeed" })
			movementSec:createSlider({ Text = "Ladder Jumpoff", Min = 250, Max = 1500, Value = 250, Flag = "m_ljs" })

			local edgeConn
			local function raycast(origin, dir) --// pls dont kill me
				local params = RaycastParams.new()
				params.FilterDescendantsInstances = { playerService.LocalPlayer.Character, workspace.CurrentCamera }
				params.FilterType = Enum.RaycastFilterType.Exclude
				return workspace:Raycast(origin, dir, params)
			end

			movementSec
				:createToggle({
					Text = "Edgebug",
					Flag = "m_eb",
					Callback = function(enabled)
						if enabled then
							edgeConn = runService.Heartbeat:Connect(function(dt)
								if not nocturnal:isAlive(playerService.LocalPlayer) then
									return
								end
								local root = playerService.LocalPlayer.Character.PrimaryPart
								local vel = replicatedStorage.MovementBindables.getVelocity:Invoke()
								if vel.Y > 1 then
									return
								end --// already going up

								local forward = Vector3.new(vel.X, 0, vel.Z)
								if forward.Magnitude < 1 then
									return
								end
								forward = forward.Unit

								local feetHit = raycast(root.Position, Vector3.new(0, -3.1, 0))

								if not feetHit then
									return
								end

								local aheadPos = root.Position + forward * 2
								local aheadHit = raycast(aheadPos, Vector3.new(0, -3.1, 0))

								if not aheadHit then
									nocturnal.action("jump", Enum.UserInputState.Begin)
								end
							end)
						else
							if edgeConn then
								edgeConn:Disconnect()
								edgeConn = nil
							end
						end
					end,
				})
				:createBind({ Flag = "eb_key", Mode = "Toggle", Text = "", Callback = function(a) end })

			movementSec:createToggle({ Text = "Infinite crouch", Flag = "m_cd" })
			
			--[[ source ported from https://github.com/Storm99999/MRDemo ]]
			local SAMPLE_RATE = 1 / 60
			local IGNORE_WHEN_FOCUSED = true
			local SAVE_PATH = "nocturnal/recordings/"

			pcall(function()
				if not isfolder(SAVE_PATH) then
					makefolder(SAVE_PATH)
				end
			end)

			local camera = workspace.CurrentCamera
			local player = playerService.LocalPlayer
			local latestRecording = nil
			local isRecording = false
			local isPlaying = false
			local recordingStart = 0
			local recordingElapsed = 0
			local saveWindowUntil = 0
			local heldKeys = {}
			local heldMouseButtons = {}
			local samples = {} -- { { t, move, yaw, pitch, camRel, rootCFrame } }
			local events = {} -- { { t, kind, id } }

			local heldPlaybackKeys = {}
			local PlaybackInputSetter = nil

			local VISUALIZE_ENABLED = false
			local VISUALIZE_COLOR = Color3.fromRGB(255, 255, 255)
			local START_VISUALS = {}

			local function isTyping()
				if not IGNORE_WHEN_FOCUSED then
					return false
				end
				local focused = inputService:GetFocusedTextBox()

				return focused ~= nil
			end

			local function serialize(val)
				if typeof(val) == "CFrame" then
					return { type = "CF", data = { val:GetComponents() } }
				elseif typeof(val) == "Vector3" then
					return { type = "V3", data = { val.X, val.Y, val.Z } }
				end

				return val
			end

			local function deserialize(val)
				if type(val) == "table" and val.type then
					if val.type == "CF" then
						return CFrame.new(unpack(val.data))
					elseif val.type == "V3" then
						return Vector3.new(unpack(val.data))
					end
				end

				return val
			end

			local function clearVisuals()
				for _, v in START_VISUALS do
					v:Destroy()
				end
				START_VISUALS = {}
			end

			local function createStartVisual(pos, mapName)
				if not VISUALIZE_ENABLED then
					return
				end
				if mapName ~= nocturnal:Map() then
					return
				end

				local p = Instance.new("Part")
				p.Size = Vector3.new(0.5, 0.5, 0.5)
				p.Position = pos
				p.Anchored = true
				p.CanCollide = false
				p.CanQuery = false
				p.CanTouch = false
				p.Material = Enum.Material.Neon
				p.Color = VISUALIZE_COLOR
				p.Parent = workspace

				table.insert(START_VISUALS, p)
			end

			local function loadAndVisualize()
				clearVisuals() -- Clean ts
				if not isfolder(SAVE_PATH) then
					return
				end

				local files = listfiles(SAVE_PATH)
				local currentMap = nocturnal:Map()

				for _, filePath in files do
					if filePath:sub(-5) == ".json" then
						local success, content = pcall(readfile, filePath)
						if success then
							local decodeSuccess, data = pcall(function()
								return httpService:JSONDecode(content)
							end)

							if decodeSuccess and data.map == currentMap then
								if data.samples and data.samples[1] and data.samples[1].rootCFrame then
									local startPos = deserialize(data.samples[1].rootCFrame).Position
									createStartVisual(startPos, data.map)
								end
							end
						end
					end
				end
			end

			local function recordEvent(kind, id, t)
				table.insert(events, { t = t, kind = kind, id = id })
			end

			local function cameraAnglesFromCFrame(cf)
				local lv = cf.LookVector
				local yaw = math.atan2(lv.X, lv.Z)
				local pitch = math.asin(math.clamp(lv.Y, -1, 1)) -- DUDE

				return yaw, pitch
			end

			local function currentMoveVector()
				local forward, right = 0, 0
				if heldKeys["W"] then
					forward = forward + 1
				end
				if heldKeys["S"] then
					forward = forward - 1
				end
				if heldKeys["A"] then
					right = right - 1
				end
				if heldKeys["D"] then
					right = right + 1
				end

				local camC = camera and camera.CFrame or CFrame.new()
				local camForward = Vector3.new(camC.LookVector.X, 0, camC.LookVector.Z)
				if camForward.Magnitude == 0 then
					camForward = Vector3.new(0, 0, 1)
				end
				camForward = camForward.Unit

				local camRight = Vector3.new(camC.RightVector.X, 0, camC.RightVector.Z)
				if camRight.Magnitude == 0 then
					camRight = Vector3.new(1, 0, 0)
				end
				camRight = camRight.Unit

				local v = camForward * forward + camRight * right
				if v.Magnitude > 1e-5 then
					v = v.Unit
				else
					v = Vector3.new(0, 0, 0)
				end

				return v
			end

			local humanoidJumpConn, humanoidStateConn
			local function hookJump(humanoid)
				if humanoidJumpConn then
					humanoidJumpConn:Disconnect()
				end
				if humanoidStateConn then
					humanoidStateConn:Disconnect()
				end

				humanoidJumpConn = replicatedStorage.MovementBindables.jumping.Event:Connect(function()
					if isRecording then
						recordEvent("jump", nil, tick() - recordingStart)
					end
				end)
			end

			local function characterHooks()
				local char = player.Character
				if not char then
					return
				end
				local humanoid = char:FindFirstChildOfClass("Humanoid")

				hookJump()
			end

			local sampleAccumulator = 0
			runService.RenderStepped:Connect(function(dt)
				camera = workspace.CurrentCamera
				if isRecording then
					sampleAccumulator = sampleAccumulator + dt
					local now = tick()

					while sampleAccumulator >= SAMPLE_RATE do
						sampleAccumulator = sampleAccumulator - SAMPLE_RATE
						local t = now - recordingStart
						recordingElapsed = t

						local moveVec = currentMoveVector()
						local yaw, pitch = cameraAnglesFromCFrame(camera.CFrame)

						local camRel = nil
						local rootCFrame = nil
						local char = player.Character
						local rootPart = char and char:FindFirstChild("HumanoidRootPart")
						if rootPart and camera and camera.CFrame then
							camRel = rootPart.CFrame:ToObjectSpace(camera.CFrame)
							rootCFrame = rootPart.CFrame
						elseif camera and camera.CFrame then
							camRel = camera.CFrame
						end

						table.insert(samples, {
							t = t,
							move = moveVec,
							yaw = yaw,
							pitch = pitch,
							camRel = camRel,
							rootCFrame = rootCFrame,
						})
					end
				end
			end)

			local function dispatchPlaybackEvent(ev, humanoid, rootPart)
				if not ev then
					return
				end
				if ev.kind == "keyDown" then
					if ev.id == "Space" then
						heldPlaybackKeys["Space"] = true
						if PlaybackInputSetter then
							pcall(PlaybackInputSetter, "Space", true)
						end
						if humanoid then
							humanoid.Jump = true
						end
					else
						if PlaybackInputSetter then
							pcall(PlaybackInputSetter, ev.id, true)
						end
					end
				elseif ev.kind == "keyUp" then
					if ev.id == "Space" then
						heldPlaybackKeys["Space"] = nil
						if PlaybackInputSetter then
							pcall(PlaybackInputSetter, "Space", false)
						end
					else
						if PlaybackInputSetter then
							pcall(PlaybackInputSetter, ev.id, false)
						end
					end
				elseif ev.kind == "jump" or ev.kind == "jump_state" then
					nocturnal.action("jump", Enum.UserInputState.Begin)
				end
			end

			local function playRecording(recording)
				if not recording or isPlaying then
					return
				end
				local char = player.Character
				local humanoid = char and char:FindFirstChildOfClass("Humanoid")
				local rootPart = char and char:FindFirstChild("HumanoidRootPart")
				if not humanoid or not rootPart then
					return
				end

				isPlaying = true
				camera = workspace.CurrentCamera
				local savedCameraType = camera.CameraType
				local savedCameraSubject = camera.CameraSubject
				local savedFOV = camera.FieldOfView

				local startTick = tick()
				local duration = recording.duration
				local samplesList = recording.samples
				local eventsList = recording.events
				table.sort(eventsList, function(a, b)
					return a.t < b.t
				end)
				local eventIndex = 1

				if samplesList[1] and samplesList[1].rootCFrame then
					nocturnal.completeMove:Fire(samplesList[1].rootCFrame.Position)

					if rootPart.AssemblyLinearVelocity then
						rootPart.AssemblyLinearVelocity = Vector3.new(0, rootPart.AssemblyLinearVelocity.Y, 0)
					end
				end

				camera.CameraType = Enum.CameraType.Scriptable

				local running = true
				local conn
				conn = runService.RenderStepped:Connect(function()
					if not running then
						conn:Disconnect()
						return
					end

					local elapsed = tick() - startTick

					while eventIndex <= #eventsList and eventsList[eventIndex].t <= elapsed do
						dispatchPlaybackEvent(eventsList[eventIndex], humanoid, rootPart)
						eventIndex = eventIndex + 1
					end

					if PlaybackInputSetter then
						for k, _ in heldPlaybackKeys do
							pcall(PlaybackInputSetter, k, true)
						end
					end

					if heldPlaybackKeys["Space"] and humanoid then
						humanoid.Jump = true
					end

					if elapsed >= duration then
						running = false
						isPlaying = false

						for k, _ in heldPlaybackKeys do
							if PlaybackInputSetter then
								pcall(PlaybackInputSetter, k, false)
							end
						end

						heldPlaybackKeys = {}
						return
					end

					if #samplesList > 0 then
						local i = 1
						while i < #samplesList and samplesList[i + 1].t < elapsed do
							i = i + 1
						end
						local s1 = samplesList[i]
						local s2 = samplesList[math.min(i + 1, #samplesList)]
						local sT = 0
						if s2 and s2.t > s1.t then
							sT = (elapsed - s1.t) / (s2.t - s1.t)
						end

						local desiredRootCFrame = nil
						if s1.rootCFrame and s2 and s2.rootCFrame then
							desiredRootCFrame = s1.rootCFrame:Lerp(s2.rootCFrame, sT)
						elseif s1.rootCFrame then
							desiredRootCFrame = s1.rootCFrame
						end

						if desiredRootCFrame then
							nocturnal.completeMove:Fire(desiredRootCFrame.Position)
						end

						local camRel1 = s1.camRel
						local camRel2 = (s2 and s2.camRel) or camRel1
						if camRel1 and camRel2 and camera then
							camera.CFrame = rootPart.CFrame * camRel1:Lerp(camRel2, sT)
						end
					end
				end)
			end

			local function saveLatest()
				if not latestRecording then
					return
				end
				if tick() > saveWindowUntil then
					latestRecording = nil
					return
				end

				local mapName = nocturnal:Map()
				local fileName = SAVE_PATH .. mapName .. "_" .. os.time() .. ".json"

				local serializedData = {
					map = mapName,
					duration = latestRecording.duration,
					events = latestRecording.events,
					samples = {},
				}

				for _, s in latestRecording.samples do
					table.insert(serializedData.samples, {
						t = s.t,
						move = serialize(s.move),
						yaw = s.yaw,
						pitch = s.pitch,
						camRel = serialize(s.camRel),
						rootCFrame = serialize(s.rootCFrame),
					})
				end

				local success, err = pcall(function()
					writefile(fileName, httpService:JSONEncode(serializedData))
				end)

				if success then
					Notification.new("Saved: " .. fileName)

					if latestRecording.samples[1] and latestRecording.samples[1].rootCFrame then
						createStartVisual(latestRecording.samples[1].rootCFrame.Position, mapName)
					end
				else
					Notification.new("Save Error: " .. tostring(err))
				end
			end

			inputService.InputBegan:Connect(function(input, gp)
				if gp or isTyping() then
					return
				end

				local key = input.KeyCode
				if key == Enum.KeyCode.Y and Library.Flags.m_mvrecrere then
					saveLatest()
				end

				local name = tostring(key):gsub("Enum.KeyCode.", "")
				if name ~= "" then
					heldKeys[name] = true
				end
				if isRecording then
					recordEvent("keyDown", name, tick() - recordingStart)
				end
			end)

			inputService.InputEnded:Connect(function(input, gp)
				local name = tostring(input.KeyCode):gsub("Enum.KeyCode.", "")
				if name ~= "" then
					heldKeys[name] = nil
				end
				if isRecording then
					recordEvent("keyUp", name, tick() - recordingStart)
				end
			end)

			movementSec:createToggle({
				Text = "Movement Recorder",
				Flag = "m_mvrecrere",
				Callback = function(v) end,
			})
			movementSec
				:createToggle({
					Text = "Visualize recordings",
					Flag = "m_vr",
					Callback = function(v)
						VISUALIZE_ENABLED = v
						if v then
							loadAndVisualize()
						else
							clearVisuals()
						end
					end,
				})
				:createColorpicker({
					Text = "Line Color",
					Default = Color3.fromRGB(255, 255, 255),
					Flag = "m_vrc",
					Callback = function(c)
						VISUALIZE_COLOR = c
					end,
				})

			movementSec
				:createToggle({
					Text = "Toggle MR",
					Flag = "m_tmrr",
					Callback = function(v)
						if v then
							-- Start
							sampleAccumulator = 0 -- <-- importantz: reset ts accumulator
							isRecording = true
							samples = {}
							events = {}
							heldKeys = {}
							recordingStart = tick()
							recordingElapsed = 0
							characterHooks()
						else
							-- Stop
							isRecording = false
							latestRecording = {
								duration = recordingElapsed,
								samples = samples,
								events = events,
								map = nocturnal:Map(),
							}
							saveWindowUntil = tick() + 5

							task.delay(5, function()
								if latestRecording and tick() > saveWindowUntil then
									latestRecording = nil
								end
							end)

							Notification.new("Press Y to save recording")
						end
					end,
				})
				:createBind({
					Flag = "record2_key",
					Mode = "Toggle",
					Text = "",
					Callback = function() end,
				})

			local function playNearestRecording()
				if isPlaying or isRecording then
					return
				end

				local char = player.Character
				local rootPart = char and char:FindFirstChild("HumanoidRootPart")
				if not rootPart then
					return
				end

				local files = listfiles(SAVE_PATH)
				local currentMap = nocturnal:Map()

				local nearestRec = nil
				local shortestDistance = 5
				local nearestFile = nil

				for _, filePath in files do
					if filePath:sub(-5) == ".json" then
						local success, content = pcall(readfile, filePath)
						if success then
							local decodeSuccess, data = pcall(function()
								return httpService:JSONDecode(content)
							end)

							if decodeSuccess and data.map == currentMap then
								if data.samples and data.samples[1] and data.samples[1].rootCFrame then
									local startCF = deserialize(data.samples[1].rootCFrame)
									local dist = (rootPart.Position - startCF.Position).Magnitude

									if dist < shortestDistance then
										shortestDistance = dist
										nearestRec = data
										nearestFile = filePath
									end
								end
							end
						end
					end
				end

				if nearestRec then
					local decodedSamples = {}
					for _, s in nearestRec.samples do
						table.insert(decodedSamples, {
							t = s.t,
							move = deserialize(s.move),
							yaw = s.yaw,
							pitch = s.pitch,
							camRel = deserialize(s.camRel),
							rootCFrame = deserialize(s.rootCFrame),
						})
					end

					nearestRec.samples = decodedSamples
					playRecording(nearestRec)

					local fn = nearestFile:match("([^/\\]+)$") -- works for both / and \ ts time
					Notification.new(
						"Playing: " .. fn .. " (" .. math.floor(shortestDistance * 10) / 10 .. " studs away)"
					)
				else
					Notification.new("No recording found within 5 studs.")
				end
			end

			movementSec
				:createToggle({
					Text = "Play MR",
					Flag = "m_pmrr",
					Callback = function(v)
						if v and not isPlaying then
							playNearestRecording()
						end
					end,
				})
				:createBind({
					Flag = "record1_key",
					Mode = "Toggle",
					Text = "",
					Callback = function() end,
				})

			task.spawn(function()
				local lastMap = nocturnal:Map()
				while task.wait(5) do
					local currentMap = nocturnal:Map()
					if currentMap ~= lastMap then
						lastMap = currentMap
						if VISUALIZE_ENABLED then
							loadAndVisualize()
						end
					end
				end
			end)

			player.CharacterAdded:Connect(function()
				isRecording = false
				isPlaying = false
				task.delay(0.1, characterHooks)
			end)

			if player.Character then
				characterHooks()
			end

			local skinsSec = tab:createSection({ Text = "Skins", Location = 2 })
			skinsSec:createDropdown({
				Text = "Knife",
				Options = {
					"None",
					"ButterflyKnife",
					"Bayonet",
					"Karambit",
					"talon",
					"stiletto",
					"SurvivalKnife",
					"Shadow Daggers",
					"skeleton",
				},
				Default = "None",
				Flag = "skin_weapon",
				Callback = function(skin)
					nocturnal:ChangeKnife(skin, Library.Flags.skin_knifeskin)
					nocturnal.skins.knife.name = ""
				end,
			})

			skinsSec:createDropdown({
				Text = "Knife Skin",
				Options = {
					"None",
					"Doppler Sapphire",
					"Doppler Ruby",
					"Gamma Phase 10",
					"Doppler Emerald",
					"Gamma Doppler Phase 4",
					"Sea Drift",
					"Marble Fade",
					"Gamma Doppler Phase 1",
					"Blood Moon",
					"Doppler Phase 1",
					"Doppler Phase 2",
					"PurpleGuy",
					"Doppler Purple Dream",
				},
				Default = "None",
				Flag = "skin_knifeskin",
				Callback = function(a)
					selectedSkins.ctknife = a
					selectedSkins.tknife = a
					nocturnal.skins.knife.name = ""
				end,
			})

			local AllGloves = {}
			table.insert(AllGloves, "None")

			for idx, glove in replicatedStorage.Import.Assets.Gloves:GetChildren() do
				table.insert(AllGloves, glove.Name)
			end

			--[[skinsSec:createDropdown({ Text = "Glove", Options = AllGloves, Default = "None", Flag = "skin_glove", Callback = function(skin)
				--nocturnal:ChangeGlove(skin, Library.Flags.skin_gloveskin)
			end})

			skinsSec:createDropdown({ Text = "Glove Skin", Options = {"None", "Doppler Sapphire", "Doppler Ruby", "Gamma Phase 10", "Doppler Emerald", "Gamma Doppler Phase 4", "Sea Drift", "Marble Fade", "Gamma Doppler Phase 1", "Blood Moon", "Doppler Phase 1", "Doppler Phase 2","PurpleGuy"}, Default = "None", Flag = "skin_gloveskin", Callback = function(a)
				selectedSkins.glove = a
			end})]]

			local skins = {}
			local skinsFolder = replicatedStorage.Import.Assets.Skins

			for weaponName, folder in skinsFolder:GetChildren() do
				local list = {}
				list[1] = "None"
				for _, skin in folder:GetChildren() do
					list[#list + 1] = skin.Name
				end

				skins[folder.Name] = list
			end

			skinsSec:createDropdown({
				Text = "AK47 Skin",
				Options = skins.ak47,
				Default = "None",
				Flag = "skin_ak47skin",
				Callback = function(a)
					selectedSkins.ak47 = a
				end,
			})

			skinsSec:createDropdown({
				Text = "AWP Skin",
				Options = skins.awp,
				Default = "None",
				Flag = "skin_awpskin",
				Callback = function(a)
					selectedSkins.awp = a
				end,
			})

			skinsSec:createDropdown({
				Text = "SSG08 Skin",
				Options = skins.ssg08,
				Default = "None",
				Flag = "skin_ssg08skin",
				Callback = function(a)
					selectedSkins.ssg08 = a
				end,
			})

			skinsSec:createDropdown({
				Text = "Deagle Skin",
				Options = skins.deserteagle,
				Default = "None",
				Flag = "skin_deagleskin",
				Callback = function(a)
					selectedSkins.deserteagle = a
				end,
			})

			skinsSec:createDropdown({
				Text = "M4A1 Skin",
				Options = skins.m4a1,
				Default = "None",
				Flag = "skin_m4a1skin",
				Callback = function(a)
					selectedSkins.m4a1 = a
				end,
			})

			skinsSec:createDropdown({
				Text = "M4A4 Skin",
				Options = skins.m4a4,
				Default = "None",
				Flag = "skin_m4a4skin",
				Callback = function(a)
					selectedSkins.m4a4 = a
				end,
			})

			skinsSec:createDropdown({
				Text = "Glock Skin",
				Options = skins.glock,
				Default = "None",
				Flag = "skin_glockskin",
				Callback = function(a)
					selectedSkins.glock = a
				end,
			})

			do
				if not isfolder("nocturnal/models") then
					makefolder("nocturnal/models")
					makefolder("nocturnal/models/knife")
					makefolder("nocturnal/models/ssg08")
					makefolder("nocturnal/models/ak47")
					makefolder("nocturnal/models/awp")
					makefolder("nocturnal/models/glock")
				end

				local base_models = {
					{
						"nocturnal/models/knife/diamond_pickaxe.model",
						"https://github.com/Storm99999/nocturnal/blob/main/models/diamond_pickaxe.model?raw=true",
					},

					{
						"nocturnal/models/knife/diamond_sword.model",
						"https://github.com/Storm99999/nocturnal/blob/main/models/diamond_sword.model?raw=true",
					},
				}

				for idx, model in base_models do
					writefile(base_models[idx][1], game:HttpGetAsync(base_models[idx][2]))
				end
			end

			nocturnal.primaries = { ct = { ["None"] = {} }, t = { ["None"] = {} } }
			nocturnal.secondaries = { ct = { ["None"] = {} }, t = { ["None"] = {} } }
			nocturnal.grenades2 = { ct = { ["None"] = {} }, t = { ["None"] = {} } }

			local WEAPON_DATA = {
				--// RIFLES
				["AK47"] = { Price = 2700, Slot = "Primary", Team = "T" },
				["M4A1-S"] = { Price = 2900, Slot = "Primary", Team = "CT" },
				["M4A4"] = { Price = 3100, Slot = "Primary", Team = "CT" },
				["AUG"] = { Price = 3300, Slot = "Primary", Team = "CT" },
				["SG 553"] = { Price = 3000, Slot = "Primary", Team = "T" },
				["AWP"] = { Price = 4750, Slot = "Primary", Team = "Both" },
				["SSG 08"] = { Price = 1700, Slot = "Primary", Team = "Both" },
				["FAMAS"] = { Price = 2050, Slot = "Primary", Team = "CT" },
				["Galil AR"] = { Price = 1800, Slot = "Primary", Team = "T" },

				--// SMGS
				["MP9"] = { Price = 1250, Slot = "Primary", Team = "CT" },
				["MAC-10"] = { Price = 1050, Slot = "Primary", Team = "T" },
				["MP7"] = { Price = 1500, Slot = "Primary", Team = "Both" },
				["UMP-45"] = { Price = 1200, Slot = "Primary", Team = "Both" },
				["P90"] = { Price = 2350, Slot = "Primary", Team = "Both" },

				--// PISTOLS
				["Glock"] = { Price = 200, Slot = "Secondary", Team = "T" },
				["USP-S"] = { Price = 200, Slot = "Secondary", Team = "CT" },
				["P2000"] = { Price = 200, Slot = "Secondary", Team = "CT" },
				["P250"] = { Price = 300, Slot = "Secondary", Team = "Both" },
				["Desert Eagle"] = { Price = 700, Slot = "Secondary", Team = "Both" },
				["CZ75"] = { Price = 500, Slot = "Secondary", Team = "Both" },

				--// GRENADES
				["HE Grenade"] = { Price = 300, Slot = "Utility", Team = "Both" },
				["Flashbang"] = { Price = 200, Slot = "Utility", Team = "Both" },
				["SmokeGrenade"] = { Price = 300, Slot = "Utility", Team = "Both" },
				["Molotov"] = { Price = 400, Slot = "Utility", Team = "T" },
				["Incendiary Grenade"] = { Price = 600, Slot = "Utility", Team = "CT" },
			}

			local function buildOptions(tbl: { any }): {}
				local options = {}

				for name in tbl do
					table.insert(options, name) --// temp fix
				end

				table.sort(options)

				return options
			end

			for weaponName, data in WEAPON_DATA do
				local teams = data.Team == "CT" and { "ct" } or data.Team == "T" and { "t" } or { "ct", "t" }

				for _, team in teams do
					local target = data.Slot == "Primary" and nocturnal.primaries
						or data.Slot == "Secondary" and nocturnal.secondaries
						or nocturnal.grenades2

					target[team][weaponName] = {
						Name = weaponName,
						Price = data.Price,
						Slot = data.Slot,
						Team = team:upper(),
					}
				end
			end

			local autoBuyConnection
			local debounce = false

			local ct, t = tab:createMultisection({
				Text = "Autobuy",
				Sections = { "CT", "T" },
				Text1 = "Autobuy",
				Text2 = "Autobuy",
				Location = 2,
			})

			ct.createToggle({
				Section = 1,
				Text = "Enabled",
				Flag = "m_autob",
				Callback = function(enabled)
					if not enabled then
						if autoBuyConnection then
							autoBuyConnection:Disconnect()
							autoBuyConnection = nil
						end

						return
					end

					local buyZones = workspace:WaitForChild("Map"):WaitForChild("BuyZones"):GetChildren()
					local rayParams = RaycastParams.new()
					rayParams.FilterType = Enum.RaycastFilterType.Include
					rayParams.IgnoreWater = true

					autoBuyConnection = runService.RenderStepped:Connect(function()
						if replicatedStorage.MatchStates.BuyTime.Value <= 0 then
							return
						end
						if debounce then
							return
						end
						if not nocturnal:isAlive(playerService.LocalPlayer) then
							return
						end

						local character = playerService.LocalPlayer.Character
						local root = character and character.PrimaryPart
						if not root then
							return
						end

						rayParams.FilterDescendantsInstances = buyZones
						if not workspace:Raycast(root.Position, Vector3.new(0, -500, 0), rayParams) then
							return
						end

						debounce = true
						local team = string.lower(playerService.LocalPlayer.PlayerStates.Team.Value)

						local selections = {
							{ Flag = team == "ct" and "ctab_p" or "tab_p", Slot = "Primary" },
							{ Flag = team == "ct" and "ctab_s" or "tab_s", Slot = "Secondary" },
							{ Flag = team == "ct" and "ctab_g" or "tab_g", Slot = "Utility" },
						}

						for _, sel in selections do
							local choice = Library.Flags[sel.Flag]
							if choice and choice ~= "None" then
								local weaponData = sel.Slot == "Primary" and nocturnal.primaries[team][choice]
									or sel.Slot == "Secondary" and nocturnal.secondaries[team][choice]
									or nocturnal.grenades2[team][choice]

								if weaponData then
									replicatedStorage.Import.Remotes.BuyGun:FireServer(
										weaponData.Name,
										weaponData.Slot,
										tostring(weaponData.Price)
									)
								end
							end
						end

						task.delay(30, function()
							debounce = false
						end)
					end)
				end,
			})

			ct.createDropdown({
				Section = 1,
				Text = "Primary",
				Options = buildOptions(nocturnal.primaries.ct),
				Default = "None",
				Flag = "ctab_p",
			})

			ct.createDropdown({
				Section = 1,
				Text = "Secondary",
				Options = buildOptions(nocturnal.secondaries.ct),
				Default = "None",
				Flag = "ctab_s",
			})

			ct.createDropdown({
				Section = 1,
				Text = "Grenades",
				Options = buildOptions(nocturnal.grenades2.ct),
				Default = "None",
				Flag = "ctab_g",
			})

			t.createDropdown({
				Section = 2,
				Text = "Primary",
				Options = buildOptions(nocturnal.primaries.t),
				Default = "None",
				Flag = "tab_p",
			})

			t.createDropdown({
				Section = 2,
				Text = "Secondary",
				Options = buildOptions(nocturnal.secondaries.t),
				Default = "None",
				Flag = "tab_s",
			})

			t.createDropdown({
				Section = 2,
				Text = "Grenades",
				Options = buildOptions(nocturnal.grenades2.t),
				Default = "None",
				Flag = "tab_g",
			})

			local modelSec = tab:createSection({ Text = "Custom models", Location = 1 })
			modelSec:createLabel({ Text = "To import custom models, put them in /nocturnal/models." })
			modelSec:createLabel({ Text = "" })

			local KnifeModels = {}
			for _, path in listfiles("nocturnal/models/knife/") do
				local cut = path:match("[^/\\]+$")
				local name = cut:gsub("%.model$", "") -- gsub returns TWO Values??? WTF
				table.insert(KnifeModels, name)
			end

			modelSec:createDropdown({
				Text = "Knife",
				Options = KnifeModels,
				Default = "None",
				Flag = "model_knifeweapon",
			})
			modelSec:createButton({
				Text = "Convert",
				Callback = function()
					local file = "nocturnal/models/knife/" .. Library.Flags.model_knifeweapon .. ".model"
					local data = loadstring(readfile(file))()

					if Viewmodels:FindFirstChild("v_TKnife") then
						Viewmodels["v_TKnife"].Parent = nil
					end

					if Viewmodels:FindFirstChild("v_CTKnife") then
						Viewmodels["v_CTKnife"].Parent = nil
					end

					task.wait()

					local Model1 = Instance.new("Model", Viewmodels)
					game:GetObjects(data.Asset)[1].Parent = Model1
					Model = Viewmodels.Model

					for _, Child in Model:GetChildren() do
						Child.Parent = Model.Parent
					end

					Model:Destroy()
					task.wait()
					Viewmodels[data.Model].Name = "v_TKnife"
					local ct = Viewmodels["v_TKnife"]:Clone()
					ct.Name = "v_CTKnife"
					ct.Parent = Viewmodels

					nocturnal.skins.knife.name = data.Name
					nocturnal.skins.knife.image = data.Image
				end,
			})

			modelSec:createSeperator({})
			modelSec:createDropdown({
				Text = "Custom character",
				Options = nocturnal.characters,
				Default = "None",
				Flag = "model_char",
				Callback = function(char)
					if char ~= "None" then
						nocturnal:SwapCharacter(char)
					end
				end,
			})
		end

		-- SETTINGS TAB
		do
			local tab = window:createTab({ Text = "Settings" })

			tab:createSettings({})
		end

		-- done
		return true
	end

	x(window)
end

-- [[ definitions ]]
local player, camera, mouse =
	Services.Players.LocalPlayer, workspace.CurrentCamera, Services.Players.LocalPlayer:GetMouse()
local Players = Services.Players
local runService = Services.RunService
local inputService = Services.UserInputService

-- [[ functions ]]

local PHYS_MULT = 8.183673469387754 --// this is what they mult with so ill use it
local SETTINGS = {
	Steps = 200,
	DeltaTime = 1 / 60,
	Thickness = 2,
	Color = Color3.fromRGB(255, 255, 255),
	Transparency = 1,
}

local P_CONFIG = { --// this was supposed to be updated per grenade but they all use the same values so no point.
	MaxBounces = 4,
	Decay = 0.5,
	Threshold = 2,
	Gravity = 0.65,
}

nocturnal.points = {}

for i = 1, SETTINGS.Steps - 1 do
	local line = nocturnal:Draw("Line", { Color = Color3.fromRGB(255, 255, 255), Thickness = 1, Visible = false })

	nocturnal.points[i] = line
end

function nocturnal:get_initial_velocity(origin, target, velocity)
	return (target - origin).Unit * velocity * PHYS_MULT
end

function nocturnal:get_acceleration(wind, gravity)
	return Vector3.new(wind.X, wind.Y - gravity * 9.8, wind.Z) * PHYS_MULT
end

function nocturnal:world_to_screen(point)
	local vec3, on_screen = camera:WorldToScreenPoint(point)
	return vec3, on_screen
end

function nocturnal:worldToScreen_Test(position)
	local screenPoint, onScreen = camera:WorldToViewportPoint(position)
	if onScreen then
		return Vector2.new(screenPoint.X, screenPoint.Y)
	else
		return nil
	end
end

local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Include
local includeList = {}
local map = workspace:FindFirstChild("Map")
if map then
	local geom = map:FindFirstChild("Geometry")
	if geom then
		table.insert(includeList, geom)
	end
end

rayParams.FilterDescendantsInstances = includeList --// TODO: Make sure this gets updated every frame but im lazy // COMPLETED.

function nocturnal:Predict(origin, target, velocity, wind)
	--// update per map
	local includeList = {}
	local map = workspace:FindFirstChild("Map")
	if map then
		local geom = map:FindFirstChild("Geometry")
		if geom then
			table.insert(includeList, geom)
		end
	end

	rayParams.FilterDescendantsInstances = includeList

	local initialVelocity = nocturnal:get_initial_velocity(origin, target, velocity)
	local acceleration = nocturnal:get_acceleration(wind, P_CONFIG.Gravity)
	local originSegment = origin
	local lastPosition = origin
	local timeSinceBounce = 0
	local bounceCount = 0
	local MaxBounces = P_CONFIG.MaxBounces
	local Decay = P_CONFIG.Decay
	local Threshold = P_CONFIG.Threshold

	local DT = 1 / 60
	local stepIndex = 1
	local finished = false
	local lastScreenPos = nil

	for i = 1, #nocturnal.points do
		nocturnal.points[i].Visible = false
	end

	while stepIndex <= SETTINGS.Steps and not finished do
		timeSinceBounce = timeSinceBounce + DT
		local currentVelocity = initialVelocity + acceleration * timeSinceBounce
		local newPos = Vector3.new(
			originSegment.X + initialVelocity.X * timeSinceBounce + 0.5 * acceleration.X * timeSinceBounce ^ 2,
			originSegment.Y + initialVelocity.Y * timeSinceBounce + 0.5 * acceleration.Y * timeSinceBounce ^ 2,
			originSegment.Z + initialVelocity.Z * timeSinceBounce + 0.5 * acceleration.Z * timeSinceBounce ^ 2
		)

		local dir = newPos - lastPosition
		local length = dir.Magnitude
		local hit = nil
		if length > 0.0001 and #rayParams.FilterDescendantsInstances > 0 then
			hit = workspace:Raycast(lastPosition, dir, rayParams)
		end

		local screenPos3, onScreen = nocturnal:world_to_screen(hit and hit.Position or newPos)
		local screenPos = Vector2.new(screenPos3.X, screenPos3.Y)

		if lastScreenPos and stepIndex <= #nocturnal.points then
			local line = nocturnal.points[stepIndex]
			line.From = lastScreenPos
			line.To = screenPos
			line.Visible = onScreen
			stepIndex = stepIndex + 1
		end

		lastScreenPos = screenPos

		if hit then
			bounceCount = bounceCount + 1
			local reflected = currentVelocity - 2 * currentVelocity:Dot(hit.Normal) * hit.Normal
			initialVelocity = reflected * Decay
			if initialVelocity.Magnitude < Threshold then
				finished = true
				break
			end
			originSegment = hit.Position
			lastPosition = hit.Position
			timeSinceBounce = 0
		else
			lastPosition = newPos
		end
	end

	for i = stepIndex, #nocturnal.points do
		nocturnal.points[i].Visible = false
	end
end

function nocturnal:SwapCharacter(n: string)
	local a, b, c = player, ChrModels, BrickColor.new("Medium stone grey")
	if not n or n == "None" then
		return
	end

	local d = b:FindFirstChild(n)
	if not d then
		return
	end

	local e = a and a.Character
	if not e then
		return
	end

	for _, x in e:GetChildren() do
		if x:IsA("Accessory") then
			x:Destroy()
		end
	end

	for _, p in e:GetChildren() do
		if p:IsA("BasePart") then
			local q = d:FindFirstChild(p.Name)
			if q and q:IsA("BasePart") then
				p.BrickColor = (a and a.TeamColor) or c
				p.Transparency = q.Transparency
			end
		end

		if p.Name == "Head" then
			local da = p:FindFirstChildWhichIsA("Decal")
			local hb = d:FindFirstChild("Head")
			local db = hb and hb:FindFirstChildWhichIsA("Decal")
			if da and db then
				da.Texture = db.Texture
			end
		end
	end

	local function replace(class)
		local src = d:FindFirstChildWhichIsA(class)
		if not src then
			return
		end
		local old = e:FindFirstChildWhichIsA(class)
		if old then
			old:Destroy()
		end
		src:Clone().Parent = e
	end

	replace("Shirt")
	replace("Pants")

	for _, acc in d:GetChildren() do
		if acc:IsA("Accessory") then
			local y = acc:Clone()
			local h = y:FindFirstChild("Handle")
			if h then
				for _, w in h:GetChildren() do
					if w:IsA("Weld") and w.Part1 then
						local z = e:FindFirstChild(w.Part1.Name)
						if z then
							w.Part1 = z
						end
					end
				end
			end
			y.Parent = e
		end
	end

	for _, cls in { "Shirt", "Pants" } do
		local obj = e:FindFirstChildWhichIsA(cls)
		if obj then
			local s = Instance.new("StringValue")
			s.Name = "OriginalTexture"
			s.Value = obj[cls .. "Template"] or ""
			s.Parent = obj
		end
	end

	for _, u in e:GetChildren() do
		local function save(t)
			local col = Instance.new("Color3Value")
			col.Name = "OriginalColor"
			col.Value = t.Color
			col.Parent = t

			local mat = Instance.new("StringValue")
			mat.Name = "OriginalMaterial"
			mat.Value = tostring(t.Material)
			mat.Parent = t
		end

		if u:IsA("BasePart") and u.Transparency ~= 1 then
			save(u)
		elseif u:IsA("Accessory") then
			local h = u:FindFirstChild("Handle")
			if h and h:IsA("BasePart") and h.Transparency ~= 1 then
				save(h)
			end
		end
	end
end

function nocturnal:isAlive(p): ()
	if not p then
		return false
	end
	if not p.Character then
		return false
	end
	local hum = p.Character:FindFirstChildOfClass("Humanoid")
	if not hum then
		return false
	end
	if hum.Health <= 0 then
		return false
	end
	if not p.PlayerStates.Alive.Value then
		return false
	end

	return true
end

function nocturnal:isTarget(p): ()
	if not p then
		return false
	end
	if not p.Character then
		return false
	end
	if p.PlayerStates and player.PlayerStates then
		return (p.PlayerStates.Team.Value ~= player.PlayerStates.Team.Value)
	end

	return p ~= player
end

function nocturnal:isCorrect(Args, RayMethod): ()
	local Matches = 0
	local Arg = { "Instance", "Ray", "table", "boolean", "boolean" }

	if #Args < 3 then
		return false
	end

	for Pos, Argument in Args do
		if typeof(Argument) == Arg[Pos] then
			Matches = Matches + 1
		end
	end

	return Matches >= 3
end

function nocturnal:partIsVisible(part, ignoreList)
	if not part or not part.Parent then
		return false
	end
	local rayOrigin = workspace.CurrentCamera.CFrame.Position
	local dir = part.Position - rayOrigin
	if dir.Magnitude <= 0 then
		return true
	end

	local ray = Ray.new(rayOrigin, dir.Unit * dir.Magnitude)
	local hit = workspace:FindPartOnRayWithIgnoreList(ray, ignoreList, false, true)

	-- if ray hits nothing, it's unobstructed, good!!!
	if not hit then
		return true
	end

	return hit:IsDescendantOf(part.Parent)
end

function nocturnal:removeChams(c)
	if not c.Character then
		return
	end
	for idx, v in c.Character:GetChildren() do
		if v:IsA("BasePart") and v.Transparency ~= 1 then
			if v:FindFirstChild("Glow") and v:FindFirstChild("Chams") then
				v.Glow:Destroy()
				v.Chams:Destroy()
			end
		end
	end
end

function nocturnal:getFreestandYaw(): number
	local directions = { -90, 0, 90, 180 } -- left, forward, right, back
	local bestDir = 0
	local maxDist = -math.huge
	local torso = playerService.LocalPlayer.Character.UpperTorso

	for _, yaw in directions do
		local rad = math.rad(yaw)
		local dir = Vector3.new(math.sin(rad), 0, math.cos(rad))
		local origin = torso.Position
		local ray = Ray.new(origin, dir * 100)
		local hit, pos = workspace:FindPartOnRayWithIgnoreList(
			ray,
			{ player.Character, workspace.CurrentCamera, workspace.ServerIgnore }
		)
		local dist = hit and (pos - origin).Magnitude or 100
		if dist > maxDist then
			maxDist = dist
			bestDir = yaw
		end
	end

	return bestDir
end

function nocturnal:getAntiAimCFrame(dt: number): CFrame --[[
    if not nocturnal:isAlive(playerService.LocalPlayer) then return CFrame.new() end
	local head = playerService.LocalPlayer.Character.Head
	local torso = playerService.LocalPlayer.Character.PrimaryPart

    local camCF = workspace.CurrentCamera.CFrame
    local headPos = head.Position
    local torsoLV = torso.CFrame.LookVector

    local diffY = headPos.Y - camCF.Position.Y
    local dist = math.max((headPos - camCF.Position).Magnitude, 0.0001)
    local vUnit = (headPos - camCF.Position).Unit
    local crossY = -vUnit:Cross(torsoLV).Y

    local pitch = -math.asin(math.clamp(diffY / dist, -1, 1) * 0.6)
    local yawRoll = -crossY * 1

    local aaMode: string = Library.Flags.aa_mode or "Static"
    local yawOffset: number = Library.Flags.aa_yaw or 180
    local pitchOffset: number = Library.Flags.aa_pitch or 0

    -- Mode adjustments
    if aaMode == "Jitter" then
        local speed = Library.Flags.aa_js or 10
        yawOffset = yawOffset * (math.sin(tick() * speed) > 0 and 1 or -1)
    elseif aaMode == "Spin" then
        yawOffset = tick() * 180 % 360
    elseif aaMode == "Freestanding" then
        yawOffset = 0 -- neck doesn't rotate, HRP handles freestand
    elseif aaMode == "Custom" then
        -- keep user-defined yawOffset
    end

	-- pitch, yaw, roll
	local targetC0 = Vector3.new(0, 0, 0) * CFrame.Angles(math.rad(pitch + pitchOffset), math.rad(yawRoll + yawOffset), 0)


    return targetC0]] end

function nocturnal:jitterSign(speed: number): number
	return (math.sin(tick() * speed * 2) > 0) and 1 or -1
end

function nocturnal:applyFreestandBodyRotation(dt: number)
	local hrp = player.Character.HumanoidRootPart
	if not hrp then
		return
	end
	if Library.Flags.aa_enabled then
		local aaMode: string = Library.Flags.aa_mode or "Static"
		local bodyYawFlag: number = Library.Flags.aa_yaw or 180
		local jitterSpeed: number = Library.Flags.aa_js or 10
		local jitterAmount: number = 45
		local jitterTarget: string = "Both"

		local desiredYaw = bodyYawFlag

		if aaMode == "Jitter" then
			if jitterTarget == "Body" or jitterTarget == "Both" then
				desiredYaw = bodyYawFlag + nocturnal:jitterSign(jitterSpeed) * jitterAmount
			end
		elseif aaMode == "Spin" then
			desiredYaw = (tick() * jitterSpeed) % 360
		elseif aaMode == "Freestanding" then
			desiredYaw = nocturnal:getFreestandYaw()
		end

		local targetHRP = hrp.CFrame * CFrame.Angles(0, math.rad(desiredYaw), 0)
		hrp.CFrame = targetHRP

		--[[print(targetHRP, desiredYaw)]]
	end
end

function nocturnal:getSound(hitsound: boolean): ()
	local function Get(fileName, url): ()
		local path = "nocturnal/assets/" .. fileName
		writefile(path, game:HttpGet(url))
		return getasset(path)
	end

	local hits = hitsound and Library.Flags.ro_s or Library.Flags.ro_ksound
	-- ref {"aimhook", "skeet.cc", "neverlose", "baimware", "osu", "rust", "bag", "sit","reminder","uwu","zing","crowbar","ara ara","burp","mario","laugh","huh", "4.ogg", "808perc", "bubble pop 1.ogg", "quake4", "saya_cute", "Custom"}, Default = "aimhook", Flag = "ro_s" }
	local soundMap = {
		["skeet.cc"] = "rbxassetid://5447626464",
		["baimware"] = "rbxassetid://6607339542",
		["neverlose"] = "rbxassetid://6607204501",
		["mario coin"] = "rbxassetid://5709456554",
		["rust"] = "rbxassetid://5043539486",
		["bag"] = "rbxassetid://364942410",
		["sit"] = {
			"sit.mp3",
			"https://raw.githubusercontent.com/Storm99999/whitelistkeys/main/aimhook/sounds/sit.mp3",
		},
		["osu"] = {
			"osu.mp3",
			"https://raw.githubusercontent.com/Storm99999/whitelistkeys/main/aimhook/sounds/osu.mp3",
		},
		["reminder"] = {
			"reminder.mp3",
			"https://raw.githubusercontent.com/Storm99999/whitelistkeys/main/aimhook/sounds/reminder.mp3",
		},
		["uwu"] = {
			"uwu.mp3",
			"https://raw.githubusercontent.com/Storm99999/whitelistkeys/main/aimhook/sounds/uwu.mp3",
		},
		["zing"] = {
			"zing.mp3",
			"https://raw.githubusercontent.com/Storm99999/whitelistkeys/main/aimhook/sounds/animezing.mp3",
		},
		["crowbar"] = {
			"crowbar.mp3",
			"https://raw.githubusercontent.com/Storm99999/whitelistkeys/main/aimhook/sounds/crowbar.mp3",
		},
		["laugh"] = {
			"laugh.mp3",
			"https://raw.githubusercontent.com/Storm99999/whitelistkeys/main/aimhook/sounds/laugh.mp3",
		},
		["burp"] = {
			"burp.mp3",
			"https://raw.githubusercontent.com/Storm99999/whitelistkeys/main/aimhook/sounds/burp.mp3",
		},
		["mario"] = {
			"mario.mp3",
			"https://raw.githubusercontent.com/Storm99999/whitelistkeys/main/aimhook/sounds/mariowoahh.mp3",
		},
		["huh"] = {
			"huh.mp3",
			"https://raw.githubusercontent.com/Storm99999/whitelistkeys/main/aimhook/sounds/huhh.mp3",
		},
		["ara ara"] = {
			"ara.mp3",
			"https://raw.githubusercontent.com/Storm99999/whitelistkeys/main/aimhook/sounds/ara.mp3",
		},
		["aimhook"] = {
			"nv.mp3",
			"https://raw.githubusercontent.com/Storm99999/whitelistkeys/main/aimhook/sounds/Track.mp3",
		},
		["quake4"] = { "q4.ogg", "https://github.com/Storm99999/nocturnal/blob/main/weapon_hit.ogg?raw=true" },
		["saya_cute"] = { "saya.ogg", "https://github.com/Storm99999/nocturnal/blob/main/saya_cute.ogg?raw=true" },
		["808perc"] = { "808.ogg", "https://github.com/Storm99999/nocturnal/blob/main/808%20perc.ogg?raw=true" },
		["4.ogg"] = { "4.ogg", "https://github.com/Storm99999/nocturnal/blob/main/4.ogg?raw=true" },
		["bubble pop 1.ogg"] = {
			"bubble pop 1.ogg",
			"https://github.com/Storm99999/nocturnal/blob/main/bubble%20pop%201.ogg?raw=true",
		},
	}

	local soundInfo

	if rawequal(hits, "Custom") then
		soundInfo = hitsound and Library.Flags.ro_chsoundid or Library.Flags.ro_cksoundid
	else
		soundInfo = soundMap[hits]
	end

	if type(soundInfo) == "string" then
		return soundInfo
	elseif type(soundInfo) == "table" then
		return Get(soundInfo[1], soundInfo[2])
	end
end

function nocturnal:getCorners(part)
	local s = part.Size * 0.5

	return {
		Vector3.new(-s.X, -s.Y, -s.Z),
		Vector3.new(s.X, -s.Y, -s.Z),
		Vector3.new(-s.X, -s.Y, s.Z),
		Vector3.new(s.X, -s.Y, s.Z),
		Vector3.new(-s.X, s.Y, -s.Z),
		Vector3.new(s.X, s.Y, -s.Z),
		Vector3.new(-s.X, s.Y, s.Z),
		Vector3.new(s.X, s.Y, s.Z),
	}
end

function nocturnal:findBestTarget(a)
	local Ignore = {}
	if player and player.Character then
		table.insert(Ignore, player.Character)
	end
	if camera then
		table.insert(Ignore, camera)
	end
	if workspace.Map and workspace.Map.Clips then
		table.insert(Ignore, workspace.Map.Clips)
	end
	if workspace:FindFirstChild("ServerIgnore") then
		table.insert(Ignore, workspace.ServerIgnore)
	end
	if workspace:FindFirstChild("Ragdolls") then
		table.insert(Ignore, workspace.Ragdolls)
	end
	if workspace:FindFirstChild("Ray_Ignore") then
		table.insert(Ignore, workspace.Ray_Ignore)
	end

	local bestDistance = math.huge
	local bestPlayer = nil
	local bestPart = nil

	if player and player.PlayerGui and player.PlayerGui:FindFirstChild("Flash") then
		return nil, nil
	end

	for _, other in playerService:GetPlayers() do
		if other ~= player and nocturnal:isAlive(other) and nocturnal:isTarget(other) then
			if other.Character and not other.Character:FindFirstChildOfClass("ForceField") then
				local hrp = other.Character:FindFirstChild("HumanoidRootPart")

				if not a then
					if hrp then
						local screenPos, onScreen = camera:WorldToViewportPoint(hrp.Position)
						if onScreen then
							local dist2d = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(mouse.X, mouse.Y)).Magnitude
							if dist2d < Library.Flags.aim_radius then
								local hitboxPart = nil
								local head = other.Character:FindFirstChild("Head")
								local torso = other.Character:FindFirstChild("UpperTorso")
									or other.Character:FindFirstChild("Torso")

								if Library.Flags.aim_hb == "Closest" then
									if head or torso then
										if head and torso then
											local headPos, headOn = camera:WorldToViewportPoint(head.Position)
											local torsoPos, torsoOn = camera:WorldToViewportPoint(torso.Position)
											if headOn and torsoOn then
												local headDist = (Vector2.new(headPos.X, headPos.Y) - Vector2.new(
													mouse.X,
													mouse.Y
												)).Magnitude
												local torsoDist = (Vector2.new(torsoPos.X, torsoPos.Y) - Vector2.new(
													mouse.X,
													mouse.Y
												)).Magnitude
												hitboxPart = (headDist < torsoDist) and head or torso
											elseif headOn then
												hitboxPart = head
											elseif torsoOn then
												hitboxPart = torso
											end
										else
											hitboxPart = head or torso
										end
									end
								elseif Library.Flags.aim_hb == "Head" then
									hitboxPart = head
								elseif Library.Flags.aim_hb == "Body" then
									hitboxPart = torso
								end

								if hitboxPart then
									if not Library.Flags.aim_wc then
										local screenP, onS = camera:WorldToViewportPoint(hitboxPart.Position)
										if onS then
											local curDist = (Vector2.new(screenP.X, screenP.Y) - Vector2.new(
												mouse.X,
												mouse.Y
											)).Magnitude
											if curDist < bestDistance then
												bestDistance = curDist
												bestPlayer = other
												bestPart = hitboxPart
											end
										end
									else
										if nocturnal:partIsVisible(hitboxPart, Ignore) then
											local screenP, onS = camera:WorldToViewportPoint(hitboxPart.Position)
											if onS then
												local curDist = (Vector2.new(screenP.X, screenP.Y) - Vector2.new(
													mouse.X,
													mouse.Y
												)).Magnitude
												if curDist < bestDistance then
													bestDistance = curDist
													bestPlayer = other
													bestPart = hitboxPart
												end
											end
										end
									end
								end
							end
						end
					end
				else
					-- Rage
					local hitboxPart = nil
					local head = other.Character:FindFirstChild("Head")
					local torso = other.Character:FindFirstChild("UpperTorso")
						or other.Character:FindFirstChild("Torso")

					if Library.Flags.rage_hb == "Prefer safe" then
						if head or torso then
							if head and torso then
								local headPos, headOn = camera:WorldToViewportPoint(head.Position)
								local torsoPos, torsoOn = camera:WorldToViewportPoint(torso.Position)
								if headOn and torsoOn then
									local headDist = (Vector2.new(headPos.X, headPos.Y) - Vector2.new(mouse.X, mouse.Y)).Magnitude
									local torsoDist = (Vector2.new(torsoPos.X, torsoPos.Y) - Vector2.new(
										mouse.X,
										mouse.Y
									)).Magnitude
									hitboxPart = (headDist < torsoDist) and head or torso
								elseif headOn then
									hitboxPart = head
								elseif torsoOn then
									hitboxPart = torso
								end
							else
								-- If only one exists, prefer that one
								hitboxPart = head or torso
							end
						end
					elseif Library.Flags.rage_hb == "Head" then
						hitboxPart = head
					elseif Library.Flags.rage_hb == "Body" then
						hitboxPart = torso
					end

					if hitboxPart then
						local screenP, onS = camera:WorldToViewportPoint(hitboxPart.Position)
						if onS then
							local curDist = (Vector2.new(screenP.X, screenP.Y) - Vector2.new(mouse.X, mouse.Y)).Magnitude
							if curDist < bestDistance then
								bestDistance = curDist
								bestPlayer = other
								bestPart = hitboxPart
							end
						end
					end
				end
			end
		end
	end

	return bestPlayer, bestPart
end

local function getDirection(Origin, Position)
	return (Position - Origin).Unit * 1000
end

local WorldToScreen = camera.WorldToScreenPoint

function nocturnal:getPositionOnScreen(Vector): ()
	local Vec3, OnScreen = WorldToScreen(camera, Vector)
	return Vector2.new(Vec3.X, Vec3.Y), OnScreen
end

local GetMouseLocation = inputService.GetMouseLocation
local FindFirstChild = game.FindFirstChild
function nocturnal:getMousePosition()
	return GetMouseLocation(inputService)
end

local function getClosestPlayer()
	local Players = game:GetService("Players")
	local UIS = game:GetService("UserInputService")
	local RunService = game:GetService("RunService")
	local LocalPlayer = Players.LocalPlayer
	local Camera = workspace.CurrentCamera

	local mousePos = UIS:GetMouseLocation()
	local closestDistance = math.huge
	local closestHead = nil
	local closestPlayer = nil

	for _, player in Players:GetPlayers() do
		if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
			local head = player.Character.Head
			local screenPos, onScreen = Camera:WorldToScreenPoint(head.Position)
			if
				true --[[onScreen]]
			then
				local distance = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(mousePos.X, mousePos.Y)).Magnitude
				if distance < closestDistance then
					closestDistance = distance
					closestHead = head
					closestPlayer = player
				end
			end
		end
	end

	return closestHead
end

-- [[ main ]]

nocturnal.circle = nocturnal:Draw("Circle", {
	Transparency = 1,
	Thickness = 1,
	NumSides = 360,
	Radius = 50,
	Position = Vector2.new(0, 0),
	Visible = false,
	Color = Color3.fromRGB(255, 0, 0),
})

local isDown = false

inputService.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		isDown = true
	end
end)

inputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		isDown = false
		for i = 1, #nocturnal.points do
			nocturnal.points[i].Visible = false
		end
	end
end)

-- [[ smoothing functions ]]

local currentAim = Vector2.new(mouse.X, mouse.Y)
local bezierProgress = 0
local bezierStart = currentAim
local bezierEnd = currentAim
local control1 = currentAim
local control2 = currentAim

function nocturnal:cubicBezier(p0, p1, p2, p3, t)
	return (1 - t) ^ 3 * p0 + 3 * (1 - t) ^ 2 * t * p1 + 3 * (1 - t) * t ^ 2 * p2 + t ^ 3 * p3
end

function nocturnal:generateBezierCurve(startPos, endPos)
	local distance = (endPos - startPos).Magnitude
	local curveHeight = math.clamp(distance / 4, 50, 200)

	local offset1 = Vector2.new(math.random(-curveHeight, curveHeight), -curveHeight)
	local offset2 = Vector2.new(math.random(-curveHeight, curveHeight), -curveHeight)

	control1 = startPos + offset1
	control2 = startPos + offset2
	bezierStart = startPos
	bezierEnd = endPos
	bezierProgress = 0
end

table.insert(
	nocturnal.threads,
	Library:CreateThread(function()
		-- [[ legitbot thread ]]
		table.insert(
			nocturnal.connections,
			runService.RenderStepped:Connect(function(deltaTime)
				nocturnal.circle.Position = inputService:GetMouseLocation()
				nocturnal.circle.Visible = Library.Flags.aim_fov

				if Library.Flags.aim_enabled then
					local key = Library.Flags.aim_activate == "MouseButton1" and Enum.UserInputType.MouseButton1
						or Enum.UserInputType.MouseButton2

					if inputService:IsMouseButtonPressed(key) then
						local targetPlayer, targetPart = nocturnal:findBestTarget()

						if targetPlayer and targetPart then
							local pos, onScreen = camera:WorldToScreenPoint(targetPart.Position)

							if onScreen then
								local magnitude = Vector2.new(pos.X - mouse.X, pos.Y - mouse.Y)
								local smooth = math.max(1, Library.Flags.aim_smoothing)

								if Library.Flags.aim_smoothing == 0 then
									mousemoverel(magnitude.x, magnitude.y)
								else
									local method = Library.Flags.aim_st

									if method == "Linear" then
										mousemoverel(magnitude.x / smooth, magnitude.y / smooth)
									elseif method == "Exponential" then
										local factor = 1 - math.exp(-smooth * deltaTime)
										mousemoverel(magnitude.x * factor, magnitude.y * factor)
									elseif method == "EaseInOut" then
										local factor = math.sin((1 / smooth) * (math.pi / 2))
										mousemoverel(magnitude.x * factor, magnitude.y * factor)
									elseif method == "DistanceCurve" then
										local distance = magnitude.Magnitude
										local factor = math.clamp(distance / 100, 0.05, 1) / smooth
										local move = Vector2.new(magnitude.X * factor, magnitude.Y * factor)

										mousemoverel(move.X, move.Y)
									elseif method == "ComplexCurve" then
										if not nocturnal.lastMove then
											nocturnal.lastMove = Vector2.new(0, 0)
										end
										local distance = magnitude.Magnitude
										local smoothFactor = math.max(1, smooth)
										local distanceFactor = math.clamp(distance / 150, 0.05, 1)
										local expFactor = 1 - math.exp(-deltaTime / smoothFactor)
										local easeFactor = math.sin(expFactor * math.pi / 2)

										local move = (magnitude * distanceFactor * easeFactor)

										move = (move + nocturnal.lastMove) / 2
										nocturnal.lastMove = move

										mousemoverel(move.X, move.Y)
									elseif method == "WeightedAverage" then
										if not nocturnal.lastMove then
											nocturnal.lastMove = Vector2.new(0, 0)
										end

										local move = (magnitude / smooth + nocturnal.lastMove) / 2
										mousemoverel(move.x, move.y)
										nocturnal.lastMove = move
									end
								end
							end
						end
					end
				end

				if Library.Flags.m_bhop then
					if inputService:IsKeyDown(Enum.KeyCode.Space) then
						nocturnal.action("jump", Enum.UserInputState.Begin)
					end
				end

				if Library.Flags.world_weather then
					if nocturnal:isAlive(player) then
						if not WeatherPart then
							return
						end
						local character = player.Character
						local hrp = character and character:FindFirstChild("HumanoidRootPart")
						if hrp then
							WeatherPart.Position = hrp.Position + Vector3.new(0, 35, 0)
						end
					end
				end

				if Library.Flags.ro_traj and nocturnal:isAlive(player) and player:FindFirstChild("Gun") then
					if not table.find(nocturnal.grenades, player.Gun.Value) then
						return
					end
					if not isDown then
						return
					end

					local local_character = player.Character
					local head = local_character:FindFirstChild("Head")
					if not head then
						return
					end
					local origin = head.Position
					local unit_ray = camera:ScreenPointToRay(mouse.X, mouse.Y)
					local target = unit_ray.Origin + unit_ray.Direction * 500
					local throw_power = 10
					local gravity = 0.65
					local wind = Vector3.new(0, 0, 0)

					nocturnal:Predict(origin, target, throw_power, wind)
				end
			end)
		)
	end)
)

-- [[ no flash thread ]]
table.insert(
	nocturnal.threads,
	Library:CreateThread(function()
		while task.wait() do
			if Library.Flags.world_noflash then
				local gui = player.PlayerGui
				for idx, element in gui:GetChildren() do
					if string.find(string.lower(element.Name), "flash") then
						if element:IsA("ScreenGui") then
							element.Enabled = false
						end

						if element:IsA("GuiObject") then
							element.Visible = false
						end
					end
				end
			end
		end
	end)
)

-- [[ esp thread ]]
table.insert(
	nocturnal.threads,
	Library:CreateThread(function()
		while task.wait() do
			nocturnal.sense.teamSettings.enemy.enabled = Library.Flags.esp_enabled

			-- boxes
			nocturnal.sense.teamSettings.enemy.box = Library.Flags.esp_boxes
			nocturnal.sense.teamSettings.enemy.boxColor[1] = Library.Flags.esp_boxcolor

			-- box fill
			nocturnal.sense.teamSettings.enemy.boxFill = Library.Flags.esp_boxfill
			nocturnal.sense.teamSettings.enemy.boxFillColor[1] = Library.Flags.esp_fillcolor

			-- health bars
			nocturnal.sense.teamSettings.enemy.healthBar = Library.Flags.esp_health
			nocturnal.sense.teamSettings.enemy.healthyColor = Library.Flags.esp_healthcolor

			-- names
			nocturnal.sense.teamSettings.enemy.name = Library.Flags.esp_names
			nocturnal.sense.teamSettings.enemy.nameColor[1] = Library.Flags.esp_namecolor

			-- skeleton
			nocturnal.sense.teamSettings.enemy.skeleton = Library.Flags.esp_skeleton
			nocturnal.sense.teamSettings.enemy.skeletonColor[1] = Library.Flags.esp_skeletoncolor

			-- distance
			nocturnal.sense.teamSettings.enemy.distance = Library.Flags.esp_dist
			nocturnal.sense.teamSettings.enemy.distanceColor[1] = Library.Flags.esp_distcolor

			-- offscreen arrows
			nocturnal.sense.teamSettings.enemy.offScreenArrow = Library.Flags.esp_arr
			nocturnal.sense.teamSettings.enemy.offScreenArrowColor[1] = Library.Flags.esp_arrcolor
		end
	end)
)

-- troll Are you messing with me?
local function removeAdorns(part)
	if not part then
		return
	end
	for _, obj in part:GetChildren() do
		if obj.Name == "Chams" or obj.Name == "Glow" then
			obj:Destroy()
		end
	end
end

local function removeCharChams(char)
	if not char then
		return
	end
	for _, p in char:GetChildren() do
		if p:IsA("BasePart") then
			removeAdorns(p)
		end
	end
end

function nocturnal:clearAllChams()
	for _, plr in playerService:GetPlayers() do
		if plr == player then
			continue
		end

		local char = plr.Character
		if not char then
			continue
		end

		for _, inst in char:GetDescendants() do
			if inst.Name == "Chams" or inst.Name == "Glow" or inst:IsA("Highlight") or inst:IsA("HandleAdornment") then
				inst:Destroy()
			end
		end
	end

	table.clear(nocturnal.laminateTransparency) --for the 1000000000th TIM<E FUCK THIS
end

local lastEnabled = false
nocturnal.laminateTransparency = {} -- i couldve just taken the easy route, but no.

local Vec3, CFrameNew, InstanceNew, Color3New = Vector3.new, CFrame.new, Instance.new, Color3.new -- ported from rivals vers sry

do
	local LastEnabled = false

	local function RemoveAdorns(Part)
		if not Part then
			return
		end
		local Children = Part:GetChildren()

		for i = 1, #Children do
			local Obj = Children[i]
			if Obj.Name == "Chams" or Obj.Name == "Glow" then
				Obj:Destroy()
			end
		end
	end

	local function RemoveCharChams(Char)
		if not Char then
			return
		end
		local Children = Char:GetChildren()

		for i = 1, #Children do
			local P = Children[i]
			if P:IsA("BasePart") then
				RemoveAdorns(P)
			end
		end
	end

	function CreateAdornment(Part, Type, Color, Trans, ZIndex, SizeOffset, Extra)
		Extra = Extra or {} -- yo why tf wat the fuckz

		local Ad
		if Type == "Cylinder" then
			Ad = InstanceNew("CylinderHandleAdornment")
			Ad.Height = Part.Size.Y + (Extra.HeightOffset or 0)
			Ad.Radius = (Part.Size.X * 0.5) + (Extra.RadiusOffset or 0)
			Ad.CFrame = CFrameNew(Vec3(), Vec3(0, 1, 0))
		elseif Type == "Box" then
			Ad = InstanceNew("BoxHandleAdornment")
			Ad.Size = Part.Size + (SizeOffset or Vec3(0, 0, 0))
		elseif Type == "Wireframe" then
			Ad = InstanceNew("WireframeHandleAdornment")
			Ad.Adornee = Part
			Ad.AlwaysOnTop = true
			Ad.Thickness = Extra.Thickness or 1
			Ad.ZIndex = ZIndex or 1
			Ad.Color3 = Color
			Ad.Parent = Part
			return Ad
		else
			error("err cus: " .. tostring(Type))
		end

		Ad.Name = "Chams"
		Ad.AlwaysOnTop = true
		Ad.ZIndex = ZIndex
		Ad.Adornee = Part
		Ad.Color3 = Color
		Ad.Transparency = Trans or 0
		if Extra.Shading then
			Ad.Shading = Extra.Shading
		end

		Ad.Parent = Part

		return Ad
	end

	Library:CreateThread(function()
		while task.wait(2) do
			local Enabled = Library.Flags["echams_enabled"]

			if not Enabled and LastEnabled then
				nocturnal:clearAllChams()
			end

			LastEnabled = Enabled
			if not Enabled then
				continue
			end
			--[[
			Library.Flags.chams_etype
		local mainColor = Library.Flags.chams_ecolor
		local glowColor = Library.Flags.chams_eocolor
			]]

			local ChamsType = Library.Flags.chams_etype
			local MainColor = Library.Flags.chams_ecolor
			local GlowColor = Library.Flags.chams_eocolor
			local Trans = Library.Flags.chams_ealpha

			local Players = playerService:GetPlayers()
			for i = 1, #Players do
				local Plr = Players[i]
				if Plr == player then
					continue
				end
				if not nocturnal:isTarget(Plr) then
					continue
				end

				local Char = Plr.Character
				if not Char or not nocturnal:isAlive(Plr) then
					RemoveCharChams(Char)
					continue
				end

				local Parts = nocturnal.parts
				for j = 1, #Parts do
					local Name = Parts[j]
					local Part = Char:FindFirstChild(Name)
					if not Part or not Part:IsA("BasePart") or Part.Transparency >= 1 then
						continue
					end

					RemoveAdorns(Part)

					if ChamsType == "Materialistic" then
						local SA = Part:FindFirstChildOfClass("SurfaceAppearance")
						if SA then
							SA:Destroy()
						end
						if Part.Name:find("Sleeve") then
							local Children = Part:GetChildren()
							for k = 1, #Children do
								local D = Children[k]
								if D:IsA("Decal") or D:IsA("Texture") then
									D:Destroy()
								end
							end
						end
						Part.Material = Enum.Material.ForceField
						Part.Color = MainColor
					elseif
						ChamsType == "BoxHandleAdornment"
						or ChamsType == "OutlineGlow"
						or ChamsType == "Glow"
						or ChamsType == "LayeredGlow"
					then
						local Ad, Glow
						local IsHead = Name == "Head"

						if ChamsType == "Glow" or ChamsType == "LayeredGlow" then
							local BaseColor = (ChamsType == "Glow")
									and Color3New(MainColor.R * 5, MainColor.G * 5, MainColor.B * 5)
								or Color3New(GlowColor.R * 5, GlowColor.G * 5, GlowColor.B * 5)
							Ad = CreateAdornment(
								Part,
								IsHead and "Cylinder" or "Box",
								BaseColor,
								-1,
								IsHead and 10 or 9,
								Vec3(0.03, 0.03, 0.03),
								{ Shading = Enum.AdornShading.XRayShaded }
							)
							if ChamsType == "LayeredGlow" then
								CreateAdornment(
									Part,
									IsHead and "Cylinder" or "Box",
									MainColor,
									Trans,
									IsHead and 10 or 10,
									Vec3(0.02, 0.02, 0.02)
								)
							end
						else
							if IsHead then
								Ad = CreateAdornment(
									Part,
									"Cylinder",
									MainColor,
									Trans,
									4,
									nil,
									{ HeightOffset = 0.3, RadiusOffset = 0.2 }
								)
								if Library.Flags["echams_oenabled"] and ChamsType ~= "Materialistic" then
									Glow = Ad:Clone()
									Glow.Name = "Glow"
									Glow.ZIndex = 3
									Glow.Color3 = GlowColor
									Glow.Height += 0.13
									Glow.Radius += 0.13
									Glow.Parent = Part
								end
							else
								Ad = CreateAdornment(Part, "Box", MainColor, Trans, 4, Vec3(0.02, 0.02, 0.02))
								if Library.Flags["echams_oenabled"] then
									Glow = Ad:Clone()
									Glow.Name = "Glow"
									Glow.ZIndex = 3
									Glow.Color3 = GlowColor
									Glow.Size += Vec3(0.13, 0.13, 0.13)
									Glow.Parent = Part
								end
							end
						end
					elseif ChamsType == "Wireframe" then
						local Ad = Part:FindFirstChild("Chams") or CreateAdornment(Part, "Wireframe", MainColor, 0, 1)
						Ad.Color3 = MainColor
						Ad:Clear()
						local Corners = nocturnal:getCorners(Part)
						local Edges = nocturnal.edges
						local Pts = {}
						for k = 1, #Edges do
							local E = Edges[k]
							Pts[#Pts + 1] = Corners[E[1]]
							Pts[#Pts + 1] = Corners[E[2]]
						end
						Ad:AddLines(Pts)
					elseif ChamsType == "Highlight" then
						local Part = Char
						if not Part then
							break
						end
						local Existing = Part:FindFirstChild("Chams")
						if Existing and Existing:IsA("Highlight") then
							Existing.FillColor = MainColor
							Existing.OutlineColor = GlowColor
							Existing.FillTransparency = Trans
						else
							local Highlight = Instance.new("Highlight", Part)
							Highlight.Name = "Chams"
							Highlight.FillColor = MainColor
							Highlight.OutlineColor = GlowColor
							Highlight.FillTransparency = Trans
							Highlight.Adornee = Char
						end
					end
				end
			end
		end
	end)
end

-- [[ character added thread ]]
Library:CreateThread(function()
	table.insert(
		nocturnal.connections,
		player.CharacterAdded:Connect(function(c)
			nocturnal:SwapCharacter(Library.Flags.model_char)
		end)
	)
end)

-- [[ world ]]
Library:CreateThread(function()
	workspace.ChildAdded:Connect(function(c)
		if rawequal(c.Name, "Map") then
			if Library.Flags.world_skybox then
				local a = Library.Flags.world_skyboxcustom
				if a == "None" then
					return
				end

				lightService:FindFirstChildOfClass("Sky"):Destroy()
				local skybox = Instance.new("Sky", Services.Lighting)
				skybox.SkyboxLf = nocturnal.skies[a].SkyboxLf
				skybox.SkyboxBk = nocturnal.skies[a].SkyboxBk
				skybox.SkyboxDn = nocturnal.skies[a].SkyboxDn
				skybox.SkyboxFt = nocturnal.skies[a].SkyboxFt
				skybox.SkyboxRt = nocturnal.skies[a].SkyboxRt
				skybox.SkyboxUp = nocturnal.skies[a].SkyboxUp
				skybox.Name = "skeibocks"
			end

			if Library.Flags.world_nolights then
				task.delay(5, function()
					for idx, light in workspace:GetDescendants() do
						if light:IsA("Light") then
							light:Destroy()
						end
					end
				end)
			end
		end
	end)
end)

-- [[ metatable hooks ]]
local oldNamecall

runService:BindToRenderStep("NCameraStuff", Enum.RenderPriority.Camera.Value + 1, function()
	if Library.Flags.s_ar then
		workspace.CurrentCamera.CFrame = workspace.CurrentCamera.CFrame
			* CFrame.new(0, 0, 0, 1, 0, 0, 0, Library.Flags.s_arr, 0, 0, 0, 1)
	end
end)

table.insert(
	nocturnal.connections,
	camera.ChildAdded:Connect(function(a)
		task.wait(0.1)
		if Library.Flags.vm_enabledchanger then
			if a:IsA("Model") then
				local offset = a:FindFirstChild("Offset")
				if offset and offset:IsA("CFrameValue") then
					offset.Value *= CFrame.new(Library.Flags.vm_x, Library.Flags.vm_y, Library.Flags.vm_z)
				end

				if offset and offset:IsA("Vector3Value") then
					offset.Value *= Vector3.new(Library.Flags.vm_x, Library.Flags.vm_y, Library.Flags.vm_z)
				end
			end
		end
	end)
)

table.insert(
	nocturnal.connections,
	player.PlayerStates.Damage:GetPropertyChangedSignal("Value"):Connect(function(n)
		if Library.Flags.ro_hs then
			local sound = Instance.new("Sound")
			sound.Name = "Hitsound_1"
			sound.Parent = Services.SoundService
			sound.SoundId = nocturnal:getSound(true)
			sound.Volume = 0.8
			sound.PlayOnRemove = true
			sound:Destroy()
		end
	end)
)

table.insert(
	nocturnal.connections,
	player.PlayerStates.Kills:GetPropertyChangedSignal("Value"):Connect(function(n)
		if Library.Flags.ro_ks then
			local sound = Instance.new("Sound")
			sound.Name = "Killsound_1"
			sound.Parent = Services.SoundService
			sound.SoundId = nocturnal:getSound(false)
			sound.Volume = 0.8
			sound.PlayOnRemove = true
			sound:Destroy()
		end
	end)
)

-- [[ yaw/pitch hooks ]]
local yaw
yaw = (math.random() * 180) % 360

table.insert(
	nocturnal.threads,
	Library:CreateThread(function()
		local oldGetYaw

		oldGetYaw = hookfunction(nocturnal.cameraRotation.getYaw, function(...)
			if Library.Flags.aa_enabled and Library.Flags.aa_mode == "Spin" then
				return (tick() * 180) % 360
			end

			return oldGetYaw(...)
		end)
	end)
)

-- [[ attemptfire hook ]]
table.insert(
	nocturnal.threads,
	Library:CreateThread(function()
		local id = getthreadidentity()
		setthreadidentity(2)

		local FireRates = {
			AK47 = 600 / 60,
			M4A4 = 666.67 / 60,
			M4A1 = 600 / 60,
			SG553 = 666 / 60, -- ~11.1 RPS :contentReference[oaicite:4]{index=4}
			AUG = 666 / 60, -- ~11.1 RPS :contentReference[oaicite:5]{index=5}
			FAMAS = 666 / 60, -- ~11.1 RPS :contentReference[oaicite:6]{index=6}
			GalilAR = 666 / 60, -- ~11.1 RPS :contentReference[oaicite:7]{index=7}
			AWP = 41 / 60, -- ~0.683 RPS :contentReference[oaicite:8]{index=8}
			SSG08 = 48 / 60, -- 0.8 RPS :contentReference[oaicite:9]{index=9}
			SCAR20 = 240 / 60, -- 4 RPS :contentReference[oaicite:10]{index=10}
			G3SG1 = 240 / 60, -- 4 RPS :contentReference[oaicite:11]{index=11}
			P90 = 857 / 60, -- ~14.28 RPS :contentReference[oaicite:12]{index=12}
			MP9 = 666 / 60, -- ~11.1 RPS :contentReference[oaicite:13]{index=13}
			UMP45 = 666 / 60, -- ~11.1 RPS :contentReference[oaicite:14]{index=14}
			MAC10 = 666 / 60, -- ~11.1 RPS  :contentReference[oaicite:15]{index=15}
			PPBizon = 666 / 60, -- ~11.1 RPS  :contentReference[oaicite:16]{index=16}
			MP7 = 666 / 60, -- ~11.1 RPS :contentReference[oaicite:17]{index=17}
			MP5SD = 666 / 60, -- ~11.1 RPS :contentReference[oaicite:18]{index=18}
			Glock = 400 / 60, -- ~6.67 RPS :contentReference[oaicite:19]{index=19}
			P250 = 400 / 60, -- ~6.67 RPS :contentReference[oaicite:20]{index=20}
			FiveSeven = 400 / 60, -- ~6.67 RPS :contentReference[oaicite:21]{index=21}
			USP = 400 / 60, -- ~6.67 RPS :contentReference[oaicite:21]{index=AmYisraelAmYisraelChaiiiiiiiii}
			Tec9 = 400 / 60, -- ~6.67 RPS :contentReference[oaicite:22]{index=22}
			CZ75Auto = 400 / 60, -- ~6.67 RPS :contentReference[oaicite:23]{index=23}
			DesertEagle = 267 / 60, -- ~4.45 RPS :contentReference[oaicite:24]{index=24}
			R8Revolver = 300 / 60, -- ~5 RPS :contentReference[oaicite:25]{index=25}
			Negev = 1000 / 60, -- ~16.67 RPS :contentReference[oaicite:26]{index=26}
			M249 = 750 / 60, -- 12.5 RPS :contentReference[oaicite:27]{index=27}
		}

		local lastFireTime = {}

		function canFire(gunName)
			local rate = FireRates[gunName]

			if not rate then
				return false
			end

			local now = tick()
			local last = lastFireTime[gunName] or 0
			local cooldown = 1 / rate

			if now - last >= cooldown then
				lastFireTime[gunName] = now
				return true
			end

			return false
		end

		local oldAttemptFire
		oldAttemptFire = hookfunction(nocturnal.attemptFireFunc, function(...)
			local ok = canFire(player.Gun.Value)
			if Library.Flags.t_bt and ok then
				local rayParams = RaycastParams.new()
				rayParams.FilterType = Enum.RaycastFilterType.Blacklist
				rayParams.FilterDescendantsInstances = { player.Character, camera }

				local barrelOrFlash

				for _, descendant in camera:GetDescendants() do
					if descendant:IsA("BasePart") then
						local nameLower = descendant.Name:lower()
						if nameLower:find("barrel") or nameLower:find("flash") then
							barrelOrFlash = descendant
							break
						end
					end
				end

				local origin = barrelOrFlash and barrelOrFlash.Position
					or (camera.CFrame.Position + camera.CFrame.LookVector * 1.25) + Vector3.new(0, -0.15, 0)
				local direction = camera.CFrame.LookVector * 1000

				local result = workspace:Raycast(origin, direction, rayParams)

				if result then
					nocturnal:Beam(origin, result.Position)
				end
			end

			if Library.Flags.net_bt and ok then
				local btParams = RaycastParams.new()
				btParams.FilterType = Enum.RaycastFilterType.Blacklist
				btParams.FilterDescendantsInstances = {
					player.Character,
					camera,
					workspace.ServerIgnore,
				}
				--btParams.CollisionGroup = "ShootCast"

				local btResult = workspace:Raycast(camera.CFrame.Position, camera.CFrame.LookVector * 1000, btParams)

				if btResult and btResult.Instance then
					local tag = btResult.Instance:FindFirstChild("PlayerName")

					if tag and tag.Value and tag.Value.Character then
						local targetPlayer = tag.Value
						local head = targetPlayer.Character:FindFirstChild("Head")

						if head then
							local confirmParams = RaycastParams.new()
							confirmParams.FilterType = Enum.RaycastFilterType.Blacklist
							confirmParams.FilterDescendantsInstances = {
								player.Character,
								camera,
								workspace.ServerIgnore,
								workspace.Map,
							}
							confirmParams.CollisionGroup = "ShootCast"

							local confirm = workspace:Raycast(
								camera.CFrame.Position,
								head.Position - camera.CFrame.Position,
								confirmParams
							)

							if confirm and confirm.Instance:IsDescendantOf(targetPlayer.Character) then
								nocturnal:FireBullet(targetPlayer, confirm)
							end
						end
					end
				end
			end

			return oldAttemptFire(...)
		end)

		setthreadidentity(8)
	end)
)

-- [[ desync & aa ]]
table.insert(
	nocturnal.connections,
	runService.RenderStepped:Connect(function()
		if Library.Flags.aa_enabled and nocturnal:isAlive(player) then
			local hrp = player.Character.PrimaryPart
			if Library.Flags.aa_enabled then
				local aaMode: string = Library.Flags.aa_mode or "Static"
				local bodyYawFlag: number = Library.Flags.aa_yaw or 180
				local jitterSpeed: number = Library.Flags.aa_js or 10
				local jitterAmount: number = 20
				local jitterTarget: string = "Both"

				local desiredYaw = bodyYawFlag

				if aaMode == "Jitter" then
					if jitterTarget == "Body" or jitterTarget == "Both" then
						desiredYaw = bodyYawFlag + nocturnal:jitterSign(jitterSpeed) * jitterAmount
					end
				elseif aaMode == "Spin" then
					desiredYaw = (tick() * 180) % 360
				elseif aaMode == "Freestanding" then
					desiredYaw = nocturnal:getFreestandYaw()
				end

				local upsideDown = Library.Flags.aa_upside or false
				local roll = upsideDown and math.rad(180) or 0

				local targetHRP = CFrame.new(hrp.Position) * CFrame.Angles(0, math.rad(desiredYaw), 0)
				player.Character.PrimaryPart.CFrame = CFrame.new(player.Character.PrimaryPart.Position)
					* CFrame.Angles(0, math.rad(desiredYaw), roll)

				yaw = desiredYaw
			end
		end

		if Library.Flags.aa_desync then
			if Library.Flags.aa_desyncmode == "Extrapolate" and nocturnal:isAlive(player) then
				task.spawn(function()
					if player.Character and not workspace.Ragdolls:FindFirstChildOfClass("Seat") then
						local _c = player.Character
						if not (_c and _c:FindFirstChild("HumanoidRootPart")) then
						else
							if true then
								local cee = Instance.new("Seat")
								cee.Name = "tRGWJUI%ERjtguihe85ur"
								cee.Parent = workspace.Ragdolls
								cee.Size = Vector3.new(4, 1, 1)
								cee.CanCollide = false
								cee.CollisionGroup = "Smoke"

								local awe = Instance.new("Weld", cee)
								local bb = Instance.new("Weld")
								bb.Name = "geriuzh5eruzhge5"
								bb.Parent = _c.HumanoidRootPart

								cee.CFrame = CFrame.new(_c.HumanoidRootPart.Position)
								cee.CFrame = cee.CFrame
								awe.Part0 = _c.HumanoidRootPart
								awe.Part1 = cee
								_c.HumanoidRootPart.CFrame = CFrame.new(cee.Position)
								bb.Part0 = _c.HumanoidRootPart
								bb.Part1 = cee
								cee.Transparency = 1
							end

							if Library.Flags.aa_desyncv then
								local sf = workspace.Ragdolls
								if not sf:FindFirstChild("FakeChar") then
									local i = Instance.new("Model", sf)
									i.Name = "FakeChar"
									for _, v in _c:GetDescendants() do
										if v:IsA("BasePart") and v.Transparency ~= 1 then
											local a = v:Clone()
											a.CanCollide = false
											a.Parent = i
											v.CanQuery = false
											a.Anchored = true
											a.Color = Library.Flags.aa_desynccolor
											a.Material = "ForceField"
											a.Transparency = 0.6
											a.Reflectance = 0
											if a:IsA("MeshPart") then
												a.TextureID = ""
											end

											for _, c in a:GetChildren() do
												if not c:IsA("SpecialMesh") then
													c:Destroy()
												else
													c.TextureId = ""
												end
											end
										end
									end
								end
							end

							task.delay(tonumber(Library.Flags.desync_ticks) / 1000, function()
								local isThere = workspace.Ragdolls:FindFirstChildOfClass("Seat")
								if isThere then
									isThere:Destroy()
								end

								local sf = workspace.Ragdolls
								--local sf = workspace.Debris.Ignore
								for _, v in sf:GetChildren() do
									if v:IsA("Seat") or v.Name == "FakeChar" then
										v:Destroy()
									end
								end

								if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
									local h = player.Character.HumanoidRootPart
									local existing = h:FindFirstChild("geriuzh5eruzhge5")
									if existing then
										existing:Destroy()
									end
								end
							end)
						end
					end
				end)
			end

			if Library.Flags.aa_desyncmode == "Offset" and nocturnal:isAlive(player) then
				local root = player.Character and player.Character.PrimaryPart or nil
				if root then
					local x = math.random(-25, 25)
					local y = math.random(-25, 25)
					local z = math.random(-25, 25)

					local offset = Vector3.new(x, y, z)
					nocturnal.completeMove:Fire(root.Position + offset)
				end
			end

			if Library.Flags.aa_desyncmode == "Anti-Ragebot" and nocturnal:isAlive(player) then
				local root = player.Character and player.Character.PrimaryPart or nil
				if root then
					local x = math.random(-2500000, 2500000)
					local y = math.random(-2500000, 2500000)
					local z = math.random(-2500000, 2500000)

					local offset = Vector3.new(x, y, z)
					nocturnal.completeMove:Fire(root.Position + offset)
				end
			end
		end
	end)
)

local Old
Old = hookmetamethod(
	nocturnal.remotes.hurtself[1],
	"__namecall",
	newcclosure(function(self, ...)
		local Method = getnamecallmethod()

		if self == nocturnal.remotes.hurtself[1] and Method == "FireServer" and Library.Flags.o_af then
			return
		end

		return Old(self, ...)
	end)
)

--[[rawset(nocturnal.configuration, "velocity", setmetatable({}, {
	__index = function(self, idx)
		local Value = rawget(nocturnal.velocity, idx)

		if idx == "jumpRequestCooldown" and Library.Flags.m_bhop and Library.Flags.m_bhoptype == "Rage" then
			Value = 0
		end

		if idx == "maxSpeed" and Library.Flags.m_speed then
			local multiplier = Library.Flags.m_speedamount
			if type(Value) == "table" then
				local modified = {}
				
				for k, v in pairs(Value) do
					modified[k] = v * multiplier
				end

				return modified
			elseif type(Value) == "number" then
				Value *= multiplier
			end
		end

		if idx == "groundVelocityLimit" and Library.Flags.m_speed then
			Value *= Library.Flags.m_speedamount
		end

		if idx == "crouching" and Library.Flags.m_cd then
			Value.staminaMax = math.huge
			Value.staminaCost = 0
		end

		if idx == "ladderSpeed" and Library.Flags.m_as then
			Value = nocturnal:Units(Library.Flags.m_bhopspeed);
		end

		if idx == "ladderJumpOffSpeed" and Library.Flags.m_as then
			Value = nocturnal:Units(Library.Flags.m_ljs);
		end

		return Value
	end
}));

rawset(nocturnal.configuration, "moveStateMultipliers", setmetatable({}, {
	__index = function(self, idx)
		local Value = rawget(nocturnal.multipliers, idx)

		if idx == "maxSpeed" and Library.Flags.m_speed and Library.Flags.m_speedtype == "Multiplier2" then
			local multiplier = Library.Flags.m_speedamount
			if type(Value) == "table" then
				local modified = {}

				for k, v in pairs(Value) do
					modified[k] = v * multiplier
				end

				return modified
			elseif type(Value) == "number" then
				Value *= multiplier
			end
		end

		return Value
	end
}))]]

-- [[ load sense ]]
nocturnal.sense.Load()
local elapsed = os.clock() - startTime
nocturnal.loadcomplete = true

task.delay(0.8, function()
	Notification.new("Execution took " .. formatMS(elapsed))
end)
