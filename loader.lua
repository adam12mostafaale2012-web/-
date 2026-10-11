local Http = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")

-- دالة لقراءة حالة السكريبت مع كسر الـ Cache نهائياً باستخدام os.time()
local function getStatus()
    local statusURL = "https://raw.githubusercontent.com/adam12mostafaale2012-web/-/refs/heads/main/status.json?t=" .. os.time()
    local success, response = pcall(function()
        return game:HttpGet(statusURL)
    end)
    
    if success and response then
        local decodeSuccess, data = pcall(function()
            return Http:JSONDecode(response)
        end)
        if decodeSuccess and data and type(data.enabled) == "boolean" then
            return data.enabled
        end
    end
    return false -- لو فشل الاتصال أو القراءة، يوقف السكريبت للأمان
end

-- 1️⃣ الفحص الأول قبل التشغيل
if getStatus() == true then
    local mainURL = "https://raw.githubusercontent.com/adam12mostafaale2012-web/-/refs/heads/main/main.lua?t=" .. os.time()
    local scriptCode = game:HttpGet(mainURL)
    local loadedFunc = loadstring(scriptCode)
    
    if loadedFunc then
        loadedFunc()
    end
    
    -- 2️⃣ حلقة المراقبة المستمرة أثناء اللعب
    task.spawn(function()
        while task.wait(5) do -- يفحص كل 5 ثواني
            if getStatus() == false then
                -- إشعار الصيانة
                pcall(function()
                    StarterGui:SetCore("SendNotification", {
                        Title = "تنبيه الصيانة",
                        Text = "تم إيقاف السكريبت الآن للصيانة.",
                        Duration = 7
                    })
                end)
                
                -- مسح واجهات السكريبت من الشاشة
                for _, gui in pairs(CoreGui:GetChildren()) do
                    if gui:IsA("ScreenGui") and not gui.Name:find("Roblox") then
                        gui:Destroy()
                    end
                end
                
                break -- الخروج من حلقة الفحص
            end
        end
    end)

else
    -- إشعار لو كان متوقف من الأول
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "تنبيه",
            Text = "السكريبت متوقف حالياً للصيانة.",
            Duration = 5
        })
    end)
end
