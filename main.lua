-- ========================================================
-- ⚡ سكربت المهندس أدم وياسين - النسخة النهائية المعربة ⚡
-- ========================================================

local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")
local Lighting = game:GetService("Lighting")
local Terrain = Workspace:FindFirstChildOfClass("Terrain")

---------------------------------------------------------
-- ⚙️ لوحة التحكم الرئيسية للصيانة:
local ScriptEnabled = true  
---------------------------------------------------------

local function showMaintenanceNotice()
	pcall(function()
		StarterGui:SetCore("SendNotification", {
			Title = "تنبيه صيانة ⚠️",
			Text = "نعتذر يوجد صيانة من المطور آدم يمكن غلق اللعبة وفتحها اذا لم يفتح لي فترة كبيرة من الوقت",
			Duration = 8
		})
	end)
end

if ScriptEnabled == false then
	showMaintenanceNotice()
	for _, gui in pairs(CoreGui:GetChildren()) do
		if gui:IsA("ScreenGui") and not gui.Name:find("Roblox") then
			gui:Destroy()
		end
	end
	return
end

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local SoundService = game:GetService("SoundService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local CurrentLang = "AR"
local SpeedEnabled = false
local NoclipEnabled = false
local FlyEnabled = false
local PlatformEnabled = false
local InstantInteractEnabled = false
local ESPEnabled = false
local MM2ESPEnabled = false
local MultiJumpEnabled = false
local FPSBoostEnabled = false

local MvsActiveState = false
local MvsLoadedInstance = nil
local MvsTeam = { Source = "", Before = {}, Run = 0 }

-- حالة زر "ماب سرقت البيض" (السكربت الثالث المدمج في آخر الملف)
local EggsMap = { Active = false, Loaded = nil, Before = {}, Source = "", Run = 0 }

local WalkSpeedVal = 50
local FlySpeedVal = 50

local CurrentThemeColor = Color3.fromRGB(0, 255, 180)
local SavedPosition = nil

local FollowPlatformPart = nil
local BodyVelocity = nil
local BodyGyro = nil
local Connections = {}
local HighlightsTable = {}
local MM2HighlightsTable = {}

local AutoHopEnabled = false
local HopThreshold = 1

local CountryNamesAR = {
	["EG"] = "مصر", ["SA"] = "المملكة العربية السعودية", ["AE"] = "الإمارات العربية المتحدة",
	["KW"] = "الكويت", ["QA"] = "قطر", ["BH"] = "البحرين", ["OM"] = "سلطنة عمان",
	["JO"] = "الأردن", ["IQ"] = "العراق", ["LB"] = "لبنان", ["SY"] = "سوريا",
	["MA"] = "المغرب", ["DZ"] = "الجزائر", ["TN"] = "تونس", ["LY"] = "ليبيا",
	["SD"] = "السودان", ["YE"] = "اليمن", ["US"] = "الولايات المتحدة الأمريكية",
	["GB"] = "المملكة المتحدة", ["FR"] = "فرنسا", ["DE"] = "ألمانيا", ["TR"] = "تركيا"
}

local TitleLabel, LangBtnRef, SpeedBtnRef, FlyBtnRef, PlatformBtnRef
local TeleportBtnRef, TeleportInputRef, ServerHopPanelBtnRef, UpdatesPanelBtnRef, ThemePanelBtnRef
local SavePosBtnRef, LoadPosBtnRef
local CountryLabelRef, FooterLabelRef
local MVSButtonRef, FPSBoostBtnRef
local ServerHopFrame, ServerHopCloseBtn, ServerHopInfoLabel, ServerHopInput, HopOnceBtn, AutoHopBtn
local UpdatesFrame, UpdatesCloseBtn, UpdatesTitle, UpdatesTextLabel, UpdatesScroll
local ThemeFrame, ThemeCloseBtn, ThemeTitleText, ThemeGreenBtn, ThemeRedBtn, ThemeBlueBtn, ThemePurpleBtn

local Translations = {
	AR = {
		Title = "⚡ سكربت المهندس أدم وياسين ⚡",
		SpeedText = "سرعة المشي الخارقة",
		FlyText = "الطيران الحر المتقدم",
		NoclipText = "اختراق الجدران (Noclip)",
		PlatformText = "منصة الارتكاز الذكية",
		InstantInteractText = "التفاعل الفوري السريع",
		ESPText = "كشف اللاعبين عبر الجدران",
		MM2ESPText = "كشف أدوار MM2 🔪",
		MultiJumpText = "القفز المتعدد اللانهائي",
		MvsTextActive = "فريق: تفعيل",
		MvsTextClosed = "فريق: غلق",
		EggsMapText = "ماب سرقت البيض",
		FPSBoostText = "مضاد اللاج وسلاسة اللعبة 🚀",
		TeleportBtn = "انتقال 🚀",
		TeleportPlaceholder = "اكتب اسم اللاعب...",
		ServerHopBtn = "نظام تبديل السيرفرات",
		UpdatesBtn = "كل ما يخص السكربت بالتفصيل 📜",
		ThemeBtn = "تغيير لون الواجهة 🎨",
		SavePosBtn = "حفظ المكان الحالي 📍",
		LoadPosBtn = "الانتقال للمحفوظ 🚀",
		
		ThemeTitle = "🎨 اختر لون الواجهة المفضل",
		ThemeGreen = "🟢 أخضر نيون",
		ThemeRed = "🔴 أحمر ناري",
		ThemeBlue = "🔵 أزرق سايبر",
		ThemePurple = "🟣 بنفسجي ملكي",
		
		ServerHopInfo = "الانتقال لسيرفرات هادئة وفارغة لسهولة اللعب وتجنب اللاج.",
		HopThresholdPlaceholder = "أقصى عدد لاعبين (مثال: 1-5)",
		HopOnceText = "انتقال لسيرفر الآن 🌐",
		AutoHopON = "التنقل التلقائي: تفعيل",
		AutoHopOFF = "التنقل التلقائي: غلق",
		
		UpdatesTitleText = "📜 دليل ومميزات السكربت الشاملة",
		UpdatesLogText = [[
⚡ دليل ومميزات سكربت المهندس أدم وياسين VIP الشامل ⚡

📜 قائمة بكل ما يحتوي عليه السكربت منذ إنشائه:
---------------------------------------------
1. 🏃 زيادة السرعة الخارقة: التحكم الكامل في سرعة المشي من (1 إلى 200).
2. 🦅 الطيران الحر (Flight): طيران احترافي سلس مع التحكم بالسرعة والأبعاد.
3. 👻 اختراق الجدران (Noclip): المرور من خلال المباني والألواح بسهولة.
4. 🏗️ منصة الارتكاز (Quantum Platform): إنشاء أرضية نيون تحتك (تفعيل بحرف F).
5. ⚡ التفاعل الفوري (Instant Interact): فتح الأبواب والكلتشات بدون انتظار.
6. 👁️ كشف الأماكن (ESP): إظهار مجسمات جميع اللاعبين خلف الجدران مع التحديث التلقائي عند الموت والرسبون.
7. 🔪 كشف أدوار Murder Mystery 2: تحديد القاتل (أحمر)، الشريف (أزرق)، البريء (أصفر).
8. 🚀 القفز المتعدد اللانهائي: نط متعدد في الهواء بدون توقف.
9. ⚔️ فريق: نظام تفعيل وغلق تفاعلي بضغطة زر مع تنظيف كامل للذاكرة.
10. ⚡ مضاد اللاج (FPS Boost): إزالة الظلال والتاكتشرز لرفع السلاسة والفريمات.
11. 📍 حفظ وإعادة الانتقال (Waypoint): حفظ الموقع والعودة إليه بزر الانتقال.
12. 👤 الانتقال للاعبين: الانتقال المباشر لأي لاعب بكتابة اسمه فقط.
13. 🌐 نظام تبديل السيرفرات (Server Hop): دخول سيرفرات فاضية بنقرة واحدة.
14. 🎨 مخصص الألوان (Theme Color): خيارات تغيير لون الواجهة (أخضر، أحمر، أزرق، بنفسجي).
15. 📱💻 دعم جميع الأجهزة: وضع مخصص ومريح للكمبيوتر والموبايل.
16. ⚙️ نظام الصيانة الحية: نظام حماية وإغلاق فوري يدار بواسطة المهندس أدم.
]],
		Country = "الموقع: ",
		CountryLoading = "الموقع: جاري التحميل...",
		CountryUnknown = "الموقع: غير متوفر",
		Footer = "Left Ctrl: إخفاء / إظهار الواجهة",
		ON = "ON",
		OFF = "OFF",
		LangBtn = "EN"
	},
	EN = {
		Title = "⚡ ADAM & YASEEN CONTROLLER ⚡",
		SpeedText = "Walk Speed Boost",
		FlyText = "Free Flight System",
		NoclipText = "Wall Noclip Pass",
		PlatformText = "Quantum Stand Platform",
		InstantInteractText = "Instant Proximity Interact",
		ESPText = "Player Wallhack ESP",
		MM2ESPText = "Murder Mystery 2 Roles Reveal 🔪",
		MultiJumpText = "Infinite Air Jump",
		MvsTextActive = "Team: ON",
		MvsTextClosed = "Team: OFF",
		EggsMapText = "Steal the Eggs Map",
		FPSBoostText = "FPS Boost & Anti-Lag 🚀",
		TeleportBtn = "Teleport 🚀",
		TeleportPlaceholder = "Enter Player Name...",
		ServerHopBtn = "Server Hop Switcher",
		UpdatesBtn = "Full Changelog & Features 📜",
		ThemeBtn = "Theme UI Color 🎨",
		SavePosBtn = "Save Location 📍",
		LoadPosBtn = "Teleport Saved 🚀",
		
		ThemeTitle = "🎨 Choose Interface Color Theme",
		ThemeGreen = "🟢 Neon Green",
		ThemeRed = "🔴 Crimson Red",
		ThemeBlue = "🔵 Cyber Blue",
		ThemePurple = "🟣 Royal Purple",
		
		ServerHopInfo = "Switch to low population servers or filter by player count easily.",
		HopThresholdPlaceholder = "Max players (e.g. 1-5)",
		HopOnceText = "Hop Server Now 🌐",
		AutoHopON = "Auto Hop: ON",
		AutoHopOFF = "Auto Hop: OFF",
		
		UpdatesTitleText = "📜 Complete Script Features & History",
		UpdatesLogText = [[
⚡ ADAM & YASEEN VIP CONTROLLER FULL GUIDE ⚡

📜 LIST OF ALL INTEGRATED FEATURES:
---------------------------------------------
1. 🏃 Walk Speed Boost: Custom speed adjustment (1 to 200).
2. 🦅 Free Flight Glider: Smooth flight matrix with custom speed control.
3. 👻 Wall Noclip: Walk directly through walls and obstacles.
4. 🏗️ Quantum Platform: Creates a neon platform below player (Hotkey: F).
5. ⚡ Instant Interact: Instant proximity prompts activation (0 Hold Delay).
6. 👁️ Player ESP: Highlights all players with flawless auto-respawn sync.
7. 🔪 MM2 Role Reveal: Identifies Murderers (Red), Sheriffs (Blue), and Innocents (Yellow).
8. 🚀 Infinite Multi-Jump: Infinite airborne jumping capability.
9. ⚔️ Team Hub: Interactive toggle script system with clean memory wipe.
10. ⚡ FPS Boost / Anti-Lag: Removes lag, shadows, and textures for ultra smoothness.
11. 📍 Waypoint Teleport: Save position and teleport via buttons.
12. 👤 Player Teleport: Teleport directly to any player by entering their name.
13. 🌐 Server Hop System: Switch to smaller or custom player threshold servers.
14. 🎨 Theme Color Customizer: Change script main visual color (Green, Red, Blue, Purple).
15. 📱💻 Dual Platform Support: Optimized layouts for both PC and Mobile devices.
16. ⚙️ Instant Maintenance System: Safety system managed by Developer Adam.
]],
		Country = "Region: ",
		CountryLoading = "Region: Syncing...",
		CountryUnknown = "Region: Restricted",
		Footer = "Left Ctrl: Hide / Show UI",
		ON = "ON",
		OFF = "OFF",
		LangBtn = "AR"
	}
}

task.spawn(function()
	pcall(function()
		local startupSound = Instance.new("Sound")
		startupSound.SoundId = "rbxassetid://4590657391"
		startupSound.Volume = 5.0
		startupSound.Parent = SoundService
		startupSound:Play()
		
		task.delay(3, function()
			if startupSound and startupSound.Parent then
				startupSound:Destroy()
			end
		end)
	end)
end)

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
for _, gui in pairs(PlayerGui:GetChildren()) do
	if gui.Name == "Legendary_Core_UI" then
		gui:Destroy()
	end
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Legendary_Core_UI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

local SelectorGui = Instance.new("Frame")
SelectorGui.Size = UDim2.new(0, 320, 0, 190)
SelectorGui.Position = UDim2.new(0.5, -160, 0.5, -95)
SelectorGui.BackgroundColor3 = Color3.fromRGB(15, 20, 30)
SelectorGui.BorderSizePixel = 0
SelectorGui.Active = true
SelectorGui.Draggable = true
SelectorGui.Parent = ScreenGui

local SelectorCorner = Instance.new("UICorner")
SelectorCorner.CornerRadius = UDim.new(0, 14)
SelectorCorner.Parent = SelectorGui

local SelectorStroke = Instance.new("UIStroke")
SelectorStroke.Thickness = 2.5
SelectorStroke.Color = CurrentThemeColor
SelectorStroke.Parent = SelectorGui

local SelectorTitle = Instance.new("TextLabel")
SelectorTitle.Size = UDim2.new(1, 0, 0, 50)
SelectorTitle.BackgroundTransparency = 1
SelectorTitle.Text = "اختر نوع جهازك للتشغيل أولاً 🎮"
SelectorTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
SelectorTitle.TextSize = 15
SelectorTitle.Font = Enum.Font.GothamBold
SelectorTitle.Parent = SelectorGui

local PCBtn = Instance.new("TextButton")
PCBtn.Size = UDim2.new(0.85, 0, 0, 45)
PCBtn.Position = UDim2.new(0.075, 0, 0.35, 0)
PCBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 110)
PCBtn.Text = "💻 كمبيوتر (PC Mode)"
PCBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
PCBtn.TextSize = 14
PCBtn.Font = Enum.Font.GothamBold
PCBtn.Parent = SelectorGui

local PCCorner = Instance.new("UICorner")
PCCorner.CornerRadius = UDim.new(0, 8)
PCCorner.Parent = PCBtn

local MobileBtn = Instance.new("TextButton")
MobileBtn.Size = UDim2.new(0.85, 0, 0, 45)
MobileBtn.Position = UDim2.new(0.075, 0, 0.65, 0)
MobileBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 220)
MobileBtn.Text = "📱 هاتف (Mobile Compact Mode)"
MobileBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MobileBtn.TextSize = 13
MobileBtn.Font = Enum.Font.GothamBold
MobileBtn.Parent = SelectorGui

local MobileCorner = Instance.new("UICorner")
MobileCorner.CornerRadius = UDim.new(0, 8)
MobileCorner.Parent = MobileBtn

local BaseWidth, BaseHeight = 310, 970

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, BaseWidth, 0, BaseHeight)
MainFrame.Position = UDim2.new(0.05, 0, 0.02, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 15, 22)
MainFrame.BackgroundTransparency = 0 
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Visible = false 
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 14)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Thickness = 2.5
MainStroke.Color = CurrentThemeColor
MainStroke.Parent = MainFrame

local GradientStroke = Instance.new("UIGradient")
GradientStroke.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, CurrentThemeColor),
	ColorSequenceKeypoint.new(0.5, Color3.fromRGB(100, 100, 255)),
	ColorSequenceKeypoint.new(1, CurrentThemeColor)
})
GradientStroke.Parent = MainStroke

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Name = "Legendary_ToggleBtn"
ToggleBtn.Size = UDim2.new(0, 140, 0, 45)
ToggleBtn.Position = UDim2.new(0.02, 0, 0.2, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(15, 20, 30)
ToggleBtn.BackgroundTransparency = 0.15
ToggleBtn.Text = ""
ToggleBtn.Active = true
ToggleBtn.Draggable = true
ToggleBtn.Visible = false
ToggleBtn.Parent = ScreenGui

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 22)
ToggleCorner.Parent = ToggleBtn

local ToggleStroke = Instance.new("UIStroke")
ToggleStroke.Thickness = 2.5
ToggleStroke.Color = CurrentThemeColor
ToggleStroke.Parent = ToggleBtn

local FlagIcon = Instance.new("ImageLabel")
FlagIcon.Size = UDim2.new(0, 28, 0, 28)
FlagIcon.Position = UDim2.new(0.08, 0, 0.5, -14)
FlagIcon.BackgroundTransparency = 1
FlagIcon.Image = "rbxassetid://111333712"
FlagIcon.Parent = ToggleBtn

local FlagCorner = Instance.new("UICorner")
FlagCorner.CornerRadius = UDim.new(0, 6)
FlagCorner.Parent = FlagIcon

local BtnText = Instance.new("TextLabel")
BtnText.Size = UDim2.new(0.58, 0, 1, 0)
BtnText.Position = UDim2.new(0.38, 0, 0, 0)
BtnText.BackgroundTransparency = 1
BtnText.Text = "ADAM"
BtnText.TextColor3 = Color3.fromRGB(255, 255, 255)
BtnText.TextSize = 16
BtnText.Font = Enum.Font.GothamBlack
BtnText.TextXAlignment = Enum.TextXAlignment.Left
BtnText.Parent = ToggleBtn

ToggleBtn.MouseButton1Click:Connect(function()
	MainFrame.Visible = not MainFrame.Visible
end)

local UpdatesFrameStroke, HopFrameStroke, ThemeFrameStroke

local function ApplyThemeColor(color)
	CurrentThemeColor = color
	MainStroke.Color = color
	ToggleStroke.Color = color
	if SelectorStroke then SelectorStroke.Color = color end
	if UpdatesFrameStroke then UpdatesFrameStroke.Color = color end
	if HopFrameStroke then HopFrameStroke.Color = color end
	if ThemeFrameStroke then ThemeFrameStroke.Color = color end
	if TitleLabel then TitleLabel.TextColor3 = color end
	if UpdatesTitle then UpdatesTitle.TextColor3 = color end
	if ThemeTitleText then ThemeTitleText.TextColor3 = color end
	
	GradientStroke.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, color),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(120, 120, 255)),
		ColorSequenceKeypoint.new(1, color)
	})

	if MvsTeam.PaintAll then pcall(MvsTeam.PaintAll) end -- حواف "فريق" تتغير فوراً
end

PCBtn.MouseButton1Click:Connect(function()
	SelectorGui:Destroy()
	BaseWidth, BaseHeight = 310, 970
	MainFrame.Size = UDim2.new(0, BaseWidth, 0, BaseHeight)
	MainFrame.Visible = true
	ToggleBtn.Visible = true
end)

MobileBtn.MouseButton1Click:Connect(function()
	SelectorGui:Destroy()
	BaseWidth, BaseHeight = 265, 870
	MainFrame.Size = UDim2.new(0, BaseWidth, 0, BaseHeight)
	MainFrame.Visible = true
	ToggleBtn.Visible = true
end)

local TitleFrame = Instance.new("Frame")
TitleFrame.Size = UDim2.new(1, 0, 0, 54)
TitleFrame.BackgroundColor3 = Color3.fromRGB(16, 20, 30)
TitleFrame.BackgroundTransparency = 0.4
TitleFrame.BorderSizePixel = 0
TitleFrame.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 14)
TitleCorner.Parent = TitleFrame

TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(0.58, 0, 1, 0)
TitleLabel.Position = UDim2.new(0.04, 0, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = Translations[CurrentLang].Title
TitleLabel.TextColor3 = CurrentThemeColor
TitleLabel.TextSize = 11
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TitleFrame

LangBtnRef = Instance.new("TextButton")
LangBtnRef.Size = UDim2.new(0, 44, 0, 28)
LangBtnRef.Position = UDim2.new(0.63, 0, 0.24, 0)
LangBtnRef.BackgroundColor3 = Color3.fromRGB(28, 35, 50)
LangBtnRef.BackgroundTransparency = 0.3
LangBtnRef.Text = Translations[CurrentLang].LangBtn
LangBtnRef.TextColor3 = Color3.fromRGB(255, 255, 255)
LangBtnRef.TextSize = 11
LangBtnRef.Font = Enum.Font.GothamBold
LangBtnRef.Parent = TitleFrame

local LangCorner = Instance.new("UICorner")
LangCorner.CornerRadius = UDim.new(0, 6)
LangCorner.Parent = LangBtnRef

local CloseUIBtn = Instance.new("TextButton")
CloseUIBtn.Size = UDim2.new(0, 28, 0, 28)
CloseUIBtn.Position = UDim2.new(0.83, 0, 0.24, 0)
CloseUIBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
CloseUIBtn.BackgroundTransparency = 0.3
CloseUIBtn.Text = "X"
CloseUIBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseUIBtn.TextSize = 12
CloseUIBtn.Font = Enum.Font.GothamBold
CloseUIBtn.Parent = TitleFrame

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseUIBtn

-- دوال تشغيل/إيقاف ماب سرقت البيض
local function EggsMapContainers()
	local list = {CoreGui, LocalPlayer:FindFirstChild("PlayerGui")}
	pcall(function()
		if typeof(gethui) == "function" then
			local h = gethui()
			if h then table.insert(list, h) end
		end
	end)
	return list
end

local function EggsMapSnapshot()
	local set = {}
	for _, container in ipairs(EggsMapContainers()) do
		if container then
			for _, child in ipairs(container:GetChildren()) do set[child] = true end
		end
	end
	return set
end

-- حذف أي واجهة أنشأها سكربت "فريق" بعد تشغيله (بدون المساس بواجهة السكربت الأساسي)
MvsTeam.RemoveNewGuis = function()
	for _, container in ipairs(EggsMapContainers()) do
		if container then
			for _, child in ipairs(container:GetChildren()) do
				if not MvsTeam.Before[child] and child ~= ScreenGui and child:IsA("ScreenGui")
					and child.Name ~= "Legendary_Core_UI" and not child.Name:find("Roblox") then
					pcall(function() child:Destroy() end)
				end
			end
		end
	end
end

-- ========================================================
-- 🚫 إخفاء الخطوط الصفراء (Tracers) - مشترك بين "فريق" و"ماب سرقت البيض"
-- بيخفي أي Beam / Trail / خط مجسم أصفر يظهر بعد التشغيل (والأسماء والمسافات بتفضل ظاهرة).
-- كمان بيخفي أي Beam بيوصل بين شخصيتين (لاعب ← لاعب) حتى لو لونه مش أصفر.
-- ========================================================
local LineKill = {
	Owners = {}, Hidden = {}, Pending = {}, Watch = {}, Conns = {},
	Bind = "AdamLineKill", Last = 0, On = false,
}

LineKill.IsCharBeam = function(b)
	local a0, a1 = b.Attachment0, b.Attachment1
	if not a0 or not a1 then return false end
	local m0 = a0:FindFirstAncestorOfClass("Model")
	local m1 = a1:FindFirstAncestorOfClass("Model")
	return m0 ~= nil and m1 ~= nil and m0 ~= m1
		and m0:FindFirstChildOfClass("Humanoid") ~= nil
		and m1:FindFirstChildOfClass("Humanoid") ~= nil
end

LineKill.Check = function(obj)
	local ok, res = pcall(function()
		if obj:IsA("Beam") and LineKill.IsCharBeam(obj) then return true end
		return MvsTeam.IsLine(obj)
	end)
	return ok and res
end

LineKill.Step = function()
	local now = os.clock()
	for obj, expire in pairs(LineKill.Pending) do
		if obj.Parent == nil or now > expire then
			LineKill.Pending[obj] = nil
		elseif LineKill.Check(obj) then
			LineKill.Hidden[obj] = true
			LineKill.Pending[obj] = nil
		end
	end
	-- إعادة فحص الـ Beams/Trails اللي لونها أو أطرافها اتحددت بعد ما اتعملت
	if now - LineKill.Last > 0.2 then
		LineKill.Last = now
		for obj in pairs(LineKill.Watch) do
			if obj.Parent == nil then
				LineKill.Watch[obj] = nil
			elseif not LineKill.Hidden[obj] and LineKill.Check(obj) then
				LineKill.Hidden[obj] = true
			end
		end
	end
	for obj in pairs(LineKill.Hidden) do
		if obj.Parent == nil then LineKill.Hidden[obj] = nil else MvsTeam.HideObj(obj) end
	end
end

LineKill.Start = function(owner)
	LineKill.Owners[owner] = true
	if LineKill.On then return end
	LineKill.On = true
	LineKill.Hidden, LineKill.Pending, LineKill.Watch = {}, {}, {}
	local function hook(root)
		pcall(function()
			table.insert(LineKill.Conns, root.DescendantAdded:Connect(function(d)
				if d:IsA("Beam") or d:IsA("Trail") or d:IsA("HandleAdornment") then
					LineKill.Watch[d] = true
					LineKill.Pending[d] = os.clock() + 3
				elseif d:IsA("BasePart") then
					LineKill.Pending[d] = os.clock() + 3
				end
			end))
		end)
	end
	hook(Workspace)
	for _, c in ipairs(EggsMapContainers()) do
		if c then hook(c) end
	end
	pcall(function()
		RunService:BindToRenderStep(LineKill.Bind, 2002, function() pcall(LineKill.Step) end)
	end)
end

LineKill.Stop = function(owner)
	LineKill.Owners[owner] = nil
	if next(LineKill.Owners) or not LineKill.On then return end
	LineKill.On = false
	pcall(function() RunService:UnbindFromRenderStep(LineKill.Bind) end)
	for _, c in ipairs(LineKill.Conns) do pcall(function() c:Disconnect() end) end
	LineKill.Conns = {}
	for obj in pairs(LineKill.Hidden) do pcall(function() obj:Destroy() end) end
	LineKill.Hidden, LineKill.Pending, LineKill.Watch = {}, {}, {}
end

-- ========================================================
-- 🎨 ربط حواف واجهة "فريق" بلون واجهة سكربت أدم
-- بيقرأ CurrentThemeColor و GradientStroke (نفس حواف سكربت أدم) كل فريم،
-- فأول ما تشغّل "فريق" بتطلع بنفس الحواف، ولما تغيّر اللون بتتغير معاه.
-- ========================================================
MvsTeam.PaintBorders = true -- خليها false لو مش عايز BorderColor3 يتغير (الـ UIStroke بس)
MvsTeam.ThemeBind = "MvsTeamThemeSync"
MvsTeam.ThemeConns = {}
MvsTeam.ThemeGuis = {}
MvsTeam.ThemeStrokes = {}
MvsTeam.ThemeBorders = {}

-- واجهة جديدة اتعملت بعد تشغيل "فريق" (مش واجهة سكربت أدم ومش واجهات Roblox)
MvsTeam.IsTeamGui = function(g)
	return g ~= nil and g:IsA("ScreenGui") and g ~= ScreenGui
		and not MvsTeam.Before[g] and g.Name ~= "Legendary_Core_UI"
		and not g.Name:find("Roblox")
end

-- نلوّن الحواف بس، مش خط الكتابة (Text outline)
MvsTeam.IsEdgeStroke = function(s)
	local p = s.Parent
	if p and (p:IsA("TextLabel") or p:IsA("TextButton") or p:IsA("TextBox")) then
		return s.ApplyStrokeMode == Enum.ApplyStrokeMode.Border
	end
	return true
end

MvsTeam.Track = function(d)
	if d:IsA("UIStroke") then
		MvsTeam.ThemeStrokes[d] = true
	elseif d:IsA("GuiObject") then
		MvsTeam.ThemeBorders[d] = true
	end
end

MvsTeam.PaintAll = function()
	local color = CurrentThemeColor
	local seq = GradientStroke.Color
	for s in pairs(MvsTeam.ThemeStrokes) do
		if s.Parent == nil then
			MvsTeam.ThemeStrokes[s] = nil
		elseif MvsTeam.IsEdgeStroke(s) then
			s.Color = color
			local g = s:FindFirstChildOfClass("UIGradient")
			if not g then
				g = Instance.new("UIGradient")
				g.Name = "ThemeSync"
				g.Parent = s
			end
			g.Color = seq
		end
	end
	if MvsTeam.PaintBorders then
		for o in pairs(MvsTeam.ThemeBorders) do
			if o.Parent == nil then
				MvsTeam.ThemeBorders[o] = nil
			elseif o.BorderSizePixel > 0 then
				o.BorderColor3 = color
			end
		end
	end
end

MvsTeam.HookGui = function(gui)
	if MvsTeam.ThemeGuis[gui] then return end
	MvsTeam.ThemeGuis[gui] = true
	for _, d in ipairs(gui:GetDescendants()) do MvsTeam.Track(d) end
	table.insert(MvsTeam.ThemeConns, gui.DescendantAdded:Connect(MvsTeam.Track))
end

MvsTeam.StopTheme = function()
	pcall(function() RunService:UnbindFromRenderStep(MvsTeam.ThemeBind) end)
	for _, c in ipairs(MvsTeam.ThemeConns) do pcall(function() c:Disconnect() end) end
	MvsTeam.ThemeConns = {}
	MvsTeam.ThemeGuis = {}
	MvsTeam.ThemeStrokes = {}
	MvsTeam.ThemeBorders = {}
end

MvsTeam.StartTheme = function()
	MvsTeam.StopTheme()
	for _, container in ipairs(EggsMapContainers()) do
		if container then
			table.insert(MvsTeam.ThemeConns, container.ChildAdded:Connect(function(child)
				if MvsTeam.IsTeamGui(child) then MvsTeam.HookGui(child) end
			end))
			for _, child in ipairs(container:GetChildren()) do
				if MvsTeam.IsTeamGui(child) then MvsTeam.HookGui(child) end
			end
		end
	end
	-- أولوية 2001 = بعد أي تعديل من سكربت "فريق" نفسه، فلونك هو اللي يظهر
	pcall(function()
		RunService:BindToRenderStep(MvsTeam.ThemeBind, 2001, function() pcall(MvsTeam.PaintAll) end)
	end)
end

-- إخفاء الخطوط (Tracers) الصفراء من واجهة فريق وإبقاء الأسماء فقط
-- الإخفاء بيتعمل كل فريم قبل الرسم مباشرة (بدون وميض)
MvsTeam.Pending = {}
MvsTeam.Hidden = {}
MvsTeam.Conns = {}
MvsTeam.Threads = {}
MvsTeam.Env = nil
MvsTeam.LineRun = 0
MvsTeam.BindName = "MvsTeamHideLines"

MvsTeam.IsYellow = function(c)
	return c ~= nil and c.R > 0.7 and c.G > 0.7 and c.B < 0.6
end
MvsTeam.IsLine = function(obj)
	if obj:IsA("Beam") or obj:IsA("Trail") then
		for _, k in ipairs(obj.Color.Keypoints) do
			if MvsTeam.IsYellow(k.Value) then return true end
		end
	elseif obj:IsA("HandleAdornment") then
		return MvsTeam.IsYellow(obj.Color3)
	elseif obj:IsA("BasePart") then
		if not MvsTeam.IsYellow(obj.Color) or obj.CanCollide then return false end
		local m = obj:FindFirstAncestorOfClass("Model")
		if m and m:FindFirstChildOfClass("Humanoid") then return false end
		local sz = obj.Size
		local a = { sz.X, sz.Y, sz.Z }
		table.sort(a)
		return a[2] < 1.5
	end
	return false
end
MvsTeam.HideObj = function(obj)
	pcall(function()
		if obj:IsA("Beam") then
			obj.Enabled = false
			obj.Transparency = NumberSequence.new(1)
		elseif obj:IsA("Trail") then
			obj.Enabled = false
		elseif obj:IsA("HandleAdornment") then
			obj.Visible = false
			obj.Transparency = 1
		elseif obj:IsA("BasePart") then
			obj.Transparency = 1
			obj.LocalTransparencyModifier = 1
		end
	end)
end
MvsTeam.Step = function()
	local now = os.clock()
	for obj, expire in pairs(MvsTeam.Pending) do
		if (not obj.Parent) or now > expire then
			MvsTeam.Pending[obj] = nil
		else
			local ok, isLine = pcall(MvsTeam.IsLine, obj)
			if ok and isLine then
				MvsTeam.Hidden[obj] = true
				MvsTeam.Pending[obj] = nil
			end
		end
	end
	for obj in pairs(MvsTeam.Hidden) do
		if obj.Parent then MvsTeam.HideObj(obj) else MvsTeam.Hidden[obj] = nil end
	end
end
MvsTeam.ShowLines = function()
	MvsTeam.LineRun = MvsTeam.LineRun + 1
	pcall(MvsTeam.StopTheme) -- يوقف مزامنة لون الحواف مع كل إغلاق
	pcall(LineKill.Stop, "team")
	pcall(function() game:GetService("RunService"):UnbindFromRenderStep(MvsTeam.BindName) end)
	for _, c in ipairs(MvsTeam.Conns) do pcall(function() c:Disconnect() end) end
	MvsTeam.Conns = {}
	MvsTeam.Pending = {}
	-- الخطوط تابعة لسكربت فريق، نحذف اللي اتخفى منها
	for obj in pairs(MvsTeam.Hidden) do pcall(function() obj:Destroy() end) end
	MvsTeam.Hidden = {}
	if MvsTeam.OrigDrawingNew then
		pcall(function() Drawing.new = MvsTeam.OrigDrawingNew end)
		MvsTeam.OrigDrawingNew = nil
	end
end
MvsTeam.HideLines = function()
	MvsTeam.ShowLines()
	-- خطوط Drawing: نرجّع كائن وهمي بدل الخط الحقيقي
	pcall(function()
		if type(Drawing) == "table" and type(Drawing.new) == "function" then
			local orig = Drawing.new
			MvsTeam.OrigDrawingNew = orig
			Drawing.new = function(class, ...)
				if class == "Line" then
					return { Visible = false, Remove = function() end, Destroy = function() end }
				end
				return orig(class, ...)
			end
		end
	end)
	-- خطوط 3D: أي جسم جديد نراقبه، ولو طلع خط أصفر نخفيه قبل أول رسم
	local roots = { Workspace }
	for _, c in ipairs(EggsMapContainers()) do if c then table.insert(roots, c) end end
	for _, root in ipairs(roots) do
		pcall(function()
			table.insert(MvsTeam.Conns, root.DescendantAdded:Connect(function(d)
				if d:IsA("Beam") or d:IsA("Trail") or d:IsA("HandleAdornment") or d:IsA("BasePart") then
					MvsTeam.Pending[d] = os.clock() + 3
				end
			end))
		end)
	end
	pcall(function()
		game:GetService("RunService"):BindToRenderStep(MvsTeam.BindName, 2000, MvsTeam.Step)
	end)
end

-- تجهيز بيئة معزولة لسكربت فريق عشان نقدر نوقف اللوبات والاتصالات بتاعته وقت الإغلاق
MvsTeam.SetupEnv = function(fn)
	pcall(function()
		local base = getfenv()
		local wt = setmetatable({}, { __index = task })
		local function track(th)
			if typeof(th) == "thread" then MvsTeam.Threads[th] = true end
			return th
		end
		wt.spawn = function(...) return track(task.spawn(...)) end
		wt.defer = function(...) return track(task.defer(...)) end
		wt.delay = function(...) return track(task.delay(...)) end
		local env = setmetatable({ task = wt, spawn = wt.spawn, delay = wt.delay }, { __index = base, __newindex = base })
		setfenv(fn, env)
		MvsTeam.Env = env
	end)
end

-- إيقاف كل اللي سكربت فريق شغّله (لوبات + اتصالات)
MvsTeam.KillNew = function()
	for th in pairs(MvsTeam.Threads) do
		if th ~= coroutine.running() then pcall(function() task.cancel(th) end) end
	end
	MvsTeam.Threads = {}
	local env = MvsTeam.Env
	if env and typeof(getconnections) == "function" then
		local RS = game:GetService("RunService")
		local sigs = {
			RS.RenderStepped, RS.Heartbeat, RS.Stepped,
			Players.PlayerAdded, Players.PlayerRemoving,
			UserInputService.InputBegan, UserInputService.InputEnded, UserInputService.JumpRequest,
			Workspace.DescendantAdded, Workspace.ChildAdded, LocalPlayer.CharacterAdded,
		}
		for _, sig in ipairs(sigs) do
			pcall(function()
				for _, c in ipairs(getconnections(sig)) do
					pcall(function()
						local f = c.Function
						if f and getfenv(f) == env then
							pcall(function() c:Disconnect() end)
							pcall(function() c:Disable() end)
						end
					end)
				end
			end)
		end
	end
	MvsTeam.Env = nil
end

-- استبدال الأسماء داخل واجهة ماب سرقت البيض (cebo hit / ceboscripts -> ادم وياسين)
local EggsMapNamePatterns = {
	"[cC][eE][bB][oO]%s*[hH][iI][tT]",
	"[cC][eE][bB][oO]%s*[sS][cC][rR][iI][pP][tT][sS]",
}

local function EggsMapRebrandText(text)
	for _, p in ipairs(EggsMapNamePatterns) do
		text = text:gsub(p, "ادم وياسين")
	end
	return text
end

local function EggsMapRebrandSweep()
	for _, container in ipairs(EggsMapContainers()) do
		if container then
			for _, child in ipairs(container:GetChildren()) do
				if not EggsMap.Before[child] and child ~= ScreenGui then
					pcall(function()
						local objs = child:GetDescendants()
						table.insert(objs, child)
						for _, d in ipairs(objs) do
							if d:IsA("TextLabel") or d:IsA("TextButton") then
								local t = d.Text
								local n = EggsMapRebrandText(t)
								if n ~= t then d.Text = n end
							end
						end
					end)
				end
			end
		end
	end
end

EggsMap.Stop = function()
	EggsMap.Active = false
	pcall(LineKill.Stop, "eggs")
	if EggsMap.Loaded then
		pcall(function()
			if typeof(EggsMap.Loaded) == "Instance" then
				EggsMap.Loaded:Destroy()
			elseif type(EggsMap.Loaded) == "table" and EggsMap.Loaded.Destroy then
				EggsMap.Loaded:Destroy()
			end
		end)
		EggsMap.Loaded = nil
	end
	-- حذف أي واجهة جديدة أنشأها السكربت بعد تشغيله
	for _, container in ipairs(EggsMapContainers()) do
		if container then
			for _, child in ipairs(container:GetChildren()) do
				if not EggsMap.Before[child] and child ~= ScreenGui and child:IsA("ScreenGui")
					and child.Name ~= "Legendary_Core_UI" and not child.Name:find("Roblox") then
					pcall(function() child:Destroy() end)
				end
			end
		end
	end
end

local function CleanScript()
	pcall(EggsMap.Stop)
	SpeedEnabled = false
	NoclipEnabled = false
	FlyEnabled = false
	PlatformEnabled = false
	InstantInteractEnabled = false
	ESPEnabled = false
	MM2ESPEnabled = false
	MultiJumpEnabled = false
	AutoHopEnabled = false
	FPSBoostEnabled = false
	MvsActiveState = false
	
	pcall(function()
		Lighting.GlobalShadows = true
		settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
	end)

	for _, hl in pairs(HighlightsTable) do
		if hl and hl.Parent then hl:Destroy() end
	end
	HighlightsTable = {}

	if BodyVelocity then BodyVelocity:Destroy() BodyVelocity = nil end
	if BodyGyro then BodyGyro:Destroy() BodyGyro = nil end
	if FollowPlatformPart then FollowPlatformPart:Destroy() FollowPlatformPart = nil end

	for _, highlight in pairs(MM2HighlightsTable) do if highlight then highlight:Destroy() end end
	MM2HighlightsTable = {}

	if MvsLoadedInstance then
		pcall(function()
			if typeof(MvsLoadedInstance) == "Instance" then
				MvsLoadedInstance:Destroy()
			elseif type(MvsLoadedInstance) == "table" and MvsLoadedInstance.Destroy then
				MvsLoadedInstance:Destroy()
			end
		end)
		MvsLoadedInstance = nil
	end
	MvsTeam.Run = MvsTeam.Run + 1
	pcall(MvsTeam.KillNew)
	pcall(MvsTeam.ShowLines)
	pcall(MvsTeam.RemoveNewGuis)

	pcall(function()
		for _, gui in pairs(CoreGui:GetChildren()) do
			if gui:IsA("ScreenGui") and gui.Name ~= "Legendary_Core_UI" and not gui.Name:find("Roblox") then
				gui:Destroy()
			end
		end
	end)

	local char = LocalPlayer.Character
	if char then
		local humanoid = char:FindFirstChildOfClass("Humanoid")
		if humanoid then 
			humanoid.WalkSpeed = 16 
			humanoid.JumpPower = 50
			humanoid.PlatformStand = false 
			humanoid.AutoRotate = true
		end
		for _, part in ipairs(char:GetDescendants()) do
			if part:IsA("BasePart") then part.Anchored = false end
		end
	end

	for _, conn in pairs(Connections) do if conn then conn:Disconnect() end end
	ScreenGui:Destroy()
end

CloseUIBtn.MouseButton1Click:Connect(CleanScript)

task.spawn(function()
	while task.wait(3) do
		if ScriptEnabled == false then
			showMaintenanceNotice()
			CleanScript()
			break
		end
	end
end)

local UIUpdaters = {}
local updateSpeedUI, updateFlyUI, updateMvsUI, updateFPSBoostUI

-- دالة التعريب التلقائي لاسم الواجهة الخارجية وجعله "فريق" فقط دون كلمات غريبة
local function translateTeamUI()
	pcall(function()
		for _, gui in pairs(CoreGui:GetChildren()) do
			if gui:IsA("ScreenGui") and gui.Name ~= "Legendary_Core_UI" and not gui.Name:find("Roblox") then
				for _, desc in ipairs(gui:GetDescendants()) do
					if desc:IsA("TextLabel") or desc:IsA("TextButton") then
						local txt = desc.Text
						if CurrentLang == "AR" then
							if txt:upper():find("ARHANGELS TEAM") or txt:upper():find("TEAM") or txt:upper():find("HUB") then
								desc.Text = "فريق"
							elseif txt:upper() == "OFF" then
								desc.Text = "إغلاق"
							elseif txt:upper() == "ON" then
								desc.Text = "تفعيل"
							end
						else
							if txt == "فريق" then
								desc.Text = "TEAM"
							elseif txt == "إغلاق" then
								desc.Text = "OFF"
							elseif txt == "تفعيل" then
								desc.Text = "ON"
							end
						end
					end
				end
			end
		end
	end)
end

LangBtnRef.MouseButton1Click:Connect(function()
	CurrentLang = (CurrentLang == "AR") and "EN" or "AR"
	local L = Translations[CurrentLang]
	
	LangBtnRef.Text = L.LangBtn
	TitleLabel.Text = L.Title
	TeleportInputRef.PlaceholderText = L.TeleportPlaceholder
	TeleportBtnRef.Text = L.TeleportBtn
	ServerHopPanelBtnRef.Text = L.ServerHopBtn
	UpdatesPanelBtnRef.Text = L.UpdatesBtn
	ThemePanelBtnRef.Text = L.ThemeBtn
	SavePosBtnRef.Text = L.SavePosBtn
	LoadPosBtnRef.Text = L.LoadPosBtn
	
	ServerHopInfoLabel.Text = L.ServerHopInfo
	ServerHopInput.PlaceholderText = L.HopThresholdPlaceholder
	HopOnceBtn.Text = L.HopOnceText
	AutoHopBtn.Text = AutoHopEnabled and L.AutoHopON or L.AutoHopOFF
	
	ThemeTitleText.Text = L.ThemeTitle
	ThemeGreenBtn.Text = L.ThemeGreen
	ThemeRedBtn.Text = L.ThemeRed
	ThemeBlueBtn.Text = L.ThemeBlue
	ThemePurpleBtn.Text = L.ThemePurple
	
	UpdatesTitle.Text = L.UpdatesTitleText
	UpdatesTextLabel.Text = L.UpdatesLogText
	FooterLabelRef.Text = L.Footer
	
	for _, updater in ipairs(UIUpdaters) do
		pcall(updater)
	end
	
	translateTeamUI()
end)

local function createSimpleToggle(posY, textKeyAR, textKeyEN, onClick)
	local button = Instance.new("TextButton")
	button.Size = UDim2.new(0.9, 0, 0, 32)
	button.Position = UDim2.new(0.05, 0, 0, posY)
	button.BackgroundColor3 = Color3.fromRGB(180, 45, 45)
	button.BackgroundTransparency = 0.35
	button.TextColor3 = Color3.fromRGB(255, 255, 255)
	button.TextSize = 10
	button.Font = Enum.Font.GothamSemibold
	button.Parent = MainFrame

	local btnCorner = Instance.new("UICorner")
	btnCorner.CornerRadius = UDim.new(0, 6)
	btnCorner.Parent = button

	local state = false
	local function updateText()
		local lang = Translations[CurrentLang]
		local titleText = (CurrentLang == "AR") and textKeyAR or textKeyEN
		local status = state and lang.ON or lang.OFF
		button.Text = titleText .. ": " .. status
		button.BackgroundColor3 = state and Color3.fromRGB(0, 180, 110) or Color3.fromRGB(180, 45, 45)
		button.BackgroundTransparency = 0.35
	end

	button.MouseButton1Click:Connect(function()
		state = not state
		updateText()
		onClick(state)
	end)

	table.insert(UIUpdaters, updateText)
	updateText()
	return button
end

-- 1. Walk Speed Section (Y: 64)
local SpeedInput = Instance.new("TextBox")
SpeedInput.Size = UDim2.new(0.28, 0, 0, 32)
SpeedInput.Position = UDim2.new(0.05, 0, 0, 64)
SpeedInput.BackgroundColor3 = Color3.fromRGB(18, 22, 32)
SpeedInput.BackgroundTransparency = 0.4
SpeedInput.Text = "50"
SpeedInput.PlaceholderText = "1-200"
SpeedInput.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedInput.TextSize = 11
SpeedInput.Font = Enum.Font.GothamBold
SpeedInput.Parent = MainFrame

local SpeedInputCorner = Instance.new("UICorner")
SpeedInputCorner.CornerRadius = UDim.new(0, 6)
SpeedInputCorner.Parent = SpeedInput

SpeedBtnRef = Instance.new("TextButton")
SpeedBtnRef.Size = UDim2.new(0.61, 0, 0, 32)
SpeedBtnRef.Position = UDim2.new(0.34, 0, 0, 64)
SpeedBtnRef.BackgroundColor3 = Color3.fromRGB(180, 45, 45)
SpeedBtnRef.BackgroundTransparency = 0.35
SpeedBtnRef.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedBtnRef.TextSize = 10
SpeedBtnRef.Font = Enum.Font.GothamSemibold
SpeedBtnRef.Parent = MainFrame

local SpeedBtnCorner = Instance.new("UICorner")
SpeedBtnCorner.CornerRadius = UDim.new(0, 6)
SpeedBtnCorner.Parent = SpeedBtnRef

updateSpeedUI = function()
	local lang = Translations[CurrentLang]
	local titleName = (CurrentLang == "AR") and Translations.AR.SpeedText or Translations.EN.SpeedText
	local status = SpeedEnabled and lang.ON or lang.OFF
	SpeedBtnRef.Text = titleName .. " (" .. WalkSpeedVal .. "): " .. status
	SpeedBtnRef.BackgroundColor3 = SpeedEnabled and Color3.fromRGB(0, 180, 110) or Color3.fromRGB(180, 45, 45)
	SpeedBtnRef.BackgroundTransparency = 0.35
end
table.insert(UIUpdaters, updateSpeedUI)

SpeedInput.FocusLost:Connect(function()
	local num = tonumber(SpeedInput.Text)
	if num then WalkSpeedVal = math.clamp(math.floor(num), 1, 200) SpeedInput.Text = tostring(WalkSpeedVal)
	else SpeedInput.Text = tostring(WalkSpeedVal) end
	updateSpeedUI()
end)

SpeedBtnRef.MouseButton1Click:Connect(function()
	SpeedEnabled = not SpeedEnabled
	updateSpeedUI()
end)

table.insert(Connections, RunService.RenderStepped:Connect(function(delta)
	if SpeedEnabled and not FlyEnabled then
		local char = LocalPlayer.Character
		if char then
			local humanoid = char:FindFirstChildOfClass("Humanoid")
			local hrp = char:FindFirstChild("HumanoidRootPart")
			if humanoid and hrp and humanoid.MoveDirection.Magnitude > 0 then
				local moveMultiplier = (WalkSpeedVal / 16) - 1
				if moveMultiplier > 0 then
					hrp.CFrame = hrp.CFrame + (humanoid.MoveDirection * (moveMultiplier * 16 * delta))
				end
			end
		end
	end
end))

updateSpeedUI()

-- 2. Fly Section (Y: 104)
local FlyInput = Instance.new("TextBox")
FlyInput.Size = UDim2.new(0.28, 0, 0, 32)
FlyInput.Position = UDim2.new(0.05, 0, 0, 104)
FlyInput.BackgroundColor3 = Color3.fromRGB(18, 22, 32)
FlyInput.BackgroundTransparency = 0.4
FlyInput.Text = "50"
FlyInput.PlaceholderText = "1-100"
FlyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
FlyInput.TextSize = 11
FlyInput.Font = Enum.Font.GothamBold
FlyInput.Parent = MainFrame

local FlyInputCorner = Instance.new("UICorner")
FlyInputCorner.CornerRadius = UDim.new(0, 6)
FlyInputCorner.Parent = FlyInput

FlyBtnRef = Instance.new("TextButton")
FlyBtnRef.Size = UDim2.new(0.61, 0, 0, 32)
FlyBtnRef.Position = UDim2.new(0.34, 0, 0, 104)
FlyBtnRef.BackgroundColor3 = Color3.fromRGB(200, 160, 0)
FlyBtnRef.BackgroundTransparency = 0.35
FlyBtnRef.TextColor3 = Color3.fromRGB(255, 255, 255)
FlyBtnRef.TextSize = 10
FlyBtnRef.Font = Enum.Font.GothamSemibold
FlyBtnRef.Parent = MainFrame

local FlyBtnCorner = Instance.new("UICorner")
FlyBtnCorner.CornerRadius = UDim.new(0, 6)
FlyBtnCorner.Parent = FlyBtnRef

updateFlyUI = function()
	local lang = Translations[CurrentLang]
	local titleName = (CurrentLang == "AR") and Translations.AR.FlyText or Translations.EN.FlyText
	local status = FlyEnabled and lang.ON or lang.OFF
	FlyBtnRef.Text = titleName .. " (" .. FlySpeedVal .. "): " .. status
	FlyBtnRef.BackgroundColor3 = FlyEnabled and Color3.fromRGB(0, 180, 110) or Color3.fromRGB(200, 160, 0)
	FlyBtnRef.BackgroundTransparency = 0.35
end
table.insert(UIUpdaters, updateFlyUI)

FlyInput.FocusLost:Connect(function()
	local num = tonumber(FlyInput.Text)
	if num then 
		FlySpeedVal = math.clamp(math.floor(num), 1, 100) 
		FlyInput.Text = tostring(FlySpeedVal) 
	end
	updateFlyUI()
end)

FlyBtnRef.MouseButton1Click:Connect(function()
	FlyEnabled = not FlyEnabled
	updateFlyUI()
	local char = LocalPlayer.Character
	if not char then return end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	local humanoid = char:FindFirstChildOfClass("Humanoid")
	if not hrp or not humanoid then return end

	if FlyEnabled then
		humanoid.PlatformStand = true
		BodyVelocity = Instance.new("BodyVelocity")
		BodyVelocity.MaxForce = Vector3.new(1, 1, 1) * 400000
		BodyVelocity.Velocity = Vector3.zero
		BodyVelocity.Parent = hrp
		BodyGyro = Instance.new("BodyGyro")
		BodyGyro.MaxTorque = Vector3.new(1, 1, 1) * 400000
		BodyGyro.P = 9000
		BodyGyro.CFrame = hrp.CFrame
		BodyGyro.Parent = hrp
	else
		humanoid.PlatformStand = false
		if BodyVelocity then BodyVelocity:Destroy() BodyVelocity = nil end
		if BodyGyro then BodyGyro:Destroy() BodyGyro = nil end
	end
end)

table.insert(Connections, RunService.RenderStepped:Connect(function()
	if FlyEnabled and BodyVelocity and BodyGyro then
		local char = LocalPlayer.Character
		if char then
			local hrp = char:FindFirstChild("HumanoidRootPart")
			local camera = Workspace.CurrentCamera
			if hrp and camera then
				local moveDir = Vector3.zero
				if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + camera.CFrame.LookVector end
				if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - camera.CFrame.LookVector end
				if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - camera.CFrame.RightVector end
				if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + camera.CFrame.RightVector end
				if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
				if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir - Vector3.new(0, 1, 0) end
				
				BodyVelocity.Velocity = moveDir * (FlySpeedVal * 0.9)
				BodyGyro.CFrame = camera.CFrame
			end
		end
	end
end))

updateFlyUI()

-- 3. Noclip Button (Y: 144)
createSimpleToggle(144, Translations.AR.NoclipText, Translations.EN.NoclipText, function(enabled) NoclipEnabled = enabled end)
table.insert(Connections, RunService.Stepped:Connect(function()
	if NoclipEnabled then
		local char = LocalPlayer.Character
		if char then
			for _, part in pairs(char:GetDescendants()) do
				if part:IsA("BasePart") and part.CanCollide then part.CanCollide = false end
			end
		end
	end
end))

-- 4. Stand Platform Button (Y: 184)
PlatformBtnRef = Instance.new("TextButton")
PlatformBtnRef.Size = UDim2.new(0.72, 0, 0, 32)
PlatformBtnRef.Position = UDim2.new(0.05, 0, 0, 184)
PlatformBtnRef.BackgroundColor3 = Color3.fromRGB(180, 45, 45)
PlatformBtnRef.BackgroundTransparency = 0.35
PlatformBtnRef.TextColor3 = Color3.fromRGB(255, 255, 255)
PlatformBtnRef.TextSize = 10
PlatformBtnRef.Font = Enum.Font.GothamSemibold
PlatformBtnRef.Parent = MainFrame

local platformCorner = Instance.new("UICorner")
platformCorner.CornerRadius = UDim.new(0, 6)
platformCorner.Parent = PlatformBtnRef

local PlatformKeyBtn = Instance.new("TextButton")
PlatformKeyBtn.Size = UDim2.new(0.16, 0, 0, 32)
PlatformKeyBtn.Position = UDim2.new(0.79, 0, 0, 184)
PlatformKeyBtn.BackgroundColor3 = Color3.fromRGB(40, 50, 70)
PlatformKeyBtn.BackgroundTransparency = 0.3
PlatformKeyBtn.Text = "[ F ]"
PlatformKeyBtn.TextColor3 = Color3.fromRGB(0, 255, 170)
PlatformKeyBtn.TextSize = 10
PlatformKeyBtn.Font = Enum.Font.GothamBold
PlatformKeyBtn.Parent = MainFrame

local platformKeyCorner = Instance.new("UICorner")
platformKeyCorner.CornerRadius = UDim.new(0, 6)
platformKeyCorner.Parent = PlatformKeyBtn

local function updatePlatformState(newState)
	PlatformEnabled = newState
	local lang = Translations[CurrentLang]
	local platformText = (CurrentLang == "AR") and Translations.AR.PlatformText or Translations.EN.PlatformText
	local status = PlatformEnabled and lang.ON or lang.OFF
	PlatformBtnRef.Text = platformText .. ": " .. status
	PlatformBtnRef.BackgroundColor3 = PlatformEnabled and Color3.fromRGB(0, 180, 110) or Color3.fromRGB(180, 45, 45)
	PlatformBtnRef.BackgroundTransparency = 0.35
	
	if PlatformEnabled then
		if not FollowPlatformPart then
			FollowPlatformPart = Instance.new("Part")
			FollowPlatformPart.Name = "StandPlatform"
			FollowPlatformPart.Size = Vector3.new(6, 0.8, 6)
			FollowPlatformPart.Transparency = 0.4
			FollowPlatformPart.Color = Color3.fromRGB(0, 220, 110)
			FollowPlatformPart.Material = Enum.Material.Neon
			FollowPlatformPart.Anchored = true
			FollowPlatformPart.CanCollide = true
			FollowPlatformPart.Parent = Workspace
		end
	else
		if FollowPlatformPart then FollowPlatformPart:Destroy() FollowPlatformPart = nil end
	end
end

table.insert(UIUpdaters, function()
	updatePlatformState(PlatformEnabled)
end)

PlatformBtnRef.MouseButton1Click:Connect(function()
	updatePlatformState(not PlatformEnabled)
end)

PlatformKeyBtn.MouseButton1Click:Connect(function()
	updatePlatformState(not PlatformEnabled)
end)

table.insert(Connections, UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.F then
		updatePlatformState(not PlatformEnabled)
	end
end))

updatePlatformState(false)

table.insert(Connections, RunService.RenderStepped:Connect(function()
	if PlatformEnabled and FollowPlatformPart then
		local char = LocalPlayer.Character
		if char and char:FindFirstChild("HumanoidRootPart") then
			FollowPlatformPart.CFrame = CFrame.new(char.HumanoidRootPart.Position.X, char.HumanoidRootPart.Position.Y - 3.4, char.HumanoidRootPart.Position.Z)
		end
	end
end))

-- 5. Instant Interactions Button (Y: 224)
createSimpleToggle(224, Translations.AR.InstantInteractText, Translations.EN.InstantInteractText, function(enabled) InstantInteractEnabled = enabled end)
table.insert(Connections, ProximityPromptService.PromptShown:Connect(function(prompt)
	if InstantInteractEnabled then prompt.HoldDuration = 0 end
end))

-- 6. Player ESP Button (Y: 264)
createSimpleToggle(264, Translations.AR.ESPText, Translations.EN.ESPText, function(enabled)
	ESPEnabled = enabled
	if not ESPEnabled then
		for _, hl in pairs(HighlightsTable) do
			if hl and hl.Parent then hl:Destroy() end
		end
		HighlightsTable = {}
	end
end)

table.insert(Connections, RunService.RenderStepped:Connect(function()
	if not ESPEnabled then return end
	for _, player in pairs(Players:GetPlayers()) do
		if player ~= LocalPlayer then
			local char = player.Character
			local humanoid = char and char:FindFirstChildOfClass("Humanoid")
			if char and humanoid and humanoid.Health > 0 then
				local hl = HighlightsTable[player]
				if not hl or not hl.Parent or hl.Adornee ~= char then
					if hl then pcall(function() hl:Destroy() end) end
					hl = Instance.new("Highlight")
					hl.Name = "Player_ESP"
					hl.Adornee = char
					hl.FillColor = Color3.fromRGB(255, 45, 45)
					hl.FillTransparency = 0.5
					hl.OutlineColor = Color3.fromRGB(255, 255, 255)
					hl.OutlineTransparency = 0
					hl.Parent = char
					HighlightsTable[player] = hl
				end
			else
				if HighlightsTable[player] then
					pcall(function() HighlightsTable[player]:Destroy() end)
					HighlightsTable[player] = nil
				end
			end
		end
	end
end))

-- 7. MM2 Role Reveal Button (Y: 304)
createSimpleToggle(304, Translations.AR.MM2ESPText, Translations.EN.MM2ESPText, function(enabled)
	MM2ESPEnabled = enabled
	if not MM2ESPEnabled then
		for _, hl in pairs(MM2HighlightsTable) do if hl then hl:Destroy() end end
		MM2HighlightsTable = {}
	end
end)

table.insert(Connections, RunService.RenderStepped:Connect(function()
	if not MM2ESPEnabled then return end
	for _, player in pairs(Players:GetPlayers()) do
		if player ~= LocalPlayer then
			local char = player.Character
			local humanoid = char and char:FindFirstChildOfClass("Humanoid")
			if char and humanoid and humanoid.Health > 0 then
				local backpack = player:FindFirstChild("Backpack")
				local hasKnife = false
				local hasGun = false
				local function checkItem(item)
					if item:IsA("Tool") then
						local name = string.lower(item.Name)
						if name:find("knife") or name:find("cuchillo") or item:FindFirstChild("Knife") then hasKnife = true end
						if name == "gun" or name == "revolver" or name == "sheriffgun" then hasGun = true end
					end
				end
				for _, item in pairs(char:GetChildren()) do checkItem(item) end
				if backpack then for _, item in pairs(backpack:GetChildren()) do checkItem(item) end end
				
				local existingHl = MM2HighlightsTable[player]
				if not existingHl or not existingHl.Parent or existingHl.Adornee ~= char then
					if existingHl then existingHl:Destroy() end
					existingHl = Instance.new("Highlight")
					existingHl.Name = "MM2_Role_Highlight"
					existingHl.Adornee = char
					existingHl.OutlineColor = Color3.fromRGB(255, 255, 255)
					existingHl.FillTransparency = 0.4
					existingHl.Parent = char
					MM2HighlightsTable[player] = existingHl
				end
				
				if hasKnife then
					existingHl.FillColor = Color3.fromRGB(255, 0, 0)
				elseif hasGun then
					existingHl.FillColor = Color3.fromRGB(0, 100, 255)
				else
					existingHl.FillColor = Color3.fromRGB(255, 255, 0)
				end
			else
				if MM2HighlightsTable[player] then
					pcall(function() MM2HighlightsTable[player]:Destroy() end)
					MM2HighlightsTable[player] = nil
				end
			end
		end
	end
end))

-- 8. Multi-Jump Button (Y: 344)
createSimpleToggle(344, Translations.AR.MultiJumpText, Translations.EN.MultiJumpText, function(enabled)
	MultiJumpEnabled = enabled
end)

table.insert(Connections, UserInputService.JumpRequest:Connect(function()
	if MultiJumpEnabled then
		local char = LocalPlayer.Character
		if char then
			local humanoid = char:FindFirstChildOfClass("Humanoid")
			local hrp = char:FindFirstChild("HumanoidRootPart")
			if humanoid and hrp then
				humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
				hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, 50, hrp.AssemblyLinearVelocity.Z)
			end
		end
	end
end))

-- 9. زر "فريق" التفاعلي (Y: 384)
MVSButtonRef = Instance.new("TextButton")
MVSButtonRef.Size = UDim2.new(0.9, 0, 0, 32)
MVSButtonRef.Position = UDim2.new(0.05, 0, 0, 384)
MVSButtonRef.BackgroundColor3 = Color3.fromRGB(180, 45, 45)
MVSButtonRef.BackgroundTransparency = 0.35
MVSButtonRef.TextColor3 = Color3.fromRGB(255, 255, 255)
MVSButtonRef.TextSize = 10
MVSButtonRef.Font = Enum.Font.GothamBold
MVSButtonRef.Parent = MainFrame

local MVSButtonCorner = Instance.new("UICorner")
MVSButtonCorner.CornerRadius = UDim.new(0, 6)
MVSButtonCorner.Parent = MVSButtonRef

updateMvsUI = function()
	if MvsActiveState then
		MVSButtonRef.Text = Translations[CurrentLang].MvsTextActive
		MVSButtonRef.BackgroundColor3 = Color3.fromRGB(0, 180, 110)
	else
		MVSButtonRef.Text = Translations[CurrentLang].MvsTextClosed
		MVSButtonRef.BackgroundColor3 = Color3.fromRGB(180, 45, 45)
	end
	MVSButtonRef.BackgroundTransparency = 0.35
end
table.insert(UIUpdaters, updateMvsUI)
updateMvsUI()

MVSButtonRef.MouseButton1Click:Connect(function()
	MvsActiveState = not MvsActiveState
	updateMvsUI()
	
	if MvsActiveState then
		MvsTeam.Before = EggsMapSnapshot()
		MvsTeam.Run = MvsTeam.Run + 1
		local myRun = MvsTeam.Run
		MvsTeam.HideLines()
		MvsTeam.StartTheme()
		LineKill.Start("team")
		task.spawn(function()
			MvsTeam.Threads[coroutine.running()] = true
			local ok, result = pcall(function()
				local fn, err = loadstring(MvsTeam.Source)
				if not fn then error(err) end
				MvsTeam.SetupEnv(fn)
				return fn()
			end)
			if not ok then
				if MvsTeam.Run == myRun then
					MvsActiveState = false
					updateMvsUI()
					pcall(MvsTeam.KillNew)
					pcall(MvsTeam.ShowLines)
					pcall(function()
						StarterGui:SetCore("SendNotification", {
							Title = (CurrentLang == "AR") and "خطأ ⚠️" or "Error ⚠️",
							Text = (CurrentLang == "AR") and "تعذر تشغيل فريق" or "Failed to run Team",
							Duration = 4
						})
					end)
				end
			elseif MvsActiveState and MvsTeam.Run == myRun then
				MvsLoadedInstance = result
			else
				-- تم الإغلاق أثناء التحميل
				pcall(function()
					if typeof(result) == "Instance" then result:Destroy() end
				end)
				pcall(MvsTeam.RemoveNewGuis)
			end
		end)
		task.delay(1, function()
			translateTeamUI()
		end)
	else
		MvsTeam.Run = MvsTeam.Run + 1
		pcall(MvsTeam.KillNew)
		pcall(MvsTeam.ShowLines)
		if MvsLoadedInstance then
			pcall(function()
				if typeof(MvsLoadedInstance) == "Instance" then
					MvsLoadedInstance:Destroy()
				elseif type(MvsLoadedInstance) == "table" and MvsLoadedInstance.Destroy then
					MvsLoadedInstance:Destroy()
				end
			end)
			MvsLoadedInstance = nil
		end
		pcall(MvsTeam.RemoveNewGuis)
		
		pcall(function()
			for _, gui in pairs(CoreGui:GetChildren()) do
				if gui:IsA("ScreenGui") and gui.Name ~= "Legendary_Core_UI" and not gui.Name:find("Roblox") then
					gui:Destroy()
				end
			end
		end)
	end
end)

-- 10. FPS Boost / Anti-Lag Button (Y: 424)
FPSBoostBtnRef = Instance.new("TextButton")
FPSBoostBtnRef.Size = UDim2.new(0.9, 0, 0, 32)
FPSBoostBtnRef.Position = UDim2.new(0.05, 0, 0, 424)
FPSBoostBtnRef.BackgroundColor3 = Color3.fromRGB(180, 45, 45)
FPSBoostBtnRef.BackgroundTransparency = 0.35
FPSBoostBtnRef.TextColor3 = Color3.fromRGB(255, 255, 255)
FPSBoostBtnRef.TextSize = 10
FPSBoostBtnRef.Font = Enum.Font.GothamSemibold
FPSBoostBtnRef.Parent = MainFrame

local FPSCorner = Instance.new("UICorner")
FPSCorner.CornerRadius = UDim.new(0, 6)
FPSCorner.Parent = FPSBoostBtnRef

updateFPSBoostUI = function()
	local lang = Translations[CurrentLang]
	local titleName = (CurrentLang == "AR") and Translations.AR.FPSBoostText or Translations.EN.FPSBoostText
	local status = FPSBoostEnabled and lang.ON or lang.OFF
	FPSBoostBtnRef.Text = titleName .. ": " .. status
	FPSBoostBtnRef.BackgroundColor3 = FPSBoostEnabled and Color3.fromRGB(0, 180, 110) or Color3.fromRGB(180, 45, 45)
	FPSBoostBtnRef.BackgroundTransparency = 0.35
end
table.insert(UIUpdaters, updateFPSBoostUI)

FPSBoostBtnRef.MouseButton1Click:Connect(function()
	FPSBoostEnabled = not FPSBoostEnabled
	updateFPSBoostUI()
	
	pcall(function()
		if FPSBoostEnabled then
			Lighting.GlobalShadows = false
			Lighting.FogEnd = 999999
			settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
			if Terrain then
				Terrain.WaterWaveSize = 0
				Terrain.WaterWaveSpeed = 0
				Terrain.WaterReflectance = 0
				Terrain.WaterTransparency = 0
			end
			for _, obj in ipairs(Workspace:GetDescendants()) do
				if obj:IsA("BasePart") then
					obj.Material = Enum.Material.SmoothPlastic
					obj.Reflectance = 0
				elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") then
					obj.Enabled = false
				end
			end
		else
			Lighting.GlobalShadows = true
			Lighting.FogEnd = 100000
			settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
			if Terrain then
				Terrain.WaterWaveSize = 1
				Terrain.WaterWaveSpeed = 8
				Terrain.WaterReflectance = 1
				Terrain.WaterTransparency = 0
			end
			for _, obj in ipairs(Workspace:GetDescendants()) do
				if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") then
					obj.Enabled = true
				end
			end
		end
	end)
end)
updateFPSBoostUI()

