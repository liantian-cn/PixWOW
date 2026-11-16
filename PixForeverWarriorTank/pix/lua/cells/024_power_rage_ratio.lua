-- 怒气比例；绝对点数由 Python 结合配置上限还原。
local addonName, addonTable = ...

-- Lua 内置方法
local insert = table.insert
local random = math.random
local ipairs = ipairs

-- WoW API
local After = C_Timer.After
local Rage = Enum.PowerType.Rage
local CreateFrame = CreateFrame
local UnitPowerPercent = UnitPowerPercent

-- 项目引用
local CURVE = addonTable.CURVE
local UIInitFuncs = addonTable.UIInitFuncs
local Cell = addonTable.Cell

-- 本地配置
local cell
local frame = CreateFrame("Frame")

local function Refresh()
    if cell then
        cell:setCell(UnitPowerPercent("player", Rage, false, CURVE.percent))
    end
end
for _, event in ipairs({ "PLAYER_ENTERING_WORLD", "UNIT_POWER_UPDATE", "UNIT_MAXPOWER", "UNIT_DISPLAYPOWER" }) do
    frame:RegisterEvent(event)
end
frame:SetScript("OnEvent", function() After(0, Refresh) end)
insert(UIInitFuncs, function()
    cell = Cell:New({ x = 24 })
    Refresh()
end)

-- 事件和配置回调之外，每秒刷新一次显示状态。
local refreshElapsed = random()
frame:SetScript("OnUpdate", function(_, elapsed)
    refreshElapsed = refreshElapsed + elapsed
    if refreshElapsed >= 1 then
        refreshElapsed = refreshElapsed % 1
        Refresh()
    end
end)
