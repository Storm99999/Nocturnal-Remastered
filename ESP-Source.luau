--// Services
local RunService: RunService = game:GetService("RunService");
local Players: Players = game:GetService("Players");
local Workspace: Workspace = game:GetService("Workspace");
local CoreGui: Instance = game:GetService("CoreGui");
local LocalPlayer: Player? = Players.LocalPlayer;
local Camera: Camera = Workspace.CurrentCamera;
local ViewportSize: Vector2 = Camera and Camera.ViewportSize or Vector2.new(0, 0);
local Container: Instance = Instance.new("Folder", (RunService:IsStudio() and LocalPlayer.PlayerGui or (gethui and gethui() or CoreGui)));

--// Aliases
local Floor, Round, Atan2, Sin, Cos, TableClear, Unpack, TableFind, TableCreate =
	math.floor, math.round, math.atan2, math.sin, math.cos, table.clear, table.unpack, table.find, table.create;
local WtVp, IsA, GetPivot, FindFirstChild, FindFirstChildOfClass, GetChildren =
	Camera.WorldToViewportPoint, Workspace.IsA, Workspace.GetPivot, Workspace.FindFirstChild, Workspace.FindFirstChildOfClass, Workspace.GetChildren;
local ToOrientation, PointToObjectSpace = CFrame.identity.ToOrientation, CFrame.identity.PointToObjectSpace;
local LerpColor = Color3.new().Lerp;
local Min2, Max2, Lerp2 = Vector2.zero.Min, Vector2.zero.Max, Vector2.zero.Lerp;
local Min3, Max3 = Vector3.zero.Min, Vector3.zero.Max;

--// Constants
local HEALTH_BAR_OFFSET: Vector2 = Vector2.new(5, 0);
local HEALTH_TEXT_OFFSET: Vector2 = Vector2.new(3, 0);
local HEALTH_BAR_OUTLINE_OFFSET: Vector2 = Vector2.new(0, 1);
local NAME_OFFSET: Vector2 = Vector2.new(0, 2);
local DISTANCE_OFFSET: Vector2 = Vector2.new(0, 2);
local VERTICES: { Vector3 } = {
	Vector3.new(-1, -1, -1),
	Vector3.new(-1, 1, -1),
	Vector3.new(-1, 1, 1),
	Vector3.new(-1, -1, 1),
	Vector3.new(1, -1, -1),
	Vector3.new(1, 1, -1),
	Vector3.new(1, 1, 1),
	Vector3.new(1, -1, 1)
};

local SKELETON_BONE_DEFS = {
	{"Head", "UpperTorso|Torso"},
	{"UpperTorso|Torso", "LowerTorso|Torso"},
	{"UpperTorso|Torso", "LeftUpperArm|Left Arm|LeftArm"},
	{"LeftUpperArm|Left Arm|LeftArm", "LeftLowerArm|LeftLowerArm"},
	{"LeftLowerArm|Left Lower Arm|LeftLowerArm", "LeftHand|Left Hand|LeftHand"},
	{"UpperTorso|Torso", "RightUpperArm|Right Arm|RightArm"},
	{"RightUpperArm|Right Arm|RightArm", "RightLowerArm|RightLowerArm"},
	{"RightLowerArm|Right Lower Arm|RightLowerArm", "RightHand|Right Hand|RightHand"},
	{"LowerTorso|Torso", "LeftUpperLeg|Left Leg|LeftUpperLeg"},
	{"LeftUpperLeg|Left Leg|LeftUpperLeg", "LeftLowerLeg|LeftLowerLeg"},
	{"LeftLowerLeg|Left Lower Leg|LeftLowerLeg", "LeftFoot|Left Foot|LeftFoot"},
	{"LowerTorso|Torso", "RightUpperLeg|Right Leg|RightUpperLeg"},
	{"RightUpperLeg|Right Leg|RightUpperLeg", "RightLowerLeg|RightLowerLeg"},
	{"RightLowerLeg|Right Lower Leg|RightLowerLeg", "RightFoot|Right Foot|RightFoot"},
	{"Torso", "Left Arm|LeftArm"},
	{"Torso", "Right Arm|RightArm"},
	{"Torso", "Left Leg|LeftLeg"},
	{"Torso", "Right Leg|RightLeg"}
};

local Fading: { Player } = {};

--// Types
type EspObject = {
	Player: Player,
	Interface: table,
	RenderConnection: RBXScriptConnection?,
};

type Corners = {
	corners: { Vector2 },
	topLeft: Vector2,
	topRight: Vector2,
	bottomLeft: Vector2,
	bottomRight: Vector2
};

--// Utilities
function Tween(InstanceObj: any, InstanceTo: { [string]: number }, InstanceTime: number): ()
	local CurrentTime: number = 0;
	local CurrentIndex: { [string]: number } = {};
	local Connection: RBXScriptConnection?;

	for Property, Value in InstanceTo do
		CurrentIndex[Property] = InstanceObj[Property];
	end;

	local function Interpolate(): ()
		for Property, TargetValue in InstanceTo do
			local StartValue = CurrentIndex[Property] or 0;
			InstanceObj[Property] = ((TargetValue - StartValue) * CurrentTime / InstanceTime) + StartValue;
		end;
	end;

	Connection = RunService.RenderStepped:Connect(function(Delta: number): ()
		if CurrentTime < InstanceTime then
			CurrentTime = CurrentTime + Delta;
			Interpolate();
		else
			Connection:Disconnect();
		end;
	end);
end;

function FadeOut(PlayerObj: Player, FadeTime: number?, EnvironmentTable: {}): ()
	local FadeDuration = FadeTime or 1;
	if Fading[PlayerObj] then return end;
	Fading[PlayerObj] = true;

	local Objects = EnvironmentTable._object_cache and EnvironmentTable._object_cache[PlayerObj] or EnvironmentTable._objectCache and EnvironmentTable._objectCache[PlayerObj];

    if not Objects then return end;

	for i = 1, #Objects do
		local Obj = Objects[i];
		if Obj.bin then
			for j = 1, #Obj.bin do
				local DrawingObj = Obj.bin[j];
				if DrawingObj.Visible then
					Tween(DrawingObj, { Transparency = 0 }, FadeDuration);
				end;
			end;
		end;

		if Obj.highlight and Obj.highlight:IsA("Highlight") then
			--// OOPS
		else
			task.delay(FadeDuration * 1.5, function()
				Fading[PlayerObj] = nil;
			end);
		end;
	end;
end;

function CreateThread(Func, ...): ( any, { [any]: any } ) -> ()
	local Thread: any = coroutine.create(Func);
	coroutine.resume(Thread, ...);
	return Thread;
end;

