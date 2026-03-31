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
	CREDITS - Main Library: shlex - Rewrite: newguy
	
	NOTES:
		- This is the Sirius Sense ESP library completely rewritten. I did not see the old one production fit, due to poor optimizations.
		- All calculation / concept credits go to shlex and Sirius.
]]

local RunService: RunService = game:GetService("RunService")
local Players: Players = game:GetService("Players")
local Workspace: Workspace = game:GetService("Workspace")
local CoreGui: Instance = game:GetService("CoreGui")
local localPlayer: Player? = Players.LocalPlayer
local camera: Camera = Workspace.CurrentCamera
local viewportSize: Vector2 = camera and camera.ViewportSize or Vector2.new(0, 0)
local container: Instance = Instance.new("Folder", (RunService:IsStudio() and localPlayer.PlayerGui or game.CoreGui))

local floor, round, atan2, sin, cos, clear, unpack, find, create =
	math.floor, math.round, math.atan2, math.sin, math.cos, table.clear, table.unpack, table.find, table.create

local wtvp, isA, getPivot, findFirstChild, findFirstChildOfClass, getChildren =
	camera.WorldToViewportPoint, Workspace.IsA, Workspace.GetPivot, Workspace.FindFirstChild, Workspace.FindFirstChildOfClass, Workspace.GetChildren
local toOrientation, pointToObjectSpace = CFrame.identity.ToOrientation, CFrame.identity.PointToObjectSpace
local lerpColor = Color3.new().Lerp
local min2, max2, lerp2 = Vector2.zero.Min, Vector2.zero.Max, Vector2.zero.Lerp
local min3, max3 = Vector3.zero.Min, Vector3.zero.Max

--// constants
local HEALTH_BAR_OFFSET: Vector2 = Vector2.new(5, 0)
local HEALTH_TEXT_OFFSET: Vector2 = Vector2.new(3, 0)
local HEALTH_BAR_OUTLINE_OFFSET: Vector2 = Vector2.new(0, 1)
local NAME_OFFSET: Vector2 = Vector2.new(0, 2)
local DISTANCE_OFFSET: Vector2 = Vector2.new(0, 2)
local VERTICES: {Vector3} = {
	Vector3.new(-1, -1, -1),
	Vector3.new(-1, 1, -1),
	Vector3.new(-1, 1, 1),
	Vector3.new(-1, -1, 1),
	Vector3.new(1, -1, -1),
	Vector3.new(1, 1, -1),
	Vector3.new(1, 1, 1),
	Vector3.new(1, -1, 1)
}

--// types
type EspObject = {
	player: Player,
	interface: table,
	renderConnection: RBXScriptConnection?,
}

type Corners = {
	corners: {Vector2},
	topLeft: Vector2,
	topRight: Vector2,
	bottomLeft: Vector2,
	bottomRight: Vector2
}

--// utility functions
function CreateThread(func, ...): ( any, { [any]: any } ) -> ()
	local thread: any = coroutine.create(func)
	coroutine.resume(thread, ...)

	return thread;
end;

function MultiThreadList(obj: { [number]: any } | { [string]: any }, ...: any): nil
	local n: number = #obj;

	if n > 0 then
		for i = 1, n do
			local t = obj[i];
			local ttype = type(t);
			if ttype == "table" then
				local d: number = #t;
				assert(d ~= 0, "table inserted was not an array or was empty");
				assert(d < 3, ("invalid number of arguments (%d)"):format(d));

				local thetype = type(t[1]);
				assert(
					thetype == "function",
					("invalid argument #1: expected 'function', got '%s'"):format(tostring(thetype))
				);

				if d == 1 then
					--// only the function provided, call without extra args
					CreateThread(t[1]);
				else
					--// d == 2 -> second entry should be an array of args
					local args = t[2];
					assert(type(args) == "table", "argument list must be a table");
					CreateThread(t[1], unpack(args));
				end;
			else
				CreateThread(t, ...);
			end;
		end;
	else
		for idx, thread in obj do
			CreateThread(thread, ...);
		end;
	end;
end;

local function isBodyPart(name: string): boolean
	return name == "Head" or name:find("Torso") or name:find("Leg") or name:find("Arm")
end

