--[[
    JarotUI Library
    Version : 1.0
    Style   : JAROT v5 (dark purple, sidebar tabs, horizontal layout)

    Usage:
        local UI = loadstring(game:HttpGet("YOUR_RAW_URL"))()

        local win = UI:Window("My Script", "v1.0")

        local tab = win:Tab("[TP] Teleport", Color3.fromRGB(212,60,130))

        tab:Label("Hello world!")
        tab:Button("Click me", function() print("clicked") end)
        tab:Toggle("Auto Farm", false, function(v) print(v) end)
        tab:Slider("Speed", 1, 100, 16, function(v) print(v) end)
        tab:Separator()
        tab:Status("Running", Color3.fromRGB(50,208,98))
        tab:Input("Enter name", function(text) print(text) end)
        tab:Dropdown("Mode", {"Mode A","Mode B","Mode C"}, function(v) print(v) end)
        tab:ColorPicker("ESP Color", Color3.fromRGB(80,200,255), function(c) print(c) end)

        win:Notify("Hello!", Color3.fromRGB(188,98,255), 3)
        win:Status("Ready", Color3.fromRGB(50,208,98))
]]

-- 
-- SERVICES
-- 
local Players          = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local CoreGui          = game:GetService("CoreGui")
local RunService       = game:GetService("RunService")

local LP = Players.LocalPlayer
if not LP then Players.PlayerAdded:Wait(); LP = Players.LocalPlayer end

-- 
-- PALETTE  (exact JAROT v5 colors)
-- 
local C = {
    BG      = Color3.fromRGB(9,   8,  18),
    SIDEBAR = Color3.fromRGB(13,  11, 24),
    PANEL   = Color3.fromRGB(16,  14, 30),
    CARD    = Color3.fromRGB(22,  19, 42),
    CARD2   = Color3.fromRGB(28,  24, 52),
    BORDER  = Color3.fromRGB(58,  30, 140),
    ACC     = Color3.fromRGB(108, 52, 238),
    ACC2    = Color3.fromRGB(188, 98, 255),
    RED     = Color3.fromRGB(228, 56,  56),
    RED2    = Color3.fromRGB(148, 20,  20),
    GREEN   = Color3.fromRGB(50,  208, 98),
    GREEN2  = Color3.fromRGB(18,  128, 56),
    BLUE    = Color3.fromRGB(50,  140, 242),
    BLUE2   = Color3.fromRGB(18,   76, 178),
    PINK    = Color3.fromRGB(212,  60, 130),
    PINK2   = Color3.fromRGB(146,  18,  76),
    PURPLE  = Color3.fromRGB(160,  80, 220),
    PURPLE2 = Color3.fromRGB(90,   30, 140),
    TEXT    = Color3.fromRGB(226, 220, 246),
    SUB     = Color3.fromRGB(146, 136, 180),
    MUTED   = Color3.fromRGB(80,   72, 110),
    YELLOW  = Color3.fromRGB(252, 210,  50),
    ORANGE  = Color3.fromRGB(252, 156,  40),
    W       = Color3.new(1,1,1),
}

-- 
-- INTERNAL HELPERS
-- 
local function _rnd(p, r)
    local u = Instance.new("UICorner", p)
    u.CornerRadius = UDim.new(0, r or 10)
    return u
end

local function _brdr(p, col, th, tr)
    local s = Instance.new("UIStroke", p)
    s.Color = col or C.BORDER
    s.Thickness = th or 1.5
    s.Transparency = tr or 0.2
    return s
end

local function _grad(p, a, b, rot)
    local g = Instance.new("UIGradient", p)
    g.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, a),
        ColorSequenceKeypoint.new(1, b)
    }
    g.Rotation = rot or 90
    return g
end

local function _tw(o, props, t, sty, dir)
    return TweenService:Create(o,
        TweenInfo.new(t or 0.25,
            sty or Enum.EasingStyle.Quint,
            dir or Enum.EasingDirection.Out),
        props)
end

local function _hvr(b, normal, hover)
    b.MouseEnter:Connect(function()
        _tw(b, {BackgroundColor3=hover}, 0.18):Play()
    end)
    b.MouseLeave:Connect(function()
        _tw(b, {BackgroundColor3=normal}, 0.18):Play()
    end)
end

-- 
-- NOTIFICATION QUEUE
-- 
local NQ = {q={}, running=false}

local function _runNQ()
    if NQ.running then return end
    NQ.running = true
    task.spawn(function()
        while #NQ.q > 0 do
            pcall(function()
                local n = table.remove(NQ.q, 1)
                local vp = workspace.CurrentCamera.ViewportSize

                local g = Instance.new("ScreenGui")
                g.Name="JarotUI_Notif";g.ResetOnSpawn=false
                g.IgnoreGuiInset=true;g.DisplayOrder=99999;g.Parent=CoreGui

                local f = Instance.new("Frame", g)
                f.AnchorPoint=Vector2.new(0.5,0)
                f.Size=UDim2.new(0,math.min(360,math.floor(vp.X*0.72)),0,58)
                f.Position=UDim2.new(0.5,0,0,-70)
                f.BackgroundColor3=Color3.fromRGB(13,11,25)
                f.BorderSizePixel=0; _rnd(f,12); _brdr(f,n.col,1.5,0.2)

                local bar=Instance.new("Frame",f)
                bar.Size=UDim2.new(0,3,1,0)
                bar.BackgroundColor3=n.col;bar.BorderSizePixel=0;_rnd(bar,3)

                local ico=Instance.new("TextLabel",f)
                ico.Size=UDim2.new(0,36,1,0);ico.Position=UDim2.new(0,6,0,0)
                ico.BackgroundTransparency=1;ico.Text=n.ico or "!"
                ico.TextSize=18;ico.Font=Enum.Font.GothamBold
                ico.TextColor3=n.col
                ico.TextXAlignment=Enum.TextXAlignment.Center
                ico.TextYAlignment=Enum.TextYAlignment.Center

                local lb=Instance.new("TextLabel",f)
                lb.Size=UDim2.new(1,-46,1,0);lb.Position=UDim2.new(0,44,0,0)
                lb.BackgroundTransparency=1;lb.Text=n.msg
                lb.TextColor3=C.TEXT;lb.TextSize=13;lb.Font=Enum.Font.GothamBold
                lb.TextXAlignment=Enum.TextXAlignment.Left
                lb.TextWrapped=true;lb.TextYAlignment=Enum.TextYAlignment.Center

                _tw(f,{Position=UDim2.new(0.5,0,0,12)},0.3,Enum.EasingStyle.Quint):Play()
                task.wait(n.dur or 3.5)
                _tw(f,{Position=UDim2.new(0.5,0,0,-70)},0.28,Enum.EasingStyle.Quint):Play()
                task.wait(0.3)
                if g.Parent then g:Destroy() end
            end)
            task.wait(0.06)
        end
        NQ.running = false
    end)
