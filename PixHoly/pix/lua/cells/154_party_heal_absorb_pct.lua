-- 同一属性按单位顺序集中创建，空槽由存在性控制。
local addonName, addonTable = ...

-- 项目引用
local Units = addonTable.UnitCells
local HealAbsorb = Units.HealAbsorb
local Party = Units.Party

HealAbsorb(154, Party)
