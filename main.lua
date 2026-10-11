-- ========================================================
-- ⚡ ADAM & YASEEN CONTROLLER - ULTIMATE CORE ⚡
-- ========================================================

local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")

---------------------------------------------------------
-- ⚙️ لوحة التحكم في الصيانة (من هنا بتقفل وتفتح):
-- true  = السكريبت شغال وطبيعي عند الكل
-- false = السكريبت مقفول صيانة (يمنع التشغيل ويحذف الواجهات)
local ScriptEnabled = true  
---------------------------------------------------------

-- دالة إشعار الصيانة
local function showMaintenanceNotice()
	pcall(function()
		StarterGui:SetCore("SendNotification", {
			Title = "تنبيه صيانة",
			Text = "نعتذر يوجد صيانة من المطور آدم",
			Duration = 6
		})
	end)
end

-- فحص الحالة فوراً قبل تحميل أي حاجة
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

-- Global States & Variables
local CurrentLang = "AR"
local SpeedEnabled = false
local NoclipEnabled = false
local FlyEnabled = false
local PlatformEnabled = false
local InstantInteractEnabled = false
local ESPEnabled = false
local MM2ESPEnabled = false
local MultiJumpEnabled = false
local ArhangelsTeamEnabled = false
local HitboxSizeVal = 4

local WalkSpeedVal = 50
local FlySpeedVal = 50

local FollowPlatformPart = nil
local BodyVelocity = nil
local BodyGyro = nil
local Connections = {}
local HighlightsTable = {}
local MM2HighlightsTable = {}

-- Server Hop Variables
local AutoHopEnabled = false
local HopThreshold = 1

-- Country Name Translation Dictionary
local CountryNamesAR = {
	["EG"] = "مصر",
	["SA"] = "المملكة العربية السعودية",
	["AE"] = "الإمارات العربية المتحدة",
	["KW"] = "الكويت",
	["QA"] = "قطر",
	["BH"] = "البحرين",
	["OM"] = "سلطنة عمان",
	["JO"] = "الأردن",
	["IQ"] = "العراق",
	["LB"] = "لبنان",
	["SY"] = "سوريا",
	["MA"] = "المغرب",
	["DZ"] = "الجزائر",
	["TN"] = "تونس",
	["LY"] = "ليبيا",
	["SD"] = "السودان",
	["YE"] = "اليمن",
	["US"] = "الولايات المتحدة الأمريكية",
	["GB"] = "المملكة المتحدة",
	["FR"] = "فرنسا",
	["DE"] = "ألمانيا",
	["TR"] = "تركيا"
}

-- UI References
local TitleLabel, LangBtnRef, SpeedBtnRef, FlyBtnRef, PlatformBtnRef
local TeleportBtnRef, TeleportInputRef, ServerHopPanelBtnRef
local CountryLabelRef, FooterLabelRef
local ArhangelsBtnRef, HitboxLabelRef
local ServerHopFrame, ServerHopCloseBtn, ServerHopInfoLabel, ServerHopInput, HopOnceBtn, AutoHopBtn

-- Translations Setup
local Translations = {
	EN = {
		Title = "⚡ ADAM & YASEEN CONTROLLER ⚡",
		SpeedText = "Walk Speed",
		FlyText = "Flight Matrix",
		NoclipText = "Noclip",
		PlatformText = "Quantum Platform",
		InstantInteractText = "Instant Interact",
		ESPText = "Player ESP",
		MM2ESPText = "MM2 Role Reveal",
		MultiJumpText = "Multi-Jump",
		ArhangelsText = "ARHANGELS TEAM",
		HitboxText = "Hitbox Size",
		TeleportBtn = "Teleport",
		TeleportPlaceholder = "Player Name...",
		ServerHopBtn = "Server Hop System",
		Country = "Region: ",
		CountryLoading = "Region: Syncing...",
		CountryUnknown = "Region: Restricted",
		Footer = "Left Ctrl: Hide UI",
		ON = "ON",
		OFF = "OFF",
		LangBtn = "AR"
	},
	AR = {
		Title = "⚡ سكربت ادم وياسين ⚡",
		SpeedText = "سرعة المشي",
		FlyText = "الطيران الحر",
		NoclipText = "اختراق الجدران",
		PlatformText = "منصة الارتكاز",
		InstantInteractText = "التفاعل الفوري",
		ESPText = "كشف اللاعبين",
		MM2ESPText = "كشف أدوار MM2 🔪",
		MultiJumpText = "القفز المتعدد",
		ArhangelsText = "ARHANGELS TEAM",
		HitboxText = "Hitbox Size",
		TeleportBtn = "انتقال 🚀",
		TeleportPlaceholder = "اكتب اسم اللاعب...",
		ServerHopBtn = "نظام تبديل السيرفرات",
		Country = "الموقع: ",
		CountryLoading = "الموقع: جاري التحميل...",
		CountryUnknown = "الموقع: غير متوفر",
		Footer = "Left Ctrl: إخفاء الواجهة",
		ON = "ON",
		OFF = "OFF",
		LangBtn = "EN"
	}
}

