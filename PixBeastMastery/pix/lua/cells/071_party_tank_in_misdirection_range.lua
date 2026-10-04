-- 对已选坦克使用误导自身射程，秘密布尔只交给颜色消费者。
local addonName, addonTable = ...

-- Lua 内置方法
local insert = table.insert

-- WoW API
local IsSpellInRange = C_Spell.IsSpellInRange
local EvaluateColorFromBoolean = C_CurveUtil.EvaluateColorFromBoolean
local CreateFrame = CreateFrame
local UnitExists = UnitExists
local UnitIsConnected = UnitIsConnected
local UnitIsDeadOrGhost = UnitIsDeadOrGhost
local issecretvalue = issecretvalue

-- 项目引用
local COLOR = addonTable.COLOR
local UIInitFuncs = addonTable.UIInitFuncs
local Cell = addonTable.Cell

-- 本地配置
local cell
local frame = CreateFrame("Frame")

-- PartyTankUnit 会随小队状态刷新而重新赋值，使用时读取当前单位。
local function Refresh()
    if not cell then return end
    local color = COLOR.BLACK
    local unit = addonTable.PartyTankUnit
    if unit and UnitExists(unit) and UnitIsConnected(unit) and not UnitIsDeadOrGhost(unit) then
        local inRange = IsSpellInRange(34477, unit)
        if not issecretvalue(inRange) and inRange == nil then inRange = false end
        color = EvaluateColorFromBoolean(inRange, COLOR.WHITE, COLOR.BLACK)
    end
    cell:setCell(color)
end
addonTable.RefreshMisdirectionRange = Refresh
local elapsed = 0
frame:SetScript("OnUpdate", function(_, delta)
    elapsed = elapsed + delta
    if elapsed >= 0.1 then elapsed = elapsed % 0.1; Refresh() end
end)
insert(UIInitFuncs, function()
    cell = Cell:New({ x = 71 })
    Refresh()
end)
