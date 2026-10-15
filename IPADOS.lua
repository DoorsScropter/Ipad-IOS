--[[
	iPad (first person) - Roblox Delta LocalScript  (v4)
	- Real 3D iPad in workspace (rounded corners, bezel, camera, side buttons), both hands hold it
	- Swipe up to unlock
	- Apps: App Store, Settings, Notes (works), Podcasts (demo), Reminders (works)
	- Settings: Airplane Mode, Wi-Fi (off by default, some networks need a password), Bluetooth,
	  Siri (on/off, hold-home-bar, voice, "Try Siri"), Display & Brightness, Sounds (volume), General
	- App Store needs Wi-Fi. GET installs demo apps onto the home screen
	- Tap the Wi-Fi icon in the status bar = jump to Settings > Wi-Fi
	- SWIPE DOWN from the top-right (start on the Wi-Fi / battery icons) = Control Center
	  (airplane, AirDrop, Wi-Fi, Bluetooth, music, brightness + volume sliders, silent, torch ...)
	  The flashlight tile is a REAL light: a beam in front of you + a soft glow (only you see it)
	- Swipe up from the bottom (or tap "Home" at the top) to leave an app
	- Hold the bottom home bar ~0.6s = Siri (if Siri + "Hold Home Bar" are on in Settings)
	- Side buttons (right edge): upper = volume up, lower = volume down
	- Top button = screen off / on (black screen like a real power button)
	- Small "iPad" button (top right) = put the iPad away / pull it out
	PC: hold Left Ctrl to free the mouse and click.

	WI-FI PASSWORDS:  Home_5G = 12345678 | NeighborNet = password123 | Library_WiFi = readbooks
	(CoffeeShop_Free and Roblox_Guest are open)
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CAS = game:GetService("ContextActionService")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- remove an older copy if you execute twice
local env = (getgenv and getgenv()) or _G
if env.__DeltaIPadCleanup then pcall(env.__DeltaIPadCleanup) end

---------------------------------------------------------------- constants
local WHITE = Color3.new(1, 1, 1)
local BG = Color3.fromRGB(26, 26, 34)
local CARD = Color3.fromRGB(46, 46, 58)
local GRAY = Color3.fromRGB(150, 150, 165)
local BLUE = Color3.fromRGB(10, 132, 255)
local GREEN = Color3.fromRGB(52, 199, 89)
local FULL = UDim.new(1, 0)

local SW, SH, M = 2.66, 1.862, 0.17          -- screen size + bezel margin (studs)
local W, H, T, R = SW + 2 * M, SH + 2 * M, 0.11, 0.26
local CW, CH = 1000, 700                     -- screen canvas (pixels)
local HOLD = CFrame.new(0, -0.15, -2.3) * CFrame.Angles(math.rad(-12), 0, 0)
local K, C = 220, 11                         -- spring stiffness / damping (bounce feel)
local SP = Enum.Material.SmoothPlastic
local CYL, BALL = Enum.PartType.Cylinder, Enum.PartType.Ball

local conns = {}
local shown = true

---------------------------------------------------------------- 3D model
local model = Instance.new("Model")
model.Name = "DeltaIPad"

local function mk(size, cf, color, mat, shape)
	local p = Instance.new("Part")
	p.Anchored = true
	p.CanCollide = false
	p.CanQuery = false
	p.CanTouch = false
	p.CastShadow = false
	p.Size = size
	p.CFrame = cf
	p.Color = color
	p.Material = mat or SP
	if shape then p.Shape = shape end
	p.Parent = model
	return p
end

-- rounded rectangle slab (smooth corners made from cylinders)
local function roundedBox(w, h, d, r, center, color, mat)
	mk(Vector3.new(w - 2 * r, h, d), CFrame.new(center), color, mat)
	mk(Vector3.new(w, h - 2 * r, d - 0.002), CFrame.new(center), color, mat)
	for _, sx in ipairs({ -1, 1 }) do
		for _, sy in ipairs({ -1, 1 }) do
			mk(
				Vector3.new(d - 0.004, 2 * r, 2 * r),
				CFrame.new(center + Vector3.new(sx * (w / 2 - r), sy * (h / 2 - r), 0)) * CFrame.Angles(0, math.pi / 2, 0),
				color, mat, CYL
			)
		end
	end
end

local silver = Color3.fromRGB(196, 198, 204)
roundedBox(W, H, T, R, Vector3.zero, silver, Enum.Material.Metal)               -- aluminium body (first part = pivot)
model.PrimaryPart = model:FindFirstChildWhichIsA("BasePart")
roundedBox(W - 0.05, H - 0.05, 0.012, R - 0.03, Vector3.new(0, 0, T / 2 + 0.004), Color3.fromRGB(8, 8, 10), SP) -- black bezel

local screen = mk(Vector3.new(SW, SH, 0.006), CFrame.new(0, 0, T / 2 + 0.0135), Color3.new(0, 0, 0), SP)
screen.Name = "Screen"

-- front camera
mk(Vector3.new(0.004, 0.045, 0.045), CFrame.new(0, H / 2 - M / 2, T / 2 + 0.0125) * CFrame.Angles(0, math.pi / 2, 0), Color3.fromRGB(25, 28, 40), Enum.Material.Glass, CYL)

-- clickable side buttons
local btnCol = Color3.fromRGB(214, 216, 222)
local powerPart = mk(Vector3.new(0.3, 0.06, 0.06), CFrame.new(W / 2 - 0.55, H / 2 + 0.012, 0), btnCol, Enum.Material.Metal)
local volUpPart = mk(Vector3.new(0.06, 0.2, 0.06), CFrame.new(W / 2 + 0.012, H / 2 - 0.55, 0), btnCol, Enum.Material.Metal)
local volDownPart = mk(Vector3.new(0.06, 0.2, 0.06), CFrame.new(W / 2 + 0.012, H / 2 - 0.85, 0), btnCol, Enum.Material.Metal)

local SIDE_BTNS = {
	{ name = "power", center = Vector3.new(W / 2 - 0.55, H / 2 + 0.012, 0), size = Vector3.new(0.3, 0.06, 0.06) },
	{ name = "volup", center = Vector3.new(W / 2 + 0.012, H / 2 - 0.55, 0), size = Vector3.new(0.06, 0.2, 0.06) },
	{ name = "voldown", center = Vector3.new(W / 2 + 0.012, H / 2 - 0.85, 0), size = Vector3.new(0.06, 0.2, 0.06) },
}

---------------------------------------------------------------- hands
local skin = Color3.fromRGB(234, 184, 146)
pcall(function()
	local hd = player.Character and player.Character:FindFirstChild("Head")
	if hd and hd:IsA("BasePart") then skin = hd.Color end
end)
local sleeve = Color3.fromRGB(44, 48, 62)

local function limb(a, b, th, color, mat, caps)
	local mid = (a + b) / 2
	local len = (b - a).Magnitude
	mk(Vector3.new(len, th, th), CFrame.lookAt(mid, b) * CFrame.Angles(0, math.pi / 2, 0), color, mat, CYL)
	if caps then
		mk(Vector3.new(th, th, th), CFrame.new(a), color, mat, BALL)
		mk(Vector3.new(th, th, th), CFrame.new(b), color, mat, BALL)
	end
end

local function buildHand(s) -- s = -1 left, +1 right
	local x = W / 2
	-- thumb wraps over the front bezel
	local A = Vector3.new(s * (x + 0.05), -0.62, 0.15)
	local B = Vector3.new(s * (x - 0.17), -0.5, T / 2 + 0.12)
	local Cc = Vector3.new(s * (x - 0.6), -0.43, T / 2 + 0.125)
	limb(A, B, 0.2, skin, SP, true)
	limb(B, Cc, 0.19, skin, SP, true)
	mk(Vector3.new(0.13, 0.1, 0.012), CFrame.new(Cc.X - s * 0.02, Cc.Y, Cc.Z + 0.098), Color3.fromRGB(245, 225, 215), SP)
	-- palm gripping the back edge
	mk(Vector3.new(0.95, 0.52, 0.52), CFrame.new(s * (x + 0.29), -0.12, -0.18) * CFrame.Angles(0, 0, math.pi / 2), skin, SP, CYL)
	-- forearm + sleeve going down out of view
	local p0 = Vector3.new(s * (x + 0.32), -0.55, -0.15)
	local p1 = Vector3.new(s * (x + 0.9), -2.1, 0.95)
	mk(Vector3.new(0.46, 0.46, 0.46), CFrame.new(p0), skin, SP, BALL)
	limb(p0, p1, 0.44, skin, SP, false)
	limb(p0:Lerp(p1, 0.42), p1 + (p1 - p0) * 0.2, 0.58, sleeve, Enum.Material.Fabric, false)
end
buildHand(-1)
buildHand(1)

---------------------------------------------------------------- flashlight (real light aimed where you look)
local torchPart = Instance.new("Part")
torchPart.Name = "DeltaIPadTorch"
torchPart.Anchored = true
torchPart.CanCollide = false
torchPart.CanQuery = false
torchPart.CanTouch = false
torchPart.CastShadow = false
torchPart.Transparency = 1
torchPart.Size = Vector3.new(0.2, 0.2, 0.2)
torchPart.Parent = workspace

local torchBeam = Instance.new("SpotLight")
torchBeam.Face = Enum.NormalId.Front          -- front = the way the camera looks
torchBeam.Brightness = 4
torchBeam.Range = 70
torchBeam.Angle = 65
torchBeam.Shadows = true
torchBeam.Color = Color3.fromRGB(255, 244, 225)
torchBeam.Enabled = false
torchBeam.Parent = torchPart

local torchGlow = Instance.new("PointLight")   -- soft glow right around you
torchGlow.Brightness = 0.8
torchGlow.Range = 14
torchGlow.Color = Color3.fromRGB(255, 244, 225)
torchGlow.Enabled = false
torchGlow.Parent = torchPart

local function setTorch(on)
	torchBeam.Enabled = on
	torchGlow.Enabled = on
end

---------------------------------------------------------------- screen UI helpers
local gui = Instance.new("SurfaceGui")
gui.Face = Enum.NormalId.Back
gui.SizingMode = Enum.SurfaceGuiSizingMode.FixedSize
gui.CanvasSize = Vector2.new(CW, CH)
gui.LightInfluence = 0
gui.Brightness = 1.15
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = screen

local function px(n) return UDim.new(0, n) end

local function frame(parent, x, y, w, h, color, tr, corner)
	local f = Instance.new("Frame")
	f.BorderSizePixel = 0
	f.Position = UDim2.fromOffset(x, y)
	f.Size = UDim2.fromOffset(w, h)
	f.BackgroundColor3 = color or WHITE
	f.BackgroundTransparency = tr or 0
	if corner then
		local c = Instance.new("UICorner")
		c.CornerRadius = corner
		c.Parent = f
	end
	f.Parent = parent
	return f
end

local function label(parent, text, x, y, w, h, size, color, font, align)
	local l = Instance.new("TextLabel")
	l.BackgroundTransparency = 1
	l.Position = UDim2.fromOffset(x, y)
	l.Size = UDim2.fromOffset(w, h)
	l.Text = text
	l.TextSize = size
	l.TextColor3 = color or WHITE
	l.Font = font or Enum.Font.GothamMedium
	l.TextXAlignment = align or Enum.TextXAlignment.Center
	l.TextYAlignment = Enum.TextYAlignment.Center
	l.TextTruncate = Enum.TextTruncate.AtEnd
	l.Parent = parent
	return l
end

local function stroke(parent, color, thickness, tr)
	local s = Instance.new("UIStroke")
	s.Color = color
	s.Thickness = thickness
	s.Transparency = tr or 0
	s.Parent = parent
	return s
end

local function gradient(parent, c1, c2, rot)
	local g = Instance.new("UIGradient")
	g.Color = ColorSequence.new(c1, c2)
	g.Rotation = rot or 90
	g.Parent = parent
	return g
end

local function tw(obj, t, props, style, dir)
	TweenService:Create(obj, TweenInfo.new(t, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out), props):Play()
end

local function inRect(x, y, rx, ry, rw, rh)
	return x >= rx and x <= rx + rw and y >= ry and y <= ry + rh
end

local function esc(s)
	return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

local function drawToggle(parent, x, y, on)
	local t = frame(parent, x, y, 64, 36, on and GREEN or Color3.fromRGB(80, 80, 92), 0, FULL)
	frame(t, on and 30 or 2, 2, 32, 32, WHITE, 0, FULL)
end

local function drawSlider(parent, x, y, w, frac)
	local track = frame(parent, x, y, w, 12, Color3.fromRGB(70, 70, 84), 0, FULL)
	local fill = frame(track, 0, 0, w * frac, 12, BLUE, 0, FULL)
	local knob = frame(parent, x + w * frac - 16, y - 10, 32, 32, WHITE, 0, FULL)
	return { fill = fill, knob = knob, x = x, y = y, w = w }
end

local function setSlider(sl, frac)
	if not sl then return end
	sl.fill.Size = UDim2.fromOffset(sl.w * frac, 12)
	sl.knob.Position = UDim2.fromOffset(sl.x + sl.w * frac - 16, sl.y - 10)
end

---------------------------------------------------------------- icon + glyph library (drawn from shapes, no emoji)
local function shape(parent, s, cx, cy, w, h, color, rot, round, tr)
	local f = Instance.new("Frame")
	f.BorderSizePixel = 0
	f.AnchorPoint = Vector2.new(0.5, 0.5)
	f.Position = UDim2.fromOffset(cx * s, cy * s)
	f.Size = UDim2.fromOffset(math.max(1, w * s), math.max(1, h * s))
	f.BackgroundColor3 = color
	f.BackgroundTransparency = tr or 0
	f.Rotation = rot or 0
	if round then
		local c = Instance.new("UICorner")
		c.CornerRadius = UDim.new(round, 0)
		c.Parent = f
	end
	f.Parent = parent
	return f
end

local function ringShape(parent, s, cx, cy, d, thick, color, tr)
	local f = shape(parent, s, cx, cy, d, d, color, 0, 0.5, 1)
	stroke(f, color, math.max(1, thick * s), tr)
	return f
end

local function triShape(parent, s, dir, x, y, h, color)
	local hh, ww = h * s, h * s / 2
	local clip = Instance.new("Frame")
	clip.BackgroundTransparency = 1
	clip.BorderSizePixel = 0
	clip.ClipsDescendants = true
	clip.Position = UDim2.fromOffset(x * s, y * s)
	clip.Size = UDim2.fromOffset(ww, hh)
	clip.Parent = parent
	local d = hh / math.sqrt(2)
	local dia = Instance.new("Frame")
	dia.BorderSizePixel = 0
	dia.AnchorPoint = Vector2.new(0.5, 0.5)
	dia.Position = UDim2.fromOffset(dir == "r" and 0 or ww, hh / 2)
	dia.Size = UDim2.fromOffset(d, d)
	dia.Rotation = 45
	dia.BackgroundColor3 = color
	dia.Parent = clip
	return clip
end

local function stopsGradient(parent, stops, rot)
	local kps = {}
	for _, st in ipairs(stops) do
		table.insert(kps, ColorSequenceKeypoint.new(st[1], st[2]))
	end
	local g = Instance.new("UIGradient")
	g.Color = ColorSequence.new(kps)
	g.Rotation = rot or 90
	g.Parent = parent
	return g
end

local function drawGear(h, s, c, bg)
	for _, r in ipairs({ 0, 45, 90, 135 }) do
		shape(h, s, 0.5, 0.5, 0.15, 0.82, c, r, 0.2)
	end
	shape(h, s, 0.5, 0.5, 0.62, 0.62, c, 0, 0.5)
	shape(h, s, 0.5, 0.5, 0.34, 0.34, bg, 0, 0.5)
end

local GLYPH = {}

GLYPH.airplane = function(h, s, c)
	shape(h, s, 0.5, 0.5, 0.8, 0.12, c, -45, 0.5)
	shape(h, s, 0.56, 0.44, 0.62, 0.12, c, 45, 0.5)
	shape(h, s, 0.29, 0.71, 0.26, 0.1, c, 45, 0.5)
end
GLYPH.airdrop = function(h, s, c)
	ringShape(h, s, 0.5, 0.5, 0.84, 0.07, c)
	ringShape(h, s, 0.5, 0.5, 0.56, 0.07, c)
	shape(h, s, 0.5, 0.5, 0.2, 0.2, c, 0, 0.5)
end
GLYPH.wifi = function(h, s, c)
	for i = 1, 3 do
		local bh = 0.22 + (i - 1) * 0.22
		shape(h, s, 0.22 + (i - 1) * 0.28, 0.82 - bh / 2, 0.18, bh, c, 0, 0.3)
	end
end
GLYPH.bluetooth = function(h, s, c)
	shape(h, s, 0.5, 0.5, 0.1, 0.8, c, 0, 0.5)
	shape(h, s, 0.62, 0.23, 0.34, 0.09, c, 42, 0.5)
	shape(h, s, 0.62, 0.77, 0.34, 0.09, c, -42, 0.5)
	shape(h, s, 0.51, 0.5, 0.64, 0.09, c, -38, 0.5)
	shape(h, s, 0.51, 0.5, 0.64, 0.09, c, 38, 0.5)
end
GLYPH.rotlock = function(h, s, c)
	ringShape(h, s, 0.5, 0.5, 0.82, 0.07, c)
	shape(h, s, 0.5, 0.56, 0.26, 0.2, c, 0, 0.15)
	ringShape(h, s, 0.5, 0.42, 0.16, 0.045, c)
end
GLYPH.moon = function(h, s, c, bg)
	shape(h, s, 0.48, 0.5, 0.62, 0.62, c, 0, 0.5)
	shape(h, s, 0.64, 0.4, 0.52, 0.52, bg, 0, 0.5)
end
GLYPH.mirror = function(h, s, c, bg)
	local a = shape(h, s, 0.4, 0.44, 0.56, 0.4, bg, 0, 0.12)
	stroke(a, c, math.max(1.5, 0.06 * s))
	local b = shape(h, s, 0.6, 0.58, 0.56, 0.4, bg, 0, 0.12)
	stroke(b, c, math.max(1.5, 0.06 * s))
end
GLYPH.bell = function(h, s, c)
	shape(h, s, 0.5, 0.4, 0.46, 0.46, c, 0, 0.5)
	shape(h, s, 0.5, 0.58, 0.46, 0.28, c, 0, 0.1)
	shape(h, s, 0.5, 0.7, 0.66, 0.1, c, 0, 0.5)
	shape(h, s, 0.5, 0.82, 0.16, 0.1, c, 0, 0.5)
end
GLYPH.torch = function(h, s, c, bg)
	shape(h, s, 0.5, 0.2, 0.36, 0.14, c, 0, 0.25)
	shape(h, s, 0.5, 0.32, 0.22, 0.1, c, 0, 0.2)
	shape(h, s, 0.5, 0.62, 0.26, 0.5, c, 0, 0.3)
	shape(h, s, 0.5, 0.52, 0.08, 0.14, bg, 0, 0.5)
end
GLYPH.timer = function(h, s, c)
	ringShape(h, s, 0.5, 0.52, 0.78, 0.07, c)
	shape(h, s, 0.5, 0.4, 0.07, 0.24, c, 0, 0.5)
	shape(h, s, 0.5, 0.52, 0.12, 0.12, c, 0, 0.5)
	shape(h, s, 0.5, 0.07, 0.16, 0.06, c, 0, 0.4)
end
GLYPH.stopwatch = function(h, s, c)
	ringShape(h, s, 0.5, 0.56, 0.72, 0.07, c)
	shape(h, s, 0.5, 0.1, 0.16, 0.07, c, 0, 0.4)
	shape(h, s, 0.78, 0.2, 0.12, 0.06, c, 45, 0.4)
	shape(h, s, 0.58, 0.47, 0.07, 0.26, c, 35, 0.5)
	shape(h, s, 0.5, 0.56, 0.1, 0.1, c, 0, 0.5)
end
GLYPH.camera = function(h, s, c, bg)
	shape(h, s, 0.5, 0.58, 0.82, 0.54, c, 0, 0.2)
	shape(h, s, 0.5, 0.28, 0.34, 0.14, c, 0, 0.4)
	shape(h, s, 0.5, 0.58, 0.36, 0.36, bg, 0, 0.5)
	shape(h, s, 0.5, 0.58, 0.2, 0.2, c, 0, 0.5)
end
GLYPH.record = function(h, s, c)
	ringShape(h, s, 0.5, 0.5, 0.8, 0.07, c)
	shape(h, s, 0.5, 0.5, 0.4, 0.4, c, 0, 0.5)
end
GLYPH.sun = function(h, s, c)
	shape(h, s, 0.5, 0.5, 0.34, 0.34, c, 0, 0.5)
	for i = 0, 7 do
		local a = math.rad(i * 45)
		shape(h, s, 0.5 + 0.38 * math.cos(a), 0.5 + 0.38 * math.sin(a), 0.1, 0.1, c, 0, 0.5)
	end
end
GLYPH.speaker = function(h, s, c)
	shape(h, s, 0.3, 0.5, 0.16, 0.24, c, 0, 0.15)
	triShape(h, s, "l", 0.34, 0.26, 0.48, c)
end
GLYPH.gear = function(h, s, c, bg)
	drawGear(h, s, c, bg)
end
GLYPH.siri = function(h, s, c)
	local hs = { 0.3, 0.55, 0.8, 0.55, 0.3 }
	for i, hh in ipairs(hs) do
		shape(h, s, 0.14 + (i - 1) * 0.18, 0.5, 0.1, hh, c, 0, 0.5)
	end
end
GLYPH.lock = function(h, s, c)
	shape(h, s, 0.5, 0.6, 0.64, 0.46, c, 0, 0.18)
	ringShape(h, s, 0.5, 0.32, 0.38, 0.1, c)
end

local function glyph(parent, name, cx, cy, size, color, bg)
	local h = Instance.new("Frame")
	h.BackgroundTransparency = 1
	h.BorderSizePixel = 0
	h.AnchorPoint = Vector2.new(0.5, 0.5)
	h.Position = UDim2.fromOffset(cx, cy)
	h.Size = UDim2.fromOffset(size, size)
	h.Parent = parent
	local fn = GLYPH[name]
	if fn then fn(h, size, color or WHITE, bg or BG) end
	return h
end

local ICONS = {}

ICONS.appstore = {
	c1 = Color3.fromRGB(88, 196, 255), c2 = Color3.fromRGB(10, 100, 240),
	draw = function(ic, s)
		shape(ic, s, 0.4, 0.47, 0.1, 0.64, WHITE, 20, 0.5)
		shape(ic, s, 0.6, 0.47, 0.1, 0.64, WHITE, -20, 0.5)
		shape(ic, s, 0.5, 0.6, 0.34, 0.08, WHITE, 0, 0.5)
		shape(ic, s, 0.3, 0.78, 0.18, 0.08, WHITE, 0, 0.5)
		shape(ic, s, 0.7, 0.78, 0.18, 0.08, WHITE, 0, 0.5)
	end,
}
ICONS.settings = {
	c1 = Color3.fromRGB(205, 205, 212), c2 = Color3.fromRGB(120, 120, 132),
	draw = function(ic, s)
		drawGear(ic, s, Color3.fromRGB(240, 240, 246), Color3.fromRGB(150, 150, 162))
	end,
}
ICONS.notes = {
	c1 = WHITE, c2 = WHITE,
	stops = {
		{ 0, Color3.fromRGB(255, 204, 0) }, { 0.27, Color3.fromRGB(255, 204, 0) },
		{ 0.271, Color3.fromRGB(255, 255, 255) }, { 1, Color3.fromRGB(242, 242, 246) },
	},
	draw = function(ic, s)
		local g = Color3.fromRGB(215, 215, 222)
		shape(ic, s, 0.5, 0.47, 0.72, 0.025, g)
		shape(ic, s, 0.5, 0.6, 0.72, 0.025, g)
		shape(ic, s, 0.5, 0.73, 0.72, 0.025, g)
		shape(ic, s, 0.5, 0.86, 0.72, 0.025, g)
		shape(ic, s, 0.37, 0.36, 0.34, 0.05, Color3.fromRGB(70, 70, 80), 0, 0.5)
	end,
}
ICONS.podcasts = {
	c1 = Color3.fromRGB(212, 120, 255), c2 = Color3.fromRGB(120, 45, 210),
	draw = function(ic, s)
		ringShape(ic, s, 0.5, 0.46, 0.34, 0.05, WHITE)
		ringShape(ic, s, 0.5, 0.46, 0.6, 0.05, WHITE, 0.25)
		ringShape(ic, s, 0.5, 0.46, 0.86, 0.04, WHITE, 0.55)
		shape(ic, s, 0.5, 0.4, 0.14, 0.14, WHITE, 0, 0.5)
		shape(ic, s, 0.5, 0.55, 0.1, 0.22, WHITE, 0, 0.5)
	end,
}
ICONS.reminders = {
	c1 = WHITE, c2 = Color3.fromRGB(236, 236, 242),
	draw = function(ic, s)
		local cols = { Color3.fromRGB(255, 149, 0), Color3.fromRGB(10, 132, 255), Color3.fromRGB(255, 59, 48) }
		for i = 1, 3 do
			local y = 0.22 + (i - 1) * 0.28
			ringShape(ic, s, 0.24, y, 0.15, 0.035, cols[i])
			shape(ic, s, 0.63, y, 0.4, 0.035, Color3.fromRGB(205, 205, 212), 0, 0.5)
		end
	end,
}
ICONS.x_chess = {
	c1 = Color3.fromRGB(110, 115, 130), c2 = Color3.fromRGB(30, 32, 42),
	draw = function(ic, s)
		shape(ic, s, 0.5, 0.31, 0.2, 0.2, WHITE, 0, 0.5)
		shape(ic, s, 0.5, 0.45, 0.28, 0.06, WHITE, 0, 0.5)
		shape(ic, s, 0.5, 0.62, 0.3, 0.3, WHITE, 0, 0.4)
		shape(ic, s, 0.5, 0.79, 0.52, 0.08, WHITE, 0, 0.4)
	end,
}
ICONS.x_weather = {
	c1 = Color3.fromRGB(110, 200, 255), c2 = Color3.fromRGB(30, 110, 230),
	draw = function(ic, s)
		shape(ic, s, 0.64, 0.34, 0.3, 0.3, Color3.fromRGB(255, 214, 10), 0, 0.5)
		shape(ic, s, 0.37, 0.6, 0.28, 0.28, WHITE, 0, 0.5)
		shape(ic, s, 0.55, 0.54, 0.34, 0.34, WHITE, 0, 0.5)
		shape(ic, s, 0.7, 0.62, 0.24, 0.24, WHITE, 0, 0.5)
		shape(ic, s, 0.54, 0.7, 0.5, 0.18, WHITE, 0, 0.5)
	end,
}
ICONS.x_photo = {
	c1 = WHITE, c2 = Color3.fromRGB(235, 235, 240),
	draw = function(ic, s)
		local cols = {
			Color3.fromRGB(255, 120, 60), Color3.fromRGB(255, 200, 40), Color3.fromRGB(90, 210, 90),
			Color3.fromRGB(60, 200, 230), Color3.fromRGB(80, 120, 255), Color3.fromRGB(230, 80, 200),
		}
		for i = 1, 6 do
			local a = math.rad((i - 1) * 60)
			shape(ic, s, 0.5 + 0.17 * math.cos(a), 0.5 + 0.17 * math.sin(a), 0.34, 0.34, cols[i], 0, 0.5, 0.25)
		end
	end,
}
ICONS.x_sketch = {
	c1 = Color3.fromRGB(190, 120, 255), c2 = Color3.fromRGB(100, 60, 220),
	draw = function(ic, s)
		shape(ic, s, 0.5, 0.5, 0.16, 0.52, Color3.fromRGB(255, 214, 10), 45, 0.1)
		shape(ic, s, 0.684, 0.316, 0.17, 0.1, Color3.fromRGB(255, 120, 150), 45, 0.2)
		shape(ic, s, 0.31, 0.69, 0.11, 0.11, Color3.fromRGB(245, 215, 180), 45, 0.1)
		shape(ic, s, 0.275, 0.725, 0.05, 0.05, Color3.fromRGB(60, 60, 70), 45, 0.1)
	end,
}
ICONS.x_fit = {
	c1 = Color3.fromRGB(40, 40, 46), c2 = Color3.fromRGB(0, 0, 0),
	draw = function(ic, s)
		ringShape(ic, s, 0.5, 0.5, 0.74, 0.1, Color3.fromRGB(255, 45, 85))
		ringShape(ic, s, 0.5, 0.5, 0.52, 0.1, Color3.fromRGB(166, 255, 0))
		ringShape(ic, s, 0.5, 0.5, 0.3, 0.1, Color3.fromRGB(0, 200, 255))
	end,
}
ICONS.x_calc = {
	c1 = Color3.fromRGB(255, 190, 60), c2 = Color3.fromRGB(230, 120, 20),
	draw = function(ic, s)
		shape(ic, s, 0.5, 0.26, 0.7, 0.16, Color3.fromRGB(40, 40, 46), 0, 0.3)
		shape(ic, s, 0.32, 0.52, 0.3, 0.2, WHITE, 0, 0.3)
		shape(ic, s, 0.68, 0.52, 0.3, 0.2, WHITE, 0, 0.3)
		shape(ic, s, 0.32, 0.76, 0.3, 0.2, WHITE, 0, 0.3)
		shape(ic, s, 0.68, 0.76, 0.3, 0.2, WHITE, 0, 0.3)
	end,
}

local function drawIcon(parent, id, x, y, size)
	local def = ICONS[id]
	local ic = frame(parent, x, y, size, size, def.c1, 0, UDim.new(0.225, 0))
	if def.stops then
		stopsGradient(ic, def.stops, 90)
	else
		gradient(ic, def.c1, def.c2, 90)
	end
	def.draw(ic, size)
	stroke(ic, WHITE, 1, 0.82)
	return ic
end

local clocks = {}
local function clockLabel(lbl, kind)
	table.insert(clocks, { lbl, kind })
	return lbl
end

local function timeParts()
	local d = os.date("*t")
	local h12 = d.hour % 12
	if h12 == 0 then h12 = 12 end
	return d, h12, d.hour >= 12 and "PM" or "AM"
end

local function refreshClocks()
	local d, h12, ap = timeParts()
	for _, c in ipairs(clocks) do
		local k = c[2]
		if k == "time" then
			c[1].Text = string.format("%d:%02d", h12, d.min)
		elseif k == "status" then
			c[1].Text = string.format("%d:%02d %s    %s %s %d", h12, d.min, ap, os.date("%a"), os.date("%b"), d.day)
		elseif k == "date" then
			c[1].Text = string.format("%s, %s %d", os.date("%A"), os.date("%B"), d.day)
		end
	end
end

---------------------------------------------------------------- state
local state = "lock"
local curId = nil
local screenOff = false
local siriOpen, pwOpen = false, false
local ccOpen = false
local wifiOn, connected, connecting, connectToken = false, nil, nil, nil
local airplane, btOn = false, false
local siriOn, siriHold, siriVoice = true, true, 1
local brightness = 1
local vol = 8
local wifiIcons = {}

local openApp, closeApp, lockNow, unlock, openSiri, closeSiri, openPw
local setWifi, connectTo, onNetChanged, changeVolume, applyBrightness, layoutHome, getApp, showApp
local ccRender, openCC, closeCC

---------------------------------------------------------------- layers
local root = frame(gui, 0, 0, CW, CH, Color3.new(0, 0, 0), 0, px(28))
root.Size = UDim2.fromScale(1, 1)
root.ClipsDescendants = true

local function wallpaper(parent, rot)
	local f = frame(parent, 0, 0, CW, CH, WHITE, 0)
	f.ClipsDescendants = true
	local g = Instance.new("UIGradient")
	g.Rotation = rot
	g.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(16, 22, 70)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(104, 54, 170)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(244, 112, 150)),
	})
	g.Parent = f
	frame(f, -120, 380, 520, 520, Color3.fromRGB(255, 170, 120), 0.82, FULL)
	frame(f, 640, -160, 480, 480, Color3.fromRGB(90, 200, 255), 0.85, FULL)
	return f
