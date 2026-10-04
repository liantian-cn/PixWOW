-- 玩家法力百分比；原生曲线直接消费资源比例。
local addonName, addonTable = ...

-- Lua 内置方法
local insert = table.insert
local random = math.random

-- WoW API
local Mana = Enum.PowerType.Mana
local After = C_Timer.After
local CreateFrame = CreateFrame
local UnitPowerPercent = UnitPowerPercent

-- 项目引用
local percentCurve = addonTable.CURVE.percent
local Cell = addonTable.Cell
local UIInitFuncs = addonTable.UIInitFuncs

-- 本地配置
local X = 49
local cell
local eventFrame = CreateFrame("Frame")

local function Refresh()
    if not cell then return end
    cell:setCell(UnitPowerPercent("player", Mana, false, percentCurve))
end
local function Initialize()
    cell = Cell:New({ x = X })
    Refresh()
end
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterUnitEvent("UNIT_POWER_UPDATE", "player")
eventFrame:RegisterUnitEvent("UNIT_MAXPOWER", "player")
eventFrame:RegisterUnitEvent("UNIT_DISPLAYPOWER", "player")
eventFrame:SetScript("OnEvent", function() After(0, Refresh) end)
insert(UIInitFuncs, Initialize)

-- 事件和配置回调之外，每秒刷新一次显示状态。
local refreshElapsed = random()
eventFrame:SetScript("OnUpdate", function(_, elapsed)
    refreshElapsed = refreshElapsed + elapsed
    if refreshElapsed >= 1 then
        refreshElapsed = refreshElapsed % 1
        Refresh()
    end
end)
