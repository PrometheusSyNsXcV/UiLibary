JarotUI Library — Documentation
Dark purple UI library untuk Roblox executor.
Style: JAROT v5 — sidebar tabs, horizontal layout, smooth animations.
Quick Start
local UI = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/USERNAME/REPO/main/JarotUI.lua"
))()

local win  = UI:Window("My Script", "v1.0")
local tab  = win:Tab("[Home] Home", Color3.fromRGB(108,52,238))

tab:Button("Hello!", function()
    print("clicked")
end)
Window
local win = UI:Window(title, subtitle, toggleKey)
Parameter
Type
Default
Keterangan
title
string
"JarotUI"
Judul di header
subtitle
string
"v1.0"
Sub-judul kecil di bawah title
toggleKey
Enum.KeyCode
RightBracket
Hotkey buat show/hide window
Contoh:
local win = UI:Window("My Script", "v2.0", Enum.KeyCode.RightShift)
Window Methods
Notify
Popup notifikasi muncul dari atas layar.
win:Notify(message, color, duration, icon)
win:Notify("Auto Farm ON!", Color3.fromRGB(50,208,98), 3, "!")
win:Notify("Error!", Color3.fromRGB(228,56,56), 4)
Status (footer)
Ubah text dan warna dot di footer bawah window.
win:Status(text, color)
win:Status("Running...", Color3.fromRGB(50,208,98))
win:Status("Idle", Color3.fromRGB(80,72,110))
Tab
Buat tab baru di sidebar kiri.
local tab = win:Tab(label, accentColor)
Parameter
Type
Keterangan
label
string
Teks tab di sidebar
accentColor
Color3
Warna aksen tab (pip, header, scrollbar)
Contoh:
local tabHome = win:Tab("[H] Home",     Color3.fromRGB(108, 52,238))
local tabFarm = win:Tab("[F] Auto Farm",Color3.fromRGB( 50,208, 98))
local tabESP  = win:Tab("[E] ESP",      Color3.fromRGB( 50,140,242))
local tabBuy  = win:Tab("[$] Auto Buy", Color3.fromRGB(252,210, 50))
Tabs otomatis bisa discroll kalau jumlahnya banyak.
Tab Components
Label
Text statis, untuk info atau keterangan.
tab:Label(text, color, textSize)
tab:Label("Selamat datang!")
tab:Label("Fitur ini butuh kendaraan.", Color3.fromRGB(252,210,50))
tab:Label("Versi: 1.0", Color3.fromRGB(80,72,110), 11)
Separator
Garis pembatas antar section, bisa ada label kecil.
tab:Separator()
tab:Separator("Settings")
Status
Status indicator dengan dot berwarna. Mengembalikan fungsi update.
local update = tab:Status(text, color)

-- Update nanti:
update("Running", Color3.fromRGB(50,208,98))
update("Stopped", Color3.fromRGB(228,56,56))
local msStatus = tab:Status("Auto MS: OFF", Color3.fromRGB(80,72,110))

-- Di dalam logic:
msStatus("Auto MS: ON",  Color3.fromRGB(50,208,98))
msStatus("Auto MS: OFF", Color3.fromRGB(80,72,110))
Button
Tombol yang bisa diklik.
tab:Button(label, callback, color)
Parameter
Type
Default
Keterangan
label
string
—
Teks tombol
callback
function
—
Dipanggil saat diklik
color
Color3
accent color
Warna tombol (opsional)
tab:Button("Teleport to Spawn", function()
    -- kode teleport
end)

tab:Button("Delete Floor", function()
    -- kode hapus floor
end, Color3.fromRGB(228,56,56))
Toggle
Switch ON/OFF. Mengembalikan object dengan method Set dan Get.
local toggle = tab:Toggle(label, default, callback)
Parameter
Type
Default
Keterangan
label
string
—
Teks toggle
default
boolean
false
State awal (true = ON)
callback
function
—
Dipanggil tiap state berubah
local autoFarm = tab:Toggle("Auto Farm", false, function(isOn)
    if isOn then
        startFarm()
    else
        stopFarm()
    end
end)

-- Ubah state dari luar:
autoFarm:Set(true)

-- Baca state:
print(autoFarm:Get())  -- true / false
Slider
Slider angka dengan drag. Mengembalikan object Set/Get.
local slider = tab:Slider(label, min, max, default, callback)
Parameter
Type
Keterangan
label
string
Teks slider
min
number
Nilai minimum
max
number
Nilai maximum
default
number
Nilai awal
callback
function
Dipanggil setiap nilai berubah
local speedSlider = tab:Slider("Speed", 1, 100, 16, function(v)
    humanoid.WalkSpeed = v
end)

local buySlider = tab:Slider("Buy Amount", 1, 100, 5, function(v)
    buyAmount = v
end)

-- Ubah nilai:
speedSlider:Set(50)

-- Baca nilai:
print(speedSlider:Get())
Input
Text box untuk input dari user. Callback dipanggil saat Enter ditekan.
tab:Input(placeholder, callback)
tab:Input("Masukkan nama...", function(text)
    print("Input:", text)
end)

