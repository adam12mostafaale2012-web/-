local Http = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")

-- دالة لقراءة الحالة مع إجبار جيت هاب على التحديث الفوري
local function getStatus()
    -- بنزود تيك عشوائي مع رقم راندوم عشان نتجنب الكاش تماماً
    local statusURL = "https://raw.githubusercontent.com/adam12mostafaale2012-web/-/refs/heads/main/status.json?v=" .. tick() .. math.random(1000, 9999)
    local success, response = pcall(function()
        return game:HttpGet(statusURL)
    end)
    
    if success and response then
        -- طباعة الرد في الـ F9 Output عشان نشوف هو بيقرا إيه بظبط!
        print("Raw Response from GitHub:", response)
        
        -- لو الرد فيه كلمة true يبقي اشتغل، غير كده يعتبر صيانة
        if response:find("true") then
            return true
        end
    end
    return false
end

-- 1️⃣ الفحص قبل التشغيل
if getStatus() == true then
    local mainURL = "https://raw.githubusercontent.com/adam12mostafaale2012-web/-/refs/heads/main/main.lua?v=" .. tick()
    local scriptCode = game:HttpGet(mainURL)
    local loadedFunc = loadstring(scriptCode)
    
    if loadedFunc then
        loadedFunc()
    end
    
    -- 2️⃣ حلقة مراقبة ذكية أثناء اللعب
    task.spawn(function()
        while task.wait(3) do
            -- لو الـ getStatus رجعت false (يعني مفيش كلمة true في الملف)
            if getStatus() == false then
                -- إرسال الإشعار بالرسالة الخاصة بك
                pcall(function()
                    StarterGui:SetCore("SendNotification", {
                        Title = "تنبيه صيانة",
                        Text = "نعتذر يوجد صيانة من المطور آدم",
                        Duration = 8
                    })
                end)
                
                -- إغلاق واجهات السكريبت فوراً
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
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "تنبيه صيانة",
            Text = "نعتذر يوجد صيانة من المطور آدم",
            Duration = 6
        })
    end)
end
