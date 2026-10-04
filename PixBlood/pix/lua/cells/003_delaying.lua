-- 第 3 格显示 Delaying() 状态：延迟中为白色，否则为黑色。
-- 初始化后以错峰的约 0.1 秒周期刷新。
local addonName, addonTable = ...

-- Lua 内置方法
local random                   = math.random
local insert                   = table.insert

-- WoW API
local CreateFrame              = CreateFrame
local EvaluateColorFromBoolean = C_CurveUtil.EvaluateColorFromBoolean

-- 项目引用
local COLOR                    = addonTable.COLOR
local Cell                     = addonTable.Cell
local UIInitFuncs              = addonTable.UIInitFuncs
local FrameLevel            = addonTable.FrameLevel
local BackgroundFrameResize = addonTable.BackgroundFrameResize
local Delaying = addonTable.Delaying

-- 本地配置
local eventFrame = CreateFrame("Frame")
local X          = 3
local cell

local function RefreshEnableCell()
    if not cell then -- 更新回调可能先于延迟 UI 初始化到达
        return
    end
    local color = EvaluateColorFromBoolean(Delaying(), COLOR.WHITE, COLOR.BLACK)
    cell:setCell(color)
end

local function InitializeEnableCell()
    cell = Cell:New({ x = X })
end


local fastTimeElapsed = -random()               -- 随机负初值推迟首次刷新，不改变全局随机种子
eventFrame:HookScript("OnUpdate", function(_, elapsed)
    fastTimeElapsed = fastTimeElapsed + elapsed
    if fastTimeElapsed > 0.1 then
        fastTimeElapsed = fastTimeElapsed - 0.1
        RefreshEnableCell()
    end
end)
insert(UIInitFuncs, InitializeEnableCell)