-- Startup Sound Effect
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

-- Create Screen GUI Safely
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
if PlayerGui:FindFirstChild("Legendary_Core_UI") then
	PlayerGui["Legendary_Core_UI"]:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Legendary_Core_UI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

---------------------------------------------------------
-- 📱💻 نافذة اختيار الجهاز أولاً (ولا يظهر زر ADAM أبداً قبلها)
---------------------------------------------------------
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
SelectorStroke.Thickness = 2
SelectorStroke.Color = Color3.fromRGB(0, 255, 180)
SelectorStroke.Parent = SelectorGui

local SelectorTitle = Instance.new("TextLabel")
SelectorTitle.Size = UDim2.new(1, 0, 0, 50)
SelectorTitle.BackgroundTransparency = 1
SelectorTitle.Text = "اختر نوع جهازك للتشغيل أولاً 🎮"
SelectorTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
SelectorTitle.TextSize = 15
SelectorTitle.Font = Enum.Font.GothamBold
SelectorTitle.Parent = SelectorGui

-- زر الكمبيوتر في القائمة الأولى
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

-- زر الهاتف في القائمة الأولى
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

---------------------------------------------------------
-- إعداد اللوحة الرئيسية (مخفية تماماً في البداية)
---------------------------------------------------------
local BaseWidth, BaseHeight = 310, 830

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
MainStroke.Thickness = 2
MainStroke.Color = Color3.fromRGB(0, 255, 180)
MainStroke.Parent = MainFrame

local GradientStroke = Instance.new("UIGradient")
GradientStroke.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 170)),
	ColorSequenceKeypoint.new(0.5, Color3.fromRGB(100, 100, 255)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 210, 255))
})
GradientStroke.Parent = MainStroke

---------------------------------------------------------
-- زر ADAM العائم (يبدأ مخفي تماماً ولن يظهر إلا بعد اختيار الجهاز)
---------------------------------------------------------
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Name = "Legendary_ToggleBtn"
ToggleBtn.Size = UDim2.new(0, 140, 0, 45)
ToggleBtn.Position = UDim2.new(0.02, 0, 0.2, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(15, 20, 30)
ToggleBtn.BackgroundTransparency = 0.15
ToggleBtn.Text = ""
ToggleBtn.Active = true
ToggleBtn.Draggable = true
ToggleBtn.Visible = false -- مخفي في البداية
ToggleBtn.Parent = ScreenGui

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 22)
ToggleCorner.Parent = ToggleBtn

local ToggleStroke = Instance.new("UIStroke")
ToggleStroke.Thickness = 2.5
ToggleStroke.Color = Color3.fromRGB(0, 255, 170)
ToggleStroke.Parent = ToggleBtn

local ToggleGradient = Instance.new("UIGradient")
ToggleGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 170)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 150, 255))
})
ToggleGradient.Parent = ToggleStroke

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

---------------------------------------------------------
-- تفعيل الأحداث بعد اختيار نوع الجهاز
---------------------------------------------------------
-- عند اختيار الكمبيوتر
PCBtn.MouseButton1Click:Connect(function()
	SelectorGui:Destroy()
	BaseWidth, BaseHeight = 310, 830
	MainFrame.Size = UDim2.new(0, BaseWidth, 0, BaseHeight)
	MainFrame.Visible = true
	ToggleBtn.Visible = true -- إظهار زر آدم العائم
end)

-- عند اختيار الهاتف (تصغير مقاس اللوحة لتناسب الشاشة الصغيرة)
MobileBtn.MouseButton1Click:Connect(function()
	SelectorGui:Destroy()
	BaseWidth, BaseHeight = 265, 740
	MainFrame.Size = UDim2.new(0, BaseWidth, 0, BaseHeight)
	MainFrame.Visible = true
	ToggleBtn.Visible = true -- إظهار زر آدم العائم
end)
---------------------------------------------------------

