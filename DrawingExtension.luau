--// Services
local Services: { [string]: any } = setmetatable({ }, {
	__index = function(Self: any, Index: string): any
		return cloneref(game.GetService(game, Index));
	end
});

local Environment: any =
	(getgenv and function(): any
		return getgenv()
	end)
	or function(): { [string]: any }
		return {}
	end;

local MakeFolder: (Path: string) -> () = makefolder or function(_: string): () end;
local IsFolder: (Path: string) -> boolean = isfolder or function(_: string): boolean return false end;
local IsFile: (Path: string) -> boolean = isfile or function(_: string): boolean return false end;
local WriteFile: (Path: string, Contents: string) -> () = writefile or function(_: string, _: string): () end;
local ReadFile: (Path: string) -> string = readfile or function(_: string): string return "" end;
local GetConnections: (Event: any) -> () = getconnections or function(...) return { } end;
local GetUpvalue: (Upvalue: any) -> () = debug.getupvalue or function(...) end;
local LoadFile: (Path: string) -> () = loadfile or function(_: string): () end;
local HookFn: (any) -> () = hookfunction or function(_: any): () end;

local Request: ((Options: any) -> any)? =
	(syn and syn.request)
	or (http and http.request)
	or request;

local GetCustomAsset: (Path: string) -> string =
	getcustomasset or function(_: string): string return "" end;

--// math
local Floor: (number) -> number = math.floor;
local Ceil: (number) -> number = math.ceil;
local Abs: (number) -> number = math.abs;
local Sign: (number) -> number =
	math.sign or function(X: number): number
		if X > 0 then
			return 1
		elseif X < 0 then
			return -1
		else
			return 0
		end
	end;

local Max: (...number) -> number = math.max;
local Min: (...number) -> number = math.min;
local Sqrt: (number) -> number = math.sqrt;
local Pow: (number, number) -> number = math.pow;
local Exp: (number) -> number = math.exp;
local Log: (number, number?) -> number = math.log;

local Log10: (number) -> number =
	math.log10 or function(X: number): number
		return Log(X, 10)
	end;

local Sin: (number) -> number = math.sin;
local Cos: (number) -> number = math.cos;
local Tan: (number) -> number = math.tan;
local Asin: (number) -> number = math.asin;
local Acos: (number) -> number = math.acos;
local Atan: (number) -> number = math.atan;
local Atan2: (number, number) -> number = math.atan2;
local Pi: number = math.pi;
local Huge: number = math.huge;
local Random: (number?, number?) -> number = math.random;
local RandomSeed: (number) -> () = math.randomseed or function(_: number): () end;
local Rad: (number) -> number = math.rad;
local Deg: (number) -> number = math.deg;

local Clamp: (number, number, number) -> number =
	function(Value: number, Min: number, Max: number): number
		return (Value < Min and Min) or (Value > Max and Max) or Value
	end;

local Lerp: (number, number, number) -> number =
	math.lerp or function(A: number, B: number, T: number): number
		return A + (B - A) * T
	end;

local Round: (number) -> number =
	math.round or function(X: number): number
		return Floor(X + 0.5)
	end;

local MathIsFinite: (number) -> boolean =
	(math.type and function(X: number): boolean
		return math.type(X) == "number" and X == X and X ~= Huge and X ~= -Huge
	end)
	or function(_: number): boolean
		return true
	end;

--// table
local Insert: <T>(Tbl: { T }, Value: T) -> () = table.insert;
local Remove: <T>(Tbl: { T }, Index: number?) -> T? = table.remove;
local Concat: (Tbl: { string }, Sep: string?, I: number?, J: number?) -> string = table.concat;
local Sort: <T>(Tbl: { T }, Comp: ((T, T) -> boolean)?) -> () = table.sort;

local TFind: <T>(Tbl: { T }, Value: T) -> number? =
	table.find or function<T>(T: { T }, V: T): number?
		for I = 1, #T do
			if T[I] == V then
				return I
			end
		end
		return nil
	end;

local Clear: (Tbl: { [any]: any }) -> () =
	table.clear or function(T: { [any]: any }): ()
		for K in T do
			T[K] = nil
		end;
	end;

local Clone: <T>(Tbl: T) -> T =
	table.clone or function<T>(T: T): T
		local N: any = {}
		for K, V in T do
			N[K] = V
		end
		return N
	end;

