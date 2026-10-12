-- iPad GUI v5 | Delta compatible (client-side LocalScript)
-- The whole iPad is made of GUI (landscape, black bezel, camera dot on the left,
-- round home button on the right). Every screen is its own LAYER, and only the
-- top layer receives touches, so the App Store, Wi-Fi menu and home screen can't overlap.
--
-- iPad is an ITEM: it shows up in your inventory (hotbar) as "iPad".
--   * Tap the item = the iPad appears
--   * TOP button on the iPad (bar on the top edge) = closes the iPad
--   * SIDE buttons (right edge) = volume up / down (hold to repeat)
--   * HOME button (round, right) = go home / close Control Center
--   * Swipe up on the lock screen to unlock
--   * Swipe DOWN from the battery / wifi icons = Control Center
--   * Wi-Fi is OFF by default: Control Center > Wi-Fi > turn on > tap baseplate_5G
--   * App Store: tap GET to download (only works while Wi-Fi is connected)
--   * Swipe up from the very bottom of the screen to leave an app
--   * Battery is fixed at 100%

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local GuiService = game:GetService("GuiService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ===== SETTINGS =====
local FIT = 0.94               -- how much of the screen the iPad fills (bigger = larger iPad)
local PUSH_SCALE = 0.988       -- tap push-back (1 = none, lower = stronger)
local WIFI_NAME = "baseplate_5G"
local VOL_STEP = 0.0625        -- volume change per button press
local RELOCK_ON_CLOSE = true   -- closing the iPad locks it again

-- ===== CLEAN UP OLD COPIES =====
local oldGui = playerGui:FindFirstChild("IPadGui5")
if oldGui then oldGui:Destroy() end
local old3d = Workspace:FindFirstChild("IPad3D_Swipe") -- old 3D version, if still running
if old3d then old3d:Destroy() end
for _, holderObj in ipairs({ player:FindFirstChildOfClass("Backpack"), player.Character }) do
	if holderObj then
		for _, c in ipairs(holderObj:GetChildren()) do
			if c:IsA("Tool") and c:GetAttribute("IPad3D_Tool") then
				c:Destroy()
			end
		end
	end
end

-- ===== DESIGN SIZES =====
local DW, DH = 1000, 706       -- whole iPad
local SX, SY = 86, 42          -- where the screen starts inside the iPad
local SW, SH = 828, 620        -- screen size

local WHITE = Color3.new(1, 1, 1)
local BLACK = Color3.new(0, 0, 0)
local BLUE = Color3.fromRGB(10, 132, 255)
local GREEN = Color3.fromRGB(52, 199, 89)
local PURPLE = Color3.fromRGB(94, 92, 230)
local ORANGE = Color3.fromRGB(255, 159, 10)
local RED = Color3.fromRGB(255, 69, 58)
local GRAY = Color3.fromRGB(140, 140, 155)
local TILE_OFF = Color3.fromRGB(66, 66, 80)
local ROW = Color3.fromRGB(54, 54, 66)

-- ===== SCREEN GUI =====
local gui = Instance.new("ScreenGui")
gui.Name = "IPadGui5"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.DisplayOrder = 50
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = playerGui

local function ui(class, props, parent)
	local o = Instance.new(class)
	for k, v in pairs(props) do
		o[k] = v
	end
	o.Parent = parent
	return o
end

local function corner(parent, r)
	return ui("UICorner", { CornerRadius = r }, parent)
end

local holder = ui("Frame", {
	Name = "Holder",
	Size = UDim2.fromScale(1, 1),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	Visible = false,
}, gui)

local root = ui("Frame", {
	Name = "Root",
	Size = UDim2.fromOffset(DW, DH),
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 1.6),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
}, holder)
local fit = ui("UIScale", { Scale = 1 }, root)

local ipad = ui("Frame", {
	Name = "IPad",
	Size = UDim2.fromOffset(DW, DH),
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
}, root)
local pushScale = ui("UIScale", { Scale = 1 }, ipad)

local conns = {}

local function refit()
	local cam = Workspace.CurrentCamera
	if not cam then return end
	local vp = cam.ViewportSize
	local inset = GuiService:GetGuiInset()
	fit.Scale = math.max(0.1, math.min(vp.X * FIT / DW, (vp.Y - inset.Y) * FIT / DH))
end
refit()
do
	local cam = Workspace.CurrentCamera
	if cam then
		conns[#conns + 1] = cam:GetPropertyChangedSignal("ViewportSize"):Connect(refit)
	end
end

-- ===== SHARED STATE =====
local alive = true
local isOpen = false
local locked = true
local wifiOn, wifiState, wifiView = false, "off", false
local btOn, dndOn, eyeOn = false, false, false
local ccP, ccTarget, ccDragging, ccDrawn = 0, 0, false, -1
local appOpen = nil
local alertOn = false
local brightV, volV = 0.85, 0.5
local tool = nil
local slideTween = nil

-- forward declarations (assigned further down)
local openApp, closeApp, startDownload, showAlert, hideAlert
local refreshStoreStatus, flappyReset, flappyTap
local setBrightness, setVolume, showVolHud
local refreshWifi, showWifiView
local showIPad, hideIPad, closeIPad

-- ===== INPUT HELPERS =====
local function isPress(input)
	local ut = input.UserInputType
	return ut == Enum.UserInputType.Touch or ut == Enum.UserInputType.MouseButton1
end

-- only one drag at a time (swipes, sliders)
local drag = nil
local function beginDrag(input, onMove, onEnd)
	if drag then return false end
	drag = { input = input, type = input.UserInputType, onMove = onMove, onEnd = onEnd }
	return true
end

conns[#conns + 1] = UIS.InputChanged:Connect(function(input)
	if not drag then return end
	local ut = input.UserInputType
	local ok = false
	if drag.type == Enum.UserInputType.Touch then
		ok = (ut == Enum.UserInputType.Touch and input == drag.input)
	else
		ok = (ut == Enum.UserInputType.MouseMovement)
	end
	if ok then
		drag.onMove(input.Position)
	end
end)

conns[#conns + 1] = UIS.InputEnded:Connect(function(input)
	if not drag then return end
	local ut = input.UserInputType
	local ok = false
	if drag.type == Enum.UserInputType.Touch then
		ok = (ut == Enum.UserInputType.Touch and input == drag.input)
	else
		ok = (ut == Enum.UserInputType.MouseButton1)
	end
	if ok then
		local d = drag
		drag = nil
		d.onEnd()
	end
end)

-- little "push back" when you tap the iPad
local function pulse()
	TweenService:Create(pushScale, TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Scale = PUSH_SCALE }):Play()
	task.delay(0.07, function()
		TweenService:Create(pushScale, TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 }):Play()
	end)
end

-- ===== UI HELPERS =====
local blobScales = {}
local function blob(parent, x, y, s, color, tr)
	local f = ui("Frame", {
		Size = UDim2.fromOffset(s, s),
		Position = UDim2.fromOffset(x, y),
		BackgroundColor3 = color,
		BackgroundTransparency = tr,
		BorderSizePixel = 0,
	}, parent)
	corner(f, UDim.new(1, 0))
	table.insert(blobScales, ui("UIScale", { Scale = 1 }, f))
end

local function wallpaper(parent, name, c1, c2, c3, rot, z)
	local w = ui("Frame", {
		Name = name,
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = WHITE,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		ZIndex = z,
	}, parent)
	ui("UIGradient", {
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, c1),
			ColorSequenceKeypoint.new(0.5, c2),
			ColorSequenceKeypoint.new(1, c3),
		}),
		Rotation = rot,
	}, w)
	return w
end

local function group(parent, z)
	return ui("CanvasGroup", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		GroupTransparency = 0,
		ZIndex = z,
	}, parent)
end

local function label(parent, text, x, y, w, h, size, color, font, align, z)
	return ui("TextLabel", {
		Size = UDim2.fromOffset(w, h),
		Position = UDim2.fromOffset(x, y),
		BackgroundTransparency = 1,
		Font = font or Enum.Font.GothamMedium,
		TextSize = size,
		TextColor3 = color or WHITE,
		TextXAlignment = align or Enum.TextXAlignment.Center,
		Text = text,
		ZIndex = z or 3,
	}, parent)
end

-- a real tappable button (use .Activated)
local function button(parent, x, y, w, h, color, tr, z)
	local b = ui("TextButton", {
		Size = UDim2.fromOffset(w, h),
		Position = UDim2.fromOffset(x, y),
		BackgroundColor3 = color or WHITE,
		BackgroundTransparency = tr or 1,
		BorderSizePixel = 0,
		AutoButtonColor = false,
		Text = "",
		ZIndex = z or 3,
	}, parent)
	b.InputBegan:Connect(function(input)
		if isPress(input) then
			pulse()
		end
	end)
	return b
end

local function pressFx(btn, sc, amt)
	btn.InputBegan:Connect(function(input)
		if isPress(input) then
			TweenService:Create(sc, TweenInfo.new(0.08), { Scale = amt }):Play()
		end
	end)
	btn.InputEnded:Connect(function(input)
		if isPress(input) then
			TweenService:Create(sc, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 }):Play()
		end
	end)
end

