local Http = Service or game:GetService("HttpService")

-- إضافة وقت دقيق لمنع الـ Cache نهائياً
local timeStamp = tostring(os.time())
local statusURL = "https://raw.githubusercontent.com/adam12mostafaale2012-web/-/refs/heads/main/status.json?time=" .. timeStamp
local mainURL = "https://raw.githubusercontent.com/adam12mostafaale2012-web/-/refs/heads/main/main.lua?time=" .. timeStamp

local success, response = pcall(function()
    return game:HttpGet(statusURL)
end)

if not success then
    warn("فشل الاتصال بملف الحالة")
    return
end

-- تنظيف النص من أي مسافات مخفية
local statusText = response:match('"status"%s*:%s*"([^"]+)"')

if statusText == "تشغيل" then
    local scriptSuccess, scriptCode = pcall(function()
        return game:HttpGet(mainURL)
    end)
    
    if scriptSuccess and scriptCode then
        local runFunc, err = loadstring(scriptCode)
        if runFunc then
            runFunc()
        else
            warn("خطأ في تشغيل السكريبت:", err)
        end
    end
else
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "تنبيه",
        Text = "السكريبت متوقف حالياً للصيانة.",
        Duration = 5
    })
end
