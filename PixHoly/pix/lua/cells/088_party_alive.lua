-- 同一属性按单位顺序集中创建，空槽由存在性控制。
local addonName, addonTable = ...

-- 项目引用
local Units = addonTable.UnitCells
local Alive = Units.Alive
local Party = Units.Party

Alive(88, Party)