end

local function _notify(msg, col, ico, dur)
    table.insert(NQ.q, {msg=msg, col=col or C.YELLOW, ico=ico or "!", dur=dur or 3.5})
    _runNQ()
end

-- 
-- WINDOW  (main entry point)
-- 
local JarotUI = {}
JarotUI.__index = JarotUI

function JarotUI:Window(title, subtitle, toggleKey)
    local self      = setmetatable({}, JarotUI)
    self._tabs      = {}    -- list of {id, lbl, acc, panel, btn}
    self._activTab  = nil
    self._minimized = false
    self._closed    = false
    self._tabOrder  = 2

    local vp  = workspace.CurrentCamera.ViewportSize
    local WW  = math.clamp(math.floor(vp.X * 0.72), 560, 820)
    local WH  = math.clamp(math.floor(vp.Y * 0.70), 420, 580)
    local SBW = 140
    local HDR = 52
    local toggleKC = toggleKey or Enum.KeyCode.RightBracket

    --  ScreenGui 
    local SG = Instance.new("ScreenGui")
    SG.Name="JarotUI";SG.ResetOnSpawn=false
    SG.IgnoreGuiInset=true;SG.DisplayOrder=200;SG.Parent=CoreGui
    self._sg = SG

    --  Main frame 
    local MF = Instance.new("Frame", SG)
    MF.Name="MainFrame";MF.AnchorPoint=Vector2.new(0.5,0)
    MF.Size=UDim2.new(0,WW,0,WH)
    MF.Position=UDim2.new(0.5,0,0.08,0)
    MF.BackgroundColor3=C.BG;MF.BorderSizePixel=0;MF.Visible=false
    _rnd(MF,14);_brdr(MF,C.BORDER,1.5,0.15)
    _grad(MF,Color3.fromRGB(15,11,28),Color3.fromRGB(7,6,13),135)
    self._mf = MF

    -- top accent strip
    local ts=Instance.new("Frame",MF)
    ts.Size=UDim2.new(1,-20,0,2);ts.Position=UDim2.new(0,10,0,0)
    ts.BackgroundColor3=C.ACC2;ts.BorderSizePixel=0;_rnd(ts,4)
    _grad(ts,C.ACC2,C.ACC,0)

    --  Header 
    local hdr=Instance.new("Frame",MF)
    hdr.Size=UDim2.new(1,0,0,HDR)
    hdr.BackgroundColor3=Color3.fromRGB(12,9,24)
    hdr.BorderSizePixel=0;_rnd(hdr,14)
    -- fill bottom corners
    local hfill=Instance.new("Frame",hdr)
    hfill.Size=UDim2.new(1,0,0,14);hfill.Position=UDim2.new(0,0,1,-14)
    hfill.BackgroundColor3=Color3.fromRGB(12,9,24);hfill.BorderSizePixel=0

    -- logo box
    local lbox=Instance.new("Frame",hdr)
    lbox.Size=UDim2.new(0,36,0,36);lbox.Position=UDim2.new(0,12,0.5,-18)
    lbox.BackgroundColor3=Color3.fromRGB(19,9,44);lbox.BorderSizePixel=0
    _rnd(lbox,10);_brdr(lbox,C.ACC,1.5,0.3)
    local ltx=Instance.new("TextLabel",lbox)
    ltx.Size=UDim2.new(1,0,1,0);ltx.BackgroundTransparency=1
    ltx.Text="[J]";ltx.TextSize=14;ltx.Font=Enum.Font.GothamBlack
    ltx.TextColor3=C.ACC2
    ltx.TextXAlignment=Enum.TextXAlignment.Center
    ltx.TextYAlignment=Enum.TextYAlignment.Center
    -- logo pulse
    task.spawn(function()
        while SG.Parent do
            _tw(ltx,{TextColor3=C.ACC},0.9,Enum.EasingStyle.Sine):Play();task.wait(0.9)
            _tw(ltx,{TextColor3=C.ACC2},0.9,Enum.EasingStyle.Sine):Play();task.wait(0.9)
        end
    end)

    -- title + subtitle
    local ttl=Instance.new("TextLabel",hdr)
    ttl.Size=UDim2.new(1,-120,0,20);ttl.Position=UDim2.new(0,54,0,8)
    ttl.BackgroundTransparency=1;ttl.Text=title or "JarotUI"
    ttl.TextColor3=C.TEXT;ttl.TextSize=16;ttl.Font=Enum.Font.GothamBlack
    ttl.TextXAlignment=Enum.TextXAlignment.Left
    self._ttl = ttl

    local subt=Instance.new("TextLabel",hdr)
    subt.Size=UDim2.new(1,-120,0,13);subt.Position=UDim2.new(0,54,0,29)
    subt.BackgroundTransparency=1
    subt.Text=(subtitle or "v1.0").."  |  ["..tostring(toggleKC).." to toggle]"
    subt.TextColor3=C.MUTED;subt.TextSize=10;subt.Font=Enum.Font.Gotham
    subt.TextXAlignment=Enum.TextXAlignment.Left

    -- header buttons
    local function mkHBtn(xOff, bg3, txt, tc)
        local b=Instance.new("TextButton",hdr)
        b.Size=UDim2.new(0,26,0,26);b.Position=UDim2.new(1,xOff,0.5,-13)
        b.BackgroundColor3=bg3;b.Text=txt;b.TextColor3=tc or C.W
        b.TextSize=13;b.Font=Enum.Font.GothamBold;b.BorderSizePixel=0;_rnd(b,7)
        return b
    end
    local minB   = mkHBtn(-72,Color3.fromRGB(25,19,46),"-",C.SUB)
    local closeB = mkHBtn(-40,Color3.fromRGB(44,12,12),"x",C.RED)
    _brdr(minB,C.MUTED,1,0.5);_brdr(closeB,C.RED,1,0.4)

    --  Body 
    local BODY_Y = HDR + 6
    local BODY_H = WH - BODY_Y - 32

    local body=Instance.new("Frame",MF)
    body.Size=UDim2.new(1,-16,0,BODY_H)
    body.Position=UDim2.new(0,8,0,BODY_Y)
    body.BackgroundTransparency=1;body.BorderSizePixel=0
    self._body = body

    -- sidebar
    local sidebar=Instance.new("ScrollingFrame",body)
    sidebar.Size=UDim2.new(0,SBW,1,0);sidebar.Position=UDim2.new(0,0,0,0)
    sidebar.BackgroundColor3=C.SIDEBAR;sidebar.BorderSizePixel=0
    sidebar.ScrollBarThickness=0
    sidebar.AutomaticCanvasSize=Enum.AutomaticSize.Y
    sidebar.CanvasSize=UDim2.new(0,0,0,0)
    sidebar.ScrollingDirection=Enum.ScrollingDirection.Y
    _rnd(sidebar,12);_brdr(sidebar,C.BORDER,1,0.6)
    local sbUL=Instance.new("UIListLayout",sidebar)
    sbUL.SortOrder=Enum.SortOrder.LayoutOrder;sbUL.Padding=UDim.new(0,4)
    local sbPad=Instance.new("UIPadding",sidebar)
    sbPad.PaddingTop=UDim.new(0,8);sbPad.PaddingBottom=UDim.new(0,8)
    sbPad.PaddingLeft=UDim.new(0,6);sbPad.PaddingRight=UDim.new(0,6)
    -- "MENU" label
    local sbLbl=Instance.new("TextLabel",sidebar)
    sbLbl.Size=UDim2.new(1,0,0,16);sbLbl.LayoutOrder=0
    sbLbl.BackgroundTransparency=1;sbLbl.Text="MENU"
    sbLbl.TextColor3=C.MUTED;sbLbl.TextSize=9;sbLbl.Font=Enum.Font.GothamBold
    sbLbl.TextXAlignment=Enum.TextXAlignment.Center
    local sbDiv=Instance.new("Frame",sidebar)
    sbDiv.Size=UDim2.new(1,0,0,1);sbDiv.BackgroundColor3=C.BORDER
    sbDiv.BorderSizePixel=0;sbDiv.BackgroundTransparency=0.6;sbDiv.LayoutOrder=1
    self._sidebar = sidebar

    -- content area
    local con=Instance.new("Frame",body)
    con.Size=UDim2.new(1,-(SBW+8),1,0);con.Position=UDim2.new(0,SBW+8,0,0)
    con.BackgroundTransparency=1;con.ClipsDescendants=false
    self._con = con

    --  Footer 
    local foot=Instance.new("Frame",MF)
    foot.Size=UDim2.new(1,-16,0,22);foot.Position=UDim2.new(0,8,1,-28)
    foot.BackgroundColor3=Color3.fromRGB(10,8,20)
    foot.BorderSizePixel=0;_rnd(foot,7)
    local fdot=Instance.new("Frame",foot)
    fdot.Size=UDim2.new(0,7,0,7);fdot.Position=UDim2.new(0,10,0.5,-3)
    fdot.BackgroundColor3=C.GREEN;fdot.BorderSizePixel=0;_rnd(fdot,4)
    local flbl=Instance.new("TextLabel",foot)
    flbl.Size=UDim2.new(1,-24,1,0);flbl.Position=UDim2.new(0,22,0,0)
    flbl.BackgroundTransparency=1;flbl.Text="Ready"
    flbl.TextColor3=C.MUTED;flbl.TextSize=10;flbl.Font=Enum.Font.Gotham
    flbl.TextXAlignment=Enum.TextXAlignment.Left
    self._fdot = fdot;self._flbl = flbl

    --  Drag 
    local dr,ds,fp=false,nil,nil
    hdr.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1
        or i.UserInputType==Enum.UserInputType.Touch then
            dr=true;ds=i.Position;fp=MF.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dr and (i.UserInputType==Enum.UserInputType.MouseMovement
            or i.UserInputType==Enum.UserInputType.Touch) then
            local d=i.Position-ds
            MF.Position=UDim2.new(fp.X.Scale,fp.X.Offset+d.X,fp.Y.Scale,fp.Y.Offset+d.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1
        or i.UserInputType==Enum.UserInputType.Touch then dr=false end
    end)

    --  Minimize 
    local FULL = UDim2.new(0,WW,0,WH)
    local MINI = UDim2.new(0,WW,0,HDR)
    minB.MouseButton1Click:Connect(function()
        self._minimized = not self._minimized
        if self._minimized then
            body.Visible=false;foot.Visible=false
            _tw(MF,{Size=MINI},0.28,Enum.EasingStyle.Quint):Play()
            minB.Text="+"
        else
            _tw(MF,{Size=FULL},0.32,Enum.EasingStyle.Quint):Play()
            task.delay(0.18,function() body.Visible=true;foot.Visible=true end)
            minB.Text="-"
        end
    end)

    --  Close 
    closeB.MouseButton1Click:Connect(function()
        if self._closed then return end
        self._closed = true
        MF.AnchorPoint=Vector2.new(0.5,0.5)
        MF.Position=UDim2.new(0.5,0,0.5,0)
        _tw(MF,{
            Position=UDim2.new(0.5,0,0.42,0),
            BackgroundTransparency=1,
            Size=UDim2.new(0,math.floor(WW*0.88),0,math.floor(WH*0.88))
        },0.22,Enum.EasingStyle.Quint):Play()
        for _,d in ipairs(MF:GetDescendants()) do pcall(function()
            if d:IsA("TextLabel") or d:IsA("TextButton") then
                _tw(d,{TextTransparency=1},0.18):Play()
            end
            if d:IsA("Frame") or d:IsA("ScrollingFrame") then
                _tw(d,{BackgroundTransparency=1},0.18):Play()
            end
        end) end
        task.wait(0.24)
        _tw(MF,{Size=UDim2.new(0,0,0,0)},0.18,Enum.EasingStyle.Back,Enum.EasingDirection.In):Play()
        task.delay(0.2,function() SG:Destroy() end)
    end)

    --  Hotkey 
    UserInputService.InputBegan:Connect(function(i,gp)
        if gp then return end
        if i.KeyCode==toggleKC then
            MF.Visible=not MF.Visible
        end
    end)

    --  Open animation 
    task.spawn(function()
        task.wait(0.1)
        MF.Size=UDim2.new(0,WW,0,0);MF.Visible=true
        _tw(MF,{Size=FULL},0.45,Enum.EasingStyle.Quint):Play()
    end)

    return self
