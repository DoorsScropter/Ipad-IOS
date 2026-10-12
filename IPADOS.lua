local P,TS,RS,UIS,GS=game:GetService("Players"),game:GetService("TweenService"),game:GetService("RunService"),game:GetService("UserInputService"),game:GetService("GuiService")
local LP=P.LocalPlayer local PG=LP:WaitForChild("PlayerGui")
for _,n in ipairs({"iPadOS_UI","iPadOS_Toggle"}) do local o=PG:FindFirstChild(n) if o then o:Destroy() end end
for _,c in ipairs({LP:FindFirstChild("Backpack"),LP.Character}) do if c then local o=c:FindFirstChild("iPad") if o then o:Destroy() end end end
local u,C,V2=UDim2.new,Color3.fromRGB,Vector2.new
local XL,XR,XC=Enum.TextXAlignment.Left,Enum.TextXAlignment.Right,Enum.TextXAlignment.Center
local FG,FB,FM=Enum.Font.Gotham,Enum.Font.GothamBold,Enum.Font.GothamMedium
local WH=C(255,255,255)
local function N(c,p,par) local o=Instance.new(c) for k,v in pairs(p or {}) do o[k]=v end o.Parent=par return o end
local function F(p,par) p.BorderSizePixel=0 return N("Frame",p,par) end
local function Cr(r,par) return N("UICorner",{CornerRadius=UDim.new(0,r)},par) end
local function T(p,par) p.BackgroundTransparency=1 p.Font=p.Font or FM p.TextColor3=p.TextColor3 or WH p.TextSize=p.TextSize or 12 return N("TextLabel",p,par) end
local function B(p,par) p.AutoButtonColor=false p.BorderSizePixel=0 p.Text=p.Text or "" p.Font=p.Font or FB p.TextColor3=p.TextColor3 or WH return N("TextButton",p,par) end
local function tw(o,t,pr,es) local x=TS:Create(o,TweenInfo.new(t,es or Enum.EasingStyle.Quint,Enum.EasingDirection.Out),pr) x:Play() return x end
local function rc(p,x,y,w,h,c,r,rot,tr)
 local f=N("Frame",{AnchorPoint=V2(.5,.5),Position=u(x,0,y,0),Size=u(w,0,h,0),BackgroundColor3=c,BorderSizePixel=0,Rotation=rot or 0,BackgroundTransparency=tr or 0},p)
 if r and r>0 then N("UICorner",{CornerRadius=UDim.new(r,0)},f) end return f
end
local function gt(p,txt,x,y,w,h,c) return N("TextLabel",{AnchorPoint=V2(.5,.5),Position=u(x,0,y,0),Size=u(w,0,h,0),BackgroundTransparency=1,Text=txt,TextScaled=true,Font=FB,TextColor3=c or WH},p) end
local function tri(p,x,y,D,dir,c)
 local cl=F({Position=u(0,x,0,y),Size=u(0,D/2,0,D),BackgroundTransparency=1,ClipsDescendants=true},p) local a=D/math.sqrt(2)
 N("Frame",{AnchorPoint=V2(.5,.5),Position=u(0,dir>0 and 0 or D/2,0,D/2),Size=u(0,a,0,a),Rotation=45,BackgroundColor3=c,BorderSizePixel=0},cl) return cl
end

local S={isSleep=false,currentVolume=75,activeAppId=nil,installedApps={},locked=true,wifi=false,net=nil,joining=nil,bt=false,btdev=false,dnd=false,eye=false,bright=1,playing=false,track=1,prog=0,battery=87,photos={},note="",best=0,page=0}
local subs={}
local function on(k,f) subs[k]=subs[k] or {} table.insert(subs[k],f) end
local function set(k,v) S[k]=v for _,f in ipairs(subs[k] or {}) do pcall(f,v) end end
local function setKey(k,v) if k=="wifi" and not v then S.joining=nil set("net",nil) end set(k,v) end
local TR={{"Sunset Drive","Baseplate Beats"},{"Neon Studs","Roblox Radio"},{"Lo-Fi Spawn","Chill Parts"}}

local function A(id,n,col,cat,light,sub,sys) return {id=id,name=n,col=col,cat=cat,light=light,sub=sub,sys=sys} end
local ALL={A("camera","Camera",C(110,110,118),"Creativity",false,nil,true),A("maps","Maps",C(96,200,110),"Utilities",false,nil,true),A("store","App Store",C(21,126,251),"Utilities",true,nil,true),A("settings","Settings",C(120,120,128),"Utilities",true,nil,true),
A("photos","Photos",C(248,248,250),"Creativity",true,nil,true),A("notes","Notes",C(252,252,250),"Productivity",true,nil,true),A("music","Music",C(252,60,90),"Entertainment",false,nil,true),A("clock","Clock",C(22,22,24),"Utilities",false,nil,true),
A("flappy","Flappy Bird",C(112,197,206),"Entertainment",false,"Tap to flap. Don't crash."),A("calc","Calculator",C(40,40,44),"Productivity",false,"Fast, simple maths"),A("stopwatch","Stopwatch",C(30,30,32),"Utilities",false,"Time anything"),A("weather","Weather",C(62,150,240),"Utilities",false,"Live forecast")}
local byId={} for _,a in ipairs(ALL) do byId[a.id]=a if a.sys then table.insert(S.installedApps,a) end end
local function hasApp(id) for _,a in ipairs(S.installedApps) do if a.id==id then return true end end return false end
local DOCK={camera=true,maps=true,store=true,settings=true}
local refs={[0]={},[1]={}}
local launch,closeApp,setPage,renderHome,renderLib,notify,alert,ctxMenu,go,unlock,lockNow,openCC,closeCC,showVol,setBar,geom
local ccOpen,busy,Win,WC,WS=false,false,nil,nil,nil
local build={}

local GL={
camera=function(p) rc(p,.5,.58,.66,.44,WH,.2) rc(p,.5,.34,.28,.1,WH,.35) rc(p,.5,.58,.34,.34,C(52,52,58),.5) rc(p,.5,.58,.22,.22,C(30,48,92),.5) rc(p,.46,.54,.07,.07,C(140,170,255),.5) rc(p,.78,.44,.06,.06,C(255,190,40),.5) end,
maps=function(p) rc(p,.5,.5,.9,.12,WH,0,-32) rc(p,.3,.76,.5,.08,C(255,225,120),0,18) rc(p,.5,.6,.13,.13,C(255,59,48),0,45) rc(p,.5,.44,.3,.3,C(255,59,48),.5) rc(p,.5,.44,.12,.12,WH,.5) end,
store=function(p) rc(p,.41,.5,.09,.56,WH,.5,-20) rc(p,.59,.5,.09,.56,WH,.5,20) rc(p,.5,.6,.3,.07,WH,.3) end,
settings=function(p) for _,r in ipairs({0,45,90,135}) do rc(p,.5,.5,.74,.14,C(228,228,235),.3,r) end rc(p,.5,.5,.52,.52,C(210,210,218),.5) rc(p,.5,.5,.24,.24,C(110,110,120),.5) end,
photos=function(p) local cs={C(255,59,48),C(255,149,0),C(255,204,0),C(52,199,89),C(90,200,250),C(10,132,255),C(175,82,222),C(255,45,85)} for i,c in ipairs(cs) do local a=math.rad((i-1)*45) rc(p,.5+.2*math.cos(a),.5+.2*math.sin(a),.34,.34,c,.5,0,.35) end end,
notes=function(p) rc(p,.5,.22,.72,.1,C(255,204,0),.5) for i=0,3 do rc(p,.5,.42+i*.14,.7,.04,C(205,205,210),.5) end end,
music=function(p) rc(p,.5,.42,.05,.4,WH,0) rc(p,.38,.64,.22,.17,WH,.5,-20) rc(p,.6,.26,.2,.07,WH,.5,25) end,
clock=function(p) rc(p,.5,.5,.76,.76,WH,.5) rc(p,.5,.34,.04,.32,C(20,20,20),.5) rc(p,.64,.5,.28,.05,C(20,20,20),.5) rc(p,.5,.5,.07,.07,C(255,149,0),.5) end,
flappy=function(p) rc(p,.5,.9,.9,.1,C(222,216,149)) rc(p,.45,.52,.46,.38,C(250,213,60),.5) rc(p,.56,.46,.15,.15,WH,.5) rc(p,.58,.46,.06,.06,C(0,0,0),.5) rc(p,.72,.58,.2,.1,C(240,100,40),.5) rc(p,.38,.58,.2,.14,C(255,240,150),.5) end,
calc=function(p) rc(p,.5,.22,.72,.2,C(80,80,86),.2) for r=0,2 do for c=0,2 do rc(p,.26+c*.24,.46+r*.19,.18,.14,c==2 and C(255,159,10) or C(110,110,116),.3) end end end,
stopwatch=function(p) local r=rc(p,.5,.56,.64,.64,C(30,30,32),.5) N("UIStroke",{Color=WH,Thickness=2},r) rc(p,.5,.46,.04,.22,C(255,159,10),.5) rc(p,.5,.16,.14,.08,WH,.3) end,
weather=function(p) rc(p,.38,.4,.3,.3,C(255,214,10),.5) rc(p,.55,.64,.5,.22,WH,.5) rc(p,.45,.56,.26,.26,WH,.5) rc(p,.64,.58,.22,.22,WH,.5) end}
local function tile(a,par,x,y,sz,isb)
 local t=N(isb and "TextButton" or "Frame",{Position=u(0,x,0,y),Size=u(0,sz,0,sz),BackgroundColor3=a.col,BorderSizePixel=0},par)
 if isb then t.AutoButtonColor=false t.Text="" end
 Cr(sz*.225,t) N("UIGradient",{Rotation=90,Color=ColorSequence.new(a.col:Lerp(WH,.22),a.col:Lerp(C(0,0,0),.12))},t)
 N("UIStroke",{Color=WH,Transparency=.84,Thickness=1},t)
 if GL[a.id] then GL[a.id](t) end return t
end