local Move: (Src: { any }, F: number, L: number, Idx: number, Dst: { any }) -> { any } =
	table.move or function(Src: { any }, F: number, L: number, Idx: number, Dst: { any }): { any }
		for I = F, L do
			Dst[Idx + I - F] = Src[I]
		end
		return Dst
	end;

local Pack: (...any) -> { n: number, [number]: any } =
	table.pack or function(...: any): { n: number, [number]: any }
		return { n = select("#", ...), ... }
	end;

local Freeze: <T>(Tbl: T) -> T =
	table.freeze or function<T>(_: T): T
		return {} :: any
	end;

local Unpack: <T>(Tbl: { T }, I: number?, J: number?) -> ...T = table.unpack or unpack;
local Create: (number, any?) -> { any } = table.create;

--// string
local Byte: (string, number?, number?) -> ...number = string.byte;
local Char: (...number) -> string = string.char;
local Sub: (string, number, number?) -> string = string.sub;
local Len: (string) -> number = string.len;
local Lower: (string) -> string = string.lower;
local Upper: (string) -> string = string.upper;
local Find: (string, string, number?, boolean?) -> (number?, number?, ...string) = string.find;
local GSub: (string, string, string | ((...any) -> string), number?) -> (string, number) = string.gsub;
local Gmatch: (string, string) -> (() -> string?) = string.gmatch;
local Match: (string, string, number?) -> string? = string.match;
local Rep: (string, number, string?) -> string = string.rep;
local Reverse: (string) -> string = string.reverse;

local Split: (string, string) -> { string } =
	string.split or function(S: string, Sep: string): { string }
		local Out: { string } = {}
		for Part in S:gmatch("([^" .. Sep .. "]+)") do
			Insert(Out, Part)
		end

		return Out;
	end;

local Format: (string, ...any) -> string = string.format;
local Trim: (string) -> string =
	string.trim or function(S: string): string
		return S:match("^%s*(.-)%s*$") or ""
	end;

--// os / task
local Time: () -> number = os.time;
local Clock: () -> number = os.clock;
local Date: (string?, number?) -> any = os.date;
local DiffTime: (number, number) -> number = os.difftime;

local Tick: () -> number = tick or OsTime;
local Time: () -> number = time;

local Wait: (number?) -> number = (task and task.wait) or wait;
local Spawn: (thread | (() -> ()), ...any) -> () = (task and task.spawn) or spawn;
local Defer: ((...any) -> (), ...any) -> () =
	(task and task.defer)
	or function(F: (...any) -> (), ...: any): ()
		local Co = coroutine.create(F)
		coroutine.resume(Co, ...)
	end;

local Delay: (number, (...any) -> (), ...any) -> () = (task and task.delay) or delay;
local Cancel: (thread) -> () = (task and task.cancel) or function(_: thread): () end;

--// bit
local BitBand: (number, number) -> number =
	(bit32 and bit32.band)
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
	end;

local BitBor: (number, number) -> number =
	(bit32 and bit32.bor)
	or function(A: number, B: number): number
		local R = 0;
		local Bit = 1;
		for _ = 0, 31 do
			local AA = A % 2;
			local BB = B % 2;
			if AA == 1 or BB == 1 then
				R += Bit;
			end;
			A = Floor(A / 2);
			B = Floor(B / 2);
			Bit *= 2;
		end
		return R
	end;

local BitXor: (number, number) -> number =
	(bit32 and bit32.bxor)
	or function(A: number, B: number): number
		return (A + B) - 2 * (A ^ B)
	end;

local BitLshift: (number, number) -> number =
	(bit32 and bit32.lshift) or function(A: number, N: number): number
		return A * (2 ^ N)
	end;

local BitRshift: (number, number) -> number =
	(bit32 and bit32.rshift) or function(A: number, N: number): number
		return Floor(A / (2 ^ N))
	end;

local BitNot: (number) -> number =
	(bit32 and bit32.bnot) or function(A: number): number
		return 2 ^ A
	end;

local function Switch<T>(Value: T, Cases: { [T]: (() -> ()) }, Default: (() -> ())?)
    local CaseFn: (() -> ())? = Cases[Value]

    if CaseFn then
        CaseFn();
    elseif Default then
        Default();
    end;
end;

local function Pairs<K, V>(tbl: { [K]: V }): (()->(K, V)?) 
    local nextIndex = nil;

    return function()
        nextIndex, value = next(tbl, nextIndex);
        return nextIndex, value;
    end;
end;