end

local function homeBar(parent)
	frame(parent, 390, 680, 220, 8, WHITE, 0.1, px(4))
end

local function status(parent, withLeft)
	if withLeft then
		clockLabel(label(parent, "", 30, 8, 420, 28, 22, WHITE, Enum.Font.GothamBold, Enum.TextXAlignment.Left), "status")
	end
	local icon = { bars = {} }
	for i = 1, 3 do
		local h = 4 + i * 4
		icon.bars[i] = frame(parent, 818 + (i - 1) * 9, 32 - h, 6, h, WHITE, 0.65, px(2))
	end
	icon.slash = frame(parent, 828, 9, 3, 30, WHITE, 0, px(2))
	icon.slash.Rotation = 45
	table.insert(wifiIcons, icon)
	label(parent, "87%", 850, 8, 62, 28, 20, WHITE, Enum.Font.GothamBold, Enum.TextXAlignment.Right)
	local body = frame(parent, 920, 13, 40, 18, WHITE, 1, px(6))
	stroke(body, WHITE, 1.5, 0.3)
	frame(parent, 923, 16, 31, 12, WHITE, 0, px(3))
	frame(parent, 962, 18, 3, 8, WHITE, 0.3, px(2))
end

---------------------------------------------------------------- on-screen keyboard
local function makeKeyboard(parent, rx, ry, ax, ay)
	local kb = { shift = false, keys = {} }
	local f = frame(parent, rx, ry, 676, 346, Color3.fromRGB(26, 26, 34), 0, px(18))
	f.ZIndex = 5
	f.Visible = false
	kb.frame = f
	local KEYC, SPEC = Color3.fromRGB(78, 78, 96), Color3.fromRGB(52, 52, 66)

	local function add(id, text, x, y, w, special)
		local k = frame(f, 12 + x, 12 + y, w, 58, special and SPEC or KEYC, 0, px(10))
		local l = label(k, text, 0, 0, w, 58, special and 19 or 26, WHITE, Enum.Font.GothamBold)
		table.insert(kb.keys, { id = id, frame = k, lbl = l, special = special, rect = { ax + 12 + x, ay + 12 + y, w, 58 } })
	end

	local digits = "1234567890"
	for i = 1, 10 do add(digits:sub(i, i), digits:sub(i, i), (i - 1) * 66, 0, 58) end
	local r2 = "qwertyuiop"
	for i = 1, 10 do add(r2:sub(i, i), r2:sub(i, i), (i - 1) * 66, 66, 58) end
	local r3 = "asdfghjkl"
	for i = 1, 9 do add(r3:sub(i, i), r3:sub(i, i), 33 + (i - 1) * 66, 132, 58) end
	add("shift", "Shift", 0, 198, 92, true)
	local r4 = "zxcvbnm"
	for i = 1, 7 do add(r4:sub(i, i), r4:sub(i, i), 100 + (i - 1) * 66, 198, 58) end
	add("back", "Del", 562, 198, 90, true)
	add("done", "Done", 0, 264, 92, true)
	add(",", ",", 100, 264, 58)
	add(" ", "space", 166, 264, 300)
	add(".", ".", 474, 264, 58)
	add("return", "Return", 540, 264, 112, true)

	function kb.refresh()
		for _, k in ipairs(kb.keys) do
			if not k.special then
				if k.id == " " then
					k.lbl.Text = "space"
				elseif kb.shift and k.id:match("%a") then
					k.lbl.Text = k.id:upper()
				else
					k.lbl.Text = k.id
				end
			elseif k.id == "shift" then
				k.frame.BackgroundColor3 = kb.shift and Color3.fromRGB(240, 240, 250) or SPEC
				k.lbl.TextColor3 = kb.shift and Color3.new(0, 0, 0) or WHITE
			end
		end
	end

	function kb.tap(x, y)
		for _, k in ipairs(kb.keys) do
			if inRect(x, y, k.rect[1], k.rect[2], k.rect[3], k.rect[4]) then
				local id = k.id
				if id == "shift" then
					kb.shift = not kb.shift
				elseif id == "back" then
					if kb.onBack then kb.onBack() end
				elseif id == "return" then
					if kb.onReturn then kb.onReturn() end
				elseif id == "done" then
					if kb.onDone then kb.onDone() end
				else
					local ch = id
					if kb.shift and ch:match("%a") then
						ch = ch:upper()
						kb.shift = false
					end
					if kb.onChar then kb.onChar(ch) end
				end
				kb.refresh()
				local target = k.frame.BackgroundColor3
				k.frame.BackgroundColor3 = Color3.fromRGB(140, 140, 165)
				tw(k.frame, 0.18, { BackgroundColor3 = target })
				return true
			end
		end
		return false
	end

	return kb
