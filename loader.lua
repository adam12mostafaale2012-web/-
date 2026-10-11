local Http = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")

-- دالة لقراءة حالة السكريبت بدون Cache
local function getStatus()
    local statusURL = "https://raw.githubusercontent.com/adam12mostafaale2012-web/-/refs/heads/main/status.json?v=" .. tick()
    local success, response = pcall(function()
        return game:HttpGet(statusURL)
    end)
    
    if success and response then
        local decodeSuccess, data = pcall(function()
            return Http:JSONDecode(response)
        end)
        if decodeSuccess and data then
            return data.enabled
        end
    end
    return nil
end

-- 1️⃣ الفحص الأول قبل التشغيل
if getStatus() == true then
    -- تحميل وتشغيل السكريبت الرئيسي من main.lua
    local mainURL = "https://raw.githubusercontent.com/adam12mostafaale2012-web/-/refs/heads/main/main.lua?v=" .. tick()
    local scriptCode = game:HttpGet(mainURL)
    local loadedFunc = loadstring(scriptCode)
    
    if loadedFunc then
        loadedFunc() -- تشغيل السكريبت الأصلي بتاعك كاملاً
    end
    
    -- 2️⃣ حلقة المراقبة المستمرة أثناء اللعب (تشتغل في الخلفية)
    task.spawn(function()
        while task.wait(3) do -- يفحص كل 3 ثواني
            if getStatus() == false then
                -- إرسال إشعار بالصيانة للاعب
                StarterGui:SetCore("SendNotification", {
                    Title = "تنبيه الصيانة",
                    Text = "تم إيقاف السكريبت الآن للصيانة من قبل المطور.",
                    Duration = 7
                })
                
                -- حذف واجهات السكريبت من الشاشة فوراً
                for _, gui in pairs(CoreGui:GetChildren()) do
                    if gui:IsA("ScreenGui") and not gui.Name:find("Roblox") then
                        -- لحذف واجهة السكريبت
                        gui:Destroy()
                    end
                end
                
                break -- إيقاف الفحص
            end
        end
    end)

else
    -- لو كان متوقف من الأول
    StarterGui:SetCore("SendNotification", {
        Title = "تنبيه",
        Text = "السكريبت متوقف حالياً للصيانة.",
        Duration = 5
    })
end
