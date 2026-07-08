local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local DISCORD_WEBHOOK_URL = "https://discord.com/api/webhooks/1493701449161642054/eSWJl9k9siGa1RVBMNT8InnxoMf6W96yRlMDORLhbMpezbXxxJaKqD-PeGPHv65VhGts"

local req = request or (http and http.request) or http_request

local function getInventoryValue(itemName)
    local reg = getreg or debug.getregistry
    if reg then
        for _, v in pairs(reg()) do
            if type(v) == "table" then
                -- PEREDAM CRASH: Pcall akan mengabaikan objek Roact yang memicu error merah
                local success, result = pcall(function()
                    if v.Inventory and type(v.Inventory) == "table" then
                        if v.Inventory[itemName] then
                            return tonumber(v.Inventory[itemName])
                        end
                    end
                end)
                if success and result then return result end
            end
        end
    end
    
    if getgc then
        for _, v in pairs(getgc(true)) do
            if type(v) == "table" then
                local success, result = pcall(function()
                    if v.Inventory and type(v.Inventory) == "table" then
                        if v.Inventory[itemName] then
                            return tonumber(v.Inventory[itemName])
                        end
                    end
                end)
                if success and result then return result end
            end
        end
    end
    return 0
end

local function sendToDiscord()
    local evolved = getInventoryValue("Evolved Enchant Stone")
    local runic = getInventoryValue("Runic Enchant Stone")
    local ghostfinn = getInventoryValue("Ghostfinn Rod")
    local element = getInventoryValue("Element Rod")
    local diamond = getInventoryValue("Diamond Rod")
    local ruby = getInventoryValue("Ruby Gemstone")

    local payload = {
        ["embeds"] = {{
            ["title"] = "📦 Fish It - Inventory Tracker",
            ["description"] = "Berikut adalah laporan penyimpanan inventori akun saat ini.",
            ["color"] = 3447003,
            ["fields"] = {
                {["name"] = "👤 Player Name", ["value"] = "```" .. LocalPlayer.Name .. "```", ["inline"] = false},
                {["name"] = "🔮 Enchant Stones", ["value"] = "• Evolved Enchant: **" .. (evolved or 0) .. "**\n• Runic Enchant: **" .. (runic or 0) .. "**", ["inline"] = true},
                {["name"] = "💎 Gems", ["value"] = "• Ruby Gemstone: **" .. (ruby or 0) .. "**", ["inline"] = true},
                {["name"] = "🎣 Rods / Alat Pancing", ["value"] = "• Ghostfinn Rod: **" .. (ghostfinn or 0) .. "**\n• Element Rod: **" .. (element or 0) .. "**\n• Diamond Rod: **" .. (diamond or 0) .. "**", ["inline"] = false}
            },
            ["footer"] = {["text"] = "R-Helper v2.4 • Khusus Mobile"},
            ["timestamp"] = DateTime.now():ToIsoDate()
        }}
    }

    if req then
        pcall(function()
            req({
                Url = DISCORD_WEBHOOK_URL,
                Method = "POST",
                Headers = {
                    ["Content-Type"] = "application/json"
                },
                Body = HttpService:JSONEncode(payload)
            })
        end)
    end
end

task.spawn(sendToDiscord)
while task.wait(60) do
    sendToDiscord()
end