tab:Input("Target player name", function(name)
    targetPlayer = name
end)
Dropdown
Pilihan dari list. Mengembalikan object Set/Get.
local dropdown = tab:Dropdown(label, options, callback)
local modeSelect = tab:Dropdown("Mode", {
    "Auto",
    "Manual",
    "Semi-Auto"
}, function(selected)
    print("Mode:", selected)
    currentMode = selected
end)

-- Ubah pilihan:
modeSelect:Set("Manual")

-- Baca pilihan:
print(modeSelect:Get())
ColorPicker
Draggable color picker (hue bar + sat/val box). Mengembalikan object Set/Get.
local picker = tab:ColorPicker(label, defaultColor, callback)
local espColor = tab:ColorPicker(
    "ESP Color",
    Color3.fromRGB(80,200,255),
    function(color)
        -- apply warna ke ESP
        highlight.OutlineColor = color
    end
)

-- Ubah warna:
espColor:Set(Color3.fromRGB(255,100,100))

-- Baca warna:
print(espColor:Get())
Contoh Lengkap
-- Load library
local UI = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/USERNAME/REPO/main/JarotUI.lua"
))()

-- Buat window
local win = UI:Window("My Roblox Script", "v1.0", Enum.KeyCode.RightBracket)

-- ── Tab: Home ──────────────────────────────────────────
local home = win:Tab("[H] Home", Color3.fromRGB(108,52,238))

home:Label("Selamat datang! Script by username.")
home:Separator()
home:Label("Versi: 1.0  |  Game: South Bronx")

-- ── Tab: Auto Farm ─────────────────────────────────────
local farm = win:Tab("[F] Auto Farm", Color3.fromRGB(50,208,98))

local farmStatus = farm:Status("Auto Farm: OFF")

local isRunning = false

farm:Toggle("Auto Farm", false, function(v)
    isRunning = v
    if v then
        farmStatus("Auto Farm: ON",  Color3.fromRGB(50,208,98))
        win:Status("Auto Farm running", Color3.fromRGB(50,208,98))
        win:Notify("Auto Farm ON!", Color3.fromRGB(50,208,98), 2.5)
    else
        farmStatus("Auto Farm: OFF", Color3.fromRGB(80,72,110))
        win:Status("Idle")
        win:Notify("Auto Farm OFF", Color3.fromRGB(228,56,56), 2)
    end
end)

farm:Slider("Speed", 1, 100, 16, function(v)
    if game.Players.LocalPlayer.Character then
        local hum = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = v end
    end
end)

farm:Separator("Options")

farm:Button("Collect Now", function()
    -- kode collect
    win:Notify("Collected!", Color3.fromRGB(252,210,50), 2)
end)

-- ── Tab: Auto Buy ──────────────────────────────────────
local buy = win:Tab("[$] Auto Buy", Color3.fromRGB(252,210,50))

local buyAmt = 1

local buySlider = buy:Slider("Amount", 1, 100, 1, function(v)
    buyAmt = v
end)

buy:Button("Buy Water", function()
    local remote = game:GetService("ReplicatedStorage")
        :WaitForChild("RemoteEvents")
        :WaitForChild("StorePurchase")
    local bought = 0
    while bought < buyAmt do
        remote:FireServer("Water")
        bought = bought + 1
        task.wait(0.15)
    end
    win:Notify("Beli Water x"..buyAmt.." selesai!", Color3.fromRGB(50,140,242), 3)
end, Color3.fromRGB(50,140,242))

-- ── Tab: Settings ──────────────────────────────────────
local cfg = win:Tab("[S] Settings", Color3.fromRGB(146,136,180))

cfg:Toggle("Show Notifications", true, function(v)
    -- toggle notif
end)

cfg:ColorPicker("Theme Color", Color3.fromRGB(108,52,238), function(c)
    -- apply tema
end)

cfg:Dropdown("Language", {"Indonesia","English","日本語"}, function(lang)
    print("Language:", lang)
end)

-- Done
win:Notify("Script loaded! Halo ges.", Color3.fromRGB(188,98,255), 4)
win:Status("Ready", Color3.fromRGB(50,208,98))
Color Reference
Warna bawaan library yang bisa dipake:
Nama
RGB
Kegunaan
Purple
108, 52, 238
Default accent
Pink
212, 60, 130
Teleport / danger
Green
50, 208, 98
Success / ON state
Blue
50, 140, 242
Info / interact
Yellow
252, 210, 50
Warning / buy
Orange
252, 156, 40
Caution
Red
228, 56, 56
Error / OFF state
Cyan
80, 200, 255
ESP / special
Tips
Tab pertama yang dibuat otomatis terpilih saat window muncul.
Tabs bisa discroll di sidebar kalau jumlahnya banyak.
win:Status() mengubah footer bar di bawah window.
tab:Status() membuat status card di dalam konten tab.
Semua komponen mengembalikan object dengan method Get() dan Set() kecuali Button, Label, Separator.
Hotkey default ] (RightBracket) bisa diganti saat UI:Window().
JarotUI — built from JAROT v5