function MultiThreadList(Obj: { [number]: any } | { [string]: any }, ...: any): nil
	local n: number = #Obj;
	if n > 0 then
		for i = 1, n do
			local t = Obj[i];
			local ttype = type(t);
			if ttype == "table" then
				local d: number = #t;
				assert(d ~= 0, "table inserted was not an array or was empty");
				assert(d < 3, ("invalid number of arguments (%d)"):format(d));
				local thetype = type(t[1]);
				assert(thetype == "function", ("invalid argument #1: expected 'function', got '%s'"):format(tostring(thetype)));
				if d == 1 then
					CreateThread(t[1]);
				else
					local args = t[2];
					assert(type(args) == "table", "argument list must be a table");
					CreateThread(t[1], Unpack(args));
				end;
			else
				CreateThread(t, ...);
			end;
		end;
	else
		for k, v in Obj do
			CreateThread(v, ...);
		end;
	end;
end;

local function IsBodyPart(Name: string): boolean
	return Name == "Head" or Name:find("Torso") or Name:find("Leg") or Name:find("Arm");
end;

local function GetBoundingBox(Parts: { BasePart }): (CFrame, Vector3)
	local MinV: Vector3?
	local MaxV: Vector3?
	for i = 1, #Parts do
		local p = Parts[i];
		local cf, s = p.CFrame, p.Size;
		MinV = Min3(MinV or cf.Position, (cf - s * 0.5).Position);
		MaxV = Max3(MaxV or cf.Position, (cf + s * 0.5).Position);
	end;

	local Center = (MinV + MaxV) * 0.5;
	local Front = Vector3.new(Center.X, Center.Y, MaxV.Z);
	return CFrame.new(Center, Front), (MaxV - MinV);
end;

local function WorldToScreen(World: Vector3): (Vector2, boolean, number)
	local Screen, InBounds = WtVp(Camera, World);
	return Vector2.new(Screen.X, Screen.Y), InBounds, Screen.Z;
end;

local function CalculateCorners(CFrameObj: CFrame, Size: Vector3): Corners
	local CornerScreens: { Vector2 } = TableCreate(#VERTICES);
	for i = 1, #VERTICES do
		local WorldPos = (CFrameObj + Size * 0.5 * VERTICES[i]).Position;
		CornerScreens[i] = WorldToScreen(WorldPos);
	end;

	local MinV = Min2(ViewportSize, Unpack(CornerScreens));
	local MaxV = Max2(Vector2.zero, Unpack(CornerScreens));
	return {
		corners = CornerScreens,
		topLeft = Vector2.new(Floor(MinV.X), Floor(MinV.Y)),
		topRight = Vector2.new(Floor(MaxV.X), Floor(MinV.Y)),
		bottomLeft = Vector2.new(Floor(MinV.X), Floor(MaxV.Y)),
		bottomRight = Vector2.new(Floor(MaxV.X), Floor(MaxV.Y))
	};
end;

local function RotateVector(VectorObj: Vector2, Radians: number): Vector2
	local c, s = Cos(Radians), Sin(Radians);
	return Vector2.new(c * VectorObj.X - s * VectorObj.Y, s * VectorObj.X + c * VectorObj.Y);
end;

local function ParseColor(Self: any, ColorOrToken: any, IsOutline: boolean?): Color3
	if ColorOrToken == "Team Color" or (Self.Interface.sharedSettings.useTeamColor and not IsOutline) then
		return Self.Interface.getTeamColor(Self.Player) or Color3.new(1, 1, 1);
	end;
	return ColorOrToken;
end;

if Camera then
	Camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
		ViewportSize = Camera.ViewportSize;
	end);
end;

