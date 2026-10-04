-- 治疗阈值使用普通整数灰度字节，数值直接表示百分数。
local addonName, addonTable = ...

-- Lua 内置方法
local insert = table.insert
local floor = math.floor
local max = math.max
local min = math.min
local random = math.random

-- WoW API
local CreateFrame = CreateFrame

-- 项目引用
local Config = addonTable.Config
local ConfigRows = addonTable.ConfigRows
local Cell = addonTable.Cell
local UIInitFuncs = addonTable.UIInitFuncs

-- 本地配置
local X = 59
local config = Config("word_of_glory_two_stacks_health_pct")
local cell
local eventFrame

config:set_default(75)
insert(ConfigRows, {
    type = "slider",
    name = "荣耀圣令：双层",
    tooltip = "闪耀之光2层、法力至少20%时的自身治疗血量阈值。",
    bind_config = config,
    default_value = 75,
    min_value = 55,
    max_value = 95,
    step = 1,
})
local function Refresh()
    if not cell then return end
    local value = floor(max(55, min(95, config:get_value())) + 0.5) / 255
    cell:setCellRGBA(value, value, value)
end
local function Initialize()
    cell = Cell:New({ x = X })
    Refresh()
end
config:register_callback(Refresh)
insert(UIInitFuncs, Initialize)

-- 保持原有初始化时序，此处才创建事件框架。
eventFrame = CreateFrame("Frame")

-- 事件和配置回调之外，每秒刷新一次显示状态。
local refreshElapsed = random()
eventFrame:SetScript("OnUpdate", function(_, elapsed)
    refreshElapsed = refreshElapsed + elapsed
    if refreshElapsed >= 1 then
        refreshElapsed = refreshElapsed % 1
        Refresh()
    end
end)