local function bar(parent, w, h, x, y, rot, z)
	local f = ui("Frame", {
		Size = UDim2.fromOffset(w, h),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromOffset(x, y),
		Rotation = rot,
		BackgroundColor3 = WHITE,
		BorderSizePixel = 0,
		ZIndex = z,
	}, parent)
	corner(f, UDim.new(0, 5))
	return f
end

local function line(parent, x1, y1, x2, y2, th, color, z)
	local dx, dy = x2 - x1, y2 - y1
	local len = math.sqrt(dx * dx + dy * dy)
	local f = ui("Frame", {
		Size = UDim2.fromOffset(len + th * 0.6, th),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromOffset((x1 + x2) / 2, (y1 + y2) / 2),
		Rotation = math.deg(math.atan2(dy, dx)),
		BackgroundColor3 = color,
		BorderSizePixel = 0,
		ZIndex = z,
	}, parent)
	corner(f, UDim.new(0.5, 0))
	return f
end

local function dot(parent, cx, cy, d, color, z)
	local f = ui("Frame", {
		Size = UDim2.fromOffset(d, d),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromOffset(cx, cy),
		BackgroundColor3 = color,
		BorderSizePixel = 0,
		ZIndex = z,
	}, parent)
	corner(f, UDim.new(1, 0))
	return f
end

local function drawWifi(parent, cx, cy, s, color, z)
	local parts = {}
	local th = math.max(2.5, 4 * s)
	for _, r in ipairs({ 12, 21, 30 }) do
		local prev = nil
		for a = -45, 45, 15 do
			local rad = math.rad(a)
			local px, py = cx + math.sin(rad) * r * s, cy - math.cos(rad) * r * s
			if prev then
				table.insert(parts, line(parent, prev[1], prev[2], px, py, th, color, z))
			end
			prev = { px, py }
		end
	end
	table.insert(parts, dot(parent, cx, cy, math.max(4, 8 * s), color, z))
	return parts
end

local function drawBluetooth(parent, cx, cy, s, color, z)
	local segs = {
		{ 0, -24, 0, 24 },
		{ 0, -24, 14, -10 },
		{ 14, -10, -13, 12 },
		{ 0, 24, 14, 10 },
		{ 14, 10, -13, -12 },
	}
	for _, g in ipairs(segs) do
		line(parent, cx + g[1] * s, cy + g[2] * s, cx + g[3] * s, cy + g[4] * s, 4 * s, color, z)
	end
end

local function drawSun(parent, cx, cy, s, color, z)
	dot(parent, cx, cy, 20 * s, color, z)
	for i = 0, 7 do
		local rad = math.rad(i * 45)
		line(
			parent,
			cx + math.cos(rad) * 16 * s, cy + math.sin(rad) * 16 * s,
			cx + math.cos(rad) * 23 * s, cy + math.sin(rad) * 23 * s,
			3.5 * s, color, z
		)
	end
end

local function drawSpeaker(parent, cx, cy, s, color, z)
	local pts = { { -13, -6 }, { -5, -6 }, { 4, -13 }, { 4, 13 }, { -5, 6 }, { -13, 6 }, { -13, -6 } }
	for i = 1, #pts - 1 do
		line(parent, cx + pts[i][1] * s, cy + pts[i][2] * s, cx + pts[i + 1][1] * s, cy + pts[i + 1][2] * s, 3 * s, color, z)
	end
	for _, r in ipairs({ 9, 17 }) do
		local prev = nil
		for a = -35, 35, 17.5 do
			local rad = math.rad(a)
			local px, py = cx + (4 + math.cos(rad) * r) * s, cy + math.sin(rad) * r * s
			if prev then
				line(parent, prev[1], prev[2], px, py, 3 * s, color, z)
			end
			prev = { px, py }
		end
	end
end

-- ===== THE IPAD BODY =====
local body = ui("Frame", {
	Name = "Body",
	Size = UDim2.fromOffset(DW, DH),
	BackgroundColor3 = Color3.fromRGB(30, 30, 33),
	BorderSizePixel = 0,
	ZIndex = 2,
}, ipad)
corner(body, UDim.new(0, 58))
local bodyStroke = ui("UIStroke", { Color = WHITE, Thickness = 5 }, body)
ui("UIGradient", {
	Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(160, 160, 168)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(70, 70, 76)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(105, 105, 112)),
	}),
	Rotation = 90,
}, bodyStroke)

local bezel = ui("Frame", {
	Name = "Bezel",
	Size = UDim2.fromOffset(DW - 28, DH - 28),
	Position = UDim2.fromOffset(14, 14),
	BackgroundColor3 = Color3.fromRGB(4, 4, 5),
	BorderSizePixel = 0,
	ZIndex = 3,
}, ipad)
corner(bezel, UDim.new(0, 46))

dot(ipad, 44, DH / 2, 22, Color3.fromRGB(14, 14, 18), 4)
dot(ipad, 44, DH / 2, 11, Color3.fromRGB(28, 34, 62), 5)

local scr = ui("Frame", {
	Name = "Screen",
	Position = UDim2.fromOffset(SX, SY),
	Size = UDim2.fromOffset(SW, SH),
	BackgroundColor3 = BLACK,
	BorderSizePixel = 0,
	ClipsDescendants = true,
	ZIndex = 4,
}, ipad)
corner(scr, UDim.new(0, 6))

-- ===== APP ICON GLYPHS =====
local glyphs = {}

glyphs.store = function(f, s, u)
	bar(f, 11 * u, 66 * u, s / 2 - 14 * u, 52 * u, 22, 4)
	bar(f, 11 * u, 66 * u, s / 2 + 14 * u, 52 * u, -22, 4)
	bar(f, 40 * u, 9 * u, s / 2, 64 * u, 0, 4)
	dot(f, 78 * u, 22 * u, 8 * u, WHITE, 4)
end

glyphs.roblox = function(f, s, u)
	local sq = ui("Frame", {
		Size = UDim2.fromOffset(60 * u, 60 * u),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromOffset(s / 2, s / 2),
		Rotation = -15,
		BackgroundColor3 = WHITE,
		BorderSizePixel = 0,
		ZIndex = 4,
	}, f)
	corner(sq, UDim.new(0, 8 * u))
	local hole = ui("Frame", {
		Size = UDim2.fromOffset(20 * u, 20 * u),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		BackgroundColor3 = Color3.fromRGB(35, 36, 42),
		BorderSizePixel = 0,
		ZIndex = 5,
	}, sq)
	corner(hole, UDim.new(0, 3 * u))
end

glyphs.flappy = function(f, s, u)
	local pipe = ui("Frame", {
		Size = UDim2.fromOffset(26 * u, 30 * u),
		Position = UDim2.fromOffset(s - 46 * u, s - 44 * u),
		BackgroundColor3 = Color3.fromRGB(115, 190, 46),
		BorderSizePixel = 0,
		ZIndex = 3,
	}, f)
	ui("UIStroke", { Color = Color3.fromRGB(70, 120, 30), Thickness = 2 }, pipe)
	dot(f, s / 2 - 4 * u, s / 2 - 6 * u, 54 * u, Color3.fromRGB(255, 214, 48), 4)
	dot(f, s / 2 - 16 * u, s / 2 + 2 * u, 24 * u, Color3.fromRGB(240, 170, 30), 5)
	dot(f, s / 2 + 10 * u, s / 2 - 16 * u, 20 * u, WHITE, 5)
	dot(f, s / 2 + 14 * u, s / 2 - 16 * u, 9 * u, BLACK, 6)
	local beak = ui("Frame", {
		Size = UDim2.fromOffset(26 * u, 15 * u),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromOffset(s / 2 + 28 * u, s / 2),
		BackgroundColor3 = Color3.fromRGB(255, 128, 40),
		BorderSizePixel = 0,
		ZIndex = 5,
	}, f)
	corner(beak, UDim.new(0.5, 0))
end

glyphs.minecraft = function(f, s, u)
	local g1, g2 = Color3.fromRGB(96, 170, 60), Color3.fromRGB(78, 148, 48)
	local d1, d2 = Color3.fromRGB(134, 96, 58), Color3.fromRGB(112, 78, 46)
	local cols = {
		{ g1, g2, g1 },
		{ d1, g1, d1 },
		{ d2, d1, d2 },
	}
	local px = 30 * u
	local x0, y0 = (s - 3 * px) / 2, (s - 3 * px) / 2
	for r = 1, 3 do
		for c = 1, 3 do
			ui("Frame", {
				Size = UDim2.fromOffset(px, px),
				Position = UDim2.fromOffset(x0 + (c - 1) * px, y0 + (r - 1) * px),
				BackgroundColor3 = cols[r][c],
				BorderSizePixel = 0,
				ZIndex = 4,
			}, f)
		end
	end
end

