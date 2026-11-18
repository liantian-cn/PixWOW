-- 只统计可观察姓名板；秘密或 nil 射程不计入，不代表全部附近敌人。
local addonName, addonTable = ...

-- Lua 内置方法
local insert = table.insert
local random = math.random
local ipairs = ipairs

-- WoW API
local CreateFrame = CreateFrame
local After = C_Timer.After
local IsSpellInRange = C_Spell.IsSpellInRange
local IsSpellInSpellBook = C_SpellBook.IsSpellInSpellBook
local issecretvalue = issecretvalue
local UnitExists = UnitExists
local UnitCanAttack = UnitCanAttack
local UnitIsDeadOrGhost = UnitIsDeadOrGhost
local UnitAffectingCombat = UnitAffectingCombat

-- 项目引用
local Cell = addonTable.Cell
local UIInitFuncs = addonTable.UIInitFuncs

-- 本地配置
local X = 31
local SPELL_IDS = { 11597, 11596, 8380, 7405, 7386 }
local COMBAT_ONLY = true
local NAMEPLATE_LIMIT = 40
local UPDATE_INTERVAL = 1
local cell
local eventFrame = CreateFrame("Frame")

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

local function Update()
    if not cell then return end
    if not selectedSpellID then
        cell:clearCell()
        return
    end

    local count = 0
    for index = 1, NAMEPLATE_LIMIT do
        local unit = "nameplate" .. index
        if UnitExists(unit)
            and UnitCanAttack("player", unit)
            and not UnitIsDeadOrGhost(unit)
            and (not COMBAT_ONLY or UnitAffectingCombat(unit))
        then
            local inRange = IsSpellInRange(selectedSpellID, unit)
            if not issecretvalue(inRange) and inRange == true then
                count = count + 1
            end
        end
    end
    local value = count / NAMEPLATE_LIMIT
    cell:setCellRGBA(value, value, value)
end

local function Initialize()
    cell = Cell:New({ x = X })
    SelectSpell()
    Update()
end

eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("SPELLS_CHANGED")
eventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
eventFrame:RegisterEvent("NAME_PLATE_UNIT_ADDED")
eventFrame:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
eventFrame:SetScript("OnEvent", function(_, event)
    After(0, function()
        if event == "PLAYER_ENTERING_WORLD" or event == "SPELLS_CHANGED" then
            SelectSpell()
        end
        Update()
    end)
end)

local elapsedTime = -random() * UPDATE_INTERVAL
eventFrame:SetScript("OnUpdate", function(_, elapsed)
    elapsedTime = elapsedTime + elapsed
    if elapsedTime >= UPDATE_INTERVAL then
        elapsedTime = elapsedTime % UPDATE_INTERVAL
        Update()
    end
end)
insert(UIInitFuncs, Initialize)