local function getBoundingBox(parts: {BasePart}): (CFrame, Vector3)
	local minV: Vector3?
	local maxV: Vector3?
	for i = 1, #parts do
		local p = parts[i]
		local cf, s = p.CFrame, p.Size

		minV = min3(minV or cf.Position, (cf - s * 0.5).Position)
		maxV = max3(maxV or cf.Position, (cf + s * 0.5).Position)
	end

	local center = (minV + maxV) * 0.5
	local front = Vector3.new(center.X, center.Y, maxV.Z)
	return CFrame.new(center, front), (maxV - minV)
end

local function worldToScreen(world: Vector3): (Vector2, boolean, number)
	local screen, inBounds = wtvp(camera, world)
	return Vector2.new(screen.X, screen.Y), inBounds, screen.Z
end

local function calculateCorners(cframe: CFrame, size: Vector3): Corners
	local cornerScreens: {Vector2} = create(#VERTICES)
	for i = 1, #VERTICES do
		local worldPos = (cframe + size * 0.5 * VERTICES[i]).Position
		cornerScreens[i] = worldToScreen(worldPos)
	end

	local minV = min2(viewportSize, unpack(cornerScreens))
	local maxV = max2(Vector2.zero, unpack(cornerScreens))
	return {
		corners = cornerScreens,
		topLeft = Vector2.new(floor(minV.X), floor(minV.Y)),
		topRight = Vector2.new(floor(maxV.X), floor(minV.Y)),
		bottomLeft = Vector2.new(floor(minV.X), floor(maxV.Y)),
		bottomRight = Vector2.new(floor(maxV.X), floor(maxV.Y))
	}
end

local function rotateVector(vector: Vector2, radians: number): Vector2
	local c, s = cos(radians), sin(radians)
	return Vector2.new(c * vector.X - s * vector.Y, s * vector.X + c * vector.Y)
end

local function parseColor(self: any, color: any, isOutline: boolean?): Color3
	if color == "Team Color" or (self.interface.sharedSettings.useTeamColor and not isOutline) then
		return self.interface.getTeamColor(self.player) or Color3.new(1, 1, 1)
	end
	return color
end

if camera then
	camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
		viewportSize = camera.ViewportSize
	end)
end

--// skeleton defs
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
}