end

---------------------------------------------------------------- HOME
local homeF = frame(root, 500, 350, CW, CH, WHITE, 1)
homeF.AnchorPoint = Vector2.new(0.5, 0.5)
homeF.ZIndex = 1
local homeScale = Instance.new("UIScale")
homeScale.Parent = homeF
wallpaper(homeF, 40)
status(homeF, true)
local iconsF = frame(homeF, 0, 0, CW, CH, WHITE, 1)
frame(homeF, 440, 6, 120, 30, Color3.new(0, 0, 0), 0.6, px(15))
label(homeF, "Lock", 440, 6, 120, 30, 18, WHITE, Enum.Font.GothamBold)
homeBar(homeF)

---------------------------------------------------------------- APP container
local appF = frame(root, 500, 350, CW, CH, BG, 0, px(28))
appF.AnchorPoint = Vector2.new(0.5, 0.5)
appF.ZIndex = 2
appF.Visible = false
appF.ClipsDescendants = true
local appScale = Instance.new("UIScale")
appScale.Parent = appF

local chromeF = frame(appF, 0, 0, CW, CH, WHITE, 1)
chromeF.ZIndex = 4
status(chromeF, true)
frame(chromeF, 440, 6, 120, 30, Color3.new(0, 0, 0), 0.6, px(15))
label(chromeF, "Home", 440, 6, 120, 30, 18, WHITE, Enum.Font.GothamBold)
homeBar(appF)

local apps = {}
local pageFrames = {}
local function newPage()
	local p = { regions = {} }
	p.frame = frame(appF, 0, 0, CW, CH, WHITE, 1)
	p.frame.ZIndex = 1
	p.frame.Visible = false
	table.insert(pageFrames, p.frame)
	function p.clear()
		p.frame:ClearAllChildren()
		p.regions = {}
	end
	function p.region(x, y, w, h, fn)
		table.insert(p.regions, { x, y, w, h, fn })
	end
	function p.tap(x, y)
		for i = #p.regions, 1, -1 do
			local r = p.regions[i]
			if inRect(x, y, r[1], r[2], r[3], r[4]) then
				r[5](x, y)
				return true
			end
		end
		return false
	end
	return p
end

local kbApp = makeKeyboard(appF, 162, 330, 162, 330)

---------------------------------------------------------------- LOCK
local lockF = frame(root, 0, 0, CW, CH, Color3.new(0, 0, 0), 1)
lockF.ZIndex = 3
wallpaper(lockF, 120)
status(lockF, false)
clockLabel(label(lockF, "", 0, 120, 1000, 40, 34, Color3.fromRGB(240, 240, 255), Enum.Font.GothamMedium), "date")
clockLabel(label(lockF, "", 0, 155, 1000, 170, 160, WHITE, Enum.Font.GothamBold), "time")
local hint = label(lockF, "Swipe up to unlock", 0, 625, 1000, 36, 26, WHITE, Enum.Font.GothamMedium)
homeBar(lockF)

---------------------------------------------------------------- Wi-Fi password prompt
local NETWORKS = {
	{ name = "Home_5G", pass = "12345678" },
	{ name = "CoffeeShop_Free" },
	{ name = "Roblox_Guest" },
	{ name = "NeighborNet", pass = "password123" },
	{ name = "Library_WiFi", pass = "readbooks" },
}