local function SplitPatterns(Pattern: string)
	local Out = {};
	for Token in Pattern:gmatch("[^|]+") do
		Out[#Out + 1] = Token;
	end;
	return Out;
end;

local function FindPartByPatterns(Character: Model, Pattern: string)
	if not Character then return nil end;
	local Parts = GetChildren(Character);
	local Patterns = SplitPatterns(Pattern);

	for i = 1, #Patterns do
		local Alt = Patterns[i];
		local Exact = FindFirstChild(Character, Alt);
		if Exact and IsA(Exact, "BasePart") then
			return Exact;
		end;
	end;

	for i = 1, #Parts do
		local p = Parts[i];
		if IsA(p, "BasePart") then
			local Lower = p.Name:lower();
			for j = 1, #Patterns do
				local a = Patterns[j]:lower();
				if Lower:find(a) then
					return p;
				end;
			end;
		end;
	end;

	return nil;
end;

local EspObject = {};
EspObject.__index = EspObject;

function EspObject.New(PlayerObj: Player, Interface: table): EspObject
	local Self = setmetatable({}, EspObject) :: any;
	Self.Player = assert(PlayerObj, "Missing argument #1 (Player expected)");
	Self.Interface = assert(Interface, "Missing argument #2 (table expected)");
	Self:Construct();
	return Self :: EspObject;
end;

function EspObject:_Create(ClassName: string, Properties: table): any
	local DrawingObj = Drawing.new(ClassName);
	for Key, Value in Properties do
		DrawingObj[Key] = Value;
	end;
	self.bin[#self.bin + 1] = DrawingObj;
	return DrawingObj;
end;

function EspObject:Construct(): nil
	self.charCache = {};
	self.childCount = 0;
	self.bin = {};
	self.skeletonBones = {};

	--// visible drawings
	self.drawings = {
		box3d = {
			{self:_Create("Line", {Thickness = 1, Visible = false}), self:_Create("Line", {Thickness = 1, Visible = false}), self:_Create("Line", {Thickness = 1, Visible = false})},
			{self:_Create("Line", {Thickness = 1, Visible = false}), self:_Create("Line", {Thickness = 1, Visible = false}), self:_Create("Line", {Thickness = 1, Visible = false})},
			{self:_Create("Line", {Thickness = 1, Visible = false}), self:_Create("Line", {Thickness = 1, Visible = false}), self:_Create("Line", {Thickness = 1, Visible = false})},
			{self:_Create("Line", {Thickness = 1, Visible = false}), self:_Create("Line", {Thickness = 1, Visible = false}), self:_Create("Line", {Thickness = 1, Visible = false})}
		},
		visible = {
			tracerOutline = self:_Create("Line", {Thickness = 3, Visible = false}),
			tracer = self:_Create("Line", {Thickness = 1, Visible = false}),
			boxFill = self:_Create("Square", {Filled = true, Visible = false}),
			boxOutline = self:_Create("Square", {Thickness = 3, Visible = false}),
			box = self:_Create("Square", {Thickness = 1, Visible = false}),
			healthBarOutline = self:_Create("Line", {Thickness = 3, Visible = false}),
			healthBar = self:_Create("Line", {Thickness = 1, Visible = false}),
			healthText = self:_Create("Text", {Center = true, Visible = false}),
			name = self:_Create("Text", {Text = self.Player.DisplayName, Center = true, Visible = false}),
			distance = self:_Create("Text", {Center = true, Visible = false}),
			weapon = self:_Create("Text", {Center = true, Visible = false}),

			--// corners: for each corner we create 4 lines: hOutline, h, vOutline, v
			corners = {
				{ self:_Create("Line", {Thickness = 3, Visible = false}), self:_Create("Line", {Thickness = 1, Visible = false}), self:_Create("Line", {Thickness = 3, Visible = false}), self:_Create("Line", {Thickness = 1, Visible = false}) },
				{ self:_Create("Line", {Thickness = 3, Visible = false}), self:_Create("Line", {Thickness = 1, Visible = false}), self:_Create("Line", {Thickness = 3, Visible = false}), self:_Create("Line", {Thickness = 1, Visible = false}) },
				{ self:_Create("Line", {Thickness = 3, Visible = false}), self:_Create("Line", {Thickness = 1, Visible = false}), self:_Create("Line", {Thickness = 3, Visible = false}), self:_Create("Line", {Thickness = 1, Visible = false}) },
				{ self:_Create("Line", {Thickness = 3, Visible = false}), self:_Create("Line", {Thickness = 1, Visible = false}), self:_Create("Line", {Thickness = 3, Visible = false}), self:_Create("Line", {Thickness = 1, Visible = false}) }
			}
		},
		hidden = {
			arrowOutline = self:_Create("Triangle", {Thickness = 3, Visible = false}),
			arrow = self:_Create("Triangle", {Filled = true, Visible = false})
		},
		skeleton = {
			outline = {},
			lines = {}
		}
	};

	--// pre-create skeleton lines
	for i = 1, 20 do
		self.drawings.skeleton.outline[i] = self:_Create("Line", {Thickness = 3, Visible = false});
		self.drawings.skeleton.lines[i] = self:_Create("Line", {Thickness = 1, Visible = false});
	end;

	--// render
	self.renderConnection = RunService.Heartbeat:Connect(function(dt)
		self:Update(dt);
		self:Render(dt);

		local Plrs = Players:GetPlayers();
		for i = 1, #Plrs do
			local p = Plrs[i];
			local obj = self.Interface._objectCache[p];
			if obj then
				local Health, _ = self.Interface.getHealth(p);
				if Health <= 0 then
					FadeOut(p, 1, self.Interface);
				end;
			end;
		end;
	end);
end;

function EspObject:Destruct(): nil
	if self.renderConnection then
		self.renderConnection:Disconnect();
	end;
	for i = 1, #self.bin do
		self.bin[i]:Remove();
	end;
	TableClear(self);
end;

function EspObject:Update(): nil
	local Interface = self.Interface;
	self.options = Interface.teamSettings[Interface.isFriendly(self.Player) and "friendly" or "enemy"];
	self.character = Interface.getCharacter(self.Player);
	self.health, self.maxHealth = Interface.getHealth(self.Player);
	self.weapon = Interface.getWeapon(self.Player);
	self.enabled = self.options.enabled and self.character and not (#Interface.whitelist > 0 and not TableFind(Interface.whitelist, self.Player.UserId));

	local Head = self.enabled and FindFirstChild(self.character, "Head");
	if not Head then
		self.charCache = {};
		self.skeletonBones = {};
		return;
	end;

	local _, OnScreen, Depth = WorldToScreen(Head.Position);
	self.onScreen = OnScreen;
	self.distance = Depth;

	if Interface.sharedSettings.limitDistance and Depth > Interface.sharedSettings.maxDistance then
		self.onScreen = false;
	end;

	if self.onScreen then
		local Cache = self.charCache;
		local Children = GetChildren(self.character);
		if not Cache[1] or self.childCount ~= #Children then
			TableClear(Cache);
			for i = 1, #Children do
				local Part = Children[i];
				if IsA(Part, "BasePart") and IsBodyPart(Part.Name) then
					Cache[#Cache + 1] = Part;
				end;
			end;
			self.childCount = #Children;
		end;
		local CFrameObj, SizeObj = GetBoundingBox(Cache);
		self.corners = CalculateCorners(CFrameObj, SizeObj);

		--// skeleton
		TableClear(self.skeletonBones);
		for i = 1, #SKELETON_BONE_DEFS do
			local Def = SKELETON_BONE_DEFS[i];
			local APattern, BPattern = Def[1], Def[2];
			local APart = FindPartByPatterns(self.character, APattern);
			local BPart = FindPartByPatterns(self.character, BPattern);
			if APart and BPart and APart ~= BPart then
				self.skeletonBones[#self.skeletonBones + 1] = {APart, BPart};
			end;
		end;
	else
		if self.options.offScreenArrow then
			local _, Yaw, Roll = ToOrientation(Camera.CFrame);
			local FlatCFrame = CFrame.Angles(0, Yaw, Roll) + Camera.CFrame.Position;
			local ObjectSpace = PointToObjectSpace(FlatCFrame, Head.Position);
			local Angle = Atan2(ObjectSpace.Z, ObjectSpace.X);
			self.direction = Vector2.new(Cos(Angle), Sin(Angle));
		end;
	end;
end;

function EspObject:Render(): nil
	local OnScreen: boolean = self.onScreen or false;
	local Enabled: boolean = self.enabled or false;
	local Visible = self.drawings.visible;
	local Hidden = self.drawings.hidden;
	local Box3D = self.drawings.box3d;
	local Interface = self.Interface;
	local Options = self.options;
	local CornersObj: Corners? = self.corners;
	local Faded: boolean = Fading[self.Player];

	--// box
	Visible.box.Visible = Enabled and OnScreen and Options.box;
	Visible.boxOutline.Visible = Visible.box.Visible and Options.boxOutline;
	if Visible.box.Visible and CornersObj then
		local Box = Visible.box;
		Box.Position = CornersObj.topLeft;
		Box.Size = CornersObj.bottomRight - CornersObj.topLeft;
		Box.Color = ParseColor(self, Options.boxColor[1]);

		if not Faded then
			Box.Transparency = Options.boxColor[2];
		end;

		local BoxOutline = Visible.boxOutline;
		BoxOutline.Position = Box.Position;
		BoxOutline.Size = Box.Size;
		BoxOutline.Color = ParseColor(self, Options.boxOutlineColor[1], true);

		if not Faded then
			BoxOutline.Transparency = Options.boxOutlineColor[2];
		end;
	end;

	--// box fill
	Visible.boxFill.Visible = Enabled and OnScreen and Options.boxFill;
	if Visible.boxFill.Visible and CornersObj then
		local BoxFill = Visible.boxFill;
		BoxFill.Position = CornersObj.topLeft;
		BoxFill.Size = CornersObj.bottomRight - CornersObj.topLeft;
		BoxFill.Color = ParseColor(self, Options.boxFillColor[1]);

		if not Faded then
			BoxFill.Transparency = Options.boxFillColor[2];
		end;
	end;

	--// health bar
	Visible.healthBar.Visible = Enabled and OnScreen and Options.healthBar;
	Visible.healthBarOutline.Visible = Visible.healthBar.Visible and Options.healthBarOutline;
	if Visible.healthBar.Visible and CornersObj then
		local BarFrom = CornersObj.topLeft - HEALTH_BAR_OFFSET;
		local BarTo = CornersObj.bottomLeft - HEALTH_BAR_OFFSET;

		local HealthBar = Visible.healthBar;
		HealthBar.To = BarTo;
		HealthBar.From = Lerp2(BarTo, BarFrom, (self.health / self.maxHealth));
		HealthBar.Color = LerpColor(Options.dyingColor, Options.healthyColor, (self.health / self.maxHealth));

		local HealthBarOutline = Visible.healthBarOutline;
		HealthBarOutline.To = BarTo + HEALTH_BAR_OUTLINE_OFFSET;
		HealthBarOutline.From = BarFrom - HEALTH_BAR_OUTLINE_OFFSET;
		HealthBarOutline.Color = ParseColor(self, Options.healthBarOutlineColor[1], true);

		if not Faded then
			HealthBar.Transparency = 1;
			HealthBarOutline.Transparency = Options.healthBarOutlineColor[2];
		end;
	end;

	--// health text
	Visible.healthText.Visible = Enabled and OnScreen and Options.healthText;
	if Visible.healthText.Visible and CornersObj then
		local BarFrom = CornersObj.topLeft - HEALTH_BAR_OFFSET;
		local BarTo = CornersObj.bottomLeft - HEALTH_BAR_OFFSET;

		local HealthText = Visible.healthText;
		HealthText.Text = Round(self.health) .. "hp";
		HealthText.Size = Interface.sharedSettings.textSize;
		HealthText.Font = Interface.sharedSettings.textFont;
		HealthText.Color = ParseColor(self, Options.healthTextColor[1]);

		if not Faded then
			HealthText.Transparency = Options.healthTextColor[2];
		end;

		HealthText.Outline = Options.healthTextOutline;
		HealthText.OutlineColor = ParseColor(self, Options.healthTextOutlineColor, true);
		HealthText.Position = Lerp2(BarTo, BarFrom, (self.health / self.maxHealth)) - HealthText.TextBounds * 0.5 - HEALTH_TEXT_OFFSET;
	end;

	--// name
	Visible.name.Visible = Enabled and OnScreen and Options.name;
	if Visible.name.Visible and CornersObj then
		local Name = Visible.name;
		Name.Size = Interface.sharedSettings.textSize;
		Name.Font = Interface.sharedSettings.textFont;
		Name.Color = ParseColor(self, Options.nameColor[1]);

		if not Faded then
			Name.Transparency = Options.nameColor[2];
		end;

		Name.Outline = Options.nameOutline;
		Name.OutlineColor = ParseColor(self, Options.nameOutlineColor, true);
		Name.Position = (CornersObj.topLeft + CornersObj.topRight) * 0.5 - Vector2.yAxis * Name.TextBounds.Y - NAME_OFFSET;
	end;

	--// distance
	Visible.distance.Visible = Enabled and OnScreen and self.distance and Options.distance;
	if Visible.distance.Visible and CornersObj then
		local Distance = Visible.distance;
		Distance.Text = Round(self.distance) .. " studs";
		Distance.Size = Interface.sharedSettings.textSize;
		Distance.Font = Interface.sharedSettings.textFont;
		Distance.Color = ParseColor(self, Options.distanceColor[1]);

		if not Faded then
			Distance.Transparency = Options.distanceColor[2];
		end;

		Distance.Outline = Options.distanceOutline;
		Distance.OutlineColor = ParseColor(self, Options.distanceOutlineColor, true);
		Distance.Position = (CornersObj.bottomLeft + CornersObj.bottomRight) * 0.5 + DISTANCE_OFFSET;
	end;

	--// weapon
	Visible.weapon.Visible = Enabled and OnScreen and Options.weapon;
	if Visible.weapon.Visible and CornersObj then
		local Weapon = Visible.weapon;
		Weapon.Text = self.weapon;
		Weapon.Size = Interface.sharedSettings.textSize;
		Weapon.Font = Interface.sharedSettings.textFont;
		Weapon.Color = ParseColor(self, Options.weaponColor[1]);
		Weapon.Transparency = Options.weaponColor[2];
		Weapon.Outline = Options.weaponOutline;
		Weapon.OutlineColor = ParseColor(self, Options.weaponOutlineColor, true);
		Weapon.Position = (CornersObj.bottomLeft + CornersObj.bottomRight) * 0.5 + (Visible.distance.Visible and DISTANCE_OFFSET + Vector2.yAxis * Visible.distance.TextBounds.Y or Vector2.zero);
	end;

	--// tracer
	Visible.tracer.Visible = Enabled and OnScreen and Options.tracer;
	Visible.tracerOutline.Visible = Visible.tracer.Visible and Options.tracerOutline;
	if Visible.tracer.Visible and CornersObj then
		local Tracer = Visible.tracer;
		Tracer.Color = ParseColor(self, Options.tracerColor[1]);
		Tracer.Transparency = Options.tracerColor[2];
		Tracer.To = (CornersObj.bottomLeft + CornersObj.bottomRight) * 0.5;
		Tracer.From = (Options.tracerOrigin == "Middle" and ViewportSize * 0.5) or (Options.tracerOrigin == "Top" and ViewportSize * Vector2.new(0.5, 0)) or (Options.tracerOrigin == "Bottom" and ViewportSize * Vector2.new(0.5, 1));

		local TracerOutline = Visible.tracerOutline;
		TracerOutline.Color = ParseColor(self, Options.tracerOutlineColor[1], true);
		TracerOutline.Transparency = Options.tracerOutlineColor[2];
		TracerOutline.To = Tracer.To;
		TracerOutline.From = Tracer.From;
	end;

	--// skeleton
	local SkeletonEnabled = Enabled and OnScreen and Options.skeleton;
	local SkeletonDraw = self.drawings.skeleton;
	if SkeletonEnabled and self.skeletonBones then
		for i = 1, #SkeletonDraw.lines do
			local Outline = SkeletonDraw.outline[i];
			local Line = SkeletonDraw.lines[i];
			if i <= #self.skeletonBones then
				local Bone = self.skeletonBones[i];
				local A, B = Bone[1], Bone[2];
				local APos, AOn, ADepth = WorldToScreen(A.Position);
				local BPos, BOn, BDepth = WorldToScreen(B.Position);
				local VisibleLine = AOn and BOn;
				Outline.Visible = VisibleLine;
				Line.Visible = VisibleLine;
				if VisibleLine then
					Outline.From = APos;
					Outline.To = BPos;
					Outline.Color = ParseColor(self, Options.skeletonOutlineColor[1], true);
					Outline.Transparency = Options.skeletonOutlineColor[2];

					Line.From = APos;
					Line.To = BPos;
					Line.Color = ParseColor(self, Options.skeletonColor[1]);

					if not Faded then
						Line.Transparency = Options.skeletonColor[2];
					end;
				end;
			else
				Outline.Visible = false;
				Line.Visible = false;
			end;
		end;
	else
		for i = 1, #SkeletonDraw.lines do
			SkeletonDraw.outline[i].Visible = false;
			SkeletonDraw.lines[i].Visible = false;
		end;
	end;

	--// offscreen arrow
	Hidden.arrow.Visible = Enabled and (not OnScreen) and Options.offScreenArrow;
	Hidden.arrowOutline.Visible = Hidden.arrow.Visible and Options.offScreenArrowOutline;
	if Hidden.arrow.Visible and self.direction then
		local Arrow = Hidden.arrow;
		Arrow.PointA = Min2(Max2(ViewportSize * 0.5 + self.direction * Options.offScreenArrowRadius, Vector2.one * 25), ViewportSize - Vector2.one * 25);
		Arrow.PointB = Arrow.PointA - RotateVector(self.direction, 0.45) * Options.offScreenArrowSize;
		Arrow.PointC = Arrow.PointA - RotateVector(self.direction, -0.45) * Options.offScreenArrowSize;
		Arrow.Color = ParseColor(self, Options.offScreenArrowColor[1]);
		Arrow.Transparency = Options.offScreenArrowColor[2];

		local ArrowOutline = Hidden.arrowOutline;
		ArrowOutline.PointA = Arrow.PointA;
		ArrowOutline.PointB = Arrow.PointB;
		ArrowOutline.PointC = Arrow.PointC;
		ArrowOutline.Color = ParseColor(self, Options.offScreenArrowOutlineColor[1], true);
		ArrowOutline.Transparency = Options.offScreenArrowOutlineColor[2];
	end;

	--// 3D box faces
	local Box3DEnabled = Enabled and OnScreen and Options.box3d;
	for i = 1, #Box3D do
		local Face = Box3D[i];
		for j = 1, #Face do
			local Line = Face[j];
			Line.Visible = Box3DEnabled;
			Line.Color = ParseColor(self, Options.box3dColor[1]);
			Line.Transparency = Options.box3dColor[2];
		end;

		if Box3DEnabled and CornersObj then
			local p1 = CornersObj.corners[i];
			local p2 = CornersObj.corners[(i == 4) and 1 or (i + 1)];
			local p3 = CornersObj.corners[(i == 4) and 5 or (i + 5)];
			local p4 = CornersObj.corners[(i == 4) and 8 or (i + 4)];

			local line1 = Face[1];
			line1.From = p1;
			line1.To = p2;

			local line2 = Face[2];
			line2.From = p2;
			line2.To = p3;

			local line3 = Face[3];
			line3.From = p3;
			line3.To = p4;
		end;
	end;

	--// Corner ESP
	local CornerEnabled = Enabled and OnScreen and Options.cornerEsp and CornersObj;
	if CornerEnabled then
		local CornerLines = Visible.corners; --// table of 4 entries - {hOutline, h, vOutline, v}
		local Length = Options.cornerSize or 12; --// length of corner seg
		local InnerThickness = Options.cornerThickness or 1;
		local OutlineThickness = Options.cornerOutline and (Options.cornerOutlineThickness or 3) or 0;
		local InnerColor = ParseColor(self, Options.cornerColor[1]);
		local InnerTransparency = Options.cornerColor[2] or 1;
		local OutlineColor = ParseColor(self, Options.cornerOutlineColor or Color3.new(), true);
		local OutlineTransparency = Options.cornerOutlineColor and (Options.cornerOutlineColor[2] or 1) or 1;

		local function SetCorner(idx: number, cornerPos: Vector2, horizDir: Vector2, vertDir: Vector2)
			--// horiz: from cornerPos to cornerPos + horizDir * Length
			--// vert: from cornerPos to cornerPos + vertDir * Length
			local c = CornerLines[idx];
			local hOut, hIn, vOut, vIn = c[1], c[2], c[3], c[4];

			--// Get endpoints
			local hTo = cornerPos + horizDir * Length;
			local vTo = cornerPos + vertDir * Length;

			--// Outline lines
			if OutlineThickness > 0 then
				hOut.Thickness = OutlineThickness;
				hOut.From = cornerPos;
				hOut.To = hTo;
				hOut.Color = OutlineColor;
				hOut.Transparency = OutlineTransparency;
				hOut.Visible = true;

				vOut.Thickness = OutlineThickness;
				vOut.From = cornerPos;
				vOut.To = vTo;
				vOut.Color = OutlineColor;
				vOut.Transparency = OutlineTransparency;
				vOut.Visible = true;
			else
				hOut.Visible = false;
				vOut.Visible = false;
			end;

			--// Inner lines
			hIn.Thickness = InnerThickness;
			hIn.From = cornerPos;
			hIn.To = hTo;
			hIn.Color = InnerColor;
			hIn.Transparency = InnerTransparency;
			hIn.Visible = true;

			vIn.Thickness = InnerThickness;
			vIn.From = cornerPos;
			vIn.To = vTo;
			vIn.Color = InnerColor;
			vIn.Transparency = InnerTransparency;
			vIn.Visible = true;
		end;

		--// top-left: horiz right, vert down
		SetCorner(1, CornersObj.topLeft, Vector2.new(1, 0), Vector2.new(0, 1));
		--// top-right: horiz left, vert down
		SetCorner(2, CornersObj.topRight, Vector2.new(-1, 0), Vector2.new(0, 1));
		--// bottom-left: horiz right, vert up
		SetCorner(3, CornersObj.bottomLeft, Vector2.new(1, 0), Vector2.new(0, -1));
		--// bottom-right: horiz left, vert up
		SetCorner(4, CornersObj.bottomRight, Vector2.new(-1, 0), Vector2.new(0, -1));
	else
		--// hide ts
		local CornerLines = Visible.corners;
		for i = 1, #CornerLines do
			local c = CornerLines[i];
			c[1].Visible = false;
			c[2].Visible = false;
			c[3].Visible = false;
			c[4].Visible = false;
		end;
	end;
end;

local ChamObject = {};
ChamObject.__index = ChamObject;

function ChamObject.New(PlayerObj: Player, Interface: table)
	local Self = setmetatable({}, ChamObject) :: any;
	Self.Player = assert(PlayerObj, "Missing argument #1 (Player expected)");
	Self.Interface = assert(Interface, "Missing argument #2 (table expected)");
	Self:Construct();
	return Self;
end;

local function NewQuad(Color: Color3)
	local Quad = Drawing.new("Quad");
	Quad.Visible = false;
	Quad.Color = Color;
	Quad.Filled = true;
	Quad.Thickness = 1;
	Quad.Transparency = 0.25;

	return Quad;
end;

local function ColorizeQuads(Color: Color3, Quads: { any })
	for i = 1, #Quads do
		Quads[i].Color = Color;
	end;
end;

function ChamObject:Construct(): nil
	self.highlight = Instance.new("Highlight", Container);
	self.drawQuads = nil;
	self.partQuads = {}; --// map basepart -> {6 quads}
	self.updateConnection = RunService.Heartbeat:Connect(function()
		self:Update();
	end);

    self.charConn = self.Player.CharacterRemoving:Connect(function()
        for part, quads in self.partQuads do
            for i = 1, #quads do
                quads[i]:Remove()
            end
        end
        self.partQuads = {}
    end)

end;

function ChamObject:Destruct(): nil
	if self.updateConnection then
		self.updateConnection:Disconnect();
		self.updateConnection = nil;
	end

	if self.highlight then
		self.highlight:Destroy();
		self.highlight = nil;
	end

	if self.drawQuads then
		for i = 1, #self.drawQuads do
			self.drawQuads[i]:Remove();
		end

		self.drawQuads = nil;
	end;

    if self.charConn then
        self.charConn:Disconnect();
        self.charConn = nil;
    end


	-- destroy per-part quads (THIS WAS MISSING, OMFG)
	for part, quads in self.partQuads do
		for i = 1, #quads do
			quads[i]:Remove();
		end;
	end;

	self.partQuads = {};

	TableClear(self);
end;

function ChamObject:Update(): nil
	local HighlightObj = self.highlight;
	local Interface = self.Interface;
	local Character = Interface.getCharacter(self.Player);
	local Options = Interface.teamSettings[Interface.isFriendly(self.Player) and "friendly" or "enemy"];
	local Enabled = Options.enabled and Character and not (#Interface.whitelist > 0 and not TableFind(Interface.whitelist, self.Player.UserId));

	if Options.chamsStyle == "Highlight" then
		for part, quads in self.partQuads do
			for i = 1, #quads do
				quads[i].Visible = false;
			end;
		end;

		TableClear(self.partQuads);

		if self.drawQuads then
			for i = 1, #self.drawQuads do
				self.drawQuads[i].Visible = false;
			end;
			self.drawQuads = nil;
		end;

		HighlightObj.Enabled = Enabled and Options.chams;
		if HighlightObj.Enabled then
			HighlightObj.Adornee = Character;
			HighlightObj.FillColor = ParseColor(self, Options.chamsFillColor[1]);
			HighlightObj.FillTransparency = Options.chamsFillColor[2];
			HighlightObj.OutlineColor = ParseColor(self, Options.chamsOutlineColor[1], true);
			HighlightObj.OutlineTransparency = Options.chamsOutlineColor[2];
			HighlightObj.DepthMode = Options.chamsVisibleOnly and Enum.HighlightDepthMode.Occluded or Enum.HighlightDepthMode.AlwaysOnTop;
		end;
		return;
	end;

	HighlightObj.Enabled = false;

	if not (Enabled and Options.chams) then
		if self.drawQuads then
			for i = 1, #self.drawQuads do
				self.drawQuads[i].Visible = false;
			end;
			self.drawQuads = nil;
		end;

		for part, quads in self.partQuads do
			for i = 1, #quads do
				quads[i].Visible = false;
			end;
		end;

		TableClear(self.partQuads);
		return;
	end;

	local Children = GetChildren(Character);
	local PartsList = {};
	for i = 1, #Children do
		local p = Children[i];
		if IsA(p, "BasePart") and IsBodyPart(p.Name) then
			PartsList[#PartsList + 1] = p;
		end;
	end;

	for i = 1, #PartsList do
		local part = PartsList[i];
		if not self.partQuads[part] then
			--// create 6 quads per part
			local qset = {
				NewQuad(Options.chamsFillColor[1]),
				NewQuad(Options.chamsFillColor[1]),
				NewQuad(Options.chamsFillColor[1]),
				NewQuad(Options.chamsFillColor[1]),
				NewQuad(Options.chamsFillColor[1]),
				NewQuad(Options.chamsFillColor[1])
			};
			self.partQuads[part] = qset;
		end;

		local quads = self.partQuads[part];

        if not part or not part.Parent then
			for j = 1, #quads do
				quads[j].Visible = false;
			end;
			self.partQuads[part] = nil;
			continue;
		end;

		--// on-screen check
		local partPos, onscreen = WtVp(Camera, part.Position);
		if not onscreen then
			for j = 1, #quads do
				quads[j].Visible = false;
			end;
		else
			--// get half-sizes
			local size_X = part.Size.X * 0.5;
			local size_Y = part.Size.Y * 0.5;
			local size_Z = part.Size.Z * 0.5;

			--// calc 8 corners in world then to screen, I hate this, its aids to look at
			local Top1 = WtVp(Camera, (part.CFrame * CFrame.new(-size_X, size_Y, -size_Z)).p);
			local Top2 = WtVp(Camera, (part.CFrame * CFrame.new(-size_X, size_Y, size_Z)).p);
			local Top3 = WtVp(Camera, (part.CFrame * CFrame.new(size_X, size_Y, size_Z)).p);
			local Top4 = WtVp(Camera, (part.CFrame * CFrame.new(size_X, size_Y, -size_Z)).p);

			local Bottom1 = WtVp(Camera, (part.CFrame * CFrame.new(-size_X, -size_Y, -size_Z)).p);
			local Bottom2 = WtVp(Camera, (part.CFrame * CFrame.new(-size_X, -size_Y, size_Z)).p);
			local Bottom3 = WtVp(Camera, (part.CFrame * CFrame.new(size_X, -size_Y, size_Z)).p);
			local Bottom4 = WtVp(Camera, (part.CFrame * CFrame.new(size_X, -size_Y, -size_Z)).p);

			--// convert
			local t1 = Vector2.new(Top1.X, Top1.Y);
			local t2 = Vector2.new(Top2.X, Top2.Y);
			local t3 = Vector2.new(Top3.X, Top3.Y);
			local t4 = Vector2.new(Top4.X, Top4.Y);
			local b1 = Vector2.new(Bottom1.X, Bottom1.Y);
			local b2 = Vector2.new(Bottom2.X, Bottom2.Y);
			local b3 = Vector2.new(Bottom3.X, Bottom3.Y);
			local b4 = Vector2.new(Bottom4.X, Bottom4.Y);

			local UseColor: Color3 = Options.chamsFillColor[1];
			if Interface.teamCheck then
				if self.Player.TeamColor == LocalPlayer.TeamColor then
					UseColor = Options.greenColor or Color3.new(0, 1, 0);
				else
					UseColor = Options.redColor or Color3.new(1, 0, 0);
				end;
			end;
			if Options.chamsTeamColor then
				UseColor = (self.Player.TeamColor and self.Player.TeamColor.Color) or UseColor;
			end;

			for j = 1, #quads do
				quads[j].Color = UseColor;
				quads[j].Transparency = Options.chamsFillColor[2] or 0.25;
				quads[j].Filled = true;
			end;

			--// quad1: top
			quads[1].PointA = t1;
			quads[1].PointB = t2;
			quads[1].PointC = t3;
			quads[1].PointD = t4;

			--// quad2: bottom
			quads[2].PointA = b1;
			quads[2].PointB = b2;
			quads[2].PointC = b3;
			quads[2].PointD = b4;

			--// quad3: side 1
			quads[3].PointA = t1;
			quads[3].PointB = t2;
			quads[3].PointC = b2;
			quads[3].PointD = b1;

			--// quad4: side 2
			quads[4].PointA = t2;
			quads[4].PointB = t3;
			quads[4].PointC = b3;
			quads[4].PointD = b2;

			--// quad5: side 3
			quads[5].PointA = t3;
			quads[5].PointB = t4;
			quads[5].PointC = b4;
			quads[5].PointD = b3;

			--// quad6: side 4
			quads[6].PointA = t4;
			quads[6].PointB = t1;
			quads[6].PointC = b1;
			quads[6].PointD = b4;

			for j = 1, #quads do
				quads[j].Visible = true;
			end;
		end;
	end;

	for part, quads in self.partQuads do
		if not part or not part.Parent then
			for j = 1, #quads do
				quads[j].Visible = false;
			end;

			self.partQuads[part] = nil;
		end;
	end;
end;

local InstanceObject = {};
InstanceObject.__index = InstanceObject;

function InstanceObject.New(InstanceObj: Instance, Options: table)
	local Self = setmetatable({}, InstanceObject) :: any;
	Self.instance = assert(InstanceObj, "Missing argument #1 (Instance Expected)");
	Self.options = assert(Options, "Missing argument #2 (table expected)");
	Self:Construct();
	return Self;
end;

function InstanceObject:Construct(): nil
	local Options = self.options;
	Options.enabled = if Options.enabled == nil then true else Options.enabled;
	Options.text = Options.text or "{name}";
	Options.textColor = Options.textColor or {Color3.new(1, 1, 1), 1};
	Options.textOutline = if Options.textOutline == nil then true else Options.textOutline;
	Options.textOutlineColor = Options.textOutlineColor or Color3.new();
	Options.textSize = Options.textSize or 13;
	Options.textFont = Options.textFont or 2;
	Options.limitDistance = Options.limitDistance or false;
	Options.maxDistance = Options.maxDistance or 150;

	self.text = Drawing.new("Text");
	self.text.Center = true;

	self.renderConnection = RunService.Heartbeat:Connect(function(dt)
		self:Render(dt);
	end);
end;

function InstanceObject:Destruct(): nil
	if self.renderConnection then
		self.renderConnection:Disconnect();
	end;
	if self.text then
		self.text:Remove();
	end;
end;

function InstanceObject:Render(): nil
	local Inst = self.instance;
	if not Inst or not Inst.Parent then
		return self:Destruct();
	end;

	local Text = self.text;
	local Options = self.options;
	if not Options.enabled then
		Text.Visible = false;
		return;
	end;

	local World = GetPivot(Inst).Position;
	local Position, Visible, Depth = WorldToScreen(World);
	if Options.limitDistance and Depth > Options.maxDistance then
		Visible = false;
	end;

	Text.Visible = Visible;
	if Text.Visible then
		Text.Position = Position;
		Text.Color = Options.textColor[1];
		Text.Transparency = Options.textColor[2];
		Text.Outline = Options.textOutline;
		Text.OutlineColor = Options.textOutlineColor;
		Text.Size = Options.textSize;
		Text.Font = Options.textFont;
		Text.Text = Options.text:gsub("{name}", Inst.Name):gsub("{distance}", tostring(Round(Depth))):gsub("{position}", tostring(World));
	end;
end;

--// EspInterface
local EspInterface = {
	_hasLoaded = false,
	_objectCache = {},
	whitelist = {},
	teamCheck = false,
	sharedSettings = {
		textSize = 13,
		textFont = 2,
		limitDistance = false,
		maxDistance = 150,
		useTeamColor = false
	},

    teamSettings = {
		enemy = {
			enabled = false,
			box = false,
			boxColor = { Color3.new(1, 0, 0), 1 },
			boxOutline = true,
			boxOutlineColor = { Color3.new(), 1 },
			boxFill = false,
			boxFillColor = { Color3.new(1, 1, 1), 0.5 },
			healthBar = false,
			healthyColor = Color3.new(0, 1, 0),
			dyingColor = Color3.new(1, 0, 0),
			healthBarOutline = true,
			healthBarOutlineColor = { Color3.new(), 0.5 },
			healthText = false,
			healthTextColor = { Color3.new(1, 1, 1), 1 },
			healthTextOutline = true,
			healthTextOutlineColor = Color3.new(),
			box3d = false,
			box3dColor = { Color3.new(1, 0, 0), 1 },
			name = false,
			nameColor = { Color3.new(1, 1, 1), 1 },
			nameOutline = true,
			nameOutlineColor = Color3.new(),
			weapon = false,
			weaponColor = { Color3.new(1, 1, 1), 1 },
			weaponOutline = true,
			weaponOutlineColor = { Color3.new(), 1 },
			distance = false,
			distanceColor = { Color3.new(1, 1, 1), 1 },
			distanceOutline = true,
			distanceOutlineColor = Color3.new(),
			tracer = false,
			tracerOrigin = "Bottom",
			tracerColor = { Color3.new(1, 0, 0), 1 },
			tracerOutline = true,
			tracerOutlineColor = { Color3.new(), 1 },
			offScreenArrow = false,
			offScreenArrowColor = { Color3.new(1, 1, 1), 1 },
			offScreenArrowSize = 15,
			offScreenArrowRadius = 150,
			offScreenArrowOutline = true,
			offScreenArrowOutlineColor = { Color3.new(), 1 },
			chams = false,
			chamsVisibleOnly = false,
			chamsFillColor = { Color3.fromRGB(162, 164, 189), 1 },
			chamsOutlineColor = { Color3.new(1, 0, 0), 0 },
			--// NEW (i added this): chamsStyle -> "Highlight" or "Drawing"
			chamsStyle = "Highlight",
			chamsTeamColor = false,

            cornerEsp = false,
			cornerSize = 12,
			cornerThickness = 1,
			cornerOutline = true,
			cornerOutlineThickness = 3,
			cornerColor = { Color3.new(1, 1, 1), 1 },
			cornerOutlineColor = { Color3.new(), 1 },

			--// skeleton (I added this)
			skeleton = false,
			skeletonColor = { Color3.new(1, 0, 0), 1 },
			skeletonOutline = true,
			skeletonOutlineColor = { Color3.new(), 0 },

            greenColor = Color3.new(0, 1, 0),
			redColor = Color3.new(1, 0, 0)
		},
		friendly = {
			enabled = false,
			box = false,
			boxColor = { Color3.new(0, 1, 0), 1 },
			boxOutline = true,
			boxOutlineColor = { Color3.new(), 1 },
			boxFill = false,
			boxFillColor = { Color3.new(0, 1, 0), 0.5 },
			healthBar = false,
			healthyColor = Color3.new(0, 1, 0),
			dyingColor = Color3.new(1, 0, 0),
			healthBarOutline = true,
			healthBarOutlineColor = {Color3.new(), 0.5},
			healthText = false,
			healthTextColor = {Color3.new(1, 1, 1), 1},
			healthTextOutline = true,
			healthTextOutlineColor = Color3.new(),
			box3d = false,
			box3dColor = {Color3.new(0, 1, 0), 1},
			name = false,
			nameColor = {Color3.new(1, 1, 1), 1},
			nameOutline = true,
			nameOutlineColor = Color3.new(),
			weapon = false,
			weaponColor = {Color3.new(1, 1, 1), 1},
			weaponOutline = true,
			weaponOutlineColor = {Color3.new(), 1},
			distance = false,
			distanceColor = {Color3.new(1, 1, 1), 1},
			distanceOutline = true,
			distanceOutlineColor = Color3.new(),
			tracer = false,
			tracerOrigin = "Bottom",
			tracerColor = {Color3.new(0, 1, 0), 1},
			tracerOutline = true,
			tracerOutlineColor = {Color3.new(), 1},
			offScreenArrow = false,
			offScreenArrowColor = {Color3.new(1, 1, 1), 1},
			offScreenArrowSize = 15,
			offScreenArrowRadius = 150,
			offScreenArrowOutline = true,
			offScreenArrowOutlineColor = {Color3.new(), 1},
			chams = false,
			chamsVisibleOnly = false,
			chamsFillColor = {Color3.new(0.2, 0.2, 0.2), 0.5},
			chamsOutlineColor = {Color3.new(0, 1, 0), 0},
			chamsStyle = "Highlight",
			chamsTeamColor = false,

            cornerEsp = false,
			cornerSize = 12,
			cornerThickness = 1,
			cornerOutline = true,
			cornerOutlineThickness = 3,
			cornerColor = { Color3.new(0, 1, 0), 1 },
			cornerOutlineColor = { Color3.new(), 1 },
			skeleton = false,
			skeletonColor = { Color3.new(0, 1, 0), 1 },
			skeletonOutline = false,
			skeletonOutlineColor = { Color3.new(), 0 }
		};
	};
};

function EspInterface.AddInstance(InstanceObj: Instance, Options: table)
	local Cache = EspInterface._objectCache;
	if Cache[InstanceObj] then
		warn("Instance handler already exists.");
	else
		Cache[InstanceObj] = { InstanceObject.New(InstanceObj, Options) };
	end;
	return Cache[InstanceObj][1];
end;

function EspInterface.Load(): nil
	assert(not EspInterface._hasLoaded, "Esp has already been loaded.");

	local function CreateObject(PlayerObj: Player)
		EspInterface._objectCache[PlayerObj] = { EspObject.New(PlayerObj, EspInterface), ChamObject.New(PlayerObj, EspInterface) };
	end;

	local function RemoveObject(PlayerObj: Player)
		local Object = EspInterface._objectCache[PlayerObj];
		if Object then
			for i = 1, #Object do
				Object[i]:Destruct();
			end;

			EspInterface._objectCache[PlayerObj] = nil;
		end;
	end;

	local Plrs: { Players } = Players:GetPlayers();
	local CreateTasks = {};
	for i = 1, #Plrs do
		local P = Plrs[i];
		if P and not rawequal(P, LocalPlayer) then
			CreateTasks[#CreateTasks + 1] = function() CreateObject(P); end;
		end;
	end;

	MultiThreadList(CreateTasks);

	EspInterface.playerAdded = Players.PlayerAdded:Connect(function(p) CreateObject(p); end);
	EspInterface.playerRemoving = Players.PlayerRemoving:Connect(function(p) RemoveObject(p); end);
	EspInterface._hasLoaded = true;
end;

function EspInterface.Unload(): nil
	assert(EspInterface._hasLoaded, "Esp has not been loaded yet.");

	local Keys = {};

	for k, _ in EspInterface._objectCache do
		Keys[#Keys + 1] = k;
	end;

	for i = 1, #Keys do
		local Index = Keys[i];
		local Object = EspInterface._objectCache[Index];
		if Object then
			for j = 1, #Object do
				Object[j]:Destruct();
			end;
			EspInterface._objectCache[Index] = nil;
		end;
	end;

	EspInterface.playerAdded:Disconnect();
	EspInterface.playerRemoving:Disconnect();
	EspInterface._hasLoaded = false;
end;

function EspInterface.getWeapon(PlayerObj: Player): string
	if PlayerObj.Character and PlayerObj.Character:FindFirstChild("Humanoid") and PlayerObj.Character.Humanoid.Health > 0 then
		local Weapon = PlayerObj.Character:FindFirstChildOfClass("Tool");
		if Weapon then
			return Weapon.Name;
		end;
	end;
	return "Unknown";
end;

function EspInterface.isFriendly(PlayerObj: Player): boolean
	--// Placeholder; implement game-specific team logic if u want, but im not doing it for you
	return false;
end;

function EspInterface.getTeamColor(PlayerObj: Player): Color3?
	return PlayerObj.Team and PlayerObj.Team.TeamColor and PlayerObj.Team.TeamColor.Color;
end;

function EspInterface.getCharacter(PlayerObj: Player): Model?
	return PlayerObj.Character;
end;

function EspInterface.getHealth(PlayerObj: Player): (number, number)
	local Character = PlayerObj and EspInterface.getCharacter(PlayerObj);
	local Humanoid = Character and FindFirstChildOfClass(Character, "Humanoid");
	if Humanoid then
		return Humanoid.Health, Humanoid.MaxHealth;
	end;
	return 100, 100;
end;

return EspInterface :: EspObject;
