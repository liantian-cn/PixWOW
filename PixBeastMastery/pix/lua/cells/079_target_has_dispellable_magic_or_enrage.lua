-- 第 79 格显示目标的魔法或激怒增益：任一种存在为白色，否则为黑色。
-- 仅单位存在、可攻击且不可协助时显示；原生光环容器负责匹配，不读取秘密光环数据。
local addonName, addonTable = ...

-- Lua 内置方法
local insert = table.insert
local random = math.random

-- WoW API
local CreateFrame = CreateFrame
local After = C_Timer.After
local UnitExists = UnitExists
local UnitCanAttack = UnitCanAttack
local UnitCanAssist = UnitCanAssist

-- 项目引用
local CellBackplate = addonTable.CellBackplate
local COLOR = addonTable.COLOR
local SIZE = addonTable.SIZE
local FrameLevel = addonTable.FrameLevel
local UIInitFuncs = addonTable.UIInitFuncs

-- 本地配置
local X = 79
local UNIT_TOKEN = "target"
local CANDIDATE_FILTERS = { includeDispelTypes = { Magic = true, Enrage = true } }
local eventFrame = CreateFrame("Frame")
local container

local function RefreshVisibility()
    if not container then
        return
    end
    -- 如果 单位存在、可攻击且不可协助（与 Shigure 敌方驱散条件一致）
    -- => 显示增益容器；否则隐藏，由黑底表示 false
    container:SetShown(UnitExists(UNIT_TOKEN)
        and UnitCanAttack("player", UNIT_TOKEN)
        and not UnitCanAssist("player", UNIT_TOKEN))
end

local function Refresh()
    if not container then
        return
    end
    RefreshVisibility()
    -- 同 token 换人时重设过滤；此方法内部已经执行 UpdateAllAuras。
    container:SetAuraSlotCandidateFilters("aura", CANDIDATE_FILTERS)
end

local function Initialize()
    local backing = CellBackplate:New({ x = X })
    container = CreateFrame("AuraContainer", nil, backing.Frame, "CustomAuraContainerTemplate")
    container:SetAllPoints(backing.Frame)
    container:SetFrameLevel(FrameLevel.AuraContainer)
    container:SetUnit(UNIT_TOKEN)
    container:AddAuraSlot("aura", "HELPFUL", {
        candidateFilters = CANDIDATE_FILTERS,
        initializeFrame = function(frame)
            frame:SetSize(SIZE.CELL, SIZE.CELL)
            frame:SetPoint("TOPLEFT", container, "TOPLEFT")
            frame:SetFrameLevel(FrameLevel.AuraButton)
            local overlay = frame:CreateTexture(nil, "OVERLAY")
            overlay:SetAllPoints(frame)
            overlay:SetTexture("Interface\\Buttons\\WHITE8X8")
            overlay:SetVertexColor(COLOR.WHITE:GetRGBA())
        end,
    })
    Refresh()
end

eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
eventFrame:RegisterUnitEvent("UNIT_FACTION", "player", UNIT_TOKEN)
eventFrame:RegisterUnitEvent("UNIT_FLAGS", UNIT_TOKEN)
eventFrame:SetScript("OnEvent", function()
    After(0, Refresh)
end)
insert(UIInitFuncs, Initialize)

-- 光环由原生容器更新；每秒仅兜底刷新单位资格显隐。
local refreshElapsed = random()
eventFrame:SetScript("OnUpdate", function(_, elapsed)
    refreshElapsed = refreshElapsed + elapsed
    if refreshElapsed >= 1 then
        refreshElapsed = refreshElapsed % 1
        RefreshVisibility()
    end
end)