local pwF = frame(root, 0, 0, CW, CH, Color3.new(0, 0, 0), 0.35)
pwF.ZIndex = 7
pwF.Visible = false
local PX, PY, PW, PH = 150, 50, 700, 600
local pcard = frame(pwF, PX, PY, PW, PH, Color3.fromRGB(34, 34, 44), 0, px(28))
local pwTitle = label(pcard, "", 150, 16, 400, 40, 24, WHITE, Enum.Font.GothamBold)
frame(pcard, 24, 16, 110, 40, Color3.fromRGB(60, 60, 74), 0, px(20))
label(pcard, "Cancel", 24, 16, 110, 40, 18, WHITE, Enum.Font.GothamBold)
frame(pcard, 566, 16, 110, 40, BLUE, 0, px(20))
label(pcard, "Join", 566, 16, 110, 40, 18, WHITE, Enum.Font.GothamBold)
local pwField = frame(pcard, 60, 80, 580, 70, Color3.fromRGB(20, 20, 28), 0, px(16))
local pwText = label(pwField, "", 16, 0, 548, 70, 36, WHITE, Enum.Font.GothamBold, Enum.TextXAlignment.Left)
local pwErr = label(pcard, "", 60, 156, 580, 30, 20, Color3.fromRGB(255, 110, 110), Enum.Font.GothamMedium)
local kbPw = makeKeyboard(pcard, 12, 196, PX + 12, PY + 196)
kbPw.frame.Visible = true

local pwBuf = ""
local pwTarget = nil

local function updatePw()
	if #pwBuf == 0 then
		pwText.Text = "Password"
		pwText.TextColor3 = Color3.fromRGB(110, 110, 125)
	else
		pwText.Text = string.rep("•", #pwBuf - 1) .. pwBuf:sub(-1)
		pwText.TextColor3 = WHITE
	end
end

local function pwJoin()
	if pwTarget and pwBuf == pwTarget.pass then
		pwF.Visible = false
		pwOpen = false
		connectTo(pwTarget)
	else
		pwErr.Text = "Incorrect password"
		pwBuf = ""
		updatePw()
	end
end

kbPw.onChar = function(ch)
	if #pwBuf < 20 then pwBuf = pwBuf .. ch end
	pwErr.Text = ""
	updatePw()
end
kbPw.onBack = function()
	pwBuf = pwBuf:sub(1, -2)
	updatePw()
end
kbPw.onReturn = pwJoin

local function pwTap(x, y)
	if inRect(x, y, PX + 24, PY + 16, 110, 40) then
		pwF.Visible = false
		pwOpen = false
		return
	end
	if inRect(x, y, PX + 566, PY + 16, 110, 40) then
		pwJoin()
		return
	end
	kbPw.tap(x, y)
end

openPw = function(n)
	pwTarget = n
	pwBuf = ""
	pwErr.Text = ""
	pwTitle.Text = n.name
	updatePw()
	pwOpen = true
	pwF.Visible = true
end

---------------------------------------------------------------- Siri overlay
local siriF = frame(root, 0, 0, CW, CH, Color3.new(0, 0, 0), 0.4)
siriF.ZIndex = 8
siriF.Visible = false
local orb = frame(siriF, 500, 170, 120, 120, WHITE, 0, FULL)
orb.AnchorPoint = Vector2.new(0.5, 0.5)
local orbG = Instance.new("UIGradient")
orbG.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(80, 220, 255)),
	ColorSequenceKeypoint.new(0.35, Color3.fromRGB(190, 90, 255)),
	ColorSequenceKeypoint.new(0.7, Color3.fromRGB(255, 120, 150)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(80, 220, 255)),
})
orbG.Parent = orb
label(siriF, "Hi, how can I help?", 0, 255, 1000, 50, 36, WHITE, Enum.Font.GothamBold)
local siriReply = label(siriF, "", 100, 315, 800, 100, 26, Color3.fromRGB(225, 225, 240), Enum.Font.GothamMedium)
siriReply.TextWrapped = true
frame(siriF, 860, 56, 100, 40, Color3.fromRGB(60, 60, 74), 0, px(20))
label(siriF, "Done", 860, 56, 100, 40, 18, WHITE, Enum.Font.GothamBold)

local function fmtTime()
	local d, h12, ap = timeParts()
	return string.format("%d:%02d %s", h12, d.min, ap)
end

local SIRI_CHIPS = {
	{ "What time is it?", 130, 450, function() return "It's " .. fmtTime() .. "." end },
	{ "What's the date?", 510, 450, function()
		local d = os.date("*t")
		return string.format("Today is %s, %s %d.", os.date("%A"), os.date("%B"), d.day)
	end },
	{ "Turn Wi-Fi on", 130, 516, function()
		setWifi(true)
		return "Wi-Fi is on. Pick a network in Settings."
	end },
	{ "Open Notes", 510, 516, function()
		closeSiri()
		openApp("notes")
		return nil
	end },
	{ "Tell me a joke", 320, 582, function()
		return "Why don't scientists trust atoms? Because they make up everything."
	end },
}
for _, chip in ipairs(SIRI_CHIPS) do
	frame(siriF, chip[2], chip[3], 360, 52, Color3.fromRGB(60, 60, 78), 0.1, px(26))
	label(siriF, chip[1], chip[2], chip[3], 360, 52, 20, WHITE, Enum.Font.GothamMedium)
end

local function siriTap(x, y)
	if inRect(x, y, 860, 56, 100, 40) then
		closeSiri()
		return
	end
	for _, chip in ipairs(SIRI_CHIPS) do
		if inRect(x, y, chip[2], chip[3], 360, 52) then
			if not siriOn then
				siriReply.Text = "Siri is turned off. You can turn it on in Settings > Siri."
			else
				local r = chip[4]()
				if r then siriReply.Text = r end
			end
			return
		end
	end
end

openSiri = function()
	if siriOpen or screenOff or state == "lock" then return end
	siriOpen = true
	siriReply.Text = siriOn and "" or "Siri is turned off. You can turn it on in Settings > Siri."
	siriF.Visible = true
end

closeSiri = function()
	siriOpen = false
	siriF.Visible = false
end

---------------------------------------------------------------- ripples, volume HUD, brightness, screen-off
local ripples = frame(root, 0, 0, CW, CH, WHITE, 1)
ripples.ZIndex = 10
local function ripple(u, v)
	local r = frame(ripples, u * CW, v * CH, 10, 10, WHITE, 0.55, FULL)
	r.AnchorPoint = Vector2.new(0.5, 0.5)
	tw(r, 0.45, { Size = UDim2.fromOffset(110, 110), BackgroundTransparency = 1 })
	Debris:AddItem(r, 0.5)
end

local hud = frame(root, 330, 50, 340, 46, Color3.fromRGB(20, 20, 28), 0.15, FULL)
hud.ZIndex = 20
hud.Visible = false
label(hud, "Volume", 18, 0, 90, 46, 18, WHITE, Enum.Font.GothamBold, Enum.TextXAlignment.Left)
local hudTrack = frame(hud, 120, 18, 190, 10, Color3.fromRGB(90, 90, 100), 0, FULL)
local hudFill = frame(hudTrack, 0, 0, 95, 10, WHITE, 0, FULL)
local hudToken = 0

local dimF = frame(root, 0, 0, CW, CH, Color3.new(0, 0, 0), 1)
dimF.ZIndex = 25
local offF = frame(root, 0, 0, CW, CH, Color3.new(0, 0, 0), 1)
offF.ZIndex = 30
offF.Visible = false

applyBrightness = function()
	dimF.BackgroundTransparency = 1 - (1 - brightness) * 0.85
end

changeVolume = function(delta)
	vol = math.clamp(vol + delta, 0, 16)
	tw(hudFill, 0.1, { Size = UDim2.fromOffset(190 * vol / 16, 10) })
	hud.Visible = true
	hudToken = hudToken + 1
	local my = hudToken
	task.delay(1.6, function()
		if hudToken == my then hud.Visible = false end
	end)
	if state == "app" and curId == "settings" and apps.settings.sel == "sounds" then
		apps.settings.render()
	end
end

---------------------------------------------------------------- networking
onNetChanged = function()
	for _, ic in ipairs(wifiIcons) do
		for _, b in ipairs(ic.bars) do b.BackgroundTransparency = connected and 0 or 0.65 end
		ic.slash.Visible = not wifiOn
	end
	if state == "app" then
		local a = getApp()
		if a and a.render then a.render() end
	end
	if ccOpen then ccRender() end
end

setWifi = function(on)
	wifiOn = on
	if on then
		airplane = false
	else
		connected = nil
		connecting = nil
		connectToken = nil
	end
	onNetChanged()
end

connectTo = function(n)
	connecting = n.name
	connected = nil
	local token = {}
	connectToken = token
	onNetChanged()
	task.delay(1.3, function()
		if connectToken == token and wifiOn then
			connected = n.name
			connecting = nil
			onNetChanged()
		end
	end)
end

---------------------------------------------------------------- APP: Settings
local S = { page = newPage(), sel = "wifi", drag = nil, slider = nil }
apps.settings = S
local BT_DEVICES = { { name = "AirPods Pro", on = false }, { name = "Magic Keyboard", on = false }, { name = "Portable Speaker", on = false } }
local VOICES = { "American", "British", "Australian" }

local SETTINGS_ITEMS = {
	{ id = "airplane", name = "Airplane Mode", icon = "airplane", color = Color3.fromRGB(255, 149, 0) },
	{ id = "wifi", name = "Wi-Fi", icon = "wifi", color = BLUE,
		value = function() return (not wifiOn) and "Off" or (connected or "Not Connected") end },
	{ id = "bluetooth", name = "Bluetooth", icon = "bluetooth", color = BLUE,
		value = function() return btOn and "On" or "Off" end },
	{ id = "siri", name = "Siri", icon = "siri", color = Color3.fromRGB(120, 90, 220),
		value = function() return siriOn and "On" or "Off" end },
	{ id = "display", name = "Display & Brightness", icon = "sun", color = Color3.fromRGB(10, 132, 255) },
	{ id = "sounds", name = "Sounds", icon = "speaker", color = Color3.fromRGB(255, 59, 48) },
	{ id = "general", name = "General", icon = "gear", color = Color3.fromRGB(142, 142, 147) },
}

local function card(f, x, y, w, h)
	return frame(f, x, y, w, h, CARD, 0, px(14))
end