glyphs.amongus = function(f, s, u)
	local red = Color3.fromRGB(197, 17, 17)
	local function rr(w, h, x, y, color, rad, z)
		local o = ui("Frame", {
			Size = UDim2.fromOffset(w, h),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromOffset(x, y),
			BackgroundColor3 = color,
			BorderSizePixel = 0,
			ZIndex = z,
		}, f)
		corner(o, UDim.new(0, rad))
		return o
	end
	rr(18 * u, 34 * u, s / 2 - 30 * u, s / 2 + 4 * u, red, 8 * u, 4)
	rr(50 * u, 62 * u, s / 2, s / 2 - 2 * u, red, 22 * u, 5)
	rr(22 * u, 22 * u, s / 2 - 12 * u, s / 2 + 30 * u, red, 6 * u, 4)
	rr(22 * u, 22 * u, s / 2 + 12 * u, s / 2 + 30 * u, red, 6 * u, 4)
	rr(32 * u, 20 * u, s / 2 + 8 * u, s / 2 - 14 * u, Color3.fromRGB(150, 225, 245), 10 * u, 6)
end

glyphs.spotify = function(f, s, u)
	dot(f, s / 2, s / 2, 76 * u, Color3.fromRGB(30, 215, 96), 3)
	local dark = Color3.fromRGB(18, 18, 20)
	local arcs = { { 46, -14, 8 }, { 38, 0, 7 }, { 28, 13, 5.5 } }
	for _, a in ipairs(arcs) do
		local w, yo, d = a[1] * u, a[2] * u, a[3] * u
		local prev = nil
		for i = 0, 6 do
			local t = (i / 6) * 2 - 1
			local px = s / 2 + t * w / 2
			local py = s / 2 + yo + t * t * d
			if prev then
				line(f, prev[1], prev[2], px, py, 5 * u, dark, 4)
			end
			prev = { px, py }
		end
	end
end

glyphs.youtube = function(f, s, u)
	local r = ui("Frame", {
		Size = UDim2.fromOffset(80 * u, 56 * u),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromOffset(s / 2, s / 2),
		BackgroundColor3 = Color3.fromRGB(255, 0, 0),
		BorderSizePixel = 0,
		ZIndex = 3,
	}, f)
	corner(r, UDim.new(0, 16 * u))
	local pts = { { -8, -14 }, { -8, 14 }, { 16, 0 } }
	for i = 1, 3 do
		local a, b = pts[i], pts[i % 3 + 1]
		line(f, s / 2 + a[1] * u, s / 2 + a[2] * u, s / 2 + b[1] * u, s / 2 + b[2] * u, 7 * u, WHITE, 4)
	end
end

-- ===== APP CATALOG =====
local APPS = {
	{ id = "store", name = "App Store", sub = "", c1 = Color3.fromRGB(80, 215, 255), c2 = Color3.fromRGB(10, 95, 250), glyph = glyphs.store, time = 0 },
	{ id = "roblox", name = "Roblox", sub = "Play millions of games", c1 = Color3.fromRGB(78, 78, 88), c2 = Color3.fromRGB(22, 22, 28), glyph = glyphs.roblox, time = 14 },
	{ id = "flappy", name = "Flappy Bird", sub = "Tap to flap, dodge the pipes", c1 = Color3.fromRGB(112, 205, 255), c2 = Color3.fromRGB(60, 165, 235), glyph = glyphs.flappy, time = 6 },
	{ id = "minecraft", name = "Minecraft", sub = "Build and explore", c1 = Color3.fromRGB(134, 96, 58), c2 = Color3.fromRGB(90, 60, 36), glyph = glyphs.minecraft, time = 18 },
	{ id = "amongus", name = "Among Us", sub = "Find the impostor", c1 = Color3.fromRGB(40, 48, 86), c2 = Color3.fromRGB(14, 18, 40), glyph = glyphs.amongus, time = 12 },
	{ id = "spotify", name = "Spotify", sub = "Music for everyone", c1 = Color3.fromRGB(34, 34, 38), c2 = Color3.fromRGB(12, 12, 14), glyph = glyphs.spotify, time = 9 },
	{ id = "youtube", name = "YouTube", sub = "Watch videos", c1 = Color3.fromRGB(255, 255, 255), c2 = Color3.fromRGB(232, 232, 240), glyph = glyphs.youtube, time = 8 },
}
local APPSById = {}
for _, a in ipairs(APPS) do
	APPSById[a.id] = a
end

local function makeAppIcon(parent, app, s, x, y, z)
	local f = ui("Frame", {
		Size = UDim2.fromOffset(s, s),
		Position = UDim2.fromOffset(x, y),
		BackgroundColor3 = WHITE,
		BorderSizePixel = 0,
		ZIndex = z,
	}, parent)
	corner(f, UDim.new(0, s * 0.235))
	ui("UIGradient", { Color = ColorSequence.new(app.c1, app.c2), Rotation = 90 }, f)
	ui("UIStroke", { Color = WHITE, Thickness = 1.2, Transparency = 0.8 }, f)
	app.glyph(f, s, s / 110)
	return f
end

-- =====================================================================
-- LAYER 1: HOME SCREEN
-- =====================================================================
local home = wallpaper(scr, "Home", Color3.fromRGB(14, 120, 170), Color3.fromRGB(52, 84, 210), Color3.fromRGB(150, 72, 215), 70, 1)
blob(home, -80, 40, 340, Color3.fromRGB(120, 255, 235), 0.82)
blob(home, 500, 200, 380, Color3.fromRGB(255, 170, 255), 0.84)
blob(home, 200, 360, 320, Color3.fromRGB(110, 190, 255), 0.8)

local homeBarV = ui("Frame", {
	Size = UDim2.fromOffset(180, 6),
	Position = UDim2.fromOffset(SW / 2 - 90, SH - 16),
	BackgroundColor3 = WHITE,
	BackgroundTransparency = 0.3,
	BorderSizePixel = 0,
	ZIndex = 2,
}, home)
corner(homeBarV, UDim.new(1, 0))

local homeContent = group(home, 3)

local homeEntries = {}
local slotCount = 0

local function slotPos(slot)
	local col, row = (slot - 1) % 6, math.floor((slot - 1) / 6)
	return 36 + col * 132, 84 + row * 150
end

local function addHomeIcon(app, installed)
	slotCount = slotCount + 1
	local x, y = slotPos(slotCount)
	local frame = makeAppIcon(homeContent, app, 96, x, y, 3)
	local sc = ui("UIScale", { Scale = 1 }, frame)
	local rad = UDim.new(0, 96 * 0.235)
	local dimF = ui("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = BLACK,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 8,
	}, frame)
	corner(dimF, rad)
	local dl = ui("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = BLACK,
		BackgroundTransparency = installed and 1 or 0.45,
		BorderSizePixel = 0,
		ZIndex = 9,
	}, frame)
	corner(dl, rad)
	local track = ui("Frame", {
		Size = UDim2.fromOffset(72, 7),
		Position = UDim2.fromOffset(12, 76),
		BackgroundColor3 = WHITE,
		BackgroundTransparency = 0.6,
		BorderSizePixel = 0,
		Visible = not installed,
		ZIndex = 10,
	}, frame)
	corner(track, UDim.new(1, 0))
	local fill = ui("Frame", {
		Size = UDim2.fromScale(0, 1),
		BackgroundColor3 = WHITE,
		BorderSizePixel = 0,
		ZIndex = 11,
	}, track)
	corner(fill, UDim.new(1, 0))

	local lab = label(homeContent, app.name, x - 12, y + 102, 120, 22, 17, WHITE, Enum.Font.GothamMedium, nil, 3)
	lab.TextStrokeTransparency = 0.85

	local hit = button(home, x - 12, y - 8, 120, 134, WHITE, 1, 4)
	hit.InputBegan:Connect(function(input)
		if isPress(input) then
			TweenService:Create(sc, TweenInfo.new(0.08), { Scale = 0.88 }):Play()
			TweenService:Create(dimF, TweenInfo.new(0.1), { BackgroundTransparency = 0.75 }):Play()
		end
	end)
	hit.InputEnded:Connect(function(input)
		if isPress(input) then
			TweenService:Create(sc, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 }):Play()
			TweenService:Create(dimF, TweenInfo.new(0.1), { BackgroundTransparency = 1 }):Play()
		end
	end)

	local entry = { app = app, installed = installed, frame = frame, scale = sc, dl = dl, track = track, fill = fill }
	homeEntries[app.id] = entry

	hit.Activated:Connect(function()
		if entry.installed then
			openApp(app.id)
		end
	end)
	return entry
end

addHomeIcon(APPSById.store, true)

-- =====================================================================
-- LAYER 2: APPS
-- =====================================================================
local appLayer = ui("Frame", {
	Name = "AppLayer",
	Size = UDim2.fromScale(1, 1),
	Position = UDim2.fromOffset(0, SH),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	Visible = false,
	ZIndex = 2,
}, scr)

local appCatcher = ui("Frame", {
	Size = UDim2.fromScale(1, 1),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	Active = true,
	ZIndex = 1,
}, appLayer)
appCatcher.InputBegan:Connect(function(input)
	if isPress(input) then
		pulse()
		if appOpen == "flappy" then
			flappyTap()
		end
	end
end)

local storeFrame = ui("Frame", {
	Name = "Store",
	Size = UDim2.fromScale(1, 1),
	BackgroundColor3 = Color3.fromRGB(20, 20, 28),
	BorderSizePixel = 0,
	Visible = false,
	ZIndex = 2,
}, appLayer)

label(storeFrame, "App Store", 28, 54, 400, 50, 40, WHITE, Enum.Font.GothamBold, Enum.TextXAlignment.Left, 2)
local storeStatus = label(storeFrame, "", 28, 106, 560, 26, 18, GRAY, Enum.Font.GothamMedium, Enum.TextXAlignment.Left, 2)

