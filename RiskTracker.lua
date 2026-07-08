-- Script Tracker untuk Fish It (Client-Side)
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- KONFIGURASI SUPABASE
local SUPABASE_URL = "https://mtlxlyqmcpzzqnzzyyus.supabase.co" 
local SUPABASE_ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im10bHhseXFtY3B6enFuenp5eXVzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODM0OTU5MDksImV4cCI6MjA5OTA3MTkwOX0.2M02hdfHtD-Bw2OQdUbcJLoqLEeqIFT5oOkkFFfvoKc"
local API_URL = SUPABASE_URL .. "/rest/v1/fish_it_inventory"

local function sendInventory()
    local inv = LocalPlayer:FindFirstChild("Inventory") or LocalPlayer:FindFirstChild("leaderstats")
    
    if inv then
        local data = {
            username = LocalPlayer.Name,
            evolved_enchant = inv:FindFirstChild("EvolvedEnchantStone") and inv.EvolvedEnchantStone.Value or 0,
            runic_enchant = inv:FindFirstChild("RunicEnchantStone") and inv.RunicEnchantStone.Value or 0,
            secret_fish = inv:FindFirstChild("SecretFish") and inv.SecretFish.Value or 0,
            ghostfinn_rod = inv:FindFirstChild("GhostfinnRod") and inv.GhostfinnRod.Value or 0,
            element_rod = inv:FindFirstChild("ElementRod") and inv.ElementRod.Value or 0,
            diamond_rod = inv:FindFirstChild("DiamondRod") and inv.DiamondRod.Value or 0,
            ruby_gem = inv:FindFirstChild("RubyGemstone") and inv.RubyGemstone.Value or 0
        }
        
        local success, result = pcall(function()
            return request({
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
        
        if success then
            print("Tracker: Data berhasil dikirim ke Supabase!")
        else
            warn("Tracker: Gagal mengirim data. " .. tostring(result))
        end
    else
        warn("Tracker: Folder Inventory/leaderstats tidak ditemukan!")
    end
end

task.spawn(sendInventory)

while task.wait(60) do
    sendInventory()
end