function S.render()
	local p = S.page
	p.clear()
	local f = p.frame
	S.slider, S.volLbl = nil, nil

	-- sidebar
	frame(f, 0, 44, 310, 656, Color3.fromRGB(32, 32, 42), 0)
	label(f, "Settings", 24, 54, 260, 44, 34, WHITE, Enum.Font.GothamBold, Enum.TextXAlignment.Left)
	for i, it in ipairs(SETTINGS_ITEMS) do
		local y = 116 + (i - 1) * 58
		local selected = (S.sel == it.id)
		if selected then frame(f, 12, y, 286, 52, BLUE, 0, px(12)) end
		local ib = frame(f, 24, y + 8, 36, 36, it.color, 0, px(9))
		glyph(ib, it.icon, 18, 18, 24, WHITE, it.color)
		if it.value then
			label(f, it.name, 72, y + 4, 214, 26, 18, WHITE, Enum.Font.GothamMedium, Enum.TextXAlignment.Left)
			label(f, it.value(), 72, y + 28, 214, 20, 13, selected and WHITE or GRAY, Enum.Font.GothamMedium, Enum.TextXAlignment.Left)
		elseif it.id == "airplane" then
			label(f, it.name, 72, y, 146, 52, 18, WHITE, Enum.Font.GothamMedium, Enum.TextXAlignment.Left)
		else
			label(f, it.name, 72, y, 214, 52, 18, WHITE, Enum.Font.GothamMedium, Enum.TextXAlignment.Left)
		end
		if it.id == "airplane" then
			drawToggle(f, 222, y + 8, airplane)
			p.region(12, y, 286, 52, function()
				airplane = not airplane
				if airplane then
					btOn = false
					setWifi(false)
				else
					S.render()
				end
			end)
		else
			p.region(12, y, 286, 52, function()
				S.sel = it.id
				S.render()
			end)
		end
	end

	-- detail
	local sel = S.sel
	if sel == "wifi" then
		label(f, "Wi-Fi", 340, 54, 400, 44, 32, WHITE, Enum.Font.GothamBold, Enum.TextXAlignment.Left)
		card(f, 340, 116, 630, 60)
		label(f, "Wi-Fi", 360, 116, 300, 60, 22, WHITE, Enum.Font.GothamMedium, Enum.TextXAlignment.Left)
		drawToggle(f, 886, 128, wifiOn)
		p.region(780, 116, 190, 60, function() setWifi(not wifiOn) end)
		if wifiOn then
			label(f, connected and ("Connected to " .. connected) or "Choose a network", 340, 184, 630, 28, 18, GRAY, Enum.Font.GothamMedium, Enum.TextXAlignment.Left)
			for i, n in ipairs(NETWORKS) do
				local y = 222 + (i - 1) * 62
				card(f, 340, y, 630, 56)
				label(f, n.name, 360, y, 300, 56, 22, WHITE, Enum.Font.GothamMedium, Enum.TextXAlignment.Left)
				if n.pass then glyph(f, "lock", 790, y + 28, 20, GRAY, CARD) end
				local st = (connecting == n.name) and "Connecting..." or ((connected == n.name) and "Connected" or "")
				label(f, st, 810, y, 150, 56, 17, Color3.fromRGB(110, 170, 255), Enum.Font.GothamBold, Enum.TextXAlignment.Right)
				p.region(340, y, 630, 56, function()
					if connected == n.name then
						connected = nil
						onNetChanged()
					elseif connecting ~= n.name then
						if n.pass then openPw(n) else connectTo(n) end
					end
				end)
			end
		else
			label(f, "Wi-Fi is turned off", 340, 300, 630, 40, 24, GRAY, Enum.Font.GothamMedium)
		end

	elseif sel == "bluetooth" then
		label(f, "Bluetooth", 340, 54, 400, 44, 32, WHITE, Enum.Font.GothamBold, Enum.TextXAlignment.Left)
		card(f, 340, 116, 630, 60)
		label(f, "Bluetooth", 360, 116, 300, 60, 22, WHITE, Enum.Font.GothamMedium, Enum.TextXAlignment.Left)
		drawToggle(f, 886, 128, btOn)
		p.region(780, 116, 190, 60, function()
			btOn = not btOn
			if btOn then airplane = false else for _, d in ipairs(BT_DEVICES) do d.on = false end end
			S.render()
		end)
		if btOn then
			label(f, "MY DEVICES", 340, 190, 300, 22, 14, GRAY, Enum.Font.GothamBold, Enum.TextXAlignment.Left)
			for i, d in ipairs(BT_DEVICES) do
				local y = 220 + (i - 1) * 62
				card(f, 340, y, 630, 56)
				label(f, d.name, 360, y, 400, 56, 22, WHITE, Enum.Font.GothamMedium, Enum.TextXAlignment.Left)
				label(f, d.on and "Connected" or "Not Connected", 760, y, 200, 56, 17, d.on and Color3.fromRGB(110, 170, 255) or GRAY, Enum.Font.GothamBold, Enum.TextXAlignment.Right)
				p.region(340, y, 630, 56, function()
					d.on = not d.on
					S.render()
				end)
			end
		else
			label(f, "Bluetooth is turned off", 340, 300, 630, 40, 24, GRAY, Enum.Font.GothamMedium)
		end

	elseif sel == "siri" then
		label(f, "Siri", 340, 54, 400, 44, 32, WHITE, Enum.Font.GothamBold, Enum.TextXAlignment.Left)
		card(f, 340, 116, 630, 60)
		label(f, "Siri", 360, 116, 300, 60, 22, WHITE, Enum.Font.GothamMedium, Enum.TextXAlignment.Left)
		drawToggle(f, 886, 128, siriOn)
		p.region(780, 116, 190, 60, function()
			siriOn = not siriOn
			S.render()
		end)
		card(f, 340, 184, 630, 60)
		label(f, "Hold Home Bar for Siri", 360, 184, 450, 60, 22, WHITE, Enum.Font.GothamMedium, Enum.TextXAlignment.Left)
		drawToggle(f, 886, 196, siriHold)
		p.region(780, 184, 190, 60, function()
			siriHold = not siriHold
			S.render()
		end)
		label(f, "SIRI VOICE", 340, 262, 300, 22, 14, GRAY, Enum.Font.GothamBold, Enum.TextXAlignment.Left)
		for i, name in ipairs(VOICES) do
			local y = 290 + (i - 1) * 62
			local on = (siriVoice == i)
			card(f, 340, y, 630, 56)
			label(f, name, 360, y, 400, 56, 22, WHITE, Enum.Font.GothamMedium, Enum.TextXAlignment.Left)
			local r = frame(f, 930, y + 16, 24, 24, on and BLUE or CARD, 0, FULL)
			stroke(r, on and BLUE or GRAY, 2)
			p.region(340, y, 630, 56, function()
				siriVoice = i
				S.render()
			end)
		end
		frame(f, 340, 494, 630, 56, BLUE, 0, px(14))
		label(f, "Try Siri", 340, 494, 630, 56, 22, WHITE, Enum.Font.GothamBold)
		p.region(340, 494, 630, 56, function() openSiri() end)

	elseif sel == "display" then
		label(f, "Display & Brightness", 340, 54, 600, 44, 32, WHITE, Enum.Font.GothamBold, Enum.TextXAlignment.Left)
		card(f, 340, 116, 630, 130)
		label(f, "Brightness", 360, 126, 300, 36, 22, WHITE, Enum.Font.GothamMedium, Enum.TextXAlignment.Left)
		S.slider = drawSlider(f, 370, 196, 570, (brightness - 0.1) / 0.9)
		label(f, "Drag the slider to dim or brighten the screen.", 340, 262, 630, 28, 18, GRAY, Enum.Font.GothamMedium, Enum.TextXAlignment.Left)

	elseif sel == "sounds" then
		label(f, "Sounds", 340, 54, 400, 44, 32, WHITE, Enum.Font.GothamBold, Enum.TextXAlignment.Left)
		card(f, 340, 116, 630, 130)
		label(f, "Volume", 360, 126, 300, 36, 22, WHITE, Enum.Font.GothamMedium, Enum.TextXAlignment.Left)
		S.volLbl = label(f, math.floor(vol / 16 * 100 + 0.5) .. "%", 820, 126, 130, 36, 20, GRAY, Enum.Font.GothamBold, Enum.TextXAlignment.Right)
		S.slider = drawSlider(f, 370, 196, 570, vol / 16)
		label(f, "You can also use the volume buttons on the side of the iPad.", 340, 262, 630, 28, 18, GRAY, Enum.Font.GothamMedium, Enum.TextXAlignment.Left)

	elseif sel == "general" then
		label(f, "General", 340, 54, 400, 44, 32, WHITE, Enum.Font.GothamBold, Enum.TextXAlignment.Left)
		local rows = { { "Name", "iPad" }, { "Model", "iPad Air" }, { "Software Version", "iPadOS 18.0" }, { "Capacity", "64 GB" } }
		for i, r in ipairs(rows) do
			local y = 116 + (i - 1) * 62
			card(f, 340, y, 630, 56)
			label(f, r[1], 360, y, 300, 56, 22, WHITE, Enum.Font.GothamMedium, Enum.TextXAlignment.Left)
			label(f, r[2], 640, y, 310, 56, 20, GRAY, Enum.Font.GothamMedium, Enum.TextXAlignment.Right)
		end
	end
end

-- Define S.onDrag BEFORE S.onPress so it is never nil
function S.onDrag(x, y)
	if not S.drag then return end
	local frac = math.clamp((x - 370) / 570, 0, 1)
	if S.drag == "bright" then
		brightness = 0.1 + 0.9 * frac
		applyBrightness()
	else
		vol = math.floor(frac * 16 + 0.5)
		frac = vol / 16
		if S.volLbl then S.volLbl.Text = math.floor(frac * 100 + 0.5) .. "%" end
	end
	setSlider(S.slider, frac)
end

function S.onPress(x, y)
	if (S.sel == "display" or S.sel == "sounds") and inRect(x, y, 350, 170, 620, 60) then
		S.drag = (S.sel == "display") and "bright" or "vol"
		S.onDrag(x, y)
		return true
	end
	return false
end

function S.onRelease()
	S.drag = nil
end

S.tap = S.page.tap

---------------------------------------------------------------- APP: App Store
local STORE = {
	{ id = "x_chess", name = "Pocket Chess", sub = "Classic strategy board game", c1 = Color3.fromRGB(120, 120, 130), c2 = Color3.fromRGB(40, 40, 48) },
	{ id = "x_weather", name = "Weather Now", sub = "Live forecasts for your city", c1 = Color3.fromRGB(110, 200, 255), c2 = Color3.fromRGB(30, 110, 230) },
	{ id = "x_photo", name = "Photo Studio", sub = "Edit and share your photos", c1 = Color3.fromRGB(255, 170, 100), c2 = Color3.fromRGB(230, 70, 130) },
	{ id = "x_sketch", name = "Sketchbook", sub = "Draw anywhere, any time", c1 = Color3.fromRGB(190, 120, 255), c2 = Color3.fromRGB(100, 60, 220) },
	{ id = "x_fit", name = "Fitness Pal", sub = "Track workouts and goals", c1 = Color3.fromRGB(110, 230, 130), c2 = Color3.fromRGB(20, 160, 80) },
	{ id = "x_calc", name = "Calc Pro", sub = "Powerful scientific calculator", c1 = Color3.fromRGB(255, 190, 60), c2 = Color3.fromRGB(230, 120, 20) },
}
local EXTRA = {}
for _, it in ipairs(STORE) do EXTRA[it.id] = it end

local homeApps = { "appstore", "settings", "notes", "podcasts", "reminders" }
local DEFS = {
	appstore = { name = "App Store", c1 = Color3.fromRGB(80, 170, 255), c2 = Color3.fromRGB(20, 90, 230) },
	settings = { name = "Settings", c1 = Color3.fromRGB(170, 172, 180), c2 = Color3.fromRGB(100, 102, 112) },
	notes = { name = "Notes", c1 = Color3.fromRGB(255, 226, 90), c2 = Color3.fromRGB(240, 180, 30) },
	podcasts = { name = "Podcasts", c1 = Color3.fromRGB(200, 110, 255), c2 = Color3.fromRGB(120, 50, 210) },
	reminders = { name = "Reminders", c1 = Color3.fromRGB(255, 255, 255), c2 = Color3.fromRGB(215, 215, 225) },
}
for _, it in ipairs(STORE) do DEFS[it.id] = { name = it.name, c1 = it.c1, c2 = it.c2 } end

local AS = { page = newPage() }
apps.appstore = AS
local installed, downloading = {}, {}

function AS.render()
	local p = AS.page
	p.clear()
	local f = p.frame
	label(f, "App Store", 60, 54, 500, 52, 42, WHITE, Enum.Font.GothamBold, Enum.TextXAlignment.Left)
	if not connected then
		label(f, "No Internet Connection", 0, 250, 1000, 50, 36, WHITE, Enum.Font.GothamBold)
		label(f, "Connect to a Wi-Fi network in Settings to browse apps.", 0, 306, 1000, 34, 22, GRAY, Enum.Font.GothamMedium)
		frame(f, 400, 370, 200, 54, BLUE, 0, px(27))
		label(f, "Open Settings", 400, 370, 200, 54, 20, WHITE, Enum.Font.GothamBold)
		p.region(400, 370, 200, 54, function()
			S.sel = "wifi"
			openApp("settings")
		end)
		return
	end
	label(f, "Featured Apps", 60, 104, 500, 28, 20, GRAY, Enum.Font.GothamMedium, Enum.TextXAlignment.Left)
	for i, it in ipairs(STORE) do
		local y = 144 + (i - 1) * 86
		drawIcon(f, it.id, 60, y, 70)
		label(f, it.name, 148, y + 6, 520, 32, 26, WHITE, Enum.Font.GothamBold, Enum.TextXAlignment.Left)
		label(f, it.sub, 148, y + 40, 520, 26, 18, GRAY, Enum.Font.GothamMedium, Enum.TextXAlignment.Left)
		local by = y + 13
		if installed[it.id] then
			frame(f, 800, by, 140, 44, Color3.fromRGB(70, 70, 84), 0, px(22))
			label(f, "OPEN", 800, by, 140, 44, 18, WHITE, Enum.Font.GothamBold)
			p.region(800, by, 140, 44, function() openApp(it.id) end)
		elseif downloading[it.id] then
			frame(f, 800, by, 140, 44, Color3.fromRGB(70, 70, 84), 0, px(22))
			label(f, math.floor(downloading[it.id] * 100) .. "%", 800, by, 140, 44, 18, Color3.fromRGB(110, 170, 255), Enum.Font.GothamBold)
		else
			frame(f, 800, by, 140, 44, BLUE, 0, px(22))
			label(f, "GET", 800, by, 140, 44, 18, WHITE, Enum.Font.GothamBold)
			p.region(800, by, 140, 44, function()
				downloading[it.id] = 0
				AS.render()
			end)
		end
	end
end
AS.tap = AS.page.tap

---------------------------------------------------------------- APP: Demo
local demoApp = { page = newPage(), def = nil }
function demoApp.render()
	local p = demoApp.page
	p.clear()
	local f = p.frame
	local d = demoApp.def
	if not d then return end
	drawIcon(f, d.id, 400, 150, 200)
	label(f, d.name, 0, 380, 1000, 60, 46, WHITE, Enum.Font.GothamBold)
	label(f, "Demo app - nothing here yet", 0, 440, 1000, 36, 24, GRAY, Enum.Font.GothamMedium)
end
demoApp.tap = demoApp.page.tap

---------------------------------------------------------------- APP: Notes
local N = {
	page = newPage(),
	notes = { { body = "Welcome to Notes\nTap + to write a new note." } },
	sel = 1,
	editing = false,
}
apps.notes = N

local function noteTitle(b)
	local first = b:match("([^\n]*)") or ""
	return first == "" and "New Note" or first
end

local function noteEditStart()
	N.editing = true
	kbApp.onChar = function(ch)
		local n = N.notes[N.sel]
		if n and #n.body < 600 then
			n.body = n.body .. ch
			N.render()
		end
	end
	kbApp.onBack = function()
		local n = N.notes[N.sel]
		if n then
			n.body = n.body:sub(1, -2)
			N.render()
		end
	end
	kbApp.onReturn = function()
		local n = N.notes[N.sel]
		if n and #n.body < 600 then
			n.body = n.body .. "\n"
			N.render()
		end
	end
	kbApp.onDone = function()
		N.editing = false
		kbApp.frame.Visible = false
		N.render()
	end
	kbApp.shift = false
	kbApp.refresh()
	kbApp.frame.Visible = true
end

function N.onShow()
	N.editing = false
	kbApp.frame.Visible = false