-- Title Header Frame
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
TitleLabel.TextColor3 = Color3.fromRGB(0, 255, 170)
TitleLabel.TextSize = 11
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TitleFrame

-- Language Switcher Button
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

-- Close Button
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

-- Safe Cleanup / Reset Function
local function CleanScript()
	SpeedEnabled = false
	NoclipEnabled = false
	FlyEnabled = false
	PlatformEnabled = false
	InstantInteractEnabled = false
	ESPEnabled = false
	MM2ESPEnabled = false
	MultiJumpEnabled = false
	ArhangelsTeamEnabled = false
	AutoHopEnabled = false
	
	for _, player in pairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character then
			local hrp = player.Character:FindFirstChild("HumanoidRootPart")
			if hrp then
				hrp.Size = Vector3.new(2, 2, 1)
				hrp.Transparency = 1
				hrp.CanCollide = true
			end
		end
	end
	
	if BodyVelocity then BodyVelocity:Destroy() BodyVelocity = nil end
	if BodyGyro then BodyGyro:Destroy() BodyGyro = nil end
	if FollowPlatformPart then FollowPlatformPart:Destroy() FollowPlatformPart = nil end

	for _, highlight in pairs(HighlightsTable) do if highlight then highlight:Destroy() end end
	HighlightsTable = {}
	for _, highlight in pairs(MM2HighlightsTable) do if highlight then highlight:Destroy() end end
	MM2HighlightsTable = {}

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

-- حلقة مراقبة صيانة داخلية
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
local updateSpeedUI, updateFlyUI, updateArhangelsUI

LangBtnRef.MouseButton1Click:Connect(function()
	CurrentLang = (CurrentLang == "AR") and "EN" or "AR"
	LangBtnRef.Text = Translations[CurrentLang].LangBtn
	TitleLabel.Text = Translations[CurrentLang].Title
	TeleportInputRef.PlaceholderText = Translations[CurrentLang].TeleportPlaceholder
	TeleportBtnRef.Text = Translations[CurrentLang].TeleportBtn
	ServerHopPanelBtnRef.Text = Translations[CurrentLang].ServerHopBtn
	FooterLabelRef.Text = Translations[CurrentLang].Footer
	
	for _, updater in ipairs(UIUpdaters) do
		pcall(updater)
	end
end)

---------------------------------------------------------
-- UI CONTROLS (الأزرار والوظائف الأساسية)
---------------------------------------------------------

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

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.F then
		updatePlatformState(not PlatformEnabled)
	end
end)

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
local function applyESPToCharacter(player, char)
	if not ESPEnabled or not char then return end
	local existing = char:FindFirstChild("Player_ESP")
	if existing then existing:Destroy() end
	local hl = Instance.new("Highlight")
	hl.Name = "Player_ESP"
	hl.Adornee = char
	hl.FillColor = Color3.fromRGB(255, 45, 45)
	hl.FillTransparency = 0.5
	hl.OutlineColor = Color3.fromRGB(255, 255, 255)
	hl.OutlineTransparency = 0
	hl.Parent = char
	HighlightsTable[player] = hl
end

createSimpleToggle(264, Translations.AR.ESPText, Translations.EN.ESPText, function(enabled)
	ESPEnabled = enabled
	for _, player in pairs(Players:GetPlayers()) do
		if player ~= LocalPlayer then
			if ESPEnabled and player.Character then applyESPToCharacter(player, player.Character)
			else
				if HighlightsTable[player] then HighlightsTable[player]:Destroy() HighlightsTable[player] = nil end
			end
		end
	end
end)

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
			if char and char:FindFirstChild("HumanoidRootPart") then
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
					MM2HighlightsTable[player]:Destroy()
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

-- 9. ARHANGELS TEAM Button (Y: 384)
ArhangelsBtnRef = Instance.new("TextButton")
ArhangelsBtnRef.Size = UDim2.new(0.9, 0, 0, 32)
ArhangelsBtnRef.Position = UDim2.new(0.05, 0, 0, 384)
ArhangelsBtnRef.BackgroundColor3 = Color3.fromRGB(180, 45, 45)
ArhangelsBtnRef.BackgroundTransparency = 0.35
ArhangelsBtnRef.TextColor3 = Color3.fromRGB(255, 255, 255)
ArhangelsBtnRef.TextSize = 10
ArhangelsBtnRef.Font = Enum.Font.GothamSemibold
ArhangelsBtnRef.Parent = MainFrame

