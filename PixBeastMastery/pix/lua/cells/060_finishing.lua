-- 配置、命令、像素及独立状态按钮均由本文件管理。
local addonName, addonTable = ...

-- Lua 内置方法
local insert = table.insert
local random = math.random
local ipairs = ipairs
local print = print
local type = type

-- WoW API
local After = C_Timer.After
local CreateFrame = CreateFrame
local IsShiftKeyDown = IsShiftKeyDown
local UIParent = UIParent

-- 项目引用
local Config = addonTable.Config
local ConfigRows = addonTable.ConfigRows
local CommandHandler = addonTable.CommandHandler
local UIInitFuncs = addonTable.UIInitFuncs
local Cell = addonTable.Cell

-- 本地配置
local config = Config("finishing")
local position = Config("finishing_position")
local iconPath = "Interface/AddOns/" .. addonName .. "/ui/status/"
local states
local options
local cell, button, icon, background
local events

-- PrintCommandHelp 会被后续文件包装，命令执行时读取当前函数；previousHelp 在原位置捕获旧函数。
-- AttackModeFrame 在 UI 初始化时才创建，初始化及拖动回调中读取当前对象。
config:set_default(0)
config:set_value(0) -- 每次加载恢复自动，按钮位置单独保存。
-- 保留原初始化时序；文件头只提前声明。
states = {
    { value = 0, label = "自动", icon = iconPath .. "finishing_auto.tga", color = { 0.15, 0.65, 0.35 } },
    { value = 10, label = "残血持续爆发", icon = iconPath .. "finishing_off.tga", color = { 0.15, 0.45, 0.85 } },
    { value = 20, label = "残血不爆发", icon = iconPath .. "finishing_on.tga", color = { 0.95, 0.45, 0.1 } }
}
-- 保留原初始化时序；文件头只提前声明。
options = {}
for _, state in ipairs(states) do options[#options + 1] = { k = state.value, v = state.label } end
insert(ConfigRows, {
    type = "combo", name = "残血收尾模式", tooltip = "自动：非遭遇战且目标血量低于阈值时不使用狂野怒火。残血持续爆发：不收尾，狂野怒火仍按原有施放条件使用。残血不爆发：始终禁用狂野怒火，不受血量阈值影响，包括遭遇战；不影响饰品和药水。左击按自动、残血持续爆发、残血不爆发循环；Shift+左键拖动攻击模式时整体移动。模式变化时在聊天框打印，脱战及重载恢复自动。",
    bind_config = config, default_value = 0, options = options,
})
local function CurrentState()
    local value = config:get_value()
    for index, state in ipairs(states) do if state.value == value then return state, index end end
    return states[1], 1
end
local function CycleState()
    local _, index = CurrentState()
    config:set_value(states[index % #states + 1].value)
end
-- 初始化已恢复自动；只在有效模式发生变化时打印，周期刷新和重复写入不刷屏。
local lastMode = 0
local function Refresh()
    local state = CurrentState()
    local value = state.value
    if value ~= lastMode then
        lastMode = value
        print("残血收尾模式：" .. state.label)
    end
    if cell then
        local gray = value / 255
        cell:setCellRGBA(gray, gray, gray)
    end
    if button then
        icon:SetTexture(state.icon)
        background:SetColorTexture(state.color[1] * 0.3, state.color[2] * 0.3, state.color[3] * 0.3, 1)
    end
end
config:register_callback(Refresh)
CommandHandler["end"] = function(_, arguments)
    if arguments == "auto" then config:set_value(0)
    elseif arguments == "off" then config:set_value(10)
    elseif arguments == "on" then config:set_value(20)
    elseif arguments == "toggle" then CycleState()
    else addonTable.PrintCommandHelp() end
end
local previousHelp = addonTable.PrintCommandHelp
addonTable.PrintCommandHelp = function()
    previousHelp()
    print("/pix end auto|off|on|toggle — 残血收尾模式，toggle按自动、残血持续爆发、残血不爆发循环；残血不爆发始终禁用狂野怒火，不受血量影响")
end

-- 保留原初始化时序；文件头只提前声明。
events = CreateFrame("Frame")
events:RegisterEvent("PLAYER_REGEN_ENABLED")
events:SetScript("OnEvent", function() config:set_value(0) end)
insert(UIInitFuncs, function()
    cell = Cell:New({ x = 60 })
    button = CreateFrame("Button", addonName .. "FinishingFrame", UIParent)
    addonTable.FinishingFrame = button
    -- 控制按钮使用原生 UI 单位，不参与像素采样区的分辨率换算。
    button:SetSize(66, 66)
    button:SetFrameStrata("DIALOG")
    button:SetClampedToScreen(true)
    button:SetMovable(true)
    button:RegisterForClicks("LeftButtonUp")
    button:RegisterForDrag("LeftButton")
    local function PlaceSaved()
        local saved = position:get_value()
        if type(saved) == "table" and type(saved.x) == "number" and type(saved.y) == "number" then
            button:SetPoint("CENTER", UIParent, "CENTER", saved.x, saved.y)
        else
            button:SetPoint("CENTER", UIParent, "CENTER", 0, -144)
        end
    end
    local anchor = addonTable.AttackModeFrame
    if anchor then
        button:SetPoint("TOPLEFT", anchor, "TOPRIGHT", 0, 0)
    else
        PlaceSaved()
    end
    background = button:CreateTexture(nil, "BACKGROUND")
    background:SetAllPoints(button)
    icon = button:CreateTexture(nil, "ARTWORK")
    icon:SetSize(60, 60)
    icon:SetPoint("TOP", button, "TOP", 0, -3)
    local dragging = false
    button:SetScript("OnDragStart", function()
    if addonTable.AttackModeFrame then return end
        if IsShiftKeyDown() then dragging = true; button:StartMoving() end
    end)
    button:SetScript("OnDragStop", function()
        if not dragging then return end
        button:StopMovingOrSizing()
        local x, y = button:GetCenter()
        local centerX, centerY = UIParent:GetCenter()
        position:set_value({ x = x - centerX, y = y - centerY })
        -- 保留本帧标记，防止拖动结束被识别为点击。
        After(0, function() dragging = false end)
    end)
    button:SetScript("OnClick", function()
        if dragging or IsShiftKeyDown() then return end
        CycleState()
    end)
    Refresh()
end)

-- 事件和配置回调之外，每秒刷新一次显示状态。
local refreshElapsed = random()
events:SetScript("OnUpdate", function(_, elapsed)
    refreshElapsed = refreshElapsed + elapsed
    if refreshElapsed >= 1 then
        refreshElapsed = refreshElapsed % 1
        Refresh()
    end
end)
