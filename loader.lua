local Http = game:GetService("HttpService")

-- رابط ملف التحكم مع منع الـ Cache
local statusURL = "https://raw.githubusercontent.com/adam12mostafaale2012-web/-/refs/heads/main/status.json?v=" .. tick()
local mainURL = "https://raw.githubusercontent.com/adam12mostafaale2012-web/-/refs/heads/main/main.lua?v=" .. tick()

local success, statusData = pcall(function()
    return Http:JSONDecode(game:HttpGet(statusURL))
end)

-- الفحص المباشر: يشتغل فقط إذا كانت الحالة تساوي بالظبط "تشغيل"
if success and statusData and statusData.status == "تشغيل" then
    local scriptCode = game:HttpGet(mainURL)
    local loadedFunc, err = loadstring(scriptCode)
    
    if loadedFunc then
        loadedFunc()
    else
        warn("خطأ في تشغيل السكريبت الرئيسي:", err)
    end
else
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "تنبيه",
        Text = "السكريبت متوقف حالياً للصيانة.",
        Duration = 5
    })
end
