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
	CREDITS - Author: newguy - Inspiration: Octohook, Splix
	
	NOTES:
		- This is a library I made for my own use, it is not meant to be a fully featured library, but it is a good starting point.
		- It is mainly an Octohook fork, as I loved the library, but it felt lacking, so I changed all of the code and alot of the design.
		- Please credit @newguy & @liam when using this.

	I optimized this library until there was no beyond, There is no more drag-lag like there was with original Octohook.
]]

--// Services
local Services: { [string]: any } = setmetatable({}, {
	__index = function(self: any, idx: string): any
		return game:GetService(idx);
	end
})

--// definitions
local environment: any =
	(getgenv and function(): any
		return getgenv()
	end)

	or function(): { [string]: any }
		return {}
	end

local makefolder: (path: string) -> () = makefolder or function(_: string): () end
local isfolder: (path: string) -> boolean = isfolder or function(_: string): boolean return false end
local isfile: (path: string) -> boolean = isfile or function(_: string): boolean return false end
local writefile: (path: string, contents: string) -> () = writefile or function(_: string, _: string): () end
local readfile: (path: string) -> string = readfile or function(_: string): string return "" end

local request: ((options: any) -> any)? =
	(syn and syn.request)
	or (http and http.request)
	or request

local getcustomasset: (path: string) -> string =
	getcustomasset or function(_: string): string return "" end

--// math
local math_floor: (number) -> number = math.floor
local math_ceil: (number) -> number = math.ceil
local math_abs: (number) -> number = math.abs
local math_sign: (number) -> number =
	math.sign or function(x: number): number
		if x > 0 then
			return 1
		elseif x < 0 then
			return -1
		else
			return 0
		end
	end

local math_max: (...number) -> number = math.max
local math_min: (...number) -> number = math.min
local math_sqrt: (number) -> number = math.sqrt
local math_pow: (number, number) -> number = math.pow
local math_exp: (number) -> number = math.exp
local math_log: (number, number?) -> number = math.log

local math_log10: (number) -> number =
	math.log10 or function(x: number): number
		return math.log(x, 10)
	end

local math_sin: (number) -> number = math.sin
local math_cos: (number) -> number = math.cos
local math_tan: (number) -> number = math.tan
local math_asin: (number) -> number = math.asin
local math_acos: (number) -> number = math.acos
local math_atan: (number) -> number = math.atan
local math_atan2: (number, number) -> number = math.atan2
local math_pi: number = math.pi
local math_huge: number = math.huge
local math_random: (number?, number?) -> number = math.random
local math_randomseed: (number) -> () = math.randomseed or function(_: number): () end
local math_rad: (number) -> number = math.rad
local math_deg: (number) -> number = math.deg

local math_clamp: (number, number, number) -> number =
	function(value: number, min: number, max: number): number
		return (value < min and min) or (value > max and max) or value
	end

local math_lerp: (number, number, number) -> number =
	math.lerp or function(a: number, b: number, t: number): number
		return a + (b - a) * t
	end

local math_round: (number) -> number =
	math.round or function(x: number): number
		return math_floor(x + 0.5)
	end

local math_isfinite: (number) -> boolean =
	(math.type and function(x: number): boolean
		return math.type(x) == "number" and x == x and x ~= math_huge and x ~= -math_huge
	end)
	or function(_: number): boolean
		return true
	end

--// table
local table_insert: <T>(tbl: { T }, value: T) -> () = table.insert
local table_remove: <T>(tbl: { T }, index: number?) -> T? = table.remove
local table_concat: (tbl: { string }, sep: string?, i: number?, j: number?) -> string = table.concat
local table_sort: <T>(tbl: { T }, comp: ((T, T) -> boolean)?) -> () = table.sort

local table_find: <T>(tbl: { T }, value: T) -> number? =
	table.find or function<T>(t: { T }, v: T): number?
		for i = 1, #t do
			if t[i] == v then
				return i
			end
		end
		return nil
	end

local table_clear: (tbl: { [any]: any }) -> () =
	table.clear or function(t: { [any]: any }): ()
		for k in t do
			t[k] = nil
		end
	end

local table_clone: <T>(tbl: T) -> T =
	table.clone or function<T>(t: T): T
		local n: any = {}
		for k, v in t do
			n[k] = v
		end
		return n
	end

local table_move: (src: { any }, f: number, l: number, idx: number, dst: { any }) -> { any } =
	table.move or function(src: { any }, f: number, l: number, idx: number, dst: { any }): { any }
		for i = f, l do
			dst[idx + i - f] = src[i]
		end
		return dst
	end

local table_pack: (...any) -> { n: number, [number]: any } =
	table.pack or function(...: any): { n: number, [number]: any }
		return { n = select("#", ...), ... }
	end

local table_freeze: <T>(tbl: T) -> T =
	table.freeze or function<T>(_: T): T
		return {} :: any
	end

local table_unpack: <T>(tbl: { T }, i: number?, j: number?) -> ...T = table.unpack or unpack
local table_create: (number, any?) -> { any } = table.create

--// string
local string_byte: (string, number?, number?) -> ...number = string.byte
local string_char: (...number) -> string = string.char
local string_sub: (string, number, number?) -> string = string.sub
local string_len: (string) -> number = string.len
local string_lower: (string) -> string = string.lower
local string_upper: (string) -> string = string.upper
local string_find: (string, string, number?, boolean?) -> (number?, number?, ...string) = string.find
local string_gsub: (string, string, string | ((...any) -> string), number?) -> (string, number) = string.gsub
local string_gmatch: (string, string) -> (() -> string?) = string.gmatch
local string_match: (string, string, number?) -> string? = string.match
local string_rep: (string, number, string?) -> string = string.rep
local string_reverse: (string) -> string = string.reverse

local string_split: (string, string) -> { string } =
	string.split or function(s: string, sep: string): { string }
		local out: { string } = {}
		for part in s:gmatch("([^" .. sep .. "]+)") do
			table_insert(out, part)
		end
		return out
	end

local string_format: (string, ...any) -> string = string.format
local string_trim: (string) -> string =
	string.trim or function(s: string): string
		return s:match("^%s*(.-)%s*$") or ""
	end

--// os / task
local os_time: () -> number = os.time
local os_clock: () -> number = os.clock
local os_date: (string?, number?) -> any = os.date
local os_difftime: (number, number) -> number = os.difftime

local tick: () -> number = tick or os_time
local time: () -> number = time

local task_wait: (number?) -> number = (task and task.wait) or wait
local task_spawn: (thread | (() -> ()), ...any) -> () = (task and task.spawn) or spawn
local task_defer: ((...any) -> (), ...any) -> () =
	(task and task.defer)
	or function(f: (...any) -> (), ...: any): ()
		local co = coroutine.create(f)
		coroutine.resume(co, ...)
	end

local task_delay: (number, (...any) -> (), ...any) -> () = (task and task.delay) or delay
local task_cancel: (thread) -> () = (task and task.cancel) or function(_: thread): () end
local wait: (number?) -> number = task_wait

--// bit
local bit_band: (number, number) -> number =
	(bit32 and bit32.band)
	or function(a: number, b: number): number
		local r = 0
		local bit = 1
		for _ = 0, 31 do
			local A = a % 2
			local B = b % 2
			if A == 1 and B == 1 then
				r += bit
			end
			a = math_floor(a / 2)
			b = math_floor(b / 2)
			bit *= 2
		end
		return r
	end

local bit_bor: (number, number) -> number =
	(bit32 and bit32.bor)
	or function(a: number, b: number): number
		local r = 0
		local bit = 1
		for _ = 0, 31 do
			local A = a % 2
			local B = b % 2
			if A == 1 or B == 1 then
				r += bit
			end
			a = math_floor(a / 2)
			b = math_floor(b / 2)
			bit *= 2
		end
		return r
	end

local bit_xor: (number, number) -> number =
	(bit32 and bit32.bxor)
	or function(a: number, b: number): number
		return (a + b) - 2 * (a ^ b)
	end

local bit_lshift: (number, number) -> number =
	(bit32 and bit32.lshift) or function(a: number, n: number): number
		return a * (2 ^ n)
	end

local bit_rshift: (number, number) -> number =
	(bit32 and bit32.rshift) or function(a: number, n: number): number
		return math_floor(a / (2 ^ n))
	end

local bit_not: (number) -> number =
	(bit32 and bit32.bnot) or function(a: number): number
		return 2 ^ a
	end

--// roblox
local vec2: (number, number) -> Vector2 = Vector2.new
local vec3: (number, number, number) -> Vector3 = Vector3.new
local udim2_new: (number, number, number, number) -> UDim2 = UDim2.new
local udim_new: (number, number) -> UDim = UDim.new
local instance_new: (string) -> Instance = Instance.new
local color3_new: (number, number, number) -> Color3 = Color3.new
local color3_fromRGB: (number, number, number) -> Color3 = Color3.fromRGB
local color3_fromHSV: (number, number, number, number) -> Color3 = Color3.fromHSV
local cframe_new: (...any) -> CFrame = CFrame.new

local color_sequence: (any) -> ColorSequence = ColorSequence.new
local color_sequence_keypoint: (number, Color3) -> ColorSequenceKeypoint = ColorSequenceKeypoint.new
local number_sequence: (any) -> NumberSequence = NumberSequence.new
local number_sequence_keypoint: (number, number, number?) -> NumberSequenceKeypoint =
	NumberSequenceKeypoint.new

--// services
local context_action_service: ContextActionService = Services.ContextActionService
local http_service: HttpService = Services.HttpService
local run_service: RunService = Services.RunService
local tween_service: TweenService = Services.TweenService
local replicated_storage: ReplicatedStorage = Services.ReplicatedStorage
local input_service: UserInputService = Services.UserInputService
local player_service: Players = Services.Players

local player_local: Player? = player_service.LocalPlayer
local get_mouse_location: Vector2 = input_service.GetMouseLocation
local SetByConfig: boolean = false


--// unload hook
if environment and environment().Nocturnal ~= nil and rawequal(typeof(environment().Nocturnal.Unload), "function") then
	pcall(environment().Nocturnal.Unload, 1)
end

--// types
type Orders = { [string]: number };

type States = { Stage: string, Status: boolean };

type Months = { [number]: string };

type Filesystem = { Root: string, Children: { string } };

type Library = { [any]: any };

type ThemeColors = { [string]: Color3 };

type ThemeEntry = { Theme: ThemeColors, Name: string };

type Utility = { MouseOver: (self: Utility, Object: any) -> boolean };

type IndexCallback = (Table: any, Key: any) -> any;

type NewIndexCallback = (Table: any, Key: any, Value: any) -> ();

type ThreadJob = { [number]: any } | { [string]: any };


export type Listener = {
	id: number,
	callback: (...any) -> (),
	once: boolean,
};

export type Connection = {
	Connected: boolean,
	Disconnect: (self: Connection) -> (),
};

export type SignalClass = {
	Connect: (self: SignalClass, callback: (...any) -> ()) -> Connection,
	Once: (self: SignalClass, callback: (...any) -> ()) -> Connection,
	Fire: (self: SignalClass, ...any) -> (),
	Wait: (self: SignalClass) -> ...any,
	Destroy: (self: SignalClass) -> (),
	GetConnectionCount: (self: SignalClass) -> number,
	IsDestroyed: (self: SignalClass) -> boolean,
};

type DrawingObject = {
	Object: any,
	Children: { [any]: DrawingObject },
	ThemeColor: string,
	OutlineThemeColor: string,
	ThemeColorOffset: number,
	OutlineThemeColorOffset: number,
	Parent: DrawingObject?,
	Size: Vector2,
	Position: Vector2,
	AbsoluteSize: Vector2,
	AbsolutePosition: Vector2,
	Hover: boolean,
	Visible: boolean,

	MouseButton1Down: any,
	MouseButton2Down: any,
	MouseButton1Up: any,
	MouseButton2Up: any,
	MouseEnter: any,
	MouseLeave: any,

	Class: string,

	Update: (self: DrawingObject) -> (),
	UpdateChildren: (self: DrawingObject) -> (),
	GetDescendants: (self: DrawingObject) -> { DrawingObject },
	Remove: (self: DrawingObject) -> (),
};

local Library: Library = {
	Connections = { },

	Filesystem = {
		Root = "nocturnal",
		Children = { "fonts", "assets", "configs" },
	} :: Filesystem,

	Indicators = { },

	Instances = { },

	Watermark = { },

	Drawings = { },

	Utility = { },

	Options = { },

	Windows = { },

	Tweens = { },

	Flags = { },

	Stats = { },

	Images = {
		['gradientp90'] = 'https://raw.githubusercontent.com/portallol/luna/main/modules/gradient90.png',
		['gradientp45'] = 'https://raw.githubusercontent.com/portallol/luna/main/modules/gradient45.png',
		['colorhue'] = 'https://raw.githubusercontent.com/portallol/luna/main/modules/lgbtqshit.png',
		['colortrans'] = 'https://raw.githubusercontent.com/portallol/luna/main/modules/trans.png',
	},

	Months = {
		[1] = "January",
		[2] = "February",
		[3] = "March",
		[4] = "April",
		[5] = "May",
		[6] = "June",
		[7] = "July",
		[8] = "August",
		[9] = "September",
		[10] = "October",
		[11] = "November",
		[12] = "December",
	} :: Months,

	Order = {
		Notification = 1400,
		Colorpicker = 1100,
		Watermark = 1300,
		Dropdown = 1200,
		Indicator = 950,
		Cursor = 1500,
		Window = 1000,
	} :: Orders,

	State = {
		Stage = "N/A",
		Status = false,
	} :: States,

	Themes = {
		{
			["Theme"] = {
				['Accent']                = color3_fromRGB(255,135,255);
				['Background']                = color3_fromRGB(18,18,18);
				['Border']                    = color3_fromRGB(0,0,0);
				['Border 1']                  = color3_fromRGB(60,60,60);
				['Border 2']                  = color3_fromRGB(35,35,35);
				['Border 3']                  = color3_fromRGB(10,10,10);
				['Primary Text']              = color3_fromRGB(235,235,235);
				['Group Background']          = color3_fromRGB(35,35,35);
				['Selected Tab Background']   = color3_fromRGB(35,35,35);
				['Unselected Tab Background'] = color3_fromRGB(18,18,18);
				['Selected Tab Text']         = color3_fromRGB(245,245,245);
				['Unselected Tab Text']       = color3_fromRGB(145,145,145);
				['Section Background']        = color3_fromRGB(18,18,18);
				['Option Text 1']             = color3_fromRGB(245,245,245);
				['Option Text 2']             = color3_fromRGB(195,195,195);
				['Option Text 3']             = color3_fromRGB(145,145,145);
				['Option Border 1']           = color3_fromRGB(50,50,50);
				['Option Border 2']           = color3_fromRGB(0,0,0);
				['Option Background']         = color3_fromRGB(35,35,35);
				["Risky Text"]                = color3_fromRGB(175, 21, 21);
				["Risky Text Enabled"]        = color3_fromRGB(255, 41, 41);
			} :: ThemeColors,

			Name = "Nocturnal",
		},
	},

	ScriptData = {
		{
			[1] = "nocturnal_remastered",
			[2] = "Rivals"
		}
	},

	Theme = "Nocturnal",

	Open = false,

	Opening = false,

	CurrentTheme = {
		['Accent']                    = Color3.fromRGB(160, 115, 136);
		['Background']                = Color3.fromRGB(27, 27, 40);
		['Border']                    = Color3.fromRGB(0, 0, 0);
		['Border 1']                  = Color3.fromRGB(60, 60, 70);
		['Border 2']                  = Color3.fromRGB(35, 35, 50);
		['Border 3']                  = Color3.fromRGB(12, 12, 18);
		['Primary Text']              = Color3.fromRGB(240, 240, 240);
		['Group Background']          = Color3.fromRGB(30, 30, 45);
		['Selected Tab Background']   = Color3.fromRGB(30, 30, 45);
		['Unselected Tab Background'] = Color3.fromRGB(27, 27, 40);
		['Selected Tab Text']         = Color3.fromRGB(245, 245, 245);
		['Unselected Tab Text']       = Color3.fromRGB(150, 150, 150);
		['Section Background']        = Color3.fromRGB(27, 27, 40);
		['Option Text 1']             = Color3.fromRGB(245, 245, 245);
		['Option Text 2']             = Color3.fromRGB(200, 200, 200);
		['Option Text 3']             = Color3.fromRGB(150, 150, 150);
		['Option Border 1']           = Color3.fromRGB(60, 60, 70);
		['Option Border 2']           = Color3.fromRGB(0, 0, 0);
		['Option Background']         = Color3.fromRGB(30, 30, 45);
		["Risky Text"]                = Color3.fromRGB(190, 50, 50);
		["Risky Text Enabled"]        = Color3.fromRGB(255, 80, 80);
	} :: ThemeColors,


	BlacklistedKeys = {
		Enum.KeyCode.Unknown,
		Enum.KeyCode.W,
		Enum.KeyCode.A,
		Enum.KeyCode.S,
		Enum.KeyCode.D,
		Enum.KeyCode.Slash,
		Enum.KeyCode.Tab,
		Enum.KeyCode.Escape
	},

	WhitelistedBoxKeys = {
		Enum.KeyCode.Zero,
		Enum.KeyCode.One,
		Enum.KeyCode.Two,
		Enum.KeyCode.Three,
		Enum.KeyCode.Four,
		Enum.KeyCode.Five,
		Enum.KeyCode.Six,
		Enum.KeyCode.Seven,
		Enum.KeyCode.Eight,
		Enum.KeyCode.Nine
	},

	KeyNames = {
		[Enum.KeyCode.LeftControl] = 'LCTRL';
		[Enum.KeyCode.RightControl] = 'RCTRL';
		[Enum.KeyCode.LeftShift] = 'LSHIFT';
		[Enum.KeyCode.RightShift] = 'RSHIFT';
		[Enum.UserInputType.MouseButton1] = 'MB1';
		[Enum.UserInputType.MouseButton2] = 'MB2';
		[Enum.UserInputType.MouseButton3] = 'MB3';
	},
	
	Notifications = { }
};

local Signal, Utility = { }, { } :: Utility;
Signal.__index = Signal

--// signal impl
do
	function Signal.new(): SignalClass
		local self = setmetatable({
			_listeners = {} :: {[number]: Listener},
			_nextId = 0,
			_destroyed = false,
		}, Signal)

		return (self :: any) :: SignalClass
	end

	function Signal:Connect(callback: (...any) -> ()): Connection
		assert(typeof(callback) == "function", "Signal:Connect expects a function")
		assert(not self._destroyed, "signal has been destroyed")

		self._nextId = self._nextId + 1
		local id = self._nextId
		local listener: Listener = { id = id, callback = callback, once = false }
		self._listeners[id] = listener

		local signalRef = self
		local connection: Connection = {
			Connected = true,
			Disconnect = function(conn: Connection)
				if not conn.Connected then
					return
				end
				conn.Connected = false
				if signalRef and signalRef._listeners then
					signalRef._listeners[id] = nil
				end
			end,
		}

		return connection
	end

	function Signal:Once(callback: (...any) -> ()): Connection
		assert(typeof(callback) == "function", "Signal:Once expects a function")
		assert(not self._destroyed, "signal has been destroyed")

		self._nextId = self._nextId + 1
		local id = self._nextId
		local listener: Listener = { id = id, callback = callback, once = true }
		self._listeners[id] = listener

		local signalRef = self
		local connection: Connection = {
			Connected = true,
			Disconnect = function(conn: Connection)
				if not conn.Connected then
					return
				end
				conn.Connected = false
				if signalRef and signalRef._listeners then
					signalRef._listeners[id] = nil
				end
			end,
		}

		return connection
	end

	function Signal:Fire(...: any)
		if self._destroyed then
			return
		end

		local snapshot: { Listener } = {}
		local snapN = 0
		for _, listener in pairs(self._listeners) do
			snapN = snapN + 1
			snapshot[snapN] = listener
		end

		for i = 1, snapN do
			local listener = snapshot[i]
			if listener and self._listeners[listener.id] == listener then
				local ok, err = pcall(listener.callback, ...)
				if not ok then
					warn(("[signal] callback error: %s"):format(tostring(err)))
				end
				if listener.once then
					self._listeners[listener.id] = nil
				end
			end
		end
	end

	function Signal:Wait()
		assert(not self._destroyed, "signal has been destroyed")
		local thread = coroutine.running()
		assert(thread ~= nil, "Signal:Wait() must be called from a coroutine")

		local resumed = false
		local values: { any } = {}

		local conn
		conn = self:Connect(function(...: any)
			if conn then
				conn:Disconnect()
			end

			if not resumed then
				resumed = true
				values = { ... }
				coroutine.resume(thread, table_unpack(values))
			end
		end)

		return coroutine.yield()
	end

	function Signal:Destroy()
		if self._destroyed then
			return
		end
		self._listeners = {}
		self._destroyed = true
	end

	function Signal:GetConnectionCount(): number
		local count = 0
		for _ in self._listeners do
			count = count + 1
		end

		return count
	end

	function Signal:IsDestroyed(): boolean
		return self._destroyed == true
	end
