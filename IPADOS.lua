--[[
	NOOB HANDS iPAD  |  Client-side LocalScript (Delta compatible)
	- "iPad" item appears in your hotbar (equip = open, unequip = close)
	- Button at the top of your screen also opens/closes it
	- Landscape iPad: camera left, home button right, volume + power on the top edge
	- Classic lock screen: clock, date, battery, "slide to unlock"
	- Noob hands reach up from the bottom of your screen to wherever you tap
	- Apps: Clock, Calculator, Notes, Settings, Safari, Music, Photos, Camera
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local GuiService = game:GetService("GuiService")

local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

---------------------------------------------------------------------
-- CLEANUP (so you can re-execute safely)
---------------------------------------------------------------------
for _, n in ipairs({"NoobIPad_UI", "NoobIPad_Hands"}) do
	local o = PlayerGui:FindFirstChild(n)
	if o then o:Destroy() end
end
do
	local bp = player:FindFirstChildOfClass("Backpack")
	if bp then
		local t = bp:FindFirstChild("iPad")
		if t then t:Destroy() end
	end
	if player.Character then
		local t = player.Character:FindFirstChild("iPad")
		if t then t:Destroy() end
	end
end

---------------------------------------------------------------------
-- HELPERS
---------------------------------------------------------------------
local WHITE = Color3.new(1, 1, 1)
local BLACK = Color3.new(0, 0, 0)
local DARK = Color3.fromRGB(30, 30, 34)
local SKIN = Color3.fromRGB(245, 205, 48)
local NOOB_BLUE = Color3.fromRGB(13, 105, 172)
local OUTLINE = Color3.fromRGB(35, 35, 35)

local function mk(class, props, parent)
	local o = Instance.new(class)
	if o:IsA("GuiObject") then o.BorderSizePixel = 0 end
	for k, v in pairs(props) do o[k] = v end
	o.Parent = parent
	return o
end

local function corner(o, r)
	return mk("UICorner", {CornerRadius = r}, o)
end

local function stroke(o, c, t, tr)
	return mk("UIStroke", {Color = c, Thickness = t, Transparency = tr or 0, ApplyStrokeMode = Enum.ApplyStrokeMode.Border}, o)
end

local function text(parent, props)
	local p = {
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamMedium,
		TextColor3 = WHITE,
		TextScaled = true,
		Text = "",
	}
	for k, v in pairs(props) do p[k] = v end
	return mk("TextLabel", p, parent)
end

local function btn(parent, props)
	local p = {
		AutoButtonColor = false,
		Text = "",
		Font = Enum.Font.GothamMedium,
		TextColor3 = WHITE,
		TextScaled = true,
		BackgroundColor3 = Color3.fromRGB(60, 60, 64),
	}
	for k, v in pairs(props) do p[k] = v end
	return mk("TextButton", p, parent)
end

---------------------------------------------------------------------
-- STATE
---------------------------------------------------------------------
local isOpen = false
local locked = true
local asleep = false
local currentApp = nil
local battery = 100
local volume = 8 -- 0..16
local brightness = 1
local wallIdx = 1
local noteText = ""
local clockBig, clockDate = nil, nil
local tool = nil
local openApp, closeApp, lock, unlock

---------------------------------------------------------------------
-- ROOT GUIS
---------------------------------------------------------------------
local gui = mk("ScreenGui", {
	Name = "NoobIPad_UI",
	ResetOnSpawn = false,
	IgnoreGuiInset = true,
	DisplayOrder = 50,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, PlayerGui)

local handsGui = mk("ScreenGui", {
	Name = "NoobIPad_Hands",
	ResetOnSpawn = false,
	IgnoreGuiInset = true,
	DisplayOrder = 51,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, PlayerGui)

local tapSound = mk("Sound", {SoundId = "rbxasset://sounds/switch.wav", Volume = 0.5}, gui)
local function playClick()
	pcall(function()
		tapSound.Volume = (volume / 16) * 0.8
		tapSound:Play()
	end)
end

---------------------------------------------------------------------
-- iPAD BODY (matches the picture: black bezel, silver rim)
---------------------------------------------------------------------
local OPEN_POS = UDim2.fromScale(0.5, 0.52)
local CLOSED_POS = UDim2.fromScale(0.5, 1.7)

local ipad = mk("Frame", {
	Name = "iPad",
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = CLOSED_POS,
	Size = UDim2.fromScale(0.84, 0.78),
	BackgroundColor3 = Color3.fromRGB(16, 16, 18),
	Active = true,
	Visible = false,
}, gui)
mk("UIAspectRatioConstraint", {AspectRatio = 500 / 353}, ipad)
corner(ipad, UDim.new(0.045, 0))
stroke(ipad, Color3.fromRGB(125, 127, 133), 2)

-- front camera (left)
local cam = mk("Frame", {
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.048, 0.507),
	Size = UDim2.fromScale(0.014, 0.02),
	BackgroundColor3 = Color3.fromRGB(32, 34, 46),
}, ipad)
corner(cam, UDim.new(0.5, 0))
stroke(cam, Color3.fromRGB(70, 72, 80), 1)

-- screen
local screen = mk("Frame", {
	Name = "Screen",
	Position = UDim2.fromScale(0.086, 0.062),
	Size = UDim2.fromScale(0.828, 0.878),
	BackgroundColor3 = Color3.fromRGB(34, 34, 34),
	ClipsDescendants = true,
}, ipad)
corner(screen, UDim.new(0.012, 0))

-- home button (right)
local homeBtn = btn(ipad, {
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.96, 0.5),
	Size = UDim2.fromScale(0.05, 0.071),
	BackgroundColor3 = Color3.fromRGB(10, 10, 12),
})
corner(homeBtn, UDim.new(0.5, 0))
stroke(homeBtn, Color3.fromRGB(105, 107, 113), 1.5)
local homeIcon = mk("Frame", {
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromScale(0.34, 0.34),
	BackgroundTransparency = 1,
}, homeBtn)
corner(homeIcon, UDim.new(0.25, 0))
stroke(homeIcon, Color3.fromRGB(80, 82, 88), 1)

-- top-edge buttons (power on the left, volume on the right)
local function sideButton(x, w, onPress)
	local hit = btn(ipad, {
		Position = UDim2.fromScale(x, -0.07),
		Size = UDim2.fromScale(w, 0.075),
		BackgroundTransparency = 1,
	})
	local bar = mk("Frame", {
		Position = UDim2.fromScale(0, 0.55),
		Size = UDim2.fromScale(1, 0.45),
		BackgroundColor3 = Color3.fromRGB(150, 152, 158),
	}, hit)
	corner(bar, UDim.new(0.35, 0))
	hit.MouseButton1Down:Connect(function() bar.BackgroundColor3 = Color3.fromRGB(95, 97, 103) end)
	hit.MouseButton1Up:Connect(function() bar.BackgroundColor3 = Color3.fromRGB(150, 152, 158) end)
	hit.MouseLeave:Connect(function() bar.BackgroundColor3 = Color3.fromRGB(150, 152, 158) end)
	hit.Activated:Connect(onPress)
	return hit
end

---------------------------------------------------------------------
-- SCREEN LAYERS
---------------------------------------------------------------------
local WALLPAPERS = {
	{Color3.fromRGB(20, 40, 110), Color3.fromRGB(90, 50, 160), Color3.fromRGB(235, 110, 120)},
	{Color3.fromRGB(10, 70, 90), Color3.fromRGB(20, 140, 150), Color3.fromRGB(190, 235, 200)},
	{Color3.fromRGB(30, 30, 40), Color3.fromRGB(70, 70, 100), Color3.fromRGB(150, 150, 190)},
	{Color3.fromRGB(190, 60, 30), Color3.fromRGB(240, 150, 40), Color3.fromRGB(255, 225, 120)},
}

local wall = mk("Frame", {Size = UDim2.fromScale(1, 1), BackgroundColor3 = WHITE, ZIndex = 1}, screen)
local wallGrad = mk("UIGradient", {Rotation = 70}, wall)
local function applyWallpaper()
	local w = WALLPAPERS[wallIdx]
	wallGrad.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, w[1]),
		ColorSequenceKeypoint.new(0.5, w[2]),
		ColorSequenceKeypoint.new(1, w[3]),
	})
