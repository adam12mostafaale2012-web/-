local Http = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")

-- دالة فحص الحالة بـ tick لضمان التحديث الفوري
local function getStatus()
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

-- 1️⃣ الفحص قبل تشغيل السكريبت أول ما اللاعب يدخل
if getStatus() == true then
    local mainURL = "https://raw.githubusercontent.com/adam12mostafaale2012-web/-/refs/heads/main/main.lua?v=" .. tick()
    local scriptCode = game:HttpGet(mainURL)
    local loadedFunc = loadstring(scriptCode)
    
    if loadedFunc then
        loadedFunc()
    end
    
    -- 2️⃣ حلقة مراقبة أثناء اللعب (لو قفلت السكريبت وأنت جوه الجيم)
    task.spawn(function()
        while task.wait(3) do
            if getStatus() == false then
                -- إرسال الإشعار بالرسالة التي طلبتها بالضبط
                pcall(function()
                    StarterGui:SetCore("SendNotification", {
                        Title = "تنبيه صيانة",
                        Text = "نعتذر يوجد صيانة من المطور آدم",
                        Duration = 8
                    })
                end)
                
                -- إغلاق واجهات السكريبت فوراً لكل اللاعبين في الجيم
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
    -- لو اللاعب حاول يشغل السكريبت وهو في حالة صيانة
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "تنبيه صيانة",
            Text = "نعتذر يوجد صيانة من المطور آدم",
            Duration = 6
        })
    end)
end