local G=N("ScreenGui",{Name="iPadOS_UI",ResetOnSpawn=false,IgnoreGuiInset=true,DisplayOrder=50,ZIndexBehavior=Enum.ZIndexBehavior.Sibling},PG)
local R=F({Name="iPad",Size=u(0,500,0,354),AnchorPoint=V2(.5,.5),Position=u(.5,0,.5,0),BackgroundTransparency=1},G)
local sc=N("UIScale",{},R)
local function fit() local cm=workspace.CurrentCamera if not cm then return end local v=cm.ViewportSize sc.Scale=math.min(v.X*.94/510,v.Y*.86/372,1.6) end fit()
if workspace.CurrentCamera then workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(fit) end
local sd=F({Size=u(1,0,1,0),Position=u(0,0,0,12),BackgroundColor3=C(0,0,0),BackgroundTransparency=.65},R) Cr(28,sd)
local O=F({Size=u(1,0,1,0),BackgroundColor3=C(70,70,75)},R) Cr(26,O)
N("UIGradient",{Rotation=90,Color=ColorSequence.new(C(140,140,146),C(48,48,52))},O)
local Bz=F({Size=u(1,-6,1,-6),Position=u(0,3,0,3),BackgroundColor3=C(6,6,8)},O) Cr(23,Bz)
local Sc=F({Name="Screen",Size=u(0,414,0,310),Position=u(0,43,0,22),BackgroundColor3=C(0,0,0),ClipsDescendants=true},R) Cr(3,Sc)
local cam=F({Size=u(0,7,0,7),Position=u(0,20,0,176),BackgroundColor3=C(28,28,34)},R) Cr(4,cam) N("UIStroke",{Color=C(70,70,78),Thickness=1},cam)
F({Size=u(0,2,0,2),Position=u(0,2,0,2),BackgroundColor3=C(60,90,160)},cam)
local HB=B({Position=u(0,473,0,164),Size=u(0,24,0,24),BackgroundColor3=C(0,0,0)},R) Cr(12,HB) N("UIStroke",{Color=C(100,100,106),Thickness=2},HB)
local function press(b) local p=b.Position tw(b,.07,{Position=p+u(0,0,0,2)}).Completed:Connect(function() tw(b,.12,{Position=p}) end) end
local function HW(x,w,cb) local b=B({Position=u(0,x,0,-6),Size=u(0,w,0,10),BackgroundColor3=C(105,105,112)},R) Cr(3,b) N("UIStroke",{Color=C(40,40,44),Thickness=1},b) b.MouseButton1Click:Connect(function() press(b) cb() end) return b end

function geom(b) local k=sc.Scale return (b.AbsolutePosition-Sc.AbsolutePosition)/k,b.AbsoluteSize/k end
local function wall(par)
 local w=F({Size=u(1,0,1,0),BackgroundColor3=WH,ClipsDescendants=true},par)
 N("UIGradient",{Rotation=120,Color=ColorSequence.new({ColorSequenceKeypoint.new(0,C(20,28,90)),ColorSequenceKeypoint.new(.55,C(96,60,170)),ColorSequenceKeypoint.new(1,C(230,110,150))})},w)
 for _,bl in ipairs({{60,60,280,C(255,110,170),.7},{330,250,320,C(70,170,255),.72},{260,30,200,C(255,200,90),.82}}) do local f=F({AnchorPoint=V2(.5,.5),Position=u(0,bl[1],0,bl[2]),Size=u(0,bl[3],0,bl[3]),BackgroundColor3=bl[4],BackgroundTransparency=bl[5]},w) Cr(bl[3]/2,f) end
 return w
end
wall(Sc).ZIndex=0
local PC=F({Size=u(0,828,0,310),BackgroundTransparency=1,ZIndex=1},Sc)
local P1=F({Size=u(0,414,0,310),BackgroundTransparency=1},PC)
local P2=F({Size=u(0,414,0,310),Position=u(0,414,0,0),BackgroundTransparency=1},PC)
local GridC=F({Position=u(0,0,0,30),Size=u(0,414,0,200),BackgroundTransparency=1},P1)
local LibC=F({Position=u(0,0,0,60),Size=u(0,414,0,250),BackgroundTransparency=1},P2)

local function icon(a,par,x,y,sz,pg,lab,shadow)
 if shadow then local sh=F({Position=u(0,x,0,y+3),Size=u(0,sz,0,sz),BackgroundColor3=C(0,0,0),BackgroundTransparency=.75},par) Cr(sz*.225,sh) end
 local b=tile(a,par,x,y,sz,true) b.Name=a.id
 if lab then T({Text=a.name,Position=u(0,x-8,0,y+sz+3),Size=u(0,sz+16,0,12),TextSize=9,Font=FM,TextStrokeTransparency=.8,TextTruncate=Enum.TextTruncate.AtEnd},par) end
 refs[pg][a.id]=b local down,long=false,false
 b.MouseButton1Down:Connect(function() down=true long=false if not a.sys then task.delay(.55,function() if down then long=true down=false ctxMenu(a,b) end end) end end)
 b.MouseButton1Up:Connect(function() down=false end) b.MouseLeave:Connect(function() down=false end)
 b.MouseButton1Click:Connect(function() if long then long=false return end launch(a.id,b) end)
 return b
end
local DK=F({Position=u(0,42,0,240),Size=u(0,330,0,58),BackgroundColor3=WH,BackgroundTransparency=.78},P1) Cr(18,DK) N("UIStroke",{Color=WH,Transparency=.7,Thickness=1},DK)
for i,id in ipairs({"camera","maps","store","settings"}) do icon(byId[id],DK,(i-1)*66+11,7,44,0,false,false) end
local LB=B({Position=u(0,4*66+11,0,7),Size=u(0,44,0,44),BackgroundColor3=C(70,70,86)},DK) Cr(10,LB)
for r=0,1 do for c=0,1 do rc(LB,.3+c*.4,.3+r*.4,.28,.28,C(235,235,245),.25) end end
LB.MouseButton1Click:Connect(function() setPage(1) end)
local d1=F({Position=u(0,198,0,230),Size=u(0,6,0,6),BackgroundColor3=WH,ZIndex=5},Sc) Cr(3,d1)
local d2=F({Position=u(0,210,0,230),Size=u(0,6,0,6),BackgroundColor3=WH,BackgroundTransparency=.6,ZIndex=5},Sc) Cr(3,d2)
B({Position=u(0,192,0,224),Size=u(0,14,0,18),BackgroundTransparency=1,ZIndex=6},Sc).MouseButton1Click:Connect(function() setPage(0) end)
B({Position=u(0,208,0,224),Size=u(0,14,0,18),BackgroundTransparency=1,ZIndex=6},Sc).MouseButton1Click:Connect(function() setPage(1) end)
function setPage(n) if S.activeAppId then return end S.page=n tw(PC,.4,{Position=u(0,-414*n,0,0)}) d1.BackgroundTransparency=n==0 and 0 or .6 d2.BackgroundTransparency=n==1 and 0 or .6 end
local SBx=N("TextBox",{Position=u(0,20,0,26),Size=u(0,374,0,26),BackgroundColor3=WH,BackgroundTransparency=.25,Text="",PlaceholderText="Search",PlaceholderColor3=C(100,100,108),TextColor3=C(0,0,0),Font=FM,TextSize=12,ClearTextOnFocus=false,BorderSizePixel=0},P2) Cr(13,SBx)
function renderHome()
 for _,c in ipairs(GridC:GetChildren()) do c:Destroy() end
 local i=0 for _,a in ipairs(S.installedApps) do if not DOCK[a.id] and i<18 then icon(a,GridC,29+(i%6)*62,8+math.floor(i/6)*64,46,0,true,true) i+=1 end end
end
function renderLib()
 for _,c in ipairs(LibC:GetChildren()) do c:Destroy() end
 local q=SBx.Text:lower()
 if q~="" then
  local i=0 for _,a in ipairs(S.installedApps) do if a.name:lower():find(q,1,true) then icon(a,LibC,29+(i%6)*62,8+math.floor(i/6)*64,46,1,true,false) i+=1 end end
  if i==0 then T({Text="No Results",Position=u(0,0,0,40),Size=u(0,414,0,20),TextSize=14,Font=FB,TextXAlignment=XC},LibC) end return
 end
 for k,cn in ipairs({"Utilities","Creativity","Entertainment","Productivity"}) do
  local f=F({Position=u(0,16+((k-1)%2)*198,0,4+math.floor((k-1)/2)*122),Size=u(0,184,0,112),BackgroundColor3=WH,BackgroundTransparency=.8},LibC) Cr(18,f)
  T({Text=cn,Position=u(0,12,0,5),Size=u(0,160,0,16),TextSize=10,Font=FB,TextXAlignment=XL},f)
  local j=0 for _,a in ipairs(S.installedApps) do if a.cat==cn and j<8 then icon(a,f,10+(j%4)*43,24+math.floor(j/4)*43,36,1,false,false) j+=1 end end
 end
end
SBx:GetPropertyChangedSignal("Text"):Connect(renderLib)

local SBar=F({Size=u(0,414,0,20),BackgroundTransparency=1,ZIndex=80},Sc)
local BI={} local function bi(o) table.insert(BI,o) return o end
local tm=bi(T({Position=u(0,16,0,0),Size=u(0,56,0,20),TextSize=11,Font=FB,TextXAlignment=XL},SBar))
local dtl=bi(T({Position=u(0,70,0,0),Size=u(0,70,0,20),TextSize=10,TextXAlignment=XL},SBar))
local dndT=bi(T({Position=u(0,142,0,0),Size=u(0,30,0,20),Text="DND",TextSize=9,Font=FB,Visible=false,TextXAlignment=XL},SBar))
local wf={} for i,h in ipairs({4,7,10}) do local w=bi(F({Position=u(0,316+(i-1)*5,0,14-h),Size=u(0,3,0,h),BackgroundColor3=WH,Visible=false},SBar)) Cr(1,w) wf[i]=w end
local pct=bi(T({Position=u(0,338,0,0),Size=u(0,34,0,20),TextSize=10,TextXAlignment=XR},SBar))
local bat=F({Position=u(0,376,0,5),Size=u(0,22,0,10),BackgroundTransparency=1},SBar) Cr(3,bat)
bi(N("UIStroke",{Color=WH,Thickness=1,Transparency=.4},bat))
local bf=F({Position=u(0,2,0,2),Size=u(1,-4,1,-4),BackgroundColor3=C(52,199,89)},bat) Cr(2,bf)
bi(F({Position=u(0,399,0,8),Size=u(0,2,0,4),BackgroundColor3=WH},SBar))
local function updBat() pct.Text=S.battery.."%" bf.Size=u(S.battery/100,-4,1,-4) bf.BackgroundColor3=S.battery<=20 and C(255,69,58) or C(52,199,89) end updBat()
local SBb=B({Position=u(0,306,0,0),Size=u(0,108,0,22),BackgroundTransparency=1,ZIndex=2},SBar)
local HI=bi(F({Position=u(0,152,0,302),Size=u(0,110,0,4),BackgroundColor3=WH,ZIndex=90},Sc)) Cr(2,HI)
local HIB=B({Position=u(0,127,0,288),Size=u(0,160,0,22),BackgroundTransparency=1,ZIndex=91},Sc)
function setBar(light) local c=light and C(10,10,10) or WH for _,o in ipairs(BI) do if o:IsA("TextLabel") then o.TextColor3=c elseif o:IsA("UIStroke") then o.Color=c else o.BackgroundColor3=c end end end
on("net",function(v) for _,w in ipairs(wf) do w.Visible=v~=nil end end)
on("dnd",function(v) dndT.Visible=v end)