end
applyWallpaper()

local homeFrame = mk("Frame", {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ZIndex = 2}, screen)
local lockFrame = mk("Frame", {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ZIndex = 3}, screen)
local appFrame = mk("Frame", {Size = UDim2.fromScale(1, 1), BackgroundColor3 = BLACK, ZIndex = 4, Visible = false}, screen)

---------------------------------------------------------------------
-- STATUS BAR (iPad  wifi | time | battery)
---------------------------------------------------------------------
local statusBar = mk("Frame", {Size = UDim2.fromScale(1, 0.075), BackgroundTransparency = 1, ZIndex = 6}, screen)
local sbLeft = text(statusBar, {
	Text = "iPad  📶",
	Size = UDim2.fromScale(0.22, 0.75),
	Position = UDim2.fromScale(0.015, 0.125),
	TextXAlignment = Enum.TextXAlignment.Left,
})
local sbTime = text(statusBar, {
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromScale(0.3, 0.75),
	Font = Enum.Font.GothamBold,
})
local sbRight = mk("Frame", {
	AnchorPoint = Vector2.new(1, 0.5),
	Position = UDim2.fromScale(0.985, 0.5),
	Size = UDim2.fromScale(0.25, 0.75),
	BackgroundTransparency = 1,
}, statusBar)
mk("UIListLayout", {
	FillDirection = Enum.FillDirection.Horizontal,
	HorizontalAlignment = Enum.HorizontalAlignment.Right,
	VerticalAlignment = Enum.VerticalAlignment.Center,
	Padding = UDim.new(0, 3),
	SortOrder = Enum.SortOrder.LayoutOrder,
}, sbRight)
local sbPct = text(sbRight, {Size = UDim2.fromScale(0.4, 1), LayoutOrder = 1, TextXAlignment = Enum.TextXAlignment.Right, Text = "100%"})
local batBody = mk("Frame", {Size = UDim2.fromScale(0.3, 0.62), LayoutOrder = 2, BackgroundTransparency = 1}, sbRight)
corner(batBody, UDim.new(0.25, 0))
local batStroke = stroke(batBody, WHITE, 1, 0.2)
local batFill = mk("Frame", {
	Position = UDim2.fromScale(0.06, 0.14),
	Size = UDim2.fromScale(0.88, 0.72),
	BackgroundColor3 = Color3.fromRGB(80, 220, 110),
}, batBody)
corner(batFill, UDim.new(0.2, 0))
local batNub = mk("Frame", {Size = UDim2.fromScale(0.035, 0.28), LayoutOrder = 3, BackgroundColor3 = WHITE}, sbRight)
corner(batNub, UDim.new(0.3, 0))