end

function N.render()
	local p = N.page
	p.clear()
	local f = p.frame
	frame(f, 0, 44, 310, 656, Color3.fromRGB(32, 32, 42), 0)
	label(f, "Notes", 24, 54, 200, 44, 34, WHITE, Enum.Font.GothamBold, Enum.TextXAlignment.Left)
	local plus = frame(f, 248, 58, 44, 44, Color3.fromRGB(255, 204, 0), 0, FULL)
	label(plus, "+", 0, 0, 44, 44, 30, Color3.new(0, 0, 0), Enum.Font.GothamBold)
	p.region(236, 50, 66, 60, function()
		if #N.notes >= 8 then return end
		table.insert(N.notes, 1, { body = "" })
		N.sel = 1
		noteEditStart()
		N.render()
	end)
	for i, n in ipairs(N.notes) do
		local y = 116 + (i - 1) * 70
		local selected = (i == N.sel)
		frame(f, 12, y, 286, 62, selected and Color3.fromRGB(255, 204, 0) or CARD, selected and 0.78 or 0, px(12))
		label(f, noteTitle(n.body), 26, y + 6, 260, 28, 20, WHITE, Enum.Font.GothamBold, Enum.TextXAlignment.Left)
		label(f, n.body:match("\n([^\n]*)") or "No additional text", 26, y + 34, 260, 22, 15, GRAY, Enum.Font.GothamMedium, Enum.TextXAlignment.Left)
		p.region(12, y, 286, 62, function()
			N.sel = i
			N.editing = false
			kbApp.frame.Visible = false
			N.render()
		end)
	end

	local note = N.notes[N.sel]
	if note then
		frame(f, 700, 58, 110, 40, Color3.fromRGB(255, 69, 58), 0.15, px(20))
		label(f, "Delete", 700, 58, 110, 40, 18, WHITE, Enum.Font.GothamBold)
		p.region(700, 58, 110, 40, function()
			table.remove(N.notes, N.sel)
			N.sel = (#N.notes > 0) and math.min(N.sel, #N.notes) or nil
			N.editing = false
			kbApp.frame.Visible = false
			N.render()
		end)
		if N.editing then
			frame(f, 830, 58, 110, 40, BLUE, 0, px(20))
			label(f, "Done", 830, 58, 110, 40, 18, WHITE, Enum.Font.GothamBold)
			p.region(830, 58, 110, 40, function()
				N.editing = false
				kbApp.frame.Visible = false
				N.render()
			end)
		end
		local h = N.editing and 214 or 540
		local ta
		if note.body == "" then
			ta = label(f, N.editing and "|" or "Tap here to start typing...", 340, 112, 620, h, 24, N.editing and WHITE or GRAY, Enum.Font.GothamMedium, Enum.TextXAlignment.Left)
		else
			ta = label(f, note.body .. (N.editing and "|" or ""), 340, 112, 620, h, 24, WHITE, Enum.Font.GothamMedium, Enum.TextXAlignment.Left)
		end
		ta.TextWrapped = true
		ta.TextYAlignment = Enum.TextYAlignment.Top
		p.region(330, 104, 640, h + 8, function()
			if not N.editing then
				noteEditStart()
				N.render()
			end
		end)
	else
		label(f, "No note selected", 320, 300, 680, 40, 24, GRAY, Enum.Font.GothamMedium)
	end
end

function N.tap(x, y)
	if N.editing and kbApp.frame.Visible then
		if kbApp.tap(x, y) then return end
		if inRect(x, y, 162, 330, 676, 346) then return end
	end
	N.page.tap(x, y)
end

---------------------------------------------------------------- APP: Reminders
local Rm = {
	page = newPage(),
	items = { { text = "Buy milk", done = false }, { text = "Charge iPad", done = false } },
	adding = false,
	draft = "",
}
apps.reminders = Rm

local function remCommit()
	if #Rm.draft > 0 and #Rm.items < 9 then
		table.insert(Rm.items, { text = Rm.draft, done = false })
	end
	Rm.adding = false
	Rm.draft = ""
	kbApp.frame.Visible = false
	Rm.render()
end

local function remStart()
	if #Rm.items >= 9 or Rm.adding then return end
	Rm.adding = true
	Rm.draft = ""
	kbApp.onChar = function(ch)
		if #Rm.draft < 60 then
			Rm.draft = Rm.draft .. ch
			Rm.render()
		end
	end
	kbApp.onBack = function()
		Rm.draft = Rm.draft:sub(1, -2)
		Rm.render()
	end
	kbApp.onReturn = remCommit
	kbApp.onDone = remCommit
	kbApp.shift = false
	kbApp.refresh()
	kbApp.frame.Visible = true
	Rm.render()
end

function Rm.onShow()
	Rm.adding = false
	Rm.draft = ""
	kbApp.frame.Visible = false
end

function Rm.render()
	local p = Rm.page
	p.clear()
	local f = p.frame
	local remaining, anyDone = 0, false
	for _, it in ipairs(Rm.items) do
		if it.done then anyDone = true else remaining = remaining + 1 end
	end
	label(f, "Reminders", 60, 54, 500, 52, 42, BLUE, Enum.Font.GothamBold, Enum.TextXAlignment.Left)
	label(f, remaining .. " remaining", 60, 106, 400, 26, 20, GRAY, Enum.Font.GothamMedium, Enum.TextXAlignment.Left)
	frame(f, 880, 58, 60, 46, BLUE, 0, px(23))
	label(f, "+", 880, 58, 60, 46, 30, WHITE, Enum.Font.GothamBold)
	p.region(870, 52, 80, 58, remStart)
	if anyDone then
		frame(f, 710, 58, 150, 46, Color3.fromRGB(60, 60, 74), 0, px(23))
		label(f, "Clear Done", 710, 58, 150, 46, 18, WHITE, Enum.Font.GothamBold)
		p.region(710, 58, 150, 46, function()
			for i = #Rm.items, 1, -1 do
				if Rm.items[i].done then table.remove(Rm.items, i) end
			end
			Rm.render()
		end)
	end

	local y = 150
	if Rm.adding then
		frame(f, 60, y, 880, 56, CARD, 0, px(14))
		local c = frame(f, 60, y + 10, 36, 36, BG, 0, FULL)
		stroke(c, BLUE, 2)
		label(f, Rm.draft == "" and "New Reminder|" or (Rm.draft .. "|"), 116, y, 800, 56, 26, Rm.draft == "" and GRAY or WHITE, Enum.Font.GothamMedium, Enum.TextXAlignment.Left)
		y = y + 62
	end
	for i, it in ipairs(Rm.items) do
		local c = frame(f, 60, y + 10, 36, 36, it.done and BLUE or BG, 0, FULL)
		stroke(c, BLUE, 2)
		local lbl = label(f, it.done and ("<s>" .. esc(it.text) .. "</s>") or it.text, 116, y, 820, 56, 26, it.done and GRAY or WHITE, Enum.Font.GothamMedium, Enum.TextXAlignment.Left)
		lbl.RichText = it.done
		frame(f, 116, y + 55, 824, 1, Color3.fromRGB(60, 60, 72), 0)
		p.region(60, y, 880, 56, function()
			it.done = not it.done
			Rm.render()
		end)
		y = y + 56
	end
	if #Rm.items == 0 and not Rm.adding then
		label(f, "All done! Tap + to add a reminder.", 0, 300, 1000, 40, 24, GRAY, Enum.Font.GothamMedium)
	end
end

function Rm.tap(x, y)
	if Rm.adding and kbApp.frame.Visible then
		if kbApp.tap(x, y) then return end
		if inRect(x, y, 162, 330, 676, 346) then return end
	end
	Rm.page.tap(x, y)
end

---------------------------------------------------------------- APP: Podcasts
local SHOWS = {
	{ "Morning Brew Chat", "Daily news & banter", "", Color3.fromRGB(255, 149, 0) },
	{ "True Crime Tuesdays", "Mysteries unfolded", "", Color3.fromRGB(175, 82, 222) },
	{ "Space Talk", "The cosmos explained", "", Color3.fromRGB(10, 132, 255) },
	{ "Chill Beats Radio", "Lo-fi to relax to", "", Color3.fromRGB(52, 199, 89) },
	{ "History Unpacked", "Stories from the past", "", Color3.fromRGB(255, 59, 48) },
	{ "Code & Coffee", "Chats about programming", "", Color3.fromRGB(90, 200, 250) },
}
local Pod = { page = newPage(), sel = nil, playing = false, prog = 0, fill = nil }
apps.podcasts = Pod

function Pod.render()
	local p = Pod.page
	p.clear()
	local f = p.frame
	Pod.fill = nil
	label(f, "Podcasts", 60, 54, 500, 52, 42, WHITE, Enum.Font.GothamBold, Enum.TextXAlignment.Left)
	label(f, "Top Shows", 60, 106, 400, 26, 20, GRAY, Enum.Font.GothamMedium, Enum.TextXAlignment.Left)
	for i, s in ipairs(SHOWS) do
		local col, row = (i - 1) % 3, math.floor((i - 1) / 3)
		local x, y = 60 + col * 300, 146 + row * 200
		local c = card(f, x, y, 280, 184)
		if Pod.sel == i then stroke(c, s[4], 3) end
		local art = frame(f, x + 16, y + 16, 72, 72, s[4], 0, px(16))
		gradient(art, s[4], s[4]:Lerp(Color3.new(0, 0, 0), 0.35), 90)
		label(art, s[1]:sub(1, 1), 0, 0, 72, 72, 40, WHITE, Enum.Font.GothamBold)
		label(f, s[1], x + 16, y + 96, 248, 30, 22, WHITE, Enum.Font.GothamBold, Enum.TextXAlignment.Left)
		label(f, s[2], x + 16, y + 128, 248, 24, 16, GRAY, Enum.Font.GothamMedium, Enum.TextXAlignment.Left)
		p.region(x, y, 280, 184, function()
			if Pod.sel ~= i then Pod.prog = 0 end
			Pod.sel = i
			Pod.playing = true
			Pod.render()
		end)
	end
	card(f, 60, 548, 880, 108)
	if Pod.sel then
		local s = SHOWS[Pod.sel]
		local art = frame(f, 76, 564, 76, 76, s[4], 0, px(16))
		gradient(art, s[4], s[4]:Lerp(Color3.new(0, 0, 0), 0.35), 90)
		label(art, s[1]:sub(1, 1), 0, 0, 76, 76, 40, WHITE, Enum.Font.GothamBold)
		label(f, s[1], 170, 562, 560, 34, 24, WHITE, Enum.Font.GothamBold, Enum.TextXAlignment.Left)
		label(f, "Episode 24  -  Demo", 170, 596, 560, 24, 17, GRAY, Enum.Font.GothamMedium, Enum.TextXAlignment.Left)
		local track = frame(f, 170, 632, 560, 8, Color3.fromRGB(80, 80, 94), 0, FULL)
		Pod.fill = frame(track, 0, 0, 560 * Pod.prog, 8, WHITE, 0, FULL)
		frame(f, 780, 586, 140, 44, BLUE, 0, px(22))
		label(f, Pod.playing and "Pause" or "Play", 780, 586, 140, 44, 18, WHITE, Enum.Font.GothamBold)
		p.region(780, 586, 140, 44, function()
			Pod.playing = not Pod.playing
			Pod.render()
		end)
	else
		label(f, "Pick a show to start listening", 60, 548, 880, 108, 22, GRAY, Enum.Font.GothamMedium)
	end
end
Pod.tap = Pod.page.tap

---------------------------------------------------------------- CONTROL CENTER
local ccF = frame(root, 0, 0, CW, CH, Color3.new(0, 0, 0), 1)
ccF.ZIndex = 9
ccF.Visible = false
local ccPanel = frame(ccF, 0, 0, CW, CH, WHITE, 1)
local ccToast = frame(ccF, 330, 54, 340, 42, Color3.fromRGB(34, 34, 44), 0.1, FULL)
ccToast.Visible = false
local ccToastLbl = label(ccToast, "", 0, 0, 340, 42, 18, WHITE, Enum.Font.GothamBold)
local ccToastToken = 0
local cc = { regions = {}, sliders = {}, grab = nil }
local ccState = { airdrop = false, rotlock = false, dnd = false, silent = false, torch = false, rec = false, music = false }
local CCX, CCY = 706, 60
local CC_DARK = Color3.fromRGB(34, 34, 46)
local CC_OFF = Color3.fromRGB(70, 70, 86)
local CC_TILE = Color3.fromRGB(44, 44, 58)

local function ccShowToast(text)
	ccToastLbl.Text = text
	ccToast.Visible = true
	ccToastToken = ccToastToken + 1
	local my = ccToastToken
	task.delay(1.6, function()
		if ccToastToken == my then ccToast.Visible = false end
	end)
end

ccRender = function()
	ccPanel:ClearAllChildren()
	cc.regions, cc.sliders = {}, {}
	local function reg(x, y, w, h, fn) table.insert(cc.regions, { x, y, w, h, fn }) end
	local function cell(c, r) return CCX + c * 66, CCY + r * 66 end
	local function toggle(key, name)
		ccState[key] = not ccState[key]
		ccRender()
		ccShowToast(name .. ": " .. (ccState[key] and "On" or "Off"))
	end

	local x0, y0 = cell(0, 0)
	frame(ccPanel, x0, y0, 124, 124, CC_DARK, 0.08, px(30))
	local conn = {
		{ "airplane", 31, 31, airplane, Color3.fromRGB(255, 149, 0), function()
			airplane = not airplane
			if airplane then
				btOn = false
				for _, d in ipairs(BT_DEVICES) do d.on = false end
				setWifi(false)
			else
				ccRender()
			end
		end },
		{ "airdrop", 93, 31, ccState.airdrop, BLUE, function() toggle("airdrop", "AirDrop") end },
		{ "wifi", 31, 93, wifiOn, BLUE, function() setWifi(not wifiOn) end },
		{ "bluetooth", 93, 93, btOn, BLUE, function()
			btOn = not btOn
			if btOn then
				airplane = false
			else
				for _, d in ipairs(BT_DEVICES) do d.on = false end
			end
			ccRender()
		end },
	}
	for _, b in ipairs(conn) do
		local cx, cy = x0 + b[2], y0 + b[3]
		local col = b[4] and b[5] or CC_OFF
		local c = frame(ccPanel, cx - 26, cy - 26, 52, 52, col, 0, FULL)
		glyph(c, b[1], 26, 26, 30, WHITE, col)
		reg(cx - 30, cy - 30, 60, 60, b[6])
	end

	local mx, my = cell(2, 0)
	frame(ccPanel, mx, my, 124, 124, CC_DARK, 0.08, px(30))
	label(ccPanel, "Music", mx, my + 12, 124, 24, 16, WHITE, Enum.Font.GothamBold)
	label(ccPanel, ccState.music and "Playing" or "Not Playing", mx, my + 34, 124, 20, 12, GRAY, Enum.Font.GothamMedium)
	local py = my + 88
	local ctl = Color3.fromRGB(200, 200, 210)
	triShape(ccPanel, 1, "l", mx + 14, py - 9, 18, ctl)
	triShape(ccPanel, 1, "l", mx + 23, py - 9, 18, ctl)
	if ccState.music then
		shape(ccPanel, 1, mx + 56, py, 8, 28, WHITE, 0, 0.3)
		shape(ccPanel, 1, mx + 70, py, 8, 28, WHITE, 0, 0.3)
	else
		triShape(ccPanel, 1, "r", mx + 54, py - 14, 28, WHITE)
	end
	triShape(ccPanel, 1, "r", mx + 94, py - 9, 18, ctl)
	triShape(ccPanel, 1, "r", mx + 103, py - 9, 18, ctl)
	reg(mx + 4, py - 24, 44, 48, function() ccShowToast("Previous track (demo)") end)
	reg(mx + 46, py - 24, 40, 48, function()
		ccState.music = not ccState.music
		ccRender()
	end)
	reg(mx + 86, py - 24, 36, 48, function() ccShowToast("Next track (demo)") end)

	local bx, by = cell(2, 2)
	for i = 1, 2 do
		local sx = bx + (i - 1) * 66
		local frac = (i == 1) and ((brightness - 0.1) / 0.9) or (vol / 16)
		frame(ccPanel, sx, by, 58, 124, CC_OFF, 0.05, px(22))
		local fh = math.floor(124 * frac)
		local fill = frame(ccPanel, sx, by + 124 - fh, 58, fh, Color3.fromRGB(236, 236, 244), 0, px(22))
		local gc = (frac > 0.2) and Color3.fromRGB(70, 70, 84) or WHITE
		glyph(ccPanel, (i == 1) and "sun" or "speaker", sx + 29, by + 124 - 24, 28, gc, Color3.fromRGB(236, 236, 244))
		cc.sliders[i] = { x = sx, y = by, w = 58, h = 124, fill = fill, id = (i == 1) and "bright" or "vol" }
	end

	local function small(col, row, name, on, onColor, glyphOn, fn)
		local x, y = cell(col, row)
		local bg = on and onColor or CC_TILE
		frame(ccPanel, x, y, 58, 58, bg, 0.08, px(18))
		glyph(ccPanel, name, x + 29, y + 29, 30, (on and glyphOn) or WHITE, bg)
		reg(x, y, 58, 58, fn)
	end
	small(0, 2, "rotlock", ccState.rotlock, Color3.fromRGB(255, 69, 58), WHITE, function() toggle("rotlock", "Orientation Lock") end)
	small(1, 2, "moon", ccState.dnd, Color3.fromRGB(94, 92, 230), WHITE, function() toggle("dnd", "Do Not Disturb") end)

	local sx0, sy0 = cell(0, 3)
	frame(ccPanel, sx0, sy0, 124, 58, CC_DARK, 0.08, px(18))
	glyph(ccPanel, "mirror", sx0 + 28, sy0 + 29, 30, WHITE, CC_DARK)
	label(ccPanel, "Screen\nMirroring", sx0 + 50, sy0, 70, 58, 13, WHITE, Enum.Font.GothamBold, Enum.TextXAlignment.Left)
	reg(sx0, sy0, 124, 58, function() ccShowToast("Screen Mirroring: no devices found") end)

	small(0, 4, "bell", ccState.silent, Color3.fromRGB(255, 69, 58), WHITE, function() toggle("silent", "Silent Mode") end)
	small(1, 4, "torch", ccState.torch, Color3.fromRGB(240, 240, 248), Color3.fromRGB(30, 30, 40), function()
		toggle("torch", "Flashlight")
		setTorch(ccState.torch)
	end)
	small(2, 4, "timer", false, CC_TILE, WHITE, function() ccShowToast("Timer (demo)") end)
	small(3, 4, "camera", false, CC_TILE, WHITE, function() ccShowToast("Camera (demo)") end)
	small(0, 5, "record", ccState.rec, Color3.fromRGB(255, 69, 58), WHITE, function() toggle("rec", "Screen Recording") end)
	small(1, 5, "stopwatch", false, CC_TILE, WHITE, function() ccShowToast("Stopwatch (demo)") end)
end

local function ccPress(x, y)
	for _, sl in ipairs(cc.sliders) do
		if inRect(x, y, sl.x - 4, sl.y - 4, sl.w + 8, sl.h + 8) then
			cc.grab = sl
			return true
		end
	end
	return false
end

local function ccDrag(x, y)
	local sl = cc.grab
	if not sl then return end
	local frac = math.clamp(1 - (y - sl.y) / sl.h, 0, 1)
	local fh = math.floor(sl.h * frac)
	sl.fill.Position = UDim2.fromOffset(sl.x, sl.y + sl.h - fh)
	sl.fill.Size = UDim2.fromOffset(sl.w, fh)
	if sl.id == "bright" then
		brightness = 0.1 + 0.9 * frac
		applyBrightness()
	else
		vol = math.floor(frac * 16 + 0.5)
	end
end

local function ccRelease()
	cc.grab = nil
end

local function ccFollow(p)
	if not ccF.Visible then
		ccRender()
		ccF.Visible = true
	end
	ccPanel.Position = UDim2.fromOffset(0, -460 * (1 - p))
	ccF.BackgroundTransparency = 1 - 0.45 * p
end

openCC = function(follow)
	ccOpen = true
	if not follow then
		ccRender()
		ccF.Visible = true
		ccPanel.Position = UDim2.fromOffset(0, -460)
		ccF.BackgroundTransparency = 1
	end
	tw(ccPanel, 0.28, { Position = UDim2.fromOffset(0, 0) }, Enum.EasingStyle.Quint)
	tw(ccF, 0.28, { BackgroundTransparency = 0.55 })
end

closeCC = function(instant)
	if not ccOpen and not ccF.Visible then return end
	ccOpen = false
	cc.grab = nil
	if instant then
		ccF.Visible = false
		ccF.BackgroundTransparency = 1
		ccToast.Visible = false
		return
	end
	tw(ccPanel, 0.25, { Position = UDim2.fromOffset(0, -460) }, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
	tw(ccF, 0.25, { BackgroundTransparency = 1 })
	task.delay(0.27, function()
		if not ccOpen then ccF.Visible = false end
	end)
end

local function ccTap(x, y)
	for i = #cc.regions, 1, -1 do
		local r = cc.regions[i]
		if inRect(x, y, r[1], r[2], r[3], r[4]) then
			r[5]()
			return
		end
	end
	if not inRect(x, y, CCX - 16, CCY - 8, 288, 412) then closeCC() end
end

---------------------------------------------------------------- navigation
local homeBtns, homeBtnPos = {}, {}

local function press(sc)
	sc.Scale = 0.86
	tw(sc, 0.35, { Scale = 1 }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
end

layoutHome = function()
	iconsF:ClearAllChildren()
	homeBtns, homeBtnPos = {}, {}
	for i, id in ipairs(homeApps) do
		local d = DEFS[id]
		local col, row = (i - 1) % 6, math.floor((i - 1) / 6)
		local cx, cy, size = 1000 * (col + 0.5) / 6, 150 + row * 165, 86
		local c = frame(iconsF, cx - size / 2, cy - size / 2, size, size, WHITE, 1)
		local sc = Instance.new("UIScale")
		sc.Parent = c
		drawIcon(c, id, 0, 0, size)
		label(c, d.name, -20, size + 4, size + 40, 22, 18, WHITE, Enum.Font.GothamMedium)
		table.insert(homeBtns, { x = cx - size / 2 - 8, y = cy - size / 2 - 6, w = size + 16, h = size + 34, id = id, scale = sc })
		homeBtnPos[id] = { cx, cy }
	end
end

getApp = function()
	if not curId then return nil end
	if apps[curId] then return apps[curId] end
	if EXTRA[curId] then
		demoApp.def = EXTRA[curId]
		return demoApp
	end
	return nil
end

showApp = function(id)
	curId = id
	local a = getApp()
	if not a then return end
	for _, pf in ipairs(pageFrames) do pf.Visible = false end
	kbApp.frame.Visible = false
	a.page.frame.Visible = true
	if a.onShow then a.onShow() end
	a.render()
end

openApp = function(id)
	if state == "app" then
		showApp(id)
		return
	end
	state = "app"
	showApp(id)
	local pos = homeBtnPos[id] or { 500, 350 }
	appF.Position = UDim2.fromOffset(pos[1], pos[2])
	appScale.Scale = 0.09
	appF.Visible = true
	tw(appF, 0.38, { Position = UDim2.fromOffset(500, 350) }, Enum.EasingStyle.Quint)
	tw(appScale, 0.38, { Scale = 1 }, Enum.EasingStyle.Quint)
	tw(homeScale, 0.38, { Scale = 0.92 }, Enum.EasingStyle.Quint)
end

closeApp = function()
	if state ~= "app" then return end
	state = "home"
	kbApp.frame.Visible = false
	local pos = homeBtnPos[curId] or { 500, 350 }
	tw(appF, 0.3, { Position = UDim2.fromOffset(pos[1], pos[2]) }, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
	tw(appScale, 0.3, { Scale = 0.09 }, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
	tw(homeScale, 0.3, { Scale = 1 }, Enum.EasingStyle.Quint)
	task.delay(0.32, function()
		if state ~= "app" then appF.Visible = false end
	end)
end

unlock = function()
	state = "home"
	tw(lockF, 0.35, { Position = UDim2.fromScale(0, -1) })
	task.delay(0.36, function()
		if state ~= "lock" then lockF.Visible = false end
	end)
end

lockNow = function(instant)
	closeCC(true)
	pwF.Visible = false
	pwOpen = false
	closeSiri()
	appF.Visible = false
	appScale.Scale = 1
	homeScale.Scale = 1
	kbApp.frame.Visible = false
	state = "lock"
	curId = nil
	lockF.Visible = true
	if instant then
		lockF.Position = UDim2.fromScale(0, 0)
	else
		lockF.Position = UDim2.fromScale(0, -1)
		tw(lockF, 0.35, { Position = UDim2.fromScale(0, 0) })
	end
end

local function sleepScreen()
	if screenOff then return end
	screenOff = true
	offF.Visible = true
	offF.BackgroundTransparency = 1
	tw(offF, 0.3, { BackgroundTransparency = 0 })
	task.delay(0.32, function()
		if screenOff then lockNow(true) end
	end)
end

local function wakeScreen()
	if not screenOff then return end
	screenOff = false
	lockNow(true)
	tw(offF, 0.35, { BackgroundTransparency = 1 })
	task.delay(0.37, function()
		if not screenOff then offF.Visible = false end
	end)
end

---------------------------------------------------------------- spring
local sp = { x = 0, y = 0, z = 0, rx = 0, ry = 0, xv = 0, yv = 0, zv = 0, rxv = 0, ryv = 0 }

local function bounce(u, v)
	sp.zv = sp.zv - 1.1
	sp.rxv = sp.rxv + (v - 0.5) * 1.5
	sp.ryv = sp.ryv + (u - 0.5) * 1.5
end

---------------------------------------------------------------- taps
local function openSettingsWifi()
	S.sel = "wifi"
	if state == "app" and curId == "settings" then
		S.render()
	else
		openApp("settings")
	end
end

local function handleTap(u, v)
	if screenOff then return end
	local x, y = u * CW, v * CH

	if siriOpen then
		siriTap(x, y)
		return
	end
	if pwOpen then
		pwTap(x, y)
		return
	end
	if ccOpen then
		ccTap(x, y)
		return
	end

	if state == "home" then
		if inRect(x, y, 430, 4, 140, 36) then
			lockNow(false)
			return
		end
		if inRect(x, y, 806, 2, 60, 38) then
			openSettingsWifi()
			return
		end
		for _, b in ipairs(homeBtns) do
			if inRect(x, y, b.x, b.y, b.w, b.h) then
				press(b.scale)
				task.delay(0.12, function()
					if state == "home" then openApp(b.id) end
				end)
				return
			end
		end

	elseif state == "app" then
		if inRect(x, y, 430, 4, 140, 36) then
			closeApp()
			return
		end
		if inRect(x, y, 806, 2, 60, 38) then
			openSettingsWifi()
			return
		end
		local a = getApp()
		if a and a.tap then a.tap(x, y) end
	end
end

---------------------------------------------------------------- side buttons
local function rayBox(o, d, bmin, bmax)
	local tmin, tmax = 0, math.huge
	for _, ax in ipairs({ "X", "Y", "Z" }) do
		local oo, dd = o[ax], d[ax]
		if math.abs(dd) < 1e-6 then
			if oo < bmin[ax] or oo > bmax[ax] then return nil end
		else
			local t1, t2 = (bmin[ax] - oo) / dd, (bmax[ax] - oo) / dd
			if t1 > t2 then t1, t2 = t2, t1 end
			tmin = math.max(tmin, t1)
			tmax = math.min(tmax, t2)
			if tmin > tmax then return nil end
		end
	end
	return tmin
end

local PAD = Vector3.new(0.13, 0.13, 0.2)
local function hitSide(pos)
	local ray = camera:ScreenPointToRay(pos.X, pos.Y)
	local cf = model.PrimaryPart.CFrame
	local o = cf:PointToObjectSpace(ray.Origin)
	local d = cf:VectorToObjectSpace(ray.Direction)
	local best, bestT = nil, math.huge
	for _, b in ipairs(SIDE_BTNS) do
		local half = b.size / 2 + PAD
		local t = rayBox(o, d, b.center - half, b.center + half)
		if t and t < bestT then
			best, bestT = b.name, t
		end
	end
	return best
end

local function nudge(part, dir)
	part.CFrame = part.CFrame * CFrame.new(dir)
	task.delay(0.09, function()
		part.CFrame = part.CFrame * CFrame.new(-dir)
	end)
end

local function sideAction(name)
	sp.zv = sp.zv - 0.7
	if name == "power" then
		nudge(powerPart, Vector3.new(0, -0.02, 0))
		if screenOff then wakeScreen() else sleepScreen() end
	elseif name == "volup" then
		nudge(volUpPart, Vector3.new(-0.02, 0, 0))
		changeVolume(1)
	elseif name == "voldown" then
		nudge(volDownPart, Vector3.new(-0.02, 0, 0))
		changeVolume(-1)
	end
end

---------------------------------------------------------------- input
local function screenUV(pos)
	local ray = camera:ScreenPointToRay(pos.X, pos.Y)
	local cf = screen.CFrame
	local n = -cf.LookVector
	local denom = ray.Direction:Dot(n)
	if denom > -1e-4 then return nil end
	local p0 = cf:PointToWorldSpace(Vector3.new(0, 0, 0.003))
	local t = (p0 - ray.Origin):Dot(n) / denom
	if t < 0 then return nil end
	local lp = cf:PointToObjectSpace(ray.Origin + ray.Direction * t)
	return lp.X / SW + 0.5, 0.5 - lp.Y / SH
end

local drag = { active = false }

local function startDrag(input, ty, u, v)
	drag = {
		active = true, input = input, type = ty, su = u, sv = v, u = u, v = v,
		moved = false, mode = "tap", t0 = os.clock(),
	}
	if not screenOff and not siriOpen and not pwOpen then
		if ccOpen then
			drag.mode = "cc"
			if ccPress(u * CW, v * CH) then drag.mode = "ccdrag" end
		elseif u * CW >= 690 and v * CH <= 55 then
			drag.mode = "ccopen"
		elseif state == "lock" then
			drag.mode = "unlock"
		elseif (state == "app" and v > 0.9) or (state == "home" and v > 0.94) then
			drag.mode = "bottom"
		elseif state == "app" then
			local a = getApp()
			if a and a.onPress and a.onPress(u * CW, v * CH) then drag.mode = "appdrag" end
		end
	end
	bounce(u, v)
	if not screenOff then ripple(u, v) end
end

local function moveDrag(u, v)
	drag.u, drag.v = u, v
	if math.abs(v - drag.sv) > 0.03 or math.abs(u - drag.su) > 0.03 then drag.moved = true end
	if drag.mode == "unlock" then
		lockF.Position = UDim2.fromScale(0, -math.clamp(drag.sv - v, 0, 1))
	elseif drag.mode == "ccopen" then
		local p = math.clamp((v - drag.sv) / 0.2, 0, 1)
		if p > 0.02 then ccFollow(p) end
	elseif drag.mode == "ccdrag" then
		ccDrag(u * CW, v * CH)
	elseif drag.mode == "bottom" and state == "app" then
		appScale.Scale = 1 - math.clamp(drag.sv - v, 0, 0.6) * 0.35
	elseif drag.mode == "appdrag" then
		local a = getApp()
		if a and a.onDrag then a.onDrag(u * CW, v * CH) end
	end
end

local function endDrag()
	local d = drag
	drag = { active = false }
	if d.mode == "side" then return end
	if d.mode == "ccdrag" then
		ccRelease()
		return
	end
	if d.mode == "cc" then
		if (d.sv - d.v) > 0.06 then
			closeCC()
		elseif not d.moved then
			handleTap(d.su, d.sv)
		end
		return
	end
	if d.mode == "ccopen" then
		local p = math.clamp((d.v - d.sv) / 0.2, 0, 1)
		if p > 0.35 then
			openCC(true)
		elseif ccF.Visible then
			closeCC()
		elseif not d.moved then
			handleTap(d.su, d.sv)
		end
		return
	end
	if d.mode == "appdrag" then
		local a = getApp()
		if a and a.onRelease then a.onRelease() end
		return
	end
	local p = d.sv - d.v
	if d.mode == "unlock" then
		local fast = p > 0.12 and (os.clock() - d.t0) < 0.35
		if p > 0.3 or fast then
			unlock()
		else
			tw(lockF, 0.3, { Position = UDim2.fromScale(0, 0) }, Enum.EasingStyle.Back)
		end
	elseif d.mode == "bottom" then
		if d.siriDone then
			tw(appScale, 0.25, { Scale = 1 }, Enum.EasingStyle.Back)
		elseif state == "app" and p > 0.08 then
			closeApp()
		else
			tw(appScale, 0.25, { Scale = 1 }, Enum.EasingStyle.Back)
		end
	elseif not d.moved then
		handleTap(d.su, d.sv)
	end
end

local PASS, SINK = Enum.ContextActionResult.Pass, Enum.ContextActionResult.Sink

local function onInput(_, st, input)
	if not shown then return PASS end
	local ty = input.UserInputType

	if ty == Enum.UserInputType.MouseMovement then
		if drag.active and drag.type == Enum.UserInputType.MouseButton1 and drag.mode ~= "side" then
			local u, v = screenUV(input.Position)
			if u then moveDrag(u, v) end
			return SINK
		end
		return PASS
	end

	if st == Enum.UserInputState.Begin then
		if drag.active then return PASS end
		local u, v = screenUV(input.Position)
		if u and u >= 0 and u <= 1 and v >= 0 and v <= 1 then
			startDrag(input, ty, u, v)
			return SINK
		end
		local side = hitSide(input.Position)
		if side then
			drag = { active = true, input = input, type = ty, mode = "side" }
			sideAction(side)
			return SINK
		end
		return PASS
	end

	local same = drag.active and ((ty == Enum.UserInputType.Touch and input == drag.input)
		or (ty ~= Enum.UserInputType.Touch and ty == drag.type))
	if not same then return PASS end

	if st == Enum.UserInputState.Change then
		if drag.mode ~= "side" then
			local u, v = screenUV(input.Position)
			if u then moveDrag(u, v) end
		end
		return SINK
	elseif st == Enum.UserInputState.End or st == Enum.UserInputState.Cancel then
		endDrag()
		return SINK
	end
	return PASS
end

CAS:BindActionAtPriority(
	"DeltaIPadInput", onInput, false, 3000,
	Enum.UserInputType.Touch, Enum.UserInputType.MouseButton1, Enum.UserInputType.MouseMovement
)

---------------------------------------------------------------- render step
local ARM_NAMES = {
	"LeftUpperArm", "LeftLowerArm", "LeftHand", "RightUpperArm", "RightLowerArm", "RightHand",
	"Left Arm", "Right Arm",
}
local prevCam = camera.CFrame
local t0 = os.clock()

local function setShown(on)
	shown = on
	drag = { active = false }
	model.Parent = on and workspace or nil
	pcall(function()
		player.CameraMode = on and Enum.CameraMode.LockFirstPerson or Enum.CameraMode.Classic
	end)
end

RunService:BindToRenderStep("DeltaIPad", Enum.RenderPriority.Camera.Value + 2, function(dt)
	camera = workspace.CurrentCamera
	torchPart.CFrame = camera.CFrame * CFrame.new(0.5, -0.6, -1.5)
	if not shown then
		prevCam = camera.CFrame
		return
	end
	dt = math.min(dt, 1 / 30)

	local rel = prevCam:ToObjectSpace(camera.CFrame)
	local rx, ry = rel:ToEulerAnglesYXZ()
	prevCam = camera.CFrame
	sp.x = math.clamp(sp.x + ry * 0.9, -0.2, 0.2)
	sp.y = math.clamp(sp.y - rx * 0.9, -0.2, 0.2)

	for _, k in ipairs({ "x", "y", "z", "rx", "ry" }) do
		local kv = k .. "v"
		sp[kv] = sp[kv] + (-K * sp[k] - C * sp[kv]) * dt
		sp[k] = sp[k] + sp[kv] * dt
	end

	local bob = math.sin((os.clock() - t0) * 1.4) * 0.012
	model:PivotTo(
		camera.CFrame * HOLD
		* CFrame.new(sp.x, sp.y + bob, sp.z)
		* CFrame.Angles(sp.rx, sp.ry, 0)
	)

	local ch = player.Character
	if ch then
		for _, n in ipairs(ARM_NAMES) do
			local p = ch:FindFirstChild(n)
			if p and p:IsA("BasePart") then p.LocalTransparencyModifier = 1 end
		end
	end

	if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then
		UIS.MouseBehavior = Enum.MouseBehavior.Default
		UIS.MouseIconEnabled = true
	end
end)

local lastSec = -1
local dlTimer = 0
table.insert(conns, RunService.Heartbeat:Connect(function(dt)
	local ts = os.time()
	if ts ~= lastSec then
		lastSec = ts
		refreshClocks()
	end

	if state == "lock" and lockF.Visible and not drag.active and not screenOff then
		hint.TextTransparency = 0.15 + 0.4 * (0.5 + 0.5 * math.sin(os.clock() * 2.4))
	end

	if siriOpen then
		orbG.Rotation = (os.clock() * 140) % 360
		local s = 120 + 8 * math.sin(os.clock() * 4)
		orb.Size = UDim2.fromOffset(s, s)
	end

	if drag.active and drag.mode == "bottom" and not drag.moved and not drag.siriDone
		and siriOn and siriHold and (os.clock() - drag.t0) > 0.6 then
		drag.siriDone = true
		openSiri()
	end

	if Pod.playing and Pod.sel then
		Pod.prog = math.min(1, Pod.prog + dt / 240)
		if Pod.fill and state == "app" and curId == "podcasts" then
			Pod.fill.Size = UDim2.fromOffset(560 * Pod.prog, 8)
		end
	end

	if not connected then
		if next(downloading) then
			for k in pairs(downloading) do downloading[k] = nil end
			if state == "app" and curId == "appstore" then AS.render() end
		end
	else
		local any = false
		for id, pr in pairs(downloading) do
			any = true
			local np = pr + dt / 2.2
			if np >= 1 then
				downloading[id] = nil
				installed[id] = true
				table.insert(homeApps, id)
				layoutHome()
			else
				downloading[id] = np
			end
		end
		if any then
			dlTimer = dlTimer + dt
			if dlTimer > 0.1 or not next(downloading) then
				dlTimer = dlTimer = 0
				if state == "app" and curId == "appstore" then AS.render() end
			end
		end
	end
end))

---------------------------------------------------------------- toggle button
local sg = Instance.new("ScreenGui")
sg.Name = "DeltaIPadToggle"
sg.ResetOnSpawn = false
sg.DisplayOrder = 50
local tb = Instance.new("TextButton")
tb.AnchorPoint = Vector2.new(1, 0)
tb.Position = UDim2.new(1, -12, 0, 56)
tb.Size = UDim2.fromOffset(56, 34)
tb.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
tb.BackgroundTransparency = 0.3
tb.Text = "iPad"
tb.TextColor3 = WHITE
tb.TextSize = 16
tb.Font = Enum.Font.GothamBold
tb.Parent = sg
local tc = Instance.new("UICorner")
tc.CornerRadius = px(10)
tc.Parent = tb
table.insert(conns, tb.Activated:Connect(function()
	setShown(not shown)
end))
sg.Parent = player:WaitForChild("PlayerGui")

---------------------------------------------------------------- init
layoutHome()
refreshClocks()
applyBrightness()
onNetChanged()
model:PivotTo(camera.CFrame * HOLD)
setShown(true)

env.__DeltaIPadCleanup = function()
	pcall(function() RunService:UnbindFromRenderStep("DeltaIPad") end)
	pcall(function() CAS:UnbindAction("DeltaIPadInput") end)
	for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end
	pcall(function() model:Destroy() end)
	pcall(function() torchPart:Destroy() end)
	pcall(function() sg:Destroy() end)
	pcall(function() player.CameraMode = Enum.CameraMode.Classic end)
end
