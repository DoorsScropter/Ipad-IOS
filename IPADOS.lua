--[[
    iPadOS-style GUI mockup for Roblox
    Designed as a LocalScript for YOUR OWN Roblox experience / private testing.
    It uses only normal Roblox GUI objects and client-side UI state.

    Features:
      - Responsive tablet frame with rounded bezel, wallpaper, status bar, icons
      - Touch-friendly app buttons and bottom home indicator
      - App Store mockup with local simulated installs
      - Settings Wi-Fi toggle (App Store downloads require Wi-Fi)
      - Close/power button on the top-right bezel and a reopen control

    This does not install or launch real Roblox/iPad apps. It is a visual mockup.
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
if not player then return end
local playerGui = player:WaitForChild("PlayerGui")

-- Clean up an earlier copy if the script is run again.
local previous = playerGui:FindFirstChild("iPadOSMockup")
if previous then previous:Destroy() end

local C = {
    white = Color3.fromRGB(250, 250, 252),
    black = Color3.fromRGB(15, 16, 20),
    text = Color3.fromRGB(24, 25, 30),
    muted = Color3.fromRGB(120, 123, 134),
    blue = Color3.fromRGB(0, 122, 255),
    green = Color3.fromRGB(48, 209, 88),
    panel = Color3.fromRGB(245, 246, 250),
    row = Color3.fromRGB(232, 234, 240),
}

local function addCorner(obj, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius)
    c.Parent = obj
    return c
end

local function addStroke(obj, color, thickness, transparency)
    local s = Instance.new("UIStroke")
    s.Color = color
    s.Thickness = thickness or 1
    s.Transparency = transparency or 0
    s.Parent = obj
    return s
end

local function make(className, properties, parent)
    local obj = Instance.new(className)
    for key, value in pairs(properties) do
        obj[key] = value
    end
    obj.Parent = parent
    return obj
end

local function label(parent, text, pos, size, fontSize, color, align)
    return make("TextLabel", {
        BackgroundTransparency = 1,
        Position = pos,
        Size = size,
        Font = Enum.Font.GothamMedium,
        Text = text,
        TextSize = fontSize or 16,
        TextColor3 = color or C.text,
        TextXAlignment = align or Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        TextWrapped = true,
        ZIndex = 8,
    }, parent)
end

local function button(parent, text, pos, size, background, foreground, fontSize)
    local b = make("TextButton", {
        AutoButtonColor = true,
        BackgroundColor3 = background or C.white,
        BorderSizePixel = 0,
        Position = pos,
        Size = size,
        Font = Enum.Font.GothamSemibold,
        Text = text,
        TextSize = fontSize or 16,
        TextColor3 = foreground or C.text,
        TextWrapped = true,
        ZIndex = 9,
    }, parent)
    addCorner(b, 14)
    return b
end

local gui = make("ScreenGui", {
    Name = "iPadOSMockup",
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    DisplayOrder = 900,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, playerGui)

local root = make("Frame", {
    Name = "Root",
    BackgroundTransparency = 1,
    Size = UDim2.fromScale(1, 1),
}, gui)

-- Reopen control remains on-screen while the tablet is powered off/closed.
local reopen = button(root, "▣\n iPad", UDim2.new(1, -76, 0.52, -42), UDim2.fromOffset(62, 78), Color3.fromRGB(28, 30, 38), C.white, 15)
reopen.Name = "ReopeniPad"
reopen.Visible = false
addStroke(reopen, Color3.fromRGB(110, 115, 130), 1, 0.25)

-- Outer aluminum body.
local tablet = make("Frame", {
    Name = "TabletBody",
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.fromOffset(420, 660),
    BackgroundColor3 = Color3.fromRGB(184, 188, 197),
    BorderSizePixel = 0,
    ClipsDescendants = false,
    ZIndex = 2,
}, root)
addCorner(tablet, 38)
addStroke(tablet, Color3.fromRGB(225, 227, 233), 2, 0.15)
local tabletScale = make("UIScale", { Scale = 1 }, tablet)

-- Screen and dark bezel.
local screen = make("Frame", {
    Name = "Display",
    Position = UDim2.fromOffset(11, 11),
    Size = UDim2.new(1, -22, 1, -22),
    BackgroundColor3 = C.black,
    BorderSizePixel = 0,
    ClipsDescendants = true,
    ZIndex = 3,
}, tablet)
addCorner(screen, 30)

local wallpaper = make("Frame", {
    Name = "Wallpaper",
    Size = UDim2.fromScale(1, 1),
    BackgroundColor3 = Color3.fromRGB(62, 93, 220),
    BorderSizePixel = 0,
    ClipsDescendants = true,
    ZIndex = 3,
}, screen)
addCorner(wallpaper, 30)
make("UIGradient", {
    Rotation = 40,
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(37, 198, 238)),
        ColorSequenceKeypoint.new(0.48, Color3.fromRGB(76, 94, 231)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(161, 66, 205)),
    }),
}, wallpaper)