local function setStatusColor(c)
	sbLeft.TextColor3 = c
	sbTime.TextColor3 = c
	sbPct.TextColor3 = c
	batStroke.Color = c
	batNub.BackgroundColor3 = c
end

local function updateBattery()
	local b = math.floor(battery + 0.5)
	sbPct.Text = b .. "%"
	batFill.Size = UDim2.fromScale(0.88 * battery / 100, 0.72)
	batFill.BackgroundColor3 = (b <= 20) and Color3.fromRGB(235, 70, 60) or Color3.fromRGB(80, 220, 110)
end
updateBattery()

---------------------------------------------------------------------
-- LOCK SCREEN (big time, date, slide to unlock)
---------------------------------------------------------------------
local lockTime = text(lockFrame, {
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.33),
	Size = UDim2.fromScale(0.45, 0.2),
	Font = Enum.Font.Gotham,
	TextStrokeTransparency = 0.9,
})
local lockDate = text(lockFrame, {
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.48),
	Size = UDim2.fromScale(0.4, 0.06),
	TextTransparency = 0.1,
})

local track = mk("Frame", {
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.86),
	Size = UDim2.fromScale(0.56, 0.12),
	BackgroundColor3 = BLACK,
	BackgroundTransparency = 0.45,
}, lockFrame)
corner(track, UDim.new(0.5, 0))
stroke(track, WHITE, 1, 0.6)
local hint = text(track, {
	Text = "slide to unlock",
	Size = UDim2.fromScale(0.58, 0.5),
	Position = UDim2.fromScale(0.34, 0.25),
	TextTransparency = 0.1,
})
local knob = btn(track, {
	AnchorPoint = Vector2.new(0, 0.5),
	BackgroundColor3 = WHITE,
	Text = "➜",
	TextColor3 = Color3.fromRGB(70, 70, 80),
	Font = Enum.Font.GothamBold,
})
corner(knob, UDim.new(0.5, 0))

local slide = 0
local function setSlide(p)
	slide = p
	local tw, kw = track.AbsoluteSize.X, knob.Size.X.Offset
	knob.Position = UDim2.new(0, 3 + p * math.max(tw - kw - 6, 0), 0.5, 0)
	hint.TextTransparency = 0.1 + p * 0.9
end
local function sizeKnob()
	local h = track.AbsoluteSize.Y
	knob.Size = UDim2.fromOffset(math.max(h * 1.5, 10), math.max(h - 6, 6))
	setSlide(slide)
end
track:GetPropertyChangedSignal("AbsoluteSize"):Connect(sizeKnob)
task.defer(sizeKnob)

local dragInput, dragStartX, dragStartSlide
knob.InputBegan:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
		dragInput = i
		dragStartX = i.Position.X
		dragStartSlide = slide
	end
end)
UIS.InputChanged:Connect(function(i)
	if dragInput and (i == dragInput or i.UserInputType == Enum.UserInputType.MouseMovement) then
		local range = math.max(track.AbsoluteSize.X - knob.Size.X.Offset - 6, 1)
		setSlide(math.clamp(dragStartSlide + (i.Position.X - dragStartX) / range, 0, 1))
	end
end)
UIS.InputEnded:Connect(function(i)
	if dragInput and (i == dragInput or (i.UserInputType == Enum.UserInputType.MouseButton1 and dragInput.UserInputType == Enum.UserInputType.MouseButton1)) then
		dragInput = nil
		if slide > 0.85 then
			setSlide(1)
			unlock()
		else
			task.spawn(function()
				while slide > 0.01 and not dragInput do
					setSlide(slide * 0.75)
					task.wait()
				end
				if not dragInput then setSlide(0) end
			end)
		end
	end
end)

---------------------------------------------------------------------
-- HOME SCREEN (icons + dock)
---------------------------------------------------------------------
local function makeIcon(parent, name, emoji, color, order, showLabel)
	local cell = mk("Frame", {BackgroundTransparency = 1, LayoutOrder = order}, parent)
	local b = btn(cell, {
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.fromScale(0.5, 0),
		Size = UDim2.fromScale(1, showLabel and 0.74 or 1),
		BackgroundColor3 = color,
		Text = emoji,
	})
	mk("UIAspectRatioConstraint", {AspectRatio = 1}, b)
	corner(b, UDim.new(0.22, 0))
	if showLabel then
		text(cell, {Text = name, Position = UDim2.fromScale(0, 0.79), Size = UDim2.fromScale(1, 0.19), Font = Enum.Font.Gotham})
	end
	b.Activated:Connect(function() openApp(name) end)
	return cell
end

