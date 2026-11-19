-- 使用共享非线性剩余时间曲线显示冷却，就绪白色，不可用黑色。
local addonName, addonTable = ...

-- Lua 内置方法
local insert                   = table.insert
local random                   = math.random

-- WoW API
local CreateFrame              = CreateFrame
local After                    = C_Timer.After
local IsSpellInSpellBook       = C_SpellBook.IsSpellInSpellBook
local GetSpellCooldownDuration = C_Spell.GetSpellCooldownDuration

-- 项目引用
local COLOR                    = addonTable.COLOR
local UIInitFuncs              = addonTable.UIInitFuncs
local Cell                     = addonTable.Cell
local remainingCurve           = addonTable.CURVE.SpellColddownRemaining

-- 本地配置
local X = 48
local SPELL_ID = 402927
local eventFrame               = CreateFrame("Frame")
local cell
local spellKnown

local function Refresh()
    if not cell then return end
    local color = COLOR.BLACK
    if spellKnown then
        local duration = GetSpellCooldownDuration(SPELL_ID, true)
        if duration then color = duration:EvaluateRemainingDuration(remainingCurve) end
    end
    cell:setCell(color)
end

local function Initialize()
    cell = Cell:New({ x = X })
    spellKnown = IsSpellInSpellBook(SPELL_ID)
    Refresh()
end

eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("SPELLS_CHANGED")
eventFrame:RegisterEvent("SPELL_UPDATE_COOLDOWN")
eventFrame:SetScript("OnEvent", function(_, event)
    After(0, function()
        if event == "PLAYER_ENTERING_WORLD" or event == "SPELLS_CHANGED" then spellKnown = IsSpellInSpellBook(SPELL_ID) end
        Refresh()
    end)
end)
local elapsedTime = -random() * 0.1
eventFrame:SetScript("OnUpdate", function(_, elapsed)
    elapsedTime = elapsedTime + elapsed
    if elapsedTime >= 0.1 then
        elapsedTime = elapsedTime % 0.1
        Refresh()
    end
end)
insert(UIInitFuncs, Initialize)
