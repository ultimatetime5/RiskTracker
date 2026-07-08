local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local API_URL = "https://mtlxlyqmcpzzqnzzyyus.supabase.co/rest/v1/fish_it_inventory"
local ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im10bHhseXFtY3B6enFuenp5eXVzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODM0OTU5MDksImV4cCI6MjA5OTA3MTkwOX0.2M02hdfHtD-Bw2OQdUbcJLoqLEeqIFT5oOkkFFfvoKc"

local req = request or (http and http.request) or http_request

-- Mengambil fungsi pemanggil data internal dari script referensi Fish It
local function getInternalInventory()
    local success, save = pcall(function()
        -- Menembak sistem Save_Data bawaan game Fish It menggunakan remote/modul jika tersedia
        return game:GetService("ReplicatedStorage").CloudSave.GetSave:InvokeServer()
    end)
    if success and type(save) == "table" then
        return save
    end
    
    -- Cadangan jika disimpan di save_data folder klien
    local altSave = LocalPlayer:FindFirstChild("Save_Data")
    if altSave then
        return altSave
    end
    return nil
end

local function sendInventory()
    local inv = getInternalInventory()
    
    -- Ambil data nilai, jika tabel kosong atau gagal maka otomatis 0
    local function val(itemName)
        if not inv then return 0 end
        if type(inv) == "table" then
            return tonumber(inv[itemName]) or 0
        else
            local item = inv:FindFirstChild(itemName)
            return item and tonumber(item.Value) or 0
        end
    end

    local data = {
        username = LocalPlayer.Name,
        evolved_enchant = val("Evolved Enchant") + val("EvolvedEnchantStone"),
        runic_enchant = val("Runic Enchant") + val("RunicEnchantStone"),
        secret_fish = val("Secret") or 0,
        ghostfinn_rod = val("Ghostfinn Rod") or val("GhostfinnRod"),
        element_rod = val("Element Rod") or val("ElementRod"),
        diamond_rod = val("Diamond Rod") or val("DiamondRod"),
        ruby_gem = val("Ruby") or val("RubyGemstone")
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

task.spawn(sendInventory)
while task.wait(60) do
    sendInventory()
end
