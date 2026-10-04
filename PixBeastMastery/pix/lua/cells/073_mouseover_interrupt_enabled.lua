-- 鼠标指向打断开关：默认开启，配置持久化保存。
local addonName, addonTable = ...

-- Lua 内置方法
local insert = table.insert
local random = math.random

-- WoW API
local CreateFrame = CreateFrame

-- 项目引用
local Config = addonTable.Config
local COLOR = addonTable.COLOR
local ConfigRows = addonTable.ConfigRows
local UIInitFuncs = addonTable.UIInitFuncs
local Cell = addonTable.Cell

-- 本地配置
local config = Config("mouseover_interrupt_enabled")
local cell
local eventFrame

config:set_default(true)

local function Refresh()
    if not cell then return end
    cell:setCell(config:get_value() == true and COLOR.WHITE or COLOR.BLACK)
end

insert(ConfigRows, {
    type = "combo", name = "鼠标指向打断",
    tooltip = "允许打断鼠标指向的敌人；优先级低于焦点、高于目标，共用打断进度阈值与黑名单。",
    bind_config = config, default_value = true,
    options = { { k = false, v = "否" }, { k = true, v = "是" } },
})
config:register_callback(Refresh)
insert(UIInitFuncs, function()
    cell = Cell:New({ x = 73 })
    Refresh()
end)

-- 保留原初始化时序；文件头只提前声明。
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
