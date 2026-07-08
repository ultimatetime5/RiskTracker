local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

local DISCORD_WEBHOOK_URL = "https://discord.com/api/webhooks/1493701449161642054/eSWJl9k9siGa1RVBMNT8InnxoMf6W96yRlMDORLhbMpezbXxxJaKqD-PeGPHv65VhGts"
local req = request or (http and http.request) or http_request

-- HOOK: Kita membajak fungsi yang digunakan game untuk mengambil data
local OldInvoke
OldInvoke = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    if method == "InvokeServer" and self.Name == "GetSave" then
        local data = OldInvoke(self, ...)
        -- Di sini data inventori disadap saat server mengirimnya ke client
        task.spawn(function()
            if data and type(data) == "table" then
                -- Kirim ke Discord
                local payload = {
                    ["embeds"] = {{
                        ["title"] = "📦 Fish It - Inventory Tracker (Hooked)",
                        ["color"] = 3447003,
                        ["fields"] = {
                            {["name"] = "🔮 Stones", ["value"] = "• Evolved: **" .. (data["Evolved Enchant Stone"] or 0) .. "**\n• Runic: **" .. (data["Runic Enchant Stone"] or 0) .. "**", ["inline"] = true},
                            {["name"] = "🎣 Rods", ["value"] = "• Ghostfinn: **" .. (data["Ghostfinn Rod"] or 0) .. "**", ["inline"] = false}
                        }
                    }}
                }
                req({
                    Url = DISCORD_WEBHOOK_URL,
                    Method = "POST",
                    Headers = {["Content-Type"] = "application/json"},
                    Body = HttpService:JSONEncode(payload)
                })
            end
        end)
    end
    return OldInvoke(self, ...)
end)
