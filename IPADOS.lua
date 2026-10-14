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
local function tw(o,t,pr,es,dir) local x=TS:Create(o,TweenInfo.new(t,es or Enum.EasingStyle.Quint,dir or Enum.EasingDirection.Out),pr) x:Play() return x end
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
A("photos","Photos",C(248,248,250),"Creativity",true,nil,true),A("notes","Notes",C(252,252,250),"Productivity",true,nil,true),A("music","Music",C(252,60,90),"Entertainment",false,nil,true),A("clock","Clock",C(22,22,24),"Utilities",false,nil,true),A("facetime","FaceTime",C(52,199,89),"Utilities",false,nil,true),A("safari","Safari",C(10,132,255),"Productivity",true,nil,true),A("messages","Messages",C(52,199,89),"Productivity",true,nil,true),
A("flappy","Flappy Bird",C(112,197,206),"Entertainment",false,"Tap to flap. Don't crash."),A("calc","Calculator",C(40,40,44),"Productivity",false,"Fast, simple maths"),A("stopwatch","Stopwatch",C(30,30,32),"Utilities",false,"Time anything"),A("weather","Weather",C(62,150,240),"Utilities",false,"Live forecast"),A("amazon","Amazon",C(35,47,62),"Utilities",true,"Shop everything you need")}
local byId={} for _,a in ipairs(ALL) do byId[a.id]=a if a.sys then table.insert(S.installedApps,a) end end
local function hasApp(id) for _,a in ipairs(S.installedApps) do if a.id==id then return true end end return false end
local DOCK={camera=true,maps=true,store=true,settings=true}
local refs={[0]={},[1]={}}
local launch,closeApp,setPage,renderHome,renderLib,notify,alert,ctxMenu,go,unlock,lockNow,openCC,closeCC,showVol,setBar,geom,placeOrder
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
weather=function(p) rc(p,.38,.4,.3,.3,C(255,214,10),.5) rc(p,.55,.64,.5,.22,WH,.5) rc(p,.45,.56,.26,.26,WH,.5) rc(p,.64,.58,.22,.22,WH,.5) end,
facetime=function(p) rc(p,.4,.5,.5,.36,WH,.2) rc(p,.74,.5,.2,.2,WH,.15,45) end,
messages=function(p) rc(p,.5,.46,.68,.5,WH,.4) rc(p,.32,.76,.16,.16,WH,0,45) end,
safari=function(p) rc(p,.5,.5,.78,.78,WH,.5) rc(p,.5,.5,.68,.68,C(40,150,255),.5) rc(p,.56,.44,.12,.3,C(255,69,58),.5,45) rc(p,.44,.56,.12,.3,WH,.5,45) end,
amazon=function(p) gt(p,"a",.5,.42,.5,.6,WH) rc(p,.5,.72,.52,.08,C(255,153,0),.5) rc(p,.76,.68,.1,.1,C(255,153,0),.2,0,0) end}
local function tile(a,par,x,y,sz,isb)
 local t=N(isb and "TextButton" or "Frame",{Position=u(0,x,0,y),Size=u(0,sz,0,sz),BackgroundColor3=a.col,BorderSizePixel=0},par)
 if isb then t.AutoButtonColor=false t.Text="" end
 Cr(sz*.225,t) N("UIGradient",{Rotation=90,Color=ColorSequence.new(a.col:Lerp(WH,.22),a.col:Lerp(C(0,0,0),.12))},t)
 N("UIStroke",{Color=WH,Transparency=.84,Thickness=1},t)
 if GL[a.id] then GL[a.id](t) end return t
end

local G=N("ScreenGui",{Name="iPadOS_UI",ResetOnSpawn=false,IgnoreGuiInset=true,DisplayOrder=50,ZIndexBehavior=Enum.ZIndexBehavior.Sibling},PG)
G.Enabled=false
local R=F({Name="iPad",Size=u(0,500,0,354),AnchorPoint=V2(.5,.5),Position=u(.5,0,1.7,0),BackgroundTransparency=1},G)
local sc=N("UIScale",{Scale=.8},R)
local av=N("NumberValue",{Value=0}) local base=1
local function apply() local v=av.Value R.Position=u(.5,0,.5+(1-v)*1.2,0) sc.Scale=math.max(base*(.8+.2*v),.01) end
local function fit() local cm=workspace.CurrentCamera if not cm then return end local v=cm.ViewportSize base=math.min(v.X*.94/452,v.Y*.86/356,1.8) apply() end fit()
if workspace.CurrentCamera then workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(fit) end
av.Changed:Connect(apply)
local sd=F({Size=u(0,442,0,338),Position=u(0,29,0,20),BackgroundColor3=C(0,0,0),BackgroundTransparency=.62},R) Cr(28,sd)
local O=F({Size=u(0,442,0,338),Position=u(0,29,0,8),BackgroundColor3=C(70,70,75)},R) Cr(28,O)
N("UIGradient",{Rotation=35,Color=ColorSequence.new({ColorSequenceKeypoint.new(0,C(132,132,138)),ColorSequenceKeypoint.new(.35,C(78,78,84)),ColorSequenceKeypoint.new(.65,C(110,110,116)),ColorSequenceKeypoint.new(1,C(52,52,58))})},O)
N("UIStroke",{Color=C(200,200,208),Thickness=1.2,Transparency=.55},O)
local Bz=F({Size=u(1,-6,1,-6),Position=u(0,3,0,3),BackgroundColor3=C(8,8,10)},O) Cr(25,Bz)
N("UIGradient",{Rotation=90,Color=ColorSequence.new(C(18,18,22),C(4,4,6))},Bz) N("UIStroke",{Color=C(28,28,32),Thickness=1.5},Bz)
local Sc=F({Name="Screen",Size=u(0,414,0,310),Position=u(0,43,0,22),BackgroundColor3=C(0,0,0),ClipsDescendants=true},R) Cr(12,Sc) N("UIStroke",{Color=C(0,0,0),Thickness=2},Sc)
local mk=F({Position=u(0,43,0,22),Size=u(0,414,0,310),BackgroundTransparency=1,ZIndex=3},R) Cr(12,mk) N("UIStroke",{Color=C(5,5,7),Thickness=11},mk)
for _,d in ipairs({{232,4},{241,4},{259,3},{268,4}}) do local dt=F({AnchorPoint=V2(.5,.5),Position=u(0,d[1],0,16),Size=u(0,d[2],0,d[2]),BackgroundColor3=C(20,20,26),ZIndex=4},R) Cr(d[2],dt) end
local lens=F({AnchorPoint=V2(.5,.5),Position=u(0,250,0,16),Size=u(0,7,0,7),BackgroundColor3=C(10,10,14),ZIndex=4},R) Cr(4,lens) N("UIStroke",{Color=C(50,50,60),Thickness=1},lens) F({Position=u(0,1,0,1),Size=u(0,2,0,2),BackgroundColor3=C(60,90,160)},lens)
local HB=B({Position=u(0,473,0,164),Size=u(0,24,0,24),BackgroundColor3=C(0,0,0)},R) Cr(12,HB) N("UIStroke",{Color=C(100,100,106),Thickness=2},HB) local hq=F({AnchorPoint=V2(.5,.5),Position=u(.5,0,.5,0),Size=u(0,9,0,9),BackgroundTransparency=1},HB) Cr(2,hq) N("UIStroke",{Color=C(90,90,96),Thickness=1},hq) HB.Visible=false
local function press(b) local p=b.Position tw(b,.07,{Position=p+u(0,0,0,2)}).Completed:Connect(function() tw(b,.12,{Position=p}) end) end
local function HW(x,w,cb) local b=B({Position=u(0,x,0,2),Size=u(0,w,0,10),BackgroundColor3=C(105,105,112)},R) Cr(3,b) N("UIStroke",{Color=C(40,40,44),Thickness=1},b) b.MouseButton1Click:Connect(function() press(b) cb() end) return b end

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
for i,tx in ipairs({"+","-"}) do T({Text=tx,Position=u(0,i==1 and 392 or 430,0,2),Size=u(0,30,0,10),TextSize=9,Font=FB,ZIndex=2},R) end

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
 local mode,pool="pic",{}
 local lay=F({Size=u(1,0,1,0),BackgroundTransparency=1,ZIndex=2},b)
 local function proj(pos)
  local rel=cm.CFrame:PointToObjectSpace(pos) if rel.Z>=-.1 then return nil end
  local hh=math.tan(math.rad(cm.FieldOfView)/2)
  return (rel.X/(-rel.Z)/(hh*(414/310))*.5+.5)*414,(.5-rel.Y/(-rel.Z)/hh*.5)*310
 end
 local function boxes()
  local out={} local me=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
  for _,pl in ipairs(P:GetPlayers()) do if pl~=LP then
   local hr=pl.Character and pl.Character:FindFirstChild("HumanoidRootPart")
   if hr then
    local x1,y1=proj(hr.Position+Vector3.new(0,3,0)) local x2,y2=proj(hr.Position-Vector3.new(0,3,0))
    if x1 and x2 then local h2=math.abs(y2-y1) local w2=h2*.5
     table.insert(out,{x=(x1+x2)/2-w2/2,y=math.min(y1,y2),w=w2,h=h2,name=pl.DisplayName,dist=me and math.floor((hr.Position-me.Position).Magnitude) or 0}) end
   end
  end end
  return out
 end
 local function mk(i)
  local bx=F({BackgroundTransparency=1,Visible=false},lay) N("UIStroke",{Color=C(255,59,48),Thickness=1.5},bx)
  local lb=T({AnchorPoint=V2(0,1),Position=u(0,0,0,-2),Size=u(0,150,0,12),TextSize=9,Font=FB,TextColor3=C(255,90,80),TextStrokeTransparency=.2,TextXAlignment=XL},bx)
  pool[i]={bx=bx,lb=lb} return pool[i]
 end
 local cn=RS.RenderStepped:Connect(function()
  local wc=workspace.CurrentCamera if wc then cm.CFrame=wc.CFrame cm.FieldOfView=wc.FieldOfView end
  local l=mode=="esp" and boxes() or {}
  for i,e in ipairs(l) do local p=pool[i] or mk(i) p.bx.Visible=true p.bx.Position=u(0,e.x,0,e.y) p.bx.Size=u(0,e.w,0,e.h) p.lb.Text=e.name.." "..e.dist.." studs" end
  for i=#l+1,#pool do pool[i].bx.Visible=false end
 end)
 F({Position=u(0,0,0,232),Size=u(0,414,0,78),BackgroundColor3=C(0,0,0),BackgroundTransparency=.4,ZIndex=3},b)
 local mb={}
 local function setMode(m) mode=m for k,bt in pairs(mb) do bt.TextColor3=(k==m) and C(255,214,10) or C(205,205,210) end end
 for _,d in ipairs({{"pic","Picture",126,70},{"esp","ESP Picture",204,96}}) do
  local bt=B({Position=u(0,d[3],0,236),Size=u(0,d[4],0,16),BackgroundTransparency=1,Text=d[2],TextSize=10,ZIndex=4},b) mb[d[1]]=bt bt.MouseButton1Click:Connect(function() setMode(d[1]) end)
 end
 setMode("pic")
 local th=F({Position=u(0,22,0,252),Size=u(0,44,0,44),BackgroundColor3=C(30,30,32),ClipsDescendants=true,ZIndex=4},b) Cr(8,th) N("UIStroke",{Color=WH,Thickness=1.5},th)
 local ring=B({Position=u(0,179,0,254),Size=u(0,56,0,56),BackgroundTransparency=1,ZIndex=4},b) Cr(28,ring) N("UIStroke",{Color=WH,Thickness=3},ring)
 local inn=F({Position=u(0,6,0,6),Size=u(0,44,0,44),BackgroundColor3=WH,Active=false},ring) Cr(22,inn)
 local fl=F({Size=u(1,0,1,0),BackgroundColor3=WH,BackgroundTransparency=1,ZIndex=30,Active=false},b)
 ring.MouseButton1Click:Connect(function()
  fl.BackgroundTransparency=0 tw(fl,.4,{BackgroundTransparency=1}) inn.Size=u(0,36,0,36) inn.Position=u(0,10,0,10) tw(inn,.25,{Size=u(0,44,0,44),Position=u(0,6,0,6)})
  for _,c in ipairs(th:GetChildren()) do if c:IsA("ViewportFrame") then c:Destroy() end end
  local cp=vp:Clone() cp.Size=u(0,59,0,44) cp.Position=u(0,-7,0,0) cp.Parent=th cp.CurrentCamera=cp:FindFirstChildOfClass("Camera")
  table.insert(S.photos,{vp=cp:Clone(),mode=mode,esp=mode=="esp" and boxes() or nil,t=os.date("%b %d, %I:%M %p")})
  if #S.photos>12 then table.remove(S.photos,1).vp:Destroy() end
 end)
 return function() cn:Disconnect() end
