-- 同一属性按单位顺序集中创建，空槽由存在性控制。
local addonName, addonTable = ...

-- WoW API
local UnitExists = UnitExists

-- 项目引用
local Units = addonTable.UnitCells
local Boolean = Units.Boolean
local Party = Units.Party

Boolean(84, Party, UnitExists)
