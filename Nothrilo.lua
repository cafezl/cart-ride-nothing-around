-- =============================================================================
-- Nothrilo 🇧🇷 — Menu completo por Cafezl
-- Versão auditada: bugs corrigidos + novas funções
-- =============================================================================
-- Nothrilo / Cafezl | build protegido O2 | Darklua AST v0.19.0 (rename_variables + dense) | fonte sha256 8ba066d10db28185a32363842a70795efe0cbbbbcb6fb0f70a33d36ee10fe03d
local a=game:GetService('Players')local b=game:GetService('RunService')local c=game:GetService('UserInputService')local d=game:GetService('TweenService')local e=game:GetService('StarterGui')local f=a.
LocalPlayer if not f then return end local g='Nothrilo \u{1f1e7}\u{1f1f7}'local h=g..' | Feito por Cafezl'local i=_G if type(getgenv)=='function'then local j,k=pcall(getgenv)if j and type(k)=='table'
then i=k end end local j=(tonumber(i.__CafezlSuiteGeneration)or 0)+1 do local k=pcall(function()i.__CafezlSuiteGeneration=j end)if not k then i=_G j=(tonumber(i.__CafezlSuiteGeneration)or 0)+1 i.
__CafezlSuiteGeneration=j end end local function isCurrentSuiteGeneration()return i.__CafezlSuiteGeneration==j end local k=(function()if type(gethui)=='function'then local k,l=pcall(gethui)if k and l
then return l end end local k,l=pcall(function()return game:GetService('CoreGui')end)if k and l then local m=Instance.new('ScreenGui')local n=pcall(function()m.Parent=l end)if m.Parent then m:Destroy(
)end if n then return l end end return f:FindFirstChildOfClass('PlayerGui')or f:FindFirstChild('PlayerGui')end)()if not isCurrentSuiteGeneration()then return end if not k then warn(g..
': PlayerGui/CoreGui ainda n\u{e3}o est\u{e1} dispon\u{ed}vel.')return end local l={}do local m={}local function addGuiRoot(n)if n and not m[n]then m[n]=true table.insert(l,n)end end addGuiRoot(k)
pcall(function()addGuiRoot(game:GetService('CoreGui'))end)addGuiRoot(f:FindFirstChild('PlayerGui'))end local m local n=false local o={}local function trackConnection(p)table.insert(o,p)return p end
for p,q in ipairs(l)do for r,s in ipairs({'NothriloRuntime','CafezitosRuntime'})do local t=q:FindFirstChild(s)if t then local u=t:FindFirstChild('Cleanup')if u and u:IsA('BindableEvent')then u:Fire()
end t:Destroy()end end end local p=workspace.Gravity local q=Instance.new('Folder')q.Name='NothriloRuntime'q.Parent=k do local r=Instance.new('BindableEvent')r.Name='Cleanup'r.Parent=q
trackConnection(r.Event:Connect(function()if m then m()return end n=true for s,t in ipairs(l)do local u=t:FindFirstChild('NothriloKeyGate')if u then pcall(function()u:Destroy()end)end end for s=#o,1,-
1 do local t=o[s]pcall(function()t:Disconnect()end)o[s]=nil end if q and q.Parent then q:Destroy()end end))end for r,s in ipairs(l)do for t,u in ipairs(s:GetChildren())do if u:IsA('ScreenGui')then if
u.Name=='NothriloLauncher'or u.Name=='NothriloNotifications'or u.Name=='NothriloLoading'or u.Name=='NothriloMobileFly'or u.Name=='NothriloKeyGate'then u:Destroy()else local v=u:FindFirstChild('Main')
local w=v and v:FindFirstChild('MainHeader')local x=w and w:FindFirstChild('title')if x and x:IsA('TextLabel')and x.Text:find('Nothrilo',1,true)then u:Destroy()end end end end end local r={SchemeColor
=Color3.fromRGB(255,0,170),Background=Color3.fromRGB(8,8,10),Header=Color3.fromRGB(15,15,18),TextColor=Color3.fromRGB(245,245,245),ElementColor=Color3.fromRGB(22,22,27)}do local s=game:GetService(
'HttpService')local t local function runFreeKeyGate()local u='https://nothrilo-key.urielcafe01.workers.dev'local v=u:match('^https://')~=nil and not u:find('__NOTHRILO_',1,true)local w=
'Nothrilo/key-cache-v1.json'local x='Nothrilo'local y='__NothriloFreeKeyCacheV1'local z=24*60*60 local function environmentFunction(A)local B pcall(function()B=rawget(i,A)end)if type(B)=='function'
then return B end pcall(function()B=rawget(_G,A)end)if type(B)=='function'then return B end return nil end local function nestedEnvironmentFunction(A,B)local C pcall(function()C=rawget(i,A)end)if
type(C)~='table'then pcall(function()C=rawget(_G,A)end)end local D=type(C)=='table'and rawget(C,B)or nil return type(D)=='function'and D or nil end local function getRequestFunction()return
environmentFunction('request')or environmentFunction('http_request')or nestedEnvironmentFunction('syn','request')or nestedEnvironmentFunction('fluxus','request')or nestedEnvironmentFunction('http',
'request')end local function postKeyServer(A)if not v then return false,0,nil,'server_not_configured'end local B,C=pcall(function()return s:JSONEncode(A)end)if not B then return false,0,nil,
'invalid_request'end local D={Url=u..'/v1/nothrilo/key/verify',Method='POST',Headers={['Content-Type']='application/json',['Accept']='application/json'},Body=C}local E=getRequestFunction()local F,G if
E then F,G=pcall(E,D)else F,G=pcall(function()return s:RequestAsync(D)end)end if not F then return false,0,nil,'network_error'end local H=0 local I if type(G)=='table'then H=tonumber(G.StatusCode or G
.Status or G.status_code)or 0 I=G.Body or G.body if H==0 and G.Success==true then H=200 end elseif type(G)=='string'then H=200 I=G end if type(I)~='string'or I==''then return false,H,nil,
'invalid_response'end local J,K=pcall(function()return s:JSONDecode(I)end)if not J or type(K)~='table'then return false,H,nil,'invalid_response'end return H>=200 and H<300,H,K,K.error end local 
function validLease(A)return type(A)=='string'and#A==71 and A:match('^NLEASE%-%x+$')~=nil end local function clearKeyCache()pcall(function()i[y]=nil end)local A=environmentFunction('delfile')if A then
pcall(A,w)end end local function decodeCache(A)if type(A)=='table'then return A end if type(A)~='string'or A==''then return nil end local B,C=pcall(function()return s:JSONDecode(A)end)return B and
type(C)=='table'and C or nil end local function validateCachedRecord(A)if type(A)~='table'then return nil end local B=os.time()local C=tonumber(A.savedAt)local D=tonumber(A.expiresAt)if A.version~=1
or A.product~='nothrilo'or tostring(A.userId or'')~=tostring(f.UserId)or not validLease(A.lease)or not C or not D or C>B+300 or D<=B+5 or D-C>z+60 then return nil end return A end local function 
readKeyCache()local A=environmentFunction('isfile')local B=environmentFunction('readfile')if B then local C=true if A then local D,E=pcall(A,w)C=D and E==true end if C then local D,E=pcall(B,w)if D
then local F=validateCachedRecord(decodeCache(E))if F then return F end end end end local C pcall(function()C=i[y]end)return validateCachedRecord(decodeCache(C))end local function saveKeyCache(A,B)if
not validLease(A)then return end local C=math.floor(math.clamp(tonumber(B)or 0,1,z))if C<=5 then return end local D=os.time()local E={version=1,product='nothrilo',userId=tostring(f.UserId),lease=A,
savedAt=D,expiresAt=D+C}pcall(function()i[y]=E end)local F=environmentFunction('writefile')if not F then return end local G,H=pcall(function()return s:JSONEncode(E)end)if not G then return end local I
=environmentFunction('makefolder')if I then pcall(I,x)end pcall(F,w,H)end local A=false local B=false local C={}local D=0 local E={}local function gateAlive()return not n and isCurrentSuiteGeneration(
)and t and t.Parent~=nil and E~=nil end local function connect(F,G)local H=F:Connect(G)table.insert(C,H)return H end local F=Instance.new('ScreenGui')F.Name='NothriloKeyGate'F.ResetOnSpawn=false F.
IgnoreGuiInset=true F.DisplayOrder=10100 F.ZIndexBehavior=Enum.ZIndexBehavior.Sibling F.Parent=k t=F local G=Instance.new('Frame')G.Name='Shade'G.Size=UDim2.fromScale(1,1)G.BackgroundColor3=Color3.
fromRGB(3,3,5)G.BackgroundTransparency=0.06 G.BorderSizePixel=0 G.Parent=F local H=Instance.new('Frame')H.Name='Card'H.AnchorPoint=Vector2.new(0.5,0.5)H.Position=UDim2.fromScale(0.5,0.5)H.
BackgroundColor3=r.Background H.BorderSizePixel=0 H.ClipsDescendants=true H.Parent=G local I=Instance.new('UICorner')I.CornerRadius=UDim.new(0,22)I.Parent=H local J=Instance.new('UIStroke')J.Thickness
=2 J.Color=r.SchemeColor J.Parent=H local K=Instance.new('Frame')K.Name='Header'K.Size=UDim2.new(1,0,0,68)K.BackgroundColor3=r.Header K.BorderSizePixel=0 K.Parent=H local L=Instance.new('Frame')L.
AnchorPoint=Vector2.new(0,0.5)L.Position=UDim2.new(0,18,0.5,0)L.Size=UDim2.fromOffset(13,13)L.BackgroundColor3=r.SchemeColor L.BorderSizePixel=0 L.Parent=K Instance.new('UICorner',L).CornerRadius=UDim
.new(1,0)local M=Instance.new('TextLabel')M.Position=UDim2.new(0,42,0,8)M.Size=UDim2.new(1,-96,0,27)M.BackgroundTransparency=1 M.Font=Enum.Font.GothamBold M.Text='Nothrilo \u{2022} Key gr\u{e1}tis'M.
TextColor3=r.TextColor M.TextSize=19 M.TextXAlignment=Enum.TextXAlignment.Left M.Parent=K local N=Instance.new('TextLabel')N.Position=UDim2.new(0,42,0,36)N.Size=UDim2.new(1,-96,0,20)N.
BackgroundTransparency=1 N.Font=Enum.Font.Gotham N.Text='1 an\u{fa}ncio \u{2022} menu completo por 24 horas'N.TextColor3=Color3.fromRGB(214,214,224)N.TextSize=13 N.TextXAlignment=Enum.TextXAlignment.
Left N.Parent=K local O=Instance.new('TextButton')O.Name='Close'O.AnchorPoint=Vector2.new(1,0.5)O.Position=UDim2.new(1,-10,0.5,0)O.Size=UDim2.fromOffset(46,46)O.BackgroundColor3=Color3.fromRGB(24,24,
30)O.BorderSizePixel=0 O.AutoButtonColor=true O.Font=Enum.Font.GothamBold O.Text='\u{d7}'O.TextColor3=r.TextColor O.TextSize=23 O.Parent=K Instance.new('UICorner',O).CornerRadius=UDim.new(0,13)local P
=Instance.new('ScrollingFrame')P.Name='Content'P.Position=UDim2.fromOffset(0,68)P.Size=UDim2.new(1,0,1,-68)P.BackgroundTransparency=1 P.BorderSizePixel=0 P.ScrollBarThickness=5 P.ScrollBarImageColor3=
r.SchemeColor P.ScrollingDirection=Enum.ScrollingDirection.Y P.AutomaticCanvasSize=Enum.AutomaticSize.Y P.CanvasSize=UDim2.new()P.Parent=H local Q=Instance.new('UIPadding')Q.PaddingLeft=UDim.new(0,18)
Q.PaddingRight=UDim.new(0,18)Q.PaddingTop=UDim.new(0,14)Q.PaddingBottom=UDim.new(0,16)Q.Parent=P local R=Instance.new('UIListLayout')R.FillDirection=Enum.FillDirection.Vertical R.HorizontalAlignment=
Enum.HorizontalAlignment.Center R.SortOrder=Enum.SortOrder.LayoutOrder R.Padding=UDim.new(0,10)R.Parent=P local function label(S,T,U,V,W)local X=Instance.new('TextLabel')X.Size=UDim2.new(1,0,0,T)X.
BackgroundTransparency=1 X.Font=U or Enum.Font.Gotham X.Text=S X.TextColor3=W or r.TextColor X.TextSize=V or 13 X.TextWrapped=true X.TextXAlignment=Enum.TextXAlignment.Left X.TextYAlignment=Enum.
TextYAlignment.Center X.Parent=P return X end local S=label(
'Escolha uma op\u{e7}\u{e3}o, conclua as etapas no navegador e cole a key aqui. Work.ink, LootLabs e Linkvertise liberam exatamente as mesmas fun\u{e7}\u{f5}es.',58,Enum.Font.GothamMedium,15,Color3.
fromRGB(238,238,244))S.LayoutOrder=1 local T=label('ESCOLHA ONDE PEGAR A KEY',22,Enum.Font.GothamBold,13,Color3.fromRGB(218,218,228))T.LayoutOrder=2 local U=Instance.new('Frame')U.Size=UDim2.new(1,0,0
,54)U.BackgroundTransparency=1 U.LayoutOrder=3 U.Parent=P local V=Instance.new('UIListLayout')V.FillDirection=Enum.FillDirection.Horizontal V.HorizontalAlignment=Enum.HorizontalAlignment.Center V.
VerticalAlignment=Enum.VerticalAlignment.Center V.Padding=UDim.new(0,8)V.Parent=U local W=Instance.new('TextBox')W.Name='KeyLink'W.Size=UDim2.new(1,0,0,46)W.BackgroundColor3=r.ElementColor W.
BorderSizePixel=0 W.ClearTextOnFocus=false W.Font=Enum.Font.Code W.PlaceholderText='O link escolhido aparece aqui'W.PlaceholderColor3=Color3.fromRGB(188,188,201)W.Text=''W.TextColor3=Color3.fromRGB(
240,240,246)W.TextSize=13 W.TextTruncate=Enum.TextTruncate.AtEnd W.TextXAlignment=Enum.TextXAlignment.Left W.LayoutOrder=4 W.Parent=P Instance.new('UICorner',W).CornerRadius=UDim.new(0,11)local X=
Instance.new('UIPadding')X.PaddingLeft=UDim.new(0,12)X.PaddingRight=UDim.new(0,12)X.Parent=W local Y=Instance.new('UIStroke')Y.Color=Color3.fromRGB(62,62,76)Y.Thickness=1 Y.Parent=W local Z=Instance.
new('TextBox')Z.Name='KeyInput'Z.Size=UDim2.new(1,0,0,52)Z.BackgroundColor3=r.ElementColor Z.BorderSizePixel=0 Z.ClearTextOnFocus=false Z.Font=Enum.Font.RobotoMono Z.PlaceholderText=
'Cole sua key: NOTH-XXXX-XXXX-XXXX-XXXX-XXXX'Z.PlaceholderColor3=Color3.fromRGB(195,195,208)Z.Text=''Z.TextColor3=r.TextColor Z.TextSize=15 Z.TextXAlignment=Enum.TextXAlignment.Left Z.LayoutOrder=5 Z.
Parent=P Instance.new('UICorner',Z).CornerRadius=UDim.new(0,12)local _=Instance.new('UIPadding')_.PaddingLeft=UDim.new(0,14)_.PaddingRight=UDim.new(0,14)_.Parent=Z local aa=Instance.new('UIStroke')aa.
Color=Color3.fromRGB(72,72,88)aa.Thickness=1 aa.Parent=Z local ab=Instance.new('TextButton')ab.Name='Verify'ab.Size=UDim2.new(1,0,0,52)ab.BackgroundColor3=r.SchemeColor ab.BorderSizePixel=0 ab.
AutoButtonColor=true ab.Font=Enum.Font.GothamBold ab.Text='VALIDAR E ABRIR O NOTHRILO'ab.TextColor3=Color3.fromRGB(8,8,10)ab.TextSize=14 ab.LayoutOrder=6 ab.Parent=P Instance.new('UICorner',ab).
CornerRadius=UDim.new(0,13)local ac=Instance.new('Frame')ac.Size=UDim2.new(1,0,0,62)ac.BackgroundColor3=Color3.fromRGB(15,15,20)ac.BorderSizePixel=0 ac.LayoutOrder=7 ac.Parent=P Instance.new(
'UICorner',ac).CornerRadius=UDim.new(0,12)local ad=Instance.new('Frame')ad.AnchorPoint=Vector2.new(0,0.5)ad.Position=UDim2.new(0,13,0.5,0)ad.Size=UDim2.fromOffset(10,10)ad.BackgroundColor3=r.
SchemeColor ad.BorderSizePixel=0 ad.Parent=ac Instance.new('UICorner',ad).CornerRadius=UDim.new(1,0)local ae=Instance.new('TextLabel')ae.Position=UDim2.new(0,35,0,6)ae.Size=UDim2.new(1,-48,1,-12)ae.
BackgroundTransparency=1 ae.Font=Enum.Font.Gotham ae.Text=v and'Escolha uma op\u{e7}\u{e3}o para gerar sua key gr\u{e1}tis.'or'O servidor de keys ainda n\u{e3}o foi conectado nesta build.'ae.
TextColor3=Color3.fromRGB(232,232,240)ae.TextSize=14 ae.TextWrapped=true ae.TextXAlignment=Enum.TextXAlignment.Left ae.TextYAlignment=Enum.TextYAlignment.Center ae.Parent=ac local af=label(
'\u{1f510} Todas as fun\u{e7}\u{f5}es s\u{e3}o gr\u{e1}tis ap\u{f3}s a key. Nenhuma senha \u{e9} pedida.',42,Enum.Font.GothamMedium,13,Color3.fromRGB(205,205,216))af.LayoutOrder=8 local ag={}local ah=
{{id='workink',text='Work.ink'},{id='lootlabs',text='LootLabs'},{id='linkvertise',text='Linkvertise'}}local function setStatus(ai,aj)ae.Text=ai if aj=='good'then ae.TextColor3=Color3.fromRGB(116,255,
158)elseif aj=='bad'then ae.TextColor3=Color3.fromRGB(255,116,148)else ae.TextColor3=Color3.fromRGB(232,232,240)end end local function copyText(ai)for aj,ak in ipairs({'setclipboard','toclipboard'})do
local al=environmentFunction(ak)if al then local am=pcall(al,ai)if am then return true end end end return false end for ai,aj in ipairs(ah)do local ak=Instance.new('TextButton')ak.Name=aj.id ak.Size=
UDim2.new(1/3,-6,1,0)ak.BackgroundColor3=Color3.fromRGB(24,24,31)ak.BorderSizePixel=0 ak.AutoButtonColor=true ak.Font=Enum.Font.GothamBold ak.Text=aj.text ak.TextColor3=r.TextColor ak.TextSize=14 ak.
Parent=U Instance.new('UICorner',ak).CornerRadius=UDim.new(0,12)local al=Instance.new('UIStroke')al.Color=r.SchemeColor al.Transparency=0.18 al.Thickness=1 al.Parent=ak table.insert(ag,al)connect(ak.
Activated,function()if not gateAlive()then return end if not v then setStatus('O servidor ainda n\u{e3}o foi publicado. Esta build \u{e9} apenas de prepara\u{e7}\u{e3}o.','bad')return end local am=u..
'/v1/nothrilo/key/start?provider='..s:UrlEncode(aj.id)..'&userId='..s:UrlEncode(tostring(f.UserId))W.Text=am if copyText(am)then setStatus('Link do '..aj.text..
' copiado. Cole no navegador, conclua e volte com a key.','good')else setStatus([[Copie o link do campo acima, abra no navegador, conclua e volte com a key.]],nil)pcall(function()W:CaptureFocus()W.
CursorPosition=#W.Text+1 W.SelectionStart=1 end)end end)end local function setBusy(ai)ab.Active=not ai ab.AutoButtonColor=not ai ab.Text=ai and'VERIFICANDO...'or'VALIDAR E ABRIR O NOTHRILO'ab.
BackgroundTransparency=ai and 0.35 or 0 pcall(function()Z.TextEditable=not ai end)end local function friendlyError(ai,aj)if ai=='server_not_configured'then return
'O servidor de keys ainda n\u{e3}o foi conectado nesta build.'end if ai=='network_error'then return'N\u{e3}o consegui falar com o servidor. Confira a internet e tente novamente.'end if ai==
'invalid_key'or ai=='invalid_lease'or aj==401 or aj==403 then return'Key inv\u{e1}lida, expirada ou criada para outro usu\u{e1}rio.'end if aj==429 then return
'Muitas tentativas. Aguarde um pouco e tente novamente.'end return[[O servidor respondeu de um jeito inesperado. Tente novamente em instantes.]]end local function beginVerification(ai,aj,ak)if not
gateAlive()then return end aj=tostring(aj or''):match('^%s*(.-)%s*$')if ai=='key'then aj=aj:upper()end if(ai=='key'and not aj:match('^NOTH%-%w%w%w%w%-%w%w%w%w%-%w%w%w%w%-%w%w%w%w%-%w%w%w%w$'))or(ai==
'lease'and not validLease(aj))then if ak then clearKeyCache()else setStatus('Cole uma key Nothrilo completa antes de validar.','bad')end return end D+=1 local al=D setBusy(true)setStatus(ak and
'Verificando seu acesso salvo...'or'Validando sua key com seguran\u{e7}a...',nil)task.delay(20,function()if gateAlive()and D==al and not A then D+=1 setBusy(false)setStatus(
'A verifica\u{e7}\u{e3}o demorou demais. Tente novamente.','bad')end end)task.spawn(function()local am=tostring(os.clock())pcall(function()am=s:GenerateGUID(false)end)local an={product='nothrilo',
clientVersion='free-key-v1',userId=tostring(f.UserId),placeId=tostring(game.PlaceId),nonce=am}an[ai]=aj local ao,ap,aq,ar=postKeyServer(an)if not gateAlive()or D~=al or A then return end if ao and
type(aq)=='table'and aq.ok==true and validLease(aq.lease)and tonumber(aq.ttlSeconds)and tonumber(aq.ttlSeconds)>5 then local as=math.floor(math.clamp(tonumber(aq.ttlSeconds),1,z))saveKeyCache(aq.lease
,as)local at=os.clock()+as task.spawn(function()while not n and isCurrentSuiteGeneration()do local au=at-os.clock()if au<=0 then break end task.wait(math.max(0.25,math.min(30,au)))end if n or not
isCurrentSuiteGeneration()or os.clock()<at then return end clearKeyCache()if m then m()else n=true if q and q.Parent then q:Destroy()end end end)setStatus(
'Acesso liberado! Abrindo o Nothrilo completo...','good')task.wait(0.45)if gateAlive()and D==al then B=true A=true end return end if ak then clearKeyCache()end setBusy(false)setStatus(friendlyError(ar
or(aq and aq.error),ap),'bad')end)end connect(ab.Activated,function()beginVerification('key',Z.Text,false)end)connect(Z.FocusLost,function(ai)if ai then beginVerification('key',Z.Text,false)end end)
connect(O.Activated,function()D+=1 A=true B=false end)local ai=Vector2.new()local function resizeGate()local aj=workspace.CurrentCamera local ak=aj and aj.ViewportSize or Vector2.new(800,600)if ak==ai
then return end ai=ak local al=math.max(284,math.min(600,ak.X-16))local am=math.max(350,math.min(550,ak.Y-16))H.Size=UDim2.fromOffset(al,am)local an=al<390 M.TextSize=an and 17 or 19 N.TextSize=an and
12 or 13 S.TextSize=an and 14 or 15 T.TextSize=an and 12 or 13 W.TextSize=an and 12 or 13 Z.TextSize=an and 13 or 15 ab.TextSize=an and 13 or 14 ae.TextSize=an and 13 or 14 af.TextSize=an and 12 or 13
for ao,ap in ipairs(ag)do ap.Parent.TextSize=an and 12 or 14 end end resizeGate()task.spawn(function()while gateAlive()and not A do resizeGate()local aj=Color3.fromHSV((os.clock()*0.075)%1,0.86,1)J.
Color=aj L.BackgroundColor3=aj ab.BackgroundColor3=aj P.ScrollBarImageColor3=aj ad.BackgroundColor3=aj for ak,al in ipairs(ag)do al.Color=aj end task.wait(0.08)end end)local aj=readKeyCache()if aj
then beginVerification('lease',aj.lease,true)elseif v then setStatus('Escolha uma op\u{e7}\u{e3}o para gerar sua key gr\u{e1}tis.',nil)end repeat task.wait(0.05)until A or not gateAlive()D+=1 E=nil
for ak=#C,1,-1 do pcall(function()C[ak]:Disconnect()end)C[ak]=nil end if t and t.Parent then pcall(function()t:Destroy()end)end t=nil return B and not n and isCurrentSuiteGeneration()end if not
runFreeKeyGate()then n=true for aa=#o,1,-1 do pcall(function()o[aa]:Disconnect()end)o[aa]=nil end if q and q.Parent then q:Destroy()end return end end local aa={seconds=5,beganAt=os.clock()}aa.gui,aa.
status,aa.progress=(function()local ab=Instance.new('ScreenGui')ab.Name='NothriloLoading'ab.ResetOnSpawn=false ab.IgnoreGuiInset=true ab.DisplayOrder=10050 ab.ZIndexBehavior=Enum.ZIndexBehavior.
Sibling ab.Parent=k local ac=Instance.new('Frame')ac.Name='Shade'ac.Size=UDim2.fromScale(1,1)ac.BackgroundColor3=Color3.fromRGB(3,3,5)ac.BackgroundTransparency=0.08 ac.BorderSizePixel=0 ac.Parent=ab
local ad=Instance.new('Frame')ad.Name='Shadow'ad.AnchorPoint=Vector2.new(0.5,0.5)ad.Position=UDim2.new(0.5,0,0.5,6)ad.Size=UDim2.fromOffset(344,500)ad.BackgroundColor3=Color3.fromRGB(0,0,0)ad.
BackgroundTransparency=0.38 ad.BorderSizePixel=0 ad.Parent=ac Instance.new('UICorner',ad).CornerRadius=UDim.new(0,24)local ae=Instance.new('Frame')ae.Name='Card'ae.AnchorPoint=Vector2.new(0.5,0.5)ae.
Position=UDim2.fromScale(0.5,0.5)ae.Size=UDim2.fromOffset(344,500)ae.BackgroundColor3=Color3.fromRGB(10,10,14)ae.BorderSizePixel=0 ae.ClipsDescendants=true ae.Parent=ac local af=Instance.new(
'UICorner')af.CornerRadius=UDim.new(0,24)af.Parent=ae local ag=Instance.new('UIStroke')ag.Thickness=2 ag.Color=r.SchemeColor ag.Parent=ae ag.Transparency=0.06 local ah=Instance.new('Frame')ah.Name=
'MediaPanel'ah.Position=UDim2.fromOffset(14,14)ah.Size=UDim2.new(1,-28,1,-142)ah.BackgroundColor3=Color3.fromRGB(17,17,23)ah.BorderSizePixel=0 ah.ClipsDescendants=true ah.Parent=ae Instance.new(
'UICorner',ah).CornerRadius=UDim.new(0,18)local ai=Instance.new('UIStroke')ai.Thickness=1 ai.Transparency=0.55 ai.Color=r.SchemeColor ai.Parent=ah local aj=Instance.new('VideoFrame')aj.Name='CatVideo'
aj.Size=UDim2.fromScale(1,1)aj.BackgroundColor3=Color3.fromRGB(12,12,17)aj.BorderSizePixel=0 aj.Looped=true aj.Volume=0 aj.Visible=false aj.ZIndex=1 aj.Parent=ah local ak=Instance.new('Frame')ak.Name=
'EmojiFallback'ak.Size=UDim2.fromScale(1,1)ak.BackgroundColor3=Color3.fromRGB(17,17,23)ak.BorderSizePixel=0 ak.ZIndex=2 ak.Parent=ah local al=Instance.new('TextLabel')al.AnchorPoint=Vector2.new(0.5,
0.5)al.Position=UDim2.fromScale(0.5,0.42)al.Size=UDim2.new(1,-30,0,44)al.BackgroundTransparency=1 al.Font=Enum.Font.GothamBold al.Text='preparando a bagun\u{e7}a...'al.TextColor3=Color3.fromRGB(244,
244,248)al.TextSize=17 al.TextWrapped=true al.ZIndex=3 al.Parent=ak local am=Instance.new('Frame')am.Name='BrandDot'am.Position=UDim2.new(0,18,1,-110)am.Size=UDim2.fromOffset(18,18)am.BackgroundColor3
=r.SchemeColor am.BorderSizePixel=0 am.Parent=ae Instance.new('UICorner',am).CornerRadius=UDim.new(1,0)local an=Instance.new('TextLabel')an.BackgroundTransparency=1 an.Position=UDim2.new(0,46,1,-122)
an.Size=UDim2.new(1,-64,0,26)an.Font=Enum.Font.GothamBold an.Text=g an.TextColor3=Color3.fromRGB(248,248,250)an.TextSize=18 an.TextXAlignment=Enum.TextXAlignment.Left an.Parent=ae local ao=Instance.
new('TextLabel')ao.BackgroundTransparency=1 ao.Position=UDim2.new(0,18,1,-90)ao.Size=UDim2.new(1,-36,0,17)ao.Font=Enum.Font.Gotham ao.Text='Feito por Cafezl  \u{2022}  preparando tudo'ao.TextColor3=
Color3.fromRGB(205,205,214)ao.TextSize=12 ao.TextXAlignment=Enum.TextXAlignment.Left ao.Parent=ae local ap={}local aq={'\u{1f431}','\u{1f638}','\u{2728}','\u{2615}','\u{26a1}','\u{1f3ae}'}for ar,as in
ipairs(aq)do local at=Instance.new('TextLabel')at.Name='Emoji'..ar at.AnchorPoint=Vector2.new(0.5,0.5)local au=(ar-1)%3 local s=math.floor((ar-1)/3)at.Position=UDim2.new(0.23+au*0.27,0,0.58+s*0.15,0)
at.Size=UDim2.fromOffset(52,52)at.BackgroundTransparency=1 at.Font=Enum.Font.GothamBold at.Text=as at.TextColor3=Color3.fromRGB(255,255,255)at.TextSize=30 at.ZIndex=3 at.Parent=ak table.insert(ap,at)
end local ar=Instance.new('Frame')ar.Name='StatusDot'ar.AnchorPoint=Vector2.new(0.5,0.5)ar.Position=UDim2.new(0,22,1,-52)ar.Size=UDim2.fromOffset(8,8)ar.BackgroundColor3=r.SchemeColor ar.
BorderSizePixel=0 ar.Parent=ae Instance.new('UICorner',ar).CornerRadius=UDim.new(1,0)local as=Instance.new('TextLabel')as.BackgroundTransparency=1 as.Position=UDim2.new(0,34,1,-63)as.Size=UDim2.new(1,
-100,0,22)as.Font=Enum.Font.Gotham as.Text='Preparando interface...'as.TextColor3=r.SchemeColor as.TextSize=12 as.TextXAlignment=Enum.TextXAlignment.Left as.Parent=ae local at=Instance.new('TextLabel'
)at.Name='Percent'at.BackgroundTransparency=1 at.Position=UDim2.new(1,-68,1,-63)at.Size=UDim2.fromOffset(50,22)at.Font=Enum.Font.GothamSemibold at.Text='0%'at.TextColor3=r.SchemeColor at.TextSize=12
at.TextXAlignment=Enum.TextXAlignment.Right at.Parent=ae local au=Instance.new('Frame')au.Name='ProgressTrack'au.Position=UDim2.new(0,18,1,-24)au.Size=UDim2.new(1,-36,0,8)au.BackgroundColor3=Color3.
fromRGB(34,34,42)au.BorderSizePixel=0 au.Parent=ae Instance.new('UICorner',au).CornerRadius=UDim.new(1,0)local s=Instance.new('Frame')s.Name='Progress's.Size=UDim2.fromScale(0,1)s.BackgroundColor3=r.
SchemeColor s.BorderSizePixel=0 s.Parent=au Instance.new('UICorner',s).CornerRadius=UDim.new(1,0)local t='Nothrilo/loader-cat-v1.mp4'local u=tostring(i.NothriloLoaderVideoUrl or
[[https://raw.githubusercontent.com/cafezl/cart-ride-nothing-around/main/assets/nothrilo-loader.mp4]])local function loaderFunction(v)local w pcall(function()w=rawget(i,v)end)if type(w)=='function'
then return w end pcall(function()w=rawget(_G,v)end)return type(w)=='function'and w or nil end local function nestedLoaderFunction(v,w)local x pcall(function()x=rawget(i,v)end)if type(x)~='table'then
pcall(function()x=rawget(_G,v)end)end local y=type(x)=='table'and rawget(x,w)or nil return type(y)=='function'and y or nil end local function loaderAlive()return ab.Parent~=nil and not n and
isCurrentSuiteGeneration()and os.clock()<aa.beganAt+aa.seconds end local function showLoadedVideo()if not loaderAlive()then return end local v,w=pcall(function()return aj.IsLoaded end)if v and w then
pcall(function()aj.Visible=true aj.TimePosition=0 aj:Play()ak.Visible=false end)end end aj.Loaded:Connect(showLoadedVideo)local v=loaderFunction('getcustomasset')or loaderFunction('getsynasset')local
w=loaderFunction('writefile')local x=loaderFunction('readfile')local y=loaderFunction('isfile')local z=loaderFunction('makefolder')local A=loaderFunction('delfile')local B=loaderFunction('request')or
loaderFunction('http_request')or nestedLoaderFunction('syn','request')or nestedLoaderFunction('fluxus','request')or nestedLoaderFunction('http','request')local function validMp4(C)return type(C)==
'string'and#C>=4096 and#C<=12*1024*1024 and C:sub(5,8)=='ftyp'end local function attachVideoFile()if not v or not loaderAlive()then return false end local C,D=pcall(v,t)if not C or type(D)~='string'or
D==''then return false end local E=pcall(function()aj.Video=D end)if E then task.defer(showLoadedVideo)end return E end local function downloadVideo()if B then local C,D=pcall(B,{Url=u,Method='GET'})
if C and type(D)=='table'then local E=tonumber(D.StatusCode or D.Status or D.status_code)or 0 local F=D.Body or D.body if E>=200 and E<300 then return F end elseif C and type(D)=='string'then return D
end end local C,D=pcall(function()return game:HttpGet(u,true)end)return C and D or nil end task.spawn(function()if not v then return end local C=false if y then local D,E=pcall(y,t)C=D and E==true end
if C and x then local D,E=pcall(x,t)if not D or not validMp4(E)then C=false if A then pcall(A,t)end end end if C and attachVideoFile()then return end if not w or not u:match('^https://')then return
end local D=downloadVideo()if not validMp4(D)then return end if z then pcall(z,'Nothrilo')end local E=pcall(w,t,D)if E and loaderAlive()then attachVideoFile()end end)local C=Vector2.new()local 
function resizeLoader()local D=workspace.CurrentCamera local E=D and D.ViewportSize or Vector2.new(800,600)if E==C then return end C=E local F=math.max(276,math.min(356,E.X-24))local G=math.max(330,
math.min(552,E.Y-24))ae.Size=UDim2.fromOffset(F,G)ad.Size=UDim2.fromOffset(F,G)end resizeLoader()task.spawn(function()local D=as.Text while ab.Parent do resizeLoader()local E=os.clock()-aa.beganAt
local F=math.clamp(E/aa.seconds,0,1)s.Size=UDim2.fromScale(F,1)local G=Color3.fromHSV((E*0.2)%1,0.84,1)s.BackgroundColor3=G ag.Color=G ai.Color=G am.BackgroundColor3=G ar.BackgroundColor3=G as.
TextColor3=G at.TextColor3=G at.Text=('%d%%'):format(math.floor(F*100))local H if F<0.24 then H='Preparando interface...'elseif F<0.5 then H='Carregando fun\u{e7}\u{f5}es...'elseif F<0.76 then H=
'Organizando atalhos...'elseif F<0.98 then H='Aplicando acabamento...'else H='Tudo pronto!'end if as.Text==D then D=H as.Text=D end for I,J in ipairs(ap)do local K=E*5.2+I*0.78 local L=(I-1)%3 local M
=math.floor((I-1)/3)J.Position=UDim2.new(0.23+L*0.27,0,0.58+M*0.15,math.floor(math.sin(K)*5))J.Rotation=math.sin(K*0.82)*7 J.TextSize=30+math.floor((math.sin(K)+1)*1.5)end b.RenderStepped:Wait()end
end)return ab,as,s end)()local ab=(function()local ab={gui=nil,theme=r,themeBindings={}}local function classicCreate(ac,ad,ae)local af=Instance.new(ac)for ag,ah in pairs(ad or{})do af[ag]=ah end af.
Parent=ae return af end local function classicCorner(ac,ad)return classicCreate('UICorner',{CornerRadius=UDim.new(0,ad or 4)},ac)end local function classicBindTheme(ac,ad,ae)table.insert(ab.
themeBindings,{object=ac,property=ad,themeKey=ae})ac[ad]=ab.theme[ae]return ac end local function classicInvoke(ac,ad,...)if not ad then return end local ae=table.pack(...)local af,ag=xpcall(function(
)ad(table.unpack(ae,1,ae.n))end,function(af)if debug and type(debug.traceback)=='function'then return debug.traceback(tostring(af),2)end return tostring(af)end)if not af then warn(('[%s/%s] %s'):
format(g,ac,tostring(ag)))end end function ab:ChangeColor(ac,ad)if not self.theme[ac]then return end self.theme[ac]=ad for ae=#self.themeBindings,1,-1 do local af=self.themeBindings[ae]if not af.
object or not af.object.Parent then table.remove(self.themeBindings,ae)elseif af.themeKey==ac then af.object[af.property]=ad end end end function ab:ToggleUI()if self.gui and self.gui.Parent then self
.gui.Enabled=not self.gui.Enabled end end function ab.CreateLib(ac,ad)ab.theme=ad or r table.clear(ab.themeBindings)local ae=classicCreate('ScreenGui',{Name='NothriloClassicUI',Enabled=false,
ResetOnSpawn=false,IgnoreGuiInset=true,DisplayOrder=10000,ZIndexBehavior=Enum.ZIndexBehavior.Sibling},k)ab.gui=ae local af=classicCreate('Frame',{Name='Main',AnchorPoint=Vector2.new(0.5,0.5),Position=
UDim2.fromScale(0.5,0.5),Size=UDim2.fromOffset(525,318),BackgroundColor3=ab.theme.Background,BorderSizePixel=0,ClipsDescendants=true},ae)classicCorner(af,18)local ag=classicCreate('Frame',{Name=
'MainHeader',Size=UDim2.new(1,0,0,34),BackgroundColor3=ab.theme.Header,BorderSizePixel=0},af)classicCorner(ag,18)local ah=classicCreate('Frame',{Name='SquareBottom',Position=UDim2.new(0,0,1,-18),Size=
UDim2.new(1,0,0,18),BackgroundColor3=ab.theme.Header,BorderSizePixel=0},ag)classicBindTheme(ah,'BackgroundColor3','Header')local ai=classicCreate('TextLabel',{Name='title',Position=UDim2.fromOffset(12
,0),Size=UDim2.new(1,-46,1,0),BackgroundTransparency=1,Font=Enum.Font.GothamSemibold,Text=ac,TextColor3=ab.theme.TextColor,TextSize=16,TextTruncate=Enum.TextTruncate.AtEnd,TextXAlignment=Enum.
TextXAlignment.Left,RichText=true},ag)classicBindTheme(ai,'TextColor3','TextColor')local aj=classicCreate('TextButton',{Name='close',Position=UDim2.new(1,-34,0,0),Size=UDim2.fromOffset(34,34),
BackgroundTransparency=1,Text='\u{d7}',Font=Enum.Font.GothamBold,TextColor3=ab.theme.TextColor,TextSize=20},ag)aj.Activated:Connect(function()if m then m()elseif ae.Parent then ae:Destroy()end end)
local ak=classicCreate('Frame',{Name='MainSide',Position=UDim2.fromOffset(0,34),Size=UDim2.new(0,145,1,-34),BackgroundColor3=ab.theme.Header,BorderSizePixel=0},af)classicCorner(ak,18)local al=
classicCreate('Frame',{Name='SquareTop',Size=UDim2.new(1,0,0,18),BackgroundColor3=ab.theme.Header,BorderSizePixel=0},ak)classicBindTheme(al,'BackgroundColor3','Header')local am=classicCreate('Frame',{
Name='SquareRight',Position=UDim2.new(1,-18,0,0),Size=UDim2.new(0,18,1,0),BackgroundColor3=ab.theme.Header,BorderSizePixel=0},ak)classicBindTheme(am,'BackgroundColor3','Header')local an=classicCreate(
'ScrollingFrame',{Name='tabFrames',Position=UDim2.fromOffset(6,3),Size=UDim2.new(0,133,1,-6),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=0,AutomaticCanvasSize=Enum.AutomaticSize.Y,
CanvasSize=UDim2.new(),ScrollingDirection=Enum.ScrollingDirection.Y},ak)classicBindTheme(an,'ScrollBarImageColor3','SchemeColor')classicCreate('UIListLayout',{Name='tabListing',Padding=UDim.new(0,2),
SortOrder=Enum.SortOrder.LayoutOrder},an)local ao=classicCreate('Frame',{Name='pages',Position=UDim2.fromOffset(153,42),Size=UDim2.fromOffset(364,268),BackgroundColor3=ab.theme.Background,
BorderSizePixel=0},af)local ap=classicCreate('Folder',{Name='Pages'},ao)local aq=classicCreate('TextLabel',{Name='infoContainer',Position=UDim2.fromOffset(153,268),Size=UDim2.fromOffset(364,42),
BackgroundColor3=ab.theme.ElementColor,BorderSizePixel=0,Font=Enum.Font.GothamSemibold,Text='',TextColor3=ab.theme.TextColor,TextSize=12,TextWrapped=true,TextTruncate=Enum.TextTruncate.AtEnd,
TextXAlignment=Enum.TextXAlignment.Left,Visible=false,ZIndex=60},af)classicCorner(aq,12)classicCreate('UIPadding',{PaddingLeft=UDim.new(0,10),PaddingRight=UDim.new(0,10)},aq)classicBindTheme(aq,
'BackgroundColor3','ElementColor')classicBindTheme(aq,'TextColor3','TextColor')local ar=classicCreate('UIStroke',{Thickness=1,Transparency=0.1},aq)classicBindTheme(ar,'Color','SchemeColor')local as=0
local function showHint(at,au)if not au or au==''then return end as=as+1 local s=as aq.Text=tostring(at)..'  \u{2022}  '..tostring(au)aq.Visible=true task.delay(4,function()if s==as and aq.Parent then
aq.Visible=false end end)end local at local au={}local function updateResponsiveLayout()local s=workspace.CurrentCamera local t=s and s.ViewportSize or Vector2.new(1280,720)local u=math.clamp(t.X-16,
300,525)local v=math.clamp(t.Y-16,260,318)local w=u<420 and 96 or 145 local x=w+8 local y=42 af.Size=UDim2.fromOffset(u,v)ak.Position=UDim2.fromOffset(0,34)ak.Size=UDim2.new(0,w,1,-34)an.Size=UDim2.
new(1,-12,1,-6)ao.Position=UDim2.fromOffset(x,y)ao.Size=UDim2.new(1,-(x+8),1,-(y+8))aq.Position=UDim2.fromOffset(x,v-50)aq.Size=UDim2.new(1,-(x+8),0,42)local z=u<420 for A,B in ipairs(au)do B(z)end
end local function bindViewportCamera()if at then at:Disconnect()at=nil end local s=workspace.CurrentCamera if s then at=trackConnection(s:GetPropertyChangedSignal('ViewportSize'):Connect(
updateResponsiveLayout))end updateResponsiveLayout()end bindViewportCamera()trackConnection(workspace:GetPropertyChangedSignal('CurrentCamera'):Connect(bindViewportCamera))local s={tabs={},gui=ae}
local function showTab(t)for u,v in ipairs(s.tabs)do local w=v==t v.page.Visible=w v.button.BackgroundTransparency=w and 0 or 1 v.button.Font=w and Enum.Font.GothamSemibold or Enum.Font.GothamMedium v
.button.TextColor3=w and Color3.fromRGB(7,7,9)or ab.theme.TextColor if w then v.page.CanvasPosition=Vector2.zero end end end function s:NewTab(t)local u=classicCreate('TextButton',{Name=t..'TabButton'
,Size=UDim2.new(1,0,0,26),BackgroundTransparency=1,BorderSizePixel=0,AutoButtonColor=false,Font=Enum.Font.GothamMedium,Text=t,TextColor3=ab.theme.TextColor,TextSize=13},an)classicCorner(u,10)
classicBindTheme(u,'BackgroundColor3','SchemeColor')classicBindTheme(u,'TextColor3','TextColor')local v=classicCreate('ScrollingFrame',{Name='Page',Size=UDim2.fromScale(1,1),BackgroundColor3=ab.theme.
Background,BorderSizePixel=0,ScrollBarThickness=5,AutomaticCanvasSize=Enum.AutomaticSize.Y,CanvasSize=UDim2.new(),ScrollingDirection=Enum.ScrollingDirection.Y,Visible=false},ap)classicBindTheme(v,
'ScrollBarImageColor3','SchemeColor')classicCreate('UIPadding',{PaddingLeft=UDim.new(0,4),PaddingRight=UDim.new(0,4),PaddingTop=UDim.new(0,4),PaddingBottom=UDim.new(0,50)},v)classicCreate(
'UIListLayout',{Name='pageListing',Padding=UDim.new(0,5),SortOrder=Enum.SortOrder.LayoutOrder},v)local w={button=u,page=v}table.insert(self.tabs,w)u.Activated:Connect(function()showTab(w)end)if#self.
tabs==1 then showTab(w)end function w:NewSection(x,y)local z=classicCreate('Frame',{Name='sectionFrame',Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1,
BorderSizePixel=0},v)classicCreate('UIListLayout',{Name='sectionlistoknvm',Padding=UDim.new(0,5),SortOrder=Enum.SortOrder.LayoutOrder},z)local A=classicCreate('Frame',{Name='sectionHead',Size=UDim2.
new(1,0,0,y and 0 or 33),Visible=not y,BackgroundColor3=ab.theme.SchemeColor,BorderSizePixel=0},z)classicCorner(A,12)classicBindTheme(A,'BackgroundColor3','SchemeColor')local B=classicCreate(
'TextLabel',{Name='sectionName',Position=UDim2.fromOffset(12,0),Size=UDim2.new(1,-24,1,0),BackgroundTransparency=1,Font=Enum.Font.GothamBold,Text=x,TextColor3=Color3.fromRGB(7,7,9),TextSize=14,
TextTruncate=Enum.TextTruncate.AtEnd,TextXAlignment=Enum.TextXAlignment.Left},A)table.insert(au,function(C)B.TextSize=C and 12 or 14 end)local C=classicCreate('Frame',{Name='sectionInners',Size=UDim2.
new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1,BorderSizePixel=0},z)classicCreate('UIListLayout',{Name='sectionElListing',Padding=UDim.new(0,3),SortOrder=Enum.SortOrder.
LayoutOrder},C)local D={}local function makeElement(E,F,G,H,I)local J=c.TouchEnabled and math.max(F,44)or F local K=classicCreate('TextButton',{Name=E,Size=UDim2.new(1,0,0,J),BackgroundColor3=ab.theme
.ElementColor,BorderSizePixel=0,AutoButtonColor=false,ClipsDescendants=true,Text=''},C)classicCorner(K,12)local L=classicCreate('UIStroke',{Thickness=1,Transparency=0.82,Color=Color3.fromRGB(80,80,92)
},K)local M=classicCreate('TextLabel',{Name='touch',Position=UDim2.new(0,7,0.5,-11),Size=UDim2.fromOffset(22,22),BackgroundTransparency=1,Font=Enum.Font.GothamBold,Text='\u{2022}',TextColor3=ab.theme.
SchemeColor,TextSize=17},K)classicBindTheme(M,'TextColor3','SchemeColor')local N=classicCreate('TextLabel',{Name='togName',Position=UDim2.fromOffset(34,0),Size=UDim2.new(1,-(62+(I or 0)),1,0),
BackgroundTransparency=1,Font=Enum.Font.GothamSemibold,Text=G,TextColor3=ab.theme.TextColor,TextSize=14,TextTruncate=Enum.TextTruncate.AtEnd,TextXAlignment=Enum.TextXAlignment.Left},K)
classicBindTheme(N,'TextColor3','TextColor')table.insert(au,function(O)N.TextSize=O and 13 or 14 end)local O=classicCreate('TextButton',{Name='viewInfo',Position=UDim2.new(1,-30,0,0),Size=UDim2.new(0,
30,1,0),BackgroundTransparency=1,AutoButtonColor=false,Font=Enum.Font.GothamBold,Text='i',TextColor3=ab.theme.SchemeColor,TextSize=14,Visible=H~=nil and H~='',ZIndex=4},K)classicBindTheme(O,
'TextColor3','SchemeColor')O.Activated:Connect(function()showHint(G,H)end)O.MouseEnter:Connect(function()showHint(G,H)end)K.MouseEnter:Connect(function()K.BackgroundColor3=ab.theme.ElementColor:Lerp(
Color3.new(1,1,1),0.08)end)K.MouseLeave:Connect(function()K.BackgroundColor3=ab.theme.ElementColor end)return K,N,M,O end function D:NewButton(E,F,G)local H,I,J=makeElement('buttonElement',33,E,F,0)J.
Text='\u{203a}'J.TextSize=20 H.Activated:Connect(function()classicInvoke(E,G)end)local K={}function K:UpdateButton(L)local M=H:FindFirstChild('togName')if M and L~=nil then M.Text=tostring(L)end end
return K end function D:NewToggle(E,F,G)local H,I,J=makeElement('toggleElement',33,E,F,0)J.Visible=false local K=c.TouchEnabled and 11 or 6 local L=classicCreate('Frame',{Name='toggleDisabled',
Position=UDim2.fromOffset(7,K),Size=UDim2.fromOffset(21,21),BackgroundTransparency=1,BorderSizePixel=0},H)classicCorner(L,8)local M=classicCreate('UIStroke',{Thickness=2},L)classicBindTheme(M,'Color',
'SchemeColor')local N=classicCreate('Frame',{Name='toggleEnabled',Position=UDim2.fromOffset(5,5),Size=UDim2.fromOffset(11,11),BackgroundColor3=ab.theme.SchemeColor,BorderSizePixel=0,Visible=false},L)
classicCorner(N,6)classicBindTheme(N,'BackgroundColor3','SchemeColor')local O=false local P={}function P:UpdateToggle(Q,R)if Q~=nil then I.Text=tostring(Q)end O=R==true N.Visible=O classicInvoke(E,G,O
)end H.Activated:Connect(function()P:UpdateToggle(nil,not O)end)return P end function D:NewTextBox(E,F,G)local H,I,J=makeElement('textboxElement',33,E,F,0)local K=c.TouchEnabled and 44 or 33 J.Text=
'T'J.TextSize=13 I.Size=UDim2.new(0.49,-34,1,0)local L=classicCreate('TextBox',{Name='TextBox',Position=UDim2.new(0.49,0,0.5,-9),Size=UDim2.new(0.43,-2,0,18),BackgroundColor3=Color3.fromRGB(14,14,18),
BorderSizePixel=0,ClearTextOnFocus=false,PlaceholderText='Type here!',Text='',Font=Enum.Font.Gotham,TextColor3=ab.theme.TextColor,PlaceholderColor3=Color3.fromRGB(135,135,145),TextSize=12,
TextXAlignment=Enum.TextXAlignment.Left},H)classicCorner(L,9)classicCreate('UIPadding',{PaddingLeft=UDim.new(0,6),PaddingRight=UDim.new(0,6)},L)local function layoutTextBox(M)if M then H.Size=UDim2.
new(1,0,0,64)J.Position=UDim2.fromOffset(7,4)I.Position=UDim2.fromOffset(34,0)I.Size=UDim2.new(1,-70,0,30)L.Position=UDim2.fromOffset(34,32)L.Size=UDim2.new(1,-72,0,24)else H.Size=UDim2.new(1,0,0,K)J.
Position=UDim2.new(0,7,0.5,-11)I.Position=UDim2.fromOffset(34,0)I.Size=UDim2.new(0.49,-34,1,0)L.Position=UDim2.new(0.49,0,0.5,-9)L.Size=UDim2.new(0.43,-2,0,18)end end table.insert(au,layoutTextBox)
layoutTextBox(af.Size.X.Offset<420)L.FocusLost:Connect(function(M)if M then classicInvoke(E,G,L.Text)end end)return L end function D:NewSlider(E,F,G,H,I,J)if type(I)=='function'then J=I I=H end G=
tonumber(G)or 100 H=tonumber(H)or 0 local K,L,M=makeElement('sliderElement',33,E,F,0)local N=c.TouchEnabled and 44 or 33 M.Text='\u{25c9}'M.TextSize=13 L.Size=UDim2.new(0.49,-34,1,0)local O=math.
clamp(tonumber(I)or H,H,G)local P=classicCreate('TextLabel',{Name='value',Position=UDim2.new(1,-58,0,0),Size=UDim2.fromOffset(31,33),BackgroundTransparency=1,Font=Enum.Font.GothamSemibold,Text=
tostring(O),TextSize=12,TextXAlignment=Enum.TextXAlignment.Right},K)classicBindTheme(P,'TextColor3','SchemeColor')local Q=classicCreate('TextButton',{Name='sliderBtn',Position=UDim2.new(0.49,0,0.5,-12
),Size=UDim2.new(0.34,0,0,23),BackgroundTransparency=1,BorderSizePixel=0,Text=''},K)local R=classicCreate('Frame',{Name='track',AnchorPoint=Vector2.new(0,0.5),Position=UDim2.fromScale(0,0.5),Size=
UDim2.new(1,0,0,6),BackgroundColor3=Color3.fromRGB(45,45,52),BorderSizePixel=0},Q)classicCorner(R,3)local S=classicCreate('Frame',{Name='sliderDrag',Size=UDim2.new(G~=H and((O-H)/(G-H))or 0,0,1,0),
BorderSizePixel=0},R)classicCorner(S,3)classicBindTheme(S,'BackgroundColor3','SchemeColor')local function layoutSlider(T)if T then K.Size=UDim2.new(1,0,0,60)M.Position=UDim2.fromOffset(7,4)L.Position=
UDim2.fromOffset(34,0)L.Size=UDim2.new(1,-70,0,30)Q.Position=UDim2.fromOffset(34,30)Q.Size=UDim2.new(1,-136,0,28)P.Position=UDim2.new(1,-100,0,30)P.Size=UDim2.fromOffset(70,28)else K.Size=UDim2.new(1,
0,0,N)M.Position=UDim2.new(0,7,0.5,-11)L.Position=UDim2.fromOffset(34,0)L.Size=UDim2.new(0.49,-34,1,0)Q.Position=UDim2.new(0.49,0,0.5,-12)Q.Size=UDim2.new(0.34,0,0,23)P.Position=UDim2.new(1,-58,0,0)P.
Size=UDim2.new(0,31,1,0)end end table.insert(au,layoutSlider)layoutSlider(af.Size.X.Offset<420)local T=false local U=G-H local V={}function V:SetValue(W,X)O=math.clamp(tonumber(W)or H,H,G)local Y=U~=0
and((O-H)/U)or 0 S.Size=UDim2.new(Y,0,1,0)P.Text=tostring(O)if X~=false then classicInvoke(E,J,O)end end function V:GetValue()return O end local function setFromInput(W)if Q.AbsoluteSize.X<=0 then
return end local X=math.clamp((W.Position.X-Q.AbsolutePosition.X)/Q.AbsoluteSize.X,0,1)V:SetValue(math.floor(H+(U*X)+0.5),true)end Q.InputBegan:Connect(function(W)if W.UserInputType==Enum.
UserInputType.MouseButton1 or W.UserInputType==Enum.UserInputType.Touch then T=true setFromInput(W)end end)trackConnection(c.InputChanged:Connect(function(W)if T and(W.UserInputType==Enum.
UserInputType.MouseMovement or W.UserInputType==Enum.UserInputType.Touch)then setFromInput(W)end end))trackConnection(c.InputEnded:Connect(function(W)if W.UserInputType==Enum.UserInputType.
MouseButton1 or W.UserInputType==Enum.UserInputType.Touch then T=false end end))return V end function D:NewKeybind(E,F,G,H)local I,J,K=makeElement('keybindElement',33,E,F,70)K.Text='K'K.TextSize=12
local L=G or Enum.KeyCode.Unknown local M=false local N=classicCreate('TextLabel',{Name='togName',Position=UDim2.new(1,-96,0,0),Size=UDim2.fromOffset(70,33),BackgroundTransparency=1,Font=Enum.Font.
GothamSemibold,Text=L.Name,TextSize=14,TextXAlignment=Enum.TextXAlignment.Right},I)classicBindTheme(N,'TextColor3','SchemeColor')I.Activated:Connect(function()M=true N.Text='...'end)trackConnection(c.
InputBegan:Connect(function(O,P)if n then return end if M then if O.KeyCode~=Enum.KeyCode.Unknown then L=O.KeyCode N.Text=L.Name M=false end return end if not P and not c:GetFocusedTextBox()and O.
KeyCode==L then classicInvoke(E,H)end end))local O={}function O:UpdateKeybind(P,Q)if P~=nil then J.Text=tostring(P)end if Q then L=Q N.Text=L.Name end end return O end return D end return w end local
t=classicCreate('Frame',{Name='MainOutline',Position=UDim2.fromOffset(1,1),Size=UDim2.new(1,-2,1,-2),BackgroundTransparency=1,BorderSizePixel=0,Active=false,ZIndex=100},af)classicCorner(t,17)local u=
classicCreate('UIStroke',{Thickness=1,Transparency=0.08,ApplyStrokeMode=Enum.ApplyStrokeMode.Border},t)classicBindTheme(u,'Color','SchemeColor')return s end return ab end)()local function 
bootstrapAlive()return not n and isCurrentSuiteGeneration()and q and q.Parent~=nil end local function abortBootstrap()n=true for ac=#o,1,-1 do local ad=o[ac]pcall(function()ad:Disconnect()end)o[ac]=
nil end if ab.gui and ab.gui.Parent then ab.gui:Destroy()end if aa.gui and aa.gui.Parent then aa.gui:Destroy()end if q and q.Parent then q:Destroy()end end if aa.status then aa.status.Text=
'Montando interface cl\u{e1}ssica local...'end if not bootstrapAlive()then abortBootstrap()return end local ac do local ad,ae=pcall(function()return ab.CreateLib(h,r)end)if not ad or not ae or not
bootstrapAlive()then warn(g..': falha ao criar a janela local: '..tostring(ae))abortBootstrap()return end ac=ae end local ad local ae={}local function notify(af,ag)if not ad or not ad.Parent then
warn((af or g)..': '..(ag or''))return end local ah=Instance.new('Frame')ah.Name='NothriloToast'ah.Size=UDim2.new(1,0,0,74)ah.BackgroundColor3=Color3.fromRGB(18,18,23)ah.BackgroundTransparency=1 ah.
BorderSizePixel=0 ah.Parent=ad Instance.new('UICorner',ah).CornerRadius=UDim.new(0,15)local ai=Instance.new('UIStroke')ai.Name='RGBStroke'ai.Thickness=1.5 ai.Transparency=1 ai.Parent=ah table.insert(
ae,ai)local aj=Instance.new('TextLabel')aj.Size=UDim2.fromOffset(42,42)aj.Position=UDim2.fromOffset(14,16)aj.BackgroundColor3=Color3.fromRGB(30,30,37)aj.BackgroundTransparency=1 aj.Font=Enum.Font.
GothamBold aj.Text='N'aj.TextColor3=Color3.fromRGB(255,255,255)aj.TextSize=18 aj.TextTransparency=1 aj.Parent=ah Instance.new('UICorner',aj).CornerRadius=UDim.new(1,0)local ak=Instance.new('TextLabel'
)ak.Size=UDim2.new(1,-76,0,20)ak.Position=UDim2.fromOffset(68,14)ak.BackgroundTransparency=1 ak.Font=Enum.Font.GothamBold ak.Text=af or g ak.TextColor3=Color3.fromRGB(250,250,252)ak.TextSize=14 ak.
TextTransparency=1 ak.TextXAlignment=Enum.TextXAlignment.Left ak.Parent=ah local al=Instance.new('TextLabel')al.Size=UDim2.new(1,-76,0,30)al.Position=UDim2.fromOffset(68,34)al.BackgroundTransparency=1
al.Font=Enum.Font.Gotham al.Text=ag or''al.TextColor3=Color3.fromRGB(185,185,195)al.TextSize=12 al.TextTransparency=1 al.TextWrapped=true al.TextXAlignment=Enum.TextXAlignment.Left al.TextYAlignment=
Enum.TextYAlignment.Top al.Parent=ah local am=TweenInfo.new(0.22,Enum.EasingStyle.Quint,Enum.EasingDirection.Out)d:Create(ah,am,{BackgroundTransparency=0}):Play()d:Create(ai,TweenInfo.new(0.22),{
Transparency=0.15}):Play()d:Create(aj,TweenInfo.new(0.22),{BackgroundTransparency=0,TextTransparency=0}):Play()d:Create(ak,TweenInfo.new(0.22),{TextTransparency=0}):Play()d:Create(al,TweenInfo.new(
0.22),{TextTransparency=0}):Play()task.delay(4,function()if not ah.Parent then return end local an=TweenInfo.new(0.2,Enum.EasingStyle.Quad,Enum.EasingDirection.In)d:Create(ah,an,{
BackgroundTransparency=1}):Play()d:Create(ai,an,{Transparency=1}):Play()d:Create(aj,an,{BackgroundTransparency=1,TextTransparency=1}):Play()d:Create(ak,an,{TextTransparency=1}):Play()d:Create(al,an,{
TextTransparency=1}):Play()task.wait(0.25)ah:Destroy()end)end local function getCharacter(af)local ag=f.Character if ag or not af then return ag end local ah=os.clock()+5 repeat task.wait(0.05)ag=f.
Character until ag or n or not isCurrentSuiteGeneration()or os.clock()>=ah return ag end local function getHumanoid(af,ag)af=af or getCharacter(ag and ag>0)if not af then return nil end local ah=af:
FindFirstChildOfClass('Humanoid')if not ah and ag and ag>0 then local ai=af:WaitForChild('Humanoid',ag)if ai and ai:IsA('Humanoid')then ah=ai end end return ah end local function getRoot(af,ag)af=af
or getCharacter(ag and ag>0)if not af then return nil end local ah=af:FindFirstChild('HumanoidRootPart')if not ah and ag and ag>0 then local ai=af:WaitForChild('HumanoidRootPart',ag)if ai and ai:IsA(
'BasePart')then ah=ai end end return ah end local function teleportCharacter(af)if n or not isCurrentSuiteGeneration()then return false end local ag=getCharacter(true)local ah=getRoot(ag,5)local ai=
getHumanoid(ag,5)if n or not isCurrentSuiteGeneration()or not ag or not ah then notify('Teleporte','HumanoidRootPart n\u{e3}o encontrado.')return false end if ai and ai.SeatPart then ai.Sit=false
pcall(function()ai:ChangeState(Enum.HumanoidStateType.GettingUp)end)local aj=os.clock()+0.6 repeat b.Heartbeat:Wait()until not ai.Parent or not ai.SeatPart or os.clock()>=aj end if n or not
isCurrentSuiteGeneration()then return false end ah=getRoot(ag)if not ah then return false end local aj=pcall(function()local aj=ag:GetPivot():ToObjectSpace(ah.CFrame)ag:PivotTo(af*aj:Inverse())ah.
AssemblyLinearVelocity=Vector3.zero ah.AssemblyAngularVelocity=Vector3.zero end)if not aj then notify('Teleporte','N\u{e3}o foi poss\u{ed}vel mover o personagem.')end return aj end local af=
'NothriloESP'local ag=false local ah={}local ai={}local aj={}local ak=0 local function getESPColor(al)if al.Team and al.Team.TeamColor then return al.Team.TeamColor.Color end return Color3.fromRGB(190
,130,255)end local function removeESP(al)local am=ah[al]if not am then return end if am.Billboard and am.Billboard.Parent then am.Billboard:Destroy()end if am.Highlight and am.Highlight.Parent then am
.Highlight:Destroy()end local an=am.Humanoid local ao=am.DisplayState if an and an.Parent and ao then pcall(function()an.DisplayDistanceType=ao.DisplayDistanceType an.NameOcclusion=ao.NameOcclusion an
.NameDisplayDistance=ao.NameDisplayDistance an.HealthDisplayDistance=ao.HealthDisplayDistance end)end ah[al]=nil end local function refreshESPColor(al)local am=ah[al]if not am then return end local an
=getESPColor(al)if am.Highlight and am.Highlight.Parent then am.Highlight.FillColor=an am.Highlight.OutlineColor=an end if am.Label and am.Label.Parent then am.Label.TextColor3=an end end local 
function refreshESPDistance(al)local am=ah[al]if not am or not am.Billboard or not am.Billboard.Parent then return end local an=f.Character local ao=an and an:FindFirstChild('HumanoidRootPart')local
ap=am.Billboard.Adornee if not ao or not ap or not ap.Parent then am.Billboard.Enabled=false return end local aq=(ao.Position-ap.Position).Magnitude local ar=150 am.Billboard.Enabled=true local as=
math.clamp((aq-ar)/450,0,1)am.Billboard.Size=UDim2.fromOffset(math.floor(118+(210-118)*as),math.floor(20+(38-20)*as))if am.Label and am.Label.Parent then am.Label.Text=string.format('%s  [%d studs]',
am.BaseText or al.DisplayName or al.Name,math.floor(aq+0.5))end end local function addESP(al,am)if not ag or al==f then return end am=am or al.Character if not am or not am.Parent then return end
local an=am:FindFirstChild('HumanoidRootPart')local ao=am:FindFirstChildOfClass('Humanoid')if not an or not ao then return end removeESP(al)local ap={DisplayDistanceType=ao.DisplayDistanceType,
NameOcclusion=ao.NameOcclusion,NameDisplayDistance=ao.NameDisplayDistance,HealthDisplayDistance=ao.HealthDisplayDistance}pcall(function()ao.DisplayDistanceType=Enum.HumanoidDisplayDistanceType.None ao
.NameOcclusion=Enum.NameOcclusion.NoOcclusion ao.NameDisplayDistance=0 ao.HealthDisplayDistance=0 end)local aq=Instance.new('BillboardGui')aq.Name=af..'Name'aq.Size=UDim2.fromOffset(118,20)aq.Enabled=
false aq.Adornee=an aq.AlwaysOnTop=true aq.LightInfluence=0 aq.MaxDistance=math.huge aq.StudsOffset=Vector3.new(0,3.2,0)aq.Parent=an local ar=Instance.new('TextLabel')ar.Name='NameLabel'ar.Size=UDim2.
fromScale(1,1)ar.BackgroundTransparency=1 ar.Font=Enum.Font.GothamBold local as=al.DisplayName~=''and al.DisplayName or al.Name ar.Text=as ar.TextScaled=true ar.TextStrokeColor3=Color3.fromRGB(0,0,0)
ar.TextStrokeTransparency=0 ar.Parent=aq local at=Instance.new('Highlight')at.Name=af at.FillTransparency=0.5 at.OutlineTransparency=0 at.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop at.Adornee=am at
.Parent=am ah[al]={Billboard=aq,Label=ar,Highlight=at,Humanoid=ao,DisplayState=ap,BaseText=as}refreshESPColor(al)refreshESPDistance(al)end local function disconnectESPPlayer(al)local am=ai[al]if am
then for an,ao in ipairs(am)do ao:Disconnect()end end ai[al]=nil end local function watchESPPlayer(al)if al==f then return end disconnectESPPlayer(al)local am={}ai[al]=am table.insert(am,al.
CharacterAdded:Connect(function(an)task.wait(0.2)addESP(al,an)end))table.insert(am,al.CharacterRemoving:Connect(function()removeESP(al)end))table.insert(am,al:GetPropertyChangedSignal('Team'):Connect(
function()refreshESPColor(al)end))table.insert(am,al:GetPropertyChangedSignal('DisplayName'):Connect(function()local an=ah[al]if an then an.BaseText=al.DisplayName~=''and al.DisplayName or al.Name
refreshESPDistance(al)end end))addESP(al,al.Character)end local function clearESP()for al,am in ipairs(aj)do am:Disconnect()end table.clear(aj)local al={}for am in pairs(ai)do table.insert(al,am)end
for am,an in ipairs(al)do disconnectESPPlayer(an)end local am={}for an in pairs(ah)do table.insert(am,an)end for an,ao in ipairs(am)do removeESP(ao)end end local function setESP(al)ag=al ak=ak+1
clearESP()if not al then notify('ESP','Desligado.')return end for am,an in ipairs(a:GetPlayers())do watchESPPlayer(an)end table.insert(aj,a.PlayerAdded:Connect(watchESPPlayer))table.insert(aj,a.
PlayerRemoving:Connect(function(am)removeESP(am)disconnectESPPlayer(am)end))local am=ak task.spawn(function()while ag and am==ak do for an,ao in ipairs(a:GetPlayers())do if ao~=f and ao.Character then
local ap=ah[ao]local aq=ap and ap.Billboard and ap.Billboard.Parent and ap.Highlight and ap.Highlight.Parent if not aq then removeESP(ao)addESP(ao,ao.Character)else refreshESPDistance(ao)end end end
task.wait(0.5)end end)notify('ESP','Ligado: nomes e contornos ativos.')end local al=false local am local an local ao local ap local aq local ar=false local as=0 local at local au local s local t local
u={}local v=false local w=0 local x=0 local y local z={}local function restoreDefaultCamera()local A=workspace.CurrentCamera if not A then return end A.CameraType=Enum.CameraType.Custom local B=
getHumanoid()if B then A.CameraSubject=B end end local function claimCameraMode(A)if y==A then return end local B=y y=A local C=B and z[B]if C then pcall(C)end end local function releaseCameraMode(A)
if y~=A then return end y=nil restoreDefaultCamera()end local function resetCameraModes()local A=y y=nil local B=A and z[A]if B then pcall(B)end restoreDefaultCamera()end local function 
restoreCameraWhenCharacterReady(A)z.restoreSession=(z.restoreSession or 0)+1 local B=z.restoreSession task.spawn(function()local C=A and(A:FindFirstChildOfClass('Humanoid')or A:WaitForChild('Humanoid'
,5))if n or B~=z.restoreSession or y or A~=f.Character or not C or not C.Parent then return end local D=workspace.CurrentCamera if D then D.CameraType=Enum.CameraType.Custom D.CameraSubject=C end end)
end trackConnection(workspace:GetPropertyChangedSignal('CurrentCamera'):Connect(function()task.defer(function()if not n and not y then restoreDefaultCamera()end end)end))local A=false local B=1 local
C local D local E={inputEnabled=true}local F=f:GetMouse()local G=0 local H=0 local I local J=0 local function showMobileFlyControls(K)if not c.TouchEnabled then return end if I and I.Parent then I.
Enabled=K return end if not K then return end local L=Instance.new('ScreenGui')L.Name='NothriloMobileFly'L.ResetOnSpawn=false L.IgnoreGuiInset=true L.DisplayOrder=10020 L.Parent=k I=L local M=Instance
.new('Frame')M.Name='ControlesDeVoo'M.AnchorPoint=Vector2.new(1,0.5)M.Position=UDim2.new(1,-16,0.5,0)M.Size=UDim2.fromOffset(72,124)M.BackgroundColor3=Color3.fromRGB(10,10,13)M.BackgroundTransparency=
0.12 M.BorderSizePixel=0 M.Parent=L Instance.new('UICorner',M).CornerRadius=UDim.new(0,14)local N=Instance.new('UIStroke',M)N.Color=r.SchemeColor N.Thickness=1 local O=Instance.new('TextLabel')O.
BackgroundTransparency=1 O.Position=UDim2.fromOffset(0,6)O.Size=UDim2.new(1,0,0,18)O.Font=Enum.Font.GothamBold O.Text='VOO'O.TextColor3=Color3.fromRGB(245,245,245)O.TextSize=11 O.Parent=M local 
function makeBtn(P,Q,R)local S=Instance.new('TextButton')S.Size=UDim2.fromOffset(52,38)S.Position=UDim2.new(0.5,-26,0,Q)S.BackgroundColor3=Color3.fromRGB(28,28,35)S.BorderSizePixel=0 S.AutoButtonColor
=false S.Font=Enum.Font.GothamBold S.Text=P S.TextColor3=r.SchemeColor S.TextSize=22 S.Parent=M Instance.new('UICorner',S).CornerRadius=UDim.new(0,10)S.InputBegan:Connect(function(T)if T.UserInputType
==Enum.UserInputType.Touch or T.UserInputType==Enum.UserInputType.MouseButton1 then R(1)S.BackgroundColor3=Color3.fromRGB(48,48,58)end end)S.InputEnded:Connect(function(T)if T.UserInputType==Enum.
UserInputType.Touch or T.UserInputType==Enum.UserInputType.MouseButton1 then R(0)S.BackgroundColor3=Color3.fromRGB(28,28,35)end end)end makeBtn('\u{25b2}',30,function(P)G=P end)makeBtn('\u{25bc}',74,
function(P)H=P end)end local function stopFly()J=J+1 A=false G=0 H=0 showMobileFlyControls(false)if C then C:Disconnect()C=nil end if D then D:Disconnect()D=nil end local K=E.root or(f.Character and f
.Character:FindFirstChild('HumanoidRootPart'))if E.gyro and E.gyro.Parent then E.gyro:Destroy()end if E.velocity and E.velocity.Parent then E.velocity:Destroy()end if K then local L=K:FindFirstChild(
'CafezlVehicleFlyGyro')local M=K:FindFirstChild('CafezlVehicleFlyVelocity')if L then L:Destroy()end if M then M:Destroy()end end E.root=nil E.gyro=nil E.velocity=nil E.startedSeated=false E.
inputEnabled=true releaseCameraMode('fly')end local function startVehicleFly(K)if z.autoWin then z.autoWin(true)end stopFly()local L=J if n or not isCurrentSuiteGeneration()then return false end local
M=getCharacter(true)local N=getRoot(M,5)local O=getHumanoid(M,5)if n or not isCurrentSuiteGeneration()or not N or not O then notify('Voo do Ve\u{ed}culo','Personagem n\u{e3}o encontrado.')return false
end claimCameraMode('fly')pcall(function()if workspace.CurrentCamera then workspace.CurrentCamera.CameraType=Enum.CameraType.Track end end)E.inputEnabled=K~=false E.startedSeated=O.SeatPart~=nil local
P={F=0,B=0,L=0,R=0,Q=0,E=0}local Q={F=0,B=0,L=0,R=0,Q=0,E=0}A=true showMobileFlyControls(E.inputEnabled)local R=Instance.new('BodyGyro')R.Name='CafezlVehicleFlyGyro'R.P=90000 R.MaxTorque=Vector3.new(
9e9,9e9,9e9)R.CFrame=N.CFrame R.Parent=N local S=Instance.new('BodyVelocity')S.Name='CafezlVehicleFlyVelocity'S.MaxForce=Vector3.new(9e9,9e9,9e9)S.Velocity=Vector3.zero S.Parent=N E.root=N E.gyro=R E.
velocity=S C=F.KeyDown:Connect(function(T)if not E.inputEnabled then return end T=T:lower()if T=='w'then P.F=B elseif T=='s'then P.B=-B elseif T=='a'then P.L=-B elseif T=='d'then P.R=B elseif T=='e'
then P.Q=B*2 elseif T=='q'then P.E=-B*2 end pcall(function()if workspace.CurrentCamera then workspace.CurrentCamera.CameraType=Enum.CameraType.Track end end)end)D=F.KeyUp:Connect(function(T)if not E.
inputEnabled then return end T=T:lower()if T=='w'then P.F=0 elseif T=='s'then P.B=0 elseif T=='a'then P.L=0 elseif T=='d'then P.R=0 elseif T=='e'then P.Q=0 elseif T=='q'then P.E=0 end end)task.spawn(
function()local T while A and L==J and N.Parent and O.Parent and R.Parent and S.Parent do task.wait()if E.inputEnabled and c.KeyboardEnabled then P.F=c:IsKeyDown(Enum.KeyCode.W)and B or 0 P.B=c:
IsKeyDown(Enum.KeyCode.S)and-B or 0 P.L=c:IsKeyDown(Enum.KeyCode.A)and-B or 0 P.R=c:IsKeyDown(Enum.KeyCode.D)and B or 0 P.Q=c:IsKeyDown(Enum.KeyCode.E)and B*2 or 0 P.E=c:IsKeyDown(Enum.KeyCode.Q)and-B
*2 or 0 end local U=(P.L+P.R~=0)or(P.F+P.B~=0)or(P.Q+P.E~=0)local V=O.MoveDirection if E.inputEnabled and c.TouchEnabled and Vector3.new(V.X,0,V.Z).Magnitude<=0.05 then local W=O.SeatPart local X=
workspace.CurrentCamera if W and W:IsA('VehicleSeat')and X then local Y=Vector3.new(X.CFrame.LookVector.X,0,X.CFrame.LookVector.Z)local Z=Vector3.new(X.CFrame.RightVector.X,0,X.CFrame.RightVector.Z)if
Y.Magnitude>0.01 then Y=Y.Unit end if Z.Magnitude>0.01 then Z=Z.Unit end V=Y*W.ThrottleFloat+Z*W.SteerFloat end end local W=E.inputEnabled and c.TouchEnabled and(Vector3.new(V.X,0,V.Z).Magnitude>0.05
or G~=0 or H~=0)local X=U or W local Y=X and 50 or 0 if U then Q={F=P.F,B=P.B,L=P.L,R=P.R,Q=P.Q,E=P.E}end local Z=U and P or Q if U and Y>0 then local _=workspace.CurrentCamera if not _ then break end
S.Velocity=((_.CFrame.LookVector*(Z.F+Z.B))+((_.CFrame*CFrame.new(Z.L+Z.R,(Z.F+Z.B+Z.Q+Z.E)*0.2,0)).Position-_.CFrame.Position))*Y elseif W and Y>0 then S.Velocity=Vector3.new(V.X,0,V.Z)*(B*Y)+Vector3
.new(0,(G-H)*B*Y,0)else S.Velocity=Vector3.zero end local _=workspace.CurrentCamera if not _ then break end if _~=T then T=_ pcall(function()_.CameraType=Enum.CameraType.Track end)end R.CFrame=_.
CFrame end if R.Parent then R:Destroy()end if S.Parent then S:Destroy()end if L==J then E.root=nil E.gyro=nil E.velocity=nil end if L==J and A then if al and am then am:UpdateToggle(nil,false)else
stopFly()end end end)return true end z.fly=function()if al and am then am:UpdateToggle(nil,false)else stopFly()end end local function findCartFromSeat(K)if not K or not K:IsA('VehicleSeat')then return
nil end local L=K.AssemblyRootPart local M=K.Parent local N while M and M~=workspace do if M:IsA('Model')then N=N or M local O=0 for P,Q in ipairs(M:GetDescendants())do if Q:IsA('BasePart')and(not L
or Q.AssemblyRootPart==L)then O=O+1 if O>=2 then return M end end end end M=M.Parent end return N end local K local L local M local function cacheCartFromSeat(N)K=N M=N and N.AssemblyRootPart or nil L
=N and findCartFromSeat(N)or nil return L end local function getCurrentCart()local N=getHumanoid()local O=N and N.SeatPart if not O or not O:IsA('VehicleSeat')then K=nil L=nil M=nil return nil end if
O~=K or not L or not L.Parent or not L:IsAncestorOf(O)or O.AssemblyRootPart~=M then return cacheCartFromSeat(O)end return L end local function getCartPrimary(N)if not N then return nil end local O=K
if not O or not O.Parent then local P=getHumanoid()O=P and P.SeatPart end if O and O:IsA('VehicleSeat')and N:IsAncestorOf(O)and not O.Anchored then return O end if N.PrimaryPart and not N.PrimaryPart.
Anchored then return N.PrimaryPart end local P for Q,R in ipairs(N:GetDescendants())do if R:IsA('BasePart')and not R.Anchored then P=P or R if R.AssemblyRootPart==R then return R end end end return P
or N.PrimaryPart end local N={}local O=false local function restorePanicStop()for P,Q in pairs(N)do if P and P.Parent then P.Anchored=Q end end N={}O=false end local function setPanicStop(P)if not P
then restorePanicStop()notify('Carrinho','Parada de emerg\u{ea}ncia desligada.')return true end local Q=getCurrentCart()if not Q then notify('Carrinho','Sente em um carrinho primeiro.')return false
end if v then w=w+1 v=false end if al and am then am:UpdateToggle(nil,false)else stopFly()end if ap then ap()end if an then task.defer(function()an:UpdateToggle(nil,false)end)end restorePanicStop()O=
true for R,S in ipairs(Q:GetDescendants())do if S:IsA('BasePart')then N[S]=S.Anchored if not S.Anchored then pcall(function()S.AssemblyLinearVelocity=Vector3.zero S.AssemblyAngularVelocity=Vector3.
zero end)end S.Anchored=true end end notify('Carrinho','Parada de emerg\u{ea}ncia ligada.')return true end local function pivotCartByReference(P,Q)local R=getCartPrimary(P)if not P or not R then
return false end return pcall(function()local S=P:GetPivot():ToObjectSpace(R.CFrame)for T,U in ipairs(P:GetDescendants())do if U:IsA('BasePart')and not U.Anchored then pcall(function()U.
AssemblyLinearVelocity=Vector3.zero U.AssemblyAngularVelocity=Vector3.zero end)end end P:PivotTo(Q*S:Inverse())for T,U in ipairs(P:GetDescendants())do if U:IsA('BasePart')and not U.Anchored then
pcall(function()U.AssemblyLinearVelocity=Vector3.zero U.AssemblyAngularVelocity=Vector3.zero end)end end end)end local function getCheckpointCartModel(P)local Q=getHumanoid()local R=Q and Q.SeatPart
local S=R and R.Parent if S and S:IsA('Model')and S.PrimaryPart then return S end if P and P:IsA('Model')and P.PrimaryPart then return P end return nil end local function pivotCartByPrimaryPart(P,Q)
local R=getCheckpointCartModel(P)if not R then return false,'missing_primary'end local S=pcall(function()for S,T in ipairs(R:GetDescendants())do if T:IsA('BasePart')and not T.Anchored then pcall(
function()T.AssemblyLinearVelocity=Vector3.zero T.AssemblyAngularVelocity=Vector3.zero end)end end R:SetPrimaryPartCFrame(Q)local S=R.PrimaryPart if S then pcall(function()S.AssemblyLinearVelocity=
Vector3.zero S.AssemblyAngularVelocity=Vector3.zero end)end for T,U in ipairs(R:GetDescendants())do if U:IsA('BasePart')and not U.Anchored then pcall(function()U.AssemblyLinearVelocity=Vector3.zero U.
AssemblyAngularVelocity=Vector3.zero end)end end end)if S then return true,nil end return false,'pivot_failed'end local function stopCartControllersForTeleport(P)if not P and z.autoWin then z.autoWin(
true)end x=os.clock()+0.25 if v then w=w+1 v=false end if al and am then am:UpdateToggle(nil,false)else stopFly()end if ap then ap()end restorePanicStop()if an then task.defer(function()an:
UpdateToggle(nil,false)end)end if ao then task.defer(function()ao:UpdateToggle(nil,false)end)end end local function teleportCart(P)stopCartControllersForTeleport()local Q=getCurrentCart()if not Q then
notify('Carrinho','Sente em um carrinho primeiro.')return false end local R,S=pivotCartByPrimaryPart(Q,P)if R then notify('Carrinho','Carrinho movido para o checkpoint.')elseif S=='missing_primary'
then notify('Carrinho','O modelo deste carrinho n\u{e3}o possui PrimaryPart.')else notify('Carrinho','N\u{e3}o foi poss\u{ed}vel mover este carrinho.')end return R end local P={NORMAL_FORCE=2500,
DOWNHILL_FORCE=800}local Q={enabled=false,cart=nil,forces={},attachments={},heartbeat=nil}local function cleanupStabilizer()if Q.heartbeat then Q.heartbeat:Disconnect()Q.heartbeat=nil end for R,S in
ipairs(Q.forces)do if S and S.Parent then S:Destroy()end end for R,S in ipairs(Q.attachments)do if S and S.Parent then S:Destroy()end end Q.forces={}Q.attachments={}Q.cart=nil end local function 
getWheels(R)local S={}local T={'wheel','tire','tyre','roda','pneu','axle','roue'}for U,V in ipairs(R:GetDescendants())do if V:IsA('BasePart')and not V.Anchored then local W=V.Name:lower()for X,Y in
ipairs(T)do if W:find(Y,1,true)then table.insert(S,V)break end end end end if#S==0 then local U={}for V,W in ipairs(R:GetDescendants())do if W:IsA('BasePart')and not W.Anchored then table.insert(U,W)
end end table.sort(U,function(V,W)return V.Position.Y<W.Position.Y end)local V=math.max(1,math.floor(#U/3))for W=1,math.min(V,#U)do table.insert(S,U[W])end end return S end local function 
applyStabilizer(R)if not R or not R.Parent then return end cleanupStabilizer()local S=getWheels(R)if#S==0 then notify('Estabilizador','Nenhuma roda encontrada.')return end Q.cart=R for T,U in ipairs(S
)do local V=U:FindFirstChild('_CafezlStabilizer')if not V then V=Instance.new('Attachment')V.Name='_CafezlStabilizer'V.Parent=U table.insert(Q.attachments,V)end local W=Instance.new('VectorForce')W.
Name='CafezlStabilizerForce'W.Attachment0=V W.RelativeTo=Enum.ActuatorRelativeTo.World W.Force=Vector3.zero W.Parent=U table.insert(Q.forces,W)end local T=getCartPrimary(R)or S[1]Q.heartbeat=b.
Heartbeat:Connect(function()if not T or not T.Parent or getCurrentCart()~=R then cleanupStabilizer()return end local U=0 if Q.enabled and not A and not O and os.clock()>=x then U=math.abs(T.
AssemblyLinearVelocity.Y)>5 and P.DOWNHILL_FORCE or P.NORMAL_FORCE end for V,W in ipairs(Q.forces)do if W and W.Parent and W.Attachment0 and W.Attachment0.Parent then W.Force=Vector3.new(0,-U*W.Parent
.AssemblyMass,0)end end end)end local function refreshStabilizer()if Q.enabled then local R=getCurrentCart()if R then applyStabilizer(R)else notify('Estabilizador','Sente em um carrinho primeiro.')end
else cleanupStabilizer()end end local R local function watchSeat(S,T)local U=T or getHumanoid(S)if not U then return end if R then R:Disconnect()R=nil end cacheCartFromSeat(U.SeatPart)R=
trackConnection(U.Seated:Connect(function(V,W)if not V then cacheCartFromSeat(nil)cleanupStabilizer()restorePanicStop()if ap then ap()end if A and E.startedSeated then if al and am then task.defer(
function()am:UpdateToggle(nil,false)end)else stopFly()end end if an then task.defer(function()an:UpdateToggle(nil,false)end)end if ao then task.defer(function()ao:UpdateToggle(nil,false)end)end else
local X=cacheCartFromSeat(W)if Q.enabled then applyStabilizer(X)end end end))end local function watchSeatWhenReady(S,T)if not S then return end task.spawn(function()local U=S:FindFirstChildOfClass(
'Humanoid')or S:WaitForChild('Humanoid',5)if n or not isCurrentSuiteGeneration()or not S.Parent or not U or not U:IsA('Humanoid')then return end watchSeat(S,U)if T and not ar then if au then U.
WalkSpeed=au end if U.UseJumpPower and s then U.JumpPower=s elseif not U.UseJumpPower and t then U.JumpHeight=t end end end)end watchSeatWhenReady(f.Character,false)trackConnection(f.CharacterAdded:
Connect(function(S)if z.autoWin then z.autoWin(true)end cacheCartFromSeat(nil)cleanupStabilizer()restorePanicStop()if ao then task.defer(function()ao:UpdateToggle(nil,false)end)end as=as+1 ar=false at
=nil if ap then ap()end if an then task.defer(function()an:UpdateToggle(nil,false)end)end if al and am then am:UpdateToggle(nil,false)else stopFly()end resetCameraModes()
restoreCameraWhenCharacterReady(S)watchSeatWhenReady(S,true)end))trackConnection(f.CharacterRemoving:Connect(function()if z.autoWin then z.autoWin(true)end w=w+1 v=false cacheCartFromSeat(nil)
cleanupStabilizer()restorePanicStop()if ap then ap()end if al and am then am:UpdateToggle(nil,false)else stopFly()end if an then task.defer(function()an:UpdateToggle(nil,false)end)end if ao then task.
defer(function()ao:UpdateToggle(nil,false)end)end resetCameraModes()end))local function findNearestFreeVehicleSeat()local S=getRoot(nil,5)if n or not isCurrentSuiteGeneration()or not S then return nil
end local T,U=nil,math.huge for V,W in ipairs(workspace:GetDescendants())do if W:IsA('VehicleSeat')and not W.Occupant then local X=(S.Position-W.Position).Magnitude if X<U then T=W U=X end end end
return T end local function findPlayerByPartialName(S)S=(S or''):match('^%s*(.-)%s*$'):lower()if S==''then return nil end for T,U in ipairs(a:GetPlayers())do if U.Name:lower()==S or U.DisplayName:
lower()==S then return U end end for T,U in ipairs(a:GetPlayers())do local V=U.Name:lower()local W=U.DisplayName:lower()if V:sub(1,#S)==S or W:sub(1,#S)==S then return U end end for T,U in ipairs(a:
GetPlayers())do if U.Name:lower():find(S,1,true)or U.DisplayName:lower():find(S,1,true)then return U end end return nil end local function sitOnVehicleSeat(S,T)local U=getRoot(nil,5)local V=
getHumanoid(nil,5)if n or not isCurrentSuiteGeneration()or(T and T~=w)or not S or not U or not V or(S.Occupant and S.Occupant~=V)then return false end if V.SeatPart==S or S.Occupant==V then return
true end if V.SeatPart and V.SeatPart~=S then V.Sit=false pcall(function()V:ChangeState(Enum.HumanoidStateType.GettingUp)end)local W=os.clock()+0.5 repeat b.Heartbeat:Wait()until n or(T and T~=w)or
not V.Parent or not V.SeatPart or os.clock()>=W if n or(T and T~=w)or not V.Parent then return false end end for W=1,3 do if V.SeatPart==S or S.Occupant==V then return true end if n or not
isCurrentSuiteGeneration()or(T and T~=w)or not S.Parent or(S.Occupant and S.Occupant~=V)then break end U.CFrame=S.CFrame*CFrame.new(0,2,0)task.wait(0.12)if V.SeatPart==S or S.Occupant==V then return
true end if n or(T and T~=w)or not S.Parent or not V.Parent or(S.Occupant and S.Occupant~=V)then break end pcall(function()S:Sit(V)end)task.wait(0.2)if n or(T and T~=w)or not S.Parent or not V.Parent
or not U.Parent then return false end if V.SeatPart==S or S.Occupant==V then return true end V.Sit=true task.wait(0.12)if n or(T and T~=w)or not S.Parent or not V.Parent or not U.Parent then return
false end if V.SeatPart==S or S.Occupant==V then return true end end return false end local function moveToTarget(S,T,U,V,W)local X=getRoot()local Y=getHumanoid()local Z=os.clock()while os.clock()-Z<T
do if n or not v or U~=w then return false end if not X or not X.Parent or not Y or not Y.Parent or not S or not S.Parent or not V or not V.Parent or V.Occupant~=Y or Y.SeatPart~=V or getCurrentCart()
~=W then return false end local _=S.Position-S.CFrame.LookVector*1.2+Vector3.new(0,1.5,0)X.CFrame=CFrame.lookAt(_,S.Position)b.Heartbeat:Wait()end return true end local function finishKiller(S,T)if T
and T~=w then return end w=w+1 local U=w local V=getHumanoid()local W=V and V.SeatPart~=nil if V then V.Sit=false end if W then task.wait(0.05)if w~=U then return end end if al and am then am:
UpdateToggle(nil,false)else stopFly()end v=false if S then notify('Eliminador',S)end end local function executeKiller(S)if v then notify('Eliminador','Aguarde a tentativa atual terminar.')return end
if z.autoWin then z.autoWin(true)end local T=findPlayerByPartialName(S)if not T or T==f then notify('Eliminador',T==f and'Escolha outro jogador.'or'Jogador n\u{e3}o encontrado.')return end w=w+1 local
U=w v=true if al and am then am:UpdateToggle(nil,false)else stopFly()end if ap then ap()end if an then task.defer(function()an:UpdateToggle(nil,false)end)end local V=getHumanoid()local W=V and V.
SeatPart local X=W and W:IsA('VehicleSeat')and(W.Occupant==V or V.SeatPart==W)if not X then W=findNearestFreeVehicleSeat()if not W then finishKiller('N\u{e3}o h\u{e1} carrinho livre por perto.',U)
return end if n or U~=w then return end if not sitOnVehicleSeat(W,U)then if U==w then finishKiller('N\u{e3}o foi poss\u{ed}vel sentar no carrinho.',U)end return end end if n or U~=w then return end
local Y=cacheCartFromSeat(W)if not Y then finishKiller('Estrutura do carrinho n\u{e3}o reconhecida.',U)return end if not startVehicleFly(false)then finishKiller(
'N\u{e3}o foi poss\u{ed}vel iniciar o voo.',U)return end task.wait(0.15)if n or U~=w then return end local Z local _=os.clock()+2 repeat local av=T.Character Z=av and av:FindFirstChild(
'HumanoidRootPart')if Z then break end task.wait(0.2)until os.clock()>=_ or n or U~=w if not Z then finishKiller('Personagem do alvo n\u{e3}o carregou.',U)return end local av=moveToTarget(Z,3,U,W,Y)if
U==w then finishKiller(av and'Carrinho levado ao alvo.'or'Tentativa cancelada.',U)end end local function teleportPlayerOrCart(av)local S=getCurrentCart()if S then stopCartControllersForTeleport()
return pivotCartByReference(S,av)end return teleportCharacter(av)end trackConnection(f.CharacterAdded:Connect(function()w=w+1 v=false end))local av local S local T=false local U local V local W=ac:
NewTab('Jogador'):NewSection('Configura\u{e7}\u{f5}es do Jogador')W:NewSlider('Velocidade','Velocidade de caminhada (padr\u{e3}o 16).',500,0,16,function(X)au=X local Y=getHumanoid()if Y and not ar
then Y.WalkSpeed=X end end)W:NewButton('Redefinir Velocidade','Volta para 16.',function()au=16 local X=getHumanoid()if X and not ar then X.WalkSpeed=16 end notify('Velocidade','Redefinida para 16.')
end)V=W:NewToggle('Pulo Infinito','Pula no ar. Tecla P.',function(X)T=X notify('Pulo Infinito',X and'Ligado.'or'Desligado.')end)trackConnection(c.JumpRequest:Connect(function()if n or not T then
return end local X=getHumanoid()if X then X:ChangeState(Enum.HumanoidStateType.Jumping)end end))local function giveClickTeleportTool()local X=f:FindFirstChildOfClass('Backpack')if not X then return
end local Y=f.Character if X:FindFirstChild('NothriloClickTP')or(Y and Y:FindFirstChild('NothriloClickTP'))then notify('Teleporte por Clique','A ferramenta j\u{e1} est\u{e1} na mochila.')return end
local Z=Instance.new('Tool')Z.Name='NothriloClickTP'Z.RequiresHandle=false Z:SetAttribute('CafezlOwner','Nothrilo')Z.Activated:Connect(function()teleportCharacter(CFrame.new(F.Hit.Position+Vector3.
new(0,2.5,0)))end)Z.Parent=X table.insert(u,Z)notify('Teleporte por Clique','Ferramenta criada. Clique no mapa para teleportar.')end W:NewButton('Teleporte por Clique',
'Cria ferramenta na mochila. Tecla T.',giveClickTeleportTool)W:NewTextBox('Ir at\u{e9} Jogador','Nome do jogador. Enter.',function(X)local Y=findPlayerByPartialName(X)if not Y then notify(
'Ir at\u{e9} Jogador','Jogador n\u{e3}o encontrado.')return end local Z local _=os.clock()+2 repeat local aw=Y.Character Z=aw and aw:FindFirstChild('HumanoidRootPart')if Z then break end task.wait(0.2
)until os.clock()>=_ if not Z then notify('Ir at\u{e9} Jogador','Personagem n\u{e3}o carregou.')return end teleportCharacter(Z.CFrame*CFrame.new(0,2,0))notify('Ir at\u{e9} Jogador','Teleportado para '
..Y.DisplayName..'.')end)local function setVehicleFlyEnabled(aw)al=aw if aw then if v then al=false notify('Voo do Ve\u{ed}culo','Indispon\u{ed}vel durante o Eliminador.')task.defer(function()if am
then am:UpdateToggle(nil,false)end end)return end if O then restorePanicStop()if ao then task.defer(function()ao:UpdateToggle(nil,false)end)end end if ap then ap()end if an then task.defer(function()
an:UpdateToggle(nil,false)end)end if startVehicleFly()then notify('Voo do Ve\u{ed}culo','Ligado.')else al=false task.defer(function()if am then am:UpdateToggle(nil,false)end end)end else stopFly()
notify('Voo do Ve\u{ed}culo','Desligado.')end end am=W:NewToggle('Voo do Ve\u{ed}culo','Tecla V liga/desliga.',setVehicleFlyEnabled)U=W:NewToggle('ESP','Destaca jogadores. Tecla L.',setESP)W:
NewTextBox('Velocidade do Voo','Digite e aperte Enter.',function(aw)local X=tonumber(aw)if X and X>0 then B=X notify('Voo','Velocidade: '..X)else notify('Voo','Digite um n\u{fa}mero maior que zero.')
end end)W:NewButton('Redefinir Velocidade do Voo','Volta para 1.',function()B=1 S('Velocidade do Voo',1)notify('Voo','Velocidade redefinida para 1.')end)local aw=false local X local Y local Z local _
local ax local function restoreGodHumanoid()if X then X:Disconnect()X=nil end local ay=Z if ay and ay.Parent and _ then ay.MaxHealth=_ ay.Health=math.clamp(ax or _,1,_)end Z,_,ax=nil,nil,nil end local 
function connectGod()restoreGodHumanoid()local ay=getHumanoid()if not ay then return end Z=ay _=ay.MaxHealth ax=ay.Health ay.MaxHealth=math.huge ay.Health=math.huge X=ay.HealthChanged:Connect(function
()if aw and ay.Parent and ay.Health<1 then ay.Health=ay.MaxHealth end end)end local function setGodMode(ay)aw=ay if not ay then restoreGodHumanoid()notify('God Mode','Desligado.')return end
connectGod()if not Y then Y=f.CharacterAdded:Connect(function()task.wait(0.3)if aw then connectGod()end end)end notify('God Mode','Ligado (s\u{f3} funciona localmente).')end W:NewToggle(
'God Mode (local)','Impede que sua vida caia abaixo de 1 localmente.',setGodMode)local ay=false local az W:NewToggle('Anti-AFK','Mant\u{e9}m a sess\u{e3}o de teste ativa.',function(aA)ay=aA if az then
az:Disconnect()az=nil end if not aA then notify('Anti-AFK','Desligado.')return end az=f.Idled:Connect(function()if not ay then return end pcall(function()local aB=game:GetService('VirtualUser')aB:
CaptureController()aB:ClickButton2(Vector2.zero,workspace.CurrentCamera.CFrame)end)end)notify('Anti-AFK','Ligado.')end)do local aA=0 local aB=false local aC local aD local function autoWinAlive(aE)
return aB and aE==aA and not n and isCurrentSuiteGeneration()end local function waitAutoWin(aE,aF)local aG=os.clock()+aE repeat task.wait(math.min(0.1,math.max(0,aG-os.clock())))until os.clock()>=aG
or not autoWinAlive(aF)return autoWinAlive(aF)end local function restoreAutoWinAnchor()if aC and aC.Parent then aC.Anchored=aD==true end aC=nil aD=nil end local function cancelAutoWin(aE)local aF=aB
aA=aA+1 aB=false restoreAutoWinAnchor()if aF and not aE then notify('Vit\u{f3}ria Autom\u{e1}tica','Rota cancelada.')end end z.autoWin=cancelAutoWin local function setAutoWinRoot(aE,aF)if not
autoWinAlive(aF)then return false end local aG=getRoot(nil,5)if not aG or not autoWinAlive(aF)then return false end local aH=pcall(function()aG.CFrame=aE aG.AssemblyLinearVelocity=Vector3.zero aG.
AssemblyAngularVelocity=Vector3.zero end)return aH end local function setAutoWinSitting(aE,aF)if not autoWinAlive(aF)then return false end local aG=getHumanoid(nil,5)if not aG or not autoWinAlive(aF)
then return false end aG.Sit=aE return true end local function startAutoWin()if aB then notify('Vit\u{f3}ria Autom\u{e1}tica','A rota j\u{e1} est\u{e1} em andamento.')return end
stopCartControllersForTeleport(true)aA=aA+1 local aE=aA aB=true notify('Vit\u{f3}ria Autom\u{e1}tica','Rota antiga iniciada; n\u{e3}o feche o menu.')task.spawn(function()local function abort(aF)if aE
~=aA then return end cancelAutoWin(true)if aF and not n then notify('Vit\u{f3}ria Autom\u{e1}tica',aF)end end if not teleportCharacter(CFrame.new(-430.898926,165.25,101.645676,1,1.51719295e-8,-
1.24212969e-14,-1.51719295e-8,1,-1.1467514699999999e-9,1.24038988e-14,1.1467514699999999e-9,1))then abort('N\u{e3}o foi poss\u{ed}vel iniciar a rota.')return end if not waitAutoWin(4.1,aE)then return
end if not setAutoWinRoot(CFrame.new(-430.898529,163.273926,131.145554,1,-2.85942061e-8,2.0407586e-7,2.85942079e-8,1,-1.0792735599999999e-8,-2.0407586e-7,1.07927409e-8,1),aE)then abort(
'Personagem perdido durante a rota.')return end if not waitAutoWin(10,aE)then return end if not setAutoWinSitting(true,aE)then abort('Humanoid n\u{e3}o encontrado.')return end if not waitAutoWin(33,aE
)then return end if not setAutoWinSitting(false,aE)then abort('Humanoid n\u{e3}o encontrado.')return end if not waitAutoWin(2,aE)then return end if not setAutoWinRoot(CFrame.new(-500.748535,-21.78265,
-302.303406,0,0,1,0,-1,0,1,0,0),aE)then abort('N\u{e3}o foi poss\u{ed}vel entrar na segunda etapa.')return end if not waitAutoWin(0.1,aE)then return end local aF=getRoot(nil,5)if not aF or not
autoWinAlive(aE)then abort('HumanoidRootPart n\u{e3}o encontrado.')return end aC=aF aD=aF.Anchored aF.Anchored=true if not waitAutoWin(1.3,aE)then return end restoreAutoWinAnchor()if not waitAutoWin(
0.6,aE)then return end if not setAutoWinRoot(CFrame.new(-470.360138,-21.1945782,-302.303101,0,0,1,0,-1,0,1,0,0),aE)then abort('N\u{e3}o foi poss\u{ed}vel continuar a segunda etapa.')return end if not
waitAutoWin(10,aE)then return end if not setAutoWinSitting(true,aE)then abort('Humanoid n\u{e3}o encontrado.')return end if not waitAutoWin(35,aE)then return end if not setAutoWinSitting(false,aE)then
abort('Humanoid n\u{e3}o encontrado.')return end if not waitAutoWin(0.5,aE)then return end if not setAutoWinRoot(CFrame.new(-421.770264,-44.2260475,-297.081909,0.999515891,6.59387993e-8,0.0311128739,-
6.60972859e-8,1,4.06536627e-9,-0.0311128739,-6.11987483e-9,0.999515891),aE)then abort('N\u{e3}o foi poss\u{ed}vel concluir a rota.')return end if aE==aA then aB=false restoreAutoWinAnchor()notify(
'Vit\u{f3}ria Autom\u{e1}tica','Rota conclu\u{ed}da.')end end)end local aE=ac:NewTab('Teleporte'):NewSection('Teleportes')aE:NewButton('In\u{ed}cio','Teleporta para o in\u{ed}cio da trilha.',function(
)if teleportCharacter(CFrame.new(1,3.11,38))then notify('Teleporte','Teleportado para o in\u{ed}cio.')end end)aE:NewButton('Bot\u{e3}o de Carrinho','Teleporta para o bot\u{e3}o do carrinho.',function(
)if teleportCharacter(CFrame.new(-33,3.11,21.5)*CFrame.Angles(0,math.rad(180),0))then notify('Teleporte','Teleportado para o bot\u{e3}o.')end end)aE:NewButton('Equipe Suffering',
'Teleporta para a \u{e1}rea Suffering.',function()if teleportCharacter(CFrame.new(-416.844727,163.402969,171.087555,0.0174489655,5.45878223e-8,0.99984777,-4.55684486e-8,1,-5.38008926e-8,-0.99984777,-
4.46227411e-8,0.0174489655))then notify('Teleporte','Teleportado para Suffering.')end end)aE:NewButton('Ins\u{ed}gnia Secreta','Teleporta para a Secret Badge da refer\u{ea}ncia.',function()if
teleportCharacter(CFrame.new(234.500259,2.28650475,296.495483))then notify('Teleporte','Teleportado para a ins\u{ed}gnia secreta.')end end)aE:NewButton('Sala Secreta','Procura Workspace.Misc.Giver.',
function()local aF=workspace:FindFirstChild('Misc')local aG=aF and aF:FindFirstChild('Giver')local aH=aG and(aG:IsA('BasePart')and aG or aG:FindFirstChildWhichIsA('BasePart',true))if not aH then
notify('Teleporte','Misc.Giver n\u{e3}o encontrado.')return end if teleportPlayerOrCart(aH.CFrame*CFrame.new(0,3,0))then notify('Teleporte','Teleportado para a sala secreta.')end end)aE:NewButton(
'Vit\u{f3}ria Autom\u{e1}tica','Executa a rota completa do menu antigo.',startAutoWin)aE:NewButton('Cancelar Vit\u{f3}ria Autom\u{e1}tica','Interrompe a rota com seguran\u{e7}a.',function()
cancelAutoWin(false)end)end local aA={[1]=CFrame.new(-430.898926,164.75,101.645676)*CFrame.Angles(0,math.rad(90),0),[2]=CFrame.new(511.88,3.69,306.59)*CFrame.Angles(0,math.rad(270),0),[3]=CFrame.new(
171.09,2.78,-410.31)*CFrame.Angles(0,math.rad(90),0)}local function teleportToCheckpoint(aB)local aC=aA[aB]if aC then teleportCart(aC)end end local aB=ac:NewTab('Carrinho')local aC=aB:NewSection(
'Controle do Carrinho')ao=aC:NewToggle('Parada de Emerg\u{ea}ncia','Para e trava o carrinho.',function(aD)local aE=setPanicStop(aD)if aD and not aE then task.defer(function()ao:UpdateToggle(nil,false)
end)end end)aC:NewButton('Ir ao Checkpoint 1','NumPad 1.',function()teleportToCheckpoint(1)end)aC:NewButton('Ir ao Checkpoint 2','NumPad 2.',function()teleportToCheckpoint(2)end)aC:NewButton(
'Ir ao Checkpoint 3','NumPad 3.',function()teleportToCheckpoint(3)end)aC:NewButton('Ver Velocidade do Carrinho','Mostra studs/s na notifica\u{e7}\u{e3}o.',function()local aD=getCurrentCart()if not aD
then notify('Velocidade','Sente em um carrinho primeiro.')return end local aE=getCartPrimary(aD)if not aE then notify('Velocidade','Estrutura n\u{e3}o reconhecida.')return end local aF=aE.
AssemblyLinearVelocity.Magnitude notify('Velocidade do Cart',string.format('%.1f studs/s',aF))end)aC:NewButton('Ejetar do Carrinho','Sai do assento atual.',function()local aD=getHumanoid()if aD then
aD.Sit=false notify('Carrinho','Ejetado.')else notify('Carrinho','Personagem n\u{e3}o encontrado.')end end)local aD=aB:NewSection('Estabilizador')aD:NewToggle('Estabilizador do Carrinho',
'Mant\u{e9}m est\u{e1}vel enquanto sentado.',function(aE)Q.enabled=aE refreshStabilizer()if aE and getCurrentCart()then notify('Estabilizador','Ligado.')elseif not aE then notify('Estabilizador',
'Desligado.')end end)aD:NewTextBox('For\u{e7}a Normal','Padr\u{e3}o 2500. Enter.',function(aE)local aF=tonumber(aE)if aF and aF>0 then P.NORMAL_FORCE=aF S('For\u{e7}a Normal',aF)notify('Estabilizador'
,'For\u{e7}a normal: '..aF)else notify('Estabilizador','Digite um n\u{fa}mero maior que zero.')end end)aD:NewTextBox('For\u{e7}a em Descidas','Padr\u{e3}o 800. Enter.',function(aE)local aF=tonumber(aE
)if aF and aF>0 then P.DOWNHILL_FORCE=aF S('For\u{e7}a em Descidas',aF)notify('Estabilizador','For\u{e7}a descida: '..aF)else notify('Estabilizador','Digite um n\u{fa}mero maior que zero.')end end)aD:
NewButton('Redefinir For\u{e7}as','Volta para 2500 e 800.',function()P.NORMAL_FORCE=2500 P.DOWNHILL_FORCE=800 S('For\u{e7}a Normal',2500)S('For\u{e7}a em Descidas',800)refreshStabilizer()notify(
'Estabilizador','For\u{e7}as redefinidas.')end)local aE=ac:NewTab('Cart+'):NewSection('Boost e F\u{ed}sica')local aF=false local aG=500 local aH local aI=nil local aJ local aK=false local aL ap=
function()aF=false if aH then aH:Disconnect()aH=nil end if aI and aI.Parent then aI:Destroy()end if aK and aJ and aJ.Parent then aJ:Destroy()end aI=nil aJ=nil aK=false aL=nil end local function 
startBoost()ap()if O or A or v then notify('Boost','Indispon\u{ed}vel durante parada, voo ou Eliminador.')return false end local aM=getCurrentCart()if not aM then notify('Boost',
'Sente em um carrinho primeiro.')return false end local aN=getCartPrimary(aM)if not aN then notify('Boost','Estrutura do carrinho n\u{e3}o reconhecida.')return false end aL=aN.AssemblyRootPart or aN
local aO=aN:FindFirstChild('NothriloBoostAttachment')if not aO then aO=Instance.new('Attachment')aO.Name='NothriloBoostAttachment'aO.Parent=aN aK=true end aJ=aO local aP=Instance.new('VectorForce')aP.
Name='NothriloBoost'aP.Attachment0=aO aP.RelativeTo=Enum.ActuatorRelativeTo.World aP.ApplyAtCenterOfMass=true aP.Force=Vector3.zero aP.Parent=aN aI=aP aF=true aH=b.Heartbeat:Connect(function()local aQ
=getCurrentCart()local aR=aQ and getCartPrimary(aQ)local aS=aR and(aR.AssemblyRootPart or aR)if not aF or O or A or v or not aN.Parent or not aP.Parent or aQ~=aM or aS~=aL then ap()if an then task.
defer(function()an:UpdateToggle(nil,false)end)end return end aP.Force=aN.CFrame.LookVector*aG*aN.AssemblyMass*60 end)notify('Boost','Ligado \u{2014} for\u{e7}a '..aG..'.')return true end an=aE:
NewToggle('Boost do Carrinho','Empurra pra frente. Tecla B.',function(aM)if aM then if not startBoost()then task.defer(function()an:UpdateToggle(nil,false)end)end else ap()notify('Boost','Desligado.')
end end)aE:NewSlider('For\u{e7}a do Boost','Intensidade (padr\u{e3}o 500).',3000,0,500,function(aM)aG=aM if aF and not startBoost()then task.defer(function()an:UpdateToggle(nil,false)end)end end)local
aM=false local aN local aO={antiFlipReadyAt=0,autobrakeHoldUntil=0,autobrakeReadyAt=0}aE:NewToggle('Anti-Flip','Endireita o carrinho ao tombar automaticamente.',function(aP)aM=aP if aN then aN:
Disconnect()aN=nil end aO.antiFlipReadyAt=0 if not aP then notify('Anti-Flip','Desligado.')return end aN=b.Heartbeat:Connect(function()if not aM or O or A or v or os.clock()<x or os.clock()<aO.
antiFlipReadyAt then return end local aQ=getCurrentCart()if not aQ then return end local aR=getCartPrimary(aQ)if not aR or not aR.Parent then return end local aS=aR.CFrame.UpVector:Dot(Vector3.new(0,1
,0))if aS<0.5 then aO.antiFlipReadyAt=os.clock()+1.5 if aF then ap()if an then task.defer(function()an:UpdateToggle(nil,false)end)end end local aT=aR.CFrame.Position local aU=Vector3.new(aR.CFrame.
LookVector.X,0,aR.CFrame.LookVector.Z)aU=aU.Magnitude>0.01 and aU.Unit or Vector3.new(1,0,0)local aV=pivotCartByReference(aQ,CFrame.new(aT+Vector3.new(0,2,0),aT+Vector3.new(0,2,0)+aU))if aV then
notify('Anti-Flip','Carrinho endireitado.')end end end)notify('Anti-Flip','Ligado.')end)local aP=false local aQ aE:NewToggle('Freio Autom\u{e1}tico','Trava ao detectar queda livre.',function(aR)aP=aR
if aQ then aQ:Disconnect()aQ=nil end aO.autobrakeHoldUntil=0 aO.autobrakeReadyAt=0 if not aR then notify('Freio Autom\u{e1}tico','Desligado.')return end aQ=b.Heartbeat:Connect(function()if not aP or O
or A or v or os.clock()<x then return end local aS=getCurrentCart()if not aS then return end local aT=getCartPrimary(aS)if not aT then return end local aU=os.clock()if aU<aO.autobrakeHoldUntil then
for aV,aW in ipairs(aS:GetDescendants())do if aW:IsA('BasePart')and not aW.Anchored then pcall(function()aW.AssemblyLinearVelocity=Vector3.zero aW.AssemblyAngularVelocity=Vector3.zero end)end end
return end if aU>=aO.autobrakeReadyAt and aT.AssemblyLinearVelocity.Y<-35 then aO.autobrakeHoldUntil=aU+0.45 aO.autobrakeReadyAt=aU+1.25 if aF then ap()if an then task.defer(function()an:UpdateToggle(
nil,false)end)end end for aV,aW in ipairs(aS:GetDescendants())do if aW:IsA('BasePart')and not aW.Anchored then pcall(function()aW.AssemblyLinearVelocity=Vector3.zero aW.AssemblyAngularVelocity=Vector3
.zero end)end end notify('Freio Autom\u{e1}tico','Queda detectada \u{2014} travado.')end end)notify('Freio Autom\u{e1}tico','Ligado.')end)local aR=ac:NewTab('Extras'):NewSection(
'Movimento e F\u{ed}sica')local aS=false local aT={}local function restoreNoclip()for aU,aV in pairs(aT)do if aU and aU.Parent then aU.CanCollide=aV end end table.clear(aT)end trackConnection(b.
Stepped:Connect(function()if not aS then return end local aU=f.Character if not aU then return end for aV,aW in ipairs(aU:GetDescendants())do if aW:IsA('BasePart')then if aT[aW]==nil then aT[aW]=aW.
CanCollide end aW.CanCollide=false end end end))aR:NewToggle('Noclip','Atravessa paredes durante o teste.',function(aU)aS=aU if not aU then restoreNoclip()end notify('Noclip',aU and'Ligado.'or
'Desligado.')end)local aU=false local aV={}local function setLocalInvisible(aW)local aX=f.Character if not aX then return end for aY,aZ in ipairs(aX:GetDescendants())do if aZ:IsA('BasePart')or aZ:IsA(
'Decal')then if aW and aV[aZ]==nil then aV[aZ]=aZ.LocalTransparencyModifier end aZ.LocalTransparencyModifier=aW and 1 or(aV[aZ]or 0)end end if not aW then table.clear(aV)end end aR:NewToggle(
'Invis\u{ed}vel (local)','S\u{f3} voc\u{ea} se v\u{ea} transparente.',function(aW)aU=aW setLocalInvisible(aW)notify('Invis\u{ed}vel',aW and'Ligado (s\u{f3} voc\u{ea} v\u{ea}).'or'Desligado.')end)
trackConnection(f.CharacterAdded:Connect(function()task.wait(0.25)if aU and not n then setLocalInvisible(true)end end))aR:NewSlider('Jump Power','Altura do pulo (padr\u{e3}o 50).',300,0,50,function(aW
)s=aW t=7.2*(aW/50)local aX=getHumanoid()if aX and not ar then if aX.UseJumpPower then aX.JumpPower=s else aX.JumpHeight=t end end end)aR:NewButton('Redefinir Jump Power','Volta para 50.',function()s=
50 t=7.2 local aW=getHumanoid()if aW and not ar then if aW.UseJumpPower then aW.JumpPower=s else aW.JumpHeight=t end end notify('Jump Power','Redefinido.')end)aR:NewSlider('Gravidade',
'Gravidade global (padr\u{e3}o 196.2).',400,0,p,function(aW)workspace.Gravity=aW end)aR:NewButton('Redefinir Gravidade','Volta ao valor original do jogo.',function()workspace.Gravity=p notify(
'Gravidade','Valor original restaurado.')end)local aW=nil aR:NewButton('Salvar Posi\u{e7}\u{e3}o Atual','Salva onde voc\u{ea} est\u{e1}.',function()local aX=getRoot()if not aX then notify(
'Posi\u{e7}\u{e3}o','Personagem n\u{e3}o encontrado.')return end aW=aX.CFrame local aY=aX.Position notify('Posi\u{e7}\u{e3}o',string.format('Salva em %.0f, %.0f, %.0f',aY.X,aY.Y,aY.Z))end)aR:
NewButton('Voltar \u{e0} Posi\u{e7}\u{e3}o Salva','Teleporta de volta.',function()if not aW then notify('Posi\u{e7}\u{e3}o','Nenhuma posi\u{e7}\u{e3}o salva ainda.')return end if teleportPlayerOrCart(
aW)then notify('Posi\u{e7}\u{e3}o','Teleportado.')end end)local aX=ac:NewTab('Mapa'):NewSection('Explora\u{e7}\u{e3}o')aX:NewTextBox('Ir at\u{e9} Parte','Nome da parte no workspace. Enter.',function(
aY)aY=aY:match('^%s*(.-)%s*$'):lower()if aY==''then return end local aZ,a_=nil,0 for a0,a1 in ipairs(workspace:GetDescendants())do if a1:IsA('BasePart')then local a2=a1.Name:lower()local a3=0 if a2==
aY then a3=3 elseif a2:sub(1,#aY)==aY then a3=2 elseif a2:find(aY,1,true)then a3=1 end if a3>a_ then aZ=a1 a_=a3 end end end if not aZ then notify('Mapa',"Parte '"..aY.."' n\u{e3}o encontrada.")return
end teleportCharacter(aZ.CFrame*CFrame.new(0,4,0))notify('Mapa','Teleportado para: '..aZ.Name)end)aX:NewButton('Listar Partes no Output (F9)','Imprime 30 BaseParts no console.',function()print(
'[Nothrilo] === BaseParts no Workspace ===')local aY=0 for aZ,a_ in ipairs(workspace:GetDescendants())do if a_:IsA('BasePart')and aY<30 then print(('[Nothrilo] %s  pos: %s'):format(a_:GetFullName(),
tostring(a_.Position)))aY=aY+1 end end print(('[Nothrilo] %d partes listadas. Abra F9 para ver.'):format(aY))notify('Mapa',aY..' partes no output (F9).')end)local function findNearestCartSeat()local
aY=getRoot()if not aY then return nil end for aZ,a_ in ipairs({'VehicleSeat','Seat'})do local a0,a1=nil,math.huge for a2,a3 in ipairs(workspace:GetDescendants())do if a3:IsA(a_)then local a4=(aY.
Position-a3.Position).Magnitude if a4<a1 then a0=a3 a1=a4 end end end if a0 then return a0 end end return nil end aX:NewButton('Ir ao Carrinho','Procura o assento do carrinho mais pr\u{f3}ximo.',
function()local aY=findNearestCartSeat()if not aY then notify('Carrinho','Nenhum assento de carrinho foi encontrado.')return end if teleportCharacter(aY.CFrame*CFrame.new(0,4,0))then notify('Carrinho'
,'Teleportado para o carrinho.')end end)local aY=false local aZ local a_=1 local a0 local function stopFreecam()aY=false if aZ then aZ:Disconnect()aZ=nil end releaseCameraMode('freecam')end z.freecam=
function()if a0 then a0:UpdateToggle(nil,false)else stopFreecam()end end a0=aX:NewToggle('C\u{e2}mera Livre','WASD move, Q/E sobe e desce.',function(a1)if not a1 then stopFreecam()notify(
'C\u{e2}mera Livre','Desligada.')return end claimCameraMode('freecam')aY=true local a2=workspace.CurrentCamera if not a2 then stopFreecam()task.defer(function()a0:UpdateToggle(nil,false)end)return end
a2.CameraType=Enum.CameraType.Scriptable local a3=a2.CFrame aZ=b.RenderStepped:Connect(function()if not aY then return end local a4=workspace.CurrentCamera if not a4 then return end if a4~=a2 then a2=
a4 end if a2.CameraType~=Enum.CameraType.Scriptable then a2.CameraType=Enum.CameraType.Scriptable end local a5=Vector3.zero if c:IsKeyDown(Enum.KeyCode.W)then a5=a5+a3.LookVector end if c:IsKeyDown(
Enum.KeyCode.S)then a5=a5-a3.LookVector end if c:IsKeyDown(Enum.KeyCode.A)then a5=a5-a3.RightVector end if c:IsKeyDown(Enum.KeyCode.D)then a5=a5+a3.RightVector end if c:IsKeyDown(Enum.KeyCode.E)then
a5=a5+Vector3.new(0,1,0)end if c:IsKeyDown(Enum.KeyCode.Q)then a5=a5-Vector3.new(0,1,0)end if a5.Magnitude>0 then a3=CFrame.new(a3.Position+a5*a_)*(a3-a3.Position)end a2.CFrame=a3 a2.Focus=a3*CFrame.
new(0,0,-12)end)notify('C\u{e2}mera Livre','WASD move, Q/E sobe e desce. Desative para voltar.')end)aX:NewSlider('Velocidade da C\u{e2}mera Livre','Velocidade de movimento (1\u{2013}10).',10,1,a_,
function(a1)a_=a1 end)local a1=ac:NewTab('Eliminador'):NewSection('Killer \u{2022} GR\u{c1}TIS \u{2713}')local a2=''a1:NewTextBox('Nome do Alvo','Digite parte do nome e pressione Enter.',function(a3)
a2=a3 end)a1:NewButton('Alcan\u{e7}ar Alvo','Usa o carrinho livre mais pr\u{f3}ximo contra o alvo.',function()if not a2 or a2:match('^%s*$')then notify('Eliminador',
'Digite parte do nome e pressione Enter.')return end local a3=a2 task.spawn(function()local a4,a5=xpcall(function()executeKiller(a3)end,function(a4)local a5=debug if type(a5)=='table'and type(a5.
traceback)=='function'then local a6,a7=pcall(a5.traceback,tostring(a4),2)if a6 then return a7 end end return tostring(a4)end)if not a4 then warn(g..' Killer: '..a5)if v then finishKiller(
'Erro na tentativa. Tente de novo.')end end end)end)local a3=ac:NewTab('Troll'):NewSection('Divers\u{e3}o')local a4=5 local a5 local function stopSpin(a6)if a5 then a5:Disconnect()a5=nil end
releaseCameraMode('spin')if not a6 then notify('Troll','C\u{e2}mera voltou ao normal.')end end z.spin=function()stopSpin(true)end a3:NewButton('C\u{e2}mera Girat\u{f3}ria',
'Gira a c\u{e2}mera por alguns segundos.',function()stopSpin(true)claimCameraMode('spin')local a6=workspace.CurrentCamera if not a6 then releaseCameraMode('spin')return end a6.CameraType=Enum.
CameraType.Scriptable local a7=os.clock()local a8=a6.CFrame a5=b.RenderStepped:Connect(function()local a9=os.clock()-a7 if a9>=a4 then stopSpin(false)return end local ba=workspace.CurrentCamera if not
ba then return end if ba~=a6 then a6=ba end if a6.CameraType~=Enum.CameraType.Scriptable then a6.CameraType=Enum.CameraType.Scriptable end local bb=a9*math.pi*2 a6.CFrame=CFrame.new(a8.Position)*
CFrame.Angles(0,bb,0)*CFrame.new(0,0,-10)a6.Focus=CFrame.new(a8.Position)end)notify('Troll','C\u{e2}mera girando por '..a4..'s.')end)a3:NewSlider('Dura\u{e7}\u{e3}o C\u{e2}mera (s)',
'Segundos de giro.',30,1,a4,function(a6)a4=a6 end)local a6=2 local function restoreFakeLag()local a7=at ar=false if a7 and a7.Parent then a7.WalkSpeed=au or 16 if a7.UseJumpPower then a7.JumpPower=s
or 50 else a7.JumpHeight=t or 7.2 end end at=nil end a3:NewButton('Fake Lag','Congela voc\u{ea} por alguns segundos.',function()local a7=getHumanoid()if not a7 then return end if not ar then au=au or
a7.WalkSpeed s=s or a7.JumpPower t=t or a7.JumpHeight elseif at~=a7 then restoreFakeLag()end as=as+1 local a8=as ar=true at=a7 a7.WalkSpeed=0 if a7.UseJumpPower then a7.JumpPower=0 else a7.JumpHeight=
0 end notify('Troll','Fake lag por '..a6..'s.')task.spawn(function()task.wait(a6)if a8~=as or n then return end restoreFakeLag()notify('Troll','Fake lag encerrado.')end)end)a3:NewSlider(
'Dura\u{e7}\u{e3}o Fake Lag (s)','Dura\u{e7}\u{e3}o em segundos.',15,1,a6,function(a7)a6=a7 end)local a7=false local a8 local function stopSpectate(a9)a7=false if a8 then a8:Disconnect()a8=nil end
releaseCameraMode('spectate')if not a9 then notify('Spectate','Parado.')end end z.spectate=function()stopSpectate(true)end a3:NewTextBox('Spectate Jogador','Nome do jogador. Enter para seguir.',
function(a9)local ba=findPlayerByPartialName(a9)if not ba or ba==f then notify('Spectate','Escolha outro jogador.')return end stopSpectate(true)claimCameraMode('spectate')a7=true local bb=workspace.
CurrentCamera if not bb then stopSpectate(true)return end bb.CameraType=Enum.CameraType.Scriptable a8=b.RenderStepped:Connect(function()if not a7 then return end local bc=workspace.CurrentCamera if
not bc then return end if bc~=bb then bb=bc end if bb.CameraType~=Enum.CameraType.Scriptable then bb.CameraType=Enum.CameraType.Scriptable end local bd=ba.Character local be=bd and bd:FindFirstChild(
'HumanoidRootPart')if not be then stopSpectate(false)return end bb.CFrame=CFrame.new(be.Position+Vector3.new(0,8,-14),be.Position)bb.Focus=CFrame.new(be.Position)end)notify('Spectate','Seguindo '..ba.
DisplayName..'.')end)a3:NewButton('Parar Spectate','Para de seguir.',function()stopSpectate(false)end)a3:NewButton('Teleporte Aleat\u{f3}rio','Te joga em uma parte aleat\u{f3}ria.',function()local a9=
{}for ba,bb in ipairs(workspace:GetDescendants())do if bb:IsA('BasePart')and bb.Transparency<0.9 and bb.Size.Magnitude>2 and bb~=workspace.Terrain then table.insert(a9,bb)end end if#a9==0 then notify(
'Troll','Nenhuma parte \u{fa}til encontrada.')return end local ba=a9[math.random(1,#a9)]teleportCharacter(ba.CFrame*CFrame.new(0,5,0))notify('Troll','Caiu em: '..ba.Name)end)local function findMenuGui
()local a9 for ba,bb in ipairs(l)do for bc,bd in ipairs(bb:GetChildren())do if bd:IsA('ScreenGui')then local be=bd:FindFirstChild('Main',true)local bf=be and be:FindFirstChild('MainHeader')local bg=bf
and bf:FindFirstChild('title')if bg and bg:IsA('TextLabel')and bg.Text==h then return bd end if be and bf then a9=bd end for bh,bi in ipairs(bd:GetDescendants())do if bi:IsA('TextLabel')and bi.Text==h
then return bd end end end end end return a9 end local a9=ac and ac.gui or findMenuGui()if not bootstrapAlive()then abortBootstrap()return end local ba if not a9 then warn(g..
': n\u{e3}o foi poss\u{ed}vel localizar a janela cl\u{e1}ssica local.')a9=Instance.new('ScreenGui')a9.Name='NothriloFallbackHost'a9.ResetOnSpawn=false a9.Parent=k end av=function(bb)for bc,bd in
ipairs(a9:GetDescendants())do if bd:IsA('TextButton')and bd.Name=='textboxElement'then local be=bd:FindFirstChild('togName')local bf=bd:FindFirstChildOfClass('TextBox')if be and be.Text==bb and bf
then return bf end end end return nil end S=function(bb,bc)task.delay(0.22,function()local bd=av(bb)if bd and bd.Parent then bd.Text=tostring(bc)end end)end local function configureKavoTextBox(bb,bc,
bd)local be=av(bb)if not be then return end be.PlaceholderText=bc if bd~=nil then be.Text=tostring(bd)end end for bb,bc in ipairs(a9:GetDescendants())do if bc:IsA('TextBox')and bc.PlaceholderText==
'Type here!'then bc.PlaceholderText='Digite aqui...'end end configureKavoTextBox('Ir at\u{e9} Jogador','Nome ou come\u{e7}o do nome',nil)configureKavoTextBox('Velocidade do Voo','Digite a velocidade',
nil)configureKavoTextBox('Nome do Alvo','Nome ou come\u{e7}o do nome',nil)configureKavoTextBox('For\u{e7}a Normal','2500',2500)configureKavoTextBox('For\u{e7}a em Descidas','800',800)local bb={}local 
function addShortcutBadge(bc,bd)if c.TouchEnabled then return end for be,bf in ipairs(a9:GetDescendants())do if bf:IsA('TextButton')then local bg for bh,bi in ipairs(bf:GetDescendants())do if bi:IsA(
'TextLabel')and bi.Text==bc then bg=bi break end end if bg and not bf:FindFirstChild('NothriloShortcut_'..bd)then local bh=bd=='1/2/3'and 42 or 21 local bi=Instance.new('TextButton')bi.Name=
'NothriloShortcut_'..bd bi.Size=UDim2.fromOffset(bh,21)bi.Position=UDim2.new(1,-(bh+31),0,6)bi.BackgroundColor3=Color3.fromRGB(30,30,37)bi.BorderSizePixel=0 bi.AutoButtonColor=false bi.Font=Enum.Font.
GothamBold bi.Text=bd bi.TextColor3=r.SchemeColor bi.TextSize=bd=='1/2/3'and 9 or 12 bi.ZIndex=3 bi.Parent=bf Instance.new('UICorner',bi).CornerRadius=UDim.new(0,7)table.insert(bb,bi)if bg.Parent==bf
then bg.Size=UDim2.new(1,-(bh+70),1,0)end bi.Activated:Connect(function()if bd=='V'then am:UpdateToggle(nil,not al)elseif bd=='L'then U:UpdateToggle(nil,not ag)elseif bd=='P'then V:UpdateToggle(nil,
not T)elseif bd=='T'then giveClickTeleportTool()elseif bd=='1'then teleportToCheckpoint(1)elseif bd=='2'then teleportToCheckpoint(2)elseif bd=='3'then teleportToCheckpoint(3)elseif bd=='1/2/3'then
notify('Checkpoints','Use NumPad 1, 2 ou 3.')elseif bd=='B'then an:UpdateToggle(nil,not aF)elseif bd=='K'then aq(false)elseif bd=='X'and m then m()end end)return end end end end addShortcutBadge(
'Voo do Ve\u{ed}culo','V')addShortcutBadge('ESP','L')addShortcutBadge('Pulo Infinito','P')addShortcutBadge('Teleporte por Clique','T')addShortcutBadge('Boost do Carrinho','B')addShortcutBadge(
'Ir ao Checkpoint 1','1')addShortcutBadge('Ir ao Checkpoint 2','2')addShortcutBadge('Ir ao Checkpoint 3','3')local bc=Instance.new('ScreenGui')bc.Name='NothriloNotifications'bc.ResetOnSpawn=false bc.
IgnoreGuiInset=true bc.DisplayOrder=10001 bc.Parent=a9.Parent ad=Instance.new('Frame')ad.Name='ToastContainer'ad.AnchorPoint=Vector2.new(1,0)ad.Position=UDim2.new(1,-18,0,20)ad.Size=UDim2.fromOffset(
300,300)ad.BackgroundTransparency=1 ad.Parent=bc do local bd=Instance.new('UIListLayout')bd.Padding=UDim.new(0,8)bd.SortOrder=Enum.SortOrder.LayoutOrder bd.Parent=ad end local function enableDrag(bd,
be,bf)bd.Active=true be.Active=true local bg,bh,bi,bj,bk=false,nil,nil,nil,false local function updatePos(bl)local bm=bl.Position-bi if bm.Magnitude>6 then bk=true end bd.Position=UDim2.new(bj.X.Scale
,bj.X.Offset+bm.X,bj.Y.Scale,bj.Y.Offset+bm.Y)end be.InputBegan:Connect(function(bl)if bl.UserInputType~=Enum.UserInputType.MouseButton1 and bl.UserInputType~=Enum.UserInputType.Touch then return end
bg=true bk=false bi=bl.Position bj=bd.Position bl.Changed:Connect(function()if bl.UserInputState==Enum.UserInputState.End then bg=false if bf then bf(bk)end end end)end)be.InputChanged:Connect(
function(bl)if bl.UserInputType==Enum.UserInputType.MouseMovement or bl.UserInputType==Enum.UserInputType.Touch then bh=bl end end)trackConnection(c.InputChanged:Connect(function(bl)if bg and bl==bh
then updatePos(bl)end end))end local bd=Instance.new('ScreenGui')bd.Name='NothriloLauncher'bd.ResetOnSpawn=false bd.IgnoreGuiInset=true bd.DisplayOrder=10000 bd.Parent=a9.Parent local be=Instance.new(
'TextButton')be.Name='OpenNothriloMenu'be.Size=UDim2.fromOffset(178,50)be.Position=UDim2.new(0,16,0.5,-25)be.BackgroundColor3=Color3.fromRGB(10,10,12)be.BorderSizePixel=0 be.AutoButtonColor=false be.
Font=Enum.Font.GothamBold be.Text=string.upper(g)be.TextColor3=Color3.fromRGB(255,255,255)be.TextSize=15 be.TextXAlignment=Enum.TextXAlignment.Left be.Visible=false be.Parent=bd Instance.new(
'UICorner',be).CornerRadius=UDim.new(0,18)do local bf=Instance.new('UIPadding')bf.PaddingLeft=UDim.new(0,52)bf.PaddingRight=UDim.new(0,10)bf.Parent=be end local bf=Instance.new('UIStroke')bf.Thickness
=1.5 bf.Parent=be local bg=Instance.new('TextLabel')bg.BackgroundColor3=Color3.fromRGB(26,26,33)bg.BackgroundTransparency=0 bg.Size=UDim2.fromOffset(36,36)bg.Position=UDim2.fromOffset(7,7)bg.Font=Enum
.Font.GothamBold bg.Text='N'bg.TextColor3=Color3.fromRGB(255,255,255)bg.TextSize=18 bg.Parent=be Instance.new('UICorner',bg).CornerRadius=UDim.new(1,0)aq=function(bh)if n then return end a9.Enabled=bh
be.Visible=not bh end do local bh=a9:FindFirstChild('Main')local bi=bh and bh:FindFirstChild('MainHeader')local bj=bi and bi:FindFirstChild('close')if bj then bj.Visible=false bj.Active=false end if
bi then local bk=Instance.new('TextButton')bk.Name='Minimize'bk.Size=UDim2.fromOffset(30,30)bk.Position=UDim2.new(1,-32,0,2)bk.BackgroundColor3=Color3.fromRGB(28,28,34)bk.BackgroundTransparency=0.2 bk
.AutoButtonColor=false bk.Font=Enum.Font.GothamBold bk.Text='\u{2014}'bk.TextColor3=Color3.fromRGB(255,255,255)bk.TextSize=17 bk.Parent=bi Instance.new('UICorner',bk).CornerRadius=UDim.new(0,10)bk.
MouseButton1Click:Connect(function()aq(false)end)enableDrag(bh,bi)end end local bh=0 enableDrag(be,be,function(bi)if bi then bh=os.clock()end end)be.Activated:Connect(function()if os.clock()-bh<0.25
then return end aq(true)end)trackConnection(c.InputBegan:Connect(function(bi,bj)if n or bj or c:GetFocusedTextBox()then return end if bi.KeyCode==Enum.KeyCode.V then am:UpdateToggle(nil,not al)elseif
bi.KeyCode==Enum.KeyCode.L then U:UpdateToggle(nil,not ag)elseif bi.KeyCode==Enum.KeyCode.P then V:UpdateToggle(nil,not T)elseif bi.KeyCode==Enum.KeyCode.T then giveClickTeleportTool()elseif bi.
KeyCode==Enum.KeyCode.B then an:UpdateToggle(nil,not aF)elseif bi.KeyCode==Enum.KeyCode.KeypadOne then teleportToCheckpoint(1)elseif bi.KeyCode==Enum.KeyCode.KeypadTwo then teleportToCheckpoint(2)
elseif bi.KeyCode==Enum.KeyCode.KeypadThree then teleportToCheckpoint(3)elseif bi.KeyCode==Enum.KeyCode.K then aq(not a9.Enabled)elseif bi.KeyCode==Enum.KeyCode.X then m()end end))local bi=true m=
function()if n then return end n=true bi=false v=false w=w+1 if z.autoWin then z.autoWin(true)end z.restoreSession=(z.restoreSession or 0)+1 T=false as=as+1 restoreFakeLag()stopSpin(true)stopSpectate(
true)stopFreecam()aS=false restoreNoclip()aU=false setLocalInvisible(false)aw=false if Y then Y:Disconnect()Y=nil end restoreGodHumanoid()ay=false if az then az:Disconnect()az=nil end stopFly()ap()ag=
false ak=ak+1 clearESP()Q.enabled=false cleanupStabilizer()restorePanicStop()workspace.Gravity=p aM=false aP=false aO.antiFlipReadyAt=0 aO.autobrakeHoldUntil=0 aO.autobrakeReadyAt=0 if aN then aN:
Disconnect()aN=nil end if aQ then aQ:Disconnect()aQ=nil end y=nil restoreDefaultCamera()for bj=#o,1,-1 do local bk=o[bj]pcall(function()bk:Disconnect()end)o[bj]=nil end for bj=#u,1,-1 do local bk=u[bj
]if bk and bk.Parent then bk:Destroy()end u[bj]=nil end if I and I.Parent then I:Destroy()end if bc and bc.Parent then bc:Destroy()end if bd and bd.Parent then bd:Destroy()end if a9 and a9.Parent then
a9:Destroy()end if q and q.Parent then q:Destroy()end end do local bj=ac:NewTab('Comandos'):NewSection('Atalhos')ba=a9:FindFirstChild('ComandosTabButton',true)bj:NewButton(
'V  \u{2022}  Voo do Ve\u{ed}culo','Tecla V',function()am:UpdateToggle(nil,not al)end)bj:NewButton('L  \u{2022}  ESP','Tecla L',function()U:UpdateToggle(nil,not ag)end)bj:NewButton(
'P  \u{2022}  Pulo Infinito','Tecla P',function()V:UpdateToggle(nil,not T)end)bj:NewButton('T  \u{2022}  Teleporte por Clique','Tecla T',giveClickTeleportTool)bj:NewButton(
'B  \u{2022}  Boost do Carrinho','Tecla B',function()an:UpdateToggle(nil,not aF)end)bj:NewButton('NumPad 1/2/3  \u{2022}  Checkpoints','Teclado num\u{e9}rico',function()notify('Checkpoints',
'Use NumPad 1, 2 ou 3.')end)bj:NewButton('K  \u{2022}  Minimizar / Abrir','Tecla K',function()aq(false)end)bj:NewButton('X  \u{2022}  Fechar o Nothrilo','Tecla X',m)end addShortcutBadge(
'V  \u{2022}  Voo do Ve\u{ed}culo','V')addShortcutBadge('L  \u{2022}  ESP','L')addShortcutBadge('P  \u{2022}  Pulo Infinito','P')addShortcutBadge('T  \u{2022}  Teleporte por Clique','T')
addShortcutBadge('B  \u{2022}  Boost do Carrinho','B')addShortcutBadge('NumPad 1/2/3  \u{2022}  Checkpoints','1/2/3')addShortcutBadge('K  \u{2022}  Minimizar / Abrir','K')addShortcutBadge(
'X  \u{2022}  Fechar o Nothrilo','X')task.delay(0.3,function()if not a9 or not a9.Parent then return end addShortcutBadge('V  \u{2022}  Voo do Ve\u{ed}culo','V')addShortcutBadge('L  \u{2022}  ESP','L'
)addShortcutBadge('P  \u{2022}  Pulo Infinito','P')addShortcutBadge('T  \u{2022}  Teleporte por Clique','T')addShortcutBadge('B  \u{2022}  Boost do Carrinho','B')addShortcutBadge(
'NumPad 1/2/3  \u{2022}  Checkpoints','1/2/3')addShortcutBadge('K  \u{2022}  Minimizar / Abrir','K')addShortcutBadge('X  \u{2022}  Fechar o Nothrilo','X')end)do local bj=ac:NewTab('Interface'):
NewSection('Interface')bj:NewButton('Fechar Menu','Fecha agora; a tecla X tamb\u{e9}m funciona.',m)end addShortcutBadge('Fechar Menu','X')if not bootstrapAlive()then abortBootstrap()return end a9.
Enabled=false if os.clock()<aa.beganAt+aa.seconds then if aa.status then aa.status.Text='Fun\u{e7}\u{f5}es prontas \u{2022} terminando carregamento seguro...'end repeat b.RenderStepped:Wait()if not
bootstrapAlive()then abortBootstrap()return end until os.clock()>=aa.beganAt+aa.seconds end if aa.gui and aa.gui.Parent then aa.gui:Destroy()end a9.Enabled=true task.spawn(function()while bi and not n
and a9.Parent and bd.Parent do local bj=Color3.fromHSV((os.clock()*0.12)%1,0.85,1)ab:ChangeColor('SchemeColor',bj)if ba and ba.Parent then ba.BackgroundColor3=bj end bf.Color=bj bg.TextColor3=bj for
bk=#bb,1,-1 do local bl=bb[bk]if bl and bl.Parent then bl.TextColor3=bj else table.remove(bb,bk)end end for bk=#ae,1,-1 do local bl=ae[bk]if bl and bl.Parent then bl.Color=bj else table.remove(ae,bk)
end end task.wait(0.3)end end)notify(g,'Feito por Cafezl  \u{2022}  K minimiza e reabre o menu.')

