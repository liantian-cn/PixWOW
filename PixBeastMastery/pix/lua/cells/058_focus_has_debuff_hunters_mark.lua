-- 第 58 格显示焦点的自身猎人印记减益（257584）：存在为白色，否则为黑色。
-- 原生光环容器负责匹配与显隐，不读取秘密光环数据。
local addonName, addonTable = ...

-- Lua 内置方法
local insert = table.insert
local random = math.random

-- WoW API
local CreateFrame = CreateFrame
local After = C_Timer.After
local UnitExists = UnitExists
local UnitCanAssist = UnitCanAssist

-- 项目引用
local CellBackplate = addonTable.CellBackplate
local COLOR = addonTable.COLOR
local SIZE = addonTable.SIZE
local FrameLevel = addonTable.FrameLevel
local UIInitFuncs = addonTable.UIInitFuncs

-- 本地配置
local X = 58
local UNIT_TOKEN = "focus"
local AURA_ID = 257584
local eventFrame = CreateFrame("Frame")
local container

local function RefreshVisibility()
    if not container then
        return
    end
    -- 如果 单位存在且不可协助（忽略免疫和不可交互限制）
    -- => 显示自身减益容器；否则隐藏，由黑底表示无印记
    container:SetShown(UnitExists(UNIT_TOKEN) and not UnitCanAssist("player", UNIT_TOKEN, true, true))
end

local function Refresh()
    if not container then
        return
    end
    RefreshVisibility()
    container:UpdateAllAuras()
end

local function Initialize()
    local backing = CellBackplate:New({ x = X })
    container = CreateFrame("AuraContainer", nil, backing.Frame, "CustomAuraContainerTemplate")
    container:SetAllPoints(backing.Frame)
    container:SetFrameLevel(FrameLevel.AuraContainer)
    container:SetUnit(UNIT_TOKEN)
    container:AddAuraSlot("aura", "HARMFUL|PLAYER", {
        candidateFilters = { includeSpellIDs = { [AURA_ID] = true } },
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
eventFrame:RegisterEvent("PLAYER_FOCUS_CHANGED")
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