local function blob(parent, position, size, color, transparency)
    local circle = make("Frame", {
        Position = position,
        Size = size,
        BackgroundColor3 = color,
        BackgroundTransparency = transparency,
        BorderSizePixel = 0,
        ZIndex = 4,
    }, parent)
    addCorner(circle, 999)
    return circle
end
blob(wallpaper, UDim2.new(-0.22, 0, 0.08, 0), UDim2.fromOffset(250, 250), Color3.fromRGB(95, 235, 229), 0.47)
blob(wallpaper, UDim2.new(0.47, 0, 0.34, 0), UDim2.fromOffset(320, 320), Color3.fromRGB(255, 149, 219), 0.60)
blob(wallpaper, UDim2.new(0.05, 0, 0.65, 0), UDim2.fromOffset(250, 250), Color3.fromRGB(61, 185, 255), 0.47)

-- Views live inside the screen. The status bar and home indicator remain above them.
local homeView = make("Frame", {
    Name = "HomeScreen",
    Size = UDim2.fromScale(1, 1),
    BackgroundTransparency = 1,
    ZIndex = 5,
}, screen)

local storeView = make("Frame", {
    Name = "AppStore",
    Size = UDim2.fromScale(1, 1),
    BackgroundColor3 = C.panel,
    BorderSizePixel = 0,
    Visible = false,
    ZIndex = 5,
}, screen)

local settingsView = make("Frame", {
    Name = "Settings",
    Size = UDim2.fromScale(1, 1),
    BackgroundColor3 = C.panel,
    BorderSizePixel = 0,
    Visible = false,
    ZIndex = 5,
}, screen)

local appView = make("Frame", {
    Name = "AppView",
    Size = UDim2.fromScale(1, 1),
    BackgroundColor3 = C.white,
    BorderSizePixel = 0,
    Visible = false,
    ZIndex = 5,
}, screen)

-- Simulated iPad status bar.
local status = make("Frame", {
    Name = "StatusBar",
    Position = UDim2.fromOffset(0, 0),
    Size = UDim2.new(1, 0, 0, 38),
    BackgroundTransparency = 1,
    ZIndex = 20,
}, screen)
local timeLabel = label(status, "9:41", UDim2.fromOffset(23, 1), UDim2.fromOffset(70, 26), 14, C.white)
timeLabel.Font = Enum.Font.GothamBold
local statusRight = label(status, "●  ▮▮  ▰", UDim2.new(1, -130, 0, 1), UDim2.fromOffset(105, 26), 13, C.white, Enum.TextXAlignment.Right)
statusRight.Font = Enum.Font.GothamBold

-- Home screen title and app grid.
label(homeView, "", UDim2.fromOffset(18, 43), UDim2.fromOffset(350, 35), 18, C.white)
local grid = make("Frame", {
    Name = "AppGrid",
    Position = UDim2.fromOffset(18, 100),
    Size = UDim2.new(1, -36, 1, -175),
    BackgroundTransparency = 1,
    ZIndex = 6,
}, homeView)
local gridLayout = make("UIGridLayout", {
    CellSize = UDim2.fromOffset(76, 100),
    CellPadding = UDim2.fromOffset(10, 10),
    SortOrder = Enum.SortOrder.LayoutOrder,
    HorizontalAlignment = Enum.HorizontalAlignment.Center,
    VerticalAlignment = Enum.VerticalAlignment.Top,
}, grid)

