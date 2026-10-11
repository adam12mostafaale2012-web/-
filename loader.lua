local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")

---------------------------------------------------------
-- ⚙️ لوحة التحكم في السكريبت المباشرة:
-- true  = السكريبت شغال تمام
-- false = السكريبت متوقف للصيانة
local ScriptEnabled = false  
---------------------------------------------------------

-- 1️⃣ الفحص أول ما اللاعب يشغل السكريبت
if ScriptEnabled == true then
    local mainURL = "https://raw.githubusercontent.com/adam12mostafaale2012-web/-/refs/heads/main/main.lua?v=" .. tick()
    local scriptCode = game:HttpGet(mainURL)
    local loadedFunc = loadstring(scriptCode)
    
    if loadedFunc then
        loadedFunc()
    end
    
    -- 2️⃣ حلقة مراقبة في الخلفية كل 3 ثواني للإيقاف الفوري
    task.spawn(function()
        while task.wait(3) do
            if ScriptEnabled == false then
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
    -- إشعار لو السكريبت متوقف من البداية
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "تنبيه صيانة",
            Text = "نعتذر يوجد صيانة من المطور آدم",
            Duration = 6
        })
    end)
end
