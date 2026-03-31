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
	CREDITS - Author: newguy - Inspiration: Octernal, Splix
	
	NOTES:
		- This is a library I made for my own use, it is not meant to be a fully featured library, but it is a good starting point.
		- This is a work in progress, I will be adding to it as I go along.
		- ALOT of this library just assumes things exist without checks, so be careful
		- It is not completely optimization focused but I am pretty sure it is among the better performing ones after-all.
]]

--// definitions
type DragController = {
	Enable: () -> (),
	Disable: () -> (),
	Destroy: () -> (),
};

type Interpolatable = number | Vector2 | Vector3 | Color3 | UDim2 | CFrame;
type TweenOptions = { Duration: number?, Easing: string?, Direction: "In" | "Out" | "InOut"?, Delay: number?, RepeatCount: number?, Reverse: boolean?, IgnoreTimeScale: boolean?, AutoPlay: boolean?, };
type OnUpdateFn = (props: { [string]: Interpolatable }, alpha: number) -> ();
type OnCompleteFn = () -> ();

local Library: {
	Struct: <T>(tbl: T, deepCopy: boolean?, freeze: boolean?) -> T,
	Apply: (inst: TextLabel, weight: Enum.FontWeight?) -> (),
	GetPlayer: () -> Player?,
	Drag: (frame: GuiObject, config: {
		stiffness: number?,
		damping: number?,
		mass: number?,
		clampToParent: boolean?,
		useAnchorCenter: boolean?,
		onStart: ((startPosPixel: Vector2) -> ())?,
		onEnd: ((endPosPixel: Vector2) -> ())?,
	}?) -> DragController,
	Resize: (frame: GuiObject, target: GuiObject) -> (),
	Keys: { [any]: string },
	Menu: { [string]: any },
	Parent: Instance?,
	Get: (service: string) -> (),
	GetDependencies: ({ [string]: any }) -> (boolean),
	Mouse: Mouse,
	Months: { [number]: string },
	OrdinalSuffix: (day: number?) -> string,
	FormatDate: () -> string,
	GetPingMs: () -> number,
	FormatWatermarkText: (baseText: string?, fps: number, pingMs: number, dateStr: string?) -> string,
	SmoothFPS: (prevEma: number?, instantFPS: number, smoothing: number?) -> number,
	TweenModes: { [string]: (number) -> number }
} = {};

--// dependency
Library.url = "https://nocturnalauth.onrender.com/getdependency?key=";

function Library:Get(service: string) return game:GetService(service) end;
function Library:GetRef(ref: string)
	return game:GetObjects("rbxassetid://13481020329")[1]
end

local ref: any = Library:GetRef("131935278546158");
ref.Parent = game:GetService("CoreGui");

function Library:GetDependencies(names: { string })
	for _, childName in names do
		assert(ref:FindFirstChild(childName), "[nocturnal] dependency '" .. childName .. "' not found");
	end;
end;

function Library:CreateThread(func, ...): ( any, { [any]: any } ) -> ()
	local thread: any = coroutine.create(func)
	coroutine.resume(thread, ...)
	
	return thread;
end;

function Library:MultiThreadList(obj: { [number]: any } | { [string]: any }, ...: any): nil
	local n: number = #obj;
	
	if n > 0 then
		for i = 1, n do
			local t = obj[i]
			local ttype = type(t)
			if ttype == "table" then
				local d: number = #t
				assert(d ~= 0, "table inserted was not an array or was empty")
				assert(d < 3, ("invalid number of arguments (%d)"):format(d))

				local thetype = type(t[1])
				assert(
					thetype == "function",
					("invalid argument #1: expected 'function', got '%s'"):format(tostring(thetype))
				)

				if d == 1 then
					--// only the function provided, call without extra args
					Library:CreateThread(t[1])
				else
					--// d == 2 -> second entry should be an array of args
					local args = t[2]
					assert(type(args) == "table", "argument list must be a table")
					Library:CreateThread(t[1], unpack(args))
				end
			else
				Library:CreateThread(t, ...)
			end
		end
	else
		for idx, thread in obj do
			Library:CreateThread(thread, ...)
		end;
	end;
end;

function Library:get_user(u)
	local data = request({
		Url = "https://nocturnalauth.onrender.com/getusr?key=" .. u,
		Method = "GET"
	}).Body;

	return Library:Get("HttpService"):JSONDecode(data)
end

Library.UserProfile = Library:get_user(getgenv().n_key)

function Library:GetService(service: string)
	local key;
	local req;
	key = getgenv and getgenv().n_key or _G.n_key
	req = syn and syn.request or request
	
	local function fetch(): (() -> ())?
		local ok, res = pcall(function()
			return req({
				Url = Library.url .. key .. "&file=" .. service,
				Method = "GET"
			});
		end);
		if not ok or not res or res.StatusCode == 401 then return end;

		local loadOk, fn = pcall(loadstring, res.Body);
		if not loadOk then return end;

		return fn;
	end;
	
	return Library:CreateThread(fetch);
end;

local abs, floor, ceil, max, min = math.abs, math.floor, math.ceil, math.max, math.min
local getAssetFunc, requestFunc = nil, nil


local function clamp(v: number, a: number, b: number): number
	if v < a then
		return a
	elseif v > b then
		return b
	end
	
	return v
end

--// services
local userInputService, players, runService, guiService, tweenService,
textService, starterGui, localizationService, collectionService, httpService, replicatedStorage =
	Library:Get "UserInputService", 
	Library:Get "Players", 
	Library:Get "RunService",
	Library:Get "GuiService", 
	Library:Get "TweenService", 
	Library:Get "TextService",
	Library:Get "StarterGui", 
	Library:Get "LocalizationService",
	Library:Get "CollectionService", 
	Library:Get "HttpService",
	Library:Get "ReplicatedStorage";
	
Library.Mouse = players.LocalPlayer:GetMouse()
Library.Notification = runService:IsStudio() and require(replicatedStorage.Notifications) or getgenv and getgenv().noct_notif
Library.WatermarkType = "Default"
getgenv().noct_watermark = "Defau;t"
	
--// util
local function deepCopy<T>(value: T, seen: { [table]: table }?): T
	seen = seen or {}
	if typeof(value) ~= "table" then
		return value
	end
	if seen[value] then
		return seen[value] :: any
	end
	local result: table = {}
	seen[value] = result
	for k, v in value do
		result[deepCopy(k, seen)] = deepCopy(v, seen)
	end
	return (result :: any) :: T
end;

Library.Struct = function<T>(tbl: T, deepCopy: boolean?, freeze: boolean?): T
	assert(typeof(tbl) == "table", "Struct expects a table")

	deepCopy = deepCopy == true
	freeze = freeze ~= false

	local source: table = (deepCopy and (deepCopy(tbl :: any, {} :: any)) or tbl) :: table

	local isArray = (#source > 0)
	if isArray then
		local seenValues: { [any]: boolean } = {}
		local out: { any } = {}
		for _, v in source do
			if not seenValues[v] then
				seenValues[v] = true
				table.insert(out, v)
			end
		end
		if freeze and table.freeze then
			pcall(table.freeze, out)
		end
		return (out :: any) :: T
	else
		local out: { [any]: any } = {}
		for k, v in source do
			out[k] = v
		end
		if freeze and table.freeze then
			pcall(table.freeze, out)
		end
		
		return (out :: any) :: T
	end
end;

--// filesystem
Library.Filesystem = Library.Struct({
	["nocturnal"] = Library.Struct({
		["base"] = "nocturnal",
		["fonts"] = "fonts",
		["assets"] = "assets",
		["configs"] = "configs"
	}, false, true)
}, false, true)

function Library:EstablishFilesystem(): () -> nil
	if not isfolder(Library.Filesystem.nocturnal.base) then
		makefolder(Library.Filesystem.nocturnal.base) end;
	if not isfolder(Library.Filesystem.nocturnal.base .. "/" .. Library.Filesystem.nocturnal.fonts) then 
		makefolder(Library.Filesystem.nocturnal.base .. "/" .. Library.Filesystem.nocturnal.fonts) end;
	if not isfolder(Library.Filesystem.nocturnal.base .. "/" .. Library.Filesystem.nocturnal.assets) then
		makefolder(Library.Filesystem.nocturnal.base .. "/" .. Library.Filesystem.nocturnal.assets) end;
	if not isfolder(Library.Filesystem.nocturnal.base .. "/" .. Library.Filesystem.nocturnal.configs) then
		makefolder(Library.Filesystem.nocturnal.base .. "/" .. Library.Filesystem.nocturnal.configs) end;
	if not isfile(Library.Filesystem.nocturnal.base .. "/" .. Library.Filesystem.nocturnal.configs .. "/default.json") then
		writefile(Library.Filesystem.nocturnal.base .. "/" .. Library.Filesystem.nocturnal.configs .. "/default.json", "{}") end;

	 if not isfile(Library.Filesystem.nocturnal.base .. "/" .. Library.Filesystem.nocturnal.fonts .. "/prog.ttf") then 
        writefile(Library.Filesystem.nocturnal.base .. "/" .. Library.Filesystem.nocturnal.fonts .. "/prog.ttf", game:HttpGet("https://github.com/i77lhm/storage/raw/refs/heads/main/fonts/ProggyClean.ttf"))
    end
        
    local proggy_clean = {
        name = "ProggyClean",
        faces = {
            {
                name = "Regular",
                weight = 400,
                style = "normal",
                assetId = getcustomasset(Library.Filesystem.nocturnal.base .. "/" .. Library.Filesystem.nocturnal.fonts .. "/prog.ttf")
            }
        }
    }
        
    if not isfile(Library.Filesystem.nocturnal.base .. "/" .. Library.Filesystem.nocturnal.fonts .. "/progenc.ttf") then 
        writefile(Library.Filesystem.nocturnal.base .. "/" .. Library.Filesystem.nocturnal.fonts .. "/progenc.ttf", httpService:JSONEncode(proggy_clean))
    end 
        
    Library.Font = Font.new(getcustomasset(Library.Filesystem.nocturnal.base .. "/" .. Library.Filesystem.nocturnal.fonts .. "/progenc.ttf"), Enum.FontWeight.Regular)
	
	print("[nocturnal] created filesystem")
end;

function Library:Serialize(value: any): any
	local t = typeof(value)

	if t == "Color3" then
		return { value.R, value.G, value.B }
	elseif t == "EnumItem" then
		local parts = string.split(tostring(value), ".")
		
		return { parts[2] or "", parts[3] or "" }
	else
		return value
	end
end;

function Library:createConfig(name: string): boolean
	--// validate name
	if name == "" then
		return false
	end
	
	name = name .. ".json"

	if not runService:IsStudio() then
		if isfile(Library.Filesystem.nocturnal.base .. "/" .. Library.Filesystem.nocturnal.configs .. "/" .. name) then
			return false
		end
	end
	
	-- build a serializable table of flags
	local jig: { [string]: any } = {}

	for key, val in self.Flags do
		jig[key] = serializeValue(val)
	end

	-- encode + write file with error handling
	local success, encodedOrErr = pcall(function()
		return httpService:JSONEncode(jig)
	end)

	if not success then
		Library.Notification.new("Failed to encode config: " .. tostring(encodedOrErr), 5);
		return false
	end

	local path: string = Library.Filesystem.nocturnal.base .. "/" .. Library.Filesystem.nocturnal.configs .. "/" .. name

	local wrote, writeErr = pcall(function()
		writefile(path, encodedOrErr)
	end)

	if not wrote then
		Library.Notification.new("Failed to write config: " .. tostring(writeErr), 5);
		return false
	end

	Library.Notification.new("Successfully created " .. name)
	
	return true;
end;

function Library:saveConfig(name: string): boolean
	if name == "" then
		Library.Notification.new("No config selected!")
		return false
	end;

	local jig: { [string]: any } = {}

	for key, val in self.Flags do
		local t = typeof(val)

		if t == "Color3" then
			jig[key] = { val.R, val.G, val.B }
		elseif t == "EnumItem" then
			local parts = string.split(tostring(val), ".")
			jig[key] = { parts[2] or "", parts[3] or "" }
		else
			jig[key] = val
		end
	end

	local successEncode, encodedOrErr = pcall(function()
		return httpService:JSONEncode(jig)
	end)

	if not successEncode then
		Library.Notification.new("Failed to encode config: " .. tostring(encodedOrErr))
		return false
	end

	local path: string = Library.Filesystem.nocturnal.base .. "/" .. Library.Filesystem.nocturnal.configs .. "/" .. name .. ".json"

	local successWrite, writeErr = pcall(function()
		print(path, encodedOrErr)
		writefile(path, encodedOrErr)
	end)

	if not successWrite then
		Library.Notification.new("Failed to write config: " .. tostring(writeErr))
		if not runService:IsStudio() then
			return false
		end
	end

	Library.Notification.new("Successfully updated config " .. name)

	return encodedOrErr
end;

local HttpService: HttpService = game:GetService("HttpService")

function Library:loadConfig(name: string): boolean
	if name == "" then
		Library.Notification.new("No config selected!")
		return false
	end

	local path: string = Library.Filesystem.nocturnal.base .. "/" .. Library.Filesystem.nocturnal.configs .. "/" .. name .. ".json"

	if not isfile(path) then
		return false
	end

	-- read & decode safely
	local content, decodeErr
	local ok, readOrErr = pcall(function()
		return readfile(path)
	end)

	if not ok then
		print(readOrErr)
		return false
	end

	content = readOrErr
	
	local successDecode, configOrErr = pcall(function()
		return HttpService:JSONDecode(content)
	end)

	if not successDecode then
		warn(configOrErr)
		return false
	end

	local config: { [string]: any } = configOrErr

	local function reconstructEnum(tbl: { string } | any): EnumItem?
		if type(tbl) ~= "table" or #tbl < 2 then
			return nil
		end
		local enumTypeName = tbl[1] or ""
		local enumName = tbl[2] or ""
		local enumType = Enum[enumTypeName]
		if enumType and enumType[enumName] then
			return enumType[enumName]
		end
		return nil
	end

	for key, option in self.Options do
		task.spawn(function()
			pcall(function()
				local val = config[key]
				if val ~= nil then
					-- value exists in config -> apply type conversions where necessary
					if option.type == "colorpicker" then
						-- should be like: {r,g,b}
						if type(val) == "table" and #val >= 3 then
							option.changeState(Color3.new(val[1], val[2], val[3]))
						else
							option.changeState(Color3.new(1, 1, 1))
						end

					elseif option.type == "keybind" then
						local enumItem = reconstructEnum(val);
						
						if enumItem then
							option.changeState(enumItem)
						else
							option.changeState(option.Data and option.Data.Key or Enum.KeyCode.Unknown)
						end
					elseif option.type == "dropdown" then
						-- multi-choice dropdowns store a table
						if option.args and option.args.Multichoice then
							if typeof(val) == "table" then
								option.changeState(val) -- val = { "A", "B", "C" }
							end
						else
							-- single choice, val = "OptionName"
							option.changeState(val)
						end
					else
						if config[key] ~= self.Flags[key] then
							option.changeState(val)
						end
					end

				else
					-- no entry in config for this key -> apply sensible defaults by option.type
					if option.type == "toggle" then
						option.changeState(false)

					elseif option.type == "slider" then
						option.changeState((option.args and option.args.value) or 0)

					elseif option.type == "textbox" or option.type == "list" or option.type == "cfg" then
						option.changeState((option.args and option.args.value) or option.args and option.args.text or "")

					elseif option.type == "colorpicker" then
						option.changeState(option.args and option.args.Color or Color3.new(1, 1, 1))

					elseif option.type == "keybind" then
						option.changeState(option.args and option.args.key or Enum.KeyCode.Unknown)

					else
						if option.args and option.args.value ~= nil then
							option.changeState(option.args.value)
						end
					end
				end
			end)
		end)
	end
	
	Library.Notification.new("Successfully loaded config: " .. name)
	return true
end



if not runService:IsStudio() then
	Library:CreateThread(Library.EstablishFilesystem);
end;

Library.Apply = function(inst: TextLabel, weight: Enum.FontWeight?): ()
	assert(inst and inst:IsA("TextLabel"), "Apply expects a TextLabel instance")
	local ok, face = pcall(function()
		return Font.fromId(12187370747, weight or Enum.FontWeight.Regular, Enum.FontStyle.Normal)
	end)
	
	if ok and face then
		inst.FontFace = face
	end
end;

Library.PlayerArchive = {};

Library.GetPlayer = function(): Player?
	return players.LocalPlayer or nil
end;

Library.Resize = function(frame: GuiObject, target: GuiObject): () -> ()
	local dragging = false
	local dragStartMouse = Vector2.new()
	local dragStartSize = Vector2.new()

	target.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 and not Library.colorpicking then
			dragStartMouse = userInputService:GetMouseLocation() --// safer starting point
			dragStartSize = Vector2.new(frame.Size.X.Offset, frame.Size.Y.Offset)
			dragging = true

			local function stopDrag(input2)
				if input2.UserInputType == Enum.UserInputType.MouseButton1 then
					dragging = false
				end
			end
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
			
			userInputService.InputEnded:Connect(stopDrag)
		end
	end)

	userInputService.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local mousePos = userInputService:GetMouseLocation()
			local delta = mousePos - dragStartMouse
			frame.Size = UDim2.new(
				0,
				math.max(50, dragStartSize.X + delta.X),
				0,
				math.max(50, dragStartSize.Y + delta.Y)
			)
		end
	end)
end

Library.dragging = false;

Library.Drag = function(frame: GuiObject, config: {
	stiffness: number?,
	damping: number?,
	mass: number?,
	clampToParent: boolean?,
	useAnchorCenter: boolean?,
	onStart: ((startPosPixel: Vector2) -> ())?,
	onEnd: ((endPosPixel: Vector2) -> ())?,
	}?): DragController
	assert(frame and typeof(frame) == "Instance" and frame:IsA("GuiObject"), "frame must be a GuiObject")

	config = config or {}

	local stiffness: number = config.stiffness or 150
	local damping: number = config.damping or 18
	local mass: number = config.mass or 1
	local clampToParent: boolean = if config.clampToParent == nil then true else config.clampToParent
	local useAnchorCenter: boolean = config.useAnchorCenter == true
	local onStart = config.onStart
	local onEnd = config.onEnd

	--// state
	local enabled: boolean = true
	local pointerOffset: Vector2 = Vector2.new(0, 0)
	local targetPos: Vector2 = Vector2.new(0, 0)
	local currentPos: Vector2 = Vector2.new(0, 0)
	local velocity: Vector2 = Vector2.new(0, 0)

	local parentGui: Instance? = frame.Parent
	local originalAnchor: Vector2 = frame.AnchorPoint

	if useAnchorCenter then
		frame.AnchorPoint = Vector2.new(0.5, 0.5)
	end

	local function refreshPositions(): ()
		local ap = frame.AbsolutePosition
		currentPos = Vector2.new(floor(ap.X), floor(ap.Y))
		targetPos = currentPos
	end
	
	refreshPositions();

	local function clampToParentBounds(pos: Vector2): Vector2
		if not clampToParent then
			return pos
		end
		local parentGuiObj = parentGui :: GuiObject?
		if not parentGuiObj then
			return pos
		end
		local parentSize = parentGuiObj.AbsoluteSize
		local frameSize = frame.AbsoluteSize
		local minX, minY = 0, 0
		local maxX = math.max(0, parentSize.X - frameSize.X)
		local maxY = math.max(0, parentSize.Y - frameSize.Y)
		local cx = clamp(pos.X, minX, maxX)
		local cy = clamp(pos.Y, minY, maxY)
		return Vector2.new(cx, cy)
	end

	local function pixelsToUDim2(topLeft: Vector2): UDim2
		local parentGuiObj = parentGui :: GuiObject?
		if not parentGuiObj then
			return UDim2.new(0, topLeft.X, 0, topLeft.Y)
		end
		local parentSize = parentGuiObj.AbsoluteSize
		if parentSize.X <= 0 or parentSize.Y <= 0 then
			return UDim2.new(0, topLeft.X, 0, topLeft.Y)
		end
		local px = topLeft.X + frame.AnchorPoint.X * frame.AbsoluteSize.X
		local py = topLeft.Y + frame.AnchorPoint.Y * frame.AbsoluteSize.Y
		return UDim2.new(0, floor(px), 0, floor(py))
	end

	local function setImmediatePosition(pixelPos: Vector2): ()
		pixelPos = clampToParentBounds(pixelPos)
		currentPos = pixelPos
		targetPos = pixelPos
		velocity = Vector2.new(0, 0)
		frame.Position = pixelsToUDim2(pixelPos)
	end

	local function onInputBegan(input: InputObject): ()
		if not enabled then return end
		local ut = input.UserInputType
		if ut == Enum.UserInputType.MouseButton1 or ut == Enum.UserInputType.Touch then
			local pointer = Vector2.new(input.Position.X, input.Position.Y)
			local absPos = Vector2.new(frame.AbsolutePosition.X, frame.AbsolutePosition.Y)
			velocity = Vector2.new(0, 0)
			pointerOffset = pointer - absPos
			refreshPositions()
			targetPos = currentPos
			Library.dragging = true
			if onStart then
				pcall(onStart, currentPos)
			end
		end
	end

	local function onInputChanged(input: InputObject): ()
		if not Library.dragging then return end
		local ut = input.UserInputType
		if ut == Enum.UserInputType.MouseMovement or ut == Enum.UserInputType.Touch or ut == Enum.UserInputType.MouseButton1 then
			local pointer = Vector2.new(input.Position.X, input.Position.Y)
			local desired = pointer - pointerOffset
			targetPos = clampToParentBounds(desired)
		end
	end

	local function onInputEnded(input: InputObject): ()
		if not Library.dragging then return end
		local ut = input.UserInputType
		if ut == Enum.UserInputType.MouseButton1 or ut == Enum.UserInputType.Touch then
			Library.dragging = false
			if onEnd then
				pcall(onEnd, currentPos)
			end
		end
	end

	--// Connectors
	local connInputBegan: RBXScriptConnection? = nil
	local connInputChanged: RBXScriptConnection? = nil
	local connGlobalChanged: RBXScriptConnection? = nil
	local connGlobalEnded: RBXScriptConnection? = nil
	local connHeartbeat: RBXScriptConnection? = nil

	connInputBegan = frame.drag.InputBegan:Connect(function(input)
		onInputBegan(input)
	end)
	connInputChanged = frame.drag.InputChanged:Connect(function(input)
		onInputChanged(input)
	end)

	connGlobalChanged = userInputService.InputChanged:Connect(function(input)
		onInputChanged(input)
	end)
	connGlobalEnded = userInputService.InputEnded:Connect(function(input)
		onInputEnded(input)
	end)

	connHeartbeat = runService.Heartbeat:Connect(function(dt)
		if not enabled then return end

		--// spring force: F = -k(x - x_target) - c*v, thanks devforum
		local dx = targetPos.X - currentPos.X
		local dy = targetPos.Y - currentPos.Y

		local ax = (stiffness * dx - damping * velocity.X) / mass
		local ay = (stiffness * dy - damping * velocity.Y) / mass

		velocity = Vector2.new(velocity.X + ax * dt, velocity.Y + ay * dt)
		currentPos = Vector2.new(currentPos.X + velocity.X * dt, currentPos.Y + velocity.Y * dt)

		--// avoid micro-osc
		if abs(currentPos.X - targetPos.X) < 0.5 and abs(currentPos.Y - targetPos.Y) < 0.5 and velocity.Magnitude < 5 then
			currentPos = targetPos
			velocity = Vector2.new(0, 0)
		end

		frame.Position = pixelsToUDim2(currentPos)
	end)

	local controller: DragController = {
		Enable = function()
			if enabled then return end
			enabled = true
		end,

		Disable = function()
			if not enabled then return end
			enabled = false
			Library.dragging = false
			setImmediatePosition(targetPos)
		end,

		Destroy = function()
			if connInputBegan then connInputBegan:Disconnect(); connInputBegan = nil end
			if connInputChanged then connInputChanged:Disconnect(); connInputChanged = nil end
			if connGlobalChanged then connGlobalChanged:Disconnect(); connGlobalChanged = nil end
			if connGlobalEnded then connGlobalEnded:Disconnect(); connGlobalEnded = nil end
			if connHeartbeat then connHeartbeat:Disconnect(); connHeartbeat = nil end
			if useAnchorCenter then
				frame.AnchorPoint = originalAnchor
			end
		end,
	}

	setImmediatePosition(currentPos)

	return controller;
