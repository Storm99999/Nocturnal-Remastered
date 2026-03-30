--!nolint
--[[
	                                                                                                                                      
	                                                                                                 88                  88               
	                                        ,d                                                       88                  ""               
	                                        88                                                       88                                   
	8b,dPPYba,    ,adPPYba,    ,adPPYba,  MM88MMM  88       88  8b,dPPYba,  8b,dPPYba,   ,adPPYYba,  88     8b       d8  88  8b,dPPYba,   
	88P'   `"8a  a8"     "8a  a8"     ""    88     88       88  88P'   "Y8  88P'   `"8a  ""     `Y8  88     `8b     d8'  88  88P'    "8a  
	88       88  8b       d8  8b            88     88       88  88          88       88  ,adPPPPP88  88      `8b   d8'   88  88       d8  
	88       88  "8a,   ,a8"  "8a,   ,aa    88,    "8a,   ,a88  88          88       88  88,    ,88  88  888  `8b,d8'    88  88b,   ,a8"  
	88       88   `"YbbdP"'    `"Ybbd8"'    "Y888   `"YbbdP'Y8  88          88       88  `"8bbdP"Y8  88  888    "8"      88  88`YbbdP"'   
	                                                                                                                         88           
	                                                                                                                         88           
	                                                                                                                         
	                                                                                                                         
	NOCTURNAL.VIP
	CREDITS - Author: newguy
]]

local Library
local Notification
local CreateThread, MultiThreadList

local Services: { [string]: any } = setmetatable({}, {
	__index = function(Self: any, Index: string): any
		return cloneref(game.GetService(game, Index))
	end,
})

local Environment: any = (getgenv and function(): any
	return getgenv()
end) or function(): { [string]: any }
	return {}
end

local MakeFolder: (Path: string) -> () = makefolder or function(_: string): () end
local IsFolder: (Path: string) -> boolean = isfolder or function(_: string): boolean
	return false
end
local IsFile: (Path: string) -> boolean = isfile or function(_: string): boolean
	return false
end
local WriteFile: (Path: string, Contents: string) -> () = writefile or function(_: string, _: string): () end
local ReadFile: (Path: string) -> string = readfile or function(_: string): string
	return ""
end
local GetConnections: (Event: any) -> () = getconnections or function(...)
	return {}
end
local GetUpvalue: (Upvalue: any) -> () = debug.getupvalue or function(...) end
local LoadFile: (Path: string) -> () = loadfile or function(_: string): () end
local DetourFn: (any) -> () = hookfunction or function(_: any): () end

local Request: ((Options: any) -> any)? = (syn and syn.request) or (http and http.request) or request

local GetCustomAsset: (Path: string) -> string = getcustomasset or function(_: string): string
	return ""
end

--// math
local Floor: (number) -> number = math.floor
local Ceil: (number) -> number = math.ceil
local Abs: (number) -> number = math.abs
local Sign: (number) -> number = math.sign
	or function(X: number): number
		if X > 0 then
			return 1
		elseif X < 0 then
			return -1
		else
			return 0
		end
	end

local Max: (...number) -> number = math.max
local Min: (...number) -> number = math.min
local Sqrt: (number) -> number = math.sqrt
local Pow: (number, number) -> number = math.pow
local Exp: (number) -> number = math.exp
local Log: (number, number?) -> number = math.log

local Log10: (number) -> number = math.log10 or function(X: number): number
	return Log(X, 10)
end

local Sin: (number) -> number = math.sin
local Cos: (number) -> number = math.cos
local Tan: (number) -> number = math.tan
local Asin: (number) -> number = math.asin
local Acos: (number) -> number = math.acos
local Atan: (number) -> number = math.atan
local Atan2: (number, number) -> number = math.atan2
local Pi: number = math.pi
local Huge: number = math.huge
local Random: (number?, number?) -> number = math.random
local RandomSeed: (number) -> () = math.randomseed or function(_: number): () end
local Rad: (number) -> number = math.rad
local Deg: (number) -> number = math.deg

local Clamp: (number, number, number) -> number = function(Value: number, Min: number, Max: number): number
	return (Value < Min and Min) or (Value > Max and Max) or Value
end

local Lerp: (number, number, number) -> number = math.lerp
	or function(A: number, B: number, T: number): number
		return A + (B - A) * T
	end

local Round: (number) -> number = math.round or function(X: number): number
	return Floor(X + 0.5)
end

local MathIsFinite: (number) -> boolean = (
	math.type
	and function(X: number): boolean
		return math.type(X) == "number" and X == X and X ~= Huge and X ~= -Huge
	end
) or function(_: number): boolean
		return true
	end

--// table
local Insert: <T>(Tbl: { T }, Value: T) -> () = table.insert
local Remove: <T>(Tbl: { T }, Index: number?) -> T? = table.remove
local Concat: (Tbl: { string }, Sep: string?, I: number?, J: number?) -> string = table.concat
local Sort: <T>(Tbl: { T }, Comp: ((T, T) -> boolean)?) -> () = table.sort

local TFind: <T>(Tbl: { T }, Value: T) -> number? = table.find
	or function<T>(T: { T }, V: T): number?
		for I = 1, #T do
			if T[I] == V then
				return I
			end
		end
		return nil
	end

local Clear: (Tbl: { [any]: any }) -> () = table.clear
	or function(T: { [any]: any }): ()
		for K in T do
			T[K] = nil
		end
	end

local Clone: <T>(Tbl: T) -> T = table.clone
	or function<T>(T: T): T
		local N: any = {}
		for K, V in T do
			N[K] = V
		end
		return N
	end

local Move: (Src: { any }, F: number, L: number, Idx: number, Dst: { any }) -> { any } = table.move
	or function(Src: { any }, F: number, L: number, Idx: number, Dst: { any }): { any }
		for I = F, L do
			Dst[Idx + I - F] = Src[I]
		end
		return Dst
	end

local Pack: (...any) -> { n: number, [number]: any } = table.pack
	or function(...: any): { n: number, [number]: any }
		return { n = select("#", ...), ... }
	end

local Freeze: <T>(Tbl: T) -> T = table.freeze or function<T>(_: T): T
	return {} :: any
end

local Unpack: <T>(Tbl: { T }, I: number?, J: number?) -> ...T = table.unpack or unpack
local Create: (number, any?) -> { any } = table.create

--// string
local Byte: (string, number?, number?) -> ...number = string.byte
local Char: (...number) -> string = string.char
local Sub: (string, number, number?) -> string = string.sub
local Len: (string) -> number = string.len
local Lower: (string) -> string = string.lower
local Upper: (string) -> string = string.upper
local Find: (string, string, number?, boolean?) -> (number?, number?, ...string) = string.find
local GSub: (string, string, string | ((...any) -> string), number?) -> (string, number) = string.gsub
local Gmatch: (string, string) -> () -> string? = string.gmatch
local Match: (string, string, number?) -> string? = string.match
local Rep: (string, number, string?) -> string = string.rep
local Reverse: (string) -> string = string.reverse

local Split: (string, string) -> { string } = string.split
	or function(S: string, Sep: string): { string }
		local Out: { string } = {}
		for Part in S:gmatch("([^" .. Sep .. "]+)") do
			Insert(Out, Part)
		end
		return Out
	end

local Format: (string, ...any) -> string = string.format
local Trim: (string) -> string = string.trim or function(S: string): string
	return S:match("^%s*(.-)%s*$") or ""
end

--// os / task
local Time: () -> number = os.time
local Clock: () -> number = os.clock
local Date: (string?, number?) -> any = os.date
local DiffTime: (number, number) -> number = os.difftime

local Tick: () -> number = tick or OsTime
local Time: () -> number = time

local Wait: (number?) -> number = (task and task.wait) or wait
local Spawn: (thread | (() -> ()), ...any) -> () = (task and task.spawn) or spawn
local Defer: ((...any) -> (), ...any) -> () = (task and task.defer)
	or function(F: (...any) -> (), ...: any): ()
		local Co = coroutine.create(F)
		coroutine.resume(Co, ...)
	end

local Delay: (number, (...any) -> (), ...any) -> () = (task and task.delay) or delay
local Cancel: (thread) -> () = (task and task.cancel) or function(_: thread): () end

--// bit
local BitBand: (number, number) -> number = (bit32 and bit32.band)
	or function(A: number, B: number): number
		local R = 0
		local Bit = 1
		for _ = 0, 31 do
			local AA = A % 2
			local BB = B % 2
			if AA == 1 and BB == 1 then
				R += Bit
			end
			A = Floor(A / 2)
			B = Floor(B / 2)
			Bit *= 2
		end
		return R
	end

local BitBor: (number, number) -> number = (bit32 and bit32.bor)
	or function(A: number, B: number): number
		local R = 0
		local Bit = 1
		for _ = 0, 31 do
			local AA = A % 2
			local BB = B % 2
			if AA == 1 or BB == 1 then
				R += Bit
			end
			A = Floor(A / 2)
			B = Floor(B / 2)
			Bit *= 2
		end
		return R
	end

local BitXor: (number, number) -> number = (bit32 and bit32.bxor)
	or function(A: number, B: number): number
		return (A + B) - 2 * (A ^ B)
	end

local BitLshift: (number, number) -> number = (bit32 and bit32.lshift)
	or function(A: number, N: number): number
		return A * (2 ^ N)
	end

local BitRshift: (number, number) -> number = (bit32 and bit32.rshift)
	or function(A: number, N: number): number
		return Floor(A / (2 ^ N))
	end

local BitNot: (number) -> number = (bit32 and bit32.bnot) or function(A: number): number
	return 2 ^ A
end

local function Switch<T>(Value: T, Cases: { [T]: () -> () }, Default: (() -> ())?)
	local CaseFn: (() -> ())? = Cases[Value]

	if CaseFn then
		CaseFn()
	elseif Default then
		Default()
	end
end

local function Pairs<K, V>(tbl: { [K]: V }): () -> (K, V)?
	local nextIndex = nil

	return function()
		nextIndex, value = next(tbl, nextIndex)
		return nextIndex, value
	end
end

--// roblox
local Vec2: (number, number) -> Vector2 = Vector2.new
local Vec3: (number, number, number) -> Vector3 = vector.create
local VecEmpty: (number, number, number) -> Vector3 = vector.zero
local UDim2New: (number, number, number, number) -> UDim2 = UDim2.new
local UDimNew: (number, number) -> UDim = UDim.new
local InstanceNew: (string) -> Instance = Instance.new
local Color3New: (number, number, number) -> Color3 = Color3.new
local Color3FromRGB: (number, number, number) -> Color3 = Color3.fromRGB
local Color3FromHSV: (number, number, number, number) -> Color3 = Color3.fromHSV
local CFrameNew: (...any) -> CFrame = CFrame.new
local CFrameAngles: (...any) -> CFrame = CFrame.Angles
local CFrameLookAt: (...any) -> CFrame = CFrame.lookAt

local ColorSequenceNew: (any) -> ColorSequence = ColorSequence.new
local ColorSequenceKeypointNew: (number, Color3) -> ColorSequenceKeypoint = ColorSequenceKeypoint.new
local NumberSequenceNew: (any) -> NumberSequence = NumberSequence.new
local NumberSequenceKeypointNew: (number, number, number?) -> NumberSequenceKeypoint = NumberSequenceKeypoint.new

--// services
local ContextActionService: ContextActionService = Services.ContextActionService
local HttpService: HttpService = Services.HttpService
local RunService: RunService = Services.RunService
local TweenService: TweenService = Services.TweenService
local ReplicatedStorage: ReplicatedStorage = Services.ReplicatedStorage
local InputService: UserInputService = Services.UserInputService
local ScriptContext: ScriptContext = Services.ScriptContext
local LogService: LogService = Services.LogService
local PlayerService: Players = Services.Players
local Lighting: Lighting = Services.Lighting

local VirtualInputManager = cloneref(InstanceNew("VirtualInputManager"))

local LocalPlayer: Player? = PlayerService.LocalPlayer
local Camera: Instance? = workspace.CurrentCamera
local Mouse: Mouse? = LocalPlayer:GetMouse()

local StartupArgs = Pack((...))[1] or {}
local ThreadList: {} = {}

local Window, Tabs

--//
local WorldToViewportPoint: () -> () = Camera.WorldToViewportPoint
--//

--//
local RayParams = RaycastParams.new()
RayParams.IgnoreWater = true
RayParams.FilterType = Enum.RaycastFilterType.Blacklist
--//

--// hooks
do
	--[[for Index, Connection in GetConnections(LogService.MessageOut) do
		if Connection and Connection.Function then
			DetourFn(Connection.Function, newcclosure(function(...)
				return;
			end));
		end;
	end;

	for Index, Connection in GetConnections(ScriptContext.Error) do
		if Connection and Connection.Function then
			DetourFn(Connection.Function, newcclosure(function(...)
				return;
			end));
		end;
	end;

	DetourFn(Services.Stats.GetMemoryUsageMbForTag, function()
		return coroutine.yield();
	end)]]
end

function CreateHandle(Module: ModuleScript): {}
	assert(Module, "Cannot create handle on nil")

	local Old = getthreadidentity()
	setthreadidentity(3)

	local DwHandle = require(Module)
	setthreadidentity(Old)

	return DwHandle
end