end

-- 
-- WINDOW METHODS
-- 

-- Set footer status
function JarotUI:Status(text, col)
    if self._flbl then self._flbl.Text = text end
    if self._fdot then
        _tw(self._fdot,{BackgroundColor3=col or C.GREEN},0.2):Play()
    end
end

-- Fire notification
function JarotUI:Notify(msg, col, dur, ico)
    _notify(msg, col or C.ACC2, ico or "!", dur or 3.5)
end

-- Add a tab, returns Tab object
function JarotUI:Tab(label, accentColor)
    local acc   = accentColor or C.ACC2
    local id    = "tab_"..tostring(#self._tabs+1)
    local order = self._tabOrder
    self._tabOrder = self._tabOrder + 1

    -- Panel (content area)
    local panel=Instance.new("Frame",self._con)
    panel.Size=UDim2.new(1,0,1,0)
    panel.BackgroundColor3=C.PANEL;panel.BorderSizePixel=0
    panel.Visible=false;panel.ClipsDescendants=true
    _rnd(panel,12);_brdr(panel,C.BORDER,1.2,0.45)

    -- Panel header strip
    local ph=Instance.new("Frame",panel)
    ph.Size=UDim2.new(1,0,0,36)
    ph.BackgroundColor3=Color3.fromRGB(13,11,25);ph.BorderSizePixel=0;_rnd(ph,12)
    local phf=Instance.new("Frame",ph);phf.Size=UDim2.new(1,0,0,12)
    phf.Position=UDim2.new(0,0,1,-12)
    phf.BackgroundColor3=Color3.fromRGB(13,11,25);phf.BorderSizePixel=0
    local phpip=Instance.new("Frame",ph);phpip.Size=UDim2.new(0,3,0,16)
    phpip.Position=UDim2.new(0,10,0.5,-8);phpip.BackgroundColor3=acc
    phpip.BorderSizePixel=0;_rnd(phpip,3)
    local phlbl=Instance.new("TextLabel",ph)
    phlbl.Size=UDim2.new(1,-28,1,0);phlbl.Position=UDim2.new(0,20,0,0)
    phlbl.BackgroundTransparency=1;phlbl.Text=label
    phlbl.TextColor3=acc;phlbl.TextSize=12;phlbl.Font=Enum.Font.GothamBold
    phlbl.TextXAlignment=Enum.TextXAlignment.Left

    -- Scroll inside panel
    local scroll=Instance.new("ScrollingFrame",panel)
    scroll.Size=UDim2.new(1,-14,1,-46);scroll.Position=UDim2.new(0,7,0,42)
    scroll.BackgroundTransparency=1;scroll.ScrollBarThickness=3
    scroll.AutomaticCanvasSize=Enum.AutomaticSize.Y
    scroll.CanvasSize=UDim2.new(0,0,0,0);scroll.BorderSizePixel=0
    scroll.ScrollBarImageColor3=acc
    local ul=Instance.new("UIListLayout",scroll)
    ul.Padding=UDim.new(0,8);ul.SortOrder=Enum.SortOrder.LayoutOrder
    local pad=Instance.new("UIPadding",scroll)
    pad.PaddingTop=UDim.new(0,6);pad.PaddingBottom=UDim.new(0,8)
    pad.PaddingLeft=UDim.new(0,2);pad.PaddingRight=UDim.new(0,4)

    -- Sidebar button
    local btn=Instance.new("TextButton",self._sidebar)
    btn.Size=UDim2.new(1,0,0,36);btn.LayoutOrder=order
    btn.BackgroundColor3=Color3.fromRGB(13,10,24)
    btn.Text=label;btn.TextColor3=C.MUTED
    btn.TextSize=11;btn.Font=Enum.Font.GothamBold
    btn.BorderSizePixel=0;_rnd(btn,8)
    btn.TextXAlignment=Enum.TextXAlignment.Left
    -- left pip
    local pip=Instance.new("Frame",btn)
    pip.Name="pip";pip.Size=UDim2.new(0,3,0,20)
    pip.Position=UDim2.new(0,0,0.5,-10);pip.BackgroundColor3=acc
    pip.BorderSizePixel=0;pip.BackgroundTransparency=1;_rnd(pip,3)
    local bpad=Instance.new("UIPadding",btn);bpad.PaddingLeft=UDim.new(0,10)
    -- hover
    btn.MouseEnter:Connect(function()
        if self._activTab~=id then
            _tw(btn,{BackgroundColor3=Color3.fromRGB(18,14,34)},0.15):Play()
        end
    end)
    btn.MouseLeave:Connect(function()
        if self._activTab~=id then
            _tw(btn,{BackgroundColor3=Color3.fromRGB(13,10,24)},0.15):Play()
        end
    end)

    local tabDef={id=id,lbl=label,acc=acc,panel=panel,btn=btn,scroll=scroll,_order=#self._tabs+1}
    table.insert(self._tabs,tabDef)

    btn.MouseButton1Click:Connect(function()
        self:_selectTab(id)
        self:Status(label,acc)
    end)

    -- auto-select first tab
    if #self._tabs==1 then
        task.defer(function() self:_selectTab(id) end)
    end

    -- Return Tab API object
    local Tab={}
    Tab._scroll  = scroll
    Tab._acc     = acc
    Tab._itemIdx = 0

    function Tab:_nextOrder()
        self._itemIdx=self._itemIdx+1
        return self._itemIdx
    end

    --  Card helpers (internal) 
    function Tab:_card(h, bg, order)
        local f=Instance.new("Frame",self._scroll)
        f.Size=UDim2.new(1,0,0,h)
        f.BackgroundColor3=bg or C.CARD
        f.BorderSizePixel=0;f.LayoutOrder=order or self:_nextOrder()
        _rnd(f,10)
        return f
    end

    -- 
    -- TAB COMPONENTS
    -- 

    -- Label (static text)
    function Tab:Label(text, color, size)
        local card=self:_card(34)
        _brdr(card,self._acc,1,0.7)
        local lbl=Instance.new("TextLabel",card)
        lbl.Size=UDim2.new(1,-16,1,0);lbl.Position=UDim2.new(0,10,0,0)
        lbl.BackgroundTransparency=1;lbl.Text=text
        lbl.TextColor3=color or C.SUB;lbl.TextSize=size or 12
        lbl.Font=Enum.Font.Gotham;lbl.TextXAlignment=Enum.TextXAlignment.Left
        lbl.TextWrapped=true;lbl.TextYAlignment=Enum.TextYAlignment.Center
        return lbl
    end

    -- Separator line
    function Tab:Separator(label)
        local h = label and 24 or 8
        local card=self:_card(h,Color3.fromRGB(14,12,26))
        _brdr(card,C.BORDER,1,0.7)
        if label then
            local lbl=Instance.new("TextLabel",card)
            lbl.Size=UDim2.new(1,-16,1,0);lbl.Position=UDim2.new(0,10,0,0)
            lbl.BackgroundTransparency=1;lbl.Text=label
            lbl.TextColor3=C.MUTED;lbl.TextSize=10;lbl.Font=Enum.Font.GothamBold
            lbl.TextXAlignment=Enum.TextXAlignment.Center
        end
    end

    -- Status display
    function Tab:Status(text, col)
        local card=self:_card(38)
        _brdr(card,self._acc,1,0.6)
        local dot=Instance.new("Frame",card)
        dot.Size=UDim2.new(0,8,0,8);dot.Position=UDim2.new(0,10,0.5,-4)
        dot.BackgroundColor3=col or C.GREEN;dot.BorderSizePixel=0;_rnd(dot,4)
        local lbl=Instance.new("TextLabel",card)
        lbl.Size=UDim2.new(1,-26,1,0);lbl.Position=UDim2.new(0,24,0,0)
        lbl.BackgroundTransparency=1;lbl.Text=text
        lbl.TextColor3=C.TEXT;lbl.TextSize=12;lbl.Font=Enum.Font.GothamBold
        lbl.TextXAlignment=Enum.TextXAlignment.Left
        -- returns update function
        return function(newText, newCol)
            lbl.Text=newText
            if newCol then _tw(dot,{BackgroundColor3=newCol},0.2):Play() end
        end
    end

    -- Button
    function Tab:Button(label, callback, color)
        local bg  = color or self._acc
        local bg2 = Color3.fromRGB(
            math.floor(bg.R*180),
            math.floor(bg.G*180),
            math.floor(bg.B*180))
        local card=self:_card(44)
        _brdr(card,bg,1.5,0.3)
        _grad(card,bg2,Color3.fromRGB(
            math.floor(bg.R*140),
            math.floor(bg.G*140),
            math.floor(bg.B*140)),135)
        local btn=Instance.new("TextButton",card)
        btn.Size=UDim2.new(1,0,1,0);btn.BackgroundTransparency=1
        btn.Text=label;btn.TextColor3=C.W;btn.TextSize=13
        btn.Font=Enum.Font.GothamBlack;btn.BorderSizePixel=0
        btn.MouseButton1Click:Connect(function() pcall(callback) end)
        btn.MouseEnter:Connect(function()
            _tw(card,{BackgroundColor3=bg},0.15):Play()
        end)
        btn.MouseLeave:Connect(function()
            _tw(card,{BackgroundColor3=bg2},0.15):Play()
        end)
        return btn
    end

    -- Toggle
    function Tab:Toggle(label, default, callback)
        local state = default or false
        local card=self:_card(44)
        _brdr(card,self._acc,1,0.55)

        local lbl=Instance.new("TextLabel",card)
        lbl.Size=UDim2.new(1,-70,1,0);lbl.Position=UDim2.new(0,12,0,0)
        lbl.BackgroundTransparency=1;lbl.Text=label
        lbl.TextColor3=C.TEXT;lbl.TextSize=13;lbl.Font=Enum.Font.GothamBold
        lbl.TextXAlignment=Enum.TextXAlignment.Left

        -- pill track
        local track=Instance.new("Frame",card)
        track.Size=UDim2.new(0,44,0,22);track.Position=UDim2.new(1,-56,0.5,-11)
        track.BackgroundColor3=state and C.GREEN or C.MUTED
        track.BorderSizePixel=0;_rnd(track,11)
        -- knob
        local knob=Instance.new("Frame",track)
        knob.Size=UDim2.new(0,16,0,16);knob.Position=state
            and UDim2.new(1,-18,0.5,-8) or UDim2.new(0,2,0.5,-8)
        knob.BackgroundColor3=C.W;knob.BorderSizePixel=0;_rnd(knob,8)

        local function refresh()
            _tw(track,{BackgroundColor3=state and C.GREEN or C.MUTED},0.2):Play()
            _tw(knob,{Position=state
                and UDim2.new(1,-18,0.5,-8)
                or  UDim2.new(0,2,0.5,-8)},0.2):Play()
        end

        local hitBtn=Instance.new("TextButton",card)
        hitBtn.Size=UDim2.new(1,0,1,0);hitBtn.BackgroundTransparency=1
        hitBtn.Text="";hitBtn.BorderSizePixel=0
        hitBtn.MouseButton1Click:Connect(function()
            state=not state
            refresh()
            pcall(callback,state)
        end)

        return {
            Set = function(_, v)
                state=v; refresh(); pcall(callback,state)
            end,
            Get = function(_) return state end
        }
    end

    -- Slider
    function Tab:Slider(label, min, max, default, callback)
        local val = math.clamp(default or min, min, max)
        local card=self:_card(66)
        _brdr(card,self._acc,1,0.55)

        local titleL=Instance.new("TextLabel",card)
        titleL.Size=UDim2.new(1,-16,0,20);titleL.Position=UDim2.new(0,12,0,4)
        titleL.BackgroundTransparency=1
        titleL.Text=label;titleL.TextColor3=C.TEXT
        titleL.TextSize=12;titleL.Font=Enum.Font.GothamBold
        titleL.TextXAlignment=Enum.TextXAlignment.Left

        local valL=Instance.new("TextLabel",card)
        valL.Size=UDim2.new(0,60,0,20);valL.Position=UDim2.new(1,-68,0,4)
        valL.BackgroundTransparency=1
        valL.Text=tostring(val);valL.TextColor3=self._acc
        valL.TextSize=13;valL.Font=Enum.Font.GothamBlack
        valL.TextXAlignment=Enum.TextXAlignment.Right

        local track=Instance.new("Frame",card)
        track.Size=UDim2.new(1,-24,0,7);track.Position=UDim2.new(0,12,0,36)
        track.BackgroundColor3=Color3.fromRGB(28,22,52)
        track.BorderSizePixel=0;_rnd(track,4)

        local fill=Instance.new("Frame",track)
        fill.Size=UDim2.new(0.01,0,1,0);fill.BackgroundColor3=self._acc
        fill.BorderSizePixel=0;_rnd(fill,4)
        _grad(fill,self._acc,C.ACC,0)

        local handle=Instance.new("Frame",track)
        handle.Size=UDim2.new(0,14,0,14);handle.AnchorPoint=Vector2.new(0.5,0.5)
        handle.Position=UDim2.new(0,0,0.5,0)
        handle.BackgroundColor3=C.W;handle.BorderSizePixel=0;_rnd(handle,7)
        _brdr(handle,self._acc,2,0.2)

        local pct = (val-min)/(max-min)

        local function setVal(v)
            val = math.clamp(math.round(v), min, max)
            pct = (val-min)/(max-min)
            valL.Text=tostring(val)
            _tw(fill,  {Size=UDim2.new(math.max(pct,0.005),0,1,0)},0.08):Play()
            _tw(handle,{Position=UDim2.new(pct,0,0.5,0)},0.08):Play()
            pcall(callback,val)
        end
        setVal(val)

        local dragging=false
        track.InputBegan:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1
            or i.UserInputType==Enum.UserInputType.Touch then
                dragging=true
                local ap=track.AbsolutePosition;local sz=track.AbsoluteSize
                local r=math.clamp((i.Position.X-ap.X)/sz.X,0,1)
                setVal(min+r*(max-min))
            end
        end)
        handle.InputBegan:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1
            or i.UserInputType==Enum.UserInputType.Touch then dragging=true end
        end)
        UserInputService.InputChanged:Connect(function(i)
            if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement
                or i.UserInputType==Enum.UserInputType.Touch) then
                local ap=track.AbsolutePosition;local sz=track.AbsoluteSize
                local r=math.clamp((i.Position.X-ap.X)/sz.X,0,1)
                setVal(min+r*(max-min))
            end
        end)
        UserInputService.InputEnded:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1
            or i.UserInputType==Enum.UserInputType.Touch then dragging=false end
        end)

        return {
            Set = function(_, v) setVal(v) end,
            Get = function(_) return val end
        }
    end

    -- Input box
    function Tab:Input(placeholder, callback)
        local card=self:_card(50)
        _brdr(card,self._acc,1,0.55)
        local box=Instance.new("TextBox",card)
        box.Size=UDim2.new(1,-24,0,30);box.Position=UDim2.new(0,12,0.5,-15)
        box.BackgroundColor3=Color3.fromRGB(14,12,26)
        box.BorderSizePixel=0;_rnd(box,8);_brdr(box,self._acc,1,0.5)
        box.Text="";box.PlaceholderText=placeholder or "Type here..."
        box.TextColor3=C.TEXT;box.PlaceholderColor3=C.MUTED
        box.TextSize=12;box.Font=Enum.Font.Gotham
        box.ClearTextOnFocus=false
        local pad=Instance.new("UIPadding",box)
        pad.PaddingLeft=UDim.new(0,8);pad.PaddingRight=UDim.new(0,8)
        box.FocusLost:Connect(function(enter)
            if enter then pcall(callback, box.Text) end
        end)
        return box
    end

    -- Dropdown
    function Tab:Dropdown(label, options, callback)
        local selected = options[1]
        local open     = false
        local card=self:_card(44)
        _brdr(card,self._acc,1,0.55)

        local lbl2=Instance.new("TextLabel",card)
        lbl2.Size=UDim2.new(0.45,-6,1,0);lbl2.Position=UDim2.new(0,12,0,0)
        lbl2.BackgroundTransparency=1;lbl2.Text=label
        lbl2.TextColor3=C.TEXT;lbl2.TextSize=12;lbl2.Font=Enum.Font.GothamBold
        lbl2.TextXAlignment=Enum.TextXAlignment.Left

        local selBtn=Instance.new("TextButton",card)
        selBtn.Size=UDim2.new(0.55,-12,0,30);selBtn.Position=UDim2.new(0.45,0,0.5,-15)
        selBtn.BackgroundColor3=Color3.fromRGB(18,14,34)
        selBtn.BorderSizePixel=0;_rnd(selBtn,8);_brdr(selBtn,self._acc,1,0.5)
        selBtn.Text=selected.." v";selBtn.TextColor3=self._acc
        selBtn.TextSize=11;selBtn.Font=Enum.Font.GothamBold

        -- dropdown list (spawned below)
        local listFrame=Instance.new("Frame",card)
        listFrame.Size=UDim2.new(0.55,-12,0,0)
        listFrame.Position=UDim2.new(0.45,0,1,2)
        listFrame.BackgroundColor3=Color3.fromRGB(16,13,30)
        listFrame.BorderSizePixel=0;listFrame.Visible=false;listFrame.ZIndex=10
        _rnd(listFrame,8);_brdr(listFrame,self._acc,1,0.4)
        local listUL=Instance.new("UIListLayout",listFrame)
        listUL.Padding=UDim.new(0,2);listUL.SortOrder=Enum.SortOrder.LayoutOrder
        local listPad=Instance.new("UIPadding",listFrame)
        listPad.PaddingTop=UDim.new(0,4);listPad.PaddingBottom=UDim.new(0,4)
        listPad.PaddingLeft=UDim.new(0,4);listPad.PaddingRight=UDim.new(0,4)

        for i,opt in ipairs(options) do
            local ob=Instance.new("TextButton",listFrame)
            ob.Size=UDim2.new(1,0,0,26);ob.LayoutOrder=i
            ob.BackgroundColor3=Color3.fromRGB(22,18,40)
            ob.BorderSizePixel=0;_rnd(ob,6)
            ob.Text=opt;ob.TextColor3=C.TEXT;ob.TextSize=11
            ob.Font=Enum.Font.GothamBold;ob.ZIndex=11
            _hvr(ob,Color3.fromRGB(22,18,40),Color3.fromRGB(30,24,52))
            ob.MouseButton1Click:Connect(function()
                selected=opt
                selBtn.Text=opt.." v"
                open=false
                _tw(listFrame,{Size=UDim2.new(0.55,-12,0,0)},0.18):Play()
                task.delay(0.2,function() listFrame.Visible=false end)
                pcall(callback,opt)
            end)
        end
        listFrame.Size=UDim2.new(0.55,-12,0,#options*28+8)

        selBtn.MouseButton1Click:Connect(function()
            open=not open
            listFrame.Visible=true
            if open then
                _tw(listFrame,{Size=UDim2.new(0.55,-12,0,#options*28+8)},0.2):Play()
                card.Size=UDim2.new(1,0,0,44+#options*28+12)
            else
                _tw(listFrame,{Size=UDim2.new(0.55,-12,0,0)},0.18):Play()
                task.delay(0.2,function() listFrame.Visible=false end)
                card.Size=UDim2.new(1,0,0,44)
            end
        end)

        return {
            Get = function(_) return selected end,
            Set = function(_, v)
                selected=v;selBtn.Text=v.." v";pcall(callback,v)
            end
        }
    end

    -- Color Picker (draggable hue+sat/val box)
    function Tab:ColorPicker(label, default, callback)
        local cpHue,cpSat,cpVal=0.55,0.8,0.9
        if default then
            cpHue,cpSat,cpVal=Color3.toHSV(default)
        end
        local picked=Color3.fromHSV(cpHue,cpSat,cpVal)

        local card=self:_card(240)
        _brdr(card,self._acc,1,0.5)
        mkLbl2(card,label,C.SUB,10,Enum.Font.GothamBold,
            Enum.TextXAlignment.Left,12,6)

        -- sat/val box
        local hsBox=Instance.new("Frame",card)
        hsBox.Size=UDim2.new(1,-74,0,130);hsBox.Position=UDim2.new(0,12,0,22)
        hsBox.BackgroundColor3=Color3.fromRGB(255,0,0)
        hsBox.BorderSizePixel=0;_rnd(hsBox,8)
        local wG=Instance.new("UIGradient",hsBox)
        wG.Color=ColorSequence.new{
            ColorSequenceKeypoint.new(0,Color3.new(1,1,1)),
            ColorSequenceKeypoint.new(1,Color3.fromRGB(255,0,0))
        };wG.Rotation=0
        local bOvr=Instance.new("Frame",hsBox)
        bOvr.Size=UDim2.new(1,0,1,0);bOvr.BackgroundColor3=Color3.new(0,0,0)
        bOvr.BorderSizePixel=0;_rnd(bOvr,8)
        local bG=Instance.new("UIGradient",bOvr)
        bG.Transparency=NumberSequence.new{
            NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(1,0)
        };bG.Rotation=90
        local cpCur=Instance.new("Frame",hsBox)
        cpCur.Size=UDim2.new(0,14,0,14);cpCur.AnchorPoint=Vector2.new(0.5,0.5)
        cpCur.BackgroundColor3=C.W;cpCur.BorderSizePixel=0;_rnd(cpCur,7)
        _brdr(cpCur,Color3.new(0,0,0),2,0)

        -- hue bar
        local hBar=Instance.new("Frame",card)
        hBar.Size=UDim2.new(0,36,0,130);hBar.Position=UDim2.new(1,-48,0,22)
        hBar.BackgroundColor3=Color3.new(1,1,1);hBar.BorderSizePixel=0;_rnd(hBar,8)
        local hG=Instance.new("UIGradient",hBar)
        hG.Color=ColorSequence.new{
            ColorSequenceKeypoint.new(0,    Color3.fromRGB(255,0,0)),
            ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255,255,0)),
            ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0,255,0)),
            ColorSequenceKeypoint.new(0.5,  Color3.fromRGB(0,255,255)),
            ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0,0,255)),
            ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255,0,255)),
            ColorSequenceKeypoint.new(1,    Color3.fromRGB(255,0,0)),
        };hG.Rotation=90
        local hCur=Instance.new("Frame",hBar)
        hCur.Size=UDim2.new(1,6,0,6);hCur.AnchorPoint=Vector2.new(0.5,0.5)
        hCur.BackgroundColor3=C.W;hCur.BorderSizePixel=0;_rnd(hCur,3)
        _brdr(hCur,Color3.new(0,0,0),1.5,0)

        -- preview
        local prev=Instance.new("Frame",card)
        prev.Size=UDim2.new(0,44,0,28);prev.Position=UDim2.new(0,12,0,162)
        prev.BackgroundColor3=picked;prev.BorderSizePixel=0
        _rnd(prev,7);_brdr(prev,C.MUTED,1,0.4)

        local hexL=Instance.new("TextLabel",card)
        hexL.Size=UDim2.new(1,-72,0,14);hexL.Position=UDim2.new(0,62,0,165)
        hexL.BackgroundTransparency=1;hexL.TextColor3=C.SUB
        hexL.TextSize=10;hexL.Font=Enum.Font.Gotham
        hexL.TextXAlignment=Enum.TextXAlignment.Left

        local applyBg=Color3.fromRGB(18,60,18)
        local applyBtn=Instance.new("TextButton",card)
        applyBtn.Size=UDim2.new(1,-24,0,26);applyBtn.Position=UDim2.new(0,12,0,200)
        applyBtn.BackgroundColor3=applyBg;applyBtn.BorderSizePixel=0
        applyBtn.Text="Apply Color";applyBtn.TextColor3=C.W
        applyBtn.TextSize=12;applyBtn.Font=Enum.Font.GothamBold
        _rnd(applyBtn,8);_brdr(applyBtn,C.GREEN,1.5,0.3)
        _hvr(applyBtn,applyBg,C.GREEN2)

        local function refresh()
            picked=Color3.fromHSV(cpHue,cpSat,cpVal)
            prev.BackgroundColor3=picked
            local r=math.floor(picked.R*255)
            local g2=math.floor(picked.G*255)
            local b=math.floor(picked.B*255)
            hexL.Text="R:"..r.."  G:"..g2.."  B:"..b
            local ph=Color3.fromHSV(cpHue,1,1)
            hsBox.BackgroundColor3=ph
            wG.Color=ColorSequence.new{
                ColorSequenceKeypoint.new(0,Color3.new(1,1,1)),
                ColorSequenceKeypoint.new(1,ph)
            }
            cpCur.Position=UDim2.new(cpSat,0,1-cpVal,0)
            hCur.Position=UDim2.new(0.5,0,cpHue,0)
        end
        refresh()

        local dHS,dH=false,false
        hsBox.InputBegan:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1
            or i.UserInputType==Enum.UserInputType.Touch then
                dHS=true
                local ap=hsBox.AbsolutePosition;local sz=hsBox.AbsoluteSize
                cpSat=math.clamp((i.Position.X-ap.X)/sz.X,0,1)
                cpVal=1-math.clamp((i.Position.Y-ap.Y)/sz.Y,0,1)
                refresh()
            end
        end)
        hBar.InputBegan:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1
            or i.UserInputType==Enum.UserInputType.Touch then
                dH=true
                local ap=hBar.AbsolutePosition;local sz=hBar.AbsoluteSize
                cpHue=math.clamp((i.Position.Y-ap.Y)/sz.Y,0,1)
                refresh()
            end
        end)
        UserInputService.InputChanged:Connect(function(i)
            if i.UserInputType~=Enum.UserInputType.MouseMovement
            and i.UserInputType~=Enum.UserInputType.Touch then return end
            if dHS then
                local ap=hsBox.AbsolutePosition;local sz=hsBox.AbsoluteSize
                cpSat=math.clamp((i.Position.X-ap.X)/sz.X,0,1)
                cpVal=1-math.clamp((i.Position.Y-ap.Y)/sz.Y,0,1)
                refresh()
            elseif dH then
                local ap=hBar.AbsolutePosition;local sz=hBar.AbsoluteSize
                cpHue=math.clamp((i.Position.Y-ap.Y)/sz.Y,0,1)
                refresh()
            end
        end)
        UserInputService.InputEnded:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1
            or i.UserInputType==Enum.UserInputType.Touch then
                dHS=false;dH=false
            end
        end)
        applyBtn.MouseButton1Click:Connect(function()
            pcall(callback,picked)
        end)

        return {
            Get = function(_) return picked end,
            Set = function(_,c)
                cpHue,cpSat,cpVal=Color3.toHSV(c);refresh()
            end
        }
    end

    -- helper used inside ColorPicker
    function mkLbl2(p,txt,col,sz,fnt,xa,x,y)
        local l=Instance.new("TextLabel",p)
        l.Size=UDim2.new(1,-16,0,16);l.Position=UDim2.new(0,x or 12,0,y or 4)
        l.BackgroundTransparency=1;l.Text=txt;l.TextColor3=col or C.SUB
        l.TextSize=sz or 11;l.Font=fnt or Enum.Font.Gotham
        l.TextXAlignment=xa or Enum.TextXAlignment.Left
        return l
    end

    return Tab
end

-- 
-- INTERNAL: select tab
-- 
function JarotUI:_selectTab(id)
    if self._activTab==id then return end
    self._activTab=id
    for _,def in ipairs(self._tabs) do
        local b=def.btn;local p=def.panel
        if def.id==id then
            _tw(b,{BackgroundColor3=Color3.fromRGB(22,15,44),TextColor3=def.acc},0.2):Play()
            local pip=b:FindFirstChild("pip")
            if pip then _tw(pip,{BackgroundTransparency=0},0.2):Play() end
            p.Visible=true;p.BackgroundTransparency=1
            _tw(p,{BackgroundTransparency=0},0.15):Play()
        else
            _tw(b,{BackgroundColor3=Color3.fromRGB(13,10,24),TextColor3=C.MUTED},0.2):Play()
            local pip=b:FindFirstChild("pip")
            if pip then _tw(pip,{BackgroundTransparency=1},0.2):Play() end
            p.Visible=false
        end
    end
end

return JarotUI