local installState = {}
local storeRows = {}

local function refreshRow(app)
	local r, st = storeRows[app.id], installState[app.id]
	if not r then return end
	if st.state == "none" then
		r.btn.BackgroundColor3 = BLUE
		r.fill.Visible = false
		r.txt.Text = "GET"
		r.txt.TextSize = 20
		r.txt.TextColor3 = WHITE
	elseif st.state == "downloading" then
		r.btn.BackgroundColor3 = Color3.fromRGB(60, 60, 76)
		r.fill.Visible = true
		r.fill.Size = UDim2.fromScale(st.p, 1)
		if wifiState == "connected" then
			r.txt.Text = math.floor(st.p * 100) .. "%"
			r.txt.TextSize = 20
		else
			r.txt.Text = "Waiting..."
			r.txt.TextSize = 14
		end
		r.txt.TextColor3 = WHITE
	else
		r.btn.BackgroundColor3 = Color3.fromRGB(60, 60, 76)
		r.fill.Visible = false
		r.txt.Text = "OPEN"
		r.txt.TextSize = 20
		r.txt.TextColor3 = BLUE
	end
end

local function onStoreButton(app)
	local st = installState[app.id]
	if st.state == "installed" then
		openApp(app.id)
	elseif st.state == "none" then
		if wifiState ~= "connected" then
			showAlert()
		else
			startDownload(app)
		end
	end
end

local idx = 0
for _, app in ipairs(APPS) do
	if app.id ~= "store" then
		local cx, cy = 28 + (idx % 2) * 400, 150 + math.floor(idx / 2) * 120
		idx = idx + 1
		makeAppIcon(storeFrame, app, 72, cx, cy, 2)
		label(storeFrame, app.name, cx + 88, cy + 2, 180, 28, 22, WHITE, Enum.Font.GothamBold, Enum.TextXAlignment.Left, 2)
		local subL = label(storeFrame, app.sub, cx + 88, cy + 34, 180, 38, 14, GRAY, Enum.Font.GothamMedium, Enum.TextXAlignment.Left, 2)
		subL.TextWrapped = true
		subL.TextYAlignment = Enum.TextYAlignment.Top

		local btn = button(storeFrame, cx + 276, cy + 17, 84, 38, BLUE, 0, 2)
		btn.ClipsDescendants = true
		corner(btn, UDim.new(1, 0))
		local fill = ui("Frame", {
			Size = UDim2.fromScale(0, 1),
			BackgroundColor3 = BLUE,
			BorderSizePixel = 0,
			Visible = false,
			ZIndex = 3,
		}, btn)
		corner(fill, UDim.new(1, 0))
		local txt = label(btn, "GET", 0, 0, 84, 38, 20, WHITE, Enum.Font.GothamBold, nil, 4)

		storeRows[app.id] = { btn = btn, fill = fill, txt = txt }
		installState[app.id] = { state = "none", p = 0 }

		btn.InputBegan:Connect(function(input)
			if isPress(input) then btn.BackgroundTransparency = 0.3 end
		end)
		btn.InputEnded:Connect(function(input)
			if isPress(input) then btn.BackgroundTransparency = 0 end
		end)
		btn.Activated:Connect(function()
			onStoreButton(app)
		end)
	end
end

local alertFrame = ui("Frame", {
	Size = UDim2.fromScale(1, 1),
	BackgroundColor3 = BLACK,
	BackgroundTransparency = 0.45,
	BorderSizePixel = 0,
	Active = true,
	Visible = false,
	ZIndex = 30,
}, storeFrame)
local alertBox = ui("Frame", {
	Size = UDim2.fromOffset(440, 220),
	Position = UDim2.fromOffset((SW - 440) / 2, 170),
	BackgroundColor3 = Color3.fromRGB(46, 46, 60),
	BorderSizePixel = 0,
	ZIndex = 31,
}, alertFrame)
corner(alertBox, UDim.new(0, 28))
label(alertBox, "Wi-Fi Required", 0, 24, 440, 36, 28, WHITE, Enum.Font.GothamBold, nil, 32)
local alertMsg = label(alertBox, "Connect to Wi-Fi to download apps.", 40, 68, 360, 70, 20, GRAY, Enum.Font.GothamMedium, nil, 32)
alertMsg.TextWrapped = true
ui("Frame", {
	Size = UDim2.fromOffset(440, 1),
	Position = UDim2.fromOffset(0, 150),
	BackgroundColor3 = WHITE,
	BackgroundTransparency = 0.85,
	BorderSizePixel = 0,
	ZIndex = 32,
}, alertBox)
local alertOk = button(alertBox, 0, 151, 440, 69, WHITE, 1, 32)
label(alertOk, "OK", 0, 0, 440, 69, 28, BLUE, Enum.Font.GothamBold, nil, 33)

showAlert = function()
	alertOn = true
	alertFrame.Visible = true
end
hideAlert = function()
	alertOn = false
	alertFrame.Visible = false
end
alertOk.Activated:Connect(function()
	hideAlert()
end)

refreshStoreStatus = function()
	if wifiState == "connected" then
		storeStatus.Text = "Connected to " .. WIFI_NAME
		storeStatus.TextColor3 = GREEN
	else
		storeStatus.Text = "No Wi-Fi connection. Connect to download apps."
		storeStatus.TextColor3 = ORANGE
	end
end
refreshStoreStatus()

startDownload = function(app)
	local st = installState[app.id]
	if st.state ~= "none" then return end
	st.state = "downloading"
	st.p = 0
	addHomeIcon(app, false)
	refreshRow(app)
end

local function finishInstall(app)
	local st = installState[app.id]
	st.state = "installed"
	st.p = 1
	local e = homeEntries[app.id]
	if e then
		e.installed = true
		TweenService:Create(e.dl, TweenInfo.new(0.3), { BackgroundTransparency = 1 }):Play()
		e.track.Visible = false
		TweenService:Create(e.scale, TweenInfo.new(0.15), { Scale = 1.12 }):Play()
		task.delay(0.15, function()
			TweenService:Create(e.scale, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 }):Play()
		end)
	end
	refreshRow(app)
end

-- FLAPPY BIRD
local GROUND_Y, PIPE_W, GAP, SPACING = 520, 84, 190, 270
local SPEED, GRAV, FLAP = 170, 1300, -430
local BIRD_X = 190

local flappyFrame = ui("Frame", {
	Name = "Flappy",
	Size = UDim2.fromScale(1, 1),
	BackgroundColor3 = Color3.fromRGB(112, 197, 206),
	BorderSizePixel = 0,
	ClipsDescendants = true,
	Visible = false,
	ZIndex = 2,
}, appLayer)

for _, c in ipairs({ { 60, 180, 140 }, { 420, 120, 180 }, { 650, 300, 130 } }) do
	local cl = ui("Frame", {
		Size = UDim2.fromOffset(c[3], c[3] * 0.35),
		Position = UDim2.fromOffset(c[1], c[2]),
		BackgroundColor3 = WHITE,
		BackgroundTransparency = 0.35,
		BorderSizePixel = 0,
		ZIndex = 1,
	}, flappyFrame)
	corner(cl, UDim.new(1, 0))
end

local pipes = {}
for i = 1, 4 do
	local top = ui("Frame", { BackgroundColor3 = Color3.fromRGB(115, 190, 46), BorderSizePixel = 0, ZIndex = 2 }, flappyFrame)
	ui("UIStroke", { Color = Color3.fromRGB(70, 120, 30), Thickness = 4 }, top)
	local bot = ui("Frame", { BackgroundColor3 = Color3.fromRGB(115, 190, 46), BorderSizePixel = 0, ZIndex = 2 }, flappyFrame)
	ui("UIStroke", { Color = Color3.fromRGB(70, 120, 30), Thickness = 4 }, bot)
	pipes[i] = { x = 0, gap = 300, top = top, bot = bot, scored = false }
end

local ground = ui("Frame", {
	Size = UDim2.fromOffset(SW, SH - GROUND_Y),
	Position = UDim2.fromOffset(0, GROUND_Y),
	BackgroundColor3 = Color3.fromRGB(222, 216, 150),
	BorderSizePixel = 0,
	ZIndex = 3,
}, flappyFrame)
ui("Frame", {
	Size = UDim2.fromOffset(SW, 16),
	BackgroundColor3 = Color3.fromRGB(100, 200, 60),
	BorderSizePixel = 0,
	ZIndex = 4,
}, ground)

local bird = ui("Frame", {
	Size = UDim2.fromOffset(44, 34),
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromOffset(BIRD_X, 290),
	BackgroundColor3 = Color3.fromRGB(255, 214, 48),
	BorderSizePixel = 0,
	ZIndex = 5,
}, flappyFrame)
corner(bird, UDim.new(1, 0))
dot(bird, 14, 21, 16, Color3.fromRGB(240, 170, 30), 6)
dot(bird, 32, 11, 13, WHITE, 6)
dot(bird, 35, 11, 6, BLACK, 7)
local beak = ui("Frame", {
	Size = UDim2.fromOffset(16, 10),
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromOffset(42, 21),
	BackgroundColor3 = Color3.fromRGB(255, 128, 40),
	BorderSizePixel = 0,
	ZIndex = 6,
}, bird)
corner(beak, UDim.new(0.5, 0))

