-- 圣光潜力：分别检查两个品阶的非银行库存与冷却，任一就绪即为白色。
local addonName, addonTable = ...

-- Lua 内置方法
local insert = table.insert
local random = math.random
local ipairs = ipairs

-- WoW API
local CreateFrame = CreateFrame
local After = C_Timer.After
local EvaluateColorFromBoolean = C_CurveUtil.EvaluateColorFromBoolean
local GetItemCount = C_Item.GetItemCount
local GetItemCooldown = C_Item.GetItemCooldown
local GetTime = GetTime

-- 项目引用
local Cell = addonTable.Cell
local COLOR = addonTable.COLOR
local UIInitFuncs = addonTable.UIInitFuncs

-- 本地配置
local X = 54
local ITEM_IDS = { 241308, 241309 }
local cell
local eventFrame = CreateFrame("Frame")

-- 与 Shigure 一样按物品 ID 查询库存；共享冷却不代表库存合并。
local function ItemReady(itemID)
    local count = GetItemCount(itemID, false, false, false, false)
    if not count or count <= 0 then return false end
    local start, duration, enabled = GetItemCooldown(itemID)
    if start == nil or duration == nil or enabled == nil or enabled == false or enabled == 0 then
        return false
    end
    return start <= 0 or duration <= 0 or start + duration <= GetTime()
end

local function Update()
    if not cell then return end
    local ready = false
    for _, itemID in ipairs(ITEM_IDS) do
        if ItemReady(itemID) then
            ready = true
            break
        end
    end
    cell:setCell(EvaluateColorFromBoolean(ready, COLOR.WHITE, COLOR.BLACK))
end

local function Initialize()
    cell = Cell:New({ x = X })
    Update()
end

eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("BAG_UPDATE")
eventFrame:RegisterEvent("BAG_UPDATE_COOLDOWN")
eventFrame:RegisterEvent("SPELL_UPDATE_COOLDOWN")

eventFrame:SetScript("OnEvent", function()
    After(0, Update)
end)

local elapsedTime = -random()
eventFrame:SetScript("OnUpdate", function(_, elapsed)
    elapsedTime = elapsedTime + elapsed
    if elapsedTime >= 1 then
        elapsedTime = elapsedTime % 1
        Update()
    end
end)
insert(UIInitFuncs, Initialize)

