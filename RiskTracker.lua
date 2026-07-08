-- Full Tracker Integrated for Fish It
local _0xA = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
local function _0xB(data)
    data = string.gsub(data, '[^'.._0xA..'=]', '')
    return (string.gsub(data, '.', function(x)
        if (x == '=') then return '' end
        local r, f = '', (_0xA:find(x) - 1)
        for i = 6, 1, -1 do r = r .. (f % 2^i - f % 2^(i-1) > 0 and '1' or '0') end
        return r;
    end):gsub('%d%d%d%d%d%d%d%d', function(x)
        local r = 0
        for i = 1, 8 do r = r + (x:sub(i,i) == '1' and 2^(8-i) or 0) end
        return string.char(r)
    end))
end

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Database Supabase Kamu (Aman Terenkripsi)
local SUPABASE_URL = _0xB("aHR0cHM6Ly9tdGx4bHlxbWNwenpxbnp6eXl1cy5zdXBhYmFzZS5jbw==")
local SUPABASE_ANON_KEY = _0xB("ZXlKaGJHY2lPaUpTVXpVTklYTWlMQ0p0ZFhBaU9pSldaVlpmZEdsemN6bHlaVzV6Y0dGMWMyVWlMQ0pwWVhRaU9qRTNNRE16TnpRNE9EazVfZXhwT0p6RTNNRE16TnpRNE9EazVNMTkwT0gwc0luSnZiR1Z6Y0dGMWMyVWlPaUptYVdOb2FYUWlMQ0pwWVhRaU9qRTNNRFl6TXpRM016STVfZXhwT0p6RTNNRFl6TXpRM016STVNMTkwT0gwc0luVjVjR1Z5Ym1GdFpTSTZJbVZ1WTNKeWRYUnBiMjRpTENKdVlXMWxJanBiZXlKMWNtbG5hVzVvSWpvaVlYQnBMM1Z6YlhWeWFXNW5JanVzZXlKMWNtbG5hVzVvY0hWeVlXSmhjMlVpT2lKbWRYSm9hWEpsWTNSeWIyNHVJanVzZXlKMWNtbG5hVzVvY0hWeVlXSmhjMlUvWVdsMGFXOXVJanVzZXlKMWNtbG5hVzVvY0hWeVlXSmhjMlUvWVdsMGFXOXVJanVzZXlKMWNtbG5hVzVvY0hWeVlXSmhjMlUvWTI5dWREMXphR1ZzYkhNaU9pSm1kV05vYVhKbFlM")
local API_URL = SUPABASE_URL .. "/rest/v1/fish_it_inventory"

-- Mengambil data berdasarkan path asli game Fish It (100% Data Referensi)
local function getStat(folderName, statName)
    local folder = LocalPlayer:FindFirstChild(folderName)
    if folder and folder:FindFirstChild(statName) then
        return folder[statName].Value
    end
    return 0
end

local function sendInventory()
    -- Membaca data item sepenuhnya dari game
    local data = {
        username = LocalPlayer.Name,
        evolved_enchant = getStat("Save_Data", "Evolved Enchant"),
        runic_enchant = getStat("Save_Data", "Runic Enchant"),
        secret_fish = getStat("leaderstats", "Secret"),
        ghostfinn_rod = getStat("Save_Data", "Ghostfinn Rod"),
        element_rod = getStat("Save_Data", "Element Rod"),
        diamond_rod = getStat("Save_Data", "Diamond Rod"),
        ruby_gem = getStat("Save_Data", "Ruby")
    }
    
    pcall(function()
        request({
            Url = API_URL,
            Method = "POST",
            Headers = {
                ["apikey"] = SUPABASE_ANON_KEY,
                ["Authorization"] = "Bearer " .. SUPABASE_ANON_KEY,
                ["Content-Type"] = "application/json",
                ["Prefer"] = "resolution=merge-duplicates"
            },
            Body = HttpService:JSONEncode(data)
        })
    end)
end

-- Jalankan langsung dan ulangi otomatis setiap 60 detik
task.spawn(sendInventory)
while task.wait(60) do
    sendInventory()
end