local ArhangelsCorner = Instance.new("UICorner")
ArhangelsCorner.CornerRadius = UDim.new(0, 6)
ArhangelsCorner.Parent = ArhangelsBtnRef

updateArhangelsUI = function()
	local lang = Translations[CurrentLang]
	local status = ArhangelsTeamEnabled and lang.ON or lang.OFF
	ArhangelsBtnRef.Text = "ARHANGELS TEAM: " .. status
	ArhangelsBtnRef.BackgroundColor3 = ArhangelsTeamEnabled and Color3.fromRGB(0, 180, 110) or Color3.fromRGB(180, 45, 45)
	ArhangelsBtnRef.BackgroundTransparency = 0.35
end
table.insert(UIUpdaters, updateArhangelsUI)

ArhangelsBtnRef.MouseButton1Click:Connect(function()
	ArhangelsTeamEnabled = not ArhangelsTeamEnabled
	updateArhangelsUI()
	
	if not ArhangelsTeamEnabled then
		for _, player in pairs(Players:GetPlayers()) do
			if player ~= LocalPlayer and player.Character then
				local hrp = player.Character:FindFirstChild("HumanoidRootPart")
				if hrp then
					hrp.Size = Vector3.new(2, 2, 1)
					hrp.Transparency = 1
					hrp.CanCollide = true
				end
			end
		end
	end
end)
updateArhangelsUI()

-- 10. Hitbox Size Section (Y: 424)
HitboxLabelRef = Instance.new("TextLabel")
HitboxLabelRef.Size = UDim2.new(0.35, 0, 0, 32)
HitboxLabelRef.Position = UDim2.new(0.05, 0, 0, 424)
HitboxLabelRef.BackgroundTransparency = 1
HitboxLabelRef.Text = "Hitbox Size: " .. HitboxSizeVal
HitboxLabelRef.TextColor3 = Color3.fromRGB(255, 255, 255)
HitboxLabelRef.TextSize = 10
HitboxLabelRef.Font = Enum.Font.GothamBold
HitboxLabelRef.TextXAlignment = Enum.TextXAlignment.Left
HitboxLabelRef.Parent = MainFrame

local HitboxMinusBtn = Instance.new("TextButton")
HitboxMinusBtn.Size = UDim2.new(0.24, 0, 0, 32)
HitboxMinusBtn.Position = UDim2.new(0.42, 0, 0, 424)
HitboxMinusBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
HitboxMinusBtn.BackgroundTransparency = 0.3
HitboxMinusBtn.Text = "-"
HitboxMinusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
HitboxMinusBtn.TextSize = 14
HitboxMinusBtn.Font = Enum.Font.GothamBold
HitboxMinusBtn.Parent = MainFrame

local MinusCorner = Instance.new("UICorner")
MinusCorner.CornerRadius = UDim.new(0, 6)
MinusCorner.Parent = HitboxMinusBtn

local HitboxPlusBtn = Instance.new("TextButton")
HitboxPlusBtn.Size = UDim2.new(0.24, 0, 0, 32)
HitboxPlusBtn.Position = UDim2.new(0.71, 0, 0, 424)
HitboxPlusBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 110)
HitboxPlusBtn.BackgroundTransparency = 0.3
HitboxPlusBtn.Text = "+"
HitboxPlusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
HitboxPlusBtn.TextSize = 14
HitboxPlusBtn.Font = Enum.Font.GothamBold
HitboxPlusBtn.Parent = MainFrame

local PlusCorner = Instance.new("UICorner")
PlusCorner.CornerRadius = UDim.new(0, 6)
PlusCorner.Parent = HitboxPlusBtn

HitboxMinusBtn.MouseButton1Click:Connect(function()
	HitboxSizeVal = math.clamp(HitboxSizeVal - 1, 1, 50)
	HitboxLabelRef.Text = "Hitbox Size: " .. HitboxSizeVal
end)

HitboxPlusBtn.MouseButton1Click:Connect(function()
	HitboxSizeVal = math.clamp(HitboxSizeVal + 1, 1, 50)
	HitboxLabelRef.Text = "Hitbox Size: " .. HitboxSizeVal
end)