local LS=F({Size=u(1,0,1,0),ZIndex=75,Active=true,BackgroundColor3=WH,ClipsDescendants=true},Sc) wall(LS)
local lsD=T({Position=u(0,0,0,56),Size=u(0,414,0,20),TextSize=15,Font=FM,TextXAlignment=XC},LS)
local lsT=T({Position=u(0,0,0,72),Size=u(0,414,0,86),TextSize=82,Font=FG,TextXAlignment=XC},LS)
local lk=F({Position=u(0,201,0,36),Size=u(0,12,0,9),BackgroundColor3=WH},LS) Cr(2,lk)
local lkr=F({Position=u(0,203,0,29),Size=u(0,8,0,10),BackgroundTransparency=1},LS) Cr(4,lkr) N("UIStroke",{Color=WH,Thickness=1.5},lkr)
T({Text="Swipe up to unlock",Position=u(0,0,0,266),Size=u(0,414,0,16),TextSize=11,TextTransparency=.25,TextXAlignment=XC},LS)
for i,x in ipairs({22,358}) do local cb=F({Position=u(0,x,0,248),Size=u(0,34,0,34),BackgroundColor3=C(10,10,14),BackgroundTransparency=.45},LS) Cr(17,cb) if i==2 then GL.camera(cb) else rc(cb,.5,.36,.3,.18,WH,.2) rc(cb,.5,.62,.2,.38,WH,.2) end end
F({Position=u(0,152,0,302),Size=u(0,110,0,4),BackgroundColor3=WH},LS)

local SL=F({Size=u(1,0,1,0),BackgroundColor3=C(0,0,0),BackgroundTransparency=1,Visible=false,ZIndex=160,Active=true},Sc)
local BR=F({Size=u(1,0,1,0),BackgroundColor3=C(0,0,0),BackgroundTransparency=1,ZIndex=176},Sc)
local EY=F({Size=u(1,0,1,0),BackgroundColor3=C(255,150,40),BackgroundTransparency=1,ZIndex=177},Sc)
local GLS=F({Size=u(1,0,1,0),BackgroundColor3=WH,ZIndex=180},Sc) N("UIGradient",{Rotation=125,Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,.9),NumberSequenceKeypoint.new(.4,.96),NumberSequenceKeypoint.new(.5,1),NumberSequenceKeypoint.new(1,1)})},GLS)
on("bright",function(v) tw(BR,.1,{BackgroundTransparency=1-(1-v)*.8}) end)
on("eye",function(v) tw(EY,.5,{BackgroundTransparency=v and .84 or 1}) end)

local BN=N("CanvasGroup",{Position=u(0,57,0,-60),Size=u(0,300,0,46),BackgroundColor3=C(236,236,240),BorderSizePixel=0,ZIndex=85},Sc) Cr(14,BN)
local bnI=F({Position=u(0,10,0,11),Size=u(0,24,0,24),BackgroundColor3=C(21,126,251)},BN) Cr(6,bnI)
local bnT=T({Position=u(0,44,0,6),Size=u(0,244,0,16),TextSize=11,Font=FB,TextColor3=C(0,0,0),TextXAlignment=XL},BN)
local bnM=T({Position=u(0,44,0,22),Size=u(0,244,0,16),TextSize=10,Font=FG,TextColor3=C(70,70,76),TextXAlignment=XL,TextTruncate=Enum.TextTruncate.AtEnd},BN)
local btok=0
function notify(ti,ms,col)
 if S.dnd or S.isSleep then return end
 bnT.Text=ti bnM.Text=ms bnI.BackgroundColor3=col or C(21,126,251) BN.Position=u(0,57,0,-60)
 tw(BN,.5,{Position=u(0,57,0,28)},Enum.EasingStyle.Back) btok+=1 local t=btok
 task.delay(3,function() if t==btok then tw(BN,.4,{Position=u(0,57,0,-60)}) end end)
end
function alert(ti,ms,bt)
 local o=F({Size=u(1,0,1,0),BackgroundColor3=C(0,0,0),BackgroundTransparency=1,ZIndex=140,Active=true},Sc) tw(o,.2,{BackgroundTransparency=.5})
 local c=N("CanvasGroup",{AnchorPoint=V2(.5,.5),Position=u(.5,0,.5,0),Size=u(0,250,0,118),BackgroundColor3=C(246,246,248),BorderSizePixel=0,GroupTransparency=1},o) Cr(14,c)
 local us=N("UIScale",{Scale=1.1},c) tw(c,.2,{GroupTransparency=0}) tw(us,.2,{Scale=1})
 T({Text=ti,Position=u(0,10,0,12),Size=u(1,-20,0,18),TextSize=13,Font=FB,TextColor3=C(0,0,0)},c)
 T({Text=ms,Position=u(0,14,0,32),Size=u(1,-28,0,44),TextSize=11,Font=FG,TextColor3=C(60,60,67),TextWrapped=true,TextYAlignment=Enum.TextYAlignment.Top},c)
 F({Position=u(0,0,0,81),Size=u(1,0,0,1),BackgroundColor3=C(200,200,205)},c)
 local w=250/#bt
 for i,b in ipairs(bt) do
  local k=B({Position=u(0,(i-1)*w,0,82),Size=u(0,w,0,36),BackgroundTransparency=1,Text=b[1],TextSize=13,TextColor3=b[2] or C(10,132,255),Font=i==#bt and FB or FG},c)
  if i>1 then F({Position=u(0,(i-1)*w,0,82),Size=u(0,1,0,36),BackgroundColor3=C(200,200,205)},c) end
  k.MouseButton1Click:Connect(function() o:Destroy() if b[3] then b[3]() end end)
 end
end
local function sw(par,x,y,k)
 local tr=B({Position=u(0,x,0,y),Size=u(0,44,0,26),BackgroundColor3=C(120,120,128)},par) Cr(13,tr)
 local kn=F({Position=u(0,2,0,2),Size=u(0,22,0,22),BackgroundColor3=WH},tr) Cr(11,kn)
 local function ap(v,an) local p,c=v and u(0,20,0,2) or u(0,2,0,2),v and C(52,199,89) or C(120,120,128) if an then tw(kn,.2,{Position=p}) tw(tr,.2,{BackgroundColor3=c}) else kn.Position=p tr.BackgroundColor3=c end end
 ap(S[k]) on(k,function(v) ap(v,true) end) tr.MouseButton1Click:Connect(function() setKey(k,not S[k]) end)
end
local function check(par,x,y,col) local f=F({Position=u(0,x,0,y),Size=u(0,16,0,16),BackgroundTransparency=1},par) rc(f,.3,.64,.36,.16,col,0,45) rc(f,.58,.46,.78,.16,col,0,-50) end
local function lockI(par,x,y) F({Position=u(0,x,0,y+5),Size=u(0,10,0,7),BackgroundColor3=C(142,142,147)},par) local s=F({Position=u(0,x+2,0,y),Size=u(0,6,0,8),BackgroundTransparency=1},par) Cr(3,s) N("UIStroke",{Color=C(142,142,147),Thickness=1.3},s) end
local function bars(par,x,y,col) for i,h in ipairs({4,7,10}) do F({Position=u(0,x+(i-1)*5,0,y+10-h),Size=u(0,3,0,h),BackgroundColor3=col},par) end end

local VH=N("CanvasGroup",{Position=u(0,-44,0,85),Size=u(0,34,0,140),BackgroundColor3=C(44,44,48),BorderSizePixel=0,GroupTransparency=1,ZIndex=170},Sc) Cr(12,VH)
local VT=F({Position=u(0,12,0,10),Size=u(0,10,0,92),BackgroundColor3=C(95,95,100)},VH) Cr(5,VT)
local VF=F({AnchorPoint=V2(0,1),Position=u(0,0,1,0),Size=u(1,0,.75,0),BackgroundColor3=WH},VT) Cr(5,VF)
F({Position=u(0,9,0,113),Size=u(0,5,0,8),BackgroundColor3=WH},VH) tri(VH,13,111,12,-1,WH)
local vtok=0
on("currentVolume",function(v) VF.Size=u(1,0,v/100,0) end)
function showVol() tw(VH,.25,{Position=u(0,10,0,85),GroupTransparency=0}) vtok+=1 local t=vtok task.delay(2,function() if t==vtok then tw(VH,.4,{Position=u(0,-44,0,85),GroupTransparency=1}) end end) end
local function vol(d) set("currentVolume",math.clamp(S.currentVolume+d,0,100)) showVol() end
local function setSleep(v)
 S.isSleep=v
 if v then closeCC() lockNow() SL.Visible=true tw(SL,.35,{BackgroundTransparency=0}) else tw(SL,.3,{BackgroundTransparency=1}).Completed:Connect(function() if not S.isSleep then SL.Visible=false end end) end
end
function lockNow() S.locked=true LS.Position=u(0,0,0,0) LS.Visible=true setBar(false) end
function unlock() if not S.locked then return end S.locked=false tw(LS,.5,{Position=u(0,0,-1,0)}).Completed:Connect(function() if not S.locked then LS.Visible=false end end) end
HW(40,34,function() setSleep(not S.isSleep) end) HW(392,30,function() vol(6.25) end) HW(430,30,function() vol(-6.25) end)
for i,tx in ipairs({"+","-"}) do T({Text=tx,Position=u(0,i==1 and 392 or 430,0,-6),Size=u(0,30,0,10),TextSize=9,Font=FB,ZIndex=2},R) end

local function slider(par,x,y,w,h,lab,get,put,key)
 local tr=B({Position=u(0,x,0,y),Size=u(0,w,0,h),BackgroundColor3=WH,BackgroundTransparency=.82,ClipsDescendants=true},par) Cr(14,tr)
 local fl=F({Size=u(get(),0,1,0),BackgroundColor3=WH},tr)
 T({Text=lab,Position=u(0,12,0,0),Size=u(1,-12,1,0),TextSize=10,Font=FB,TextColor3=C(130,130,138),TextXAlignment=XL},tr)
 local dr=false
 local function up(i) put(math.clamp((i.Position.X-tr.AbsolutePosition.X)/tr.AbsoluteSize.X,0,1)) end
 tr.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dr=true up(i) end end)
 UIS.InputChanged:Connect(function(i) if dr and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then up(i) end end)
 UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dr=false end end)
 on(key,function() fl.Size=u(get(),0,1,0) end)
