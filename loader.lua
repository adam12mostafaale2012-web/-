local Http = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")

---------------------------------------------------------
-- ⚙️ لوحة التحكم في السكريبت المباشرة:
-- true  = السكريبت شغال تمام
-- false = السكريبت متوقف للصيانة
local ScriptEnabled = true  
---------------------------------------------------------

-- دالة فحص الحالة (بتفحص المتغير المحلي + ملف status.json)
local function getStatus()
    -- لو قفلت السكريبت من هنا المباشر هيقفل فوراً
    if not ScriptEnabled then 
        return false 
    end
    
    local statusURL = "https://raw.githubusercontent.com/adam12mostafaale2012-web/-/refs/heads/main/status.json?v=" .. tick()
    local success, response = pcall(function()
        return game:HttpGet(statusURL)
    end)
    
    if success and response then
        if response:find("true") then
            return true
        end
    end
    return false
end

-- 1️⃣ الفحص أول ما اللاعب يشغل السكريبت
if getStatus() == true then
    local mainURL = "https://raw.githubusercontent.com/adam12mostafaale2012-web/-/refs/heads/main/main.lua?v=" .. tick()
    local scriptCode = game:HttpGet(mainURL)
    local loadedFunc = loadstring(scriptCode)
    
    if loadedFunc then
        loadedFunc()
    end
    
    -- 2️⃣ حلقة مراقبة في الخلفية كل 3 ثواني للإيقاف الفوري
    task.spawn(function()
        while task.wait(3) do
            if getStatus() == false then
                -- إشعار الصيانة
                pcall(function()
                    StarterGui:SetCore("SendNotification", {
                        Title = "تنبيه صيانة",
                        Text = "نعتذر يوجد صيانة من المطور آدم",
                        Duration = 8
                    })
                end)
                
                -- إغلاق وحذف واجهات السكريبت فوراً
                for _, gui in pairs(CoreGui:GetChildren()) do
                    if gui:IsA("ScreenGui") and not gui.Name:find("Roblox") then
                        gui:Destroy()
                    end
                end
                
                break
            end
        end
    end)

else
    -- إشعار لو السكريبت متوقف
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "تنبيه صيانة",
            Text = "نعتذر يوجد صيانة من المطور آدم",
            Duration = 6
        })
    end)
end