local grid = mk("Frame", {Position = UDim2.fromScale(0.1, 0.14), Size = UDim2.fromScale(0.8, 0.5), BackgroundTransparency = 1}, homeFrame)
mk("UIGridLayout", {
	CellSize = UDim2.fromScale(0.2, 0.42),
	CellPadding = UDim2.fromScale(0.0667, 0.08),
	SortOrder = Enum.SortOrder.LayoutOrder,
	FillDirection = Enum.FillDirection.Horizontal,
}, grid)
makeIcon(grid, "Clock", "🕒", Color3.fromRGB(35, 35, 40), 1, true)
makeIcon(grid, "Calculator", "🧮", Color3.fromRGB(255, 149, 0), 2, true)
makeIcon(grid, "Notes", "📝", Color3.fromRGB(255, 204, 0), 3, true)
makeIcon(grid, "Settings", "⚙️", Color3.fromRGB(142, 142, 147), 4, true)

local dock = mk("Frame", {
	AnchorPoint = Vector2.new(0.5, 1),
	Position = UDim2.fromScale(0.5, 0.975),
	Size = UDim2.fromScale(0.84, 0.19),
	BackgroundColor3 = BLACK,
	BackgroundTransparency = 0.55,
}, homeFrame)
corner(dock, UDim.new(0.25, 0))
mk("UIListLayout", {
	FillDirection = Enum.FillDirection.Horizontal,
	HorizontalAlignment = Enum.HorizontalAlignment.Center,
	VerticalAlignment = Enum.VerticalAlignment.Center,
	Padding = UDim.new(0.04, 0),
	SortOrder = Enum.SortOrder.LayoutOrder,
}, dock)
local dockApps = {
	{"Safari", "🧭", Color3.fromRGB(0, 122, 255)},
	{"Music", "🎵", Color3.fromRGB(252, 60, 68)},
	{"Photos", "🌸", Color3.fromRGB(245, 245, 250)},
	{"Camera", "📷", Color3.fromRGB(110, 110, 115)},
}
for i, a in ipairs(dockApps) do
	local c = makeIcon(dock, a[1], a[2], a[3], i, false)
	c.Size = UDim2.fromScale(0.19, 0.78)
end

---------------------------------------------------------------------
-- VOLUME HUD, BRIGHTNESS DIM, SLEEP OVERLAY
---------------------------------------------------------------------
local hud = mk("Frame", {
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromScale(0.3, 0.32),
	BackgroundColor3 = Color3.fromRGB(30, 30, 32),
	BackgroundTransparency = 0.15,
	Visible = false,
	ZIndex = 8,
}, screen)
corner(hud, UDim.new(0.12, 0))
local hudIcon = text(hud, {Text = "🔊", Size = UDim2.fromScale(0.5, 0.45), Position = UDim2.fromScale(0.25, 0.12)})
local hudTrack = mk("Frame", {Position = UDim2.fromScale(0.12, 0.72), Size = UDim2.fromScale(0.76, 0.09), BackgroundColor3 = Color3.fromRGB(90, 90, 95)}, hud)
corner(hudTrack, UDim.new(0.5, 0))
local hudFill = mk("Frame", {Size = UDim2.fromScale(0.5, 1), BackgroundColor3 = WHITE}, hudTrack)
corner(hudFill, UDim.new(0.5, 0))

local hudToken = 0
local function showVolume()
	hudIcon.Text = (volume == 0) and "🔈" or "🔊"
	hudFill.Size = UDim2.fromScale(volume / 16, 1)
	hud.Visible = true
	hudToken += 1
	local t = hudToken
	task.delay(1.4, function()
		if t == hudToken then hud.Visible = false end
	end)
end

local dim = mk("Frame", {Size = UDim2.fromScale(1, 1), BackgroundColor3 = BLACK, BackgroundTransparency = 1, ZIndex = 9}, screen)
local function applyBrightness()
	dim.BackgroundTransparency = 1 - (1 - brightness) * 0.75
end

local sleepOverlay = mk("Frame", {
	Size = UDim2.fromScale(1, 1),
	BackgroundColor3 = Color3.fromRGB(34, 34, 34),
	Visible = false,
	Active = true,
	ZIndex = 10,
}, screen)

---------------------------------------------------------------------
-- APPS
---------------------------------------------------------------------
local function buildClock(p)
	clockBig = text(p, {
		Size = UDim2.fromScale(0.8, 0.3),
		Position = UDim2.fromScale(0.1, 0.25),
		Font = Enum.Font.GothamBold,
	})
	clockDate = text(p, {
		Size = UDim2.fromScale(0.6, 0.08),
		Position = UDim2.fromScale(0.2, 0.58),
		TextTransparency = 0.3,
	})
end

