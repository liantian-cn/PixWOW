-- 灰度字节直接表示打断进度阈值，默认30%，范围10%至90%。
local addonName, addonTable = ...

-- Lua 内置方法
local floor = math.floor
local max = math.max
local min = math.min
local insert = table.insert
local random = math.random
local tonumber = tonumber

-- WoW API
local CreateFrame = CreateFrame

-- 项目引用
local Config = addonTable.Config
local ConfigRows = addonTable.ConfigRows
local UIInitFuncs = addonTable.UIInitFuncs
local Cell = addonTable.Cell

-- 本地配置
local config = Config("interrupt_progress_threshold")
local cell
local eventFrame

config:set_default(30)

local function Refresh()
    if not cell then return end
    local value = floor(max(10, min(90, tonumber(config:get_value()) or 30)) + 0.5)
    local gray = value / 255
    cell:setCellRGBA(gray, gray, gray)
end

insert(ConfigRows, {
    type = "slider", name = "打断进度（%）",
    tooltip = "焦点、鼠标指向和目标的施法或引导已经过进度严格超过此百分比后才允许打断。",
    bind_config = config, default_value = 30, min_value = 10, max_value = 90, step = 1,
})
config:register_callback(Refresh)
insert(UIInitFuncs, function()
    cell = Cell:New({ x = 77 })
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
