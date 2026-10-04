-- 同一属性按单位顺序集中创建，空槽由存在性控制。
local addonName, addonTable = ...

-- 项目引用
local Units = addonTable.UnitCells
local Number = Units.Number
local Party = Units.Party
local Class = Units.Class

Number(108, Party, Class)
