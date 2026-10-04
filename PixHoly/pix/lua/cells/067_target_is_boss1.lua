-- 同一属性按单位顺序集中创建，空槽由存在性控制。
local addonName, addonTable = ...

-- WoW API
local UnitIsUnit = UnitIsUnit

-- 项目引用
local Units = addonTable.UnitCells
local Boolean = Units.Boolean

Boolean(67, { "target" }, function(unit) return UnitIsUnit(unit, "boss1") end, { "PLAYER_TARGET_CHANGED", "INSTANCE_ENCOUNTER_ENGAGE_UNIT" }, 0.1)
