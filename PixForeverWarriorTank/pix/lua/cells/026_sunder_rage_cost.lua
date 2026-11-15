-- 配置上限为普通整数；灰度字节直接表示12至15点。
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
local config = Config("sunder_rage_cost")
local cell
local eventFrame

config:set_default(15)
local function Refresh()
    if not cell then return end
    local value = floor(max(12, min(15, tonumber(config:get_value()) or 15)) + 0.5)
    local gray = value / 255
    cell:setCellRGBA(gray, gray, gray)
end
insert(ConfigRows, {
    type = "slider", name = "破甲所需怒气", tooltip = "按天赋设置破甲攻击所需怒气。",
    bind_config = config, default_value = 15, min_value = 12, max_value = 15, step = 1,
})
config:register_callback(Refresh)
insert(UIInitFuncs, function()
    cell = Cell:New({ x = 26 })
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
