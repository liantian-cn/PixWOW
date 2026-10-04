-- 自动清毒开关：通过现有面板 combo 配置，默认开启。
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
local X = 66
local config = Config("auto_cleanse_enabled")
local cell
local eventFrame

config:set_default(true)

insert(ConfigRows, {
    type = "combo",
    name = "自动清毒",
    tooltip = "战斗中自动清除自身可驱散的中毒和疾病，优先级仅在祝福之锤之前；无敌对目标时仍可清毒。",
    bind_config = config,
    default_value = true,
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
