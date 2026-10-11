local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

---------------------------------------------------------
-- ⚙️ لوحة التحكم الرئيسية:
-- true  = السكريبت متاح للتشغيل
-- false = السكريبت مقفول نهائياً (القرار ثابت على الجميع حتى لو دخلوا ماب تانية)
local ScriptEnabled = false  
---------------------------------------------------------

local function showMaintenanceNotice()
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "تنبيه صيانة",
            Text = "نعتذر يوجد صيانة من المطور آدم",
            Duration = 6
        })
    end)
end

-- التحقق المباشر قبل جلب أو تشغيل أي حاجة
if ScriptEnabled == false then
    showMaintenanceNotice()
    return -- إيقاف تام للسكريبت من البداية ولن يعمل حتى لو تنقل بين الماباعات
end

-- تحميل السكريبت الأساسي لو الحالة true
local mainURL = "https://raw.githubusercontent.com/adam12mostafaale2012-web/-/refs/heads/main/main.lua?v=" .. tick()
local success, scriptCode = pcall(function()
    return game:HttpGet(mainURL)
end)

if success and scriptCode then
    local loadedFunc = loadstring(scriptCode)
    if loadedFunc then
        loadedFunc()
    end
end

-- نظام مراقبة في الخلفية لو أنت قررت تقفله وأنت جوه اللعبة
task.spawn(function()
    while task.wait(3) do
        if ScriptEnabled == false then
            showMaintenanceNotice()
            
            -- حذف واجهات السكريبت فوراً
            for _, gui in pairs(CoreGui:GetChildren()) do
                if gui:IsA("ScreenGui") and not gui.Name:find("Roblox") then
                    gui:Destroy()
                end
            end
            break
        end
    end
end)