local installed = { store = true, settings = true, photos = true, safari = true }
local downloadBusy = {}
local wifiEnabled = false
local currentView = "home"
local currentApp = nil

local appDefs = {
    { id = "store", name = "App Store", glyph = "A", color = Color3.fromRGB(18, 143, 255), sub = "Discover apps and games." },
    { id = "photos", name = "Photos", glyph = "🌈", color = Color3.fromRGB(255, 255, 255), sub = "Your photo library is empty in this demo." },
    { id = "safari", name = "Safari", glyph = "🧭", color = Color3.fromRGB(255, 255, 255), sub = "A browser-style demo screen." },
    { id = "settings", name = "Settings", glyph = "⚙", color = Color3.fromRGB(130, 137, 150), sub = "Manage Wi-Fi and the demo settings." },
    { id = "roblox", name = "Roblox", glyph = "◇", color = Color3.fromRGB(30, 31, 37), sub = "This is a visual mockup, not the real Roblox app." },
    { id = "flappy", name = "Flappy Bird", glyph = "🐤", color = Color3.fromRGB(117, 208, 244), sub = "Tap the bird area to flap in this simple demo." },
    { id = "music", name = "Music", glyph = "♫", color = Color3.fromRGB(250, 55, 93), sub = "No music is playing in this mockup." },
    { id = "files", name = "Files", glyph = "📁", color = Color3.fromRGB(68, 158, 255), sub = "Your demo files would appear here." },
}
local byId = {}
for _, app in ipairs(appDefs) do byId[app.id] = app end

local homeButtons = {}
-- Forward declarations used by app-button callbacks.
local switchView, appTitle, appGlyph, appDescription, homeIndicatorHit, homeIndicatorBar

local function createHomeIcon(app, order)
    local tile = make("Frame", {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        LayoutOrder = order,
        ZIndex = 7,
    }, grid)
    local icon = button(tile, app.glyph, UDim2.fromOffset(4, 0), UDim2.fromOffset(68, 68), app.color, (app.id == "photos" or app.id == "safari") and C.text or C.white, 31)
    icon.Name = app.id .. "Icon"
    icon.TextWrapped = false
    addCorner(icon, 17)
    if app.id == "store" then
        addStroke(icon, Color3.fromRGB(255,255,255), 1, 0.75)
        icon.TextColor3 = C.white
    elseif app.id == "roblox" then
        icon.Text = "◩"
        icon.TextSize = 42
        icon.Rotation = -12
    end
    local title = label(tile, app.name, UDim2.fromOffset(-8, 70), UDim2.fromOffset(84, 24), 11, C.white, Enum.TextXAlignment.Center)
    title.TextTruncate = Enum.TextTruncate.AtEnd
    title.TextStrokeTransparency = 0.7
    icon.Activated:Connect(function()
        if app.id == "store" then
            currentView = "store"
        elseif app.id == "settings" then
            currentView = "settings"
        elseif installed[app.id] then
            currentView = "app"
            currentApp = app
        else
            currentView = "store"
        end
        -- View visibility is updated below by switchView.
        if app.id == "store" then
            currentView = "store"
        end
        switchView(currentView, app)
    end)
    homeButtons[app.id] = icon
    return tile
end

-- All local functions referenced by GUI events are declared before clicks can occur.
switchView = function(which, app)
    currentView = which
    homeView.Visible = which == "home"
    storeView.Visible = which == "store"
    settingsView.Visible = which == "settings"
    appView.Visible = which == "app"
    if which == "app" and app then currentApp = app end
    if which == "app" then
        local chosen = currentApp or byId.roblox
        appTitle.Text = chosen.name
        appGlyph.Text = chosen.glyph
        appDescription.Text = chosen.sub
        if chosen.id == "flappy" then
            appDescription.Text = "Tap anywhere in this panel to flap. This is only a small visual demo."
        end
    end
    homeIndicatorHit.Visible = true
    if which == "home" then
        homeIndicatorBar.BackgroundTransparency = 0.18
    else
        homeIndicatorBar.BackgroundTransparency = 0
    end