local function buildCalculator(p)
	local cur, acc, op, fresh = "0", nil, nil, true
	local disp = text(p, {
		Size = UDim2.fromScale(0.92, 0.2),
		Position = UDim2.fromScale(0.04, 0.02),
		Text = "0",
		TextXAlignment = Enum.TextXAlignment.Right,
		Font = Enum.Font.Gotham,
	})
	local function fmt(n)
		if n ~= n or n == math.huge or n == -math.huge then return "Error" end
		if n == math.floor(n) and math.abs(n) < 1e10 then return string.format("%d", n) end
		return tostring(math.floor(n * 1e8 + 0.5) / 1e8)
	end
	local function calc(a, b, o)
		if o == "+" then return a + b
		elseif o == "−" then return a - b
		elseif o == "×" then return a * b
		else return (b == 0) and math.huge or a / b end
	end
	local function press(k)
		if cur == "Error" and k ~= "C" then cur = "0"; fresh = true; acc = nil; op = nil end
		if k:match("^%d$") then
			if fresh then cur = k; fresh = false
			elseif cur == "0" then cur = k
			elseif #cur < 10 then cur = cur .. k end
		elseif k == "." then
			if fresh then cur = "0."; fresh = false
			elseif not cur:find("%.") then cur = cur .. "." end
		elseif k == "C" then
			cur, acc, op, fresh = "0", nil, nil, true
		elseif k == "±" then
			cur = fmt(-(tonumber(cur) or 0))
		elseif k == "%" then
			cur = fmt((tonumber(cur) or 0) / 100)
		elseif k == "DEL" then
			if not fresh and #cur > 1 then cur = cur:sub(1, -2) else cur = "0" end
		elseif k == "=" then
			if op and acc then
				cur = fmt(calc(acc, tonumber(cur) or 0, op))
				acc = nil; op = nil; fresh = true
			end
		else
			if op and acc and not fresh then cur = fmt(calc(acc, tonumber(cur) or 0, op)) end
			acc = tonumber(cur); op = k; fresh = true
		end
		disp.Text = cur
	end
	local keys = {
		"C", "±", "%", "÷",
		"7", "8", "9", "×",
		"4", "5", "6", "−",
		"1", "2", "3", "+",
		"0", ".", "DEL", "=",
	}
	local g = mk("Frame", {Position = UDim2.fromScale(0.04, 0.23), Size = UDim2.fromScale(0.92, 0.75), BackgroundTransparency = 1}, p)
	mk("UIGridLayout", {
		CellSize = UDim2.fromScale(0.2275, 0.178),
		CellPadding = UDim2.fromScale(0.03, 0.02),
		SortOrder = Enum.SortOrder.LayoutOrder,
	}, g)
	for i, k in ipairs(keys) do
		local col = Color3.fromRGB(70, 70, 75)
		if i <= 3 then col = Color3.fromRGB(150, 150, 155) end
		if i % 4 == 0 then col = Color3.fromRGB(255, 149, 0) end
		local b = btn(g, {Text = k, LayoutOrder = i, BackgroundColor3 = col, Font = Enum.Font.GothamBold})
		corner(b, UDim.new(0.3, 0))
		b.Activated:Connect(function() press(k) end)
	end
end

local function buildNotes(p)
	text(p, {Text = "Notes", Size = UDim2.fromScale(0.4, 0.09), Position = UDim2.fromScale(0.04, 0.02), TextColor3 = DARK, Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left})
	local box = mk("TextBox", {
		Size = UDim2.fromScale(0.92, 0.8),
		Position = UDim2.fromScale(0.04, 0.15),
		BackgroundTransparency = 1,
		Text = noteText,
		PlaceholderText = "Tap to write a note...",
		TextColor3 = DARK,
		Font = Enum.Font.Gotham,
		TextSize = 15,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		TextWrapped = true,
		MultiLine = true,
		ClearTextOnFocus = false,
	}, p)
	box:GetPropertyChangedSignal("Text"):Connect(function() noteText = box.Text end)
end

local function buildSettings(p)
	text(p, {Text = "Settings", Size = UDim2.fromScale(0.5, 0.09), Position = UDim2.fromScale(0.04, 0.02), TextColor3 = DARK, Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left})
	local function row(y, label)
		local r = mk("Frame", {Position = UDim2.fromScale(0.04, y), Size = UDim2.fromScale(0.92, 0.17), BackgroundColor3 = WHITE}, p)
		corner(r, UDim.new(0.2, 0))
		local l = text(r, {Text = label, Size = UDim2.fromScale(0.45, 0.5), Position = UDim2.fromScale(0.04, 0.25), TextColor3 = DARK, TextXAlignment = Enum.TextXAlignment.Left})
		return r, l
	end
	local function small(r, t, x, w)
		local b = btn(r, {Text = t, Size = UDim2.fromScale(w or 0.14, 0.6), Position = UDim2.fromScale(x, 0.2), BackgroundColor3 = Color3.fromRGB(0, 122, 255), Font = Enum.Font.GothamBold})
		corner(b, UDim.new(0.3, 0))
		return b
	end

	local r1 = row(0.14, "Brightness")
	local bv = text(r1, {Text = math.floor(brightness * 100 + 0.5) .. "%", Size = UDim2.fromScale(0.15, 0.5), Position = UDim2.fromScale(0.655, 0.25), TextColor3 = DARK})
	local function bright(d)
		brightness = math.clamp(brightness + d, 0.2, 1)
		bv.Text = math.floor(brightness * 100 + 0.5) .. "%"
		applyBrightness()
	end
	small(r1, "−", 0.5).Activated:Connect(function() bright(-0.2) end)
	small(r1, "+", 0.82).Activated:Connect(function() bright(0.2) end)

	local r2 = row(0.33, "Wallpaper")
	small(r2, "Next", 0.74, 0.2).Activated:Connect(function()
		wallIdx = wallIdx % #WALLPAPERS + 1
		applyWallpaper()
	end)

	local r3, l3 = row(0.52, "Battery")
	local bt = text(r3, {Text = math.floor(battery + 0.5) .. "%", Size = UDim2.fromScale(0.15, 0.5), Position = UDim2.fromScale(0.5, 0.25), TextColor3 = DARK})
	small(r3, "Charge", 0.7, 0.26).Activated:Connect(function()
		battery = 100
		updateBattery()
		bt.Text = "100%"
	end)

	text(p, {
		Text = "Volume: use the buttons on the top edge",
		Size = UDim2.fromScale(0.92, 0.07),
		Position = UDim2.fromScale(0.04, 0.73),
		TextColor3 = Color3.fromRGB(120, 120, 125),
	})
