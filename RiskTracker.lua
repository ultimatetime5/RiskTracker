local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local API_URL = "https://mtlxlyqmcpzzqnzzyyus.supabase.co/rest/v1/fish_it_inventory"
local ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im10bHhseXFtY3B6enFuenp5eXVzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODM0OTU5MDksImV4cCI6MjA5OTA3MTkwOX0.2M02hdfHtD-Bw2OQdUbcJLoqLEeqIFT5oOkkFFfvoKc"

local req = request or (http and http.request) or http_request

-- Fungsi pencarian memori internal super aman (Bypass error "not a valid member")
local function safeFetchMemory(itemName)
    local reg = getreg or debug.getregistry
    if reg then
        local success, result = pcall(function()
            for _, v in pairs(reg()) do
                if type(v) == "table" then
                    -- Jalur 1: Jika data inventori ditaruh di dalam sub-tabel khusus
                    if v.Inventory and type(v.Inventory) == "table" and v.Inventory[itemName] then
                        return tonumber(v.Inventory[itemName])
                    end
                    -- Jalur 2: Jika data inventori langsung digabung di tabel utama save
                    if v[itemName] and (type(v[itemName]) == "number" or type(v[itemName]) == "string") then
                        return tonumber(v[itemName])
                    end
                end
            end
        end)
        if success and result then return result end
    end
    
    if getgc then
        local success, result = pcall(function()
            for _, v in pairs(getgc(true)) do
                if type(v) == "table" then
                    if v.Inventory and type(v.Inventory) == "table" and v.Inventory[itemName] then
                        return tonumber(v.Inventory[itemName])
                    end
                    if v[itemName] and (type(v[itemName]) == "number" or type(v[itemName]) == "string") then
                        return tonumber(v[itemName])
                    end
                end
            end
        end)
        if success and result then return result end
    end
    return 0
end

local function sendInventory()
    -- Membaca data item riil menggunakan nama string asli dari script referensi game
    local data = {
        username = LocalPlayer.Name,
        evolved_enchant = safeFetchMemory("Evolved Enchant Stone"),
        runic_enchant = safeFetchMemory("Runic Enchant Stone"),
        secret_fish = 0,
        ghostfinn_rod = safeFetchMemory("Ghostfinn Rod"),
        element_rod = safeFetchMemory("Element Rod"),
        diamond_rod = safeFetchMemory("Diamond Rod"),
        ruby_gem = safeFetchMemory("Ruby Gemstone")
    }

    if req then
        req({
            Url = API_URL,
            Method = "POST",
            Headers = {
                ["apikey"] = ANON_KEY,
                ["Authorization"] = "Bearer " .. ANON_KEY,
                ["Content-Type"] = "application/json"
            },
            Body = HttpService:JSONEncode(data)
        })
    end
end

-- Eksekusi instan dan ulangi otomatis setiap 60 detik
task.spawn(sendInventory)
while task.wait(60) do
    sendInventory()
end