end

for i, app in ipairs(appDefs) do
    createHomeIcon(app, i)
end

-- Subtle home-screen page dots.
local pageDots = make("Frame", {
    Position = UDim2.new(0.5, -25, 1, -79),
    Size = UDim2.fromOffset(50, 12),
    BackgroundTransparency = 1,
    ZIndex = 8,
}, homeView)
for i = 1, 3 do
    local d = make("Frame", {
        Position = UDim2.fromOffset((i - 1) * 17, 3),
        Size = UDim2.fromOffset(7, 7),
        BackgroundColor3 = C.white,
        BackgroundTransparency = i == 1 and 0.05 or 0.58,
        BorderSizePixel = 0,
        ZIndex = 8,
    }, pageDots)
    addCorner(d, 8)
end

-- App Store header and scrollable app catalogue.
label(storeView, "App Store", UDim2.fromOffset(22, 48), UDim2.new(1, -44, 0, 42), 29, C.text).Font = Enum.Font.GothamBold
label(storeView, "Discover", UDim2.fromOffset(23, 90), UDim2.new(1, -46, 0, 26), 15, C.muted)
local search = make("TextBox", {
    Name = "Search",
    Position = UDim2.fromOffset(20, 119),
    Size = UDim2.new(1, -40, 0, 38),
    BackgroundColor3 = Color3.fromRGB(226, 228, 234),
    BorderSizePixel = 0,
    ClearTextOnFocus = false,
    Font = Enum.Font.Gotham,
    PlaceholderText = "⌕  Search apps",
    PlaceholderColor3 = C.muted,
    Text = "",
    TextColor3 = C.text,
    TextSize = 14,
    ZIndex = 7,
}, storeView)
addCorner(search, 11)

local storeScroll = make("ScrollingFrame", {
    Name = "Catalogue",
    Position = UDim2.fromOffset(14, 168),
    Size = UDim2.new(1, -28, 1, -220),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    CanvasSize = UDim2.fromOffset(0, 0),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    ScrollBarThickness = 3,
    ScrollBarImageColor3 = C.muted,
    ZIndex = 7,
}, storeView)
local storeListLayout = make("UIListLayout", {
    Padding = UDim.new(0, 9),
    SortOrder = Enum.SortOrder.LayoutOrder,
}, storeScroll)

local storeRows = {}
local function makeStoreRow(app, order)
    local row = make("Frame", {
        Size = UDim2.new(1, -2, 0, 82),
        BackgroundColor3 = C.white,
        BorderSizePixel = 0,
        LayoutOrder = order,
        ZIndex = 8,
    }, storeScroll)
    addCorner(row, 15)
    local ic = button(row, app.glyph, UDim2.fromOffset(9, 11), UDim2.fromOffset(58, 58), app.color, C.white, 27)
    addCorner(ic, 14)
    if app.id == "photos" or app.id == "safari" then ic.TextColor3 = C.text end
    local nm = label(row, app.name, UDim2.fromOffset(77, 10), UDim2.new(1, -170, 0, 27), 14, C.text)
    nm.Font = Enum.Font.GothamBold
    label(row, app.sub, UDim2.fromOffset(77, 36), UDim2.new(1, -170, 0, 36), 10, C.muted)
    local action = button(row, installed[app.id] and "OPEN" or "GET", UDim2.new(1, -78, 0.5, -15), UDim2.fromOffset(66, 30), Color3.fromRGB(235, 237, 242), C.blue, 12)
    addCorner(action, 16)
    storeRows[app.id] = { button = action, row = row, app = app }
    action.Activated:Connect(function()
        if installed[app.id] then
            switchView("app", app)
            return
        end
        if not wifiEnabled then
            statusRight.Text = "Wi-Fi Off"
            statusRight.TextColor3 = Color3.fromRGB(255, 190, 70)
            action.Text = "Wi-Fi Off"
            task.delay(1.4, function()
                if action and action.Parent and not installed[app.id] then action.Text = "GET" end
            end)
            return
        end
        if downloadBusy[app.id] then return end
        downloadBusy[app.id] = true
        action.Text = "GETTING…"
        action.TextColor3 = C.muted
        task.wait(1.0)
        installed[app.id] = true
        downloadBusy[app.id] = nil
        if action and action.Parent then
            action.Text = "OPEN"
            action.TextColor3 = C.blue
        end
        local homeIcon = homeButtons[app.id]
        if homeIcon then
            homeIcon.BackgroundColor3 = app.color
            homeIcon.Text = app.glyph
        end
    end)