--// roblox
local Vec2: (number, number) -> Vector2 = Vector2.new;
local Vec3: (number, number, number) -> Vector3 = vector.create;
local VecEmpty: (number, number, number) -> Vector3 = vector.zero;
local UDim2New: (number, number, number, number) -> UDim2 = UDim2.new;
local UDimNew: (number, number) -> UDim = UDim.new;
local InstanceNew: (string) -> Instance = Instance.new;
local NewColor: (number, number, number) -> Color3 = Color3.new;
local FromRGB: (number, number, number) -> Color3 = Color3.fromRGB;
local FromHSV: (number, number, number, number) -> Color3 = Color3.fromHSV;
local CFrameNew: (...any) -> CFrame = CFrame.new;
local CFrameAngles: (...any) -> CFrame = CFrame.Angles;
local CFrameLookAt: (...any) -> CFrame = CFrame.lookAt;



local ColorSequenceNew: (any) -> ColorSequence = ColorSequence.new;
local ColorSequenceKeypointNew: (number, Color3) -> ColorSequenceKeypoint = ColorSequenceKeypoint.new;
local NumberSequenceNew: (any) -> NumberSequence = NumberSequence.new;
local NumberSequenceKeypointNew: (number, number, number?) -> NumberSequenceKeypoint =
	NumberSequenceKeypoint.new;

--// services
local ContextActionService: ContextActionService = Services.ContextActionService;
local ReplicatedStorage: ReplicatedStorage = Services.ReplicatedStorage;
local InputService: UserInputService = Services.UserInputService;
local ScriptContext: ScriptContext = Services.ScriptContext;
local TweenService: TweenService = Services.TweenService;
local HttpService: HttpService = Services.HttpService;
local RunService: RunService = Services.RunService;
local LogService: LogService = Services.LogService;
local PlayerService: Players = Services.Players;
local Lighting: Lighting = Services.Lighting;

local GetMouseLocation = InputService.GetMouseLocation;
local LocalPlayer: Player? = PlayerService.LocalPlayer;
local Camera: Instance? = workspace.CurrentCamera;
local Mouse: Mouse? = LocalPlayer:GetMouse();

local ScreenPointToRay: () -> () = Camera.ScreenPointToRay;
local Draw: () -> () = Drawing.new;


local BlacklistedProperties: { string } = { "Object", "Children", "Class" }
local Extension: { } = { };
local ScrollState: {
    [any]: {
        Offset: number,
        Padding: number,
        Children: { any },
        ContentSize: number
    }
} = { };

--// Declarations
Extension.Drawings = { };
Extension.Connections = { };
Extension.RenderId = 0

--// Types
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

local Signal = { };
Signal.__index = Signal;

--// Signal implementation
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