local fScoreLabel = label(flappyFrame, "0", 0, 60, SW, 90, 76, WHITE, Enum.Font.GothamBold, nil, 6)
fScoreLabel.TextStrokeColor3 = BLACK
fScoreLabel.TextStrokeTransparency = 0.3
local fHint = label(flappyFrame, "Tap to flap", 0, 350, SW, 46, 30, WHITE, Enum.Font.GothamBold, nil, 6)
fHint.TextStrokeColor3 = BLACK
fHint.TextStrokeTransparency = 0.3

local BROWN = Color3.fromRGB(84, 56, 71)
local fOver = ui("Frame", {
	Size = UDim2.fromOffset(400, 250),
	Position = UDim2.fromOffset((SW - 400) / 2, 130),
	BackgroundColor3 = Color3.fromRGB(222, 216, 150),
	BorderSizePixel = 0,
	Visible = false,
	ZIndex = 7,
}, flappyFrame)
corner(fOver, UDim.new(0, 22))
ui("UIStroke", { Color = BROWN, Thickness = 5 }, fOver)
label(fOver, "GAME OVER", 0, 20, 400, 46, 36, Color3.fromRGB(230, 110, 30), Enum.Font.GothamBold, nil, 8)
local fOverScore = label(fOver, "Score: 0", 0, 86, 400, 36, 28, BROWN, Enum.Font.GothamBold, nil, 8)
local fOverBest = label(fOver, "Best: 0", 0, 128, 400, 36, 28, BROWN, Enum.Font.GothamBold, nil, 8)
label(fOver, "Tap to retry", 0, 192, 400, 32, 22, BROWN, Enum.Font.GothamMedium, nil, 8)

local fState, by, bv, fScore, fBest, deadAt = "ready", 290, 0, 0, 0, 0

local function flappyApply()
	bird.Position = UDim2.fromOffset(BIRD_X, by)
	bird.Rotation = math.clamp(bv * 0.08, -25, 80)
	for _, p in ipairs(pipes) do
		local topH = p.gap - GAP / 2
		p.top.Position = UDim2.fromOffset(p.x, 0)
		p.top.Size = UDim2.fromOffset(PIPE_W, topH)
		p.bot.Position = UDim2.fromOffset(p.x, p.gap + GAP / 2)
		p.bot.Size = UDim2.fromOffset(PIPE_W, GROUND_Y - (p.gap + GAP / 2))
	end
end

flappyReset = function()
	fState = "ready"
	by, bv, fScore = 290, 0, 0
	for i, p in ipairs(pipes) do
		p.x = SW + 100 + (i - 1) * SPACING
		p.gap = math.random(175, 420)
		p.scored = false
	end
	fScoreLabel.Text = "0"
	fHint.Visible = true
	fOver.Visible = false
	flappyApply()
end

local function flappyDie()
	fState = "dead"
	deadAt = os.clock()
	if fScore > fBest then fBest = fScore end
	fOverScore.Text = "Score: " .. fScore
	fOverBest.Text = "Best: " .. fBest
	fOver.Visible = true
end

flappyTap = function()
	if fState == "ready" then
		fState = "playing"
		fHint.Visible = false
		bv = FLAP
	elseif fState == "playing" then
		bv = FLAP
	elseif fState == "dead" and os.clock() - deadAt > 0.5 then
		flappyReset()
	end
end

local function flappyUpdate(dt)
	if fState == "ready" then
		by = 290 + math.sin(os.clock() * 5) * 9
		bv = 0
	elseif fState == "playing" then
		bv = bv + GRAV * dt
		by = by + bv * dt
		if by < 10 then
			by = 10
			bv = 0
		end
		local maxX = -1000
		for _, p in ipairs(pipes) do
			p.x = p.x - SPEED * dt
			if p.x > maxX then maxX = p.x end
		end
		for _, p in ipairs(pipes) do
			if p.x < -PIPE_W then
				p.x = maxX + SPACING
				maxX = p.x
				p.gap = math.random(175, 420)
				p.scored = false
			end
		end
		local left, right, top, bottom = BIRD_X - 15, BIRD_X + 15, by - 13, by + 13
		for _, p in ipairs(pipes) do
			if not p.scored and p.x + PIPE_W < left then
				p.scored = true
				fScore = fScore + 1
				fScoreLabel.Text = tostring(fScore)
			end
			if right > p.x and left < p.x + PIPE_W then
				if top < p.gap - GAP / 2 or bottom > p.gap + GAP / 2 then
					flappyDie()
				end
			end
		end
		if bottom >= GROUND_Y then
			by = GROUND_Y - 13
			flappyDie()
		end
	elseif fState == "dead" then
		if by < GROUND_Y - 13 then
			bv = bv + GRAV * dt
			by = math.min(by + bv * dt, GROUND_Y - 13)
		end
	end
	flappyApply()
end
flappyReset()

local genericFrame = ui("Frame", {
	Name = "Generic",
	Size = UDim2.fromScale(1, 1),
	BackgroundColor3 = Color3.fromRGB(18, 18, 26),
	BorderSizePixel = 0,
	Visible = false,
	ZIndex = 2,
}, appLayer)
local bigIcons = {}
for _, app in ipairs(APPS) do
	if app.id ~= "store" and app.id ~= "flappy" then
		local ic = makeAppIcon(genericFrame, app, 150, (SW - 150) / 2, 110, 2)
		ic.Visible = false
		bigIcons[app.id] = ic
	end
end
local genName = label(genericFrame, "", 0, 285, SW, 50, 40, WHITE, Enum.Font.GothamBold, nil, 2)
local genSub = label(genericFrame, "", 0, 338, SW, 30, 22, GRAY, Enum.Font.GothamMedium, nil, 2)
label(genericFrame, "This app has no content yet", 0, 430, SW, 26, 18, Color3.fromRGB(100, 100, 115), Enum.Font.GothamMedium, nil, 2)

local bottomZone = ui("Frame", {
	Name = "BottomZone",
	Size = UDim2.fromOffset(SW, 60),
	Position = UDim2.fromOffset(0, SH - 60),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	Active = true,
	ZIndex = 10,
}, appLayer)
local appBarV = ui("Frame", {
	Size = UDim2.fromOffset(180, 6),
	Position = UDim2.fromOffset(SW / 2 - 90, SH - 16),
	BackgroundColor3 = WHITE,
	BackgroundTransparency = 0.35,
	BorderSizePixel = 0,
	ZIndex = 11,
}, appLayer)
corner(appBarV, UDim.new(1, 0))

local appToken = 0

openApp = function(id)
	local app = APPSById[id]
	if not app then return end
	local generic = id ~= "store" and id ~= "flappy"
	storeFrame.Visible = id == "store"
	flappyFrame.Visible = id == "flappy"
	genericFrame.Visible = generic
	if generic then
		for k, ic in pairs(bigIcons) do
			ic.Visible = (k == id)
		end
		genName.Text = app.name
		genSub.Text = app.sub
	end
	if id == "flappy" then flappyReset() end
	if id == "store" then
		hideAlert()
		refreshStoreStatus()
	end
	local already = appOpen ~= nil
	appOpen = id
	appToken = appToken + 1
	if not already then
		appLayer.Position = UDim2.fromOffset(0, SH)
		appLayer.Visible = true
		TweenService:Create(appLayer, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Position = UDim2.fromOffset(0, 0) }):Play()
	end
end

closeApp = function(instant)
	if not appOpen then return end
	appOpen = nil
	appToken = appToken + 1
	local my = appToken
	hideAlert()
	flappyReset()
	if instant then
		appLayer.Visible = false
		appLayer.Position = UDim2.fromOffset(0, SH)
		return
	end
	local tw = TweenService:Create(appLayer, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Position = UDim2.fromOffset(0, -SH) })
	tw.Completed:Connect(function()
		if appToken == my then
			appLayer.Visible = false
			appLayer.Position = UDim2.fromOffset(0, SH)
		end
	end)
	tw:Play()
end

bottomZone.InputBegan:Connect(function(input)
	if not isPress(input) then return end
	pulse()
	local startY, startT, lastDy = input.Position.Y, os.clock(), 0
	beginDrag(input, function(pos)
		lastDy = math.max(0, (startY - pos.Y) / fit.Scale)
		appLayer.Position = UDim2.fromOffset(0, -lastDy)
	end, function()
		local dt = math.max(os.clock() - startT, 0.05)
		if lastDy > 110 or (lastDy > 30 and lastDy / dt > 700) then
			closeApp(false)
		else
			TweenService:Create(
				appLayer,
				TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
				{ Position = UDim2.fromOffset(0, 0) }
			):Play()
		end
	end)
end)

-- =====================================================================
-- LAYER 3: LOCK SCREEN
-- =====================================================================
local lock = wallpaper(scr, "Lock", Color3.fromRGB(24, 20, 84), Color3.fromRGB(132, 52, 172), Color3.fromRGB(255, 128, 118), 70, 3)
lock.Active = true
blob(lock, -80, 30, 340, Color3.fromRGB(120, 140, 255), 0.82)
blob(lock, 520, 180, 380, Color3.fromRGB(255, 190, 120), 0.85)
blob(lock, 150, 340, 320, Color3.fromRGB(255, 110, 190), 0.82)