end

local function buildSimple(p, emoji, title, sub)
	text(p, {Text = emoji, Size = UDim2.fromScale(0.3, 0.3), Position = UDim2.fromScale(0.35, 0.2)})
	text(p, {Text = title, Size = UDim2.fromScale(0.6, 0.1), Position = UDim2.fromScale(0.2, 0.52), Font = Enum.Font.GothamBold, TextColor3 = p.Parent.BackgroundColor3 == WHITE and DARK or WHITE})
	text(p, {Text = sub, Size = UDim2.fromScale(0.7, 0.06), Position = UDim2.fromScale(0.15, 0.63), TextTransparency = 0.4, TextColor3 = p.Parent.BackgroundColor3 == WHITE and DARK or WHITE})
end

local function buildSafari(p)
	local bar = mk("Frame", {Position = UDim2.fromScale(0.1, 0.02), Size = UDim2.fromScale(0.8, 0.09), BackgroundColor3 = Color3.fromRGB(235, 235, 240)}, p)
	corner(bar, UDim.new(0.3, 0))
	mk("TextBox", {
		Size = UDim2.fromScale(0.9, 0.8),
		Position = UDim2.fromScale(0.05, 0.1),
		BackgroundTransparency = 1,
		Text = "",
		PlaceholderText = "Search or enter website name",
		TextColor3 = DARK,
		Font = Enum.Font.Gotham,
		TextSize = 13,
	}, bar)
	local c = mk("Frame", {Position = UDim2.fromScale(0, 0.12), Size = UDim2.fromScale(1, 0.88), BackgroundTransparency = 1}, p)
	buildSimple(c, "🧭", "Safari", "Offline - no internet on this iPad")
end

local function buildMusic(p)
	local art = mk("Frame", {AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.fromScale(0.5, 0.06), Size = UDim2.fromScale(0.4, 0.55), BackgroundColor3 = Color3.fromRGB(252, 60, 68)}, p)
	mk("UIAspectRatioConstraint", {AspectRatio = 1}, art)
	corner(art, UDim.new(0.08, 0))
	text(art, {Text = "🎵", Size = UDim2.fromScale(0.6, 0.6), Position = UDim2.fromScale(0.2, 0.2)})
	text(p, {Text = "Noob Beats", Size = UDim2.fromScale(0.6, 0.08), Position = UDim2.fromScale(0.2, 0.66), Font = Enum.Font.GothamBold})
	local play = btn(p, {Text = "▶", Size = UDim2.fromScale(0.12, 0.17), Position = UDim2.fromScale(0.44, 0.78), BackgroundColor3 = WHITE, TextColor3 = DARK})
	mk("UIAspectRatioConstraint", {AspectRatio = 1}, play)
	corner(play, UDim.new(0.5, 0))
	local playing = false
	play.Activated:Connect(function()
		playing = not playing
		play.Text = playing and "⏸" or "▶"
	end)
end

local function buildPhotos(p)
	buildSimple(p, "🌸", "No Photos", "Take one with the Camera app")
end

local function buildCamera(p)
	text(p, {Text = "📷", Size = UDim2.fromScale(0.3, 0.3), Position = UDim2.fromScale(0.35, 0.22), TextTransparency = 0.6})
	local shutter = btn(p, {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.84),
		Size = UDim2.fromScale(0.13, 0.2),
		BackgroundColor3 = WHITE,
	})
	mk("UIAspectRatioConstraint", {AspectRatio = 1}, shutter)
	corner(shutter, UDim.new(0.5, 0))
	stroke(shutter, Color3.fromRGB(120, 120, 125), 3)
	local flash = mk("Frame", {Size = UDim2.fromScale(1, 1), BackgroundColor3 = WHITE, BackgroundTransparency = 1, ZIndex = 5}, p)
	shutter.Activated:Connect(function()
		flash.BackgroundTransparency = 0
		TweenService:Create(flash, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
	end)
end

local APPS = {
	Clock = {bg = Color3.fromRGB(15, 15, 18), fg = WHITE, build = buildClock},
	Calculator = {bg = Color3.fromRGB(20, 20, 22), fg = WHITE, build = buildCalculator},
	Notes = {bg = Color3.fromRGB(255, 247, 205), fg = DARK, build = buildNotes},
	Settings = {bg = Color3.fromRGB(242, 242, 247), fg = DARK, build = buildSettings},
	Safari = {bg = WHITE, fg = DARK, build = buildSafari},
	Music = {bg = Color3.fromRGB(28, 28, 34), fg = WHITE, build = buildMusic},
	Photos = {bg = WHITE, fg = DARK, build = buildPhotos},
	Camera = {bg = BLACK, fg = WHITE, build = buildCamera},
}

openApp = function(name)
	if locked or asleep then return end
	local def = APPS[name]
	if not def then return end
	for _, c in ipairs(appFrame:GetChildren()) do c:Destroy() end
	currentApp = name
	appFrame.BackgroundColor3 = def.bg
	local content = mk("Frame", {Position = UDim2.fromScale(0, 0.075), Size = UDim2.fromScale(1, 0.925), BackgroundTransparency = 1}, appFrame)
	def.build(content)
	setStatusColor(def.fg)
	appFrame.Position = UDim2.fromScale(0, 0.25)
	appFrame.Visible = true
	TweenService:Create(appFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.fromScale(0, 0)}):Play()