end

for i, app in ipairs(appDefs) do
    if app.id ~= "store" and app.id ~= "settings" then
        makeStoreRow(app, i)
    end
end

search:GetPropertyChangedSignal("Text"):Connect(function()
    local q = string.lower(search.Text)
    for _, item in pairs(storeRows) do
        item.row.Visible = q == "" or string.find(string.lower(item.app.name), q, 1, true) ~= nil
    end
end)

-- Settings screen.
label(settingsView, "Settings", UDim2.fromOffset(22, 48), UDim2.new(1, -44, 0, 42), 29, C.text).Font = Enum.Font.GothamBold
label(settingsView, "Connectivity", UDim2.fromOffset(23, 103), UDim2.new(1, -46, 0, 24), 14, C.muted)
local wifiCard = make("Frame", {
    Position = UDim2.fromOffset(16, 135),
    Size = UDim2.new(1, -32, 0, 76),
    BackgroundColor3 = C.white,
    BorderSizePixel = 0,
    ZIndex = 7,
}, settingsView)
addCorner(wifiCard, 15)
local wifiGlyph = label(wifiCard, "◔", UDim2.fromOffset(14, 10), UDim2.fromOffset(46, 54), 24, C.blue, Enum.TextXAlignment.Center)
wifiGlyph.Font = Enum.Font.GothamBold
label(wifiCard, "Wi-Fi", UDim2.fromOffset(67, 7), UDim2.fromOffset(150, 30), 15, C.text).Font = Enum.Font.GothamBold
local wifiStateLabel = label(wifiCard, "Off", UDim2.fromOffset(67, 37), UDim2.fromOffset(150, 25), 11, C.muted)
local wifiToggle = button(wifiCard, "OFF", UDim2.new(1, -80, 0.5, -16), UDim2.fromOffset(65, 32), Color3.fromRGB(230, 232, 237), C.muted, 12)
addCorner(wifiToggle, 18)
local wifiExplanation = label(settingsView, "Turn Wi-Fi on to simulate App Store downloads. This setting only affects this mockup.", UDim2.fromOffset(22, 220), UDim2.new(1, -44, 0, 62), 12, C.muted)
wifiExplanation.TextYAlignment = Enum.TextYAlignment.Top

local infoCard = make("Frame", {
    Position = UDim2.fromOffset(16, 300),
    Size = UDim2.new(1, -32, 0, 80),
    BackgroundColor3 = C.white,
    BorderSizePixel = 0,
    ZIndex = 7,
}, settingsView)
addCorner(infoCard, 15)
label(infoCard, "About This iPad", UDim2.fromOffset(16, 8), UDim2.new(1, -32, 0, 28), 14, C.text).Font = Enum.Font.GothamBold
label(infoCard, "iPadOS-style local UI demo", UDim2.fromOffset(16, 38), UDim2.new(1, -32, 0, 26), 11, C.muted)

local function setWifi(on)
    wifiEnabled = on
    wifiToggle.Text = on and "ON" or "OFF"
    wifiToggle.BackgroundColor3 = on and C.green or Color3.fromRGB(230, 232, 237)
    wifiToggle.TextColor3 = on and C.white or C.muted
    wifiStateLabel.Text = on and "Connected (simulated)" or "Off"
    statusRight.Text = on and "●  Wi-Fi  ▰" or "●  ▮▮  ▰"
    statusRight.TextColor3 = C.white
end
wifiToggle.Activated:Connect(function() setWifi(not wifiEnabled) end)

