-- 第 6 格显示符文能量比例：零为黑，满为白。
local addonName, addonTable = ...

-- Lua 内置方法
local insert                   = table.insert
local random = math.random

-- WoW API
local CreateFrame              = CreateFrame
local UnitPowerPercent         = UnitPowerPercent
local After                    = C_Timer.After
local RunicPower               = Enum.PowerType.RunicPower

-- 项目引用
local Cell                     = addonTable.Cell
local percentCurve             = addonTable.CURVE.percent
local UIInitFuncs              = addonTable.UIInitFuncs

-- 本地配置
local X                        = 6
local cell
local eventFrame               = CreateFrame("Frame")

local function update()
    if not cell then return end
    local color = UnitPowerPercent("player", RunicPower, false, percentCurve)
    cell:setCell(color)
end

local function initialize()
    cell = Cell:New({ x = X })
    update()
end

eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterUnitEvent("UNIT_POWER_UPDATE", "player")
eventFrame:RegisterUnitEvent("UNIT_MAXPOWER", "player")
eventFrame:RegisterUnitEvent("UNIT_DISPLAYPOWER", "player")
eventFrame:SetScript("OnEvent", function()
    After(0, update)
end)
insert(UIInitFuncs, initialize)

-- 事件和配置回调之外，每秒刷新一次显示状态。
local refreshElapsed = random()
eventFrame:SetScript("OnUpdate", function(_, elapsed)
    refreshElapsed = refreshElapsed + elapsed
    if refreshElapsed >= 1 then
        refreshElapsed = refreshElapsed % 1
        update()
    end
end)
