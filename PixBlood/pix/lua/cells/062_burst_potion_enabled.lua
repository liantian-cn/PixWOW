-- 独立爆发药水开关：通过现有面板 combo 配置，默认关闭。
local addonName, addonTable = ...

-- Lua 内置方法
local insert = table.insert
local random = math.random

-- WoW API
local CreateFrame = CreateFrame

-- 项目引用
local Cell = addonTable.Cell
local COLOR = addonTable.COLOR
local Config = addonTable.Config
local ConfigRows = addonTable.ConfigRows
local UIInitFuncs = addonTable.UIInitFuncs

-- 本地配置
local X = 62
local config = Config("burst_potion_enabled")
local cell
local eventFrame

config:set_default(false)

insert(ConfigRows, {
    type = "combo",
    name = "爆发药水",
    tooltip = "独立控制轮转使用圣光潜力，不随爆发开关联动。",
    bind_config = config,
    default_value = false,
    options = {
        { k = false, v = "关闭" },
        { k = true, v = "开启" },
    },
})

local function Refresh()
    if not cell then return end
    cell:setCell(config:get_value() == true and COLOR.WHITE or COLOR.BLACK)
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