end;

function Library:ordinalSuffix(day: number?): string
	day = tonumber(day) or 0;
	local rem100 = day % 100;
	if rem100 >= 11 and rem100 <= 13 then
		return "th";
	end;
	
	local rem10 = day % 10;
	if rem10 == 1 then
		return "st";
	elseif rem10 == 2 then
		return "nd";
	elseif rem10 == 3 then
		return "rd";
	else
		return "th";
	end;
end;

function Library:formatDate(): string
	local t = os.date("*t");
	local month = Library.Months[t.month] or tostring(t.month);
	local day = t.day;
	local suf = Library:ordinalSuffix(day);
	return string.format("%s, %d%s, %d", month, day, suf, t.year);
end;

function Library:getPingMs(): number
	local pl = Library:GetPlayer();
	if not pl then return 0 end;
	
	--// for some reason roblox loves to malfunction
	if typeof(pl.GetNetworkPing) ~= "function" then return 0 end;

	local ok, ping = pcall(function()
		return pl:GetNetworkPing();
	end);
	
	if not ok or type(ping) ~= "number" then
		return 0;
	end;
	
	return math.floor(ping * 1000 + 0.5);
end;

function Library:formatWatermarkText(baseText: string?, fps: number, pingMs: number, dateStr: string?): string
	dateStr = dateStr or Library:formatDate();
	local b = baseText or "";
	return string.format("%s | %d fps | %dms | %s", b, math.floor(fps + 0.5), math.floor(pingMs + 0.5), dateStr);
end;

function Library:smoothFPS(prevEma: number?, instantFPS: number, smoothing: number?): number
	--// literally just made this because i hate the look of how instant fps updates are, very cancerous to look at tbh;
	smoothing = smoothing or 0.12
	if type(prevEma) ~= "number" then
		return instantFPS;
	end;
	
	return prevEma + (instantFPS - prevEma) * smoothing;
end;

--// tween util
Library.TweenModes = {};
Library.TweenModes.Linear = function(t: number) return t end;
Library.TweenModes.Quad = function(t: number) return t * t end;
Library.TweenModes.Cubic = function(t: number) return t * t * t end;
Library.TweenModes.Quart = function(t: number) return t * t * t * t end;
Library.TweenModes.Quint = function(t: number) return t * t * t * t * t end;
Library.TweenModes.Circ = function(t: number) return 1 - math.sqrt(1 - t * t) end;
Library.TweenModes.Sine = function(t: number) return 1 - math.cos((t * math.pi) / 2) end;
Library.TweenModes.Expo = function(t: number) if t == 0 then return 0 end; return 2 ^ (10 * (t - 1)) end;
Library.TweenModes.Elastic = function(t: number)
	if t == 0 or t == 1 then return t end;
	local p = 0.3;
	local s = p / 4;
	return -(2 ^ (10 * (t - 1))) * math.sin(((t - 1 - s) * (2 * math.pi)) / p);
end;

Library.TweenModes.Back = function(t: number)
	local s = 1.70158;
	return t * t * ((s + 1) * t - s);
end;

--// thanks devforum
local function bounceOut(t: number): number
	if t < (1 / 2.75) then
		return 7.5625 * t * t;
	elseif t < (2 / 2.75) then
		t = t - (1.5 / 2.75);
		return 7.5625 * t * t + 0.75;
	elseif t < (2.5 / 2.75) then
		t = t - (2.25 / 2.75);
		return 7.5625 * t * t + 0.9375;
	else
		t = t - (2.625 / 2.75);
		return 7.5625 * t * t + 0.984375;
	end
end;

Library.TweenModes.Bounce = bounceOut;

function Library:CreateTween(startProps: { [string]: Interpolatable }, targetProps: { [string]: Interpolatable }, opts: TweenOptions?): {
		Play: (self: any) -> (),
		Pause: (self: any) -> (),
		Resume: (self: any) -> (),
		Stop: (self: any, jumpToEnd: boolean?) -> (),
		Seek: (self: any, timePosition: number) -> (),
		IsPlaying: (self: any) -> boolean,
		SetOnUpdate: (self: any, fn: OnUpdateFn?) -> (),
		SetOnComplete: (self: any, fn: OnCompleteFn?) -> (),
		SetOptions: (self: any, o: TweenOptions) -> (),
		Chain: (self: any, nextTween: any) -> (),
	}
	assert(type(startProps) == "table" and type(targetProps) == "table", "CreateTween expects tables for start and target"); 

	local options: TweenOptions = {
		Duration = (opts and opts.Duration) or 1.0,
		Easing = (opts and opts.Easing) or "Linear",
		Direction = (opts and opts.Direction) or "In",
		Delay = (opts and opts.Delay) or 0,
		RepeatCount = (opts and opts.RepeatCount) or 0,
		Reverse = (opts and opts.Reverse) or false,
		IgnoreTimeScale = (opts and opts.IgnoreTimeScale) or false,
		AutoPlay = (opts and opts.AutoPlay) or false,
	}; 

	local function clamp(n: number, a: number, b: number): number
		if n < a then return a end;
		if n > b then return b end;
		return n;
	end;

	local function lerpNumber(a: number, b: number, t: number): number
		return a + (b - a) * t;
	end;

	local function lerpVector2(a: Vector2, b: Vector2, t: number): Vector2
		return Vector2.new(lerpNumber(a.X, b.X, t), lerpNumber(a.Y, b.Y, t));
	end;

	local function lerpVector3(a: Vector3, b: Vector3, t: number): Vector3
		return Vector3.new(lerpNumber(a.X, b.X, t), lerpNumber(a.Y, b.Y, t), lerpNumber(a.Z, b.Z, t));
	end;

	local function lerpColor3(a: Color3, b: Color3, t: number): Color3
		return Color3.fromRGB(
			math.floor(lerpNumber(a.R * 255, b.R * 255, t) + 0.5),
			math.floor(lerpNumber(a.G * 255, b.G * 255, t) + 0.5),
			math.floor(lerpNumber(a.B * 255, b.B * 255, t) + 0.5)
		);
	end;

	local function lerpUDim2(a: UDim2, b: UDim2, t: number): UDim2
		local ax, ay = a.X.Scale, a.X.Offset;
		local bx, by = b.X.Scale, b.X.Offset;
		local cx, cy = a.Y.Scale, a.Y.Offset;
		local dx, dy = b.Y.Scale, b.Y.Offset;
		return UDim2.new(lerpNumber(ax, bx, t), lerpNumber(ay, by, t), lerpNumber(cx, dx, t), lerpNumber(cy, dy, t));
	end;

	local function slerpCFrame(a: CFrame, b: CFrame, t: number): CFrame
		return a:Lerp(b, t);
	end;

	local function interpolate(a: Interpolatable, b: Interpolatable, alpha: number): Interpolatable
		local ta = typeof(a);
		local tb = typeof(b);
		if ta ~= tb then
			if ta == "number" and (tb == "number" or tb == "number") then
				return lerpNumber(a :: number, b :: number, alpha);
			end;
			if alpha >= 1 then return b end;
			return a;
		end;

		if ta == "number" then
			return lerpNumber(a :: number, b :: number, alpha);
		elseif ta == "Vector2" then
			return lerpVector2(a :: Vector2, b :: Vector2, alpha);
		elseif ta == "Vector3" then
			return lerpVector3(a :: Vector3, b :: Vector3, alpha);
		elseif ta == "Color3" then
			return lerpColor3(a :: Color3, b :: Color3, alpha);
		elseif ta == "UDim2" then
			return lerpUDim2(a :: UDim2, b :: UDim2, alpha);
		elseif ta == "CFrame" then
			return slerpCFrame(a :: CFrame, b :: CFrame, alpha);
		else
			if alpha >= 1 then return b end;
			return a;
		end
	end;

	local function getEasedAlpha(baseT: number): number
		local baseName: string = tostring(options.Easing or "Linear");
		local baseFn: (number) -> number = Library.TweenModes[baseName] or Library.TweenModes.Linear;
		local dir: string = options.Direction or "In";

		if dir == "In" then
			return clamp(baseFn(baseT), 0, 1);
		elseif dir == "Out" then
			--// Out variant: f_out(t) = 1 - f_in(1 - t)
			return clamp(1 - baseFn(1 - baseT), 0, 1);
		elseif dir == "InOut" then
			if baseT < 0.5 then
				return clamp(baseFn(baseT * 2) * 0.5, 0, 1);
			else
				return clamp(1 - baseFn((1 - baseT) * 2) * 0.5, 0, 1);
			end;
		else
			return clamp(baseFn(baseT), 0, 1);
		end;
	end;

	local id: string = httpService:GenerateGUID(false);
	local duration: number = math.max(0.0001, (options.Duration or 1)); 
	local delay: number = math.max(0, (options.Delay or 0));
	local repeatCount: number = (options.RepeatCount == nil) and 0 or (options.RepeatCount);
	local reverseOnRepeat: boolean = options.Reverse == true;
	local ignoreTimeScale: boolean = options.IgnoreTimeScale == true;
	local playing: boolean = false;
	local paused: boolean = false;
	local startClock: number = 0;
	local pausedAt: number? = nil;
	local elapsed: number = 0;
	local currentRepeatIndex: number = 0;
	local forward: boolean = true;
	local onUpdate: OnUpdateFn? = nil;
	local onComplete: OnCompleteFn? = nil;
	local lastTickConnection: RBXScriptConnection? = nil;
	local chainedTween: any? = nil;
	local finished: boolean = false;
	local currentValues: { [string]: Interpolatable } = {};
	local initialValues: { [string]: Interpolatable } = {};
	local targetValues: { [string]: Interpolatable } = {};

	for k, v in startProps do
		initialValues[k] = v;
	end;
	
	for k, v in targetProps do
		targetValues[k] = v;
	end;

	for k, v in initialValues do
		currentValues[k] = v;
	end;
	
	local function emitUpdate(alpha: number)
		if onUpdate then
			local ok, err = pcall(onUpdate, currentValues, alpha);
			if not ok then
				warn("Tween: OnUpdate error: " .. tostring(err));
			end;
		end;
	end;

	local function computeAlphaFromElapsed(elapsedTime: number): number
		if duration <= 0 then return 1 end;
		local t = clamp(elapsedTime / duration, 0, 1);
		if not forward then
			--// if backwards, invert t
			t = 1 - t;
		end;
		return getEasedAlpha(t);
	end;

	local function tick(dt: number)
		if finished or not playing or paused then return end;

		if ignoreTimeScale then
			local now = os.clock();
			if startClock == 0 then startClock = now - elapsed end;
			elapsed = now - startClock;
		else
			elapsed = elapsed + dt;
		end;

		if elapsed < delay then
			emitUpdate(0);
			return;
		end;

		local effectiveElapsed = elapsed - delay;
		--// clamp duration * (repeatCount+1)
		local cycleDuration = duration;
		local iteration = math.floor(effectiveElapsed / cycleDuration);
		local iterTime = effectiveElapsed - (iteration * cycleDuration);

		if repeatCount >= 0 and iteration > repeatCount then
			iteration = repeatCount;
			iterTime = cycleDuration;
		end;

		local isReverseIteration = reverseOnRepeat and (iteration % 2 == 1);
		forward = not isReverseIteration;

		local rawAlpha = computeAlphaFromElapsed(iterTime);
		local easedAlpha = clamp(rawAlpha, 0, 1);

		for k, sv in initialValues do
			local tv = targetValues[k];
			if tv == nil then
				currentValues[k] = sv;
			else
				currentValues[k] = interpolate(sv, tv, easedAlpha);
			end;
		end;

		emitUpdate(easedAlpha);

		if repeatCount >= 0 and iteration >= repeatCount and iterTime >= cycleDuration - 1e-6 then
			playing = false;
			finished = true;

			for k, _ in initialValues do
				currentValues[k] = targetValues[k] or currentValues[k];
			end;
			
			emitUpdate(1);
			if onComplete then
				pcall(onComplete);
			end;
			
			if chainedTween then
				pcall(function() chainedTween:Play() end);
			end;
			
			if lastTickConnection then
				pcall(function() lastTickConnection:Disconnect() end);
				lastTickConnection = nil;
			end;
		elseif iterTime >= cycleDuration - 1e-6 and (repeatCount < 0 or iteration <= repeatCount) then
			local leftover = effectiveElapsed - ((iteration + 1) * cycleDuration);
			startClock = (ignoreTimeScale and os.clock() - (leftover + delay)) or 0;
			elapsed = delay + leftover;
		end;
	end;

	--// connection starter
	local function connectTick()
		if lastTickConnection then return end;
		lastTickConnection = runService.Heartbeat:Connect(function(dt) tick(dt) end);
	end;

	local function disconnectTick()
		if lastTickConnection then
			pcall(function() lastTickConnection:Disconnect() end);
			lastTickConnection = nil;
		end;
	end;

	local api: any = {};

	function api.Play(self: any)
		if finished then
			finished = false;
			elapsed = 0;
			currentRepeatIndex = 0;
		end;
		playing = true;
		paused = false;
		if ignoreTimeScale then
			startClock = os.clock() - elapsed;
		end;
		connectTick();
	end;

	function api.Pause(self: any)
		if not playing or paused then return end;
		paused = true;
		if ignoreTimeScale then
			pausedAt = os.clock();
		end;
	end;

	function api.Resume(self: any)
		if not paused then return end;
		paused = false;
		if ignoreTimeScale and pausedAt then
			local now = os.clock();
			local pausedDuration = now - pausedAt;
			startClock = startClock + pausedDuration;
			pausedAt = nil;
		end;
	end;

	function api.Stop(self: any, jumpToEnd: boolean?)
		playing = false;
		paused = false;
		disconnectTick();
		if jumpToEnd then
			for k, _ in initialValues do
				currentValues[k] = targetValues[k] or currentValues[k];
			end;
			
			emitUpdate(1);
			if onComplete then pcall(onComplete) end;
		end;
	end;

	function api.Seek(self: any, timePosition: number)
		timePosition = math.max(0, timePosition or 0);
		
		if ignoreTimeScale then
			startClock = os.clock() - timePosition;
			elapsed = timePosition;
		else
			elapsed = timePosition;
		end;
		
		local localElapsed = elapsed - delay;
		local iteration = 0;
		if localElapsed > 0 then iteration = math.floor(localElapsed / duration) end;
		local iterTime = math.clamp((localElapsed - iteration * duration), 0, duration);
		local isReverseIteration = reverseOnRepeat and (iteration % 2 == 1);
		forward = not isReverseIteration;
		local alpha = computeAlphaFromElapsed(iterTime);
		
		for k, sv in initialValues do
			local tv = targetValues[k];
			if tv == nil then
				currentValues[k] = sv;
			else
				currentValues[k] = interpolate(sv, tv, alpha);
			end;
		end;
		
		emitUpdate(alpha);
	end;

	function api.IsPlaying(self: any): boolean
		return playing and not paused;
	end;

	function api.SetOnUpdate(self: any, fn: OnUpdateFn?)
		onUpdate = fn;
	end;

	function api.SetOnComplete(self: any, fn: OnCompleteFn?)
		onComplete = fn;
	end;

	function api.SetOptions(self: any, o: TweenOptions)
		options = o or options;
		duration = math.max(0.0001, options.Duration or duration);
		delay = math.max(0, options.Delay or delay);
		repeatCount = (options.RepeatCount == nil) and repeatCount or options.RepeatCount;
		reverseOnRepeat = options.Reverse == true;
		ignoreTimeScale = options.IgnoreTimeScale == true;
	end;

	function api.Chain(self: any, nextTween: any)
		chainedTween = nextTween;
	end;

	if options.AutoPlay then
		api.Play(api);
	end;

	return {
		Play = api.Play;
		Pause = api.Pause;
		Resume = api.Resume;
		Stop = api.Stop;
		Seek = api.Seek;
		IsPlaying = api.IsPlaying;
		SetOnUpdate = api.SetOnUpdate;
		SetOnComplete = api.SetOnComplete;
		SetOptions = api.SetOptions;
		Chain = api.Chain;
	};
end;


Library.Months = {
	[1] = "Jan", [2] = "Feb", [3] = "Mar", [4] = "Apr",
	[5] = "May", [6] = "Jun", [7] = "Jul", [8] = "Aug",
	[9] = "Sep", [10] = "Oct", [11] = "Nov", [12] = "Dec",
};


Library.Keys = Library.Struct({
	[Enum.KeyCode.LeftAlt] = 'LALT',
	[Enum.KeyCode.RightAlt] = 'RALT',
	[Enum.KeyCode.LeftControl] = 'LCTRL',
	[Enum.KeyCode.RightControl] = 'RCTRL',
	[Enum.KeyCode.LeftShift] = 'LSHIFT',
	[Enum.KeyCode.RightShift] = 'RSHIFT',
	[Enum.KeyCode.Underscore] = '_',
	[Enum.KeyCode.Minus] = '-',
	[Enum.KeyCode.Plus] = '+',
	[Enum.KeyCode.Period] = '.',
	[Enum.KeyCode.Slash] = '/',
	[Enum.KeyCode.BackSlash] = '\\',
	[Enum.KeyCode.Question] = '?',
	[Enum.UserInputType.MouseButton1] = 'MB1',
	[Enum.UserInputType.MouseButton2] = 'MB2',
	[Enum.UserInputType.MouseButton3] = 'MB3',
}, false, true);

Library.BlacklistedKeys = Library.Struct({
	Enum.KeyCode.W,
	Enum.KeyCode.A,
	Enum.KeyCode.S,
	Enum.KeyCode.D,
	Enum.UserInputType.MouseMovement
}, false, true);

