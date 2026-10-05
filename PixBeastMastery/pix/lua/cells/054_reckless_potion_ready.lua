-- 共用爆发药水检测：狂放恣意饮剂与鲁莽药水任一有库存且冷却结束。
local addonName, addonTable = ...

-- Lua 内置方法
local insert = table.insert
local ipairs = ipairs

-- WoW API
local GetItemCooldown = C_Item.GetItemCooldown
local GetItemCount = C_Item.GetItemCount
local After = C_Timer.After
local CreateFrame = CreateFrame
local GetTime = GetTime

-- 项目引用
local COLOR = addonTable.COLOR
local UIInitFuncs = addonTable.UIInitFuncs
local Cell = addonTable.Cell

-- 本地配置
local cell
local frame = CreateFrame("Frame")

local function Refresh()
    if not cell then return end
    local ready = false
    for _, id in ipairs({ 241293, 241292, 241288, 241289 }) do
        local start, duration, enabled = GetItemCooldown(id)
        if GetItemCount(id, false, false, false, false) > 0
            and start ~= nil and duration ~= nil and enabled and enabled ~= 0
            and (duration == 0 or start + duration <= GetTime()) then
            ready = true
        end
    end
    cell:setCell(ready and COLOR.WHITE or COLOR.BLACK)
end
for _, event in ipairs({ "PLAYER_ENTERING_WORLD", "BAG_UPDATE", "BAG_UPDATE_COOLDOWN", "SPELL_UPDATE_COOLDOWN" }) do frame:RegisterEvent(event) end
frame:SetScript("OnEvent", function() After(0, Refresh) end)
local elapsed = 0
frame:SetScript("OnUpdate", function(_, delta)
    elapsed = elapsed + delta
    if elapsed >= 1 then elapsed = elapsed % 1; Refresh() end
end)
insert(UIInitFuncs, function()
    cell = Cell:New({ x = 54 })
    Refresh()
end)