end;

--// event impl
Library.button1down = Signal.new();
Library.button1up   = Signal.new();
Library.mousemove   = Signal.new();
Library.Unloaded    = Signal.new();

local Button1Down, Button1Up, MouseMove = Library.button1down, Library.button1up, Library.mousemove
local DrawingOriginalTransparency = {} -- [object] = originalTransparency
local DrawingFadeThreads = {} -- store current fade coroutine per object
local DrawingDoNotFade = {}

local MB1Down = false;


--// util impl
do
	function Utility:Connection(SignalParam: RBXScriptConnection, Func: (...any) -> ()): RBXScriptConnection
		local Conn = SignalParam:Connect(Func);
		table_insert(Library.Connections, Conn);

		return Conn;
	end

	function Utility:Instance(Class: string, Properties: { [string]: any }?): Instance
		local Inst: Instance = instance_new(Class);
		local Props: { [string]: any } = Properties or {};

		for Prop, Val in Props do
			local Success, Err = pcall(function()
				Inst[Prop] = Val;
			end);

			if not Success then
				warn("[nocturnal] error.");
			end;
		end;

		return Inst;
	end

	function Utility:HasProperty(Obj: Instance, Prop: string): boolean
		local Success: boolean = (pcall(function() local _ = Obj[Prop] end))

		return Success;
	end;

	function Utility:ToRGB(C3: Color3): (number, number, number)
		return C3.R * 255, C3.G * 255, C3.B * 255;
	end;

	function Utility:AddRGB(A: Color3, B: Color3): Color3
		local R1, G1, B1 = self:ToRGB(A)
		local R2, G2, B2 = self:ToRGB(B)

		return color3_fromRGB(
			math_clamp(R1 + R2, 0, 255),
			math_clamp(G1 + G2, 0, 255),
			math_clamp(B1 + B2, 0, 255)
		);
	end;

	function Utility:ConvertNumberRange(Val: number, OldMin: number, OldMax: number, NewMin: number, NewMax: number): number
		return ((Val - OldMin) * (NewMax - NewMin)) / (OldMax - OldMin) + NewMin;
	end;

	function Utility:UDim2ToVector2(UDim: UDim2, Vector: Vector2): Vector2
		local X: number = UDim.X.Offset + self:ConvertNumberRange(UDim.X.Scale, 0, 1, 0, Vector.X);
		local Y: number = UDim.Y.Offset + self:ConvertNumberRange(UDim.Y.Scale, 0, 1, 0, Vector.Y);

		return vec2(X, Y);
	end;

	function Utility:Lerp(A: number, B: number, T: number): number
		return A + (B - A) * T;
	end;

	function Utility:LerpTween(InstanceObj: any, InstanceTo: { [string]: number }, InstanceTime: number): ()
		local CurrentTime: number = 0
		local CurrentIndex: { [string]: number } = {}
		local Connection: RBXScriptConnection?

		for Property, Value in InstanceTo do
			CurrentIndex[Property] = InstanceObj[Property]
		end

		local function Interpolate(): ()
			for Property, TargetValue in InstanceTo do
				local StartValue = CurrentIndex[Property] or 0
				InstanceObj[Property] = ((TargetValue - StartValue) * CurrentTime / InstanceTime) + StartValue
			end
		end

		Connection = run_service.RenderStepped:Connect(function(Delta: number): ()
			if CurrentTime < InstanceTime then
				CurrentTime = CurrentTime + Delta
				Interpolate()
			else
				Connection:Disconnect()
			end
		end)
	end



	function Utility:Tween(Obj: Instance, Prop: string, Val: any, Time: number, Direction: Enum.EasingDirection?, Style: Enum.EasingStyle?): { Completed: any; Cancel: () -> () }
		if not self:HasProperty(Obj, Prop) then
			warn('Unable to tween: invalid property '..tostring(Prop)..' for object '..tostring(Obj), 255, 0, 0);
			return;
		end;

		local Tweens = Library.Tweens;
		Tweens[Obj] = Tweens[Obj] or {};

		if Tweens[Obj][Prop] then
			Tweens[Obj][Prop]:Cancel();
		end;

		local StartVal: any = Obj[Prop];
		local IsNumber: boolean = typeof(StartVal) == 'number';
		local Progress: number = 0;

		local TweenObj: { Completed: any; Connection: RBXScriptConnection?; Cancel: () -> () } = {
			Completed = Signal.new();
		};

		Tweens[Obj][Prop] = TweenObj;

		local Dir: Enum.EasingDirection = Direction or Enum.EasingDirection.In;
		local Sty: Enum.EasingStyle = Style or Enum.EasingStyle.Linear;

		TweenObj.Connection = self:Connection(run_service.RenderStepped, function(Dt: number): ()
			Progress += Dt / Time;
			if Progress >= 1 or not Obj or not Obj.Parent then
				TweenObj:Cancel();
				return;
			end;

			local Success, Result = pcall(function(): any
				local P: number = tween_service:GetValue(Progress, Sty, Dir);
				if IsNumber then
					return Utility:Lerp(StartVal, Val, P);
				else
					return StartVal:Lerp(Val, P);
				end;
			end);

			if Success then
				Obj[Prop] = Result;
			end;
		end);

		function TweenObj:Cancel(): ()
			if TweenObj.Connection then
				TweenObj.Connection:Disconnect();
				TweenObj.Connection = nil;
			end;

			TweenObj.Completed:Fire();
			Tweens[Obj][Prop] = nil;
			table_clear(TweenObj);
		end;

		return TweenObj;
	end;


	function Utility:DetectTableChange(
		IndexCallback: IndexCallback?,
		NewIndexCallback: NewIndexCallback?
	): userdata
		if IndexCallback == nil then
			warn("DetectTableChange: Argument #1 (IndexCallback) is nil, function may not work as expected.");
		elseif NewIndexCallback == nil then
			warn("DetectTableChange: Argument #2 (NewIndexCallback) is nil, function may not work as expected.");
		end;

		local Proxy: userdata = newproxy(true);
		local Mt: { } = getmetatable(Proxy) :: { };

		Mt.__index = IndexCallback;
		Mt.__newindex = NewIndexCallback;

		return Proxy;
	end

	function Utility:MouseOver(Object: any): boolean
		local Mouse: Vector2 = get_mouse_location(input_service);
		local Pos, Size: Vector2 = Object.Position, Object.Size;
		local MX, MY, X1, Y1, X2, Y2: number = Mouse.X, Mouse.Y, Pos.X, Pos.Y, Pos.X + Size.X, Pos.Y + Size.Y;

		return MX >= X1 and MX <= X2 and MY >= Y1 and MY <= Y2;
	end;

	function Utility:GetHoverObject(): any?
		local Drawings: any = Library.Drawings;
		local TopObject: any? = nil;
		local MaxZIndex: number = -math_huge;

		for Idx, Value in Drawings do
			local Obj: any = Value.Object;
			local Class: string = Value.Class;

			if rawequal(Class, "Square") and Obj.Visible and self:MouseOver(Obj) then
				local Z: number = Obj.ZIndex;
				if Z > MaxZIndex then
					MaxZIndex = Z;
					TopObject = Obj;
				end;
			end;
		end;

		return TopObject;
	end;

	function Utility:Draw(Class: string, Properties: { [string]: any }?): any
		local BlacklistedProperties: { string } = { "Object", "Children", "Class" }

		local DrawingObj: DrawingObject = {
			Object = Drawing.new(Class),
			Children = {},
			ThemeColor = "",
			OutlineThemeColor = "",
			ThemeColorOffset = 0,
			OutlineThemeColorOffset = 0,
			Parent = nil,
			Size = udim2_new(0,0,0,0),
			Position = udim2_new(0,0,0,0),
			AbsoluteSize = vec2(0,0),
			AbsolutePosition = vec2(0,0),
			Hover = false,
			Visible = true,
			MouseButton1Down = Signal.new(),
			MouseButton2Down = Signal.new(),
			MouseButton1Up = Signal.new(),
			MouseButton2Up = Signal.new(),
			MouseEnter = Signal.new(),
			MouseLeave = Signal.new(),
			Class = Class,
		} :: DrawingObject

		function DrawingObj:UpdateChildren(): ()
			for _, Child in self.Children do
				Child:Update();
			end;
		end

		function DrawingObj:Update(): ()
			local Parent: DrawingObject? = self.Parent and Library.Drawings[self.Parent.Object] or nil;
			local ParentSize, ParentPos, ParentVis: Vector2, Vector2, boolean = workspace.CurrentCamera.ViewportSize, vec2(0,0), true;

			if Parent then
				local ObjClass = Parent.Class;
				ParentSize = (ObjClass == "Square" or ObjClass == "Image") and Parent.Object.Size
					or ObjClass == "Text" and Parent.TextBounds
					or workspace.CurrentCamera.ViewportSize;
				ParentPos = Parent.Object.Position;
				ParentVis = Parent.Object.Visible;
			end;

			local IsSquareOrImage = (self.Class == "Square" or self.Class == "Image");
			local IsRenderable = IsSquareOrImage or self.Class == "Circle" or self.Class == "Text";

			if IsSquareOrImage then
				self.Object.Size = typeof(self.Size) == "Vector2" and self.Size or Utility:UDim2ToVector2(self.Size, ParentSize);
			end;

			if IsRenderable then
				self.Object.Position = ParentPos + (typeof(self.Position) == "Vector2" and self.Position or Utility:UDim2ToVector2(self.Position, ParentSize));
			end;

			self.Object.Visible = ParentVis and self.Visible;

			self:UpdateChildren();
		end;

		function DrawingObj:GetDescendants(): { DrawingObject }
			local Descendants: { DrawingObject } = {};

			local function AddChildren(T: DrawingObject)
				for _, V in T.Children do
					table_insert(Descendants, V);
					AddChildren(V);
				end;
			end;

			AddChildren(self);

			return Descendants;
		end;

		function DrawingObj:Remove(): ()
			for _, Child in self.Children do
				if Child.Remove then
					Child:Remove();
				end
			end;

			if self.Parent then
				self.Parent.Children[self.Object] = nil;
			end;

			Library.Drawings[self.Object] = nil;
			self.Object:Remove();
			
			pcall(function()
				table_clear(self);
			end)
		end;

		Properties = typeof(Properties) == "table" and Properties or {};

		if rawequal(Class, "Square") and Properties.Filled == nil then
			Properties.Filled = true;
		end;

		if Properties.Visible == nil then
			Properties.Visible = true;
		end;

		local Proxy = self:DetectTableChange(
			function(_, Key)
				return DrawingObj[Key] == nil and DrawingObj.Object[Key] or DrawingObj[Key];
			end,

			function(_, Key, Value)
				if not table_find(BlacklistedProperties, Key) then
					local LastVal = DrawingObj[Key];

					if Key == "Size" and (Class == "Square" or Class == "Image") then
						DrawingObj.Object.Size = Utility:UDim2ToVector2(Value, DrawingObj.Parent and DrawingObj.Parent.Object.Size or workspace.CurrentCamera.ViewportSize);
						DrawingObj.AbsoluteSize = DrawingObj.Object.Size;
					elseif Key == "Position" and (Class == "Square" or Class == "Image" or Class == "Text") then
						DrawingObj.Object.Position = Utility:UDim2ToVector2(Value, DrawingObj.Parent and DrawingObj.Parent.Object.Position or vec2(0,0));
						DrawingObj.AbsolutePosition = DrawingObj.Object.Position;
					elseif Key == "Parent" then
						if DrawingObj.Parent then
							DrawingObj.Parent.Children[DrawingObj.Object] = nil;
						end;
						if Value then
							table_insert(Value.Children, DrawingObj);
						end;
					elseif Key == "Visible" then
						DrawingObj.Visible = Value;
					elseif Key == "Font" and Value == 2 then
						Value = 1;
					end;

					pcall(function()
						DrawingObj.Object[Key] = Value;
					end);

					if DrawingObj[Key] ~= nil or Key == "Parent" then
						DrawingObj[Key] = Value;
					end;

					if table_find({ "Size", "Position", "Visible", "Parent" }, Key) then
						DrawingObj:Update();
					end;

					if table_find({ "ThemeColor", "OutlineThemeColor", "ThemeColorOffset", "OutlineThemeColorOffset" }, Key) and LastVal ~= Value then
						Library:UpdateThemeColors();
					end;
				end;
			end
		);

		for Key, Value in Properties do
			Proxy[Key] = Value;
		end;

		Library.Drawings[DrawingObj.Object] = DrawingObj;
		DrawingObj:Update();

		return Proxy;
	end;

	function Utility:CreateThread(func: (...any) -> (), ...: any): thread
		return task_spawn(func, ...);
	end;

	function Utility:MultiThreadList(obj: ThreadJob, ...: any): thread
		local count = #obj;
		if count == 0 then return end;

		if (obj[1] ~= nil) then
			for i = 1, count do
				local item = obj[i];
				if type(item) == "table" then
					local fn = item[1];
					local args = item[2];
					if type(fn) == "function" then
						if args and type(args) == "table" then
							task_spawn(fn, table_unpack(args));
						else
							task_spawn(fn);
						end;
					end;
				elseif type(item) == "function" then
					task_spawn(item, ...);
				end;
			end;
		else
			for _, threadFn in obj do
				if type(threadFn) == "function" then
					task_spawn(threadFn, ...);
				end;
			end;
		end;
	end;

	Library.Utility = Utility;
end;

