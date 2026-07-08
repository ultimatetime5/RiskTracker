local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local API_URL = "https://mtlxlyqmcpzzqnzzyyus.supabase.co/rest/v1/fish_it_inventory"
local ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im10bHhseXFtY3B6enFuenp5eXVzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODM0OTU5MDksImV4cCI6MjA5OTA3MTkwOX0.2M02hdfHtD-Bw2OQdUbcJLoqLEeqIFT5oOkkFFfvoKc"

local req = request or (http and http.request) or http_request

-- 100% Menggunakan Logika Pembacaan Tabel Internal dari Script Referensi
local function getInventoryValue(itemName)
    local reg = getreg or debug.getregistry
    if reg then
        for _, v in pairs(reg()) do
            if type(v) == "table" and v.Inventory and type(v.Inventory) == "table" then
                -- Jika nama item ada di dalam tabel inventory internal game
                if v.Inventory[itemName] then
                    return tonumber(v.Inventory[itemName]) or 0
                end
            end
        end
    end
    
    -- Jalur Cadangan getgc jika getreg dikunci oleh executor
    if getgc then
        for _, v in pairs(getgc(true)) do
            if type(v) == "table" and v.Inventory and type(v.Inventory) == "table" then
                if v.Inventory[itemName] then
                    return tonumber(v.Inventory[itemName]) or 0
                end
            end
        end
    end
    return 0
end

local function sendInventory()
    -- Membaca indeks item asli game Fish It berdasarkan skrip referensi
    local data = {
        username = LocalPlayer.Name,
        evolved_enchant = getInventoryValue("Evolved Enchant Stone"),
        runic_enchant = getInventoryValue("Runic Enchant Stone"),
        secret_fish = 0,
        ghostfinn_rod = getInventoryValue("Ghostfinn Rod"),
        element_rod = getInventoryValue("Element Rod"),
        diamond_rod = getInventoryValue("Diamond Rod"),
        ruby_gem = getInventoryValue("Ruby Gemstone")
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

-- Eksekusi langsung dan looping otomatis setiap 60 detik
task.spawn(sendInventory)
while task.wait(60) do
    sendInventory()
end
