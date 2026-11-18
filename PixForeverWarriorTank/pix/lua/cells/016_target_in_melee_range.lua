-- 技能射程；无单位或普通 nil 结果显示黑色。
local addonName, addonTable = ...

-- Lua 内置方法
local insert = table.insert
local random = math.random
local ipairs = ipairs

-- WoW API
local CreateFrame = CreateFrame
local After = C_Timer.After
local EvaluateColorFromBoolean = C_CurveUtil.EvaluateColorFromBoolean
local UnitExists = UnitExists
local IsSpellInRange = C_Spell.IsSpellInRange
local IsSpellInSpellBook = C_SpellBook.IsSpellInSpellBook
local issecretvalue = issecretvalue

-- 项目引用
local Cell = addonTable.Cell
local COLOR = addonTable.COLOR
local UIInitFuncs = addonTable.UIInitFuncs

-- 本地配置
local X = 16
local SPELL_IDS = { 11597, 11596, 8380, 7405, 7386 }
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
    local inRange = IsSpellInRange(selectedSpellID, "target")
    if not issecretvalue(inRange) and inRange == nil then
        inRange = false
    end
    local rangeColor = EvaluateColorFromBoolean(inRange, COLOR.WHITE, COLOR.BLACK)
    local color = EvaluateColorFromBoolean(UnitExists("target"), rangeColor, COLOR.BLACK)
    cell:setCell(color)
end

local function Initialize()
    cell = Cell:New({ x = X })
    SelectSpell()
    Update()
end

eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
eventFrame:RegisterEvent("SPELLS_CHANGED")

eventFrame:SetScript("OnEvent", function(_, event)
    After(0, function()
        if event == "PLAYER_ENTERING_WORLD" or event == "SPELLS_CHANGED" then
            SelectSpell()
        end
        Update()
    end)
end)

local elapsedTime = -random() * 0.1
eventFrame:SetScript("OnUpdate", function(_, elapsed)
    elapsedTime = elapsedTime + elapsed
    if elapsedTime >= 0.1 then
        elapsedTime = elapsedTime % 0.1
        Update()
    end
end)
insert(UIInitFuncs, Initialize)
