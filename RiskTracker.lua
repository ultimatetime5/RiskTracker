local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local DISCORD_WEBHOOK_URL = "https://discord.com/api/webhooks/1493701449161642054/eSWJl9k9siGa1RVBMNT8InnxoMf6W96yRlMDORLhbMpezbXxxJaKqD-PeGPHv65VhGts"

-- Deteksi fungsi request bawaan executor mobile kamu
local req = request or (http and http.request) or http_request

local function getInventoryValue(itemName)
    local reg = getreg or debug.getregistry
    if reg then
        for _, v in pairs(reg()) do
            if type(v) == "table" and v.Inventory and type(v.Inventory) == "table" then
                if v.Inventory[itemName] then
                    return tonumber(v.Inventory[itemName]) or 0
                end
            end
        end
    end
    
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
                {["name"] = "🔮 Enchant Stones", ["value"] = "• Evolved Enchant: **" .. evolved .. "**\n• Runic Enchant: **" .. runic .. "**", ["inline"] = true},
                {["name"] = "💎 Gems", ["value"] = "• Ruby Gemstone: **" .. ruby .. "**", ["inline"] = true},
                {["name"] = "🎣 Rods / Alat Pancing", ["value"] = "• Ghostfinn Rod: **" .. ghostfinn .. "**\n• Element Rod: **" .. element .. "**\n• Diamond Rod: **" .. diamond .. "**", ["inline"] = false}
            },
            ["footer"] = {["text"] = "R-Helper v2.4 • Auto Loop 60s"},
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
