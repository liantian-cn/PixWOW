-- 目标打断默认关闭；焦点没有开关，始终参与打断判断。
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
local config = Config("target_interrupt_enabled")
local cell
local eventFrame

config:set_default(false)

local function Refresh()
    if not cell then return end
    cell:setCell(config:get_value() == true and COLOR.WHITE or COLOR.BLACK)
end

insert(ConfigRows, {
    type = "combo", name = "目标打断",
    tooltip = "允许打断当前目标；优先级低于焦点，共用打断进度阈值与黑名单。关闭不影响焦点打断。",
    bind_config = config, default_value = false,
    options = { { k = false, v = "否" }, { k = true, v = "是" } },
})
config:register_callback(Refresh)
insert(UIInitFuncs, function()
    cell = Cell:New({ x = 70 })
    Refresh()
end)

eventFrame = CreateFrame("Frame")

-- 配置回调之外，每秒刷新一次显示状态。
local refreshElapsed = random()
eventFrame:SetScript("OnUpdate", function(_, elapsed)
    refreshElapsed = refreshElapsed + elapsed
    if refreshElapsed >= 1 then
        refreshElapsed = refreshElapsed % 1
        Refresh()
    end
end)
