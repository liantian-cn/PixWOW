-- 宠物 Cell显示宠物预测生命值比例：零为黑，满为白。
local addonName, addonTable = ...

-- Lua 内置方法
local insert                   = table.insert
local random = math.random

-- WoW API
local CreateFrame              = CreateFrame
local UnitExists               = UnitExists
local UnitHealthPercent        = UnitHealthPercent
local After                    = C_Timer.After

-- 项目引用
local Cell                     = addonTable.Cell
local COLOR                    = addonTable.COLOR
local percentCurve             = addonTable.CURVE.percent
local UIInitFuncs              = addonTable.UIInitFuncs

-- 本地配置
local X = 65
local cell
local eventFrame               = CreateFrame("Frame")

local function update()
    if not cell then return end
    local color = COLOR.BLACK
    if UnitExists("pet") then
        color = UnitHealthPercent("pet", true, percentCurve)
    end
    cell:setCell(color)
end

local function initialize()
    cell = Cell:New({ x = X })
    update()
end

eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("UNIT_PET")
eventFrame:RegisterUnitEvent("UNIT_HEALTH", "pet")
eventFrame:RegisterUnitEvent("UNIT_MAXHEALTH", "pet")
eventFrame:RegisterUnitEvent("UNIT_HEAL_PREDICTION", "pet")
eventFrame:RegisterUnitEvent("UNIT_ABSORB_AMOUNT_CHANGED", "pet")
eventFrame:RegisterUnitEvent("UNIT_HEAL_ABSORB_AMOUNT_CHANGED", "pet")
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