local lockContent = group(lock, 6)

local shackle = ui("Frame", {
	Size = UDim2.fromOffset(22, 22),
	Position = UDim2.fromOffset(SW / 2 - 11, 66),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	ZIndex = 6,
}, lockContent)
corner(shackle, UDim.new(1, 0))
ui("UIStroke", { Color = WHITE, Thickness = 4, Transparency = 0.1 }, shackle)
local lockBody = ui("Frame", {
	Size = UDim2.fromOffset(36, 26),
	Position = UDim2.fromOffset(SW / 2 - 18, 82),
	BackgroundColor3 = WHITE,
	BackgroundTransparency = 0.1,
	BorderSizePixel = 0,
	ZIndex = 7,
}, lockContent)
corner(lockBody, UDim.new(0, 7))

local dateLabel = label(lockContent, "", 0, 124, SW, 34, 28, WHITE, Enum.Font.GothamMedium, nil, 6)
dateLabel.TextTransparency = 0.1
local timeLabel = label(lockContent, "", 0, 156, SW, 130, 118, WHITE, Enum.Font.GothamBold, nil, 6)

local hint = label(lockContent, "Swipe up to unlock", 0, SH - 74, SW, 30, 22, WHITE, Enum.Font.GothamMedium, nil, 6)
hint.TextTransparency = 0.15
TweenService:Create(
	hint,
	TweenInfo.new(1.1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
	{ TextTransparency = 0.7 }
):Play()

local lockBar = ui("Frame", {
	Size = UDim2.fromOffset(180, 6),
	Position = UDim2.fromOffset(SW / 2 - 90, SH - 16),
	BackgroundColor3 = WHITE,
	BackgroundTransparency = 0.2,
	BorderSizePixel = 0,
	ZIndex = 6,
}, lockContent)
corner(lockBar, UDim.new(1, 0))

local function unlock()
	locked = false
	if slideTween then slideTween:Cancel() end
	slideTween = TweenService:Create(
		lock,
		TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ Position = UDim2.fromOffset(0, -SH - 20) }
	)
	slideTween.Completed:Connect(function()
		if not locked then
			lock.Visible = false
		end
	end)
	slideTween:Play()
end

local function snapBack()
	if slideTween then slideTween:Cancel() end
	slideTween = TweenService:Create(
		lock,
		TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{ Position = UDim2.fromOffset(0, 0) }
	)
	slideTween:Play()
end

lock.InputBegan:Connect(function(input)
	if not isPress(input) then return end
	pulse()
	if slideTween then slideTween:Cancel() end
	local startY, startT, lastDy = input.Position.Y, os.clock(), 0
	beginDrag(input, function(pos)
		lastDy = math.max(0, (startY - pos.Y) / fit.Scale)
		lock.Position = UDim2.fromOffset(0, -lastDy)
	end, function()
		local dt = math.max(os.clock() - startT, 0.05)
		if lastDy > SH * 0.3 or (lastDy > SH * 0.08 and lastDy / dt > SH * 1.4) then
			unlock()
		else
			snapBack()
		end
	end)
end)

-- =====================================================================
-- LAYER 4: CONTROL CENTER
-- =====================================================================
local PANEL_W, PANEL_H = 600, 360
local PANEL_X, PANEL_Y = (SW - PANEL_W) / 2, 64

local ccRoot = ui("Frame", {
	Name = "ControlCenter",
	Size = UDim2.fromScale(1, 1),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	Visible = false,
	ZIndex = 4,
}, scr)

local frost = ui("Frame", {
	Size = UDim2.fromScale(1, 1),
	BackgroundColor3 = Color3.fromRGB(110, 115, 145),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	Active = true,
	ZIndex = 1,
}, ccRoot)

local panel = ui("Frame", {
	Name = "Panel",
	Size = UDim2.fromOffset(PANEL_W, PANEL_H),
	Position = UDim2.fromOffset(PANEL_X, -PANEL_H - 30),
	BackgroundColor3 = Color3.fromRGB(32, 32, 42),
	BackgroundTransparency = 0.1,
	BorderSizePixel = 0,
	ZIndex = 2,
}, ccRoot)
corner(panel, UDim.new(0, 36))
ui("UIStroke", { Color = WHITE, Thickness = 1.5, Transparency = 0.85 }, panel)

local panelBg = ui("Frame", {
	Size = UDim2.fromScale(1, 1),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	Active = true,
	ZIndex = 1,
}, panel)

local ccMain = ui("Frame", {
	Size = UDim2.fromScale(1, 1),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	ZIndex = 2,
}, panel)
local ccWifi = ui("Frame", {
	Size = UDim2.fromScale(1, 1),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	Visible = false,
	ZIndex = 2,
}, panel)

local function ccDragBegin(input, inPanel)
	if not isPress(input) then return end
	pulse()
	local startY = input.Position.Y
	local moved = 0
	local started = beginDrag(input, function(pos)
		local dy = (pos.Y - startY) / fit.Scale
		moved = math.max(moved, math.abs(dy))
		ccP = math.clamp(1 + dy / 240, 0, 1)
	end, function()
		ccDragging = false
		if (not inPanel and moved < 14) or ccP < 0.6 then
			ccTarget = 0
		else
			ccTarget = 1
		end
	end)
	if started then
		ccDragging = true
	end
end
frost.InputBegan:Connect(function(input) ccDragBegin(input, false) end)
panelBg.InputBegan:Connect(function(input) ccDragBegin(input, true) end)

local function setToggle(tile, carve, on, onColor)
	local c = on and onColor or TILE_OFF
	TweenService:Create(tile, TweenInfo.new(0.15), { BackgroundColor3 = c }):Play()
	if carve then
		TweenService:Create(carve, TweenInfo.new(0.15), { BackgroundColor3 = c }):Play()
	end
end

local TILE = 100
local function makeTile(i, text)
	local x = 30 + (i - 1) * (TILE + 46.67)
	local t = button(ccMain, x, 26, TILE, TILE, TILE_OFF, 0, 3)
	corner(t, UDim.new(0, 28))
	local sc = ui("UIScale", { Scale = 1 }, t)
	pressFx(t, sc, 0.92)
	local lab = label(ccMain, text, x - 12, 26 + TILE + 8, TILE + 24, 20, 14, WHITE, Enum.Font.GothamMedium, nil, 3)
	lab.TextTransparency = 0.1
	return t, sc, lab
end

local wifiTile, wifiSc, wifiLab = makeTile(1, "Wi-Fi")
drawWifi(wifiTile, TILE / 2, 62, 0.9, WHITE, 5)

local btTile = makeTile(2, "Bluetooth")
drawBluetooth(btTile, TILE / 2, TILE / 2, 0.9, WHITE, 5)

local dndTile = makeTile(3, "Do Not Disturb")
dot(dndTile, TILE / 2, TILE / 2, 40, WHITE, 5)
local dndCarve = dot(dndTile, TILE / 2 + 11, TILE / 2 - 7, 34, TILE_OFF, 6)

local eyeTile = makeTile(4, "Eye Protection")
local eyeOutline = ui("Frame", {
	Size = UDim2.fromOffset(52, 30),
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromOffset(TILE / 2, TILE / 2),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	ZIndex = 5,
}, eyeTile)
corner(eyeOutline, UDim.new(1, 0))
ui("UIStroke", { Color = WHITE, Thickness = 4 }, eyeOutline)
dot(eyeTile, TILE / 2, TILE / 2, 14, WHITE, 5)

local function makeSlider(y, text, drawIcon, init)
	local track = ui("Frame", {
		Size = UDim2.fromOffset(540, 68),
		Position = UDim2.fromOffset(30, y),
		BackgroundColor3 = Color3.fromRGB(78, 78, 92),
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Active = true,
		ZIndex = 3,
	}, ccMain)
	corner(track, UDim.new(0, 26))
	local fill = ui("Frame", {
		Size = UDim2.new(init, 0, 1, 0),
		BackgroundColor3 = WHITE,
		BorderSizePixel = 0,
		ZIndex = 4,
	}, track)
	corner(fill, UDim.new(0, 26))
	drawIcon(track, 40, 34, 0.85, Color3.fromRGB(120, 120, 135), 6)
	label(track, text, 84, 0, 300, 68, 22, Color3.fromRGB(125, 125, 140), Enum.Font.GothamMedium, Enum.TextXAlignment.Left, 6)
	return track, fill
end

local brightTrack, brightFill = makeSlider(176, "Brightness", drawSun, brightV)
local volTrack, volFill = makeSlider(260, "Volume", drawSpeaker, volV)

local function bindSlider(track, setFn)
	track.InputBegan:Connect(function(input)
		if not isPress(input) then return end
		pulse()
		local function setFromX(x)
			setFn(math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1))
		end
		setFromX(input.Position.X)
		beginDrag(input, function(pos)
			setFromX(pos.X)
		end, function() end)
	end)
end

local dim, warm
setBrightness = function(v)
	brightV = math.clamp(v, 0, 1)
	brightFill.Size = UDim2.new(brightV, 0, 1, 0)
	if dim then
		dim.BackgroundTransparency = 1 - (1 - brightV) * 0.85
	end
