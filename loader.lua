local Http = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")

-- هنا الرابط المباشر لملف status.json بتاعك على جيت هاب (مع منع الكاش بـ tick)
local function getStatus()
    local statusURL = "https://raw.githubusercontent.com/adam12mostafaale2012-web/-/refs/heads/main/status.json?v=" .. tick()
    local success, response = pcall(function()
        return game:HttpGet(statusURL)
    end)
    
    if success and response then
        -- لو الملف فيه true هيشتغل، لو false هيوقف
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
    
    -- 2️⃣ المراقبة المستمرة أثناء اللعب
    task.spawn(function()
        while task.wait(3) do
            if getStatus() == false then
                StarterGui:SetCore("SendNotification", {
                    Title = "تنبيه الصيانة",
                    Text = "تم إيقاف السكريبت الآن للصيانة.",
                    Duration = 7
                })
                
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
    StarterGui:SetCore("SendNotification", {
        Title = "تنبيه",
        Text = "السكريبت متوقف حالياً للصيانة.",
        Duration = 5
    })
end
