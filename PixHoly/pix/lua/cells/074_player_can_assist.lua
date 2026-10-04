-- 同一属性按单位顺序集中创建，空槽由存在性控制。
local addonName, addonTable = ...

-- WoW API
local UnitCanAssist = UnitCanAssist

-- 项目引用
local Units = addonTable.UnitCells
local Boolean = Units.Boolean

Boolean(74, { "player" }, function(unit) return UnitCanAssist("player", unit) end, { "UNIT_FLAGS", "UNIT_TARGETABLE_CHANGED" })