end
build.photos=function(b,a)
 local root=F({Size=u(1,0,1,0),BackgroundTransparency=1},b) local list,view
 local function clr() for _,c in ipairs(root:GetChildren()) do c:Destroy() end end
 local function put(par,ph,w,h) local c=ph.vp:Clone() c.Size=u(0,w,0,h) c.Position=u(0,0,0,0) c.Parent=par c.CurrentCamera=c:FindFirstChildOfClass("Camera") return c end
 local function esp(par,ph,w,th,names)
  if not ph.esp then return end local k=w/414
  for _,e in ipairs(ph.esp) do
   local bx=F({Position=u(0,e.x*k,0,e.y*k),Size=u(0,e.w*k,0,e.h*k),BackgroundTransparency=1,ZIndex=3},par) N("UIStroke",{Color=C(255,59,48),Thickness=th},bx)
   if names then T({AnchorPoint=V2(0,1),Position=u(0,0,0,-2),Size=u(0,150,0,12),Text=e.name.." "..e.dist.." studs",TextSize=9,Font=FB,TextColor3=C(255,90,80),TextStrokeTransparency=.2,TextXAlignment=XL},bx) end
  end
 end
 function list()
  clr() hdr(root,"Photos",C(0,0,0))
  T({Text=#S.photos==0 and "No photos yet. Take some with Camera." or #S.photos.." photo"..(#S.photos==1 and "" or "s"),Position=u(0,20,0,68),Size=u(0,374,0,14),TextSize=10,TextColor3=C(142,142,147),TextXAlignment=XL},root)
  local sf=N("ScrollingFrame",{Position=u(0,0,0,86),Size=u(1,0,1,-90),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=3,AutomaticCanvasSize=Enum.AutomaticSize.Y,CanvasSize=u(0,0,0,0)},root)
  N("UIPadding",{PaddingLeft=UDim.new(0,20),PaddingTop=UDim.new(0,4),PaddingBottom=UDim.new(0,16)},sf)
  local g=F({Size=u(0,374,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1},sf) N("UIGridLayout",{CellSize=u(0,86,0,64),CellPadding=u(0,6,0,6),SortOrder=Enum.SortOrder.LayoutOrder},g)
  for i=#S.photos,1,-1 do
   local ph=S.photos[i] local cell=B({BackgroundColor3=C(30,30,32),ClipsDescendants=true,LayoutOrder=#S.photos-i},g) Cr(6,cell) put(cell,ph,86,64) esp(cell,ph,86,1,false)
   if ph.mode=="esp" then local tg=F({Position=u(0,3,1,-14),Size=u(0,26,0,11),BackgroundColor3=C(255,59,48),ZIndex=5},cell) Cr(4,tg) T({Text="ESP",Size=u(1,0,1,0),TextSize=7,Font=FB},tg) end
   cell.MouseButton1Click:Connect(function() view(i) end)
  end
 end
 function view(i)
  local ph=S.photos[i] if not ph then return list() end
  clr() F({Size=u(1,0,1,0),BackgroundColor3=C(0,0,0)},root)
  local v=put(root,ph,414,310) esp(root,ph,414,1.5,true)
  local tp=F({Position=u(0,0,0,20),Size=u(0,414,0,40),BackgroundColor3=C(0,0,0),BackgroundTransparency=.45,ZIndex=6},root)
  local bk=B({Position=u(0,12,0,0),Size=u(0,90,0,40),BackgroundTransparency=1,Text="< Photos",TextSize=12,TextColor3=C(10,132,255),Font=FM,TextXAlignment=XL},tp) bk.MouseButton1Click:Connect(list)
  T({Text=ph.t..(ph.mode=="esp" and "  (ESP)" or ""),Size=u(1,0,1,0),TextSize=12,Font=FB,TextXAlignment=XC},tp)
  local bt=F({Position=u(0,0,0,258),Size=u(0,414,0,44),BackgroundColor3=C(0,0,0),BackgroundTransparency=.45,ZIndex=6},root)
  T({Text=(#S.photos-i+1).." of "..#S.photos,Size=u(1,0,1,0),TextSize=11,Font=FM,TextTransparency=.2,TextXAlignment=XC},bt)
  local tr=B({Position=u(0,364,0,4),Size=u(0,36,0,36),BackgroundTransparency=1},bt) rc(tr,.5,.3,.6,.1,C(255,69,58),.3) rc(tr,.5,.62,.46,.5,C(255,69,58),.12) rc(tr,.5,.2,.22,.08,C(255,69,58),.3)
  tr.MouseButton1Click:Connect(function() alert("Delete Photo?","This photo will be deleted.",{{"Cancel"},{"Delete",C(255,59,48),function() local x=table.remove(S.photos,i) if x then x.vp:Destroy() end list() end}}) end)
 end
 list() return function() end
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

local function rel(d,root) local t={} while d and d~=root do table.insert(t,1,d.Name) d=d.Parent end return table.concat(t,"/") end
local function clean(cl) for _,d in ipairs(cl:GetDescendants()) do if d:IsA("LuaSourceContainer") or d:IsA("Sound") or d:IsA("ParticleEmitter") then d:Destroy() end end end
local function feed(par,pl,rad,maxp,dist)
 local vp=N("ViewportFrame",{Size=u(1,0,1,0),BackgroundColor3=C(135,175,215),Ambient=C(175,175,175),LightColor=WH},par)
 local cm=N("Camera",{FieldOfView=60},vp) vp.CurrentCamera=cm
 local ch=pl.Character local hrp=ch and ch:FindFirstChild("HumanoidRootPart") local prs={}
 if hrp then pcall(function()
  ch.Archivable=true local cc=ch:Clone()
  if cc then clean(cc) cc.Parent=vp local mp={}
   for _,d in ipairs(cc:GetDescendants()) do if d:IsA("BasePart") then d.Anchored=true mp[rel(d,cc)]=d end end
   for _,d in ipairs(ch:GetDescendants()) do if d:IsA("BasePart") then local c2=mp[rel(d,ch)] if c2 then table.insert(prs,{d,c2}) end end end end
  local n=0
  for _,p in ipairs(workspace:GetDescendants()) do
   if n>maxp then break end
   if p:IsA("BasePart") and p~=workspace.Terrain and p.Size.Magnitude>1 and (p.Position-hrp.Position).Magnitude<rad and not p:IsDescendantOf(ch) then
    local m=p:FindFirstAncestorOfClass("Model")
    if not (m and m:FindFirstChildOfClass("Humanoid")) then local ok,cl=pcall(function() return p:Clone() end) if ok and cl then clean(cl) cl.Anchored=true cl.Parent=vp n+=1 end end
   end
  end
 end) end
 local cn=RS.RenderStepped:Connect(function()
  if not (hrp and hrp.Parent) then return end
  for _,pr in ipairs(prs) do pr[2].CFrame=pr[1].CFrame end
  local hd=ch:FindFirstChild("Head") local tg=hd and hd.Position or hrp.Position+Vector3.new(0,1.5,0)
  cm.CFrame=CFrame.lookAt(tg+hrp.CFrame.LookVector*dist+Vector3.new(0,.3,0),tg)
 end)
 return hrp~=nil,function() cn:Disconnect() end
end

build.facetime=function(b,a)
 local alive,mode,cleanup,tok=true,"list",nil,0
 local root=F({Size=u(1,0,1,0),BackgroundTransparency=1},b)
 local list,calling,incall
 local function clr() if cleanup then pcall(cleanup) cleanup=nil end for _,c in ipairs(root:GetChildren()) do c:Destroy() end end
 local function avatar(par,pl,x,y,s) local f=F({Position=u(0,x,0,y),Size=u(0,s,0,s),BackgroundColor3=Color3.fromHSV((#pl.Name*.13)%1,.45,.75)},par) Cr(s/2,f) T({Text=pl.DisplayName:sub(1,1):upper(),Size=u(1,0,1,0),TextSize=s*.45,Font=FB},f) return f end
 local function rbtn(par,x,y,s,col,z) local k=B({Position=u(0,x,0,y),Size=u(0,s,0,s),BackgroundColor3=col,ZIndex=z or 1},par) Cr(s/2,k) return k end
 function list()
  clr() mode="list"
  T({Text="FaceTime",Position=u(0,20,0,34),Size=u(0,300,0,34),TextSize=26,Font=FB,TextXAlignment=XL},root)
  T({Text="Tap someone to start a video call",Position=u(0,20,0,68),Size=u(0,300,0,14),TextSize=10,Font=FG,TextColor3=C(150,150,158),TextXAlignment=XL},root)
  local sf=N("ScrollingFrame",{Position=u(0,0,0,90),Size=u(1,0,1,-96),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=3,AutomaticCanvasSize=Enum.AutomaticSize.Y,CanvasSize=u(0,0,0,0)},root)
  N("UIListLayout",{Padding=UDim.new(0,8),HorizontalAlignment=Enum.HorizontalAlignment.Center},sf)
  local n=0
  for _,pl in ipairs(P:GetPlayers()) do if pl~=LP then n+=1
   local r=B({Size=u(0,374,0,48),BackgroundColor3=C(40,40,44)},sf) Cr(12,r) avatar(r,pl,8,6,36)
   T({Text=pl.DisplayName,Position=u(0,54,0,6),Size=u(0,220,0,18),TextSize=13,Font=FB,TextXAlignment=XL},r)
   T({Text="@"..pl.Name,Position=u(0,54,0,24),Size=u(0,220,0,14),TextSize=10,Font=FG,TextColor3=C(150,150,158),TextXAlignment=XL},r)
   local cb=F({Position=u(0,328,0,9),Size=u(0,34,0,30),BackgroundColor3=C(52,199,89)},r) Cr(15,cb) GL.camera(cb)
   r.MouseButton1Click:Connect(function() calling(pl) end)
  end end
  if n==0 then T({Text="No one else is in this server yet.",Position=u(0,0,0,110),Size=u(0,414,0,20),TextSize=13,Font=FG,TextColor3=C(150,150,158),TextXAlignment=XC},root) end
 end
 function calling(pl)
  clr() mode="calling" tok+=1 local my=tok
  local bg=F({Size=u(1,0,1,0),BackgroundColor3=C(30,30,34)},root) N("UIGradient",{Rotation=90,Color=ColorSequence.new(C(64,64,74),C(14,14,18))},bg)
  avatar(root,pl,162,64,90)
  T({Text=pl.DisplayName,Position=u(0,0,0,164),Size=u(0,414,0,26),TextSize=20,Font=FB,TextXAlignment=XC},root)
  local st=T({Text="FaceTime Video",Position=u(0,0,0,192),Size=u(0,414,0,16),TextSize=12,Font=FG,TextColor3=C(190,190,198),TextXAlignment=XC},root)
  local en=rbtn(root,186,236,42,C(255,59,48)) rc(en,.5,.5,.58,.16,WH,.5) en.MouseButton1Click:Connect(function() list() end)
  task.spawn(function()
   local t,w,i=0,2.5+math.random()*3,0
   while alive and mode=="calling" and tok==my and t<w do i=i%3+1 st.Text="FaceTime Video"..string.rep(".",i) task.wait(.45) t+=.45 end
   if alive and mode=="calling" and tok==my then if pl.Parent then incall(pl) else list() end end
  end)
 end
 function incall(pl)
  clr() mode="call" tok+=1 local my=tok
  local ok1,c1=feed(root,pl,150,300,6)
  if not ok1 then local nc=F({Size=u(1,0,1,0),BackgroundColor3=C(30,30,34)},root) T({Text="Camera unavailable",Size=u(1,0,1,0),TextSize=14},nc) end
  local pip=F({Position=u(0,306,0,28),Size=u(0,96,0,128),BackgroundColor3=C(20,20,24),ClipsDescendants=true,ZIndex=5},root) Cr(10,pip) N("UIStroke",{Color=WH,Thickness=1.5,Transparency=.3},pip)
  local ok2,c2=feed(pip,LP,80,150,4)
  local off=F({Size=u(1,0,1,0),BackgroundColor3=C(28,28,32),Visible=false,ZIndex=6},pip) T({Text="Camera Off",Position=u(0,0,.5,-8),Size=u(1,0,0,16),TextSize=10,Font=FB,ZIndex=7},off)
  cleanup=function() c1() c2() end
  T({Text=pl.DisplayName,Position=u(0,16,0,28),Size=u(0,220,0,20),TextSize=16,Font=FB,TextXAlignment=XL,TextStrokeTransparency=.5,ZIndex=8},root)
  local tl=T({Text="0:00",Position=u(0,16,0,48),Size=u(0,100,0,14),TextSize=11,Font=FM,TextXAlignment=XL,TextStrokeTransparency=.5,ZIndex=8},root)
  local mt=F({Position=u(0,16,0,68),Size=u(0,64,0,18),BackgroundColor3=C(255,59,48),Visible=false,ZIndex=8},root) Cr(9,mt) T({Text="Mic Off",Size=u(1,0,1,0),TextSize=10,Font=FB},mt)
  local bar=F({Position=u(0,92,0,242),Size=u(0,230,0,56),BackgroundColor3=C(20,20,24),BackgroundTransparency=.3,ZIndex=7},root) Cr(28,bar)
  local mu=rbtn(bar,14,7,42,C(70,70,76),8) rc(mu,.5,.4,.22,.4,WH,.5) rc(mu,.5,.72,.04,.14,WH,0) rc(mu,.5,.82,.28,.05,WH,.5)
  local ms=rc(mu,.5,.5,.9,.07,C(255,59,48),0,45) ms.Visible=false
  local cm2=rbtn(bar,94,7,42,C(70,70,76),8) GL.camera(cm2)
  local cs=rc(cm2,.5,.5,.9,.07,C(255,59,48),0,45) cs.Visible=false
  local en=rbtn(bar,174,7,42,C(255,59,48),8) rc(en,.5,.5,.6,.16,WH,.5)
  local muted,camOff=false,false
  mu.MouseButton1Click:Connect(function() muted=not muted ms.Visible=muted mt.Visible=muted end)
  cm2.MouseButton1Click:Connect(function() camOff=not camOff cs.Visible=camOff off.Visible=camOff end)
  en.MouseButton1Click:Connect(function() list() end)
  task.spawn(function() local t=0 while alive and mode=="call" and tok==my do t+=1 tl.Text=string.format("%d:%02d",t//60,t%60) if not pl.Parent then list() break end task.wait(1) end end)
 end
 local c1=P.PlayerAdded:Connect(function() task.delay(.3,function() if alive and mode=="list" then list() end end) end)
 local c2=P.PlayerRemoving:Connect(function() task.delay(.3,function() if alive and mode=="list" then list() end end) end)
 list()
 return function() alive=false c1:Disconnect() c2:Disconnect() clr() end
end

build.settings=function(b,a)
 local alive,pg,ord=true,"main",0
 local top=F({Size=u(1,0,0,68),BackgroundTransparency=1,ZIndex=2},b)
 local sf=N("ScrollingFrame",{Position=u(0,0,0,68),Size=u(1,0,1,-68),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=3,AutomaticCanvasSize=Enum.AutomaticSize.Y,CanvasSize=u(0,0,0,0)},b)
 N("UIListLayout",{Padding=UDim.new(0,10),HorizontalAlignment=Enum.HorizontalAlignment.Center,SortOrder=Enum.SortOrder.LayoutOrder},sf) N("UIPadding",{PaddingTop=UDim.new(0,4),PaddingBottom=UDim.new(0,24)},sf)
 local show
 local function nxo() ord+=1 return ord end
 local function title(t,back)
  if back then
   local bb=B({Position=u(0,14,0,34),Size=u(0,90,0,22),BackgroundTransparency=1,Text="< Settings",TextSize=12,TextColor3=C(10,132,255),Font=FM,TextXAlignment=XL},top) bb.MouseButton1Click:Connect(function() show("main") end)
   T({Text=t,Position=u(0,0,0,34),Size=u(0,414,0,22),TextSize=14,Font=FB,TextColor3=C(0,0,0),TextXAlignment=XC},top)
  else T({Text=t,Position=u(0,20,0,28),Size=u(0,300,0,34),TextSize=26,Font=FB,TextColor3=C(0,0,0),TextXAlignment=XL},top) end
 end
 local function group(items)
  local g=F({Size=u(0,374,0,#items*36),BackgroundColor3=WH,LayoutOrder=nxo()},sf) Cr(10,g)
  for i,it in ipairs(items) do
   local r=B({Position=u(0,0,0,(i-1)*36),Size=u(1,0,0,36),BackgroundTransparency=1},g)
   local x=it.app and 44 or (it.nx or 14)
   if it.app then tile(it.app,r,12,6,24,false) end
   T({Text=it.t,Position=u(0,x,0,0),Size=u(0,200,1,0),TextSize=13,Font=FG,TextColor3=it.col or C(0,0,0),TextXAlignment=XL},r)
   if it.k then if S[it.k]==nil then S[it.k]=true end sw(r,374-14-44,5,it.k)
   elseif it.v then local rt=T({Text=it.v(),Position=u(0,160,0,0),Size=u(0,it.chev and 176 or 190,1,0),TextSize=12,Font=FG,TextColor3=C(142,142,147),TextXAlignment=XR},r) for _,k in ipairs(it.vk or {}) do on(k,function() rt.Text=it.v() end) end end
   if it.chev then local c=F({Position=u(0,350,0,12),Size=u(0,10,0,12),BackgroundTransparency=1},r) rc(c,.3,.3,.7,.14,C(190,190,195),0,45) rc(c,.3,.7,.7,.14,C(190,190,195),0,-45) end
   if i<#items then F({Position=u(0,x,1,-1),Size=u(1,-x,0,1),BackgroundColor3=C(215,215,220)},r) end
   if it.ex then it.ex(r) end if it.cb then r.MouseButton1Click:Connect(it.cb) end
  end
 end
 local function lbl(t) T({Text=t,Size=u(0,350,0,14),TextSize=9,Font=FM,TextColor3=C(142,142,147),TextXAlignment=XL,LayoutOrder=nxo()},sf) end
 local function srow(lab,get,put,key) local c=F({Size=u(0,374,0,44),BackgroundColor3=C(34,34,38),LayoutOrder=nxo()},sf) Cr(12,c) slider(c,10,6,354,32,lab,get,put,key) end
 local function vol() return math.floor(S.currentVolume+.5).."%" end
 local function join(nm) if S.joining or S.net==nm then return end S.joining=nm show("wifi")
  task.delay(1.8,function() S.joining=nil if S.wifi then set("net",nm) notify("Wi-Fi","Connected to "..nm,C(10,132,255)) end if alive and pg=="wifi" then show("wifi") end end) end
 function show(p)
  pg=p ord=0
  for _,c in ipairs(sf:GetChildren()) do if c:IsA("GuiObject") then c:Destroy() end end top:ClearAllChildren() sf.CanvasPosition=V2(0,0)
  if p=="main" then title("Settings")
   group({{t="Wi-Fi",v=function() return S.net or (S.wifi and "Not Connected" or "Off") end,vk={"net","wifi"},chev=true,cb=function() show("wifi") end},{t="Bluetooth",v=function() return S.bt and "On" or "Off" end,vk={"bt"},chev=true,cb=function() show("bt") end}})
   group({{t="Do Not Disturb",k="dnd"},{t="Eye Protection",k="eye"}})
   group({{t="Display & Brightness",chev=true,cb=function() show("display") end},{t="Sounds",v=vol,vk={"currentVolume"},chev=true,cb=function() show("sounds") end},{t="Battery",v=function() return S.battery.."%" end,chev=true,cb=function() show("battery") end}})
   group({{t="About",chev=true,cb=function() show("about") end}})
   lbl("APPS") local its={}
   for _,x in ipairs(S.installedApps) do table.insert(its,{t=x.name,app=x,chev=true,cb=function() show("app:"..x.id) end}) end group(its)
  elseif p=="wifi" then title("Wi-Fi",true) group({{t="Wi-Fi",k="wifi"}})
   if S.wifi then lbl("NETWORKS") local its={}
    for _,n in ipairs({{"Baseplate_5G",false},{"NETGEAR_42",true},{"Roblox_Guest",true},{"xfinitywifi",true}}) do
     table.insert(its,{t=n[1],nx=36,ex=function(r)
       if S.net==n[1] then check(r,12,10,C(10,132,255)) end
       if S.joining==n[1] then T({Text="Joining...",Position=u(0,190,0,0),Size=u(0,170,1,0),TextSize=11,Font=FG,TextColor3=C(142,142,147),TextXAlignment=XR},r) else if n[2] then lockI(r,374-62,13) end bars(r,374-34,13,C(30,30,34)) end end,
       cb=function() if n[2] then alert("Unable to Join Network",'The password for "'..n[1]..'" is incorrect.',{{"OK"}}) else join(n[1]) end end})
    end
    group(its)
   end
  elseif p=="bt" then title("Bluetooth",true) group({{t="Bluetooth",k="bt"}})
   if S.bt then lbl("MY DEVICES") group({{t="Baseplate Buds",v=function() return S.btdev and "Connected" or "Not Connected" end,vk={"btdev"},cb=function() set("btdev",not S.btdev) end}}) end
  elseif p=="display" then title("Display & Brightness",true)
   srow("Brightness",function() return (S.bright-.15)/.85 end,function(v) set("bright",.15+.85*v) end,"bright") group({{t="Eye Protection",k="eye"}})
  elseif p=="sounds" then title("Sounds",true) srow("Volume",function() return S.currentVolume/100 end,function(v) set("currentVolume",math.floor(v*100+.5)) end,"currentVolume")
  elseif p=="battery" then title("Battery",true) group({{t="Battery Level",v=function() return S.battery.."%" end,vk={}},{t="Power Source",v=function() return "Battery" end}})
  elseif p=="about" then title("About",true)
   group({{t="Name",v=function() return "iPad Pro Max" end},{t="Software Version",v=function() return "iPadOS 17.4" end},{t="Apps",v=function() return tostring(#S.installedApps) end}})
  else
   local x=byId[p:sub(5)] title(x.name,true)
   local hd=F({Size=u(0,374,0,70),BackgroundTransparency=1,LayoutOrder=nxo()},sf) tile(x,hd,0,6,58,false)
   T({Text=x.name,Position=u(0,72,0,14),Size=u(0,280,0,20),TextSize=16,Font=FB,TextColor3=C(0,0,0),TextXAlignment=XL},hd)
   T({Text=x.cat,Position=u(0,72,0,36),Size=u(0,280,0,14),TextSize=11,Font=FG,TextColor3=C(142,142,147),TextXAlignment=XL},hd)
   group({{t="Notifications",k="na_"..x.id},{t="Background App Refresh",k="br_"..x.id}})
   group({{t="Storage",v=function() return ((#x.name*37+11)%90+12).." MB" end},{t="Version",v=function() return "1.0" end}})
   if not x.sys then group({{t="Delete App",col=C(255,59,48),cb=function() alert('Delete "'..x.name..'"?',"Deleting this app will also delete its data.",{{"Cancel"},{"Delete",C(255,59,48),function() deleteApp(x) show("main") end}}) end}}) end
  end
 end
 on("wifi",function() if alive and pg=="wifi" then show("wifi") end end) on("net",function() if alive and pg=="wifi" then show("wifi") end end) on("bt",function() if alive and pg=="bt" then show("bt") end end)
 show("main") return function() alive=false end
end

local PHC=C(104,84,66)
local function phoneArt(par,x,y,w,h,rot,back)
 local bd=rc(par,x,y,w,h,PHC,.14,rot) N("UIStroke",{Color=PHC:Lerp(C(0,0,0),.35),Thickness=1},bd)
 if back then rc(bd,.5,.19,.76,.27,PHC:Lerp(WH,.18),.18) for _,l in ipairs({{.3,.14},{.7,.14},{.5,.25}}) do rc(bd,l[1],l[2],.27,.115,C(20,20,24),.5) rc(bd,l[1],l[2],.14,.06,C(50,70,120),.5) end
 else rc(bd,.5,.5,.9,.95,C(0,0,0),.12) end
end
local function art(par,k,c)
 local d=c:Lerp(C(0,0,0),.3)
 if k=="shoe" then rc(par,.5,.7,.72,.14,C(40,40,44),.5) rc(par,.42,.52,.46,.36,c,.3) rc(par,.7,.62,.3,.2,c,.5)
 elseif k=="pj" then rc(par,.5,.52,.4,.56,c,.15) rc(par,.28,.4,.16,.34,c,.3,18) rc(par,.72,.4,.16,.34,c,.3,-18) rc(par,.5,.52,.4,.05,WH,0,0,.4)
 elseif k=="vac" then rc(par,.4,.64,.3,.34,c,.3) rc(par,.6,.42,.05,.62,d,.5,24) rc(par,.76,.82,.3,.1,d,.3)
 elseif k=="cof" then rc(par,.45,.58,.34,.46,c,.2) rc(par,.7,.58,.12,.22,c,.5) rc(par,.45,.22,.04,.16,WH,.5,0,.3)
 elseif k=="hp" then rc(par,.5,.38,.5,.06,d,.5) rc(par,.27,.58,.18,.36,c,.4) rc(par,.73,.58,.18,.36,c,.4)
 elseif k=="bag" then rc(par,.5,.56,.42,.6,c,.25) rc(par,.5,.7,.3,.24,d,.2) rc(par,.5,.24,.18,.12,d,.5)
 elseif k=="lamp" then rc(par,.5,.84,.3,.06,d,.3) rc(par,.5,.58,.04,.48,d,.5) rc(par,.58,.28,.32,.22,c,.3,-18)
 else rc(par,.5,.52,.62,.3,c,.5,-8) rc(par,.2,.54,.14,.3,d,.5) end
end
local function dots(par,x,y,rate) for i=1,5 do local d=F({Position=u(0,x+(i-1)*10,0,y),Size=u(0,7,0,7),BackgroundColor3=i<=math.floor(rate+.5) and C(255,153,0) or C(210,210,214)},par) Cr(4,d) end end
local ITEMS={{name="iPhone 17 Pro Max",price="$1,199.00",rate=4.8,phone=true},
{name="Running Shoes",price="$64.99",rate=4.4,kind="shoe",col=C(235,90,70)},{name="Cozy Pajama Set",price="$29.99",rate=4.6,kind="pj",col=C(90,130,220)},
{name="Cordless Vacuum",price="$149.00",rate=4.3,kind="vac",col=C(130,90,200)},{name="Coffee Maker",price="$79.95",rate=4.5,kind="cof",col=C(120,80,50)},
{name="Wireless Headphones",price="$59.99",rate=4.2,kind="hp",col=C(60,60,70)},{name="Travel Backpack",price="$39.50",rate=4.7,kind="bag",col=C(60,160,120)},
{name="Desk Lamp",price="$24.99",rate=4.1,kind="lamp",col=C(230,180,40)},{name="Yoga Mat",price="$19.99",rate=4.5,kind="yoga",col=C(220,90,150)}}
local function thumb(im,it,s,big)
 if it.phone then if big then phoneArt(im,.42,.5,.12,.9,-7,false) phoneArt(im,.58,.5,.12,.9,7,true) else phoneArt(im,.5,.5,.28,.9,0,true) end
 else local sq=F({AnchorPoint=V2(.5,.5),Position=u(.5,0,.5,0),Size=u(0,s,0,s),BackgroundTransparency=1},im) art(sq,it.kind,it.col) end
end
build.amazon=function(b,a)
 local page,prod,q="home",nil,""
 local nv=F({Position=u(0,0,0,20),Size=u(0,414,0,40),BackgroundColor3=C(35,47,62)},b)
 T({Text="amazon",Position=u(0,12,0,3),Size=u(0,70,0,24),TextSize=17,Font=FB,TextXAlignment=XL},nv) rc(nv,.113,.8,.1,.07,C(255,153,0),.5)
 local sb=N("TextBox",{Position=u(0,96,0,7),Size=u(0,306,0,26),BackgroundColor3=WH,Text="",PlaceholderText="Search Amazon",PlaceholderColor3=C(120,120,128),TextColor3=C(0,0,0),Font=FM,TextSize=12,ClearTextOnFocus=false,BorderSizePixel=0},nv) Cr(6,sb)
 local body=F({Position=u(0,0,0,60),Size=u(0,414,0,238),BackgroundTransparency=1,ClipsDescendants=true},b)
 local render
 local function rt(s,txt,sz,fnt,col,h,ord) return T({Text=txt,Size=u(0,390,0,h),TextSize=sz,Font=fnt,TextColor3=col,TextXAlignment=XL,TextWrapped=true,TextYAlignment=Enum.TextYAlignment.Top,LayoutOrder=ord},s) end
 local function buy(s,ord,it) local k=B({Size=u(0,390,0,34),BackgroundColor3=C(255,216,20),Text="Buy Now",TextSize=12,TextColor3=C(20,20,24),LayoutOrder=ord},s) Cr(17,k) k.MouseButton1Click:Connect(function()
   if it.phone then alert("Place your order?","iPhone 17 Pro Max for $1,199.00. It will be delivered near you.",{{"Cancel"},{"Order",nil,function() placeOrder() alert("Order Placed","Your iPhone is on the way. Look for the package near you.",{{"OK"}}) end}})
   else alert("Amazon","This item is a placeholder. Only the iPhone 17 Pro Max can be ordered.",{{"OK"}}) end end) end
 local function open(it) prod=it page="prod" render() end
 function render()
  for _,c in ipairs(body:GetChildren()) do c:Destroy() end
  local s=N("ScrollingFrame",{Size=u(1,0,1,0),BackgroundColor3=C(236,238,240),BorderSizePixel=0,ScrollBarThickness=3,AutomaticCanvasSize=Enum.AutomaticSize.Y,CanvasSize=u(0,0,0,0)},body)
  N("UIListLayout",{Padding=UDim.new(0,8),HorizontalAlignment=Enum.HorizontalAlignment.Center,SortOrder=Enum.SortOrder.LayoutOrder},s) N("UIPadding",{PaddingTop=UDim.new(0,8),PaddingBottom=UDim.new(0,16)},s)
  local n=0 local function o() n+=1 return n end
  if page=="prod" then
   local it=prod
   local bk=B({Size=u(0,390,0,18),BackgroundTransparency=1,Text="< Back",TextSize=11,Font=FM,TextColor3=C(0,113,133),TextXAlignment=XL,LayoutOrder=o()},s) bk.MouseButton1Click:Connect(function() page="home" prod=nil render() end)
   local im=F({Size=u(0,390,0,130),BackgroundColor3=it.col and it.col:Lerp(WH,.75) or C(238,238,242),LayoutOrder=o()},s) Cr(10,im) thumb(im,it,130,true)
   rt(s,it.name,15,FB,C(20,20,24),20,o()) rt(s,it.price,22,FB,C(177,39,4),28,o()) rt(s,"In Stock",11,FM,C(0,128,60),16,o())
   buy(s,o(),it)
  else
   local list={} for _,it in ipairs(ITEMS) do if q=="" or it.name:lower():find(q,1,true) then table.insert(list,it) end end
   if q=="" then
    local bn=B({Size=u(0,390,0,100),BackgroundColor3=C(255,170,40),LayoutOrder=o()},s) Cr(10,bn) N("UIGradient",{Rotation=20,Color=ColorSequence.new(C(255,153,0),C(255,210,110))},bn)
    T({Text="DEAL OF THE DAY",Position=u(0,14,0,10),Size=u(0,200,0,12),TextSize=9,Font=FB,TextColor3=C(35,47,62),TextXAlignment=XL},bn)
    T({Text="iPhone 17 Pro Max",Position=u(0,14,0,24),Size=u(0,220,0,26),TextSize=17,Font=FB,TextColor3=C(20,20,24),TextXAlignment=XL},bn)
    T({Text="$1,199.00",Position=u(0,14,0,50),Size=u(0,200,0,20),TextSize=15,Font=FB,TextColor3=C(120,20,0),TextXAlignment=XL},bn)
    local sd=B({Position=u(0,14,0,74),Size=u(0,84,0,20),BackgroundColor3=C(35,47,62),Text="See deal",TextSize=10},bn) Cr(10,sd)
    local pa=F({Position=u(0,250,0,0),Size=u(0,140,0,100),BackgroundTransparency=1},bn) phoneArt(pa,.34,.5,.29,.9,-8,false) phoneArt(pa,.66,.5,.29,.9,8,true)
    bn.MouseButton1Click:Connect(function() open(ITEMS[1]) end) sd.MouseButton1Click:Connect(function() open(ITEMS[1]) end)
    T({Text="Recommended for you",Size=u(0,390,0,16),TextSize=13,Font=FB,TextColor3=C(20,20,24),TextXAlignment=XL,LayoutOrder=o()},s)
   end
   local gd=F({Size=u(0,390,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1,LayoutOrder=o()},s) N("UIGridLayout",{CellSize=u(0,124,0,150),CellPadding=u(0,9,0,9)},gd)
   for _,it in ipairs(list) do
    local c=B({BackgroundColor3=WH},gd) Cr(8,c)
    local im=F({Position=u(0,6,0,6),Size=u(0,112,0,84),BackgroundColor3=it.col and it.col:Lerp(WH,.75) or C(238,238,242)},c) Cr(6,im) thumb(im,it,84,false)
    T({Text=it.name,Position=u(0,8,0,94),Size=u(0,108,0,14),TextSize=10,Font=FM,TextColor3=C(30,30,34),TextXAlignment=XL,TextTruncate=Enum.TextTruncate.AtEnd},c)
    T({Text=it.price,Position=u(0,8,0,108),Size=u(0,108,0,16),TextSize=12,Font=FB,TextColor3=C(177,39,4),TextXAlignment=XL},c) dots(c,8,129,it.rate)
    c.MouseButton1Click:Connect(function() open(it) end)
   end
   if #list==0 then T({Text="No results",Size=u(0,390,0,20),TextSize=12,Font=FG,TextColor3=C(110,110,118),LayoutOrder=o()},s) end
  end
 end
 sb:GetPropertyChangedSignal("Text"):Connect(function() q=sb.Text:lower() page="home" prod=nil render() end)
 render() return function() end
end

build.safari=function(b,a)
 local alive,ptok,hist,hi,n=true,0,{},0,0
 local bar=F({Position=u(0,0,0,20),Size=u(0,414,0,40),BackgroundColor3=C(246,246,248)},b) F({Position=u(0,0,1,-1),Size=u(1,0,0,1),BackgroundColor3=C(210,210,214)},bar)
 local function nb(x,t) return B({Position=u(0,x,0,6),Size=u(0,26,0,28),BackgroundTransparency=1,Text=t,TextSize=18,TextColor3=C(10,132,255)},bar) end
 local bk,fw=nb(6,"<"),nb(34,">")
 local tb=N("TextBox",{Position=u(0,66,0,7),Size=u(0,282,0,26),BackgroundColor3=C(228,228,233),Text="",PlaceholderText="Search or enter website name",PlaceholderColor3=C(120,120,128),TextColor3=C(0,0,0),Font=FM,TextSize=11,ClearTextOnFocus=false,TextXAlignment=XL,BorderSizePixel=0},bar) Cr(8,tb) N("UIPadding",{PaddingLeft=UDim.new(0,24),PaddingRight=UDim.new(0,64)},tb)
 local lk=F({Position=u(0,72,0,0),Size=u(0,14,0,40),BackgroundTransparency=1,ZIndex=3},bar) lockI(lk,0,9)
 local sec=T({Position=u(0,284,0,0),Size=u(0,60,0,40),TextSize=9,Font=FB,TextColor3=C(220,40,40),TextXAlignment=XR,ZIndex=3},bar)
 local hm=B({Position=u(0,352,0,6),Size=u(0,56,0,28),BackgroundTransparency=1,Text="Home",TextSize=11,Font=FM,TextColor3=C(10,132,255)},bar)
 local area=F({Position=u(0,0,0,60),Size=u(0,414,0,240),BackgroundTransparency=1,ClipsDescendants=true},b)
 local pages,nav,show={}
 local function ord() n+=1 return n end
 local function base(bg)
  ptok+=1 n=0 for _,c in ipairs(area:GetChildren()) do c:Destroy() end
  local s=N("ScrollingFrame",{Size=u(1,0,1,0),BackgroundColor3=bg,BorderSizePixel=0,ScrollBarThickness=3,AutomaticCanvasSize=Enum.AutomaticSize.Y,CanvasSize=u(0,0,0,0)},area)
  N("UIListLayout",{Padding=UDim.new(0,8),HorizontalAlignment=Enum.HorizontalAlignment.Center,SortOrder=Enum.SortOrder.LayoutOrder},s) N("UIPadding",{PaddingTop=UDim.new(0,8),PaddingBottom=UDim.new(0,16)},s)
  return s
 end
 local function txt(s,t,sz,fnt,col,h,al) return T({Text=t,Size=u(0,390,0,h or sz+6),TextSize=sz,Font=fnt or FG,TextColor3=col,TextXAlignment=al or XL,TextWrapped=true,TextYAlignment=Enum.TextYAlignment.Top,LayoutOrder=ord()},s) end
 local function btn(s,t,col,fg,w,h,cb) local k=B({Size=u(0,w,0,h),BackgroundColor3=col,Text=t,TextSize=12,TextColor3=fg,LayoutOrder=ord()},s) Cr(math.min(h/2,12),k) k.MouseButton1Click:Connect(cb) return k end
 local function hero(s,h,c1,c2) local f=F({Size=u(0,390,0,h),BackgroundColor3=WH,LayoutOrder=ord()},s) Cr(10,f) N("UIGradient",{Rotation=30,Color=ColorSequence.new(c1,c2)},f) return f end
 local function sim(t) alert("Simulation",t,{{"OK"}}) end

 function pages.start()
  local s=base(C(242,242,247))
  local function grid(title,list)
   txt(s,title,15,FB,C(20,20,24),20)
   local g=F({Size=u(0,390,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1,LayoutOrder=ord()},s) N("UIGridLayout",{CellSize=u(0,88,0,82),CellPadding=u(0,10,0,6)},g)
   for _,f in ipairs(list) do
    local cell=F({BackgroundTransparency=1},g)
    local k=B({Position=u(0,16,0,0),Size=u(0,56,0,56),BackgroundColor3=f[3],Text=f[4],TextSize=26},cell) Cr(14,k)
    T({Text=f[1],Position=u(0,0,0,60),Size=u(1,0,0,14),TextSize=10,TextColor3=C(30,30,34),TextXAlignment=XC},cell)
    k.MouseButton1Click:Connect(function() nav(f[2],true,false) end)
   end
  end
  grid("Favorites",{{"Roblox","www.roblox.com",C(35,37,39),"R"},{"YouTube","www.youtube.com",C(255,0,0),"Y"},{"Minecraft","www.minecraft.net",C(98,160,62),"M"},{"News","www.baseplate-news.com",C(60,60,66),"N"}})
  grid("Sus Sites",{{"Free Robux","free-robux-now.biz",C(255,200,0),"$"},{"Virus Check","your-ipad-has-virus.net",C(200,30,30),"!"},{"Prizes","totally-legit-prizes.xyz",C(150,60,200),"?"}})
 end

 function pages.roblox()
  local s=base(C(18,18,20))
  local hd=F({Size=u(0,414,0,36),BackgroundColor3=C(35,37,39),LayoutOrder=ord()},s)
  T({Text="ROBLOX",Position=u(0,14,0,0),Size=u(0,100,1,0),TextSize=16,Font=FB,TextXAlignment=XL},hd)
  for i,l in ipairs({"Discover","Avatar Shop","Create"}) do T({Text=l,Position=u(0,120+(i-1)*76,0,0),Size=u(0,76,1,0),TextSize=10,Font=FM,TextColor3=C(190,192,196)},hd) end
  local h=hero(s,110,C(0,162,255),C(80,60,220))
  T({Text="Play. Create. Explore.",Position=u(0,16,0,16),Size=u(0,300,0,30),TextSize=20,Font=FB,TextXAlignment=XL},h)
  T({Text="Millions of worlds made by players.",Position=u(0,16,0,48),Size=u(0,300,0,16),TextSize=11,Font=FG,TextXAlignment=XL},h)
  btn(h,"Sign Up",WH,C(0,100,200),90,26,function() sim("Sign up isn't real in this simulation.") end).Position=u(0,16,0,74)
  txt(s,"Popular Experiences",13,FB,WH,20)
  local g=F({Size=u(0,390,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1,LayoutOrder=ord()},s) N("UIGridLayout",{CellSize=u(0,122,0,96),CellPadding=u(0,8,0,8)},g)
  for _,e in ipairs({{"Obby Tower",C(235,90,70)},{"Brookside Town",C(70,170,110)},{"Blox Racers",C(240,170,40)},{"Sword Arena",C(110,110,200)},{"Pet Island",C(230,110,170)},{"Tycoon City",C(60,150,200)}}) do
   local c=B({BackgroundColor3=e[2]},g) Cr(8,c) N("UIGradient",{Rotation=90,Color=ColorSequence.new(WH,C(140,140,140))},c)
   T({Text=e[1],Position=u(0,6,1,-24),Size=u(1,-12,0,20),TextSize=11,Font=FB,TextXAlignment=XL,TextStrokeTransparency=.5},c)
   c.MouseButton1Click:Connect(function() sim("Joining games isn't available here.") end)
  end
 end

 local VIDS={{"a1","Top 10 Obby Fails","BloxBuddy","1.2M views",C(235,90,70)},{"b2","I Built a Castle in 24 Hours","PixelPete","3.4M views",C(70,150,220)},{"c3","Server Crash Compilation","LagLord","890K views",C(110,90,200)},{"d4","Funny Cats Being Cats","Whiskers TV","5.1M views",C(240,160,60)},{"e5","Lo-Fi Beats to Relax To","ChillCloud","12M views",C(60,170,140)}}
 function pages.youtube(path)
  local s=base(C(249,249,249))
  local hd=F({Size=u(0,414,0,38),BackgroundColor3=WH,LayoutOrder=ord()},s)
  local lg=F({Position=u(0,12,0,9),Size=u(0,28,0,20),BackgroundColor3=C(255,0,0)},hd) Cr(6,lg) tri(lg,10,4,12,1,WH)
  T({Text="YouTube",Position=u(0,46,0,0),Size=u(0,100,1,0),TextSize=15,Font=FB,TextColor3=C(20,20,20),TextXAlignment=XL},hd)
  local sb=F({Position=u(0,170,0,6),Size=u(0,150,0,26),BackgroundColor3=C(238,238,238)},hd) Cr(13,sb) T({Text="Search",Position=u(0,12,0,0),Size=u(1,-12,1,0),TextSize=10,TextColor3=C(120,120,120),TextXAlignment=XL},sb)
  local function card(v)
   local c=B({Size=u(0,390,0,148),BackgroundColor3=WH,LayoutOrder=ord()},s) Cr(8,c)
   local th=F({Size=u(1,0,0,100),BackgroundColor3=WH},c) Cr(8,th) N("UIGradient",{Rotation=35,Color=ColorSequence.new(v[5],C(30,30,40))},th) tri(th,187,34,32,1,WH)
   T({Text=v[2],Position=u(0,8,0,104),Size=u(1,-16,0,16),TextSize=12,Font=FB,TextColor3=C(20,20,20),TextXAlignment=XL,TextTruncate=Enum.TextTruncate.AtEnd},c)
   T({Text=v[3].."  -  "..v[4],Position=u(0,8,0,122),Size=u(1,-16,0,14),TextSize=10,TextColor3=C(100,100,100),TextXAlignment=XL},c)
   c.MouseButton1Click:Connect(function() nav("www.youtube.com/watch?v="..v[1],true,false) end)
  end
  local wid=path:match("watch%?v=(%w+)")
  if wid then
   local v=VIDS[1] for _,x in ipairs(VIDS) do if x[1]==wid then v=x end end
   local pl=F({Size=u(0,414,0,200),BackgroundColor3=WH,LayoutOrder=ord()},s) N("UIGradient",{Rotation=45,Color=ColorSequence.new(v[5],C(10,10,14))},pl) tri(pl,191,72,56,1,WH)
   local tr=F({Position=u(0,12,1,-14),Size=u(0,390,0,4),BackgroundColor3=C(90,90,95)},pl) local fl=F({Size=u(0,0,1,0),BackgroundColor3=C(255,0,0)},tr)
   local my=ptok task.spawn(function() local t=0 while alive and ptok==my do t=(t+.3)%100 fl.Size=u(t/100,0,1,0) task.wait(.1) end end)
   txt(s,v[2],14,FB,C(20,20,20),20) txt(s,v[3].."  -  "..v[4],10,FM,C(100,100,100),14)
   btn(s,"Like",C(235,235,235),C(20,20,20),90,26,function() sim("Likes aren't saved in this simulation.") end)
   txt(s,"Up next",13,FB,C(20,20,20),20)
  end
  for _,v in ipairs(VIDS) do if v[1]~=wid then card(v) end end
 end

 function pages.minecraft()
  local s=base(C(30,30,34))
  local hd=F({Size=u(0,414,0,36),BackgroundColor3=C(20,20,22),LayoutOrder=ord()},s) T({Text="MINECRAFT",Position=u(0,14,0,0),Size=u(0,160,1,0),TextSize=16,Font=FB,TextColor3=C(110,190,70),TextXAlignment=XL},hd)
  local h=hero(s,120,C(120,190,255),C(60,120,200))
  for i=0,5 do local blk=F({Position=u(0,24+i*46,0,66),Size=u(0,42,0,42),BackgroundColor3=C(121,85,58)},h) F({Size=u(1,0,0,12),BackgroundColor3=C(98,160,62)},blk) end
  T({Text="Build Anything.",Position=u(0,16,0,12),Size=u(0,300,0,30),TextSize=20,Font=FB,TextXAlignment=XL},h)
  btn(h,"Get Minecraft",C(98,160,62),WH,110,24,function() sim("Downloads aren't available here.") end).Position=u(0,16,0,38)
  txt(s,"Latest News",13,FB,WH,20)
  for _,e in ipairs({{"The Wandering Forest Update",C(70,130,70)},{"New Mobs Arrive in the Caves",C(90,90,120)},{"Community Build Contest",C(170,110,50)}}) do
   local c=F({Size=u(0,390,0,52),BackgroundColor3=WH,LayoutOrder=ord()},s) Cr(8,c) N("UIGradient",{Rotation=0,Color=ColorSequence.new(e[2],C(40,40,46))},c)
   T({Text=e[1],Position=u(0,12,0,0),Size=u(1,-24,1,0),TextSize=12,Font=FB,TextXAlignment=XL},c)
  end
 end

 local HL={{"Player Finds Secret Room Behind Spawn","WORLD"},{"Server Lag Blamed On Too Many Parts","TECH"},{"Local Noob Learns To Jump, Community Celebrates","LIFE"},{"Sunny Skies Expected On Baseplate All Week","WEATHER"}}
 function pages.news(path)
  local s=base(WH)
  local m=F({Size=u(0,414,0,50),BackgroundColor3=WH,LayoutOrder=ord()},s)
  T({Text="BASEPLATE DAILY",Position=u(0,0,0,4),Size=u(1,0,0,26),TextSize=20,Font=FB,TextColor3=C(20,20,20),TextXAlignment=XC},m)
  T({Text=os.date("%A, %B %d"),Position=u(0,0,0,30),Size=u(1,0,0,14),TextSize=10,TextColor3=C(110,110,116),TextXAlignment=XC},m)
  F({Position=u(0,12,1,-2),Size=u(1,-24,0,2),BackgroundColor3=C(20,20,20)},m)
  local aid=tonumber(path:match("^a(%d+)"))
  if aid and HL[aid] then
   txt(s,HL[aid][2],10,FB,C(200,40,40),14) txt(s,HL[aid][1],18,FB,C(20,20,20),48)
   txt(s,"Witnesses say the story unfolded quickly, with players gathering to see it for themselves.",12,FG,C(50,50,56),40)
   txt(s,"Officials say more details will follow as the story develops.",12,FG,C(50,50,56),30)
   btn(s,"Back to front page",C(20,20,20),WH,160,28,function() nav("www.baseplate-news.com",true,false) end)
  else
   local h=hero(s,90,C(60,60,70),C(20,20,24)) T({Text=HL[1][2],Position=u(0,12,0,8),Size=u(0,100,0,12),TextSize=9,Font=FB,TextColor3=C(255,90,80),TextXAlignment=XL},h)
   T({Text=HL[1][1],Position=u(0,12,0,24),Size=u(1,-24,0,56),TextSize=17,Font=FB,TextWrapped=true,TextXAlignment=XL,TextYAlignment=Enum.TextYAlignment.Top},h)
   local hb=B({Size=u(1,0,1,0),BackgroundTransparency=1},h) hb.MouseButton1Click:Connect(function() nav("www.baseplate-news.com/a1",true,false) end)
   for i=2,#HL do
    local r=B({Size=u(0,390,0,44),BackgroundColor3=C(245,245,247),LayoutOrder=ord()},s) Cr(6,r)
    T({Text=HL[i][2],Position=u(0,10,0,4),Size=u(0,100,0,12),TextSize=8,Font=FB,TextColor3=C(200,40,40),TextXAlignment=XL},r)
    T({Text=HL[i][1],Position=u(0,10,0,16),Size=u(1,-20,0,24),TextSize=11,Font=FB,TextColor3=C(20,20,20),TextXAlignment=XL,TextWrapped=true,TextYAlignment=Enum.TextYAlignment.Top},r)
    r.MouseButton1Click:Connect(function() nav("www.baseplate-news.com/a"..i,true,false) end)
   end
  end
 end

 function pages.robux()
  local s=base(C(255,225,0))
  local h=F({Size=u(0,390,0,70),BackgroundColor3=C(220,20,20),LayoutOrder=ord()},s) Cr(8,h)
  T({Text="WINNER!!!",Position=u(0,0,0,4),Size=u(1,0,0,36),TextSize=26,Font=FB},h) T({Text="CLAIM 10,000 FREE ROBUX NOW",Position=u(0,0,0,40),Size=u(1,0,0,22),TextSize=14,Font=FB},h)
  local cd=txt(s,"Offer ends in 04:59",14,FB,C(180,0,0),20,XC)
  local my=ptok task.spawn(function() local t=299 while alive and ptok==my and t>0 do cd.Text=string.format("Offer ends in %02d:%02d",t//60,t%60) t-=1 task.wait(1) end end)
  txt(s,"No password needed!!! 100% REAL!!! 1,284,331 players claimed today!!!",11,FM,C(40,40,40),44,XC)
  btn(s,"CLAIM NOW",C(40,200,40),WH,200,38,function()
   alert("Human Verification","Complete 5 surveys to continue.",{{"OK",nil,function()
    alert("Download Required","Install RobuxBooster.exe to get your Robux.",{{"Cancel"},{"Install",nil,function() alert("Just Kidding!","This was a fake scam page. Nothing was downloaded.",{{"OK"}}) end}}) end}}) end)
 end
 function pages.virus()
  local s=base(C(150,0,0))
  txt(s,"WARNING!!!",24,FB,WH,32,XC) txt(s,"3 VIRUSES FOUND ON YOUR IPAD",13,FB,C(255,230,0),20,XC)
  local tr=F({Size=u(0,300,0,10),BackgroundColor3=C(60,0,0),LayoutOrder=ord()},s) Cr(5,tr) local fl=F({Size=u(0,0,1,0),BackgroundColor3=C(255,60,60)},tr) Cr(5,fl)
  local my=ptok task.spawn(function() local t=0 while alive and ptok==my do t=(t+.02)%1 fl.Size=u(t,0,1,0) task.wait(.05) end end)
  for _,v in ipairs({"Trojan.Robux.Stealer","Adware.Popup.Spam","Spyware.Keylogger.X"}) do txt(s,"! "..v.."  -  CRITICAL",11,FB,C(255,200,200),16,XC) end
  btn(s,"REMOVE VIRUSES NOW",C(255,200,0),C(60,0,0),220,36,function() alert("Fake Alert","Your iPad is fine. This was a fake scam page.",{{"OK"}}) end)
 end
 function pages.prize()
  local s=base(C(90,40,170))
  txt(s,"CONGRATULATIONS!",22,FB,WH,30,XC) txt(s,"You are visitor #1,000,000! You won an iPhone 17!",13,FM,C(255,230,120),40,XC)
  btn(s,"CLAIM PRIZE",C(255,200,0),C(60,20,100),200,38,function()
   alert("Almost There","Pay $1 shipping to claim your prize.",{{"Cancel"},{"Continue",nil,function() alert("Just Kidding!","Fake prize page. Never enter card details on sites like this.",{{"OK"}}) end}}) end)
 end
 function pages.warn(e)
  local s=base(C(185,28,28))
  local ic=F({Size=u(0,50,0,50),BackgroundColor3=WH,LayoutOrder=ord()},s) Cr(25,ic) T({Text="!",Size=u(1,0,1,0),TextSize=30,Font=FB,TextColor3=C(185,28,28)},ic)
  txt(s,"Deceptive Website Warning",16,FB,WH,22,XC)
  txt(s,"Safari thinks this site may try to trick you into installing software or sharing personal info.",11,FG,C(255,220,220),44,XC)
  btn(s,"Go Back",WH,C(185,28,28),180,32,function() if hi>1 then hi-=1 show(hist[hi]) else nav("",true,false) end end)
  btn(s,"Visit Website Anyway",C(140,15,15),WH,180,32,function() e.ok=true show(e) end)
 end
 function pages.nofind()
  local s=base(C(242,242,247)) txt(s,"Safari Can't Find the Server",16,FB,C(20,20,24),22,XC) txt(s,"Safari can't open the page because the server can't be found.",11,FG,C(100,100,106),30,XC)
 end
 function pages.search(q)
  local s=base(C(242,242,247)) txt(s,'Results for "'..q..'"',13,FB,C(20,20,24),20)
  for _,r in ipairs({{"Roblox","www.roblox.com","Play millions of experiences.",false},{"YouTube","www.youtube.com","Watch, share and create videos.",false},{"Minecraft","www.minecraft.net","Build and explore worlds.",false},{"Baseplate Daily","www.baseplate-news.com","Today's top stories.",false},{"FREE ROBUX NOW!!!","free-robux-now.biz","Claim your free Robux.",true},{"Your iPad Has a Virus","your-ipad-has-virus.net","Scan your device now.",true},{"You Won a Prize","totally-legit-prizes.xyz","Claim your prize today.",true}}) do
   local c=B({Size=u(0,390,0,52),BackgroundColor3=WH,LayoutOrder=ord()},s) Cr(8,c)
   T({Text=r[1],Position=u(0,10,0,4),Size=u(1,-20,0,16),TextSize=12,Font=FB,TextColor3=C(10,90,200),TextXAlignment=XL},c)
   T({Text=r[2]..(r[4] and "  (Not Secure)" or ""),Position=u(0,10,0,20),Size=u(1,-20,0,12),TextSize=9,TextColor3=r[4] and C(200,40,40) or C(40,140,60),TextXAlignment=XL},c)
   T({Text=r[3],Position=u(0,10,0,33),Size=u(1,-20,0,14),TextSize=10,TextColor3=C(90,90,96),TextXAlignment=XL},c)
   c.MouseButton1Click:Connect(function() nav(r[2],true,false) end)
  end
 end

 local SUS={robux=true,virus=true,prize=true}
 local function key(l) if l:find("free%-?robux") then return "robux" elseif l:find("virus") then return "virus" elseif l:find("prize") then return "prize" elseif l:find("roblox") then return "roblox" elseif l:find("youtu") then return "youtube" elseif l:find("minecraft") then return "minecraft" elseif l:find("news") then return "news" end end
 function show(e)
  local u2=e.u local l=(u2:lower():gsub("^https?://",""):gsub("^www%.","")) local path=l:match("^[^/]+/(.*)$") or ""
  local k=key(l) local bad=k~=nil and SUS[k]==true
  tb.Text=u2 lk.Visible=(u2~="") and not bad sec.Text=bad and "Not Secure" or ""
  if u2=="" then pages.start() elseif bad and not e.ok then pages.warn(e) elseif k then pages[k](path)
  elseif l:find("%.") and not l:find("%s") then pages.nofind() else pages.search(u2) end
 end
 function nav(u2,push,ok) for i=#hist,hi+1,-1 do table.remove(hist,i) end table.insert(hist,{u=u2,ok=ok}) hi=#hist show(hist[hi]) end
 bk.MouseButton1Click:Connect(function() if hi>1 then hi-=1 show(hist[hi]) end end)
 fw.MouseButton1Click:Connect(function() if hi<#hist then hi+=1 show(hist[hi]) end end)
 hm.MouseButton1Click:Connect(function() nav("",true,false) end)
 tb.FocusLost:Connect(function(enter) if enter and tb.Text~="" then nav(tb.Text,true,false) end end)
 nav("",true,false)
 return function() alive=false end
end

build.messages=function(b,a)
 local TXS=game:GetService("TextService")
 local alive,cur,push=true,nil,nil
 local CONT={
  {"mom","Mom",C(240,120,140),{"Okay sweetie!","Be home before dark.","Love you! Did you eat?","Don't forget your jacket.","Call me later!"},"Hi sweetie!",{"Are you eating enough?","Text me when you get home."}},
  {"jake","Jake",C(70,150,220),{"lol fr","wait what","nah bro","bet","ok but have you tried obbies","im lagging so bad rn","ayo","no way"},"yo what's up",{"bro hop on","did you see the new update"}},
  {"sophie","Sophie",C(170,110,220),{"haha omg","wait really??","stop it lol","I'm so tired today","same!!","send pics","ok ok ok"},"heyyy!",{"omg you won't believe what happened","are you free later?"}},
  {"pizza","Pizza Palace",C(235,120,60),{"Thanks for your order!","Your pizza is 5 minutes away.","We hope you enjoyed your meal!","Reply STOP to unsubscribe."},"Welcome to Pizza Palace!",{"Two large pizzas for the price of one today!"}},
  {"coach","Coach",C(60,160,110),{"Good effort today.","See you at practice.","Hydrate!","Be on time.","Nice work."},"Hello. Ready for practice?",{"Practice moved to 4pm.","Don't be late tomorrow."}}}
 if not S.msgs then
  S.msgs={mom={{me=false,t="Dinner's at 6, don't be late!",time="9:12 AM"}},jake={{me=false,t="bro did you see the new update",time="8:47 AM"}},sophie={{me=true,t="omg same lol",time="Yesterday"}},pizza={{me=false,t="Your order is on its way!",time="Yesterday"}},coach={{me=false,t="Practice moved to 4pm",time="Mon"}}}
  S.unread={mom=true,jake=true}
 end
 local root=F({Size=u(1,0,1,0),BackgroundTransparency=1},b)
 local list,chat
 local function now() return (os.date("%I:%M %p"):gsub("^0","")) end
 local function clr() for _,c in ipairs(root:GetChildren()) do c:Destroy() end end
 local function avatar(par,c,x,y,s) local f=F({Position=u(0,x,0,y),Size=u(0,s,0,s),BackgroundColor3=c[3]},par) Cr(s/2,f) T({Text=c[2]:sub(1,1),Size=u(1,0,1,0),TextSize=s*.45,Font=FB},f) return f end
 local function deliver(c,txt)
  local m={me=false,t=txt,time=now()} table.insert(S.msgs[c[1]],m)
  if alive and cur==c[1] and push then push(m) else S.unread[c[1]]=true notify(c[2],txt,c[3]) if alive and cur==nil then list() end end
 end
 function list()
  clr() cur=nil push=nil
  hdr(root,"Messages",C(0,0,0))
  local sf=N("ScrollingFrame",{Position=u(0,0,0,72),Size=u(1,0,1,-76),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=3,AutomaticCanvasSize=Enum.AutomaticSize.Y,CanvasSize=u(0,0,0,0)},root)
  N("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder},sf)
  for i,c in ipairs(CONT) do
   local ms=S.msgs[c[1]] local last=ms[#ms]
   local r=B({Size=u(0,414,0,56),BackgroundColor3=WH,LayoutOrder=i},sf)
   if S.unread[c[1]] then local d=F({Position=u(0,6,0,24),Size=u(0,8,0,8),BackgroundColor3=C(10,132,255)},r) Cr(4,d) end
   avatar(r,c,20,8,40)
   T({Text=c[2],Position=u(0,68,0,8),Size=u(0,240,0,16),TextSize=13,Font=FB,TextColor3=C(0,0,0),TextXAlignment=XL},r)
   T({Text=(last.me and "You: " or "")..last.t,Position=u(0,68,0,26),Size=u(0,260,0,16),TextSize=11,Font=FG,TextColor3=C(142,142,147),TextXAlignment=XL,TextTruncate=Enum.TextTruncate.AtEnd},r)
   T({Text=last.time,Position=u(0,330,0,8),Size=u(0,72,0,16),TextSize=10,Font=FG,TextColor3=C(142,142,147),TextXAlignment=XR},r)
   F({Position=u(0,68,1,-1),Size=u(1,-68,0,1),BackgroundColor3=C(218,218,222)},r)
   r.MouseButton1Click:Connect(function() chat(c) end)
  end
 end
 function chat(c)
  clr() cur=c[1] S.unread[c[1]]=false
  local top=F({Position=u(0,0,0,20),Size=u(0,414,0,40),BackgroundColor3=C(246,246,248),ZIndex=3},root) F({Position=u(0,0,1,-1),Size=u(1,0,0,1),BackgroundColor3=C(210,210,214)},top)
  local bk=B({Position=u(0,8,0,0),Size=u(0,90,0,40),BackgroundTransparency=1,Text="< Messages",TextSize=12,TextColor3=C(10,132,255),Font=FM,TextXAlignment=XL},top) bk.MouseButton1Click:Connect(function() list() end)
  avatar(top,c,152,9,22) T({Text=c[2],Position=u(0,180,0,0),Size=u(0,150,1,0),TextSize=12,Font=FB,TextColor3=C(0,0,0),TextXAlignment=XL},top)
  local sf=N("ScrollingFrame",{Position=u(0,0,0,60),Size=u(1,0,0,200),BackgroundColor3=WH,BorderSizePixel=0,ScrollBarThickness=2,CanvasSize=u(0,0,0,0)},root)
  local y=8
  local function fit() sf.CanvasSize=u(0,0,0,y+4) sf.CanvasPosition=V2(0,math.max(0,y+4-200)) end
  local function bubble(m)
   local sz=TXS:GetTextSize(m.t,12,FM,V2(230,10000)) local w,h=sz.X+22,sz.Y+14
   local row=F({Position=u(0,0,0,y),Size=u(0,414,0,h),BackgroundTransparency=1},sf)
   local bb=F({Position=m.me and u(0,414-12-w,0,0) or u(0,12,0,0),Size=u(0,w,0,h),BackgroundColor3=m.me and C(10,132,255) or C(229,229,234)},row) Cr(14,bb)
   T({Text=m.t,Position=u(0,11,0,0),Size=u(1,-22,1,0),TextSize=12,Font=FM,TextColor3=m.me and WH or C(0,0,0),TextWrapped=true,TextXAlignment=XL},bb)
   y+=h+6 fit()
  end
  local function typing()
   local row=F({Position=u(0,0,0,y),Size=u(0,414,0,28),BackgroundTransparency=1},sf)
   local bb=F({Position=u(0,12,0,0),Size=u(0,54,0,28),BackgroundColor3=C(229,229,234)},row) Cr(14,bb)
   local ds={} for i=1,3 do ds[i]=F({Position=u(0,12+(i-1)*12,0,11),Size=u(0,7,0,7),BackgroundColor3=C(150,150,156)},bb) Cr(4,ds[i]) end
   y+=34 fit() local on2=true
   task.spawn(function() local k=0 while on2 and row.Parent do k=k%3+1 for i,d in ipairs(ds) do d.BackgroundTransparency=(i==k) and 0 or .55 end task.wait(.25) end end)
   return function() on2=false row:Destroy() y-=34 fit() end
  end
  for _,m in ipairs(S.msgs[c[1]]) do bubble(m) end
  push=bubble
  local inp=F({Position=u(0,0,0,262),Size=u(0,414,0,38),BackgroundColor3=C(246,246,248),ZIndex=3},root)
  local tb=N("TextBox",{Position=u(0,12,0,4),Size=u(0,346,0,30),BackgroundColor3=WH,Text="",PlaceholderText="iMessage",PlaceholderColor3=C(150,150,156),TextColor3=C(0,0,0),Font=FM,TextSize=12,ClearTextOnFocus=false,TextXAlignment=XL,BorderSizePixel=0},inp) Cr(15,tb) N("UIPadding",{PaddingLeft=UDim.new(0,12),PaddingRight=UDim.new(0,8)},tb)
  local sn=B({Position=u(0,366,0,4),Size=u(0,30,0,30),BackgroundColor3=C(10,132,255),Text="^",TextSize=16},inp) Cr(15,sn)
  local function send()
   local t=(tb.Text:gsub("^%s+",""):gsub("%s+$","")) if t=="" then return end tb.Text=""
   local m={me=true,t=t,time=now()} table.insert(S.msgs[c[1]],m) bubble(m)
   task.spawn(function()
    task.wait(.6) local rm if alive and cur==c[1] then rm=typing() end
    task.wait(1.2+math.random()*1.6) if rm and rm then pcall(rm) end
    local l=t:lower() local out
    if l:match("^hi") or l:match("^hey") or l:match("^hello") then out=c[5]
    elseif l:find("%?") and math.random()<.5 then local q={"hmm good question lol","idk honestly","let me think...","maybe?"} out=q[math.random(#q)]
    else out=c[4][math.random(#c[4])] end
    deliver(c,out)
   end)
  end
  sn.MouseButton1Click:Connect(send) tb.FocusLost:Connect(function(enter) if enter then send() end end)
 end
 task.spawn(function() while alive do task.wait(20+math.random()*20) if alive then local c=CONT[math.random(#CONT)] deliver(c,c[6][math.random(#c[6])]) end end end)
 list()
 return function() alive=false end
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
local shown=false
local function showPad(v)
 if v==shown then return end shown=v
 if v then G.Enabled=true tw(av,.7,{Value=1},Enum.EasingStyle.Back)
 else closeCC() tw(av,.45,{Value=0},Enum.EasingStyle.Quint,Enum.EasingDirection.In).Completed:Connect(function() if not shown then G.Enabled=false end end) end
end
local function mkPad()
 local tool=N("Tool",{Name="iPad",RequiresHandle=true,CanBeDropped=false,ToolTip="iPad"})
 local h=N("Part",{Name="Handle",Size=Vector3.new(1.55,.09,1.18),Color=C(66,66,72),Material=Enum.Material.Metal,CanCollide=false},tool)
 local sg=N("SurfaceGui",{Face=Enum.NormalId.Top,CanvasSize=V2(442,338)},h)
 local sbz=F({Size=u(1,0,1,0),BackgroundColor3=C(8,8,10)},sg) Cr(26,sbz)
 local ssc=F({Position=u(0,14,0,14),Size=u(0,414,0,310),BackgroundColor3=WH},sg) wall(ssc) local m2=F({Position=u(0,14,0,14),Size=u(0,414,0,310),BackgroundTransparency=1,ZIndex=3},sg) Cr(12,m2) N("UIStroke",{Color=C(8,8,10),Thickness=11},m2)
 T({Text="iPadOS",Size=u(1,0,1,0),TextSize=40,Font=FB},ssc)
 local sc2=F({Position=u(.5,-3,0,5),Size=u(0,6,0,6),BackgroundColor3=C(10,10,14)},sg) Cr(3,sc2)
 tool.Equipped:Connect(function() showPad(true) end)
 tool.Unequipped:Connect(function() showPad(false) end)
 return tool
end
local function mkPhone()
 local tool=N("Tool",{Name="iPhone 17 Pro Max",RequiresHandle=true,CanBeDropped=false,ToolTip="iPhone 17 Pro Max"})
 local h=N("Part",{Name="Handle",Size=Vector3.new(.62,.08,1.32),Color=PHC,Material=Enum.Material.Metal,CanCollide=false},tool)
 local sg=N("SurfaceGui",{Face=Enum.NormalId.Top,CanvasSize=V2(282,600)},h)
 local bz=F({Size=u(1,0,1,0),BackgroundColor3=C(0,0,0)},sg) Cr(46,bz)
 local scr=F({Position=u(0,6,0,6),Size=u(1,-12,1,-12),BackgroundColor3=C(22,22,24)},sg) Cr(40,scr)
 local stT=T({Text="9:41",Position=u(0,30,0,14),Size=u(0,70,0,20),TextSize=16,Font=FB,TextXAlignment=XL},scr)
 local isl=F({Position=u(.5,-46,0,12),Size=u(0,92,0,27),BackgroundColor3=C(0,0,0)},scr) Cr(14,isl)
 local ln=F({Position=u(0,70,0,9),Size=u(0,8,0,8),BackgroundColor3=C(24,34,60)},isl) Cr(4,ln)
 for i,hh in ipairs({4,6,8,10}) do local bb=F({Position=u(0,170+(i-1)*4,0,29-hh),Size=u(0,3,0,hh),BackgroundColor3=WH},scr) Cr(1,bb) end
 local wc=F({Position=u(0,192,0,19),Size=u(0,16,0,10),BackgroundTransparency=1,ClipsDescendants=true},scr)
 for _,s in ipairs({16,10}) do local rg=F({Position=u(0,8-s/2,0,9-s/2),Size=u(0,s,0,s),BackgroundTransparency=1},wc) Cr(s/2,rg) N("UIStroke",{Color=WH,Thickness=2},rg) end
 local wd=F({Position=u(0,6,0,6),Size=u(0,4,0,4),BackgroundColor3=WH},wc) Cr(2,wd)
 local bt=F({Position=u(0,214,0,18),Size=u(0,22,0,11),BackgroundTransparency=1},scr) Cr(3,bt) N("UIStroke",{Color=WH,Thickness=1,Transparency=.4},bt)
 local bfl=F({Position=u(0,2,0,2),Size=u(.8,-2,1,-4),BackgroundColor3=WH},bt) Cr(2,bfl) F({Position=u(0,238,0,21),Size=u(0,2,0,5),BackgroundColor3=WH},scr)
 F({Position=u(.5,-7,0,98),Size=u(0,14,0,10),BackgroundColor3=WH},scr)
 local sh=F({Position=u(.5,-5,0,90),Size=u(0,10,0,12),BackgroundTransparency=1},scr) Cr(5,sh) N("UIStroke",{Color=WH,Thickness=1.5},sh)
 local dtL=T({Position=u(0,0,0,116),Size=u(1,0,0,20),TextSize=16,Font=FM,TextXAlignment=XC},scr)
 local tmL=T({Position=u(0,0,0,134),Size=u(1,0,0,90),TextSize=88,Font=FM,TextXAlignment=XC},scr)
 for i,x in ipairs({30,196}) do local cb=F({Position=u(0,x,0,500),Size=u(0,44,0,44),BackgroundColor3=C(60,60,64),BackgroundTransparency=.3},scr) Cr(22,cb) if i==2 then GL.camera(cb) else rc(cb,.5,.36,.3,.18,WH,.2) rc(cb,.5,.62,.2,.38,WH,.2) end end
 local hi=F({Position=u(.5,-56,0,568),Size=u(0,112,0,5),BackgroundColor3=WH},scr) Cr(3,hi)
 task.spawn(function() while h.Parent do local tt=(os.date("%I:%M"):gsub("^0","")) tmL.Text=tt stT.Text=tt dtL.Text=os.date("%A, %B %d") task.wait(1) end end)
 return tool
end
local function dropBox()
 local ch=LP.Character local hrp=ch and ch:FindFirstChild("HumanoidRootPart")
 if not hrp then task.delay(2,dropBox) return end
 local lv=hrp.CFrame.LookVector local fw=Vector3.new(lv.X,0,lv.Z) fw=fw.Magnitude>.1 and fw.Unit or Vector3.new(0,0,-1)
 local tp=hrp.Position+fw*5
 local rp=RaycastParams.new() rp.FilterDescendantsInstances={ch} rp.FilterType=Enum.RaycastFilterType.Exclude
 local hit=workspace:Raycast(tp+Vector3.new(0,60,0),Vector3.new(0,-200,0),rp)
 local gy=(hit and hit.Position.Y or hrp.Position.Y-3)+.85
 local yaw=CFrame.Angles(0,math.rad(math.random(0,359)),0)
 local bx=N("Part",{Name="AmazonBox",Size=Vector3.new(2.4,1.7,1.9),Color=C(196,152,98),Material=Enum.Material.SmoothPlastic,Anchored=true,CanCollide=false,CFrame=CFrame.new(tp.X,gy+50,tp.Z)*yaw},workspace)
 local g1=N("SurfaceGui",{Face=Enum.NormalId.Front,CanvasSize=V2(240,170)},bx)
 T({Text="amazon",Position=u(0,0,0,30),Size=u(1,0,0,80),TextSize=44,Font=FB,TextColor3=C(30,30,34)},g1) rc(g1,.5,.72,.6,.06,C(255,153,0),.5)
 local g2=N("SurfaceGui",{Face=Enum.NormalId.Top,CanvasSize=V2(240,190)},bx) F({Position=u(.5,-14,0,0),Size=u(0,28,1,0),BackgroundColor3=C(222,196,150)},g2)
 tw(bx,.9,{CFrame=CFrame.new(tp.X,gy,tp.Z)*yaw},Enum.EasingStyle.Quad,Enum.EasingDirection.In).Completed:Connect(function()
  tw(bx,.12,{CFrame=CFrame.new(tp.X,gy+.6,tp.Z)*yaw}).Completed:Connect(function() tw(bx,.15,{CFrame=CFrame.new(tp.X,gy,tp.Z)*yaw},Enum.EasingStyle.Quad,Enum.EasingDirection.In) end)
  notify("Amazon","Your package has arrived nearby.",C(255,153,0))
  local opened=false
  local function open()
   if opened then return end opened=true S.ownsPhone=true
   local bp=LP:FindFirstChild("Backpack") if bp and not bp:FindFirstChild("iPhone 17 Pro Max") then mkPhone().Parent=bp end
   notify("Package Opened","iPhone 17 Pro Max added to your items",C(255,153,0))
   for _,d in ipairs(bx:GetChildren()) do if d:IsA("SurfaceGui") or d:IsA("ProximityPrompt") or d:IsA("ClickDetector") then d:Destroy() end end
   tw(bx,.5,{Transparency=1}) task.delay(.6,function() bx:Destroy() end)
  end
  local pp=N("ProximityPrompt",{ActionText="Open",ObjectText="Amazon Package",HoldDuration=.4,MaxActivationDistance=14,RequiresLineOfSight=false},bx) pp.Triggered:Connect(open)
  local cd=N("ClickDetector",{MaxActivationDistance=20},bx) cd.MouseClick:Connect(open)
 end)
end
function placeOrder() task.delay(math.random()<.5 and 5 or 20,dropBox) end
local function giveTools()
 local bp=LP:WaitForChild("Backpack")
 for _,n in ipairs({"iPad","iPhone 17 Pro Max"}) do local o=bp:FindFirstChild(n) if o then o:Destroy() end end
 mkPad().Parent=bp
 if S.ownsPhone then mkPhone().Parent=bp end
end
LP.CharacterAdded:Connect(function() showPad(false) task.wait(.7) giveTools() end)
giveTools()
