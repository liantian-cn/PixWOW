-- 第7格显示玩家是否组队；队伍变化统一刷新。
local addonName, addonTable = ...

-- WoW API
local IsInGroup = IsInGroup

-- 项目引用
local UnitBoolean = addonTable.UnitCells.Boolean

UnitBoolean(7, { "player" }, function() return IsInGroup() end)
