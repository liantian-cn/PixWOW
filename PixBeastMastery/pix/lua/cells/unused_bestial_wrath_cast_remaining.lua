-- 第 88 格显示玩家成功施放狂野怒火后的本地 4 秒窗口，不是真实光环剩余时间。
-- RGB 字节值为向上取整的剩余十分之一秒（0～40）。
local addonName, addonTable = ...

-- Lua 内置方法
local insert = table.insert
local ceil = math.ceil
local min = math.min
local max = math.max

-- WoW API
local CreateFrame = CreateFrame
local GetTime = GetTime
local issecretvalue = issecretvalue

-- 项目引用
local Cell = addonTable.Cell
local UIInitFuncs = addonTable.UIInitFuncs

-- 本地配置
local X = 88
local SPELL_ID = 19574
local DURATION = 4
local deadline = 0
local elapsedTime = 0
local cell
local eventFrame = CreateFrame("Frame")

local function Refresh()
    if not cell then return end
    local remaining = max(0, min(DURATION, deadline - GetTime()))
    local brightness = ceil(remaining * 10) / 255
    cell:setCellRGBA(brightness, brightness, brightness)
end

local function Initialize()
    cell = Cell:New({ x = X })
    Refresh()
end

eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", "player")
eventFrame:SetScript("OnEvent", function(_, event, unitTarget, castGUID, spellID)
    -- 如果 进入世界
    -- => 清除本地窗口；重载时也从零开始
    if event == "PLAYER_ENTERING_WORLD" then
        deadline = 0
    else
        -- 如果 玩家施法成功事件的法术 ID 是秘密值、缺失或不是狂野怒火
        -- => 忽略该事件，保留已有计时
        if issecretvalue(spellID) or spellID ~= SPELL_ID then return end
        -- 如果 玩家成功施放狂野怒火且法术 ID 可读
        -- => 从本次事件重新开始 4 秒窗口
        deadline = GetTime() + DURATION
    end
    elapsedTime = 0
    Refresh()
end)
eventFrame:SetScript("OnUpdate", function(_, elapsed)
    elapsedTime = elapsedTime + elapsed
    if elapsedTime >= 0.1 then
        elapsedTime = elapsedTime % 0.1
        Refresh()
    end
end)
insert(UIInitFuncs, Initialize)
