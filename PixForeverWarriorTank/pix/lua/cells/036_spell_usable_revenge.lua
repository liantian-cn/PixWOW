-- 最高已学等级复仇的usable：原生布尔颜色显示，白真黑假。
local addonName, addonTable = ...

-- Lua 内置方法
local insert                   = table.insert
local random                   = math.random
local ipairs                   = ipairs

-- WoW API
local CreateFrame              = CreateFrame
local After                    = C_Timer.After
local IsSpellInSpellBook       = C_SpellBook.IsSpellInSpellBook
local IsSpellUsable = C_Spell.IsSpellUsable
local EvaluateColorFromBoolean = C_CurveUtil.EvaluateColorFromBoolean

-- 项目引用
local COLOR                    = addonTable.COLOR
local UIInitFuncs              = addonTable.UIInitFuncs
local Cell                     = addonTable.Cell

-- 本地配置
local X = 36
local SPELL_IDS = { 25288, 11601, 11600, 7379, 6574, 6572 }
local eventFrame               = CreateFrame("Frame")
local cell
local selectedSpellID

local function SelectSpell()
    selectedSpellID = nil
    for _, spellID in ipairs(SPELL_IDS) do
        if IsSpellInSpellBook(spellID) then
            selectedSpellID = spellID
            return
        end
    end
end

local function Refresh()
    if not cell then return end
    local color = COLOR.BLACK
    if selectedSpellID then
        color = EvaluateColorFromBoolean(IsSpellUsable(selectedSpellID), COLOR.WHITE, COLOR.BLACK)
    end
    cell:setCell(color)
end

local function Initialize()
    cell = Cell:New({ x = X })
    SelectSpell()
    Refresh()
end

eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("SPELLS_CHANGED")
eventFrame:RegisterEvent("SPELL_UPDATE_USABLE")
eventFrame:SetScript("OnEvent", function(_, event)
    After(0, function()
        if event == "PLAYER_ENTERING_WORLD" or event == "SPELLS_CHANGED" then SelectSpell() end
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