-- 11. Spacer Label (Y: 464)
local HitboxSpacerLabel = Instance.new("TextLabel")
HitboxSpacerLabel.Size = UDim2.new(0.9, 0, 0, 32)
HitboxSpacerLabel.Position = UDim2.new(0.05, 0, 0, 464)
HitboxSpacerLabel.BackgroundTransparency = 1
HitboxSpacerLabel.Text = (CurrentLang == "AR") and "⚡ سكربتات وتحكم متقدم ⚡" or "⚡ Advanced Controls & Tools ⚡"
HitboxSpacerLabel.TextColor3 = Color3.fromRGB(150, 160, 180)
HitboxSpacerLabel.TextSize = 10
HitboxSpacerLabel.Font = Enum.Font.GothamBold
HitboxSpacerLabel.TextXAlignment = Enum.TextXAlignment.Center
HitboxSpacerLabel.Parent = MainFrame

table.insert(UIUpdaters, function()
	HitboxSpacerLabel.Text = (CurrentLang == "AR") and "⚡ سكربتات وتحكم متقدم ⚡" or "⚡ Advanced Controls & Tools ⚡"
end)

local function TeleportToSavedWaypoint()
	if SavedPosition then
		local char = LocalPlayer.Character
		if char and char:FindFirstChild("HumanoidRootPart") then
			char.HumanoidRootPart.CFrame = SavedPosition + Vector3.new(0, 3, 0)
		end
	else
		pcall(function()
			StarterGui:SetCore("SendNotification", {
				Title = (CurrentLang == "AR") and "تنبيه ⚠️" or "Warning ⚠️",
				Text = (CurrentLang == "AR") and "لم تقم بحفظ أي مكان بعد!" or "No saved position found!",
				Duration = 3
			})
		end)
	end
end

-- 12. Save Position & Teleport to Saved Position Buttons (Y: 504)
SavePosBtnRef = Instance.new("TextButton")
SavePosBtnRef.Size = UDim2.new(0.43, 0, 0, 32)
SavePosBtnRef.Position = UDim2.new(0.05, 0, 0, 504)
SavePosBtnRef.BackgroundColor3 = Color3.fromRGB(200, 140, 0)
SavePosBtnRef.BackgroundTransparency = 0.35
SavePosBtnRef.TextColor3 = Color3.fromRGB(255, 255, 255)
SavePosBtnRef.TextSize = 10
SavePosBtnRef.Font = Enum.Font.GothamBold
SavePosBtnRef.Text = Translations[CurrentLang].SavePosBtn
SavePosBtnRef.Parent = MainFrame

local SavePosCorner = Instance.new("UICorner")
SavePosCorner.CornerRadius = UDim.new(0, 6)
SavePosCorner.Parent = SavePosBtnRef

LoadPosBtnRef = Instance.new("TextButton")
LoadPosBtnRef.Size = UDim2.new(0.43, 0, 0, 32)
LoadPosBtnRef.Position = UDim2.new(0.52, 0, 0, 504)
LoadPosBtnRef.BackgroundColor3 = Color3.fromRGB(0, 160, 110)
LoadPosBtnRef.BackgroundTransparency = 0.35
LoadPosBtnRef.TextColor3 = Color3.fromRGB(255, 255, 255)
LoadPosBtnRef.TextSize = 9
LoadPosBtnRef.Font = Enum.Font.GothamBold
LoadPosBtnRef.Text = Translations[CurrentLang].LoadPosBtn
LoadPosBtnRef.Parent = MainFrame

local LoadPosCorner = Instance.new("UICorner")
LoadPosCorner.CornerRadius = UDim.new(0, 6)
LoadPosCorner.Parent = LoadPosBtnRef

SavePosBtnRef.MouseButton1Click:Connect(function()
	local char = LocalPlayer.Character
	if char and char:FindFirstChild("HumanoidRootPart") then
		SavedPosition = char.HumanoidRootPart.CFrame
		pcall(function()
			StarterGui:SetCore("SendNotification", {
				Title = (CurrentLang == "AR") and "تم الحفظ 📍" or "Saved 📍",
				Text = (CurrentLang == "AR") and "تم حفظ المكان! اضغط على زر الانتقال للمحفوظ للرجوع إليه" or "Position saved! Click Teleport Saved to return.",
				Duration = 3
			})
		end)
	end
end)

LoadPosBtnRef.MouseButton1Click:Connect(TeleportToSavedWaypoint)

-- 13. Teleport to Player Section (Y: 544)
TeleportInputRef = Instance.new("TextBox")
TeleportInputRef.Size = UDim2.new(0.58, 0, 0, 32)
TeleportInputRef.Position = UDim2.new(0.05, 0, 0, 544)
TeleportInputRef.BackgroundTransparency = 0.4
TeleportInputRef.BackgroundColor3 = Color3.fromRGB(18, 22, 32)
TeleportInputRef.Text = ""
TeleportInputRef.PlaceholderText = Translations[CurrentLang].TeleportPlaceholder
TeleportInputRef.TextColor3 = Color3.fromRGB(255, 255, 255)
TeleportInputRef.TextSize = 11
TeleportInputRef.Font = Enum.Font.GothamBold
TeleportInputRef.Parent = MainFrame

local TeleportInputCorner = Instance.new("UICorner")
TeleportInputCorner.CornerRadius = UDim.new(0, 6)
TeleportInputCorner.Parent = TeleportInputRef

TeleportBtnRef = Instance.new("TextButton")
TeleportBtnRef.Size = UDim2.new(0.29, 0, 0, 32)
TeleportBtnRef.Position = UDim2.new(0.66, 0, 0, 544)
TeleportBtnRef.BackgroundColor3 = Color3.fromRGB(0, 160, 220)
TeleportBtnRef.BackgroundTransparency = 0.3
TeleportBtnRef.Text = Translations[CurrentLang].TeleportBtn
TeleportBtnRef.TextColor3 = Color3.fromRGB(255, 255, 255)
TeleportBtnRef.TextSize = 11
TeleportBtnRef.Font = Enum.Font.GothamBold
TeleportBtnRef.Parent = MainFrame

local TeleportBtnCorner = Instance.new("UICorner")
TeleportBtnCorner.CornerRadius = UDim.new(0, 6)
TeleportBtnCorner.Parent = TeleportBtnRef