--// library impl
do
	function Library:Unload(): ()

		self.Unloaded:Fire();

		local Conns: { RBXScriptConnection } = self.Connections;

		for i = 1, #Conns do
			Conns[i]:Disconnect();
		end;

		local Draws = self.Drawings;

		for Obj, DrawingObj in Draws do
			DrawingObj:Remove();
		end;

		table_clear(Draws);
		
		if environment and environment().Library then
			environment().Nocturnal = nil;
		end;
		
		context_action_service:UnbindAction('FreezeMovement');
	end;

	function Library:Init(): ()
		--// initialization
		if rawequal(self.State.Stage, "Complete") then return end;

		local TooltipObjects: { [string]: any } = {};
		local utility: { } = Library.Utility;
		local CheatName: string = self.ScriptData[1][1];
		local Game: string = self.ScriptData[1][2];

		if not isfolder(CheatName) or not isfolder(CheatName .. '/' .. Game) then
			makefolder( CheatName );
			makefolder( CheatName .. '/assets' );
			makefolder( CheatName .. '/' .. Game );
			makefolder( CheatName .. '/' .. Game  .. '/configs' );
		end;

		--// theme
		function self:SetTheme(Theme: { [string]: any }): ()
			for K, V in Theme do
				self.Theme[K] = V;
			end;

			self:UpdateThemeColors();
		end;

		--// configs
		function self:GetConfig(Name: string): string?
			local Path: string = CheatName .. '/' .. Game .. '/configs/' .. Name .. ".json";

			if isfile(Path) then
				return readfile(Path);
			end;
		end;

		function self:LoadConfig(Name: string): ()
			local Cfg: string? = self:GetConfig(Name);

			if not Cfg then
				self:SendNotification('Error loading config: Config does not exist. ('..tostring(Name)..')', 5, color3_new(1,0,0));
				return;
			end;

			local Success, Err = pcall(function()
				SetByConfig = true;

				for Flag, Value in pairs(http_service:JSONDecode(Cfg)) do
					local Option = Library.Options[Flag];

					if Option then
						if string_lower(Option.Class) == 'toggle' then
							Option:SetState(Value == nil and false or (Value == 1 and true or false));
						elseif string_lower(Option.Class) == 'slider' then
							Option:SetValue(Value == nil and 0 or Value);
						elseif string_lower(Option.Class) == 'bind' then
							Option:SetBind(Value == nil and 'none' or (Utility:HasProperty(Enum.KeyCode, Value) and Enum.KeyCode[Value] or Enum.UserInputType[Value]));
						elseif string_lower(Option.Class) == 'color' then
							Option:SetColor(Value == nil and color3_new(1,1,1) or color3_new(Value[1], Value[2], Value[3]));
							Option:SetTrans(Value == nil and 1 or Value[4]);
						elseif string_lower(Option.Class) == 'list' then
							Option:Select(Value == nil and '' or Value);
						elseif string_lower(Option.Class) == 'box' then
							Option:SetInput(Value == nil and '' or Value);
						end;
					end;
				end;

				SetByConfig = false;
			end);

			if Success then
				self:SendNotification('Successfully loaded config: '..Name, 5, color3_new(0,1,0));
			else
				self:SendNotification('Error loading config: '..tostring(Err)..'. ('..tostring(Name)..')', 5, color3_new(1,0,0));
			end;
		end;

		function self:SaveConfig(Name: string): ()
			if not self:GetConfig(Name) then
				self:SendNotification('Error saving config: Config does not exist. ('..tostring(Name)..')', 5, color3_new(1,0,0));
				return;
			end;

			local Success, Err = pcall(function()
				local Cfg: { [string]: any } = {};

				for Flag, Option in pairs(Library.Options) do
					print(Flag, Option);

					if string_lower(Option.Class) == 'toggle' then
						Cfg[Flag] = Option.State and 1 or 0;
					elseif string_lower(Option.Class) == 'slider' then
						Cfg[Flag] = Option.Value;
					elseif string_lower(Option.Class) == 'bind' then
						Cfg[Flag] = Option.Bind.Name;
					elseif string_lower(Option.Class) == 'color' then
						Cfg[Flag] = { Option.Color.R, Option.Color.G, Option.Color.B, Option.Trans };
					elseif string_lower(Option.Class) == 'list' then
						Cfg[Flag] = Option.Selected;
					elseif string_lower(Option.Class) == 'box' then
						Cfg[Flag] = Option.Input;
					end;
				end;
				
				print(http_service:JSONEncode(Cfg));
				writefile(CheatName .. '/' .. Game .. '/configs/' .. Name .. '.json', http_service:JSONEncode(Cfg));
			end);

			if Success then
				self:SendNotification('Successfully saved config: '..Name, 5, color3_new(0,1,0));
			else
				self:SendNotification('Error saving config: '..tostring(Err)..'. ('..tostring(Name)..')', 5, color3_new(1,0,0));
			end;
		end;

		--// load images
		for K, V in self.Images do
			if not isfile(CheatName .. '/assets/' .. K .. '.xd') then
				writefile(CheatName .. '/assets/' .. K .. '.xd', game:HttpGet(V));
			end;

			self.Images[K] = readfile(CheatName .. '/assets/' .. K .. '.xd');
		end;

		--// cursors
		self.Cursor1 = Utility:Draw('Triangle', { Filled = true, Color = Library.CurrentTheme.Accent, ZIndex = self.Order.Cursor });
		self.Cursor2 = Utility:Draw('Triangle', { Filled = true, Color = color3_fromRGB(0, 0, 0), ZIndex = self.Order.Cursor - 1 });

		local function UpdateCursor(): ()
			self.Cursor1.Visible = self.Open;
			self.Cursor2.Visible = self.Open;

			if self.Cursor1.Visible then
				local Pos: Vector2 = input_service:GetMouseLocation();
				self.Cursor1.PointA = Pos;
				self.Cursor1.PointB = Pos + vec2(16,5);
				self.Cursor1.PointC = Pos + vec2(5,16);
				self.Cursor2.PointA = self.Cursor1.PointA + vec2(0,0);
				self.Cursor2.PointB = self.Cursor1.PointB + vec2(1,1);
				self.Cursor2.PointC = self.Cursor1.PointC + vec2(1,1);
			end;
		end;

		--// screen gui
		local ScreenGui: ScreenGui = Utility:Instance('ScreenGui', { Parent = gethui(), Enabled = true; });

		Utility:Instance('ImageButton', {
			Parent = ScreenGui,
			Visible = true,
			Modal = true,
			Size = udim2_new(1,0,1,0),
			ZIndex = 9999999999,
			Transparency = 1;
		});

		Utility:Connection(Library.Unloaded, function(): ()
			ScreenGui:Destroy();
		end);

		local function Fade(Drawings, FadeIn)
			for Index, Object in Drawings do
				if type(Object) == "table" then
					Fade(Object, FadeIn);
				elseif typeof(Object) == "userdata" then
					if DrawingDoNotFade[Object] then
						continue;
					else
						local ok, transparency = pcall(function() return Object.Transparency end);
						local okColor, color = pcall(function() return Object.Color end);

						if ok and transparency ~= nil and okColor and color then
							if DrawingOriginalTransparency[Object] == nil then
								DrawingOriginalTransparency[Object] = transparency;
							end;

							local target = FadeIn and DrawingOriginalTransparency[Object] or 0;
							Utility:LerpTween(Object, { Transparency = target }, 0.25);
						end;
					end;
				end;
			end;
		end;

		--// input handling
		Utility:Connection(input_service.InputBegan, function(Input: InputObject, GPE: boolean): ()
			if rawequal(Library.State.Stage, "Complete") then
				if Input.KeyCode == Enum.KeyCode.RightShift and not Library.Opening and not GPE then
					Fade(Library.Windows, not self.Open);

					task_delay(self.Open and 0.25 or 0, function()
						self:SetOpen(not self.Open);

						task_spawn(function(): ()
							Library.Opening = true;
							task_wait(.15);
							Library.Opening = false;
						end);
					end)
				end;

				if Library.Open then
					local HoverObj: any = Utility:GetHoverObject();
					local HoverObjData: any = Library.Drawings[HoverObj];

					if Input.UserInputType == Enum.UserInputType.MouseButton1 then
						MB1Down = true;
						Button1Down:Fire();

						if HoverObj and HoverObjData then
							HoverObjData.MouseButton1Down:Fire(input_service:GetMouseLocation());
						end;

						if Library.DraggingSlider then
							local Rel: Vector2 = input_service:GetMouseLocation() - Library.DraggingSlider.Objects.Background.Object.Position;
							local Val: number = Utility:ConvertNumberRange(Rel.X, 0, Library.DraggingSlider.Objects.Background.Object.Size.X, Library.DraggingSlider.Min, Library.DraggingSlider.Max);
							Library.DraggingSlider:SetValue(Val);
						end;
					elseif Input.UserInputType == Enum.UserInputType.MouseButton2 then
						if HoverObj and HoverObjData then
							HoverObjData.MouseButton2Down:Fire(input_service:GetMouseLocation());
						end;
					end;
				end;
			end;
		end);

		Utility:Connection(input_service.InputEnded, function(Input: InputObject, GPE: boolean): ()
			if rawequal(self.State.Stage, "Complete") and Library.Open then
				local HoverObj: any = Utility:GetHoverObject();
				local HoverObjData: any = Library.Drawings[HoverObj];

				if Input.UserInputType == Enum.UserInputType.MouseButton1 then
					MB1Down = false;
					Button1Up:Fire();

					if HoverObj and HoverObjData then
						HoverObjData.MouseButton1Up:Fire(input_service:GetMouseLocation());
					end;
				elseif Input.UserInputType == Enum.UserInputType.MouseButton2 then
					if HoverObj and HoverObjData then
						HoverObjData.MouseButton2Up:Fire(input_service:GetMouseLocation());
					end;
				end;
			end;
		end);

		Utility:Connection(input_service.InputChanged, function(Input: InputObject, GPE: boolean): ()
			if Input.UserInputType == Enum.UserInputType.MouseMovement then
				if Library.Open then
					MouseMove:Fire(input_service:GetMouseLocation());
					UpdateCursor();

					if Library.CurrentTooltip then
						local MousePos: Vector2 = input_service:GetMouseLocation();
						TooltipObjects.Background.Position = udim2_new(0,MousePos.X + 15,0,MousePos.Y + 15);
						TooltipObjects.Background.Size = udim2_new(0,TooltipObjects.Text.TextBounds.X + 6 + (Library.CurrentTooltipRisky and 60 or 0),0,TooltipObjects.Text.TextBounds.Y + 2);
					end;

					local HoverObj: any = Utility:GetHoverObject();
					for _, V in Library.Drawings do
						local Hover: boolean = HoverObj == V.Object;
						if Hover and not V.Hover then
							V.Hover = true;
							V.MouseEnter:Fire(input_service:GetMouseLocation());
						elseif not Hover and V.Hover then
							V.Hover = false;
							V.MouseLeave:Fire(input_service:GetMouseLocation());
						end;
					end;

					if MB1Down then
						if Library.DraggingSlider then
							local Rel: Vector2 = input_service:GetMouseLocation() - Library.DraggingSlider.Objects.Background.Object.Position;
							local Val: number = Utility:ConvertNumberRange(Rel.X, 0, Library.DraggingSlider.Objects.Background.Object.Size.X, Library.DraggingSlider.Min, Library.DraggingSlider.Max);
							Library.DraggingSlider:SetValue(Val);
						end;
					end;
				end;
			end;
		end);

		--// SetOpen
		function self:SetOpen(Bool: boolean): ()
			self.Open = Bool;
			ScreenGui.Enabled = Bool;
			local blocker = ScreenGui:FindFirstChildOfClass("ImageButton")
			if blocker then
				blocker.Modal = Bool
			end

			if Bool then
				context_action_service:BindAction(
					'FreezeMovement',

					function(): Enum.ContextActionResult
						return Enum.ContextActionResult.Sink;
					end,

					false,

					table_unpack(Enum.PlayerActions:GetEnumItems())
				);
			else
				context_action_service:UnbindAction('FreezeMovement');
			end;

			UpdateCursor();

			for _, Window in self.Windows do
				Window:SetOpen(Bool);
			end;

			Library.CurrentTooltip = nil;
			TooltipObjects.Background.Visible = false;
		end;

		--// UpdateThemeColors
		function self:UpdateThemeColors(): ()
			for _, V in Library.Drawings do
				if V.ThemeColor and Library.Theme[V.ThemeColor] then
					V.Object.Color = Utility:AddRGB(Library.Theme[V.ThemeColor], color3_fromRGB(V.ThemeColorOffset, V.ThemeColorOffset, V.ThemeColorOffset));
				end;
				if V.ThemeColorOutline and Library.Theme[V.ThemeColorOutline] then
					V.Object.OutlineColor = Utility:AddRGB(Library.Theme[V.ThemeColorOutline], color3_fromRGB(V.OutlineThemeColorOffset, V.OutlineThemeColorOffset, V.OutlineThemeColorOffset));
				end;
			end;
		end;

		--// notifications
		function self:SendNotification(Message: string, Time: number?, Color: Color3?): ()
			Time = Time or 5;

			if typeof(Message) ~= 'string' then return error(('Invalid message type, got %s, expected string'):format(typeof(Message))); end;
			if typeof(Time) ~= 'number' then return error(('Invalid time type, got %s, expected number'):format(typeof(Time))); end;
			if Color ~= nil and typeof(Color) ~= 'Color3' then return error(('Invalid color type, got %s, expected Color3'):format(typeof(Color))); end;

			local Notification: { [string]: any } = {};
			self.Notifications[Notification] = true;

			do
				local Z: number = self.Order.Notification;
				Notification.Holder = Utility:Draw('Square', { Position = udim2_new(0,0,0,75); Transparency = 0; });
				Notification.Background = Utility:Draw('Square', { Size = udim2_new(1,0,1,0); Position = udim2_new(0,-500,0,0); Parent = Notification.Holder; Color = Library.CurrentTheme['Background']; ZIndex = Z; });
				Notification.Border1 = Utility:Draw('Square', { Size = udim2_new(1,2,1,2); Position = udim2_new(0,-1,0,-1); Color = Library.CurrentTheme['Border 2']; Parent = Notification.Background; ZIndex = Z-1; });
				Notification.Border2 = Utility:Draw('Square', { Size = udim2_new(1,2,1,2); Position = udim2_new(0,-1,0,-1); Color = Library.CurrentTheme['Border 3']; Parent = Notification.Border1; ZIndex = Z-2; });
				Notification.Gradient = Utility:Draw('Image', { Size = udim2_new(1,0,1,0); Data = self.Images.gradientp90; Parent = Notification.Background; Transparency = .5; ZIndex = Z+1; });
				Notification.AccentBar = Utility:Draw('Square', { Size = udim2_new(0,3,1,4); Position = udim2_new(0,0,0,-2); Parent = Notification.Background; Color = Library.CurrentTheme[Color == nil and 'Accent' or '']; ZIndex = Z+5; });
				Notification.Text = Utility:Draw('Text', { Position = udim2_new(0,13,0,2); Color = Library.CurrentTheme['Primary Text']; Text = Message; Outline = true; Font = 2; Size = 13; ZIndex = Z+4; Parent = Notification.Background; });

				if Color then Notification.AccentBar.Color = Color; end;
			end;

			function Notification:Remove(): ()
				Library.Notifications[Notification] = nil;
				self.Holder:Remove();
				Library:UpdateNotifications();
			end;

			task_spawn(function(): ()
				self:UpdateNotifications();

				Notification.Background.Size = udim2_new(0, Notification.Text.TextBounds.X + 20, 0, 19);

				task_wait();

				Utility:Tween(Notification.Background, 'Position', udim2_new(0,0,0,0), .1);

				task_wait(Time);

				for _, V in Notification do
					if typeof(V) ~= 'function' then
						Utility:Tween(V, 'Transparency', 0, .15);
					end;
				end;

				Utility:Connection(Utility:Tween(Notification.Background, 'Position', udim2_new(0,-500,0,0), .25).Completed, function(): ()
					Notification:Remove();
				end);
			end);
		end;

		function self:UpdateNotifications(): ()
			local I: number = 0;

			for V in self.Notifications do
				Utility:Tween(V.Holder, 'Position', udim2_new(0,0,0, 75 + (I * 30)), .15);
				I += 1;
			end;
		end;

		function self.NewIndicator(Data: { title: string?, enabled: boolean?, position: UDim2?, values: { }? }): {}
			local Indicator: { } = {
				Title = Data.title or "Indicator";
				Enabled = Data.enabled or false;
				Position = Data.position or udim2_new(0, 15, 0, 300);
				Values = {};
				Objects = { ValueObjects = {} };
				Spacing = "   ";
			}

			table_insert(self.Indicators, Indicator)

			local Z: number = self.Order.Indicator
			local Objs: { } = Indicator.Objects

			Objs.Background = utility:Draw("Square", {
				Size = udim2_new(0, 200, 0, 16);
				Position = Indicator.Position;
				Color = Library.CurrentTheme["Background"];
				ZIndex = Z;
			})

			Objs.Border1 = utility:Draw("Square", {
				Size = udim2_new(1, 2, 1, 2);
				Position = udim2_new(0, -1, 0, -1);
				Color = Library.CurrentTheme["Border 2"];
				Parent = Objs.Background;
				ZIndex = Z - 1;
			})

			Objs.Border2 = utility:Draw("Square", {
				Size = udim2_new(1, 2, 1, 2);
				Position = udim2_new(0, -1, 0, -1);
				Color = Library.CurrentTheme["Border 3"];
				Parent = Objs.Border1;
				ZIndex = Z - 2;
			})

			Objs.TopBorder = utility:Draw("Square", {
				Size = udim2_new(1, 0, 0, 1);
				Color = Library.CurrentTheme["Accent"];
				Parent = Objs.Background;
				ZIndex = Z + 1;
			})

			Objs.TextLabel = utility:Draw("Text", {
				Position = udim2_new(0.5, 0, 0, 1);
				Color = Library.CurrentTheme["Primary Text"];
				Text = Indicator.Title;
				Size = 13;
				Font = 2;
				ZIndex = Z + 2;
				Center = true;
				Outline = true;
				Parent = Objs.Background;
			})

			function Indicator:Update(): nil
				local XSize: number = 125
				local YPos: number = 0
				table_sort(self.Values, function(A: { }, B: { }) return A.Order < B.Order end)

				for _, V: { } in self.Values do
					local KeyObj: { }, ValObj: { }, BgObj: { } = V.Objects.KeyLabel, V.Objects.ValueLabel, V.Objects.Background
					KeyObj.Text = tostring(V.Key)
					ValObj.Text = tostring(V.Value)

					ValObj.Position = udim2_new(1, -(ValObj.TextBounds.X + 3), 0, 0)
					BgObj.Position = udim2_new(0, 0, 1, 3 + YPos)
					BgObj.Visible = V.Enabled

					if V.Enabled then
						YPos += 16 + 3
						local W: number = KeyObj.TextBounds.X + 10 + ValObj.TextBounds.X
						if W > XSize then XSize = W end
					end
				end

				self.Objects.Background.Size = udim2_new(0, XSize + 8, 0, 16)
				self.Objects.Background.Position = self.Position
			end

			function Indicator:AddValue(Data: {key: string?, value: string?, order: number?, enabled: boolean?}): { }
				local Value: { } = {
					Key = Data.key or "";
					Value = Data.value or "";
					Order = Data.order or (#self.Values + 1);
					Enabled = Data.enabled ~= false;
					Objects = {};
				}
				table_insert(self.Values, Value)

				local Z: number = Library.Order.Indicator
				local Objs: { } = Value.Objects

				Objs.Background = utility:Draw("Square", {
					Size = udim2_new(1, 0, 0, 16);
					Color = Library.CurrentTheme["Background"];
					ZIndex = Z;
					Parent = Indicator.Objects.Background;
				})

				Objs.Border1 = utility:Draw("Square", {
					Size = udim2_new(1, 2, 1, 2);
					Position = udim2_new(0, -1, 0, -1);
					Color = Library.CurrentTheme["Border 2"];
					Parent = Objs.Background;
					ZIndex = Z - 1;
				})

				Objs.Border2 = utility:Draw("Square", {
					Size = udim2_new(1, 2, 1, 2);
					Position = udim2_new(0, -1, 0, -1);
					Color = Library.CurrentTheme["Border 3"];
					Parent = Objs.Border1;
					ZIndex = Z - 2;
				})

				Objs.KeyLabel = utility:Draw("Text", {
					Position = udim2_new(0, 3, 0, 1);
					Color = Library.CurrentTheme["Accent"];
					Size = 13;
					Font = 2;
					ZIndex = Z + 2;
					Outline = true;
					Parent = Objs.Background;
				})

				Objs.ValueLabel = utility:Draw("Text", {
					Position = udim2_new(0, 0, 0, 1);
					Color = Library.CurrentTheme["Option Text 2"];
					Size = 13;
					Font = 2;
					ZIndex = Z + 2;
					Outline = true;
					Parent = Objs.Background;
				})

				DrawingDoNotFade[Objs.Background] = true
				DrawingDoNotFade[Objs.KeyLabel] = true
				DrawingDoNotFade[Objs.ValueLabel] = true
				DrawingDoNotFade[Objs.Border1] = true
				DrawingDoNotFade[Objs.Border2] = true

				function Value:Remove(): nil
					table_remove(Indicator.Values, table_find(Indicator.Values, Value))
					Objs.Background:Remove()
					table_clear(self)
					Indicator:Update()
				end

				function Value:SetEnabled(Bool: boolean): nil
					if typeof(Bool) == "boolean" then self.Enabled = Bool; Indicator:Update() end
				end

				function Value:SetValue(Str: string): nil
					if typeof(Str) == "string" then self.Value = Str; Indicator:Update() end
				end

				function Value:SetKey(Str: string): nil
					if typeof(Str) == "string" then self.Key = Str; Indicator:Update() end
				end

				self:Update()

				return Value
			end

			function Indicator:GetValue(Id: number | string): { }?
				if typeof(Id) == "number" then return self.Values[Id] end
				for _, V: { } in self.Values do if V.Key == Id then return V end end
			end

			function Indicator:SetEnabled(Bool: boolean): nil
				if typeof(Bool) == "boolean" then self.Enabled = Bool; self.Objects.Background.Visible = Bool; self:Update() end
			end

			function Indicator:SetPosition(Pos: UDim2): nil
				if typeof(Pos) == "UDim2" then self.Position = Pos; self.Objects.Background.Position = Pos end
			end

			for I,V in Data.Values or {} do
				Indicator:AddValue({key = tostring(I), value = tostring(V)})
			end

			Indicator:SetEnabled(Indicator.Enabled)

			return Indicator
		end

		function self:Window(Data: {Title: string?, Size: UDim2?, Position: UDim2?}): { }
			local Window: { } = {
				Title = Data.Title or "";
				SelectedTab = nil;
				Tabs = { };
				Objects = { };
				ColorPicker = { Objects = { }, Color = color3_fromRGB(1,0,0), Trans = 0 };
				Dropdown = { Objects = { Values = { } }, Max = 5 };

				Open = true;
			}

			table_insert(Library.Windows, Window)

			local Objs, Z = Window.Objects, Library.Order.Window
			local Size: UDim2 = Data.Size or udim2_new(0, 525, 0, 650)
			local Pos: UDim2 = Data.Position or udim2_new(0, 250, 0, 150)

			--[[
			['Accent']                = color3_fromRGB(255,135,255);
				['Background']                = color3_fromRGB(18,18,18);
				['Border']                    = color3_fromRGB(0,0,0);
				['Border 1']                  = color3_fromRGB(60,60,60);
				['Border 2']                  = color3_fromRGB(35,35,35);
				['Border 3']                  = color3_fromRGB(10,10,10);
				['Primary Text']              = color3_fromRGB(235,235,235);
				['Group Background']          = color3_fromRGB(35,35,35);
				['Selected Tab Background']   = color3_fromRGB(35,35,35);
				['Unselected Tab Background'] = color3_fromRGB(18,18,18);
				['Selected Tab Text']         = color3_fromRGB(245,245,245);
				['Unselected Tab Text']       = color3_fromRGB(145,145,145);
				['Section Background']        = color3_fromRGB(18,18,18);
				['Option Text 1']             = color3_fromRGB(245,245,245);
				['Option Text 2']             = color3_fromRGB(195,195,195);
				['Option Text 3']             = color3_fromRGB(145,145,145);
				['Option Border 1']           = color3_fromRGB(50,50,50);
				['Option Border 2']           = color3_fromRGB(0,0,0);
				['Option Background']         = color3_fromRGB(35,35,35);
				["Risky Text"]                = color3_fromRGB(175, 21, 21);
				["Risky Text Enabled"]        = color3_fromRGB(255, 41, 41);
			]]

			Objs.Background =
				Utility:Draw(
				"Square",
				{Size = Size, Position = Pos, ThemeColor = "Background", ZIndex = Z, Color = Library.CurrentTheme["Background"]}
			)

			Objs.InnerBorder1 =
				Utility:Draw(
				"Square",
				{
					Size = udim2_new(1, 2, 1, 2),
					Position = udim2_new(0, -1, 0, -1),
					ThemeColor = "Border 3",
					ZIndex = Z - 1,
					Parent = Objs.Background,
					Color = Library.CurrentTheme["Border 3"]
				}
			)

			Objs.InnerBorder2 =
				Utility:Draw(
				"Square",
				{
					Size = udim2_new(1, 2, 1, 2),
					Position = udim2_new(0, -1, 0, -1),
					ThemeColor = "Border 1",
					ZIndex = Z - 2,
					Parent = Objs.InnerBorder1,
					Color = Library.CurrentTheme["Border 1"]
				}
			)

			Objs.MidBorder =
				Utility:Draw(
				"Square",
				{
					Size = udim2_new(1, 10, 1, 25),
					Position = udim2_new(0, -5, 0, -20),
					ThemeColor = "Border 2",
					ZIndex = Z - 3,
					Parent = Objs.InnerBorder2,
					Color = Library.CurrentTheme["Border 2"]
				}
			)

			Objs.OuterBorder1 =
				Utility:Draw(
				"Square",
				{
					Size = udim2_new(1, 2, 1, 2),
					Position = udim2_new(0, -1, 0, -1),
					ThemeColor = "Border 1",
					ZIndex = Z - 4,
					Parent = Objs.MidBorder,
					Color = Library.CurrentTheme["Border 1"]
				}
			)

			Objs.OuterBorder2 =
				Utility:Draw(
				"Square",
				{
					Size = udim2_new(1, 2, 1, 2),
					Position = udim2_new(0, -1, 0, -1),
					ThemeColor = "Border 3",
					ZIndex = Z - 5,
					Parent = Objs.OuterBorder1,
					Color = Library.CurrentTheme["Border 3"]
				}
			)

			Objs.TopBorder =
				Utility:Draw(
				"Square",
				{
					Size = udim2_new(1, 0, 0, 1),
					ThemeColor = "Accent",
					ZIndex = Z + 1,
					Parent = Objs.Background,
					Color = Library.CurrentTheme["Accent"]
				}
			)

			Objs.Title =
				Utility:Draw(
				"Text",
				{
					Position = udim2_new(0, 7, 0, 2),
					ThemeColor = "Primary Text",
					Text = Window.Title,
					Font = 2,
					Size = 13,
					ZIndex = Z + 1,
					Outline = true,
					Parent = Objs.MidBorder,
					Color = Library.CurrentTheme["Primary Text"]
				}
			)

			Objs.GroupBackground =
				Utility:Draw(
				"Square",
				{
					Size = udim2_new(1, -16, 1, -(16 + 23)),
					Position = udim2_new(0, 8, 0, 8 + 23),
					ThemeColor = "Group Background",
					ZIndex = Z + 5,
					Parent = Objs.Background,
					Color = Library.CurrentTheme["Group Background"]
				}
			)

			Objs.GroupInnerBorder =
				Utility:Draw(
				"Square",
				{
					Size = udim2_new(1, 2, 1, 2),
					Position = udim2_new(0, -1, 0, -1),
					ThemeColor = "Border 1",
					ZIndex = Z + 4,
					Parent = Objs.GroupBackground,
					Color = Library.CurrentTheme["Border 1"]
				}
			)

			Objs.GroupOuterBorder =
				Utility:Draw(
				"Square",
				{
					Size = udim2_new(1, 2, 1, 2),
					Position = udim2_new(0, -1, 0, -1),
					ThemeColor = "Border 3",
					ZIndex = Z + 3,
					Parent = Objs.GroupInnerBorder,
					Color = Library.CurrentTheme["Border 3"]
				}
			)

			Objs.TabHolder =
				Utility:Draw(
				"Square",
				{
					Size = udim2_new(1, 0, 0, 20),
					Position = udim2_new(0, 0, 0, -21),
					Parent = Objs.GroupBackground,
					Transparency = 0,
					ZIndex = Z + 1,
					Color = Library.CurrentTheme["Background"]
				}
			)

			Objs.ColumnHolder1 =
				Utility:Draw(
				"Square",
				{
					Size = udim2_new(0.48, 0, 0.96, 0),
					Position = udim2_new(0.01, 0, 0.02, 0),
					Transparency = 0,
					ZIndex = Z + 6,
					Parent = Objs.GroupBackground
				}
			)

			Objs.ColumnHolder2 =
				Utility:Draw(
				"Square",
				{
					Size = udim2_new(0.48, 0, 0.96, 0),
					Position = udim2_new(1 - (0.48 + 0.01), 0, 0.02, 0),
					Transparency = 0,
					ZIndex = Z + 6,
					Parent = Objs.GroupBackground
				}
			)

			Objs.DragDetector =
				Utility:Draw(
				"Square",
				{
					Size = udim2_new(1, 0, 1, 0),
					Parent = Objs.MidBorder,
					Transparency = 0,
					ZIndex = Z + 2,
					Color = Library.CurrentTheme["Border 3"]
				}
			)


			local Dragging: boolean, MouseStart: UDim2, ObjStart: UDim2

			Utility:Connection(Objs.DragDetector.MouseButton1Down, function(Pos: Vector2)
				Dragging = true
				MouseStart = udim2_new(0, Pos.X, 0, Pos.Y)
				ObjStart = Objs.Background.Position
			end)

			Utility:Connection(Button1Up, function()
				Dragging = false
			end)

			Utility:Connection(MouseMove, function(Pos: Vector2)
				if Dragging then
					if Window.Open then
						Objs.Background.Position = ObjStart + udim2_new(0, Pos.X, 0, Pos.Y) - MouseStart
					else
						Dragging = false
					end
				end
			end)

			local function Tooltip(Option): ()
				utility:Connection(Option.Objects.Holder.MouseEnter, function()
					TooltipObjects.Background.Visible = (Option.Tooltip ~= '' and Option.Tooltip ~= nil)
					TooltipObjects.RiskyText.Visible = Option.Risky
					TooltipObjects.Text.Position = Option.Risky and udim2_new(0, 60, 0, 0) or udim2_new(0, 3, 0, 0)
					TooltipObjects.Text.Text = tostring(Option.Tooltip)
					Library.CurrentTooltip = Option
				end)

				utility:Connection(Option.Objects.Holder.MouseLeave, function()
					if Library.CurrentTooltip == Option then
						Library.CurrentTooltip = nil
						TooltipObjects.Background.Visible = false
					end
				end)
			end



			local VisValues: { } = {};


			function Window:SetOpen(Bool: boolean): ()
				if typeof(Bool) ~= "boolean" then
					return
				end

				self.Open = Bool

				local Background = self.Objects.Background
				local Objs: { any } = Background:GetDescendants()
				table_insert(Objs, Background)

				task_spawn(function()
					if not Bool then
						task_wait(0.1)
					end
					Background.Visible = Bool
				end)

				for _, Obj in Objs do
					local DrawObj = Obj.Object
					if DrawObj and DrawObj.Transparency ~= 0 then
						task_spawn(function()
							if Bool then
								Utility:Tween(DrawObj, "Transparency", VisValues[Obj] or 1, 0.1)
							else
								VisValues[Obj] = DrawObj.Transparency
								Utility:Tween(DrawObj, "Transparency", 0.05, 0.1)
							end
						end)
					end
				end
			end;

			function Window:UpdateTabs(): ()
				table_sort(self.Tabs, function(A, B)
					return A.Order < B.Order
				end)

				local Pos: number = 0;

				for _, Tab in self.Tabs do
					local Objs = Tab.Objects;
					Tab.Selected = (Tab == self.SelectedTab);


					local BgTheme: string = Tab.Selected and "Selected Tab Background" or "Unselected Tab Background";
					Objs.Background.ThemeColor = BgTheme;
					Objs.Background.Color = Library.CurrentTheme[BgTheme];
					Objs.Background.Size = udim2_new(
						0,
						Objs.Text.TextBounds.X + 50,
						1,
						Tab.Selected and 1 or 0
					);
					Objs.Background.Position = udim2_new(0, Pos, 0, 0);

					local TextTheme: string = Tab.Selected and "Selected Tab Text" or "Unselected Tab Text";
					Objs.Text.ThemeColor = TextTheme;
					Objs.Text.Color = Library.CurrentTheme[TextTheme];
					Objs.Text.Position = udim2_new(0.5, 0, 0, 3);

					local TopTheme: string = Tab.Selected and "Accent" or "Unselected Tab Background";
					Objs.TopBorder.ThemeColor = TopTheme;
					Objs.TopBorder.Color = Library.CurrentTheme[TopTheme];

					Pos += Objs.Background.Size.X.Offset + 10;

					Tab:UpdateSections();
				end
			end;


			function Window:Tab(Text: string, Order: number?): { }
				local Tab: { } = {
					Text = Text;
					Order = Order or (#self.Tabs + 1);
					Callback = function() end;
					Objects = { };
					Sections = { };
				}

				table_insert(self.Tabs, Tab);

				do
					local Objs = Tab.Objects;
					local Z: number = Library.Order.Window + 5;

					Objs.Background = Utility:Draw("Square", {
						Size = udim2_new(0, 50, 1, 0);
						Parent = self.Objects.TabHolder;
						ThemeColor = "Unselected Tab Background";
						Color = Library.CurrentTheme["Unselected Tab Background"];
						ZIndex = Z;
					})

					Objs.InnerBorder = Utility:Draw("Square", {
						Size = udim2_new(1, 2, 1, 2);
						Position = udim2_new(0, -1, 0, -1);
						ThemeColor = "Border 1";
						Color = Library.CurrentTheme["Border 1"];
						ZIndex = Z - 1;
						Parent = Objs.Background;
					})

					Objs.OuterBorder = Utility:Draw("Square", {
						Size = udim2_new(1, 2, 1, 2);
						Position = udim2_new(0, -1, 0, -1);
						ThemeColor = "Border 3";
						Color = Library.CurrentTheme["Border 3"];
						ZIndex = Z - 2;
						Parent = Objs.InnerBorder;
					})

					Objs.TopBorder = Utility:Draw("Square", {
						Size = udim2_new(1, 0, 0, 1);
						ThemeColor = "Unselected Tab Background";
						Color = Library.CurrentTheme["Unselected Tab Background"];
						ZIndex = Z + 1;
						Parent = Objs.Background;
					})

					Objs.Text = Utility:Draw("Text", {
						ThemeColor = "Unselected Tab Text";
						Color = Library.CurrentTheme["Unselected Tab Text"];
						Text = Text;
						Size = 13;
						Font = 2;
						ZIndex = Z + 1;
						Outline = true;
						Center = true;
						Parent = Objs.Background;
					})

					Utility:Connection(Objs.Background.MouseButton1Down, function()
						Tab:Select();
					end)
				end

				function Tab:Section(Text: string, Side: number?, Order: number?): { }
					local Section: { } = {
						Text = tostring(Text);
						Side = Side == nil and 1 or math_clamp(Side, 1, 2);
						Order = Order or (#self.Sections + 1);
						Enabled = true;
						Objects = { };
						Options = { };
					};

					table_insert(self.Sections, Section);

					do
						local Objs = Section.Objects;
						local Z: number = Library.Order.Window + 15;

						Objs.Background = Utility:Draw("Square", {
							ThemeColor = "Section Background";
							Color = Library.CurrentTheme["Section Background"];
							ZIndex = Z;
							Parent = Window.Objects["ColumnHolder" .. Section.Side];
						});

						Objs.InnerBorder = Utility:Draw("Square", {
							Size = udim2_new(1, 2, 1, 1);
							Position = udim2_new(0, -1, 0, 0);
							ThemeColor = "Border 3";
							Color = Library.CurrentTheme["Border 3"];
							ZIndex = Z - 1;
							Parent = Objs.Background;
						});

						Objs.OuterBorder = Utility:Draw("Square", {
							Size = udim2_new(1, 2, 1, 1);
							Position = udim2_new(0, -1, 0, 0);
							ThemeColor = "Border 1";
							Color = Library.CurrentTheme["Border 1"];
							ZIndex = Z - 2;
							Parent = Objs.InnerBorder;
						});

						Objs.TopBorder1 = Utility:Draw("Square", {
							Size = udim2_new(0.025, 1, 0, 1);
							Position = udim2_new(0, -1, 0, 0);
							ThemeColor = "Accent";
							Color = Library.CurrentTheme["Accent"];
							ZIndex = Z + 1;
							Parent = Objs.Background;
						});

						Objs.TopBorder2 = Utility:Draw("Square", {
							ThemeColor = "Accent";
							Color = Library.CurrentTheme["Accent"];
							ZIndex = Z + 1;
							Parent = Objs.Background;
						});

						Objs.TextLabel = Utility:Draw("Text", {
							Position = udim2_new(0.0425, 0, 0, -7);
							ThemeColor = "Primary Text";
							Color = Library.CurrentTheme["Primary Text"];
							Size = 13;
							Font = 2;
							ZIndex = Z + 1;
							Parent = Objs.Background;
							Outline = true;
						});

						Objs.OptionHolder = Utility:Draw("Square", {
							Size = udim2_new(1 - 0.03, 0, 1, -15);
							Position = udim2_new(0.015, 0, 0, 13);
							Transparency = 0;
							ZIndex = Z + 1;
							Parent = Objs.Background;
						});
					end

					function Section:SetText(NewText: string): ()
						self.Text = tostring(NewText);
						self.Objects.TextLabel.Text = self.Text;

						local X: number =
							self.Objects.Background.Object.Size.X
						- self.Objects.TextLabel.TextBounds.X
						- 13;

						self.Objects.TopBorder2.Size = udim2_new(0, X, 0, 1);
						self.Objects.TopBorder2.Position = udim2_new(1, -X + 1, 0, 0);
					end

					function Section:UpdateOptions(): ()
						table_sort(self.Options, function(A, B)
							return A.Order < B.Order;
						end);

						local YSize: number = 15;
						local Padding: number = 0;

						for _, Option in self.Options do
							Option.Objects.Holder.Visible = Option.Enabled;

							if Option.Enabled then
								Option.Objects.Holder.Position =
									udim2_new(0, 0, 0, YSize - 15);

								YSize += Option.Objects.Holder.Object.Size.Y + Padding;
							end
						end

						self.Objects.Background.Size = udim2_new(1, 0, 0, YSize);
					end

					function Section:SetEnabled(State: boolean): ()
						if typeof(State) == "boolean" then
							self.Enabled = State;
							Tab:UpdateSections();
						end
					end

					function Section:Toggle(Data: { [string]: any }): { [string]: any }
						local Toggle: { [string]: any } = {
							Class = 'toggle';
							Flag = Data.Flag;
							Text = '';
							Tooltip = '';
							Order = #self.Options + 1;
							State = false;
							Risky = false;
							Callback = function() end;
							Enabled = true;
							Options = {};
							Objects = {};
						};

						local Blacklist: { string } = { 'objects' };

						for I, V in Data do
							if not table_find(Blacklist, I) and Toggle[I] ~= nil then
								Toggle[I] = V;
							end
						end

						table_insert(self.Options, Toggle);

						if Toggle.Flag then
							Library.Flags[Toggle.Flag] = Toggle.State;
							Library.Options[Toggle.Flag] = Toggle;
						end

						do
							local Objs: { [string]: any } = Toggle.Objects;
							local Z: number = Library.Order.Window + 25;

							Objs.Holder = Utility:Draw('Square', {
								Size = udim2_new(1, 0, 0, 17);
								Transparency = 0;
								ZIndex = Z + 5;
								Parent = self.Objects.OptionHolder;
							});

							Objs.Background = Utility:Draw('Square', {
								Size = udim2_new(0, 8, 0, 8);
								Position = udim2_new(0, 2, 0, 4);
								ThemeColor = 'Option Background';
								ZIndex = Z + 3;
								Parent = Objs.Holder;
								Color = Library.CurrentTheme["Option Background"]
							});

							Objs.Gradient = Utility:Draw('Image', {
								Size = udim2_new(1, 0, 1, 0);
								Data = Library.Images.gradientp45;
								Transparency = 0.25;
								ZIndex = Z + 4;
								Parent = Objs.Background;
							});

							Objs.Border1 = Utility:Draw('Square', {
								Size = udim2_new(1, 2, 1, 2);
								Position = udim2_new(0, -1, 0, -1);
								ThemeColor = 'Option Border 1';
								ZIndex = Z + 2;
								Parent = Objs.Background;
								Color = Library.CurrentTheme["Option Border 1"]
							});

							Objs.Border2 = Utility:Draw('Square', {
								Size = udim2_new(1, 2, 1, 2);
								Position = udim2_new(0, -1, 0, -1);
								ThemeColor = 'Option Border 2';
								ZIndex = Z + 1;
								Parent = Objs.Border1;
								Color = Library.CurrentTheme["Option Border 2"]
							});

							Objs.Text = Utility:Draw('Text', {
								Position = udim2_new(0, 19, 0, 1);
								ThemeColor = 'Option Text 3';
								Size = 13;
								Font = 2;
								ZIndex = Z + 1;
								Outline = true;
								Parent = Objs.Holder;
								Color = Library.CurrentTheme["Option Text 3"]
							});

							Utility:Connection(Objs.Holder.MouseEnter, function(): ()
								Objs.Border1.Color = Library.CurrentTheme["Accent"]
							end);

							Utility:Connection(Objs.Holder.MouseLeave, function(): ()
								Objs.Border1.Color = Toggle.State and Library.CurrentTheme["Accent"] or Library.CurrentTheme["Option Border 1"]
							end);

							Utility:Connection(Objs.Holder.MouseButton1Down, function(): ()
								Toggle:SetState(not Toggle.State);
							end);
						end

						function Toggle:SetState(Bool: boolean, NoCallback: boolean?): ()
							if typeof(Bool) == 'boolean' then
								self.State = Bool;
								if self.Flag then
									Library.Flags[self.Flag] = Bool;
								end

								self.Objects.Border1.Color = Bool and Library.CurrentTheme["Accent"] or (self.Objects.Holder.Hover and Library.CurrentTheme["Accent"] or Library.CurrentTheme["Option Border 1"]);
								self.Objects.Text.Color = Bool and (self.Risky and 'Risky Text Enabled' or Library.CurrentTheme["Option Text 1"]) or (self.Risky and Library.CurrentTheme["Risky Text"] or Library.CurrentTheme["Option Text 3"]);
								--self.Objects.Background.Color = Bool and Library.CurrentTheme["Accent"] or Library.CurrentTheme["Option Background"];
								--self.Objects.Background.ThemeColorOffset = Bool and -55 or 0;
								self.Objects.Background.Color = Utility:AddRGB(Bool and Library.CurrentTheme["Accent"] or Library.CurrentTheme["Option Background"], color3_fromRGB(Bool and -55 or 0, Bool and -55 or 0, Bool and -55 or 0));
								if not NoCallback then
									self.Callback(Bool);
								end
							end
						end

						function Toggle:SetText(Str: string): ()
							if typeof(Str) == 'string' then
								self.Text = Str;
								self.Objects.Text.Text = Str;
							end
						end

						function Toggle:UpdateOptions(): ()
							table_sort(self.Options, function(A: { [string]: any }, B: { [string]: any })
								return A.Order < B.Order;
							end);

							local X: number = 0;
							local Y: number = 0;

							for _, Option in self.Options do
								Option.Objects.Holder.Visible = Option.Enabled;
								if Option.Enabled then
									if string_lower(Option.Class) ==  'color' or string_lower(Option.Class) == 'bind' then
										Option.Objects.Holder.Position = udim2_new(1, -Option.Objects.Holder.Object.Size.X - X, 0, 0);
										X = X + Option.Objects.Holder.Object.Size.X;
									elseif string_lower(Option.Class) == 'slider' or string_lower(Option.Class) == 'list' then
										Option.Objects.Holder.Position = udim2_new(0, 0, 1, -Option.Objects.Holder.Object.Size.Y - Y);
										Y = Y + Option.Objects.Holder.Object.Size.Y;
									end
								end
							end

							self.Objects.Holder.Size = udim2_new(1, 0, 0, 17 + Y);
							Section:UpdateOptions();
						end

						-- // Toggle
						function Toggle:Color(Data: { [string]: any }): { [string]: any }
							local ColorOption: { [string]: any } = {
								Class = 'color';
								Flag = Data.Flag;
								Text = '';
								Tooltip = '';
								Order = #self.Options + 1;
								Callback = function() end;
								Color = color3_new(1, 1, 1);
								Trans = 0;
								Open = false;
								Enabled = true;
								Objects = {};
							};

							local Blacklist2: { string } = { 'objects' };
							for I, V in Data do
								if not table_find(Blacklist2, I) and ColorOption[I] ~= nil then
									ColorOption[I] = V;
								end
							end

							table_insert(self.Options, ColorOption);

							if ColorOption.Flag then
								Library.Flags[ColorOption.Flag] = ColorOption.Color;
								Library.Options[ColorOption.Flag] = ColorOption;
							end

							do
								local Objs: { [string]: any } = ColorOption.Objects;
								local Z: number = Library.Order.Window + 25;

								Objs.Holder = Utility:Draw('Square', {
									Size = udim2_new(0, 21, 0, 17);
									Transparency = 0;
									ZIndex = Z + 6;
									Parent = self.Objects.Holder;
								})

								Objs.Background = Utility:Draw('Square', {
									Size = udim2_new(0, 15, 0, 8);
									Position = udim2_new(0, 4, 0, 5);
									Color = Library.CurrentTheme["Option Background"];
									ZIndex = Z + 3;
									Parent = Objs.Holder;
								})

								Objs.Gradient = Utility:Draw('Image', {
									Size = udim2_new(1, 0, 1, 0);
									Data = Library.Images.gradientp45 or Library.Images.GradientP45;
									Transparency = 0.25;
									ZIndex = Z + 4;
									Parent = Objs.Background;
								})

								Objs.Border1 = Utility:Draw('Square', {
									Size = udim2_new(1, 2, 1, 2);
									Position = udim2_new(0, -1, 0, -1);
									Color = Library.CurrentTheme["Option Border 1"];
									ZIndex = Z + 2;
									Parent = Objs.Background;
								})

								Objs.Border2 = Utility:Draw('Square', {
									Size = udim2_new(1, 2, 1, 2);
									Position = udim2_new(0, -1, 0, -1);
									Color = Library.CurrentTheme["Option Border 2"];
									ZIndex = Z + 1;
									Parent = Objs.Border1;
								})

								-- Mouse hover updates
								Utility:Connection(Objs.Holder.MouseEnter, function(): ()
									Objs.Border1.Color = Library.CurrentTheme["Accent"];
								end)

								Utility:Connection(Objs.Holder.MouseLeave, function(): ()
									Objs.Border1.Color = ColorOption.State and Library.CurrentTheme["Accent"]
										or Library.CurrentTheme["Option Border 1"];
								end)

								Utility:Connection(Objs.Holder.MouseButton1Down, function(): ()
									ColorOption:SetOpen(not ColorOption.Open);
								end);
							end


							function ColorOption:SetColor(C3: Color3, NoCallback: boolean?): ()
								if typeof(C3) == 'Color3' then
									local H, S, V = C3:ToHSV();
									C3 = color3_fromHSV(H, math_clamp(S, 0.005, 0.995), math_clamp(V, 0.005, 0.995));
									self.Color = C3;
									self.Objects.Background.Color = C3;
									if not NoCallback then
										self.Callback(C3, self.Trans);
									end
									if self.Open then
										Window.ColorPicker:Visualize(self.Color, self.Trans);
									end
									if self.Flag then
										Library.Flags[self.Flag] = C3;
									end
								end
							end

							function ColorOption:SetTrans(Trans: number, NoCallback: boolean?): ()
								if typeof(Trans) == 'number' then
									self.Trans = Trans;
									if not NoCallback then
										self.Callback(self.Color, Trans);
									end
									if self.Open then
										Window.ColorPicker:Visualize(self.Color, self.Trans);
									end
								end
							end

							function ColorOption:SetOpen(Bool: boolean): ()
								if typeof(Bool) == 'boolean' then
									self.Open = Bool;
									if Bool then
										if Window.ColorPicker.Selected then
											Window.ColorPicker.Selected.Open = false;
										end
										Window.ColorPicker.Selected = ColorOption;
										Window.ColorPicker.Objects.Background.Parent = self.Objects.Background;
										Window.ColorPicker.Objects.Background.Visible = true;
										Window.ColorPicker:Visualize(ColorOption.Color, ColorOption.Trans);
									elseif Window.ColorPicker.Selected == ColorOption then
										Window.ColorPicker.Selected = nil;
										Window.ColorPicker.Objects.Background.Parent = Window.Objects.Background;
										Window.ColorPicker.Objects.Background.Visible = false;
									end
								end
							end

							Tooltip(ColorOption);
							ColorOption:SetColor(ColorOption.Color, true);
							ColorOption:SetTrans(ColorOption.Trans, true);
							self:UpdateOptions();
							
							return ColorOption;
						end

						function Toggle:Bind(Data: { [string]: any }): { [string]: any }
							local BindOption: { [string]: any } = {
								Class = 'bind';
								Flag = Data.Flag;
								Text = '';
								Tooltip = '';
								Bind = 'none';
								Mode = 'toggle';
								Order = #self.Options + 1;
								Callback = function() end;
								KeyCallback = function() end;
								IndicatorValue = Library.KeyIndicator:AddValue({ value = 'value', key = 'key', enabled = false });
								NoIndicator = false;
								InvertIndicator = false;
								State = false;
								NoMouse = false;
								Enabled = true;
								Binding = false;
								Objects = {};
							};

							local Blacklist3: { string } = { 'objects' };
							for I, V in Data do
								if not table_find(Blacklist3, I) and BindOption[I] ~= nil then
									BindOption[I] = V;
								end
							end

							table_insert(self.Options, BindOption);

							if BindOption.Flag then
								Library.Options[BindOption.Flag] = BindOption;
							end

							if BindOption.Bind == 'none' then
								BindOption.State = true;
								if BindOption.Flag then
									Library.Flags[BindOption.Flag] = BindOption.State;
								end
								BindOption.Callback(true);
								local Display = BindOption.State;
								if BindOption.InvertIndicator then
									Display = not BindOption.State;
								end
								BindOption.IndicatorValue:SetEnabled(Display and not BindOption.NoIndicator);
								BindOption.IndicatorValue:SetKey((BindOption.Text == nil or BindOption.Text == '') and (BindOption.Flag == nil and 'unknown' or BindOption.Flag) or BindOption.Text);
								BindOption.IndicatorValue:SetValue('[Always]');
							end

							do
								local Objs: { [string]: any } = BindOption.Objects;
								local Z: number = Library.Order.Window + 25;

								Objs.Holder = Utility:Draw('Square', {
									Size = udim2_new(0, 0, 0, 17);
									Transparency = 0;
									ZIndex = Z + 6;
									Parent = self.Objects.Holder;
								});

								Objs.KeyText = Utility:Draw('Text', {
									ThemeColor = 'Option Text 3';
									Size = 13;
									Font = 2;
									ZIndex = Z + 1;
									Parent = Objs.Holder;
									Color = Library.CurrentTheme["Option Text 3"]
								});

								Utility:Connection(Objs.Holder.MouseEnter, function(): ()
									Objs.KeyText.Color = Library.CurrentTheme["Accent"]
								end);

								Utility:Connection(Objs.Holder.MouseLeave, function(): ()
									Objs.KeyText.Color = BindOption.Binding and Library.CurrentTheme["Accent"] or Library.CurrentTheme["Option Text 3"];
								end);

								Utility:Connection(Objs.Holder.MouseButton1Down, function(): ()
									if not BindOption.Binding then
										BindOption:SetKeyText('...');
										BindOption.Binding = true;
									end
								end);
							end

							local C: RBXScriptConnection? = nil;

							function BindOption:SetBind(KeyBind: any): ()
								if C then
									C:Disconnect();
									if BindOption.Flag then
										Library.Flags[BindOption.Flag] = false;
									end
									BindOption.Callback(false);
								end

								local KeyName: string = 'NONE';
								self.Bind = (KeyBind and KeyBind) or KeyBind or self.Bind;

								if self.Bind == Enum.KeyCode.Backspace then
									self.Bind = 'none';
									BindOption.State = true;
									if BindOption.Flag then
										Library.Flags[BindOption.Flag] = BindOption.State;
									end
									self.Callback(true);
									local Display = BindOption.State;
									if BindOption.InvertIndicator then
										Display = not BindOption.State;
									end
									BindOption.IndicatorValue:SetEnabled(Display and not BindOption.NoIndicator);
								else
									KeyName = Library.KeyNames[KeyBind] or (KeyBind and KeyBind.Name) or KeyBind;
								end

								if self.Bind ~= 'none' then
									BindOption.State = false;
									if BindOption.Flag then
										Library.Flags[BindOption.Flag] = BindOption.State;
									end
									self.Callback(false);
									local Display = BindOption.State;
									if BindOption.InvertIndicator then
										Display = not BindOption.State;
									end
									BindOption.IndicatorValue:SetEnabled(Display and not BindOption.NoIndicator);
								end

								self.KeyCallback(self.Bind);
								self:SetKeyText((tostring(KeyName):upper()));
								self.IndicatorValue:SetKey((self.Text == nil or self.Text == '') and (self.Flag == nil and 'unknown' or self.Flag) or self.Text);
								self.IndicatorValue:SetValue('[' .. tostring(KeyName):upper() .. ']');

								if self.Bind == 'none' then
									self.IndicatorValue:SetValue('[Always]');
								end

								self.Objects.KeyText.Color = self.Objects.Holder.Hover and Library.CurrentTheme["Accent"] or Library.CurrentTheme["Option Text 3"];
							end

							function BindOption:SetKeyText(Str: string): ()
								Str = tostring(Str);
								self.Objects.KeyText.Text = '[' .. Str .. ']';
								self.Objects.KeyText.Position = udim2_new(0, 2, 0, 2);
								self.Objects.Holder.Size = udim2_new(0, self.Objects.KeyText.TextBounds.X + 2, 0, 17);
								Toggle:UpdateOptions();
							end

							Utility:Connection(input_service.InputBegan, function(Inp: InputObject): ()
								if input_service:GetFocusedTextBox() then
									return;
								elseif BindOption.Binding then
									local Key = (table_find({ Enum.UserInputType.MouseButton1, Enum.UserInputType.MouseButton2, Enum.UserInputType.MouseButton3 }, Inp.UserInputType) and not BindOption.NoMouse) and Inp.UserInputType;
									BindOption:SetBind(Key or (not table_find(Library.BlacklistedKeys, Inp.KeyCode)) and Inp.KeyCode);
									BindOption.Binding = false;
								elseif not BindOption.Binding and self.Bind == 'none' then
									BindOption.State = true;
									Library.Flags[BindOption.Flag] = BindOption.State;
									local Display = BindOption.State;
									if BindOption.InvertIndicator then
										Display = not BindOption.State;
									end
									BindOption.IndicatorValue:SetEnabled(Display and not BindOption.NoIndicator);
								elseif (Inp.KeyCode == BindOption.Bind or Inp.UserInputType == BindOption.Bind) and not BindOption.Binding then
									if BindOption.Mode == 'toggle' then
										BindOption.State = not BindOption.State;
										if BindOption.Flag then
											Library.Flags[BindOption.Flag] = BindOption.State;
										end
										BindOption.Callback(BindOption.State);
										local Display = BindOption.State;
										if BindOption.InvertIndicator then
											Display = not BindOption.State;
										end
										BindOption.IndicatorValue:SetEnabled(Display and not BindOption.NoIndicator);
									elseif BindOption.Mode == 'hold' then
										if BindOption.Flag then
											Library.Flags[BindOption.Flag] = true;
										end
										BindOption.IndicatorValue:SetEnabled((not BindOption.InvertIndicator and true or false) and not BindOption.NoIndicator);
										C = Utility:Connection(run_service.RenderStepped, function(): ()
											if BindOption.Callback then
												BindOption.Callback(true);
											end
										end);
									end
								end
							end);

							Utility:Connection(input_service.InputEnded, function(Inp: InputObject): ()
								if BindOption.Bind ~= 'none' then
									if Inp.KeyCode == BindOption.Bind or Inp.UserInputType == BindOption.Bind then
										if C then
											C:Disconnect();
											if BindOption.Flag then
												Library.Flags[BindOption.Flag] = false;
											end
											if BindOption.Callback then
												BindOption.Callback(false);
											end
											BindOption.IndicatorValue:SetEnabled(BindOption.InvertIndicator and true or false);
										end
									end
								end
							end);

							Tooltip(BindOption);
							BindOption:SetBind(BindOption.Bind);
							self:UpdateOptions();
							return BindOption;
						end

						function Toggle:AddList(Data: { [string]: any }): { [string]: any }
							local List: { [string]: any } = {
								Class = 'list';
								Flag = Data.Flag;
								Text = '';
								Selected = '';
								Tooltip = '';
								Order = #self.Options + 1;
								Callback = function() end;
								Enabled = true;
								Multi = false;
								Open = false;
								Values = {};
								Objects = {};
							};

							table_insert(self.Options, List);

							local Blacklist5: { string } = { 'objects' };
							for I, V in Data do
								if not table_find(Blacklist5, I) and List[I] ~= nil then
									List[I] = V;
								end
							end

							if List.Flag then
								Library.Flags[List.Flag] = List.Selected;
								Library.Options[List.Flag] = List;
							end

							do
								local Objs: { [string]: any } = List.Objects;
								local Z: number = Library.Order.Window + 25;

								Objs.Holder = Utility:Draw('Square', {
									Size = udim2_new(1, 0, 0, 22);
									Transparency = 0;
									ZIndex = Z + 6;
									Parent = Toggle.Objects.Holder;
								});

								Objs.Background = Utility:Draw('Square', {
									Size = udim2_new(1, -4, 1, -8);
									Position = udim2_new(0, 2, 0, 4);
									ThemeColor = 'Option Background';
									ZIndex = Z + 2;
									Parent = Objs.Holder;
								});

								Objs.Border1 = Utility:Draw('Square', {
									Size = udim2_new(1, 2, 1, 2);
									Position = udim2_new(0, -1, 0, -1);
									ThemeColor = 'Option Border 1';
									ZIndex = Z + 1;
									Parent = Objs.Background;
								});

								Objs.Border2 = Utility:Draw('Square', {
									Size = udim2_new(1, 2, 1, 2);
									Position = udim2_new(0, -1, 0, -1);
									ThemeColor = 'Option Border 2';
									ZIndex = Z;
									Parent = Objs.Border1;
								});

								Objs.Gradient = Utility:Draw('Image', {
									Size = udim2_new(1, 0, 1, 0);
									Data = Library.Images.gradientp90 or Library.Images.GradientP90;
									Transparency = 0.65;
									ZIndex = Z + 4;
									Parent = Objs.Background;
								});

								Objs.InputText = Utility:Draw('Text', {
									Position = udim2_new(0, 4, 0, 0);
									ThemeColor = 'Option Text 2';
									Text = 'none';
									Size = 13;
									Font = 2;
									ZIndex = Z + 5;
									Outline = true;
									Parent = Objs.Background;
								});

								Objs.OpenText = Utility:Draw('Text', {
									Position = udim2_new(1, -10, 0, 0);
									ThemeColor = 'Option Text 3';
									Text = '+';
									Size = 13;
									Font = 2;
									ZIndex = Z + 5;
									Outline = true;
									Parent = Objs.Background;
								});

								Utility:Connection(Objs.Holder.MouseEnter, function(): ()
									Objs.Border1.ThemeColor = 'Accent';
								end);

								Utility:Connection(Objs.Holder.MouseLeave, function(): ()
									Objs.Border1.ThemeColor = 'Option Border 1';
								end);

								Utility:Connection(Objs.Holder.MouseButton1Down, function(): ()
									if List.Open then
										List.Open = false;
										Objs.OpenText.Text = '+';
										if Window.Dropdown.Selected == List then
											Window.Dropdown.Selected = nil;
											Window.Dropdown.Objects.Background.Visible = false;
										end
									else
										if Window.Dropdown.Selected ~= nil then
											Window.Dropdown.Selected.Open = false;
										end
										List.Open = true;
										Objs.OpenText.Text = '-';
										Window.Dropdown.Selected = List;
										Window.Dropdown.Objects.Background.Visible = true;
										Window.Dropdown.Objects.Background.Parent = Objs.Holder;
										Window.Dropdown:Refresh();
									end
								end);
							end

							function List:Select(Option: any, NoCallback: boolean?): ()
								Option = typeof(Option) == 'table' and (self.Multi == true and Option or (#Option == 0 and nil or Option[1])) or self.Multi == true and { Option } or Option;
								if Option ~= nil then
									self.Selected = Option;
									local TextVal: string = typeof(Option) == 'table' and (#Option == 0 and 'none' or table_concat(Option, ', ')) or tostring(Option);
									local Label = self.Objects.InputText;
									Label.Text = TextVal;

									if Label.TextBounds.X > self.Objects.Background.Object.Size.X - 10 then
										local Split = TextVal:split('');
										for I = 1, #Split do
											Label.Text = table_concat(Split, '', 1, I);
											if Label.TextBounds.X > self.Objects.Background.Object.Size.X - 10 then
												Label.Text = Label.Text:sub(1, -6) .. '...';
												break;
											end
										end
									end

									if self.Flag then
										Library.Flags[self.Flag] = self.Selected;
									end

									if not NoCallback then
										self.Callback(self.Selected);
									end
								end
							end

							function List:AddValue(Value: any): ()
								table_insert(List.Values, tostring(Value));
								if Window.Dropdown.Selected == List then
									Window.Dropdown:Refresh();
								end
							end

							function List:RemoveValue(Value: any): ()
								if table_find(List.Values, Value) then
									table_remove(List.Values, table_find(List.Values, Value));
									if Window.Dropdown.Selected == List then
										Window.Dropdown:Refresh();
									end
								end
							end

							function List:ClearValues(): ()
								table_clear(List.Values);
								if Window.Dropdown.Selected == List then
									Window.Dropdown:Refresh();
								end
							end

							Tooltip(List);
							List:Select((Data.value or Data.selected) or (List.Multi and 'none' or List.Values[1]), true);
							self:UpdateOptions();

							return List;
						end

						Tooltip(Toggle);
						Toggle:SetText(Toggle.Text);
						Toggle:SetState(Toggle.State, true);
						self:UpdateOptions();

						return Toggle;
					end;
					
					function Section:Separator(Data: { [string]: any }): any
						local Separator: {
							Class: string,
							Flag: any,
							Text: string,
							Order: number,
							Enabled: boolean,
							Objects: { [string]: any },
							SetText: (self: any, Text: string) -> ()
						} = {
							Class = "Separator",
							Flag = Data.Flag,
							Text = "",
							Order = #self.Options + 1,
							Enabled = true,
							Objects = {},
						}

						local Blacklist: { string } = { "Objects", "Dragging" }
						for Key: string, Value: any in Data do
							if not table_find(Blacklist, Key)
								and Separator[Key] ~= nil
								and typeof(Separator[Key]) == typeof(Value)
							then
								Separator[Key] = Value
							end
						end

						table_insert(self.Options, Separator)

						--// Create Objects
						do
							local Objs: { [string]: any } = Separator.Objects
							local Z: number = Library.Order.Window + 25

							Objs.Holder = Utility:Draw("Square", {
								Size = udim2_new(1, 0, 0, 18),
								Transparency = 0,
								ZIndex = Z,
								Parent = Section.Objects.OptionHolder,
							})

							Objs.Line1 = Utility:Draw("Square", {
								Position = udim2_new(0, 0, 0, 1),
								Color = Library.CurrentTheme["Option Background"],
								ZIndex = Z + 1,
								Parent = Objs.Holder,
							})

							Objs.Line2 = Utility:Draw("Square", {
								Position = udim2_new(0, 0, 0, 1),
								Color = Library.CurrentTheme["Option Background"],
								ZIndex = Z + 1,
								Parent = Objs.Holder,
							})

							Objs.Border1 = Utility:Draw("Square", {
								Size = udim2_new(1, 2, 1, 2),
								Position = udim2_new(0, -1, 0, -1),
								Color = Library.CurrentTheme["Option Border 2"],
								ZIndex = Z,
								Parent = Objs.Line1,
							})

							Objs.Border2 = Utility:Draw("Square", {
								Size = udim2_new(1, 2, 1, 2),
								Position = udim2_new(0, -1, 0, -1),
								Color = Library.CurrentTheme["Option Border 2"],
								ZIndex = Z,
								Parent = Objs.Line2,
							})

							Objs.Text = Utility:Draw("Text", {
								Position = udim2_new(0.5, 0, 0, 1),
								Color = Library.CurrentTheme["Option Text 2"],
								Size = 13,
								Font = 2,
								ZIndex = Z,
								Outline = true,
								Center = true,
								Parent = Objs.Holder,
							})
						end

						function Separator:SetText(Value: string): ()
							if typeof(Value) == "string" then
								self.Text = Value
								self.Objects.Text.Text = Value

								local TextBoundsX: number = self.Objects.Text.TextBounds.X
								local HolderWidth: number = self.Objects.Holder.Object.Size.X
								local XScale: number =
									(1 - Utility:ConvertNumberRange(
										TextBoundsX,
										0,
										HolderWidth,
										0,
										1
										)) / 2 - (Value == "" and 0 or 0.04)

								self.Objects.Line1.Size = string_len(Value or "") == 0 and udim2_new(XScale, 0, 0, 1) or udim2_new(XScale * 0.9, 0, 0, 1)
								self.Objects.Line2.Size = string_len(Value or "") == 0 and udim2_new(XScale, 0, 0, 1) or udim2_new(XScale * 0.9, 0, 0, 1)

								self.Objects.Line1.Position = udim2_new(0, 1, 0.5, -1)
								self.Objects.Line2.Position =
									udim2_new(1 - self.Objects.Line2.Size.X.Scale, -1, 0.5, -1)
							end
						end

						Separator:SetText(Separator.Text)
						self:UpdateOptions()

						return Separator;
					end
					
					function Section:Button(Data: { [string]: any }): any
						local ZBase: number = Library.Order.Window + 25

						--// Button object
						local Button: {
							Class: string,
							Flag: any,
							Text: string,
							Suffix: string,
							Tooltip: string,
							Order: number,
							Callback: () -> (),
							Confirm: boolean,
							Enabled: boolean,
							Risky: boolean,
							Objects: { [string]: any },
							SubButtons: { any },

							Button: ( self: any, Data: {} ) -> any,
							UpdateOptions: (self: any) -> (),
							SetText: (self: any, Text: string) -> ()
						} = {
							Class = "Button",
							Flag = Data.Flag,
							Text = "",
							Suffix = "",
							Tooltip = "",
							Order = #self.Options + 1,
							Callback = function(): () end,
							Confirm = false,
							Enabled = true,
							Risky = false,
							Objects = {},
							SubButtons = {},
						}

						for Key: string, Value: any in Data do
							if Button[Key] ~= nil then
								Button[Key] = Value
							end
						end

						table_insert(self.Options, Button)
						
						if Button.Flag then
							Library.Options[Button.Flag] = Button
						end

						do
							local Objs = Button.Objects

							Objs.Holder = Utility:Draw("Square", {
								Size = udim2_new(1, 0, 0, 22),
								Transparency = 0,
								ZIndex = ZBase + 4,
								Parent = Section.Objects.OptionHolder,
							})

							Objs.Background = Utility:Draw("Square", {
								Size = udim2_new(1, -4, 0, 14),
								Position = udim2_new(0, 2, 0, 4),
								Color = Library.CurrentTheme["Option Background"],
								ZIndex = ZBase + 2,
								Parent = Objs.Holder,
							})

							Objs.Border1 = Utility:Draw("Square", {
								Size = udim2_new(1, 2, 1, 2),
								Position = udim2_new(0, -1, 0, -1),
								Color = Library.CurrentTheme["Option Border 1"],
								ZIndex = ZBase + 1,
								Parent = Objs.Background,
							})

							Objs.Border2 = Utility:Draw("Square", {
								Size = udim2_new(1, 2, 1, 2),
								Position = udim2_new(0, -1, 0, -1),
								Color = Library.CurrentTheme["Option Border 2"],
								ZIndex = ZBase,
								Parent = Objs.Border1,
							})

							Objs.Gradient = Utility:Draw("Image", {
								Size = udim2_new(1, 0, 1, 0),
								Data = Library.Images.gradientp90,
								Transparency = 0.65,
								ZIndex = ZBase + 3,
								Parent = Objs.Background,
							})

							Objs.Text = Utility:Draw("Text", {
								Position = udim2_new(0.5, 0, 0, 0),
								Color = Library.CurrentTheme["Option Text 3"],
								Size = 13,
								Font = 2,
								ZIndex = ZBase + 4,
								Outline = true,
								Center = true,
								Parent = Objs.Background,
							})

							--// Hover / click
							Utility:Connection(Objs.Holder.MouseEnter, function(): ()
								Objs.Border1.Color = Library.CurrentTheme["Accent"]
							end)

							Utility:Connection(Objs.Holder.MouseLeave, function(): ()
								Objs.Border1.Color = Library.CurrentTheme["Option Border 1"]
								Objs.Text.Color = Library.CurrentTheme[Button.Risky and "Risky Text" or "Option Text 3"]
								Objs.Background.Color = Library.CurrentTheme["Option Background"]
								Objs.Background.Color = Utility:AddRGB(Library.CurrentTheme["Option Background"], color3_fromRGB(0, 0, 0));
							end)

							Utility:Connection(Objs.Holder.MouseButton1Up, function(): ()
								Objs.Text.ThemeColor = Button.Risky and "Risky Text" or "Option Text 3"
								Objs.Background.Color = Library.CurrentTheme["Option Background"]
								Objs.Background.Color = Utility:AddRGB(Library.CurrentTheme["Option Background"], color3_fromRGB(0, 0, 0));
							end)

							local Clicked: boolean = false
							local Counting: boolean = false

							Utility:Connection(Objs.Holder.MouseButton1Down, function(): ()
								Objs.Text.Color = Library.CurrentTheme[Button.Risky and "Risky Text Enabled" or "Option Text 2"]
								Objs.Background.Color = "Accent"
								Objs.Background.Color = Utility:AddRGB(Library.CurrentTheme["Accent"], color3_fromRGB(-95, -95, -95));

								task_spawn(function(): ()
									if not Button.Confirm then
										Button.Callback()
										return
									end

									if Clicked then
										Clicked = false
										Counting = false
										Objs.Text.Text = Button.Text
										Button.Callback()
										return
									end

									Clicked = true
									Counting = true
									
									for i = 3, 1, -1 do
										if not Counting then break end
										Objs.Text.Text = ("Confirm %s? %d"):format(Button.Text, i)
										task_wait(1)
									end

									Clicked = false
									Counting = false
									Objs.Text.Text = Button.Text
								end)
							end)
						end

						function Button:Button(SubData: { [string]: any }): any
							local SubButton = Section:Button(SubData)
							
							table_insert(self.SubButtons, SubButton)
							
							self:UpdateOptions()
							
							return SubButton
						end

						function Button:UpdateOptions(): ()
							local Count: number = 1 + #self.SubButtons
							local SizeX: number = (1 / Count) - 0.005

							self.Objects.Background.Size = udim2_new(SizeX, -4, 0, 14)

							for Index: number, Sub: any in self.SubButtons do
								Sub.Objects.Holder.Size = udim2_new(SizeX, 0, 1, 0)
								Sub.Objects.Holder.Position = udim2_new(Index * SizeX + 0.01, 0, 0, 0)
							end
						end

						function Button:SetText(Value: string): ()
							if typeof(Value) == "string" then
								self.Text = Value
								self.Objects.Text.Text = Value
							end
						end

						Tooltip(Button)
						Button:SetText(Button.Text)
						Button:UpdateOptions()

						return Button;
					end;
					
					function Section:Textbox(Data: { [string]: any }): any
						local ZBase: number = Library.Order.Window + 25

						local Box: {
							Class: string,
							Flag: any,
							Text: string,
							Input: string,
							Order: number,
							Callback: (Value: string) -> (),
							Enabled: boolean,
							Focused: boolean,
							Risky: boolean,
							Objects: { [string]: any },

							SetText: (self: any, Value: string) -> (),
							SetInput: (self: any, Value: string, NoCallback: boolean?) -> (),
							CaptureFocus: (self: any, Clear: boolean?) -> (),
							ReleaseFocus: (self: any, Apply: boolean?) -> ()
						} = {
							Class = "Box",
							Flag = Data.Flag,
							Text = "",
							Input = "",
							Order = #self.Options + 1,
							Callback = function(_: string): () end,
							Enabled = true,
							Focused = false,
							Risky = false,
							Objects = {},
						}

						for Key: string, Value: any in Data do
							if Box[Key] ~= nil then
								Box[Key] = Value
							end
						end

						table_insert(self.Options, Box)

						if Box.Flag then
							Library.Flags[Box.Flag] = Box.Input
							Library.Options[Box.Flag] = Box
						end

						do
							local Objs = Box.Objects

							Objs.Holder = Utility:Draw("Square", {
								Size = udim2_new(1, 0, 0, 37),
								Transparency = 0,
								ZIndex = ZBase + 4,
								Parent = Section.Objects.OptionHolder,
							})

							Objs.Background = Utility:Draw("Square", {
								Size = udim2_new(1, -4, 0, 15),
								Position = udim2_new(0, 2, 1, -17),
								Color = Library.CurrentTheme["Option Background"],
								ZIndex = ZBase + 2,
								Parent = Objs.Holder,
							})

							Objs.Border1 = Utility:Draw("Square", {
								Size = udim2_new(1, 2, 1, 2),
								Position = udim2_new(0, -1, 0, -1),
								Color = Library.CurrentTheme["Option Border 1"],
								ZIndex = ZBase + 1,
								Parent = Objs.Background,
							})

							Objs.Border2 = Utility:Draw("Square", {
								Size = udim2_new(1, 2, 1, 2),
								Position = udim2_new(0, -1, 0, -1),
								Color = Library.CurrentTheme["Option Border 2"],
								ZIndex = ZBase,
								Parent = Objs.Border1,
							})

							Objs.Gradient = Utility:Draw("Image", {
								Size = udim2_new(1, 0, 1, 0),
								Data = Library.Images.gradientp90,
								Transparency = 0.65,
								ZIndex = ZBase + 4,
								Parent = Objs.Background,
							})

							Objs.Text = Utility:Draw("Text", {
								Position = udim2_new(0, 2, 0, 2),
								Color = Library.CurrentTheme[
								Box.Risky and "Risky Text Enabled" or "Option Text 2"
								],
								Size = 13,
								Font = 2,
								ZIndex = ZBase + 1,
								Outline = true,
								Parent = Objs.Holder,
							})

							Objs.InputText = Utility:Draw("Text", {
								Position = udim2_new(0, 2, 0, 0),
								Color = Library.CurrentTheme["Option Text 2"],
								Size = 13,
								Font = 2,
								ZIndex = ZBase + 5,
								Outline = true,
								Parent = Objs.Background,
							})

							Utility:Connection(Objs.Holder.MouseEnter, function(): ()
								Objs.Border1.Color = Library.CurrentTheme["Accent"]
							end)

							Utility:Connection(Objs.Holder.MouseLeave, function(): ()
								Objs.Border1.Color = Library.CurrentTheme["Option Border 1"]
							end)

							Utility:Connection(Objs.Holder.MouseButton1Down, function(): ()
								if Box.Focused then
									Box:ReleaseFocus()
									context_action_service:UnbindAction("FreezeMovement")
									return
								end

								context_action_service:BindAction(
									"FreezeMovement",
									function(): Enum.ContextActionResult
										return Enum.ContextActionResult.Sink
									end,
									false,
									table_unpack(Enum.PlayerActions:GetEnumItems())
								)

								local Clear: boolean = input_service:IsKeyDown(Enum.KeyCode.LeftControl)
								Box:CaptureFocus(Clear)

								if Clear then
									Objs.InputText.Text = ""
								end
							end)
						end

						function Box:SetText(Value: string): ()
							if typeof(Value) == "string" then
								self.Text = Value
								self.Objects.Text.Text = Value
							end
						end

						function Box:SetInput(Value: string, NoCallback: boolean?): ()
							if typeof(Value) ~= "string" then
								return
							end

							self.Input = Value
							self.Objects.InputText.Text = Value

							if not NoCallback then
								self.Callback(Value)
							end

							if self.Flag then
								Library.Flags[self.Flag] = Value
							end
						end

						local InputBuffer: string = Box.Input
						local InputConn: RBXScriptConnection?

						function Box:CaptureFocus(Clear: boolean?): ()
							self.Focused = true

							if Clear then
								InputBuffer = ""
							end

							self.Objects.InputText.Color = Library.CurrentTheme["Option Text 1"]

							InputConn = Utility:Connection(input_service.InputBegan, function(Input: InputObject): ()
								if Input.KeyCode == Enum.KeyCode.Return
									or Input.UserInputType == Enum.UserInputType.MouseButton1
								then
									self:ReleaseFocus(true)
									return
								end

								if Input.KeyCode == Enum.KeyCode.Escape then
									InputBuffer = self.Input
									self.Objects.InputText.Text = InputBuffer
									self:ReleaseFocus()
									return
								end

								if Input.KeyCode == Enum.KeyCode.Backspace then
									InputBuffer = InputBuffer:sub(1, -2)
									self.Objects.InputText.Text = InputBuffer
									return
								end

								local KeyName: string = Input.KeyCode.Name
								local Char: string?

								if #KeyName == 1 then
									Char = KeyName
								elseif KeyName == "Space" then
									Char = " "
								elseif KeyName == "Minus" then
									Char = input_service:IsKeyDown(Enum.KeyCode.LeftShift) and "_" or "-"
								elseif KeyName == "Equals" then
									Char = input_service:IsKeyDown(Enum.KeyCode.LeftShift) and "+" or "="
								elseif KeyName == "Backquote" then
									Char = input_service:IsKeyDown(Enum.KeyCode.LeftShift) and "~" or "`"
								else
									local Index = table_find(Library.WhitelistedBoxKeys, Input.KeyCode)
									if Index then
										Char = tostring(Index - 1)
									end
								end

								if not Char then
									return
								end

								if input_service:IsKeyDown(Enum.KeyCode.LeftShift) then
									Char = ({
										["1"] = "!",
										["2"] = "@",
										["3"] = "#",
										["4"] = "$",
										["5"] = "%",
										["6"] = "^",
										["7"] = "&",
										["8"] = "*",
										["9"] = "(",
										["0"] = ")",
									})[Char] or Char
								else
									Char = Char:lower()
								end

								InputBuffer ..= Char
								self.Objects.InputText.Text = InputBuffer
							end)
						end

						function Box:ReleaseFocus(Apply: boolean?): ()
							self.Focused = false
							self.Objects.InputText.Color = Library.CurrentTheme["Option Text 2"]

							if Apply then
								self:SetInput(InputBuffer)
							end

							if InputConn then
								InputConn:Disconnect()
								InputConn = nil
							end
						end

						Tooltip(Box)
						Box:SetText(Box.Text)
						Box:SetInput(Box.Input, true)
						self:UpdateOptions()

						return Box;
					end;


					function Section:Dropdown(Data)
						local List = {
							Class = 'List';
							Flag = Data.Flag;
							Text = '';
							Selected = '';
							Tooltip = '';
							Order = #self.Options + 1;
							Callback = function() end;
							Enabled = true;
							Multi = false;
							Open = false;
							Risky = false;
							Values = {};
							Objects = {};
						}

						table_insert(self.Options, List);

						local Blacklist = {'Objects'};
						for i, v in Data do
							if not table_find(Blacklist, i) ~= List[i] ~= nil then
								List[i] = v
							end
						end

						if List.Flag then
							Library.Flags[List.Flag] = List.Selected;
							Library.Options[List.Flag] = List;
						end

						do
							local Objs = List.Objects;
							local Z = Library.Order.Window + 25;

							Objs.Holder = Utility:Draw('Square', {
								Size = udim2_new(1, 0, 0, 40);
								Transparency = 0;
								ZIndex = Z + 4;
								Parent = Section.Objects.OptionHolder;
							})

							Objs.Background = Utility:Draw('Square', {
								Size = udim2_new(1, -4, 0, 15);
								Position = udim2_new(0, 2, 1, -19);
								Color = Library.CurrentTheme["Option Background"];
								ZIndex = Z + 2;
								Parent = Objs.Holder;
							})

							Objs.Border1 = Utility:Draw('Square', {
								Size = udim2_new(1, 2, 1, 2);
								Position = udim2_new(0, -1, 0, -1);
								Color = Library.CurrentTheme["Option Border 1"];
								ZIndex = Z + 1;
								Parent = Objs.Background;
							})

							Objs.Border2 = Utility:Draw('Square', {
								Size = udim2_new(1, 2, 1, 2);
								Position = udim2_new(0, -1, 0, -1);
								Color = Library.CurrentTheme["Option Border 2"];
								ZIndex = Z;
								Parent = Objs.Border1;
							})

							Objs.Gradient = Utility:Draw('Image', {
								Size = udim2_new(1, 0, 1, 0);
								Data = Library.Images.gradientp90;
								Transparency = .65;
								ZIndex = Z + 4;
								Parent = Objs.Background;
							})

							Objs.Text = Utility:Draw('Text', {
								Position = udim2_new(0, 2, 0, 2);
								Color = Library.CurrentTheme[List.Risky and "Risky Text Enabled" or "Option Text 2"];
								Size = 13;
								Font = 2;
								ZIndex = Z + 1;
								Outline = true;
								Parent = Objs.Holder;
							})

							Objs.InputText = Utility:Draw('Text', {
								Position = udim2_new(0, 4, 0, 0);
								Color = Library.CurrentTheme["Option Text 2"];
								Text = 'None';
								Size = 13;
								Font = 2;
								ZIndex = Z + 5;
								Outline = true;
								Parent = Objs.Background;
							})

							Objs.OpenText = Utility:Draw('Text', {
								Position = udim2_new(1, -10, 0, 0);
								Color = Library.CurrentTheme["Option Text 3"];
								Text = '+';
								Size = 13;
								Font = 2;
								ZIndex = Z + 5;
								Outline = true;
								Parent = Objs.Background;
							})


							Utility:Connection(Objs.Holder.MouseEnter, function()
								Objs.Border1.Color = Library.CurrentTheme["Accent"];
							end)

							Utility:Connection(Objs.Holder.MouseLeave, function()
								Objs.Border1.Color = Library.CurrentTheme["Option Border 1"];
							end)

							Utility:Connection(Objs.Holder.MouseButton1Down, function()
								if List.Open then
									List.Open = false;
									Objs.OpenText.Text = '+';
									if Window.Dropdown.Selected == List then
										Window.Dropdown.Selected = nil;
										Window.Dropdown.Objects.Background.Visible = false;
									end
								else
									if Window.Dropdown.Selected ~= nil then
										Window.Dropdown.Selected.Open = false
									end
									List.Open = true;
									Objs.OpenText.Text = '-';
									Window.Dropdown.Selected = List;
									Window.Dropdown.Objects.Background.Visible = true;
									Window.Dropdown.Objects.Background.Parent = Objs.Holder;
									Window.Dropdown:Refresh();
								end
							end)
						end


						function List:SetText(Str)
							if typeof(Str) == 'string' then
								self.Text = Str;
								self.Objects.Text.Text = Str;
							end
						end

						function List:Select(Option, NoCallback)
							Option = typeof(Option) == 'table' and (self.Multi == true and Option or (#Option == 0 and nil or Option[1])) or self.Multi == true and {Option} or Option;
							if Option ~= nil then
								self.Selected = Option;
								local Text = typeof(Option) == 'table' and (#Option == 0 and "None" or table_concat(Option, ', ')) or tostring(Option);
								local Label = self.Objects.InputText
								Label.Text = Text;
								if Label.TextBounds.X > self.Objects.Background.Object.Size.X - 10 then
									local Split = Text:split('');
									for i = 1, #Split do
										Label.Text = table_concat(Split, '', 1, i)
										if Label.TextBounds.X > self.Objects.Background.Object.Size.X - 10 then
											Label.Text = Label.Text:sub(1, -6) .. '...';
											break
										end
									end
								end
								if self.Flag then
									Library.Flags[self.Flag] = self.Selected
								end

								if not NoCallback then
									self.Callback(self.Selected);
								end
							end
						end

						function List:AddValue(Value)
							table_insert(List.Values, tostring(Value));
							if Window.Dropdown.Selected == List then
								Window.Dropdown:Refresh()
							end
						end

						function List:RemoveValue(Value)
							if table_find(List.Values, Value) then
								table_remove(List.Values, table_find(List.Values, Value));
								if Window.Dropdown.Selected == List then
									Window.Dropdown:Refresh()
								end
							end
						end

						function List:ClearValues()
							table_clear(List.Values);
							if Window.Dropdown.Selected == List then
								Window.Dropdown:Refresh()
							end
						end

						Tooltip(List);
						List:Select((Data.Value or Data.Selected) or (List.Multi and 'None' or List.Values[1]), true);
						List:SetText(List.Text);
						self:UpdateOptions();

						return List
					end



					function Section:Slider(Data: {}): any
						local SliderInstance: any = {
							Class = "Slider",
							Flag = Data.Flag,
							Text = Data.Text or "",
							Tooltip = Data.Tooltip or "",
							Suffix = Data.Suffix or "",
							Order = #self.Options + 1,
							Value = Data.Value or 0,
							Min = Data.Min or 0,
							Max = Data.Max or 100,
							Increment = Data.Increment or 1,
							Callback = Data.Callback or function() end,
							Enabled = Data.Enabled ~= false,
							Dragging = false,
							Focused = false,
							Risky = Data.Risky or false,
							Objects = {},
						}

						local Blacklist: { string } = { 'objects' };

						for I, V in Data do
							if not table_find(Blacklist, I) and SliderInstance[I] ~= nil then
								SliderInstance[I] = V;
							end
						end

						table_insert(self.Options, SliderInstance);

						if SliderInstance.Flag then
							Library.Flags[SliderInstance.Flag] = SliderInstance.Value
							Library.Options[SliderInstance.Flag] = SliderInstance
						end

						--// Objects
						do
							local Objects = SliderInstance.Objects
							local ZIndex = Library.Order.Window + 25

							Objects.Holder = Utility:Draw("Square", {
								Size = udim2_new(1, 0, 0, 32),
								Transparency = 0,
								ZIndex = ZIndex + 4,
								Parent = self.Objects.OptionHolder,
							})

							Objects.Background = Utility:Draw("Square", {
								Size = udim2_new(1, -4, 0, 11),
								Position = udim2_new(0, 2, 1, -14),
								Color = Library.CurrentTheme["Option Background"],
								ZIndex = ZIndex + 2,
								Parent = Objects.Holder,
							})

							Objects.Slider = Utility:Draw("Square", {
								Size = udim2_new(0, 0, 1, 0),
								Color = Library.CurrentTheme["Accent"],
								ZIndex = ZIndex + 3,
								Parent = Objects.Background,
							})

							Objects.Border1 = Utility:Draw("Square", {
								Size = udim2_new(1, 2, 1, 2),
								Position = udim2_new(0, -1, 0, -1),
								Color = Library.CurrentTheme["Option Border 1"],
								ZIndex = ZIndex + 1,
								Parent = Objects.Background,
							})

							Objects.Border2 = Utility:Draw("Square", {
								Size = udim2_new(1, 2, 1, 2),
								Position = udim2_new(0, -1, 0, -1),
								Color = Library.CurrentTheme["Option Border 2"],
								ZIndex = ZIndex,
								Parent = Objects.Border1,
							})

							Objects.Gradient = Utility:Draw("Image", {
								Size = udim2_new(1, 0, 1, 0),
								Data = Library.Images.gradientp90,
								Transparency = 0.65,
								ZIndex = ZIndex + 4,
								Parent = Objects.Background,
							})

							Objects.Text = Utility:Draw("Text", {
								Position = udim2_new(0, 2, 0, 1),
								Color = Library.CurrentTheme["Option Text 3"],
								Size = 13,
								Font = 2,
								ZIndex = ZIndex + 1,
								Outline = true,
								Parent = Objects.Holder,
							})

							Objects.PlusDetector = Utility:Draw("Square", {
								Size = udim2_new(0, 14, 0, 14),
								Position = udim2_new(1, -28, 0, 1),
								Transparency = 0,
								ZIndex = ZIndex + 5,
								Parent = Objects.Holder,
							})

							Objects.MinusDetector = Utility:Draw("Square", {
								Size = udim2_new(0, 14, 0, 14),
								Position = udim2_new(1, -14, 0, 1),
								Transparency = 0,
								ZIndex = ZIndex + 5,
								Parent = Objects.Holder,
							})

							Objects.PlusText = Utility:Draw("Text", {
								Position = udim2_new(0.5, 0, 0, -1),
								Text = "+",
								Color = Library.CurrentTheme["Option Text 3"],
								Size = 13,
								Font = 2,
								ZIndex = ZIndex + 4,
								Center = true,
								Outline = true,
								Parent = Objects.PlusDetector,
							})

							Objects.MinusText = Utility:Draw("Text", {
								Position = udim2_new(0.5, 0, 0, -1),
								Text = "-",
								Color = Library.CurrentTheme["Option Text 3"],
								Size = 13,
								Font = 2,
								ZIndex = ZIndex + 4,
								Center = true,
								Outline = true,
								Parent = Objects.MinusDetector,
							})


							--// Hover
							Utility:Connection(Objects.Holder.MouseEnter, function()
								Objects.Border1.Color = Library.CurrentTheme["Accent"]
							end)

							Utility:Connection(Objects.Holder.MouseLeave, function()
								Objects.Border1.Color = SliderInstance.Dragging and Library.CurrentTheme["Accent"] or Library.CurrentTheme["Option Border 1"]
							end)

							--// Increment / Decrement
							Utility:Connection(Objects.PlusDetector.MouseButton1Down, function()
								local Step = input_service:IsKeyDown(Enum.KeyCode.LeftShift) and 10 or SliderInstance.Increment
								SliderInstance:SetValue(SliderInstance.Value + Step)
							end)

							Utility:Connection(Objects.MinusDetector.MouseButton1Down, function()
								local Step = input_service:IsKeyDown(Enum.KeyCode.LeftShift) and 10 or SliderInstance.Increment
								SliderInstance:SetValue(SliderInstance.Value - Step)
							end)

							--// Drag / Manual Input
							local InputConnection: RBXScriptConnection?
							local InputBuffer = ""

							Utility:Connection(Objects.Holder.MouseButton1Down, function()
								if input_service:IsKeyDown(Enum.KeyCode.LeftControl) then
									if SliderInstance.Focused then
										SliderInstance.Focused = false
										if InputConnection then
											InputConnection:Disconnect()
										end
									else
										SliderInstance.Focused = true
										InputBuffer = ""
										Objects.Text.Text = string_format(
											"%s: %s%s []",
											SliderInstance.Text,
											SliderInstance.Value,
											SliderInstance.Suffix
										)

										InputConnection = Utility:Connection(input_service.InputBegan, function(Input)
											local Key = Input.KeyCode

											if Library.NumberStrings[Key.Name] then
												InputBuffer ..= tostring(Library.NumberStrings[Key.Name])
											elseif Key == Enum.KeyCode.Backspace then
												InputBuffer = InputBuffer:sub(1, -2)
											elseif Key == Enum.KeyCode.Return then
												SliderInstance:SetValue(tonumber(InputBuffer))
												SliderInstance.Focused = false
												InputConnection:Disconnect()
												return
											elseif Key == Enum.KeyCode.Escape then
												SliderInstance:SetValue(SliderInstance.Value, true)
												SliderInstance.Focused = false
												InputConnection:Disconnect()
												return
											end

											Objects.Text.Text = string_format(
												"%s: %.14g%s [%s]",
												SliderInstance.Text,
												SliderInstance.Value,
												SliderInstance.Suffix,
												InputBuffer
											)
										end)
									end
								else
									SliderInstance.Dragging = true
									Library.DraggingSlider = SliderInstance
								end
							end)

							Utility:Connection(Button1Up, function()
								SliderInstance.Dragging = false
								Library.DraggingSlider = nil
								Objects.Border1.ThemeColor = Objects.Holder.Hover and "Accent" or "Option Border 1"
							end)
						end

						function SliderInstance:SetValue(NewValue: number?, Silent: boolean?)
							if not self.Enabled then
								return
							end

							local Value = tonumber(NewValue)
							if not Value then
								return
							end

							--// Clamp
							Value = math_clamp(Value, self.Min, self.Max)

							--// Snap to increment
							local Increment = self.Increment
							if Increment > 0 then
								Value = math_floor((Value - self.Min) / Increment + 0.5) * Increment + self.Min
							end

							if Value == self.Value then
								return
							end

							self.Value = Value

							--// Update bar size
							local Alpha = (Value - self.Min) / (self.Max - self.Min)
							self.Objects.Slider.Size = udim2_new(Alpha, 0, 1, 0)

							--// Update text
							self.Objects.Text.Text = string_format(
								"%s: %.14g%s",
								self.Text,
								Value,
								self.Suffix
							)

							--// Flags
							if self.Flag then
								Library.Flags[self.Flag] = Value
							end

							--// Callback
							if not Silent then
								task_spawn(self.Callback, Value)
							end
						end

						function SliderInstance:SetText(NewText: string)
							if self.Text == NewText then
								return
							end

							self.Text = NewText

							--// Update label
							self.Objects.Text.Text = string_format(
								"%s: %.14g%s",
								SliderInstance.Text,
								self.Value,
								self.Suffix
							)
						end


						--// Update
						Tooltip(SliderInstance)
						SliderInstance:SetValue(SliderInstance.Value, true)
						SliderInstance:SetText(SliderInstance.Text)
						SliderInstance.Objects.Text.Text = string_format(
							"%s: %.14g%s [%s]",
							SliderInstance.Text,
							SliderInstance.Value,
							SliderInstance.Suffix,
							""
						)
						self:UpdateOptions()
						Section:UpdateOptions()



						return SliderInstance
					end





					Section:SetEnabled(true)
					Section:UpdateOptions()
					Section:SetText(Text)

					return Section;
				end;

				function Tab:UpdateSections(): ()
					table_sort(self.Sections, function(A, B)
						return A.Order < B.Order;
					end);

					local LastLeft: any = nil;
					local LastRight: any = nil;
					local Padding: number = 15;

					for _, Section in self.Sections do
						local Visible: boolean = Section.Enabled and self.Selected;

						if Section.Objects.Background.Visible ~= Visible then
							Section.Objects.Background.Visible = Visible;
							Section:UpdateOptions();
						end

						if Section.Enabled then
							if Section.Side == 1 then
								if LastLeft then
									Section.Objects.Background.Position =
										LastLeft.Objects.Background.Position
										+ udim2_new(
											0,
											0,
											0,
											LastLeft.Objects.Background.Object.Size.Y + Padding
										);
								end

								LastLeft = Section;

							elseif Section.Side == 2 then
								if LastRight then
									Section.Objects.Background.Position =
										LastRight.Objects.Background.Position
										+ udim2_new(
											0,
											0,
											0,
											LastRight.Objects.Background.Object.Size.Y + Padding
										);
								end

								LastRight = Section;
							end
						end

						Section:SetText(Section.Text);
					end
				end;



				function Tab:Select(): ()
					Window.SelectedTab = Tab;
					Window:UpdateTabs();

					for _, V in Window.Tabs do
						if V.Callback then
							V.Callback(V == self);
						end
					end
				end;


				if rawequal(Window.SelectedTab, nil) then
					Tab:Select();
				end

				Window:UpdateTabs();

				return Tab;
			end;

			--// colorpicker impl
			do
				--// Objects
				do
					local Objs = Window.ColorPicker.Objects
					local Z = Library.Order.Colorpicker

					Objs.Background = Utility:Draw("Square", {
						Visible = false,
						Size = udim2_new(0, 200, 0, 242),
						Position = udim2_new(1, -200, 1, 10),
						Color = Library.CurrentTheme["Background"],
						ZIndex = Z,
						Parent = Window.Objects.background,
					})

					Objs.Border1 = Utility:Draw("Square", {
						Size = udim2_new(1, 2, 1, 2),
						Position = udim2_new(0, -1, 0, -1),
						Color = Library.CurrentTheme["Border"],
						ZIndex = Z - 1,
						Parent = Objs.Background,
					})

					Objs.Border2 = Utility:Draw("Square", {
						Size = udim2_new(1, 2, 1, 2),
						Position = udim2_new(0, -1, 0, -1),
						Color = Library.CurrentTheme["Border 1"],
						ZIndex = Z - 2,
						Parent = Objs.Border1,
					})

					Objs.Border3 = Utility:Draw("Square", {
						Size = udim2_new(1, 2, 1, 2),
						Position = udim2_new(0, -1, 0, -1),
						Color = Library.CurrentTheme["Border"],
						ZIndex = Z - 3,
						Parent = Objs.Border2,
					})

					Objs.StatusText = Utility:Draw("Text", {
						Position = udim2_new(0, 5, 0, 4),
						Text = "colorpicker_status_text",
						Color = Library.CurrentTheme["Option Text 1"],
						Size = 13,
						Font = 2,
						Outline = true,
						ZIndex = Z + 1,
						Parent = Objs.Background,
					})

					Objs.MainColor = Utility:Draw("Square", {
						Size = udim2_new(0, 175, 0, 175),
						Position = udim2_new(0, 5, 0, 25),
						Color = color3_new(1, 0, 0),
						ZIndex = Z + 2,
						Parent = Objs.Background,
					})

					Objs.Sat1 = Utility:Draw("Image", {
						Size = udim2_new(1, 0, 1, 0),
						Data = crypt.base64.decode"iVBORw0KGgoAAAANSUhEUgAAAaQAAAGkCAQAAADURZm+AAAABGdBTUEAALGPC/xhBQAAACBjSFJNAAB6JQAAgIMAAPn/AACA6QAAdTAAAOpgAAA6mAAAF2+SX8VGAAAAAmJLR0QA/4ePzL8AAAAJcEhZcwAACxMAAAsTAQCanBgAAAAHdElNRQflBwwSLzK3wl3KAAADrElEQVR42u3TORLCMBBFwT+6/50hMqXSZgonBN0BWCDGYPwqeSWVZPWYVHd0Pc5H86v9areu4Sz9u7XZXT/vvtZtu6dtJtYw525iGya05afnWW17ltPE8fzfTZy/yf3vmCes59xf0Sf/42l3lnvGOyyH+y/bo/X689wCPCYkEBIICYQECAmEBEICIQFCAiGBkEBIgJBASCAkEBIgJBASCAmEBAgJhARCAiEBQgIhgZAAIYGQQEggJEBIICQQEggJEBIICYQEQgKEBEICIYGQACGBkEBIICRASCAkEBIICRASCAmEBAgJhARCAiEBQgIhgZBASICQQEggJBASICQQEggJhAQICYQEQgIhAUICIYGQQEguAQgJhARCAoQEQgIhgZAAIYGQQEggJEBIICQQEggJEBIICYQEQgKEBEICIYGQACGBkEBIgJBASCAkEBIgJBASCAmEBAgJhARCAiEBQgIhgZBASICQQEggJBASICQQEggJhAQICYQEQgKEBEICIYGQACGBkEBIICRASCAkEBIICRASCAmEBEIChARCAiGBkAAhgZBASCAkQEggJBASICQQEggJhAQICYQEQgIhAUICIYGQQEiAkEBIICQQEiAkEBIICYQECAmEBEIChARCAiGBkAAhgZBASCAkQEggJBASCAkQEggJhARCAoQEQgIhgZAAIYGQQEggJEBIICQQEiAkEBIICYQECAmEBEICIQFCAiGBkEBIgJBASCAkEBIgJBASCAmEBAgJhARCAiEBQgIhgZAAIYGQQEggJEBIICQQEggJEBIICYQEQgKEBEICIYGQACGBkEBIICRASCAkEBIgJBASCAmEBAgJhARCAiEBQgIhgZBASICQQEggJBASICQQEggJhAQICYQEQgIhAUICIYGQACGBkEBIICRASCAkEBIICRASCAmEBEIChARCAiGBkAAhgZBASCAkQEggJBASCAkQEggJhAQICYQEQgIhAUICIYGQQEiAkEBIICQQEiAkEBIICYQECAmEBEICIQFCAiGBkEBILgEICYQEQgKEBEICIYGQACGBkEBIICRASCAkEBIICRASCAmEBEIChARCAiGBkAAhgZBASICQQEggJBASICQQEggJhAQICYQEQgIhAUICIYGQQEiAkEBIICQQEiAkEBIICYQECAmEBEIChARCAiGBkAAhgZBASCAkQEggJBASCAkQEggJhARCAoQEQgIhgZAAIYGQQEggJEBIICQQEiAkEBL8lzft9AVFFzN+ywAAACV0RVh0ZGF0ZTpjcmVhdGUAMjAyMS0wNy0xMlQxODo0Nzo1MCswMDowMIxlM90AAAAldEVYdGRhdGU6bW9kaWZ5ADIwMjEtMDctMTJUMTg6NDc6NTArMDA6MDD9OIthAAAAAElFTkSuQmCC",
						ZIndex = Z + 3,
						Parent = Objs.MainColor,
					})

					Objs.Sat2 = Utility:Draw("Image", {
						Size = udim2_new(1, 0, 1, 0),
						Data = crypt.base64.decode("iVBORw0KGgoAAAANSUhEUgAAAaQAAAGkCAQAAADURZm+AAAABGdBTUEAALGPC/xhBQAAACBjSFJNAAB6JQAAgIMAAPn/AACA6QAAdTAAAOpgAAA6mAAAF2+SX8VGAAAAAmJLR0QA/4ePzL8AAAAJcEhZcwAACxMAAAsTAQCanBgAAAAHdElNRQflBwwSLyBEeyyCAAAD4klEQVR42u3YwQnAQAhFQTek/5pz9eBtEYzMlBD4PDcRADDBieMjwK3HJwBDghFepx0oEhgSOO0ARQJDAqcdKBJgSGBI4I0EhgQ47cCQwJDAGwlQJDAkcNqBIgGKBIoEhgROO0CRQJFAkQBDAqcdGBI47QBFAkUCQwKnHaBIoEigSKBIgCKBIYHTDhQJUCQwJHDagSIBigSGBE47UCRAkcCQwGkHKBIoEigSGBLgtANDAkMCbyTAkMBpB4oEigQoEhgSOO1AkQBDAqcdKBIoEqBIYEjgtANFUiRQJFAkMCTAaQeKBIoEigQYEjjtQJFAkQBFAkMCpx0oEmBI4LQDRQJFAhQJDAmcdqBIgCKBIoEhAU47UCRQJFAkwJDAaQeKBIYEOO1AkUCRYHuRTAmcduC0A0UCFAkUCQwJnHaAIoEigSKBIQFOO2gvkimBIoE3EhgS4LQDRQJDAqcdoEigSKBIYEiAIYEhwXx+NoAigSGB0w5QJDAkMCQwJKDiZwMoEhgSOO0ARQJFgnlFMiVw2oHTDhQJUCRQJDAkcNoBVZFMCRQJvJHAkACnHSgSKBIoElANSZPAaQdOOzAkwGkHigSGBIYEGBK08LMBFAkUCRQJMCQwJDAkWMjPBlAkMCRw2gG5SKYEigTeSGBIgNMOFAkMCQwJMCRo4WcDKBIYEjjtgFwkUwJFAm8kMCTAaQeKBIoEigRUQ9IkcNqB0w4MCXDagSKBIsHCIpkSOO3AaQeKBCgSKBIYEhgSYEjQws8GUCQwJHDaAblIpgSKBN5IYEiA0w4UCQwJDAkwJGjhZwMoEhgSOO0ARQJDAkMCQwIqfjaAIoEigSIBhgROO5hXJFMCpx047UCRAEUCRQJDAqcdUBXJlECRwBsJDAlw2oEigSKBIgGGBIYEhgSL+dkAigSGBE47QJHAkMBpB4oEGBIYEhgSrOZnAygSKBIoEmBI4LQDRQJFAhQJDAmcdrC8SKYEigTeSGBIgNMOFAkMCZx2gCKBIoEigSEBTjtQJFAkUCTAkMBpB4oEigQoEhgSOO1AkQBDAqcdKBKgSKBIYEjgtAMUCRQJFAkMCXDagSKBIoEiAYYETjtQJFAkQJHAkMBpB4oEGBI47UCRQJEARQJDAqcdoEigSGBI4LQDFAkUCRQJFAkwJHDagSKBIQFOOzAkMCTwRgIMCZx2oEigSIAigSKBIYHTzkcARQJFAkMCnHZgSGBI4I0EGBI47UCRQJEAQwKnHSgSKBKgSGBI4LQDRQIUCRQJDAmcdoAigSGB0w5QJFAkUCQwJMBpB4oEhgROO0CRwJDAkMAbCVAkMCT4gw/reQYigE05fAAAACV0RVh0ZGF0ZTpjcmVhdGUAMjAyMS0wNy0xMlQxODo0NzozMiswMDowMN2VK3MAAAAldEVYdGRhdGU6bW9kaWZ5ADIwMjEtMDctMTJUMTg6NDc6MzIrMDA6MDCsyJPPAAAAAElFTkSuQmCC"),
						ZIndex = Z + 4,
						Parent = Objs.MainColor,
					})

					Objs.ColorBorder = Utility:Draw("Square", {
						Size = udim2_new(1, 2, 1, 2),
						Position = udim2_new(0, -1, 0, -1),
						Color = Library.CurrentTheme["Border"],
						ZIndex = Z + 1,
						Parent = Objs.MainColor,
					})

					Objs.MainDetector = Utility:Draw("Square", {
						Size = udim2_new(1, 0, 1, 0),
						Transparency = 0,
						ZIndex = Z + 10,
						Parent = Objs.MainColor,
					})

					Objs.Hue = Utility:Draw("Image", {
						Size = udim2_new(0, 175, 0, 10),
						Position = udim2_new(0, 5, 0, 205),
						Data = Library.Images.colorhue,
						ZIndex = Z + 2,
						Parent = Objs.Background,
					})

					Objs.HueBorder = Utility:Draw("Square", {
						Size = udim2_new(1, 2, 1, 2),
						Position = udim2_new(0, -1, 0, -1),
						Color = Library.CurrentTheme["Border"],
						ZIndex = Z + 1,
						Parent = Objs.Hue,
					})

					Objs.HueDetector = Utility:Draw("Square", {
						Size = udim2_new(1, 0, 1, 0),
						Transparency = 0,
						ZIndex = Z + 10,
						Parent = Objs.Hue,
					})

					Objs.TransColor = Utility:Draw("Square", {
						Size = udim2_new(0, 10, 0, 175),
						Position = udim2_new(0, 185, 0, 25),
						Color = color3_new(1, 0, 0),
						ZIndex = Z + 2,
						Parent = Objs.Background,
					})

					Objs.Trans = Utility:Draw("Image", {
						Size = udim2_new(1, 0, 1, 0),
						Data = Library.Images.colortrans,
						ZIndex = Z + 3,
						Parent = Objs.TransColor,
					})

					Objs.TransBorder = Utility:Draw("Square", {
						Size = udim2_new(1, 2, 1, 2),
						Position = udim2_new(0, -1, 0, -1),
						Color = Library.CurrentTheme["Border"],
						ZIndex = Z + 1,
						Parent = Objs.TransColor,
					})

					Objs.TransDetector = Utility:Draw("Square", {
						Size = udim2_new(1, 0, 1, 0),
						Transparency = 0,
						ZIndex = Z + 10,
						Parent = Objs.TransColor,
					})

					Objs.Pointer = Utility:Draw("Square", {
						Size = udim2_new(0, 2, 0, 2),
						Position = udim2_new(0, 0, 0, 0),
						Color = color3_new(1, 1, 1),
						ZIndex = Z + 6,
						Parent = Objs.MainColor,
					})

					Objs.PointerBorder = Utility:Draw("Square", {
						Size = udim2_new(1, 2, 1, 2),
						Position = udim2_new(0, -1, 0, -1),
						Color = color3_new(0, 0, 0),
						ZIndex = Z + 5,
						Parent = Objs.Pointer,
					})

					Objs.HueSlider = Utility:Draw("Square", {
						Size = udim2_new(0, 1, 1, 0),
						Color = color3_new(1, 1, 1),
						ZIndex = Z + 4,
						Parent = Objs.Hue,
					})

					Objs.HueSliderBorder = Utility:Draw("Square", {
						Size = udim2_new(1, 2, 1, 2),
						Position = udim2_new(0, -1, 0, -1),
						Color = color3_new(0, 0, 0),
						ZIndex = Z + 3,
						Parent = Objs.HueSlider,
					})

					Objs.TransSlider = Utility:Draw("Square", {
						Size = udim2_new(1, 0, 0, 1),
						Color = color3_new(1, 1, 1),
						ZIndex = Z + 5,
						Parent = Objs.Trans,
					})

					Objs.TransSliderBorder = Utility:Draw("Square", {
						Size = udim2_new(1, 2, 1, 2),
						Position = udim2_new(0, -1, 0, -1),
						Color = color3_new(0, 0, 0),
						ZIndex = Z + 4,
						Parent = Objs.TransSlider,
					})

					Objs.RBackground = Utility:Draw("Square", {
						Size = udim2_new(0, 60, 0, 15),
						Position = udim2_new(0, 5, 1, -20),
						Color = Library.CurrentTheme["Option Background"],
						ZIndex = Z + 5,
						Parent = Objs.Background,
					})

					Objs.RBorder = Utility:Draw("Square", {
						Size = udim2_new(1, 2, 1, 2),
						Position = udim2_new(0, -1, 0, -1),
						Color = color3_new(0, 0, 0),
						ZIndex = Z + 4,
						Parent = Objs.RBackground,
					})

					Objs.RText = Utility:Draw("Text", {
						Position = udim2_new(0.5, 0, 0, 0),
						Color = color3_new(1, 0.1, 0.1),
						Text = "R",
						Size = 13,
						Font = 2,
						Outline = true,
						Center = true,
						ZIndex = Z + 6,
						Parent = Objs.RBackground,
					})

					Objs.GBackground = Utility:Draw("Square", {
						Size = udim2_new(0, 60, 0, 15),
						Position = udim2_new(0, 70, 1, -20),
						Color = Library.CurrentTheme["Option Background"],
						ZIndex = Z + 5,
						Parent = Objs.Background,
					})

					Objs.GBorder = Utility:Draw("Square", {
						Size = udim2_new(1, 2, 1, 2),
						Position = udim2_new(0, -1, 0, -1),
						Color = color3_new(0, 0, 0),
						ZIndex = Z + 4,
						Parent = Objs.GBackground,
					})

					Objs.GText = Utility:Draw("Text", {
						Position = udim2_new(0.5, 0, 0, 0),
						Color = color3_new(0.1, 1, 0.1),
						Text = "G",
						Size = 13,
						Font = 2,
						Outline = true,
						Center = true,
						ZIndex = Z + 6,
						Parent = Objs.GBackground,
					})

					Objs.BBackground = Utility:Draw("Square", {
						Size = udim2_new(0, 60, 0, 15),
						Position = udim2_new(0, 135, 1, -20),
						Color = Library.CurrentTheme["Option Background"],
						ZIndex = Z + 5,
						Parent = Objs.Background,
					})

					Objs.BBorder = Utility:Draw("Square", {
						Size = udim2_new(1, 2, 1, 2),
						Position = udim2_new(0, -1, 0, -1),
						Color = color3_new(0, 0, 0),
						ZIndex = Z + 4,
						Parent = Objs.BBackground,
					})

					Objs.BText = Utility:Draw("Text", {
						Position = udim2_new(0.5, 0, 0, 0),
						Color = color3_new(0.1, 0.1, 1),
						Text = "B",
						Size = 13,
						Font = 2,
						Outline = true,
						Center = true,
						ZIndex = Z + 6,
						Parent = Objs.BBackground,
					})



					local DraggingHue: boolean = false
					local DraggingSat: boolean = false
					local DraggingTrans: boolean = false

					local function UpdateSatVal(Pos: Vector2): ()
						if Window.ColorPicker.Selected ~= nil then
							local Hue: number, Sat: number, Val: number =
								Window.ColorPicker.Selected.Color:ToHSV()

							local XSize: number =
								(Objs.MainColor.Object.Position.X + Objs.MainColor.Object.Size.X)
							- Objs.MainColor.Object.Position.X

							local YSize: number =
								(Objs.MainColor.Object.Position.Y + Objs.MainColor.Object.Size.Y)
							- Objs.MainColor.Object.Position.Y

							local X: number = math.clamp(
								(Pos.X - Objs.MainColor.Object.Position.X) / XSize,
								0,
								0.995
							)

							local Y: number = math.clamp(
								(Pos.Y - Objs.MainColor.Object.Position.Y) / YSize,
								0,
								0.995
							)

							Sat = 1 - X
							Val = 1 - Y

							local NewColor: Color3 = color3_fromHSV(Hue, Sat, Val)
							Window.ColorPicker.Selected:SetColor(NewColor)
							Window.ColorPicker:Visualize(NewColor, Window.ColorPicker.Selected.Trans)
						end
					end

					local function UpdateHue(Pos: Vector2): ()
						if Window.ColorPicker.Selected ~= nil then
							local Hue: number, Sat: number, Val: number =
								Window.ColorPicker.Selected.Color:ToHSV()

							local XSize: number =
								(Objs.Hue.Object.Position.X + Objs.Hue.Object.Size.X)
							- Objs.Hue.Object.Position.X

							local X: number = math.clamp(
								(Pos.X - Objs.Hue.Object.Position.X) / XSize,
								0,
								0.995
							)

							Hue = 1 - X

							local NewColor: Color3 = color3_fromHSV(Hue, Sat, Val)
							Window.ColorPicker.Selected:SetColor(NewColor)
							Window.ColorPicker:Visualize(NewColor, Window.ColorPicker.Selected.Trans)
						end
					end

					local function UpdateTrans(Pos: Vector2): ()
						if Window.ColorPicker.Selected ~= nil then
							local YSize: number =
								(Objs.Trans.Object.Position.Y + Objs.Trans.Object.Size.Y)
							- Objs.Trans.Object.Position.Y

							local Y: number = math.clamp(
								(Pos.Y - Objs.TransColor.Object.Position.Y) / YSize,
								0,
								0.995
							)

							Window.ColorPicker.Selected:SetTrans(Y)
							Window.ColorPicker:Visualize(Window.ColorPicker.Selected.Color, Y)
						end
					end



					Utility:Connection(Objs.MainDetector.MouseButton1Down, function(Pos: Vector2)
						DraggingSat = true
						UpdateSatVal(Pos)
					end)

					Utility:Connection(Objs.HueDetector.MouseButton1Down, function(Pos: Vector2)
						DraggingHue = true
						UpdateHue(Pos)
					end)

					Utility:Connection(Objs.TransDetector.MouseButton1Down, function(Pos: Vector2)
						DraggingTrans = true
						UpdateTrans(Pos)
					end)

					Utility:Connection(MouseMove, function(Pos: Vector2)
						if not Library.Open then return end
						if DraggingSat then
							UpdateSatVal(Pos)
						elseif DraggingHue then
							UpdateHue(Pos)
						elseif DraggingTrans then
							UpdateTrans(Pos)
						end
					end)

					Utility:Connection(Button1Up, function()
						DraggingSat = false
						DraggingHue = false
						DraggingTrans = false
					end)
				end

				function Window.ColorPicker:Visualize(Color: Color3, Alpha: number)
					if typeof(Color) ~= "Color3" or typeof(Alpha) ~= "number" then return end

					local H, S, V = Color:ToHSV()
					local R, G, B = Color.R, Color.G, Color.B

					if H == 0 then H = 1 end

					self.Color = Color
					self.Trans = Alpha

					local Objs = self.Objects
					Objs.MainColor.Color = color3_fromHSV(H, 1, 1)
					Objs.TransColor.Color = color3_fromHSV(H, S, V)
					Objs.HueSlider.Position = udim2_new(1 - H, 0, 0, 0)
					Objs.TransSlider.Position = udim2_new(0, 0, Alpha, 0)
					Objs.Pointer.Position = udim2_new(1 - S, 0, 1 - V, 0)
					
					Objs.RText.Text = tostring(math_floor(R * 255))
					Objs.GText.Text = tostring(math_floor(G * 255))
					Objs.BText.Text = tostring(math_floor(B * 255))
					
					local Text = "Editing : Unknown"
					local Selected = self.Selected
					if Selected then
						Text = Selected.Text ~= "" and tostring(Selected.Text)
							or Selected.Flag ~= "" and tostring(Selected.Flag)
							or Text
					end

					Objs.StatusText.Text = Text
				end

				Window.ColorPicker:Visualize(Window.ColorPicker.Color, Window.ColorPicker.Trans)
			end


			--// dropdown impl
			do
				do
					local Objs = Window.Dropdown.Objects;
					local Z = Library.Order.Dropdown;

					Objs.Background = Utility:Draw('Square', {
						Visible = false;
						Size = udim2_new(1, -3, 0, 50);
						Position = udim2_new(0, 3, 1, 0);
						Color = Library.CurrentTheme["Background"];
						ZIndex = Z;
						Parent = Window.Objects.Background;
					})

					Objs.Border1 = Utility:Draw('Square', {
						Size = udim2_new(1, 2, 1, 2);
						Position = udim2_new(0, -1, 0, -1);
						Color = Library.CurrentTheme["Border"];
						ZIndex = Z - 1;
						Parent = Objs.Background;
					})

					Objs.Border2 = Utility:Draw('Square', {
						Size = udim2_new(1, 2, 1, 2);
						Position = udim2_new(0, -1, 0, -1);
						Color = Library.CurrentTheme["Border 1"];
						ZIndex = Z - 2;
						Parent = Objs.Border1;
					})

					Objs.Border3 = Utility:Draw('Square', {
						Size = udim2_new(1, 2, 1, 2);
						Position = udim2_new(0, -1, 0, -1);
						Color = Library.CurrentTheme["Border"];
						ZIndex = Z - 3;
						Parent = Objs.Border2;
					})
				end

				function Window.Dropdown:Refresh(): ()
					if self.Selected ~= nil then
						local List = self.Selected

						for Idx, Value in List.Values do
							local ValueObject = self.Objects.Values[Idx]

							if ValueObject == nil then
								ValueObject = {};

								ValueObject.Background = Utility:Draw('Square', {
									Size = udim2_new(1, -4, 0, 18);
									Color = Library.CurrentTheme['Group Background'] ; --color3_new(.25, .25, .25);
									Transparency = 0;
									ZIndex = Library.Order.Dropdown + 1;
									Parent = self.Objects.Background;
								})

								ValueObject.Text = Utility:Draw('Text', {
									Position = udim2_new(0, 3, 0, 1);
									Color = Library.CurrentTheme["Option Text 2"];
									Text = tostring(Value);
									Size = 13;
									Font = 2;
									ZIndex = Library.Order.Dropdown + 2;
									Parent = ValueObject.Background;
									Outline = true
								})

								ValueObject.Connection = Utility:Connection(
									ValueObject.Background.MouseButton1Down,
									function()
										local CurrentList = self.Selected
										if CurrentList then
											local Val = CurrentList.Values[Idx]
											local CurrentSelected = CurrentList.Selected
											local NewSelected = CurrentList.Multi and {} or Val

											if CurrentList.Multi then
												for i, v in CurrentSelected do
													if v == "None" then continue end
													NewSelected[i] = v
												end

												if table_find(NewSelected, Val) then
													table_remove(NewSelected, table_find(NewSelected, Val))
												else
													table_insert(NewSelected, Val)
												end
											end

											CurrentList:Select(NewSelected)

											if not CurrentList.Multi then
												CurrentList.Open = false
												CurrentList.Objects.OpenText.Text = '+'
												Window.Dropdown.Selected = nil
												Window.Dropdown.Objects.Background.Visible = false
											end

											for i, v in CurrentList.Values do
												local ValueObj = self.Objects.Values[i]
												if ValueObj then
													ValueObj.Background.Transparency =
														(typeof(NewSelected) == 'table' and table_find(NewSelected, v) or NewSelected == v)
														and 1 or 0
													ValueObj.Text.Color =
														(typeof(List.Selected) == 'table' and table_find(List.Selected, Val) or List.Selected == Val)
														and Library.CurrentTheme.Accent or Library.CurrentTheme["Option Text 2"];
												end
											end
										end
									end
								)

								self.Objects.Values[Idx] = ValueObject
							end
						end

						for Idx, Val in List.Values do
							local ValueObj = self.Objects.Values[Idx]
							if ValueObj then
								ValueObj.Background.Transparency =
									(typeof(List.Selected) == 'table' and table_find(List.Selected, Val) or List.Selected == Val)
									and 1 or 0
								ValueObj.Text.Color =
									(typeof(List.Selected) == 'table' and table_find(List.Selected, Val) or List.Selected == Val)
									and Library.CurrentTheme.Accent or Library.CurrentTheme["Option Text 2"];
							end
						end

						local Y, Padding = 2, 2
						for Idx, Obj in self.Objects.Values do
							local ValueStr = List.Values[Idx]
							Obj.Background.Visible = ValueStr ~= nil

							if ValueStr ~= nil then
								Obj.Background.Position = udim2_new(0, 2, 0, Y)
								Obj.Text.Text = ValueStr
								Y = Y + Obj.Background.Object.Size.Y + Padding
							end
						end

						self.Objects.Background.Size = udim2_new(1, -6, 0, Y)
					end
				end

				Window.Dropdown:Refresh()
			end

			self.Watermark = {
				Objects = {} :: { },

				Text = {
					{ "nocturnal", true },

					{
						string_format(
							"%s (uid %s)",
							"newguy",
							tostring(1)
						),
						true
					},

					{ "Rivals", true },

					{ "0 fps", true },

					{ "0ms", true },

					{ "00:00:00", true },

					{ "M, D, Y", true },
				},

				Lock = "Top Right",
				Position = udim2_new(0, 0, 0, 0),
				RefreshRate = 25,
			}

			--// Update Function
			function self.Watermark:Update(): ()
				local WatermarkEnabled: boolean = true
				local Objects = self.Objects

				Objects.Background.Visible = WatermarkEnabled
				if not WatermarkEnabled then
					return
				end

				local DateTable = os.date("*t")

				local Month: string = os.date("%b", os.time(DateTable))
				local DayNum: number = DateTable.day
				local Year: string = tostring(DateTable.year)

				local DaySuffix: string =
					(DayNum % 10 == 1 and "st")
					or (DayNum % 10 == 2 and "nd")
					or (DayNum % 10 == 3 and "rd")
					or "th"

				self.Text[4][1] = tostring(Library.Stats.FPS) .. " fps"
				self.Text[5][1] = tostring(math_floor(Library.Stats.Ping)) .. "ms"
				self.Text[6][1] = os_date("%X", os_time())
				self.Text[7][1] = table_concat({ Month, tostring(DayNum) .. DaySuffix, Year }, ", ")

				local Output: { string } = table_create(#self.Text)
				for _, Entry in self.Text do
					if Entry[2] then
						table_insert(Output, Entry[1])
					end
				end

				local FinalText: string = table_concat(Output, " / ")
				Objects.Text.Text = FinalText

				--// Resize background
				local TextBoundsX: number = Objects.Text.TextBounds.X
				Objects.Background.Size = udim2_new(0, TextBoundsX + 15, 0, 17)

				--// Positioning
				local BackgroundSize: Vector2 = Objects.Background.Object.Size
				local ScreenSize: Vector2 = Workspace.CurrentCamera.ViewportSize

				self.Position =
					(self.Lock == "Top Right" and udim2_new(0, ScreenSize.X - BackgroundSize.X - 15, 0, 15))
					or (self.Lock == "Top Left" and udim2_new(0, 15, 0, 15))
					or (self.Lock == "Bottom Right" and udim2_new(0, ScreenSize.X - BackgroundSize.X - 15, 0, ScreenSize.Y - BackgroundSize.Y - 15))
					or (self.Lock == "Bottom Left" and udim2_new(0, 15, 0, ScreenSize.Y - BackgroundSize.Y - 15))
					or (self.Lock == "Top" and udim2_new(0, ScreenSize.X / 2 - BackgroundSize.X / 2, 0, 15))
					or udim2_new(
						(((tick() / 100) * math_pi) % 360) ^ 0.0084,
						0,
						(((tick() / 100) * math_pi) % 360) ^ 0.0034,
						0
					)

				Objects.Background.Position = self.Position
			end

			--// Drawing watermark
			do
				local Objects: any = self.Watermark.Objects
				local ZIndex: number = self.Order.Watermark

				Objects.Background = Utility:Draw("Square", {
					Visible = true,
					Size = udim2_new(0, 200, 0, 17),
					Position = udim2_new(0, 800, 0, 100),
					Color = Library.CurrentTheme["Background"],
					ZIndex = ZIndex,
				})

				Objects.Border1 = Utility:Draw("Square", {
					Size = udim2_new(1, 2, 1, 2),
					Position = udim2_new(0, -1, 0, -1),
					Color = Library.CurrentTheme["Border 2"],
					Parent = Objects.Background,
					ZIndex = ZIndex - 1,
				})

				Objects.Border2 = Utility:Draw("Square", {
					Size = udim2_new(1, 2, 1, 2),
					Position = udim2_new(0, -1, 0, -1),
					Color = Library.CurrentTheme["Border 3"],
					Parent = Objects.Border1,
					ZIndex = ZIndex - 2,
				})

				Objects.TopBar = Utility:Draw("Square", {
					Size = udim2_new(1, 0, 0, 1),
					Color = Library.CurrentTheme["Accent"],
					ZIndex = ZIndex + 1,
					Parent = Objects.Background,
				})

				Objects.Text = Utility:Draw("Text", {
					Position = udim2_new(0.5, 0, 0, 2),
					Color = Library.CurrentTheme["Primary Text"],
					Text = "Watermark Text",
					Size = 13,
					Font = 2,
					ZIndex = ZIndex + 1,
					Outline = true,
					Center = true,
					Parent = Objects.Background,
				})
			end

			--// Stats impl
			local LastTick: number = tick()

			Utility:Connection(run_service.RenderStepped, function(Step: number): ()
				Library.Stats.FPS = math_floor(1 / Step)
				Library.Stats.Ping = math_floor(player_local:GetNetworkPing() * 1000)

				local Now: number = tick()
				if (Now - LastTick) * 1000 > Library.Watermark.RefreshRate then
					LastTick = Now
					Library.Watermark:Update();
				end
			end)



			Window.Dropdown:Refresh();
			self:SetOpen(true)

			Library.KeyIndicator = self.NewIndicator({title = 'Keybinds', pos = udim2_new(0,15,0,325), enabled = false});
			Library.KeyIndicator:SetEnabled(true);



			return Window;
		end;

		do
			local Z: number = Library.Order.Window + 2000

			TooltipObjects.Background = utility:Draw('Square', {
				Color = Library.CurrentTheme["Group Background"];
				ZIndex = Z;
				Visible = false;
			})

			TooltipObjects.Border1 = utility:Draw('Square', {
				Size = udim2_new(1, 2, 1, 2);
				Position = udim2_new(0, -1, 0, -1);
				Color = Library.CurrentTheme["Border 1"];
				ZIndex = Z - 1;
				Parent = TooltipObjects.Background;
			})

			TooltipObjects.Border2 = utility:Draw('Square', {
				Size = udim2_new(1, 4, 1, 4);
				Position = udim2_new(0, -2, 0, -2);
				Color = Library.CurrentTheme["Border 3"];
				ZIndex = Z - 2;
				Parent = TooltipObjects.Background;
			})

			TooltipObjects.Text = utility:Draw('Text', {
				Position = udim2_new(0, 3, 0, 0);
				Color = Library.CurrentTheme["Primary Text"];
				Size = 13;
				Font = 2;
				ZIndex = Z + 1;
				Outline = true;
				Parent = TooltipObjects.Background;
			})

			TooltipObjects.RiskyText = utility:Draw('Text', {
				Position = udim2_new(0, 3, 0, 0);
				Color = Library.CurrentTheme["Risky Text Enabled"];
				Text = '[RISKY]';
				Size = 13;
				Font = 2;
				ZIndex = Z + 1;
				Outline = true;
				Parent = TooltipObjects.Background;
			})

		end

		Library.State.Stage = "Complete"
	end;
	
	function Library:CreateSettings(Menu: any): any
		local SettingsTab: any = Menu:Tab("Settings", 999);
		local ConfigSection: any = SettingsTab:Section("Config", 2);
		local MainSection: any = SettingsTab:Section("Interface", 1);
		local CheatName: string = Library.ScriptData[1][1];
		local Game: string = Library.ScriptData[1][2];

		ConfigSection:Textbox({ Text = "Config Name", Flag = "ConfigInput" });
		ConfigSection:Dropdown({ Text = "Config", Flag = "SelectedConfig" });

		local function RefreshConfigs(): ()
			Library.Options.SelectedConfig:ClearValues()
			
			if run_service:IsStudio() then return end;

			local ConfigPath: string = CheatName .. "/" .. Game .. "/configs"

			for _, FileName: string in listfiles(ConfigPath) do
				local Split: { string } = FileName:split(".")
				local Ext: string = "." .. Split[#Split]

				if Ext == ".json" then
					local PathSplit: { string } = FileName:split("\\");
					local CleanName: string = PathSplit[#PathSplit]:sub(1, -#Ext - 1);
					Library.Options.SelectedConfig:AddValue(CleanName);
				end;
			end;
		end;

		ConfigSection
			:Button({
				Text = "Load",
				Confirm = true,
				Callback = function(): ()
					Library:LoadConfig(Library.Flags.SelectedConfig)
				end,
			})
		ConfigSection:Button({
				Text = "Save",
				Confirm = true,
				Callback = function(): ()
					Library:SaveConfig(Library.Flags.SelectedConfig)
				end,
			})

		ConfigSection
			:Button({
				Text = "Create",
				Confirm = true,
				Callback = function(): ()
					local Name: string = Library.Flags.ConfigInput
					if Library:GetConfig(Name) then
						Library:SendNotification(
							"Config '" .. Name .. "' already exists.",
							5,
							color3_new(1, 0, 0)
						)
						return
					end

					writefile(
						CheatName
						.. "/"
						.. Game
						.. "/configs/"
						.. Name
						.. ".json",
						http_service:JSONEncode({ })
					)

					RefreshConfigs()
				end,
			})
		ConfigSection:Button({
				Text = "Delete",
				Confirm = true,
				Callback = function(): ()
					local Name: string = Library.Flags.SelectedConfig
					if Library:GetConfig(Name) then
						delfile(
							CheatName
							.. "/"
							.. Game
							.. "/configs/"
							.. Name
							.. ".json"
						)
						RefreshConfigs()
					end
				end,
			});

		RefreshConfigs();

		MainSection:Toggle({
			Text = "Indicators",
			Flag = "KeybindIndicator",
			Callback = function(Value: boolean): ()
				Library.KeyIndicator:SetEnabled(Value)
			end,
		});


		MainSection:Toggle({ Text = "Watermark", Flag = "WatermarkEnabled" })

		MainSection:Dropdown({
			Text = "Position",
			Flag = "WatermarkPos",
			Selected = "Top",
			Values = {
				"Top",
				"Top Left",
				"Top Right",
				"Bottom Left",
				"Bottom Right",
			},
			Callback = function(Value: string): ()
				Library.Watermark.Lock = Value
			end,
		})
		
		MainSection:Button({
			Text = "Unload",
			Confirm = true,
			Callback = function(): ()
				Library:Unload()
			end,
		});


		
		local SetByPreset: boolean = false

		return SettingsTab
	end

end;

environment().Nocturnal = Library;

return Library;
