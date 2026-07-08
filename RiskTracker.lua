local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

print("--- [MEMULAI SCANNING INVENTORY FISIK] ---")

-- 1. Scan Modul Data Internal di ReplicatedStorage
local success, save = pcall(function()
    return ReplicatedStorage.CloudSave.GetSave:InvokeServer()
end)

if success and type(save) == "table" then
    print("[FOUND] Data Save Berupa Tabel:")
    for k, v in pairs(save) do
        if type(v) == "table" then
            print("  -> Sub-Tabel: " .. tostring(k))
            for subK, subV in pairs(v) do
                print("     • " .. tostring(subK) .. " = " .. tostring(subV))
            end
        else
            print("  • " .. tostring(k) .. " = " .. tostring(v))
        end
    end
else
    print("[INFO] Jalur CloudSave tidak mengembalikan tabel data.")
end

-- 2. Scan Folder atau Nilai Tersirat di ReplicatedStorage yang membawa nama player
for _, v in pairs(ReplicatedStorage:GetChildren()) do
    if v:IsA("Folder") and (v.Name:lower():find("data") or v.Name:lower():find("profile")) then
        local pData = v:FindFirstChild(LocalPlayer.Name) or v:FindFirstChild(tostring(LocalPlayer.UserId))
        if pData then
            print("[FOUND] Folder Data Player di ReplicatedStorage: " .. v.Name)
            for _, item in pairs(pData:GetChildren()) do
                print("  • " .. item.Name .. " (" .. item.ClassName .. ") = " .. tostring(item.Value))
            end
        end
    end
end

-- 3. Scan Element UI Inventory di PlayerGui (Tempat teks jumlah item berada)
local pGui = LocalPlayer:FindFirstChild("PlayerGui")
if pGui then
    print("[SCANNING] Mencari teks angka di dalam PlayerGui...")
    for _, v in pairs(pGui:GetDescendants()) do
        if v:IsA("TextLabel") or v:IsA("TextBox") then
            -- Cari UI yang teksnya berisi angka (kuantitas item) dan punya nama spesifik
            if string.match(v.Text, "^%d+$") and #v.Name > 2 then
                print("  • UI Name: " .. v.Name .. " | Text: " .. v.Text .. " | Parent: " .. v.Parent.Name)
            end
        end
    end
end

print("--- [SCANNING SELESAI] ---")