TeleportBtnRef.MouseButton1Click:Connect(function()
	local targetName = string.lower(TeleportInputRef.Text)
	if targetName == "" then return end
	for _, player in pairs(Players:GetPlayers()) do
		if player ~= LocalPlayer then
			if string.lower(player.Name):sub(1, #targetName) == targetName or string.lower(player.DisplayName):sub(1, #targetName) == targetName then
				if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
					local char = LocalPlayer.Character
					if char and char:FindFirstChild("HumanoidRootPart") then
						char.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
					end
				end
				break
			end
		end
	end
end)

-- 14. Server Hop System Button (Y: 584)
ServerHopPanelBtnRef = Instance.new("TextButton")
ServerHopPanelBtnRef.Size = UDim2.new(0.9, 0, 0, 32)
ServerHopPanelBtnRef.Position = UDim2.new(0.05, 0, 0, 584)
ServerHopPanelBtnRef.BackgroundColor3 = Color3.fromRGB(80, 50, 180)
ServerHopPanelBtnRef.BackgroundTransparency = 0.35
ServerHopPanelBtnRef.TextColor3 = Color3.fromRGB(255, 255, 255)
ServerHopPanelBtnRef.TextSize = 11
ServerHopPanelBtnRef.Font = Enum.Font.GothamSemibold
ServerHopPanelBtnRef.Text = Translations[CurrentLang].ServerHopBtn
ServerHopPanelBtnRef.Parent = MainFrame

local ServerHopCorner = Instance.new("UICorner")
ServerHopCorner.CornerRadius = UDim.new(0, 6)
ServerHopCorner.Parent = ServerHopPanelBtnRef

ServerHopFrame = Instance.new("Frame")
ServerHopFrame.Size = UDim2.new(0, 280, 0, 220)
ServerHopFrame.Position = UDim2.new(1.05, 0, 0, 0)
ServerHopFrame.BackgroundColor3 = Color3.fromRGB(15, 18, 28)
ServerHopFrame.BackgroundTransparency = 0.05
ServerHopFrame.BorderSizePixel = 0
ServerHopFrame.Visible = false
ServerHopFrame.Parent = MainFrame

local HopFrameCorner = Instance.new("UICorner")
HopFrameCorner.CornerRadius = UDim.new(0, 14)
HopFrameCorner.Parent = ServerHopFrame

HopFrameStroke = Instance.new("UIStroke")
HopFrameStroke.Thickness = 2.5
HopFrameStroke.Color = CurrentThemeColor
HopFrameStroke.Parent = ServerHopFrame

ServerHopCloseBtn = Instance.new("TextButton")
ServerHopCloseBtn.Size = UDim2.new(0, 26, 0, 26)
ServerHopCloseBtn.Position = UDim2.new(0.88, 0, 0.04, 0)
ServerHopCloseBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
ServerHopCloseBtn.BackgroundTransparency = 0.3
ServerHopCloseBtn.Text = "X"
ServerHopCloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ServerHopCloseBtn.TextSize = 11
ServerHopCloseBtn.Font = Enum.Font.GothamBold
ServerHopCloseBtn.Parent = ServerHopFrame

local HopCloseCorner = Instance.new("UICorner")
HopCloseCorner.CornerRadius = UDim.new(0, 6)
HopCloseCorner.Parent = ServerHopCloseBtn

ServerHopInfoLabel = Instance.new("TextLabel")
ServerHopInfoLabel.Size = UDim2.new(0.9, 0, 0, 50)
ServerHopInfoLabel.Position = UDim2.new(0.05, 0, 0.15, 0)
ServerHopInfoLabel.BackgroundTransparency = 1
ServerHopInfoLabel.Text = Translations[CurrentLang].ServerHopInfo
ServerHopInfoLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
ServerHopInfoLabel.TextSize = 10
ServerHopInfoLabel.Font = Enum.Font.Gotham
ServerHopInfoLabel.TextWrapped = true
ServerHopInfoLabel.Parent = ServerHopFrame

ServerHopInput = Instance.new("TextBox")
ServerHopInput.Size = UDim2.new(0.9, 0, 0, 32)
ServerHopInput.Position = UDim2.new(0.05, 0, 0.42, 0)
ServerHopInput.BackgroundColor3 = Color3.fromRGB(22, 28, 42)
ServerHopInput.BackgroundTransparency = 0.3
ServerHopInput.Text = "1"
ServerHopInput.PlaceholderText = Translations[CurrentLang].HopThresholdPlaceholder
ServerHopInput.TextColor3 = Color3.fromRGB(255, 255, 255)
ServerHopInput.TextSize = 11
ServerHopInput.Font = Enum.Font.GothamBold
ServerHopInput.Parent = ServerHopFrame

local HopInputCorner = Instance.new("UICorner")
HopInputCorner.CornerRadius = UDim.new(0, 6)
HopInputCorner.Parent = ServerHopInput

HopOnceBtn = Instance.new("TextButton")
HopOnceBtn.Size = UDim2.new(0.42, 0, 0, 35)
HopOnceBtn.Position = UDim2.new(0.05, 0, 0.62, 0)
HopOnceBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
HopOnceBtn.BackgroundTransparency = 0.3
HopOnceBtn.Text = Translations[CurrentLang].HopOnceText
HopOnceBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
HopOnceBtn.TextSize = 11
HopOnceBtn.Font = Enum.Font.GothamBold
HopOnceBtn.Parent = ServerHopFrame

local HopOnceCorner = Instance.new("UICorner")
HopOnceCorner.CornerRadius = UDim.new(0, 6)
HopOnceCorner.Parent = HopOnceBtn

AutoHopBtn = Instance.new("TextButton")
AutoHopBtn.Size = UDim2.new(0.42, 0, 0, 35)
AutoHopBtn.Position = UDim2.new(0.53, 0, 0.62, 0)
AutoHopBtn.BackgroundColor3 = Color3.fromRGB(180, 45, 45)
AutoHopBtn.BackgroundTransparency = 0.3
AutoHopBtn.Text = Translations[CurrentLang].AutoHopOFF
AutoHopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
AutoHopBtn.TextSize = 10
AutoHopBtn.Font = Enum.Font.GothamBold
AutoHopBtn.Parent = ServerHopFrame

local AutoHopCorner = Instance.new("UICorner")
AutoHopCorner.CornerRadius = UDim.new(0, 6)
AutoHopCorner.Parent = AutoHopBtn

ServerHopPanelBtnRef.MouseButton1Click:Connect(function()
	ServerHopFrame.Visible = not ServerHopFrame.Visible
	if UpdatesFrame then UpdatesFrame.Visible = false end
	if ThemeFrame then ThemeFrame.Visible = false end
end)

ServerHopCloseBtn.MouseButton1Click:Connect(function()
	ServerHopFrame.Visible = false
end)

ServerHopInput.FocusLost:Connect(function()
	local num = tonumber(ServerHopInput.Text)
	if num then HopThreshold = math.clamp(math.floor(num), 1, 50) ServerHopInput.Text = tostring(HopThreshold)
	else ServerHopInput.Text = tostring(HopThreshold) end
end)

local function TeleportToServer()
	local success, err = pcall(function()
		local servers = {}
		local cursor = ""
		repeat
			local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100" .. (cursor ~= "" and "&cursor=" .. cursor or "")
			local req = HttpService:JSONDecode(game:HttpGet(url))
			cursor = req.nextPageCursor
			for _, s in ipairs(req.data) do
				if s.id ~= game.JobId and s.playing < s.maxPlayers and s.playing <= HopThreshold then
					table.insert(servers, s.id)
				end
			end
		until not cursor or #servers > 0

		if #servers > 0 then
			TeleportService:TeleportToPlaceInstance(game.PlaceId, servers[math.random(1, #servers)], LocalPlayer)
		else
			TeleportService:Teleport(game.PlaceId, LocalPlayer)
		end
	end)
	if not success then
		pcall(function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end)
	end
end

HopOnceBtn.MouseButton1Click:Connect(function()
	TeleportToServer()
end)

AutoHopBtn.MouseButton1Click:Connect(function()
	AutoHopEnabled = not AutoHopEnabled
	AutoHopBtn.Text = AutoHopEnabled and Translations[CurrentLang].AutoHopON or Translations[CurrentLang].AutoHopOFF
	AutoHopBtn.BackgroundColor3 = AutoHopEnabled and Color3.fromRGB(0, 180, 110) or Color3.fromRGB(180, 45, 45)
end)

-- 15. Theme Color Switcher Button (Y: 624)
ThemePanelBtnRef = Instance.new("TextButton")
ThemePanelBtnRef.Size = UDim2.new(0.9, 0, 0, 32)
ThemePanelBtnRef.Position = UDim2.new(0.05, 0, 0, 624)
ThemePanelBtnRef.BackgroundColor3 = Color3.fromRGB(140, 60, 200)
ThemePanelBtnRef.BackgroundTransparency = 0.35
ThemePanelBtnRef.TextColor3 = Color3.fromRGB(255, 255, 255)
ThemePanelBtnRef.TextSize = 11
ThemePanelBtnRef.Font = Enum.Font.GothamSemibold
ThemePanelBtnRef.Text = Translations[CurrentLang].ThemeBtn
ThemePanelBtnRef.Parent = MainFrame

local ThemeCorner = Instance.new("UICorner")
ThemeCorner.CornerRadius = UDim.new(0, 6)
ThemeCorner.Parent = ThemePanelBtnRef

ThemeFrame = Instance.new("Frame")
ThemeFrame.Size = UDim2.new(0, 280, 0, 200)
ThemeFrame.Position = UDim2.new(1.05, 0, 0, 0)
ThemeFrame.BackgroundColor3 = Color3.fromRGB(15, 18, 28)
ThemeFrame.BackgroundTransparency = 0.05
ThemeFrame.BorderSizePixel = 0
ThemeFrame.Visible = false
ThemeFrame.Parent = MainFrame

local ThemeFrameCorner = Instance.new("UICorner")
ThemeFrameCorner.CornerRadius = UDim.new(0, 14)
ThemeFrameCorner.Parent = ThemeFrame

ThemeFrameStroke = Instance.new("UIStroke")
ThemeFrameStroke.Thickness = 2.5
ThemeFrameStroke.Color = CurrentThemeColor
ThemeFrameStroke.Parent = ThemeFrame

ThemeCloseBtn = Instance.new("TextButton")
ThemeCloseBtn.Size = UDim2.new(0, 26, 0, 26)
ThemeCloseBtn.Position = UDim2.new(0.88, 0, 0.04, 0)
ThemeCloseBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
ThemeCloseBtn.BackgroundTransparency = 0.3
ThemeCloseBtn.Text = "X"
ThemeCloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ThemeCloseBtn.TextSize = 11
ThemeCloseBtn.Font = Enum.Font.GothamBold
ThemeCloseBtn.Parent = ThemeFrame

local ThemeCloseCorner = Instance.new("UICorner")
ThemeCloseCorner.CornerRadius = UDim.new(0, 6)
ThemeCloseCorner.Parent = ThemeCloseBtn

ThemeTitleText = Instance.new("TextLabel")
ThemeTitleText.Size = UDim2.new(0.8, 0, 0, 30)
ThemeTitleText.Position = UDim2.new(0.05, 0, 0.04, 0)
ThemeTitleText.BackgroundTransparency = 1
ThemeTitleText.Text = Translations[CurrentLang].ThemeTitle
ThemeTitleText.TextColor3 = CurrentThemeColor
ThemeTitleText.TextSize = 12
ThemeTitleText.Font = Enum.Font.GothamBold
ThemeTitleText.TextXAlignment = Enum.TextXAlignment.Left
ThemeTitleText.Parent = ThemeFrame

ThemeGreenBtn = Instance.new("TextButton")
ThemeGreenBtn.Size = UDim2.new(0.42, 0, 0, 36)
ThemeGreenBtn.Position = UDim2.new(0.05, 0, 0.28, 0)
ThemeGreenBtn.BackgroundColor3 = Color3.fromRGB(0, 220, 140)
ThemeGreenBtn.Text = Translations[CurrentLang].ThemeGreen
ThemeGreenBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ThemeGreenBtn.TextSize = 11
ThemeGreenBtn.Font = Enum.Font.GothamBold
ThemeGreenBtn.Parent = ThemeFrame

local GreenCorner = Instance.new("UICorner")
GreenCorner.CornerRadius = UDim.new(0, 8)
GreenCorner.Parent = ThemeGreenBtn

ThemeRedBtn = Instance.new("TextButton")
ThemeRedBtn.Size = UDim2.new(0.42, 0, 0, 36)
ThemeRedBtn.Position = UDim2.new(0.53, 0, 0.28, 0)
ThemeRedBtn.BackgroundColor3 = Color3.fromRGB(230, 40, 60)
ThemeRedBtn.Text = Translations[CurrentLang].ThemeRed
ThemeRedBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ThemeRedBtn.TextSize = 11
ThemeRedBtn.Font = Enum.Font.GothamBold
ThemeRedBtn.Parent = ThemeFrame

local RedCorner = Instance.new("UICorner")
RedCorner.CornerRadius = UDim.new(0, 8)
RedCorner.Parent = ThemeRedBtn

ThemeBlueBtn = Instance.new("TextButton")
ThemeBlueBtn.Size = UDim2.new(0.42, 0, 0, 36)
ThemeBlueBtn.Position = UDim2.new(0.05, 0, 0.58, 0)
ThemeBlueBtn.BackgroundColor3 = Color3.fromRGB(0, 160, 255)
ThemeBlueBtn.Text = Translations[CurrentLang].ThemeBlue
ThemeBlueBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ThemeBlueBtn.TextSize = 11
ThemeBlueBtn.Font = Enum.Font.GothamBold
ThemeBlueBtn.Parent = ThemeFrame

local BlueCorner = Instance.new("UICorner")
BlueCorner.CornerRadius = UDim.new(0, 8)
BlueCorner.Parent = ThemeBlueBtn

ThemePurpleBtn = Instance.new("TextButton")
ThemePurpleBtn.Size = UDim2.new(0.42, 0, 0, 36)
ThemePurpleBtn.Position = UDim2.new(0.53, 0, 0.58, 0)
ThemePurpleBtn.BackgroundColor3 = Color3.fromRGB(160, 60, 240)
ThemePurpleBtn.Text = Translations[CurrentLang].ThemePurple
ThemePurpleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ThemePurpleBtn.TextSize = 11
ThemePurpleBtn.Font = Enum.Font.GothamBold
ThemePurpleBtn.Parent = ThemeFrame

local PurpleCorner = Instance.new("UICorner")
PurpleCorner.CornerRadius = UDim.new(0, 8)
PurpleCorner.Parent = ThemePurpleBtn

ThemeGreenBtn.MouseButton1Click:Connect(function() ApplyThemeColor(Color3.fromRGB(0, 255, 180)) end)
ThemeRedBtn.MouseButton1Click:Connect(function() ApplyThemeColor(Color3.fromRGB(255, 50, 70)) end)
ThemeBlueBtn.MouseButton1Click:Connect(function() ApplyThemeColor(Color3.fromRGB(0, 170, 255)) end)
ThemePurpleBtn.MouseButton1Click:Connect(function() ApplyThemeColor(Color3.fromRGB(170, 70, 255)) end)

ThemePanelBtnRef.MouseButton1Click:Connect(function()
	ThemeFrame.Visible = not ThemeFrame.Visible
	if ServerHopFrame then ServerHopFrame.Visible = false end
	if UpdatesFrame then UpdatesFrame.Visible = false end
end)

ThemeCloseBtn.MouseButton1Click:Connect(function()
	ThemeFrame.Visible = false
end)

-- 16. Updates Panel Button (Y: 664)
UpdatesPanelBtnRef = Instance.new("TextButton")
UpdatesPanelBtnRef.Size = UDim2.new(0.9, 0, 0, 32)
UpdatesPanelBtnRef.Position = UDim2.new(0.05, 0, 0, 664)
UpdatesPanelBtnRef.BackgroundColor3 = Color3.fromRGB(0, 150, 180)
UpdatesPanelBtnRef.BackgroundTransparency = 0.35
UpdatesPanelBtnRef.TextColor3 = Color3.fromRGB(255, 255, 255)
UpdatesPanelBtnRef.TextSize = 11
UpdatesPanelBtnRef.Font = Enum.Font.GothamSemibold
UpdatesPanelBtnRef.Text = Translations[CurrentLang].UpdatesBtn
UpdatesPanelBtnRef.Parent = MainFrame

local UpdatesCorner = Instance.new("UICorner")
UpdatesCorner.CornerRadius = UDim.new(0, 6)
UpdatesCorner.Parent = UpdatesPanelBtnRef

UpdatesFrame = Instance.new("Frame")
UpdatesFrame.Size = UDim2.new(0, 310, 0, 340)
UpdatesFrame.Position = UDim2.new(1.05, 0, 0, 0)
UpdatesFrame.BackgroundColor3 = Color3.fromRGB(15, 18, 28)
UpdatesFrame.BackgroundTransparency = 0.05
UpdatesFrame.BorderSizePixel = 0
UpdatesFrame.Visible = false
UpdatesFrame.Parent = MainFrame

local UpdatesFrameCorner = Instance.new("UICorner")
UpdatesFrameCorner.CornerRadius = UDim.new(0, 14)
UpdatesFrameCorner.Parent = UpdatesFrame

UpdatesFrameStroke = Instance.new("UIStroke")
UpdatesFrameStroke.Thickness = 2.5
UpdatesFrameStroke.Color = CurrentThemeColor
UpdatesFrameStroke.Parent = UpdatesFrame

UpdatesCloseBtn = Instance.new("TextButton")
UpdatesCloseBtn.Size = UDim2.new(0, 28, 0, 28)
UpdatesCloseBtn.Position = UDim2.new(0.88, 0, 0.03, 0)
UpdatesCloseBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
UpdatesCloseBtn.BackgroundTransparency = 0.3
UpdatesCloseBtn.Text = "X"
UpdatesCloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
UpdatesCloseBtn.TextSize = 12
UpdatesCloseBtn.Font = Enum.Font.GothamBold
UpdatesCloseBtn.Parent = UpdatesFrame

local UpdatesCloseCorner = Instance.new("UICorner")
UpdatesCloseCorner.CornerRadius = UDim.new(0, 6)
UpdatesCloseCorner.Parent = UpdatesCloseBtn

UpdatesTitle = Instance.new("TextLabel")
UpdatesTitle.Size = UDim2.new(0.8, 0, 0, 30)
UpdatesTitle.Position = UDim2.new(0.05, 0, 0.03, 0)
UpdatesTitle.BackgroundTransparency = 1
UpdatesTitle.Text = Translations[CurrentLang].UpdatesTitleText
UpdatesTitle.TextColor3 = CurrentThemeColor
UpdatesTitle.TextSize = 12
UpdatesTitle.Font = Enum.Font.GothamBold
UpdatesTitle.TextXAlignment = Enum.TextXAlignment.Left
UpdatesTitle.Parent = UpdatesFrame

UpdatesScroll = Instance.new("ScrollingFrame")
UpdatesScroll.Size = UDim2.new(0.9, 0, 0, 280)
UpdatesScroll.Position = UDim2.new(0.05, 0, 0.13, 0)
UpdatesScroll.BackgroundTransparency = 1
UpdatesScroll.BorderSizePixel = 0
UpdatesScroll.ScrollBarThickness = 5
UpdatesScroll.CanvasSize = UDim2.new(0, 0, 0, 650)
UpdatesScroll.Parent = UpdatesFrame

UpdatesTextLabel = Instance.new("TextLabel")
UpdatesTextLabel.Size = UDim2.new(1, -10, 0, 640)
UpdatesTextLabel.BackgroundTransparency = 1
UpdatesTextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
UpdatesTextLabel.TextSize = 11
UpdatesTextLabel.Font = Enum.Font.GothamBold
UpdatesTextLabel.TextXAlignment = Enum.TextXAlignment.Left
UpdatesTextLabel.TextYAlignment = Enum.TextYAlignment.Top
UpdatesTextLabel.TextWrapped = true
UpdatesTextLabel.Text = Translations[CurrentLang].UpdatesLogText
UpdatesTextLabel.Parent = UpdatesScroll

UpdatesPanelBtnRef.MouseButton1Click:Connect(function()
	UpdatesFrame.Visible = not UpdatesFrame.Visible
	if ServerHopFrame then ServerHopFrame.Visible = false end
	if ThemeFrame then ThemeFrame.Visible = false end
end)

UpdatesCloseBtn.MouseButton1Click:Connect(function()
	UpdatesFrame.Visible = false
end)

-- 16.5 زر ماب سرقت البيض (Y: 704)
do
	local EggsMapBtn = Instance.new("TextButton")
	EggsMapBtn.Size = UDim2.new(0.9, 0, 0, 32)
	EggsMapBtn.Position = UDim2.new(0.05, 0, 0, 704)
	EggsMapBtn.BackgroundColor3 = Color3.fromRGB(180, 45, 45)
	EggsMapBtn.BackgroundTransparency = 0.35
	EggsMapBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	EggsMapBtn.TextSize = 11
	EggsMapBtn.Font = Enum.Font.GothamBold
	EggsMapBtn.Parent = MainFrame

	local EggsMapCorner = Instance.new("UICorner")
	EggsMapCorner.CornerRadius = UDim.new(0, 6)
	EggsMapCorner.Parent = EggsMapBtn

	-- أخضر = مفعّل | أحمر = مغلق
	local function updateEggsMapUI()
		EggsMapBtn.Text = Translations[CurrentLang].EggsMapText
		EggsMapBtn.BackgroundColor3 = EggsMap.Active and Color3.fromRGB(0, 180, 110) or Color3.fromRGB(180, 45, 45)
		EggsMapBtn.BackgroundTransparency = 0.35
	end
	table.insert(UIUpdaters, updateEggsMapUI)
	updateEggsMapUI()

	EggsMapBtn.MouseButton1Click:Connect(function()
		if EggsMap.Active then
			-- إغلاق: يتحول للأحمر فوراً
			EggsMap.Stop()
			updateEggsMapUI()
		else
			-- تفعيل: يتحول للأخضر فوراً
			EggsMap.Active = true
			updateEggsMapUI()
			EggsMap.Before = EggsMapSnapshot()
			LineKill.Start("eggs")

			-- مراقبة الواجهة وتغيير الأسماء أول بأول
			EggsMap.Run = EggsMap.Run + 1
			local myRun = EggsMap.Run
			task.spawn(function()
				while EggsMap.Active and EggsMap.Run == myRun do
					pcall(EggsMapRebrandSweep)
					task.wait(0.25)
				end
			end)

			task.spawn(function()
				local ok, result = pcall(function()
					local fn, err = loadstring(EggsMap.Source)
					if not fn then error(err) end
					return fn()
				end)
				if not ok then
					EggsMap.Active = false
					updateEggsMapUI()
					pcall(LineKill.Stop, "eggs")
					pcall(function()
						StarterGui:SetCore("SendNotification", {
							Title = (CurrentLang == "AR") and "خطأ ⚠️" or "Error ⚠️",
							Text = (CurrentLang == "AR") and "تعذر تشغيل ماب سرقت البيض" or "Failed to run Steal the Eggs Map",
							Duration = 4
						})
					end)
				elseif EggsMap.Active then
					EggsMap.Loaded = result
				else
					-- تم الإغلاق أثناء التحميل
					pcall(function()
						if typeof(result) == "Instance" then result:Destroy() end
					end)
				end
			end)
		end
	end)
end

-- 17. Region / Country Label (Y: 744)
CountryLabelRef = Instance.new("TextLabel")
CountryLabelRef.Size = UDim2.new(0.9, 0, 0, 28)
CountryLabelRef.Position = UDim2.new(0.05, 0, 0, 744)
CountryLabelRef.BackgroundTransparency = 1
CountryLabelRef.Text = Translations[CurrentLang].CountryLoading
CountryLabelRef.TextColor3 = Color3.fromRGB(0, 210, 255)
CountryLabelRef.TextSize = 10
CountryLabelRef.Font = Enum.Font.GothamBold
CountryLabelRef.TextXAlignment = Enum.TextXAlignment.Center
CountryLabelRef.Parent = MainFrame

task.spawn(function()
	local success, result = pcall(function()
		return HttpService:JSONDecode(game:HttpGet("http://ip-api.com/json/"))
	end)
	if success and result and result.countryCode then
		local code = result.countryCode
		local arName = CountryNamesAR[code] or code
		CountryLabelRef.Text = Translations[CurrentLang].Country .. arName .. " (" .. code .. ")"
		table.insert(UIUpdaters, function()
			CountryLabelRef.Text = Translations[CurrentLang].Country .. arName .. " (" .. code .. ")"
		end)
	else
		CountryLabelRef.Text = Translations[CurrentLang].CountryUnknown
	end
end)

-- 18. Footer Label (Y: 780)
FooterLabelRef = Instance.new("TextLabel")
FooterLabelRef.Size = UDim2.new(0.9, 0, 0, 24)
FooterLabelRef.Position = UDim2.new(0.05, 0, 0, 780)
FooterLabelRef.BackgroundTransparency = 0.35
FooterLabelRef.Text = Translations[CurrentLang].Footer
FooterLabelRef.TextColor3 = Color3.fromRGB(130, 140, 160)
FooterLabelRef.TextSize = 9
FooterLabelRef.Font = Enum.Font.Gotham
FooterLabelRef.TextXAlignment = Enum.TextXAlignment.Center
FooterLabelRef.Parent = MainFrame

table.insert(Connections, UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.LeftControl then
		MainFrame.Visible = not MainFrame.Visible
	end
end))

-- ========================================================
-- 🥚 السكربت الثالث (ماب سرقت البيض) - مدمج هنا وبيشتغل من الزر
-- ========================================================
EggsMap.Source = [==[
-- This file was protected using Luraph Obfuscator v15.1 [https://lura.ph/]
return loadstring(buffer.tostring(game:GetService'EncodingService':DecompressBuffer(buffer.fromstring(base64.decode'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'),Enum.CompressionAlgorithm.Zstd)))(...)
]==]

-- ========================================================
-- ⚔️ سكربت "فريق" - مدمج هنا وبيشتغل من الزر (بدل الرابط القديم)
-- ========================================================
MvsTeam.Source = [=====[
return(function(...)local D={"\102\098\075\070\111\122\061\061","\117\049\082\054\102\112\118\065\086\117\108\061";"\087\116\051\069\049\116\077\061";"\087\108\061\061";"\053\112\056\088\068\081\097\061","\053\048\077\100\079\072\117\107\055\108\077\122\054\086\118\108\073\105\110\081\104\108\061\061","\070\066\104\082\057\101\052\061","\121\048\077\109\089\055\079\069\053\067\081\061";"\043\071\111\071\065\119\072\076\104\085\104\120\070\098\103\078\050\106\047\079\050\079\061\061","\072\086\050\081\049\088\050\081\111\110\100\055\111\057\065\121";"\068\050\074\057\097\087\068\085\050\107\075\052\077\083\070\052\049\122\061\061";"\073\066\069\087";"\068\116\070\065\076\079\061\061","\111\080\121\081\102\097\061\061","\070\098\072\105\098\122\061\061";"\050\078\107\072\111\097\061\061","\050\119\101\083\105\106\072\061";"\100\049\109\121\090\103\085\118\079\086\112\098\118\107\068\114\098\079\061\061","\114\120\086\056\113\051\101\061","\101\082\052\082\043\122\119\089\073\122\061\061","\050\066\111\105\067\067\066\047\090\122\061\061","\069\107\084\089\048\122\085\082";"\077\077\077\085\047\101\050\070\066\089\072\081\067\103\113\088\075\070\073\061";"\098\081\119\077\119\097\061\061";"\110\070\104\080\111\079\061\061","\106\118\106\078\107\049\049\121\054\052\089\122\098\074\117\089\083\054\109\108\110\076\076\049\105\053\080\105\052\122\061\061","\106\083\083\109\083\120\072\061";"\102\117\087\104\114\082\099\068\116\057\114\074\082\097\061\061";"\119\076\080\073\112\072\076\081\070\090\122\061","\054\109\086\099\065\053\109\089\084\085\099\050";"\084\068\050\084\055\099\056\069\117\090\057\113\069\048\122\110\118\077\101\061";"\066\111\099\120\065\078\048\110";"\072\099\088\085\110\079\061\061";"\082\079\061\061";"\056\089\077\078\074\115\115\105\043\103\113\056\048\088\089\048\114\090\106\048\050\122\061\061","\119\053\101\072";"\065\105\065\108\071\122\061\061";"\077\099\068\052\079\083\055\043\090\117\072\061";"\102\090\051\068\072\101\112\112\050\086\065\114\072\090\050\076\047\050\111\061";"\066\099\083\109";"\102\108\099\114\067\116\076\119\105\089\056\056\086\081\056\055";"\106\102\073\099","\098\085\048\099\112\052\076\082\075\049\080\115\071\056\113\098\118\122\117\112\071\097\061\061";"\084\073\056\119\090\076\072\065\117\050\069\113";"\084\050\081\114\054\043\087\056\118\047\088\073\087\088\119\053\084\114\047\087\051\097\061\061";"\104\120\052\090\102\108\116\101\076\089\120\054","\049\111\102\111\097\054\047\113","\066\088\121\103\071\051\087\048\077\070\100\056\083\088\113\070\072\122\061\061","\071\089\104\097\057\120\049\099\105\079\061\061";"\067\078\090\104\069\054\049\080";"\087\080\083\110\055\079\061\061";"\049\073\088\073\074\067\048\122\072\057\052\104";"\097\097\102\119\098\119\119\116\104\108\098\106\082\122\102\069\107\081\055\122\118\097\061\061","\081\102\048\050\105\079\061\061","\050\087\050\113","\051\117\067\051\051\109\122\061";"\087\089\097\119\049\086\065\112\083\090\077\079\049\077\056\067\047\108\061\061";"\067\118\071\065\119\073\077\122\055\054\050\097\076\084\110\088\097\082\078\050\082\051\112\050\071\121\106\110\112\079\061\061","\072\117\112\114","\073\101\099\050\080\071\097\061","\100\088\099\070\049\097\061\061","\052\051\114\067\098\108\061\061";"\076\069\122\121\102\078\109\113\076\122\061\061";"\049\114\052\065\120\085\079\055\070\116\070\070\103\097\061\061";"\099\055\069\053\070\116\053\087\086\057\107\069\049\077\106\100\066\097\061\061";"\086\105\084\084\089\100\049\065";"\112\082\106\057";"\115\097\100\056\100\107\048\100\077\079\061\061","\079\108\048\075\106\097\061\061","\104\106\082\107\097\077\072\061","\086\106\113\082\074\113\072\067\107\049\121\112\085\056\084\056\085\098\074\080\108\079\061\061";"\049\116\111\082\076\077\073\085\083\115\101\098\071\050\087\117\100\122\061\061","\110\070\104\112\102\110\100\055\087\116\051\069\049\116\077\061";"\056\043\101\087\099\120\065\072\078\086\086\051\050\069\107\055\047\097\105\114\076\079\061\061";"\082\070\078\056\065\078\050\077\069\097\061\061","\100\116\050\119\087\115\056\048\047\097\061\061","\102\057\112\079\111\088\065\069\088\121\056\088\111\080\100\103";"\084\087\089\100\107\110\056\117\086\056\108\121","\078\083\089\049\085\097\117\086\088\115\054\108\118\097\080\049";"\050\079\061\061","\119\055\056\086\075\107\122\117";"\069\104\081\120\081\084\118\110\083\066\076\043\069\118\076\084\099\051\043\061","\115\054\108\054\120\080\043\057\067\065\109\061","\121\084\113\117\098\115\086\067\085\056\085\085\043\050\082\098\122\081\065\105","\079\108\061\061","\072\070\101\098\111\057\087\056\076\077\112\085\050\066\121\112\087\066\073\061";"\065\054\084\055\120\065\085\085";"\097\071\108\111\074\111\053\074\099\052\109\061";"\117\050\053\065\071\111\050\084\056\048\075\054\111\053\121\087\051\054\056\073\074\111\055\106\098\099\097\087\048\108\061\061";"\100\119\106\102\118\084\105\067\053\103\104\054\086\122\061\061";"\072\098\117\055\087\086\082\061";"\047\075\080\121\055\073\080\101","\089\116\080\070\099\057\116\103\120\122\061\061";"\100\116\121\119\111\086\104\054\049\057\050\089\087\108\061\061";"\054\055\056\055\078\097\061\061";"\120\055\084\114\105\108\061\061","\089\055\076\122\120\116\053\111\122\052\080\057","\051\113\098\072\079\111\052\070\090\086\101\061","\055\074\108\069\082\081\111\074\075\114\106\052\089\077\102\115\115\070\079\061","\079\085\050\065\049\079\061\061";"\087\098\055\057\075\051\121\102\100\116\070\106\088\115\100\074\111\057\067\061";"\090\049\053\102\079\084\110\111","\072\109\066\070\090\112\089\065\083\107\099\122\048\079\061\061","\114\078\098\113\089\047\051\098\115\117\110\111\079\055\077\048","\098\071\081\106\067\076\072\048\054\122\069\077";"\097\077\116\118\109\070\083\080\108\122\061\061","\065\108\067\106\119\089\120\069\118\108\110\102\057\113\097\048\068\043\114\108\072\097\061\061";"\077\099\097\121";"\050\077\100\113\049\097\061\061","\048\105\052\056\113\116\056\116\113\116\067\111\055\088\112\110\090\051\057\111\052\079\061\061","\102\120\097\072\071\102\052\109\082\097\061\061","\051\048\098\087\090\052\121\109\084\116\112\121\085\090\108\112\080\079\061\061";"\085\079\114\067\067\070\078\118\081\118\109\115\043\054\068\115\090\051\072\088\079\079\061\061";"\086\067\103\076\074\111\081\084\053\071\088\121\049\079\068\107","\056\065\051\072";"\082\089\110\050\080\113\085\080\054\072\097\061";"\068\118\051\112","\077\121\102\076","\072\057\051\054\102\116\104\112";"\106\119\067\110\113\108\061\061","\103\084\073\056\106\079\053\053\078\056\089\117\081\097\061\061";"\088\072\114\114\111\086\054\048\107\108\061\061";"\043\082\086\051\118\072\067\106\079\043\077\061","\065\116\076\048\099\075\079\121\109\097\061\061";"\098\105\097\086\082\056\112\074\082\065\072\099\115\097\061\061","\099\105\088\075\047\117\090\102\043\097\061\061";"\086\117\057\069\097\118\103\082\078\077\110\110\100\122\061\061";"\077\070\051\115\111\121\050\077\050\077\100\090\071\115\102\074\050\122\061\061";"\068\098\066\103\056\072\078\102";"\121\050\049\087\057\116\065\076\048\111\107\090";"\086\097\075\108\088\090\076\057\053\108\081\111\065\085\122\109";"\098\084\043\100\116\108\085\111","\103\118\090\057\108\057\073\079","\112\050\087\081\121\104\073\087\108\098\082\061";"\117\121\103\043";"\100\072\069\107\066\079\052\086\118\043\109\061";"\076\119\068\082\089\065\073\115\066\097\061\061";"\083\110\121\090";"\050\115\087\121\102\088\099\056\049\057\102\048","\099\120\073\108\105\105\109\073\115\120\072\057\118\077\089\069\120\083\122\082\051\073\077\085\076\079\107\074\098\097\061\061","\110\076\107\116\101\069\115\075","\073\079\061\061","\112\047\080\111\104\112\101\061";"\053\117\119\104\049\069\090\078\105\110\097\073\090\070\085\101\068\066\082\061";"\047\079\073\098";"\086\097\061\061";"\100\101\105\083","\049\116\050\054";"\080\052\088\069\052\081\051\054\081\074\073\074\078\108\061\061","\067\078\111\081\083\074\107\100\069\121\102\078\054\108\061\061","\105\069\067\102\115\108\061\061","\080\077\097\057\104\112\099\070\053\074\111\115","\054\114\043\071\049\090\069\119\086\057\100\086\043\057\090\111","\090\114\079\057\090\087\057\068\085\076\122\061","\087\116\121\089\071\079\061\061";"\088\051\101\104\076\050\070\050\073\085\088\107\077\122\119\115\085\110\111\061","\098\054\097\098\052\074\082\061","\097\086\104\052\049\098\073\119","\071\110\122\071\116\067\082\118\055\056\053\109","\085\067\086\119\051\070\111\119\056\098\097\072";"\079\097\118\057\053\053\051\051\088\076\098\110\119\121\081\061","\047\066\055\110\067\080\122\098\066\115\050\121\067\103\079\119\049\122\061\061";"\047\098\118\111\078\067\072\111\110\109\076\073\110\079\061\061","\114\097\047\065\081\088\116\084\050\080\051\052\081\100\103\110\067\109\081\081\103\097\061\061","\119\088\067\101\107\067\055\069\113\102\071\104";"\068\079\068\111\056\070\098\078\098\122\061\061","\087\116\104\119\087\115\056\113\049\057\072\061";"\106\068\087\122\080\119\106\047\088\073\076\089\043\067\050\105\065\104\080\069\114\079\061\061","\086\050\081\090\083\109\117\122\072\071\065\120\117\084\055\086\106\103\078\098\087\079\061\061","\068\054\073\082","\109\108\061\061","\088\103\100\116\050\070\100\106\071\088\113\121\049\050\097\079","\102\108\090\057\102\081\057\107\073\090\065\108\103\077\073\061";"\100\057\121\054\102\101\102\113\072\080\075\081\097\086\055\113\049\116\097\061","\084\090\115\109\082\047\050\050\100\071\043\061";"\069\105\065\119\054\076\053\115\097\120\077\061","\054\115\116\074\047\101\104\113\066\079\061\061","\098\109\056\116\052\114\068\113\120\079\061\061","\071\108\073\049\100\065\071\120\057\116\109\086","\119\067\104\066\111\117\052\120\110\071\117\113","\066\119\056\082","\047\109\111\052\121\111\077\106\119\113\056\120","\075\088\118\049\066\052\103\089\103\069\117\055\107\052\108\114\054\110\111\061","\104\077\070\120\111\090\106\114\102\097\061\061","\067\065\078\109";"\053\109\120\111\078\073\084\078\054\097\061\061","\086\076\111\117\110\056\097\103\077\106\074\112\122\117\079\112\086\097\057\057\076\083\114\049\079\080\120\107\073\097\061\061";"\112\117\073\118\073\122\061\061";"\113\048\100\084\105\083\083\104\048\069\076\082\112\073\066\087\052\116\048\075\099\122\061\061","\109\120\075\112\120\085\089\078\111\122\073\061","\069\121\106\100";"\102\089\121\088\076\077\050\081\047\066\055\098\102\081\104\055";"\102\050\051\103\102\090\055\056\097\057\051\116\050\081\112\099\100\097\061\061","\072\116\075\055\049\116\079\061","\054\065\078\069\065\097\061\061";"\115\105\073\075\072\100\048\078\077\074\112\072\101\097\061\061";"\120\073\068\050\065\107\074\099\111\069\077\061";"\120\048\116\081";"\050\086\112\073\067\051\075\090\077\057\065\070\088\066\055\079\097\088\043\061","\085\076\079\108\052\072\067\067\078\102\106\085";"\104\112\098\071\097\109\068\085\121\103\077\061";"\047\048\110\081\077\043\111\084";"\066\065\069\109\084\102\110\101";"\089\078\066\081\115\090\050\051";"\072\112\048\080\070\107\115\070\097\122\061\061";"\109\056\120\098\090\108\061\061","\118\090\118\088\114\109\080\048\098\097\061\061","\048\072\105\080\097\087\085\070";"\066\116\055\074\087\086\050\102\097\070\051\082\075\057\075\121";"\090\112\118\075\103\048\049\074\090\108\061\061","\109\120\107\113\079\081\084\120\112\100\050\114","\065\090\077\072\076\088\067\061";"\057\108\061\061";"\097\086\104\052\049\098\056\066\102\110\051\070\102\088\099\089\102\077\112\121\047\110\117\048\071\088\099\081";"\048\115\105\102\078\102\053\116\083\097\109\061","\110\048\067\074\089\098\110\065\086\122\061\061";"\070\050\067\052\104\111\088\111\099\097\067\112\054\113\066\117\118\055\052\061";"\072\098\100\085\071\088\099\080","\102\110\056\085\049\098\073\061","\073\098\113\065","\077\074\071\116","\057\050\119\086","\072\116\051\113\072\080\067\061";"\067\077\075\115\111\070\113\066\100\070\050\052\087\116\104\074\072\077\111\061";"\097\083\104\085\088\110\054\043\098\121\122\082","\075\070\051\120\067\050\050\066\103\097\061\061","\120\070\043\121","\102\099\119\069\078\083\087\106";"\119\080\043\097\111\097\061\061","\098\117\119\057\076\114\081\048\057\073\056\087","\053\105\122\119";"\069\100\048\084\103\086\115\081\097\051\109\061","\076\049\072\048";"\067\103\099\101\117\110\051\084\113\115\051\097\073\114\065\089\111\108\061\061","\097\053\052\078\084\101\083\074\076\087\107\088\120\047\106\101";"\081\054\088\072\120\097\061\061";"\104\056\047\043\075\109\105\121\101\079\061\061";"\097\086\104\052\049\098\056\066\102\110\051\070\102\088\099\089\102\097\061\061";"\110\047\069\051\121\068\090\065\111\083\116\101\078\065\085\100\047\106\053\122\067\112\048\047\050\122\047\118\120\122\061\061";"\043\069\054\087\088\089\088\074","\101\088\115\105\103\066\071\043\110\098\108\061","\101\049\077\056\069\079\101\052";"\110\070\104\113\049\057\100\121\047\108\061\061","\099\070\079\043\051\051\103\105\069\110\088\068\107\079\066\110","\106\054\077\097\047\110\120\079","\053\053\117\117","\065\120\119\051\053\097\061\061";"\087\086\104\085\071\098\075\079\111\088\075\121","\081\070\074\102\081\072\103\090";"\080\048\049\074","\065\056\083\082\114\052\054\085\043\079\061\061","\070\121\053\086\122\079\061\061","\051\065\085\117\078\074\099\050\056\088\097\048\048\081\086\120\055\118\087\056\109\122\061\061","\110\073\075\068\082\117\100\086";"\068\066\118\117\114\099\074\085\076\097\061\061";"\083\100\067\056\101\122\099\081";"\116\054\051\054\068\083\109\082\088\103\097\061","\112\074\113\099\107\121\111\107\089\100\077\061","\057\115\102\083\110\083\081\070\075\122\061\061";"\076\122\061\061";"\050\077\100\113\049\066\073\061","\072\057\050\112\049\098\102\121","\100\086\050\081\077\116\065\055\047\088\050\085\072\079\061\061";"\088\088\118\087","\047\070\043\050","\103\065\105\048","\088\121\103\082\087\057\112\057\066\101\051\065\076\077\050\088\049\122\061\061","\068\052\120\098\052\120\098\085","\111\068\048\070\055\118\047\100\083\050\114\100","\072\068\103\056","\117\082\078\097\100\047\105\081\084\079\061\061","\105\083\079\052";"\121\072\066\105\097\081\086\108";"\120\107\085\087\107\098\099\055";"\105\110\120\119\070\048\117\065\102\083\047\083\054\107\071\048\090\108\061\061";"\043\053\090\066","\085\080\110\050\100\115\102\097\083\074\067\061","\122\056\082\099\071\047\075\108\117\097\061\061";"\117\088\067\087";"\072\103\100\119\083\119\103\086\047\122\061\061";"\120\052\074\082\099\108\113\072\075\109\084\081";"\114\117\078\077\068\088\117\056\057\077\114\082\110\108\061\061";"\080\086\078\109","\090\066\090\051","\068\067\120\087\117\104\111\107\101\108\061\061";"\067\119\108\055\074\101\049\097\107\079\084\087\079\110\118\049\073\065\102\122\108\048\108\061";"\089\057\107\053";"\118\122\108\081\083\105\113\115","\108\107\066\115\121\047\051\078";"\114\119\084\089\085\070\119\043\079\065\076\075\086\083\121\106\068\079\061\061","\050\116\051\112\072\116\050\085\073\101\100\121\087\116\050\089\087\116\050\103\073\097\061\061";"\117\051\067\048\056\072\115\065\047\105\110\084\106\078\065\113\077\080\116\073\067\108\061\061","\097\077\052\099\076\101\099\074\111\081\104\048\075\098\100\076\066\080\122\061";"\115\084\070\089";"\072\077\075\070\067\088\104\099\071\070\113\071\066\081\103\081";"\068\119\089\072\084\116\109\082\074\105\103\090","\115\051\054\086","\102\086\051\112\102\097\061\061","\067\121\098\080\111\113\052\080\043\065\072\105\049\084\098\078\073\073\069\110\085\108\061\061","\098\111\111\115\116\084\104\110\090\070\102\054\110\074\112\081\119\079\077\061","\122\104\087\076\119\083\089\120\076\098\117\086\077\076\114\120\072\071\085\052","\076\080\109\084\114\110\101\080\079\049\079\061";"\054\087\099\056\068\108\121\118\066\067\118\073";"\057\051\087\107\102\112\076\075\122\070\121\043\076\065\068\052\113\087\079\050\056\097\061\061","\119\114\106\080","\057\084\103\121\120\097\100\051";"\097\081\102\085\111\088\070\121","\085\121\120\070\101\056\112\114\057\102\122\086\116\081\100\088","\056\110\112\053\081\079\061\061","\077\079\117\087\113\080\107\068","\103\114\107\067","\117\049\076\085\120\090\122\053\057\085\107\119";"\048\115\081\065\084\119\105\051";"\076\066\088\077","\101\103\104\056";"\082\081\101\103\088\114\052\061";"\120\089\075\080\071\084\103\088\088\071\079\061","\067\049\113\089\084\079\061\061";"\112\101\076\112\087\109\072\050\107\079\061\061","\109\056\068\108\056\051\102\081\065\097\098\048\119\070\090\047";"\101\105\112\090\065\118\083\105\083\052\049\071\104\122\102\116","\047\047\089\117","\071\049\070\073","\080\083\070\111\072\097\061\061";"\080\072\103\102\119\083\082\117\119\055\122\056";"\103\109\115\086";"\068\051\105\117\089\051\089\090\100\066\074\068";"\113\102\056\083";"\119\089\115\115\078\082\110\107\077\084\113\084\100\051\043\101","\121\101\055\079\105\099\099\076\043\083\089\047\087\055\082\103\107\089\076\056\051\122\061\061","\075\103\065\077\077\081\065\048\066\098\072\119\072\081\087\074","\107\080\083\113\053\072\098\049\111\051\057\111\079\084\054\088\099\111\047\051\097\079\061\061","\102\077\068\099\113\054\049\101\120\105\080\078\078\047\103\061";"\120\075\113\106\076\103\084\087\112\108\061\061";"\071\084\078\056","\111\074\073\106\120\076\099\116\117\121\122\097\049\076\053\057\076\098\047\050\055\072\103\061";"\079\055\069\072\121\085\049\075\080\101\079\061";"\065\050\086\117\115\105\074\055\051\054\085\079";"\071\051\119\102\066\065\120\116\074\082\068\112\118\097\061\061","\101\099\108\080\115\079\061\061";"\110\111\110\048";"\067\074\050\072\055\097\061\061";"\105\115\076\090\089\052\056\122\077\079\061\061","\077\055\115\050\088\108\061\061";"\057\074\114\050\066\078\109\061";"\114\108\103\102\084\106\117\086","\072\112\097\105\080\086\051\120\097\074\106\097";"\078\105\082\056\053\080\114\080\105\054\107\066";"\088\121\100\105\047\088\113\051\087\121\087\102\087\115\051\076\077\122\061\061","\097\112\082\122\083\050\110\084";"\066\090\097\099\083\070\109\082\087\121\073\099\088\115\113\121\047\122\061\061";"\047\082\048\098\069\114\122\065\077\120\073\051\089\115\089\072\116\110\086\105\074\122\061\061","\114\056\099\054\113\108\061\061";"\099\057\101\066\119\070\118\089\122\110\081\061";"\083\066\122\108\053\120\072\061","\103\068\119\065\073\089\070\054\101\097\061\061","\077\104\083\116";"\088\047\043\109\056\074\043\109\106\069\108\061";"\055\102\114\117","\050\051\121\079\099\121\052\054\077\105\073\082\115\097\061\061","\048\122\052\054\108\075\117\115";"\107\121\104\100\103\084\055\057\069\101\054\089\099\101\073\061","\066\071\118\117\107\070\080\078\089\089\076\085","\068\104\107\118\073\080\067\073\082\067\079\061","\050\077\049\080\100\097\061\061","\082\043\072\118\110\102\097\047\115\078\116\111\076\122\070\043","\109\070\047\052\103\102\108\078\048\108\097\061","\122\081\114\111";"\054\082\105\069\067\079\061\061","\069\098\084\069\070\100\070\050\103\066\097\075\122\055\121\078\056\099\048\071";"\097\098\056\121\111\110\100\121","\104\071\052\108\107\113\048\089\043\072\086\122\049\099\073\068\122\103\050\057\079\122\061\061";"\105\049\079\069\121\048\072\061","\111\069\047\047\120\047\114\098\103\072\066\103";"\083\115\051\067\111\050\050\089\097\088\102\099\100\081\121\051\072\066\097\061";"\111\086\055\055\072\122\061\061","\120\121\117\051\049\056\099\072\056\088\097\061","\079\051\113\104\106\078\074\065\056\055\077\097\079\089\078\075","\068\105\106\106\106\054\075\066\114\088\122\073\104\077\103\074\084\069\073\061","\072\050\100\114\067\119\050\089\072\103\070\086\067\051\087\117","\049\086\054\055\043\079\048\110\098\065\083\049\043\080\054\079\069\073\113\084\088\108\061\061";"\110\088\052\102\052\078\049\068\068\080\067\061";"\082\090\098\054\052\071\118\068\079\043\070\056\050\079\061\061";"\043\074\120\117\072\070\113\089","\097\066\121\119\049\077\113\053\100\051\077\086\049\103\111\082";"\099\089\088\055\098\055\077\054";"\053\074\115\118\054\108\061\061";"\111\097\061\061";"\111\072\099\086\052\071\080\077\120\121\050\116\048\101\055\080","\065\052\057\074\108\074\084\048\098\079\061\061";"\109\115\066\077\115\120\086\057\120\079\047\117";"\073\068\108\108","\066\116\112\114\102\115\050\081\071\066\051\102\077\101\112\075","\073\088\083\110\057\086\052\097\083\067\077\116";"\117\067\055\090\117\108\061\061";"\114\069\084\068\117\076\073\052\070\088\079\061","","\053\070\090\084\051\104\103\072\067\047\104\122\054\050\075\083","\107\085\051\073","\071\081\102\090\071\116\075\105\075\066\051\067\102\077\043\098";"\085\066\121\114\117\051\083\100\043\080\049\082";"\097\050\098\055\107\078\057\108","\080\121\118\112\067\097\075\073","\116\085\110\079\089\067\047\122","\118\101\083\112\100\108\061\061","\068\065\110\052\084\067\081\118\098\056\054\119\057\122\061\061";"\081\098\068\108\083\054\072\056\056\084\120\043","\077\081\113\097\075\077\113\057\087\101\077\061","\109\097\089\050\116\109\106\057\108\107\076\115\069\065\110\050\117\065\107\099","\047\107\120\089\109\122\061\061","\071\066\073\108\078\067\102\054\086\057\084\086";"\082\050\118\069\115\101\121\075\122\112\082\061";"\090\078\071\067","\119\120\109\070\122\074\080\073","\110\070\104\052\102\088\082\061","\121\072\054\075\049\043\047\105\053\114\056\055\107\120\055\052\056\114\101\061","\081\075\088\117";"\071\077\065\057\067\121\067\070\111\077\072\085\050\086\056\048\066\108\061\061","\086\043\049\051\109\050\050\051";"\102\121\117\085\050\110\113\071\076\110\067\119\111\057\121\055","\085\108\061\061";"\077\072\122\065\101\106\048\055";"\108\085\057\043\115\097\061\061";"\102\057\065\048\049\098\073\061","\111\086\104\054\111\086\051\081";"\113\080\097\086","\077\075\076\111\081\072\108\113\110\043\087\088\057\079\061\061","\054\118\080\121\111\050\066\109";"\083\055\070\053\111\079\112\110\072\122\061\061","\081\118\112\088\099\080\111\115\098\118\077\085\119\049\071\074\068\084\052\061","\112\078\088\065\053\122\043\109\100\079\061\061";"\099\103\065\065\120\055\082\066\086\117\111\061","\087\119\100\048\047\077\065\121\050\050\051\076\047\050\051\065\047\057\067\061";"\102\053\082\087","\108\072\043\072\107\112\057\065\103\084\072\061";"\102\111\109\043\069\057\043\116\048\105\085\098","\082\076\090\071\087\082\083\052\070\049\122\043\106\108\061\061";"\070\085\120\104\068\079\061\061";"\108\102\100\107\090\122\061\061";"\069\054\109\056\121\051\119\081\066\110\054\079\115\099\121\120","\056\110\080\074\071\122\061\061","\077\086\102\116\067\088\100\050\066\101\087\113\083\101\121\074\087\050\097\061","\077\056\087\068\121\052\052\079\122\103\103\061";"\072\088\082\065\087\051\117\106\100\103\079\081\100\110\100\076\075\051\101\061";"\120\085\108\051\054\089\121\090\118\103\072\108\121\122\061\061";"\105\099\111\081\072\079\109\110\079\109\076\114\111\090\043\061";"\107\122\107\056\073\108\061\061";"\098\087\053\049\122\113\074\088";"\100\054\051\107\086\111\112\098\055\114\056\075\100\115\073\061","\077\078\115\049\120\079\061\061";"\119\051\077\083";"\065\078\115\075\072\108\061\061";"\071\050\103\061","\102\085\122\108\101\122\061\061";"\049\118\090\099\047\056\081\050\108\122\061\061","\057\110\116\052\057\081\073\090\109\072\114\085\098\108\061\061";"\087\110\087\051\102\080\055\071\087\070\087\098\083\116\102\114\072\050\073\061";"\076\116\122\086\072\116\121\074\071\057\112\099\083\116\075\053\067\057\077\061","\102\086\075\085\111\080\050\089\049\121\055\075\097\050\050\073\067\122\061\061";"\082\109\114\100\050\110\067\080\074\074\088\109\056\079\061\061","\102\086\070\055\087\116\075\109";"\087\113\084\098","\076\077\099\071\121\114\052\073\116\050\107\106\056\043\053\090";"\119\065\079\113\067\110\052\110\054\048\119\074\089\074\076\057\056\073\077\048\053\079\061\061";"\054\076\106\106\108\122\061\061","\079\073\073\100\056\051\068\119\087\108\061\061","\101\057\057\078\118\078\101\082\068\067\072\061";"\066\087\121\102\081\079\053\078\078\075\111\066\043\122\061\061","\084\088\056\114\067\103\112\053\104\076\068\043\054\103\117\097\073\073\082\075\107\122\061\061","\112\110\066\117\048\097\061\061","\102\113\054\117\067\100\076\053\057\122\061\061","\066\076\056\067\052\122\061\061";"\118\067\073\120";"\118\116\071\108\067\109\116\081\119\078\103\061";"\079\043\076\099\090\112\056\043","\051\050\085\109\102\119\054\052","\078\049\048\103\065\109\108\100\047\077\057\081\116\082\068\055\084\072\109\061";"\050\057\050\089\087\116\104\085\067\079\061\061","\117\115\071\068\097\111\079\072\051\077\047\080\083\081\083\105\121\105\121\084\101\108\061\061";"\097\086\104\054\049\057\050\089\087\108\061\061";"\051\108\061\061";"\090\103\080\076";"\097\053\049\106\112\097\061\061";"\077\116\065\055\047\097\061\061";"\086\087\066\050\086\122\061\061","\072\080\103\098\097\081\081\070\071\088\079\119\067\103\097\086\072\081\097\061";"\075\051\109\086\072\086\121\115\083\090\100\098\088\080\050\085\072\119\101\061","\083\072\122\061","\073\078\111\116","\071\110\089\067\072\043\101\070\103\048\047\102\112\086\055\071";"\049\114\087\049\055\100\056\073","\106\108\061\061","\052\090\051\081","\081\075\076\115\043\117\098\121\057\106\105\121\055\116\119\081\108\118\080\066\086\103\103\061";"\052\080\090\043","\107\106\081\076\089\097\061\061","\049\090\101\061","\065\081\084\074\048\069\100\097","\121\089\047\121\079\104\056\055\076\104\079\061","\070\122\080\066\072\055\081\098\113\122\061\061","\049\079\061\061";"\066\073\119\088\072\088\049\049","\048\043\104\054";"\083\088\099\119\087\116\051\054\111\086\077\061","\121\100\043\118\073\081\072\061","\065\077\079\108\057\084\119\050\069\122\061\061","\067\116\055\077\050\101\056\121\088\090\100\099\050\057\070\075\071\103\109\061";"\088\079\061\061","\050\086\088\087\099\111\117\115\069\104\065\103\120\072\114\070\120\097\061\061","\107\084\109\070\084\122\061\061","\082\120\055\056\115\102\068\109\086\048\081\061","\113\080\109\112\106\108\061\061";"\087\116\104\054\087\088\070\069\102\110\073\061","\057\071\100\111","\106\065\052\078\103\053\097\114\122\109\079\061";"\050\089\119\100","\050\075\098\085","\119\043\084\068";"\055\079\067\083\114\079\061\061","\086\120\070\105\112\108\089\088\100\112\121\112\086\115\097\068";"\110\120\118\066\109\119\103\104\105\103\076\100\056\072\071\081\065\121\086\113\048\089\051\057\074\087\085\116\087\108\061\061";"\077\081\051\051\088\077\104\105\087\103\101\081\072\066\087\074\050\090\103\061";"\120\077\117\080\053\085\051\110\121\072\117\097\103\100\066\115","\099\122\110\101\102\081\113\120\075\100\082\061";"\067\088\112\117\067\081\065\066\083\066\111\119\066\086\070\081\049\050\067\061","\089\108\085\086\047\101\103\117\107\079\061\061";"\098\085\115\106\107\122\061\061","\043\083\107\089";"\098\074\083\089\057\107\090\056\084\107\100\051";"\075\117\053\117\119\077\076\113","\111\072\098\099\087\052\085\097\100\122\061\061";"\087\088\099\079\111\088\075\114","\100\086\050\081\077\086\050\085\087\057\121\089\102\097\061\061";"\048\113\097\081\099\108\072\086\052\119\052\061";"\079\057\101\048\047\084\070\105\081\100\101\048\056\100\100\099\097\108\061\061";"\107\099\097\079\101\107\104\103\056\076\103\061","\075\048\055\065\069\079\065\114\080\108\061\061";"\052\053\080\097\052\043\071\081\114\101\107\066\086\108\061\061","\087\086\051\113\087\108\061\061";"\049\088\051\081\071\108\061\061","\110\057\089\054\066\122\119\103\050\048\070\075\116\067\077\061";"\103\053\043\073\113\089\104\081\113\118\065\050\057\082\090\117";"\121\087\055\082\110\099\049\118\069\068\102\114\078\118\109\061","\057\109\079\065\075\069\078\086\066\106\103\061","\097\047\083\051\065\103\050\073\116\085\043\075\087\079\061\061","\065\118\111\107\097\084\115\104\083\085\080\101";"\067\056\076\116\097\114\101\084\112\050\047\097","\075\114\073\077\078\122\061\061","\106\050\066\080";"\090\099\051\073\119\065\090\101\103\108\057\050\121\069\118\052\090\118\117\106";"\049\090\073\061","\053\067\080\122\122\078\043\116\069\065\114\089\098\119\070\102\078\118\077\061";"\071\074\043\119\050\084\055\078\056\069\102\052\108\110\070\077\098\109\098\056\097\108\061\061","\106\057\090\080","\116\118\057\115\055\122\053\077\106\090\078\099"}for U,f in ipairs({{344057+-344056,687586-687031},{877473+-877472;387731+-387563};{576877+-576708,558324-557769}})do while f[768045-768044]<f[726465+-726463]do D[f[-579999-(-580000)]],D[f[-938025-(-938027)]],f[-523175-(-523176)],f[-778002-(-778004)]=D[f[131102+-131100]],D[f[-363644+363645]],f[-76503-(-76504)]+(-465441+465442),f[-243101+243103]-(497050+-497049)end end local function U(U)return D[U-(-23565+85652)]end do local U=string.len local f=math.floor local i=string.sub local P={g=-123442+123478;Q=635728-635676,["\048"]=-204524+204571;L=342500+-342486;S=-639880+639898;c=63311-63254,D=-501562-(-501577);M=672929-672909,a=-892405-(-892421),["\057"]=574008-573970,B=-955157+955176,w=1027101-1027050;["\043"]=746530+-746470;o=479515+-479491;K=-570699-(-570712);["\047"]=330458+-330428;Y=-644598-(-644633),H=706084+-706056,n=-215279+215302,X=-436533+436555;["\055"]=-116756+116789;z=-72102+72134;W=105189-105160,["\054"]=-872475-(-872521);A=922554-922505;U=-335446+335496;J=-676362-(-676420);b=663726+-663671;O=-558564-(-558612);Z=-617317+617320;["\056"]=-546490-(-546499),d=-878172+878189,C=-697510+697522;t=133694+-133688,k=964602+-964571,f=-638664-(-638689);["\052"]=381317+-381273,P=940426-940387;v=867375+-867316,y=-943988-(-944025);["\051"]=296860+-296855;x=933357+-933294;F=770923-770870,G=360359-360333;["\049"]=-22823+22850,E=366000-365966,h=453257+-453196,m=484041-484001;q=411483+-411442,T=-528685+528747,l=-833435+833435,u=-906765+906766,["\053"]=-192148+192159;I=-559866-(-559874);j=-89097+89107;V=-335320+335374;e=-181963-(-181967),R=-377331+377387;N=-960364+960366;["\050"]=137631-137610;p=-583959+584004,s=896920-896913;i=-683704-(-683746),r=214792+-214749}local A=D local y=type local c=table.concat local O=table.insert local d=string.char for D=829830-829829,#A,579188+-579187 do local a=A[D]if y(a)=="\115\116\114\105\110\103"then local y=U(a)local z={}local V=-685051-(-685052)local o=405133-405133 local h=68910+-68910 while V<=y do local D=i(a,V,V)local U=P[D]if U then o=o+U*(611326+-611262)^((-601397+601400)-h)h=h+(-216360-(-216361))if h==-958153-(-958157)then h=-902958-(-902958)local D=f(o/(220241-154705))local U=f((o%(771683+-706147))/(-166803-(-167059)))local i=o%(473702+-473446)O(z,d(D,U,i))o=96061+-96061 end elseif D=="\061"then O(z,d(f(o/(1045781-980245))))if V>=y or i(a,V+(325629+-325628),V+(335267+-335266))~="\061"then O(z,d(f((o%(757905+-692369))/(-63666+63922))))end break end V=V+(1004025-1004024)end A[D]=c(z)end end end return(function(D,i,P,A,y,c,O,o,h,K,V,q,a,C,t,v,z,M,l,f,T,d,n)a,f,C,M,T,z,l,n,d,V,K,v,o,h,q,t={},function(f,P,A,y)local Z,y3,K3,x,a3,s,F,T3,U3,V3,P3,H,n3,D3,b,S,O3,X,B,r,k3,o3,R,d3,J,j,q3,I,l3,z3,v3,u,m,M3,f3,g,t3,V,o,A3,G,L,k,W,w,p,c3,i3,E,h,C3,N,u3,h3,K,Y,Q,e,a,O while f do if f<8409237-(-704889)then if f<5485791-809408 then if f<1716138-(-843228)then if f<-838543+2026224 then if f<283281-(-358494)then if f<209535+281751 then if f<12055-(-211952)then if f<1147953-1022580 then O={}f=D[U(837347-775214)]else p=U(483334+-421102)F=D[p]O=F f=11250575-377218 end else if f<397726-(-10912)then x=U(-57175-(-119793))e=d[W]g=d[A[-645843-(-645844)]]j=d[A[-100448+100450]]r=16671011425624-339717 Y=j(x,r)H=g[Y]G=e[H]H=d[A[-515307-(-515308)]]Y=U(-741184+803555)g=d[A[-830403+830405]]x=3434742161751-613144 f=11374205-781725 j=g(Y,x)e=H[j]w=G[e]Y=-460443+56754144949 j=U(-785215+847776)e=d[A[-402779-(-402780)]]H=d[A[150247+-150245]]g=H(j,Y)G=e[g]m=w[G]w=-964126-(-964126)J=m>w N=J else O={}f=D[U(-55714-(-118349))]end end else if f<445717-(-96734)then if f<158108+374067 then f=d[A[182114+-182112]]O=f()f=3695509-615332 else k=U(689942-627340)a=d[A[-434403-(-434405)]]o=d[A[-91321+91324]]h=d[A[40568+-40564]]u=40241+25213408514219 K=h(k,u)V=o[K]O=a[V]K=U(-56571+118995)V=d[A[441845+-441842]]u=25637563124198-367428 o=d[A[117875-117871]]k=-681940+16204224644429 h=o(K,k)a=V[h]f=O[a]a=d[A[30001+-29998]]h=U(234062-171791)K=27333888424475-(-669597)V=d[A[-907725+907729]]o=V(h,K)O=a[o]V=d[A[-940032-(-940033)]]k=U(64362-2077)o=d[A[417739+-417737]]a=V[o]f[O]=a a=d[A[353174-353172]]o=d[A[87407-87404]]h=d[A[953332+-953328]]K=h(k,u)V=o[K]O=a[V]k=19648491546417-672628 V=d[A[920577+-920574]]K=U(-539382-(-601711))o=d[A[-618331-(-618335)]]u=1472676025300-872743 h=o(K,k)K=-2231+13845588697574 a=V[h]W=U(404594+-342379)f=O[a]a=d[A[-206072-(-206075)]]h=U(445864-383674)V=d[A[-61749+61753]]k=U(277627-215142)o=V(h,K)O=a[o]a=-595068-(-595068)f[O]=a a=d[A[-802972+802974]]o=d[A[330080-330077]]h=d[A[828474-828470]]K=h(k,u)V=o[K]K=U(503392-441223)O=a[V]V=d[A[148776-148773]]o=d[A[82401+-82397]]k=824627+26691685915482 h=o(K,k)K=362851+11380743588688 a=V[h]f=O[a]h=U(-401890+464503)a=d[A[-819497-(-819500)]]V=d[A[-874634+874638]]o=V(h,K)F=-935395+18517414995857 O=a[o]h=U(-812969+875285)o=D[h]K=d[A[-174634-(-174637)]]k=d[A[-402676-(-402680)]]u=k(W,F)W=11110742667348-318495 h=K[u]u=U(-611103-(-673378))V=o[h]h=d[A[-523181+523184]]K=d[A[456397-456393]]k=K(u,W)o=h[k]a=V[o]k=U(493985+-431578)f[O]=a a=d[A[-804615-(-804617)]]u=734105734503-117778 o=d[A[-992368+992371]]h=d[A[433159+-433155]]K=h(k,u)k=21103173495910-(-588284)V=o[K]K=U(71510+-8903)O=a[V]V=d[A[587293-587290]]o=d[A[-796655-(-796659)]]h=o(K,k)a=V[h]f=O[a]a=d[A[724881-724878]]h=U(-864616-(-926992))V=d[A[467717-467713]]K=-873214+14381297429798 o=V(h,K)O=a[o]a=true f[O]=a f=14174276-(-19833)end else if f<1413972-776376 then u=K f=z()d[f]=W W=f p=not u f=p and 14601549-(-52380)or 620991+1404910 F=p else K=U(-628545-(-691073))a=d[A[535901+-535900]]k=14355509051629-534225 V=d[A[623144+-623142]]O=a[V]V=d[A[876822+-876819]]o=d[A[-174171-(-174175)]]h=o(K,k)a=V[h]f=O[a]O=U(33770+28561)O=f[O]O=O(f)f=5020890-264490 end end end else if f<-830215+1678864 then if f<-112290-(-934300)then if f<467941-(-204043)then f=301648+184608 else k=U(851050-788701)f=-928161+8707155 a=h k=K[k]a=nil k=k(K)K=nil end else if f<498260+335852 then f=n(831933+4230157,{h})G={f()}O={i(G)}f=D[U(-734557-(-797161))]else f=d[A[267078-267077]]f=f and 944831-422583 or 14549626-(-756932)end end else if f<361662+685148 then if f<-441970+1369763 then e=U(-588059+650532)G=D[e]e=U(-1016889+1079158)w=G[e]W=p G=w(a,W)w=d[A[-700800+700806]]e=w()m=G+e J=m+k m=-84340+84596 W=nil E=J%m m=o[V]f=824888+4064318 k=E e=-965411-(-965412)G=k+e w=h[G]J=m..w o[V]=J else G=d[V]w=G f=G and 5173472-(-680022)or-180265+13389716 end else f=D[U(-900758+962915)]O={}end end end else if f<2911555-900255 then if f<2081839-407015 then if f<-28496+1332726 then if f<1522692-292262 then J=U(919087-856514)H=18391265137405-749961 Z=d[A[-933560+933561]]m=29212134975458-(-658752)N=d[A[-891727+891729]]e=583038+27878061428023 E=N(J,m)f=Z[E]E=U(899673-837495)N=D[E]J=d[A[1018485-1018484]]m=d[A[101946+-101944]]G=U(820378+-758279)w=m(G,e)E=J[w]Z=N[E]E=d[A[-67395-(-67403)]]J=d[A[643366+-643358]]m=d[A[171631-171623]]N=Z(E,J,m)p[f]=N m=57400+6714499427326 Z=d[A[-433957-(-433958)]]J=U(887885+-825665)N=d[A[780761-780759]]E=N(J,m)f=Z[E]Z=.7 p[f]=Z e=U(-285691+348178)Z=d[A[413949-413948]]N=d[A[-85984+85986]]J=U(-622157-(-684500))m=1037762+11285669871301 E=N(J,m)f=Z[E]J=U(341130+-278814)E=D[J]m=d[A[477574+-477573]]w=d[A[73222+-73220]]G=w(e,H)J=m[G]G=U(915137+-852542)N=E[J]J=d[A[323140-323139]]e=5851362473237-27249 m=d[A[-447705-(-447707)]]w=m(G,e)m=28600331389187-(-584451)E=J[w]Z=N[E]J=U(574826-512211)p[f]=Z Z=d[A[-54406-(-54407)]]N=d[A[617190+-617188]]E=N(J,m)f=Z[E]Z=false p[f]=Z G=27294068130109-(-77928)N=d[A[-59691-(-59695)]]E=d[W]Z=N[E]E=d[A[-206094+206095]]J=d[A[876726+-876724]]w=U(467858-405421)m=J(w,G)N=E[m]f=Z[N]w=316499+17341824371512 N=d[A[-74336-(-74337)]]E=d[A[-55215-(-55217)]]m=U(-278978-(-341515))G=394406136289-(-1029846)J=E(m,w)Z=N[J]N=V w=U(527181+-464876)f[Z]=N N=d[A[51720-51716]]E=d[W]Z=N[E]E=d[A[-673449+673450]]J=d[A[-57610+57612]]m=J(w,G)w=34109577444239-32132 N=E[m]f=Z[N]N=d[A[880035+-880034]]m=U(-50940-(-113338))E=d[A[-30251+30253]]J=E(m,w)Z=N[J]N=V f[Z]=N f=o and 13829937-(-828951)or 3869864-(-237260)else u=-186722+5713536361414 k=U(861139-798728)a=d[A[90274-90273]]W=U(486572-424456)o=d[A[-234821+234823]]h=d[A[-255246-(-255249)]]F=786830+4937887057773 K=h(k,u)h=U(-796336+858652)V=o[K]O=a[V]o=D[h]K=d[A[577797+-577795]]k=d[A[1013640+-1013637]]u=k(W,F)h=K[u]W=15677772657929-(-927611)V=o[h]h=d[A[-474027-(-474029)]]u=U(-295352-(-357883))K=d[A[-197824-(-197827)]]k=K(u,W)o=h[k]a=V[o]f=O==a f=f and 990447+2528054 or 12336411-(-337045)end else if f<-112947+1569963 then f=212866-(-432678)O=d[A[1033480-1033474]]a=O()else o=z()a=z()V=z()F=1462028939467-60963 d[a]=P[106418+-106417]d[V]=P[314774+-314772]d[o]=P[695927-695924]W=U(449722+-387562)O=d[a]K=d[A[468013+-468012]]k=d[A[-79019-(-79021)]]u=k(W,F)h=K[u]f=O[h]F=28153715883720-265106 O=U(368839+-306659)O=f[O]h=t(-213830+7477691,{A[-603287+603290],a,A[399231-399230];A[-324610+324612],o})W=U(-305412+367557)O=O(f,h)O=d[a]K=d[A[-422088+422089]]o=T(o)k=d[A[-146483-(-146485)]]u=k(W,F)h=K[u]f=O[h]h=M(16102758-(-459300),{A[-546455+546458],a,A[1012553-1012552],A[-703167-(-703169)];V})O=U(782401+-720221)O=f[O]V=T(V)a=T(a)O=O(f,h)O={}f=D[U(-740016-(-802399))]end end else if f<432509+1512789 then if f<1446683-(-294759)then O=U(-349606-(-412055))a=M(-974911+3213485,{A[-1011491+1011493],A[964653-964650];A[1043147-1043143],A[-412628+412633];A[379818+-379812];A[-549803-(-549810)],A[-639439-(-639447)];A[780627-780618]})f=D[O]O=f(a)f=14798033-513851 else O=d[A[-543966+543967]]V=d[A[-252331-(-252333)]]k=-542858+22881655058985 o=d[A[-108593-(-108596)]]K=U(-349966+412069)h=o(K,k)a=V[h]f=O[a]f=f and-179250+13507304 or-1030270+12597203 end else if f<-493200+2490755 then e=U(-276026+338448)f=D[e]g=U(-41319-(-103516))H=D[g]e=f(H)f=U(513221+-450970)D[f]=e f=-208132+10887855 else F=U(-729521-(-791970))f=D[F]p=l(10486541-(-503586),{A[-365709-(-365713)],W,A[664607+-664606],A[-595717-(-595719)]})F=f(p)f=d[A[-289795+289799]]F=d[W]p=nil f[F]=p f=-378759+8543133 end end end else if f<257548+2104935 then if f<212337+2017220 then if f<-8848+2177334 then Z=f m=d[A[45640-45639]]e=U(-273909+336297)w=d[A[160772-160770]]H=30668628235782-(-532931)G=w(e,H)J=m[G]E=u[J]N=not E f=N and 937065+5778669 or 16292724-118711 p=N else f=F and 13099218-66610 or-256575+3565939 end else if f<2724017-460358 then V=U(-594970+657380)k=U(534104+-471642)a=D[V]V=a()a=-636895.5-(-636896)O=V*a a=791793-791792 F=U(19669-(-42691))u=18341935717498-(-804067)f=O%a a=f V=U(331072+-268659)O=D[V]o=d[A[149822+-149821]]h=d[A[-418189-(-418191)]]K=h(k,u)V=o[K]f=O[V]V=.8 o=-752858-(-752859)O=f(a,V,o)V=O h=d[A[395079-395076]]k=d[A[-880766+880767]]u=d[A[-112305+112307]]p=153890+17443222341272 W=u(F,p)K=k[W]o=h[K]f=o and-832026+11089639 or 817919+13263349 O=o else f=true O={f}f=D[U(862532+-799892)]end end else if f<591044+1884916 then if f<1510392-(-904549)then o=d[A[-659642+659643]]a=P[-892841+892842]V=a==o f=V and 3175611-(-287343)or 13573125-(-494479)O=V else k=32514335631119-(-316437)O=d[A[429145-429144]]K=U(964149-901919)V=d[A[914571+-914569]]o=d[A[-82393+82396]]h=o(K,k)a=V[h]f=O[a]O=U(7534+54797)O=f[O]O=O(f)f=2746827-(-283353)end else p=nil F=nil f=8008605-(-155769)end end end end else if f<2911561-(-343562)then if f<-923334+3948590 then if f<304954+2618331 then if f<2323402-(-445234)then if f<514415+2193098 then H=-67513+67513 m=#E f=-478127+5025202 J=m==H else f=14082215-630786 O=d[A[-823771+823777]]a=O()end else if f<1883204-(-1016734)then f=13286421-(-557428)else f=3091163-(-104587)end end else if f<-384387+3391990 then if f<3652578-686818 then f=m f=-603880+15634131 N=J else f=-130652+15493982 end else if f<3463982-447207 then H=621296+21696071068807 m=d[A[-1014171-(-1014172)]]w=d[A[19724-19722]]e=U(-88126+150238)x=-937708+19603428651668 j=11019485343983-859364 g=U(-699233+761709)G=w(e,H)w=U(155955+-93777)J=m[G]E=o[J]m=D[w]G=d[A[-199900-(-199901)]]e=d[A[-372858+372860]]H=e(g,j)w=G[H]J=m[w]g=7043196148441-298506 G=-237681-(-237682)w=37012+-37012 H=U(206003+-143719)e=288920+-288920 m=J(w,G,e)j=U(1102963-1040641)f=E+m w=d[A[119398-119397]]E=f G=d[A[630894+-630892]]e=G(H,g)Y=32719527365782-4370 G=U(672373-610195)m=w[e]J=p[m]w=D[G]e=d[A[69026+-69025]]H=d[A[-382908-(-382910)]]g=H(j,Y)G=e[g]H=415313-415313 m=w[G]e=505149-505146 G=-483186-(-483186)g=504527+17044738403378 w=m(G,e,H)f=J+w J=f Y=U(186178-124050)H=U(-543673+606196)f=J-E w=d[A[206103+-206102]]m=f G=d[A[-275592+275594]]e=G(H,g)f=w[e]e=U(-108313+170875)G=D[e]H=d[A[229251-229250]]g=d[A[393858+-393856]]j=g(Y,x)e=H[j]g=-366552+366554 w=G[e]H=m/g e=E+H G=w(e,J)g=-104601+24537733875003 H=U(-137071+199388)N[f]=G w=d[A[903327+-903326]]G=d[A[645156+-645154]]e=G(H,g)L=951379+3270553256351 x=-675803+2585760683151 f=w[e]Y=U(571801+-509274)e=U(-600935+663113)G=D[e]H=d[A[331278-331277]]g=d[A[430470-430468]]j=g(Y,x)e=H[j]H=.1 B=U(56632-(-5623))w=G[e]Y=d[A[-859136+859137]]J=nil x=d[A[345315+-345313]]e=.1 r=x(B,L)j=Y[r]g=m[j]G=w(e,H,g)H=U(473794-411696)N[f]=G w=d[A[-1045860-(-1045861)]]E=nil G=d[A[-226545+226547]]g=-1024796+365740778438 e=G(H,g)f=w[e]m=nil w=.3 N[f]=w f=304210+11924562 else Z=nil f=234783+3872341 N=nil end end end else if f<3959873-790934 then if f<3672403-572872 then if f<3451221-391470 then f=D[U(142522+-80105)]O={}else O={}f=D[U(57770-(-4372))]end else if f<-593281+3732672 then f=true f=f and 850866+8601074 or 4045+117103 else a={}d[A[-833957-(-833966)]]=a O={}f=D[U(-300513-(-362735))]end end else if f<4081179-884712 then if f<2474651-(-716852)then f=O and 6292621-(-96005)or-41028+12681516 else o=T(o)Z=nil o=nil p=T(p)V=T(V)J=nil h=T(h)W=nil F=T(F)E=nil Z={}f=14567333-(-645056)u=T(u)V=nil k=nil K=T(K)m=T(m)N=nil h=z()F=U(-629648+692121)d[h]=V V=z()k=U(-213239+275479)d[V]=o u=U(-380858-(-443098))K=D[k]k=U(1008005+-945881)E={}W=U(-146886-(-209144))o=K[k]K=z()d[K]=o p=z()k=D[u]u=U(-704724-(-767098))J=-66873-(-66874)o=k[u]u=D[W]W=U(-359408-(-421925))k=u[W]N=z()W=D[F]F=U(-716914+779545)u=W[F]F=z()W=-72500-(-72500)d[F]=W W=-774865+774867 d[p]=W W={}d[N]=Z Z=-201292+201292 m=-160519-(-160775)H=m m=815716+-815715 g=m m=-249070-(-249070)j=g<m m=J-g end else V,K=o(a,V)f=V and 991775+10900802 or 3912826-(-83622)end end end else if f<-35845+3922821 then if f<1013470+2446677 then if f<3093623-(-233355)then if f<3476547-192010 then K=d[A[-134374+134376]]W=U(120676-58233)k=d[A[232036-232033]]F=1718591094740-752820 u=k(W,F)f=-239025+3871357 h=K[u]o=a[h]V=not o O=V else F=d[A[825488+-825484]]p=d[W]f=F[p]f=f and 2767403-769569 or 8505389-341015 end else if f<743061+2637234 then a=a+o O=a<=V K=not h O=K and O K=a>=V K=h and K O=K or O K=-812122+14997908 f=O and K O=695998+3208887 f=f or O else O=d[A[-18585+18586]]K=U(-441719+504020)k=-83305+13937412529859 V=d[A[765555-765553]]o=d[A[607847+-607844]]h=o(K,k)a=V[h]f=O[a]O=U(51519-(-10812))O=f[O]O=O(f)f=330775+14185373 end end else if f<3692131-158330 then if f<3995607-525880 then V=d[A[100969+-100967]]O=V f=14177690-110086 else f=false d[A[-916313-(-916317)]]=f f=95874+12577582 end else if f<762609+2876493 then f=O and 2856142-569316 or-661199+7749491 else f=d[A[-156109+156110]]f=f and-116014+3101221 or 16013723-650393 end end end else if f<4617770-253919 then if f<3975759-(-27943)then if f<3776921-(-188966)then f=14535500-691651 else f=D[U(-919771-(-982112))]O={}end else if f<-547240+4825762 then f=2918225-367863 else f=1342582-(-487568)end end else if f<764222+3878079 then if f<5239381-810942 then f=d[A[120665+-120664]]K=a E=-904481+13880176535136 F=U(182343+-119963)p=32889945715911-(-739084)k=d[A[-336762-(-336764)]]u=d[A[710956+-710953]]N=U(-129368-(-191908))W=u(F,p)O=k[W]W=U(-154847+217260)u=D[W]F=d[A[-42567-(-42569)]]p=d[A[429064-429061]]Z=p(N,E)W=F[Z]k=u[W]W=.3 F=915156-915155 u=k(K,W,F)f[O]=u k=.05 O=U(-498020+560259)K=nil f=D[O]O=f(k)f=-936067+5899426 else Y=33732-33731 m=215733-215732 H=#E J=o(m,H)m=k(E,J)J=nil H=d[N]j=m-Y g=u(j)H[m]=g f=12117892-921272 m=nil end else a=-250814-(-250815)O=d[A[498899+-498898]]f=O+a d[A[1038586+-1038585]]=f O=d[A[-273341+273343]]K=U(-1030176+1092326)W=5677869849468-889129 V=d[A[490516-490513]]k=3529485111415-18956 u=U(-531770+594090)o=d[A[1037298+-1037294]]h=o(K,k)a=V[h]h=d[A[-775398+775401]]K=d[A[-552381-(-552385)]]k=K(u,W)o=h[k]h=d[A[675590+-675589]]V=o..h O[a]=V O=d[A[-914654-(-914659)]]f=O and 3746534-995177 or 14104703-653274 end end end end end else if f<864951+6046526 then if f<191472+5391969 then if f<-596172+5504886 then if f<564094+4196495 then if f<3811906-(-914936)then if f<340866+4360885 then p=14298831219594-921992 F=U(-552688+614986)f=d[A[120634-120632]]E=132117+21125901492824 k=d[A[832327+-832324]]u=d[A[-359119+359123]]W=u(F,p)O=k[W]N=U(-93884+156317)W=U(-262894+325307)u=D[W]F=d[A[886590+-886587]]p=d[A[-846116+846120]]Z=p(N,E)W=F[Z]k=u[W]F=.2 W=.3 u=k(K,W,F)k=.05 f[O]=u O=U(-489433+551672)f=D[O]K=nil O=f(k)f=10412076-585353 else N=d[A[-845033+845040]]E=d[W]Z=N[E]f=not Z f=f and 4212142-(-777052)or-1000545+13421709 end else if f<-741383+5483205 then f=true f=1797263-965282 else f=D[U(360982-298823)]O={}end end else if f<-597619+5475463 then if f<722270+4067541 then f=Z f=1892423-(-333862)F=p else w=w+e g=not H O=w<=G O=g and O g=w>=G g=H and g O=g or O g=13693754-(-739922)f=O and g O=1155553-131449 f=f or O end else if f<848176+4055349 then p=p+Z W=p<=F E=not N W=E and W E=p>=F E=N and E W=E or W E=-584369+1435634 f=W and E W=16161456-206094 f=f or W else E=127013-126513 f=Z<=E f=f and 698809+2310909 or 14382737-(-717829)end end end else if f<4993843-(-110695)then if f<193970+4842602 then if f<5339356-371503 then K=not h a=a+o O=a<=V O=K and O K=a>=V K=h and K O=K or O K=3845666-(-555650)f=O and K O=288318+13442650 f=f or O else f=d[A[295349+-295342]]Z=d[W]e=24848159177178-838824 J=d[A[642815-642814]]m=d[A[-67236+67238]]G=U(-882611+944763)w=m(G,e)E=J[w]N=p[E]f[Z]=N f=-87823+12508987 end else if f<4602172-(-485092)then f=-373872+10690176 else K=372228-372226 h=688115-688114 V=d[A[774931+-774930]]o=V(h,K)V=-597022+597023 a=o==V f=a and 120993+3052280 or-367887+13751320 O=a end end else if f<5981909-421881 then if f<5214399-(-180494)then w=U(893290-830754)Z=d[W]G=164108+3215048688845 E=d[A[-630607-(-630608)]]J=d[A[794516+-794514]]m=J(w,G)N=E[m]p=Z[N]f=p and 796466+7887792 or 2081580-(-144705)F=p else m=f x=-789451+29643271307702 H=d[A[749433+-749432]]g=d[A[674192-674190]]Y=U(966803+-904279)j=g(Y,x)e=H[j]r=19053062697957-889149 G=u[e]x=U(-389888+452396)e=U(-824719+887148)g=d[A[618017-618016]]j=d[A[-82554+82556]]e=G[e]Y=j(x,r)H=g[Y]e=e(G,H)w=not e f=w and 1970786-(-983820)or 9536743-(-636817)J=w end else E=U(1673-(-60585))N=D[E]f=-474569+11986059 E=U(-13856-(-76088))Z=N[E]F=Z end end end else if f<6918787-523735 then if f<6060446-258487 then if f<6569550-825555 then if f<5049546-(-625975)then O=d[A[-1041196+1041197]]a=319693-319692 f=O>a f=f and 542812+10632083 or-664836+1151092 else a=d[A[797107+-797106]]O=#a a=121620-121620 f=O==a f=f and-166210+8261166 or-729131+17408382 end else if f<5726628-(-57805)then h=o O=z()d[O]=h h=O O=z()d[O]=K k=U(274587+-212138)K=O u=t(7677991-926151,{A[493690-493682],h,A[-63036+63039];A[781707+-781703],K})K=T(K)O=D[k]h=T(h)f=10862482-961948 k=O(u)else o=d[A[728142-728136]]f=-816117+8245529 V=o==a O=V end end else if f<-130468+6281824 then if f<6301603-334224 then G=Z==N f=1045101+12164350 w=G else O={}f=D[U(-327558+389870)]a=nil end else if f<7060859-725451 then f=D[U(1001075+-938627)]O={}else O=U(29238-(-32975))f=D[O]F=t(101268+13783327,{})a=d[A[607566-607562]]h=U(290133-227711)W=U(-811640-(-874089))o=D[h]u=D[W]W={u(F)}k={i(W)}u=-276793+276795 K=k[u]h=o(K)o=U(-386322-(-448640))V=a(h,o)a={V()}O=f(i(a))a=O V=d[A[-292758+292763]]O=V f=V and-860319+6648860 or 7789427-360015 end end end else if f<601496+6150175 then if f<94927+6473787 then if f<7212502-743478 then f=d[A[222855+-222845]]V=d[A[-759555-(-759566)]]a[f]=V f=d[A[539802-539790]]V={f(a)}O={i(V)}f=D[U(147742+-85278)]else a=U(90381+-27907)o=-56273+56273 f=D[a]V=d[A[-78562+78570]]a=f(V,o)f=14787908-(-864787)end else if f<683845+6046336 then f=Z f=-65790+14719719 F=p else a=326894+-326893 O=32497-32497 V=a f=827305+8999418 a=.01 o=a a=-416378-(-416378)h=o<a a=O-o end end else if f<7192689-397442 then if f<6432700-(-331805)then V=d[A[-559391-(-559392)]]o=d[A[-624920+624922]]a=V[o]f=a and 10556174-(-505023)or-763209+15987832 O=a else f=584278+11513140 end else p=d[A[746346+-746341]]N=d[W]f=15351877-63963 Z=p(N)F=Z end end end end else if f<8101081-334883 then if f<635721+6622000 then if f<-111508+7210010 then if f<7486087-414685 then if f<7413216-433008 then O=U(172099+-109848)f=D[O]a=U(-699145+761342)O=D[a]a=U(848651-786454)D[a]=f a=U(177415-115164)D[a]=O a=d[A[-715421+715422]]V=a()f=10508564-192260 else O=d[A[987440+-987435]]V=d[A[-658990+658993]]k=8180084610902-(-30603)K=U(930309+-867952)o=d[A[-164185-(-164189)]]h=o(K,k)a=V[h]f=O[a]O=U(152664-90333)O=f[O]O=O(f)f=7060288-902131 end else if f<-44748+7132264 then F=-1025428+1025683 f=d[A[-887326+887327]]W=1010255+-1010255 u=f(W,F)V=o f=-602122+15015569 a[V]=u V=nil else V=d[A[-30198+30199]]h=d[A[596847+-596845]]u=U(1099350-1037240)K=d[A[136602-136599]]W=8918858138776-406623 k=K(u,W)u=U(-490323+552519)o=h[k]W=24791403699697-(-954151)O=V[o]h=d[A[922057-922055]]K=d[A[518408+-518405]]k=K(u,W)o=h[k]V=a[o]f=O~=V O={f}f=D[U(746620-684395)]end end else if f<511545+6669307 then if f<6465318-(-672670)then f=D[U(-908667+970961)]O={}else b=-870384+870386 f=11449710-(-12605)I=L[b]b=d[B]S=I==b X=S end else if f<7455036-237076 then O={}f=D[U(-625913+688120)]else W=24697167121924-(-515816)f=true d[A[-513130+513133]]=f V=d[a]h=d[A[-432542+432543]]u=U(3141-(-59289))K=d[A[842115+-842113]]k=K(u,W)o=h[k]f=710988+12292805 O=V[o]d[A[373899+-373895]]=O o=d[A[-317581-(-317586)]]F=-266413+11481652323727 K=d[A[751614-751613]]W=U(-423018+485530)p=783774+14305481155687 k=d[A[-302849-(-302851)]]u=k(W,F)h=K[u]V=o[h]d[A[999302-999296]]=V h=d[a]F=U(-928992-(-991158))k=d[A[-310912-(-310913)]]u=d[A[-640545-(-640547)]]W=u(F,p)K=k[W]o=h[K]K=n(-225955+1463358,{a,A[486986+-486985],A[-585389-(-585391)];A[960592+-960589]})h=U(-169424+231604)h=o[h]h=h(o,K)end end end else if f<-216131+7679711 then if f<6409549-(-976088)then if f<7282653-9677 then f=d[A[-387104-(-387105)]]F=17375074091577-303775 h=U(756130-693736)a=d[A[-297041+297043]]o=D[h]W=U(-300907-(-363277))O=U(1003118+-940492)K=d[A[-112637-(-112640)]]k=d[A[-609242-(-609246)]]u=k(W,F)W=U(354838-292284)h=K[u]V=o[h]h=.2 o=V(h)K=d[A[-746523-(-746526)]]F=-17415+7150544130312 k=d[A[325984-325980]]u=k(W,F)h=K[u]K=d[A[-921804+921809]]O=f[O]V={[h]=K}O=O(f,a,o,V)f=U(12887-(-49297))f=O[f]f=f(O)f=D[U(-52956+115506)]O={}else f=W k=u f=13849515-(-989963)end else if f<-769934+8191722 then S=686471-686470 s=L[S]X=s f=13391754-848200 else d[A[923099+-923094]]=O f=12829837-189349 a=nil end end else if f<-380431+8044944 then if f<6579026-(-1010594)then k,W=h(K,k)f=k and 1005649+7566531 or 502115+10041375 else K=nil f=-258112+7030655 end else W=T(W)f=8936072-(-40322)u=nil end end end else if f<8398007-(-136439)then if f<857059+7502582 then if f<-831569+8932954 then if f<-820898+8613878 then h,K=V(o,h)f=h and 1405935-604889 or 522689+2643275 else o=607502-607277 V=d[A[-738249-(-738251)]]a=V*o V=2453558877178-776067 O=a+V a=35184371601248-(-487584)V=302394+-302393 f=O%a d[A[403986-403984]]=f a=d[A[1039927-1039924]]O=a~=V f=438542+13363943 end else if f<8683561-368217 then f=856838+15192057 else f=d[A[341158-341157]]f=f and 1538207-(-143134)or-313587+13367010 end end else if f<-835380+9281418 then if f<7982079-(-453280)then a=a+o O=a<=V K=not h O=K and O K=a>=V K=h and K O=K or O K=-894112+11832765 f=O and K O=8911397-464563 f=f or O else s=f b=1023098-1023097 I=L[b]b=false S=I==b f=S and-124786+7296643 or-674802+12137117 X=S end else f=11562268-(-411301)end end else if f<-406373+9282791 then if f<796526+7771889 then if f<8267905-(-288459)then f=O and 111874+14076008 or-1035248+2117940 else a=U(1010652+-948106)O=U(1042401-979927)f=D[O]O=f(a)O={}f=D[U(-981016-(-1043174))]end else if f<9517638-857915 then f=z()d[f]=W u=k W=f Z=d[W]N=d[A[-933613+933616]]p=Z~=N F=p f=p and 643607+6257982 or 15738665-450751 else E=d[W]H=-50257+28970975803651 Z=f e=U(31687+30880)m=d[A[198221+-198220]]w=d[A[1035598+-1035596]]G=w(e,H)J=m[G]e=U(739964-677674)N=E[J]E=U(292074-229645)E=N[E]H=237920+2735296406425 m=d[A[-749287+749288]]w=d[A[346529-346527]]G=w(e,H)J=m[G]E=E(N,J)p=E f=E and-700085+13553634 or 5265192-503047 end end else if f<9624764-567134 then if f<8187111-(-754124)then u=1698292710183-(-542703)a=P[-765997-(-765998)]o=d[A[659369+-659368]]h=d[A[1000255-1000253]]k=U(-442045-(-504280))F=U(765798+-703589)K=h(k,u)V=o[K]p=-623737+5689043963602 K=U(177539-115223)O=a[V]h=D[K]k=d[A[545038+-545037]]u=d[A[-502241+502243]]W=u(F,p)F=-350828+34354305915113 K=k[W]o=h[K]K=d[A[-44567+44568]]W=U(-509186-(-571452))k=d[A[770051+-770049]]u=k(W,F)h=K[u]V=o[h]f=O==V f=f and-892443+10676626 or 9490360-(-777834)else K,W=k(h,K)f=K and 287015-(-297078)or-231415+9632885 end else f=15080899-198185 k=d[K]O=k end end end end end end else if f<-461181+13644050 then if f<831392+10249350 then if f<10781015-469192 then if f<583106+9212791 then if f<660613+8658973 then if f<47463+9190555 then if f<8126697-(-1034786)then J=m Y=J E[J]=Y J=nil f=15817828-605439 else H=U(-18456-(-80707))f=D[H]H=U(846825-784628)D[H]=f f=984567+9695156 end else if f<9175189-(-124952)then X=d[V]O=X f=X and 7736048-(-706968)or-801442+13963828 else f=true f=f and 12370084-566022 or 1255536-423555 end end else if f<9584946-157695 then if f<8471220-(-879164)then V=U(-220436-(-282914))O={}d[A[-282880-(-282887)]]=O f=206804+7572190 a=D[V]K=d[A[46981+-46972]]k={a(K)}V=k[876655-876654]h=k[-137188-(-137191)]o=k[687826-687824]else h=U(-978596-(-1041074))F=U(888620+-826102)f=D[h]u=d[A[277088+-277082]]F=u[F]W={F(u)}u={f(i(W))}K=u[765067-765065]h=u[632012-632011]k=u[-585853-(-585856)]f=-748066+8252859 end else if f<9799320-342359 then O=U(954868+-892629)a=-729837+729842 f=D[O]O=f(a)O=U(-505906-(-568355))a=n(4866932-995973,{A[-408328-(-408329)]})f=D[O]O=f(a)f=-757530+3894466 else f=a d[A[569462-569459]]=f f=327808+9940386 end end end else if f<9477408-(-610483)then if f<10945524-1003954 then if f<8945313-(-907332)then K=not h a=a+o O=a<=V O=K and O K=a>=V K=h and K O=K or O K=876188+13193647 f=O and K O=6964097-191554 f=f or O else o,K=a(V,o)f=o and 5231236-(-545661)or 8504252-(-816582)end else if f<9117309-(-841769)then f=false K=U(112707-50301)d[A[830085-830084]]=f u=477916+6465204142310 O=d[A[-14518+14520]]V=d[A[-939337+939340]]k=1315154116717-(-197111)o=d[A[561592+-561588]]h=o(K,k)a=V[h]o=d[A[808432-808429]]h=d[A[81077-81073]]k=U(766601-703987)K=h(k,u)V=o[K]O[a]=V k=186192+30273426202561 K=U(-296686+359322)O=d[A[649790+-649785]]f=9653189-(-247345)V=d[A[-335981+335984]]F=696348+1709560783616 o=d[A[404172-404168]]h=o(K,k)a=V[h]h=U(-1032509+1094922)W=U(589150+-526924)o=D[h]K=d[A[271798-271795]]k=d[A[258177+-258173]]u=k(W,F)k=-721331+721391 F=-706094+11646343322461 h=K[u]V=o[h]h=914666+-914411 K=-228482-(-228542)o=V(h,K,k)k=-381290+5390410308408 K=U(416398-354145)O[a]=o O=d[A[690661-690659]]V=d[A[699946+-699943]]o=d[A[-999669-(-999673)]]h=o(K,k)a=V[h]h=U(593063+-530650)o=D[h]K=d[A[929288+-929285]]k=d[A[-1001896-(-1001900)]]W=U(-593164+655603)u=k(W,F)k=127419+-127349 h=K[u]V=o[h]K=-969805-(-969835)h=-57250+57290 o=V(h,K,k)O[a]=o K=U(-146748-(-209180))O=d[A[-151120+151126]]k=-899044+3304170520038 V=d[A[-12815-(-12818)]]o=d[A[-479590+479594]]h=o(K,k)a=V[h]V=false O[a]=V a=U(-314120+376598)O=D[a]h=d[A[-198307-(-198314)]]K={O(h)}V=K[487528+-487526]a=K[634538+-634537]o=K[-77651-(-77654)]else f=3376450-179298 h=nil K=nil end end else if f<10199024-(-68355)then if f<973024+9272923 then G=d[A[980325+-980320]]e=G(u)w=not e f=-508773+3463379 J=w else F=U(-694719-(-757312))h=d[A[237099+-237096]]p=765399+22489872153361 k=d[A[-611385-(-611386)]]u=d[A[-428961-(-428963)]]W=u(F,p)f=13066386-(-1014882)K=k[W]o=h[K]h=U(813550+-751121)h=o[h]p=15904664043981-484575 k=d[A[338259-338258]]u=d[A[-895402+895404]]F=U(668791+-606530)W=u(F,p)K=k[W]h=h(o,K)O=h end else f=D[U(132477+-70290)]O={}a=nil end end end else if f<-934365+11744616 then if f<9838940-(-724725)then if f<9655378-(-827001)then if f<15370+10376117 then f=true f=f and 7824100-846186 or-259911+13639192 else O=d[A[531600+-531595]]V=d[A[320616+-320613]]o=d[A[157274+-157270]]K=U(-666276+728618)k=947475+10345539739070 h=o(K,k)a=V[h]f=O[a]f=f and 7964019-919882 or 5776849-(-381308)end else if f<10679158-141322 then K=U(-852536-(-915019))a=d[A[164139+-164138]]V=d[A[928996-928994]]O=a[V]V=d[A[-83716-(-83719)]]k=-52542+7899194497948 o=d[A[89060-89056]]h=o(K,k)a=V[h]f=O[a]f=f and 898495+-259611 or 3816508-(-939892)else a=nil f=D[U(1008385+-946029)]o=nil O={}V=nil end end else if f<784721+9885395 then if f<-50432+10626048 then a=d[A[545375+-545374]]V=d[A[664621-664619]]K=U(-634030-(-696259))k=-279741+7080239534493 O=a[V]V=d[A[230348-230345]]o=d[A[913818+-913814]]h=o(K,k)a=V[h]f=O[a]O=U(-698939+761270)O=f[O]O=O(f)f=747314+9767198 else f=E p=N f=4728273-(-33872)end else if f<9726746-(-1011354)then f=8402+15364287 else O=-914612+914612 a=-628770+629130 V=a a=284944+-284942 o=a f=119640+8298561 a=8806+-8806 h=o<a a=O-o end end end else if f<712934+10242675 then if f<280203+10650213 then if f<-1004288+11875886 then f=true u=U(126535+-64086)V=z()d[V]=f h=z()a=P o=U(1068955-1006482)O=D[o]o=U(-571202-(-633363))f=O[o]K=z()W=M(-257313+13369734,{K})o=z()d[o]=f f=C(8522377-(-39775),{})d[h]=f f=false d[K]=f k=D[u]u=k(W)O=u f=u and 8412240-(-645719)or-862517+15745231 else F=z()d[F]=O Z=407731+-407666 f=d[u]p=693841+-693838 O=f(p,Z)p=z()d[p]=O E=U(-20572+83021)f=541728+-541728 J=M(15619958-(-290722),{})Z=f f=547372+-547372 N=f O=D[E]E={O(J)}f={i(E)}O=-340995-(-340997)E=f f=E[O]e=U(843847-781425)J=f O=U(188047+-125834)f=D[O]m=d[o]G=D[e]e=G(J)G=U(1023409+-961091)w=m(e,G)m={w()}O=f(i(m))m=z()d[m]=O O=344934-344933 w=d[p]G=w w=17725+-17724 e=w w=-849740+849740 H=e<w w=O-e f=4719672-(-156306)end else if f<-277986+11224372 then K=a F=U(-182803+245375)f=d[A[-567772-(-567776)]]k=d[A[-389049-(-389051)]]p=-679217+22188613961101 u=d[A[-1015915-(-1015918)]]W=u(F,p)O=k[W]k=K f[O]=k O=U(326756+-264517)K=nil f=D[O]k=.03 O=f(k)f=8721484-303283 else O=d[A[-209166-(-209171)]]V=d[A[-267556+267559]]K=U(-242283-(-304865))o=d[A[862824-862820]]k=330369+17716697290168 h=o(K,k)a=V[h]f=O[a]O=U(-582842-(-645173))O=f[O]O=O(f)f=10694695-214229 end end else if f<1004623+10047322 then if f<-6385+10970793 then f=d[A[433447-433445]]a=196515+-196514.5 O=f()O=U(-419513-(-481752))f=D[O]O=f(a)f=d[A[262246-262243]]O=f()f=16290741-(-276336)else a=d[A[276211+-276210]]V=d[A[-259643+259645]]O=a[V]V=d[A[-729812-(-729815)]]k=31148617182070-963278 K=U(-183341-(-245775))o=d[A[-801392+801396]]h=o(K,k)a=V[h]f=O[a]f=f and 125122+10444892 or 11165230-650718 end else h=d[A[-44398+44400]]V=f p=869154+23823349327923 F=U(928230+-865795)k=d[A[-30631-(-30634)]]u=d[A[-680915+680919]]W=u(F,p)K=k[W]o=h[K]f=o and 16600978-535510 or 12717505-(-765046)a=o end end end end else if f<418953+12080843 then if f<190315+11566588 then if f<-1003050+12473172 then if f<-262988+11496592 then if f<-690687+11876860 then O=d[A[757363-757362]]a=-622784-(-622785)f=O-a d[A[233257+-233256]]=f K=U(367472+-305300)O=d[A[131668+-131666]]V=d[A[-852915-(-852918)]]k=-982201+11379969085804 u=U(451920-389553)o=d[A[-695979+695983]]h=o(K,k)a=V[h]W=263422+15224678028979 h=d[A[-590016+590019]]K=d[A[-945919-(-945923)]]k=K(u,W)o=h[k]h=d[A[354414-354413]]V=o..h O[a]=V O=d[A[-749030-(-749035)]]f=O and 751950-(-667539)or 76962+568582 else m=#E H=-47232+47232 J=m==H f=J and 384453+16263473 or 5400119-853044 end else if f<11152580-(-295060)then f=-269443+12778037 else f=s O=X f=-200913+13363299 end end else if f<799448+10781239 then if f<-369903+11883117 then f=p O=F f=F and 611704+10261653 or 583003+-455096 else f=D[U(-479479+541579)]O={}end else if f<10778248-(-865249)then O=U(-271399-(-333877))f=D[O]o=d[A[-934616+934617]]h={f(o)}a=h[-879312-(-879314)]f=2890616-(-306536)O=h[-1022761-(-1022762)]o=O V=h[-126829-(-126832)]else W=-195293+32835260806807 V=d[A[-171525+171529]]f=744235+7807187 h=d[A[353672+-353670]]u=U(-214951+277228)K=d[A[-736085-(-736088)]]k=K(u,W)o=h[k]a=V[o]O=a end end end else if f<12803251-614225 then if f<37217+11859102 then if f<11886202-8477 then f=957325+14415364 else h=V f=h and 428100+16146730 or 13980694-(-858784)k=h end else if f<12411565-373949 then O=d[A[966846+-966845]]k=24822501963464-690594 V=d[A[-108627-(-108629)]]o=d[A[-663193-(-663196)]]K=U(987294+-924678)h=o(K,k)a=V[h]f=O[a]f=f and-800902+11598254 or-37966+16265049 else f=d[A[-472505+472506]]f=f and 6182358-(-555462)or-652554+7756250 end end else if f<-403205+12811572 then if f<12723144-406579 then f=3594784-576903 else f=12637893-540475 end else e=-355324+22909373846952 Z=d[A[510428-510427]]m=33097078269537-764461 G=U(142968+-80851)N=d[A[-462524+462526]]J=U(-647165-(-709729))E=N(J,m)f=Z[E]E=U(360619+-298441)N=D[E]J=d[A[864792-864791]]m=d[A[-721186+721188]]w=m(G,e)E=J[w]Z=N[E]E=d[A[-887930-(-887938)]]J=d[A[-5819+5827]]e=U(-167896-(-230341))m=d[A[558880-558872]]N=Z(E,J,m)r=869125+11012377219331 m=-689894+29406126455907 J=U(568403-506314)p[f]=N Z=d[A[-599440+599441]]N=d[A[864680-864678]]E=N(J,m)H=15896253253838-764900 m=12692226718127-991897 f=Z[E]Z=.7 p[f]=Z Z=d[A[-871644+871645]]J=U(1005638+-943006)x=18851498240442-(-358544)N=d[A[802971-802969]]E=N(J,m)f=Z[E]J=U(72102+-9786)E=D[J]m=d[A[954275+-954274]]w=d[A[-530644-(-530646)]]G=w(e,H)J=m[G]G=U(939457-876833)N=E[J]J=d[A[310924+-310923]]m=d[A[778199-778197]]e=8520583891102-(-83681)w=m(G,e)E=J[w]Z=N[E]J=U(975031-912626)m=33818127965233-614062 p[f]=Z Z=d[A[-433485-(-433486)]]N=d[A[862815+-862813]]w=U(-789188-(-851737))E=N(J,m)f=Z[E]Z=false N=U(463905-401701)G=31661271695140-(-899699)p[f]=Z Z=D[N]E=d[A[-1024192+1024193]]e=U(1029315+-967024)J=d[A[-100554-(-100556)]]m=J(w,G)G=894776+26862519601572 H=11561235282421-861422 N=E[m]w=U(1046927+-984519)f=Z[N]E=d[A[200469-200468]]J=d[A[29684+-29682]]m=J(w,G)G=18966772528972-(-879412)w=-208302+16076977965804 N=E[m]m=U(-428-(-62696))Z=f(N)N=d[A[93156-93155]]E=d[A[-75682+75684]]J=E(m,w)f=N[J]E=d[A[227909+-227908]]w=U(-30020-(-92328))J=d[A[259991-259989]]m=J(w,G)N=E[m]Z[f]=N m=U(121727-59119)w=7582812050182-99643 N=d[A[892537+-892536]]E=d[A[-51988-(-51990)]]J=E(m,w)f=N[J]J=U(-239577-(-302093))E=D[J]m=d[A[-1005479+1005480]]w=d[A[271635+-271633]]G=w(e,H)J=m[G]N=E[J]m=-447884+448084 G=-380058+380108 J=-43079+43079 w=-522021+522021 E=N(J,m,w,G)w=8227911821834-809747 Z[f]=E N=d[A[-56755-(-56756)]]m=U(390762+-328346)E=d[A[717859-717857]]H=30614296339933-93742 J=E(m,w)f=N[J]N=true m=U(370565-308416)Z[f]=N N=d[A[-59980+59981]]w=691050+2041709688908 e=U(-701035-(-763289))E=d[A[-487676+487678]]J=E(m,w)f=N[J]J=U(-103541+165719)E=D[J]m=d[A[-505438-(-505439)]]w=d[A[-362756-(-362758)]]G=w(e,H)J=m[G]w=36089-36089 N=E[J]J=-103238+103238 m=-103423-(-103427)E=N(J,m,w)Z[f]=E w=781827+8961302127177 j=34399834937227-(-796423)N=d[A[-219958+219959]]e=-736702+14700139518075 E=d[A[-144419+144421]]g=8486741818965-(-610586)m=U(409423-346995)J=E(m,w)f=N[J]N=-181671-(-182671)Z[f]=N w=15979122247192-(-579320)N=d[A[885647-885646]]E=d[A[218193+-218191]]m=U(15977+46624)J=E(m,w)f=N[J]G=U(377026-314934)E=U(44943-(-17261))N=p Z[f]=N N=D[E]J=d[A[392544+-392543]]m=d[A[160116-160114]]w=m(G,e)E=J[w]G=U(748153-685907)e=-753445+6291267504790 f=N[E]J=d[A[-35419+35420]]H=U(-488795-(-551220))m=d[A[-832288-(-832290)]]w=m(G,e)E=J[w]N=f(E)E=d[A[67428-67427]]J=d[A[-809259+809261]]w=U(-752622+814928)G=19194171639292-(-56557)m=J(w,G)f=E[m]m=U(40373+22143)J=D[m]w=d[A[-472884+472885]]G=d[A[-164120+164122]]e=G(H,g)G=-138689-(-138690)m=w[e]E=J[m]m=44819+-44818 e=-741031+741031 w=-151338+151338 J=E(m,w,G,e)N[f]=J E=d[A[-644760-(-644761)]]w=U(384753-322311)J=d[A[230406-230404]]G=-413193+9026563808884 m=J(w,G)f=E[m]E=498046+-498045 N[f]=E H=U(-529871+592226)G=30886492548066-(-953420)w=U(5595-(-56653))E=d[A[-542902-(-542903)]]J=d[A[-865700+865702]]g=286859+17257907093209 m=J(w,G)f=E[m]J=d[W]w=d[A[-756205-(-756206)]]G=d[A[-197994-(-197996)]]e=G(H,g)m=w[e]E=J[m]w=U(111372-49127)G=25697573875689-(-605909)N[f]=E E=d[A[308088+-308087]]J=d[A[-241918+241920]]m=J(w,G)f=E[m]m=U(728547-666134)J=D[m]w=d[A[-409613+409614]]g=-185152+34321235235246 G=d[A[508893+-508891]]H=U(-542025+604214)e=G(H,g)m=w[e]G=-955783+955784 E=J[m]m=281341+-281340 g=8902803554820-(-249389)w=-136551+136552 J=E(m,w,G)N[f]=J E=d[A[-636636-(-636637)]]G=17314661964071-899497 H=U(847445+-784940)w=U(-54497+116676)J=d[A[348495-348493]]m=J(w,G)f=E[m]m=U(609897+-547484)J=D[m]w=d[A[-856316+856317]]G=d[A[-705117-(-705119)]]e=G(H,g)m=w[e]G=-453720-(-453720)E=J[m]w=408878+-408878 m=-833945-(-833945)J=E(m,w,G)N[f]=J g=U(281668-219161)G=11490462605382-363360 w=U(-399478-(-461972))E=d[A[617944-617943]]J=d[A[313273-313271]]m=J(w,G)G=6978446684183-(-613530)f=E[m]w=U(-973869-(-1036080))E=290730+-290730 N[f]=E E=d[A[837668+-837667]]J=d[A[708943+-708941]]m=J(w,G)Y=713238+8981744578112 f=E[m]E=-702129+702143 N[f]=E w=U(841688+-779523)E=d[A[-395183+395184]]J=d[A[-411102-(-411104)]]G=492033+6815508712036 m=J(w,G)w=U(746520-684204)f=E[m]m=D[w]G=d[A[-261577+261578]]e=d[A[-307388-(-307390)]]H=e(g,j)g=1200200155155-(-803355)w=G[H]J=m[w]H=U(-479005+541173)w=d[A[-341199+341200]]G=d[A[484707+-484705]]e=G(H,g)m=w[e]w=U(312481-249972)E=J[m]N[f]=E E=d[A[966244+-966243]]J=d[A[849429-849427]]e=U(-973477+1036047)G=-568285+19507735514968 m=J(w,G)J=U(-525526-(-587730))f=E[m]H=101849+15111716031907 E=Z N[f]=E E=D[J]m=d[A[761995+-761994]]w=d[A[392918+-392916]]G=w(e,H)H=9720785164374-231080 e=U(-931148-(-993598))J=m[G]f=E[J]m=d[A[-319635-(-319636)]]w=d[A[-922117+922119]]G=w(e,H)J=m[G]E=f(J)H=-150187+11588616773567 e=839021+18141489353618 G=U(85686+-23545)J=d[A[930412+-930411]]m=d[A[910513+-910511]]w=m(G,e)f=J[w]e=U(294811-232322)m=d[A[187924+-187923]]w=d[A[-96984-(-96986)]]G=w(e,H)J=m[G]G=U(2215+60237)E[f]=J J=d[A[-115556-(-115557)]]m=d[A[-998782-(-998784)]]e=594567+1398932729860 w=m(G,e)f=J[w]J=true E[f]=J J=d[A[613424-613423]]j=U(153079+-90648)e=-316943+34218468267085 G=U(-908023-(-970661))m=d[A[-767866-(-767868)]]w=m(G,e)f=J[w]J=false E[f]=J G=U(1059058-996814)J=d[A[689887+-689886]]e=30555390996865-965101 m=d[A[-814457-(-814459)]]w=m(G,e)f=J[w]G=U(-493382-(-555698))w=D[G]e=d[A[-717105-(-717106)]]H=d[A[284932-284930]]g=H(j,Y)G=e[g]m=w[G]j=-271781+10595330554090 G=d[A[756035+-756034]]g=U(-288102-(-350207))e=d[A[54361-54359]]H=e(g,j)w=G[H]e=3598929212661-274026 G=U(114858-52359)J=m[w]E[f]=J J=d[A[-517795+517796]]m=d[A[-244963+244965]]w=m(G,e)f=J[w]j=-884903+6025255308188 J=.3 E[f]=J e=11023455424085-(-247224)J=d[A[787086+-787085]]m=d[A[-736486-(-736488)]]G=U(-837728-(-900016))w=m(G,e)f=J[w]w=U(-433651-(-495829))g=U(131704+-69126)m=D[w]G=d[A[-220324+220325]]e=d[A[260055+-260053]]H=e(g,j)j=-113192+27002578611014 g=U(53789-(-8677))w=G[H]J=m[w]e=905378+-905377 w=.1 G=.1 Y=-777438+20725393982097 m=J(w,G,e)e=12560230821598-(-1026042)E[f]=m J=d[A[-333080-(-333081)]]G=U(201940-139836)m=d[A[443046-443044]]w=m(G,e)m=U(-503122+565625)f=J[w]J=D[m]E[f]=J f=d[A[179928-179924]]J=d[W]G=d[A[994166-994165]]e=d[A[-517627+517629]]H=e(g,j)w=G[H]e=d[A[-447383-(-447384)]]H=d[A[76554-76552]]j=U(212691-150306)g=H(j,Y)Y=U(480095-417638)G=e[g]H=d[A[927225-927224]]g=d[A[-484456-(-484458)]]j=g(Y,x)x=U(939691-877088)e=H[j]g=d[A[-911561+911562]]j=d[A[87559-87557]]Y=j(x,r)H=g[Y]m={[w]=Z;[G]=N;[e]=E,[H]=F}E=nil Z=nil N=nil f[J]=m f=-938838+15155560 end end end else if f<11909857-(-1003136)then if f<13056112-336086 then if f<12725631-96938 then if f<12310819-(-204790)then O={V}f=D[U(-692397+754490)]else R=-949305+949306 d[V]=X b=d[x]I=b+R S=L[I]s=Z+S S=284685+-284429 f=s%S Z=f I=d[Y]S=N+I I=874447-874191 s=S%I f=15583961-(-321948)N=s end else if f<12961792-310927 then f=d[A[-541491-(-541498)]]f=f and-695243+7177076 or 16467197-814502 else f=D[U(266927-204595)]O={}end end else if f<1026951+11831732 then if f<13420660-567102 then j=-937475+11692322743111 E=f m=d[W]G=d[A[-334943-(-334944)]]e=d[A[633046-633044]]g=U(-947526+1009627)H=e(g,j)w=G[H]J=m[w]g=U(313475-250856)j=8771165597983-647467 G=d[A[575535-575534]]e=d[A[-519396-(-519398)]]H=e(g,j)w=G[H]m=U(241551+-179122)m=J[m]m=m(J,w)N=m f=m and 754818+-475634 or 10631088-38608 else F=U(467190+-404741)p=C(15617432-787317,{W,A[-275297+275298];A[-317274-(-317276)]})f=D[F]F=f(p)f=d[A[-696161-(-696165)]]F=nil f[u]=F f=7375571-(-323354)end else s=d[V]f=s and-434850+7855760 or 11927244-(-616310)X=s end end else if f<-1045015+14102414 then if f<14024685-1004017 then if f<13536729-548220 then V=P[968308-968306]a=P[540010+-540009]f=d[A[529749+-529748]]o=f f=o[V]f=f and 10451699-(-956587)or 15674938-629615 else O={}f=D[U(-224325+286847)]a=T(a)end else if f<-261310+13312396 then F=d[W]J=U(-364834+427249)Z=d[A[-135671+135672]]m=18389600896120-(-531707)N=d[A[-130380+130382]]E=N(J,m)p=Z[E]f=F[p]F=f m=-314055+12353599611199 Z=d[A[-832939-(-832940)]]N=d[A[694655-694653]]J=U(678334+-616170)E=N(J,m)p=Z[E]f=F[p]p=f N=d[A[-481407+481411]]E=d[W]Z=N[E]f=not Z f=f and 4682865-(-43154)or 14577569-360847 else f=d[A[-451527-(-451537)]]O=U(264358+-202009)O=f[O]O=O(f)f=82050+14202132 end end else if f<-15042+13150421 then if f<12764614-(-326382)then f=-148430+3285366 else f=true d[A[648481-648480]]=f f=D[U(197854-135527)]O={}end else d[V]=O f=-416276+16322185 end end end end end else if f<-497254+15152929 then if f<239455+13828884 then if f<-751817+14370443 then if f<-825285+14205610 then if f<-743494+14061853 then if f<-890502+14189650 then d[V]=w f=d[V]f=f and 2657837-(-256231)or 4018029-(-710943)else f=17543065-863814 o=1023176-1023144 Z=-440362+440375 V=d[A[195917+-195914]]a=V%o h=d[A[331512-331508]]F=-570814+570816 u=d[A[1030231+-1030229]]J=d[A[43691+-43688]]E=J-a J=-162533+162565 N=E/J p=Z-N W=F^p k=u/W K=h(k)h=4294944702-(-22594)F=-689158-(-689414)o=K%h K=103067+-103065 h=K^a V=o/h Z=-914347+914603 h=d[A[87857+-87853]]W=481217-481216 u=V%W W=4295479677-512381 k=u*W K=h(k)h=d[A[-711744-(-711748)]]k=h(V)o=K+k u=1027703-962167 K=-806723-(-872259)h=o%K k=o-h K=k/u u=-436571+436827 k=h%u W=h-k u=W/F o=nil V=nil F=403094+-402838 W=K%F a=nil p=K-W h=nil K=nil F=p/Z p={k;u,W,F}d[A[-61535-(-61536)]]=p u=nil F=nil k=nil W=nil end else if f<391689+12958187 then a=69252+-69251 O=280246+-280246 V=a f=927547+4035812 a=.005 o=a a=19123-19123 h=o<a a=O-o else O={}f=D[U(-894566-(-956869))]end end else if f<486098+12960843 then if f<-531426+13931098 then V=d[A[351388+-351386]]o=d[A[1037762-1037759]]f=2724910-(-448363)a=V==o O=a else e=321349-321348 H=-714418+714424 f=d[u]G=f(e,H)H=U(260419+-198168)f=U(196310+-134059)D[f]=G e=D[H]H=15252+-15250 f=e>H f=f and 1444395-(-548488)or-474456+9655672 end else if f<-197878+13672865 then f=D[U(-712082-(-774536))]O={}else O=a f=V f=837720+14386903 end end end else if f<-3127+13884510 then if f<13091815-(-698998)then if f<14573029-873104 then f=11266255-(-707314)else f=1563920-(-266230)end else if f<-503511+14346010 then V=d[A[-23108-(-23111)]]o=-949214+949340 a=V*o V=-319073+319330 O=a%V d[A[-289502+289505]]=O f=15045023-(-264573)else V=d[A[461782-461781]]h=d[A[147745+-147743]]W=34427960209000-700361 u=U(16088+46551)K=d[A[-141095-(-141098)]]k=K(u,W)o=h[k]a=V[o]O=a f=a and 10955106-(-799744)or 8403152-(-148270)end end else if f<13554675-(-484398)then if f<-714367+14693013 then O=13613451-638906 V=U(757351-694816)o=10699249-349871 a=V^o f=O-a O=U(-80449+142557)a=f f=O/a O={f}f=D[U(312470-249884)]else f=true d[A[-686076+686077]]=f k=-597696+14707476674944 O=d[A[-570240+570242]]V=d[A[556515-556512]]o=d[A[-848296-(-848300)]]u=10555774421395-226912 W=U(874879+-812373)K=U(-723984+786583)h=o(K,k)k=U(-184410+246598)a=V[h]o=d[A[-395413+395416]]h=d[A[-1043476-(-1043480)]]K=h(k,u)V=o[K]O[a]=V O=d[A[643820-643815]]V=d[A[-264872-(-264875)]]K=U(954369+-891950)o=d[A[662086-662082]]k=4557967742196-314538 h=o(K,k)a=V[h]h=U(-595424+657837)o=D[h]K=d[A[148182-148179]]k=d[A[-474827+474831]]F=14779520684744-358374 u=k(W,F)h=K[u]W=15765020552369-462852 V=o[h]k=88144+-88064 u=U(-156602+218849)h=-184316-(-184396)K=894532-894277 o=V(h,K,k)O[a]=o K=U(-343298-(-405872))O=d[A[-293506+293512]]V=d[A[-648660+648663]]o=d[A[685222+-685218]]k=28171251337897-235371 h=o(K,k)a=V[h]V=true O[a]=V V=M(13007614-607687,{A[-151236-(-151237)];A[658048+-658046],A[-726226+726229],A[427045-427041]})a=U(1088666-1026320)O=D[a]a=O(V)a=z()O=nil d[a]=O V=d[A[956245-956238]]h=d[A[-389878+389881]]F=262838+12931601437903 K=d[A[-403306-(-403310)]]k=K(u,W)o=h[k]h=U(372483-310225)O=V[o]f=D[U(62915+-285)]o=C(406834+7938623,{A[875350-875349];A[-200592-(-200595)],A[-735958-(-735962)];A[-78474+78482],A[371213+-371204];A[852057+-852047];A[-700406-(-700417)];A[-234206+234218];A[-334179-(-334192)],a})V=U(-423887-(-486067))V=O[V]V=V(O,o)d[a]=V o=D[h]K=d[A[626237+-626234]]k=d[A[452194+-452190]]W=U(-944438+1006785)u=k(W,F)h=K[u]O=o[h]h=d[A[-579792+579806]]K=d[a]a=T(a)o=O(h,K)O={}end else f=O and 16403350-896511 or 6886282-896098 end end end else if f<-909324+15240654 then if f<-490967+14677135 then if f<-541930+14623959 then if f<14921014-844052 then O=d[A[-483255-(-483256)]]f=not O f=f and 7033500-(-595193)or 4867413-177581 K=a else o=O O=U(814708+-752230)f=D[O]k=d[A[-876025-(-876029)]]u={f(k)}O=u[-49282-(-49283)]h=u[711818+-711816]f=83441+8892953 K=u[-820573+820576]k=O end else if f<592184+13497119 then O=U(-28078+90317)a=370088+-370087 f=D[O]O=f(a)f=d[A[-816872+816873]]f=f and-281002+11236749 or 16393240-(-173837)else k=U(-189128+251541)K=a O=D[k]u=d[A[-506850+506852]]p=U(852247+-789886)Z=23684443410041-238437 W=d[A[-674394+674397]]F=W(p,Z)p=U(-155246+217817)k=u[F]Z=599680+14216141452123 f=O[k]k=.8 u=.9 O=f(K,k,u)f=d[A[864380-864379]]k=O u=d[A[-1013411-(-1013413)]]W=d[A[698534-698531]]F=W(p,Z)O=u[F]u=k f[O]=u f=d[A[928499+-928495]]p=U(1090724-1028409)Z=30984563954758-(-42006)u=d[A[240705+-240703]]W=d[A[492830+-492827]]F=W(p,Z)O=u[F]u=k f[O]=u O=U(28708+33531)f=D[O]k=nil u=.03 K=nil O=f(u)f=4352882-982946 end end else if f<-803254+15011207 then if f<14206927-13203 then f=3129129-(-240807)a=271868-271867 O=-1010901+1010901 V=a a=.01 o=a a=-130340+130340 h=o<a a=O-o else O=d[A[-953848+953853]]V=d[A[926391-926388]]o=d[A[-402542+402546]]K=U(336951+-274860)k=791376+1099844595376 h=o(K,k)a=V[h]f=O[a]f=f and 11424000-468689 or 9821490-(-658976)end else if f<134126+14109347 then Z=d[A[-176166+176170]]N=d[W]f=Z[N]f=f and-274960+1467771 or 2547729-(-2633)else O={}f=D[U(-213761+276309)]end end end else if f<455090+14039000 then if f<13802547-(-632384)then if f<128964+14304352 then o=o+K u=not k V=o<=h V=u and V u=o>=h u=k and u V=u or V u=6597447-(-477642)f=V and u V=714828+5689548 f=f or V else j=U(44917+17323)g=z()Y=-492305+492405 d[g]=w O=D[j]j=U(-633696+696070)f=O[j]j=-577947+577948 Q=997854+-987854 O=f(j,Y)R=-740252+740252 j=z()d[j]=O B=-368893+368894 Y=543236-543236 x=652915+-652660 f=d[u]O=f(Y,x)Y=z()x=836716+-836715 d[Y]=O f=d[u]r=d[j]L=550855+-550853 S=U(-405687-(-468109))O=f(x,r)x=z()d[x]=O O=d[u]r=O(B,L)O=343869-343868 f=r==O r=z()L=U(152086-89571)d[r]=f O=U(-422742-(-485060))s=D[S]I=d[u]b={I(R,Q)}S=s(i(b))s=U(-230619+293134)f=U(-924453-(-986709))X=S..s f=J[f]B=L..X f=f(J,O,B)B=z()X=M(4691812-(-412449),{u;g,p,o,V,m;r;B,j;x,Y;F})d[B]=f L=U(724800-662351)O=D[L]L={O(X)}f={i(L)}L=f f=d[r]f=f and 539855+8741080 or 13084110-218366 end else if f<-733975+15178351 then a=z()u=U(-961231-(-1023761))W=3585481791506-496013 d[a]=P[-670663-(-670664)]V=d[a]h=d[A[-531850-(-531851)]]p=-532167+19734978298540 K=d[A[19505+-19503]]k=K(u,W)K=U(646745-584429)o=h[k]O=V[o]h=D[K]F=U(-113498-(-176043))k=d[A[893318-893317]]u=d[A[-918866-(-918868)]]W=u(F,p)K=k[W]F=18323599946685-(-273815)W=U(-197000-(-259223))o=h[K]K=d[A[-487491-(-487492)]]k=d[A[945640+-945638]]u=k(W,F)h=K[u]V=o[h]f=O==V f=f and-840150+8095170 or 152962+12850831 else F=U(150480+-88129)p=-102377+26469960941583 a=P[766704+-766703]h=d[A[-818365-(-818366)]]k=d[A[-742431+742433]]u=d[A[868170+-868167]]W=u(F,p)K=k[W]o=h[K]V=not o O=V f=V and 3545636-(-86696)or-783176+4048160 end end else if f<-954738+15570261 then if f<13682484-(-877018)then k=19270214666456-26059 K=U(914726-852226)O=d[A[-138775+138776]]V=d[A[94795+-94793]]o=d[A[221466+-221463]]h=o(K,k)a=V[h]f=O[a]f=f and 2243808-(-196320)or-934676+3964856 else J=U(953226-890746)Z=d[A[597248+-597246]]m=24701048419029-(-784921)N=d[A[-553777+553780]]E=N(J,m)m=U(27691+34753)w=1004156+21111685338090 p=Z[E]F=h[p]N=d[A[536814+-536812]]E=d[A[-254851+254854]]J=E(m,w)f=-752687+8120468 p=U(592077+-529648)Z=N[J]p=F[p]p=p(F,Z)u=p end else f=F and-413889+13268993 or-411803+8110728 end end end end else if f<16051039-459886 then if f<14993463-(-223604)then if f<166103+14830348 then if f<401533+14431284 then if f<14021035-(-746337)then H=-699151+1594608823797 e=-535292+16557288868122 J=d[A[-301689-(-301690)]]m=d[A[-809249+809251]]G=U(-894839-(-957038))w=m(G,e)E=J[w]N=p[E]m=d[A[-611258+611259]]e=U(-637235-(-699471))w=d[A[618357-618355]]G=w(e,H)J=m[G]E=o[J]r=U(93219+-30591)Z=N-E G=18432940863730-610155 e=-1013365+31669005479952 w=U(-613207-(-675318))E=d[A[-763001-(-763002)]]J=d[A[937104+-937102]]m=J(w,G)N=E[m]G=U(-652955-(-715506))f=Z[N]E=d[A[368998-368994]]J=d[W]N=E[J]J=d[A[-282234-(-282235)]]m=d[A[142034+-142032]]Z=f w=m(G,e)G=11315392687932-(-386393)E=J[w]f=N[E]E=d[A[-909143+909144]]j=1390059361574-1004191 J=d[A[-732508+732510]]g=U(957146+-894796)w=U(-577008+639492)m=J(w,G)N=E[m]m=d[W]G=d[A[-691280-(-691281)]]B=586232+12714325812520 e=d[A[-509297+509299]]H=e(g,j)g=U(399060+-336907)w=G[H]J=m[w]G=d[A[278224+-278223]]j=61402+8073248923349 e=d[A[-94258+94260]]H=e(g,j)w=G[H]g=U(4950+57290)H=D[g]j=d[A[961181+-961180]]Y=d[A[216129+-216127]]x=Y(r,B)g=j[x]x=U(326709+-264472)e=H[g]H=e(Z)g=d[A[-554861-(-554862)]]j=d[A[-840470-(-840472)]]r=424153825883-(-376426)Y=j(x,r)e=g[Y]G=H..e m=w..G E=J..m f[N]=E E=d[A[-622370+622374]]J=d[W]N=E[J]e=3444266788038-(-123261)J=d[A[-305100+305101]]G=U(-150003-(-212547))m=d[A[93402-93400]]w=m(G,e)E=J[w]f=N[E]N=f f=N and 929179+3977217 or-307327+3325208 else O=d[A[-844058-(-844059)]]V=d[A[315541+-315539]]o=d[A[-620898+620901]]k=733392121581-241048 K=U(-30759-(-93066))h=o(K,k)a=V[h]f=O[a]f=f and 200558+3201671 or 14149700-(-366448)end else if f<15012830-167217 then f=k and 16805609-654794 or 10583147-620091 else u=U(46416-(-15824))k=O O=D[u]N=U(-185618-(-247876))u=U(-842595+904969)f=O[u]W=U(311464+-249206)u=z()d[u]=f O=D[W]W=U(824389+-762264)f=O[W]p=f Z=D[N]F=Z W=f f=Z and 96133+5483640 or 10965026-(-546464)end end else if f<318732+14735307 then if f<932412+14098737 then p=N f=E f=6459506-(-256228)else f={}d[A[414279+-414277]]=f K=35184372054793-(-34039)f=5772024-882818 O=d[A[-609177+609180]]h=O O=V%K d[A[614776-614772]]=O u=-811184+811439 k=V%u W=U(62223+250)u=97301+-97299 K=k+u d[A[785697+-785692]]=K u=D[W]W=U(-862539+924942)k=u[W]u=k(a)k=U(616937-554840)W=509237-509236 o[V]=k k=197146+-196953 p=-1002004-(-1002005)Z=p p=-157370+157370 N=Z<p p=W-Z F=u end else if f<-238209+15342346 then w=U(-904790-(-967423))E=d[A[-714074-(-714075)]]J=d[A[-304131-(-304133)]]G=-601059+31797896242618 m=J(w,G)f=E[m]E=329677-329676 N[f]=E f=11875854-(-352918)else Y=not j m=m+g J=m<=H J=Y and J Y=m>=H Y=j and Y J=Y or J Y=-705598+9863427 f=J and Y J=2604818-21660 f=f or J end end end else if f<16163528-813342 then if f<15983017-679880 then if f<16212084-927139 then f=O and 162832-(-379542)or 407370+13786739 else f=F and 500727+4653896 or-394097+16442992 end else if f<15766220-457862 then f=d[A[479526-479523]]O=f()f=293617+2786560 else V=d[A[-425940+425943]]o=911478-911477 a=V~=o f=a and 13891648-579007 or 963746+12838739 end end else if f<-708038+16117059 then if f<16321620-949675 then O={}f=D[U(-384861-(-447467))]else f=true f=f and 206006+13204600 or 7998912-784272 end else k=U(-809152+871326)E=33982819398599-(-854537)Z=26591591095817-503211 o=d[A[26260+-26257]]u=16167843317138-(-251862)h=d[A[-1036544+1036548]]K=h(k,u)p=U(563931-501463)V=o[K]O=a[V]V=d[A[547134+-547129]]f=O-V V=f o=U(-952783+1015299)H=14453273764018-(-424344)O=D[o]u=U(-928320+990862)h=d[A[-818364-(-818367)]]W=16607746370651-(-94682)K=d[A[-39724-(-39728)]]k=K(u,W)o=h[k]f=O[o]K=d[A[-608017-(-608023)]]u=d[A[-465381-(-465384)]]W=d[A[977913+-977909]]F=W(p,Z)k=u[F]h=K[k]F=U(-342596+404870)k=d[A[850541+-850538]]N=U(961919-899831)p=-746543+17629873210432 u=d[A[-672668+672672]]W=u(F,p)K=k[W]o=h[K]u=d[A[554943+-554937]]F=d[A[536453-536450]]p=d[A[-344508+344512]]Z=p(N,E)W=F[Z]k=u[W]W=d[A[380878-380875]]F=d[A[736750-736746]]Z=U(1078128-1015633)N=33742133822163-(-883341)m=14679301179168-(-676755)p=F(Z,N)u=W[p]K=k[u]N=10599215693195-(-284092)W=d[A[-418-(-421)]]Z=U(259143-196746)F=d[A[-560643+560647]]p=F(Z,N)e=U(-702349+764550)u=W[p]k=V[u]h=K+k N=U(457725+-395466)E=-185913+27554266089559 u=d[A[-64319+64325]]F=d[A[440202-440199]]p=d[A[-602798-(-602802)]]Z=p(N,E)W=F[Z]k=u[W]Z=U(330349+-268077)W=d[A[-368006+368009]]N=24225719813378-(-976654)F=d[A[55258+-55254]]p=F(Z,N)u=W[p]K=k[u]F=d[A[-290821-(-290827)]]w=U(126035+-63634)Z=d[A[36231-36228]]J=U(-533581-(-595789))N=d[A[578086-578082]]E=N(J,m)p=Z[E]J=-834247+21859818021514 W=F[p]p=d[A[342061+-342058]]Z=d[A[-836907+836911]]E=U(-670061-(-732180))N=Z(E,J)F=p[N]J=628108870353-33197 u=W[F]E=U(-910771+973111)p=d[A[498287+-498284]]Z=d[A[435043+-435039]]N=Z(E,J)F=p[N]W=V[F]E=-556516+26763235864210 k=u+W u=U(771047-708669)O=f(o,h,K,k)f=d[A[791187+-791180]]m=14482171754497-(-533078)h=d[A[335246-335243]]o=O W=33140683696853-(-594291)Z=29931567346095-719678 K=d[A[911010-911006]]k=K(u,W)O=h[k]h=o N=U(-400084+462276)W=17265213485105-(-356150)J=U(-859281-(-921402))f[O]=h f=d[A[410228-410220]]u=U(851972-789748)h=d[A[61794+-61791]]K=d[A[542272+-542268]]k=K(u,W)O=h[k]p=U(-442264-(-504478))k=U(-337786+400302)K=D[k]G=-555580+10363491241237 u=d[A[-1033735-(-1033738)]]W=d[A[194862-194858]]F=W(p,Z)k=u[F]h=K[k]F=d[A[644383+-644380]]p=d[A[-175246+175250]]Z=p(N,E)W=F[Z]N=U(717576-654976)u=o[W]F=d[A[20770+-20767]]p=d[A[-519594+519598]]E=20850695093463-(-59670)Z=p(N,E)W=F[Z]k=u[W]Z=d[A[-328246-(-328249)]]N=d[A[53529-53525]]E=N(J,m)m=777660+9902462645319 J=U(812753-750605)p=Z[E]F=o[p]Z=d[A[-63026-(-63029)]]N=d[A[399188-399184]]E=N(J,m)p=Z[E]W=F[p]Z=d[A[884178-884169]]E=d[A[505996-505993]]J=d[A[494359+-494355]]m=J(w,G)N=E[m]p=Z[N]G=-480967+30901712686844 N=d[A[758121+-758118]]m=U(-714245-(-776641))w=865119+25963823496155 E=d[A[-335859-(-335863)]]J=E(m,w)Z=N[J]J=U(472374-409948)m=24207944384387-(-978053)F=p[Z]u=W+F Z=d[A[-1040857-(-1040860)]]N=d[A[-471710+471714]]E=N(J,m)p=Z[E]F=o[p]Z=d[A[-372614+372617]]J=U(-947112-(-1009524))V=nil N=d[A[636493-636489]]m=16077025893854-(-966496)E=N(J,m)p=Z[E]w=U(-871624+933913)W=F[p]E=d[A[-448330-(-448333)]]J=d[A[-421951-(-421955)]]m=J(w,G)N=E[m]w=U(691227+-628622)Z=o[N]E=d[A[-1020233+1020236]]G=4701347223635-380870 J=d[A[52755-52751]]m=J(w,G)N=E[m]p=Z[N]E=d[A[-42267+42276]]m=d[A[944569-944566]]w=d[A[862655-862651]]G=w(e,H)J=m[G]G=U(193899+-131612)N=E[J]o=nil J=d[A[1020772-1020769]]m=d[A[-980353+980357]]e=32600006297979-822831 w=m(G,e)E=J[w]Z=N[E]F=p+Z K=h(k,u,W,F)f[O]=K f=490624+5499560 end end end else if f<16885310-728436 then if f<16048624-70598 then if f<15055767-(-851503)then if f<-24414+15789312 then f={}V=953440-953439 a=f o=d[A[598790+-598781]]h=o o=240499-240498 K=o o=43915-43915 k=K<o o=V-K f=14790978-377531 else B=T(B)j=T(j)x=T(x)r=T(r)Y=T(Y)f=-523600+5399578 L=nil g=T(g)end else if f<-719041+16658936 then o=752174+1959001 V=U(-1015938+1078417)a=V^o O=4668564-(-335315)f=O-a a=f O=U(-139463-(-201583))f=O/a O={f}f=D[U(-777495+839922)]else h=nil f=12018662-(-489932)k=nil u=nil end end else if f<16593704-450700 then if f<-752126+16809364 then u=nil f=-78225+7583018 W=T(W)else p=-186768+8130975164506 h=d[A[888399+-888397]]k=d[A[-505663+505666]]u=d[A[-371674-(-371678)]]F=U(-1553+64182)W=u(F,p)p=14619563371844-676525 F=U(-372104+434472)K=k[W]o=h[K]f=668750+12813801 k=d[A[117741+-117738]]u=d[A[-702668+702672]]W=u(F,p)h=U(-164020+226449)K=k[W]h=o[h]h=h(o,K)a=h end else Z=U(532369-470036)W=d[A[17614+-17612]]N=26931046780843-384687 J=28640607773868-(-118636)F=d[A[737912-737909]]p=F(Z,N)u=W[p]k=h[u]Z=U(824730-762365)N=-253514+31166254077690 W=d[A[198622+-198620]]F=d[A[580981+-580978]]p=F(Z,N)Z=-491028+16200741116812 u=W[p]f=k[u]u=d[A[943144+-943142]]p=U(372364+-310210)W=d[A[313909-313906]]F=W(p,Z)k=u[F]E=U(-507617-(-570198))F=U(102032-39854)W=D[F]p=d[A[-692771+692773]]Z=d[A[203020-203017]]N=Z(E,J)F=p[N]u=W[F]F=d[A[676385+-676381]]p=d[A[-257384-(-257388)]]Z=d[A[-329532-(-329536)]]W=u(F,p,Z)N=-93471+1372291739550 f[k]=W W=d[A[-363651-(-363653)]]F=d[A[54662+-54659]]Z=U(-199304-(-261862))p=F(Z,N)u=W[p]k=h[u]Z=U(-571401-(-634028))W=d[A[439757+-439755]]N=470986+27847082787549 F=d[A[-365109+365112]]p=F(Z,N)u=W[p]f=k[u]p=U(-165360-(-227981))Z=31944777527214-13715 u=d[A[-19625+19627]]W=d[A[791536-791533]]F=W(p,Z)k=u[F]u=.7 f[k]=u f=170696+9792360 end end else if f<283355+16285785 then if f<757727+15752927 then if f<16507808-286037 then G=d[A[636567+-636566]]g=U(62970-390)E=f e=d[A[-876469+876471]]j=-5709+24445509714628 H=e(g,j)w=G[H]m=u[w]J=not m f=J and 609551+14420700 or 5776526-271121 N=J else f=D[U(-842733+904851)]O={}end else if f<674316+15892178 then f=d[A[-854685-(-854686)]]a=d[A[-258567-(-258569)]]F=770806+28755816984920 h=U(612353-549959)o=D[h]K=d[A[480747-480744]]k=d[A[-617474+617478]]W=U(376806+-314433)u=k(W,F)h=K[u]V=o[h]h=.2 F=-237918+25667958411278 W=U(703049-640502)o=V(h)K=d[A[937056+-937053]]O=U(317431-254805)k=d[A[909077-909073]]O=f[O]u=k(W,F)h=K[u]K=d[A[-179295-(-179300)]]V={[h]=K}O=O(f,a,o,V)f=U(81714+-19530)f=O[f]f=f(O)O={}f=D[U(-746996-(-809443))]else f=D[U(-817360+879504)]O={}end end else if f<17355492-676577 then if f<-639428+17278733 then W=f Z=d[A[403673+-403671]]N=d[A[-34561+34564]]m=25615892802278-719950 J=U(421244+-359150)E=N(J,m)p=Z[E]F=h[p]u=F f=F and 491246+14123071 or 8309731-941950 else u=nil m=z()H=l(-212853+5898676,{m,F;p;K})J={}o=nil k=nil r=U(-245344-(-307842))d[m]=J J=z()d[J]=H K=T(K)g=z()j=U(251413+-189148)Z=nil H={}Y={}Z=718465+20839184691047 d[g]=H H=D[j]E=nil L=U(-1009836+1072164)B=d[g]S=nil x={[r]=B;[L]=S}j=H(Y,x)d[h]=j W=nil D3=1021062+21408318067307 H=M(13628669-655555,{g,m,N,F,p,J})d[V]=H m=T(m)p=T(p)F=T(F)K=U(314904-252351)o=D[K]N=T(N)g=T(g)J=T(J)u=d[h]W=d[V]p=U(-267228+329817)F=W(p,Z)k=u[F]K=U(-880758-(-942991))m=-62701+17037460706282 K=o[K]N=24125394044833-(-648257)Z=U(629086+-566492)K=K(o,k)o=z()d[o]=K E=10478989605127-796152 r=-196187+33475576298303 k=U(705234-642681)K=D[k]W=d[h]F=d[V]B=843666+12736150173592 k=U(-206095-(-268328))p=F(Z,N)k=K[k]u=W[p]J=11415215923269-(-996478)k=k(K,u)K=z()u=U(-347721+410274)d[K]=k k=D[u]N=U(-960171-(-1022311))F=d[h]u=U(-147643-(-209876))p=d[V]u=k[u]H=479064+10242904556361 Z=p(N,E)W=F[Z]u=u(k,W)I=10929329687827-(-591566)k=z()E=U(-920837+983037)Y=U(-396764-(-459202))d[k]=u W=U(-579181+641734)u=D[W]x=2843728016704-225300 W=U(-887532+949765)p=d[h]Z=d[V]N=Z(E,J)W=u[W]F=p[N]W=W(u,F)J=U(-64715+126956)F=d[o]Z=d[h]N=d[V]E=N(J,m)p=Z[E]u=F[p]F=z()d[F]=u Z=U(-924796+987000)m=U(459101-396582)p=D[Z]N=d[h]E=d[V]J=E(m,H)m=U(624685+-562265)Z=N[J]u=p[Z]H=21392851327162-(-740911)N=d[h]E=d[V]J=E(m,H)Z=N[J]p=u(Z)m=6107867339646-315490 J=U(-9056+71194)Z=d[h]N=d[V]E=N(J,m)u=Z[E]m=U(286968-224695)H=25721760435935-(-810986)N=d[h]E=d[V]J=E(m,H)Z=N[J]m=15817068215280-663339 p[u]=Z Z=d[h]J=U(155536-93046)N=d[V]E=N(J,m)u=Z[E]Z=false f3=U(-587379-(-649778))p[u]=Z Z=d[h]J=U(-201541+263671)m=-349912+2662604463023 N=d[V]E=N(J,m)J=U(552929+-490613)u=Z[E]E=D[J]m=d[h]H=d[V]g=H(Y,x)J=m[g]g=U(617758-555266)N=E[J]J=d[h]Y=-429029+23738431059731 m=d[V]H=m(g,Y)E=J[H]m=-240825+11874632516178 Z=N[E]p[u]=Z Z=d[h]J=U(358125-295883)R=U(-845796+908306)N=d[V]E=N(J,m)u=Z[E]Z=-72955+82954 m=10030943942135-(-613448)p[u]=Z Z=d[h]U3=-1029648+18714635278362 J=U(-186998+249541)N=d[V]E=N(J,m)g=-285534+309807127534 u=Z[E]Z=W p[u]=Z N=U(-687315+749519)Z=D[N]z3=19191178173483-(-329405)E=d[h]J=d[V]H=U(999134-936659)m=J(H,g)g=96485+27968717470202 Q=1651155084154-(-73606)N=E[m]H=U(1036799+-974537)u=Z[N]E=d[h]J=d[V]m=J(H,g)x=U(-472381+534648)N=E[m]Z=u(N)H=U(747171-684986)u=z()d[u]=Z g=29551223673823-777759 Z=d[u]E=d[h]J=d[V]m=J(H,g)N=E[m]m=U(680923+-618407)J=D[m]H=d[h]g=d[V]Y=g(x,r)m=H[Y]E=J[m]g=527710-527710 m=-407890+407890 Y=-75134-(-75254)H=-645605-(-645905)r=28975706058652-15080 x=U(-678765-(-740878))J=E(m,H,g,Y)Z[N]=J Z=d[u]E=d[h]H=U(672633+-610376)J=d[V]g=-743840+34608854423700 m=J(H,g)N=E[m]m=U(-459909+522425)J=D[m]H=d[h]g=d[V]Y=g(x,r)S=U(-870778-(-932904))m=H[Y]H=-287962-(-287982)Y=-293930-(-293950)E=J[m]g=-1027644+1027644 m=-546069-(-546069)J=E(m,H,g,Y)Z[N]=J Z=d[u]g=277070+6998186005100 H=U(-726026+788290)E=d[h]J=d[V]x=U(-905211+967671)r=317385+21701116448688 m=J(H,g)N=E[m]m=U(502476-440063)J=D[m]H=d[h]g=d[V]Y=g(x,r)m=H[Y]E=J[m]g=-247369+247394 m=611622+-611607 H=-34257+34272 J=E(m,H,g)Z[N]=J Z=d[u]g=34542957881486-(-710215)H=U(-313683-(-376027))E=d[h]J=d[V]m=J(H,g)g=23739055907112-(-690694)N=E[m]E=.1 Z[N]=E Z=d[u]Y=10282591889547-(-1010217)E=d[h]H=U(314493-251868)J=d[V]m=J(H,g)N=E[m]E=731547+-731547 Z[N]=E Z=d[u]r=U(430157-367534)E=d[h]g=32490977538592-177927 H=U(-1015560+1077751)J=d[V]m=J(H,g)N=E[m]E=p Z[N]=E g=U(829853+-767352)E=U(967857+-905653)N=D[E]J=d[h]m=d[V]H=m(g,Y)E=J[H]Z=N[E]Y=-1006975+19546170654988 J=d[h]g=U(173804+-111677)m=d[V]H=m(g,Y)E=J[H]Y=563169+15996341290295 g=U(860483-798223)N=Z(E)Z=z()d[Z]=N N=d[Z]J=d[h]m=d[V]H=m(g,Y)E=J[H]H=U(-318426-(-380919))m=D[H]g=d[h]Y=d[V]x=Y(r,B)H=g[x]J=m[H]x=U(404054-341585)Y=D[x]r=d[h]B=d[V]L=B(S,I)x=r[L]g=Y[x]L=U(545530+-483117)B=D[L]S=d[h]x=159363+-159363 I=d[V]b=I(R,Q)I=-549463+549513 L=S[b]r=B[L]S=107914-107904 L=427513+-427483 b=336880+1677173268252 B={r(L,S,I)}Y=g(x,i(B))r=U(15820-(-46649))x=D[r]B=d[h]I=U(1098787-1036235)L=d[V]Q=U(1041727+-979556)S=L(I,b)r=B[S]S=U(199899-137486)g=x[r]r=-744428.5-(-744429)L=D[S]I=d[h]b=d[V]R=b(Q,D3)S=I[R]B=L[S]I=878910-878900 b=996235+-996155 S=-384386+384436 L={B(S,I,b)}D3=U(247220+-184739)x=g(r,i(L))B=U(634+61835)r=D[B]L=d[h]S=d[V]R=-888793+13066372966301 b=U(1075854-1013418)I=S(b,R)B=L[I]I=U(-674253-(-736666))g=r[B]B=858278+-858277 S=D[I]b=d[h]R=d[V]Q=R(D3,U3)I=b[Q]L=S[I]I=8961+-8931 R=-417711-(-417761)b=717678-717668 S={L(I,b,R)}r={g(B,i(S))}H={Y;x,i(r)}m=J(H)N[E]=m N=d[Z]J=d[h]Y=265573+31651223874605 g=U(-485710-(-547944))m=d[V]H=m(g,Y)Y=34459224483735-321769 E=J[H]J=77046-77001 N[E]=J N=d[Z]g=U(299830+-237371)J=d[h]m=d[V]H=m(g,Y)E=J[H]J=d[u]N[E]=J J=t(13793470-119394,{u;h;V;Z})E=U(503350+-441004)V3=U(-140344+202716)x=-641963+15091920250654 N=D[E]E=N(J)J=U(-869142-(-931346))E=D[J]Y=U(-22434-(-84731))m=d[h]H=d[V]B=907871+3645977242690 g=H(Y,x)J=m[g]N=E[J]Y=U(-596634-(-659226))x=27485104433619-(-968747)S=29430136009396-(-410324)m=d[h]H=d[V]g=H(Y,x)J=m[g]g=U(235558+-173262)E=N(J)J=d[h]Y=393901+25032340679387 m=d[V]O3=29793446501920-(-284689)H=m(g,Y)N=J[H]H=U(713018+-650654)m=D[H]g=d[h]Y=d[V]r=U(1051167-988872)x=Y(r,B)H=g[x]J=m[H]H=-140574-(-140574)g=-384869-(-384881)r=35063285399495-(-229376)m=J(H,g)g=U(-434382+496703)E[N]=m J=d[h]Y=4175365564810-(-7694)m=d[V]H=m(g,Y)N=J[H]L=U(-727478-(-789801))m=U(696036+-633832)J=d[u]E[N]=J J=D[m]H=d[h]x=U(659732-597598)g=d[V]Y=g(x,r)m=H[Y]N=J[m]x=U(804791-742656)r=-725197+3955785717759 H=d[h]g=d[V]Y=g(x,r)x=U(-143872-(-206482))m=H[Y]J=N(m)N=z()d[N]=J J=d[N]I=23221469630140-(-744321)H=d[h]g=d[V]r=487023+32144082652169 Y=g(x,r)m=H[Y]Y=U(706291+-643878)g=D[Y]x=d[h]r=d[V]B=r(L,S)Y=x[B]A3=20917931324567-(-160117)x=-517768+517768 H=g[Y]r=-778676+778876 Y=-175392-(-175492)g=H(Y,x,r)x=U(-396646+458753)J[m]=g J=d[N]r=-613487+2246989602949 H=d[h]g=d[V]S=U(-864061-(-926617))Y=g(x,r)x=U(-576679+638788)m=H[Y]H=-986458-(-986460)r=31568564749628-35792 J[m]=H J=d[N]H=d[h]g=d[V]Y=g(x,r)x=U(339092-276776)m=H[Y]Y=D[x]r=d[h]B=d[V]L=B(S,I)x=r[L]I=32862648889388-(-887706)g=Y[x]L=U(771001+-708360)S=9245175220019-(-51614)x=d[h]r=d[V]B=r(L,S)Y=x[B]r=1042868+18085308331825 H=g[Y]J[m]=H x=U(-49871+112334)J=d[N]b=370378+10966158355752 H=d[h]g=d[V]Y=g(x,r)m=H[Y]H=d[u]J[m]=H H=U(146602+-84398)B=1027425+22580055833521 m=D[H]g=d[h]Y=d[V]r=U(568887-506573)x=Y(r,B)B=-364742+32984232234181 H=g[x]J=m[H]g=d[h]r=U(-1024908+1087260)Y=d[V]S=U(-132812+195007)x=Y(r,B)H=g[x]m=J(H)J=z()r=U(479461-417242)B=131780+15391914498363 d[J]=m m=d[J]g=d[h]Y=d[V]u3=-45020+28806923166786 x=Y(r,B)H=g[x]x=U(-609263-(-671779))Y=D[x]r=d[h]B=d[V]L=B(S,I)B=332466+-332466 x=r[L]L=283321+-283276 g=Y[x]x=-311672-(-311673)r=59133-59133 Y=g(x,r,B,L)I=6505+31388256493487 B=17346028628830-(-783407)m[H]=Y m=d[J]r=U(377375+-315037)S=U(784770+-722158)g=d[h]Y=d[V]x=Y(r,B)H=g[x]x=U(929310-866794)Y=D[x]r=d[h]B=d[V]L=B(S,I)x=r[L]r=120972-120972 g=Y[x]x=7263+-7263 B=-687899-(-687899)L=-1046122-(-1046127)Y=g(x,r,B,L)m[H]=Y m=d[J]r=U(996359-934078)B=-253376+10414428942513 S=U(-554594-(-616924))g=d[h]Y=d[V]x=Y(r,B)B=-1005323+28275360713337 H=g[x]g=-716183+716184 m[H]=g r=U(-246556-(-309047))m=d[J]g=d[h]Y=d[V]x=Y(r,B)H=g[x]L=537914+33039411119839 B=U(-604012+666349)Y=d[h]x=d[V]r=x(B,L)g=Y[r]m[H]=g B=12091601698997-(-595273)m=d[J]r=U(-83123-(-145260))g=d[h]I=14499306691151-(-16)Y=d[V]x=Y(r,B)H=g[x]x=U(73476-11063)Y=D[x]r=d[h]B=d[V]L=B(S,I)B=-544273-(-544528)x=r[L]r=-153400+153655 g=Y[x]x=802673-802418 Y=g(x,r,B)B=10921412469032-822603 m[H]=Y r=U(-798728-(-861365))m=d[J]g=d[h]Y=d[V]x=Y(r,B)I=U(-1030847+1092994)H=g[x]g=658358-658334 m[H]=g B=-978888+30806237538257 m=d[J]g=d[h]Y=d[V]r=U(317457-254815)x=Y(r,B)H=g[x]r=U(182149-119833)x=D[r]C3=U(-832325+894866)B=d[h]L=d[V]S=L(I,b)r=B[S]I=438616+10196263264564 Y=x[r]r=d[h]S=U(-608573+670719)B=d[V]L=B(S,I)x=r[L]r=U(-584396+646648)g=Y[x]m[H]=g I=U(746531-684354)m=d[J]g=d[h]B=-321374+20444366048398 Y=d[V]b=-432926+33154772440940 x=Y(r,B)H=g[x]r=U(-503160-(-565476))x=D[r]B=d[h]L=d[V]S=L(I,b)I=25288184162847-850976 r=B[S]S=U(743024+-680822)R=2616144800012-681034 Y=x[r]r=d[h]B=d[V]L=B(S,I)Q=U(-303075-(-365278))S=U(612906+-550777)x=r[L]B=12745098463409-(-560765)g=Y[x]r=U(402704+-340378)m[H]=g m=d[J]c3=U(523461+-461185)g=d[h]Y=d[V]I=23002740112020-(-880451)x=Y(r,B)H=g[x]x=U(-333302-(-395715))Y=D[x]r=d[h]B=d[V]L=B(S,I)x=r[L]g=Y[x]r=-969229-(-969229)x=371496-371396 B=901075+-900875 Y=g(x,r,B)r=U(985876+-923563)m[H]=Y m=d[J]B=703754+28934160758679 g=d[h]Y=d[V]x=Y(r,B)H=g[x]g=.3 B=16920464478599-(-118080)E=nil m[H]=g r=U(-724062-(-786364))m=d[J]g=d[h]Y=d[V]x=Y(r,B)H=g[x]L=874951+17127417972064 g=d[u]m[H]=g B=U(277985-215419)g=v(4700759-380586,{J;h;V})H=U(-835558+897904)m=D[H]H=m(g)g=U(-370937+433141)H=D[g]Y=d[h]x=d[V]r=x(B,L)B=U(578154-515796)g=Y[r]k3=52480+13078261304010 m=H[g]Y=d[h]L=35136934609715-(-834742)x=d[V]r=x(B,L)b=5164516110924-(-1005336)g=Y[r]H=m(g)m=z()d[m]=H B=U(52957-(-9545))H=d[m]I=U(764070+-701624)L=429806+10264367825853 Y=d[h]x=d[V]r=x(B,L)g=Y[r]r=U(-1010486+1073002)x=D[r]B=d[h]L=d[V]S=L(I,b)r=B[S]B=-120466-(-120446)L=-613781-(-613781)b=28349677422132-(-208221)Y=x[r]r=-600581-(-600582)S=887847+-887807 x=Y(r,B,L,S)I=U(813941+-751539)H[g]=x H=d[m]B=U(856015-793502)L=-183828+9197738811087 Y=d[h]x=d[V]r=x(B,L)g=Y[r]r=U(-331254-(-393770))x=D[r]B=d[h]L=d[V]S=L(I,b)r=B[S]L=-192691+192691 S=686229+-686174 B=977702+-977692 Y=x[r]r=659071+-659071 x=Y(r,B,L,S)H[g]=x b=-384754+6997598776236 L=-840945+27744574818152 B=U(-41392-(-103754))H=d[m]Y=d[h]x=d[V]r=x(B,L)D3=33513550689240-(-231709)g=Y[r]r=U(862307-799894)I=U(994538-932012)x=D[r]B=d[h]L=d[V]S=L(I,b)r=B[S]Y=x[r]S=25422851051627-(-597459)L=411034-410964 r=-650395-(-650435)B=-893663-(-893693)x=Y(r,B,L)H[g]=x B=U(693405+-631113)H=d[m]Y=d[h]x=d[V]b=-13718+4761104580159 L=8557220495172-323508 r=x(B,L)g=Y[r]x=d[h]r=d[V]L=U(-658802-(-721371))B=r(L,S)L=124754+24343627695349 Y=x[B]B=U(-522102+584421)H[g]=Y H=d[m]Y=d[h]I=U(540601+-478220)x=d[V]r=x(B,L)g=Y[r]r=U(-306146+368559)x=D[r]B=d[h]L=d[V]M3=144502+25195641698654 S=L(I,b)r=B[S]L=16665+-16410 Y=x[r]r=12263+-12008 B=24928+-24673 x=Y(r,B,L)L=652908438558-205550 H[g]=x H=d[m]b=U(696469-634145)B=U(369647-307115)Y=d[h]x=d[V]r=x(B,L)g=Y[r]Y=-940026-(-940042)H[g]=Y B=U(563970-501760)L=-227055+17434615649957 H=d[m]Y=d[h]x=d[V]r=x(B,L)g=Y[r]B=U(405041-342725)r=D[B]L=d[h]S=d[V]I=S(b,R)B=L[I]x=r[B]b=12744509607884-(-935778)B=d[h]I=U(977614+-915508)L=d[V]S=L(I,b)r=B[S]Y=x[r]H[g]=Y H=d[m]Y=d[h]L=31933922819546-705476 b=23733820359342-890755 B=U(-556775-(-619304))x=d[V]r=x(B,L)g=Y[r]Y=d[u]H[g]=Y Y=U(23680-(-38524))g=D[Y]x=d[h]r=d[V]S=534550+13537555230857 L=U(16664-(-45824))B=r(L,S)Y=x[B]L=U(-633567+695699)H=g[Y]S=84797+8366374913018 x=d[h]o3=26926791945222-97036 r=d[V]I=U(742668+-680078)B=r(L,S)Y=x[B]g=H(Y)Y=d[h]L=7715709195253-443885 x=d[V]B=U(454694+-392308)r=x(B,L)H=Y[r]r=U(-810191+872555)x=D[r]B=d[h]L=d[V]R=-124957+28688849771596 S=L(I,b)r=B[S]Y=x[r]B=816824-816816 r=-859094-(-859094)x=Y(r,B)g[H]=x Y=d[h]B=U(-340370+402828)L=-443276+28810741168116 x=d[V]r=x(B,L)l3=4080086089385-227134 I=5686108484677-(-169490)x=U(-912249+974453)S=U(-873597-(-936118))H=Y[r]Y=d[m]g[H]=Y Y=D[x]r=d[h]B=d[V]L=B(S,I)S=U(555911-493441)x=r[L]H=Y[x]b=U(853929-791581)r=d[h]B=d[V]I=13837631682825-991198 L=B(S,I)x=r[L]Y=H(x)L=U(626104+-563822)x=d[h]S=6371468415832-755650 r=d[V]B=r(L,S)H=x[B]B=U(917456-855043)r=D[B]L=d[h]S=d[V]I=S(b,R)B=L[I]x=r[B]L=-547787-(-547847)S=777592-777472 O={}B=1034908+-1034828 b=8323+16386132065611 a3=31518082522835-533887 r=x(B,L,S)I=U(33456+29026)S=116036+7587419932809 Y[H]=r x=d[h]r=d[V]L=U(470821+-408522)B=r(L,S)H=x[B]x=157730+-157728 Y[H]=x L=U(1048350-985785)x=d[h]S=-576512+23291932833374 r=d[V]B=r(L,S)r=U(991101-928897)H=x[B]x=d[m]Y[H]=x x=D[r]B=d[h]L=d[V]S=L(I,b)r=B[S]H=x[r]B=d[h]b=5292993650920-(-764088)I=U(503463-441152)L=d[V]S=L(I,b)r=B[S]I=U(608250+-545875)x=H(r)H=z()b=711484+1987735087201 d[H]=x x=d[H]B=d[h]L=d[V]S=L(I,b)r=B[S]S=U(97880+-35364)L=D[S]I=d[h]b=d[V]R=b(Q,D3)S=I[R]R=-413755-(-413765)Q=U(345016-282843)I=-260706+260716 b=822353+-822353 B=L[S]S=358655-358655 L=B(S,I,b,R)b=199943+5245557554307 x[r]=L x=d[H]B=d[h]I=U(-463612+526221)L=d[V]S=L(I,b)r=B[S]S=U(-623943-(-686459))L=D[S]I=d[h]P3=U(47001+15399)b=d[V]D3=12252104856559-802214 R=b(Q,D3)S=I[R]B=L[S]I=993883+-993908 S=1002253+-1002252 b=694807.5-694807 R=-268758+268753 L=B(S,I,b,R)Q=U(661531-599139)i3=8056171020914-(-117813)I=U(-129962+192385)x[r]=L x=d[H]B=d[h]L=d[V]b=-928230+3493696860224 S=L(I,b)r=B[S]S=U(-892416-(-954829))D3=14443295832479-(-549030)L=D[S]I=d[h]b=d[V]R=b(Q,D3)S=I[R]B=L[S]b=278185-278125 S=-544214+544469 I=-724509-(-724569)L=B(S,I,b)x[r]=L b=401380+5417409178102 x=d[H]D3=10600150599261-94997 B=d[h]I=U(148131-85792)L=d[V]S=L(I,b)R=21440895648765-859389 r=B[S]I=U(-199499-(-261883))b=447027+31238269462175 B=-751432-(-751432)x[r]=B x=d[H]B=d[h]L=d[V]S=L(I,b)r=B[S]B=d[m]x[r]=B B=U(1071396-1009192)b=U(411742+-349208)r=D[B]L=d[h]S=d[V]I=S(b,R)B=L[I]b=U(469328-406975)x=r[B]R=13974629173492-(-577655)L=d[h]S=d[V]I=S(b,R)B=L[I]r=x(B)b=-335760+21476749805216 I=U(-958736-(-1020899))B=d[h]L=d[V]Q=U(780805-718589)S=L(I,b)x=B[S]S=U(-935815+998179)L=D[S]I=d[h]b=d[V]R=b(Q,D3)S=I[R]B=L[S]S=621837+-621836 I=-218791-(-218791)L=B(S,I)R=U(-456716+519255)D3=-85999+34874168332126 r[x]=L B=d[h]b=590384+18735733727204 I=U(-869020+931588)L=d[V]S=L(I,b)Q=22129657756476-54012 x=B[S]L=U(-406102+468306)B=d[H]r[x]=B B=D[L]S=d[h]I=d[V]b=I(R,Q)L=S[b]Q=282653+28034765644513 x=B[L]S=d[h]I=d[V]R=U(359440-297026)b=I(R,Q)L=S[b]Q=714779+21351877738171 R=U(-654955+717167)B=x(L)x=z()d[x]=B B=d[x]S=d[h]I=d[V]b=I(R,Q)L=S[b]Q=U(-930586+993203)I=d[h]b=d[V]R=b(Q,D3)S=I[R]B[L]=S B=d[x]S=d[h]I=d[V]Q=24784316741588-805567 R=U(-974484+1037059)b=I(R,Q)L=S[b]Q=34889433491993-(-726365)S=false B[L]=S B=d[x]S=d[h]R=U(-955511+1017865)I=d[V]b=I(R,Q)L=S[b]R=U(474149-411833)b=D[R]Q=d[h]D3=d[V]U3=D3(f3,i3)f3=-363199+32500025050589 R=Q[U3]I=b[R]R=d[h]Q=d[V]U3=U(44893+17705)D3=Q(U3,f3)b=R[D3]Q=806545+23438880791569 S=I[b]R=U(282047+-219463)B[L]=S B=d[x]S=d[h]I=d[V]b=I(R,Q)D3=2092139236428-(-948098)Q=709232+1682539065503 L=S[b]S=-8509-(-18507)R=U(73262-10841)B[L]=S i3=9679559431060-(-802311)f3=U(303116-240663)B=d[x]S=d[h]I=d[V]b=I(R,Q)R=U(501804-439417)L=S[b]S=false Q=-305311+3001761558036 B[L]=S B=d[x]S=d[h]I=d[V]b=I(R,Q)L=S[b]S=W Q=U(-168554-(-230747))B[L]=S S=U(-292106-(-354310))L=D[S]I=d[h]b=d[V]R=b(Q,D3)S=I[R]B=L[S]D3=8054008091327-656409 Q=U(316059-253734)I=d[h]b=d[V]R=b(Q,D3)Q=U(166225-104102)S=I[R]L=B(S)B=z()D3=855349+31690610044016 d[B]=L L=d[B]I=d[h]b=d[V]R=b(Q,D3)S=I[R]R=U(-52406-(-114922))b=D[R]Q=d[h]D3=d[V]U3=D3(f3,i3)D3=-412394+412394 g=nil R=Q[U3]Q=398294+-398144 I=b[R]R=-372490+372490 f3=U(-810315-(-872892))U3=-663990-(-664050)b=I(R,Q,D3,U3)D3=31345938706870-(-984910)L[S]=b L=d[B]I=d[h]b=d[V]Q=U(333346-270957)R=b(Q,D3)i3=12892371809169-941086 S=I[R]R=U(371770-309254)b=D[R]Q=d[h]D3=d[V]U3=D3(f3,i3)R=Q[U3]I=b[R]U3=-340844-(-340994)R=-307785+307785 D3=-415207+415207 Q=643830+-643810 b=I(R,Q,D3,U3)L[S]=b D3=90623+14972554557757 L=d[B]Q=U(654425-591866)I=d[h]b=d[V]R=b(Q,D3)S=I[R]R=U(623129+-560716)i3=-529937+33333676020403 b=D[R]f3=U(-516186-(-578392))Q=d[h]D3=d[V]U3=D3(f3,i3)R=Q[U3]I=b[R]D3=-615967+615992 Q=-191767+191782 R=-796158+796173 b=I(R,Q,D3)L[S]=b L=d[B]Q=U(637902-575507)I=d[h]D3=453434+11221549230383 b=d[V]R=b(Q,D3)S=I[R]r=nil I=.1 Q=U(1056522-994272)L[S]=I L=d[B]J=T(J)I=d[h]D3=-767797+20218113186811 b=d[V]R=b(Q,D3)S=I[R]I=481215-481215 Q=U(-975816+1038320)L[S]=I D3=444763+10401406994832 L=d[B]I=d[h]f3=U(-146217-(-208703))b=d[V]U3=1042058+14715244573754 R=b(Q,D3)D3=U(-121518-(-183995))S=I[R]I=d[x]L[S]=I I=U(-260253+322457)S=D[I]b=d[h]R=d[V]Q=R(D3,U3)I=b[Q]L=S[I]D3=U(1588-(-60794))b=d[h]i3=10769143475295-39113 U3=873637+34661407926887 R=d[V]Q=R(D3,U3)I=b[Q]S=L(I)Q=U(248317+-185850)Y=nil I=d[h]D3=15818817470155-434693 b=d[V]R=b(Q,D3)L=I[R]R=U(824941-762448)b=D[R]Q=d[h]D3=d[V]U3=D3(f3,i3)R=Q[U3]U3=U(499000+-436531)I=b[R]D3=D[U3]f3=d[h]i3=d[V]y3=i3(P3,A3)U3=f3[y3]Q=D3[U3]U3=642232-642232 y3=U(283109-220696)i3=D[y3]P3=d[h]A3=d[V]d3=A3(c3,O3)y3=P3[d3]P3=-546019+546029 f3=i3[y3]O3=U(-283057-(-345361))d3=77845+32245892827794 A3=915113+-915063 y3=686996-686966 i3={f3(y3,P3,A3)}D3=Q(U3,i(i3))A3=U(-267787+330325)f3=U(730207-667738)U3=D[f3]i3=d[h]n3=U(419755+-357222)y3=d[V]P3=y3(A3,d3)f3=i3[P3]P3=U(657551+-595138)Q=U3[f3]f3=-70438.5-(-70439)y3=D[P3]A3=d[h]d3=d[V]c3=d3(O3,a3)P3=A3[c3]c3=13344808532597-(-482769)i3=y3[P3]P3=-705501+705551 d3=-463133+463213 A3=-411785-(-411795)y3={i3(P3,A3,d3)}U3=Q(f3,i(y3))i3=U(-847520-(-909989))d3=U(-577430-(-639647))f3=D[i3]y3=d[h]a3=U(-864326+926791)P3=d[V]A3=P3(d3,c3)i3=y3[A3]A3=U(-465904-(-528317))Q=f3[i3]P3=D[A3]i3=641753+-641752 d3=d[h]c3=d[V]O3=c3(a3,z3)A3=d3[O3]c3=1037496+-1037446 y3=P3[A3]A3=119408-119378 d3=561716-561706 P3={y3(A3,d3,c3)}f3={Q(i3,i(P3))}R={D3,U3,i(f3)}D3=-779706+24368476590605 b=I(R)S[L]=b y3=26937145588200-(-210711)I=d[h]Q=U(988803-926246)b=d[V]R=b(Q,D3)U3=U(-245756+308119)A3=24748399584082-325198 L=I[R]f3=-819499+18880975479683 I=797624+-797579 S[L]=I I=d[h]D3=502908+34696686965408 b=d[V]Q=U(263455-201119)i3=U(-738912+801161)R=b(Q,D3)L=I[R]I=d[B]b=U(601273-539069)S[L]=I I=D[b]R=d[h]Q=d[V]D3=Q(U3,f3)U3=U(757745-695649)f3=13968419025927-(-632161)b=R[D3]L=I[b]R=d[h]Q=d[V]D3=Q(U3,f3)b=R[D3]U3=570050+34401749011409 I=L(b)b=d[h]R=d[V]D3=U(279032-216698)Q=R(D3,U3)L=b[Q]Q=U(-158691+221055)R=D[Q]D3=d[h]S=nil U3=d[V]f3=U3(i3,y3)U3=-281956+11284072522218 Q=D3[f3]b=R[Q]D3=-145735-(-145747)a3=217152232502-(-582703)Q=-638398+638398 R=b(Q,D3)I[L]=R b=d[h]D3=U(-448936+511111)R=d[V]i3=22656258738637-(-335721)f3=U(-453015-(-515535))Q=R(D3,U3)L=b[Q]b=d[B]c3=-505613+5162664673393 R=U(44517+17687)I[L]=b b=D[R]Q=d[h]D3=d[V]U3=D3(f3,i3)R=Q[U3]f3=U(-26517+88660)L=b[R]Q=d[h]D3=d[V]i3=-48619+28619685622266 U3=D3(f3,i3)R=Q[U3]b=L(R)L=z()d[L]=b f3=U(-311450-(-373655))b=d[L]Q=d[h]d3=-978578+14436867360980 i3=14285833621089-128101 D3=d[V]U3=D3(f3,i3)R=Q[U3]U3=U(89784-27371)D3=D[U3]f3=d[h]i3=d[V]P3=U(140172+-77793)y3=i3(P3,A3)U3=f3[y3]Q=D3[U3]f3=93713-93713 U3=-375068+375168 y3=-978708+34905993850514 i3=-881109-(-881309)D3=Q(U3,f3,i3)i3=1489321725016-821667 b[R]=D3 f3=U(-366571+429026)b=d[L]Q=d[h]D3=d[V]U3=D3(f3,i3)f3=U(674450+-612252)R=Q[U3]Q=431979-431977 b[R]=Q i3=10792072944059-640538 b=d[L]Q=d[h]D3=d[V]U3=D3(f3,i3)R=Q[U3]Q=d[B]i3=U(-311826+374266)b[R]=Q R=U(20319+42027)b=D[R]Q=l(3792787-981574,{N;h;V;L})R=b(Q)Q=U(-113258-(-175462))R=D[Q]D3=d[h]O3=22778141013509-(-78697)U3=d[V]f3=U3(i3,y3)Q=D3[f3]i3=U(-825935+888071)b=R[Q]D3=d[h]y3=-45343+34434254516161 U3=d[V]f3=U3(i3,y3)i3=U(-379720+442299)Q=D3[f3]R=b(Q)b=z()d[b]=R A3=U(154173-91991)R=d[b]y3=730726+6201598616801 D3=d[h]U3=d[V]f3=U3(i3,y3)Q=D3[f3]f3=U(111431+-48915)U3=D[f3]i3=d[h]y3=d[V]P3=y3(A3,d3)f3=i3[P3]P3=-9711-(-9731)y3=-121334+121334 D3=U3[f3]f3=-840105-(-840106)i3=958240+-958240 U3=D3(f3,i3,y3,P3)R[Q]=U3 i3=U(-284307+346474)R=d[b]y3=33911290925010-(-257501)D3=d[h]U3=d[V]A3=U(761153-699002)f3=U3(i3,y3)Q=D3[f3]f3=U(407478+-344962)U3=D[f3]i3=d[h]y3=d[V]d3=643802+22020415739188 P3=y3(A3,d3)f3=i3[P3]D3=U3[f3]i3=-730318+730318 P3=-47194+47199 y3=-254839+254839 f3=-921191+921191 U3=D3(f3,i3,y3,P3)y3=25206010602251-783666 R[Q]=U3 R=d[b]D3=d[h]U3=d[V]P3=703616+16629490360767 i3=U(883066+-820845)f3=U3(i3,y3)Q=D3[f3]D3=-1009882+1009883 A3=U(-549330+611941)R[Q]=D3 R=d[b]D3=d[h]U3=d[V]y3=840148+19644849721831 i3=U(802893+-740723)f3=U3(i3,y3)d3=15978560178103-(-283993)Q=D3[f3]U3=d[h]f3=d[V]y3=U(657773+-595218)i3=f3(y3,P3)D3=U3[i3]R[Q]=D3 R=d[b]y3=602384+22267530016625 D3=d[h]U3=d[V]i3=U(636597-574179)f3=U3(i3,y3)Q=D3[f3]f3=U(-501649+564062)U3=D[f3]i3=d[h]y3=d[V]P3=y3(A3,d3)f3=i3[P3]i3=-235868-(-236123)D3=U3[f3]y3=-789281+789536 f3=-688856+689111 U3=D3(f3,i3,y3)R[Q]=U3 R=d[b]D3=d[h]U3=d[V]i3=U(-232203-(-294496))y3=29974299309224-(-770525)f3=U3(i3,y3)Q=D3[f3]D3=736436-736422 R[Q]=D3 R=d[b]D3=d[h]y3=-572629+6274337605694 U3=d[V]i3=U(-434213+496833)f3=U3(i3,y3)Q=D3[f3]i3=U(441464+-379148)f3=D[i3]y3=d[h]d3=U(838829-776646)P3=d[V]A3=P3(d3,c3)d3=-102301+29486615545151 i3=y3[A3]U3=f3[i3]i3=d[h]y3=d[V]A3=U(533802+-471351)P3=y3(A3,d3)f3=i3[P3]i3=U(357663+-295191)d3=U(-276426-(-339060))D3=U3[f3]c3=19131083436803-(-389065)R[Q]=D3 R=d[b]y3=25155310948132-(-745117)D3=d[h]U3=d[V]f3=U3(i3,y3)Q=D3[f3]i3=U(-699990+762306)f3=D[i3]y3=d[h]P3=d[V]A3=P3(d3,c3)i3=y3[A3]A3=U(497382-435280)U3=f3[i3]i3=d[h]y3=d[V]d3=28703993391197-455719 P3=y3(A3,d3)A3=U(1000508-938118)y3=-292430+16908085679375 f3=i3[P3]q3=29489924174681-802229 D3=U3[f3]R[Q]=D3 P3=817566+30415155264949 i3=U(226209-164033)R=d[b]D3=d[h]U3=d[V]f3=U3(i3,y3)Q=D3[f3]D3=d[B]d3=9516617233146-(-237141)y3=U(342293+-279697)R[Q]=D3 D3=U(-585242+647446)Q=D[D3]U3=d[h]f3=d[V]i3=f3(y3,P3)D3=U3[i3]P3=20167+16175879884453 R=Q[D3]y3=U(1061980-999824)U3=d[h]f3=d[V]i3=f3(y3,P3)N=T(N)D3=U3[i3]Q=R(D3)D3=d[h]y3=10343398323314-(-548446)U3=d[V]i3=U(602134-539864)f3=U3(i3,y3)R=D3[f3]f3=U(716730+-654214)U3=D[f3]i3=d[h]y3=d[V]P3=y3(A3,d3)f3=i3[P3]D3=U3[f3]i3=-978572-(-978572)Z=T(Z)f3=.3 P3=80052-80027 y3=102499+-102499 U3=D3(f3,i3,y3,P3)i3=U(1041629+-979133)Q[R]=U3 y3=5739907291026-216354 D3=d[h]U3=d[V]f3=U3(i3,y3)R=D3[f3]f3=U(960164+-897648)A3=U(-780894-(-843454))d3=11832719429672-(-345438)U3=D[f3]i3=d[h]y3=d[V]P3=y3(A3,d3)f3=i3[P3]D3=U3[f3]i3=-214381+214381 A3=U(353196+-290965)f3=.1 P3=-752571-(-752601)y3=-342631+342631 U3=D3(f3,i3,y3,P3)d3=-623896+4983495101992 Q[R]=U3 y3=415055+20308689358753 D3=d[h]U3=d[V]i3=U(146839-84252)f3=U3(i3,y3)R=D3[f3]f3=U(-576147+638560)U3=D[f3]i3=d[h]y3=d[V]P3=y3(A3,d3)f3=i3[P3]P3=8808761821084-964503 D3=U3[f3]f3=597314+-597114 i3=-16300-(-16360)y3=-230123+230183 U3=D3(f3,i3,y3)y3=9483608535355-253947 Q[R]=U3 D3=d[h]i3=U(-666992-(-729589))U3=d[V]f3=U3(i3,y3)A3=U(966824+-904383)R=D3[f3]U3=d[h]y3=U(-634400+696581)f3=d[V]i3=f3(y3,P3)D3=U3[i3]Q[R]=D3 D3=d[h]i3=U(517624-455341)U3=d[V]y3=19199636349157-(-180743)d3=5283800079165-(-110175)f3=U3(i3,y3)R=D3[f3]f3=U(46879+15534)U3=D[f3]i3=d[h]y3=d[V]P3=y3(A3,d3)f3=i3[P3]i3=185567-185312 y3=-806515+806770 D3=U3[f3]f3=553474+-553219 U3=D3(f3,i3,y3)Q[R]=U3 D3=d[h]U3=d[V]i3=U(-337151-(-399414))y3=8530381114776-(-508396)f3=U3(i3,y3)R=D3[f3]d3=U(778544-716083)i3=U(-324511-(-386738))y3=-573590+18449519485477 D3=598706-598688 Q[R]=D3 D3=d[h]U3=d[V]f3=U3(i3,y3)i3=U(109543+-47227)R=D3[f3]f3=D[i3]c3=11485399992550-455682 y3=d[h]P3=d[V]A3=P3(d3,c3)i3=y3[A3]d3=-774591+22967248780165 U3=f3[i3]A3=U(-573254+635497)i3=d[h]c3=14950933846202-(-1032824)y3=d[V]P3=y3(A3,d3)f3=i3[P3]D3=U3[f3]Q[R]=D3 D3=d[h]U3=d[V]i3=U(318667-256545)A3=-249154+33505816169012 y3=-669975+17176438659157 f3=U3(i3,y3)R=D3[f3]D3=d[B]P3=U(-604891+667201)U3=U(-209358+271562)d3=U(-269234+331452)Q[R]=D3 D3=D[U3]f3=d[h]i3=d[V]y3=i3(P3,A3)U3=f3[y3]P3=U(-436460-(-498916))R=D3[U3]f3=d[h]i3=d[V]A3=12988886484660-749332 y3=i3(P3,A3)U3=f3[y3]D3=R(U3)P3=1636916728454-282508 U3=d[h]y3=U(-198345-(-260908))f3=d[V]i3=f3(y3,P3)R=U3[i3]i3=U(136952+-74588)f3=D[i3]y3=d[h]P3=d[V]A3=P3(d3,c3)i3=y3[A3]y3=601485+-601479 U3=f3[i3]c3=U(295978-233816)i3=-519726+519726 f3=U3(i3,y3)d3=-173880+17615477081922 D3[R]=f3 P3=-528150+72044777271 U3=d[h]A3=U(-1036186+1098579)f3=d[V]y3=U(805828+-743331)i3=f3(y3,P3)R=U3[i3]U3=Q f3=U(-885293-(-947497))I=nil D3[R]=U3 U3=D[f3]i3=d[h]y3=d[V]P3=y3(A3,d3)f3=i3[P3]R=U3[f3]i3=d[h]A3=U(-956204-(-1018442))y3=d[V]d3=9740862949213-79270 P3=y3(A3,d3)f3=i3[P3]U3=R(f3)P3=U(503746+-441651)A3=669429+6346380612758 f3=d[h]i3=d[V]y3=i3(P3,A3)R=f3[y3]y3=U(944788-882272)i3=D[y3]P3=d[h]A3=d[V]d3=A3(c3,O3)y3=P3[d3]d3=902383+-902358 f3=i3[y3]y3=.3 A3=-189561-(-189561)P3=834185+-834185 i3=f3(y3,P3,A3,d3)U3[R]=i3 f3=d[h]i3=d[V]P3=U(417589+-354967)A3=-96512+4043106304090 y3=i3(P3,A3)O3=-718806+31501693694243 R=f3[y3]y3=U(234498-171982)c3=U(-696680-(-759205))i3=D[y3]P3=d[h]A3=d[V]d3=A3(c3,O3)A3=-669191-(-669191)y3=P3[d3]f3=i3[y3]d3=332030-332000 P3=477822-477822 y3=.6 i3=f3(y3,P3,A3,d3)U3[R]=i3 A3=6724852283920-(-528939)P3=U(267376-205076)f3=d[h]i3=d[V]y3=i3(P3,A3)O3=-633503+32747099776560 R=f3[y3]c3=U(147709+-85619)y3=U(390320-327907)i3=D[y3]P3=d[h]A3=d[V]d3=A3(c3,O3)A3=1043880-1043820 y3=P3[d3]P3=407758-407558 f3=i3[y3]y3=922361-922301 i3=f3(y3,P3,A3)U3[R]=i3 c3=U(-223945+286076)d3=1955637114251-324093 A3=-122468+13225406396018 f3=d[h]P3=U(111707-49398)i3=d[V]y3=i3(P3,A3)A3=U(99619+-37284)R=f3[y3]i3=d[h]y3=d[V]P3=y3(A3,d3)f3=i3[P3]U3[R]=f3 P3=U(192885-130481)A3=-316867+13738607275712 f3=d[h]i3=d[V]y3=i3(P3,A3)O3=112083+23568805033228 R=f3[y3]y3=U(130775+-68362)i3=D[y3]P3=d[h]A3=d[V]d3=A3(c3,O3)y3=P3[d3]P3=865374+-865119 f3=i3[y3]A3=-37550+37805 y3=382405+-382150 i3=f3(y3,P3,A3)A3=11472254049632-(-227198)U3[R]=i3 f3=d[h]i3=d[V]P3=U(-972498+1034907)y3=i3(P3,A3)R=f3[y3]P3=U(-366800+428939)f3=779034+-779016 A3=19478513167479-(-866039)U3[R]=f3 f3=d[h]i3=d[V]O3=U(289064+-226785)y3=i3(P3,A3)P3=U(108712-46396)R=f3[y3]y3=D[P3]A3=d[h]d3=d[V]c3=d3(O3,a3)P3=A3[c3]i3=y3[P3]P3=d[h]A3=d[V]c3=U(2237-(-60351))O3=31780943930751-(-119888)d3=A3(c3,O3)y3=P3[d3]f3=i3[y3]P3=U(690169-628055)U3[R]=f3 O3=U(197310-135082)f3=d[h]a3=-87135+14984561389472 i3=d[V]A3=-536462+24462009048077 d3=U(859486+-796903)y3=i3(P3,A3)c3=9700761785944-672947 R=f3[y3]f3=d[B]U3[R]=f3 i3=U(801418+-739214)f3=D[i3]y3=d[h]P3=d[V]A3=P3(d3,c3)i3=y3[A3]R=f3[i3]y3=d[h]d3=U(18543-(-43848))P3=d[V]c3=5405333741164-939159 A3=P3(d3,c3)i3=y3[A3]f3=R(i3)i3=d[h]A3=U(761089-698720)y3=d[V]d3=8477273513388-577089 P3=y3(A3,d3)R=i3[P3]P3=U(-672239+734603)y3=D[P3]A3=d[h]d3=d[V]c3=d3(O3,a3)P3=A3[c3]i3=y3[P3]A3=-968643+968649 P3=-208541+208541 y3=i3(P3,A3)A3=U(964150+-901639)d3=-444501+13935714869678 f3[R]=y3 i3=d[h]y3=d[V]P3=y3(A3,d3)R=i3[P3]i3=U3 O3=U(502018-439502)P3=z()y3=z()f3[R]=i3 R=false i3=z()d3=z()d[i3]=R R=-569925-(-569926)d[y3]=R R={}d[P3]=R A3=z()R={}d[A3]=R R={}d[d3]=R c3=D[O3]a3=d[h]z3=d[V]h3=z3(V3,o3)O3=a3[h3]z3=693570-693570 R=c3[O3]O3=902196+-902196 a3=-427046-(-427046)h3=-513817+513947 c3=R(O3,a3,z3,h3)R=z()O3=M(14010608-(-447841),{F;h,V})d[R]=c3 c3=z()d[c3]=O3 a3=M(311970+13669437,{i3,m;h,V;H,x;K,F;A3,c3;o,P3,y3,d3})O3=z()d[O3]=a3 z3=C(-995726+10946320,{i3;m,h;V,H,x;A3,P3;d3})h3=M(-21617+11630107,{A3;h,V;y3})a3=z()d[a3]=z3 z3=z()d[z3]=h3 V3=d[m]A3=T(A3)T3=d[h]K3=d[V]t3=K3(C3,M3)o3=T3[t3]t3=U(822499+-759908)C3=-812123+793686943180 h3=V3[o3]V3=U(909924+-847744)V3=h3[V3]o3=C(183674-(-658007),{i3;a3;O3})V3=V3(h3,o3)o3=d[h]T3=d[V]K3=T3(t3,C3)V3=o3[K3]t3=U(-777965+840159)o3=t(-774354+6425976,{y3;b;h,V;i3;z3})h3=Q[V3]L=T(L)V3=U(120182-58002)C3=37315+16997910072616 V3=h3[V3]V3=V3(h3,o3)K=T(K)o3=d[h]T3=d[V]K3=T3(t3,C3)t3=U(-815983+878396)V3=o3[K3]d3=T(d3)c3=T(c3)o3=n(4530167-(-139448),{y3;b;h,V;i3;z3})h3=U3[V3]V3=U(-458121-(-520301))V3=h3[V3]V3=V3(h3,o3)o3=d[m]h3=C(-943191+2417757,{h;V,k})K3=D[t3]C3=d[h]x=T(x)M3=d[V]v3=M3(n3,l3)M3=-1035477+1035547 t3=C3[v3]z3=T(z3)C3=-388963-(-388993)T3=K3[t3]t3=-869306-(-869346)K3=T3(t3,C3,M3)k=T(k)C3=U(-902663-(-965076))t3=D[C3]M3=d[h]l3=U(1068376-1006010)v3=d[V]n3=v3(l3,q3)C3=M3[n3]T3=t3[C3]C3=914978+-914918 v3=-306760-(-306860)M3=689981-689941 t3={T3(C3,M3,v3)}n3=11586760874885-722546 V3=h3(o3,K3,i(t3))l3=18461381785867-(-649353)K3=U(318926+-256513)T3=D[K3]t3=d[h]v3=U(-767887+830264)C3=d[V]M3=C3(v3,n3)P3=T(P3)K3=t3[M3]t3=-481643+481703 o3=T3[K3]C3=338022-337962 K3=481913+-481713 T3=o3(K3,t3,C3)W=nil n3=U(-715461-(-777932))t3=U(485860+-423447)K3=D[t3]y3=T(y3)C3=d[h]M3=d[V]m=T(m)v3=M3(n3,l3)t3=C3[v3]o3=K3[t3]C3=220895+-220815 M3=127171-127091 t3=-919646+919866 K3={o3(t3,C3,M3)}V3=h3(Q,T3,i(K3))v3=U(-598315+660470)K3=U(-938069-(-1000482))n3=30589769490082-730878 H=T(H)T3=D[K3]f3=nil t3=d[h]C3=d[V]M3=C3(v3,n3)K3=t3[M3]q3=U(-525581+587926)t3=-39239+39439 n3=U(533715+-471201)o3=T3[K3]C3=788478-788418 K3=101905-101845 l3=29303458642327-853066 T3=o3(K3,t3,C3)t3=U(840736+-778323)o=T(o)K3=D[t3]C3=d[h]M3=d[V]v3=M3(n3,l3)t3=C3[v3]o3=K3[t3]C3=771788+-771568 t3=970946-970866 M3=900204+-900124 K3={o3(t3,C3,M3)}V3=h3(U3,T3,i(K3))V3=false K3=nil T3=nil o3=z()t3=z()d[o3]=V3 V3=nil d[t3]=V3 V3=z()d[V3]=T3 T3=z()d[T3]=K3 C3=d[u]v3=d[h]n3=d[V]l3=n3(q3,u3)u3=628018+33560618805209 M3=v3[l3]K3=C3[M3]h3=nil M3=C(-5956+14448422,{h;V;o3,V3;u,T3})C3=U(889126-826946)C3=K3[C3]C3=C3(K3,M3)C3=d[u]v3=d[h]b=T(b)n3=d[V]p=nil q3=U(34692+27884)l3=n3(q3,u3)M3=v3[l3]K3=C3[M3]M3=C(548942+8377571,{h;V;t3})C3=U(704366+-642186)C3=K3[C3]C3=C3(K3,M3)M3=U(116469+-53916)U3=nil C3=D[M3]n3=d[h]l3=d[V]M3=U(-270814-(-333047))M3=C3[M3]u3=U(-1008477+1071062)q3=l3(u3,k3)v3=n3[q3]M3=M3(C3,v3)v3=d[h]n3=d[V]Q=nil u3=20913722009022-376756 q3=U(-98696-(-161055))l3=n3(q3,u3)C3=v3[l3]K3=M3[C3]M3=q(1519829-(-885608),{t3,o3,h;V,V3;T3;u;B;R})B=T(B)u3=10390390946994-764364 C3=U(542229-480049)C3=K3[C3]C3=C3(K3,M3)C3=d[F]v3=d[h]q3=U(-833472-(-895758))n3=d[V]l3=n3(q3,u3)M3=v3[l3]V3=T(V3)V=T(V)K3=C3[M3]M3=C(14392142-309025,{i3,a3;O3})C3=U(981095+-918915)o3=T(o3)C3=K3[C3]u=T(u)O3=T(O3)C3=C3(K3,M3)C3=U(-270298-(-332644))f=D[U(-656278-(-718464))]D3=nil K3=D[C3]h=T(h)T3=T(T3)t3=T(t3)M3=l(-719351+13792200,{i3})F=T(F)i3=T(i3)a3=T(a3)R=T(R)C3=K3(M3)end else f=D[U(-590911+653189)]o=U(-740458+802716)V=D[o]o=U(-207872+270389)a=V[o]o=d[A[-365922+365923]]V={a(o)}O={i(V)}end end end end end end end end f=#y return i(O)end,function(D,U)local i=o(U)local P=function(P,A,y,c)return f(D,{P;A;y,c},U,i)end return P end,function(D,U)local i=o(U)local P=function(P,A)return f(D,{P,A},U,i)end return P end,function(D)a[D]=a[D]-(-523182+523183)if a[D]==1003997+-1003997 then a[D],d[D]=nil,nil end end,function()V=V+(343644+-343643)a[V]=-417956+417957 return V end,function(D,U)local i=o(U)local P=function(P)return f(D,{P},U,i)end return P end,function(D,U)local i=o(U)local P=function()return f(D,{},U,i)end return P end,{},-682224+682224,function(D,U)local i=o(U)local P=function(...)return f(D,{...},U,i)end return P end,function(D,U)local i=o(U)local P=function(P,A,y,c,O)return f(D,{P,A;y;c;O},U,i)end return P end,function(D)for U=-628035-(-628036),#D,925398-925397 do a[D[U]]=a[D[U]]+(-233253+233254)end if P then local f=P(true)local i=y(f)i[U(493380+-430882)],i[U(672042+-609762)],i[U(1025215-963100)]=D,h,function()return-1578573-(-1038241)end return f else return A({},{[U(-718593+780873)]=h,[U(628862-566364)]=D,[U(935646+-873531)]=function()return-126540+-413792 end})end end,function(D)local U,f=271667+-271666,D[-324896-(-324897)]while f do a[f],U=a[f]-(-385404-(-385405)),(-576764-(-576765))+U if 638803+-638803==a[f]then a[f],d[f]=nil,nil end f=D[U]end end,function(D,U)local i=o(U)local P=function(P,A,y,c,O,d)return f(D,{P;A;y,c,O,d},U,i)end return P end,function(D,U)local i=o(U)local P=function(P,A,y)return f(D,{P;A,y},U,i)end return P end return(K(11704484-871831,{}))(i(O))end)(getfenv and getfenv()or _ENV,unpack or table[U(430662+-368430)],newproxy,setmetatable,getmetatable,select,{...})end)(...)
]=====]