-- Generic app screen; a bottom home gesture/tap returns from this view.
local appTopIcon = make("Frame", {
    AnchorPoint = Vector2.new(0.5, 0),
    Position = UDim2.new(0.5, 0, 0, 125),
    Size = UDim2.fromOffset(110, 110),
    BackgroundColor3 = Color3.fromRGB(235, 238, 244),
    BorderSizePixel = 0,
    ZIndex = 7,
}, appView)
addCorner(appTopIcon, 26)
appGlyph = label(appTopIcon, "◇", UDim2.fromScale(0, 0), UDim2.fromScale(1, 1), 58, C.blue, Enum.TextXAlignment.Center)
appGlyph.TextYAlignment = Enum.TextYAlignment.Center
appTitle = label(appView, "App", UDim2.fromOffset(20, 250), UDim2.new(1, -40, 0, 42), 25, C.text, Enum.TextXAlignment.Center)
appTitle.Font = Enum.Font.GothamBold
appDescription = label(appView, "Demo app", UDim2.fromOffset(34, 298), UDim2.new(1, -68, 0, 90), 14, C.muted, Enum.TextXAlignment.Center)
appDescription.TextYAlignment = Enum.TextYAlignment.Top

local demoAction = button(appView, "Tap here", UDim2.new(0.5, -80, 0, 410), UDim2.fromOffset(160, 44), C.blue, C.white, 15)
addCorner(demoAction, 22)
demoAction.Activated:Connect(function()
    if currentApp and currentApp.id == "flappy" then
        demoAction.Text = "FLAP! 🐤"
        task.delay(0.35, function()
            if demoAction and demoAction.Parent then demoAction.Text = "Tap here" end
        end)
    else
        demoAction.Text = "This is a demo"
        task.delay(1.0, function()
            if demoAction and demoAction.Parent then demoAction.Text = "Tap here" end
        end)
    end
end)

-- Bottom home indicator: generous invisible hit-area so it is easy to tap on mobile.
homeIndicatorHit = button(screen, "", UDim2.new(0.5, -88, 1, -45), UDim2.fromOffset(176, 34), Color3.fromRGB(255,255,255), C.white, 1)
homeIndicatorHit.Name = "HomeIndicatorHitArea"
homeIndicatorHit.BackgroundTransparency = 1
homeIndicatorHit.Text = ""
homeIndicatorHit.ZIndex = 40
homeIndicatorBar = make("Frame", {
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.new(0.5, 0, 0.5, 0),
    Size = UDim2.fromOffset(106, 5),
    BackgroundColor3 = C.white,
    BackgroundTransparency = 0.18,
    BorderSizePixel = 0,
    ZIndex = 41,
}, homeIndicatorHit)
addCorner(homeIndicatorBar, 10)
homeIndicatorHit.Activated:Connect(function()
    if currentView ~= "home" then
        switchView("home")
    end
end)

-- Power button on the top-right of the tablet shell (not an extra icon on the left).
local power = button(tablet, "⏻", UDim2.new(1, -61, 0, -9), UDim2.fromOffset(34, 25), Color3.fromRGB(73, 76, 85), C.white, 16)
power.Name = "PowerButton"
addCorner(power, 8)
power.ZIndex = 30
power.Activated:Connect(function()
    tablet.Visible = false
    reopen.Visible = true
end)
reopen.Activated:Connect(function()
    tablet.Visible = true
    reopen.Visible = false
end)

-- Keep the tablet small enough for phone/tablet viewports, without filling the screen.
local cameraConnection
local function updateScale()
    local camera = Workspace.CurrentCamera
    if not camera then return end
    local viewport = camera.ViewportSize
    local scale = math.min(1, (viewport.X * 0.88) / 420, (viewport.Y * 0.88) / 660)
    tabletScale.Scale = math.max(0.52, scale)
end
updateScale()
if Workspace.CurrentCamera then
    cameraConnection = Workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale)
end
Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    if cameraConnection then cameraConnection:Disconnect() end
    if Workspace.CurrentCamera then
        cameraConnection = Workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale)
        updateScale()
    end
end)

-- Digital clock, refreshed once per second.
task.spawn(function()
    while gui.Parent do
        timeLabel.Text = os.date("%H:%M")
        task.wait(1)
    end
end)

-- Start on the home screen; Wi-Fi stays off until toggled in Settings.
switchView("home")
setWifi(false)