end
setVolume = function(v)
	volV = math.clamp(v, 0, 1)
	volFill.Size = UDim2.new(volV, 0, 1, 0)
end
bindSlider(brightTrack, function(v) setBrightness(v) end)
bindSlider(volTrack, function(v) setVolume(v) end)

local wBack = button(ccWifi, 12, 12, 180, 56, WHITE, 1, 3)
label(wBack, "< Back", 10, 0, 160, 56, 24, BLUE, Enum.Font.GothamMedium, Enum.TextXAlignment.Left, 4)
label(ccWifi, "Wi-Fi", 0, 18, PANEL_W, 44, 28, WHITE, Enum.Font.GothamBold, nil, 3)

local swRow = button(ccWifi, 30, 84, 540, 68, ROW, 0, 3)
corner(swRow, UDim.new(0, 24))
label(swRow, "Wi-Fi", 26, 0, 200, 68, 26, WHITE, Enum.Font.GothamMedium, Enum.TextXAlignment.Left, 4)
local swTrack = ui("Frame", {
	Size = UDim2.fromOffset(88, 50),
	Position = UDim2.fromOffset(540 - 88 - 22, 9),
	BackgroundColor3 = Color3.fromRGB(86, 86, 100),
	BorderSizePixel = 0,
	ZIndex = 4,
}, swRow)
corner(swTrack, UDim.new(1, 0))
local swKnob = ui("Frame", {
	Size = UDim2.fromOffset(42, 42),
	Position = UDim2.fromOffset(4, 4),
	BackgroundColor3 = WHITE,
	BorderSizePixel = 0,
	ZIndex = 5,
}, swTrack)
corner(swKnob, UDim.new(1, 0))

local netHeader = label(ccWifi, "NETWORKS", 44, 166, 300, 22, 15, GRAY, Enum.Font.GothamMedium, Enum.TextXAlignment.Left, 3)

local netRow = button(ccWifi, 30, 194, 540, 68, ROW, 0, 3)
corner(netRow, UDim.new(0, 24))
drawWifi(netRow, 46, 46, 0.55, WHITE, 5)
label(netRow, WIFI_NAME, 82, 0, 260, 68, 26, WHITE, Enum.Font.GothamMedium, Enum.TextXAlignment.Left, 4)
local netStatus = label(netRow, "", 320, 0, 200, 68, 20, GRAY, Enum.Font.GothamMedium, Enum.TextXAlignment.Right, 4)

local netInfo = label(ccWifi, "Turn on Wi-Fi to see networks", 30, 194, 540, 68, 22, GRAY, Enum.Font.GothamMedium, nil, 3)

local statusWifi = {}

refreshWifi = function()
	TweenService:Create(swTrack, TweenInfo.new(0.2), { BackgroundColor3 = wifiOn and GREEN or Color3.fromRGB(86, 86, 100) }):Play()
	TweenService:Create(swKnob, TweenInfo.new(0.2), { Position = wifiOn and UDim2.fromOffset(88 - 46, 4) or UDim2.fromOffset(4, 4) }):Play()

	local showList = wifiOn and wifiState ~= "scanning"
	netHeader.Visible = showList
	netRow.Visible = showList
	netInfo.Visible = not showList
	netInfo.Text = wifiOn and "Searching..." or "Turn on Wi-Fi to see networks"

	if wifiState == "connecting" then
		netStatus.Text = "Connecting..."
		netStatus.TextColor3 = GRAY
	elseif wifiState == "connected" then
		netStatus.Text = "Connected"
		netStatus.TextColor3 = BLUE
	else
		netStatus.Text = ""
	end

	setToggle(wifiTile, nil, wifiOn, BLUE)
	if wifiState == "connected" then
		wifiLab.Text = WIFI_NAME
	elseif wifiOn then
		wifiLab.Text = "Not Connected"
	else
		wifiLab.Text = "Wi-Fi"
	end

	for _, p in ipairs(statusWifi) do
		p.BackgroundTransparency = wifiState == "connected" and 0 or 0.7
	end

	refreshStoreStatus()
end

local wifiToken = 0
local function setWifi(on)
	wifiToken = wifiToken + 1
	local my = wifiToken
	wifiOn = on
	if on then
		wifiState = "scanning"
		refreshWifi()
		task.delay(1.2, function()
			if wifiToken == my and wifiOn then
				wifiState = "idle"
				refreshWifi()
			end
		end)
	else
		wifiState = "off"
		refreshWifi()
	end
end

local function tapNetwork()
	if wifiState == "idle" then
		wifiToken = wifiToken + 1
		local my = wifiToken
		wifiState = "connecting"
		refreshWifi()
		task.delay(1.6, function()
			if wifiToken == my and wifiOn then
				wifiState = "connected"
				refreshWifi()
			end
		end)
	elseif wifiState == "connected" then
		wifiToken = wifiToken + 1
		wifiState = "idle"
		refreshWifi()
	end
end

showWifiView = function(v)
	wifiView = v
	ccMain.Visible = not v
	ccWifi.Visible = v
end

wifiTile.Activated:Connect(function() showWifiView(true) end)
wBack.Activated:Connect(function() showWifiView(false) end)
swRow.Activated:Connect(function() setWifi(not wifiOn) end)
netRow.Activated:Connect(function() tapNetwork() end)

btTile.Activated:Connect(function()
	btOn = not btOn
	setToggle(btTile, nil, btOn, BLUE)
end)

local statusZone = ui("Frame", {
	Name = "StatusZone",
	Size = UDim2.fromOffset(250, 48),
	Position = UDim2.fromOffset(SW - 250, 0),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	Active = true,
	ZIndex = 5,
}, scr)

statusZone.InputBegan:Connect(function(input)
	if not isPress(input) then return end
	if ccTarget ~= 0 then return end
	pulse()
	local startY, startT = input.Position.Y, os.clock()
	local started = beginDrag(input, function(pos)
		ccP = math.clamp((pos.Y - startY) / fit.Scale / 240, 0, 1)
	end, function()
		ccDragging = false
		local dt = math.max(os.clock() - startT, 0.05)
		local speed = ccP * 240 / dt
		if ccP > 0.4 or (speed > 700 and ccP > 0.08) then
			ccTarget = 1
		else
			ccTarget = 0
		end
	end)
	if started then
		ccDragging = true
	end
end)

local status = ui("Frame", {
	Name = "StatusBar",
	Size = UDim2.fromOffset(SW, 48),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	ZIndex = 6,
}, scr)

local dndLabel = label(status, "Do Not Disturb", 24, 9, 220, 26, 18, WHITE, Enum.Font.GothamMedium, Enum.TextXAlignment.Left, 7)
dndLabel.Visible = false

local statusTime = label(status, "", SW / 2 - 60, 8, 120, 28, 19, WHITE, Enum.Font.GothamBold, nil, 7)

for _, p in ipairs(drawWifi(status, SW - 176, 32, 0.5, WHITE, 7)) do
	p.BackgroundTransparency = 0.7
	table.insert(statusWifi, p)
end

label(status, "100%", SW - 150, 9, 64, 26, 18, WHITE, Enum.Font.GothamMedium, Enum.TextXAlignment.Right, 7)

local battOutline = ui("Frame", {
	Size = UDim2.fromOffset(46, 24),
	Position = UDim2.fromOffset(SW - 76, 10),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	ZIndex = 7,
}, status)
corner(battOutline, UDim.new(0, 7))
ui("UIStroke", { Color = WHITE, Thickness = 2.5, Transparency = 0.2 }, battOutline)
local battFill = ui("Frame", {
	Size = UDim2.fromOffset(38, 16),
	Position = UDim2.fromOffset(SW - 76 + 4, 10 + 4),
	BackgroundColor3 = WHITE,
	BorderSizePixel = 0,
	ZIndex = 8,
}, status)
corner(battFill, UDim.new(0, 4))
local battNub = ui("Frame", {
	Size = UDim2.fromOffset(4, 10),
	Position = UDim2.fromOffset(SW - 29, 17),
	BackgroundColor3 = WHITE,
	BackgroundTransparency = 0.2,
	BorderSizePixel = 0,
	ZIndex = 7,
}, status)
corner(battNub, UDim.new(0, 2))

task.spawn(function()
	while alive do
		local t = os.date("%H:%M")
		timeLabel.Text = t
		statusTime.Text = t
		dateLabel.Text = os.date("%A, %B %d")
		task.wait(1)
	end
end)

local volHud = ui("Frame", {
	Name = "VolumeHud",
	Size = UDim2.fromOffset(280, 56),
	Position = UDim2.fromOffset((SW - 280) / 2, 56),
	BackgroundColor3 = Color3.fromRGB(34, 34, 44),
	BackgroundTransparency = 0.08,
	BorderSizePixel = 0,
	Visible = false,
	ZIndex = 7,
}, scr)
corner(volHud, UDim.new(1, 0))
ui("UIStroke", { Color = WHITE, Thickness = 1.5, Transparency = 0.85 }, volHud)
drawSpeaker(volHud, 40, 28, 0.8, WHITE, 8)
local hudTrack = ui("Frame", {
	Size = UDim2.fromOffset(170, 10),
	Position = UDim2.fromOffset(76, 23),
	BackgroundColor3 = Color3.fromRGB(90, 90, 104),
	BorderSizePixel = 0,
	ZIndex = 8,
}, volHud)
corner(hudTrack, UDim.new(1, 0))
local hudFill = ui("Frame", {
	Size = UDim2.fromScale(0.5, 1),
	BackgroundColor3 = WHITE,
	BorderSizePixel = 0,
	ZIndex = 9,
}, hudTrack)
corner(hudFill, UDim.new(1, 0))