end

closeApp = function()
	for _, c in ipairs(appFrame:GetChildren()) do c:Destroy() end
	appFrame.Visible = false
	currentApp = nil
	clockBig, clockDate = nil, nil
	setStatusColor(WHITE)
end

---------------------------------------------------------------------
-- LOCK / UNLOCK / SLEEP
---------------------------------------------------------------------
lock = function()
	closeApp()
	locked = true
	lockFrame.Position = UDim2.fromScale(0, 0)
	lockFrame.Visible = true
	setSlide(0)
end

unlock = function()
	locked = false
	local tw = TweenService:Create(lockFrame, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Position = UDim2.fromScale(0, -1)})
	tw:Play()
	task.delay(0.36, function()
		if not locked then lockFrame.Visible = false end
	end)
end

local function toggleSleep()
	asleep = not asleep
	if asleep then lock() end
	sleepOverlay.Visible = asleep
end

homeBtn.Activated:Connect(function()
	playClick()
	if asleep then
		toggleSleep()
	elseif not locked and currentApp then
		closeApp()
	end
end)

-- power button (top left), volume buttons (top right)
sideButton(0.07, 0.07, function() playClick(); toggleSleep() end)
sideButton(0.78, 0.055, function()
	volume = math.min(16, volume + 1)
	playClick()
	showVolume()
end)
sideButton(0.85, 0.055, function()
	volume = math.max(0, volume - 1)
	playClick()
	showVolume()
end)

---------------------------------------------------------------------
-- CLOCK + BATTERY LOOP
---------------------------------------------------------------------
local function updateClock()
	local t = os.date("*t")
	local h = t.hour % 12
	if h == 0 then h = 12 end
	local ts = string.format("%d:%02d", h, t.min)
	local ok, d = pcall(os.date, "%A, %B %d")
	d = ok and d or ""
	lockTime.Text = ts
	lockDate.Text = d
	sbTime.Text = locked and "🔒" or (ts .. (t.hour >= 12 and " PM" or " AM"))
	if clockBig and clockBig.Parent then
		clockBig.Text = string.format("%d:%02d:%02d", h, t.min, t.sec)
		clockDate.Text = d
	end
end

local lastDrain = tick()
task.spawn(function()
	while gui.Parent do
		updateClock()
		if tick() - lastDrain >= 40 then
			lastDrain = tick()
			battery = math.max(1, battery - 1)
			updateBattery()
		end
		task.wait(1)
	end
end)

---------------------------------------------------------------------
-- OPEN / CLOSE + ITEM (TOOL) + TOP BUTTON
---------------------------------------------------------------------
local toggleBtn = btn(gui, {
	AnchorPoint = Vector2.new(0.5, 0),
	Position = UDim2.new(0.5, 0, 0, 6),
	Size = UDim2.fromOffset(100, 28),
	BackgroundColor3 = Color3.fromRGB(25, 25, 28),
	Text = "📱 Open iPad",
	ZIndex = 20,
})
corner(toggleBtn, UDim.new(0.5, 0))
stroke(toggleBtn, Color3.fromRGB(120, 122, 128), 1.5)

local function setOpen(state)
	if state == isOpen then return end
	isOpen = state
	toggleBtn.Text = state and "📱 Close iPad" or "📱 Open iPad"
	if state then
		ipad.Visible = true
		TweenService:Create(ipad, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = OPEN_POS}):Play()
	else
		TweenService:Create(ipad, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Position = CLOSED_POS}):Play()
		task.delay(0.37, function()
			if not isOpen then ipad.Visible = false end
		end)
	end
end

local function giveTool()
	if tool and tool.Parent then return end
	local bp = player:FindFirstChildOfClass("Backpack") or player:WaitForChild("Backpack", 5)
	if not bp then return end
	tool = Instance.new("Tool")
	tool.Name = "iPad"
	tool.ToolTip = "iPad"
	tool.RequiresHandle = false
	tool.CanBeDropped = false
	tool.Equipped:Connect(function() setOpen(true) end)
	tool.Unequipped:Connect(function() setOpen(false) end)
	tool.Parent = bp
end

local function toggleOpen()
	local want = not isOpen
	setOpen(want)
	local char = player.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if hum and tool and tool.Parent then
		pcall(function()
			if want then hum:EquipTool(tool) else hum:UnequipTools() end
		end)
	end
end
toggleBtn.Activated:Connect(toggleOpen)

