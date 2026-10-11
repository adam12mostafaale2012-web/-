local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")

-- دالة حديثة لجلب الحالة الحقيقية والمباشرة من جيت هاب لحظياً بدون أي كاش
local function checkLiveStatus()
    -- بنزود tick() عشان نمنع أي كاش قديم من جيت هاب تماماً
    local statusURL = "https://raw.githubusercontent.com/adam12mostafaale2012-web/-/refs/heads/main/loader.lua?v=" .. tick()
    -- ملاحظة: بما أننا حاطين التحكم جوه loader.lua نفسه، هنعتمد على المتغير المباشر أدناه، 
    -- ولو حابب تربطه بملف خارجي نقدر، بس خلينا نمشي بالتحكم المباشر السريع:
end

---------------------------------------------------------
-- ⚙️ لوحة التحكم المباشرة:
-- true  = مسموح للسكريبت يشتغل في أي ماب يدخلها
-- false = متوقف تماماً (حتى لو اتنقل بين الماباعات)
local ScriptEnabled = true  
---------------------------------------------------------

-- دالة التشغيل الأساسية التي تتفعل مع كل دخول أو تنقل (Teleport)
local function initScript()
    if ScriptEnabled == true then
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
    else
        -- تنبيه فور دخول اللاعب لو السكريبت مغلق للصيانة
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = "تنبيه صيانة",
                Text = "نعتذر يوجد صيانة من المطور آدم",
                Duration = 6
            })
        end)
    end
end

-- تشغيل الكود أول ما اللاعب يدخل
initScript()

-- نظام مراقبة ذكي يعمل حتى لو اللاعب تنقل بين الماباعات (Teleport Support)
task.spawn(function()
    while task.wait(3) do
        if ScriptEnabled == false then
            -- إشعار الصيانة الفوري
            pcall(function()
                StarterGui:SetCore("SendNotification", {
                    Title = "تنبيه صيانة",
                    Text = "نعتذر يوجد صيانة من المطور آدم",
                    Duration = 8
                })
            end)
            
            -- حذف واجهات السكريبت فوراً من شاشة اللاعب
            for _, gui in pairs(CoreGui:GetChildren()) do
                if gui:IsA("ScreenGui") and not gui.Name:find("Roblox") then
                    gui:Destroy()
                end
            end
            break
        end
    end
end)