local hudToken = 0
showVolHud = function()
	hudFill.Size = UDim2.fromScale(volV, 1)
	volHud.Visible = true
	hudToken = hudToken + 1
	local my = hudToken
	task.delay(1.4, function()
		if hudToken == my then
			volHud.Visible = false
		end
	end)
end

dim = ui("Frame", {
	Name = "BrightnessDim",
	Size = UDim2.fromScale(1, 1),
	BackgroundColor3 = BLACK,
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	ZIndex = 8,
}, scr)
warm = ui("Frame", {
	Name = "EyeProtection",
	Size = UDim2.fromScale(1, 1),
	BackgroundColor3 = Color3.fromRGB(255, 160, 40),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	ZIndex = 9,
}, scr)
setBrightness(brightV)

dndTile.Activated:Connect(function()
	dndOn = not dndOn
	setToggle(dndTile, dndCarve, dndOn, PURPLE)
	dndLabel.Visible = dndOn
end)
eyeTile.Activated:Connect(function()
	eyeOn = not eyeOn
	setToggle(eyeTile, nil, eyeOn, ORANGE)
	TweenService:Create(warm, TweenInfo.new(0.3), { BackgroundTransparency = eyeOn and 0.86 or 1 }):Play()
end)

local function setCC(p)
	ccRoot.Visible = p > 0.002
	frost.BackgroundTransparency = 1 - (appOpen and 0.8 or 0.5) * p
	local closedY = -PANEL_H - 30
	panel.Position = UDim2.fromOffset(PANEL_X, closedY + (PANEL_Y - closedY) * p)
	homeContent.GroupTransparency = p
	lockContent.GroupTransparency = p
	for _, sc in ipairs(blobScales) do
		sc.Scale = 1 + 0.4 * p
	end
	statusZone.Visible = (p < 0.02 and ccTarget == 0)
end
refreshWifi()
setCC(0)

local btnColor = Color3.fromRGB(96, 96, 104)

local powerBar = ui("Frame", {
	Size = UDim2.fromOffset(100, 11),
	Position = UDim2.fromOffset(700, -8),
	BackgroundColor3 = btnColor,
	BorderSizePixel = 0,
	ZIndex = 1,
}, ipad)
corner(powerBar, UDim.new(0, 4))
local powerHit = button(ipad, 680, -30, 140, 48, WHITE, 1, 6)

local volUpBar = ui("Frame", {
	Size = UDim2.fromOffset(11, 56),
	Position = UDim2.fromOffset(DW - 3, 130),
	BackgroundColor3 = btnColor,
	BorderSizePixel = 0,
	ZIndex = 1,
}, ipad)
corner(volUpBar, UDim.new(0, 4))
local volDownBar = ui("Frame", {
	Size = UDim2.fromOffset(11, 56),
	Position = UDim2.fromOffset(DW - 3, 210),
	BackgroundColor3 = btnColor,
	BorderSizePixel = 0,
	ZIndex = 1,
}, ipad)
corner(volDownBar, UDim.new(0, 4))
local volUpHit = button(ipad, DW - 24, 116, 52, 76, WHITE, 1, 6)
local volDownHit = button(ipad, DW - 24, 196, 52, 76, WHITE, 1, 6)

local homeBtn = button(ipad, DW - 72, DH / 2 - 29, 58, 58, Color3.fromRGB(6, 6, 8), 0, 5)
corner(homeBtn, UDim.new(1, 0))
ui("UIStroke", { Color = Color3.fromRGB(88, 88, 96), Thickness = 3 }, homeBtn)
local homeInner = ui("Frame", {
	Size = UDim2.fromOffset(20, 20),
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	ZIndex = 6,
}, homeBtn)
corner(homeInner, UDim.new(0, 5))
ui("UIStroke", { Color = Color3.fromRGB(62, 62, 70), Thickness = 2 }, homeInner)

homeBtn.Activated:Connect(function()
	if ccTarget == 1 then
		ccTarget = 0
	elseif appOpen then
		closeApp(false)
	end
end)

local function nudge(barFrame, dx, dy)
	local p0 = barFrame.Position
	barFrame.Position = UDim2.new(p0.X.Scale, p0.X.Offset + dx, p0.Y.Scale, p0.Y.Offset + dy)
	task.delay(0.12, function()
		barFrame.Position = p0
	end)
end

local holdToken = 0
local function bindVolume(hit, barFrame, delta)
	hit.InputBegan:Connect(function(input)
		if not isPress(input) then return end
		holdToken = holdToken + 1
		local my = holdToken
		local function step()
			setVolume(volV + delta)
			showVolHud()
			nudge(barFrame, -4, 0)
		end
		step()
		task.spawn(function()
			task.wait(0.4)
			while holdToken == my and alive and isOpen do
				step()
				task.wait(0.12)
			end
		end)
	end)
end
bindVolume(volUpHit, volUpBar, VOL_STEP)
bindVolume(volDownHit, volDownBar, -VOL_STEP)
conns[#conns + 1] = UIS.InputEnded:Connect(function(input)
	if isPress(input) then
		holdToken = holdToken + 1
	end
end)

powerHit.Activated:Connect(function()
	nudge(powerBar, 0, 4)
	closeIPad()
end)

local openToken = 0

showIPad = function()
	if isOpen then return end
	isOpen = true
	openToken = openToken + 1
	refit()
	holder.Visible = true
	root.Position = UDim2.fromScale(0.5, 1.6)
	TweenService:Create(root, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Position = UDim2.fromScale(0.5, 0.5) }):Play()
end

hideIPad = function()
	if not isOpen then return end
	isOpen = false
	openToken = openToken + 1
	local my = openToken
	ccTarget, ccP, ccDragging = 0, 0, false
	setCC(0)
	ccDrawn = 0
	showWifiView(false)
	closeApp(true)
	if RELOCK_ON_CLOSE then
		locked = true
		if slideTween then slideTween:Cancel() end
		lock.Visible = true
		lock.Position = UDim2.fromOffset(0, 0)
	end
	local tw = TweenService:Create(root, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Position = UDim2.fromScale(0.5, 1.6) })
	tw.Completed:Connect(function()
		if openToken == my then
			holder.Visible = false
		end
	end)
	tw:Play()
end

closeIPad = function()
	local bp = player:FindFirstChildOfClass("Backpack")
	if tool and bp and tool.Parent ~= bp then
		tool.Parent = bp
	end
	hideIPad()
end

conns[#conns + 1] = RunService.RenderStepped:Connect(function(dt)
	if not alive or not isOpen then return end
	dt = math.min(dt, 1 / 30)

	if not ccDragging then
		ccP = ccP + (ccTarget - ccP) * math.min(1, dt * 14)
		if math.abs(ccTarget - ccP) < 0.003 then
			ccP = ccTarget
		end
	end
	if ccP ~= ccDrawn then
		ccDrawn = ccP
		setCC(ccP)
	end
	if ccP == 0 and wifiView then
		showWifiView(false)
	end

	if appOpen == "flappy" and ccP < 0.01 then
		flappyUpdate(dt)
	end
end)

conns[#conns + 1] = RunService.Heartbeat:Connect(function(dt)
	if not alive then return end
	for _, app in ipairs(APPS) do
		local st = installState[app.id]
		if st and st.state == "downloading" then
			if wifiState == "connected" then
				st.p = math.min(1, st.p + dt / app.time)
			end
			local e = homeEntries[app.id]
			if e then
				e.fill.Size = UDim2.fromScale(st.p, 1)
			end
			if st.p >= 1 then
				finishInstall(app)
			else
				refreshRow(app)
			end
		end
	end
end)

local function onToolParent()
	if not alive or not tool then return end
	local char = player.Character
	if char and tool.Parent == char then
		showIPad()
	else
		hideIPad()
	end
end

local function makeTool()
	if tool then
		local oldTool = tool
		tool = nil
		pcall(function()
			oldTool:Destroy()
		end)
	end
	local t = Instance.new("Tool")
	t.Name = "iPad"
	t.ToolTip = "iPad"
	t.RequiresHandle = false
	t.CanBeDropped = false
	t:SetAttribute("IPad3D_Tool", true)
	tool = t
	t:GetPropertyChangedSignal("Parent"):Connect(onToolParent)
	t.Parent = player:WaitForChild("Backpack")
end

conns[#conns + 1] = player.CharacterAdded:Connect(function()
	hideIPad()
	task.wait(1)
	if alive then
		makeTool()
	end
end)

task.spawn(makeTool)

gui.Destroying:Connect(function()
	alive = false
	for _, c in ipairs(conns) do
		c:Disconnect()
	end
	if tool then
		pcall(function()
			tool:Destroy()
		end)
	end
end)
