local addonName, addonTable = ...

-- Lua 内置方法
local insert = table.insert
local random = math.random

-- WoW API
local EvaluateColorFromBoolean = C_CurveUtil.EvaluateColorFromBoolean
local After = C_Timer.After
local CreateFrame = CreateFrame
local IsInGroup = IsInGroup
local IsInRaid = IsInRaid

-- 项目引用
local COLOR = addonTable.COLOR
local UIInitFuncs = addonTable.UIInitFuncs
local Cell = addonTable.Cell

-- 本地配置
local cell
local frame = CreateFrame("Frame")

local function Refresh()
    if cell then cell:setCell(EvaluateColorFromBoolean(IsInGroup() and not IsInRaid(), COLOR.WHITE, COLOR.BLACK)) end
end
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("GROUP_ROSTER_UPDATE")
frame:SetScript("OnEvent", function() After(0, Refresh) end)
insert(UIInitFuncs, function()
    cell = Cell:New({ x = 69 })
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
