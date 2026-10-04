-- 库存、可使用状态和冷却与实际使用的物品一致。
local addonName, addonTable = ...

-- Lua 内置方法
local insert = table.insert
local ipairs = ipairs

-- WoW API
local GetItemCount = C_Item.GetItemCount
local GetItemCooldown = C_Item.GetItemCooldown
local IsUsableItem = C_Item.IsUsableItem
local EvaluateColorFromBoolean = C_CurveUtil.EvaluateColorFromBoolean
local After = C_Timer.After
local CreateFrame = CreateFrame

-- 项目引用
local COLOR = addonTable.COLOR
local UIInitFuncs = addonTable.UIInitFuncs
local Cell = addonTable.Cell

-- 本地配置
local X, ITEM_ID = 59, 271883
local cell
local frame = CreateFrame("Frame")

local function Refresh()
    if not cell then return end
    local color = COLOR.BLACK
    if GetItemCount(ITEM_ID) > 0 then
        local _, duration, enabled = GetItemCooldown(ITEM_ID)
        local usable, noMana = IsUsableItem(ITEM_ID)
        local available = EvaluateColorFromBoolean(noMana, COLOR.BLACK, COLOR.WHITE)
        available = EvaluateColorFromBoolean(usable, available, COLOR.BLACK)
        available = EvaluateColorFromBoolean(duration == 0, available, COLOR.BLACK)
        color = EvaluateColorFromBoolean(enabled, available, COLOR.BLACK)
    end
    cell:setCell(color)
end
for _, event in ipairs({ "PLAYER_ENTERING_WORLD", "BAG_UPDATE_DELAYED", "BAG_UPDATE_COOLDOWN", "SPELL_UPDATE_COOLDOWN" }) do
    frame:RegisterEvent(event)
end
frame:SetScript("OnEvent", function() After(0, Refresh) end)
local elapsed = 0
frame:SetScript("OnUpdate", function(_, delta)
    elapsed = elapsed + delta
    if elapsed >= 1 then elapsed = elapsed % 1; Refresh() end
end)
insert(UIInitFuncs, function()
    cell = Cell:New({ x = X })
    Refresh()
end)
