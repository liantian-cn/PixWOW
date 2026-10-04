-- 玩家闪耀之光增益的层数，灰度字节直接表示计数。
-- 原生光环容器负责匹配与显隐，不读取秘密光环数据。
local addonName, addonTable = ...

-- Lua 内置方法
local insert                  = table.insert
local ipairs                  = ipairs
local error = error

-- WoW API
local CreateFrame             = CreateFrame
local After                   = C_Timer.After
local IsAddOnLoaded = C_AddOns.IsAddOnLoaded
local LoadAddOn = C_AddOns.LoadAddOn
local GameFontNormal = GameFontNormal

-- 项目引用
local Cell                    = addonTable.Cell
local COLOR                   = addonTable.COLOR
local SIZE                    = addonTable.SIZE
local FrameLevel              = addonTable.FrameLevel
local UIInitFuncs             = addonTable.UIInitFuncs
local CountFormatter = addonTable.CountFormatter

-- 本地配置
local X = 54
local AURA_IDS = { 327510 }
local eventFrame              = CreateFrame("Frame")
local container

local function Refresh()
    if not container then
        return
    end
    container:UpdateAllAuras()
end

local function Initialize()
    if not IsAddOnLoaded("Blizzard_AuraContainer") then
        LoadAddOn("Blizzard_AuraContainer")
    end
    if not IsAddOnLoaded("Blizzard_AuraContainer") then
        error("未能加载 Blizzard_AuraContainer，无法绑定光环")
    end
    local cell = Cell:New({ x = X })
    container = CreateFrame("AuraContainer", nil, cell.Frame, "CustomAuraContainerTemplate")
    container:SetAllPoints(cell.Frame)
    container:SetFrameLevel(FrameLevel.AuraContainer)
    container:SetUnit("player")

    local includeSpellIDs = {}
    for _, spellID in ipairs(AURA_IDS) do
        includeSpellIDs[spellID] = true
    end
    container:AddAuraSlot("aura", "HELPFUL|PLAYER", {
        candidateFilters = { includeSpellIDs = includeSpellIDs },
        initializeFrame = function(frame)
            frame:SetSize(SIZE.CELL, SIZE.CELL)
            frame:SetPoint("TOPLEFT", container, "TOPLEFT")
            frame:SetFrameLevel(FrameLevel.AuraButton)
            frame:SetClipsChildren(true)
            local fontPath = GameFontNormal:GetFont()
            local text = frame:CreateFontString(nil, "ARTWORK")
            text:SetFont(fontPath, SIZE.CELL_FONT_SIZE, "")
            text:SetPoint("CENTER", frame, "CENTER")
            text:SetJustifyH("CENTER")
            text:SetJustifyV("MIDDLE")
            text:SetShadowOffset(0, 0)
            text:SetShadowColor(0, 0, 0, 0)
            text:SetTextColor(1, 1, 1, 1)
            text:SetFixedColor(false)
            frame:SetApplicationCount(text, { formatter = CountFormatter })
        end,
    })
    Refresh()
end

eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:SetScript("OnEvent", function()
    After(0, Refresh)
end)
insert(UIInitFuncs, Initialize)
