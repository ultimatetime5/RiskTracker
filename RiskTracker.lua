local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

local API_URL = "https://mtlxlyqmcpzzqnzzyyus.supabase.co/rest/v1/fish_it_inventory"
local ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im10bHhseXFtY3B6enFuenp5eXVzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODM0OTU5MDksImV4cCI6MjA5OTA3MTkwOX0.2M02hdfHtD-Bw2OQdUbcJLoqLEeqIFT5oOkkFFfvoKc"

local req = request or (http and http.request) or http_request

-- Fungsi melacak item inventori fisik di dalam data pemain/ReplicatedStorage
local function getInventoryItem(itemName)
    -- Jalur 1: Cek folder internal PlayerGui data jika tersimpan di klien
    local inventoryFolder = LocalPlayer:FindFirstChild("Inventory") or LocalPlayer:FindFirstChild("Items")
    if inventoryFolder then
        local item = inventoryFolder:FindFirstChild(itemName)
        if item then return tonumber(item.Value) or 0 end
    end
    
    -- Jalur 2: Cek apakah data disimpan menggunakan modul ReplicatedStorage bawaan game
    local playerFolder = ReplicatedStorage:FindFirstChild("PlayerData") or ReplicatedStorage:FindFirstChild("Profiles")
    if playerFolder then
        local myData = playerFolder:FindFirstChild(LocalPlayer.Name) or playerFolder:FindFirstChild(tostring(LocalPlayer.UserId))
        if myData then
            local target = myData:FindFirstChild(itemName, true)
            if target then return tonumber(target.Value) or 0 end
        end
    end
    
    return 0
end

local function sendInventory()
    local data = {
        username = LocalPlayer.Name,
        -- Menembak nama item fisik asli inventori Fish It
        evolved_enchant = getInventoryItem("Evolved Enchant") or getInventoryItem("EvolvedEnchantStone"),
        runic_enchant = getInventoryItem("Runic Enchant") or getInventoryItem("RunicEnchantStone"),
        secret_fish = 0,
        ghostfinn_rod = getInventoryItem("Ghostfinn Rod") or getInventoryItem("GhostfinnRod"),
        element_rod = getInventoryItem("Element Rod") or getInventoryItem("ElementRod"),
        diamond_rod = getInventoryItem("Diamond Rod") or getInventoryItem("DiamondRod"),
        ruby_gem = getInventoryItem("Ruby") or getInventoryItem("RubyGemstone")
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
