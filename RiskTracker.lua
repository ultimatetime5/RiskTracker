local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local API_URL = "https://mtlxlyqmcpzzqnzzyyus.supabase.co/rest/v1/fish_it_inventory"
local ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im10bHhseXFtY3B6enFuenp5eXVzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODM0OTU5MDksImV4cCI6MjA5OTA3MTkwOX0.2M02hdfHtD-Bw2OQdUbcJLoqLEeqIFT5oOkkFFfvoKc"

local req = request or (http and http.request) or http_request

-- Fungsi untuk menghitung jumlah item spesifik dari slot UI Gui
local function countUiItems(targetName)
    local pGui = LocalPlayer:FindFirstChild("PlayerGui")
    if not pGui then return 0 end

    local totalAmount = 0
    targetName = targetName:lower()

    -- Menyusuri seluruh element Text di PlayerGui untuk mencari slot item
    for _, v in pairs(pGui:GetDescendants()) do
        if v:IsA("TextLabel") and (v.Name == "ItemName" or v.Name == "Title" or v.Name:lower():find("name")) then
            local textClean = v.Text:lower()
            
            -- Jika nama teks cocok dengan item yang dicari
            if textClean:find(targetName) then
                -- Cari text Quantity yang berada di dalam satu folder/slot yang sama
                local parentSlot = v.Parent
                if parentSlot then
                    local qtyLabel = parentSlot:FindFirstChild("Quantity") or parentSlot:FindFirstChild("Amount") or parentSlot:FindFirstChild("Count")
                    
                    -- Cadangan: scan text angka di sekitar slot tersebut jika nama element-nya berbeda
                    if not qtyLabel then
                        for _, child in pairs(parentSlot:GetChildren()) do
                            if child:IsA("TextLabel") and string.match(child.Text, "%d+") then
                                qtyLabel = child
                                break
                            end
                        end
                    end

                    if qtyLabel then
                        local num = string.match(qtyLabel.Text, "%d+")
                        if num then
                            totalAmount = totalAmount + (tonumber(num) or 0)
                        end
                    else
                        -- Jika tidak ada text quantity tetapi slotnya muncul, artinya item tersebut berjumlah 1 (seperti pancingan)
                        totalAmount = totalAmount + 1
                    end
                end
            end
        end
    end
    return totalAmount
end

local function sendInventory()
    -- Melacak dan memilah jumlah asli masing-masing item secara mandiri
    local data = {
        username = LocalPlayer.Name,
        evolved_enchant = countUiItems("Evolved Enchant"),
        runic_enchant = countUiItems("Runic Enchant"),
        secret_fish = 0,
        ghostfinn_rod = countUiItems("Ghostfinn"),
        element_rod = countUiItems("Element"),
        diamond_rod = countUiItems("Diamond"),
        ruby_gem = countUiItems("Ruby")
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