Library.Menu = Library.Struct({
	Colors = Library.Struct({
		Background = Color3.fromRGB(30, 30, 30),
		Foreground = Color3.fromRGB(25, 25, 25),
		TabActive = Color3.fromRGB(30, 30, 30),
		Accent = Color3.fromRGB(123, 79, 144),
		Tab = Color3.fromRGB(25, 25, 25),
		Hex = "#724b84"
	}, false, false),
	
	Themes = Library.Struct({
		["Nocturnal"] = Library.Struct({
			["Background"] = Color3.fromRGB(30, 30, 30),
			["Foreground"] = Color3.fromRGB(25, 25, 25),
			["TabActive"] = Color3.fromRGB(30, 30, 30),
			["Accent"] = Color3.fromRGB(123, 79, 144),
			["Tab"] = Color3.fromRGB(25, 25, 25),
			["Hex"] = "#724b84"
		}, false, false),
		
		["Akiri"] = Library.Struct({
			["Background"] = Color3.fromRGB(25, 20, 50),
			["Foreground"] = Color3.fromRGB(35, 25, 70),
			["TabActive"] = Color3.fromRGB(35, 25, 70),
			["Accent"] = Color3.fromRGB(169, 110, 197),
			["Tab"] = Color3.fromRGB(25, 20, 50),
			["Hex"] = "#9861b8"
		}, false, false),
		
	}, false, false),
	
	Reference = nil,
	IsLoaded = false,
	CurrentTheme = "Nocturnal"
	
}, false, false);

Library.ApplyTheme = function(window: NocturnalWindow, theme: string): () -> ()
	assert(Library.Menu.IsLoaded, "[nocturnal] menu is not loaded");
	local theme = Library.Menu.Themes[theme];
	if not theme then return end;
	
	Library.Menu.Colors = theme;
	
	--// window
	window.Gui.BackgroundColor3 = Library.Menu.Colors.Background;
	window.Gui.Frame.BackgroundColor3 = Library.Menu.Colors.Foreground;
	
	local function onTab(): () -> ()
		for idx, tab in window.Gui.Frame.Tabs:GetChildren() do
			if not tab:IsA("Frame") then
				continue;
			end
			
			tab.BackgroundColor3 = Library.Menu.Colors.Tab;
		end
	end
	
	window.Gui.Frame.Tabs.ChildAdded:Connect(function()
		Library:CreateThread(onTab)
	end)
	
	window.Gui.DescendantAdded:Connect(function(c)
		Library:CreateThread(function()
			local function change(): ()
				if c.Parent and c.Parent:IsA"ScrollingFrame" then
					if not (c.Parent.Parent.Name == "Options") then
						c.BackgroundColor3 = Library.Menu.Colors.Background;
					end
				end

				if rawequal(c.BackgroundColor3, Library.Menu.Colors[Library.Menu.CurrentTheme].Background) then
					c.BackgroundColor3 = Library.Menu.Themes[theme].Background;
				end

				if rawequal(c.BackgroundColor3, Library.Menu.Colors[Library.Menu.CurrentTheme].Foreground) then
					c.BackgroundColor3 = Library.Menu.Themes[theme].Foreground;
				end
			end
			
			Library:CreateThread(change)
			
			c.Changed:Connect(function()
				Library:CreateThread(change)
			end)
		end)
	end)
	
	window.Gui.Frame.Contents.BackgroundColor3 = Library.Menu.Colors.Foreground;
	Library.Menu.CurrentTheme = theme;
end;

Library.Convert = function(color: Color3): () -> string
	assert(color, "[nocturnal] critical error; report to devs")
	return string.format("#%02X%02X%02X", color.R * 255, color.G * 255, color.B * 255);
end;

Library.Connections = Library.Struct({}, false, false);

Library.Flags = Library.Struct({}, false, false);
Library.Options = Library.Struct({}, false, false);

do
	local syn = (typeof(syn) == "table") and syn or nil;
	if type(request) == "function" then
		requestFunc = request;
	elseif syn and type(syn.request) == "function" then
		requestFunc = syn.request;
	else
		requestFunc = function(req: table)
			assert(req and req.Url, "Bad request table");
			local ok, res = pcall(function() return httpService:GetAsync(req.Url) end);
			if not ok then error("HttpService:GetAsync failed: " .. tostring(res)) end;
			return { Body = res };
		end;
	end;
end;

do
	if typeof(getsynasset) == "function" then
		getAssetFunc = getsynasset
	elseif typeof(getcustomasset) == "function" then
		getAssetFunc = getcustomasset
	else
		getAssetFunc = function(path: string) return path end
	end
end;

local function ensureFaceJson(fontName: string, assetId: string)
	local function read(path: string): string?
		if isfile and isfile(path) and readfile then
			local ok, res = pcall(function() return readfile(path) end)
			if ok then return res end
		end
		return nil
	end
	
	local facePath = (Library.Filesystem.base .. "/".. Library.Filesystem.fonts .. "/" .. fontName .. "Face.json")
	local existing = read(facePath)
	if existing then
		local ok, decoded = pcall(function() return httpService:JSONDecode(existing) end)
		if ok and type(decoded) == "table" and decoded.faces and decoded.faces[1] and decoded.faces[1].assetId == assetId then
			return
		end
	end
	
	local face = {
		name = fontName,
		faces = {
			{
				name = "Regular",
				weight = 300,
				style = "normal",
				assetId = assetId
			}
		}
	}
	
	local encoded = httpService:JSONEncode(face)
	writefile(facePath, encoded)
end

function Library:PreloadAssets(fontList: table?, licenseKey: string?)
	assert(licenseKey, "[nocturnal] unauthorized access.");
	
	local function downloadFont(fontName: string): (boolean, string?)
		local localPath = (Library.Filesystem.base .. "/" .. Library.Filesystem.fonts .. "/" .. fontName)
		
		if isfile and isfile(localPath) then
			return true, localPath
		end
		
		local url = (Library.url .. licenseKey .. "&file=" .. fontName)
		local ok, res = pcall(function() return requestFunc({ Url = url, Method = "GET" }) end)
		if not ok or not res then
			return false, tostring(res)
		end
		local body = res.Body or res.body
		if not body then return false, "no response body" end
		writefile(localPath, body)
		return true, localPath
	end
	
	if type(fontList) ~= "table" then return end
	
	--// mhm mhm mhm
	for _, v in fontList do
		if type(v) == "string" then
			local ok, pathOrErr = Library:CreateThread(downloadFont, v)
			
			if ok and pathOrErr then
				local asset = getAssetFunc(pathOrErr)
				ensureFaceJson(v, asset)
			else
				warn("Failed to download font '" .. v .. "': " .. tostring(pathOrErr))
			end
		end
	end
end

function Library:SetFont(fontName: string, label: TextLabel | TextBox | any)
	assert(type(fontName) == "string", "fontName must be a string");
	assert(label ~= nil, "label is required");

	local localPath = (Library.Filesystem.base .. "/".. Library.Filesystem.fonts .. "/" .. fontName);
	if not (isfile and isfile(localPath)) then
		return warn("[nocturnal] preload all fonts before loading;");
	end;

	local asset = getAssetFunc(localPath);
	ensureFaceJson(fontName, asset);

	local faceJsonPath = (Library.Filesystem.base .. "/".. Library.Filesystem.fonts .. "/" .. fontName .. "Face.json");
	local faceAsset = getAssetFunc(faceJsonPath);
	local ok, fontObj = pcall(function() return Font.new(faceAsset) end);
	if not ok or not fontObj then error("Failed to create Font from face json: " .. tostring(fontObj or "nil")) end;

	local suc, setErr = pcall(function() label.FontFace = fontObj end);
	if not suc then error("Failed to assign FontFace: " .. tostring(setErr)) end;
end;

--// If executor is identified, we'll just parent to CoreGui since it's far superior
local success, identifyexecutor = pcall(function() return identifyexecutor end)
if success and identifyexecutor then
	Library.Parent = Library:Get("CoreGui")
else
	Library.Parent = Library:GetPlayer() and Library:GetPlayer().PlayerGui or nil
end

