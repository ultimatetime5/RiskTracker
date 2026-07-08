local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local API_URL = "https://mtlxlyqmcpzzqnzzyyus.supabase.co/rest/v1/fish_it_inventory"
local ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im10bHhseXFtY3B6enFuenp5eXVzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODM0OTU5MDksImV4cCI6MjA5OTA3MTkwOX0.2M02hdfHtD-Bw2OQdUbcJLoqLEeqIFT5oOkkFFfvoKc"

local req = request or (http and http.request) or http_request

-- Fungsi nyari nilai di dalam tabel sedalam apa pun (Recursive Search)
local function findInTable(t, targetKey)
    if type(t) ~= "table" then return nil end
    
    -- Cek langsung di level ini
    for k, v in pairs(t) do
        if tostring(k):lower() == targetKey:lower() or tostring(k):lower():gsub("%s+", "") == targetKey:lower():gsub("%s+", "") then
            return tonumber(v) or 0
        end
    end
    
    -- Masuk ke sub-tabel di dalamnya
    for _, v in pairs(t) do
        if type(v) == "table" then
            local res = findInTable(v, targetKey)
            if res then return res end
        end
    end
    return nil
end

local function sendInventory()
    -- Ambil semua kemungkinan data save game
    local save = nil
    pcall(function()
        save = game:GetService("ReplicatedStorage").CloudSave.GetSave:InvokeServer()
    end)
    
    -- Jika InvokeServer gagal, coba ambil data cadangan dari LocalPlayer
    if not save then
        save = LocalPlayer:FindFirstChild("Save_Data") or LocalPlayer:FindFirstChild("leaderstats")
    end

    local function getVal(key)
        if not save then return 0 end
        if type(save) == "table" then
            local found = findInTable(save, key)
            return found or 0
        else
            -- Jika berupa folder objek Roblox
            local item = save:FindFirstChild(key, true)
            return item and tonumber(item.Value) or 0
        end
    end

    local data = {
        username = LocalPlayer.Name,
        evolved_enchant = getVal("Evolved Enchant") or getVal("Evolved Enchant Stone") or getVal("EvolvedEnchant"),
        runic_enchant = getVal("Runic Enchant") or getVal("Runic Enchant Stone") or getVal("RunicEnchant"),
        secret_fish = getVal("Secret") or getVal("Caught") or 0,
        ghostfinn_rod = getVal("Ghostfinn Rod") or getVal("GhostfinnRod"),
        element_rod = getVal("Element Rod") or getVal("ElementRod"),
        diamond_rod = getVal("Diamond Rod") or getVal("DiamondRod"),
        ruby_gem = getVal("Ruby") or getVal("Ruby Gemstone") or getVal("RubyGem")
    }

    -- Print ke console Delta biar kamu tahu isi datanya sebelum dikirim
    print("--- [TRACKER SEND LOG] ---")
    print("Username: " .. tostring(data.username))
    print("Evolved Enchant: " .. tostring(data.evolved_enchant))
    print("Ghostfinn Rod: " .. tostring(data.ghostfinn_rod))

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

task.spawn(sendInventory)
while task.wait(60) do
    sendInventory()
end