end
local function musicUI(par,x,y,w,sz,tc,sc2)
 local ti=T({Position=u(0,x,0,y),Size=u(0,w,0,sz+4),TextSize=sz,Font=FB,TextColor3=tc,TextXAlignment=XL,TextTruncate=Enum.TextTruncate.AtEnd},par)
 local ar=T({Position=u(0,x,0,y+sz+4),Size=u(0,w,0,sz),TextSize=sz-2,Font=FG,TextColor3=sc2,TextXAlignment=XL},par)
 local ty=y+2*sz+10
 local tr=F({Position=u(0,x,0,ty),Size=u(0,w,0,3),BackgroundColor3=sc2,BackgroundTransparency=.55},par) Cr(2,tr)
 local fl=F({Size=u(S.prog/180,0,1,0),BackgroundColor3=tc},tr) Cr(2,fl)
 local cs,cy=sz+3,ty+10
 local pv=B({Position=u(0,x+w/2-cs*3.6,0,cy),Size=u(0,cs*2,0,cs+4),BackgroundTransparency=1},par) tri(pv,cs*.2,2,cs,-1,tc) tri(pv,cs*.7,2,cs,-1,tc)
 local pp=B({Position=u(0,x+w/2-cs,0,cy),Size=u(0,cs*2,0,cs+4),BackgroundTransparency=1},par)
 local nx=B({Position=u(0,x+w/2+cs*1.6,0,cy),Size=u(0,cs*2,0,cs+4),BackgroundTransparency=1},par) tri(nx,cs*.2,2,cs,1,tc) tri(nx,cs*.7,2,cs,1,tc)
 local function dpp(v) for _,c in ipairs(pp:GetChildren()) do c:Destroy() end if v then F({Position=u(0,cs*.55,0,2),Size=u(0,cs*.28,0,cs),BackgroundColor3=tc},pp) F({Position=u(0,cs*1.05,0,2),Size=u(0,cs*.28,0,cs),BackgroundColor3=tc},pp) else tri(pp,cs*.6,2,cs,1,tc) end end
 dpp(S.playing) on("playing",dpp)
 local function tt() ti.Text=TR[S.track][1] ar.Text=TR[S.track][2] end tt() on("track",tt)
 on("prog",function(v) fl.Size=u(v/180,0,1,0) end)
 pp.MouseButton1Click:Connect(function() set("playing",not S.playing) end)
 pv.MouseButton1Click:Connect(function() set("prog",0) set("track",(S.track-2)%#TR+1) end)
 nx.MouseButton1Click:Connect(function() set("prog",0) set("track",S.track%#TR+1) end)
end
local CCb=B({Size=u(1,0,1,0),BackgroundColor3=C(0,0,0),BackgroundTransparency=1,Visible=false,ZIndex=120},Sc)
local CCp=N("CanvasGroup",{Position=u(0,26,0,-200),Size=u(0,362,0,184),BackgroundColor3=C(34,34,38),BorderSizePixel=0,GroupTransparency=1,ZIndex=121,Active=true},Sc) Cr(26,CCp) N("UIStroke",{Color=WH,Transparency=.85,Thickness=1},CCp)
local function ctile(x,y,k,lab,col,gl,lf)
 local t=B({Position=u(0,x,0,y),Size=u(0,72,0,72),BackgroundColor3=WH,BackgroundTransparency=.82},CCp) Cr(18,t)
 local g=F({Position=u(.5,-13,0,11),Size=u(0,26,0,26),BackgroundTransparency=1},t)
 local lb=T({Text=lab,Position=u(0,2,1,-24),Size=u(1,-4,0,18),TextSize=8,Font=FB,TextTruncate=Enum.TextTruncate.AtEnd},t)
 local cut=gl(g)
 local function ap(v) tw(t,.2,{BackgroundColor3=v and col or WH,BackgroundTransparency=v and 0 or .82}) if cut then cut.BackgroundColor3=v and col or C(82,82,86) end if lf then lb.Text=lf() end end
 ap(S[k]) on(k,ap) if lf then on("net",function() lb.Text=lf() end) end
 t.MouseButton1Click:Connect(function() setKey(k,not S[k]) end)
end
ctile(12,12,"wifi","Wi-Fi Off",C(10,132,255),function(g) rc(g,.2,.85,.2,.3,WH,.3) rc(g,.5,.72,.2,.56,WH,.3) rc(g,.8,.58,.2,.84,WH,.3) end,function() return S.net or (S.wifi and "Not Connected" or "Wi-Fi Off") end)
ctile(96,12,"bt","Bluetooth",C(10,132,255),function(g) gt(g,"B",.5,.5,.9,1,WH) end)
ctile(12,96,"dnd","Do Not Disturb",C(94,92,230),function(g) rc(g,.5,.5,.9,.9,WH,.5) return rc(g,.72,.36,.78,.78,C(82,82,86),.5) end)
ctile(96,96,"eye","Eye Protection",C(255,149,0),function(g) rc(g,.5,.5,1,.5,WH,.5) rc(g,.5,.5,.42,.42,C(40,40,44),.5) rc(g,.5,.5,.16,.16,WH,.5) end)
local mcd=F({Position=u(0,180,0,12),Size=u(0,170,0,70),BackgroundColor3=WH,BackgroundTransparency=.82},CCp) Cr(18,mcd) musicUI(mcd,12,8,146,11,WH,C(190,190,198))
slider(CCp,180,90,170,36,"Brightness",function() return (S.bright-.15)/.85 end,function(v) set("bright",.15+.85*v) end,"bright")
slider(CCp,180,134,170,34,"Volume",function() return S.currentVolume/100 end,function(v) set("currentVolume",math.floor(v*100+.5)) end,"currentVolume")
function openCC() if ccOpen or S.isSleep then return end ccOpen=true CCb.Visible=true tw(CCb,.3,{BackgroundTransparency=.45}) CCp.Position=u(0,26,0,-200) tw(CCp,.45,{Position=u(0,26,0,26),GroupTransparency=0}) end
function closeCC() if not ccOpen then return end ccOpen=false tw(CCb,.3,{BackgroundTransparency=1}) tw(CCp,.35,{Position=u(0,26,0,-200),GroupTransparency=1}).Completed:Connect(function() if not ccOpen then CCb.Visible=false end end) end
CCb.MouseButton1Click:Connect(closeCC)
SBb.MouseButton1Click:Connect(function() if ccOpen then closeCC() else openCC() end end)

local function hdr(b,txt,col) T({Text=txt,Position=u(0,20,0,34),Size=u(0,300,0,34),TextSize=26,Font=FB,TextColor3=col,TextXAlignment=XL},b) end
function launch(id,btn)
 if busy or S.activeAppId or S.isSleep or S.locked or not G.Enabled then return end
 local a=byId[id] busy=true S.activeAppId=id closeCC()
 local bp,bsz=V2(184,132),V2(46,46) if btn and btn.Parent then bp,bsz=geom(btn) end
 Win=N("CanvasGroup",{Size=u(0,bsz.X,0,bsz.Y),Position=u(0,bp.X,0,bp.Y),BackgroundColor3=a.light and C(242,242,247) or C(18,18,20),BorderSizePixel=0,GroupTransparency=.5,ZIndex=20},Sc)
 WC=Cr(12,Win) local body=F({Size=u(0,414,0,310),BackgroundTransparency=1},Win)
 WS=N("UIScale",{Scale=math.max(bsz.X/414,.05)},body)
 S.cl=(build[id] or build.generic)(body,a) setBar(a.light)
 tw(Win,.5,{Size=u(1,0,1,0),Position=u(0,0,0,0),GroupTransparency=0}) tw(WC,.5,{CornerRadius=UDim.new(0,0)}) tw(WS,.5,{Scale=1}).Completed:Connect(function() busy=false end)
end
function closeApp()
 if busy or not S.activeAppId then return end busy=true
 local id=S.activeAppId local b=refs[S.page][id] or refs[0][id] or refs[1][id]
 local pos,sz=V2(184,132),V2(46,46) if b and b.Parent then pos,sz=geom(b) end
 if S.cl then pcall(S.cl) S.cl=nil end setBar(false) local w=Win
 tw(w,.45,{Size=u(0,sz.X,0,sz.Y),Position=u(0,pos.X,0,pos.Y),GroupTransparency=.6}) tw(WC,.45,{CornerRadius=UDim.new(0,12)})
 tw(WS,.45,{Scale=sz.X/414}).Completed:Connect(function() w:Destroy() S.activeAppId=nil busy=false end)
end
function go(id) closeApp() task.delay(.6,function() launch(id,refs[S.page][id] or refs[0][id]) end) end
local function deleteApp(a) for i,x in ipairs(S.installedApps) do if x.id==a.id then table.remove(S.installedApps,i) break end end refs[0][a.id]=nil refs[1][a.id]=nil renderHome() renderLib() notify("App Removed",a.name.." was deleted",C(255,59,48)) end
local ctx
function ctxMenu(a,btn)
 if ctx then ctx:Destroy() end local bp,bsz=geom(btn)
 ctx=B({Size=u(1,0,1,0),BackgroundTransparency=1,ZIndex=130},Sc)
 local m=F({Position=u(0,math.clamp(bp.X+bsz.X/2-70,8,266),0,math.clamp(bp.Y+bsz.Y+8,24,250)),Size=u(0,140,0,40),BackgroundColor3=C(236,236,240)},ctx) Cr(12,m)
 local d=B({Size=u(1,0,1,0),BackgroundTransparency=1,Text="Delete App",TextSize=13,TextColor3=C(255,59,48),Font=FM},m)
 local c=ctx ctx.MouseButton1Click:Connect(function() c:Destroy() ctx=nil end)
 d.MouseButton1Click:Connect(function() c:Destroy() ctx=nil alert('Delete "'..a.name..'"?',"Deleting this app will also delete its data.",{{"Cancel"},{"Delete",C(255,59,48),function() deleteApp(a) end}}) end)
end
local function homeBtn() if S.isSleep then setSleep(false) elseif S.locked then unlock() elseif ccOpen then closeCC() elseif S.activeAppId then closeApp() else setPage(0) end end
HB.MouseButton1Click:Connect(homeBtn)
HIB.MouseButton1Click:Connect(function() if S.locked then unlock() elseif ccOpen then closeCC() elseif S.activeAppId then closeApp() elseif S.page==1 then setPage(0) end end)

build.camera=function(b,a)
 local vp=N("ViewportFrame",{Size=u(1,0,1,0),BackgroundColor3=C(135,175,215),Ambient=C(170,170,170),LightColor=WH},b)
 local cm=N("Camera",{FieldOfView=70},vp) vp.CurrentCamera=cm
 pcall(function()
  local ch=LP.Character local hrp=ch and ch:FindFirstChild("HumanoidRootPart") if not hrp then return end
  ch.Archivable=true local cc=ch:Clone() if cc then for _,d in ipairs(cc:GetDescendants()) do if d:IsA("LuaSourceContainer") then d:Destroy() end end cc.Parent=vp end
  local n=0
  for _,p in ipairs(workspace:GetDescendants()) do
   if n>350 then break end
   if p:IsA("BasePart") and p~=workspace.Terrain and not p:IsDescendantOf(ch) and p.Size.Magnitude>1 and (p.Position-hrp.Position).Magnitude<150 then
    local ok,cl=pcall(function() return p:Clone() end)
    if ok and cl then for _,d in ipairs(cl:GetChildren()) do if d:IsA("LuaSourceContainer") or d:IsA("Sound") or d:IsA("ParticleEmitter") then d:Destroy() end end cl.Anchored=true cl.Parent=vp n+=1 end
   end
  end
 end)
 local cn=RS.RenderStepped:Connect(function() local wc=workspace.CurrentCamera if wc then cm.CFrame=wc.CFrame cm.FieldOfView=wc.FieldOfView end end)
 F({Position=u(0,0,0,232),Size=u(0,414,0,78),BackgroundColor3=C(0,0,0),BackgroundTransparency=.4},b)
 T({Text="PHOTO",Position=u(0,0,0,236),Size=u(0,414,0,14),TextSize=10,Font=FB,TextColor3=C(255,214,10),TextXAlignment=XC},b)
 local th=F({Position=u(0,22,0,250),Size=u(0,44,0,44),BackgroundColor3=C(30,30,32),ClipsDescendants=true},b) Cr(8,th) N("UIStroke",{Color=WH,Thickness=1.5},th)
 local ring=B({Position=u(0,179,0,252),Size=u(0,56,0,56),BackgroundTransparency=1},b) Cr(28,ring) N("UIStroke",{Color=WH,Thickness=3},ring)
 local inn=F({Position=u(0,6,0,6),Size=u(0,44,0,44),BackgroundColor3=WH,Active=false},ring) Cr(22,inn)
 local fl=F({Size=u(1,0,1,0),BackgroundColor3=WH,BackgroundTransparency=1,ZIndex=30,Active=false},b)
 ring.MouseButton1Click:Connect(function()
  fl.BackgroundTransparency=0 tw(fl,.4,{BackgroundTransparency=1}) inn.Size=u(0,36,0,36) inn.Position=u(0,10,0,10) tw(inn,.25,{Size=u(0,44,0,44),Position=u(0,6,0,6)})
  for _,c in ipairs(th:GetChildren()) do if c:IsA("ViewportFrame") then c:Destroy() end end
  local cp=vp:Clone() cp.Size=u(0,59,0,44) cp.Position=u(0,-7,0,0) cp.Parent=th cp.CurrentCamera=cp:FindFirstChildOfClass("Camera")
  local sn=cp:Clone() table.insert(S.photos,sn) if #S.photos>12 then table.remove(S.photos,1) end
 end)
 return function() cn:Disconnect() end
end
build.photos=function(b,a) hdr(b,"Photos",C(0,0,0))
 T({Text=#S.photos==0 and "No photos yet. Take some with Camera." or #S.photos.." photo"..(#S.photos==1 and "" or "s"),Position=u(0,20,0,68),Size=u(0,374,0,14),TextSize=10,TextColor3=C(142,142,147),TextXAlignment=XL},b)
 local g=F({Position=u(0,20,0,90),Size=u(0,374,0,210),BackgroundTransparency=1},b) N("UIGridLayout",{CellSize=u(0,86,0,64),CellPadding=u(0,6,0,6)},g)
 for _,sn in ipairs(S.photos) do local cell=F({BackgroundColor3=C(30,30,32),ClipsDescendants=true},g) Cr(6,cell) local c=sn:Clone() c.Size=u(0,86,0,64) c.Position=u(0,0,0,0) c.Parent=cell c.CurrentCamera=c:FindFirstChildOfClass("Camera") end
 return function() end
end
build.notes=function(b,a) hdr(b,"Notes",C(0,0,0))
 local tb=N("TextBox",{Position=u(0,20,0,76),Size=u(0,374,0,200),BackgroundColor3=C(255,252,235),Text=S.note,PlaceholderText="Tap to write...",MultiLine=true,ClearTextOnFocus=false,TextWrapped=true,TextXAlignment=XL,TextYAlignment=Enum.TextYAlignment.Top,Font=FM,TextSize=13,TextColor3=C(0,0,0),BorderSizePixel=0},b) Cr(10,tb) N("UIPadding",{PaddingLeft=UDim.new(0,10),PaddingTop=UDim.new(0,8)},tb)
 tb:GetPropertyChangedSignal("Text"):Connect(function() S.note=tb.Text end) return function() end
end
build.music=function(b,a)
 local bg=F({Size=u(1,0,1,0),BackgroundColor3=C(60,20,40)},b) N("UIGradient",{Rotation=90,Color=ColorSequence.new(C(120,30,60),C(20,10,20))},bg)
 local ar=tile(a,b,30,70,130,false)
 musicUI(b,182,86,200,15,WH,C(190,170,178)) return function() end
end
build.clock=function(b,a) local alive=true
 local cx,cy=207,140 local face=F({AnchorPoint=V2(.5,.5),Position=u(0,cx,0,cy),Size=u(0,196,0,196),BackgroundColor3=C(30,30,33)},b) Cr(98,face) N("UIStroke",{Color=C(70,70,76),Thickness=3},face)
 for i=0,11 do local an=math.rad(i*30) F({AnchorPoint=V2(.5,.5),Position=u(0,98+math.sin(an)*88,0,98-math.cos(an)*88),Size=u(0,i%3==0 and 3 or 2,0,i%3==0 and 10 or 6),Rotation=i*30,BackgroundColor3=WH},face)
  if i%3==0 then T({Text=tostring(i==0 and 12 or i),Position=u(0,98+math.sin(an)*68-10,0,98-math.cos(an)*68-8),Size=u(0,20,0,16),TextSize=13,Font=FB},face) end end
 local function hand(len,w,col) local h=F({AnchorPoint=V2(.5,.5),Size=u(0,w,0,len),BackgroundColor3=col},face) Cr(w/2,h) return h end
 local hh,mh,sh=hand(46,4,WH),hand(70,3,WH),hand(78,1.5,C(255,149,10))
 F({AnchorPoint=V2(.5,.5),Position=u(.5,0,.5,0),Size=u(0,8,0,8),BackgroundColor3=C(255,149,10),ZIndex=5},face).ZIndex=5
 local function pl(h,len,deg) local a2=math.rad(deg) h.Position=u(0,98+math.sin(a2)*len/2,0,98-math.cos(a2)*len/2) h.Rotation=deg end
 local dg=T({Position=u(0,0,0,252),Size=u(0,414,0,30),TextSize=22,Font=FB,TextXAlignment=XC},b)
 task.spawn(function() while alive do local t=os.date("*t") pl(hh,46,(t.hour%12+t.min/60)*30) pl(mh,70,(t.min+t.sec/60)*6) pl(sh,78,t.sec*6) dg.Text=os.date("%H:%M:%S") task.wait(.25) end end)
 return function() alive=false end
end
build.stopwatch=function(b,a) local alive,run,el,t0=true,false,0,0
 local d=T({Position=u(0,0,0,70),Size=u(0,414,0,70),TextSize=54,Font=FG,TextXAlignment=XC,Text="00:00.00"},b)
 local function mk(x,txt,col) local k=B({Position=u(0,x,0,190),Size=u(0,72,0,72),BackgroundColor3=col,Text=txt,TextSize=13},b) Cr(36,k) return k end
 local rs,st=mk(90,"Reset",C(60,60,64)),mk(252,"Start",C(48,209,88))
 rs.MouseButton1Click:Connect(function() if not run then el=0 d.Text="00:00.00" end end)
 st.MouseButton1Click:Connect(function() run=not run if run then t0=tick()-el st.Text="Stop" st.BackgroundColor3=C(255,69,58) else st.Text="Start" st.BackgroundColor3=C(48,209,88) end end)
 task.spawn(function() while alive do if run then el=tick()-t0 d.Text=string.format("%02d:%05.2f",math.floor(el/60),el%60) end task.wait(.03) end end)
 return function() alive=false end
end
build.weather=function(b,a)
 local bg=F({Size=u(1,0,1,0),BackgroundColor3=C(60,140,230)},b) N("UIGradient",{Rotation=90,Color=ColorSequence.new(C(40,110,220),C(150,200,250))},bg)
 T({Text="Baseplate",Position=u(0,0,0,50),Size=u(0,414,0,30),TextSize=24,Font=FB,TextXAlignment=XC},b)
 T({Text="72°",Position=u(0,0,0,86),Size=u(0,414,0,90),TextSize=76,Font=FG,TextXAlignment=XC},b)
 T({Text="Sunny  H:76°  L:61°",Position=u(0,0,0,180),Size=u(0,414,0,20),TextSize=13,TextXAlignment=XC},b) return function() end
end
build.calc=function(b,a)
 local ds=T({Position=u(0,20,0,28),Size=u(0,374,0,64),TextScaled=true,Font=FG,TextXAlignment=XR,Text="0"},b) N("UITextSizeConstraint",{MaxTextSize=46},ds)
 local cur,acc,op,fresh="0",nil,nil,true
 local function fmt(n) if n~=n or math.abs(n)==math.huge then return "Error" end return string.format("%.9g",n) end
 local function cal(x,y,o) if o=="+" then return x+y elseif o=="-" then return x-y elseif o=="x" then return x*y else return y~=0 and x/y or 0/0 end end
 local function pr(k)
  if cur=="Error" then cur="0" acc=nil op=nil fresh=true end
  if tonumber(k) then if fresh then cur=k fresh=false else cur=(cur=="0") and k or cur..k end
  elseif k=="." then if fresh then cur="0." fresh=false elseif not cur:find("%.") then cur=cur.."." end
  elseif k=="C" then cur="0" acc=nil op=nil fresh=true
  elseif k=="+/-" then cur=fmt(-(tonumber(cur) or 0))
  elseif k=="%" then cur=fmt((tonumber(cur) or 0)/100)
  elseif k=="=" then if op and acc then cur=fmt(cal(acc,tonumber(cur) or 0,op)) acc=nil op=nil fresh=true end
  else if op and acc and not fresh then acc=cal(acc,tonumber(cur) or 0,op) cur=fmt(acc) elseif not acc or fresh then acc=tonumber(cur) end op=k fresh=true end
  ds.Text=cur
 end
 local rows={{"C","+/-","%","/"},{"7","8","9","x"},{"4","5","6","-"},{"1","2","3","+"},{"0",".","="}}
 for r,row in ipairs(rows) do local x=14 for _,k in ipairs(row) do
  local w=k=="0" and 184 or 90 local top=(k=="C" or k=="+/-" or k=="%") local opk=(k=="/" or k=="x" or k=="-" or k=="+" or k=="=")
  local bt=B({Position=u(0,x,0,98+(r-1)*40),Size=u(0,w,0,34),BackgroundColor3=top and C(165,165,170) or opk and C(255,159,10) or C(58,58,62),Text=k,TextSize=15,TextColor3=top and C(0,0,0) or WH},b) Cr(17,bt)
  bt.MouseButton1Click:Connect(function() pr(k) end) x+=w+8 end end
 return function() end
end
build.generic=function(b,a) return function() end end

build.flappy=function(b,a)
 local W,H,GY,PW,GAP,SPD,GRV,FLAP=414,310,268,54,92,125,950,-300
 local sky=F({Size=u(1,0,1,0),BackgroundColor3=C(112,197,206),ClipsDescendants=true},b) N("UIGradient",{Rotation=90,Color=ColorSequence.new(C(78,192,202),C(195,236,214))},sky)
 for i,cx in ipairs({50,190,320}) do local cl=F({Position=u(0,cx,0,36+i*20),Size=u(0,70,0,22),BackgroundColor3=WH,BackgroundTransparency=.4},sky) Cr(11,cl) end
 local pc=F({Size=u(1,0,1,0),BackgroundTransparency=1},sky)
 local gr=F({Position=u(0,0,0,GY),Size=u(1,0,0,H-GY),BackgroundColor3=C(222,216,149),ZIndex=5},sky) F({Size=u(1,0,0,8),BackgroundColor3=C(115,191,46),ZIndex=6},gr)
 local stripes={} for i=1,12 do local f=F({Size=u(0,14,0,6),Position=u(0,(i-1)*40,0,18),BackgroundColor3=C(196,186,118),ZIndex=6},gr) stripes[i]={f=f,x=(i-1)*40} end
 local bd=F({AnchorPoint=V2(.5,.5),Size=u(0,28,0,22),BackgroundColor3=C(250,213,60),ZIndex=8},sky) Cr(11,bd) N("UIStroke",{Color=C(90,65,20),Thickness=1.5},bd)
 rc(bd,.7,.35,.3,.38,WH,.5) rc(bd,.76,.37,.14,.18,C(0,0,0),.5) rc(bd,.97,.62,.36,.3,C(240,100,40),.4) rc(bd,.32,.62,.42,.32,C(255,240,150),.5)
 local sT=T({Text="0",Position=u(0,0,0,34),Size=u(0,414,0,44),TextSize=36,Font=FB,TextStrokeTransparency=0,TextXAlignment=XC,ZIndex=9},sky)
 local ms=T({Text="Tap to Start",Position=u(0,0,0,130),Size=u(0,414,0,70),TextSize=18,Font=FB,TextStrokeTransparency=0,TextXAlignment=XC,ZIndex=9},sky)
 local fl=F({Size=u(1,0,1,0),BackgroundColor3=WH,BackgroundTransparency=1,ZIndex=12},sky)
 local st,by,vy,score,pipes,sp,d0="ready",150,0,0,{},0,0
 local function reset() for _,p in ipairs(pipes) do p.t:Destroy() p.b:Destroy() end pipes={} st="ready" by=150 vy=0 score=0 sp=0 sT.Text="0" ms.Text="Tap to Start" ms.Visible=true bd.Rotation=0 end
 local function die() if st=="dead" then return end st="dead" d0=tick() S.best=math.max(S.best,score) ms.Text="Game Over\nScore "..score.."   Best "..S.best.."\nTap to retry" ms.Visible=true fl.BackgroundTransparency=.2 tw(fl,.4,{BackgroundTransparency=1}) end
 local function flap() if st=="dead" then if tick()-d0>.5 then reset() end return end if st=="ready" then st="play" ms.Visible=false end vy=FLAP end
 local function pipe(par,x,y,h,cap) local p=F({Position=u(0,x,0,y),Size=u(0,PW,0,h),BackgroundColor3=C(115,191,46)},par) N("UIStroke",{Color=C(70,120,30),Thickness=2},p) local c=F({Position=u(0,-3,cap and 0 or 1,cap and 0 or -14),Size=u(0,PW+6,0,14),BackgroundColor3=C(130,210,56)},p) N("UIStroke",{Color=C(70,120,30),Thickness=2},c) return p end
 local cn=RS.RenderStepped:Connect(function(dt)
  dt=math.min(dt,.05)
  if st~="dead" then for _,s in ipairs(stripes) do s.x-=SPD*dt if s.x<-20 then s.x+=W+40 end s.f.Position=u(0,s.x,0,18) end end
  if st=="ready" then by=150+math.sin(tick()*5)*5 bd.Position=u(0,100,0,by) return end
  vy+=GRV*dt by+=vy*dt
  if st=="play" then
   sp-=dt if sp<=0 then sp=1.55 local gy=math.random(50,GY-GAP-40) table.insert(pipes,{x=W+10,gy=gy,c=false,t=pipe(pc,W+10,0,gy,false),b=pipe(pc,W+10,gy+GAP,GY-gy-GAP,true)}) end
   for i=#pipes,1,-1 do local p=pipes[i] p.x-=SPD*dt p.t.Position=u(0,p.x,0,0) p.b.Position=u(0,p.x,0,p.gy+GAP)
    if not p.c and p.x+PW<89 then p.c=true score+=1 sT.Text=tostring(score) end
    if p.x<-PW-10 then p.t:Destroy() p.b:Destroy() table.remove(pipes,i)
    elseif 111>p.x and 89<p.x+PW and (by-10<p.gy or by+10>p.gy+GAP) then die() end
   end
   if by+10>=GY then by=GY-10 die() end if by<10 then by=10 vy=0 end
  elseif by+10>=GY then by=GY-10 vy=0 end
  bd.Position=u(0,100,0,by) bd.Rotation=math.clamp(vy*.12,-25,80)
 end)
 local kc=UIS.InputBegan:Connect(function(i) if i.KeyCode==Enum.KeyCode.Space then flap() end end)
 B({Size=u(1,0,1,0),BackgroundTransparency=1,ZIndex=15},sky).MouseButton1Down:Connect(flap)
 return function() cn:Disconnect() kc:Disconnect() end
end

build.maps=function(b,a)
 local mf=F({Size=u(1,0,1,0),BackgroundColor3=C(228,226,220),ClipsDescendants=true},b)
 local z,trk,alive=.8,nil,true
 local vl,hl={},{} for i=1,25 do vl[i]=F({Size=u(0,1,1,0),BackgroundColor3=C(206,204,197),ZIndex=1},mf) end for i=1,19 do hl[i]=F({Size=u(1,0,0,1),BackgroundColor3=C(206,204,197),ZIndex=1},mf) end
 local fps={}
 pcall(function()
  local ch=LP.Character local hrp=ch and ch:FindFirstChild("HumanoidRootPart")
  for _,p in ipairs(workspace:GetDescendants()) do
   if #fps>=200 then break end
   if p:IsA("BasePart") and p~=workspace.Terrain and p.Transparency<.9 and p.Size.X*p.Size.Z>24 then
    local m=p:FindFirstAncestorOfClass("Model")
    if not (m and m:FindFirstChildOfClass("Humanoid")) and (not hrp or (p.Position-hrp.Position).Magnitude<900) then
     local _,yy=p.CFrame:ToOrientation() local big=p.Size.X*p.Size.Z>20000
     local f=F({AnchorPoint=V2(.5,.5),BackgroundColor3=p.Color:Lerp(WH,big and .55 or .3),BackgroundTransparency=big and 0 or .1,ZIndex=big and 2 or 3},mf) Cr(2,f)
     table.insert(fps,{f=f,p=p.Position,sx=p.Size.X,sz=p.Size.Z,r=-math.deg(yy)})
    end
   end
  end
 end)
 local mk={}
 local function marker(pl)
  if mk[pl] then return mk[pl] end local me=pl==LP
  local d=F({AnchorPoint=V2(.5,.5),Size=u(0,me and 16 or 14,0,me and 16 or 14),BackgroundColor3=me and C(10,132,255) or C(255,59,48),ZIndex=10},mf) Cr(8,d) N("UIStroke",{Color=WH,Thickness=2},d)
  T({AnchorPoint=V2(.5,1),Position=u(.5,0,0,-3),Size=u(0,80,0,12),Text=me and "You" or pl.DisplayName,TextSize=9,Font=FB,TextColor3=C(30,30,34),TextStrokeColor3=WH,TextStrokeTransparency=.2},d)
  mk[pl]=d return d
 end
 local function cpos(pl) local c=pl and pl.Character local h=c and c:FindFirstChild("HumanoidRootPart") return h and h.Position end
 local function upd()
  local c=cpos(trk or LP) or Vector3.new()
  local sp=50*z if sp<18 then sp*=4 end
  local x0,y0=(207-c.X*z)%sp,(155-c.Z*z)%sp
  for i,l in ipairs(vl) do local x=x0+(i-1)*sp l.Visible=x<414 l.Position=u(0,x,0,0) end
  for i,l in ipairs(hl) do local y=y0+(i-1)*sp l.Visible=y<310 l.Position=u(0,0,0,y) end
  for _,p in ipairs(fps) do
   local px,py,w,h=207+(p.p.X-c.X)*z,155+(p.p.Z-c.Z)*z,p.sx*z,p.sz*z local r=math.max(w,h)*.75
   local vis=math.abs(px-207)-r<230 and math.abs(py-155)-r<175 p.f.Visible=vis
   if vis then p.f.Position=u(0,px,0,py) p.f.Size=u(0,w,0,h) p.f.Rotation=p.r end
  end
  for pl,m in pairs(mk) do if not pl.Parent then m:Destroy() mk[pl]=nil end end
  for _,pl in ipairs(P:GetPlayers()) do
   local m=marker(pl) local pos=cpos(pl)
   if pos then local sx,sy=207+(pos.X-c.X)*z,155+(pos.Z-c.Z)*z local cx2,cy2=math.clamp(sx,12,402),math.clamp(sy,40,298) m.Position=u(0,cx2,0,cy2) m.BackgroundTransparency=(cx2~=sx or cy2~=sy) and .4 or 0 m.Visible=true else m.Visible=false end
  end
 end
 local pill=F({Position=u(0,14,0,26),Size=u(0,180,0,26),BackgroundColor3=C(250,250,252),BackgroundTransparency=.08,ZIndex=20},b) Cr(13,pill)
 local pt=T({Position=u(0,12,0,0),Size=u(1,-12,1,0),TextSize=11,Font=FB,TextColor3=C(30,30,34),TextXAlignment=XL,ZIndex=21},pill)
 local function zb(y,txt,cb) local x=B({Position=u(0,372,0,y),Size=u(0,30,0,30),BackgroundColor3=C(250,250,252),Text=txt,TextSize=18,TextColor3=C(40,40,46),ZIndex=20},b) Cr(8,x) x.MouseButton1Click:Connect(cb) return x end
 zb(60,"+",function() z=math.clamp(z*1.35,.12,3) upd() end) zb(94,"-",function() z=math.clamp(z/1.35,.12,3) upd() end)
 local lc=zb(128,"",function() trk=nil z=.8 upd() end) local rg=F({AnchorPoint=V2(.5,.5),Position=u(.5,0,.5,0),Size=u(0,14,0,14),BackgroundTransparency=1,ZIndex=21},lc) Cr(7,rg) N("UIStroke",{Color=C(10,132,255),Thickness=2},rg) rc(rg,.5,.5,.4,.4,C(10,132,255),.5)
 local sh=F({Position=u(0,10,0,198),Size=u(0,394,0,104),BackgroundColor3=C(250,250,252),BackgroundTransparency=.06,ZIndex=20},b) Cr(16,sh)
 T({Text="Players",Position=u(0,14,0,6),Size=u(0,100,0,16),TextSize=12,Font=FB,TextColor3=C(30,30,34),TextXAlignment=XL,ZIndex=21},sh)
 local sf=N("ScrollingFrame",{Position=u(0,8,0,26),Size=u(1,-16,1,-32),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=2,AutomaticCanvasSize=Enum.AutomaticSize.Y,CanvasSize=u(0,0,0,0),ZIndex=21},sh)
 N("UIListLayout",{Padding=UDim.new(0,4)},sf)
 local dl={}
 local function dist() local mp=cpos(LP) for pl,l in pairs(dl) do local pp=cpos(pl) l.Text=(mp and pp) and (math.floor((pp-mp).Magnitude).." studs") or "--" end end
 local function rows()
  if not alive then return end
  for _,c in ipairs(sf:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end dl={}
  pt.Text="Tracking: "..(trk and trk.DisplayName or "You")
  for _,pl in ipairs(P:GetPlayers()) do
   local r=F({Size=u(1,-4,0,24),BackgroundTransparency=1,ZIndex=22},sf)
   local dt=F({Position=u(0,4,0,7),Size=u(0,10,0,10),BackgroundColor3=pl==LP and C(10,132,255) or C(255,59,48),ZIndex=23},r) Cr(5,dt)
   T({Text=pl==LP and pl.DisplayName.." (You)" or pl.DisplayName,Position=u(0,22,0,0),Size=u(0,170,1,0),TextSize=11,Font=FM,TextColor3=C(30,30,34),TextXAlignment=XL,TextTruncate=Enum.TextTruncate.AtEnd,ZIndex=23},r)
   dl[pl]=T({Position=u(0,200,0,0),Size=u(0,100,1,0),TextSize=10,Font=FG,TextColor3=C(110,110,118),TextXAlignment=XR,ZIndex=23},r)
   local tb=B({Position=u(0,306,0,3),Size=u(0,66,0,18),BackgroundColor3=(trk==pl) and C(52,199,89) or C(10,132,255),Text=(trk==pl) and "Tracking" or "Track",TextSize=10,ZIndex=23},r) Cr(9,tb)
   tb.MouseButton1Click:Connect(function() if pl==LP then trk=nil else trk=(trk==pl) and nil or pl end rows() upd() end)
  end
  dist()
 end
 rows() upd()
 task.spawn(function() local n=0 while alive do upd() n+=1 if n%5==0 then dist() end task.wait(.12) end end)
 local c1=P.PlayerAdded:Connect(function() task.delay(.2,rows) end) local c2=P.PlayerRemoving:Connect(function() task.delay(.3,rows) end)
 return function() alive=false c1:Disconnect() c2:Disconnect() end
end

local function getBtn(par,a,x,y,w,h,bg,fg)
 local g=B({Position=u(0,x,0,y),Size=u(0,w,0,h),BackgroundColor3=bg,TextSize=11,TextColor3=fg},par) Cr(h/2,g)
 local function lab() g.Text=hasApp(a.id) and "OPEN" or "GET" end lab() local dl=false
 g.MouseButton1Click:Connect(function()
  if dl then return end
  if hasApp(a.id) then go(a.id) return end
  if not S.net then alert("Cannot Connect to App Store","Connect to a Wi-Fi network in Settings to download apps.",{{"OK"},{"Settings",nil,function() go("settings") end}}) return end
  dl=true g.Text=""
  local sp=F({Size=u(0,14,0,14),Position=u(.5,-7,.5,-7),BackgroundTransparency=1},g) Cr(7,sp)
  local st=N("UIStroke",{Color=fg,Thickness=2},sp)
  local gr=N("UIGradient",{Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(.6,0),NumberSequenceKeypoint.new(.61,1),NumberSequenceKeypoint.new(1,1)})},st)
  task.spawn(function()
   local t,d=0,1.8+math.random()*1.6
   while t<d do t+=RS.RenderStepped:Wait() gr.Rotation=(gr.Rotation+14)%360 end
   sp:Destroy() dl=false
   if not S.net then alert("Download Failed","The Wi-Fi connection was lost.",{{"OK"}}) lab() return end
   if not hasApp(a.id) then table.insert(S.installedApps,a) end renderHome() renderLib() lab() notify(a.name,"Downloaded and installed",a.col)
  end)
 end)
end
build.store=function(b,a)
 T({Text=os.date("%A %d %B"):upper(),Position=u(0,20,0,22),Size=u(0,300,0,12),TextSize=9,TextColor3=C(142,142,147),Font=FB,TextXAlignment=XL},b) hdr(b,"Today",C(0,0,0))
 local av=F({Position=u(0,372,0,38),Size=u(0,26,0,26),BackgroundColor3=C(10,132,255)},b) Cr(13,av) rc(av,.5,.38,.34,.34,WH,.5) rc(av,.5,.82,.6,.4,WH,.5)
 local sf=N("ScrollingFrame",{Position=u(0,0,0,76),Size=u(1,0,1,-76),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=3,AutomaticCanvasSize=Enum.AutomaticSize.Y,CanvasSize=u(0,0,0,0)},b)
 N("UIListLayout",{Padding=UDim.new(0,10),HorizontalAlignment=Enum.HorizontalAlignment.Center,SortOrder=Enum.SortOrder.LayoutOrder},sf) N("UIPadding",{PaddingBottom=UDim.new(0,30)},sf)
 local fa=byId.flappy
 local fc=F({Size=u(0,374,0,150),BackgroundColor3=C(60,180,190),LayoutOrder=1,ClipsDescendants=true},sf) Cr(16,fc) N("UIGradient",{Rotation=45,Color=ColorSequence.new(C(90,205,215),C(30,140,160))},fc)
 T({Text="GAME OF THE DAY",Position=u(0,16,0,14),Size=u(0,200,0,12),TextSize=9,Font=FB,TextTransparency=.25,TextXAlignment=XL},fc)
 T({Text=fa.name,Position=u(0,16,0,28),Size=u(0,220,0,28),TextSize=22,Font=FB,TextXAlignment=XL},fc)
 T({Text=fa.sub,Position=u(0,16,0,58),Size=u(0,200,0,30),TextSize=11,Font=FG,TextWrapped=true,TextXAlignment=XL},fc)
 tile(fa,fc,262,28,90,false) getBtn(fc,fa,16,108,60,26,WH,C(30,140,160))
 T({Text="Top Apps",Size=u(0,374,0,22),TextSize=16,Font=FB,TextColor3=C(0,0,0),TextXAlignment=XL,LayoutOrder=2},sf)
 local gr=F({Size=u(0,374,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1,LayoutOrder=3},sf) N("UIGridLayout",{CellSize=u(0,183,0,70),CellPadding=u(0,8,0,8)},gr)
 for _,s in ipairs(ALL) do if not s.sys and s.id~="flappy" then
  local cd=F({BackgroundColor3=WH},gr) Cr(12,cd) tile(s,cd,8,12,46,false)
  T({Text=s.name,Position=u(0,62,0,10),Size=u(0,114,0,14),TextSize=11,Font=FB,TextColor3=C(0,0,0),TextXAlignment=XL,TextTruncate=Enum.TextTruncate.AtEnd},cd)
  T({Text=s.sub,Position=u(0,62,0,24),Size=u(0,114,0,12),TextSize=9,Font=FG,TextColor3=C(142,142,147),TextXAlignment=XL,TextTruncate=Enum.TextTruncate.AtEnd},cd)
  getBtn(cd,s,62,42,50,20,C(235,235,240),C(10,132,255))
 end end
 return function() end
end

build.settings=function(b,a)
 local alive,pg=true,"main" local cont=F({Size=u(1,0,1,0),BackgroundTransparency=1},b) local show
 local function title(t,back)
  if back then local bb=B({Position=u(0,14,0,30),Size=u(0,90,0,22),BackgroundTransparency=1,Text="< Settings",TextSize=12,TextColor3=C(10,132,255),Font=FM,TextXAlignment=XL},cont) bb.MouseButton1Click:Connect(function() show("main") end)
   T({Text=t,Position=u(0,0,0,30),Size=u(0,414,0,22),TextSize=14,Font=FB,TextColor3=C(0,0,0),TextXAlignment=XC},cont)
  else T({Text=t,Position=u(0,20,0,34),Size=u(0,300,0,34),TextSize=26,Font=FB,TextColor3=C(0,0,0),TextXAlignment=XL},cont) end
 end
 local function group(y,items)
  local g=F({Position=u(0,20,0,y),Size=u(0,374,0,#items*36),BackgroundColor3=WH},cont) Cr(10,g)
  for i,it in ipairs(items) do
   local r=B({Position=u(0,0,0,(i-1)*36),Size=u(1,0,0,36),BackgroundTransparency=1},g)
   T({Text=it.t,Position=u(0,it.nx or 14,0,0),Size=u(0,200,1,0),TextSize=13,Font=FG,TextColor3=C(0,0,0),TextXAlignment=XL},r)
   if it.k then sw(r,374-14-44,5,it.k)
   elseif it.v then local rt=T({Text=it.v(),Position=u(0,190,0,0),Size=u(0,170,1,0),TextSize=12,Font=FG,TextColor3=C(142,142,147),TextXAlignment=XR},r) for _,k in ipairs(it.vk or {}) do on(k,function() rt.Text=it.v() end) end end
   if i<#items then F({Position=u(0,it.nx or 14,1,-1),Size=u(1,-(it.nx or 14),0,1),BackgroundColor3=C(215,215,220)},r) end
   if it.ex then it.ex(r) end if it.cb then r.MouseButton1Click:Connect(it.cb) end
  end
 end
 local function lbl(t,y) T({Text=t,Position=u(0,34,0,y),Size=u(0,300,0,14),TextSize=9,Font=FM,TextColor3=C(142,142,147),TextXAlignment=XL},cont) end
 local function join(nm) if S.joining or S.net==nm then return end S.joining=nm show("wifi")
  task.delay(1.8,function() S.joining=nil if S.wifi then set("net",nm) notify("Wi-Fi","Connected to "..nm,C(10,132,255)) end if alive and pg=="wifi" then show("wifi") end end) end
 function show(p)
  pg=p cont:ClearAllChildren()
  if p=="main" then title("Settings")
   group(78,{{t="Wi-Fi",v=function() return S.net or (S.wifi and "Not Connected" or "Off") end,vk={"net","wifi"},cb=function() show("wifi") end},{t="Bluetooth",v=function() return S.bt and "On" or "Off" end,vk={"bt"},cb=function() show("bt") end}})
   group(160,{{t="Do Not Disturb",k="dnd"},{t="Eye Protection",k="eye"}})
   group(242,{{t="Software Version",v=function() return "iPadOS 17.4" end}})
  elseif p=="wifi" then title("Wi-Fi",true) group(64,{{t="Wi-Fi",k="wifi"}})
   if S.wifi then lbl("NETWORKS",110)
    local nets={{"Baseplate_5G",false},{"NETGEAR_42",true},{"Roblox_Guest",true},{"xfinitywifi",true}} local items={}
    for _,n in ipairs(nets) do table.insert(items,{t=n[1],nx=36,ex=function(r)
      if S.net==n[1] then check(r,12,10,C(10,132,255)) end
      if S.joining==n[1] then T({Text="Joining...",Position=u(0,190,0,0),Size=u(0,170,1,0),TextSize=11,Font=FG,TextColor3=C(142,142,147),TextXAlignment=XR},r) else if n[2] then lockI(r,374-62,13) end bars(r,374-34,13,C(30,30,34)) end end,
      cb=function() if n[2] then alert("Unable to Join Network",'The password for "'..n[1]..'" is incorrect.',{{"OK"}}) else join(n[1]) end end}) end
    group(128,items)
   end
  else title("Bluetooth",true) group(64,{{t="Bluetooth",k="bt"}})
   if S.bt then lbl("MY DEVICES",110) group(128,{{t="Baseplate Buds",v=function() return S.btdev and "Connected" or "Not Connected" end,vk={"btdev"},cb=function() set("btdev",not S.btdev) end}}) end
  end
 end
 on("wifi",function() if alive and pg=="wifi" then show("wifi") end end) on("net",function() if alive and pg=="wifi" then show("wifi") end end) on("bt",function() if alive and pg=="bt" then show("bt") end end)
 show("main") return function() alive=false end
end

local st0
local function ptr(i) return i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch end
UIS.InputBegan:Connect(function(i) if ptr(i) and G.Enabled and not S.isSleep then
 local p,s=Sc.AbsolutePosition,Sc.AbsoluteSize local x,y=i.Position.X,i.Position.Y local k=sc.Scale local ins=GS:GetGuiInset().Y
 if x>=p.X and x<=p.X+s.X and y>=p.Y-60 and y<=p.Y+s.Y+60 then local r1,r2=y+ins-p.Y,y-p.Y st0={p=i.Position,top=(r1>=-10 and r1<=34*k) or (r2>=-10 and r2<=34*k)} else st0=nil end end end)
UIS.InputEnded:Connect(function(i) if st0 and ptr(i) then
 local d=i.Position-st0.p local k=sc.Scale local s=st0 st0=nil
 if ccOpen then if d.Y<-35*k then closeCC() end return end
 if s.top and d.Y>35*k and math.abs(d.Y)>math.abs(d.X) then openCC() return end
 if S.locked then if d.Y<-45*k then unlock() end return end
 if not S.activeAppId and math.abs(d.X)>40*k and math.abs(d.X)>math.abs(d.Y)*1.5 then setPage(d.X<0 and 1 or 0) end end end)
task.spawn(function() local n=0 while G.Parent do
 local tt=os.date("%I:%M"):gsub("^0","") tm.Text=(os.date("%I:%M %p"):gsub("^0","")) dtl.Text=os.date("%a %b %d") lsT.Text=tt lsD.Text=os.date("%A, %B %d")
 n+=1 if n%45==0 and S.battery>1 then S.battery-=1 updBat() end
 if S.playing then local p=S.prog+1 if p>=180 then p=0 set("track",S.track%#TR+1) end set("prog",p) end
 task.wait(1) end end)

renderHome() renderLib() setBar(false)
local tg=N("ScreenGui",{Name="iPadOS_Toggle",ResetOnSpawn=false,IgnoreGuiInset=true,DisplayOrder=51},PG)
local tb=B({Position=u(.5,-32,0,44),Size=u(0,64,0,26),BackgroundColor3=C(30,30,34),Text="iPad",TextSize=12},tg) Cr(13,tb) N("UIStroke",{Color=C(120,120,128),Thickness=1},tb)
tb.MouseButton1Click:Connect(function() G.Enabled=not G.Enabled end)

local tool=N("Tool",{Name="iPad",RequiresHandle=true,CanBeDropped=false,ToolTip="iPad"})
local h=N("Part",{Name="Handle",Size=Vector3.new(1.6,.09,1.15),Color=C(28,28,32),Material=Enum.Material.SmoothPlastic,CanCollide=false},tool)
local sg=N("SurfaceGui",{Face=Enum.NormalId.Top,CanvasSize=V2(500,354)},h)
local sbz=F({Size=u(1,0,1,0),BackgroundColor3=C(8,8,10)},sg) Cr(24,sbz)
local ssc=F({Position=u(0,43,0,22),Size=u(0,414,0,310),BackgroundColor3=WH},sg) wall(ssc)
T({Text="iPadOS",Size=u(1,0,1,0),TextSize=40,Font=FB},ssc)
local sh2=F({Position=u(0,473,0,164),Size=u(0,24,0,24),BackgroundColor3=C(0,0,0)},sg) Cr(12,sh2) N("UIStroke",{Color=C(100,100,106),Thickness=2},sh2)
tool.Activated:Connect(function() G.Enabled=not G.Enabled end)
tool.Parent=LP:WaitForChild("Backpack")
task.delay(.3,function() pcall(function() LP.Character:FindFirstChildOfClass("Humanoid"):EquipTool(tool) end) end)
