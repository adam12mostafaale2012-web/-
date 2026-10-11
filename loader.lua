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