--// Drawing extension
do
	function Extension:Connection(SignalParam: RBXScriptConnection, Func: (...any) -> ()): RBXScriptConnection
		local Conn = SignalParam:Connect(Func);
		Insert(Extension.Connections, Conn);

		return Conn;
	end;

    function Extension:MouseOver(Object: any): boolean
        local Mouse: Vector2 = GetMouseLocation(InputService);
        local Pos, Size: Vector2 = Object.Position, Object.Size;
        local MX, MY, X1, Y1, X2, Y2: number = Mouse.X, Mouse.Y, Pos.X, Pos.Y, Pos.X + Size.X, Pos.Y + Size.Y;

        return MX >= X1 and MX <= X2 and MY >= Y1 and MY <= Y2;
    end;

    function Extension:HasProperty(Obj: Instance, Prop: string): boolean
		local Success: boolean = (pcall(function() local _ = Obj[Prop] end))

		return Success;
	end;

	function Extension:ToRGB(C3: Color3): (number, number, number)
		return C3.R * 255, C3.G * 255, C3.B * 255;
	end;

	function Extension:AddRGB(A: Color3, B: Color3): Color3
		local R1, G1, B1 = self:ToRGB(A)
		local R2, G2, B2 = self:ToRGB(B)

		return FromRGB(
			Clamp(R1 + R2, 0, 255),
			Clamp(G1 + G2, 0, 255),
			Clamp(B1 + B2, 0, 255)
		);
	end;

	function Extension:ConvertNumberRange(Val: number, OldMin: number, OldMax: number, NewMin: number, NewMax: number): number
		return ((Val - OldMin) * (NewMax - NewMin)) / (OldMax - OldMin) + NewMin;
	end;

	function Extension:UDim2ToVector2(Value: any, ParentSize: Vector2): Vector2
        if typeof(Value) == "Vector2" then
            return Value;
        end;

        assert(typeof(Value) == "UDim2", "UDim2ToVector2 expects UDim2 or Vector2");

        local X = Value.X.Offset + self:ConvertNumberRange(Value.X.Scale, 0, 1, 0, ParentSize.X);
        local Y = Value.Y.Offset + self:ConvertNumberRange(Value.Y.Scale, 0, 1, 0, ParentSize.Y);

        return Vec2(X, Y);
    end;

	function Extension:GetHoverObject(): any?
		local Drawings: any = Extension.Drawings;
		local TopObject: any? = nil;
		local MaxZIndex: number = -Huge;

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

	function Extension:DetectTableChange(
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

	function Extension:Draw(Class: string, Properties: { [string]: any }?): any
		local DrawingObj: DrawingObject = {
			Object = Draw(Class),
			Children = {},
			ThemeColor = "",
			OutlineThemeColor = "",
			ThemeColorOffset = 0,
			OutlineThemeColorOffset = 0,
			Parent = nil,
			Size = UDim2New(0,0,0,0),
			Position = UDim2New(0,0,0,0),
			AbsoluteSize = Vec2(0,0),
			AbsolutePosition = Vec2(0,0),
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
			local Parent: DrawingObject? = self.Parent and Extension.Drawings[self.Parent.Object] or nil;
			local ParentSize, ParentPos, ParentVis: Vector2, Vector2, boolean = workspace.CurrentCamera.ViewportSize, Vec2(0,0), true;

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
				self.Object.Size = typeof(self.Size) == "Vector2" and self.Size or Extension:UDim2ToVector2(self.Size, ParentSize);
			end;

			if IsRenderable then
				self.Object.Position = ParentPos + (typeof(self.Position) == "Vector2" and self.Position or Extension:UDim2ToVector2(self.Position, ParentSize));
			end;

			self.Object.Visible = ParentVis and self.Visible;

			self:UpdateChildren();
		end;

		function DrawingObj:GetDescendants(): { DrawingObject }
			local Descendants: { DrawingObject } = {};

			local function AddChildren(T: DrawingObject)
				for _, V in T.Children do
					Insert(Descendants, V);
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

			Extension.Drawings[self.Object] = nil;
			self.Object:Remove();
			
			pcall(function()
				Clear(self);
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
				if not TFind(BlacklistedProperties, Key) then
					local LastVal = DrawingObj[Key];

					if Key == "Size" and (Class == "Square" or Class == "Image") then
						DrawingObj.Object.Size = Extension:UDim2ToVector2(Value, DrawingObj.Parent and DrawingObj.Parent.Object.Size or workspace.CurrentCamera.ViewportSize);
						DrawingObj.AbsoluteSize = DrawingObj.Object.Size;
					elseif Key == "Position" and (Class == "Square" or Class == "Image" or Class == "Text") then
						DrawingObj.Object.Position = Extension:UDim2ToVector2(Value, DrawingObj.Parent and DrawingObj.Parent.Object.Position or Vec2(0,0));
						DrawingObj.AbsolutePosition = DrawingObj.Object.Position;
					elseif Key == "Parent" then
						if DrawingObj.Parent then
							DrawingObj.Parent.Children[DrawingObj.Object] = nil;
						end;
						if Value then
							Insert(Value.Children, DrawingObj);
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
				end;
			end
		);

		for Key, Value in Properties do
			Proxy[Key] = Value;
		end;

		Extension.Drawings[DrawingObj.Object] = DrawingObj;
		DrawingObj:Update();

		return Proxy;
	end;

	function Extension:Lerp(A: number, B: number, T: number): number
		return A + (B - A) * T;
	end;

	function Extension:Tween(InstanceObj: any, InstanceTo: { [string]: number }, InstanceTime: number): ()
		local CurrentTime: number = 0;
		local CurrentIndex: { [string]: number } = { };
		local Connection: RBXScriptConnection?;

		for Property, Value in InstanceTo do
			CurrentIndex[Property] = InstanceObj[Property];
		end

		local function Interpolate(): ()
			for Property, TargetValue in InstanceTo do
				local StartValue = CurrentIndex[Property] or 0;
				InstanceObj[Property] = ((TargetValue - StartValue) * CurrentTime / InstanceTime) + StartValue;
			end
		end

		Connection = RunService.RenderStepped:Connect(function(Delta: number): ()
			if CurrentTime < InstanceTime then
				CurrentTime = CurrentTime + Delta;
				Interpolate();
			else
				Connection:Disconnect();
			end
		end);
	end;

	local Black: Color3 = NewColor();

	function Extension:RgbToLuv13(c: Color3): (number, number, number)
		local r, g, b = c.r, c.g, c.b;

		local function InverseGamma(x: number): number
			if x < 0.0404482362771076 then
				return x / 12.92;
			else
				return 0.87941546140213 * (x + 0.055) ^ 2.4;
			end;
		end;

		r = InverseGamma(r);
		g = InverseGamma(g);
		b = InverseGamma(b);

		--// sRGB -> XYZ -> CIELUV
		local y = 0.2125862307855956 * r + 0.71517030370341085 * g + 0.0722004986433362 * b;
		local z = 3.6590806972265883 * r + 11.4426895800574232 * g + 4.1149915024264843 * b;
		local l = y > 0.008856451679035631 and 116 * y ^ (1 / 3) - 16 or 903.296296296296 * y;

		if z > 1e-15 then
			local x = 0.9257063972951867 * r - 0.8333736323779866 * g - 0.09209820666085898 * b;
			return l, l * x / z, l * (9 * y / z - 0.46832);
		else
			return l, -0.19783 * l, -0.46832 * l;
		end;
	end;

	function Extension:LerpCIELUV(c0: Color3, c1: Color3): (t: number) -> Color3
		local l0, u0, v0 = RgbToLuv13(c0);
		local l1, u1, v1 = RgbToLuv13(c1);

		local function GammaCorrect(x: number): number
			if x < 0.0031306684425 then
				return 12.92 * x;
			else
				return 1.055 * x ^ (1 / 2.4) - 0.055;
			end;
		end;

		return function(t: number): Color3
			local l = (1 - t) * l0 + t * l1;
			if l < 0.0197955 then
				return Black;
			end;

			local u = ((1 - t) * u0 + t * u1) / l + 0.19783;
			local v = ((1 - t) * v0 + t * v1) / l + 0.46832;

			--// CIELUV -> XYZ
			local y = (l + 16) / 116;
			y = y > 0.20689655172413793 and y ^ 3 or 0.12841854934601665 * y - 0.01771290335807126;
			local x = y * u / v;
			local z = y * ((3 - 0.75 * u) / v - 5);

			--// XYZ -> linear sRGB
			local r = 7.2914074 * x - 1.5372080 * y - 0.4986286 * z;
			local g = -2.1800940 * x + 1.8757561 * y + 0.0415175 * z;
			local b = 0.1253477 * x - 0.2040211 * y + 1.0569959 * z;

			--// out of bounds values get handled HEre
			if r < 0 and r < g and r < b then
				r, g, b = 0, g - r, b - r;
			elseif g < 0 and g < b then
				r, g, b = r - g, 0, b - g;
			elseif b < 0 then
				r, g, b = r - b, g - b, 0;
			end;

			return {
				r = Clamp(GammaCorrect(r), 0, 1),
				g = Clamp(GammaCorrect(g), 0, 1),
				b = Clamp(GammaCorrect(b), 0, 1),
			};
		end;
	end;


    function Extension:AddScrollableChild(Container: any, Child: any, Padding: number?): ()
        Padding = Padding or 0;

        local State = ScrollState[Container];
        if not State then
            return;
        end;

        local YOffset: number = State.ContentSize;
        Child.Position = Container.Position + Vec2(0, YOffset);
        Child.Visible = true;

        Insert(State.Children, Child);

        State.ContentSize += Child.Size.Y + Padding;
    end;

    function Extension:MakeScrollable(Container: any, Padding: number?): ()
        Padding = Padding or 0;

        ScrollState[Container] = {
            Offset = 0,
            Padding = Padding,
            Children = { },
            ContentSize = 0
        };

        InputService.InputChanged:Connect(function(Input: InputObject, Gpe: boolean): ()
            if Gpe then
                return;
            end;

            if Input.UserInputType ~= Enum.UserInputType.MouseWheel then
                return;
            end;

            if not self:MouseOver(Container) then
                return;
            end;

            local State = ScrollState[Container];
            if not State then
                return;
            end;

            local Delta: number = -Sign(Input.Position.Z) * 24;
            local MaxScroll: number = Max(0, State.ContentSize - Container.Size.Y);

            State.Offset = Clamp(State.Offset + Delta, -MaxScroll, 0);

            for _, Child in State.Children do
                local LocalY: number =
                    (Child.Position.Y - Container.Position.Y)
                    + Delta;

                local NewY: number = Container.Position.Y + LocalY;

                Child.Position = Vec2(
                    Child.Position.X,
                    NewY
                );

                Child.Visible =
                    NewY + Child.Size.Y >= Container.Position.Y
                    and NewY <= Container.Position.Y + Container.Size.Y;
            end;
        end);
    end;

    function Extension:RefreshScroll(Container: any): ()
        local State = ScrollState[Container];
        if not State then
            return;
        end;

        State.Offset = 0;

        local Y: number = 0;
        for _, Child in State.Children do
            Child.Position = Container.Position + Vec2(0, Y);
            Child.Visible = true;
            Y += Child.Size.Y + State.Padding;
        end;
    end;

	function Extension:RoundedSquare(
		Position: Vector2,
		Size: Vector2,
		Radius: number,
		Color: Color3,
		Transparency: number
	): ()
		assert(typeof(Position) == "Vector2", "position must be Vector2");
		assert(typeof(Size) == "Vector2", "size must be Vector2");
		assert(typeof(Radius) == "number", "radius must be number");
		assert(typeof(Transparency) == "number", "transparency must be number");
		assert(typeof(Color) == "Color3", "color must be Color3");

		local MaxRadius: number = Min(Size.X, Size.Y) / 2;
		local R: number = Clamp(Radius, 0, MaxRadius);

		local Center: any = Draw("Square");
		local Top: any = Draw("Square");
		local Bottom: any = Draw("Square");
		local Left: any = Draw("Square");
		local Right: any = Draw("Square");

		local CornerTL: any = Draw("Circle");
		local CornerTR: any = Draw("Circle");
		local CornerBL: any = Draw("Circle");
		local CornerBR: any = Draw("Circle");

		local AllObjects: { any } = {
			Center,
			Top,
			Bottom,
			Left,
			Right,
			CornerTL,
			CornerTR,
			CornerBL,
			CornerBR,
		};

		for _, Obj: any in AllObjects do
			Obj.Filled = true;
			Obj.Visible = true;
			Obj.Transparency = Transparency;
			Obj.Color = Color;

			if Obj.Thickness ~= nil then
				Obj.Thickness = 0;
			end;
		end;

		local Self: {
			Position: Vector2,
			Size: Vector2,
			Color: Color3,
			Transparency: number,
			Rounding: number,
			Visible: boolean,
			__Objects: { any },

			Update: (self: any) -> (),
			Destroy: (self: any) -> (),
		} = {
			Position = Position,
			Size = Size,
			Color = Color,
			Transparency = Transparency,
			Rounding = R,
			Visible = true,

			__Objects = AllObjects,
		};

		local function Sync(): ()
			local Pos: Vector2 = Self.Position;
			local CurSize: Vector2 = Self.Size;
			local CurR: number = Clamp(Self.Rounding, 0, Min(CurSize.X, CurSize.Y) / 2);

			Self.Rounding = CurR;

			local X: number = Pos.X;
			local Y: number = Pos.Y;
			local W: number = CurSize.X;
			local H: number = CurSize.Y;

			local CenterSize: Vector2 = Vec2(
				Max(0, W - 2 * CurR),
				Max(0, H - 2 * CurR)
			);
			Center.Size = CenterSize;
			Center.Position = Vec2(X + CurR, Y + CurR);

			local TopSize: Vector2 = Vec2(
				Max(0, W - 2 * CurR),
				CurR
			);
			Top.Size = TopSize;
			Top.Position = Vec2(X + CurR, Y);

			Bottom.Size = TopSize;
			Bottom.Position = Vec2(X + CurR, Y + H - CurR);

			local SideSize: Vector2 = Vec2(
				CurR,
				Max(0, H - 2 * CurR)
			);
			Left.Size = SideSize;
			Left.Position = Vec2(X, Y + CurR);

			Right.Size = SideSize;
			Right.Position = Vec2(X + W - CurR, Y + CurR);

			CornerTL.Radius = CurR;
			CornerTL.Position = Vec2(X + CurR, Y + CurR);

			CornerTR.Radius = CurR;
			CornerTR.Position = Vec2(X + W - CurR, Y + CurR);

			CornerBL.Radius = CurR;
			CornerBL.Position = Vec2(X + CurR, Y + H - CurR);

			CornerBR.Radius = CurR;
			CornerBR.Position = Vec2(X + W - CurR, Y + H - CurR);

			for _, Obj: any in AllObjects do
				Obj.Visible = Self.Visible;
				Obj.Color = Self.Color;
				Obj.Transparency = Self.Transparency;
			end;
		end;

		function Self.Update(): ()
			Sync();
		end;

		function Self.Destroy(): ()
			for _, Obj: any in Self.__Objects do
				pcall(function()
					if Obj and Obj.Destroy then
						Obj:Destroy();
					end;
				end);
			end;

			Self.__Objects = {};
		end;

		Sync();

		local Proxy: any = newproxy(true);
		local Mt: any = getmetatable(Proxy);

		Mt.__index = function(_: any, Key: string): any
			if Self[Key] ~= nil then
				return Self[Key];
			end;
			return nil;
		end;

		Mt.__newindex = function(_: any, Key: string, Value: any): ()
			if Key == "Position" then
				assert(typeof(Value) == "Vector2", "Position must be Vector2");
				Self.Position = Value;
				Sync();
			elseif Key == "Size" then
				assert(typeof(Value) == "Vector2", "Size must be Vector2");
				Self.Size = Value;
				Self.Rounding = Clamp(Self.Rounding, 0, Min(Value.X, Value.Y) / 2);
				Sync();
			elseif Key == "Color" then
				assert(typeof(Value) == "Color3", "Color must be Color3");
				Self.Color = Value;
				Sync();
			elseif Key == "Transparency" then
				assert(typeof(Value) == "number", "Transparency must be number");
				Self.Transparency = Clamp(Value, 0, 1);
				Sync();
			elseif Key == "Rounding" then
				assert(typeof(Value) == "number", "Rounding must be number");
				Self.Rounding = Clamp(Value, 0, Min(Self.Size.X, Self.Size.Y) / 2);
				Sync();
			elseif Key == "Visible" then
				assert(typeof(Value) == "boolean", "Visible must be boolean");
				Self.Visible = Value;
				Sync();
			else
				Self[Key] = Value;
			end;
		end;

		Mt.__tostring = function(): string
			return ("(Pos=%.1f,%.1f Size=%.1f,%.1f R=%.1f)")
				:format(
					Self.Position.X,
					Self.Position.Y,
					Self.Size.X,
					Self.Size.Y,
					Self.Rounding
				);
		end;

		return (Proxy :: any) :: any;
	end;

	function Extension:CreateBlur(Square: DrawingSquare, Name: string): BlurHandle
		assert(Square, "Missing argument #1");
		assert(Name, "Missing argument #2");

		local DepthOfField: DepthOfFieldEffect = Lighting:FindFirstChild("RBXUiBlur") :: DepthOfFieldEffect
			or Instance.new("DepthOfFieldEffect");

		DepthOfField.Name = "RBXUiBlur";
		DepthOfField.FarIntensity = 0;
		DepthOfField.NearIntensity = 1;
		DepthOfField.FocusDistance = 51.6;
		DepthOfField.InFocusRadius = 50;
		DepthOfField.Parent = Lighting;

		Extension.RenderId += 1;
		local BindName: string = "Blur_" .. Extension.RenderId;

		local Root: Folder = InstanceNew("Folder");
		Root.Name = Name;
		Root.Parent = Camera;

		local Parts: { BasePart? } = Create(4);

		local function ApplyParts(): ()
			for I: number = 1, 4 do
				local P: BasePart? = Parts[I];
				if P then
					P.Parent = Root;
					P.Transparency = 0.98;
					P.BrickColor = BrickColor.new("Institutional white");
				end;
			end;
		end;

		local function Update(): ()
			if not Square.Visible then
				return;
			end;

			local Pos = typeof(Square.Position) == "Vector2" 
				and Square.Position 
				or Extension:UDim2ToVector2(Square.Position, Camera.ViewportSize);
        
			local Size = typeof(Square.Size) == "Vector2"
				and Square.Size
				or Extension:UDim2ToVector2(Square.Size, Camera.ViewportSize);
			
			local Z: number = 1 - Square.ZIndex * 0.05;

			local TL: Vector2 = Pos;
			local BR: Vector2 = Pos + Size;
			local TR: Vector2 = Vec2(BR.X, TL.Y);
			local BL: Vector2 = Vec2(TL.X, BR.Y);

			local TLRay: Ray = ScreenPointToRay(Camera, TL.X, TL.Y, Z);
			local TRRay: Ray = ScreenPointToRay(Camera, TR.X, TR.Y, Z);
			local BLRay: Ray = ScreenPointToRay(Camera, BL.X, BL.Y, Z);
			local BRRay: Ray = ScreenPointToRay(Camera, BR.X, BR.Y, Z);

			-- Draw Quad
			local function DrawTriangle(
				V1: Vector3,
				V2: Vector3,
				V3: Vector3,
				P0: BasePart?,
				P1: BasePart?
			): (BasePart, BasePart)
				local S1: number = (V1 - V2).Magnitude;
				local S2: number = (V2 - V3).Magnitude;
				local S3: number = (V3 - V1).Magnitude;

				local SMax: number = Max(S1, S2, S3);
				local A: Vector3; local B: Vector3; local C: Vector3;

				if S1 == SMax then
					A, B, C = V1, V2, V3;
				elseif S2 == SMax then
					A, B, C = V2, V3, V1;
				else
					A, B, C = V3, V1, V2;
				end;

				local BA: Vector3 = B - A;
				local CA: Vector3 = C - A;

				local Para: number = (BA:Dot(CA)) / BA.Magnitude;
				local Perp: number = Sqrt(CA.Magnitude * CA.Magnitude - Para * Para);
				local DifPara: number = (A - B).Magnitude - Para;

				local ST: CFrame = CFrameNew(B, A);
				local ZA: CFrame = CFrameAngles(Pi / 2, 0, 0);

				local CF0: CFrame = ST;
				local TopLook: Vector3 = (CF0 * ZA).LookVector;
				local Mid: Vector3 = A + CFrameNew(A, B).LookVector * Para;
				local NeedLook: Vector3 = CFrameNew(Mid, C).LookVector;

				local Dot: number = TopLook:Dot(NeedLook);
				local AC: CFrame = CFrameAngles(0, 0, Acos(Dot));

				CF0 = CF0 * AC;
				if ((CF0 * ZA).LookVector - NeedLook).Magnitude > 0.01 then
					CF0 = CF0 * CFrameAngles(0, 0, -2 * Acos(Dot));
				end;

				CF0 = CF0 * CFrameNew(0, Perp / 2, -(DifPara + Para / 2));

				local CF1: CFrame = ST * AC * CFrameAngles(0, Pi, 0);
				if ((CF1 * ZA).LookVector - NeedLook).Magnitude > 0.01 then
					CF1 = CF1 * CFrameAngles(0, 0, 2 * Acos(Dot));
				end;

				CF1 = CF1 * CFrameNew(0, Perp / 2, DifPara / 2);

				if not P0 then
					P0 = Instance.new("Part");
					P0.Anchored = true;
					P0.CanCollide = false;
					P0.CastShadow = false;
					P0.Material = Enum.Material.Glass;
					P0.Size = Vec3(0.2, 0.2, 0.2);

					local Mesh: SpecialMesh = Instance.new("SpecialMesh");
					Mesh.MeshType = Enum.MeshType.Wedge;
					Mesh.Parent = P0;
				end;

				local M0: SpecialMesh = P0:FindFirstChildWhichIsA("SpecialMesh") :: SpecialMesh;
				M0.Scale = Vec3(0, Perp / 0.2, Para / 0.2);
				P0.CFrame = CF0;

				if not P1 then
					P1 = P0:Clone();
				end;

				local M1: SpecialMesh = P1:FindFirstChildWhichIsA("SpecialMesh") :: SpecialMesh;
				M1.Scale = Vec3(0, Perp / 0.2, DifPara / 0.2);
				P1.CFrame = CF1;

				return P0, P1;
			end;

			local function DrawQuad(
				A: Vector3,
				B: Vector3,
				C: Vector3,
				D: Vector3,
				PartsArr: { BasePart? }
			): ()
				PartsArr[1], PartsArr[2] = DrawTriangle(A, B, C, PartsArr[1], PartsArr[2]);
				PartsArr[3], PartsArr[4] = DrawTriangle(C, B, D, PartsArr[3], PartsArr[4]);
			end;

			DrawQuad(TLRay.Origin, TRRay.Origin, BLRay.Origin, BRRay.Origin, Parts);
		end;

		RunService:BindToRenderStep(BindName, Enum.RenderPriority.Camera.Value + 1967, Update);
		Update();
		ApplyParts();

		return {
			Destroy = function(): ()
				RunService:UnbindFromRenderStep(BindName);
				Root:Destroy();
			end
		};
	end;
end;

return Extension;