player.CharacterAdded:Connect(function()
	setOpen(false)
	task.wait(1)
	giveTool()
end)
giveTool()

---------------------------------------------------------------------
-- NOOB HANDS (reach from the bottom of the screen to your taps)
---------------------------------------------------------------------
local hands = {}

local function makeHand(side) -- -1 = left hand, 1 = right hand
	local f = mk("Frame", {
		Name = "NoobArm",
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = SKIN,
		Visible = false,
	}, handsGui)
	corner(f, UDim.new(0.3, 0))
	stroke(f, OUTLINE, 1.5)
	local sleeve = mk("Frame", {Size = UDim2.fromScale(1, 0.38), BackgroundColor3 = NOOB_BLUE}, f)
	corner(sleeve, UDim.new(0.3, 0))
	stroke(sleeve, OUTLINE, 1.5)
	local thumb = mk("Frame", {BackgroundColor3 = SKIN}, f)
	corner(thumb, UDim.new(0.4, 0))
	stroke(thumb, OUTLINE, 1.5)
	return {frame = f, thumb = thumb, side = side, tip = nil, base = Vector2.zero, target = nil, input = nil, releaseAt = 0}
end

hands[1] = makeHand(-1)
hands[2] = makeHand(1)

local function insideIPad(p)
	local pos, size = ipad.AbsolutePosition, ipad.AbsoluteSize
	return p.X >= pos.X and p.X <= pos.X + size.X and p.Y >= pos.Y and p.Y <= pos.Y + size.Y
end

local function toGui(v3)
	return Vector2.new(v3.X, v3.Y) + GuiService:GetGuiInset()
end

local function pickHand(p)
	local cx = ipad.AbsolutePosition.X + ipad.AbsoluteSize.X / 2
	return (p.X < cx) and hands[1] or hands[2]
end

local function ripple(p)
	local r = mk("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromOffset(p.X, p.Y),
		Size = UDim2.fromOffset(8, 8),
		BackgroundColor3 = WHITE,
		BackgroundTransparency = 0.35,
		ZIndex = 3,
	}, handsGui)
	corner(r, UDim.new(0.5, 0))
	TweenService:Create(r, TweenInfo.new(0.35), {Size = UDim2.fromOffset(38, 38), BackgroundTransparency = 1}):Play()
	task.delay(0.4, function() r:Destroy() end)
end

UIS.InputBegan:Connect(function(input)
	if not isOpen then return end
	if input.UserInputType ~= Enum.UserInputType.Touch and input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
	local p = toGui(input.Position)
	if not insideIPad(p) then return end
	local h = pickHand(p)
	h.target = p
	h.input = input
	h.releaseAt = tick() + 0.3
	ripple(p)
	playClick()
end)

UIS.InputChanged:Connect(function(input)
	for _, h in ipairs(hands) do
		if h.input and (input == h.input or (input.UserInputType == Enum.UserInputType.MouseMovement and h.input.UserInputType == Enum.UserInputType.MouseButton1)) then
			h.target = toGui(input.Position)
		end
	end
end)

UIS.InputEnded:Connect(function(input)
	for _, h in ipairs(hands) do
		if h.input and (input == h.input or (input.UserInputType == Enum.UserInputType.MouseButton1 and h.input.UserInputType == Enum.UserInputType.MouseButton1)) then
			h.input = nil
			h.releaseAt = tick() + 0.35
		end
	end
end)

RunService.RenderStepped:Connect(function(dt)
	local vp = handsGui.AbsoluteSize
	local w = math.clamp(vp.Y * 0.095, 24, 64)
	local ipos, isize = ipad.AbsolutePosition, ipad.AbsoluteSize
	for _, h in ipairs(hands) do
		h.base = Vector2.new(vp.X * (0.5 + 0.2 * h.side), vp.Y + 90)
		if not h.tip then h.tip = h.base end

		local goal
		if not isOpen then
			goal = h.base
		elseif h.target and (h.input or tick() < h.releaseAt) then
			goal = h.target
		else
			h.target = nil
			goal = Vector2.new(ipos.X + isize.X * (0.5 + 0.37 * h.side), math.min(ipos.Y + isize.Y * 1.02, vp.Y - 8))
		end

		local a = 1 - math.exp(-dt * (h.target and 22 or 9))
		h.tip = h.tip:Lerp(goal, a)

		local d = h.tip - h.base
		local L = math.max(d.Magnitude, 1)
		local f = h.frame
		f.Visible = d.Magnitude > 12
		f.Size = UDim2.fromOffset(w, L)
		f.Position = UDim2.fromOffset((h.base.X + h.tip.X) / 2, (h.base.Y + h.tip.Y) / 2)
		f.Rotation = math.deg(math.atan2(-d.X, d.Y))
		h.thumb.Size = UDim2.fromOffset(w * 0.42, w * 0.62)
		if h.side > 0 then
			h.thumb.Position = UDim2.new(0, -w * 0.3, 1, -w * 1.15)
		else
			h.thumb.Position = UDim2.new(1, -w * 0.12, 1, -w * 1.15)
		end
	end
end)

---------------------------------------------------------------------
-- START
---------------------------------------------------------------------
setStatusColor(WHITE)
applyBrightness()
updateClock()
lock()
