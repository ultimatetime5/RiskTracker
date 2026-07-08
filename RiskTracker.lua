local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local DISCORD_WEBHOOK_URL = "https://discord.com/api/webhooks/1493701449161642054/eSWJl9k9siGa1RVBMNT8InnxoMf6W96yRlMDORLhbMpezbXxxJaKqD-PeGPHv65VhGts"
local req = request or (http and http.request) or http_request

local function getInventoryValue(itemName)
    local reg = getreg or debug.getregistry
    if not reg then return 0 end

    -- Menggunakan iterasi dengan jeda agar tidak membuat CPU freeze
    for _, v in pairs(reg()) do
        if type(v) == "table" then
            -- Memberi jeda setiap 500 tabel yang diperiksa (mengatasi hang di mobile)
            if math.random(1, 500) == 1 then task.wait() end
            
            local success, match = pcall(function()
                if v.Inventory and type(v.Inventory) == "table" and v.Inventory[itemName] then
                    return tonumber(v.Inventory[itemName])
                end
                if v[itemName] and (type(v[itemName]) == "number" or type(v[itemName]) == "string") then
                    return tonumber(v[itemName])
                end
            end)
            if success and match then return match end
        end
    end
    return 0
end

local function sendToDiscord()
    -- Menggunakan task.spawn agar proses pengambilan data tidak mengganggu jalannya game
    task.spawn(function()
        local evolved = getInventoryValue("Evolved Enchant Stone")
        local runic = getInventoryValue("Runic Enchant Stone")
        local ghostfinn = getInventoryValue("Ghostfinn Rod")
        local element = getInventoryValue("Element Rod")
        local diamond = getInventoryValue("Diamond Rod")
        local ruby = getInventoryValue("Ruby Gemstone")

        local payload = {
            ["embeds"] = {{
                ["title"] = "📦 Fish It - Inventory Tracker",
                ["description"] = "Laporan inventori (Optimized for Mobile).",
                ["color"] = 3447003,
                ["fields"] = {
                    {["name"] = "👤 Player", ["value"] = "```" .. LocalPlayer.Name .. "```", ["inline"] = false},
                    {["name"] = "🔮 Stones", ["value"] = "• Evolved: **" .. (evolved or 0) .. "**\n• Runic: **" .. (runic or 0) .. "**", ["inline"] = true},
                    {["name"] = "🎣 Rods", ["value"] = "• Ghostfinn: **" .. (ghostfinn or 0) .. "**\n• Element: **" .. (element or 0) .. "**", ["inline"] = false}
                }
            }}
        }

        if req then
            req({
                Url = DISCORD_WEBHOOK_URL,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = HttpService:JSONEncode(payload)
            })
        end
    end)
end

-- Jalankan pertama kali setelah 10 detik game stabil
task.delay(10, sendToDiscord)
-- Ulangi setiap 2 menit agar CPU HP lebih awet
while task.wait(120) do
    sendToDiscord()
end
