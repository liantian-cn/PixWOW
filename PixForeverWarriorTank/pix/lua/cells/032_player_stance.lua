local addonName, addonTable = ...

-- Lua 内置方法
local insert = table.insert
local random = math.random

-- WoW API
local CreateFrame = CreateFrame
local After = C_Timer.After
local GetShapeshiftFormID = GetShapeshiftFormID

-- 项目引用
local Cell = addonTable.Cell
local UIInitFuncs = addonTable.UIInitFuncs

-- 本地配置
local cell
local events = CreateFrame("Frame")
local function Refresh()
    if not cell then return end
    local value = GetShapeshiftFormID() or 0
    local gray = value / 255
    cell:setCellRGBA(gray, gray, gray)
end
insert(UIInitFuncs, function()
    cell = Cell:New({ x = 32 })
    Refresh()
end)
events:RegisterEvent("PLAYER_ENTERING_WORLD")
events:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
events:RegisterEvent("UPDATE_SHAPESHIFT_FORMS")
events:SetScript("OnEvent", function() After(0, Refresh) end)
local elapsedTime = -random()
events:SetScript("OnUpdate", function(_, elapsed)
    elapsedTime = elapsedTime + elapsed
    if elapsedTime >= 1 then
        elapsedTime = elapsedTime % 1
        Refresh()
    end
end)