local Nocturnal: {} = {
	["Sense"] = nil,

	["Circle"] = nil,

	["Connections"] = {},

	["PlayerCache"] = {
		["_cache"] = {},
	},

	["Humanizer"] = {
		["Sample"] = nil,
		["Tick"] = Tick(),
		["Index"] = 1,
	},

	["Modules"] = {
		--[[[1] = CreateHandle(ReplicatedStorage.Controllers.InventoryController),
		[2] = CreateHandle(ReplicatedStorage.Components.Weapon.Classes.Bullet),
		[3] = CreateHandle(ReplicatedStorage.Classes.WeaponComponent.Classes.Viewmodel),
		[4] = CreateHandle(ReplicatedStorage.Controllers.CameraController),
        [5] = CreateHandle(ReplicatedStorage.Shared.Spring)]]
	},

	["Parts"] = {
		--// R15
		"Head",
		"HumanoidRootPart",
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

	["Weapons"] = {
		["ak-47"] = {
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
		["m4a4"] = {
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
		["m4a1"] = {
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
		["famas"] = {
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
		["galil"] = {
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
		["aug"] = {
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
		["sg 553"] = {
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
		["ssg 08"] = {
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
		["awp"] = {
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
		["g3sg1"] = {
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
		["scar20"] = {
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
		["negev"] = {
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
		["m249"] = {
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
		["p90"] = {
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
		["ump45"] = {
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
		["mac10"] = {
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
		["mp7"] = {
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
		["mp9"] = {
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
		["ppbizon"] = {
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
		["desert eagle"] = {
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
		["r8revolver"] = {
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
		["fiveseven"] = {
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
		["p250"] = {
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
		["glock-18"] = {
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
		["p2000"] = {
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
		["usp-s"] = {
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

	["Edges"] = {
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

	["Skies"] = {
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

	["Textures"] = {
		["None"] = "",
		["Hex"] = "http://www.roblox.com/asset/?id=488275840",
		["Stars"] = "http://www.roblox.com/asset/?id=7209784983",
	},

	["MoveInput"] = {
		["Forward"] = 0,
		["Right"] = 0,
		["Up"] = 0,
	},

	["RayParameters"] = {
		["Raycast"] = {
			["TotalParams"] = 3,
			["Arguments"] = {
				"Instance",
				"Vector3",
				"Vector3",
				"RaycastParams",
			},
		},
		["FindPartOnRayWithIgnoreList"] = {
			["TotalParams"] = 3,
			["Arguments"] = {
				"Instance",
				"Ray",
				"table",
				"boolean",
				"boolean",
			},
		},
		["FindPartOnRayWithWhitelist"] = {
			["TotalParams"] = 3,
			["Arguments"] = {
				"Instance",
				"Ray",
				"table",
				"boolean",
			},
		},
		["FindPartOnRay"] = {
			["TotalParams"] = 2,
			["Arguments"] = {
				"Instance",
				"Ray",
				"Instance",
				"boolean",
				"boolean",
			},
		},
	},

	["Directions"] = {
		Vec3(-1, 0, 0),
		Vec3(0, 0, 1),
		Vec3(1, 0, 0),
		Vec3(0, 0, -1),
	},

	["Yaws"] = {
		-90,
		0,
		90,
		180,
	},

	["EasingStyles"] = {
		["Linear"] = function(t)
			return t
		end,
		["QuadIn"] = function(t)
			return t ^ 2
		end,
		["QuadOut"] = function(t)
			return t * (2 - t)
		end,
		["QuadInOut"] = function(t)
			if t < 0.5 then
				return 2 * t ^ 2
			else
				return -1 + (4 - 2 * t) * t
			end
		end,
		["CubicIn"] = function(t)
			return t ^ 3
		end,
		["CubicOut"] = function(t)
			local f = t - 1
			return f ^ 3 + 1
		end,
		["CubicInOut"] = function(t)
			if t < 0.5 then
				return 4 * t ^ 3
			else
				local f = 2 * t - 2
				return 0.5 * f ^ 3 + 1
			end
		end,
		["QuartIn"] = function(t)
			return t ^ 4
		end,
		["QuartOut"] = function(t)
			local f = t - 1
			return 1 - f ^ 4
		end,
		["QuartInOut"] = function(t)
			if t < 0.5 then
				return 8 * t ^ 4
			else
				local f = t - 1
				return 1 - 8 * f ^ 4
			end
		end,
		["QuintIn"] = function(t)
			return t ^ 5
		end,
		["QuintOut"] = function(t)
			local f = t - 1
			return f ^ 5 + 1
		end,
		["QuintInOut"] = function(t)
			if t < 0.5 then
				return 16 * t ^ 5
			else
				local f = 2 * t - 2
				return 0.5 * f ^ 5 + 1
			end
		end,
		["SineIn"] = function(t)
			return 1 - Cos(t * Pi / 2)
		end,
		["SineOut"] = function(t)
			return Sin(t * Pi / 2)
		end,
		["SineInOut"] = function(t)
			return -0.5 * (Cos(Pi * t) - 1)
		end,
		["ExpoIn"] = function(t)
			if t == 0 then
				return 0
			else
				return 2 ^ (10 * (t - 1))
			end
		end,
		["ExpoOut"] = function(t)
			if t == 1 then
				return 1
			else
				return 1 - 2 ^ (-10 * t)
			end
		end,
		["ExpoInOut"] = function(t)
			if t == 0 then
				return 0
			elseif t == 1 then
				return 1
			elseif t < 0.5 then
				return 0.5 * 2 ^ (20 * t - 10)
			else
				return 1 - 0.5 * 2 ^ (-20 * t + 10)
			end
		end,
		["CircIn"] = function(t)
			return 1 - Sqrt(1 - t ^ 2)
		end,
		["CircOut"] = function(t)
			return Sqrt(1 - (t - 1) ^ 2)
		end,
		["CircInOut"] = function(t)
			if t < 0.5 then
				return 0.5 * (1 - Sqrt(1 - 4 * t ^ 2))
			else
				return 0.5 * (Sqrt(1 - (2 * t - 2) ^ 2) + 1)
			end
		end,
		["BackIn"] = function(t)
			local s = 1.70158
			return t ^ 3 - s * t ^ 2 * Sin(t * Pi)
		end,
		["BackOut"] = function(t)
			local s = 1.70158
			local f = t - 1
			return f ^ 3 + s * f ^ 2 * Sin(f * Pi) + 1
		end,
		["BackInOut"] = function(t)
			local s = 1.70158 * 1.525
			if t < 0.5 then
				return 0.5 * (2 * t) ^ 2 * ((s + 1) * 2 * t - s)
			else
				local f = 2 * t - 2
				return 0.5 * (f ^ 2 * ((s + 1) * f + s) + 2)
			end
		end,
		["ElasticIn"] = function(t)
			if t == 0 then
				return 0
			elseif t == 1 then
				return 1
			else
				return -2 ^ (10 * (t - 1)) * Sin((t - 1.075) * (2 * Pi) / 0.3)
			end
		end,
		["ElasticOut"] = function(t)
			if t == 0 then
				return 0
			elseif t == 1 then
				return 1
			else
				return 2 ^ (-10 * t) * Sin((t - 0.075) * (2 * Pi) / 0.3) + 1
			end
		end,
		["ElasticInOut"] = function(t)
			if t == 0 then
				return 0
			elseif t == 1 then
				return 1
			elseif t < 0.5 then
				return -0.5 * 2 ^ (20 * t - 10) * Sin((20 * t - 11.125) * (2 * Pi) / 0.45)
			else
				return 0.5 * 2 ^ (-20 * t + 10) * Sin((20 * t - 11.125) * (2 * Pi) / 0.45) + 1
			end
		end,
		["BounceOut"] = function(t)
			if t < 1 / 2.75 then
				return 7.5625 * t ^ 2
			elseif t < 2 / 2.75 then
				local f = t - 1.5 / 2.75
				return 7.5625 * f ^ 2 + 0.75
			elseif t < 2.5 / 2.75 then
				local f = t - 2.25 / 2.75
				return 7.5625 * f ^ 2 + 0.9375
			else
				local f = t - 2.625 / 2.75
				return 7.5625 * f ^ 2 + 0.984375
			end
		end,
		["BounceIn"] = function(t)
			return 1
				- (function(tt)
					if tt < 1 / 2.75 then
						return 7.5625 * tt ^ 2
					elseif tt < 2 / 2.75 then
						local f = tt - 1.5 / 2.75
						return 7.5625 * f ^ 2 + 0.75
					elseif tt < 2.5 / 2.75 then
						local f = tt - 2.25 / 2.75
						return 7.5625 * f ^ 2 + 0.9375
					else
						local f = tt - 2.625 / 2.75
						return 7.5625 * f ^ 2 + 0.984375
					end
				end)(1 - t)
		end,
		["BounceInOut"] = function(t)
			if t < 0.5 then
				local x = t * 2
				return 0.5
					* (
						1
						- (function(tt)
							if tt < 1 / 2.75 then
								return 7.5625 * tt ^ 2
							elseif tt < 2 / 2.75 then
								local f = tt - 1.5 / 2.75
								return 7.5625 * f ^ 2 + 0.75
							elseif tt < 2.5 / 2.75 then
								local f = tt - 2.25 / 2.75
								return 7.5625 * f ^ 2 + 0.9375
							else
								local f = tt - 2.625 / 2.75
								return 7.5625 * f ^ 2 + 0.984375
							end
						end)(1 - x)
					)
			else
				local x = t * 2 - 1
				return 0.5
						* (function(tt)
							if tt < 1 / 2.75 then
								return 7.5625 * tt ^ 2
							elseif tt < 2 / 2.75 then
								local f = tt - 1.5 / 2.75
								return 7.5625 * f ^ 2 + 0.75
							elseif tt < 2.5 / 2.75 then
								local f = tt - 2.25 / 2.75
								return 7.5625 * f ^ 2 + 0.9375
							else
								local f = tt - 2.625 / 2.75
								return 7.5625 * f ^ 2 + 0.984375
							end
						end)(x)
					+ 0.5
			end
		end,
	},

	["EasingStylesList"] = {
		"Linear",
		"QuadIn",
		"QuadOut",
		"QuadInOut",
		"CubicIn",
		"CubicOut",
		"CubicInOut",
		"QuartIn",
		"QuartOut",
		"QuartInOut",
		"QuintIn",
		"QuintOut",
		"QuintInOut",
		"SineIn",
		"SineOut",
		"SineInOut",
		"ExpoIn",
		"ExpoOut",
		"ExpoInOut",
		"CircIn",
		"CircOut",
		"CircInOut",
		"BackIn",
		"BackOut",
		"BackInOut",
		"ElasticIn",
		"ElasticOut",
		"ElasticInOut",
		"BounceIn",
		"BounceOut",
		"BounceInOut",
	},

	["GetSecuredFolder"] = function()
		local a = workspace:FindFirstChild("_securefolder")
		if a then
			return a
		else
			a = InstanceNew("Folder", workspace)
			a.Name = "_securefolder"
			return a
		end
		return nil
	end,

	["LoadComplete"] = false,
}

function Nocturnal:FormatTime(seconds: any): string
	if seconds < 0.001 then
		return Format("%.3f µs", seconds * 1e6)
	elseif seconds < 1 then
		return Format("%.3f ms", seconds * 1000)
	else
		return Format("%.3f s", seconds)
	end
end

function Decompress(Data: string): string
	local MinMatch: number = 3
	local Decoded: string = crypt.base64.decode(Data)

	local Pos: number = 1
	local BitBuffer: number = 0
	local BitCount: number = 0

	local Output: { string } = {}

	local function ReadBits(Count: number): number
		while BitCount < Count do
			local Byte: number? = Decoded:byte(Pos)
			Pos += 1
			BitBuffer = BitLshift(BitBuffer, 8) + (Byte or 0)
			BitCount += 8
		end

		BitCount -= Count
		local Value: number = BitRshift(BitBuffer, BitCount)
		BitBuffer = BitBand(BitBuffer, BitLshift(1, BitCount) - 1)

		return Value
	end

	while Pos <= #Decoded do
		local Flag: number = ReadBits(1)

		if Flag == 0 then
			local Byte: number = ReadBits(8)
			Output[#Output + 1] = Char(Byte)
		else
			local Offset: number = ReadBits(12)
			local Length: number = ReadBits(4) + MinMatch
			local OutLen: number = #Output

			for I = 1, Length do
				Output[OutLen + I] = Output[OutLen + I - Offset]
			end
		end
	end

	return Concat(Output)
end

function Nocturnal:Download(FileName: string, User: string, Repository: string, File: string): {}
	if IsFile(FileName) then
		return
	end

	local Url: string = Format("https://github.com/%s/%s/blob/main/%s?raw=true", User, Repository, File)
	local OK, Statement = pcall(function()
		local Data = game:HttpGetAsync(Url)

		pcall(WriteFile, FileName, Data)
	end)

	if OK then
		return { true, OK, Statement }
	else
		warn("[nocturnal @ downloader]", OK, Statement)
		return { false, OK, Statement }
	end
end

function Nocturnal:GetFileName(Path: string)
	return Path:match("[^\\/]+$") or Path
end

function Nocturnal:Draw(Inst: DrawingObject, Properties: DrawingProperties)
	local Object: any = Drawing.new(Inst)

	for Index, Property in Properties or {} do
		local succ, err = pcall(function()
			Object[Index] = Property
		end)

		if not succ then
			warn(err)
		end
	end

	return Object
end

function Nocturnal:Corners(part: Instance): { Vector3 }
	local s = part.Size * 0.5

	return {
		Vec3(-s.X, -s.Y, -s.Z),
		Vec3(s.X, -s.Y, -s.Z),
		Vec3(-s.X, -s.Y, s.Z),
		Vec3(s.X, -s.Y, s.Z),
		Vec3(-s.X, s.Y, -s.Z),
		Vec3(s.X, s.Y, -s.Z),
		Vec3(-s.X, s.Y, s.Z),
		Vec3(s.X, s.Y, s.Z),
	}
end

function Nocturnal:Raycast(Origin: Vector3, Direction: Vector3)
	local Params = RaycastParams.new()
	Params.FilterDescendantsInstances = { LocalPlayer.Character, Camera }
	Params.FilterType = Enum.RaycastFilterType.Exclude

	return workspace:Raycast(Origin, Direction, Params)
end

function Nocturnal:IsValid(Parameters: {}, Method: {})
	local Matches: number = 0

	if #Parameters < Method.TotalParams then
		return false
	end

	for Index, Argument in Parameters do
		if typeof(Argument) == Method.Arguments[Index] then
			Matches += 1
		end
	end

	return Matches >= Method.TotalParams
end

function Nocturnal:DirectAt(Origin: Vector3, Position: Vector3)
	return (Position - Origin).Unit * 1000
end

function Nocturnal:IsVisible(part: BasePart?, ignoreList: {})
	if not Part or not Part:IsDescendantOf(workspace) then
		return false
	end

	local Origin = Camera.CFrame.Position
	local Direction = Part.Position - Origin

	if Direction.Magnitude <= 1e-6 then
		return true
	end

	RayParams.FilterDescendantsInstances = ignoreList

	local Result = workspace:Raycast(Origin, Direction, RayParams)

	if not Result then
		return true
	end

	return Result.Instance:IsDescendantOf(Part.Parent)
end

do
	local BeamFolder = InstanceNew("Folder", workspace)
	LocalPlayer:GetMouse().TargetFilter = BeamFolder

	local Lifetime = 1.5

	function Nocturnal:Beam(StartPosition: Vector3, EndPosition: Vector3): nil
		if Library.Flags["misc.effects"] then
			--// EndPosition += Vec3(-0.1, 0.2, 0)
			if StartPosition == nil then
				return
			end
			if EndPosition == nil then
				return
			end

			local StartPart = InstanceNew("Part", BeamFolder)
			StartPart.Size = vector.zero
			StartPart.Anchored = true
			StartPart.CanCollide = false
			StartPart.Transparency = 1
			StartPart.Position = StartPosition
			StartPart.CanQuery = false

			local EndPart = InstanceNew("Part", BeamFolder)
			EndPart.Size = vector.zero
			EndPart.Anchored = true
			EndPart.CanCollide = false
			EndPart.CanQuery = false
			EndPart.Transparency = 1
			EndPart.Position = EndPosition

			local StartAttachment = InstanceNew("Attachment", StartPart)
			local EndAttachment = InstanceNew("Attachment", EndPart)

			local BeamInstance = InstanceNew("Beam")
			BeamInstance.Attachment0 = StartAttachment
			BeamInstance.Attachment1 = EndAttachment
			BeamInstance.FaceCamera = true
			BeamInstance.Width0 = 0.5
			BeamInstance.Width1 = 0.5
			BeamInstance.LightEmission = 6
			BeamInstance.Texture = "rbxassetid://446111271"
			BeamInstance.TextureMode = Enum.TextureMode.Static
			BeamInstance.TextureSpeed = 12
			BeamInstance.TextureLength = 1.3
			BeamInstance.Transparency = NumberSequenceNew(Library.Flags["world.btt"])
			BeamInstance.Color = ColorSequenceNew(Library.Flags["world.btc"])
			BeamInstance.Parent = StartPart

			local Tween = TweenInfo.new(5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out, 0, false, 0)
			TweenService:Create(BeamInstance, Tween, { TextureSpeed = 2 }):Play()

			Delay(Lifetime, function()
				StartPart:Destroy()
				EndPart:Destroy()
			end)
		else
			local BeamPart = InstanceNew("Part")

			BeamPart.Anchored = true
			BeamPart.CanCollide = false
			BeamPart.CanQuery = false
			BeamPart.Material = Enum.Material.Neon
			BeamPart.Color = Library.Flags["world.btc"]
			BeamPart.Size = Vec3(0.05, 0.05, (StartPosition - EndPosition).Magnitude)
			BeamPart.CFrame = CFrameNew(StartPosition, EndPosition) * CFrameNew(0, 0, -BeamPart.Size.Z / 2)
			BeamPart.Transparency = Library.Flags["world.btt"]
			BeamPart.Parent = workspace

			--// Out tween
			TweenService:Create(
				BeamPart,
				TweenInfo.new(Lifetime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{ Transparency = 1 }
			):Play()

			Delay(Lifetime + 0.1, function()
				BeamPart:Destroy()
			end)
		end
	end
end

pcall(function()
	Notification = loadstring(
		Decompress(
			"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"
		),
		"Notification Library"
	)()
	Environment().noct_notif = Notification
end)

pcall(function()
	Library = loadstring(
		Decompress(
			"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"
		),
		"UI Library"
	)()
	Environment().Library = Library

	CreateThread, MultiThreadList =
		function(Func: (...any) -> (), ...: any): thread
			local Thread: thread = Library.Utility:CreateThread(Func, ...)
			Insert(ThreadList, Thread)

			return Thread
		end, function(JobList: { any }, ...: any): { thread }
			local Threads: { thread } = {}

			local Count: number = #JobList
			if Count == 0 then
				return Threads
			end

			for i = 1, Count do
				local Item = JobList[i]

				if type(Item) == "table" then
					local Fn: (() -> ())? = Item[1]
					local Args: { any }? = Item[2]
					if type(Fn) == "function" then
						local Thread: thread
						if Args and type(Args) == "table" then
							Thread = Library.Utility:CreateThread(Fn, Unpack(Args))
						else
							Thread = Library.Utility:CreateThread(Fn)
						end

						Insert(Threads, Thread)
						Insert(ThreadList, Thread)
					end
				elseif type(Item) == "function" then
					local Thread: thread = Library.Utility:CreateThread(Item, ...)
					Insert(Threads, Thread)
					Insert(ThreadList, Thread)
				end
			end

			return Threads
		end
end)

pcall(function()
	if not IsFolder("nocturnal_remastered/samples/") then
		MakeFolder("nocturnal_remastered/samples/")
	end
end)

pcall(function()
	Nocturnal.Sense = loadstring(
		Decompress(
			"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"
		),
		"ESP Library"
	)()
	Nocturnal.Sense.Load()
end)

if not Library or not Notification or not Nocturnal.Sense then
	return
end

pcall(function()
	Library:Init()
end)

pcall(function()
	setfflag("AdornShadingAPI", "true")
end)
pcall(function()
	Nocturnal.ViewmodelPath = Camera
end)
pcall(function()
	function Nocturnal:IsFriendly(Player: Player)
		return Player:GetAttribute("Team") == LocalPlayer:GetAttribute("Team")
	end
end)

function Nocturnal:RotationY(CoordinateFrame: CFrame): CFrame
	local X, Y, Z = CoordinateFrame:ToOrientation()

	return CFrameNew(CoordinateFrame.Position) * CFrameAngles(0, Y, 0)
end

function Nocturnal.PlayerCache:Update()
	Clear(self._cache)

	local Players = PlayerService:GetPlayers()

	for Index = 1, #Players do
		local Player: Player? = Players[Index]
		if Player == LocalPlayer then
			continue
		end
		if Nocturnal:IsFriendly(Player) and not Library.Flags["legit.team"] then
			continue
		end

		local Character: Model? = Player.Character
		local BodyParts: {} = {}
		local Alive: boolean = Character
				and Character:FindFirstChildOfClass("Humanoid")
				and Character:FindFirstChildOfClass("Humanoid").Health > 0
			or false

		if Character then
			for j = 1, #Nocturnal.Parts do
				local PartName = Nocturnal.Parts[j]
				local Part = Character:FindFirstChild(PartName)

				if Part then
					BodyParts[PartName] = Part
				end
			end
		end

		self._cache[Player.Name] = {
			["PlayerInstance"] = Player,
			["BodyParts"] = BodyParts,
			["Alive"] = Alive,
		}
	end
end

function Nocturnal:GetPlayers(): { [string]: any }
	return Clone(self.PlayerCache._cache)
end

function Nocturnal:Alive(): boolean
	return LocalPlayer.Character
			and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
			and LocalPlayer.Character:FindFirstChildOfClass("Humanoid").Health > 0
		or false
end

function Nocturnal:ClearAllChams(): ()
	for _, Entry in self.PlayerCache._cache do
		local Char = Entry.PlayerInstance.Character
		if not Char then
			continue
		end

		local Highlight = Char:FindFirstChild("Chams")

		if Highlight and Highlight:IsA("Highlight") then
			Highlight:Destroy()
		end

		for _, Part in Pairs(Entry.BodyParts) do
			if Part and Part.Parent then
				for _, Obj in Part:GetChildren() do
					if Obj.Name == "Chams" or Obj.Name == "Glow" or Obj:IsA("HandleAdornment") then
						Obj:Destroy()
					end
				end
			end
		end
	end
end

function Nocturnal:GetStrafeTarget(MaxDistance: number): BasePart?
	local Character: Model? = LocalPlayer.Character
	if not Character then
		return nil
	end

	local Root: BasePart? = Character:FindFirstChild("HumanoidRootPart") :: BasePart?
	if not Root then
		return nil
	end

	local ClosestRoot: BasePart? = nil
	local ClosestDistance: number = MaxDistance

	for _, Entry: PlayerEntry in Nocturnal.PlayerCache._cache do
		if not Entry.Alive then
			continue
		end

		local EnemyCharacter: Model? = Entry.PlayerInstance.Character
		if not EnemyCharacter then
			continue
		end

		local EnemyRoot: BasePart? = EnemyCharacter:FindFirstChild("HumanoidRootPart") :: BasePart?
		if not EnemyRoot then
			continue
		end

		local Distance: number = (EnemyRoot.Position - Root.Position).Magnitude

		if Distance < ClosestDistance then
			ClosestRoot = EnemyRoot
			ClosestDistance = Distance
		end
	end

	return ClosestRoot
end

function Nocturnal:GetStrafeCFrame(
	StrafeMode: string,
	SelfRoot: BasePart,
	TargetRoot: BasePart,
	Radius: number,
	DeltaTime: number
): CFrame?
	local Result: CFrame? = nil

	Nocturnal._strafeAngle = Nocturnal._strafeAngle or 0
	Nocturnal._strafeAngle += DeltaTime * Library.Flags["move.strafespeed"]

	Switch(StrafeMode, {

		Circle = function()
			local Angle: number = Nocturnal._strafeAngle

			local Offset: Vector3 = Vec3(Cos(Angle) * Radius, 0, Sin(Angle) * Radius)

			Result = CFrameNew(TargetRoot.Position + Offset, TargetRoot.Position)
		end,

		Ontop = function()
			Result = CFrameNew(TargetRoot.Position + Vec3(0, Radius, 0), TargetRoot.Position)
		end,

		Underground = function()
			Result = CFrameNew(TargetRoot.Position - Vec3(0, Radius, 0), TargetRoot.Position)
		end,
	}, function()
		Result = nil
	end)

	return Result
end

function Nocturnal:GetFreestandYaw(): number
	local Torso: BasePart = LocalPlayer.Character.PrimaryPart
	local Origin: Vector3 = Torso.Position

	local RayParams: RaycastParams = RaycastParams.new()
	RayParams.FilterDescendantsInstances = { LocalPlayer.Character, Camera }
	RayParams.FilterType = Enum.RaycastFilterType.Blacklist

	local BestDirection: number = 0
	local MaxDist: number = -Huge

	for i = 1, #Nocturnal.Directions do
		local Result: RaycastResult? = workspace:Raycast(Origin, Nocturnal.Directions[i] * 100, RayParams)
		local Dist: number = Result and (Result.Position - Origin).Magnitude or 100

		if Dist > MaxDist then
			MaxDist = Dist
			BestDirection = Nocturnal.Yaws[i]
		end
	end

	return BestDirection
end

function Nocturnal:FindBestTarget(IsRage: boolean?): (Player?, BasePart?)
	if not Camera or not LocalPlayer then
		return nil, nil
	end

	local IgnoreList = {}
	local Char = LocalPlayer.Character

	if Char then
		IgnoreList[1] = Char
	end

	IgnoreList[#IgnoreList + 1] = Camera

	local Flags = Library.Flags
	local UseFOV = Flags["world.fov"]
	local FOVSize = Flags["world.fov.size"]
	local HitboxMode = Flags["legit.hitbox"]
	local WallCheck = Flags["legit.visible"]

	local MouseX = Mouse.X
	local MouseY = Mouse.Y
	local MouseVec = Vec2(MouseX, MouseY)

	local BestDistance = Huge
	local BestPlayer = nil
	local BestPart = nil

	local List = self.PlayerCache._cache

	for _, Data in self.PlayerCache._cache do
		if not Data.Alive then
			continue
		end

		local Parts = Data.BodyParts
		local Root = Parts.HumanoidRootPart

		if not Root then
			continue
		end

		local RootPos, OnScreen = WorldToViewportPoint(Camera, Root.Position)

		if not OnScreen then
			continue
		end

		if not IsRage and UseFOV then
			local dx = RootPos.X - MouseX
			local dy = RootPos.Y - MouseY
			if (dx * dx + dy * dy) > (FOVSize * FOVSize) then
				continue
			end
		end

		local Head = Parts.Head
		local Torso = Parts.UpperTorso or Parts.Torso
		local Hitbox: BasePart? = nil

		--// Hitbox selection
		if HitboxMode == "Head" then
			Hitbox = Head
		elseif HitboxMode == "Body" then
			Hitbox = Torso
		else
			if Head and Torso then
				local hx, hOn = WorldToViewportPoint(Camera, Head.Position)
				local tx, tOn = WorldToViewportPoint(Camera, Torso.Position)

				if hOn and tOn then
					local hdx = hx.X - MouseX
					local hdy = hx.Y - MouseY
					local tdx = tx.X - MouseX
					local tdy = tx.Y - MouseY

					Hitbox = ((hdx * hdx + hdy * hdy) < (tdx * tdx + tdy * tdy)) and Head or Torso
				else
					Hitbox = hOn and Head or (tOn and Torso)
				end
			else
				Hitbox = Head or Torso
			end
		end

		if not Hitbox then
			continue
		end

		if not IsRage and WallCheck and not self:IsVisible(Hitbox, IgnoreList) then
			continue
		end

		local ScreenPos, Visible = WorldToViewportPoint(Camera, Hitbox.Position)
		if not Visible then
			continue
		end

		local dx = ScreenPos.X - MouseX
		local dy = ScreenPos.Y - MouseY
		local Dist = dx * dx + dy * dy

		if Dist < BestDistance then
			BestDistance = Dist
			BestPlayer = Data.PlayerInstance
			BestPart = Hitbox
		end
	end

	return BestPlayer, BestPart
end

local resolverData: { [number]: ResolverRecord } = {}

local function GetYaw(cf: CFrame): number
	local LookVector = cf.LookVector

	--// yaw = atan2(x, z) in degrees
	return Deg(Atan2(LookVector.X, LookVector.Z))
end

local function ClampAngle(a: number): number
	-- normalize to -180..180
	local x: number = ((a + 180) % 360) - 180

	return x
end

local function GetRecord(p: Player): ResolverRecord
	local id = p.UserId
	local rec = resolverData[id]
	if not rec then
		rec = { history = {}, lastSeenTime = 0, bestOffsetScores = {} }
		resolverData[id] = rec
	end

	return rec
end

function Nocturnal:resolverRecordObservation(p: Player, hrpYaw: number, headYawDelta: number)
	local rec = GetRecord(p)
	Insert(rec.history, 1, { Tick(), hrpYaw, headYawDelta }) -- newest first
	-- trim ts history size
	local maxHistory = Clamp(Library.Flags.rage_rsh or 6, 1, 24)
	while #rec.history > maxHistory do
		Remove(rec.history, #rec.history)
	end

	rec.lastSeenTime = Tick()
end

function Nocturnal:resolverRegisterHit(p: Player, offsetGuess: number)
	if not p then
		return
	end
	local rec = GetRecord(p)
	local rounded = Floor(offsetGuess + 0.5)
	rec.bestOffsetScores[rounded] = (rec.bestOffsetScores[rounded] or 0) + 1
end

local function SampleYaw(p: Player): (number, number)
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

	local hrpYaw = GetYaw(hrp.CFrame)

	local headYawDelta = 0
	if neck then
		local c0 = neck.C0
		local _, _, z = c0:ToEulerAnglesXYZ()
		local head = c:FindFirstChild("Head")
		if head then
			local headYaw = Deg(Atan2(head.CFrame.LookVector.X, head.CFrame.LookVector.Z))
			headYawDelta = ClampAngle(headYaw - hrpYaw)
		else
			headYawDelta = 0
		end
	else
		local head = c:FindFirstChild("Head")
		if head then
			local headYaw = Deg(Atan2(head.CFrame.LookVector.X, head.CFrame.LookVector.Z))
			headYawDelta = ClampAngle(headYaw - hrpYaw)
		else
			headYawDelta = 0
		end
	end

	return hrpYaw, headYawDelta
end

local function ScoreYawExposure(targetPos: Vector3, yawDeg: number): number
	local rad = Rad(yawDeg)
	local dir = Vec3(Sin(rad), 0, Cos(rad))
	local start = targetPos + Vec3(0, 1.5, 0)
	local ignore = { LocalPlayer.Character, Camera }
	local dist = 0
	local rays = 3

	for i = 1, rays do
		local offset = Vec3(0, (i - 2) * 0.2, 0)
		local r = Ray.new(start + offset, dir * 120)
		local hit, pos = workspace:FindPartOnRayWithIgnoreList(r, ignore)
		dist = dist + (hit and (pos - start).Magnitude or 120)
	end

	return dist
end

--// offsets used in brute force x), too lazy to re use TODO: Fix this shit and rewrite
local BRUTE_OFFSETS = { 0, 30, -30, 60, -60, 90, -90, 180 }

function Nocturnal:resolvePlayerYaw(p: Player): number
	if not p or not p.Character then
		return 0
	end
	--// fast exit when resolver disabled
	if not Library.Flags.rage_rs then
		local c = p.Character
		local hrp = c:FindFirstChild("HumanoidRootPart") or c:FindFirstChild("Torso") or c:FindFirstChild("UpperTorso")
		return hrp and GetYaw(hrp.CFrame) or 0
	end

	--// sample current info and record it
	local sample = SampleYaw(p)
	local hrpYaw, headDelta = nil, nil
	if sample then
		hrpYaw, headDelta = sample
		Nocturnal:resolverRecordObservation(p, hrpYaw, headDelta)
	else
		local c = p.Character
		local hrp = c
			and (c:FindFirstChild("HumanoidRootPart") or c:FindFirstChild("Torso") or c:FindFirstChild("UpperTorso"))
		return hrp and GetYaw(hrp.CFrame) or 0
	end

	local rec = GetRecord(p)

	--// resolver mode selection
	local mode = Library.Flags.rage_rsm or "Safe"
	local useLBYChecks = Library.Flags.rage_lby or false

	local velMag = 0
	do
		local humanoidRoot = p.Character
			and (p.Character:FindFirstChild("HumanoidRootPart") or p.Character:FindFirstChild("Torso"))
		if humanoidRoot and humanoidRoot:IsA("BasePart") then
			velMag = (humanoidRoot.Velocity or Vec3(0, 0, 0)).Magnitude
		end
	end

	if useLBYChecks and velMag < 0.5 then
		return hrpYaw
	end

	if mode == "Safe" then
		if Abs(headDelta) < 10 then
			return hrpYaw
		else
			local guess = ClampAngle(hrpYaw + headDelta * 0.5)
			return guess
		end
	end

	if mode == "Brute" then
		local best = hrpYaw
		local bestScore = -Huge
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
			local candYaw = ClampAngle(hrpYaw + off)
			local s = ScoreYawExposure(pos, candYaw)
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

		--// assume head delta is real facing dir; guess by combining hrp + avgDelta hope it works.
		local guess = ClampAngle(hrpYaw + avgDelta)
		return guess
	end

	if mode == "Adaptive" then
		local recScores = rec.bestOffsetScores or {}

		local bestScore, bestOffset = -Huge, nil
		for offsetStr, score in recScores do
			local off = tonumber(offsetStr) or offsetStr
			if score > bestScore then
				bestScore = score
				bestOffset = off
			end
		end
		if bestOffset then
			return ClampAngle(hrpYaw + bestOffset)
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
				local best, bscore = hrpYaw, -Huge
				for _, off in BRUTE_OFFSETS do
					local cand = ClampAngle(hrpYaw + off)
					local s = ScoreYawExposure(pos, cand)
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

function Nocturnal:resolverGetRecord(p: Player)
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

--// sample points on part: center + along its axes to get corners (dk if theres a better solution)
local function samplePointsOnPart(part)
	if not part or not part:IsA("BasePart") then
		return {}
	end
	local size = part.Size
	local center = part.Position
	local cf = part.CFrame
	local samples = {}

	--// center
	samples[#samples + 1] = center

	--// axis
	local localDirs = {
		Vec3(size.X / 2, 0, 0),
		Vec3(-size.X / 2, 0, 0),
		Vec3(0, size.Y / 2, 0),
		Vec3(0, -size.Y / 2, 0),
		Vec3(0, 0, size.Z / 2),
		Vec3(0, 0, -size.Z / 2),
	}
	for _, ld in localDirs do
		samples[#samples + 1] = (cf * CFrameNew(ld)).Position
	end

	--// mid-edge samples (12) to catch thin protrusions (quarter offsets)
	local qx, qy, qz = size.X * 0.25, size.Y * 0.25, size.Z * 0.25
	local midDirs = {
		Vec3(qx, qy, 0),
		Vec3(-qx, qy, 0),
		Vec3(qx, -qy, 0),
		Vec3(-qx, -qy, 0),
		Vec3(qx, 0, qz),
		Vec3(-qx, 0, qz),
		Vec3(qx, 0, -qz),
		Vec3(-qx, 0, -qz),
		Vec3(0, qy, qz),
		Vec3(0, -qy, qz),
		Vec3(0, qy, -qz),
		Vec3(0, -qy, -qz),
	}
	for _, md in midDirs do
		samples[#samples + 1] = (cf * CFrameNew(md)).Position
	end

	--// helps when a small corner is sticking out
	if Camera then
		local toCam = (Camera.CFrame.Position - center)
		if toCam.Magnitude > 0 then
			local offset = Min(part.Size.Magnitude * 0.35, 2)
			samples[#samples + 1] = center + toCam.Unit * offset
		end
	end

	--// clamp sample count a bit (not necessary but keeps perf sane)
	if #samples > 24 then
		--// keep first 24 samples (includes center, tips, mid-edges, camera offset)
		local out = {}
		for i = 1, 24 do
			out[i] = samples[i]
		end
		return out
	end

	return samples
end

function Nocturnal:GetBestVisibleSample(part)
	if not part or not part:IsA("BasePart") then
		return nil, 0
	end

	local startPart = LocalPlayer.Character.Head

	local start = (startPart and startPart.Position) or (Camera and Camera.CFrame.Position) or Vec3(0, 0, 0)
	local samples = samplePointsOnPart(part)
	if #samples == 0 then
		return nil, 0
	end

	local bestScore = -Huge
	local bestPos = nil
	local visibleCount = 0

	for _, s in samples do
		local params = RaycastParams.new()
		params.FilterDescendantsInstances = { LocalPlayer.Character, Camera }
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

		local res = workspace:Raycast(start, dir.Unit * Min(dir.Magnitude, 4000), params)
		local visible = false
		if not res then
			visible = true
		else
			if res.Instance and res.Instance:IsDescendantOf(part.Parent) then
				visible = true
			end
		end

		local facing = 0
		if Camera then
			local toCam = (Camera.CFrame.Position - s)
			if toCam.Magnitude > 0 then
				facing = Clamp((toCam.Unit:Dot((part.CFrame.LookVector * -1)) + 1) / 2, 0, 1)
			end
		end

		local dist = (s - start).Magnitude
		local distFactor = 1 / Max(dist, 1)

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
	local start = (LocalPlayer.Character.Head and LocalPlayer.Character.Head.Position)
		or (Camera and Camera.CFrame.Position)
		or Vec3(0, 0, 0)
	local dir = point - start
	if dir.Magnitude <= 0.001 then
		return true, nil
	end

	local params = RaycastParams.new()
	params.FilterDescendantsInstances = { LocalPlayer.Character, Camera }
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.IgnoreWater = true

	local res = workspace:Raycast(start, dir.Unit * Min(dir.Magnitude, 4000), params)
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
	local startPart = LocalPlayer.Character.Head

	local start = (startPart and startPart.Position) or (Camera and Camera.CFrame.Position) or Vec3(0, 0, 0)
	--//	local start = (head and head.Position) or (cam and cam.CFrame.Position) or Vec3(0,0,0)

	for _, s in samples do
		local params = RaycastParams.new()
		params.FilterDescendantsInstances = { LocalPlayer.Character, Camera }
		params.FilterType = Enum.RaycastFilterType.Exclude
		params.IgnoreWater = true

		local r = workspace:Raycast(start, (s - start).Unit * Min((s - start).Magnitude, 4000), params)
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
				local facing = Clamp((toCam.Unit:Dot((part.CFrame.LookVector * -1)) + 1) / 2, 0, 1)
				camFacingSum = camFacingSum + facing
			end
		end
	end

	local frac = visibleCount / #samples
	local avgFacing = (#samples > 0) and (camFacingSum / #samples) or 0

	return frac, avgFacing
end

function Nocturnal:isVisibleFromHead(part: BasePart): boolean
	if not part or not LocalPlayer.Character.Head then
		return false
	end
	local start = LocalPlayer.Character.Head.Position
	local dir = part.Position - start
	if dir.Magnitude <= 0.001 then
		return true
	end

	local params = RaycastParams.new()
	params.FilterDescendantsInstances = { LocalPlayer.Character, Camera }
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.IgnoreWater = true

	local result = workspace:Raycast(start, dir.Unit * Min(dir.Magnitude, 3000), params)
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

	local bestScore = -Huge
	local bestPart = nil
	local myPos = LocalPlayer.Character.Head and LocalPlayer.Character.Head.Position
		or (Camera and Camera.CFrame.Position)
		or LocalPlayer.Character.PrimaryPart.Position

	for _, cand in candidates do
		local part = cand.part
		if not part then
			continue
		end
		--// skip if invalid
		if not part:IsDescendantOf(p.Character) then
			continue
		end

		local frac, facing = evaluatePartVisibility(part) --// fraction visible, average facing
		local dist = (part.Position - LocalPlayer.Character.PrimaryPart.Position).Magnitude
		local distFactor = 1 / Max(dist, 1)

		--// base priority from mode: head/torso get boosted
		local baseP = cand.basePriority or 1

		--// compute ts:
		--// visible fraction is primary; multiply by facing and add base + dist
		local score = frac * (0.7 + 0.3 * facing) * 100
		score = score + (baseP * 10) + (distFactor * 5)

		--// fully invisible parts get de-prioritized unless autowall allowed
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

CreateThread(function()
	while Wait(1) do
		Nocturnal.PlayerCache:Update()
	end
end)

Insert(
	Nocturnal.Connections,
	PlayerService.PlayerAdded:Connect(function(Player: Player?)
		Nocturnal.PlayerCache:Update()
	end)
)

Insert(
	Nocturnal.Connections,
	PlayerService.PlayerRemoving:Connect(function(Player: Player?)
		Nocturnal.PlayerCache._cache[Player.Name] = nil
	end)
)

--// UI
do
	Window = Library:Window({
		Title = "Nocturnal Remastered - Bloxstrike",
	})

	Tabs = {
		["Legit"] = Window:Tab("Legit", 1),
		["Rage"] = Window:Tab("Rage", 2),
		["Visuals"] = Window:Tab("Visuals", 3),
		["Misc"] = Window:Tab("Misc", 4),
	}

	--// Settings
	Library:CreateSettings(Window)

	--// Legit
	do
		local main = Tabs.Legit:Section("Legitbot", 1, 1)
		local filter = Tabs.Legit:Section("Filters", 2, 1)
		local trigger = Tabs.Legit:Section("Triggerbot", 2, 2)
		local rcs = Tabs.Legit:Section("Recoil Control", 1, 3)

		main:Toggle({ Flag = "legit.enabled", Text = "Enabled" }):Bind({
			Flag = "legit.key",
			Text = "Aimbot",
			Mode = "hold",
			Bind = "NONE",
			Callback = function(E) end,
		})

		main:Toggle({ Flag = "legit.humanizer", Text = "Humanizer" })

		main:Slider({ Flag = "legit.smooth", Text = "Smoothing", Min = 0, Max = 100, Value = 20, Suffix = "%" })

		main:Dropdown({
			Flag = "legit.hitbox",
			Text = "Target Hitbox",
			Values = { "Head", "Body", "Closest" },
			Selected = "Head",
		})

		main:Dropdown({
			Flag = "legit.meth",
			Text = "Smoothing Curve",
			Values = { "Linear", "Exponential", "EaseInOut", "WeightedAverage" },
			Selected = "Linear",
		})

		local SampleDropdown = main:Dropdown({
			Flag = "legit.humansample",
			Text = "Humanizer Sample",
			Values = {},
			Selected = "",
			Callback = function(Sample: string): ()
				if not IsFile("nocturnal_remastered/samples/" .. Sample) then
					return
				end

				local OK, Decode = pcall(function()
					return HttpService:JSONDecode(ReadFile("nocturnal_remastered/samples/" .. Sample))
				end)

				if OK then
					local VecSample: {} = {}

					for Index, Value in Pairs(Decode) do
						VecSample[Index] = Vec2(Value.x, Value.y)
					end

					Nocturnal.Humanizer.Sample = VecSample
					Nocturnal.Humanizer.Index = 1
					Nocturnal.Humanizer.Tick = Tick()
				else
					Nocturnal.Humanizer.Sample = nil
					Nocturnal.Humanizer.Index = 1
					Nocturnal.Humanizer.Tick = Tick()
				end
			end,
		})

		local Files = listfiles("nocturnal_remastered/samples/")
		for _, FullPath in Pairs(Files) do
			SampleDropdown:AddValue(Nocturnal:GetFileName(FullPath))
		end

		CreateThread(function()
			while Wait(3) do
				SampleDropdown:ClearValues()
				local Files = listfiles("nocturnal_remastered/samples/")

				for _, FullPath in Pairs(Files) do
					SampleDropdown:AddValue(Nocturnal:GetFileName(FullPath))
				end
			end
		end)

		main:Dropdown({
			Flag = "legit.cammethod",
			Text = "Method",
			Values = { "Mouse", "Camera" },
			Selected = "Mouse",
		})

		filter:Toggle({ Flag = "legit.team", Text = "Ignore Team" })
		filter:Toggle({ Flag = "legit.visible", Text = "Visibility Check" })
		filter:Toggle({ Flag = "world.fov", Text = "Visualizers" })

		filter:Slider({
			Flag = "world.fov.size",
			Text = "FOV Size",
			Min = 10,
			Max = 500,
			Value = 150,
			Suffix = "°",
			Callback = function(Value)
				if Nocturnal.Circle then
					Nocturnal.Circle.Radius = Value
				end
			end,
		})

		filter:Dropdown({
			Flag = "legit.deadzone.type",
			Text = "Dead Zone Type",
			Values = { "Hard", "Soft" },
			Selected = "Soft",
		})

		filter:Slider({
			Flag = "legit.deadzone",
			Text = "Dead Zone",
			Min = 0,
			Max = 25,
			Value = 3,
			Suffix = "px",
		})

		trigger:Toggle({ Flag = "trigger.enabled", Text = "Enabled" })
		trigger:Toggle({ Flag = "trigger.randomize", Text = "Randomize Delay" })
		trigger:Slider({ Flag = "trigger.delay", Text = "Delay", Min = 0, Max = 250, Value = 50, Suffix = "ms" })
		trigger:Slider({ Flag = "trigger.delaymax", Text = "Delay Max", Min = 0, Max = 250, Value = 50, Suffix = "ms" })

		--// RCS, Please, do not question this. It is ported from Nocturnal v1, and is fragile.
		local smoothX = 0
		local smoothY = 0
		local SMOOTHING = 0.15
		local enabled = false
		local strength = 15
		local InputConnection: RBXScriptConnection
		local currentIndex = 1
		local lastGunName = ""
		local remainderX = 0
		local remainderY = 0
		local lastShootTime = 0
		local isHolding = false

		local guns = {}

		local function Normalize(str)
			return str:lower():gsub("%W", "")
		end

		local function AddGun(name, id, rpm, pattern): nil
			local gunData = {
				name = name,
				id = id,
				rpm = rpm,
				recoilPattern = pattern,
			}

			guns[Normalize(name)] = gunData
		end

		AddGun("AUG", 1, 600, {
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

		AddGun("AK-47", 223, 600, {
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
		AddGun("M4A1", 38965, 666, m4_pattern)
		AddGun("M4A4", 38965, 666, m4_pattern)

		AddGun("Galil", 51191, 666, {
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

		AddGun("FAMAS", 39623, 666, {
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

		AddGun("DesertEagle", 12345, 267, {
			{ 0, 0 },
			{ 26.815728296829917, 31.242901752599302 },
			{ -3.317230599950525, 20.126243666122814 },
			{ -4.224166803398816, 20.04172356428791 },
			{ -6.864289752463892, 27.10308534055652 },
			{ 5.954570401516337, 49.902621304156646 },
		})

		AddGun("SG553", 43500, 545, {
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

		AddGun("P90", 6213, 857, {
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

		AddGun("TEC-9", 789, 500, {
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

		AddGun("MP7", 61649, 750, {
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

		AddGun("Bizon", 36387, 750, {
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

		AddGun("MAC10", 34079, 800, {
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

		AddGun("UMP", 59299, 666, {
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

		AddGun("MP9", 50729, 857, mp9_pattern)
		AddGun("MP9_alt", 50729, 857, mp9_pattern)

		AddGun("Negev", 57966, 800, {
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

		local function GetGun()
			local gunObj = Nocturnal.Modules[1].getCurrentEquipped() or nil

			if gunObj then
				local currentGun = gunObj.Name

				if currentGun == "" or currentGun == "USP-S" or currentGun == "Zeus" then
					return nil
				end

				return guns[Normalize(currentGun)]
			end

			return guns["ak47"]
		end

		local function ResetRecoil()
			currentIndex = 1
			isHolding = false
			remainderX = 0
			remainderY = 0
			smoothX = 0
			smoothY = 0
			lastShootTime = 0
		end

		InputService.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				isHolding = true
			end
		end)

		InputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				isHolding = false
				ResetRecoil()
			end
		end)

		Insert(
			Nocturnal.Connections,
			RunService.RenderStepped:Connect(function()
				if not enabled then
					return
				end

				if Library.Flags["rcs.method"] ~= "CS:GO" then
					return
				end

				if not isHolding then
					return
				end

				local gun = GetGun()

				if not gun then
					ResetRecoil()
					return
				end

				local now = Tick()
				local interval = 60 / gun.rpm

				if now - lastShootTime >= interval then
					lastShootTime = now

					local pattern = gun.recoilPattern
					local curr = pattern[currentIndex]
					local prev = pattern[currentIndex - 1] or { 0, 0 }

					if curr then
						local mul = Library.Flags["rcs.strength"] / 100

						local moveX = ((curr[1] - prev[1]) * mul) + remainderX
						local moveY = ((curr[2] - prev[2]) * mul) + remainderY

						local fx = Floor(moveX + 0.5)
						local fy = Floor(moveY + 0.5)

						remainderX = moveX - fx
						remainderY = moveY - fy

						smoothX = smoothX + fx
						smoothY = smoothY + fy

						if currentIndex < #pattern then
							currentIndex = currentIndex + 1
						end
					end
				end

				local smoothing = Clamp((Library.Flags["rcs.strength"] / 100) * 0.15, 0.02, 0.3)

				if Abs(smoothX) > 0.01 or Abs(smoothY) > 0.01 then
					local dx = smoothX * smoothing
					local dy = smoothY * smoothing

					local ix = Floor(dx + 0.5)
					local iy = Floor(dy + 0.5)

					smoothX = smoothX - ix
					smoothY = smoothY - iy

					mousemoverel(ix, iy)
				end
			end)
		)

		function Nocturnal.ControlRecoil(input, gameProcessed)
			if not enabled then
				return
			end

			if input.UserInputType == Enum.UserInputType.MouseButton1 and not Library.Open then
				if rawequal(Library.Flags["rcs.method"], "Linear") then
					ResetRecoil()

					isHolding = false

					if Nocturnal:Alive() then
						while InputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
							local moveY = Max(strength / 100 * 10, 1)
							mousemoverel(0, moveY)
							Wait()
						end
					end
				end
			end
		end

		rcs:Toggle({
			Flag = "rcs.enabled",
			Text = "Enable",
			Callback = function(Value: boolean)
				enabled = Value

				if enabled then
					InputConnection = InputService.InputBegan:Connect(Nocturnal.ControlRecoil)
				else
					if InputConnection then
						InputConnection:Disconnect()
						InputConnection = nil
					end
				end
			end,
		})

		rcs:Slider({
			Flag = "rcs.strength",
			Text = "Strength",
			Min = 1,
			Max = 100,
			Value = 100,
			Increment = 1,
			Suffix = "%",
			Callback = function(Value: number): ()
				strength = Value
			end,
		})

		rcs:Dropdown({
			Flag = "rcs.method",
			Text = "Recoil Method",
			Values = { "Linear", "CS:GO" },
			Selected = "Linear",
		})
	end

	--// Rage
	do
		local main = Tabs.Rage:Section("Ragebot", 1, 1)
		local resolver = Tabs.Rage:Section("Resolver", 1, 2)
		local antiaim = Tabs.Rage:Section("Anti-Aim", 2, 2)

		local RagebotConn

		main:Toggle({
			Flag = "rage_as",
			Text = "Auto Shoot",
			Risky = true,
			Callback = function(Enabled: boolean): ()
				if Enabled then
					RagebotConn = RunService.Heartbeat:Connect(function(Dt: number): ()
						if not Nocturnal:Alive() then
							return
						end

						local LocalCharacter: Model? = LocalPlayer.Character
						if not LocalCharacter then
							return
						end

						local LocalHRP: BasePart? = LocalCharacter:FindFirstChild("HumanoidRootPart")
						if not LocalHRP then
							return
						end

						local BestDist: number = Huge
						local BestPlayer: Player? = nil

						for _, Entry in Nocturnal.PlayerCache._cache do
							if not Entry.Alive then
								continue
							end

							local PlayerInstance: Player = Entry.PlayerInstance
							local Character: Model? = PlayerInstance.Character
							if not Character then
								continue
							end

							local PlayerHRP: BasePart? = Entry.BodyParts.HumanoidRootPart
								or Entry.BodyParts.UpperTorso
								or Entry.BodyParts.Torso

							if PlayerHRP then
								local Dist: number = (PlayerHRP.Position - LocalHRP.Position).Magnitude
								if Dist < BestDist then
									BestDist = Dist
									BestPlayer = PlayerInstance
								end
							end
						end

						if not BestPlayer then
							return
						end

						local TargetPart: BasePart? = chooseHitPart(BestPlayer)
						if not TargetPart then
							return
						end

						local Frac: number, _: any = evaluatePartVisibility(TargetPart)
						local Visible: boolean = Frac > 0

						if not Visible then
							if not Library.Flags.rage_aw then
								return
							end

							local Origin: Vector3 = LocalCharacter.Head.Position
							local Dir: Vector3 = TargetPart.Position - Origin
							if Dir.Magnitude <= 0.001 then
								return
							end

							local Ignore: { Instance } = { LocalCharacter, Camera }
							local WallsHit: number = 0
							local CanHit: boolean = false
							local UnitDir: Vector3 = Dir.Unit

							while WallsHit < 4 do
								local Params: RaycastParams = RaycastParams.new()
								Params.FilterType = Enum.RaycastFilterType.Exclude
								Params.FilterDescendantsInstances = Ignore
								--Params.CollisionGroup = "Me Arse Died In The Gizzy Genocide in Palpatine evil israel...";
								Params.IgnoreWater = true

								local Result: RaycastResult? = workspace:Raycast(Origin, UnitDir * 10000, Params)
								if not Result then
									break
								end

								if Result.Instance and Result.Instance:IsDescendantOf(BestPlayer.Character) then
									CanHit = true

									local GunValue: StringValue? = Nocturnal.Modules[1].getCurrentEquipped()
									if not GunValue then
										return
									end
									local CurrentGun: string = Lower(GunValue.Name)
									local WeaponData: any = Nocturnal.Weapons[CurrentGun]
									if not WeaponData then
										return
									end

									local PredictedDmg: number = WeaponData.damage
									Nocturnal._LastShot = Nocturnal._LastShot or {}
									local LastShot: number = Nocturnal._LastShot[CurrentGun] or 0
									local TimeSinceLast: number = Tick() - LastShot
									local FireDelay: number = 60 / WeaponData.rpm

									if TimeSinceLast >= FireDelay then
										Nocturnal._LastShot[CurrentGun] = Tick()

										Spawn(function(): ()
											--// Nocturnal:FireBullet(BestPlayer, Result, PredictedDmg);
											Nocturnal._TargetPart = TargetPart --// obscure af

											local MousePos: Vector2 = InputService:GetMouseLocation()

											--// mouse button down
											VirtualInputManager:SendMouseButtonEvent(
												MousePos.X,
												MousePos.Y,
												0, --// 0 = left mouse button
												true, --// pressed
												game,
												0
											)

											--// mouse button up
											VirtualInputManager:SendMouseButtonEvent(
												MousePos.X,
												MousePos.Y,
												0,
												false, --// released
												game,
												0
											)
										end)
									end

									break
								end

								WallsHit += 1
								Insert(Ignore, Result.Instance)
								Origin = Result.Position + UnitDir * 0.05
							end

							if not CanHit then
								return
							end
						else
							local AimPos: Vector3 = TargetPart.Position

							local BestSample, SampleFrac = Nocturnal:GetBestVisibleSample(TargetPart)
							if BestSample and SampleFrac > 0 then
								if Nocturnal.ResolvePlayerYaw and Library.Flags.rage_rs then
									local ResolvedYaw: number? = Nocturnal:ResolvePlayerYaw(BestPlayer)
									if ResolvedYaw then
										local Rad: number = Rad(ResolvedYaw)
										local Forward = Vec3(Sin(Rad), 0, Cos(Rad))
										BestSample += Forward * 0.02
									end
								end
								AimPos = BestSample
							else
								if Library.Flags.rage_rs then
									local ResolvedYaw: number? = Nocturnal:ResolvePlayerYaw(BestPlayer)
									if ResolvedYaw then
										local Rad: number = Rad(ResolvedYaw)
										local Forward = Vec3(Sin(Rad), 0, Cos(Rad))

										AimPos += Forward * 0.15
									end
								end
							end

							if Library.Flags.rage_as then
								local GunValue: StringValue? = Nocturnal.Modules[1].getCurrentEquipped()
								if not GunValue then
									return
								end

								local CurrentGun: string = Lower(GunValue.Name)
								local WeaponData: any = Nocturnal.Weapons[CurrentGun]
								if not WeaponData then
									return
								end

								Nocturnal._LastShot = Nocturnal._LastShot or {}
								local LastShot: number = Nocturnal._LastShot[CurrentGun] or 0
								local TimeSinceLast: number = Tick() - LastShot
								local FireDelay: number = 60 / WeaponData.rpm

								if TimeSinceLast >= FireDelay then
									Nocturnal._LastShot[CurrentGun] = Tick()

									local Origin: Vector3 = LocalCharacter.Head.Position
									local Dir: Vector3 = AimPos - Origin
									if Dir.Magnitude <= 0.001 then
										Dir = Camera.CFrame.LookVector
									end

									local Params: RaycastParams = RaycastParams.new()
									Params.FilterType = Enum.RaycastFilterType.Exclude
									Params.FilterDescendantsInstances = { LocalCharacter, Camera }
									Params.IgnoreWater = true

									local Result: RaycastResult? =
										workspace:Raycast(Origin, Dir.Unit * Min(Dir.Magnitude + 2, 4000), Params)

									pcall(function(): ()
										local PredictedDmg: number = WeaponData.damage
										if Result and Result.Instance and Result.Instance.Name == "Head" then
											PredictedDmg *= WeaponData.headshot_multiplier
										end

										if PredictedDmg <= 0 then
											if Library.Flags["misc.effects"] then
												Notification.new("Unable to send hit; Dmg too low")
											end

											return
										end

										if
											Result
											and Result.Instance
											and Result.Instance:IsDescendantOf(BestPlayer.Character)
										then
											Spawn(function(): ()
												-- Nocturnal:FireBullet(BestPlayer, Result, PredictedDmg);
												Nocturnal._TargetPart = TargetPart --// obscure af
												local MousePos: Vector2 = InputService:GetMouseLocation()

												--// mouse button down
												VirtualInputManager:SendMouseButtonEvent(
													MousePos.X,
													MousePos.Y,
													0, --// 0 = left mouse button
													true, --// pressed
													game,
													0
												)

												--// mouse button up
												VirtualInputManager:SendMouseButtonEvent(
													MousePos.X,
													MousePos.Y,
													0,
													false, --// released
													game,
													0
												)
											end)
										end
									end)
								end
							end
						end
					end)
				else
					if RagebotConn then
						RagebotConn:Disconnect()
						RagebotConn = nil
					end
				end
			end,
		})

		main:Toggle({ Flag = "rage_aw", Text = "Auto Wall", Risky = true })
		main:Toggle({ Flag = "rage.silent", Text = "Silent Aim", Risky = true })
		main:Toggle({ Flag = "rage_ab", Text = "Allow bodyaim", Risky = true })

		main:Dropdown({
			Flag = "rage_hb",
			Text = "Hitbox Priority",
			Values = { "Head", "Body", "Auto", "Prefer Safe" },
			Selected = "Head",
		})

		main:Dropdown({
			Flag = "silent.mode",
			Text = "Raycast Method",
			Values = { "Raycast", "FindPartOnRay", "FindPartOnRayWithIgnoreList", "FindPartOnRayWithWhitelist" },
			Selected = "Raycast",
		})

		resolver:Toggle({ Flag = "rage_rs", Text = "Resolver", Risky = true })
		resolver:Toggle({ Flag = "rage_lby", Text = "LBY Checks", Risky = true })
		resolver:Slider({
			Flag = "rage_rsh",
			Text = "Resolver History",
			Min = 1,
			Max = 12,
			Value = 6,
			Suffix = " ticks",
			Risky = true,
		})
		resolver:Dropdown({
			Flag = "rage_rsm",
			Text = "Resolver Mode",
			Values = { "Aggressive", "Safe", "Bruteforce" },
			Selected = "Adaptive",
		})

		antiaim:Toggle({ Flag = "aa.enabled", Text = "Enable", Risky = true })
		antiaim:Toggle({ Flag = "aa.ud", Text = "Upside down", Risky = true })

		antiaim:Dropdown({
			Flag = "aa.pitch",
			Text = "Pitch",
			Values = { "Off", "Up", "Down", "Zero" },
			Selected = "Off",
		})

		antiaim:Dropdown({
			Flag = "aa.yaw",
			Text = "Yaw",
			Values = { "Backward", "Spin", "Jitter", "Freestanding" },
			Selected = "Backward",
		})

		antiaim:Slider({ Flag = "aa.jitter", Text = "Jitter Amount", Min = 0, Max = 180, Value = 90, Suffix = "°", Risky = true })
	end

	--// visuals
	do
		local players = Tabs.Visuals:Section("Player ESP", 1, 1)
		local chams = Tabs.Visuals:Section("Chams", 2, 1)
		local miscellaneous = Tabs.Visuals:Section("Miscellaneous", 2, 2)
		local world = Tabs.Visuals:Section("World", 1, 3)
		local viewmodel = Tabs.Visuals:Section("Viewmodel", 2, 3)

		--// Player ESP
		players:Toggle({ Flag = "esp.enabled", Text = "Enable ESP" })
		players:Toggle({ Flag = "esp.box", Text = "Box" }):Color({ Flag = "esp.box.color", Text = "Box Color" })
		players:Toggle({ Flag = "esp.fill", Text = "Fill" }):Color({ Flag = "esp.fill.color", Text = "Fill Color" })
		players:Toggle({ Flag = "esp.name", Text = "Name" }):Color({ Flag = "esp.name.color", Text = "Name Color" })
		players
			:Toggle({ Flag = "esp.health", Text = "Health" })
			:Color({ Flag = "esp.health.color", Text = "Health Color" })
		players:Toggle({ Flag = "esp.weapon", Text = "Weapon" })
		players
			:Toggle({ Flag = "esp.distance", Text = "Distance" })
			:Color({ Flag = "esp.distance.color", Text = "Distance Color" })
		players
			:Toggle({ Flag = "esp.skeleton", Text = "Skeleton" })
			:Color({ Flag = "esp.skeleton.color", Text = "Skeleton Color" })
		players
			:Toggle({ Flag = "esp.arrow", Text = "Offscreen Arrow" })
			:Color({ Flag = "esp.arrow.color", Text = "Arrow Color" })

		--// Chams
		chams:Toggle({ Flag = "chams.enabled", Text = "Enabled" }):Color({ Flag = "chams.color", Text = "Chams Color" })
		chams
			:Toggle({ Flag = "chams.outline", Text = "Outline" })
			:Color({ Flag = "chams.outline.color", Text = "Outline Color" })
		chams:Slider({ Flag = "chams.trans", Text = "Transparency", Min = 0, Max = 1, Value = 0.5, Increment = 0.1, Suffix = "%" })

		chams:Dropdown({
			Flag = "chams.method",
			Text = "Cham Style",
			Values = {
				"BoxHandleAdornment",
				"Materialistic",
				"Highlight",
				"Glow",
				"Wireframe",
				"LayeredGlow",
				"OutlineGlow",
				"Drawing",
			},
			Selected = "BoxHandleAdornment",
		})

		--// viewmodel
		local GunModulationConnection

		viewmodel
			:Toggle({
				Flag = "gunchams.enabled",
				Text = "Gun Chams",
				Callback = function(Value: boolean): ()
					if Value then
						GunModulationConnection = Nocturnal.ViewmodelPath.ChildAdded:Connect(
							function(Child: Instance?): ()
								if not Child or not Child:IsA("Model") then
									return
								end

								for Index, Part in Child:GetDescendants() do
									if not Part:IsA("MeshPart") then
										continue
									end

									local PartName: string = Lower(Part.Name)

									if
										PartName:find("glove")
										or PartName:find("arm")
										or PartName:find("sleeve")
										or PartName:find("joint")
									then
										continue
									end

									local SurfaceAppearance: SurfaceAppearance? =
										Part:FindFirstChildOfClass("SurfaceAppearance")
									if SurfaceAppearance then
										SurfaceAppearance:Destroy()
									end

									Part.TextureID = Nocturnal.Textures[Library.Flags["gunchams.texture"]]
									Part.Material = Enum.Material.Neon
									Part.Color = Library.Flags["gunchams.color"]
									Part.Reflectance = Library.Flags["gunchams.reflectance"]

									local Effect: string = Library.Flags["gunchams.style"]

									Switch(Effect, {
										Pulse = function()
											CreateThread(function()
												while Part and Part.Parent do
													local ToOpaque = TweenService:Create(
														Part,
														TweenInfo.new(
															1,
															Enum.EasingStyle.Linear,
															Enum.EasingDirection.InOut
														),
														{ Transparency = 0 }
													)
													local ToFaded = TweenService:Create(
														Part,
														TweenInfo.new(
															1,
															Enum.EasingStyle.Linear,
															Enum.EasingDirection.InOut
														),
														{ Transparency = 0.9 }
													)

													ToOpaque:Play()
													ToOpaque.Completed:Wait()
													ToFaded:Play()
													ToFaded.Completed:Wait()

													Wait(0.5)
												end
											end)
										end,

										Tween = function()
											Part.Material = Enum.Material.ForceField
											CreateThread(function()
												while Part and Part.Parent do
													local TweenInfoSettings = TweenInfo.new(
														1.3,
														Enum.EasingStyle.Quart,
														Enum.EasingDirection.InOut
													)
													local TweenWhite = TweenService:Create(
														Part,
														TweenInfoSettings,
														{ Color = Color3.fromRGB(255, 255, 255) }
													)
													TweenWhite:Play()
													TweenWhite.Completed:Wait()
													local TweenOriginal = TweenService:Create(
														Part,
														TweenInfoSettings,
														{ Color = Library.Flags["gunchams.color"] }
													)
													TweenOriginal:Play()
													TweenOriginal.Completed:Wait()
												end
											end)
										end,

										ForceField = function()
											Part.Color = Library.Flags["gunchams.color"]
											Part.Material = Enum.Material.ForceField
											Part.TextureID = "rbxassetid://8133639623"
										end,

										Flat = function()
											Part.Material = Enum.Material.Neon
										end,

										Glass = function()
											Part.Color = Library.Flags["gunchams.color"]
											Part.Material = Enum.Material.Glass
											Part.Transparency = 0.55
										end,

										Smooth = function()
											Part.Color = Library.Flags["gunchams.color"]
											Part.Material = Enum.Material.SmoothPlastic
										end,

										ForceOverlay = function()
											Part.Color = Library.Flags["gunchams.color"]
											Part.Material = Enum.Material.Plastic
											Part.Reflectance = 999999
										end,

										Water = function()
											Part.Material = Enum.Material.ForceField
											Part.Transparency = 0
											Part.Color = Library.Flags["gunchams.color"]

											local TextureIndex = 1
											local MAX_TEXTURES = 25 --// theres only lIke 25 textures in water folder so this is the limit. do not chang.e

											CreateThread(function()
												while Part and Part.Parent do
													Part.TextureID = "rbxasset://textures/water/normal_"
														.. StringFormat("%02d", TextureIndex)
														.. ".dds"
													TextureIndex = TextureIndex + 1

													if TextureIndex > MAX_TEXTURES then
														TextureIndex = 1
													end

													Wait(0.08)
												end
											end)
										end,
									})
								end
							end
						)
					else
						if GunModulationConnection then
							GunModulationConnection:Disconnect()
							GunModulationConnection = nil
						end
					end
				end,
			})
			:Color({ Flag = "gunchams.color", Text = "Gun Chams Color" })

		viewmodel:Slider({
			Flag = "gunchams.reflectance",
			Text = "Cham Reflectance",
			Min = 0,
			Max = 1,
			Value = 0,
			Increment = 0.1,
			Suffix = "%",
		})

		viewmodel:Dropdown({
			Flag = "gunchams.style",
			Text = "Cham Type",
			Values = { "Pulse", "ForceField", "Flat", "Glass", "Tween", "Smooth", "ForceOverlay", "Water" },
			Selected = "Pulse",
		})

		viewmodel:Dropdown({
			Flag = "gunchams.texture",
			Text = "Cham Texture",
			Values = { "None", "Stars", "Hex" },
			Selected = "None",
		})

		local c = {
			Nocturnal:Draw("Line", { ZIndex = 999 }),
			Nocturnal:Draw("Line", { ZIndex = 999 }),
			Nocturnal:Draw("Line", { ZIndex = 999 }),
			Nocturnal:Draw("Line", { ZIndex = 999 }),
		}

		local CurrentPos = Vec2(0, 0)
		local CurrentGap = 0
		local PulseTime = 0
		local Rotation = 0

		local function RotatePoint(p, center, a): Vector2
			local s, cr = Sin(a), Cos(a)
			local dx, dy = p.X - center.X, p.Y - center.Y

			return Vec2(dx * cr - dy * s + center.X, dx * s + dy * cr + center.Y)
		end

		function EaseInOut(t: number): number
			return t * t * (3 - 2 * t) --// thx devforum
		end

		function EaseInOutQuart(t: number): number
			if t < 0.5 then
				return 8 * t ^ 4
			else
				local f = (t - 1)
				return 1 - 8 * f ^ 4
			end
		end

		function UpdateCrosshair(ScreenPos, Delta): ()
			local Center = Camera.ViewportSize / 2
			local Len = Library.Flags["world.crosshair.length"] or 5
			local BaseGap = Library.Flags["world.crosshair.gap"] or 5
			local PulseAmount = 6
			local PulseSpeed = 1.5 --// too lazy to make this configurable. fck fof.

			PulseTime = (PulseTime + Delta * PulseSpeed) % 2
			local T = PulseTime
			if T > 1 then
				T = 2 - T
			end

			local EasingName = Library.Flags["misc.easingstyle"] or "QuartInOut"
			local EasingFunc = Nocturnal.EasingStyles[EasingName] or Nocturnal.EasingStyles.QuartInOut
			local Eased = EasingFunc(T)

			local TargetGap
			if Library.Flags["misc.effects"] then
				TargetGap = BaseGap + Eased * PulseAmount
			else
				TargetGap = BaseGap
			end

			CurrentGap = CurrentGap + (TargetGap - CurrentGap) * 0.15

			if ScreenPos then
				CurrentPos = CurrentPos:Lerp(ScreenPos, 0.2)
			else
				CurrentPos = CurrentPos:Lerp(Center, 0.2)
			end

			if Library.Flags["world.crosshair.spin"] then
				Rotation = (Rotation + 0.02) % (Pi * 2)
			end

			local Points = {
				{ Vec2(CurrentPos.X - CurrentGap, CurrentPos.Y), Vec2(CurrentPos.X - CurrentGap - Len, CurrentPos.Y) },
				{ Vec2(CurrentPos.X + CurrentGap, CurrentPos.Y), Vec2(CurrentPos.X + CurrentGap + Len, CurrentPos.Y) },
				{ Vec2(CurrentPos.X, CurrentPos.Y - CurrentGap), Vec2(CurrentPos.X, CurrentPos.Y - CurrentGap - Len) },
				{ Vec2(CurrentPos.X, CurrentPos.Y + CurrentGap), Vec2(CurrentPos.X, CurrentPos.Y + CurrentGap + Len) },
			}

			for Index = 1, 4 do
				local Line = c[Index]
				local From = RotatePoint(Points[Index][1], CurrentPos, Rotation)
				local To = RotatePoint(Points[Index][2], CurrentPos, Rotation)

				Line.From = From
				Line.To = To
				Line.Thickness = Library.Flags["world.crosshair.width"] or 2
				Line.Color = Library.Flags["world.crosshair.color"] or Color3New(1, 1, 1)
				Line.Visible = Library.Flags["world.crosshair.enabled"] == true
			end
		end

		Insert(
			Nocturnal.Connections,
			RunService.RenderStepped:Connect(function(dt)
				if not Library.Flags["world.crosshair.enabled"] then
					return
				end

				if
					Library.Flags["world.crosshair.follow"]
					and Nocturnal.ViewmodelPath
					and #Nocturnal.ViewmodelPath:GetChildren() > 0
				then
					local barrel

					for _, d in Nocturnal.ViewmodelPath:GetDescendants() do
						if d:IsA("BasePart") then
							local n = d.Name:lower()
							if n:find("barrel") or n:find("bolt") then
								barrel = d
								break
							end
						end
					end

					if barrel then
						local RayParams = RaycastParams.new()
						RayParams.FilterType = Enum.RaycastFilterType.Exclude
						RayParams.FilterDescendantsInstances = { LocalPlayer.Character, Camera }

						local Result = workspace:Raycast(barrel.Position, Camera.CFrame.LookVector * 500, RayParams)

						if Result then
							local Screen, OnScreen = Camera:WorldToViewportPoint(Result.Position)

							if OnScreen then
								UpdateCrosshair(Vec2(Screen.X, Screen.Y), dt)

								return
							end
						end
					end
				end

				UpdateCrosshair(nil, dt)
			end)
		)

		--// Misc
		miscellaneous
			:Toggle({
				Flag = "world.crosshair.enabled",
				Text = "Custom Crosshair",
				Callback = function(Enabled)
					if not Enabled then
						for Index = 1, 4 do
							if c[Index] then
								c[Index].Visible = false
							end
						end
					end
				end,
			})
			:Color({
				Flag = "world.crosshair.color",
				Text = "Crosshair Color",
			})

		miscellaneous:Toggle({
			Flag = "world.crosshair.follow",
			Text = "Follow Barrel",
		})

		miscellaneous:Toggle({
			Flag = "world.crosshair.spin",
			Text = "Spin",
			Callback = function(v)
				if not v then
					Rotation = 0
				end
			end,
		})

		miscellaneous:Slider({
			Flag = "world.crosshair.gap",
			Text = "Gap",
			Min = 0,
			Max = 20,
			Value = 5,
		})

		miscellaneous:Slider({
			Flag = "world.crosshair.width",
			Text = "Width",
			Min = 1,
			Max = 10,
			Value = 2,
		})

		miscellaneous:Slider({
			Flag = "world.crosshair.length",
			Text = "Length",
			Min = 1,
			Max = 60,
			Value = 5,
		})

		miscellaneous:Separator({ Flag = "goyimDestroyer69420", Text = "Sky" })

		local SkyValues: { string } = {}
		Insert(SkyValues, "None")

		for Index, Sky in Nocturnal.Skies do
			Insert(SkyValues, Index)
		end

		miscellaneous:Toggle({ Text = "Custom skybox", Flag = "world_skyboxtogg" })
		miscellaneous:Dropdown({
			Flag = "world_skyboxcustom",
			Text = "Skybox",
			Values = SkyValues,
			Selected = "None",
			Callback = function(Value): ()
				if not Value then
					return
				end
				if Value == "None" then
					return
				end
				if Lighting:FindFirstChildOfClass("Sky") then
					Lighting:FindFirstChildOfClass("Sky"):Destroy()
				end
				local Skybox = InstanceNew("Sky", Lighting)

				Skybox.SkyboxLf = Nocturnal.Skies[Value].SkyboxLf
				Skybox.SkyboxBk = Nocturnal.Skies[Value].SkyboxBk
				Skybox.SkyboxDn = Nocturnal.Skies[Value].SkyboxDn
				Skybox.SkyboxFt = Nocturnal.Skies[Value].SkyboxFt
				Skybox.SkyboxRt = Nocturnal.Skies[Value].SkyboxRt
				Skybox.SkyboxUp = Nocturnal.Skies[Value].SkyboxUp

				Skybox.Name = "skeibocks"
			end,
		})

		miscellaneous:Separator({ Flag = "werewrewrwe", Text = "Tracers" })
		miscellaneous:Toggle({ Text = "Bullet Tracers", Flag = "world.btracers" }):Color({
			Flag = "world.btc",
			Text = "Tracer Color",
		})

		miscellaneous:Slider({
			Flag = "world.btt",
			Text = "Tracer Transparency",
			Min = 0,
			Max = 1,
			Value = 0.5,
			Increment = 0.1,
		})

		local function GetOrCreateEffect(Name, ClassName): Instance
			local existing = Lighting:FindFirstChild(Name)

			if existing then
				if existing.ClassName ~= ClassName then
					existing:Destroy()
				else
					return existing
				end
			end

			local inst = InstanceNew(ClassName)
			inst.Name = Name
			inst.Parent = Lighting

			return inst
		end

		local function RemoveNamedEffect(Name): nil
			local inst = Lighting:FindFirstChild(Name)

			if inst then
				inst:Destroy()
			end
		end

		local function RestoreLighting(): nil
			Lighting:ClearAllChildren() --// too lazy for ts
		end

		local function SaveCurrentLighting()
			--// Placeholder
		end

		local function MasterOK()
			return Library.Flags["world.amb"] == true
		end

		Spawn(function()
			local lastMaster = nil

			while Wait() do
				local masterOn = Library.Flags["world.amb"] == true

				if not masterOn then
					continue
				end

				if lastMaster == nil then
					lastMaster = masterOn
				elseif lastMaster and not masterOn then
					RestoreLighting()
				end
				lastMaster = masterOn

				if not masterOn then
				end

				if Library.Flags["world_ambc"] then
					Lighting.Ambient = Library.Flags["world_ambc"]
				end
				if Library.Flags["world_csbc"] then
					Lighting.ColorShift_Bottom = Library.Flags["world_csbc"]
				end
				if Library.Flags["world_cstc"] then
					Lighting.ColorShift_Top = Library.Flags["world_cstc"]
				end
				if Library.Flags["world_eds"] then
					Lighting.EnvironmentDiffuseScale = Library.Flags["world_eds"]
				end
				if Library.Flags["world_ess"] then
					Lighting.EnvironmentSpecularScale = Library.Flags["world_ess"]
				end
				if Library.Flags["world_brightness2"] then
					Lighting.Brightness = Library.Flags["world_brightness2"]
				end
				if Library.Flags["world_ct"] then
					Lighting.ClockTime = Library.Flags["world_ct"]
				end

				--// Bloom
				if Library.Flags["world_bloom"] then
					local b = GetOrCreateEffect("nBloom", "BloomEffect")
					b.Enabled = true
					if Library.Flags["world_bi"] then
						b.Intensity = Library.Flags["world_bi"]
					end
					if Library.Flags["world_bs"] then
						b.Size = Library.Flags["world_bs"]
					end
					if Library.Flags["world_bt"] then
						b.Threshold = Library.Flags["world_bt"]
					end
				else
					local b = Lighting:FindFirstChild("nBloom")
					if b then
						b.Enabled = false
					end
				end

				--// Sun Rays
				if Library.Flags["world_sr"] then
					local s = GetOrCreateEffect("nSunRays", "SunRaysEffect")
					s.Enabled = true
					if Library.Flags["world_sri"] then
						s.Intensity = Library.Flags["world_sri"]
					end
					if Library.Flags["world_srs"] then
						s.Spread = Library.Flags["world_srs"]
					end
				else
					local s = Lighting:FindFirstChild("nSunRays")
					if s then
						s.Enabled = false
					end
				end

				--// Color Correction
				if Library.Flags["world_cc"] then
					local c = GetOrCreateEffect("nColorCorrection", "ColorCorrectionEffect")
					c.Enabled = true
					if Library.Flags["world_ccc"] then
						c.TintColor = Library.Flags["world_ccc"]
					end
				else
					local c = Lighting:FindFirstChild("nColorCorrection")
					if c then
						c.Enabled = false
					end
				end
			end
		end)

		--// UI
		world:Toggle({ Text = "Ambience", Flag = "world.amb" }):Color({
			Text = "Ambient Color",
			Flag = "world_ambc",
			Color = Lighting.Ambient,
			Callback = function(c)
				if MasterOK() then
					Lighting.Ambient = c
					SaveCurrentLighting()
				end
			end,
		})

		world:Toggle({ Text = "Colorshift Bottom", Flag = "world_csb" }):Color({
			Text = "Bottom Color",
			Flag = "world_csbc",
			Color = Color3.new(0, 0, 0),
			Callback = function(c)
				if MasterOK() then
					Lighting.ColorShift_Bottom = c
					SaveCurrentLighting()
				end
			end,
		})

		world:Toggle({ Text = "Colorshift Top", Flag = "world_cst" }):Color({
			Text = "Top Color",
			Flag = "world_cstc",
			Color = Color3.new(0, 0, 0),
			Callback = function(c)
				if MasterOK() then
					Lighting.ColorShift_Top = c
					SaveCurrentLighting()
				end
			end,
		})

		world:Slider({
			Text = "Environment Diffuse",
			Min = 0,
			Max = 1,
			Value = 0.35,
			Increment = 0.1,
			Flag = "world_eds",
			Callback = function(v)
				if MasterOK() then
					Lighting.EnvironmentDiffuseScale = v
					SaveCurrentLighting()
				end
			end,
		})

		world:Slider({
			Text = "Environment Specular",
			Min = 0,
			Max = 1,
			Value = 1,
			Increment = 0.1,
			Flag = "world_ess",
			Callback = function(v)
				if MasterOK() then
					Lighting.EnvironmentSpecularScale = v
					SaveCurrentLighting()
				end
			end,
		})

		world:Slider({
			Text = "Clock time",
			Min = 0,
			Max = 24,
			Value = Lighting.ClockTime,
			Increment = 0.1,
			Flag = "world_ct",
			Callback = function(v)
				if MasterOK() then
					Lighting.ClockTime = v
					SaveCurrentLighting()
				end
			end,
		})

		--// Bloom
		world:Toggle({ Text = "Bloom", Flag = "world_bloom" })
		world:Slider({ Text = "Bloom Intensity", Min = 0, Max = 10, Value = 4, Flag = "world_bi" })
		world:Slider({ Text = "Bloom Size", Min = 0, Max = 50, Value = 15, Flag = "world_bs" })
		world:Slider({ Text = "Bloom Threshold", Min = 0, Max = 1, Value = 0.15, Increment = 0.01, Flag = "world_bt" })

		--// Sun Rays
		world:Toggle({ Text = "Sun Rays", Flag = "world_sr" })
		world:Slider({ Text = "Intensity", Min = 0, Max = 1, Value = 0.01, Increment = 0.01, Flag = "world_sri" })
		world:Slider({ Text = "Spread", Min = 0, Max = 1, Value = 0.1, Increment = 0.1, Flag = "world_srs" })

		--// Color Correction
		world
			:Toggle({ Text = "Color correction", Flag = "world_cc" })
			:Color({ Text = "Correction Color", Flag = "world_ccc", Color = Color3.fromRGB(255, 85, 255) })
	end

	--// Misc
	do
		local movement = Tabs.Misc:Section("Movement", 1, 1)
		local weapon = Tabs.Misc:Section("Weapon", 2, 1)
		local network = Tabs.Misc:Section("Network", 1, 2)
		local other = Tabs.Misc:Section("Other", 2, 2)
		local skins = Tabs.Misc:Section("Skins", 2, 3)

		--// connections
		local BunnyConnection

		movement:Toggle({ Flag = "move.speed", Text = "Speed" })

		Insert(
			Nocturnal.Connections,
			RunService.RenderStepped:Connect(function(DeltaTime: number): ()
				if not Library.Flags["move.speed"] then
					return
				end
				if not Nocturnal:Alive() then
					return
				end

				local Player: Player = PlayerService.LocalPlayer
				local Character: Model? = Player.Character
				if not Character then
					return
				end

				local Humanoid: Humanoid? = Character:FindFirstChildOfClass("Humanoid")
				if not Humanoid then
					return
				end

				local SpeedType: string = Library.Flags["move.speedtype"] or "WalkSpeed"
				local SpeedAmount: number = Library.Flags["move.speedamount"] or 16

				if SpeedType == "WalkSpeed" then
					Humanoid.WalkSpeed = SpeedAmount
				elseif SpeedType == "MoveDirection" then
					local Root: BasePart = Character.PrimaryPart
					if Root then
						local MoveDir: Vector3 = Humanoid.MoveDirection
						Root.CFrame += CFrameNew(MoveDir * SpeedAmount * DeltaTime).Position
					end
				end
			end)
		)

		movement:Toggle({
			Flag = "move.bhop",
			Text = "Bunny Hop",
			Risky = true,
			Callback = function(Value: boolean): ()
				if Value then
					BunnyConnection = RunService.RenderStepped:Connect(function(DeltaTime: number): ()
						if not Library.Flags["move.bhop"] then
							return
						end
						if not Nocturnal:Alive() then
							return
						end

						local Character = LocalPlayer.Character
						if not Character then
							return
						end

						local HRP = Character.PrimaryPart
						if not HRP then
							return
						end

						local IsJumping: boolean = InputService:IsKeyDown(Enum.KeyCode.Space)

						if IsJumping then
							local AddAngle: number = 0

							local W: boolean = InputService:IsKeyDown(Enum.KeyCode.W)
							local A: boolean = InputService:IsKeyDown(Enum.KeyCode.A)
							local S: boolean = InputService:IsKeyDown(Enum.KeyCode.S)
							local D: boolean = InputService:IsKeyDown(Enum.KeyCode.D)

							if A and W then
								AddAngle = 45
							elseif D and W then
								AddAngle = 315
							elseif D and S then
								AddAngle = 225
							elseif A and S then
								AddAngle = 145
							elseif A then
								AddAngle = 90
							elseif S then
								AddAngle = 180
							elseif D then
								AddAngle = 270
							end

							local CameraRotation: CFrame = Nocturnal:RotationY(workspace.CurrentCamera.CFrame)
							local MoveRotation: CFrame = CameraRotation * CFrameAngles(0, Rad(AddAngle), 0)

							local Speed = Library.Flags["move.speedamount"] * 2
							local Direction = MoveRotation.LookVector

							--// Preserve y
							local CurrentVelocity = HRP.Velocity
							HRP.Velocity = Vector3.new(Direction.X * Speed, CurrentVelocity.Y, Direction.Z * Speed)

							Character.Humanoid.Jump = true
						end
					end)

					Insert(Nocturnal.Connections, BunnyConnection)
				else
					if BunnyConnection then
						BunnyConnection:Disconnect()
						BunnyConnection = nil
					end
				end
			end,
		})

		local function DoCollision(Character: Model, CanCollide: boolean)
			for _, descendant in Character:GetDescendants() do
				if descendant:IsA("BasePart") and not (descendant.Parent:IsA("Accessory")) then
					--descendant.CanCollide = CanCollide
				end
			end
		end

		movement
			:Toggle({
				Flag = "move.noclip",
				Text = "Noclip",
				Callback = function(Enabled: boolean)
					local Character = LocalPlayer.Character

					if Nocturnal:Alive() and Character then
						DoCollision(Character, not Enabled)
					end
				end,
			})
			:Bind({
				Flag = "move.nokey",
				Text = "Noclip",
				Bind = "NONE",
				Mode = "toggle",
				Callback = function(Enabled: boolean)
					local Character = LocalPlayer.Character
					if Nocturnal:Alive() and Character then
						DoCollision(Character, not Enabled)
					end
				end,
			})

		movement:Toggle({ Flag = "move.edgejump", Text = "Edge Jump" }):Bind({
			Flag = "move.jumpkey",
			Text = "Edgejump",
			Bind = "NONE",
			Mode = "toggle",
		})

		movement:Toggle({ Flag = "move.jumpbug", Text = "Jump Bug" }):Bind({
			Flag = "move.jumpkey",
			Text = "Jump Bug",
			Bind = "NONE",
			Mode = "toggle",
		})

		Insert(
			Nocturnal.Connections,
			RunService.RenderStepped:Connect(function(DeltaTime: number): ()
				if not Library.Flags["move.jumpbug"] or not Library.Flags["move.jumpkey"] then
					return
				end
				if not Nocturnal:Alive() then
					return
				end

				local Character: Model? = LocalPlayer.Character
				if not Character then
					return
				end

				local Humanoid: Humanoid? = Character:FindFirstChildOfClass("Humanoid")
				local Root: BasePart? = Character.PrimaryPart
				if not Humanoid or not Root then
					return
				end

				local CurrentVelocity: Vector3 = Root.Velocity

				if CurrentVelocity.Y < -2 then
					local RayResult: RaycastResult? = Nocturnal:Raycast(Root.Position, Vec3(0, -3, 0))

					if RayResult then
						Root.CFrame = LastPosition
						Root.Velocity += Vec3(0, Humanoid.JumpPower, 0)
					end
				end

				LastPosition = Root.CFrame
			end)
		)

		Insert(
			Nocturnal.Connections,
			RunService.Heartbeat:Connect(function(DeltaTime: number)
				if not Library.Flags["move.edgejump"] or not Library.Flags["move.jumpkey"] then
					return
				end
				if not Nocturnal:Alive() then
					return
				end

				local Player: Player = PlayerService.LocalPlayer
				local Character: Model? = Player.Character
				if not Character then
					return
				end

				local Root: BasePart = Character.PrimaryPart
				if not Root then
					return
				end

				local Velocity: Vector3 = Root.Velocity

				--// Already moving up s0 dont do ts
				if Velocity.Y > 1 then
					return
				end

				local Forward: Vector3 = Vec3(Velocity.X, 0, Velocity.Z)
				if Forward.Magnitude < 1 then
					return
				end
				Forward = Forward.Unit

				local FeetHit: RaycastResult? = Nocturnal:Raycast(Root.Position, Vec3(0, -3.1, 0))
				if not FeetHit then
					return
				end

				local AheadPosition: Vector3 = Root.Position + Forward * 2
				local AheadHit: RaycastResult? = Nocturnal:Raycast(AheadPosition, Vec3(0, -3.1, 0))

				if not AheadHit then
					if rawequal(Library.Flags["move.edgetype"], "Velocity") then
						Root.Velocity += Vec3(0, Character.Humanoid.JumpPower, 0) or Vec3(0, 50, 0)
					else
						Character:FindFirstChildOfClass("Humanoid").Jump = true
					end
				end
			end)
		)

		movement
			:Toggle({ Flag = "move.targetstrafe", Text = "Target Strafe" })
			:Bind({ Flag = "move.strafe.key", Text = "Targetstrafe", Bind = "NONE", Mode = "toggle" })

		movement:Dropdown({
			Flag = "net.strafetype",
			Text = "Targetstrafe type",
			Values = { "Circle", "Ontop", "Underground" },
			Selected = "Circle",
		})

		movement:Dropdown({
			Flag = "move.speedtype",
			Text = "Speed Type",
			Values = { "WalkSpeed", "MoveDirection" },
			Selected = "WalkSpeed",
		})

		movement:Dropdown({
			Flag = "move.edgetype",
			Text = "Edgejump type",
			Values = { "Velocity", "Humanoid" },
			Selected = "Velocity",
		})

		Insert(
			Nocturnal.Connections,
			RunService.RenderStepped:Connect(function(DeltaTime: number)
				if not Nocturnal.LoadComplete then
					return
				end
				if not Library.Flags["move.targetstrafe"] or not Library.Flags["move.strafe.key"] then
					return
				end

				local Character: Model? = LocalPlayer.Character
				if not Character then
					return
				end

				local Root: BasePart? = Character:FindFirstChild("HumanoidRootPart") :: BasePart?
				if not Root then
					return
				end

				local Radius: number = Library.Flags["move.strafedistance"]
				local StrafeMode: string = Library.Flags["net.strafetype"]

				local TargetRoot: BasePart? = Nocturnal:GetStrafeTarget(Library.Flags["move.strafedistance"] * 2)
				if not TargetRoot then
					return
				end

				local TargetCFrame: CFrame? = Nocturnal:GetStrafeCFrame(StrafeMode, Root, TargetRoot, Radius, DeltaTime)

				if TargetCFrame then
					Root.CFrame = TargetCFrame
				end
			end)
		)

		movement:Slider({ Flag = "move.strafespeed", Text = "Strafe Speed", Min = 1, Max = 10, Value = 5 })

		movement:Slider({ Flag = "move.strafedistance", Text = "Strafe Distance", Min = 1, Max = 100, Value = 16 })

		movement:Slider({ Flag = "move.speedamount", Text = "Speed Amount", Min = 1, Max = 160, Value = 16 })

		Nocturnal.OriginalValues = {}

		weapon:Toggle({
			Flag = "weapon.firerate",
			Text = "Fire Rate",
			Risky = true,
			Callback = function(State: boolean)
				for _, Obj in ReplicatedStorage:GetDescendants() do
					if Obj:IsA("NumberValue") and Find(Lower(Obj.Name), "firerate") then
						CreateThread(function()
							if not Nocturnal.OriginalValues[Obj] then
								Nocturnal.OriginalValues[Obj] = Obj.Value
							end

							if State then
								Obj.Value = 0.03
							else
								Obj.Value = Nocturnal.OriginalValues[Obj]
							end
						end)
					end
				end
			end,
		})

		weapon:Toggle({
			Flag = "weapon.norecoil",
			Text = "No Recoil",
			Risky = true,
			Callback = function(State: boolean)
				if not Nocturnal.OriginalCFrames then
					Nocturnal.OriginalCFrames = {}
				end

				local SprayPatterns = ReplicatedStorage.Database.Custom.Weapons.SprayPatterns:GetChildren()
				for i = 1, #SprayPatterns do
					local WeaponPart = SprayPatterns[i]
					local PartName = WeaponPart.Name

					if not Nocturnal.OriginalCFrames[PartName] then
						Nocturnal.OriginalCFrames[PartName] = {}
					end

					local Attachments = WeaponPart:GetChildren()

					Sort(Attachments, function(a, b)
						return tonumber(a.Name) < tonumber(b.Name)
					end)

					for j = 1, #Attachments do
						local Attachment = Attachments[j]
						if Attachment:IsA("Attachment") then
							if not Nocturnal.OriginalCFrames[PartName][Attachment.Name] then
								Nocturnal.OriginalCFrames[PartName][Attachment.Name] = Attachment.WorldCFrame
							end

							if State then
								Attachment.WorldCFrame = CFrameNew()
							else
								local Original = Nocturnal.OriginalCFrames[PartName][Attachment.Name]

								if Original then
									Attachment.WorldCFrame = Original
								end
							end
						end
					end
				end
			end,
		})

		weapon:Toggle({
			Flag = "weapon.nospread",
			Text = "No Spread",
			Risky = true,
			Callback = function(State: boolean) end,
		})

		weapon:Toggle({
			Flag = "weapon.instant",
			Text = "Instant Reload",
			Risky = true,
			Callback = function(State: boolean) end,
		})

		weapon:Toggle({
			Flag = "weapon.nobob",
			Text = "No bob",
			Risky = false,
			Callback = function(State: boolean) end,
		})

		network
			:Toggle({ Flag = "net.fakelag", Text = "Fakelag" })
			:Bind({ Flag = "net.lag.key", Text = "Fakelag", Bind = "NONE", Mode = "toggle" })

		network
			:Toggle({ Flag = "net.fakelag.vis", Text = "Visualize lag" })
			:Color({ Text = "Visualization Color", Flag = "net.fakelag.color", Color = Color3.fromRGB(255, 85, 255) })

		network:Slider({ Flag = "net.lagticks", Text = "Lag ticks", Min = 1, Max = 20, Value = 3 })

		network:Dropdown({
			Flag = "net.lagtype",
			Text = "Fakelag type",
			Values = { "Instance", "Prevent Replication", "Physics" },
			Selected = "Instance",
			Callback = function(Value): () end,
		})

		network:Separator({ Flag = "goydestroy50", Text = "Desync" })

		local desyncConn
		network
			:Toggle({ Flag = "net.desync", Text = "Disable netsync" })
			:Bind({ Flag = "net.dsync.key", Text = "Desync", Bind = "NONE", Mode = "toggle" })
		network:Slider({ Flag = "net.syncticks", Text = "Desync ticks", Min = 1, Max = 5000, Value = 3 })

		CreateThread(function()
			Insert(
				Nocturnal.Connections,
				RunService.RenderStepped:Connect(function(DeltaTime: number)
					if Library.Flags["net.desync"] or Library.Flags["net.dsync.key"] then
						if Nocturnal:Alive() then
							Spawn(function()
								if LocalPlayer.Character and not workspace:FindFirstChildOfClass("Seat") then
									local _c = LocalPlayer.Character
									if not (_c and _c:FindFirstChild("HumanoidRootPart")) then
									else
										if true then
											local cee = InstanceNew("Seat")
											cee.Name = "tRGWJUI%ERjtguihe85ur"
											cee.Parent = workspace
											cee.Size = Vec3(4, 1, 1)
											cee.CanCollide = false
											cee.CanQuery = false
											--cee.CollisionGroup = "Smoke"

											local awe = InstanceNew("Weld", cee)
											local bb = InstanceNew("Weld")
											bb.Name = "geriuzh5eruzhge5"
											bb.Parent = _c.HumanoidRootPart

											cee.CFrame = CFrameNew(_c.HumanoidRootPart.Position)
											cee.CFrame = cee.CFrame
											awe.Part0 = _c.HumanoidRootPart
											awe.Part1 = cee
											_c.HumanoidRootPart.CFrame = CFrameNew(cee.Position)
											bb.Part0 = _c.HumanoidRootPart
											bb.Part1 = cee
											cee.Transparency = 1
										end

										if Library.Flags["net.fakelag.vis"] then
											local sf = workspace
											if not sf:FindFirstChild("FakeChar") then
												local i = InstanceNew("Model", sf)
												i.Name = "FakeChar"
												for _, v in _c:GetDescendants() do
													if v:IsA("BasePart") and v.Transparency ~= 1 then
														local a = v:Clone()
														a.CanCollide = false
														a.Parent = i
														v.CanQuery = false
														a.Anchored = true
														a.Color = Library.Flags["net.fakelag.color"]
														a.Material = "ForceField"
														a.Transparency = 0.6
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
											end
										end

										Delay(Library.Flags["net.syncticks"] / 10000, function()
											local isThere = workspace:FindFirstChildOfClass("Seat")

											if isThere then
												isThere:Destroy()
											end

											local sf = workspace

											for _, v in sf:GetChildren() do
												if v:IsA("Seat") or v.Name == "FakeChar" then
													v:Destroy()
												end
											end

											if
												LocalPlayer.Character
												and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
											then
												local h = LocalPlayer.Character.HumanoidRootPart
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
					end
				end)
			)
		end)

		local LagTick = 0
		local lagconn

		CreateThread(function()
			local Sleeping: boolean = false

			Insert(
				Nocturnal.Connections,
				RunService.PostSimulation:Connect(function()
					if
						Nocturnal.LoadComplete
						and Nocturnal:Alive()
						and (Library.Flags["net.lag.key"] == true or Library.Flags["net.fakelag"] == true)
						and Library.Flags["net.lagtype"] == "Physics"
					then
						Sleeping = not Sleeping
						sethiddenproperty(LocalPlayer.Character.HumanoidRootPart, "NetworkIsSleeping", Sleeping)
					end
				end)
			)
		end)

		CreateThread(function()
			while Wait(1 / 20) do
				LagTick = Clamp(LagTick + 1, 0, Library.Flags["net.lagticks"] or 5)
				if
					Nocturnal.LoadComplete
					and Nocturnal:Alive()
					and (Library.Flags["net.fakelag"] == true or Library.Flags["net.lag.key"] == true)
					and Library.Flags["net.lagtype"] == "Instance"
				then
					if rawequal(LagTick, (Random(1, Library.Flags["net.lagticks"]))) then
						Services.NetworkClient:SetOutgoingKBPSLimit(9e9)
						Nocturnal.GetSecuredFolder():ClearAllChildren()
						LagTick = 0

						if Library.Flags["net.fakelag.vis"] then
							local i = InstanceNew("Model", Nocturnal:GetSecuredFolder())
							i.Name = "FakeChar2"

							for _, v: BasePart in LocalPlayer.Character:GetDescendants() do
								if v:IsA("BasePart") and v.Transparency ~= 1 then
									local a = v:Clone()
									a.CanCollide = false
									a.Parent = i
									v.CanQuery = false
									a.Anchored = true
									a.Color = Library.Flags["net.fakelag.color"]
									a.Material = "ForceField"
									a.Transparency = 0.6
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
						end
					else
						if Library.Flags["net.fakelag"] == true or Library.Flags["net.lag.key"] == true then
							Services.NetworkClient:SetOutgoingKBPSLimit(1)
						end
					end
				else
					Nocturnal.GetSecuredFolder():ClearAllChildren()
					Services.NetworkClient:SetOutgoingKBPSLimit(9e9)
				end
			end
		end)

		other
			:Toggle({ Flag = "misc.thirdperson", Text = "Third Person" })
			:Bind({ Flag = "misc.thirdperson.key", Text = "Third Person", Bind = "NONE", Mode = "toggle" })
		other
			:Toggle({ Flag = "misc.fly", Text = "Flight" })
			:Bind({ Flag = "misc.flight.key", Text = "Flight", Bind = "NONE", Mode = "toggle" })
		other:Slider({ Flag = "misc.flyspeed", Text = "Flight Speed", Min = 1, Max = 350, Value = 60, Increment = 1 })

		--// While I did think about using the bunnyhop connection for this, I realized they were overlapping and that it's best to seperate them
		do
			Insert(
				Nocturnal.Connections,
				InputService.InputBegan:Connect(function(Input: InputObject, GameProcessed: boolean): ()
					if GameProcessed then
						return
					end

					if Input.KeyCode == Enum.KeyCode.W then
						Nocturnal.MoveInput.Forward = 1
					elseif Input.KeyCode == Enum.KeyCode.S then
						Nocturnal.MoveInput.Forward = -1
					elseif Input.KeyCode == Enum.KeyCode.A then
						Nocturnal.MoveInput.Right = -1
					elseif Input.KeyCode == Enum.KeyCode.D then
						Nocturnal.MoveInput.Right = 1
					elseif Input.KeyCode == Enum.KeyCode.Space then
						Nocturnal.MoveInput.Up = 1
					elseif Input.KeyCode == Enum.KeyCode.LeftControl then
						Nocturnal.MoveInput.Up = -1
					end
				end)
			)

			Insert(
				Nocturnal.Connections,
				InputService.InputEnded:Connect(function(Input: InputObject): ()
					if Input.KeyCode == Enum.KeyCode.W or Input.KeyCode == Enum.KeyCode.S then
						Nocturnal.MoveInput.Forward = 0
					elseif Input.KeyCode == Enum.KeyCode.A or Input.KeyCode == Enum.KeyCode.D then
						Nocturnal.MoveInput.Right = 0
					elseif Input.KeyCode == Enum.KeyCode.Space or Input.KeyCode == Enum.KeyCode.LeftControl then
						Nocturnal.MoveInput.Up = 0
					end
				end)
			)

			Insert(
				Nocturnal.Connections,
				RunService.RenderStepped:Connect(function(DeltaTime: number): ()
					if not Library.Flags["misc.fly"] or not Library.Flags["misc.flight.key"] then
						return
					end

					if not Nocturnal:Alive() then
						return
					end

					local Root: BasePart? = LocalPlayer.Character.PrimaryPart

					local MoveDirection: Vector3 = Camera.CFrame.LookVector * Nocturnal.MoveInput.Forward
						+ Camera.CFrame.RightVector * Nocturnal.MoveInput.Right
						+ Vec3(0, Nocturnal.MoveInput.Up, 0)

					if MoveDirection.Magnitude > 0 then
						MoveDirection = MoveDirection.Unit
					end

					Root.Velocity = MoveDirection * Library.Flags["misc.flyspeed"]

					if MoveDirection.Magnitude > 0 then
						--// i dont like this
						Root.CFrame = CFrameLookAt(Root.Position, Root.Position + MoveDirection)
					end
				end)
			)
		end

		do
			RunService:BindToRenderStep("Thirdperson", Enum.RenderPriority.Camera.Value + 1, function()
				if not Nocturnal.LoadComplete then
					return
				end

				if Library.Flags["misc.ratio"] then
					Camera.CFrame *= CFrameNew(0, 0, 0, 1, 0, 0, 0, Library.Flags["misc.ratioEffect"], 0, 0, 0, 1)
				end

				if Library.Flags["misc.thirdperson"] or Library.Flags["misc.thirdperson.key"] then
					Camera.CFrame += (Camera.CFrame.LookVector * -10)
				end
			end)
		end

		other:Toggle({ Flag = "misc.ratio", Text = "Aspect Ratio" })
		other:Slider({ Flag = "misc.ratioEffect", Text = "Ratio", Min = 0.1, Max = 1, Value = 0.5, Increment = 0.1 })
		other:Toggle({ Flag = "misc.effects", Text = "Enable fluent effects" })
		other:Dropdown({
			Flag = "misc.easingstyle",
			Text = "Crosshair easing",
			Values = Nocturnal.EasingStylesList,
			Selected = "QuartInOut",
			Callback = function(Value): () end,
		})

		--// Skins
		local KnifeSkinDropdown, AK47SkinDropdown, AWPSkinDropdown

		skins:Toggle({ Flag = "misc.skins", Text = "Enabled" })
		skins:Dropdown({
			Flag = "misc.knife",
			Text = "Knife",
			Values = { "Butterfly Knife", "Karambit", "M9 Bayonet" },
			Selected = "Karambit",
			Callback = function(Option: string): ()
				if KnifeSkinDropdown then
					KnifeSkinDropdown:ClearValues()

					for Index, Skin in ReplicatedStorage.Assets.Skins[Option]:GetChildren() do
						if Skin:IsA("Folder") then
							KnifeSkinDropdown:AddValue(Skin.Name)
						end
					end
				end
			end,
		})

		KnifeSkinDropdown = skins:Dropdown({
			Flag = "misc.knifeskin",
			Text = "Knife Skin",
			Values = {},
			Selected = "Vanilla",
		})

		AK47SkinDropdown = skins:Dropdown({
			Flag = "misc.ak47skin",
			Text = "AK47 Skin",
			Values = {},
			Selected = "Stock",
		})

		AWPSkinDropdown = skins:Dropdown({
			Flag = "misc.awpskin",
			Text = "AWP Skin",
			Values = {},
			Selected = "Stock",
		})

		do
			for Index, Skin in ReplicatedStorage.Assets.Skins["Karambit"]:GetChildren() do
				if Skin:IsA("Folder") then
					KnifeSkinDropdown:AddValue(Skin.Name)
				end
			end

			for Index, Skin in ReplicatedStorage.Assets.Skins["AK-47"]:GetChildren() do
				if Skin:IsA("Folder") then
					AK47SkinDropdown:AddValue(Skin.Name)
				end
			end

			for Index, Skin in ReplicatedStorage.Assets.Skins["AWP"]:GetChildren() do
				if Skin:IsA("Folder") then
					AWPSkinDropdown:AddValue(Skin.Name)
				end
			end
		end
	end
end

--// skin hook
do
	local CoreScript = Nocturnal.Modules[3]
	setreadonly(CoreScript, false)

	local Old
	Old = DetourFn(CoreScript.construct, function(...)
		local Arguments = { ... }
		local Data = Arguments[1]

		if Data and Library.Flags["misc.skins"] and Nocturnal:Alive() then
			Switch(Data.Weapon, {
				["CT Knife"] = function()
					Arguments[1].Weapon = Library.Flags["misc.knife"]
					Arguments[1].Skin = Library.Flags["misc.knifeskin"] == "" and "Vanilla"
						or Library.Flags["misc.knifeskin"]
				end,

				["T Knife"] = function()
					Arguments[1].Weapon = Library.Flags["misc.knife"]
					Arguments[1].Skin = Library.Flags["misc.knifeskin"] == "" and "Vanilla"
						or Library.Flags["misc.knifeskin"]
				end,

				["AK-47"] = function()
					Arguments[1].Skin = Library.Flags["misc.ak47skin"] == "" and "Stock"
						or Library.Flags["misc.ak47skin"]
				end,

				["AWP"] = function()
					Arguments[1].Skin = Library.Flags["misc.awpskin"] == "" and "Stock" or Library.Flags["misc.awpskin"]
				end,
			})
		end

		return Old(Unpack(Arguments))
	end)

	setreadonly(CoreScript, true)
end

--// fov circle
do
	Nocturnal.Circle = Nocturnal:Draw("Circle", {
		Transparency = 1,
		Thickness = 1,
		NumSides = 360,
		Radius = 50,
		Position = Vec2(0, 0),
		Visible = false,
		Outline = true,
		Color = Color3FromRGB(255, 255, 255),
	})

	Nocturnal.DeadzoneCircle = Nocturnal:Draw("Circle", {
		Transparency = 1,
		Thickness = 1,
		NumSides = 360,
		Radius = 5,
		Position = Vec2(0, 0),
		Visible = false,
		Outline = true,
		Color = Color3FromRGB(255, 80, 80),
	})
end

--// legitbot
do
	Insert(
		Nocturnal.Connections,
		RunService.RenderStepped:Connect(function(DeltaTime: number)
			local mousePos = InputService:GetMouseLocation()
			Nocturnal.Circle.Position = mousePos
			Nocturnal.Circle.Visible = Library.Flags["world.fov"]

			local dz = Library.Flags["legit.deadzone"] or 0
			Nocturnal.DeadzoneCircle.Position = mousePos
			Nocturnal.DeadzoneCircle.Radius = dz
			Nocturnal.DeadzoneCircle.Visible = dz > 0 and Library.Flags["world.fov"]

			if Library.Flags["legit.enabled"] and Library.Flags["legit.key"] then
				local targetPlayer, targetPart = Nocturnal:FindBestTarget()

				if targetPlayer and targetPart then
					local camMethod = Library.Flags["legit.cammethod"] or "Mouse"

					if camMethod == "Mouse" then
						local pos, onScreen = Camera:WorldToScreenPoint(targetPart.Position)

						if onScreen then
							local delta = Vec2(pos.X - Mouse.X, pos.Y - Mouse.Y)
							local dist = delta.Magnitude

							local deadzone = Library.Flags["legit.deadzone"] or 0
							local dzType = Library.Flags["legit.deadzone.type"] or "Hard"

							if deadzone > 0 then
								if dzType == "Hard" then
									if dist <= deadzone then
										return
									end
								else
									if dist <= deadzone then
										return
									end

									local scale = Clamp((dist - deadzone) / deadzone, 0, 1)
									delta = delta * scale
								end
							end

							local magnitude = delta
							local smooth = Max(1, Library.Flags["legit.smooth"])

							local humanizerEnabled = Library.Flags["legit.humanizer"]
							if humanizerEnabled and Nocturnal.Humanizer.Sample then
								local Delta = 25 / dist

								if Delta <= 0.8 then
									local CurrentTick = Tick()
									local sample = Nocturnal.Humanizer.Sample[Nocturnal.Humanizer.Index]
									magnitude = magnitude + sample * Delta

									if (CurrentTick - Nocturnal.Humanizer.Tick) > 0.1 then
										Nocturnal.Humanizer.Tick = CurrentTick
										Nocturnal.Humanizer.Index = Nocturnal.Humanizer.Index + 1

										if Nocturnal.Humanizer.Index > #Nocturnal.Humanizer.Sample then
											Nocturnal.Humanizer.Index = 1
										end
									end
								end
							end

							if Library.Flags["legit.smooth"] == 0 then
								mousemoverel(magnitude.x, magnitude.y)
							else
								local method = Library.Flags["legit.meth"]

								if method == "Linear" then
									mousemoverel(magnitude.x / smooth, magnitude.y / smooth)
								elseif method == "Exponential" then
									local factor = 1 - Exp(-smooth * DeltaTime)
									mousemoverel(magnitude.x * factor, magnitude.y * factor)
								elseif method == "EaseInOut" then
									local factor = Sin((1 / smooth) * (Pi / 2))
									mousemoverel(magnitude.x * factor, magnitude.y * factor)
								elseif method == "WeightedAverage" then
									if not Nocturnal.lastMove then
										Nocturnal.lastMove = Vec2(0, 0)
									end

									local move = (magnitude / smooth + Nocturnal.lastMove) / 2
									mousemoverel(move.x, move.y)
									Nocturnal.lastMove = move
								end
							end
						end
					elseif camMethod == "Camera" then
						local camPos = Camera.CFrame.Position
						local targetCF = CFrameNew(camPos, targetPart.Position)

						local smooth = Max(1, Library.Flags["legit.smooth"])
						local method = Library.Flags["legit.meth"]

						local alpha = 1

						if Library.Flags["legit.smooth"] ~= 0 then
							if method == "Linear" then
								alpha = 1 / smooth
							elseif method == "Exponential" then
								alpha = 1 - Exp(-smooth * DeltaTime)
							elseif method == "EaseInOut" then
								alpha = Sin((1 / smooth) * (Pi / 2))
							elseif method == "WeightedAverage" then
								if not Nocturnal.lastCam then
									Nocturnal.lastCam = Camera.CFrame
								end

								targetCF = Nocturnal.lastCam:Lerp(targetCF, 0.5)
								Nocturnal.lastCam = targetCF
								alpha = 1
							end
						end

						Camera.CFrame = Camera.CFrame:Lerp(targetCF, alpha)
					end
				end
			end
		end)
	)
end

--// Chams
do
	local LastEnabled = false

	function RemoveAdorns(Part): ()
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

	function RemoveCharChams(Char): ()
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
			Ad.CFrame = CFrameNew(VecEmpty, Vec3(0, 1, 0))
		elseif Type == "Box" then
			Ad = InstanceNew("BoxHandleAdornment")
			Ad.Size = Part.Size + (SizeOffset or VecEmpty)
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

	CreateThread(function()
		while Wait(2) do
			local Enabled = Library.Flags["chams.enabled"]

			if not Enabled and LastEnabled then
				Nocturnal:ClearAllChams()
			end

			LastEnabled = Enabled

			if not Enabled then
				continue
			end

			local ChamsType = Library.Flags["chams.method"]
			local MainColor = Library.Flags["chams.color"]
			local GlowColor = Library.Flags["chams.outline.color"]
			local Trans = Library.Flags["chams.trans"]

			if ChamsType == "Drawing" then
				Nocturnal:ClearAllChams()
			end

			for _, Entry in Nocturnal.PlayerCache._cache do
				if not Entry.Alive then
					local Char = Entry.PlayerInstance.Character
					if Char then
						RemoveCharChams(Char)
					end

					continue
				end

				local BodyParts = Entry.BodyParts

				for Name, Part in BodyParts do
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
							for _, D in Part:GetChildren() do
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
						local IsHead = Name == "Head" or Name == "FakeHead"

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
									10,
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

								if Library.Flags["chams.outline"] then
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

								if Library.Flags["chams.outline"] then
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

						local Corners = Nocturnal:Corners(Part)
						local Edges = Nocturnal.Edges
						local Points = {}

						for k = 1, #Edges do
							local E = Edges[k]
							Points[#Points + 1] = Corners[E[1]]
							Points[#Points + 1] = Corners[E[2]]
						end

						Ad:AddLines(Points)
					elseif ChamsType == "Highlight" then
						local Char = Entry.PlayerInstance.Character
						if not Char then
							continue
						end

						local Existing = Char:FindFirstChild("Chams")
						if Existing and Existing:IsA("Highlight") then
							Existing.FillColor = MainColor
							Existing.OutlineColor = GlowColor
							Existing.FillTransparency = Trans
						else
							local Highlight = InstanceNew("Highlight", Char)
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

--// Antiaim Thread
do
	local Old, Rotation: any
	Rotation = 0

	Insert(
		Nocturnal.Connections,
		RunService.RenderStepped:Connect(function(DeltaTime: number)
			if not Library.Flags["aa.enabled"] then
				return
			end

			if Nocturnal:Alive() then
				local RootPart: Instance = LocalPlayer.Character.PrimaryPart
				local JitterAmount: number = Library.Flags["aa.jitter"]
				local Method: string = Library.Flags["aa.yaw"]
				local Roll: number = Library.Flags["aa.ud"] and Rad(180) or 0

				Switch(Method, {
					Spin = function()
						Rotation += JitterAmount
						RootPart.CFrame = CFrameNew(RootPart.Position) * CFrameAngles(0, Rotation, Roll)
					end,

					Jitter = function()
						local Delta: number = JitterAmount
						if Random() < 0.5 then
							Delta = -Delta
						end

						Rotation += Delta

						RootPart.CFrame = CFrameNew(RootPart.Position) * CFrameAngles(0, Rotation, Roll)
					end,

					Backward = function()
						RootPart.CFrame = CFrameNew(RootPart.Position) * CFrameAngles(0, Pi, Roll)
					end,

					Freestanding = function()
						RootPart.CFrame = CFrameNew(RootPart.Position)
							* CFrameAngles(0, Rad(Nocturnal:GetFreestandYaw()), Roll)
					end,
				}, function() end)
			end
		end)
	)
end

--// ESP Thread
do
	CreateThread(function()
		while Wait() do
			if not Environment().Nocturnal then
				break
			end
			if not Nocturnal.LoadComplete then
				continue
			end

			local Flags = Library.Flags
			local Enemy = Nocturnal.Sense.teamSettings.enemy

			Enemy.enabled = Flags["esp.enabled"]

			Enemy.box = Flags["esp.box"]
			Enemy.boxColor[1] = Flags["esp.box.color"]

			Enemy.boxFill = Flags["esp.fill"]
			Enemy.boxFillColor[1] = Flags["esp.fill.color"]

			Enemy.healthBar = Flags["esp.health"]
			Enemy.healthyColor = Flags["esp.health.color"]

			Enemy.name = Flags["esp.name"]
			Enemy.nameColor[1] = Flags["esp.name.color"]

			Enemy.skeleton = Flags["esp.skeleton"]
			Enemy.skeletonColor[1] = Flags["esp.skeleton.color"]

			Enemy.distance = Flags["esp.distance"]
			Enemy.distanceColor[1] = Flags["esp.distance.color"]

			Enemy.offScreenArrow = Flags["esp.arrow"]
			Enemy.offScreenArrowColor[1] = Flags["esp.arrow.color"]

			Enemy.chams = Flags["chams.enabled"] and Flags["chams.method"] == "Drawing"
			Enemy.chamsFillColor[1] = Flags["chams.color"]
		end
	end)
end

--// Queue
--[[CreateThread(function(): ()
    queue_on_teleport(
        repeat task.wait() until game:IsLoaded();
        repeat task.wait() until game:GetService("Players").LocalPlayer:FindFirstChild("PlayerScripts");

        task.delay(10, function()
            loadfile("src.lua")();
        end);
    );
end);]]

--// Spread & Recoil hooks
do
	local OldKick

	OldKick = DetourFn(
		Nocturnal.Modules[4].updateCamera,
		newcclosure(function(...)
			if Library.Flags["weapon.norecoil"] then
				return
			end

			return OldKick(...)
		end)
	)

	local OldSpring

	OldSpring = DetourFn(
		Nocturnal.Modules[5].new,
		newcclosure(function(...)
			if Library.Flags["weapon.nobob"] then
				--// To ensure we don't make the entire game error we return a fake table that basically only needs getPosition
				--// Just to be safe

				return {
					update = function(self, dt) end, --// spring:update(dt)
					getPosition = function(self)
						return Vector3.new()
					end, --// spring:getPosition()
					getGoal = function(self) end, --// spring:getGoal()
					setGoal = function(self, goal) end, --// spring:setGoal(goal)
					setPosition = function(self, value) end, -- spring:setPosition(value)
					reset = function(self, value) end, --// spring:reset(value)
					impulse = function(self, value) end, --// spring:impulse(vector)
					setFrequency = function(self, freq) end, --// spring:setFrequency(freq)
					setDampingRatio = function(self, ratio) end, --// spring:setDampingRatio(ratio)
				}
			end

			return OldSpring(...)
		end)
	)
end

--// Workspace hooks
do
	local Old

	Old = hookmetamethod(
		workspace,
		"__namecall",
		newcclosure(function(...: any)
			local Method: string = getnamecallmethod()
			local Arguments: any = Pack(...) --// Pack preserves nils, as {...} does NOT!
			local Self: Instance = Arguments[1]

			--// Only care if it's a workspace raycast and not called by us and if its a Bullet cause their movement also calls Raycast
			if Self == workspace and not checkcaller() then
				if Method == "Raycast" and Arguments[4].CollisionGroup == "Bullet" then
					if Nocturnal:IsValid(Arguments, Nocturnal.RayParameters.Raycast) then
						local RayOrigin: Vector3 = Arguments[2]
						local RayEnd: Vector3 = Arguments[3]

						--// Do the arg spoofs here
						if Library.Flags["rage.silent"] then
							if Library.Flags["rage_as"] and Nocturnal._TargetPart then
								Arguments[3] = Nocturnal:DirectAt(RayOrigin, Nocturnal._TargetPart.Position)
								RayEnd = Arguments[3]
							else
								local _, HitPart = Nocturnal:FindBestTarget()

								if HitPart then
									Arguments[3] = Nocturnal:DirectAt(RayOrigin, HitPart.Position)
									RayEnd = Arguments[3]
								end
							end
						end

						--// Draw bullet tracer
						if Library.Flags["world.btracers"] then
							CreateThread(function()
								local Barrel

								if Nocturnal.ViewmodelPath then
									for _, Descendant in Nocturnal.ViewmodelPath:GetDescendants() do
										if Descendant:IsA("BasePart") then
											local n = Descendant.Name:lower()
											if n:find("barrel") or n:find("bolt") then
												Barrel = Descendant

												break
											end
										end
									end
								end

								local Origin = Barrel and Barrel.Position or RayOrigin

								if not Library.Flags["rage.silent"] then
									local RayParams = RaycastParams.new()
									RayParams.FilterType = Enum.RaycastFilterType.Blacklist
									RayParams.FilterDescendantsInstances = { LocalPlayer.Character, Camera }

									local Direction = Camera.CFrame.LookVector * 1000

									local Result = workspace:Raycast(Origin, Direction, RayParams)

									if Result then
										RayEnd = Result.Position
									end
								end

								Nocturnal:Beam(Origin, RayEnd)
							end)
						end

						return Old(Unpack(Arguments))
					end
				end
			end

			return Old(...)
		end)
	)
end

local Old
Old = DetourFn(Environment().Nocturnal.Unload, function(...)
	for Index, Connection in Nocturnal.Connections do
		if Connection and Connection.Disconnect then
			Connection:Disconnect()
		end
	end

	Nocturnal.LoadComplete = false

	return Old(...)
end)

Nocturnal.LoadComplete = true
