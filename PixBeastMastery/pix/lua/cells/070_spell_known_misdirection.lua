local addonName, addonTable = ...

-- Lua 内置方法
local insert = table.insert
local random = math.random

-- WoW API
local EvaluateColorFromBoolean = C_CurveUtil.EvaluateColorFromBoolean
local IsSpellInSpellBook = C_SpellBook.IsSpellInSpellBook
local IsSpellKnown = C_SpellBook.IsSpellKnown
local After = C_Timer.After
local CreateFrame = CreateFrame

-- 项目引用
local COLOR = addonTable.COLOR
local UIInitFuncs = addonTable.UIInitFuncs
local Cell = addonTable.Cell

-- 本地配置
local cell
local frame = CreateFrame("Frame")

local function Refresh()
    if cell then cell:setCell(EvaluateColorFromBoolean(IsSpellInSpellBook(34477) or IsSpellKnown(34477), COLOR.WHITE, COLOR.BLACK)) end
end
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("SPELLS_CHANGED")
frame:SetScript("OnEvent", function() After(0, Refresh) end)
insert(UIInitFuncs, function()
    cell = Cell:New({ x = 70 })
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
