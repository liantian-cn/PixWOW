-- 圣能按普通整数编码：灰度字节值直接等于圣能数量。
local addonName, addonTable = ...

-- Lua 内置方法
local insert = table.insert
local random = math.random
local error = error
local type = type

-- WoW API
local CreateFrame = CreateFrame
local After = C_Timer.After
local UnitPower = UnitPower
local issecretvalue = issecretvalue
local POWER_TYPE = Enum.PowerType.HolyPower

-- 项目引用
local Cell = addonTable.Cell
local UIInitFuncs = addonTable.UIInitFuncs

-- 本地配置
local X = 6
local cell
local eventFrame = CreateFrame("Frame")

local function Update()
    if not cell then return end
    local power = UnitPower("player", POWER_TYPE, false)
    if issecretvalue(power) then error("圣能返回秘密值") end
    if type(power) ~= "number" or power < 0 or power > 255 or power % 1 ~= 0 then
        error("圣能必须为 0..255 整数")
    end
    local value = power / 255
    cell:setCellRGBA(value, value, value)
end

local function Initialize()
    cell = Cell:New({ x = X })
    Update()
end

eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterUnitEvent("UNIT_POWER_UPDATE", "player")
eventFrame:RegisterUnitEvent("UNIT_MAXPOWER", "player")
eventFrame:RegisterUnitEvent("UNIT_DISPLAYPOWER", "player")
eventFrame:SetScript("OnEvent", function() After(0, Update) end)
insert(UIInitFuncs, Initialize)

-- 事件和配置回调之外，每秒刷新一次显示状态。
local refreshElapsed = random()
eventFrame:SetScript("OnUpdate", function(_, elapsed)
    refreshElapsed = refreshElapsed + elapsed
    if refreshElapsed >= 1 then
        refreshElapsed = refreshElapsed % 1
        Update()
    end
end)