function Library:createWindow(data: {}): () -> ()
	if Library.IsLoaded then return end;
	data = Library.Struct(data, false, false);
	
	--// api definitions
	local window = Library.Struct({
		Connections = Library.Struct({}, false, false),
		Watermarks = Library.Struct({}, false, false),
		Tabs = Library.Struct({}, false, false),
		List = nil,
		Gui = nil
	}, false, false);
	
	--// init dependencies
	Library:GetDependencies({
		"Window",
		"Section",
		"TabSection",
		"Tab",
		"Slider",
		"Toggle",
		"Dropdown",
		"Button",
		"Watermark"
	});
	
	--// show
	local screenGui: ScreenGui = Instance.new("ScreenGui", Library.Parent)
	screenGui.IgnoreGuiInset = true
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	
	window.Gui = ref:FindFirstChild("Window"):Clone();
	window.Gui.Parent = screenGui;
	window.Gui.pre.Text = data.Text or string.format('nocturnal<font color="%s">.vip</font>', Library.Menu.Colors.Hex);
	
	Library.Drag(window.Gui, {}):Enable()
	Library.Resize(window.Gui, window.Gui.resize)
	
	--// fade in/out
	window._OriginalTransparency = window._OriginalTransparency or {};
	Library.Flags["n_cMenuKey"] = data.MenuKey or Enum.KeyCode.RightShift;
	
	local function collectProperties(element)
		local propsStart = {};
		local found = false;

		local ok, val;
		local propNames = {"Transparency", "BackgroundTransparency", "TextTransparency", "ImageTransparency", "TextStrokeTransparency"};

		for _, prop in propNames do
			ok, val = pcall(function() return element[prop] end);
			if ok then
				propsStart[prop] = val;
				found = true;
			end
		end

		return propsStart, found;
	end;

	local function storeOriginalTransparency()
		for _, element in window.Gui:GetDescendants() do
			if not window._OriginalTransparency[element] then
				local propsStart, found = collectProperties(element)
				if found then
					window._OriginalTransparency[element] = propsStart
				end
			end
		end
	end

	storeOriginalTransparency()

	local success = pcall(function() 
		local mouse = game:GetService"Players".LocalPlayer:GetMouse()

		Library.cursor = Drawing.new('Triangle');
        Library.cursor.Thickness = 1;
        Library.cursor.Filled = true;
        Library.cursor.Visible = true;

        Library.cursor2 = Drawing.new('Triangle');
        Library.cursor2.Thickness = 1;
      	Library.cursor2.Filled = false;
        Library.cursor2.Color = Color3.new(0, 0, 0);
        Library.cursor2.Visible = true;

       --[[ 
	   	Library.cursor = Drawing.new("Image")
        Library.cursor.Data = game:HttpGet("https://github.com/Storm99999/Storm99999.github.io/blob/main/ArrowFarCursor.png?raw=true")
        Library.cursor.Size = Vector2.new(64, 64)
        Library.cursor.Visible = userInputService.MouseEnabled
        Library.cursor.Rounding = 0
        Library.cursor.Position = Vector2.new(mouse.X - 32, mouse.Y + 6) 
		]]
    end)

    if success and Library.cursor then
        userInputService.InputChanged:Connect(function(input)
            if userInputService.MouseEnabled then
                if input.UserInputType == Enum.UserInputType.MouseMovement then
                    --Library.cursor.Position = Vector2.new(input.Position.X - 32, input.Position.Y + 7)
					local mPos = userInputService:GetMouseLocation();

                    Library.cursor.Color = Library.Menu.Colors.Accent;

                    Library.cursor.PointA = Vector2.new(mPos.X, mPos.Y);
                    Library.cursor.PointB = Vector2.new(mPos.X + 16, mPos.Y + 6);
                    Library.cursor.PointC = Vector2.new(mPos.X + 6, mPos.Y + 16);

                    Library.cursor2.PointA = Library.cursor.PointA;
                    Library.cursor2.PointB = Library.cursor.PointB;
                    Library.cursor2.PointC = Library.cursor.PointC;

                end
            end
        end)
        getgenv().aeaeae = true
        game:GetService("RunService").RenderStepped:Connect(function()
            userInputService.OverrideMouseIconBehavior = Enum.OverrideMouseIconBehavior.ForceHide
            Library.cursor.Visible = getgenv().aeaeae and userInputService.MouseEnabled and (userInputService.MouseIconEnabled or game:GetService("GuiService").MenuIsOpen) or window.Gui.Visible;
			Library.cursor2.Visible = getgenv().aeaeae and userInputService.MouseEnabled and (userInputService.MouseIconEnabled or game:GetService("GuiService").MenuIsOpen) or window.Gui.Visible;
        end)
    elseif not success and Library.cursor then
        Library.cursor:Remove()
		Library.cursor2:Remove()
    end

	table.insert(window.Connections, userInputService.InputBegan:Connect(function(input, gpe)
		if gpe then return end;
		if input.KeyCode == Library.Flags["n_cMenuKey"] then
			local visible = window.Gui.Visible;
			local tweens = {};

			for _, element in window.Gui:GetDescendants() do
				local originalProps = window._OriginalTransparency[element];
				if not originalProps then continue end;

				local propsStart, found = collectProperties(element);
				if not found then continue end;

				local propsTarget = {};

				if visible then
					for k in propsStart do
						propsTarget[k] = 1
					end
				else
					for k, v in originalProps do
						propsTarget[k] = v
					end
					propsStart = {}
					for k in originalProps do
						propsStart[k] = element[k]
					end
				end


				local tweenHandle = Library:CreateTween(propsStart, propsTarget, {
					Duration = 0.25;
					Easing = "Linear";
					Direction = "In";
					AutoPlay = false;
				});

				tweenHandle:SetOnUpdate(function(newProps)
					for prop, val in newProps do
						val = math.clamp(val, 0, 1)
						pcall(function() element[prop] = val end)
					end
				end);

				table.insert(tweens, tweenHandle)
			end

			local completedCount = 0;
			local totalTweens = #tweens;

			for _, tween in tweens do
				tween:SetOnComplete(function()
					completedCount = completedCount + 1
					if completedCount >= totalTweens then
						if visible then
							window.Gui.Visible = false
						end
						
						window.Gui.pre.TextTransparency = 0
					end
				end)
				
				tween:Play()
				window.Gui.pre.TextTransparency = 0

			end

			if not visible then
				window.Gui.Visible = true
				window.Gui.pre.TextTransparency = 0
			end
		end
	end))
	
	function window:createPreview(data: { [string]: any }): () -> ()
		assert(window.Gui, "[nocturnal] gui not initialized yet; init preview later, not now");
		
		if screenGui:FindFirstChild("Preview") then return end;
		local preview: Frame = ref:FindFirstChild("Preview"):Clone();

		local cam: Camera = Instance.new("Camera")
		preview.Visible = true;
		preview.Parent = window.Gui;
		preview.Frame.ViewportFrame.CurrentCamera = cam;

		local rig;
		rig = preview.Frame.ViewportFrame.Rig;
		assert(rig, "[nocturnal] rig doesn't exist?")
		local offset = Vector3.new(0, 1.75, 0)
		cam.CFrame = CFrame.new(rig.PrimaryPart.Position + Vector3.new(0, 0, 10), rig.PrimaryPart.Position)

		rig:SetPrimaryPartCFrame(rig.PrimaryPart.CFrame + offset)
		
		--// yeah this'll work for now
		local btn: ImageButton = preview.ImageButton
		btn.MouseButton1Click:Connect(function()
			preview.Visible = not preview.Visible
		end)

	end

	function window:createBindList(data: { [string]: any }): () -> ()
		if screenGui:FindFirstChild("BindList") then return end;

		local list: Frame = ref:FindFirstChild("BindList"):Clone();
		list.Parent = screenGui;
		
		window.List = list;
	end;
	
	function window:createBindEntry(data: { [string]: any }): () -> ()
		if not data then return end;
		if not screenGui:FindFirstChild("BindList") then return end;
		if screenGui.BindList:FindFirstChild(data.Feature or "am yisrael chaiiiii") then return end
		data = Library.Struct(data, false, false);
		
		--// checks
		assert(data.Key, "[nocturnal.vip @ bindlist] invalid key")
		assert(data.Feature, "[nocturnal.vip @ bindlist] invalid feature")
		
		--// pass, ok?
		local key: string = data.Key;
		local feature: string = data.Feature;
		
		local label = screenGui:FindFirstChild("BindList").Sample:Clone();
		label.Text = string.format('<font color="%s">[%s] %s (%s)</font>', Library.Menu.Colors.Hex, key, feature, data.Mode or "Toggle");
		label.Name = feature;
		label.Parent = screenGui.BindList;
		
		screenGui.BindList.Size += UDim2.new(0, 0, 0.025, 0); --// scales the list to fit the new entry
	end;
	
	function window:updateBindEntry(data: { [string]: any }): () -> ()
		if not data then return end;
		data = Library.Struct(data, false, false);
		
		--// checks
		if not screenGui:FindFirstChild"BindList" then return end;
		if not screenGui.BindList:FindFirstChild(data.Feature) then return end
		
		local newState = data.State;
		if not newState then
			--screenGui.BindList:FindFirstChild(data.Feature).Visible = false;
			--screenGui.BindList.Size -= UDim2.new(0, 0, 0.02, 0);
			screenGui.BindList:FindFirstChild(data.Feature).Visible = true;
			screenGui.BindList:FindFirstChild(data.Feature).Text = string.format('<font color="#FFFFFF">[%s] %s (%s)</font>', data.Key, data.Feature, data.Mode or "Toggle")
		else
			screenGui.BindList:FindFirstChild(data.Feature).Visible = true;
			screenGui.BindList:FindFirstChild(data.Feature).Text = string.format('<font color="%s">[%s] %s (%s)</font>', Library.Menu.Colors.Hex, data.Key, data.Feature, data.Mode or "Toggle")
			--screenGui.BindList.Size += UDim2.new(0, 0, 0.02, 0);
			
		end;
	end;
	
	function window:toggleBindList(state: boolean): () -> ()
		if screenGui:FindFirstChild("BindList") then
			screenGui.BindList.Visible = state;
		end;
	end;
	
	function window:createWatermark(data: { [string]: any }): () -> ()
		if not data then return end;
		data = Library.Struct(data, false, false);
		
		--// checks
		if screenGui:FindFirstChild("Watermark") then return end;
		
		local watermark: Frame = ref:FindFirstChild("Watermark"):Clone();
		watermark.Parent = screenGui;

		local otherMarks = game:GetObjects("rbxassetid://119950076389168")[1]
		otherMarks.Parent = screenGui

		for idx, wm in otherMarks:GetChildren() do
			if not wm:IsA"Frame" then continue end
			wm.Visible = false
			wm.Parent = wm.Parent.Parent
		end

		otherMarks = screenGui --// weird quickfix, please don't judge me on this.
		
		local baseText: string = data.Text or string.format('nocturnal<font color="%s">.vip</font>', Library.Menu.Colors.Hex);
		local preLabel = watermark:FindFirstChild("Frame") and watermark.Frame:FindFirstChild("pre");
		
		if not preLabel or not preLabel:IsA("TextLabel") then
			if watermark:IsA("TextLabel") then
				preLabel = watermark;
			else
				return function()
					if watermark and watermark.Parent then watermark:Destroy() end;
				end;
			end;
		end;

		--// initial displays
		local initialFPS, initialPing, initialDate = 0, Library:getPingMs(), Library:formatDate();

		preLabel.RichText = true;
		preLabel.Text = Library:formatWatermarkText(baseText, initialFPS, initialPing, initialDate);

		local emaFPS: number = 60; --// starting EMA
		local smoothing: number = 0.12; --// 0..1 (higher = more responsive)
		local updateInterval: number = 0.1; --// seconds between text updates
		local accumulator: number = 0;

		--// connection
		local conn: RBXScriptConnection?
		conn = runService.RenderStepped:Connect(function(deltaTime: number)
			local instantFPS = 0;
			if type(deltaTime) == "number" and deltaTime > 0 then
				instantFPS = 1 / deltaTime;
			end;

			emaFPS = Library:smoothFPS(emaFPS, instantFPS, smoothing);

			accumulator = accumulator + (type(deltaTime) == "number" and deltaTime or 0);
			if accumulator >= updateInterval then
				accumulator = accumulator - updateInterval;

				local displayFPS = math.floor(emaFPS + 0.5);
				local pingMs = Library:getPingMs();
				local dateStr = Library:formatDate();
				
				if Library.Flags["n_useMenuName"] then
					baseText = Library.Flags["n_name"] .. string.format('<font color="%s">.vip</font>', Library.Menu.Colors.Hex);
				else
					baseText = data.Text or string.format('nocturnal<font color="%s">.vip</font>', Library.Menu.Colors.Hex);
				end
				
				preLabel.Text = Library:formatWatermarkText(baseText, displayFPS, pingMs, dateStr);
			end;

			local currentWatermark = getgenv().noct_watermark
			if currentWatermark == 'Default' then
				watermark.Visible = true
				otherMarks.NocturnalV2.Visible = false
				otherMarks.atlanta.Visible = false
				otherMarks.nocturnalsense.Visible = false
			end

			if currentWatermark == 'NocturnalV2' then
				watermark.Visible = false
				otherMarks.NocturnalV2.Visible = true
				otherMarks.atlanta.Visible = false
				otherMarks.nocturnalsense.Visible = false
				otherMarks.NocturnalV2.userlogin.Frame.TextLabel.Text = string.format("^_^ | %s | uid %s", Library.UserProfile.name, tostring(Library.UserProfile.uid))
			end

			if currentWatermark == 'atlanta' then
				watermark.Visible = false
				otherMarks.NocturnalV2.Visible = false
				otherMarks.atlanta.Visible = true
				otherMarks.nocturnalsense.Visible = false
				otherMarks.atlanta.TextLabel.Text = string.format("^_^ | %s | %s", Library.UserProfile.name, tostring(Library.UserProfile.uid))
			end

			if currentWatermark == 'nocturnalsense' then
				watermark.Visible = false
				otherMarks.NocturnalV2.Visible = false
				otherMarks.atlanta.Visible = false
				otherMarks.nocturnalsense.Visible = true
				otherMarks.nocturnalsense.Inner.Data.Text = string.format("nocturnalsense | uid %s | %s ms", tostring(Library.UserProfile.uid), tostring(Library:getPingMs()))
			end

			otherMarks.atlanta.TextLabel.FontFace = Library.Font;
			--otherMarks.atlanta.u.TextLabel.FontFace = Library.Font;
			--otherMarks.atlanta.u.TextSize = 10 -- TODO: FIX THE FUCKING SIZING.
		end);

		if conn then
			table.insert(Library.Connections, conn);
		end;

		--// return cleanup function
		return function()
			if conn and conn.Disconnect then
				pcall(function() conn:Disconnect() end);
			end;

			for i = #Library.Connections, 1, -1 do
				if Library.Connections[i] == conn then
					table.remove(Library.Connections, i)
					break;
				end;
			end;

			--// destroy watermark gui
			if watermark and watermark.Parent then
				pcall(function() watermark:Destroy() end);
			end;
		end;
	end;
	
	function window:createTab(data: { [string]: any }): () -> ()
		if not data then return end;
		data = Library.Struct(data, false, true)
		local tabBtn: Frame = ref:FindFirstChild("Tab"):Clone();
		local tab: {} = Library.Struct({
			Sections = Library.Struct({}, false, false)
		}, false, false)
		
		tabBtn.Parent = window.Gui.Frame.Tabs;
		tabBtn.pre.Text = data.Text or "Tab";
		tabBtn.Name = data.Text or "Tab";
		local isSmall: boolean = data.Small or false;
		tabBtn.Size = isSmall and UDim2.new(0.18, 0, 1, 0) or tabBtn.Size;
		
		function tab:selectTab(data: { [string]: any }): () -> ()
			if not data then return end;
			data = Library.Struct(data, false, false);
			assert(data.Tab, "[nocturnal] invalid tab name");

			for idx, tab in window.Gui.Frame.Tabs:GetChildren() do
				if not tab:IsA("Frame") then continue end;
				tab.BackgroundColor3 = Library.Menu.Colors.Tab;
			end

			for idx, section in window.Gui.Frame.Contents:GetChildren() do
				if not section:IsA("Frame") then continue end;
				section.Visible = false;
			end;

			window.Gui.Frame.Tabs[data.Tab].BackgroundColor3 = Library.Menu.Colors.TabActive;
			window.Gui.Frame.Contents[data.Tab].Visible = true;
		end;

		table.insert(window.Connections, tabBtn.TextButton.MouseButton1Click:Connect(function()
			return tab:selectTab({ Tab = tabBtn.Name });
		end));
		
		table.insert(window.Tabs, tabBtn);
		
		local tabSectionFrame: Frame = ref:FindFirstChild("TabSection"):Clone();
		tabSectionFrame.Name = data.Text or "Section";
		tabSectionFrame.Parent = window.Gui.Frame.Contents
		tabSectionFrame.Visible = false
		
		local zIndex: number = 1
		local Drop_zIndex: number = 999999

		
		function tab:createSettings(data: { [string]: any }): () -> ()
			local settings = ref:FindFirstChild("Settings"):Clone()
			settings.Parent = tabSectionFrame
			
			--// remove base
			tabSectionFrame["L"]:Destroy()
			tabSectionFrame["R"]:Destroy()
			
			
			local votekickButton, spectateButton, statusDropdown, playerAvatar, playerSample,
				configLoad, configSave, configDelete, configDropdown,
				menuName, cMenuKey, cMenuName, cMenuAccent =
					settings:FindFirstChild("Votekick", true),
					settings:FindFirstChild("Spectate", true),
					settings:FindFirstChild("Status", true),
					settings:FindFirstChild("ImageLabel", true),
					settings:FindFirstChild("Sample", true),
					settings:FindFirstChild("ld", true),
					settings:FindFirstChild("sv", true),
					settings:FindFirstChild("dl", true),
					settings:FindFirstChild("cfgs", true),
					settings:FindFirstChild("menuName", true),
					settings:FindFirstChild("cstmMenuKey", true),
					settings:FindFirstChild("cMenuName", true),
					settings:FindFirstChild("cMenuAccent", true);

			
			--// player list
			local function getTeamColor(p: Player): () -> Color3
				return rawequal(p.PlayerStates.Team and p.PlayerStates.Team.Value or "T", "CT") and Color3.fromRGB(85, 170, 255) or Color3.fromRGB(255, 214, 110);
			end;
			
			local function onPlayer(p: Player): () -> Player
				if not playerSample.Parent:FindFirstChild(p.Name) then
					local newSample = playerSample:Clone();
					newSample.Name = p.Name;
					newSample.Parent = playerSample.Parent;
					newSample.Frame.name.Text = p.Name;
					newSample.Frame.team.Text = p.PlayerStates.Team and p.PlayerStates.Team.Value or "Terrorists";
					newSample.Frame.team.TextColor3 = getTeamColor(p);
					newSample.Frame.status.Text = "None";
					newSample.Visible = true;
					
					--// store for later
					Library.PlayerArchive[p.Name] = "Neutral";
					
					table.insert(window.Connections, newSample.TextButton.MouseButton1Click:Connect(function()
						local avatar;
						local name;
						name = playerAvatar.name;
						avatar = string.format("https://www.roblox.com/headshot-thumbnail/image?userId=%s&width=420&height=420&format=png", tostring(p.UserId));
						
						playerAvatar.Image = avatar;
						name.Text = p.Name;
					end));
				end;
			end;
			
			for idx, player in players:GetPlayers() do
				task.spawn(function() pcall(onPlayer, player) end);
			end;
			
			table.insert(window.Connections, players.PlayerAdded:Connect(function(p)
				task.spawn(function() pcall(onPlayer, p) end);
			end))
			
			--// votekick button / playerlist
			task.spawn(function()
				do
					local uiGradient: UIGradient = votekickButton.UIGradient
					local currentTween: any = nil
					local uiStroke: UIStroke

					table.insert(window.Connections, votekickButton.TextButton.MouseButton1Click:Connect(function()
						local player = players:FindFirstChild(playerAvatar.name.Text) or nil;
						assert(player, "[nocturnal] critical error; report to devs");

						--// pseudo code, i dont actually know the remote path
						replicatedStorage.Votekick:FireServer({ player });

						--// effects
						for _, child in votekickButton:GetChildren() do
							if child:IsA("UIStroke") and child.BorderStrokePosition == Enum.BorderStrokePosition.Outer then
								uiStroke = child
								break
							end
						end

						if not uiStroke then return end

						local originalColor = uiStroke.Color
						local accentColor = Library.Menu.Colors.Accent

						local tween = Library:CreateTween(
							{ Color = originalColor },
							{ Color = accentColor },
							{
								Duration = 0.05,
								Easing = "Quad",
								Direction = "InOut",
								AutoPlay = false
							}
						)

						tween:SetOnUpdate(function(currentValues)
							uiStroke.Color = currentValues.Color
						end)

						tween:SetOnComplete(function()
							local tweenBack = Library:CreateTween(
								{ Color = accentColor },
								{ Color = originalColor },
								{
									Duration = 0.05,
									Easing = "Quad",
									Direction = "InOut",
									AutoPlay = false
								}
							)
							tweenBack:SetOnUpdate(function(currentValues)
								uiStroke.Color = currentValues.Color;
							end)
							tweenBack:Play();
						end);

						tween:Play();
					end))
					
					local function tweenRotation(targetRotation)
						if currentTween then
							currentTween:Stop(true)
						end

						local tween = Library:CreateTween(
							{ Rotation = uiGradient.Rotation },
							{ Rotation = targetRotation },
							{
								Duration = 0.16,
								Easing = "Quad",
								Direction = "InOut",
								AutoPlay = false
							}
						)

						currentTween = tween

						tween:SetOnUpdate(function(currentValues)
							uiGradient.Rotation = currentValues.Rotation
						end)

						tween:Play()
					end

					table.insert(window.Connections, votekickButton.TextButton.MouseEnter:Connect(function()
						tweenRotation(90)
					end))

					table.insert(window.Connections, votekickButton.TextButton.MouseLeave:Connect(function()
						tweenRotation(-90)
					end))
				end;
			end);
			
			--// spectate button / playerlist
			task.spawn(function()
				do
					local uiGradient: UIGradient = spectateButton.UIGradient
					local currentTween: any = nil
					local uiStroke: UIStroke

					table.insert(window.Connections, spectateButton.TextButton.MouseButton1Click:Connect(function()
						local player = players[playerAvatar.name.Text];
						assert(player, "[nocturnal] critical error; report to devs");

						--// pseudo code, i dont actually know the remote path
						replicatedStorage.Spectate:FireServer({ player });

						--// effects
						for _, child in spectateButton:GetChildren() do
							if child:IsA("UIStroke") and child.BorderStrokePosition == Enum.BorderStrokePosition.Outer then
								uiStroke = child
								break
							end
						end

						if not uiStroke then return end

						local originalColor = uiStroke.Color
						local accentColor = Library.Menu.Colors.Accent

						local tween = Library:CreateTween(
							{ Color = originalColor },
							{ Color = accentColor },
							{
								Duration = 0.05,
								Easing = "Quad",
								Direction = "InOut",
								AutoPlay = false
							}
						)

						tween:SetOnUpdate(function(currentValues)
							uiStroke.Color = currentValues.Color
						end)

						tween:SetOnComplete(function()
							local tweenBack = Library:CreateTween(
								{ Color = accentColor },
								{ Color = originalColor },
								{
									Duration = 0.05,
									Easing = "Quad",
									Direction = "InOut",
									AutoPlay = false
								}
							)
							tweenBack:SetOnUpdate(function(currentValues)
								uiStroke.Color = currentValues.Color;
							end)
							tweenBack:Play();
						end);

						tween:Play();
					end))

					local function tweenRotation(targetRotation)
						if currentTween then
							currentTween:Stop(true)
						end

						local tween = Library:CreateTween(
							{ Rotation = uiGradient.Rotation },
							{ Rotation = targetRotation },
							{
								Duration = 0.16,
								Easing = "Quad",
								Direction = "InOut",
								AutoPlay = false
							}
						)

						currentTween = tween

						tween:SetOnUpdate(function(currentValues)
							uiGradient.Rotation = currentValues.Rotation
						end)

						tween:Play()
					end

					table.insert(window.Connections, spectateButton.TextButton.MouseEnter:Connect(function()
						tweenRotation(90)
					end))

					table.insert(window.Connections, spectateButton.TextButton.MouseLeave:Connect(function()
						tweenRotation(-90)
					end))
				end;
			end);
			
			--// status dropdown / playerlist
			task.spawn(function()
				do
					--// this does nothing for now
					--[[
					local frame: Frame = Library.PlayerArchive[playerAvatar.name.Text] or nil;
					assert(frame, "[nocturnal] critical error; report to devs");
					assert(frame.status, "[nocturnal] critical error; report to devs");]]
					
					--// hover effects
					local uiStroke: UIStroke = statusDropdown.bg.main.outer;
					local button: TextButton = statusDropdown.bg.main.TextButton

					table.insert(window.Connections, button.MouseEnter:Connect(function()
						local tween = Library:CreateTween(
							{ Color = Color3.fromRGB() },
							{ Color = Library.Menu.Colors.Accent },
							{
								Duration = 0.05,
								Easing = "Quad",
								Direction = "InOut",
								AutoPlay = false
							}
						)

						tween:SetOnUpdate(function(currentValues)
							uiStroke.Color = currentValues.Color
						end)

						tween:Play();
					end))

					table.insert(window.Connections, button.MouseLeave:Connect(function()
						local tween = Library:CreateTween(
							{ Color = Library.Menu.Colors.Accent },
							{ Color = Color3.fromRGB() },
							{
								Duration = 0.05,
								Easing = "Quad",
								Direction = "InOut",
								AutoPlay = false
							}
						)

						tween:SetOnUpdate(function(currentValues)
							uiStroke.Color = currentValues.Color
						end)

						tween:Play();
					end));
					
					
					do
						--// dropdown
						local sample: Frame = statusDropdown.Options.ScrollingFrame.main:Clone();

						for idx, option in { 'Neutral', 'Friendly', 'Enemy' } do
							local opt: Frame = sample:Clone()
							opt.TextLabel.Text = option
							opt.Name = option
							opt.Visible = true
							opt.LayoutOrder = idx
							opt.Parent = statusDropdown.Options.ScrollingFrame
							opt.TextButton.MouseButton1Click:Connect(function()
								statusDropdown.bg.main.TextLabel.Text = option;
								statusDropdown.Options.Visible = false;
								statusDropdown.bg.ImageLabel.Rotation = 0;

								Library:CreateThread(function()
									local playa: Player = game:GetService"Players":FindFirstChild(playerAvatar.name.Text);
									if playa and Library.PlayerArchive[playa.Name] then
										Library.PlayerArchive[playa.Name] = option;
										print(playa.Name, 'is now', Library.PlayerArchive[playa.Name])
									else
										warn('player not found')
										print(playerAvatar.name.Text)
									end
								end)
							end)
						end;
					end;
					
					table.insert(window.Connections, button.MouseButton1Click:Connect(function()
						statusDropdown.Options.Visible = not statusDropdown.Options.Visible;
						statusDropdown.bg.ImageLabel.Rotation = statusDropdown.Options.Visible and 180 or 0 ;
					end))
				end;
			end);
			
			--// menu settings
			task.spawn(function()
				--// custom menu name toggle
				do
					local toggle = cMenuName;
					Library.Flags["n_useMenuName"] = false;
					
					table.insert(window.Connections, toggle.TextButton.MouseEnter:Connect(function()
						local uiStroke: UIStroke = toggle.Frame.outer;

						local tween = Library:CreateTween(
							{ Color = Color3.fromRGB() },
							{ Color = Library.Menu.Colors.Accent },
							{
								Duration = 0.05,
								Easing = "Quad",
								Direction = "InOut",
								AutoPlay = false
							}
						)

						tween:SetOnUpdate(function(currentValues)
							uiStroke.Color = currentValues.Color
						end)

						tween:Play();
					end))

					table.insert(window.Connections, toggle.TextButton.MouseLeave:Connect(function()
						local uiStroke: UIStroke = toggle.Frame.outer;

						local tween = Library:CreateTween(
							{ Color = Library.Menu.Colors.Accent },
							{ Color = Color3.fromRGB() },
							{
								Duration = 0.05,
								Easing = "Quad",
								Direction = "InOut",
								AutoPlay = false
							}
						)

						tween:SetOnUpdate(function(currentValues)
							uiStroke.Color = currentValues.Color
						end)

						tween:Play();
					end))

					local function updateState(): () -> () -> nil 
						local value: boolean = Library.Flags["n_useMenuName"]

						value = not value
						Library.Flags["n_useMenuName"] = value

						if value then
							toggle.Frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
							toggle.Frame.Disabled.Enabled = false
							toggle.Frame.Enabled.Enabled = true
						else
							toggle.Frame.BackgroundColor3 = Color3.fromRGB(27, 25, 27)
							toggle.Frame.Disabled.Enabled = true
							toggle.Frame.Enabled.Enabled = false
						end

						if data.Callback then
							task.spawn(data.Callback, value)
						end;
					end;

					local function getState(): () -> () -> nil 
						return Library.Flags["n_useMenuName"] or false
					end;

					table.insert(window.Connections, toggle.TextButton.MouseButton1Click:Connect(function()
						updateState()
					end))
					
					--// textbox
					Library.Flags["n_name"] = "nocturnal";
					menuName.Frame.pw.Text = Library.Flags["n_name"] or "nocturnal";

					--// hover effects
					local uiStroke: UIStroke = menuName.Frame.pw.outer;
					local button: TextButton = menuName.Frame.pw;

					table.insert(window.Connections, button.MouseEnter:Connect(function()
						local tween = Library:CreateTween(
							{ Color = Color3.fromRGB() },
							{ Color = Library.Menu.Colors.Accent },
							{
								Duration = 0.05,
								Easing = "Quad",
								Direction = "InOut",
								AutoPlay = false
							}
						)

						tween:SetOnUpdate(function(currentValues)
							uiStroke.Color = currentValues.Color
						end)

						tween:Play();
					end));

					table.insert(window.Connections, button.MouseLeave:Connect(function()
						local tween = Library:CreateTween(
							{ Color = Library.Menu.Colors.Accent },
							{ Color = Color3.fromRGB() },
							{
								Duration = 0.05,
								Easing = "Quad",
								Direction = "InOut",
								AutoPlay = false
							}
						)

						tween:SetOnUpdate(function(currentValues)
							uiStroke.Color = currentValues.Color
						end)

						tween:Play();
					end));

					table.insert(window.Connections, button.FocusLost:Connect(function()
						Library.Flags["n_name"] = button.Text;
					end));
				end;
				
				do
					local toggle = cMenuAccent;
					Library.Flags["n_accent"] = false;

					table.insert(window.Connections, toggle.TextButton.MouseEnter:Connect(function()
						local uiStroke: UIStroke = toggle.Frame.outer;

						local tween = Library:CreateTween(
							{ Color = Color3.fromRGB() },
							{ Color = Library.Menu.Colors.Accent },
							{
								Duration = 0.05,
								Easing = "Quad",
								Direction = "InOut",
								AutoPlay = false
							}
						)

						tween:SetOnUpdate(function(currentValues)
							uiStroke.Color = currentValues.Color
						end)

						tween:Play();
					end))

					table.insert(window.Connections, toggle.TextButton.MouseLeave:Connect(function()
						local uiStroke: UIStroke = toggle.Frame.outer;

						local tween = Library:CreateTween(
							{ Color = Library.Menu.Colors.Accent },
							{ Color = Color3.fromRGB() },
							{
								Duration = 0.05,
								Easing = "Quad",
								Direction = "InOut",
								AutoPlay = false
							}
						)

						tween:SetOnUpdate(function(currentValues)
							uiStroke.Color = currentValues.Color
						end)

						tween:Play();
					end))

					local function updateState(): () -> () -> nil 
						local value: boolean = Library.Flags["n_accent"]

						value = not value
						Library.Flags["n_useMenuKey"] = value

						if value then
							toggle.Frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
							toggle.Frame.Disabled.Enabled = false
							toggle.Frame.Enabled.Enabled = true
						else
							toggle.Frame.BackgroundColor3 = Color3.fromRGB(27, 25, 27)
							toggle.Frame.Disabled.Enabled = true
							toggle.Frame.Enabled.Enabled = false
						end


					end;

					local function getState(): () -> () -> nil 
						return Library.Flags["n_accent"] or false
					end;

					table.insert(window.Connections, toggle.TextButton.MouseButton1Click:Connect(function()
						updateState()
					end));
					
					--// custom colorpicker
					local Colorpicker: Frame = toggle.Colorpicker;
					Colorpicker.Visible = true;
					Colorpicker.Parent.ZIndex += 1 --// weird

					local colorpicker = Instance.new("Frame")
					local mid = Instance.new("Frame")
					local front = Instance.new("Frame")
					local button2 = Instance.new("TextButton")
					local colorFrame = Instance.new("Frame")
					local colorFrame_2 = Instance.new("Frame")
					local hueframe = Instance.new("Frame")
					local main = Instance.new("Frame")
					local hue = Instance.new("ImageLabel")
					local pickerframe = Instance.new("Frame")
					local main_2 = Instance.new("Frame")
					local picker2 = Instance.new("ImageLabel")
					local clr = Instance.new("Frame")
					local copy = Instance.new("TextButton")




					button2.Name = "button2"
					button2.Parent = Colorpicker
					button2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					button2.BackgroundTransparency = 1.000
					button2.Size = UDim2.new(1, 0, 1, 0)
					button2.Text = ""
					button2.Font = Enum.Font.SourceSans
					button2.TextColor3 = Color3.fromRGB(0, 0, 0)
					button2.TextSize = 14.000

					colorFrame.Name = "colorFrame"
					colorFrame.Parent = toggle
					colorFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
					colorFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
					colorFrame.BorderSizePixel = 2
					colorFrame.Position = UDim2.new(0.101092957, 0, 0.75, 0)
					colorFrame.Size = UDim2.new(0, 137, 0, 128)
					colorFrame.Visible = false
					colorFrame.ZIndex = 685486548

					colorFrame_2.Name = "colorFrame"
					colorFrame_2.Parent = colorFrame
					colorFrame_2.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
					colorFrame_2.BorderColor3 = Color3.fromRGB(60, 60, 60)
					colorFrame_2.Size = UDim2.new(1, 0, 1, 0)

					hueframe.Name = "hueframe"
					hueframe.Parent = colorFrame_2
					hueframe.Parent = colorFrame_2
					hueframe.BackgroundColor3 = Color3.fromRGB(34, 34, 34)
					hueframe.BorderColor3 = Color3.fromRGB(60, 60, 60)
					hueframe.BorderSizePixel = 2
					hueframe.Position = UDim2.new(-0.0930000022, 18, -0.0599999987, 30)
					hueframe.Size = UDim2.new(0, 100, 0, 100)

					main.Name = "main"
					main.Parent = hueframe
					main.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
					main.BorderColor3 = Color3.fromRGB(0, 0, 0)
					main.Size = UDim2.new(0, 100, 0, 100)
					main.ZIndex = 8677777777777777

					picker2.Name = "picker"
					picker2.Parent = main
					picker2.BackgroundColor3 = Color3.fromRGB(232, 0, 255)
					picker2.BorderColor3 = Color3.fromRGB(0, 0, 0)
					picker2.BorderSizePixel = 0
					picker2.Size = UDim2.new(0, 100, 0, 100)
					picker2.ZIndex = 687678678
					picker2.Image = "rbxassetid://2615689005"

					pickerframe.Name = "pickerframe"
					pickerframe.Parent = colorFrame
					pickerframe.BackgroundColor3 = Color3.fromRGB(34, 34, 34)
					pickerframe.BorderColor3 = Color3.fromRGB(60, 60, 60)
					pickerframe.BorderSizePixel = 2
					pickerframe.Position = UDim2.new(0.711000025, 14, -0.0599999987, 30)
					pickerframe.Size = UDim2.new(0, 20, 0, 100)

					main_2.Name = "main"
					main_2.Parent = pickerframe
					main_2.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
					main_2.BorderColor3 = Color3.fromRGB(0, 0, 0)
					main_2.Size = UDim2.new(0, 20, 0, 100)
					main_2.ZIndex = 6

					hue.Name = "hue"
					hue.Parent = main_2
					hue.BackgroundColor3 = Color3.fromRGB(255, 0, 178)
					hue.BorderColor3 = Color3.fromRGB(0, 0, 0)
					hue.BorderSizePixel = 0
					hue.Size = UDim2.new(0, 20, 0, 100)
					hue.ZIndex = 104
					hue.Image = "rbxassetid://2615692420"

					clr.Name = "clr"
					clr.Parent = colorFrame
					clr.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
					clr.BackgroundTransparency = 1.000
					clr.BorderColor3 = Color3.fromRGB(60, 60, 60)
					clr.BorderSizePixel = 2
					clr.Position = UDim2.new(0.0280000009, 0, 0, 2)
					clr.Size = UDim2.new(0, 129, 0, 14)
					clr.ZIndex = 5

					copy.Name = "copy"
					copy.Parent = clr
					copy.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
					copy.BackgroundTransparency = 1.000
					copy.BorderSizePixel = 0
					copy.Size = UDim2.new(0, 129, 0, 14)
					copy.ZIndex = 5
					copy.Font = Enum.Font.Code
					copy.Text = data.Text or "Colorpicker"
					copy.TextColor3 = Color3.fromRGB(100, 100, 100)
					copy.TextSize = 14.000
					copy.TextStrokeTransparency = 0.000

					copy.MouseButton1Click:Connect(function()
						colorFrame.Visible = false
					end)

					button2.MouseButton1Click:Connect(function()
						colorFrame.Visible = not colorFrame.Visible
						--mid.BorderColor3 = Color3.fromRGB(60, 60, 60)
					end)

					local uiStroke: UIStroke = Colorpicker.outer;
					local button: TextButton = button2;

					table.insert(window.Connections, button.MouseEnter:Connect(function()
						local tween = Library:CreateTween(
							{ Color = Color3.fromRGB() },
							{ Color = Library.Menu.Colors.Accent },
							{
								Duration = 0.05,
								Easing = "Quad",
								Direction = "InOut",
								AutoPlay = false
							}
						)

						tween:SetOnUpdate(function(currentValues)
							uiStroke.Color = currentValues.Color
						end)

						tween:Play();
					end))

					table.insert(window.Connections, button.MouseLeave:Connect(function()
						local tween = Library:CreateTween(
							{ Color = Library.Menu.Colors.Accent },
							{ Color = Color3.fromRGB() },
							{
								Duration = 0.05,
								Easing = "Quad",
								Direction = "InOut",
								AutoPlay = false
							}
						)

						tween:SetOnUpdate(function(currentValues)
							uiStroke.Color = currentValues.Color
						end)

						tween:Play();
					end))


					local function colorAlmostEqual(a, b, eps)
						eps = eps or 1e-5
						return abs(a.R - b.R) <= eps and abs(a.G - b.G) <= eps and abs(a.B - b.B) <= eps
					end

					local function updateValue(value, fakevalue)
						if typeof(value) == "table" then value = fakevalue end

						Colorpicker.BackgroundColor3 = value
						front.BackgroundColor3 = value

						task.spawn(function()
							for _, element in screenGui:GetDescendants() do
								if element:IsA("TextLabel") or element:IsA("TextButton") or element:IsA("TextBox") then
									if element.TextColor3 == Library.Menu.Colors.Accent and not (element.TextColor3==Color3.fromRGB(255,255,255)) then
										element.TextColor3 = value
									end
									
									if element.Text:find(Library.Menu.Colors.Hex) or element.Text:find('#724b84') then
										element.Text = element.Text:gsub(Library.Menu.Colors.Hex, Library.Convert(value))
									end
								elseif element:IsA("Frame") or element:IsA("ScrollingFrame") or element:IsA("TextButton") or element:IsA("ImageLabel") and element.BackgroundColor3 ~= nil then
									if element.BackgroundColor3 == Library.Menu.Colors.Accent then
										element.BackgroundColor3 = value
									end

								elseif element:IsA("UIStroke") then
									if element.Color == Library.Menu.Colors.Accent then
										element.Color = value
									end

								elseif element:IsA("ImageLabel") or element:IsA("ImageButton") then
									if element.ImageColor3 == Library.Menu.Colors.Accent then
										element.ImageColor3 = value
									end

								elseif element:IsA("UIGradient") then
									--[[local cs = element.Color
									local startColor = cs.Keypoints[1].Value
									local endColor = cs.Keypoints[#cs.Keypoints].Value
									if startColor == Library.Menu.Colors.Accent or cs == ColorSequence.new(Library.Menu.Colors.Accent) then
										element.Color = ColorSequence.new(value)
									end]]
									
									if element.Parent and element.Parent.Name == "fill" then
										element.Color = ColorSequence.new(value)
									end
									
									if element.Name == "Enabled" then
										element.Color = ColorSequence.new(value)
									end
								end
							end
						end)

						Library.Menu.Colors.Accent = value
						Library.Menu.Colors.Hex = Library.Convert(value)
					end


					local white, black = Color3.new(1,1,1), Color3.new(0,0,0)
					local colors = {Color3.new(1,0,0),Color3.new(1,1,0),Color3.new(0,1,0),Color3.new(0,1,1),Color3.new(0,0,1),Color3.new(1,0,1),Color3.new(1,0,0)}
					local heartbeat = game:GetService("RunService").Heartbeat

					local pickerX,pickerY,hueY = 0,0,0
					local oldpercentX,oldpercentY = 0,0

					hue.MouseEnter:Connect(function()
						local input = hue.InputBegan:Connect(function(key)
							if key.UserInputType == Enum.UserInputType.MouseButton1 then
								while heartbeat:wait() and userInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
									Library.colorpicking = true
									local percent = (hueY-hue.AbsolutePosition.Y-36)/hue.AbsoluteSize.Y
									local num = max(1, min(7,floor(((percent*7+0.5)*100))/100))
									local startC = colors[floor(num)]
									local endC = colors[ceil(num)]
									local color = white:lerp(picker2.BackgroundColor3, oldpercentX):lerp(black, oldpercentY)
									picker2.BackgroundColor3 = startC:lerp(endC, num-floor(num)) or Color3.new(0, 0, 0)
									updateValue(color)
								end
								Library.colorpicking = false
							end
						end)

						local leave
						leave = hue.MouseLeave:Connect(function()
							input:disconnect()
							leave:disconnect()
						end)
					end)

					picker2.MouseEnter:Connect(function()
						local input = picker2.InputBegan:Connect(function(key)
							if key.UserInputType == Enum.UserInputType.MouseButton1 then
								while heartbeat:wait() and userInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
									Library.colorpicking = true
									local xPercent = (pickerX-picker2.AbsolutePosition.X)/picker2.AbsoluteSize.X
									local yPercent = (pickerY-picker2.AbsolutePosition.Y-36)/picker2.AbsoluteSize.Y
									local color = white:lerp(picker2.BackgroundColor3, xPercent):lerp(black, yPercent)
									updateValue(color)
									oldpercentX,oldpercentY = xPercent,yPercent
								end

								Library.colorpicking = false
							end
						end)
						local leave
						leave = picker2.MouseLeave:connect(function()
							input:disconnect()
							leave:disconnect()
						end)
					end)

					hue.MouseMoved:connect(function(_, y)
						hueY = y
					end)

					picker2.MouseMoved:connect(function(x, y)
						pickerX,pickerY = x,y
					end)




					--updateValue(Library.Menu.Colors.Accent)
				end;
				
				do
					local toggle = cMenuKey;
					Library.Flags["n_useMenuKey"] = false;

					table.insert(window.Connections, toggle.TextButton.MouseEnter:Connect(function()
						local uiStroke: UIStroke = toggle.Frame.outer;

						local tween = Library:CreateTween(
							{ Color = Color3.fromRGB() },
							{ Color = Library.Menu.Colors.Accent },
							{
								Duration = 0.05,
								Easing = "Quad",
								Direction = "InOut",
								AutoPlay = false
							}
						)

						tween:SetOnUpdate(function(currentValues)
							uiStroke.Color = currentValues.Color
						end)

						tween:Play();
					end))

					table.insert(window.Connections, toggle.TextButton.MouseLeave:Connect(function()
						local uiStroke: UIStroke = toggle.Frame.outer;

						local tween = Library:CreateTween(
							{ Color = Library.Menu.Colors.Accent },
							{ Color = Color3.fromRGB() },
							{
								Duration = 0.05,
								Easing = "Quad",
								Direction = "InOut",
								AutoPlay = false
							}
						)

						tween:SetOnUpdate(function(currentValues)
							uiStroke.Color = currentValues.Color
						end)

						tween:Play();
					end))

					local function updateState(): () -> () -> nil 
						local value: boolean = Library.Flags["n_useMenuKey"]

						value = not value
						Library.Flags["n_useMenuKey"] = value

						if value then
							toggle.Frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
							toggle.Frame.Disabled.Enabled = false
							toggle.Frame.Enabled.Enabled = true
						else
							toggle.Frame.BackgroundColor3 = Color3.fromRGB(27, 25, 27)
							toggle.Frame.Disabled.Enabled = true
							toggle.Frame.Enabled.Enabled = false
						end

						if data.Callback then
							task.spawn(data.Callback, value)
						end;
					end;

					local function getState(): () -> () -> nil 
						return Library.Flags["n_useMenuKey"] or false
					end;

					table.insert(window.Connections, toggle.TextButton.MouseButton1Click:Connect(function()
						updateState()
					end));
					
					local bind = toggle.bind;
					local button = bind.TextButton;
					local next = false;

					local function updateValue(val): () -> ()
						if Library.colorpicking then return end;
						Library.Flags["n_cMenuKey"] = val;
						button.Text = Library.Keys[val] or val.Name;
					end;

					userInputService.InputBegan:Connect(function(key): ()
						local key = key.KeyCode == Enum.KeyCode.Unknown and key.UserInputType or key.KeyCode;

						if next then
							if not table.find(Library.BlacklistedKeys, key) then
								next = false;
								Library.Flags["n_cMenuKey"] = key;
								button.Text = Library.Keys[key] or key.Name;
								button.TextColor3 = Color3.fromRGB(155, 155, 155);
							end;
						end;
					end);

					button.MouseButton1Click:Connect(function()
						if Library.colorpicking then return end
						Library.Flags[data.Flag or "Keybind"] = Enum.KeyCode.Unknown
						button.Text = "--"
						button.TextColor3 = Library.Menu.Colors.Accent
						next = true
					end);

					Library.Flags["n_cMenuKey"] = Enum.KeyCode.RightShift;

					updateValue(Library.Flags["n_cMenuKey"]);
				end;
				
				--// config system
				do
					local flagName = "NCTRNL_CFG"
					local Options = {}
					for _, path in listfiles("nocturnal/configs/") do
						local cut = path:match("[^/\\]+$")
						local name = cut:gsub("%.json$", "")  -- gsub returns TWO Values??? WTF
						table.insert(Options, name)
					end
					Library.Flags["NCTRNL_CFG"] = Options[1] or "default"				

					local function buildDisplay(): string
						local val = Library.Flags[flagName]
						
						return tostring(val or "")
					end

					local function updateValue(value: string | {string})
						if type(value) ~= "string" then return end
						Library.Flags[flagName] = value
						configDropdown.frame.Visible = false
						configDropdown.bg.ImageLabel.Rotation = 0

						configDropdown.bg.main.TextLabel.Text = buildDisplay()

						for _, child in configDropdown.frame.holder:GetChildren() do
							if child:IsA("Frame") and child:FindFirstChildOfClass("TextLabel") then
								local text = child.TextLabel.Text
								
								if rawequal(Library.Flags[flagName], text) then
									child.TextLabel.TextColor3 = Library.Menu.Colors.Accent
								else
									child.TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
								end
							end
						end
					end

					-- create dropdown options in UI
					local function createOptions(arr: { string })
						for idx, option in arr or {} do
							local opt: Frame = configDropdown.frame.holder.Sample:Clone()
							opt.Name = option
							opt.Visible = true
							opt.LayoutOrder = idx
							opt.TextLabel.Text = option
							opt.Parent = configDropdown.frame.holder
							opt.Parent.Parent.Size += UDim2.new(0, 0, 0, 16)

							-- initial highlight
							
							if rawequal(Library.Flags[flagName], option) then
								opt.TextLabel.TextColor3 = Library.Menu.Colors.Accent
							else
								opt.TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
							end

							opt.TextButton.MouseButton1Click:Connect(function()
								updateValue(option)
							end)
						end
					end

					configDropdown.bg.main.button.MouseButton1Click:Connect(function()
						configDropdown.frame.Visible = not configDropdown.frame.Visible
						configDropdown.bg.ImageLabel.Rotation = configDropdown.frame.Visible and 180 or 0
					end)

					--// hmmmmmm
					createOptions(Options)
					updateValue(Options[1])

					configSave.TextButton.MouseButton1Click:Connect(function()
						local selected: string = configDropdown.Parent.Textbox.Frame.pw.Text;
						writefile("nocturnal/configs/".. selected ..".json", Library:saveConfig(selected));
					end)
					
					configLoad.TextButton.MouseButton1Click:Connect(function()
						local selected: string = configDropdown.bg.main.TextLabel.Text;
						Library:loadConfig(selected);
					end)
					
					for idx, button in { configLoad, configSave, configDelete } do
						local uiGradient: UIGradient = button.UIGradient
						local currentTween: any = nil
						local uiStroke: UIStroke

						table.insert(window.Connections, button.TextButton.MouseButton1Click:Connect(function()
							--// effects
							for _, child in button:GetChildren() do
								if child:IsA("UIStroke") and child.BorderStrokePosition == Enum.BorderStrokePosition.Outer then
									uiStroke = child
									break
								end
							end

							if not uiStroke then return end

							local originalColor = uiStroke.Color
							local accentColor = Library.Menu.Colors.Accent

							local tween = Library:CreateTween(
								{ Color = originalColor },
								{ Color = accentColor },
								{
									Duration = 0.05,
									Easing = "Quad",
									Direction = "InOut",
									AutoPlay = false
								}
							)

							tween:SetOnUpdate(function(currentValues)
								uiStroke.Color = currentValues.Color
							end)

							tween:SetOnComplete(function()
								local tweenBack = Library:CreateTween(
									{ Color = accentColor },
									{ Color = originalColor },
									{
										Duration = 0.05,
										Easing = "Quad",
										Direction = "InOut",
										AutoPlay = false
									}
								)
								tweenBack:SetOnUpdate(function(currentValues)
									uiStroke.Color = currentValues.Color;
								end)
								tweenBack:Play();
							end);

							tween:Play();
						end))

						local function tweenRotation(targetRotation)
							if currentTween then
								currentTween:Stop(true)
							end

							local tween = Library:CreateTween(
								{ Rotation = uiGradient.Rotation },
								{ Rotation = targetRotation },
								{
									Duration = 0.16,
									Easing = "Quad",
									Direction = "InOut",
									AutoPlay = false
								}
							)

							currentTween = tween

							tween:SetOnUpdate(function(currentValues)
								uiGradient.Rotation = currentValues.Rotation
							end)

							tween:Play()
						end

						table.insert(window.Connections, button.TextButton.MouseEnter:Connect(function()
							tweenRotation(90)
						end))

						table.insert(window.Connections, button.TextButton.MouseLeave:Connect(function()
							tweenRotation(-90)
						end))
					end
				end;
			end);
		end;
		
		function tab:createMultisection(data: { [string]: any }): () -> ()
			if not data then return end;
			data = Library.Struct(data, false, false);
			local sectionFrame: Frame = ref:FindFirstChild("Multisection"):Clone();
			local sectionLocation: string = data.Location == 2 and "R" or "L"
			local sectionOne: {} = Library.Struct({
				Toggles = Library.Struct({}, false, false),
				Dropdowns = Library.Struct({}, false, false),
				Keybinds = Library.Struct({}, false, false),
				Sliders = Library.Struct({}, false, false),
			}, false, false);
			
			local sectionTwo: {} = Library.Struct({
				Toggles = Library.Struct({}, false, false),
				Dropdowns = Library.Struct({}, false, false),
				Keybinds = Library.Struct({}, false, false),
				Sliders = Library.Struct({}, false, false),
			}, false, false);
			
			local sections: {} = data.Sections;
			if #sections > 2 then return end;
			
			sectionFrame.pre1.Text = data.Text1 or "Multisection 1";
			sectionFrame.pre2.Text = data.Text2 or "Multisection 2";

			sectionFrame.Name = data.Text or "Multisection";
			sectionFrame.Parent = tabSectionFrame[sectionLocation]
			sectionFrame.Underline.Size = UDim2.new(1, 0, 0, 2)
			
			local firstTab: Frame = sectionFrame.SectionTab["1"]
			local secondTab: Frame = sectionFrame.SectionTab["2"]
			
			local section_name_one: string = sections[1];
			local section_name_two: string = sections[2];
			
			firstTab.pre.Text = section_name_one;
			secondTab.pre.Text = section_name_two;
			
			--// tab system
			local tabs: Frame = sectionFrame.SectionTab:GetChildren()
			
			local function initTabs(): () -> ()
				for _, tab: Frame in tabs do
					if tab:IsA("Frame") then
						local btn = tab:FindFirstChild("TextButton");
						btn.MouseButton1Click:Connect(function()
							for _, sections in sectionFrame:GetChildren() do
								if sections.Name:find("Content") then
									sections.Visible = false;
								end;
							end;

							sectionFrame["Content" .. btn.Parent.Name].Visible = true;

							if rawequal(btn.Parent.Name, "1") then
								sectionFrame.pre1.Visible = true;
								sectionFrame.pre2.Visible = false;
								sectionFrame.SectionTab["1"].Frame.Visible = true;
								sectionFrame.SectionTab["2"].Frame.Visible = false;
								sectionFrame.SectionTab["2"].BackgroundTransparency = 1
								sectionFrame.SectionTab["1"].BackgroundTransparency = 0
							else
								sectionFrame.pre1.Visible = false;
								sectionFrame.pre2.Visible = true;
								sectionFrame.SectionTab["1"].Frame.Visible = true;
								sectionFrame.SectionTab["2"].Frame.Visible = true;
								sectionFrame.SectionTab["2"].BackgroundTransparency = 0
								sectionFrame.SectionTab["1"].BackgroundTransparency = 1
							end;
						end)
					end
				end;
			end;
			
			task.spawn(initTabs, nil);
			
			local function createLabel(data: { [string]: any }): () -> ()
				if not data then return end;
				
				data = Library.Struct(data, false, false);
				assert(data.Text, "[nocturnal] invalid label text");

				local labelFrame: Frame = ref:FindFirstChild("Label"):Clone();
				local sectionIndex: number = data.Section or 1
				labelFrame.Parent = sectionFrame["Content" .. sectionIndex];
				
				--// set values
				sectionFrame.Underline.Size = UDim2.new(1, 0, 0, 2);

				labelFrame.TextLabel.Text = data.Text or "Label";
			end				
			
			local function createTextbox(data: { [string]: any }): () -> ()
				if not data then return end;
				data = Library.Struct(data, false, false);
				local textboxFrame: Frame = ref:FindFirstChild("Textbox"):Clone();
				local textbox: {} = Library.Struct({}, false, false);
				local sectionIndex: number = data.Section or 1
				textboxFrame.Parent = sectionFrame["Content" .. sectionIndex];
				textboxFrame.TextLabel.Text = data.Text or "Textbox";
				textboxFrame.Name = data.Text or "Textbox";
				textboxFrame.Frame.pw.Text = data.Default or "";
				Library.Flags[data.Flag or "Textbox"] = data.Default or "";

				--// set values
				--sectionFrame.Size += UDim2.new(0, 0, .065, 0);
				sectionFrame.Underline.Size = UDim2.new(1, 0, 0, 2);

				--// hover effects
				local uiStroke: UIStroke = textboxFrame.Frame.pw.outer;
				local button: TextButton = textboxFrame.Frame.pw;

				table.insert(window.Connections, button.MouseEnter:Connect(function()
					local tween = Library:CreateTween(
						{ Color = Color3.fromRGB() },
						{ Color = Library.Menu.Colors.Accent },
						{
							Duration = 0.05,
							Easing = "Quad",
							Direction = "InOut",
							AutoPlay = false
						}
					)

					tween:SetOnUpdate(function(currentValues)
						uiStroke.Color = currentValues.Color
					end)

					tween:Play();
				end));

				table.insert(window.Connections, button.MouseLeave:Connect(function()
					local tween = Library:CreateTween(
						{ Color = Library.Menu.Colors.Accent },
						{ Color = Color3.fromRGB() },
						{
							Duration = 0.05,
							Easing = "Quad",
							Direction = "InOut",
							AutoPlay = false
						}
					)

					tween:SetOnUpdate(function(currentValues)
						uiStroke.Color = currentValues.Color
					end)

					tween:Play();
				end));

				table.insert(window.Connections, button.FocusLost:Connect(function()
					Library.Flags[data.Flag or "Textbox"] = button.Text;

					if data.Callback then
						task.spawn(data.Callback, button.Text)
					end
				end));
				
				Library.Options[data.Flag] = {type = "textbox",changeState = function(text) button.Text = text end,oldargs = args}
			end

			local function createButton(data: { [string]: any }): () -> ()
				if not data then return end;
				data = Library.Struct(data, false, false);
				local buttonFrame: Frame = ref:FindFirstChild("Button"):Clone();
				local button: {} = Library.Struct({}, false, false);
				local sectionIndex: number = data.Section or 1
				buttonFrame.Parent = sectionFrame["Content" .. sectionIndex];
				buttonFrame.TextButton.Text = data.Text or "Button";
				buttonFrame.Name = data.Text or "Button";

				--// set values
				sectionFrame.Size += UDim2.new(0, 0, .065, 0)
				sectionFrame.Underline.Size = UDim2.new(1, 0, 0, 2)

				table.insert(window.Connections, buttonFrame.TextButton.MouseButton1Click:Connect(function()
					if data.Callback then
						task.spawn(data.Callback, os.clock())
					end

					--// lmaoo
					local uiStroke: UIStroke
					for _, child in buttonFrame:GetChildren() do
						if child:IsA("UIStroke") and child.BorderStrokePosition == Enum.BorderStrokePosition.Outer then
							uiStroke = child
							break
						end
					end

					if not uiStroke then return end

					local originalColor = uiStroke.Color
					local accentColor = Library.Menu.Colors.Accent

					local tween = Library:CreateTween(
						{ Color = originalColor },
						{ Color = accentColor },
						{
							Duration = 0.05,
							Easing = "Quad",
							Direction = "InOut",
							AutoPlay = false
						}
					)

					tween:SetOnUpdate(function(currentValues)
						uiStroke.Color = currentValues.Color
					end)

					tween:SetOnComplete(function()
						local tweenBack = Library:CreateTween(
							{ Color = accentColor },
							{ Color = originalColor },
							{
								Duration = 0.05,
								Easing = "Quad",
								Direction = "InOut",
								AutoPlay = false
							}
						)
						tweenBack:SetOnUpdate(function(currentValues)
							uiStroke.Color = currentValues.Color;
						end)
						tweenBack:Play();
					end);

					tween:Play();
				end));


				local uiGradient: UIGradient = buttonFrame.UIGradient
				local currentTween: any = nil

				local function tweenRotation(targetRotation)
					if currentTween then
						currentTween:Stop(true)
					end

					local tween = Library:CreateTween(
						{ Rotation = uiGradient.Rotation },
						{ Rotation = targetRotation },
						{
							Duration = 0.16,
							Easing = "Quad",
							Direction = "InOut",
							AutoPlay = false
						}
					)

					currentTween = tween

					tween:SetOnUpdate(function(currentValues)
						uiGradient.Rotation = currentValues.Rotation
					end)

					tween:Play()
				end

				table.insert(window.Connections, buttonFrame.TextButton.MouseEnter:Connect(function()
					tweenRotation(90)
				end))

				table.insert(window.Connections, buttonFrame.TextButton.MouseLeave:Connect(function()
					tweenRotation(-90)
				end))
			end;

			local function createDropdown(data: { [string]: any }): ()
				if not data then return end
				data = Library.Struct(data, false, false)
				local sectionIndex: number = data.Section or 1
				local dropdownFrame: Frame = ref:FindFirstChild("list"):Clone()
				dropdownFrame.Parent = sectionFrame["Content" .. sectionIndex];
				dropdownFrame.TextLabel.Text = data.Text or "Dropdown"
				dropdownFrame.Name = data.Text or "Dropdown"

				local button = dropdownFrame.bg.main.button
				local uiStroke = dropdownFrame.bg.main.outer

				local flagName = data.Flag or "Dropdown"

				table.insert(window.Connections, button.MouseEnter:Connect(function()
					local tween = Library:CreateTween(
						{ Color = Color3.fromRGB() },
						{ Color = Library.Menu.Colors.Accent },
						{
							Duration = 0.05,
							Easing = "Quad",
							Direction = "InOut",
							AutoPlay = false
						}
					)

					tween:SetOnUpdate(function(currentValues)
						uiStroke.Color = currentValues.Color
					end)

					tween:Play();
				end))

				table.insert(window.Connections, button.MouseLeave:Connect(function()
					local tween = Library:CreateTween(
						{ Color = Library.Menu.Colors.Accent },
						{ Color = Color3.fromRGB() },
						{
							Duration = 0.05,
							Easing = "Quad",
							Direction = "InOut",
							AutoPlay = false
						}
					)

					tween:SetOnUpdate(function(currentValues)
						uiStroke.Color = currentValues.Color
					end)

					tween:Play();
				end))

				if data.Multichoice then
					if type(data.Default) == "table" then
						Library.Flags[flagName] = { unpack(data.Default) }
					elseif type(data.Default) == "string" then
						Library.Flags[flagName] = { data.Default }
					else
						Library.Flags[flagName] = {}
					end
				else
					Library.Flags[flagName] = data.Default or data.Options[1] or nil
				end

				local function buildDisplay(): string
					local val = Library.Flags[flagName]
					if data.Multichoice then
						if #val == 0 then return "" end
						return table.concat(val, ", ")
					else
						return tostring(val or "")
					end
				end

				local function updateValue(value: string | {string})
					if data.Multichoice then
						if type(value) == "string" then
							local sel = Library.Flags[flagName]
							local index = table.find(sel, value)
							if index then
								if #sel == 1 then
									return 
								end --// need at least 1 elementz

								table.remove(sel, index)
							else
								table.insert(sel, value)
							end
						elseif type(value) == "table" then
							Library.Flags[flagName] = { unpack(value) }
						end
					else
						if type(value) ~= "string" then return end
						Library.Flags[flagName] = value
						dropdownFrame.frame.Visible = false
						dropdownFrame.bg.ImageLabel.Rotation = 0
					end

					dropdownFrame.bg.main.TextLabel.Text = buildDisplay()

					for _, child in dropdownFrame.frame.holder:GetChildren() do
						if child:IsA("Frame") and child:FindFirstChildOfClass("TextLabel") then
							local text = child.TextLabel.Text
							if data.Multichoice then
								if table.find(Library.Flags[flagName], text) then
									child.TextLabel.TextColor3 = Library.Menu.Colors.Accent
								else
									child.TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
								end
							else
								if rawequal(Library.Flags[flagName], text) then
									child.TextLabel.TextColor3 = Library.Menu.Colors.Accent
								else
									child.TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
								end
							end
						end
					end

					if data.Callback then
						task.spawn(data.Callback, Library.Flags[flagName])
					end
				end

				-- create dropdown options in UI
				local function createOptions(arr: { string })
					for idx, option in arr or {} do
						local opt: Frame = dropdownFrame.frame.holder.Sample:Clone()
						opt.Name = option
						opt.Visible = true
						opt.LayoutOrder = idx
						opt.TextLabel.Text = option
						opt.Parent = dropdownFrame.frame.holder
						opt.Parent.Parent.Size += UDim2.new(0, 0, 0, 16)

						-- initial highlight
						if data.Multichoice then
							if table.find(Library.Flags[flagName], option) then
								opt.TextLabel.TextColor3 = Library.Menu.Colors.Accent
							else
								opt.TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
							end
						else
							if rawequal(Library.Flags[flagName], option) then
								opt.TextLabel.TextColor3 = Library.Menu.Colors.Accent
							else
								opt.TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
							end
						end

						opt.TextButton.MouseButton1Click:Connect(function()
							updateValue(option)
						end)
					end

					Library.Options[flagName].values = arr
				end

				dropdownFrame.bg.main.button.MouseButton1Click:Connect(function()
					dropdownFrame.frame.Visible = not dropdownFrame.frame.Visible
					dropdownFrame.bg.ImageLabel.Rotation = dropdownFrame.frame.Visible and 180 or 0
				end)

				Library.Options[flagName] = {
					type = "list",
					changeState = updateValue,
					values = data.Options,
					oldargs = data,
					refresh = createOptions,
				}


				--// hmmmmmm
				createOptions(data.Options)
				updateValue(data.Default or data.Options[1])
			end;
			
			local function createToggle(data: { [string]: any }): () -> ()
				if not data then return end;
				data = Library.Struct(data, false, false);
				local toggle: Frame = ref:FindFirstChild("Toggle"):Clone();
				local toggles: {} = Library.Struct({
					Bound = false,
					Binds = Library.Struct({}, false, false)
				}, false, false)
				toggle.Name = data.Text or "Toggle";
				print(data.Text)
				toggle.TextLabel.Text = data.Text or "Toggle";
				local sectionIndex: number = data.Section or 1
				toggle.Parent = sectionFrame["Content" .. sectionIndex];

				--// states
				Library.Flags[data.Flag or "Toggle"] = false;
				--sectionFrame.Size += UDim2.new(0, 0, .04, 0)
				sectionFrame.Underline.Size = UDim2.new(1, 0, 0, 2)

				--// connections
				table.insert(window.Connections, toggle.TextButton.MouseEnter:Connect(function()
					local uiStroke: UIStroke = toggle.Frame.outer;

					local tween = Library:CreateTween(
						{ Color = Color3.fromRGB() },
						{ Color = Library.Menu.Colors.Accent },
						{
							Duration = 0.05,
							Easing = "Quad",
							Direction = "InOut",
							AutoPlay = false
						}
					)

					tween:SetOnUpdate(function(currentValues)
						uiStroke.Color = currentValues.Color
					end)

					tween:Play();
				end))

				table.insert(window.Connections, toggle.TextButton.MouseLeave:Connect(function()
					local uiStroke: UIStroke = toggle.Frame.outer;

					local tween = Library:CreateTween(
						{ Color = Library.Menu.Colors.Accent },
						{ Color = Color3.fromRGB() },
						{
							Duration = 0.05,
							Easing = "Quad",
							Direction = "InOut",
							AutoPlay = false
						}
					)

					tween:SetOnUpdate(function(currentValues)
						uiStroke.Color = currentValues.Color
					end)

					tween:Play();
				end))

				local flagName = data.Flag or "Toggle"

				local function changeState(newState: boolean)
					Library.Flags[flagName] = newState
					local toggleFrame = toggle

					if newState then
						toggleFrame.Frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
						toggleFrame.Frame.Disabled.Enabled = false
						toggleFrame.Frame.Enabled.Enabled = true
					else
						toggleFrame.Frame.BackgroundColor3 = Color3.fromRGB(27, 25, 27)
						toggleFrame.Frame.Disabled.Enabled = true
						toggleFrame.Frame.Enabled.Enabled = false
					end

					if data.Callback then
						task.spawn(data.Callback, newState)
					end

					if window.List and toggles.Bound then
						if not rawequal(toggle.bind.TextButton.Text, "Unknown") then
							window:updateBindEntry({ State =  toggles:getState(), Key = toggle.bind.TextButton.Text, Feature = toggle.TextLabel.Text})
						end
					end
				end

				function toggles:updateState(): () -> () -> nil 
					local value: boolean = Library.Flags[data.Flag]

					value = not value
					Library.Flags[data.Flag or "Toggle"] = value

					if value then
						toggle.Frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
						toggle.Frame.Disabled.Enabled = false
						toggle.Frame.Enabled.Enabled = true
					else
						toggle.Frame.BackgroundColor3 = Color3.fromRGB(27, 25, 27)
						toggle.Frame.Disabled.Enabled = true
						toggle.Frame.Enabled.Enabled = false
					end

					if data.Callback then
						task.spawn(data.Callback, value)
					end;

					if window.List and toggles.Bound then
						if not rawequal(toggle.bind.TextButton.Text, "Unknown") then
							window:updateBindEntry({ State =  toggles:getState(), Key = toggle.bind.TextButton.Text, Feature = toggle.TextLabel.Text})
						end
					end
				end;

				function toggles:getState(): () -> () -> nil 
					return Library.Flags[data.Flag] or false
				end;

				table.insert(window.Connections, toggle.TextButton.MouseButton1Click:Connect(function()
					changeState(not Library.Flags[flagName])
				end))

				Library.Options[flagName] = {
					type = "toggle",
					changeState = changeState,
					oldargs = data
				}


				function toggles:createBind(data: { [string]: any }): () -> ()
					if not data then return end;
					data = Library.Struct(data, false, false);
					toggles.Bound = true;
					local bind = toggle.bind;
					bind.Visible = true;
					local button = bind.TextButton;
					local next = false;

					local function updateValue(val): () -> ()
						if Library.colorpicking then return end;
						Library.Flags[data.Flag or "Keybind"] = val;
						button.Text = Library.Keys[val] or val.Name;
					end;

					userInputService.InputBegan:Connect(function(key): ()
						local key = key.KeyCode == Enum.KeyCode.Unknown and key.UserInputType or key.KeyCode;

						if next then
							if not table.find(Library.BlacklistedKeys, key) then
								next = false;
								Library.Flags[data.Flag or "Keybind"] = key;
								button.Text = Library.Keys[key] or key.Name;
								button.TextColor3 = Color3.fromRGB(155, 155, 155);
							end;
						end;

						if not next and key == Library.Flags[data.Flag or "Keybind"] and data.Callback then
							--// sometimes it shouldn't trigger the original toggle
							if not data.Ignore then
								toggles:updateState()
							end

							task.spawn(data.Callback, key);
							task.spawn(function()
								if window.List then
									window:createBindEntry({ Key = Library.Keys[key] or key.Name, Feature = toggle.TextLabel.Text })
									window:updateBindEntry({ State =  toggles:getState(), Key = Library.Keys[key] or key.Name; Feature = toggle.TextLabel.Text})
								end
							end)
						end
					end);

					button.MouseButton1Click:Connect(function()
						if Library.colorpicking then return end
						Library.Flags[data.Flag or "Keybind"] = Enum.KeyCode.Unknown
						button.Text = "--"
						button.TextColor3 = Library.Menu.Colors.Accent
						next = true
					end);

					Library.Flags[data.Flag or "Keybind"] = Enum.KeyCode.Unknown;
					Library.Options[data.Flag] = {type = "keybind",changeState = updateValue,oldargs = args}

					updateValue(data.Default or Enum.KeyCode.Unknown);
				end

				function toggles:createColorpicker(data: { [string]: any }): () -> ()
					if not data then return end;
					data = Library.Struct(data, false, false);
					local picker: ColorPicker = {
						Name = data.Text or "Colorpicker",
						Color = data.Default or Color3.new(1, 1, 1),
						SetColor = function(e)
							toggle.Colorpicker.BackgroundColor3 = e
						end
					}

					local hueValue = 0
					local satValue = 1
					local valValue = 1

					--// TODO: Add colorpicker logic
					local Colorpicker: Frame = toggle.Colorpicker;
					Colorpicker.Visible = true;
					Colorpicker.Parent.ZIndex += 1 --// weird

					local colorpicker = Instance.new("Frame")
					local mid = Instance.new("Frame")
					local front = Instance.new("Frame")
					local button2 = Instance.new("TextButton")
					local colorFrame = Instance.new("Frame")
					local colorFrame_2 = Instance.new("Frame")
					local hueframe = Instance.new("Frame")
					local main = Instance.new("Frame")
					local hue = Instance.new("ImageLabel")
					local pickerframe = Instance.new("Frame")
					local main_2 = Instance.new("Frame")
					local picker2 = Instance.new("ImageLabel")
					local clr = Instance.new("Frame")
					local copy = Instance.new("TextButton")




					button2.Name = "button2"
					button2.Parent = Colorpicker
					button2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					button2.BackgroundTransparency = 1.000
					button2.Size = UDim2.new(1, 0, 1, 0)
					button2.Text = ""
					button2.Font = Enum.Font.SourceSans
					button2.TextColor3 = Color3.fromRGB(0, 0, 0)
					button2.TextSize = 14.000

					colorFrame.Name = "colorFrame"
					colorFrame.Parent = toggle
					colorFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
					colorFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
					colorFrame.BorderSizePixel = 2
					colorFrame.Position = UDim2.new(0.101092957, 0, 0.75, 0)
					colorFrame.Size = UDim2.new(0, 137, 0, 128)
					colorFrame.Visible = false
					colorFrame.ZIndex = 685486548

					local screenGuiZ = toggle:FindFirstAncestorWhichIsA("ScreenGui")
					if not screenGuiZ then
						return
					end

					colorFrame.Parent = screenGuiZ
					colorFrame.AnchorPoint = Vector2.new(1, 0) -- top-right corner
					colorFrame.Position = UDim2.new(1, -10, 0, 10) -- 10px margin from top-right

					colorFrame_2.Name = "colorFrame"
					colorFrame_2.Parent = colorFrame
					colorFrame_2.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
					colorFrame_2.BorderColor3 = Color3.fromRGB(60, 60, 60)
					colorFrame_2.Size = UDim2.new(1, 0, 1, 0)

					hueframe.Name = "hueframe"
					hueframe.Parent = colorFrame_2
					hueframe.Parent = colorFrame_2
					hueframe.BackgroundColor3 = Color3.fromRGB(34, 34, 34)
					hueframe.BorderColor3 = Color3.fromRGB(60, 60, 60)
					hueframe.BorderSizePixel = 2
					hueframe.Position = UDim2.new(-0.0930000022, 18, -0.0599999987, 30)
					hueframe.Size = UDim2.new(0, 100, 0, 100)

					main.Name = "main"
					main.Parent = hueframe
					main.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
					main.BorderColor3 = Color3.fromRGB(0, 0, 0)
					main.Size = UDim2.new(0, 100, 0, 100)
					main.ZIndex = 8677777777777777

					picker2.Name = "picker"
					picker2.Parent = main
					picker2.BackgroundColor3 = Color3.fromRGB(232, 0, 255)
					picker2.BorderColor3 = Color3.fromRGB(0, 0, 0)
					picker2.BorderSizePixel = 0
					picker2.Size = UDim2.new(0, 100, 0, 100)
					picker2.ZIndex = 687678678
					picker2.Image = "rbxassetid://2615689005"

					pickerframe.Name = "pickerframe"
					pickerframe.Parent = colorFrame
					pickerframe.BackgroundColor3 = Color3.fromRGB(34, 34, 34)
					pickerframe.BorderColor3 = Color3.fromRGB(60, 60, 60)
					pickerframe.BorderSizePixel = 2
					pickerframe.Position = UDim2.new(0.711000025, 14, -0.0599999987, 30)
					pickerframe.Size = UDim2.new(0, 20, 0, 100)

					main_2.Name = "main"
					main_2.Parent = pickerframe
					main_2.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
					main_2.BorderColor3 = Color3.fromRGB(0, 0, 0)
					main_2.Size = UDim2.new(0, 20, 0, 100)
					main_2.ZIndex = 6

					hue.Name = "hue"
					hue.Parent = main_2
					hue.BackgroundColor3 = Color3.fromRGB(255, 0, 178)
					hue.BorderColor3 = Color3.fromRGB(0, 0, 0)
					hue.BorderSizePixel = 0
					hue.Size = UDim2.new(0, 20, 0, 100)
					hue.ZIndex = 104
					hue.Image = "rbxassetid://2615692420"

					clr.Name = "clr"
					clr.Parent = colorFrame
					clr.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
					clr.BackgroundTransparency = 1.000
					clr.BorderColor3 = Color3.fromRGB(60, 60, 60)
					clr.BorderSizePixel = 2
					clr.Position = UDim2.new(0.0280000009, 0, 0, 2)
					clr.Size = UDim2.new(0, 129, 0, 14)
					clr.ZIndex = 5

					copy.Name = "copy"
					copy.Parent = clr
					copy.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
					copy.BackgroundTransparency = 1.000
					copy.BorderSizePixel = 0
					copy.Size = UDim2.new(0, 129, 0, 14)
					copy.ZIndex = 5
					copy.Font = Enum.Font.SourceSans
					copy.Text = data.Text or "Colorpicker"
					copy.TextColor3 = Color3.fromRGB(100, 100, 100)
					copy.TextSize = 14.000
					copy.TextStrokeTransparency = 0.000

					copy.MouseButton1Click:Connect(function() -- "  "..args.text or "  "..args.flag
						colorFrame.Visible = false
					end)

					button2.MouseButton1Click:Connect(function()
						colorFrame.Visible = not colorFrame.Visible
						--mid.BorderColor3 = Color3.fromRGB(60, 60, 60)
					end)

					local uiStroke: UIStroke = Colorpicker.outer;
					local button: TextButton = button2;

					table.insert(window.Connections, button.MouseEnter:Connect(function()
						local tween = Library:CreateTween(
							{ Color = Color3.fromRGB() },
							{ Color = Library.Menu.Colors.Accent },
							{
								Duration = 0.05,
								Easing = "Quad",
								Direction = "InOut",
								AutoPlay = false
							}
						)

						tween:SetOnUpdate(function(currentValues)
							uiStroke.Color = currentValues.Color
						end)

						tween:Play();
					end))

					table.insert(window.Connections, button.MouseLeave:Connect(function()
						local tween = Library:CreateTween(
							{ Color = Library.Menu.Colors.Accent },
							{ Color = Color3.fromRGB() },
							{
								Duration = 0.05,
								Easing = "Quad",
								Direction = "InOut",
								AutoPlay = false
							}
						)

						tween:SetOnUpdate(function(currentValues)
							uiStroke.Color = currentValues.Color
						end)

						tween:Play();
					end))


					local function updateValue(value,fakevalue)
						if typeof(value) == "table" then value = fakevalue end
						picker:SetColor(value)
						front.BackgroundColor3 = value
						Library.Flags[data.Flag or "Colorpicker"] = value
						if data.Callback then
							task.spawn(data.Callback, value)
						end
					end

					local white, black = Color3.new(1,1,1), Color3.new(0,0,0)
					local colors = {Color3.new(1,0,0),Color3.new(1,1,0),Color3.new(0,1,0),Color3.new(0,1,1),Color3.new(0,0,1),Color3.new(1,0,1),Color3.new(1,0,0)}
					local heartbeat = game:GetService("RunService").Heartbeat

					local pickerX,pickerY,hueY = 0,0,0
					local oldpercentX,oldpercentY = 0,0
					local baseHueColor = picker2.BackgroundColor3

					hue.MouseEnter:Connect(function()
						local input = hue.InputBegan:Connect(function(key)
							if key.UserInputType == Enum.UserInputType.MouseButton1 then
								while heartbeat:wait() and userInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
									Library.colorpicking = true
									local percent = math.clamp(
										(hueY - hue.AbsolutePosition.Y - 36) / hue.AbsoluteSize.Y,
										0,
										1
									)									
									local num = math.max(1, math.min(7,math.floor(((percent*7+0.5)*100))/100))
									local startC = colors[math.floor(num)]
									local endC = colors[math.ceil(num)]
									baseHueColor = startC:lerp(endC, num - math.floor(num))
									picker2.BackgroundColor3 = baseHueColor

									local color = white:lerp(baseHueColor, oldpercentX):lerp(black, oldpercentY)
									updateValue(color)
								end
								Library.colorpicking = false
							end
						end)

						local leave
						leave = hue.MouseLeave:Connect(function()
							input:disconnect()
							leave:disconnect()
						end)
					end)

					picker2.MouseEnter:Connect(function()
						local input = picker2.InputBegan:Connect(function(key)
							if key.UserInputType == Enum.UserInputType.MouseButton1 then
								while heartbeat:wait() and userInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
									Library.colorpicking = true
									local xPercent = math.clamp(
										(pickerX - picker2.AbsolutePosition.X) / picker2.AbsoluteSize.X,
										0,
										1
									)

									local yPercent = math.clamp(
										(pickerY - picker2.AbsolutePosition.Y - 36) / picker2.AbsoluteSize.Y,
										0,
										1
									)

									local color = white:lerp(baseHueColor, xPercent):lerp(black, yPercent)
									updateValue(color)
									oldpercentX,oldpercentY = xPercent,yPercent
								end

								Library.colorpicking = false
							end
						end)
						local leave
						leave = picker2.MouseLeave:connect(function()
							input:disconnect()
							leave:disconnect()
						end)
					end)

					hue.MouseMoved:connect(function(_, y)
						hueY = y
					end)

					picker2.MouseMoved:connect(function(x, y)
						pickerX,pickerY = x,y
					end)



					function picker:SetColor(c: Color3)
						self.Color = c
						Colorpicker.BackgroundColor3 = c
					end

					updateValue(data.Default or Color3.fromRGB(255, 255, 255))
					Library.Options[data.Flag or "ColorpickerYes"] = {type = "colorpicker", changeState = updateValue, args = data}

					return picker
				end;

				return toggles;
			end;

			local function createSlider(data: { [string]: any }): () -> ()
				if not data then return end;
				data = Library.Struct(data, false, false);
				local sliderFrame: Frame = ref:FindFirstChild("Slider"):Clone();
				local slider: {} = Library.Struct({}, false, false);
				local sectionIndex: number = data.Section or 1
				sliderFrame.Parent = sectionFrame["Content" .. sectionIndex];
				sliderFrame.TextLabel.Text = data.Text or "Slider";
				sliderFrame.Name = data.Text or "Slider";

				--// fetches from slider data
				local min, max, value, callback = data.Min or 0, data.Max or 100, data.Value or 0, data.Callback or nil;
				local entered = false
				local scrolling = false
				local amount = 0

				--// states
				local fill = sliderFrame.bg.main:FindFirstChild("fill");
				local valuetext = sliderFrame.bg.main.TextLabel
				local button = sliderFrame.bg.main.TextButton
				assert(fill, "[nocturnal] critical error; slider fetch failed") --// how would this even happen

				Library.Flags[data.Flag or "Slider"] = value;
				sectionFrame.Underline.Size = UDim2.new(1, 0, 0, 2)

				--// hover effects
				local uiStroke: UIStroke = sliderFrame.bg.main.outer;

				table.insert(window.Connections, button.MouseEnter:Connect(function()
					local tween = Library:CreateTween(
						{ Color = Color3.fromRGB() },
						{ Color = Library.Menu.Colors.Accent },
						{
							Duration = 0.05,
							Easing = "Quad",
							Direction = "InOut",
							AutoPlay = false
						}
					)

					tween:SetOnUpdate(function(currentValues)
						uiStroke.Color = currentValues.Color
					end)

					tween:Play();
				end))

				table.insert(window.Connections, button.MouseLeave:Connect(function()
					local tween = Library:CreateTween(
						{ Color = Library.Menu.Colors.Accent },
						{ Color = Color3.fromRGB() },
						{
							Duration = 0.05,
							Easing = "Quad",
							Direction = "InOut",
							AutoPlay = false
						}
					)

					tween:SetOnUpdate(function(currentValues)
						uiStroke.Color = currentValues.Color
					end)

					tween:Play();
				end))


				local function updateValue(value)
					if Library.colorpicking then return end
					if value ~= 0 then
						fill:TweenSize(UDim2.new(value/max,0,1,0),Enum.EasingDirection.In,Enum.EasingStyle.Sine,0.01)
					else
						fill:TweenSize(UDim2.new(0,1,1,0),Enum.EasingDirection.In,Enum.EasingStyle.Sine,0.01)
					end
					valuetext.Text = value.."°/"..max.."°"
					Library.Flags[data.Flag or "Slider"] = value
					if callback then
						task.spawn(callback, value)
					end
				end

				local step = data.Step or 1

				local function updateScroll()
					if scrolling or Library.scrolling or Library.colorpicking then return end
					while userInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) and screenGui.Enabled and not Library.dragging do
						runService.RenderStepped:Wait()
						Library.scrolling = true
						scrolling = true

						local rawValue = min + ((Library.Mouse.X - button.AbsolutePosition.X) / button.AbsoluteSize.X) * (max - min)
						if rawValue < min then rawValue = min end
						if rawValue > max then rawValue = max end

						local steppedValue = math.floor(rawValue / step + 0.5) * step -- rounds to nearest step
						updateValue(steppedValue)
					end

					if not screenGui.Enabled then
						entered = false
					end
					scrolling = false
					Library.scrolling = false
				end

				button.MouseEnter:Connect(function()
					if Library.colorpicking then return end
					if scrolling or entered then return end
					entered = true
					while entered do 
						task.wait()
						updateScroll()
					end
				end)

				button.MouseLeave:Connect(function()
					entered = false
				end)

				if value then
					updateValue(value)
				end

				Library.Flags[data.Flag] = 0
				updateValue(value or 0)
			end;
			
			--// i love this solution, but it's still sadly so messy
			local binds: {
				createLabel: any,
				createButton: any,
				createTextbox: any,
				createDropdown: any,
				createSlider: any,
				createToggle: any
			} = {
				["createToggle"]   = createToggle,
				["createDropdown"] = createDropdown,
				["createSlider"]   = createSlider,
				["createTextbox"]  = createTextbox,
				["createButton"]   = createButton,
				["createLabel"]    = createLabel,
			};

			local sections: { [ Frame ]: {} } = { sectionOne, sectionTwo };
			local list: { any } = {};

			for _, sec in sections do
				for key, fn in binds do
					table.insert(list, {
						function(...)
							local s, k, f = ...
							s[k] = f
						end,
						{ sec, key, fn }
					})
				end
			end

			Library:MultiThreadList(list);
			return sectionOne, sectionTwo; --// terrible solution but idc, its v1 afterall
		end
		
		function tab:createSection(data: { [string]: any }): () -> ()
			if not data then return end;
			data = Library.Struct(data, false, false);
			local sectionFrame: Frame = ref:FindFirstChild("Section"):Clone();
			local sectionLocation: string = data.Location == 2 and "R" or "L"
			local section: {} = Library.Struct({
				Toggles = Library.Struct({}, false, false),
				Dropdowns = Library.Struct({}, false, false),
				Keybinds = Library.Struct({}, false, false),
				Sliders = Library.Struct({}, false, false),
			}, false, false);
			
			zIndex -= 1;
			sectionFrame.Content.pre.Text = data.Text or "Section";
			sectionFrame.Name = data.Text or "Section";
			sectionFrame.Parent = tabSectionFrame[sectionLocation]
			sectionFrame.Underline.Size = UDim2.new(1, 0, 0, 2)
			sectionFrame.ZIndex = zIndex
						
			function section:createSeperator(): () -> ()
				local seperatorFrame: Frame = ref:FindFirstChild("Seperator"):Clone();
				seperatorFrame.Parent = sectionFrame.Content;
				
				--// set values
				sectionFrame.Size += UDim2.new(0, 0, 0, 17.5);
				sectionFrame.Underline.Size = UDim2.new(1, 0, 0, 2);
			end
			
			function section:createLabel(data: { [string]: any }): () -> ()
				if not data then return end;
				data = Library.Struct(data, false, false);
				assert(data.Text, "[nocturnal] invalid label text");
				
				local labelFrame: Frame = ref:FindFirstChild("Label"):Clone();
				labelFrame.Parent = sectionFrame.Content;

				--// set values
				sectionFrame.Size += UDim2.new(0, 0, 0, 20)
				sectionFrame.Underline.Size = UDim2.new(1, 0, 0, 2);
				
				labelFrame.TextLabel.Text = data.Text or "Label";
			end
			
			function section:createTextbox(data: { [string]: any }): () -> ()
				if not data then return end;
				data = Library.Struct(data, false, false);
				local textboxFrame: Frame = ref:FindFirstChild("Textbox"):Clone();
				local textbox: {} = Library.Struct({}, false, false);
				textboxFrame.Parent = sectionFrame.Content;
				textboxFrame.TextLabel.Text = data.Text or "Textbox";
				textboxFrame.Name = data.Text or "Textbox";
				textboxFrame.Frame.pw.Text = data.Default or "";
				Library.Flags[data.Flag or "Textbox"] = data.Default or "";
				
				--// set values
				sectionFrame.Size += UDim2.new(0, 0, 0, 32.5);
				sectionFrame.Underline.Size = UDim2.new(1, 0, 0, 2);
				
				--// hover effects
				local uiStroke: UIStroke = textboxFrame.Frame.pw.outer;
				local button: TextButton = textboxFrame.Frame.pw;

				table.insert(window.Connections, button.MouseEnter:Connect(function()
					local tween = Library:CreateTween(
						{ Color = Color3.fromRGB() },
						{ Color = Library.Menu.Colors.Accent },
						{
							Duration = 0.05,
							Easing = "Quad",
							Direction = "InOut",
							AutoPlay = false
						}
					)

					tween:SetOnUpdate(function(currentValues)
						uiStroke.Color = currentValues.Color
					end)

					tween:Play();
				end));

				table.insert(window.Connections, button.MouseLeave:Connect(function()
					local tween = Library:CreateTween(
						{ Color = Library.Menu.Colors.Accent },
						{ Color = Color3.fromRGB() },
						{
							Duration = 0.05,
							Easing = "Quad",
							Direction = "InOut",
							AutoPlay = false
						}
					)

					tween:SetOnUpdate(function(currentValues)
						uiStroke.Color = currentValues.Color
					end)

					tween:Play();
				end));
				
				table.insert(window.Connections, button.FocusLost:Connect(function()
					Library.Flags[data.Flag or "Textbox"] = button.Text;
					
					if data.Callback then
						task.spawn(data.Callback, button.Text)
					end
				end));
			end
			
			function section:createButton(data: { [string]: any }): () -> ()
				if not data then return end;
				data = Library.Struct(data, false, false);
				local buttonFrame: Frame = ref:FindFirstChild("Button"):Clone();
				local button: {} = Library.Struct({}, false, false);
				buttonFrame.Parent = sectionFrame.Content;
				buttonFrame.TextButton.Text = data.Text or "Button";
				buttonFrame.Name = data.Text or "Button";
				
				--// set values
				sectionFrame.Size += UDim2.new(0, 0, 0, 32.5)
				sectionFrame.Underline.Size = UDim2.new(1, 0, 0, 2)
				
				table.insert(window.Connections, buttonFrame.TextButton.MouseButton1Click:Connect(function()
					if data.Callback then
						task.spawn(data.Callback, os.clock())
					end

					--// lmaoo
					local uiStroke: UIStroke
					for _, child in buttonFrame:GetChildren() do
						if child:IsA("UIStroke") and child.BorderStrokePosition == Enum.BorderStrokePosition.Outer then
							uiStroke = child
							break
						end
					end
					
					if not uiStroke then return end

					local originalColor = uiStroke.Color
					local accentColor = Library.Menu.Colors.Accent

					local tween = Library:CreateTween(
						{ Color = originalColor },
						{ Color = accentColor },
						{
							Duration = 0.05,
							Easing = "Quad",
							Direction = "InOut",
							AutoPlay = false
						}
					)

					tween:SetOnUpdate(function(currentValues)
						uiStroke.Color = currentValues.Color
					end)

					tween:SetOnComplete(function()
						local tweenBack = Library:CreateTween(
							{ Color = accentColor },
							{ Color = originalColor },
							{
								Duration = 0.05,
								Easing = "Quad",
								Direction = "InOut",
								AutoPlay = false
							}
						)
						tweenBack:SetOnUpdate(function(currentValues)
							uiStroke.Color = currentValues.Color;
						end)
						tweenBack:Play();
					end);

					tween:Play();
				end));

				
				local uiGradient: UIGradient = buttonFrame.UIGradient
				local currentTween: any = nil

				local function tweenRotation(targetRotation)
					if currentTween then
						currentTween:Stop(true)
					end
					
					local tween = Library:CreateTween(
						{ Rotation = uiGradient.Rotation },
						{ Rotation = targetRotation },
						{
							Duration = 0.16,
							Easing = "Quad",
							Direction = "InOut",
							AutoPlay = false
						}
					)
					
					currentTween = tween

					tween:SetOnUpdate(function(currentValues)
						uiGradient.Rotation = currentValues.Rotation
					end)

					tween:Play()
				end

				table.insert(window.Connections, buttonFrame.TextButton.MouseEnter:Connect(function()
					tweenRotation(90)
				end))

				table.insert(window.Connections, buttonFrame.TextButton.MouseLeave:Connect(function()
					tweenRotation(-90)
				end))
			end;
			
			function section:createDropdown(data: { [string]: any }): ()
				if not data then return end
				data = Library.Struct(data, false, false)
				Drop_zIndex -= 1

				local dropdownFrame: Frame = ref:FindFirstChild("list"):Clone()
				dropdownFrame.Parent = sectionFrame.Content
				dropdownFrame.TextLabel.Text = data.Text or "Dropdown"
				dropdownFrame.Name = data.Text or "Dropdown"
				dropdownFrame.ZIndex = Drop_zIndex
				
				sectionFrame.Size += UDim2.new(0, 0, 0, 37.5)
				local button = dropdownFrame.bg.main.button
				local uiStroke = dropdownFrame.bg.main.outer

				local flagName = data.Flag or "Dropdown"
				
				table.insert(window.Connections, button.MouseEnter:Connect(function()
					local tween = Library:CreateTween(
						{ Color = Color3.fromRGB() },
						{ Color = Library.Menu.Colors.Accent },
						{
							Duration = 0.05,
							Easing = "Quad",
							Direction = "InOut",
							AutoPlay = false
						}
					)

					tween:SetOnUpdate(function(currentValues)
						uiStroke.Color = currentValues.Color
					end)

					tween:Play();
				end))

				table.insert(window.Connections, button.MouseLeave:Connect(function()
					local tween = Library:CreateTween(
						{ Color = Library.Menu.Colors.Accent },
						{ Color = Color3.fromRGB() },
						{
							Duration = 0.05,
							Easing = "Quad",
							Direction = "InOut",
							AutoPlay = false
						}
					)

					tween:SetOnUpdate(function(currentValues)
						uiStroke.Color = currentValues.Color
					end)

					tween:Play();
				end))

				if data.Multichoice then
					if type(data.Default) == "table" then
						Library.Flags[flagName] = { unpack(data.Default) }
					elseif type(data.Default) == "string" then
						Library.Flags[flagName] = { data.Default }
					else
						Library.Flags[flagName] = {}
					end
				else
					Library.Flags[flagName] = data.Default or data.Options[1] or nil
				end

				local function buildDisplay(): string
					local val = Library.Flags[flagName]
					if data.Multichoice then
						if #val == 0 then return "" end
						return table.concat(val, ", ")
					else
						return tostring(val or "")
					end
				end

				local function updateValue(value: string | {string})
					if data.Multichoice then
						if type(value) == "string" then
							local sel = Library.Flags[flagName]
							local index = table.find(sel, value)
							if index then
								if #sel == 1 then
									return 
								end --// need at least 1 elementz
								
								table.remove(sel, index)
							else
								table.insert(sel, value)
							end
						elseif type(value) == "table" then
							Library.Flags[flagName] = { unpack(value) }
						end
					else
						if type(value) ~= "string" then return end
						Library.Flags[flagName] = value
						dropdownFrame.frame.Visible = false
						dropdownFrame.bg.ImageLabel.Rotation = 0
					end

					dropdownFrame.bg.main.TextLabel.Text = buildDisplay()

					for _, child in dropdownFrame.frame.holder:GetChildren() do
						if child:IsA("Frame") and child:FindFirstChildOfClass("TextLabel") then
							local text = child.TextLabel.Text
							if data.Multichoice then
								if table.find(Library.Flags[flagName], text) then
									child.TextLabel.TextColor3 = Library.Menu.Colors.Accent
								else
									child.TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
								end
							else
								if rawequal(Library.Flags[flagName], text) then
									child.TextLabel.TextColor3 = Library.Menu.Colors.Accent
								else
									child.TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
								end
							end
						end
					end

					if data.Callback then
						task.spawn(data.Callback, Library.Flags[flagName])
					end
				end

				-- create dropdown options in UI
				local function createOptions(arr: { string })
					for idx, option in arr or {} do
						local opt: Frame = dropdownFrame.frame.holder.Sample:Clone()
						opt.Name = option
						opt.Visible = true
						opt.LayoutOrder = idx
						opt.TextLabel.Text = option
						opt.Parent = dropdownFrame.frame.holder
						opt.Parent.Parent.Size += UDim2.new(0, 0, 0, 16)

						-- initial highlight
						if data.Multichoice then
							if table.find(Library.Flags[flagName], option) then
								opt.TextLabel.TextColor3 = Library.Menu.Colors.Accent
							else
								opt.TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
							end
						else
							if rawequal(Library.Flags[flagName], option) then
								opt.TextLabel.TextColor3 = Library.Menu.Colors.Accent
							else
								opt.TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
							end
						end

						opt.TextButton.MouseButton1Click:Connect(function()
							updateValue(option)
						end)
					end

					Library.Options[flagName].values = arr
				end

				dropdownFrame.bg.main.button.MouseButton1Click:Connect(function()
					dropdownFrame.frame.Visible = not dropdownFrame.frame.Visible
					dropdownFrame.bg.ImageLabel.Rotation = dropdownFrame.frame.Visible and 180 or 0
				end)

				table.insert(section.Dropdowns, dropdownFrame)

				Library.Options[flagName] = {
					type = "list",
					changeState = updateValue,
					values = data.Options,
					oldargs = data,
					refresh = createOptions,
				}


				--// hmmmmmm
				createOptions(data.Options)
				updateValue(data.Default or data.Options[1])
			end


			function section:createSlider(data: { [string]: any }): () -> ()
				if not data then return end;
				data = Library.Struct(data, false, false);
				local sliderFrame: Frame = ref:FindFirstChild("Slider"):Clone();
				local slider: {} = Library.Struct({}, false, false);
				sliderFrame.Parent = sectionFrame.Content;
				sliderFrame.TextLabel.Text = data.Text or "Slider";
				sliderFrame.Name = data.Text or "Slider";
				
				--// fetches from slider data
				local min, max, value, callback = data.Min or 0, data.Max or 100, data.Value or 0, data.Callback or nil;
				local entered = false
				local scrolling = false
				local amount = 0
				
				--// states
				local fill = sliderFrame.bg.main:FindFirstChild("fill");
				local valuetext = sliderFrame.bg.main.TextLabel
				local button = sliderFrame.bg.main.TextButton
				assert(fill, "[nocturnal] critical error; slider fetch failed") --// how would this even happen
				
				Library.Flags[data.Flag or "Slider"] = value;
				sectionFrame.Size += UDim2.new(0, 0, 0, 30)
				sectionFrame.Underline.Size = UDim2.new(1, 0, 0, 2)
				
				--// hover effects
				local uiStroke: UIStroke = sliderFrame.bg.main.outer;

				table.insert(window.Connections, button.MouseEnter:Connect(function()
					local tween = Library:CreateTween(
						{ Color = Color3.fromRGB() },
						{ Color = Library.Menu.Colors.Accent },
						{
							Duration = 0.05,
							Easing = "Quad",
							Direction = "InOut",
							AutoPlay = false
						}
					)

					tween:SetOnUpdate(function(currentValues)
						uiStroke.Color = currentValues.Color
					end)

					tween:Play();
				end))

				table.insert(window.Connections, button.MouseLeave:Connect(function()
					local tween = Library:CreateTween(
						{ Color = Library.Menu.Colors.Accent },
						{ Color = Color3.fromRGB() },
						{
							Duration = 0.05,
							Easing = "Quad",
							Direction = "InOut",
							AutoPlay = false
						}
					)

					tween:SetOnUpdate(function(currentValues)
						uiStroke.Color = currentValues.Color
					end)

					tween:Play();
				end))
				
				--// insert for better control in the future
				table.insert(section.Sliders, sliderFrame)
				
				local function updateValue(value)
					if Library.colorpicking then return end
					if value ~= 0 then
						fill:TweenSize(UDim2.new(value/max,0,1,0),Enum.EasingDirection.In,Enum.EasingStyle.Sine,0.01)
					else
						fill:TweenSize(UDim2.new(0,1,1,0),Enum.EasingDirection.In,Enum.EasingStyle.Sine,0.01)
					end
					valuetext.Text = value.."°/"..max.."°"
					Library.Flags[data.Flag or "Slider"] = value
					if callback then
						task.spawn(callback, value)
					end
				end
				
				local step = data.Step or 1

				local function updateScroll()
					if scrolling or Library.scrolling or Library.colorpicking then return end
					while userInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) and screenGui.Enabled and not Library.dragging do
						runService.RenderStepped:Wait()
						Library.scrolling = true
						scrolling = true

						local rawValue = min + ((Library.Mouse.X - button.AbsolutePosition.X) / button.AbsoluteSize.X) * (max - min)
						if rawValue < min then rawValue = min end
						if rawValue > max then rawValue = max end

						local steppedValue = math.floor(rawValue / step + 0.5) * step -- rounds to nearest step
						updateValue(steppedValue)
					end
					
					if not screenGui.Enabled then
						entered = false
					end
					scrolling = false
					Library.scrolling = false
				end
				
				button.MouseEnter:Connect(function()
					if Library.colorpicking then return end
					if scrolling or entered then return end
					entered = true
					while entered do 
						task.wait()
						updateScroll()
					end
				end)
				
				button.MouseLeave:Connect(function()
					entered = false
				end)
				
				if value then
					updateValue(value)
				end
				
				Library.Flags[data.Flag] = 0
				Library.Options[data.Flag] = {type = "slider",changeState = updateValue,oldargs = args}

				updateValue(value or 0)
			end;
			
			function section:createToggle(data: { [string]: any }): () -> ()
				if not data then return end;
				data = Library.Struct(data, false, false);
				local toggle: Frame = ref:FindFirstChild("Toggle"):Clone();
				local toggles: {} = Library.Struct({
					Bound = false,
					Binds = Library.Struct({}, false, false)
				}, false, false)
				toggle.Name = data.Text or "Toggle";
				toggle.TextLabel.Text = data.Text or "Toggle";
				toggle.Parent = sectionFrame.Content;
				
				--// states
				Library.Flags[data.Flag or "Toggle"] = false;
				sectionFrame.Size += UDim2.new(0, 0, 0, 21.5)
				sectionFrame.Underline.Size = UDim2.new(1, 0, 0, 2)

				--// connections
				table.insert(window.Connections, toggle.TextButton.MouseEnter:Connect(function()
					local uiStroke: UIStroke = toggle.Frame.outer;
					
					local tween = Library:CreateTween(
						{ Color = Color3.fromRGB() },
						{ Color = Library.Menu.Colors.Accent },
						{
							Duration = 0.05,
							Easing = "Quad",
							Direction = "InOut",
							AutoPlay = false
						}
					)

					tween:SetOnUpdate(function(currentValues)
						uiStroke.Color = currentValues.Color
					end)

					tween:Play();
				end))
				
				table.insert(window.Connections, toggle.TextButton.MouseLeave:Connect(function()
					local uiStroke: UIStroke = toggle.Frame.outer;

					local tween = Library:CreateTween(
						{ Color = Library.Menu.Colors.Accent },
						{ Color = Color3.fromRGB() },
						{
							Duration = 0.05,
							Easing = "Quad",
							Direction = "InOut",
							AutoPlay = false
						}
					)

					tween:SetOnUpdate(function(currentValues)
						uiStroke.Color = currentValues.Color
					end)

					tween:Play();
				end))
				
				local flagName = data.Flag or "Toggle"
				
				local function changeState(newState: boolean)
					Library.Flags[flagName] = newState
					local toggleFrame = toggle

					if newState then
						toggleFrame.Frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
						toggleFrame.Frame.Disabled.Enabled = false
						toggleFrame.Frame.Enabled.Enabled = true
					else
						toggleFrame.Frame.BackgroundColor3 = Color3.fromRGB(27, 25, 27)
						toggleFrame.Frame.Disabled.Enabled = true
						toggleFrame.Frame.Enabled.Enabled = false
					end

					if data.Callback then
						task.spawn(data.Callback, newState)
					end
					
					if window.List and toggles.Bound then
						if not rawequal(toggle.bind.TextButton.Text, "Unknown") then
							window:updateBindEntry({ State =  toggles:getState(), Key = toggle.bind.TextButton.Text, Feature = toggle.TextLabel.Text})
						end
					end
				end
				
				function toggles:updateState(): () -> () -> nil 
					local value: boolean = Library.Flags[data.Flag]

					value = not value
					Library.Flags[data.Flag or "Toggle"] = value

					if value then
						toggle.Frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
						toggle.Frame.Disabled.Enabled = false
						toggle.Frame.Enabled.Enabled = true
					else
						toggle.Frame.BackgroundColor3 = Color3.fromRGB(27, 25, 27)
						toggle.Frame.Disabled.Enabled = true
						toggle.Frame.Enabled.Enabled = false
					end

					if data.Callback then
						task.spawn(data.Callback, value)
					end;
					
					if window.List and toggles.Bound then
						if not rawequal(toggle.bind.TextButton.Text, "Unknown") then
							window:updateBindEntry({ State =  toggles:getState(), Key = toggle.bind.TextButton.Text, Feature = toggle.TextLabel.Text, Mode = data.Mode or "Toggle" })
						end
					end
				end;
				
				function toggles:getState(): () -> () -> nil 
					return Library.Flags[data.Flag] or false
				end;
				
				table.insert(window.Connections, toggle.TextButton.MouseButton1Click:Connect(function()
					changeState(not Library.Flags[flagName])
				end))
				
				table.insert(section.Toggles, toggle)
				
				Library.Options[flagName] = {
					type = "toggle",
					changeState = changeState,
					oldargs = data
				}
				
				if #section.Toggles > 100 then
					return
				end
				
				
				function toggles:createBind(data: { [string]: any }): () -> ()
					if not data then return end;
					data = Library.Struct(data, false, false);
					toggles.Bound = true;
					local bind = toggle.bind;
					bind.Visible = true;
					local button = bind.TextButton;
					local next = false;
					
					local function updateValue(val): () -> ()
						if Library.colorpicking then return end;
						Library.Flags[data.Flag or "Keybind"] = val;
						button.Text = Library.Keys[val] or val.Name;
					end;
					
					userInputService.InputBegan:Connect(function(key): ()
						local key = key.KeyCode == Enum.KeyCode.Unknown and key.UserInputType or key.KeyCode;
						
						if next then
							if not table.find(Library.BlacklistedKeys, key) then
								next = false;
								Library.Flags[data.Flag or "Keybind"] = key;
								button.Text = Library.Keys[key] or key.Name;
								button.TextColor3 = Color3.fromRGB(155, 155, 155);
							end;
						end;
						
						if not next and key == Library.Flags[data.Flag or "Keybind"] and data.Callback then
							--// sometimes it shouldn't trigger the original toggle
							if not data.Ignore then
								toggles:updateState()
							end
							
							task.spawn(data.Callback, key);
							task.spawn(function()
								if data.PlsIgnore then
									return
								else
									if window.List then
										window:createBindEntry({ Key = Library.Keys[key] or key.Name, Feature = toggle.TextLabel.Text, Mode = data.Mode or "Toggle" })
										window:updateBindEntry({ State =  toggles:getState(), Key = Library.Keys[key] or key.Name; Feature = toggle.TextLabel.Text, Mode = data.Mode or "Toggle" })
									end
								end
							end)
						end
					end);

					button.MouseButton1Click:Connect(function()
						if Library.colorpicking then return end
						Library.Flags[data.Flag or "Keybind"] = Enum.KeyCode.Unknown
						button.Text = "--"
						button.TextColor3 = Library.Menu.Colors.Accent
						next = true
					end);

					Library.Flags[data.Flag or "Keybind"] = Enum.KeyCode.Unknown;
					Library.Options[data.Flag] = {type = "keybind",changeState = updateValue,oldargs = args}

					updateValue(data.Default or Enum.KeyCode.Unknown);
				end
				
				function toggles:createColorpicker(data: { [string]: any }): () -> ()
					if not data then return end;
					data = Library.Struct(data, false, false);
					local picker: ColorPicker = {
						Name = data.Text or "Colorpicker",
						Color = data.Default or Color3.new(1, 1, 1),
						SetColor = function(e)
							toggle.Colorpicker.BackgroundColor3 = e
						end
					}
					--// TODO: Add colorpicker logic
					local Colorpicker: Frame = toggle.Colorpicker;
					Colorpicker.Visible = true;
					Colorpicker.Parent.ZIndex += 1 --// weird
					
					local colorpicker = Instance.new("Frame")
					local mid = Instance.new("Frame")
					local front = Instance.new("Frame")
					local button2 = Instance.new("TextButton")
					local colorFrame = Instance.new("Frame")
					local colorFrame_2 = Instance.new("Frame")
					local hueframe = Instance.new("Frame")
					local main = Instance.new("Frame")
					local hue = Instance.new("ImageLabel")
					local pickerframe = Instance.new("Frame")
					local main_2 = Instance.new("Frame")
					local picker2 = Instance.new("ImageLabel")
					local clr = Instance.new("Frame")
					local copy = Instance.new("TextButton")




					button2.Name = "button2"
					button2.Parent = Colorpicker
					button2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					button2.BackgroundTransparency = 1.000
					button2.Size = UDim2.new(1, 0, 1, 0)
					button2.Text = ""
					button2.Font = Enum.Font.SourceSans
					button2.TextColor3 = Color3.fromRGB(0, 0, 0)
					button2.TextSize = 14.000

					colorFrame.Name = "colorFrame"
					colorFrame.Parent = toggle
					colorFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
					colorFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
					colorFrame.BorderSizePixel = 2
					colorFrame.Position = UDim2.new(0.101092957, 0, 0.75, 0)
					colorFrame.Size = UDim2.new(0, 137, 0, 128)
					colorFrame.Visible = false
					colorFrame.ZIndex = 685486548

					local screenGuiZ = toggle:FindFirstAncestorWhichIsA("ScreenGui")
					if not screenGuiZ then
						return
					end

					colorFrame.Parent = screenGuiZ
					colorFrame.AnchorPoint = Vector2.new(1, 0) -- top-right corner
					colorFrame.Position = UDim2.new(1, -10, 0, 10) -- 10px margin from top-right

					colorFrame_2.Name = "colorFrame"
					colorFrame_2.Parent = colorFrame
					colorFrame_2.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
					colorFrame_2.BorderColor3 = Color3.fromRGB(60, 60, 60)
					colorFrame_2.Size = UDim2.new(1, 0, 1, 0)

					hueframe.Name = "hueframe"
					hueframe.Parent = colorFrame_2
					hueframe.Parent = colorFrame_2
					hueframe.BackgroundColor3 = Color3.fromRGB(34, 34, 34)
					hueframe.BorderColor3 = Color3.fromRGB(60, 60, 60)
					hueframe.BorderSizePixel = 2
					hueframe.Position = UDim2.new(-0.0930000022, 18, -0.0599999987, 30)
					hueframe.Size = UDim2.new(0, 100, 0, 100)

					main.Name = "main"
					main.Parent = hueframe
					main.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
					main.BorderColor3 = Color3.fromRGB(0, 0, 0)
					main.Size = UDim2.new(0, 100, 0, 100)
					main.ZIndex = 8677777777777777

					picker2.Name = "picker"
					picker2.Parent = main
					picker2.BackgroundColor3 = Color3.fromRGB(232, 0, 255)
					picker2.BorderColor3 = Color3.fromRGB(0, 0, 0)
					picker2.BorderSizePixel = 0
					picker2.Size = UDim2.new(0, 100, 0, 100)
					picker2.ZIndex = 687678678
					picker2.Image = "rbxassetid://2615689005"

					pickerframe.Name = "pickerframe"
					pickerframe.Parent = colorFrame
					pickerframe.BackgroundColor3 = Color3.fromRGB(34, 34, 34)
					pickerframe.BorderColor3 = Color3.fromRGB(60, 60, 60)
					pickerframe.BorderSizePixel = 2
					pickerframe.Position = UDim2.new(0.711000025, 14, -0.0599999987, 30)
					pickerframe.Size = UDim2.new(0, 20, 0, 100)

					main_2.Name = "main"
					main_2.Parent = pickerframe
					main_2.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
					main_2.BorderColor3 = Color3.fromRGB(0, 0, 0)
					main_2.Size = UDim2.new(0, 20, 0, 100)
					main_2.ZIndex = 6

					hue.Name = "hue"
					hue.Parent = main_2
					hue.BackgroundColor3 = Color3.fromRGB(255, 0, 178)
					hue.BorderColor3 = Color3.fromRGB(0, 0, 0)
					hue.BorderSizePixel = 0
					hue.Size = UDim2.new(0, 20, 0, 100)
					hue.ZIndex = 104
					hue.Image = "rbxassetid://2615692420"

					clr.Name = "clr"
					clr.Parent = colorFrame
					clr.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
					clr.BackgroundTransparency = 1.000
					clr.BorderColor3 = Color3.fromRGB(60, 60, 60)
					clr.BorderSizePixel = 2
					clr.Position = UDim2.new(0.0280000009, 0, 0, 2)
					clr.Size = UDim2.new(0, 129, 0, 14)
					clr.ZIndex = 5

					copy.Name = "copy"
					copy.Parent = clr
					copy.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
					copy.BackgroundTransparency = 1.000
					copy.BorderSizePixel = 0
					copy.Size = UDim2.new(0, 129, 0, 14)
					copy.ZIndex = 5
					copy.Font = Enum.Font.SourceSans
					copy.Text = data.Text or "Colorpicker"
					copy.TextColor3 = Color3.fromRGB(100, 100, 100)
					copy.TextSize = 14.000
					copy.TextStrokeTransparency = 0.000

					copy.MouseButton1Click:Connect(function() -- "  "..args.text or "  "..args.flag
						colorFrame.Visible = false
					end)

					button2.MouseButton1Click:Connect(function()
						colorFrame.Visible = not colorFrame.Visible
						--mid.BorderColor3 = Color3.fromRGB(60, 60, 60)
					end)
					
					local uiStroke: UIStroke = Colorpicker.outer;
					local button: TextButton = button2;

					table.insert(window.Connections, button.MouseEnter:Connect(function()
						local tween = Library:CreateTween(
							{ Color = Color3.fromRGB() },
							{ Color = Library.Menu.Colors.Accent },
							{
								Duration = 0.05,
								Easing = "Quad",
								Direction = "InOut",
								AutoPlay = false
							}
						)

						tween:SetOnUpdate(function(currentValues)
							uiStroke.Color = currentValues.Color
						end)

						tween:Play();
					end))

					table.insert(window.Connections, button.MouseLeave:Connect(function()
						local tween = Library:CreateTween(
							{ Color = Library.Menu.Colors.Accent },
							{ Color = Color3.fromRGB() },
							{
								Duration = 0.05,
								Easing = "Quad",
								Direction = "InOut",
								AutoPlay = false
							}
						)

						tween:SetOnUpdate(function(currentValues)
							uiStroke.Color = currentValues.Color
						end)

						tween:Play();
					end))


					local function updateValue(value,fakevalue)
						if typeof(value) == "table" then value = fakevalue end
						picker:SetColor(value)
						front.BackgroundColor3 = value
						Library.Flags[data.Flag or "Colorpicker"] = value
						if data.Callback then
							task.spawn(data.Callback, value)
						end
					end

					local white, black = Color3.new(1,1,1), Color3.new(0,0,0)
					local colors = {Color3.new(1,0,0),Color3.new(1,1,0),Color3.new(0,1,0),Color3.new(0,1,1),Color3.new(0,0,1),Color3.new(1,0,1),Color3.new(1,0,0)}
					local heartbeat = game:GetService("RunService").Heartbeat

					local pickerX,pickerY,hueY = 0,0,0
					local oldpercentX,oldpercentY = 0,0

					hue.MouseEnter:Connect(function()
						local input = hue.InputBegan:Connect(function(key)
							if key.UserInputType == Enum.UserInputType.MouseButton1 then
								while heartbeat:wait() and userInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
									Library.colorpicking = true
									local percent = (hueY-hue.AbsolutePosition.Y-36)/hue.AbsoluteSize.Y
									local num = max(1, min(7,floor(((percent*7+0.5)*100))/100))
									local startC = colors[floor(num)]
									local endC = colors[ceil(num)]
									local color = white:lerp(picker2.BackgroundColor3, oldpercentX):lerp(black, oldpercentY)
									picker2.BackgroundColor3 = startC:lerp(endC, num-floor(num)) or Color3.new(0, 0, 0)
									updateValue(color)
								end
								Library.colorpicking = false
							end
						end)
						
						local leave
						leave = hue.MouseLeave:Connect(function()
							input:disconnect()
							leave:disconnect()
						end)
					end)

					picker2.MouseEnter:Connect(function()
						local input = picker2.InputBegan:Connect(function(key)
							if key.UserInputType == Enum.UserInputType.MouseButton1 then
								while heartbeat:wait() and userInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
									Library.colorpicking = true
									local xPercent = (pickerX-picker2.AbsolutePosition.X)/picker2.AbsoluteSize.X
									local yPercent = (pickerY-picker2.AbsolutePosition.Y-36)/picker2.AbsoluteSize.Y
									local color = white:lerp(picker2.BackgroundColor3, xPercent):lerp(black, yPercent)
									updateValue(color)
									oldpercentX,oldpercentY = xPercent,yPercent
								end
								
								Library.colorpicking = false
							end
						end)
						local leave
						leave = picker2.MouseLeave:connect(function()
							input:disconnect()
							leave:disconnect()
						end)
					end)

					hue.MouseMoved:connect(function(_, y)
						hueY = y
					end)

					picker2.MouseMoved:connect(function(x, y)
						pickerX,pickerY = x,y
					end)



					function picker:SetColor(c: Color3)
						self.Color = c
						Colorpicker.BackgroundColor3 = c
					end
					
					updateValue(data.Default or Color3.fromRGB(255, 255, 255))
					Library.Options[data.Flag or "ColorpickerYes"] = {type = "colorpicker", changeState = updateValue, args = data}

					return picker
				end;
				
				return toggles;
			end;
			
			table.insert(tab.Sections, sectionFrame)
			return section;
		end;
		
		--// select first one
		if rawequal(#window.Tabs, 1) then
			tab:selectTab({ Tab = tabBtn.Name });
		end;
		
		return tab;
	end;
	
	--// cleanup
	Library.Menu.IsLoaded = true;

	return window;
end;

return Library;
