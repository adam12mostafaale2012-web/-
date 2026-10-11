local Http = game:GetService("HttpService")

local function checkStatus()
    local statusURL = "https://raw.githubusercontent.com/adam12mostafaale2012-web/-/refs/heads/main/status.json?v=" .. tick()
    local success, response = pcall(function()
        return game:HttpGet(statusURL)
    end)
    
    if success and response then
        local decodeSuccess, data = pcall(function()
            return Http:JSONDecode(response)
        end)
        if decodeSuccess and data and data.enabled == true then
            return true
        end
    end
    return false
end

if checkStatus() then
    local mainURL = "https://raw.githubusercontent.com/adam12mostafaale2012-web/-/refs/heads/main/main.lua?v=" .. tick()
    local scriptCode = game:HttpGet(mainURL)
    local loadedFunc = loadstring(scriptCode)
    if loadedFunc then
        loadedFunc()
    end
else
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "تنبيه",
        Text = "السكريبت متوقف حالياً للصيانة.",
        Duration = 5
    })
end
