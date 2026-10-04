-- 第 7 格编码可用符文数量：RGB 通道值为 0–6。
local addonName, addonTable = ...

-- Lua 内置方法
local insert                   = table.insert
local random = math.random

-- WoW API
local CreateFrame              = CreateFrame
local CreateColor              = CreateColor
local GetRuneCooldown          = GetRuneCooldown
local After                    = C_Timer.After

-- 项目引用
local Cell                     = addonTable.Cell
local UIInitFuncs              = addonTable.UIInitFuncs

-- 本地配置
local X                        = 7
local runeColors               = {}
local cell
local eventFrame               = CreateFrame("Frame")

for count = 0, 6 do
    local brightness = count / 255
    runeColors[count] = CreateColor(brightness, brightness, brightness, 1)
end

local function update()
    if not cell then return end
    local readyRunes = 0
    for runeIndex = 1, 6 do
        local _, _, runeReady = GetRuneCooldown(runeIndex)
        if runeReady then readyRunes = readyRunes + 1 end
    end
    local color = runeColors[readyRunes]
    cell:setCell(color)
end

local function initialize()
    cell = Cell:New({ x = X })
    update()
end

eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("RUNE_POWER_UPDATE")
eventFrame:SetScript("OnEvent", function()
    After(0, update)
end)
insert(UIInitFuncs, initialize)

-- 事件和配置回调之外，每秒刷新一次显示状态。
local refreshElapsed = random()
eventFrame:SetScript("OnUpdate", function(_, elapsed)
    refreshElapsed = refreshElapsed + elapsed
    if refreshElapsed >= 1 then
        refreshElapsed = refreshElapsed % 1
        update()
    end
end)
