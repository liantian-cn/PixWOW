-- 灰度字节直接表示收尾血量阈值；设置持久化，脱战和重载不重置。
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
local config = Config("finishing_health_threshold")
local cell
local eventFrame

config:set_default(20)

local function Refresh()
    if not cell then return end
    local value = floor(max(0, min(50, tonumber(config:get_value()) or 20)) + 0.5)
    local gray = value / 255
    cell:setCellRGBA(gray, gray, gray)
end

insert(ConfigRows, {
    type = "slider", name = "收尾血量阈值（%）",
    tooltip = "仅影响自动收尾：非遭遇战且目标血量严格低于此百分比时不使用狂野怒火。0表示自动模式不收尾。脱战及重载保留设置。",
    bind_config = config, default_value = 20, min_value = 0, max_value = 50, step = 5,
})
config:register_callback(Refresh)
insert(UIInitFuncs, function()
    cell = Cell:New({ x = 18 })
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
