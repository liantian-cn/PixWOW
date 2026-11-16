-- 使用撕裂开关：默认开启，配置持久化保存。
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
local config = Config("rend_enabled")
local cell
local button, icon
local eventFrame

config:set_default(true)

local function Refresh()
    if button then icon:SetTexture(config:get_value() == true and 132155 or 132363) end
    if not cell then return end
    cell:setCell(config:get_value() == true and COLOR.WHITE or COLOR.BLACK)
end

insert(ConfigRows, {
    type = "combo", name = "使用撕裂",
    tooltip = "允许对非机械、非元素且类型已知的目标维护自身撕裂。",
    bind_config = config, default_value = true,
    options = { { k = false, v = "否" }, { k = true, v = "是" } },
})
config:register_callback(Refresh)
insert(UIInitFuncs, function()
    cell = Cell:New({ x = 27 })
    -- TOC先加载模式模块；其UI初始化先创建AttackModeFrame，此处才读取动态对象。
    button = CreateFrame("Button", addonName .. "RendFrame", addonTable.AttackModeFrame)
    button:SetSize(66, 66)
    button:SetPoint("TOPLEFT", addonTable.AttackModeFrame, "TOPRIGHT", 0, 0)
    button:RegisterForClicks("LeftButtonUp")
    icon = button:CreateTexture(nil, "ARTWORK")
    icon:SetSize(60, 60)
    icon:SetPoint("CENTER")
    button:SetScript("OnClick", function() config:set_value(not config:get_value()) end)
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