table.insert(Connections, RunService.RenderStepped:Connect(function()
	if ArhangelsTeamEnabled then
		for _, player in pairs(Players:GetPlayers()) do
			if player ~= LocalPlayer and player.Character then
				local hrp = player.Character:FindFirstChild("HumanoidRootPart")
				if hrp then
					hrp.Size = Vector3.new(HitboxSizeVal, HitboxSizeVal, HitboxSizeVal)
					hrp.Transparency = 0.6
					hrp.CanCollide = false
					hrp.Massless = true
				end
			end
		end
	end
end))

-- 11. Teleport to Player Section (Y: 464)
TeleportInputRef = Instance.new("TextBox")
TeleportInputRef.Size = UDim2.new(0.58, 0, 0, 32)
TeleportInputRef.Position = UDim2.new(0.05, 0, 0, 464)
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
TeleportBtnRef.Position = UDim2.new(0.66, 0, 0, 464)
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

-- 12. Server Hop System Button (Y: 504)
ServerHopPanelBtnRef = Instance.new("TextButton")
ServerHopPanelBtnRef.Size = UDim2.new(0.9, 0, 0, 32)
ServerHopPanelBtnRef.Position = UDim2.new(0.05, 0, 0, 504)
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

-- Server Hop Panel Frame
ServerHopFrame = Instance.new("Frame")
ServerHopFrame.Size = UDim2.new(0, 280, 0, 220)
ServerHopFrame.Position = UDim2.new(1.05, 0, 0, 0)
ServerHopFrame.BackgroundColor3 = Color3.fromRGB(15, 18, 28)
ServerHopFrame.BackgroundTransparency = 0.05
ServerHopFrame.BorderSizePixel = 0
ServerHopFrame.Visible = false
ServerHopFrame.Parent = MainFrame

local HopFrameCorner = Instance.new("UICorner")
HopFrameCorner.CornerRadius = UDim.new(0, 12)
HopFrameCorner.Parent = ServerHopFrame

local HopFrameStroke = Instance.new("UIStroke")
HopFrameStroke.Thickness = 2
HopFrameStroke.Color = Color3.fromRGB(100, 100, 255)
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
ServerHopInfoLabel.Text = "Server Hop & Region Switcher\nFind smaller or cleaner servers."
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
ServerHopInput.PlaceholderText = "Max Players Threshold..."
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
HopOnceBtn.Text = "Hop Once"
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
AutoHopBtn.Text = "Auto Hop: OFF"
AutoHopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
AutoHopBtn.TextSize = 10
AutoHopBtn.Font = Enum.Font.GothamBold
AutoHopBtn.Parent = ServerHopFrame

local AutoHopCorner = Instance.new("UICorner")
AutoHopCorner.CornerRadius = UDim.new(0, 6)
AutoHopCorner.Parent = AutoHopBtn

ServerHopPanelBtnRef.MouseButton1Click:Connect(function()
	ServerHopFrame.Visible = not ServerHopFrame.Visible
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
	AutoHopBtn.Text = AutoHopEnabled and "Auto Hop: ON" or "Auto Hop: OFF"
	AutoHopBtn.BackgroundColor3 = AutoHopEnabled and Color3.fromRGB(0, 180, 110) or Color3.fromRGB(180, 45, 45)
end)

-- 13. Region / Country Label (Y: 584)
CountryLabelRef = Instance.new("TextLabel")
CountryLabelRef.Size = UDim2.new(0.9, 0, 0, 28)
CountryLabelRef.Position = UDim2.new(0.05, 0, 0, 584)
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

-- 14. Footer Label (Y: 620)
FooterLabelRef = Instance.new("TextLabel")
FooterLabelRef.Size = UDim2.new(0.9, 0, 0, 24)
FooterLabelRef.Position = UDim2.new(0.05, 0, 0, 620)
FooterLabelRef.BackgroundTransparency = 0.5
FooterLabelRef.Text = Translations[CurrentLang].Footer
FooterLabelRef.TextColor3 = Color3.fromRGB(130, 140, 160)
FooterLabelRef.TextSize = 9
FooterLabelRef.Font = Enum.Font.Gotham
FooterLabelRef.TextXAlignment = Enum.TextXAlignment.Center
FooterLabelRef.Parent = MainFrame

-- Keyboard Toggle (LeftControl for UI)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if input.KeyCode == Enum.KeyCode.LeftControl then
		MainFrame.Visible = not MainFrame.Visible
	end
end)