local function splitPatterns(pattern: string)
	local out = {}
	for token in pattern:gmatch("[^|]+") do
		out[#out + 1] = token
	end

	return out
end

local function findPartByPatterns(character: Model, pattern: string)
	if not character then return nil end
	local parts = getChildren(character)
	local patterns = splitPatterns(pattern)

	for _, alt in patterns do
		local exact = findFirstChild(character, alt)
		if exact and isA(exact, "BasePart") then
			return exact
		end
	end

	for _, p in pairs(parts) do
		if isA(p, "BasePart") then
			local lower = p.Name:lower()
			for _, alt in patterns do
				local a = alt:lower()
				if lower:find(a) then
					return p
				end
			end
		end
	end

	return nil
end

local EspObject = {}
EspObject.__index = EspObject

function EspObject.new(player: Player, interface: table): EspObject
	local self = setmetatable({}, EspObject) :: any
	self.player = assert(player, "Missing argument #1 (Player expected)")
	self.interface = assert(interface, "Missing argument #2 (table expected)")
	self:Construct()
	return self :: EspObject
end

function EspObject:_create(className: string, properties: table): any
	local drawing = Drawing.new(className)
	for k, v in properties do
		drawing[k] = v
	end
	self.bin[#self.bin + 1] = drawing
	return drawing
end

function EspObject:Construct(): nil
	self.charCache = {}
	self.childCount = 0
	self.bin = {}
	self.skeletonBones = {}

	self.drawings = {
		box3d = {
			{self:_create("Line", {Thickness = 1, Visible = false}), self:_create("Line", {Thickness = 1, Visible = false}), self:_create("Line", {Thickness = 1, Visible = false})},
			{self:_create("Line", {Thickness = 1, Visible = false}), self:_create("Line", {Thickness = 1, Visible = false}), self:_create("Line", {Thickness = 1, Visible = false})},
			{self:_create("Line", {Thickness = 1, Visible = false}), self:_create("Line", {Thickness = 1, Visible = false}), self:_create("Line", {Thickness = 1, Visible = false})},
			{self:_create("Line", {Thickness = 1, Visible = false}), self:_create("Line", {Thickness = 1, Visible = false}), self:_create("Line", {Thickness = 1, Visible = false})}
		},
		visible = {
			tracerOutline = self:_create("Line", {Thickness = 3, Visible = false}),
			tracer = self:_create("Line", {Thickness = 1, Visible = false}),
			boxFill = self:_create("Square", {Filled = true, Visible = false}),
			boxOutline = self:_create("Square", {Thickness = 3, Visible = false}),
			box = self:_create("Square", {Thickness = 1, Visible = false}),
			healthBarOutline = self:_create("Line", {Thickness = 3, Visible = false}),
			healthBar = self:_create("Line", {Thickness = 1, Visible = false}),
			healthText = self:_create("Text", {Center = true, Visible = false}),
			name = self:_create("Text", {Text = self.player.DisplayName, Center = true, Visible = false}),
			distance = self:_create("Text", {Center = true, Visible = false}),
			weapon = self:_create("Text", {Center = true, Visible = false})
		},
		hidden = {
			arrowOutline = self:_create("Triangle", {Thickness = 3, Visible = false}),
			arrow = self:_create("Triangle", {Filled = true, Visible = false})
		},
		
		skeleton = {
			outline = {},
			lines = {}
		}
	}

	-- pre-create 20 bones worth of lines
	for i = 1, 20 do
		self.drawings.skeleton.outline[i] = self:_create("Line", {Thickness = 3, Visible = false})
		self.drawings.skeleton.lines[i] = self:_create("Line", {Thickness = 1, Visible = false})
	end

	--// render
	self.renderConnection = RunService.Heartbeat:Connect(function(dt)
		self:Update(dt)
		self:Render(dt)
	end)
end

function EspObject:Destruct(): nil
	if self.renderConnection then
		self.renderConnection:Disconnect()
	end
	for i = 1, #self.bin do
		self.bin[i]:Remove()
	end
	clear(self)
end

function EspObject:Update(): nil
	local interface = self.interface
	self.options = interface.teamSettings[interface.isFriendly(self.player) and "friendly" or "enemy"]
	self.character = interface.getCharacter(self.player)
	self.health, self.maxHealth = interface.getHealth(self.player)
	self.weapon = interface.getWeapon(self.player)
	self.enabled = self.options.enabled and self.character and not (#interface.whitelist > 0 and not find(interface.whitelist, self.player.UserId))

	local head = self.enabled and findFirstChild(self.character, "Head")
	if not head then
		self.charCache = {}
		self.skeletonBones = {}
		return
	end

	local _, onScreen, depth = worldToScreen(head.Position)
	self.onScreen = onScreen
	self.distance = depth

	if interface.sharedSettings.limitDistance and depth > interface.sharedSettings.maxDistance then
		self.onScreen = false
	end

	if self.onScreen then
		local cache = self.charCache
		local children = getChildren(self.character)
		if not cache[1] or self.childCount ~= #children then
			clear(cache)
			for i = 1, #children do
				local part = children[i]
				if isA(part, "BasePart") and isBodyPart(part.Name) then
					cache[#cache + 1] = part
				end
			end
			self.childCount = #children
		end
		self.corners = calculateCorners(getBoundingBox(cache))

		-- skeleton (i added this)
		clear(self.skeletonBones)
		for i = 1, #SKELETON_BONE_DEFS do
			local def = SKELETON_BONE_DEFS[i]
			local aPattern, bPattern = def[1], def[2]
			local aPart = findPartByPatterns(self.character, aPattern)
			local bPart = findPartByPatterns(self.character, bPattern)
			if aPart and bPart and aPart ~= bPart then
				self.skeletonBones[#self.skeletonBones + 1] = {aPart, bPart}
			end
		end
	elseif self.options.offScreenArrow then
		local _, yaw, roll = toOrientation(camera.CFrame)
		local flatCFrame = CFrame.Angles(0, yaw, roll) + camera.CFrame.Position
		local objectSpace = pointToObjectSpace(flatCFrame, head.Position)
		local angle = atan2(objectSpace.Z, objectSpace.X)
		self.direction = Vector2.new(cos(angle), sin(angle))
	end
end

function EspObject:Render(): nil
	local onScreen: boolean = self.onScreen or false
	local enabled: boolean = self.enabled or false
	local visible = self.drawings.visible
	local hidden = self.drawings.hidden
	local box3d = self.drawings.box3d
	local interface = self.interface
	local options = self.options
	local corners: Corners? = self.corners

	--// box
	visible.box.Visible = enabled and onScreen and options.box
	visible.boxOutline.Visible = visible.box.Visible and options.boxOutline
	if visible.box.Visible then
		local box = visible.box
		box.Position = corners.topLeft
		box.Size = corners.bottomRight - corners.topLeft
		box.Color = parseColor(self, options.boxColor[1])
		box.Transparency = options.boxColor[2]

		local boxOutline = visible.boxOutline
		boxOutline.Position = box.Position
		boxOutline.Size = box.Size
		boxOutline.Color = parseColor(self, options.boxOutlineColor[1], true)
		boxOutline.Transparency = options.boxOutlineColor[2]
	end

	--// box fill
	visible.boxFill.Visible = enabled and onScreen and options.boxFill
	if visible.boxFill.Visible then
		local boxFill = visible.boxFill
		boxFill.Position = corners.topLeft
		boxFill.Size = corners.bottomRight - corners.topLeft
		boxFill.Color = parseColor(self, options.boxFillColor[1])
		boxFill.Transparency = options.boxFillColor[2]
	end

	--// health bar
	visible.healthBar.Visible = enabled and onScreen and options.healthBar
	visible.healthBarOutline.Visible = visible.healthBar.Visible and options.healthBarOutline
	if visible.healthBar.Visible then
		local barFrom = corners.topLeft - HEALTH_BAR_OFFSET
		local barTo = corners.bottomLeft - HEALTH_BAR_OFFSET

		local healthBar = visible.healthBar
		healthBar.To = barTo
		healthBar.From = lerp2(barTo, barFrom, (self.health / self.maxHealth))
		healthBar.Color = lerpColor(options.dyingColor, options.healthyColor, (self.health / self.maxHealth))

		local healthBarOutline = visible.healthBarOutline
		healthBarOutline.To = barTo + HEALTH_BAR_OUTLINE_OFFSET
		healthBarOutline.From = barFrom - HEALTH_BAR_OUTLINE_OFFSET
		healthBarOutline.Color = parseColor(self, options.healthBarOutlineColor[1], true)
		healthBarOutline.Transparency = options.healthBarOutlineColor[2]
	end

	--// health text
	visible.healthText.Visible = enabled and onScreen and options.healthText
	if visible.healthText.Visible then
		local barFrom = corners.topLeft - HEALTH_BAR_OFFSET
		local barTo = corners.bottomLeft - HEALTH_BAR_OFFSET

		local healthText = visible.healthText
		healthText.Text = round(self.health) .. "hp"
		healthText.Size = interface.sharedSettings.textSize
		healthText.Font = interface.sharedSettings.textFont
		healthText.Color = parseColor(self, options.healthTextColor[1])
		healthText.Transparency = options.healthTextColor[2]
		healthText.Outline = options.healthTextOutline
		healthText.OutlineColor = parseColor(self, options.healthTextOutlineColor, true)
		healthText.Position = lerp2(barTo, barFrom, (self.health / self.maxHealth)) - healthText.TextBounds * 0.5 - HEALTH_TEXT_OFFSET
	end

	--// name
	visible.name.Visible = enabled and onScreen and options.name
	if visible.name.Visible then
		local name = visible.name
		name.Size = interface.sharedSettings.textSize
		name.Font = interface.sharedSettings.textFont
		name.Color = parseColor(self, options.nameColor[1])
		name.Transparency = options.nameColor[2]
		name.Outline = options.nameOutline
		name.OutlineColor = parseColor(self, options.nameOutlineColor, true)
		name.Position = (corners.topLeft + corners.topRight) * 0.5 - Vector2.yAxis * name.TextBounds.Y - NAME_OFFSET
	end

	--// distance
	visible.distance.Visible = enabled and onScreen and self.distance and options.distance
	if visible.distance.Visible then
		local distance = visible.distance
		distance.Text = round(self.distance) .. " studs"
		distance.Size = interface.sharedSettings.textSize
		distance.Font = interface.sharedSettings.textFont
		distance.Color = parseColor(self, options.distanceColor[1])
		distance.Transparency = options.distanceColor[2]
		distance.Outline = options.distanceOutline
		distance.OutlineColor = parseColor(self, options.distanceOutlineColor, true)
		distance.Position = (corners.bottomLeft + corners.bottomRight) * 0.5 + DISTANCE_OFFSET
	end

	--// weapon
	visible.weapon.Visible = enabled and onScreen and options.weapon
	if visible.weapon.Visible then
		local weapon = visible.weapon
		weapon.Text = self.weapon
		weapon.Size = interface.sharedSettings.textSize
		weapon.Font = interface.sharedSettings.textFont
		weapon.Color = parseColor(self, options.weaponColor[1])
		weapon.Transparency = options.weaponColor[2]
		weapon.Outline = options.weaponOutline
		weapon.OutlineColor = parseColor(self, options.weaponOutlineColor, true)
		weapon.Position = (corners.bottomLeft + corners.bottomRight) * 0.5 + (visible.distance.Visible and DISTANCE_OFFSET + Vector2.yAxis * visible.distance.TextBounds.Y or Vector2.zero)
	end

	--// tracer
	visible.tracer.Visible = enabled and onScreen and options.tracer
	visible.tracerOutline.Visible = visible.tracer.Visible and options.tracerOutline
	if visible.tracer.Visible then
		local tracer = visible.tracer
		tracer.Color = parseColor(self, options.tracerColor[1])
		tracer.Transparency = options.tracerColor[2]
		tracer.To = (corners.bottomLeft + corners.bottomRight) * 0.5
		tracer.From = (options.tracerOrigin == "Middle" and viewportSize * 0.5) or (options.tracerOrigin == "Top" and viewportSize * Vector2.new(0.5, 0)) or (options.tracerOrigin == "Bottom" and viewportSize * Vector2.new(0.5, 1))

		local tracerOutline = visible.tracerOutline
		tracerOutline.Color = parseColor(self, options.tracerOutlineColor[1], true)
		tracerOutline.Transparency = options.tracerOutlineColor[2]
		tracerOutline.To = tracer.To
		tracerOutline.From = tracer.From
	end

	--// skeleton
	local skeletonEnabled = enabled and onScreen and options.skeleton
	local skeletonDraw = self.drawings.skeleton
	if skeletonEnabled and self.skeletonBones then
		for i = 1, #skeletonDraw.lines do
			local outline = skeletonDraw.outline[i]
			local line = skeletonDraw.lines[i]
			if i <= #self.skeletonBones then
				local bone = self.skeletonBones[i]
				local a, b = bone[1], bone[2]
				local aPos, aOn, aDepth = worldToScreen(a.Position)
				local bPos, bOn, bDepth = worldToScreen(b.Position)
				local visibleLine = aOn and bOn
				outline.Visible = visibleLine
				line.Visible = visibleLine
				if visibleLine then
					outline.From = aPos
					outline.To = bPos
					outline.Color = parseColor(self, options.skeletonOutlineColor[1], true)
					outline.Transparency = options.skeletonOutlineColor[2]

					line.From = aPos
					line.To = bPos
					line.Color = parseColor(self, options.skeletonColor[1])
					line.Transparency = options.skeletonColor[2]
				end
			else
				outline.Visible = false
				line.Visible = false
			end
		end
	else
		for i = 1, #skeletonDraw.lines do
			skeletonDraw.outline[i].Visible = false
			skeletonDraw.lines[i].Visible = false
		end
	end

	--// offscreen arrow
	hidden.arrow.Visible = enabled and (not onScreen) and options.offScreenArrow
	hidden.arrowOutline.Visible = hidden.arrow.Visible and options.offScreenArrowOutline
	if hidden.arrow.Visible and self.direction then
		local arrow = hidden.arrow
		arrow.PointA = min2(max2(viewportSize * 0.5 + self.direction * options.offScreenArrowRadius, Vector2.one * 25), viewportSize - Vector2.one * 25)
		arrow.PointB = arrow.PointA - rotateVector(self.direction, 0.45) * options.offScreenArrowSize
		arrow.PointC = arrow.PointA - rotateVector(self.direction, -0.45) * options.offScreenArrowSize
		arrow.Color = parseColor(self, options.offScreenArrowColor[1])
		arrow.Transparency = options.offScreenArrowColor[2]

		local arrowOutline = hidden.arrowOutline
		arrowOutline.PointA = arrow.PointA
		arrowOutline.PointB = arrow.PointB
		arrowOutline.PointC = arrow.PointC
		arrowOutline.Color = parseColor(self, options.offScreenArrowOutlineColor[1], true)
		arrowOutline.Transparency = options.offScreenArrowOutlineColor[2]
	end

	--// 3D box faces
	local box3dEnabled = enabled and onScreen and options.box3d
	for i = 1, #box3d do
		local face = box3d[i]
		for j = 1, #face do
			local line = face[j]
			line.Visible = box3dEnabled
			line.Color = parseColor(self, options.box3dColor[1])
			line.Transparency = options.box3dColor[2]
		end

		if box3dEnabled then
			local p1 = corners.corners[i]
			local p2 = corners.corners[(i == 4) and 1 or (i + 1)]
			local p3 = corners.corners[(i == 4) and 5 or (i + 5)]
			local p4 = corners.corners[(i == 4) and 8 or (i + 4)]

			local line1 = face[1]
			line1.From = p1
			line1.To = p2

			local line2 = face[2]
			line2.From = p2
			line2.To = p3

			local line3 = face[3]
			line3.From = p3
			line3.To = p4
		end
	end
end

--// chams
local ChamObject = {}
ChamObject.__index = ChamObject

function ChamObject.new(player: Player, interface: table)
	local self = setmetatable({}, ChamObject) :: any
	self.player = assert(player, "Missing argument #1 (Player expected)")
	self.interface = assert(interface, "Missing argument #2 (table expected)")
	self:Construct()
	return self
end

function ChamObject:Construct(): nil
	self.highlight = Instance.new("Highlight", container)
	self.updateConnection = RunService.Heartbeat:Connect(function()
		self:Update()
	end)
end

function ChamObject:Destruct(): nil
	if self.updateConnection then
		self.updateConnection:Disconnect()
	end
	if self.highlight then
		self.highlight:Destroy()
	end
	clear(self)
end

function ChamObject:Update(): nil
	local highlight = self.highlight
	local interface = self.interface
	local character = interface.getCharacter(self.player)
	local options = interface.teamSettings[interface.isFriendly(self.player) and "friendly" or "enemy"]
	local enabled = options.enabled and character and not (#interface.whitelist > 0 and not find(interface.whitelist, self.player.UserId))

	highlight.Enabled = enabled and options.chams
	if highlight.Enabled then
		highlight.Adornee = character
		highlight.FillColor = parseColor(self, options.chamsFillColor[1])
		highlight.FillTransparency = options.chamsFillColor[2]
		highlight.OutlineColor = parseColor(self, options.chamsOutlineColor[1], true)
		highlight.OutlineTransparency = options.chamsOutlineColor[2]
		highlight.DepthMode = options.chamsVisibleOnly and "Occluded" or "AlwaysOnTop"
	end
end

local InstanceObject: {} = {}
InstanceObject.__index = InstanceObject

function InstanceObject.new(instance: Instance, options: table)
	local self = setmetatable({}, InstanceObject) :: any
	self.instance = assert(instance, "Missing argument #1 (Instance Expected)")
	self.options = assert(options, "Missing argument #2 (table expected)")
	self:Construct()
	return self
end

function InstanceObject:Construct(): nil
	local options = self.options
	options.enabled = if options.enabled == nil then true else options.enabled
	options.text = options.text or "{name}"
	options.textColor = options.textColor or {Color3.new(1, 1, 1), 1}
	options.textOutline = if options.textOutline == nil then true else options.textOutline
	options.textOutlineColor = options.textOutlineColor or Color3.new()
	options.textSize = options.textSize or 13
	options.textFont = options.textFont or 2
	options.limitDistance = options.limitDistance or false
	options.maxDistance = options.maxDistance or 150

	self.text = Drawing.new("Text")
	self.text.Center = true

	self.renderConnection = RunService.Heartbeat:Connect(function(dt)
		self:Render(dt)
	end)
end

function InstanceObject:Destruct(): nil
	if self.renderConnection then
		self.renderConnection:Disconnect()
	end
	if self.text then
		self.text:Remove()
	end
end

function InstanceObject:Render(): nil
	local instance = self.instance
	if not instance or not instance.Parent then
		return self:Destruct()
	end

	local text = self.text
	local options = self.options
	if not options.enabled then
		text.Visible = false
		return
	end

	local world = getPivot(instance).Position
	local position, visible, depth = worldToScreen(world)
	if options.limitDistance and depth > options.maxDistance then
		visible = false
	end

	text.Visible = visible
	if text.Visible then
		text.Position = position
		text.Color = options.textColor[1]
		text.Transparency = options.textColor[2]
		text.Outline = options.textOutline
		text.OutlineColor = options.textOutlineColor
		text.Size = options.textSize
		text.Font = options.textFont
		text.Text = options.text:gsub("{name}", instance.Name):gsub("{distance}", tostring(round(depth))):gsub("{position}", tostring(world))
	end
end

local EspInterface = {
	_hasLoaded = false,
	_objectCache = {},
	whitelist = {},
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
			chamsFillColor = { Color3.new(0.2, 0.2, 0.2), 0.1 },
			chamsOutlineColor = { Color3.new(1, 0, 0), 0 },
			skeleton = false,
			skeletonColor = { Color3.new(1, 0, 0), 1 },
			skeletonOutline = false,
			skeletonOutlineColor = { Color3.new(), 1 }
		},
		friendly = {
			enabled = false,
			box = false,
			boxColor = {Color3.new(0, 1, 0), 1},
			boxOutline = true,
			boxOutlineColor = {Color3.new(), 1},
			boxFill = false,
			boxFillColor = {Color3.new(0, 1, 0), 0.5},
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
			skeleton = false,
			skeletonColor = { Color3.new(0, 1, 0), 1 },
			skeletonOutline = false,
			skeletonOutlineColor = { Color3.new(), 0 }
		}
	}
}

function EspInterface.AddInstance(instance: Instance, options: table)
	local cache = EspInterface._objectCache
	if cache[instance] then
		warn("Instance handler already exists.")
	else
		cache[instance] = {InstanceObject.new(instance, options)}
	end
	return cache[instance][1]
end

function EspInterface.Load(): nil
	assert(not EspInterface._hasLoaded, "Esp has already been loaded.")

	local function createObject(player: Player)
		EspInterface._objectCache[player] = { EspObject.new(player, EspInterface), ChamObject.new(player, EspInterface) };
	end;

	local function removeObject(player: Player)
		local object = EspInterface._objectCache[player];
		if object then
			for i = 1, #object do
				object[i]:Destruct();
			end;
			EspInterface._objectCache[player] = nil
		end;
	end

	local plrs: { Players } = Players:GetPlayers();
	local createTasks = {};
	for i = 2, #plrs do
		local p = plrs[i];
		createTasks[#createTasks + 1] = function() createObject(p); end;
	end;

	MultiThreadList(createTasks);

	EspInterface.playerAdded = Players.PlayerAdded:Connect(createObject);
	EspInterface.playerRemoving = Players.PlayerRemoving:Connect(removeObject);
	EspInterface._hasLoaded = true;
end

function EspInterface.Unload(): nil
	assert(EspInterface._hasLoaded, "Esp has not been loaded yet.")
	for index, object in EspInterface._objectCache do
		for i = 1, #object do
			object[i]:Destruct()
		end
		EspInterface._objectCache[index] = nil
	end
	EspInterface.playerAdded:Disconnect()
	EspInterface.playerRemoving:Disconnect()
	EspInterface._hasLoaded = false
end

function EspInterface.getWeapon(player: Player): string
	if player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
		local weapon = player.Character:FindFirstChildOfClass("Tool")
		if weapon then
			return weapon.Name
		end
	end
	return "Unknown"
end

function EspInterface.isFriendly(player: Player): boolean
	if not player:FindFirstChild("PlayerStates") then
		return false;
	end;

	if not player.PlayerStates:FindFirstChild("Team") then
		return false;
	end;

	return player.PlayerStates.Team and localPlayer and player.PlayerStates.Team.Value == localPlayer.PlayerStates.Team.Value;
end

function EspInterface.getTeamColor(player: Player): Color3?
	return player.Team and player.Team.TeamColor and player.Team.TeamColor.Color
end

function EspInterface.getCharacter(player: Player): Model?
	return player.Character
end

function EspInterface.getHealth(player: Player): (number, number)
	local character = player and EspInterface.getCharacter(player)
	local humanoid = character and findFirstChildOfClass(character, "Humanoid")
	if humanoid then
		return humanoid.Health, humanoid.MaxHealth
	end
	
	return 100, 100
end

return EspInterface :: EspObject;
