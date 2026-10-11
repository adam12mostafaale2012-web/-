local Http = game:GetService("HttpService")

-- رابط ملف التحكم (حالة السكريبت)
local statusURL = "https://raw.githubusercontent.com/adam12mostafaale2012-web/-/refs/heads/main/status.json"

-- رابط السكريبت الرئيسي
local mainURL = "https://raw.githubusercontent.com/adam12mostafaale2012-web/-/refs/heads/main/%D8%A7%D8%B3%D9%83%D8%B1%D9%8A%D9%81%D8%AA%20%D8%A7%D8%AF%D9%85"

local success, statusData = pcall(function()
    return Http:JSONDecode(game:HttpGet(statusURL))
end)

if success and statusData and statusData.enabled == true then
    loadstring(game:HttpGet(mainURL))()
else
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "تنبيه",
        Text = "السكريبت متوقف حالياً للصيانة.",
        Duration = 5
    })
end
