-- 手动怒火延后：本地计时、配置、命令和显示，不读取或拦截技能施放。
local addonName, addonTable = ...

-- Lua 内置方法
local insert = table.insert
local ceil = math.ceil
local floor = math.floor
local max = math.max
local min = math.min
local tonumber = tonumber
local print = print

-- WoW API
local CreateFrame = CreateFrame
local GetTime = GetTime
local GetSpellTexture = C_Spell.GetSpellTexture
local RequestLoadSpellData = C_Spell.RequestLoadSpellData
local UIParent = UIParent
local GameTooltip = GameTooltip

-- 项目引用
local Config = addonTable.Config
local ConfigRows = addonTable.ConfigRows
local CommandHandler = addonTable.CommandHandler
local UIInitFuncs = addonTable.UIInitFuncs
local Cell = addonTable.Cell

-- 本地配置
local config = Config("bestial_wrath_delay_duration")
local SPELL_ID = 19574
local cell, button, icon, background, bar, text
local events = CreateFrame("Frame")
local deadline, duration = 0, 0

-- 截止时间仅保存在内存；脱战保留，重载自然清空。
config:set_default(5)
local function ConfigDuration()
    return floor(max(3, min(15, tonumber(config:get_value()) or 5)) + 0.5)
end
insert(ConfigRows, {
    type = "slider", name = "狂野怒火延后时长（秒）",
    tooltip = "左键第三按钮或 /pix bwdelay 使用此时长；右键或 /pix bwdelay 0 取消。只影响后续触发，脱战保留计时，重载清空计时；配置持久保存。",
    bind_config = config, default_value = 5, min_value = 3, max_value = 15, step = 1,
})

local function Refresh()
    local remaining = max(0, deadline - GetTime())
    if cell then
        local gray = ceil(remaining * 10) / 255
        cell:setCellRGBA(gray, gray, gray)
    end
    if button then
        if remaining > 0 then
            background:SetColorTexture(1, 0.45, 0.05, 1)
            bar:SetMinMaxValues(0, duration)
            bar:SetValue(remaining)
            text:SetFormattedText("怒火延后 %.1f秒", remaining)
            bar:Show()
        else
            background:SetColorTexture(0.15, 0.15, 0.15, 1)
            bar:Hide()
        end
    end
end

local function SetDelay(seconds)
    duration = seconds
    deadline = GetTime() + seconds
    Refresh()
    if seconds == 0 then
        print("狂野怒火延后：已取消")
    else
        print("狂野怒火延后：" .. seconds .. "秒")
    end
end
CommandHandler["bwdelay"] = function(_, arguments)
    local seconds
    if arguments == "" then
        seconds = ConfigDuration()
    elseif arguments:match("^%d+$") then
        seconds = tonumber(arguments)
    end
    if not seconds or (seconds ~= 0 and (seconds < 3 or seconds > 15)) then
        print("用法：/pix bwdelay [3–15整数秒数]，省略使用配置，0取消；原计时不变")
        return
    end
    SetDelay(seconds)
end
-- 帮助函数会被其他模块包装，此处捕获已有帮助并追加本模块说明。
local previousHelp = addonTable.PrintCommandHelp
addonTable.PrintCommandHelp = function()
    previousHelp()
    print("/pix bwdelay [秒数] — 延后狂野怒火，整数3–15，省略使用配置，0取消")
end

local function RefreshIcon()
    if not icon then return end
    icon:Hide()
    local texture = GetSpellTexture(SPELL_ID)
    if texture and icon:SetTexture(texture) then icon:Show() end
end
events:RegisterEvent("SPELL_DATA_LOAD_RESULT")
events:SetScript("OnEvent", function(_, _, spellID, success)
    if spellID == SPELL_ID and success then RefreshIcon() end
end)

insert(UIInitFuncs, function()
    cell = Cell:New({ x = 67 })
    button = CreateFrame("Button", addonName .. "BestialWrathDelayFrame", UIParent)
    button:SetSize(66, 66)
    button:SetFrameStrata("DIALOG")
    -- 两个锚点在前序 UI 初始化回调中创建，不能在文件加载时缓存。
    button:SetPoint("TOPLEFT", addonTable.FinishingFrame, "TOPRIGHT", 0, 0)
    button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    background = button:CreateTexture(nil, "BACKGROUND")
    background:SetAllPoints(button)
    icon = button:CreateTexture(nil, "ARTWORK")
    icon:SetSize(60, 60)
    icon:SetPoint("CENTER")
    button:SetScript("OnClick", function(_, mouseButton)
        if mouseButton == "RightButton" then SetDelay(0)
        else SetDelay(ConfigDuration()) end
    end)
    button:SetScript("OnEnter", function()
        GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
        GameTooltip:SetText("狂野怒火延后")
        GameTooltip:AddLine("左键：从现在延后" .. ConfigDuration() .. "秒；右键：取消。", 1, 1, 1, true)
        GameTooltip:AddLine("重复触发重设截止时间，可缩短；仅暂停自动怒火及前置药水、饰品。到期恢复正常判断，不强制施放，也不拦截手动怒火。", 1, 1, 1, true)
        GameTooltip:AddLine("脱战保留，重载清空。Shift+左键拖动第一个按钮可整体移动。", 1, 1, 1, true)
        GameTooltip:Show()
    end)
    button:SetScript("OnLeave", function() GameTooltip:Hide() end)
    bar = CreateFrame("StatusBar", nil, button)
    bar:SetSize(198, 18)
    bar:SetPoint("TOPLEFT", addonTable.AttackModeFrame, "BOTTOMLEFT", 0, -4)
    bar:SetStatusBarTexture("Interface\\Buttons\\WHITE8X8")
    bar:SetStatusBarColor(1, 0.45, 0.05)
    local barBackground = bar:CreateTexture(nil, "BACKGROUND")
    barBackground:SetAllPoints(bar)
    barBackground:SetColorTexture(0.1, 0.1, 0.1, 1)
    text = bar:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    text:SetPoint("CENTER")
    RequestLoadSpellData(SPELL_ID)
    RefreshIcon()
    Refresh()
end)

-- 同一个刷新入口更新像素、高亮和倒计时；到期静默清零。
local elapsedSinceRefresh = 0
events:SetScript("OnUpdate", function(_, elapsed)
    elapsedSinceRefresh = elapsedSinceRefresh + elapsed
    if elapsedSinceRefresh >= 0.1 then
        elapsedSinceRefresh = elapsedSinceRefresh % 0.1
        Refresh()
    end
end)
