-- 治疗石触发血量，默认30%；0关闭自动使用，配置持久化。
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
local config = Config("healthstone_health_threshold")
local cell
local eventFrame

config:set_default(30)

local function Refresh()
    if not cell then return end
    local value = floor(max(0, min(100, tonumber(config:get_value()) or 30)) + 0.5)
    local gray = value / 255
    cell:setCellRGBA(gray, gray, gray)
end

insert(ConfigRows, {
    type = "slider", name = "治疗石血量（%）",
    tooltip = "自身预测生命百分比不高于此值且治疗石可用时使用；0关闭自动使用。",
    bind_config = config, default_value = 30, min_value = 0, max_value = 100, step = 1,
})
config:register_callback(Refresh)
insert(UIInitFuncs, function()
    cell = Cell:New({ x = 74 })
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
